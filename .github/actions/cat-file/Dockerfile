# Container image that runs your code
FROM alpine:3.10

RUN echo "echo ::set-output name=text::\$(cat \$1)" > bootstrap.sh
RUN chmod 777 ./bootstrap.sh

ENTRYPOINT ["sh", "./bootstrap.sh"]
