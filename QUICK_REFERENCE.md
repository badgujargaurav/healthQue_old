# Quick Reference Guide

## TL;DR - Fast Track Setup

### Prerequisites
- GitHub account with repository creation permissions
- Git installed and configured
- 5 minutes of time

### Steps (3 simple steps)

1. **Create the new repository** on GitHub
   - Go to https://github.com/new
   - Name: `healthQue`
   - Visibility: Your choice
   - Don't initialize with anything
   - Click "Create repository"

2. **Run the automation script**
   ```bash
   # Linux/Mac/WSL
   cd scripts
   ./init-branches.sh badgujargaurav/healthQue main dev
   
   # Windows PowerShell
   cd scripts
   .\init-branches.ps1 -RepoFullName "badgujargaurav/healthQue" -BaseBranch "main" -DefaultBranch "dev"
   ```

3. **Done!** All 6 environment branches created:
   - ✅ prod
   - ✅ pre-prod  
   - ✅ staging
   - ✅ qa
   - ✅ dev (set as default)
   - ✅ dev-phases

## Command Cheat Sheet

### Bash Script
```bash
# Basic usage (creates from 'main')
./init-branches.sh owner/repo

# Specify base branch
./init-branches.sh owner/repo master

# Specify base and default branch
./init-branches.sh owner/repo main dev

# View help
./init-branches.sh
```

### PowerShell Script
```powershell
# Basic usage
.\init-branches.ps1 -RepoFullName "owner/repo"

# With all options
.\init-branches.ps1 -RepoFullName "owner/repo" -BaseBranch "main" -DefaultBranch "dev"

# Get help
Get-Help .\init-branches.ps1 -Detailed
```

### GitHub Actions
1. Go to: https://github.com/owner/repo/actions
2. Select: "Manage Environment Branches"
3. Click: "Run workflow"
4. Choose: base_branch = "main"
5. Optional: Enable dry_run for testing
6. Click: "Run workflow"

## Branch Hierarchy Diagram

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  prod (production)                             │
│    ↓ merge from pre-prod                       │
│  pre-prod (pre-production)                     │
│    ↓ merge from staging                        │
│  staging (staging environment)                 │
│    ↓ merge from qa                             │
│  qa (quality assurance)                        │
│    ↓ merge from dev                            │
│  dev (development) ← DEFAULT BRANCH            │
│    ↑ merge from dev-phases                     │
│  dev-phases (feature branches)                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

## Workflow Diagram

```
┌─────────────────┐
│  Developer      │
│  Creates PR     │
└────────┬────────┘
         │
         ↓
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  dev-phases     │ --> │  dev            │ --> │  qa             │
│  (features)     │     │  (integration)  │     │  (testing)      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                          │
                                                          ↓
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  prod           │ <-- │  pre-prod       │ <-- │  staging        │
│  (live)         │     │  (final check)  │     │  (integration)  │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Troubleshooting Quick Fixes

### "Permission denied"
```bash
gh auth login
# Follow the prompts
```

### "Base branch does not exist"
```bash
# Create initial commit first
git clone https://github.com/owner/repo
cd repo
echo "# Project" > README.md
git add README.md
git commit -m "Initial commit"
git push -u origin main

# Then run the script
```

### "Branch already exists"
**This is normal!** The script skips existing branches. No action needed.

### Script won't run (Linux/Mac)
```bash
chmod +x scripts/init-branches.sh
./scripts/init-branches.sh owner/repo
```

## File Index

| Need to...                          | Open this file                    |
|-------------------------------------|-----------------------------------|
| Get started quickly                 | **Quick Reference (this file)**   |
| Full setup instructions             | REPO_SETUP.md                     |
| Understand safety/security          | SAFETY_NOTES.md                   |
| See what was added                  | SUMMARY.md                        |
| Overview and links                  | README.md                         |
| Run bash automation                 | scripts/init-branches.sh          |
| Run PowerShell automation           | scripts/init-branches.ps1         |
| Use GitHub Actions                  | .github/workflows/manage-branches.yml |

## Common Use Cases

### Use Case 1: New Project Setup
```bash
# Create repo on GitHub
# Run script with defaults
./init-branches.sh badgujargaurav/healthQue main dev
# Set up branch protection (see REPO_SETUP.md)
# Start coding!
```

### Use Case 2: Testing First
```bash
# Run with dry-run in GitHub Actions
# Check the output
# Run for real
./init-branches.sh badgujargaurav/healthQue
```

### Use Case 3: Custom Base Branch
```bash
# Maybe you use 'master' instead of 'main'
./init-branches.sh badgujargaurav/healthQue master dev
```

### Use Case 4: Re-run After Partial Success
```bash
# Some branches failed to create?
# Just run again - it's idempotent
./init-branches.sh badgujargaurav/healthQue
# Already-existing branches are skipped
```

## After Branch Creation

### Immediate Actions (5 minutes)
1. ✅ Verify all branches exist on GitHub
2. ✅ Check default branch is set correctly
3. ✅ Clone the repository locally

### Important Setup (30 minutes)
1. 🔒 Set up branch protection rules (REPO_SETUP.md)
2. ⚙️ Configure CI/CD workflows
3. 👥 Add team members with appropriate roles

### Long-term Setup
1. 📋 Document deployment procedures
2. 🤖 Set up automated deployments
3. 📊 Configure monitoring and alerts

## Getting Help

1. **Check documentation**: See files in File Index above
2. **Script help**: Run script without arguments
3. **GitHub Issues**: Create issue in this repository
4. **Contact admin**: For permission-related issues

## Success Indicators

You'll know everything worked when:
- ✅ All 6 branches appear on GitHub
- ✅ Default branch shows as "dev"
- ✅ No error messages in script output
- ✅ You can clone and checkout each branch

## One-Liner Summary

> **Create 6 environment branches (prod, pre-prod, staging, qa, dev, dev-phases) in a new repository with one command.**

---

**Quick links:**
- 📖 [Full Documentation](REPO_SETUP.md)
- 🔒 [Safety Notes](SAFETY_NOTES.md)
- 📋 [Summary](SUMMARY.md)
