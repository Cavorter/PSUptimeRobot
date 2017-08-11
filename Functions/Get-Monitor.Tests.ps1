$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	$goodKey = "123456789-1234567890"
	$goodId = "123"
	$goodType = "HTTP"
	$goodStatus = "Up"
	
	$goodParams = @{ ApiKey = $goodKey }
	$optionalParams = @{
		ID = $goodId
		Type = $goodType
		Status = $goodStatus
		Logs = [switch]$true
		ResponseTimes = [switch]$true
		AlertContacts = [switch]$true
	}

	Mock -CommandName Invoke-RestMethod -MockWith { return $true }

	Context "Parameter Attributes" {
		$funtionDef = Get-Command -Name $functionName
		foreach ( $mandatory in $goodParams.Keys ) {
			It "the Mandatory attribute for the $mandatory parameter is $true" {
				$funtionDef.Parameters."$mandatory".ParameterSets.__AllParameterSets.IsMandatory | Should Be $true
			}
        }
		
		foreach ( $param in $optionalParams.Keys ) {
			It "the Mandatory attribute for the $param parameter is $false" {
				$funtionDef.Parameters."$param".ParameterSets.__AllParameterSets.IsMandatory | Should Be $false
			}
		}

		$testCases = @()
		$testCases += @{ param = "Type"; enumName = "UptimeRobotMonitorType" }
		$testCases += @{ param = "Status"; enumName = "UptimeRobotMonitorStatus" }
		It -Name "the <param> parameter only accepts names from the <enumName> enumeration" -TestCases $testCases -test {
			Param( $param, $enumName )
			$values = [Enum]::GetNames( $enumName )
			$result = Compare-Object -DifferenceObject $funtionDef.Parameters."$param".Attributes.ValidValues -ReferenceObject $values
			$result | Should BeNullOrEmpty

		}

		$boolParams = @( "Logs" , "ResponseTimes" , "AlertContacts" )
		foreach ( $param in $boolParams ) {
			It "the $param parameter is a switch" {
				$funtionDef.Parameters."$param".SwitchParameter | Should Be $true
			}
		}

		$testCases = @()
		$testCases += @{ param = "ID"; value = "Int32[]" }
		$testCases += @{ param = "Type"; value = "String[]" }
		$testCases += @{ param = "Status"; value = "String[]" }
		It "the type for the <param> parameter is <value>" -TestCases $testCases {
			Param($param,$value)
			$funtionDef.Parameters."$param".ParameterType.Name | Should Be $value
		}
	}

	Context "No Optional Parameters" {
		Test-Function @goodParams

		It "atempts to connect to the correct base uri of $urBaseUri" {
			Assert-MockCalled -CommandName Invoke-RestMethod -Scope "Context" -Exactly 1 -ExclusiveFilter { $Uri -like "$urBaseUri/*" }
		}

		It "atempts to connect to the correct rest endpoint of getMonitors" {
			Assert-MockCalled -CommandName Invoke-RestMethod -Scope "Context" -Exactly 1 -ExclusiveFilter { $Uri -like "*/getMonitors" }
		}

		It "passes the value of the ApiKey parameter" {
			Assert-MockCalled -CommandName Invoke-RestMethod -Scope "Context" -Exactly 1 -ExclusiveFilter { $Body -eq "api_key=$goodKey&format=json" }
		}
	}

	Context "With Optional Parameters" {
		Test-Function @goodParams @optionalParams

		$testCases = @()
		$testCases += @{ param = "ID"; bodyKey = "monitors"; value = $optionalParams.ID }
		$testCases += @{ param = "Type"; bodyKey = "types"; value = ([UptimeRobotMonitorType]::"$goodType").value__ }
		$testCases += @{ param = "Status"; bodyKey = "statuses"; value = ([UptimeRobotMonitorStatus]::"$goodStatus").value__ }
		$testCases += @{ param = "Logs"; bodyKey = "logs"; value = [int]$optionalParams.Logs.ToBool() }
		$testCases += @{ param = "ResponseTimes"; bodyKey = "response_times"; value = [int]$optionalParams.Logs.ToBool() }
		$testCases += @{ param = "AlertContacts"; bodyKey = "alert_contacts"; value = [int]$optionalParams.Logs.ToBool() }
		It "processes the value of the <param> parameter" -TestCases $testCases {
			Param($param,$bodyKey,$value)
			$comparison = "*&{0}={1}*" -f $bodyKey,$value
			Assert-MockCalled -CommandName Invoke-RestMethod -Scope "Context" -Exactly 1 -ExclusiveFilter { $Body -like $comparison }
		}
	}

	Context "With Optional Parameters" {
		$optionalParams.ID = @( 123 , 234 , 345 )
		$optionalParams.Type = @( "HTTP" , "Port" )
		$optionalParams.Status = @( "Up" , "Down" )
		Test-Function @goodParams @optionalParams

		$testCases = @()
		$testCases += @{ param = "ID"; bodyKey = "monitors"; value = $optionalParams.ID -join '-' }
		$testCases += @{ param = "Type"; bodyKey = "types"; value = $optionalParams.Type.Foreach({ ([UptimeRobotMonitorType]::"$_").value__ }) -join '-' }
		$testCases += @{ param = "Status"; bodyKey = "statuses"; value = $optionalParams.Status.Foreach({ ([UptimeRobotMonitorStatus]::"$_").value__ }) -join '-' }
		It "processes the value of the <param> parameter" -TestCases $testCases {
			Param($param,$bodyKey,$value)
			$comparison = "*&{0}={1}*" -f $bodyKey,$value
			Assert-MockCalled -CommandName Invoke-RestMethod -Scope "Context" -Exactly 1 -ExclusiveFilter { $Body -like $comparison }
		}
	}
}