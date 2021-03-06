Option Explicit

'====================================================================
Class CFolderFinder
  
  Private FSO
  Private mvarInitialized
  Private mvarPath
  Private mvarFiles
  Private mvarFolders
  
  '==================================================================
  Private Sub Class_Initialize()
    Set FSO = CreateObject("Scripting.FileSystemObject")
    
    mvarInitialized = False
    mvarPath = ""
    mvarFiles = ""
    mvarFolders = ""
  End Sub
  
  '==================================================================
  Public Function Init(ByVal Path)
    Dim Folder
    Dim TMP
    
    On Error Resume Next
    
    Init = False
    
    Set Folder = FSO.GetFolder(Path)
    If Err.Number <> 0 Then Exit Function
    
    mvarPath = Path
    mvarFiles = ""
    mvarFolders = ""
    
    For Each TMP In Folder.SubFolders
      mvarFolders = mvarFolders & ":" & TMP.Name
    Next
    
    For Each TMP In Folder.Files
      mvarFiles = mvarFiles & ":" & TMP.Name
    Next
    
    If Len(mvarFolders) > 0 Then _
      mvarFolders = mvarFolders & ":"
    
    If Len(mvarFiles) > 0 Then _
      mvarFiles = mvarFiles & ":"
    
    ' Debug!
    'MsgBox Len(mvarPath) & " ==> " & mvarPath
    'MsgBox Len(mvarFiles) & " ==> " & mvarFiles
    'MsgBox Len(mvarFolders) & " ==> " & mvarFolders
    
    mvarInitialized = True
    Init = True
  End Function
  
  '==================================================================
  Private Function FileExists(ByVal FileName)
    FileExists = False
    If Not mvarInitialized Then Exit Function
    
    FileName = ":" & FSO.GetFileName(FileName) & ":"
    FileExists = CBool(InStr(1, mvarFiles, FileName, vbTextCompare) > 0)
  End Function
  
  '==================================================================
  Private Function FolderExists(ByVal FileName)
    FolderExists = False
    If Not mvarInitialized Then Exit Function
    
    FileName = ":" & FSO.GetFileName(FileName) & ":"
    FolderExists = CBool(InStr(1, mvarFolders, FileName, vbTextCompare) > 0)
  End Function
  
  '==================================================================
  Private Function IsItExist(ByVal FileName, _
                             ByVal IgnoreTrail, _
                             ByVal FindOnlyFolders)
    IsItExist = False
    If Not mvarInitialized Then Exit Function
    
    ' На всякий случай...
    If FileName = "" Then Exit Function
    
    ' Сначала делаем простую проверку существования папки или файла.
    ' Важно проверить наличие файла, ибо папку с таким же именем 
    ' создать не получится.
    If FindOnlyFolders Then
      IsItExist = FolderExists(FileName)
    Else
      IsItExist = _
        CBool(FileExists(FileName) Or FolderExists(FileName))
    End If
    
    ' Если ни то, ни другое не найдено, то проверяем наличие папки
    ' с хвостиком в имени, если нужно.
    If Not IsItExist Then _
      If IgnoreTrail Then _
        IsItExist = IsFolderWithTrailExist(FileName)
  End Function
  
  '==================================================================
  Public Function IsFileOrFolderExist(ByVal FileName, _
                                      ByVal IgnoreTrail)
    IsFileOrFolderExist = IsItExist(FileName, IgnoreTrail, False)
  End Function
  
  '==================================================================
  Public Function IsFolderExist(ByVal FileName, _
                                ByVal IgnoreTrail)
    IsFolderExist = IsItExist(FileName, IgnoreTrail, True)
  End Function
  
  '==================================================================
  ' На всякий случай: эта функция не ищет точное совпадение, а только
  ' подкаталоги с хвостиком: "0000 - Ariel".
  '==================================================================
  Public Function IsFolderWithTrailExist(ByVal FileName)
    Dim RC
    
    ' Всё плохо...
    IsFolderWithTrailExist = False
    
    ' На всякий случай...
    If FileName = "" Then Exit Function
    
    ' Вычленяем имя каталога. Если слэша нет, то берём строку 
    ' как есть...
    RC = InStrRev(FileName, "\")
    If RC > 0 Then _
      FileName = Mid(FileName, RC + 1)
    
    ' Дописываем чёрточку с пробелами. Остальное нас не волнует...
    ' Так же дописываем двоеточие для поиска. Двоеточие с хвоста нас 
    ' не интересет, потому что дальнейшая часть имени может быть 
    ' любой...
    FileName = ":" & FileName & " - "
    
    ' И ищем! Интересуют только каталоги. Файлы не интересуют.
    IsFolderWithTrailExist = CBool(InStr(1, mvarFolders, FileName, vbTextCompare) > 0)
  End Function
  
End Class
