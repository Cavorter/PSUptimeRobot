$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	$goodKey = "123456789-1234567890"
    $goodName = "New Alert Contact"
    $goodType = "WebHook"
    $goodValue = "http://not.actually.a.url/some/path"
	
	$goodParams = @{
        ApiKey = $goodKey
        Name = $goodName
        Type = $goodType
        Value = $goodValue
	}

	Mock -CommandName Invoke-RestMethod -MockWith { return $true }

	Context "Parameter Attributes" {
		$funtionDef = Get-Command -Name $functionName
		foreach ( $mandatory in $goodParams.Keys ) {
			It "the Mandatory attribute for the $mandatory parameter is $true" {
				$funtionDef.Parameters."$mandatory".ParameterSets.__AllParameterSets.IsMandatory | Should Be $true
			}
        }
		
		$testCases = @()
		$testCases += @{ param = "Type"; enumName = "UptimeRobotAlertContactType" }
		It -Name "the <param> parameter only accepts names from the <enumName> enumeration" -TestCases $testCases -test {
			Param( $param, $enumName )
			$values = [Enum]::GetNames( $enumName )
			$result = Compare-Object -DifferenceObject $funtionDef.Parameters."$param".Attributes.ValidValues -ReferenceObject $values
			$result | Should BeNullOrEmpty

		}

		$testCases = @()
		$testCases += @{ param = "Name"; value = "String" }
		$testCases += @{ param = "Type"; value = "String" }
		$testCases += @{ param = "Value"; value = "String" }
		It "the type for the <param> parameter is <value>" -TestCases $testCases {
			Param($param,$value)
			$funtionDef.Parameters."$param".ParameterType.Name | Should Be $value
		}
	}

	Context "Execution Test" {
		Test-Function @goodParams

		It "atempts to connect to the correct base uri of $urBaseUri" {
			Assert-MockCalled -CommandName Invoke-RestMethod -Scope "Context" -Exactly 1 -ExclusiveFilter { $Uri -like "$urBaseUri/*" }
		}

		It "atempts to connect to the correct rest endpoint of newAlertContact" {
			Assert-MockCalled -CommandName Invoke-RestMethod -Scope "Context" -Exactly 1 -ExclusiveFilter { $Uri -like "*/newAlertContact" }
		}

		It "passes the value of the ApiKey parameter" {
			Assert-MockCalled -CommandName Invoke-RestMethod -Scope "Context" -Exactly 1 -ExclusiveFilter { $Body -like "api_key=$goodKey&format=json*" }
		}

		$testCases = @()
		$testCases += @{ param = "Name"; bodyKey = "friendly_name"; value = $goodParams.ID }
		$testCases += @{ param = "Type"; bodyKey = "type"; value = ([UptimeRobotAlertContactType]::"$goodType").value__ }
		$testCases += @{ param = "Value"; bodyKey = "value"; value = $goodParams.Value }
		It "processes the value of the <param> parameter" -TestCases $testCases {
			Param($param,$bodyKey,$value)
			$comparison = "*&{0}={1}*" -f $bodyKey,$value
			Assert-MockCalled -CommandName Invoke-RestMethod -Scope "Context" -Exactly 1 -ExclusiveFilter { $Body -like $comparison }
		}
	}
}