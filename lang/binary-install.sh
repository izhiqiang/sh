#!/usr/bin/env bash
set -e

# curl -sSL https://raw.githubusercontent.com/izhiqiang/sh/main/lang/binary-install.sh | bash -s go 1.18
# bash binary-install.sh go 1.18

# curl -sSL https://raw.githubusercontent.com/izhiqiang/sh/main/lang/binary-install.sh | bash -s node 20.18.0
# bash binary-install.sh node 20.18.0

# curl -sSL https://raw.githubusercontent.com/izhiqiang/sh/main/lang/binary-install.sh | bash -s java 8
# bash binary-install.sh java 8

cmd=${1}
version=${2}
local_path="/usr/local/lang/"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    ARCH="arm64"
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

# -------------------------------------------- install node start-------------------------------------------------------------------------------
install_go() {
  local version="${1}"
  local download_url="https://go.dev/dl/go${version}.${OS}-${ARCH}.tar.gz"
  local worker_path="${local_path}golang/${1}"
  install "${download_url}" "${worker_path}" "go-${version}.tar.gz"
}

# -------------------------------------------- install golang end-------------------------------------------------------------------------------


# -------------------------------------------- install golang start-------------------------------------------------------------------------------
install_node() {
  local version="${1}"
  if [ "$ARCH" = "amd64" ]; then
      ARCH="x64"
  fi
  local download_url="https://nodejs.org/dist/v${version}/node-v${version}-${OS}-${ARCH}.tar.gz"
  local worker_path="${local_path}nodejs/${1}"
  install "${download_url}" "${worker_path}" "node-${version}.tar.gz"
}
# -------------------------------------------- install node end-------------------------------------------------------------------------------


# -------------------------------------------- install java start-------------------------------------------------------------------------------
declare jdk_liunx_url_versions=(
  [8]="https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz"
  [9]="https://repo.huaweicloud.com/java/jdk/9.0.1+11/jdk-9.0.1_linux-x64_bin.tar.gz"
  [10]="https://repo.huaweicloud.com/java/jdk/10.0.2+13/jdk-10.0.2_linux-x64_bin.tar.gz"
  [11]="https://repo.huaweicloud.com/java/jdk/11.0.2+9/jdk-11.0.2_linux-x64_bin.tar.gz"
  [12]="https://repo.huaweicloud.com/java/jdk/12.0.2+10/jdk-12.0.2_linux-x64_bin.tar.gz"
  [13]="https://repo.huaweicloud.com/java/jdk/13+33/jdk-13_linux-x64_bin.tar.gz"
)
install_java(){
  if [ "$OS" != "linux" ]; then
    log "The current script does not support installing Java on the ${OS} operating system"
    exit 1
  fi
  local version="${1}"
  local download_url=""
  local worker_path="${local_path}java/${1}"
  if [ -n "${jdk_liunx_url_versions[$version]}" ]; then
    download_url="${jdk_liunx_url_versions[$version]}"
  else
    log "on ${OS} Invalid Java version: $version"
    exit 1
  fi
   install "${download_url}" "${worker_path}" "jdk-${version}.tar.gz"
}
# ------------------------------------------ install java end---------------------------------------------------------------------------------------

case "${cmd}" in
  "go")
    install_go ${version}
    ;;
  "node")
    install_node ${version}
    ;;
  "java")
    install_java ${version}
    ;;
  *)
    log "Operation ${cmd} is not supported"
    exit 1
    ;;
esac