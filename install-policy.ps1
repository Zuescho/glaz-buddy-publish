# install-policy.ps1 - install GLAZ-Buddy for the current Windows user through Edge's
# ExtensionInstallForcelist policy (HKCU). No admin rights and no GPO needed.
#
#   pwsh tools\install-policy.ps1              # add / update the entry
#   pwsh tools\install-policy.ps1 -Uninstall   # remove it again
#
# Restart Edge afterwards, then open edge://policy and press "Reload policies". Edge downloads the
# signed CRX from the update URL and keeps it up to date on its own. A machine-wide policy (GPO or
# HKLM) takes precedence over this per-user entry.
#
# Remove an unpacked copy of the same extension in edge://extensions first - the extension ID can only
# be installed once.

param(
    [switch]$Uninstall,
    [string]$ExtensionId = 'ijhbmofnkgedjfknliopndpofmeddonp',
    [string]$UpdateUrl = 'https://raw.githubusercontent.com/Zuescho/glaz-buddy-publish/main/updates.xml'
)

$ErrorActionPreference = 'Stop'
$key = 'HKCU:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist'
$value = "$ExtensionId;$UpdateUrl"

if ($Uninstall) {
    if (-not (Test-Path $key)) { Write-Host 'No policy set for the current user.'; exit 0 }
    $removed = $false
    foreach ($name in @((Get-Item $key).Property)) {
        if ((Get-ItemPropertyValue -Path $key -Name $name) -like "$ExtensionId;*") {
            Remove-ItemProperty -Path $key -Name $name
            $removed = $true
        }
    }
    if ($removed) { Write-Host "Removed $ExtensionId from $key. Restart Edge." }
    else { Write-Host "No entry for $ExtensionId found. Nothing to do." }
    exit 0
}

# Create the key path one segment at a time: New-Item -Force on an existing registry key recreates it
# and drops every value (other extensions' force-install entries), so it must only run on missing keys.
$path = 'HKCU:'
foreach ($part in 'SOFTWARE', 'Policies', 'Microsoft', 'Edge', 'ExtensionInstallForcelist') {
    $path = Join-Path $path $part
    if (-not (Test-Path $path)) { New-Item -Path $path | Out-Null }
}
$numbers = @((Get-Item $key).Property | Where-Object { $_ -match '^\d+$' })
$target = $numbers | Where-Object { (Get-ItemPropertyValue -Path $key -Name $_) -like "$ExtensionId;*" } |
    Select-Object -First 1
if (-not $target) {
    $target = 1
    while ($numbers -contains "$target") { $target++ }
}
New-ItemProperty -Path $key -Name "$target" -Value $value -PropertyType String -Force | Out-Null

Write-Host "Wrote '$target' = '$value'"
Write-Host 'Next: restart Edge, open edge://policy, press "Reload policies". GLAZ-Buddy installs itself.'
