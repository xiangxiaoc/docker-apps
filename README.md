# docker-compose
## 单机版常用模板
version: '2.3'

networks:
  net_a:
  net_b:

volumes:
  data1:

services:
  service_name:
    image: 
    container_name: 
    restart: always
    volumes:
      - /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime:ro
    ports:
      - 
    working_dir: 
    environment:
      -
    command:
      -
    networks 
      -
    depends_on:
      - 