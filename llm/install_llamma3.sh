#!/usr/bin/bash

sudo apt-get update
sudo apt-get upgrade

sudo apt-get install -y wget curl

# installer ollama, on garde le script au cas ou 
wget https://ollama.com/install.sh
chmod +x install.sh
sudo ./install.sh

# installer ollama 2
ollama pull llama2

# requeter le llm 
ollama run llama2 'tell me a joke'

# requet web
curl -X POST http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Pourquoi le ciel est bleu ?"
}'

# utilliser code llama avec l extension dans vscode
# ollama pull codellama
# ollama serve codellama





