#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGFORMATTER         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String formatter -- case conversion,        #
#                  alignment, padding, spacing, simplification #
#                  and repeating.                              #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringFormatterXT.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Changes how a text looks: its case, its alignment and padding, its white space and its repetition.
#
# It is the formatting helper behind the case methods of stzString (Titlecased, CaseFolded...),
# which builds one over itself and writes the result back; reach for it directly with new
# stzStringFormatter(cText) or StzStringFormatterQ(cText) when you only need the formatting. Each
# Apply verb and each Align, Pad, Trim, Simplify and Repeat verb changes the held text in place and
# returns nothing (the Q form returns the formatter, so calls chain), and the past-tense form
# (Uppercased, RightAligned, Trimmed...) returns the new text and leaves the formatter alone. Read
# the result with Content. Widths and reversals count characters, not bytes, so Hebrew, Arabic and
# emoji text is handled whole. Pass a plain text, not a stzString object: an edit through a
# formatter empties the stzString that was passed in. PaddedLeft and PaddedRight ignore their
# padding character; use PadLeft and PadRight.
#
#   receiver   o1 = new stzStringFormatter("hello WORLD")
#   example    ? o1.Titlecased()
#              #--> Hello World
#              ? "[" + o1.RightAligned(14) + "]"
#              #--> [   hello WORLD]
#              o1.PadRight(14, "*")
#              ? o1.Content()
#              #--> hello WORLD***
#              o2 = new stzStringFormatter("שלום עולם")
#              ? o2.NumberOfChars()
#              #--> 9
#              ? o2.Reversed() = "םלוע םולש"
#              #--> 1
#              o3 = new stzStringFormatter("ab😀")
#              ? "[" + o3.CenterAligned(7) + "]"
#              #--> [  ab😀  ]
#   see        stzString, stzStringEncoder, stzStringLeadTrail
class stzStringFormatter from stzObject

	@oString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a formatter over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the text to format, or a stzString whose content is formatted, any other
	#                     value raises an error
	#   returns           nothing; the object is built
	#   note              pass a plain text and read the result with Content; stzString does it
	#                     safely by writing the formatter result back with Update
	#   warning           with a stzString argument, the first edit (Apply..., an Align, Trim,
	#                     Simplify, RepeatNTimes) leaves the stzString you passed reading as an
	#                     empty text; the formatter itself keeps the right text
	#   see               Content, Titlecased
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringFormatter! Parameter must be a string or stzString object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the text as it stands now, after the edits made so far.
	#
	#   returns    a text
	#   see        NumberOfChars, Lowercased
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting an emoji or a Hebrew letter as one.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text holds no character at all.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfChars, Content
	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     LOWERCASE                 #
	#===============================#

	# Turns the held text to lower case, in place.
	#
	#   returns    nothing; the text changes. ApplyLowercaseQ returns the formatter for chaining
	#   note       the past-tense twin Lowercased leaves the formatter alone
	#   see        Lowercased, ApplyUppercase
	def ApplyLowercase()
		pHandle = StzEngineString(@oString.Content())
		pLower = StzEngineStringToLower(pHandle)
		@oString.Update(StzEngineStringData(pLower))
		StzEngineStringFree(pLower)
		StzEngineStringFree(pHandle)

		def ApplyLowercaseQ()
			This.ApplyLowercase()
			return This

	# Returns the text in lower case and leaves the formatter unchanged.
	#
	#   returns    a text
	#   note       LowercasedQ returns a new formatter over the result
	#   see        ApplyLowercase, Uppercased
	def Lowercased()
		pHandle = StzEngineString(@oString.Content())
		pLower = StzEngineStringToLower(pHandle)
		_cResult_ = StzEngineStringData(pLower)
		StzEngineStringFree(pLower)
		StzEngineStringFree(pHandle)
		return _cResult_

		def LowercasedQ()
			return new stzStringFormatter(This.Lowercased())

	  #===============================#
	 #     UPPERCASE                 #
	#===============================#

	# Turns the held text to upper case, in place; a German sharp s becomes SS.
	#
	#   returns    nothing; the text changes. ApplyUppercaseQ returns the formatter for chaining
	#   see        Uppercased, ApplyLowercase
	def ApplyUppercase()
		pHandle = StzEngineString(@oString.Content())
		pUpper = StzEngineStringToUpper(pHandle)
		@oString.Update(StzEngineStringData(pUpper))
		StzEngineStringFree(pUpper)
		StzEngineStringFree(pHandle)

		def ApplyUppercaseQ()
			This.ApplyUppercase()
			return This

	# Returns the text in upper case and leaves the formatter unchanged; a German sharp s becomes SS.
	#
	#   returns    a text
	#   note       UppercasedQ returns a new formatter over the result
	#   see        ApplyUppercase, Lowercased
	def Uppercased()
		pHandle = StzEngineString(@oString.Content())
		pUpper = StzEngineStringToUpper(pHandle)
		_cResult_ = StzEngineStringData(pUpper)
		StzEngineStringFree(pUpper)
		StzEngineStringFree(pHandle)
		return _cResult_

		def UppercasedQ()
			return new stzStringFormatter(This.Uppercased())

	  #===============================#
	 #     CAPITALIZE                #
	#===============================#

	# Capitalizes the held text in place: its first character in upper case and everything after it in lower case.
	#
	#   returns    nothing; the text changes. ApplyCapitalcaseQ returns the formatter for chaining
	#   note       a text that starts with a space keeps its first letter unchanged, because the
	#              space is the first character
	#   see        Capitalized, ApplyTitlecase
	def ApplyCapitalcase()
		_cContent_ = @oString.Content()
		if StzLen(_cContent_) = 0
			return
		ok

		_cFirst_ = StzUpper(StzLeft(_cContent_, 1))
		if StzLen(_cContent_) > 1
			_pH_ = StzEngineString(_cContent_)
			pRest = StzEngineStringSlice(_pH_, 2, StzLen(_cContent_) - 1)
			_cRest_ = StzLower(StzEngineStringData(pRest))
			StzEngineStringFree(pRest)
			StzEngineStringFree(_pH_)
			@oString.Update(_cFirst_ + _cRest_)
		else
			@oString.Update(_cFirst_)
		ok

		def ApplyCapitalcaseQ()
			This.ApplyCapitalcase()
			return This

	# Returns the text with only its first character in upper case and the rest in lower case, leaving the formatter unchanged.
	#
	#   returns    a text; an empty text for an empty one
	#   note       hello WORLD gives Hello world, where Titlecased gives Hello World; CapitalizedQ
	#              returns a new formatter over the result
	#   see        ApplyCapitalcase, Titlecased
	def Capitalized()
		_cContent_ = @oString.Content()
		if StzLen(_cContent_) = 0
			return ""
		ok

		_cFirst_ = StzUpper(StzLeft(_cContent_, 1))
		if StzLen(_cContent_) > 1
			_pH_ = StzEngineString(_cContent_)
			pRest = StzEngineStringSlice(_pH_, 2, StzLen(_cContent_) - 1)
			_cRest_ = StzLower(StzEngineStringData(pRest))
			StzEngineStringFree(pRest)
			StzEngineStringFree(_pH_)
			return _cFirst_ + _cRest_
		else
			return _cFirst_
		ok

		def CapitalizedQ()
			return new stzStringFormatter(This.Capitalized())

	  #===============================#
	 #     TITLECASE                 #
	#===============================#

	# Capitalizes the first letter of every word of the held text, in place.
	#
	#   returns    nothing; the text changes. ApplyTitlecaseQ returns the formatter for chaining
	#   see        Titlecased, ApplyCapitalcase
	def ApplyTitlecase()
		@oString.Update(StzTitle(@oString.Content()))

		def ApplyTitlecaseQ()
			This.ApplyTitlecase()
			return This

	# Returns the text with each word capitalized and leaves the formatter unchanged.
	#
	#   returns    a text
	#   note       TitlecasedQ returns a new formatter over the result
	#   see        ApplyTitlecase, Capitalized
	#@ aka  The string in Title Case (each word capitalized).
	def Titlecased()
		_oCopy_ = new stzStringFormatter(@oString.Content())
		_oCopy_.ApplyTitlecase()
		return _oCopy_.Content()

		def TitlecasedQ()
			return new stzStringFormatter(This.Titlecased())

	  #===============================#
	 #     CASE FOLD                 #
	#===============================#

	# Replaces the held text by its caseless form, in place, ready to be compared.
	#
	#   returns    nothing; the text changes
	#   note       case folding is stronger than lower casing: a German sharp s becomes ss
	#   see        CaseFolded, ApplyLowercase
	def ApplyCaseFold()
		@oString.Update(StzCaseFold(@oString.Content()))

	# Returns the caseless form of the text, for comparing two texts without regard to case.
	#
	#   returns    a text
	#   note       the plain lower case of a German sharp s is itself, its case fold is ss
	#   see        ApplyCaseFold, Lowercased
	#@ aka  The string case-folded (aggressive lowercasing, for caseless comparison).
	def CaseFolded()
		return StzCaseFold(@oString.Content())

	  #===============================#
	 #     REVERSED                  #
	#===============================#

	# Reverses the order of the characters of the held text, in place.
	#
	#   returns    nothing; the text changes. ApplyReverseQ returns the formatter for chaining
	#   see        Reversed
	def ApplyReverse()
		@oString.Update(StzReverse(@oString.Content()))

		def ApplyReverseQ()
			This.ApplyReverse()
			return This

	# Returns the characters in reverse order and leaves the formatter unchanged.
	#
	#   returns    a text
	#   note       characters are reversed, not bytes, so Hebrew, Arabic and emoji stay whole;
	#              ReversedQ returns a new formatter over the result
	#   see        ApplyReverse
	def Reversed()
		return StzReverse(@oString.Content())

		def ReversedQ()
			return new stzStringFormatter(This.Reversed())

	  #===============================#
	 #     LEFT ALIGN                #
	#===============================#

	# Pads the held text on its right with spaces up to a width, so the text sits on the left, in place.
	#
	#   nWidth     the width to reach, in characters, a text already that long is left as it is
	#   returns    nothing; the text changes. LeftAlignQ returns the formatter for chaining
	#   see        LeftAligned, RightAlign, PadRight
	def LeftAlign(nWidth)
		This.LeftAlignXT(nWidth, " ")

		def LeftAlignQ(nWidth)
			This.LeftAlign(nWidth)
			return This

	def LeftAlignXT(nWidth, cChar)
		if CheckingParams()
			if NOT isNumber(nWidth)
				StzRaise("Incorrect param type! nWidth must be a number.")
			ok
			if NOT ( isString(cChar) and StzLen(cChar) = 1 )
				StzRaise("Incorrect param type! cChar must be a char.")
			ok
		ok
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringLjust(_pH_, nWidth, cChar)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def LeftAlignXTQ(nWidth, cChar)
			This.LeftAlignXT(nWidth, cChar)
			return This

	# Returns the text padded on its right with spaces up to a width, leaving the formatter unchanged.
	#
	#   nWidth     the width to reach, in characters, a text already that long is returned as it is
	#   returns    a text
	#   see        LeftAlign, RightAligned
	def LeftAligned(nWidth)
		_oCopy_ = new stzStringFormatter(@oString.Content())
		_oCopy_.LeftAlign(nWidth)
		return _oCopy_.Content()

	  #===============================#
	 #     RIGHT ALIGN               #
	#===============================#

	# Pads the held text on its left with spaces up to a width, so the text sits on the right, in place.
	#
	#   nWidth     the width to reach, in characters, a text already that long is left as it is
	#   returns    nothing; the text changes. RightAlignQ returns the formatter for chaining
	#   see        RightAligned, LeftAlign, PadLeft
	def RightAlign(nWidth)
		This.RightAlignXT(nWidth, " ")

		def RightAlignQ(nWidth)
			This.RightAlign(nWidth)
			return This

	def RightAlignXT(nWidth, cChar)
		if CheckingParams()
			if NOT isNumber(nWidth)
				StzRaise("Incorrect param type! nWidth must be a number.")
			ok
			if NOT ( isString(cChar) and StzLen(cChar) = 1 )
				StzRaise("Incorrect param type! cChar must be a char.")
			ok
		ok
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRjust(_pH_, nWidth, cChar)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RightAlignXTQ(nWidth, cChar)
			This.RightAlignXT(nWidth, cChar)
			return This

	# Returns the text padded on its left with spaces up to a width, leaving the formatter unchanged.
	#
	#   nWidth     the width to reach, in characters, a text already that long is returned as it is
	#   returns    a text
	#   see        RightAlign, LeftAligned
	def RightAligned(nWidth)
		_oCopy_ = new stzStringFormatter(@oString.Content())
		_oCopy_.RightAlign(nWidth)
		return _oCopy_.Content()

	  #===============================#
	 #     CENTER ALIGN              #
	#===============================#

	# Pads the held text on both sides with spaces up to a width, in place; an odd remainder puts the extra space on the right.
	#
	#   nWidth     the width to reach, in characters, a text already that long is left as it is
	#   returns    nothing; the text changes. CenterAlignQ returns the formatter for chaining
	#   see        CenterAligned, LeftAlign
	def CenterAlign(nWidth)
		This.CenterAlignXT(nWidth, " ")

		def CenterAlignQ(nWidth)
			This.CenterAlign(nWidth)
			return This

	def CenterAlignXT(nWidth, cChar)
		if CheckingParams()
			if NOT isNumber(nWidth)
				StzRaise("Incorrect param type! nWidth must be a number.")
			ok
			if NOT ( isString(cChar) and StzLen(cChar) = 1 )
				StzRaise("Incorrect param type! cChar must be a char.")
			ok
		ok
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringCenterPad(_pH_, nWidth, cChar)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def CenterAlignXTQ(nWidth, cChar)
			This.CenterAlignXT(nWidth, cChar)
			return This

	# Returns the text padded on both sides with spaces up to a width; an odd remainder puts the extra space on the right.
	#
	#   nWidth     the width to reach, in characters, a text already that long is returned as it is
	#   returns    a text
	#   see        CenterAlign, RightAligned
	def CenterAligned(nWidth)
		_oCopy_ = new stzStringFormatter(@oString.Content())
		_oCopy_.CenterAlign(nWidth)
		return _oCopy_.Content()

	  #===============================#
	 #     PADDING                   #
	#===============================#

	# Pads the held text on its left with a chosen character up to a width, in place.
	#
	#   nWidth     the width to reach, in characters
	#   cChar      the padding character, exactly one character, otherwise an error is raised
	#   returns    nothing; the text changes. PadLeftQ returns the formatter for chaining
	#   note       the same as RightAlign with a fill character instead of a space
	#   see        PaddedLeft, PadRight, RightAlign
	def PadLeft(nWidth, cChar)
		This.RightAlignXT(nWidth, cChar)

		def PadLeftQ(nWidth, cChar)
			This.PadLeft(nWidth, cChar)
			return This

	# Returns the text padded on its left with spaces up to a width, and does not use the padding character.
	#
	#   nWidth     the width to reach, in characters
	#   cChar      accepted but not used
	#   returns    a text
	#   note       use PadLeft for a chosen character, or RightAligned for spaces
	#   warning    the padding character is ignored: PaddedLeft(6, "-") on abc answers three spaces
	#              then abc, where PadLeft(6, "-") gives ---abc; the body returns
	#              RightAligned(nWidth)
	#   see        PadLeft, RightAligned
	def PaddedLeft(nWidth, cChar)
		return This.RightAligned(nWidth)

	# Pads the held text on its right with a chosen character up to a width, in place.
	#
	#   nWidth     the width to reach, in characters
	#   cChar      the padding character, exactly one character, otherwise an error is raised
	#   returns    nothing; the text changes. PadRightQ returns the formatter for chaining
	#   note       the same as LeftAlign with a fill character instead of a space
	#   see        PaddedRight, PadLeft, LeftAlign
	def PadRight(nWidth, cChar)
		This.LeftAlignXT(nWidth, cChar)

		def PadRightQ(nWidth, cChar)
			This.PadRight(nWidth, cChar)
			return This

	# Returns the text padded on its right with spaces up to a width, and does not use the padding character.
	#
	#   nWidth     the width to reach, in characters
	#   cChar      accepted but not used
	#   returns    a text
	#   note       use PadRight for a chosen character, or LeftAligned for spaces
	#   warning    the padding character is ignored: PaddedRight(6, "-") on abc answers abc then
	#              three spaces, where PadRight(6, "-") gives abc---; the body returns
	#              LeftAligned(nWidth)
	#   see        PadRight, LeftAligned
	def PaddedRight(nWidth, cChar)
		return This.LeftAligned(nWidth)

	  #===============================#
	 #     SIMPLIFICATION            #
	#===============================#

	# Collapses every run of white space in the held text to one space and drops it at both ends, in place.
	#
	#   returns    nothing; the text changes. SimplifyQ returns the formatter for chaining
	#   see        Simplified, Trim
	def Simplify()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringSimplify(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def SimplifyQ()
			This.Simplify()
			return This

	# Returns the text with each run of white space collapsed to one space and none at its ends, leaving the formatter unchanged.
	#
	#   returns    a text
	#   note       SimplifiedQ returns a new formatter over the result; tabs and new lines count as
	#              white space
	#   see        Simplify, Trimmed
	def Simplified()
		_oCopy_ = new stzStringFormatter(@oString.Content())
		_oCopy_.Simplify()
		return _oCopy_.Content()

		def SimplifiedQ()
			return new stzStringFormatter(This.Simplified())

	  #===============================#
	 #     TRIMMING                  #
	#===============================#

	# Removes the white space at both ends of the held text, in place.
	#
	#   returns    nothing; the text changes. TrimQ returns the formatter for chaining
	#   note       inside the text nothing is touched
	#   see        Trimmed, TrimLeft, TrimRight, Simplify
	def Trim()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrim(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def TrimQ()
			This.Trim()
			return This

	# Returns the text without the white space at its two ends, leaving the formatter unchanged.
	#
	#   returns    a text
	#   note       tabs and new lines are white space too
	#   see        Trim, Simplified
	def Trimmed()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimmed(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Removes the white space at the start of the held text, in place.
	#
	#   returns    nothing; the text changes. TrimLeftQ returns the formatter for chaining
	#   see        TrimmedLeft, TrimRight
	def TrimLeft()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimLeft(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def TrimLeftQ()
			This.TrimLeft()
			return This

	# Returns the text without the white space at its start, leaving the formatter unchanged.
	#
	#   returns    a text
	#   see        TrimLeft, TrimmedRight
	def TrimmedLeft()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimLeft(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Removes the white space at the end of the held text, in place.
	#
	#   returns    nothing; the text changes. TrimRightQ returns the formatter for chaining
	#   see        TrimmedRight, TrimLeft
	def TrimRight()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimRight(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def TrimRightQ()
			This.TrimRight()
			return This

	# Returns the text without the white space at its end, leaving the formatter unchanged.
	#
	#   returns    a text
	#   see        TrimRight, TrimmedLeft
	def TrimmedRight()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimRight(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     REPEATING                 #
	#===============================#

	# Replaces the held text by itself written n times in a row, in place; 0 gives an empty text.
	#
	#   n          how many times to write the text
	#   returns    nothing; the text changes. RepeatNTimesQ returns the formatter for chaining
	#   note       no separator is inserted between the copies
	#   see        RepeatedNTimes
	def RepeatNTimes(n)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRepeat(_pH_, n)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RepeatNTimesQ(n)
			This.RepeatNTimes(n)
			return This

	# Returns the text written n times in a row, leaving the formatter unchanged.
	#
	#   n          how many times to write the text
	#   returns    a text
	#   note       no separator is inserted between the copies
	#   see        RepeatNTimes
	def RepeatedNTimes(n)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRepeat(_pH_, n)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_
