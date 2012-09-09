; get path to selected file
GetFileName() {
    BlockInput, Mousemove  ;Block mouse movement
    filename=
    oldclip := ClipboardAll
    Clipboard=
    Send, ^c
    ClipWait, 0.25 ; 250ms of waiting
    If !ErrorLevel
        filename := Clipboard
    Clipboard := oldclip
    BlockInput, MouseMoveOff ;Enable mouse movement
    Return, filename
}

; create relative path to the file
GetRelPath(from,to) {
    StringSplit, sfrom, from, \
    StringSplit, sto, to, \
    IfNotEqual, sfrom1, %sto1%
        {
        DriveGet, type, Type, %to%
        IfEqual, type, Removable
            {
            SplitPath, to,,,,, OutDrive
            DriveGet, DriveLabel, Label, %OutDrive%
            If DriveLabel =
                {
                DriveGet, DriveLabel, Serial, %OutDrive%
                If DriveLabel =
                    {
                    rpath = ERROR
                    Return, rpath
                    }
                DriveLabel = *%DriveLabel%*
                rpath:=StrReplace(to,OutDrive,DriveLabel)
                Return, rpath
                }
            DriveLabel = *%DriveLabel%*
            rpath:=StrReplace(to,OutDrive,DriveLabel)
            Return, rpath
            }
        Else
            Return, to
        }
    i=1
    diff=1
    Loop
        {
        cfrom:=sfrom%i%
        cto:=sto%i%
        IfNotEqual cfrom, %cto%
            {
            diff=%i%
            Break
            }
        i++
        }
    i=1
    rpath=
    Loop, %sto0%
        {
        If i>=%diff%
            {
            cto:=sto%i%
            rpath=%rpath%\%cto%
            }
        i++
        }
    StringTrimLeft, rpath, rpath, 1
    i=1
    Loop, %sfrom0%
        {
        If i>%diff%
            {
            rpath=..\%rpath%
            }
        i++
        }
    Return, rpath
}

StrReplace(string, param1 = "", param2 = "") {
    param1 := RegExReplace(param1, "([\[\\\^\$\.\|\?\*\+\(\)])", "\$1")
    new := RegExReplace(string, "i)" . param1, param2)
    Return, new
}

