FROM centos:7

RUN yum -y --setopt=tsflags=nodocs update
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
RUN yum -y --setopt=tsflags=nodocs install https://repo.percona.com/percona/yum/percona-release-1.0-7.noarch.rpm
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Percona
RUN yum -y --setopt=tsflags=nodocs install Percona-Server-client-57
RUN yum -y --setopt=tsflags=nodocs install wget unzip
RUN yum install epel-release -y && yum install jq -y
RUN yum -y --setopt=tsflags=nodocs --skip-broken install https://github.com/github/orchestrator/releases/download/v3.0.14/orchestrator-3.0.14-1.x86_64.rpm
RUN yum -y --setopt=tsflags=nodocs --skip-broken install https://github.com/github/orchestrator/releases/download/v3.0.14/orchestrator-cli-3.0.14-1.x86_64.rpm

COPY orchestrator.conf.json /etc/orchestrator.conf.json
RUN chown root:root /etc/orchestrator.conf.json && \
    chmod a+x /etc/orchestrator.conf.json

ADD consul_1.4.2_linux_amd64.zip /root/
RUN unzip /root/consul_1.4.2_linux_amd64.zip -d /root/ && \
    rm -f /root/consul_1.4.2_linux_amd64.zip && \
    mv /root/consul /usr/local/bin/ && \
    mkdir -p /etc/consul.d/

COPY config.json /etc/consul.d/config.json
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod a+x /root/entrypoint.sh
RUN yum -y clean all && rm -rf /var/cache/yum/*

WORKDIR /root

EXPOSE 31456/tcp

ENTRYPOINT ["/root/entrypoint.sh"]
