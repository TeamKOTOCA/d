# d - ディレクトリ移動支援ソフト

**`d`** は、ターミナル上で簡単にディレクトリを一覧表示し、ページごとに移動できる軽量なディレクトリナビゲーターです。  
大量のフォルダがある場所でも、キーボードだけで素早く移動できます。

---

## 概要

- ディレクトリをページ単位で表示（1ページあたり10件）
- `n` / `p` で次ページ・前ページに移動
- 数字入力でディレクトリを選択して移動
- `j` / `k` または `↑` / `↓` でカーソル移動
- `/` で検索（部分一致）、`c` で検索クリア
- 画面幅が十分な場合はカーソル位置のフォルダ内容をプレビュー表示（PowerShell版）
- `Enter` で終了
- `..` は親ディレクトリとして特別表示

## 動作環境

- Linux / macOS
  - Bash, Zsh
- Windows
  - PowerShell 5.1+ / PowerShell 7+

## インストール

### Linux / macOS (Bash/Zsh)

```bash
curl -fsSL https://d.kotoca.net/set.sh | bash
source ~/.bashrc
```

> zsh を使っている場合は `source ~/.zshrc` を実行してください。

### Windows (PowerShell)

```powershell
iwr https://d.kotoca.net/set.ps1 -UseBasicParsing | iex
. $PROFILE
```

## 使い方

```text
d
Current: /home/user/projects
Page 1 / 3
--------------------
0) .. (parent)
1) backend
2) frontend
...
--------------------
0-9=select, n=next, p=prev, Enter=quit
```

- `0-9` : 選択して移動
- `j` / `k` または `↑` / `↓` : カーソル移動（PowerShell版）
- `/` : 検索（部分一致・PowerShell版）
- `c` : 検索クリア（PowerShell版）
- `n` : 次のページ
- `p` : 前のページ
- `Enter` : 終了


# 変更を反映
source ~/.bashrc

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/TeamKOTOCA/d)
