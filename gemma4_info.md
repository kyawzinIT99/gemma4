# Gemma 4 — Local Deployment Guide

**Released:** April 2, 2026 · **By:** Google · **License:** Apache 2.0

---

## Model Variants

| Model | Params | Type | RAM Needed | Best For |
|-------|--------|------|-----------|---------|
| `gemma4:e2b` | 2B | Text only | ~2 GB | Edge / fastest |
| `gemma4:e4b` | 4B | **Multimodal** ★ | ~4 GB | Vision + audio + files |
| `gemma4:26b` | 26B | MoE | ~16 GB | High-end GPU |
| `gemma4:31b` | 31B | Dense | ~20 GB | Flagship quality |

> **For live cam + file attachment** → use `gemma4:e4b` or larger (multimodal models).

---

## Capabilities (gemma4:e4b and above)

- **Vision** — images, PDFs, screenshots, charts, handwriting, UI understanding
- **Audio** — native audio input on e2b/e4b
- **Video** — frame-sequence processing
- **Files** — document parsing, OCR, multilingual text extraction
- **Tool use** — function calling with `<|tool_call|>` tokens
- **Context** — 128K tokens (e2b/e4b), 256K tokens (26b/31b)
- **Languages** — 140+

---

## Quickstart

### Option A — Automated Setup (recommended)

```bash
chmod +x setup.sh
./setup.sh
```

This installs Ollama, pulls your chosen model, installs Open WebUI, and creates the launcher.

### Option B — Docker (no Python needed)

```bash
docker compose up -d
# then open http://localhost:8080
```

### Option C — Manual (Ollama only)

```bash
# 1. Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 2. Pull Gemma 4 (multimodal 4B)
ollama pull gemma4:e4b

# 3. Chat in terminal
ollama run gemma4:e4b

# 4. Or use the API
curl http://localhost:11434/api/generate \
  -d '{"model":"gemma4:e4b","prompt":"Hello!"}'
```

---

## Open WebUI — Live Cam & File Attachment

Open WebUI gives Gemma 4 a full ChatGPT-style browser interface.

| Feature | How to use in UI |
|---------|-----------------|
| 📷 Live camera | Chat box → **📎** → **Camera** |
| 📁 File upload | Chat box → **📎** → **Upload file** |
| 🎤 Voice input | Chat box → **Microphone** icon |
| 🖼️ Image input | Drag & drop image into chat box |
| 📄 PDF reading | Upload PDF → ask questions about it |

**Supported file types:** PDF, DOCX, TXT, CSV, PNG, JPG, MP3, MP4, and more.

---

## Daily Usage

```bash
# Launch everything (Ollama + WebUI + browser)
./launch_gemma4.sh

# Use a different model
./launch_gemma4.sh gemma4:e2b

# Manage models (pull / update / delete)
./gemma4_manager.sh
```

---

## Reliable Download Sources

| Source | URL |
|--------|-----|
| Ollama | https://ollama.com/library/gemma4 |
| Hugging Face | https://huggingface.co/google/gemma-4 |
| Kaggle | https://kaggle.com/models/google/gemma-4 |
| Google AI Studio | https://aistudio.google.com |

---

## API Reference (OpenAI-compatible via Ollama)

```python
import requests

response = requests.post("http://localhost:11434/api/chat", json={
    "model": "gemma4:e4b",
    "messages": [{"role": "user", "content": "Explain quantum computing"}],
    "stream": False
})
print(response.json()["message"]["content"])
```

---

*Last updated: April 7, 2026*
