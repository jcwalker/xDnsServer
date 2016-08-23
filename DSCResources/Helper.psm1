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

# Internal function to compare property values that are arrays
function Compare-Array
{
    [OutputType([System.Boolean])]
    [cmdletbinding()]
    param
    (
        [System.array]
        $ReferenceObject,

        [System.array]
        $DifferenceObject
    )

    if($ReferenceObject -ne $null -and $DifferenceObject -ne $null)
    {
        $compare = Compare-Object -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject

        if ($compare)
        {    
            return $false
        }
        else
        {    
            return $true
        }
    }
    elseIf ($ReferenceObject -eq $null -and $DifferenceObject -eq $null)
    {
        return $true
    }
    else
    {
        return $false
    }
}

# Internal function to remove all common parameters from $PSBoundParameters before it is passed to Set-CimInstance
function Remove-CommonParameter
{
    [OutputType([System.Collections.Hashtable])]
    [cmdletbinding()]
    param
    (
        [hashtable]
        $InputParameter
    )

    $inputClone = $InputParameter.Clone()
    $commonParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
    $commonParameters += [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

    foreach ($parameter in $InputParameter.Keys)
    {
        foreach ($commonParameter in $commonParameters)
        {
            if ($parameter -eq $commonParameter)
            {
                $inputClone.Remove($parameter)
            }
        }
    }

    $inputClone
}

# Internal function to add dot to end of string to match the output of Get-DnsServerRootHint
function Format-OutputDot
{
    param
    (
        [System.String]
        $InputString
    )

    $length = $InputString.Length

    $lastCharacter = $InputString.Substring(($length -1))

    if ($lastCharacter -eq '.')
    {
        return $InputString
    }
    else
    {
        return $InputString + '.'
    }
}

# Internal function to return IPAddresses in string format
function Get-IPAddressString
{
    param
    (
        [System.String]
        $NameServer
    )

    $IPs = @()
    $formatedNameServer = Format-OutputDot -InputString $NameServer    
    $getResult = Get-DnsServerRootHint
    $rootHintRecords = $getResult | Where-Object {$_.NameServer.RecordData.NameServer -eq $formatedNameServer}
    
    foreach ($record in $rootHintRecords.IPAddress)
    {
        if ($record.RecordType -eq 'AAAA')
        {
            $IpProperty = 'IPv6Address'
        }
        elseIf ($record.RecordType -eq 'A')
        {
            $IpProperty = 'IPv4Address'
        }

        $IPs += $record.RecordData.$IpProperty.IPAddressToString
    }

    return $IPs
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
