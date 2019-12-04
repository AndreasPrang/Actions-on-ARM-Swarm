FROM alpine:3.7

RUN mkdir actions-runner && cd actions-runner
WORKDIR actions-runner

RUN curl -O https://githubassets.azureedge.net/runners/2.161.0/actions-runner-linux-arm-2.161.0.tar.gz
RUN tar xzf ./actions-runner-linux-arm-2.161.0.tar.gz

ADD run_worker.sh run_worker.sh
ADD .env

CMD run_worker.sh
