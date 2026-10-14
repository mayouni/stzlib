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

# Draws a text inside a box made of Unicode line characters, the whole text in one box or each character in its own cell.
#
# Build one with new stzStringBoxed("hello"); Boxed and BoxedChars return the drawing as a text and
# print nothing, and the text held never changes. The global function StzBoxedString(text) (also
# BoxedString) is the one-call form of Boxed. Several lines of text give several rows in the box,
# padded to the longest. BoxedChars draws a single row and its borders are mis-sized today, see its
# warning.
#
#   receiver   o1 = new stzStringBoxed("hello")
#   example    ? o1.Boxed()
#              #--> ╭───────╮
#              #--> │ hello │
#              #--> ╰───────╯
#              o2 = new stzStringBoxed("שלום")
#              ? o2.Boxed()
#              #--> ╭──────╮
#              #--> │ שלום │
#              #--> ╰──────╯
#   see        stzString, stzStringVisualizer, stzTile
class stzStringBoxed from stzObject

	@oString

	# Builds a boxed-text helper over a text or over a stzString object.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, to draw in a box
	#   returns           nothing; the object is built
	#   warning           any other kind of value raises "Can't create stzStringBoxed! Parameter
	#                     must be a string or stzString object."
	#   see               Boxed, BoxedChars
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringBoxed! Parameter must be a string or stzString object.")
		ok

	# Returns the text the helper holds, unchanged by drawing.
	#
	#   returns    a text
	#   note       Boxed and BoxedChars only return drawings, they never change it
	#   see        NumberOfChars
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting letters and not bytes.
	#
	#   returns    a number
	#   see        Content
	def NumberOfChars()
		return @oString.NumberOfChars()

	  #======================================================#
	 #   BOXED -- FULL STRING IN A BOX                      #
	#======================================================#

	# Returns the whole text drawn inside one box of Unicode lines, one row per line of the text, padded to the longest line.
	#
	#   returns    a text of several lines, with no newline at the end
	#   note       a text with no content draws an empty box of two lines; the width is counted in
	#              characters, so Hebrew, Arabic and emoji are measured by letter, and a wide emoji
	#              may still look misaligned on a console
	#   see        BoxedChars, Content
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

	# Returns the text drawn with each character in its own cell of a single row.
	#
	#   returns    a text of three lines: top border, the cells, bottom border
	#   note       the drawing needs a UTF-8 console
	#   warning    The borders do not match the cells today: each border cell is 4 dashes wide while
	#              each text cell is 3 characters wide, so the top and bottom lines are longer than
	#              the middle one and the dividers do not line up; an empty text falls back to Boxed
	#   see        Boxed
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
