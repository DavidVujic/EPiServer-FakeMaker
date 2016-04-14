#$installPath is the path to the folder where the package is installed
param([string]$installPath)

#	The Update-EPiDataBase and Update-EPiConfig uses by default EPiServerDB connection string name and $package\tools\epiupdates path 
#	to find sql files and transformations file but if it needed to customize the connectionStringname 
#	then a settings.config file can be created (e.g. "settings.config" file under the $package\tools\settings.config).
#	The format of the settings file is like 
#		<settings>
#			<connectionStringName/>
#		</settings>
$setting = "settings.config"
$exportRootPackageName = "EPiUpdatePackage"
$frameworkPackageId = "EPiServer.Framework"
$tools_id = "tools"
$runBatFile = "update.bat"
$updatesPattern = "epiupdates*"
$defaultCommandTimeout = "1800"
$nl = [Environment]::NewLine

#	This CommandLet update DB 
#	It collects all scripts by default under $packagepath\tools\epiupdates
#   By default uses EPiServerDB connection string name and if the connection string name is different from default (EPiServerDB)
#	then it needs a settings.config (See setting for more information)
Function Update-EPiDatabase
{
<#
	.Description
		Update database by deploying updated sql files that can be found under nuget packages. The pattern to find sql files is nugetpackage.id.version\tools\epiupdates*.sql.
		By default uses EPiServerDB connection string name and if the connection string name is different from default (EPiServerDB)
		then it needs a settings.config in the epiupdates folder as: 
		<settings>
			<connectionStringName>MyConnectionString</connectionStringName>
		</settings>
    .SYNOPSIS 
		Update all Epi database
    .EXAMPLE
		Update-EPiDatabase
		Update-EPiDatabase -commandTimeout 60

#>
	[CmdletBinding()]
    param ([string]$commandTimeout = $defaultCommandTimeout)
	Update "sql" -Verbose:(GetVerboseFlag($PSBoundParameters)) $commandTimeout
}

#	This CommandLet update web config 
#	It collects all transformation config by default under $packagepath\tools\epiupdates
Function Update-EPiConfig
{
<#
	.Description
		Update config file by finding transform config files that can be found under nuget packages. The pattern to find transform config files is nugetpackage.id.version\tools\epiupdates*.config.
    .SYNOPSIS 
		Update config file.
    .EXAMPLE
		Update-EPiConfig
#>
	[CmdletBinding()]
    param ( )

	Update "config" -Verbose:($PSBoundParameters["Verbose"].IsPresent -eq $true)
}

#	This command can be used in the visual studio environment
#	Try to find all packages that related to the project that needs to be updated  
#   Create export package that can be used to update to the site
Function Export-EPiUpdates 
{
 <#
	.Description
		Export updated sql and transform config files that can be found under nuget packages. The pattern to find sql and transform config files is nugetpackage.id.version\tools\epiupdates*.
		The transform config files and sql files are saved in the EPiUpdatePackage folder. In the EPiUpdatePackage folder is uppdate.bat file that can be run on the site.
    .SYNOPSIS 
		Export updated sql files into EPiUpdatePackage.
    .EXAMPLE
		Export-EPiUpdates
		Export-EPiUpdates commandTimeout:30
#>
	[CmdletBinding()]
    param ($action = "sql", [string]$commandTimeout =$defaultCommandTimeout)
	
	$params = Getparams $installPath
	$packages = $params["packages"]
	$sitePath = $params["sitePath"]
	ExportPackages  $action $params["sitePath"]  $params["packagePath"] $packages $commandTimeout -Verbose:(GetVerboseFlag($PSBoundParameters))
}


