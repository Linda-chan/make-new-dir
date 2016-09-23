'====================================================================
Public Function Format0000(ByVal Num)
  Format0000 = Format(Num, 4)
End Function

Public Function Format00(ByVal Num)
  Format00 = Format(Num, 2)
End Function

Public Function Format(ByVal Num, ByVal Width)
  Dim TXT
  
  TXT = Trim(CStr(Num))
  Do While Len(TXT) < Width
    TXT = "0" & TXT
  Loop
  
  Format = TXT
End Function

'====================================================================
Public Function Format0000S(ByVal Num)
  Format0000S = FormatS(Num, 4)
End Function

Public Function Format00S(ByVal Num)
  Format00S = FormatS(Num, 2)
End Function

Public Function FormatS(ByVal Num, ByVal Width)
  Dim TXT
  
  TXT = Trim(CStr(Num))
  Do While Len(TXT) < Width
    TXT = " " & TXT
  Loop
  
  FormatS = TXT
End Function
