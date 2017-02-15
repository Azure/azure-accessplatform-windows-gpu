<# Install NVIDIA Drivers, PCOIP Agent and download Leostream Agent/OpendTect #>
<#param (
    [string]$leostreamAgentVer,
    [string]$teradiciAgentVer,
    [string]$nvidiaVer,	
    [string]$storageAcc,
    [string]$conName
)
#>
<#
$dest = "C:\Downloadinstallers"
$leostreamAgentVer = $Args[0]
$teradiciAgentVer = "2.7.0.3589"
$nvidiaVer = "369.71"
$storageAcc = "tdcm16sg112leo8193ls102"
$conName = "tdcm16sg112leo8193ls102"
#>
$dest = "C:\Downloadinstallers\"
$leostreamAgentVer = $args[0]
$teradiciAgentVer = $args[1]
$nvidiaVer = $args[2] #Ignored - latested Azure driver is pulled from Microsoft
$storageAcc = $args[3]
$conName = $args[4]
$license = $args[5]
$registryPath = "HKLM:\Software\Teradici\PCoIP\pcoip_admin"
$Name = "pcoip.max_encode_threads"
$value = "8"
$Date = Get-Date
<#
Write-Host "You inputs are '$leostreamAgentVer' and '$teradiciAgentVer' with '$storageAcc', '$conName', '$license'  on '$Date'"

New-Item -Path $dest -ItemType directory

wget https://go.microsoft.com/fwlink/?linkid=836843 -OutFile C:\Downloadinstallers\NVAzureDriver.zip
wget http://download.opendtect.org/relman/OpendTect_Installer_win64.exe -OutFile C:\Downloadinstallers\OpendTect_Installer_win64.exe
wget https://$storageAcc.blob.core.windows.net/$conName/PCoIP_agent_release_installer_"$teradiciAgentVer"_graphics.exe -OutFile C:\Downloadinstallers\PCoIP_agent_release_installer_"$teradiciAgentVer"_graphics.exe

wget https://$storageAcc.blob.core.windows.net/$conName/LeostreamAgentSetup$leostreamAgentVer.exe -OutFile C:\Downloadinstallers\LeostreamAgentSetup$leostreamAgentVer.exe

New-Item -Path C:\Downloadinstallers\NVAzureDriver\ -ItemType directory
Expand-Archive C:\Downloadinstallers\NVAzureDriver.zip -DestinationPath C:\Downloadinstallers\NVAzureDriver\
Set-Location C:\Downloadinstallers\NVAzureDriver\
.\setup.exe -s
Start-Sleep -s 90
C:\Downloadinstallers\PCoIP_agent_release_installer_"$teradiciAgentVer"_graphics.exe /S
Start-Sleep -s 90
& 'C:\Program Files (x86)\Teradici\PCoIP Agent\bin\RestartAgent.bat'
net stop nvsvc
Start-Sleep -s 90
net start nvsvc
& 'C:\Program Files (x86)\Teradici\PCoIP Agent\licenses\appactutil.exe' appactutil.exe -served -comm soap -commServer https://teradici.flexnetoperations.com/control/trdi/ActivationService -entitlementID $license
#>
New-Item -Path $dest -ItemType directory
$nvidiaMSSite = [System.String]::Format("https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-n-series-driver-setup")
$nvidiaUrl = [System.String]::Format("https://go.microsoft.com/fwlink/?linkid=836843")
$teradiciAgentUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/PCoIP_agent_release_installer_{2}_graphics.exe", $storageAcc, $conName, $teradiciAgentVer)
$leostreamAgentUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/LeostreamAgentSetup{2}.exe", $storageAcc, $conName, $leostreamAgentVer)
$nvidiaZipName = [System.String]::Format("{0}\NVAzureDriver.zip", $dest)
$nvidiaTmpPath = [System.String]::Format("{0}\NVAzureDriver", $dest)
$teradiciExeName = [System.IO.Path]::GetFileName($teradiciAgentUrl)
$leostreamExeName = [System.IO.Path]::GetFileName($leostreamAgentUrl)
$teradiciExePath = [System.String]::Format("{0}{1}", $dest, $teradiciExeName)
$leostreamExePath = [System.String]::Format("{0}{1}", $dest, $leostreamExeName)
Write-Host "The NVIDIA Azure specific driver is from  '$nvidiaMSSite'"
Write-Host "The NVIDIA Driver Zip file Url  is '$nvidiaUrl'"
Write-Host "The Teradici Agent exe  Url  is '$teradiciAgentUrl'"
Write-Host "The Teradici Agent exe name is '$teradiciExeName'"
Write-Host "The Leostream Agent exe Url is '$leostreamAgentUrl'"
Write-Host "The Leostream Agent exe name is '$leostreamExeName'"
Write-Host "The Teradici Agent exe downloaded location is '$teradiciExePath'"
Write-Host "The Leostream Agent exe downloaded location is '$leostreamExePath'"
wget $nvidiaUrl -OutFile $nvidiaZipName
wget $teradiciAgentUrl -OutFile $teradiciExePath
wget $leostreamAgentUrl -OutFile $leostreamExePath
Start-Sleep -s 360
Write-Host "Expanding NVIDIA driver archive '$nvidiaZipName' to '$nvidiaTmpPath'"
New-Item -Path $nvidiaTmpPath -ItemType directory
Expand-Archive $nvidiaZipName -DestinationPath $nvidiaTmpPath
Set-Location $nvidiaTmpPath
Write-Host "Installing NVIDIA Azure specific driver"
.\setup.exe -s -noreboot -clean
Start-Sleep -s 180
& $teradiciExePath /S /NoPostReboot
Start-Sleep -s 90 
Write-Host "teradiciagent install over"
cd 'C:\Program Files (x86)\Teradici\PCoIP Agent\licenses\'
Write-Host "pre-activate"
.\appactutil.exe -served -comm soap -commServer https://teradici.flexnetoperations.com/control/trdi/ActivationService -entitlementID $license
Write-Host "activation over"
if ($teradiciAgentVer -match "2.7.0.4060")
{
IF(!(Test-Path $registryPath))

  {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null}

 ELSE {
     New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null}
  }
else
{ 
  Write-Host  "No Registry entry required ."
}
<# Reboot in 60 seconds #>
C:\WINDOWS\system32\shutdown.exe -r -f -t 60
Write-Host "end script"
<# & 'C:\Program Files (x86)\Teradici\PCoIP Agent\bin\RestartAgent.bat' #>
<# cd 'C:\Program Files (x86)\Teradici\PCoIP Agent\bin'
.\RestartAgent.bat
.\pcoip_arbiter_win32.exe start

Write-Host "teradici arbiter on"
net stop nvsvc
Start-Sleep -s 90
Write-Host "Stopping NVIDIA Display Driver"
net start nvsvc
Write-Host "Starting NVIDIA Display Driver"
#>
