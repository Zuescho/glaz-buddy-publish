# uninstall-policy.ps1 - remove GLAZ-Buddy's per-user Edge policy entry again.
#
#   irm https://raw.githubusercontent.com/Zuescho/glaz-buddy/main/tools/uninstall-policy.ps1 | iex
#   pwsh tools\uninstall-policy.ps1
#
# Restart Edge afterwards. Other extensions' entries in the same policy key are left untouched.

$ErrorActionPreference = 'Stop'
$ExtensionId = 'ijhbmofnkgedjfknliopndpofmeddonp'
$key = 'HKCU:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist'

if (-not (Test-Path $key)) { Write-Host 'No policy set for the current user.'; exit 0 }
$removed = $false
foreach ($name in @((Get-Item $key).Property)) {
    if ((Get-ItemPropertyValue -Path $key -Name $name) -like "$ExtensionId;*") {
        Remove-ItemProperty -Path $key -Name $name
        $removed = $true
    }
}
if ($removed) { Write-Host "Removed $ExtensionId. Restart Edge." }
else { Write-Host "No entry for $ExtensionId found. Nothing to do." }
