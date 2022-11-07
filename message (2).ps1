#=======================================================================================#
#========== Script om virtuele machines te maken aan de hand van een csv file ==========#
#=======================================================================================#

#========== Variabelen ==========#
$Vms = @()
import-csv -Path "C:\Users\victo\OneDrive\Toegepaste informatica\3de jaar toegepaste informatica\Windows server II\newvms.csv" -Delimiter ";" | ForEach-Object { 
[pscustomobject]$Obj = @{
        name = [string]$_.ComputerName
        ostype = [string]$_.Ostype
        memory = [int]$_.Memory
        cpus =  [int]$_.Cpus
        vram = [int]$_.Vram
        nic1 = [string]$_.Nic1
        nic2 = [string]$_.Nic2
        filename = [string]$_.Filename
        size = [int]$_.Size
        index = [int]$_.Index
        iso = [string]$_.ISO
        scripts = [string]$_.Scripts
        main = [String]$_.Main
        }
$Vms += $Obj
}
[string]$usrName = "Administrator"
[string]$passwd = "21Admin22"
[string]$remoteCompDir= "C:\"
[string]$additionsISO= "$($remoteCompDir)Program Files\Oracle\VirtualBox\VBoxGuestAdditions.iso"
[string]$locale = "en_US"
[string]$country = "BE"
[string]$language = "en-us"
[string]$timezone = "Romance Standard Time"
[string]$postCmnd = "powershell E:\vboxadditions\VBoxWindowsAdditions.exe /S ; timeout 20 ; shutdown /r" 
[string]$logFile = "C:\Users\victo\OneDrive\Toegepaste informatica\3de jaar toegepaste informatica\Windows server II\serversLog.txt"
[string]$gpoScript = "C:\ScriptsDc\scripts\DCConfiguratiePart5.ps1"


#========== Functies ==========#
function logMsg($msg)
{
    $msg | Out-File $logFile -Append 
    Write-Host $msg -ForegroundColor Green
}
function Show-Menu {
    param (
        [string]$Title = "Vboxmange Menu"
    )
    Clear-Host
    Write-Host "================ $Title ================" -ForegroundColor Green 
    
    Write-Host "1: Druk op '1' Om de virtuele machines te maken " -ForegroundColor Cyan 
    Write-Host "2: Druk op '2' Om de virtuele machines te stoppen" -ForegroundColor Cyan 
    Write-Host "3: Druk op '3' Om de virutele machines te verwijderen" -ForegroundColor Cyan 
    Write-Host "Q: Druk op 'Q' Om het menu te verlaten" -ForegroundColor Cyan 
}

do
 {
    Show-Menu
    $selection = $(Write-Host "================ Maak een keuze ================`n" -ForegroundColor Green -NoNewLine; Read-Host) 
    switch ($selection)
    {
    '1' {
    logMsg("Je koos voor optie 1")

    foreach ($vm in $Vms){

        #========== Maken van de virtuele machine ==========#
        logMsg("========== Maken van de $($vm.name) virtuele machine ==========") 
        VBoxManage createvm --name $vm.name --ostype $vm.ostype --register | Out-File $logFile -Append 
        VBoxManage modifyvm $vm.name --memory $vm.memory --cpus $vm.cpus --nic1 $vm.nic1  --nic2 $vm.nic2 --clipboard bidirectional --draganddrop bidirectional --vram $vm.vram | Out-File $logFile -Append 
        #========== Toevoegen van de virtuele media ==========#
        logMsg("========== Toevoegen van de virtuele media ==========") 
        VBoxManage createmedium disk --filename $vm.filename  --size $vm.size --format VDI --variant Standard | Out-File $logFile -Append  
        VBoxManage storagectl $vm.name --name "SATA Controller" --add sata --controller IntelAhci --bootable on | Out-File $logFile -Append
        VBoxManage storageattach $vm.name --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $vm.filename | Out-File $logFile -Append 
        VBoxManage storageattach $vm.name --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium $vm.iso | Out-File $logFile -Append
        VBoxManage storageattach $vm.name --storagectl "SATA Controller" --port 2 --device 0 --type dvddrive --medium $additionsISO | Out-File $logFile -Append 
        VBoxManage modifyvm $vm.name --boot1 disk --boot2 dvd --boot3 none --boot4 none | Out-File $logFile -Append

        
        #========== Configureren van de unattended installatie ==========#
        logMsg("========== Configureren van de unattended installatie ==========") 
        VBoxManage unattended install $vm.name --iso="$($vm.iso)" --user=$usrName --password=$passwd --locale=$locale --country=$country --time-zone=$timezone --image-index $vm.index --language=$language --install-additions --additions-iso=$additionsISO --post-install-command=$postCmnd | Out-File $logFile -Append 
        
        #========== Starten van de virtuele machine ==========#
        logMsg("========== Starten van de $($vm.name) virtuele machine ==========")
        VBoxManage startvm $vm.name | Out-File $logFile -Append 
        Write-Host "========== Wacht tot de machine volledig is opgestart ========== `n" -ForegroundColor Green -NoNewLine; Read-Host
        if ($vm.name -eq "EX-VIC" )
        {
            Write-Host "========== Start het GPO script op de domeincontroller ========== `n" -ForegroundColor Green -NoNewLine; Read-Host
            VBoxManage guestcontrol "DC-VIC" run --username $usrName --password $passwd --exe "C:\\windows\\system32\\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe /C $gpoScript
            VBoxManage guestcontrol "DC-VIC" run --username $usrName --password $passwd --exe "C:\\windows\\system32\\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe /C $gpoScript
        }
    
        #========== Installatie van de scripts ==========#
        logMsg("========== Installatie van de scripts ==========")
        vboxmanage guestcontrol $vm.name copyto $vm.scripts $remoteCompDir --username $usrName --password $passwd
        VBoxManage guestcontrol $vm.name run --username $usrName --password $passwd --exe "C:\\windows\\system32\\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe /C set-executionpolicy remotesigned
        VBoxManage guestcontrol $vm.name run --username $usrName --password $passwd --exe "C:\\windows\\system32\\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe /C $($vm.main)
        }

    } '2' {
        logMsg("Je koos voor optie 2")

#========== Stoppen van de virtuele machines ==========#
foreach ($vm in $Vms)
{   
    logMsg("========== Stoppen van $($vm.name) ==========")
    VBoxManage controlvm $vm.name poweroff | Out-File $logFile -Append  
}

    } '3' {
        logMsg("Je koos voor optie 3")

    
#========== Verwijderen van de virtuele machines ==========#
foreach($vm in $vms)
{
    logMsg("========== Verwijderen van $($vm.name) ==========")
    VBoxManage unregistervm --delete $vm.name | Out-File $logFile -Append
}

    }
    }
 }
 until ($selection -eq 'q')