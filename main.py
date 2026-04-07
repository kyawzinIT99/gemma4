import modal
import os
import subprocess
import time

# Create a Modal app named "main" so the deployment goes to https://modal.com/apps/<workspace>/main
app = modal.App("main")

# Build the system image exactly like the local setup
image = (
    modal.Image.debian_slim(python_version="3.11")
    .apt_install("curl", "systemd", "zstd")
    # Install Ollama
    .run_commands("curl -fsSL https://ollama.com/install.sh | sh")
    # Pip install Open WebUI 
    .pip_install("open-webui")
    # Pull the Gemma 4 model (the 4B multimodal version) into the image
    .run_commands("ollama serve & sleep 3 && ollama pull gemma4:e4b")
)

@app.function(
    image=image,
    gpu="T4", # Required for running a 4B model reasonably 
    allow_concurrent_inputs=100, 
    keep_warm=1, 
    timeout=3600
)
@modal.web_server(8080)
def serve():
    # 1. Start Ollama locally inside the Modal container
    subprocess.Popen(["ollama", "serve"])
    time.sleep(5)  # Wait for ollama to initialize

    # 2. Configure Open WebUI environment matches local docker-compose.yml
    os.environ["OLLAMA_BASE_URL"] = "http://localhost:11434"
    os.environ["ENABLE_IMAGE_GENERATION"] = "true"
    os.environ["ENABLE_COMMUNITY_SHARING"] = "false"
    os.environ["WEBUI_AUTH"] = "false"
    os.environ["DEFAULT_MODELS"] = "gemma4:e4b"
    os.environ["ENABLE_SIGNUP"] = "true"
    os.environ["MAX_FILE_SIZE"] = "100"
    os.environ["MAX_FILE_COUNT"] = "10"
    os.environ["RAG_EMBEDDING_ENGINE"] = "ollama"
    os.environ["RAG_OLLAMA_BASE_URL"] = "http://localhost:11434"
    os.environ["ENABLE_WEBSOCKET_SUPPORT"] = "true"
    os.environ["PORT"] = "8080"
    os.environ["HOST"] = "0.0.0.0"

    # 3. Start Open WebUI 
    subprocess.check_call(["open-webui", "serve"])
