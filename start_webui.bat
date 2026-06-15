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

REM 检查 Python 是否存在
where python >nul 2>nul
if errorlevel 1 (
    echo [ERROR] 未找到 Python，请确认已安装并添加到 PATH
    pause
    exit /b
) else (
    for /f "delims=" %%i in ('where python') do (
        echo [OK] 已找到 Python: %%i
        goto :found
    )
)
:found

REM 检查 ffmpeg 是否存在
where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo [ERROR] 未找到 ffmpeg，请确认已安装并添加到 PATH
    pause
    exit /b
) else (
    for /f "delims=" %%i in ('where ffmpeg') do (
        echo [OK] 已找到 ffmpeg: %%i
        goto :ffmpeg_found
    )
)
:ffmpeg_found

REM 检查 webui.py 是否存在
if exist "webui.py" (
    echo [OK] 已找到 webui.py，准备启动...
) else (
    echo [ERROR] 未找到 webui.py，请确认文件在目录: %cd%
    pause
    exit /b
)

REM 使用 Python 启动 webui.py
echo [INFO] 正在启动 webui.py ...
python webui.py

echo ============================================
echo   WebUI 已退出
echo ============================================
pause
