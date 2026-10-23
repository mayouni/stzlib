#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGPERFORMER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String performer -- Wraps stzString via     #
#                  composition. Higher-order operations        #
#                  (perform, yield) on chars.                  #
#                  For aliases, use stzStringPerformerXT.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Applies an expression to each character of a text, to collect the results as a list or to rewrite the text in place.
#
# Build one with new stzStringPerformer("abc"). An expression is text in which @char is the current
# character and @i its position, such as "upper(@char)" or "@char + @char". Yield returns the result
# for every character as a list and YieldOn does so for chosen positions. Perform rewrites the text,
# each character becoming its result, and PerformOn rewrites only the characters at chosen positions;
# Content shows the text as it stands. PerformW and YieldW choose the characters by a condition.
#
# The expression is never run as Ring code: the engine reads it with its own evaluator, which accepts
# only these parts. Values: numbers, texts in single or double quotes, true and false. Names: @char,
# @i, @numberofitems (the count of characters). Operators: + - * / % = != < > <= >=, and, or, not,
# and parentheses; + joins two texts, / divides whole numbers and gives a whole number. Functions
# (upper, lower, len, trim, left, right, substr, replace, repeat, if, min, max, abs, isletter,
# isdigit, isuppercase and the like) are the engine's own list. upper and lower change only the
# ASCII letters, and len counts bytes. A text the evaluator does not accept (an unknown function, a
# statement separator, an empty text, or one longer than 2000 characters, because the engine's
# compiler overflows the stack on a very deeply nested text) gives no results: Yield answers [ ], and
# Perform and PerformOn leave the text as it is. Nothing in it can reach the system, a file or the
# network.
#
# A result is written into the text as text: a number as its digits, a true or false as 1 or 0, an
# empty result removes the character, and a result of several characters makes the text longer.
# The text is held by the performer itself; a stzString object given to the constructor is never
# changed by Perform.
#
#   receiver   o1 = new stzStringPerformer("abc")
#   example    ? @@( o1.Yield("upper(@char)") )
#              #--> [ "A", "B", "C" ]
#              ? @@( o1.Yield("@char + @char") )
#              #--> [ "aa", "bb", "cc" ]
#              ? @@( o1.YieldOn([ 3, 1 ], "upper(@char)") )
#              #--> [ "C", "A" ]
#              o1.Perform("@char + @char")
#              ? o1.Content()
#              #--> aabbcc
#              o2 = new stzStringPerformer("abc")
#              o2.PerformOn([ 2 ], "@char + @char")
#              ? o2.Content()
#              #--> abbc
#   see        stzString, stzListPerformer
class stzStringPerformer from stzObject

	@oString

	# Builds a performer over a text or over a stzString object, to apply an expression to its characters.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, whose characters are visited
	#   returns           nothing; the object is built
	#   warning           any other kind of value raises "Can't create stzStringPerformer! Parameter
	#                     must be a string or stzString object."; nothing here changes the text, so
	#                     a stzString passed in is safe
	#   see               Yield, Perform
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringPerformer! Parameter must be a string or stzString object.")
		ok

	# Returns the text the performer holds now, as rewritten by any Perform or PerformOn so far.
	#
	#   returns    a text
	#   see        Perform, Yield
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

	  #======================================================#
	 #   PERFORM ACTION ON EACH CHAR                        #
	#======================================================#

	# Replaces every character of the text, in place, by the result of an expression applied to it.
	#
	#   pcAction   the expression as text, where @char stands for the character and @i for its
	#              position, such as "upper(@char)"
	#   returns    nothing; the text becomes the results written one after the other
	#   note       the text after Perform is the joining of the list Yield gives for the same
	#              expression: "abc" with "@char + @char" becomes aabbcc; a number is written as its
	#              digits, an empty result removes the character, and a text the evaluator does not
	#              accept leaves the text as it is
	#   see        Yield, PerformOn
	def Perform(pcAction)
		_aRes_ = This.Yield(pcAction)
		_nRes_ = ring_len(_aRes_)
		if _nRes_ = 0
			return
		ok

		_cNew_ = ""
		for i = 1 to _nRes_
			_cNew_ += This._ResultAsText(_aRes_[i])
		next
		@oString = new stzString(_cNew_)

		def PerformQ(pcAction)
			This.Perform(pcAction)
			return This

	  #======================================================#
	 #   PERFORM ACTION ON SPECIFIC POSITIONS               #
	#======================================================#

	# Replaces the characters at the given positions, in place, by the result of an expression applied to each.
	#
	#   panPos     the positions, from 1, as a list; the order and repeats do not matter, and a
	#              position that is 0, negative or past the end is skipped, as YieldOn skips it
	#   pcAction   the expression as text, where @char stands for the character and @i for its
	#              position in the whole text, such as "upper(@char)"
	#   returns    nothing; the other characters stay as they are
	#   warning    a value that is not a list raises an error, as YieldOn does
	#   note       PerformOn([ 2 ], "@char + @char") on "abc" gives abbc; each chosen character is
	#              replaced once whatever the number of times its position is given
	#   see        YieldOn, Perform
	def PerformOn(panPos, pcAction)
		if NOT isList(panPos)
			StzRaise("Can't perform on positions! panPos must be a list of positions.")
		ok

		_aRes_ = This.Yield(pcAction)
		_nRes_ = ring_len(_aRes_)
		if _nRes_ = 0
			return
		ok

		_aSel_ = []
		for i = 1 to _nRes_
			_aSel_ + 0
		next
		_nPos_ = ring_len(panPos)
		for i = 1 to _nPos_
			_n_ = panPos[i]
			if _n_ >= 1 and _n_ <= _nRes_
				_aSel_[_n_] = 1
			ok
		next

		_aChars_ = This.Yield("@char")
		_cNew_ = ""
		for i = 1 to _nRes_
			if _aSel_[i] = 1
				_cNew_ += This._ResultAsText(_aRes_[i])
			else
				_cNew_ += _aChars_[i]
			ok
		next
		@oString = new stzString(_cNew_)

		def PerformOnQ(panPos, pcAction)
			This.PerformOn(panPos, pcAction)
			return This

	  #======================================================#
	 #   PERFORM WITH CONDITION                             #
	#======================================================#

	# Replaces, in place, the characters that meet a condition by the result of an expression applied to each.
	#
	#   pcCondition   the condition as text, where @char stands for the character, such as
	#                 "isuppercase(@char)"
	#   pcAction      the expression as text, where @char stands for the character
	#   returns       nothing; the characters that do not meet the condition stay as they are
	#   see           PerformOn, YieldW
	def PerformW(pcCondition, pcAction)
		_anPos_ = This._PositionsW(pcCondition)
		This.PerformOn(_anPos_, pcAction)

		def PerformWQ(pcCondition, pcAction)
			This.PerformW(pcCondition, pcAction)
			return This

	  #======================================================#
	 #   YIELD (COLLECT) FROM EACH CHAR                     #
	#======================================================#

	# Returns the results of an expression applied to each character, in order, as a list.
	#
	#   pcYielder   the expression as text, where @char stands for the character and @i for its
	#               position, such as "upper(@char)"
	#   returns     a list with one result per character; [ ] for an empty text
	#   warning     a text longer than 2000 characters is not accepted and gives [ ], as does any text
	#               the evaluator rejects, such as an unknown function or a statement separator
	#   note        "abc" with "upper(@char)" gives A, B, C; len(@char) counts bytes, so שלום gives
	#               2 for each letter and 😀 gives 4; the text is not changed
	#   see         YieldOn, Perform
	def Yield(pcYielder)
		if isString(pcYielder) and ring_len(pcYielder) > 2000
			return []
		ok
		_cStr_ = @oString.Content()
		_pList_ = StzEngineStringMapChars(_cStr_, _StzStripBraces(pcYielder))
		if _pList_ = "" return [] ok

		_aResult_ = StzEngineContentFromList(_pList_)
		StzEngineListFree(_pList_)
		return _aResult_

	  #======================================================#
	 #   YIELD FROM SPECIFIC POSITIONS                      #
	#======================================================#

	# Returns the results of an expression for the characters at the given positions only, in the order of the positions.
	#
	#   panPos      the positions to read, from 1, in the order wanted
	#   pcYielder   the expression as text, where @char stands for the character
	#   returns     a list of results; positions outside the text are skipped
	#   note        [3, 1] on "abc" with "upper(@char)" gives C, A; 0 and 9 are skipped
	#   see         Yield, YieldW
	def YieldOn(panPos, pcYielder)
		_aAll_ = This.Yield(pcYielder)
		_aResult_ = []
		_nLen_ = len(panPos)
		for i = 1 to _nLen_
			_n_ = panPos[i]
			if _n_ >= 1 and _n_ <= len(_aAll_)
				_aResult_ + _aAll_[_n_]
			ok
		next
		return _aResult_

	  #======================================================#
	 #   YIELD WITH CONDITION                               #
	#======================================================#

	# Returns the results of an expression for the characters that meet a condition, in text order.
	#
	#   pcCondition   the condition as text, where @char stands for the character, such as
	#                 "isuppercase(@char)"
	#   pcYielder     the expression as text, where @char stands for the character
	#   returns       a list with one result per character that meets the condition
	#   see           YieldOn, PerformW
	def YieldW(pcCondition, pcYielder)
		_anPos_ = This._PositionsW(pcCondition)
		return This.YieldOn(_anPos_, pcYielder)

	  #======================================================#
	 #   INTERNAL                                           #
	#======================================================#

	def _PositionsW(pcCondition)
		if isString(pcCondition) and ring_len(pcCondition) > 2000
			return []
		ok
		return @oString.FindCharsW(pcCondition)

	def _ResultAsText(pResult)
		if isString(pResult)
			return pResult
		but isNumber(pResult)
			return "" + pResult
		ok
		return ""
