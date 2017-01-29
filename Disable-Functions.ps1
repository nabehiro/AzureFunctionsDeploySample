# すべての Function の実行を無効にする。
# site/wwwroot で実行される前提。
# 無効にすると、実行中の Function のキャンセルトークンの IsCancellationRequested が true になる。

$files = Get-ChildItem "*\function.json"

foreach($file in $files)
{
    $content = $(Get-Content $file.FullName) -replace "`"disabled`": false","`"disabled`": true"
    $content > $file.FullName
}