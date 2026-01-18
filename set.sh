#!/bin/bash
# set.sh

set -euo pipefail

# 設定項目
BASE_URL="https://d.kotoca.net"
INSTALL_DIR="$HOME/.local/libexec/d"
LOGIC_FILE="$INSTALL_DIR/d.sh"
BASHRC="$HOME/.bashrc"

echo "1. ディレクトリ作成: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

echo "2. ロジック本体（d.sh）の配置"
# https://d.kotoca.net/d.sh から取得
curl -fsSL "$BASE_URL/d.sh" -o "$LOGIC_FILE"
chmod 700 "$LOGIC_FILE"

echo "3. .bashrc に関数 'd' を登録"
touch "$BASHRC"

# 登録する関数定義
# $HOME をリテラルで書き込むのではなく、実行時に展開されるよう定義
FUNC_DEF="
d() {
  source \"$LOGIC_FILE\"
}
"

if ! grep -Fq "d() {" "$BASHRC"; then
  echo "$FUNC_DEF" >> "$BASHRC"
  echo "関数 'd' を $BASHRC に追加しました。"
else
  echo "既に関数 'd' は登録されています。スキップします。"
fi

echo "------------------------------------"
echo "インストール完了"
echo "反映するには以下のコマンドを実行してください:"
echo "  source ~/.bashrc"
echo "------------------------------------"
