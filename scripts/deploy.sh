#!/bin/bash

# aq3stat网站统计系统一键部署脚本
# 支持开发环境和生产环境部署

set -e

# 脚本配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="/tmp/aq3stat_deploy.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1" | tee -a "$LOG_FILE"
}

# 显示帮助信息
show_help() {
    cat << EOF
aq3stat网站统计系统部署脚本

用法: $0 [选项]

选项:
  -e, --env ENV           部署环境 (development|production|docker) [默认: development]
  -d, --domain DOMAIN     域名 (生产环境必需)
  -p, --port PORT         服务端口 [默认: 8080]
  --db-host HOST          数据库主机 [默认: localhost]
  --db-port PORT          数据库端口 [默认: 3306]
  --db-user USER          数据库用户 [默认: root]
  --db-password PASS      数据库密码
  --db-name NAME          数据库名称 [默认: aq3stat]
  --skip-deps             跳过依赖安装
  --skip-build            跳过构建步骤
  --skip-db               跳过数据库初始化
  -h, --help              显示帮助信息

示例:
  # 开发环境部署
  $0 --env development

  # 生产环境部署
  $0 --env production --domain aq3stat.example.com --db-password mypassword

  # Docker部署
  $0 --env docker

EOF
}

# 默认配置
ENV="development"
DOMAIN=""
PORT="8080"
DB_HOST="localhost"
DB_PORT="3306"
DB_USER="root"
DB_PASSWORD=""
DB_NAME="aq3stat"
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
        -d|--domain)
            DOMAIN="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        --db-host)
            DB_HOST="$2"
            shift 2
            ;;
        --db-port)
            DB_PORT="$2"
            shift 2
            ;;
        --db-user)
            DB_USER="$2"
            shift 2
            ;;
        --db-password)
            DB_PASSWORD="$2"
            shift 2
            ;;
        --db-name)
            DB_NAME="$2"
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

# 验证环境参数
if [[ ! "$ENV" =~ ^(development|production|docker)$ ]]; then
    error "无效的环境: $ENV. 支持的环境: development, production, docker"
fi

# 生产环境必须指定域名
if [[ "$ENV" == "production" && -z "$DOMAIN" ]]; then
    error "生产环境部署必须指定域名 (--domain)"
fi

# 检查系统要求
check_requirements() {
    log "检查系统要求..."

    # 检查操作系统
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        info "检测到Linux系统"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        info "检测到macOS系统"
    else
        warn "未测试的操作系统: $OSTYPE"
    fi

    # 检查必需的命令
    local required_commands=("git" "curl")

    if [[ "$ENV" != "docker" ]]; then
        required_commands+=("go" "node" "npm")
        if [[ "$ENV" == "production" ]]; then
            required_commands+=("nginx" "mysql")
        fi
    else
        required_commands+=("docker" "docker-compose")
    fi

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
    if [[ "$ENV" != "docker" ]]; then
        log "安装Go依赖..."
        go mod download

        # 安装前端依赖
        log "安装前端依赖..."
        cd web
        npm install
        cd ..
    fi

    log "依赖安装完成"
}

# 配置环境变量
setup_environment() {
    log "配置环境变量..."

    local env_file="$PROJECT_DIR/configs/.env"

    # 复制环境配置模板
    if [[ ! -f "$env_file" ]]; then
        if [[ -f "$PROJECT_DIR/configs/.env.example" ]]; then
            cp "$PROJECT_DIR/configs/.env.example" "$env_file"
        else
            # 创建基本的.env文件
            cat > "$env_file" << EOF
# aq3stat环境配置文件
ENV=development
SERVER_PORT=8080
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=aq3stat
JWT_SECRET=your_jwt_secret_change_in_production
JWT_EXPIRATION=24h
LOG_LEVEL=info
LOG_FILE=
CORS_ORIGINS=*
RATE_LIMIT=100
EOF
        fi
    fi

    # 使用更安全的方式更新配置
    update_env_var() {
        local key="$1"
        local value="$2"
        local file="$3"

        # 创建临时文件
        local temp_file="${file}.tmp"

        # 检查是否存在该配置项
        if grep -q "^${key}=" "$file"; then
            # 更新现有配置 - 使用awk避免sed的特殊字符问题
            awk -v key="$key" -v value="$value" '
                BEGIN { FS="="; OFS="=" }
                $1 == key { $2 = value; print; next }
                { print }
            ' "$file" > "$temp_file"
            mv "$temp_file" "$file"
        else
            # 添加新配置
            echo "${key}=${value}" >> "$file"
        fi
    }

    # 更新配置项
    update_env_var "ENV" "$ENV" "$env_file"
    update_env_var "SERVER_PORT" "$PORT" "$env_file"
    update_env_var "DB_HOST" "$DB_HOST" "$env_file"
    update_env_var "DB_PORT" "$DB_PORT" "$env_file"
    update_env_var "DB_USER" "$DB_USER" "$env_file"
    update_env_var "DB_NAME" "$DB_NAME" "$env_file"

    if [[ -n "$DB_PASSWORD" ]]; then
        update_env_var "DB_PASSWORD" "$DB_PASSWORD" "$env_file"
    fi

    # 生成JWT密钥
    if ! grep -q "JWT_SECRET=" "$env_file" || grep -q "your_jwt_secret" "$env_file"; then
        local jwt_secret
        if command -v openssl &> /dev/null; then
            jwt_secret=$(openssl rand -base64 32 2>/dev/null)
        fi

        # 如果openssl失败或不存在，生成一个简单的密钥
        if [[ -z "$jwt_secret" ]]; then
            local timestamp
            local random_num
            timestamp=$(date +%s)
            random_num=${RANDOM:-1234}
            jwt_secret="aq3stat_${timestamp}_${random_num}_secret_key"
        fi

        update_env_var "JWT_SECRET" "$jwt_secret" "$env_file"
    fi

    log "环境变量配置完成"
}

