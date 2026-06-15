import gradio as gr
import subprocess
import os
import shutil

#设置绝对路径
#WHISPER_BIN = r"F:/whisper.cpp/build/bin/Release/whisper-cli.exe"
#MODEL_DIR = r"F:/whisper.cpp/models"
#OUTPUT_DIR = r"F:/whisper.cpp/outputs"

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

WHISPER_BIN = os.path.join(BASE_DIR, "build/bin/Release/whisper-cli.exe")
MODEL_DIR   = os.path.join(BASE_DIR, "models")
OUTPUT_DIR  = os.path.join(BASE_DIR, "outputs")

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
