@echo off
REM aq3stat 网站统计系统数据库初始化脚本 (Windows版)

REM 默认数据库配置
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=
set DB_NAME=aq3stat

REM 解析命令行参数
:parse_args
if "%~1"=="" goto :check_mysql
if "%~1"=="-h" (
    set DB_HOST=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--host" (
    set DB_HOST=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-P" (
    set DB_PORT=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--port" (
    set DB_PORT=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-u" (
    set DB_USER=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--user" (
    set DB_USER=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-p" (
    set DB_PASSWORD=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--password" (
    set DB_PASSWORD=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-d" (
    set DB_NAME=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--database" (
    set DB_NAME=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--help" (
    call :show_help
    exit /b 0
)
echo 未知选项: %~1
call :show_help
exit /b 1

:show_help
echo aq3stat 网站统计系统数据库初始化脚本 (Windows版)
echo.
echo 用法: %0 [选项]
echo.
echo 选项:
echo   -h, --host        数据库主机 (默认: localhost)
echo   -P, --port        数据库端口 (默认: 3306)
echo   -u, --user        数据库用户名 (默认: root)
echo   -p, --password    数据库密码 (默认: 空)
echo   -d, --database    数据库名称 (默认: aq3stat)
echo   --help            显示帮助信息
echo.
echo 示例:
echo   %0 -h localhost -P 3306 -u root -p password -d aq3stat
echo.
exit /b 0

:check_mysql
REM 检查mysql命令是否可用
where mysql >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo 错误: mysql命令不可用，请安装MySQL客户端
    exit /b 1
)

REM 构建MySQL连接参数
set MYSQL_ARGS=-h%DB_HOST% -P%DB_PORT% -u%DB_USER%
if not "%DB_PASSWORD%"=="" (
    set MYSQL_ARGS=%MYSQL_ARGS% -p%DB_PASSWORD%
)

REM 检查数据库连接
echo 正在检查数据库连接...
mysql %MYSQL_ARGS% -e "SELECT 1" >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo 错误: 无法连接到数据库，请检查连接参数
    exit /b 1
)

echo 数据库连接成功

REM 获取脚本所在目录
set SCRIPT_DIR=%~dp0
set MIGRATIONS_DIR=%SCRIPT_DIR%\..\migrations

REM 检查SQL文件是否存在
if not exist "%MIGRATIONS_DIR%\aq3stat.sql" (
    echo 错误: 找不到SQL文件: %MIGRATIONS_DIR%\aq3stat.sql
    exit /b 1
)

REM 执行数据库初始化
echo 正在初始化数据库...
mysql %MYSQL_ARGS% < "%MIGRATIONS_DIR%\aq3stat.sql"
if %ERRORLEVEL% neq 0 (
    echo 错误: 数据库初始化失败
    exit /b 1
)

echo 数据库初始化成功

REM 询问是否导入示例IP数据
set /p IMPORT_IP_DATA=是否导入示例IP数据? (y/n): 
if /i "%IMPORT_IP_DATA%"=="y" (
    if exist "%MIGRATIONS_DIR%\ip_data_sample.sql" (
        echo 正在导入示例IP数据...
        mysql %MYSQL_ARGS% < "%MIGRATIONS_DIR%\ip_data_sample.sql"
        if %ERRORLEVEL% neq 0 (
            echo 警告: 示例IP数据导入失败
        ) else (
            echo 示例IP数据导入成功
        )
    ) else (
        echo 警告: 找不到示例IP数据文件: %MIGRATIONS_DIR%\ip_data_sample.sql
    )
)

echo 数据库初始化完成
echo 默认管理员账号: admin
echo 默认管理员密码: admin123
echo.
echo 请记得修改默认管理员密码!

pause
