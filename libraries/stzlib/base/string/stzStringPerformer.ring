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

# Applies an expression to each character of a text and collects the results, as a list; the in-place Perform verbs do nothing today.
#
# Build one with new stzStringPerformer("abc"). An expression is text in which @char is the current
# character and @i its position, such as "upper(@char)" or "@char + @char"; len() inside it counts
# bytes. Yield returns the result for every character as a list and YieldOn for chosen positions.
# Perform and PerformOn are meant to rewrite the text and leave it unchanged today, and the W forms
# (PerformW, YieldW) raise error R14. Use Yield and rebuild the text from the list when you need a
# rewritten string.
#
#   receiver   o1 = new stzStringPerformer("abc")
#   example    ? @@( o1.Yield("upper(@char)") )
#              #--> [ "A", "B", "C" ]
#              ? @@( o1.Yield("@char + @char") )
#              #--> [ "aa", "bb", "cc" ]
#              ? @@( o1.YieldOn([ 3, 1 ], "upper(@char)") )
#              #--> [ "C", "A" ]
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

	# Returns the text the performer holds, which no method of this class changes today.
	#
	#   returns    a text
	#   see        Yield
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

	# Leaves the text unchanged today instead of replacing every character by the result of an expression.
	#
	#   pcAction   the expression as text, where @char stands for the character, such as
	#              "upper(@char)"
	#   returns    nothing; the text is unchanged
	#   warning    Has no effect today: Perform("upper(@char)") on "abc" leaves "abc", because the
	#              result of the engine call is dropped and never written back; use Yield to get the
	#              results as a list
	#   see        Yield, PerformOn
	def Perform(pcAction)
		_cStr_ = @oString.Content()
		StzEngineStringMapChars(_cStr_, _StzStripBraces(pcAction))

		def PerformQ(pcAction)
			This.Perform(pcAction)
			return This

	  #======================================================#
	 #   PERFORM ACTION ON SPECIFIC POSITIONS               #
	#======================================================#

	# Leaves the text unchanged today instead of replacing the characters at some positions by the result of an expression.
	#
	#   panPos     the positions, from 1
	#   pcAction   the expression as text, where @char stands for the character
	#   returns    nothing; the text is unchanged
	#   warning    Has no effect today: PerformOn([1], "upper(@char)") on "abc" leaves "abc"; the
	#              positions are not even read; use YieldOn
	#   see        YieldOn, Perform
	def PerformOn(panPos, pcAction)
		_cStr_ = @oString.Content()
		_pList_ = StzEngineStringMapChars(_cStr_, _StzStripBraces(pcAction))
		if _pList_ != ""
			StzEngineListFree(_pList_)
		ok

		def PerformOnQ(panPos, pcAction)
			This.PerformOn(panPos, pcAction)
			return This

	  #======================================================#
	 #   PERFORM WITH CONDITION                             #
	#======================================================#

	def PerformW(pcCondition, pcAction)
		_anPos_ = This.FindCharsW(pcCondition)
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
	#   note        "abc" with "upper(@char)" gives A, B, C; len(@char) counts bytes, so שלום gives
	#               2 for each letter and 😀 gives 4; the text is not changed
	#   see         YieldOn, Perform
	def Yield(pcYielder)
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

	def YieldW(pcCondition, pcYielder)
		_anPos_ = This.FindCharsW(pcCondition)
		return This.YieldOn(_anPos_, pcYielder)

