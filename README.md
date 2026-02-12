# HealthQue_old

This is the old repository for HealthQue. The project is being migrated to a new repository with improved environment management and deployment practices.

## About HealthQue

HealthQue is a smart, streamlined appointment management app designed to keep doctors' schedules organized and patients' visits running on time. It helps clinics manage the entire patient journey—from booking and reminders to check‑in and post‑visit follow‑ups—in one clean, easy-to-use interface.

Built for busy practices, HealthQue reduces no-shows with automated reminders, optimizes time slots to cut waiting room queues, and gives staff a clear view of each doctor's day at a glance. The result is a smoother workflow for providers, shorter waits for patients, and a more professional, modern experience for the entire clinic.

## Repository Migration

This repository contains documentation and automation tools to help set up the new `healthQue` repository with a proper environment branch hierarchy.

### Branch Hierarchy for New Repository

The new repository will use the following environment branches:
- `prod` - Production environment
- `pre-prod` - Pre-production environment
- `staging` - Staging environment
- `qa` - Quality assurance environment
- `dev` - Development environment (default)
- `dev-phases` - Feature development branches

### Quick Start

To set up the new repository with environment branches:

1. **Read the setup guide**: [REPO_SETUP.md](./REPO_SETUP.md)
2. **Create the new repository** on GitHub (name it `healthQue`)
3. **Run the automation script**:
   ```bash
   # Using Bash (Linux/Mac/WSL)
   cd scripts
   ./init-branches.sh badgujargaurav/healthQue main dev
   
   # Using PowerShell (Windows)
   cd scripts
   .\init-branches.ps1 -RepoFullName "badgujargaurav/healthQue" -BaseBranch "main" -DefaultBranch "dev"
   ```

### Available Tools

- **[REPO_SETUP.md](./REPO_SETUP.md)** - Complete guide for repository setup and branch management
- **[SAFETY_NOTES.md](./SAFETY_NOTES.md)** - Important safety warnings and best practices
- **[scripts/init-branches.sh](./scripts/init-branches.sh)** - Bash script for automated branch creation
- **[scripts/init-branches.ps1](./scripts/init-branches.ps1)** - PowerShell script for automated branch creation
- **[.github/workflows/manage-branches.yml](./.github/workflows/manage-branches.yml)** - GitHub Actions workflow for branch management

### Documentation

- 📖 [Complete Repository Setup Guide](./REPO_SETUP.md)
- 🔒 [Safety Notes and Best Practices](./SAFETY_NOTES.md)
- 🔧 [Automation Scripts](./scripts/)
- ⚙️ [GitHub Actions Workflows](./.github/workflows/)

### Support

For questions or issues with the repository setup:
1. Review the [REPO_SETUP.md](./REPO_SETUP.md) documentation
2. Check the script comments in [scripts/](./scripts/)
3. Create an issue in this repository
