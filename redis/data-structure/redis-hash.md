# redis 数据结构之哈希

## 介绍

- Redis hash 是一个 string 类型的 field 和 value 的映射表，hash 特别适合用于存储对象。
- Redis 中每个 hash 可以存储 2^32 - 1 键值对

## 内部编码

- ziplist（压缩列表）

  - 当哈希类型元素个数小于 hash-max-ziplist-entries 配置（默认 512 个), 同时所有值都小于 hash-max-ziplist-value 配置（默认 64 个字节）时，Redis 会使用 ziplist 作为哈希的内部实现
  - ziplist 使用更加紧凑的结构实现多个元素的连续存储，所以在节省内存方面比 hashtable 更加优秀

- hashtable（哈希表)
  - 当哈希类型无法满足 ziplist 的条件时，Redis 会使用 hashtable 作为哈希的内部实现
  - 因为此时 ziplist 的读写效率会下降，而 hashtable 的读写时间复杂度为 O(1)

## 测试代码

- 修改 hash-max-ziplist-entries=5

```
local_virtual2:0>config set hash-max-ziplist-entries 5
OK

local_virtual2:0>hset person:2 a 1
1

local_virtual2:0>hset person:2 b 1
1

local_virtual2:0>hset person:2 c 1
1

local_virtual2:0>hset person:2 d 1
1

local_virtual2:0>object encoding person:2
ziplist

local_virtual2:0>hset person:2 e 1
1

local_virtual2:0>object encoding person:2
ziplist

local_virtual2:0>hset person:2 f 1
1

local_virtual2:0>object encoding person:2
hashtable
```

- 修改 hash-max-ziplist-value=5

```
local_virtual2:0>config set hash-max-ziplist-value 5
OK

local_virtual2:0>hset person:3 a a
1

local_virtual2:0>hset person:3 b ab
1

local_virtual2:0>hset person:3 c abc
1

local_virtual2:0>hset person:3 d abcd
1

local_virtual2:0>object encoding person:3
ziplist

local_virtual2:0>hset person:3 e abcde
1

local_virtual2:0>object encoding person:3
ziplist

local_virtual2:0>hset person:3 f abcdef
1

local_virtual2:0>object encoding person:3
hashtable
```
