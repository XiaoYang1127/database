# 删除表

## 1. 删除的方式

- delete
- truncate

## 2. 几个方面对比

### 条件删除

- delete 是可以带 WHERE 的，所以支持条件删除
- truncate 只能删除整个表

### 事务回滚

- delete 是数据操作语言，Data Manipulation Language，操作时原数据会被放到 rollback segment 中，可以被回滚
- truncate 是数据定义语言，Data Definition Language，操作时不会进行存储，不能进行回滚

### 清理速度

- 在数据量比较小的情况下，delete 和 truncate 的清理速度差别不是很大
- 数据量很大的时候，由于 truncate 不需要支持回滚，所以使用的系统和事务日志资源少
- delete 语句每次删除一行，并在事务日志中为所删除的每行记录一项，固然会慢，但是相对来说也较安全

### 可恢复

- truncate 删除后不记录 mysql 日志，不可以恢复数据
