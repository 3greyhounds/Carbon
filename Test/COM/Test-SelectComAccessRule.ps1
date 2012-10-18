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

$rules = @(
    (New-Object Carbon.Security.ComAccessRule ((New-Object Security.Principal.NTAccount 'BUILTIN\Administrators'),'Execute','Allow')),
    (New-Object Carbon.Security.ComAccessRule ((New-Object Security.Principal.NTAccount 'NT AUTHORITY\Network Service'),'Execute','Allow'))
)

function Setup
{
    & (Join-Path $TestDir ..\..\Carbon\Import-Carbon.ps1 -Resolve)
}

function TearDown
{
    Remove-Module Carbon
}

function Test-ShouldReturnAllRulesByDefault
{
    $filteredRules = $rules | Select-ComAccessRule
    Assert-NotNull $filteredRules
    Assert-Equal 2 $filteredRules.Count
    Assert-Equal $rules[0] $filteredRules[0]
    Assert-Equal $rules[1] $filteredRules[1]
}

function Test-ShouldReturnRulesForIdentity
{
    $adminRule = $rules | Select-ComAccessRule -Identity 'Administrators'
    Assert-NotNull $adminRule
    Assert-Equal $rules[0] $adminRule
}