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


class stzStringWalker from stzObject

	@oString
	@aWalkers = []

	  #===================#
	 #   INITIALIZATION  #
	#===================#

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

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     ADD/REMOVE WALKERS        #
	#===============================#

	def AddWalker(pcWalkerName, _nStart_, _nEnd_, nStep)
		@aWalkers + [ pcWalkerName, new stzWalker(_nStart_, _nEnd_, nStep) ]

		def AddWalkerQ(pcWalkerName, _nStart_, _nEnd_, nStep)
			This.AddWalker(pcWalkerName, _nStart_, _nEnd_, nStep)
			return This

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

	def Walkers()
		return @aWalkers

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

	def RemoveWalkers()
		@aWalkers = []

	  #===============================#
	 #     CHARS ENUMERATION         #
	#===============================#

	def Chars()
		return @oString.Chars()

		def CharsQ()
			return new stzList(This.Chars())

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

	def CharAt(n)
		if n < 1 or n > @oString.NumberOfChars()
			StzRaise("Index out of range!")
		ok
		return @oString.NthChar(n)

	def FirstChar()
		return This.CharAt(1)

	def LastChar()
		return This.CharAt(@oString.NumberOfChars())

	  #===============================#
	 #     WALK AND YIELD            #
	#===============================#

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
