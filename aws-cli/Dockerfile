# FROM python:3.8.0-buster
FROM python:3.8.0-slim
# FROM python:3.8.0-alpine
RUN pip install awscli -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com && \
    echo "complete -C aws_completer aws" >>/root/.bashrc
