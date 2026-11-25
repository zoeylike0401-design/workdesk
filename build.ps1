$publicAssets = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'assets.json') -Raw | ConvertFrom-Json
foreach ($asset in $publicAssets.PSObject.Properties) {
 $assetPath = Join-Path (Join-Path $PSScriptRoot 'assets') $asset.Name
 New-Item -ItemType Directory -Path (Split-Path $assetPath -Parent) -Force | Out-Null
 [IO.File]::WriteAllBytes($assetPath,[Convert]::FromBase64String($asset.Value))
}
$ErrorActionPreference = 'Stop'
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$avatarResources = 0..5 | ForEach-Object { "/resource:$PSScriptRoot\assets\avatars\$_.png,ReferenceAvatar$_" }
& $compiler /nologo /target:winexe /win32icon:"$PSScriptRoot\assets\workbench.ico" /out:"$PSScriptRoot\像素工作台.exe" /reference:System.Windows.Forms.dll /reference:System.Drawing.dll /reference:System.Web.Extensions.dll /resource:"$PSScriptRoot\assets\workbench.ico,WorkbenchIcon" @avatarResources "$PSScriptRoot\Workbench.cs" "$PSScriptRoot\Theme.cs" "$PSScriptRoot\Embedded.cs"
if ($LASTEXITCODE -ne 0) { throw '编译失败' }
