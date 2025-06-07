<#
.SYNOPSIS
Matrix-Themed System Maintenance Script for Windows

.DESCRIPTION
This PowerShell script provides advanced system maintenance functions including:
- Windows Update installation
- System file checking and repair
- Disk optimization and cleanup
- Error scanning and fixing
- System performance optimization
- Temporary file cleanup
- DNS cache flushing
- Network optimization
- Memory diagnostic
- Power plan optimization

.NOTES
Author: System Administrator
Version: 2.0
#>

# Function to check if script is running as administrator
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to restart the script with admin privileges
function Restart-ScriptAsAdmin {
    $scriptPath = $MyInvocation.MyCommand.Path
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    try {
        Start-Process PowerShell -ArgumentList $arguments -Verb RunAs
        return $true
    } catch {
        Write-MatrixText "Failed to restart script as admin: $_" "Red"
        return $false
    }
}

# Function to display Matrix-style falling text animation
function Show-MatrixRain {
    param (
        [int]$Duration = 3,
        [int]$Speed = 50
    )
    
    $originalBackground = $Host.UI.RawUI.BackgroundColor
    $originalForeground = $Host.UI.RawUI.ForegroundColor
    
    try {
        $Host.UI.RawUI.BackgroundColor = "Black"
        Clear-Host
        
        $width = $Host.UI.RawUI.WindowSize.Width
        $height = $Host.UI.RawUI.WindowSize.Height
        
        # Create arrays for tracking characters and their positions
        $chars = @()
        $positions = @()
        $speeds = @()
        $colors = @()
        
        # Initialize with random starting points
        for ($i = 0; $i -lt ($width / 2); $i++) {
            $chars += [char](Get-Random -Minimum 33 -Maximum 126)
            $positions += @{
                X = Get-Random -Minimum 0 -Maximum $width
                Y = Get-Random -Minimum -10 -Maximum 0
            }
            $speeds += (Get-Random -Minimum 1 -Maximum 3) / 10
            
            # Mostly green with occasional white, cyan or yellow
            $colorRoll = Get-Random -Minimum 1 -Maximum 20
            switch ($colorRoll) {
                { $_ -le 15 } { $colors += "Green" }
                { $_ -gt 15 -and $_ -le 17 } { $colors += "DarkGreen" }
                { $_ -gt 17 -and $_ -le 19 } { $colors += "Cyan" }
                { $_ -eq 20 } { $colors += "White" }
            }
        }
        
        $startTime = Get-Date
        $endTime = $startTime.AddSeconds($Duration)
        
        while ((Get-Date) -lt $endTime) {
            for ($i = 0; $i -lt $chars.Count; $i++) {
                # Clear previous position
                if ($positions[$i].Y -ge 0 -and $positions[$i].Y -lt $height) {
                    [Console]::SetCursorPosition($positions[$i].X, $positions[$i].Y)
                    Write-Host " " -NoNewline
                }
                
                # Update position
                $positions[$i].Y += $speeds[$i]
                
                # Draw new position if it's on screen
                if ($positions[$i].Y -ge 0 -and $positions[$i].Y -lt $height) {
                    [Console]::SetCursorPosition($positions[$i].X, $positions[$i].Y)
                    Write-Host $chars[$i] -ForegroundColor $colors[$i] -NoNewline
                }
                
                # Reset if off-screen
                if ($positions[$i].Y -ge $height) {
                    $positions[$i].Y = 0
                    $positions[$i].X = Get-Random -Minimum 0 -Maximum $width
                    $chars[$i] = [char](Get-Random -Minimum 33 -Maximum 126)
                }
            }
            
            Start-Sleep -Milliseconds $Speed
        }
    }
    finally {
        $Host.UI.RawUI.BackgroundColor = $originalBackground
        $Host.UI.RawUI.ForegroundColor = $originalForeground
        Clear-Host
    }
}

