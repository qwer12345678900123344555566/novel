Dim WshShell, Result

Set WshShell = CreateObject("WScript.Shell")

' 确认是否停止
Result = MsgBox("确定要停止 AI长篇小说生成器服务吗？", vbYesNo + vbQuestion, "停止服务")

If Result = vbYes Then
    ' 查找并结束Node进程（占用3000端口的）
    On Error Resume Next
    
    ' 尝试结束占用3000端口的进程
    WshShell.Run "cmd /c for /f ""tokens=5"" %a in ('netstat -ano ^| findstr "":3000""') do taskkill /PID %a /F", 0, True
    
    If Err.Number = 0 Then
        MsgBox "服务器已停止！", vbInformation, "操作成功"
    Else
        MsgBox "未找到运行中的服务器，或停止失败。", vbExclamation, "提示"
    End If
    
    On Error Goto 0
End If
