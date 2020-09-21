# redis 数据结构之有序集合

## 介绍

- Redis 有序集合和集合一样也是 string 类型元素的集合,且不允许重复的成员
- 不同的是每个元素都会关联一个 double 类型的分数。redis 正是通过分数来为集合中的成员进行从小到大的排序
- 有序集合的成员是唯一的,但分数(score)却可以重复
- 集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是 O(1)
- 集合中最大的成员数为 2^32 - 1

## 内部编码

- ziplist（压缩列表）

  - 当有序集合的元素个数小于 zset-max-ziplist-entries 配置（默认 128 个）,同时每个元素的值小于 zset-max-ziplist-value 配置（默认 64 个字节）时，Redis 会用 ziplist 来作为有序集合的内部实现

- skiplist（跳跃表）

  - 当 ziplist 条件不满足时，有序集合会使用 skiplist 作为内部实现，因为此时 zip 的读写效率会下降

## 测试代码

- 修改 zset-max-ziplist-entries = 5

```
local_virtual2:0>config set zset-max-ziplist-entries 5
OK

local_virtual2:0>zadd score:2 1 a
1

local_virtual2:0>zadd score:2 2 b
1

local_virtual2:0>zadd score:2 3 c
1

local_virtual2:0>zadd score:2 4 d
1

local_virtual2:0>zadd score:2 5 e
1

local_virtual2:0>object encoding score:2
ziplist

local_virtual2:0>zadd score:2 6 f
1

local_virtual2:0>object encoding score:2
skiplist
```

- 修改 zset-max-ziplist-value = 5

```

```
