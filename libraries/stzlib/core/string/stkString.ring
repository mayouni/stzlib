
#~~~~~~~~~~~~~~~~~~~#
#  STK CORE STRING  #
#~~~~~~~~~~~~~~~~~~~#

func StkReplaceCS(cStr, cSubStr, cNewSubStr, bCase)

	if bCase = TRUE
		return ring_substr2(cStr, cSubStr, cNewSubStr)
	ok

	cStrLow = lower(cStr)
	cSubStrLow = lower(cSubStr)
	cNewSubStrLow = lower(cNewSubStr)

	return ring_substr2(cStrLow, cSubStrLow, cNewSubStrLow)

func StkReplace(cStr, cSubStr, cNewSubStr)
	return StkReplaceCS(cStr, cSubStr, cNewSubStr, TRUE)

# Split function

func StkSplitCS(cStr, cSubStr, bCase)
	if cSubStr = "" return [cStr] ok

	cWork = cStr
	cSep = cSubStr
	if bCase = FALSE or bCase = 0
		cWork = lower(cStr)
		cSep = lower(cSubStr)
	ok

	acResult = []
	nSepLen = len(cSep)
	nPos = substr(cWork, cSep)

	nStart = 1
	while nPos > 0
		acResult + substr(cStr, nStart, nPos - nStart)
		nStart = nPos + nSepLen
		cWork = substr(cWork, nStart)
		cStr = substr(cStr, nStart)
		nStart = 1
		nPos = substr(cWork, cSep)
	end
	acResult + cStr
	return acResult

func StkSplit(cStr, cSubStr)
	return StkSplitCS(cStr, cSubStr, 0)

# Trim function

func StkTrim(cStr)
	return trim(cStr)


class stkString from stzCoreString

