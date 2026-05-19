#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTSORTER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List sorter subclass -- sorting, reversing, #
#                  classifying operations.                      #
#                  For aliases, use stzListSorterXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListSorter from stzList

	  #=============================#
	 #  SORTING ORDER OF THE LIST  #
	#=============================#

	def SortingOrder()
		cResult = :Unsorted

		if This.IsSorted()
			if This.IsSortedInAscending()
				cResult = :Ascending
			else
				cResult = :Descending
			ok
		ok

		return cResult

	def HasSameSortingOrderAs(paOtherList)
		if _ListSortingOrder(paOtherList) = This.SortingOrder()
			return 1
		else
			return 0
		ok

		def HasSameOrderAs(paOtherList)
			return This.HasSameSortingOrderAs(paOtherList)

	  #-----------------------------------#
	 #  IS THE LIST SORTED OR UNSORTED?  #
	#-----------------------------------#

	def IsSorted()
		if This.IsSortedInAscending() or
		   This.IsSortedInDescending()
			return 1
		else
			return 0
		ok

	def IsSortedInAscending()
		aContent = This.Content()
		nLen = len(aContent)

		aSorted = @SortList(aContent)

		bResult = 1

		for i = 1 to nLen
			cItem   = @@(aContent[i])
			cSorted = @@(aSorted[i])

			if cItem != cSorted
				bResult = 0
				exit
			ok
		next

		return bResult

		def IsSortedUp()
			return This.IsSortedInAscending()

	def IsSortedInDescending()
		aContent = This.Content()
		nLen = len(aContent)

		aSorted = ring_reverse( @SortList(aContent) )

		bResult = 1

		for i = 1 to nLen
			cItem   = @@(aContent[i])
			cSorted = @@(aSorted[i])

			if cItem != cSorted
				bResult = 0
				exit
			ok
		next

		return bResult

		def IsSortedDown()
			return This.IsSortedInDescending()

	def IsUnsorted()
		return NOT This.IsSorted()

	  #----------------------------------#
	 #  SORTING THE ITEMS IN ASCENDING  #
	#----------------------------------#

	def SortInAscending()
		aResult = @SortList( This.Content() )
		This.Update( aResult )

		def SortInAscendingQ()
			This.SortInAscending()
			return This

		def Sort()
			This.SortInAscending()

			def SortQ()
				return This.SortInAscendingQ()

		def SortUp()
			This.SortInAscending()

	def SortedInAscending()
		aResult = This.Copy().SortInAscendingQ().Content()
		return aResult

		def Sorted()
			return This.SortedInAscending()

		def SortedUp()
			return This.SortedInAscending()

	  #-----------------------------------#
	 #  SORTING THE ITEMS IN DESCENDING  #
	#-----------------------------------#

	def SortInDescending()
		aResult = ring_reverse( This.SortedInAscending() )
		This.Update( aResult )

		def SortInDescendingQ()
			This.SortInDescending()
			return This

		def SortDown()
			This.SortInDescending()

	def SortedInDescending()
		aResult = This.Copy().SortInDescendingQ().Content()
		return aResult

		def SortedDown()
			return This.SortedInDescending()

	  #--------------------------------------------#
	 #  SORTING BY AN EVALUATED EXPRESSION        #
	#--------------------------------------------#

	def SortByInAscending(pcExpr)
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen - 1
			for j = i + 1 to nLen
				@item = aContent[i]
				@item2 = aContent[j]
				cCode = 'bSwap = (' + pcExpr + ')'
				eval(cCode)
				if bSwap
					temp = aContent[i]
					aContent[i] = aContent[j]
					aContent[j] = temp
				ok
			next
		next

		This.UpdateWith(aContent)

		def SortBy(pcExpr)
			This.SortByInAscending(pcExpr)

	def SortByInDescending(pcExpr)
		This.SortByInAscending(pcExpr)
		This.Reverse()

	  #-------------------------------------#
	 #  REVERSING ITEMS ORDER IN THE LIST  #
	#-------------------------------------#

	def Reverse()
		aResult = ring_reverse( This.List() )
		This.Update( aResult )

		def ReverseQ()
			This.Reverse()
			return This

		def ReverseItems()
			This.Reverse()

	def Reversed()
		aResult = ring_reverse(This.Content())
		return aResult

		def ItemsReversed()
			return This.Reversed()

	  #==============================#
	 #    CLASSIFYING              #
	#==============================#

	def Classify()
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			cKey = @@(aContent[i])
			bFound = 0

			nResultLen = len(aResult)
			for j = 1 to nResultLen
				if aResult[j][1] = cKey
					aResult[j][2] + i
					bFound = 1
					exit
				ok
			next

			if bFound = 0
				aResult + [ cKey, [i] ]
			ok
		next

		return aResult

		def Categorize()
			return This.Classify()

		def Categorise()
			return This.Classify()

	  #==============================#
	 #    STABLE SORT BY KEY        #
	#==============================#

	def SortedBy(pcExpr)
		aResult = This.Copy().Content()
		nLen = len(aResult)

		for i = 1 to nLen - 1
			for j = i + 1 to nLen
				@item = aResult[i]
				@item2 = aResult[j]
				cCode = 'bSwap = (' + pcExpr + ')'
				eval(cCode)
				if bSwap
					temp = aResult[i]
					aResult[i] = aResult[j]
					aResult[j] = temp
				ok
			next
		next

		return aResult

		def SortedByInAscending(pcExpr)
			return This.SortedBy(pcExpr)

	def SortedByInDescending(pcExpr)
		return ring_reverse(This.SortedBy(pcExpr))

	  #==============================#
	 #    MIN / MAX ITEMS           #
	#==============================#

	def Min()
		aContent = This.Content()
		nLen = len(aContent)
		if nLen = 0
			return NULL
		ok

		result = aContent[1]
		for i = 2 to nLen
			if isNumber(aContent[i]) and isNumber(result)
				if aContent[i] < result
					result = aContent[i]
				ok
			but isString(aContent[i]) and isString(result)
				if strcmp(aContent[i], result) < 0
					result = aContent[i]
				ok
			ok
		next

		return result

		def Minimum()
			return This.Min()

	def Max()
		aContent = This.Content()
		nLen = len(aContent)
		if nLen = 0
			return NULL
		ok

		result = aContent[1]
		for i = 2 to nLen
			if isNumber(aContent[i]) and isNumber(result)
				if aContent[i] > result
					result = aContent[i]
				ok
			but isString(aContent[i]) and isString(result)
				if strcmp(aContent[i], result) > 0
					result = aContent[i]
				ok
			ok
		next

		return result

		def Maximum()
			return This.Max()

	def MinMax()
		return [ This.Min(), This.Max() ]

	  #==============================#
	 #    RANKING (ORDINAL POS)     #
	#==============================#

	def Ranked()
		aContent = This.Content()
		nLen = len(aContent)
		aSorted = sort(aContent)

		aResult = []
		for i = 1 to nLen
			nRank = StzFind(aSorted, aContent[i])
			aResult + nRank
		next

		return aResult

		def Ranks()
			return This.Ranked()

	  #==============================#
	 #    NTH SMALLEST / LARGEST   #
	#==============================#

	def NthSmallest(n)
		aSorted = sort(This.Content())
		if n >= 1 and n <= len(aSorted)
			return aSorted[n]
		ok
		return NULL

	def NthLargest(n)
		aSorted = sort(This.Content())
		aSorted = ring_reverse(aSorted)
		if n >= 1 and n <= len(aSorted)
			return aSorted[n]
		ok
		return NULL

	  #==============================#
	 #    MEDIAN                    #
	#==============================#

	def Median()
		aContent = This.Content()
		nLen = len(aContent)
		if nLen = 0
			return 0
		ok

		aSorted = sort(aContent)
		if nLen % 2 = 1
			return aSorted[ (nLen + 1) / 2 ]
		else
			n1 = aSorted[ nLen / 2 ]
			n2 = aSorted[ nLen / 2 + 1 ]
			if isNumber(n1) and isNumber(n2)
				return (n1 + n2) / 2
			else
				return n1
			ok
		ok
