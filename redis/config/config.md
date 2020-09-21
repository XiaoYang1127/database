# redis 配置

## 1. 碎片

### 碎片整理总开关

- activedefrag yes

### 内存碎片达到多少的时候开启整理

- active-defrag-ignore-bytes 100mb

### 碎片率达到百分之多少开启整理

- active-defrag-threshold-lower 10

### 碎片率小余多少百分比开启整理

- active-defrag-threshold-upper 100

### Minimal effort for defrag in CPU percentage

- active-defrag-cycle-min 25

### Maximal effort for defrag in CPU percentage

- active-defrag-cycle-max 75
