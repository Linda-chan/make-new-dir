Option Explicit

Const AppTitle = "AJPapps - Make new dir"
Const AppCopyright = "Линда Кайе 2016-2020. Посвящается Ариэль"

Public FSO
Public FF
Public AddNumber
Public AddDate
Public AddTime
Public AddGUID
Public AddGUIDTrail
Public NumDigits
Public IgnoreTrail
Public MultiMake
Public ReverseSearch
Public ListFileName
Public UnicodeList
Public AddBackSlashesToList
Public MakeWebName
Public BaseFolder

'====================================================================
Public Sub Main()
  If Not DetectCommandLine() Then 
    ShowUsage
  Else
    DoIt
  End If
End Sub

'====================================================================
Private Function DetectCommandLine()
  ' Заранее предполагаем самое худшее ^^'
  DetectCommandLine = False
  
  ' Проверка запроса usage...
  If WScript.Arguments.Count = 1 Then _
    If Trim(WScript.Arguments(0)) = "/?" Then _
      Exit Function
  
  ' Только один базовый каталог...
  If WScript.Arguments.Unnamed.Count > 1 Then Exit Function
  
  ' Если каталог не указан, используем текущий - FSO разберётся...
  If WScript.Arguments.Unnamed.Count = 1 Then
    BaseFolder = WScript.Arguments.Unnamed(0)
  Else
    BaseFolder = "."
  End If
  
  ' Булевы параметры и их псевдонимы...
  AddNumber = WScript.Arguments.Named.Exists("Number") Or WScript.Arguments.Named.Exists("N")
  AddDate = WScript.Arguments.Named.Exists("Date") Or WScript.Arguments.Named.Exists("D")
  AddTime = WScript.Arguments.Named.Exists("Time") Or WScript.Arguments.Named.Exists("T")
  AddGUID = WScript.Arguments.Named.Exists("Guid") Or WScript.Arguments.Named.Exists("G")
  AddGUIDTrail = WScript.Arguments.Named.Exists("GuidTrail") Or WScript.Arguments.Named.Exists("GT")
  IgnoreTrail = WScript.Arguments.Named.Exists("IgnoreTrail") Or WScript.Arguments.Named.Exists("IT")
  MultiMake = WScript.Arguments.Named.Exists("Multi") Or WScript.Arguments.Named.Exists("M")
  ReverseSearch = WScript.Arguments.Named.Exists("ReverseSearch") Or WScript.Arguments.Named.Exists("R")
  UnicodeList = WScript.Arguments.Named.Exists("UnicodeList") Or WScript.Arguments.Named.Exists("UL")
  AddBackSlashesToList = WScript.Arguments.Named.Exists("BackSlashList") Or WScript.Arguments.Named.Exists("BS")
  MakeWebName = WScript.Arguments.Named.Exists("WebName") Or WScript.Arguments.Named.Exists("W")
  
  ' Извлекаем имя файла списка...
  If WScript.Arguments.Named.Exists("List") Then
    ListFileName = WScript.Arguments.Named("List")
  ElseIf WScript.Arguments.Named.Exists("L") Then
    ListFileName = WScript.Arguments.Named("L")
  Else
    ListFileName = ""
  End If
  
  ' Извлекаем циферь...
  If WScript.Arguments.Named.Exists("Digits") Then
    NumDigits = XCLng(WScript.Arguments.Named("Digits"))
  ElseIf WScript.Arguments.Named.Exists("C") Then
    NumDigits = XCLng(WScript.Arguments.Named("C"))
  Else
    NumDigits = 0
  End If
  
  If NumDigits < 0 Then Exit Function
  If NumDigits > 10 Then Exit Function
  
  ' Всё хорошо!
  DetectCommandLine = True
End Function

