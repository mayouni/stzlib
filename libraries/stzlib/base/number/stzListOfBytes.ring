#-------------------------------------------------------------------------------#
# 		   SOFTANZA LIBRARY (V1.0) - stzListOfBytes			#
#		 An accelerative library for Ring applications	      		#
#-------------------------------------------------------------------------------#
#										#
# 	Description	: The class for managing lists of bytes		        #
#	Version		: V1.0 (2020-2024)					#
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		   	#
#										#
#-------------------------------------------------------------------------------#

/*
Internatlly, stzListOfBytes (and thus QByteArray) use UTF-8 encoding of bytes.
		
UTF 8 encodes characters on 1, 2, 3 or 4 bytes depending on the char unicode:
	* from 0 to 127 (ascii characters) : 1 byte
	* from 128 to 2047 : 2 bytes
	* from 2048 to 65535 : 3 bytes
	* from 65536 to 1114111 : 4 bytes
		
Look at this: http://tutorials.jenkov.com/unicode/utf-8.html
*/

/* FROM QT DOCUMENTATION

QByteArray can be used to store both raw bytes (including '\0's) and
traditional 8-bit '\0'-terminated strings. Using QByteArray is much
more convenient than using const char *. Behind the scenes, it always
ensures that the data is followed by a '\0' terminator, and uses
implicit sharing (copy-on-write) to reduce memory usage and avoid
needless copying of data.

In addition to QByteArray, Qt also provides the QString class to
store string data. For most purposes, QString is the class you want
to use. It understands its content as Unicode text (encoded using UTF-16)
where QByteArray aims to avoid assumptions about the encoding or semantics
of the bytes it stores (aside from a few legacy cases where it uses ASCII).

Furthermore, QString is used throughout in the Qt API. The two main cases
where QByteArray is appropriate are when you need to store raw binary data,
and when memory conservation is critical (e.g., with Qt for Embedded Linux).

*/


func StzListOfBytesQ(p)
	return new stzListOfBytes(p)

func IsListOfBytes(p)
	if isString(p) or @IsStzString(p) or @IsStzListOfBytes(p) or @IsQByteArray(p)
		return _TRUE_
	else
		return _FALSE_
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

// The fellowing function is Used to retrive the numeric value hosted in
// pointers returned by some Qt methods (made with the help of Ilir)
func NumberInPointer(ptr)
	if IsPointer(ptr)
		BinStr = pointer2string(ptr, 0, len(int2bytes(0)) )
		return bytes2int(BinStr)
	else
		StzRaise("Value you provided is not of type Pointer!")
	ok

class stzBytes from stzListOfBytes

