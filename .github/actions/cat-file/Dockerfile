# Container image that runs your code
FROM alpine:3.10

RUN echo "#!/bin/bash\necho ::set-output name=text::\$(cat @1)" > bootstrap.sh
RUN chmod 777 bootsrap.sh

ENTRYPOINT ["./bootstrap.sh"]
