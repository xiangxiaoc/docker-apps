#!/bin/bash

[ $UID -ne 0 ] && echo "Only for root" && exit 0

APT_SOURCE_PATH="/etc/apt/sources.list"

function change_apt_source_to_aliyun() {
    if grep "Modified by script" $APT_SOURCE_PATH &>/dev/null; then
        echo "Modified"
    else
        cp -a $APT_SOURCE_PATH{,.origin}
        cat >$APT_SOURCE_PATH <<EOF_file_content
## Modified by script at $(date +'%Y-%m-%d %H:%M:%S %Z')
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
# deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
# deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
# deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
# deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
EOF_file_content
    fi
}

function change_apt_source_back() {
    [ ! -f $APT_SOURCE_PATH.origin ] && echo "/etc/apt/source.list.origin is missing" && return 1
    cp -a $APT_SOURCE_PATH.origin $APT_SOURCE_PATH
}

case $1 in
"")
    change_apt_source_to_aliyun

    ;;
disable)
    change_apt_source_back
    ;;
*)
    echo "default"
    ;;
esac

echo "have a try to run 'apt update'"
