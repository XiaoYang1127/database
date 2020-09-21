#!/bin/sh

USER=python
TOOL_PATH=/python_project
INSTALL_PATH=/opt/redis5.0.6
SRC_PATH=/opt/src
PORT=6397

install_redis() {
    if [ ! -d $TOOL_PATH ]; then
        sudo mkdir -p $TOOL_PATH
    fi

    if [ ! -d $INSTALL_PATH ]; then
        sudo mkdir -p $INSTALL_PATH
    fi

    if [ ! -d $SRC_PATH ]; then
        sudo mkdir -p $SRC_PATH
    fi

    sudo chown -R $USER:$USER $INSTALL_PATH
    sudo chown -R $USER:$USER $SRC_PATH

    cd $TOOL_PATH
    url=http://download.redis.io/releases/redis-5.0.6.tar.gz
    #wget $url
    #tar_name=${url##*/}
    #redis_name=${url%%.tar.gz}
    tar_name=redis-5.0.6.tar.gz
    redis_name=redis-5.0.6

    cd $SRC_PATH
    sudo tar -zxvf $TOOL_PATH/$tar_name
    cd $SRC_PATH/$redis_name
    sudo make PREFIX=$INSTALL_PATH install

    #conf
    cd $INSTALL_PATH
    if [ ! -d data ]; then
        sudo mkdir conf
    fi
    cd $conf
    sudo cp $SRC_PATH/$redis_name/redis.conf redis.conf
    sudo cp $SRC_PATH/$redis_name/redis.conf redis_$PORT.conf

    #log
    cd $INSTALL_PATH
    if [ ! -d log ]; then
        sudo mkdir log
    fi

    #data
    cd $INSTALL_PATH
    if [ ! -d data ]; then
        sudo mkdir data
    fi

    cd $INSTALL_PATH/conf
    cat >>redis_$PORT.conf <<EOF
port $PORT
aemonize yes
appendonly yes
requirepass 123456
logfile $INSTALL_PATH/log/redis_$PORT.log
pidfile $INSTALL_PATH/log/redis_$PORT.pid
dir $INSTALL_PATH/data
EOF
}

mk_shell() {
    cd $INSTALL_PATH
    cat >redis.sh <<EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides: lsb-ourdb
# Required-Start: $local_fs $network $remote_fs
# Required-Stop: $local_fs $network $remote_fs
# Default-Start:  2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: start and stop OurDB
# Description: OurDB is a very fast and reliable database
#    engine used for illustrating init scripts
### END INIT INFO

REDIS_SERVER=$INSTALL_PATH/bin/redis-server
CONFIG_NAME=$INSTALL_PATH/conf/redis_$PORT.conf
PID_FILE=$INSTALL_PATH/log/redis_$PORT.pid

case "\$1" in
 start)
  echo -n "Starting redis-server:\n"
  \$REDIS_SERVER \$CONFIG_NAME &
  ;;

 stop)
  echo -n "Stopping redis-server:\n"
  PID=\$(cat \$PID_FILE)
  kill -9 \$PID
  ;;

 restart)
  stop
  start
  ;;

 *)
  echo "Usage: /etc/init.d/redis.sh (start|stop|restart)"
  exit 1
  ;;

esac
EOF
    chmod +x redis.sh
}

install_redis
mk_shell
