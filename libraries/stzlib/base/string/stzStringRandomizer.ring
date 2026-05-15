#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STZSTRINGRANDOMIZER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String randomizer subclass -- shuffling,    #
#                  random char/substring extraction,            #
#                  random generation operations.                 #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringRandomizer from stzString

	  #===============================#
	 #     SHUFFLE                   #
	#===============================#

	def Shuffle()
		cContent = This.Content()
		nLen = len(cContent)
		acChars = []

		for i = 1 to nLen
			acChars + substr(cContent, i, 1)
		next

		for i = nLen to 2 step -1
			j = random(i - 1) + 1
			cTemp = acChars[i]
			acChars[i] = acChars[j]
			acChars[j] = cTemp
		next

		cResult = ""
		for i = 1 to nLen
			cResult += acChars[i]
		next

		This.Update(cResult)

		def ShuffleQ()
			This.Shuffle()
			return This

	def Shuffled()
		oCopy = new stzStringRandomizer(This.Content())
		oCopy.Shuffle()
		return oCopy.Content()

	  #===============================#
	 #     RANDOM CHAR               #
	#===============================#

	def RandomChar()
		nLen = This.NumberOfChars()
		if nLen = 0
			return ""
		ok
		n = random(nLen - 1) + 1
		return substr(This.Content(), n, 1)

	def RandomChars(n)
		acResult = []
		for i = 1 to n
			acResult + This.RandomChar()
		next
		return acResult

	  #===============================#
	 #     RANDOM SECTION            #
	#===============================#

	def RandomSection(nLen)
		nMax = This.NumberOfChars()
		if nLen > nMax
			nLen = nMax
		ok
		if nLen <= 0
			return ""
		ok

		nStart = random(nMax - nLen) + 1
		return substr(This.Content(), nStart, nLen)

		def RandomSubString(nLen)
			return This.RandomSection(nLen)

