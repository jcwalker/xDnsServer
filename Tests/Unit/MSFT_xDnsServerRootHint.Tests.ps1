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

$script:DSCModuleName   = 'xDnsServer'
$script:DSCResourceName = 'MSFT_xDnsServerRootHint'


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
               
            $testParameters = @{
                NameServer = 'y.root-servers.net'
                Ensure = 'Present'
            }

            $mockResults = @{
                IpAddress = @('10.0.0.1')
                Ensure = 'Present'
                NameServer = 'y.root-servers.net'
            }
            Mock Get-DnsServerRootHint -MockWith {return @{NameServer = @{RecordData = @{NameServer='y.root-servers.net.'}}} }
            Mock Get-IPAddressString -MockWith {return @('10.0.0.1')}        
                
                
            It "Get method returns 'something'" {

                $getResult = Get-TargetResource @testParameters

                foreach ($key in $getResult.Keys)
                {              
                    $getResult[$key] | Should be $mockResults[$key]            
                }
            }

            It "Test method returns false when IpAddress is not in desired state" {

                Mock Get-TargetResource -MockWith {$mockResults}
                $falseTestParameters = $testParameters.Clone()
                $falseTestParameters.Add('IpAddress',@('10.0.0.2'))

                Test-TargetResource @falseTestParameters | Should be $false
            }

            It "Test method returns false when Ensure is not in desired state" {               

                Mock Get-TargetResource -MockWith {$mockResults}
                $falseTestParameters = @{
                    IpAddress = @('10.0.0.1')
                    Ensure = 'Absent'
                    NameServer = 'y.root-servers.net'
                }

                Test-TargetResource @falseTestParameters | Should be $false               
            }
            Context "Asserting Add-DnsServerRootHint Mock" {
                It "Set method calls only Add-DnsServerRootHint 1 time" {
                    $testParameters = $testParameters.Clone()
                    $testParameters.Add('IpAddress',@('10.0.0.2'))  
                    Mock Get-TargetResource -MockWith {return @{Ensure = 'Absent'}}
                    Mock Add-DnsServerRootHint    -MockWith {}
                       
                    Set-TargetResource @testParameters
                                
                    Assert-MockCalled Add-DnsServerRootHint -Exactly 1 
                }
            }
            Context "Asserting Add and Remove Mocks" {
                It "Set method calls Add and Remove 1 time" {
                    $testParameters = $testParameters.Clone()
                    $testParameters.Add('IpAddress',@('10.0.0.2'))  
                    Mock Get-TargetResource -MockWith {return @{Ensure = 'Present'}}
                    Mock Add-DnsServerRootHint    -MockWith {}
                    Mock Remove-DnsServerRootHint -MockWith {} 

                    Set-TargetResource @testParameters
                                
                    Assert-MockCalled Add-DnsServerRootHint -Exactly 1
                    Assert-MockCalled Remove-DnsServerRootHint -Exactly 1
                }
            }
            Context "Asserting Remove-DnsServerRootHint Mock" {
                It "Set method should call Remove-DnsServerRootHint 1 time" {
                    $removeParameters = @{
                        IpAddress = @('10.0.0.1')
                        Ensure = 'Absent'
                        NameServer = 'y.root-servers.net'
                    }
                    Mock Remove-DnsServerRootHint -MockWith {}

                    Set-TargetResource @removeParameters

                    Assert-MockCalled Remove-DnsServerRootHint -Exactly 1
                }
            }
        }
    
    #endregion Example state 1

    #region Example state 2
        Describe "The system is in the desired state" {

            $trueTestParameters = @{
                    NameServer = 'y.root-servers.net'
                    Ensure = 'Present'
                }

            $mockResults = @{
                    IpAddress = @('10.0.0.1')
                    Ensure = 'Present'
                    NameServer = 'y.root-servers.net'
                }

            It "Test method returns true when Ensure is in a desired state" {
                Mock Get-TargetResource -MockWith {return $mockResults}
                Test-TargetResource @trueTestParameters | Should be $true 
            }

            It "Test method returns true when IpAddress is in a desired state" {
                $testIpParameters = $trueTestParameters.Clone()
                $testIpParameters.Add('IpAddress',(@('10.0.0.1')))
                Mock Get-TargetResource -MockWith {return $mockResults}
                Test-TargetResource @trueTestParameters | Should be $true           
            }
        }
    }
    #endregion Example state 2

    #region Non-Exported Function Unit Tests

    InModuleScope $script:DSCResourceName {
        
        $array1 = 1,2,3
        $array2 = 3,2,1
        $array3 = 1,2,3,4

        Describe 'Private functions' {


            Context 'Compare-Array' {
            
                It 'Should return true when arrays are same' {
                    Compare-Array $array1 $array2 | should be $true
                }

                It 'Should return true when both arrays are NULL' {
                    Compare-Array $null $null | should be $true
                }

                It 'Should return false when arrays are different' {
                    Compare-Array $array1 $array3 | should be $false
                }

                It 'Should return false when only one input is NULL' {
                    Compare-Array $array1 $null | should be $false
                }
            }

            Context 'Format-OutputDot' {
                It 'Should Append a dot to input string' {
                    Format-OutputDot -InputString 'String' | Should be 'String.'
                }
                It 'Should return input string if string ends with dot' {
                    Format-OutputDot -InputString 'String.' | Should be 'String.'
                }                
            }
        }
    }
    #endregion Non-Exported Function Unit Tests
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
