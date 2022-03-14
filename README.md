# steamcmd_powershellv2


Created in Windows Server 2022 and PowerShell 5.1. This program may or not may work in previous or next versions of Windows Server and PowerShell.
Script requires admin permission account, otherwise will refuse to launch.

Install instructions:

Open Powershell window with user that got admin permissions and paste following command:

New-Item -ItemType Directory -Force -Path 'C:\steamcmd'; Invoke-WebRequest -Uri 'https://github.com/xbit0412/steamcmd_powershellv2/releases/download/steamcmd_powershellv2/steamcmd_powershell.ps1' -OutFile 'C:\steamcmd\steamcmd_powershell.ps1'; Set-Location 'C:\steamcmd'; .\steamcmd_powershell.ps1

Done! 

First of all execute option 1 to install first steamcmd

You can stop script with CTRL+C and execute again with this command: Set-Location 'C:\steamcmd'; .\steamcmd_powershell.ps1
