FROM ubuntu:18.04

WORKDIR /root

ADD ubuntu_1804-add_aliyun_apt_source.sh /root/

ADD https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip /root

RUN bash ubuntu_1804-add_aliyun_apt_source.sh && \
    apt update && apt install -y --no-install-recommends unzip graphviz && \
    unzip terraform_0.12.18_linux_amd64.zip && \
    install terraform /usr/local/bin/terraform && \
    rm terraform terraform_0.12.18_linux_amd64.zip && \
    terraform -install-autocomplete