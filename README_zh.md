# docker apps

[English README](README.md)

## 概述

这里是一些经过测试的容器化服务编排项目。基本上是遵循 Docker 倡导的 "编码一次，到处运行"。 对 `docker-compose` 熟悉的老手可以直接取用需要的 YAML 文件。相关的注意事项，如果有的话，会在其对应的目录内补充说明。

其中几个编排项目是专门用来了解和学习 docker 相关的机制。例如 `logging-driver` ，可以了解到 docker 支持的日志驱动。

## docker-compose.sh 脚本

本项目提供了一个 Shell 脚本，通过交互的方式，实现了常用的操作。使用它来部署和管理可能会减少一点点操作时间，但对 docker 及 docker-compose 系列命令不熟悉的同学有较大的帮助。(实际上我一直在使用，因为懒，可以少敲点命令)

## docker-compose.yml File 格式

默认的编排文件版本基本采用的是 2.x，相比 1.x 扩展了很多功能，几乎将 docker 命令的参数都实现了，举例如下。

```yaml
version: "2.4"
services:
  postgresql:
    image: postgresql
    ports:
      - "5432:5432"

    # cpu 设置
    cpu_count: 2
    cpu_percent: 50
    cpus: 0.5
    cpu_shares: 73
    cpu_quota: 50000
    cpu_period: 20ms
    cpuset: 0,1

    # 用户和工作目录设置
    user: postgresql
    working_dir: /code

    # 在容器中系统级别的设置
    domainname: foo.com
    hostname: foo
    ipc: host
    mac_address: 02:42:ac:11:65:43

    # 内存设置
    mem_limit: 1000000000
    memswap_limit: 2000000000
    mem_reservation: 512m
    privileged: true

    # 超出内存则自动结束容器
    oom_score_adj: 500
    oom_kill_disable: true

    # 其他设置
    read_only: true
    shm_size: 64M
    stdin_open: true
    tty: true
```

可以参考官方文档查看对照表，根据本地的 Docker Engine 版本，确认是否支持 compose file 的版本。

https://docs.docker.com/compose/compose-file/compose-versioning/#compatibility-matrix

## 小贴士

### docker 安装

```shell
bash get-docker.sh --mirror Aliyun
```

### 加速镜像仓库
中国区 registry mirror https://registry.docker-cn.com
