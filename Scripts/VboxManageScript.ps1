$env:PATH = $env:PATH + ";C:\Program Files\Oracle\VirtualBox"


$username = "Administrator"
[String]$password = "P@ssw0rd"

### HIER AANPASSEN  #####
# Zet hier het pad naar u Windows Server 2019 ISO
[String]$PathISO="C:\Users\VictorDewitte\Desktop\WindowsServer2\en_windows_server_2019_x64_dvd_4cb967d8.iso"
# Zet hier het pad naar u Windows 10
[String]$PathISO2="C:\Users\VictorDewitte\Desktop\WindowsServer2\SW_DVD9_Win_Pro_10_20H2.10_64BIT_English_Pro_Ent_EDU_N_MLF_X22-76585.ISO"

# Zet hier het pad naar waar u de VM wilt opslaan
[string]$path1 = "C:\Users\VictorDewitte\VMs\"

# Zet hier het pad naar waar u de Shared Folder heeft opgeslagen
[String]$sharedFolder = "C:\Users\VictorDewitte\Documents\SharedFolder"             
[string]$logs = "C:\Users\VictorDewitte\Desktop\WindowsServer2\logfile.txt"



[string]$scripts = "C:\Users\VictorDewitte\Desktop\WindowsServer2\Windows-Server-II-Project\Scripts\$name.ps1"
#############################


[String]$postCommand= "powershell E:\vboxadditions\VBoxWindowsAdditions.exe /S ; timeout 20 ; shutdown /r"

#- Management server met gui, 2 cores, 4gb ram.
#- DC server zonder gui, 2 cores, 4gb ram.
#- sql server zonder gui, Windows security only, 1 core 4gb ram , min 6gb hard disk
#- Exchange zonder gui, Imap voor ms mail , 4 cores, 10gb ram, min 30+gb hard disk
#- IIS server zonder gui, 1 core, 2gb ram. security appart.


 function Create-all-VM
 {

    Create-Vm -Name "DC" -Mem 4096 -Cpu 2 -Hdd 25000 -Gui $true
    Create-Vm -Name "SQL" -Mem 4096 -Cpu 1 -Hdd 25000 -Gui $false
    Create-Vm -Name "Exchange" -Mem 10240 -Cpu 4 -Hdd 30000 -Gui $false
    Create-Vm -Name "IIS" -Mem 2048 -Cpu 1 -Hdd 8000 -Gui $false
    #create-Vm -Name "Management" -Mem 4096 -Cpu 2 -Hdd 80000 -Gui $true
    Create-Vm -Name "Host" -Mem 4096 -Cpu 2 -Hdd 80000 -Gui $true

 }


function Create-VM
{
    param(
        [string]$Name = 'DC',
        [int]$Mem = 4096,
        [int]$Cpu = 2,
        [int]$Hdd = 25000,
        [bool]$Gui = $false,

        
        [String]$Group = '/VictorDewitteWindowsServerIIProject',
        
        [string]$diskPath = "$path1$Name.vdi"
    )

    try{
        #VBoxManage createvm --name "Test"--ostype "Windows2019"  --basefolder "E:\VM's\Test\" --group TestGroup --register
        if($name -match "Host"){
            $ostype = "Windows10_64"
        }
        else{
            $ostype = "Windows2019_64"
        }
        VBoxManage createvm --name "$Name"--ostype "$ostype"  --basefolder "$path1" --groups $Group --register | out-file $logs -append

        VBoxManage createhd --filename "$path1$Group\$Name\$Name.vdi" --size $Hdd | out-file $logs -append
        VBoxManage storagectl $Name --name "SATA Controller" --add sata --controller IntelAhci | out-file $logs -append
        VBoxManage storageattach $Name --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$path1$Group\$Name\$Name.vdi" | out-file $logs -append

        VBoxManage sharedfolder add $Name --name shr --hostpath $sharedFolder --automount | out-file $logs -append
   
        if($name -match "DC"){
            VBoxManage modifyvm $Name --memory $Mem --vram 128 --cpus $Cpu --nic1 nat --nic2 intnet --audio none --boot1 disk --boot2 dvd --boot3 none --boot4 none | out-file $logs -append }
        else{
            VBoxManage modifyvm $Name --memory $Mem --vram 128 --cpus $Cpu --nic1 intnet --audio none --boot1 disk --boot2 dvd --boot3 none --boot4 none | out-file $logs -append}
        }
       

        
    catch [NativeCommandError]
        { }

}

function Install-DC1 {
    VBoxManage unattended install "DC" --iso "$PathISO" --user "Administrator" --password "P@ssw0rd" --full-user-name "Administrator"  --locale "nl_BE" --time-zone "Europe/Brussels" --install-additions  --image-index=2 --start-vm=gui --post-install-command=$postCommand
    #--post-install-command "powershell -ExecutionPolicy Bypass -File C:\Users\Administrator\Desktop\Scripts\DC1.ps1" 
}
function Install-SQL {
    VBoxManage unattended install "SQL" --iso "$PathISO" --user "Administrator" --password "P@ssw0rd" --full-user-name "Administrator"  --locale "nl_BE" --time-zone "Europe/Brussels" --install-additions --image-index=1 --start-vm=headless --post-install-command=$postCommand
}
function Install-Exchange {
    VBoxManage unattended install "Exchange" --iso "$PathISO" --user "Administrator" --password "P@ssw0rd" --full-user-name "Administrator"  --locale "nl_BE" --time-zone "Europe/Brussels" --install-additions --image-index=1 --start-vm=headless  --post-install-command=$postCommand 
}
function Install-IIS {
    VBoxManage unattended install "IIS" --iso "$PathISO" --user "Administrator" --password "P@ssw0rd" --full-user-name "Administrator"  --locale "nl_BE" --time-zone "Europe/Brussels" --install-additions --image-index=1 --start-vm=headless --post-install-command=$postCommand
}
#function Install-Management {
   # VBoxManage unattended install "Management" --iso "$PathISO" --user "Administrator" --password "P@ssw0rd" --full-user-name "Administrator"  --locale "nl_BE" --time-zone "Europe/Brussels" --install-additions --image-index=2 --start-vm=gui
