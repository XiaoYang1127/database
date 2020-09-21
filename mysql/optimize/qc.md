# query cache 介绍

## 1. 参数讲解

### Qcache_free_blocks

- 缓存中相邻内存块的个数
- 数目大说明可能有碎片，从而得到一个空闲块

### Qcache_free_memory

- 缓存中的空闲内存

### Qcache_hits

- 每次查询在缓存中命中时就增大

### Qcache_inserts

- 每次插入一个查询时就增大

### Qcache_lowmem_prunes

- 缓存出现内存不足并且必须要进行清理以便为更多查询提供空间的次数。
- 这个数字最好长时间来看，如果这个数字在不断增长，就表示可能碎片非常严重，或者内存很少

### Qcache_not_cached

- 不适合进行缓存的查询的数量，通常是由于这些查询不是 SELECT 语句或者用了 now()之类的函

### Qcache_queries_in_cache

- 当前缓存的查询和响应的数量

### Qcache_total_blocks

- 缓存中块的数量

### query_cache_limit

- 超过此大小的查询将不缓存

### query_cache_min_res_unit

- 缓存块的最小大小，设置值大对大数据查询有好处
- 如果你的查询都是小数据查询，就容易造成内存碎片和浪费

### query_cache_size

- 查询缓存大小

### query_cache_type

- 查询缓存类型
- 0-关闭，1-开启，2-demand

### query_cache_wlock_invalidate

- 1：在写锁定的同时将失效该表相关的所有 Query Cache
- 0：在锁定时刻仍然允许读取该表相关的 Query Cache

### query_cache_min_res_unit 参数

- 一般情况下不是一次性地分配足够多的内存来缓存结果的，而是在查询结果获得的过程中，逐块存储
- 当一个存储块被填满之后，一个新的存储块将会被创建，并分配内存（allocate）
- 单个存储块的内存分配大小通过 query_cache_min_res_unit 参数控制，默认值为 4KB
- Qcache_queries_in_cache / Qcache_total_blocks 接近 1:2 则表示参数已经足够大
- 如果 Qcache_total_blocks 比 Qcache_queries_in_cache 多很多，则需要增加 query_cache_min_res_unit 的大小
- Qcache_queries_in_cache \* query_cache_min_res_unit，如果远远大于 query_cache_size - Qcache_free_memory，那么可以尝试减小 query_cache_min_res_unit 的值

## 2. 不应该使用 QC 的地方

- 涉及频繁更新的表，查询缓存会失效
- 缓存的 sql 语句被用的次数很少

## 3. sql 控制是否使用 QC，前提是 query_cache_type=2

- select \* from table_name sql_cache; 使用 QC
- select \* from table_name sql_noche; 不使用 QC

## 4. 适合使用 QC 的地方

- 需要消耗系统大量资源的查询，如 count，多表 join 后还需做排序和分页
- 结果集很小，且涉及表的更新操作非常少

## 5. 查询缓存计算公式

### 缓存命中率

- 公式：Qcache_hits / (Qcache_hits + Qcache_inserts) \* 100

### 缓存利用率

- 公式：(query_cache_size -Qcache_free_memory) / query_cache_size

### 缓存碎片率

- 公式：Qcache_free_blocks / Qcache_total_blocks \* 1.0

## 6. 查询缓存未命中原因

- 查询语句无法缓存，(now()，current\*()，自定义函数，存储函数，用户变量，字查询，或查询结果过大)
- 从来未处理过这个查询
- 查询缓存的内存使用完毕
- 缓存通过一个哈希值引用存放在一个引用表中，这个哈希值包括查询本身，数据库，客户端协议的版本等，所以查询语句上任何字符上的不同，例如空格，注释都会导致缓存不命中

## 7. 查询缓存大小设置建议

- 整理碎片期间，查询缓存无法被访问，可能导致服务器僵死一段时间，所以查询缓存不宜太大
- 由于查询缓存是靠一个全局锁操作保护的，如果查询缓存配置的内存比较大且里面存放了大量的查询结果，当查询缓存失效的时候，会长时间的持有这个全局锁
