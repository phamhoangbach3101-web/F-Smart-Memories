param([string]$Python = 'python', [switch]$SkipModels, [switch]$SkipCPUOptimization, [switch]$SkipSemanticSearch, [switch]$WithLocalChat, [switch]$WithSubjectTools)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$taskTemp = Join-Path $PSScriptRoot '.cache\tmp'
New-Item -ItemType Directory -Force -Path $taskTemp | Out-Null
$env:TEMP = $taskTemp
$env:TMP = $taskTemp
$taskPython = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $taskPython)) {
    & $Python -m venv .venv
    if ($LASTEXITCODE -ne 0) { throw 'Cần Python 3.10–3.12 thực, không phải shortcut Microsoft Store.' }
}
& $taskPython -m pip install -r requirements.txt -r requirements-dev.txt
if ($LASTEXITCODE -ne 0) { throw 'Không cài được các thư viện ứng dụng.' }
& $taskPython -c 'import torch, torchvision'
if ($LASTEXITCODE -ne 0) {
    & $taskPython -m pip install -r requirements-ml.txt --index-url https://download.pytorch.org/whl/cpu
    if ($LASTEXITCODE -ne 0) { throw 'Không cài được PyTorch CPU.' }
}
if (-not $SkipModels) {
    & $taskPython scripts/fetch_assets.py
    if ($LASTEXITCODE -ne 0) { throw 'Chưa tải đủ model. Kiểm tra kết nối và chạy lại scripts/fetch_assets.py.' }
}
if (-not $SkipCPUOptimization) {
    & $taskPython -m pip install -r requirements-cpu.txt
    if ($LASTEXITCODE -ne 0) { throw 'Không cài được OpenVINO. Có thể chạy lại với -SkipCPUOptimization để dùng PyTorch.' }
    if (-not $SkipModels) {
        & $taskPython scripts/prepare_cpu.py
        if ($LASTEXITCODE -ne 0) { throw 'Chưa chuẩn bị được CPU. App vẫn có PyTorch dự phòng; xem lỗi ở trên.' }
    }
}
if (-not $SkipSemanticSearch) {
    & $taskPython -m pip install -r requirements-semantic.txt
    if ($LASTEXITCODE -ne 0) { throw 'Không cài được tìm kiếm AI. Có thể dùng -SkipSemanticSearch để bỏ qua.' }
    if (-not $SkipModels) {
        & $taskPython scripts/fetch_semantic.py
        if ($LASTEXITCODE -ne 0) { throw 'Chưa tải đủ SigLIP 2. Chạy lại scripts/fetch_semantic.py khi có mạng.' }
    }
}
if ($WithLocalChat -or $WithSubjectTools) {
    & $taskPython -m pip install -r requirements-semantic.txt
    if ($LASTEXITCODE -ne 0) { throw 'Không cài được thư viện model tùy chọn.' }
    if (-not $SkipModels) {
        if ($WithLocalChat) { & $taskPython scripts/fetch_chat_cpu.py; if ($LASTEXITCODE -ne 0) { throw 'Không tải được chat CPU.' } }
        if ($WithSubjectTools) { & $taskPython scripts/fetch_segmentation.py; if ($LASTEXITCODE -ne 0) { throw 'Không tải được SAM 2.' } }
    }
}
Write-Host 'Sẵn sàng. Chạy .\run.ps1 và mở http://127.0.0.1:8000'
