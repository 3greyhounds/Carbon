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

function Setup
{
    Import-Module (Join-Path $TestDir ..\..\Carbon -Resolve)
}

function TearDown
{
    Remove-Module Carbon
}

function Test-ShouldNotFindNonExistentWebsite
{
    $result = Test-IisWebsite 'jsdifljsdflkjsdf'
    Assert-False $result "Found a non-existent website!"
}

function Test-ShouldFindExistentWebsite
{
    Install-IisWebsite -Name 'Test Website Exists' -Path $TestDir
    try
    {
        $result = Test-IisWebsite 'Test Website Exists'
        Assert-True $result "Did not find existing website."
    }
    finally
    {
        Remove-IisWebsite 'Test Website Exists'
    }
}