Function Initialize-EPiDatabase
{
<#
	.Description
		Deploy all sql schema that can be found under nuget package. The pattern to find sql files is nugetpackage.id.version\tools\nugetpackage.id.sql.
		By default uses EPiServerDB connection string name and if the connection string name is different from default (EPiServerDB)
		then it needs a settings.config as: 
		<settings>
			<connectionStringName>MyConnectionString</connectionStringName>
		</settings>
    .SYNOPSIS 
		Deploy epi database schema.
    .EXAMPLE
		Initialize-EPiDatabase
		This command deploy all epi database schema that can be found in the nuget packages. 
	.EXAMPLE
		Initialize-EPiDatabase -sqlFilePattern:c:\data\mysql.sql -connectionString:MyConnectionString -commandTimeout:30
		This command deploy mysql.sql into database by using MyConnectionString. The -connectionString can be both connection string name inthe application web config or connection string.
#>
	[CmdletBinding()]
    param ([string]$sqlFilePattern, [string]$connectionString,[bool]$validation = $false, [string]$commandTimeout = $defaultCommandTimeout)

	$params = Getparams $installPath
	$packages = $params["packages"]
	$packagePath = $params["packagePath"]
	$sitePath = $params["sitePath"]

	$epideploy = GetDeployExe $packagePath $packages  
	if (!$epideploy)
	{
		throw "There is no EPiServer.Framework nuget package installed"
	}

	if (!$connectionString -and !$sqlFilePattern) 
	{
		# deploy all products
		DeploySqlFiles $epideploy $packages $packagePath $sitePath $validation $commandTimeout
		return
	}

	if (!$connectionString)
	{
		$connectionString = "EPiServerDB"
	}

	if ($sqlFilePattern)
	{
		DeploySqlFile $epideploy $connectionString $sqlFilePattern $sitePath $validation $commandTimeout
		return;	
	}
}

#	This command can be used in the visual studio environment
#	Try to find all packages that related to the project that has update  
#	Find out setting for each package
#   Call epideploy with -a config for each package
Function Update 
{
 	[CmdletBinding()]
    param ($action, [string]$commandTimeout = $defaultCommandTimeout)

	$params = Getparams $installPath
	$packages = $params["packages"]
	$sitePath = $params["sitePath"]
 
	Update-Packages $action $params["sitePath"] $params["packagePath"] $packages $commandTimeout -Verbose:(GetVerboseFlag($PSBoundParameters))
}


#	This command can be used in the visual studio environment
#	Export all packages that have epiupdates folder under tools path and
#	Create a bat (update.bat) that can be used to call on site
Function ExportPackages
{
 	[CmdletBinding()]
    param ($action, $sitePath, $packagesPath, $packages, $commandTimeout = $defaultCommandTimeout)

	CreateRootPackage  $exportRootPackageName
	$batFile  = AddUsage 
	$packages |foreach-object -process {
			$packageName = $_.id + "." + $_.version
			$packagePath = join-path $packagesPath $packageName
			$packageToolsPath = join-Path $packagePath $tools_id
			if (test-Path $packageToolsPath){
				$updatePackages = Get-ChildItem -path $packageToolsPath -Filter $updatesPattern
				if($updatePackages -ne $null) {
					foreach($p in $updatePackages) {
						$packageSetting = Get-PackageSetting $p.FullName
						ExportPackage $packagePath $packageName $p $packageSetting
						$des = join-path $packageName $p
						AddDeployCommand $action $batFile  $des $packageSetting $commandTimeout
					}
				}
			}
		}
	Add-Content $batFile.FullName ") $($nl)"
	ExportFrameworkTools $packagesPath $packages
	Write-Verbose "A $($runBatFile) file has been created in the $($exportRootPackageName)"
}

Function AddDeployCommand($action, $batFile,  $des, $packageSetting, $commandTimeout = $defaultCommandTimeout)
{
	if ($action -match "config")
	{
		$command =  "epideploy.exe  -a config -s ""%~f1""  -p ""$($des)\*"" -c ""$($packageSetting["connectionStringName"])"""
		Add-Content $batFile.FullName $command
	}
	if ($action -match "sql")
	{
		$command =  "epideploy.exe  -a sql -s ""%~f1""  -p ""$($des)\*""  -m ""$($commandTimeout)""  -c ""$($packageSetting["connectionStringName"])"""
		Add-Content $batFile.FullName $command
	}
}

Function AddUsage ()
{
	$content = "@echo off  $($nl) if '%1' ==''  ($($nl) echo  USAGE: %0  web application path ""[..\episerversitepath or c:\episerversitepath]"" $($nl)	) else ($($nl)" 
	New-Item (join-path $exportRootPackageName $runBatFile) -type file -force -value $content
}

Function CreateRootPackage ($deployPackagePath)
{
	if (test-path $deployPackagePath)
	{
		remove-Item -path $deployPackagePath -Recurse
	}
	$directory = New-Item -ItemType directory -Path $deployPackagePath
	Write-Host "An Export package is created $($directory.Fullname)"
}

