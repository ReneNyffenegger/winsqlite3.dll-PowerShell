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

$stmtIns.bindArrayStepReset( (1,                  1 ))
$stmtIns.bindArrayStepReset( (2,                 -2 ))
$stmtIns.bindArrayStepReset( (3,        0x987654321 )) # 64 bit number
$stmtIns.bindArrayStepReset( (4, 0xffffffffffffffff )) # 64 bit number
$stmtIns.bindArrayStepReset( (5,'0xfedcba9876543210')) # String
$stmtIns.bindArrayStepReset( (6,              12.34 )) # Real (Double)
$stmtIns.bindArrayStepReset( (7,              $null ))

$stmtIns.finalize()

$stmtSel = $db.prepareStmt('select * from T order by id')

compare_next_row $stmtSel  1                   1
compare_next_row $stmtSel  2                  -2
compare_next_row $stmtSel  3         0x987654321
compare_next_row $stmtSel  4                  -1    # -1 == 0xffffffffffffffff in 64-bit
compare_next_row $stmtSel  5 '0xfedcba9876543210'
compare_next_row $stmtSel  6               12.34
compare_next_row $stmtSel  7               $null

$stmtSel.finalize()

$db.close()
