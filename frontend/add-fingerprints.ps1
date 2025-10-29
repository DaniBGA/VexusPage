<#
add-fingerprints.ps1

Simple PowerShell helper to fingerprint JS/CSS files under frontend/Static
and update HTML files under frontend/ and frontend/pages/ to reference the
fingerprinted filenames. This is a minimal approach to enable long caching
for static assets while ensuring clients fetch new versions after deploy.

Usage (from repo root):
  pwsh ./frontend/add-fingerprints.ps1 -Version "20251029"

It will:
 - compute SHA256 for each .js/.css in frontend/Static
 - copy each file to a new file with .{hash8}.ext (e.g. main.ab12cd34.js)
 - update all .html files under frontend/ to point to the new names

Notes:
 - The original files are left in place so old references (if any) still work.
 - Run this as part of your deploy pipeline and use the fingerprinted names in
  your deployed HTML (this script updates them automatically).
#>

param(
    [string]$Version = (Get-Date -Format yyyyMMddHHmmss)
)

Write-Host "Starting fingerprinting (version: $Version)"

Set-Location -Path $PSScriptRoot

$staticDirs = @(
    "Static/js",
    "Static/css"
)

# Collect files to fingerprint
$filesToFingerprint = @()
foreach ($d in $staticDirs) {
    $full = Join-Path $PSScriptRoot $d
    if (Test-Path $full) {
        $filesToFingerprint += Get-ChildItem -Path $full -Recurse -File -Include *.js,*.css
    }
}

if ($filesToFingerprint.Count -eq 0) {
    Write-Host "No JS/CSS files found to fingerprint. Exiting." -ForegroundColor Yellow
    exit 0
}

$mapping = @{}

foreach ($f in $filesToFingerprint) {
    $hashObj = Get-FileHash -Algorithm SHA256 -Path $f.FullName
    $hash = $hashObj.Hash.Substring(0,8).ToLower()
    $newName = "{0}.{1}{2}" -f $f.BaseName, $hash, $f.Extension
    $newPath = Join-Path $f.DirectoryName $newName

    if (-not (Test-Path $newPath)) {
        Copy-Item -Path $f.FullName -Destination $newPath -Force
        Write-Host "Created: $($f.Name) -> $newName"
    } else {
        Write-Host "Fingerprint already exists for $($f.Name): $newName"
    }

    # store mapping using path relative to /Static root
    $rel = $f.FullName.Replace($PSScriptRoot, '').Replace('\','/').TrimStart('/')
    $relNew = $newPath.Replace($PSScriptRoot, '').Replace('\','/').TrimStart('/')
    $mapping["/$rel"] = "/$relNew"
}

# Update all HTML files under frontend/ with new references
$htmlFiles = Get-ChildItem -Path $PSScriptRoot -Recurse -File -Include *.html

foreach ($html in $htmlFiles) {
    $content = Get-Content -Raw -Path $html.FullName -Encoding UTF8
    $original = $content
    foreach ($k in $mapping.Keys) {
        $v = $mapping[$k]
        # Replace absolute paths (/Static/...) and relative variants (../Static/)
        $content = $content -replace [regex]::Escape($k), $v
        # also try relative forms where appropriate
        $relKey = $k -replace '^/','../'
        $content = $content -replace [regex]::Escape($relKey), $v
    }

    if ($content -ne $original) {
        Set-Content -Path $html.FullName -Value $content -Encoding UTF8
        Write-Host "Updated HTML: $($html.FullName)"
    }
}

Write-Host "Fingerprinting complete. ${($mapping.Keys).Count} files processed." -ForegroundColor Green