Function ExportPackage($packagpath, $packageName, $updatePackage, $setting)
{
	$packageRootPath = join-path (join-Path $exportRootPackageName  $packageName) $updatePackage.Name
	write-Host "Exporting  $($updatePackage.Name) into $($packageRootPath)"
	$destinationupdatePath  = join-Path $packageRootPath  $package.Name
	copy-Item $updatePackage.FullName  -Destination $destinationupdatePath  -Recurse
	if ($setting["settingPath"])
	{
		copy-Item $setting["settingPath"]  -Destination $packageRootPath 
	}
}

Function GetEpiFrameworkFromPackages($packages)
{
	return (GetPackage $packages $frameworkPackageId)
}

Function DeploySqlFiles()
{
 	[CmdletBinding()]
	 param ($epideploy, $packages, $packagesPath, $sitePath, [bool]$validation = $false, [string]$commandTimeout = $defaultCommandTimeout)

	 $packages | foreach-object -process {
			$packageName = $_.id + "." + $_.version
			$packagePath = join-path $packagesPath $packageName
			$sqldatabaseFile = join-Path (join-Path $packagePath $tools_id) ( $_.id + ".sql")
			if (test-Path $sqldatabaseFile){
				$packageSetting = Get-PackageSetting $packagePath
				DeploySqlFile $epideploy $packageSetting["connectionStringName"] $sqldatabaseFile  $sitePath  $validation $commandTimeout
			}
		}
}

Function DeploySqlFile()
{
	[CmdletBinding()]
	param ($epideploy, [string]$connectionString, [string]$sqlFilePattern, [string]$sitePath, [bool]$validation = $false, [string]$commandTimeout = $defaultCommandTimeout)

	if ((($connectionString -Match "Data Source=") -eq $true) -or (($connectionString -Match "AttachDbFilename=") -eq $true) -or (($connectionString -Match "Initial Catalog=") -eq $true)) 
	{
		&$epideploy  -a "sql" -s $sitePath  -p $sqlFilePattern -b  $connectionString  -v $validation -d (GetVerboseFlag($PSBoundParameters)) -m $commandTimeout
	}
	else
	{
		&$epideploy  -a "sql" -s $sitePath  -p $sqlFilePattern -c  $connectionString  -v $validation -d (GetVerboseFlag($PSBoundParameters))  -m $commandTimeout
	}
}

Function GetPackage($packages, $packageid)
{
	$package = $packages | where-object  {$_.id -eq $packageid} | Sort-Object -Property version -Descending
	if ($package -ne $null)
	{
		return $package.id + "." + $package.version 
	}
}

Function ExportFrameworkTools($packagePath, $packages)
{
	$epiDeployPath = GetDeployExe $packagesPath  $packages
	copy-Item $epiDeployPath  -Destination $exportRootPackageName
}
 
Function Update-Packages
{
	[CmdletBinding()]
	param($action, $sitePath, $packagesPath, $packages, [string]$commandTimeout = $defaultCommandTimeout)
	$epiDeployPath = GetDeployExe $packagesPath  $packages
	$packages | foreach-object -process {
				$packagePath = join-path $packagesPath ($_.id + "." + $_.version)
				$packageToolsPath = join-Path $packagePath $tools_id
				if (test-Path $packageToolsPath){
					$updatePackages = Get-ChildItem -path $packageToolsPath -Filter $updatesPattern
					if($updatePackages -ne $null) {
						foreach($p in $updatePackages) {
							$settings = Get-PackageSetting $p.FullName
							Update-Package $p.FullName $action $sitePath $epiDeployPath  $settings  -Verbose:(GetVerboseFlag($PSBoundParameters)) $commandTimeout
						}
					}
				}
			}
}
 
Function Update-Package  
  {
	[CmdletBinding()]
    Param ($updatePath, $action, $sitePath, $epiDeployPath, $settings, [string]$commandTimeout = $defaultCommandTimeout)
	
    if (test-Path $updatePath)
	{
        Write-Verbose "$epiDeployPath  -a $action -s $sitePath  -p $($updatePath)\* -c $($settings["connectionStringName"]) "
		&$epiDeployPath  -a $action -s $sitePath  -p $updatePath\* -c $settings["connectionStringName"]  -d (GetVerboseFlag($PSBoundParameters)) -m $commandTimeout
	}
}

#	Find out EPiDeploy from frameworkpackage
Function GetDeployExe($packagesPath, $packages)
 {
	$frameWorkPackage = $packages |  where-object  {$_.id -eq $frameworkPackageId} | Sort-Object -Property version -Descending
	$frameWorkPackagePath = join-Path $packagesPath ($frameWorkPackage.id + "." + $frameWorkPackage.version)
	join-Path  $frameWorkPackagePath "tools\epideploy.exe"
 }

