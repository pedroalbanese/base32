; ====================================================================================================
;Base32 encoding decoding adapted from:
;http://www.docjar.com/src/api/xnap/plugin/gnutella/util/Base32.java
;ported to AutoIt by Stephen Podhajecki {gehossafats at netmdc dot com}
;this port falls under GPL
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;;
; ====================================================================================================
Const $BASE32CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567" ;
Local $_BASE32_DECODE_TABLE[128]
Local $BASE32_INIT = 0
; #FUNCTION# =========================================================================================
; Description ...: Encode a string as base32
; Parameters ....: $vData - IN - Data to decode.
; Return values .: On Success - Encoded data
;                 On Failure - @error set to 1, 0 returned
; Author ........: Ported by Stephen Podhajecki {gehossafats at netmdc. com}
; Remarks .......: Works with text strings and files.
; Related .......: _Base32_Decode
; ====================================================================================================
Func _Base32_Encode($vData)
	If $BASE32_INIT = 0 Then
		If Not _Base32_BuildTable() Then Return SetError(1, 0, 0)
	EndIf
	Local $data = __Split_Key($vData)
	Local $dataLength = UBound($data)
	If Not $dataLength > 0 Then Return SetError(1, 0, 0)
	Local $chars[$dataLength * 8 / 5 + (1 * (Mod($dataLength, 5) > 0))]
	Local $charsLength = UBound($chars)
	Local $i = 0, $j = 0, $index = 0, $b = 0
	Local $ALPHABET = __Split_Key($BASE32CHARS)
	For $i = 0 To $charsLength - 1
		If $index > 3 Then
			$b = BitAND(Asc($data[$j]), BitShift(0xFF, $index))
			$index = Mod($index + 5, 8)
			$b = BitShift($b, -$index)
			If $j < $dataLength - 1 Then
				$b = BitOR($b, BitShift(BitAND(Asc($data[$j + 1]), 0xFF), (8 - $index)))
			EndIf
			$chars[$i] = $ALPHABET[$b]
			$j += 1
		Else
			$chars[$i] = $ALPHABET[BitAND(BitShift(Asc($data[$j]), (8 - ($index + 5))), 0x1F)]
			$index = Mod($index + 5, 8)
			If $index = 0 Then
				$j += 1
			EndIf
		EndIf
	Next
	Local $sEncoded = ""
	For $x = 0 To UBound($chars) - 1
		$sEncoded &= $chars[$x]
	Next
	Return $sEncoded
EndFunc   ;==>_Base32_Encode

; #FUNCTION# ====================================================================================================
; Description ...: Decode a base32 encoded string
; Parameters ....: $vData - IN - Data to decode.
; Return values .: On Success - Decoded data
;                 On Failure - @error set to 1, 0 returned
; Author ........: Ported by Stephen Podhajecki {gehossafats at netmdc. com}
; Remarks .......: Works with text strings and files.
; Related .......: _Base32_Encode
; ====================================================================================================
Func _Base32_Decode($vData)
	If $BASE32_INIT = 0 Then
		If Not _Base32_BuildTable() Then Return SetError(1, 0, 0)
	EndIf
	Local $stringData = __Split_Key($vData)
	Local $stringDataLength = UBound($stringData)
	If Not $stringDataLength > 0 Then Return SetError(1, 0, 0)
	Local $data[(($stringDataLength * 5) / 8)]
	Local $dataLength = UBound($data)
	Local $i, $j = 0, $index = 0, $val = 0, $decoded = ""
	For $i = 0 To $stringDataLength - 1
		$val = 0
		$val = $_BASE32_DECODE_TABLE[Asc($stringData[$i])]
		If $val = 0xFF Then
			;;rem illegal character
			Return SetError(1, 0, 0)
		EndIf
		If ($index <= 3) Then
			$index = Mod($index + 5, 8)
			If $index = 0 Then
				$data[$j] = BitOR($data[$j], $val)
				$j += 1
			Else
				$data[$j] = BitOR($data[$j], BitShift($val, -(8 - $index)))
			EndIf
		Else
			$index = Mod($index + 5, 8)
			$data[$j] = BitOR($data[$j], BitShift($val, $index))
			$j += 1
			If $j < $dataLength Then
				$data[$j] = BitOR($data[$j], BitShift($val, -(8 - $index)))
				$data[$j] = BitAND($data[$j], 0xFF)
			EndIf
		EndIf
	Next
	For $x = 0 To UBound($data) - 1
		$decoded &= Chr($data[$x])
	Next
	Return $decoded
EndFunc   ;==>_Base32_Decode
; ====================================================================================================
; _Base32_BuildTable(): Builds a conversion table
; ====================================================================================================
Func _Base32_BuildTable()
	For $i = 0 To UBound($_BASE32_DECODE_TABLE) - 1
		$_BASE32_DECODE_TABLE[$i] = 0xFF
	Next
	For $i = 0 To StringLen($BASE32CHARS) - 1
		$_BASE32_DECODE_TABLE[Asc(StringMid($BASE32CHARS, $i + 1, 1))] = $i
		If $i < 24 Then
			$_BASE32_DECODE_TABLE[Asc(StringLower(StringMid($BASE32CHARS, $i + 1, 1)))] = $i
		EndIf
	Next
	$BASE32_INIT = 1
	Return 1
EndFunc   ;==>_Base32_BuildTable

; ====================================================================================================
; __Split_Key:  Internal function
; splits a string into an array of characters and strip the count value from the first element.
; ====================================================================================================
Func __Split_Key($szKey, $szDelim = "")
	If $szKey = "" Then Return SetError(1, 0, 0)
	If IsArray($szKey) Then Return $szKey
	Local $iCount, $szTemp = ""
	Local $aTemp = StringSplit($szKey, $szDelim)
	If Not @error Then
		Local $iCount = $aTemp[0], $iTotal = 0
		For $x = 1 To $iCount
			$iTotal += 1
			$aTemp[$x - 1] = $aTemp[$x]
		Next
		ReDim $aTemp[$iTotal]
		Return $aTemp
	EndIf
	Return SetError(1, 0, 0)
EndFunc   ;==>__Split_Key
