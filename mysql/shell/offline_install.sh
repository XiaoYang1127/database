#!/bin/bash

: <<!
修改密码
  1. /etc/my.conf增加skip-grant-tables
  2. 重启mysql
  3. mysql -uroot -p进入界面
  4. update user set authentication_string=password('123456') where user = 'root'；
  5. flush privileges;
  6. 注释1中的那一行，重启mysql
  7. 报错：ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement
    alter user 'root'@'localhost' identified by '123456';
!

TOOLS_PATH=/tmp/tools
INSTALL_PATH=/usr/local
LOG_PATH=/var/log/mysql

install_mysql() {
    if [ ! -d $TOOLS_PATH ]; then
        mkdir $TOOLS_PATH
    fi

    #cd TOOLS_PATH
    #wget http://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz

    cd $INSTALL_PATH
    rm -rf $INSTALL_PATH/mysql*
    tar -zxvf $TOOLS_PATH/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
    ln -s $INSTALL_PATH/mysql-5.7.17-linux-glibc2.5-x86_64 $INSTALL_PATH/mysql

    #dependency
    apt-get install libaio-dev

    groupadd mysql
    useradd -r -g mysql mysql
    cd $INSTALL_PATH/mysql
    mkdir data
    chown -R mysql:mysql $INSTALL_PATH/mysql
    chmod -R 777 $INSTALL_PATH/mysql/data

    if [ ! -d $LOG_PATH ]; then
        mkdir $LOG_PATH
    fi

    cd /etc
    cat >my.cnf <<EOF
[client]
port = 3306
socket = /tmp/mysql.sock

[mysqld]
user = mysql
socket = /tmp/mysql.sock

basedir = $INSTALL_PATH/mysql
datadir = $INSTALL_PATH/mysql/data
pid-file = $LOG_PATH/mysqld.pid
log-error = $LOG_PATH/mysql-error.log
EOF

    rm -rf /etc/mysql
    sudo cp -a $INSTALL_PATH/mysql/support-files/mysql.server /etc/init.d/mysqld

    rm -rf $INSTALL_PATH/mysql/data
    cd $INSTALL_PATH/mysql/bin
    ./mysqld --no-defaults --initialize --basedir=$INSTALL_PATH/mysql --datadir=$INSTALL_PATH/mysql/data
    #./mysqld --no-defaults --initialize --basedir=/usr/local/mysql/ --datadir=/usr/local/mysql/data/ --pid-file=/var/log/mysql/mysqld.pid
}

install_mysql
