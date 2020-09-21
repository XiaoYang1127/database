# 慢查询

## 1. 参数讲解

### show variables like 'slow_query%'

- 查询状态

### slow_query_log

- on 代表开启
- off 代表关闭

### slow_query_log_file

- 慢查询日志位置

### long_query_time

- 查询超过多少毫秒才记录

### log_queries_not_using_indexes

- 未使用索引的查询也被记录到慢查询日志中

### show global status like '%slow_queries%'

- 查询有多少条慢查询记录

### log_slow_admin_statements

- 是否将慢管理语句例如 ANALYZE TABLE 和 ALTER TABLE 等记入慢查询日志

## 2. 分析工具

### 得到返回记录集最多的 10 个 SQL。

- mysqldumpslow -s r -t 10 /database/mysql/mysql06_slow.log

### 得到访问次数最多的 10 个 SQL

- mysqldumpslow -s c -t 10 /database/mysql/mysql06_slow.log

### 得到按照时间排序的前 10 条里面含有左连接的查询语句。

- mysqldumpslow -s t -t 10 -g “left join” /database/mysql/mysql06_slow.log

### 建议在使用这些命令时结合 | 和 more 使用 ，否则有可能出现刷屏的情况

- mysqldumpslow -s r -t 20 /mysqldata/mysql/mysql06-slow.log | more
