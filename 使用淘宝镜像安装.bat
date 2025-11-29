@echo off
chcp 65001 >nul 2>&1
title 使用淘宝镜像安装依赖

color 0B

echo.
echo ========================================
echo       使用淘宝镜像安装依赖
echo       (适合国内网络环境)
echo ========================================
echo.

:: 检查Node.js
node --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [错误] 未检测到 Node.js
    echo.
    pause
    exit /b 1
)

color 0E
echo [步骤 1] 配置淘宝镜像源...
echo.

:: 设置淘宝镜像
npm config set registry https://registry.npmmirror.com

if errorlevel 1 (
    color 0C
    echo ✗ 镜像配置失败
    pause
    exit /b 1
)

color 0A
echo ✓ 镜像配置成功
echo 当前源: https://registry.npmmirror.com
echo.

:: 显示当前配置
color 0B
echo [信息] npm 配置:
npm config get registry
echo.

color 0E
echo [步骤 2] 清理旧依赖...
echo.

if exist "node_modules" (
    echo 正在删除旧依赖...
    rmdir /s /q node_modules 2>nul
    echo ✓ 清理完成
) else (
    echo ✓ 无需清理
)
echo.

if exist "package-lock.json" (
    echo 正在删除 package-lock.json...
    del package-lock.json 2>nul
    echo ✓ 删除完成
)
echo.

color 0E
echo [步骤 3] 安装依赖包...
echo.
echo 使用淘宝镜像加速下载...
echo.

:: 安装依赖
call npm install

if errorlevel 1 (
    color 0C
    echo.
    echo ✗ 安装失败！
    echo.
    echo 即使使用镜像仍然失败，可能原因：
    echo 1. 网络暂时不稳定
    echo 2. 磁盘空间不足
    echo 3. 权限问题
    echo.
    echo 建议：
    echo - 稍后重试
    echo - 以管理员身份运行
    echo.
    pause
    exit /b 1
)

color 0A
echo.
echo ========================================
echo [成功] 依赖安装完成！
echo ========================================
echo.

:: 显示安装的包
echo 已安装的依赖包：
for /d %%i in (node_modules\*) do (
    echo   ✓ %%~ni
)

echo.
color 0B
echo ========================================
echo 现在可以运行 "启动.bat" 启动服务器
echo ========================================
echo.

:: 询问是否恢复默认源
color 0E
echo.
echo [选项] 是否恢复npm默认源？
echo.
echo 1. 是 - 恢复官方源
echo 2. 否 - 保持淘宝镜像
echo.
set /p RESTORE="请选择 (1/2): "

if "%RESTORE%"=="1" (
    npm config set registry https://registry.npmjs.org
    color 0A
    echo.
    echo ✓ 已恢复为官方源
)

echo.
pause
