#!/bin/bash

MAX_PER_PAGE=10  # 1ページあたりの表示数

while :; do
  # ディレクトリ一覧
  dirs=("..")
  while IFS= read -r -d '' d; do
    dirs+=("$(basename "$d")")
  done < <(find . -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null | LC_ALL=C sort -z)

  total=${#dirs[@]}
  page=0

  while :; do
    start=$((page * MAX_PER_PAGE))
    end=$((start + MAX_PER_PAGE))
    (( end > total )) && end=$total

    # ディレクトリ表示
    echo "Current: $(pwd)"
    echo "--------------------"
    for i in $(seq $start $((end - 1))); do
      item="${dirs[$i]}"
      [[ "$item" == ".." ]] && item="$item (parent)"
      printf "%1d) %s\n" "$i" "$item"
    done
    echo "--------------------"
    echo "n=next, p=prev, Enter=quit"

    # 1文字入力
    read -rsn1 choice
    echo

    case "$choice" in
      "") return 0 2>/dev/null || exit 0 ;;  # 空入力で終了
      n) (( page < (total-1)/MAX_PER_PAGE )) && ((page++)) ;;
      p) (( page > 0 )) && ((page--)) ;;
      [0-9])
        idx=$((choice))
        if (( idx >= start && idx < end )); then
          cd -- "${dirs[$idx]}" || echo "移動失敗"
          break
        else
          echo "Number out of page range."
        fi
        ;;
      *) echo "Invalid input." ;;
    esac
    echo
  done
done