# 表字段尽量不要使用 null 字段

## 针对查询情况分析

- 所有使用 NULL 值的情况，都可以通过一个有意义的值的表示，这样有利于代码的可读性和可维护性，并能从约束上增强业务数据的规范性
- NULL 值到非 NULL 的更新无法做到原地更新，更容易发生索引分裂，从而影响性能
- null -> not null 性能提升很小，除非确定它带来了问题，否则不要当成优先的优化措施
- NULL 值在 timestamp 类型下容易出问题，特别是没有启用参数 explicit_defaults_for_timestamp
- NOT IN、!= 等负向条件查询在有 NULL 值的情况下返回永远为空结果，查询容易出错
- 当计算 count 时候 null column 不会计入统计
- concat 连接的时候，还需判断各个字段是否为 null

## 针对索引情况分析

```sql
create table table1 (
    `id` INT (11) NOT NULL,
    `name` varchar(20) NOT NULL
)

create table table2 (
    `id` INT (11) NOT NULL,
    `name`  varchar(20)
)

alter table table1 add index idx_name (name);
alter table table2 add index idx_name (name);

explain select * from table1 where name='zhaoyun';
explain select * from table2 where name='zhaoyun';
```

- table1 的 key_len = 82
- table2 的 key_len = 83
- key_len 的计算规则和三个因素有关：数据类型、字符编码、是否为 NULL
- 82 = 20 \* 4(utf8mb4 - 4 字节, utf8 - 3 字节) + 2(存储 varchar 变长字符长度为 2 字节，定长字段无需额外的字节)
- 83 = 20 \* 4(utf8mb4 - 4 字节, utf8 - 3 字节) + 2(存储 varchar 变长字符长度为 2 字节，定长字段无需额外的字节) + 1(是否为 null 的标志)
- 索引字段最好不要为 NULL，因为 NULL 会使索引、索引统计和值更加复杂，并且需要额外一个字节的存储空间

## 引用

- https://www.cnblogs.com/balfish/p/7905100.html
