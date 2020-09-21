# mysql 运行的配置

## 1. back_log

```
1. 在MySQL暂时停止回答新请求之前的短时间内多少个请求可以被存在堆栈中

2. 如果MySql的连接数据达到max_connections时，新来的请求将会被存在堆栈中，以等待某一连接释放资源，
  该堆栈的数量即back_log，如果等待连接的数量超过back_log，将不被授予连接资源。
  将会报：unauthenticated user | xxx.xxx.xxx.xxx | NULL | Connect | NULL | login | NULL 的待连接进程时

3. back_log值不能超过TCP/IP连接的侦听队列的大小。若超过则无效，查看当前系统的TCP/IP连接的侦听队列的
  大小命令：cat /proc/sys/net/ipv4/tcp_max_syn_backlog目前系统为1024。对于Linux系统推荐设置为小于512的整数
```

## 2. 线程缓存

### thread_cache_size

- 可以重新利用保存在缓存中线程的数量

### Threads_cached

- 当前被缓存的空闲线程的数量

### Threads_connected

- 正在处于连接状态的线程数量

### Threads_created

- 服务启动以来，创建了多少个线程

### Threads_running

- 正在忙的线程（正在查询数据，传输数据等等操作）

## 3. 连接

### max_user_connections

- 每个数据库用户的最大连接， 同一个账号能够同时连接到 mysql 服务的最大连接数。设置为 0 表示不限制

### Connections

- 服务启动以来，历史连接数

### max_connections

- 服务器最大连接数，因为如果连接数越多，介于 MySql 会为每个连接提供连接缓冲区，就会开销越多的内存，
  所以要适当调整该值，不能盲目提高设值

### Max_used_connections

- 服务器过去的最大连接数
- 连接线程池的命中率来判断设置值是否合适？命中率超过 90%以上
- (Connections _ Threads_created) / Connections _ 100

## 4. 表缓存

### table_open_cache

- 指定表高速缓存的大小
- 每当 MySQL 访问一个表时，如果在表缓冲区中还有空间，该表就被打开并放入其中，这样可以更快地访问表内容

### open_tables

- 当前打开的表缓存数
- 如果执行 flush tables 操作，则此系统会关闭一些当前没有使用的表缓存而使得此状态值减小

### opend_tables

- 曾经打开的表缓存数，会一直进行累加
- 执行 flush tables 操作，值不会减小
- 如发现 open_tables 等于 table_open_cache，并且 opened_tables 在不断增长，那么需要增加 table_cache 的值

## 5. 临时表，文件

### Created_tmp_tables

- 创建临时表的计数
- 每次创建临时表，此计数增加

### Created_tmp_disk_tables

- 磁盘上创建临时表的计数
- 如临时表大小超过 tmp_table_size，则此计数增加

### Created_tmp_files

- 磁盘上创建临时文件的计数

### tmp_table_size

- 控制内存临时表的最大值，超过限值后，往硬盘写(copying on tmp table [on disk])

### max_heap_table_size

- 用户可以创建的内存表(memory table)的大小, 用来计算内存表的最大行数值
- 理想的配置： Created_tmp_disk_tables / Created_tmp_tables \* 100% <= 25%
- 默认为 16M，可调到 64-256 最佳，线程独占，太大可能内存不够 I/O 堵塞

## 6. 表读取缓存优化

### read_buffer_size

- 是 MySQL 读入缓冲区的大小
- 对表进行顺序扫描的请求将分配一个读入缓冲区，MySQL 会为它分配一段内存 read_buffer_size 大小的缓冲区
- 如果对表的顺序扫描非常频繁，并你认为频繁扫描进行的太慢，可以通过增加该变量值以及内存缓冲区大小提高其性能
- 用来提高表的顺序扫描的效率 数据文件顺序

### read_rnd_buffer_size

- MySQL 的随机读缓冲区大小
- 当按任意顺序读取行时（列如按照排序顺序）将分配一个随机读取缓冲区
- 当进行排序查询时，MySQL 会首先扫描一遍该缓冲，以避免磁盘搜索，提高查询速度
- 如果需要大量数据可适当的调整该值，但 MySQL 会为每个客户连接分配该缓冲区所以尽量适当设置该值，以免内存开销过大
- 用来提高表的随机的顺序缓冲，提高读取的效率

## 7. myisam 的键读取

### Key_read_requests

- 索引请求读的次数

### Key_reads

- 请求在内存中没有找到，然后直接从硬盘读取索引

### Key_reads / Uptime

- 查看间隔时间内这个比例

### Key_reads / Key_read_requests

- =0.1%比较好

## 8. myisam 的键缓存

### Key_blocks_unused

- 目前未被使用的 Cache Block 数目

### Key_blocks_used

- 已经使用了的 Cache Block 数目

### 缓存区使用率

- (key_blocks_unused \* key_cache_block_size) / key_buffer_size
- 如果一段时间后还是没有使用完所有的键缓存，就可以把缓冲区调小一点

## 8. myisam-recover：如何寻找和恢复错误

- DEFAULT：表示不设置，会尝试修复崩溃或者未完全关闭的表，但在恢复数据时不会执行其它动作
- BACKUP：将数据文件备份到.bak 文件，以便随后进行检查
- FORCE：即使.myd 文件中丢失的数据超过 1 行，也让恢复动作继续执行
- QUICK：除非有删除块，否则跳过恢复

## 9. myisam 的并发优化

### concurrent_insert

- 提高 INSERT 操作和 SELECT 之间的并发处理，使二者尽可能并行
- =1: 当表中没有删除记录留下的空余空间时可以在尾部并行插入 (默认设置)
- =2: 不管在表中是否有删除行留下的空余空间，都在尾部进行并发插入，使 INSERT 和 SELECT 互不干扰， 要定期 optimize table

### max_write_lock_count

- 缺省情况下，写操作的优先级要高于读操作的优先级，即便是先发送的读请求，后发送的写请求，此时也会优先处理写请求，然后再处理读请求
- max_write_lock_count=2 有了这样的设置，当系统处理 2 个写操作后，就会暂停写操作，给读操作执行的机会

## 10. sort_buffer_size

- MySql 执行排序使用的缓冲大小
- 如果想要增加 ORDER BY 的速度，首先看是否可以让 MySQL 使用索引而不是额外的排序阶段
- 如果不能，可以尝试增加 sort_buffer_size 变量的大小
- sort_buffer_size，超过 2KB 的时候，就会使用 mmap() 而不是 malloc() 来进行内存分配，导致效率降低
- 默认大小是 256kb，不建议调整
- http://bbs.chinaunix.net/thread-1805254-1-1.html

## 11. 其他参数

### myisam_sort_buffer_size

- 它用于 ALTER TABLE, OPTIMIZE TABLE, REPAIR TABLE 等命令时需要的内存
- 默认值即可

### thread_concurrency

- 在多核的情况下，错误设置 thread_concurrenc 会导致 mysql 不能充分利用多核，出现同一时刻只有一个核在工作的情况
- 应设为 CPU 核数的 2 倍

### wait_timeout=1800s

1. 当你的 MySQL 连接闲置超过一定时间后将会被强行关闭
2. 在线程启动时，根据全局 wait_timeout 值或全局 interactive_timeout 值初始化会话 wait_timeout 值，由 mysql_real_connect()的连接选项 CLIENT_INTERACTIVE 定义
3. interactive_timeout：服务器关闭交互式连接前等待活动的秒数
