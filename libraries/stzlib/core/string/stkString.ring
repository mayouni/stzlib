# Requires Engine or LightGuiLib

#~~~~~~~~~~~~~~~~~~~#
#  STZ CORE STRING  #
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
	return StzReplaceCS(cStr, cSubStr, cNewSubStr, TRUE)

# Split function

func StkSplitCS(cStr, cSubStr, bCase)
	if isGlobal(:$STZ_ENGINE_LOADED) and $STZ_ENGINE_LOADED = TRUE
		# Engine path: use Ring's built-in substr for splitting
		# (Engine handles the string ops, but split is pure Ring logic)
		return _StkSplitPure(cStr, cSubStr, bCase)
	ok

	# Qt fallback
	oQStr = new QString2()
	oQStr.append(cStr)

	oQStrList = oQStr.split(cSubStr, 0, bCase)

	acResult = []
	for i = 0 to oQStrList.size()-1
		acResult + oQStrList.at(i)
	next

	return acResult

func _StkSplitPure(cStr, cSubStr, bCase)
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
		nPos = substr(cWork, cSep, nStart)
	end
	acResult + substr(cStr, nStart)
	return acResult

func StkSplit(cStr, cSubStr)
	return StkSplitCS(cStr, cSubStr, 0)

# Trim function

func StkTrim(cStr)
	if isGlobal(:$STZ_ENGINE_LOADED) and $STZ_ENGINE_LOADED = TRUE
		return trim(cStr)
	ok

	oQStr = new QString2()
	oQStr.append(cStr)

	cResult = oQStr.trimmed()
	return cResult


class stkString from stzCoreString

