# =============================================================
#  render.ps1 — Pre-render Mermaid .mmd files on Windows
#
#  REQUIREMENTS:
#    npm install -g @mermaid-js/mermaid-cli
#
#  USAGE (PowerShell):
#    .\render.ps1                         # render all .mmd here → PDF
#    .\render.ps1 -SrcDir diagrams -OutDir figs
#    .\render.ps1 -Format svg -Theme dark
# =============================================================

param(
    [string]$SrcDir  = ".",
    [string]$OutDir  = "",
    [ValidateSet("pdf","svg","png")]
    [string]$Format  = "pdf",
    [ValidateSet("default","dark","forest","neutral")]
    [string]$Theme   = "default",
    [string]$Bg      = "white",
    [int]   $Scale   = 2
)

$ErrorActionPreference = "Stop"

function Write-Log  { param($m) Write-Host "[render] $m" -ForegroundColor Cyan   }
function Write-OK   { param($m) Write-Host "[  OK  ] $m" -ForegroundColor Green  }
function Write-Warn { param($m) Write-Host "[ WARN ] $m" -ForegroundColor Yellow }
function Write-Err  { param($m) Write-Host "[ ERR  ] $m" -ForegroundColor Red    }

# Check mmdc
if (-not (Get-Command mmdc -ErrorAction SilentlyContinue)) {
    Write-Err "mmdc not found. Run: npm install -g @mermaid-js/mermaid-cli"
    exit 1
}

$files = Get-ChildItem -Path $SrcDir -Filter "*.mmd" -Recurse -Depth 3

if ($files.Count -eq 0) {
    Write-Warn "No .mmd files found in '$SrcDir'."
    exit 0
}

Write-Log "Found $($files.Count) .mmd file(s)"

$pass = 0; $fail = 0

foreach ($file in $files) {
    $baseName = $file.BaseName

    if ($OutDir -ne "") {
        New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
        $dest = Join-Path $OutDir "$baseName.$Format"
    } else {
        $dest = Join-Path $file.DirectoryName "$baseName.$Format"
    }

    Write-Log "Rendering $($file.Name) → $dest"

    $args = @(
        "--input",  $file.FullName,
        "--output", $dest,
        "--theme",  $Theme,
        "--backgroundColor", $Bg,
        "--pdfFit"
    )

    if ($Format -eq "png") {
        $args += @("--scale", $Scale)
    }

    try {
        & mmdc @args 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-OK "$baseName.$Format"
            $pass++
        } else {
            throw "mmdc exit code $LASTEXITCODE"
        }
    } catch {
        Write-Err "Failed: $($file.Name) — $_"
        $fail++
    }
}

Write-Log ""
Write-Log "Done: $pass rendered, $fail failed"
if ($fail -gt 0) { exit 1 }
