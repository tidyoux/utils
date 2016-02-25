
if WScript.Arguments.Count < 1 Then
    WScript.Echo "Please specify the file. Usage: convert2utf8.vbs <test.txt>"
    Wscript.Quit
End If

Const intForReading = 1
Const intUniCode = -1

Dim objFSO, objTextStream
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objTextStream = objFSO.OpenTextFile(Wscript.Arguments.Item(0), intForReading, False, intUniCode)
sText = objTextStream.ReadAll

objTextStream.Close
Set objTextStream = Nothing
Set objFSO = Nothing

Dim oStream
Set oStream = CreateObject("ADODB.Stream")
With oStream
    .Open
    .CharSet = "utf-8"
    .WriteText sText
    .SaveToFile Wscript.Arguments.Item(0), 2
End With

Set oStream = Nothing



                                          