#!/bin/bash

# docker stack 管理脚本

###################
# variable define #
###################
docker_host_ip="192.168.3.9"
[ -z $docker_host_ip ] && docker_remote_arg="" || docker_remote_arg="-H $docker_host_ip"
docker_stack_compose_dir="compose"
docker_stack_compose_file="ecv_stack_3.9.yml"
docker_stack_name="gx-test"
docker_compose_dir="compose/extra"
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
            # sed -i  "/docker_host_ip/ s/docker_host_ip=/docker_host_ip=$docker_host_ip_new/" $0
            sed -i  "/^docker_host_ip/ c docker_host_ip=\"$docker_host_ip_new\"" $0
        fi
    fi  

    read -p "是否改变集群编排文件所在目录？[y/N]:(默认 N) " cho
    if [ ! -z $cho ] ; then
        if [ $cho = 'y' -o $cho = 'Y' ] ; then
            read -p "输入集群编排文件目录路径： " docker_stack_compose_dir_new
            sed -i  "/^docker_stack_compose_dir/ c docker_stack_compose_dir=\"$docker_stack_compose_dir_new\"" $0
        fi
    fi

    read -p "是否改变集群编排文件名？[y/N]:(默认 N) " cho
    if [ ! -z $cho ] ; then
        if [ $cho = 'y' -o $cho = 'Y' ] ; then
            read -p "输入集群编排文件名： " docker_stack_compose_file_new
            sed -i  "/^docker_stack_compose_file/ c docker_stack_compose_file=\"$docker_stack_compose_file_new\"" $0
        fi
    fi

    read -p "是否改变服务栈名称？[y/N]:(默认 N) " cho
    if [ ! -z $cho ] ; then
        if [ $cho = 'y' -o $cho = 'Y' ] ; then
            read -p "输入服务栈名称： " docker_stack_name_new
            sed -i  "/^docker_stack_name/ c docker_stack_name=\"$docker_stack_name_new\"" $0
        fi
    fi
}


################
# image manage #
################
function docker_image_save() {
    cd $docker_stack_compose_dir
    ./images.sh save
}

function docker_image_load() {
    cd $docker_stack_compose_dir
    ./images.sh load $1
}

################
# docker stack #
################
function docker_stack_port() {
    yml_ports_line=$(sed -n "/ports:/=" $docker_stack_compose_dir/$docker_stack_compose_file.yml)
    yml_ports_value_line=$(($yml_ports_line+1))
    host_port=$(sed -n "${yml_ports_value_line}p" $docker_stack_compose_dir/$docker_stack_compose_file.yml)
    case $1 in
    "")
    current_value=$(echo $host_port | cut -d ":" -f 1 |cut -d "\"" -f 2)
    echo "当前端口为 $current_value，下次执行 $0 up 将使用此端口"
    ;;
    $1)
    original_value=$(echo $host_port | cut -d ":" -f 1 |cut -d "\"" -f 2)
    sed -i "s/$original_value/$1/" $docker_stack_compose_dir/$docker_stack_compose_file &> /dev/null
    [ $? -eq 0 ] && echo "已修改端口为 $1，再次执行 $0 up 生效"
    ;;
    esac
}

function docker_stack_deploy() {
    echo -e "读取部署编排文件 ./$docker_stack_compose_dir/$docker_stack_compose_file \n开始部署服务集群 ... "
    docker $docker_remote_arg stack deploy --compose-file $docker_stack_compose_dir/$docker_stack_compose_file $docker_stack_name --resolve-image=never
    
}

function docker_service_print() {
    declare -A list
    i=0
    echo -e "序号  服务\n----------"
    for docker_service_name in $(docker $docker_remote_arg stack services $docker_stack_name | grep -v NAME |awk '{print $2}' | sort)
        do
            i=$((i+1))
            if [ $i -lt 10 ] ; then
                j=0$i
                echo "$j.   $docker_service_name"
            else
                echo "$i.   $docker_service_name"
            fi
            list[$i]=$docker_service_name
        done
    echo 
}

