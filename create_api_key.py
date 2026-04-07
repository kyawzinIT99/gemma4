#!/usr/bin/env python3
"""
Gemma 4 — API Key Generator
Creates a free API key from your local Open WebUI instance
so any external project can use Gemma 4 at zero cost.

Usage:  python3 create_api_key.py
"""

import requests
import json
import sys
import os
import secrets
import string

WEBUI_URL = os.environ.get("WEBUI_URL", "http://localhost:3000")
OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")

GREEN  = "\033[0;32m"
CYAN   = "\033[0;36m"
YELLOW = "\033[1;33m"
BOLD   = "\033[1m"
RESET  = "\033[0m"

def banner():
    print(f"\n{CYAN}{BOLD}  Gemma 4 — API Key Generator{RESET}")
    print(f"{CYAN}  ────────────────────────────────────{RESET}\n")

def check_ollama():
    """Verify Ollama + Gemma 4 are running."""
    try:
        r = requests.get(f"{OLLAMA_URL}/api/tags", timeout=5)
        models = [m["name"] for m in r.json().get("models", [])]
        gemma = [m for m in models if "gemma4" in m or "gemma" in m.lower()]
        if gemma:
            print(f"{GREEN}  ✓ Ollama running — models: {', '.join(gemma)}{RESET}")
            return gemma[0]
        else:
            print(f"{YELLOW}  ⚠ Ollama running but no Gemma 4 found. Pull: ollama pull gemma4:e4b{RESET}")
            return None
    except Exception as e:
        print(f"  ✗ Ollama not reachable at {OLLAMA_URL}: {e}")
        return None

def get_webui_token():
    """Sign in to Open WebUI and return admin JWT token."""
    # Try default admin credentials (set during first-run signup)
    for creds in [
        {"email": "admin@gemma4.local", "password": "gemma4admin"},
        {"email": "kyawzin.ccna@gmail.com", "password": "gemma4admin"},
        {"email": "itsolutions.mm@gmail.com", "password": "gemma4admin"},
    ]:
        try:
            r = requests.post(
                f"{WEBUI_URL}/api/v1/auths/signin",
                json=creds, timeout=5
            )
            if r.status_code == 200:
                token = r.json().get("token")
                print(f"{GREEN}  ✓ Signed in to Open WebUI as {creds['email']}{RESET}")
                return token
        except:
            pass
    return None

def create_webui_api_key(token):
    """Create a new API key in Open WebUI."""
    try:
        r = requests.post(
            f"{WEBUI_URL}/api/v1/auths/api_key",
            headers={"Authorization": f"Bearer {token}"},
            timeout=5
        )
        if r.status_code == 200:
            key = r.json().get("api_key")
            print(f"{GREEN}  ✓ Open WebUI API key created{RESET}")
            return key
    except Exception as e:
        print(f"  Open WebUI key creation failed: {e}")
    return None

def generate_ollama_key():
    """Generate a simple bearer token for direct Ollama access."""
    # Ollama doesn't require keys by default — generate a placeholder
    # that documents the direct endpoint usage.
    chars = string.ascii_letters + string.digits
    return "sk-gemma4-" + "".join(secrets.choice(chars) for _ in range(32))