class stzCoreString from stzCoreObject

	# Internal storage: either an Engine handle (pointer) or a Qt object
	@content
	@pEngine = NULL  # Engine handle when using Engine mode

	def init(str)
		if NOT isString(str)
			return StkError(:IncorrectPramType)
		ok

		if isGlobal(:$STZ_ENGINE_LOADED) and $STZ_ENGINE_LOADED = TRUE
			# Engine mode
			@pEngine = CallCFunc($pEngineHandle, "stz_string_from", "p", "pi", str, len(str))
			@content = str
		else
			# Qt mode
			@content = new QString2()
			@content.append(str)
		ok

	def _IsEngine()
		return @pEngine != NULL

	#--

	def Content()
		if This._IsEngine()
			nSize = CallCFunc($pEngineHandle, "stz_string_size", "i", "p", @pEngine)
			if nSize = 0 return "" ok
			pData = CallCFunc($pEngineHandle, "stz_string_data", "p", "p", @pEngine)
			return copy(pData, nSize)
		ok
		return @content.mid(0, @content.size())

	def Update(cStr)
		if This._IsEngine()
			# Free old, create new
			CallCFunc($pEngineHandle, "stz_string_free", "v", "p", @pEngine)
			@pEngine = CallCFunc($pEngineHandle, "stz_string_from", "p", "pi", cStr, len(cStr))
			return
		ok
		cContent = This.Content()
		cNewContent = ring_substr2(cContent, cContent, cStr)
		@content.replace_2(cContent, cNewContent, 1)

	#--

	def Size()
		if This._IsEngine()
			return CallCFunc($pEngineHandle, "stz_string_size", "i", "p", @pEngine)
		ok
		return @content.size()

		def Count()
			return This.Size()

		def NumberOfChars()
			return This.Size()

	#--

	def At(n)
		if This._IsEngine()
			# mid(n-1, 1) equivalent
			pMid = CallCFunc($pEngineHandle, "stz_string_mid", "p", "pii", @pEngine, n-1, 1)
			pData = CallCFunc($pEngineHandle, "stz_string_data", "p", "p", pMid)
			cResult = copy(pData, 1)
			CallCFunc($pEngineHandle, "stz_string_free", "v", "p", pMid)
			return cResult
		ok
		return @content.mid(n-1, 1)

		def CharAt(n)
			return This.At(n)

	#-- APPENDING

	def Append(substr)
		if substr != ""
			if This._IsEngine()
				CallCFunc($pEngineHandle, "stz_string_append", "v", "ppi",
				          @pEngine, substr, len(substr))
				return
			ok
			@content.append(substr)
		ok

		def Add(substr)
			This.Append(substr)

	def AppendQChar(q)
		if This._IsEngine()
			return
		ok
		@content.append_2(q)

	#-- FINDING

	def FindFirstCS(substr, bCase)
		if substr = ""
			return 0
		ok
		if This._IsEngine()
			if bCase = TRUE or bCase = 1
				nPos = CallCFunc($pEngineHandle, "stz_string_index_of", "i", "ppi",
				                 @pEngine, substr, len(substr))
				if nPos >= 0 return nPos + 1 ok
				return 0
			ok
			# Case-insensitive: search in lowered copies
			cContent = lower(This.Content())
			cNeedle = lower(substr)
			nPos = substr(cContent, cNeedle)
			return nPos
		ok
		return @content.indexOf(substr, 0, bCase) + 1

	def FindFirst(substr)
		if substr = ""
			return 0
		ok
		return This.FindFirstCS(substr, TRUE)

	#--

	def FindLastCS(substr, bCase)
		if substr = ""
			return 0
		ok
		if This._IsEngine()
			if bCase = TRUE or bCase = 1
				nPos = CallCFunc($pEngineHandle, "stz_string_last_index_of", "i", "ppi",
				                 @pEngine, substr, len(substr))
				if nPos >= 0 return nPos + 1 ok
				return 0
			ok
			# Case-insensitive fallback
			cContent = lower(This.Content())
			cNeedle = lower(substr)
			nResult = 0
			nPos = substr(cContent, cNeedle)
			while nPos > 0
				nResult = nPos
				nPos = substr(cContent, cNeedle, nPos + 1)
			end
			return nResult
		ok
		return @content.lastIndexOf(substr, @content.size()-1, bCase) + 1

	def FindLast(substr)
		if substr = ""
			return 0
		ok
		return This.FindLastCS(substr, TRUE)

	#--

	def FindCS(substr, bCase)
		if substr = ""
			return [0]
		ok

		if This._IsEngine()
			cContent = This.Content()
			cNeedle = substr
			if bCase = FALSE or bCase = 0
				cContent = lower(cContent)
				cNeedle = lower(substr)
			ok

			nSize = len(cNeedle)
			anResult = []
			nPos = substr(cContent, cNeedle)
			while nPos > 0
				anResult + nPos
				nPos = substr(cContent, cNeedle, nPos + nSize)
			end
			return anResult
		ok

		@TempQStr = new QString2()
		@TempQStr.append(substr)
		nSize = @TempQStr.size()

		anResult = []
		bContinue = TRUE

		nPos = 0

	   	while bContinue
			nPos = @content.indexOf(substr, nPos, bCase)
			if nPos = -1
				bContinue = FALSE
			else
				anResult + (nPos + 1)
				nPos = nPos + nSize
			ok
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

		if This._IsEngine()
			anAll = This.FindCS(substr, bCase)
			if n <= len(anAll) return anAll[n] ok
			return 0
		ok

		@TempQStr = new QString2()
		@TempQStr.append(substr)
		nSize = @TempQStr.size()

		nResult = 0
		bContinue = TRUE

		nPos = 0
		nTimes = 0

	   	while bContinue
			nPos = @content.indexOf(substr, nPos, bCase)
			if nPos = -1
				bContinue = FALSE
			else
				nTimes++
				if nTimes = n
					nResult = nPos + 1
					exit
				ok

				nPos = nPos + nSize
			ok
		end

		return nResult

	def FindNth(n, substr)
		return This.FindNthCS(n, substr, TRUE)

	#-- INSERTING

	def InsertAt(n, substr)
		if n > 0 and substr != ""
			if This._IsEngine()
				CallCFunc($pEngineHandle, "stz_string_insert", "v", "pipi",
				          @pEngine, n-1, substr, len(substr))
				return
			ok
			@content.insert(n-1, substr)
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
			if This._IsEngine()
				cContent = This.Content()
				cNew = left(cContent, n1 - 1) + substr + substr(cContent, n2 + 1)
				This.Update(cNew)
				return
			ok
			@content.replace( n1 - 1, n2 - n1 + 1, substr)
		ok

	#== REMOVING

	def RemoveCS(substr, bCase)
		This.ReplaceCS(substr, "", bCase)

	def Remove(substr)
		This.Replace(substr, "")

	#--

	def RemoveSection(n1, n2)
		if n1 > 0 and n2 >= n1
			if This._IsEngine()
				cContent = This.Content()
				cNew = left(cContent, n1 - 1) + substr(cContent, n2 + 1)
				This.Update(cNew)
				return
			ok
			@content.replace(n1 - 1, n2 - n1 + 1, "")
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
			if This._IsEngine()
				nLen = n2 - n1 + 1
				pMid = CallCFunc($pEngineHandle, "stz_string_mid", "p", "pii",
				                 @pEngine, n1-1, nLen)
				nSize = CallCFunc($pEngineHandle, "stz_string_size", "i", "p", pMid)
				pData = CallCFunc($pEngineHandle, "stz_string_data", "p", "p", pMid)
				cResult = copy(pData, nSize)
				CallCFunc($pEngineHandle, "stz_string_free", "v", "p", pMid)
				return cResult
			ok
			return @content.mid(n1-1, n2 - n1 + 1)
		else
			raise( 'ERR-' + StkError(:IncorrectParamType) )
		ok

	#--

	def ContainsCS(substr, bCase)
		if substr = ""
			return FALSE
		ok

		if This._IsEngine()
			if bCase = TRUE or bCase = 1
				nResult = CallCFunc($pEngineHandle, "stz_string_contains", "i", "ppi",
				                    @pEngine, substr, len(substr))
				return nResult = 1
			ok
			return substr(lower(This.Content()), lower(substr)) > 0
		ok

		return @content.contains(substr, bCase)

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

		if This._IsEngine()
			if bCase = TRUE or bCase = 1
				nResult = CallCFunc($pEngineHandle, "stz_string_starts_with", "i", "ppi",
				                    @pEngine, substr, len(substr))
				return nResult = 1
			ok
			return left(lower(This.Content()), len(substr)) = lower(substr)
		ok

		return @content.startsWith(substr, bCase)

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

		if This._IsEngine()
			if bCase = TRUE or bCase = 1
				nResult = CallCFunc($pEngineHandle, "stz_string_ends_with", "i", "ppi",
				                    @pEngine, substr, len(substr))
				return nResult = 1
			ok
			return right(lower(This.Content()), len(substr)) = lower(substr)
		ok

		return @content.endsWith(substr, bCase)

	def EndsWith(substr)
		if substr = ""
			return FALSE
		ok
		return This.EndsWithCS(substr, TRUE)

	#--

	def IsRightToLeft()
		if This._IsEngine()
			return FALSE
		ok
		return @content.IsRighttoLeft()

	#--

	def Simplify()
		if This.Content() != ""
			if This._IsEngine()
				cContent = This.Content()
				# Replace multiple whitespace with single space and trim
				while substr(cContent, "  ") > 0
					cContent = ring_substr2(cContent, "  ", " ")
				end
				This.Update(trim(cContent))
				return
			ok
			cSimplified = @content.simplified()
			oTempQStr = new QString2()
			oTempQStr.append(cSimplified)

			@content = oTempQStr
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

		if This._IsEngine()
			cChar = This.CharAt(n)
			nResult = CallCFunc($pEngineHandle, "stz_char_unicode", "i", "p", cChar)
			return nResult
		ok

		oTempQStr = new QString2()
		oTempQStr.append(This.CharAt(n))
		nResult = oTempQStr.unicode().unicode()
		return nResult

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

	def QStringObject()
		if This._IsEngine()
			return NULL
		ok
		return @content

		def Qt()
			return This.QStringObject()

	def ToQCharObject(n)
		if This._IsEngine()
			return NULL
		ok
		return new QChar(This.UnicodeAt(n))

		def ToQChar(n)
			return This.ToQCharObject(n)

		def QCharObject(n)
			return This.ToQCharObject(n)

		def QChar(n)
			return This.ToQCharObject(n)

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
