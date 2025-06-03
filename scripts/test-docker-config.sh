#!/bin/bash

# Docker Compose配置测试脚本

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

# 测试Docker Compose配置
test_compose_config() {
    log "测试Docker Compose配置..."
    
    cd "$PROJECT_DIR"
    
    # 检查docker-compose.yml
    if [[ -f "docker-compose.yml" ]]; then
        info "测试 docker-compose.yml..."
        
        # 检查语法
        if command -v docker-compose &> /dev/null; then
            if docker-compose config > /dev/null 2>&1; then
                info "✅ docker-compose.yml 语法正确"
            else
                error "❌ docker-compose.yml 语法错误:"
                docker-compose config
                return 1
            fi
        elif docker compose version &> /dev/null 2>&1; then
            if docker compose config > /dev/null 2>&1; then
                info "✅ docker-compose.yml 语法正确"
            else
                error "❌ docker-compose.yml 语法错误:"
                docker compose config
                return 1
            fi
        else
            warn "Docker Compose未安装，跳过语法检查"
        fi
    else
        error "docker-compose.yml 文件不存在"
        return 1
    fi
    
    # 检查docker-compose.simple.yml
    if [[ -f "docker-compose.simple.yml" ]]; then
        info "测试 docker-compose.simple.yml..."
        
        if command -v docker-compose &> /dev/null; then
            if docker-compose -f docker-compose.simple.yml config > /dev/null 2>&1; then
                info "✅ docker-compose.simple.yml 语法正确"
            else
                error "❌ docker-compose.simple.yml 语法错误:"
                docker-compose -f docker-compose.simple.yml config
                return 1
            fi
        elif docker compose version &> /dev/null 2>&1; then
            if docker compose -f docker-compose.simple.yml config > /dev/null 2>&1; then
                info "✅ docker-compose.simple.yml 语法正确"
            else
                error "❌ docker-compose.simple.yml 语法错误:"
                docker compose -f docker-compose.simple.yml config
                return 1
            fi
        fi
    fi
}

# 检查必需文件
check_required_files() {
    log "检查必需文件..."
    
    local required_files=(
        "Dockerfile.backend"
        "web/Dockerfile"
        "migrations/aq3stat.sql"
        "configs/nginx/default.conf"
    )
    
    for file in "${required_files[@]}"; do
        if [[ -f "$PROJECT_DIR/$file" ]]; then
            info "✅ $file"
        else
            error "❌ $file 不存在"
            return 1
        fi
    done
}

# 显示配置信息
show_config_info() {
    log "Docker Compose配置信息:"
    
    cd "$PROJECT_DIR"
    
    if command -v docker-compose &> /dev/null; then
        echo ""
        info "主配置文件服务列表:"
        docker-compose config --services 2>/dev/null || echo "无法获取服务列表"
        
        echo ""
        info "简化配置文件服务列表:"
        docker-compose -f docker-compose.simple.yml config --services 2>/dev/null || echo "无法获取服务列表"
    elif docker compose version &> /dev/null 2>&1; then
        echo ""
        info "主配置文件服务列表:"
        docker compose config --services 2>/dev/null || echo "无法获取服务列表"
        
        echo ""
        info "简化配置文件服务列表:"
        docker compose -f docker-compose.simple.yml config --services 2>/dev/null || echo "无法获取服务列表"
    fi
}

# 显示部署建议
show_deployment_suggestions() {
    log "部署建议:"
    echo ""
    
    info "推荐使用简化配置进行部署:"
    info "  docker-compose -f docker-compose.simple.yml up -d"
    echo ""
    
    info "或使用主配置文件:"
    info "  docker-compose up -d"
    echo ""
    
    info "查看服务状态:"
    info "  docker-compose ps"
    echo ""
    
    info "查看日志:"
    info "  docker-compose logs -f"
    echo ""
    
    info "停止服务:"
    info "  docker-compose down"
}

# 主函数
main() {
    log "开始测试Docker Compose配置..."
    echo ""
    
    local test_passed=true
    
    test_compose_config || test_passed=false
    echo ""
    
    check_required_files || test_passed=false
    echo ""
    
    if [[ "$test_passed" == true ]]; then
        log "🎉 Docker Compose配置测试通过！"
    else
        error "⚠️  Docker Compose配置测试失败"
        return 1
    fi
    
    echo ""
    show_config_info
    echo ""
    show_deployment_suggestions
}

# 执行主函数
main "$@"
