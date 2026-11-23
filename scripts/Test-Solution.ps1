#requires -Version 7
<#
.SYNOPSIS
  Checks the exercise end to end on a temporary copy of the repository:
  1. After Exercise 2 (example-based Slug tests added), dotnet test must FAIL on the two buggy cases.
  2. After Exercise 3 and the bonus (reference solution applied), dotnet test must PASS.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$work = Join-Path ([IO.Path]::GetTempPath()) "promptlab-$([guid]::NewGuid().ToString('N'))"

try {
    New-Item -ItemType Directory -Path $work | Out-Null
    foreach ($item in 'global.json', 'PromptLab.slnx', 'src', 'tests') {
        Copy-Item -Path (Join-Path $repo $item) -Destination $work -Recurse
    }
    Get-ChildItem $work -Recurse -Directory -Include bin, obj | Remove-Item -Recurse -Force

    $solution = Join-Path $repo 'solution'
    $tests = Join-Path $work 'tests/PromptLab.Tests'
    $src = Join-Path $work 'src/PromptLab'

    # Copy-Item keeps old timestamps, which would make MSBuild skip recompiling.
    function Copy-Fresh([string]$File, [string]$Destination) {
        Copy-Item (Join-Path $solution $File) $Destination -Force
        (Get-Item (Join-Path $Destination $File)).LastWriteTime = Get-Date
    }

    Write-Host '== Stage 1: Exercise 2 tests on the buggy starter (expect 3 failures) =='
    Copy-Fresh 'SlugTests.cs' $tests
    $out = & dotnet test (Join-Path $work 'PromptLab.slnx') 2>&1 | Out-String
    Write-Host $out
    if ($LASTEXITCODE -eq 0) { throw 'Expected failing tests before the repair step, but dotnet test passed.' }
    if ($out -notmatch 'Failed:\s+3\b') { throw 'Expected exactly 3 failing tests before the repair step.' }
    foreach ($case in '  Hello,   World!  ', 'Hello,World', 'C# & .NET 10') {
        if (-not $out.Contains("title: `"$case`"")) { throw "Expected a failure for '$case'." }
    }

    Write-Host '== Stage 2: reference solution (expect all tests to pass) =='
    Copy-Fresh 'Slug.cs' $src
    Copy-Fresh 'Calculator.cs' $src
    Copy-Fresh 'CalculatorTests.cs' $tests
    & dotnet test (Join-Path $work 'PromptLab.slnx')
    if ($LASTEXITCODE -ne 0) { throw 'Reference solution tests failed.' }

    Write-Host 'Solution check passed.'
}
finally {
    Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
}
