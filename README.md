# GUI-Automation-Tool
Developed a PowerShell GUI automation tool using .NET Framework 2.0 and Windows APIs. Implemented keyboard/mouse recording, timing, script generation, replay, and image-based screen verification, demonstrating application logic, API integration, and Windows system interaction.



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# PowerShell GUI Automation Tool

A Windows GUI automation prototype built with PowerShell v1, .NET Framework 2.0, and Windows APIs. The tool records keyboard and mouse interactions, captures event timing, generates reusable PowerShell automation scripts, replays recorded actions, and verifies screen states using image comparison.

## Overview

This project explores how to build a desktop automation application by integrating PowerShell, .NET libraries, and native Windows APIs. It demonstrates how user input can be captured, represented as events, transformed into executable scripts, and replayed against desktop applications.

The long-term goal is to develop an image-driven automation engine that identifies interface elements visually and performs actions based on the current screen state.

## Features

- **Keyboard recording:** Captures keyboard input and special keys.
- **Mouse recording:** Captures mouse movement and left/right clicks.
- **Event timing:** Records delays between interactions for more accurate replay.
- **Script generation:** Converts recorded events into a reusable `RecordedAutomation.ps1` script.
- **Automated replay:** Reproduces recorded keyboard and mouse actions.
- **Image verification:** Compares screen captures against reference images and reports similarity results.
- **Windows API integration:** Uses native Windows functionality alongside .NET Framework libraries.

## Technology Stack

- PowerShell v1
- .NET Framework 2.0
- C# interop through CodeDOM
- `System.Drawing`
- `System.Windows.Forms`
- `System.Diagnostics.Stopwatch`
- Win32 API (`user32.dll`)

## Architecture

The application combines several responsibilities within a local desktop automation tool.

```text
User Input
    |
    v
Input Capture
    |
    v
Event Processing
    |
    v
Event Storage and Timing
    |
    v
PowerShell Script Generation
    |
    v
Automation Replay
    |
    v
Target Windows Application
```

The image-verification component provides a separate capability for comparing the current screen with a reference image.

## Getting Started

### Requirements

- A Windows environment
- PowerShell v1-compatible execution environment
- .NET Framework 2.0
- Permission to execute PowerShell scripts
- Access to the desktop application being automated

### Usage

The recorder uses the following keyboard controls:

| Key | Action |
|---|---|
| `F8` | Start recording |
| `F9` | Stop recording |

1. Run the recorder in the intended Windows environment.
2. Press `F8` to begin recording.
3. Perform the keyboard and mouse interactions you want to capture.
4. Press `F9` to stop recording.
5. Generate the replay script.
6. Run `RecordedAutomation.ps1` to reproduce the captured sequence.

The generated script is written to the current working directory by default.

**Important:** Recorded automation relies on the original application's state, screen layout, timing, and input focus. Review the generated script before executing it, and test it in a safe environment first.

## Image Verification

The existing image-verification component captures the screen and compares it against a reference bitmap.

The verification process is:

1. Capture the current screen.
2. Load the reference image.
3. Compare the images.
4. Calculate a similarity score.
5. Report whether the comparison passes or fails.

Image verification is currently distinct from fully image-driven action execution. Automatically locating arbitrary interface elements and triggering actions from those matches is planned future work.

## Planned Improvements

- Image search that returns matching screen coordinates.
- Image-triggered mouse clicks and keyboard actions.
- Text entry and clipboard-based paste actions.
- Wait, retry, and timeout handling.
- Verification after each automation step.
- Workflow configuration separated from execution logic.
- Secure runtime credential retrieval.
- Structured event logging and execution reports.
- Modular architecture separating the user interface, automation engine, and supporting services.

## Security Considerations

- Do not store passwords or other secrets in generated scripts, workflow files, screenshots, or logs.
- Use an approved secure credential store when credential-based automation is implemented.
- Review automation scripts before running them.
- Test against applications and systems you are authorized to access.
- Avoid running unattended automation against production systems until appropriate safeguards and failure handling are in place.

## Project Purpose

This project serves as a practical exploration of application development, automation architecture, Windows API integration, event processing, and image-based verification.

It provides a foundation for evolving a local automation tool into a modular automation framework with reusable workflows, state verification, and more resilient execution.

## Current Status

**Working components:** Keyboard and mouse recording, event timing, PowerShell script generation, replay, and image verification.

**In development:** Image-driven element detection and action execution, workflow orchestration, and robust unattended automation.

## License

No license has been specified yet. Add an appropriate license before permitting others to reuse, modify, or distribute this project.
