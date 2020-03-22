set-strictMode -version 2

function charPtrToString([IntPtr]$charPtr) {
   [OutputType([String])]
 #
 # Create a .NET/PowerShell string from the bytes
 # that are pointed at by $charPtr
 #
   [IntPtr] $i = 0

   $strB = new-object Text.StringBuilder
   while ( [Runtime.InteropServices.Marshal]::ReadByte($charPtr, $i) -gt 0 ) {
      $null = $strB.Append( [Runtime.InteropServices.Marshal]::ReadByte($charPtr, $i) -as [Char] )
      $i=$i+1
   }
   return $strB.ToString()
}

function strToCharPtr([String] $str) {
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
      $res = [sqlite]::exec($this.db, $sql, 0, 0, [ref] $errMsg)

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

   [String] errmsg() {
      return charPtrToString ([sqlite]::errmsg($this.db))
   }

   static [String] version() {
      $h = [kernel32]::GetModuleHandle('winsqlite3.dll')
      if ($h -eq 0) {
         return 'winsqlite3.dll is probably not yet loaded'
      }
      $a = [kernel32]::GetProcAddress($h, 'sqlite3_version')
      return charPtrToString $a
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
         [IntPtr] $heapPtr = strToCharPtr($value)
         $res = [sqlite]::bind_text($this.handle, $index, $heapPtr, $value.length, 0)

       #
       # Keep track of allocations on heap, free later
       #
         $this.heapAllocs += $heapPtr
      }
      elseif ($value -is [Int]) {
         $res = [sqlite]::bind_int($this.handle, $index, $value)
      }
      else {
         throw "type $($value.GetType()) not (yet?) supported"
      }

      if ($res -ne [sqlite]::OK) {
         write-warning $this.db.errmsg()
         write-warning "index: $index, value: $value"
         throw "sqliteBind: res = $res"
      }
   }

   [IntPtr] step() {
      $res = [sqlite]::step($this.handle)

   #  if ($res -ne [sqlite]::DONE) {
   #     throw "sqliteStep: res = $res"
   #  }

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

      if ($res -ne [sqlite]::OK) {
         throw "sqliteBind: res = $res"
      }
   }

   [object] col(
         [Int] $index
   ) {

      $colType =[sqlite]::column_type($this.handle, $index)
      switch ($colType) {

         ([sqlite]::INTEGER) {
            return [sqlite]::column_int($this.handle, $index)
         }
         ([sqlite]::FLOAT)   {
            return [sqlite]::column_float($this.handle, $index)
         }
         ([sqlite]::TEXT)    {
            [IntPtr] $charPtr = [sqlite]::column_text($this.handle, $index)
            return charPtrToString $charPtr
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
      #$null = sqliteStep  $stmt
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
