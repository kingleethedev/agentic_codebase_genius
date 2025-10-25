walker generate_repo_map {
    has input repo_node;
    has output success;
    
    can utils.git_utils.clone_repository;
    can utils.git_utils.generate_file_tree;
    
    with entry {
        report "Cloning repository: " + repo_node.url;
        
        // Clone repository
        clone_result = utils.git_utils.clone_repository(repo_node.url);
        if (!clone_result.success) {
            repo_node.status = "error";
            success = false;
            return;
        }
        
        repo_node.repo_name = clone_result.repo_name;
        repo_node.local_path = clone_result.local_path;
        
        // Generate file tree
        report "Generating file tree...";
        file_tree = utils.git_utils.generate_file_tree(clone_result.local_path);
        repo_node.file_tree = file_tree;
        
        success = true;
        report "Repository mapping completed. Found " + file_tree.length + " files/folders";
    }
}

walker summarize_readme {
    has input repo_node;
    has output summary;
    
    can extract_readme_content;
    can generate_summary;
    
    with entry {
        report "Looking for README files...";
        
        readme_files = [];
        for file_path, file_info in repo_node.file_tree {
            if (file_info.type == "file") {
                lower_name = file_path.lower();
                if (lower_name.contains("readme") or 
                    lower_name == "readme" or 
                    lower_name == "readme.md" or
                    lower_name == "readme.rst" or
                    lower_name == "readme.txt") {
                    readme_files.append(file_path);
                }
            }
        }
        
        if (readme_files.length > 0) {
            primary_readme = readme_files[0];
            report "Found README: " + primary_readme;
            
            readme_content = extract_readme_content(repo_node.local_path + "/" + primary_readme);
            summary = generate_summary(readme_content);
            repo_node.readme_summary = summary;
        } else {
            repo_node.readme_summary = "No README file found in repository.";
            summary = repo_node.readme_summary;
        }
        
        report "README Summary: " + summary;
    }
    
    with extract_readme_content {
        has input file_path;
        has output content;
        
        file.exists(file_path) {
            content = file.load_str(file_path);
        } else {
            content = "";
        }
    }
    
    with generate_summary {
        has input content;
        has output summary;
        
        // Simple summary generation - could be enhanced with LLM
        lines = content.split("\n");
        key_sections = [];
        current_section = "";
        
        for line in lines {
            line = line.strip();
            if (line.startsWith("# ")) {
                if (current_section != "") {
                    key_sections.append(current_section);
                }
                current_section = line.replace("# ", "") + ": ";
            } else if (line.startsWith("## ")) {
                if (current_section != "") {
                    key_sections.append(current_section);
                }
                current_section = line.replace("## ", "") + ": ";
            } else if (line != "" and current_section != "") {
                if (current_section.split(": ")[1].length < 100) {
                    current_section = current_section + line + " ";
                }
            }
        }
        
        if (current_section != "") {
            key_sections.append(current_section);
        }
        
        summary = key_sections.join("\n");
        if (summary.length > 500) {
            summary = summary[0:500] + "...";
        }
    }
}