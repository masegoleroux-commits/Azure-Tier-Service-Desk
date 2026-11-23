<#
.SYNOPSIS
    Clears temporary files and the recycle bin on a remote client and reports space freed.
.EXAMPLE
    .\Clear-DiskSpace.ps1 -ComputerName CLIENT01
#>
[CmdletBinding(SupportsShouldProcess)]
param([string]$ComputerName = "CLIENT01")

if (-not $PSCmdlet.ShouldProcess($ComputerName, "Clear temp files and recycle bin")) { return }

Invoke-Command -ComputerName $ComputerName -ErrorAction Stop -ScriptBlock {
    $before = (Get-PSDrive C).Free
    $paths = @("$env:windir\Temp\*") +
             (Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue |
              ForEach-Object { Join-Path $_.FullName "AppData\Local\Temp\*" })
    foreach ($p in $paths) { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }
    Remove-Item "$env:windir\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    Clear-RecycleBin -DriveLetter C -Force -ErrorAction SilentlyContinue
    $after = (Get-PSDrive C).Free
    [PSCustomObject]@{
        Computer   = $env:COMPUTERNAME
        FreedGB    = [math]::Round(($after - $before) / 1GB, 2)
        NowFreeGB  = [math]::Round($after / 1GB, 1)
    }
} | Select-Object Computer, FreedGB, NowFreeGB
