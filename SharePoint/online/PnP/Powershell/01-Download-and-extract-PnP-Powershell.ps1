<#
Created:      10.12.2016
Created by:   Tom Solem (at) gmail.com
Description:  Download all PnP Powershell modules from web and extract the content of each msi file in 
              different folders. the scripts creates a Download folder and saves all msi files in sub 
              folders. Then it will create a extraction folder for getting the content foreach msi file. 
              The last step is to copy the files to the Resource\PnP\ folder. Each module will have 
              it's own folder under Resources\PnP. you can then use this in development of modules to SharePoint.
#>

$0 = $myInvocation.MyCommand.Definition
$CommandDirectory = [System.IO.Path]::GetDirectoryName($0)
Write-Host "Current dir: $($CommandDirectory)" -ForegroundColor Magenta

$PnPModules = @()
$PnPModules += "SharePointPnPPowerShellOnline"
$PnPModules += "SharePointPnPPowerShell2016"
$PnPModules += "SharePointPnPPowerShell2013"

$Version = "2.10.1612.0" # December 2016, update to the version you would like to download
$uriPrefix = "https://github.com/SharePoint/PnP-PowerShell/releases/download"


foreach($PnPModule in $PnPModules){
    Write-Host "Starts to download $($PnPModule), version $($Version)" -ForegroundColor Magenta
    $uri = "$($uriPrefix)/$($Version)/$($PnPModule).msi"
    Write-Host "Uri to download from: $($uri)" -ForegroundColor Magenta
    $output = Join-Path $CommandDirectory "Download\$($PnPModule)"
    $exist = $false
    $exist = Test-Path $output
    if($exist -eq $false){
        # if there are no folder named download\<module name> it will create the module
        New-Item -ItemType Directory -Path $output 
    }
    Push-Location $output
    Write-Host "Starts to download $($Version) version of PnP powershell" -ForegroundColor Magenta
    Invoke-WebRequest -Uri $uri -OutFile "$output\$($PnPModule).msi"
    Pop-Location
    Write-Host "Download completed" -ForegroundColor Magenta
    $msiFiles = Get-ChildItem -Path $output -Filter "*.msi"

    foreach($msi in $msiFiles){
        Write-Host "Extrating files from $($msi.Name)" -ForegroundColor Magenta
        $fullName = $msi.FullName
        $folderName = $msi.Name.Replace(".msi","")
        $targetFolder = Join-Path $CommandDirectory $folderName        
        $msiArgumentList = "/a $($fullName) /qn TARGETDIR=$($targetFolder)"
        Start-Process msiexec -ArgumentList $msiArgumentList -Wait

        $moduleFile = Get-ChildItem -Path $targetFolder -Recurse -Filter "$($folderName).psd1"
        $moduleFolder = $moduleFile.FullName.Replace("\$($folderName).psd1","")
    
        $items = Get-ChildItem -Path $moduleFolder
        $resourceFolderPath = Join-Path $CommandDirectory "Resources\PnP"
        $moduleFolderPath = Join-Path $resourceFolderPath $folderName
        $exist = $false
        $exist = Test-Path $moduleFolderPath
        if($exist -eq $false){
           # Creates a folder named Resources\PnP\<module name>
           New-Item -ItemType Directory -Path $moduleFolderPath 
        }
        # copy all files to the Resource\PnP<module name> folder
        Copy-Item -Path "$($moduleFolder)\*" -Destination $moduleFolderPath -Force 
    }
    
}






