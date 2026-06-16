# CMD 和 PowerShell 代理配置指南

## 📌 背景

在 Windows 下，CMD 和 PowerShell 的语法不同，设置代理时需要区分：

- **CMD** 使用 `set` 命令
- **PowerShell** 使用 `$env:` 环境变量

---

## 🚀 快速开始

### 1. 打开 PowerShell

如果 `powershell` 命令不可用，可以直接运行以下路径：

```powershell
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
```

进入后提示符会变成：

```
PS C:\Users\xxx>
```

---

### 2. 在 PowerShell 中设置代理

#### 设置代理
```powershell
$env:HTTP_PROXY = "http://192.168.0.107:10808"
$env:HTTPS_PROXY = "http://192.168.0.107:10808"
```

#### 查看代理
```powershell
echo $env:HTTP_PROXY
echo $env:HTTPS_PROXY
```

#### 取消代理
```powershell
Remove-Item Env:HTTP_PROXY, Env:HTTPS_PROXY -ErrorAction SilentlyContinue
```

---

### 3. 在 CMD 中设置代理

#### 设置代理
```cmd
set HTTP_PROXY=http://192.168.0.107:10808
set HTTPS_PROXY=http://192.168.0.107:10808
```

#### 取消代理
```cmd
set HTTP_PROXY=
set HTTPS_PROXY=
```

---

### 4. 持久化配置（推荐）

在 PowerShell 配置文件 `$PROFILE` 中添加以下函数：

```powershell
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
```

保存后运行以下命令使配置生效：

```powershell
. $PROFILE
```

或重启 PowerShell，之后即可使用：

```powershell
proxy_on
proxy_off
```

---

## ⚠️ 注意事项

| 注意项 | 说明 |
|------|------|
| 语法区别 | CMD 与 PowerShell 语法不同，**不要混用** |
| 会话有效性 | 环境变量方式只在当前会话有效，关闭窗口后失效 |
| 系统级代理 | 如果需要系统级代理，可使用 `netsh` 命令 |

### 系统级代理配置（可选）

#### 设置系统级代理
```cmd
netsh winhttp set proxy 192.168.0.107:10808
```

#### 重置系统级代理
```cmd
netsh winhttp reset proxy
```

---

## 总结

选择适合你的配置方式：
- **临时配置**：直接设置环境变量（会话结束后失效）
- **持久化配置**：在 PowerShell 配置文件中添加函数
- **系统级配置**：使用 `netsh` 命令（影响整个系统）
