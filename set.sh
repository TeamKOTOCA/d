#!/bin/bash
set -euo pipefail

BASE_URL="https://d.kotoca.net"
INSTALL_DIR="$HOME/.local/libexec/d"
LOGIC_FILE="$INSTALL_DIR/d.sh"

echo "1. ディレクトリ作成: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

echo "2. 本体（d.sh）の取得"
curl -fsSL "$BASE_URL/d.sh" -o "$LOGIC_FILE"
chmod 700 "$LOGIC_FILE"

echo "3. シェル設定ファイルへの登録"

# 追加する関数定義
FUNC_DEF="
# d - interactive directory navigator
d() {
  source \"$LOGIC_FILE\"
}
"

# ターゲットとなる設定ファイルのリスト
# ファイルが存在する場合のみ登録を試みる
TARGETS=()
[[ -f "$HOME/.bashrc" ]] && TARGETS+=("$HOME/.bashrc")
[[ -f "$HOME/.zshrc" ]] && TARGETS+=("$HOME/.zshrc")

if [ ${#TARGETS[@]} -eq 0 ]; then
    # どちらも存在しない場合は新規で .bashrc を作る（または手動設定を促す）
    TARGETS=("$HOME/.bashrc")
    touch "$HOME/.bashrc"
fi

for rc_file in "${TARGETS[@]}"; do
    if ! grep -Fq "d() {" "$rc_file"; then
        echo "$FUNC_DEF" >> "$rc_file"
        echo "✅ $rc_file に関数 'd' を追加しました。"
    else
        echo "ℹ️ $rc_file には既に関数が登録されています。"
    fi
done

echo "------------------------------------"
echo "インストール完了"
echo "新しい設定を反映するには、ターミナルを再起動するか以下を実行してください:"
for rc_file in "${TARGETS[@]}"; do
    echo "  source $rc_file"
done
echo "------------------------------------"
