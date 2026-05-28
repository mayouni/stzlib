#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLIST (CORE)             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List core class -- init, content access,    #
#                  item retrieval, counting, updating, adding.  #
#                  For full fluency (aliases), use stzListXT.   #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzList from stzObject
	@aContent = []

	@aWalkers = []

	These
	Those

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(paList)

		if CheckingParams()

			if NOT isList(paList)
				StzRaise("Can't create the stzList object! paList must be a list.")
			ok
		ok

		@aContent = paList
		These = This
		Those = This

		StartObjectTime()
		TraceObjectHistory(This)

	  #---------------------#
	 #     CONSTRAINTS     #
	#---------------------#

	//def MustBe(pcIsMethod)
	//def CanNotBe(pcIsMethod)

	  #-----------------------------------#
	 #  GETTING THE CONTENT OF THE LIST  #
	#-----------------------------------#

	def ContentCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT (pCaseSensitive = 0 or pCaseSensitive = 1)
			StzRaise("Incorrect param type! pCaseSensitive must be 1 (1) or 0 (0).")
		ok

		aResult = []

		if pCaseSensitive = 1
			aResult = @aContent

		else
			aResult = This.WithoutDuplicationCS(0)

		ok

		return aResult

		def ContentCSQ(pCaseSensitive)
			return new stzList(This.Content())

	def Content()
		return @aContent

		def ContentQ()
			return new stzList(This.Content())

	  #--------------------------------------------------------#
	 #  GETTING THE CONTENT OF THE LIST WITHOUT DUPPLICATION  #
	#--------------------------------------------------------#

	def ContentCSU(pCaseSensitive)
		return This.WithoutDuplicationCS(0)

		def ContentCSUQ(pCaseSensitive)
			return new stzList(This.ContentU())

	def ContentU()
		return This.WithoutDuplication()

		def ContentUQ()
			return new stzList(This.ContentU())

	  #------------------------------#
	 #  GETTING A COPY OF THE LIST  #
	#------------------------------#

	def Copy()
		return new stzList( This.List() )

	def ReversedCopy()
		return This.ReverseQ()

	  #-------------------------------------------#
	 #  GETTING THE NUMBER OF ITEMS OF THE LIST  #
	#-------------------------------------------#

	def NumberOfItemsCS(pCaseSensitive)
		nResult = len( This.ContentCS(pCaseSensitive) )
		return nResult

		def NumberOfItemsCSQ(pCaseSensitive)
			return new stzNumber( This.NumberOfItemsCS(pCaseSensitive) )

		def NumberOfItemsCSB(pCaseSensitive)
			if This.NumberOfItemsCS(pCaseSensitive) = LastValue()
				return 1
			else
				return 0
			ok

			def NumberOfItemsCSBQ(pCaseSensitive)
				if This.NumberOfItemsCSB(pCaseSensitive)
					return This
				else
					return AFalseObject()
				ok

	def NumberOfItems()
		nResult = len(@aContent)
		return nResult

		def NumberOfItemsQ()
			return new stzNumber( This.NumberOfItems() )

		def NumberOfItemsB()
			if This.NumberOfItems() = LastValue()
				return 1
			else
				return 0
			ok

			def NumberOfItemsBQ()
				if This.NumberOfItemsB()
					return This
				else
					return AFalseObject()
				ok

	  #--------------------------------------------------------------#
	 #  GETTING THE NUMBER OF ITEMS OF THE LIST -- U/Extended FORM  #
	#--------------------------------------------------------------#

	def NumberOfItemsU()
		return len( Q(This.Content()).WithoutDuplicates() )

		def NumberOfItemsUQ()
			return new stzNumber(This.NumberOfItemsU())

	  #-----------------------------#
	 #  GETTING THE LIST OF ITEMS  #
	#-----------------------------#

	def Items()
		return This.Content()

		def ItemsQ()
			return This

	  #------------------------------------#
	 #  GETTING THE NTH ITEM IN THE LIST  #
	#------------------------------------#

	def Item(n)

		if CheckingParams()

			if isString(n)
				if n = "first"
					n = 1

				but n = "last"
					n = This.NumberOfItems()

				ok
			ok

			if NOT isNumber(n)
				StzRaise("Incorrect param type! n should be a number.")
			ok
		ok

		aContent = This.Content()
		nLen = len(aContent)

		if n > nLen
			StzRaise("Index outside the list!" + NL +
			 "Trying to access position " + n + " in a list of "  + nLen + " items!")
		but n < 0
			n = nLen + n + 1
		ok

		return @aContent[n]

		def ItemQ(n)
			return Q(This.Item(n))

		def NthItem(n)
			return This.Item(n)

			def NthItemQ(n)
				return This.ItemQ(n)

		def ItemAtPosition(n)
			return This.Item(n)

		def ItemAt(n)
			return This.Item(n)

	  #--------------------------------------#
	 #  GETTING THE FIRST ITEM IN THE LIST  #
	#--------------------------------------#

	def FirstItem()
		return This.NthItem(1)

		def FirstItemQ()
			return Q(This.FirstItem())

	  #-------------------------------------#
	 #  GETTING THE LAST ITEM IN THE LIST  #
	#-------------------------------------#

	def LastItem()
		return This.NthItem( This.NumberOfItems() )

		def LastItemQ()
			return Q(This.LastItem())

	  #------------------------------------------------#
	 #  GETTING THE FIRST AND LAST ITEMS IN THE LIST  #
	#------------------------------------------------#

	def FirstAndLastItems()
		aResult = [ This.FirstItem(), This.LastItem() ]
		return aResult

	def LastAndFirstItems()
		aResult = [ This.LastItem(), FirstItem() ]
		return aResult

	  #--------------------------------------------#
	 #  GETTING THE CENTRAL POSITION IN THE LIST  #
	#--------------------------------------------#

	def CentralPosition()
		oTemp = new stzNumber( (This.NumberOfItems()/2) )
		n = oTemp.IntegerPartValue()
		return n

		def CentralItemPosition()
			return This.CentralPosition()

	  #----------------------------------------#
	 #  GETTING THE CENTRAL ITEM IN THE LIST  #
	#----------------------------------------#

	def CentralItem()
		return This[CentralPosition()]

		def CentralItemQ()
			return Q(This.CentralItem())

	  #---------------------------------------------#
	 #  CHECKING IF THE STRING HAS A CENTRAL ITEM  #
	#---------------------------------------------#

	def HasCentralItem()
		return This.NumberOfItemsQ().IsNotEven()

		def ContainsCentralItem()
			return This.HasCentralItem()

	  #-------------------------------------#
	 #  GETTING THE LIST OF N FIRST ITEMS  #
	#-------------------------------------#

	def NFirstItems(n)
		aContent = This.Content()
		aResult = []

		for i = 1 to n
			aResult + aContent[i]
		next

		return aResult

		def NFirstItemsQ(n)
			return NFirstItemsQRT(n, :stzList)

		def NFirstItemsQRT(n, pcReturnType)
			if isList(pcReturnType) and
			   Q(pcReturnType).IsReturnedAsNamedParam()

				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NFirstItems(n) )

			on :stzListOfStrings
				return new stzListOfStrings( This.NFirstItems(n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NFirstItems(n) )

			other
				StzRaise("Unsupported return type!")
			off

	  #------------------------------------#
	 #  GETTING THE LIST OF N LAST ITEMS  #
	#------------------------------------#

	def NLastItems(n)
		aContent = This.Content()
		nLen = len(aContent)
		n1 = nLen - n + 1
		n2 = nLen

		aResult = []

		for i = n1 to n2
			aResult + aContent[i]
		next

		return aResult

		def NLastItemsQ(n)
			return NLastItemsQRT(n, :stzList)

		def NLastItemsQRT(n, pcReturnType)
			if isList(pcReturnType) and
			   Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NLastItems(n) )

			on :stzListOfStrings
				return new stzListOfStrings( This.NLastItems(n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NLastItems(n) )

			other
				StzRaise("Unsupported return type!")
			off

	  #-------------------------------------------------#
	 #  GETTING NEXT/PREVIOUS N ITEMS FROM A POSITION  #
	#-------------------------------------------------#

	def NextNItems(n, pnStartingAt)

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if isList(pnStartingAt) and IsStartingAtOrStartingAtPositionNamedParamList(pnStartingAt)
			pnStartingAt = pnStartingAt[2]
		ok

		if isString(pnStartingAt)
			if pnStartingAt = :First or pnStartingAt = :FirstItem
				pnStartingAt = 1

			but pnStartingAt = :Last or pnStartingAt = :LastItem
				pnStartingAt = This.NumberOfItems()
			ok
		ok

		if NOT isNumber(pnStartingAt)
			StzRaise("Incorrect param type! pnStartingAt must be a number.")
		ok

		if pnStartingAt < 0
			pnStartingAt = This.NumberOfItems() - Abs(pnStartingAt) + 1
		ok

		aContent = This.Content()
		nLen = len(aContent)

		n2 = pnStartingAt + n - 1
		if n2 > nLen
			n2 = nLen
		ok

		aResult = []
		for i = pnStartingAt to n2
			aResult + aContent[i]
		next

		return aResult

	  #--------------------#
	 #      UPDATING      #
	#--------------------#

	def Update(paNewList)
		if CheckingParams() = 1
			if isList(paNewList) and IsWithOrByOrUsingNamedParamList(paNewList)
				paNewList = paNewList[2]
			ok

			if NOT isList(paNewList)
				StzRaise("Incorrect param type! paNewList must be a list.")
			ok
		ok

		@aContent = paNewList

		if _bInHistoryUpdate = 0
			@TraceObjectHistory(This)
		ok

		def UpdateQ(paNewList)
			This.Update(paNewList)
			return This

		def UpdateWith(paNewList)
			This.Update(paNewList)

			def UpdateWithQ(paNewList)
				return This.UpdateQ(paNewList)

		def UpdateBy(paNewList)
			This.Update(paNewList)

			def UpdateByQ(paNewList)
				return This.UpdateQ(paNewList)

	def Updated(paNewList)
		return paNewList

		def UpdatedWith(paNewList)
			return This.Updated(paNewList)

		def UpdatedBy(paNewList)
			return This.Updated(paNewList)

	  #----------------------#
	 #     ADDING ITEMS     #
	#----------------------#

	def AddItem(pItem)
		aCopy = This.Content()
		aCopy + pItem
		This.UpdateWith(aCopy)

		def AddItemQ(pItem)
			This.AddItem(pItem)
			return This

		def Add(pItem)
			This.AddItem(pItem)

			def AddQ(pItem)
				This.Add(pItem)
				return This

		def Append(pItem)
			if isList(pItem) and IsWithOrUsingOrByNamedParamList(pItem)
				pItem = pItem[2]
			ok

			This.AddItem(pItem)

			def AppendQ(pItem)
				This.Append(pItem)
				return This

	def ItemAdded(pItem)
		aResult = This.Copy().AddItemQ(pItem).Content()
		return aResult

		def Added(pItem)
			return This.ItemAdded(pItem)

	  #-----------------------------------#
	 #  MERGING WITH ANOTHER LIST        #
	#-----------------------------------#

	def MergeWith(paOtherList)
		_nLen_ = len(paOtherList)
		for _i_ = 1 to _nLen_
			This.Add(paOtherList[_i_])
		next

		def MergeWithQ(paOtherList)
			This.MergeWith(paOtherList)
			return This

	def MergedWith(paOtherList)
		_aResult_ = This.Content()
		_nLen_ = len(paOtherList)
		for _i_ = 1 to _nLen_
			_aResult_ + paOtherList[_i_]
		next
		return _aResult_

	  #-----------------------------------------------------------#
	 #  ADDING AN ITEM AT A GIVEN POSITION --> INSERT OR EXTEND  #
	#-----------------------------------------------------------#

	def AddItemAt(n, pItem)

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if n <= This.NumberOfItems()
			This.InsertAt(n, pItem)

		else
			This.ExtendToPositionXT(n - 1, :With = "")
			This.Add(pItem)
		ok

		def AddItemAtQ(n, pItem)
			This.AddItemAt(n, pItem)
			return This

	  #-----------------------------------------#
	 #  ADDING MANY ITEMS TO THE LIST          #
	#-----------------------------------------#

	def AddMany(paItems)
		if NOT isList(paItems)
			StzRaise("Incorrect param type! paItems must be a list.")
		ok

		nLen = len(paItems)
		for i = 1 to nLen
			This.AddItem(paItems[i])
		next

		def AddManyQ(paItems)
			This.AddMany(paItems)
			return This

		def AddItems(paItems)
			This.AddMany(paItems)

	  #-------------------#
	 #     IS EMPTY      #
	#-------------------#

	def IsEmpty()
		return This.NumberOfItems() = 0

	def IsNotEmpty()
		return NOT This.IsEmpty()

	  #------------------------------------------#
	 #  NAMED-PARAM CHECKS (needed by Q() calls) #
	#------------------------------------------#

	# Generic: checks if this list is a named param (2-item, first is keyword)
	def IsNamedParam()
		return StzIsNamedParamList(This.Content())

	# --- Methods with existing global functions ---
	def IsAndNamedParam()
		return StzIsAndNamedParamList(This.Content())

	def IsAtNamedParam()
		return StzIsAtNamedParamList(This.Content())

	def IsAtOrAtPositionNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["at", "atposition"])

	def IsAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "atposition")

	def IsBetweenNamedParam()
		return StzIsBetweenNamedParamList(This.Content())

	def IsByNamedParam()
		return StzIsByNamedParamList(This.Content())

	def IsCaseSensitiveNamedParam()
		return StzIsCaseSensitiveNamedParamList(This.Content())

	def IsDirectionOrGoingNamedParam()
		return StzIsDirectionOrGoingNamedParamList(This.Content())

	def IsEqualToNamedParam()
		return StzIsEqualToNamedParamList(This.Content())

	def IsFromNamedParam()
		return StzIsFromNamedParamList(This.Content())

	def IsInNamedParam()
		return StzIsInNamedParamList(This.Content())

	def IsNorNamedParam()
		return StzIsNorNamedParamList(This.Content())

	def IsOfNamedParam()
		return StzIsOfNamedParamList(This.Content())

	def IsOfOrOfSubStringNamedParam()
		return StzIsOfOrOfSubStringNamedParamList(This.Content())

	def IsPositionNamedParam()
		return StzIsPositionNamedParamList(This.Content())

	def IsPositionOrPositionsNamedParam()
		return StzIsPositionOrPositionsNamedParamList(This.Content())

	def IsReturnedAsNamedParam()
		return StzIsReturnedAsNamedParamList(This.Content())

	def IsStartingAtNamedParam()
		return StzIsStartingAtNamedParamList(This.Content())

	def IsStoppingAtNamedParam()
		return StzIsStoppingAtNamedParamList(This.Content())

	def IsToNamedParam()
		return StzIsToNamedParamList(This.Content())

	def IsUsingOrWithOrByNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["using", "with", "by"])

	def IsWhereNamedParam()
		return StzIsWhereNamedParamList(This.Content())

	def IsWithNamedParam()
		return StzIsWithNamedParamList(This.Content())

	def IsWithOrByNamedParam()
		return StzIsWithOrByNamedParamList(This.Content())

	def IsWithOrByOrUsingNamedParam()
		return StzIsWithOrByOrUsingNamedParamList(This.Content())

	# --- Methods without existing global functions (keyword-based) ---
	def IsAndcColNamedNamedParam()
		return StzIsThisNamedParam(This.Content(), "andccolnamed")

	def IsAndcColNamedParam()
		return StzIsThisNamedParam(This.Content(), "andccol")

	def IsAndColAtNamedParam()
		return StzIsThisNamedParam(This.Content(), "andcolat")

	def IsAndColAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "andcolatposition")

	def IsAndColumnAtNamedParam()
		return StzIsThisNamedParam(This.Content(), "andcolumnat")

	def IsAndColumnAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "andcolumnatposition")

	def IsAndColumnNamedNamedParam()
		return StzIsThisNamedParam(This.Content(), "andcolumnnamed")

	def IsAndColumnNamedParam()
		return StzIsThisNamedParam(This.Content(), "andcolumn")

	def IsAndPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "andposition")

	def IsAndReturningNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["andreturning", "andreturnas", "andreturnedas"])

	def IsAndReturningNthNamedParam()
		return StzIsThisNamedParam(This.Content(), "andreturningnth")

	def IsAndReturnNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["andreturn", "andreturnas", "andreturnedas", "andreturnitas"])

	def IsAndReturnNthNamedParam()
		return StzIsThisNamedParam(This.Content(), "andreturnnth")

	def IsAndRowAtNamedParam()
		return StzIsThisNamedParam(This.Content(), "androwat")

	def IsAndRowAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "androwatposition")

	def IsAndRowNamedParam()
		return StzIsThisNamedParam(This.Content(), "androw")

	def IsBetweencColNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweenccol")

	def IsBetweenColAtNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweencolat")

	def IsBetweenColAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweencolatposition")

	def IsBetweenColumnAtNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweencolumnat")

	def IsBetweenColumnAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweencolumnatposition")

	def IsBetweenColumnNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweencolumn")

	def IsBetweenPositionNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["betweenposition", "betweenpositions"])

	def IsBetweenPositionsNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweenpositions")

	def IsBetweenRowAtNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweenrowat")

	def IsBetweenRowAtPositionNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweenrowatposition")

	def IsBetweenRowNamedParam()
		return StzIsThisNamedParam(This.Content(), "betweenrow")

	def IsByColOrByColNumberNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["bycol", "bycolnumber"])

	def IsByOrUsingOrWithNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["by", "using", "with"])

	def IsByOrWithOrUsingNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["by", "with", "using"])

	def IsByRowNamedParam()
		return StzIsThisNamedParam(This.Content(), "byrow")

	def IsComingNamedParam()
		return StzIsThisNamedParam(This.Content(), "coming")

	def IsFromOrOfNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["from", "of"])

	def IsFromPositionNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["fromposition", "from"])

	def IsInANamedParam()
		return StzIsThisNamedParam(This.Content(), "ina")

	def IsInOrInListNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["in", "inlist"])

	def IsInOrInStringNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["in", "instring"])

	def IsOfSizeNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["ofsize", "size"])

	def IsReturningNamedParam()
		return StzIsThisNamedParam(This.Content(), "returning")

	def IsReturningNthNamedParam()
		return StzIsThisNamedParam(This.Content(), "returningnth")

	def IsReturnNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["return", "returnas", "returnedas", "returnitas"])

	def IsReturnNthNamedParam()
		return StzIsThisNamedParam(This.Content(), "returnnth")

	def IsSeedNamedParam()
		return StzIsThisNamedParam(This.Content(), "seed")

	def IsSizeNamedParam()
		return StzIsThisNamedParam(This.Content(), "size")

	def IsToOrOfNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["to", "of"])

	def IsToPositionNamedParam()
		return StzIsOneOfTheseNamedParamsList(This.Content(), ["toposition", "to"])

	def IsWithRowNamedParam()
		return StzIsThisNamedParam(This.Content(), "withrow")

	  #====================#
	 #  SHOWING THE LIST  #
	#====================#

	def Show()
		? @@( This.Content() )

	def ShowShort()
		? @@S( This.Content() )

	  #-----------------------------#
	 #  CLASS NAME                 #
	#-----------------------------#

	def ClassName()
		return "stzlist"

	def StzType()
		return :stzList

	  #=========================================#
	 #  ENGINE-BACKED OPERATIONS (Zig engine)  #
	#=========================================#

	#-- Builds an engine list handle from @aContent.
	#   Returns a C pointer to a StzList, or NULL on failure.

	def _EngineListFromContent()
		return StzEngineMarshalList(@aContent)

	#-- Reads engine list contents back into a Ring list

	def _ContentFromEngineList(pList)
		return StzEngineContentFromList(pList)

	  #------------------------------#
	 #  SORTING (engine-backed)     #
	#------------------------------#

	def SortCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		pList = This._EngineListFromContent()
		if pList = NULL return ok

		StzEngineListSortCS(pList, pCaseSensitive)
		@aContent = This._ContentFromEngineList(pList)
		StzEngineListFree(pList)

		def SortCSQ(pCaseSensitive)
			This.SortCS(pCaseSensitive)
			return This

	def Sort()
		This.SortCS(1)

		def SortQ()
			This.Sort()
			return This

	def SortedCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		pList = This._EngineListFromContent()
		if pList = NULL return [] ok

		StzEngineListSortCS(pList, pCaseSensitive)
		aResult = This._ContentFromEngineList(pList)
		StzEngineListFree(pList)
		return aResult

	def Sorted()
		return This.SortedCS(1)

	def SortInDescendingCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		pList = This._EngineListFromContent()
		if pList = NULL return ok

		StzEngineListSortDescendingCS(pList, pCaseSensitive)
		@aContent = This._ContentFromEngineList(pList)
		StzEngineListFree(pList)

		def SortInDescendingCSQ(pCaseSensitive)
			This.SortInDescendingCS(pCaseSensitive)
			return This

	def SortInDescending()
		This.SortInDescendingCS(1)

		def SortInDescendingQ()
			This.SortInDescending()
			return This

	def SortedInDescendingCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		pList = This._EngineListFromContent()
		if pList = NULL return [] ok

		StzEngineListSortDescendingCS(pList, pCaseSensitive)
		aResult = This._ContentFromEngineList(pList)
		StzEngineListFree(pList)
		return aResult

	def SortedInDescending()
		return This.SortedInDescendingCS(1)

	  #------------------------------#
	 #  REVERSING (engine-backed)   #
	#------------------------------#

	def Reverse()
		pList = This._EngineListFromContent()
		if pList = NULL return ok

		StzEngineListReverse(pList)
		@aContent = This._ContentFromEngineList(pList)
		StzEngineListFree(pList)

		def ReverseQ()
			This.Reverse()
			return This

	def Reversed()
		pList = This._EngineListFromContent()
		if pList = NULL return [] ok

		StzEngineListReverse(pList)
		aResult = This._ContentFromEngineList(pList)
		StzEngineListFree(pList)
		return aResult

	  #----------------------------------------------#
	 #  FINDING ITEMS (engine-backed, first match)  #
	#----------------------------------------------#

	# Note: Find() = ALL occurrences is defined later via
	# FindAllOccurrencesCS at line ~1668, with aliases
	# FindAll, FindFirst, FindLast, FindNth.
	# This method provides a fast single-result engine path.

	def _FindFirstEngine(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		pList = This._EngineListFromContent()
		if pList = NULL return 0 ok

		nResult = 0
		if isString(pItem)
			nResult = StzEngineListFindStringCS(pList, pItem, pCaseSensitive)
		else
			_aFcsContent = @aContent
			_nFcsLen = len(_aFcsContent)
			for _iFcs = 1 to _nFcsLen
				if _aFcsContent[_iFcs] = pItem
					nResult = _iFcs
					exit
				ok
			next
		ok

		StzEngineListFree(pList)
		return nResult

	  #----------------------------------------------#
	 #  CONTAINS (engine-backed)                    #
	#----------------------------------------------#

	def ContainsCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		return This._FindFirstEngine(pItem, pCaseSensitive) > 0

	def Contains(pItem)
		return This.ContainsCS(pItem, 1)

	  #------------------------------------------------------#
	 #  REMOVE DUPLICATES / UNIQUE (engine-backed)          #
	#------------------------------------------------------#

	def RemoveDuplicatesCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		pList = This._EngineListFromContent()
		if pList = NULL return ok

		pUnique = StzEngineListUniqueCS(pList, pCaseSensitive)
		if pUnique != NULL
			@aContent = This._ContentFromEngineList(pUnique)
			StzEngineListFree(pUnique)
		ok
		StzEngineListFree(pList)

		def RemoveDuplicatesCSQ(pCaseSensitive)
			This.RemoveDuplicatesCS(pCaseSensitive)
			return This

	def RemoveDuplicates()
		This.RemoveDuplicatesCS(1)

		def RemoveDuplicatesQ()
			This.RemoveDuplicates()
			return This

	def WithoutDuplicationCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		pList = This._EngineListFromContent()
		if pList = NULL return @aContent ok

		pUnique = StzEngineListUniqueCS(pList, pCaseSensitive)
		aResult = @aContent
		if pUnique != NULL
			aResult = This._ContentFromEngineList(pUnique)
			StzEngineListFree(pUnique)
		ok
		StzEngineListFree(pList)
		return aResult

	def WithoutDuplication()
		return This.WithoutDuplicationCS(1)

		def Unique()
			return This.WithoutDuplication()

		def UniqueCS(pCaseSensitive)
			return This.WithoutDuplicationCS(pCaseSensitive)

	  #--------------------------------------#
	 #  DUPLICATE DETECTION (delegates to   #
	 #  stzListDuplicates)                  #
	#--------------------------------------#

	def ContainsDuplicatedItemsCS(pCaseSensitive)
		_oDupChk_ = new stzListDuplicates(This)
		return _oDupChk_.HasDuplicatesCS(pCaseSensitive)

	def ContainsDuplicatedItems()
		return This.ContainsDuplicatedItemsCS(1)

		def HasDuplicates()
			return This.ContainsDuplicatedItems()

		def HasDuplicatesCS(pCaseSensitive)
			return This.ContainsDuplicatedItemsCS(pCaseSensitive)

		def ContainsDuplicates()
			return This.ContainsDuplicatedItems()

	def DuplicatedItemsCS(pCaseSensitive)
		_oDupItm_ = new stzListDuplicates(This)
		return _oDupItm_.DuplicatedItemsCS(pCaseSensitive)

	def DuplicatedItems()
		return This.DuplicatedItemsCS(1)

	def NumberOfDuplicatedItemsCS(pCaseSensitive)
		return len(This.DuplicatedItemsCS(pCaseSensitive))

	def NumberOfDuplicatedItems()
		return This.NumberOfDuplicatedItemsCS(1)

	  #--------------------------------------#
	 #  FLATTEN (engine-backed)             #
	#--------------------------------------#

	def Flatten()
		pList = This._EngineListFromContent()
		if pList = NULL return ok

		pFlat = StzEngineListFlatten(pList)
		if pFlat != NULL
			@aContent = This._ContentFromEngineList(pFlat)
			StzEngineListFree(pFlat)
		ok
		StzEngineListFree(pList)

		def FlattenQ()
			This.Flatten()
			return This

	def Flattened()
		pList = This._EngineListFromContent()
		if pList = NULL return [] ok

		pFlat = StzEngineListFlatten(pList)
		aResult = []
		if pFlat != NULL
			aResult = This._ContentFromEngineList(pFlat)
			StzEngineListFree(pFlat)
		ok
		StzEngineListFree(pList)
		return aResult

	  #-------------------------------------------#
	 #  EQUALITY CHECK (engine-backed)           #
	#-------------------------------------------#

	def IsEqualToCS(paOtherList, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		pList1 = This._EngineListFromContent()
		if pList1 = NULL return 0 ok

		oOther = new stzList(paOtherList)
		pList2 = oOther._EngineListFromContent()
		if pList2 = NULL
			StzEngineListFree(pList1)
			return 0
		ok

		nResult = StzEngineListEqualsCS(pList1, pList2, pCaseSensitive)
		StzEngineListFree(pList1)
		StzEngineListFree(pList2)

		return nResult

	def IsEqualTo(paOtherList)
		return This.IsEqualToCS(paOtherList, 1)

	  #---------------------------------------------------#
	 #  EXPRESSION-BACKED OPERATIONS (engine bytecode)    #
	#---------------------------------------------------#

	def Map(pcExpr)
		pList = This._EngineListFromContent()
		if pList = NULL return [] ok

		pcExpr = _StzStripBraces(pcExpr)
		pResult = StzEngineListMapExpr(pList, pcExpr)
		aResult = This._ContentFromEngineList(pResult)

		StzEngineListFree(pResult)
		StzEngineListFree(pList)
		return aResult

		def MapQ(pcExpr)
			return new stzList(This.Map(pcExpr))

	def Filter(pcExpr)
		pList = This._EngineListFromContent()
		if pList = NULL return [] ok

		pcExpr = _StzStripBraces(pcExpr)
		pResult = StzEngineListFilterExpr(pList, pcExpr)
		aResult = This._ContentFromEngineList(pResult)

		StzEngineListFree(pResult)
		StzEngineListFree(pList)
		return aResult

		def FilterQ(pcExpr)
			return new stzList(This.Filter(pcExpr))

		def FilterW(pcExpr)
			return This.Filter(pcExpr)

	def Reduce(pcExpr, pInitValue)
		pList = This._EngineListFromContent()
		if pList = NULL return 0 ok

		pcExpr = _StzStripBraces(pcExpr)
		pInit = StzEngineValueNewInt(pInitValue)
		pResult = StzEngineListReduceExpr(pList, pcExpr, pInit)

		nType = StzEngineValueType(pResult)
		switch nType
		on 2
			result = StzEngineValueGetInt(pResult)
		on 3
			result = StzEngineValueGetFloat(pResult)
		other
			result = 0
		off

		StzEngineValueFree(pInit)
		StzEngineValueFree(pResult)
		StzEngineListFree(pList)
		return result

	def ReduceNoInit(pcExpr)
		pList = This._EngineListFromContent()
		if pList = NULL return 0 ok

		pcExpr = _StzStripBraces(pcExpr)
		pResult = StzEngineListReduceExprNoInit(pList, pcExpr)

		nType = StzEngineValueType(pResult)
		switch nType
		on 2
			result = StzEngineValueGetInt(pResult)
		on 3
			result = StzEngineValueGetFloat(pResult)
		other
			result = 0
		off

		StzEngineValueFree(pResult)
		StzEngineListFree(pList)
		return result

	def CountW(pcCondition)
		pList = This._EngineListFromContent()
		if pList = NULL return 0 ok

		pcCondition = _StzStripBraces(pcCondition)
		nResult = StzEngineListCountW(pList, pcCondition)

		StzEngineListFree(pList)
		return nResult

		def CountWhere(pcCondition)
			return This.CountW(pcCondition)

		def NumberOfItemsW(pcCondition)
			return This.CountW(pcCondition)

	  #-------------------------------------------#
	 #  SORTING ORDER CHECK                      #
	#-------------------------------------------#

	def IsSorted()
		return This.IsSortedInAscending() or This.IsSortedInDescending()

	def IsSortedInAscending()
		return _ListSortingOrder(@aContent) = :Ascending

	def IsSortedInDescending()
		return _ListSortingOrder(@aContent) = :Descending

	def SortingOrder()
		return _ListSortingOrder(@aContent)

	def HasSameSortingOrderAs(paOther)
		return This.SortingOrder() = _ListSortingOrder(paOther)

	  #-------------------------------------------#
	 #  TYPE-CHECKING METHODS                    #
	#-------------------------------------------#

	def IsHashList()
		bResult = 1
		aTempKeys = []
		nLen = len(@aContent)
		for i = 1 to nLen
			if NOT ( isList(@aContent[i]) and len(@aContent[i]) = 2 and
				 isString(@aContent[i][1]) )
				bResult = 0
				exit
			else
				cKey = @aContent[i][1]
				nKeyLen = len(aTempKeys)
				for j = 1 to nKeyLen
					if aTempKeys[j] = cKey
						bResult = 0
						exit 2
					ok
				next
				aTempKeys + cKey
			ok
		next
		return bResult

		def IsAHashList()
			return This.IsHashList()

		def IsNotHashList()
			return NOT This.IsHashList()

	def IsPair()
		return len(@aContent) = 2

		def IsAPair()
			return This.IsPair()

	def IsListOfStrings()
		pList = This._EngineListFromContent()
		nResult = StzEngineListIsAllStrings(pList)
		StzEngineListFree(pList)
		return nResult

		def IsAListOfStrings()
			return This.IsListOfStrings()

	def IsListOfNumbers()
		pList = This._EngineListFromContent()
		nResult = StzEngineListIsAllNumbers(pList)
		StzEngineListFree(pList)
		return nResult

		def IsAListOfNumbers()
			return This.IsListOfNumbers()

	def IsListOfLists()
		nLen = len(@aContent)
		for i = 1 to nLen
			if NOT isList(@aContent[i])
				return FALSE
			ok
		next
		return TRUE

		def IsAListOfLists()
			return This.IsListOfLists()

		def AllItemsAreLists()
			return This.IsListOfLists()

		def ContainsOnlyLists()
			return This.IsListOfLists()

	def IsListOfListsOfSameSize()
		nLen = This.NumberOfItems()
		if nLen = 0
			return 0
		ok
		if NOT This.IsListOfLists()
			return 0
		ok
		for i = 2 to nLen
			if len(@aContent[i]) != len(@aContent[i-1])
				return 0
			ok
		next
		return 1

		def ItemsAreListsOfSameSize()
			return This.IsListOfListsOfSameSize()

		def AllItemsAreListsOfSameSize()
			return This.IsListOfListsOfSameSize()

	def IsPairOfNumbers()
		if len(@aContent) = 2 and isNumber(@aContent[1]) and isNumber(@aContent[2])
			return 1
		else
			return 0
		ok

		def IsAPairOfNumbers()
			return This.IsPairOfNumbers()

	def IsListOfPairs()
		nLen = len(@aContent)
		for i = 1 to nLen
			if NOT (isList(@aContent[i]) and len(@aContent[i]) = 2)
				return FALSE
			ok
		next
		return TRUE

		def IsAListOfPairs()
			return This.IsListOfPairs()

	def IsSet()
		nLen = len(@aContent)
		for i = 1 to nLen
			for j = i + 1 to nLen
				if @aContent[i] = @aContent[j]
					return FALSE
				ok
			next
		next
		return TRUE

		def IsASet()
			return This.IsSet()

	  #=============================================#
	 #  ESSENTIAL METHODS FOR SUBMODULE SUPPORT    #
	#=============================================#

	  #-- List() alias

	def List()
		return This.Content()

		def ListQ()
			return This

	  #-- Section: extract items between two positions

	def SectionCS(n1, n2, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		nLen = This.NumberOfItems()

		if CheckingParams()
			if isString(n1)
				if n1 = :First or n1 = :FirstItem
					n1 = 1
				but n1 = :Last or n1 = :LastItem
					n1 = nLen
				ok
			ok

			if isString(n2)
				if n2 = :Last or n2 = :LastItem or n2 = :End or n2 = :EndOfList
					n2 = nLen
				but n2 = :First or n2 = :FirstItem
					n2 = 1
				ok
			ok

			if NOT @BothAreNumbers(n1, n2)
				StzRaise("Incorrect params! n1 and n2 must be numbers.")
			ok
		ok

		if n1 < 1 or n1 > nLen or n2 < 1 or n2 > nLen
			StzRaise("Indexes out of range!")
		ok

		if n2 < n1
			nTemp = n1
			n1 = n2
			n2 = nTemp
		ok

		aContent = This.Content()
		aResult = []
		for i = n1 to n2
			aResult + aContent[i]
		next

		return aResult

		def SectionCSQ(n1, n2, pCaseSensitive)
			return new stzList(This.SectionCS(n1, n2, pCaseSensitive))

	def Section(n1, n2)
		return This.SectionCS(n1, n2, 1)

		def SectionQ(n1, n2)
			return new stzList(This.Section(n1, n2))

	  #-- Range: extract items from a start position for a given count

	def Range(pnStart, pnRange)
		if CheckingParams()
			if isString(pnStart)
				if pnStart = :First or pnStart = :FirstItem
					pnStart = 1
				but pnStart = :Last or pnStart = :LastItem
					pnStart = This.NumberOfItems()
				ok
			ok
		ok

		if pnStart < 0
			pnStart = This.NumberOfItems() + pnStart + 1
		ok

		if pnStart = 0 or pnRange = 0
			return []
		ok

		if pnRange > 0
			return This.Section(pnStart, pnStart + pnRange - 1)
		else
			n1 = pnStart + pnRange + 1
			if n1 > 0
				return This.Section(n1, pnStart)
			ok
			return []
		ok

		def RangeQ(pnStart, pnRange)
			return new stzList(This.Range(pnStart, pnRange))

	  #-- InsertAt: insert an item at a given position

	def InsertAt(n, pItem)
		if isList(n) and IsOneOfTheseNamedParamsList(n, [ :Position, :ItemAt, :ItemAtPosition ])
			n = n[2]
		ok

		aContent = @aContent
		ring_insert(aContent, n, pItem)
		This.UpdateWith(aContent)

		def InsertBefore(n, pItem)
			This.InsertAt(n, pItem)

		def InsertAtQ(n, pItem)
			This.InsertAt(n, pItem)
			return This

	  #-- RemoveItemAtPosition: remove item at a specific position

	def RemoveItemAtPosition(n)
		if isString(n)
			if StzFind([:First, :FirstPosition, :FirstItem], n) > 0
				n = 1
			but StzFind([:Last, :LastPosition, :LastItem], n) > 0
				n = This.NumberOfItems()
			ok
		ok

		if NOT (isNumber(n) and n != 0)
			StzRaise("Incorrect param! n must be a number different from zero.")
		ok

		if n <= This.NumberOfItems()
			aContent = This.Content()
			ring_del(aContent, n)
			This.UpdateWith(aContent)
		ok

		def RemoveItemAtPositionQ(n)
			This.RemoveItemAtPosition(n)
			return This

		def RemoveAt(n)
			This.RemoveItemAtPosition(n)

	  #-- RemoveItemsAtPositions: remove items at multiple positions

	def RemoveItemsAtPositions(panPos)
		if NOT isList(panPos)
			StzRaise("Incorrect param type! panPos must be a list.")
		ok

		panSorted = new stzList(panPos).Sorted()
		nLen = len(panSorted)

		for i = nLen to 1 step -1
			This.RemoveItemAtPosition(panSorted[i])
		next

		def RemoveItemsAtPositionsQ(panPos)
			This.RemoveItemsAtPositions(panPos)
			return This

	  #-- RemoveSection: remove items between two positions

	def RemoveSection(n1, n2)
		nLen = This.NumberOfItems()

		if CheckingParams()
			if isString(n1)
				if StzFind([:First, :FirstPosition, :FirstItem], n1) > 0
					n1 = 1
				ok
			ok

			if isString(n2)
				if StzFind([:Last, :LastPosition, :LastItem], n2) > 0
					n2 = nLen
				ok
			ok

			if NOT @BothAreNumbers(n1, n2)
				StzRaise("Incorrect param type! n1 and n2 must be numbers.")
			ok

			if n2 < n1
				nTemp = n1
				n1 = n2
				n2 = nTemp
			ok
		ok

		if nLen = 0
			return
		ok

		if n1 = 1 and n2 = nLen
			This.UpdateWith([])
			return
		ok

		if n1 = n2
			This.RemoveItemAtPosition(n1)
			return
		ok

		aContent = This.Content()
		aResult = []

		for i = 1 to n1 - 1
			aResult + aContent[i]
		next

		for i = n2 + 1 to nLen
			aResult + aContent[i]
		next

		This.UpdateWith(aResult)

		def RemoveSectionQ(n1, n2)
			This.RemoveSection(n1, n2)
			return This

	  #-- RemoveFirstItem / RemoveLastItem

	def RemoveFirstItem()
		This.RemoveItemAtPosition(1)

		def RemoveFirstItemQ()
			This.RemoveFirstItem()
			return This

	def RemoveLastItem()
		This.RemoveItemAtPosition(This.NumberOfItems())

		def RemoveLastItemQ()
			This.RemoveLastItem()
			return This

	def RemoveFirstAndLastItems()
		This.RemoveFirstItem()
		This.RemoveLastItem()

	  #-- RemoveRange: remove items from start for a count

	def RemoveRange(nStart, nRange)
		if nRange > 0
			This.RemoveSection(nStart, nStart + nRange - 1)
		but nRange < 0
			n1 = nStart + nRange + 1
			if n1 > 0
				This.RemoveSection(n1, nStart)
			ok
		ok

	  #-- RemoveAllItems

	def RemoveAllItems()
		This.UpdateWith([])

	  #-- FindAllOccurrencesCS: find all positions of an item

	def FindAllOccurrencesCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if isList(pItem) and IsOfNamedParamList(pItem)
			pItem = pItem[2]
		ok

		aContent = This.Content()
		nLen = len(aContent)

		if nLen = 0
			return []
		ok

		anResult = @FindAllCS_NbrOrStr(aContent, pItem, pCaseSensitive)

		if isList(anResult) and len(anResult) > 0
			return anResult
		ok

		cItem = ""
		if isList(pItem)
			cItem = @@(pItem)
		but isObject(pItem) and @IsStzObject(pItem) and pItem.IsNamed()
			cItem = pItem.ObjectName()
		else
			cItem = Q(pItem).Stringified()
		ok

		acContent = []
		for _k = 1 to nLen
			acContent + ("" + aContent[_k])
		next

		if pCaseSensitive = 0
			cItem = StzLower(cItem)
			for i = 1 to nLen
				acContent[i] = StzLower(acContent[i])
			next
		ok

		anResult = []
		for i = 1 to nLen
			if acContent[i] = cItem
				anResult + i
			ok
		next

		return anResult

		def FindCS(pItem, pCaseSensitive)
			return This.FindAllOccurrencesCS(pItem, pCaseSensitive)

		def Find(pItem)
			return This.FindAllOccurrencesCS(pItem, 1)

		def FindAllCS(pItem, pCaseSensitive)
			return This.FindAllOccurrencesCS(pItem, pCaseSensitive)

		def FindAll(pItem)
			return This.FindAllOccurrencesCS(pItem, 1)

		def FindAllOccurrences(pItem)
			return This.FindAllOccurrencesCS(pItem, 1)

	  #-- NumberOfOccurrenceCS: count occurrences

	def NumberOfOccurrenceCS(pItem, pCaseSensitive)
		return len(This.FindAllOccurrencesCS(pItem, pCaseSensitive))

		def NumberOfOccurrencesCS(pItem, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pItem, pCaseSensitive)

		def NumberOfOccurrence(pItem)
			return This.NumberOfOccurrenceCS(pItem, 1)

		def NumberOfOccurrences(pItem)
			return This.NumberOfOccurrenceCS(pItem, 1)

		def CountCS(pItem, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pItem, pCaseSensitive)

		def Count(pItem)
			return This.NumberOfOccurrenceCS(pItem, 1)

	  #-- FindNthOccurrenceCS: find nth occurrence

	def FindNthOccurrenceCS(n, pItem, pCaseSensitive)
		if CheckingParams()
			if isString(n)
				if n = :First or n = :FirstOccurrence
					n = 1
				but n = :Last or n = :LastOccurrence
					n = This.NumberOfOccurrenceCS(pItem, pCaseSensitive)
				ok
			ok

			if isList(pItem) and IsOfNamedParamList(pItem)
				pItem = pItem[2]
			ok

			if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
				pCaseSensitive = pCaseSensitive[2]
			ok
		ok

		anPositions = This.FindAllOccurrencesCS(pItem, pCaseSensitive)
		nLen = len(anPositions)

		if n < 1 or n > nLen
			return 0
		ok

		return anPositions[n]

		def FindNthCS(n, pItem, pCaseSensitive)
			return This.FindNthOccurrenceCS(n, pItem, pCaseSensitive)

		def NthOccurrenceCS(n, pItem, pCaseSensitive)
			return This.FindNthOccurrenceCS(n, pItem, pCaseSensitive)

	  #-- FindFirstOccurrenceCS / FindLastOccurrenceCS

	def FindFirstOccurrenceCS(pItem, pCaseSensitive)
		return This.FindNthOccurrenceCS(1, pItem, pCaseSensitive)

		def FindFirstCS(pItem, pCaseSensitive)
			return This.FindFirstOccurrenceCS(pItem, pCaseSensitive)

		def FindFirst(pItem)
			return This.FindFirstOccurrenceCS(pItem, 1)

	def FindLastOccurrenceCS(pItem, pCaseSensitive)
		anAll = This.FindAllOccurrencesCS(pItem, pCaseSensitive)
		nLen = len(anAll)
		if nLen = 0
			return 0
		ok
		return anAll[nLen]

		def FindLastCS(pItem, pCaseSensitive)
			return This.FindLastOccurrenceCS(pItem, pCaseSensitive)

		def FindLast(pItem)
			return This.FindLastOccurrenceCS(pItem, 1)

	  #-- FindManyCS: find multiple items at once

	def FindManyCS(paItems, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		anResult = []
		nLen = len(paItems)
		for i = 1 to nLen
			anPos = This.FindAllOccurrencesCS(paItems[i], pCaseSensitive)
			for j = 1 to len(anPos)
				anResult + anPos[j]
			next
		next

		return new stzList(anResult).Sorted()

		def FindMany(paItems)
			return This.FindManyCS(paItems, 1)

	  #-- ContainsManyCS: check if list contains multiple items

	def ContainsManyCS(paItems, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		nLen = len(paItems)
		for i = 1 to nLen
			if NOT This.ContainsCS(paItems[i], pCaseSensitive)
				return 0
			ok
		next

		return 1

		def ContainsMany(paItems)
			return This.ContainsManyCS(paItems, 1)

		def ContainsThese(paItems)
			return This.ContainsManyCS(paItems, 1)

		def ContainsEach(paItems)
			return This.ContainsManyCS(paItems, 1)

		def ContainsAll(paItems)
			return This.ContainsManyCS(paItems, 1)

		def ContainsTheseCS(paItems, pCaseSensitive)
			return This.ContainsManyCS(paItems, pCaseSensitive)

		def ContainsEachCS(paItems, pCaseSensitive)
			return This.ContainsManyCS(paItems, pCaseSensitive)

		def ContainsAllCS(paItems, pCaseSensitive)
			return This.ContainsManyCS(paItems, pCaseSensitive)

	  #-- RemoveAllCS: remove all occurrences of an item

	def RemoveAllCS(pItem, pCaseSensitive)
		if isList(pItem) and IsOfNamedParamList(pItem)
			pItem = pItem[2]
		ok

		anPos = This.FindAllOccurrencesCS(pItem, pCaseSensitive)
		nLenPos = len(anPos)

		for i = nLenPos to 1 step -1
			This.RemoveItemAtPosition(anPos[i])
		next

		def RemoveAllCSQ(pItem, pCaseSensitive)
			This.RemoveAllCS(pItem, pCaseSensitive)
			return This

		def RemoveAll(pItem)
			This.RemoveAllCS(pItem, 1)

	  #-- FindW: find items matching a condition (eval-based)

	def FindAllItemsWCS(pcCondition, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		return This.FindAllItemsW(pcCondition)

		def FindWCS(pcCondition, pCaseSensitive)
			return This.FindAllItemsWCS(pcCondition, pCaseSensitive)

		def FindAllWCS(pcCondition, pCaseSensitive)
			return This.FindAllItemsWCS(pcCondition, pCaseSensitive)

	def FindAllItemsW(pcCondition)
		pList = This._EngineListFromContent()
		if pList = NULL return [] ok

		pcCondition = _StzStripBraces(pcCondition)
		cRaw = StzEngineListFindAllW(pList, pcCondition)
		StzEngineListFree(pList)

		if len(cRaw) = 0
			return []
		ok

		anResult = StzSplit(cRaw, ",")
		nLen = len(anResult)
		for i = 1 to nLen
			anResult[i] = 0 + anResult[i]
		next
		return anResult

		def FindW(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def FindAllW(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def FindWhere(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def PositionsW(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def PositionsWhere(pcCondition)
			return This.FindAllItemsW(pcCondition)

	  #-- FindWXT: find items matching condition (returns items, not positions)

	def FindWXT(pcCondition)
		anPos = This.FindW(pcCondition)
		return This.ItemsAtPositions(anPos)

	  #-- ItemsAtPositions: get items at given positions

	def ItemsAtPositions(panPos)
		if NOT isList(panPos)
			StzRaise("Incorrect param type! panPos must be a list.")
		ok

		aContent = This.Content()
		nLen = len(panPos)
		aResult = []

		for i = 1 to nLen
			aResult + aContent[panPos[i]]
		next

		return aResult

		def ItemsAtPositionsQ(panPos)
			return new stzList(This.ItemsAtPositions(panPos))

		def ItemsAt(panPos)
			return This.ItemsAtPositions(panPos)

	  #-- ExtendToPositionXT: extend list to a given position

	def ExtendToPositionXT(n, pWith)
		if isList(pWith) and IsWithOrByOrUsingNamedParamList(pWith)
			pWith = pWith[2]
		ok

		nLen = This.NumberOfItems()
		if n > nLen
			for i = nLen + 1 to n
				This.AddItem(pWith)
			next
		ok

		def ExtendToPositionWith(n, pWith)
			This.ExtendToPositionXT(n, pWith)

	  #-- Perform: execute code on each item

	def Perform(pcAction)
		@aContent = This.Map(pcAction)

		def PerformQ(pcAction)
			This.Perform(pcAction)
			return This

	  #-- PerformOn: execute code on specific positions

	def PerformOn(panPos, pcAction)
		pcAction = _StzStripBraces(pcAction)
		nLen = len(panPos)
		pList = This._EngineListFromContent()
		if pList = NULL return ok

		pResult = StzEngineListMapExpr(pList, pcAction)
		aNew = This._ContentFromEngineList(pResult)

		for i = 1 to nLen
			nPos = panPos[i]
			if nPos >= 1 and nPos <= len(@aContent)
				@aContent[nPos] = aNew[nPos]
			ok
		next

		StzEngineListFree(pResult)
		StzEngineListFree(pList)

	  #-- Yield: execute code on each item and collect results

	def Yield(pcYielder)
		return This.Map(pcYielder)

		def YieldQ(pcYielder)
			return new stzList(This.Yield(pcYielder))

	  #-- Min / Max for numeric lists

	def Min()
		if len(@aContent) = 0
			return 0
		ok

		# Engine-backed O(n) min
		pList = This._EngineListFromContent()
		nResult = StzEngineListMin(pList)
		StzEngineListFree(pList)
		return nResult

	def Max()
		if len(@aContent) = 0
			return 0
		ok

		# Engine-backed O(n) max
		pList = This._EngineListFromContent()
		nResult = StzEngineListMax(pList)
		StzEngineListFree(pList)
		return nResult

	  #=========================================#
	 #  ADDITIONAL TYPE CHECKING METHODS       #
	#=========================================#

	def IsListOfHashLists()
		_aIlhContent_ = This.Content()
		_nIlhLen_ = len(_aIlhContent_)
		if _nIlhLen_ = 0
			return 0
		ok

		for _iIlh_ = 1 to _nIlhLen_
			if NOT isList(_aIlhContent_[_iIlh_])
				return 0
			ok
			_oIlhTemp_ = new stzList(_aIlhContent_[_iIlh_])
			if NOT _oIlhTemp_.IsHashList()
				return 0
			ok
		next

		return 1

	def IsMadeOfSome(paValues)
		_aImContent_ = This.Content()
		_nImLen_ = len(_aImContent_)

		for _iIm_ = 1 to _nImLen_
			_bImFound_ = 0
			_nImVLen_ = len(paValues)
			for _jIm_ = 1 to _nImVLen_
				if _aImContent_[_iIm_] = paValues[_jIm_]
					_bImFound_ = 1
					exit
				ok
			next
			if _bImFound_ = 0
				return 0
			ok
		next

		return 1

	def IsPairOfStrings()
		_aIpContent_ = This.Content()
		if len(_aIpContent_) != 2
			return 0
		ok
		return isString(_aIpContent_[1]) and isString(_aIpContent_[2])


