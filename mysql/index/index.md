# 索引介绍

## 1. 介绍

- 索引优化应该是对查询性能优化最有效的手段
- mysql 只能高效地使用索引的最左前缀列
- mysql 中索引是在存储引擎层而不是服务器层实现的

## 2. 索引的操作

```mysql
# 创建索引
* alter table table_name add index index_name (column_list);
* alter table table_name add unique (column_list);
* alter table table_name add primary key (column_list);

# 创建索引2
* create index index_name on table_name (column_list)
* create unique index index_name on table_name (column_list)
* 不能用CREATE INDEX语句创建PRIMARY KEY索引

# 删除索引
* drop index index_name on table_name
* alter table table_name drop index index_name
* alter table table_name drop primary key
* 在前面的两条语句中，都删除了table_name中的索引index_name
* 在最后一条语句中，只在删除PRIMARY KEY索引中使用，因为一个表只可能有一个PRIMARY KEY索引，因此不需要指定索引名
* 如果没有创建PRIMARY KEY索引，但表具有一个或多个UNIQUE索引，则MySQL将删除第一个UNIQUE索引
* 如果从表中删除某列，则索引会受影响。对于多列组合的索引，如果删除其中的某列，则该列也会从索引中删除
* 如果删除组成索引的所有列，则整个索引将被删除

# 查看索引
* show keys from table_name;
* show index from table_name;
* show create table table_name;

# 添加列
* alter table TABLE_NAME add column NEW_COLUMN_NAME varchar(20) not null;
* alter table TABLE_NAME add column NEW_COLUMN_NAME varchar(20) not null after COLUMN_NAME;
* alter table TABLE_NAME add column NEW_COLUMN_NAME varchar(20) not null first;
```

## 3. B-Tree 索引

- B-Tree 对索引列是顺序组织存储的，索引很适合查找范围数据

### B-Tree 索引的限制

- 如果不是按照索引的最左列开始查找，则无法使用索引
- 不能跳过索引中的列
- 如果查询中有某列的范围查询，则其右边所有列都无法使用索引优化查询
- 这些限制都和索引列的顺序存储有关系。或者说是索引顺序存储导致了这些限制

## 4. 哈希索引

- 哈希索引基于哈希表实现的，只有精确匹配索引所有列的查询才有效
- 对于每一行数据，存储引擎都会对所有的索引列计算一个哈希值，哈希值是一个较小的值，并且不同键值的行计算出来的哈希值不一样
- 哈希索引将所有的哈希值存储在索引中，同时保存指向每个数据行的指针，这样就可以根据，索引中寻找对于哈希值，然后在根据对应指针，返回到数据行
- mysql 中只有 memory 引擎显式支持哈希索引，innodb 是隐式支持哈希索引的

### 哈希索引限制

- 哈希索引只包含哈希值和行指针，不存储字段值，所以不能使用"覆盖索引"的优化方式，去避免读取数据表
- 哈希索引数据并不是按照索引值顺序存储的，索引也就无法用于排序
- 哈希索引页不支持部分索引列匹配查找，因为哈希索引始终是使用索引列的全部内容计算哈希值的
- 哈希索引只支持等值比较查询，包括=，in(),<=>，不支持任何范围查询。列入 where price>100
- 访问哈希索引的数据非常快，除非有很多哈希冲突（不同的索引列值却有相同的哈希值）
- 如果哈希冲突很多的话，一些索引维护操作的代价也会很高

## 5. 创建索引注意的地方

- 索引列不能是表达式的一部分，也不能是函数的参数
- 正则表达式，不能使用索引
- 不包括 NULL 行的列
- like '%aaa%'的列不走索引，like 'aa%'的列走索引
- 使用 NOT IN 、<>、!=操作，不能使用索引
- 在多列索引的第一个字段使用范围查找，不能使用索引
- 在经常需要排序，分组，distinct 列上加索引 可以加快排序查询的时间
- 在表与表的而连接条件上加上索引，可以加快连接查询的速度
- 将选择性最高的列放在最前面，公式是 count(distinct colum)/count(\*)，表示字段不重复的比例，比例越大我们扫描的记录数越少
- 尽量扩展索引，不要新建索引

