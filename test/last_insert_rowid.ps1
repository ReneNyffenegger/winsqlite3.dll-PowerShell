<#

   Test for last_insert_rowid()

#>

set-strictMode -version latest

function compare_next_row($stmt, $expected_id, $expected_val) {

   if ($stmt.step() -eq [sqlite]::DONE) {
      write-warning 'DONE not expected'
   }
   if ($stmt.col(0) -ne $expected_id) {
      write-warning "expected $expected_id"
   }
   if ($stmt.col(1) -ne $expected_val) {
      write-warning "expected $expected_val"
   }

}

[sqliteDB] $db = [sqliteDB]::new("$($pwd)\last_insert_rowid.db", $true)

$db.exec('create table T (
    id   integer primary key,
    val  text
)')

$db.exec("insert into T (val) values ('foo')");
if ($db.last_insert_rowid() -ne 1) {
   write-warning 'expected rowid 1'
}

$db.exec("insert into T values (null, 'bar')");
if ($db.last_insert_rowid() -ne 2) {
   write-warning 'expected rowid 2'
}

$db.exec("insert into T values (42, 'baz')");
if ($db.last_insert_rowid() -ne 42) {
   write-warning 'expected rowid 42'
}

$db.exec("insert into T (val) values ('next')");
if ($db.last_insert_rowid() -ne 43) {
   write-warning 'expected rowid 43'
}

$stmt = $db.prepareStmt('select * from T order by id')

compare_next_row $stmt  1 'foo'
compare_next_row $stmt  2 'bar'
compare_next_row $stmt 42 'baz'
compare_next_row $stmt 43 'next'

if ($stmt.step() -ne [sqlite]::DONE) {
   write-warning 'expected: DONE'
}

$stmt.finalize()
$db.close()
