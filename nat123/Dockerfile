FROM centos:7.5.1804

ADD nat123linux20180627.tar.gz /nat123

RUN yum install epel-release -y && \
    yum install mono-core -y
    # wget ftp://119.29.5.84/nat123linux20180627.tar.gz -o /nat123.tar.gz && \
    # tar zxvf nat123.tar.gz && \
    # rm -f /nat123.tar.gz

WORKDIR /nat123/data

VOLUME [ "/nat123/data" ]

CMD mono ../nat123linux.sh service
