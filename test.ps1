# Regression suite for WpfDemo.exe (UI Automation). Exit code 0 = all pass.
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing
$A = [System.Windows.Automation.AutomationElement]; $Scope = [System.Windows.Automation.TreeScope]
$Invoke = [System.Windows.Automation.InvokePattern]::Pattern; $Value = [System.Windows.Automation.ValuePattern]::Pattern
$Select = [System.Windows.Automation.SelectionItemPattern]::Pattern
$delay = if ($env:STEP_MS) { [int]$env:STEP_MS } else { 300 }
$script:fails = 0
function Check($name, $actual, $expected) {
  if ("$actual" -eq "$expected") { Write-Host "PASS  $name" -ForegroundColor Green }
  else { Write-Host "FAIL  $name (expected '$expected', got '$actual')" -ForegroundColor Red; $script:fails++ } }

Get-Process WpfDemo -EA 0 | Stop-Process
$p = Start-Process "$PSScriptRoot\WpfDemo.exe" -PassThru
$win = $null; for ($i=0; $i -lt 40 -and -not $win; $i++) { Start-Sleep -m 250
  $win = $A::RootElement.FindFirst($Scope::Children, (New-Object System.Windows.Automation.PropertyCondition($A::ProcessIdProperty, $p.Id))) }
if (-not $win) { Write-Host "FAIL  window not found"; exit 1 }
function By($id) { $win.FindFirst($Scope::Descendants, (New-Object System.Windows.Automation.PropertyCondition($A::AutomationIdProperty, $id))) }
$box = By "TaskInput"; $add = By "AddButton"; $remove = By "RemoveButton"; $status = By "StatusText"; $list = By "TaskList"
function StepWait { Start-Sleep -m $delay }
function TypeText($text) { $box.GetCurrentPattern($Value).SetValue($text); StepWait }
function Click($el) { $el.GetCurrentPattern($Invoke).Invoke(); StepWait }
function Items { ($list.FindAll($Scope::Children, [System.Windows.Automation.Condition]::TrueCondition) | % { $_.Current.Name }) -join ", " }
function SelectItem($name) { $list.FindAll($Scope::Children, [System.Windows.Automation.Condition]::TrueCondition) | ? { $_.Current.Name -eq $name } | % { $_.GetCurrentPattern($Select).Select() }; StepWait }

Write-Host "--- Existing behavior (regression) ---"
Check "window title" $win.Current.Name "WPF Task List"
Check "starts empty" $status.Current.Name "0 tasks"
Click $add;  Check "empty add rejected" $status.Current.Name "Enter a task first"
foreach ($task in "Buy milk","Ship demo","Call Teddy") { TypeText $task; Click $add }
Check "three tasks added" (Items) "Buy milk, Ship demo, Call Teddy"
Check "count updates" $status.Current.Name "3 tasks"
Check "input clears" $box.GetCurrentPattern($Value).Current.Value ""

Write-Host "--- New: duplicate prevention ---"
TypeText "ship DEMO"; Click $add
Check "duplicate rejected" $status.Current.Name "Task already exists"
Check "list unchanged" (Items) "Buy milk, Ship demo, Call Teddy"

Write-Host "--- New: remove selected ---"
$box.GetCurrentPattern($Value).SetValue(""); Click $remove
Check "remove with no selection" $status.Current.Name "Select a task to remove"
SelectItem "Ship demo"; Click $remove
Check "selected task removed" (Items) "Buy milk, Call Teddy"
Check "count after remove" $status.Current.Name "2 tasks"
SelectItem "Buy milk"; Click $remove
Check "singular count" $status.Current.Name "1 task"

$r = $win.Current.BoundingRectangle
$bmp = New-Object System.Drawing.Bitmap ([int]$r.Width), ([int]$r.Height)
[System.Drawing.Graphics]::FromImage($bmp).CopyFromScreen([int]$r.X, [int]$r.Y, 0, 0, $bmp.Size)
$bmp.Save("$PSScriptRoot\wpf-demo.png")
if ($env:KEEP_OPEN -ne "1") { $p | Stop-Process }
if ($script:fails) { Write-Host "$($script:fails) FAILED" -ForegroundColor Red; exit 1 } else { Write-Host "ALL PASSED" -ForegroundColor Green; exit 0 }
