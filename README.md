   ![Azure icon](https://imagine.microsoft.com/Content/Images/favicon.ico)           ![teradici icon](http://img.informer.com/icons/png/128/5487/5487453.png)           ![nvidia icon](https://cdn-img.easyicon.net/png/5552/555272.gif)

# Deploy a Windows NV VM.

# **WIP** [Check releases](https://github.com/Azure/azure-accessplatform-windows-gpu/tags)

* [Prereqs](#prereqs)
* [Deploy and Visualize](#deploy-and-visualize)
* [PCoIP with Teradici and NVIDIA GRID Management on Azure for M60 Visualizations](#pcoip-with-teradici-and-nvidia-grid-management-on-azure-for-m60-visualizations)
* [Optional Usage of Operational Management Suite](#optional-usage-of-operational-management-suite)
* [Manual Install of OpendTect for Sanity](#manual-install-of-opendtect-for-sanity)
* [MSFT OSCC](#msft-oscc)
* [Credits](#credits)
* [Reporting Bugs](#reporting-bugs)
* [Patches and pull requests](#patches-and-pull-requests)

#### Prereqs
**Obtain a Trial License Activation Code For the Teradici "Graphics Agent for Windows" from [here](http://connect.teradici.com/cas-trial) to put in the template parameter. If that is not put in, Windows Server would be available over [Personal Session Desktop for RDS using RDP 10](https://blogs.technet.microsoft.com/hybridcloudbp/2016/11/15/new-rds-capabilities-in-windows-server-2016-for-service-providers/)**

**Please download PCoIP Software Clients 1.11 (Beta) for Windows from
  [here](https://techsupport.teradici.com/link/portal/15134/15164/Download/2852) to access over PCoIP**
* NVIDIA GRID 4.2 (369.95) with [NVIDIA GRID 4.2 latest Driver (Defaulted)](https://tdcm16sg112leo8193ls102.blob.core.windows.net/tdcm16sg112leo8193ls102/369.95_grid_win10_server2016_64bit_international.exe) and working.
* NVIDIA GRID 4.1 (369.71) with [Azure NVIDIA GRID Driver (non-defaulted)](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-n-series-driver-setup) and working
* All software installers and sample data are in D:\ and system installers like Teradici, Azure NVIDIA GRID Driver installers are in D:\DownloadInstallers

* Latest  [Teradici Cloud Access Software 2.8.0 (Beta) Agent- Graphics Edition for Windows](https://techsupport.teradici.com/link/portal/15134/15164/Download/2870). Includes the latest client PCoIP Software Clients 1.11 (Beta)
for Windows.

* [Manual Install of OpendTect for Sanity](#manual-install-of-opendtect-for-sanity)

* nView needs to be enabled manually. [User Guide](http://www.nvidia.com/content/quadro/pdf/nView-user-guide.pdf)

#### Deploy and Visualize
<a href="https://preview.portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-accessplatform-windows-gpu%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-accessplatform-windows-gpu%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Tip: Map you local drive only when using Remote Desktop Client (not PCoIP) to transfer files to your virtual machine. Find more information [here](https://technet.microsoft.com/en-us/library/cc770631(v=ws.11).aspx)

#### PCoIP with Teradici and NVIDIA GRID Management on Azure for M60 Visualizations

* For GRID server interfaces for GPU management, please view [the grid software management sdk user guide](https://tdcm16sg112leo8193ls102.blob.core.windows.net/tdcm16sg112leo8193ls102/367.43-369.17-grid-software-management-sdk-user-guide.pdf)
* nView needs to be enabled manually. [User Guide](http://www.nvidia.com/content/quadro/pdf/nView-user-guide.pdf)
* Collection of the user dumps for the NVIDIA Display Driver 369.95 or 369.71  from within the VM on Display Driver Crash if occurs.
 * Details are [here](http://nvidia.custhelp.com/app/answers/detail/a_id/3335/~/tdr-(timeout-detection-and-recovery)-and-collecting-dump-files) 
* PCoIP Graphics Agent for Windows Log Collection from the Teradici System Tray (right click Teradici Icon on System Tray) and collect Agent Logs (from the support tab).
* The PCoIP Client Logs  [v1.11 ~Beta]((https://techsupport.teradici.com/link/portal/15134/15164/Download/2852)) from the Office Client machine of the end-user from <code>C:\Users\user_name\AppData\Local\Teradici\PCoIPClient\logs</code>

#### Optional Usage of Operational Management Suite
**OMS Setup (for mostly Security, compliance and backup in this case) is optional and the OMS Workspace Id and OMS Workspace Key can either be kept blank or populated post the steps below.**

[Create a free account for MS Azure Operational Management Suite with workspaceName](https://login.mms.microsoft.com/signin.aspx?signUp=on&ref=ms_mms)

* Provide a Name for the OMS Workspace.
* Link your Subscription to the OMS Portal.
* Depending upon the region, a Resource Group would be created in the Sunscription like "mms-weu" for "West Europe" and the named OMS Workspace with portal details etc. would be created in the Resource Group.
* login to https://<<OMSWorkspaceName>>.portal.mms.microsoft.com 
* Add The solutions "Agent Health", "Backup", "Security & Compliance", "Activity Log Analytics" and "Protection & Recovery" Solutions from the "Solutions Gallery" of the OMS Portal of the workspace.
* Logon to the OMS Workspace and Go to -> Settings -> "Connected Sources"  -> "Windows Servers" -> Obtain the Workspace ID like <code>ba1e3f33-648d-40a1-9c70-3d8920834669</code> and the "Primary and/or Secondary Key" like <code>xkifyDr2s4L964a/Skq58ItA/M1aMnmumxmgdYliYcC2IPHBPphJgmPQrKsukSXGWtbrgkV2j1nHmU0j8I8vVQ==</code>
* While Deploying the Template just the WorkspaceID and the Key are to be mentioned and all will be registered. **The Windows Agent is already available in the VM once WorkspaceID and Key are put in during Template deployment**.

![OMS Container](https://docs.microsoft.com/en-us/azure/log-analytics/media/log-analytics-windows-agents/oms-direct-agent-connected-sources.png)

* Then one can login to https://<<OMSWorkspaceName>>.portal.mms.microsoft.com  and monitor VM and use Log Analytics and if Required perform automated backups using the corresponding Solutions for OMS.
 * Or if the OMS Workspace and the Machines are in the same subscription, one can just connect the VM sources manually to the OMS Workspace as Data Sources.

####  Manual Install of OpendTect for Sanity
* On using default options of the template, **OpendTect Installer 6.0.5 would be available in D:\DownloadInstallers** folder of the NV
* On using default options of the template, **D:\opendtect empty folder would be available as OpendTect Installation location for manual install**.
 * D: Drive of the NV is a NVMe SSD over PCIe interface and hence usage of the drive is preferred for software.
* Post-installation of ALL features of OpendTect Pro and successfully in D:\OpendTect, **ONLY** zip file survey option should be chosen via OpendTect startup and **the zip file for Netherlands North F3 Data should be downloaded directly from VM browser from [here](https://tdcm16sg112leo8193ls102.blob.core.windows.net/tdcm16sg112leo8193ls102/opendTect/F3_Demo_2016_training_v6.zip). It should be downloaded manually from browser in the NV prior to OpendTect manual installation.**

#### MSFT OSCC
This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

#### Credits
* The NVIDIA GRID 4.1 (369.71) with "Azure" Driver silent install works with certificate force trust - Thanks to [Mathieu Rietman](https://github.com/MathieuRietman)'s [commit on fork for the -f option](https://github.com/MathieuRietman/azure-accessplatform-windows-gpu/commit/a6bc42bc6936a75200f4d968d31ae0de00fe4e97).

* The NVFBC stop start with time lag aka [Driver Kick snippet](https://github.com/Azure/azure-accessplatform-windows-gpu/blob/7584b0b962c2e0d21501685589e05240d2ee2448/CustomScripts/nVIDIAdTeradiciLeostreamAgents.ps1#L161-L181) uses [the snippet](https://github.com/teradici/azure-accessplatform-windows-gpu/blob/74df452f8f3275e62b991a39b67000af7aaecf15/CustomScripts/nVIDIAdTeradiciLeostreamAgents.ps1#L138-L159) as per [specific commit in Teradici Branch on fork of master](https://github.com/teradici/azure-accessplatform-windows-gpu/commit/74df452f8f3275e62b991a39b67000af7aaecf15) by [Peter Longhurst](https://github.com/peterlonghurst).

* Dynamic Disk Selection with take function is as per the [Azure quickstart template](https://github.com/Azure/azure-quickstart-templates/tree/master/201-vm-dynamic-data-disks-selection)

#### Reporting bugs

Please report bugs  by opening an issue in the [GitHub Issue Tracker](https://github.com/Azure/azure-accessplatform-windows-gpu/issues)

#### Patches and pull requests

Patches can be submitted as GitHub pull requests. If using GitHub please make sure your branch applies to the current master as a 'fast forward' merge (i.e. without creating a merge commit). Use the `git rebase` command to update your branch to the current master if necessary.
