# redis 安装与运行

## 安装

- wget http://download.redis.io/releases/redis-3.2.8.tar.gz
- tar xzf redis-3.2.8.tar.gz
- cd redis-3.2.8
- make && make install
- cd utils && ./install_server.sh

## 安装目录

- redis 安装在/usr/local/bin/目录
- redis-benchmark: ==> 性能测试工具
- redis-check-aof: ==> AOF 文件修复工具
- redis-check-dump: => RDB 文件检查工具
- redis-cli: ==> 命令行客户端
- redis-sentinel: => 帮助管理 redis 实例的工具
- redis-server: ==> redis 服务器

## 启动服务器

- redis-server 默认端口 6379
- redis-server --port 端口号
- redis-server /path/to/redis.conf 启动时的配置文件将覆盖系统同名配置项
