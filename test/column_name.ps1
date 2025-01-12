set-strictMode -version latest

[sqliteDB] $db = [sqliteDB]::new("$($pwd)\column_names.db", $true)

$db.exec('create table T (
    id     integer primary key,
    txt    text,
    COL_1,
    col_2
)')

$stmt = $db.prepareStmt('select * from T')

$colCount = $stmt.column_count()
if ($colCount -ne 4) { write-error "colCount should be 4" }
if ($stmt.column_name(0) -cne 'id'   ) {write-error 'column_name(0) should be id'   }
if ($stmt.column_name(1) -cne 'txt'  ) {write-error 'column_name(1) should be txt'  }
if ($stmt.column_name(2) -cne 'COL_1') {write-error 'column_name(1) should be COL_1'}
if ($stmt.column_name(4) -cne 'col_2') {write-error 'column_name(1) should be col_2'}

$stmt.finalize()
$db.close()