ReplaceInFile(filepath,SearchText,ReplaceText){
    IfNotExist, %filepath%
        {
        return
        }
    SplitPath, filepath, OutFileName, OutDir,,,
    newfilepath = %OutDir%\new.%OutFileName%
    FileCopy, %filepath%, %filepath%.old, 1
    IfExist, %newfilepath%
        {
        FileDelete, %newfilepath%
        }
    Loop, read, %filepath%, %newfilepath%
        {
        newstr:=StrReplace(A_LoopReadLine,SearchText,ReplaceText)
        FileAppend, %newstr%`n
        }
    FileMove, %newfilepath%, %filepath%, 1
}

; get parent directory
GetParentDir(path){
    Return SubStr(path, 1, InStr(path, "\", False, 0) - 1)
}

;;; WTF with this ridiculously long function?  All you need is that ^^^^

;~ get parent directory
 /*GetParentDir(path){
     StringSplit, PathArray, path, \,
     Loop, %PathArray0%
         {
         index = %A_Index%
         count := ----index
         }
     parentdir = %PathArray1%
     Loop, %count%
         {
         index = %A_Index%
         index := ++index
         path := PathArray%index%
         parentdir = %parentdir%\%path%
         }
     Return, parentdir
 }
*/
; create absolute path from relative path if needed
; form:
;   ce\path
;   \ce\path
;   .\ce\path
;   ..\ce\path
; or use a preferred label:                                *label*\ce\chemin
; or use a preferred number series:                        *145641324*\ce\chemin
; or use a path starting with an environment variable:    %userprofile%\My Documents
; don't accept paths in the form:                        F:\ce\..\..\chemin

GetAbsMovPath(relpath){
    StringSplit, PathArray, relpath,,",
    IfEqual, PathArray1, *
       {
       StringSplit, DriveLabel, relpath , \, *
       DriveGet, drvlist, list ; all removable drives
       Loop, Parse, drvlist
          {
          drv = %A_LoopField%:
          DriveGet, drvlb, Label, %drv%
          If drvlb = %DriveLabel1%
             {
             drvlt = %A_LoopField%:
             break
             }
          DriveGet, drvlb, Serial, %drv%
          If drvlb = %DriveLabel1%
             {
             drvlt = %A_LoopField%:
             break
             }
          }
       DriveLabel1 = *%DriveLabel1%*
       abspath:=StrReplace(relpath, DriveLabel1, drvlt)
       Return, abspath
       }
    IfEqual, PathArray1, ?
       {
       StringSplit, PathArray, relpath , \, ?
       new := %PathArray1%
       hold = ?%PathArray1%?
       abspath:=StrReplace(relpath, hold, new)
       Return, abspath
       }
    IfEqual, PathArray1, `%
        {
        StringSplit, VarLabel, relpath, \, `%
        Variable = %VarLabel1%
        VarLabel1 = `%%VarLabel1%`%
        EnvGet, Variable, %Variable%
        abspath := StrReplace(relpath, VarLabel1, Variable)
        Return, abspath
        }
    StringSplit, PathArray, relpath , \
    IfEqual,PathArray1,..
       {
       abspath = %A_ScriptDir%
       Loop, parse, relpath, \,
          {
          IfEqual,A_LoopField,..
             {
             abspath:=GetParentDir(abspath)
             }

          Else
             {
             newpath = %newpath%\%A_LoopField%
             }
          }
       abspath=%abspath%%newpath%
       Return, abspath
       }
    StringSplit, PathArray, relpath
    IfEqual,PathArray2,:
       {
       abspath=%relpath%
       Return, abspath
       }
    IfEqual,PathArray1,\
       {
       abspath=%A_ScriptDir%%relpath%
       Return, abspath
       }
    IfEqual,PathArray1,.
       {
       StringReplace, relpath, relpath, .\,,
       abspath=%A_ScriptDir%\%relpath%
       Return, abspath
       }
    Else
       {
       abspath=%A_ScriptDir%\%relpath%
       Return, abspath
       }
}

; get values of all keys in a section of the ini
GetIniSecListKey(inifile,header){
    Loop
        {
        FileReadLine, line, %inifile%, %A_Index%
        If ErrorLevel
            break
        IfEqual,line,[%header%]
            {
            count := A_Index
            break
            }
        }
        Loop
        {
        count := count +1
        FileReadLine, value,%inifile%, %count%
        StringSplit, CharArray, value,,%A_Space%
        if CharArray1 = [
            {
            Loop, %CharArray0%
                {
                last_char := charArray%a_index%
                cntrl=%charArray1%%last_char%
                if cntrl = [`;
                    {
                    break
                    }

                if cntrl = []
                    {
                    break
                    }
                }
            }
        if cntrl = []
            {
            break
            }
        if charArray1 = `;
            {
            Continue
            }
        if ErrorLevel
            {
            break
            }
        if value =
            {
            break
            }
        else
            {
            If list=
                {
                TestString = %value%
                StringSplit, word_array, TestString, =, .  ; Omits periods.
                list=%word_array1%
                }
            Else
                {
                TestString = %value%
                StringSplit, word_array, TestString, =, .  ; Omits periods.
                list=%list%|%word_array1%
                }
            }
        }
    Return, list
}

; get values of all keys in a section of the ini, not allowing redundancies
GetIniSecListNoDups(inifile,header,exclude){
    Loop
        {
        FileReadLine, line, %inifile%, %A_Index%
        If ErrorLevel
            break
        IfEqual,line,[%header%]
            {
            count := A_Index
            break
            }
        }
    Loop
        {
        count := ++count
        FileReadLine, value,%inifile%, %count%
        StringSplit, CharArray, value,,
        if CharArray1 = [
            {
            Loop, %CharArray0%
                {
                last_char := charArray%a_index%
                cntrl=%charArray1%%last_char%
                if cntrl = []
                    {
                    break
                    }
                }
            }
            if cntrl = []
                {
                break
                }
        if ErrorLevel
            {
            break
            }
        if value =
            {
            break
            }
        else
            {
            If list=
                {
                TestString = %value%
                StringSplit, word_array, TestString, =,  ; Omits periods.
                if word_array2 = %exclude%
                    {
                    Continue
                    }
                list=%word_array2%
                }
            Else
                {
                TestString = %value%
                StringSplit, word_array, TestString, =,  ; Omits periods.
                if word_array2 = %exclude%
                    {
                    Continue
                    }
                Loop, Parse, list, |
                    {
                    IfEqual, A_LoopField, %word_array2%
                        {
                        cntrl2 = 0
                        break
                        }
                    cntrl2 = 1
                    }
                IfEqual,cntrl2,1
                    {
                    list=%list%|%word_array2%
                    }
                }
            }
        }
    Return, list
}