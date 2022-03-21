<# Force the script to be allowed to run as admin group user only for security purposes #>
#Requires -RunAsAdministrator

<# Doing some prerequisites  #>
<# Create new group for script created users #>
New-LocalGroup -Name 'script_limited_users'
<# Set less restrictive policy for passwords #>
secedit /export /cfg c:\secpol.cfg
(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
rm -force c:\secpol.cfg -confirm:$false
<# Force gpedit update #>
gpupdate /force
<#######################################################>

<# Loop to keep script open in Powershell #>
while ($true) {

<# Clean PowerShell #>
Clear-Host

<# Banner #>
Write-Host '################################################################################################' 
Write-Host '# steamcmd_powershell v2                                                                       #'          
Write-Host '# by xbit                                                                                      #'                         
Write-Host '# https://github.com/xbit0412                                                                  #'       
Write-Host '# https://www.xbitnetspace.com                                                                 #'
Write-Host '# If you find useful this script please donate at:                                             #'
Write-Host '# https://www.paypal.com/donate/?hosted_button_id=8DNVY4365H9Y4                                #'
Write-Host '################################################################################################'

<# Ask user for option value, set the value in variable to use #>
[int]$option = Read-Host '
Available options
-----------------

steamcmd options
----------------
1- Install steamcmd
2- Update steamcmd
3- Delete steamcmd

Game server options
-------------------
4- Create game server account 
5- List game server account 
6- Delete game server account 

Windows Firewall options
------------------------
7- Open Windows Firewall port
8- Delete Windows Firewall port
9- List Windows Firewall rules


Other
-----
10- Open PowerShell as other user in other window
11- Run Windows Update from Powershell
12- Reboot Windows
13- Shutdown Windows

Enter number and press enter'

switch ( $option )
{
    1 {
        <# Execution if option 1: Install steamcmd #>
        <# Clean PowerShell #>
        Clear-Host
        <# Create steamcmd installation directoy#>
        New-Item -ItemType Directory -Force -Path 'C:steamcmd\steamcmd'
        <# Download latest version of steamcmd, set location of steamcmd #>
        Invoke-WebRequest -Uri 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip' -OutFile 'C:steamcmd\steamcmd\steamcmd.zip'
        Expand-Archive 'C:steamcmd\steamcmd\steamcmd.zip' -DestinationPath 'C:\steamcmd\steamcmd'
        <# Remove downloaded zip for cleanup, we don't need it anymore #>
        Remove-Item -Path 'C:\steamcmd\steamcmd\steamcmd.zip'
        <# Start steamcmd for first time to download and install required files #>
        Start-Process -FilePath 'C:\steamcmd\steamcmd\steamcmd.exe' '+exit'
    }

    2 {
        <# Execution if option 2: Update steamcmd #>
        <# Clean PowerShell #>
        Clear-Host
        <# Relaunch steamcmd which check by itself for new versions #>
        Start-Process -FilePath 'C:steamcmd\steamcmd\steamcmd.exe' '+exit'
    }

    3 {
        <# Execution if option 3: Delete steamcmd #>
        <# Clean PowerShell #>
        Clear-Host
        Remove-Item -Path 'C:\steamcmd\steamcmd' -Force -Recurse
    }

    4 {
        <# Execution if option 4: Create account game server #>
        <# Clean PowerShell #>
        Clear-Host
        <# Show current system users created by script#>
        Write-Host 'Current users'
        <# Show current system users created by script#>
        Get-LocalUser | Where-Object Description -eq 'script' | Select Name, Enabled | Out-String
        [string]$newuser = Read-Host 'Enter new account name without spaces, for example: my_game_server'
        <# Add new user#>
        New-LocalUser -Name $newuser -Description "script" -Verbose
        <# Add the new user to previously group #>
        Add-LocalGroupMember -Group 'script_limited_users' -Member $newuser
        Read-Host 'Login first time with created user to correctly create user profile. Press enter to continue'
        <# Login for first time to Windows create user profile #>
        Start-Process powershell.exe -Credential $newuser -ArgumentList 'exit'
        <# Create in user profile directory 2 files: update_server.bat and empty server_startup.bat #>
        <# Take first variables #>
        [int]$gameid = Read-Host 'Insert game ID, to find game server AppID search here https://developer.valvesoftware.com/wiki/Dedicated_Servers_List#Windows_Dedicated_Servers'
        [string]$steamcmduserlogin = Read-Host -Prompt 'If steam user login is required for game server enter here, otherwise write anonymous [userlogin/anonymous][anonymous by default]'
        if ([string]::IsNullOrWhiteSpace($steamcmduserlogin)) {
            $steamcmduserlogin = 'anonymous'
        }
        <# Create update_server.bat file #>
        New-Item -ItemType File -Path C:\users\$newuser\update_server.bat
        <# Add directory for server install #>
        New-Item -ItemType Directory C:\users\$newuser\$newuser
        <# Add empty startup script, user must edit this file later to start the game server #>
        New-Item -ItemType File -Path C:\users\$newuser\$newuser\server_startup.bat
        <# Add empty steam_appid file #>
        New-Item -ItemType File -Path C:\users\$newuser\$newuser\steam_appid.txt
        <# Add steam_appid.txt file with server ID insider #>
        $gameid >> C:\users\$newuser\$newuser\steam_appid.txt
        <# Insert script required data to install the game server in specified folder for future manual use case #>
        "'C:\steamcmd\steamcmd\steamcmd.exe +login $steamcmduserlogin +force_install_dir C:\users\$newuser\$newuser +app_update $gameid +quit'" >> C:\users\$newuser\update_server.bat
        <# Launch game server install parameters manually for the first time #>
        Start-Process -FilePath "C:\steamcmd\steamcmd\steamcmd.exe" "+force_install_dir C:\users\$newuser\$newuser +login anonymous +app_update $gameid validate +quit"
        <# Wait so user can read info #>
        Read-Host 'Press enter to continue'
    }

    5 {
        <# Execution if option 5 is: list account game server #>
        <# Clean PowerShell #>
        Clear-Host
        <# Show current system users created by script#>
        Get-LocalUser | Where-Object Description -eq 'script' | Out-String
        <# Wait so user can read info #>
        Read-Host 'Press enter to continue'
    }

    6 {
        <# Execution if option 6: Delete game server account #>
        <# Clean PowerShell #>
        Clear-Host
        <# Show current system users created by script#>
        Write-Host 'Current users'
        Get-LocalUser | Where-Object Description -eq 'script' | Select Name, Enabled | Out-String
        <# Ask user to delete #>
        Write-Host 'WARNING: DELETING USER ACCOUNT WILL DELETE ALL USER PROFILE TOO'
        <# Ask user for user #>
        [string]$usertodelete = Read-Host 'Enter the name of the account to delete'
        <# Delete user profile using CIM #>
        Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq $usertodelete } | Remove-CimInstance
        <# Delete user from the system #>
        Remove-LocalUser -Name $usertodelete -Confirm:$false
        <# Wait so user can read info #>
        Read-Host 'Press enter to continue'
    }

    7 {
        <# Execution if option 7: Open Windows Firewall port #>
        <# Clean PowerShell #>
        Clear-Host
        <# Disable all Windows Firewall profiles #>
        Set-NetFirewallProfile -All -Enabled False
        <# Enable Windows Firewall public profile only #>
        Set-NetFirewallProfile -Profile Public -Enabled True
        <# Show user available rules #>
        Write-Host 'Created rules'
        <# Match with variable script created firewall entries #>
        [string]$rule = "allow*"
        Get-NetFirewallRule -DisplayName $rule | ft -Property Name, DisplayName, @{Name='Protocol';Expression={($PSItem | Get-NetFirewallPortFilter).Protocol}}, @{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}}, @{Name='RemotePort';Expression={($PSItem | Get-NetFirewallPortFilter).RemotePort}}, @{Name='RemoteAddress';Expression={($PSItem | Get-NetFirewallAddressFilter).RemoteAddress}}, Enabled, Profile, Direction, Action
        <# Ask user to insert port number #>
        [int]$port = Read-Host 'Port to open'
        <# Ask user to enter protocol #>
        [string]$protocol = Read-Host 'Write protocol [tcp/udp]'
        <# Open a user specified port and protocol #>
        New-NetFirewallRule -DisplayName "allow $port" -Direction inbound -Profile public -Action allow -LocalPort $port -Protocol $protocol
    }

    8 {
        <# Execution if option 8: Delete Windows Firewall port #>
        <# Clean PowerShell #>
        Clear-Host
        <# Disable all Windows Firewall profiles #>
        Set-NetFirewallProfile -All -Enabled False
        <# Enable Windows Firewall public profile only #>
        Set-NetFirewallProfile -Profile Public -Enabled True
        <# Show user available rules #>
        Write-Host 'Created rules'
        <# Match with variable script created firewall entries #>
        [string]$rule = "allow*"
        Get-NetFirewallRule -DisplayName $rule | ft -Property Name, DisplayName, @{Name='Protocol';Expression={($PSItem | Get-NetFirewallPortFilter).Protocol}}, @{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}}, @{Name='RemotePort';Expression={($PSItem | Get-NetFirewallPortFilter).RemotePort}}, @{Name='RemoteAddress';Expression={($PSItem | Get-NetFirewallAddressFilter).RemoteAddress}}, Enabled, Profile, Direction, Action
        <# Ask user to input port of the rule will be deleted #>
        [int]$port = Read-Host 'Port to delete'
        <# Remove rule which match in display name used in variable #>
        Remove-NetFirewallRule -DisplayName "allow $port"
    }

    9 {
        <# Execution if option 9: List Windows Firewall rules #>
        <# Clean PowerShell #>
        Clear-Host
        <# Match with variable script created firewall entries #>
        <# Show user available rules #>
        Write-Host 'Created rules'
        [string]$rule = "allow*"
        Get-NetFirewallRule -DisplayName $rule | ft -Property Name, DisplayName, @{Name='Protocol';Expression={($PSItem | Get-NetFirewallPortFilter).Protocol}}, @{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}}, @{Name='RemotePort';Expression={($PSItem | Get-NetFirewallPortFilter).RemotePort}}, @{Name='RemoteAddress';Expression={($PSItem | Get-NetFirewallAddressFilter).RemoteAddress}}, Enabled, Profile, Direction, Action
        Read-Host 'Press enter to continue'
    }

    10 {
        <# Execution if option 10: Open PowerShell as other user in other window #>
        <# Clean PowerShell #>
        Clear-Host
        <# Start Powershell as other user if good credentials are provided #>
        Start-Process powershell.exe -Verb runAsUser
    }

    11 {
        <# Execution if option 11: Run Windows Update from Powershell #>
        <# Clean PowerShell #>
        Clear-Host
        <# Install Windows Update PowerShell module #>
        Install-Module PSWindowsUpdate -Confirm:$false -Verbose
        <# Update Windows Update updates list #>
        Get-WindowsUpdate -Verbose
        <# Install updates without forcing a reboot #>
        Install-WindowsUpdate -Confirm:$false
    }

    12 {
        <# Execution if option 12: Reboot Windows #>
        <# Reboot Windows #>
        Restart-Computer
    }

    13 {
        <# Execution if option 13: Shutdown Windows #>
        <# Shutdown Windows #>
        Stop-Computer
    }
    
    <# Execution if no valid option is provided #>
    
    default {
    Clear-Host
    Write-Host 'No valid input detected. Nothing to do'
    Read-Host 'Press enter to continue'
    }

}
}
