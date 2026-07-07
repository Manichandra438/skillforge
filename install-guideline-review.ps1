# Installs ONLY the guideline-review skill for Claude Code (global) and/or
# GitHub Copilot CLI (repo-local). Other skillforge skills, if any, have
# their own install-<skill>.ps1 script and are not touched by this one.
param(
    [switch]$ClaudeOnly,
    [switch]$CopilotOnly,
    [string]$Dir = "."
)

$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/Manichandra438/skillforge.git"
$SkillRelPath = "plugins/guideline-review/skills/guideline-review"
$ScriptDir = $PSScriptRoot

$DoClaude = -not $CopilotOnly
$DoCopilot = -not $ClaudeOnly

if ($ScriptDir -and (Test-Path (Join-Path $ScriptDir $SkillRelPath))) {
    $Src = $ScriptDir
} else {
    $Src = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Force -Path $Src | Out-Null
    git clone --depth 1 $RepoUrl $Src | Out-Null
}

if ($DoClaude) {
    $ClaudeSkills = Join-Path $HOME ".claude/skills"
    New-Item -ItemType Directory -Force -Path $ClaudeSkills | Out-Null
    Copy-Item -Recurse -Force (Join-Path $Src $SkillRelPath) (Join-Path $ClaudeSkills "guideline-review")
    Write-Host "Claude Code: installed guideline-review skill -> $ClaudeSkills/guideline-review/SKILL.md"
}

if ($DoCopilot) {
    $CopilotSkills = Join-Path $Dir ".github/skills"
    New-Item -ItemType Directory -Force -Path $CopilotSkills | Out-Null
    Copy-Item -Recurse -Force (Join-Path $Src $SkillRelPath) (Join-Path $CopilotSkills "guideline-review")
    Write-Host "Copilot CLI: installed guideline-review skill -> $CopilotSkills/guideline-review/SKILL.md"
}

Write-Host "Done. Run /review-guidelines in a project with docs/ENGINEERING_GUIDELINES.md."
