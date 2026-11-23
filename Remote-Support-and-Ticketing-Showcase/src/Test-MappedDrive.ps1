<#
.SYNOPSIS
    Checks why a mapped drive is missing for the signed-in user.
.DESCRIPTION
    Run on the client in the user's session.
.EXAMPLE
    .\Test-MappedDrive.ps1 -DriveLetter F -SharePath \\DC01\Finance -GroupName GG-Finance
#>
[CmdletBinding()]
param(
    [string]$DriveLetter = "F",
    [string]$SharePath   = "\\DC01\Finance",
    [string]$GroupName   = "GG-Finance"
)

$server  = ($SharePath -split "\\")[2]
$groups  = whoami /groups /fo csv | ConvertFrom-Csv | Select-Object -ExpandProperty "Group Name"
$applied = (gpresult /r /scope:user) -join "`n"

[PSCustomObject]@{
    DriveMapped     = [bool](Get-PSDrive -Name $DriveLetter -ErrorAction SilentlyContinue)
    InGroup         = [bool]($groups -match [regex]::Escape($GroupName))
    GpoListed       = $applied -match "Drives"
    ServerReachable = (Test-NetConnection $server -Port 445 -WarningAction SilentlyContinue).TcpTestSucceeded
    ShareReachable  = Test-Path $SharePath
} | Format-List

Write-Host "If InGroup is False: add the user to $GroupName, then sign out and back in."
Write-Host "If GpoListed is False: run gpupdate /force, then sign out and back in."
