#!/bin/bash
# ============================================================
#  Gemma 4 Model Manager
#  Switch models, check status, update, clean up
# ============================================================

BOLD="\033[1m"; GREEN="\033[0;32m"; CYAN="\033[0;36m"
YELLOW="\033[1;33m"; RED="\033[0;31m"; RESET="\033[0m"

MODELS=(
  "gemma4:e2b   | 2B  | Text only   | ~1.5 GB | Edge/mobile"
  "gemma4:e4b   | 4B  | Multimodal  | ~3.0 GB | ★ Recommended"
  "gemma4:26b   | 26B | MoE         | ~16 GB  | High-end GPU"
  "gemma4:31b   | 31B | Dense       | ~20 GB  | Flagship"
)

MODEL_IDS=("gemma4:e2b" "gemma4:e4b" "gemma4:26b" "gemma4:31b")

banner() {
  echo -e "\n${CYAN}${BOLD}  Gemma 4 Model Manager${RESET}"
  echo -e "${CYAN}  ─────────────────────────────────────────${RESET}"
}

check_ollama() {
  if ! command -v ollama &>/dev/null; then
    echo -e "${RED}  Ollama not installed. Run setup.sh first.${RESET}"
    exit 1
  fi
}

status() {
  banner
  echo -e "${BOLD}  Ollama service:${RESET}"
  if pgrep -x ollama &>/dev/null; then
    echo -e "${GREEN}  ✓ Running (PID: $(pgrep -x ollama))${RESET}"
  else
    echo -e "${RED}  ✗ Not running${RESET}"
  fi
  echo ""
  echo -e "${BOLD}  Downloaded models:${RESET}"
  ollama list 2>/dev/null | grep gemma4 || echo "  (none)"
  echo ""
  echo -e "${BOLD}  Running models:${RESET}"
  ollama ps 2>/dev/null || echo "  (none)"
}

pull_model() {
  banner
  echo -e "${BOLD}  Available Gemma 4 models:${RESET}\n"
  for i in "${!MODELS[@]}"; do
    echo "  $((i+1))) ${MODELS[$i]}"
  done
  echo ""
  read -rp "  Select model [1-4]: " choice
  local idx=$((choice - 1))
  if [[ $idx -ge 0 && $idx -lt ${#MODEL_IDS[@]} ]]; then
    local model="${MODEL_IDS[$idx]}"
    echo -e "\n${CYAN}  Pulling ${model}...${RESET}"
    ollama pull "${model}"
    echo -e "${GREEN}  ✓ ${model} ready${RESET}"
  else
    echo -e "${RED}  Invalid choice${RESET}"
  fi
}

run_model() {
  banner
  echo -e "${BOLD}  Running models:${RESET}"
  ollama list 2>/dev/null | grep gemma4
  echo ""
  read -rp "  Enter model tag to run (e.g. gemma4:e4b): " model
  if [[ -n "$model" ]]; then
    echo -e "${CYAN}  Starting ${model} in terminal...${RESET}"
    ollama run "${model}"
  fi
}

update_all() {
  banner
  echo -e "${CYAN}  Updating all Gemma 4 models...${RESET}"
  ollama list 2>/dev/null | grep gemma4 | awk '{print $1}' | while read -r m; do
    echo -e "\n  Updating ${m}..."
    ollama pull "${m}"
  done
  echo -e "${GREEN}  ✓ All models updated${RESET}"
}

stop_ollama() {
  if pgrep -x ollama &>/dev/null; then
    pkill -x ollama && echo -e "${GREEN}  ✓ Ollama stopped${RESET}"
  else
    echo "  Ollama not running"
  fi
}

delete_model() {
  banner
  echo -e "${BOLD}  Installed models:${RESET}"
  ollama list 2>/dev/null | grep gemma4
  echo ""
  read -rp "  Enter model tag to delete: " model
  if [[ -n "$model" ]]; then
    read -rp "  Delete ${model}? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      ollama rm "${model}"
      echo -e "${GREEN}  ✓ ${model} deleted${RESET}"
    fi
  fi
}

# ── Menu ──────────────────────────────────────────────────────
main_menu() {
  check_ollama
  while true; do
    banner
    echo "  1) Status — check Ollama & models"
    echo "  2) Pull model — download a Gemma 4 variant"
    echo "  3) Run model — start interactive chat"
    echo "  4) Update all — refresh all downloaded models"
    echo "  5) Delete model"
    echo "  6) Stop Ollama service"
    echo "  0) Exit"
    echo ""
    read -rp "  Choice: " opt
    case $opt in
      1) status ;;
      2) pull_model ;;
      3) run_model ;;
      4) update_all ;;
      5) delete_model ;;
      6) stop_ollama ;;
      0) exit 0 ;;
      *) echo -e "${YELLOW}  Invalid option${RESET}" ;;
    esac
    echo ""
    read -rp "  Press Enter to continue..."
  done
}

main_menu
