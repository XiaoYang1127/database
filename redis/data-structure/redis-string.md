# redis 数据结构之字符串

## 介绍

- 字符串 string 是 Redis 最简单的数据结构。
- Redis 所有的数据结构都是以唯一的 key 字符串作为名称，然后通过这个唯一 key 值来获取相应的 value 数据。
- String 数据结构是简单的 key-value 类型，value 其实不仅是 String，也可以是数字

## 内部编码

- int：8 个字节的长整型。 (2^64/2 -1 )
- embstr：小于等于 44 个字节的字符串。
- raw：大于 44 个字节的字符串。

## 测试代码

- int -> embstr

```
local_virtual2:0>set a 9223372036854775807
OK

local_virtual2:0>object encoding a
int

local_virtual2:0>set a 9223372036854775808
OK

local_virtual2:0>object encoding a
embstr
```

- embstr -> raw

```
local_virtual2:0>set a abcdefghijklmnopqrstuvmwzyz123456789@#$^&*()
OK

local_virtual2:0>strlen a
44

local_virtual2:0>object encoding a
embstr

local_virtual2:0>set a abcdefghijklmnopqrstuvmwzyz123456789@#$^&*()-
OK

local_virtual2:0>object encoding a
raw

local_virtual2:0>strlen a
45
```
