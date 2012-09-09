; assign strings
	IniRead, extguispltext, %lng%, extgui, extguispltext, Extension List Creation In Progress...
	IniRead, boxadd, %lng%, extgui, boxadd, Add an association
	IniRead, textadd, %lng%, extgui, textadd, You can either use the ... button to browse for a file with the desired extension, or you can type the desired extension, beginning with the dot.
	IniRead, btnassoc, %lng%, extgui, btnassoc, Associate
	IniRead, btnbrowse, %lng%, shared, btnbrowse, ...
	IniRead, boxapps, %lng%, extgui, boxapps, Associated Applications
	IniRead, boxmain, %lng%, extgui, boxmain, Main Application
	IniRead, boxsecondary, %lng%, extgui, boxsecondary, Alternative Application
	IniRead, textassoc, %lng%, extgui, textassoc, To use the software on the host computer, type host in the field. You must click OK for the association to be applied.
	IniRead, boxext, %lng%, extgui, boxext, Extension List
	IniRead, delext, %lng%, extgui, delext, Delete Extension
	IniRead, delassoc, %lng%, extgui, delassoc, Delete Association
	IniRead, btnOK, %lng%, shared, btnOK, OK
	IniRead, btnquit, %lng%, shared, btnquit, Close
	IniRead, exttitlegui, %lng%, extgui, exttitlegui, eXpresso | Extension Association Configuration
	IniRead, titleselectfile, %lng%, extgui, titleselectfile, eXpresso | Select a file to associate
	IniRead, alltypes, %lng%, shared, alltypes, All Files
	IniRead, errorext, %lng%, extgui, errorext, Error while adding the extension
	IniRead, typeapp, %lng%, shared, typeapp, Application
	IniRead, nofile, %lng%, extgui, nofile, No file selected to associate
	IniRead, noext, %lng%, extgui, noext, Selected file does not have an extension`nAssociate anyway?
	IniRead, noapp, %lng%, extgui, noapp, Please select an application before`nattempting to create this association.
	IniRead, nullType, %lng%, extgui, nullType, *No Extension

; create GUI for extension config
eXpressoGUI:
	SplashImage,, B1,, %extguispltext%
	assoclist:=MakeListKey(inifile)
	SplashImage, Off
	Gui, 2:-SysMenu
	Gui, 2:Add, GroupBox, x6 y0 w460 h80 , %boxadd%
	Gui, 2:Add, Text, x16 y15 w440 h30 , %textadd%
	Gui, 2:Add, Edit, x16 y50 w330 h20 veditSelectedFileToAssoc,
	Gui, 2:Add, Button, x396 y50 w60 h20 gbtnAddFileExt, %btnassoc%
	Gui, 2:Add, Button, x356 y50 w30 h20 gbtnSearchFile, %btnbrowse%
	Gui, 2:Add, GroupBox, x126 y80 w340 h250 , %boxapps%
	Gui, 2:Add, GroupBox, x136 y140 w320 h90 , %boxmain%
	Gui, 2:Add, Edit, x146 y160 w260 h20 veditMainApp +Disabled,
	Gui, 2:Add, Button, x416 y160 w30 h20 vbtnBrowseMainApp gbtnBrowseMainApp +Disabled, %btnbrowse%
	Gui, 2:Add, GroupBox, x136 y230 w320 h90 , %boxsecondary%
	Gui, 2:Add, Text, x136 y96 w320 h40 , %textassoc%
	Gui, 2:Add, Edit, x146 y250 w260 h20 veditAppSecond +Disabled,
	Gui, 2:Add, Button, x416 y250 w30 h20 vbtnBrowseSecApp gbtnBrowseSecApp +Disabled, %btnbrowse%
	Gui, 2:Add, GroupBox, x6 y80 w110 h250 , %boxext%
	Gui, 2:Add, ListBox, x16 y100 w90 h214 glistexts vlistexts +Sort, %assoclist%
	Gui, 2:Add, Button, x6 y335 w110 h30 gbtnDeleteAssocExt, %delext%
	Gui, 2:Add, Button, x266 y190 w130 h30 vbtnDelMainApp gbtnDelMainApp +Disabled, %delassoc%
	Gui, 2:Add, Button, x266 y280 w130 h30 vbtnDelSecApp gbtnDelSecApp +Disabled, %delassoc%
	Gui, 2:Add, Button, x406 y190 w40 h30 vbtnAssocMainApp gbtnAssocMainApp +Disabled, %btnOK%
	Gui, 2:Add, Button, x406 y280 w40 h30 vbtnAssocSecApp gbtnAssocSecApp +Disabled, %btnOK%
	Gui, 2:Add, Button, x360 y335 w100 h30 g2GuiClose, %btnquit%
	Gui, 2:Show,, %exttitlegui%
