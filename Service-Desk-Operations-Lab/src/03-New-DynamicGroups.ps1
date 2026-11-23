<#
.SYNOPSIS
    Creates Entra ID dynamic security groups per department.
.DESCRIPTION
    Users join DYN-<Department> automatically based on their department attribute.
    Assign licences to these groups in the Entra admin centre for group-based licensing.
    Requires Entra ID P1 (included in the Microsoft 365 developer tenant and Business Premium).
.EXAMPLE
    .\03-New-DynamicGroups.ps1
#>
[CmdletBinding()]
param(
    [string[]]$Departments = @("Finance", "Sales", "IT")
)

Import-Module Microsoft.Graph.Groups -ErrorAction Stop
Connect-MgGraph -Scopes "Group.ReadWrite.All" -NoWelcome

foreach ($dept in $Departments) {
    $name = "DYN-$dept"
    $existing = Get-MgGroup -Filter "displayName eq '$name'" -ErrorAction SilentlyContinue
    if ($existing) { Write-Host "Exists: $name"; continue }

    $params = @{
        DisplayName                   = $name
        Description                   = "All users in the $dept department"
        MailEnabled                   = $false
        MailNickname                  = "dyn$($dept.ToLower())"
        SecurityEnabled               = $true
        GroupTypes                    = @("DynamicMembership")
        MembershipRule                = "(user.department -eq `"$dept`")"
        MembershipRuleProcessingState = "On"
    }
    New-MgGroup -BodyParameter $params | Select-Object DisplayName, Id, MembershipRule
}

Write-Host "`nNext: Entra admin centre > Groups > DYN-<dept> > Licenses > assign the Microsoft 365 licence."
