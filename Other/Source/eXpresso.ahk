;##AhkResUpdate_Language=1033
;##AhkResUpdate_OutFile=..\..\..\..\eXpresso\eXpresso.exe
;##AhkResUpdate_Icon=..\..\..\..\eXpresso\App\AppInfo\appicon.ico
;##AhkResUpdate_Comment=eXpresso by Goofy
;##AhkResUpdate_Description=eXpresso
;##AhkResUpdate_FileVersion=1.3.1.0
;##AhkResUpdate_LegalCopyright=PortableApps.com & Contributors
;##AhkResUpdate_requestedExecutionLevel=asInvoker

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                                                 ;;
;;     Application Name: eXpresso (Conveyor -> Associate File Extensions), formerly known as CAFEMod               ;;
;;                                                                                                                 ;;
;;     AutoHotkey Version:         1.x                                                                             ;;
;;     Language:                   English                                                                         ;;
;;     Platform:                   Windows                                                                         ;;
;;     Authors:                    Brandon Cheng <bcheng.gt@gmail.com> and Eric Pilsits <epilsits@gmail.com>       ;;
;;                                                                                                                 ;;
;;     C.A.F.�. (Mod) App found at: http://portableapps.com/node/13453                                             ;;
;;     Authors: Zachary Hudock <zrhudock@adelphia.net> and Brian All <brianallb23@gmail.com>                       ;;
;;                                                                                                                 ;;
;;     Original C.A.F.�. App found at:  http://clef.usb.googlepages.com/cafe                                       ;;
;;     Authors:  Yann Perrin <yann.perrin+clef@gmail.com> and Lahire Biette <tuxmouraille@gmail.com>               ;;
;;                                                                                                                 ;;
;;     Purpose of eXpresso:                                                                                        ;;
;;     Create temporary file associations for portable applications.                                               ;;
;;                                                                                                                 ;;
;;                                         PROGRAMMERS:                                                            ;;
;;                                                                                                                 ;;
;;                                         Yann Perrin                                                             ;;
;;                                        Lahire Biette                                                            ;;
;;                                        Zachary Hudock                                                           ;;
;;                                          Brian All                                                              ;;
;;                                         Brandon Cheng                                                           ;;
;;                                         Eric Pilsits                                                            ;;
;;                                                                                                                 ;;
;;                                          GRAPHICS:                                                              ;;
;;                                                                                                                 ;;
;;                                           Neorame                                                               ;;
;;                                          Mr.Magical                                                             ;;
;;                                         Tango Icon Set                                                          ;;
;;                                        Crystal Icon Set                                                         ;;
;;                                                                                                                 ;;
;;                                       HELP AND SUPPORT:                                                         ;;
;;                                                                                                                 ;;
;;                                        ComputerFreaker                                                          ;;
;;                                 The PortableApps.com Community                                                  ;;
;;                                  Lupo, from the Lupo PenSuite                                                   ;;
;;                                                                                                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#NoEnv
SendMode Input
SetBatchLines -1
ListLines off
SetWorkingDir %A_ScriptDir%
#SingleInstance force
#NoTrayIcon

; Quit app if launched with /exit parameter
IfEqual, 1, /exit
ExitApp

; Include external functions for handling file and application paths and handling ini files
#Include %A_ScriptDir%
#Include library.ahk
#Include eXpresso_library.ahk
#Include info.ahk
#Include MI.ahk

eXpressoIni:
Process, Priority,, H
CoordMode, Mouse, Screen
SetWorkingDir, %A_ScriptDir%
FileCreateDir, Data
FileCreateDir, Data\Links
StringReplace, inifile, A_ScriptName, .ahk, .ini
StringReplace, inifile, inifile, .exe, .ini
inifile = Data\%inifile%
Loop, %inifile%
inifile = %A_LoopFileLongPath%
firstClick := 0

;Get Drive Letter
IniRead, dassoc, %inifile%, configuration, dassoc, 0
SplitPath, A_ScriptDir ,,,,, CurrentDrive

; Get Localization
    IniRead, lng, %inifile%, configuration, lang, English.lng
    Lng = App\Locale\%lng%
    Loop, %lng% {
        lng = %A_LoopFileLongPath%
        lngdir = %A_LoopFileDir%
    }

