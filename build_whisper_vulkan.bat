@echo off
chcp 65001 >nul

echo ============================================
echo Whisper.cpp Vulkan Build Script
echo ============================================

:: 检查 VULKAN_SDK 环境变量
if "%VULKAN_SDK%"=="" (
    echo [错误] 未检测到 VULKAN_SDK 环境变量！
    echo 请安装 Vulkan SDK 并设置环境变量，例如：
    echo   VULKAN_SDK=C:\VulkanSDK\1.4.xxx.x
    pause
    exit /b 1
) else (
    echo [OK] VULKAN_SDK = %VULKAN_SDK%
)

:: 检查 glslc.exe 是否存在
if exist "%VULKAN_SDK%\Bin\glslc.exe" (
    echo [OK] 找到 glslc.exe
) else (
    echo [错误] 未找到 glslc.exe，请确认 Vulkan SDK 安装完整！
    pause
    exit /b 1
)

:: 删除旧的 build 文件夹
if exist build (
    echo 清理旧的 build 文件夹...
    rmdir /s /q build
)

:: 运行 CMake 配置
echo 正在运行 CMake 配置...
cmake -B build -DGGML_VULKAN=1 -G "Visual Studio 17 2022" -A x64

:: 编译项目
echo 正在编译项目...
cmake --build build --config Release

echo ============================================
echo 编译完成！可执行文件在 build\bin\whisper-cli.exe
echo ============================================

pause
