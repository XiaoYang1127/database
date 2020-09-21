# mysql bin-log

## 1. 介绍

- 它记录了数据库上的所有改变，并以二进制的形式保存在磁盘中
- 它可以用来查看数据库的变更历史、数据库增量备份和恢复、Mysql 的复制（主从数据库的复制）。
- 语句以事件的形式保存，它描述数据更改。
- 因为有了数据更新的 binlog，所以可以用于实时备份，与 master/slave 复制，高可用与数据恢复。
- 恢复使能够最大可能地更新数据库，因为二进制日志包含备份后进行的所有更新。
- 在主复制服务器上记录所有将发送给从服务器的语句
- 逻辑日志，是逻辑操作
- binlog 是 MySQL Server 层记录的日志
- 缺点是难以并行
- 选择 binlog 日志作为 replication

## 2. 格式

### Statement

- 基于 SQL 语句的复制
- statement-based replication，SBR

### Row

- 基于行的复制
- row-based replication，RBR

### Mixed

- 混合模式复制
- mixed-based replication，MBR

## 3. 配置

### binlog_format

- 格式类型

### log_bin

- 是否开启

### log_bin_index

- 路径和名称

### binlog_row_image

- 控制二进制日志记录内容
- binlog 格式必须为 row 格式或者 mixed 格式，不可以是 statement 格式
- before image：前镜像，即数据库表中修改前的内容。
- after image：后镜像，即数据库表中修改后的内容
- 1. full: binlog 日志记录所有前镜像和后镜像
- 2. minimal: binlog 日志的前镜像只记录唯一识别列(唯一索引列、主键列)，后镜像只记录修改列
- 3. noblob: binlog 记录所有的列，就像 full 格式一样,记录所有的列值，但是 BLOB 与 TEXT 列除外

### binlog_do_db

- 记录指定的数据库

### binlog_ignore_db

- 不记录指定的数据库的二进制日志

### max_binlog_cache_size

- binlog 使用的内存最大尺寸

### binlog_cache_size

- binlog 使用的内存大小

### binlog_cache_use

- 使用二进制日志缓存的事务数量

### binlog_cache_disk_use

- 使用二进制日志缓存但超过 binlog_cache_size 值并使用临时文件来保存事务中的语句的事务数量

### max_binlog_size

- Binlog 最大值，最大和默认值是 1GB
- 当 Binlog 比较靠近最大值，为了保证事务的完整性，不能做切换日志的动作，只能将该事务的所有 SQL 都记录进当前日志，直到事务结束

### sync_binlog

- 这个参数直接影响 mysql 的性能和完整性

```
1. sync_binlog=0
  当事务提交后，Mysql仅仅是将binlog_cache中的数据写入Binlog文件，但不执行fsync之类的磁盘
  同步指令通知文件系统将缓存刷新到磁盘，而让Filesystem自行决定什么时候来做同步
  但是，一旦系统绷Crash，在文件系统缓存中的所有Binlog信息都会丢失
  这个是性能最好的

2. sync_binlog=n
  在进行n次事务提交以后，Mysql将执行一次fsync之类的磁盘同步指令，同志文件系统将Binlog文件缓存刷新到磁盘。
```

## 4. 推荐配置

- N=1,1 适合数据安全性要求非常高，而且磁盘 IO 写能力足够支持业务，比如充值消费系统
- N=1,0 适合数据安全性要求高，磁盘 IO 写能力支持业务不富余，允许备库落后或无复制
- N=2,0 或 2,m 适合数据安全性有要求，允许丢失一点事务日志，复制架构的延迟也能接受
- N=0,0 磁盘 IO 写能力有限，无复制或允许复制延迟稍微长点能接受，例如：日志性登记业务
