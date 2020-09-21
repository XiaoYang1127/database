#!/bin/sh

: <<!
  redis-cluster配置
!

USER=riak
TOOLS_PATH=/tmp/tools
SRC_PATH=/opt/src
BASE_PATH=/opt/redis-cluster
CLUSTER_NUM=8

install_redis_cluster() {
    if [ ! -d $TOOLS_PATH ]; then
        mkdir -p $TOOLS_PATH
    fi

    if [ ! -d $SRC_PATH ]; then
        mkdir -p $SRC_PATH
    fi

    if [ -d $BASE_PATH ]; then
        rm -rf $BASE_PATH
    fi

    cd $TOOLS_PATH
    url=http://download.redis.io/releases/redis-5.0.5.tar.gz
    #wget $url
    tar_name=${url##*/}
    redis_name=${tar_name%%.tar.gz}

    if [ -d $SRC_PATH/$redis_name ]; then
        rm -rf $SRC_PATH/$redis_name
    fi
    cd $SRC_PATH
    tar -zxvf $TOOLS_PATH/$tar_name

    for i in $(seq 1 $CLUSTER_NUM); do
        port=700$i
        install_path=$BASE_PATH/redis_0$i
        if [ ! -d $install_path ]; then
            mkdir -p $install_path
        fi

        cd $SRC_PATH/$redis_name
        make && make install PREFIX=$install_path

        #conf
        cd $install_path
        if [ $i -le $CLUSTER_NUM ]; then
            cat >redis_$port.conf <<EOF
port $port
cluster-enabled yes
cluster-config-file nodes_$port.conf
cluster-node-timeout 15000
appendonly yes

requirepass 123456
logfile $install_path/redis_$port.log
pidfile $install_path/redis_$port.pid
dir $install_path

replica-read-only yes
masterauth 123456
EOF
        else
            master_port=$(expr $port - 3)
            cat >redis_$port.conf <<EOF
port $port
requirepass 123456
logfile $install_path/redis_$port.log
pidfile $install_path/redis_$port.pid
dir $install_path
replicaof 127.0.0.1 $master_port
replica-read-only yes
masterauth 123456
EOF
        fi

        #shell
        cat >redis0$i.sh <<EOF
#!/bin/sh

REDIS_SERVER=$install_path/bin/redis-server
CONFIG_NAME=$install_path/redis_$port.conf
PID_FILE=$install_path/redis_$port.pid

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
        chmod +x redis0$i.sh
    done

    #make start shelL
    cd $BASE_PATH
    cat >redis.sh <<EOF
#!/bin/sh

if [ \$# -ne 1 ]; then
    echo "please input start or stop"
    exit
fi

sh $BASE_PATH/redis_01/redis01.sh \$1
sh $BASE_PATH/redis_02/redis02.sh \$1
sh $BASE_PATH/redis_03/redis03.sh \$1
sh $BASE_PATH/redis_04/redis04.sh \$1
sh $BASE_PATH/redis_05/redis05.sh \$1
sh $BASE_PATH/redis_06/redis06.sh \$1
EOF
    chmod +x redis.sh
    chown -R $USER:$USER $BASE_PATH

    #make cluster shell
    cd $BASE_PATH
    cat >redis_cluster.sh <<EOF
#!/bin/sh

EXEC=$SRC_PATH/$redis_name/src/redis-cli
\$EXEC -a 123456 --cluster create 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 127.0.0.1:7006 --cluster-replicas 1
EOF
    chmod +x redis_cluster.sh
}

install_redis_cluster
