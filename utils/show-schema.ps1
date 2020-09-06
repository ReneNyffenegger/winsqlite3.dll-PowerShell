#
#  vim:  ft=conf
#
#  Version 0.01
#
set-strictMode -version latest

if ($args.count -lt 1) {
   write-host 'show-schema  database-file'
   return
}

$dbFile = $args[0]

if (! (test-path $dbFile -pathType leaf ) ) {
   write-host "$dbFile is not a file"
   return
}

[sqliteDB]   $db   = [sqliteDB]::new($dbFile)
[sqliteStmt] $stmt = $db.prepareStmt('select * from sqlite_master')

while ( $stmt.step()  -ne [sqlite]::DONE ) {

   write-host ('{0,-30} ({1})' -f $stmt.col(1), $stmt.col(0)) -foreGroundColor yellow
   write-host $stmt.col(4)
   write-host ''
}


$stmt.finalize()
$db.close()
