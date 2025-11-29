@echo off
chcp 65001 >nul 2>&1
title 安装项目依赖

color 0B

echo.
echo ========================================
echo          安装项目依赖
echo ========================================
echo.

:: 检查Node.js
echo [检查] 正在检查 Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [错误] 未检测到 Node.js！
    echo.
    echo 请先从以下地址下载安装 Node.js:
    echo https://nodejs.org/
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
color 0A
echo [成功] Node.js 版本: %NODE_VERSION%
echo.

:: 检查npm
echo [检查] 正在检查 npm...
npm --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [错误] 未检测到 npm！
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
color 0B
echo [成功] npm 版本: %NPM_VERSION%
echo.

:: 询问是否使用国内镜像
color 0E
echo [选项] 是否使用淘宝镜像加速？(推荐国内用户)
echo.
echo 1. 是 - 使用淘宝镜像(更快)
echo 2. 否 - 使用官方源
echo.
set /p MIRROR_CHOICE="请选择 (1/2): "

if "%MIRROR_CHOICE%"=="1" (
    color 0B
    echo.
    echo [配置] 正在设置淘宝镜像...
    npm config set registry https://registry.npmmirror.com
    echo [成功] 镜像设置完成
    echo.
)

:: 清理旧依赖
if exist "node_modules" (
    color 0E
    echo [清理] 发现已有依赖，是否重新安装？(Y/N)
    set /p REINSTALL="请选择: "
    
    if /i "%REINSTALL%"=="Y" (
        echo.
        echo [清理] 正在删除旧依赖...
        rmdir /s /q node_modules 2>nul
        del package-lock.json 2>nul
        color 0A
        echo [成功] 清理完成
        echo.
    )
)

:: 安装依赖
color 0E
echo ========================================
echo [安装] 正在安装项目依赖...
echo ========================================
echo.
echo 这可能需要几分钟，请耐心等待...
echo.

call npm install

if errorlevel 1 (
    color 0C
    echo.
    echo ========================================
    echo [错误] 依赖安装失败！
    echo ========================================
    echo.
    echo 可能的原因：
    echo 1. 网络连接问题
    echo 2. npm源访问超时
    echo 3. 权限不足
    echo.
    echo 建议解决方案：
    echo 1. 检查网络连接
    echo 2. 使用淘宝镜像（重新运行此脚本并选择1）
    echo 3. 以管理员身份运行
    echo.
    pause
    exit /b 1
)

:: 安装成功
color 0A
echo.
echo ========================================
echo [成功] 所有依赖安装完成！
echo ========================================
echo.

:: 显示已安装的包
echo [信息] 已安装的依赖包：
echo.
if exist "node_modules" (
    for /d %%i in (node_modules\*) do (
        echo    - %%~ni
    )
)

echo.
color 0B
echo ========================================
echo [完成] 现在可以运行 "启动.bat" 启动服务器
echo ========================================
echo.

pause
