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

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtOrStartingAtPositionNamedParam()
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
			if isList(paNewList) and StzListQ(paNewList).IsWithOrByOrUsingNamedParam()
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
			if isList(pItem) and StzListQ(pItem).IsWithOrUsingOrByNamedParam()
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
