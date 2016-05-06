
function Get-WebConfig
{
	param ($projectPath)

	# Construct the path to the web.config based on the project path
	$webConfigPath = Join-Path $projectPath "web.config"

	# Do an early exit returning null if the web.config file doesn't exist
	if (!(Test-Path $webConfigPath))
	{
		return $null
	}

	# Load the web.config as an XmlDocument
	[xml] $config = Get-Content $webConfigPath

	# Expand all the nodes that have their configuration in another file
	$config.SelectNodes("//*[@configSource]") | ForEach-Object {
		$configFragmentPath = Join-Path $projectPath $_.GetAttribute("configSource")
		if (Test-Path $configFragmentPath)
		{
			# Set the contents of the referenced file as the contents of the referencing element
			$_.InnerXml = ([xml](Get-Content $configFragmentPath)).FirstChild.InnerXml
			$_.RemoveAttribute("configSource")
		}
	}

	return $config
}


#Create a offset type
Function New-DateTimeConversionOffset()
{
  param ([datetime]$IntervalStart,[datetime] $IntervalEnd, [long]$Offset)

  $DateTimeConversionOffset = new-object PSObject

  $DateTimeConversionOffset | add-member -type NoteProperty  -Name IntervalStart -Value $IntervalStart
  $DateTimeConversionOffset | add-member -type NoteProperty  -Name IntervalEnd -Value $IntervalEnd
  $DateTimeConversionOffset | add-member -type NoteProperty  -Name Offset -Value $Offset

  return $DateTimeConversionOffset
}

#generate Offset with respect to time zone between start and end 
Function GenerateOffsets()
{
	param ([TimeZoneInfo]$timeZone, [int]$startYears, [int]$endYears)
	
	$res = @()
    $start = (get-date).AddYears($startYears)
    $end = (get-date).AddYears($endYears)
    $current = $start
    $startOffset = $timeZone.GetUtcOffset($start).TotalMinutes
    while ($current -lt $end)
    {
        $current = $current.AddMinutes(30)
        $currentOffset = $timeZone.GetUtcOffset($current).TotalMinutes
        if ($startOffset -ne $currentOffset)
        {
            $res += New-DateTimeConversionOffset -IntervalStart:$start -IntervalEnd:$current -Offset:$startOffset
            $start = $current
            $startOffset = $currentOffset
        }
    }
    if ($start -ne $current)
	{
     	$res += New-DateTimeConversionOffset -IntervalStart:$start -IntervalEnd:$current -Offset:$startOffset
	}
	return $res
}

#create offfset as a date table to send to sp
Function CreateOffsetRows()
{
	param ($items)

	$result = New-Object 'System.Collections.Generic.List[Microsoft.SqlServer.Server.SqlDataRecord]'
    if ($items -ne $null)
    {
        $intervalStart =  new-object Microsoft.SqlServer.Server.SqlMetaData("IntervalStart", [System.Data.SqlDbType]::DateTime);
        $intervalEnd =  new-object Microsoft.SqlServer.Server.SqlMetaData("IntervalEnd", [System.Data.SqlDbType]::DateTime);
        $offset =  new-object Microsoft.SqlServer.Server.SqlMetaData("Offset", [System.Data.SqlDbType]::Float);
		foreach($item in $items)
		{
            $sqldr = new-object Microsoft.SqlServer.Server.SqlDataRecord($intervalStart, $intervalEnd, $offset);
            [void]$sqldr.SetDateTime(0, $item.IntervalStart);
            [void]$sqldr.SetDateTime(1, $item.IntervalEnd);
            [void]$sqldr.SetDouble(2, $item.Offset);
			[void]$result.ADD($sqldr)
		}
    }
    return $result;
}

Function CreateOffsetInDB($connectionString, $rows)
{
	$effectedRows = ExecuteSP $connectionString "dbo.DateTimeConversion_InitDateTimeOffsets" "@DateTimeOffsets"  $rows "dbo.DateTimeConversion_DateTimeOffset"
} 

Function InitFieldNames($connectionString)
{
	$effectedRows = ExecuteSP $connectionString "DateTimeConversion_InitFieldNames"  
}

