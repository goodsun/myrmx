#!/bin/bash

# Git Submodules Setup Script for siegeNgin projects
# This script helps convert existing projects to independent repositories
# and set them up as submodules in the parent repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [[ ! -f "../package.json" ]] || [[ $(basename $(dirname $(pwd))) != "siegeNgin" ]]; then
    print_error "This script must be run from the siegeNgin/projects directory"
    exit 1
fi

# Function to setup a project as a submodule
setup_submodule() {
    local project_name=$1
    local github_repo_url=$2
    
    print_info "Setting up $project_name as a Git submodule..."
    
    # Check if project directory exists
    if [[ ! -d "$project_name" ]]; then
        print_error "Project directory $project_name not found"
        return 1
    fi
    
    # Move to parent directory
    cd ..
    
    # Create a temporary backup
    print_info "Creating backup of $project_name..."
    cp -r "projects/$project_name" "projects/${project_name}_backup_$(date +%Y%m%d_%H%M%S)"
    
    # Remove the project from git tracking (but keep files)
    print_info "Removing $project_name from parent repository tracking..."
    git rm -r --cached "projects/$project_name" || true
    git commit -m "Remove $project_name from tracking (converting to submodule)" || true
    
    # Initialize the project as a new repository
    cd "projects/$project_name"
    
    if [[ -d ".git" ]]; then
        print_warn "$project_name already has a .git directory. Skipping git init."
    else
        print_info "Initializing $project_name as a new Git repository..."
        git init
        git add .
        git commit -m "Initial commit"
    fi
    
    # Add remote if provided
    if [[ -n "$github_repo_url" ]]; then
        print_info "Adding remote origin: $github_repo_url"
        git remote add origin "$github_repo_url" || git remote set-url origin "$github_repo_url"
        
        print_warn "Ready to push to remote. Run the following commands when ready:"
        echo "cd projects/$project_name"
        echo "git push -u origin main"
    fi
    
    # Go back to parent repository
    cd ../..
    
    # Add as submodule
    if [[ -n "$github_repo_url" ]]; then
        print_info "Adding $project_name as a submodule..."
        git submodule add "$github_repo_url" "projects/$project_name"
        git commit -m "Add $project_name as a submodule"
    else
        print_warn "No remote URL provided. You'll need to add the submodule manually after pushing to GitHub."
    fi
    
    cd projects
    print_info "✅ $project_name setup complete!"
    echo ""
}

# Main menu
show_menu() {
    echo "==================================="
    echo "Git Submodules Setup for siegeNgin"
    echo "==================================="
    echo ""
    echo "This script will help you convert projects to independent Git repositories"
    echo "and set them up as submodules in the parent repository."
    echo ""
    echo "Available projects:"
    ls -d */ | grep -v "_backup" | sed 's/\///'
    echo ""
    echo "Enter the project name you want to convert (or 'exit' to quit):"
}

# Main loop
while true; do
    show_menu
    read -p "Project name: " project_name
    
    if [[ "$project_name" == "exit" ]]; then
        print_info "Exiting..."
        break
    fi
    
    if [[ ! -d "$project_name" ]]; then
        print_error "Project $project_name not found"
        continue
    fi
    
    echo ""
    echo "Enter the GitHub repository URL for $project_name"
    echo "(e.g., https://github.com/yourusername/$project_name.git)"
    echo "Press Enter to skip if you'll create the repository later:"
    read -p "GitHub URL: " github_url
    
    echo ""
    echo "You are about to convert '$project_name' to a Git submodule."
    echo "A backup will be created before any changes are made."
    read -p "Continue? (y/n): " confirm
    
    if [[ "$confirm" == "y" ]] || [[ "$confirm" == "Y" ]]; then
        setup_submodule "$project_name" "$github_url"
    else
        print_info "Skipping $project_name"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
done

print_info "Setup complete!"