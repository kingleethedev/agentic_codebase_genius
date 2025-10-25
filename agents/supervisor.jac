node code_repo {
    has url;
    has repo_name;
    has status = "pending"; // pending, mapping, analyzing, generating, completed, error
    has progress = 0;
    has file_tree = {};
    has readme_summary = "";
    has code_graph = {};
    has documentation_path = "";
    has priority_files = [];
    has analyzed_files = [];
}

edge workflow_edge;

walker orchestrate_workflow {
    has input repo_node;
    
    can repo_mapper.generate_repo_map;
    can repo_mapper.summarize_readme;
    can code_analyzer.build_ccg;
    can code_analyzer.analyze_priority_files;
    can docgenie.generate_documentation;
    can prioritize_files;
    
    with entry {
        repo_node.status = "mapping";
        repo_node.progress = 10;
        
        // Step 1: Repository Mapping
        report "Starting repository mapping...";
        repo_mapper.generate_repo_map(repo_node);
        repo_mapper.summarize_readme(repo_node);
        
        repo_node.status = "planning";
        repo_node.progress = 30;
        
        // Step 2: High-level planning
        report "Planning analysis priority...";
        prioritize_files(repo_node);
        
        repo_node.status = "analyzing";
        repo_node.progress = 40;
        
        // Step 3: Code Analysis
        report "Building Code Context Graph...";
        code_analyzer.build_ccg(repo_node);
        code_analyzer.analyze_priority_files(repo_node);
        
        repo_node.status = "generating";
        repo_node.progress = 80;
        
        // Step 4: Documentation Generation
        report "Generating documentation...";
        docgenie.generate_documentation(repo_node);
        
        repo_node.status = "completed";
        repo_node.progress = 100;
        
        report "Documentation generation completed!";
        report "Output: " + repo_node.documentation_path;
    }
    
    with prioritize_files {
        // Prioritize entry point files and important modules
        priority_patterns = ["main", "app", "index", "run", "start", "init"];
        extensions = [".py", ".jac", ".js", ".java", ".cpp"];
        
        repo_node.priority_files = [];
        
        for file_path, file_info in repo_node.file_tree {
            if (file_info.type == "file") {
                for pattern in priority_patterns {
                    for ext in extensions {
                        if (file_path.contains(pattern) and file_path.ends_with(ext)) {
                            repo_node.priority_files.append(file_path);
                            break;
                        }
                    }
                }
            }
        }
        
        // Add files mentioned in README
        if (repo_node.readme_summary.contains("import")) {
            // Extract potential module names from README
            // This is a simplified version - would be enhanced in production
        }
        
        report "Prioritized files: " + repo_node.priority_files;
    }
}