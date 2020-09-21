# 表维护

## 1. 目的

- 找到并修复损坏的表
- 维护准确的索引统计信息
- 减少碎片

## 2. 常用操作

### 找到损坏的表

- check table tb_name

### 修复损坏的表

- repair table tb_name

### 清理碎片

- optimize table tb_name
- alter table tbl engine=innodb

## 3. 数据碎片

### 行碎片(row fragmentation)

- 数据行被存储为多个地方的多个片段中

### 行间碎片(Intra-row fragmentation)

- 逻辑上顺序的页，在磁盘上不是顺序存储的

### 剩余空间碎片(Free space fragmentation)

- 数据页中有大量的空余空间
