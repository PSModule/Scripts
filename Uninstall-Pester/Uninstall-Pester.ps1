#Requires -RunAsAdministrator

<#PSScriptInfo

.VERSION 0.1.0

.GUID b3e951d5-146a-43d1-a4f6-f69c72672c71

.AUTHOR Marius Storhaug

.COMPANYNAME

.COPYRIGHT

.TAGS Pester

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#>
[CmdletBinding()]
param (
    # Completely remove all built-in Pester 3 installations
    [Parameter()]
    [switch] $All
)

$pesterPaths = foreach ($programFiles in ($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
    $path = "$programFiles\WindowsPowerShell\Modules\Pester"
    if ($null -ne $programFiles -and (Test-Path $path)) {
        if ($All) {
            Get-Item $path
        } else {
            Get-ChildItem "$path\3.*"
        }
    }
}

if (-not $pesterPaths) {
    "There are no Pester$(if (-not $all) {' 3'}) installations in Program Files and Program Files (x86) doing nothing."
    return
}

foreach ($pesterPath in $pesterPaths) {
    takeown /F $pesterPath /A /R
    icacls $pesterPath /reset
    # grant permissions to Administrators group, but use SID to do
    # it because it is localized on non-us installations of Windows
    icacls $pesterPath /grant '*S-1-5-32-544:F' /inheritance:d /T
    Remove-Item -Path $pesterPath -Recurse -Force -Confirm:$false
}
