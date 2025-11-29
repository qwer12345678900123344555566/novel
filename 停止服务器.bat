@echo off
chcp 65001 >nul 2>&1
title 停止服务器

color 0E

echo.
echo ========================================
echo          停止服务器进程
echo ========================================
echo.

:: 查找占用3000端口的进程
echo [检查] 正在查找服务器进程...
echo.

for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000"') do (
    set PID=%%a
    goto :found
)

:notfound
color 0E
echo [提示] 未发现运行中的服务器进程
echo.
echo 端口 3000 当前没有被占用
goto :end

:found
color 0B
echo [发现] 服务器进程 PID: %PID%
echo.

:: 获取进程详细信息
echo [信息] 进程详情:
tasklist /FI "PID eq %PID%" /FO LIST | findstr "映像名称\|进程 ID\|内存使用"
echo.

:: 确认是否停止
color 0E
echo [确认] 确定要停止此进程吗？ (Y/N)
set /p CONFIRM="请选择: "

if /i not "%CONFIRM%"=="Y" (
    color 0E
    echo.
    echo [取消] 操作已取消
    goto :end
)

:: 停止进程
echo.
echo [执行] 正在停止进程...

taskkill /PID %PID% /F >nul 2>&1

if errorlevel 1 (
    color 0C
    echo [错误] 停止失败
    echo.
    echo 可能原因：
    echo 1. 权限不足 - 尝试以管理员身份运行
    echo 2. 进程已经结束
    echo.
) else (
    color 0A
    echo [成功] 服务器已停止
    echo.
    
    :: 再次检查
    timeout /t 1 /nobreak >nul
    netstat -ano | findstr ":3000" >nul 2>&1
    if errorlevel 1 (
        echo [确认] 端口 3000 现已可用
    )
)

:end
echo.
echo ========================================
pause
