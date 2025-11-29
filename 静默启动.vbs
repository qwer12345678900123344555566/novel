Dim WshShell, FSO, ScriptDir, NodeModulesExists

Set WshShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")

' 获取脚本所在目录
ScriptDir = FSO.GetParentFolderName(WScript.ScriptFullName)

' 检查node_modules是否存在
NodeModulesExists = FSO.FolderExists(ScriptDir & "\node_modules")

If Not NodeModulesExists Then
    ' 如果依赖未安装，提示用户
    Result = MsgBox("检测到首次运行，需要安装依赖。" & vbCrLf & vbCrLf & _
                    "这可能需要2-5分钟，是否继续？", _
                    vbYesNo + vbQuestion, "安装依赖")
    
    If Result = vbYes Then
        ' 显示安装窗口（需要用户看到安装进度）
        WshShell.Run "cmd /c cd /d """ & ScriptDir & """ && npm install && pause", 1, True
        
        ' 检查是否安装成功
        If FSO.FolderExists(ScriptDir & "\node_modules") Then
            MsgBox "依赖安装成功！现在启动服务器...", vbInformation, "安装完成"
        Else
            MsgBox "依赖安装失败！请运行""安装依赖.bat""手动安装。", vbCritical, "安装失败"
            WScript.Quit
        End If
    Else
        WScript.Quit
    End If
End If

' 后台启动服务器
WshShell.Run "cmd /c cd /d """ & ScriptDir & """ && node server.js", 0, False

' 显示启动提示
MsgBox "AI长篇小说生成器正在后台启动..." & vbCrLf & vbCrLf & _
       "服务器地址: http://localhost:3000" & vbCrLf & vbCrLf & _
       "即将自动打开浏览器...", vbInformation, "启动中"

' 等待服务器启动
WScript.Sleep 3000

' 打开浏览器
WshShell.Run "http://localhost:3000", 1, False
