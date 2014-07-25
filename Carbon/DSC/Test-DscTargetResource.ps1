# Copyright 2012 Aaron Jensen
# 
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

function Test-DscTargetResource
{
    <#
    .SYNOPSIS
    Tests that all the properties on a resource and object are the same.

    .DESCRIPTION
    DSC expects a resource's `Test-TargetResource` function to return `$false` if an object needs to be updated. Usually, you compare the current state of a resource with the desired state, and return `$false` if anything doesn't match.

    This function takes in a hashtable of the current resource's state (what's returned by `Get-TargetResource`) and compares it to the desired state (the values passed to `Test-TargetResource`). If any property in the target resource is different than the desired resource, a list of stale resources is written to the verbose stream and `$false` is returned. 

    Here's a quick example:

        return Test-TargetResource -TargetResource (Get-TargetResource -Name 'fubar') -DesiredResource $PSBoundParameters -Target ('my resource ''fubar''')

    If you want to exclude properties from the evaluation, just remove them from the hashtable returned by `Get-TargetResource`:

        $resource = Get-TargetResource -Name 'fubar'
        $resource.Remove( 'PropertyThatDoesNotMatter' )
        return Test-TargetResource -TargetResource $resource -DesiredResource $PSBoundParameters -Target ('my resource ''fubar''')

    .OUTPUTS
    System.Boolean.

    .EXAMPLE
    Test-TargetResource -TargetResource (Get-TargetResource -Name 'fubar') -DesiredResource $PSBoundParameters -Target ('my resource ''fubar''')

    Demonstrates how to test that all the properties on a DSC resource are the same was what's desired.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]
        # The current state of the resource.
        $TargetResource,

        [Parameter(Mandatory=$true)]
        [hashtable]
        # The desired state of the resource. Properties not in this hashtable are skipped. Usually you'll pass `PSBoundParameters` from your `Test-TargetResource` function.
        $DesiredResource,

        [Parameter(Mandatory=$true)]
        [string]
        # The a description of the target object being tested. Output in verbose messages.
        $Target
    )

    Set-StrictMode -Version 'Latest'

    $notEqualProperties = $TargetResource.Keys | 
                            Where-Object { $_ -ne 'Ensure' } |  
                            Where-Object { $DesiredResource.ContainsKey( $_ ) } |
                            Where-Object { $TargetResource[$_] -ne $DesiredResource[$_] }

    if( $notEqualProperties )
    {
        Write-Verbose ('{0} has stale properties: ''{1}''' -f $Target,($notEqualProperties -join ''','''))
        return $false
    }

    return $true
}