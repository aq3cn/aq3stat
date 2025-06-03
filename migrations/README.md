# aq3stat 数据库初始化

本目录包含 aq3stat 网站统计系统的数据库初始化文件。

## 文件说明

- `aq3stat.sql`: 主数据库初始化脚本，包含表结构和初始数据
- `ip_data_sample.sql`: 示例IP地址库数据，仅供测试使用
- `README.md`: 本说明文件

## 初始化数据库

### 使用初始化脚本

我们提供了两个初始化脚本，分别适用于 Linux/macOS 和 Windows 系统。

#### Linux/macOS

```bash
# 进入脚本目录
cd scripts

# 添加执行权限
chmod +x init_db.sh

# 执行初始化脚本
./init_db.sh -h localhost -P 3306 -u root -p your_password -d aq3stat
```

#### Windows

```batch
# 进入脚本目录
cd scripts

# 执行初始化脚本
init_db.bat -h localhost -P 3306 -u root -p your_password -d aq3stat
```

### 手动初始化

如果您不想使用初始化脚本，也可以手动执行 SQL 文件：

```bash
# 创建数据库
mysql -h localhost -P 3306 -u root -p -e "CREATE DATABASE IF NOT EXISTS aq3stat DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 执行主初始化脚本
mysql -h localhost -P 3306 -u root -p aq3stat < aq3stat.sql

# 执行示例IP数据脚本（可选）
mysql -h localhost -P 3306 -u root -p aq3stat < ip_data_sample.sql
```

## 默认账号

初始化完成后，系统会创建一个默认管理员账号：

- 用户名: `admin`
- 密码: `admin123`

**重要提示**: 请在系统部署后立即修改默认管理员密码！

## IP地址库

`ip_data_sample.sql` 文件仅包含少量示例IP地址数据，仅供测试使用。在生产环境中，您应该导入完整的IP地址库。

您可以从以下网站获取完整的IP地址库：

1. 纯真IP库：http://www.cz88.net/
2. GeoIP：https://dev.maxmind.com/geoip/geoip2/geolite2/
3. IP2Location：https://lite.ip2location.com/

## 数据库结构

### 主要表

- `users`: 用户表
- `groups`: 用户组表
- `websites`: 网站表
- `stats`: 统计数据表
- `ip_data`: IP地址库表
- `emails`: 邮件表
- `email_configs`: 邮件配置表
- `search_engines`: 搜索引擎表

### 视图

- `stat_summary`: 统计数据汇总视图，提供网站访问统计的汇总信息
