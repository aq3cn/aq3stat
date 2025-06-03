#!/bin/bash

# aq3stat部署测试脚本

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
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 测试系统要求
test_requirements() {
    log "测试系统要求..."
    
    local all_good=true
    
    # 检查Go
    if command -v go &> /dev/null; then
        local go_version=$(go version | awk '{print $3}')
        info "✅ Go: $go_version"
    else
        error "❌ Go未安装"
        all_good=false
    fi
    
    # 检查Node.js
    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        info "✅ Node.js: $node_version"
    else
        warn "⚠️  Node.js未安装（前端需要）"
    fi
    
    # 检查npm
    if command -v npm &> /dev/null; then
        local npm_version=$(npm --version)
        info "✅ npm: v$npm_version"
    else
        warn "⚠️  npm未安装（前端需要）"
    fi
    
    # 检查MySQL
    if command -v mysql &> /dev/null; then
        local mysql_version=$(mysql --version | awk '{print $3}')
        info "✅ MySQL客户端: $mysql_version"
    else
        warn "⚠️  MySQL客户端未安装"
    fi
    
    # 检查MySQL服务
    if systemctl is-active --quiet mysql 2>/dev/null; then
        info "✅ MySQL服务运行中"
    else
        warn "⚠️  MySQL服务未运行"
    fi
    
    if [[ "$all_good" == true ]]; then
        log "系统要求检查通过"
    else
        error "系统要求检查失败，请安装缺失的组件"
        return 1
    fi
}

# 测试项目结构
test_project_structure() {
    log "测试项目结构..."
    
    cd "$PROJECT_DIR"
    
    local required_files=(
        "go.mod"
        "cmd/api/main.go"
        "web/package.json"
        "migrations/aq3stat.sql"
        "scripts/deploy.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            info "✅ $file"
        else
            error "❌ 缺少文件: $file"
            return 1
        fi
    done
    
    log "项目结构检查通过"
}

# 测试Go依赖
test_go_dependencies() {
    log "测试Go依赖..."
    
    cd "$PROJECT_DIR"
    
    if go mod verify &>/dev/null; then
        info "✅ Go模块验证通过"
    else
        warn "⚠️  Go模块验证失败，尝试下载依赖..."
        go mod download
    fi
    
    if go mod tidy &>/dev/null; then
        info "✅ Go依赖整理完成"
    else
        error "❌ Go依赖整理失败"
        return 1
    fi
}

# 测试数据库连接
test_database_connection() {
    log "测试数据库连接..."
    
    # 检查是否有数据库配置文件
    if [[ -f "$HOME/.aq3stat_db_config" ]]; then
        source "$HOME/.aq3stat_db_config"
        info "使用配置文件: ~/.aq3stat_db_config"
    else
        # 使用默认配置
        DB_HOST="localhost"
        DB_PORT="3306"
        DB_USER="root"
        DB_PASSWORD=""
        DB_NAME="aq3stat"
        warn "使用默认数据库配置"
    fi
    
    # 构建连接参数
    local mysql_args="-h $DB_HOST -P $DB_PORT -u $DB_USER"
    if [[ -n "$DB_PASSWORD" ]]; then
        mysql_args="$mysql_args -p$DB_PASSWORD"
    fi
    
    # 测试连接
    if eval "mysql $mysql_args -e 'SELECT 1'" &>/dev/null; then
        info "✅ 数据库连接成功"
        
        # 检查数据库是否存在
        if eval "mysql $mysql_args -e 'USE $DB_NAME'" &>/dev/null; then
            info "✅ 数据库 $DB_NAME 存在"
        else
            warn "⚠️  数据库 $DB_NAME 不存在"
        fi
    else
        error "❌ 数据库连接失败"
        error "请运行: ./scripts/install-mysql.sh"
        return 1
    fi
}

# 测试构建
test_build() {
    log "测试应用构建..."
    
    cd "$PROJECT_DIR"
    
    # 测试后端构建
    if go build -o aq3stat-server-test cmd/api/main.go; then
        info "✅ 后端构建成功"
        rm -f aq3stat-server-test
    else
        error "❌ 后端构建失败"
        return 1
    fi
    
    # 测试前端构建（如果Node.js可用）
    if command -v npm &> /dev/null; then
        cd web
        if [[ -f "package.json" ]]; then
            if npm install --silent &>/dev/null; then
                info "✅ 前端依赖安装成功"
            else
                warn "⚠️  前端依赖安装失败"
            fi
        fi
        cd ..
    fi
}

# 显示建议
show_recommendations() {
    log "部署建议："
    echo ""
    
    if ! command -v mysql &> /dev/null; then
        warn "建议运行MySQL安装脚本:"
        info "  ./scripts/install-mysql.sh"
        echo ""
    fi
    
    if ! command -v node &> /dev/null; then
        warn "建议安装Node.js（用于前端）:"
        info "  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"
        info "  sudo apt-get install -y nodejs"
        echo ""
    fi
    
    info "运行部署脚本:"
    if [[ -f "$HOME/.aq3stat_db_config" ]]; then
        source "$HOME/.aq3stat_db_config"
        info "  ./scripts/deploy.sh --env development --db-password '$DB_PASSWORD'"
    else
        info "  ./scripts/deploy.sh --env development"
    fi
    echo ""
    
    info "或跳过数据库初始化:"
    info "  ./scripts/deploy.sh --env development --skip-db"
}

# 主函数
main() {
    log "开始aq3stat部署测试..."
    echo ""
    
    local test_passed=true
    
    test_requirements || test_passed=false
    echo ""
    
    test_project_structure || test_passed=false
    echo ""
    
    test_go_dependencies || test_passed=false
    echo ""
    
    test_database_connection || test_passed=false
    echo ""
    
    test_build || test_passed=false
    echo ""
    
    if [[ "$test_passed" == true ]]; then
        log "🎉 所有测试通过！系统已准备好部署aq3stat"
    else
        warn "⚠️  部分测试失败，请根据上述提示解决问题"
    fi
    
    echo ""
    show_recommendations
}

# 执行主函数
main "$@"
