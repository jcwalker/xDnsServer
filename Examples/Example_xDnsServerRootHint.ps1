configuration DnsServerRootHint
{
    Import-DscResource -ModuleName xDnsServer

    node localhost
    {
        xDnsServerRootHint RemoveRoot-Y
        {
            NameServer = 'y.root-servers.net'
            Ensure     = 'Absent'
        }

        xDnsServerRootHint AddRoot-A
        {
            NameServer = 'a.root-servers.net'
            IpAddress  = '198.41.0.4'#,'2001:503:ba3e::2:30'
            Ensure     = 'Present'
        }
    }
}

DnsServerRootHint -OutputPath C:\DscRootHint

Start-DscConfiguration -Path C:\DscRootHint -Wait -Force -Verbose