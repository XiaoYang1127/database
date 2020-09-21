# redis 常用指令

## 1. 清空

### 清空某个数据库的所有 key

- select #{db_num}
- flushdb

### 清空整个数据库的 key

- flushall

## 2. 查看 key

### 查看 key 过期时间

- ttl key_name
- 当 key 不存在时，返回-2
- 当 key 存在但没有设置剩余生存时间时，返回-1
- 否则，以秒为单位，返回 key 的剩余生存时间

### object 命令

- object refcount key: 返回给定 key 引用所储存的值的次数
- object encoding key: 返回给定 key 锁储存的值所使用的内部表示
- object idletime key: 返回给定 key 自储存以来的空转时间，没有被读取也没有被写入，以秒为单位
