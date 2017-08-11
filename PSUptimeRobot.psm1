# Variables

$global:urBaseUri = "https://api.uptimerobot.com/v2"

# Load Functions
foreach ( $function in (Get-ChildItem -Path $PSScriptRoot\Functions\*.ps1 -Exclude "*.Tests.*","_*") ) {
	"Loading function from " + $function.FullName
	. $function.FullName
}