# Copies campaign notes from the Obsidian vault into Quartz and pushes to GitHub.
$ErrorActionPreference = "Stop"

$VaultNotes = "C:\Users\Ilie\Documents\Obsidian Vault\KeysToKnowledge"
$QuartzRoot = "C:\Users\Ilie\Documents\orpheus-quartz"
$ContentDest = Join-Path $QuartzRoot "content\KeysToKnowledge"

if (-not (Test-Path -LiteralPath $VaultNotes)) {
  throw "Vault notes folder not found: $VaultNotes"
}

New-Item -ItemType Directory -Force -Path $ContentDest | Out-Null

$robocopy = & robocopy $VaultNotes $ContentDest /MIR /R:2 /W:2 /NFL /NDL /NJH /NJS /NP /XD .obsidian
if ($LASTEXITCODE -ge 8) {
  throw "robocopy failed with exit code $LASTEXITCODE"
}

Set-Location $QuartzRoot

$changes = git status --porcelain -- content/KeysToKnowledge content/index.md
if (-not $changes) {
  Write-Output "No note changes to publish."
  exit 0
}

git add -- "content/KeysToKnowledge" "content/index.md"
git commit -m "Sync notes from Obsidian"
git push origin HEAD

Write-Output "Published updates to GitHub."
