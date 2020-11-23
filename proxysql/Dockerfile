FROM centos:7

RUN yum -y --setopt=tsflags=nodocs update
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
RUN yum -y --setopt=tsflags=nodocs install which wget unzip sysvinit-tools
RUN yum install epel-release -y && yum install jq -y && yum install gettext -y && yum install epel-release -y && yum install moreutils -y 
RUN yum -y --setopt=tsflags=nodocs install https://repo.percona.com/percona/yum/percona-release-1.0-7.noarch.rpm
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Percona
RUN yum -y --setopt=tsflags=nodocs install proxysql Percona-Server-client-57

COPY proxysql.cnf /etc/proxysql.cnf

ADD consul_1.4.2_linux_amd64.zip /root/
RUN unzip /root/consul_1.4.2_linux_amd64.zip -d /root/ && \
    rm -f /root/consul_1.4.2_linux_amd64.zip && \
    mv /root/consul /usr/local/bin/ && \
    mkdir -p /etc/consul.d/

COPY config.json /etc/consul.d/config.json
COPY entrypoint.sh /root/entrypoint.sh
COPY mysql-handler.sh /root/mysql-handler.sh
COPY proxysql-handler.sh /root/proxysql-handler.sh

RUN chmod a+x /root/entrypoint.sh
RUN chmod a+x /root/mysql-handler.sh
RUN chmod a+x /root/proxysql-handler.sh
RUN touch /var/log/mysql-handler.log
RUN touch /var/log/proxysql-handler.log
RUN touch /var/log/entrypoint.log

RUN yum -y clean all && rm -rf /var/cache/yum/*

EXPOSE 3306/tcp 6032/tcp

WORKDIR /root

CMD ["/root/entrypoint.sh"]
