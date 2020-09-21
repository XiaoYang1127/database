#!/bin/sh

: <<!
  redis从服配置
!

USER=riak
TOOLS_PATH=/tmp/tools
SRC_PATH=/opt/src
INSTALL_PATH=/opt/redis
PORT=6380
LOGS_NAME=logs
CONF_NAME=conf

install_redis_slave() {
    if [ ! -d $TOOLS_PATH ]; then
        mkdir -p $TOOLS_PATH
    fi

    if [ ! -d $SRC_PATH ]; then
        mkdir -p $SRC_PATH
    fi

    if [ -d $INSTALL_PATH ]; then
        rm -rf $INSTALL_PATH
    fi

    cd $TOOLS_PATH
    url=http://download.redis.io/releases/redis-5.0.5.tar.gz
    #wget $url
    tar_name=${url##*/}
    redis_name=${tar_name%%.tar.gz}

    cd $SRC_PATH
    tar -zxvf $TOOLS_PATH/$tar_name

    cd $SRC_PATH/$redis_name
    make && make install PREFIX=$INSTALL_PATH

    #conf
    cd $INSTALL_PATH
    mkdir $CONF_NAME
    cd $CONF_NAME
    cp $SRC_PATH/$redis_name/redis.conf redis.conf
    cp $SRC_PATH/$redis_name/redis.conf redis_$PORT.conf

    cd $INSTALL_PATH/$CONF_NAME
    cat >>redis_$PORT.conf <<EOF
port $PORT
requirepass 123456
logfile $INSTALL_PATH/$LOGS_NAME/redis-$PORT.log
pidfile $INSTALL_PATH/redis_$PORT.pid
dir $INSTALL_PATH
replicaof 127.0.0.1 6379
replica-read-only yes
masterauth 123456
EOF

    #logs
    cd $INSTALL_PATH
    mkdir $LOGS_NAME

    #shell
    cat >redis.sh <<EOF
#!/bin/sh

REDIS_SERVER=$INSTALL_PATH/bin/redis-server
CONFIG_NAME=$INSTALL_PATH/$CONF_NAME/redis_$PORT.conf
PID_FILE=$INSTALL_PATH/redis_$PORT.pid

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
  echo "Usage: /etc/init.d/subversion (start|stop|restart)"
  exit 1
  ;;

esac
EOF

    chmod +x $INSTALL_PATH/redis.sh
    chown -R $USER:$USER $INSTALL_PATH
}

install_redis_slave
