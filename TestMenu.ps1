# Simple test script to verify PowerShell syntax
Write-Host "Windows System Maintenance Tool" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor DarkGreen
Write-Host ""

$menuItems = @(
    "1. Install Windows Updates",
    "2. Scan and Repair System Files", 
    "3. Check and Fix Disk Errors",
    "4. Optimize Drives",
    "5. Clean Temporary Files",
    "6. Optimize Network",
    "7. Run Memory Diagnostic",
    "8. Optimize Power Settings",
    "9. Run Full System Maintenance",
    "Q. Exit Program"
)

$selectedIndex = 0

function Show-Menu {
    Clear-Host
    Write-Host "Windows System Maintenance Tool" -ForegroundColor Green
    Write-Host "==============================" -ForegroundColor DarkGreen
    Write-Host ""
    Write-Host "Use arrow keys to select, Enter to confirm:" -ForegroundColor White
    Write-Host ""
    
    for ($i = 0; $i -lt $menuItems.Count; $i++) {
        if ($i -eq $selectedIndex) {
            Write-Host " > $($menuItems[$i])" -ForegroundColor Green
        } else {
            Write-Host "   $($menuItems[$i])" -ForegroundColor Cyan
        }
    }
}

Show-Menu

while ($true) {
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    switch ($key.VirtualKeyCode) {
        38 { # Up arrow
            if ($selectedIndex -gt 0) {
                $selectedIndex--
                Show-Menu
            }
        }
        40 { # Down arrow  
            if ($selectedIndex -lt ($menuItems.Count - 1)) {
                $selectedIndex++
                Show-Menu
            }
        }
        13 { # Enter
            if ($selectedIndex -eq 9) {
                Write-Host "`nExiting..." -ForegroundColor Yellow
                break
            }
            Write-Host "`nYou selected: $($menuItems[$selectedIndex])" -ForegroundColor Green
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Show-Menu
        }
        81 { # Q key
            Write-Host "`nExiting..." -ForegroundColor Yellow
            exit
        }
        57 { # 9 key
            if ($key.Character -eq '9') {
                Write-Host "`nRunning all maintenance tasks..." -ForegroundColor Green
                Write-Host "Press any key to continue..."
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                Show-Menu
            }
        }
    }
}