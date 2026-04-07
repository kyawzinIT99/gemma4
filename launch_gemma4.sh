#!/bin/bash
# ============================================================
#  Gemma 4 Quick Launcher
#  Starts Ollama + Open WebUI — then opens browser
#  Usage:  ./launch_gemma4.sh [model] [port]
#  Example: ./launch_gemma4.sh gemma4:e4b 3000
# ============================================================

MODEL="${1:-${GEMMA4_MODEL:-gemma4:e4b}}"
PREFERRED_PORT="${2:-${WEBUI_PORT:-8080}}"

GREEN="\033[0;32m"; CYAN="\033[0;36m"; YELLOW="\033[1;33m"; BOLD="\033[1m"; RESET="\033[0m"

# ── Find a free port ─────────────────────────────────────────
find_free_port() {
  local start=$1
  local port=$start
  while lsof -iTCP:"${port}" -sTCP:LISTEN &>/dev/null 2>&1; do
    echo -e "${YELLOW}  ⚠ Port ${port} in use — trying $((port+1))...${RESET}" >&2
    port=$((port + 1))
    if [[ $port -gt $((start + 20)) ]]; then
      echo -e "${YELLOW}  ⚠ No free port found near ${start}, using 3456${RESET}" >&2
      port=3456
      break
    fi
  done
  echo "$port"
}

PORT=$(find_free_port "$PREFERRED_PORT")

echo -e "\n${CYAN}${BOLD}  Gemma 4 Launcher${RESET}"
echo -e "${CYAN}  Model : ${MODEL}${RESET}"
echo -e "${CYAN}  WebUI : http://localhost:${PORT}${RESET}\n"

# ── Kill any stale Open WebUI on same port ───────────────────
stale=$(lsof -ti TCP:"${PORT}" 2>/dev/null)
if [[ -n "$stale" ]]; then
  echo -e "${YELLOW}  Clearing stale process on port ${PORT}...${RESET}"
  kill "$stale" 2>/dev/null
  sleep 1
fi

# ── Start Ollama if not running ──────────────────────────────
if ! pgrep -f "ollama serve" &>/dev/null && ! pgrep -x ollama &>/dev/null; then
  echo -e "${CYAN}  Starting Ollama...${RESET}"
  ollama serve &>/tmp/ollama_gemma4.log &
  sleep 3
else
  echo -e "${GREEN}  ✓ Ollama already running${RESET}"
fi

# ── Pre-load model into memory ───────────────────────────────
echo -e "${CYAN}  Warming up model (${MODEL})...${RESET}"
ollama run "${MODEL}" --keepalive 60m "" &>/dev/null &

# ── Start Open WebUI ─────────────────────────────────────────
echo -e "${CYAN}  Starting Open WebUI on port ${PORT}...${RESET}"
if command -v open-webui &>/dev/null; then
  OLLAMA_BASE_URL=http://localhost:11434 \
  DEFAULT_MODELS="${MODEL}" \
  ENABLE_IMAGE_GENERATION=true \
  MAX_FILE_SIZE=100 \
  WEBUI_AUTH=false \
    open-webui serve --host 0.0.0.0 --port "${PORT}" &
  WEBUI_PID=$!
  sleep 6

  # Confirm it's actually up
  if lsof -iTCP:"${PORT}" -sTCP:LISTEN &>/dev/null 2>&1; then
    echo -e "${GREEN}  ✓ Open WebUI running on port ${PORT} (PID: ${WEBUI_PID})${RESET}"
    echo -e "${GREEN}  ✓ Live cam   : Chat box → 📎 → Camera${RESET}"
    echo -e "${GREEN}  ✓ File attach: Chat box → 📎 → Upload${RESET}"
    echo -e "${GREEN}  ✓ Voice input: Chat box → Microphone icon${RESET}\n"
    open "http://localhost:${PORT}"
  else
    # Try alternate port if it still didn't bind
    ALT_PORT=$(find_free_port $((PORT + 1)))
    echo -e "${YELLOW}  Port ${PORT} still blocked — retrying on ${ALT_PORT}...${RESET}"
    kill "$WEBUI_PID" 2>/dev/null
    OLLAMA_BASE_URL=http://localhost:11434 \
    DEFAULT_MODELS="${MODEL}" \
    ENABLE_IMAGE_GENERATION=true \
    MAX_FILE_SIZE=100 \
    WEBUI_AUTH=false \
      open-webui serve --host 0.0.0.0 --port "${ALT_PORT}" &
    WEBUI_PID=$!
    sleep 5
    echo -e "${GREEN}  ✓ Open WebUI running on port ${ALT_PORT}${RESET}"
    open "http://localhost:${ALT_PORT}"
  fi

  wait $WEBUI_PID
else
  echo -e "  Open WebUI not installed yet."
  echo -e "  Run:  pip install open-webui"
  echo -e "  Or:   docker compose up -d"
  echo -e "\n  Ollama API is live at http://localhost:11434"
fi
