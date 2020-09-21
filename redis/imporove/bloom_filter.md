# 布隆过滤器

## 1. 介绍

- 本质上布隆过滤器是一种数据结构，比较巧妙的概率型数据结构（probabilistic data structure）

## 2. 特点

- 高效地插入和查询，可以用来告诉你某样东西一定不存在或者可能存在
- 相比于传统的 List、Set、Map 等数据结构，它更高效、占用空间更少
- 缺点是其返回的结果是概率性的，而不是确切的

## 3. 数据结构

- 布隆过滤器是一个 bit 向量, 或者说 bit 数组
- 使用多个不同的哈希函数生成多个哈希值，并对每个生成的哈希值指向的 bit 位置 1
- 随着增加的值越来越多，被置为 1 的 bit 位也会越来越多，就会导致覆盖的问题

## 4. 支持的操作

- add
- isExist

## 5. 如何选择布隆过滤器长度

### 背景

- 过小的布隆过滤器很快所有的 bit 位均为 1，那么查询任何值都会返回可能存在，起不到过滤的目的
- 布隆过滤器的长度会直接影响误报率，布隆过滤器越长其误报率越小

## 6. 如何选择哈希函数个数

### 背景

- 个数越多则布隆过滤器 bit 位置位 1 的速度越快，且布隆过滤器的效率越低
- 个数太少的话，那我们的误报率会变高

## 7. 最佳实践

- 利用布隆过滤器减少磁盘 IO 或者网络请求，因为一旦一个值必定不存在的话，我们可以不用进行后续昂贵的查询请求

## 8. 基于 python 的实现地址

- https://github.com/liyaopinner/BloomFilter_imooc