; Get Theme
    IniRead, ctheme, %inifile%, configuration, theme, Default
    If (ctheme =="Default") {
        IfNotExist, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\
        {
            MsgBox, 48, No Theme, The default theme is gone. Please reinstall.
            Goto, Quit
        }
    } Else {
        IfNotExist, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%
        {
            IniDelete, %inifile%, configuration, theme
            Run, %A_ScriptFullPath%,,UseErrorLevel
        }
    }

    IniRead, runningicon, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\eXTheme.ini, Theme, Running, running.ico
    IniRead, pausedicon, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\eXTheme.ini, Theme, Paused, paused.ico
    IniRead, informationicon, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\eXTheme.ini, Theme, Information, information.ico
    IniRead, preferencesicon, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\eXTheme.ini, Theme, Preferences, preferences.ico
    IniRead, conveyicon, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\eXTheme.ini, Theme, Convey, convey.ico
    IniRead, typeandrunicon, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\eXTheme.ini, Theme, TypeAndRun, typeandrun.ico
    IniRead, pauseicon, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\eXTheme.ini, Theme, Pause, pause.ico
    IniRead, refreshicon, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\eXTheme.ini, Theme, Refresh, refresh.ico
    IniRead, quiticon, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\eXTheme.ini, Theme, Quit, quit.ico

    Running = 1
    Menu, Tray, Icon, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\%runningicon%, 1, 0 ; change the icon
    Menu, Tray, Icon ; show the icon hidden with #NoTrayIcon

; tray menu
    IniRead, pref, %lng%, tray, pref, Preferences
    IniRead, inform, %lng%, tray, information, Information
    IniRead, mtheme, %lng%, tray, theme, Theme
    IniRead, sendto, %lng%, tray, sendto, Convey
    IniRead, exec, %lng%, tray, exec, Type And Run
    IniRead, pause, %lng%, tray, pause, Pause
    IniRead, refresh, %lng%, tray, refresh, Refresh eXpresso
    IniRead, quit, %lng%, tray, quit, Quit

    ;******** Not Yet Implemented ************
    ;IniRead, upd, %lng%, tray, upd, Update
    ;*****************************************

; information menu
    IniRead, instructions, %lng%, info, instructions, Instructions
    IniRead, license, %lng%, info, license, License

; preference menu
    IniRead, language, %lng%, pref, language, Language Choice

    IniRead, driveassoc, %lng%, pref, driveassoc, Associate Only On Drive
    IniRead, autoassoc, %lng%, pref, autoassoc, Auto Associate New To Host
    IniRead, associations, %lng%, pref, associations, Associations Config

    IniRead, enableglass, %lng%, pref, glass, Enable Glass
    IniRead, dblclickset, %lng%, pref, dblclickset, Double-click Settings
    IniRead, configassoc, %lng%, pref, configassoc, Extension Configuration
    IniRead, configapps, %lng%, pref, configapps, Application Path Configuration
    IniRead, configwin, %lng%, pref, configwin, Monitored Window Configuration
    IniRead, confedit, %lng%, pref, confedit, Edit Configuration ini File

; convey menu
    IniRead, reconvey, %lng%, sendto, reconvey, ReConvey
    IniRead, linksfolder, %lng%, sendto, linksfolder, Open Links Folder
    IniRead, sendtofolder, %lng%, sendto, sendtofolder, Open Send To Folder

; shared
    ; IniRead, runfile, %lng%, messages, runfile, Would you like to run the selected`nfile in the selected application?
    ; StringReplace, runfile, runfile, ``n, `n, All

