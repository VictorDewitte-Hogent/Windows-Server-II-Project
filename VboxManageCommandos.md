# Vbox manage Commando's/ Scripts

VRAGEN OFDA EM EEN PATH EEFT WAAR IE DE ISO's Zal ZETTN


## Create a new VM

    VBoxManage createvm --name "{VM Name}" --ostype "Windows2019" --register

## Create a new HDD
    
    VBoxManage createhd --filename "E:\VM's\Windows Server II\DC\DC.vdi" --size 10000

## Attach HDD to VM
    
    VBoxManage storagectl "VM Name" --name "SATA Controller" --add sata --controller IntelAhci
    VBoxManage storageattach "VM Name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "C:\Users\user\VirtualBox VMs\VM Name\{VM Name}.vdi"

## Attach ISO to VM
        
    VBoxManage storagectl "VM Name" --name "IDE Controller" --add ide
    VBoxManage storageattach "VM Name" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "C:\Users\user\Downloads\{ISO Name}.iso"

## Modify VM
        
    VBoxManage modifyvm "VM Name" --memory {2048} --vram {128} --cpus {2} --nic1 nat --audio none --boot1 dvd --boot2 disk --boot3 none --boot4 none 
    (NIC1 NAT, NIC2 Bridged, NIC3 Host-only, NIC4 Internal) --groups "/Windows Server II"  --hostonlyadapter1 "VirtualBox Host-Only Ethernet Adapter#{}"
    --intnet1 "intnet"

## Start VM
    
    VBoxManage startvm "VM Name" --type headless

## Stop VM
        
    VBoxManage controlvm "VM Name" poweroff

## Delete VMq
    
    VBoxManage unregistervm "VM Name" --delete

## Unnatend instal Virtual box (Opzoeken heo da werkt)

    VBoxManage unattended install "VM Name" --iso="C:\Users\user\Downloads\{ISO Name}.iso" --user="user" --password="password" --full-user-name="user" --country="BE" --locale="nl_BE" --time-zone="Europe/Brussels" --start-vm=gui
    

--image-index=number
Windows installation image index. (default: 1)

--post-install-template=file
The post installation script template. (default: IMachine::OSTypeId dependent)