# Function to display Matrix-style text typing
function Write-MatrixText {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$ForegroundColor = "Green",
        
        [Parameter(Mandatory=$false)]
        [switch]$NoNewline,
        
        [Parameter(Mandatory=$false)]
        [int]$TypeSpeed = 10
    )
    
    # Make important messages stand out more with text "glitching"
    $shouldGlitch = ($ForegroundColor -eq "Red" -or $ForegroundColor -eq "Yellow" -or $ForegroundColor -eq "Magenta")
    
    for ($i = 0; $i -lt $Message.Length; $i++) {
        # Randomly "glitch" characters for warnings and errors
        if ($shouldGlitch -and (Get-Random -Minimum 1 -Maximum 10) -eq 1) {
            $glitchChar = [char](Get-Random -Minimum 33 -Maximum 126)
            Write-Host $glitchChar -ForegroundColor $ForegroundColor -NoNewline
            Start-Sleep -Milliseconds 30
            [Console]::SetCursorPosition([Console]::CursorLeft-1, [Console]::CursorTop)
            Write-Host $Message[$i] -ForegroundColor $ForegroundColor -NoNewline
        } else {
            Write-Host $Message[$i] -ForegroundColor $ForegroundColor -NoNewline
        }
        
        # Vary typing speed slightly for more natural effect
        $delay = Get-Random -Minimum ($TypeSpeed/2) -Maximum ($TypeSpeed*1.5)
        Start-Sleep -Milliseconds $delay
    }
    
    if (-not $NoNewline) {
        Write-Host ""
    }
}

# Function to show a progress bar with Matrix effect
function Show-MatrixProgress {
    param (
        [string]$Activity,
        [int]$DurationSeconds,
        [string]$Color = "Green"
    )
    
    # Create matrix-style characters
    $matrixChars = @('0','1','0','1')
    
    Write-MatrixText "`n$Activity" $Color
    
    $origPos = $host.UI.RawUI.CursorPosition
    $width = $host.UI.RawUI.WindowSize.Width - 10
    
    # Draw empty progress bar
    Write-Host "["  -NoNewline
    for ($i = 0; $i -lt $width; $i++) {
        Write-Host " " -NoNewline
    }
    Write-Host "]" -NoNewline
    
    # Reset cursor to start of progress bar
    $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates ($origPos.X + 1), $origPos.Y
    
    $startTime = Get-Date
    $endTime = $startTime.AddSeconds($DurationSeconds)
    
    while ((Get-Date) -lt $endTime) {
        $percentComplete = (((Get-Date) - $startTime).TotalSeconds / $DurationSeconds) * 100
        $completedWidth = [Math]::Floor(($percentComplete / 100) * $width)
        
        # Reset cursor position
        $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates ($origPos.X + 1), $origPos.Y
        
        # Fill in the bar with matrix characters
        for ($i = 0; $i -lt $completedWidth; $i++) {
            $charIdx = Get-Random -Minimum 0 -Maximum $matrixChars.Count
            Write-Host $matrixChars[$charIdx] -ForegroundColor $Color -NoNewline
        }
        
        Start-Sleep -Milliseconds 100
    }
    
    # Ensure the bar is completely filled at the end
    $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates ($origPos.X + 1), $origPos.Y
    for ($i = 0; $i -lt $width; $i++) {
        $charIdx = Get-Random -Minimum 0 -Maximum $matrixChars.Count
        Write-Host $matrixChars[$charIdx] -ForegroundColor $Color -NoNewline
    }
    
    Write-Host "`n" # Add a newline after the progress bar
}

