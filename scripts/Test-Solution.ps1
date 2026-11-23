#requires -Version 7
<#
.SYNOPSIS
  Checks the starter, each core exercise, and optional remainder tests on a disposable copy.
  Uses structured test results to distinguish expected assertion failures from build failures.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$work = Join-Path $repo ".validation/promptlab-$([guid]::NewGuid().ToString('N'))"

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

    function Test-Stage([string]$Name, [int]$Passed, [int]$Failed) {
        $results = Join-Path $work "TestResults/$Name"
        $out = & dotnet test (Join-Path $work 'PromptLab.slnx') --logger 'trx;LogFileName=results.trx' --results-directory $results 2>&1 | Out-String
        $exitCode = $LASTEXITCODE
        [xml]$trx = Get-Content (Join-Path $results 'results.trx') -Raw
        $counts = $trx.TestRun.ResultSummary.Counters
        if ([int]$counts.passed -ne $Passed -or [int]$counts.failed -ne $Failed -or
            [int]$counts.total -ne ($Passed + $Failed) -or
            ($Failed -eq 0 -and $exitCode -ne 0) -or ($Failed -gt 0 -and $exitCode -ne 1)) {
            Write-Host $out
            throw "Unexpected results at $Name (expected $Passed passed, $Failed failed)."
        }
        Write-Host "$Name : $Passed passed, $Failed failed, $($Passed + $Failed) total"
        return $trx
    }

    Test-Stage 'starter' 1 0 | Out-Null
    Copy-Fresh 'CalculatorTests.cs' $tests
    Test-Stage 'exercise-1' 10 0 | Out-Null

    $slugHash = (Get-FileHash (Join-Path $src 'Slug.cs')).Hash
    Copy-Fresh 'SlugTests.cs' $tests
    $trx = Test-Stage 'exercise-2' 15 3
    if ((Get-FileHash (Join-Path $src 'Slug.cs')).Hash -ne $slugHash) {
        throw 'Exercise 2 changed Slug.cs.'
    }
    $failures = @($trx.TestRun.Results.UnitTestResult | Where-Object outcome -eq 'Failed')
    foreach ($case in '  Hello,   World!  ', 'Hello,World', 'C# & .NET 10') {
        $match = @($failures | Where-Object { $_.testName.Contains("title: `"$case`"") })
        if ($match.Count -ne 1 -or $match[0].Output.ErrorInfo.Message -notmatch 'Assert.Equal') {
            throw "Expected an assertion failure for '$case'."
        }
    }

    $beforeRepair = @{}
    Get-ChildItem $tests -Filter '*.cs' | ForEach-Object {
        $beforeRepair[$_.Name] = (Get-FileHash $_.FullName).Hash
    }
    Copy-Fresh 'Slug.cs' $src
    Test-Stage 'exercise-3' 18 0 | Out-Null
    foreach ($file in Get-ChildItem $tests -Filter '*.cs') {
        if ($beforeRepair[$file.Name] -ne (Get-FileHash $file.FullName).Hash) {
            throw "The repair changed tests in $($file.Name)."
        }
    }

    Copy-Fresh 'Calculator.cs' $src
    Copy-Fresh 'RemainderTests.cs' $tests
    Test-Stage 'optional-remainder' 21 0 | Out-Null

    Write-Host 'Solution check passed.'
}
finally {
    Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
}
