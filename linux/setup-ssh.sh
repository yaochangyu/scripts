#!/bin/bash

# 🔐 SSH 部署金鑰設定腳本
# 用途: 產生 SSH 金鑰並自動複製到遠端伺服器

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置變數
REMOTE_HOST="${1:-172.17.0.1}"
REMOTE_USER="${2:-root}"
SSH_KEY_NAME="${3:-techplus-web-deploy}"
SSH_KEY_COMMENT="${4:-techplus-web-deploy}"
SSH_KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🔐 SSH 部署金鑰自動設定${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ==========================================
# 步驟 1: 檢查或產生 SSH 金鑰
# ==========================================
echo -e "${YELLOW}[步驟 1]${NC} 檢查/產生 SSH 金鑰..."
echo "路徑: $SSH_KEY_PATH"
echo ""

if [ -f "$SSH_KEY_PATH" ]; then
    echo -e "${YELLOW}⚠️  金鑰已存在${NC}"
    read -p "是否要重新產生? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "✓ 使用現有金鑰"
    else
        echo -e "${YELLOW}正在刪除舊金鑰...${NC}"
        rm -f "$SSH_KEY_PATH" "$SSH_KEY_PATH.pub"
        echo -e "${YELLOW}正在產生新金鑰...${NC}"
        ssh-keygen -t ed25519 -C "$SSH_KEY_COMMENT" -f "$SSH_KEY_PATH" -N ""
	    #ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N ""

        echo -e "${GREEN}✓ 新金鑰已產生${NC}"
    fi
else
    echo -e "${YELLOW}正在產生新金鑰...${NC}"
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$SSH_KEY_COMMENT" -f "$SSH_KEY_PATH" -N ""
    #ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N ""
    echo -e "${GREEN}✓ 金鑰已產生${NC}"
fi

# ==========================================
# 步驟 2: 顯示公鑰資訊
# ==========================================
echo ""
echo -e "${YELLOW}[步驟 2]${NC} 公鑰資訊"
echo "---"
cat "$SSH_KEY_PATH.pub"
echo "---"
echo ""

# ==========================================
# 步驟 3: 複製公鑰到遠端伺服器
# ==========================================
echo -e "${YELLOW}[步驟 3]${NC} 複製公鑰到遠端伺服器..."
echo "遠端位址: $REMOTE_USER@$REMOTE_HOST"
echo ""

# 檢查遠端連線
if ssh-keyscan "$REMOTE_HOST" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ 遠端主機連線正常${NC}"
else
    echo -e "${RED}✗ 無法連線到遠端主機${NC}"
    exit 1
fi

# 使用 ssh-copy-id 複製公鑰
echo -e "${YELLOW}準備複製公鑰... (需要輸入遠端伺服器密碼)${NC}"
ssh-copy-id -i "$SSH_KEY_PATH.pub" "$REMOTE_USER@$REMOTE_HOST"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 公鑰已成功複製到遠端伺服器${NC}"
else
    echo -e "${RED}✗ 公鑰複製失敗${NC}"
    exit 1
fi

# ==========================================
# 步驟 4: 驗證 SSH 連線
# ==========================================
echo ""
echo -e "${YELLOW}[步驟 4]${NC} 驗證 SSH 連線..."
echo ""

if ssh -i "$SSH_KEY_PATH" "$REMOTE_USER@$REMOTE_HOST" "echo '✓ SSH 連線成功!'" 2>/dev/null; then
    echo -e "${GREEN}✓ SSH 無密碼登入驗證成功${NC}"
else
    echo -e "${RED}✗ SSH 連線驗證失敗${NC}"
    exit 1
fi

# ==========================================
# 步驟 5: 顯示總結和下一步
# ==========================================
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ SSH 設定完成!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "📋 設定總結:"
echo "  • 私鑰位置: $SSH_KEY_PATH"
echo "  • 公鑰位置: $SSH_KEY_PATH.pub"
echo "  • 遠端伺服器: $REMOTE_HOST"
echo "  • 遠端使用者: $REMOTE_USER"
echo ""
echo "🔑 登入方式:"
echo "  ssh -i $SSH_KEY_PATH $REMOTE_USER@$REMOTE_HOST"
echo ""
echo "📌 下一步 - 配置 GitHub Repository Secrets:"
echo ""
echo "1️⃣  SSH_PRIVATE_KEY"
echo "   執行: cat $SSH_KEY_PATH"
echo "   將完整內容複製到 GitHub Secrets"
echo ""
echo "2️⃣  REMOTE_HOST (可選)"
echo "   值: $REMOTE_HOST"
echo ""
echo "3️⃣  REMOTE_USER (可選)"
echo "   值: $REMOTE_USER"
echo ""
echo "📖 GitHub 設定位置:"
echo "   https://github.com/juandesigns/techplus-web/settings/secrets/actions"
echo ""
echo -e "${YELLOW}💡 提示: 使用以下指令複製私鑰到剪貼簿 (macOS):${NC}"
echo "   cat $SSH_KEY_PATH | pbcopy"
echo ""
echo -e "${YELLOW}💡 提示: 使用以下指令複製私鑰到剪貼簿 (Linux):${NC}"
echo "   cat $SSH_KEY_PATH | xclip -selection clipboard"
echo ""