'====================================================================
Private Sub ShowUsage()
  Dim TXT
  
  Echo AppTitle & vbCrLf & _
       AppCopyright & vbCrLf & _
       vbCrLf & _
       "Использование: MakeNewDir.WSF [/Number] [/Date] [/Time] [/Guid]" & vbCrLf & _
       "                              [/Digits:n] [/IgnoreTrail] [/Multi]" & vbCrLf & _
       "                              [/ReverseSearch] [/List:filename]" & vbCrLf & _
       "                              [/UnicodeList] [/BackSlashList]" & vbCrLf & _
       "                              [/GuidTrail] [/WebName] [BaseFolder]" & vbCrLf & _
       vbCrLf & _
       "Псевдонимы: /N = /Number    /D = /Date            /T = /Time" & vbCrLf & _
       "            /G = /Guid      /C = /Digits          /IT = /IgnoreTrail" & vbCrLf & _
       "            /M = /Multi     /R = /ReverseSearch   /BS = /BackSlashList" & vbCrLf & _
       "            /L = /List      /U = /UnicodeList     /GT = /GuidTrail" & vbCrLf & _
       "            /W = /WebName" & vbCrLf & _
       vbCrLf & _
       "Параметр /Guid не совместим с параметрами /Date и /Time."
End Sub

'====================================================================
Private Sub DoIt()
  Dim Folder
  Dim MakeAnother
  
  On Error Resume Next

  ' Тут проблем быть не должно...
  Set FF = New CFolderFinder
  
  Set FSO = CreateObject("Scripting.FileSystemObject")
  If Err.Number <> 0 Then
    ErrEcho "Не удаётся создать объект Scripting.FileSystemObject."
    Exit Sub
  End If
  
  Set Folder = FSO.GetFolder(BaseFolder)
  If Err.Number <> 0 Then
    ' Использовать переменную только сейчас. 
    ' Потом уже использовать Folder.Path.
    ErrEcho2 "Не удаётся открыть каталог", BaseFolder
    Exit Sub
  End If
  
  ' Вместо GoTo городим вот такое =_=
  Do
    ' Теперь инициализируем FF. Используем объект Folder вместо 
    ' строки, я так понимаю, потому, что он даёт прямой путь, 
    ' а не относительный. Потом можно будет переделать...
    FF.Init Folder.Path
    
    ' ВНИМАНИЕ! Параметр /Number совместим с параметрами /Date 
    '           и /Time! Это /Guid не совместим с /Date и /Time!!!
    
    ' Делать нечего, если все параметры пусты, либо GUID скомбинирован 
    ' с Date и/или Time. Можно было проверить ранее, но чтобы не 
    ' запутаться, проверим тут...
    If (Not (AddNumber Or AddDate Or AddTime Or AddGUID)) Or _
       (AddGUID And (AddDate Or AddTime)) Then
      ShowUsage
      Exit Sub
    End If
    
    ' Обнуляем переменную, говорим, что ещё один каталог создать 
    ' не нужно. Её значение может измениться только 
    ' в CreateNewDirectory(), и то, если пользователю будет выдан 
    ' запрос. Так что, если будет какая ошибка (закончатся цифры, 
    ' например), в этой переменной не останется True с последнего 
    ' успешного создания каталога, и скрипт не зациклится. Заодно 
    ' это избавит нас от необходимости обнулять её при каждой 
    ' ошибке...
    MakeAnother = False
    
    ' Тут ещё по умолчанию значение подгоняем...
    If (AddDate Or AddTime) Then  
      If NumDigits = 0 Then NumDigits = 2
      DoItWithDateTime Folder, MakeAnother
    ElseIf AddGUID Then
      If NumDigits = 0 Then NumDigits = 4
      DoItWithGUID Folder, MakeAnother
    Else
      If NumDigits = 0 Then NumDigits = 4
      DoItWithNumber Folder, MakeAnother
    End If
    
    ' Если ещё один каталог создать не нужно, выходим из цикла.
    If Not MakeAnother Then Exit Do
  Loop

  SaveListToFile
End Sub

