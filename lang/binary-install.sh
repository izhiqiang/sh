#!/usr/bin/env bash
set -e

# curl -sSL https://raw.githubusercontent.com/izhiqiang/sh/main/lang/binary-install.sh | bash -s go 1.18
# bash binary-install.sh go 1.18
# curl -sSL https://raw.githubusercontent.com/izhiqiang/sh/main/lang/binary-install.sh | bash -s node 20.18.0
# bash binary-install node 20.18.0

cmd=${1}
version=${2}
local_path="/usr/local/lang/"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')

ARCH=$(uname -m)
ARCH_NODE=${ARCH}
if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
    ARCH_NODE="x64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    ARCH="arm64"
    ARCH_NODE="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# install Download URL address, store directory, tar file name
install() {
  local download_url="${1}"
  local worker_path="${2}"
  local tar_filename="${3}"

  log "Start downloading:${download_url} -> ${tar_filename}，Please wait a moment..."
  if ! wget --tries=3 "${download_url}" -O "${tar_filename}"; then
    log "Download failed: ${download_url}"
    exit 1
  fi
  
  log "Download completed, currently decompressing:${tar_filename} Go to the directory ${worker_path}..."
  mkdir -p "${worker_path}"
  if ! tar -xzvf "${tar_filename}" -C "${worker_path}" --strip-components=1; then
    log "Decompression failed:${tar_filename}"
    exit 1
  fi
  rm -rf ${tar_filename}
  log "Installation successful, working directory: ${worker_path}"
}

install_go() {
  local version="${1}"
  local download_url="https://go.dev/dl/go${version}.${OS}-${ARCH}.tar.gz"
  local worker_path="${local_path}golang/${1}"
  install "${download_url}" "${worker_path}" "${version}.tar.gz"
}


install_node() {
  local version="${1}"
  local download_url="https://nodejs.org/dist/v${version}/node-v${version}-${OS}-${ARCH_NODE}.tar.gz"
  local worker_path="${local_path}nodejs/${1}"
  install "${download_url}" "${worker_path}" "${version}.tar.gz"
}

case "${cmd}" in
  "go")
    install_go ${version}
    ;;
  "node")
    install_node ${version}
    ;;
  *)
    exit 1
    ;;
esac