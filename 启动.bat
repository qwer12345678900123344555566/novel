@echo off
chcp 65001 >nul 2>&1
title AI长篇小说生成器

:: 设置颜色（0=黑底 A=亮绿 B=亮青 C=亮红 E=亮黄）
color 0A

echo.
echo ========================================
echo          AI长篇小说生成器
echo ========================================
echo.

:: 检查Node.js是否安装
echo [检查] 正在检查 Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [错误] 未检测到 Node.js！
    echo.
    echo 请先安装 Node.js:
    echo https://nodejs.org/
    echo.
    echo 建议安装 LTS 版本
    pause
    exit /b 1
)

:: 显示Node版本
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
color 0B
echo [成功] Node.js 版本: %NODE_VERSION%
echo.

:: 检查npm是否安装
echo [检查] 正在检查 npm...
npm --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [错误] 未检测到 npm！
    echo.
    pause
    exit /b 1
)

:: 显示npm版本
for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
color 0B
echo [成功] npm 版本: %NPM_VERSION%
echo.

:: 检查依赖是否安装
if not exist "node_modules" (
    color 0E
    echo [提示] 首次运行，需要安装依赖...
    echo.
    echo [安装] 正在安装项目依赖，请稍候...
    echo.
    
    call npm install
    
    if errorlevel 1 (
        color 0C
        echo.
        echo [错误] 依赖安装失败！
        echo.
        echo 请检查网络连接或尝试使用淘宝镜像：
        echo npm config set registry https://registry.npmmirror.com
        echo.
        pause
        exit /b 1
    )
    
    color 0A
    echo.
    echo [成功] 依赖安装完成！
    echo.
) else (
    color 0B
    echo [提示] 依赖已安装
    echo.
)

:: 启动服务器
color 0E
echo ========================================
echo          正在启动服务器...
echo ========================================
echo.
echo [访问] 请在浏览器中打开:
color 0A
echo        http://localhost:3000
echo.
color 0E
echo [提示] 按 Ctrl+C 可以停止服务器
echo ========================================
echo.

:: 启动Node服务
node server.js

:: 如果服务异常退出
if errorlevel 1 (
    color 0C
    echo.
    echo [错误] 服务器启动失败！
    echo.
    pause
)
