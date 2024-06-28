Sub ConvertFirstSheetToCSV()
    Dim ws As Worksheet
    Dim csvFileName As String
    Dim folderPath As String
    Dim tempWB As Workbook
    Dim lastRow As Long
    Dim i As Long, j As Long
    Dim fileSystem As Object
    Dim fileStream As Object

    ' path to xlsx file to convert and save csv file
    ' for Windows OS
    folderPath = "C:\Users\river\workdir\"

    ' Set ws to the first sheet
    Set ws = ThisWorkbook.Sheets(1)

    ' Set csv file name
    csvFileName = folderPath & ws.Name & ".csv"

    ' Get the last row of the sheet
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row

    ' Create a new text file
    Set fileSystem = CreateObject("Scripting.FileSystemObject")
    Set fileStream = fileSystem.CreateTextFile(csvFileName, True, True)

    ' Write the data to the text file
    For i = 2 To lastRow
        For j = 1 To ws.UsedRange.Columns.Count
            If j > 1 Then
                fileStream.Write ","
            End If
            fileStream.Write QuoteCSV(ws.Cells(i, j).Value)
        Next j
        fileStream.WriteLine
    Next i

    ' Close the text file
    fileStream.Close

    MsgBox "CSV file created: " & csvFileName

End Sub

Function QuoteCSV(s As String) As String
    ' If the string contains a comma or double quote, wrap it in double quotes
    If InStr(s, ",") > 0 Or InStr(s, """") > 0 Then
        QuoteCSV = """" & Replace(s, """", """""") & """"
    Else
        QuoteCSV = s
    End If
End Function