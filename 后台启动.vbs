Set WshShell = CreateObject("WScript.Shell")

' 获取脚本所在目录
ScriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

' 切换到脚本目录并运行启动脚本
' 0 = 隐藏窗口, False = 不等待完成
WshShell.Run "cmd /c cd /d """ & ScriptDir & """ && node server.js", 0, False

' 等待2秒后打开浏览器
WScript.Sleep 2000

' 打开浏览器
WshShell.Run "http://localhost:3000", 1, False

' 显示通知（可选）
' MsgBox "AI长篇小说生成器已在后台启动！" & vbCrLf & vbCrLf & "访问地址: http://localhost:3000", vbInformation, "启动成功"
