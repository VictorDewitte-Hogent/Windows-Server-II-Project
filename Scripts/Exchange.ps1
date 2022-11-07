

#maken dak ingelogd ben als schema admin

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco install urlrewrite --version 2.1.20190828 -y
choco install vcredist2013 --version 12.0.40660.20180427 -y
choco install vcredist2012 --version 11.0.61031.20220311 -y
choco install dotnetfx --version 4.8.0.20220524 -y


Mount-DiskImage -ImagePath "C:\Exchange\mul_exchange_server_2019_cumulative_update_12_x64_dvd_52bf3153.iso"
$Drive = Get-Volume -FileSystemLabel "exchange*" 
$DriveLetter = $Drive.DriveLetter
Set-Location  -Path "$($DriveLetter):\"


.\setup.exe /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /PrepareSchama

.\setup.exe /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /PrepareAD

.\setup.exe /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /PrepareAllDomains 

.\setup.exe /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF /mode:Install /Role:Mailbox /InstallWindowsComponents