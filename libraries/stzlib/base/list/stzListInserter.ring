#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTINSERTER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List inserter subclass -- inserting items,  #
#                  moving, swapping operations.                 #
#                  For aliases, use stzListInserterXT.          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListInserter from stzList

	  #===================================================#
	 #     INSERTING AN ITEM BEFORE A GIVEN POSITION     #
	#===================================================#

	def Insert(pItem, pWhere)

		if isList(pItem) and StzListQ(pItem).IsItemNamedParam()
			pItem = pItem[2]
		ok

		if isList(pWhere)

			oParam = Q(pWhere)

			if oParam.IsOneOfTheseNamedParams([
				:At, :AtPosition, :Before, :BeforePosition ])

				This.InsertBefore(pWhere[2], pItem)
				return

			but oParam.IsOneOfTheseNamedParams([ :After, :AfterPosition ])

				This.InsertAfter(pWhere[2], pItem)
				return
			ok
		else
			This.InsertBefore(pWhere, pItem)
		ok

		def InsertQ(pItem, pWhere)
			This.Insert( pItem, pWhere )
			return This

		def InsertItem(pItem, pWhere)
			This.Insert(pItem, pWhere)

	def InsertBeforePosition(n, pItem)
		if isList(n) and StzListQ(n).IsPositionNamedParam()
			n = n[2]
		ok

		if isList(n) and StzListQ(n).IsListOfNumbers()
			This.InsertBeforePositions(n, pItem)
			return
		ok

		if isList(pItem) and StzListQ(pItem).IsItemNamedParam()
			pItem = pItem[2]
		ok

		if n >= 1 and n <= This.NumberOfItems()
			ring_insert(This.List(), n-1, pItem)

		but n > This.NumberofItems()
			This.ExtendToN(n)
			ring_insert(This.List(), n-1, pItem)
		ok

		def InsertBeforePositionQ(n, pItem)
			This.InsertBeforePosition(n, pItem)
			return This

		def InsertBefore(n, pItem)
			This.InsertBeforePosition(n, pItem)

		def InsertAt(n, pItem)
			if isList(n) and StzListQ(n).IsOneOfTheseNamedParams([ :Position, :ItemAt, :ItemAtPosition ])
				n = n[2]
			ok

			aContent = @aContent
			ring_insert(aContent, n, pItem)
			This.UpdateWith(aContent)

			def InsertAtQ(n, pItem)
				This.InsertAt(n, pItem)
				return This

	  #----------------------------------------------------#
	 #     INSERTING AN ITEM AFTER A GIVEN POSITION      #
	#----------------------------------------------------#

	def InsertAfterPosition(n, pItem)

		if isList(n) and StzListQ(n).IsListOfNumbers()
			This.InsertAfterPositions(n, pItem)
			return
		ok

		if n > 0 and n < This.NumberOfItems()
			ring_insert(This.List(), n, pItem)
		ok

		def InsertAfterPositionQ(n, pItem)
			This.InsertAfterPosition(n, pItem)
			return This

		def InsertAfter(n, pItem)
			This.InsertAfterPosition(n, pItem)

	  #---------------------------------------------#
	 #  INSERTING BEFORE MANY POSITIONS            #
	#---------------------------------------------#

	def InsertBeforePositions(panPositions, pItem)
		if isList(pItem) and StzListQ(pItem).IsItemNamedParam()
			pItem = pItem[2]
		ok

		panPositions = ring_sort(panPositions)
		nLen = len(panPositions)

		for i = nLen to 1 step -1
			This.InsertBeforePosition(panPositions[i], pItem)
		next

		def InsertBeforePositionsQ(panPositions, pItem)
			This.InsertBeforePositions(panPositions, pItem)
			return This

	  #=============================================#
	 #  MOVING ITEM AT POSITION N1 TO POSITION N2 #
	#=============================================#

	def MoveItem(n1, n2)

		if isList(n1) and StzListQ(n1).IsFromNamedParam()
			n1 = n1[2]
		ok

		if isList(n2) and StzListQ(n2).IsToNamedParam()
			n2 = n2[2]
		ok

		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("Incorrect param types! n1 and n2 must be numbers.")
		ok

		if n1 < 1 or n1 > This.NumberOfItems() or
		   n2 < 1 or n2 > This.NumberOfItems()
			StzRaise("Position out of range!")
		ok

		pItem = This.Item(n1)
		This.RemoveItemAtPosition(n1)

		if n2 > n1
			n2 = n2 - 1
		ok

		This.InsertBeforePosition(n2, pItem)

		def MoveItemQ(n1, n2)
			This.MoveItem(n1, n2)
			return This

	  #=========================================#
	 #  SWAPPING ITEMS AT TWO GIVEN POSITIONS  #
	#=========================================#

	def SwapItems(n1, n2)

		if isList(n1) and StzListQ(n1).IsBetweenNamedParam()
			n1 = n1[2]
		ok

		if isList(n2) and StzListQ(n2).IsAndNamedParam()
			n2 = n2[2]
		ok

		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("Incorrect param types! n1 and n2 must be numbers.")
		ok

		aContent = This.Content()
		temp = aContent[n1]
		aContent[n1] = aContent[n2]
		aContent[n2] = temp
		This.UpdateWith(aContent)

		def SwapItemsQ(n1, n2)
			This.SwapItems(n1, n2)
			return This

		def Swap(n1, n2)
			This.SwapItems(n1, n2)
