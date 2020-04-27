#!/bin/bash

# docker-compose 管理脚本

##################
# Initialization #
##################

CONFIG_FILE='docker-compose.conf'

function parse_config_file() {
    local field=$1
    value=$(sed "/^$field=/!d;s/.*=//" $CONFIG_FILE)
    eval echo "$value"
}

compose_file=$(parse_config_file compose_file)
container_group_name=$(parse_config_file container_group_name)
docker_daemon_host=$(parse_config_file docker_daemon_host)
docker_daemon_port=$(parse_config_file docker_daemon_port)

##########################
# Global variable define #
##########################

if [ -n "$docker_daemon_port" ]; then
    DOCKER_DAEMON=$docker_daemon_host:$docker_daemon_port
fi
if [ -z "$docker_daemon_host" ] && [ -z "$docker_daemon_port" ]; then
    DOCKER_HOST_DISPLAY="本机(/var/run/docker.sock)"
fi

# Output Color
CR='\e[0;31m'
#CG='\e[0;32m'
#CY='\e[0;33m'
#CLB='\e[1;30m'
RC='\e[0m'

################################
# Pre-check running dependency #
################################

if ! command -v docker &>/dev/null; then
    echo -e "${CR}docker command is not found. Please check in \$PATH or install if need.${RC}"
    exit 0
fi
if ! command -v docker-compose &>/dev/null; then
    echo -e "${CR}docker-compose command is not found. Please check in \$PATH or install if need.${RC}"
    exit 0
fi

function reconfigure() {
    cat <<EOF_init
##### docker-compose 部署脚本 ######

初始化设置 ...

EOF_init

    read -r -p "更改 docker daemon 地址？[y/N]:(默认 N) " cho
    if [ -n "$cho" ]; then
        if [ "$cho" = 'y' ] || [ "$cho" = 'Y' ]; then
            read -r -p "输入远程 Docker daemon 地址（输入空则控制本地 Docker 服务 ）： " new_docker_host
            sed -i "/^docker_daemon_host/ c docker_daemon_host=\"$new_docker_host\"" $CONFIG_FILE
        fi
    fi
    echo

    read -r -p "更改编排文件的路径？[y/N]:(默认 N) " cho
    if [ -n "$cho" ]; then
        if [ "$cho" = 'y' ] || [ "$cho" = 'Y' ]; then
            read -r -p "输入集群编排文件名： " new_compose_file
            sed -i "/^compose_file/ c compose_file=\"$new_compose_file\"" $CONFIG_FILE
        fi
    fi
    echo

    read -r -p "更改容器组名称？[y/N]:(默认 N) " cho
    if [ -n "$cho" ]; then
        if [ "$cho" = 'y' ] || [ "$cho" = 'Y' ]; then
            read -r -p "输入服务栈名称： " new_container_group_name
            sed -i "/^container_group_name/ c container_group_name=\"$new_container_group_name\"" $CONFIG_FILE
        fi
    fi
    echo
}

######################
# image manage Entry #
######################
function docker_image_ls() {
    docker -H "$DOCKER_DAEMON" images
}

function docker_image_save() {
    now_time=$(date "+%Y-%m-%d_%H%M")
    case $1 in
    "")
        mkdir ./images_bak_"$now_time"
        grep "image:" "$compose_file" | sed 's/#//' | awk '{print $2}' | sort -u | while IFS= read -r line; do
            j=$(echo "$line" | sed "s/:/_/g;s/\//-/g")
            if docker -H "$DOCKER_DAEMON" image save "$line" >./images_bak_"$now_time"/"$j"; then
                echo "$line 已导出为 $j"
            else
                echo "$line 导出失败"
            fi
        done
        ;;
    "-c")
        mkdir ./base_images_from_compose_bak_"$now_time"
        grep "base_image=" "$compose_file" | sed 's/#//' | awk '{print $2}' | sort -u | cut -d '=' -f 2 | while IFS= read -r line; do
            j=$(echo "$line" | sed "s/:/_/g;s/\//-/g")
            if docker -H "$DOCKER_DAEMON" image save "$line" >./base_images_from_compose_bak_"$now_time"/"$j"; then
                echo "$line 已导出为 $j"
            else
                echo "$line 导出失败"
            fi
        done
        ;;
    esac
}