; Double-Click Settings strings
    IniRead, labelfast, %lng%, dblclickgui, labelfast, Fast
    IniRead, labelslow, %lng%, dblclickgui, labelslow, Slow
    IniRead, buttontest, %lng%, dblclickgui, buttontest, This button`nallows you`nto test sensitivity`nat the chosen speed`nby double-clicking it
    StringReplace, buttontest, buttontest, ``n, `n, All
    IniRead, dblclicktt, %lng%, dblclickgui, dblclicktt, Double-click!
    IniRead, bntvalidate, %lng%, dblclickgui, bntvalidate, Validate
    IniRead, bntcancel, %lng%, dblclickgui, bntcancel, Cancel
    IniRead, dblclicktitlegui, %lng%, dblclickgui, dblclicktitlegui, eXpresso | Double-click Settings
    IniRead, textdc, %lng%, dblclickgui, textdc, Double-Click

; set customized double-click speed
    initialDblClickSpeed := DllCall("GetDoubleClickTime")
    IniRead, dblClickSpeed, %inifile%, configuration, doubleclick, %initialDblClickSpeed%
    If (dblClickSpeed != initialDblClickSpeed)
        DllCall("SetDoubleClickTime", "uint", dblClickSpeed)
    oneClick := 0
    OnExit, Quit

; Collect info on mouse location at the time of double-click
    SysGet, XDblClickDiff, 36
    SysGet, YDblClickDiff, 37

; create tray menu
    If A_IsCompiled
        Menu, tray, NoStandard
    FileCreateDir, App\Docs
    FileInstall, Instructions.txt, App\Docs\Instructions.txt
    Menu, info, Add, %instructions%, Instructions
    FileInstall, License.txt, App\Docs\License.txt
    Menu, info, Add, %license%, License

    Menu, tray, Add, %inform%, :info

; add language choice to tray menu
    Loop, %lngdir%\*.lng
    {
        nbfile := A_Index
        StringReplace, lang, A_LoopFileName, .lng
        Menu, languages, Add, %lang%, Lng
        if (A_LoopFileLongPath = lng)
            Menu, languages, Check, %lang%
    }
    If nbfile
        Menu, pref, Add, %language%, :languages
        ;Menu, pref, Add


; Build Associations Config Section of Preferences
    Menu, assoc, Add, %driveassoc%, DriveAssoc
    Menu, assoc, Add, %autoassoc%, AutoAssoc
    Menu, pref, Add, %associations%, :assoc

; Build and Get Themes
    Loop, App\DefaultData\Themes\*, 2
    {
        nbfile := A_Index
        Menu, themes, Add, %A_LoopFileName%, Theme
    }
    If nbfile
        Menu, pref, Add, %mtheme%, :themes

    Menu, themes, ToggleCheck, %ctheme%

; Build Preferences Section of Menu
    Menu, pref, Add
    Menu, pref, Add, %enableglass%, Glass
    Menu, pref, Add
    Menu, pref, Add, %dblclickset%`t(Win+Alt+M), ConfigMouse
    Menu, pref, Add, %configassoc%`t(Win+Alt+X), eXpressoConfExt
    Menu, pref, Add, %configapps%`t(Win+Alt+A), eXpressoConfApps
    Menu, pref, Add, %configwin%`t(Win+Alt+W), eXpressoConfWindows
    Menu, pref, Add, %confedit%`t(Win+Alt+I), eXpressoEdit
    Menu, Tray, Add, %pref%, :pref
    Menu, Tray, Add

; Build Convey Section of Menu
    Menu, sendto, Add, %reconvey%, ReConvey
    Menu, sendto, Add, %linksfolder%, OpenLinksFolder
    Menu, sendto, Add, %sendtofolder%, OpenSendToFolder
    Menu, Tray, Add, %sendto%, :sendto

; Build RunBox
    Menu, Tray, Add
    Menu, Tray, Add, %exec%`t(Alt+Win+R), RunBox
    Menu, Tray, Add

; Finish building tray
    Menu, Tray, Add, %pause%`t(Win+Alt+P), Pause
    Menu, Tray, Add, %refresh%`t(Win+Alt+F5), Refresh
    Menu, Tray, Add, %quit%`t(Win+Alt+Esc), Quit
    Menu, Tray, Default, %pause%`t(Win+Alt+P)
    Menu, Tray, Tip, eXpresso

    IniRead, auto, %inifile%, configuration, auto, 0
    If auto
        Menu, assoc, Check, %autoassoc%

    IniRead, dassoc, %inifile%, configuration, dassoc, 0
    If dassoc
        Menu, assoc, Check, %driveassoc%

    IniRead, glass, %inifile%, configuration, glass, 0
    If glass
        Menu, pref, Check, %enableglass%

; Add Icons
    IconsTray := MI_GetMenuHandle("Tray")
    IfExist, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\%informationicon%
        MI_SetMenuItemIcon(IconsTray, 1, A_ScriptDir "\App\DefaultData\Themes\" ctheme "\" informationicon, 1, 16)
    IfExist, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\%preferencesicon%
        MI_SetMenuItemIcon(IconsTray, 2, A_ScriptDir "\App\DefaultData\Themes\" ctheme "\" preferencesicon, 1, 16)
    IfExist, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\%conveyicon%
        MI_SetMenuItemIcon(IconsTray, 4, A_ScriptDir "\App\DefaultData\Themes\" ctheme "\" conveyicon, 1, 16)
    IfExist, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\%typeandrunicon%
        MI_SetMenuItemIcon(IconsTray, 6, A_ScriptDir "\App\DefaultData\Themes\" ctheme "\" typeandrunicon, 1, 16)
    IfExist, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\%pauseicon%
        MI_SetMenuItemIcon(IconsTray, 8, A_ScriptDir "\App\DefaultData\Themes\" ctheme "\" pauseicon, 1, 16)
    IfExist, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\%refreshicon%
        MI_SetMenuItemIcon(IconsTray, 9, A_ScriptDir "\App\DefaultData\Themes\" ctheme "\" refreshicon, 1, 16)
    IfExist, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\%quiticon%
        MI_SetMenuItemIcon(IconsTray, 10, A_ScriptDir "\App\DefaultData\Themes\" ctheme "\" quiticon, 1, 16)


; Launch Paused
    IfEqual, 1, /pause
        Gosub, Pause

; Launch Convey
    Gosub, Convey

; choose windows in which script will function
    GroupAdd, Interception, ahk_class Progman
    GroupAdd, Interception, ahk_class WorkerW
    GroupAdd, Interception, ahk_class ExploreWClass,,, Control Panel
    GroupAdd, Interception, ahk_class CabinetWClass,,, Control Panel
    IniRead, managedWindows, %inifile%, configuration, managedWindows, 0
    If managedWindows
    {
        Loop, Parse, managedWindows, `|, %A_Tab%%A_Space%
            GroupAdd, Interception, %A_LoopField%
    }
