# Functions のデプロイ資格情報
$username = "nabehiro"
$password = "xEDtY4qFdYWFL"

$resourceName = "resource-01"
$serviceName = "nabehiro-func"


$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

# Disable-Functions.ps1 => Disable-Functions.zip として圧縮
Write-Host "Compress Disable-Functions.ps1"
Compress-Archive -Path Disable-Functions.ps1 -DestinationPath Disable-Functions.zip

# 圧縮ファイルをアップロード
Write-Host "Upload Disable-Functions.zip to Azure"
$apiUrl = "https://" + $serviceName + ".scm.azurewebsites.net/api/zip/site/wwwroot"
$filePath = "Disable-Functions.zip"
Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method PUT -InFile $filePath -ContentType "multipart/form-data"

# Disable-Functions.zip を削除
Remove-Item Disable-Functions.zip

# Disable-Functions.ps1 をサイト上で実行
Write-Host "Execute Disable-Functions.ps1 on Azure"
$apiUrl = "https://" + $serviceName + ".scm.azurewebsites.net/api/command"
$commandBody = @{
    command = "powershell -NoProfile -NoLogo -ExecutionPolicy Unrestricted -File Disable-Functions.ps1"
    dir = "site\\wwwroot"
}
Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method POST -ContentType "application/json" -Body (ConvertTo-Json $commandBody)

# WAIT: 実行中の Functions の終了をまつ。
Write-Host "Sleeping for functions terminate..."
Start-Sleep -Seconds 5

# Azure Login
# TODO: 下記方法だとポータルサイトでログインする必要があるので、Service Principals によるログインに差し替える
# https://azure.microsoft.com/ja-jp/blog/azure-cli-supports-microsoft-account-logins/
Write-Host "Azure Login"
#azure login

# リスタート
Write-Host "Restrt Service"
azure webapp restart $resourceName $serviceName

# WAIT: リスタートが完了するのを待つ
Write-Host "Sleeping for service restart..."
Start-Sleep -Seconds 10

# wwwroot 内の全ファイルを削除
Write-Host "Clear All Files on wwwroot"
$apiUrl = "https://" + $serviceName + ".scm.azurewebsites.net/api/command"
$commandBody = @{
    command = "del /q * && for /D %f in ( * ) do rmdir /s /q `"%f`""
    dir = "site\\wwwroot"
}
Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method POST -ContentType "application/json" -Body (ConvertTo-Json $commandBody)

# TODO: Upload Functions


