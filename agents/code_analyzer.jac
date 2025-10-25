node code_file {
    has name;
    has path;
    has language;
    has content = "";
    has ast = {};
    has functions = [];
    has classes = [];
    has imports = [];
    has exports = [];
}

node function {
    has name;
    has signature;
    has parameters = [];
    has return_type;
    has docstring;
    has start_line;
    has end_line;
    has calls = [];
}

node class {
    has name;
    has base_classes = [];
    has methods = [];
    has attributes = [];
    has docstring;
}

edge calls;
edge inherits;
edge imports;
edge contains;

walker build_ccg {
    has input repo_node;
    has output graph;
    
    can utils.tree_parser.parse_file;
    can utils.graph_builder.build_relationships;
    
    with entry {
        report "Building Code Context Graph...";
        
        // Create graph structure
        graph = {};
        repo_node.code_graph = graph;
        
        // Analyze all source files
        source_files = [];
        for file_path, file_info in repo_node.file_tree {
            if (file_info.type == "file" and is_source_file(file_path)) {
                source_files.append(file_path);
            }
        }
        
        report "Found " + source_files.length + " source files to analyze";
        
        // Parse each file and build relationships
        for file_path in source_files {
            full_path = repo_node.local_path + "/" + file_path;
            file_analysis = utils.tree_parser.parse_file(full_path);
            
            if (file_analysis) {
                graph[file_path] = file_analysis;
                
                // Build relationships between entities
                utils.graph_builder.build_relationships(graph, file_path, file_analysis);
            }
        }
        
        report "Code Context Graph built with " + graph.keys().length + " files analyzed";
    }
    
    with is_source_file {
        has input file_path;
        has output is_source;
        
        source_extensions = [".py", ".jac", ".js", ".java", ".cpp", ".c", ".h", ".hpp"];
        is_source = false;
        
        for ext in source_extensions {
            if (file_path.ends_with(ext)) {
                is_source = true;
                break;
            }
        }
    }
}

walker analyze_priority_files {
    has input repo_node;
    
    with entry {
        report "Analyzing priority files: " + repo_node.priority_files;
        
        for file_path in repo_node.priority_files {
            full_path = repo_node.local_path + "/" + file_path;
            if (file.exists(full_path)) {
                analysis = utils.tree_parser.parse_file(full_path);
                if (analysis) {
                    repo_node.code_graph[file_path] = analysis;
                    repo_node.analyzed_files.append(file_path);
                }
            }
        }
        
        report "Completed priority file analysis";
    }
}

walker query_relationships {
    has input repo_node, query_type, target;
    has output results;
    
    with entry {
        results = [];
        graph = repo_node.code_graph;
        
        if (query_type == "calls") {
            // Find functions that call the target
            for file_path, file_data in graph {
                for func in file_data.functions {
                    if (target in func.calls) {
                        results.append({
                            "file": file_path,
                            "function": func.name,
                            "type": "calls"
                        });
                    }
                }
            }
        } else if (query_type == "inherits") {
            // Find classes that inherit from target
            for file_path, file_data in graph {
                for cls in file_data.classes {
                    if (target in cls.base_classes) {
                        results.append({
                            "file": file_path,
                            "class": cls.name,
                            "type": "inherits"
                        });
                    }
                }
            }
        } else if (query_type == "imports") {
            // Find files that import target
            for file_path, file_data in graph {
                for imp in file_data.imports {
                    if (target in imp.module) {
                        results.append({
                            "file": file_path,
                            "import": imp.module,
                            "type": "imports"
                        });
                    }
                }
            }
        }
    }
}