#!/bin/bash

function docker_save() {
    now_time=$(date "+%Y-%m-%d")
    mkdir ../images_bak_$now_time
    for i in $(grep "image" ecv_stack.yml | awk '{print $2}' | sort -u)
        do
            j=$(echo $i | sed "s/:/_/g;s/\//-/g" )
            # if [ ! -e $j ];then
            docker image save $i > ../images_bak_$(date "+%Y-%m-%d")/$j
            # fi
        done
}

function docker_load() {
    case $1 in
    "")
    for i in $(ls ../images)
        do
            docker image load < ../images/$i
        done
    ;;
    $1)
    for i in $(ls ../$1)
        do
            docker image load < ../$1/$i
        done
    ;;
    esac
}


# function docker_load() {
#     arg=$1
#     if [[ -n $arg ]];then
#     for i in $(ls ../$arg)
#         do
#             echo $arg
#             docker image load < ../$arg/$i
#         done
#     else
#     for i in $(ls ../images)
#         do
#             docker image load < ../images/$i
#         done
#     fi
# }

function show_help() {
cat << EOF
Docker images tool , version: 1.0.0 , build: 2018-06-11 17:38:37

Usage: ./$0 command

commands:

  load [dir_name]	载入上级目录下的images目录内的镜像 [载入制定目录下的镜像]
  save          	将现场目前的镜像导出备份到上级目录下的images-bak目录下

  -h, --help 显示本帮助页面
EOF
}

function main() {
    main_command=$1
    shift
    case $main_command in 
        save)   docker_save         ;   exit 0 ;;
        load)   docker_load "$@"    ;   exit 0 ;;
        *)      show_help           ;   exit 0 ;;
    esac
}

main "$@"
