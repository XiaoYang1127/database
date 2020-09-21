# 设计规范

## 命名

- 数据库对象名称必须使用小写字母并用下划线分割
- 临时库表必须以 tmp\*为前缀并以日期为后缀，备份表必须以 bak\*为前缀并以日期(时间戳)为后缀
- 所有存储相同数据的列名和列类型必须一致，如果查询时关联列类型不一致会自动进行数据类型隐式转换，会造成列上的索引失效，导致查询效率降低

## 基本规范

- 表必须使用 Innodb 存储引擎, Innodb 支持事务，支持行级锁，更好的恢复性，高并发下性能更好
- 数据库和表的字符集统一使用 UTF-8,如果数据库中有存储 emoji 表情的需要，字符集需要采用 utf8mb4 字符集
- 所有表和字段都要添加注释
- 尽量控制单表数据量的大小，建议控制在 500 万以内, 过大会造成修改表结构、备份、恢复都会有很大的问题
  - 针对日志数据，采用历史数据归档
  - 针对业务数据，采用分库分表
- 禁止在表中建立预留字段
- 禁止在数据库中存储图片，文件等大的二进制数据
- 禁止在线上做数据库压力测试
- 禁止从开发环境，测试环境直接连接生产环境数据库

## 设计规范

- 优先选择符合存储需要的最小的数据类型
  - 列的字段越大，建立索引时所需要的空间也就越大，这样一页中所能存储的索引节点的数量也就越少也越少，在遍历时所需要的 IO 次数也就越多，索引的性能也就越差
  - 如 ip 转存为整型
  - 负数，采用无符号存储
- 尽量避免避免使用 TEXT、BLOB 数据类型
  - 建议把 BLOB 或是 TEXT 列分离到单独的扩展表中
  - Mysql 内存临时表不支持 TEXT、BLOB 这样的大数据类型，如果查询中包含这样的数据，在排序等操作时，就不能使用内存临时表，必须使用磁盘临时表进行
  - 查询时一定不要使用 select \* 而只需要取出必要的列，不需要 TEXT 列的数据时不要对该列进行查询
  - TEXT 或 BLOB 类型只能使用前缀索引
- 避免使用 ENUM 类型
  - 修改 ENUM 值需要使用 ALTER 语句
  - ENUM 类型的 ORDER BY 操作效率低，需要额外操作
  - 禁止使用数值作为 ENUM 的枚举值
- 尽可能把所有列定义为 NOT NULL
  - 索引 NULL 列需要额外的空间来保存，所以要占用更多的空间
  - 进行比较和计算时要对 NULL 值做特别的处理
- 使用 TIMESTAMP（4 个字节）或 DATETIME 类型（8 个字节）存储时间
  - TIMESTAMP 存储的时间范围 1970-01-01 00:00:01 ~ 2038-01-19-03:14:07
  - TIMESTAMP 占用 4 字节和 INT 相同，但比 INT 可读性高
  - 超出 TIMESTAMP 取值范围的使用 DATETIME 类型存储
- 同财务相关的金额类数据必须使用 decimal 类型
  - 非精准浮点：float,double
  - 精准浮点：decimal
  - Decimal 为精准浮点数，在计算时不会丢失精度。占用空间由定义的宽度决定，每 4 个字节可以存储 9 位数字，并且小数点要占用一个字节，可用于存储比 bigint 更大的整型数据

## 索引设计规范

- 限制每张表上的索引数量，建议单张表索引不超过 5 个
  - 索引可以提高效率同样可以降低效率。索引可以增加查询效率，但同样也会降低插入和更新的效率，甚至有些情况下会降低查询效率
  - 因为 mysql 优化器在选择如何优化查询时，会根据统一信息，对每一个可以用到的索引来进行评估，以生成出一个最好的执行计划，如果同时有很多个索引都可以用于查询，就会增加 mysql 优化器生成执行计划的时间，同样会降低查询性能
- 禁止给表中的每一列都建立单独的索引
- 每个 Innodb 表必须有个主键
  - Innodb 是按照主键索引的顺序来组织表的
  - 不要使用更新频繁的列作为主键，不适用多列主键（相当于联合索引）
  - 不要使用 UUID,MD5,HASH,字符串列作为主键（无法保证数据的顺序增长）
  - 主键建议使用自增 ID 值

