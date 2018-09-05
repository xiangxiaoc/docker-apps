#!/bin/bash
# docker-compose 管理脚本

##########################
# global variable define #
##########################
docker_host_ip=""
[ -z $docker_host_ip ] && docker_remote_arg="" || docker_remote_arg="-H ${docker_host_ip}:2375"
[ -z $docker_host_ip ] && DOCKER_HOST="本机" || DOCKER_HOST="${docker_host_ip}:2375"
docker_compose_file="cadvisor/docker-compose.yml"
[ -z $docker_compose_file ] && docker_compose_file_arg="" || docker_compose_file_arg="-f $docker_compose_file"
[ -z $docker_compose_file ] && DOCKER_COMPOSE_FILE="未指定，默认使用 ./docker-compose.yml" || DOCKER_COMPOSE_FILE="$docker_compose_file"
docker_stack_name="cadvisor"
[ -z $docker_stack_name ] && docker_stack_name_arg="" || docker_stack_name_arg="-p $docker_stack_name"
[ -z $docker_stack_name ] && DOCKER_COMPOSE_STACK="未指定，默认使用 Compose File 所在目录名" || DOCKER_COMPOSE_STACK="$docker_stack_name"

dockerfile_file="*/build/*/Dockerfile"


string_placeholders="#####"

##################
# Initialization #
##################
function script_init() {
cat << EOF_init
$string_placeholders docker-compose 部署脚本 $string_placeholders

初始化设置 ...

EOF_init

    read -p "是否改变远程 Docker Host IP 地址？[y/N]:(默认 N) " cho
    if [ ! -z $cho ] ; then
        if [ $cho = 'y' -o $cho = 'Y' ] ; then
            read -p "输入远程 Docker Host 的 IP 地址（输入空则控制本地 Docker 服务 ）： " docker_host_ip_new
            sed -i  "/^docker_host_ip/ c docker_host_ip=\"$docker_host_ip_new\"" $0
        fi
    fi  
    echo

    # read -p "是否改变集群编排文件所在目录？[y/N]:(默认 N) " cho
    # if [ ! -z $cho ] ; then
    #     if [ $cho = 'y' -o $cho = 'Y' ] ; then
    #         read -p "输入集群编排文件目录路径： " docker_stack_compose_dir_new
    #         sed -i  "/^docker_stack_compose_dir/ c docker_stack_compose_dir=\"$docker_stack_compose_dir_new\"" $0
    #     fi
    # fi
    # echo

    read -p "是否改变集群编排文件名？[y/N]:(默认 N) " cho
    if [ ! -z $cho ] ; then
        if [ $cho = 'y' -o $cho = 'Y' ] ; then
            read -p "输入集群编排文件名： " docker_compose_file_new
            sed -i  "/^docker_compose_file/ c docker_compose_file=\"$docker_compose_file_new\"" $0
        fi
    fi
    echo

    read -p "是否改变服务栈名称？[y/N]:(默认 N) " cho
    if [ ! -z $cho ] ; then
        if [ $cho = 'y' -o $cho = 'Y' ] ; then
            read -p "输入服务栈名称： " docker_stack_name_new
            sed -i  "/^docker_stack_name/ c docker_stack_name=\"$docker_stack_name_new\"" $0
        fi
    fi
    echo

echo -e "初始化完成，即将根据 $([ -z $docker_compose_file_new ] && echo $docker_compose_file || echo $docker_compose_file_new) 管理 $([ -z $docker_host_ip_new ] && echo $docker_host_ip || echo $docker_host_ip_new) $([ -z $docker_stack_name_new ] && echo $docker_stack_name || echo $docker_stack_name_new) 服务栈，请运行 $0 其他命令"

}



###########################
# image manage entrypoint #
###########################
function docker_image_ls() {
    docker $docker_remote_arg images
}

