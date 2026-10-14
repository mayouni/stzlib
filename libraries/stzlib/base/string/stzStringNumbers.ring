#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STZSTRINGNUMBERS             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String numbers -- Wraps stzString via       #
#                  composition. Extracting and working with    #
#                  numbers embedded in strings.                #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


# Reads the numbers written inside a text, and sums, ranks, replaces or removes them.
#
# Build one with new stzStringNumbers("text"); stzString does not hand one out. Numbers returns the
# figures in order as numbers: a sign directly before a digit belongs to the figure, a point between
# two digits makes a decimal, and only ASCII digits count, so Arabic-Indic digits and the 1 and 0 of
# 1,000 are read as the characters they are. The statistics (SumOfNumbers, MaxNumber, MinNumber,
# AverageOfNumbers, NthNumber) are built on Numbers; Max, Min, Average and the First, Last and Nth
# readers raise when the text holds no number, whereas the sum answers 0. RemoveNumbers and
# ReplaceNumbers edit the held text in place and work digit run by digit run, so the signs and
# points stay; NumbersRemoved and NumbersReplaced return the edited text and leave the object alone.
# Found today: a run with two points such as 1.2.3 raises R41 in Numbers and everything built on it;
# ScanInteger stops the Ring process above 2147483647; and the in-place edits on an object built
# from a stzString leave that stzString empty.
#
#   receiver   o1 = new stzStringNumbers("Invoice 12 costs -3.5 and +7, total 10")
#   example    ? @@( o1.Numbers() )
#              #--> [ 12, -3.50, 7, 10 ]
#              ? o1.SumOfNumbers()
#              #--> 25.50
#              ? o1.NthNumber(2)
#              #--> -3.50
#              o2 = new stzStringNumbers("שלום 12 עולם 7.5")
#              ? @@( o2.PositionsOfNumbers() )
#              #--> [ 6, 14, 16 ]
#              o3 = new stzStringNumbers("a😀1😀22")
#              ? @@( o3.Numbers() )
#              #--> [ 1, 22 ]
#   see        stzString, stzListOfNumbers
class stzStringNumbers from stzObject

	@oString

	# Builds a number extractor over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the text to read numbers from, or a stzString that the object then edits
	#   returns           nothing; the object is built
	#   note              stzString does not build one: its own Numbers is a different method; build
	#                     one with new stzStringNumbers("text")
	#   warning           RemoveNumbers and ReplaceNumbers on an object built from a stzString leave
	#                     that stzString EMPTY while the extractor holds the new text; confirmed
	#                     twice, so pass a text, not a stzString, when the edit matters
	#   see               Numbers, Content
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringNumbers! Parameter must be a string or stzString object.")
		ok

	# Returns the text held, with the edits made so far.
	#
	#   returns    a text
	#   see        NumberOfChars, Numbers
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, a Hebrew letter or an emoji counting as one.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text holds no character at all.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfChars
	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     EXTRACT NUMBERS           #
	#===============================#

	# Returns the numbers written in the text, in order, as numbers; a sign directly before a digit belongs to the number.
	#
	#   returns    a list of numbers; [ ] when there are none
	#   note       ExtractNumbers is the same call, NumbersQ returns a stzList; Invoice 12 costs
	#              -3.5 and +7 gives 12, -3.5, 7; 5-10 gives 5 and 10, the dash after a digit is not
	#              a sign; 1,000 gives 1 and 0; a figure beyond 15 digits loses precision
	#   warning    a run with two decimal points such as 1.2.3 or 192.168.0.1 raises R41 Invalid
	#              numeric string, and so does every method built on Numbers; only ASCII digits
	#              count, so the Arabic-Indic ١٢٣ is skipped
	#   see        NumbersAsStrings, PositionsOfNumbers
	def Numbers()
		_acChars_ = @oString.Chars()
		_nLen_ = StzLen(@oString.Content())
		_anResult_ = []
		_cNum_ = ""

		for i = 1 to _nLen_
			_c_ = _acChars_[i]

			if isDigit(_c_)
				_cNum_ += _c_

			but (_c_ = "-" or _c_ = "+") and _cNum_ = ""
				_cNext_ = ""
				if i + 1 <= _nLen_
					_cNext_ = _acChars_[i + 1]
				ok
				if isDigit(_cNext_)
					_cNum_ = _c_
				ok

			but _c_ = "." and _cNum_ != ""
				_cNext_ = ""
				if i + 1 <= _nLen_
					_cNext_ = _acChars_[i + 1]
				ok
				if isDigit(_cNext_)
					_cNum_ += _c_
				else
					_anResult_ + (0 + _cNum_)
					_cNum_ = ""
				ok

			else
				if _cNum_ != "" and _cNum_ != "-" and _cNum_ != "+"
					_anResult_ + (0 + _cNum_)
				ok
				_cNum_ = ""
			ok
		next

		if _cNum_ != "" and _cNum_ != "-" and _cNum_ != "+"
			_anResult_ + (0 + _cNum_)
		ok

		return _anResult_

		def NumbersQ()
			return new stzList(This.Numbers())

		def ExtractNumbers()
			return This.Numbers()

	  #===============================#
	 #     NUMBER COUNT              #
	#===============================#

	# Returns how many numbers the text holds.
	#
	#   returns    a number
	#   note       CountNumbers and HowManyNumbers are the same call; it raises like Numbers on a
	#              run such as 1.2.3
	#   see        Numbers, ContainsNumbers
	def NumberOfNumbers()
		return len(This.Numbers())

		def CountNumbers()
			return This.NumberOfNumbers()

		def HowManyNumbers()
			return This.NumberOfNumbers()

	  #===============================#
	 #     CONTAINS NUMBERS          #
	#===============================#

	# TRUE if the text holds at least one number.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   warning    raises like Numbers on a run such as 1.2.3
	#   see        NumberOfNumbers, ContainsOnlyNumbers
	def ContainsNumbers()
		return This.NumberOfNumbers() > 0

	# TRUE if every character of the text is a digit, a point, a minus or a plus.
	#
	#   returns    TRUE or FALSE, as 1 or 0; TRUE for an empty text
	#   note       42 gives 1, 42abc gives 0
	#   warning    it tests characters, not number syntax: -.+ and 1-2-3 give 1, and abc gives 0
	#   see        ContainsNumbers
	def ContainsOnlyNumbers()
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)

		for i = 1 to _nLen_
			_c_ = _acChars_[i]
			if NOT isDigit(_c_) and _c_ != "." and _c_ != "-" and _c_ != "+"
				return 0
			ok
		next
		return 1

	  #===============================#
	 #     REMOVE NUMBERS            #
	#===============================#

	# Deletes every ASCII digit from the text, in place.
	#
	#   returns    nothing; the text changes. RemoveNumbersQ returns the object for chaining
	#   note       a1b22c333 gives abc
	#   warning    the signs and points around the digits stay: x 5 y 10 z 5.5 gives x  y  z .; on
	#              an object built from a stzString the original stzString is left empty
	#   see        NumbersRemoved, ReplaceNumbers
	def RemoveNumbers()
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_cResult_ = ""

		for i = 1 to _nLen_
			_c_ = _acChars_[i]
			if NOT isDigit(_c_)
				_cResult_ += _c_
			ok
		next

		@oString.Update(_cResult_)

		def RemoveNumbersQ()
			This.RemoveNumbers()
			return This

	# Returns the text with every ASCII digit deleted, leaving the object as it is.
	#
	#   returns    a text
	#   note       works on a copy, so it is safe on an object built from a stzString
	#   warning    the signs and points stay: Invoice 12 costs -3.5 gives Invoice  costs -.
	#   see        RemoveNumbers, NumbersReplaced
	def NumbersRemoved()
		_oCopy_ = new stzStringNumbers(@oString.Content())
		_oCopy_.RemoveNumbers()
		return _oCopy_.Content()

	  #===============================#
	 #     SUM / STATS               #
	#===============================#

	# Returns the sum of the numbers in the text.
	#
	#   returns    a number; 0 when there are none
	#   note       10 20 30 gives 60; 10-5 and 3+4 gives 22
	#   warning    raises like Numbers on a run such as 1.2.3
	#   see        AverageOfNumbers, MaxNumber
	def SumOfNumbers()
		_anNums_ = This.Numbers()
		_nSum_ = 0
		_nLen_ = len(_anNums_)
		for i = 1 to _nLen_
			_nSum_ += _anNums_[i]
		next
		return _nSum_

	  #===============================#
	 #     MAX / MIN / AVERAGE       #
	#===============================#

	# Returns the largest number in the text.
	#
	#   returns    a number
	#   note       Invoice 12 costs -3.5 and +7, total 10 gives 12
	#   warning    raises No numbers found in the string! when the text holds none
	#   see        MinNumber, SumOfNumbers
	def MaxNumber()
		_anNums_ = This.Numbers()
		_nLen_ = len(_anNums_)
		if _nLen_ = 0
			StzRaise("No numbers found in the string!")
		ok

		_nMax_ = _anNums_[1]
		for i = 2 to _nLen_
			if _anNums_[i] > _nMax_
				_nMax_ = _anNums_[i]
			ok
		next
		return _nMax_

	# Returns the smallest number in the text.
	#
	#   returns    a number
	#   note       the same text gives -3.5
	#   warning    raises No numbers found in the string! when the text holds none
	#   see        MaxNumber, SumOfNumbers
	def MinNumber()
		_anNums_ = This.Numbers()
		_nLen_ = len(_anNums_)
		if _nLen_ = 0
			StzRaise("No numbers found in the string!")
		ok

		_nMin_ = _anNums_[1]
		for i = 2 to _nLen_
			if _anNums_[i] < _nMin_
				_nMin_ = _anNums_[i]
			ok
		next
		return _nMin_

	# Returns the mean of the numbers in the text.
	#
	#   returns    a number
	#   note       1 2 gives 1.5
	#   warning    raises No numbers found in the string! when the text holds none
	#   see        SumOfNumbers, MaxNumber
	def AverageOfNumbers()
		_anNums_ = This.Numbers()
		_nLen_ = len(_anNums_)
		if _nLen_ = 0
			StzRaise("No numbers found in the string!")
		ok

		_nSum_ = 0
		for i = 1 to _nLen_
			_nSum_ += _anNums_[i]
		next
		return _nSum_ / _nLen_

	  #===============================#
	 #     NTH / FIRST / LAST       #
	#===============================#

	# Returns the nth number of the text.
	#
	#   n          which number, counting from 1
	#   returns    a number
	#   note       in 12, -3.5, 7, 10 the second is -3.5
	#   warning    raises Index out of range! for 0, a negative n or a count beyond the last
	#   see        FirstNumber, LastNumber, Numbers
	def NthNumber(n)
		_anNums_ = This.Numbers()
		if n >= 1 and n <= len(_anNums_)
			return _anNums_[n]
		ok
		StzRaise("Index out of range!")

	# Returns the first number of the text.
	#
	#   returns    a number
	#   note       Invoice 12 costs gives 12
	#   warning    raises Index out of range! when the text holds none
	#   see        LastNumber, NthNumber
	def FirstNumber()
		return This.NthNumber(1)

	# Returns the last number of the text.
	#
	#   returns    a number
	#   note       Invoice 12 costs -3.5 and +7, total 10 gives 10
	#   warning    raises Index out of range! when the text holds none
	#   see        FirstNumber, NthNumber
	def LastNumber()
		return This.NthNumber(This.NumberOfNumbers())

	  #===============================#
	 #     REPLACE NUMBERS           #
	#===============================#

	# Replaces every run of ASCII digits with a value, in place.
	#
	#   nNewValue   the value written in place of each run
	#   returns     nothing; the text changes. ReplaceNumbersQ returns the object for chaining
	#   note        x 5 y 10 z 5.5 with 9 gives x 9 y 9 z 9.9
	#   warning     each run of digits is replaced on its own, so 5.5 becomes two replacements
	#               around the point and -3.5 keeps its sign; on an object built from a stzString
	#               the original stzString is left empty
	#   see         NumbersReplaced, RemoveNumbers
	def ReplaceNumbers(nNewValue)
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_cResult_ = ""
		_cNewStr_ = "" + nNewValue
		_bInNum_ = 0

		for i = 1 to _nLen_
			_c_ = _acChars_[i]

			if isDigit(_c_)
				if NOT _bInNum_
					_cResult_ += _cNewStr_
					_bInNum_ = 1
				ok
			else
				_bInNum_ = 0
				_cResult_ += _c_
			ok
		next

		@oString.Update(_cResult_)

		def ReplaceNumbersQ(nNewValue)
			This.ReplaceNumbers(nNewValue)
			return This

	# Returns the text with every run of ASCII digits replaced by a value, leaving the object as it is.
	#
	#   nNewValue   the value written in place of each run, joined as text
	#   returns     a text
	#   note        works on a copy, so it is safe on an object built from a stzString
	#   warning     the signs and points stay: Invoice 12 costs -3.5 with 0 gives Invoice 0 costs
	#               -0.0
	#   see         ReplaceNumbers, NumbersRemoved
	def NumbersReplaced(nNewValue)
		_oCopy_ = new stzStringNumbers(@oString.Content())
		_oCopy_.ReplaceNumbers(nNewValue)
		return _oCopy_.Content()

	  #===============================#
	 #     NUMBERS AS STRINGS        #
	#===============================#

	# Returns each number of the text written as a text.
	#
	#   returns    a list of texts
	#   note       12 and -3.5 give 12 and -3.50 when printed through a list
	#   warning    the numbers are converted with Ring's two-decimal text form, so 3.14159 comes out
	#              as 3.14 although Numbers holds the full value; raises like Numbers on a run such
	#              as 1.2.3
	#   see        Numbers
	def NumbersAsStrings()
		_anNums_ = This.Numbers()
		_acResult_ = []
		_nLen_ = len(_anNums_)

		for i = 1 to _nLen_
			_acResult_ + ("" + _anNums_[i])
		next

		return _acResult_

	  #===============================#
	 #     POSITIONS OF NUMBERS      #
	#===============================#

	# Returns the position where each run of ASCII digits starts, counted in characters.
	#
	#   returns    a list of numbers; [ ] when there are none
	#   note       5.5 is two runs, so x 5 y 10 z 5.5 gives 3, 7, 12 and 14; Hebrew and emoji text
	#              count by characters: a😀1😀22 gives 3 and 5
	#   see        Numbers, ScanInteger
	def PositionsOfNumbers()
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_anPositions_ = []
		_bInNum_ = 0

		for i = 1 to _nLen_
			_c_ = _acChars_[i]

			if isDigit(_c_)
				if NOT _bInNum_
					_anPositions_ + i
					_bInNum_ = 1
				ok
			else
				_bInNum_ = 0
			ok
		next

		return _anPositions_

	  #===============================#
	 #     SCAN INTEGER              #
	#===============================#

	# Returns the first integer written in the text, skipping any text before it.
	#
	#   returns    a number; 0 when the text has no digit
	#   note       42abc gives 42, a1b99 gives 1, -17x gives -17, abc gives 0
	#   warning    an integer above 2147483647, or the value -2147483648, stops the Ring process
	#              with an integer overflow panic in stz_string.dll; confirmed with 99999999999,
	#              3000000000 and a 30 digit figure
	#   see        Numbers, FirstNumber
	def ScanInteger()
		_pH_ = @oString.Engine()
		return StzEngineStringScanInt(_pH_)
