#!/bin/bash
<<!
    1、数据库目录
    /var/lib/mysql/

    2、配置文件
    /usr/share/mysql（mysql.server命令及配置文件）

    3、相关命令
    /usr/bin(mysqladmin mysqldump等命令)

    4、启动脚本
    /etc/rc.d/init.d/（启动脚本文件mysql的目录）

    5. 修改密码
    /usr/bin/mysqladmin -u root password 'new-password'
!

install_mysql() {
    sudo apt-get install mysql-server
    sudo apt-get install mysql-client
}