function docker_image_save() {
    now_time=$(date "+%Y-%m-%d_%H%M")
    case $1 in 
    "")
        mkdir ./images_bak_$now_time
        for i in $( grep "image:" $docker_compose_file | sed 's/#//' |  awk '{print $2}' | sort -u )
            do
                j=$(echo $i | sed "s/:/_/g;s/\//-/g" )
                docker $docker_remote_arg image save $i > ./images_bak_$now_time/$j
            done
    ;;
    "-b")
        mkdir ./images_$now_time
        for i in $( grep "FROM" $dockerfile_file | awk '{print $NF}' | sort -u )
            do
                j=$(echo $i | sed "s/:/_/g;s/\//-/g" )
                docker $docker_remote_arg image save $i > ./images_$now_time/$j
            done
    ;;
    esac
}

function docker_image_load() {
    case $1 in
    "")
    for i in $(ls ./images)
        do
            docker $docker_remote_arg image load < ./images/$i
        done
    ;;
    $1)
    for i in $(ls ./$1)
        do
            docker $docker_remote_arg image load < ./$1/$i
        done
    ;;
    esac
}

function docker_image_build() {
    case $1 in
        "")
            docker_service_choose
            docker-compose $docker_remote_arg $docker_compose_file_arg build $docker_service_choice 
        ;;
        "-a") 
            docker-compose $docker_remote_arg $docker_compose_file_arg build
        ;;
    esac
}

function docker_image_push() {
    case $1 in
        "")
            docker_service_choose
            docker-compose $docker_remote_arg $docker_compose_file_arg push $docker_service_choice
        ;;
        "-a")
            docker-compose $docker_remote_arg $docker_compose_file_arg push
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
    for docker_service_name in $(docker_compose_ps --services | sort)
        do
            i=$((i+1))
            if [ $i -lt 10 ] ; then
                j=' '$i
                echo "$j.   $docker_service_name"
            else
                echo "$i.   $docker_service_name"
            fi
            list[$i]=$docker_service_name
        done
    echo 
    read -p "选择服务，输入其序号，按回车执行： " cho
    docker_service_choice=${list[$cho]}
    echo
}


function docker_compose_port() {
    yml_ports_line=$(sed -n "1,/ports:/=" $docker_compose_file | sed -n '$ p' )
    yml_ports_value_line=$(($yml_ports_line+1))
    host_port=$(sed -n "${yml_ports_value_line}p" $docker_compose_file)
    case $1 in
    "")
    current_value=$(echo $host_port | cut -d ":" -f 1 |cut -d "\"" -f 2)
    echo "当前端口为 $current_value，下次执行 $0 up 将使用此端口"
    ;;
    $1)
    original_value=$(echo $host_port | cut -d ":" -f 1 |cut -d "\"" -f 2)
    sed -i "s/$original_value/$1/" $docker_compose_file &> /dev/null
    [ $? -eq 0 ] && echo "已修改端口为 $1，再次执行 $0 up 生效"
    ;;
    esac
}

function docker_compose_up() {
    echo -e "读取部署编排文件 ./$docker_compose_file \n开始创建容器 ... "
    docker-compose $docker_stack_name_arg $docker_remote_arg $docker_compose_file_arg up -d
}

function docker_compose_start() {
    case $1 in
    "")
        docker_service_choose
        docker-compose $docker_stack_name_arg $docker_remote_arg $docker_compose_file_arg start $docker_service_choice
    ;;
    "-a") 
        docker-compose $docker_stack_name_arg $docker_remote_arg $docker_compose_file_arg start
    ;;
    esac
}

function docker_compose_restart() {
    case $1 in
    "")
        docker_service_choose
        docker-compose $docker_stack_name_arg $docker_remote_arg $docker_compose_file_arg restart $docker_service_choice
    ;;
    "-a") 
        docker-compose $docker_stack_name_arg $docker_remote_arg $docker_compose_file_arg restart
    ;;
    esac
}

function docker_compose_stop() {
    case $1 in
    "")
        docker_service_choose
        docker-compose $docker_stack_name_arg $docker_remote_arg $docker_compose_file_arg stop $docker_service_choice
    ;;
    "-a")  
        docker-compose $docker_stack_name_arg $docker_remote_arg $docker_compose_file_arg stop
    ;;
    esac
}

function docker_compose_down() {
    docker-compose $docker_stack_name_arg $docker_remote_arg $docker_compose_file_arg down $@
}

