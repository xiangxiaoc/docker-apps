# docker-compose 脚本客户端

[English README](README.md)

## 概述

这里是一些经过测试的容器化服务编排项目。 基本上是遵循 Docker 倡导的 "编码一次，到处运行"。 对 `docker-compose` 熟悉的老手可以直接取用需要的 YAML 文件。 相关的注意事项，如果有的话，会在其对应的目录内补充说明。

其中几个编排项目是专门用来了解和学习 docker 相关的机制。例如 `logging-driver`，可以了解到可以给容器配置多种日志驱动，按需进行日志管理。

## docker-compose.sh 脚本

本项目提供了一个 Shell 脚本，通过交互的方式，实现了常用的操作。使用它来部署和管理可能会减少一点点操作时间，但对 docker 及 docker-compose 系列命令不熟悉的同学有较大的帮助。(事实上我一直在使用，因为懒得敲命令)

### run_stack.sh(弃用)

基于 `docker stack COMMAND` 命令的管理编排脚本，同时也整合了一些 `docker service` 的命令，方便统一操作。

请确保 Docker 服务器已经启用 "swarm mode"，并且 docker-ce version >= '17.12.0'

```sh
# 初始化本机 Docker 服务器为 Swarm 集群主节点
docker swarm init
```

## Compose File Format

默认的编排文件版本基本采用的是 2.x，方便直接设置内存分配，如果安装的 docker 和 docker-compose 版本过低，参考官方文档查看对照表，根据自己的版本进行适当的调整。

https://docs.docker.com/compose/compose-file/compose-versioning/#compatibility-matrix

## 小贴士

中国区 registry mirror https://registry.docker-cn.com
