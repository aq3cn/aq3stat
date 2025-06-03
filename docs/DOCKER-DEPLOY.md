# aq3stat Docker 部署指南

## 🐳 Docker 部署

### 前提条件

确保已安装以下软件：
- Docker 20.10+
- Docker Compose 2.0+

```bash
# 检查Docker版本
docker --version
docker-compose --version
```

### 快速部署

#### 方法一：使用简化配置（推荐）

```bash
# 1. 克隆项目
git clone https://github.com/your-org/aq3stat.git
cd aq3stat

# 2. 使用简化的Docker Compose配置
docker-compose -f docker-compose.simple.yml up -d

# 3. 查看服务状态
docker-compose -f docker-compose.simple.yml ps
```

#### 方法二：使用完整配置

```bash
# 1. 构建并启动所有服务
docker-compose up -d

# 2. 启动监控服务（可选）
docker-compose --profile monitoring up -d
```

### 环境变量配置

创建 `.env` 文件来自定义配置：

```env
# 数据库配置
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=aq3stat
MYSQL_USER=aq3stat
MYSQL_PASSWORD=secure_aq3stat_password

# 应用配置
ENV=production
SERVER_PORT=8080
JWT_SECRET=your_very_secure_jwt_secret

# 端口配置
HTTP_PORT=80
HTTPS_PORT=443
MYSQL_PORT=3306

# 监控配置（可选）
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin123
```

### 服务说明

#### 核心服务

1. **MySQL数据库** (`aq3stat-mysql`)
   - 端口：3306
   - 数据持久化：`mysql_data` 卷
   - 自动初始化数据库结构

2. **后端应用** (`aq3stat-backend`)
   - 端口：8080
   - 健康检查：`/api/health`
   - 日志：`app_logs` 卷

3. **前端服务** (`aq3stat-frontend`)
   - 端口：80
   - Nginx代理
   - 静态文件服务

#### 可选服务

4. **Redis缓存** (`aq3stat-redis`)
   - 端口：6379
   - 数据持久化：`redis_data` 卷

5. **Prometheus监控** (`aq3stat-prometheus`)
   - 端口：9090
   - 配置：`configs/prometheus/`

6. **Grafana可视化** (`aq3stat-grafana`)
   - 端口：3000
   - 默认账号：admin/admin

### 常用命令

#### 服务管理

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f [service_name]
```

#### 数据管理

```bash
# 备份数据库
docker exec aq3stat-mysql mysqldump -u aq3stat -p aq3stat > backup.sql

# 恢复数据库
docker exec -i aq3stat-mysql mysql -u aq3stat -p aq3stat < backup.sql

# 查看数据卷
docker volume ls | grep aq3stat
```

#### 调试命令

```bash
# 进入容器
docker exec -it aq3stat-backend /bin/sh
docker exec -it aq3stat-mysql mysql -u root -p

# 查看容器日志
docker logs aq3stat-backend
docker logs aq3stat-mysql

# 检查网络
docker network ls
docker network inspect aq3stat_aq3stat-network
```

### 访问服务

部署完成后，可以通过以下地址访问：

- **前端界面**: http://localhost
- **API接口**: http://localhost/api
- **健康检查**: http://localhost/api/health
- **统计代码**: http://localhost/counter.js?id=1
- **Grafana监控**: http://localhost:3000 (如果启用)
- **Prometheus**: http://localhost:9090 (如果启用)

### 默认账号

- **aq3stat管理员**: admin / admin123
- **Grafana**: admin / admin (可通过环境变量修改)

### 故障排查

#### 1. 服务启动失败

```bash
# 查看详细错误信息
docker-compose logs [service_name]

# 检查配置文件
docker-compose config

# 重新构建镜像
docker-compose build --no-cache
```

#### 2. 数据库连接问题

```bash
# 检查MySQL服务状态
docker-compose ps mysql

# 测试数据库连接
docker exec aq3stat-mysql mysql -u aq3stat -p -e "SELECT 1"

# 查看MySQL日志
docker logs aq3stat-mysql
```

#### 3. 前端无法访问

```bash
# 检查Nginx配置
docker exec aq3stat-frontend nginx -t

# 查看Nginx日志
docker logs aq3stat-frontend

# 检查后端连接
curl http://localhost/api/health
```

#### 4. 端口冲突

```bash
# 检查端口占用
netstat -tlnp | grep :80
netstat -tlnp | grep :3306

# 修改端口配置
# 编辑 .env 文件或 docker-compose.yml
```

### 生产环境配置

#### 1. 安全配置

```bash
# 修改默认密码
# 编辑 .env 文件，设置强密码

# 限制网络访问
# 修改 docker-compose.yml 中的端口映射
```

#### 2. 性能优化

```bash
# 调整MySQL配置
# 编辑 configs/mysql/my.cnf

# 调整Nginx配置
# 编辑 configs/nginx/nginx.conf
```

#### 3. 数据备份

```bash
# 设置定时备份
crontab -e
# 添加：0 2 * * * /path/to/backup-script.sh
```

### 更新升级

```bash
# 1. 备份数据
docker-compose exec mysql mysqldump -u aq3stat -p aq3stat > backup.sql

# 2. 停止服务
docker-compose down

# 3. 更新代码
git pull origin main

# 4. 重新构建
docker-compose build

# 5. 启动服务
docker-compose up -d
```

### 卸载清理

```bash
# 停止并删除容器
docker-compose down

# 删除数据卷（注意：会丢失数据）
docker-compose down -v

# 删除镜像
docker rmi $(docker images aq3stat* -q)

# 清理未使用的资源
docker system prune -a
```

---

**注意事项**：
1. 生产环境请修改默认密码
2. 定期备份数据库数据
3. 监控服务运行状态
4. 及时更新镜像版本
