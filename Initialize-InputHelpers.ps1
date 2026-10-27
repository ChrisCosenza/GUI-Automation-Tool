# Loads and compiles the C# helper source into the current PowerShell process.
# This keeps the original design: C# is compiled in memory at startup.

function Initialize-InputHelpers
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$ProjectRoot
    )

    $sourcePath = Join-Path $ProjectRoot "Input\InputHelpers.cs"
    $inputCode = [System.IO.File]::ReadAllText($sourcePath)

    $provider = New-Object Microsoft.CSharp.CSharpCodeProvider
    $compileParams = New-Object System.CodeDom.Compiler.CompilerParameters
    $compileParams.GenerateInMemory = $true
    $compileParams.GenerateExecutable = $false

    [void]$compileParams.ReferencedAssemblies.Add("System.dll")
    [void]$compileParams.ReferencedAssemblies.Add("System.Drawing.dll")

    $result = $provider.CompileAssemblyFromSource($compileParams, $inputCode)

    if ($result.Errors.Count -gt 0)
    {
        Write-Host ""
        Write-Host "Input helper compilation failed."
        Write-Host ""
        foreach ($compileError in $result.Errors)
        {
            Write-Host $compileError
        }
        throw "Could not compile InputHelpers.cs."
    }
}
