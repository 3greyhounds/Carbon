# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$serviceBaseName = 'CarbonGrantControlServiceTest'
$serviceName = $serviceBaseName
$servicePath = Join-Path -Path $PSScriptRoot -ChildPath 'Service\NoOpService.exe' -Resolve
& (Join-Path -Path $PSScriptRoot -ChildPath 'Import-CarbonForTest.ps1' -Resolve)

function Uninstall-TestService
{
    if( (Get-Service $serviceName -ErrorAction SilentlyContinue) )
    {
        Stop-Service $serviceName
        & C:\Windows\system32\sc.exe delete $serviceName
    }
}

function GivenServiceStillRunsAfterStop
{
    Mock -CommandName 'Stop-Service' -ModuleName 'Carbon'
}

function Init
{
    Uninstall-TestService
    Install-Service -Name $serviceName -Path $servicePath
}

function ThenServiceUninstalled
{
    param(
        [Parameter(Mandatory)]
        [string]
        $Named
    )

    while( (Get-Service $Named -ErrorAction Ignore) )
    {
        Write-Verbose -Message ('Waiting for "{0}" to get uninstalled.' -f $Named) -Verbose
        Start-Sleep -Seconds 1
    }

    It ('should uninstall service') {
        Get-Service $Named -ErrorAction Ignore | Should -BeNullOrEmpty
    }
}

function WhenUninstalling
{
    param(
        [Parameter(Mandatory)]
        [string]
        $Named,

        $WithTimeout
    )

    $optionalParams = @{ }
    if( $WithTimeout )
    {
        $optionalParams['StopTimeout'] = $WithTimeout
    }

    Uninstall-Service -Name $Named @optionalParams
}

Describe 'Uninstall-Service' {
    It 'should remove service' {
        Init
        $service = Get-Service -Name $serviceName
        $service | Should Not BeNullOrEmpty
        $output = Uninstall-Service -Name $serviceName
        $output | Should BeNullOrEmpty
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        $service | Should BeNullOrEmpty
    }
    
    It 'should not remove non existent service' {
        Init
        $error.Clear()
        Uninstall-Service -Name "IDoNotExist"
        $error | Should BeNullOrEmpty
    }
    
    It 'should support what if' {
        Init
        Uninstall-Service -Name $serviceName -WhatIf
        $service = Get-Service -Name $serviceName
        $service | Should Not BeNullOrEmpty
    }
}

Describe 'Uninstall-Service.when service doesn''t stop' {
    Init
    GivenServiceStillRunsAfterStop
    WhenUninstalling $serviceName
    ThenServiceUninstalled $serviceName
}

Describe 'Uninstall-Service.when waiting for service to really stop' {
    Init
    GivenServiceStillRunsAfterStop
    WhenUninstalling $serviceName -WithTimeout (New-TimeSpan -Seconds 1)
    ThenServiceUninstalled $serviceName
}

Uninstall-TestService