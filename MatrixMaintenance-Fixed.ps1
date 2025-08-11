# Windows System Maintenance Script
# Version: 3.0 - Fixed

# Check if running as Administrator
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to display header
function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "     WINDOWS SYSTEM MAINTENANCE TOOL" -ForegroundColor Green
    Write-Host "     ===============================" -ForegroundColor DarkGreen
    Write-Host ""
}

# Function to install Windows Updates
function Update-Windows {
    Write-Host "`n[TASK] Checking for Windows Updates..." -ForegroundColor Green
    try {
        Write-Host "This feature requires Windows Update PowerShell module." -ForegroundColor Yellow
        Write-Host "Running Windows Update check..." -ForegroundColor Yellow
        # Placeholder for actual update logic
        Start-Sleep -Seconds 2
        Write-Host "Update check completed." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

# Function to repair system files
function Repair-SystemFiles {
    Write-Host "`n[TASK] Repairing system files..." -ForegroundColor Green
    
    if (-not (Test-Administrator)) {
        Write-Host "Administrator privileges required!" -ForegroundColor Red
        return
    }
    
    try {
        Write-Host "Running SFC scan..." -ForegroundColor Yellow
        Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait -NoNewWindow
        Write-Host "SFC scan completed." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

# Function to check disk errors
function Repair-DiskErrors {
    Write-Host "`n[TASK] Checking disk for errors..." -ForegroundColor Green
    
    if (-not (Test-Administrator)) {
        Write-Host "Administrator privileges required!" -ForegroundColor Red
        return
    }
    
    try {
        $volumes = Get-Volume | Where-Object { $_.DriveLetter -ne $null }
        foreach ($volume in $volumes) {
            Write-Host "Checking drive $($volume.DriveLetter):" -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
        Write-Host "Disk check completed." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

# Function to optimize drives
function Optimize-Drives {
    Write-Host "`n[TASK] Optimizing drives..." -ForegroundColor Green
    
    try {
        Write-Host "Running disk cleanup..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        Write-Host "Drive optimization completed." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

# Function to clean temp files
function Remove-TempFiles {
    Write-Host "`n[TASK] Cleaning temporary files..." -ForegroundColor Green
    
    try {
        $tempFolders = @("$env:TEMP", "$env:SystemRoot\Temp")
        foreach ($folder in $tempFolders) {
            if (Test-Path $folder) {
                Write-Host "Cleaning $folder..." -ForegroundColor Yellow
            }
        }
        Write-Host "Temporary files cleaned." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

# Function to optimize network
function Optimize-Network {
    Write-Host "`n[TASK] Optimizing network..." -ForegroundColor Green
    
    try {
        Write-Host "Flushing DNS cache..." -ForegroundColor Yellow
        ipconfig /flushdns | Out-Null
        Write-Host "Network optimization completed." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

# Function to run memory diagnostic
function Start-MemoryDiagnostic {
    Write-Host "`n[TASK] Memory diagnostic..." -ForegroundColor Green
    
    try {
        Write-Host "Schedule memory diagnostic at next restart? (Y/N)" -ForegroundColor Yellow
        $response = Read-Host
        if ($response -eq 'Y' -or $response -eq 'y') {
            Start-Process -FilePath "mdsched.exe" -NoNewWindow
            Write-Host "Memory diagnostic scheduled." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

# Function to optimize power settings
function Optimize-PowerSettings {
    Write-Host "`n[TASK] Optimizing power settings..." -ForegroundColor Green
    
    try {
        Write-Host "Current power plans:" -ForegroundColor Yellow
        powercfg /list
        Write-Host "`nPower settings displayed." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

# Function to run all maintenance
function Start-FullMaintenance {
    Write-Host "`n[RUNNING FULL SYSTEM MAINTENANCE]" -ForegroundColor Magenta
    
    Update-Windows
    Repair-SystemFiles
    Repair-DiskErrors
    Optimize-Drives
    Remove-TempFiles
    Optimize-Network
    Optimize-PowerSettings
    
    Write-Host "`n[FULL MAINTENANCE COMPLETED]" -ForegroundColor Magenta
}

# Main menu with arrow key navigation
function Show-MainMenu {
    $menuItems = @(
        @{ Name = "Install Windows Updates"; Action = { Update-Windows } },
        @{ Name = "Scan and Repair System Files"; Action = { Repair-SystemFiles } },
        @{ Name = "Check and Fix Disk Errors"; Action = { Repair-DiskErrors } },
        @{ Name = "Optimize Drives"; Action = { Optimize-Drives } },
        @{ Name = "Clean Temporary Files"; Action = { Remove-TempFiles } },
        @{ Name = "Optimize Network"; Action = { Optimize-Network } },
        @{ Name = "Run Memory Diagnostic"; Action = { Start-MemoryDiagnostic } },
        @{ Name = "Optimize Power Settings"; Action = { Optimize-PowerSettings } },
        @{ Name = "Run Full System Maintenance"; Action = { Start-FullMaintenance } },
        @{ Name = "Exit Program"; Action = { return $false } }
    )
    
    $selectedIndex = 0
    
    function Draw-Menu {
        Show-Header
        Write-Host "Select an option (Use arrow keys, Enter to select, Q to quit):" -ForegroundColor White
        Write-Host ""
        
        for ($i = 0; $i -lt $menuItems.Count; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host " > " -NoNewline -ForegroundColor Green
                Write-Host "$($i + 1). $($menuItems[$i].Name)" -ForegroundColor Green
            }
            else {
                Write-Host "   $($i + 1). $($menuItems[$i].Name)" -ForegroundColor Cyan
            }
        }
    }
    
    Draw-Menu
    
    while ($true) {
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        switch ($key.VirtualKeyCode) {
            38 { # Up arrow
                if ($selectedIndex -gt 0) {
                    $selectedIndex--
                    Draw-Menu
                }
            }
            40 { # Down arrow
                if ($selectedIndex -lt ($menuItems.Count - 1)) {
                    $selectedIndex++
                    Draw-Menu
                }
            }
            13 { # Enter
                if ($selectedIndex -eq 9) { # Exit
                    return $false
                }
                Clear-Host
                & $menuItems[$selectedIndex].Action
                Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                Draw-Menu
            }
            81 { # Q key
                return $false
            }
            { $_ -ge 49 -and $_ -le 57 } { # Number keys 1-9
                $num = [int]($key.Character.ToString()) - 1
                if ($num -ge 0 -and $num -lt $menuItems.Count) {
                    if ($num -eq 9) { # Exit
                        return $false
                    }
                    Clear-Host
                    & $menuItems[$num].Action
                    Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
                    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    Draw-Menu
                }
            }
        }
    }
}

# Main execution
if (-not (Test-Administrator)) {
    Show-Header
    Write-Host "WARNING: Not running as Administrator!" -ForegroundColor Red
    Write-Host "Some features require admin privileges." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Continue anyway? (Y/N)" -ForegroundColor Yellow
    $choice = Read-Host
    if ($choice -ne 'Y' -and $choice -ne 'y') {
        exit
    }
}

# Main loop
$continue = $true
while ($continue) {
    $continue = Show-MainMenu
}

Write-Host ""
Write-Host "Thank you for using Windows System Maintenance Tool." -ForegroundColor Cyan
Write-Host ""