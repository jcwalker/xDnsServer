Import-Module $PSScriptRoot\..\Helper.psm1

data LocalizedData
{
   ConvertFrom-StringData -StringData @'
NotInDesiredStateEnsurePresent=Directory partition "{0}" not found and Ensure is Present.
InDesiredStateEnsurePresent=Directory partition "{0}" found and Ensure is Present.
NotInDesiredStateEnsureAbsent=Directory partition "{0}" found and Ensure is Absent.
InDesiredStateEnsureAbsent=Directory partition "{0}" not found and Ensure is Absent.
DirectoryIsInProcessOfDelete=Directory partition "{0}" is in the deletion process.
RegisterNotInDesiredState=Register not in deisred state. Expect Register:"{0}" Actual: "{1}".

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
        $Name,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

    $dnsPartition = Get-DnsServerDirectoryPartition | Where-Object DirectoryPartitionName -eq $Name

    if ($dnsPartition)
    {
        $ensureResult = 'Present'
    }
    else
    {
        $ensureResult = 'Absent'
    }
    if ($dnsPartition)
    {    
        if ($dnsPartition.flags.Trim() -eq 'Enlisted')
        {
            $registerResult = $true
        }
        else
        {
            $registerResult = $false
        }
    }
    else
    {
        $registerResult = $false
    }

    $returnValue = @{
        Name     = $Name
        Ensure   = $ensureResult
        Register = $registerResult
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

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.Boolean]
        $Register,
        
        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

    $dnsPartition = Get-DnsServerDirectoryPartition | Where-Object DirectoryPartitionName -eq $Name

    if ($Ensure -eq 'Present')
    {
        if (!$dnsPartition)
        {
            Add-DnsServerDirectoryPartition -Name $Name
            
            Wait-PartitionTask -Name $Name -Task Add

        }
        if ($Register -eq $true)
        {                
            Invoke-Command -ComputerName . -ScriptBlock {
                Register-DnsServerDirectoryPartition -Name $using:Name
            } -Credential $Credential

            Wait-PartitionTask -Name $Name -Task AddRegister
        }
        else
        {
            # need credential
            Invoke-Command -ComputerName . -ScriptBlock {
                Unregister-DnsServerDirectoryPartition -Name $using:Name -Force
            } -Credential $Credential

            Wait-PartitionTask -Name $Name -Task RemoveRegister
        }
    }
    else
    {
        #need credential
        Invoke-Command -ComputerName . -ScriptBlock {
            Remove-DnsServerDirectoryPartition -Name $using:Name -Force
        } -Credential $Credential

        Wait-PartitionTask -Name $Name -Task Remove        
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

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.Boolean]
        $Register,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

    $dnsPartition = Get-DnsServerDirectoryPartition -ErrorAction stop | Where-Object DirectoryPartitionName -eq $Name

    $targetResult = Get-TargetResource -Name $Name -Ensure $Ensure -Credential $Credential

    if ($Ensure -eq 'Present')
    {
        if ($PSBoundParameters.ContainsKey('Register'))
        {
            if ($targetResult.Register -ne $Register)
            {
                Write-Verbose -Message ($LocalizedData.RegisterNotInDesiredState `
                    -f $Register,$($targetResult.Register))
                return $false
            } 
        }
        if ($targetResult.Ensure -eq 'Absent')
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredStateEnsurePresent -f $Name)
            return $false
        }

        # if the code made it this far resource must be in a desired state
        return $true        
    }
    else
    {
        if ($targetResult.Ensure -eq 'Present')
        {
            if ($dnsPartition.Flags.Trim() -eq 'Enlisted Deleted')
            {
                Write-Verbose -Message ($LocalizedData.DirectoryIsInProcessOfDelete -f $Name)
                return $true
            }
                
            Write-Verbose -Message ($LocalizedData.NotInDesiredStateEnsureAbsent -f $Name)
            return $false
        }
        else
        {
            Write-Verbose -Message ($LocalizedData.InDesiredStateEnsureAbsent -f $Name)
            return $true
        }
    }
}


Export-ModuleMember -Function *-TargetResource
