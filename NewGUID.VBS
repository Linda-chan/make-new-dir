Option Explicit

'====================================================================
Public Function GetNewGUID()
  Dim TypeLib
  Dim TXT
  Dim RC
  
  Set TypeLib = CreateObject("Scriptlet.TypeLib")
  TXT = TypeLib.Guid
  
  RC = InStr(TXT, vbNullChar)
  If RC > 0 Then TXT = Left(TXT, RC - 1)
  
  GetNewGUID = UCase(TXT)
End Function
