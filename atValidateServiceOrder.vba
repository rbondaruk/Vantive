Function atValidateServiceOrder ()
'***********************************************************************************************
'  Author                           : Robert Bondaruk, PeopleSoft Consulting
'  Date Written                     : 7/17/2000
'  Objects invoking this procedure  : SERVICE_ORDER
'  Events Called from               : Pre-Save
'  Detailed Description             :
'  Modified By                      :
'  Modified Date                    :
'  Modified Desc.                   :
'***********************************************************************************************
  On Error GoTo Errhndl
  atValidateServiceOrder  = 0 'By default, the function returns a success value.
  'Actual Code Begins Here ------------------

  Dim w as Window           'Window Handle
  Dim p as Page             'Page Handle
  Dim f as Form             'Form Handle
  Dim soStatus as Field     'Field Handle for SO Status
  Dim sql as String         'String for SQL Statements
  Dim ResultSet() as String 'Array to hold the output values of the Stored Proc
  Dim rc as Integer         'Integer for SQL return codes

  Set w = Application.EventWindow 
  Set p = w.Page(PGE_INFORMATION)
  Set f = p.Form
  Set soStatus = f.Field(SOSTATUSPATH)

  If soStatus.Value = "Completed" Then

    Select Case Application.DatabaseType
      Case vcDBTypeOracle
        sql = "begin Atsp_Val_So_Pkg.Atsp_Val_So(" & CStr(Application.Locale()) & "," & w.PrimaryKeyValue & ",:a0,:b,:r,:s);end;"
      Case Else
        Message.DisplayErrorMessage Application.Locale(), "7171"
        Exit Function
    End Select

	rc = Application.SQL(sql,ResultSet)
    If rc >= 0 Then
      Redim PreServe ResultSet(rc) as String
      Message.DisplayErrorMessage Application.Locale(),	ResultSet(0)
  	End If
     
  End If

  'Actual Code Ends Here ------------------
  Exit Function 'The function should not fall through to the error handler.

  Errhndl:
  Dim ErrMsg1 as string
  Dim ErrMsg2 as string
  Dim ErrMsg3 as string
  ErrMsg1 = Err
  ErrMsg2 = Error$
  ErrMsg3 = Erl
  Message.DisplayErrorMessage Application.Locale(), BAD_VBA, "atValidateServiceOrder", ErrMsg1, ErrMsg2, ErrMsg3
  atValidateServiceOrder = -1
End Function