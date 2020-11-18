FROM ubuntu:xenial

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  apt-utils \
  curl \
  tzdata \
  vim \
  unzip \
  jq

RUN apt-get install -y mysql-server-5.7 \
                       mysql-client-core-5.7 \
                       mysql-utilities

COPY my.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
RUN chown root:root /etc/mysql/mysql.conf.d/mysqld.cnf


ADD consul_1.4.2_linux_amd64.zip /root/
RUN unzip /root/consul_1.4.2_linux_amd64.zip -d /root/ && \
    rm -f /root/consul_1.4.2_linux_amd64.zip && \
    mv /root/consul /usr/local/bin/ && \
    mkdir -p /etc/consul.d/

COPY config.json /etc/consul.d/config.json
COPY entrypoint.sh /root/entrypoint.sh
COPY provisioning.sh /root/provisioning.sh
RUN chmod a+x /root/entrypoint.sh
RUN chmod a+x /root/provisioning.sh
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 3306/tcp

ENTRYPOINT ["/root/entrypoint.sh"]
