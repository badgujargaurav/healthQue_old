# HealthQue Repository Setup Guide

This guide provides instructions for creating a new `healthQue` repository with a proper environment branch hierarchy.

> ⚠️ **Important**: Before proceeding, please review the [Safety Notes and Best Practices](./SAFETY_NOTES.md) document for important warnings, security guidelines, and error handling procedures.

## Overview

The new `healthQue` repository will use a hierarchical branch structure to support different deployment environments:

```
prod (production)
  ↓
pre-prod (pre-production)
  ↓
staging
  ↓
qa (quality assurance)
  ↓
dev (development)
  ↓
dev-phases (feature development)
```

## Branch Hierarchy

1. **prod** - Production environment (stable, release-ready code)
2. **pre-prod** - Pre-production environment (final testing before production)
3. **staging** - Staging environment (integration testing)
4. **qa** - Quality Assurance environment (testing)
5. **dev** - Development environment (active development)
6. **dev-phases** - Development phases (feature branches, experimental work)

## Prerequisites

- GitHub account with repository creation permissions
- Git installed locally (2.x or higher)
- GitHub CLI (`gh`) installed (optional, for easier setup)
- Admin access to the new repository

## Manual Setup Steps

### Step 1: Create the New Repository

1. Go to GitHub.com and click the "+" icon → "New repository"
2. Repository name: `healthQue`
3. Description: "Smart appointment management app for healthcare providers"
4. Choose visibility (Public or Private)
5. **Do NOT** initialize with README, .gitignore, or license (we'll push from healthQue_old)
6. Click "Create repository"

### Step 2: Initialize Branches

#### Option A: Using the Automation Script (Recommended)

We provide both Bash and PowerShell scripts for automated branch setup:

**Using Bash (Linux/Mac/WSL):**
```bash
cd scripts
chmod +x init-branches.sh
./init-branches.sh <repository-owner>/<repository-name> [base-branch] [default-branch]
```

**Using PowerShell (Windows):**
```powershell
cd scripts
.\init-branches.ps1 -RepoFullName "<owner>/<repo>" [-BaseBranch "main"] [-DefaultBranch "dev"]
```

**Examples:**
```bash
# Create branches from main, set dev as default
./init-branches.sh badgujargaurav/healthQue main dev

# Create branches from master, keep current default
./init-branches.sh badgujargaurav/healthQue master
```

#### Option B: Manual Branch Creation

If you prefer to create branches manually:

```bash
# Clone the new repository
git clone https://github.com/<owner>/healthQue.git
cd healthQue

# Create an initial commit if repository is empty
echo "# HealthQue" > README.md
git add README.md
git commit -m "Initial commit"
git push -u origin main

# Create all environment branches from main
git checkout -b dev-phases
git push -u origin dev-phases

git checkout main
git checkout -b dev
git push -u origin dev

git checkout main
git checkout -b qa
git push -u origin qa

git checkout main
git checkout -b staging
git push -u origin staging

git checkout main
git checkout -b pre-prod
git push -u origin pre-prod

git checkout main
git checkout -b prod
git push -u origin prod

# Set default branch to dev (requires admin permissions)
gh repo edit <owner>/healthQue --default-branch dev
# OR manually: Settings → Branches → Default branch → Switch to dev
```

### Step 3: Configure Branch Protection Rules (Recommended)

Protect your main environment branches to prevent accidental changes:

1. Go to repository Settings → Branches
2. Add branch protection rules for: `prod`, `pre-prod`, `staging`, `qa`, `dev`

**Recommended protection settings:**
- ✅ Require pull request reviews before merging (at least 1 reviewer)
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ✅ Include administrators (for prod/pre-prod)
- ✅ Require linear history

### Step 4: Set Up Branch Merge Flow

Configure which branches can merge into which:

- `dev-phases` → `dev` (feature PRs)
- `dev` → `qa` (development release)
- `qa` → `staging` (tested features)
- `staging` → `pre-prod` (integration complete)
- `pre-prod` → `prod` (production release)

This can be enforced using:
- Branch protection rules
- CODEOWNERS file
- GitHub Actions workflows (see `.github/workflows/manage-branches.yml`)

## Using GitHub Actions for Branch Management

This repository includes a GitHub Actions workflow that can create/update branches in the current repository.

### Running the Workflow

1. Go to the repository on GitHub
2. Click "Actions" tab
3. Select "Manage Environment Branches" workflow
4. Click "Run workflow"
5. Choose the branch to run from
6. Enter the base branch name (default: main)
7. Click "Run workflow"

**Note:** The GitHub Actions workflow requires write permissions. Ensure the `GITHUB_TOKEN` has sufficient permissions in Settings → Actions → General → Workflow permissions.

## Migrating from healthQue_old

If you want to migrate existing code from `healthQue_old` to the new `healthQue` repository:

```bash
# Clone the old repository
git clone https://github.com/badgujargaurav/healthQue_old.git
cd healthQue_old

# Add the new repository as a remote
git remote add new-origin https://github.com/badgujargaurav/healthQue.git

# Push to the new repository
git push new-origin main:main

# Then create the branch hierarchy using the scripts above
```

## Troubleshooting

### Authentication Issues

If you encounter authentication errors:

```bash
# Use GitHub CLI to authenticate
gh auth login

# OR configure Git credentials
git config --global credential.helper cache
```

### Branch Already Exists

The scripts are idempotent - they will skip existing branches without error. If you need to recreate a branch:

```bash
# Delete the branch locally and remotely
git branch -D branch-name
git push origin --delete branch-name

# Then re-run the script
```

### Permission Denied

Ensure you have admin access to the repository. Setting the default branch requires admin permissions.

## Best Practices

1. **Always work through pull requests** - Never push directly to environment branches
2. **Follow the merge hierarchy** - Don't skip environments (e.g., dev → staging, not dev → prod)
3. **Tag releases** - Use semantic versioning for production deployments
4. **Keep branches in sync** - Regularly merge upstream to avoid drift
5. **Protect critical branches** - Enable branch protection on prod, pre-prod, and staging
6. **Test before merging** - Ensure CI/CD passes before merging to higher environments
7. **Document changes** - Maintain a CHANGELOG.md for tracking releases

## Additional Resources

- [GitHub Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Git Branching Strategies](https://www.atlassian.com/git/tutorials/comparing-workflows)

## Support

For issues or questions about this setup:
- Create an issue in the repository
- Contact the development team
- Review the automation scripts in the `scripts/` directory
