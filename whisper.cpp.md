# Whisper.cpp — Vulkan + WebUI 使用指南

本指南整理了在 Windows 上使用 Whisper.cpp（启用 Vulkan 支持）以及基于 Gradio 的简单 WebUI 的完整流程：环境准备、编译、模型下载、命令行运行与 WebUI 使用示例。

---

## 📦 环境准备（Windows）

1. Visual Studio Build Tools
- 下载并安装 Visual Studio Build Tools，勾选 MSVC 编译器 和 Windows SDK。

2. CMake
- 安装 CMake，并确保添加到系统 PATH。

3. Ninja（可选）
- 如果偏好 Ninja 构建器，可安装并使用。

4. Git
- 安装 Git for Windows，用于拉取源码。

5. Python 3.11+
- 安装 Python，并确保 pip 可用（用于运行 WebUI）。

6. Vulkan SDK
- 下载并安装 LunarG Vulkan SDK，安装后会自动设置环境变量 VULKAN_SDK。
- 验证（在 cmd 或 PowerShell 中运行）：

```bat
echo %VULKAN_SDK%
dir %VULKAN_SDK%\Bin\glslc.exe
```

---

## ⚙️ 编译 Whisper.cpp（启用 Vulkan）

1. 拉取源码：

```bat
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp
```

2. 配置（使用 MSVC + Vulkan）：

```bat
cmake -B build -DGGML_VULKAN=1 -G "Visual Studio 17 2022" -A x64
```

3. 编译（Release）：

```bat
cmake --build build --config Release
```

编译完成后可执行文件位于：

```
build\bin\Release\whisper-cli.exe
```

---

## 📥 下载模型

进入项目的 `models` 目录并下载所需的 ggml 模型：

```bat
cd models
curl -L -o ggml-base.en.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin
curl -L -o ggml-large-v1.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v1.bin
```

常见模型说明：
- ggml-tiny.en.bin（最快，精度最低）
- ggml-base.en.bin（速度/准确度平衡）
- ggml-small.en.bin
- ggml-medium.en.bin
- ggml-large-v3.bin（最精确，显存需求高）

---

## ▶️ 命令行运行示例

- 转录示例音频：

```bat
.\build\bin\Release\whisper-cli.exe -m models\ggml-base.en.bin -f samples\jfk.wav
```

- 生成字幕（SRT）：

```bat
.\build\bin\Release\whisper-cli.exe -m models\ggml-base.en.bin -f samples\jfk.wav --output-srt
```

---

## 🌐 WebUI（Gradio）示例

下面给出一个简单的 Gradio WebUI 示例（将项目根目录下创建 `webui.py`）：

```python

import gradio as gr
import subprocess
import os
import shutil

WHISPER_BIN = r"F:/whisper.cpp/build/bin/Release/whisper-cli.exe"
MODEL_DIR = r"F:/whisper.cpp/models"
OUTPUT_DIR = r"F:/whisper.cpp/outputs"

os.makedirs(OUTPUT_DIR, exist_ok=True)

# 只加载 ggml 开头的模型
MODELS = [f for f in os.listdir(MODEL_DIR) if f.startswith("ggml") and f.endswith(".bin")]
if not MODELS:
    MODELS = ["(未找到 ggml 模型，请检查 models 文件夹)"]

def transcribe(files, model_name, output_format, language):
    results = []
    model_path = os.path.join(MODEL_DIR, model_name)
    if not os.path.exists(model_path):
        return f"模型文件不存在: {model_path}"

    if not isinstance(files, list):
        files = [files]

    for file in files:
        base_name = os.path.basename(file)
        temp_wav = os.path.join(OUTPUT_DIR, base_name + "_converted.wav")
        output_file = os.path.join(OUTPUT_DIR, base_name + "." + output_format)

        # 自动转码：无论是音频还是视频，都转成 16kHz wav
        try:
            subprocess.run(
                ["ffmpeg", "-y", "-i", file, "-ar", "16000", "-ac", "1", temp_wav],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        except Exception as e:
            results.append(f"文件 {base_name} 转码失败: {e}")
            continue

        cmd = [WHISPER_BIN, "-m", model_path, "-f", temp_wav, "-l", language]

        try:
            if output_format == "txt":
                result = subprocess.run(
                    cmd,
                    capture_output=True,
                    text=True,
                    encoding="utf-8",
                    errors="ignore"
                )
                output_text = result.stdout if result.stdout else "转录失败，未捕获到输出"
                results.append(f"文件 {base_name} 转录结果:\n" + output_text)

                with open(output_file, "w", encoding="utf-8") as f:
                    f.write(output_text)

            else:
                if output_format == "srt":
                    cmd.append("--output-srt")
                elif output_format == "vtt":
                    cmd.append("--output-vtt")

                subprocess.run(cmd, check=True)

                temp_output = temp_wav + "." + output_format

                if os.path.exists(temp_output):
                    with open(temp_output, "r", encoding="utf-8") as f:
                        text = f.read()

                    with open(output_file, "w", encoding="utf-8") as f:
                        f.write(text)

                    results.append(f"文件 {base_name} 转录结果:\n" + text)
                    os.remove(temp_output)
                else:
                    results.append(f"文件 {base_name} 转录失败，未生成输出文件。")

        except subprocess.CalledProcessError as e:
            results.append(f"文件 {base_name} 转录失败，错误信息: {e}")

        if os.path.exists(temp_wav):
            os.remove(temp_wav)

    return "\n\n".join(results)

iface = gr.Interface(
    fn=transcribe,
    inputs=[
        gr.File(type="filepath", label="上传音频/视频文件（可多选）", file_types=["audio", "video"], file_count="multiple"),
        gr.Dropdown(MODELS, value=MODELS[0], label="选择模型"),
        gr.Radio(["txt", "srt", "vtt"], value="txt", label="输出格式"),
        gr.Textbox(value="zh", label="语言代码 (如 en, zh, ja, fr)")
    ],
    outputs="text",
    title="Whisper.cpp WebUI",
    description="上传音频或视频，自动提取音频并转码为16kHz WAV，只加载 ggml 模型，选择语言，生成转录或字幕（支持批量处理）"
)

iface.launch(server_name="0.0.0.0", server_port=7860)



```

运行 WebUI：

```bat
pip install gradio
python webui.py
```

在浏览器中打开：

```
http://127.0.0.1:7860
```

上传音频 → 选择模型 → 选择输出格式 → 获取转录或字幕。

---

## ✅ 总结
- 准备工具链：Visual Studio Build Tools、CMake、Vulkan SDK、Python（及 pip）、（可选）Ninja。
- 编译 whisper.cpp（启用 Vulkan）得到 `whisper-cli.exe`。
- 下载所需 ggml 模型到 `models` 目录。
- 可通过命令行或上面的 Gradio WebUI 进行转录与字幕生成。
- 运行 WebUI，支持自动转码、多语音、批量处理，结果保存到 outputs。
- 支持视频文件：上传 mp4/mkv/avi 时，自动用 ffmpeg 提取音轨。
- 统一处理：无论音频还是视频，都会转成 16kHz wav，再交给 Whisper。


