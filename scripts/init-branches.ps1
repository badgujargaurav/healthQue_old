<#
.SYNOPSIS
    Branch Initialization Script for HealthQue Repository

.DESCRIPTION
    This script creates the environment branch hierarchy:
    prod → pre-prod → staging → qa → dev → dev-phases

.PARAMETER RepoFullName
    GitHub repository in format 'owner/repository-name' (required)

.PARAMETER BaseBranch
    Base branch to create new branches from (default: main)

.PARAMETER DefaultBranch
    Branch to set as repository default (optional)

.EXAMPLE
    .\init-branches.ps1 -RepoFullName "badgujargaurav/healthQue"

.EXAMPLE
    .\init-branches.ps1 -RepoFullName "badgujargaurav/healthQue" -BaseBranch "main" -DefaultBranch "dev"

.EXAMPLE
    .\init-branches.ps1 -RepoFullName "badgujargaurav/healthQue" -BaseBranch "master"

.NOTES
    Requirements:
    - Git installed and configured
    - GitHub CLI (gh) for setting default branch (optional)
    - Write access to the repository
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidatePattern('^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$')]
    [string]$RepoFullName,
    
    [Parameter(Mandatory=$false, Position=1)]
    [string]$BaseBranch = "main",
    
    [Parameter(Mandatory=$false, Position=2)]
    [string]$DefaultBranch = ""
)

# Branch hierarchy (order matters)
$Branches = @(
    "prod",
    "pre-prod",
    "staging",
    "qa",
    "dev",
    "dev-phases"
)

#############################################################################
# Helper Functions
#############################################################################

function Write-Header {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Blue
    Write-Host $Message -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Test-RemoteBranchExists {
    param(
        [string]$RepoUrl,
        [string]$Branch
    )
    
    try {
        $result = git ls-remote --heads $RepoUrl "refs/heads/$Branch" 2>&1
        return $result -match "refs/heads/$Branch"
    }
    catch {
        return $false
    }
}

function Get-RemoteBranchSha {
    param(
        [string]$RepoFullName,
        [string]$Branch
    )
    
    try {
        if (Test-CommandExists "gh") {
            $sha = gh api "repos/$RepoFullName/git/refs/heads/$Branch" --jq '.object.sha' 2>$null
            return $sha
        }
    }
    catch {
        return $null
    }
    return $null
}

function New-RemoteBranch {
    param(
        [string]$RepoFullName,
        [string]$Branch,
        [string]$FromBranch
    )
    
    $repoUrl = "https://github.com/$RepoFullName.git"
    
    # Check if branch already exists
    if (Test-RemoteBranchExists -RepoUrl $repoUrl -Branch $Branch) {
        Write-Warning "Branch '$Branch' already exists - skipping"
        return $true
    }
    
    Write-Info "Creating branch '$Branch' from '$FromBranch'..."
    
    # Verify base branch exists
    if (-not (Test-RemoteBranchExists -RepoUrl $repoUrl -Branch $FromBranch)) {
        Write-ErrorMsg "Base branch '$FromBranch' does not exist"
        return $false
    }
    
    # Try direct push method
    try {
        $null = git push $repoUrl "refs/heads/${FromBranch}:refs/heads/${Branch}" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Created branch '$Branch'"
            return $true
        }
    }
    catch {
        # Continue to API method
    }
    
    # Try GitHub API method
    if (Test-CommandExists "gh") {
        try {
            $sha = Get-RemoteBranchSha -RepoFullName $RepoFullName -Branch $FromBranch
            if ($sha) {
                $body = @{
                    ref = "refs/heads/$Branch"
                    sha = $sha
                } | ConvertTo-Json
                
                # Write body to temp file for gh api
                $tempFile = New-TemporaryFile
                try {
                    $body | Out-File -FilePath $tempFile.FullName -Encoding utf8 -NoNewline
                    $null = gh api "repos/$RepoFullName/git/refs" --method POST --input $tempFile.FullName 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-Success "Created branch '$Branch' (via API)"
                        return $true
                    }
                }
                finally {
                    Remove-Item -Path $tempFile.FullName -ErrorAction SilentlyContinue
                }
            }
        }
        catch {
            # Fall through to error
        }
    }
    
    Write-ErrorMsg "Failed to create branch '$Branch'"
    return $false
}