Return

; browse for file to associate extension
btnSearchFile:
	FileSelectFile, foundfile, 3, , %titleselectfile%, %alltypes% (*.*)
	GuiControl,2:, editSelectedFileToAssoc, %foundfile%
return

; add extension to list
btnAddFileExt:
	Gui, 2:+OwnDialogs
	assoclist:=MakeListKey(inifile)
	GuiControl,2:, listexts, |
	GuiControl,2:, listexts, %assoclist%
	; extract extension from file name
	GuiControlGet, foundfile,2:, editSelectedFileToAssoc
	; check that a file was selected
	If !foundfile
		{
		MsgBox,, eXpresso | No File, %nofile%
		GuiControl,2:Focus, editSelectedFileToAssoc
		}
	Else
		{
		SplitPath, foundfile,,, extension
		; check that file has an extension
		If !extension
			{
			StringReplace, noext, noext, ``n, `n, All
			MsgBox, 4, eXpresso | No Extension, %noext%
			IfMsgBox Yes
				{
				extension = %nullType%
				Gosub checkIfManaged
				}
			Else
				{
				GuiControl,2:, editSelectedFileToAssoc,
				GuiControl,2:Focus, editSelectedFileToAssoc
				}
			}
		Else
			{
			Gosub checkIfManaged
			}
		}
return

checkIfManaged:
	Gui, 2:+OwnDialogs
	StringSplit, ext_array, assoclist,`|,
	Loop, %ext_array0%
		{
		extarray:=ext_array%a_index%
		If (extarray=extension)
			{
			IniRead, extexists, %lng%, extexists, extexists, $extension files are already managed!`nWould you like to change the associations?
			StringReplace, extexists, extexists, ``n, `n, All
			StringReplace, extexists, extexists, $extension, %extension%
			MsgBox, 4,eXpresso | Already Managed, %extexists%
			IfMsgBox Yes
				{
				GuiControl, 2:Choose, listexts,%extension%
				Gosub listexts
				Return
				}
			Else
				Return
			}
		If ErrorLevel
			{
			MsgBox,,eXpresso | Error, %errorext%
			Return
			}
		Else
			Continue
		}
	GuiControl,2:, listexts,%extension%
	GuiControl, Choose, listexts,%extension%
	If !assoclist
		assoclist=%extension%
	Else
		assoclist=%assoclist%|%extension%
	GuiControl,2:, editSelectedFileToAssoc,
	Gosub listexts
return

; on selection of an extension from the list, all other fields become enabled
listexts:
	GuiControlGet, extension,2:, listexts
	If extension
		{
		IniRead, readmainapp, %inifile%, associations, %extension%, %A_Space%
		IniRead, readappsec, %inifile%, alternative, %extension%, %A_Space%
		GuiControl,2:, editMainApp, %readmainapp%
		GuiControl,2:, editAppSecond, %readappsec%
		GuiControl, 2:Enable, editMainApp
		GuiControl, 2:Enable, editAppSecond
		GuiControl, 2:Enable, btnBrowseSecApp
		GuiControl, 2:Enable, btnBrowseMainApp
		GuiControl, 2:Enable, btnDelMainApp
		GuiControl, 2:Enable, btnDelSecApp
		GuiControl, 2:Enable, btnAssocMainApp
		GuiControl, 2:Enable, btnAssocSecApp
		}
return

; main application
btnBrowseMainApp:
	readapp=%readmainapp%
	Gosub, searchforapp
	GuiControl,2:, editMainApp, %foundfile%
return

; secondary application
btnBrowseSecApp:
	readapp=%readappsec%
	Gosub, searchforapp
	GuiControl,2:, editAppSecond, %foundfile%
return

; browse for the application
searchforapp:
	GuiControlGet, extension,2:, listexts
	IniRead, assocboxtitle, %lng%, shared, assocboxtitle, eXpresso | Choose the application that will open $extension files
	StringReplace, assocboxtitle, assocboxtitle, $extension, %extension%
	FileSelectFile, foundfile, 3, , %assocboxtitle%, %typeapp% (*.exe;*.cmd;*.bat)
	If foundfile
		foundfile:=GetRelPath(A_ScriptFullPath,foundfile)
	Else
		foundfile:=readapp
return

; write path to main app
btnAssocMainApp:
	Gui, 2:+OwnDialogs
	GuiControlGet, extension,2:, listexts
	GuiControlGet, foundfile,2:, editMainApp
	If foundfile
		IniWrite, %foundfile%, %inifile%, associations, %extension%
	Else
		{
		StringReplace, noapp, noapp, ``n, `n, All
		MsgBox,, eXpresso | No Application, %noapp%
		}

	TrayTip, eXpresso, Multiline`nText, 20, 17

		#Persistent
		TrayTip, eXpresso:, A new association has sucessfully been added.
		SetTimer, RemoveTrayTipv, 10000
	return

		RemoveTrayTipv:
		SetTimer, RemoveTrayTip, Off
		TrayTip
	return

; write path to secondary app
btnAssocSecApp:
	Gui, 2:+OwnDialogs
	GuiControlGet, extension,2:, listexts
	GuiControlGet, foundfile,2:, editAppSecond
	If foundfile
		IniWrite, %foundfile%, %inifile%, alternative, %extension%
	Else
		{
		StringReplace, noapp, noapp, ``n, `n, All
		MsgBox,, eXpresso | No Application, %noapp%
		}

	TrayTip, eXpresso, Multiline`nText, 20, 17

		#Persistent
		TrayTip, eXpresso:, A new secondary association has sucessfully been added.
		SetTimer, RemoveTrayTipc, 10000
	return

		RemoveTrayTipc:
		SetTimer, RemoveTrayTip, Off
		TrayTip
	return

; delete main app association
btnDelMainApp:
	GuiControlGet, extension,2:, listexts
	IniDelete, %inifile%, associations, %extension%
	GuiControl,2:, editMainApp,
	assoclist:=MakeListKey(inifile)
	GuiControl,2:, listexts, |%assoclist%
	IfInString, assoclist, %extension%
		GuiControl, 2:Choose, listexts,%extension%
	Else
		Gosub disablefields

	TrayTip, eXpresso, Multiline`nText, 20, 17

		#Persistent
		TrayTip, eXpresso:, Extension successfully removed.
		SetTimer, RemoveTrayTipz, 10000
	return

		RemoveTrayTipz:
		SetTimer, RemoveTrayTip, Off
		TrayTip
	return

; delete secondary app association
btnDelSecApp:
	GuiControlGet, extension,2:, listexts
	IniDelete, %inifile%, alternative, %extension%
	GuiControl,2:, editAppSecond,
	assoclist:=MakeListKey(inifile)
	GuiControl,2:, listexts, |%assoclist%
	IfInString, assoclist, %extension%
		GuiControl, 2:Choose, listexts,%extension%
	Else
		Gosub disablefields

	TrayTip, eXpresso, Multiline`nText, 20, 17

		#Persistent
		TrayTip, eXpresso:, Extension successfully removed.
		SetTimer, RemoveTrayTipx, 10000
	return

		RemoveTrayTipx:
		SetTimer, RemoveTrayTip, Off
		TrayTip
	return

; delete extension association
btnDeleteAssocExt:
	GuiControlGet, extension,2:, listexts
	IniDelete, %inifile%, associations, %extension%
	IniDelete, %inifile%, alternative, %extension%
	GuiControl,2:, editMainApp,
	GuiControl,2:, editAppSecond,
	assoclist:=MakeListKey(inifile)
	GuiControl,2:, listexts, |%assoclist%
	Gosub disablefields
return

disablefields:
	GuiControl, 2:Disable, editMainApp
	GuiControl, 2:Disable, editAppSecond
	GuiControl, 2:Disable, btnBrowseSecApp
	GuiControl, 2:Disable, btnBrowseMainApp
	GuiControl, 2:Disable, btnDelMainApp
	GuiControl, 2:Disable, btnDelSecApp
	GuiControl, 2:Disable, btnAssocMainApp
	GuiControl, 2:Disable, btnAssocSecApp
return

2GuiClose:
	Gosub GuiDestroyAll
return
