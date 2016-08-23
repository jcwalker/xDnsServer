# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
RoleNotFound = Please ensure that the PowerShell module for role {0} is installed
WaitMessage=Waiting for "{0}" to complete on directory partition "{1}".
TaskComplete=Task took "{0}" seconds to complete.
WaitError=DNS directory partition task has not completed in 5 minutes.
'@
}

# Internal function to throw terminating error with specified errroCategory, errorId and errorMessage
function New-TerminatingError
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [String]$errorId,
        
        [Parameter(Mandatory)]
        [String]$errorMessage,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorCategory]$errorCategory
    )
    
    $exception = New-Object System.InvalidOperationException $errorMessage 
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $null
    throw $errorRecord
}

# Internal function to assert if the role specific module is installed or not
function Assert-Module
{
    [CmdletBinding()]
    param
    (
        [string]$moduleName = 'DnsServer'
    )

    if(! (Get-Module -Name $moduleName -ListAvailable))
    {
        $errorMsg = $($LocalizedData.RoleNotFound) -f $moduleName
        New-TerminatingError -errorId 'ModuleNotFound' -errorMessage $errorMsg -errorCategory ObjectNotFound
    }
}

# Internal funciton to wait for task completion performed on dns directory partition
function Wait-PartitionTask
{
    [CmdletBinding()]
    param
    (
        [System.String]
        $Name,

        [ValidateSet("Add","Remove","RemoveRegister","AddRegister")]
        [System.String]
        $Task
    )

    $i = 0
    $start = Get-Date
    $targetResource = Get-TargetResource -Name $Name -Ensure Present -Credential ([PSCredential]::Empty)

    if ($Task -eq 'Add')
    {
        $waitCondition = {$targetResource.Ensure -ne 'Present'}
    }
    elseif ($Task -eq 'Remove')
    {
        $waitCondition = {$targetResource.Ensure -ne 'Absent'}
    }
    elseIf ($Task -eq 'RemoveRegister')
    {    
        $waitCondition = {$targetResource.Register -ne $false}
    }
    elseIf ($Task -eq 'AddRegister')
    {
        $waitCondition = {$targetResource.Register -ne $true}
    }
    
    while ($waitCondition.Invoke())
    {
        $i++
        if ($i -gt 30)
        {
            throw "$($LocalizedData.WaitError)"
        }
        # Bounce DNS service every 5 loops
        if ($i%5 -eq 0)
        {
            Restart-Service DNS -Force
        }
        
        $targetResource = Get-TargetResource -Name $Name -Ensure Present -Credential ([PSCredential]::Empty)
        Write-Verbose -Message ($LocalizedData.WaitMessage -f $Task,$Name)
        Start-Sleep -Seconds 10
    }

    $timeSpan = New-TimeSpan -Start $start -End (Get-Date)
 
    Write-Verbose -Message ($LocalizedData.TaskComplete -f $($timeSpan.Seconds))   
}
