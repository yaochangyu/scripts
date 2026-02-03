# SSH 部署金鑰設定腳本

## 概述

`setup-ssh.sh` 是一個自動化 SSH 部署金鑰設定的 Bash 腳本，可用於快速配置 SSH 無密碼登入到遠端伺服器。

## 功能特性

- 🔐 自動產生 SSH 金鑰（Ed25519）
- ⚡ 自動複製公鑰到遠端伺服器
- ✓ 驗證 SSH 連線
- 📋 生成部署指南（GitHub Secrets 配置）
- ⚙️ 支援參數外部注入，提高可重用性

## 使用方式

### 基本語法

```bash
./linux/setup-ssh.sh [REMOTE_HOST] [REMOTE_USER] [SSH_KEY_NAME] [SSH_KEY_COMMENT]
```

### 參數說明

| 參數 | 說明 | 預設值 | 示例 |
|------|------|--------|------|
| `REMOTE_HOST` | 遠端伺服器 IP 或域名 | `172.17.0.1` | `192.168.1.100` |
| `REMOTE_USER` | 遠端伺服器登入使用者 | `root` | `ubuntu` |
| `SSH_KEY_NAME` | SSH 私鑰檔名 | `techplus-web-deploy` | `my-deploy-key` |
| `SSH_KEY_COMMENT` | SSH 金鑰備註 | `techplus-web-deploy` | `Production Deployment` |

### 使用範例

#### 1. 使用預設值
```bash
./linux/setup-ssh.sh
```
使用所有預設設定連線到 `172.17.0.1`

#### 2. 自訂遠端伺服器和使用者
```bash
./linux/setup-ssh.sh 192.168.1.100 ubuntu
```

#### 3. 完整自訂所有參數
```bash
./linux/setup-ssh.sh 192.168.1.100 ubuntu my-prod-key "Production Deploy Key"
```

#### 4. 只自訂金鑰名稱
```bash
./linux/setup-ssh.sh 172.17.0.1 root github-deploy "GitHub Action Deploy"
```

## 執行步驟

脚本會自動執行以下步驟：

1. **檢查/產生 SSH 金鑰**
   - 若金鑰已存在，詢問是否重新產生
   - 產生新的 Ed25519 格式金鑰

2. **顯示公鑰資訊**
   - 輸出公鑰內容供查驗

3. **複製公鑰到遠端伺服器**
   - 驗證遠端連線
   - 使用 `ssh-copy-id` 複製公鑰
   - 需要輸入遠端伺服器密碼

4. **驗證 SSH 連線**
   - 使用私鑰測試無密碼登入

5. **顯示總結和下一步**
   - 輸出配置摘要
   - 提供 GitHub Secrets 配置指南

## GitHub Actions 配置

執行完成後，根據提示配置 GitHub Repository Secrets：

### 1. SSH_PRIVATE_KEY
```bash
cat ~/.ssh/your-key-name
```
複製完整內容到 GitHub Secrets

### 2. REMOTE_HOST（可選）
```
172.17.0.1
```

### 3. REMOTE_USER（可選）
```
root
```

GitHub 設定位置：
```
https://github.com/your-org/your-repo/settings/secrets/actions
```

## 快速複製金鑰指令

### macOS
```bash
cat ~/.ssh/techplus-web-deploy | pbcopy
```

### Linux
```bash
cat ~/.ssh/techplus-web-deploy | xclip -selection clipboard
```

### Windows (PowerShell)
```powershell
Get-Content $HOME\.ssh\techplus-web-deploy | Set-Clipboard
```

## 常見問題

### Q: 如果金鑰已存在，會發生什麼？
A: 腳本會詢問是否重新產生，若選否則使用現有金鑰。

### Q: 遠端連線失敗？
A: 檢查以下項目：
- IP 地址或域名是否正確
- 遠端伺服器是否開啟 SSH 服務（預設 22 埠）
- 防火牆是否允許 SSH 連線

### Q: 如何變更金鑰名稱？
A: 使用第 3 個參數指定金鑰名稱：
```bash
./linux/setup-ssh.sh 139.162.106.77 root new-key-name
```

## 檔案位置

- **私鑰**：`~/.ssh/[SSH_KEY_NAME]`
- **公鑰**：`~/.ssh/[SSH_KEY_NAME].pub`

## 安全建議

⚠️ **重要**：
- 私鑰檔案權限應為 `600`（腳本自動處理）
- 不要分享或上傳私鑰到版本控制系統
- 定期檢查 SSH 配置檔案權限
- 使用強密碼保護私鑰（若有加密）

## 相關資源

- [SSH 金鑰配置指南](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [GitHub Actions 部署金鑰](https://docs.github.com/en/developers/overview/managing-deploy-keys)
