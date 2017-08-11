Param (
	[Parameter(Mandatory=$true)]
	[string]$ModuleName,
	
	[Parameter(Mandatory=$true)]
	[string]$Version
)

# Update module version numbers
Write-Output "Setting module version..."
[xml]$nuspec = Get-Content ".\$ModuleName.nuspec"
$nuspec.package.metadata.version = $Version
$nuspec.Save( "$PSScriptRoot\$ModuleName.nuspec" )

$verString = "ModuleVersion = '1.0'"
$manifest = Get-Content ".\$ModuleName.psd1"
$manifest[ $manifest.IndexOf($verString)] = "ModuleVersion = '$Version'"
$manifest | Out-File ".\$ModuleName.psd1"

# Ensure module dependencies are present
Write-Output "Ensuring module dependencies are available..."
foreach ( $module in $nuspec.package.metadata.dependencies.dependency ) {
	$modName = $module.id
	$modVersion = $module.version
	Write-Host "Looking for $modName version $modVersion or higher..."
	
	$bestVersion = ( Get-Module -Name $modName -ListAvailable ).version | Sort-Object -Descending | Select-Object -First 1
	if ( $bestVersion -ge $modVersion ) {
		Write-Host "Found version $bestVersion!"
	} else {
		Write-Host "Attempting to install $modName version $modVersion..."
		Install-Module -Name $modName -MinimumVersion $modVersion -Scope CurrentUser -Force -Repository vbps
	}
}

# Force import the local module before executing the tests
Write-Output "Importing $moduleName..."
Import-Module "$PSScriptRoot\$ModuleName.psd1" -Force -Verbose

# Output the current function set for the module
Get-Command -Module $ModuleName

Write-Output "Executing tests..."
$testResults = Invoke-Pester -OutputFile Test.xml -OutputFormat NUnitXml -CodeCoverage (Get-ChildItem -Path $PSScriptRoot\*.ps1 -Exclude "*.Tests.*","Invoke-BuildTests.ps1","_ClientTests.ps1" -Recurse ).FullName -PassThru
Write-Output "##teamcity[buildStatisticValue key='CodeCoverageAbsLTotal' value='$($testResults.CodeCoverage.NumberOfCommandsAnalyzed)']"
Write-Output "##teamcity[buildStatisticValue key='CodeCoverageAbsLCovered' value='$($testResults.CodeCoverage.NumberOfCommandsExecuted)']"