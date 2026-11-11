# Hindsight 离线包还原脚本（PowerShell 5+，Windows 自带）
# 用法: 在本仓库根目录执行  powershell -ExecutionPolicy Bypass -File .\restore.ps1
# 结果: 在 .\restored\ 下还原出完整 hindsight-offline-kit 目录

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$out  = Join-Path $root "_bundle.tar.gz"
$dst  = Join-Path $root "restored"

$parts = Get-ChildItem (Join-Path $root "parts") -Filter "hindsight-kit.tar.gz.part-*" | Sort-Object Name
if ($parts.Count -eq 0) { throw "parts 目录里没有找到分卷" }
Write-Host "合并 $($parts.Count) 个分卷..."

if (Test-Path $out) { Remove-Item $out -Force }
$fs = [System.IO.File]::Create($out)
foreach ($p in $parts) {
    $bytes = [System.IO.File]::ReadAllBytes($p.FullName)
    $fs.Write($bytes, 0, $bytes.Length)
    Write-Host "  + $($p.Name)"
}
$fs.Close()
Write-Host "合并完成: $out ($([math]::Round((Get-Item $out).Length/1MB,1)) MB)"

if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
New-Item -ItemType Directory -Path $dst | Out-Null
Write-Host "解包中（约 1-3 分钟）..."
tar -xzf $out -C $dst
Remove-Item $out -Force
Write-Host "完成！完整工具包在: $dst"
Write-Host "下一步: 按 restored\README-拷贝说明.md 的位置表部署到目标目录"
