#!/bin/sh

USER=web
TOOLS_PATH=/tmp/tools/redis
SRC_PATH=/opt/src

install_redis() {
    if [ ! -d $TOOLS_PATH ]; then
        sudo mkdir -p $TOOLS_PATH
    fi

    if [ ! -d $SRC_PATH ]; then
        sudo mkdir -p $SRC_PATH
    fi

    cd $TOOLS_PATH
    url=http://download.redis.io/releases/redis-5.0.6.tar.gz
    wget $url
    tar_name=${url##*/}
    redis_name=${tar_name%%.tar.gz}

    cd $SRC_PATH
    sudo tar -zxvf $TOOLS_PATH/$tar_name

    cd $SRC_PATH/$redis_name
    sudo make && make install

    cd $SRC_PATH/$redis_name/utils
    sudo ./install_server.sh

    chown -R $USER:$USER /etc/redis
    chown -R $USER:$USER /var/log/redis
    chown -R $USER:$USER /var/lib/redis
}
