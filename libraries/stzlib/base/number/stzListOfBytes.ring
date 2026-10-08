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

# Holds a run of raw bytes in a Ring text, and reads, cuts and converts it byte by byte.
#
# Positions and sizes count bytes, never characters, so a character of several bytes is several
# items here (Chars and the per-character methods are the exception). The bytes can be read as
# numbers, as hexadecimal, as Base64 or with percent escapes, and written back from those forms.
# Methods that change the object say so with a verb such as Clear, Trim or Update; the others return
# a new text. The name stzBytes is the same class.
#
#   receiver   o1 = new stzListOfBytes("Hi!")
#   example    ? @@( o1.Bytecodes() )
#              #--> [ 72, 105, 33 ]
#              ? o1.ToHex()
#              #--> 0x486921
#              ? o1.ToBase64()
#              #--> SGkh
#              ? o1.LeftNBytes(2)
#              #--> Hi
#   see        stzString, stzList, StzListOfBytesQ
class stzListOfBytes from stzList

	@cData = ""

	# Builds a list of bytes from a text, or from another list of bytes, keeping the raw bytes of the text.
	#
	#   pValue     a text, whose bytes are kept as they are, or a stzListOfBytes, whose bytes are
	#              copied
	#   returns    nothing; the object is built
	#   warning    any other value, a number for instance, raises the error Can't create the
	#              stzListOfBytes object!
	#   see        ToString, Copy
	def init(pValue)

		if isString(pValue)
			@cData = pValue

		but @IsStzListOfBytes(pValue)
			@cData = pValue.ToString()

		else
			StzRaise("Can't create the stzListOfBytes object!")
		ok

	# Returns the bytes one by one, each as a one-byte text.
	#
	#   returns    a list of one-byte texts; a character of several bytes is cut into several items
	#   note       Value, ListOfBytes and Bytes are the same call
	#   see        Bytecodes, Chars, ToString
	def Content()

		_aResult_ = []
		_nLen_ = This.NumberOfBytes()

		for @i = 1 to _nLen_
			_aResult_ + This.Section(@i, @i)
		next

		return _aResult_

		# Returns the bytes one by one, each as a one-byte text.
		#
		#   returns    a list of one-byte texts
		#   see        Content, Bytecodes
		def Value()
			return Content()

	# Returns a new, independent list of bytes holding the same bytes.
	#
	#   returns    a stzListOfBytes; changing it leaves this one as it is
	#   see        ToString, Content
	def Copy()
		return new stzListOfBytes(This.ToString())

	def ListOfBytes()
		return This.Content()

	def Bytes()
		return This.ListOfBytes()

	# Returns all the bytes as one text.
	#
	#   returns    a text
	#   see        Content, ToStzString
	def ToString()
		return @cData

	# Returns the bytes as a stzString, to use the string methods on them.
	#
	#   returns    a stzString
	#   see        ToString, Chars
	def ToStzString()
		return new stzString(This.ToString())

	#--- BYTE PRIMITIVES -----------------------------------------------
	#
	# THIS CLASS SLICES BYTES. Every positional method below used to reach for
	# StzLeft / StzMid / StzRight / StzLen, which count CODEPOINTS -- correct
	# for stzString, wrong for a list of bytes. On ASCII the two agree, so the
	# confusion stayed invisible; on anything multibyte they diverge, and the
	# class contradicted itself depending on which method you called:
	# NumberOfBytes() and Bytecodes() were byte-based (len(), @cData[i]) while
	# NLeftBytes() was not. NLeftBytes(3) over "m" + 2-byte + 3-byte answered
	# all SIX bytes, because three codepoints is the whole string.
	#
	# Ring's NUMERIC substr(s, nStart, nCount) is the byte primitive. Its string
	# forms are different calls entirely (find, and replace) -- see CLAUDE.md;
	# the numeric form is the one meant here, and bytes are what we genuinely
	# want, exactly as len() is the right byte count for @cData.

	def _ByteCount_()
		return len(@cData)

	# 1-based, count-based, clamped. Answers "" rather than raising for an
	# out-of-range window, which is what the callers below already assumed.
	def _ByteSlice_(nStart, nCount)
		_nLen_ = len(@cData)
		if nStart < 1 nCount = nCount + nStart - 1 nStart = 1 ok
		if nCount < 1 or nStart > _nLen_ return "" ok
		if nStart + nCount - 1 > _nLen_ nCount = _nLen_ - nStart + 1 ok
		return substr(@cData, nStart, nCount)

	def _ByteLeft_(n)
		return This._ByteSlice_(1, n)

	def _ByteRight_(n)
		if n < 1 return "" ok
		_nLen_ = len(@cData)
		if n >= _nLen_ return @cData ok
		return This._ByteSlice_(_nLen_ - n + 1, n)

	# Inserts the first bytes of a text before a position, changing the object.
	#
	#   nPosition   the byte position the new bytes go before, 1 being the first
	#   _nBytes_    how many bytes of pcSubstr to insert
	#   pcSubstr    the text the bytes are taken from
	#   returns     nothing; read ToString for the result
	#   note        a position past the end appends; a position of 0 or less inserts at the start
	#   see         RemoveNBytesStartingAt, ReplaceNBytes
	#-------------------------------------------------------------------
	def InsertNBytesOfSubstringAt(nPosition, _nBytes_, pcSubstr)
		_cLeft_ = This._ByteLeft_(nPosition - 1)
		_cInsert_ = substr(pcSubstr, 1, _nBytes_)
		_cRight_ = This._ByteSlice_(nPosition, len(@cData) - nPosition + 1)
		@cData = _cLeft_ + _cInsert_ + _cRight_

	def NLeftBytes(n)
		return This._ByteLeft_(n)

		# Returns the first n bytes as a text.
		#
		#   n          how many bytes to take
		#   returns    a text; the whole content when n is larger
		#   note       NLeftBytes is the same call; the cut is by bytes, so a character of several
		#              bytes can be cut in the middle
		#   see        RightNBytes, Section
		def LeftNBytes(n)
			return NLeftBytes(n)

	# Returns the first three bytes as a text.
	#
	#   returns    a text; the whole content when it has fewer than three bytes
	#   note       Left3Bytes is the same call
	#   see        LeftNBytes, 3RightBytes
	def 3LeftBytes()
		return This.NLeftBytes(3)

		def Left3Bytes()
			return This.3LeftBytes()

	def NRightBytes(n)
		return This._ByteRight_(n)

		# Returns the last n bytes as a text.
		#
		#   n          how many bytes to take
		#   returns    a text; the whole content when n is larger
		#   note       NRightBytes is the same call
		#   see        LeftNBytes, Section
		def RightNBytes(n)
			return NRightBytes(n)

	# Returns the last three bytes as a text.
	#
	#   returns    a text; the whole content when it has fewer than three bytes
	#   note       Right3Bytes is the same call
	#   see        RightNBytes, 3LeftBytes
	def 3RightBytes()
		return This.NRightBytes(3)

		def Right3Bytes()
			return This.3RightBytes()

	# Removes every byte, leaving the list empty.
	#
	#   returns    nothing; use ClearQ to chain
	#   see        IsEmpty, RemoveNBytesFromEnd
	def Clear()
		@cData = ""

		def ClearQ()
			This.Clear()
			return This

	# TRUE if the list holds no byte.
	#
	#   returns    TRUE or FALSE
	#   see        Clear, NumberOfBytes
	def IsEmpty()
		return len(@cData) = 0

	# Removes a number of bytes from a position, changing the object.
	#
	#   nPosition   the byte position of the first byte removed
	#   _nBytes_    how many bytes to remove, fewer if the end comes first
	#   returns     nothing; use RemoveNBytesStartingAtQ to chain
	#   note        a position outside the content changes nothing
	#   see         RemoveNBytesFromEnd, InsertNBytesOfSubstringAt
	def RemoveNBytesStartingAt(nPosition, _nBytes_)
		_nLen_ = len(@cData)
		if nPosition < 1 or nPosition > _nLen_ return ok
		_nEnd_ = nPosition + _nBytes_ - 1
		if _nEnd_ > _nLen_ _nEnd_ = _nLen_ ok
		@cData = This._ByteLeft_(nPosition - 1) + This._ByteSlice_(_nEnd_ + 1, _nLen_ - _nEnd_)

	def RemoveNBytesStartingAtQ(nPosition, _nBytes_)
		This.RemoveNBytesStartingAt(nPosition, _nBytes_)
		return This

	# Removes the last n bytes, changing the object.
	#
	#   n          how many bytes to remove
	#   returns    nothing; use RemoveNBytesFromEndQ to chain
	#   see        RemoveNBytesStartingAt, TruncateAt
	def RemoveNBytesFromEnd(n)
		if n >= len(@cData)
			@cData = ""
		else
			@cData = This._ByteLeft_(len(@cData) - n)
		ok

	def RemoveNBytesFromEndQ(n)
		This.RemoveNBytesFromEnd(n)
		return This

	def Range(nStart, _nBytes_)
		return This._ByteSlice_(nStart, _nBytes_)

	# Returns the bytes from one position to another, both included, as a text.
	#
	#   n1         the byte position to start at, 1 being the first
	#   n2         the byte position to end at
	#   returns    a text; bytes beyond the end are left out, and an empty text when n2 is before n1
	#   note       Range takes a start and a count
	#   see        LeftNBytes, RightNBytes
	def Section(n1, n2)
		return This.Range( n1, n2 - n1 + 1 )

	# Replaces some bytes at a position by the first bytes of another text, changing the object.
	#
	#   nBytesFromMainStr     how many bytes of the list to remove
	#   nStartingAtPosition   the byte position the replacement starts at
	#   nWithNBytes           how many bytes of pcFromSubstr to put in
	#   pcFromSubstr          the text the new bytes are taken from
	#   returns               nothing; use ReplaceNBytesQ to chain
	#   see                   InsertNBytesOfSubstringAt, RemoveNBytesStartingAt
	def ReplaceNBytes(nBytesFromMainStr, nStartingAtPosition, nWithNBytes, pcFromSubstr)
		_cLeft_ = This._ByteLeft_(nStartingAtPosition - 1)
		_cMid_ = substr(pcFromSubstr, 1, nWithNBytes)
		_cRight_ = This._ByteSlice_(nStartingAtPosition + nBytesFromMainStr, len(@cData) - (nStartingAtPosition + nBytesFromMainStr) + 1)
		@cData = _cLeft_ + _cMid_ + _cRight_

	def ReplaceNBytesQ(nBytesFromMainStr, nStartingAtPosition, nWithNBytes, pcFromSubstr)
		This.ReplaceNBytes(nBytesFromMainStr, nStartingAtPosition, nWithNBytes, pcFromSubstr)
		return This

	# Returns the value of one byte, a number from 0 to 255.
	#
	#   n          the byte position, 1 being the first
	#   returns    a number; -1 when n is outside the content
	#   note       the name says Unicode but the number is the raw byte, not a code point;
	#              BytecodeOfNthByte is the same call
	#   see        Bytecodes
	def UnicodeOfNthByte(n)
		# Bounded in BYTES, because @cData[n] indexes bytes. The bound used to
		# be StzLen (codepoints), so on multibyte content every byte past the
		# codepoint count answered -1 for a byte that plainly exists.
		if n < 1 or n > len(@cData) return -1 ok
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

	# Returns the value of every byte, each a number from 0 to 255.
	#
	#   returns    a list of numbers
	#   note       Unicodes is the same call, with the same raw bytes
	#   see        UnicodeOfNthByte, BytecodesPerChar
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

	# Returns the characters of the text, each as a text of one or more bytes.
	#
	#   returns    a list of texts
	#   note       the cut is by character and not by byte
	#   see        Bytecodes, BytesPerChar
	def Chars()
		return This.ToStzString().Chars()

		def CharsQ()
			return new stzList( This.Chars() )

	# Returns every character with the values of its bytes.
	#
	#   returns    a list of [ character, list of numbers ] pairs
	#   note       UnicodesPerChar is the same call
	#   see        Bytecodes, BytesPerChar
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

	# Returns every character with its bytes as one-byte texts.
	#
	#   returns    a list of [ character, list of one-byte texts ] pairs
	#   note       the one-byte texts of a multibyte character are not valid characters and print as
	#              garbage; use BytecodesPerChar to read them
	#   see        BytecodesPerChar, NumberOfBytesPerChar
	def BytesPerChar()
		_aChars_ = This.Chars()
		_nLen_ = len(_aChars_)

		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + [ _aChars_[i], StzListOfBytesQ(_aChars_[i]).Bytes()]
		next

		return _aResult_

	# Returns the bytes of a character as one-byte texts, if the list contains that character.
	#
	#   pcChar     the character to look for, as text
	#   returns    a list of one-byte texts; an empty list when the character is not in the content
	#   see        BytesOfCharNumber, BytecodesPerChar
	def BytesOfChar(pcChar)
		if CheckingParams()
			if NOT ( isString(pcChar) and @IsChar(pcChar) )
				StzRaise("Incorrect param type! pcChar must be a char.")
			ok
		ok

		_aChars_ = This.Chars()
		_nLen_ = len(_aChars_)

		_aResult_ = []

		if StzFindFirst(pcChar, _aChars_) > 0
			_aResult_ = StzListOfBytesQ(pcChar).Bytes()
		ok

		return _aResult_

		# Does nothing today and answers an empty text instead of the bytes of a character.
		#
		#   pcChar     the character it was meant to look for
		#   returns    an empty text
		#   warning    the definition has no body, so the argument is never read; BytesOfChar
		#              answers the bytes (tried on abc with b, and on héllo with é)
		#   see        BytesOfChar
		def BytesOfThisChar(pcChar)

	# Returns how many bytes the character at a position takes.
	#
	#   n          the character position, 1 being the first
	#   returns    a number
	#   note       NumberOfBytesInCharN is the same call; a position beyond the last character
	#              raises an error
	#   see        BytesOfCharNumber, NumberOfBytesInNthChar
	def NumberOfBytesInCharNumber(n)
		_nResult_ = len( This.BytesOfCharNumber(n) )
		return _nResult_

		def NumberOfBytesInCharN(n)
			return This.NumberOfBytesInCharNumber(n)

	# Returns the bytes of the character at a position, as one-byte texts.
	#
	#   n          the character position, 1 being the first
	#   returns    a list of one-byte texts
	#   note       BytesOfNthChar and BytesOfCharN are the same call
	#   warning    a position beyond the last character raises the error Array Access (Index out of
	#              range)
	#   see        NumberOfBytesInCharNumber, BytesOfChar
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

	# Returns how many bytes the list holds.
	#
	#   returns    a number
	#   note       Size and SizeInBytes are the same call; the count is of bytes, so é counts for 2
	#   see        NumberOfBytesPerChar, IsEmpty
	def NumberOfBytes()
		return len(@cData)

		def Size()
			return This.NumberOfBytes()

		def SizeInBytes()
			return This.NumberOfBytes()

	# Returns every character with the number of bytes it takes.
	#
	#   returns    a list of [ character, number ] pairs
	#   see        NumberOfBytes, BytesPerChar
	def NumberOfBytesPerChar()

		_aResult_ = []
		for i = 1 to This.ToStzString().NumberOfChars()
			_oStzChar_ = new stzChar(This.ToStzString()[i])
			_aResult_ + [ This.ToStzString()[i], _oStzChar_.NumberOfBytes() ]
		next

		return _aResult_

	# Returns how many bytes the character at a position takes.
	#
	#   n          the character position, 1 being the first
	#   returns    a number
	#   warning    a position beyond the last character raises the error Array Access (Index out of
	#              range)
	#   see        NumberOfBytesInCharNumber, NumberOfBytesPerChar
	def NumberOfBytesInNthChar(n)

		return This.NumberOfBytesPerChar()[n][2]

	# Returns how many bytes a given character takes in this list.
	#
	#   pcCaract   the character to look for, as text
	#   returns    a number; an empty text when the character is not in the list
	#   see        NumberOfBytesInNthChar, NumberOfBytesPerChar
	def NumberOfBytesInChar(pcCaract)
		return This.NumberOfBytesPerChar()[pcCaract]

	# Replaces every byte by one ASCII character, keeping the same size.
	#
	#   pcChar     the ASCII character to fill with
	#   returns    the new content, as a text
	#   note       the size stays the number of bytes the list had
	#   warning    a character that is not ASCII raises an error
	#   see        FillWithAsciiCharUpToNBytes, Resize
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

	# Replaces the content by one ASCII character repeated for a number of bytes.
	#
	#   pcChar     the ASCII character to repeat
	#   _nBytes_   how many bytes the new content has
	#   returns    nothing; read ToString for the result
	#   see        FillWithAsciiChar, Resize
	def FillWithAsciiCharUpToNBytes(pcChar, _nBytes_)
		@cData = @copy(StzChar(ascii(pcChar)), _nBytes_)

	# Raises error R21 today instead of filling the content with one ASCII character repeated for a number of characters.
	#
	#   pcChar     the ASCII character to repeat
	#   nChars     the number of characters wanted
	#   returns    nothing; it raises an error
	#   warning    raises the error R21 Using operator with values of incorrect type, because nChars
	#              is multiplied by NumberOfBytesPerChar, which answers a list of pairs and not a
	#              number (tried on abc with 2, and on abcd with 3)
	#   see        FillWithAsciiCharUpToNBytes
	def FillWithAsciiCharUpToNChars(pcChar, nChars)
		_nBytes_ = nChars * This.NumberOfBytesPerChar()
		@cData = @copy(StzChar(ascii(pcChar)), _nBytes_)

	# Cuts the content to n bytes, or pads it with zero bytes up to n, changing the object.
	#
	#   n          the new size, in bytes
	#   returns    nothing; read ToString for the result
	#   note       the padding bytes have the value 0
	#   see        FillWithAsciiCharUpToNBytes, TruncateAt
	def Resize(n)
		# n is a BYTE size: the padding below appends one NUL per unit, so
		# growing and shrinking have to be measured on the same axis.
		_nLen_ = len(@cData)
		if n < _nLen_
			@cData = This._ByteLeft_(n)
		but n > _nLen_
			@cData = @cData + @copy(StzChar(0), n - _nLen_)
		ok

	# Does nothing: the bytes are not pre-allocated in this class.
	#
	#   n          the size that would be reserved, which is ignored
	#   returns    nothing
	#   note       kept so that code written for a byte array can call it
	#   see        Resize, ReleaseUnusedMemory
	def Reserve(n)
	# Does nothing: the bytes are held in a Ring text with no spare room.
	#
	#   returns    nothing
	#   note       Squeeze is the same call
	#   see        Reserve, Squeeze
	#@ aka  No-op in pure Ring -- no pre-allocation concept
	def ReleaseUnusedMemory()
		# Does nothing: the bytes are held in a Ring text with no spare room.
		#
		#   returns    nothing
		#   see        Reserve, ReleaseUnusedMemory
		#@ aka  No-op in pure Ring
		def Squeeze()
			This.ReleaseUnusedMemory()

	# Replaces the content by the digits of a number written in a base.
	#
	#   nNumber    the whole number to write, a negative one gets a leading -
	#   nBase      the base, 2 to 36
	#   returns    nothing; read ToString for the result
	#   note       digits above 9 are lower-case letters; the name has the typo Witht
	#   see        ToHex, FromHex
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

	# Exchanges the bytes of this list with those of another list of bytes.
	#
	#   oOtherListOfBytes   the other stzListOfBytes, which receives this list's bytes
	#   returns             nothing
	#   warning             a value that is not a list of bytes raises an error saying it can not
	#                       swap
	#   see                 Copy, Update
	def SwapWith(oOtherListOfBytes)
		if IsListOfBytes(oOtherListOfBytes)
			_cTemp_ = @cData
			@cData = oOtherListOfBytes.ToString()
			oOtherListOfBytes.Update(_cTemp_)
		else
			StzRaise(stzListOfBytesError(:CanNotSwapWithNonListOfBytes))
		ok

	# Returns the bytes written in Base64.
	#
	#   returns    a text; an empty text for an empty list
	#   see        FromBase64, ToHex
	def ToBase64()
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = "" return "" ok
		_cResult_ = StzEngineBytesToBase64(pHandle)
		StzEngineBytesFree(pHandle)
		return _cResult_

	# Replaces the content by the bytes a Base64 text stands for.
	#
	#   pcBase64String   the Base64 text to decode
	#   returns          nothing; read ToString for the result
	#   see              ToBase64, FromHex
	def FromBase64(pcBase64String)
		pHandle = StzEngineBytesNew()
		if pHandle = "" return ok
		StzEngineBytesFromBase64(pHandle, pcBase64String)
		_nSize_ = StzEngineBytesSize(pHandle)
		if _nSize_ > 0
			@cData = StzEngineBytesLeft(pHandle, _nSize_)
		else
			@cData = ""
		ok
		StzEngineBytesFree(pHandle)

	# Returns the bytes written with a % escape for every byte that is not a letter, a digit or one of - _ . ~.
	#
	#   pcExcludedFromEncoding   meant to name characters left unescaped
	#   pcIncludedInEncoding     meant to name characters escaped too
	#   pcPercentAsciiChar       meant to name the escape character
	#   returns                  a text such as "a%20b"
	#   note                     the escapes use upper-case hex digits
	#   warning                  the three arguments are accepted and ignored: with - given as
	#                            excluded, a given as included and # as escape character the answers
	#                            did not change (tried three times)
	#   see                      FromPercentEncoding, ToHex
	def ToPercentEncoding(pcExcludedFromEncoding, pcIncludedInEncoding, pcPercentAsciiChar)
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = "" return @cData ok
		_cResult_ = StzEngineBytesToPercent(pHandle)
		StzEngineBytesFree(pHandle)
		return _cResult_

	# Replaces the content by the bytes a %-escaped text stands for.
	#
	#   pcPercentEncodedString   the text to decode, such as "a%20b"
	#   pcPercentAsciiChar       meant to name the escape character, which is not used
	#   returns                  1 when it ran
	#   note                     the escape character is always %
	#   see                      ToPercentEncoding, FromHex
	def FromPercentEncoding(pcPercentEncodedString, pcPercentAsciiChar)
		pHandle = StzEngineBytesNew()
		if pHandle = "" return 0 ok
		StzEngineBytesFromPercent(pHandle, pcPercentEncodedString)
		_nSize_ = StzEngineBytesSize(pHandle)
		if _nSize_ > 0
			@cData = StzEngineBytesLeft(pHandle, _nSize_)
		else
			@cData = ""
		ok
		StzEngineBytesFree(pHandle)
		return 1

	# Returns the bytes as hexadecimal digits behind the prefix 0x.
	#
	#   returns    a text such as "0x4869"; "0x" for an empty list
	#   see        ToHexWithoutPrefix, Hexcodes, FromHex
	def ToHex()
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = "" return HexPrefix() ok
		_cResult_ = HexPrefix() + StzEngineBytesToHex(pHandle)
		StzEngineBytesFree(pHandle)
		return _cResult_

		def ToHexQ()
			return new stzString(This.ToHex())

	# Returns the bytes as hexadecimal digits, two per byte, with no prefix.
	#
	#   returns    a text such as "4869"
	#   see        ToHex, FromHex
	def ToHexWithoutPrefix()
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = "" return "" ok
		_cResult_ = StzEngineBytesToHex(pHandle)
		StzEngineBytesFree(pHandle)
		return _cResult_

		def ToHexWithoutPrefixQ()
			return new stzString( This.ToHexWithoutPrefix() )

	# Replaces the content by the bytes that pairs of hexadecimal digits stand for.
	#
	#   pcHexString   the digits, two per byte, with no prefix, no space and an even count
	#   returns       nothing; read ToString for the result
	#   warning       text that is not made of pairs of hex digits, such as one with 0x in front,
	#                 with a space, with an odd count or with a letter beyond f, does not raise: it
	#                 empties the list (tried on 0xff, 414, zz and 41 42)
	#   see           ToHexWithoutPrefix, FromBase64
	def FromHex(pcHexString)
		pHandle = StzEngineBytesNew()
		if pHandle = "" return ok
		StzEngineBytesFromHex(pHandle, pcHexString)
		_nSize_ = StzEngineBytesSize(pHandle)
		if _nSize_ > 0
			@cData = StzEngineBytesLeft(pHandle, _nSize_)
		else
			@cData = ""
		ok
		StzEngineBytesFree(pHandle)

	# Raises error R14 today instead of answering the bytes as UTF-8.
	#
	#   returns    nothing; it raises an error
	#   warning    raises the error R14 Calling Method without definition: toutf8, because it
	#              forwards to a stzString method that does not exist (tried on abc and on aé€)
	#   see        ToString, ToHexUTF8
	def ToUTF8()
		_cResult_ = This.ToStzString().ToUTF8()
		return _cResult_

	# Returns every byte as a hexadecimal text with the prefix 0x.
	#
	#   returns    a list of texts such as "0x48"
	#   see        HexcodesWithoutPrefix, HexPerByte, ToHex
	def Hexcodes()
		_aBytes_ = This.Bytes()
		_nLen_ = len(_aBytes_)

		_acResult_ = []

		for i = 1 to _nLen_
			_cHex_ = StzListOfBytesQ(_aBytes_[i]).ToHex()
			_acResult_ + _cHex_
		next

		return _acResult_

	# Returns every byte with its hexadecimal text.
	#
	#   returns    a list of [ byte, "0x.." ] pairs
	#   see        Hexcodes, HexPerByteWithoutPrefix
	def HexPerByte()
		_aBytes_ = This.Bytes()
		_nLen_ = len(_aBytes_)

		_aResult_ = []

		for i = 1 to _nLen_
			_cHex_ = StzListOfBytesQ(_aBytes_[i]).ToHex()
			_aResult_ + [ _aBytes_[i], _cHex_ ]
		next

		return _aResult_

	# Returns every byte as a two-digit hexadecimal text.
	#
	#   returns    a list of texts such as "48"
	#   see        Hexcodes, HexPerByteWithoutPrefix
	def HexcodesWithoutPrefix()
		_aBytes_ = This.Bytes()
		_nLen_ = len(_aBytes_)

		_acResult_ = []

		for i = 1 to _nLen_
			_cHex_ = StzListOfBytesQ(_aBytes_[i]).ToHexWithoutPrefix()
			_acResult_ + _cHex_
		next

		return _acResult_

	# Returns every byte with its two-digit hexadecimal text.
	#
	#   returns    a list of [ byte, "hh" ] pairs
	#   see        HexcodesWithoutPrefix, HexPerByte
	def HexPerByteWithoutPrefix()
		_aBytes_ = This.Bytes()
		_nLen_ = len(_aBytes_)

		_aResult_ = []

		for i = 1 to _nLen_
			_cHex_ = StzListOfBytesQ(_aBytes_[i]).ToHexWithoutPrefix()
			_aResult_ + [ _aBytes_[i], _cHex_ ]
		next

		return _aResult_

	# Returns the bytes as prefixed hexadecimal texts joined by a separator.
	#
	#   pcSep      the text put between two bytes
	#   returns    a text such as "0x48-0x69"
	#   note       ToHexSeparatedBy, ToHexSeparatedWith and ToHexSeparatedUsing are the same call
	#   warning    a separator that is not a text raises an error
	#   see        ToHexSpacified, ToHexWithoutPrefixSeparated
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

		# Returns the bytes as prefixed hexadecimal texts joined by a separator, as ToHexSeparated does.
		#
		#   pcSep      the text put between two bytes
		#   returns    a text such as "0x48:0x69"
		#   see        ToHexSeparated, ToHexWithoutPrefixSeparatedBy
		#< @FunctionAlternativeForm
		def ToHexSeparatedBy(pcSep)
			if CheckingParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexSeparated(pcSep)

		# Returns the bytes as prefixed hexadecimal texts joined by a separator, as ToHexSeparated does.
		#
		#   pcSep      the text put between two bytes
		#   returns    a text such as "0x48:0x69"
		#   see        ToHexSeparated, ToHexWithoutPrefixSeparatedWith
		def ToHexSeparatedWith(pcSep)
			if CheckingParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexSeparated(pcSep)

		# Returns the bytes as prefixed hexadecimal texts joined by a separator, as ToHexSeparated does.
		#
		#   pcSep      the text put between two bytes
		#   returns    a text such as "0x48:0x69"
		#   see        ToHexSeparated, ToHexWithoutPrefixSeparatedUsing
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

	# Returns the bytes as prefixed hexadecimal texts separated by one space.
	#
	#   returns    a text such as "0x48 0x69"
	#   see        ToHexSeparated, ToHexWithoutPrefixSpacified
		#>
	def ToHexSpacified()
		return This.ToHexSeparatedBy(" ")

	# Returns the bytes as two-digit hexadecimal texts joined by a separator.
	#
	#   pcSep      the text put between two bytes
	#   returns    a text such as "48-69"
	#   note       the By, With and Using forms are the same call
	#   warning    a separator that is not a text raises an error
	#   see        ToHexWithoutPrefixSpacified, ToHexSeparated
	#@ aka  --
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

		# Returns the bytes as two-digit hexadecimal texts joined by a separator, as ToHexWithoutPrefixSeparated does.
		#
		#   pcSep      the text put between two bytes
		#   returns    a text such as "48:69"
		#   see        ToHexWithoutPrefixSeparated, ToHexSeparatedBy
		#< @FunctionAlternativeForm
		def ToHexWithoutPrefixSeparatedBy(pcSep)
			if CheckingParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexWithoutPrefixSeparated(pcSep)

		# Returns the bytes as two-digit hexadecimal texts joined by a separator, as ToHexWithoutPrefixSeparated does.
		#
		#   pcSep      the text put between two bytes
		#   returns    a text such as "48:69"
		#   see        ToHexWithoutPrefixSeparated, ToHexSeparatedWith
		def ToHexWithoutPrefixSeparatedWith(pcSep)
			if CheckingParams()
				if NOT isString(pcSep)
					StzRaise("Incorrect param type! pcSep must be a string.")
				ok
			ok

			return This.ToHexWithoutPrefixSeparated(pcSep)

		# Returns the bytes as two-digit hexadecimal texts joined by a separator, as ToHexWithoutPrefixSeparated does.
		#
		#   pcSep      the text put between two bytes
		#   returns    a text such as "48:69"
		#   see        ToHexWithoutPrefixSeparated, ToHexSeparatedUsing
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

	# Returns the bytes as two-digit hexadecimal texts separated by one space.
	#
	#   returns    a text such as "48 69"
	#   see        ToHexWithoutPrefixSeparated, ToHexSpacified
		#>
	def ToHexWithoutPrefixSpacified()
		return This.ToHexWithoutPrefixSeparatedBy(" ")

	# Returns the bytes as two-digit hexadecimal texts, each behind a backslash-x, separated by a space.
	#
	#   returns    a text such as "\x48 \x69"
	#   see        ToHexWithoutPrefixSeparated, ToHex
	def ToHexUTF8()
		_cResult_ = "\x" + This.ToHexWithoutPrefixSeparatedBy(" \x")
		return _cResult_

	# Replaces the content by a text.
	#
	#   pcStr      the new content
	#   returns    nothing; use UpdateQ to chain
	#   note       UpdateWith, UpdateBy and UpdateUsing are the same call
	#   see        Updated, FromHex
	#@ aka  --
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

		# Replaces the content by a text, as Update does.
		#
		#   pcStr      the new content
		#   returns    nothing
		#   see        Update
		#< @FunctionAlternativeForms
		def UpdateWith(pcStr)
			This.Update(pcStr)

			def UpdateWithQ(pcStr)
				return This.UpdateQ(pcStr)

		# Replaces the content by a text, as Update does.
		#
		#   pcStr      the new content
		#   returns    nothing
		#   see        Update
		def UpdateBy(pcStr)
			This.Update(pcStr)

			def UpdateByQ(pcStr)
				return This.UpdateQ(pcStr)

		# Replaces the content by a text, as Update does.
		#
		#   pcStr      the new content
		#   returns    nothing
		#   see        Update
		def UpdateUsing(pcStr)
			This.Update(pcStr)

			def UpdateUsingQ(pcStr)
				return This.UpdateQ(pcStr)

	# Returns the text it is given, unchanged, and leaves the bytes of the object as they were.
	#
	#   pcStr      the text to give back
	#   returns    the text given
	#   note       UpdatedWith, UpdatedBy and UpdatedUsing are the same call
	#   warning    it does not return an updated copy as the name suggests: the object stayed abc
	#              and x with the arguments QQ and ZZZ
	#   see        Update
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

	# Does nothing today and answers an empty text: its body is a TODO that waits for a list of bits class.
	#
	#   returns    an empty text
	#   note       tried on abc and on x
	#   see        ToStzListOfBits, Bytecodes
		#>
	#---
	def Bits()
		// TODO: after making stzListOfBits

	# Does nothing today and answers an empty text: its body is a TODO that waits for a list of bits class.
	#
	#   returns    an empty text
	#   note       tried on abc and on x
	#   see        Bits, Bytecodes
	def ToStzListOfBits()
		// TODO

	# Returns the bytes with the ASCII capital letters changed to small ones, leaving the object as it is.
	#
	#   returns    a text
	#   note       a character beyond ASCII, such as É, is not changed; ToLowercase is the same call
	#   see        ApplyLowercase, Uppercased
	def Lowercase()
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = "" return @cData ok
		_cResult_ = StzEngineBytesToLower(pHandle)
		StzEngineBytesFree(pHandle)
		return _cResult_

		def ToLowercase()
			return This.Lowercase()

	# Changes the ASCII capital letters of the content to small ones.
	#
	#   returns    nothing; use ApplyLowercaseQ to chain
	#   note       a character beyond ASCII is not changed
	#   see        Lowercase, Uppercase
	def ApplyLowercase()
		@cData = This.Lowercase()

		def ApplyLowercaseQ()
			This.ApplyLowercase()
			return This

	# Returns the bytes with the ASCII small letters changed to capitals, leaving the object as it is.
	#
	#   returns    a text
	#   note       a character beyond ASCII, such as é, is not changed; ToUppercase is the same call
	#   see        Uppercase, Lowercase
	def Uppercased()
		pHandle = StzEngineBytesFrom(@cData)
		if pHandle = "" return @cData ok
		_cResult_ = StzEngineBytesToUpper(pHandle)
		StzEngineBytesFree(pHandle)
		return _cResult_

		def ToUppercase()
			return This.Uppercased()

	# Changes the ASCII small letters of the content to capitals.
	#
	#   returns    nothing; use UppercaseQ to chain
	#   note       a character beyond ASCII is not changed
	#   see        Uppercased, ApplyLowercase
	def Uppercase()
		@cData = This.Uppercased()

		def UppercaseQ()
			This.Uppercase()
			return This

		# Changes the ASCII small letters of the content to capitals, as Uppercase does.
		#
		#   returns    nothing; use ApplyUppercaseQ to chain
		#   see        Uppercase, ApplyLowercase
		def ApplyUppercase()
			This.Uppercase()

			def ApplyUppercaseQ()
				This.ApplyUppercase()
				return This

	# Returns the bytes without the spaces at both ends, leaving the object as it is.
	#
	#   returns    a text
	#   see        Trim, Section
	def Trimmed()
		return @trim(@cData)

		# Does nothing today and answers an empty text instead of the bytes without the spaces at both ends.
		#
		#   returns    an empty text
		#   warning    the definition has no body; Trimmed answers the trimmed bytes (tried on '  ab
		#              c  ' and on 'x ')
		#   see        Trimmed, Strip
		def Stripped()

	# Removes the spaces at both ends of the content.
	#
	#   returns    nothing; use TrimQ to chain
	#   see        Trimmed, Strip
	def Trim()
		@cData = @trim(@cData)

		def TrimQ()
			This.Trim()
			return This

		# Removes the spaces at both ends of the content, as Trim does.
		#
		#   returns    nothing; use StripQ to chain
		#   see        Trim, Trimmed
		def Strip()
			This.Trim()

			def StripQ()
				return This.TrimQ()

	def TruncatedAt(n)
		return This._ByteLeft_(n)

	# Keeps only the first n bytes.
	#
	#   n          how many bytes to keep
	#   returns    nothing; use TruncateAtQ to chain
	#   note       TruncatedAt answers the same bytes without changing the object
	#   see        RemoveNBytesFromEnd, Resize
	def TruncateAt(n)
		@cData = This._ByteLeft_(n)

		def TruncateAtQ(n)
			This.TruncateAt(n)
			return this
