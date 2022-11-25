; ====================================================
; =========== Base32 String Converter CLI ============
; ====================================================
; AutoIt version: 3.3.12.0
; Language:       English
; Author:         Pedro F. Albanese
; Modified:       -
;
; ----------------------------------------------------------------------------
; Script Start
; ----------------------------------------------------------------------------
#NoTrayIcon
#include <base32.au3>


If $CmdLineRaw == "" Or $CmdLine[0] == 1 Then
	ConsoleWrite("Base32 Encoder 1.0 - ALBANESE Research Lab " & Chr(184) & " 2016" & @CRLF) ;
	ConsoleWrite("Usage: " & @ScriptName & " [-e|d] <string or file.ext>" & @CRLF) ;
Else
	If $CmdLine[2] == '-' Then
		Local $sOutput
		While True
			$sOutput &= ConsoleRead()
			If @error Then ExitLoop
			Sleep(25)
		WEnd
		$full = StringReplace($sOutput, @LF, '')
		$full = StringReplace($full, @CRLF, '')
		If $CmdLine[1] == "-e" Then
			ConsoleWrite(_Base32_Encode($full))
		ElseIf $CmdLine[1] == "-d" Then
			ConsoleWrite(_Base32_Decode($full))
		EndIf
	ElseIf $CmdLine[2] <> '' Then
		if FileExists($CmdLine[2]) Then
			$full = FileRead($CmdLine[2])
		Else
			$full = $CmdLine[2]
		EndIf
		$full = StringReplace($full, @LF, '')
		$full = StringReplace($full, @CRLF, '')
		If $CmdLine[1] == "-e" Then
			ConsoleWrite(_Base32_Encode($full))
		ElseIf $CmdLine[1] == "-d" Then
			ConsoleWrite(_Base32_Decode($full))
		EndIf
	EndIf
EndIf
Exit
