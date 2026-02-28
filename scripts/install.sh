#!/bin/bash
# install.sh - Clara Companion Installer
# Usage: curl -fsSL https://gist.githubusercontent.com/claraverse-space/87a840d4a462c2787ce958691fa267b4/raw/install.sh | bash
#        curl -fsSL <url> | bash -s -- [install|update|uninstall]

set -euo pipefail

# Configuration
VERSION="${CLARA_VERSION:-latest}"
INSTALL_DIR="${CLARA_INSTALL_DIR:-}"
GITHUB_REPO="claraverse-space/clara-companion-releases"
BINARY_NAME="clara-companion"
RELEASE_PREFIX="clara_companion"
REMOVE_CONFIG="${REMOVE_CONFIG:-false}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

error() { echo -e "${RED}${BOLD}error${NC}: $1" >&2; exit 1; }
info()  { echo -e "${BLUE}${BOLD}info${NC}: $1"; }
success() { echo -e "${GREEN}${BOLD}success${NC}: $1"; }
warn()  { echo -e "${YELLOW}${BOLD}warn${NC}: $1"; }

print_banner() {
  echo ""
  echo -e "${BOLD}  Clara Companion Installer${NC}"
  echo -e "  Desktop agent for ClaraVerse Nexus"
  echo ""
}

detect_os_arch() {
  OS="$(uname -s)"
  ARCH="$(uname -m)"

  case "$OS" in
    Darwin)  OS="darwin" ;;
    Linux)   OS="linux" ;;
    MINGW*|MSYS*|CYGWIN*)
      echo ""
      echo "  For Windows, download the .exe from:"
      echo "  https://github.com/$GITHUB_REPO/releases/latest"
      echo ""
      exit 1 ;;
    *) error "Unsupported OS: $OS" ;;
  esac

  case "$ARCH" in
    x86_64)        ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) error "Unsupported architecture: $ARCH" ;;
  esac

  info "Detected: $OS/$ARCH"
}

get_latest_version() {
  local latest
  latest=$(curl -fsSL "https://api.github.com/repos/$GITHUB_REPO/releases/latest" 2>/dev/null |
           grep '"tag_name"' |
           sed -E 's/.*"v?([^"]+)".*/\1/' |
           head -1)

  if [[ -z "$latest" ]]; then
    error "Failed to fetch latest version. Check your internet connection."
  fi

  echo "${latest#v}"
}

get_install_dir() {
  if [[ -n "$INSTALL_DIR" ]]; then
    mkdir -p "$INSTALL_DIR" 2>/dev/null || true
    echo "$INSTALL_DIR"
    return
  fi

  if [[ -w "/usr/local/bin" ]]; then
    echo "/usr/local/bin"
    return
  fi

  mkdir -p "$HOME/.local/bin"
  echo "$HOME/.local/bin"
}

download_binary() {
  local version=$1 os=$2 arch=$3
  local tmpdir="${TMPDIR:-/tmp}"
  local asset="${RELEASE_PREFIX}-${os}-${arch}"
  local binary_url="https://github.com/$GITHUB_REPO/releases/download/v${version}/${asset}"
  local checksum_url="https://github.com/$GITHUB_REPO/releases/download/v${version}/checksums.txt"

  info "Downloading $BINARY_NAME v$version..."

  if ! curl -fsSL "$binary_url" -o "$tmpdir/$BINARY_NAME"; then
    error "Failed to download from $binary_url"
  fi

  info "Verifying checksum..."
  local expected
  expected=$(curl -fsSL "$checksum_url" 2>/dev/null | grep "$asset" | awk '{print $1}' || true)

  if [[ -n "$expected" ]]; then
    local actual
    if command -v sha256sum &>/dev/null; then
      actual=$(sha256sum "$tmpdir/$BINARY_NAME" | awk '{print $1}')
    elif command -v shasum &>/dev/null; then
      actual=$(shasum -a 256 "$tmpdir/$BINARY_NAME" | awk '{print $1}')
    else
      warn "Skipping checksum verification (sha256sum not found)"
      return
    fi

    if [[ "$expected" != "$actual" ]]; then
      rm -f "$tmpdir/$BINARY_NAME"
      error "Checksum mismatch! Expected: $expected, Got: $actual"
    fi
    success "Checksum verified"
  else
    warn "Skipping checksum verification (checksums.txt not found in release)"
  fi
}

update_path() {
  local install_dir=$1

  if [[ ":$PATH:" == *":$install_dir:"* ]]; then
    return
  fi

  local shell_rc=""
  case "${SHELL:-}" in
    */zsh)
      shell_rc="${HOME}/.zshrc"
      [[ -f "$HOME/.zprofile" ]] && shell_rc="$HOME/.zprofile"
      ;;
    */bash)
      for rc in "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.profile"; do
        [[ -f "$rc" ]] && shell_rc="$rc" && break
      done
      [[ -z "$shell_rc" ]] && shell_rc="$HOME/.profile"
      ;;
    */fish)
      shell_rc="$HOME/.config/fish/config.fish"
      mkdir -p "$HOME/.config/fish"
      ;;
    *)
      shell_rc="$HOME/.profile"
      ;;
  esac

  if [[ -n "$shell_rc" ]] && ! grep -q "# clara-companion" "$shell_rc" 2>/dev/null; then
    {
      echo ""
      echo "# clara-companion"
      if [[ "$shell_rc" == *"fish"* ]]; then
        echo "set -gx PATH \"$install_dir\" \$PATH"
      else
        echo "export PATH=\"$install_dir:\$PATH\""
      fi
    } >> "$shell_rc"
    info "Added $install_dir to PATH in $shell_rc"
    echo ""
    echo "  Restart your shell or run:  source $shell_rc"
    echo ""
  fi
}

