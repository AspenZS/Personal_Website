$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$requiredFiles = @(
  'index.html',
  'styles.css',
  'script.js',
  'favicon.svg',
  'social-card.svg',
  'manifest.webmanifest',
  '404.html',
  'robots.txt',
  'sitemap.xml'
)

foreach ($relativePath in $requiredFiles) {
  $fullPath = Join-Path $repositoryRoot $relativePath
  if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
    throw "Missing required file: $relativePath"
  }
}

$indexPath = Join-Path $repositoryRoot 'index.html'
$index = Get-Content -Raw -LiteralPath $indexPath
$allTextFiles = Get-ChildItem -LiteralPath $repositoryRoot -Recurse -File |
  Where-Object {
    $_.FullName -notmatch '[\\/]\.git[\\/]' -and
    $_.Extension -in @('.html', '.css', '.js', '.md', '.svg', '.xml', '.txt', '.webmanifest', '.ps1')
  }

$requiredFragments = @(
  'https://aspenzs.github.io/Personal_Website/',
  'https://github.com/AspenZS',
  'ZEPHYRE SYSTEMS',
  'Aspen // ZS',
  'aria-controls="primary-navigation"',
  'application/ld+json',
  'twitter:card',
  'og:image'
)

foreach ($fragment in $requiredFragments) {
  if (-not $index.Contains($fragment)) {
    throw "Missing required index fragment: $fragment"
  }
}

$oldGitHubOwner = 'jthenderson' + '00'
$legacyBrand = 'Zeph' + 'yr'
$legacyMaker = 'Sa' + 'lem'
$prohibitedPatterns = @(
  [regex]::Escape($oldGitHubOwner),
  "(?<![A-Za-z])$([regex]::Escape($legacyBrand))(?![A-Za-z])",
  "(?<![A-Za-z])$([regex]::Escape($legacyMaker))(?![A-Za-z])"
)

foreach ($file in $allTextFiles) {
  $contents = Get-Content -Raw -LiteralPath $file.FullName
  foreach ($pattern in $prohibitedPatterns) {
    if ([regex]::IsMatch($contents, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
      throw "Prohibited legacy identity pattern '$pattern' found in $($file.FullName)"
    }
  }
}

$idMatches = [regex]::Matches($index, '\bid="([^"]+)"')
$knownIds = $idMatches | ForEach-Object { $_.Groups[1].Value }
$duplicateIds = $idMatches |
  ForEach-Object { $_.Groups[1].Value } |
  Group-Object |
  Where-Object Count -gt 1

if ($duplicateIds) {
  throw "Duplicate HTML IDs: $($duplicateIds.Name -join ', ')"
}

$anchorMatches = [regex]::Matches($index, 'href="#([^"]+)"')
foreach ($match in $anchorMatches) {
  $target = $match.Groups[1].Value
  if ($target -notin $knownIds) {
    throw "Broken in-page anchor: #$target"
  }
}

$localAssetMatches = [regex]::Matches($index, '(?:href|src)="\.\/([^"#?]+)"')
foreach ($match in $localAssetMatches) {
  $relativePath = $match.Groups[1].Value
  if (-not (Test-Path -LiteralPath (Join-Path $repositoryRoot $relativePath) -PathType Leaf)) {
    throw "Broken local asset reference: $relativePath"
  }
}

$manifestPath = Join-Path $repositoryRoot 'manifest.webmanifest'
Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json | Out-Null

[xml](Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'sitemap.xml')) | Out-Null
[xml](Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'favicon.svg')) | Out-Null
[xml](Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'social-card.svg')) | Out-Null

Write-Host 'PERSONAL WEBSITE VALIDATION PASSED' -ForegroundColor Green
Write-Host "Validated files: $($requiredFiles.Count)"
Write-Host "Unique HTML IDs: $($idMatches.Count)"
Write-Host "In-page anchors: $($anchorMatches.Count)"
Write-Host "Local asset references: $($localAssetMatches.Count)"
