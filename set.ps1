$ErrorActionPreference = 'Stop'

$BaseUrl = 'https://d.kotoca.net'
$InstallDir = Join-Path $HOME '.local/libexec/d'
$LogicFile = Join-Path $InstallDir 'd.ps1'

Write-Host "1. ディレクトリ作成: $InstallDir"
New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null

Write-Host '2. 本体（d.ps1）の取得'
Invoke-WebRequest -Uri "$BaseUrl/d.ps1" -OutFile $LogicFile

Write-Host '3. PowerShell プロファイルへの登録'
$profileDir = Split-Path -Parent $PROFILE
New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
if (-not (Test-Path -LiteralPath $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File | Out-Null
}

$marker = '# d - interactive directory navigator'
$funcDef = @"
$marker
function d {
    . '$LogicFile'
}
"@

$profileContent = Get-Content -LiteralPath $PROFILE -Raw
if ($profileContent -notmatch 'function\s+d\s*\{') {
    Add-Content -LiteralPath $PROFILE -Value "`n$funcDef"
    Write-Host "✅ $PROFILE に関数 'd' を追加しました。"
}
else {
    Write-Host "ℹ️ $PROFILE には既に関数が登録されています。"
}

Write-Host '------------------------------------'
Write-Host 'インストール完了'
Write-Host '新しい設定を反映するには、PowerShell を再起動するか以下を実行してください:'
Write-Host ". $PROFILE"
Write-Host '------------------------------------'
