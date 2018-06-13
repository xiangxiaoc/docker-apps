#!/bin/bash
# docker-compose 管理脚本

##########################
# global variable define #
##########################
docker_compose_file="portainer/docker-compose.yml"
[ -z $docker_compose_file ] && docker_compose_file_arg="" || docker_compose_file_arg="-f $docker_compose_file"

string_placeholders="#####"

##################
# Initialization #
##################
function script_init() {
cat << EOF_init
$string_placeholders docker-compose 部署脚本 $string_placeholders

初始化设置 ...

EOF_init

    

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

echo -e "初始化完成，即将通过，请运行 $0 其他命令"

}



###########################
# image manage entrypoint #
###########################
function docker_image_save() {
    now_time=$(date "+%Y-%m-%d_%H")
    mkdir ./images_bak_$now_time
    for i in $(grep "image:" $docker_compose_file | sed 's/#//' |  awk '{print $2}' | sort -u)
        do
            j=$(echo $i | sed "s/:/_/g;s/\//-/g" )
            docker image save $i > ./images_bak_$now_time/$j
        done
}

function docker_image_load() {
    case $1 in
    "")
    for i in $(ls ./images)
        do
            docker image load < ../images/$i
        done
    ;;
    $1)
    for i in $(ls ./$1)
        do
            docker image load < ../$1/$i
        done
    ;;
    esac
}

##################
# docker-compose #
##################
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
    docker-compose $docker_compose_file_arg up --no-start
}

function docker_compose_start() {
    docker-compose $docker_compose_file_arg start
}

function docker_compose_restart() {
    case $1 in
    "")
    declare -A list
    i=0
    for docker_service_name in $(docker_compose_ps --services)
        do
            i=$((i+1))
            echo "$i. $docker_service_name"
            list[$i]=$docker_service_name
        done
    read -p "输入待重启服务的序号： " j
    docker-compose $docker_compose_file_arg restart "${list[$j]}" 
    ;;
    -a) docker-compose $docker_compose_file_arg restart    ;;
    esac
}

function docker_compose_stop() {
    case $1 in
    "")
    declare -A list
    i=0
    for docker_service_name in $(docker_compose_ps --services)
        do
            i=$((i+1))
            echo "$i. $docker_service_name"
            list[$i]=$docker_service_name
        done
    read -p "输入待停止服务的序号： " j
    docker-compose $docker_compose_file_arg restart "${list[$j]}" 
    ;;
    -a)  docker-compose $docker_compose_file_arg stop  ;;
    esac
}

function docker_compose_down() {
    docker-compose $docker_compose_file_arg down
}

function docker_compose_ps() {
    while true
        do
            clear
            docker-compose $docker_compose_file_arg ps $@
            sleep 1
        done
}

function docker_compose_logs() {
    case $1 in
    "") 
        declare -A list
        i=0
        echo -e "序号  服务\n----------"
        for docker_service_name in $(docker_compose_ps --services)
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
        read -p "输入待查看日志的服务序号： " cho
        read -p "查看最近多少条日志？(默认：全部)： " tail
        [ -z $tail ] && tail_arg="--tail all" || tail_arg="--tail $tail"
        read -p "查看或导出  [ 1 查看 | 2 导出 ]： " download_cho
        case $download_cho in 
            1)  
                docker-compose $docker_compose_file_arg logs -f $tail_arg ${list[$cho]}    
            ;;
            2)  
                docker-compose $docker_compose_file_arg logs --no-color $tail_arg ${list[$cho]} &> ${list[$cho]}_$tail.log
                echo "导出完成，保存为./${list[$cho]}_$tail.log"
            ;;
        esac
    ;;
    -a) 
        read -p "查看最近多少条日志？(默认：全部)： " tail
        [ -z $tail ] && tail_arg="--tail all" || tail_arg="--tail $tail"
        docker-compose $docker_compose_file_arg logs -f $tail_arg   ;;
    esac
}

###################
# help entrypoint #
###################
function show_help() {
cat << EOF_help
Docker-Compose deploy script , Version: 1.0.4 , build: 2018-06-13 19:26:59

Usage: $0 Command [arg]
            
Commands:

  init              脚本初始化
  save              备份现在的镜像
  load [dir_name]   载入images目录下的镜像 [指定目录]
  port [PORT]       查看端口 [指定端口 示例：$0 port 51000]
  up                创建容器
  start             启动服务
  restart [-a]      重启服务 [-a 全部]
  stop [-a]         停止服务 [-a 全部]
  down              停止并移除全部容器
  ps                查看服务状态
  logs [-a]         查看服务日志 [-a 全部]

  -h, --help        显示此帮助页
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
        up)         docker_compose_up ;         exit 0  ;;
        start)      docker_compose_start ;      exit 0  ;;
        restart)    docker_compose_restart $@;  exit 0  ;;
        stop)       docker_compose_stop $@ ;    exit 0  ;;
        down)       docker_compose_down ;       exit 0  ;;
        ps)         docker_compose_ps $@ ;      exit 0  ;;
        logs)       docker_compose_logs $@ ;    exit 0  ;;
        port)       docker_compose_port $@  ;   exit 0  ;;
        *)  echo "需要执行命令，后面加上 --help 查看可执行命令的更多信息" ;  exit 0  ;;
    esac
}

main $@