# Function to display an attractive header
function Show-Header {
    Clear-Host
    $headerColor = "Green"
    
    Write-Host ""
    $ascii = @"
     ███▄ ▄███▓ ▄▄▄     ▄▄▄█████▓ ██▀███   ██▓▒██   ██▒
    ▓██▒▀█▀ ██▒▒████▄   ▓  ██▒ ▓▒▓██ ▒ ██▒▓██▒▒▒ █ █ ▒░
    ▓██    ▓██░▒██  ▀█▄ ▒ ▓██░ ▒░▓██ ░▄█ ▒▒██▒░░  █   ░
    ▒██    ▒██ ░██▄▄▄▄██░ ▓██▓ ░ ▒██▀▀█▄  ░██░ ░ █ █ ▒ 
    ▒██▒   ░██▒ ▓█   ▓██▒ ▒██▒ ░ ░██▓ ▒██▒░██░▒██▒ ▒██▒
    ░ ▒░   ░  ░ ▒▒   ▓▒█░ ▒ ░░   ░ ▒▓ ░▒▓░░▓  ▒▒ ░ ░▓ ░
    ░  ░      ░  ▒   ▒▒ ░   ░      ░▒ ░ ▒░ ▒ ░░░   ░▒ ░
    ░      ░     ░   ▒    ░        ░░   ░  ▒ ░ ░    ░  
           ░         ░  ░           ░      ░   ░    ░  
   ▄▄▄      ▓█████▄  ███▄ ▄███▓ ██▓ ███▄    █  ██▓  ██████ ▄▄▄█████▓ ██▀███   ▄▄▄     ▄▄▄█████▓ ▒█████   ██▀███  
  ▒████▄    ▒██▀ ██▌▓██▒▀█▀ ██▒▓██▒ ██ ▀█   █ ▓██▒▒██    ▒ ▓  ██▒ ▓▒▓██ ▒ ██▒▒████▄   ▓  ██▒ ▓▒▒██▒  ██▒▓██ ▒ ██▒
  ▒██  ▀█▄  ░██   █▌▓██    ▓██░▒██▒▓██  ▀█ ██▒▒██▒░ ▓██▄   ▒ ▓██░ ▒░▓██ ░▄█ ▒▒██  ▀█▄ ▒ ▓██░ ▒░▒██░  ██▒▓██ ░▄█ ▒
  ░██▄▄▄▄██ ░▓█▄   ▌▒██    ▒██ ░██░▓██▒  ▐▌██▒░██░  ▒   ██▒░ ▓██▓ ░ ▒██▀▀█▄  ░██▄▄▄▄██░ ▓██▓ ░ ▒██   ██░▒██▀▀█▄  
   ▓█   ▓██▒░▒████▓ ▒██▒   ░██▒░██░▒██░   ▓██░░██░▒██████▒▒  ▒██▒ ░ ░██▓ ▒██▒ ▓█   ▓██▒ ▒██▒ ░ ░ ████▓▒░░██▓ ▒██▒
   ▒▒   ▓▒█░ ▒▒▓  ▒ ░ ▒░   ░  ░░▓  ░ ▒░   ▒ ▒ ░▓  ▒ ▒▓▒ ▒ ░  ▒ ░░   ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░ ▒ ░░   ░ ▒░▒░▒░ ░ ▒▓ ░▒▓░
    ▒   ▒▒ ░ ░ ▒  ▒ ░  ░      ░ ▒ ░░ ░░   ░ ▒░ ▒ ░░ ░▒  ░ ░    ░      ░▒ ░ ▒░  ▒   ▒▒ ░   ░      ░ ▒ ▒░   ░▒ ░ ▒░
    ░   ▒    ░ ░  ░ ░      ░    ▒ ░   ░   ░ ░  ▒ ░░  ░  ░    ░        ░░   ░   ░   ▒    ░      ░ ░ ░ ▒    ░░   ░ 
        ░  ░   ░           ░    ░           ░  ░        ░               ░           ░  ░            ░ ░     ░     
             ░                                                                                                     
"@
    Write-Host $ascii -ForegroundColor $headerColor
    
    Write-MatrixText "    The system is a prison for your mind. We're here to set it free." "DarkGreen"
    Write-MatrixText "    [Running system diagnostics and optimization routines...]" "Yellow"
    Write-Host ""
}

