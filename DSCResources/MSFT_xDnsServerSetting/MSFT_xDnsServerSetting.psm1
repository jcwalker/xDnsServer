Import-Module $PSScriptRoot\..\Helper.psm1 -Verbose:$false

data LocalizedData
{
   ConvertFrom-StringData -StringData @'
NotInDesiredState="{0}" not in desired state. Expected: "{1}" Actual: "{2}".
DnsClassNotFound=MicrosoftDNS_Server class not found. DNS role is not installed.
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
        $Name
    )

    try
    {
        $dnsServerInstance = Get-CimInstance -Namespace root\MicrosoftDNS -ClassName MicrosoftDNS_Server -ErrorAction Stop
    }
    catch
    {
        if ($_.Exception.Message -match "Invalid namespace")
        {
            throw ($localizedData.DnsClassNotFound)
        }
        else
        {
            throw $_
        }
    }
    
    $returnValue = @{
        Name = $Name
        AddressAnswerLimit = $dnsServerInstance.AddressAnswerLimit
        AllowUpdate = $dnsServerInstance.AllowUpdate
        AutoCacheUpdate = $dnsServerInstance.AutoCacheUpdate
        AutoConfigFileZones = $dnsServerInstance.AutoConfigFileZones
        BindSecondaries = $dnsServerInstance.BindSecondaries
        BootMethod = $dnsServerInstance.BootMethod
        DefaultAgingState = $dnsServerInstance.DefaultAgingState
        DefaultNoRefreshInterval = $dnsServerInstance.DefaultNoRefreshInterval
        DefaultRefreshInterval = $dnsServerInstance.DefaultRefreshInterval
        DisableAutoReverseZones = $dnsServerInstance.DisableAutoReverseZones
        DisjointNets = $dnsServerInstance.DisjointNets
        DsAvailable = $dnsServerInstance.DsAvailable
        DsPollingInterval = $dnsServerInstance.DsPollingInterval
        DsTombstoneInterval = $dnsServerInstance.DsTombstoneInterval
        EDnsCacheTimeout = $dnsServerInstance.EDnsCacheTimeout
        EnableDirectoryPartitions = $dnsServerInstance.EnableDirectoryPartitions
        EnableDnsSec = $dnsServerInstance.EnableDnsSec
        EnableEDnsProbes = $dnsServerInstance.EnableEDnsProbes
        EventLogLevel = $dnsServerInstance.EventLogLevel
        ForwardDelegations = $dnsServerInstance.ForwardDelegations
        Forwarders = $dnsServerInstance.Forwarders
        ForwardingTimeout = $dnsServerInstance.ForwardingTimeout
        IsSlave = $dnsServerInstance.IsSlave
        ListenAddresses = $dnsServerInstance.ListenAddresses
        LocalNetPriority = $dnsServerInstance.LocalNetPriority
        LogFileMaxSize = $dnsServerInstance.LogFileMaxSize
        LogFilePath = $dnsServerInstance.LogFilePath
        LogIPFilterList = $dnsServerInstance.LogIPFilterList
        LogLevel = $dnsServerInstance.LogLevel
        LooseWildcarding = $dnsServerInstance.LooseWildcarding
        MaxCacheTTL = $dnsServerInstance.MaxCacheTTL
        MaxNegativeCacheTTL = $dnsServerInstance.MaxNegativeCacheTTL
        NameCheckFlag = $dnsServerInstance.NameCheckFlag
        NoRecursion = $dnsServerInstance.NoRecursion
        RecursionRetry = $dnsServerInstance.RecursionRetry
        RecursionTimeout = $dnsServerInstance.RecursionTimeout
        RoundRobin = $dnsServerInstance.RoundRobin
        RpcProtocol = $dnsServerInstance.RpcProtocol
        ScavengingInterval = $dnsServerInstance.ScavengingInterval
        SecureResponses = $dnsServerInstance.SecureResponses
        SendPort = $dnsServerInstance.SendPort
        StrictFileParsing = $dnsServerInstance.StrictFileParsing
        UpdateOptions = $dnsServerInstance.UpdateOptions
        WriteAuthorityNS = $dnsServerInstance.WriteAuthorityNS
        XfrConnectTimeout = $dnsServerInstance.XfrConnectTimeout
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
        $Name,

        [System.UInt32]
        $AddressAnswerLimit,

        [System.UInt32]
        $AllowUpdate,

        [System.Boolean]
        $AutoCacheUpdate,

        [System.UInt32]
        $AutoConfigFileZones,

        [System.Boolean]
        $BindSecondaries,

        [System.UInt32]
        $BootMethod,

        [System.Boolean]
        $DefaultAgingState,

        [System.UInt32]
        $DefaultNoRefreshInterval,

        [System.UInt32]
        $DefaultRefreshInterval,

        [System.Boolean]
        $DisableAutoReverseZones,

        [System.Boolean]
        $DisjointNets,

        [System.Boolean]
        $DsAvailable,

        [System.UInt32]
        $DsPollingInterval,

        [System.UInt32]
        $DsTombstoneInterval,

        [System.UInt32]
        $EDnsCacheTimeout,

        [System.Boolean]
        $EnableDirectoryPartitions,

        [System.UInt32]
        $EnableDnsSec,

        [System.Boolean]
        $EnableEDnsProbes,

        [System.UInt32]
        $EventLogLevel,

        [System.UInt32]
        $ForwardDelegations,

        [System.String[]]
        $Forwarders,

        [System.UInt32]
        $ForwardingTimeout,

        [System.Boolean]
        $IsSlave,

        [System.String[]]
        $ListenAddresses,

        [System.Boolean]
        $LocalNetPriority,

        [System.UInt32]
        $LogFileMaxSize,

        [System.String]
        $LogFilePath,

        [System.String[]]
        $LogIPFilterList,

        [System.UInt32]
        $LogLevel,

        [System.Boolean]
        $LooseWildcarding,

        [System.UInt32]
        $MaxCacheTTL,

        [System.UInt32]
        $MaxNegativeCacheTTL,

        [System.UInt32]
        $NameCheckFlag,

        [System.Boolean]
        $NoRecursion,

        [System.UInt32]
        $RecursionRetry,

        [System.UInt32]
        $RecursionTimeout,

        [System.Boolean]
        $RoundRobin,

        [System.Int16]
        $RpcProtocol,

        [System.UInt32]
        $ScavengingInterval,

        [System.Boolean]
        $SecureResponses,

        [System.UInt32]
        $SendPort,

        [System.Boolean]
        $StrictFileParsing,

        [System.UInt32]
        $UpdateOptions,

        [System.Boolean]
        $WriteAuthorityNS,

        [System.UInt32]
        $XfrConnectTimeout
    )

    $PSBoundParameters.Remove('Name')
    $dnsProperties = Remove-CommonParameter -InputParameter $PSBoundParameters 

    $dnsServerInstance = Get-CimInstance -Namespace root\MicrosoftDNS -ClassName MicrosoftDNS_Server

    try
    {
        Set-CimInstance -InputObject $dnsServerInstance -Property $dnsProperties -ErrorAction Stop
    }
    catch
    {
        throw $_
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
        $Name,

        [System.UInt32]
        $AddressAnswerLimit,

        [System.UInt32]
        $AllowUpdate,

        [System.Boolean]
        $AutoCacheUpdate,

        [System.UInt32]
        $AutoConfigFileZones,

        [System.Boolean]
        $BindSecondaries,

        [System.UInt32]
        $BootMethod,

        [System.Boolean]
        $DefaultAgingState,

        [System.UInt32]
        $DefaultNoRefreshInterval,

        [System.UInt32]
        $DefaultRefreshInterval,

        [System.Boolean]
        $DisableAutoReverseZones,

        [System.Boolean]
        $DisjointNets,

        [System.Boolean]
        $DsAvailable,

        [System.UInt32]
        $DsPollingInterval,

        [System.UInt32]
        $DsTombstoneInterval,

        [System.UInt32]
        $EDnsCacheTimeout,

        [System.Boolean]
        $EnableDirectoryPartitions,

        [System.UInt32]
        $EnableDnsSec,

        [System.Boolean]
        $EnableEDnsProbes,

        [System.UInt32]
        $EventLogLevel,

        [System.UInt32]
        $ForwardDelegations,

        [System.String[]]
        $Forwarders,

        [System.UInt32]
        $ForwardingTimeout,

        [System.Boolean]
        $IsSlave,

        [System.String[]]
        $ListenAddresses,

        [System.Boolean]
        $LocalNetPriority,

        [System.UInt32]
        $LogFileMaxSize,

        [System.String]
        $LogFilePath,

        [System.String[]]
        $LogIPFilterList,

        [System.UInt32]
        $LogLevel,

        [System.Boolean]
        $LooseWildcarding,

        [System.UInt32]
        $MaxCacheTTL,

        [System.UInt32]
        $MaxNegativeCacheTTL,

        [System.UInt32]
        $NameCheckFlag,

        [System.Boolean]
        $NoRecursion,

        [System.UInt32]
        $RecursionRetry,

        [System.UInt32]
        $RecursionTimeout,

        [System.Boolean]
        $RoundRobin,

        [System.Int16]
        $RpcProtocol,

        [System.UInt32]
        $ScavengingInterval,

        [System.Boolean]
        $SecureResponses,

        [System.UInt32]
        $SendPort,

        [System.Boolean]
        $StrictFileParsing,

        [System.UInt32]
        $UpdateOptions,

        [System.Boolean]
        $WriteAuthorityNS,

        [System.UInt32]
        $XfrConnectTimeout
    )

    try
    {
        $dnsServerInstance = Get-CimInstance -Namespace root\MicrosoftDNS -ClassName MicrosoftDNS_Server -ErrorAction Stop
    }
    catch
    {
        if ($_.Exception.Message -match "Invalid namespace")
        {
            throw ($localizedData.DnsClassNotFound)
        }
        else
        {
            throw $_
        }
    }    

    if ($PSBoundParameters.ContainsKey('AddressAnswerLimit'))
    {   
        if ($PSBoundParameters.AddressAnswerLimit -ne $dnsServerInstance.AddressAnswerLimit)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'AddressAnswerLimit',
                $PSBoundParameters.AddressAnswerLimit,
                $dnsServerInstance.AddressAnswerLimit
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('AllowUpdate'))
    {   
        if ($PSBoundParameters.AllowUpdate -ne $dnsServerInstance.AllowUpdate)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'AllowUpdate',
                $PSBoundParameters.AllowUpdate,
                $dnsServerInstance.AllowUpdate
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('AutoCacheUpdate'))
    {   
        if ($PSBoundParameters.AutoCacheUpdate -ne $dnsServerInstance.AutoCacheUpdate)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'AutoCacheUpdate',
                $PSBoundParameters.AutoCacheUpdate,
                $dnsServerInstance.AutoCacheUpdate
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('AutoConfigFileZones'))
    {   
        if ($PSBoundParameters.AutoConfigFileZones -ne $dnsServerInstance.AutoConfigFileZones)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'AutoConfigFileZones',
                $PSBoundParameters.AutoConfigFileZones,
                $dnsServerInstance.AutoConfigFileZones
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('BindSecondaries'))
    {   
        if ($PSBoundParameters.BindSecondaries -ne $dnsServerInstance.BindSecondaries)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'BindSecondaries',
                $PSBoundParameters.BindSecondaries,
                $dnsServerInstance.BindSecondaries
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('BootMethod'))
    {   
        if ($PSBoundParameters.BootMethod -ne $dnsServerInstance.BootMethod)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'BootMethod',
                $PSBoundParameters.BootMethod,
                $dnsServerInstance.BootMethod
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('DefaultAgingState'))
    {   
        if ($PSBoundParameters.DefaultAgingState -ne $dnsServerInstance.DefaultAgingState)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'BootMethod',
                $PSBoundParameters.DefaultAgingState,
                $dnsServerInstance.DefaultAgingState
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('DefaultNoRefreshInterval'))
    {   
        if ($PSBoundParameters.DefaultNoRefreshInterval -ne $dnsServerInstance.DefaultNoRefreshInterval)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'DefaultNoRefreshInterval',
                $PSBoundParameters.DefaultNoRefreshInterval,
                $dnsServerInstance.DefaultNoRefreshInterval
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('DefaultRefreshInterval'))
    {   
        if ($PSBoundParameters.DefaultRefreshInterval -ne $dnsServerInstance.DefaultRefreshInterval)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'DefaultRefreshInterval',
                $PSBoundParameters.DefaultRefreshInterval,
                $dnsServerInstance.DefaultRefreshInterval
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('DisableAutoReverseZones'))
    {   
        if ($PSBoundParameters.DisableAutoReverseZones -ne $dnsServerInstance.DisableAutoReverseZones)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'DisableAutoReverseZones',
                $PSBoundParameters.DisableAutoReverseZones,
                $dnsServerInstance.DisableAutoReverseZones
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('DisjointNets'))
    {   
        if ($PSBoundParameters.DisjointNets -ne $dnsServerInstance.DisjointNets)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'DisjointNets',
                $PSBoundParameters.DisjointNets,
                $dnsServerInstance.DisjointNets
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('DsAvailable'))
    {   
        if ($PSBoundParameters.DsAvailable -ne $dnsServerInstance.DsAvailable)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'DsAvailable',
                $PSBoundParameters.DsAvailable,
                $dnsServerInstance.DsAvailable
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('DsPollingInterval'))
    {   
        if ($PSBoundParameters.DsPollingInterval -ne $dnsServerInstance.DsPollingInterval)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'DsPollingInterval',
                $PSBoundParameters.DsPollingInterval,
                $dnsServerInstance.DsPollingInterval
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('DsTombstoneInterval'))
    {   
        if ($PSBoundParameters.DsTombstoneInterval -ne $dnsServerInstance.DsTombstoneInterval)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'DsTombstoneInterval',
                $PSBoundParameters.DsTombstoneInterval,
                $dnsServerInstance.DsTombstoneInterval
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('EDnsCacheTimeout'))
    {   
        if ($PSBoundParameters.EDnsCacheTimeout -ne $dnsServerInstance.EDnsCacheTimeout)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'EDnsCacheTimeout',
                $PSBoundParameters.EDnsCacheTimeout,
                $dnsServerInstance.EDnsCacheTimeout
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('EnableDirectoryPartitions'))
    {   
        if ($PSBoundParameters.EnableDirectoryPartitions -ne $dnsServerInstance.EnableDirectoryPartitions)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'EnableDirectoryPartitions',
                $PSBoundParameters.EnableDirectoryPartitions,
                $dnsServerInstance.EnableDirectoryPartitions
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('EnableDnsSec'))
    {   
        if ($PSBoundParameters.EnableDnsSec -ne $dnsServerInstance.EnableDnsSec)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'EnableDnsSec',
                $PSBoundParameters.EnableDnsSec,
                $dnsServerInstance.EnableDnsSec
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('EnableEDnsProbes'))
    {   
        if ($PSBoundParameters.EnableEDnsProbes -ne $dnsServerInstance.EnableEDnsProbes)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'EnableEDnsProbes',
                $PSBoundParameters.EnableEDnsProbes,
                $dnsServerInstance.EnableEDnsProbes
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('EventLogLevel'))
    {   
        if ($PSBoundParameters.EventLogLevel -ne $dnsServerInstance.EventLogLevel)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'EventLogLevel',
                $PSBoundParameters.EventLogLevel,
                $dnsServerInstance.EventLogLevel
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('ForwardDelegations'))
    {   
        if ($PSBoundParameters.ForwardDelegations -ne $dnsServerInstance.ForwardDelegations)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'ForwardDelegations',
                $PSBoundParameters.ForwardDelegations,
                $dnsServerInstance.ForwardDelegations
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('Forwarders'))
    {   
        $forwardersMatch = Compare-Array $PSBoundParameters.Forwarders $dnsServerInstance.Forwarders

        if ($forwardersMatch -eq $false)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'Forwarders',
                ($PSBoundParameters.Forwarders -join ',') ,
                ($dnsServerInstance.Forwarders -join ',')
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('ForwardingTimeout'))
    {   
        if ($PSBoundParameters.ForwardingTimeout -ne $dnsServerInstance.ForwardingTimeout)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'ForwardingTimeout',
                $PSBoundParameters.ForwardingTimeout,
                $dnsServerInstance.ForwardingTimeout
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('IsSlave'))
    {   
        if ($PSBoundParameters.IsSlave -ne $dnsServerInstance.IsSlave)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'IsSlave',
                $PSBoundParameters.IsSlave,
                $dnsServerInstance.IsSlave
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('ListenAddresses'))
    {   
        $listenAddressesMatch = Compare-Array $PSBoundParameters.ListenAddresses $dnsServerInstance.ListenAddresses

        if ($listenAddressesMatch -eq $false)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'ListenAddresses',
                ($PSBoundParameters.ListenAddresses -join ','),
                ($dnsServerInstance.ListenAddresses -join ',')
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('LocalNetPriority'))
    {   
        if ($PSBoundParameters.LocalNetPriority -ne $dnsServerInstance.LocalNetPriority)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'LocalNetPriority',
                $PSBoundParameters.LocalNetPriority,
                $dnsServerInstance.LocalNetPriority
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('LogFileMaxSize'))
    {   
        if ($PSBoundParameters.LogFileMaxSize -ne $dnsServerInstance.LogFileMaxSize)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'LogFileMaxSize',
                $PSBoundParameters.LogFileMaxSize,
                $dnsServerInstance.LogFileMaxSize
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('LogFilePath'))
    {   
        if ($PSBoundParameters.LogFilePath -ne $dnsServerInstance.LogFilePath)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'LogFilePath',
                $PSBoundParameters.LogFilePath,
                $dnsServerInstance.LogFilePath
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('LogIPFilterList'))
    {   
        $logIpFilterListMatch = Compare-Array $PSBoundParameters.LogIPFilterList $dnsServerInstance.LogIPFilterList

        if ($logIpFilterListMatch -eq $false)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'LogIPFilterList',
                ($PSBoundParameters.LogIPFilterList -join ','),
                ($dnsServerInstance.LogIPFilterList -join ',')
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('LogLevel'))
    {   
        if ($PSBoundParameters.LogLevel -ne $dnsServerInstance.LogLevel)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'LogLevel',
                $PSBoundParameters.LogLevel,
                $dnsServerInstance.LogLevel
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('LooseWildcarding'))
    {   
        if ($PSBoundParameters.LooseWildcarding -ne $dnsServerInstance.LooseWildcarding)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'LooseWildcarding',
                $PSBoundParameters.LooseWildcarding,
                $dnsServerInstance.LooseWildcarding
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('MaxCacheTTL'))
    {   
        if ($PSBoundParameters.MaxCacheTTL -ne $dnsServerInstance.MaxCacheTTL)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'MaxCacheTTL',
                $PSBoundParameters.MaxCacheTTL,
                $dnsServerInstance.MaxCacheTTL
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('MaxNegativeCacheTTL'))
    {   
        if ($PSBoundParameters.MaxNegativeCacheTTL -ne $dnsServerInstance.MaxNegativeCacheTTL)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'MaxNegativeCacheTTL',
                $PSBoundParameters.MaxNegativeCacheTTL,
                $dnsServerInstance.MaxNegativeCacheTTL
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('NameCheckFlag'))
    {   
        if ($PSBoundParameters.NameCheckFlag -ne $dnsServerInstance.NameCheckFlag)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'NameCheckFlag',
                $PSBoundParameters.NameCheckFlag,
                $dnsServerInstance.NameCheckFlag
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('NoRecursion'))
    {   
        if ($PSBoundParameters.NoRecursion -ne $dnsServerInstance.NoRecursion)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'NoRecursion',
                $PSBoundParameters.NoRecursion,
                $dnsServerInstance.NoRecursion
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('RecursionRetry'))
    {   
        if ($PSBoundParameters.RecursionRetry -ne $dnsServerInstance.RecursionRetry)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'RecursionRetry',
                $PSBoundParameters.RecursionRetry,
                $dnsServerInstance.RecursionRetry
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('RecursionTimeout'))
    {   
        if ($PSBoundParameters.RecursionTimeout -ne $dnsServerInstance.RecursionTimeout)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'RecursionTimeout',
                $PSBoundParameters.RecursionTimeout,
                $dnsServerInstance.RecursionTimeout
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('RoundRobin'))
    {   
        if ($PSBoundParameters.RoundRobin -ne $dnsServerInstance.RoundRobin)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'RoundRobin',
                $PSBoundParameters.RoundRobin,
                $dnsServerInstance.RoundRobin
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('RpcProtocol'))
    {   
        if ($PSBoundParameters.RpcProtocol -ne $dnsServerInstance.RpcProtocol)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'RpcProtocol',
                $PSBoundParameters.RpcProtocol,
                $dnsServerInstance.RpcProtocol
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('ScavengingInterval'))
    {   
        if ($PSBoundParameters.ScavengingInterval -ne $dnsServerInstance.ScavengingInterval)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'ScavengingInterval',
                $PSBoundParameters.ScavengingInterval,
                $dnsServerInstance.ScavengingInterval
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('SecureResponses'))
    {   
        if ($PSBoundParameters.SecureResponses -ne $dnsServerInstance.SecureResponses)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'SecureResponses',
                $PSBoundParameters.SecureResponses,
                $dnsServerInstance.SecureResponses
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('SendPort'))
    {   
        if ($PSBoundParameters.SendPort -ne $dnsServerInstance.SendPort)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'SendPort',
                $PSBoundParameters.SendPort,
                $dnsServerInstance.SendPort
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('StrictFileParsing'))
    {   
        if ($PSBoundParameters.StrictFileParsing -ne $dnsServerInstance.StrictFileParsing)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'StrictFileParsing',
                $PSBoundParameters.StrictFileParsing,
                $dnsServerInstance.StrictFileParsing
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('UpdateOptions'))
    {   
        if ($PSBoundParameters.UpdateOptions -ne $dnsServerInstance.UpdateOptions)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'UpdateOptions',
                $PSBoundParameters.UpdateOptions,
                $dnsServerInstance.UpdateOptions
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('WriteAuthorityNS'))
    {   
        if ($PSBoundParameters.WriteAuthorityNS -ne $dnsServerInstance.WriteAuthorityNS)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'WriteAuthorityNS',
                $PSBoundParameters.WriteAuthorityNS,
                $dnsServerInstance.WriteAuthorityNS
            )

            return $false
        }
    }

    if ($PSBoundParameters.ContainsKey('XfrConnectTimeout'))
    {   
        if ($PSBoundParameters.XfrConnectTimeout -ne $dnsServerInstance.XfrConnectTimeout)
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredState -f `
                'XfrConnectTimeout',
                $PSBoundParameters.XfrConnectTimeout,
                $dnsServerInstance.XfrConnectTimeout
            )

            return $false
        }
    }

    # If the code made it this far the server is in a desired state
    return $true
}

Export-ModuleMember -Function *-TargetResource

