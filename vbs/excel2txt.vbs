if WScript.Arguments.Count < 2 Then
    WScript.Echo "Please specify the source, the sheet. Usage: excel2txt.vbs <xls/xlsx source file> <sheetName>"
    Wscript.Quit
End If

out_dir = "./temp/"
file_format = 42
file_tail = ".txt"

Set objFSO = CreateObject("Scripting.FileSystemObject")

src_file = objFSO.GetAbsolutePathName(Wscript.Arguments.Item(0))
dest_file = objFSO.GetAbsolutePathName(out_dir & WScript.Arguments.Item(1) & file_tail)

Dim oExcel
Set oExcel = CreateObject("Excel.Application")

Dim oBook
Set oBook = oExcel.Workbooks.Open(src_file)

oBook.Sheets(WScript.Arguments.Item(1)).Select
oBook.SaveAs dest_file, file_format

oBook.Close False
oExcel.Quit

