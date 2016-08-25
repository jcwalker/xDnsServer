$resourceProperties = @()
$resourceProperties += New-xDscResourceProperty -Name Name -Type String -Attribute Key -Description "Specifies a name for the DNS application directory partition being configured."
$resourceProperties += New-xDscResourceProperty -Name Ensure -Type String -Attribute Required -ValidateSet "Present","Absent" -Description "Specifies if the DNS directory partition should be added (Present) or removed (Absent)"
$resourceProperties += New-xDscResourceProperty -Name Register -Type Boolean -Attribute Write -Description "Specifies to register the local DNS server with the directory partition."
$resourceProperties += New-xDscResourceProperty -Name Credential -Type PSCredential -Attribute Required -Description "Credentials required to modify or remove a DNS directory partition."

$dnsServerDirectoryPartitionParameters = @{
    Name         = 'MSFT_xDnsServerDirectoryPartition' 
    Property     = $resourceProperties 
    FriendlyName = 'xDnsServerDirectoryPartition' 
    ModuleName   = 'xDnsServer' 
    Path         = 'C:\Program Files\WindowsPowerShell\Modules\' 
} 
 
New-xDscResource @dnsServerDirectoryPartitionParameters