function docker_compose_ps() {
    docker-compose $docker_stack_name_arg $docker_remote_arg $docker_compose_file_arg ps $@
}

function docker_compose_logs() {
    case $1 in
    "") 
        docker_service_choose
        read -p "查看最近多少条日志？(默认：全部)： " tail
        [ -z $tail ] && tail_arg="--tail all" || tail_arg="--tail $tail"
        read -p "预览或下载到文件  [ 1 预览 | 2 下载 ]（默认：预览）： " download_cho
        [ -z $download_cho ] && download_cho="1" || download_cho=$download_cho
        case $download_cho in 
            1)  
                docker-compose $docker_stack_name_arg $docker_remote_arg $docker_compose_file_arg logs -f $tail_arg $docker_service_choice 
            ;;
            2)  
                docker-compose $docker_stack_name_arg $docker_remote_arg $docker_compose_file_arg logs --no-color $tail_arg $docker_service_choice &> ${docker_service_choice}_$(date "+%m月%d日_%H时%M分%S秒")$([ -z $tail ] && echo "" || echo "_最近$tail条").log
                echo "导出完成"
            ;;
        esac
    ;;
    "-a") 
        read -p "查看最近多少条日志？(默认：全部)： " tail
        [ -z $tail ] && tail_arg="--tail all" || tail_arg="--tail $tail"
        docker-compose $docker_stack_name_arg $docker_remote_arg $docker_compose_file_arg logs -f $tail_arg   
    ;;
    esac
}

###################
# help entrypoint #
###################
function show_help() {
cat << EOF_help

Docker-Compose deploy script , Version: 1.3.2 , build: 2018-09-05 19:35

Usage: $0 Command [arg]
            
Commands:

  init              脚本初始化
  images            查看 docker host 上的镜像
  save [-b]         备份目前编排文件里面用到的镜像 [备份构建镜像的基础镜像] 
  load [dir_name]   载入 ./images 目录下的镜像 [指定目录]
  build [-a]        构建镜像 [-a 全部服务]
  push [-a]         推到镜像仓库 [-a 全部服务]
  port [PORT]       查看对外暴露端口 [指定对外暴露端口 示例：$0 port 51000]
  up                创建或重新创建容器，并启动
  start [-a]        启动停止中的服务
  restart [-a]      重启服务 [-a 全部服务]
  stop [-a]         停止服务 [-a 全部服务]
  down [-v]         移除全部容器[-v 并且删除数据卷]
  ls                查看服务状态
  logs [-a]         查看服务日志 [-a 全部服务]

  -h, --help        显示此帮助页

# 以下是 Docker 主机地址和正在使用的编排文件，如需变更执行 $0 init 进行初始化
Docker Daemon： $DOCKER_HOST
Compose File： $DOCKER_COMPOSE_FILE
Compose Stack name: $DOCKER_COMPOSE_STACK

EOF_help
}

###################
# main entrypoint #
###################
function main() {
    main_command=$1
    shift
    case $main_command in 
        -h)         show_help ;                 exit 0  ;;
        --help)     show_help ;                 exit 0  ;;
        init)       script_init ;               exit 0  ;;
        images)     docker_image_ls ;           exit 0  ;;
        save)       docker_image_save $@;       exit 0  ;;
        load)       docker_image_load $@ ;      exit 0  ;;
        build)      docker_image_build $@ ;     exit 0  ;;
        push)       docker_image_push $@ ;      exit 0  ;;
        up)         docker_compose_up ;         exit 0  ;;
        start)      docker_compose_start ;      exit 0  ;;
        restart)    docker_compose_restart $@;  exit 0  ;;
        stop)       docker_compose_stop $@ ;    exit 0  ;;
        down)       docker_compose_down $@ ;    exit 0  ;;
        ls)         docker_compose_ps $@ ;      exit 0  ;;
        logs)       docker_compose_logs $@ ;    exit 0  ;;
        port)       docker_compose_port $@  ;   exit 0  ;;
        *)  echo "需要执行命令，后面加上 --help 查看可执行命令的更多信息" ;  exit 1  ;;
    esac
}

main $@