Function InitBlocks($connectionString, $blockSize)
{
	$effectedRows = ExecuteSP $connectionString "DateTimeConversion_InitBlocks" "@BlockSize"  $blockSize
}

Function RunBlocks($connectionString)
{
	$effectedRows = ExecuteSP $connectionString "DateTimeConversion_RunBlocks" 
}

Function SwitchToUtc($connectionString)
{
	$effectedRows = ExecuteSP $connectionString "DateTimeConversion_Finalize" 
}

Function ExecuteSP($connectionString, $nameOfSP, $paramName, $paramValue, $typeName)
{
	$connection = $null
	$cmd = $null;

	try
	{
		$connection = new-object System.Data.SqlClient.SQLConnection($connectionString)
		$connection.Open()
		$cmd = new-object System.Data.SqlClient.SqlCommand($nameOfSP, $connection)
		$cmd.CommandType = [System.Data.CommandType]::StoredProcedure
		$cmd.CommandTimeout = 0
		if ($paramName -and $paramValue)
		{
			$cmdparam = $cmd.Parameters.AddWithValue($paramName, $paramValue)
			if($typeName)
			{
				$cmdparam.SqlDbType = [System.Data.SqlDbType]::Structured
				$cmdparam.TypeName = $typeName
			}		
		}
		return  $cmd.ExecuteNonQuery() 
	}
	finally
	{
		if ($cmd)
		{
			[Void]$cmd.Dispose()
		}
		if ($connection)
		{
			[Void]$connection.Close()
		}
	}
}

<#
	This function can be used in the powershell context if the database connectionstring is known.
#>
Function ConvertEPiDatabaseToUtc()
{
<#
	.Description
		Convert the dateTime columns in the database to UTC. The Convert-EPiDatabaseToUtc cmdlet converts the columns that has been 
		configured in the DateTimeConversion_GetFieldNames. By default it only converts the content related items in the db.
		If both the Web applictaion and SQL Database already runs on the UTC, the cmdlet can be run with onlySwitchToUtc flag.
    .SYNOPSIS 
		Convert the dateTime in the database to UTC.  
    .EXAMPLE
		Convert-EPiDateTime -connectionString:"connection string"
		Convert-EPiDateTime -connectionString:"connection string" -onlySwitchToUtc:$true 
		Convert-EPiDateTime -connectionString:"connection string" -timeZone:([TimeZoneInfo]::FindSystemTimeZoneById("US Eastern Standard Time")) 
#>

	param (
	[Parameter(Mandatory=$true)][string]$connectionString, 
	[TimeZoneInfo] $timeZone = [TimeZoneInfo]::Local, 
	[int] $startYears = -25, 
	[int] $endYears = 5, 
	[int] $blockSize = 1000, 
	[bool]$onlySwitchToUtc  = $false)
	
	if ($onlySwitchToUtc -eq $true)
	{
		InitFieldNames $connectionString 
		SwitchToUtc  $connectionString 
	}
	else
	{
		$offsets = GenerateOffsets $timeZone $startYears $endYears
		$rows = [Microsoft.SqlServer.Server.SqlDataRecord[]](CreateOffsetRows $offsets)
		CreateOffsetInDB $connectionString $rows
		InitFieldNames $connectionString 
		InitBlocks $connectionString $blockSize
		RunBlocks  $connectionString 
		SwitchToUtc  $connectionString 
	}
}

