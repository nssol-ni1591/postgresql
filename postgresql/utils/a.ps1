#

# dummy variable
$env:DEBUG_VAL	= "created_by_gohdo"

$NAMES	  = "LOGONSERVER", "OS", "USERPROFILE", "DEBUG_VAL"

# C:\Users\<username>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# . "$home\.aws.ps1"
$AWS_PS1  = "$home\.aws.ps1"
# ${HOME}/.bach_profile or .profile
# . "$home\.aws.bash"
$AWS_BASH = "$home\.aws.bash"

$HASH = @{}


function Create-AuthVariable {
	foreach($n in $NAMES) {
		$v = [Environment]::GetEnvironmentVariable("$n")
		$HASH[$n] = $v
		echo "> `$HASH[$n]=$v"
	}
	return
}

function Setup-ProfileFile {
	echo "update AWS files ..."

	Clear-Content $AWS_PS1
	Clear-Content $AWS_BASH
	foreach ($k in $HASH.keys) {
		$v = $hash[$k]
		echo "> $k=$v"
# format: poershell
		echo "`$env:$k=`"$v`""  | Out-File -FilePath $AWS_PS1  -Encoding ascii -Append
# format: bash
		echo "export $k=`"$v`"" | Out-File -FilePath $AWS_BASH -Encoding ascii -Append
	}
	echo "done"
	return
}

function main {
	if (test-path $AWS_PS1) {
		$time = [datetime]::Now.AddDays(-1)
#		$time = [datetime]::Now.AddMinutes(-1)
#		$time = [datetime]::Now
		$stamp = ($(Get-ItemProperty $AWS_PS1).LastWriteTime)
		echo "diff time: $time"
		echo "timestamp: $stamp"

		if ($time -lt $stamp) {
			return
		}
	}
	Create-AuthVariable
	Setup-ProfileFile
	return
}

main
