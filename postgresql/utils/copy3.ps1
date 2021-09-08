# Excel操作　シートの操作編

##### 実行は未確認. 実装のみのステータス

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

# $book($template)を$book2に複写してシート名を$nameに変更する

function copyTemplate($book, $template, $book2, $name) {

# copy
	# シート $name をコピーする
	#（先頭）
	# $book.Worksheets.item($name).copy($book2.Worksheets.item(1))
	#（最後）
	$book.Worksheets.item($template).copy([System.Reflection.Missing]::Value, $book2.Worksheets.item($book2.WorkSheets.count))

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

function copyTemplate2($sheet, $book2, $name) {

# copy
	# シート $name をコピーする
	#（先頭）
	# $book.Worksheets.item($name).copy($book2.Worksheets.item(1))
	#（最後）
	$sheet.copy([System.Reflection.Missing]::Value, $book2.worksheets.item($book2.worksheets.count))

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
function copyTemplate3($book, $tmpl, $book2, $name) {
	$sheet = $book.worksheets.item($tmpl)
	copyTemplate4 $sheet $book2 $name
}

# 
#

$script:INDEX = 0;

function findLast($sheet, $col, $row) {
	for ($ix = 0; $ix -lt 1000; $ix++) {
		$val = $sheet.Cells.item($row + $ix, $col).Text
		if ($val -eq "") {
			$script:INDEX = $ix
			return
		}
	}
	$script:INDEX = $ix - 1
	echo "findLast: INDEX=[$script:INDEX]"
}



function copyCell($book, $book2, $name, $row, $col) {
	$sheet = $book.worksheets.item($name)
	$sheet2 = $book2.worksheets.item(1)

	findLast $sheet $row $col
	$script:INDEX = $ix
	
#	Write-Output "sheet=[" + $sheet + "] sheet2=[" + $sheet2 + "]";
	for ($ix = 0; $ix -lt $script:INDEX; $ix++) {
		$val = $sheet.Cells.item($row + $ix, $col).Text
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

# $sheet の ($c_col, $c_row) のセルからデータが存在する行($INDEX)までを
# $sheet の ($s_col, $s_row):($s_col + $INDEX, $s_row + $size)の領域を
# $sheet2の ($p_col, $p_row)を始点とする複写する

function copyRange2($sheet, $sheet2, $c_col, $c_row, $s_col, $s_row, $p_col, $p_row, $size) {

	findLast $sheet $c_col $c_row

	$e_row = $s_row + $script:INDEX
	$e_col = $s_col + $size

	Write-Output (">>> start: row=[" + ($s_row) + "] col=[" + ($s_col) + "]")
	Write-Output (">>> end  : row=[" + ($e_row) + "] col=[" + ($e_col) + "]")
	Write-Output (">>> paste: row=[" + ($p_row) + "] col=[" + ($p_col) + "]")

# 複数のセルを一括コピー
	$start1 = $sheet.cells.item($s_row, $s_col)
	$end1   = $sheet.cells.item($e_row, $e_col)
	$start2 = $sheet2.cells.item($p_row, $p_pos)
	$end2   = $sheet2.cells.item($p_row + $script:INDEX, $p_col + $size)
	$sheet.range($start1, $end1).copy($sheet2.range($start2, $end2))
}

# $book($name) の ($c_col, $c_row) のセルからデータが存在する行($INDEX)までを
# $book($name) の ($s_col, $s_row):($s_col + $INDEX, $s_row + $size)の領域を
# $book2($name)の ($p_col, $p_row)を始点とする複写する
# ※シート名が異なる複写には利用できない => copyRange2を使用のこと

function copyRange3($book, $book2, $name, $c_col, $c_row, $s_col, $s_row, $p_col, $p_row, $size) {
	$sheet  = $book.worksheets.item($name)
	$sheet2 = $book2.worksheets.item($name)
	copyRange2 $sheet $sheet2 $c_col $c_row $s_col $s_row $p_col $p_row $size
}

#--------------------------------
# Excelを操作する為の宣言
$excel = New-Object -ComObject Excel.Application

# 可視化する
$excel.Visible = $true

# 既存のExcelファイルを開く
$book = $excel.workbooks.Open("C:\Users\gohdo\2021勤務表.xlsx")

# ブックを新規作成して、そのオブジェクトを取得
$book2  = $excel.workbooks.Add()

# シートを追加する("sheet2" ...)
# $book2.worksheets.add()

# --- loop

# テンプレートとして"202107"を使う
$sheet  = $book.worksheets.item("212107")

copyTemplate $sheet $book2 "202108"

$sheet2 = $book2.worksheets.item("202108")

# 入力データ領域を初期化
$book2.worksheets.item("202108").range("c3:f33").ClearContents()

# データを一括コピー
copyRange2 $sheet $sheet2 3 1 3 1 3 1 3

# --- loop end

# ブックを新規作成した場合はsheet1を削除
$book2.worksheets.item("sheet1").delete()

# 上書き保存
#$book.Save()

# 画面を閉じる
$book.close()

# Excelを閉じる
#$excel.Quit()

# プロセスを解放する
$excel = $null
[GC]::Collect()
