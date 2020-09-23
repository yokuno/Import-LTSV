function Import-LTSV {
	Param(
		[System.String]$Path,
		[System.String]$Encoding = "UTF8"
	)


	# Description
	# ltsvフォーマット（タブ区切りかつ各要素値は、名前:値　で構成されるフォーマット）をパースしPSCustomObjectを行毎にWrite-Objectします
	#  出力はImport-CSVのようにパイプラインで処理できるPSCustomObject形式です。
	#  各行をタブで区切り、その各値を:で区切った左辺値を名前、右辺値を値としてパースします。
	#  ただし名前に空白を含む場合、無効値としてImportしません
	#  なお、出力する前に全行をパースして、名前をすべて抽出します。
	#  先頭行に限り、すべての名前を持つObjectとして出力します。
	#  このようにすることで、Out-gridviewやExport-CSVですべての列が出力されるようになります。

	# 列名を抽出します
	# ファイルのパース処理を複数回実施した方が、パース結果をメモリ上に保持するより性能（速度、メモリ使用量ともに）が良いので、こうしている。
	$allColumnNames = @()
	foreach ($line in Get-Content $Path -Encoding $Encoding) {
		$item = @{}
		foreach ($col in $line.split("`t")) {
			$colName = ""
			$idx = $col.IndexOf(":")
			if ($idx -gt 0) {
				$colName = $col.SubString(0, $idx)
				if ($colName.IndexOf(" ") -lt 0) {
					if (-Not $allColumnNames.Contains($colName)) {
						$allColumnNames += $colName
					}
				}
			}
			
		}
	}

	# hashobject(PSCustomObject型にcast) の arrayを構築します。
	$isFirstLine = $true;
	foreach ($line in Get-Content $Path -Encoding $Encoding) {
		$item = @{}
		$isEmpty = $true
		foreach ($col in $line.split("`t")) {
			$colName = ""
			$colValue = ""
			$idx = $col.IndexOf(":")
			if ($idx -gt 0) {
				$colName = $col.SubString(0, $idx)
				$colValue = $col.SubString($idx + 1)
				if ($colName.IndexOf(" ") -lt 0) {
					$item.Add($colName, $colValue)
					$isEmpty = $false
				}
			}
		}
		if (-not $isEmpty) {
			# 先頭行のみ全カラムを割り当てます。先頭行のカラムがtableやgridviewにformatする際の列定義になるので。
			$obj = [PSCustomObject]$item
			if ($isFirstLine) {
				foreach ($colName in $allColumnNames) {
					# 同名Memberを追加してもエラーにならないように-ErrorAction SilentlyContinueを指定
					$obj | add-member -membertype noteproperty -name $colName -value "" -ErrorAction SilentlyContinue
				}
				$isFirstLine = $false
			}
			# オブジェクトとして出力。こうすることでout-gridviewコマンドなどにObjectとしてパイプラインで渡せます
			Write-Output $obj
		}
	}
}


Export-ModuleMember -Function Import-LTSV