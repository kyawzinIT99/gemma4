#!/bin/bash
# ============================================================
#  GEMMA 4 — Full Local Deployment Setup (macOS)
#  Released: April 2, 2026 | Source: Ollama / Hugging Face
#  Models: gemma4:e4b (4B multimodal) · gemma4:e2b · gemma4:26b · gemma4:31b
# ============================================================

set -e

BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

print_header() {
  echo -e "\n${CYAN}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}${BOLD}║       GEMMA 4 — Local AI Deployment Setup        ║${RESET}"
  echo -e "${CYAN}${BOLD}║  Google · Apache 2.0 · Released April 2, 2026    ║${RESET}"
  echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════╝${RESET}\n"
}

print_step() { echo -e "${GREEN}${BOLD}▶ $1${RESET}"; }
print_info() { echo -e "${CYAN}  $1${RESET}"; }
print_warn() { echo -e "${YELLOW}  ⚠  $1${RESET}"; }
print_ok()   { echo -e "${GREEN}  ✓ $1${RESET}"; }
print_err()  { echo -e "${RED}  ✗ $1${RESET}"; }

# ── Model selection ──────────────────────────────────────────
select_model() {
  echo -e "\n${BOLD}Select Gemma 4 model variant:${RESET}"
  echo "  1) gemma4:e4b   — 4B Multimodal (vision + audio + file) ★ Recommended"
  echo "  2) gemma4:e2b   — 2B Text-only (fastest, smallest RAM)"
  echo "  3) gemma4:26b   — 26B Mixture-of-Experts (needs 24 GB VRAM)"
  echo "  4) gemma4:31b   — 31B Dense flagship (needs 32 GB+ RAM)"
  echo ""
  read -rp "  Enter choice [1-4, default=1]: " choice
  case "${choice}" in
    2) MODEL="gemma4:e2b"  ;;
    3) MODEL="gemma4:26b"  ;;
    4) MODEL="gemma4:31b"  ;;
    *) MODEL="gemma4:e4b"  ;;   # default: multimodal 4B
  esac
  print_ok "Selected model: ${MODEL}"
}

# ── Check macOS ──────────────────────────────────────────────
check_macos() {
  if [[ "$(uname)" != "Darwin" ]]; then
    print_err "This script is designed for macOS. For Linux, edit the Ollama install step."
    exit 1
  fi
  print_ok "macOS detected: $(sw_vers -productVersion)"
}

# ── Install Homebrew ─────────────────────────────────────────
install_homebrew() {
  if command -v brew &>/dev/null; then
    print_ok "Homebrew already installed"
  else
    print_step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Apple Silicon path fix
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    print_ok "Homebrew installed"
  fi
}

# ── Install Ollama ───────────────────────────────────────────
install_ollama() {
  if command -v ollama &>/dev/null; then
    OLLAMA_VER=$(ollama --version 2>&1 | head -1)
    print_ok "Ollama already installed: ${OLLAMA_VER}"
  else
    print_step "Installing Ollama (official macOS package)..."
    # Use official installer — most reliable source
    curl -fsSL https://ollama.com/install.sh | sh
    print_ok "Ollama installed"
  fi
}

# ── Start Ollama service ─────────────────────────────────────
start_ollama() {
  print_step "Starting Ollama service..."
  if pgrep -x "ollama" &>/dev/null; then
    print_ok "Ollama already running"
  else
    ollama serve &>/tmp/ollama.log &
    sleep 3
    if pgrep -x "ollama" &>/dev/null; then
      print_ok "Ollama service started"
    else
      print_err "Failed to start Ollama. Check /tmp/ollama.log"
      exit 1
    fi
  fi
}

# ── Pull Gemma 4 model ───────────────────────────────────────
pull_model() {
  print_step "Pulling ${MODEL} from Ollama registry..."
  print_info "Source: https://ollama.com/library/gemma4"
  print_info "This may take a while depending on your connection..."
  ollama pull "${MODEL}"
  print_ok "${MODEL} downloaded and ready"
}

# ── Install Open WebUI ───────────────────────────────────────
install_open_webui() {
  print_step "Installing Open WebUI (supports live cam + file attachments)..."

  # Check Python
  if ! command -v python3 &>/dev/null; then
    print_warn "Python 3 not found. Installing via Homebrew..."
    brew install python3
  fi
  PY_VER=$(python3 --version)
  print_ok "Python: ${PY_VER}"

  # Check pip
  if ! command -v pip3 &>/dev/null; then
    python3 -m ensurepip --upgrade
  fi

  # Install Open WebUI
  if pip3 show open-webui &>/dev/null 2>&1; then
    print_ok "Open WebUI already installed"
    pip3 install --upgrade open-webui 2>/dev/null || true
  else
    print_info "Installing open-webui (this takes ~2 minutes)..."
    pip3 install open-webui
    print_ok "Open WebUI installed"
  fi
}

# ── Create launcher ──────────────────────────────────────────
create_launcher() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cat > "${SCRIPT_DIR}/launch_gemma4.sh" <<'LAUNCHER'
#!/bin/bash
# Gemma 4 Launcher — starts Ollama + Open WebUI

GREEN="\033[0;32m"; CYAN="\033[0;36m"; RESET="\033[0m"
MODEL="${GEMMA4_MODEL:-gemma4:e4b}"

echo -e "${CYAN}Starting Ollama...${RESET}"
pgrep -x ollama &>/dev/null || { ollama serve &>/tmp/ollama.log & sleep 3; }

echo -e "${CYAN}Loading model: ${MODEL}${RESET}"
ollama run "${MODEL}" --keepalive 60m &>/dev/null &

echo -e "${CYAN}Starting Open WebUI at http://localhost:8080${RESET}"
echo -e "${GREEN}✓ Live cam: enabled in UI → Attach → Camera${RESET}"
echo -e "${GREEN}✓ File attach: enabled in UI → Attach → File${RESET}"
echo ""
open-webui serve --host 0.0.0.0 --port 8080 &

sleep 4
open "http://localhost:8080"
echo -e "${GREEN}✓ Open WebUI launched in your browser${RESET}"
wait
LAUNCHER
  chmod +x "${SCRIPT_DIR}/launch_gemma4.sh"
  print_ok "Launcher created: launch_gemma4.sh"
}

# ── Print summary ────────────────────────────────────────────
print_summary() {
  echo ""
  echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}${BOLD}║             SETUP COMPLETE ✓                     ║${RESET}"
  echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
  echo ""
  echo -e "  ${BOLD}Model loaded:${RESET}  ${MODEL}"
  echo -e "  ${BOLD}WebUI URL:${RESET}     http://localhost:8080"
  echo -e "  ${BOLD}Live cam:${RESET}      Chat → 📎 → Camera icon"
  echo -e "  ${BOLD}File attach:${RESET}   Chat → 📎 → Upload file"
  echo -e "  ${BOLD}API endpoint:${RESET}  http://localhost:11434"
  echo ""
  echo -e "  ${BOLD}To start later:${RESET}"
  echo -e "  ${CYAN}  ./launch_gemma4.sh${RESET}"
  echo ""
  echo -e "  ${BOLD}Switch model:${RESET}"
  echo -e "  ${CYAN}  GEMMA4_MODEL=gemma4:e2b ./launch_gemma4.sh${RESET}"
  echo ""
}

# ── Main ─────────────────────────────────────────────────────
main() {
  print_header
  check_macos
  select_model
  install_homebrew
  install_ollama
  start_ollama
  pull_model
  install_open_webui
  create_launcher
  print_summary
}

main "$@"
