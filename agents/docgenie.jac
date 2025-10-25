walker generate_documentation {
    has input repo_node;
    has output success;
    
    can create_project_overview;
    can create_installation_section;
    can create_usage_section;
    can create_api_reference;
    can create_architecture_section;
    can generate_diagrams;
    
    with entry {
        report "Generating comprehensive documentation...";
        
        output_dir = "outputs/" + repo_node.repo_name;
        file.mkdir(output_dir);
        
        docs_content = "# " + repo_node.repo_name + " Documentation\n\n";
        
        // Table of Contents
        docs_content += "## Table of Contents\n";
        docs_content += "- [Project Overview](#project-overview)\n";
        docs_content += "- [Installation](#installation)\n";
        docs_content += "- [Usage](#usage)\n";
        docs_content += "- [API Reference](#api-reference)\n";
        docs_content += "- [Architecture](#architecture)\n";
        docs_content += "- [File Structure](#file-structure)\n\n";
        
        // Project Overview
        docs_content += create_project_overview(repo_node);
        
        // Installation
        docs_content += create_installation_section(repo_node);
        
        // Usage
        docs_content += create_usage_section(repo_node);
        
        // API Reference
        docs_content += create_api_reference(repo_node);
        
        // Architecture
        docs_content += create_architecture_section(repo_node);
        
        // File Structure
        docs_content += create_file_structure_section(repo_node);
        
        // Save documentation
        output_path = output_dir + "/docs.md";
        file.save_str(output_path, docs_content);
        
        repo_node.documentation_path = output_path;
        success = true;
        
        report "Documentation saved to: " + output_path;
    }
    
    with create_project_overview {
        has input repo_node;
        has output content;
        
        content = "## Project Overview\n\n";
        
        if (repo_node.readme_summary != "No README file found in repository.") {
            content += repo_node.readme_summary + "\n\n";
        }
        
        // Extract key information from code analysis
        total_files = repo_node.file_tree.keys().length;
        source_files = 0;
        total_functions = 0;
        total_classes = 0;
        
        for file_path, analysis in repo_node.code_graph {
            source_files += 1;
            total_functions += analysis.functions.length;
            total_classes += analysis.classes.length;
        }
        
        content += "### Repository Statistics\n";
        content += "- **Total Files**: " + total_files + "\n";
        content += "- **Source Files**: " + source_files + "\n";
        content += "- **Functions**: " + total_functions + "\n";
        content += "- **Classes**: " + total_classes + "\n";
        content += "- **Primary Language**: " + detect_primary_language(repo_node) + "\n\n";
        
        content;
    }
    
    with create_api_reference {
        has input repo_node;
        has output content;
        
        content = "## API Reference\n\n";
        
        for file_path, analysis in repo_node.code_graph {
            if (analysis.functions.length > 0 or analysis.classes.length > 0) {
                content += "### " + file_path + "\n\n";
                
                // Document classes
                for cls in analysis.classes {
                    content += "#### Class: `" + cls.name + "`\n\n";
                    if (cls.docstring) {
                        content += cls.docstring + "\n\n";
                    }
                    
                    if (cls.base_classes.length > 0) {
                        content += "**Inherits from**: " + cls.base_classes.join(", ") + "\n\n";
                    }
                    
                    if (cls.methods.length > 0) {
                        content += "**Methods**:\n";
                        for method in cls.methods {
                            content += "- `" + method.name + "`";
                            if (method.parameters.length > 0) {
                                content += "(" + method.parameters.join(", ") + ")";
                            }
                            content += "\n";
                        }
                        content += "\n";
                    }
                }
                
                // Document functions
                for func in analysis.functions {
                    content += "#### Function: `" + func.name + "`\n\n";
                    if (func.docstring) {
                        content += func.docstring + "\n\n";
                    }
                    
                    content += "```python\n";
                    content += "def " + func.name;
                    if (func.parameters.length > 0) {
                        content += "(" + func.parameters.join(", ") + ")";
                    }
                    if (func.return_type) {
                        content += " -> " + func.return_type;
                    }
                    content += "\n```\n\n";
                    
                    if (func.calls.length > 0) {
                        content += "**Calls**: " + func.calls.join(", ") + "\n\n";
                    }
                }
            }
        }
        
        content;
    }
    
    with detect_primary_language {
        has input repo_node;
        has output language;
        
        language_counts = {};
        
        for file_path in repo_node.file_tree.keys() {
            if (file_path.ends_with(".py")) {
                language_counts["Python"] = (language_counts.get("Python", 0) or 0) + 1;
            } else if (file_path.ends_with(".jac")) {
                language_counts["Jac"] = (language_counts.get("Jac", 0) or 0) + 1;
            } else if (file_path.ends_with(".js")) {
                language_counts["JavaScript"] = (language_counts.get("JavaScript", 0) or 0) + 1;
            } else if (file_path.ends_with(".java")) {
                language_counts["Java"] = (language_counts.get("Java", 0) or 0) + 1;
            }
        }
        
        if (language_counts.keys().length > 0) {
            language = language_counts.keys()[0]; // Get first language
            max_count = language_counts[language];
            
            for lang, count in language_counts {
                if (count > max_count) {
                    language = lang;
                    max_count = count;
                }
            }
        } else {
            language = "Unknown";
        }
    }
}