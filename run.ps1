param([int]$Port = 0)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$taskPython = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $taskPython)) {
    throw 'Chưa có môi trường Python. Chạy setup.ps1 trước.'
}
$env:PYTHONUNBUFFERED = '1'
$env:PYTHONIOENCODING = 'utf-8'
Write-Host 'Đang khởi động F Smart Memories...' -ForegroundColor Cyan
Write-Host 'Trình duyệt mặc định sẽ tự mở khi ứng dụng sẵn sàng.'
Write-Host 'Giữ cửa sổ này mở khi dùng ứng dụng. Nhấn Ctrl+C để dừng.'
$portArgs = if ($Port -gt 0) { @('--port', $Port) } else { @() }
& $taskPython -u scripts/launch.py @portArgs
if ($LASTEXITCODE -ne 0) {
    throw "Ứng dụng không khởi động được (mã lỗi $LASTEXITCODE). Xem thông báo phía trên."
}
