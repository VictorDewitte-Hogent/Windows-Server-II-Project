# Script Host 

######################

# IP address obtained from DHCP

#####################



# deze lijn op dc uitvoeren
New-ADComputer -Name "Exchange" -AccountPassword (ConvertTo-SecureString -String 'Temp' -AsPlainText -Force)




$joinCred = New-Object pscredential -ArgumentList ([pscustomobject]@{
    UserName = $null
    Password = (ConvertTo-SecureString -String 'Temp' -AsPlainText -Force)[0]
})
Add-Computer -Domain "ws2-2223-Victor.hogent" -Options UnsecuredJoin,PasswordPass -Credential $joinCred -Restart -Force

