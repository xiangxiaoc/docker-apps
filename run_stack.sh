#!/bin/bash
# docker stack 管理脚本

##########################
# global variable define #
##########################
docker_host_ip=""
[ -z $docker_host_ip ] && docker_remote_arg="" || docker_remote_arg="-H ${docker_host_ip}:2375"
[ -z $docker_host_ip ] && DOCKER_HOST="本机" || DOCKER_HOST="${docker_host_ip}:2375"
# docker_stack_compose_dir=""
docker_stack_compose_file="registry/swarm.yml"
[ -f $docker_stack_compose_file ] && DOCKER_COMPOSE_FILE="$docker_stack_compose_file" || DOCKER_COMPOSE_FILE="$docker_stack_compose_file (不存在)"
docker_stack_name="registry"

string_placeholders="#####"

##################
# Initialization #
##################
function script_init() {
cat << EOF_init
$string_placeholders 集群部署脚本 $string_placeholders

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
            read -p "输入集群编排文件名： " docker_stack_compose_file_new
            sed -i  "/^docker_stack_compose_file/ c docker_stack_compose_file=\"$docker_stack_compose_file_new\"" $0
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

echo -e "初始化完成，即将根据 $([ -z $docker_stack_compose_file_new ] && echo $docker_stack_compose_file || echo $docker_stack_compose_file_new) 管理 $([ -z $docker_host_ip_new ] && echo $docker_host_ip || echo $docker_host_ip_new) $([ -z $docker_stack_name_new ] && echo $docker_stack_name || echo $docker_stack_name_new) 服务栈，请运行 $0 其他命令"

}


###########################
# image manage entrypoint #
###########################
function docker_image_save() {
    now_time=$(date "+%Y-%m-%d_%H")
    mkdir ./images_bak_$now_time
    for i in $(grep "image:" $docker_stack_compose_file | sed 's/#//' |  awk '{print $2}' | sort -u)
        do
            j=$(echo $i | sed "s/:/_/g;s/\//-/g" )
            docker $docker_remote_arg image save $i > ./images_bak_$now_time/$j
        done
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

###########################
# docker stack entrypoint #
###########################
function docker_stack_port() {
    yml_ports_line=$(sed -n "1,/ports:/=" $docker_stack_compose_file | sed -n '$ p' )
    yml_ports_value_line=$(($yml_ports_line+1))
    host_port=$(sed -n "${yml_ports_value_line}p" $docker_stack_compose_file)
    case $1 in
    "")
    current_value=$(echo $host_port | cut -d ":" -f 1 |cut -d "\"" -f 2)
    echo "当前端口为 $current_value，下次执行 $0 deploy 将使用此端口"
    ;;
    $1)
    original_value=$(echo $host_port | cut -d ":" -f 1 |cut -d "\"" -f 2)
    sed -i "$yml_ports_value_line s/$original_value/$1/" $docker_stack_compose_file &> /dev/null
    [ $? -eq 0 ] && echo "已修改端口为 $1，再次执行 $0 deploy 生效"
    ;;
    esac
}

function docker_stack_deploy() {
    echo -e "读取部署编排文件 ./$docker_stack_compose_file \n开始部署服务集群 ... "
    docker $docker_remote_arg stack deploy --compose-file $docker_stack_compose_file $docker_stack_name --resolve-image=never
    
}

function docker_stack_services() {
    watch -n 1 \
    docker $docker_remote_arg stack services $docker_stack_name $@
}

#############################
# docker service entrypoint #
#############################
function docker_service_choose() {
    declare -A list
    i=0
    echo -e "序号  服务\n----------"
    for docker_service_name in $(docker $docker_remote_arg stack services $docker_stack_name | grep -v NAME |awk '{print $2}' | sort -n)
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

function docker_service_ps() {
    case $1 in
        "")
            docker_service_choose
            watch -n 1 \
            docker $docker_remote_arg service ps --no-trunc $docker_service_choice
        ;;
        "-a")
            watch -n 1 \
            docker $docker_remote_arg stack ps --no-trunc $docker_stack_name
        ;;
    esac
}

