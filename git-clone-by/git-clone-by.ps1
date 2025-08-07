param (
    [string]$RepoURL,          # Argument 1: Git repository URL
    [string]$TargetDir         # Argument 2: Clone target directory (optional)
)

# Extract owner and repo name from the URL
if ($RepoURL -match "github\.com/([^/]+)/([^\.]+)\.git") {
    $Owner = $matches[1]
    $RepoName = $matches[2]
    Write-Host "Repository URL detected:"
    Write-Host "  Owner    : $Owner"
    Write-Host "  RepoName : $RepoName"
} else {
    Write-Error "Invalid GitHub repository URL: $RepoURL"
    exit 1
}

# Use repo name as target directory if not specified
if (-not $TargetDir) {
    $TargetDir = $RepoName
    Write-Host "Target directory not specified. Using default: $TargetDir"
} else {
    Write-Host "Target directory: $TargetDir"
}

#$ScriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
#$ConfigFileName = ".$ScriptName.config"
#PS2EXEで実行ファイルにした場合、↑ではNG

$ConfigFileName = ".git-clone-by.config"
$ConfigPath = Join-Path $env:UserProfile $ConfigFileName

Write-Host "Loading config from: $ConfigPath"

# Parse config function
function ParseConfig {
    param ([string]$JsonFilePath)

    if (-Not (Test-Path $JsonFilePath)) {
        Write-Error "Config file not found: $JsonFilePath"
        exit 1
    }

    $jsonContent = Get-Content $JsonFilePath -Raw | ConvertFrom-Json
    return $jsonContent
}

# Load config and retrieve credentials
$config = ParseConfig -JsonFilePath $ConfigPath

if (-not $config.$Owner) {
    Write-Error "Owner '$Owner' not found in config."
    exit 1
}

$name  = $config.$Owner.name
$email = $config.$Owner.email
$token = $config.$Owner.token

Write-Host "Using credentials from config:"
Write-Host "  Name : $name"
Write-Host "  Email: $email"
Write-Host "  Token: (hidden for security)"

# Construct authenticated URL
$rewriteURL = "https://$name`:$token@github.com/$Owner/$RepoName.git"
Write-Host "Cloning from authenticated URL..."

#この呼び出し方だとcloneは出来ているがgitがエラーを出力する
#git clone $rewriteURL $TargetDir
#if ($LASTEXITCODE -ne 0) {
#    Write-Error "git clone failed."
#    exit 1
#}

# Git パスチェック
$gitPath = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitPath) {
    Write-Error "git not found. Ensure Git is installed and in your PATH."
    exit 1
}

# Clone
$cloneProcess = Start-Process git -ArgumentList "clone", $rewriteURL, $TargetDir -Wait -NoNewWindow -PassThru
if ($cloneProcess.ExitCode -ne 0) {
    Write-Error "git clone failed with exit code $($cloneProcess.ExitCode)"
    exit 1
}

git -C $TargetDir config --local user.name "$name"
git -C $TargetDir config --local user.email "$email"

Write-Host "Repository cloned and git user config set:"
Write-Host "  user.name  = $name"
Write-Host "  user.email = $email"
