import ast
import os
from typing import Dict, List, Any

class TreeParser:
    
    @staticmethod
    def parse_file(file_path: str) -> Dict[str, Any]:
        """Parse source file and extract code structure"""
        if not os.path.exists(file_path):
            return None
        
        file_extension = os.path.splitext(file_path)[1]
        
        if file_extension == '.py':
            return TreeParser.parse_python_file(file_path)
        elif file_extension == '.jac':
            return TreeParser.parse_jac_file(file_path)
        else:
            # Basic analysis for other file types
            return TreeParser.basic_file_analysis(file_path)
    
    @staticmethod
    def parse_python_file(file_path: str) -> Dict[str, Any]:
        """Parse Python file using AST"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            tree = ast.parse(content)
            
            analysis = {
                "file_path": file_path,
                "language": "python",
                "functions": [],
                "classes": [],
                "imports": [],
                "content": content
            }
            
            for node in ast.walk(tree):
                if isinstance(node, ast.FunctionDef):
                    func_info = {
                        "name": node.name,
                        "parameters": [arg.arg for arg in node.args.args],
                        "start_line": node.lineno,
                        "end_line": node.end_lineno,
                        "docstring": ast.get_docstring(node)
                    }
                    analysis["functions"].append(func_info)
                
                elif isinstance(node, ast.ClassDef):
                    class_info = {
                        "name": node.name,
                        "base_classes": [base.id for base in node.bases if isinstance(base, ast.Name)],
                        "methods": [n.name for n in node.body if isinstance(n, ast.FunctionDef)],
                        "docstring": ast.get_docstring(node)
                    }
                    analysis["classes"].append(class_info)
                
                elif isinstance(node, (ast.Import, ast.ImportFrom)):
                    import_info = {
                        "module": node.module if isinstance(node, ast.ImportFrom) else None,
                        "names": [alias.name for alias in node.names]
                    }
                    analysis["imports"].append(import_info)
            
            return analysis
            
        except Exception as e:
            print(f"Error parsing Python file {file_path}: {e}")
            return None
    
    @staticmethod
    def parse_jac_file(file_path: str) -> Dict[str, Any]:
        """Basic Jac file parser"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            analysis = {
                "file_path": file_path,
                "language": "jac",
                "walkers": [],
                "nodes": [],
                "edges": [],
                "content": content
            }
            
            lines = content.split('\n')
            for i, line in enumerate(lines):
                line = line.strip()
                if line.startswith('walker '):
                    analysis["walkers"].append({
                        "name": line.replace('walker ', '').split(' ')[0],
                        "start_line": i + 1
                    })
                elif line.startswith('node '):
                    analysis["nodes"].append({
                        "name": line.replace('node ', '').split(' ')[0],
                        "start_line": i + 1
                    })
                elif line.startswith('edge '):
                    analysis["edges"].append({
                        "name": line.replace('edge ', '').split(' ')[0],
                        "start_line": i + 1
                    })
            
            return analysis
            
        except Exception as e:
            print(f"Error parsing Jac file {file_path}: {e}")
            return None
    
    @staticmethod
    def basic_file_analysis(file_path: str) -> Dict[str, Any]:
        """Basic analysis for unsupported file types"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            return {
                "file_path": file_path,
                "language": "unknown",
                "content": content,
                "line_count": len(content.split('\n'))
            }
        except Exception as e:
            print(f"Error analyzing file {file_path}: {e}")
            return None