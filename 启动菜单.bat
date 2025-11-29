@echo off
chcp 65001 >nul 2>&1
title AI长篇小说生成器 - 启动菜单

:menu
cls
color 0B

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                                                               ║
echo ║              🎭  AI长篇小说生成器  🎭                          ║
echo ║                                                               ║
echo ║                      启动菜单 v1.0                             ║
echo ║                                                               ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo ┌───────────────────────────────────────────────────────────────┐
echo │  【快速操作】                                                  │
echo └───────────────────────────────────────────────────────────────┘
echo.
echo   [1] 🚀 一键安装并启动      (推荐新手，自动完成所有操作)
echo   [2] ▶  启动服务器          (标准启动，详细信息)
echo   [3] ⚡ 快速启动            (极速启动，最小输出)
echo.
echo ┌───────────────────────────────────────────────────────────────┐
echo │  【安装管理】                                                  │
echo └───────────────────────────────────────────────────────────────┘
echo.
echo   [4] 📦 安装项目依赖        (首次安装或重新安装)
echo   [5] 🇨🇳 使用淘宝镜像安装    (国内用户推荐，速度更快)
echo.
echo ┌───────────────────────────────────────────────────────────────┐
echo │  【工具选项】                                                  │
echo └───────────────────────────────────────────────────────────────┘
echo.
echo   [6] 🔍 检查系统环境        (诊断问题，查看状态)
echo   [7] ⏹  停止服务器          (安全停止正在运行的服务)
echo   [8] 📖 查看帮助文档        (打开使用说明)
echo.
echo ┌───────────────────────────────────────────────────────────────┐
echo │  【其他】                                                      │
echo └───────────────────────────────────────────────────────────────┘
echo.
echo   [9] 🌐 打开浏览器          (访问 http://localhost:3000)
echo   [0] ❌ 退出菜单
echo.
echo ═══════════════════════════════════════════════════════════════
echo.

set /p choice="请选择操作 [0-9]: "

if "%choice%"=="1" goto option1
if "%choice%"=="2" goto option2
if "%choice%"=="3" goto option3
if "%choice%"=="4" goto option4
if "%choice%"=="5" goto option5
if "%choice%"=="6" goto option6
if "%choice%"=="7" goto option7
if "%choice%"=="8" goto option8
if "%choice%"=="9" goto option9
if "%choice%"=="0" goto exit

color 0C
echo.
echo [错误] 无效的选择，请输入 0-9
timeout /t 2 >nul
goto menu

:option1
cls
color 0A
echo.
echo ═══════════════════════════════════════════════════════════════
echo  正在执行：一键安装并启动
echo ═══════════════════════════════════════════════════════════════
echo.
call "一键安装并启动.bat"
pause
goto menu

:option2
cls
color 0A
echo.
echo ═══════════════════════════════════════════════════════════════
echo  正在执行：启动服务器
echo ═══════════════════════════════════════════════════════════════
echo.
call "启动.bat"
pause
goto menu

:option3
cls
color 0A
echo.
echo ═══════════════════════════════════════════════════════════════
echo  正在执行：快速启动
echo ═══════════════════════════════════════════════════════════════
echo.
call "快速启动.bat"
pause
goto menu

:option4
cls
color 0A
echo.
echo ═══════════════════════════════════════════════════════════════
echo  正在执行：安装项目依赖
echo ═══════════════════════════════════════════════════════════════
echo.
call "安装依赖.bat"
pause
goto menu

:option5
cls
color 0A
echo.
echo ═══════════════════════════════════════════════════════════════
echo  正在执行：使用淘宝镜像安装
echo ═══════════════════════════════════════════════════════════════
echo.
call "使用淘宝镜像安装.bat"
pause
goto menu

:option6
cls
color 0A
echo.
echo ═══════════════════════════════════════════════════════════════
echo  正在执行：检查系统环境
echo ═══════════════════════════════════════════════════════════════
echo.
call "检查环境.bat"
goto menu

:option7
cls
color 0A
echo.
echo ═══════════════════════════════════════════════════════════════
echo  正在执行：停止服务器
echo ═══════════════════════════════════════════════════════════════
echo.
call "停止服务器.bat"
goto menu

:option8
cls
color 0B
echo.
echo ═══════════════════════════════════════════════════════════════
echo  帮助文档
echo ═══════════════════════════════════════════════════════════════
echo.
echo  可用文档：
echo.
echo  1. README.md - 项目说明
echo  2. USAGE.md - 详细使用指南
echo  3. Windows使用说明.md - Windows用户指南
echo  4. 快速开始.md - 5分钟快速入门
echo  5. 批处理文件说明.txt - 批处理文件说明
echo.

if exist "Windows使用说明.md" (
    echo [提示] 正在打开 Windows使用说明.md...
    start "" "Windows使用说明.md"
) else if exist "README.md" (
    echo [提示] 正在打开 README.md...
    start "" "README.md"
) else (
    echo [提示] 未找到帮助文档
)

echo.
pause
goto menu

:option9
cls
color 0A
echo.
echo ═══════════════════════════════════════════════════════════════
echo  正在打开浏览器...
echo ═══════════════════════════════════════════════════════════════
echo.
echo  访问地址: http://localhost:3000
echo.

:: 尝试多种方式打开浏览器
start http://localhost:3000 2>nul
if errorlevel 1 (
    start "" "http://localhost:3000" 2>nul
)

timeout /t 2 >nul
goto menu

:exit
cls
color 0E
echo.
echo ═══════════════════════════════════════════════════════════════
echo  感谢使用 AI长篇小说生成器！
echo ═══════════════════════════════════════════════════════════════
echo.
echo  祝你创作愉快！ ✨
echo.
timeout /t 2 >nul
exit
