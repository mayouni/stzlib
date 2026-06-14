#-------------------------------------------------------------------------------#
# 		   SOFTANZA LIBRARY (V0.9) - stzListOfBytes			#
#		 An accelerative library for Ring applications	      		#
#-------------------------------------------------------------------------------#
#										#
# 	Description	: The class for managing lists of bytes		        #
#	Version		: V0.9 (2020-2024)					#
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		   	#
#										#
#-------------------------------------------------------------------------------#

# Backed by the Softanza Zig Engine (stz_bytes.dll).
# Internally stores data as a Ring string (byte array).


func StzListOfBytesQ(p)
	return new stzListOfBytes(p)

func IsListOfBytes(p)
	if isString(p) or @IsStzString(p) or @IsStzListOfBytes(p)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsListOfBytes(p)
		return IsListOfBytes(p)

	#--

	func IsAListOfBytes(p)
		return IsListOfBytes(p)

	func @IsAListOfBytes(p)
		return IsListOfBytes(p)

	#>

func NumberInPointer(ptr)
	if IsPointer(ptr)
		BinStr = pointer2string(ptr, 0, len(int2bytes(0)) )
		return bytes2int(BinStr)
	else
		StzRaise("Value you provided is not of type Pointer!")
	ok

class stzBytes from stzListOfBytes

