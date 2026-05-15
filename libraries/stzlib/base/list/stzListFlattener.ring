#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTFLATTENER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List flattener subclass -- flattening,      #
#                  type conversion, associating operations.     #
#                  For aliases, use stzListFlattenerXT.         #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListFlattener from stzList

	  #============================#
	 #     FLATTENING THE LIST    #
	#============================#

	def Flatten()
		aContent = This.Content()
		nLen = This.NumberOfItems()

		aResult = []
		aTemp = []

		for i = 1 to nLen

			if isList(aContent[i])

				aTemp = Q(aContent[i]).Flattened()
				nLenTemp = len(aTemp)

				for j = 1 to nLenTemp
					aResult + aTemp[j]
				next
			else
				aResult + aContent[i]
			ok
		next

		This.Update(aResult)

		def FlattenQ()
			This.Flatten()
			return This

	def Flattened()
		aResult = This.Copy().FlattenQ().Content()
		return aResult

	  #=======================================#
	 #     ASSOCIATE WITH AN ANOTHER LIST    #
	#=======================================#

	def AssociateWith(paOtherList)

		if NOT isList(paOtherList)
			StzRaise("Incorrect param type!")
		ok

		aResult = []
		nLen  = This.NumberOfItems()
		nLenOtherList = len(paOtherList)

		aContent = This.Content()

		for i = 1 to nLen
			otherItem = ""
			if i <= nLenOtherList
				otherItem = paOtherList[i]
			ok

			aResult + [ aContent[i], otherItem ]
		next

		This.Update( aResult )

		def AssociateWithQ(paOtherList)
			This.AssociateWith(paOtherList)
			return This

	def AssociatedWith(paOtherList)
		aResult = This.Copy().AssociateWithQ(paOtherList).Content()
		return aResult

	  #===============================#
	 #     TYPE CONVERSION          #
	#===============================#

	def ToStzTable()
		return new stzTable( This.Content() )

	def ToStzGrid()
		return new stzGrid( This.Content() )

	def ToStzSet()
		return new stzSet( This.ToSet() )

	def ToStzListOfNumbers()
		return new stzListOfNumbers( This.Content() )

	def ToStzListOfLists()
		return new stzListOfLists(This.Content())

	def ToStzListOfPairs()
		return new stzListOfPairs(This.Content())

	def ToStzListOfStrings()
		return new stzListOfStrings(This.Content())

	def ToStzHashList()
		return new stzHashList( This.List() )

	  #=====================================#
	 #     STRINGIFYING THE LIST          #
	#=====================================#

	def Stringify()
		aContent = This.Content()
		nLen = len(aContent)

		acResult = []
		for i = 1 to nLen
			acResult + @@(aContent[i])
		next

		return acResult

		def Stringified()
			return This.Stringify()

	  #=======================================#
	 #     REPEATED LEADING/TRAILING ITEMS  #
	#=======================================#

	def HasRepeatedLeadingItemsCS(pCaseSensitive)
		aLead = This.RepeatedLeadingItemsCS(pCaseSensitive)

		if len(aLead) > 0
			return 1
		else
			return 0
		ok

		def HasLeadingItems()
			return This.HasRepeatedLeadingItemsCS(1)

	def RepeatedLeadingItemsCS(pCaseSensitive)
		aContent = This.Content()
		nLen = len(aContent)

		if nLen <= 1
			return []
		ok

		cFirst = @@(aContent[1])
		if pCaseSensitive = 0
			cFirst = ring_lower(cFirst)
		ok

		aResult = []
		for i = 2 to nLen
			cItem = @@(aContent[i])
			if pCaseSensitive = 0
				cItem = ring_lower(cItem)
			ok

			if cItem = cFirst
				aResult + aContent[i]
			else
				exit
			ok
		next

		return aResult

	def RepeatedLeadingItems()
		return This.RepeatedLeadingItemsCS(1)

	def HasRepeatedTrailingItemsCS(pCaseSensitive)
		aTrail = This.RepeatedTrailingItemsCS(pCaseSensitive)

		if len(aTrail) > 0
			return 1
		else
			return 0
		ok

	def RepeatedTrailingItemsCS(pCaseSensitive)
		aContent = This.Content()
		nLen = len(aContent)

		if nLen <= 1
			return []
		ok

		cLast = @@(aContent[nLen])
		if pCaseSensitive = 0
			cLast = ring_lower(cLast)
		ok

		aResult = []
		for i = nLen - 1 to 1 step -1
			cItem = @@(aContent[i])
			if pCaseSensitive = 0
				cItem = ring_lower(cItem)
			ok

			if cItem = cLast
				aResult + aContent[i]
			else
				exit
			ok
		next

		return ring_reverse(aResult)

	def RepeatedTrailingItems()
		return This.RepeatedTrailingItemsCS(1)
