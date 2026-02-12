#!/usr/bin/env bash

#############################################################################
# Branch Initialization Script for HealthQue Repository
#
# This script creates the environment branch hierarchy:
# prod → pre-prod → staging → qa → dev → dev-phases
#
# Usage:
#   ./init-branches.sh <owner/repo> [base-branch] [default-branch]
#
# Examples:
#   ./init-branches.sh badgujargaurav/healthQue
#   ./init-branches.sh badgujargaurav/healthQue main dev
#   ./init-branches.sh badgujargaurav/healthQue master
#
# Requirements:
#   - Git installed and configured
#   - GitHub CLI (gh) for setting default branch (optional)
#   - Write access to the repository
#############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_FULL_NAME="${1:-}"
BASE_BRANCH="${2:-main}"
DEFAULT_BRANCH="${3:-}"

# Branch hierarchy (order matters)
BRANCHES=(
    "prod"
    "pre-prod"
    "staging"
    "qa"
    "dev"
    "dev-phases"
)

#############################################################################
# Helper Functions
#############################################################################

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Show usage information
usage() {
    cat << EOF
Usage: $0 <owner/repo> [base-branch] [default-branch]

Arguments:
    owner/repo      GitHub repository in format 'owner/repository-name' (required)
    base-branch     Base branch to create new branches from (default: main)
    default-branch  Branch to set as repository default (optional)

Environment Branches (created in order):
    prod, pre-prod, staging, qa, dev, dev-phases

Examples:
    $0 badgujargaurav/healthQue
    $0 badgujargaurav/healthQue main dev
    $0 badgujargaurav/healthQue master

Requirements:
    - Git must be installed and configured
    - Write access to the repository
    - GitHub CLI (gh) for setting default branch (optional)

EOF
    exit 1
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    if ! command_exists git; then
        print_error "Git is not installed"
        exit 1
    fi
    print_success "Git is installed"
    
    if ! command_exists gh; then
        print_warning "GitHub CLI (gh) is not installed - default branch cannot be set automatically"
        print_info "Install from: https://cli.github.com/"
    else
        print_success "GitHub CLI (gh) is installed"
    fi
    
    echo ""
}

# Validate input
validate_input() {
    if [[ -z "$REPO_FULL_NAME" ]]; then
        print_error "Repository name is required"
        usage
    fi
    
    if [[ ! "$REPO_FULL_NAME" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$ ]]; then
        print_error "Invalid repository format. Use: owner/repo"
        usage
    fi
    
    print_success "Repository: $REPO_FULL_NAME"
    print_success "Base branch: $BASE_BRANCH"
    if [[ -n "$DEFAULT_BRANCH" ]]; then
        print_success "Default branch will be set to: $DEFAULT_BRANCH"
    fi
    echo ""
}

# Check if remote branch exists
remote_branch_exists() {
    local branch="$1"
    git ls-remote --heads "https://github.com/${REPO_FULL_NAME}.git" "refs/heads/${branch}" | grep -q .
}

# Create a branch
create_branch() {
    local branch="$1"
    
    # Check if branch already exists
    if remote_branch_exists "$branch"; then
        print_warning "Branch '$branch' already exists - skipping"
        return 0
    fi
    
    print_info "Creating branch '$branch' from '$BASE_BRANCH'..."
    
    # Create and push the branch
    if git ls-remote --heads "https://github.com/${REPO_FULL_NAME}.git" "refs/heads/${BASE_BRANCH}" | grep -q .; then
        # Use git push to create the branch directly on remote
        if git push "https://github.com/${REPO_FULL_NAME}.git" "refs/heads/${BASE_BRANCH}:refs/heads/${branch}" 2>/dev/null; then
            print_success "Created branch '$branch'"
            return 0
        else
            # If direct push fails, try with gh
            if command_exists gh; then
                if gh api repos/"${REPO_FULL_NAME}"/git/refs -f ref="refs/heads/${branch}" -f sha="$(gh api repos/"${REPO_FULL_NAME}"/git/refs/heads/"${BASE_BRANCH}" --jq '.object.sha')" >/dev/null 2>&1; then
                    print_success "Created branch '$branch' (via API)"
                    return 0
                fi
            fi
            print_error "Failed to create branch '$branch'"
            return 1
        fi
    else
        print_error "Base branch '$BASE_BRANCH' does not exist"
        return 1
    fi
}

# Set default branch
set_default_branch() {
    if [[ -z "$DEFAULT_BRANCH" ]]; then
        print_info "No default branch specified - skipping"
        return 0
    fi
    
    if ! command_exists gh; then
        print_warning "Cannot set default branch without GitHub CLI (gh)"
        print_info "Install gh and run: gh repo edit ${REPO_FULL_NAME} --default-branch ${DEFAULT_BRANCH}"
        return 0
    fi
    
    print_info "Setting default branch to '$DEFAULT_BRANCH'..."
    
    if gh repo edit "${REPO_FULL_NAME}" --default-branch "${DEFAULT_BRANCH}" 2>/dev/null; then
        print_success "Default branch set to '$DEFAULT_BRANCH'"
    else
        print_warning "Failed to set default branch - you may need to do this manually"
        print_info "Run: gh repo edit ${REPO_FULL_NAME} --default-branch ${DEFAULT_BRANCH}"
        print_info "Or via GitHub web UI: Settings → Branches → Default branch"
    fi
}

# Main execution
main() {
    print_header "HealthQue Branch Initialization Script"
    echo ""
    
    validate_input
    check_prerequisites
    
    print_header "Creating Environment Branches"
    
    local failed_branches=()
    
    for branch in "${BRANCHES[@]}"; do
        if ! create_branch "$branch"; then
            failed_branches+=("$branch")
        fi
    done
    
    echo ""
    
    if [[ ${#failed_branches[@]} -gt 0 ]]; then
        print_warning "Failed to create branches: ${failed_branches[*]}"
        echo ""
    fi
    
    set_default_branch
    
    echo ""
    print_header "Summary"
    
    print_info "Repository: $REPO_FULL_NAME"
    print_info "Base branch: $BASE_BRANCH"
    echo ""
    
    print_info "Branch Hierarchy:"
    for branch in "${BRANCHES[@]}"; do
        if remote_branch_exists "$branch"; then
            print_success "  $branch ✓"
        else
            print_error "  $branch ✗"
        fi
    done
    
    echo ""
    print_header "Next Steps"
    echo "1. Verify branches in GitHub: https://github.com/${REPO_FULL_NAME}/branches"
    echo "2. Configure branch protection rules (Settings → Branches)"
    echo "3. Set up CI/CD workflows for each environment"
    echo "4. Review REPO_SETUP.md for additional configuration"
    echo ""
    
    if [[ ${#failed_branches[@]} -gt 0 ]]; then
        print_warning "Some branches could not be created. Check your permissions and try again."
        exit 1
    fi
    
    print_success "Branch initialization complete!"
}

# Run main function
main "$@"
