#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTBOUNDER             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List bounder subclass -- sections, slices,  #
#                  bounds checking, bounded-by operations.      #
#                  For aliases, use stzListBounderXT.           #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListBounder from stzList

	  #==========================================#
	 #  GETTING A SECTION (SLICE) OF THE LIST   #
	#==========================================#

	def SectionCS(n1, n2, pCaseSensitive)

		aContent = This.Content()
		nLen = len(aContent)

		if CheckingParams()

			if isList(n1) and StzListQ(n1).IsFromNamedParam()
				n1 = n1[2]
			ok

			if isList(n2) and IsToNamedParamList(n2)
				n2 = n2[2]
			ok

			if isString(n1)
				if ring_find([ :First, :FirstItem ], n1) > 0
					n1 = 1
				but ring_find([ :Last, :LastItem ], n1) > 0
					n1 = nLen
				ok
			ok

			if isString(n2)
				if ring_find([ :End, :Last, :LastItem, :EndOfList ], n2) > 0
					n2 = nLen
				but ring_find([ :First, :FirstItem ], n2) > 0
					n2 = 1
				ok
			ok

			if NOT (isNumber(n1) and isNumber(n2))
				StzRaise("Incorrect params! n1 and n2 must be numbers.")
			ok
		ok

		if NOT ( ( n1 >= 1 and n1 <= nLen ) and
			 ( n2 >= 1 and n2 <= nLen ) )

			StzRaise("Indexes out of range! n1 and n2 must be inside the list.")
		ok

		aResult = []

		if n2 < n1
			nTemp = n1
			n1 = n2
			n2 = nTemp
		ok

		for i = n1 to n2
			aResult + aContent[i]
		next

		return aResult

		def SectionCSQ(n1, n2, pCaseSensitive)
			return new stzList( This.SectionCS(n1, n2, pCaseSensitive) )

	def Section(n1, n2)
		return This.SectionCS(n1, n2, 1)

		def SectionQ(n1, n2)
			return new stzList(This.Section(n1, n2))

	  #-------------------------------------------------#
	 #  GETTING A SECTION -- XT (inverted = reversed)  #
	#-------------------------------------------------#

	def SectionXT(n1, n2)
		aContent = This.Content()
		nLen = len(aContent)

		if n1 < 1 or n1 > nLen or n2 < 1 or n2 > nLen
			StzRaise("Indexes out of range!")
		ok

		aResult = []

		if n1 <= n2
			for i = n1 to n2
				aResult + aContent[i]
			next
		else
			for i = n1 to n2 step -1
				aResult + aContent[i]
			next
		ok

		return aResult

		def SectionXTQ(n1, n2)
			return new stzList(This.SectionXT(n1, n2))

	  #===========================================#
	 #  GETTING MANY SECTIONS                   #
	#===========================================#

	def Sections(paSections)
		nLen = len(paSections)
		aResult = []

		for i = 1 to nLen
			aSection = paSections[i]
			aItems = This.Section(aSection[1], aSection[2])
			aResult + aItems
		next

		return aResult

		def SectionsQ(paSections)
			return new stzList(This.Sections(paSections))

		def ManySections(paSections)
			return This.Sections(paSections)

	  #===========================================================#
	 #  CHECKING IF THE 2 ITEMS ARE BOUNDS OF A SUBSTRING        #
	#===========================================================#

	def AreBoundsOfCS(pcSubStr, pIn, pCaseSensitive)

		if CheckingParams() = 1

			if NOT isString(pcSubStr)
				StzRaise("Incorrect param type! pcSubStr must be a string.")
			ok

			if NOT ( This.IsPair() or This.IsListOfPairs() )
				StzRaise("Can't check bounds! List must be a pair or a list of pairs.")
			ok

			if isList(pIn) and StzListQ(pIn).IsInNamedParam()
				pIn = pIn[2]
			ok

			if NOT isString(pIn)
				StzRaise("Incorrect param type! pIn must be a string.")
			ok

		ok

		aContent = This.Content()
		nLen = len(aContent)

		oSubStr = new stzString(pcSubStr)
		bResult = 0

		if This.IsListOfPairs()
			bResult = 1

			for i = 1 to nLen
				bResult = oSubStr.IsBoundedByIn(aContent[i], pIn)
				if bResult = 0
					exit
				ok
			next
		else
			bResult = oSubStr.IsBoundedByIn(aContent, pIn)
		ok

		return bResult

	def AreBoundsOf(pItem, pIn)
		return This.AreBoundsOfCS(pItem, pIn, 1)

	  #----------------------------------------------------------#
	 #  CHECKING IF THE LIST IS BOUNDED BY THE GIVEN TWO ITEMS  #
	#----------------------------------------------------------#

	def IsBoundedByCS(paBounds, pCaseSensitive)
		if isList(paBounds) and StzListQ(paBounds).IsPair()
			pItem1 = paBounds[1]
			pItem2 = paBounds[2]
		else
			pItem1 = paBounds
			pItem2 = paBounds
		ok

		if This.FirstItemQ().IsEqualToCS(pItem1, pCaseSensitive) and
		   This.LastItemQ().IsEqualToCS(pItem2, pCaseSensitive)

			return 1
		else
			return 0
		ok

	def IsBoundedBy(paBounds)
		return This.IsBoundedByCS(paBounds, 1)

	  #--------------------------------------------#
	 #  GETTING BOUNDS OF THE LIST UP TO N ITEMS  #
	#--------------------------------------------#

	def BoundsUpToNItems(n)
		aFirst = This.NFirstItems(n)
		aLast  = This.NLastItems(n)

		if len(aFirst) = 1
			aFirst = aFirst[1]
		ok

		if len(aLast) = 1
			aLast = aLast[1]
		ok

		return [ aFirst, aLast ]

	def Bounds()
		return This.BoundsUpToNItems(1)

	  #=====================================#
	 #     REMOVING BOUNDS               #
	#=====================================#

	def RemoveBoundsCS(paBounds, pCaseSensitive)
		if This.IsBoundedByCS(paBounds, pCaseSensitive)
			This.RemoveFirstItem()
			This.RemoveLastItem()
		ok

		def RemoveBoundsCSQ(paBounds, pCaseSensitive)
			This.RemoveBoundsCS(paBounds, pCaseSensitive)
			return This

	def RemoveBounds(paBounds)
		This.RemoveBoundsCS(paBounds, 1)

		def RemoveBoundsQ(paBounds)
			This.RemoveBounds(paBounds)
			return This

	def BoundsRemoved(paBounds)
		aResult = This.Copy().RemoveBoundsQ(paBounds).Content()
		return aResult

	  #==============================#
	 #  IS PAIR / IS LIST OF PAIRS  #
	#==============================#

	def IsPair()
		return This.NumberOfItems() = 2

	def IsListOfPairs()
		aContent = This.Content()
		nLen = len(aContent)

		for i = 1 to nLen
			if NOT (isList(aContent[i]) and len(aContent[i]) = 2)
				return 0
			ok
		next

		return 1
