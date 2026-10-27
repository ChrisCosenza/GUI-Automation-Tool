# Script-generation responsibility:
#   Convert the recorded event objects into RecordedAutomation.ps1.
#   The generated replay script remains a standalone PowerShell script.

function New-ReplayScript
{
    param(
        [Parameter(Mandatory=$true)]
        $Events,

        [Parameter(Mandatory=$true)]
        [string]$OutputPath
    )

    # Build the generated script line-by-line. This avoids nested here-string
    # parsing issues in older PowerShell versions.
    $lines = New-Object System.Collections.ArrayList

    [void]$lines.Add('[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")')
    [void]$lines.Add('[void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")')
    [void]$lines.Add("")

    # Native mouse replay helper embedded into the generated script.
    [void]$lines.Add('$mouseCode = @"')
    [void]$lines.Add('using System;')
    [void]$lines.Add('using System.Runtime.InteropServices;')
    [void]$lines.Add("")
    [void]$lines.Add('public class MouseReplay')
    [void]$lines.Add('{')
    [void]$lines.Add('    [DllImport("user32.dll")]')
    [void]$lines.Add('    public static extern void mouse_event(')
    [void]$lines.Add('        uint flags,')
    [void]$lines.Add('        uint dx,')
    [void]$lines.Add('        uint dy,')
    [void]$lines.Add('        uint data,')
    [void]$lines.Add('        uint extraInfo);')
    [void]$lines.Add('}')
    [void]$lines.Add('"@')
    [void]$lines.Add("")

    # Compile the mouse helper when the generated replay script runs.
    [void]$lines.Add('$provider = New-Object Microsoft.CSharp.CSharpCodeProvider')
    [void]$lines.Add('$params = New-Object System.CodeDom.Compiler.CompilerParameters')
    [void]$lines.Add('$params.GenerateInMemory = $true')
    [void]$lines.Add('$params.GenerateExecutable = $false')
    [void]$lines.Add('[void]$params.ReferencedAssemblies.Add("System.dll")')
    [void]$lines.Add('$result = $provider.CompileAssemblyFromSource($params,$mouseCode)')
    [void]$lines.Add("")
    [void]$lines.Add('if ($result.Errors.Count -gt 0)')
    [void]$lines.Add('{')
    [void]$lines.Add('    Write-Host "Mouse helper compilation failed."')
    [void]$lines.Add('    exit')
    [void]$lines.Add('}')
    [void]$lines.Add("")

    [void]$lines.Add('Write-Host ""')
    [void]$lines.Add('Write-Host "==============================================="')
    [void]$lines.Add('Write-Host "       REPLAYING AUTOMATION"')
    [void]$lines.Add('Write-Host "==============================================="')
    [void]$lines.Add('Write-Host ""')
    [void]$lines.Add('Write-Host "Starting in 3 seconds..."')
    [void]$lines.Add('Start-Sleep -Seconds 3')
    [void]$lines.Add("")

    foreach ($event in $Events)
    {
        $delay = [int]$event.Delay

        if ($delay -gt 0)
        {
            [void]$lines.Add(('Start-Sleep -Milliseconds {0}' -f $delay))
        }

        if ($event.Type -eq "KEY")
        {
            $value = $event.Value.Replace('"','""')
            $line = '[System.Windows.Forms.SendKeys]::SendWait("' + $value + '")'
            [void]$lines.Add($line)
        }
        elseif ($event.Type -eq "MOVE")
        {
            $x = $event.X
            $y = $event.Y
            $line = '[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(' + $x + ',' + $y + ')'
            [void]$lines.Add($line)
        }
        elseif ($event.Type -eq "LEFT")
        {
            $x = $event.X
            $y = $event.Y

            [void]$lines.Add('[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(' + $x + ',' + $y + ')')
            [void]$lines.Add('[MouseReplay]::mouse_event(0x0002,0,0,0,0)')
            [void]$lines.Add('[MouseReplay]::mouse_event(0x0004,0,0,0,0)')
        }
        elseif ($event.Type -eq "RIGHT")
        {
            $x = $event.X
            $y = $event.Y

            [void]$lines.Add('[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(' + $x + ',' + $y + ')')
            [void]$lines.Add('[MouseReplay]::mouse_event(0x0008,0,0,0,0)')
            [void]$lines.Add('[MouseReplay]::mouse_event(0x0010,0,0,0,0)')
        }
    }

    [void]$lines.Add("")
    [void]$lines.Add('Write-Host ""')
    [void]$lines.Add('Write-Host "Replay complete."')

    [System.IO.File]::WriteAllLines(
        $OutputPath,
        $lines.ToArray(),
        [System.Text.Encoding]::ASCII
    )
}