#}
function Install-Host {
    VBoxManage unattended install "Host" --iso "$PathISO2" --user "Administrator" --password "P@ssw0rd" --full-user-name "Administrator"  --locale "nl_BE" --time-zone "Europe/Brussels" --install-additions --image-index=1 --start-vm=gui --post-install-command=$postCommand
}

########################################

function Scripts {
    param (
        $name,
        [String]$scripts ,
        [String]$CompDir
    )

    vboxmanage guestcontrol $name copyto $scripts $CompDir --username $username --password $password
    VBoxManage guestcontrol $name run --username $username --password $password --exe "C:\\windows\\system32\\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe /C set-executionpolicy remotesigned
    VBoxManage guestcontrol $name run --username $username --password $password --exe "C:\\windows\\system32\\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe /C .\$name.ps1

    
}


function GPO-Scripts {
    param (
        
    )
    VBoxManage guestcontrol "DC" run --username  --password $password --exe "C:\\windows\\system32\\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe /C $gpoScript
    VBoxManage guestcontrol "DC" run --username $username --password $password --exe "C:\\windows\\system32\\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe /C $gpoScript
}


function Show-Menu
{
    param (
        [string]$Title = 'Windows Server II Project Victor Dewitte'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: De nodige VM's aanmaken en configureren"
    Write-Host "2: Windows Installeren op DC"
    Write-Host "3: Windows Installeren op SQL"
    write-host "4: Windows Installeren op Exchange"
    Write-Host "5: Windows Installeren op IIS"
    #Write-Host "6: Installeren van Management"
    Write-Host "6: Windows Installeren op De Host"
    Write-Host "7: Scripts DC uitvoeren"
    Write-Host "8: Scripts SQL uitvoeren"
    Write-Host "9: Scripts Exchange uitvoeren"
    Write-Host "10: Scripts IIS uitvoeren"
    Write-Host "11: Scripts host uitvoeren"
    Write-Host "12: Alle VM's stoppen"
    Write-Host "Q: Press 'Q' to quit."




    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
        '1' {
            '####################

    Alle VMs aanmaken
            
######################'
            Start-Sleep -Seconds 5
            Create-all-VM 
            Show-Menu
        } '2' {
            '####################

    DC Installeren
            
######################'
            Start-Sleep -Seconds 5
            Install-DC1
            #Show-Menu
        } '3' {
            '####################

    SQL Installeren
            
#####################'
            Start-Sleep -Seconds 5
            Install-SQL
            Show-Menu
        } '4' {
            '####################

    Exchange Installeren
            
######################'
            Start-Sleep -Seconds 5
            Install-Exchange
            Show-Menu
        } '5' {
            '####################

    IIS Installeren
            
######################'
            Start-Sleep -Seconds 5
            Install-IIS
            Show-Menu
#        } '6' {
#            '####################

#    Management Installeren
            
######################'
#            Start-Sleep -Seconds 5
#            Install-Management
#            Show-Menu
        } '6' {
            '####################

    Host Installeren
            
######################'
            Start-Sleep -Seconds 5
            Install-Host
            Show-Menu    
        } '7' {
            '####################
    
    Scripts DC uitvoeren

######################'
            Start-Sleep -Seconds 5
            Scripts -name "DC" -scripts "$Scripts" -CompDir "C:\"
            Show-Menu
        } '8' {
            '####################
    
    Scripts SQL uitvoeren

######################'
            Start-Sleep -Seconds 5
            Scripts -name "SQL" -scripts "$Scripts" -CompDir "C:\"
            Show-Menu
        } '9' {
            '####################

    Scripts Exchange uitvoeren

######################'
            Start-Sleep -Seconds 5
            GPO-Scripts 
            Scripts -name "Exchange" -scripts "$Scripts" -CompDir "C:\"
            Show-Menu
        } '10' {
            '####################

    Scripts IIS uitvoeren

######################'
            Start-Sleep -Seconds 5
            Script-IIS
            Show-Menu
        } '11' {
            '####################

    Scripts Host uitvoeren

######################'
            Start-Sleep -Seconds 5
            Scripts -name "Host" -scripts "$Scripts" -CompDir "C:\"
           
        } '12' {
            '####################
    
    Alle VMs stoppen

######################'
            Start-Sleep -Seconds 5
            Stop-VM -Name "DC" -TurnOff
            Stop-VM -Name "SQL" -TurnOff
            Stop-VM -Name "Exchange" -TurnOff
            Stop-VM -Name "IIS" -TurnOff
            #Stop-VM -Name "Management" -TurnOff
            Stop-VM -Name "Host" -TurnOff
            Show-Menu
            VBoxManage controlvm $name poweroff | Out-File $logFile -Append  
        
        
        } 'q' {
            return
        }
    }
}

Show-Menu


#netsh interface ip set address "Ethernet" static 192.168.22.3 255.255.255.0 192.168.22.1