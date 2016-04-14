
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
# MIIXpAYJKoZIhvcNAQcCoIIXlTCCF5ECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9XlSoJavLvaPJnjOLgPPlA53
# hDegghLKMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# BBSphPDVFuhyyOCHyjpEapDz+LT+ODANBgkqhkiG9w0BAQEFAASCAQB3BJKFfVF/
# PugFY9CMYjSS9ld4sgKIwxXgFrf1JLCWkbaseb1anCuH3Bh+3GsyeRiiHkSrNxOo
# UuhARyrQLG7p00F3Cr6NRiH11BSrhlcXBU7UpPA6SFcT/udTRkcFsns0tsh76yL/
# ESxcibOZgAl5D+aazGtlb7u/R8+cIZOhtQVp1V3jAhh2Q2W89Wy9xktdT47h37OZ
# U2cp4u63GJYDMqPI8zornPcycrYpd+uJv3Hh5nLzRXdS2pf977P1sUxcLR9YxQsH
# ocpXihrulSAy3b/r42djQpUOwFbcYa6bu2aw02foxYMjHRClRxsCWGh8Y3XjRdXd
# bjmYPVubbWrxoYICCzCCAgcGCSqGSIb3DQEJBjGCAfgwggH0AgEBMHIwXjELMAkG
# A1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTAwLgYDVQQD
# EydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBIC0gRzICEA7P9DjI
# /r81bgTYapgbGlAwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0B
# BwEwHAYJKoZIhvcNAQkFMQ8XDTE2MDQwODExMzczOVowIwYJKoZIhvcNAQkEMRYE
# FJ7kJ4/Ycb4XotinnaKP0OP9uJjWMA0GCSqGSIb3DQEBAQUABIIBAFzVtIKY9x6l
# rG3cQbEtJmvA+jdeGMznQZNkZRGFwjYMUPcRa80RWUmJw/vMl6xbfP8p4Jqmptgo
# zungtF6GVEfQ6G8rvdjNJ+E1FDr/ytm64SVQz3evK5e/QDNVKjgFTO3YmiYWNd+M
# 968NDs11+VJYz5+IlulI2ZCAq9XH56cDhoN91ALdDnTcFxdddo7Lznppj1mRBZhV
# 8lOIVTUdGB8jnBF51f/dkPmSgrq33922SaccAwwKcH57p6RGHLpfZ72ClVJkd5bZ
# Gsvo8XvNtcXXT5kxMdSR6d/fPPj1qIUAaW99nHHZksltidnhI80AEZHHG1xHPrSv
# jDZ+3wgmfsc=
# SIG # End signature block
