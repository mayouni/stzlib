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


class stzStringNumbers from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringNumbers! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     EXTRACT NUMBERS           #
	#===============================#

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

	def NumberOfNumbers()
		return len(This.Numbers())

		def CountNumbers()
			return This.NumberOfNumbers()

		def HowManyNumbers()
			return This.NumberOfNumbers()

	  #===============================#
	 #     CONTAINS NUMBERS          #
	#===============================#

	def ContainsNumbers()
		return This.NumberOfNumbers() > 0

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

	def NumbersRemoved()
		_oCopy_ = new stzStringNumbers(@oString.Content())
		_oCopy_.RemoveNumbers()
		return _oCopy_.Content()

	  #===============================#
	 #     SUM / STATS               #
	#===============================#

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

	def NthNumber(n)
		_anNums_ = This.Numbers()
		if n >= 1 and n <= len(_anNums_)
			return _anNums_[n]
		ok
		StzRaise("Index out of range!")

	def FirstNumber()
		return This.NthNumber(1)

	def LastNumber()
		return This.NthNumber(This.NumberOfNumbers())

	  #===============================#
	 #     REPLACE NUMBERS           #
	#===============================#

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

	def NumbersReplaced(nNewValue)
		_oCopy_ = new stzStringNumbers(@oString.Content())
		_oCopy_.ReplaceNumbers(nNewValue)
		return _oCopy_.Content()

	  #===============================#
	 #     NUMBERS AS STRINGS        #
	#===============================#

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

	def ScanInteger()
		pH = @oString.Engine()
		return StzEngineStringScanInt(pH)
