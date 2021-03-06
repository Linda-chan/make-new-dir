Option Explicit

'====================================================================
Public Sub Echo(ByVal Message)
  If IsScriptInConsole() Then
    WScript.Echo Message
  Else
    MsgBox Message, vbInformation, AppTitle
  End If
End Sub

'====================================================================
Public Sub Echo2(ByVal Message, _
                 ByVal FileName)
  If IsScriptInConsole() Then
    WScript.Echo Message & ": " & FileName
  Else
    MsgBox FileName & vbCrLf & vbCrLf & _
           Message & ".", vbInformation, AppTitle
  End If
End Sub

'====================================================================
Public Sub ErrEcho(ByVal Message)
  If IsScriptInConsole() Then
    WScript.Echo Message
  Else
    MsgBox Message, vbCritical, AppTitle
  End If
End Sub

'====================================================================
Public Sub ErrEcho2(ByVal Message, _
                    ByVal FileName)
  If IsScriptInConsole() Then
    WScript.Echo Message & ": " & FileName
  Else
    MsgBox FileName & vbCrLf & vbCrLf & _
           Message & ".", vbCritical, AppTitle
  End If
End Sub

'====================================================================
Public Function Ask(ByVal Message, _
                    ByVal Question)
  If IsScriptInConsole() Then
    WScript.Echo Message
  Else
    Ask = CBool(MsgBox(Message & vbCrLf & vbCrLf & Question, _
                       vbQuestion + vbOkCancel, AppTitle) = vbOk)
  End If
End Function

'====================================================================
Public Function Ask2(ByVal Message, _
                     ByVal Question, _
                     ByVal FileName)
  If IsScriptInConsole() Then
    WScript.Echo Message & ": " & FileName
  Else
    Ask2 = CBool(MsgBox(FileName & vbCrLf & vbCrLf & _
                        Message & "." & vbCrLf & vbCrLf & _
                        Question, vbQuestion + vbOkCancel, _
                        AppTitle) = vbOk)
  End If
End Function
