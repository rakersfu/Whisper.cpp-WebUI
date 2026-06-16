@echo off
chcp 65001 >nul

echo ============================================
echo   Start Whisper.cpp WebUI
echo ============================================

REM Save target directory
set TARGET_DIR=%~dp0
set PATH=%PATH%;C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem

REM Switch to the script directory
cd /d "%TARGET_DIR%"

REM Check if directory switch succeeded
if /i "%cd%"=="%TARGET_DIR:~0,-1%" (
    echo [OK] Successfully switched to directory: %cd%
) else (
    echo [ERROR] Failed to switch to script directory
    echo Current directory: %cd%
    pause
    exit /b
)

REM Check if Python exists
where python >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Python not found, please confirm it is installed and added to PATH
    pause
    exit /b
) else (
    for /f "delims=" %%i in ('where python') do (
        echo [OK] Found Python: %%i
        goto :found
    )
)
:found

REM Check if ffmpeg exists
where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo [ERROR] ffmpeg not found, please confirm it is installed and added to PATH
    pause
    exit /b
) else (
    for /f "delims=" %%i in ('where ffmpeg') do (
        echo [OK] Found ffmpeg: %%i
        goto :ffmpeg_found
    )
)
:ffmpeg_found

REM Check if webui.py exists
if exist "webui.py" (
    echo [OK] Found webui.py, preparing to start...
) else (
    echo [ERROR] webui.py not found, please confirm the file is in directory: %cd%
    pause
    exit /b
)

REM Use Python to start webui.py
echo [INFO] Starting webui.py ...
python webui.py

echo ============================================
echo   WebUI exited
echo ============================================
pause
