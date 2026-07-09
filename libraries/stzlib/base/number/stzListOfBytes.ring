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
		_BinStr_ = pointer2string(ptr, 0, len(int2bytes(0)) )
		return bytes2int(_BinStr_)
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

	def InsertNBytesOfSubstringAt(nPosition, _nBytes_, pcSubstr)
		_cLeft_ = StzLeft(@cData, nPosition - 1)
		_cInsert_ = StzLeft(pcSubstr, _nBytes_)
		_cRight_ = StzMid(@cData, nPosition, StzLen(@cData) - nPosition + 1)
		@cData = _cLeft_ + _cInsert_ + _cRight_

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

	def RemoveNBytesStartingAt(nPosition, _nBytes_)
		if nPosition < 1 or nPosition > StzLen(@cData) return ok
		_nEnd_ = nPosition + _nBytes_ - 1
		if _nEnd_ > StzLen(@cData) _nEnd_ = StzLen(@cData) ok
		@cData = StzLeft(@cData, nPosition - 1) + StzMid(@cData, _nEnd_ + 1, StzLen(@cData) - _nEnd_)

	def RemoveNBytesStartingAtQ(nPosition, _nBytes_)
		This.RemoveNBytesStartingAt(nPosition, _nBytes_)
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

	def Range(nStart, _nBytes_)
		return StzMid(@cData, nStart, _nBytes_)

	def Section(n1, n2)
		return This.Range( n1, n2 - n1 + 1 )

	def ReplaceNBytes(nBytesFromMainStr, nStartingAtPosition, nWithNBytes, pcFromSubstr)
		_cLeft_ = StzLeft(@cData, nStartingAtPosition - 1)
		_cMid_ = StzLeft(pcFromSubstr, nWithNBytes)
		_cRight_ = StzMid(@cData, nStartingAtPosition + nBytesFromMainStr, StzLen(@cData) - (nStartingAtPosition + nBytesFromMainStr) + 1)
		@cData = _cLeft_ + _cMid_ + _cRight_

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
		_aResult_ = []

		for i = 1 to len(@cData)
			_aResult_ + ascii(@cData[i])
		next

		return _aResult_

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
		_aChars_ = This.Chars()
		_nLen_ = len(_aChars_)

		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + [ _aChars_[i], StzListOfBytesQ(_aChars_[i]).Bytecodes()]
		next

		return _aResult_

		def UnicodesPerChar()
			return This.BytecodesPerChar()

	def BytesPerChar()
		_aChars_ = This.Chars()
		_nLen_ = len(_aChars_)

		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + [ _aChars_[i], StzListOfBytesQ(_aChars_[i]).Bytes()]
		next

		return _aResult_

	def BytesOfChar(pcChar)
		if CheckingParams()
			if NOT ( isString(pcChar) and @IsChar(pcChar) )
				StzRaise("Incorrect param type! pcChar must be a char.")
			ok
		ok

		_aChars_ = This.Chars()
		_nLen_ = len(_aChars_)

		_aResult_ = []

		if StzFindFirst(_aChars_, pcChar) > 0
			_aResult_ = StzListOfBytesQ(pcChar).Bytes()
		ok

		return _aResult_

		def BytesOfThisChar(pcChar)

	def NumberOfBytesInCharNumber(n)
		_nResult_ = len( This.BytesOfCharNumber(n) )
		return _nResult_

		def NumberOfBytesInCharN(n)
			return This.NumberOfBytesInCharNumber(n)

	def BytesOfCharNumber(n)

		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_aChars_ = This.Chars()
		_nLen_ = len(_aChars_)

		_aResult_ = StzListOfBytesQ(_aChars_[n]).Bytes()
		return _aResult_

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

		_aResult_ = []
		for i = 1 to This.ToStzString().NumberOfChars()
			_oStzChar_ = new stzChar(This.ToStzString()[i])
			_aResult_ + [ This.ToStzString()[i], _oStzChar_.NumberOfBytes() ]
		next

		return _aResult_

	def NumberOfBytesInNthChar(n)

		return This.NumberOfBytesPerChar()[n][2]

	def NumberOfBytesInChar(pcCaract)
		return This.NumberOfBytesPerChar()[pcCaract]

	def FillWithAsciiChar(pcChar)
		_oCaract_ = new stzChar(pcChar)
		if _oCaract_.IsAscii()
			_nCode_ = _oCaract_.AsciiCode()
			_cChar_ = StzChar(_nCode_)
			@cData = @copy(_cChar_, This.NumberOfBytes())
			return @cData
		else
			return StzRaise(stzListOfBytesError(:CanNotFillBytesWithNonAsciiChar))
		ok

	def FillWithAsciiCharUpToNBytes(pcChar, _nBytes_)
		@cData = @copy(StzChar(ascii(pcChar)), _nBytes_)

	def FillWithAsciiCharUpToNChars(pcChar, nChars)
		_nBytes_ = nChars * This.NumberOfBytesPerChar()
		@cData = @copy(StzChar(ascii(pcChar)), _nBytes_)

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
		_cResult_ = ""
		_nVal_ = nNumber
		_cDigits_ = "0123456789abcdefghijklmnopqrstuvwxyz"
		if _nVal_ = 0
			@cData = "0"
			return
		ok
		_bNeg_ = (_nVal_ < 0)
		if _bNeg_ _nVal_ = -_nVal_ ok
		while _nVal_ > 0
			_nRem_ = _nVal_ % nBase
			_cResult_ = _cDigits_[_nRem_ + 1] + _cResult_
			_nVal_ = floor(_nVal_ / nBase)
		end
		if _bNeg_ _cResult_ = "-" + _cResult_ ok
		@cData = _cResult_

	def SwapWith(oOtherListOfBytes)
		if IsListOfBytes(oOtherListOfBytes)
			_cTemp_ = @cData
			@cData = oOtherListOfBytes.ToString()
			oOtherListOfBytes.Update(_cTemp_)
		else
			StzRaise(stzListOfBytesError(:CanNotSwapWithNonListOfBytes))
		ok

	def ToBase64()
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = NULL return "" ok
		_cResult_ = StzEngineBytesToBase64(pHandle)
		StzEngineBytesFree(pHandle)
		return _cResult_

	def FromBase64(pcBase64String)
		pHandle = StzEngineBytesNew()
		if pHandle = NULL return ok
		StzEngineBytesFromBase64(pHandle, pcBase64String)
		_nSize_ = StzEngineBytesSize(pHandle)
		if _nSize_ > 0
			@cData = StzEngineBytesLeft(pHandle, _nSize_)
		else
			@cData = ""
		ok
		StzEngineBytesFree(pHandle)

	def ToPercentEncoding(pcExcludedFromEncoding, pcIncludedInEncoding, pcPercentAsciiChar)
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = NULL return @cData ok
		_cResult_ = StzEngineBytesToPercent(pHandle)
		StzEngineBytesFree(pHandle)
		return _cResult_

	def FromPercentEncoding(pcPercentEncodedString, pcPercentAsciiChar)
		pHandle = StzEngineBytesNew()
		if pHandle = NULL return 0 ok
		StzEngineBytesFromPercent(pHandle, pcPercentEncodedString)
		_nSize_ = StzEngineBytesSize(pHandle)
		if _nSize_ > 0
			@cData = StzEngineBytesLeft(pHandle, _nSize_)
		else
			@cData = ""
		ok
		StzEngineBytesFree(pHandle)
		return 1

	def ToHex()
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = NULL return HexPrefix() ok
		_cResult_ = HexPrefix() + StzEngineBytesToHex(pHandle)
		StzEngineBytesFree(pHandle)
		return _cResult_

		def ToHexQ()
			return new stzString(This.ToHex())

	def ToHexWithoutPrefix()
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = NULL return "" ok
		_cResult_ = StzEngineBytesToHex(pHandle)
		StzEngineBytesFree(pHandle)
		return _cResult_

		def ToHexWithoutPrefixQ()
			return new stzString( This.ToHexWithoutPrefix() )

	def FromHex(pcHexString)
		pHandle = StzEngineBytesNew()
		if pHandle = NULL return ok
		StzEngineBytesFromHex(pHandle, pcHexString)
		_nSize_ = StzEngineBytesSize(pHandle)
		if _nSize_ > 0
			@cData = StzEngineBytesLeft(pHandle, _nSize_)
		else
			@cData = ""
		ok
		StzEngineBytesFree(pHandle)

	def ToUTF8()
		_cResult_ = This.ToStzString().ToUTF8()
		return _cResult_

	def Hexcodes()
		_aBytes_ = This.Bytes()
		_nLen_ = len(_aBytes_)

		_acResult_ = []

		for i = 1 to _nLen_
			_cHex_ = StzListOfBytesQ(_aBytes_[i]).ToHex()
			_acResult_ + _cHex_
		next

		return _acResult_

	def HexPerByte()
		_aBytes_ = This.Bytes()
		_nLen_ = len(_aBytes_)

		_aResult_ = []

		for i = 1 to _nLen_
			_cHex_ = StzListOfBytesQ(_aBytes_[i]).ToHex()
			_aResult_ + [ _aBytes_[i], _cHex_ ]
		next

		return _aResult_

	def HexcodesWithoutPrefix()
		_aBytes_ = This.Bytes()
		_nLen_ = len(_aBytes_)

		_acResult_ = []

		for i = 1 to _nLen_
			_cHex_ = StzListOfBytesQ(_aBytes_[i]).ToHexWithoutPrefix()
			_acResult_ + _cHex_
		next

		return _acResult_

	def HexPerByteWithoutPrefix()
		_aBytes_ = This.Bytes()
		_nLen_ = len(_aBytes_)

		_aResult_ = []

		for i = 1 to _nLen_
			_cHex_ = StzListOfBytesQ(_aBytes_[i]).ToHexWithoutPrefix()
			_aResult_ + [ _aBytes_[i], _cHex_ ]
		next

		return _aResult_

	def ToHexSeparated(pcSep)
		if CheckingParams()
			if isList(pcSep) and Q(pcSep).IsByOrUsingOrWithNamedParam()
				pcSep = pcSep[2]
			ok

			if NOT isString(pcSep)
				StzRaise("Incorrect param type! pcSep must be a string.")
			ok
		ok

		_aHex_ = This.Hexcodes()
		_nLen_ = len(_aHex_)

		_cResult_ = ""

		for i = 1 to _nLen_
			_cResult_ += _aHex_[i]
			if i < _nLen_
				_cResult_ += pcSep
			ok
		next

		return _cResult_

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

		_aHex_ = This.HexcodesWithoutPrefix()
		_nLen_ = len(_aHex_)

		_cResult_ = ""

		for i = 1 to _nLen_
			_cResult_ += _aHex_[i]
			if i < _nLen_
				_cResult_ += pcSep
			ok
		next

		return _cResult_

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
		_cResult_ = "\x" + This.ToHexWithoutPrefixSeparatedBy(" \x")
		return _cResult_

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
		_cResult_ = StzEngineBytesToLower(pHandle)
		StzEngineBytesFree(pHandle)
		return _cResult_

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
		_cResult_ = StzEngineBytesToUpper(pHandle)
		StzEngineBytesFree(pHandle)
		return _cResult_

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
