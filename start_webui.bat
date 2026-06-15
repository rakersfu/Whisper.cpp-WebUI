@echo off
chcp 65001 >nul
echo ============================================
echo   启动 Whisper.cpp WebUI
echo ============================================

REM 切换到脚本所在目录
cd /d %~dp0

REM 使用 Python 启动 webui3.py
python webui4.py

pause
