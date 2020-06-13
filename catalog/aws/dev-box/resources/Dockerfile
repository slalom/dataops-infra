ARG source_image=dataopstk/tapdance:mssql-to-snowflake-test--pre
FROM ${source_image}

# Install SSH Server
RUN apt-get update \
    && apt-get install -y openssh-server \
    && mkdir -p /var/run/sshd

EXPOSE 22

# Syntax of next command requires bash, not supported in sh
SHELL ["/bin/bash", "-c"]

RUN echo $' \n\
    if [ -z "$SSH_PUBLIC_KEY" ]; then\n\
    \techo "Missing SSH public key in the SSH_PUBLIC_KEY env variable."\n\
    exit 1\n\
    fi\n\
    mkdir -p ~/.ssh\n\
    \n\
    # Install SSH public key from SSH_PUBLIC_KEY env variable \n\
    echo \$SSH_PUBLIC_KEY > ~/.ssh/authorized_keys\n\
    unset SSH_PUBLIC_KEY\n\
    \n\
    # Start the SSH daemon.\n\
    /usr/sbin/sshd -D\n\
    ' >> ./bootstrap.sh
RUN chmod +x ./bootstrap.sh

ENTRYPOINT [ "./bootstrap.sh" ]