class stzCoreString from stzCoreObject

	@pEngine = NULL

	def init(str)
		if NOT isString(str)
			return StkError(:IncorrectPramType)
		ok
		@pEngine = StkEngineStringFrom(str)

	#--

	def Content()
		return StkEngineStringData(@pEngine)

	def Update(cStr)
		StkEngineStringFree(@pEngine)
		@pEngine = StkEngineStringFrom(cStr)

	#--

	def Size()
		return StkEngineStringSize(@pEngine)

		def Count()
			return This.Size()

		def NumberOfChars()
			return This.Size()

	#--

	def At(n)
		cContent = This.Content()
		if n > 0 and n <= len(cContent)
			return cContent[n]
		ok
		return ""

		def CharAt(n)
			return This.At(n)

	#-- APPENDING

	def Append(substr)
		if substr != ""
			StkEngineStringAppend(@pEngine, substr)
		ok

		def Add(substr)
			This.Append(substr)

	#-- FINDING

	def FindFirstCS(substr, bCase)
		if substr = ""
			return 0
		ok
		if bCase = TRUE or bCase = 1
			nPos = StkEngineStringIndexOf(@pEngine, substr)
			if nPos >= 0 return nPos + 1 ok
			return 0
		ok
		cContent = lower(This.Content())
		cNeedle = lower(substr)
		nPos = substr(cContent, cNeedle)
		return nPos

	def FindFirst(substr)
		if substr = ""
			return 0
		ok
		return This.FindFirstCS(substr, TRUE)

	#--

	def FindLastCS(cSub, bCase)
		if cSub = ""
			return 0
		ok
		cContent = This.Content()
		cNeedle = cSub
		if bCase = FALSE or bCase = 0
			cContent = lower(cContent)
			cNeedle = lower(cSub)
		ok
		nResult = 0
		nOffset = 0
		cWork = cContent
		nPos = substr(cWork, cNeedle)
		while nPos > 0
			nResult = nOffset + nPos
			cWork = substr(cWork, nPos + 1)
			nOffset = nResult
			nPos = substr(cWork, cNeedle)
		end
		return nResult

	def FindLast(substr)
		if substr = ""
			return 0
		ok
		return This.FindLastCS(substr, TRUE)

	#--

	def FindCS(cSub, bCase)
		if cSub = ""
			return [0]
		ok

		cContent = This.Content()
		cNeedle = cSub
		if bCase = FALSE or bCase = 0
			cContent = lower(cContent)
			cNeedle = lower(cSub)
		ok

		nSize = len(cNeedle)
		anResult = []
		nOffset = 0
		cWork = cContent
		nPos = substr(cWork, cNeedle)
		while nPos > 0
			anResult + (nOffset + nPos)
			cWork = substr(cWork, nPos + nSize)
			nOffset += (nPos + nSize - 1)
			nPos = substr(cWork, cNeedle)
		end
		return anResult

		def FindAllCS(substr, bCase)
			return This.FindCS(substr, bCase)

	def Find(substr)
		return This.FindCS(substr, TRUE)

		def FindAll(substr)
			return This.Find(substr)

	#--

	def FindNthCS(n, substr, bCase)
		if n < 0 or substr = ""
			return 0
		ok
		anAll = This.FindCS(substr, bCase)
		if n <= len(anAll) return anAll[n] ok
		return 0

	def FindNth(n, substr)
		return This.FindNthCS(n, substr, TRUE)

	#-- INSERTING

	def InsertAt(n, substr)
		if n > 0 and substr != ""
			cContent = This.Content()
			cNew = left(cContent, n-1) + substr + substr(cContent, n)
			This.Update(cNew)
		ok

	#== REPLACING

	def ReplaceCS(substr1, substr2, bCase)
		cResult = StkReplaceCS(This.Content(), substr1, substr2, bCase)
		This.Update(cResult)

	def Replace(substr1, substr2)
		This.ReplaceCS(substr1, substr2, TRUE)

	#--

	def ReplaceSection(n1, n2, substr)
		if n1 > 0 and n2 >= n1 and substr != ""
			cContent = This.Content()
			cNew = left(cContent, n1 - 1) + substr + substr(cContent, n2 + 1)
			This.Update(cNew)
		ok

	#== REMOVING

	def RemoveCS(substr, bCase)
		This.ReplaceCS(substr, "", bCase)

	def Remove(substr)
		This.Replace(substr, "")

	#--

	def RemoveSection(n1, n2)
		if n1 > 0 and n2 >= n1
			cContent = This.Content()
			cNew = left(cContent, n1 - 1) + substr(cContent, n2 + 1)
			This.Update(cNew)
		ok

	#== SPLITTING

	def SplitCS(cSubStr, bCase)
		acResult = StkSplitCS(This.Content(), cSubStr, bCase)
		return acResult

	def Split(substr)
		return This.SplitCS(substr, TRUE)

	#--

	def Section(n1, n2)
		if n1 > 0 and n2 >= n1
			cContent = This.Content()
			return substr(cContent, n1, n2 - n1 + 1)
		else
			raise( 'ERR-' + StkError(:IncorrectParamType) )
		ok

	#--

	def ContainsCS(substr, bCase)
		if substr = ""
			return FALSE
		ok
		if bCase = TRUE or bCase = 1
			return StkEngineStringContains(@pEngine, substr) = 1
		ok
		return substr(lower(This.Content()), lower(substr)) > 0

	def Contains(substr)
		if substr = ""
			return FALSE
		ok
		return This.ContainsCS(substr, TRUE)

	#==

	def StartsWithCS(substr, bCase)
		if substr = ""
			return FALSE
		ok
		if bCase = TRUE or bCase = 1
			return left(This.Content(), len(substr)) = substr
		ok
		return left(lower(This.Content()), len(substr)) = lower(substr)

	def StartsWith(substr)
		if substr = ""
			return FALSE
		ok
		return This.StartsWithCS(substr, TRUE)

	#--

	def EndsWithCS(substr, bCase)
		if substr = ""
			return FALSE
		ok
		if bCase = TRUE or bCase = 1
			return right(This.Content(), len(substr)) = substr
		ok
		return right(lower(This.Content()), len(substr)) = lower(substr)

	def EndsWith(substr)
		if substr = ""
			return FALSE
		ok
		return This.EndsWithCS(substr, TRUE)

	#--

	def Simplify()
		if This.Content() != ""
			cContent = This.Content()
			while substr(cContent, "  ") > 0
				cContent = ring_substr2(cContent, "  ", " ")
			end
			This.Update(StkTrim(cContent))
		ok

	#==

	def UnicodeAt(n)
		cContent = This.Content()
		if cContent = ""
			raise( "Can't proceed! Because the string is empty." )
		ok
		if n <= 0
			raise( 'ERR-' + StkError(:IncorrectParamType) )
		ok
		cChar = This.CharAt(n)
		return StkEngineCharUnicode(cChar)

		def UnicodeOfCharAt(n)
			return This.UnicodeAt(n)

	def Unicode()
		nLen = This.Size()
		if nLen = 0
			raise( "Can't proceed! Because the string is empty." )
		ok
		if nLen = 1
			return This.UnicodeAt(1)
		else
			return This.Unicodes()
		ok

	def Unicodes()
		nLen = This.Size()
		if nLen = 0
			raise( "Can't proceed! Because the string is empty." )
		ok
		anResult = []
		for i = 1 to nLen
			anResult + This.UnicodeAt(i)
		next
		return anResult

	def Chars()
		nLen = This.Size()
		if nLen = 0
			raise( "Can't proceed! Because the string is empty." )
		ok
		acResult = []
		for i = 1 to nLen
			acResult + This.CharAt(i)
		next
		return acResult

	#==

	def Operator(op, value)
		if op = "+"
			if value != ""
				This.Append(value)
			ok

		but op = "[]"
			return This.At(value)

		else
			raise( 'ERR-' + StkError(:UnsupportedOperator) )
		ok