# Function to check for and install Windows updates
function Update-Windows {
    Write-MatrixText "`n[TASK] Initializing Windows Update Protocol..." "Green"
    try {
        # Install PSWindowsUpdate module if not present
        if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            Write-MatrixText "Module not detected. Installing PSWindowsUpdate..." "Yellow"
            
            # Check if running as admin
            if (Test-Administrator) {
                Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
            } else {
                Write-MatrixText "Warning: Not running as administrator. Attempting alternate installation vector..." "Yellow"
                Install-Module -Name PSWindowsUpdate -Force -Confirm:$false -Scope CurrentUser
            }
        }
        
        # Import the module
        Import-Module PSWindowsUpdate
        
        # Check for updates
        Write-MatrixText "Scanning the Matrix for anomalies (updates)..." "Yellow"
        Show-MatrixProgress "Connecting to update servers..." 3 "Cyan"
        
        $updates = Get-WindowsUpdate
        
        if ($updates.Count -eq 0) {
            Write-MatrixText "System is up to date. No anomalies detected." "Green"
        } else {
            Write-MatrixText "Detected $($updates.Count) system anomalies requiring patching." "Yellow"
            Write-MatrixText "Initiating system patching sequence. This may take some time..." "Yellow"
            
            # Install updates
            Show-MatrixProgress "Installing updates..." 5 "Yellow"
            Install-WindowsUpdate -AcceptAll -AutoReboot:$false
            
            Write-MatrixText "Windows update protocols completed successfully!" "Green"
        }
    } catch {
        Write-MatrixText "Error updating Windows: $_" "Red"
    }
    
    Write-MatrixText "Update sequence completed." "Green"
}

# Function to scan for and fix system file errors
function Repair-SystemFiles {
    Write-MatrixText "`n[TASK] Repairing system corruption..." "Green"
    
    # Check if running as admin
    if (-not (Test-Administrator)) {
        Write-MatrixText "ACCESS DENIED: Administrator privileges required for system file repair!" "Red"
        Write-MatrixText "SFC and DISM commands will fail without proper access rights." "Yellow"
        Write-MatrixText "Do you wish to restart with administrator access? (Y/N)" "Yellow"
        $choice = Read-Host
        if ($choice -eq "Y" -or $choice -eq "y") {
            if (Restart-ScriptAsAdmin) {
                return
            }
        }
    }
    
    try {
        # Run SFC scan
        Write-MatrixText "Initializing System File Checker (SFC)..." "Yellow"
        Show-MatrixProgress "Scanning for file corruption..." 3 "Green"
        $sfc = Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait -PassThru -NoNewWindow
        
        if ($sfc.ExitCode -eq 0) {
            Write-MatrixText "SFC scan completed. System file integrity verified." "Green"
        } else {
            Write-MatrixText "SFC scan encountered issues. Exit code: $($sfc.ExitCode)" "Yellow"
        }
        
        # Run DISM
        Write-MatrixText "Initializing DISM repair protocols..." "Yellow"
        Show-MatrixProgress "Checking system image health..." 2 "Cyan"
        Start-Process -FilePath "DISM.exe" -ArgumentList "/Online /Cleanup-Image /CheckHealth" -Wait -NoNewWindow
        
        Show-MatrixProgress "Scanning system image..." 3 "Cyan"
        Start-Process -FilePath "DISM.exe" -ArgumentList "/Online /Cleanup-Image /ScanHealth" -Wait -NoNewWindow
        
        Write-MatrixText "Repairing Windows image integrity..." "Yellow"
        Show-MatrixProgress "Restoring system health..." 5 "Green"
        $dism = Start-Process -FilePath "DISM.exe" -ArgumentList "/Online /Cleanup-Image /RestoreHealth" -Wait -PassThru -NoNewWindow
        
        if ($dism.ExitCode -eq 0) {
            Write-MatrixText "DISM repair completed successfully. System integrity restored." "Green"
        } else {
            Write-MatrixText "DISM repair encountered issues. Exit code: $($dism.ExitCode)" "Yellow"
        }
    } catch {
        Write-MatrixText "Error repairing system files: $_" "Red"
    }
    
    Write-MatrixText "System file repair protocols completed." "Green"
}

