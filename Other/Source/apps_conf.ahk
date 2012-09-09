; assign strings
    IniRead, appguispltext, %lng%, appgui, appguispltext, Application List Creation in Progress...
    IniRead, boxapps, %lng%, appgui, boxapps, Associated Applications
    IniRead, lblabspath, %lng%, appgui, lblabspath, Absolute Path:
    IniRead, lblrelpath, %lng%, appgui, lblrelpath, Relative Path:
    IniRead, btnbrowse, %lng%, shared, btnbrowse, ...
    IniRead, btnOK, %lng%, shared, btnOK, OK
    IniRead, btnquit, %lng%, shared, btnquit, Close
    IniRead, apptitlegui, %lng%, appgui, apptitlegui, eXpresso | Application Path Configuration
    IniRead, titleselectapp, %lng%, appgui, titleselectapp, eXpresso. | Select an application for this association
    IniRead, typeapp, %lng%, shared, typeapp, Application
    IniRead, spashchgmnt, %lng%, appgui, spashchgmnt, Path modification in progress...
    IniRead, splashfin, %lng%, appgui, splashfin, Finished!
    IniRead, boxappspath, %lng%, appgui, boxappspath, Path To Selected Application
    IniRead, howto, %lng%, appgui, howto, To change the path of an associated application, click the application name in the box on the left, then click ... to browse to the new path. Click OK to save the new path.

; create GUI for apps configuration
GUICONFAPPS:
    tempfile = %A_ScriptDir%\temp_eXpresso.temp
    SplashImage,, zh0 fs14 B1,, %appguispltext%
    list:=MakeListApps(inifile,tempfile)
    SplashImage, Off
    Gui, 3:-SysMenu
    Gui, 3:Add, ListBox, x16 y20 w120 h190 gshowpath vlistofapps, %list%
    Gui, 3:Add, GroupBox, x6 y0 w140 h210 , %boxapps%
    Gui, 3:Add, Text, x162 y20 w300 h50 , %howto%
    Gui, 3:Add, Text, x162 y80 w300 h30 , %lblabspath%
    Gui, 3:Add, Edit, x162 y100 w300 h20 vpathappshower,
    Gui, 3:Add, Text, x162 y130 w300 h30 , %lblrelpath%
    Gui, 3:Add, Edit, x162 y150 w300 h20 vrelpathappshower,
    Gui, 3:Add, GroupBox, x152 y0 w320 h210 , %boxappspath%
    Gui, 3:Add, Button, x162 y174 w40 h30 gchoosenewpath, %btnbrowse%
    Gui, 3:Add, Button, x286 y174 w40 h30 gwritechanges, %btnOK%
    Gui, 3:Add, Button, x382 y174 w80 h30 g3GuiClose, %btnquit%
    Gui, 3:Show,, %apptitlegui%
Return

showpath:
    GuiControlGet, thisapp,3:, listofapps
    IniRead, thispath, %tempfile%, AppsList, %thisapp%
    GuiControl,3:, relpathappshower, %thispath%
    thispath:=GetAbsMovPath(thispath)
    GuiControl,3:, pathappshower, %thispath%
return

choosenewpath:
    GuiControlGet, thisapp,3:, listofapps
    FileSelectFile, newpath, 3, , %titleselectapp%, %typeapp% (*.exe)
    If newpath
        {
        relnewpath:=GetRelPath(A_ScriptFullPath,newpath)
        GuiControl,3:, pathappshower, %newpath%
        GuiControl,3:, relpathappshower, %relnewpath%
        }
return

writechanges:
    SplashImage,, zh0 fs14 B1,, %splashchgmnt%
    Gui, 3:+Disabled
    IniRead, holdpath, %tempfile%, AppsList, %thisapp%
    GuiControlGet, relnewpath,3:, relpathappshower
    IniWrite, %relnewpath%, %tempfile%, AppsList, %thisapp%
    ReplaceInFile(inifile,holdpath,relnewpath)
    list:=MakeListApps(inifile,tempfile)
    GuiControl,3:,listofapps,|%list%
    SplashImage, Off
    SplashImage,, zh0 fs14 B1,, %splashfin%
    Sleep, 2000
    SplashImage, Off
    Gui, 3:-Disabled
    GuiControl,3:, pathappshower,
    GuiControl,3:, relpathappshower,
return

3GuiClose:
    FileDelete, %tempfile%
    Gosub GuiDestroyAll
return
