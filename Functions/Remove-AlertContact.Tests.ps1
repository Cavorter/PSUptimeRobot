$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	$goodKey = "123456789-1234567890"
	$goodId = "123"
	
	$goodParams = @{ ApiKey = $goodKey; ID = $goodId }

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
		$testCases += @{ param = "ID"; value = "Int32" }
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

		It "atempts to connect to the correct rest endpoint of getAlertContacts" {
			Assert-MockCalled -CommandName Invoke-RestMethod -Scope "Context" -Exactly 1 -ExclusiveFilter { $Uri -like "*/deleteAlertContact" }
		}

		It "passes the value of the ApiKey parameter" {
			Assert-MockCalled -CommandName Invoke-RestMethod -Scope "Context" -Exactly 1 -ExclusiveFilter { $Body -like "api_key=$goodKey&format=json*" }
        }
        
 		It "processes the value of the ID parameter" {
			$comparison = "*&{0}={1}" -f "id",$goodId
			Assert-MockCalled -CommandName Invoke-RestMethod -Scope "Context" -Exactly 1 -ExclusiveFilter { $Body -like $comparison }
		}
	}
}