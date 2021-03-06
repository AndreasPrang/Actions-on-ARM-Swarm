FROM debian:buster

#RUN apt-get update; apt-get install -y curl git

#RUN mkdir actions-runner && cd actions-runner
#WORKDIR actions-runner

#RUN curl -O https://githubassets.azureedge.net/runners/2.161.0/actions-runner-linux-arm-2.161.0.tar.gz
#RUN tar xzf ./actions-runner-linux-arm-2.161.0.tar.gz

#RUN sed -i 's/user_id=`id -u`//g' config.sh
#RUN sed -i 's/user_id=`id -u`//g' run.sh

#RUN ./bin/installdependencies.sh

#ADD run_worker.sh /actions-runner/run_worker.sh

#CMD /actions-runner/run_worker.sh


ARG GH_RUNNER_VERSION="2.165.0"
ARG DOCKER_COMPOSE_VERSION="1.24.1"

ENV RUNNER_NAME=""
ENV RUNNER_WORK_DIRECTORY="_work"
ENV RUNNER_TOKEN=""
ENV RUNNER_REPOSITORY_URL=""
ENV ARCHITECTURE="arm"

# Labels.
LABEL maintainer="me@tcardonne.fr" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.name="tcardonne/github-runner" \
    org.label-schema.description="Dockerized GitHub Actions runner." \
    org.label-schema.url="https://github.com/tcardonne/docker-github-runner" \
    org.label-schema.vcs-url="https://github.com/tcardonne/docker-github-runner" \
    org.label-schema.vendor="Thomas Cardonne" \
    org.label-schema.docker.cmd="docker run -it tcardonne/github-runner:latest"

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y \
        curl \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common \
        git \
        sudo \
        supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

# Install Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

# Install Docker-Compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

RUN rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN useradd -ms /bin/bash runner && \
    usermod -aG docker runner && \
    usermod -aG sudo runner && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /home/runner

RUN echo "https://githubassets.azureedge.net/runners/${GH_RUNNER_VERSION}/actions-runner-linux-${ARCHITECTURE}-${GH_RUNNER_VERSION}.tar.gz"

RUN curl -O https://githubassets.azureedge.net/runners/${GH_RUNNER_VERSION}/actions-runner-linux-${ARCHITECTURE}-${GH_RUNNER_VERSION}.tar.gz \
    && tar -zxf actions-runner-linux-${ARCHITECTURE}-${GH_RUNNER_VERSION}.tar.gz \
    && rm -f actions-runner-linux-${ARCHITECTURE}-${GH_RUNNER_VERSION}.tar.gz \
    && ./bin/installdependencies.sh \
    && chown -R runner: /home/runner

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

USER runner
