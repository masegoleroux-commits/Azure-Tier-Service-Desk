# Lab Setup Guide

Builds the Azure lab used by every project in this repository.

## 1. Accounts

1. Create an Azure free account.
2. Get a Microsoft 365 tenant: the developer sandbox if eligible, otherwise a Microsoft 365 Business Premium trial (Entra ID P1, Exchange Online, Teams, Intune).
3. Use the tenant's admin account for Azure so everything sits in one Entra ID directory.
4. Turn on MFA for the admin account.

## 2. Resource group and network (Azure Cloud Shell, PowerShell)

```powershell
$rg = "rg-lab"; $loc = "southafricanorth"
New-AzResourceGroup -Name $rg -Location $loc

$servers = New-AzVirtualNetworkSubnetConfig -Name "snet-servers" -AddressPrefix "10.0.1.0/24"
$clients = New-AzVirtualNetworkSubnetConfig -Name "snet-clients" -AddressPrefix "10.0.2.0/24"
New-AzVirtualNetwork -Name "lab-vnet" -ResourceGroupName $rg -Location $loc `
    -AddressPrefix "10.0.0.0/16" -Subnet $servers, $clients
```

**Checkpoint:** `Get-AzVirtualNetwork -Name lab-vnet -ResourceGroupName rg-lab` shows both subnets.

## 3. Virtual machines

| Setting | DC01 | CLIENT01 |
|---|---|---|
| Image | Windows Server 2022 Datacenter | Windows Server 2022 Datacenter (Desktop Experience), or Windows 11 if licensed |
| Size | B2ms | B2s |
| Subnet | snet-servers | snet-clients |
| Private IP | Static 10.0.1.4 | Dynamic |
| Inbound access | RDP from your IP only, or Azure Bastion | Same |
| Auto-shutdown | 22:00 | 22:00 |

Store the local admin password in a password manager, never in this repository.

## 4. Domain controller (DC01, PowerShell as administrator)

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "lab.local" -DomainNetbiosName "LAB" -InstallDns -Force
```

Point the virtual network DNS at DC01 (Cloud Shell):

```powershell
$vnet = Get-AzVirtualNetwork -Name "lab-vnet" -ResourceGroupName "rg-lab"
$vnet.DhcpOptions.DnsServers = @("10.0.1.4")
$vnet | Set-AzVirtualNetwork
Restart-AzVM -Name "CLIENT01" -ResourceGroupName "rg-lab"
```

**Checkpoint:** on DC01, `Get-ADDomain` returns `lab.local`.

## 5. Join CLIENT01

```powershell
Resolve-DnsName lab.local      # expect 10.0.1.4
Add-Computer -DomainName "lab.local" -Credential LAB\<admin> -Restart
```

After restart: `Enable-PSRemoting -Force`

**Checkpoint:** on DC01, `Get-ADComputer CLIENT01` returns the computer and `Test-WSMan CLIENT01` responds.

## 6. Tools on DC01

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module ExchangeOnlineManagement -Scope CurrentUser
winget install Python.Python.3.12
winget install Git.Git
winget install Microsoft.VisualStudioCode
```

## 7. Azure AI resources

| Resource | Tier | Project |
|---|---|---|
| Azure AI Language (with storage account) | Free F0 | Smart Ticket Triage |
| Azure AI Translator | Free F0 | Smart Ticket Triage |
| Azure AI Speech | Free F0 | AI Service Desk Assistant |
| Azure OpenAI (gpt-4o-mini deployment) | Pay per use | AI Service Desk Assistant |

Keys go in local `.env` files only. `.gitignore` already excludes them.

## 8. Cost controls

1. Cost Management budget with alerts at $20, $50 and $100.
2. Auto-shutdown on both VMs.
3. Stop (deallocate) VMs from the portal when finished for the day.
4. Snapshot both OS disks at the end of the tier: `tier1-complete`.

## 9. Common problems

| Symptom | Likely cause | Fix |
|---|---|---|
| CLIENT01 can't find `lab.local` | VNet DNS not set, or VM not restarted | Set DNS to 10.0.1.4, restart CLIENT01 |
| Graph cmdlets return "Insufficient privileges" | Consent not granted | Reconnect with the right `-Scopes` and accept as admin |
| Dynamic groups can't be created | No Entra ID P1 | Use the developer tenant or Business Premium trial |
| Classifier won't train | Too few labelled examples | At least 10 per category |

## 10. Teardown

```powershell
Remove-AzResourceGroup -Name "rg-lab" -Force
```

Also delete leftover snapshots and any AI resources in other resource groups.
