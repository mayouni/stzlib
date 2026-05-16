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
 ///  FUNCTIONS ///
/////////////////

func _DeepFlattenHelper(paList)
	aResult = []
	nLen = len(paList)
	for i = 1 to nLen
		if isList(paList[i])
			aTemp = _DeepFlattenHelper(paList[i])
			for j = 1 to len(aTemp)
				aResult + aTemp[j]
			next
		else
			aResult + paList[i]
		ok
	next
	return aResult

func _FlattenDepthHelper(paList, nDepth)
	if nDepth = 0
		return paList
	ok
	aResult = []
	nLen = len(paList)
	for i = 1 to nLen
		if isList(paList[i])
			aTemp = _FlattenDepthHelper(paList[i], nDepth - 1)
			for j = 1 to len(aTemp)
				aResult + aTemp[j]
			next
		else
			aResult + paList[i]
		ok
	next
	return aResult


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

	  #=======================================#
	 #     DEEP FLATTENING THE LIST          #
	#=======================================#

	def DeepFlatten()
		aResult = _DeepFlattenHelper(This.Content())
		This.Update(aResult)

		def DeepFlattenQ()
			This.DeepFlatten()
			return This

	def DeepFlattened()
		return _DeepFlattenHelper(This.Content())

	  #=======================================#
	 #     FLATTENING TO A GIVEN DEPTH       #
	#=======================================#

	def FlattenToDepth(n)
		aResult = _FlattenDepthHelper(This.Content(), n)
		This.Update(aResult)

		def FlattenToDepthQ(n)
			This.FlattenToDepth(n)
			return This

	def FlattenedToDepth(n)
		return _FlattenDepthHelper(This.Content(), n)

	  #=======================================#
	 #     TO SET (REMOVE DUPLICATES)        #
	#=======================================#

	def ToSet()
		return UCS(This.Content(), 1)

	  #=======================================#
	 #     PAIRED (GROUP INTO PAIRS)         #
	#=======================================#

	def Paired()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []

		for i = 1 to nLen step 2
			if i + 1 <= nLen
				aResult + [ aContent[i], aContent[i+1] ]
			else
				aResult + [ aContent[i], NULL ]
			ok
		next

		return aResult

	  #=======================================#
	 #     CHUNKED (GROUP INTO N-SIZE)       #
	#=======================================#

	def Chunked(n)
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []

		i = 1
		while i <= nLen
			aChunk = []
			for j = 0 to n - 1
				if i + j <= nLen
					aChunk + aContent[i + j]
				ok
			next
			aResult + [aChunk]
			i += n
		end

		return aResult

	  #=======================================#
	 #     INTERLEAVE WITH ANOTHER LIST      #
	#=======================================#

	def InterleavedWith(paOther)
		aContent = This.Content()
		nLen1 = len(aContent)
		nLen2 = len(paOther)
		nMax = nLen1
		if nLen2 > nMax
			nMax = nLen2
		ok

		aResult = []
		for i = 1 to nMax
			if i <= nLen1
				aResult + aContent[i]
			ok
			if i <= nLen2
				aResult + paOther[i]
			ok
		next

		return aResult

	  #=======================================#
	 #     OBJECTIFIED (ITEMS AS OBJECTS)    #
	#=======================================#

	def Objectified()
		aContent = This.Content()
		nLen = len(aContent)
		aoResult = []

		for i = 1 to nLen
			if isString(aContent[i])
				aoResult + new stzString(aContent[i])
			but isNumber(aContent[i])
				aoResult + new stzNumber(aContent[i])
			but isList(aContent[i])
				aoResult + new stzList(aContent[i])
			else
				aoResult + aContent[i]
			ok
		next

		return aoResult
