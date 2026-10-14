#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGTRIMMER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String trimmer -- Wraps stzString via       #
#                  composition. Trimming whitespace and chars  #
#                  from strings.                               #
#                  For aliases, use stzStringTrimmerXT.        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Trims a text: white space at its ends, or a chosen character repeated at its start, its end or both.
#
# Build one with new stzStringTrimmer("  text  "). Trim, TrimLeft and TrimRight (and their aliases
# TrimStart and TrimEnd) strip white space; TrimChar, TrimCharFromStart and TrimCharFromEnd strip
# one given character, whole letters, so Hebrew, Arabic and emoji work. Each in-place verb changes
# the text held and has a passive twin that returns the trimmed text (Trimmed, TrimmedLeft,
# CharTrimmed ...). The Left and Right forms of TrimChar are meant to follow the writing direction
# and do not today. Do not pass a stzString object you still need: the first in-place trim empties
# it.
#
#   receiver   o1 = new stzStringTrimmer("  hello world  ")
#   example    ? o1.Trimmed()
#              #--> hello world
#              ? o1.TrimmedLeft()
#              #--> hello world  
#              o2 = new stzStringTrimmer("--a-b--")
#              ? o2.CharTrimmed("-")
#              #--> a-b
#              o3 = new stzStringTrimmer("😀😀שלום😀")
#              ? o3.CharTrimmed("😀")
#              #--> שלום
#   see        stzString, stzListTrimmer, stzStringAligner
class stzStringTrimmer from stzObject

	@oString

	# Builds a trimmer over a text or over a stzString object, to strip spaces or a chosen character from its ends.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, to trim
	#   returns           nothing; the object is built
	#   note              any other kind of value raises "Can't create stzStringTrimmer! Parameter
	#                     must be a string or stzString object."
	#   warning           Given a stzString object, the first in-place trim (Trim, TrimLeft,
	#                     TrimRight, TrimStart, TrimEnd, TrimChar and the other TrimChar forms)
	#                     leaves that stzString EMPTY while the trimmer holds the result; the
	#                     passive forms (Trimmed ...) do not. Pass the text, os.Content(), to be
	#                     safe
	#   see               Trim, TrimChar
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringTrimmer! Parameter must be a string or stzString object.")
		ok

	# Returns the text the trimmer holds, after any in-place trim.
	#
	#   returns    a text
	#   see        Trimmed
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
	#   note       a text of spaces is not empty
	#   see        NumberOfChars
	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   TRIMMING BOTH SIDES                                #
	#======================================================#

	# Removes the white space at both ends of the text, in place.
	#
	#   returns    nothing; use TrimQ to chain
	#   note       spaces, tabs and line breaks count as white space; spaces inside are kept
	#   see        Trimmed, TrimLeft, TrimRight
	def Trim()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrim(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def TrimQ()
			This.Trim()
			return This

	# Returns the text without white space at both ends, leaving the trimmer unchanged.
	#
	#   returns    a text
	#   note       "  hello world  " gives "hello world"; a text of spaces gives ""
	#   see        Trim
	def Trimmed()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimmed(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #======================================================#
	 #   TRIMMING LEFT / RIGHT                              #
	#======================================================#

	# Removes the white space at the start of the text, in place.
	#
	#   returns    nothing; use TrimLeftQ to chain
	#   note       TrimStart is the same method
	#   see        TrimmedLeft, TrimStart
	def TrimLeft()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimLeft(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def TrimLeftQ()
			This.TrimLeft()
			return This

	# Returns the text without white space at its start, leaving the trimmer unchanged.
	#
	#   returns    a text
	#   note       TrimmedFromStart is the same method
	#   see        TrimLeft
	def TrimmedLeft()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimLeft(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Removes the white space at the end of the text, in place.
	#
	#   returns    nothing; use TrimRightQ to chain
	#   note       TrimEnd is the same method
	#   see        TrimmedRight, TrimEnd
	def TrimRight()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimRight(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def TrimRightQ()
			This.TrimRight()
			return This

	# Returns the text without white space at its end, leaving the trimmer unchanged.
	#
	#   returns    a text
	#   note       TrimmedFromEnd is the same method
	#   see        TrimRight
	def TrimmedRight()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimRight(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #======================================================#
	 #   TRIMMING START / END                               #
	#======================================================#

	# Removes the white space at the start of the text, in place, exactly as TrimLeft does.
	#
	#   returns    nothing; use TrimStartQ to chain
	#   see        TrimLeft
	def TrimStart()
		This.TrimLeft()

		def TrimStartQ()
			This.TrimStart()
			return This

	def TrimmedFromStart()
		return This.TrimmedLeft()

	# Removes the white space at the end of the text, in place, exactly as TrimRight does.
	#
	#   returns    nothing; use TrimEndQ to chain
	#   see        TrimRight
	def TrimEnd()
		This.TrimRight()

		def TrimEndQ()
			This.TrimEnd()
			return This

	def TrimmedFromEnd()
		return This.TrimmedRight()

	  #======================================================#
	 #   TRIMMING A SPECIFIC CHAR                           #
	#======================================================#

	def TrimCharCS(_c_, pCaseSensitive)
		This.TrimCharFromStartCS(_c_, pCaseSensitive)
		This.TrimCharFromEndCS(_c_, pCaseSensitive)

		def TrimCharCSQ(_c_, pCaseSensitive)
			This.TrimCharCS(_c_, pCaseSensitive)
			return This

	def CharTrimmedCS(_c_, pCaseSensitive)
		_oCopy_ = new stzStringTrimmer(@oString.Content())
		_oCopy_.TrimCharCS(_c_, pCaseSensitive)
		return _oCopy_.Content()

	# Removes every repeat of one character from both ends of the text, in place, comparing case-sensitively.
	#
	#   _c_        the one character to strip
	#   returns    nothing; use TrimCharQ to chain
	#   note       "--a-b--" gives "a-b"; a text of only that character becomes empty; a padding of
	#              more than one character, such as "ab", removes nothing; TrimCharCS(c, 0) ignores
	#              case
	#   see        CharTrimmed, TrimCharFromStart, TrimCharFromEnd
	def TrimChar(_c_)
		This.TrimCharCS(_c_, 1)

		def TrimCharQ(_c_)
			This.TrimChar(_c_)
			return This

	# Returns the text without that character repeated at both ends, leaving the trimmer unchanged.
	#
	#   _c_        the one character to strip
	#   returns    a text
	#   note       "xXaXx" with "x" gives "XaX"; CharTrimmedCS("x", 0) gives "a"
	#   see        TrimChar
	def CharTrimmed(_c_)
		return This.CharTrimmedCS(_c_, 1)

	  #======================================================#
	 #   TRIMMING CHAR FROM START / END                     #
	#======================================================#

	def TrimCharFromStartCS(_c_, pCaseSensitive)
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_nStart_ = 1
		for i = 1 to _nLen_
			if BothStringsAreEqualCS(_acChars_[i], _c_, pCaseSensitive)
				_nStart_ = i + 1
			else
				exit
			ok
		next
		if _nStart_ > _nLen_
			@oString.Update("")
		else
			@oString.Update(@oString.Section(_nStart_, _nLen_))
		ok

		def TrimCharFromStartCSQ(_c_, pCaseSensitive)
			This.TrimCharFromStartCS(_c_, pCaseSensitive)
			return This

		def RemoveThisCharFromStartCS(_c_, pCaseSensitive)
			This.TrimCharFromStartCS(_c_, pCaseSensitive)

	# Removes every repeat of one character from the start of the text, in place, comparing case-sensitively.
	#
	#   _c_        the one character to strip
	#   returns    nothing; use TrimCharFromStartCSQ to chain
	#   note       "--a--" becomes "a--"
	#   see        TrimCharFromEnd, TrimChar
	def TrimCharFromStart(_c_)
		This.TrimCharFromStartCS(_c_, 1)

		# Removes every repeat of one character from the start of the text, in place, exactly as TrimCharFromStart does.
		#
		#   _c_        the one character to strip
		#   returns    nothing
		#   see        TrimCharFromStart
		def RemoveThisCharFromStart(_c_)
			This.TrimCharFromStart(_c_)

	#--

	def TrimCharFromEndCS(_c_, pCaseSensitive)
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_nEnd_ = _nLen_
		for i = _nLen_ to 1 step -1
			if BothStringsAreEqualCS(_acChars_[i], _c_, pCaseSensitive)
				_nEnd_ = i - 1
			else
				exit
			ok
		next
		if _nEnd_ < 1
			@oString.Update("")
		else
			@oString.Update(@oString.Section(1, _nEnd_))
		ok

		def TrimCharFromEndCSQ(_c_, pCaseSensitive)
			This.TrimCharFromEndCS(_c_, pCaseSensitive)
			return This

		def RemoveThisCharFromEndCS(_c_, pCaseSensitive)
			This.TrimCharFromEndCS(_c_, pCaseSensitive)

	# Removes every repeat of one character from the end of the text, in place, comparing case-sensitively.
	#
	#   _c_        the one character to strip
	#   returns    nothing; use TrimCharFromEndCSQ to chain
	#   note       "--a--" becomes "--a"
	#   see        TrimCharFromStart, TrimChar
	def TrimCharFromEnd(_c_)
		This.TrimCharFromEndCS(_c_, 1)

		# Removes every repeat of one character from the end of the text, in place, exactly as TrimCharFromEnd does.
		#
		#   _c_        the one character to strip
		#   returns    nothing
		#   see        TrimCharFromEnd
		def RemoveThisCharFromEnd(_c_)
			This.TrimCharFromEnd(_c_)

	  #======================================================#
	 #   TRIMMING CHAR FROM LEFT / RIGHT                    #
	#======================================================#

	def TrimCharFromLeftCS(_c_, pCaseSensitive)
		if @oString.IsLeftToRight()
			This.TrimCharFromStartCS(_c_, pCaseSensitive)
		else
			This.TrimCharFromEndCS(_c_, pCaseSensitive)
		ok

	# Removes a character repeated at the left end of the text, in place: the start for left-to-right text, the end for right-to-left.
	#
	#   _c_        the one character to strip
	#   returns    nothing
	#   warning    It always takes the start today: the direction test answers TRUE for Hebrew and
	#              Arabic, so for "ببمرحباب" TrimCharFromLeft("ب") strips the leading ones, the same
	#              as TrimCharFromStart
	#   see        TrimCharFromRight, TrimCharFromStart
	def TrimCharFromLeft(_c_)
		This.TrimCharFromLeftCS(_c_, 1)

	def TrimCharFromRightCS(_c_, pCaseSensitive)
		if @oString.IsLeftToRight()
			This.TrimCharFromEndCS(_c_, pCaseSensitive)
		else
			This.TrimCharFromStartCS(_c_, pCaseSensitive)
		ok

	# Removes a character repeated at the right end of the text, in place: the end for left-to-right text, the start for right-to-left.
	#
	#   _c_        the one character to strip
	#   returns    nothing
	#   warning    It always takes the end today, for the same reason as TrimCharFromLeft: right-to-
	#              left text is treated as left-to-right
	#   see        TrimCharFromLeft, TrimCharFromEnd
	def TrimCharFromRight(_c_)
		This.TrimCharFromRightCS(_c_, 1)
