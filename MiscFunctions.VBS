Option Explicit

'====================================================================
Private Function IIf(ByVal Expression, ByVal TrueValue, ByVal FalseValue)
  If Expression Then IIf = TrueValue Else IIf = FalseValue
End Function

'====================================================================
Public Function XCLng(ByVal Num)
  On Error Resume Next
  
  Err.Clear
  XCLng = CLng(Num)
  If Err.Number <> 0 Then XCLng = 0
End Function
