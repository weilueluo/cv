<#
.SYNOPSIS
    Build script for CV - compiles LaTeX to PDF and optionally converts to PNG.

.DESCRIPTION
    Compiles resume.tex and resumeCN.tex using lualatex, optionally converts
    PDFs to PNGs using ImageMagick, and copies PDFs to the repository root.

.PARAMETER SkipPng
    Skip PDF to PNG conversion (useful if ImageMagick/Ghostscript not installed).

.PARAMETER EnOnly
    Only build the English resume.

.EXAMPLE
    .\build.ps1
    .\build.ps1 -SkipPng
    .\build.ps1 -EnOnly
#>
param(
    [switch]$SkipPng,
    [switch]$EnOnly
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
if (-not $PSScriptRoot) { $RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path }
$SrcDir = Join-Path $RepoRoot "src"

function Test-Tool {
    param([string]$Name, [string]$InstallHint)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Write-Error "'$Name' not found. $InstallHint"
        return $false
    }
    return $true
}

# --- Check required tools ---
$ok = Test-Tool "lualatex" "Install MiKTeX (https://miktex.org/download) or TeX Live (https://tug.org/texlive/)."
if (-not $ok) { exit 1 }

if (-not $SkipPng) {
    $hasImageMagick = Test-Tool "magick" "Install ImageMagick (https://imagemagick.org/script/download.php#windows). Use 'magick' not 'convert' on Windows."
    $hasGhostscript = Get-Command "gswin64c" -ErrorAction SilentlyContinue
    if (-not $hasGhostscript) { $hasGhostscript = Get-Command "gswin32c" -ErrorAction SilentlyContinue }
    if (-not $hasGhostscript) {
        Write-Warning "Ghostscript not found. Install from https://ghostscript.com/releases/gsdnld.html"
        Write-Warning "PNG conversion may fail without Ghostscript. Use -SkipPng to skip."
    }
    if (-not $hasImageMagick) {
        Write-Warning "Skipping PNG conversion because ImageMagick is not installed."
        $SkipPng = $true
    }
}

# --- Compile LaTeX ---
Push-Location $SrcDir
try {
    $texFiles = if ($EnOnly) { @("resume.tex") } else { @("resume.tex", "resumeCN.tex") }

    foreach ($tex in $texFiles) {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($tex)
        Write-Host "`n=== Compiling $tex ===" -ForegroundColor Cyan
        & lualatex --interaction=nonstopmode $tex
        if (-not (Test-Path "$name.pdf")) {
            Write-Error "lualatex failed for $tex - no PDF produced. Check $name.log for details."
            exit 1
        }
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "lualatex exited with code $LASTEXITCODE for $tex (PDF was still produced). Check $name.log for warnings."
        }
        Write-Host "  -> src/$name.pdf" -ForegroundColor Green
    }

    # --- Convert PDF to PNG ---
    if (-not $SkipPng) {
        foreach ($tex in $texFiles) {
            $name = [System.IO.Path]::GetFileNameWithoutExtension($tex)
            Write-Host "`n=== Converting $name.pdf to PNG ===" -ForegroundColor Cyan
            & magick -density 900 -background white -alpha off "$name.pdf" -quality 90 -colorspace RGB "$name.png"
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "PNG conversion failed for $name.pdf. Continuing..."
            } else {
                Write-Host "  -> src/$name.png" -ForegroundColor Green
            }
        }
    }

    # --- Copy PDFs to root ---
    foreach ($tex in $texFiles) {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($tex)
        $src = Join-Path $SrcDir "$name.pdf"
        $dst = Join-Path $RepoRoot "$name.pdf"
        Copy-Item $src $dst -Force
        Write-Host "  -> $name.pdf (root)" -ForegroundColor Green
    }

    Write-Host "`n=== Build complete ===" -ForegroundColor Cyan
} finally {
    Pop-Location
}

exit 0
