📌 背景
在 Windows 下，CMD 和 PowerShell 的语法不同，设置代理时需要区分。

CMD 使用 set 命令。

PowerShell 使用 $env: 环境变量。

🚀 快速开始
1. 打开 PowerShell
如果 powershell 命令不可用，可以直接运行：

cmd
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
进入后提示符会变成：

Code
PS C:\Users\xxx>
2. 在 PowerShell 中设置代理
powershell
# 设置代理
$env:HTTP_PROXY = "http://192.168.0.107:10808"
$env:HTTPS_PROXY = "http://192.168.0.107:10808"

# 查看代理
echo $env:HTTP_PROXY
echo $env:HTTPS_PROXY

# 取消代理
Remove-Item Env:HTTP_PROXY, Env:HTTPS_PROXY -ErrorAction SilentlyContinue
3. 在 CMD 中设置代理
cmd
set HTTP_PROXY=http://192.168.0.107:10808
set HTTPS_PROXY=http://192.168.0.107:10808
取消代理：

cmd
set HTTP_PROXY=
set HTTPS_PROXY=
4. 持久化配置（推荐）
在 PowerShell 配置文件 $PROFILE 中添加函数：

powershell
function proxy_on {
    param([string]$Proxy = "http://192.168.0.107:10808")
    $env:HTTP_PROXY = $Proxy
    $env:HTTPS_PROXY = $Proxy
    Write-Host "Proxy ON: $Proxy"
}

function proxy_off {
    Remove-Item Env:HTTP_PROXY, Env:HTTPS_PROXY -ErrorAction SilentlyContinue
    Write-Host "Proxy OFF"
}
保存后运行 . $PROFILE 或重启 PowerShell，即可使用：

powershell
proxy_on
proxy_off
⚠️ 注意事项
CMD 与 PowerShell 语法不同，不要混用。

环境变量方式只在当前会话有效，关闭窗口后失效。

如果需要系统级代理，可用：

cmd
netsh winhttp set proxy 192.168.0.107:10808
netsh winhttp reset proxy
这样整理后，你的项目文档就清晰了，维护者能快速理解如何在不同环境下设置代理。
