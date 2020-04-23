#
#  Version 0.06
#
set-strictMode -version 2

function utf8PointerToStr([IntPtr]$charPtr) {
  [OutputType([String])]
 #
 # Create a .NET/PowerShell string from the bytes
 # that are pointed at by $charPtr
 #
   [IntPtr] $i = 0
   [IntPtr] $len = 0

   while ( [Runtime.InteropServices.Marshal]::ReadByte($charPtr, $len) -gt 0 ) {
     $len=$len+1
   }
   [byte[]] $byteArray = new-object byte[] $len

   while ( [Runtime.InteropServices.Marshal]::ReadByte($charPtr, $i) -gt 0 ) {
      $byteArray[$i] = [Runtime.InteropServices.Marshal]::ReadByte($charPtr, $i)
       $i=$i+1
   }

   return [System.Text.Encoding]::UTF8.GetString($byteArray)
}

function strToUtf8Pointer([String] $str) {
   [OutputType([IntPtr])]
 #
 # Create a UTF-8 byte array on the unmanaged heap
 # from $str and return a pointer to that array
 #

   [Byte[]] $bytes      = [System.Text.Encoding]::UTF8.GetBytes($str);

 # Zero terminated bytes
   [Byte[]] $bytes0    = new-object 'Byte[]' ($bytes.Length + 1)
   [Array]::Copy($bytes, $bytes0, $bytes.Length)

   [IntPtr] $heapPtr = [Runtime.InteropServices.Marshal]::AllocHGlobal($bytes0.Length);
   [Runtime.InteropServices.Marshal]::Copy($bytes0, 0, $heapPtr, $bytes0.Length);

   return $heapPtr
}

class sqliteDB {

   [IntPtr] hidden $db

   sqliteDB(
      [string] $dbFileName,
      [bool  ] $new
   ) {

   if ($new) {
      if (test-path $dbFileName) {
         remove-item $dbFileName # Don't use '-errorAction ignore' to get error message
      }
   }

   $this.open($dbFileName, $new)

   }

   sqliteDB(
      [string] $dbFileName
   ) {
      $this.open($dbFileName, $false)
   }

   [void] hidden open(
      [string] $dbFileName,
      [bool  ] $new
   ) {
    #
    # This method is not intended to be called directly, but
    # rather indirectly via the class's constructor.
    # This construct is necessary because PowerShell does not allow for
    # constructor chaining.
    #   See https://stackoverflow.com/a/44414513
    # This is also the reason why this method is declared hidden.
    #

   [IntPtr] $db_ = 0
   $res = [sqlite]::open($dbFileName, [ref] $db_)
   $this.db = $db_
      if ($res -ne [sqlite]::OK) {
         throw "Could not open $dbFileName"
      }
   }


   [void] exec(
      [String]$sql
   ) {

     [String]$errMsg = ''
     [IntPtr] $heapPtr = strToUtf8Pointer($sql)
      $res = [sqlite]::exec($this.db, $heapPtr, 0, 0, [ref] $errMsg)
      [Runtime.InteropServices.Marshal]::FreeHGlobal($heapPtr);

      if ($res -ne [sqlite]::OK) {
         write-warning "sqliteExec: $errMsg"
      }

   }

   [sqliteStmt] prepareStmt(
      [String] $sql
   ) {

      $stmt = [sqliteStmt]::new($this)
      [IntPtr] $handle_ = 0
      $res = [sqlite]::prepare_v2($this.db, $sql, -1, [ref] $handle_, 0)
      $stmt.handle = $handle_

      if ($res -ne [sqlite]::OK) {
         write-warning "prepareStmt: sqlite3_prepare failed, res = $res"
         write-warning ($this.errmsg())
         return $null
      }
      return $stmt
   }


   [void] close() {
      $res = [sqlite]::close($this.db)

      if ($res -ne [sqlite]::OK) {

         if ($res -eq [sqlite]::BUSY) {
            write-warning "Close database: database is busy"
         }
         else {
            write-warning "Close database: $res"
            write-warning ($this.errmsg())
         }
         write-error ($this.errmsg())
         throw "Could not close database"
      }
   }

   [Int64] last_insert_rowid() {
       return [sqlite]::last_insert_rowid($this.db)
   }

   [String] errmsg() {
      return utf8PointerToStr ([sqlite]::errmsg($this.db))
   }

   static [String] version() {
      $h = [kernel32]::GetModuleHandle('winsqlite3.dll')
      if ($h -eq 0) {
         return 'winsqlite3.dll is probably not yet loaded'
      }
      $a = [kernel32]::GetProcAddress($h, 'sqlite3_version')
      return utf8PointerToStr $a
   }
}

class sqliteStmt {

   [IntPtr  ] hidden $handle
   [sqliteDB] hidden $db

