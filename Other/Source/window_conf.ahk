; assign strings
STARTHERE:
    IniRead, wintitlegui, %lng%, wingui, wintitlegui,  eXpresso | Monitored Window Configuration
    IniRead, btnOK, %lng%, shared, btnOK, OK
    IniRead, btnquit, %lng%, shared, btnquit, Close
    IniRead, boxwins, %lng%, wingui, boxwins, Managed Windows
    IniRead, boxwinsclass, %lng%, wingui, boxwinsclass, Ahk Class of Managed Window
    Iniread, helpout, %lng%, wingui, helpout, To add another window for eXpresso to manage, hold Shift + Win and click the window's title bar, or if you already know the ahk_class, you can add multiple windows by typing the full class name followed by a pipe | .`n`nYou must click OK for changes to apply.
    StringReplace, helpout, helpout, ``n, `n, All
    IniRead, lblwinclass, %lng%, wingui, lblwinclass, Ahk_class:
    IniRead, delmanagedwin, %lng%, wingui, delmanagedwin, Delete Managed Window
    IniRead, noclass, %lng%, wingui, noclass, No Class Selected!
    IniRead, alreadymanaged, %lng%, wingui, alreadymanaged, Window Already Managed!

; create GUI for window config
GUICONFWIN:
    Gui, 4:-SysMenu
    Gui, 4:Add, ListBox, x16 y20 w130 h143 vlistofwindows
    Gui, 4:Add, GroupBox, x6 y0 w150 h163 , %boxwins%
    Gui, 4:Add, Button, x6 y170 w150 h30 gdelmanagedwin, %delmanagedwin%
    Gui, 4:Add, Text, x172 y20 w300 h80 , %helpout%
    Gui, 4:Add, Text, x172 y120 w300 h30 , %lblwinclass%
    Gui, 4:Add, Edit, x172 y138 w300 h20 vwinclassshower,
    Gui, 4:Add, Button, x286 y164 w40 h30 gapplychanges, %btnok%
    Gui, 4:Add, Button, x392 y164 w80 h30 g4GuiClose, %btnquit%
    Gui, 4:Add, GroupBox, x162 y0 w320 h200 , %boxwinsclass%
    Gui, 4:Show,, %wintitlegui%
    GuiControl, 4:Focus,winclassshower,

    delcount := 0

; update old INIs
IniRead, managedWindows, %inifile%, configuration, managedWindows, 0
If managedWindows
{
    ; strip any trailing |'s
    If (SubStr(managedWindows, 0) = "|") ; if there's a trailing |
    {
        While (SubStr(managedWindows, 0) = "|") ; remove ALL trailing |'s
            managedWindows := SubStr(managedWindows, 1, -1)
        IniWrite, %managedWindows%, %inifile%, configuration, managedWindows ; update INI
    }
}

; display list of managed windows
showlist:
    IniRead, managedWindows, %inifile%, configuration, managedWindows, 0
    If managedWindows
    {
        list=
        Loop, Parse, managedWindows, `|, %A_Space%%A_Tab%
            list .= "|" . A_LoopField
        GuiControl, 4:,listofwindows,%list%
    }
    Else
        GuiControl, 4:,listofwindows,|
return

; add windows hotkey
+#Lbutton::
IfWinExist, %wintitlegui%
{
    Click
    Sleep 200
    WinGetClass, manwind, A
    GuiControl, 4:,winclassshower, ahk_class %manwind%
    WinActivate, %wintitlegui%
}
Else
{
    WinGetClass, manwind, A
    Sleep 200
    Gosub, STARTHERE
    GuiControl, 4:,winclassshower, ahk_class %manwind%
    WinActivate, %wintitlegui%
}
return

; apply newly added windows
applychanges:
    Gui, 4:+OwnDialogs
    GuiControlGet, manwind,4:,winclassshower
    ; strip any trailing |'s
    While (SubStr(manwind, 0) = "|")
        manwind := SubStr(manwind, 1, -1)
    If manwind=
    {
        ; nothing to add
        MsgBox,,eXpresso | No Class,%noclass%
        return
    }
    Else
    {
        IniRead, managedWindows, %inifile%, configuration, managedWindows, 0
        ; loop through new windows and add to list (do not duplicate)
        Loop, Parse, manwind, `|, %A_Space%%A_Tab%
        {
            ; check for default window classes
            manwind := A_LoopField
            If(manwind="ahk_class Progman" || manwind="ahk_class ExploreWClass" || manwind="ahk_class CabinetWClass")
            {
                StringReplace, alreadymanaged, alreadymanaged, $window, %manwind%
                MsgBox,,eXpresso | Already Managed, %alreadymanaged%
            }
            Else
            {
                ; add the new window
                ; first window
                If (managedWindows = 0)
                    managedWindows := manwind
                ; subsequent windows
                Else
                {
                    ; check for duplicates
                    Loop, Parse, managedWindows, `|, %A_Space%%A_Tab%
                    {
                        If (A_LoopField = manwind)
                        {
                            ; skip duplicate
                            StringReplace, alreadymanaged, alreadymanaged, $window, %manwind%
                            MsgBox,,eXpresso | Already Managed, %alreadymanaged%
                            manwind= ; clear window
                            Break
                        }
                    }
                    ; not a duplicate, add to list
                    If manwind
                        managedWindows .= "|" . manwind
                }
            }
        }
        ; write changes to ini and update group
        IniWrite, %managedWindows%, %inifile%, configuration, managedWindows
        If managedWindows
        {
            Loop, Parse, managedWindows, `|, %A_Space%%A_Tab%
                GroupAdd, Interception, %A_LoopField%
        }
        GoSub, showlist
    }
    GuiControl, 4:,winclassshower,
    GuiControl, 4:Focus,winclassshower,
return

; delete managed window
delmanagedwin:
    ; empty string to hold new list
    newmanwind=
    GuiControlGet, selectedwin,4:,listofwindows
    Iniread, managedWindows, %inifile%, configuration, managedWindows,0
    If managedWindows
    {
        Loop, Parse, managedWindows, `|, %A_Space%%A_Tab%
        {
            ; if matched, do not add to new string
            If (A_LoopField = selectedwin)
            {
                delcount++ ; mark for reload
                Continue
            }
            Else
                newmanwind .= A_LoopField . "|"
        }
        If newmanwind
            newmanwind := SubStr(newmanwind, 1, -1) ; remove trailing |
        If newmanwind=
            IniDelete, %inifile%, configuration, managedWindows
        Else
            IniWrite, %newmanwind%, %inifile%, configuration, managedWindows
        list=
        Gosub, showlist
    }
return

; close GUI
4GuiClose:
    If delcount > 0
    {
        Reload
        Sleep 2000
        MsgBox, 16, Error, eXpresso failed to load the new window settings.
    }
    Gosub GuiDestroyAll
return