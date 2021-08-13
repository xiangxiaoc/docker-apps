# docker apps

[中文版 README](README_zh.md)

## Overview

Here are some tested containerized service orchestration projects. Basically follow the "coding once, run everywhere" advocated by Docker. Veteran familiar with `docker-compose` can directly access the required YAML files. Relevant precautions, if any, will be supplemented in the corresponding catalog.

Several of the orchestration projects are dedicated to understanding and learning docker-related mechanisms. For example, `logging-driver`, you can learn that you can configure a variety of log drivers for the container, and perform log management as needed.

## docker-compose.sh Script

This project provides a shell script that implements common operations through interaction. Using it for deployment and management may reduce operation time a little, but it is of great help to students who are not familiar with the docker and docker-compose series of commands. (Actually, I have been using it because I am lazy, so I can type less commands)

## Compose File Format

The default version of the layout file basically uses 2.x. Compared with 1.x, it expands many functions, and almost all the parameters of the docker command are implemented. The examples are as follows.

```yaml
version: "2.4"
services:
  postgresql:
    image: postgresql
    ports:
      - 5432:5432

    # cpu set
    cpu_count: 2
    cpu_percent: 50
    cpus: 0.5
    cpu_shares: 73
    cpu_quota: 50000
    cpu_period: 20ms
    cpuset: 0,1

    # user and work dir set
    user: postgresql
    working_dir: /code

    # system level set in container
    domainname: foo.com
    hostname: foo
    ipc: host
    mac_address: 02:42:ac:11:65:43

    # memory set
    mem_limit: 1000000000
    memswap_limit: 2000000000
    mem_reservation: 512m
    privileged: true

    # auto kill if oom
    oom_score_adj: 500
    oom_kill_disable: true

    # other set
    read_only: true
    shm_size: 64M
    stdin_open: true
    tty: true
```
You can refer to the official documentation to check the comparison table, and confirm whether the compose file version is supported according to the local Docker Engine version.

https://docs.docker.com/compose/compose-file/compose-versioning/#compatibility-matrix
