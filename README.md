# 概述

这是一些经过测试的 docker 服务编排，对于服务相关的介绍，在其对应的目录下说明。一般情况下可以直接 `docker-compose up` 或者 `docker stack deploy`，但涉及到大量数据存储的服务，最好还配置好数据存储目录，再启动服务。在此包括有两个 shell 脚本，可能会减少您部署和管理的时间。

## run_compose.sh

这是一个基于docker-compose编排软件编写的脚本，基本上支持docker-compose主要的命令操作。

### 准备

在使用前请务必确认 /usr/local/bin/docker-compose 文件存在，并且 docker-compose version >= '1.21.0' ，您可以从 docker 官方 github 上下载，也可以点击[Docker 套装快速安装](https://github.com/xiangxiaoc/docker-ce_docker-compose_nvidia-docker2)，来获取 docker-compose

## run_stack.sh

这是一个基于 `docker stack COMMAND` 命令的管理编排脚本，同时也整合了一些 `docker service` 的命令，方便统一操作。

### 准备

请确保您的 "docker daemon" 已经启用 "swarm mode"，并且 docker-ce version >= '17.12.0'

## Compose File Format

默认的编排文件格式版本可能过高，结合 docker-ce 或者 docker-compose 的版本适当降低编排文件格式版本