<#
   Tests for accessing the winsqlite3.dll

   Version 0.03
#>

set-strictMode -version 2

[sqliteDB] $db = [sqliteDB]::new("$($pwd)\the.db", $true)

[sqliteDB]::version()

#
#  $db.exec writes warning if statement has error.
#
$db.exec('create table tab(foo, bar, baz' ) # incomplete input
$db.exec('create table tab(foo, bar, baz)')
$db.exec('create table tab(foo, bar, baz)') # table tab already exists

[sqliteStmt] $stmt = $db.prepareStmt('insert into tab values(?, ?, ?)')

$stmt.bind(1,  4 )
$stmt.bind(2, 'A')
$stmt.bind(3,  333)
$null = $stmt.step()

$stmt.reset()
$stmt.bind(1,  88)
$stmt.bind(2, 'BB')
$stmt.bind(3,  $null)
$null = $stmt.step()

$stmt.reset()
$stmt.bind(1,  111)
$stmt.bind(2, 'III')
$stmt.bind(3,  42)
$null = $stmt.step()

$stmt.reset()
$stmt.bindArrayStepReset( ( 44  ,'AA'  ,  99 ))
$stmt.bindArrayStepReset( (444 , 'AAA' , 999 ))

$db.exec('begin transaction')
$stmt.bindArrayStepReset( (555 , 'SSS' , 'trx') )
$stmt.bindArrayStepReset( (333 , 'EEE' , 'trx') )
$db.exec('commit')

$db.exec('begin transaction')
$stmt.bindArrayStepReset( (500 , 'Soo' , 'trx!') )
$stmt.bindArrayStepReset( (300 , 'Eoo' , 'trx!') )
$db.exec('rollback')

$stmt.finalize()

$stmt = $db.prepareStmt('select * from tab where foo > ? order by foo')

write-host "column count of stmt: $($stmt.column_count())"

$stmt.Bind(1, 50)

while ( $stmt.step()  -ne [sqlite]::DONE ) {
   echo "$($stmt.col(0)) | $($stmt.col(1)) | $($stmt.col(2))"
}

$stmt.finalize()
$db.close()
