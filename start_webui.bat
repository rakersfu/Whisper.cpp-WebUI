@echo off
chcp 65001 >nul
echo ============================================
echo   启动 Whisper.cpp WebUI
echo ============================================

REM 保存目标目录
set TARGET_DIR=%~dp0

REM 切换到脚本所在目录
cd /d "%TARGET_DIR%"

REM 检查是否切换成功
if /i "%cd%"=="%TARGET_DIR:~0,-1%" (
    echo [OK] 已成功切换到目录: %cd%
) else (
    echo [ERROR] 未能切换到脚本所在目录
    echo 当前目录: %cd%
    pause
    exit /b
)

REM 使用 Python 启动 webui4.py
echo [INFO] 正在启动 webui4.py ...
python webui4.py

echo ============================================
echo   WebUI 已退出
echo ============================================
pause
