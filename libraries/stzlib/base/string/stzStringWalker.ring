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


class stzStringWalker

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

	def AddWalker(pcWalkerName, nStart, nEnd, nStep)
		@aWalkers + [ pcWalkerName, new stzWalker(nStart, nEnd, nStep) ]

		def AddWalkerQ(pcWalkerName, nStart, nEnd, nStep)
			This.AddWalker(pcWalkerName, nStart, nEnd, nStep)
			return This

	def Walker(pcWalkerName)
		nLen = len(@aWalkers)
		for i = 1 to nLen
			if @aWalkers[i][1] = pcWalkerName
				return @aWalkers[i][2].Walkables()
			ok
		next
		StzRaise("Incorrect param value! pcWalkerName must be a valid walker name.")

	def WalkerQ(pcWalkerName)
		nLen = len(@aWalkers)
		for i = 1 to nLen
			if @aWalkers[i][1] = pcWalkerName
				return @aWalkers[i][2]
			ok
		next
		StzRaise("Incorrect param value! pcWalkerName must be a valid walker name.")

	def Walkers()
		return @aWalkers

	def RemoveWalker(pcWalkerName)
		nLen = len(@aWalkers)
		nPos = 0
		for i = 1 to nLen
			if @aWalkers[i][1] = pcWalkerName
				nPos = i
				exit
			ok
		next

		if nPos > 0
			ring_remove(@aWalkers, nPos)
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
		acAll = This.Chars()
		acResult = []
		nLen = len(acAll)

		for i = 1 to nLen
			bFound = 0
			nResLen = len(acResult)
			for j = 1 to nResLen
				if acResult[j] = acAll[i]
					bFound = 1
					exit
				ok
			next
			if NOT bFound
				acResult + acAll[i]
			ok
		next

		return acResult

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

	def WalkAndYield(nStart, nEnd, nStep, pcCode)
		acResult = []
		nLen = @oString.NumberOfChars()

		if nStart < 1
			nStart = 1
		ok
		if nEnd > nLen
			nEnd = nLen
		ok

		i = nStart
		while i <= nEnd
			@char = @oString.NthChar(i)
			@position = i

			cCode = pcCode
			eval(cCode)
			acResult + @char

			i += nStep
		end

		return acResult

	  #===============================#
	 #     WALK FORWARD/BACKWARD     #
	#===============================#

	def CharsFromTo(n1, n2)
		acResult = []
		nLen = @oString.NumberOfChars()

		if n1 < 1 or n2 < 1 or n1 > nLen or n2 > nLen
			return acResult
		ok

		if n1 <= n2
			for i = n1 to n2
				acResult + @oString.NthChar(i)
			next
		else
			for i = n1 to n2 step -1
				acResult + @oString.NthChar(i)
			next
		ok

		return acResult

	def CharsWithStep(nStart, nStep)
		acResult = []
		nLen = @oString.NumberOfChars()

		if nStart < 1 or nStart > nLen
			return acResult
		ok

		i = nStart
		while i >= 1 and i <= nLen
			acResult + @oString.NthChar(i)
			i += nStep
		end

		return acResult