Function GetConnectionString($connectionString)
{
	$theConnectionStringNameOrValue = $connectionString
	if (!$connectionString)
	{
		#default value is EPiServerDB
		$theConnectionStringNameOrValue = "EPiServerDB"
	}
		
	$project = Get-Project
	if (!$project)
	{
		throw "No active project, please define a connectionstring argument if you are not run under a project context."
	}

	$projectPath =  (Get-Item   $project.FullName).Directory.FullName
	$webconfig = Get-WebConfig  -projectPath $projectPath

	if (!$webconfig)
	{
		throw "No web config"
	}

	foreach($cn in $webconfig.configuration.connectionStrings.add)
	{
		#Take first one so far
		if (!$connectionString)
		{
			$connectionString = $cn.connectionString
		}
		if ($cn -and $cn.name -eq $theConnectionStringNameOrValue)
		{
			return $cn.connectionString.replace("|DataDirectory|", (join-path $projectPath "app_data\"))
		}
	}
	
	return  $connectionString 
}

Function Convert-EPiDatabaseToUtc()
{
<#
	.Description
		Convert the dateTime columns in the database to UTC. The Convert-EPiDatabaseToUtc cmdlet converts the columns that has been 
		configured in the DateTimeConversion_GetFieldNames. By default it only converts the content related items in the db. 
		If both the Web applictaion and SQL Database already runs on the UTC, the cmdlet can be run with onlySwitchToUtc.
    .SYNOPSIS 
		Convert the dateTime in the database to UTC.  
    .EXAMPLE
		Convert-EPiDateTime 
		Convert-EPiDateTime -connectionString:"connection string"
		Convert-EPiDateTime -connectionString:"connection string Name"  -onlySwitchToUtc:$true
		Convert-EPiDateTime -connectionString:"connection string" -timeZone:([TimeZoneInfo]::FindSystemTimeZoneById("US Eastern Standard Time")) 
#>
	[CmdletBinding()]
	param (
	[string]$connectionString, 
	[TimeZoneInfo] $timeZone = [TimeZoneInfo]::Local, 
	[int] $startYears = -25, 
	[int] $endYears = 5, 
	[int] $blockSize = 1000, 
	[bool] $onlySwitchToUtc = $false)

	$connectionString = GetConnectionString $connectionString
	if (!$connectionString)
	{
		throw "Failed to find the connectionstring"
	}
	ConvertEPiDatabaseToUtc $connectionString $timeZone $startYears $endYears $blockSize $onlySwitchToUtc
}

# SIG # Begin signature block
# MIIZDwYJKoZIhvcNAQcCoIIZADCCGPwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUzepFTfn0nNbHlYXpGwf+uK9W
# FGCgghP/MIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR3ERJa0YgY7CYqv/uT1SDF9svI
# rTANBgkqhkiG9w0BAQEFAASCAQCdydDcY0ePu2b+gJe7Eik1cp3E4R1SXNj58tAD
# mFv+H8zsqBJdaHd5LnpvAK9/op8eKI6cH1DxOrGAWN2vmme0hSBEdp4TYveaN6sv
# VlhYO+Q9/2yeSnT9caw2JwtN9JwRM9I4XCUP+r5Hm3BkRioqQS+nlbjzDkGJaX95
# iIbBAryWut7AMFjnvs0A98O+VRIzyLoNkG6Xk+NtNB0/Cm3R8avwjKlXx8GBmKeX
# RL3eXBKkqsrJPKUtOagkzrfGrmU6NM4a+WmlmaB4w6uOSTnkbUOdAsyvctuS4glO
# aVuN4ldgWBeYayV6qKR7O5mDPgBvl6vGtKhBhvCAB+2om/cQoYICCzCCAgcGCSqG
# SIb3DQEJBjGCAfgwggH0AgEBMHIwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5
# bWFudGVjIENvcnBvcmF0aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1w
# aW5nIFNlcnZpY2VzIENBIC0gRzICEA7P9DjI/r81bgTYapgbGlAwCQYFKw4DAhoF
# AKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDEyNTA3NDAxMVowIwYJKoZIhvcNAQkEMRYEFLU4kSFUNkfR27IzgoG1Cb+1ZjfM
# MA0GCSqGSIb3DQEBAQUABIIBACJxzHcWUO7Qq99eKz0vI3sy1MxR7BRBZytCuIDU
# iFC3JbowH/TOJ86wdbvSTNUrW5W17mDRYKpdyxO8MmMkhPQkqZ8+hsgtZs72ohIo
# xfHwKVMEvNnDCjUbHZ/YzH867AErYhQhHqWsJG7FdnqfaSwru3qG12sQAwwdeWjp
# o3bohIZU4z62I/QPONaKY6c7DxovMJ2mz2NbDQGprcXKENfiv0LwBDdQYAaM76k6
# h/Eu78PZRzGzX6CFSO9+hYSnA2BVpqdbr12zDe1N5Ry+tjxxpUOf3gjek0tARzgO
# qEHhjeaNfGrLMeUMmwWkyp6rBjZ5diYLUOLWY+M2tdxBH4o=
# SIG # End signature block