# Function to check and fix disk errors
function Repair-DiskErrors {
    Write-MatrixText "`n[TASK] Scanning storage sectors for corruption..." "Green"
    
    # Check if running as admin
    if (-not (Test-Administrator)) {
        Write-MatrixText "ACCESS DENIED: Administrator privileges required for disk operations!" "Red"
        Write-MatrixText "Disk checking operations will fail without proper access rights." "Yellow"
        Write-MatrixText "Do you wish to restart with administrator access? (Y/N)" "Yellow"
        $choice = Read-Host
        if ($choice -eq "Y" -or $choice -eq "y") {
            if (Restart-ScriptAsAdmin) {
                return
            }
        }
    }
    
    try {
        # Get all volumes
        $volumes = Get-Volume | Where-Object { $_.DriveLetter -ne $null }
        
        foreach ($volume in $volumes) {
            $driveLetter = $volume.DriveLetter
            Write-MatrixText "Scanning drive $($driveLetter): for anomalies..." "Yellow"
            Show-MatrixProgress "Analyzing drive sectors..." 2 "Cyan"
            
            # Run chkdsk (read-only mode)
            $chkdsk = Start-Process -FilePath "chkdsk.exe" -ArgumentList "$($driveLetter):" -Wait -PassThru -NoNewWindow
            
            if ($chkdsk.ExitCode -eq 0) {
                Write-MatrixText "No corruption detected on drive $($driveLetter):." "Green"
            } else {
                Write-MatrixText "Drive $($driveLetter): corruption detected. Would you like to schedule repairs at next reboot? (Y/N)" "Yellow"
                $response = Read-Host
                
                if ($response -eq "Y" -or $response -eq "y") {
                    Write-MatrixText "Scheduling disk repair for drive $($driveLetter): at next system restart..." "Yellow"
                    Start-Process -FilePath "chkdsk.exe" -ArgumentList "$($driveLetter): /f /r" -Wait -NoNewWindow
                    Write-MatrixText "Repair scheduled for drive $($driveLetter):. Reboot required to execute." "Green"
                } else {
                    Write-MatrixText "Repair operation aborted for drive $($driveLetter):." "Yellow"
                }
            }
        }
    } catch {
        Write-MatrixText "Error checking disk: $_" "Red"
    }
    
    Write-MatrixText "Disk error analysis completed." "Green"
}

# Function to optimize drives
function Optimize-Drives {
    Write-MatrixText "`n[TASK] Optimizing storage subsystems..." "Green"
    
    # Check if running as admin
    if (-not (Test-Administrator)) {
        Write-MatrixText "ACCESS DENIED: Administrator privileges required for drive optimization!" "Red"
        Write-MatrixText "Disk cleanup and optimization operations will fail without proper access rights." "Yellow"
        Write-MatrixText "Do you wish to restart with administrator access? (Y/N)" "Yellow"
        $choice = Read-Host
        if ($choice -eq "Y" -or $choice -eq "y") {
            if (Restart-ScriptAsAdmin) {
                return
            }
        }
    }
    
    try {
        # Run disk cleanup
        Write-MatrixText "Initializing advanced disk cleanup protocols..." "Yellow"
        Show-MatrixProgress "Removing digital debris..." 3 "Green"
        
        # Use advanced cleanup with all options
        $cleanupParams = @("/SAGESET:1")
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList $cleanupParams -Wait -NoNewWindow -Verb RunAs
        
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/SAGERUN:1" -Wait -NoNewWindow
        
        # Get all volumes
        $volumes = Get-Volume | Where-Object { $_.DriveLetter -ne $null -and $_.DriveType -eq "Fixed" }
        
        foreach ($volume in $volumes) {
            $driveLetter = $volume.DriveLetter
            Write-MatrixText "Optimizing drive $($driveLetter): data structures..." "Yellow"
            Show-MatrixProgress "Defragmenting drive $($driveLetter):..." 4 "Cyan"
            
            # Run defrag/optimize with verbose output
            Optimize-Volume -DriveLetter $driveLetter -Verbose
            
            Write-MatrixText "Drive $($driveLetter): optimization completed successfully." "Green"
        }
    } catch {
        Write-MatrixText "Error optimizing drives: $_" "Red"
    }
    
    Write-MatrixText "Storage optimization protocols completed." "Green"
}

