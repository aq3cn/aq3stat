# aq3stat网站统计系统部署文档

本文档详细说明了aq3stat网站统计系统在开发环境和生产环境中的部署步骤。

## 目录

- [系统要求](#系统要求)
- [开发环境部署](#开发环境部署)
  - [准备工作](#准备工作)
  - [后端部署](#后端部署)
  - [前端部署](#前端部署)
  - [数据库初始化](#数据库初始化)
  - [运行系统](#运行系统)
  - [开发调试](#开发调试)
- [生产环境部署](#生产环境部署)
  - [服务器准备](#服务器准备)
  - [系统部署](#系统部署)
  - [数据库配置](#数据库配置)
  - [Web服务器配置](#web服务器配置)
  - [系统服务配置](#系统服务配置)
  - [SSL证书配置](#ssl证书配置)
  - [防火墙配置](#防火墙配置)
- [系统更新](#系统更新)
- [常见问题](#常见问题)

## 系统要求

### 硬件要求

- **开发环境**：
  - CPU: 双核及以上
  - 内存: 4GB及以上
  - 硬盘: 20GB及以上

- **生产环境**：
  - CPU: 四核及以上
  - 内存: 8GB及以上
  - 硬盘: 50GB及以上（根据预期流量和数据量调整）

### 软件要求

- **操作系统**：
  - Linux (推荐 Ubuntu 20.04/22.04 或 CentOS 8)
  - Windows Server 2016/2019/2022
  - macOS (仅用于开发)

- **软件环境**：
  - Go 1.18+
  - MySQL 5.7+ 或 MariaDB 10.5+
  - Node.js 14+
  - Nginx 1.18+ (生产环境)

## 开发环境部署

### 准备工作

1. **安装Go**：

   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install golang-go

   # CentOS/RHEL
   sudo yum install golang

   # macOS
   brew install go

   # Windows
   # 从 https://golang.org/dl/ 下载安装包
   ```

   验证安装：

   ```bash
   go version
   ```

2. **安装MySQL**：

   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install mysql-server

   # CentOS/RHEL
   sudo yum install mariadb-server
   sudo systemctl start mariadb
   sudo systemctl enable mariadb

   # macOS
   brew install mysql
   brew services start mysql

   # Windows
   # 从 https://dev.mysql.com/downloads/installer/ 下载安装包
   ```

   设置MySQL：

   ```bash
   sudo mysql_secure_installation
   ```

3. **安装Node.js和npm**：

   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install nodejs npm

   # CentOS/RHEL
   sudo yum install nodejs npm

   # macOS
   brew install node

   # Windows
   # 从 https://nodejs.org/en/download/ 下载安装包
   ```

   验证安装：

   ```bash
   node -v
   npm -v
   ```

### 后端部署

1. **克隆代码仓库**：

   ```bash
   git clone https://aq3stat.git
   cd aq3stat
   ```

2. **安装Go依赖**：

   ```bash
   go mod download
   ```

3. **配置环境变量**：

   复制示例环境配置文件：

   ```bash
   cp configs/.env.example configs/.env
   ```

   编辑 `.env` 文件，设置数据库连接信息和其他配置：

   ```bash
   # 使用你喜欢的编辑器
   vim configs/.env
   ```

### 前端部署

1. **进入前端目录**：

   ```bash
   cd web
   ```

2. **安装依赖**：

   ```bash
   npm install
   ```

3. **配置前端环境**：

   创建开发环境配置文件：

   ```bash
   cp .env.development.example .env.development.local
   ```

   编辑配置文件：

   ```bash
   # 使用你喜欢的编辑器
   vim .env.development.local
   ```

### 数据库初始化

1. **创建数据库**：

   ```bash
   mysql -u root -p -e "CREATE DATABASE aq3stat CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
   ```

2. **初始化数据库**：

   使用提供的脚本初始化数据库：

   ```bash
   # Linux/macOS
   cd scripts
   chmod +x init_db.sh
   ./init_db.sh -h localhost -P 3306 -u root -p your_password -d aq3stat

   # Windows
   cd scripts
   init_db.bat -h localhost -P 3306 -u root -p your_password -d aq3stat
   ```

   或者手动执行SQL文件：

   ```bash
   mysql -u root -p aq3stat < migrations/aq3stat.sql
   mysql -u root -p aq3stat < migrations/ip_data_sample.sql
   ```

### 运行系统

1. **启动后端服务**：

   ```bash
   # 在项目根目录下
   go run cmd/api/main.go
   ```

2. **启动前端开发服务器**：

   ```bash
   # 在web目录下
   npm run serve
   ```

3. **访问系统**：

   打开浏览器，访问 http://localhost:8080

   默认管理员账号：
   - 用户名：admin
   - 密码：admin123

### 开发调试

1. **后端API调试**：

   使用Postman或其他API测试工具访问 http://localhost:8080/api

2. **前端调试**：

   使用浏览器开发者工具进行调试

3. **日志查看**：

   ```bash
   # 查看后端日志
   tail -f logs/app.log
   ```

## 生产环境部署

### 服务器准备

1. **更新系统**：

   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt upgrade

   # CentOS/RHEL
   sudo yum update
   ```

2. **安装必要软件**：

   ```bash
   # Ubuntu/Debian
   sudo apt install nginx mysql-server golang nodejs npm git

   # CentOS/RHEL
   sudo yum install nginx mariadb-server golang nodejs npm git
   ```

3. **启动并启用服务**：

   ```bash
   sudo systemctl start nginx
   sudo systemctl enable nginx
   sudo systemctl start mysql
   sudo systemctl enable mysql
   ```

### 系统部署

1. **创建部署目录**：

   ```bash
   sudo mkdir -p /opt/aq3stat
   sudo chown $USER:$USER /opt/aq3stat
   ```

2. **克隆代码仓库**：

   ```bash
   git clone https://aq3stat.git /opt/aq3stat
   cd /opt/aq3stat
   ```

3. **编译后端**：

   ```bash
   go build -o aq3stat-server cmd/api/main.go
   ```

4. **构建前端**：

   ```bash
   cd web
   npm install
   npm run build
   ```

5. **配置环境变量**：

   ```bash
   cp configs/.env.example configs/.env
   # 编辑配置文件
   vim configs/.env
   ```

   设置生产环境配置：

   ```
   ENV=production
   SERVER_PORT=8080
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=aq3stat
   DB_PASSWORD=your_secure_password
   DB_NAME=aq3stat
   JWT_SECRET=your_jwt_secret_key
   JWT_EXPIRATION=24h
   ```

### 数据库配置

1. **创建数据库和用户**：

   ```bash
   sudo mysql -e "CREATE DATABASE aq3stat CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
   sudo mysql -e "CREATE USER 'aq3stat'@'localhost' IDENTIFIED BY 'your_secure_password';"
   sudo mysql -e "GRANT ALL PRIVILEGES ON aq3stat.* TO 'aq3stat'@'localhost';"
   sudo mysql -e "FLUSH PRIVILEGES;"
   ```

2. **初始化数据库**：

   ```bash
   cd /opt/aq3stat/scripts
   chmod +x init_db.sh
   ./init_db.sh -h localhost -P 3306 -u aq3stat -p your_secure_password -d aq3stat
   ```

### Web服务器配置

1. **配置Nginx**：

   创建Nginx配置文件：

   ```bash
   sudo vim /etc/nginx/sites-available/aq3stat
   ```

   添加以下内容：

   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           root /opt/aq3stat/web/dist;
           try_files $uri $uri/ /index.html;
       }

       location /api {
           proxy_pass http://localhost:8080;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }

       location /counter.js {
           proxy_pass http://localhost:8080;
           proxy_http_version 1.1;
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }

       location /collect {
           proxy_pass http://localhost:8080;
           proxy_http_version 1.1;
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

2. **启用站点配置**：

   ```bash
   sudo ln -s /etc/nginx/sites-available/aq3stat /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

### 系统服务配置

1. **创建系统服务**：

   ```bash
   sudo vim /etc/systemd/system/aq3stat.service
   ```

   添加以下内容：

   ```ini
   [Unit]
   Description=aq3stat Website Statistics System
   After=network.target mysql.service

   [Service]
   Type=simple
   User=www-data
   Group=www-data
   WorkingDirectory=/opt/aq3stat
   ExecStart=/opt/aq3stat/aq3stat-server
   Restart=on-failure
   RestartSec=5
   StandardOutput=syslog
   StandardError=syslog
   SyslogIdentifier=aq3stat

   [Install]
   WantedBy=multi-user.target
   ```

2. **设置权限**：

   ```bash
   sudo chown -R www-data:www-data /opt/aq3stat
   sudo chmod +x /opt/aq3stat/aq3stat-server
   ```

3. **启动服务**：

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start aq3stat
   sudo systemctl enable aq3stat
   ```

4. **检查服务状态**：

   ```bash
   sudo systemctl status aq3stat
   ```

### SSL证书配置

1. **安装Certbot**：

   ```bash
   # Ubuntu/Debian
   sudo apt install certbot python3-certbot-nginx

   # CentOS/RHEL
   sudo yum install certbot python3-certbot-nginx
   ```

2. **获取SSL证书**：

   ```bash
   sudo certbot --nginx -d your-domain.com
   ```

3. **配置自动续期**：

   ```bash
   sudo systemctl status certbot.timer
   ```

### 防火墙配置

1. **配置防火墙**：

   ```bash
   # Ubuntu/Debian with UFW
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw reload

   # CentOS/RHEL with firewalld
   sudo firewall-cmd --permanent --add-service=http
   sudo firewall-cmd --permanent --add-service=https
   sudo firewall-cmd --reload
   ```

## 系统更新

1. **拉取最新代码**：

   ```bash
   cd /opt/aq3stat
   git pull
   ```

2. **重新编译后端**：

   ```bash
   go build -o aq3stat-server cmd/api/main.go
   ```

3. **重新构建前端**：

   ```bash
   cd web
   npm install
   npm run build
   ```

4. **重启服务**：

   ```bash
   sudo systemctl restart aq3stat
   ```

## 常见问题

### 数据库连接失败

**问题**：系统无法连接到数据库。

**解决方案**：
1. 检查数据库服务是否运行：`sudo systemctl status mysql`
2. 验证数据库凭据是否正确
3. 确保数据库用户有正确的权限
4. 检查防火墙设置是否允许数据库连接

### 前端无法访问API

**问题**：前端页面加载，但无法获取数据。

**解决方案**：
1. 检查后端服务是否运行：`sudo systemctl status aq3stat`
2. 验证Nginx配置是否正确：`sudo nginx -t`
3. 检查浏览器控制台是否有CORS错误
4. 确保API路径配置正确

### 系统性能问题

**问题**：系统在高负载下响应缓慢。

**解决方案**：
1. 优化数据库索引
2. 增加服务器资源（CPU/内存）
3. 配置数据库连接池
4. 考虑使用Redis缓存热点数据
5. 对静态资源进行CDN加速

### 日志查看

**问题**：需要查看系统日志进行故障排查。

**解决方案**：
1. 查看应用日志：`sudo journalctl -u aq3stat`
2. 查看Nginx访问日志：`sudo tail -f /var/log/nginx/access.log`
3. 查看Nginx错误日志：`sudo tail -f /var/log/nginx/error.log`
4. 查看MySQL日志：`sudo tail -f /var/log/mysql/error.log`
