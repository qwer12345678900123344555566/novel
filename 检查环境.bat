@echo off
chcp 65001 >nul 2>&1
title 环境检查工具

color 0B

echo.
echo ========================================
echo          环境检查工具
echo ========================================
echo.
echo 正在检查运行环境...
echo.

:: 检查Node.js
echo ----------------------------------------
echo [检查 1/4] Node.js
echo ----------------------------------------
node --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo 状态: ✗ 未安装
    echo.
    echo 下载地址: https://nodejs.org/
    echo 建议版本: LTS (长期支持版)
    set NODE_OK=0
) else (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    color 0A
    echo 状态: ✓ 已安装
    echo 版本: %NODE_VERSION%
    set NODE_OK=1
)
echo.

:: 检查npm
echo ----------------------------------------
echo [检查 2/4] npm (包管理器)
echo ----------------------------------------
npm --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo 状态: ✗ 未安装
    set NPM_OK=0
) else (
    for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
    color 0A
    echo 状态: ✓ 已安装
    echo 版本: %NPM_VERSION%
    set NPM_OK=1
)
echo.

:: 检查项目依赖
echo ----------------------------------------
echo [检查 3/4] 项目依赖
echo ----------------------------------------
if exist "node_modules" (
    color 0A
    echo 状态: ✓ 已安装
    
    :: 统计依赖数量
    set COUNT=0
    for /d %%i in (node_modules\*) do set /a COUNT+=1
    echo 已安装: %COUNT% 个包
    set DEPS_OK=1
) else (
    color 0E
    echo 状态: ✗ 未安装
    echo.
    echo 运行 "安装依赖.bat" 进行安装
    set DEPS_OK=0
)
echo.

:: 检查配置文件
echo ----------------------------------------
echo [检查 4/4] 项目文件
echo ----------------------------------------
set FILES_OK=1

if exist "server.js" (
    echo ✓ server.js
) else (
    echo ✗ server.js (缺失)
    set FILES_OK=0
)

if exist "package.json" (
    echo ✓ package.json
) else (
    echo ✗ package.json (缺失)
    set FILES_OK=0
)

if exist "public\index.html" (
    echo ✓ public\index.html
) else (
    echo ✗ public\index.html (缺失)
    set FILES_OK=0
)

if exist "public\app.js" (
    echo ✓ public\app.js
) else (
    echo ✗ public\app.js (缺失)
    set FILES_OK=0
)

if exist "public\style.css" (
    echo ✓ public\style.css
) else (
    echo ✗ public\style.css (缺失)
    set FILES_OK=0
)
echo.

:: 检查端口占用
echo ----------------------------------------
echo [检查] 端口占用情况
echo ----------------------------------------
netstat -ano | findstr ":3000" >nul 2>&1
if errorlevel 1 (
    color 0A
    echo 端口 3000: ✓ 可用
    set PORT_OK=1
) else (
    color 0E
    echo 端口 3000: ⚠ 已被占用
    echo.
    echo 如果服务器未运行，可能需要结束占用进程
    set PORT_OK=0
)
echo.

:: 总结
echo ========================================
echo          检查结果总结
echo ========================================
echo.

if "%NODE_OK%"=="1" if "%NPM_OK%"=="1" if "%DEPS_OK%"=="1" if "%FILES_OK%"=="1" (
    color 0A
    echo 状态: ✓ 一切就绪！
    echo.
    echo 可以运行 "启动.bat" 启动服务器
) else (
    color 0E
    echo 状态: ⚠ 存在问题
    echo.
    echo 需要解决的问题：
    if "%NODE_OK%"=="0" echo   - 安装 Node.js
    if "%NPM_OK%"=="0" echo   - 安装 npm
    if "%DEPS_OK%"=="0" echo   - 运行 "安装依赖.bat"
    if "%FILES_OK%"=="0" echo   - 检查项目文件完整性
)

echo.
echo ========================================
pause
