Function Upgrade() {
	Push-Location
	Set-Location HKCU:
	if (-Not (Test-Path ".\Software\Microsoft\Command Processor")) {
		New-Item -Path ".\Software\Microsoft" -Name "Command Processor"
	}

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Command Processor" -Name AutoRun -Value """$env:USERPROFILE\autorun.cmd"""
	Pop-Location

	copy support\autorun.cmd $env:USERPROFILE
}

Function Downgrade() {
	Push-Location
	Set-Location HKCU:
	if (-Not (Test-Path ".\Software\Microsoft\Command Processor")) {
		New-Item -Path ".\Software\Microsoft" -Name "Command Processor"
	}

	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Command Processor" -Name AutoRun
	Pop-Location
}