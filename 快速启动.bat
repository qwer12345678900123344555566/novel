@echo off
chcp 65001 >nul 2>&1
title 快速启动

:: 最小化输出的快速启动版本
color 0A

echo.
echo [启动] AI长篇小说生成器
echo.

:: 静默检查
node --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [错误] 请先安装 Node.js
    pause
    exit /b 1
)

:: 检查依赖
if not exist "node_modules" (
    color 0E
    echo [安装] 首次运行，正在安装依赖...
    call npm install --silent
    if errorlevel 1 (
        color 0C
        echo [错误] 安装失败
        pause
        exit /b 1
    )
)

:: 启动
color 0B
echo [就绪] 服务器启动在: http://localhost:3000
echo.

node server.js
