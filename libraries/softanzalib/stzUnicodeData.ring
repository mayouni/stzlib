// Source: https://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt
/*
	Fields separated by (details here http://www.unicode.org/L2/L1999/UnicodeData.html):

	01. Code value
	02. Character name
	03. General category
	04. Canonical combining classes
	05. Bidirectional category
	06. Character decomposition mapping
	07. Decimal digit value
	08. Digit value
	09. Numeric value
	10. Mirrored
	11. Unicode 1.0 Name
	12. 10646 comment field()
	13. Uppercase mapping
	14. Lowercase mapping
	15. Titlecase mapping

TODO: understand and include this resource (if necessary):
https://www.unicode.org/Public/UCD/latest/ucd/NameAliases.txt
*/

_nNumberOfUnicodeChars = 149_186

_nMaxUnicode = 1_114_112

_cUnicodeData = read("stzUnicodeData.txt")

func UnicodeData()
	return _cUnicodeData
	
	func StzUnicodeDataQ()
		return new stzUnicodeData()

	func UnicodeDataAsString()
		return UnicodeData()

		func UnicodeDataAsStringQ()
			return new stzUnicodeDataAsString()

func MaxUnicode()
	return _nMaxUnicode

	func LastUnicode()
		return MaxUnicode()

	func MaxUnicodeNumber()
		return MaxUnicode()

func NumberOfUnicodeChars()
	return _nNumberOfUnicodeChars

class stzUnicodeDataAsString from stzUnicodeData

class stzUnicodeData
	@oStzStrUnicodeData

	def init()
		@oStzStrUnicodeData = new stzString( UnicodeData() )

	def ContainsCharName(pcCharName)
		if This.FindCharName(pcCharName) > 0
			return TRUE
		else
			return FALSE
		ok

		def ContainsName(pcCharName)
			return This.ContainsCharName()

	def FindCharName(pcCharName)
		if NOT isString(pcCharName)
			StzRaise("Incorrect param type! pcCharName must be a string.")
		ok

		pcCharName = Q(pcCharName).Uppercased()

		nPos = @oStzStrUnicodeData.FindFirstCS( pcCharName, :CS = FALSE )
		return nPos

		def FindcharByName(pcCharName)
			return This.FindCharName(pcCharName)

	def SearchCharName(pcCharName)
		return @oStzStrUnicodeData.FindAllCS( pcCharName, :CS = FALSE )

		def SearchForCharName(pcCharName)
			return SearchCharName(pcCharName)

		def SearchCharByName(pcCharName)
			return SearchCharName(pcCharName)


	def CharByName(pcCharName)
		cHex = This.CharHexCodeByName(pcCharName)
		nUnicode = HexToDecimal( cHex )

		cChar = StzCharQ(nUnicode).Content()
		return cChar

	def CharHexCodeByName(pcCharName)
		n = This.FindCharName(";"+ pcCharName + ";")

		if n > 0
			n2 = n - 1
			n1 = @oStzStrUnicodeData.PreviousOccurrence(NL, n) + 1
			cHex = HexPrefix() + @oStzStrUnicodeData.Section(n1, n2)

			return cHex
		ok

	def CharUnicodeByName(pcCharName)
		return StzHexNumberQ( This.CharHexCodeByName(pcCharName) ).ToDecimal()

		def CharDecimalCodeByName(pcCharName)
			return This.CharUnicodeByName(pcCharName)

	def CharByHexCode(pcHex)
		cHex = StzHexNumberQ(pcHex).WithoutPrefix()
		if @oStzStrUnicodeData.Contains(NL + cHex + ";")
			nUnicode = StzHexNumberQ(pcHex).ToDecimal()
			return StzCharQ(nUnicode).Content()
		ok

	def CharByUnicode(nUnicode)
		cHex = StzNumberQ(nUnicode).ToHex()
		return This.CharByHexCode(cHex)

		def CharByDecimalCode(nUnicode)
			return This.CharByUnicode(nUnicode)

	def CharNameByHexCode(pcHex)

		cHex = StzHexNumberQ(pcHex).WithoutPrefix()

		if cHex = ""
			return NULL
		ok

		switch len(cHex)
		on 3
			cHex = "0" + cHex
		on 2
			cHex = "00" + cHex
		on 1
			cHex = "000" + cHex
		off


		n = @oStzStrUnicodeData.FindFirst(NL + cHex + ";")
		
		if n = 0
			return NULL
		ok

		n++	# To compensate the NL

		# Defininging start of the char name in n1

		bContinue = TRUE
		i = 0

		while bContinue
			i++
			c = @oStzStrUnicodeData[n + i]

			if c = ";"
				n1 = n + i + 1
				bContinue = FALSE
			ok
		end

		# Defininging end of the char name in n2
		n = n1
		bContinue = TRUE
		i = 0

		while bContinue
			i++
			c = @oStzStrUnicodeData[n + i]

			if c = ";"
				n2 = n + i - 1
				bContinue = FALSE
			ok
		end

		
		cResult = @oStzStrUnicodeData.Section(n1, n2)
		return cResult

	def CharNameByUnicode(nUnicode)
		cHex = StzNumberQ(nUnicode).ToHex()
		cResult = This.CharNameByHexCode(cHex)
		return cResult

	def CharsContaining(pcCharName)
		anUnicodes = This.SearchCharByName(pcCharName)
		acResult = StzListOfCharsQ(anUnicodes).Content()

		return acResult

	def CharsNamesContaining(pcCharName)
		anUnicodes = This.SearchCharName(pcCharName)
		aResult = UnicodesToCharsNames(anUnicodes)
		return aResult
