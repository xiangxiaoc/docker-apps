FROM node:10.15.2-alpine

RUN apk add git python make

RUN mkdir yapi &&\
    cd yapi &&\
    git clone https://github.com/YMFE/yapi.git vendors &&\
    cp vendors/config_example.json ./config.json &&\
    cd vendors &&\
    npm install --production --registry https://registry.npm.taobao.org &&\
    npm run install-server

WORKDIR /yapi/vendors

CMD [ "node","server/app.js" ]

