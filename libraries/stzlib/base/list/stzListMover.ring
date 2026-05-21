#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTMOVER               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List mover subclass -- moving and swapping #
#                  items by position. For aliases, use         #
#                  stzListMoverXT.                              #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListMover from stzList

	def Move(n1, n2)
		if CheckingParams()
			if isList(n1) and IsOneOfTheseNamedParamsList(n1, [:From, :FromPosition, :At, :AtPosition])
				n1 = n1[2]
			ok
			if isList(n2) and IsOneOfTheseNamedParamsList(n2, [:To, :ToPosition])
				n2 = n2[2]
			ok
		ok
		item = This.List()[n1]
		ring_remove(This.List(), n1)
		if n2 > n1
			n2 = n2 - 1
		ok
		ring_insert(This.List(), n2 - 1, item)

		def MoveQ(n1, n2)
			This.Move(n1, n2)
			return This

	def Swap(n1, n2)
		if CheckingParams()
			if isList(n1) and IsOneOfTheseNamedParamsList(n1, [:Between, :BetweenPosition, :Position, :ItemAt])
				n1 = n1[2]
			ok
			if isList(n2) and IsOneOfTheseNamedParamsList(n2, [:And, :AndPosition, :Position])
				n2 = n2[2]
			ok
		ok
		temp = This.List()[n1]
		This.List()[n1] = This.List()[n2]
		This.List()[n2] = temp

		def SwapQ(n1, n2)
			This.Swap(n1, n2)
			return This

	def MoveToStart(n)
		This.Move(n, 1)

		def MoveToStartQ(n)
			This.MoveToStart(n)
			return This

		def MoveToFirst(n)
			This.MoveToStart(n)

	def MoveToEnd(n)
		This.Move(n, This.NumberOfItems())

		def MoveToEndQ(n)
			This.MoveToEnd(n)
			return This

		def MoveToLast(n)
			This.MoveToEnd(n)

	  #======================================================#
	 #   SWAP FIRST AND LAST                                #
	#======================================================#

	def SwapFirstAndLast()
		This.Swap(1, This.NumberOfItems())

		def SwapFirstAndLastQ()
			This.SwapFirstAndLast()
			return This

	  #======================================================#
	 #   MOVE MANY ITEMS                                    #
	#======================================================#

	def MoveMany(panPositions, nTo)
		nLen = len(panPositions)
		oTemp = new stzList(panPositions)
		pTmp = oTemp._EngineListFromContent()
		StzEngineListSortDescendingCS(pTmp, 1)
		aSorted = oTemp._ContentFromEngineList(pTmp)
		StzEngineListFree(pTmp)
		aItems = []
		for i = 1 to nLen
			aItems + This.NthItem(aSorted[i])
			ring_remove(This.List(), aSorted[i])
		next
		oTemp2 = new stzList(aItems)
		pTmp2 = oTemp2._EngineListFromContent()
		StzEngineListReverse(pTmp2)
		aItems = oTemp2._ContentFromEngineList(pTmp2)
		StzEngineListFree(pTmp2)
		nInsert = nTo
		if nInsert > This.NumberOfItems()
			nInsert = This.NumberOfItems() + 1
		ok
		for i = 1 to len(aItems)
			ring_insert(This.List(), nInsert - 1, aItems[i])
			nInsert++
		next

		def MoveManyQ(panPositions, nTo)
			This.MoveMany(panPositions, nTo)
			return This

	  #======================================================#
	 #   REVERSE                                            #
	#======================================================#

	def Reverse()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = nLen to 1 step -1
			aResult + aContent[i]
		next
		This.UpdateWith(aResult)

		def ReverseQ()
			This.Reverse()
			return This

	def Reversed()
		return This.Copy().ReverseQ().Content()

	  #======================================================#
	 #   ROTATE -- CIRCULAR SHIFT                           #
	#======================================================#

	def RotateLeft(n)
		pList = _EngineListFromContent()
		StzEngineListRotateLeft(pList, n)
		This.UpdateWith(StzEngineContentFromList(pList))
		StzEngineListFree(pList)

		def RotateLeftQ(n)
			This.RotateLeft(n)
			return This

	def RotatedLeft(n)
		return This.Copy().RotateLeftQ(n).Content()

	def RotateRight(n)
		pList = _EngineListFromContent()
		StzEngineListRotateRight(pList, n)
		This.UpdateWith(StzEngineContentFromList(pList))
		StzEngineListFree(pList)

		def RotateRightQ(n)
			This.RotateRight(n)
			return This

	def RotatedRight(n)
		return This.Copy().RotateRightQ(n).Content()

	  #======================================================#
	 #   SHUFFLE -- RANDOM REORDER                          #
	#======================================================#

	def Shuffle()
		aContent = This.Content()
		nLen = len(aContent)
		for i = nLen to 2 step -1
			j = random(i - 1) + 1
			temp = aContent[i]
			aContent[i] = aContent[j]
			aContent[j] = temp
		next
		This.UpdateWith(aContent)

		def ShuffleQ()
			This.Shuffle()
			return This

	def Shuffled()
		return This.Copy().ShuffleQ().Content()

	  #======================================================#
	 #   MOVE ITEM BY VALUE                                 #
	#======================================================#

	def MoveItemToStart(pItem)
		anPos = This.FindAll(pItem)
		if len(anPos) > 0
			This.MoveToStart(anPos[1])
		ok

	def MoveItemToEnd(pItem)
		anPos = This.FindAll(pItem)
		if len(anPos) > 0
			This.MoveToEnd(anPos[1])
		ok
