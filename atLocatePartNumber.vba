Function atLocatePartNumber
'***********************************************************************************************
'  Author                           : Robert Bondaruk, PeopleSoft Consulting
'  Date Written                     : 8/4/2000
'  Objects invoking this procedure  : PURCHASE_ORDER_LINE
'  Events Called from               : Field Changed
'  Detailed Description             : 
'     On the Purchase Order Lines screen, this replaces a standard drilldown
'     with a ... button. If the hidden Part number field is blank, opens a locator
'     but fills in vendor information if available.	 This script is a modification of the OOB
'     script VAPPLocatepartNumber
'  Modified By                      :
'  Modified Date                    :
'  Modified Desc.                   :
'***********************************************************************************************
On Error GoTo Errhndl
atLocatePartNumber  = 0 'By default, the function returns a success value.
'Actual Code Begins Here ------------------

Dim w as Window
Dim lw as Window
Dim FldPart as Field
Dim VirtualPart as Field
Dim VendorId as String
Dim VenVendor as String
Dim BuyerId as String
Dim nrows as Integer
Dim sql as String
Dim results() as String
Dim procname as String

Set w = Application.EventWindow
Set FldPart = w.Page(1).Form.Field(PARTNUM)
Set VirtualPart = w.Page(1).Form.Field(VPARTNUM)
BuyerId = w.Page(INFORMATION).Form.Field(BUYERIDPATH).Value
VendorId = w.Page(1).Form.Field(VENDORIDPATH).Value
VenVendor = w.Page(1).Form.Field(VENDORPATH).Value

if FldPart.Value = "" or VirtualPart.Value = "" then
	if FldPart.Value <> "" then FldPart.Value = ""
	Set lw = FldPart.Locator
	lw.Form.Field(ITMCAT_VENDOR_EID).ReadOnly = 0
	lw.Form.Field(ITMCAT_VENDOR_EID).Value = VendorId
	if VendorId <> "" then lw.Form.Field(ITMCAT_VENDOR_EID).ReadOnly = 1
	lw.Form.Field(VEN_VENDOR_PATH).ReadOnly = 0
	lw.Form.Field(VEN_VENDOR_PATH).Value = VenVendor
	if VenVendor <> "" then lw.Form.Field(VEN_VENDOR_PATH).ReadOnly = 1

   procname = "atsp_get_empcode"
   Select Case Application.DatabaseType
   Case vcDBTypeSybase
      'Tbd
   Case vcDBTypeOracle
      sql = "begin " & procname & "_pkg." & procname &_
	     "(" & BuyerId & ", :a0, :a1 , :b, :r, :s); end;"

   Case vcDBTypeInformix
      'Tbd
   Case vcDBTypeWatcom  
      'TBD
   Case Else
      Message.DisplayErrorMessage Application.Locale, "7171"
      Exit Function
   End Select

   nrows = Application.SQL (sql, results)
   if (nrows <> 0) then
      redim preserve results (0 to 1,0 to nrows)
      if (results(0,0) = "0") then
         lw.Form.Field(BUYERCODEIDPATH).ReadOnly = 0
         lw.Form.Field(BUYERCODEIDPATH).Value = VenVendor
         lw.Form.Field(BUYERCODEIDPATH).ReadOnly = 1
      else
         Message.DisplayErrorMessage Application.Locale, results(0,0)
         Exit Function
      end if
   end if

else
	' open the item catalog part when part number entered
	'mGobletAX.Context.PartNumberEID = FldPart.Column.Value
'This code was commented out because of the bug with the set on fldpart.column.value
'This is a known bug with Vantive technical support.  Both fldPart sets below.
'	FldPart.Column.Value = VAPPToDatabaseNumFormat(FldPart.Column.Value)  'i18n
	set lw = Application.OpenWindow(ITEM_CAT_OBJECT, FldPart.Column.Value)
'   FldPart.Column.Value = VAPPFromDatabaseNumFormat(FldPart.Column.Value)  'i18n - Convert back
end if

  'Actual Code Ends Here ------------------
Exit Function 'The function should not fall through to the error handler.

Errhndl:
   Dim ErrMsg1 as string
   Dim ErrMsg2 as string
   Dim ErrMsg3 as string
   ErrMsg1 = Err
   ErrMsg2 = Error$
   ErrMsg3 = Erl
   Message.DisplayErrorMessage Application.Locale(), BAD_VBA, "atLocatePartNumber", ErrMsg1, ErrMsg2, ErrMsg3
   atLocatePartNumber = -1
End Function