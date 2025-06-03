#!/bin/bash

# aq3stat网站统计系统简化部署脚本
# 适用于Windows/Linux/macOS环境

set -e

# 脚本配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

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

# 显示帮助信息
show_help() {
    cat << EOF
aq3stat网站统计系统简化部署脚本

用法: $0 [选项]

选项:
  -e, --env ENV           部署环境 (development|production) [默认: development]
  -p, --port PORT         服务端口 [默认: 8080]
  --db-password PASS      数据库密码
  --skip-deps             跳过依赖安装
  --skip-build            跳过构建步骤
  --skip-db               跳过数据库初始化
  -h, --help              显示帮助信息

示例:
  # 开发环境部署
  $0 --env development

  # 生产环境部署
  $0 --env production --db-password mypassword

EOF
}

# 默认配置
ENV="development"
PORT="8080"
DB_PASSWORD=""
SKIP_DEPS=false
SKIP_BUILD=false
SKIP_DB=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--env)
            ENV="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        --db-password)
            DB_PASSWORD="$2"
            shift 2
            ;;
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --skip-db)
            SKIP_DB=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            error "未知选项: $1"
            ;;
    esac
done

# 检查系统要求
check_requirements() {
    log "检查系统要求..."
    
    # 检查必需的命令
    local required_commands=("git" "go" "node" "npm")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            error "缺少必需的命令: $cmd"
        fi
    done
    
    log "系统要求检查完成"
}

# 安装依赖
install_dependencies() {
    if [[ "$SKIP_DEPS" == true ]]; then
        log "跳过依赖安装"
        return
    fi
    
    log "安装依赖..."
    
    cd "$PROJECT_DIR"
    
    # 安装Go依赖
    log "安装Go依赖..."
    go mod download
    
    # 安装前端依赖
    log "安装前端依赖..."
    cd web
    npm install
    cd ..
    
    log "依赖安装完成"
}

# 配置环境变量
setup_environment() {
    log "配置环境变量..."
    
    local env_file="$PROJECT_DIR/configs/.env"
    
    # 创建基本的.env文件
    cat > "$env_file" << EOF
# aq3stat环境配置文件
ENV=$ENV
SERVER_PORT=$PORT
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=$DB_PASSWORD
DB_NAME=aq3stat
JWT_SECRET=aq3stat_$(date +%s)_${RANDOM:-1234}_secret_key
JWT_EXPIRATION=24h
LOG_LEVEL=info
LOG_FILE=
CORS_ORIGINS=*
RATE_LIMIT=100
EOF
    
    log "环境变量配置完成"
}

# 初始化数据库
setup_database() {
    if [[ "$SKIP_DB" == true ]]; then
        log "跳过数据库初始化"
        return
    fi
    
    log "初始化数据库..."
    
    # 检查数据库连接
    if command -v mysql &> /dev/null; then
        if mysql -u root -p"$DB_PASSWORD" -e "SELECT 1" &>/dev/null; then
            log "数据库连接正常"
            
            # 运行初始化脚本
            if [[ -f "$SCRIPT_DIR/init_db.sh" ]]; then
                "$SCRIPT_DIR/init_db.sh" -h localhost -P 3306 -u root -p "$DB_PASSWORD" -d aq3stat
            else
                warn "找不到数据库初始化脚本，请手动初始化数据库"
            fi
        else
            warn "无法连接到数据库，请检查MySQL服务和密码"
        fi
    else
        warn "未找到MySQL客户端，跳过数据库初始化"
    fi
    
    log "数据库初始化完成"
}

# 构建应用
build_application() {
    if [[ "$SKIP_BUILD" == true ]]; then
        log "跳过构建步骤"
        return
    fi
    
    log "构建应用..."
    
    cd "$PROJECT_DIR"
    
    # 构建后端
    log "构建后端..."
    go build -o aq3stat-server cmd/api/main.go
    
    # 构建前端
    log "构建前端..."
    cd web
    npm run build
    cd ..
    
    log "应用构建完成"
}

# 显示部署信息
show_deployment_info() {
    log "部署信息:"
    info "环境: $ENV"
    info "端口: $PORT"
    info "访问地址: http://localhost:$PORT"
    info "默认管理员账号: admin / admin123"
    warn "请及时修改默认密码！"
    
    if [[ "$ENV" == "development" ]]; then
        info ""
        info "启动开发服务器:"
        info "后端: go run cmd/api/main.go"
        info "前端: cd web && npm run serve"
    fi
}

# 主函数
main() {
    log "开始部署aq3stat网站统计系统..."
    log "部署环境: $ENV"
    
    check_requirements
    install_dependencies
    setup_environment
    setup_database
    build_application
    show_deployment_info
    
    log "🎉 aq3stat部署完成！"
}

# 执行主函数
main "$@"
