# List of paths to look for logs.
$UserTemp = [System.Environment]::GetEnvironmentVariable('TEMP','User')
$SystemTemp = [System.Environment]::GetEnvironmentVariable('TEMP','Machine')
$LogToCollect = "$UserTemp", "$SystemTemp", "$env:ProgramData\PatchMyPCIntuneLogs\", "$env:ProgramData\Scappman\Logs\"

# List of log files to collect.
$logfiles = @()

try {
    # Collect all log files from the paths specified above.
    foreach($path in $LogToCollect){
        $logfiles += Get-ChildItem $path -Recurse -Filter "*.log"
    }
} catch {
    # If we can't collect the logs, exit with an error.
    Write-Error "Unable to search for logs: $_"
    exit 1
}

# If we found any log files, exit with 1, otherwise exist with 0.
if($logfiles){
    exit 1
}else{
    exit 0
}


