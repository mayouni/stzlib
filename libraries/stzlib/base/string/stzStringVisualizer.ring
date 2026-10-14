#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STZSTRINGVISUALIZER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String visualizer -- Show(), VizFind(),     #
#                  Boxed(), and visual rendering operations.   #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringVisualizerXT.     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Makes a text visible: prints it, marks where a character or substring occurs, frames it in a box, or wraps matches in markers.
#
# Build one with new stzStringVisualizer("text"); it only reads, so a stzString passed in is never
# changed. Show, ShowShort and ShowNL print; VizFindChar, VizFind, Boxed, BoxedRounded, Stringify
# and Highlight return a text; EachCharBoxed returns a list of small boxes. The boxes use plain
# ASCII characters (dots, dashes and bars), so they print on any console, unlike the Unicode frames
# of stzStringBoxed. Widths count characters, so Hebrew, Arabic and emoji are measured by letter.
#
#   receiver   o1 = new stzStringVisualizer("banana band")
#   example    ? o1.VizFind("an")
#              #--> "banana band"
#              #-->  -^^^^---^^-
#              ? o1.Highlight("an", "*")
#              #--> b*an**an*a b*an*d
#              ? o1.Stringify()
#              #--> "banana band"
#   see        stzStringBoxed, stzString, stzStringFinder
class stzStringVisualizer from stzObject

	@oString

	# Builds a visualizer over a text or over a stzString object, to print it, mark things in it or frame it.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, to display
	#   returns           nothing; the object is built
	#   warning           any other kind of value raises "Can't create stzStringVisualizer!
	#                     Parameter must be a string or stzString object."; the visualizer only
	#                     reads, so a stzString passed in is never changed
	#   see               Show, Boxed
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringVisualizer! Parameter must be a string or stzString object.")
		ok

	# Returns the text the visualizer holds.
	#
	#   returns    a text
	#   see        Stringify
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting letters and not bytes.
	#
	#   returns    a number
	#   see        Content
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text is empty.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfChars
	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     SHOW                      #
	#===============================#

	# Prints the text on the console.
	#
	#   returns    nothing
	#   see        ShowShort, ShowNL
	def Show()
		? @oString.Content()

	# Prints the text on the console, cut to its first 47 characters followed by three dots when it is longer than 50.
	#
	#   returns    nothing
	#   note       a text of exactly 50 characters is printed whole, one of 51 is cut
	#   see        Show
	def ShowShort()
		_nLen_ = @oString.NumberOfChars()
		if _nLen_ <= 50
			? @oString.Content()
		else
			? @oString.Section(1, 47) + "..."
		ok

	# Prints the text on the console followed by an extra empty line.
	#
	#   returns    nothing
	#   see        Show
	def ShowNL()
		? @oString.Content() + char(10)

	  #===============================#
	 #     VIZFIND                   #
	#===============================#

	def VizFindCharCS(_c_, pCaseSensitive)
		if NOT ( isString(_c_) and StzLen(_c_) = 1 )
			return ""
		ok

		_cResult_ = @@( @oString.Content() )
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindCS(_c_, pCaseSensitive)

		_nChars_ = @oString.NumberOfChars()

		_cViz_ = " "
		for i = 1 to _nChars_
			if StzFindFirst(i, _anPos_) > 0
				_cViz_ += "^"
			else
				_cViz_ += "-"
			ok
		next

		return _cResult_ + char(10) + _cViz_

	# Returns the text in quotes with a second line of carets under every place the given character occurs.
	#
	#   _c_        the one character to mark
	#   returns    a text of two lines; "" when the argument is not a single character
	#   note       VizFindCharCS(c, 0) ignores case; the carets line starts with a space to sit
	#              under the opening quote
	#   see        VizFind, VizFindCharCS
	def VizFindChar(_c_)
		return This.VizFindCharCS(_c_, 1)

	def VizFindCS(pcSubStr, pCaseSensitive)
		_cResult_ = @@( @oString.Content() )
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindCS(pcSubStr, pCaseSensitive)

		_nSubLen_ = StzLen(pcSubStr)
		_nChars_ = @oString.NumberOfChars()

		_cViz_ = " "
		for i = 1 to _nChars_
			_bMarked_ = 0
			_nPosLen_ = len(_anPos_)
			for j = 1 to _nPosLen_
				if i >= _anPos_[j] and i < _anPos_[j] + _nSubLen_
					_bMarked_ = 1
					exit
				ok
			next

			if _bMarked_
				_cViz_ += "^"
			else
				_cViz_ += "-"
			ok
		next

		return _cResult_ + char(10) + _cViz_

	# Returns the text in quotes with a second line of carets under every character covered by an occurrence of a substring.
	#
	#   pcSubStr   the substring to mark
	#   returns    a text of two lines
	#   note       "banana band" with "an" marks the 2nd to 5th and the 9th to 10th characters;
	#              overlapping matches are all marked; an absent or empty substring marks nothing;
	#              VizFindCS(s, 0) ignores case
	#   see        VizFindChar, Highlight
	def VizFind(pcSubStr)
		return This.VizFindCS(pcSubStr, 1)

	  #===============================#
	 #     BOXED                     #
	#===============================#

	# Returns the text in a box drawn with plain ASCII characters, with round corners drawn as dots.
	#
	#   returns    a text of three lines
	#   note       a text with a line break keeps its break inside the box instead of framing each
	#              line, and the width is the whole character count; for Unicode lines see
	#              stzStringBoxed
	#   see        BoxedXT, BoxedRounded, EachCharBoxed
	def Boxed()
		return This.BoxedXT([ :Line = :Thin, :AllCorners = :Round ])

	def BoxedXT(paOptions)
		_cContent_ = @oString.Content()
		_nLen_ = @oString.NumberOfChars()

		_cCorner_ = "+"
		_cHLine_ = "-"
		_cVLine_ = "|"

		if isList(paOptions)
			_nOptLen_ = len(paOptions)
			for i = 1 to _nOptLen_
				if isList(paOptions[i])
					if len(paOptions[i]) = 2
						if paOptions[i][1] = :AllCorners
							if paOptions[i][2] = :Round
								_cCorner_ = "."
							ok
						ok
						if paOptions[i][1] = :Line
							if paOptions[i][2] = :Dashed
								_cHLine_ = "-"
								_cVLine_ = ":"
							ok
						ok
					ok
				ok
			next
		ok

		_cTop_ = _cCorner_ + ""
		for i = 1 to _nLen_ + 2
			_cTop_ += _cHLine_
		next
		_cTop_ += _cCorner_

		_cMid_ = _cVLine_ + " " + _cContent_ + " " + _cVLine_
		_cBot_ = _cCorner_ + ""
		for i = 1 to _nLen_ + 2
			_cBot_ += _cHLine_
		next
		_cBot_ += _cCorner_

		return _cTop_ + char(10) + _cMid_ + char(10) + _cBot_

	# Returns the text in a box of plain characters with round corners, the same as Boxed.
	#
	#   returns    a text of three lines
	#   see        Boxed
	def BoxedRounded()
		return This.BoxedXT([ :Line = :Thin, :AllCorners = :Round ])

	  #===============================#
	 #     CHARS BOXED               #
	#===============================#

	# Returns a list holding one small box per character of the text, in order.
	#
	#   returns    a list of three-line texts; [ ] for an empty text
	#   note       a space gets a box too
	#   see        Boxed
	def EachCharBoxed()
		_acResult_ = []
		_cContent_ = @oString.Content()
		_nLen_ = @oString.NumberOfChars()

		for i = 1 to _nLen_
			_c_ = @oString.NthChar(i)
			_oViz_ = new stzStringVisualizer(_c_)
			_acResult_ + _oViz_.Boxed()
		next

		return _acResult_

	  #===============================#
	 #     STRINGIFICATION           #
	#===============================#

	# Returns the text as a Ring literal, in quotes and with embedded quotes kept in view.
	#
	#   returns    a text
	#   note       a text that holds a double quote is wrapped in single quotes: he said "hi" gives
	#              'he said "hi"'; a text that holds both kinds is not escaped
	#   see        Content
	def Stringify()
		return @@(@oString.Content())

	  #===============================#
	 #     HIGHLIGHTED               #
	#===============================#

	def HighlightCS(pcSubStr, pcMarker, pCaseSensitive)
		_cContent_ = @oString.Content()
		_cResult_ = @ReplaceCS(_cContent_, pcSubStr, pcMarker + pcSubStr + pcMarker, pCaseSensitive)
		return _cResult_

	# Returns the text with every occurrence of a substring wrapped in a marker, case-sensitively.
	#
	#   pcSubStr   the substring to mark
	#   pcMarker   the text put before and after each occurrence
	#   returns    a text
	#   note       "banana band" with "an" and "*" gives b*an**an*a b*an*d; an empty marker or an
	#              absent substring changes nothing; HighlightCS(s, m, 0) ignores case
	#   see        VizFind
	def Highlight(pcSubStr, pcMarker)
		return This.HighlightCS(pcSubStr, pcMarker, 1)
