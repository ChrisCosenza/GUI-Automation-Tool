# Recording responsibility:
#   - Reset input state
#   - Poll input while recording
#   - Convert detected input into event objects
#   - Track delays between events
#   - Return the recorded events to the caller

function Start-RecordingSession
{
    [InputHelper]::Reset()

    Write-Host ""
    Write-Host "==============================================="
    Write-Host "             RECORDING..."
    Write-Host "==============================================="
    Write-Host ""
    Write-Host "Press F9 to stop."
    Write-Host ""

    $events = New-Object System.Collections.ArrayList
    $watch = New-Object System.Diagnostics.Stopwatch
    $watch.Start()

    $lastEventTime = 0
    $recording = $true

    while ($recording)
    {
        # Stop recording when F9 is pressed.
        if ([RecorderControl]::IsDown(0x78))
        {
            $recording = $false
            break
        }

        # Keyboard input.
        $key = [InputHelper]::GetKeyboardEvent()

        if ($key -ne "")
        {
            $now = $watch.ElapsedMilliseconds
            $delay = $now - $lastEventTime

            $event = New-Object PSObject
            $event | Add-Member NoteProperty Type "KEY"
            $event | Add-Member NoteProperty Value $key
            $event | Add-Member NoteProperty X 0
            $event | Add-Member NoteProperty Y 0
            $event | Add-Member NoteProperty Delay $delay

            [void]$events.Add($event)
            $lastEventTime = $now

            Write-Host ("KEY       {0}   +{1}ms" -f $key, $delay)
        }

        # Mouse clicks and movement. InputHelper returns pipe-delimited data.
        $mouseData = [InputHelper]::GetMouseEvents()

        if ($mouseData -ne "")
        {
            $parts = $mouseData.Split("|")
            $i = 0

            while ($i -lt ($parts.Length - 1))
            {
                $type = $parts[$i]

                if ($type -eq "LEFT")
                {
                    $now = $watch.ElapsedMilliseconds
                    $delay = $now - $lastEventTime
                    $pos = [System.Windows.Forms.Cursor]::Position

                    $event = New-Object PSObject
                    $event | Add-Member NoteProperty Type "LEFT"
                    $event | Add-Member NoteProperty Value ""
                    $event | Add-Member NoteProperty X $pos.X
                    $event | Add-Member NoteProperty Y $pos.Y
                    $event | Add-Member NoteProperty Delay $delay

                    [void]$events.Add($event)
                    $lastEventTime = $now

                    Write-Host ("LEFT CLICK  {0},{1}   +{2}ms" -f $pos.X, $pos.Y, $delay)
                    $i++
                }
                elseif ($type -eq "RIGHT")
                {
                    $now = $watch.ElapsedMilliseconds
                    $delay = $now - $lastEventTime
                    $pos = [System.Windows.Forms.Cursor]::Position

                    $event = New-Object PSObject
                    $event | Add-Member NoteProperty Type "RIGHT"
                    $event | Add-Member NoteProperty Value ""
                    $event | Add-Member NoteProperty X $pos.X
                    $event | Add-Member NoteProperty Y $pos.Y
                    $event | Add-Member NoteProperty Delay $delay

                    [void]$events.Add($event)
                    $lastEventTime = $now

                    Write-Host ("RIGHT CLICK {0},{1}   +{2}ms" -f $pos.X, $pos.Y, $delay)
                    $i++
                }
                elseif ($type -eq "MOVE")
                {
                    if (($i + 2) -lt $parts.Length)
                    {
                        $x = [int]$parts[$i + 1]
                        $y = [int]$parts[$i + 2]

                        $now = $watch.ElapsedMilliseconds
                        $delay = $now - $lastEventTime

                        $event = New-Object PSObject
                        $event | Add-Member NoteProperty Type "MOVE"
                        $event | Add-Member NoteProperty Value ""
                        $event | Add-Member NoteProperty X $x
                        $event | Add-Member NoteProperty Y $y
                        $event | Add-Member NoteProperty Delay $delay

                        [void]$events.Add($event)
                        $lastEventTime = $now

                        Write-Host ("MOVE        {0},{1}   +{2}ms" -f $x, $y, $delay)
                        $i += 3
                    }
                    else
                    {
                        $i++
                    }
                }
                else
                {
                    $i++
                }
            }
        }

        Start-Sleep -Milliseconds 15
    }

    $watch.Stop()

    # Wait until F9 is released before returning to the entry point.
    while ([RecorderControl]::IsDown(0x78))
    {
        Start-Sleep -Milliseconds 20
    }

    # Unary comma prevents PowerShell from enumerating the ArrayList on return.
    return ,$events
}
