# Excel操作　シートの操作編

# copy $book($name) to $book2
function copySheet($book, $book2, $name) {

# copy
	# シート $name をコピーする
	#（先頭）
	# $book.Worksheets.item($name).copy($book2.Worksheets.item(1))
	#（最後）
	$book.Worksheets.item($name).copy([System.Reflection.Missing]::Value, $book2.Worksheets.item($book2.WorkSheets.count))

# rename
	# 指定のシートのシート名を変更する
	# $book2.WorkSheets.item(1).name = $name

# move
	# シートを最後(正確には"sheet1"の後ろ)に移す
	# $book2.WorkSheets.item(1).Move([System.Reflection.Missing]::Value, $book2.WorkSheets.item("sheet1"))
	# シートを最後(正確には"sheet1"の後ろ)に移す
	# $book2.WorkSheets.item(1).Move($book2.WorkSheets.item("sheet1"))
	# シートを最後に移す
	# $book2.WorkSheets.item(1).Move($book2.WorkSheets.item($book2.WorkSheets.count))
}

function copyTemplate($book, $book2, $name) {

# copy
	# シート $name をコピーする
	#（先頭）
	# $book.Worksheets.item($name).copy($book2.Worksheets.item(1))
	#（最後）
	$book.Worksheets.item("template").copy([System.Reflection.Missing]::Value, $book2.Worksheets.item($book2.WorkSheets.count))

# rename
	# 指定のシートのシート名を変更する
	$book2.WorkSheets.item($book2.WorkSheets.count).name = $name

# move
	# シートを最後(正確には"sheet1"の後ろ)に移す
	# $book2.WorkSheets.item(1).Move([System.Reflection.Missing]::Value, $book2.WorkSheets.item("sheet1"))
	# シートを最後(正確には"sheet1"の後ろ)に移す
	# $book2.WorkSheets.item(1).Move($book2.WorkSheets.item("sheet1"))
	# シートを最後に移す
	# $book2.WorkSheets.item(1).Move($book2.WorkSheets.item($book2.WorkSheets.count))

# delete
	# $book2.WorkSheets.item("sheet1").delete()
}

function copyCell($book, $book2, $name, $row, $col) {
	$sheet = $book.worksheets.item($name)
	$sheet2 = $book2.worksheets.item(1)
#	Write-Output "sheet=[" + $sheet + "] sheet2=[" + $sheet2 + "]";
	for ($ix = 0; $ix -lt 1000; $ix++) {
		$val = $sheet.Cells.item($row + $ix, $col).Text
		if ($val -eq "") {
			break
		}
#		Write-Output ("row=[" + ($row + $ix) + "] col=[" + $col + "] " + "val=[" + $val + "]")
# 特定セルのみをコピー
		$sheet2.cells.item($row + $ix, $col) = $val
	}
}

# $book($name)のシートのcell($row, $col)からデータが存在する行($row + α)までを検索し
# range(cell($row, $pos), cell($row + α, $pos + $size))の領域を$book2に複写する
function copyRange($book, $book2, $name, $row, $col, $pos, $size) {
	$sheet = $book.worksheets.item($name)
	$sheet2 = $book2.worksheets.item(1)
#	Write-Output "sheet=[" + $sheet + "] sheet2=[" + $sheet2 + "]";
	for ($ix = 0; $ix -lt 1000; $ix++) {
		$val = $sheet.Cells.item($row + $ix, $col).Text
		if ($val -eq "") {
			break
		}
	}
	Write-Output (">>> start: row=[" + ($row) + "] col=[" + ($pos) + "]")
	Write-Output (">>> end:   row=[" + ($row + $ix - 1) + "] col=[" + ($pos + $size) + "]")

# 複数のセルを一括コピー
	$start1 = $sheet.cells.item($row, $pos)
	$end1   = $sheet.cells.item($row + $ix - 1, $pos + $size)
	$start2 = $sheet2.cells.item($row, $pos)
	$end2   = $sheet2.cells.item($row + $ix - 1, $pos + $size)
	$sheet.range($start1, $end1).copy($sheet2.range($start2, $end2))
}

#--------------------------------
# Excelを操作する為の宣言
$excel = New-Object -ComObject Excel.Application

# 可視化する
$excel.Visible = $true

# 既存のExcelファイルを開く
$book = $excel.Workbooks.Open("C:\Users\gohdo\2021勤務表.xlsx")

# ブックを新規作成して、そのオブジェクトを取得
$book2  = $excel.Workbooks.Add()

# シートを追加する("sheet2" ...)
# $book2.WorkSheets.add()

# copyExcel $book $book2 "202104";
# copyExcel $book $book2 "202105";
# copyExcel $book $book2 "202106";
# copyExcel $book $book2 "202107";
#foreach ($sheet in $args) {
#	copyExcel $book $book2 $sheet;
#}

# テンプレートとして"202107"を使う
copyTemplate $book2 $book2 "202107"
# 入力データ領域を初期化
$book2.worksheets.item("202107").range("c3:f33").ClearContents()
# データを一括コピー
copyRange $book $book2 "202104" 3 1 3 3;

# ブックを新規作成した場合はsheet1を削除
$book2.WorkSheets.item("sheet1").delete()

# 上書き保存
#$book.Save()

# 画面を閉じる
$book.close()

# Excelを閉じる
#$excel.Quit()

# プロセスを解放する
$excel = $null
[GC]::Collect()
