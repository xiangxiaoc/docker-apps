# 单机版常用模板

```yaml
version: '2.3'

services:
  SERVICE_NAME:
    image: IMAGE_NAME
    restart: always
    volumes:
      - /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime:ro
    networks:
      - custom_network
    ports:
      - "80:80"
    working_dir: /
    environment:
      - ENV1=value1
    command:
      - CMD
    depends_on:
      - SERVICE_NAME
    logging:
      driver: json-file
      options:
        max-file: '3'
        max-size: 10m
    mem_limit: 1g
    memswap_limit: 0

volumes:
  data:

networks:
  default:
    external:
      name: xxx
  custom_network:
    driver: bridge
  backend:
    external: true
```