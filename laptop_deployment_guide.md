# 💻 Local Laptop Deployment Guide: Gemma 4 Experiments

Welcome! This guide is designed for developers, tinkerers, and researchers who want to deploy the **Gemma 4** multimodal system on their individual laptops for local experimentation.

Running locally guarantees zero latency from network endpoints, complete data privacy, and the ability to test complex input modalities like live camera feeds and PDF parsing completely offline.

---

## 🛑 System Requirements

Before you begin, ensure your laptop meets the criteria for your intended experiments. 

| Experiment Type | Model | RAM / Unified Memory | OS Compatibility |
| --- | --- | --- | --- |
| **Fast text / Edge scripts** | `gemma4:e2b` | 8 GB | macOS / Linux / Windows WSL |
| **Multimodal (Vision/Voice)** | `gemma4:e4b` | 8 GB+ (16GB Rec.) | macOS (M-series) / Linux (NVIDIA) |
| **Advanced Pro Reasoning** | `gemma4:26b` | 32 GB+ | High-end laptops (e.g. Mac M-Max) |

---

## 🚀 Deployment Options

You can deploy the interface and the model using one of two methods: Native Scripts (best hardware performance) or Docker (best environment isolation).

### Option 1: Native Scripts (Recommended)
This approach runs Ollama natively on your OS, extracting maximum hardware acceleration from Apple Silicon architecture or native GPUs, and installs the Open WebUI via Python.

**1. Run the automated setup:**
```bash
chmod +x setup.sh
./setup.sh
```
*(This installs Ollama, pulls the `gemma4:e4b` multimodal weights, and configures Open WebUI).*

**2. Launch the Application:**
```bash
chmod +x launch_gemma4.sh
./launch_gemma4.sh
```
A browser window will automatically open to `http://localhost:8080` (or another free port if 8080 is blocked).

---

### Option 2: Isolated Docker Deployment
If you prefer strict isolation and don't want to install Python packages directly on your machine, you can run the entire stack via Docker.

**1. Start the stack:**
```bash
docker-compose up -d
```
*(Note: Ensure Docker Desktop is running before executing this).*

**2. Access the UI:**
Navigate to `http://localhost:8080` in your web browser.

---

## 🧪 Conducting Multimodal Experiments

Once deployed locally, you can use the Open WebUI to conduct interactive experiments.

### 1. Vision & Live Camera
- Click the **📎 (Attachment)** icon next to the prompt text box.
- Choose **Camera** to securely stream your laptop's webcam feed to Gemma 4 for real-time visual reasoning and scene interpretation.
- Choose **Upload file** to drop in charts, diagrams, or UI mockups.

### 2. Document & PDF Parsing
- Upload massive PDFs (research papers, textbooks) or CSVs directly into the chat interface.
- Gemma 4 will automatically chunk and parse the file natively, allowing you to ask hyper-specific queries against your document bundle.

### 3. Model Swapping
To experiment with a different model parameter size without editing configuration scripts, you can specify it directly when launching:
```bash
# Example: Deploying the ultra-lightweight 2B model for speed tests
./launch_gemma4.sh gemma4:e2b
```

---

## 🧹 Tooling Configuration 

To manage downloaded weights, remove old models, or update to newer iterations of Gemma 4 over time, we have included an interactive manager tool:

```bash
chmod +x gemma4_manager.sh
./gemma4_manager.sh
```

You can use this terminal application to seamlessly list your installed LLMs, clean up inactive gigabytes from your hard drive, or safely pull the latest architectural updates!
