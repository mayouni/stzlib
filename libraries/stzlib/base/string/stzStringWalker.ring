#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGWALKER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String walker -- walking the string         #
#                  forward/backward with steps, yielding       #
#                  values, performing operations.              #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringWalkerXT.         #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Walks through the characters of a text by position: forwards or backwards, with a step, with code run on each, or along named walkers.
#
# Build one with new stzStringWalker("abcdefghij"); it only reads, so a stzString passed in is never
# changed. CharsFromTo and CharsWithStep answer lists of characters; WalkAndYield runs a piece of
# code on each visited character. AddWalker keeps a named walker of numbers, whose steps are given
# as a list, and Walker gives back the numbers it visits. A step of 0 in CharsWithStep or
# WalkAndYield never ends, so never give one. Positions count from 1 in characters.
#
#   receiver   o1 = new stzStringWalker("abcdefghij")
#   example    ? @@( o1.CharsFromTo(5, 2) )
#              #--> [ "e", "d", "c", "b" ]
#              ? @@( o1.CharsWithStep(1, 3) )
#              #--> [ "a", "d", "g", "j" ]
#              ? @@( o1.CharsWithStep(10, -3) )
#              #--> [ "j", "g", "d", "a" ]
#              o1.AddWalker("w", 1, 10, [ 4 ])
#              ? @@( o1.Walker("w") )
#              #--> [ 1, 5, 9 ]
#   see        stzString, stzWalker, stzStringGetter
class stzStringWalker from stzObject

	@oString
	@aWalkers = []

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Builds a walker over a text or over a stzString object, to visit its characters from a start to an end with a step.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, whose characters are visited
	#   returns           nothing; the object is built
	#   warning           any other kind of value raises "Can't create stzStringWalker! Parameter
	#                     must be a string or stzString object."; the walker only reads, so a
	#                     stzString passed in is never changed
	#   see               CharsFromTo, AddWalker
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringWalker! Parameter must be a string or stzString object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the text the walker holds.
	#
	#   returns    a text
	#   see        Chars
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
	 #     ADD/REMOVE WALKERS        #
	#===============================#

	# Registers a named walker, a start, an end and the steps to repeat, to be read back by name.
	#
	#   pcWalkerName   the name to read it back by, case-sensitive
	#   _nStart_       the number the walk starts from
	#   _nEnd_         the number it stops at
	#   nStep          a LIST of the steps taken in turn, such as [ 2 ], not a single number
	#   returns        nothing; use AddWalkerQ to chain
	#   note           the walker walks numbers (positions) and does not read the text
	#   warning        A single number for nStep, as the parameter name suggests, raises "the steps
	#                  must be a non-empty list of numbers"; a name used twice is kept twice and
	#                  Walker finds the first
	#   see            Walker, RemoveWalker
	def AddWalker(pcWalkerName, _nStart_, _nEnd_, nStep)
		@aWalkers + [ pcWalkerName, new stzWalker(_nStart_, _nEnd_, nStep) ]

		def AddWalkerQ(pcWalkerName, _nStart_, _nEnd_, nStep)
			This.AddWalker(pcWalkerName, _nStart_, _nEnd_, nStep)
			return This

	# Returns the numbers that the named walker visits, from its start to its end.
	#
	#   pcWalkerName   the name given to AddWalker, case-sensitive
	#   returns        a list of numbers
	#   note           AddWalker("w", 1, 10, [2]) gives 1, 3, 5, 7, 9
	#   warning        An unknown name, or a different case, raises "pcWalkerName must be a valid
	#                  walker name."
	#   see            AddWalker, Walkers
	def Walker(pcWalkerName)
		_nLen_ = len(@aWalkers)
		for _i_ = 1 to _nLen_
			if @aWalkers[_i_][1] = pcWalkerName
				return @aWalkers[_i_][2].Walkables()
			ok
		next
		StzRaise("Incorrect param value! pcWalkerName must be a valid walker name.")

	def WalkerQ(pcWalkerName)
		_nLen_ = len(@aWalkers)
		for _i_ = 1 to _nLen_
			if @aWalkers[_i_][1] = pcWalkerName
				return @aWalkers[_i_][2]
			ok
		next
		StzRaise("Incorrect param value! pcWalkerName must be a valid walker name.")

	# Returns the registered walkers as a list of [ name, stzWalker ] pairs, in the order added.
	#
	#   returns    a list of pairs
	#   note       the items are objects, so printing the list with @@ fails; ask len() or a name
	#   see        AddWalker, Walker
	def Walkers()
		return @aWalkers

	# Removes the first walker that has the given name.
	#
	#   pcWalkerName   the name of the walker to remove
	#   returns        nothing
	#   note           an unknown name changes nothing and raises nothing
	#   see            RemoveWalkers, AddWalker
	def RemoveWalker(pcWalkerName)
		_nLen_ = len(@aWalkers)
		_nPos_ = 0
		for _i_ = 1 to _nLen_
			if @aWalkers[_i_][1] = pcWalkerName
				_nPos_ = _i_
				exit
			ok
		next

		if _nPos_ > 0
			ring_remove(@aWalkers, _nPos_)
		ok

	# Removes every registered walker.
	#
	#   returns    nothing
	#   see        RemoveWalker
	def RemoveWalkers()
		@aWalkers = []

	  #===============================#
	 #     CHARS ENUMERATION         #
	#===============================#

	# Returns the characters of the text as a list of one-character texts.
	#
	#   returns    a list of texts
	#   note       "שלום😀ب" gives six items; CharsQ answers a stzList
	#   see        UniqueChars, CharAt
	def Chars()
		return @oString.Chars()

		def CharsQ()
			return new stzList(This.Chars())

	# Returns the different characters of the text, each once, in order of first appearance.
	#
	#   returns    a list of texts
	#   note       "aabbb" gives a and b; the comparison goes through Ring's text equality
	#   see        Chars
	def UniqueChars()
		_acAll_ = This.Chars()
		_acResult_ = []
		_nLen_ = len(_acAll_)

		for _i_ = 1 to _nLen_
			_bFound_ = 0
			_nResLen_ = len(_acResult_)
			for j = 1 to _nResLen_
				if _acResult_[j] = _acAll_[_i_]
					_bFound_ = 1
					exit
				ok
			next
			if NOT _bFound_
				_acResult_ + _acAll_[_i_]
			ok
		next

		return _acResult_

		def UniqueCharsQ()
			return new stzList(This.UniqueChars())

	# Returns the character at a position, counted from 1.
	#
	#   n          the position, from 1
	#   returns    a one-character text
	#   note       position 0 or beyond the length raises "Index out of range!"
	#   see        FirstChar, LastChar
	def CharAt(n)
		if n < 1 or n > @oString.NumberOfChars()
			StzRaise("Index out of range!")
		ok
		return @oString.NthChar(n)

	# Returns the first character of the text.
	#
	#   returns    a one-character text
	#   note       an empty text raises "Index out of range!"
	#   see        LastChar, CharAt
	def FirstChar()
		return This.CharAt(1)

	# Returns the last character of the text.
	#
	#   returns    a one-character text
	#   note       an empty text raises "Index out of range!"
	#   see        FirstChar, CharAt
	def LastChar()
		return This.CharAt(@oString.NumberOfChars())

	  #===============================#
	 #     WALK AND YIELD            #
	#===============================#

	# Visits the characters from a start to an end with a step, runs a piece of code on each, and returns the characters as the code left them.
	#
	#   _nStart_   the first position, raised to 1 if smaller
	#   _nEnd_     the last position, lowered to the length if larger
	#   nStep      the amount added to the position each time, above 0
	#   pcCode     Ring code run for each character, where @char is the character, which it may
	#              change, and @position its position
	#   returns    a list of texts
	#   note       the code can set @char: '@char = upper(@char)' on "abcdefghij" from 1 to 10 step
	#              3 gives A, D, G, J
	#   warning    A step of 0 never ends and a negative step does not go backwards either (the loop
	#              keeps its test on the end): both were read from the code and not run
	#   see        CharsFromTo, CharsWithStep
	def WalkAndYield(_nStart_, _nEnd_, nStep, pcCode)
		_acResult_ = []
		_nLen_ = @oString.NumberOfChars()

		if _nStart_ < 1
			_nStart_ = 1
		ok
		if _nEnd_ > _nLen_
			_nEnd_ = _nLen_
		ok

		_i_ = _nStart_
		while _i_ <= _nEnd_
			@char = @oString.NthChar(_i_)
			@position = _i_

			_cCode_ = pcCode
			eval(_cCode_)
			_acResult_ + @char

			_i_ += nStep
		end

		return _acResult_

	  #===============================#
	 #     WALK FORWARD/BACKWARD     #
	#===============================#

	# Returns the characters from one position to another, forwards or backwards, as a list.
	#
	#   n1         the first position, from 1
	#   n2         the last position, from 1
	#   returns    a list of texts; [ ] when a position is outside the text
	#   note       CharsFromTo(5, 2) on "abcdefghij" gives e, d, c, b; positions 0 or past the
	#              length give [ ] without an error
	#   see        CharsWithStep, WalkAndYield
	def CharsFromTo(n1, n2)
		_acResult_ = []
		_nLen_ = @oString.NumberOfChars()

		if n1 < 1 or n2 < 1 or n1 > _nLen_ or n2 > _nLen_
			return _acResult_
		ok

		if n1 <= n2
			for _i_ = n1 to n2
				_acResult_ + @oString.NthChar(_i_)
			next
		else
			for _i_ = n1 to n2 step -1
				_acResult_ + @oString.NthChar(_i_)
			next
		ok

		return _acResult_

	# Returns every nth character from a start position, forwards or backwards, as a list.
	#
	#   _nStart_   the first position, from 1
	#   nStep      the step, positive to go forward, negative to go back
	#   returns    a list of texts; [ ] when the start is outside the text
	#   note       CharsWithStep(1, 3) on "abcdefghij" gives a, d, g, j and CharsWithStep(10, -3)
	#              gives j, g, d, a
	#   warning    A step of 0 never ends (read from the code, not run)
	#   see        CharsFromTo, WalkAndYield
	def CharsWithStep(_nStart_, nStep)
		_acResult_ = []
		_nLen_ = @oString.NumberOfChars()

		if _nStart_ < 1 or _nStart_ > _nLen_
			return _acResult_
		ok

		_i_ = _nStart_
		while _i_ >= 1 and _i_ <= _nLen_
			_acResult_ + @oString.NthChar(_i_)
			_i_ += nStep
		end

		return _acResult_