#	Find "settings.config" condig file under the package  
#	The format of the settings file is like 
#		<settings>
#			<connectionStringName/>
#		</settings>
Function Get-PackageSetting($packagePath)
{
	$packageSettings = Get-ChildItem -Recurse $packagePath -Include $setting | select -first 1
	if ($packageSettings -ne $null)
	{
		$xml = [xml](gc $packageSettings)
		if ($xml.settings.SelectSingleNode("connectionStringName") -eq $null)
		{
			$connectionStringName = $xml.CreateElement("connectionStringName")
			$xml.DocumentElement.AppendChild($connectionStringName)
		}
		if ([String]::IsNullOrEmpty($xml.settings.connectionStringName))
		{
			$xml.settings.connectionStringName  = "EPiServerDB"
		}
	}
	else
	{
		$xml = [xml] "<settings><connectionStringName>EPiServerDB</connectionStringName></settings>"
	}
	 @{"connectionStringName" = $($xml.settings.connectionStringName);"settingPath" = $packageSettings.FullName}
}

# Get base params
Function GetParams($installPath)
{
	#Get The current Project
	$project  = GetProject
	$projectPath = Get-ChildItem $project.Fullname
	#site path
	$sitePath = $projectPath.Directory.FullName
	#Get project packages 
	$packages = GetPackage($project.Name)
 
	if ($installPath)
	{
		#path to packages 
		$packagePath = (Get-Item -path $installPath -ErrorAction:SilentlyContinue).Parent.FullName
	}

	if (!$packagePath -or (test-path $packagePath) -eq $false)
	{
		throw "There is no 'nuget packages' directory"
	}

	@{"project" = $project; "packages" = $packages; "sitePath" = $sitePath; "packagePath" = $packagePath}
}

Function GetVerboseFlag ($parameters)
{
	($parameters["Verbose"].IsPresent -eq $true)
}

Function GetProject()
{
	Get-Project
}

