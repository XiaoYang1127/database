# 分组和聚合

## group by

- group by 以数据表中的某个字段的值来分组
- select 的字段只能是分组的字段类别或者使用聚合函数如，max(),min(),count()的字段
- where 在前，group by 在后，注意 group by 紧跟在 where 最后一个限制条件后面，不能被夹在 where 限制条件之间
- 要先用 where 过滤掉不进行分组的数据，然后在对剩下满足条件的数据进行分组

## having

- having 是在分好组后找出特定的分组，通常是以筛选聚合函数的结果，如 sum(a) > 100 等，且 having 必须在 group by 后面
- 使用了 having 必须使用 group by，但是使用 group by 不一定使用 having

## 其他

- 不允许使用双重聚合函数
- 对分组进行筛选的时候可以用 order by 排序，然后用 limit 也可以找到极值