def save_config(model_name, webui_key, ollama_key):
    """Save API credentials to a config file."""
    config = {
        "gemma4_api_config": {
            "description": "Gemma 4 local API — zero cost, fully private",
            "model": model_name or "gemma4:e4b",

            "openwebui_endpoint": {
                "base_url": f"{WEBUI_URL}/api",
                "openai_compatible_url": f"{WEBUI_URL}/openai",
                "api_key": webui_key or "not-configured",
                "note": "Full Open WebUI features — chat, vision, file upload"
            },

            "ollama_direct_endpoint": {
                "base_url": OLLAMA_URL,
                "openai_compatible_url": f"{OLLAMA_URL}/v1",
                "api_key": ollama_key,
                "note": "Direct Ollama — fastest, no auth required by default"
            },

            "usage": {
                "python_openai_sdk": f"""
from openai import OpenAI

client = OpenAI(
    base_url="{OLLAMA_URL}/v1",
    api_key="ollama",          # any string works for local Ollama
)

response = client.chat.completions.create(
    model="{model_name or 'gemma4:e4b'}",
    messages=[{{"role": "user", "content": "Hello!"}}]
)
print(response.choices[0].message.content)
""",
                "python_requests": f"""
import requests

r = requests.post("{OLLAMA_URL}/api/chat", json={{
    "model": "{model_name or 'gemma4:e4b'}",
    "messages": [{{"role": "user", "content": "Hello!"}}],
    "stream": False
}})
print(r.json()["message"]["content"])
""",
                "curl": f"""
curl {OLLAMA_URL}/api/generate \\
  -d '{{"model": "{model_name or 'gemma4:e4b'}", "prompt": "Hello!", "stream": false}}'
""",
                "javascript_fetch": f"""
const response = await fetch('{OLLAMA_URL}/api/chat', {{
  method: 'POST',
  headers: {{'Content-Type': 'application/json'}},
  body: JSON.stringify({{
    model: '{model_name or "gemma4:e4b"}',
    messages: [{{role: 'user', content: 'Hello!'}}],
    stream: false
  }})
}});
const data = await response.json();
console.log(data.message.content);
"""
            }
        }
    }

    path = os.path.join(os.path.dirname(__file__), "gemma4_api_config.json")
    with open(path, "w") as f:
        json.dump(config, f, indent=2)
    print(f"{GREEN}  ✓ Config saved → gemma4_api_config.json{RESET}")
    return path

def print_summary(model_name, webui_key, ollama_key):
    print(f"\n{CYAN}{BOLD}  ╔══════════════════════════════════════╗{RESET}")
    print(f"{CYAN}{BOLD}  ║     Gemma 4 API Keys — Ready ✓       ║{RESET}")
    print(f"{CYAN}{BOLD}  ╚══════════════════════════════════════╝{RESET}\n")

    print(f"  {BOLD}Model:{RESET}        {model_name or 'gemma4:e4b'}")
    print(f"  {BOLD}Cost:{RESET}         $0.00 — 100% local\n")

    print(f"  {BOLD}── Option 1: Direct Ollama (Recommended) ──{RESET}")
    print(f"  Base URL:   {OLLAMA_URL}/v1")
    print(f"  API Key:    ollama   (any string — no auth needed)")
    print(f"  Model ID:   {model_name or 'gemma4:e4b'}\n")

    if webui_key:
        print(f"  {BOLD}── Option 2: Open WebUI (with key) ──{RESET}")
        print(f"  Base URL:   {WEBUI_URL}/openai")
        print(f"  API Key:    {webui_key}")
        print(f"  Model ID:   {model_name or 'gemma4:e4b'}\n")

    print(f"  {BOLD}── Quick Test ──{RESET}")
    print(f"  {CYAN}curl {OLLAMA_URL}/api/generate \\{RESET}")
    print(f"  {CYAN}  -d '{{\"model\":\"{model_name or 'gemma4:e4b'}\",\"prompt\":\"Hi!\",\"stream\":false}}'{RESET}\n")

    print(f"  {BOLD}Full config + code examples → gemma4_api_config.json{RESET}\n")

def main():
    banner()

    # 1. Check Ollama
    model = check_ollama()

    # 2. Try Open WebUI API key
    webui_key = None
    print(f"\n{CYAN}  Trying Open WebUI API key...{RESET}")
    token = get_webui_token()
    if token:
        webui_key = create_webui_api_key(token)
    else:
        print(f"  Open WebUI: no default admin account found.")
        print(f"  → Go to {WEBUI_URL} → Profile → API Keys to create one manually.")

    # 3. Generate Ollama direct key doc
    ollama_key = generate_ollama_key()

    # 4. Save config
    print(f"\n{CYAN}  Saving API config...{RESET}")
    save_config(model, webui_key, ollama_key)

    # 5. Summary
    print_summary(model, webui_key, ollama_key)

if __name__ == "__main__":
    main()
