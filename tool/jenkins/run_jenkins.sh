#!/bin/bash
#
#

docker_compose_path="../../docker-compose"

[[ -x $docker_compose_path ]] || chmod +x $docker_compose_path
$docker_compose_path -f jenkins-prod.yml up -d
