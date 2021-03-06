data LocalizedData
{
   ConvertFrom-StringData -StringData @'
NotInDesiredStateEnsurePresent=Directory partition "{0}" found and Ensure is Present.
InDesiredStateEnsurePresent=Directory partition "{0}" found and Ensure is Present.
NotInDesiredStateEnsureAbsent=Directory partition "{0}" found and Ensure is Absent.
InDesiredStateEnsureAbsent=Directory partition "{0}" not found and Ensure is Absent.
DirectoryIsInProcessOfDelete=Directory partition "{0}" is in the deletion process.
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
        $Ensure
    )

    try
    {
        $dnsPartition = Get-DnsServerDirectoryPartition -Name $Name -ErrorAction Stop
    }
    catch
    {
        Write-Warning $_
    }

    if ($dnsPartition)
    {
        $ensureResult = 'Present'
    }
    else
    {
        $ensureResult = 'Absent'
    }

    
    $returnValue = @{
        Name = $Name
        Ensure = $ensureResult
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
        $Ensure
    )

    if ($Ensure -eq 'Present')
    {
        Add-DnsServerDirectoryPartition -Name $Name
    }
    else
    {
        Remove-DnsServerDirectoryPartition -Name $Name -Force
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
        $Ensure
    )

    try
    {
        $dnsPartition = Get-DnsServerDirectoryPartition -Name $Name -ErrorAction Stop

    }
    catch
    {
        Write-Warning $_
    }

    if ($Ensure -eq 'Present')
    {
        if ($dnsPartition)
        {
            Write-Verbose -Message ($LocalizedData.InDesiredStateEnsurePresent -f $Name)
            return $true
        }
        else
        {
            Write-Verbose -Message ($LocalizedData.NotInDesiredStateEnsurePresent -f $Name)
            return $false
        }
    }
    else
    {
        if ($dnsPartition)
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
