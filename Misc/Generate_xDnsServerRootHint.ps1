$dnsRootHintProperties = @()

$dnsRootHintProperties += New-xDscResourceProperty -Name NameServer -Type String -Attribute Key -Description "Specifies the fully qualified domain name of the root name server."
$dnsRootHintProperties += New-xDscResourceProperty -Name IpAddress -Type String[] -Attribute Write -Description "Specifies an array of IPv4 or IPv6 addresses of DNS servers."
$dnsRootHintProperties += New-xDscResourceProperty -Name Ensure -Type String -Attribute Required -ValidateSet "Present","Absent" -Description "Specifies to remove or add the root hint."

$dnsServerRootHintParameters = @{
    Name         = 'MSFT_xDnsServerRootHint' 
    Property     = $dnsRootHintProperties 
    FriendlyName = 'xDnsServerRootHint' 
    ModuleName   = 'xDnsServer' 
    Path         = 'C:\Program Files\WindowsPowerShell\Modules\' 
}

New-xDscResource @dnsServerRootHintParameters