class stzListOfBytes from stzList

	@cData = ""

	def init(pValue)

		if isString(pValue)
			@cData = pValue

		but @IsStzListOfBytes(pValue)
			@cData = pValue.ToString()

		else
			StzRaise("Can't create the stzListOfBytes object!")
		ok

	def Content()

		_aResult_ = []
		_nLen_ = This.NumberOfBytes()

		for @i = 1 to _nLen_
			_aResult_ + This.Section(@i, @i)
		next

		return _aResult_

		def Value()
			return Content()

	def Copy()
		return new stzListOfBytes(This.ToString())

	def ListOfBytes()
		return This.Content()

	def Bytes()
		return This.ListOfBytes()

	def ToString()
		return @cData

	def ToStzString()
		return new stzString(This.ToString())

	def InsertNBytesOfSubstringAt(nPosition, nBytes, pcSubstr)
		cLeft = StzLeft(@cData, nPosition - 1)
		cInsert = StzLeft(pcSubstr, nBytes)
		cRight = StzMid(@cData, nPosition, StzLen(@cData) - nPosition + 1)
		@cData = cLeft + cInsert + cRight

	def NLeftBytes(n)
		return StzLeft(@cData, n)

		def LeftNBytes(n)
			return NLeftBytes(n)

	def 3LeftBytes()
		return This.NLeftBytes(3)

		def Left3Bytes()
			return This.3LeftBytes()

	def NRightBytes(n)
		return StzRight(@cData, n)

		def RightNBytes(n)
			return NRightBytes(n)

	def 3RightBytes()
		return This.NRightBytes(3)

		def Right3Bytes()
			return This.3RightBytes()

	def Clear()
		@cData = ""

		def ClearQ()
			This.Clear()
			return This

	def IsEmpty()
		return StzLen(@cData) = 0

	def RemoveNBytesStartingAt(nPosition, nBytes)
		if nPosition < 1 or nPosition > StzLen(@cData) return ok
		nEnd = nPosition + nBytes - 1
		if nEnd > StzLen(@cData) nEnd = StzLen(@cData) ok
		@cData = StzLeft(@cData, nPosition - 1) + StzMid(@cData, nEnd + 1, StzLen(@cData) - nEnd)

	def RemoveNBytesStartingAtQ(nPosition, nBytes)
		This.RemoveNBytesStartingAt(nPosition, nBytes)
		return This

	def RemoveNBytesFromEnd(n)
		if n >= StzLen(@cData)
			@cData = ""
		else
			@cData = StzLeft(@cData, StzLen(@cData) - n)
		ok

	def RemoveNBytesFromEndQ(n)
		This.RemoveNBytesFromEnd(n)
		return This

	def Range(nStart, nBytes)
		return StzMid(@cData, nStart, nBytes)

	def Section(n1, n2)
		return This.Range( n1, n2 - n1 + 1 )

	def ReplaceNBytes(nBytesFromMainStr, nStartingAtPosition, nWithNBytes, pcFromSubstr)
		cLeft = StzLeft(@cData, nStartingAtPosition - 1)
		cMid = StzLeft(pcFromSubstr, nWithNBytes)
		cRight = StzMid(@cData, nStartingAtPosition + nBytesFromMainStr, StzLen(@cData) - (nStartingAtPosition + nBytesFromMainStr) + 1)
		@cData = cLeft + cMid + cRight

	def ReplaceNBytesQ(nBytesFromMainStr, nStartingAtPosition, nWithNBytes, pcFromSubstr)
		This.ReplaceNBytes(nBytesFromMainStr, nStartingAtPosition, nWithNBytes, pcFromSubstr)
		return This

	def UnicodeOfNthByte(n)
		if n < 1 or n > StzLen(@cData) return -1 ok
		return ascii(@cData[n])

		def UnicodeOfByteNumber(n)
			return This.UnicodeOfNthByte(n)

		def UnicodeOfByteN(n)
			return This.UnicodeOfNthByte(n)

		#--

		def BytecodeOfNthByte(n)
			return This.UnicodeOfNthByte(n)

		def BytecodeOfByteNumber(n)
			return This.UnicodeOfNthByte(n)

		def BytecodeOfByteN(n)
			return This.UnicodeOfNthByte(n)

	def Bytecodes()
		aResult = []

		for i = 1 to len(@cData)
			aResult + ascii(@cData[i])
		next

		return aResult

		def BytecodesQ()
			return new stzList( This.Bytecodes() )

		def Unicodes()
			return This.Bytecodes()

			def UnicodesQ()
				return This.BytecodesQ()

	def Chars()
		return This.ToStzString().Chars()

		def CharsQ()
			return new stzList( This.Chars() )

	def BytecodesPerChar()
		aChars = This.Chars()
		nLen = len(aChars)

		aResult = []

		for i = 1 to nLen
			aResult + [ aChars[i], StzListOfBytesQ(aChars[i]).Bytecodes()]
		next

		return aResult

		def UnicodesPerChar()
			return This.BytecodesPerChar()

	def BytesPerChar()
		aChars = This.Chars()
		nLen = len(aChars)

		aResult = []

		for i = 1 to nLen
			aResult + [ aChars[i], StzListOfBytesQ(aChars[i]).Bytes()]
		next

		return aResult

	def BytesOfChar(pcChar)
		if CheckingParams()
			if NOT ( isString(pcChar) and @IsChar(pcChar) )
				StzRaise("Incorrect param type! pcChar must be a char.")
			ok
		ok

		aChars = This.Chars()
		nLen = len(aChars)

		aResult = []

		if StzFind(aChars, pcChar) > 0
			aResult = StzListOfBytesQ(pcChar).Bytes()
		ok

		return aResult

		def BytesOfThisChar(pcChar)

	def NumberOfBytesInCharNumber(n)
		nResult = len( This.BytesOfCharNumber(n) )
		return nResult

		def NumberOfBytesInCharN(n)
			return This.NumberOfBytesInCharNumber(n)

	def BytesOfCharNumber(n)

		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		aChars = This.Chars()
		nLen = len(aChars)

		aResult = StzListOfBytesQ(aChars[n]).Bytes()
		return aResult

		def BytesOfNthChar(n)
			return This.BytesOfCharNumber(n)

		def BytesOfCharN(n)
			return This.BytesOfCharNumber(n)

	def NumberOfBytes()
		return len(@cData)

		def Size()
			return This.NumberOfBytes()

		def SizeInBytes()
			return This.NumberOfBytes()

	def NumberOfBytesPerChar()

		aResult = []
		for i = 1 to This.ToStzString().NumberOfChars()
			oStzChar = new stzChar(This.ToStzString()[i])
			aResult + [ This.ToStzString()[i], oStzChar.NumberOfBytes() ]
		next

		return aResult

	def NumberOfBytesInNthChar(n)

		return This.NumberOfBytesPerChar()[n][2]

	def NumberOfBytesInChar(pcCaract)
		return This.NumberOfBytesPerChar()[pcCaract]

	def FillWithAsciiChar(pcChar)
		oCaract = new stzChar(pcChar)
		if oCaract.IsAscii()
			nCode = oCaract.AsciiCode()
			cChar = StzChar(nCode)
			@cData = @copy(cChar, This.NumberOfBytes())
			return @cData
		else
			return StzRaise(stzListOfBytesError(:CanNotFillBytesWithNonAsciiChar))
		ok

	def FillWithAsciiCharUpToNBytes(pcChar, nBytes)
		@cData = @copy(StzChar(ascii(pcChar)), nBytes)

	def FillWithAsciiCharUpToNChars(pcChar, nChars)
		nBytes = nChars * This.NumberOfBytesPerChar()
		@cData = @copy(StzChar(ascii(pcChar)), nBytes)

	def Resize(n)
		if n < StzLen(@cData)
			@cData = StzLeft(@cData, n)
		but n > StzLen(@cData)
			@cData = @cData + @copy(StzChar(0), n - StzLen(@cData))
		ok

	def Reserve(n)
		# No-op in pure Ring -- no pre-allocation concept

	def ReleaseUnusedMemory()
		# No-op in pure Ring

		def Squeeze()
			This.ReleaseUnusedMemory()

	def SetWithtNumberInBase(nNumber, nBase)
		cResult = ""
		nVal = nNumber
		cDigits = "0123456789abcdefghijklmnopqrstuvwxyz"
		if nVal = 0
			@cData = "0"
			return
		ok
		bNeg = (nVal < 0)
		if bNeg nVal = -nVal ok
		while nVal > 0
			nRem = nVal % nBase
			cResult = cDigits[nRem + 1] + cResult
			nVal = floor(nVal / nBase)
		end
		if bNeg cResult = "-" + cResult ok
		@cData = cResult

	def SwapWith(oOtherListOfBytes)
		if IsListOfBytes(oOtherListOfBytes)
			cTemp = @cData
			@cData = oOtherListOfBytes.ToString()
			oOtherListOfBytes.Update(cTemp)
		else
			StzRaise(stzListOfBytesError(:CanNotSwapWithNonListOfBytes))
		ok

	def ToBase64()
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = NULL return "" ok
		cResult = StzEngineBytesToBase64(pHandle)
		StzEngineBytesFree(pHandle)
		return cResult

	def FromBase64(pcBase64String)
		pHandle = StzEngineBytesNew()
		if pHandle = NULL return ok
		StzEngineBytesFromBase64(pHandle, pcBase64String)
		nSize = StzEngineBytesSize(pHandle)
		if nSize > 0
			@cData = StzEngineBytesLeft(pHandle, nSize)
		else
			@cData = ""
		ok
		StzEngineBytesFree(pHandle)

	def ToPercentEncoding(pcExcludedFromEncoding, pcIncludedInEncoding, pcPercentAsciiChar)
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = NULL return @cData ok
		cResult = StzEngineBytesToPercent(pHandle)
		StzEngineBytesFree(pHandle)
		return cResult

	def FromPercentEncoding(pcPercentEncodedString, pcPercentAsciiChar)
		pHandle = StzEngineBytesNew()
		if pHandle = NULL return 0 ok
		StzEngineBytesFromPercent(pHandle, pcPercentEncodedString)
		nSize = StzEngineBytesSize(pHandle)
		if nSize > 0
			@cData = StzEngineBytesLeft(pHandle, nSize)
		else
			@cData = ""
		ok
		StzEngineBytesFree(pHandle)
		return 1

	def ToHex()
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = NULL return HexPrefix() ok
		cResult = HexPrefix() + StzEngineBytesToHex(pHandle)
		StzEngineBytesFree(pHandle)
		return cResult

		def ToHexQ()
			return new stzString(This.ToHex())

	def ToHexWithoutPrefix()
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = NULL return "" ok
		cResult = StzEngineBytesToHex(pHandle)
		StzEngineBytesFree(pHandle)
		return cResult

		def ToHexWithoutPrefixQ()
			return new stzString( This.ToHexWithoutPrefix() )

	def FromHex(pcHexString)
		pHandle = StzEngineBytesNew()
		if pHandle = NULL return ok
		StzEngineBytesFromHex(pHandle, pcHexString)
		nSize = StzEngineBytesSize(pHandle)
		if nSize > 0
			@cData = StzEngineBytesLeft(pHandle, nSize)
		else
			@cData = ""
		ok
		StzEngineBytesFree(pHandle)

	def ToUTF8()
		cResult = This.ToStzString().ToUTF8()
		return cResult

	def Hexcodes()
		aBytes = This.Bytes()
		nLen = len(aBytes)

		acResult = []

		for i = 1 to nLen
			cHex = StzListOfBytesQ(aBytes[i]).ToHex()
			acResult + cHex
		next

		return acResult

	def HexPerByte()
		aBytes = This.Bytes()
		nLen = len(aBytes)

		aResult = []

		for i = 1 to nLen
			cHex = StzListOfBytesQ(aBytes[i]).ToHex()
			aResult + [ aBytes[i], cHex ]
		next

		return aResult

	def HexcodesWithoutPrefix()
		aBytes = This.Bytes()
		nLen = len(aBytes)

		acResult = []

		for i = 1 to nLen
			cHex = StzListOfBytesQ(aBytes[i]).ToHexWithoutPrefix()
			acResult + cHex
		next

		return acResult

	def HexPerByteWithoutPrefix()
		aBytes = This.Bytes()
		nLen = len(aBytes)

		aResult = []

		for i = 1 to nLen
			cHex = StzListOfBytesQ(aBytes[i]).ToHexWithoutPrefix()
			aResult + [ aBytes[i], cHex ]
		next

		return aResult

	def ToHexSeparated(pcSep)
		if CheckingParams()
			if isList(pcSep) and Q(pcSep).IsByOrUsingOrWithNamedParam()
				pcSep = pcSep[2]
			ok

			if NOT isString(pcSep)
				StzRaise("Incorrect param type! pcSep must be a string.")
			ok
		ok

		aHex = This.Hexcodes()
		nLen = len(aHex)

		cResult = ""

		for i = 1 to nLen
			cResult += aHex[i]
			if i < nLen
				cResult += pcSep
			ok
		next

		return cResult

		#< @FunctionAlternativeForm

		def ToHexSeparatedBy(pcSep)
			if CheckingParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexSeparated(pcSep)

		def ToHexSeparatedWith(pcSep)
			if CheckingParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexSeparated(pcSep)

		def ToHexSeparatedUsing(pcSep)
			if CheckingParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexSeparated(pcSep)

		#>

		#< @FunctionMisspelledForms

		def ToHexSeperated(pcSep)
			return This.ToHexSeparated(pcSep)

		def ToHexSeperatedBy(pcSep)
			return This.ToHexSeparatedBy(pcSep)

		def ToHexSeperatedWith(pcSep)
			return This.ToHexSeparatedWith(pcSep)

		def ToHexSeperatedUsing(pcSep)
			return This.ToHexSeparatedUsing(pcSep)

		#>


	def ToHexSpacified()
		return This.ToHexSeparatedBy(" ")

	#--

	def ToHexWithoutPrefixSeparated(pcSep)
		if CheckingParams()
			if isList(pcSep) and Q(pcSep).IsByOrUsingOrWithNamedParam()
				pcSep = pcSep[2]
			ok

			if NOT isString(pcSep)
				StzRaise("Incorrect param type! pcSep must be a string.")
			ok
		ok

		aHex = This.HexcodesWithoutPrefix()
		nLen = len(aHex)

		cResult = ""

		for i = 1 to nLen
			cResult += aHex[i]
			if i < nLen
				cResult += pcSep
			ok
		next

		return cResult

		#< @FunctionAlternativeForm

		def ToHexWithoutPrefixSeparatedBy(pcSep)
			if CheckingParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexWithoutPrefixSeparated(pcSep)

		def ToHexWithoutPrefixSeparatedWith(pcSep)
			if CheckingParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexWithoutPrefixSeparated(pcSep)

		def ToHexWithoutPrefixSeparatedUsing(pcSep)
			if CheckingParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexWithoutPrefixSeparated(pcSep)

		#>

		#< @FunctionMisspelledForms

		def ToHexWithoutPrefixSeperatedBy(pcSep)
			return This.ToHexWithoutPrefixSeparatedBy(pcSep)

		def ToHexWithoutPrefixSeperatedWith(pcSep)
			return This.ToHexWithoutPrefixSeparatedWith(pcSep)

		def ToHexWithoutPrefixSeperatedUsing(pcSep)
			return This.ToHexWithoutPrefixSeparatedUsing(pcSep)

		#>


	def ToHexWithoutPrefixSpacified()
		return This.ToHexWithoutPrefixSeparatedBy(" ")

	def ToHexUTF8()
		cResult = "\x" + This.ToHexWithoutPrefixSeparatedBy(" \x")
		return cResult

	#--

	def Update(pcStr)
		if CheckingParams() = 1
			if isList(pcStr) and Q(pcStr).IsWithOrByOrUsingNamedParam()
				pcStr = pcStr[2]
			ok
		ok

		@cData = pcStr

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())
		ok

		#< @FunctionAlternativeForms

		def UpdateWith(pcStr)
			This.Update(pcStr)

			def UpdateWithQ(pcStr)
				return This.UpdateQ(pcStr)

		def UpdateBy(pcStr)
			This.Update(pcStr)

			def UpdateByQ(pcStr)
				return This.UpdateQ(pcStr)

		def UpdateUsing(pcStr)
			This.Update(pcStr)

			def UpdateUsingQ(pcStr)
				return This.UpdateQ(pcStr)

		#>

	def Updated(pcStr)
		return pcStr

		#< @FunctionAlternativeForms

		def UpdatedWith(pcStr)
			return This.Updated(pcStr)

		def UpdatedBy(pcStr)
			return This.Updated(pcStr)

		def UpdatedUsing(pcStr)
			return This.Updated(pcStr)

		#>

	#---

	def Bits()
		// TODO: after making stzListOfBits

	def ToStzListOfBits()
		// TODO

	def Lowercase()
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = NULL return @cData ok
		cResult = StzEngineBytesToLower(pHandle)
		StzEngineBytesFree(pHandle)
		return cResult

		def ToLowercase()
			return This.Lowercase()

	def ApplyLowercase()
		@cData = This.Lowercase()

		def ApplyLowercaseQ()
			This.ApplyLowercase()
			return This

	def Uppercased()
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = NULL return @cData ok
		cResult = StzEngineBytesToUpper(pHandle)
		StzEngineBytesFree(pHandle)
		return cResult

		def ToUppercase()
			return This.Uppercased()

	def Uppercase()
		@cData = This.Uppercased()

		def UppercaseQ()
			This.Uppercase()
			return This

		def ApplyUppercase()
			This.Uppercase()

			def ApplyUppercaseQ()
				This.ApplyUppercase()
				return This

	def Trimmed()
		return @trim(@cData)

		def Stripped()

	def Trim()
		@cData = @trim(@cData)

		def TrimQ()
			This.Trim()
			return This

		def Strip()
			This.Trim()

			def StripQ()
				return This.TrimQ()

	def TruncatedAt(n)
		return StzLeft(@cData, n)

	def TruncateAt(n)
		@cData = StzLeft(@cData, n)

		def TruncateAtQ(n)
			This.TruncateAt(n)
			return this
