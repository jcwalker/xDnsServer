Import-Module $PSScriptRoot\..\Helper.psm1 -Verbose:$false

data LocalizedData
{
   ConvertFrom-StringData -StringData @'
NotInDesiredState="{0}" not in desired state. Expected: "{1}" Actual: "{2}".
'@ 

}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $NameServer,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    $formatedNameServer = Format-OutputDot -InputString $NameServer
    $rootHint = Get-DnsServerRootHint | Where-Object {$_.NameServer.RecordData.NameServer -eq $formatedNameServer}
    
    $returnValue = @{
        NameServer = $NameServer
        IpAddress  = @(Get-IPAddressString -NameServer $NameServer)
        Ensure     = if ($rootHint) { 'Present' } else { 'Absent' };
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $NameServer,

        [System.String[]]
        $IpAddress,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    $PSBoundParameters.Remove('Ensure')
    $targetResource = Get-TargetResource -NameServer $NameServer -Ensure $Ensure

    if ($Ensure -eq 'Present')
    {
        if ($targetResource.Ensure -eq 'Absent')
        {
            Add-DnsServerRootHint @PSBoundParameters
        }
        else
        {
            # We assume if the Ensure is present the only thing that is not in a desired
            # state is the IPAddress
            Remove-DnsServerRootHint -NameServer $NameServer -Force
            Add-DnsServerRootHint @PSBoundParameters
        }
    }
    else
    {
        Remove-DnsServerRootHint -NameServer $NameServer -Force
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $NameServer,

        [System.String[]]
        $IpAddress,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    $targetResource = Get-TargetResource -NameServer $NameServer -Ensure $Ensure

    if ($Ensure -ne $targetResource.Ensure)
    {
        Write-Verbose ($LocalizedData.NotInDesiredState -f 'Ensure', $targetResource.Ensure, $Ensure);
        return $false
    }

    if ($PSBoundParameters.ContainsKey('IpAddress'))
    {
        $ipAddressMatch = Compare-Array $IpAddress $targetResource.IpAddress
        if ($ipAddressMatch -eq $false)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'Forwarders',
                ($PSBoundParameters.IpAddress -join ',') ,
                ($targetResource.IpAddress -join ',')
            )

            return $false
        }
    }

    #if the code made it this far the server is in a desired state
    return $true

}


Export-ModuleMember -Function *-TargetResource

