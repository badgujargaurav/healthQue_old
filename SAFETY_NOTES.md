# Safety Notes and Best Practices

## ⚠️ Important Safety Warnings

### Before Running Any Scripts

1. **Verify Repository Access**: Ensure you have write/admin access to the target repository
2. **Backup Important Data**: Always backup existing branches and data before running automation
3. **Test in a Safe Environment**: Consider testing scripts on a test repository first
4. **Review Permissions**: The scripts require GitHub authentication with appropriate permissions

### Script Execution Safety

#### Bash Script (init-branches.sh)
- ✅ **Safe**: The script is idempotent - it will skip existing branches
- ✅ **Safe**: The script validates input before making changes
- ⚠️ **Caution**: Requires GitHub credentials (via Git or GitHub CLI)
- ⚠️ **Caution**: Setting default branch requires admin permissions

#### PowerShell Script (init-branches.ps1)
- ✅ **Safe**: The script is idempotent - it will skip existing branches
- ✅ **Safe**: The script validates input before making changes
- ⚠️ **Caution**: Requires GitHub credentials (via Git or GitHub CLI)
- ⚠️ **Caution**: Setting default branch requires admin permissions

#### GitHub Actions Workflow
- ✅ **Safe**: Includes a dry-run option to preview changes
- ✅ **Safe**: Only creates branches, never deletes or modifies code
- ⚠️ **Caution**: Requires `contents: write` permission
- ⚠️ **Caution**: Can only create branches in the current repository

## 🔒 Security Best Practices

### Authentication
1. **Use SSH Keys or Tokens**: Never store passwords in scripts
2. **GitHub CLI Authentication**: Use `gh auth login` for secure authentication
3. **Token Scopes**: Ensure tokens have only required permissions (repo scope)
4. **Token Expiration**: Use tokens with appropriate expiration dates

### Repository Protection
1. **Enable Branch Protection**: Protect production branches immediately after creation
2. **Require Reviews**: Set up pull request reviews for critical branches
3. **Status Checks**: Configure CI/CD checks before merging
4. **CODEOWNERS**: Define code owners for critical paths

### Access Control
1. **Limit Admin Access**: Only grant admin permissions to trusted users
2. **Audit Logs**: Regularly review repository activity logs
3. **Two-Factor Authentication**: Require 2FA for all contributors
4. **Team Permissions**: Use teams to manage group permissions

## 📋 Pre-Flight Checklist

Before creating branches in a new repository:

- [ ] Repository created and accessible
- [ ] You have admin/write access to the repository
- [ ] GitHub authentication configured (Git credentials or GitHub CLI)
- [ ] Base branch exists (usually 'main' or 'master')
- [ ] You've reviewed the branch names and hierarchy
- [ ] You understand the impact on existing workflows
- [ ] Backup/documentation of current state (if applicable)

## 🚨 Error Handling

### Common Errors and Solutions

#### "Permission denied" or "Authentication failed"
**Cause**: Insufficient permissions or authentication issues
**Solution**:
```bash
# For GitHub CLI
gh auth login

# For Git credentials
git config --global credential.helper cache

# Verify access
gh repo view owner/repo
```

#### "Branch already exists"
**Cause**: The branch was already created
**Solution**: This is normal and safe - the script will skip existing branches

#### "Base branch does not exist"
**Cause**: The specified base branch doesn't exist in the repository
**Solution**: 
- Verify the base branch name
- Check if the repository is empty (needs initial commit)
- Use the correct branch name (main vs master)

#### "Failed to set default branch"
**Cause**: Requires admin permissions or GitHub CLI not authenticated
**Solution**:
- Ensure you have admin access to the repository
- Authenticate GitHub CLI: `gh auth login`
- Set manually via GitHub web UI: Settings → Branches → Default branch

## 🔄 Rollback Procedures

### If Something Goes Wrong

#### Delete Individual Branches
```bash
# Delete local branch
git branch -D branch-name

# Delete remote branch
git push origin --delete branch-name
```

#### Using GitHub Web Interface
1. Go to repository → Branches
2. Find the branch to delete
3. Click the trash icon
4. Confirm deletion

#### Restore Default Branch
```bash
# Using GitHub CLI
gh repo edit owner/repo --default-branch main

# Or via web: Settings → Branches → Default branch
```

## 🛡️ Branch Protection Guidelines

After creating branches, immediately set up protection:

### Critical Branches (prod, pre-prod)
- ✅ Require pull request reviews (minimum 2)
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Require conversation resolution
- ✅ Include administrators in restrictions
- ✅ Require linear history
- ✅ Do not allow force pushes
- ✅ Do not allow deletions

### Important Branches (staging, qa)
- ✅ Require pull request reviews (minimum 1)
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Do not allow force pushes

### Development Branches (dev)
- ✅ Require pull request reviews (minimum 1)
- ✅ Require status checks to pass
- ⚠️ May allow force pushes (with caution)

### Feature Branches (dev-phases)
- ⚠️ Minimal restrictions
- ✅ Require status checks to pass (recommended)

## 📞 Support and Escalation

### When to Seek Help

1. **Permission Issues**: Cannot resolve authentication or access problems
2. **Data Loss**: Accidentally deleted or corrupted important branches
3. **System Errors**: Unexpected errors not covered in this document
4. **Automation Failures**: Scripts fail repeatedly with unclear errors

### Escalation Path

1. Check this document and REPO_SETUP.md
2. Review script logs and error messages
3. Search GitHub documentation
4. Create an issue in this repository
5. Contact repository administrators

## 📝 Audit Trail

Keep a record of branch creation activities:

```bash
# Log script execution
./init-branches.sh owner/repo main dev | tee branch-creation-$(date +%Y%m%d-%H%M%S).log

# Review GitHub audit log
# Repository → Settings → Security → Audit log
```

## ⚙️ Testing Recommendations

### Before Production Use

1. **Create Test Repository**: Test scripts on a throwaway repository
2. **Dry Run**: Use workflow dry-run option to preview changes
3. **Single Branch Test**: Create one branch manually first to verify access
4. **Review Logs**: Check all script output for warnings or errors
5. **Verify Results**: Confirm branches exist with correct base commits

### Testing Checklist

- [ ] Script runs without errors in test environment
- [ ] All expected branches are created
- [ ] Existing branches are not modified
- [ ] Default branch is set correctly (if specified)
- [ ] No unexpected side effects
- [ ] Logs show expected behavior
- [ ] Can authenticate and access repository
- [ ] Scripts are idempotent (re-running doesn't cause errors)

## 🔐 Credential Management

### Do NOT

- ❌ Store passwords in plain text
- ❌ Commit credentials to repositories
- ❌ Share authentication tokens
- ❌ Use personal tokens for shared services
- ❌ Set tokens without expiration

### DO

- ✅ Use SSH keys for Git operations
- ✅ Use GitHub CLI for authentication
- ✅ Use environment variables for tokens
- ✅ Set appropriate token expiration dates
- ✅ Rotate credentials regularly
- ✅ Use fine-grained personal access tokens
- ✅ Revoke unused tokens

## 📚 Additional Resources

- [GitHub Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)
- [GitHub Authentication](https://docs.github.com/en/authentication)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [Git Documentation](https://git-scm.com/doc)

---

**Last Updated**: 2026-02-12  
**Version**: 1.0.0  
**Maintainer**: Repository Administrators
