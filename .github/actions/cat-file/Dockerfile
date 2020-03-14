# Container image that runs your code
FROM alpine:3.10

RUN cat "echo ::set-output name=text::\$(cat @1)" > bootstrap.sh

ENTRYPOINT ["bootstrap.sh"]
