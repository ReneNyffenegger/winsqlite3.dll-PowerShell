add-type -typeDefinition @'

using System;
using System.Runtime.InteropServices;

public static class kernel32 {

  [DllImport("kernel32.dll", CharSet=CharSet.Auto)]
   public static extern IntPtr GetModuleHandle(string lpModuleName);

  [DllImport("kernel32", CharSet=CharSet.Ansi, ExactSpelling=true, SetLastError=true)]
   public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

}
'@