function Set-DefaultBranch {
    param(
        [string]$RepoFullName,
        [string]$Branch
    )
    
    if ([string]::IsNullOrEmpty($Branch)) {
        Write-Info "No default branch specified - skipping"
        return
    }
    
    if (-not (Test-CommandExists "gh")) {
        Write-Warning "Cannot set default branch without GitHub CLI (gh)"
        Write-Info "Install gh and run: gh repo edit $RepoFullName --default-branch $Branch"
        return
    }
    
    Write-Info "Setting default branch to '$Branch'..."
    
    try {
        $null = gh repo edit $RepoFullName --default-branch $Branch 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Default branch set to '$Branch'"
        }
        else {
            throw
        }
    }
    catch {
        Write-Warning "Failed to set default branch - you may need to do this manually"
        Write-Info "Run: gh repo edit $RepoFullName --default-branch $Branch"
        Write-Info "Or via GitHub web UI: Settings → Branches → Default branch"
    }
}

#############################################################################
# Main Execution
#############################################################################

try {
    Write-Header "HealthQue Branch Initialization Script"
    Write-Host ""
    
    # Validate prerequisites
    Write-Header "Checking Prerequisites"
    
    if (-not (Test-CommandExists "git")) {
        Write-ErrorMsg "Git is not installed"
        exit 1
    }
    Write-Success "Git is installed"
    
    if (-not (Test-CommandExists "gh")) {
        Write-Warning "GitHub CLI (gh) is not installed - default branch cannot be set automatically"
        Write-Info "Install from: https://cli.github.com/"
    }
    else {
        Write-Success "GitHub CLI (gh) is installed"
    }
    
    Write-Host ""
    
    # Display configuration
    Write-Success "Repository: $RepoFullName"
    Write-Success "Base branch: $BaseBranch"
    if (-not [string]::IsNullOrEmpty($DefaultBranch)) {
        Write-Success "Default branch will be set to: $DefaultBranch"
    }
    Write-Host ""
    
    # Create branches
    Write-Header "Creating Environment Branches"
    
    $failedBranches = @()
    
    foreach ($branch in $Branches) {
        if (-not (New-RemoteBranch -RepoFullName $RepoFullName -Branch $branch -FromBranch $BaseBranch)) {
            $failedBranches += $branch
        }
    }
    
    Write-Host ""
    
    if ($failedBranches.Count -gt 0) {
        Write-Warning "Failed to create branches: $($failedBranches -join ', ')"
        Write-Host ""
    }
    
    # Set default branch
    Set-DefaultBranch -RepoFullName $RepoFullName -Branch $DefaultBranch
    
    # Summary
    Write-Host ""
    Write-Header "Summary"
    
    Write-Info "Repository: $RepoFullName"
    Write-Info "Base branch: $BaseBranch"
    Write-Host ""
    
    Write-Info "Branch Hierarchy:"
    $repoUrl = "https://github.com/$RepoFullName.git"
    foreach ($branch in $Branches) {
        if (Test-RemoteBranchExists -RepoUrl $repoUrl -Branch $branch) {
            Write-Success "  $branch ✓"
        }
        else {
            Write-ErrorMsg "  $branch ✗"
        }
    }
    
    # Next steps
    Write-Host ""
    Write-Header "Next Steps"
    Write-Host "1. Verify branches in GitHub: https://github.com/$RepoFullName/branches"
    Write-Host "2. Configure branch protection rules (Settings → Branches)"
    Write-Host "3. Set up CI/CD workflows for each environment"
    Write-Host "4. Review REPO_SETUP.md for additional configuration"
    Write-Host ""
    
    if ($failedBranches.Count -gt 0) {
        Write-Warning "Some branches could not be created. Check your permissions and try again."
        exit 1
    }
    
    Write-Success "Branch initialization complete!"
    exit 0
}
catch {
    Write-ErrorMsg "An error occurred: $_"
    exit 1
}
