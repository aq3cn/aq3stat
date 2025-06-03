@echo off
setlocal enabledelayedexpansion

REM aq3stat网站统计系统Windows部署脚本

echo [%date% %time%] 开始部署aq3stat网站统计系统...

REM 设置默认配置
set ENV=development
set PORT=8080
set DB_PASSWORD=
set SKIP_DEPS=false
set SKIP_BUILD=false
set SKIP_DB=false

REM 获取脚本目录
set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR%..

REM 解析命令行参数
:parse_args
if "%1"=="" goto end_parse
if "%1"=="--env" (
    set ENV=%2
    shift
    shift
    goto parse_args
)
if "%1"=="--port" (
    set PORT=%2
    shift
    shift
    goto parse_args
)
if "%1"=="--db-password" (
    set DB_PASSWORD=%2
    shift
    shift
    goto parse_args
)
if "%1"=="--skip-deps" (
    set SKIP_DEPS=true
    shift
    goto parse_args
)
if "%1"=="--skip-build" (
    set SKIP_BUILD=true
    shift
    goto parse_args
)
if "%1"=="--skip-db" (
    set SKIP_DB=true
    shift
    goto parse_args
)
if "%1"=="--help" (
    goto show_help
)
echo 未知选项: %1
goto show_help

:end_parse

echo [%date% %time%] 部署环境: %ENV%

REM 检查系统要求
echo [%date% %time%] 检查系统要求...

where go >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到Go命令，请安装Go语言环境
    exit /b 1
)

where node >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到Node.js命令，请安装Node.js环境
    exit /b 1
)

where npm >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到npm命令，请安装npm
    exit /b 1
)

echo [%date% %time%] 系统要求检查完成

REM 安装依赖
if "%SKIP_DEPS%"=="true" (
    echo [%date% %time%] 跳过依赖安装
) else (
    echo [%date% %time%] 安装依赖...
    
    cd /d "%PROJECT_DIR%"
    
    echo [%date% %time%] 安装Go依赖...
    go mod download
    if errorlevel 1 (
        echo 错误: Go依赖安装失败
        exit /b 1
    )
    
    echo [%date% %time%] 安装前端依赖...
    cd web
    npm install
    if errorlevel 1 (
        echo 错误: 前端依赖安装失败
        exit /b 1
    )
    cd ..
    
    echo [%date% %time%] 依赖安装完成
)

REM 配置环境变量
echo [%date% %time%] 配置环境变量...

set ENV_FILE=%PROJECT_DIR%\configs\.env

REM 生成JWT密钥
for /f %%i in ('powershell -command "Get-Date -UFormat %%s"') do set TIMESTAMP=%%i
set /a RANDOM_NUM=%RANDOM%
set JWT_SECRET=aq3stat_%TIMESTAMP%_%RANDOM_NUM%_secret_key

REM 创建.env文件
(
echo # aq3stat环境配置文件
echo ENV=%ENV%
echo SERVER_PORT=%PORT%
echo DB_HOST=localhost
echo DB_PORT=3306
echo DB_USER=root
echo DB_PASSWORD=%DB_PASSWORD%
echo DB_NAME=aq3stat
echo JWT_SECRET=%JWT_SECRET%
echo JWT_EXPIRATION=24h
echo LOG_LEVEL=info
echo LOG_FILE=
echo CORS_ORIGINS=*
echo RATE_LIMIT=100
) > "%ENV_FILE%"

echo [%date% %time%] 环境变量配置完成

REM 初始化数据库
if "%SKIP_DB%"=="true" (
    echo [%date% %time%] 跳过数据库初始化
) else (
    echo [%date% %time%] 初始化数据库...
    
    where mysql >nul 2>&1
    if errorlevel 1 (
        echo 警告: 未找到MySQL客户端，跳过数据库初始化
    ) else (
        if exist "%SCRIPT_DIR%\init_db.bat" (
            call "%SCRIPT_DIR%\init_db.bat" -h localhost -P 3306 -u root -p "%DB_PASSWORD%" -d aq3stat
        ) else (
            echo 警告: 找不到数据库初始化脚本，请手动初始化数据库
        )
    )
    
    echo [%date% %time%] 数据库初始化完成
)

REM 构建应用
if "%SKIP_BUILD%"=="true" (
    echo [%date% %time%] 跳过构建步骤
) else (
    echo [%date% %time%] 构建应用...
    
    cd /d "%PROJECT_DIR%"
    
    echo [%date% %time%] 构建后端...
    go build -o aq3stat-server.exe cmd\api\main.go
    if errorlevel 1 (
        echo 错误: 后端构建失败
        exit /b 1
    )
    
    echo [%date% %time%] 构建前端...
    cd web
    npm run build
    if errorlevel 1 (
        echo 错误: 前端构建失败
        exit /b 1
    )
    cd ..
    
    echo [%date% %time%] 应用构建完成
)

REM 显示部署信息
echo.
echo [%date% %time%] 部署信息:
echo   环境: %ENV%
echo   端口: %PORT%
echo   访问地址: http://localhost:%PORT%
echo   默认管理员账号: admin / admin123
echo   警告: 请及时修改默认密码！
echo.

if "%ENV%"=="development" (
    echo 启动开发服务器:
    echo   后端: go run cmd\api\main.go
    echo   前端: cd web ^&^& npm run serve
    echo.
)

echo [%date% %time%] 🎉 aq3stat部署完成！

goto end

:show_help
echo aq3stat网站统计系统Windows部署脚本
echo.
echo 用法: %0 [选项]
echo.
echo 选项:
echo   --env ENV           部署环境 (development^|production) [默认: development]
echo   --port PORT         服务端口 [默认: 8080]
echo   --db-password PASS  数据库密码
echo   --skip-deps         跳过依赖安装
echo   --skip-build        跳过构建步骤
echo   --skip-db           跳过数据库初始化
echo   --help              显示帮助信息
echo.
echo 示例:
echo   %0 --env development
echo   %0 --env production --db-password mypassword
echo.

:end
endlocal
