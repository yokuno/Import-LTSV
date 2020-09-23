Param(
	[System.String]$Path
)

# ltsvフォーマット（タブ区切りかつ各要素値は、名前:値　で構成されるフォーマット）をパースし
# hashobject(PSCustomObject型にcast) の arrayを構築します。
$allColumnNames = @()
$records = @()
foreach ($line in Get-Content $Path) {
	$item = @{}
	foreach ($col in $line.split("`t")) {
		$colName = ""
		$colValue = ""
		$idx = $col.IndexOf(":")
		if ($idx -gt 0) {
			$colName = $col.SubString(0, $idx)
			$colValue = $col.SubString($idx + 1)
			if (-Not $allColumnNames.Contains($colName)) {
				$allColumnNames += $colName
			}
		}
		else {
			$colName = $col
		}
		$item.Add($colName, $colValue)
		
	}
	$obj = [PSCustomObject]$item
	$records += $obj
}


# 先頭行に全カラムを割り当てます。先頭行のカラムがtableやgridviewにformatする際の列定義になるので。
$firstItem = $records[0]
foreach ($colName in $allColumnNames) {
	# 同名Memberを追加してもエラーにならないように-ErrorAction SilentlyContinueを指定
	$firstItem | add-member -membertype noteproperty -name $colName -value "" -ErrorAction SilentlyContinue
}
$records[0] = $firstItem

# オブジェクトとして出力。こうすることでout-gridviewコマンドなどにObjectとしてパイプラインで渡せます
Write-Output $records
