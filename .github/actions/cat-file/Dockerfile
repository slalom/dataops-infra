# Container image that runs your code
FROM alpine:3.10

WORKDIR /home
RUN pwd && ls -la
RUN echo "echo ::set-output name=text::\$(cat \$1)" > bootstrap.sh
RUN chmod 777 ./bootstrap.sh
RUN pwd && ls -la

ENTRYPOINT ["sh", "/home/bootstrap.sh"]
