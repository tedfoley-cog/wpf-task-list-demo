# WPF Task List demo

A small WPF desktop app (C#, .NET Framework 4.8) with a UI Automation regression suite. It builds and runs on a stock Windows Server 2022 / Windows 10+ machine. No .NET SDK or Visual Studio is needed.

## Features
- Add a task. An empty input shows "Enter a task first".
- Duplicate tasks are rejected, ignoring case ("Task already exists").
- "Remove selected" deletes the highlighted task. With nothing selected it shows "Select a task to remove".
- Live count: `0 tasks`, `1 task`, `N tasks`.

## Install
Nothing to install. The build uses `csc.exe` from the .NET Framework that ships with Windows (`%WINDIR%\Microsoft.NET\Framework64\v4.0.30319`).
Optional: `ffmpeg` (for example `choco install ffmpeg -y`), only needed to record walkthrough videos.

## Build and run
```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
.\WpfDemo.exe
```
`build.ps1` stops any running `WpfDemo.exe` first, because the compiler can't overwrite an exe that is still running.

## Testing
`test.ps1` launches the app and drives it through Windows UI Automation (no mouse needed). It runs 12 checks and prints `PASS`/`FAIL` for each. Exit code 0 means everything passed.

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
powershell -ExecutionPolicy Bypass -File .\test.ps1
```

| Env var | Effect |
|---|---|
| `STEP_MS` | Delay between UI steps in ms (default 300). Use about 800 so a person or video can follow along. |
| `KEEP_OPEN=1` | Leave the app open after the run. |

What it covers:
- **Regression (existing behavior):** window title, empty start state, empty add rejected, three tasks added, count updates, input clears.
- **Duplicate prevention:** a case-insensitive duplicate is rejected and the list stays unchanged.
- **Remove selected:** removing with no selection shows an error, removing the selected item works, and the plural and singular counts are right.

The tests need an interactive desktop session (UI Automation can't see windows from a non-interactive service session). Run them from a logged-in console or RDP session, or from the Devin VM shell.

### Manual test checklist
1. Run `WpfDemo.exe`. The list is empty and the count reads `0 tasks`.
2. Click **Add** with the box empty. You see `Enter a task first`.
3. Add `Buy milk`, `Ship demo`, `Call Teddy`. The count reads `3 tasks` and the box clears after each add.
4. Add `ship DEMO`. You see `Task already exists` and the list is unchanged.
5. Click **Remove selected** with nothing selected. You see `Select a task to remove`.
6. Select `Ship demo` and click **Remove selected**. The count reads `2 tasks`.

### Recording a walkthrough (optional)
```powershell
ffmpeg -f gdigrab -framerate 15 -i desktop -pix_fmt yuv420p walkthrough.mp4   # press q to stop
```
Run `test.ps1` with `STEP_MS=800` while recording.

## Maintenance
- After editing `App.cs`, run `build.ps1`, then `test.ps1`.
- Give every new control a `Name`, because UI Automation finds controls by that AutomationId. Then add checks to `test.ps1` using the existing `Check` / `Click` / `TypeText` helpers.
- PowerShell gotchas in `test.ps1`: variable names ignore case (`$t` and `$T` are the same variable), `Type` is an alias that wins over a function of the same name, and `$input` is a built-in automatic variable.
