# Group Policy: Drive and Printer Mapping by Department

## Build
1. On DC01 create a share: `New-Item C:\Shares\Finance -ItemType Directory; New-SmbShare -Name Finance -Path C:\Shares\Finance -FullAccess "LAB\Domain Admins" -ChangeAccess "LAB\GG-Finance"`
2. Create a security group `GG-Finance` in OU=Finance and add the Finance users:
   `New-ADGroup GG-Finance -GroupScope Global -Path "OU=Finance,OU=Company,DC=lab,DC=local"`
   `Get-ADUser -SearchBase "OU=Finance,OU=Company,DC=lab,DC=local" -Filter * | ForEach-Object { Add-ADGroupMember GG-Finance -Members $_ }`
3. Group Policy Management > OU=Finance > **Create a GPO and link it here** > `GPO-Finance-Drives`.
4. Edit > User Configuration > Preferences > Windows Settings > **Drive Maps** > New > Mapped Drive:
   - Action: Update | Location: `\\DC01\Finance` | Drive letter: `F:`
   - Common tab > **Item-level targeting** > Security Group = `LAB\GG-Finance`
5. Printer: User Configuration > Preferences > Control Panel Settings > **Printers** > New > Shared Printer, path `\\DC01\<printer>`.

## Test on CLIENT01 (signed in as a Finance user)
```cmd
gpupdate /force
gpresult /r
gpresult /h C:\Temp\gpresult.html
net use
```
Save `gpresult.html` into `sample-output/` (remove anything sensitive first).

## Drive missing: troubleshooting
| Check | Command | Expect |
|---|---|---|
| Policy applied? | `gpresult /r` | `GPO-Finance-Drives` under Applied GPOs |
| In the right group? | `whoami /groups` | `LAB\GG-Finance` |
| Group membership new? | Sign out and in | Group tokens refresh at sign-in |
| Share reachable? | `Test-NetConnection DC01 -Port 445` | `TcpTestSucceeded: True` |
| Existing letter in use? | `net use` | `F:` not taken by another mapping |
