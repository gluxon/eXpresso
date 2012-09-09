; create list of associated apps
MakeListApps(inifile,tempfile){
    list:=MakeListNoDups(inifile)
    Loop, Parse, list, |
        {
        SplitPath, A_LoopField,,,, OutNameNoExt,
        IniRead, thisapp, %tempfile%, AppsList, %OutNameNoExt%, ERROR
        If thisapp = %A_LoopField%
            {
            Continue
            }
        If thisapp = ERROR
            {
            IniWrite, %A_LoopField%, %tempfile%, AppsList, %OutNameNoExt%
            Continue
            }
        If thisapp <> %A_LoopField%
            {
            Loop
                {
                IniRead, thisapp2, %tempfile%, AppsList, %OutNameNoExt%-%A_Index%, ERROR
                If thisapp2 = ERROR
                    {
                    IniWrite, %A_LoopField%, %tempfile%, AppsList, %OutNameNoExt%-%A_Index%
                    break
                    }
                }
            Continue
            }
        }
    header = AppsList
    list:=GetIniSecListKey(tempfile,header)
    Return, list
}

; create list of all keys from association and alternative sections in eXpresso.ini
MakeListKey(inifile){
    header1=associations
    listMain:=GetIniSecListKey(inifile,header1)
    header2=alternative
    listAlternative:=GetIniSecListKey(inifile,header2)
    list=%listMain%
    If listMain
        {
        Loop, parse, listAlternative, |
            {
            altarray:=A_LoopField
            Loop, parse, listMain, |
                {
                If A_LoopField = %altarray%
                    {
                    cntrl = f
                    break
                    }
                cntrl = t
                }
            IfEqual,cntrl,t
                {
                list=%list%|%altarray%
                }
            IfEqual,cntrl,f
                {
                Continue
                }
            }
        }
        Else
            list=%listAlternative%
    Return list
}

; create list of all keys from association and alternative sections in eXpresso.ini, not allowing redundancies
MakeListNoDups(inifile){
    exclude = host
    header1=associations
    listMain:=GetIniSecListNoDups(inifile,header1,exclude)
    header2=alternative
    listAlternative:=GetIniSecListNoDups(inifile,header2,exclude)
    list=%listMain%
    Loop, parse, listAlternative, |
        {
        altarray:=A_LoopField
        Loop, parse, listMain, |
            {
            If A_LoopField=%altarray%
                {
                cntrl = 0
                break
                }
            cntrl = 1
            }
        IfEqual,cntrl,1
            {
            list=%list%|%altarray%
            }
        }
    Return, list
}
