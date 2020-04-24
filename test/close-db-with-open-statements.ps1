# vi: ft=conf
set-strictMode -version latest

[sqliteDB] $db = [sqliteDB]::new("$($pwd)\registry.db", $true)

$db.exec('create table T(c)')

[sqliteStmt] $stmt_1 = $db.prepareStmt('insert into T values (?)'   )
[sqliteStmt] $stmt_2 = $db.prepareStmt('select * from T where c > ?')

[IntPtr] $stmt_handle_1 = $db.nextStmt(0)
[IntPtr] $stmt_handle_2 = $db.nextStmt($stmt_handle_1)
[IntPtr] $stmt_handle_  = $db.nextStmt($stmt_handle_2)

#
# Of course, I just assume that nextStmt returns the
# handles in reverse order of how they were created.
#
if ($stmt_handle_1 -ne $stmt_2.handle) {
   write-warning "handles of statement 1 differ"
}

if ($stmt_handle_2 -ne $stmt_1.handle) {
   write-warning "handles of statement 2 differ"
}

if ($stmt_handle_ -ne 0) {
   write-warning "expected statement handle of 0"
}

$db.close()
