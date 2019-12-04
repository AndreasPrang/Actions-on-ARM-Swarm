FROM alpine:3.7

RUN apk add --update curl git

RUN mkdir actions-runner && cd actions-runner
WORKDIR actions-runner

RUN curl -O https://githubassets.azureedge.net/runners/2.161.0/actions-runner-linux-arm-2.161.0.tar.gz
RUN tar xzf ./actions-runner-linux-arm-2.161.0.tar.gz

ADD run_worker.sh /actions-runner/run_worker.sh
ADD .env /actions-runner/.env

CMD /actions-runner/run_worker.sh
