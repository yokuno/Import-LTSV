Param(
	[System.String]$Path,
	[System.String]$Encoding = "UTF8"
)

Import-Module $PSScriptRoot\Import-LTSV.psm1 -Force
Import-LTSV $Path $Encoding