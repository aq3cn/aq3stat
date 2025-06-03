# aq3stat 快速开始指南

## 🚀 快速部署

### 方法一：使用PowerShell脚本（推荐Windows用户）

```powershell
# 在项目根目录执行
powershell -ExecutionPolicy Bypass -File scripts\deploy.ps1 -Env development -SkipDb
```

### 方法二：手动部署（适用于所有环境）

#### 1. 检查系统要求

确保已安装以下软件：
- Go 1.18+
- Node.js 14+
- MySQL 5.7+

#### 2. 安装Go依赖

```bash
go mod download
```

#### 3. 配置环境变量

创建 `configs/.env` 文件：

```env
ENV=development
SERVER_PORT=8080
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=aq3stat
JWT_SECRET=aq3stat_development_secret_key
JWT_EXPIRATION=24h
LOG_LEVEL=info
CORS_ORIGINS=*
RATE_LIMIT=100
```

#### 4. 初始化数据库

```sql
-- 创建数据库
CREATE DATABASE aq3stat CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 导入数据结构
mysql -u root -p aq3stat < migrations/aq3stat.sql
```

#### 5. 启动后端服务

```bash
go run cmd/api/main.go
```

#### 6. 安装前端依赖（可选）

```bash
cd web
npm install
npm run serve
```

## 🌐 访问系统

- **后端API**: http://localhost:8080/api
- **前端界面**: http://localhost:8080 (如果启动了前端)
- **健康检查**: http://localhost:8080/api/health

## 👤 默认账号

- **用户名**: admin
- **密码**: admin123

> ⚠️ **重要**: 首次登录后请立即修改默认密码！

## 📊 测试统计功能

### 1. 创建网站

登录后台，添加要统计的网站。

### 2. 获取统计代码

```javascript
// 在网站页面中添加以下代码
<script src="http://localhost:8080/counter.js?id=1"></script>
```

### 3. 查看统计数据

访问后台查看实时统计数据。

## 🔧 常见问题

### 问题1：端口被占用

```bash
# 检查端口占用
netstat -ano | findstr :8080

# 修改端口
# 在.env文件中修改SERVER_PORT=8081
```

### 问题2：数据库连接失败

```bash
# 检查MySQL服务
net start mysql

# 测试连接
mysql -u root -p
```

### 问题3：Go依赖下载失败

```bash
# 设置Go代理
go env -w GOPROXY=https://goproxy.cn,direct
go mod download
```

## 📚 更多文档

- [完整部署指南](docs/deployment-guide.md)
- [API文档](docs/api.md)
- [开发指南](docs/development.md)

## 🆘 获取帮助

如果遇到问题，请：

1. 查看 [常见问题](docs/faq.md)
2. 提交 [GitHub Issue](https://github.com/your-org/aq3stat/issues)
3. 联系技术支持

---

**祝您使用愉快！** 🎉
