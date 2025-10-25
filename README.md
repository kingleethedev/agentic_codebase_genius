Agentic Codebase Genius
A multi-agent pipeline for automated codebase documentation generation. This system analyzes GitHub repositories and generates comprehensive, well-structured documentation using a collaborative agent architecture.

 Features
Multi-Agent Architecture: Four specialized agents working in coordination

Intelligent Analysis: Code Context Graph (CCG) for relationship mapping

Smart Prioritization: Focuses on high-impact files first

Multiple Language Support: Python, Jac, JavaScript, Java, and more

RESTful API: Easy integration with existing tools

Beautiful Documentation: Clean, organized markdown output

 Architecture
Agents
Code Genius (Supervisor) - Orchestrates the workflow and makes strategic decisions

Repo Mapper - Clones repositories and generates structural overviews

Code Analyzer - Performs deep code analysis and builds relationship graphs

DocGenie - Synthesizes all information into comprehensive documentation

Workflow

A[GitHub URL] --> B[Repo Mapper]
    B --> C[File Tree & README]
    C --> D[Supervisor Planning]
    D --> E[Code Analyzer]
    E --> F[Code Context Graph]
    F --> G[DocGenie]
    G --> H[Markdown Documentation]






] Prerequisites
Python 3.8+

Jac Language Support

Git
Manual Installation
bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Create necessary directories
mkdir -p outputs logs

# Install Tree-sitter languages
pip install tree-sitter-python
Usage
Starting the Server
bash
# Activate virtual environment
source venv/bin/activate

# Run the Jac server
jac run main.jac
The server will start on http://localhost:8000



agentic_codebase_genius/
├── main.jac                 # Main entry point and HTTP server
├── agents/                  # Agent implementations
│   ├── supervisor.jac       # Workflow orchestration
│   ├── repo_mapper.jac      # Repository structure analysis
│   ├── code_analyzer.jac    # Code parsing and graph building
│   └── docgenie.jac         # Documentation generation
├── utils/                   # Python utilities
│   ├── git_utils.py         # Git operations
│   ├── tree_parser.py       # Code parsing
│   └── graph_builder.py     # Relationship graph construction
├── outputs/                 # Generated documentation
├── requirements.txt         # Python dependencies
└── setup.sh                # Installation script
