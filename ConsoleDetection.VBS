Option Explicit

Private mvarGetScriptEngineFileName
Private mvarIsScriptInConsole

'====================================================================
Public Function GetScriptEngineFileName()
  Dim FileName
  Dim RC
  
  ' Кэширование...
  If IsEmpty(mvarGetScriptEngineFileName) Then
    FileName = WScript.FullName
    RC = InStrRev(FileName, "\")
    If RC > 0 Then FileName = Mid(FileName, RC + 1)
    
    ' Кэширование...
    mvarGetScriptEngineFileName = FileName
    
    ' Debug!
    'MsgBox mvarGetScriptEngineFileName
  End If
  
  GetScriptEngineFileName = mvarGetScriptEngineFileName
End Function

'====================================================================
Public Function IsScriptInConsole()
  Dim FileName
  
  ' Кэширование...
  If IsEmpty(mvarIsScriptInConsole) Then
    FileName = UCase(GetScriptEngineFileName())
    mvarIsScriptInConsole = CBool(FileName = "CSCRIPT.EXE")
    
    ' Debug!
    'MsgBox mvarIsScriptInConsole
  End If
  
  IsScriptInConsole = mvarIsScriptInConsole
End Function