# NEW FUNCTION: Clean temporary files
function Remove-TempFiles {
    Write-MatrixText "`n[TASK] Purging system cache and temporary files..." "Green"
    
    try {
        # Common temp locations
        $tempFolders = @(
            "$env:TEMP",
            "$env:SystemRoot\Temp",
            "$env:SystemRoot\Prefetch",
            "$env:USERPROFILE\AppData\Local\Temp",
            "$env:USERPROFILE\AppData\Local\Microsoft\Windows\INetCache"
        )
        
        $totalFreed = 0
        
        foreach ($folder in $tempFolders) {
            if (Test-Path $folder) {
                Write-MatrixText "Analyzing $folder..." "Yellow"
                
                # Get size before cleanup
                $sizeBefore = Get-ChildItem -Path $folder -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
                
                # Remove files
                Show-MatrixProgress "Removing temporary files..." 2 "Cyan"
                Get-ChildItem -Path $folder -Recurse -Force -ErrorAction SilentlyContinue | 
                    Where-Object { !$_.PSIsContainer } | 
                    ForEach-Object {
                        try {
                            Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
                        } catch {
                            # Silently continue on files in use
                        }
                    }
                
                # Get size after cleanup
                $sizeAfter = Get-ChildItem -Path $folder -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
                
                # Calculate freed space
                $beforeSize = if ($sizeBefore.Sum) { $sizeBefore.Sum } else { 0 }
                $afterSize = if ($sizeAfter.Sum) { $sizeAfter.Sum } else { 0 }
                $freed = $beforeSize - $afterSize
                $totalFreed += $freed
                
                # Convert to readable format
                $freedMB = [Math]::Round($freed / 1MB, 2)
                
                Write-MatrixText "Recovered $freedMB MB from $folder" "Green"
            }
        }
        
        $totalFreedMB = [Math]::Round($totalFreed / 1MB, 2)
        Write-MatrixText "Total space recovered: $totalFreedMB MB" "Green"
        
    } catch {
        Write-MatrixText "Error cleaning temporary files: $_" "Red"
    }
    
    Write-MatrixText "Temporary file cleanup completed." "Green"
}

# NEW FUNCTION: Optimize network
function Optimize-Network {
    Write-MatrixText "`n[TASK] Optimizing network connectivity..." "Green"
    
    try {
        # Flush DNS cache
        Write-MatrixText "Flushing DNS resolver cache..." "Yellow"
        Show-MatrixProgress "Clearing DNS records..." 2 "Cyan"
        ipconfig /flushdns
        
        # Reset Winsock catalog
        Write-MatrixText "Resetting Winsock catalog..." "Yellow"
        Show-MatrixProgress "Rebuilding network catalog..." 2 "Yellow"
        netsh winsock reset
        
        # Reset TCP/IP stack
        Write-MatrixText "Resetting TCP/IP stack..." "Yellow"
        Show-MatrixProgress "Resetting network protocols..." 3 "Green"
        netsh int ip reset
        
        # Release and renew IP
        Write-MatrixText "Renewing IP configuration..." "Yellow"
        Show-MatrixProgress "Requesting new IP address..." 3 "Cyan"
        ipconfig /release
        ipconfig /renew
        
        Write-MatrixText "Network optimization completed. You may need to restart to apply all changes." "Green"
    } catch {
        Write-MatrixText "Error optimizing network: $_" "Red"
    }
    
    Write-MatrixText "Network protocols reset and optimized." "Green"
}

