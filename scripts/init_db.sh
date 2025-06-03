#!/bin/bash

# aq3stat 网站统计系统数据库初始化脚本

# 默认数据库配置
DB_HOST="localhost"
DB_PORT="3306"
DB_USER="root"
DB_PASSWORD=""
DB_NAME="aq3stat"

# 显示帮助信息
show_help() {
    echo "aq3stat 网站统计系统数据库初始化脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --host        数据库主机 (默认: localhost)"
    echo "  -P, --port        数据库端口 (默认: 3306)"
    echo "  -u, --user        数据库用户名 (默认: root)"
    echo "  -p, --password    数据库密码 (默认: 空)"
    echo "  -d, --database    数据库名称 (默认: aq3stat)"
    echo "  --help            显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -h localhost -P 3306 -u root -p password -d aq3stat"
    echo ""
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--host)
            DB_HOST="$2"
            shift
            shift
            ;;
        -P|--port)
            DB_PORT="$2"
            shift
            shift
            ;;
        -u|--user)
            DB_USER="$2"
            shift
            shift
            ;;
        -p|--password)
            DB_PASSWORD="$2"
            shift
            shift
            ;;
        -d|--database)
            DB_NAME="$2"
            shift
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 检查mysql命令是否可用
if ! command -v mysql &> /dev/null; then
    echo "错误: mysql命令不可用，请安装MySQL客户端"
    exit 1
fi

# 构建MySQL连接参数
MYSQL_ARGS="-h$DB_HOST -P$DB_PORT -u$DB_USER"
if [ ! -z "$DB_PASSWORD" ]; then
    MYSQL_ARGS="$MYSQL_ARGS -p$DB_PASSWORD"
fi

# 检查数据库连接
echo "正在检查数据库连接..."
if ! eval "mysql $MYSQL_ARGS -e 'SELECT 1'" &> /dev/null; then
    echo "错误: 无法连接到数据库，请检查连接参数"
    echo "提示: 请确保MySQL服务已启动: sudo systemctl start mysql"
    echo "提示: 请检查用户名和密码是否正确"
    exit 1
fi

echo "数据库连接成功"

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIGRATIONS_DIR="$SCRIPT_DIR/../migrations"

# 检查SQL文件是否存在
if [ ! -f "$MIGRATIONS_DIR/aq3stat.sql" ]; then
    echo "错误: 找不到SQL文件: $MIGRATIONS_DIR/aq3stat.sql"
    exit 1
fi

# 执行数据库初始化
echo "正在初始化数据库..."
if ! eval "mysql $MYSQL_ARGS < '$MIGRATIONS_DIR/aq3stat.sql'"; then
    echo "错误: 数据库初始化失败"
    exit 1
fi

echo "数据库初始化成功"

# 询问是否导入示例IP数据
read -r -p "是否导入示例IP数据? (y/n): " IMPORT_IP_DATA
if [ "$IMPORT_IP_DATA" = "y" ] || [ "$IMPORT_IP_DATA" = "Y" ]; then
    if [ -f "$MIGRATIONS_DIR/ip_data_sample.sql" ]; then
        echo "正在导入示例IP数据..."
        if ! eval "mysql $MYSQL_ARGS < '$MIGRATIONS_DIR/ip_data_sample.sql'"; then
            echo "警告: 示例IP数据导入失败"
        else
            echo "示例IP数据导入成功"
        fi
    else
        echo "警告: 找不到示例IP数据文件: $MIGRATIONS_DIR/ip_data_sample.sql"
    fi
fi

echo "数据库初始化完成"
echo "默认管理员账号: admin"
echo "默认管理员密码: admin123"
echo ""
echo "请记得修改默认管理员密码!"