## 6. 索引特点

### 什么情况下不创建索引

- 查询中很少使用到的列
- 很少数据的列也不应该建立索引 【如 sex 列只有 0 或 1，导致结果集占数据表的比例比较大】
- 定义为 text 和 image 和 bit 数据类型的列不应该增加索引
- 当表的修改操作远远大于检索操作时不应该创建索引

### 索引弊端

- 索引大大提高了查询速度，同时却会降低更新表的速度
- 因为更新表时，mysql 不仅要保存数据，还要保存一下索引文件
- 建立索引会占用磁盘空间的索引文件，特别注意大表

### 索引优点

- 索引大大减少了服务器需要扫描的数据量
- 索引可以帮助服务器避免排序和临时表
- 索引可以将随机 I/O 变成顺序 I/O

## 7. 种类

### 覆盖索引

- 如果一个索引包含(或覆盖)所有需要查询的字段

### 半宽索引

- 匹配 where 后所有谓词列
- 可以确保回表访问只发生在所有查询条件都满足的时候
- 不能避免主表的随机访问，但起码可以支持索引表的顺序读取

### 宽索引

- 包含 select 语句所涉及的所有列

### 三星索引

- 第一颗星：取出所有的等值谓词，将这些列放在最开头列，使得扫描的索引片宽度将被缩减至最窄
- 第二颗星：将 order by 加入到索引列中
- 第三颗星：将查询语句中剩余列加到索引中去，避免反复的“回表”操作

### 实践中的最佳索引

- 满足上述的 2 颗星之二

## 8. 前缀索引

### 优点

- 索引开始的部分字符，大大节约索引空间，提高索引效率

### 缺点

- 无法使用前缀索引做 order by 和 group by 排序
- 无法使用前缀索引做覆盖扫描

### 如何找到引合适的前缀索长度

- 基准值：select count(distinct city)/count(\*) from table_name
- 查询值：select count(distinct left(city, 3))/count(\*) from table_name
- alter table table_name add key(city(2))

## 9. 多列索引

### 组合索引顺序如何决定

- select count(distinct staff*id)/count(*), count(staff*id)/count(*) from table_name
- alter table_name add key(custom_id, staff_id)

## 10. 合并索引

- 5.0 版本中引入新特性
- 当查询中单张表可以使用多个索引时，同时扫描多个索引并将扫描结果进行合并

### 应用场景

- 对 OR 语句求并集
- 对 AND 语句求交集
- 对 AND 和 OR 组合语句求结果

### 分析

```
Q1: c1列和c2列选择性较高时，按照c1和c2条件进行查询性能较高且返回数据集较小，
再对两个数据量较小的数据集求交集的操作成本也较低，最终整个语句查询高效

Q2: 当c1列或c2列选择性较差且统计信息不准时，比如整表数据量2000万，按照c2列条件返回1500万数据，
按照c1列返回1000条数据，此时按照c2列条件进行索引扫描 + 聚集索引查找的操作成本极高，
对1000条数据和1500万数据求交集的成本也极高，最终导致整条SQL需要消耗大量CPU和IO资源且相应时间超长，
而如果值使用c1列的索引，查询消耗资源较少且性能较高
```

### 解决办法

- 将 OR 操作修改为 UNION 操作，使得不开启 Index merge 特性的情况下语句依然能使用多个索引
- 可以使用 UNION ALL 来求交集，避免 UNION 所带来的排序消耗

### index merge 之 intersect

- 多个索引条件扫描得到的结果进行交集运算，即在多个索引提交之间是 AND 运算时，才会出现 index intersect merge

### index merge 之 union

- 多个索引条件扫描，对得到的结果进行并集运算，显然是多个条件之间进行的是 OR 运算

### index merge 之 sort_union

- 多个条件扫描进行 OR 运算，但是不符合 index union merge 算法的，此时可能会使用 sort_union 算法
