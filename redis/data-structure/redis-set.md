# redis 数据结构之集合

## 介绍

- Redis 的 Set 是 String 类型的无序集合。
- 集合成员是唯一的，这就意味着集合中不能出现重复的数据。
- Redis 中集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是 O(1)。
- 集合中最大的成员数为 2^32 - 1

## 内部编码

- intset（整数集合）

  - 当集合中的元素都是整数且元素个数小于 set-max-intset-entries 配置（默认 512 个）时，Redis 会选用 intset 来作为集合内部实现，从而减少内存的使用。

- hashtable（哈希表）

  - 当集合类型无法满足 intset 的条件时，Redis 会使用 hashtable 作为集合的内部实现

## 测试代码

- 修改 set-max-intset-entries=5

```
local_virtual2:0>config set set-max-intset-entries 5
OK

local_virtual2:0>sadd set_test:1 1 2 3 4 5
5

local_virtual2:0>object encoding set_test:1
intset

local_virtual2:0>sadd set_test:1 6
1

local_virtual2:0>object encoding set_test:1
hashtable
```
