# 🌟 Gemma 4 — Local Deployment & Experimentation Kit

> **Run Google's Gemma 4 multimodal AI entirely on your laptop.** Vision, audio, documents, live camera — all private, all offline.

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Model](https://img.shields.io/badge/Model-Gemma_4-orange.svg)](https://ollama.com/library/gemma4)
[![Ollama](https://img.shields.io/badge/Powered_by-Ollama-black.svg)](https://ollama.com)
[![Open WebUI](https://img.shields.io/badge/UI-Open_WebUI-purple.svg)](https://github.com/open-webui/open-webui)

---

## 📖 What Is This?

This repository is an **experimental local deployment kit** for Google's **Gemma 4** family of models. It was built and tested to help developers, researchers, and tinkerers run a full ChatGPT-style multimodal interface — completely on their own machine, with **zero cloud costs and full data privacy**.

Capabilities unlocked:

| Feature | Details |
|---------|---------|
| 🖼️ **Vision** | Images, PDFs, screenshots, charts, handwriting |
| 🎤 **Audio** | Native audio input (e2b / e4b models) |
| 📷 **Live Camera** | Stream your webcam directly into the chat |
| 📄 **Document Parsing** | PDF, DOCX, CSV, TXT with native OCR |
| 🔧 **Tool Use** | Function calling via `<|tool_call|>` tokens |
| 🌍 **140+ Languages** | Multilingual by default |
| 🧠 **Long Context** | 128K tokens (2B/4B) · 256K tokens (26B/31B) |

---

## 🖥️ System Requirements

Choose the right model for your machine:

| Model | Params | Type | Min RAM | Best For |
|-------|--------|------|---------|----------|
| `gemma4:e2b` | 2B | Text only | **8 GB** | Edge / fastest |
| `gemma4:e4b` | 4B | **Multimodal ★** | **8 GB** (16 GB rec.) | Vision + audio + files |
| `gemma4:26b` | 26B | MoE | **32 GB** | High-end GPU / Mac M-Max |
| `gemma4:31b` | 31B | Dense | **40 GB** | Flagship quality |

> ✅ **Recommended for most users:** `gemma4:e4b` on any modern laptop with 16 GB unified/system RAM.

**OS Compatibility:**
- ✅ macOS (Apple Silicon M-series — best performance)
- ✅ Linux (NVIDIA GPU recommended for larger models)
- ✅ Windows (via WSL2 for native scripts; Docker works natively)

---

## 🚀 Quick Start (3 Steps)

### Prerequisites

Make sure you have the following installed:

- **macOS / Linux:** `bash`, `curl`
- **Docker option:** [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- **Python option:** Python 3.10+

---

### ⚡ Option 1 — Automated Setup (Recommended)

The fastest path to a running system. One script handles everything.

```bash
# 1. Clone this repository
git clone https://github.com/kyawzinIT99/gemma4.git
cd gemma4

# 2. Run the automated installer
chmod +x setup.sh
./setup.sh

# 3. Launch the full stack
chmod +x launch_gemma4.sh
./launch_gemma4.sh
```

Your browser will automatically open to **http://localhost:8080** with the full Open WebUI interface ready to go.

---

### 🐳 Option 2 — Docker (No Python Required)

Best for isolated environments or Windows users.

```bash
# 1. Clone this repository
git clone https://github.com/kyawzinIT99/gemma4.git
cd gemma4

# 2. Start the full stack
docker compose up -d

# 3. Open in your browser
open http://localhost:8080   # macOS
# or visit http://localhost:8080 manually
```

> 💡 Ensure **Docker Desktop** is running before executing `docker compose up`.

---

### 🛠️ Option 3 — Manual (Ollama CLI Only)

For users who want the model without any UI.

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull the multimodal 4B model
ollama pull gemma4:e4b

# Run in terminal
ollama run gemma4:e4b

# Or use the REST API
curl http://localhost:11434/api/generate \
  -d '{"model":"gemma4:e4b","prompt":"Hello, Gemma!"}'
```

---

## 🧪 Running Experiments

Once deployed, the Open WebUI gives you a full interactive lab:

### Live Camera & Vision
1. Click the **📎 attachment** icon in the chat input bar
2. Select **Camera** → streams your live webcam directly to Gemma 4
3. Ask it to *describe what it sees*, *read text in frame*, or *analyze posture*

### Document & PDF Analysis
1. Click **📎** → **Upload file**
2. Drop in a PDF, CSV, DOCX, or image
3. Ask specific questions: *"Summarize section 3"* or *"What are the key data trends?"*

### Switch Models on the Fly
```bash
# Launch with a lightweight 2B model for speed benchmarks
./launch_gemma4.sh gemma4:e2b

# Launch with the 26B model for higher reasoning quality
./launch_gemma4.sh gemma4:26b
```

### Manage Your Models
```bash
chmod +x gemma4_manager.sh
./gemma4_manager.sh
```
Interactive menu to list, update, or delete downloaded model weights.

---

## 🐍 Python API Usage

Use Gemma 4 programmatically via Ollama's OpenAI-compatible API:

```python
import requests

response = requests.post("http://localhost:11434/api/chat", json={
    "model": "gemma4:e4b",
    "messages": [{"role": "user", "content": "Explain quantum entanglement simply"}],
    "stream": False
})

print(response.json()["message"]["content"])
```

Or with the official Ollama Python SDK:

```python
import ollama

response = ollama.chat(
    model="gemma4:e4b",
    messages=[{"role": "user", "content": "What do you see?"}]
)
print(response.message.content)
```

---

## ☁️ Cloud Deployment (Modal)

This repo also contains `main.py` for deploying the full stack to [Modal](https://modal.com) with a T4 GPU — useful for sharing a public endpoint.

```bash
pip install modal
modal deploy main.py
```

> See `main.py` for full configuration details.

---

## 📦 Repository Structure

```
gemma4/
├── README.md                  ← You are here
├── setup.sh                   ← Automated installer (Ollama + Open WebUI)
├── launch_gemma4.sh           ← One-command launcher with auto browser open
├── gemma4_manager.sh          ← Interactive model manager (pull/update/delete)
├── docker-compose.yml         ← Full Docker stack definition
├── main.py                    ← Modal cloud deployment script
├── gemma4_info.md             ← Model variants and capabilities reference
└── laptop_deployment_guide.md ← Detailed step-by-step experiment guide
```

---

## 🔗 Official Resources

| Source | Link |
|--------|------|
| Ollama Library | https://ollama.com/library/gemma4 |
| Hugging Face | https://huggingface.co/google/gemma-4 |
| Kaggle Models | https://kaggle.com/models/google/gemma-4 |
| Google AI Studio | https://aistudio.google.com |
| Open WebUI | https://github.com/open-webui/open-webui |

---

## 📄 License

This project is licensed under the **Apache 2.0 License** — see the [LICENSE](LICENSE) file for details.

The Gemma 4 model weights are subject to [Google's Gemma Terms of Use](https://ai.google.dev/gemma/terms).

---

## 🙏 Acknowledgements

Built with:
- [Google Gemma 4](https://deepmind.google/models/gemma/) — the model powering everything
- [Ollama](https://ollama.com) — frictionless local LLM runtime
- [Open WebUI](https://github.com/open-webui/open-webui) — the browser interface
- [Modal](https://modal.com) — serverless GPU cloud for remote deployment

---

*Last updated: April 7, 2026 · Experimental build — tested on Apple M4 MacBook Pro*
