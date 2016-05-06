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
# MIIZDwYJKoZIhvcNAQcCoIIZADCCGPwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSPYVjNc2Fi7l/78EdSEBtzdQ
# /augghP/MIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# ggVUMIIEPKADAgECAhBqBz1Yk9Ce+JomHWkTBhgAMA0GCSqGSIb3DQEBBQUAMIG0
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsT
# FlZlcmlTaWduIFRydXN0IE5ldHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9mIHVzZSBh
# dCBodHRwczovL3d3dy52ZXJpc2lnbi5jb20vcnBhIChjKTEwMS4wLAYDVQQDEyVW
# ZXJpU2lnbiBDbGFzcyAzIENvZGUgU2lnbmluZyAyMDEwIENBMB4XDTEzMDIwNTAw
# MDAwMFoXDTE2MDQwNTIzNTk1OVowgZcxCzAJBgNVBAYTAlNFMQowCAYDVQQIEwEt
# MQ4wDAYDVQQHEwVLSVNUQTEVMBMGA1UEChQMRVBpU2VydmVyIEFCMT4wPAYDVQQL
# EzVEaWdpdGFsIElEIENsYXNzIDMgLSBNaWNyb3NvZnQgU29mdHdhcmUgVmFsaWRh
# dGlvbiB2MjEVMBMGA1UEAxQMRVBpU2VydmVyIEFCMIIBIjANBgkqhkiG9w0BAQEF
# AAOCAQ8AMIIBCgKCAQEAo6coNqVVn2Rk4HBEl0kc/HO+PttBuDrEx/9fKLONe3yT
# SFWk6dg7/Lv1l+uSTwt4GbWkk3HU4tRRd2gPJ3AK14AysycQRE9T0H5mhcJntXnz
# 6i6rOOQjEqmjipcu1iO1BPl8OSEK3h37kjjhtPCei2KpViH2icmVfVgtevF988qh
# n7V/B66QtQGjl44gBAI3JBgUDUhCCFO+d9+tY6gYx9SR9+OwYWNusRpEG4wHlzpo
# mK4xIcrk6CBfktyEjDRs7ZCNOdL3mWvPKVeZjj3+f+XPrARmEOkBsCCDuRPG2bRK
# /3gLrAfVP5L73EHHNgLqS2uzPppChulRvIKjnUyOVwIDAQABo4IBezCCAXcwCQYD
# VR0TBAIwADAOBgNVHQ8BAf8EBAMCB4AwQAYDVR0fBDkwNzA1oDOgMYYvaHR0cDov
# L2NzYzMtMjAxMC1jcmwudmVyaXNpZ24uY29tL0NTQzMtMjAxMC5jcmwwRAYDVR0g
# BD0wOzA5BgtghkgBhvhFAQcXAzAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy52
# ZXJpc2lnbi5jb20vcnBhMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHEGCCsGAQUFBwEB
# BGUwYzAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AudmVyaXNpZ24uY29tMDsGCCsG
# AQUFBzAChi9odHRwOi8vY3NjMy0yMDEwLWFpYS52ZXJpc2lnbi5jb20vQ1NDMy0y
# MDEwLmNlcjAfBgNVHSMEGDAWgBTPmanqeyb0S8mOj9fwBSbv49KnnTARBglghkgB
# hvhCAQEEBAMCBBAwFgYKKwYBBAGCNwIBGwQIMAYBAQABAf8wDQYJKoZIhvcNAQEF
# BQADggEBAIk7DJSHwVYLgVDJzo1GSsMElW0XhAkl167CGHP0q18xgRCEZsb1M93u
# Z6uSnJWbtnGrxHSjbOxvWPUQSChMq7h+aZdw/emdFpZ5g3tbKcTZN/1l8pREvPG7
# vO/UUmXSG20xezxcuzM2bRgIYxmFIHNn6XXVORkWVGujm/zo/dYVDPjH1udFZ5nj
# IenD/YeO2ZjvnZssAoyTZuDhpf3qUtEff2Kc+PXVYoMsk8Q4TO74ps6DbpqddLDg
# k73Xbyr++tvmhZIL8XSzB9j1thEijIwYFn6k2TMls4pVQ8s/37oJcvwZ/KPICLUY
# +A8+Kx6iywx7QN1mfwEekzsKiYA7LHswggYKMIIE8qADAgECAhBSAOWqJVb8Gobt
# lsnUSzPHMA0GCSqGSIb3DQEBBQUAMIHKMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# VmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsx
# OjA4BgNVBAsTMShjKSAyMDA2IFZlcmlTaWduLCBJbmMuIC0gRm9yIGF1dGhvcml6
# ZWQgdXNlIG9ubHkxRTBDBgNVBAMTPFZlcmlTaWduIENsYXNzIDMgUHVibGljIFBy
# aW1hcnkgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgLSBHNTAeFw0xMDAyMDgwMDAw
# MDBaFw0yMDAyMDcyMzU5NTlaMIG0MQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVy
# aVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxOzA5
# BgNVBAsTMlRlcm1zIG9mIHVzZSBhdCBodHRwczovL3d3dy52ZXJpc2lnbi5jb20v
# cnBhIChjKTEwMS4wLAYDVQQDEyVWZXJpU2lnbiBDbGFzcyAzIENvZGUgU2lnbmlu
# ZyAyMDEwIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA9SNLXqXX
# irsy6dRX9+/kxyZ+rRmY/qidfZT2NmsQ13WBMH8EaH/LK3UezR0IjN9plKc3o5x7
# gOCZ4e43TV/OOxTuhtTQ9Sc1vCULOKeMY50Xowilq7D7zWpigkzVIdob2fHjhDuK
# Kk+FW5ABT8mndhB/JwN8vq5+fcHd+QW8G0icaefApDw8QQA+35blxeSUcdZVAccA
# JkpAPLWhJqkMp22AjpAle8+/PxzrL5b65Yd3xrVWsno7VDBTG99iNP8e0fRakyiF
# 5UwXTn5b/aSTmX/fze+kde/vFfZH5/gZctguNBqmtKdMfr27Tww9V/Ew1qY2jtaA
# dtcZLqXNfjQtiQIDAQABo4IB/jCCAfowEgYDVR0TAQH/BAgwBgEB/wIBADBwBgNV
# HSAEaTBnMGUGC2CGSAGG+EUBBxcDMFYwKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3
# LnZlcmlzaWduLmNvbS9jcHMwKgYIKwYBBQUHAgIwHhocaHR0cHM6Ly93d3cudmVy
# aXNpZ24uY29tL3JwYTAOBgNVHQ8BAf8EBAMCAQYwbQYIKwYBBQUHAQwEYTBfoV2g
# WzBZMFcwVRYJaW1hZ2UvZ2lmMCEwHzAHBgUrDgMCGgQUj+XTGoasjY5rw8+AatRI
# GCx7GS4wJRYjaHR0cDovL2xvZ28udmVyaXNpZ24uY29tL3ZzbG9nby5naWYwNAYD
# VR0fBC0wKzApoCegJYYjaHR0cDovL2NybC52ZXJpc2lnbi5jb20vcGNhMy1nNS5j
# cmwwNAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC52ZXJp
# c2lnbi5jb20wHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMDMCgGA1UdEQQh
# MB+kHTAbMRkwFwYDVQQDExBWZXJpU2lnbk1QS0ktMi04MB0GA1UdDgQWBBTPmanq
# eyb0S8mOj9fwBSbv49KnnTAfBgNVHSMEGDAWgBR/02Wnwt3su/AwCfNDOfoCrzMx
# MzANBgkqhkiG9w0BAQUFAAOCAQEAViLmNKTEYctIuQGtVqhkD9mMkcS7zAzlrXqg
# In/fRzhKLWzRf3EafOxwqbHwT+QPDFP6FV7+dJhJJIWBJhyRFEewTGOMu6E01MZF
# 6A2FJnMD0KmMZG3ccZLmRQVgFVlROfxYFGv+1KTteWsIDEFy5zciBgm+I+k/RJoe
# 6WGdzLGQXPw90o2sQj1lNtS0PUAoj5sQzyMmzEsgy5AfXYxMNMo82OU31m+lIL00
# 6ybZrg3nxZr3obQhkTNvhuhYuyV8dA5Y/nUbYz/OMXybjxuWnsVTdoRbnK2R+qzt
# k7pdyCFTwoJTY68SDVCHERs9VFKWiiycPZIaCJoFLseTpUiR0zGCBHowggR2AgEB
# MIHJMIG0MQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAd
# BgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9m
# IHVzZSBhdCBodHRwczovL3d3dy52ZXJpc2lnbi5jb20vcnBhIChjKTEwMS4wLAYD
# VQQDEyVWZXJpU2lnbiBDbGFzcyAzIENvZGUgU2lnbmluZyAyMDEwIENBAhBqBz1Y
# k9Ce+JomHWkTBhgAMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTy5GfjYohJTK8+mg5dIDLcm94j
# oDANBgkqhkiG9w0BAQEFAASCAQB2zzveX3UICUf33RRedF0sGougpvOC01dcJvYV
# 8Ui54IHM3LNsHuxCygul5D1A3u3rTizJs3JECOT/uLReLC97m8FGZ75eEFrsWuvU
# uxClW3q4aCm+Ueysk999kDsN4J16W1wQZ/lnqYxP04IK2YPz86c36or301kAKh0v
# +tLdq3mbeHcsT98OICyRmuX6YkwXBNonrbiRAu6MMrIWIRQ7oSQIVD35OC56Gbl4
# qArFDI7fUf3SUkSsd7R5LMdWZsYZ4UHqqh+NUexyrg53l7PO83CrKitlbBR61afr
# rKSulw0SicrtqrSMY5HfPezihJtsF+W0cYazHT8SWDR7cqKJoYICCzCCAgcGCSqG
# SIb3DQEJBjGCAfgwggH0AgEBMHIwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5
# bWFudGVjIENvcnBvcmF0aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1w
# aW5nIFNlcnZpY2VzIENBIC0gRzICEA7P9DjI/r81bgTYapgbGlAwCQYFKw4DAhoF
# AKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDEyNTA3NDAxMFowIwYJKoZIhvcNAQkEMRYEFLpAZlRjrrQi3Nxhr57ArusArrXf
# MA0GCSqGSIb3DQEBAQUABIIBAJLe2wKao6IJSJZ4ixD9OXHT1/N74gYbhEJXcHkF
# O8ZpCFewmCoLtwDnqC5fyavr2iNTeUFgfvo8pX0ad/ER1eyjXcqQQcUYsQDs3IIg
# Y1e9C0GFFFpUrxjkV2yE1VfONCXP4a0+wSxRtvkTDpP3/D0ObrfsyC3oLwW5/p/7
# kQbHEyaBz90OnzSqkSL6nU5g++3xdPkQqrEoTXC0SXS5tu5ytQbyFAtVt0WviLR2
# p8M3WAsH+6n3jgJoCjLevp8CZZvfnFV7ItQqq21FANcVQUEhoFs1JeUG5QGYvbhc
# C3fpFNiElNl//qwK+GN/s6AzAeXyEVJue8jCGEdhTzGikMg=
# SIG # End signature block