function docker_service_remove() {
    case $1 in 
    "")
        docker_service_choose
        echo -e "\n开始移除服务..."
        docker $docker_remote_arg service rm $docker_service_choice 
    ;;
    -a) 
        read -p "确定移除 $docker_stack_name 服务栈?[y/N]: " cho
        if [ ! -z "$cho" ] ; then
            if [ $cho = 'y' -o $cho = 'Y'  ] ; then
                echo -e "\n开始移除服务..."
                docker $docker_remote_arg stack rm $docker_stack_name
            else 
                exit 0
            fi
        else
            exit 233
        fi        
    ;;
    esac
    echo "等待 docker 清理服务关联的容器"
    i=0
    printf "[  "
    until [ $i -eq 50 ]
        do
            sleep 0.1
            printf "\b"
            printf "="
            printf ">"
            i=$(($i+1))
        done
    echo " ]"
    echo "移除完成"
}

function docker_service_update() {
    docker_service_choose
    echo -e "开始更新服务...\n"
    docker $docker_remote_arg service update --force $docker_service_choice $@
}

function docker_service_logs() {
    docker_service_choose
    read -p "要查询多久前到现在日志？  (单位：分钟 默认：全部日志)： " time_to_now
    [ -z $time_to_now ] && since_arg="" || since_arg="--since ${time_to_now}m"
    echo
    read -p "打印预览或下载到当前目录？  [ 1 预览 | 2 下载 ]（默认：1 预览）： " download_cho
    [ -z $download_cho ] && download_cho="1" || download_cho=$download_cho
    echo
    case $download_cho in 
        1)  
            docker $docker_remote_arg service logs -f $since_arg $docker_service_choice
        ;;
        2)  
            docker $docker_remote_arg service logs $since_arg $docker_service_choice &> ${docker_service_choice}_$([ -z ${time_to_now} ] && echo "" || echo $(date -d "-${time_to_now}minutes" "+%m月%d日_%H时%M分%S秒"))至$(date "+%H时%M分%S秒").log
            echo "下载完成"
        ;;
    esac
}
############################
# docker config entrypoint #
############################
function docker_config() {
    docker $docker_remote_arg config $@
}

###################
# help entrypoint #
###################
function show_help() {
cat << EOF_help
Docker stack deploy script , version: 1.3.4 , build: 2018-09-17 16:46:32

Usage: $0 Command [arg]
            
Commands:

  init              脚本初始化
  save              备份当前编排文件里面用到的镜像
  load [dir_name]   载入 ./images 目录下的镜像 [指定目录]
  port [PORT]       查看对外暴露端口 [指定对外暴露端口 示例：$0 port 51000]  
  config            配置管理
  deploy            部署或更新服务栈
  ls                查看各服务概况
  ps [-a]           查看各服务任务状态 [-a 全部服务任务状态]
  rm [-a]           移除中的服务 [-a 全部]
  restart           强制重启服务
  logs              查看服务日志

  -h, --help        显示此帮助页

# 以下是目标 Docker 主机地址和正在使用的编排文件，如需变更执行 $0 init 进行初始化
Docker Daemon: $DOCKER_HOST
Compose File: $DOCKER_COMPOSE_FILE
Swarm Stack Name: $docker_stack_name

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
        save)       docker_image_save ;         exit 0  ;;
        load)       docker_image_load $@ ;      exit 0  ;;
        port)       docker_stack_port $@  ;     exit 0  ;;
        config)     docker_config $@     ;      exit 0  ;;        
        deploy)     docker_stack_deploy  ;      exit 0  ;;
        ls)         docker_stack_services $@ ;  exit 0  ;;
        ps)         docker_service_ps $@ ;      exit 0  ;;
        rm)         docker_service_remove $@;   exit 0  ;;
        restart)     docker_service_update $@;  exit 0  ;;
        logs)       docker_service_logs ;       exit 0  ;;
        *)  echo "需要执行命令，后面加上 --help 查看可执行命令的更多信息" ;  exit 0  ;;
    esac
}

main $@
