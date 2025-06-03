#!/bin/bash

# Docker配置验证脚本

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

# 检查Docker和Docker Compose
check_docker() {
    log "检查Docker环境..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker未安装，请先安装Docker"
        return 1
    fi
    
    local docker_version=$(docker --version)
    info "✅ $docker_version"
    
    # 检查Docker Compose
    if command -v docker-compose &> /dev/null; then
        local compose_version=$(docker-compose --version)
        info "✅ $compose_version"
    elif docker compose version &> /dev/null; then
        local compose_version=$(docker compose version)
        info "✅ Docker Compose (plugin): $compose_version"
    else
        error "Docker Compose未安装"
        return 1
    fi
    
    # 检查Docker服务状态
    if docker info &> /dev/null; then
        info "✅ Docker服务运行正常"
    else
        error "Docker服务未运行，请启动Docker"
        return 1
    fi
}

# 验证Docker Compose配置
validate_compose_config() {
    log "验证Docker Compose配置..."
    
    cd "$PROJECT_DIR"
    
    # 验证主配置文件
    if [[ -f "docker-compose.yml" ]]; then
        info "验证 docker-compose.yml..."
        if command -v docker-compose &> /dev/null; then
            if docker-compose config &> /dev/null; then
                info "✅ docker-compose.yml 配置有效"
            else
                error "❌ docker-compose.yml 配置无效"
                docker-compose config
                return 1
            fi
        elif docker compose version &> /dev/null; then
            if docker compose config &> /dev/null; then
                info "✅ docker-compose.yml 配置有效"
            else
                error "❌ docker-compose.yml 配置无效"
                docker compose config
                return 1
            fi
        fi
    else
        warn "docker-compose.yml 文件不存在"
    fi
    
    # 验证简化配置文件
    if [[ -f "docker-compose.simple.yml" ]]; then
        info "验证 docker-compose.simple.yml..."
        if command -v docker-compose &> /dev/null; then
            if docker-compose -f docker-compose.simple.yml config &> /dev/null; then
                info "✅ docker-compose.simple.yml 配置有效"
            else
                error "❌ docker-compose.simple.yml 配置无效"
                docker-compose -f docker-compose.simple.yml config
                return 1
            fi
        elif docker compose version &> /dev/null; then
            if docker compose -f docker-compose.simple.yml config &> /dev/null; then
                info "✅ docker-compose.simple.yml 配置有效"
            else
                error "❌ docker-compose.simple.yml 配置无效"
                docker compose -f docker-compose.simple.yml config
                return 1
            fi
        fi
    else
        warn "docker-compose.simple.yml 文件不存在"
    fi
}

# 检查必需的配置文件
check_config_files() {
    log "检查配置文件..."
    
    local config_files=(
        "configs/mysql/my.cnf"
        "configs/nginx/nginx.conf"
        "configs/nginx/default.conf"
        "configs/redis/redis.conf"
        "configs/prometheus/prometheus.yml"
        "configs/grafana/provisioning/datasources/prometheus.yml"
        "configs/grafana/provisioning/dashboards/dashboard.yml"
    )
    
    for file in "${config_files[@]}"; do
        if [[ -f "$PROJECT_DIR/$file" ]]; then
            info "✅ $file"
        else
            warn "⚠️  $file 不存在"
        fi
    done
}

# 检查Dockerfile
check_dockerfiles() {
    log "检查Dockerfile..."
    
    local dockerfiles=(
        "Dockerfile.backend"
        "web/Dockerfile"
    )
    
    for dockerfile in "${dockerfiles[@]}"; do
        if [[ -f "$PROJECT_DIR/$dockerfile" ]]; then
            info "✅ $dockerfile"
        else
            error "❌ $dockerfile 不存在"
            return 1
        fi
    done
}

# 检查数据库迁移文件
check_migrations() {
    log "检查数据库迁移文件..."
    
    if [[ -f "$PROJECT_DIR/migrations/aq3stat.sql" ]]; then
        info "✅ migrations/aq3stat.sql"
    else
        error "❌ migrations/aq3stat.sql 不存在"
        return 1
    fi
    
    if [[ -f "$PROJECT_DIR/migrations/ip_data_sample.sql" ]]; then
        info "✅ migrations/ip_data_sample.sql"
    else
        warn "⚠️  migrations/ip_data_sample.sql 不存在（可选）"
    fi
}

# 显示部署建议
show_deployment_suggestions() {
    log "Docker部署建议："
    echo ""
    
    info "快速部署命令："
    info "  # 使用简化配置（推荐）"
    info "  docker-compose -f docker-compose.simple.yml up -d"
    echo ""
    info "  # 使用完整配置"
    info "  docker-compose up -d"
    echo ""
    
    info "常用管理命令："
    info "  # 查看服务状态"
    info "  docker-compose ps"
    echo ""
    info "  # 查看日志"
    info "  docker-compose logs -f"
    echo ""
    info "  # 停止服务"
    info "  docker-compose down"
    echo ""
    
    info "访问地址："
    info "  前端: http://localhost"
    info "  API: http://localhost/api"
    info "  健康检查: http://localhost/api/health"
    echo ""
    
    warn "注意事项："
    warn "1. 首次启动可能需要较长时间下载镜像"
    warn "2. 确保端口80、3306、8080未被占用"
    warn "3. 生产环境请修改默认密码"
}

# 主函数
main() {
    log "开始验证Docker部署环境..."
    echo ""
    
    local validation_passed=true
    
    check_docker || validation_passed=false
    echo ""
    
    validate_compose_config || validation_passed=false
    echo ""
    
    check_config_files
    echo ""
    
    check_dockerfiles || validation_passed=false
    echo ""
    
    check_migrations || validation_passed=false
    echo ""
    
    if [[ "$validation_passed" == true ]]; then
        log "🎉 Docker环境验证通过！"
    else
        error "⚠️  Docker环境验证失败，请解决上述问题"
    fi
    
    echo ""
    show_deployment_suggestions
}

# 执行主函数
main "$@"