Return

; set up specific shortcuts
    #IfWinActive ahk_group Interception
    LButton::
        section := "associations"
        Gosub, eXpressoVerifdoubleclick
    Return

    !LButton::
        section := "alternative"
        Gosub, eXpressoVerifdoubleclick
    Return

    +^LButton::
        section := "associations"
        Gosub, eXpressoAssoc
    Return

    ^!LButton::
        section := "alternative"
        Gosub, eXpressoAssoc
    Return

    LButton Up::
        Click Up
    Return

    $Enter::
    $NumpadEnter::
        section := "associations"
        nonInterception := "eXpressoEnter"
        Gosub, eXpressoAction
    Return

    !Enter::
    !NumpadEnter::
        section := "alternative"
        nonInterception := "eXpressoAltEnter"
        Gosub, eXpressoAction
    Return

; set up general shortcuts
    #IfWinActive
    ~LButton::
    ~!LButton::
        MouseGetPos, PriorX, PriorY
        firstClick := A_TickCount
    Return

; ------------ Labels correspond to menu entries ----------

;Show Tray Menu With Right Click
!#RButton::
ShowTrayMenu:
    Menu, Tray, Show
Return

Instructions:
Show(instructions, "App\Docs\Instructions.txt")
Return

License:
Show(license, "App\Docs\License.txt")
Return

;Enable the Aero Glass
Glass:
    Menu, pref, ToggleCheck, %enableglass%
    IniRead, glass, %inifile%, configuration, glass, 0
    If (glass=1) {
        IniDelete, %inifile%, configuration, glass
        }
    Else {
        IniWrite, 1, %inifile%, configuration, glass
        MsgBox, 48, Incomplete Feature, Please note that glass is looks horrible right now.
    }
Return

; Associate Only On Drive
DriveAssoc:
    Menu, assoc, ToggleCheck, %driveassoc%
    IniRead, dassoc, %inifile%, configuration, dassoc, 0
    If (dassoc=1) {
        IniDelete, %inifile%, configuration, dassoc
    }
    Else {
        IniWrite, 1, %inifile%, configuration, dassoc
    }
Return

; Auto Associate
AutoAssoc:
    Menu, assoc, ToggleCheck, %autoassoc%
    IniRead, auto, %inifile%, configuration, auto, 0
    If (auto=1) {
        IniDelete, %inifile%, configuration, auto
    }
    Else {
        IniWrite, 1, %inifile%, configuration, auto
    }
Return

; Language choice
Lng:
    lngfile = %A_ThisMenuItem%.lng
    IniWrite, %lngfile%, %inifile%, configuration, lang
    Run, %A_ScriptFullPath%,,UseErrorLevel
Return

