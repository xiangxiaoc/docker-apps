FROM node:10.15.2-alpine

MAINTAINER xiangxiaoc xiangxiaoc@vip.com

LABEL maintainer="xiangxiaoc xiangxiaoc@vip.qq.com"

# 安装yapi-cli
RUN npm install -g yapi-cli --registry https://registry.npm.taobao.org 

