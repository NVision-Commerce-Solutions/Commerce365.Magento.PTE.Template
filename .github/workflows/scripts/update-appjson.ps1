param (
    [Parameter(Mandatory = $true)]
    [string]$ClientName
)

$appJsonPath = "app.json"

if (!(Test-Path $appJsonPath)) {
    Write-Error "app.json not found."
    exit 1
}

Write-Host "Loading app.json..."

$appJson = Get-Content $appJsonPath -Raw | ConvertFrom-Json

# Prevent running twice
if ($appJson.name -notmatch "\[Client Name\]") {
    Write-Host "Already initialized. Skipping."
    exit 0
}

# Generate lowercase GUID
$newGuid = [guid]::NewGuid().ToString().ToLower()

Write-Host "Generated GUID: $newGuid"

# Update id
$appJson.id = $newGuid

# Replace client name
$appJson.name = $appJson.name.Replace("[Client Name]", $ClientName)

# Save JSON
$appJson |
    ConvertTo-Json -Depth 100 |
    Set-Content $appJsonPath -Encoding UTF8

Write-Host "app.json updated successfully."