# aq3stat网站统计系统部署指南

本文档详细说明了aq3stat网站统计系统在开发环境和生产环境中的完整部署流程。

## 📋 目录

- [系统概述](#系统概述)
- [系统要求](#系统要求)
- [开发环境部署](#开发环境部署)
- [生产环境部署](#生产环境部署)
- [Docker部署](#docker部署)
- [系统配置](#系统配置)
- [监控与维护](#监控与维护)
- [故障排查](#故障排查)

## 🎯 系统概述

aq3stat是一个现代化的网站访问统计系统，提供以下核心功能：

- 📊 实时访问数据收集和分析
- 🌍 地理位置和设备信息统计
- 🔍 搜索引擎来源分析
- 👥 用户权限管理
- 📈 数据可视化展示
- 🔒 安全的JWT认证

**技术栈：**
- 后端：Go + Gin + GORM + MySQL
- 前端：Vue.js + Element UI + ECharts
- 数据库：MySQL 5.7+
- Web服务器：Nginx（生产环境）

## 💻 系统要求

### 硬件要求

| 环境 | CPU | 内存 | 存储 | 网络 |
|------|-----|------|------|------|
| 开发环境 | 2核+ | 4GB+ | 20GB+ | 10Mbps+ |
| 生产环境（小型） | 2核+ | 8GB+ | 50GB+ | 100Mbps+ |
| 生产环境（中型） | 4核+ | 16GB+ | 200GB+ | 1Gbps+ |
| 生产环境（大型） | 8核+ | 32GB+ | 500GB+ | 1Gbps+ |

### 软件要求

| 软件 | 版本要求 | 说明 |
|------|----------|------|
| 操作系统 | Ubuntu 20.04+, CentOS 8+, Windows Server 2019+ | 推荐Linux |
| Go | 1.18+ | 后端运行环境 |
| Node.js | 14+ | 前端构建环境 |
| MySQL | 5.7+ 或 MariaDB 10.5+ | 数据存储 |
| Nginx | 1.18+ | Web服务器（生产环境） |
| Git | 2.0+ | 代码管理 |

## 🚀 开发环境部署

### 步骤1：环境准备

#### 1.1 安装Go语言环境

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install golang-go

# CentOS/RHEL
sudo dnf install golang

# macOS
brew install go

# 验证安装
go version
```

#### 1.2 安装Node.js和npm

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# CentOS/RHEL
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs

# macOS
brew install node

# 验证安装
node -v && npm -v
```

#### 1.3 安装MySQL数据库

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install mysql-server
sudo mysql_secure_installation

# CentOS/RHEL
sudo dnf install mysql-server
sudo systemctl start mysqld
sudo systemctl enable mysqld
sudo mysql_secure_installation

# macOS
brew install mysql
brew services start mysql
```

### 步骤2：获取源代码

```bash
# 克隆项目仓库
git clone https://github.com/your-org/aq3stat.git
cd aq3stat

# 查看项目结构
tree -L 2
```

### 步骤3：后端配置

#### 3.1 安装Go依赖

```bash
# 下载依赖包
go mod download

# 验证依赖
go mod verify
```

#### 3.2 配置环境变量

```bash
# 复制环境配置模板
cp configs/.env.example configs/.env

# 编辑配置文件
vim configs/.env
```

**开发环境配置示例：**

```env
# 应用环境
ENV=development
SERVER_PORT=8080

# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=aq3stat

# JWT配置
JWT_SECRET=your_jwt_secret_key_for_development
JWT_EXPIRATION=24h

# 日志配置
LOG_LEVEL=debug
LOG_FILE=logs/app.log
```

### 步骤4：前端配置

```bash
# 进入前端目录
cd web

# 安装依赖
npm install

# 创建开发环境配置
cp .env.development.example .env.development.local
```

**前端开发配置示例：**

```env
# API基础URL
VUE_APP_API_BASE_URL=http://localhost:8080/api

# 应用标题
VUE_APP_TITLE=aq3stat开发环境

# 调试模式
VUE_APP_DEBUG=true
```

### 步骤5：数据库初始化

#### 5.1 创建数据库

```bash
mysql -u root -p -e "CREATE DATABASE aq3stat CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

#### 5.2 运行初始化脚本

```bash
# 使用自动化脚本
cd scripts
chmod +x init_db.sh
./init_db.sh -h localhost -P 3306 -u root -p your_password -d aq3stat

# 或手动执行SQL
mysql -u root -p aq3stat < ../migrations/aq3stat.sql
mysql -u root -p aq3stat < ../migrations/ip_data_sample.sql
```

### 步骤6：启动开发服务

#### 6.1 启动后端服务

```bash
# 在项目根目录
go run cmd/api/main.go

# 或使用热重载工具
go install github.com/cosmtrek/air@latest
air
```

#### 6.2 启动前端开发服务器

```bash
# 在web目录
npm run serve
```

### 步骤7：验证部署

1. **访问前端应用**：http://localhost:8080
2. **访问API文档**：http://localhost:8080/api/health
3. **默认管理员账号**：
   - 用户名：`admin`
   - 密码：`admin123`

## 🏭 生产环境部署

### 步骤1：服务器准备

#### 1.1 系统更新和基础软件安装

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y
sudo apt install -y nginx mysql-server golang nodejs npm git curl wget unzip

# CentOS/RHEL
sudo dnf update -y
sudo dnf install -y nginx mysql-server golang nodejs npm git curl wget unzip
```

#### 1.2 创建系统用户

```bash
# 创建专用用户
sudo useradd -r -s /bin/false aq3stat
sudo mkdir -p /opt/aq3stat
sudo chown aq3stat:aq3stat /opt/aq3stat
```

### 步骤2：部署应用代码

#### 2.1 获取源代码

```bash
# 切换到部署目录
cd /opt/aq3stat

# 克隆代码（使用生产分支）
sudo -u aq3stat git clone -b main https://github.com/your-org/aq3stat.git .
```

#### 2.2 编译后端应用

```bash
# 编译生产版本
sudo -u aq3stat go build -ldflags="-w -s" -o aq3stat-server cmd/api/main.go

# 设置执行权限
sudo chmod +x aq3stat-server
```

#### 2.3 构建前端应用

```bash
cd web

# 安装依赖
sudo -u aq3stat npm ci --only=production

# 构建生产版本
sudo -u aq3stat npm run build
```

### 步骤3：生产环境配置

#### 3.1 配置环境变量

```bash
# 创建生产环境配置
sudo -u aq3stat cp configs/.env.example configs/.env
sudo -u aq3stat vim configs/.env
```

**生产环境配置示例：**

```env
# 应用环境
ENV=production
SERVER_PORT=8080

# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_USER=aq3stat
DB_PASSWORD=your_secure_production_password
DB_NAME=aq3stat

# JWT配置
JWT_SECRET=your_very_secure_jwt_secret_key_for_production
JWT_EXPIRATION=24h

# 日志配置
LOG_LEVEL=info
LOG_FILE=/var/log/aq3stat/app.log

# 安全配置
CORS_ORIGINS=https://your-domain.com
RATE_LIMIT=100
```

### 步骤4：数据库配置

#### 4.1 创建生产数据库和用户

```bash
# 登录MySQL
sudo mysql

# 创建数据库
CREATE DATABASE aq3stat CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 创建专用用户
CREATE USER 'aq3stat'@'localhost' IDENTIFIED BY 'your_secure_production_password';
GRANT ALL PRIVILEGES ON aq3stat.* TO 'aq3stat'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### 4.2 初始化数据库

```bash
cd /opt/aq3stat/scripts
sudo -u aq3stat ./init_db.sh -h localhost -P 3306 -u aq3stat -p your_secure_production_password -d aq3stat
```

#### 4.3 数据库优化配置

```bash
# 编辑MySQL配置
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
```

**MySQL优化配置：**

```ini
[mysqld]
# 基础配置
max_connections = 200
innodb_buffer_pool_size = 2G
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2

# 查询缓存
query_cache_type = 1
query_cache_size = 128M

# 慢查询日志
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
```

### 步骤5：Nginx Web服务器配置

#### 5.1 创建Nginx配置文件

```bash
sudo vim /etc/nginx/sites-available/aq3stat
```

**Nginx配置内容：**

```nginx
# aq3stat网站统计系统Nginx配置
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    # 重定向到HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    # SSL证书配置
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # SSL安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # 安全头
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # 日志配置
    access_log /var/log/nginx/aq3stat_access.log;
    error_log /var/log/nginx/aq3stat_error.log;

    # 前端静态文件
    location / {
        root /opt/aq3stat/web/dist;
        try_files $uri $uri/ /index.html;

        # 静态资源缓存
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # API代理
    location /api {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        # 超时设置
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }

    # 统计代码生成
    location /counter.js {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # 缓存设置
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }

    # 数据收集接口
    location /collect {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # 禁用缓存
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }

    # 限制访问敏感文件
    location ~ /\. {
        deny all;
    }

    location ~ \.(sql|log|conf)$ {
        deny all;
    }
}
```

#### 5.2 启用站点配置

```bash
# 启用站点
sudo ln -s /etc/nginx/sites-available/aq3stat /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重载配置
sudo systemctl reload nginx
```

### 步骤6：系统服务配置

#### 6.1 创建systemd服务文件

```bash
sudo vim /etc/systemd/system/aq3stat.service
```

**服务配置内容：**

```ini
[Unit]
Description=aq3stat Website Statistics System
Documentation=https://github.com/your-org/aq3stat
After=network.target mysql.service
Wants=mysql.service

[Service]
Type=simple
User=aq3stat
Group=aq3stat
WorkingDirectory=/opt/aq3stat
ExecStart=/opt/aq3stat/aq3stat-server
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=30
Restart=on-failure
RestartSec=5
StartLimitInterval=60
StartLimitBurst=3

# 安全设置
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/aq3stat /var/log/aq3stat

# 环境变量
Environment=GIN_MODE=release

# 日志设置
StandardOutput=journal
StandardError=journal
SyslogIdentifier=aq3stat

[Install]
WantedBy=multi-user.target
```

#### 6.2 创建日志目录

```bash
sudo mkdir -p /var/log/aq3stat
sudo chown aq3stat:aq3stat /var/log/aq3stat
```

#### 6.3 启动和启用服务

```bash
# 重载systemd配置
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start aq3stat

# 设置开机自启
sudo systemctl enable aq3stat

# 检查服务状态
sudo systemctl status aq3stat
```

### 步骤7：SSL证书配置

#### 7.1 安装Certbot

```bash
# Ubuntu/Debian
sudo apt install certbot python3-certbot-nginx

# CentOS/RHEL
sudo dnf install certbot python3-certbot-nginx
```

#### 7.2 获取SSL证书

```bash
# 获取证书
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# 测试自动续期
sudo certbot renew --dry-run
```

### 步骤8：防火墙和安全配置

#### 8.1 配置防火墙

```bash
# Ubuntu/Debian (UFW)
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

#### 8.2 配置fail2ban

```bash
# 安装fail2ban
sudo apt install fail2ban  # Ubuntu/Debian
sudo dnf install fail2ban  # CentOS/RHEL

# 创建配置文件
sudo vim /etc/fail2ban/jail.local
```

**fail2ban配置：**

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true

[nginx-http-auth]
enabled = true

[nginx-limit-req]
enabled = true
```

## 🐳 Docker部署

### Docker Compose配置

创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'

services:
  # MySQL数据库
  mysql:
    image: mysql:8.0
    container_name: aq3stat-mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: aq3stat
      MYSQL_USER: aq3stat
      MYSQL_PASSWORD: aq3stat_password
    volumes:
      - mysql_data:/var/lib/mysql
      - ./migrations/aq3stat.sql:/docker-entrypoint-initdb.d/01-aq3stat.sql
      - ./migrations/ip_data_sample.sql:/docker-entrypoint-initdb.d/02-ip_data.sql
    ports:
      - "3306:3306"
    networks:
      - aq3stat-network

  # 后端应用
  backend:
    build:
      context: .
      dockerfile: Dockerfile.backend
    container_name: aq3stat-backend
    restart: unless-stopped
    environment:
      ENV: production
      DB_HOST: mysql
      DB_PORT: 3306
      DB_USER: aq3stat
      DB_PASSWORD: aq3stat_password
      DB_NAME: aq3stat
      JWT_SECRET: your_jwt_secret
    depends_on:
      - mysql
    ports:
      - "8080:8080"
    networks:
      - aq3stat-network

  # 前端应用
  frontend:
    build:
      context: ./web
      dockerfile: Dockerfile
    container_name: aq3stat-frontend
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend
    networks:
      - aq3stat-network

volumes:
  mysql_data:

networks:
  aq3stat-network:
    driver: bridge
```

### Docker部署命令

```bash
# 构建和启动服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

## ⚙️ 系统配置

### 环境变量配置详解

#### 后端环境变量

| 变量名 | 说明 | 默认值 | 示例 |
|--------|------|--------|------|
| `ENV` | 运行环境 | `development` | `production` |
| `SERVER_PORT` | 服务端口 | `8080` | `8080` |
| `DB_HOST` | 数据库主机 | `localhost` | `127.0.0.1` |
| `DB_PORT` | 数据库端口 | `3306` | `3306` |
| `DB_USER` | 数据库用户 | `root` | `aq3stat` |
| `DB_PASSWORD` | 数据库密码 | - | `secure_password` |
| `DB_NAME` | 数据库名称 | `aq3stat` | `aq3stat` |
| `JWT_SECRET` | JWT密钥 | - | `your_secret_key` |
| `JWT_EXPIRATION` | JWT过期时间 | `24h` | `24h` |
| `LOG_LEVEL` | 日志级别 | `info` | `debug/info/warn/error` |
| `LOG_FILE` | 日志文件路径 | - | `/var/log/aq3stat/app.log` |
| `CORS_ORIGINS` | 允许的跨域源 | `*` | `https://domain.com` |
| `RATE_LIMIT` | 请求频率限制 | `100` | `100` |

#### 前端环境变量

| 变量名 | 说明 | 默认值 | 示例 |
|--------|------|--------|------|
| `VUE_APP_API_BASE_URL` | API基础URL | `/api` | `https://api.domain.com` |
| `VUE_APP_TITLE` | 应用标题 | `aq3stat` | `网站统计系统` |
| `VUE_APP_DEBUG` | 调试模式 | `false` | `true` |

### 数据库配置优化

#### MySQL性能调优

```sql
-- 查看当前配置
SHOW VARIABLES LIKE 'innodb%';
SHOW VARIABLES LIKE 'max_connections';

-- 性能监控查询
SHOW PROCESSLIST;
SHOW ENGINE INNODB STATUS;

-- 慢查询分析
SELECT * FROM mysql.slow_log ORDER BY start_time DESC LIMIT 10;
```

#### 索引优化建议

```sql
-- 为统计表添加复合索引
CREATE INDEX idx_website_time ON stats(website_id, time);
CREATE INDEX idx_ip_time ON stats(ip, time);
CREATE INDEX idx_referer ON stats(base_referer);

-- 为IP数据表添加范围索引
CREATE INDEX idx_ip_range ON ip_data(start_ip, end_ip);
```

### 缓存配置

#### Redis缓存配置（可选）

```bash
# 安装Redis
sudo apt install redis-server  # Ubuntu/Debian
sudo dnf install redis         # CentOS/RHEL

# 配置Redis
sudo vim /etc/redis/redis.conf
```

**Redis配置示例：**

```conf
# 内存配置
maxmemory 1gb
maxmemory-policy allkeys-lru

# 持久化配置
save 900 1
save 300 10
save 60 10000

# 网络配置
bind 127.0.0.1
port 6379
```

## 📊 监控与维护

### 系统监控

#### 1. 服务状态监控

```bash
# 创建监控脚本
sudo vim /opt/aq3stat/scripts/monitor.sh
```

**监控脚本内容：**

```bash
#!/bin/bash

# aq3stat系统监控脚本
LOG_FILE="/var/log/aq3stat/monitor.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# 检查服务状态
check_service() {
    local service=$1
    if systemctl is-active --quiet $service; then
        echo "[$DATE] $service: 运行正常" >> $LOG_FILE
        return 0
    else
        echo "[$DATE] $service: 服务异常" >> $LOG_FILE
        # 发送告警邮件
        echo "$service服务异常，请检查" | mail -s "aq3stat服务告警" admin@domain.com
        return 1
    fi
}

# 检查数据库连接
check_database() {
    if mysql -u aq3stat -p$DB_PASSWORD -e "SELECT 1" aq3stat &>/dev/null; then
        echo "[$DATE] MySQL: 连接正常" >> $LOG_FILE
        return 0
    else
        echo "[$DATE] MySQL: 连接异常" >> $LOG_FILE
        return 1
    fi
}

# 检查磁盘空间
check_disk_space() {
    local usage=$(df /opt/aq3stat | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ $usage -gt 80 ]; then
        echo "[$DATE] 磁盘空间: 使用率${usage}%，空间不足" >> $LOG_FILE
        echo "磁盘空间使用率${usage}%，请及时清理" | mail -s "aq3stat磁盘告警" admin@domain.com
    else
        echo "[$DATE] 磁盘空间: 使用率${usage}%，正常" >> $LOG_FILE
    fi
}

# 执行检查
check_service aq3stat
check_service nginx
check_service mysql
check_database
check_disk_space
```

#### 2. 设置定时监控

```bash
# 添加到crontab
sudo crontab -e

# 每5分钟检查一次
*/5 * * * * /opt/aq3stat/scripts/monitor.sh
```

### 日志管理

#### 1. 日志轮转配置

```bash
sudo vim /etc/logrotate.d/aq3stat
```

**日志轮转配置：**

```conf
/var/log/aq3stat/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 aq3stat aq3stat
    postrotate
        systemctl reload aq3stat
    endscript
}
```

#### 2. 日志分析脚本

```bash
# 创建日志分析脚本
sudo vim /opt/aq3stat/scripts/log_analysis.sh
```

**日志分析脚本：**

```bash
#!/bin/bash

# 分析访问日志
echo "=== 今日访问统计 ==="
grep $(date '+%d/%b/%Y') /var/log/nginx/aq3stat_access.log | wc -l

echo "=== 热门页面 TOP 10 ==="
grep $(date '+%d/%b/%Y') /var/log/nginx/aq3stat_access.log | \
awk '{print $7}' | sort | uniq -c | sort -nr | head -10

echo "=== 错误日志 ==="
grep ERROR /var/log/aq3stat/app.log | tail -10
```

### 数据备份

#### 1. 数据库备份脚本

```bash
sudo vim /opt/aq3stat/scripts/backup.sh
```

**备份脚本内容：**

```bash
#!/bin/bash

# 数据库备份脚本
BACKUP_DIR="/opt/aq3stat/backups"
DATE=$(date '+%Y%m%d_%H%M%S')
DB_NAME="aq3stat"
DB_USER="aq3stat"
DB_PASSWORD="your_password"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 数据库备份
mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/aq3stat_$DATE.sql

# 压缩备份文件
gzip $BACKUP_DIR/aq3stat_$DATE.sql

# 删除7天前的备份
find $BACKUP_DIR -name "aq3stat_*.sql.gz" -mtime +7 -delete

echo "数据库备份完成: aq3stat_$DATE.sql.gz"
```

#### 2. 设置自动备份

```bash
# 添加到crontab
sudo crontab -e

# 每天凌晨2点备份
0 2 * * * /opt/aq3stat/scripts/backup.sh
```

### 性能优化

#### 1. 数据库性能优化

```sql
-- 分析慢查询
SELECT * FROM information_schema.processlist WHERE time > 10;

-- 优化统计查询
EXPLAIN SELECT COUNT(*) FROM stats WHERE website_id = 1 AND DATE(time) = CURDATE();

-- 创建分区表（大数据量时）
ALTER TABLE stats PARTITION BY RANGE (YEAR(time)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

#### 2. 应用性能优化

```bash
# Go应用性能分析
go tool pprof http://localhost:8080/debug/pprof/profile

# 内存使用分析
go tool pprof http://localhost:8080/debug/pprof/heap
```

## 🔧 故障排查

### 常见问题及解决方案

#### 1. 服务无法启动

**问题现象：**
```bash
sudo systemctl status aq3stat
# 显示：Failed to start aq3stat Website Statistics System
```

**排查步骤：**

```bash
# 1. 查看详细错误日志
sudo journalctl -u aq3stat -f

# 2. 检查配置文件
sudo -u aq3stat /opt/aq3stat/aq3stat-server --config-check

# 3. 检查端口占用
sudo netstat -tlnp | grep :8080

# 4. 检查文件权限
ls -la /opt/aq3stat/aq3stat-server

# 5. 手动启动测试
sudo -u aq3stat /opt/aq3stat/aq3stat-server
```

**常见解决方案：**
- 检查环境变量配置是否正确
- 确保数据库连接正常
- 验证文件权限设置
- 检查端口是否被占用

#### 2. 数据库连接失败

**问题现象：**
```
Error: failed to connect to database: dial tcp 127.0.0.1:3306: connect: connection refused
```

**排查步骤：**

```bash
# 1. 检查MySQL服务状态
sudo systemctl status mysql

# 2. 测试数据库连接
mysql -u aq3stat -p -h localhost aq3stat

# 3. 检查数据库配置
sudo cat /etc/mysql/mysql.conf.d/mysqld.cnf | grep bind-address

# 4. 查看MySQL错误日志
sudo tail -f /var/log/mysql/error.log
```

**解决方案：**
- 启动MySQL服务：`sudo systemctl start mysql`
- 检查数据库用户权限
- 验证数据库配置文件
- 确保防火墙允许数据库连接

#### 3. 前端页面无法访问

**问题现象：**
- 页面显示502 Bad Gateway
- 或者页面无法加载

**排查步骤：**

```bash
# 1. 检查Nginx状态
sudo systemctl status nginx

# 2. 测试Nginx配置
sudo nginx -t

# 3. 查看Nginx错误日志
sudo tail -f /var/log/nginx/error.log

# 4. 检查后端服务
curl http://localhost:8080/api/health

# 5. 检查前端文件
ls -la /opt/aq3stat/web/dist/
```

**解决方案：**
- 重启Nginx：`sudo systemctl restart nginx`
- 检查Nginx配置文件语法
- 确保后端服务正常运行
- 验证前端文件是否正确构建

#### 4. 统计数据收集异常

**问题现象：**
- 网站嵌入统计代码后无数据
- 统计数据不准确

**排查步骤：**

```bash
# 1. 检查统计代码生成
curl "http://your-domain.com/counter.js?id=1"

# 2. 测试数据收集接口
curl "http://your-domain.com/collect?id=1&ip=127.0.0.1"

# 3. 查看应用日志
sudo tail -f /var/log/aq3stat/app.log

# 4. 检查数据库记录
mysql -u aq3stat -p aq3stat -e "SELECT * FROM stats ORDER BY time DESC LIMIT 10;"
```

**解决方案：**
- 验证网站ID是否正确
- 检查跨域配置
- 确保数据收集接口正常
- 验证数据库写入权限

### 性能问题排查

#### 1. 响应速度慢

**排查工具：**

```bash
# 1. 系统资源监控
top
htop
iotop

# 2. 网络连接监控
ss -tulpn
netstat -an

# 3. 数据库性能分析
mysql -u aq3stat -p aq3stat -e "SHOW PROCESSLIST;"
mysql -u aq3stat -p aq3stat -e "SHOW ENGINE INNODB STATUS;"
```

#### 2. 内存使用过高

**排查步骤：**

```bash
# 1. 查看内存使用
free -h
ps aux --sort=-%mem | head

# 2. 分析Go应用内存
go tool pprof http://localhost:8080/debug/pprof/heap

# 3. 检查数据库缓存
mysql -u aq3stat -p aq3stat -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size';"
```

### 日志分析命令

```bash
# 查看实时日志
sudo tail -f /var/log/aq3stat/app.log

# 搜索错误日志
sudo grep -i error /var/log/aq3stat/app.log

# 分析访问模式
sudo awk '{print $1}' /var/log/nginx/aq3stat_access.log | sort | uniq -c | sort -nr

# 查看系统日志
sudo journalctl -u aq3stat --since "1 hour ago"
```

## 📞 技术支持

### 获取帮助

- **项目文档**：https://github.com/your-org/aq3stat/wiki
- **问题反馈**：https://github.com/your-org/aq3stat/issues
- **技术交流**：QQ群/微信群
- **邮件支持**：support@your-domain.com

### 版本更新

```bash
# 查看当前版本
/opt/aq3stat/aq3stat-server --version

# 更新到最新版本
cd /opt/aq3stat
git pull origin main
go build -o aq3stat-server cmd/api/main.go
sudo systemctl restart aq3stat
```

---

**注意事项：**
1. 生产环境部署前请务必在测试环境验证
2. 定期备份数据库和配置文件
3. 监控系统资源使用情况
4. 及时更新系统和依赖包
5. 遵循安全最佳实践

**部署完成后，请记得：**
- 修改默认管理员密码
- 配置SSL证书
- 设置监控告警
- 制定备份策略
- 建立运维文档