print_next_steps() {
  echo ""
  echo -e "${GREEN}${BOLD}  Clara Companion installed successfully!${NC}"
  echo ""
  echo "  Get started:"
  echo "    clara-companion login          # Authenticate with ClaraVerse"
  echo "    clara-companion daemon start   # Start the background agent"
  echo ""
  echo "  Other commands:"
  echo "    clara-companion status         # Check connection"
  echo "    clara-companion --help         # See all commands"
  echo ""
}

do_install() {
  print_banner
  detect_os_arch

  if [[ "$VERSION" == "latest" ]]; then
    info "Fetching latest version..."
    VERSION=$(get_latest_version)
  fi

  local install_dir
  install_dir=$(get_install_dir)
  local tmpdir="${TMPDIR:-/tmp}"

  info "Installing $BINARY_NAME v$VERSION to $install_dir"

  download_binary "$VERSION" "$OS" "$ARCH"

  chmod +x "$tmpdir/$BINARY_NAME"

  if [[ -w "$install_dir" ]]; then
    mv "$tmpdir/$BINARY_NAME" "$install_dir/$BINARY_NAME"
  else
    info "Requesting sudo to install to $install_dir..."
    sudo mv "$tmpdir/$BINARY_NAME" "$install_dir/$BINARY_NAME"
  fi

  update_path "$install_dir"

  success "$BINARY_NAME v$VERSION installed to $install_dir/$BINARY_NAME"
  print_next_steps
}

do_update() {
  print_banner
  local current_path
  current_path=$(command -v "$BINARY_NAME" 2>/dev/null || true)

  if [[ -z "$current_path" ]]; then
    info "$BINARY_NAME not found, performing fresh install..."
    do_install
    return
  fi

  local current_version
  current_version=$("$current_path" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
  info "Current version: $current_version"

  if [[ "$VERSION" == "latest" ]]; then
    info "Fetching latest version..."
    VERSION=$(get_latest_version)
  fi

  if [[ "$current_version" == "$VERSION" ]]; then
    success "Already at version $VERSION"
    return
  fi

  info "Updating to v$VERSION..."
  detect_os_arch

  cp "$current_path" "$current_path.bak"
  INSTALL_DIR=$(dirname "$current_path")

  local tmpdir="${TMPDIR:-/tmp}"
  download_binary "$VERSION" "$OS" "$ARCH"
  chmod +x "$tmpdir/$BINARY_NAME"

  if [[ -w "$INSTALL_DIR" ]]; then
    mv "$tmpdir/$BINARY_NAME" "$current_path"
  else
    sudo mv "$tmpdir/$BINARY_NAME" "$current_path"
  fi

  rm -f "$current_path.bak"
  success "$BINARY_NAME updated to v$VERSION"
}

do_uninstall() {
  print_banner
  local current_path
  current_path=$(command -v "$BINARY_NAME" 2>/dev/null || true)

  [[ -z "$current_path" ]] && error "$BINARY_NAME not found in PATH"

  info "Uninstalling $BINARY_NAME from $current_path..."

  "$current_path" service stop 2>/dev/null || true
  "$current_path" service uninstall 2>/dev/null || true

  if [[ -w "$(dirname "$current_path")" ]]; then
    rm -f "$current_path"
  else
    sudo rm -f "$current_path"
  fi

  success "Removed $current_path"

  if [[ "$REMOVE_CONFIG" == "true" ]]; then
    [[ -d "$HOME/.claraverse" ]] && rm -rf "$HOME/.claraverse" && info "Removed ~/.claraverse"
  else
    echo ""
    echo "  Config preserved: ~/.claraverse"
    echo "  To remove: rm -rf ~/.claraverse"
    echo ""
  fi

  success "$BINARY_NAME uninstalled"
}

main() {
  local action="${1:-install}"
  case "$action" in
    install)   do_install ;;
    update)    do_update ;;
    uninstall) do_uninstall ;;
    -h|--help|help)
      echo "Usage: curl -fsSL <url> | bash -s -- [install|update|uninstall]"
      echo ""
      echo "Environment variables:"
      echo "  CLARA_VERSION       Version to install (default: latest)"
      echo "  CLARA_INSTALL_DIR   Custom install directory"
      echo "  REMOVE_CONFIG       Set 'true' to delete ~/.claraverse on uninstall"
      ;;
    *) error "Unknown action: $action. Use install, update, or uninstall." ;;
  esac
}

main "$@"
