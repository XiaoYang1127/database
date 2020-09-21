# limit 过大优化

## 现状

```
  1. select * from table_A where id!=LAST_ID and update_time<=LAST_UPDATE_TIME order by
  update_time desc, id desc limit 1000000,10;
  2. 扫描满足条件的100020行，扔掉前面的10000行，返回最后的20行，效率较低
```

## 原因(针对 innodb)

```
  1. 建立(update_time,id)索引，匹配谓词为update_time, 过滤谓词为id
  2. 通过二级索引查到主键值
  3. 再根据查到的主键值通过主键索引找到相应的数据块。（读取的数据来源于buffer缓存或磁盘）
  4. 因为主键(或索引)没有全部数据，所以需要根据索引随机读取1000000次数据
  5. 最后根据offset的值，查询1000010次主键索引的数据，最后将之前的1000000条丢弃，取出最后10条。
  6. MySQL耗费了大量随机I/O在查询聚簇索引的数据上，而有1000000次随机I/O查询到的数据是不会出现在结果集当中的
```

## 解决办法

- 先通过条件拿到主键，然后再去查询所需要的数据
- SELECT \* FROM table_A WHERE ID >= (select id from table_A where xx limit 10000, 1) limit 20
- SELECT \* FROM product a JOIN (select id from table_A l where xx imit 10000, 20) b ON a.ID = b.id
