# 优化查询

## 原理

- innodb 要缓存数据块，myisam 只缓存索引块,  这中间还有换进换出的减少
- innodb 寻址要映射到块，再到行，myisam 记录的直接是文件的 OFFSET，定位比 innodb 要快
- innodb 还需要维护 MVCC 一致，虽然你的场景没有，但他还是需要去检查和维护 Multi-Version Concurrency Control 多版本并发控制
