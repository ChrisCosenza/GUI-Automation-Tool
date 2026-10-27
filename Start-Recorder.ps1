# ============================================================
# V3 AUTOMATION RECORDER - ENTRY POINT
#
# F8 = Start recording
# F9 = Stop recording
#
# Responsibilities:
#   - Load the .NET assemblies and C# input helper
#   - Coordinate the recording and generation components
#   - Display the console introduction and summary
# ============================================================

[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

. (Join-Path $projectRoot "Input\Initialize-InputHelpers.ps1")
. (Join-Path $projectRoot "Recording\RecordingSession.ps1")
. (Join-Path $projectRoot "Generation\ScriptGenerator.ps1")

Initialize-InputHelpers -ProjectRoot $projectRoot

Write-Host ""
Write-Host "==============================================="
Write-Host "        AUTOMATION RECORDER V3"
Write-Host "==============================================="
Write-Host ""
Write-Host "F8 = START"
Write-Host "F9 = STOP"
Write-Host ""
Write-Host "Records:"
Write-Host "  Keyboard"
Write-Host "  Mouse movement"
Write-Host "  Left click"
Write-Host "  Right click"
Write-Host "  Timing"
Write-Host ""
Write-Host "Press F8 to start."
Write-Host ""

# Wait for F8.
while (-not [RecorderControl]::IsDown(0x77))
{
    Start-Sleep -Milliseconds 30
}

# Wait for F8 to be released.
while ([RecorderControl]::IsDown(0x77))
{
    Start-Sleep -Milliseconds 20
}

# Start the recording component. It returns the recorded event list.
$events = Start-RecordingSession

# Generate the replay script from the event list.
$output = Join-Path (Get-Location) "RecordedAutomation.ps1"
New-ReplayScript -Events $events -OutputPath $output

Write-Host ""
Write-Host "==============================================="
Write-Host "         RECORDING COMPLETE"
Write-Host "==============================================="
Write-Host ""
Write-Host ("Events recorded: {0}" -f $events.Count)
Write-Host ""
Write-Host "Generated:"
Write-Host $output
Write-Host ""
Write-Host "To replay:"
Write-Host "powershell -ExecutionPolicy Bypass -File RecordedAutomation.ps1"
Write-Host ""
