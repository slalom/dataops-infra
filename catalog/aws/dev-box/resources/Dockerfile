ARG source_image=dataopstk/tapdance:mssql-to-snowflake-test--pre
FROM ${source_image}

# Install SSH Server
RUN apt-get update \
    && apt-get install -y \
    openssh-server \
    nano \
    && mkdir -p /var/run/sshd

EXPOSE 22

# Syntax of next command requires bash, not supported in sh
SHELL ["/bin/bash", "-c"]

RUN echo $'#!/bin/bash \
    \n\
    \nif [ -z "$SSH_PUBLIC_KEY_BASE64" ]; then\
    \n\techo "Missing SSH public key in the SSH_PUBLIC_KEY_BASE64 env variable."\
    \n\texit 1\
    \nfi\
    \nmkdir -p ~/.ssh\
    \n\
    \necho "Installing SSH public key from SSH_PUBLIC_KEY env variable..."\
    \necho $SSH_PUBLIC_KEY_BASE64 | base64 --decode > ~/.ssh/authorized_keys\
    \nunset SSH_PUBLIC_KEY_BASE64\
    \n\
    \necho "Starting the SSH daemon..."\
    \n/usr/sbin/sshd -D\
    \n' >> ./bootstrap.sh
RUN chmod +x ./bootstrap.sh

ENTRYPOINT [ "./bootstrap.sh" ]
