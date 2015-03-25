Function Upgrade() {
	$env:TERM =  "msys"
	$env:HOME = $env:USERPROFILE
	[Environment]::SetEnvironmentVariable("HOME", $env:HOME, "Machine") 
	[Environment]::SetEnvironmentVariable("TERM", $env:TERM, "Machine")
}

Function Downgrade() {
	$env:TERM =  ""
	$env:HOME = ""
	[Environment]::SetEnvironmentVariable("HOME", $env:HOME, "Machine") 
	[Environment]::SetEnvironmentVariable("TERM", $env:TERM, "Machine") 
}