Function GetPackage($projectName)
{
	Get-Package -ProjectName  $projectName
}
#Exported functions are Update-EPiDataBase Update-EPiConfig
export-modulemember -function  Update-EPiDatabase, Update-EPiConfig, Export-EPiUpdates, Initialize-EPiDatabase
# SIG # Begin signature block
# MIIXpAYJKoZIhvcNAQcCoIIXlTCCF5ECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDEWCEA304Ia8ttLRv1JxVmNT
# wiugghLKMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggTQMIIDuKADAgECAhASn/W83LmZkqPf6+aeK2mOMA0GCSqGSIb3DQEBCwUAMH8x
# CzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0G
# A1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEwMC4GA1UEAxMnU3ltYW50ZWMg
# Q2xhc3MgMyBTSEEyNTYgQ29kZSBTaWduaW5nIENBMB4XDTE2MDExMzAwMDAwMFoX
# DTE5MDQxMzIzNTk1OVowYzELMAkGA1UEBhMCU0UxEjAQBgNVBAgTCVNUT0NLSE9M
# TTESMBAGA1UEBxMJU1RPQ0tIT0xNMRUwEwYDVQQKFAxFUGlTZXJ2ZXIgQUIxFTAT
# BgNVBAMUDEVQaVNlcnZlciBBQjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBALWsGwJJX/DKwasEkA9qAsdlsqP8SjVHN7lXwAt2CfBjDI0rN8DO20OfCgos
# Dw1rsSAs1iNNFrB6tdzM+wXZQrHE+bJAYvEXzmZM1kSQfCLz6qIwxx3cRIz8u3Wb
# lH391Dqz03Hf6Ds8N42QKv3m9gQP6g1OIPwlziVkgZ4ANdAP4CfTKPmg0kFqW+az
# WQs+ccYOZEWBi4oPIvPv1uwAbAKIK9fArAtrta7vIdtNf2FZftuL/kAjz980wDFY
# moYR4IGY2eT0FETkoi+dQOhxIbZEl5ziPr5cpiHDWt3J5gueoQCEhiKFg9Uzoquj
# 07IyexmtsjtDsMenkwOSGt2aefMCAwEAAaOCAWIwggFeMAkGA1UdEwQCMAAwDgYD
# VR0PAQH/BAQDAgeAMCsGA1UdHwQkMCIwIKAeoByGGmh0dHA6Ly9zdi5zeW1jYi5j
# b20vc3YuY3JsMGYGA1UdIARfMF0wWwYLYIZIAYb4RQEHFwMwTDAjBggrBgEFBQcC
# ARYXaHR0cHM6Ly9kLnN5bWNiLmNvbS9jcHMwJQYIKwYBBQUHAgIwGQwXaHR0cHM6
# Ly9kLnN5bWNiLmNvbS9ycGEwEwYDVR0lBAwwCgYIKwYBBQUHAwMwVwYIKwYBBQUH
# AQEESzBJMB8GCCsGAQUFBzABhhNodHRwOi8vc3Yuc3ltY2QuY29tMCYGCCsGAQUF
# BzAChhpodHRwOi8vc3Yuc3ltY2IuY29tL3N2LmNydDAfBgNVHSMEGDAWgBSWO1Pw
# eTOXr32D7y4rzMq3hh5yZjAdBgNVHQ4EFgQUlelWRKcMMuDX80+oWbXEPaHUd7sw
# DQYJKoZIhvcNAQELBQADggEBAIaGfEvw4rJgaEDow3Aea6Fg4LGxAtezhs6bjDZi
# h/IJdcWV1nEc/uhZ5XegmRXn3LaP2RL+ZHmjWrQxv4/aK/ZCFxBV0omny3VnIXsY
# UldnW8589S3a83Dtb3cpF+P57M8Z+Fwt+gyvQJYAyDrpMvgMdOotVFWUVVDESXV/
# ttYmhg3MC0ZLuWHREKR9Jrqe9aFjjbGbQlb8jKBOBDPSykjR2nnb5lBgXyfDG9Gf
# zfzz/ed2V95/NSyk2RQD3Wo/IiR/TMABuJEXzsGIMBGSHe6Yz58IxXox4WNyn26o
# 8NklVx6UVsquwXFANU0b4Z/FDTt0cr4PjxNb/Ww/ogKdSBMwggVZMIIEQaADAgEC
# AhA9eNf5dklgsmF99PAeyoYqMA0GCSqGSIb3DQEBCwUAMIHKMQswCQYDVQQGEwJV
# UzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRy
# dXN0IE5ldHdvcmsxOjA4BgNVBAsTMShjKSAyMDA2IFZlcmlTaWduLCBJbmMuIC0g
# Rm9yIGF1dGhvcml6ZWQgdXNlIG9ubHkxRTBDBgNVBAMTPFZlcmlTaWduIENsYXNz
# IDMgUHVibGljIFByaW1hcnkgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgLSBHNTAe
# Fw0xMzEyMTAwMDAwMDBaFw0yMzEyMDkyMzU5NTlaMH8xCzAJBgNVBAYTAlVTMR0w
# GwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMg
# VHJ1c3QgTmV0d29yazEwMC4GA1UEAxMnU3ltYW50ZWMgQ2xhc3MgMyBTSEEyNTYg
# Q29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# l4MeABavLLHSCMTXaJNRYB5x9uJHtNtYTSNiarS/WhtR96MNGHdou9g2qy8hUNqe
# 8+dfJ04LwpfICXCTqdpcDU6kDZGgtOwUzpFyVC7Oo9tE6VIbP0E8ykrkqsDoOatT
# zCHQzM9/m+bCzFhqghXuPTbPHMWXBySO8Xu+MS09bty1mUKfS2GVXxxw7hd924vl
# YYl4x2gbrxF4GpiuxFVHU9mzMtahDkZAxZeSitFTp5lbhTVX0+qTYmEgCscwdyQR
# TWKDtrp7aIIx7mXK3/nVjbI13Iwrb2pyXGCEnPIMlF7AVlIASMzT+KV93i/XE+Q4
# qITVRrgThsIbnepaON2b2wIDAQABo4IBgzCCAX8wLwYIKwYBBQUHAQEEIzAhMB8G
# CCsGAQUFBzABhhNodHRwOi8vczIuc3ltY2IuY29tMBIGA1UdEwEB/wQIMAYBAf8C
# AQAwbAYDVR0gBGUwYzBhBgtghkgBhvhFAQcXAzBSMCYGCCsGAQUFBwIBFhpodHRw
# Oi8vd3d3LnN5bWF1dGguY29tL2NwczAoBggrBgEFBQcCAjAcGhpodHRwOi8vd3d3
# LnN5bWF1dGguY29tL3JwYTAwBgNVHR8EKTAnMCWgI6Ahhh9odHRwOi8vczEuc3lt
# Y2IuY29tL3BjYTMtZzUuY3JsMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcD
# AzAOBgNVHQ8BAf8EBAMCAQYwKQYDVR0RBCIwIKQeMBwxGjAYBgNVBAMTEVN5bWFu
# dGVjUEtJLTEtNTY3MB0GA1UdDgQWBBSWO1PweTOXr32D7y4rzMq3hh5yZjAfBgNV
# HSMEGDAWgBR/02Wnwt3su/AwCfNDOfoCrzMxMzANBgkqhkiG9w0BAQsFAAOCAQEA
# E4UaHmmpN/egvaSvfh1hU/6djF4MpnUeeBcj3f3sGgNVOftxlcdlWqeOMNJEWmHb
# cG/aIQXCLnO6SfHRk/5dyc1eA+CJnj90Htf3OIup1s+7NS8zWKiSVtHITTuC5nmE
# FvwosLFH8x2iPu6H2aZ/pFalP62ELinefLyoqqM9BAHqupOiDlAiKRdMh+Q6EV/W
# pCWJmwVrL7TJAUwnewusGQUioGAVP9rJ+01Mj/tyZ3f9J5THujUOiEn+jf0or0oS
# vQ2zlwXeRAwV+jYrA9zBUAHxoRFdFOXivSdLVL4rhF4PpsN0BQrvl8OJIrEfd/O9
# zUPU8UypP7WLhK9k8tAUITGCBEQwggRAAgEBMIGTMH8xCzAJBgNVBAYTAlVTMR0w
# GwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMg
# VHJ1c3QgTmV0d29yazEwMC4GA1UEAxMnU3ltYW50ZWMgQ2xhc3MgMyBTSEEyNTYg
# Q29kZSBTaWduaW5nIENBAhASn/W83LmZkqPf6+aeK2mOMAkGBSsOAwIaBQCgeDAY
# BgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3
# AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEW
# BBR3qrHMtVISKDQktLu4rG+YSJowxjANBgkqhkiG9w0BAQEFAASCAQAnS+C4h9aC
# 56vMcq68IYhWynQavoRHIuRIj7VsNe+GmAKzghIoSXBWs8Bv3qS+TZBh7DAr3rSP
# oY8cyIqqRV5lxADsgQNDzg6k4wDuXCDJdRv17hF7jmzeHSje0JT1xVqEQOfPEkqK
# PnRRAOrhAyhdj6UfXgdxNhG+bUH+JtIU0/JZUpn2j+ZJHEWK8DWHQd99KRT3g/8M
# gXFgUCp3MpWdirFE0NWEY3ASisMZ6EcKEaw9FZyu2kfusAfeDh8ntO6i390v3/ek
# 724DfiC8WW871BiraAZrQVlawOlU1W0Nbuf7z0To2ei1az7nbwq7Hb3HkW8bvMz5
# DXnhlTclrJGooYICCzCCAgcGCSqGSIb3DQEJBjGCAfgwggH0AgEBMHIwXjELMAkG
# A1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTAwLgYDVQQD
# EydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBIC0gRzICEA7P9DjI
# /r81bgTYapgbGlAwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0B
# BwEwHAYJKoZIhvcNAQkFMQ8XDTE2MDQwODExMzczOVowIwYJKoZIhvcNAQkEMRYE
# FB0JSLaXcXA72eScr7fZXpxl7ghoMA0GCSqGSIb3DQEBAQUABIIBAA71sF2AsrFB
# CzAxkiBfyTpC8YJDuw1OWgHuhpgPRxz6Ro14VBbavsdrFyY4aEOl40b3J7LVxRSs
# cYPhUdGOvg8ybse95XOSewzJcfPtwRTlR4s95GjUl7hWELPKim95czKVrlCRFEry
# hrKuf2nS8MkAs3H/OVIbZS3mtDAU6QDBGaZOoFdIO0kh9m06Ug1aoTKxfT6YBcKt
# 9ctFPp2n9EAFcAh3tkmq2Lw9NxjcoGRnigL36DPR2AtTbHW0DS1ijgeUNGgdL8oP
# RKuRrFbsOwaANOO27j9tgtgA3S/xK3l6W8mTKVXHLk0F1FniLxm1g3Z5mI0uu37Q
# +OhrKIj0OhA=
# SIG # End signature block
