
#~~~~~~~~~~~~~~~~~~~#
#  STK CORE STRING  #
#~~~~~~~~~~~~~~~~~~~#

func StkReplaceCS(_cStr_, cSubStr, cNewSubStr, bCase)

	if bCase = TRUE
		return ring_substr2(_cStr_, cSubStr, cNewSubStr)
	ok

	_cStrLow_ = lower(_cStr_)
	_cSubStrLow_ = lower(cSubStr)
	_cNewSubStrLow_ = lower(cNewSubStr)

	return ring_substr2(_cStrLow_, _cSubStrLow_, _cNewSubStrLow_)

func StkReplace(_cStr_, cSubStr, cNewSubStr)
	return StkReplaceCS(_cStr_, cSubStr, cNewSubStr, TRUE)

# Split function

func StkSplitCS(_cStr_, cSubStr, bCase)
	if cSubStr = "" return [_cStr_] ok

	_cWork_ = _cStr_
	_cSep_ = cSubStr
	if bCase = FALSE or bCase = 0
		_cWork_ = lower(_cStr_)
		_cSep_ = lower(cSubStr)
	ok

	_acResult_ = []
	_nSepLen_ = len(_cSep_)
	_nPos_ = substr(_cWork_, _cSep_)

	_nStart_ = 1
	while _nPos_ > 0
		_acResult_ + substr(_cStr_, _nStart_, _nPos_ - _nStart_)
		_nStart_ = _nPos_ + _nSepLen_
		_cWork_ = substr(_cWork_, _nStart_)
		_cStr_ = substr(_cStr_, _nStart_)
		_nStart_ = 1
		_nPos_ = substr(_cWork_, _cSep_)
	end
	_acResult_ + _cStr_
	return _acResult_

func StkSplit(_cStr_, cSubStr)
	return StkSplitCS(_cStr_, cSubStr, 0)

# Trim function

func StkTrim(_cStr_)
	return trim(_cStr_)


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

	def Update(_cStr_)
		StkEngineStringFree(@pEngine)
		@pEngine = StkEngineStringFrom(_cStr_)

	#--

	def Size()
		return StkEngineStringSize(@pEngine)

		def Count()
			return This.Size()

		def NumberOfChars()
			return This.Size()

	#--

	def At(n)
		_cContent_ = This.Content()
		if n > 0 and n <= len(_cContent_)
			return _cContent_[n]
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
			_nPos_ = StkEngineStringIndexOf(@pEngine, substr)
			if _nPos_ >= 0 return _nPos_ + 1 ok
			return 0
		ok
		_cContent_ = lower(This.Content())
		_cNeedle_ = lower(substr)
		_nPos_ = substr(_cContent_, _cNeedle_)
		return _nPos_

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
		_cContent_ = This.Content()
		_cNeedle_ = cSub
		if bCase = FALSE or bCase = 0
			_cContent_ = lower(_cContent_)
			_cNeedle_ = lower(cSub)
		ok
		_nResult_ = 0
		_nOffset_ = 0
		_cWork_ = _cContent_
		_nPos_ = substr(_cWork_, _cNeedle_)
		while _nPos_ > 0
			_nResult_ = _nOffset_ + _nPos_
			_cWork_ = substr(_cWork_, _nPos_ + 1)
			_nOffset_ = _nResult_
			_nPos_ = substr(_cWork_, _cNeedle_)
		end
		return _nResult_

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

		_cContent_ = This.Content()
		_cNeedle_ = cSub
		if bCase = FALSE or bCase = 0
			_cContent_ = lower(_cContent_)
			_cNeedle_ = lower(cSub)
		ok

		_nSize_ = len(_cNeedle_)
		_anResult_ = []
		_nOffset_ = 0
		_cWork_ = _cContent_
		_nPos_ = substr(_cWork_, _cNeedle_)
		while _nPos_ > 0
			_anResult_ + (_nOffset_ + _nPos_)
			_cWork_ = substr(_cWork_, _nPos_ + _nSize_)
			_nOffset_ += (_nPos_ + _nSize_ - 1)
			_nPos_ = substr(_cWork_, _cNeedle_)
		end
		return _anResult_

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
		_anAll_ = This.FindCS(substr, bCase)
		if n <= len(_anAll_) return _anAll_[n] ok
		return 0

	def FindNth(n, substr)
		return This.FindNthCS(n, substr, TRUE)

	#-- INSERTING

	def InsertAt(n, substr)
		if n > 0 and substr != ""
			_cContent_ = This.Content()
			_cNew_ = left(_cContent_, n-1) + substr + substr(_cContent_, n)
			This.Update(_cNew_)
		ok

	#== REPLACING

	def ReplaceCS(substr1, substr2, bCase)
		_cResult_ = StkReplaceCS(This.Content(), substr1, substr2, bCase)
		This.Update(_cResult_)

	def Replace(substr1, substr2)
		This.ReplaceCS(substr1, substr2, TRUE)

	#--

	def ReplaceSection(n1, n2, substr)
		if n1 > 0 and n2 >= n1 and substr != ""
			_cContent_ = This.Content()
			_cNew_ = left(_cContent_, n1 - 1) + substr + substr(_cContent_, n2 + 1)
			This.Update(_cNew_)
		ok

	#== REMOVING

	def RemoveCS(substr, bCase)
		This.ReplaceCS(substr, "", bCase)

	def Remove(substr)
		This.Replace(substr, "")

	#--

	def RemoveSection(n1, n2)
		if n1 > 0 and n2 >= n1
			_cContent_ = This.Content()
			_cNew_ = left(_cContent_, n1 - 1) + substr(_cContent_, n2 + 1)
			This.Update(_cNew_)
		ok

	#== SPLITTING

	def SplitCS(cSubStr, bCase)
		_acResult_ = StkSplitCS(This.Content(), cSubStr, bCase)
		return _acResult_

	def Split(substr)
		return This.SplitCS(substr, TRUE)

	#--

	def Section(n1, n2)
		if n1 > 0 and n2 >= n1
			_cContent_ = This.Content()
			return substr(_cContent_, n1, n2 - n1 + 1)
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
			_cContent_ = This.Content()
			while substr(_cContent_, "  ") > 0
				_cContent_ = ring_substr2(_cContent_, "  ", " ")
			end
			This.Update(StkTrim(_cContent_))
		ok

	#==

	def UnicodeAt(n)
		_cContent_ = This.Content()
		if _cContent_ = ""
			raise( "Can't proceed! Because the string is empty." )
		ok
		if n <= 0
			raise( 'ERR-' + StkError(:IncorrectParamType) )
		ok
		_cChar_ = This.CharAt(n)
		return StkEngineCharUnicode(_cChar_)

		def UnicodeOfCharAt(n)
			return This.UnicodeAt(n)

	def Unicode()
		_nLen_ = This.Size()
		if _nLen_ = 0
			raise( "Can't proceed! Because the string is empty." )
		ok
		if _nLen_ = 1
			return This.UnicodeAt(1)
		else
			return This.Unicodes()
		ok

	def Unicodes()
		_nLen_ = This.Size()
		if _nLen_ = 0
			raise( "Can't proceed! Because the string is empty." )
		ok
		_anResult_ = []
		for i = 1 to _nLen_
			_anResult_ + This.UnicodeAt(i)
		next
		return _anResult_

	def Chars()
		_nLen_ = This.Size()
		if _nLen_ = 0
			raise( "Can't proceed! Because the string is empty." )
		ok
		_acResult_ = []
		for i = 1 to _nLen_
			_acResult_ + This.CharAt(i)
		next
		return _acResult_

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