'====================================================================
Private Sub DoItWithNumber(ByRef Folder, ByRef lpMakeAnother)
  Dim PathName
  
  ' Необходимо дописать бэкслэш!
  ' См. пояснения к функции FindFreePath()...
  PathName = Folder.Path
  If Right(PathName, 1) <> "\" Then PathName = PathName & "\"
  
  ' Теперь ищем имя нового каталога с номером...
  PathName = FindFreePath(PathName, 0, NumDigits, IgnoreTrail, ReverseSearch)
  
  If PathName = "" Then
    ErrEcho2 "Нет свободных имён", Folder.Path
    Exit Sub
  End If
  
  CreateNewDirectory PathName, lpMakeAnother
End Sub

'====================================================================
Private Sub DoItWithDateTime(ByRef Folder, ByRef lpMakeAnother)
  Dim PathName
  Dim FolderName
  Dim xNow
  Dim Delimiter(1)
  
  ' Заранее определяем время...
  xNow = Now
  
  ' Определяемся с разделителями...
  If MakeWebName Then
    Delimiter(0) = "-"
    Delimiter(1) = "-"
  Else
    Delimiter(0) = "."
    Delimiter(1) = " "
  End If
  
  ' Собираем базовое имя каталога...
  FolderName = ""
  
  If AddDate Then
    FolderName = FolderName & Format0000(Year(xNow)) & Delimiter(0) & _
                              Format00(Month(xNow)) & Delimiter(0) & _
                              Format00(Day(xNow))
  End If
  
  If AddTime Then
    If FolderName <> "" Then FolderName = FolderName & Delimiter(1)
    FolderName = FolderName & Format00(Hour(xNow)) & Delimiter(0) & _
                              Format00(Minute(xNow)) & Delimiter(0) & _
                              Format00(Second(xNow))
  End If
  
  ' Собираем пока без цифрового хвоста...
  PathName = FSO.BuildPath(Folder.Path, FolderName)
  
  ' Ищем без номера...
  If FF.IsFileOrFolderExist(PathName, IgnoreTrail) Then
    ' Если существует, то смотрим, можно ли добавить номер...
    If AddNumber Then
      ' Дописываем чёрточку и ищем с номером...
      PathName = PathName & "-"
      PathName = FindFreePath(PathName, 1, NumDigits, IgnoreTrail, ReverseSearch)
    Else
      ' Ничего не поделаешь - сигналим наружу, что свободного 
      ' имени нет...
      PathName = ""
    End If
  End If
  
  If PathName = "" Then
    ErrEcho2 "Нет свободных имён", Folder.Path
    Exit Sub
  End If
  
  CreateNewDirectory PathName, lpMakeAnother
End Sub

'====================================================================
Private Function GetProperGUID()
  Dim TXT
  
  TXT = GetNewGUID()
  TXT = LCase(TXT)
  TXT = Replace(TXT, "{", "")
  TXT = Replace(TXT, "}", "")
  
  GetProperGUID = TXT
End Function

'====================================================================
Private Sub DoItWithGUID(ByRef Folder, ByRef lpMakeAnother)
  Dim PathName
  Dim FolderName
  
  ' Собираем базовое имя каталога...
  FolderName = GetProperGUID()
  
  ' Собираем пока без цифрового хвоста...
  PathName = FSO.BuildPath(Folder.Path, FolderName)
  
  ' Ищем без номера...
  If FF.IsFileOrFolderExist(PathName, IgnoreTrail) Then
    ' Если существует, то смотрим, можно ли добавить номер...
    ' Вообще-то, такого быть не может, но вдруг...
    If AddNumber Then
      ' Дописываем чёрточку и ищем с номером...
      PathName = PathName & "-"
      PathName = FindFreePath(PathName, 1, NumDigits, IgnoreTrail, ReverseSearch)
    Else
      ' Ничего не поделаешь - сигналим наружу, что свободного 
      ' имени нет...
      PathName = ""
    End If
  End If
  
  If PathName = "" Then
    ErrEcho2 "Нет свободных имён", Folder.Path
    Exit Sub
  End If
  
  CreateNewDirectory PathName, lpMakeAnother
