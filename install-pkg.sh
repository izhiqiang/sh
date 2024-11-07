#!/usr/bin/env bash
set -e

# Install packages according to different operating systems
# curl -sSL https://raw.githubusercontent.com/izhiqiang/sh/main/install-pkg.sh | bash -s jq

pkg=$1

# Function to log messages with timestamp
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if package name is provided
if [ -z "$pkg" ]; then
  log "Error: No package specified."
  exit 1
fi

install_mac() {
  if command -v brew &> /dev/null; then
    log "Installing $pkg on macOS using Homebrew..."
    brew install "$pkg"
  else
    log "Error: Homebrew not found. Please install Homebrew first."
    exit 1
  fi
}

install_linux() {
  if command -v apt-get &> /dev/null; then
    log "Installing $pkg on Linux using apt-get..."
    sudo apt-get update
    sudo apt-get install -y "$pkg"
  elif command -v yum &> /dev/null; then
    log "Installing $pkg on Linux using yum..."
    sudo yum update -y
    sudo yum install -y "$pkg"
  elif command -v dnf &> /dev/null; then
    log "Installing $pkg on Linux using dnf..."
    sudo dnf install -y "$pkg"
  elif command -v pacman &> /dev/null; then
    log "Installing $pkg on Linux using pacman..."
    sudo pacman -S --noconfirm "$pkg"
  else
    log "Error: Unsupported Linux distribution. Please install the package manually."
    exit 1
  fi
}

install_windows() {
  log "Windows detected. Please install $pkg manually or using a Windows package manager like winget."
  exit 1
}

# Check OS type
os_type=$(uname)
log "Detected OS: $os_type"
log "Installing : $pkg"

# Determine the OS and install the package
case "$os_type" in
  Darwin)
    install_mac
    ;;
  Linux)
    install_linux
    ;;
  CYGWIN*|MINGW*|MSYS*)
    install_windows
    ;;
  *)
    log "Error: Unsupported operating system ($os_type)."
    exit 1
    ;;
esac