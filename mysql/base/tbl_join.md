# 连接

## 内连接

- 关键字：inner join on
- 语句：select \* from a_table a inner join b_table bon a.a_id = b.b_id;
- 组合两个表中的记录，返回关联字段相符的记录，也就是返回两个表的交集（阴影）部分

## 左连接

- 关键字：left join on / left outer join on
- 语句：select \* from a_table a left join b_table bon a.a_id = b.b_id;
- 左表(a_table)的记录将会全部表示出来，而右表记录不足的地方均为 NULL

## 右连接

- 关键字：right join on / right outer join on
- 语句：select \* from a_table a right outer join b_table b on a.a_id = b.b_id;
- 右表(b_table)的记录将会全部表示出来。左表记录不足的地方均为 NULL

## 全连接

- 关键字： FULL OUTER JOIN
- select \* from a_table a right full outer join b_table b on a.a_id = b.b_id;
- mysql 不支持这种写法，可采取左连接和右连接的合集
