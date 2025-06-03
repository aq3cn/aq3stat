# aq3stat网站统计系统部署说明

## 📋 快速开始

aq3stat是一个现代化的网站访问统计系统，提供实时数据收集、分析和可视化功能。

### 🚀 一键部署

### Ubuntu 22.04 快速部署

```bash
# 1. 测试系统环境
chmod +x scripts/test-deployment.sh
./scripts/test-deployment.sh

# 2. 安装MySQL（如果需要）
chmod +x scripts/install-mysql.sh
./scripts/install-mysql.sh

# 3. 部署应用
chmod +x scripts/deploy.sh
source ~/.aq3stat_db_config  # 加载数据库配置
./scripts/deploy.sh --env development --db-password "$DB_PASSWORD"
```

### 其他环境部署

```bash
# 开发环境部署（跳过数据库）
./scripts/deploy.sh --env development --skip-db

# 生产环境部署
./scripts/deploy.sh --env production --domain your-domain.com --db-password your_password

# Docker部署
docker-compose up -d
```

## 📚 详细文档

完整的部署文档请参考：[docs/deployment-guide.md](docs/deployment-guide.md)

## 🛠️ 部署方式

### 1. 传统部署

适用于直接在服务器上部署的场景：

- **开发环境**：本地开发和测试
- **生产环境**：生产服务器部署

### 2. Docker部署

适用于容器化部署的场景：

```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

## 📁 项目结构

```
aq3stat/
├── cmd/api/                 # 应用程序入口
├── internal/                # 内部业务逻辑
│   ├── api/                # API控制器
│   ├── middleware/         # 中间件
│   ├── model/              # 数据模型
│   ├── repository/         # 数据访问层
│   └── service/            # 业务逻辑层
├── pkg/                     # 公共包
├── web/                     # 前端Vue.js应用
├── configs/                 # 配置文件
├── migrations/              # 数据库迁移
├── scripts/                 # 部署脚本
├── docs/                    # 文档
├── docker-compose.yml       # Docker编排文件
├── Dockerfile.backend       # 后端Docker文件
└── README-DEPLOYMENT.md     # 部署说明
```

## ⚙️ 系统要求

### 硬件要求

| 环境 | CPU | 内存 | 存储 |
|------|-----|------|------|
| 开发环境 | 2核+ | 4GB+ | 20GB+ |
| 生产环境 | 4核+ | 8GB+ | 50GB+ |

### 软件要求

- **Go**: 1.18+
- **Node.js**: 14+
- **MySQL**: 5.7+ 或 MariaDB 10.5+
- **Nginx**: 1.18+ (生产环境)
- **Docker**: 20.10+ (Docker部署)

## 🔧 配置说明

### 环境变量

主要配置文件：`configs/.env`

```env
# 应用配置
ENV=production
SERVER_PORT=8080

# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_USER=aq3stat
DB_PASSWORD=your_password
DB_NAME=aq3stat

# JWT配置
JWT_SECRET=your_jwt_secret
JWT_EXPIRATION=24h
```

### 数据库配置

1. 创建数据库：
```sql
CREATE DATABASE aq3stat CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. 初始化数据：
```bash
./scripts/init_db.sh -h localhost -u root -p password -d aq3stat
```

## 🌐 访问系统

### 默认访问地址

- **开发环境**: http://localhost:8080
- **生产环境**: https://your-domain.com

- 登录界面
  <img src="https://github.com/aq3cn/aq3stat/raw/main/docs/images/aq3stat-denglu.png"></img>

- 前台首页
  <img src="https://github.com/aq3cn/aq3stat/raw/main/docs/images/aq3stat-qt.png"></img>

- 后台首页
  <img src="https://github.com/aq3cn/aq3stat/raw/main/docs/images/aq3stat-ht.png"></img>


### 默认管理员账号

- **用户名**: admin
- **密码**: admin123

> ⚠️ **重要**: 首次登录后请立即修改默认密码！

## 📊 功能特性

- ✅ 实时访问数据收集
- ✅ 地理位置和设备信息统计
- ✅ 搜索引擎来源分析
- ✅ 用户权限管理
- ✅ 数据可视化展示
- ✅ RESTful API接口
- ✅ 响应式前端界面

## 🔍 监控与维护

### 服务状态检查

```bash
# 检查后端服务
curl http://localhost:8080/api/health

# 检查系统服务状态
sudo systemctl status aq3stat
sudo systemctl status nginx
sudo systemctl status mysql
```

### 日志查看

```bash
# 应用日志
sudo tail -f /var/log/aq3stat/app.log

# Nginx日志
sudo tail -f /var/log/nginx/aq3stat_access.log
sudo tail -f /var/log/nginx/aq3stat_error.log

# 系统日志
sudo journalctl -u aq3stat -f
```

### 数据备份

```bash
# 手动备份
./scripts/backup.sh

# 设置自动备份
sudo crontab -e
# 添加：0 2 * * * /opt/aq3stat/scripts/backup.sh
```

## 🚨 故障排查

### 常见问题

1. **服务无法启动**
   - 检查端口是否被占用
   - 验证数据库连接
   - 查看错误日志

2. **数据库连接失败**
   - 检查MySQL服务状态
   - 验证数据库凭据
   - 确认防火墙设置

3. **前端页面无法访问**
   - 检查Nginx配置
   - 验证后端服务状态
   - 查看浏览器控制台错误

### 获取帮助

- **项目文档**: [docs/](docs/)
- **问题反馈**: GitHub Issues
- **技术支持**: support@your-domain.com

## 🔄 更新升级

### 更新到最新版本

```bash
# 拉取最新代码
git pull origin main

# 重新构建
./scripts/deploy.sh --env production --skip-deps

# 重启服务
sudo systemctl restart aq3stat
```

### 数据库迁移

```bash
# 备份数据库
./scripts/backup.sh

# 运行迁移
go run migrations/migrate.go
```

## 📝 开发指南

### 本地开发环境

```bash
# 1. 克隆项目
git clone https://github.com/your-org/aq3stat.git
cd aq3stat

# 2. 安装依赖
go mod download
cd web && npm install && cd ..

# 3. 配置环境
cp configs/.env.example configs/.env
# 编辑 .env 文件

# 4. 初始化数据库
./scripts/init_db.sh

# 5. 启动服务
# 后端
go run cmd/api/main.go

# 前端（新终端）
cd web && npm run serve
```

### 代码贡献

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 📄 许可证

本项目采用 Apache-2.0 license 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

感谢所有为aq3stat项目做出贡献的开发者！

---

**注意事项**：
- 生产环境部署前请务必在测试环境验证
- 定期备份数据库和配置文件
- 及时更新系统和依赖包
- 遵循安全最佳实践
