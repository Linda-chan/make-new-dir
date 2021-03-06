Option Explicit

Private mvarDirList

'====================================================================
Public Sub AddDirectoryToList(ByVal PathName)
  If ListFileName = "" Then Exit Sub
  If PathName = "" Then Exit Sub
  
  If AddBackSlashesToList Then
    If Right(PathName, 1) <> "\" Then
      PathName = PathName & "\"
    End If
  Else
    If Right(PathName, 1) = "\" Then
      PathName = Left(PathName, Len(PathName) - 1)
    End If
  End If
  
  If IsEmpty(mvarDirList) Then mvarDirList = ""
  mvarDirList = mvarDirList & PathName & vbCrLf
End Sub

'====================================================================
Public Sub SaveListToFile()
  Dim Stream
  
  If ListFileName = "" Then Exit Sub
  If mvarDirList = "" Then Exit Sub
  
  On Error Resume Next
  
  Set Stream = FSO.CreateTextFile(ListFileName, True, UnicodeList)
  If Err.Number <> 0 Then
    ErrEcho2 "Не удаётся создать файл списка", ListFileName
    Exit Sub
  End If
  
  Stream.Write mvarDirList
  If Err.Number <> 0 Then
    ErrEcho2 "Не удаётся записать данные в файл списка", ListFileName
    Exit Sub
  End If
  
  Stream.Close
  
  If IsScriptInConsole() Then _
    Echo2 "Список каталогов сохранён в файл", ListFileName
End Sub
