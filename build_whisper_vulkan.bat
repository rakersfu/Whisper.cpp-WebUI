@echo off
chcp 65001 >nul

echo ============================================
echo Whisper.cpp Vulkan Build Script
echo ============================================

:: Check VULKAN_SDK environment variable
if "%VULKAN_SDK%"=="" (
    echo [ERROR] VULKAN_SDK environment variable not detected!
    echo Please install Vulkan SDK and set the environment variable, for example:
    echo   VULKAN_SDK=C:\VulkanSDK\1.4.xxx.x
    pause
    exit /b 1
) else (
    echo [OK] VULKAN_SDK = %VULKAN_SDK%
)

:: Check if glslc.exe exists
if exist "%VULKAN_SDK%\Bin\glslc.exe" (
    echo [OK] Found glslc.exe
) else (
    echo [ERROR] glslc.exe not found, please make sure Vulkan SDK is fully installed!
    pause
    exit /b 1
)

:: Remove old build folder
if exist build (
    echo Cleaning old build folder...
    rmdir /s /q build
)

:: Run CMake configuration
echo Running CMake configuration...
cmake -B build -DGGML_VULKAN=1 -G "Visual Studio 17 2022" -A x64

:: Build project
echo Building project...
cmake --build build --config Release

echo ============================================
echo Build completed! Executable is at build\bin\whisper-cli.exe
echo ============================================

pause
