#!/bin/bash

echo "Setting up Agentic Codebase Genius..."

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create necessary directories
mkdir -p outputs
mkdir -p logs

# Install Tree-sitter languages (if needed)
echo "Installing Tree-sitter languages..."
pip install tree-sitter-python

echo "Setup completed!"
echo "To run the server:"
echo "source venv/bin/activate && jac run main.jac"