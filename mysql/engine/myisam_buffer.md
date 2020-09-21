# myisam buffer

## 1. 介绍

- 设置索引块（index blocks）缓存的大小，它被所有线程共享
- 它决定索引处理的速度，尤其是索引读的速度，为 myisam 数据表开启供线程共享的索引缓存
- 即使不用 MyISAM 表，也要设置该值 8-64M，用于临时表

## 2. 参数说明

### key_buffer_size 的大小设置与下列因数有关

- 系统索引的总大小
- 系统可用物理内存
- 系统当前的 Key Cache 命中率

### key_buffer_block_size

- 索引缓存中的 Cache Block Size

### key_cache_division_limit

- LRU 链表中的 Hot Area 和 Warm Area 分界值，默认值 100，默认时候只有 Warm Area
- 用来存放使用比较频繁的 Hot Cache Block（Hot Chain），被称为 Hot Area
- 用来存放使用不太频繁的 Warm Cache Block（Warm Chain），被称为 Warm Area

### key_cache_age_threshold

- 控制 Cache Block 从 Hot Area 降到 Warm Area 的限制

## 3. 如何应用单独 Key Cache

### 设置

- set global hot_cache.key_buffer_size = 128 \* 1024;

### 应用

- cache index t1 on hot_cache;

### 清空

- set global hot_cache.key_buffer_size = 0;

### 预加载

- load index into cache t1, t2;

## 4. 注意

- 内存中缓存的索引块（Key Cache），有时候并不会及时刷新到磁盘上，所以对于正在运行的数据表的索引文件（MYI）一般都是不完整的。
- 如果此时拷贝或者移动这些索引文件。多半会出现索引文件损坏的情况
- flush tables with read lock;
- show status like 'Key_blocked_not_flushed'是否为 0
- 移动对应的 myi, myd, frm
