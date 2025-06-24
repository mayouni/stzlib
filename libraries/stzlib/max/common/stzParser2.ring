o1 = Parser(1, 9, 3)
o1 {
	? Content()
}

func Parser(nStart, nEnd, nStep)
	return new StzParser(nStart, nEnd, nStep)

class stzParser from stzList
	aContent = []
	nCurrentPosition

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(nStart, nEnd, nStep)
		aResult = []
		for i=nStart to nEnd step nStep
			aResult + i
		next i
		aContent = aResult
		SetCurrentPosition(1)

	  #-----------------#
	 #     CONTENT     #
	#-----------------#

	def Content()
		return aContent

		def Value()
			return Content()

	  #-----------------#
	 #     POSITION    #
	#-----------------#

	def CurrentPosition()
		return aContent[ nCurrentPosition ]

	def SetCurrentPosition(n)
		if n > 0 and n <= len(aContent)
			nCurrentPosition = n
		else
			StzRaise("Out of range!")
		ok

	def NextPosition()
		return NextNthPosition(1)

	def NextNthPosition(n)
		// Important: Don't swap the 2 following lines!
		nNthPosition = aContent[ nCurrentPosition + n ]
		SetCurrentPosition(nCurrentPosition + n)
		return nNthPosition

	def PreviousPosition()
		return PreviousNthPosition(1)

	def PreviousNthPosition(n)
		// Important: Don't swap the 2 following lines!
		nNthPosition = aContent[ nCurrentPosition - n ]
		SetCurrentPosition(nCurrentPosition - n)
		return nNthPosition

	def MoveToPosition(n)
		SetCurrentPosition(n)
		return aContent[n]
