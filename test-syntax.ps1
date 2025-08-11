try {
    $scriptContent = Get-Content ".\MatrixMaintenance.ps1" -Raw
    $null = [scriptblock]::Create($scriptContent)
    Write-Host "Script syntax is valid!" -ForegroundColor Green
} catch {
    Write-Host "Script has syntax errors:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Host "Error at line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Yellow
}