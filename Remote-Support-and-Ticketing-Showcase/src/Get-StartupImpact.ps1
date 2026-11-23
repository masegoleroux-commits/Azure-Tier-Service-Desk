<#
.SYNOPSIS
    Lists startup programs and recent boot times on a remote client.
.EXAMPLE
    .\Get-StartupImpact.ps1 -ComputerName CLIENT01
#>
[CmdletBinding()]
param([string]$ComputerName = "CLIENT01")

Invoke-Command -ComputerName $ComputerName -ErrorAction Stop -ScriptBlock {
    Write-Output "--- Startup programs ---"
    Get-CimInstance Win32_StartupCommand | Select-Object Name, User, Location, Command | Format-Table -AutoSize -Wrap | Out-String

    Write-Output "--- Recent boot durations ---"
    $boots = Get-WinEvent -FilterHashtable @{ LogName = 'Microsoft-Windows-Diagnostics-Performance/Operational'; Id = 100 } -MaxEvents 5 -ErrorAction SilentlyContinue
    if ($boots) {
        $boots | ForEach-Object {
            $xml = [xml]$_.ToXml()
            $ms  = ($xml.Event.EventData.Data | Where-Object Name -eq 'BootTime').'#text'
            [PSCustomObject]@{ Time = $_.TimeCreated; BootSeconds = [math]::Round([int]$ms / 1000, 1) }
        } | Format-Table -AutoSize | Out-String
    } else {
        "No boot performance events found (log may be disabled on this edition)."
    }
}
