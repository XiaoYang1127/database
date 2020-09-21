# innodb buffer

## 1. 介绍

- 数据的读写需要经过缓存，即缓存在 buffer pool，也就是在内存中
- 不仅缓存索引，还会缓存实际的数据
- 数据以整页（16K）位单位读取到缓存中
- 缓存中的数据以 LRU 策略换出（最少使用策略）
- IO 效率高，性能好

## 2. 读写过程

- buffer pool 是数据库页面的缓存
- 对 InnoDB 的任何修改操作都会首先在 bp 的 page 上进行，然后这样的页面将被标记为 dirty 并被放到专门的 flush list 上
- 后续将由 master thread 或专门的刷脏线程阶段性的将这些页面写入磁盘

## 3. 好处

```
1. 避免每次写操作都操作磁盘导致大量的随机IO，阶段性的刷脏可以将多次对页面的修改merge成一次IO操作，
  同时异步写入也降低了访问的时延。

2. 如果在dirty page还未刷入磁盘时，server非正常关闭，这些修改操作将会丢失
  如果写入操作正在进行，甚至会由于损坏数据文件导致数据库不可用

3. 解决办法：Innodb将所有对页面的修改操作写入一个专门的文件，并在数据库启动时从此文件进行恢复操作，
  这个文件就是redo log file，这样的技术推迟了bp页面的刷新，从而提升了数据库的吞吐，有效的降低了访问时延，
  带来的问题是额外的写redo log操作的开销，以及数据库启动时恢复操作所需的时间
```

## 4. 参数说明

### innodb_buffer_pool_size

- 缓存 innodb 表的索引和数据，对 Innodb 整体性能影响最大

### innodb_buffer_pool_instances

- 通过划分 innodb buffer pool 为多个实例，可以提高并发能力，并且减少了不同线程读写造成的缓冲页
- 当较多数据加载到内存时, 使用多缓存实例能减少缓存争用情况

### innodb_buffer_pool_chunk_size

- 等于 innodb_buffer_pool_size/innodb_buffer_pool_instances，默认是 128M

### innodb_additional_mem_pool_size

- 用来存放 Innodb 的字典信息和其他一些内部结构所需要的内存空间。默认 8M

### innodb_max_dirty_pages_pct

- 在 buffer pool 缓冲中，允许 Innodb 的脏页的百分比，值在范围 1-100,默认为 90，建议保持默认

## 5. 线上调整 innodb_buffer_pool_size 注意事项

- 在调整 innodb_buffer_pool_size 期间，用户的请求将会阻塞，直到调整完毕
- 调整时，内部把数据页移动到一个新的位置，单位是块，如果想增加移动的速度，需要调整 innodb_buffer_pool_chunk_size 参数的大小
- SET GLOBAL innodb_buffer_pool_size=402653184;
- 监控 Buffer Pool 调整进程: SHOW STATUS WHERE Variable_name='InnoDB_buffer_pool_resize_status';
