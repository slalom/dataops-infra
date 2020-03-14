# Container image that runs your code
FROM alpine:3.10

RUN pwd && ls -la
RUN echo "#!/bin/bash\necho ::set-output name=text::\$(cat @1)" > bootstrap.sh
RUN pwd && ls -la
RUN chmod 777 ./bootstrap.sh

ENTRYPOINT ["./bootstrap.sh"]
