- 默认用户名: admin@admin.com
- 密码: ymfe.org


### 禁止注册
在 config.json 添加 closeRegister:true 配置项,就可以禁止用户注册 yapi 平台，修改完成后，请重启 yapi 服务器。
```
{
  "port": "*****",
  "closeRegister":true
}
```
### 配置邮箱
打开项目目录 config.json 文件，新增 mail 配置， 替换默认的邮箱配置
```
{
  "port": "*****",
  "adminAccount": "********",
  "db": {...},
  "mail": {
    "enable": true,
    "host": "smtp.163.com",    //邮箱服务器
    "port": 465,               //端口
    "from": "***@163.com",     //发送人邮箱
    "auth": {
        "user": "***@163.com", //邮箱服务器账号
        "pass": "*****"        //邮箱服务器密码
    }
  }
}
```