function docker_image_load() {
    case $1 in
    "")
        for i in images/*; do
            docker -H "$DOCKER_DAEMON" image load <./images/"$i"
        done
        ;;
    $1)
        for i in "$1"/*; do
            docker -H "$DOCKER_DAEMON" image load <./"$1"/"$i"
        done
        ;;
    esac
}

function docker_image_build() {
    case $1 in
    "")
        docker_service_choose
        docker-compose -H "$DOCKER_DAEMON" -f "$compose_file" build "$docker_service_choice"
        ;;
    "-a")
        docker-compose -H "$DOCKER_DAEMON" -f "$compose_file" build
        ;;
    esac
}

function docker_image_push() {
    case $1 in
    "")
        docker_service_choose
        docker-compose -H "$DOCKER_DAEMON" -f "$compose_file" push "$docker_service_choice"
        ;;
    "-a")
        docker-compose -H "$DOCKER_DAEMON" -f "$compose_file" push
        ;;
    esac
}

##################
# docker-compose #
##################
function docker_service_choose() {
    declare -A list
    i=0
    echo -e "序号  服务\n----------"
    service_list=$(docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" ps --services | sort)
    for docker_service_name in $service_list; do
        i=$((i + 1))
        if [ $i -lt 10 ]; then
            j=' '$i
            echo "$j.   $docker_service_name"
        else
            echo "$i.   $docker_service_name"
        fi
        list[$i]=$docker_service_name
    done
    echo
    read -r -p "选择服务，输入其序号，按回车执行： " cho
    docker_service_choice=${list[$cho]}
    echo
}

function docker_compose_port() {
    yml_ports_line=$(sed -n "1,/ports:/=" "$compose_file" | sed -n '$ p')
    yml_ports_value_line=$((yml_ports_line + 1))
    host_port=$(sed -n "${yml_ports_value_line}p" "$compose_file")
    case $1 in
    "")
        current_value=$(echo "$host_port" | cut -d ":" -f 1 | cut -d "\"" -f 2)
        echo "当前端口为 $current_value，下次执行 $0 up 将使用此端口"
        ;;
    $1)
        original_value=$(echo "$host_port" | cut -d ":" -f 1 | cut -d "\"" -f 2)
        if sed -i "s/$original_value/$1/" "$compose_file" &>/dev/null; then
            echo "已修改端口为 $1，再次执行 $0 up 生效"
        fi
        ;;
    esac
}

function docker_compose_up() {
    echo -e "读取部署编排文件 $compose_file \n开始创建容器 ... "
    docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" up -d
}

function docker_compose_start() {
    case $1 in
    "")
        docker_service_choose
        docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" start "$docker_service_choice"
        ;;
    "-a")
        docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" start
        ;;
    esac
}

function docker_compose_restart() {
    case $1 in
    "")
        docker_service_choose
        docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" restart "$docker_service_choice"
        ;;
    "-a")
        docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" restart
        ;;
    esac
}

function docker_compose_stop() {
    case $1 in
    "")
        docker_service_choose
        docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" stop "$docker_service_choice"
        ;;
    "-a")
        docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" stop
        ;;
    esac
}

function docker_compose_down() {
    echo -e "读取部署编排文件 $compose_file \n开始移除容器 ... "
    docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" down "$@"
}

function docker_compose_ps() {
    echo -e "\nContainers of $container_group_name group\n"
    docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" ps "$@"
}

function docker_compose_logs() {
    case $1 in
    "")
        docker_service_choose
        read -r -p "查看最近多少条日志？(默认：全部)： " tail_num
        [ -z "$tail_num" ] && tail_num="all"
        read -r -p "预览或下载到文件  [ 1 预览 | 2 下载 ]（默认：预览）： " download_cho
        [ -z "$download_cho" ] && download_cho="1" || download_cho=$download_cho
        case $download_cho in
        1)
            docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" logs -f --tail="$tail_num" "$docker_service_choice"
            ;;
        2)
            docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" logs --no-color --tail="$tail_num" "$docker_service_choice" &>"${docker_service_choice}"_"$(date '+%m月%d日_%H时%M分%S秒')""$([ -z "$tail_num" ] && echo "" || echo "_最近$tail_num条")".log
            echo "导出完成"
            ;;
        esac
        ;;
    "-a")
        read -r -p "查看最近多少条日志？(默认：全部)： " tail_num
        [ -z "$tail_num" ] && tail_num="all"
        docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" logs -f --tail="$tail_num"
        ;;
    esac
}

function docker_compose_bash() {
    docker_service_choose
    if ! docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" exec "$docker_service_choice" bash; then
        docker-compose -H "$DOCKER_DAEMON" -p "$container_group_name" -f "$compose_file" exec "$docker_service_choice" sh
    fi
}

##############
# Help Entry #
##############
function show_help() {
    cat <<EOF_help

Docker-Compose Deploy Script , Version: 1.4.0 , Build: 2018-12-04 14:18:37

Usage: $0 Command [arg]
            
Commands:

  init              脚本初始化
  images            查看 docker host 上的镜像
  save [-b|-c]      备份目前编排文件里面用到的镜像 [备份构建镜像的基础镜像]|[备份从编排文件中指定的基础镜像]
  load [dir_name]   载入 ./images 目录下的镜像 [指定目录]
  build [-a]        构建镜像 [-a 全部服务]
  push [-a]         推到镜像仓库 [-a 全部服务]
  port [PORT]       查看对外暴露端口 [指定对外暴露端口 示例：$0 port 51000]
  up                创建或重新创建容器，并启动
  start [-a]        启动停止中的服务
  restart [-a]      重启服务 [-a 全部服务]
  stop [-a]         停止服务 [-a 全部服务]
  down [-v]         移除全部容器 [-v 并且删除数据卷]
  ps                查看服务状态
  logs [-a]         查看服务日志 [-a 全部服务]
  bash              使用bash与容器交互

  -h, --help        显示此帮助页

# 以下是 Docker 主机地址和正在使用的编排文件，如需变更执行 $0 init 进行初始化
Docker Daemon:  $DOCKER_HOST_DISPLAY
Compose File:   $DOCKER_COMPOSE_FILE
Compose Name:   $DOCKER_COMPOSE_STACK

EOF_help
}

####################
# interactive_menu #
####################

function interactive_menu() {
    cat <<EOF_menu
以下是当前配置的 Docker Daemon 和编排文件：

Docker Daemon:      $DOCKER_HOST_DISPLAY
Compose file:       $compose_file
Container group:    $container_group_name

0. reconfigure          更改本机或远端的 Docker 服务器或编排组
1. list images          查看 docker daemon 的镜像
2. list containers      查看当前编排组容器概况
3. view logs            查看当前编排组容器日志
4. bash/sh in container 进入容器运行用 bash/sh 进行交互
5. compose up           创建并运行当前编排组
6. compose down         停止并删除当前编排组

EOF_menu
    read -r -p "选择功能，输入其序号: " cho
    case $cho in
    '0') reconfigure ;;
    '1') docker_image_ls ;;
    '2') docker_compose_ps ;;
    '3') docker_compose_logs ;;
    '4') docker_compose_bash ;;
    '5') docker_compose_up ;;
    '6') docker_compose_down ;;
    esac
}

###################
# Main Entry #
###################
function main() {
    main_command=$1
    shift
    case $main_command in
    '') interactive_menu ;;
    -h)
        show_help
        exit 0
        ;;
    --help)
        show_help
        exit 0
        ;;
    help)
        show_help
        exit 0
        ;;
    init)
        reconfigure
        exit 0
        ;;
    images)
        docker_image_ls
        exit 0
        ;;
    save)
        docker_image_save "$@"
        exit 0
        ;;
    load)
        docker_image_load "$@"
        exit 0
        ;;
    build)
        docker_image_build "$@"
        exit 0
        ;;
    push)
        docker_image_push "$@"
        exit 0
        ;;
    up)
        docker_compose_up "$@"
        exit 0
        ;;
    start)
        docker_compose_start "$@"
        exit 0
        ;;
    restart)
        docker_compose_restart "$@"
        exit 0
        ;;
    stop)
        docker_compose_stop "$@"
        exit 0
        ;;
    down)
        docker_compose_down "$@"
        exit 0
        ;;
    ps)
        docker_compose_ps "$@"
        exit 0
        ;;
    logs)
        docker_compose_logs "$@"
        exit 0
        ;;
    bash) docker_compose_bash ;;
    port)
        docker_compose_port "$@"
        exit 0
        ;;
    *)
        echo "需要执行命令，后面加上 --help 查看可执行命令的更多信息"
        exit 1
        ;;
    esac
}

main "$@"
