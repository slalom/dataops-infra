FROM alpine:3.10

RUN echo "echo ::set-output name=text::\$(cat \$1)" > /home/bootstrap.sh
RUN chmod 777 /home/bootstrap.sh
RUN pwd && ls -la

ENTRYPOINT ["sh", "/home/bootstrap.sh"]
