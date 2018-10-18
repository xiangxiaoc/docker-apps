## 注意事项

elasticsearch 6.4 文档中要求 vm.max_map_count 的值至少为 262144

```sh
sudo echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sudo sysctl -w vm.max_map_count=262144
```

filebeat 6.4 要求 /var/lib/docker/containers/*/*.log 可读

```sh
sudo chmod o+rx /var/lib/docker
sudo chmod o+rx -R /var/lib/docker/containers
```