# redis 事务

## 1. 介绍

- 事务必须满足 ACID 原则，原子性、一致性、隔离性和持久性
- 事务就是打包一组操作或者命令作为一个整体，在事务处理时将顺序执行这些操作，并返回结果，如果其中任何一个环节出错，所有的操作将被回滚

## 2. 实现命令的方式

### MULTI

- 用于标记事务的开始，其后执行的命令都被存入命令队列，直到执行 EXEC 时，这些命令才会被原子的执行

### EXEC

- 执行在一个事务内命令队列的所有命令，同时将当前连接的状态恢复为正常状态，即非事务状态
- 如果在事务中执行了 WATCH 命令，那么只有当 WATCH 所监控的 keys 没有被修改的前提下，EXEC 命令才能执行事务队列中的所有命令，
  否则 EXEC 将放弃当前事务中的所有命令

### DISCARD (reset)

- 回滚事务队列中的所有命令，同时在将当前连接的状态恢复为正常状态，即非事务状态
- 如果 WATCH 命令被使用，该命令将 UNWATCH 所有 keys

### WATCH [key...]

- 在 MULTI 命令执行之前，可以指定待监控的 keys
- 在执行 EXEC 之前，如果被监控的 keys 发生修改，EXEC 将放弃执行该事务队列中的所有命令

### UNWATCH

- 取消当前事务中指定监控的 keys
- 执行了 EXEC 或 DISCARD 命令之后，事务中所有监控的 keys 都被自动取消

## 3. 事务回滚类型

- 若在事务队列中存在命令性错误，则执行 EXEC 命令时，所有命令都不会执行
- 若在事务队列中存在语法性错误，则执行 EXEC 命令时，其他正确命令会被执行，错误命令抛出异常

## 4. 为什么 redis 不支持事务

### 原因

- 这种复杂的功能和 Redis 追求的简单高效的设计主旨不符合
- Redis 事务的执行时，错误通常都是编程错误造成的，这种错误通常只会出现在开发环境中，而很少会在实际的生产环境中出现

### 事务没有隔离级别

- 批量操作在发送 EXEC 命令前被放入队列缓存，并不会被实际执行，也就不存在事务内的查询要看到事务里的更新，事务外查询不能看到

### 事务不保证原子性

- Redis 中，单条命令是原子性执行的，但事务不保证原子性，且没有回滚
- 事务中任意命令执行失败，其余的命令仍会被执行

## 5. 简单的 redis 事务

- WATCH 命令实现
