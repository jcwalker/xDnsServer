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
        $ZoneName
    )

    $dnsZoneAgingResult = Get-DnsServerZoneAging -ZoneName $ZoneName

   if($dnsZoneAgingResult.ScavengeServers)
   {
       $scavengeResult = @($dnsZoneAgingResult.ScavengeServers)
   }
   else
   {
       $scavengeResult = $null    
   }
    $returnValue = @{
        ZoneName          = $dnsZoneAgingResult.ZoneName
        AgingEnabled      = $dnsZoneAgingResult.AgingEnabled
        ScavengeServers   = $scavengeResult
        RefreshInterval   = $dnsZoneAgingResult.RefreshInterval
        NoRefreshInterval = $dnsZoneAgingResult.NoRefreshInterval
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
        $ZoneName,

        [System.Boolean]
        $AgingEnabled,

        [System.String[]]
        $ScavengeServers,

        [System.String]
        $RefreshInterval,

        [System.String]
        $NoRefreshInterval
    )
    
    $PSBoundParameters.Add('ErrorAction','Stop')

    Set-DnsServerZoneAging @PSBoundParameters
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ZoneName,

        [System.Boolean]
        $AgingEnabled,

        [System.String[]]
        $ScavengeServers,

        [System.String]
        $RefreshInterval,

        [System.String]
        $NoRefreshInterval
    )

    $dnsZoneAgingResult = Get-DnsServerZoneAging -ZoneName $ZoneName

    if ($PSBoundParameters.ContainsKey('AgingEnabled'))
    {
        if ($PSBoundParameters.AgingEnabled -ne $dnsZoneAgingResult.AgingEnabled)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'AgingEnabled',
                $PSBoundParameters.AgingEnabled,
                $dnsZoneAgingResult.AgingEnabled
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('ScavengeServers'))
    {
        $scanvengeServersMatch = Compare-Array $PSBoundParameters.ScavengeServers $dnsZoneAgingResult.ScavengeServers

        if ($scanvengeServersMatch -eq $false)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'ScavengeServers',
                ($PSBoundParameters.ScavengeServers -join ',') ,
                ($dnsZoneAgingResult.ScavengeServers -join ',')
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('RefreshInterval'))
    {
        if ($PSBoundParameters.RefreshInterval -ne $dnsZoneAgingResult.RefreshInterval)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'RefreshInterval',
                $PSBoundParameters.RefreshInterval,
                $dnsZoneAgingResult.RefreshInterval
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('NoRefreshInterval'))
    {
        if ($PSBoundParameters.NoRefreshInterval -ne $dnsZoneAgingResult.NoRefreshInterval)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'NoRefreshInterval',
                $PSBoundParameters.NoRefreshInterval,
                $dnsServerInstance.NoRefreshInterval
            )

            return $false
        }
    }
    
    # If the code made it this far all properties are in a desired state
    return $true
}


Export-ModuleMember -Function *-TargetResource

