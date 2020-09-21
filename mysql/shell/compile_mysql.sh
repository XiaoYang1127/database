#!/bin/bash

USER_NAME=riak
TOOLS_PATH=/tmp/tools
SRC_PATH=/home/$USER_NAME/sources
#http://ftp.gnu.org/gnu/bison/  【2.4.1】
#https://www.boost.org/users/history/ 【1.59.0】

compile_mysql() {
    if [ ! -d $TOOLS_PATH ]; then
        mkdir $TOOLS_PATH
    fi

    if [ ! -d $SRC_PATH ]; then
        mkdir $SRC_PATH
    fi

    cd $TOOLS_PATH
    wget http://ftp.gnu.org/gnu/bison/bison-2.4.1.tar.gz
    wget https://nchc.dl.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz

    #install dependency
    sudo apt-get install libbz2-dev
    sudo apt-get install python-dev
}

compile_mysql
