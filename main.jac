import { supervisor, repo_mapper, code_analyzer, docgenie } with './agents/';

walker init {
    can http.server;
    
    with entry {
        http.server::cors_origin("*");
    }
    
    spawn here ++> graph::code_repo;
}

walker analyze_repo {
    has input url;
    has output result;
    has workflow node_repo;
    
    can supervisor.orchestrate_workflow;
    
    with entry {
        report "Starting repository analysis for: " + url;
        
        spawn here --> node::code_repo;
        workflow = here.context;
        workflow.url = url;
        
        supervisor.orchestrate_workflow(workflow);
        
        result = {
            "status": "completed",
            "repo_name": workflow.repo_name,
            "documentation_path": workflow.documentation_path
        };
    }
}

walker get_status {
    has input repo_id;
    has output status;
    
    with entry {
        for node in -[entity]-> node::code_repo {
            if (node.id == repo_id) {
                status = {
                    "repo_name": node.repo_name,
                    "status": node.status,
                    "progress": node.progress,
                    "documentation_path": node.documentation_path
                };
            }
        }
    }
}

walker serve_api {
    can http.post, http.get;
    
    with entry {
        http.post::server(
            "/analyze", 
            -[analyze_request]-> here::analyze_repo
        );
        
        http.get::server(
            "/status/{repo_id}", 
            -[status_request]-> here::get_status
        );
        
        http.get::server(
            "/docs/{repo_name}", 
            -[docs_request]-> here::serve_documentation
        );
    }
}

walker serve_documentation {
    has input repo_name;
    has output response;
    
    can http.response;
    
    with entry {
        std.file_exists("outputs/" + repo_name + "/docs.md") {
            content = file.load_str("outputs/" + repo_name + "/docs.md");
            response = http.response(content, 200, "text/markdown");
        } else {
            response = http.response('{"error": "Documentation not found"}', 404, "application/json");
        }
    }
}