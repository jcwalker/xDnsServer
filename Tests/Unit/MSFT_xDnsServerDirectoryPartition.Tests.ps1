<#
.Synopsis
   Template for creating DSC Resource Unit Tests
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Unit\ folder and rename <ResourceName>.tests.ps1 (e.g. MSFT_xFirewall.tests.ps1)
     2. Customize TODO sections.

.NOTES
   Code in HEADER and FOOTER regions are standard and may be moved into DSCResource.Tools in
   Future and therefore should not be altered if possible.
#>

$script:DSCModuleName      = 'xDnsServer'
$script:DSCResourceName    = 'MSFT_xDnsServerDirectoryPartition'

#region HEADER
# Unit Test Template Version: 1.1.0
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit 
#endregion HEADER

# Begin Testing
try
{

    #region Example state 1
    InModuleScope $script:DSCResourceName {
        Describe "The system is not in the desired state" {
            $mockResults = @{
                DirectoryPartitionName = "contoso.com"
                Flags = 'Not-Enlisted '                                  
            }
        
            #Mock Get-DnsServerDirectoryPartition -MockWith {} -ParameterFilter {$Name -eq 'noDirectory.com'}
            Mock Get-DnsServerDirectoryPartition -MockWith {$mockResults} -ParameterFilter {$Name -eq 'contoso.com'}
            Mock Add-DnsServerDirectoryPartition -MockWith {}       
            $testParameters = @{
                Name   = 'contoso.com'
                Ensure = 'Present'
                Credential = [PSCredential]::Empty
            }     
            $cred = ([PSCRedential]::Empty)

            It "Get method returns 'Ensure is Absent' when partition is Absent" {
                Mock Get-DnsServerDirectoryPartition -MockWith {}
                $getResult = Get-TargetResource -Name 'noDirectory.com' -Ensure Absent -Credential $cred

                $getResult.Ensure | Should be 'Absent'
            }

            It "Get method returns Register is False" {
                Mock Get-DnsServerDirectoryPartition -MockWith {$mockResults}
                $getResult = Get-TargetResource @testParameters

                $getResult.Register | Should be $false
            }

            It "Test method returns false when directory is present and Ensure is Absent" {
                Test-TargetResource -Name 'contoso.com' -Ensure Absent -Credential $cred | Should be $false
            }

            It "Test method returns false when directory is Absent and Ensure is Present" {
                Mock Get-DnsServerDirectoryPartition -MockWith {}
                Test-TargetResource -Name 'noDirectory.com' -Ensure Present -Credential $cred | Should be $false
            }
        
            Mock Invoke-Command -MockWith {}
            Mock Wait-PartitionTask -MockWith {}           

            It "Set method calls Add-DnsServerDirectoryPartition when Ensure is Present" {
                Mock Add-DnsServerDirectoryPartition -MockWith {}
                Set-TargetResource -Name 'contoso.com' -Ensure Present -Credential ([PSCredential]::Empty)

                Assert-MockCalled Add-DnsServerDirectoryPartition
            }

            It 'Set method calls Remove-DnsServerDirectoryPartition when Ensure is Absent' {

                Set-TargetResource -Name 'contoso.com' -Ensure Absent -Credential ([PSCredential]::Empty)

                Assert-MockCalled Invoke-Command
            }
        }
        
    }
    #endregion Example state 1

    #region Example state 2
    Describe "The system is in the desired state" {
        $mockResults = @{
            DirectoryPartitionName = "contoso.com"
            Flags = 'Not-Enlisted '             
        }
        $testParameters = @{
            Name   = 'contoso.com'
            Ensure = 'Present'
            Credential = [PSCredential]::Empty
        } 
        Mock Get-DnsServerDirectoryPartition -MockWith {} -ParameterFilter {$Name -eq 'noDirectory.com'}
        Mock Get-DnsServerDirectoryPartition -MockWith {$mockResults} -ParameterFilter {$Name -eq 'contoso.com'}

        It "Get method returns 'Ensure is Present' when partition is Present" {
            Mock Get-DnsServerDirectoryPartition -MockWith {$mockResults}
            $getResult = Get-TargetResource @testParameters

            $getResult.Ensure | Should be 'Present'
        }
        It "Test method returns true when expecting Present" {
            {Test-TargetResource @testParameters} | Should be $true
        }

        It "Test method returns true when expecting absent" {
            Mock Get-DnsServerDirectoryPartition -MockWith {}
            {Test-TargetResource -Name 'noDirectory.com' -Ensure Absent `
                -Credential ([PSCredential]::Empty)} | Should be $true
        }

        It "Test method returns True when Register expected True" {
            $mockRegisterTrue = @{
                Name     = 'contoso.com'
                Ensure   = 'Present'
                Register = $true
            }
            Mock Get-TargetResource -MockWith {$mockRegisterTrue}
            {Test-TargetResource -Name 'contoso.com' -Ensure Present -Register $true -Credential ([PSCredential]::Empty)} | Should be $true
        }
    }
    #endregion Example state 2
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
