/*MoreInfo(name, file, config_file, inform){	
	IniRead, showonrun, %config_file%, configuration, showonrun, 1
	If (showonrun=0) {
		Goto There
    }
    Else If (showonrun=1)
    {
        Show(name, file)
    }
    There:
    ;StringReplace, msgDlg, file,.txt
    Menu, info, Add, %name%, Show
    Menu, tray, Add, %inform%, :info
    return
}
*/

;Display the text files
Show(name, file){
    Loop
    {
        Gui, %A_Index%:+LastFoundExist
        IfWinExist
            Continue
        Else
            {
            num = %A_Index%
            Break
            }
    }
    Gui, %num%: +AlwaysOnTop +ToolWindow +LabelDialog
    FileRead, FileContents, %file%
    Gui, %num%: Add, Edit, R20 W500 ReadOnly, %FileContents%
    ;StringReplace, msgDlg, file, .txt
    Gui, %num%: Show, Center, %name%
    Send, {pgup}{pgup}
return
}

; Handle user interaction with Info section of tray menu
InfoMenu(){
    global
    Show:
        file = %A_ThisMenuItem%.txt
        name = %A_ThisMenuItem%
        Show(name, file)
    return
    DialogClose:
        Gui, %A_Gui% : Destroy
    return
}