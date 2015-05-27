param(
	[int]$patchLevel
)

function LoadDefaultFunctions {
	. "support\default.ps1"
}

function AssertIsElevated()
{
	If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
	    [Security.Principal.WindowsBuiltInRole] "Administrator"))

	{
	    Write-Warning "You do not have the administrative rights required to run this command!`nPlease re-run this script as an Administrator/Elevated!"
	    Break
	}
}

if(-not $PSBoundParameters.ContainsKey('patchLevel')) {
	$patchLevel =  [int]($(ls patches\0* | sort-object -property Name -descending)[0].Name.substring(0,4))
	write-output "Default patchlevel: ${patchLevel}"
}

$configFile = "$($env:USERPROFILE)\patchwork.config"

write-output "`n------ PATCHWORK MIGRATION ------"
AssertIsElevated

if(!(Test-Path $configFile)) {
  copy support\template.config $env:USERPROFILE\patchwork.config
  write-output "Setting up initial settings file..."
}

[xml]$config = Get-Content $configFile


write-output "Current version: $($config.patchwork.currentPatchLevel)"
write-output "Target version: ${patchLevel}" 

if($patchLevel -lt $config.patchwork.currentPatchLevel) {
	# Downgrade
	foreach($patch in $(ls patches\0* | sort-object -property Name -descending)) {
		$patchVersion = [int]$patch.Name.substring(0, 4)
		
		if($patchVersion -gt $config.patchwork.currentPatchLevel) {
			continue
		}
		
		if($patchVersion -eq $patchLevel) {
			break;
		}
	
		$nextVersion = $patchVersion - 1
	
		$result = New-Object PSObject
		$result | Add-Member NoteProperty Task("Downgrading")
		$result | Add-Member NoteProperty Version("${patchVersion} -> ${nextVersion}")
		$result | Add-Member NoteProperty Using($patch.Name)
		
		LoadDefaultFunctions
		
		. "patches\$($patch.Name)"
		Downgrade
		$result | Add-Member NoteProperty Status("OK")
		Write-Output $result
		$config.patchwork.currentPatchLevel = [string]$nextVersion
		$config.Save($configFile)
	} 

	write-output "`nCurrent version: $($config.patchwork.currentPatchLevel)"
	
} elseif ($patchLevel -gt $config.patchwork.currentPatchLevel) {
	# Upgrade
	foreach ($patch in $(ls patches\0* | sort-object -property Name)) {
		$patchVersion = [int]$patch.Name.substring(0, 4)
	
		if(-not ($patchVersion -gt $config.patchwork.currentPatchLevel)) {
			continue
		}
		
		if($patchVersion -gt $patchLevel) {
			break
		}
		
		$previousVersion = $patchVersion - 1
	
		$result = New-Object PSObject
		$result | Add-Member NoteProperty Task("Upgrading")
		$result | Add-Member NoteProperty Version("${previousVersion} -> ${patchVersion}")
		$result | Add-Member NoteProperty Using($patch.Name)
		
		LoadDefaultFunctions
		
		. "patches\$($patch.Name)"
		Upgrade
		$result | Add-Member NoteProperty Status("OK")
		Write-Output $result
		$config.patchwork.currentPatchLevel = [string]$patchVersion
		$config.Save($configFile)
	}
	
	write-output "`nCurrent version: $($config.patchwork.currentPatchLevel)"
} else {
	write-output "`nNothing to do."
}