function docker_service_remove() {
    case $1 in 
    "")
        declare -A list
        i=0
        echo -e "序号  服务\n----------"
        for docker_service_name in $(docker $docker_remote_arg stack services $docker_stack_name | grep -v NAME |awk '{print $2}' | sort)
            do
                i=$((i+1))
                if [ $i -lt 10 ] ; then
                    j=0$i
                    echo "$j.   $docker_service_name"
                else
                    echo "$i.   $docker_service_name"
                fi
                list[$i]=$docker_service_name
            done
        echo 
        read -p "输入待移除服务的序号(不需要输入前面的'0')，按回车执行： " cho
        echo -e "\n开始移除服务..."
        docker $docker_remote_arg service rm "${list[$cho]}" 
    ;;
    -a) 
        read -p "确定移除 $docker_stack_name 服务栈?[y/N]: " cho
        if [ ! -z "$cho" ] ; then
            if [ $cho = 'y' -o $cho = 'Y'  ] ; then
                docker $docker_remote_arg stack rm $docker_stack_name
            fi
        else
            exit 233
        fi        
    ;;
    esac
}

function docker_service_update() {
    docker_service_remove
    docker_stack_deploy
}

function docker_compose_up() {
    docker-compose -f $docker_compose_dir/docker-compose.yml up -d 
}

function docker_compose_down() {
    docker-compose -f $docker_compose_dir/docker-compose.yml down
}

function docker_stack_ps() {
    while true
        do
            clear
            docker $docker_remote_arg stack ps $docker_stack_name
            sleep 2
        done
}

function docker_service_logs() {
    declare -A list
    i=0
    echo -e "序号  服务\n----------"
    for docker_service_name in $(docker $docker_remote_arg stack services $docker_stack_name | grep -v NAME |awk '{print $2}' | sort)
        do
            i=$((i+1))
            if [ $i -lt 10 ] ; then
                j=0$i
                echo "$j.   $docker_service_name"
            else
                echo "$i.   $docker_service_name"
            fi
            list[$i]=$docker_service_name
        done
    echo 
    read -p "输入待查看日志的服务序号(不需要输入前面的'0')： " cho
    read -p "输入要查询多久前到现在日志(单位：分钟)： " time_to_now
    read -p "预览或保存到本地[ 1 预览 | 2 下载 ]： " download_cho
    case $download_cho in 
        1)  docker $docker_remote_arg service logs -f --since ${time_to_now}m ${list[$cho]}    ;;
        2)  
        docker $docker_remote_arg service logs --since ${time_to_now}m ${list[$cho]} &> $(date -d "-${time_to_now}minutes" "+%m-%d_%H.%M.%S")_to_$(date "+%m-%d_%H.%M.%S")_${list[$cho]}.log
        echo "下载完成，保存在./目录下"
        ;;
    esac
        
}

###################
# help entrypoint #
###################
function show_help() {
cat << EOF_help
Docker stack deploy script , version: 1.0.0 , build: 2018-06-12 14:28:56

Usage: $0 Command [arg]
            
Commands:

  init          初始化设置
  save          备份现在的镜像
  load          载入images目录下的镜像
  deploy        按照脚本部署
  rm [-a]       移除服务 [-a 全部]
  update        强制重启服务
  up            部署目标分类服务
  down          移除目标分类服务
  ps            查看各服务状态
  logs          查看服务日志
  port [PORT]   查看端口 [指定端口 示例：$0 port 51000]

  -h, --help    显示此帮助页
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
        init)       script_init $@ ;            exit 0  ;;
        save)       docker_image_save ;         exit 0  ;;
        load)       docker_image_load $@ ;      exit 0  ;;
        deploy)     docker_stack_deploy  ;      exit 0  ;;
        rm)         docker_service_remove $@;   exit 0  ;;
        update)     docker_service_update $@;   exit 0  ;;
        up)         docker_compose_up   ;       exit 0  ;;
        down)       docker_compose_down ;       exit 0  ;;
        ps)         docker_stack_ps $@ ;        exit 0  ;;
        logs)       docker_service_logs ;       exit 0  ;;
        port)       docker_stack_port $@  ;     exit 0  ;;
        *)  echo "需要执行命令，后面加上 --help 查看可执行命令的更多信息" ;  exit 0  ;;
    esac
}

main $@
