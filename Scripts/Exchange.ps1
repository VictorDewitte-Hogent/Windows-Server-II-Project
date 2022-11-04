

#maken dak ingelogd ben als schema admin


Mount-DiskImage -ImagePath "C:\Exchange\mul_exchange_server_2019_cumulative_update_12_x64_dvd_52bf3153.iso"
$Drive = Get-Volume -FileSystemLabel "exchange*" 
$DriveLetter = $Drive.DriveLetter
Set-Location  -Path "$($DriveLetter):\"


.\setup.exe /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /PrepareSchama

.\setup.exe /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /PrepareAD

.\setup.exe /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /PrepareAllDomains 

.\setup.exe /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /mode:Install /Role:Mailbox /InstallWindowsComponents