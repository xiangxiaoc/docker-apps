# 集群部署模板

```yaml
version: '3'

services:
  
  SERVICE_NAME:
    image: IMAGE_NAME
    environment:
      - ENV1=VALUE1
    ports:
      - "80:80"
    logging:
      driver: json-file
      options:
        max-file: '3'
        max-size: 10m
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == worker

networks:
  
  default:
```