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
  total_pages=$(( (total + MAX_PER_PAGE - 1) / MAX_PER_PAGE ))

  while :; do
    start=$((page * MAX_PER_PAGE))
    end=$((start + MAX_PER_PAGE))
    (( end > total )) && end=$total

    echo "Current: $(pwd)"
    echo "Page $((page + 1)) / $total_pages"
    echo "--------------------"

    disp=0
    for ((i=start; i<end; i++)); do
      item="${dirs[$i]}"
      [[ "$item" == ".." ]] && item="$item (parent)"
      printf "%d) %s\n" "$disp" "$item"
      ((disp++))
    done

    echo "--------------------"
    echo "0-9=select, n=next, p=prev, Enter=quit"

    read -rsn1 choice
    echo

    case "$choice" in
      "")
        return 0 2>/dev/null || exit 0
        ;;
      n)
        (( page < total_pages - 1 )) && ((page++))
        ;;
      p)
        (( page > 0 )) && ((page--))
        ;;
      [0-9])
        real=$((start + choice))
        if (( real >= start && real < end )); then
          cd -- "${dirs[$real]}" || echo "移動失敗"
          break
        else
          echo "Number out of page range."
        fi
        ;;
      *)
        echo "Invalid input."
        ;;
    esac
    echo
  done
done