## 索引 SET 规范

- 尽量避免使用外键约束
  - 不建议使用外键约束（foreign key），但一定要在表与表之间的关联键上建立索引
  - 外键可用于保证数据的参照完整性，但建议在业务端实现
  - 外键会影响父表和子表的写操作从而降低性能

## 数据库 SQL 开发规范

- 建议使用预编译语句进行数据库操作
  - 预编译语句可以重复使用这些计划，减少 SQL 编译所需要的时间，还可以解决动态 SQL 所带来的 SQL 注入的问题
  - 只传参数，比传递 SQL 语句更高效，相同语句可以一次解析，多次使用，提高处理效率
- 避免数据类型的隐式转换
  - 隐式转换会导致索引失效
- 充分利用表上已经存在的索引
  - 避免使用双%号的查询条件，如 a like '%123%'，（如果无前置%,只有后置%，是可以用到列上的索引的）
  - 在定义联合索引时，如果 a 列要用到范围查找的话，就要把 a 列放到联合索引的右侧
- 使用 left join 或 not exists 来优化 not in 操作
- 禁止使用 SELECT \*，必须使用 SELECT <字段列表> 查询
  - 消耗更多的 CPU 和 IO 以网络带宽资源
  - 无法使用覆盖索引
  - 可减少表结构变更带来的影响
- 禁止使用不含字段列表的 INSERT 语句
  - insert into values ('a','b','c'); 替换为 insert into t(c1,c2,c3) values ('a','b','c');
- 避免使用子查询，可以把子查询优化为 join 操作
  - 通常子查询在 in 子句中，且子查询中为简单 SQL(不包含 union、group by、order by、limit 从句)时,才可以把子查询转化为关联查询进行优化
  - 子查询性能差的原因
    - 子查询的结果集无法使用索引，通常子查询的结果集会被存储到临时表中，不论是内存临时表还是磁盘临时表都不会存在索引，所以查询性能会受到一定的影响
    - 特别是对于返回结果集比较大的子查询，其对查询性能的影响也就越大
    - 由于子查询会产生大量的临时表也没有索引，所以会消耗过多的 CPU 和 IO 资源，产生大量的慢查询
- 避免使用 JOIN 关联太多的表
  - 对于 Mysql 来说，是存在关联缓存的，缓存的大小可以由 join_buffer_size 参数进行设置
  - 如果程序中大量的使用了多表关联的操作，同时 join_buffer_size 设置的也不合理的情况下，就容易造成服务器内存溢出的情况，就会影响到服务器数据库性能的稳定性
  - 对于关联操作来说，会产生临时表操作，影响查询效率
  - Mysql 最多允许关联 61 个表，建议不超过 5 个
- 减少同数据库的交互次数
  - 数据库更适合处理批量操作，合并多个相同的操作到一起，可以提高处理效率
- 对应同一列进行 or 判断时，使用 in 代替 or
  - in 的值不要超过 500 个
  - in 操作可以更有效的利用索引，or 大多数情况下很少能利用到索引
- 禁止使用 order by rand() 进行随机排序
- WHERE 从句中禁止对列进行函数转换和计算
- 在明显不会有重复值时使用 UNION ALL 而不是 UNION
  - UNION 会把两个结果集的所有数据放到临时表中后再进行去重操作
  - UNION ALL 不会再对结果集进行去重操作
- 拆分复杂的大 SQL 为多个小 SQL
  - 大 SQL：逻辑上比较复杂，需要占用大量 CPU 进行计算的 SQL
  - MySQL 一个 SQL 只能使用一个 CPU 进行计算。SQL 拆分后可以通过并行执行来提高处理效率

## 数据库操作行为规范

- 超 100 万行的批量写（UPDATE、DELETE、INSERT）操作，要分批多次进行操作
  - 大批量操作可能会造成严重的主从延迟
  - binlog 日志为 row 格式时会产生大量的日志
  - 避免产生大事务操作
- 对于大表使用 pt-online-schema-change 修改表结构
  - 避免大表修改产生的主从延迟
  - 避免在对表字段进行修改时进行锁表
  - 把原来一个 DDL 操作，分解成多个小的批次进行