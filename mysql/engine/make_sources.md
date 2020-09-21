# 源码编译

## 参考

- https://dev.mysql.com/doc/internals/en/cmake.html

## 源码阅读

```
1. 对于服务器启动初始化过程，包括参数及参数文件的处理，服务器线程初始化等等，都是从sql目录下的mysqld.cc里面
的mysqld_main函数开始的

2. 对于客户端请求的处理，mysql是相对比较复杂的，首先，确定好是想要学习哪个部分，是mysql的网络协议还是
具体命令的执行代码

3. mysql网络协议，对于mysql的客户端与服务端交流感兴趣的，可以从sql目录的net_serv.cc看起，里面包含了
mysql服务器对网络通信的基本封装

4. mysql命令执行，客户端请求会被mysqld.cc的do_handle_one_connection函数捕获，然后创建新线程来处理发
送过来的命令，处理函数是sql_parse.cc 里面的do_command函数，do_command函数对客户端发送过来的进行一些通用
处理后，调用该文件里面的dispatch_command函数处理请求。dispatch_command函数是所有客户端命令处理的集散地，
700行代码，对所有命令的代码实现，都可以从这里入手
```
