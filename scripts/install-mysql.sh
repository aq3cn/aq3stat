#!/bin/bash

# MySQL安装和配置脚本 for Ubuntu 22.04

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
    exit 1
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "请不要使用root用户运行此脚本，使用sudo权限的普通用户即可"
    fi
}

# 检查系统版本
check_system() {
    log "检查系统版本..."
    
    if [[ ! -f /etc/os-release ]]; then
        error "无法检测系统版本"
    fi
    
    source /etc/os-release
    
    if [[ "$ID" != "ubuntu" ]]; then
        warn "此脚本专为Ubuntu设计，当前系统: $ID"
        read -r -p "是否继续? (y/n): " CONTINUE
        if [[ "$CONTINUE" != "y" && "$CONTINUE" != "Y" ]]; then
            exit 0
        fi
    fi
    
    info "系统: $PRETTY_NAME"
}

# 更新系统包
update_system() {
    log "更新系统包..."
    sudo apt update
    sudo apt upgrade -y
}

# 安装MySQL服务器
install_mysql_server() {
    log "安装MySQL服务器..."
    
    # 检查是否已安装
    if command -v mysql &> /dev/null; then
        warn "MySQL已安装，跳过安装步骤"
        return
    fi
    
    # 预配置MySQL安装
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password '
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password '
    
    # 安装MySQL
    sudo apt install -y mysql-server mysql-client
    
    log "MySQL服务器安装完成"
}

# 启动和启用MySQL服务
start_mysql_service() {
    log "启动MySQL服务..."
    
    sudo systemctl start mysql
    sudo systemctl enable mysql
    
    # 检查服务状态
    if sudo systemctl is-active --quiet mysql; then
        log "MySQL服务启动成功"
    else
        error "MySQL服务启动失败"
    fi
}

# 安全配置MySQL
secure_mysql() {
    log "配置MySQL安全设置..."
    
    # 创建安全配置脚本
    cat > /tmp/mysql_secure.sql << 'EOF'
-- 删除匿名用户
DELETE FROM mysql.user WHERE User='';

-- 删除测试数据库
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- 禁止root远程登录
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- 刷新权限
FLUSH PRIVILEGES;
EOF

    # 执行安全配置
    sudo mysql < /tmp/mysql_secure.sql
    rm -f /tmp/mysql_secure.sql
    
    log "MySQL安全配置完成"
}

# 创建aq3stat数据库和用户
create_aq3stat_database() {
    log "创建aq3stat数据库和用户..."
    
    # 生成随机密码
    aq3stat_PASSWORD=$(openssl rand -base64 12 2>/dev/null || echo "aq3stat123")
    
    # 创建数据库和用户
    cat > /tmp/aq3stat_setup.sql << EOF
-- 创建数据库
CREATE DATABASE IF NOT EXISTS aq3stat CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户
CREATE USER IF NOT EXISTS 'aq3stat'@'localhost' IDENTIFIED BY '$aq3stat_PASSWORD';

-- 授权
GRANT ALL PRIVILEGES ON aq3stat.* TO 'aq3stat'@'localhost';

-- 刷新权限
FLUSH PRIVILEGES;
EOF

    sudo mysql < /tmp/aq3stat_setup.sql
    rm -f /tmp/aq3stat_setup.sql
    
    # 保存数据库配置
    cat > ~/.aq3stat_db_config << EOF
# aq3stat数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_USER=aq3stat
DB_PASSWORD=$aq3stat_PASSWORD
DB_NAME=aq3stat
EOF

    chmod 600 ~/.aq3stat_db_config
    
    log "aq3stat数据库创建完成"
    info "数据库用户: aq3stat"
    info "数据库密码: $aq3stat_PASSWORD"
    info "配置已保存到: ~/.aq3stat_db_config"
}

# 测试数据库连接
test_connection() {
    log "测试数据库连接..."
    
    source ~/.aq3stat_db_config
    
    if mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" &>/dev/null; then
        log "数据库连接测试成功"
    else
        error "数据库连接测试失败"
    fi
}

# 显示完成信息
show_completion_info() {
    log "MySQL安装和配置完成！"
    echo ""
    info "MySQL服务状态: $(sudo systemctl is-active mysql)"
    info "MySQL版本: $(mysql --version)"
    echo ""
    info "aq3stat数据库信息:"
    source ~/.aq3stat_db_config
    info "  主机: $DB_HOST"
    info "  端口: $DB_PORT"
    info "  数据库: $DB_NAME"
    info "  用户: $DB_USER"
    info "  密码: $DB_PASSWORD"
    echo ""
    info "配置文件: ~/.aq3stat_db_config"
    echo ""
    warn "请妥善保管数据库密码！"
    echo ""
    info "现在可以运行aq3stat部署脚本:"
    info "  ./scripts/deploy.sh --env development --db-password '$DB_PASSWORD'"
}

# 主函数
main() {
    log "开始安装和配置MySQL..."
    
    check_root
    check_system
    update_system
    install_mysql_server
    start_mysql_service
    secure_mysql
    create_aq3stat_database
    test_connection
    show_completion_info
    
    log "🎉 MySQL安装配置完成！"
}

# 执行主函数
main "$@"
