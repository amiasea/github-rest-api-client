[CmdletBinding()]
param(
    [string] $SourceRepository = $env:OPENAPI_SOURCE_REPOSITORY,
    [string] $SourceRef = $env:OPENAPI_SOURCE_REF,
    [string] $SourcePath = 'descriptions/api.github.com/api.github.com.yaml',
    [string] $OutputDirectory = 'openapi-3.0',
    [string] $ExpectedOpenApiVersion = '3.0'
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($SourceRepository)) {
    throw 'SourceRepository is required (e.g. github/rest-api-description).'
}
if ([string]::IsNullOrWhiteSpace($SourceRef) -or
    $SourceRef -notmatch '^[0-9a-fA-F]{40}$') {
    throw 'SourceRef must be a full 40-character commit SHA.'
}

$SourceRepository = $SourceRepository.Trim()
$SourceRef = $SourceRef.Trim().ToLowerInvariant()

$sourceUrl = "https://raw.githubusercontent.com/$SourceRepository/$SourceRef/$SourcePath"
$commitUrl = "https://github.com/$SourceRepository/commit/$SourceRef"

# Resolve paths relative to the current working directory.
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
$sourceFile = Join-Path $OutputDirectory 'source.yaml'
$lockFile = Join-Path $OutputDirectory 'source.lock.json'

# Confirm the immutable revision exists and matches the requested SHA.
$commitApiUrl = "https://api.github.com/repos/$SourceRepository/commits/$SourceRef"
$commit = Invoke-RestMethod -Uri $commitApiUrl -Headers @{
    'Accept' = 'application/vnd.github+json'
    'User-Agent' = 'Amiasea-GitHub-ApiClient'
}

if ($commit.sha -ne $SourceRef) {
    throw "Commit SHA mismatch. Requested $SourceRef, received $($commit.sha)."
}

# Download the exact source from the pinned commit.
$response = Invoke-WebRequest -Uri $sourceUrl
$yamlText = $response.Content

if ([string]::IsNullOrWhiteSpace($yamlText)) {
    throw 'Downloaded OpenAPI source is empty.'
}

# Parse YAML using the PowerShell-yaml module if available.
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    throw 'Install the pinned powershell-yaml module before running this script.'
}
Import-Module powershell-yaml

$document = ConvertFrom-Yaml -Yaml $yamlText

if ($document.openapi -notmatch "^$([regex]::Escape($ExpectedOpenApiVersion))\.\d+$") {
    throw "Expected OpenAPI $ExpectedOpenApiVersion.x; found '$($document.openapi)'."
}
if ([string]::IsNullOrWhiteSpace($document.info.title)) {
    throw 'OpenAPI info.title is missing.'
}

# Calculate a checksum over the exact downloaded bytes.
$tempFile = [System.IO.Path]::GetTempFileName()
try {
    [System.IO.File]::WriteAllText(
        $tempFile,
        $yamlText,
        [System.Text.UTF8Encoding]::new($false)
    )
    $sha256 = (Get-FileHash -Path $tempFile -Algorithm SHA256).Hash.ToLowerInvariant()
}
finally {
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

# Write the upstream document as UTF-8 without a BOM.
[System.IO.File]::WriteAllText(
    $sourceFile,
    $yamlText,
    [System.Text.UTF8Encoding]::new($false)
)

$lock = [ordered]@{
    schemaVersion = 1
    sourceRepository = $SourceRepository
    sourceRef = $SourceRef
    sourcePath = $SourcePath
    sourceUrl = $sourceUrl
    commitUrl = $commitUrl
    commitDate = $commit.commit.committer.date
    openApiVersion = $document.openapi
    title = $document.info.title
    apiDescriptionVersion = $document.info.version
    sha256 = $sha256
}

$lock |
    ConvertTo-Json -Depth 10 |
    Set-Content -Path $lockFile -Encoding utf8

Write-Host "Source:   $sourceFile"
Write-Host "Lock:     $lockFile"
Write-Host "OpenAPI:  $($document.openapi)"
Write-Host "Title:    $($document.info.title)"
Write-Host "SHA-256:  $sha256"