class stzListOfBytes from stzList
	
	@oQByteArray

	// Creates a list of bytes from an ordinary string or
	// from a QByteArray object
	def init(pValue)
		@oQByteArray = new QByteArray()

		if isString(pValue)
			@oQByteArray.append(pValue)

		but IsQByteArrayObject(pValue)
			@oQByteArray = pValue

		else
			StzRaise("Can't create the stzListOfBytes object!")
		ok

	// Returns the text represented by the list of bytes content
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
		return new stzListOfBytes(This.Content())

	def ListOfBytes()
		return This.Content()

	def Bytes()
		return This.ListOfBytes()

	def ToString()
		return @oQByteArray.data()

	def ToStzString()
		return new stzString(This.ToString())

	def QByteArrayObject()
		return @oQByteArray

	// Returns the object pointer (for low level use)
	def Pointer()
		return @oQByteArray.objectpointer()

	// Inserts n bytes of a substr in the nPosition position of the list of bytes
	def InsertNBytesOfSubstringAt(nPosition, nBytes, pcSubstr)
		@oQByteArray.insert(nBytes, pcSubstr, nPosition)
		// TODO: ...insert before & after (like in stzString & stzList)

	// Returns the n left bytes as a string
	def NLeftBytes(n)
		return @oQByteArray.left(n).data()

		def LeftNBytes(n)
			return NLeftBytes(n)
	
	def 3LeftBytes()
		return This.NLeftBytes(3)

		def Left3Bytes()
			return This.3LeftBytes()

	// Returns the n right bytes as a string
	def NRightBytes(n)
		return @oQByteArray.right(n).data()

		def RightNBytes(n)
			return NRightBytes()
	
	def 3RightBytes()
		return This.NRightBytes(3)

		def Right3Bytes()
			return This.3RightBytes()

	// Clears the content of the list of bytes
	def Clear()
		@oQByteArray.clear()

		def ClearQ()
			This.Clear()
			return This
	
	// Checks if the list of bytes is empty
	def IsEmpty()
		return @oQByteArray.isempty()

	// Removes n bytes starting from a given position
	def RemoveNBytesStartingAt(nPosition, nBytes)
		@oQByteArray.remove(nPosition, nBytes)
		/* If nPosition is out of range, nothing happens.
		If nPosition is valid, but nPosition + nBytes is larger than the size
		of the array, the array is truncated at position nBytes.
		*/

	def RemoveNBytesStartingAtQ(nPosition, nBytes)
		This.RemoveNBytesStartingAt(nBytes, nPosition)
		return This

	// Removes n bytes from the end of the list of bytes
	def RemoveNBytesFromEnd(n)
		@oQByteArray.chop(n)

	def RemoveNBytesFromEndQ(n)
		This.RemoveNBytesFromEnd(n)
		return This

	// Returns a portion of the list of bytes starting from position nStart
	def Range(nStart, nBytes)
		return @oQByteArray.mid(nStart - 1, nBytes).data()

	// Returns the list of bytes between positions nStart and nEnd
	def Section(n1, n2)
		return This.Range( n1, n2 - n1 + 1 )

	// Replaces nBytesFromMainStr bytes from the main list of bytes, starting at
	// position nStartingAtPosition, with nWithNBytes bytes from the provided substring
	def ReplaceNBytes(nBytesFromMainStr, nStartingAtPosition, nWithNBytes, pcFromSubstr)
		@oQByteArray.replace(nStartingAtPosition-1, nBytesFromMainStr, pcFromSubstr, nWithNBytes ).data()
		/*
		Example:
		o1 = new stzListOfBytes("Rixo")
		o1.Replace(2, 3, 2, "ngioom")
		? o1.Content() # Gives 'Ring'
		*/

	def ReplaceNBytesQ(nBytesFromMainStr, nStartingAtPosition, nWithNBytes, pcFromSubstr)
		This.ReplaceNBytes(nBytesFromMainStr, nStartingAtPosition, nWithNBytes, pcFromSubstr)
		return This

	def UnicodeOfNthByte(n) #NOTE: Is it more accurate to talk of Bytecode rather then Unicode?
		return @oQByteArray.at(n-1)

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

		for i = 0 to @oQByteArray.size()
			aResult + @oQByteArray.at(i)
		next

		if aResult[ len(aResult) ] = 0
			del(aResult, len(aResult) )
		ok

		return aResult

		def BytecodesQ()
			return new stzList( This.Bytecodes() )

		def Unicodes()
			return This.Bytecodes()

			def UnicodesQ()
				return This.BytescodesQ()

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

		if ring_find(aChars, pcChar) > 0
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
		return @oQByteArray.size()

		def Size()
			return This.NumberOfBytes()

		def SizeInBytes()
			return This.NumberOfBytes()
			
	def NumberOfBytesPerChar() #--> stzString domain
		/* Exp:
			o1 = new stzListOfBytes("s㊱m")
			? o2.NumberOfBytesPerChar()
			--> [ :s = 1, :㊱ = 3, :m = 1 ]
		*/

		aResult = []
		for i = 1 to This.ToStzString().NumberOfChars()
		// WARNING: Note that for in loop, instead of for loop with a counter
		// does not give a correct result!
			oStzChar = new stzChar(This.ToStzString()[i])
			aResult + [ This.ToStzString()[i], oStzChar.NumberOfBytes() ]
		next

		return aResult

	def NumberOfBytesInNthChar(n) #--> stzChar domain

		return This.NumberOfBytesPerChar()[n][2]

	def NumberOfBytesInChar(pcCaract) #--> stzChar domain
		return This.NumberOfBytesPerChar()[pcCaract]

	// Sets each byte in the list of bytes using the provided ascii character
	// Warning: non ascii characters are not supported
	def FillWithAsciiChar(pcChar)
		oCaract = new stzChar(pcChar)
		if oCaract.IsAscii()
			return @oQByteArray.fill(oCaract.AsciiCode(), This.NumberOfBytes()).data()
		else
			return StzRaise(stzListOfBytesError(:CanNotFillBytesWithNonAsciiChar))
		ok

	def FillWithAsciiCharUpToNBytes(pcChar, nBytes)
		@oQByteArray.fill(ascii(pcChar), nBytes)

	def FillWithAsciiCharUpToNChars(pcChar, nChars)
		nBytes = nChars * This.NumberOfBytesPerChar()
		@oQByteArray.fill(ascii(pcChar), nBytes)

	// Resises the list of bytes
	def Resize(n)
		@oQByteArray.resize(n)

	// Reserves n bytes of memory for the list of bytes
	// Use it if you know the size in advance -> better performance
	def Reserve(n)
		@oQByteArray.reserve(n)

	// Releases any memory not required to store the list of bytes's data
	def ReleaseUnusedMemory()
		@oQByteArray.squeeze()

		def Squeeze()
			This.ReleaseUnusedMemory()
	
	// Sets the list of bytes to the printed value of a number in base nBase
	// (nBase can be any number from 2 to 36)
	def SetWithtNumberInBase(nNumber, nBase)
		@oQByteArray.setNum(nNumber,nBase)

	// Swaps the main list of bytes with an other list of bytes created from
	// the provided string
	def SwapWith(oOtherListOfBytes)
		if IsListOfBytes(oOtherListOfBytes)
			@oQByteArray.swap(ToQByteArrayObject(oOtherListOfBytes))
		else
			StzRaise(stzListOfBytesError(:CanNotSwapWithNonListOfBytes))
		ok

	// Encodes the main list of bytes in a base64 string
	def ToBase64()
		return @oQByteArray.toBase64().data()
		/*
		Example:

		o1 = new stzListOfBytes("teebah")
		? o1.Content()
		? o1.ToBase64()

		--> "dGVlYmFo"
	
		Base64 is an encoding algorithm that allows you to transform
		any characters into an alphabet which consists of Latin letters,
		digits, plus, and slash. Thanks to it, you can convert Chinese
		characters, emoji, and even images into a “readable” string,
		which can be saved or transferred anywhere.

		BASE64 characters are 6 bits in length. They are formed by taking
		a block of three octets to form a 24-bit string, which is converted
		into four BASE64 characters.

		The final '==' sequence indicates that the last group contained
		only one byte, and '=' indicates that it contained two bytes.
		Thus, this is some sort of padding to a multiple of 4 characters
		in length, so that it can be decoded correctly

		Note that although Base64 is often used in cryptography is not a
		security mechanism. Anyone can convert the Base64 string back to
		its original bytes, so it should not be used as a means for protecting
		data, only as a format to display or store raw bytes more easily.
		*/

	// Decodes a base64 string into the list of bytes
	def FromBase64(pcBase64String)
		/*
		Example:

		o1 = new stzListOfBytes("")
		o1.FromBase64("dGVlYmFo")
		? o1.Content()

		--> "teebah"
		*/

		oTempQByteArray = new QByteArray()
		oTempQByteArray.append(pcBase64String)

		cResult = @oQByteArray.fromBase64(oTempQByteArray).data()

		@oQByteArray = new QByteArray()
		@oQByteArray.append(cResult)

	// Transforms the content of the list of bytes to a url-like encoded string
	def ToPercentEncoding(pcExcludedFromEncoding, pcIncludedInEncoding, pcPercentAsciiChar)
		/* Example:
		o1 = new stzListOfBytes("{a fishy string?}")
		? o1.ToPercentEncoding( "{}", "s" )

		--> {a%20fi%73hy%20%73tring%3F}
		*/

		// Checking that pcPercentAsciiChar is actually ASCII
		// And setting it to % by default
		oTempChar = new stzChar(pcPercentAsciiChar)
		if oTempChar.IsAsciiChar()
			if pcPercentAsciiCaract = _NULL_
				pcPercentAsciiChar = "%"
			ok
		else
			StzRaise(stzListOfBytesError(:CanNotTransformListOfBytesToPercentEncoding))
		ok

		// Preparing the required objects for the Qt QByteArray method
		oExcluded = new QByteArray()
		oExcluded.append(pcExcludedFromEncoding)
		oIncluded = new QByteArray()
		oIncluded.append(pcIncludedInEncoding)

		// Executing the Qt toPercentEncoding() method and returning the result
		return @oQByteArray.toPercentEncoding(oExcluded, oIncluded, ascii(pcPercentAsciiCaract)).constData()

	// *** Updates the list of bytes with an url-like decoded copy of the provided string
	def FromPercentEncoding(pcPercentEncodedString, pcPercentAsciiChar)
		/* Example:
		o1 = new stzListOfBytes("")
		o1.FromPercentEncoding( "{a%20fi%73hy%20%73tring%3F}", "%" )
		o1.Content()

		--> {a fishy string?}
		*/

		// Checking that pcPercentAsciiChar is actually ASCII
		// And setting it to % by default
		oTempChar = new stzChar(pcPercentAsciiChar)
		if oTempChar.IsAsciiChar()
			if pcPercentAsciiChar = _NULL_
				pcPercentAsciiChar = "%"
			ok
		else
			StzRaise(stzListOfBytesError(:CanNotTransformPercentEncodingToListOfBytes))
		ok

		// Preparing the required objects for the Qt QByteArray method
		oTempQByteArray = new QByteArray()
		oTempQByteArray.append(pcPercentEncodedString)

		// Executing the Qt toPercentEncoding() method and storing the result
		cResult = @oQByteArray.fromPercentEncoding( oTempQByteArray, ascii(pcPercentAsciiCaract)).data()

		// Updating the main QByteArray object with the result
		@oQByteArray = new QByteArray()
		@oQByteArray.append(cResult)

		// If everything goes well, then return _TRUE_
		return _TRUE_
			
	// *** Returns a hex encoded string from the content of the list of bytes
	// The hex encoding uses the numbers 0-9 and the letters a-f
	def ToHex()
		cResult = HexPrefix() + @oQByteArray.toHex().data()
		return cResult

		def ToHexQ()
			return new stzString(This.ToHex())

	def ToHexWithoutPrefix()
		cResult = @oQByteArray.toHex().data()
		return cResult

		def ToHexWithoutPrefixQ()
			return new stzString( This.ToHexWithoutPrefix() )

	def FromHex(pcHexString)
		oTempQByteArray = new QByteArray()
		oTempQByteArray.append(pcHexString)

		cResult = @oQByteArray.fromHex(oTempQByteArray).data()

		// Updating the main QByteArray object with the result
		This.Update(cResult)

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

	def ToHexWithoutPrefixSpacified()
		return This.ToHexWithoutPrefixSeparatedBy(" ")

	def ToHexUTF8()
		cResult = "\x" + This.ToHexWithoutPrefixSeparatedBy(" \x")
		return cResult

	#--

	def Update(pcStr)
		if CheckingParams() = _TRUE_
			if isList(pcStr) and Q(pcStr).IsWithOrByOrUsingNamedParam()
				pcStr = pcStr[2]
			ok
		ok

		@oQByteArray = new QByteArray()
		@oQByteArray.append(cResult)

		if KeepingHisto() = _TRUE_
			This.AddHistoricValue(This.Content())  # From the parent stzObject
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

	// TODO: For the 2 following functions (Bits() and ToStzListOfBits)
	// we need to write stzListOfBits class based on QBitArray.
	// Also, we need to manage the conversion between bits and bytes (and
	// vice-versa). For that, read this: https://wiki.qt.io/Working_with_Raw_Data
	def Bits()
		// TODO: after making stzListOfBits

	def ToStzListOfBits()
		// TODO

	// Returns a lowercase copy of the list of bytes
	// The bytearray is interpreted as a Latin-1 encoded string
	def Lowercase()
		return @oQByteArray.toLower().data()

		def ToLowercase()
			return This.Lowercased()

	def ApplyLowercase()
		This.Update( This.Lowercased() )

		def ApplyLowercaseQ()
			This.ApplyLowercase()
			return This

	// Returns an UPPERcase copy of the list of bytes
	def UPPERcased()
		return @oQByteArray.toUPPER().data()

		def ToUppercase()
			return This.Uppercased()

	def Uppercase()
		This.Update( This.Uppercased() )

		def UppercaseQ()
			This.Uppercase()
			return This

		def ApplyUppercase()
			This.Uppercase()

			def ApplyUppercaseQ()
				This.ApplyUppercase()
				return This

	// Returns a list of bytes that has whitespace removed from the both sides
	def Trimmed()
		return @oQByteArray.trimmed().data()

		def Stripped()

	def Trim()
		This.Update( This.Trimmed() )

		def TrimQ()
			This.Trim()
			return This

		def Strip()
			This.Trim()

			def StripQ()
				return This.Trim()

	// Truncates the list of bytes at the position of the nth byte
	def TruncatedAt(n)
		return @oQByteArray.truncate(8)

	def TruncateAt(n)
		This.Update( This.TruncatedAt(n) )

		def TruncateAtQ(n)
			This.TruncateAt(n)
			return this

