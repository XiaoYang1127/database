#!/bin/bash
: <<!
  1. 编译数据库（依赖于/tools/mysql-5.1.56-i486-1.zip中的/usr/include的头文件）
  2. libmysqlclient.so.20.3.4 -> libmysqlclient_r.a
  3. zlib.h: No such file or directory
    apt-get install zlib1g-dev

Q1: error while loading shared libraries: libpython2.7.so.1.0: cannot open shared object file: No such file or directory
  sudo cp libpython2.7.so.1.0 /usr/local/lib/libpython2.7.so.1.0
  sudo ldconfig -v
!

compile_pd() {
    ln -s /usr/local/mysql/lib/libmysqlclient.so.20 /usr/local/lib/libmysqlclient.so.20

    cd /etc
    cat >ld.so.conf <<EOF
    /usr/local/lib
EOF

    ldconfig -v
}
