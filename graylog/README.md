# 注意事项

`GRAYLOG_WEB_ENDPOINT_URI` 必须修改为宿主机真实 IP ，在是客户端指向 api 的地址

## 配置文件

在 `config/graylog.conf` 内提供了详细的配置

配置时区

```conf
root_timezone = Asia/Shanghai
```

> ### 日志处理队列
> <https://blog.iany.me/zh/2017/09/centralized-logs-using-graylog-collecting/>
>
> Graylog 内部使用 Kafka 实现了称为 Journal 的队列系统，来缓存接收的日志。这个对集中日志系统相当重要。日志的特性决定了量大，并且分布不平均，会突发地集中在某个时间段产生大量日志。队列能有效的防止突发大数据量输入导致系统瘫痪，将闲时利用起来处理积压的日志。同时还能作为是否要扩充集群提高 Elastic 写入速度的指标。
>
> Graylog 集群每个节点有自己独立的 Journal，扩展 Graylog 本身节点数量不但可以提升日志处理速度，还可以提升队列缓存的容量。
>
> 当 Elastic 写入出现瓶颈，Journal 的队列长度会一直增长，Graylog 设置了俩个阀值，当积压的日志超过 12 小时未处理，或者占用磁盘超过 5G 就会开始丢弃新接收到的日志。通过配置 message_journal_max_age 和 message_journal_max_size 可以修改。Graylog 还提供了 API 查询状态 可以和负载均衡系统集成。