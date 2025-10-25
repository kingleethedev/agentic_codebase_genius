from typing import Dict, List, Any

class GraphBuilder:
    
    @staticmethod
    def build_relationships(graph: Dict, file_path: str, analysis: Dict):
        """Build relationships between code entities"""
        if analysis.get("language") == "python":
            GraphBuilder.build_python_relationships(graph, file_path, analysis)
        elif analysis.get("language") == "jac":
            GraphBuilder.build_jac_relationships(graph, file_path, analysis)
    
    @staticmethod
    def build_python_relationships(graph: Dict, file_path: str, analysis: Dict):
        """Build relationships for Python code"""
        # Extract function calls (simplified)
        content = analysis.get("content", "")
        
        for func in analysis.get("functions", []):
            func_name = func["name"]
            # Simple call detection - would be enhanced with proper AST analysis
            func["calls"] = GraphBuilder.detect_function_calls(content, func_name)
    
    @staticmethod
    def detect_function_calls(content: str, current_func: str) -> List[str]:
        """Detect function calls within a function (simplified)"""
        calls = []
        lines = content.split('\n')
        in_function = False
        
        for line in lines:
            if f"def {current_func}" in line:
                in_function = True
                continue
            if in_function and line.strip().startswith('def '):
                break
            
            if in_function:
                # Simple pattern matching for function calls
                words = line.replace('(', ' ').replace('.', ' ').split()
                for i, word in enumerate(words):
                    if word.isidentifier() and not word in ['def', 'class', 'if', 'for', 'while']:
                        if i > 0 and words[i-1] not in ['def', 'class']:
                            calls.append(word)
        
        return list(set([c for c in calls if c != current_func]))