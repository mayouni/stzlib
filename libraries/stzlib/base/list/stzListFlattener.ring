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

class stzListFlattener

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListFlattener! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oList.Content()

	def NumberOfItems()
		return @oList.NumberOfItems()

	def IsEmpty()
		return @oList.IsEmpty()

	def Copy()
		return new stzListFlattener( @oList.Content() )

	def Update(paNewContent)
		@oList.UpdateWith(paNewContent)

	def UpdateWith(paNewContent)
		@oList.UpdateWith(paNewContent)

	def List()
		return @oList.List()

	def ToSet()
		return UCS(This.Content(), 1)

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
			cFirst = StzLower(cFirst)
		ok

		aResult = []
		for i = 2 to nLen
			cItem = @@(aContent[i])
			if pCaseSensitive = 0
				cItem = StzLower(cItem)
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
			cLast = StzLower(cLast)
		ok

		aResult = []
		for i = nLen - 1 to 1 step -1
			cItem = @@(aContent[i])
			if pCaseSensitive = 0
				cItem = StzLower(cItem)
			ok

			if cItem = cLast
				aResult + aContent[i]
			else
				exit
			ok
		next

		oTemp = new stzList(aResult)
		pTmp = oTemp._EngineListFromContent()
		StzEngineListReverse(pTmp)
		aReversed = oTemp._ContentFromEngineList(pTmp)
		StzEngineListFree(pTmp)
		return aReversed

	def RepeatedTrailingItems()
		return This.RepeatedTrailingItemsCS(1)

	  #=======================================#
	 #     DEEP FLATTENING THE LIST          #
	#=======================================#

	def DeepFlatten()
		pList = @oList._EngineListFromContent()
		pResult = StzEngineListDeepFlatten(pList)
		StzEngineListFree(pList)
		This.Update(StzEngineContentFromList(pResult))
		StzEngineListFree(pResult)

		def DeepFlattenQ()
			This.DeepFlatten()
			return This

	def DeepFlattened()
		pList = @oList._EngineListFromContent()
		pResult = StzEngineListDeepFlatten(pList)
		StzEngineListFree(pList)
		aResult = StzEngineContentFromList(pResult)
		StzEngineListFree(pResult)
		return aResult

	  #=======================================#
	 #     FLATTENING TO A GIVEN DEPTH       #
	#=======================================#

	def FlattenToDepth(n)
		pList = @oList._EngineListFromContent()
		pResult = StzEngineListFlattenToDepth(pList, n)
		StzEngineListFree(pList)
		This.Update(StzEngineContentFromList(pResult))
		StzEngineListFree(pResult)

		def FlattenToDepthQ(n)
			This.FlattenToDepth(n)
			return This

	def FlattenedToDepth(n)
		pList = @oList._EngineListFromContent()
		pResult = StzEngineListFlattenToDepth(pList, n)
		StzEngineListFree(pList)
		aResult = StzEngineContentFromList(pResult)
		StzEngineListFree(pResult)
		return aResult

	  #=======================================#
	 #     PAIRED (GROUP INTO PAIRS)         #
	#=======================================#

	def Paired()
		pList = @oList._EngineListFromContent()
		pResult = StzEngineListPaired(pList)
		StzEngineListFree(pList)
		aResult = StzEngineContentFromList(pResult)
		StzEngineListFree(pResult)
		return aResult

	  #=======================================#
	 #     CHUNKED (GROUP INTO N-SIZE)       #
	#=======================================#

	def Chunked(n)
		pList = @oList._EngineListFromContent()
		pResult = StzEngineListChunked(pList, n)
		StzEngineListFree(pList)
		aResult = StzEngineContentFromList(pResult)
		StzEngineListFree(pResult)
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
