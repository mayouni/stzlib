#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZBYTES                  #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Binary buffer -- Engine-backed (Zig DLL).   #
#                  Create, manipulate, encode/decode binary     #
#                  data. Base64, hex, percent encoding.         #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzBytesQ(pData)
	return new stzBytes(pData)


  /////////////////
 ///   CLASS   ///
/////////////////

# Holds a binary buffer in the engine and reads, cuts, edits and encodes it as Base64, hexadecimal or percent text.
#
# Positions and sizes count bytes from 1, never characters, so a Hebrew letter is 2 bytes and an
# emoji 4. Reads (Left, Right, Mid, ToHex...) return text and leave the buffer alone; Append,
# Insert, Remove, Replace, Fill, Resize, Clear and the From... methods change it in place, and their
# Q forms return the object for chaining. Found today: string/stzBytes.ring is not loaded by
# stzlib.ring, and it defines a class named stzBytes that clashes with the alias class of
# stzListOfBytes.ring, so new stzBytes(...) builds the stzListOfBytes alias and none of the methods
# below exist on it (R14); a negative count, size or length, a Fill value above 255, and a number
# given to Append stop the Ring process; FromHex empties the buffer on a bad text. The examples were
# run on an identical copy of the class under another name.
#
#   receiver   o1 = new stzBytes("Hello")
#   example    ? o1.ToHex()
#              #--> 48656c6c6f
#              ? o1.Mid(2, 3)
#              #--> ell
#              o2 = new stzBytes("שלום")
#              ? o2.Size()
#              #--> 8
#              ? o2.ToPercent()
#              #--> %D7%A9%D7%9C%D7%95%D7%9D
#              o3 = new stzBytes("a😀b")
#              ? o3.ToHex()
#              #--> 61f09f988062
#   see        stzListOfBytes, stzString
class stzBytes from stzObject

	@pEngine = ""

	# Builds an engine-backed byte buffer holding the bytes of a text; any other value gives an empty buffer.
	#
	#   pData      the text whose bytes fill the buffer
	#   returns    nothing; the object is built
	#   note       the bytes are the text as stored, so a Hebrew letter is 2 bytes and an emoji 4
	#   warning    stzlib.ring does not load this file: new stzBytes(...) builds the alias of
	#              stzListOfBytes, which has no ByteAt (R14), and loading this file beside it raises
	#              C26 because both define a class named stzBytes
	#   see        Content, Size
	def init(pData)
		if isString(pData)
			if pData = ""
				@pEngine = StzEngineBytesNew()
			else
				@pEngine = StzEngineBytesFrom(pData)
			ok
		but isList(pData) and len(pData) = 0
			@pEngine = StzEngineBytesNew()
		else
			@pEngine = StzEngineBytesNew()
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the whole buffer as a text.
	#
	#   returns    a text
	#   see        Size, ToHex
	def Content()
		return StzEngineBytesData(@pEngine)

		def Data()
			return This.Content()

	# Returns how many bytes the buffer holds, not how many characters.
	#
	#   returns    a number
	#   note       NumberOfBytes and Count are the same call; the Hebrew word shalom is 8 bytes
	#   see        Content, IsEmpty
	def Size()
		return StzEngineBytesSize(@pEngine)

		def NumberOfBytes()
			return This.Size()

		def Count()
			return This.Size()

	# TRUE if the buffer holds no byte at all.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        Size, Clear
	def IsEmpty()
		return StzEngineBytesIsEmpty(@pEngine)

	# Returns the value of the byte at a position, from 0 to 255.
	#
	#   n          the 1-based position of the byte
	#   returns    a number; -1 for a position outside the buffer, including 0
	#   note       At is the same call; Hello at 2 gives 101
	#   see        Mid, Left
	def ByteAt(n)
		return StzEngineBytesAt(@pEngine, n)

		def At(n)
			return This.ByteAt(n)

	  #===============================#
	 #     SLICING                   #
	#===============================#

	# Returns the first bytes of the buffer as a text.
	#
	#   n          how many bytes to take from the start
	#   returns    a text; the whole buffer when n is larger than it
	#   note       the cut is by bytes, so 2 bytes of a Hebrew text are one letter and an odd count
	#              splits a letter
	#   warning    a negative n stops the Ring process with a Zig panic in stz_bytes.dll instead of
	#              returning an error
	#   see        Right, Mid
	def Left(n)
		return StzEngineBytesLeft(@pEngine, n)

	# Returns the last bytes of the buffer as a text.
	#
	#   n          how many bytes to take from the end
	#   returns    a text; the whole buffer when n is larger than it
	#   note       Right(0) gives an empty text
	#   warning    a negative n stops the Ring process with a Zig panic in stz_bytes.dll instead of
	#              returning an error
	#   see        Left, Mid
	def Right(n)
		return StzEngineBytesRight(@pEngine, n)

	# Returns a run of bytes starting at a position, as a text.
	#
	#   nStart     the 1-based position of the first byte
	#   nLen       how many bytes to take
	#   returns    a text; empty when nStart is 0 or past the end, and shorter when the run reaches
	#              the end
	#   note       Section is the same call; Mid(2, 3) of Hello is ell
	#   warning    a negative nLen stops the Ring process with a Zig panic in stz_bytes.dll; a
	#              negative nStart returns an empty text
	#   see        Left, Right
	def Mid(nStart, nLen)
		return StzEngineBytesMid(@pEngine, nStart, nLen)

		def Section(nStart, nLen)
			return This.Mid(nStart, nLen)

	  #===============================#
	 #     MODIFICATION              #
	#===============================#

	# Adds a text at the end of the buffer, in place.
	#
	#   cData      the text whose bytes are added
	#   returns    nothing; the buffer changes. AppendQ returns the object for chaining
	#   see        Insert, Content
	def Append(cData)
		StzEngineBytesAppend(@pEngine, cData)

		def AppendQ(cData)
			This.Append(cData)
			return This

	# Puts a text into the buffer in front of the byte at a position, in place.
	#
	#   nPos       the 1-based position the text goes in front of
	#   cData      the text to insert
	#   returns    nothing; the buffer changes. InsertQ returns the object for chaining
	#   note       Insert(1, "XY") on Hello gives XYHello
	#   warning    a position of 0, a negative one or one past the end plus one changes nothing and
	#              raises no error
	#   see        Append, Remove
	def Insert(nPos, cData)
		StzEngineBytesInsert(@pEngine, nPos, cData)

		def InsertQ(nPos, cData)
			This.Insert(nPos, cData)
			return This

	# Deletes a run of bytes starting at a position, in place.
	#
	#   nStart     the 1-based position of the first byte to delete
	#   nLen       how many bytes to delete
	#   returns    nothing; the buffer changes. RemoveQ returns the object for chaining
	#   note       Remove(6, 99) on abcdefg keeps abcde
	#   warning    a position of 0 or below changes nothing and raises no error
	#   see        Insert, Replace, Clear
	def Remove(nStart, nLen)
		StzEngineBytesRemove(@pEngine, nStart, nLen)

		def RemoveQ(nStart, nLen)
			This.Remove(nStart, nLen)
			return This

	# Overwrites a run of bytes with a text, in place; the text may be longer or shorter than the run.
	#
	#   nStart     the 1-based position of the first byte replaced
	#   nLen       how many bytes are replaced, up to the end
	#   cData      the text that takes their place
	#   returns    nothing; the buffer changes. ReplaceQ returns the object for chaining
	#   note       Replace(1, 2, "__") on Hello gives __llo
	#   warning    a negative nLen stops the Ring process with a Zig panic in stz_bytes.dll; a
	#              position past the end changes nothing
	#   see        Insert, Remove
	def Replace(nStart, nLen, cData)
		StzEngineBytesReplace(@pEngine, nStart, nLen, cData)

		def ReplaceQ(nStart, nLen, cData)
			This.Replace(nStart, nLen, cData)
			return This

	# Replaces the whole buffer with a number of copies of one byte value, in place.
	#
	#   nByte      the byte value, 0 to 255
	#   nCount     how many copies
	#   returns    nothing; the buffer changes. FillQ returns the object for chaining
	#   note       Fill(65, 3) gives AAA, and a count of 0 gives an empty buffer
	#   warning    the old content is dropped, not extended; a nByte above 255 or a negative nCount
	#              stops the Ring process with a Zig panic in stz_bytes.dll
	#   see        Resize, Clear
	def Fill(nByte, nCount)
		StzEngineBytesFill(@pEngine, nByte, nCount)

		def FillQ(nByte, nCount)
			This.Fill(nByte, nCount)
			return This

	# Cuts the buffer to a size, or pads it with zero bytes up to that size, in place.
	#
	#   nNewSize   the size in bytes the buffer will have
	#   returns    nothing; the buffer changes. ResizeQ returns the object for chaining
	#   note       Resize(5) on a 2 byte buffer adds three bytes of value 0
	#   warning    a negative size stops the Ring process with a Zig panic in stz_bytes.dll
	#   see        Fill, Size
	def Resize(nNewSize)
		StzEngineBytesResize(@pEngine, nNewSize)

		def ResizeQ(nNewSize)
			This.Resize(nNewSize)
			return This

	# Empties the buffer, in place.
	#
	#   returns    nothing; the buffer is empty. ClearQ returns the object for chaining
	#   see        IsEmpty, Free
	def Clear()
		StzEngineBytesClear(@pEngine)

		def ClearQ()
			This.Clear()
			return This

	  #===============================#
	 #     CASE CONVERSION           #
	#===============================#

	# Returns the buffer as a text with the ASCII capitals made small.
	#
	#   returns    a text; the buffer is not changed
	#   note       Hello Wörld gives hello wörld
	#   warning    only the 26 ASCII letters change: A with a diaeresis and the Hebrew letters stay
	#              as they are
	#   see        ToUpper
	def ToLower()
		return StzEngineBytesToLower(@pEngine)

	# Returns the buffer as a text with the ASCII small letters made capital.
	#
	#   returns    a text; the buffer is not changed
	#   note       Hello Wörld gives HELLO WöRLD
	#   warning    only the 26 ASCII letters change: o with a diaeresis stays small
	#   see        ToLower
	def ToUpper()
		return StzEngineBytesToUpper(@pEngine)

	  #===============================#
	 #     ENCODING                  #
	#===============================#

	# Returns the buffer as Base64 text, with = padding.
	#
	#   returns    a text; empty for an empty buffer
	#   note       Hello gives SGVsbG8=
	#   see        FromBase64, ToHex
	def ToBase64()
		return StzEngineBytesToBase64(@pEngine)

	# Replaces the buffer with the bytes a Base64 text stands for, in place.
	#
	#   cBase64    the Base64 text, padded with = to a multiple of 4
	#   returns    nothing; the buffer changes. FromBase64Q returns the object for chaining
	#   note       SGVsbG8= gives Hello
	#   warning    an invalid or unpadded text changes nothing and raises no error
	#   see        ToBase64, FromHex
	def FromBase64(cBase64)
		StzEngineBytesFromBase64(@pEngine, cBase64)

		def FromBase64Q(cBase64)
			This.FromBase64(cBase64)
			return This

	# Returns the buffer as lower case hexadecimal text, two digits per byte and no prefix.
	#
	#   returns    a text; empty for an empty buffer
	#   note       Hello gives 48656c6c6f; the Hebrew word shalom gives d7a9d79cd795d79d
	#   see        FromHex, ToBase64
	def ToHex()
		return StzEngineBytesToHex(@pEngine)

	# Replaces the buffer with the bytes a hexadecimal text stands for, in place.
	#
	#   cHex       the digits, two per byte, upper or lower case, with no prefix and no space
	#   returns    nothing; the buffer changes. FromHexQ returns the object for chaining
	#   note       48656c6c6f21 gives Hello!
	#   warning    a text with an odd count, a 0x prefix, a space or a non-digit EMPTIES the buffer
	#              and raises no error, whereas a bad Base64 text keeps it
	#   see        ToHex, FromBase64
	def FromHex(cHex)
		StzEngineBytesFromHex(@pEngine, cHex)

		def FromHexQ(cHex)
			This.FromHex(cHex)
			return This

	# Returns the buffer as percent-encoded text, every byte outside A-Z a-z 0-9 and - _ . ~ written as %XX.
	#
	#   returns    a text; the buffer is not changed
	#   note       a space becomes %20, o with a diaeresis %C3%B6 and the Hebrew letter shin %D7%A9
	#   see        FromPercent, ToHex
	def ToPercent()
		return StzEngineBytesToPercent(@pEngine)

	# Replaces the buffer with the bytes a percent-encoded text stands for, in place.
	#
	#   cPercent   the text, with %XX escapes
	#   returns    nothing; the buffer changes. FromPercentQ returns the object for chaining
	#   note       a%20b%C3%A9 gives a bé
	#   warning    a malformed escape such as %zz is kept as written and a + stays a +, not a space
	#   see        ToPercent, FromHex
	def FromPercent(cPercent)
		StzEngineBytesFromPercent(@pEngine, cPercent)

		def FromPercentQ(cPercent)
			This.FromPercent(cPercent)
			return This

	  #===============================#
	 #     LIFECYCLE                 #
	#===============================#

	# Releases the engine handle behind the buffer; the buffer then reads as empty.
	#
	#   returns    nothing
	#   note       calling it twice is harmless; there is no finalizer, so a program that builds
	#              many buffers should call it
	#   see        Clear
	def Free()
		if @pEngine != ""
			StzEngineBytesFree(@pEngine)
			@pEngine = ""
		ok