End Sub

'====================================================================
' PathName - это не каталог, а начало полного имени каталога, 
' к которому будут дописываться цифры.
' 
' Например:
'   "C:\Byaka\Text\"       ==> "C:\Byaka\Text\0000"
'   "D:\Work\Backup File " ==> "D:\Work\Backup File 0000"
' 
' Такая форма необходима для варианта с датой и временем, где часть 
' имени папки меняться не будет.
' 
' NumBase - с чего начинать перечисление. В общем случае для 
' номерных каталогов - 0, для дат - 1. Ибо "0000" - норм, 
' а "2016.10.21-00" - нет, потому как "2016.10.21" - это и есть 
' нулевой каталог!
'====================================================================
Private Function FindFreePath(ByVal PathName, _
                              ByVal NumBase, _
                              ByVal NumDigits, _
                              ByVal IgnoreTrail, _
                              ByVal ReverseSearch)
  If ReverseSearch Then
    FindFreePath = FindFreePath_Reverse(PathName, NumBase, NumDigits, IgnoreTrail)
  Else
    FindFreePath = FindFreePath_Forward(PathName, NumBase, NumDigits, IgnoreTrail)
  End If
End Function

'====================================================================
Private Function FindFreePath_Forward(ByVal PathName, _
                                      ByVal NumBase, _
                                      ByVal NumDigits, _
                                      ByVal IgnoreTrail)
  Dim TMP
  Dim NewPath
  
  For TMP = NumBase To GetMaxNumber(NumDigits)
    NewPath = PathName & Format(TMP, NumDigits)
    If Not FF.IsFileOrFolderExist(NewPath, IgnoreTrail) Then
      FindFreePath_Forward = NewPath
      Exit Function
    End If
  Next
  
  FindFreePath_Forward = ""
End Function

'====================================================================
Private Function FindFreePath_Reverse(ByVal PathName, _
                                      ByVal NumBase, _
                                      ByVal NumDigits, _
                                      ByVal IgnoreTrail)
  Dim TMP
  Dim NewPath
  
  For TMP = GetMaxNumber(NumDigits) To NumBase Step -1
    NewPath = PathName & Format(TMP, NumDigits)
    If FF.IsFolderExist(NewPath, IgnoreTrail) Then
      ' Раньше тут была проверка на последний индекс, типа выше уже 
      ' каталог не создашь. Но в функции ниже всё и так завершится 
      ' неудачей если индекс начала будет выше индекса конца: цикл 
      ' не выполнится, вернётся пустая строка. Так что 
      ' не проверяем, а займём место этим камментом!
      FindFreePath_Reverse = FindFreePath_Forward(PathName, TMP + 1, NumDigits, IgnoreTrail)
      Exit Function
    End If
  Next
  
  FindFreePath_Reverse = FindFreePath_Forward(PathName, NumBase, NumDigits, IgnoreTrail)
End Function

'====================================================================
Private Function GetMaxNumber(ByVal NumDigits)
  Dim TXT
  
  TXT = String(NumDigits, "9")
  GetMaxNumber = XCLng(TXT)
End Function

'====================================================================
Private Sub CreateNewDirectory(ByVal PathName, ByRef lpMakeAnother)
  On Error Resume Next
  
  If AddGUIDTrail Then
    If MakeWebName Then
      PathName = PathName & "-" & GetProperGUID()
    Else
      PathName = PathName & " - " & GetProperGUID()
    End If
  End If
  
  FSO.CreateFolder PathName
  If Err.Number = 0 Then
    If MultiMake Then
      lpMakeAnother = Ask2("Каталог успешно создан", "Создать ещё один?", PathName)
    Else
      Echo2 "Каталог успешно создан", PathName
    End If
    AddDirectoryToList PathName
  Else
    ErrEcho2 "Не удаётся создать каталог", PathName
  End If
End Sub