# NEW FUNCTION: Run memory diagnostic
function Start-MemoryDiagnostic {
    Write-MatrixText "`n[TASK] Initiating memory diagnostic sequence..." "Green"
    
    try {
        Write-MatrixText "Preparing to run Windows Memory Diagnostic Tool..." "Yellow"
        Write-MatrixText "NOTE: This will schedule a memory test at next system restart." "Magenta"
        Write-MatrixText "Would you like to schedule the memory test? (Y/N)" "Yellow"
        $response = Read-Host
        
        if ($response -eq "Y" -or $response -eq "y") {
            Write-MatrixText "Scheduling memory diagnostic..." "Yellow"
            Show-MatrixProgress "Setting up memory test parameters..." 2 "Cyan"
            
            # Schedule the memory diagnostic
            Start-Process -FilePath "mdsched.exe" -NoNewWindow
            
            Write-MatrixText "Memory diagnostic scheduled for next system restart." "Green"
            Write-MatrixText "Please save your work and restart your computer to run the test." "Yellow"
        } else {
            Write-MatrixText "Memory diagnostic cancelled." "Yellow"
        }
    } catch {
        Write-MatrixText "Error scheduling memory diagnostic: $_" "Red"
    }
    
    Write-MatrixText "Memory diagnostic protocol completed." "Green"
}

# NEW FUNCTION: Optimize power settings
function Optimize-PowerSettings {
    Write-MatrixText "`n[TASK] Optimizing power configuration..." "Green"
    
    try {
        # Get current power plan
        $currentPlan = powercfg /getactivescheme
        Write-MatrixText "Current power plan: $currentPlan" "Yellow"
        
        Write-MatrixText "Available power plans:" "Yellow"
        powercfg /list
        
        Write-MatrixText "`nWhich power plan would you like to use?" "Yellow"
        Write-MatrixText "1. Balanced (recommended for most users)" "Cyan"
        Write-MatrixText "2. High Performance (maximum speed, higher power usage)" "Cyan"
        Write-MatrixText "3. Power Saver (maximum battery life, reduced performance)" "Cyan"
        Write-MatrixText "4. Keep current setting" "Cyan"
        
        $choice = Read-Host
        
        switch ($choice) {
            "1" {
                Write-MatrixText "Setting power plan to Balanced..." "Yellow"
                Show-MatrixProgress "Configuring power settings..." 2 "Green"
                powercfg /setactive SCHEME_BALANCED
                Write-MatrixText "Power plan set to Balanced." "Green"
            }
            "2" {
                Write-MatrixText "Setting power plan to High Performance..." "Yellow"
                Show-MatrixProgress "Configuring power settings..." 2 "Green"
                powercfg /setactive SCHEME_MIN_POWER_SAVINGS
                Write-MatrixText "Power plan set to High Performance." "Green"
            }
            "3" {
                Write-MatrixText "Setting power plan to Power Saver..." "Yellow"
                Show-MatrixProgress "Configuring power settings..." 2 "Green"
                powercfg /setactive SCHEME_MAX_POWER_SAVINGS
                Write-MatrixText "Power plan set to Power Saver." "Green"
            }
            "4" {
                Write-MatrixText "Keeping current power settings." "Yellow"
            }
            default {
                Write-MatrixText "Invalid choice. Keeping current power settings." "Yellow"
            }
        }
    } catch {
        Write-MatrixText "Error optimizing power settings: $_" "Red"
    }
    
    Write-MatrixText "Power optimization completed." "Green"
}

