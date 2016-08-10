# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
RoleNotFound = Please ensure that the PowerShell module for role {0} is installed
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

#Internal function to remove all common parameters from $PSBoundParameters before it is passed to Set-CimInstance
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

#Internal function to add dot to end of string to match the output of Get-DnsServerRootHint
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

#Internal function to return IPAddresses in string format
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
    $rootHintRecords = $getResult | where {$_.NameServer.RecordData.NameServer -eq $formatedNameServer}
    
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