; edit ini file
!#i::
Gosub GuiDestroyAll
eXpressoEdit:
    IfNotExist, %inifile%
    {
        FileAppend,, %inifile%
        filename := inifile
        extension := "ini"
        section := "associations"
        Gosub, Association
    }
    Else
    {
        IniRead, prog, %inifile%, associations, ini, host
        StringReplace, appnotfound, appnotfound, $prog, %prog%
        If (prog="host" || !prog)
        {
            Run, notepad "%inifile%",,UseErrorLevel
        }
        Else
        {
            prog:=GetAbsMovPath(prog)
            If %prog%
                Run, "%prog%" "%inifile%",,UseErrorLevel
            Else
            {
                Splitpath, prog, progname
                IniRead, appnotfound, %lng%, shared, appnotfound, The application $prog`nthat should open $extension files was not found.`nDo you wish to update the association?
                StringReplace, appnotfound, appnotfound, ``n, `n, All
                StringReplace, appnotfound, appnotfound, $extension, ini
                StringReplace, appnotfound, appnotfound, $prog, %progname%
                MsgBox, 4, eXpresso | Not Found, %appnotfound%
                IfMsgBox Yes
                    Gosub, eXpressoConfExt
                Else
                    Run, notepad.exe "%inifile%",, UseErrorLevel
            }
        }
    }
Return

; edit extension associations
!#x::
eXpressoConfExt:
Gosub GuiDestroyAll
#Include ext_conf.ahk
Return

; edit app associations
!#a::
eXpressoConfApps:
Gosub GuiDestroyAll
#Include apps_conf.ahk
Return

!#w::
eXpressoConfWindows:
Gosub GuiDestroyAll
#Include window_conf.ahk
Return

; Theme choice
Theme:
    ctheme = %A_ThisMenuItem%
    IniWrite, %ctheme%, %inifile%, configuration, theme
    Run, %A_ScriptFullPath%,,UseErrorLevel
Return

Convey:
    ;MsgBox, 48, Incomplete Feature, This feature is not yet implanted.
    RegRead, SendToPath, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, SendTo
    EnvGet, USERPROFILE, USERPROFILE
    StringReplace, SendToPath, SendToPath, `%USERPROFILE`%, %USERPROFILE%

    IniRead, LastDrive, %inifile%, configuration, LastDrive, %CurrentDrive%
    IniWrite, %CurrentDrive%, %inifile%, configuration, LastDrive
    Loop, Data\Links\*.lnk, 0, 1
    {
        FileGetShortcut, %A_LoopFileFullPath%, LinkTarget, LinkWorkingDir, LinkArgs, LinkDescription, LinkIcon, LinkIconNum, LinkRunState
        IfNotInString, LinkTarget, %CurrentDrive%
        {
            StringReplace, LinkTarget, LinkTarget, %LastDrive%, %CurrentDrive%, 1
            StringReplace, LinkWorkingDir, LinkWorkingDir, %LastDrive%, %CurrentDrive%, 1
            StringReplace, LinkArgs, LinkArgs, %LastDrive%, %CurrentDrive%, 1
            StringReplace, LinkIcon, LinkIcon, %LastDrive%, %CurrentDrive%, 1
            FileCreateShortcut, %LinkTarget%, %A_LoopFileFullPath%, %LinkWorkingDir%, %LinkArgs%, %LinkDescription%, %LinkIcon%, , %LinkIconNum%, %LinkRunState%
        }
    }

    ArrayCount = 0
    Loop, Data\Links\* {
        ArrayCount +=1
        Array%ArrayCount% := A_LoopFileName
        FileCopy, %A_ScriptDir%\Data\Links\%A_LoopFileName%, %SendToPath%
    }
Return

ReConvey:
    IniRead, LastDrive, %inifile%, configuration, LastDrive, %CurrentDrive%
    IniWrite, %CurrentDrive%, %inifile%, configuration, LastDrive
    Loop, Data\Links\*.lnk, 0, 1
    {
        FileGetShortcut, %A_LoopFileFullPath%, LinkTarget, LinkWorkingDir, LinkArgs, LinkDescription, LinkIcon, LinkIconNum, LinkRunState
        IfNotInString, LinkTarget, %CurrentDrive%
        {
            StringReplace, LinkTarget, LinkTarget, %LastDrive%, %CurrentDrive%, 1
            StringReplace, LinkWorkingDir, LinkWorkingDir, %LastDrive%, %CurrentDrive%, 1
            StringReplace, LinkArgs, LinkArgs, %LastDrive%, %CurrentDrive%, 1
            StringReplace, LinkIcon, LinkIcon, %LastDrive%, %CurrentDrive%, 1
            FileCreateShortcut, %LinkTarget%, %A_LoopFileFullPath%, %LinkWorkingDir%, %LinkArgs%, %LinkDescription%, %LinkIcon%, , %LinkIconNum%, %LinkRunState%
        }
    }

    Loop %ArrayCount% {
        element := Array%A_Index%
        FileDelete, %SendToPath%\%element%
    }
    ArrayCount = 0
    Loop, Data\Links\* {
        ArrayCount +=1
        Array%ArrayCount% := A_LoopFileName
        FileCopy, %A_ScriptDir%\Data\Links\%A_LoopFileName%, %SendToPath%
    }
Return

DeConvey:
    Loop %ArrayCount% {
        element := Array%A_Index%
        FileDelete, %SendToPath%\%element%
    }
Return

OpenLinksFolder:
    Run, %A_ScriptDir%\Data\Links
Return

OpenSendToFolder:
    RegRead, SendToPath, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, SendTo
    EnvGet, USERPROFILE, USERPROFILE
    StringReplace, SendToPath, SendToPath, `%USERPROFILE`%, %USERPROFILE%
    Run, %SendToPath%
Return

!#r::
RunBox:
Gosub GuiDestroyAll
#Include run_conf.ahk
Return

; manage pause and run fuctions.
!#p::
Pause:
    If (Running = "1") {
        Menu, Tray, Icon, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\%pausedicon%, , 1
        Menu, tray, ToggleCheck, %pause%`t(Win+Alt+P)
        Running = 0
        Suspend
    } Else If (Running = "0") {
        Menu, tray, ToggleCheck, %pause%`t(Win+Alt+P)
        Menu, Tray, Icon, %A_ScriptDir%\App\DefaultData\Themes\%ctheme%\%runningicon%, , 0
        Running = 1
        Suspend
    }
Return

!#F5::
Refresh:
    Reload
    Sleep 2000
    MsgBox, 16, Error, eXpresso failed to load the new window settings.
Return

; configure mouse
!#m::   ;************change this hotkey****************
ConfigMouse:
    Gosub GuiDestroyAll
    IfWinNotExist %dblclicktitlegui%
    {
        speed := dblClickSpeed
        priorClick := 0
        IniRead, glass, %inifile%, configuration, glass, 0
        If (glass=1){
            Gui, +LastFound -Caption +Resize MinSize MaxSize    
            hWnd := WinExist()
            VarSetCapacity(rect, 16, 0xff) ; This is the same as setting all fields to -1.
            DllCall("dwmapi\DwmExtendFrameIntoClientArea", "uint", hWnd, "uint", &rect)
            Gui, Font, c0x000000
            Gui, Color, 000000
        }
        Gui, +AlwaysOnTop -SysMenu
        Gui, Add, GroupBox, x6 y0 w205 h145, %textdc%
        Gui, Add, Text, x16 y20 vFast, %labelfast%
        Gui, Add, Text,x16 y20 vSlow, %labelslow%
        Gui, Add, Slider, Buddy1Fast Buddy2Slow +Vertical Center Range150-1650 TickInterval150 Line150 gSpeed vSpeed x16 y35 h85, %speed%
        Gui, Add, Button,x70 y20 w130 gTest, %buttontest%
        Gui, Add, Button,x70 y105 w60 h30 gDblClickSet, %bntvalidate%
        Gui, Add, Button,x140 y105 w60 h30 gGuiEscape, %bntcancel%
        Gui, Show,, %dblclicktitlegui%
    }
Return

; label for recording position of slider
Speed:
Return

Test:
    deltaClick := A_TickCount - priorClick
    priorClick := A_TickCount
    If (deltaClick < speed)
    {
        ToolTip, %dblclicktt%
        SetTimer, RemoveToolTip, 500
    }
    Else
    {
        IniRead, oneclicktt, %lng%, dblclickgui, oneclicktt, Single-click :`n- elapsed time : $deltaClickms`n- allowed time : $speedms
        StringReplace, oneclicktt, oneclicktt, ``n, `n, All
        StringReplace, oneclicktt, oneclicktt, $deltaClick, %deltaClick%
        StringReplace, oneclicktt, oneclicktt, $speed, %speed%
        ToolTip, %oneclicktt%
        SetTimer, RemoveToolTip, 1500
    }
Return

RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
Return

DblClickSet:
    dblClickSpeed := speed
    DllCall("SetDoubleClickTime", "uint", speed)
    IniWrite, %speed%, %inifile%, configuration, doubleclick

GuiEscape:
    Gui, Destroy
Return

eXpressoGetUrl:
; if selected file is URL, act on URL
    If (extension = "url")
        IniRead, filename, %filename%, InternetShortcut, URL
Return

; verify double-click
eXpressoVerifdoubleclick:
    Critical
    pastTime := A_TickCount - firstClick
    MouseGetPos, X, Y
    If (oneClick && (pastTime < dblClickSpeed) && (Abs(PriorX - X) <= XDblClickDiff) && (Abs(PriorY - Y) <= YDblClickDiff))
    {
        ; double click
        oneClick := 0
        nonInterception := "eXpressoDblClick"
        Gosub, eXpressoAction
    }
    Else
    {
        ; first click
        oneClick := 1
        PriorX := X
        PriorY := Y
        firstClick := A_TickCount
        ; send click through to managed windows
        Click Down
    }
Return

; get information about selected file
eXpressoGetFileInfo:
    filename := GetFileName()
    If !filename
        Return

eXpressoGetFileInfoShort:
    SplitPath, filename,, wrkngdir, extension
    ; if file is a shortcut, find its target
    If (extension = "lnk")
    {
        FileGetShortcut, %filename%, filename
        SplitPath, filename,, wrkngdir, extension
    }
    ; check which app the extension is associated to
    IniRead, prog, %inifile%, %section%, %extension%, ask
    if ((extension = "exe") || (extension = "com"))
        prog := "host"
    if ((prog != "host") && (prog != "ask"))
        prog := GetAbsMovPath(prog)
Return

; launch associated app if it exists
eXpressoAction:
	Critical
	MouseGetPos, X, Y, activeWin ; get window under mouse cursor
	point := ((Y << 16) | X)
	; did we click on the title bar?
	SendMessage, 0x84, 0, %point%,, ahk_id %activeWin% ; WM_NCHITTEST
	NC_HIT := ErrorLevel
	; this check should allow dbl clicks on a managed window's title bar
	If ((nonInterception = "eXpressoDblClick") && (NC_HIT = 2)) ; HTCAPTION
	{
		Gosub, eXpressoDblClick
		Return
	}
	filenames := GetFileName()
	If !filenames
		Gosub, %nonInterception%
	Else
	{
		StringSplit, filename, filenames, `n, %A_Space%%A_Tab%`r
		Loop %filename0%
		{
			filename := filename%A_Index%
			; get file info
			Gosub, eXpressoGetFileInfoShort
			If (FileExist(filename))
			{
				If (InStr(FileExist(filename), "D"))
				{
					; folder
					; if only one item, send through click or Enter
					; otherwise use Run to launch each item individually
					If (filename0 > 1)
						Run, "%filename%"
					Else
						Gosub, %nonInterception%
					Continue
				}
				If ((prog = "host") || (prog = "ask"))
				{
					IniRead, auto, %inifile%, configuration, auto, 0
					If ((prog = "ask") && !auto)
					{
                        IniRead, dassoc, %inifile%, configuration, dassoc, 0
                        If (dassoc="1") {
                            IfInString, filename, %CurrentDrive%
                            {
                                IniRead, filenotassociated, %lng%, messages, filenotassociated, $extension files are not yet recognised by eXpresso.`nDo you want to set an association for them ?`n(not recommended for exe and com files)
                                StringReplace, filenotassociated, filenotassociated, ``n, `n, All
                                StringReplace, filenotassociated, filenotassociated, $extension, %extension%
                                MsgBox, 35, eXpresso | Associate %extension% Files, %filenotassociated%
                                IfMsgBox Yes
                                    Gosub, Association
                                IfMsgBox No
                                {
                                    IniWrite, host, %inifile%, %section%, %extension%
                                    Run, "%filename%", %wrkngdir%, UseErrorLevel
                                }
                            }
                            Else {
                                Run, "%filename%", %wrkngdir%, UseErrorLevel
                            }
                        }
                        Else {
                            IniRead, filenotassociated, %lng%, messages, filenotassociated, $extension files are not yet recognised by eXpresso.`nDo you want to set an association for them ?`n(not recommended for exe and com files)
                            StringReplace, filenotassociated, filenotassociated, ``n, `n, All
                            StringReplace, filenotassociated, filenotassociated, $extension, %extension%
                            MsgBox, 35, eXpresso | Associate %extension% Files, %filenotassociated%
                            IfMsgBox Yes
                                Gosub, Association
                            IfMsgBox No
                            {
                                IniWrite, host, %inifile%, %section%, %extension%
                                Run, "%filename%", %wrkngdir%, UseErrorLevel
                            }

                        }
					}
					Else
						Run, "%filename%", %wrkngdir%, UseErrorLevel
				}
				Else
				{
					IfNotExist %prog%
					{
                        IniRead, dassoc, %inifile%, configuration, dassoc, 0
                        If (dassoc="1") {
                            IfInString, filename, %CurrentDrive%
                            {
                                Splitpath, prog, progname
                                IniRead, appnotfound, %lng%, shared, appnotfound, The application $prog`nthat should open $extension files was not found.`nDo you wish to update the association?
                                StringReplace, appnotfound, appnotfound, ``n, `n, All
                                StringReplace, appnotfound, appnotfound, $prog, %progname%
                                StringReplace, appnotfound, appnotfound, $extension, %extension%
                                MsgBox, 52, eXpresso | Not Found, %appnotfound%
                                IfMsgBox Yes
                                    Gosub, eXpressoConfExt
                                Else
                                    Run, "%filename%", %wrkngdir%, UseErrorLevel
                            }
                            Else {
                                Run, "%filename%", %wrkngdir%, UseErrorLevel
                            }
                        }
                        Else {
                            MsgBox, %dassoc%
                            Splitpath, prog, progname
                            IniRead, appnotfound, %lng%, shared, appnotfound, The application $prog`nthat should open $extension files was not found.`nDo you wish to update the association?
                            StringReplace, appnotfound, appnotfound, ``n, `n, All
                            StringReplace, appnotfound, appnotfound, $prog, %progname%
                            StringReplace, appnotfound, appnotfound, $extension, %extension%
                            MsgBox, 52, eXpresso | Not Found, %appnotfound%
                            IfMsgBox Yes
                                Gosub, eXpressoConfExt
                            Else
                                Run, "%filename%", %wrkngdir%, UseErrorLevel
                        }
					}
					Else
					{
                        IniRead, dassoc, %inifile%, configuration, dassoc, 0
                        If (dassoc="1") {
                            IfInString, filename, %CurrentDrive%
                            {
                                Run, "%prog%" "%filename%", %wrkngdir%, UseErrorLevel
                            }
                            Else {
                                Run, "%filename%", %wrkngdir%, UseErrorLevel
                            }
                        }
                        Else {
						    Gosub, eXpressoGetUrl
						    Run, "%prog%" "%filename%", %wrkngdir%, UseErrorLevel
                        }
					}
				}
			}
		}
	}
Return

; send keystrokes and double-click, not intercepted
eXpressoEnter:
    Send, {Enter}
Return

eXpressoAltEnter:
    Send, {Alt down}{Enter}{Alt up}
Return

eXpressoDblClick:
    If ((A_TickCount - firstClick) < dblClickSpeed)
        Click Down
    Else
    {
        Click
        Click Down
    }
Return

; associate the extension to an app
eXpressoAssoc:
    Click
    Gosub, eXpressoGetFileInfo
    If !filename
        Return
    assoclist := MakeListKey(inifile)
    If !assoclist
    {
        Gosub Association
        Return
    }
    StringSplit, ext_array, assoclist,`|,
    Loop, Parse, assoclist, `|
    {
        If (A_LoopField = extension)
        {
            IniRead, extexists, %lng%, shared, extexists, $extension files are already managed!`nWould you like to change the association?
            StringReplace, extexists, extexists, ``n, `n, All
            StringReplace, extexists, extexists, $extension, %extension%
            MsgBox, 4,eXpresso | Already Managed, %extexists%
            IfMsgBox No
                Return
            Else
            {
                Gosub Association
                Return
            }
        }
        If ErrorLevel
        {
            Gosub Association
            Return
        }
        Else
            Continue
    }
Association:
    IniRead, assocboxtitle, %lng%, shared, assocboxtitle, eXpresso | Choose the application that will open $extension files
    StringReplace, assocboxtitle, assocboxtitle, $extension, %extension%
    Sleep 200
    FileSelectFile, opener, 3, %prog%, %assocboxtitle%, *.exe
    If opener
    {
        openerrel := GetRelPath(A_ScriptFullPath, opener)
        IniWrite, %openerrel%, %inifile%, %section%, %extension%
        SplitPath, opener,, wrkngdir
        Run, "%opener%" "%filename%", %wrkngdir%, UseErrorLevel

        TrayTip, eXpresso:, A new association has sucessfully been added.
        SetTimer, RemoveTrayTip, 5000
    }
Return

RemoveTrayTip:
    SetTimer, RemoveTrayTip, Off
    TrayTip
Return

GuiDestroyAll:
    FileDelete, %tempfile%
    Gui, Destroy
    Gui, 2:Destroy
    Gui, 3:Destroy
    Gui, 4:Destroy
    Gui, 5:Destroy
    Gui, 6:Destroy
    SetTitleMatchMode, 2
    Splitpath, inifile, ininame
    IfWinExist, %ininame%
    {
        WinActivate, %ininame%
        Send, ^s
        WinClose, %ininame%
    }
Return

!#Esc::
Quit:
If (dblClickSpeed != initialDblClickSpeed)
    DllCall("SetDoubleClickTime", "uint", initialDblClickSpeed)
Gosub, DeConvey
ExitApp