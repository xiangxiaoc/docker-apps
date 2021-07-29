FROM ubuntu:18.04

WORKDIR /root

ADD ubuntu_1804-add_aliyun_apt_source.sh /root/

RUN bash ubuntu_1804-add_aliyun_apt_source.sh &&\
    apt update && apt install -y --no-install-recommends python python-pip python-setuptools groff less &&\
    pip install awscli -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com &&\
    echo "complete -C aws_completer aws" >>/root/.bashrc
