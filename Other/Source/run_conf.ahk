; assign strings
IniRead, txtrun, %lng%, rungui, txtrun, Run
IniRead, runtitlegui, %lng%, rungui, runtitlegui, eXpresso | Type And Run
IniRead, txtalt, %lng%, rungui, txtalt, Run Alternative
IniRead, btnbrowse, %lng%, shared, btnbrowse, ...
IniRead, btnquit, %lng%, shared, btnquit, Close
IniRead, ddoptions, %lng%, rungui, ddoptions, Keep Me On Top|Minimize Me After Run|Close Me After Run
IniRead, keywordtitle, %lng%, rungui, keywordtitle, eXpresso | Keyword
IniRead, runfiletitle, %lng%, rungui, runfiletitle, eXpresso | Select File to Launch
IniRead, makekeyword, %lng%, rungui, makekeyword, Create Keyword
IniRead, alltypes, %lng%, shared, alltypes, All Files
IniRead, nofile, %lng%, rungui, nofile, No file selected to run
thiswintitle:=runtitlegui

; create GUI for Run
rungui:
	IniRead, glass, %inifile%, configuration, glass, 0
	If (glass=1){
		Gui, 5:+LastFound +Resize MinSize MaxSize -Caption
        hWnd := WinExist()
        VarSetCapacity(rect, 16, 0xff) ; This is the same as setting all fields to -1.
        DllCall("dwmapi\DwmExtendFrameIntoClientArea", "uint", hWnd, "uint", &rect)
        Gui, 5:Font, c0x000000
        Gui, 5:Color, 000000
    }
    Gui, 5:-SysMenu
    Gui, 5:Add, GroupBox, x6 y0 w430 h90 , %txtrun%
    Gui, 5:Add, Edit, x16 y20 w240 h20 vselectedapp gselection, ; la barre affichant le chemin vers le paquet
    Gui, 5:Add, Button, x266 y20 w30 h20 gbrowse, %btnbrowse%
    Gui, 5:Add, Button, x306 y20 w120 h20 vkeyword gkeyword disabled, %makekeyword% +>
    Gui, 5:Add, Button, x306 y50 w120 h30 gGuiexecute, %txtrun%
    IfExist %inifile%  ;only add the "Alternative" button if associations exist.
        Gui, 5:Add, Button, x176 y50 w120 h30 gGuiAltExecute, %txtalt%
    Gui, 5:Add, DropDownList, x16 y100 w160 h20 Choose%Mode% r3 AltSubmit vMode gChangeMode, %ddoptions%
    Gui, 5:Add, Button, x306 y100 w120 h30 g5GuiClose, %btnquit%
    Gui, 5:Show,, %runtitlegui%
    GuiControl, 5:Choose, Mode, 1
    Gosub ChangeMode
return

browse:
Gui, 5:-AlwaysOnTop
FileSelectFile, appselected, 3, ,%runfiletitle%, %alltypes% (*.*)
GuiControl, 5:, selectedapp, %appselected%
Gui, 5:+AlwaysOnTop
return

selection:
    GuiControlGet, appselected,5:, selectedapp
    If appselected
        GuiControl, enable, keyword
    else
        GuiControl, disable, keyword
return

keyword:
    Gui, 5:+OwnDialogs
    GuiControlGet, appselected,5:, selectedapp
    appselected:=GetRelPath(inifile,appselected)
    IniRead, keywordprompt, %lng%, rungui, keywordprompt, Enter a keyword for $app
    StringReplace, keywordprompt, keywordprompt, $app, %appselected%
    InputBox, keyword, %keywordtitle%, %keywordprompt%,,, 132
    If (keyword && !ErrorLevel)
        IniWrite, %appselected%, %inifile%, keywords, %keyword%
return

Guiexecute:
    GuiControlGet, appselected,5:, selectedapp
    section:="associations"
    execute:
        Gui, 5:+OwnDialogs
        If appselected
            {
            IniRead, appselected, %inifile%, keywords, %appselected% , %appselected%
            Loop, %appselected%
                appselected = %A_LoopFileLongPath%
            filename = %appselected%
            Gosub RunAction
            If ErrorLevel
                {
                Loop, %appselected%
                    filename = %A_LoopFileName%
                IniRead, filenotfound, %lng%, shared, filenotfound, The specified file, $file, cannot be found
                StringReplace, filenotfound, filenotfound, $file, %filename%
                Gui, 5:-AlwaysOnTop
                MsgBox, 4096, eXpresso | Not Found, %filenotfound%
                Gui, 5:+AlwaysOnTop
                Run, "%filename%",,UseErrorLevel
                }
            If Mode=2
                Gui, 5:Minimize
            If Mode=3
                Gosub, 5GuiClose
            }
        Else
            {
            Gui, 5:-AlwaysOnTop
            MsgBox, , eXpresso | No File, %nofile%
            Gui, 5:+AlwaysOnTop
            }
return

GuiAltExecute:
    GuiControlGet, appselected,5:, selectedapp
    section:="alternative"
    Gosub execute
return

RunAction:
    Gui, 5:+OwnDialogs
    If filename
        {
        IfNotExist %inifile%
            {
            Run, "%filename%",,UseErrorLevel
            return
            }
        Else
            {
            SplitPath, filename,,, extension
            ; if file is a shortcut, find its target
            IfEqual extension, lnk
                FileGetShortcut, %filename%, filename
            SplitPath, filename ,,, extension
            ; check which app the extension is associated to
            IniRead, prog, %inifile%, %section%, %extension%, host
            ; if selected file is URL, act on URL
            IfEqual extension, url
                IniRead, filename, %filename%, InternetShortcut, URL
            folder := InStr(FileExist(filename), "D")
            If (prog="host" || folder)
                {
                Run, "%filename%",,UseErrorLevel
                }
            Else
                {
                IfExist %prog%
                    Run, "%prog%" "%filename%",,UseErrorLevel
                Else
                    {
                    Splitpath, prog, progname
                    IniRead, appnotfound, %lng%, shared, appnotfound, The application $prog`nthat should open $extension files was not found.`nDo you wish to update the association?
                    StringReplace, appnotfound, appnotfound, ``n, `n, All
                    StringReplace, appnotfound, appnotfound, $prog, %progname%
                    StringReplace, appnotfound, appnotfound, $extension, %extension%
                    Gui, 5:-AlwaysOnTop
                    MsgBox, , eXpresso | Not Found, %appnotfound%
                    Gui, 5:+AlwaysOnTop
                    Run, "%filename%",,UseErrorLevel
                    }
                }
            }
        }
return

ChangeMode:
    GuiControlGet, Mode,5:, Mode
    If Mode=1
        Gui, 5:+AlwaysOnTop
    Else
        Gui, 5:-AlwaysOnTop
    IniWrite, %Mode%, %inifile%, configuration, runguimode
return

5GuiClose:
    Gosub GuiDestroyAll
return
