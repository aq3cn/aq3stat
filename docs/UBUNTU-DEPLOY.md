# aq3stat Ubuntu 22.04 部署指南

## 🚀 快速部署

### 方法一：一键部署（推荐）

```bash
# 1. 安装MySQL（如果未安装）
chmod +x scripts/install-mysql.sh
./scripts/install-mysql.sh

# 2. 使用生成的数据库密码部署
source ~/.aq3stat_db_config
chmod +x scripts/deploy.sh
./scripts/deploy.sh --env development --db-password "$DB_PASSWORD"
```

### 方法二：手动部署

#### 步骤1：安装系统依赖

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装基础依赖
sudo apt install -y curl wget git build-essential

# 安装Go语言
wget https://go.dev/dl/go1.20.5.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# 验证Go安装
go version

# 安装Node.js和npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证Node.js安装
node -v && npm -v
```

#### 步骤2：安装MySQL

```bash
# 安装MySQL服务器
sudo apt install -y mysql-server

# 启动MySQL服务
sudo systemctl start mysql
sudo systemctl enable mysql

# 安全配置MySQL
sudo mysql_secure_installation

# 创建数据库和用户
sudo mysql -e "CREATE DATABASE aq3stat CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER 'aq3stat'@'localhost' IDENTIFIED BY 'your_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON aq3stat.* TO 'aq3stat'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
```

#### 步骤3：部署应用

```bash
# 克隆项目（如果还没有）
git clone https://github.com/your-org/aq3stat.git
cd aq3stat

# 运行部署脚本
chmod +x scripts/deploy.sh
./scripts/deploy.sh --env development --db-password "your_password"
```

## 🔧 故障排查

### 问题1：MySQL连接失败

```bash
# 检查MySQL服务状态
sudo systemctl status mysql

# 如果服务未启动
sudo systemctl start mysql

# 测试连接
mysql -u aq3stat -p aq3stat
```

### 问题2：Go命令未找到

```bash
# 检查Go安装
which go

# 如果未找到，重新设置PATH
export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
```

### 问题3：Node.js未安装

```bash
# 安装Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证安装
node -v && npm -v
```

### 问题4：权限问题

```bash
# 给脚本执行权限
chmod +x scripts/*.sh

# 如果遇到sudo权限问题
sudo usermod -aG sudo $USER
# 然后重新登录
```

### 问题5：端口被占用

```bash
# 检查端口占用
sudo netstat -tlnp | grep :8080

# 杀死占用进程
sudo kill -9 <PID>

# 或者修改端口
./scripts/deploy.sh --env development --port 8081 --db-password "your_password"
```

## 📊 验证部署

### 检查服务状态

```bash
# 检查Go应用是否构建成功
ls -la aq3stat-server

# 手动启动后端测试
./aq3stat-server &

# 检查API健康状态
curl http://localhost:8080/api/health

# 检查前端构建
ls -la web/dist/
```

### 访问系统

- **API接口**: http://localhost:8080/api
- **前端页面**: http://localhost:8080
- **健康检查**: http://localhost:8080/api/health

### 默认账号

- **用户名**: admin
- **密码**: admin123

## 🚀 启动服务

### 开发环境

```bash
# 启动后端
go run cmd/api/main.go

# 启动前端（新终端）
cd web
npm run serve
```

### 生产环境

```bash
# 后台运行
nohup ./aq3stat-server > aq3stat.log 2>&1 &

# 或使用systemd服务
sudo cp configs/systemd/aq3stat.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable aq3stat
sudo systemctl start aq3stat
```

## 📝 配置文件

### 环境配置 (configs/.env)

```env
ENV=development
SERVER_PORT=8080
DB_HOST=localhost
DB_PORT=3306
DB_USER=aq3stat
DB_PASSWORD=your_password
DB_NAME=aq3stat
JWT_SECRET=your_jwt_secret
```

### 数据库配置

```bash
# 查看数据库配置
cat ~/.aq3stat_db_config

# 测试数据库连接
mysql -h localhost -u aq3stat -p aq3stat
```

## 🔒 安全建议

1. **修改默认密码**
   - 登录后立即修改admin密码

2. **数据库安全**
   - 使用强密码
   - 限制数据库访问权限

3. **防火墙配置**
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 8080/tcp
   sudo ufw enable
   ```

4. **SSL证书**（生产环境）
   ```bash
   sudo apt install certbot
   sudo certbot --nginx -d your-domain.com
   ```

## 📚 更多资源

- [完整部署文档](docs/deployment-guide.md)
- [API文档](docs/api.md)
- [开发指南](docs/development.md)
- [常见问题](docs/faq.md)

## 🆘 获取帮助

如果遇到问题：

1. 查看日志文件
2. 检查系统要求
3. 提交GitHub Issue
4. 联系技术支持

---

**部署成功后，请记得修改默认密码并定期备份数据！** 🎉
