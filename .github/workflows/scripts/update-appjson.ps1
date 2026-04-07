param (
    [Parameter(Mandatory = $true)]
    [string]$ClientName
)

$appJsonPath = "App/app.json"

if (!(Test-Path $appJsonPath)) {
    Write-Error "app.json not found at $appJsonPath"
    exit 1
}

Write-Host "Loading app.json..."
$appJson = Get-Content $appJsonPath -Raw | ConvertFrom-Json

# Prevent double initialization
if ($appJson.name -notmatch "\[Client Name\]") {
    Write-Host "App.json already initialized. Skipping."
}
else {
    # Generate lowercase GUID
    $newGuid = [guid]::NewGuid().ToString().ToLower()
    Write-Host "Generated GUID: $newGuid"

    $appJson.id = $newGuid
    $appJson.name = $appJson.name.Replace("[Client Name]", $ClientName)

    # Save updated app.json
    $appJson | ConvertTo-Json -Depth 100 | Set-Content $appJsonPath -Encoding UTF8
    Write-Host "app.json updated successfully."
}

# -------------------------------
# Rename workspace file
# -------------------------------
$templateWorkspace = "Commerce365.Magento.PTE.Template.code-workspace"

# Make filesystem-safe client name
$SafeClientName = $ClientName -replace '[^a-zA-Z0-9\-]', ''

$newWorkspace = "Commerce365.Magento.PTE.$SafeClientName.code-workspace"

if (Test-Path $templateWorkspace) {
    if (!(Test-Path $newWorkspace)) {
        Rename-Item -Path $templateWorkspace -NewName $newWorkspace
        Write-Host "Workspace renamed to: $newWorkspace"
    }
    else {
        Write-Host "Workspace file already renamed."
    }
}
else {
    Write-Host "Template workspace file not found — skipping rename."
}

# -------------------------------
# Create marker file to prevent re-run
# -------------------------------
$markerFile = ".repo-initialized"

if (!(Test-Path $markerFile)) {
    Write-Host "Creating marker file to prevent re-run..."
    New-Item -Path $markerFile -ItemType File -Force | Out-Null
}