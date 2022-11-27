#NoEnv
SetBatchLines, -1
Dummy := "
(Join
Base32 is a notation for encoding arbitrary byte data using a restricted set of symbols which can be conveniently used by humans
 and processed by old computer systems which only recognize restricted character sets.`r`n
Base32 comprises a symbol set made up of 32 different characters, as well as an algorithm for encoding arbitrary strings using
 8-bit characters into the Base32 alphabet. This uses more than one 5-bit Base32 symbol for each 8-bit input character, and thus
 also specifies requirements on the allowed lengths of Base32 strings (which must be multiples of 40 bits). The Base64 system,
 in contrast, uses a set of 64 symbols, but is closely related.
)"
Gui, Margin, 20, 10
Gui, Font, s10, Courier New
Gui, Add, Edit, w600 r10 vInput, %Dummy%
Gui, Font
Gui, Add, Button, gEncode, Encode
Gui, Add, Button, x+m yp gDecode, Decode
Gui, Add, CheckBox, x+m yp hp vUseHex, Use BASE32HEX
Gui, Font, s10, Courier New
Gui, Add, Edit, xm w600 r10 vResult +ReadOnly
Gui, Show, , BASE32
Return

GuiClose:
ExitApp

Encode:
Gui, Submit, NoHide
GuiControl, , Result, % Base32_Encode(Input, UseHex)
Return

Decode:
Gui, Submit, NoHide
GuiControl, , Result, % Base32_Decode(Input, UseHex)
Return
; ==================================================================================================================================
; Parameter:
;     Decoded  -  Buffer to encode. If Encoded contains a string, omit the parameter Len or pass zero.
;                 The string will be converted to UTF-8 before it will be encoded.
;     UseHex   -  If True, the base32hex conversion table will be used; otherwise encoding will use the common Base32 table.
;     Len      -  If Encoded contains binary content, Len must specify the length in bytes; otherwise Len must be zero.
; Return value:
;     The encoded result as a string.
; ==================================================================================================================================
Base32_Encode(ByRef Decoded, UseHex := False, Len := 0) {
   Static CharsA := "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
   Static CharsH := "0123456789ABCDEFGHIJKLMNOPQRSTUV"
   Chars := UseHex ? CharsH : CharsA
   If (Len = 0) {
      Len := StrPut(Decoded, "UTF-8") - 1
      VarSetCapacity(UTF8, Len, 0)
      StrPut(Decoded, &UTF8, "UTF-8")
      BinAddr := &UTF8
   }
   Else
      BinAddr := &Decoded
   VarSetCapacity(Endcoded, Len * 2, 0)
   I := 0
   While (I < Len) {
      J := N := 0
      S := 40
      Loop, 5
         N += NumGet(BinAddr + I++, "UChar") << (8 * (5 - ++J))
      Until (I >= Len)
      Loop, % Ceil((8 * J) / 5)
         Encoded .= SubStr(Chars, ((N >> (S -= 5)) & 0x1F) + 1, 1)
   }
   Loop, % ((40 - (J * 8)) // 5)
;      Encoded .= "="
   Return Encoded
}
; ==================================================================================================================================
; Parameter:
;     Encoded  -  Buffer to encode, always a string. The length of the string should be a multiple of 8.
;     UseHex   -  If True, the base32hex conversion table will be used; otherwise decoding will use the common Base32 table.
;     Decoded  -  Variable to store the result if the encoded content is binary.
; Return values:
;     If a variabe was passed in Decoded, the function will return its length in bytes. Otherwise the function returns the
;     decoded result as a string.
; ==================================================================================================================================
Base32_Decode(ByRef Encoded, UseHex := False, ByRef Decoded := "") {
   Static CharsA := "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
   Static CharsH := "0123456789ABCDEFGHIJKLMNOPQRSTUV"
   Chars := UseHex ? CharsH : CharsA
   Len := StrLen(Encoded)
   VarSetCapacity(Decoded, Len * 2, 0)
   I := J := K := 0
   Loop, Parse, Encoded
   {
      If !(N := InStr(Chars, A_LoopField))
         Break
      K += --N << (5 * (8 - ++J))
      If (J = 8) {
         S := 40
         Loop, 5
            NumPut((K >> (S -= 8)) & 0xFF, Decoded, I++, "Uchar")
         J := K := 0
      }
   }
   If (J < 8) {
      S := 40
      Loop, % Ceil((5 * J) / 8)
         NumPut((K >> (S -= 8)) & 0xFF, Decoded, I++, "Uchar")
   }
   If IsByRef(Decoded)
      Return I
   Return StrGet(&Decoded, I, "UTF-8")
}
; ==================================================================================================================================
; 1.......2.......3.......4.......5.......   5 bytes     (40 bits)
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; 1....2..|.3....4|...5...|6....7.|..8....   8 * 5 bits  (40 bits)
; ==================================================================================================================================