# Function to run all maintenance tasks
function Start-FullMaintenance {
    Show-MatrixRain -Duration 3 -Speed 30
    
    Write-MatrixText "`n[INITIALIZING COMPLETE SYSTEM MAINTENANCE PROTOCOL]" "Magenta"
    
    Update-Windows
    Repair-SystemFiles
    Repair-DiskErrors
    Optimize-Drives
    Remove-TempFiles
    Optimize-Network
    Optimize-PowerSettings
    
    Write-MatrixText "`n[FULL SYSTEM MAINTENANCE PROTOCOLS COMPLETED SUCCESSFULLY]" "Magenta"
    Show-MatrixRain -Duration 2 -Speed 40
}

# Main menu function
function Show-MainMenu {
    Show-Header
    
    Write-MatrixText "Select operation:" "White"
    
    $menuItems = @(
        @{ Number = "1"; Description = "Install Windows Updates"; Function = "Update-Windows"; Color = "Cyan" },
        @{ Number = "2"; Description = "Scan and Repair System Files"; Function = "Repair-SystemFiles"; Color = "Cyan" },
        @{ Number = "3"; Description = "Check and Fix Disk Errors"; Function = "Repair-DiskErrors"; Color = "Cyan" },
        @{ Number = "4"; Description = "Optimize Drives"; Function = "Optimize-Drives"; Color = "Cyan" },
        @{ Number = "5"; Description = "Clean Temporary Files"; Function = "Remove-TempFiles"; Color = "Cyan" },
        @{ Number = "6"; Description = "Optimize Network"; Function = "Optimize-Network"; Color = "Cyan" },
        @{ Number = "7"; Description = "Run Memory Diagnostic"; Function = "Start-MemoryDiagnostic"; Color = "Cyan" },
        @{ Number = "8"; Description = "Optimize Power Settings"; Function = "Optimize-PowerSettings"; Color = "Cyan" },
        @{ Number = "9"; Description = "Run Full System Maintenance"; Function = "Start-FullMaintenance"; Color = "Green" },
        @{ Number = "Q"; Description = "Exit Program"; Function = "Exit"; Color = "Red" }
    )
    
    foreach ($item in $menuItems) {
        Write-MatrixText "$($item.Number). " -NoNewline
        Write-MatrixText "$($item.Description)" $item.Color
    }
    
    Write-Host ""
    $choice = Read-Host "Enter your choice"
    
    switch ($choice) {
        "1" { Update-Windows; break }
        "2" { Repair-SystemFiles; break }
        "3" { Repair-DiskErrors; break }
        "4" { Optimize-Drives; break }
        "5" { Remove-TempFiles; break }
        "6" { Optimize-Network; break }
        "7" { Start-MemoryDiagnostic; break }
        "8" { Optimize-PowerSettings; break }
        "9" { Start-FullMaintenance; break }
        "Q" { return $false }
        "q" { return $false }
        default { 
            Write-MatrixText "Invalid option. Access denied." "Red"
            Start-Sleep -Seconds 1
        }
    }
    
    return $true
}

# Initial Matrix animation
Show-MatrixRain -Duration 3 -Speed 30

# Main script execution
# Check if running as administrator at script startup
if (-not (Test-Administrator)) {
    Show-Header
    Write-Host ""
    Write-MatrixText "ACCESS RESTRICTED: Administrator privileges required." "Red"
    Write-MatrixText "System maintenance operations require elevated access rights." "Yellow"
    Write-MatrixText "Would you like to request administrator access? (Y/N)" "Yellow"
    $choice = Read-Host
    if ($choice -eq "Y" -or $choice -eq "y") {
        Restart-ScriptAsAdmin
        exit
    } else {
        Write-MatrixText "Continuing with limited functionality. Some operations may fail." "Yellow"
        Start-Sleep -Seconds 2
    }
}

$continue = $true
while ($continue) {
    $continue = Show-MainMenu
    if ($continue) {
        Write-MatrixText "`nPress any key to return to the command interface..." "Yellow"
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

Write-MatrixText "`nThank you for using the Matrix System Maintenance Protocol." "Cyan"
Write-MatrixText "Remember, all I'm offering is the truth. Nothing more." "Green"
Show-MatrixRain -Duration 2 -Speed 40