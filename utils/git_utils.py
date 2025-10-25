import os
import tempfile
import shutil
from git import Repo, GitCommandError
import json

class GitUtils:
    
    @staticmethod
    def clone_repository(url):
        """Clone repository to temporary directory"""
        try:
            temp_dir = tempfile.mkdtemp()
            repo_name = url.split('/')[-1].replace('.git', '')
            
            print(f"Cloning {url} to {temp_dir}")
            Repo.clone_from(url, temp_dir)
            
            return {
                "success": True,
                "repo_name": repo_name,
                "local_path": temp_dir
            }
        except GitCommandError as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    @staticmethod
    def generate_file_tree(repo_path):
        """Generate structured file tree representation"""
        file_tree = {}
        ignored_dirs = ['.git', '__pycache__', 'node_modules', '.idea', '.vscode']
        
        def traverse_directory(path, relative_path=""):
            tree = {}
            
            for item in os.listdir(path):
                if item in ignored_dirs:
                    continue
                    
                full_path = os.path.join(path, item)
                rel_path = os.path.join(relative_path, item) if relative_path else item
                
                if os.path.isdir(full_path):
                    tree[rel_path] = {
                        "type": "directory",
                        "children": traverse_directory(full_path, rel_path)
                    }
                else:
                    tree[rel_path] = {
                        "type": "file",
                        "size": os.path.getsize(full_path),
                        "extension": os.path.splitext(item)[1]
                    }
            
            return tree
        
        return traverse_directory(repo_path)
    
    @staticmethod
    def cleanup_temp_dir(path):
        """Clean up temporary directory"""
        try:
            shutil.rmtree(path)
        except Exception as e:
            print(f"Error cleaning up temp directory: {e}")