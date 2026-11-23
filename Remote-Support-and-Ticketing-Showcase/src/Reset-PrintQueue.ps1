<#
.SYNOPSIS
    Clears stuck print jobs by restarting the Print Spooler on a remote computer.
.EXAMPLE
    .\Reset-PrintQueue.ps1 -ComputerName CLIENT01
#>
[CmdletBinding(SupportsShouldProcess)]
param([string]$ComputerName = "CLIENT01")

if (-not $PSCmdlet.ShouldProcess($ComputerName, "Restart spooler and clear queue")) { return }

Invoke-Command -ComputerName $ComputerName -ErrorAction Stop -ScriptBlock {
    $jobsBefore = (Get-ChildItem "$env:windir\System32\spool\PRINTERS" -File -ErrorAction SilentlyContinue).Count
    Stop-Service Spooler -Force
    Remove-Item "$env:windir\System32\spool\PRINTERS\*" -Force -ErrorAction SilentlyContinue
    Start-Service Spooler
    [PSCustomObject]@{
        Computer      = $env:COMPUTERNAME
        JobsCleared   = $jobsBefore
        SpoolerStatus = (Get-Service Spooler).Status
    }
} | Select-Object Computer, JobsCleared, SpoolerStatus
