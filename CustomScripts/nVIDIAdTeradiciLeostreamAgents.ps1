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
$nvidiaVer = $args[2]
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
$teradiciAgentUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/PCoIP_agent_release_installer_{2}_graphics.exe", $storageAcc, $conName, $teradiciAgentVer)
$leostreamAgentUrl = [System.String]::Format("https://{0}.blob.core.windows.net/{1}/LeostreamAgentSetup{2}.exe", $storageAcc, $conName, $leostreamAgentVer)
$teradiciExeName = [System.IO.Path]::GetFileName($teradiciAgentUrl)
$leostreamExeName = [System.IO.Path]::GetFileName($leostreamAgentUrl)
$teradiciExePath = [System.String]::Format("{0}{1}", $dest, $teradiciExeName)
$leostreamExePath = [System.String]::Format("{0}{1}", $dest, $leostreamExeName)
Write-Host "The Teradici Agent exe  Url  is '$teradiciAgentUrl'"
Write-Host "The Teradici Agent exe name is '$teradiciExeName'"
Write-Host "The Leostream Agent exe Url is '$leostreamAgentUrl'"
Write-Host "The Leostream Agent exe name is '$leostreamExeName'"
Write-Host "The Teradici Agent exe downloaded location is '$teradiciExePath'"
Write-Host "The Leostream Agent exe downloaded location is '$leostreamExePath'"

<#
    1. Choose Microsoft Url based on requested NVIDIA driver version (currently only version '369.71' is valid)
    2. Download of Azure NVDIA driver from Microsoft Url (BasicParsing to avoid Internet Explorer first-launch configuration problem)
    2. Parse filename out of web response (Regex to find a file ending in '.zip')
    3. Write contents of download to local file
    4. Check that filename contains expected driver version
#>
Write-Host "Downloading Azure specific driver"
$nvidiaMSSite = [System.String]::Format("https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-n-series-driver-setup")
if ($nvidiaVer -match "369.71")
{
    $nvidiaUrl = [System.String]::Format("https://go.microsoft.com/fwlink/?linkid=836843")
}
else
{
    Write-Host "Invalid NVIDIA driver version ($nvidiaVer) requested; using version 369.71"
    $nvidiaVer = "369.71"
    $nvidiaUrl = [System.String]::Format("https://go.microsoft.com/fwlink/?linkid=836843")
}
$nvidiaGetResp = Invoke-WebRequest $nvidiaUrl -UseBasicParsing
$nvidiaFilename = [regex]::match($nvidiaGetResp.BaseResponse.ResponseUri.AbsolutePath, '([^\/]*?\.zip)').Groups[0].Value
$nvidiaZipFile = [System.String]::Format("{0}\{1}", $dest, $nvidiaFilename)
[io.file]::WriteAllBytes($nvidiaZipFile, $nvidiaGetResp.Content)
Write-Host "Downloaded '$nvidiaFilename' from '$nvidiaUrl'"
if ($nvidiaFilename -match $nvidiaVer)
{
    Write-Host "Found expected NVIDIA driver version ($nvidiaVer)"
}

wget $teradiciAgentUrl -OutFile $teradiciExePath
wget $leostreamAgentUrl -OutFile $leostreamExePath
Start-Sleep -s 360

<#
    1. Creation of a directory with similar name to downloaded zip filename
    2. Extraction of zip file into directory
#>
$nvidiaDir = [System.String]::Format("{0}\{1}", $dest,($nvidiaFilename -split "\.zip")[0])
Write-Host "Expanding NVIDIA driver archive '$nvidiaZipFile' to '$nvidiaDir'"
New-Item -Path $nvidiaDir -ItemType directory
Expand-Archive $nvidiaZipFile -DestinationPath $nvidiaDir

Write-Host "Installing NVIDIA Azure specific driver"
Set-Location $nvidiaDir
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

<# NVIDIA driver kicking Only needed for 369.71 driver #>
if ($nvidiaVer -match "369.71")
{
    Write-Host "Driver kick needed for this NVIDIA graphics driver, kicking now..."
    Set-Location "C:\Program Files (x86)\Teradici\PCoIP Agent\GRID"
    
    Write-Host "Stopping NVIDIA Display Driver"
    net stop nvsvc
    Start-Sleep -s 90
    
    Write-Host "Disabling NVFBC capture"
    ./NvFBCEnable -disable
    Start-Sleep -s 90
    
    Write-Host "Enabling NVFBC capture"
    ./NvFBCEnable -enable
    Start-Sleep -s 90
    
    Write-Host "Starting NVIDIA Display Driver"
    net start nvsvc
    Start-Sleep -s 90
}

<# Reboot in 60 seconds #>
C:\WINDOWS\system32\shutdown.exe -r -f -t 60
Write-Host "end script"
