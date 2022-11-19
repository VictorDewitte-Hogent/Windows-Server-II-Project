Write-Host @"
#######################################
##              PART 4/4             ##
##        Creating SMB shares        ##
##           Creating OU's           ##
##         Importing users           ##
##       Importing workstations      ##
##         Enforcing policies        ##
#######################################
"@
Start-Sleep 3

# create profiles smb share
New-Item -Path "C:\" -Name "UserProfiles" -ItemType "directory"
New-SmbShare -Name "UserProfiles" -Path "C:\UserProfiles" -ChangeAccess "Users" -FullAccess "Administrators"

#create homedir smb share
New-Item -Path "C:\" -Name "HomeFolder" -ItemType "directory"
New-SmbShare -Name "HomeFolder" -Path "C:\HomeFolder" -ChangeAccess "Users" -FullAccess "Administrators"

# Create 5 OU's
$OUnames = @('IT Administratie', 'Verkoop', 'Administratie', 'Ontwikkeling', 'Directie')
foreach ($OUname in $OUnames){
    New-ADOrganizationalUnit -Name "$($OUname)" -Path "DC=thematrix,DC=local"
    Write-Host "✅ OU $OUname werd aangemaakt!"
}

# Import users from CSV file
# Get CSV files from github
Invoke-WebRequest https://pastebin.com/raw/Gc034buf -OutFile "C:\$env:HOMEPATH\Documents\users.csv"
Invoke-WebRequest https://pastebin.com/raw/ApUziMLz -OutFile "C:\$env:HOMEPATH\Documents\workstations.csv"

$users = Import-Csv -Path "C:\Users\Administrator\Documents\users.csv" -Delimiter ";"
foreach($user in $users){
    $username = $user.username
    $first = $user.First
    $last = $user.Last
    $path = $user.Path
    $userPrincipalName = $username + "@ws2-2223-victor.hogent"
    $profilepath = "\\dc\UserProfiles\%username%"
    $homepath = "\\dc\HomeFolder\$username"
    New-Item -Path "C:\HomeFolder" -Name $username -ItemType "directory"
    New-ADUser -Name "$first $last" -GivenName $first -Surname $last -SamAccountName $username -DisplayName $username -UserPrincipalName $userPrincipalName -ProfilePath $profilepath -HomeDirectory $homepath -HomeDrive H: -Path $path -Accountpassword (ConvertTo-SecureString "Letmein123" -AsPlainText -Force) -Enabled $true
    Write-Host "✅ User $first $last werd aangemaakt!"
}

# Import workstation from CSV file
$workstations = Import-Csv -Path "C:\Users\Administrator\Documents\workstations.csv" -Delimiter ";"
foreach($workstation in $workstations){
   $workstationName= $workstation.name
   $path = $workstation.path
   New-ADComputer -Name "$workstationName" -Path $path
   Write-Host "✅ Workstation $workstationName werd aangemaakt!"
}

# Administrator verplaatsen naar IT Administratie
Get-ADUser -Identity Administrator | Move-ADObject -TargetPath "OU=IT ADMINISTRATIE,DC=THEMATRIX,DC=LOCAL"

# Enforce Policies
# Disable Link naar Games voor alle gebruikers
Set-GPRegistryValue -name "Default Domain Policy" -key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoStartMenuMyGames" -Type DWord -Value 1

#Voor iedereen behalve de IT administratie Control Panel disablen
New-GPO -Name "ITAdministratie_GPO" -Comment "Group Policy IT Administratie" | New-GPLink -Target "OU=IT Administratie,DC=thematrix,DC=local"
Set-GPRegistryValue -name "Default Domain Policy" -key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1
Set-GPRegistryValue -name "ITAdministratie_GPO" -key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 0

#Alleen Verkoop en Administratie mogen de eigenschappen van een netwerkadapter openen
New-GPO -Name "Verkoop_GPO" -Comment "Group Policy Verkoop" | New-GPLink -Target "OU=Verkoop,DC=thematrix,DC=local"
New-GPO -Name "Administratie_GPO" -Comment "Group Policy Administratie" | New-GPLink -Target "OU=Administratie,DC=thematrix,DC=local"
Set-GPRegistryValue -name "Default Domain Policy" -key "HKCU\Software\Policies\Microsoft\Windows\Network Connections" -ValueName "NC_LanProperties" -Type DWord -Value 0
Set-GPRegistryValue -name "Verkoop_GPO" -key "HKCU\Software\Policies\Microsoft\Windows\Network Connections" -ValueName "NC_LanProperties" -Type DWord -Value 1
Set-GPRegistryValue -name "Administratie_GPO" -key "HKCU\Software\Policies\Microsoft\Windows\Network Connections" -ValueName "NC_LanProperties" -Type DWord -Value 1

# Remove downloaded CSV files in C:\Documents
Remove-Item -Path "C:\$env:HOMEPATH\Documents\users.csv"
Remove-Item -Path "C:\$env:HOMEPATH\Documents\workstations.csv"

##############################
#          REBOOT            #
##############################
#Windows server herstarten om configuratie op te slaan en door te voeren
shutdown /r -t 0