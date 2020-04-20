set-strictMode -version latest

function compare_row($stmt, $id, $expected_val, $expected_length) {

   $stmt.reset()
   $stmt.Bind(1, $id)

   if ($stmt.step() -eq [sqlite]::DONE) {
      write-warning 'DONE not expected'
   }

   if ($stmt.col(0) -ne $expected_val) {
      write-warning "id = $id`: expected val: $expected_val, got $($stmt.col(0))"
   }
   if ($stmt.col(1) -ne $expected_length) {
      write-warning "id = $id`: expected length $expected_length, got $($stmt.col(1))"
   }

   if ($stmtSel.step() -ne [sqlite]::DONE) {
      write-warning "expected: DONE"
   }
}

[sqliteDB] $db = [sqliteDB]::new("$($pwd)\encoding.db", $true)


$db.exec('create table T (
    id   integer primary key,
    txt  text
)')

$db.exec("insert into T values(1, 'aouAOUBe')")
$db.exec("insert into T values(2, 'הצüִײÜßי')")

$stmtIns = $db.prepareStmt('insert into T values (?, ?)');
$stmtIns.bindArrayStepReset( ( 3, 'eBUOAuoa' ) )
$stmtIns.bindArrayStepReset( ( 4, 'יßÜײִüצה' ) )
$stmtIns.finalize()

$stmtSel = $db.prepareStmt('select txt, length(txt) len from T where id = ?')

compare_row $stmtSel 1 'aouAOUBe' 8
compare_row $stmtSel 2 'הצüִײÜßי' 8
compare_row $stmtSel 3 'eBUOAuoa' 8
compare_row $stmtSel 4 'יßÜײִüצה' 8

$stmtSel.finalize()

$db.close()
