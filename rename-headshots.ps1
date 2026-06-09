# ============================================================
# Coldwell Banker Hearthside — Headshot File Renamer
# Renames all files in all subfolders to:
#   - Lowercase
#   - Spaces replaced with hyphens
# ============================================================
# HOW TO USE:
#   1. Copy this file into your cbagentheadshots folder
#   2. Right-click the file and select "Run with PowerShell"
#   3. Review the preview list and press Y to confirm
# ============================================================

$rootFolder = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Headshot File Renamer" -ForegroundColor Cyan
Write-Host "  Folder: $rootFolder" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Find all files in all subfolders
$files = Get-ChildItem -Path $rootFolder -Recurse -File | Where-Object { $_.Name -ne "rename-headshots.ps1" }

if ($files.Count -eq 0) {
    Write-Host "No files found in subfolders." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit
}

# Preview changes
Write-Host "The following files will be renamed:" -ForegroundColor Yellow
Write-Host ""

$changes = @()
$hasChanges = $false

foreach ($file in $files) {
    $newName = $file.Name.ToLower().Replace(' ', '-')
    
    if ($newName -ne $file.Name) {
        Write-Host "  BEFORE: $($file.DirectoryName)\$($file.Name)" -ForegroundColor Red
        Write-Host "  AFTER:  $($file.DirectoryName)\$newName" -ForegroundColor Green
        Write-Host ""
        $changes += @{ File = $file; NewName = $newName }
        $hasChanges = $true
    }
}

if (-not $hasChanges) {
    Write-Host "All files are already correctly named! Nothing to do." -ForegroundColor Green
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  $($changes.Count) file(s) will be renamed" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$confirm = Read-Host "Do you want to proceed? (Y/N)"

if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host ""
    Write-Host "Cancelled. No files were renamed." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit
}

Write-Host ""

# Rename files
$successCount = 0
$errorCount = 0

foreach ($change in $changes) {
    try {
        Rename-Item -Path $change.File.FullName -NewName $change.NewName -ErrorAction Stop
        Write-Host "  ✔ Renamed: $($change.NewName)" -ForegroundColor Green
        $successCount++
    } catch {
        Write-Host "  ✘ Failed:  $($change.File.Name) — $_" -ForegroundColor Red
        $errorCount++
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Done! $successCount renamed, $errorCount failed" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Pause
Read-Host "Press Enter to exit"
