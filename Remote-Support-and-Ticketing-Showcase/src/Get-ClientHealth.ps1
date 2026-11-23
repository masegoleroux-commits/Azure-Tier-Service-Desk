<#
.SYNOPSIS
    First-look health check on a remote client.
.EXAMPLE
    .\Get-ClientHealth.ps1 -ComputerName CLIENT01
#>
[CmdletBinding()]
param([string]$ComputerName = "CLIENT01")

$result = Invoke-Command -ComputerName $ComputerName -ErrorAction Stop -ScriptBlock {
    $os   = Get-CimInstance Win32_OperatingSystem
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    [PSCustomObject]@{
        Computer       = $env:COMPUTERNAME
        OS             = $os.Caption
        UptimeHours    = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours, 1)
        FreeDiskGB     = [math]::Round($disk.FreeSpace / 1GB, 1)
        FreeDiskPct    = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 0)
        FreeMemoryMB   = [math]::Round($os.FreePhysicalMemory / 1KB)
        StoppedAutoSvc = (Get-Service | Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' }).Name -join ", "
        LoggedOnUser   = (Get-CimInstance Win32_ComputerSystem).UserName
        RecentErrors   = (Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 2; StartTime = (Get-Date).AddDays(-1) } -MaxEvents 5 -ErrorAction SilentlyContinue |
                          ForEach-Object { "$($_.TimeCreated.ToString('HH:mm')) $($_.ProviderName): $($_.Id)" }) -join " | "
    }
}

$result | Select-Object * -ExcludeProperty PSComputerName, RunspaceId | Format-List

$flags = @()
if ($result.FreeDiskPct -lt 10)  { $flags += "Low disk space: run Clear-DiskSpace.ps1" }
if ($result.UptimeHours -gt 168) { $flags += "Not restarted in over 7 days: ask the user to restart" }
if ($result.StoppedAutoSvc)      { $flags += "Automatic services stopped: $($result.StoppedAutoSvc)" }
if ($flags) { Write-Host "Flags:" -ForegroundColor Yellow; $flags | ForEach-Object { Write-Host " - $_" -ForegroundColor Yellow } }
