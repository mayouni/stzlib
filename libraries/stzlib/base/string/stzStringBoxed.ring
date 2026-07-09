#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGBOXED              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String boxed display -- draws Unicode box   #
#                  borders around string content.               #
#                  Wraps stzString via composition.             #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzBoxedString(str)
	_oStr_ = new stzStringBoxed(str)
	return _oStr_.Boxed()

	func BoxedString(str)
		return StzBoxedString(str)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringBoxed from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringBoxed! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	  #======================================================#
	 #   BOXED -- FULL STRING IN A BOX                      #
	#======================================================#

	def Boxed()
		_cContent_ = @oString.Content()

		# Split into lines using engine
		_oLines_ = new stzStringLines(@oString)
		_nLines_ = _oLines_.NumberOfLines()

		# Find max line length (codepoint-aware)
		_nMaxLen_ = 0
		for i = 1 to _nLines_
			_cLine_ = _oLines_.NthLine(i)
			_oLine_ = new stzString(_cLine_)
			_nLen_ = _oLine_.NumberOfChars()
			if _nLen_ > _nMaxLen_
				_nMaxLen_ = _nLen_
			ok
		next

		# Build box using Unicode box-drawing chars
		_cHBar_ = ""
		for i = 1 to _nMaxLen_ + 2
			_cHBar_ += "─"
		next

		_cResult_ = "╭" + _cHBar_ + "╮" + StzChar(10)

		for i = 1 to _nLines_
			_cLine_ = _oLines_.NthLine(i)
			_oLine_ = new stzString(_cLine_)
			_nLen_ = _oLine_.NumberOfChars()
			_cPad_ = ""
			for j = 1 to _nMaxLen_ - _nLen_
				_cPad_ += " "
			next
			_cResult_ += "│ " + _cLine_ + _cPad_ + " │" + StzChar(10)
		next

		_cResult_ += "╰" + _cHBar_ + "╯"
		return _cResult_

	  #======================================================#
	 #   BOXED CHARS -- EACH CHAR IN ITS OWN CELL           #
	#======================================================#

	def BoxedChars()
		_cContent_ = @oString.Content()
		if _cContent_ = ""
			return This.Boxed()
		ok

		_nLen_ = @oString.NumberOfChars()

		# Build middle line: │ c1 │ c2 │ c3 │
		_cMiddle_ = "│ "
		for i = 1 to _nLen_
			_cMiddle_ += @oString.NthChar(i) + " │"
			if i < _nLen_
				_cMiddle_ += " "
			ok
		next

		# Build top/bottom lines with separators
		_cTop_ = "╭"
		_cBottom_ = "╰"
		for i = 1 to _nLen_
			_cTop_ += "────"
			_cBottom_ += "────"
			if i < _nLen_
				_cTop_ += "┬"
				_cBottom_ += "┴"
			ok
		next
		_cTop_ += "╮"
		_cBottom_ += "╯"

		return _cTop_ + StzChar(10) + _cMiddle_ + StzChar(10) + _cBottom_
