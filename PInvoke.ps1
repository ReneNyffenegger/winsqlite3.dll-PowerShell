<#
    P/Invoke wrappers that allow to access winsqlite3.dll

    Version 0.02

    Compare with https://renenyffenegger.ch/notes/development/databases/SQLite/VBA/index
#>

set-strictMode -version 2

add-type -typeDefinition @"
using System;
using System.Runtime.InteropServices;

public static partial class sqlite {

   public const Int32 OK             =   0;
   public const Int32 ERROR          =   1;
   public const Int32 BUSY           =   5;
   public const Int32 MISUSE         =  21; //  SQLite interface was used in a undefined/unsupported way (i.e. using prepared statement after finalizing it)
   public const Int32 ROW            = 100; //  sqlite3_step() has another row ready
   public const Int32 DONE           = 101; //  sqlite3_step() has finished executing

   public const Int32 INTEGER        =  1;
   public const Int32 FLOAT          =  2;
   public const Int32 TEXT           =  3;
   public const Int32 BLOB           =  4;
   public const Int32 NULL           =  5;

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_open")]
    public static extern IntPtr open(
     //   [MarshalAs(UnmanagedType.LPStr)]
           String zFilename,
       ref IntPtr ppDB       // db handle
    );

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_exec", CharSet=CharSet.Ansi)]
    public static extern IntPtr exec (
           IntPtr db      ,    /* An open database                                               */
           String sql     ,    /* SQL to be evaluated                                            */
           IntPtr callback,    /* int (*callback)(void*,int,char**,char**) -- Callback function  */
           IntPtr cb1stArg,    /* 1st argument to callback                                       */
       ref String errMsg       /* Error msg written here  ( char **errmsg)                       */
    );

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_errmsg" , CharSet=CharSet.Ansi)]
    public static extern IntPtr errmsg (
           IntPtr    db
    );

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_prepare_v2", CharSet=CharSet.Ansi)]
    public static extern IntPtr prepare_v2 (
           IntPtr db      ,     /* Database handle                                                  */
           String zSql    ,     /* SQL statement, UTF-8 encoded                                     */
           IntPtr nByte   ,     /* Maximum length of zSql in bytes.                                 */
      ref  IntPtr sqlite3_stmt, /* int **ppStmt -- OUT: Statement handle                            */
           IntPtr pzTail        /*  const char **pzTail  --  OUT: Pointer to unused portion of zSql */
    );

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_bind_int")]
    public static extern IntPtr bind_int(
           IntPtr           stmt,
           IntPtr /* int */ index,
           IntPtr /* int */ value);

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_bind_text")]
    public static extern IntPtr bind_text(
           IntPtr    stmt,
           IntPtr    index,
//        [MarshalAs(UnmanagedType.LPStr)]
           IntPtr    value , /* const char*                  */
           IntPtr    x     , /* What does this parameter do? */
           IntPtr    y       /* void(*)(void*)               */
     );
   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_bind_null")]
    public static extern IntPtr bind_null (
           IntPtr    stmt,
           IntPtr    index
    );

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_step")]
    public static extern IntPtr step (
           IntPtr    stmt
    );

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_reset")]
    public static extern IntPtr reset (
           IntPtr    stmt
    );

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_column_type")]
    public static extern IntPtr column_type (
            IntPtr   stmt,
            IntPtr   index
    );

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_column_double")]
    public static extern Double column_double (
            IntPtr   stmt,
            IntPtr   index
   );

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_column_int")]
    public static extern IntPtr column_int(
            IntPtr   stmt,
            IntPtr   index
    );

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_column_text"
     , CharSet=CharSet.Ansi
    )]
// [return: MarshalAs(UnmanagedType.LPStr)]
    public static extern IntPtr column_text (
            IntPtr   stmt,
            IntPtr   index
    );

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_finalize")]
    public static extern IntPtr finalize (
           IntPtr    stmt
    );

   [DllImport("winsqlite3.dll", EntryPoint="sqlite3_close")]
    public static extern IntPtr close (
           IntPtr    db
    );


// [DllImport("winsqlite3.dll")]
//   public static extern IntPtr sqlite3_clear_bindings(
//          IntPtr    stmt
//  );

}
"@
