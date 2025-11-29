@echo off
chcp 65001 >nul 2>&1
title 一键安装并启动

color 0B

echo.
echo ========================================
echo       AI长篇小说生成器
echo       一键安装并启动
echo ========================================
echo.

:: 步骤1: 检查Node.js
color 0E
echo [步骤 1/3] 检查运行环境...
echo.

node --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo ✗ 未检测到 Node.js
    echo.
    echo 请先安装 Node.js (https://nodejs.org/)
    echo 安装完成后重新运行此脚本
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i

color 0A
echo ✓ Node.js: %NODE_VERSION%
echo ✓ npm: %NPM_VERSION%
echo.

:: 步骤2: 安装依赖
color 0E
echo [步骤 2/3] 安装项目依赖...
echo.

if exist "node_modules" (
    color 0B
    echo ✓ 依赖已安装，跳过此步骤
    echo.
) else (
    color 0E
    echo 正在安装依赖包，请稍候...
    echo (这可能需要2-5分钟，取决于网络速度)
    echo.
    
    :: 尝试使用淘宝镜像加速
    npm config set registry https://registry.npmmirror.com >nul 2>&1
    
    call npm install
    
    if errorlevel 1 (
        color 0C
        echo.
        echo ✗ 安装失败！
        echo.
        echo 请检查：
        echo 1. 网络连接是否正常
        echo 2. 是否有足够的磁盘空间
        echo 3. 是否有文件夹访问权限
        echo.
        echo 你也可以尝试：
        echo - 以管理员身份运行
        echo - 单独运行 "安装依赖.bat"
        echo.
        pause
        exit /b 1
    )
    
    color 0A
    echo.
    echo ✓ 依赖安装完成！
    echo.
)

:: 步骤3: 启动服务器
color 0E
echo [步骤 3/3] 启动服务器...
echo.

:: 检查端口占用
netstat -ano | findstr ":3000" >nul 2>&1
if not errorlevel 1 (
    color 0E
    echo ⚠ 警告: 端口 3000 已被占用
    echo.
    echo 如果之前的服务器还在运行，请先关闭它
    echo.
    pause
)

color 0A
echo ========================================
echo           服务器已启动！
echo ========================================
echo.
echo 访问地址: 
color 0B
echo     http://localhost:3000
color 0A
echo.
echo 使用说明:
echo   1. 打开浏览器访问上面的地址
echo   2. 首次使用需要配置API提供商
echo   3. 然后就可以开始创作小说了
echo.
color 0E
echo 按 Ctrl+C 可以停止服务器
echo ========================================
echo.

:: 尝试自动打开浏览器
timeout /t 2 /nobreak >nul
start http://localhost:3000 2>nul

color 0A
node server.js

:: 如果服务器异常退出
if errorlevel 1 (
    color 0C
    echo.
    echo ========================================
    echo [错误] 服务器异常退出
    echo ========================================
    echo.
    pause
)
