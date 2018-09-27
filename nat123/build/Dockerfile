FROM mono:5.14.0

ADD nat123linux20180627.tar.gz /nat123

VOLUME [ "/nat123/data" ]

WORKDIR /nat123/data

ENV USERNAME= \
    PASSWORD= 

CMD mono ../nat123linux.sh autologin ${USERNAME} ${PASSWORD}