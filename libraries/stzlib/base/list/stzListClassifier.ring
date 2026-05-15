#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTCLASSIFIER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List classifier subclass -- classification #
#                  and categorization of list items.           #
#                  For aliases, use stzListClassifierXT.        #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListClassifier from stzList

	def Classify()
		acContent = This.StringifyQ().Lowercased()
		nLen = len(acContent)
		acSeen = []
		aResult = []
		for i = 1 to nLen
			if isString(acContent[i])
				n = ring_find(acSeen, acContent[i])
				if n = 0
					acSeen + acContent[i]
					aResult + [acContent[i], [i]]
				else
					aResult[n][2] + i
				ok
			ok
		next
		return aResult

		def ClassifyQ()
			return new stzList(This.Classify())

	def Classified()
		return This.Classify()

	def Classes()
		aClassified = This.Classify()
		nLen = len(aClassified)
		aResult = []
		for i = 1 to nLen
			aResult + aClassified[i][1]
		next
		return aResult

	def ClassifyBy(pcExpr)
		aContent = This.Content()
		nLen = len(aContent)
		acSeen = []
		aResult = []
		for i = 1 to nLen
			@item = aContent[i]
			cValue = "" + eval(pcExpr)
			n = ring_find(acSeen, cValue)
			if n = 0
				acSeen + cValue
				aResult + [cValue, [i]]
			else
				aResult[n][2] + i
			ok
		next
		return aResult

	def PartsCS(pCaseSensitive)
		return This.Classify()

	def Parts()
		return This.PartsCS(1)

	  #======================================================#
	 #   NUMBER OF CLASSES                                  #
	#======================================================#

	def NumberOfClasses()
		return len(This.Classes())

	  #======================================================#
	 #   FREQUENCY OF EACH ITEM                             #
	#======================================================#

	def Frequencies()
		aClassified = This.Classify()
		nLen = len(aClassified)
		aResult = []
		for i = 1 to nLen
			aResult + [aClassified[i][1], len(aClassified[i][2])]
		next
		return aResult

	  #======================================================#
	 #   MOST / LEAST FREQUENT                              #
	#======================================================#

	def MostFrequent()
		aFreqs = This.Frequencies()
		nLen = len(aFreqs)
		if nLen = 0
			return NULL
		ok
		nMax = 0
		cResult = ""
		for i = 1 to nLen
			if aFreqs[i][2] > nMax
				nMax = aFreqs[i][2]
				cResult = aFreqs[i][1]
			ok
		next
		return cResult

	def LeastFrequent()
		aFreqs = This.Frequencies()
		nLen = len(aFreqs)
		if nLen = 0
			return NULL
		ok
		nMin = aFreqs[1][2]
		cResult = aFreqs[1][1]
		for i = 2 to nLen
			if aFreqs[i][2] < nMin
				nMin = aFreqs[i][2]
				cResult = aFreqs[i][1]
			ok
		next
		return cResult
