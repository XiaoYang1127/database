# 分页确保每次向下翻页看到的记录都不重复

## 做法

- select \* from table_A where id!=LAST_ID and update_time<=LAST_UPDATE_TIME order by update_time desc, id desc;
- LAST_ID：界面显示的最后一条记录的主键
- LAST_UPDATE_TIME：界面显示的最后一条记录的更新时间

## 注意

- 批量插入的时候，确保 update_time 不一致，比如自增
