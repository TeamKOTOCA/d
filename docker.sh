#!/bin/sh
set -eu

# ===== 設定 =====
DOCKER_USER="dockeruser"   # docker を使うユーザー（既存ユーザー）
ENABLE_IPV4_FORWARD=1

# ===== 前提チェック =====
if [ "$(id -u)" -ne 0 ]; then
  echo "rootで実行してください"
  exit 1
fi

# ===== カーネル機能チェック（LXC向け）=====
if ! grep -q overlay /proc/filesystems; then
  echo "overlayfs が有効ではありません（Proxmox側の設定確認が必要）"
fi

# ===== 必要パッケージ =====
apt-get update
apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# ===== Docker GPGキー =====
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# ===== Docker APT repo =====
ARCH="$(dpkg --print-architecture)"
CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"

echo \
  "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $CODENAME stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update

# ===== Docker install =====
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# ===== IPv4 forward（必要な場合）=====
if [ "$ENABLE_IPV4_FORWARD" -eq 1 ]; then
  sysctl -w net.ipv4.ip_forward=1
fi

# ===== docker グループ =====
if id "$DOCKER_USER" >/dev/null 2>&1; then
  usermod -aG docker "$DOCKER_USER"
else
  echo "ユーザー $DOCKER_USER は存在しません（スキップ）"
fi

# ===== 起動確認 =====
systemctl enable docker
systemctl start docker
docker version

echo "Docker setup 完了"


