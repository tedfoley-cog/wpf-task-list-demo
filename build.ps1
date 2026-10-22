# Builds WpfDemo.exe with the .NET Framework 4.x compiler that ships with Windows (no SDK needed).
$ErrorActionPreference = "Stop"
$fw = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319"
if (-not (Test-Path "$fw\csc.exe")) { throw ".NET Framework 4.x compiler not found at $fw" }
Get-Process WpfDemo -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 300
& "$fw\csc.exe" -nologo -target:winexe -out:"$PSScriptRoot\WpfDemo.exe" `
  -r:"$fw\WPF\PresentationCore.dll" -r:"$fw\WPF\PresentationFramework.dll" `
  -r:"$fw\WPF\WindowsBase.dll" -r:"$fw\System.Xaml.dll" "$PSScriptRoot\App.cs"
if ($LASTEXITCODE -ne 0) { throw "Build failed" }
Write-Host "Built $PSScriptRoot\WpfDemo.exe"
