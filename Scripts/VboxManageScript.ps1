#$env:PATH = $env:PATH + ";C:\Program Files\Oracle\VirtualBox"


### HIER AANPASSEN  #####
# Zet hier het pad naar u Windows Server 2019 ISO
[String]$PathISO="C:\Users\Victor\OneDrive - Hogeschool Gent\Bureaublad\WinServer\en_windows_server_2019_x64_dvd_4cb967d8.iso"
# Zet hier het pad naar u Windows 10
[String]$PathISO2="C:\Users\Victor\OneDrive - Hogeschool Gent\Bureaublad\WinServer\SW_DVD9_Win_Pro_10_20H2.10_64BIT_English_Pro_Ent_EDU_N_MLF_X22-76585.ISO"

# Zet hier het pad naar waar u de VM wilt opslaan
[string]$path1 = "E:\VM's\"

# Zet hier het pad naar waar u de Shared Folder heeft opgeslagen
[String]$sharedFolder = "E:\SharedFolder"             

#############################


#- Management server met gui, 2 cores, 4gb ram.
#- DC server zonder gui, 2 cores, 4gb ram.
#- sql server zonder gui, Windows security only, 1 core 4gb ram , min 6gb hard disk
#- Exchange zonder gui, Imap voor ms mail , 4 cores, 10gb ram, min 30+gb hard disk
#- IIS server zonder gui, 1 core, 2gb ram. security appart.


 function Create-all-VM
 {

    Create-Vm -Name "DC" -Mem 4096 -Cpu 2 -Hdd 25000 -Gui $false
    Create-Vm -Name "SQL" -Mem 4096 -Cpu 1 -Hdd 8000 -Gui $false
    Create-Vm -Name "Exchange" -Mem 10240 -Cpu 4 -Hdd 30000 -Gui $false
    Create-Vm -Name "IIS" -Mem 2048 -Cpu 1 -Hdd 8000 -Gui $false
    create-Vm -Name "Management" -Mem 4096 -Cpu 2 -Hdd 80000 -Gui $true
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
        VBoxManage createvm --name "$Name"--ostype "$ostype"  --basefolder "$path1" --groups $Group --register

        VBoxManage createhd --filename "$path1$Group\$Name\$Name.vdi" --size $Hdd
        VBoxManage storagectl $Name --name "SATA Controller" --add sata --controller IntelAhci
        VBoxManage storageattach $Name --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$path1$Group\$Name\$Name.vdi"

        VBoxManage sharedfolder add $Name --name shr --hostpath $sharedFolder --automount
   
        if($name -match "DC"){
            VBoxManage modifyvm $Name --memory $Mem --vram 128 --cpus $Cpu --nic1 nat --nic2 intnet --audio none --boot1 disk --boot2 dvd --boot3 none --boot4 none }
        else{
            VBoxManage modifyvm $Name --memory $Mem --vram 128 --cpus $Cpu --nic1 intnet --audio none --boot1 disk --boot2 dvd --boot3 none --boot4 none }
        }
       

        
    catch [NativeCommandError]
        { }

}

function Install-DC1 {
    VBoxManage unattended install "DC" --iso "$PathISO" --user "Administrator" --password "P@ssw0rd" --full-user-name "Administrator"  --locale "nl_BE" --time-zone "Europe/Brussels" --install-additions  --image-index=2 --start-vm 
}
function Install-SQL {
    VBoxManage unattended install "SQL" --iso "$PathISO" --user "Administrator" --password "P@ssw0rd" --full-user-name "Administrator"  --locale "nl_BE" --time-zone "Europe/Brussels" --install-additions --image-index=1 --start-vm -headless
}
function Install-Exchange {
    VBoxManage unattended install "Exchange" --iso "$PathISO" --user "Administrator" --password "P@ssw0rd" --full-user-name "Administrator"  --locale "nl_BE" --time-zone "Europe/Brussels" --install-additions --image-index=1 --start-vm -headless   
}
function Install-IIS {
    VBoxManage unattended install "IIS" --iso "$PathISO" --user "Administrator" --password "P@ssw0rd" --full-user-name "Administrator"  --locale "nl_BE" --time-zone "Europe/Brussels" --install-additions --image-index=1 --start-vm -headless
}
function install-Management {
    VBoxManage unattended install "Management" --iso "$PathISO" --user "Administrator" --password "P@ssw0rd" --full-user-name "Administrator"  --locale "nl_BE" --time-zone "Europe/Brussels" --install-additions --image-index=1 --start-vm -headless
}
function install-Host {
    VBoxManage unattended install "Host" --iso "$PathISO2" --user "Administrator" --password "P@ssw0rd" --full-user-name "Administrator"  --locale "nl_BE" --time-zone "Europe/Brussels" --install-additions --image-index=1 --start-vm -headless
}

function Show-Menu
{
    param (
        [string]$Title = 'Windows Server II Project Victor Dewitte'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: De nodige VM's aanmaken en configureren"
    Write-Host "2: Installeren van DC"
    Write-Host "3: Installeren van 2e"
    write-host "4: Installeren van 3e"
    Write-Host "5: Installeren van 4e"
    Write-Host "6: Installeren van 5e"
    Write-Host "Q: Press 'Q' to quit."




    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
        '1' {
            'You chose option #1'
            Create-all-VM 
            Show-Menu
        } '2' {
            'You chose option #2'
            Install-DC1
            Show-Menu
        } '3' {
            'You chose option #3'
            Show-Menu
        } '4' {
            'You chose option #4'
            Show-Menu
        } '5' {
            'You chose option #5'
            Show-Menu
        } '6' {
            'You chose option #6'
            Show-Menu
        
        
        } 'q' {
            return
        }
    }
 }

 Show-Menu