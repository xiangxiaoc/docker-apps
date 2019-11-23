# 概述

这是一些经过测试的 docker 服务编排，对于服务相关的介绍，如果有的话，会在其对应的目录内说明。一般情况下可以直接 `docker-compose up` 或者 `docker stack deploy`，但涉及到大量数据存储的服务，最好还配置好数据存储目录，再启动服务。

其中可能会有几个部分是专门用来了解和学习的，通过修改配置文件中的 code，来测试和检验想要更改的选项是否生效。

## 两个脚本

在此提供了 Linux shell 脚本，可能只会减少一点点操作的时间，但对 docker 系列命令不熟悉的同学有较大的帮助。

### run_compose.sh

基于 `docker-compose COMMAND` 编排软件编写的脚本，基本上支持原生 docker-compose 主要的命令操作。

在使用前请务必确认 /usr/local/bin/docker-compose 文件存在，并且 docker-compose version >= '1.21.0' ，您可以从 docker 官方 [Github](https://github.com/docker/compose/releases) 下载 docker-compose，也可以点击[Docker 套装快速安装](https://github.com/xiangxiaoc/docker-ce_docker-compose_nvidia-docker2)，来获取 docker-compose

### run_stack.sh

基于 `docker stack COMMAND` 命令的管理编排脚本，同时也整合了一些 `docker service` 的命令，方便统一操作。

请确保 Docker 服务器已经启用 "swarm mode"，并且 docker-ce version >= '17.12.0'

```sh
# 初始化本机 Docker 服务器为 Swarm 集群主节点
docker swarm init
```

#### Compose File Format

默认的编排文件格式版本可能过高，结合 docker-ce 或者 docker-compose 的版本适当降低编排文件格式版本，参考官方文档查看对照表：

https://docs.docker.com/compose/compose-file/compose-versioning/#compatibility-matrix

## 小贴士

中国区 registry mirror https://registry.docker-cn.com