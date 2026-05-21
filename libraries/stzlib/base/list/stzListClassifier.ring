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
				n = StzFind(acSeen, acContent[i])
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
		aKeys = This.Map("string(" + pcExpr + ")")
		nLen = len(aKeys)
		acSeen = []
		aResult = []
		for i = 1 to nLen
			cValue = "" + aKeys[i]
			n = StzFind(acSeen, cValue)
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

	  #======================================================#
	 #   GROUP BY EXPRESSION                                #
	#======================================================#

	def GroupBy(pcExpr)
		return This.ClassifyBy(pcExpr)

		def GroupByQ(pcExpr)
			return new stzList(This.GroupBy(pcExpr))

	  #======================================================#
	 #   PARTITION INTO N GROUPS                            #
	#======================================================#

	def Partition(n)
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		nGroupSize = ceil(nLen / n)
		nStart = 1
		for i = 1 to n
			aGroup = []
			nEnd = nStart + nGroupSize - 1
			if nEnd > nLen
				nEnd = nLen
			ok
			for j = nStart to nEnd
				aGroup + aContent[j]
			next
			if len(aGroup) > 0
				aResult + aGroup
			ok
			nStart = nEnd + 1
		next
		return aResult

		def PartitionQ(n)
			return new stzList(This.Partition(n))

	  #======================================================#
	 #   HISTOGRAM -- FREQUENCY AS PAIRS [VALUE, COUNT]     #
	#======================================================#

	def Histogram()
		return This.Frequencies()

		def HistogramQ()
			return new stzList(This.Histogram())

	  #======================================================#
	 #   ITEMS APPEARING EXACTLY N TIMES                    #
	#======================================================#

	def ItemsAppearingNTimes(n)
		aFreqs = This.Frequencies()
		nLen = len(aFreqs)
		aResult = []
		for i = 1 to nLen
			if aFreqs[i][2] = n
				aResult + aFreqs[i][1]
			ok
		next
		return aResult

		def ItemsWithFrequency(n)
			return This.ItemsAppearingNTimes(n)

	  #======================================================#
	 #   ITEMS APPEARING MORE/LESS THAN N TIMES             #
	#======================================================#

	def ItemsAppearingMoreThanNTimes(n)
		aFreqs = This.Frequencies()
		nLen = len(aFreqs)
		aResult = []
		for i = 1 to nLen
			if aFreqs[i][2] > n
				aResult + aFreqs[i][1]
			ok
		next
		return aResult

	def ItemsAppearingLessThanNTimes(n)
		aFreqs = This.Frequencies()
		nLen = len(aFreqs)
		aResult = []
		for i = 1 to nLen
			if aFreqs[i][2] < n
				aResult + aFreqs[i][1]
			ok
		next
		return aResult

	  #======================================================#
	 #   FREQUENCY OF A SPECIFIC ITEM                       #
	#======================================================#

	def FrequencyOf(pItem)
		aContent = This.Content()
		nLen = len(aContent)
		nCount = 0
		for i = 1 to nLen
			if BothAreEqual(aContent[i], pItem)
				nCount++
			ok
		next
		return nCount

		def HowMany(pItem)
			return This.FrequencyOf(pItem)

	  #======================================================#
	 #   MODE -- MOST COMMON ITEMS (ALL TIES)               #
	#======================================================#

	def Mode()
		aFreqs = This.Frequencies()
		nLen = len(aFreqs)
		if nLen = 0
			return []
		ok
		nMax = 0
		for i = 1 to nLen
			if aFreqs[i][2] > nMax
				nMax = aFreqs[i][2]
			ok
		next
		aResult = []
		for i = 1 to nLen
			if aFreqs[i][2] = nMax
				aResult + aFreqs[i][1]
			ok
		next
		return aResult