 #
 # Poor man's management of allocated memory on the heap.
 # This is necessary(?) because the SQLite statement interface expects
 # a char* pointer when binding text. This char* pointer must
 # still be valid at the time when the statement is executed.
 # I was unable to achieve that without allocating a copy of the
 # string's bytes on the heap and then release it after the
 # statement-step is executed.
 # There are possibly more elegant ways to achieve this, who knows?
 #
   [IntPtr[]] hidden $heapAllocs

   sqliteStmt([sqliteDB] $db_) {
      $this.db         = $db_
      $this.handle     =   0
      $this.heapAllocs = @()
   }

   [void] bind(
      [Int   ] $index,
      [Object] $value
   ) {

      if ($value -eq $null) {
         $res = [sqlite]::bind_null($this.handle, $index)
      }
      elseif ($value -is [String]) {
         [IntPtr] $heapPtr = strToUtf8Pointer($value)

       #
       # The fourth parameter to sqlite3_bind_text() specifies the
       # length of data that is pointed at in the third parameter ($heapPtr).
       # A negative value indicates that the data is terminated by a byte
       # whose value is zero.
       #
         $res = [sqlite]::bind_text($this.handle, $index, $heapPtr, -1, 0)

       #
       # Keep track of allocations on heap, free later
       #
         $this.heapAllocs += $heapPtr
      }
      elseif ( $value -is [Int32]) {
         $res = [sqlite]::bind_int($this.handle, $index, $value)
      }
      elseif ( $value -is [Int64]) {
         $res = [sqlite]::bind_int64($this.handle, $index, $value)
      }
      elseif ( $value -is [Double]) {
         $res = [sqlite]::bind_double($this.handle, $index, $value)
      }
      elseif ( $value -is [Bool]) {
         $res = [sqlite]::bind_double($this.handle, $index, $value)
      }
      else {
         throw "type $($value.GetType()) not (yet?) supported"
      }

      if ($res -eq [sqlite]::OK) {
         return
      }

      if ($res -eq [SQLite]::MISUSE) {
         write-warning $this.db.errmsg()
         throw "sqliteBind: interface was used in undefined/unsupported way (index = $index, value = $value)"
      }

      if ($res -eq [SQLite]::RANGE) {
         throw "sqliteBind: index $index with value = $value is out of range"
      }

      write-warning $this.db.errmsg()
      write-warning "index: $index, value: $value"
      throw "sqliteBind: res = $res"
   }

   [IntPtr] step() {
      $res = [sqlite]::step($this.handle)
      foreach ($p in $this.heapAllocs) {
         [IntPtr] $retPtr = [Runtime.InteropServices.Marshal]::FreeHGlobal($p);
      }

    #
    # Free the alloc'd memory that was necessary to pass
    # strings to the sqlite engine:
    #
      $this.heapAllocs = @()

      return $res
   }

   [void] reset() {
      $res = [sqlite]::reset($this.handle)

      if ($res -eq [SQLite]::CONSTRAINT) {
         write-warning ($this.db.errmsg())
         throw "sqliteRest: violation of constraint"
      }

      if ($res -ne [sqlite]::OK) {
         throw "sqliteReset: res = $res"
      }
   }


   [Int32] column_count() {
     #
     # column_count returns the number of columns of
     # a select statement.
     #
     # For non-select statemnt (insert, delete…), column_count
     # return 0.
     #
       return [sqlite]::column_count($this.handle)
   }


   [Int32] column_type(
         [Int] $index
   ) {
       return [sqlite]::column_type($this.handle, $index)
   }


   [object] col(
         [Int] $index
   ) {

      $colType =$this.column_type($index)
      switch ($colType) {

         ([sqlite]::INTEGER) {
          #
          # Be safe and return a 64-bit integer because there does
          # not seem a way to determine if a 32 or 64-bit integer
          # was inserted.
          #
            return [sqlite]::column_int64($this.handle, $index)
         }
         ([sqlite]::FLOAT)   {
            return [sqlite]::column_double($this.handle, $index)
         }
         ([sqlite]::TEXT)    {
            [IntPtr] $charPtr = [sqlite]::column_text($this.handle, $index)
            return utf8PointerToStr $charPtr
         }
         ([sqlite]::BLOB)   {
            return "TODO: blob"
         }
         ([sqlite]::NULL)    {
            return $null
         }
         default           {
            throw "This should not be possible $([sqlite]::sqlite3_column_type($this.handle, $index))"
         }
      }
      return $null
   }

   [void] bindArrayStepReset([object[]] $cols) {
      $colNo = 1
      foreach ($col in $cols) {
          $this.bind($colNo, $col)
          $colNo ++
      }
      $this.step()
      $this.reset()
   }

   [void] finalize() {
      $res = [sqlite]::finalize($this.handle)

      if ($res -ne [sqlite]::OK) {
         throw "sqliteFinalize: res = $res"
      }
   }
}
