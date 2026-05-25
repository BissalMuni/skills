# printbox/print.ps1
# 기본: 순수 텍스트 파일을 프린터로 조용히 인쇄한다 (Out-Printer — Edge 불필요, 가벼움).
# 인쇄물은 "한 번 읽고 버리는" 용도라 서식보다 속도·안정성을 우선한다.
# -Html 지정 시: 구버전 호환으로 Microsoft Edge --kiosk-printing 서식 인쇄도 지원.
param(
    [string]$Text,
    [string]$Html,
    [string]$Printer = "Canon G1010 series"
)
$ErrorActionPreference = "Stop"

# ── 기본 경로: 순수 텍스트 인쇄 (브라우저 불필요) ──
if ($Text) {
    if (-not (Test-Path $Text)) { throw "파일이 없습니다: $Text" }
    # 기본 프린터를 건드리지 않고 지정 프린터로 바로 인쇄
    Get-Content -LiteralPath $Text -Encoding UTF8 | Out-Printer -Name $Printer
    Write-Output "PRINTED(text) -> $Printer : $Text"
    return
}

if (-not $Html) { throw "-Text 또는 -Html 중 하나를 지정하세요." }

# ── 선택 경로: HTML 서식 인쇄 (Edge --kiosk-printing, 기본 프린터로만 출력) ──
$edge = @(
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $edge) { throw "Microsoft Edge 를 찾을 수 없습니다." }
if (-not (Test-Path $Html)) { throw "파일이 없습니다: $Html" }

$target = Get-CimInstance Win32_Printer -Filter "Name='$Printer'"
if (-not $target) { throw "프린터를 찾을 수 없습니다: $Printer" }

# 현재 기본 프린터 기억 → Canon 으로 임시 변경 → finally 에서 복구
$orig = (Get-CimInstance Win32_Printer | Where-Object { $_.Default }).Name
$udd = Join-Path $env:TEMP ("edgeprint_" + [guid]::NewGuid().ToString("N"))
$uri = "file:///" + (($Html | Resolve-Path).Path -replace '\\', '/')
$wsh = New-Object -ComObject WScript.Network

try {
    $wsh.SetDefaultPrinter($Printer)
    Start-Process $edge -ArgumentList @(
        "--kiosk-printing", "--no-first-run", "--no-default-browser-check",
        "--user-data-dir=$udd", "--new-window", $uri
    ) | Out-Null
    Start-Sleep -Seconds 8
    Get-CimInstance Win32_Process -Filter "Name='msedge.exe'" |
        Where-Object { $_.CommandLine -like "*$udd*" } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
}
finally {
    if ($orig) { try { $wsh.SetDefaultPrinter($orig) } catch {} }
    Remove-Item $udd -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output "PRINTED(html) -> $Printer : $Html"
