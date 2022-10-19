<powershell>
Install-WindowsFeature -name Web-Server -IncludeManagementTools
New-Item -Path C:\inetpub\wwwroot\index.html -ItemType File -Value "<html><h1>Hello From Your Windows Web Server!</h1></html>" -Force
</powershell>
