# List of paths to collect logs from.
$UserTemp = [System.Environment]::GetEnvironmentVariable('TEMP','User')
$SystemTemp = [System.Environment]::GetEnvironmentVariable('TEMP','Machine')
$LogToCollect = "$UserTemp", "$SystemTemp", "$env:ProgramData\PatchMyPCIntuneLogs\", "$env:ProgramData\Scappman\Logs\"

$logfiles = @()

# IME Log location
$IntuneManagementExtensionLogs = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\"

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

try{
    $logfiles | Copy-Item -Destination $IntuneManagementExtensionLogs -Force
}
catch{
    Write-Error "Unable to copy logs to $IntuneManagementExtensionLogs : $_"
    exit 1
}