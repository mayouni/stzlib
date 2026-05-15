#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTGETTER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List getter subclass -- content access,    #
#                  nth/first/last items, N-first/N-last.      #
#                  For aliases, use stzListGetterXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListGetter from stzList

	def ContentCS(pCaseSensitive)
		return This.List()

	def Content()
		return This.ContentCS(1)

	def NthItem(n)
		if CheckingParams()
			if isList(n) and IsOneOfTheseNamedParamsList(n, [:At, :AtPosition, :ItemAt])
				n = n[2]
			ok
		ok
		return This.List()[n]

	def FirstItem()
		return This.NthItem(1)

	def LastItem()
		return This.NthItem(This.NumberOfItems())

	def CentralItem()
		n = ceil(This.NumberOfItems() / 2)
		return This.NthItem(n)

	def NFirstItems(n)
		aResult = []
		for i = 1 to n
			aResult + This.List()[i]
		next
		return aResult

		def NFirstItemsQ(n)
			return new stzList(This.NFirstItems(n))

	def NLastItems(n)
		nLen = This.NumberOfItems()
		aResult = []
		for i = nLen - n + 1 to nLen
			aResult + This.List()[i]
		next
		return aResult

		def NLastItemsQ(n)
			return new stzList(This.NLastItems(n))

	  #======================================================#
	 #   ITEMS AT POSITIONS                                 #
	#======================================================#

	def ItemsAtPositions(panPositions)
		aResult = []
		nLen = len(panPositions)
		for i = 1 to nLen
			aResult + This.List()[panPositions[i]]
		next
		return aResult

		def ItemsAt(panPositions)
			return This.ItemsAtPositions(panPositions)

	  #======================================================#
	 #   SECTION / RANGE                                    #
	#======================================================#

	def Section(n1, n2)
		nLen = This.NumberOfItems()
		if n1 < 1 n1 = 1 ok
		if n2 > nLen n2 = nLen ok
		if n1 > n2
			temp = n1
			n1 = n2
			n2 = temp
		ok
		aResult = []
		for i = n1 to n2
			aResult + This.List()[i]
		next
		return aResult

	def Range(pnStart, pnRange)
		return This.Section(pnStart, pnStart + pnRange - 1)

	  #======================================================#
	 #   UNIQUE ITEMS                                       #
	#======================================================#

	def UniqueItemsCS(pCaseSensitive)
		aResult = []
		aContent = This.Content()
		nLen = len(aContent)
		for i = 1 to nLen
			if NOT ListContainsCS(aResult, aContent[i], pCaseSensitive)
				aResult + aContent[i]
			ok
		next
		return aResult

	def UniqueItems()
		return This.UniqueItemsCS(1)

	  #======================================================#
	 #   RANDOM ITEM                                        #
	#======================================================#

	def RandomItem()
		n = random(This.NumberOfItems() - 1) + 1
		return This.NthItem(n)

	def NRandomItems(n)
		aResult = []
		nLen = This.NumberOfItems()
		if n >= nLen
			return This.Content()
		ok
		anUsed = []
		while len(aResult) < n
			nRand = random(nLen - 1) + 1
			if ring_find(anUsed, nRand) = 0
				anUsed + nRand
				aResult + This.List()[nRand]
			ok
		end
		return aResult

	  #======================================================#
	 #   ITEMS BETWEEN TWO POSITIONS                        #
	#======================================================#

	def ItemsBetween(n1, n2)
		return This.Section(n1, n2)

		def ItemsBetweenQ(n1, n2)
			return new stzList(This.ItemsBetween(n1, n2))

	  #======================================================#
	 #   EVERY NTH ITEM                                     #
	#======================================================#

	def EveryNthItem(n)
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = n to nLen step n
			aResult + aContent[i]
		next
		return aResult

		def EveryNthItemQ(n)
			return new stzList(This.EveryNthItem(n))

		def EveryNth(n)
			return This.EveryNthItem(n)

	  #======================================================#
	 #   HEAD / TAIL                                        #
	#======================================================#

	def Head(n)
		return This.NFirstItems(n)

		def HeadQ(n)
			return new stzList(This.Head(n))

	def Tail(n)
		return This.NLastItems(n)

		def TailQ(n)
			return new stzList(This.Tail(n))

	  #======================================================#
	 #   ITEMS OF TYPE                                      #
	#======================================================#

	def OnlyStrings()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen
			if isString(aContent[i])
				aResult + aContent[i]
			ok
		next
		return aResult

	def OnlyNumbers()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen
			if isNumber(aContent[i])
				aResult + aContent[i]
			ok
		next
		return aResult

	def OnlyLists()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen
			if isList(aContent[i])
				aResult + aContent[i]
			ok
		next
		return aResult

	def OnlyChars()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen
			if isString(aContent[i]) and len(aContent[i]) = 1
				aResult + aContent[i]
			ok
		next
		return aResult

	  #======================================================#
	 #   PAIRS / TRIPLETS / WINDOWS                         #
	#======================================================#

	def Pairs()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen - 1
			aResult + [aContent[i], aContent[i + 1]]
		next
		return aResult

		def PairsQ()
			return new stzList(This.Pairs())

	def Triplets()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen - 2
			aResult + [aContent[i], aContent[i + 1], aContent[i + 2]]
		next
		return aResult

		def TripletsQ()
			return new stzList(This.Triplets())

	def SlidingWindow(n)
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen - n + 1
			aWindow = []
			for j = i to i + n - 1
				aWindow + aContent[j]
			next
			aResult + aWindow
		next
		return aResult

		def SlidingWindowQ(n)
			return new stzList(This.SlidingWindow(n))
