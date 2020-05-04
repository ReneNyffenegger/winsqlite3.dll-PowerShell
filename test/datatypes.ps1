#
#  Version 0.05
#
set-strictMode -version latest

function compare_next_row($stmt, $expected_id, $expected_val) {

   if ($stmt.step() -eq [sqlite]::DONE) {
      write-warning 'DONE not expected'
   }
   if ($stmt.col(0) -ne $expected_id) {
      write-warning "expected id $expected_id, got $($stmt.col(0))"
   }
   if ($stmt.col(1) -ne $expected_val) {
      write-warning "expected val $expected_val, got $($stmt.col(1))"
   }
}


[sqliteDB] $db = [sqliteDB]::new("$($pwd)\datatypes.db", $true)

$db.exec('create table T (
    id   integer primary key,
    val
)')


$stmtIns = $db.prepareStmt('insert into T values (?, ?)');

[byte[]] $byteArray = 42, 99, 255, 2, 18, 37, 0, 127, 222, 199

$stmtIns.bindArrayStepReset( ( 1,                  1 ))
$stmtIns.bindArrayStepReset( ( 2,                 -2 ))
$stmtIns.bindArrayStepReset( ( 3,        0x987654321 )) # 64 bit number
$stmtIns.bindArrayStepReset( ( 4, 0xffffffffffffffff )) # 64 bit number
$stmtIns.bindArrayStepReset( ( 5,'0xfedcba9876543210')) # String
$stmtIns.bindArrayStepReset( ( 6,              12.34 )) # Real (Double)
$stmtIns.bindArrayStepReset( ( 7,              $null ))
$stmtIns.bindArrayStepReset( ( 8,              $true ))
$stmtIns.bindArrayStepReset( ( 9,              $false))
$stmtIns.bindArrayStepReset( (10,              $true ))
$stmtIns.bindArrayStepReset( (11,              $false))
$stmtIns.bindArrayStepReset( (12, $byteArray         ))


$stmtIns.finalize()

$stmtSel = $db.prepareStmt('select * from T order by id')

compare_next_row $stmtSel  1                   1
compare_next_row $stmtSel  2                  -2
compare_next_row $stmtSel  3         0x987654321
compare_next_row $stmtSel  4                  -1    # -1 == 0xffffffffffffffff in 64-bit
compare_next_row $stmtSel  5 '0xfedcba9876543210'
compare_next_row $stmtSel  6               12.34
compare_next_row $stmtSel  7               $null
compare_next_row $stmtSel  8               $true
compare_next_row $stmtSel  9               $false
compare_next_row $stmtSel 10                   1   # $true  is stored as 1
compare_next_row $stmtSel 11                   0   # $false is stored as 0

if ($stmtSel.step() -eq [sqlite]::DONE) {
   write-warning 'DONE not expected'
}
if ($stmtSel.col(0) -ne 12) {
   write-warning "expected id 12, got $($stmtSel.col(0))"
}

if ($stmtSel.column_type(1) -ne [sqlite]::BLOB ) {
   write-warning "expected BLOB"
}

$arySel = $stmtSel.col(1)
if (-not ($arySel -is [Byte[]])) {
    write-warning "expected byte array, got $($arySel.GetType().FullName)"
}

if ($arySel.length -ne $byteArray.length) {
   write-warning "byte array length differs: $($arySel.length) -ne $($byteArray.length)"
}

for ($i = 0; $i -lt $arySel.length; $i++ ) {

  if ($arySel[$i].GetType().FullName -ne 'System.Byte') {
      write-warning $arySel[$i].GetType().FullName
  }
  if ($arySel[$i] -ne $byteArray[$i]) {
      write-warning "Byte $i differs ($($arySel[$i]) <> $($byteArray[$i]))"
  }
}

if ($stmtSel.step() -ne [sqlite]::DONE) {
   write-warning 'DONE expected'
}


$stmtSel.finalize()

$db.close()
