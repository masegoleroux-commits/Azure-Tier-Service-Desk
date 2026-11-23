<#
.SYNOPSIS
    Creates the lab OU structure on DC01.
.DESCRIPTION
    Creates OU=Company at the domain root with Finance, Sales, IT and Leavers below it.
    Safe to run more than once: existing OUs are skipped.
.EXAMPLE
    .\01-New-LabOUs.ps1
#>
[CmdletBinding()]
param(
    [string[]]$Departments = @("Finance", "Sales", "IT", "Leavers")
)

Import-Module ActiveDirectory -ErrorAction Stop
$domainDN = (Get-ADDomain).DistinguishedName
$rootDN   = "OU=Company,$domainDN"

if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$rootDN'" -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "Company" -Path $domainDN -ProtectedFromAccidentalDeletion $true
    Write-Host "Created OU: Company" -ForegroundColor Green
} else {
    Write-Host "Exists: Company"
}

foreach ($dept in $Departments) {
    $dn = "OU=$dept,$rootDN"
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$dn'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $dept -Path $rootDN -ProtectedFromAccidentalDeletion $true
        Write-Host "Created OU: $dept" -ForegroundColor Green
    } else {
        Write-Host "Exists: $dept"
    }
}

Get-ADOrganizationalUnit -SearchBase $rootDN -Filter * | Select-Object Name, DistinguishedName
