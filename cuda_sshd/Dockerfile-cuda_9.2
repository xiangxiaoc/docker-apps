FROM nvidia/cuda:9.2-cudnn7-devel-ubuntu18.04

RUN apt-get update

RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd

RUN echo 'root:root' |chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN mkdir /root/.ssh

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    sed -i "s#http://archive.ubuntu.com#http://mirrors.aliyun.com#g" /etc/apt/sources.list
    
EXPOSE 22

CMD    ["/usr/sbin/sshd", "-D"]
