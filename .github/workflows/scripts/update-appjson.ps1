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

# Prevent running twice
if ($appJson.name -notmatch "\[Client Name\]") {
    Write-Host "Already initialized. Skipping app.json update."
}
else {

    # Generate lowercase GUID
    $newGuid = [guid]::NewGuid().ToString().ToLower()

    Write-Host "Generated GUID: $newGuid"

    # Update id
    $appJson.id = $newGuid

    # Replace placeholder
    $appJson.name = $appJson.name.Replace("[Client Name]", $ClientName)

    # Save JSON
    $appJson |
        ConvertTo-Json -Depth 100 |
        Set-Content $appJsonPath -Encoding UTF8

    Write-Host "app.json updated successfully."
}

# ---------------------------------------------------
# Rename workspace file
# ---------------------------------------------------

$templateWorkspace =
    "Commerce365.Magento.PTE.Template.code-workspace"

$newWorkspace =
    "Commerce365.Magento.PTE.$ClientName.code-workspace"

if (Test-Path $templateWorkspace) {

    if (!(Test-Path $newWorkspace)) {

        Write-Host "Renaming workspace file..."

        Rename-Item `
            -Path $templateWorkspace `
            -NewName $newWorkspace

        Write-Host "Workspace renamed to:"
        Write-Host $newWorkspace

    }
    else {

        Write-Host "Workspace file already renamed."

    }

}
else {

    Write-Host "Template workspace file not found — skipping rename."

}