# 初始化数据库
setup_database() {
    if [[ "$SKIP_DB" == true ]]; then
        log "跳过数据库初始化"
        return
    fi

    log "初始化数据库..."

    if [[ "$ENV" != "docker" ]]; then
        # 检查MySQL是否安装
        if ! command -v mysql &> /dev/null; then
            warn "MySQL客户端未安装，跳过数据库初始化"
            warn "请手动安装MySQL并运行: sudo apt install mysql-client-core-8.0"
            return
        fi

        # 构建MySQL连接参数
        local mysql_args="-h $DB_HOST -P $DB_PORT -u $DB_USER"
        if [[ -n "$DB_PASSWORD" ]]; then
            mysql_args="$mysql_args -p$DB_PASSWORD"
        fi

        # 检查数据库连接
        log "检查数据库连接..."
        if ! eval "mysql $mysql_args -e 'SELECT 1'" &>/dev/null; then
            warn "无法连接到数据库，可能的原因："
            warn "1. MySQL服务未启动: sudo systemctl start mysql"
            warn "2. 数据库用户不存在或密码错误"
            warn "3. 数据库服务器未安装: sudo apt install mysql-server"
            warn ""
            warn "快速解决方案："
            warn "1. 运行MySQL安装脚本: ./scripts/install-mysql.sh"
            warn "2. 或手动安装MySQL: sudo apt install mysql-server"
            warn "3. 然后重新运行部署脚本"
            warn ""
            warn "跳过数据库初始化，请手动配置数据库"
            return
        fi

        log "数据库连接成功"

        # 检查数据库是否存在，不存在则创建
        if ! eval "mysql $mysql_args -e 'USE $DB_NAME'" &>/dev/null; then
            log "创建数据库: $DB_NAME"
            eval "mysql $mysql_args -e 'CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'" || {
                warn "创建数据库失败，请手动创建数据库"
                return
            }
        fi

        # 运行初始化脚本
        if [[ -f "$SCRIPT_DIR/init_db.sh" ]]; then
            log "运行数据库初始化脚本..."
            "$SCRIPT_DIR/init_db.sh" -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p "$DB_PASSWORD" -d "$DB_NAME"
        else
            warn "找不到数据库初始化脚本，请手动导入SQL文件"
        fi
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

    if [[ "$ENV" == "docker" ]]; then
        # Docker构建
        log "使用Docker构建..."
        docker-compose build
    else
        # 构建后端
        log "构建后端..."
        go build -o aq3stat-server cmd/api/main.go

        # 构建前端
        log "构建前端..."
        cd web
        npm run build
        cd ..
    fi

    log "应用构建完成"
}

# 部署应用
deploy_application() {
    log "部署应用..."

    if [[ "$ENV" == "docker" ]]; then
        # Docker部署
        log "启动Docker服务..."
        docker-compose up -d

        # 等待服务启动
        log "等待服务启动..."
        sleep 30

        # 检查服务状态
        docker-compose ps

    elif [[ "$ENV" == "production" ]]; then
        # 生产环境部署
        log "生产环境部署..."

        # 创建系统服务
        sudo cp "$SCRIPT_DIR/../configs/systemd/aq3stat.service" /etc/systemd/system/
        sudo systemctl daemon-reload
        sudo systemctl enable aq3stat
        sudo systemctl start aq3stat

        # 配置Nginx
        sudo cp "$SCRIPT_DIR/../configs/nginx/aq3stat.conf" /etc/nginx/sites-available/
        sudo ln -sf /etc/nginx/sites-available/aq3stat.conf /etc/nginx/sites-enabled/
        sudo nginx -t && sudo systemctl reload nginx

    else
        # 开发环境
        log "开发环境部署完成，可以手动启动服务:"
        info "后端: go run cmd/api/main.go"
        info "前端: cd web && npm run serve"
    fi

    log "应用部署完成"
}

# 验证部署
verify_deployment() {
    log "验证部署..."

    local base_url="http://localhost:$PORT"
    if [[ "$ENV" == "production" && -n "$DOMAIN" ]]; then
        base_url="https://$DOMAIN"
    fi

    # 检查健康状态
    if curl -f "$base_url/api/health" &>/dev/null; then
        log "✅ 后端服务运行正常"
    else
        warn "❌ 后端服务可能未正常启动"
    fi

    # 检查前端
    if curl -f "$base_url/" &>/dev/null; then
        log "✅ 前端服务运行正常"
    else
        warn "❌ 前端服务可能未正常启动"
    fi

    log "部署验证完成"
}

# 显示部署信息
show_deployment_info() {
    log "部署信息:"
    info "环境: $ENV"
    info "端口: $PORT"
    info "数据库: $DB_HOST:$DB_PORT/$DB_NAME"

    if [[ "$ENV" == "production" && -n "$DOMAIN" ]]; then
        info "访问地址: https://$DOMAIN"
    else
        info "访问地址: http://localhost:$PORT"
    fi

    info "默认管理员账号: admin / admin123"
    warn "请及时修改默认密码！"

    log "部署日志保存在: $LOG_FILE"
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
    deploy_application
    verify_deployment
    show_deployment_info

    log "🎉 aq3stat部署完成！"
}

# 执行主函数
main "$@"
