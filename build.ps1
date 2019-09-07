﻿<#
.SYNOPSIS
    PowerShell module build, test, and deployment entry script.
#>

# Check / install required modules 

$RequiredModules = @(
    @{
        Name = 'PSake'
        Version =  [version]'4.8.0'
    },
    @{
        Name = 'PSScriptAnalyzer'
        Version = [version]'1.18.1'
    },
    @{
        Name = 'Pester'
        Version = [version]'4.8.1'
    },
    @{
        Name = 'BuildHelpers'
        Version = [version]'2.0.10'
    }
)

ForEach ($RequiredModule in $RequiredModules) {

    $CheckModule = Get-Module $RequiredModule.Name -ListAvailable | Sort Version -Desc | Select -First 1
    $CheckModule

    if ($CheckModule.Version -lt $RequiredModule.Version) {
        Write-Host "Installing $($RequiredModule.Name) version $($RequiredModule.Version).."
        Install-Module $RequiredModule.Name -MinimumVersion $RequiredModule.Version -Scope CurrentUser -Force
    }

    Import-Module -Name $RequiredModule.Name -MinimumVersion $RequiredModule.Version
}

# Initiate BuildHelpers

Set-BuildEnvironment

# Execute PSake

Invoke-Psake ./psake.ps1

# Exit script with build outcome return value

exit ( [int]( -not $psake.build_success ) )