# Docker Compose 配置修复说明

## 🔧 修复的问题

### 1. 布尔值类型错误

**问题描述**:
```
ERROR: The Compose file './docker-compose.yml' is invalid because:
services.grafana.environment.GF_USERS_ALLOW_SIGN_UP contains false, which is an invalid type, it should be a string, number, or a null
```

**原因**: Docker Compose环境变量必须是字符串类型，不能使用布尔值

**修复方案**:
```yaml
# 修复前
GF_USERS_ALLOW_SIGN_UP: false
REDIS_ENABLED: true

# 修复后
GF_USERS_ALLOW_SIGN_UP: "false"
REDIS_ENABLED: "true"
```

### 2. 缺失配置文件

**问题描述**: docker-compose.yml引用了不存在的配置文件

**修复方案**: 创建了所有必需的配置文件
- `configs/mysql/my.cnf` - MySQL配置
- `configs/nginx/nginx.conf` - Nginx主配置
- `configs/nginx/default.conf` - Nginx站点配置
- `configs/redis/redis.conf` - Redis配置
- `configs/prometheus/prometheus.yml` - Prometheus配置
- `configs/grafana/provisioning/` - Grafana配置

## 🆕 新增文件

### 1. 简化的Docker Compose配置

**文件**: `docker-compose.simple.yml`

**特点**:
- 只包含核心服务（MySQL、后端、前端）
- 移除了复杂的监控组件
- 更适合开发和测试环境

**使用方法**:
```bash
docker-compose -f docker-compose.simple.yml up -d
```

### 2. Docker部署指南

**文件**: `DOCKER-DEPLOY.md`

**内容**:
- 详细的Docker部署步骤
- 环境变量配置说明
- 常用命令和故障排查
- 生产环境配置建议

### 3. Docker验证脚本

**文件**: `scripts/validate-docker.sh`

**功能**:
- 检查Docker环境
- 验证Compose配置语法
- 检查必需文件
- 提供部署建议

## 📋 配置文件详解

### MySQL配置 (`configs/mysql/my.cnf`)

```ini
# 字符集配置
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci

# 性能优化
innodb_buffer_pool_size=256M
query_cache_size=64M
max_connections=200
```

### Nginx配置 (`configs/nginx/`)

**主配置** (`nginx.conf`):
- Gzip压缩
- 安全头设置
- 性能优化

**站点配置** (`default.conf`):
- API代理配置
- 静态文件服务
- 跨域支持
- 统计代码和数据收集接口

### Redis配置 (`configs/redis/redis.conf`)

```conf
# 内存配置
maxmemory 256mb
maxmemory-policy allkeys-lru

# 持久化配置
appendonly yes
save 900 1
```

## 🚀 部署选项

### 选项1: 简化部署（推荐新手）

```bash
# 使用简化配置
docker-compose -f docker-compose.simple.yml up -d

# 服务包括：
# - MySQL数据库
# - Go后端应用
# - Nginx前端服务
```

### 选项2: 完整部署

```bash
# 使用完整配置
docker-compose up -d

# 额外包括：
# - Redis缓存
# - Prometheus监控
# - Grafana可视化
```

### 选项3: 监控部署

```bash
# 启动核心服务
docker-compose up -d

# 启动监控服务
docker-compose --profile monitoring up -d
```

## 🔍 验证部署

### 1. 运行验证脚本

```bash
chmod +x scripts/validate-docker.sh
./scripts/validate-docker.sh
```

### 2. 手动验证

```bash
# 检查配置语法
docker-compose config

# 检查简化配置
docker-compose -f docker-compose.simple.yml config

# 查看服务状态
docker-compose ps

# 测试健康检查
curl http://localhost/api/health
```

## 🛠️ 常见问题解决

### 1. 端口冲突

**问题**: 端口80、3306、8080被占用

**解决方案**:
```bash
# 创建.env文件自定义端口
echo "HTTP_PORT=8080" > .env
echo "MYSQL_PORT=3307" >> .env
echo "SERVER_PORT=8081" >> .env
```

### 2. 权限问题

**问题**: 容器无法写入日志或数据

**解决方案**:
```bash
# 创建必要的目录
mkdir -p logs uploads

# 设置权限
chmod 755 logs uploads
```

### 3. 镜像构建失败

**问题**: Dockerfile构建错误

**解决方案**:
```bash
# 清理缓存重新构建
docker-compose build --no-cache

# 单独构建服务
docker-compose build backend
docker-compose build frontend
```

### 4. 数据库初始化失败

**问题**: MySQL容器启动失败

**解决方案**:
```bash
# 检查SQL文件语法
mysql --help

# 查看MySQL日志
docker logs aq3stat-mysql

# 重新创建数据卷
docker-compose down -v
docker-compose up -d
```

## 📊 服务访问

部署成功后的访问地址：

| 服务 | 地址 | 说明 |
|------|------|------|
| 前端界面 | http://localhost | 主要用户界面 |
| API接口 | http://localhost/api | RESTful API |
| 健康检查 | http://localhost/api/health | 服务状态检查 |
| 统计代码 | http://localhost/counter.js?id=1 | 网站统计代码 |
| Grafana | http://localhost:3000 | 监控面板（完整部署） |
| Prometheus | http://localhost:9090 | 监控数据（完整部署） |

## 🔐 默认账号

- **aq3stat管理员**: admin / admin123
- **Grafana**: admin / admin
- **MySQL root**: root_password
- **MySQL aq3stat**: aq3stat_password

> ⚠️ **重要**: 生产环境请立即修改所有默认密码！

## 📈 性能优化建议

### 1. 生产环境配置

```yaml
# .env文件示例
MYSQL_ROOT_PASSWORD=your_secure_root_password
MYSQL_PASSWORD=your_secure_aq3stat_password
JWT_SECRET=your_very_secure_jwt_secret_key
GRAFANA_PASSWORD=your_secure_grafana_password
```

### 2. 资源限制

```yaml
# 在docker-compose.yml中添加
services:
  mysql:
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
```

### 3. 数据备份

```bash
# 定期备份脚本
docker exec aq3stat-mysql mysqldump -u aq3stat -p aq3stat > backup_$(date +%Y%m%d).sql
```

---

**修复总结**: 通过修复布尔值类型错误、补充配置文件、创建简化部署选项，Docker部署现在更加稳定和用户友好。
