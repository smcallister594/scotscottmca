#Requires -Modules Microsoft.Graph

<#
.SYNOPSIS
    This function can be used to connect to Graph API and remove 
    specified permissions from a specific enterprise application
.PARAMETER EnterpriseAppName
    The name of the Enterprise App to remove permissions from.
.PARAMETER PermissionsToRemove
    The Permissions to remove from the Enterprise App.
    Comma separated
.EXAMPLE
    Remove-EnterpriseAppPermissions -EnterpriseAppName "Scappman" -PermissionsToRemove "Group.Read.All", "DeviceManagementManagedDevices.ReadWrite.All"
#>
param (
    [Parameter(Mandatory=$true)]
    [string]$EnterpriseAppName,
    [Parameter(Mandatory=$true)]
    [string[]]$PermissionsToRemove
)

try {
    Write-Host "Connecting to Microsoft Graph API" -ForegroundColor Yellow
    Connect-MgGraph -Scopes AppRoleAssignment.ReadWrite.All, Application.Read.All
    Write-Host "Successfully connected to Microsoft Graph API" -ForegroundColor Green    

    $enterpriseApp = Get-MgServicePrincipal -Filter "displayName eq '$EnterpriseAppName'"
    Write-Host "Successfully retrieved Enterprise App - $EnterpriseAppName" -ForegroundColor Green

    $graphSP = Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0000-c000-000000000000'"

    $appRoleAssignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $enterpriseApp.Id
    Write-Host "Successfully retrieved $($appRoleAssignments.count) AppRoleAssignments" -ForegroundColor Green

    #Get Role Id by Name
    $roleIds = @()
    $PermissionsToRemove | ForEach-Object{
        $permissionToRemove = $_
        $roleIds += $graphSP.AppRoles | Where-Object {$_.Value -eq $permissionToRemove} | Select-Object -ExpandProperty Id
    }
    Write-Host "Successfully retrieved $($roleIds.count) Role Ids" -ForegroundColor Green

    #Remove AppRoleAssignment by Id
    $roleIds | ForEach-Object{
        $roleId = $_
        $appRoleAssignments | ForEach-Object{
            $appRoleAssignment = $_
            Write-Host "Checking if RoleId $($roleId) matches AppRoleId $($appRoleAssignment.AppRoleId)" -ForegroundColor Yellow
            if($roleId -eq $appRoleAssignment.AppRoleId){
                Write-Host "Matched RoleId $($roleId) with AppRoleId $($appRoleAssignment.AppRoleId)" -ForegroundColor Green
                Write-Host "Removing AppRoleId $($appRoleAssignment.AppRoleId)" -ForegroundColor Green
                Remove-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $enterpriseApp.Id -AppRoleAssignmentId $_.Id
            }
        }
    }
}
catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
}