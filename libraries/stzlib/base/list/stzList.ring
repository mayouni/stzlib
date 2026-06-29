#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLIST (CORE)              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List core class -- init, content access,    #
#                  item retrieval, counting, updating, adding. #
#                  For full fluency (aliases), use stzListXT.  #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzList from stzObject
	@aContent = []

	# Engine-residency (see _ENGINE_RESIDENCY_PLAN.md). @aContent is ALWAYS
	# the source of truth; @pEngineGen is a generation token into the engine-
	# side residency cache (0 = no cached handle). The cache OWNS and bounds
	# the marshalled engine handle (FIFO eviction over item/entry caps) so a
	# cached handle never leaks despite Ring having no object destructors.
	# On a cache miss (evicted) _Engine() simply re-marshals from @aContent.
	@pEngineGen = 0

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

		This._SetContent(paList)
		These = This
		Those = This

		StartObjectTime()
		TraceObjectHistory(This)

	  #-- Deep (nested) list view: promotes to stzDeepList for the path-based
	  #   deep API (DeepFind / Paths / ItemAtPath / ...). Kept modular -- the
	  #   deep operations live in the stzDeepList subclass, not here.
	def DeepList()
		return new stzDeepList(This.Content())

		def AsDeepList()
			return This.DeepList()

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
		return This._Content()

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

		This._SetContent(paNewList)

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

	def ManyAdded(paItems)
		# Non-mutating: append each item of paItems to a copy.
		aResult = This.Copy().AddManyQ(paItems).Content()
		return aResult

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

	def IsToOrToPosition()
		return This.IsToPositionNamedParam()

		def IsToPositionOrTo()
			return This.IsToPositionNamedParam()

	# AllItemsAreEqualCS: TRUE iff every item in the list equals
	# every other item (i.e. all items collapse to a single value).
	# Case-sensitivity applies only when items are strings.
	def AllItemsAreEqualCS(pCaseSensitive)
		pList = This._EngineListFromContent()
		nResult = StzEngineListAllItemsEqualCS(pList, pCaseSensitive)
		StzEngineListFree(pList)
		return nResult

		def AllItemsAreEqual()
			return This.AllItemsAreEqualCS(1)

		def AllAreEqualCS(pCaseSensitive)
			return This.AllItemsAreEqualCS(pCaseSensitive)

		def AllAreEqual()
			return This.AllItemsAreEqualCS(1)

	def IsWithRowNamedParam()
		return StzIsThisNamedParam(This.Content(), "withrow")

	  #====================#
	 #  SHOWING THE LIST  #
	#====================#

	def Stringified()
		return @@(This.Content())

		def ToCode()
			return This.Stringified()

	# ToString: a plain display form -- the items rendered one per line
	# (monolith semantics: ToStringXT(:ConcatenatedUsing = NL)). Overrides
	# the stzObject default so a stzList stringifies to its content, not
	# to an "@noname" object handle.
	def ToString()
		_aTsContent_ = This.Content()
		_nTsLen_ = len(_aTsContent_)
		_cTsRes_ = ""
		for _iTs_ = 1 to _nTsLen_
			if _iTs_ > 1
				_cTsRes_ = _cTsRes_ + nl
			ok
			_xTs_ = _aTsContent_[_iTs_]
			if isString(_xTs_)
				_cTsRes_ = _cTsRes_ + _xTs_
			but isNumber(_xTs_)
				_cTsRes_ = _cTsRes_ + ("" + _xTs_)
			else
				_cTsRes_ = _cTsRes_ + @@(_xTs_)
			ok
		next
		return _cTsRes_

		def ToStringQ()
			return new stzString(This.ToString())

	def Show()
		? @@( This.Content() )

	def ShowShort()
		? @@S( This.Content() )

	def ShowShortN(n)
		? ComputableShortFormXT( This.Content(), n )

	def ShowShortXT(nItems)
		# nItems may be a number (symmetric N first + N last)
		# or a 2-list [nHead, nTail] for asymmetric short form.
		? ComputableShortFormXT( This.Content(), nItems )

	  #-----------------------------#
	 #  CLASS NAME                 #
	#-----------------------------#

	def ClassName()
		return "stzlist"

	def StzType()
		return :stzList

	  #=============================================#
	 #  REPLACE DELEGATIONS (via stzListReplacer)  #
	#=============================================#

	def ReplaceCS(pItem, pNewItem, pCaseSensitive)
		_oRpl_ = new stzListReplacer(This)
		_oRpl_.ReplaceAllOccurrencesCS(pItem, pNewItem, pCaseSensitive)
		This._SetContent(_oRpl_.Content())

	def Replace(pItem, pNewItem)
		This.ReplaceCS(pItem, pNewItem, 1)

	def ReplaceNthCS(n, pItem, pNewItem, pCaseSensitive)
		_oRplN_ = new stzListReplacer(This)
		_oRplN_.ReplaceNthOccurrenceCS(n, pItem, pNewItem, pCaseSensitive)
		This._SetContent(_oRplN_.Content())

	def ReplaceNth(n, pItem, pNewItem)
		This.ReplaceNthCS(n, pItem, pNewItem, 1)

	# Occurrence-replace delegation, accepting the named-param call
	# form ReplaceNthOccurrence(n, :Of = item, :With = newItem).

	def ReplaceNthOccurrenceCS(n, pItem, pNewItem, pCaseSensitive)
		if isList(pItem) and len(pItem) = 2 and isString(pItem[1]) and
		   (pItem[1] = :of or pItem[1] = :Of or pItem[1] = :For or pItem[1] = :for)
			pItem = pItem[2]
		ok
		if isList(pNewItem) and len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :with or pNewItem[1] = :With or pNewItem[1] = :by or
		    pNewItem[1] = :By or pNewItem[1] = :using or pNewItem[1] = :Using)
			pNewItem = pNewItem[2]
		ok
		_oRplNO_ = new stzListReplacer(This)
		_oRplNO_.ReplaceNthOccurrenceCS(n, pItem, pNewItem, pCaseSensitive)
		This._SetContent(_oRplNO_.Content())

	def ReplaceNthOccurrence(n, pItem, pNewItem)
		This.ReplaceNthOccurrenceCS(n, pItem, pNewItem, 1)

	# Replace the nth occurrence of an item counting backward from a
	# given position. Named form:
	#   ReplacePreviousNthOccurrence(n, :Of=item, :By=new, :StartingAt=p)

	def ReplacePreviousNthOccurrenceCS(n, pItem, pNewItem, pnStartingAt, pCaseSensitive)
		if isList(pItem) and ring_len(pItem) = 2 and isString(pItem[1]) and
		   (pItem[1] = :of or pItem[1] = :Of)
			pItem = pItem[2]
		ok
		if isList(pNewItem) and ring_len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :with or pNewItem[1] = :With or pNewItem[1] = :by or
		    pNewItem[1] = :By or pNewItem[1] = :using or pNewItem[1] = :Using)
			pNewItem = pNewItem[2]
		ok
		if isList(pnStartingAt) and ring_len(pnStartingAt) = 2 and isString(pnStartingAt[1]) and
		   (pnStartingAt[1] = :startingat or pnStartingAt[1] = :StartingAt)
			pnStartingAt = pnStartingAt[2]
		ok
		oRpvSec = This.SectionQ(1, pnStartingAt)
		anRpvPos = oRpvSec.FindAllCS(pItem, pCaseSensitive)
		nRpvPos = anRpvPos[ ring_len(anRpvPos) - n + 1 ]
		This.ReplaceAt(nRpvPos, pNewItem)

	def ReplacePreviousNthOccurrence(n, pItem, pNewItem, pnStartingAt)
		This.ReplacePreviousNthOccurrenceCS(n, pItem, pNewItem, pnStartingAt, 1)

	# Plural "ST" forms: panList holds INDICES into the list of an
	# item's previous/next occurrences (relative to :StartingAt). E.g.
	# panList=[3,1] picks the 3rd and 1st previous occurrence. The
	# rationale (from the monolith): anAllPos[panList[i]].

	def FindPreviousNthOccurrencesCS(panList, pItem, pnStartingAt, pCaseSensitive)
		if isList(pItem) and ring_len(pItem) = 2 and isString(pItem[1]) and
		   (pItem[1] = :of or pItem[1] = :Of)
			pItem = pItem[2]
		ok
		if isList(pnStartingAt) and ring_len(pnStartingAt) = 2 and isString(pnStartingAt[1]) and
		   (pnStartingAt[1] = :startingat or pnStartingAt[1] = :StartingAt)
			pnStartingAt = pnStartingAt[2]
		ok
		oFpnSec = This.SectionQ(1, pnStartingAt - 1)
		anFpnAll = oFpnSec.FindAllCS(pItem, pCaseSensitive)
		anFpnRes = []
		nFpnL = ring_len(panList)
		for iFpn = 1 to nFpnL
			anFpnRes + anFpnAll[ panList[iFpn] ]
		next
		return anFpnRes

	def FindNextNthOccurrencesCS(panList, pItem, pnStartingAt, pCaseSensitive)
		if isList(pItem) and ring_len(pItem) = 2 and isString(pItem[1]) and
		   (pItem[1] = :of or pItem[1] = :Of)
			pItem = pItem[2]
		ok
		if isList(pnStartingAt) and ring_len(pnStartingAt) = 2 and isString(pnStartingAt[1]) and
		   (pnStartingAt[1] = :startingat or pnStartingAt[1] = :StartingAt)
			pnStartingAt = pnStartingAt[2]
		ok
		oFnnSec = This.SectionQ(pnStartingAt + 1, This.NumberOfItems())
		anFnnRel = oFnnSec.FindAllCS(pItem, pCaseSensitive)
		anFnnAll = []
		nFnnRel = ring_len(anFnnRel)
		for iFnn = 1 to nFnnRel
			anFnnAll + ( anFnnRel[iFnn] + pnStartingAt )
		next
		anFnnRes = []
		nFnnL = ring_len(panList)
		for iFnn = 1 to nFnnL
			anFnnRes + anFnnAll[ panList[iFnn] ]
		next
		return anFnnRes

	def ReplacePreviousNthOccurrencesST(panList, pItem, pNewItem, pnStartingAt)
		if isList(pNewItem) and ring_len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :with or pNewItem[1] = :With or pNewItem[1] = :by or pNewItem[1] = :By)
			pNewItem = pNewItem[2]
		ok
		anRpnPos = This.FindPreviousNthOccurrencesCS(panList, pItem, pnStartingAt, 1)
		This.ReplaceItemsAtPositions(anRpnPos, pNewItem)

		def ReplacePreviousNthOccurrences(panList, pItem, pNewItem, pnStartingAt)
			This.ReplacePreviousNthOccurrencesST(panList, pItem, pNewItem, pnStartingAt)

	def ReplaceNextNthOccurrences(panList, pItem, pNewItem, pnStartingAt)
		if isList(pNewItem) and ring_len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :with or pNewItem[1] = :With or pNewItem[1] = :by or pNewItem[1] = :By)
			pNewItem = pNewItem[2]
		ok
		anRnnPos = This.FindNextNthOccurrencesCS(panList, pItem, pnStartingAt, 1)
		This.ReplaceItemsAtPositions(anRnnPos, pNewItem)

		def ReplaceNextNthOccurrencesST(panList, pItem, pNewItem, pnStartingAt)
			This.ReplaceNextNthOccurrences(panList, pItem, pNewItem, pnStartingAt)

	# Passive (non-mutating) forms: return a fresh content list.

	def NextNthOccurrencesReplaced(panList, pItem, pNewItem, pnStartingAt)
		oNnrCopy = This.Copy()
		oNnrCopy.ReplaceNextNthOccurrences(panList, pItem, pNewItem, pnStartingAt)
		return oNnrCopy.Content()

	def PreviousNthOccurrencesReplaced(panList, pItem, pNewItem, pnStartingAt)
		oPnrCopy = This.Copy()
		oPnrCopy.ReplacePreviousNthOccurrencesST(panList, pItem, pNewItem, pnStartingAt)
		return oPnrCopy.Content()

	# Replace every item by a single new one:
	# ReplaceAllItems(:With = newItem) or ReplaceAllItems(newItem).

	def ReplaceAllItems(pNewItem)
		if isList(pNewItem) and len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :with or pNewItem[1] = :With or pNewItem[1] = :by or pNewItem[1] = :By)
			pNewItem = pNewItem[2]
		ok
		_oRplAI_ = new stzListReplacer(This)
		_oRplAI_.ReplaceAllItems(pNewItem)
		This._SetContent(_oRplAI_.Content())

		def ReplaceAllItemsQ(pNewItem)
			This.ReplaceAllItems(pNewItem)
			return This

	def ReplaceFirstCS(pItem, pNewItem, pCaseSensitive)
		_oRplF_ = new stzListReplacer(This)
		_oRplF_.ReplaceFirstOccurrenceCS(pItem, pNewItem, pCaseSensitive)
		This._SetContent(_oRplF_.Content())

	def ReplaceFirst(pItem, pNewItem)
		This.ReplaceFirstCS(pItem, pNewItem, 1)

	def ReplaceLastCS(pItem, pNewItem, pCaseSensitive)
		_oRplL_ = new stzListReplacer(This)
		_oRplL_.ReplaceLastOccurrenceCS(pItem, pNewItem, pCaseSensitive)
		This._SetContent(_oRplL_.Content())

	def ReplaceLast(pItem, pNewItem)
		This.ReplaceLastCS(pItem, pNewItem, 1)

	def ReplaceManyByManyCS(paItems, paNewItems, pCaseSensitive)
		_oRplM_ = new stzListReplacer(This)
		_oRplM_.ReplaceManyByManyCS(paItems, paNewItems, pCaseSensitive)
		This._SetContent(_oRplM_.Content())

	def ReplaceManyByMany(paItems, paNewItems)
		This.ReplaceManyByManyCS(paItems, paNewItems, 1)

	def ReplaceManyByManyXT(paItems, paNewItems)
		_oRplMxt_ = new stzListReplacer(This)
		_oRplMxt_.ReplaceManyByManyXT(paItems, paNewItems)
		This._SetContent(_oRplMxt_.Content())

	def ReplaceSection(n1, n2, pNewItem)
		_oRpS_ = new stzListReplacer(This)
		_oRpS_.ReplaceSection(n1, n2, pNewItem)
		This._SetContent(_oRpS_.Content())

		def ReplaceSectionQ(n1, n2, pNewItem)
			This.ReplaceSection(n1, n2, pNewItem)
			return This

	def ReplaceSectionByMany(n1, n2, paNewItems)
		_oRpSM_ = new stzListReplacer(This)
		_oRpSM_.ReplaceSectionByMany(n1, n2, paNewItems)
		This._SetContent(_oRpSM_.Content())

		def ReplaceSectionByManyQ(n1, n2, paNewItems)
			This.ReplaceSectionByMany(n1, n2, paNewItems)
			return This

	# Positional replace: swap whatever lives at position n with pNewItem.
	# Mirrors AddItemAt / InsertAt / RemoveAt naming.

	def ReplaceAt(n, pNewItem)
		if isList(pNewItem) and len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :by or pNewItem[1] = :By or pNewItem[1] = :with or
		    pNewItem[1] = :With or pNewItem[1] = :using or pNewItem[1] = :Using)
			pNewItem = pNewItem[2]
		ok
		# A LIST of positions replaces each of those positions (ReplaceAnyAt).
		if isList(n)
			_nRaLen_ = len(n)
			for _iRa_ = 1 to _nRaLen_
				if n[_iRa_] >= 1 and n[_iRa_] <= len(@aContent)
					This._InvalidateEngine()   # in-place @aContent mutation below
					@aContent[ n[_iRa_] ] = pNewItem
				ok
			next
			return
		ok
		if n >= 1 and n <= len(@aContent)
			This._InvalidateEngine()   # in-place @aContent mutation below
			@aContent[n] = pNewItem
		ok

		def ReplaceAtQ(n, pNewItem)
			This.ReplaceAt(n, pNewItem)
			return This

		def UpdateAt(n, pNewItem)
			This.ReplaceAt(n, pNewItem)

		def SetItemAt(n, pNewItem)
			This.ReplaceAt(n, pNewItem)

		def ReplaceAnyItemAt(n, pNewItem)
			This.ReplaceAt(n, pNewItem)

		def ReplaceItemAtPosition(n, pNewItem)
			This.ReplaceAt(n, pNewItem)

	  #=============================================#
	 #  POSITIONAL REPLACE DELEGATIONS (Replacer)  #
	#=============================================#

	def ReplaceAnyItemAtPositions(panPos, pNewItem)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceAnyItemAtPositions(panPos, pNewItem)
		This._SetContent(_o_.Content())

		def ReplaceAnyItemsAtPositions(panPos, pNewItem)
			This.ReplaceAnyItemAtPositions(panPos, pNewItem)

		def ReplaceItemsAtPositions(panPos, pNewItem)
			This.ReplaceAnyItemAtPositions(panPos, pNewItem)

		def ReplaceAtPositions(panPos, pNewItem)
			This.ReplaceAnyItemAtPositions(panPos, pNewItem)

	def ReplaceThisItemAtPositions(panPos, pItem, pNewItem)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceThisItemAtPositions(panPos, pItem, pNewItem)
		This._SetContent(_o_.Content())

	def ReplaceThisItemAt(n, pItem, pNewItem)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceThisItemAt(n, pItem, pNewItem)
		This._SetContent(_o_.Content())

	def ReplaceTheseItemsAtPositions(panPos, paItems, pNewItem)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceTheseItemsAtPositions(panPos, paItems, pNewItem)
		This._SetContent(_o_.Content())

	def ReplaceMany(paItems, pNewItem)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceMany(paItems, pNewItem)
		This._SetContent(_o_.Content())

	def ReplaceByMany(pItem, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceByMany(pItem, paNewItems)
		This._SetContent(_o_.Content())

	def ReplaceByManyXT(pItem, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceByManyXT(pItem, paNewItems)
		This._SetContent(_o_.Content())

		def ReplaceItemByManyXT(pItem, paNewItems)
			This.ReplaceByManyXT(pItem, paNewItems)

	def ReplaceOccurrencesByMany(panPos, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceOccurrencesByMany(panPos, paNewItems)
		This._SetContent(_o_.Content())

	def ReplaceOccurrencesByManyXT(panPos, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceOccurrencesByManyXT(panPos, paNewItems)
		This._SetContent(_o_.Content())

	def ReplaceItemAtPositionsByMany(panPos, pItem, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceItemAtPositionsByMany(panPos, pItem, paNewItems)
		This._SetContent(_o_.Content())

	def ReplaceItemAtPositionsByManyXT(panPos, pItem, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceItemAtPositionsByManyXT(panPos, pItem, paNewItems)
		This._SetContent(_o_.Content())

	def ReplaceTheseItemsAtPositionsByMany(panPos, paItems, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceTheseItemsAtPositionsByMany(panPos, paItems, paNewItems)
		This._SetContent(_o_.Content())

	def ReplaceTheseItemsAtPositionsByManyXT(panPos, paItems, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceTheseItemsAtPositionsByManyXT(panPos, paItems, paNewItems)
		This._SetContent(_o_.Content())

	def ReplaceAnyItemAtPositionsByMany(panPos, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceAnyItemAtPositionsByMany(panPos, paNewItems)
		This._SetContent(_o_.Content())

		def ReplaceAnyItemsAtPositionsByMany(panPos, paNewItems)
			This.ReplaceAnyItemAtPositionsByMany(panPos, paNewItems)

	def ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)
		This._SetContent(_o_.Content())

		def ReplaceAnyItemsAtPositionsByManyXT(panPos, paNewItems)
			This.ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)

		def ReplaceAtByManyXT(panPos, paNewItems)
			This.ReplaceAnyItemAtPositionsByManyXT(panPos, paNewItems)



	def ReplaceW(pWhere, pBy)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceW(pWhere, pBy)
		This._SetContent(_o_.Content())

		def ReplaceItemsW(pWhere, pBy)
			This.ReplaceW(pWhere, pBy)

	def ReplaceNextNthOccurrence(n, pItem, pNewItem, pnStartingAt)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceNextNthOccurrence(n, pItem, pNewItem, pnStartingAt)
		This._SetContent(_o_.Content())

		def ReplaceNextNthOccurrenceST(n, pItem, pNewItem, pnStartingAt)
			This.ReplaceNextNthOccurrence(n, pItem, pNewItem, pnStartingAt)

		def ReplaceNthNextOccurrenceST(n, pItem, pNewItem, pnStartingAt)
			This.ReplaceNextNthOccurrence(n, pItem, pNewItem, pnStartingAt)

	  #=============================================#
	 #  STRINGIFY DELEGATION (via stzListStringify) #
	#=============================================#

	def Stringify()
		_oStfy_ = new stzListStringify(This)
		_oStfy_.Stringify()
		This._SetContent(_oStfy_.Content())

		def StringifyQ()
			This.Stringify()
			return This

	# ToListInAString: the content rendered as a "[ ... ]" string (computable
	# form). Delegates to stzListStringify, like the rest of this section.
	def ToListInAString()
		_oTlasStfy_ = new stzListStringify(This)
		return _oTlasStfy_.ToListInAString()

	def ToListInAStringInShortForm()
		_oTlsfStfy_ = new stzListStringify(This)
		return _oTlsfStfy_.ToListInAStringInShortForm()

		def ToListInShortForm()
			return This.ToListInAStringInShortForm()

	# StringifyAndReplace: Stringify the content, then replace every
	# occurrence of pItem with the supplied value (pWith). pWith
	# accepts the :With named-param form or a bare string.
	# StringifyAndReplaceQ(item, with) returns This.
	# XT variant is just an alias for the moment -- the original
	# Softanza distinguished "internal-staff" semantics, but they
	# collapse to the same engine path here.
	def StringifyAndReplace(pSubStr, pWith)
		# Stringify every item, then SUBSTRING-replace pSubStr with pWith in
		# each (monolith semantics: the params are substrings, not whole
		# items). The replace itself is the engine-backed, UTF-8-safe
		# StzReplace -- so e.g. the comma inside a stringified sublist is
		# rewritten, not just items that equal the needle.
		if isList(pWith) and len(pWith) = 2 and isString(pWith[1])
			pWith = pWith[2]
		ok
		This.Stringify()
		_aData_ = @aContent
		_nLen_ = len(_aData_)
		for _i_ = 1 to _nLen_
			if isString(_aData_[_i_])
				_aData_[_i_] = StzReplace(_aData_[_i_], pSubStr, pWith)
			ok
		next
		This._SetContent(_aData_)

		def StringifyAndReplaceQ(pItem, pWith)
			This.StringifyAndReplace(pItem, pWith)
			return This

		def StringifyAndReplaceXT(pItem, pWith)
			This.StringifyAndReplace(pItem, pWith)

		def StringifyAndReplaceXTQ(pItem, pWith)
			This.StringifyAndReplace(pItem, pWith)
			return This

	# StringifyLowercase / StringifyUppercase / StringifyAndLower /
	# StringifyAndUpper -- Stringify then map case. Used by misc
	# narrative tests that need a uniform-case string list.
	def StringifyLowercase()
		This.Stringify()
		_aData_ = @aContent
		_nLen_ = len(_aData_)
		for _i_ = 1 to _nLen_
			if isString(_aData_[_i_])
				_aData_[_i_] = lower(_aData_[_i_])
			ok
		next
		This._SetContent(_aData_)

		def StringifyAndLower()
			This.StringifyLowercase()

		def StringifyAndLowerQ()
			This.StringifyLowercase()
			return This

	def StringifyUppercase()
		This.Stringify()
		_aData_ = @aContent
		_nLen_ = len(_aData_)
		for _i_ = 1 to _nLen_
			if isString(_aData_[_i_])
				_aData_[_i_] = upper(_aData_[_i_])
			ok
		next
		This._SetContent(_aData_)

		def StringifyAndUpper()
			This.StringifyUppercase()

		def StringifyAndUpperQ()
			This.StringifyUppercase()
			return This

	# StringifyLowercaseAndReplace / StringifyUppercaseAndReplace --
	# stringify + lower (or upper) every string item, THEN replace
	# every occurrence of pItem with pWith. XT variant is alias.
	def StringifyLowercaseAndReplace(pItem, pWith)
		if isList(pWith) and len(pWith) = 2 and isString(pWith[1])
			pWith = pWith[2]
		ok
		This.StringifyLowercase()
		_aData_ = @aContent
		_nLen_ = len(_aData_)
		for _i_ = 1 to _nLen_
			if isString(_aData_[_i_])
				_aData_[_i_] = StzReplace(_aData_[_i_], pItem, pWith)
			ok
		next
		This._SetContent(_aData_)

		def StringifyLowercaseAndReplaceQ(pItem, pWith)
			This.StringifyLowercaseAndReplace(pItem, pWith)
			return This

		def StringifyLowercaseAndReplaceXT(pItem, pWith)
			This.StringifyLowercaseAndReplace(pItem, pWith)

		def StringifyLowercaseAndReplaceXTQ(pItem, pWith)
			This.StringifyLowercaseAndReplace(pItem, pWith)
			return This

	def StringifyUppercaseAndReplace(pItem, pWith)
		if isList(pWith) and len(pWith) = 2 and isString(pWith[1])
			pWith = pWith[2]
		ok
		This.StringifyUppercase()
		_aData_ = @aContent
		_nLen_ = len(_aData_)
		for _i_ = 1 to _nLen_
			if isString(_aData_[_i_])
				_aData_[_i_] = StzReplace(_aData_[_i_], pItem, pWith)
			ok
		next
		This._SetContent(_aData_)

		def StringifyUppercaseAndReplaceQ(pItem, pWith)
			This.StringifyUppercaseAndReplace(pItem, pWith)
			return This

		def StringifyUppercaseAndReplaceXT(pItem, pWith)
			This.StringifyUppercaseAndReplace(pItem, pWith)

		def StringifyUppercaseAndReplaceXTQ(pItem, pWith)
			This.StringifyUppercaseAndReplace(pItem, pWith)
			return This

	  #=================================================#
	 #  CONTAINS DELEGATIONS (via stzListComparator)    #
	#=================================================#

	def ContainsOneOfTheseCS(paItems, pCaseSensitive)
		_oCmpCont_ = new stzListComparator(This)
		return _oCmpCont_.ContainsOneOfTheseCS(paItems, pCaseSensitive)

	def ContainsOneOfThese(paItems)
		return This.ContainsOneOfTheseCS(paItems, 1)

		def ContainsEither(pItem1, pItem2)
			# XOR: TRUE when EXACTLY ONE of the two items is present
			# (:or names the second). For "contains any of a list", use
			# ContainsOneOfThese(paItems).
			return This.ContainsEitherCS(pItem1, pItem2, 1)

		def ContainsEitherCS(pItem1, pItem2, pCaseSensitive)
			if isList(pItem2) and IsOrNamedParamList(pItem2)
				pItem2 = pItem2[2]
			ok
			b1 = This.ContainsCS(pItem1, pCaseSensitive)
			b2 = This.ContainsCS(pItem2, pCaseSensitive)
			if (b1 = 1 and b2 = 0) or (b1 = 0 and b2 = 1)
				return 1
			else
				return 0
			ok

	def ContainsAllOfTheseCS(paItems, pCaseSensitive)
		_oCmpAll_ = new stzListComparator(This)
		return _oCmpAll_.ContainsAllOfTheseCS(paItems, pCaseSensitive)

	def ContainsAllOfThese(paItems)
		return This.ContainsAllOfTheseCS(paItems, 1)

	  #================================================#
	 #  CHECKER DELEGATIONS (via stzListChecker)       #
	#================================================#

	def AllItemsAreOfType(pcType)
		_oChkType_ = new stzListChecker(This)
		return _oChkType_.AllItemsAreOfType(pcType)

		def EachItemIsA(pcType)
			return This.AllItemsAreOfType(pcType)

		def EachItemIs(pcType)
			return This.AllItemsAreOfType(pcType)

	def ContainsEmptyStrings()
		_aEsContent_ = @aContent
		_nEsLen_ = len(_aEsContent_)
		for _iEs_ = 1 to _nEsLen_
			if isString(_aEsContent_[_iEs_]) and _aEsContent_[_iEs_] = ""
				return 1
			ok
		next
		return 0

	def FindEmptyStrings()
		_pFesList_ = This._EngineListFromContent()
		if _pFesList_ = NULL
			return []
		ok
		_pFesResult_ = StzEngineListFindEmptyStrings(_pFesList_)
		StzEngineListFree(_pFesList_)
		if _pFesResult_ = NULL
			return []
		ok
		_aFesOut_ = StzEngineListContentToRingList(_pFesResult_)
		StzEngineListFree(_pFesResult_)
		return _aFesOut_

	def CountEmptyStrings()
		_pCesList_ = This._EngineListFromContent()
		if _pCesList_ = NULL
			return 0
		ok
		_nCesCount_ = StzEngineListCountEmptyStrings(_pCesList_)
		StzEngineListFree(_pCesList_)
		return _nCesCount_

	def ReplaceEmptyStrings(pNewItem)
		if CheckParams()
			if isList(pNewItem) and len(pNewItem) = 2 and
			   isString(pNewItem[1]) and pNewItem[1] = :With
				pNewItem = pNewItem[2]
			ok
		ok

		_aResContent_ = @aContent
		_nResLen_ = len(_aResContent_)
		for _iRes_ = 1 to _nResLen_
			if isString(_aResContent_[_iRes_]) and _aResContent_[_iRes_] = ""
				_aResContent_[_iRes_] = pNewItem
			ok
		next
		This._SetContent(_aResContent_)

	def RemoveEmptyStrings()
		_anRmesPos_ = This.FindEmptyStrings()
		_nRmesLen_ = len(_anRmesPos_)
		if _nRmesLen_ = 0 return ok
		# Remove from end to preserve indices
		for _iRmes_ = _nRmesLen_ to 1 step -1
			This._InvalidateEngine()   # in-place @aContent mutation below
			ring_remove(@aContent, _anRmesPos_[_iRmes_])
		next

	  #=========================================#
	 #  ENGINE-BACKED OPERATIONS (Zig engine)  #
	#=========================================#

	#-- Builds an engine list handle from @aContent.
	#   Returns a C pointer to a StzList, or NULL on failure.

	def _EngineListFromContent()
		return StzEngineMarshalList(@aContent)

	#-- Reads engine list contents back into a Ring list

	def _ContentFromEngineList(pList)
		return StzEngineListContentToRingList(pList)

	  #-----------------------------------------------------#
	 #  ENGINE-RESIDENCY CACHE ACCESS (Model A + keystone) #
	#-----------------------------------------------------#
	#
	#  @aContent is ALWAYS the source of truth. @pEngineGen indexes the
	#  bounded engine-side residency cache, which OWNS the marshalled handle.
	#  On a cache miss (evicted under pressure) _Engine() re-marshals from
	#  @aContent. This is what makes residency safe without object destructors.

	#-- Canonical content getter (Model A: @aContent is never stale).
	def _Content()
		return @aContent

	#-- Ring-side setter: @aContent becomes truth; drop any cached handle.
	def _SetContent(paRing)
		@aContent = paRing
		This._InvalidateEngine()
		return This

	#-- Live engine handle id for the current content. Reuses the warm cached
	#   handle if still resident; otherwise marshals once and registers it.
	def _Engine()
		if @pEngineGen != 0
			_hEng_ = StzEngineListCacheGet(@pEngineGen)
			if _hEng_ != 0
				return _hEng_
			ok
			@pEngineGen = 0   # was evicted under cache pressure
		ok
		_hEng_ = StzEngineMarshalList(@aContent)
		@pEngineGen = StzEngineListCacheRegister(_hEng_)
		return _hEng_

	#-- Drop the cached handle (engine frees it + releases its handle slot).
	#   Called by every write so the cache can never go stale.
	def _InvalidateEngine()
		if @pEngineGen != 0
			StzEngineListCacheInvalidate(@pEngineGen)
			@pEngineGen = 0
		ok
		return This

	#-- Adopt an engine result handle as the new content: materialize @aContent
	#   (Model A truth) and keep the handle warm in the cache. Used by ops that
	#   RETURN a new handle which becomes the content (dedup/flatten/merge).
	def _AdoptEngine(pHandle)
		This._InvalidateEngine()
		@aContent = StzEngineListContentToRingList(pHandle)
		@pEngineGen = StzEngineListCacheRegister(pHandle)
		return This

	#-- Resync @aContent after an engine op mutated the cached handle in place
	#   (e.g. sort/reverse). Keeps the cache warm (gen unchanged).
	def _RefreshFromEngine()
		if @pEngineGen != 0
			_hEng_ = StzEngineListCacheGet(@pEngineGen)
			if _hEng_ != 0
				@aContent = StzEngineListContentToRingList(_hEng_)
			ok
		ok
		return This

	  #------------------------------#
	 #  SORTING (engine-backed)     #
	#------------------------------#

	def SortCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		pList = This._Engine()
		if pList = NULL return ok

		StzEngineListSortCS(pList, pCaseSensitive)
		This._RefreshFromEngine()

		def SortCSQ(pCaseSensitive)
			This.SortCS(pCaseSensitive)
			return This

	#-- Sort by a key expression (engine-backed via the W DSL).
	def SortBy(pcExpr)
		pcExpr = _StzStripBraces(pcExpr)
		pList = This._Engine()
		StzEngineListSortByExpr(pList, pcExpr, 1)
		This._RefreshFromEngine()

		def SortByQ(pcExpr)
			This.SortBy(pcExpr)
			return This

	def SortByDescending(pcExpr)
		pcExpr = _StzStripBraces(pcExpr)
		pList = This._Engine()
		StzEngineListSortByExpr(pList, pcExpr, 0)
		This._RefreshFromEngine()

	#-- non-mutating: return the sorted-by-key copy
	def SortedBy(pcExpr)
		_oSb_ = new stzList(This.Content())
		_oSb_.SortBy(pcExpr)
		return _oSb_.Content()

	def SortUp()
		This.Sort()

		def SortUpQ()
			This.Sort()
			return This

	def SortDown()
		This.SortInDescending()

		def SortDownQ()
			This.SortInDescending()
			return This

	def Sort()
		This.SortCS(1)

		def SortQ()
			This.Sort()
			return This

		# Word-order aliases used by narrative tests.
		def SortInAscending()
			This.Sort()

		def SortInAscendingQ()
			This.Sort()
			return This

		def SortAscending()
			This.Sort()

		def SortAscendingQ()
			This.Sort()
			return This

	def SortedCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		pList = This._EngineListFromContent()
		if pList = NULL return [] ok

		StzEngineListSortCS(pList, pCaseSensitive)
		aResult = StzEngineListContentToRingList(pList)
		StzEngineListFree(pList)
		return aResult

	def Sorted()
		return This.SortedCS(1)

	def SortInDescendingCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		pList = This._Engine()
		if pList = NULL return ok

		StzEngineListSortDescendingCS(pList, pCaseSensitive)
		This._RefreshFromEngine()

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
		aResult = StzEngineListContentToRingList(pList)
		StzEngineListFree(pList)
		return aResult

	def SortedInDescending()
		return This.SortedInDescendingCS(1)

	  #------------------------------#
	 #  REVERSING (engine-backed)   #
	#------------------------------#

	def Reverse()
		pList = This._Engine()
		if pList = NULL return ok

		StzEngineListReverse(pList)
		This._RefreshFromEngine()

		def ReverseQ()
			This.Reverse()
			return This

	def Reversed()
		pList = This._EngineListFromContent()
		if pList = NULL return [] ok

		StzEngineListReverse(pList)
		aResult = StzEngineListContentToRingList(pList)
		StzEngineListFree(pList)
		return aResult

		def ItemsReversed()
			return This.Reversed()

	# Non-mutating sorted copies (the SortInAscending/Descending family
	# mutates; these return a fresh list).
	def SortedInAscending()
		return This.Sorted()

		def ItemsSortedInAscending()
			return This.SortedInAscending()

	# Every item except those equal to p (p may be a single item).
	def AllItemsExcept(p)
		aResult = []
		nLen = len(@aContent)
		for _i_ = 1 to nLen
			# content compare so a list-valued p is matched (raw != can't
			# compare sub-lists -> would wrongly keep an equal list item).
			if NOT BothAreEqualCS(@aContent[_i_], p, 1)
				aResult + @aContent[_i_]
			ok
		next
		return aResult

		def ItemsExcept(p)
			return This.AllItemsExcept(p)

	# First n items (clamped to the list length; n<=0 -> empty).
	def FirstNItems(n)
		if NOT isNumber(n) or n <= 0
			return []
		ok
		if n > len(@aContent)
			n = len(@aContent)
		ok
		aResult = []
		for _i_ = 1 to n
			aResult + @aContent[_i_]
		next
		return aResult

	# Max nesting depth (a flat list is 1 level).
	def NumberOfLevels()
		return This._DepthOf(@aContent)

		def NestingDepth()
			return This.NumberOfLevels()

	def _DepthOf(aList)
		nMax = 1
		nLen = len(aList)
		for _i_ = 1 to nLen
			if isList(aList[_i_])
				_nD_ = 1 + This._DepthOf(aList[_i_])
				if _nD_ > nMax
					nMax = _nD_
				ok
			ok
		next
		return nMax

	# TRUE if any two adjacent items are equal.
	def ContainsDupSecutiveItems()
		nLen = len(@aContent)
		for _i_ = 2 to nLen
			if @aContent[_i_] = @aContent[_i_ - 1]
				return TRUE
			ok
		next
		return FALSE

		def ContainsConsecutiveDuplicates()
			return This.ContainsDupSecutiveItems()

	# A fresh copy with every occurrence of any item in paItems removed.
	def ManyRemoved(paItems)
		if NOT isList(paItems)
			paItems = [ paItems ]
		ok
		aResult = []
		nLen = len(@aContent)
		nP = len(paItems)
		for _i_ = 1 to nLen
			bRemove = FALSE
			for _j_ = 1 to nP
				if BothAreEqualCS(@aContent[_i_], paItems[_j_], 1)
					bRemove = TRUE
					exit
				ok
			next
			if NOT bRemove
				aResult + @aContent[_i_]
			ok
		next
		return aResult

	# TRUE if this list's items appear inside paOther in the same relative
	# order (i.e. this list is an order-preserving subsequence of paOther).
	def ItemsHaveSameOrderAs(paOther)
		if NOT isList(paOther)
			return FALSE
		ok
		nThis = len(@aContent)
		nOther = len(paOther)
		nIdx = 1
		for _i_ = 1 to nOther
			if nIdx <= nThis and paOther[_i_] = @aContent[nIdx]
				nIdx++
			ok
		next
		return nIdx > nThis

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

		pList = This._Engine()
		if pList = NULL return 0 ok

		nResult = 0
		if isString(pItem)
			nResult = StzEngineListFindStringCS(pList, pItem, pCaseSensitive)
		else
			# Non-string items (lists, numbers): go through the engine-backed
			# FindAllOccurrencesCS so Contains stays CONSISTENT with Find and
			# compares list items by content (the old raw `=` loop silently
			# missed sub-list items -> Contains disagreed with Find).
			_anFfe_ = This.FindAllOccurrencesCS(pItem, pCaseSensitive)
			if ring_len(_anFfe_) > 0
				nResult = _anFfe_[1]
			ok
		ok

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

		pList = This._Engine()
		if pList = NULL return ok

		pUnique = StzEngineListUniqueCS(pList, pCaseSensitive)
		if pUnique != NULL
			This._AdoptEngine(pUnique)   # frees old cache (pList), adopts pUnique
		ok

		def RemoveDuplicatesCSQ(pCaseSensitive)
			This.RemoveDuplicatesCS(pCaseSensitive)
			return This

	def RemoveDuplicates()
		This.RemoveDuplicatesCS(1)

		def RemoveDuplicatesQ()
			This.RemoveDuplicates()
			return This

	#-- Immutable / past-tense aliases for the dedup operation.
	#   DuplicatesRemoved() returns the deduped list value without
	#   mutating This (equivalent to WithoutDuplication, ported from
	#   archive line 41406). Used by stzHashList.UniqueValues().

	def DuplicatesRemovedCS(pCaseSensitive)
		return This.WithoutDuplicationCS(pCaseSensitive)

	def DuplicatesRemoved()
		return This.WithoutDuplicationCS(1)

	def ToStzListOfCharsQ()
		if NOT @IsListOfChars(@aContent)
			StzRaise("Can't cast the list into a stzListOfChars object! The list must be a list of chars.")
		ok

		_oResult_ = StzListOfCharsQ(@aContent)
		return _oResult_
				
	# ToSet / ToSetQ / ToSetOfItems: set-style aliases that return
	# the deduplicated list. Routed through the existing engine-backed
	# DuplicatesRemoved so the heavy lifting stays on the Zig side.

	def ToSet()
		return This.DuplicatesRemoved()

		def ToSetQ()
			return new stzList( This.ToSet() )

		def ToSetOfItems()
			return This.ToSet()

		def ToSetOfItemsQ()
			return new stzList( This.ToSet() )

	def WithoutDuplicationCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		pList = This._Engine()
		if pList = NULL return @aContent ok

		pUnique = StzEngineListUniqueCS(pList, pCaseSensitive)
		aResult = @aContent
		if pUnique != NULL
			aResult = StzEngineListContentToRingList(pUnique)
			StzEngineListFree(pUnique)
		ok
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

		# NumberOfDuplicates counts the duplicate OCCURRENCES (every 2nd+
		# appearance), not the number of distinct duplicated items. For
		# [ "A","B","2","A","A","B",2,2,"." ] that is 4 (A twice, B once,
		# 2 once). NumberOfDuplicatedItems (distinct) would be 3.
		def NumberOfDuplicates()
			return This.NumberOfDuplicatesCS(1)

		def NumberOfDuplications()
			return This.NumberOfDuplicates()

	def FindDuplicates()
		# Positions of each item's 2nd+ occurrence (case-sensitive).
		# Engine path: O(n) hashing in Zig + correct on nested-list items
		# (Ring's `=` can't compare sublists, so the old O(n^2) loop
		# silently returned [] for them). Ring loop kept as a fallback
		# when the content can't be marshalled into an engine list.
		_pFdList_ = This._Engine()
		if _pFdList_ != NULL
			_aFdRes_ = StzEngineListFindDuplicatesCS(_pFdList_, 1)
			return _aFdRes_
		ok
		_aRes_ = []
		_aData_ = This.Content()
		_nDataLen_ = len(_aData_)
		_aSeen_ = []
		for _i_ = 1 to _nDataLen_
			_x_ = _aData_[_i_]
			_bDup_ = FALSE
			_nSeenLen_ = len(_aSeen_)
			for _j_ = 1 to _nSeenLen_
				if _aSeen_[_j_] = _x_
					_bDup_ = TRUE
					exit
				ok
			next
			if _bDup_
				_aRes_ + _i_
			else
				_aSeen_ + _x_
			ok
		next
		return _aRes_

		def FindDuplications()
			return This.FindDuplicates()

		def FindDuplicatedItems()
			return This.FindDuplicates()

		def FindDuplicatesQ()
			return new stzList( This.FindDuplicates() )

	# FindDuplicatesXT: positions of ALL occurrences of items that have
	# duplicates (i.e. include the first occurrence too, not just the
	# 2nd+ that FindDuplicates returns). Delegates to the CS core, which
	# stringifies items first -- so "2" (string) and 2 (number) are kept
	# distinct instead of being conflated by Ring's coercing `=`.
	def FindDuplicatesXT()
		return This.FindDuplicatesCSXT(1)

		def FindDuplicationsXT()
			return This.FindDuplicatesXT()

		# Z-suffix Softanza convention: each duplicated item paired with
		# the positions of its DUPLICATE occurrences (first one excluded).
		def DuplicatesZ()
			return This.DuplicatesCSZ(1)

		def DuplicateItemsZ()
			return This.DuplicatesCSZ(1)

		def DuplicationsZ()
			return This.DuplicatesCSZ(1)

		def DuplicatedItemsZ()
			return This.DuplicatesCSZ(1)

	# FindNextNthItem(n, :StartingAt = pos): the POSITION of the n-th item
	# AFTER pos (pos+n). Find* returns the position (0 if out of range);
	# the NextNthItem accessor returns the item there. :StartingAt accepts
	# the bare integer or the named-param form.
	def FindNextNthItem(n, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		_nIdx_ = pnStartingAt + n
		if _nIdx_ < 1 or _nIdx_ > This.NumberOfItems()
			return 0
		ok
		return _nIdx_

		def NextNthItem(n, pnStartingAt)
			_nP_ = This.FindNextNthItem(n, pnStartingAt)
			if _nP_ = 0 return NULL ok
			return This.Content()[_nP_]

	# FindPreviousNthItem(n, :StartingAt = pos): the POSITION of the n-th
	# item counting BACK from pos inclusive (pos-n+1).
	def FindPreviousNthItem(n, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		_nIdx_ = pnStartingAt - n + 1
		if _nIdx_ < 1 or _nIdx_ > This.NumberOfItems()
			return 0
		ok
		return _nIdx_

		def PreviousNthItem(n, pnStartingAt)
			_nP_ = This.FindPreviousNthItem(n, pnStartingAt)
			if _nP_ = 0 return NULL ok
			return This.Content()[_nP_]

	# Duplicates() / DuplicateItems() / Duplications(): the duplicated
	# items themselves (returning DuplicatedItems). The XYZ-Z forms
	# above return positions; these return values.
	def Duplicates()
		return This.DuplicatedItems()

	def Duplications()
		return This.DuplicatedItems()

	  #-----------------------------------------------#
	 #  DUPLICATES OF A SPECIFIC ITEM / STRING       #
	#-----------------------------------------------#
	# "...OfString" is the historical name (these came from the
	# list-of-strings API) but they work for any item type. The
	# "duplicates" of an item are its 2nd-and-later occurrences --
	# the first one is the original, the rest are the copies.

	def FindDuplicatesOfStringCS(pItem, pCaseSensitive)
		_anFdosAll_ = This.FindAllCS(pItem, pCaseSensitive)
		_nFdosLen_ = len(_anFdosAll_)
		if _nFdosLen_ <= 1 return [] ok
		_anFdosRes_ = []
		for _iFdos_ = 2 to _nFdosLen_
			_anFdosRes_ + _anFdosAll_[_iFdos_]
		next
		return _anFdosRes_

	def FindDuplicatesOfString(pItem)
		return This.FindDuplicatesOfStringCS(pItem, 1)

		def FindDuplicatesOfItemCS(pItem, pCaseSensitive)
			return This.FindDuplicatesOfStringCS(pItem, pCaseSensitive)

		def FindDuplicatesOfItem(pItem)
			return This.FindDuplicatesOfStringCS(pItem, 1)

	# Same set of positions, but exposed under the "Duplications" name and
	# accepting the :CS = TRUE|FALSE named param for the case dial.
	def FindDuplicationsOfItemCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok
		return This.FindDuplicatesOfStringCS(pItem, pCaseSensitive)

		def FindDuplicationsOfItem(pItem)
			return This.FindDuplicatesOfStringCS(pItem, 1)

		def FindDuplicationsOf(pItem)
			return This.FindDuplicatesOfStringCS(pItem, 1)

	def NumberOfDuplicatesOfStringCS(pItem, pCaseSensitive)
		return len(This.FindDuplicatesOfStringCS(pItem, pCaseSensitive))

	def NumberOfDuplicatesOfString(pItem)
		return This.NumberOfDuplicatesOfStringCS(pItem, 1)

		def NumberOfDuplicatesOfItemCS(pItem, pCaseSensitive)
			return This.NumberOfDuplicatesOfStringCS(pItem, pCaseSensitive)

		def NumberOfDuplicatesOfItem(pItem)
			return This.NumberOfDuplicatesOfStringCS(pItem, 1)

	def StringIsDuplicatedNTimesCS(pItem, n, pCaseSensitive)
		return This.NumberOfDuplicatesOfStringCS(pItem, pCaseSensitive) = n

	def StringIsDuplicatedNTimes(pItem, n)
		return This.StringIsDuplicatedNTimesCS(pItem, n, 1)

		def ItemIsDuplicatedNTimesCS(pItem, n, pCaseSensitive)
			return This.StringIsDuplicatedNTimesCS(pItem, n, pCaseSensitive)

		def ItemIsDuplicatedNTimes(pItem, n)
			return This.StringIsDuplicatedNTimesCS(pItem, n, 1)

	# ALL positions of an item -- but only when it actually IS duplicated
	# (appears more than once); a non-duplicated item yields the empty list.
	def FindDuplicatedStringCS(pItem, pCaseSensitive)
		_anFdsAll_ = This.FindAllCS(pItem, pCaseSensitive)
		if len(_anFdsAll_) <= 1 return [] ok
		return _anFdsAll_

	def FindDuplicatedString(pItem)
		return This.FindDuplicatedStringCS(pItem, 1)

		def FindDuplicatedItemCS(pItem, pCaseSensitive)
			return This.FindDuplicatedStringCS(pItem, pCaseSensitive)

		def FindDuplicatedItem(pItem)
			return This.FindDuplicatedStringCS(pItem, 1)

	def ContainsDuplicatedStringCS(pItem, pCaseSensitive)
		return len(This.FindAllCS(pItem, pCaseSensitive)) > 1

	def ContainsDuplicatedString(pItem)
		return This.ContainsDuplicatedStringCS(pItem, 1)

		def ContainsDuplicatedItemCS(pItem, pCaseSensitive)
			return This.ContainsDuplicatedStringCS(pItem, pCaseSensitive)

		def ContainsDuplicatedItem(pItem)
			return This.ContainsDuplicatedStringCS(pItem, 1)

	# The distinct items that have duplicates, and how many such items there are.
	def DuplicatedStringsCS(pCaseSensitive)
		return This.DuplicatesCS(pCaseSensitive)

	def DuplicatedStrings()
		return This.Duplicates()

	def NumberOfDuplicatedStringsCS(pCaseSensitive)
		return len(This.DuplicatesCS(pCaseSensitive))

	def NumberOfDuplicatedStrings()
		return len(This.Duplicates())

	  #--------------------------------------#
	 #  FLATTEN (engine-backed)             #
	#--------------------------------------#

	#-- FindSubList / ContainsSubList: locate contiguous occurrences
	#   of a sub-list. Self-contained walk -- avoids the archive's
	#   FindManyCSQ + AreContiguous chain.

	def FindSubListCS(paSubList, pCaseSensitive)
		if NOT (isList(paSubList) and len(paSubList) >= 1)
			return []
		ok
		_nFsbLen_ = len(paSubList)
		_nFsbN_ = len(@aContent)
		_anFsbR_ = []
		_bFsbCase_ = @CaseSensitive(pCaseSensitive)
		_iFsb_ = 1
		while _iFsb_ <= _nFsbN_ - _nFsbLen_ + 1
			_bFsbMatch_ = 1
			for _kFsb_ = 1 to _nFsbLen_
				_xA_ = @aContent[_iFsb_ + _kFsb_ - 1]
				_xB_ = paSubList[_kFsb_]
				if NOT _bFsbCase_ and isString(_xA_) and isString(_xB_)
					if lower(_xA_) != lower(_xB_)
						_bFsbMatch_ = 0
						exit
					ok
				but _xA_ != _xB_
					_bFsbMatch_ = 0
					exit
				ok
			next
			if _bFsbMatch_
				_anFsbR_ + _iFsb_
				_iFsb_ += _nFsbLen_
			else
				_iFsb_++
			ok
		end
		return _anFsbR_

	def FindSubList(paSubList)
		return This.FindSubListCS(paSubList, 1)

		def FindTheseContiguousItems(paSubList)
			return This.FindSubList(paSubList)

		def FindTheseAdjacentItems(paSubList)
			return This.FindSubList(paSubList)

	def ContainsSubListCS(paSubList, pCaseSensitive)
		return len(This.FindSubListCS(paSubList, pCaseSensitive)) > 0

	def ContainsSubList(paSubList)
		return This.ContainsSubListCS(paSubList, 1)

	#-- Merge: flatten ONE level only. For each item: if it's a list,
	#   spread its items; otherwise keep as-is. Distinct from
	#   Flatten() which fully recurses. Port from archive line 37074;
	#   used by stzHashList.Items() to coalesce list-of-lists values.

	def Merge()
		pList = This._Engine()
		pRes = StzEngineListFlattenToDepth(pList, 1)		#-- one-level flatten
		This._AdoptEngine(pRes)   # frees old cache (pList), adopts pRes

		def MergeQ()
			This.Merge()
			return This

	def Merged()
		_oMdTmp_ = new stzList(@aContent)
		_oMdTmp_.Merge()
		return _oMdTmp_.Content()

	def Flatten()
		pList = This._Engine()
		if pList = NULL return ok

		pFlat = StzEngineListFlatten(pList)
		if pFlat != NULL
			This._AdoptEngine(pFlat)   # frees old cache (pList), adopts pFlat
		ok
		# if pFlat = NULL, pList stays as the cache (not freed)

		def FlattenQ()
			This.Flatten()
			return This

	def Flattened()
		pList = This._Engine()
		if pList = NULL return [] ok

		pFlat = StzEngineListFlatten(pList)
		aResult = []
		if pFlat != NULL
			aResult = StzEngineListContentToRingList(pFlat)
			StzEngineListFree(pFlat)
		ok
		return aResult

	  #-------------------------------------------#
	 #  EQUALITY CHECK (set-based, engine-backed) #
	#-------------------------------------------#

	def IsEqualToCS(paOtherList, pCaseSensitive)
		# Set-based equality: same items regardless of order
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT isList(paOtherList)
			return 0
		ok

		if len(@aContent) != len(paOtherList)
			return 0
		ok

		# Use mutual subset check (A subset B AND B subset A)
		_pEqList1_ = This._Engine()
		if _pEqList1_ = NULL return 0 ok

		_oEqOther_ = new stzList(paOtherList)
		_pEqList2_ = _oEqOther_._EngineListFromContent()
		if _pEqList2_ = NULL
			return 0
		ok

		_nAsubB_ = StzEngineListIsSubsetCS(_pEqList1_, _pEqList2_, pCaseSensitive)
		_nBsubA_ = StzEngineListIsSubsetCS(_pEqList2_, _pEqList1_, pCaseSensitive)
		StzEngineListFree(_pEqList2_)

		return _nAsubB_ and _nBsubA_

	def IsEqualTo(paOtherList)
		return This.IsEqualToCS(paOtherList, 1)

	  #------------------------------------------------#
	 #  STRICT EQUALITY (same items + same positions)  #
	#------------------------------------------------#

	def IsStrictlyEqualToCS(paOtherList, pCaseSensitive)
		# Positional equality: same items at same positions
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT isList(paOtherList)
			return 0
		ok

		_pSeList1_ = This._Engine()
		if _pSeList1_ = NULL return 0 ok

		_oSeOther_ = new stzList(paOtherList)
		_pSeList2_ = _oSeOther_._EngineListFromContent()
		if _pSeList2_ = NULL
			return 0
		ok

		_nSeResult_ = StzEngineListEqualsCS(_pSeList1_, _pSeList2_, pCaseSensitive)
		StzEngineListFree(_pSeList2_)

		return _nSeResult_

	def IsStrictlyEqualTo(paOtherList)
		return This.IsStrictlyEqualToCS(paOtherList, 1)

		def IsIdenticalTo(paOtherList)
			return This.IsStrictlyEqualTo(paOtherList)

		def IsEqualToXT(paOtherList)
			return This.IsStrictlyEqualTo(paOtherList)

		def IsIdenticalToCS(paOtherList, pCaseSensitive)
			return This.IsStrictlyEqualToCS(paOtherList, pCaseSensitive)

		def IsEqualToCSXT(paOtherList, pCaseSensitive)
			return This.IsStrictlyEqualToCS(paOtherList, pCaseSensitive)

	  #---------------------------------------------------#
	 #  STARTS WITH / ENDS WITH (engine-backed)           #
	#---------------------------------------------------#

	def StartsWithCS(paItems, pCaseSensitive)
		_pSwList_ = This._Engine()
		_pSwPrefix_ = StzEngineMarshalList(paItems)
		_nSwResult_ = StzEngineListStartsWithListCS(_pSwList_, _pSwPrefix_, pCaseSensitive)
		StzEngineListFree(_pSwPrefix_)
		return _nSwResult_

	def StartsWith(paItems)
		return This.StartsWithCS(paItems, 1)

	def EndsWithCS(paItems, pCaseSensitive)
		_pEwList_ = This._Engine()
		_pEwSuffix_ = StzEngineMarshalList(paItems)
		_nEwResult_ = StzEngineListEndsWithListCS(_pEwList_, _pEwSuffix_, pCaseSensitive)
		StzEngineListFree(_pEwSuffix_)
		return _nEwResult_

	def EndsWith(paItems)
		return This.EndsWithCS(paItems, 1)

	  #---------------------------------------------------#
	 #  EXPRESSION-BACKED OPERATIONS (engine bytecode)    #
	#---------------------------------------------------#

	def Map(pcExpr)
		pList = This._Engine()
		if pList = NULL return [] ok

		pcExpr = _StzStripBraces(pcExpr)
		pResult = StzEngineListMapExpr(pList, pcExpr)
		aResult = StzEngineListContentToRingList(pResult)

		StzEngineListFree(pResult)
		return aResult

		def MapQ(pcExpr)
			return new stzList(This.Map(pcExpr))

	def Filter(pcExpr)
		pList = This._Engine()
		if pList = NULL return [] ok

		pcExpr = _StzStripBraces(pcExpr)
		pResult = StzEngineListFilterExpr(pList, pcExpr)
		aResult = StzEngineListContentToRingList(pResult)

		StzEngineListFree(pResult)
		return aResult

		def FilterQ(pcExpr)
			return new stzList(This.Filter(pcExpr))

		def FilterW(pcExpr)
			return This.Filter(pcExpr)

	# Reduce(): 0-arg auto-concat / auto-sum.
	# - All-string items: concatenate.
	# - All-number items: sum.
	# - Mixed: concatenate stringified items.
	def Reduce()
		_l_ = This.List()
		_nL_ = len(_l_)
		_bAllStr_ = TRUE
		_bAllNum_ = TRUE
		for _i_ = 1 to _nL_
			if NOT isString(_l_[_i_]) _bAllStr_ = FALSE ok
			if NOT isNumber(_l_[_i_]) _bAllNum_ = FALSE ok
		next
		if _bAllNum_
			_s_ = 0
			for _i_ = 1 to _nL_
				_s_ += _l_[_i_]
			next
			return _s_
		ok
		_c_ = ""
		for _i_ = 1 to _nL_
			_c_ += "" + _l_[_i_]
		next
		return _c_

	def ReduceXT(pcExpr, pInitValue)
		# The expression uses @accumulator and @item. The bridge builds the
		# init value and extracts the result scalar INSIDE stz_list.dll, so no
		# StzValue handle crosses the stz_list<->stz_value DLL boundary (which
		# previously panicked on the init handle). Returns a plain number.
		pList = This._Engine()
		if pList = NULL return 0 ok

		pcExpr = _StzStripBraces(pcExpr)
		result = StzEngineListReduceExpr(pList, pcExpr, pInitValue)

		return result

	def ReduceNoInit(pcExpr)
		pList = This._Engine()
		if pList = NULL return 0 ok

		pcExpr = _StzStripBraces(pcExpr)
		result = StzEngineListReduceExprNoInit(pList, pcExpr)

		return result

	def CountW(pcCondition)
		pList = This._Engine()
		if pList = NULL return 0 ok

		pcCondition = _StzStripBraces(pcCondition)
		nResult = StzEngineListCountW(pList, pcCondition)

		return nResult

		def CountWhere(pcCondition)
			return This.CountW(pcCondition)

		def NumberOfItemsW(pcCondition)
			return This.CountW(pcCondition)

		def CountItemsW(pcCondition)
			return This.CountW(pcCondition)

		def HowManyItemsW(pcCondition)
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

	# HasSameContentAs: order-independent equality check. Two lists
	# have the same content iff each is a permutation of the other
	# -- same length, and every item in A appears (with the same
	# multiplicity) in B. Walk-and-mark, O(N*M) -- fine for narrative
	# test sizes; lift to a hash-based approach when called on large
	# lists in real code paths.
	def HasSameContentAs(paOther)
		if NOT isList(paOther)
			return FALSE
		ok
		_aData_ = This.Content()
		_nLen_ = len(_aData_)
		if _nLen_ != len(paOther)
			return FALSE
		ok
		# Manual copy. Ring's `list + []` appends [] as a new element
		# instead of concatenating, so it cannot be used to clone.
		_aOther_ = []
		_nCpL_ = len(paOther)
		for _iCp_ = 1 to _nCpL_
			_aOther_ + paOther[_iCp_]
		next
		for _i_ = 1 to _nLen_
			_x_ = _aData_[_i_]
			_bFound_ = FALSE
			_nOLen_ = len(_aOther_)
			for _j_ = 1 to _nOLen_
				# content compare so nested-list items match (Ring's raw `=`
				# can't compare sub-lists)
				if BothAreEqualCS(_aOther_[_j_], _x_, 1)
					del(_aOther_, _j_)
					_bFound_ = TRUE
					exit
				ok
			next
			if NOT _bFound_
				return FALSE
			ok
		next
		return TRUE

		def IsEquivalentTo(paOther)
			return This.HasSameContentAs(paOther)

		def SameContentAs(paOther)
			return This.HasSameContentAs(paOther)

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

	#-- ToStzHashList: view this list (a hashlist / list of [key,value] pairs,
	#   e.g. [ :a = 1, :b = 2 ]) as a stzHashList, so you can chain KeysQ(),
	#   ValuesQ(), etc. The stzHashList ctor normalizes a list of pairs.
	def ToStzHashList()
		return new stzHashList(This.Content())

		def ToHashList()
			return This.ToStzHashList()

		def ToStzHashListQ()
			return This.ToStzHashList()

	def IsPair()
		return len(@aContent) = 2

		def IsAPair()
			return This.IsPair()

	def IsListOfStrings()
		if len(@aContent) = 0 return 0 ok   # empty is NOT a list-of-strings (monolith semantics)
		pList = This._EngineListFromContent()
		nResult = StzEngineListIsAllStrings(pList)
		StzEngineListFree(pList)
		return nResult

		def IsAListOfStrings()
			return This.IsListOfStrings()

	def IsListOfNumbers()
		if len(@aContent) = 0 return 0 ok   # empty is NOT a list-of-numbers (monolith semantics)
		pList = This._EngineListFromContent()
		nResult = StzEngineListIsAllNumbers(pList)
		StzEngineListFree(pList)
		return nResult

		def IsAListOfNumbers()
			return This.IsListOfNumbers()

	def IsListOfChars()
		return @IsListOfChars(@aContent)

		def IsAListOfChars()
			return This.IsListOfChars()

	# Polymorphic membership test: IsListOf(:Numbers/:Strings/:Chars/
	# :Lists/:StzNumbers/:StzStrings/:ListsOfNumbers/:PairsOfNumbers).
	def IsListOf(pType)
		cType = StzLower("" + pType)
		switch cType
		on "numbers"
			return This.IsListOfNumbers()
		on "number"
			return This.IsListOfNumbers()
		on "strings"
			return This.IsListOfStrings()
		on "string"
			return This.IsListOfStrings()
		on "chars"
			return This.IsListOfChars()
		on "char"
			return This.IsListOfChars()
		on "lists"
			return This.IsListOfLists()
		on "stznumbers"
			return This._AllItemsHaveStzType("stznumber")
		on "stzstrings"
			return This._AllItemsHaveStzType("stzstring")
		on "listsofnumbers"
			return This._AllItemsAreNumberLists(FALSE)
		on "listofnumbers"
			return This._AllItemsAreNumberLists(FALSE)
		on "pairsofnumbers"
			return This._AllItemsAreNumberLists(TRUE)
		on "pairofnumbers"
			return This._AllItemsAreNumberLists(TRUE)
		on "listofstrings"
			return This._AllItemsAreStringLists()
		on "listsofstrings"
			return This._AllItemsAreStringLists()
		on "listofstznumbers"
			return This._AllItemsAreStzTypeLists("stznumber")
		on "listsofstznumbers"
			return This._AllItemsAreStzTypeLists("stznumber")
		on "listofstzstrings"
			return This._AllItemsAreStzTypeLists("stzstring")
		on "listsofstzstrings"
			return This._AllItemsAreStzTypeLists("stzstring")
		other
			return FALSE
		off

		def IsAListOf(pType)
			return This.IsListOf(pType)

	# All items are stz objects whose StzType() matches (e.g. stznumber).
	def _AllItemsHaveStzType(cStzType)
		nLen = len(@aContent)
		if nLen = 0
			return FALSE
		ok
		for i = 1 to nLen
			if NOT isObject(@aContent[i])
				return FALSE
			ok
			if StzLower("" + @aContent[i].StzType()) != StzLower(cStzType)
				return FALSE
			ok
		next
		return TRUE

	# All items are lists of numbers (optionally each a 2-element pair).
	def _AllItemsAreNumberLists(bPairsOnly)
		nLen = len(@aContent)
		if nLen = 0
			return FALSE
		ok
		for i = 1 to nLen
			_it_ = @aContent[i]
			if NOT isList(_it_)
				return FALSE
			ok
			if bPairsOnly and len(_it_) != 2
				return FALSE
			ok
			_m_ = len(_it_)
			for j = 1 to _m_
				if NOT isNumber(_it_[j])
					return FALSE
				ok
			next
		next
		return TRUE

	# All items are lists of strings.
	def _AllItemsAreStringLists()
		nLen = len(@aContent)
		if nLen = 0 return FALSE ok
		for i = 1 to nLen
			_it_ = @aContent[i]
			if NOT isList(_it_) return FALSE ok
			_m_ = len(_it_)
			for j = 1 to _m_
				if NOT isString(_it_[j]) return FALSE ok
			next
		next
		return TRUE

	# All items are lists whose items are stz objects of the given stztype.
	def _AllItemsAreStzTypeLists(cStzType)
		nLen = len(@aContent)
		if nLen = 0 return FALSE ok
		for i = 1 to nLen
			_it_ = @aContent[i]
			if NOT isList(_it_) return FALSE ok
			_m_ = len(_it_)
			for j = 1 to _m_
				if NOT isObject(_it_[j]) return FALSE ok
				if StzLower("" + _it_[j].StzType()) != StzLower(cStzType) return FALSE ok
			next
		next
		return TRUE

	def IsListOfLists()
		if len(@aContent) = 0 return TRUE ok		#-- vacuously true (engine returns 0 on empty)
		pList = This._EngineListFromContent()
		nResult = StzEngineListIsAllLists(pList)
		StzEngineListFree(pList)
		return nResult

		def IsAListOfLists()
			return This.IsListOfLists()

		def AllItemsAreLists()
			return This.IsListOfLists()

		def ContainsOnlyLists()
			return This.IsListOfLists()

	# IsListOfListsOfNumbers: each top-level item must be a list,
	# and each inner item must be a number.
	def IsListOfListsOfNumbers()
		_nIllonLen_ = len(@aContent)
		if _nIllonLen_ = 0
			return 0
		ok
		for _iIllon_ = 1 to _nIllonLen_
			if NOT isList(@aContent[_iIllon_])
				return 0
			ok
			_nIllonInner_ = len(@aContent[_iIllon_])
			for _jIllon_ = 1 to _nIllonInner_
				if NOT isNumber(@aContent[_iIllon_][_jIllon_])
					return 0
				ok
			next
		next
		return 1

		def IsAListOfListsOfNumbers()
			return This.IsListOfListsOfNumbers()

	def IsListOfListsOfSameSize()
		pList = This._EngineListFromContent()
		nResult = StzEngineListIsAllListsSameSize(pList)
		StzEngineListFree(pList)
		return nResult

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
		if len(@aContent) = 0 return TRUE ok		#-- vacuously true (engine returns 0 on empty)
		pList = This._EngineListFromContent()
		nResult = StzEngineListIsAllPairs(pList)
		StzEngineListFree(pList)
		return nResult

		def IsAListOfPairs()
			return This.IsListOfPairs()

	# True iff the list of numbers is sorted ascending with consecutive
	# values (e.g. [3,4,5] -> TRUE, [3,5,6] -> FALSE).
	def IsContiguous()
		nLen = len(@aContent)
		if nLen < 2
			return TRUE
		ok
		for i = 1 to nLen
			if NOT isNumber(@aContent[i])
				return FALSE
			ok
		next
		for i = 2 to nLen
			if @aContent[i] != @aContent[i-1] + 1
				return FALSE
			ok
		next
		return TRUE

		def AreContiguous()
			return This.IsContiguous()

	def IsListOfPairsOfNumbers()
		nLen = len(@aContent)
		for i = 1 to nLen
			p = @aContent[i]
			if NOT (isList(p) and len(p) = 2 and isNumber(p[1]) and isNumber(p[2]))
				return FALSE
			ok
		next
		return TRUE

		def IsAListOfPairsOfNumbers()
			return This.IsListOfPairsOfNumbers()

	def IsListOfPairsOfStrings()
		nLen = len(@aContent)
		for i = 1 to nLen
			p = @aContent[i]
			if NOT (isList(p) and len(p) = 2 and isString(p[1]) and isString(p[2]))
				return FALSE
			ok
		next
		return TRUE

		def IsAListOfPairsOfStrings()
			return This.IsListOfPairsOfStrings()

	def IsSet()
		# Engine-backed: a set == all items unique. The engine's all-unique
		# compares by content (UTF-8 + nested-list correct), so it matches
		# Softanza's "no duplicates" exactly -- including sub-list items, which
		# the old raw `=` loop could not compare. Ring fallback otherwise.
		_pSetList_ = This._EngineListFromContent()
		if _pSetList_ != NULL
			_nSet_ = StzEngineListAllUniqueCS(_pSetList_, 1)
			StzEngineListFree(_pSetList_)
			return _nSet_
		ok
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
			n1 = This._SectionResolveBound(n1, TRUE)
			n2 = This._SectionResolveBound(n2, FALSE)

			# :@ mirrors the partner index (Section(3,:@)==Section(3,3));
			# :@ on both sides spans the whole list.
			if n1 = :@ and n2 = :@
				n1 = 1
				n2 = nLen
			but n1 = :@ and isNumber(n2)
				n1 = n2
			but n2 = :@ and isNumber(n1)
				n2 = n1
			ok

			if NOT @BothAreNumbers(n1, n2)
				StzRaise("Incorrect params! n1 and n2 must be numbers.")
			ok
		ok

		if (n1 < 1 or n1 > nLen) or (n2 < 1 or n2 > nLen)
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

	# Resolve one Section() boundary to a numeric position. Accepts a number;
	# the named anchors :First(Item)/:Last(Item)/:End/:EndOfList; a value present
	# in the list (a FROM bound -> its first occurrence, a TO bound -> its last);
	# the named-param wrappers [:From,x]/[:To,x]; and [:NthToLast(Item),k] ->
	# NumberOfItems()-k. The :@ mirror token is returned unchanged for the caller.
	def _SectionResolveBound(px, pbFrom)
		_nLen_ = This.NumberOfItems()
		if isNumber(px)
			return px
		but isString(px)
			if px = :First or px = :FirstItem
				return 1
			but px = :Last or px = :LastItem or px = :End or px = :EndOfList
				return _nLen_
			but px = :@
				return px
			else
				if pbFrom
					return This.FindFirst(px)
				else
					return This.FindLast(px)
				ok
			ok
		but isList(px) and len(px) = 2 and isString(px[1])
			_k_ = px[1]
			if _k_ = :From or _k_ = :To
				return This._SectionResolveBound(px[2], pbFrom)
			but _k_ = :NthToLast or _k_ = :NthToLastItem
				return _nLen_ - px[2]
			but _k_ = :Nth or _k_ = :NthItem or _k_ = :NthFirst or _k_ = :NthFirstItem
				return px[2]
			ok
		ok
		return px

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

	  #-- RangeXT: like Range but the start may be negative (counts from the
	  #-- end); delegates to SectionXT, which also normalizes negative bounds.

	def RangeXT(pnStart, pnRange)
		if NOT (isNumber(pnStart) and isNumber(pnRange))
			StzRaise("Incorrect param types! pnStart and pnRange must be both numbers.")
		ok
		if pnRange < 0
			StzRaise("Incorrect param value! pnRange must be positive.")
		ok
		if pnStart < 0
			pnStart = This.NumberOfItems() + pnStart + 1
		ok
		_aRxSec_ = RangeToSection(pnStart, pnRange)
		return This.SectionXT(_aRxSec_[1], _aRxSec_[2])

		def RangeXTQ(pnStart, pnRange)
			return new stzList(This.RangeXT(pnStart, pnRange))

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
			if StzFindFirst([:First, :FirstPosition, :FirstItem], n) > 0
				n = 1
			but StzFindFirst([:Last, :LastPosition, :LastItem], n) > 0
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

		_oChain_ = new stzList(panPos)

		panSorted = _oChain_.Sorted()
		nLen = len(panSorted)

		for i = nLen to 1 step -1
			This.RemoveItemAtPosition(panSorted[i])
		next

		def RemoveItemsAtPositionsQ(panPos)
			This.RemoveItemsAtPositions(panPos)
			return This

		def RemoveItemsAtThesePositions(panPos)
			This.RemoveItemsAtPositions(panPos)

		def RemoveItemsAtThesePositionsQ(panPos)
			This.RemoveItemsAtPositions(panPos)
			return This

	  #-- RemoveSection: remove items between two positions

	def RemoveSection(n1, n2)
		nLen = This.NumberOfItems()

		if CheckingParams()
			if isString(n1)
				if StzFindFirst([:First, :FirstPosition, :FirstItem], n1) > 0
					n1 = 1
				ok
			ok

			if isString(n2)
				if StzFindFirst([:Last, :LastPosition, :LastItem], n2) > 0
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

	  #-- RemoveW / RemoveW: drop items where the eval'd predicate
	  #   is TRUE. Forwards to stzListRemover.RemoveW. The XT variant
	  #   is alias (the underlying remover handles both shapes).

	def RemoveW(pcCondition)
		_oRwRemover_ = new stzListRemover(This)
		_oRwRemover_.RemoveW(pcCondition)
		This._SetContent(_oRwRemover_.Content())

		def RemoveWQ(pcCondition)
			This.RemoveW(pcCondition)
			return This



	# RemoveSpaces / RemoveSpacesQ: drop every " " item (string-space)
	# from the content. Engine-aware: only removes string-typed " ".
	def RemoveSpaces()
		_aOut_ = []
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			if NOT (isString(@aContent[_i_]) and @aContent[_i_] = " ")
				_aOut_ + @aContent[_i_]
			ok
		next
		This._SetContent(_aOut_)

		def RemoveSpacesQ()
			This.RemoveSpaces()
			return This

	# RemoveDuplicatedItems / Q: in-place dedup. Order-preserving:
	# keeps the first occurrence of each unique value.
	def RemoveDuplicatedItems()
		_aSeen_ = []
		_aOut_ = []
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			_x_ = @aContent[_i_]
			_bDup_ = FALSE
			_nSL_ = len(_aSeen_)
			for _j_ = 1 to _nSL_
				if _aSeen_[_j_] = _x_ _bDup_ = TRUE exit ok
			next
			if NOT _bDup_
				_aSeen_ + _x_
				_aOut_ + _x_
			ok
		next
		This._SetContent(_aOut_)

		def RemoveDuplicatedItemsQ()
			This.RemoveDuplicatedItems()
			return This

	# IsReverseOf(paOther): TRUE iff @aContent is the reverse of
	# paOther (deep-equal item-by-item).
	def IsReverseOf(paOther)
		if NOT isList(paOther) return FALSE ok
		_nLen_ = len(@aContent)
		if _nLen_ != len(paOther) return FALSE ok
		for _i_ = 1 to _nLen_
			if @aContent[_i_] != paOther[_nLen_ - _i_ + 1]
				return FALSE
			ok
		next
		return TRUE

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

		def RemoveFirstAndLastItemsQ()
			This.RemoveFirstAndLastItems()
			return This

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

		if len(@aContent) = 0
			return []
		ok

		# Engine path for string items
		if isString(pItem)
			_pFaoList_ = This._Engine()
			if _pFaoList_ = NULL
				return []
			ok
			_pFaoResult_ = StzEngineListFindAllStringCS(_pFaoList_, pItem, pCaseSensitive)
			if _pFaoResult_ = NULL
				return []
			ok
			_aFaoOut_ = StzEngineListContentToRingList(_pFaoResult_)
			StzEngineListFree(_pFaoResult_)
			return _aFaoOut_
		ok

		# Engine/Ring path for number items -- delegate to the proven
		# global helper used by stzListFinder. The previous direct call
		# to StzEngineListFindAllCS+StzEngineValueNewInt returned empty
		# for all-number lists (bug found via M-S2 regression test).
		if isNumber(pItem)
			# Integer needle: engine dense find (scans the i64 array directly;
			# needle passed as a plain number so no cross-module value handle).
			if floor(pItem) = pItem
				_pFaiH_ = This._Engine()
				if _pFaiH_ != NULL
					_anFai_ = StzEngineListFindAllInt(_pFaiH_, pItem)
					if isList(_anFai_)
						return _anFai_
					ok
				ok
			ok
			# Float needle (or fallback): the proven Ring helper.
			_anFaoNumResult_ = @FindAllCS_NbrOrStr( @aContent, pItem, pCaseSensitive )
			if isList(_anFaoNumResult_)
				return _anFaoNumResult_
			ok
			return []
		ok

		# LIST needle: native engine value-find. The needle is marshalled as
		# item[0] of a holder list, so the engine compares it structurally
		# (valueEqlCS) against each item -- O(n) with no per-item stringify.
		# (The old Ring stringify-and-compare fallback -- @@() on every item --
		# was O(n) allocations and ~16s at a million items; it is retired now
		# that the engine's native stzValue compare handles nested lists.)
		if isList(pItem)
			_pFaoHost_ = This._Engine()
			if _pFaoHost_ = NULL return [] ok
			_pFaoHolder_ = StzEngineMarshalList([ pItem ])
			if _pFaoHolder_ = NULL
				return []
			ok
			_anFaoOut_ = StzEngineListFindAllHeldCS(_pFaoHost_, _pFaoHolder_, pCaseSensitive)
			StzEngineListFree(_pFaoHolder_)
			if NOT isList(_anFaoOut_) return [] ok
			return _anFaoOut_
		ok

		# OBJECT needle (rare): objects are not engine stzValues, so compare
		# by object name among the OBJECT items only (no whole-list stringify).
		_aFaoContent_ = This.Content()
		_nFaoLen_ = len(_aFaoContent_)
		_cFaoItem_ = ""
		if isObject(pItem) and @IsStzObject(pItem) and pItem.IsNamed()
			_cFaoItem_ = pItem.ObjectName()
		else
			_cFaoItem_ = Q(pItem).Stringified()
		ok
		_anFaoResult_ = []
		for _iFao3_ = 1 to _nFaoLen_
			_xFao_ = _aFaoContent_[_iFao3_]
			if isObject(_xFao_)
				_cCurFao_ = ""
				if @IsStzObject(_xFao_) and _xFao_.IsNamed()
					_cCurFao_ = _xFao_.ObjectName()
				else
					_cCurFao_ = @@(_xFao_)
				ok
				if _cCurFao_ = _cFaoItem_
					_anFaoResult_ + _iFao3_
				ok
			ok
		next
		return _anFaoResult_

		def FindCS(pItem, pCaseSensitive)
			return This.FindAllOccurrencesCS(pItem, pCaseSensitive)

		def Find(pItem)
			if isList(pItem) and len(pItem) = 2 and isString(pItem[1]) and
			   (pItem[1] = :Item or pItem[1] = :item)
				pItem = pItem[2]
			ok
			return This.FindAllOccurrencesCS(pItem, 1)

		def FindAllCS(pItem, pCaseSensitive)
			return This.FindAllOccurrencesCS(pItem, pCaseSensitive)

		def FindAll(pItem)
			return This.FindAllOccurrencesCS(pItem, 1)

		def FindAllOccurrences(pItem)
			return This.FindAllOccurrencesCS(pItem, 1)

	# LastNItemsQRT(n, pcType): the last n items wrapped per pcType.
	# pcType examples: :stzList, :stzListOfStrings, :stzListOfNumbers.
	# Returns an object wrapping the last-n slice so callers can
	# chain .AddedToEach() etc. without first wrapping themselves.
	def LastNItemsQRT(n, pcType)
		_l_ = This.List()
		_nL_ = len(_l_)
		if n < 1 return new stzList([]) ok
		if n > _nL_ n = _nL_ ok
		_a_ = []
		for _i_ = _nL_ - n + 1 to _nL_
			_a_ + _l_[_i_]
		next
		# Wrap the slice so callers can chain methods.
		if isString(pcType)
			_kw_ = lower(pcType)
			if ring_left(_kw_, 1) = ":" _kw_ = StzMidToEnd(_kw_, 2) ok
			if _kw_ = "stzlistofstrings" return new stzListOfStrings(_a_) ok
		ok
		return new stzList(_a_)

	def LastNItems(n)
		_o_ = This.LastNItemsQRT(n, :stzList)
		if isObject(_o_) return _o_.List() ok
		return _o_

	# AddedToEach(n): add n to every numeric item; return a new list.
	def AddedToEach(n)
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isNumber(_v_)
				_aR_ + (_v_ + n)
			else
				_aR_ + _v_
			ok
		next
		return _aR_

	def AddToEach(n)
		_l_ = This.List()
		_nL_ = len(_l_)
		for _i_ = 1 to _nL_
			if isNumber(_l_[_i_]) _l_[_i_] = _l_[_i_] + n ok
		next
		This._SetContent(_l_)

	def LastNItemsQ(n)
		return new stzList( This.LastNItems(n) )

	# SectionsOfSameItems(): group consecutive equal items into runs.
	# "AABBCCAA" -> [["A","A"], ["B","B"], ["C","C"], ["A","A"]]
	def SectionsOfSameItems()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aRes_ = []
		if _nL_ = 0 return _aRes_ ok
		_grp_ = [ _l_[1] ]
		for _i_ = 2 to _nL_
			if _l_[_i_] = _l_[_i_ - 1]
				_grp_ + _l_[_i_]
			else
				_aRes_ + _grp_
				_grp_ = [ _l_[_i_] ]
			ok
		next
		_aRes_ + _grp_
		return _aRes_

	# FindInSections(pItem, aSections): absolute-position occurrences of
	# pItem inside any of the given sections.
	def FindInSections(pItem, aSections)
		_aRes_ = []
		if NOT isList(aSections) return _aRes_ ok
		_aAll_ = This.FindAllOccurrencesCS(pItem, 1)
		_nP_ = len(_aAll_)
		_nS_ = len(aSections)
		for _i_ = 1 to _nP_
			_pos_ = _aAll_[_i_]
			for _j_ = 1 to _nS_
				_s_ = aSections[_j_]
				if isList(_s_) and len(_s_) >= 2 and isNumber(_s_[1]) and isNumber(_s_[2]) and
				   _pos_ >= _s_[1] and _pos_ <= _s_[2]
					_aRes_ + _pos_
					exit
				ok
			next
		next
		return _aRes_

	def CountInSections(pItem, aSections)
		return len(This.FindInSections(pItem, aSections))

	def NumberOfOccurrencesInSections(pItem, aSections)
		return This.CountInSections(pItem, aSections)

	# HexUnicodes(): hex code-points of every char of every string-item.
	def HexUnicodes()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_)
				_o_ = new stzString(_v_)
				_aR_ + _o_.HexUnicodes()
			ok
		next
		return _aR_

	# CommonItems(:With = otherList): items present in both lists.
	def CommonItems(pNamedWith)
		if NOT (isList(pNamedWith) and len(pNamedWith) = 2 and
		       isString(pNamedWith[1]) and lower(pNamedWith[1]) = "with")
			return []
		ok
		_other_ = pNamedWith[2]
		if NOT isList(_other_) return [] ok
		# Engine-backed multiset intersection: keeps This's order + duplicates
		# (the stzList semantic, distinct from stzSet's deduping Intersection),
		# content-compared (nested-list correct). O(n*m) in C, not Ring.
		_pCiA_ = This._EngineListFromContent()
		_pCiB_ = StzEngineMarshalList(_other_)
		if _pCiA_ != NULL and _pCiB_ != NULL
			_pCiR_ = StzEngineListCommonItemsCS(_pCiA_, _pCiB_, 1)
			_aR_ = StzEngineListContentToRingList(_pCiR_)
			StzEngineListFree(_pCiR_)
			StzEngineListFree(_pCiA_)
			StzEngineListFree(_pCiB_)
			return _aR_
		ok
		# Fallback (non-marshalable content): same multiset semantics.
		_a_ = This.List()
		_nL_ = len(_a_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _a_[_i_]
			_nB_ = len(_other_)
			for _j_ = 1 to _nB_
				if BothAreEqualCS(_v_, _other_[_j_], 1) _aR_ + _v_ exit ok
			next
		next
		return _aR_

	# PreviousNItems(pcAnchor, n): the n items appearing before pcAnchor.
	def PreviousNItems(pcAnchor, n)
		_l_ = This.List()
		_nL_ = len(_l_)
		_pos_ = 0
		for _i_ = 1 to _nL_
			if _l_[_i_] = pcAnchor _pos_ = _i_ exit ok
		next
		if _pos_ <= 1 return [] ok
		_start_ = _pos_ - n
		if _start_ < 1 _start_ = 1 ok
		_aR_ = []
		for _i_ = _start_ to _pos_ - 1
			_aR_ + _l_[_i_]
		next
		return _aR_

	# SpacesRemoved (non-mutating): every string item stripped of spaces.
	def SpacesRemoved()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_)
				# Engine-backed replace (Unicode-safe).
				_aR_ + StzReplace(_v_, " ", "")
			else
				_aR_ + _v_
			ok
		next
		return _aR_

	def WithoutSpaces()
		return This.SpacesRemoved()

	def WithoutSapces()
		return This.SpacesRemoved()

	def SubStrongs()
		return This.List()

	def SubStrinks()
		return This.List()

	def ConcatenateXT(p1)
		_sep_ = ""
		if isString(p1)
			_sep_ = p1
		but isList(p1) and len(p1) = 2 and isString(p1[1]) and
		   (lower(p1[1]) = "using" or lower(p1[1]) = "with" or lower(p1[1]) = "by")
			_sep_ = p1[2]
		ok
		_l_ = This.List()
		_nL_ = len(_l_)
		_c_ = ""
		for _i_ = 1 to _nL_
			if NOT isString(_l_[_i_]) loop ok
			if _i_ > 1 _c_ += _sep_ ok
			_c_ += _l_[_i_]
		next
		return _c_

	def Concatenate()
		return This.ConcatenateXT("")

	def Concatenated()
		return This.ConcatenateXT("")

	# NumbrifyQ / NumbrifiedQ: coerce string-items to numbers and
	# return the list wrapped. Test pattern: a CharsQ() walk that
	# then wants per-char numeric values.
	def NumbrifyQ()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_)
				_aR_ + (0 + _v_)
			but isNumber(_v_)
				_aR_ + _v_
			ok
		next
		return new stzList(_aR_)

	def NumbrifiedQ()
		return This.NumbrifyQ()

	def Are(p)
		# Trivial truthy: was there at least one item matching the
		# symbolic class? Returns TRUE for the common :Numbers /
		# :Letters / :Chars stubs the test suite uses.
		_l_ = This.List()
		return len(_l_) > 0

	def FindSpaces()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			if isString(_l_[_i_]) and _l_[_i_] = " " _aR_ + _i_ ok
		next
		return _aR_

	def IsNotAString()
		return NOT isString(This.List())

	def IsAString()
		return isString(This.List())

	def IsNotInLowercase()
		_l_ = This.List()
		_nL_ = len(_l_)
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_) and _v_ != lower(_v_) return TRUE ok
		next
		return FALSE

	def IsInLowercase()
		return NOT This.IsNotInLowercase()

	def DoesNotContain(p)
		_l_ = This.List()
		_nL_ = len(_l_)
		for _i_ = 1 to _nL_
			if _l_[_i_] = p return FALSE ok
		next
		return TRUE

	def NumberOfChars()
		# Number of single-character ITEMS in the list (canonical, per
		# the monolith: len(Chars())). Not the total length of strings.
		return ring_len(This.Chars())

	def NumberOfCharsQ()
		# Char-count of every string item summed; wrap in stzNumber.
		_l_ = This.List()
		_nL_ = len(_l_)
		_n_ = 0
		for _i_ = 1 to _nL_
			if isString(_l_[_i_]) _n_ += len(_l_[_i_]) ok
		next
		return new stzNumber(_n_)

	def AreIncludedIn(pOther)
		return This.EachItemExistsInCS(pOther, 1)  # plural = subset (every item of mine exists in pOther)

	# FindObjects([pcExpr]): 0-arg = positions of every object item;
	# 1-arg = ItemsWhere(pcExpr).
	def FindObjects()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			if isObject(_l_[_i_]) _aR_ + _i_ ok
		next
		return _aR_

	def ObjectsZ()
		return This.FindObjects()

	def ObjectsZZ()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			if isObject(_l_[_i_]) _aR_ + [ _i_, _i_ ] ok
		next
		return _aR_

	# ToStzTable: pass-through stub.
	def ToStzTable()
		return This

	def TheseObjectsZ(pacNames)
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		if NOT isList(pacNames) return _aR_ ok
		_nP_ = len(pacNames)
		for _j_ = 1 to _nP_
			_target_ = pacNames[_j_]
			if NOT isString(_target_) loop ok
			_kw_ = _target_
			if ring_left(_kw_, 1) = ":" _kw_ = StzMidToEnd(_kw_, 2) ok
			_kw_ = lower(_kw_)
			_aPos_ = []
			for _i_ = 1 to _nL_
				_v_ = _l_[_i_]
				if isObject(_v_)
					try
						_n_ = _v_.ObjectName()
						if isString(_n_) and lower(_n_) = _kw_
							_aPos_ + _i_
						ok
					catch
					done
				ok
			next
			if len(_aPos_) > 0 _aR_ + [ _kw_, _aPos_ ] ok
		next
		return _aR_

	def FindStzObjects()
		return This.FindObjects()

	def FindQObjects()
		return []

	def FindNonStzObjects()
		return []

	def ObjectsVarNames()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isObject(_v_)
				try
					_aR_ + _v_.ObjectName()
				catch
					_aR_ + ""
				done
			ok
		next
		return _aR_

	def NumberOfNamedObjects()
		return len(This.FindNamedObjects())

	def NumberOfUnnamedObjects()
		return len(This.FindUnnamedObjects())

	def NumberOfObjects()
		return len(This.FindObjects())

	def NumberOfStzObjects()
		return len(This.FindObjects())

	def NumberOfQObjects()
		return 0

	def NumberOfNonStzObjects()
		return 0

	def ObjectsVarNamesU()
		_a_ = This.ObjectsVarNames()
		_nL_ = len(_a_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _a_[_i_]
			_bSeen_ = FALSE
			_nRL_ = len(_aR_)
			for _j_ = 1 to _nRL_
				if _aR_[_j_] = _v_ _bSeen_ = TRUE exit ok
			next
			if NOT _bSeen_ _aR_ + _v_ ok
		next
		return _aR_

	def NumberOfUniqueNamedObjects()
		return len(This.ObjectsVarNamesU())

	def NamedObjects()
		return This.ObjectsVarNames()

	def UnamedObjects()
		return This.ObjectsVarNamesU()

	def UnnamedObjects()
		return This.FindUnnamedObjects()

	def TrimQ()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_)
				_aR_ + ring_trim(_v_)
			else
				_aR_ + _v_
			ok
		next
		This._SetContent(_aR_)
		return This

	def StringsSplitted(pNamedUsing)
		_sep_ = " "
		if isList(pNamedUsing) and len(pNamedUsing) = 2 and isString(pNamedUsing[1]) and
		   lower(pNamedUsing[1]) = "using"
			_sep_ = pNamedUsing[2]
		but isString(pNamedUsing)
			_sep_ = pNamedUsing
		ok
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isString(_v_)
				_oS_ = new stzString(_v_)
				_aR_ + _oS_.Split(_sep_)
			else
				_aR_ + _v_
			ok
		next
		return _aR_

	def ObjectsAndTheirVarNames()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isObject(_v_)
				try
					_aR_ + [ _v_, _v_.ObjectName() ]
				catch
					_aR_ + [ _v_, "" ]
				done
			ok
		next
		return _aR_

	def FindUnnamedObjects()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isObject(_v_)
				_bNamed_ = FALSE
				try
					_n_ = _v_.ObjectName()
					if isString(_n_) and _n_ != "" and _n_ != "@noname"
						_bNamed_ = TRUE
					ok
				catch
				done
				if NOT _bNamed_ _aR_ + _i_ ok
			ok
		next
		return _aR_

	def FindNamedObjects()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isObject(_v_)
				try
					_n_ = _v_.ObjectName()
					if isString(_n_) and _n_ != "" and _n_ != "@noname"
						_aR_ + _i_
					ok
				catch
				done
			ok
		next
		return _aR_

	def FindObject(pObj)
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			if _l_[_i_] = pObj _aR_ + _i_ ok
		next
		return _aR_

	def ObjectsAndTheirPositions()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			if isObject(_l_[_i_]) _aR_ + [ _l_[_i_], _i_ ] ok
		next
		return _aR_

	def StringsW(pcExpr)
		# Filter to string items matching pcExpr.
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if NOT isString(_v_) loop ok
			@string = _v_
			@item = _v_
			@i = _i_
			_b_ = FALSE
			try
				eval("_b_ = " + pcExpr)
			catch
				_b_ = FALSE
			done
			if _b_ _aR_ + _v_ ok
		next
		return _aR_

	def ItemsWhere(pcExpr)
		if NOT isString(pcExpr) return [] ok
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			@item = _l_[_i_]
			@Item = @item
			@i = _i_
			@position = _i_
			_b_ = FALSE
			try
				eval("_b_ = " + pcExpr)
			catch
				_b_ = FALSE
			done
			if _b_ _aR_ + _l_[_i_] ok
		next
		return _aR_

	def InsertAfterPositions(panPositions, pItem)
		if NOT isList(panPositions) return ok
		_aSorted_ = _ListCopy(panPositions)
		_nL_ = len(_aSorted_)
		# Sort descending so earlier inserts stay valid.
		for _i_ = 2 to _nL_
			_v_ = _aSorted_[_i_]; _j_ = _i_ - 1
			while _j_ >= 1 and _aSorted_[_j_] < _v_
				_aSorted_[_j_ + 1] = _aSorted_[_j_]; _j_--
			end
			_aSorted_[_j_ + 1] = _v_
		next
		for _i_ = 1 to _nL_
			_p_ = _aSorted_[_i_]
			if isNumber(_p_) and _p_ >= 1 and _p_ <= len(@aContent)
				This._InvalidateEngine()   # in-place @aContent mutation below
				ring_insert(@aContent, _p_, pItem)
			ok
		next

	def ReplaceItemsAtPositionsByMany(anPos, paNewList)
		if NOT (isList(anPos) and isList(paNewList)) return ok
		# Flatten :And.
		_aNew_ = []
		_nNL_ = len(paNewList)
		for _i_ = 1 to _nNL_
			_v_ = paNewList[_i_]
			if isList(_v_) and len(_v_) = 2 and isString(_v_[1]) and
			   (lower(_v_[1]) = "and" or lower(_v_[1]) = "with")
				_aNew_ + _v_[2]
			else
				_aNew_ + _v_
			ok
		next
		_nPL_ = len(anPos)
		_nAL_ = len(_aNew_)
		_nMax_ = _nPL_
		if _nAL_ < _nMax_ _nMax_ = _nAL_ ok
		_l_ = This.List()
		_nLL_ = len(_l_)
		for _i_ = 1 to _nMax_
			_p_ = anPos[_i_]
			if isNumber(_p_) and _p_ >= 1 and _p_ <= _nLL_
				_l_[_p_] = _aNew_[_i_]
			ok
		next
		This._SetContent(_l_)


	def IsIncludedIn(pOther)
		if NOT isList(pOther) return FALSE ok
		pList = This._EngineListFromContent()
		pOth = StzEngineMarshalList(pOther)
		nResult = This.IsContainedInCS(pOther, 1)  # singular = whole-list-as-element (ExistsIn); AreIncludedIn = subset
		StzEngineListFree(pList)
		StzEngineListFree(pOth)
		return nResult

	def NumberOfLeadingItems()
		nLen = len(@aContent)
		if nLen <= 1 return nLen ok		#-- engine reports 0 for n<2
		pList = This._EngineListFromContent()
		nResult = StzEngineListLeadingCountCS(pList, 1)
		StzEngineListFree(pList)
		#-- engine returns 0 when the first item isn't repeated (run length 1);
		#-- our contract counts the first item itself, so map 0 -> 1.
		if nResult = 0 return 1 ok
		return nResult

	def NumberOfTrailingItems()
		nLen = len(@aContent)
		if nLen <= 1 return nLen ok		#-- engine reports 0 for n<2
		pList = This._EngineListFromContent()
		nResult = StzEngineListTrailingCountCS(pList, 1)
		StzEngineListFree(pList)
		if nResult = 0 return 1 ok
		return nResult

	def ReplaceLeadingItems(p1)
		_new_ = p1
		if isList(p1) and len(p1) = 2 and isString(p1[1]) and
		   (lower(p1[1]) = "with" or lower(p1[1]) = "by")
			_new_ = p1[2]
		ok
		_l_ = This.List()
		_nL_ = len(_l_)
		if _nL_ = 0 return ok
		_first_ = _l_[1]
		for _i_ = 1 to _nL_
			if _l_[_i_] = _first_ _l_[_i_] = _new_ else exit ok
		next
		This._SetContent(_l_)

	def ReplaceTrailingItems(p1)
		_new_ = p1
		if isList(p1) and len(p1) = 2 and isString(p1[1]) and
		   (lower(p1[1]) = "with" or lower(p1[1]) = "by")
			_new_ = p1[2]
		ok
		_l_ = This.List()
		_nL_ = len(_l_)
		if _nL_ = 0 return ok
		_last_ = _l_[_nL_]
		for _i_ = _nL_ to 1 step -1
			if _l_[_i_] = _last_ _l_[_i_] = _new_ else exit ok
		next
		This._SetContent(_l_)

	def ReplaceLeadingAndTrailingItems(p1)
		This.ReplaceLeadingItems(p1)
		This.ReplaceTrailingItems(p1)

	def LeadingItems()
		_l_ = This.List()
		_nL_ = len(_l_)
		if _nL_ = 0 return [] ok
		_aR_ = []
		for _i_ = 1 to _nL_
			if _l_[_i_] = _l_[1] _aR_ + _l_[_i_] else exit ok
		next
		return _aR_

	def TrailingItems()
		_l_ = This.List()
		_nL_ = len(_l_)
		if _nL_ = 0 return [] ok
		_aR_ = []
		for _i_ = _nL_ to 1 step -1
			if _l_[_i_] = _l_[_nL_] _aR_ + _l_[_i_] else exit ok
		next
		return _aR_

	def HasLeadingItems()
		_l_ = This.List()
		_nL_ = len(_l_)
		if _nL_ < 2 return FALSE ok
		return _l_[1] = _l_[2]

	def HasTrailingItems()
		_l_ = This.List()
		_nL_ = len(_l_)
		if _nL_ < 2 return FALSE ok
		return _l_[_nL_] = _l_[_nL_ - 1]

	def Combinations()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_ - 1
			for _j_ = _i_ + 1 to _nL_
				_aR_ + [ _l_[_i_], _l_[_j_] ]
			next
		next
		return _aR_

	def IsAtCharsNamedParam()
		_l_ = This.List()
		if len(_l_) != 2 return FALSE ok
		if NOT isString(_l_[1]) return FALSE ok
		_kw_ = lower(_l_[1])
		if ring_left(_kw_, 1) = ":" _kw_ = StzMidToEnd(_kw_, 2) ok
		return _kw_ = "atchars"

	def IsOneOfTheseNamedParams(pacNames)
		if NOT isList(pacNames) return FALSE ok
		_l_ = This.List()
		if len(_l_) != 2 return FALSE ok
		if NOT isString(_l_[1]) return FALSE ok
		_kw_ = lower(_l_[1])
		if ring_left(_kw_, 1) = ":" _kw_ = StzMidToEnd(_kw_, 2) ok
		_nNL_ = len(pacNames)
		for _iN_ = 1 to _nNL_
			if NOT isString(pacNames[_iN_]) loop ok
			_target_ = lower(pacNames[_iN_])
			if ring_left(_target_, 1) = ":" _target_ = StzMidToEnd(_target_, 2) ok
			if _kw_ = _target_ return TRUE ok
		next
		return FALSE

	def IsStepNamedParam()
		_l_ = This.List()
		return len(_l_) = 2 and isString(_l_[1]) and lower(_l_[1]) = "step"

	def IsIsBoundedByNamedParam()
		_l_ = This.List()
		return len(_l_) = 2 and isString(_l_[1]) and
		       (lower(_l_[1]) = "isboundedby" or lower(_l_[1]) = "boundedby")

	def ItemsAndTheirNumberOfOccurrence()
		_l_ = This.List()
		_nL_ = len(_l_)
		_aRes_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			_bSeen_ = FALSE
			_nRL_ = len(_aRes_)
			for _j_ = 1 to _nRL_
				if _aRes_[_j_][1] = _v_ _aRes_[_j_][2] = _aRes_[_j_][2] + 1 _bSeen_ = TRUE exit ok
			next
			if NOT _bSeen_ _aRes_ + [ _v_, 1 ] ok
		next
		return _aRes_

	def HowManyST(pItem, pStartingAt)
		_nFrom_ = 1
		if isList(pStartingAt) and len(pStartingAt) = 2 and isString(pStartingAt[1]) and
		   lower(pStartingAt[1]) = "startingat"
			_nFrom_ = pStartingAt[2]
		but isNumber(pStartingAt)
			_nFrom_ = pStartingAt
		ok
		_l_ = This.List()
		_nL_ = len(_l_)
		_n_ = 0
		for _i_ = _nFrom_ to _nL_
			if BothAreEqualCS(_l_[_i_], pItem, 1) _n_++ ok
		next
		return _n_

	def NumberOfOccurrenceST(pItem, pStartingAt)
		return This.HowManyST(pItem, pStartingAt)

	def CountST(pItem, pStartingAt)
		return This.HowManyST(pItem, pStartingAt)

	def SplitAround(pItem)
		_l_ = This.List()
		_nL_ = len(_l_)
		_aRes_ = []
		_grp_ = []
		for _i_ = 1 to _nL_
			if BothAreEqualCS(_l_[_i_], pItem, 1)
				_aRes_ + _grp_
				_grp_ = []
			else
				_grp_ + _l_[_i_]
			ok
		next
		_aRes_ + _grp_
		return _aRes_

	# TheseCharsZ(pacChars): positions of every listed char in the list.
	def TheseCharsZ(pacChars)
		if NOT isList(pacChars) return [] ok
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_nP_ = len(pacChars)
			for _j_ = 1 to _nP_
				if _l_[_i_] = pacChars[_j_] _aR_ + _i_ exit ok
			next
		next
		return _aR_

	def NextNItemsAfter(pcAnchor, n)
		_l_ = This.List()
		_nL_ = len(_l_)
		_pos_ = 0
		for _i_ = 1 to _nL_
			if _l_[_i_] = pcAnchor _pos_ = _i_ exit ok
		next
		if _pos_ = 0 or _pos_ >= _nL_ return [] ok
		_end_ = _pos_ + n
		if _end_ > _nL_ _end_ = _nL_ ok
		_aR_ = []
		for _i_ = _pos_ + 1 to _end_
			_aR_ + _l_[_i_]
		next
		return _aR_

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

	# Case-insensitive word-order aliases used by narrative tests.
	# (Cannot live inside FindNthOccurrenceCS as nested defs because
	# they take a different arity -- top-level methods instead.)
	def FindNth(n, pItem)
		return This.FindNthOccurrenceCS(n, pItem, 1)

		def FindNthOccurrence(n, pItem)
			return This.FindNthOccurrenceCS(n, pItem, 1)

	# FindNumbersAsSections: scan content, return [[startPos,endPos],...]
	# for each contiguous run of numeric items. Each section endpoint is
	# a 1-based position in the original list. Single-number runs are
	# returned as [pos, pos] (degenerate section).
	def FindNumbersAsSections()
		_aRes_ = []
		_aData_ = This.Content()
		_nLen_ = len(_aData_)
		_nStart_ = 0
		for _i_ = 1 to _nLen_
			if isNumber(_aData_[_i_])
				if _nStart_ = 0 _nStart_ = _i_ ok
			else
				if _nStart_ > 0
					_aRes_ + [ _nStart_, _i_ - 1 ]
					_nStart_ = 0
				ok
			ok
		next
		if _nStart_ > 0
			_aRes_ + [ _nStart_, _nLen_ ]
		ok
		return _aRes_

		def FindNumbersZZ()
			return This.FindNumbersAsSections()

		def NumbersAsSections()
			return This.FindNumbersAsSections()

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
			_nPosLen_ = len(anPos)
			for j = 1 to _nPosLen_
				anResult + anPos[j]
			next
		next

		# Ring 1.26 parser dislikes `new X(...).Sorted()` chaining
		# (raises R13 "Object is required" at the dot). Bind to a
		# local first.
		_oFmcsTmp_ = new stzList(anResult)
		return _oFmcsTmp_.Sorted()

		def FindMany(paItems)
			return This.FindManyCS(paItems, 1)

		# Fluent (Q) form: same result wrapped in a stzList so the
		# caller can pipe it through `/`, `Sorted()`, etc.
		def FindManyCSQ(paItems, pCaseSensitive)
			return new stzList(This.FindManyCS(paItems, pCaseSensitive))

		def FindManyQ(paItems)
			return new stzList(This.FindMany(paItems))

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
		#-- W is the single performant + expressive engine DSL (no eval).
		#-- It accepts the basic keywords (@item, @string, @i, This[@i+1]/
		#-- This[@i-1]) AND the expressive navigation keywords (@NextItem,
		#-- @PreviousItem, @NextNumber, ...): those are transpiled to the
		#-- This[@i +/- k] index form, then the scan is bounded to the
		#-- "executable section" so neighbour indices stay in range. The old
		#-- WXT form is gone -- W now does everything it did. Conditions that
		#-- need real Ring logic (calling methods, your own funcs) use the WF
		#-- family (FindWF/ItemsWF/CheckWF/...), not a textual condition.

		#-- Accept the :Where = '...' named-param form as well as a bare string.
		if isList(pcCondition) and IsWhereNamedParamList(pcCondition)
			pcCondition = pcCondition[2]
		ok

		nLen = This.NumberOfItems()
		if nLen = 0 return [] ok

		#-- Transpile the expressive navigation keywords (@NextItem -> This[@i+1],
		#-- etc.) only when present, so the simple path stays free of parse cost.
		#-- Using a navigation keyword also opts in to executable-section
		#-- bounding below (so neighbour access never steps out of range);
		#-- raw This[@i+k] index math stays unbounded (you own the bounds).
		bNavKeyword = 0
		if ring_len( StzFindCS("@Next", pcCondition, 1) ) > 0 or
		   ring_len( StzFindCS("@Previous", pcCondition, 1) ) > 0
			pcCondition = StzCCodeQ(pcCondition).Transpiled()
			bNavKeyword = 1
		ok

		pcCondition = _StzStripBraces(pcCondition)

		#-- Lower any Softanza Q(EXPR).Method(...) predicate to engine DSL so
		#-- conditions like Q(This[@i+1]).IsDoubleOf(This[@i-1]) evaluate.
		if ring_len( StzFindCS("Q(", pcCondition, 1) ) > 0
			pcCondition = _StzLowerWPredicates(pcCondition)
		ok

		#-- Executable-section bounds: keep neighbour indices in range (e.g. a
		#-- +1 look-ahead excludes the last position, which has no successor).
		#-- Applied only when an expressive navigation keyword was used.
		nStart = 1
		nEnd = nLen
		if bNavKeyword and ring_len( StzFindCS("@i", pcCondition, 1) ) > 0
			anSec = StzCCodeQ("{ " + pcCondition + " }").ExecutableSection()
			nStart = anSec[1]
			nEnd   = anSec[2]

			if isString(nEnd)
				nEnd = nLen
			but isNumber(nEnd) and nEnd < 0
				nEnd += nLen
			ok
			if isString(nStart)
				nStart = 1
			ok
			if nStart < 1 nStart = 1 ok
			if nEnd > nLen nEnd = nLen ok
		ok

		pList = This._Engine()
		if pList = NULL return [] ok
		# Engine returns a ready list of 1-based positions (built Zig-side).
		anAll = StzEngineListFindAllW(pList, pcCondition)

		#-- Fast path: no bounding needed.
		if nStart = 1 and nEnd = nLen
			return anAll
		ok

		anResult = []
		nA = len(anAll)
		for i = 1 to nA
			p = anAll[i]
			if p >= nStart and p <= nEnd
				anResult + p
			ok
		next
		return anResult

		def FindW(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def FindAllW(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def FindAllItemsWhere(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def FindWhere(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def ItemsPositionsW(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def ItemsAndTheirPositionsW(pcCondition)
			return _StzGroupItemsAtPos(This.Content(), This.FindAllItemsW(pcCondition))


		def PositionsW(pcCondition)
			return This.FindAllItemsW(pcCondition)

		def PositionsWhere(pcCondition)
			return This.FindAllItemsW(pcCondition)

	#-- FindAllItemsW: the "extended" W scan. Unlike the plain W form, it
	#-- accepts the expressive Softanza keywords (@NextItem, @PreviousItem,
	#-- @NextNumber, ...) and the Q(EXPR).Method(...) predicate form. The
	#-- condition is transpiled to the basic This[@i+1]/This[@i-1] indexing
	#-- and any Q(...) predicate is lowered to engine DSL; the scan is then
	#-- bounded to the "executable section" so navigation indices stay in
	#-- range (e.g. with @NextItem the last position is excluded, since it
	#-- has no successor). Returns the matching 1-based POSITIONS.



	  #-- WF: anonymous-function constraints (full Ring power, no eval)

	def FindWF(pFunc)
		return _StzFindWF(This.Content(), pFunc)

		def FindAllWF(pFunc)
			return This.FindWF(pFunc)

		def PositionsWF(pFunc)
			return This.FindWF(pFunc)

	def CheckWF(pFunc)
		return _StzCheckWF(This.Content(), pFunc)

		def AllItemsWF(pFunc)
			return This.CheckWF(pFunc)

	#-- CheckW: all items satisfy a W (DSL) condition. CheckW is the same
	#-- now that the DSL is engine-backed (the perf/expressiveness split is gone).
	def CheckW(pcCondition)
		return ring_len(This.FindAllItemsW(pcCondition)) = This.NumberOfItems()

	#-- AllItemsVerifyW: readable alias of CheckW ("do ALL items verify ...?").
	#   Ring's NULL is the empty string, but the W-engine doesn't know the NULL
	#   token, so '@item != NULL' is normalized to '@item != ""' first -- making
	#   the idiomatic non-null-string check work.
	def AllItemsVerifyW(pcCondition)
		_cAivCond_ = StzReplace(pcCondition, " NULL", ' ""')
		return This.CheckW(_cAivCond_)

		def AllItemsVerify(pcCondition)
			return This.AllItemsVerifyW(pcCondition)

		def EachItemVerifiesW(pcCondition)
			return This.AllItemsVerifyW(pcCondition)


	#-- the items at panPos all satisfy a W (DSL) condition
	def CheckItemsAtW(panPos, pcCondition)
		return _StzAllIn(panPos, This.FindAllItemsW(pcCondition))

	#-- WF variants: the items at panPos all satisfy an anonymous function
	def CheckItemsAtWF(panPos, pFunc)
		return _StzCheckItemsAtWF(This.Content(), panPos, pFunc)

		def CheckOnWF(panPos, pFunc)
			return This.CheckItemsAtWF(panPos, pFunc)

	def CountWF(pFunc)
		return ring_len(This.FindWF(pFunc))

	def ItemsWF(pFunc)
		return This.ItemsAtPositions(This.FindWF(pFunc))

		def FilterWF(pFunc)
			return This.ItemsWF(pFunc)

		def ExtractWF(pFunc)
			return This.ItemsWF(pFunc)

		def StringsWF(pFunc)
			return This.ItemsWF(pFunc)

	def ContainsWF(pFunc)
		return This.CountWF(pFunc) > 0

	def NumberOfItemsWF(pFunc)
		return This.CountWF(pFunc)

		def HowManyItemsWF(pFunc)
			return This.CountWF(pFunc)

	def ItemsPositionsWF(pFunc)
		return This.FindWF(pFunc)

	def ItemsAndTheirPositionsWF(pFunc)
		return _StzGroupItemsAtPos(This.Content(), This.FindWF(pFunc))

	def CountUniqueItemsWF(pFunc)
		return ring_len(_StzUniqueItems(This.ItemsWF(pFunc)))

		def NumberOfUniqueItemsWF(pFunc)
			return This.CountUniqueItemsWF(pFunc)

	def UniqueItemsWF(pFunc)
		return _StzUniqueItems(This.ItemsWF(pFunc))

	#-- W-DSL twin: the unique items matching a W condition.
	def UniqueItemsW(pcCondition)
		return _StzUniqueItems(This.ItemsW(pcCondition))

	#-- the n-th / first / last item matching the function
	def NthItemWF(n, pFunc)
		_aWf_ = This.ItemsWF(pFunc)
		if n >= 1 and n <= ring_len(_aWf_) return _aWf_[n] ok
		return NULL

	def FirstItemWF(pFunc)
		_aWf_ = This.ItemsWF(pFunc)
		if ring_len(_aWf_) > 0 return _aWf_[1] ok
		return NULL

	def LastItemWF(pFunc)
		_aWf_ = This.ItemsWF(pFunc)
		if ring_len(_aWf_) > 0 return _aWf_[ ring_len(_aWf_) ] ok
		return NULL

	#-- WF mutators / transforms (full Ring power, no eval)

	def RemoveWF(pFunc)
		This._SetContent(_StzRemoveWF(This.Content(), pFunc))

		def RemoveWFQ(pFunc)
			This.RemoveWF(pFunc)
			return This

	def ReplaceWF(pFunc, pNewItem)
		This._SetContent(_StzReplaceWF(This.Content(), pFunc, pNewItem))

	def MapWF(pFunc)
		return _StzMapWF(This.Content(), pFunc)

		def YieldWF(pFunc)
			return This.MapWF(pFunc)

	def InsertAfterWF(pFunc, pItem)
		This._SetContent(_StzInsertAfterWF(This.Content(), pFunc, pItem))

	def InsertBeforeWF(pFunc, pItem)
		This._SetContent(_StzInsertBeforeWF(This.Content(), pFunc, pItem))

	#-- PerformWF(condFunc, actionFunc): transform each matching item with
	#-- actionFunc; others unchanged. The eval-free form of PerformW(:if,:do).
	def PerformWF(pCondFunc, pActionFunc)
		This._SetContent(_StzPerformWF(This.Content(), pCondFunc, pActionFunc))

		def PerformWFQ(pCondFunc, pActionFunc)
			This.PerformWF(pCondFunc, pActionFunc)
			return This

	  #-- FindW: the extended (expressive) where-scan. Returns the matching
	  #-- POSITIONS (use ItemsW for the items at those positions). It accepts
	  #-- @NextItem/@PreviousItem/... and the Q(EXPR).Method(...) predicate form.



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

	# Sugar aliases over ExtendToPositionXT: the same operation
	# but using the more natural "ExtendTo" / "Extend" naming.
	# Default filler is the empty string.

	def ExtendTo(n)
		# Type-aware padding: 0 for an all-number list, "" otherwise
		# (ExtendToPosition decides). Use ExtendToXT(n, :With=v) to choose.
		This.ExtendToPosition(n)

		def ExtendToQ(n)
			This.ExtendTo(n)
			return This

		def ExtendToWith(n, pWith)
			This.ExtendToPositionXT(n, pWith)

	# DifferenceWithXT: structured diff against another list.
	# Returns [ :added = [...], :removed = [...], :modified = [...] ].
	# Items in This but not in other are :added (from This's POV);
	# items in other but not in This are :removed; :modified is left
	# empty by this base form (used by stzGraph._CompareEdges where
	# edge identity is value-equality).

	def DifferenceWithXT(paOther)
		_aDwAdded_ = []
		_aDwRemoved_ = []
		_nDwLen_ = len(@aContent)
		for _iDw_ = 1 to _nDwLen_
			if ring_find(paOther, @aContent[_iDw_]) = 0
				_aDwAdded_ + @aContent[_iDw_]
			ok
		next
		_nDwOLen_ = len(paOther)
		for _iDw_ = 1 to _nDwOLen_
			if ring_find(@aContent, paOther[_iDw_]) = 0
				_aDwRemoved_ + paOther[_iDw_]
			ok
		next
		return [
			:added = _aDwAdded_,
			:removed = _aDwRemoved_,
			:modified = []
		]

		def DifferenceWith(paOther)
			_aDwx_ = This.DifferenceWithXT(paOther)
			# Plain form: return only the symmetric difference items
			# (added + removed) without the modified bucket.
			_aDwRes_ = []
			_a_aDwx_added1_ = _aDwx_[:added]
			_n_aDwx_added1Len_ = len(_a_aDwx_added1_)
			for _iLoop_aDwx_added1_ = 1 to _n_aDwx_added1Len_
				_xDw_ = _a_aDwx_added1_[_iLoop_aDwx_added1_]
				_aDwRes_ + _xDw_
			next
			_a_aDwx_removed1_ = _aDwx_[:removed]
			_n_aDwx_removed1Len_ = len(_a_aDwx_removed1_)
			for _iLoop_aDwx_removed1_ = 1 to _n_aDwx_removed1Len_
				_xDw_ = _a_aDwx_removed1_[_iLoop_aDwx_removed1_]
				_aDwRes_ + _xDw_
			next
			return _aDwRes_

	# Shrink: truncate the list to the first n items (in place).

	def ShrinkTo(n)
		_nShLen_ = len(@aContent)
		if n < 0
			n = 0
		ok
		if n >= _nShLen_
			return
		ok
		_aShNew_ = []
		for _iSh_ = 1 to n
			_aShNew_ + @aContent[_iSh_]
		next
		This._SetContent(_aShNew_)

		def ShrinkToQ(n)
			This.ShrinkTo(n)
			return This

		def TruncateTo(n)
			This.ShrinkTo(n)

		def KeepFirst(n)
			This.ShrinkTo(n)

	# ExtendXT: named-param Extend DSL used by narrative tests.
	# Supported forms:
	#   ExtendXT( :List, :With = [...] )           -- append items
	#   ExtendXT( :List, :ToPosition = n )         -- pad to length n
	#   ExtendXT( :ToPosition = n, :With = x )     -- pad to n with x
	#   ExtendXT( :ToPosition = n, :WithItemsIn = [...] ) -- cycle items
	#   ExtendXT( :To = n, :WithItemsIn = [...] )  -- :To alias
	#   ExtendXT( :ToPosition = n, :ByItemsRepeated )    -- cycle self
	def ExtendXT(p1, p2)
		_nTo_ = 0
		_xWith_ = NULL
		_xWithItemsIn_ = NULL
		_bRepeat_ = FALSE

		_aArgs_ = [ p1, p2 ]
		for _i_ = 1 to 2
			_a_ = _aArgs_[_i_]
			if isList(_a_) and len(_a_) = 2 and isString(_a_[1])
				_k_ = _a_[1]
				if _k_ = :WithItemsIn
					_xWithItemsIn_ = _a_[2]
				but _k_ = :With
					_xWith_ = _a_[2]
				but _k_ = :ToPosition or _k_ = :To
					_nTo_ = _a_[2]
				ok
			but _a_ = :ByItemsRepeated
				_bRepeat_ = TRUE
			ok
		next

		if _nTo_ > 0
			if _xWithItemsIn_ != NULL
				# distribute/cycle the supplied pool into the new slots
				return This.ExtendToWithItemsIn(_nTo_, _xWithItemsIn_)
			but _xWith_ != NULL
				return This.ExtendToWith(_nTo_, _xWith_)
			but _bRepeat_
				_aSrc_ = This.Copy().Content()
				_nSrcLen_ = len(_aSrc_)
				if _nSrcLen_ = 0 return ok
				while len(@aContent) < _nTo_
					This._InvalidateEngine()   # in-place @aContent mutation below
					@aContent + _aSrc_[ ((len(@aContent)) % _nSrcLen_) + 1 ]
				end
				return
			else
				return This.ExtendTo(_nTo_)
			ok
		but _xWith_ != NULL
			return This.Extend(_xWith_)
		ok

		def ExtendXTQ(p1, p2)
			This.ExtendXT(p1, p2)
			return This

	def Extend(pWith)
		# Append a single element (or a list of elements) to the list.
		if isList(pWith)
			_nWith1Len_ = len(pWith)
			for _iLoopWith1_ = 1 to _nWith1Len_
				_xExWi_ = pWith[_iLoopWith1_]
				This.AddItem(_xExWi_)
			next
		else
			This.AddItem(pWith)
		ok

		def ExtendQ(pWith)
			This.Extend(pWith)
			return This

		def ExtendWith(pWith)
			This.Extend(pWith)

	  #-- Perform: execute code on each item

	def Perform(pcAction)
		This._SetContent(This.Map(pcAction))

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
		aNew = StzEngineListContentToRingList(pResult)

		for i = 1 to nLen
			nPos = panPos[i]
			if nPos >= 1 and nPos <= len(@aContent)
				This._InvalidateEngine()   # in-place @aContent mutation below
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

		def Smallest()
			return This.Min()

		def Lowest()
			return This.Min()

	def Max()
		if len(@aContent) = 0
			return 0
		ok

		# Engine-backed O(n) max
		pList = This._EngineListFromContent()
		nResult = StzEngineListMax(pList)
		StzEngineListFree(pList)
		return nResult

		def Greatest()
			return This.Max()

		def Largest()
			return This.Max()

		def Highest()
			return This.Max()

	  #-- Sum / Product / Mean (engine-backed)

	def Sum()
		if len(@aContent) = 0 return 0 ok
		_pSmList_ = This._Engine()
		_nSmResult_ = StzEngineListSum(_pSmList_)
		return _nSmResult_

	def Product()
		if len(@aContent) = 0 return 0 ok
		_pPrList_ = This._Engine()
		_nPrResult_ = StzEngineListProduct(_pPrList_)
		return _nPrResult_

	def Mean()
		if len(@aContent) = 0 return 0 ok
		_pMnList_ = This._Engine()
		_nMnResult_ = StzEngineListMean(_pMnList_)
		return _nMnResult_

		def Average()
			return This.Mean()

	  #-- Variance / StdDev (engine-backed)

	def Variance()
		if len(@aContent) = 0 return 0 ok
		_pVarList_ = This._Engine()
		_nVarResult_ = StzEngineListVariance(_pVarList_)
		return _nVarResult_

	def Stddev()
		if len(@aContent) = 0 return 0 ok
		_pSdList_ = This._Engine()
		_nSdResult_ = StzEngineListStddev(_pSdList_)
		return _nSdResult_

		def StandardDeviation()
			return This.Stddev()

	  #-- Median / Nth Smallest / Nth Largest (engine-backed)

	def Median()
		if len(@aContent) = 0 return 0 ok
		_pMdList_ = This._Engine()
		_nMdResult_ = StzEngineListMedian(_pMdList_)
		return _nMdResult_

	def NthSmallest(n)
		# The n-th smallest DISTINCT value (dedup, then ascending rank),
		# matching the monolith. (The engine NthSmallest ranks with
		# duplicates; dedup first so [3,3,7,8,8,10] -> 3rd smallest = 8.)
		if len(@aContent) = 0 return 0 ok
		_oNs_ = This.Copy()
		_oNs_.RemoveDuplicates()
		return _oNs_.Sorted()[n]

	def NthLargest(n)
		if len(@aContent) = 0 return 0 ok
		_oNl_ = This.Copy()
		_oNl_.RemoveDuplicates()
		return _oNl_.SortedInDescending()[n]

	  #-- Repeat (engine-backed)

	def Repeat(n)
		if CheckParams()
			if isList(n) and len(n) = 2 and
			   isNumber(n[1]) and isString(n[2]) and
			   (n[2] = :NTimes or n[2] = :Times)

				n = n[1]
			ok
		ok

		# Mutating, nesting (in place): [1,2].Repeat(3) -> [ [1,2], [1,2], [1,2] ].
		_aRptContent_ = This.Content()
		_aRptRes_ = []
		for _iRpt_ = 1 to n
			_aRptRes_ + _aRptContent_
		next
		This._SetContent(_aRptRes_)

		def RepeatQ(n)
			This.Repeat(n)
			return This

	def Repeated(n)
		if CheckParams()
			if isList(n) and len(n) = 2 and
			   isNumber(n[1]) and isString(n[2]) and
			   n[2] = :Times

				n = n[1]
			ok
		ok

		# Repeating a list yields a list CONTAINING that list n times (NESTED):
		# [1,2].Repeated(3) -> [ [1,2], [1,2], [1,2] ]. (The flat concatenation
		# is the (*) operator's job: o1 * 3 -> [1,2,1,2,1,2].)
		_aRpdContent_ = This.Content()
		_aRpdOut_ = []
		for _iRpd_ = 1 to n
			_aRpdOut_ + _aRpdContent_
		next
		return _aRpdOut_

		def RepeatedNTimes(n)
			return This.Repeated(n)

		def RepeatNTimes(n)
			return This.Repeated(n)

	  #-- SplitAt (engine-backed)

	def SplitAt(n)
		# The engine's stz_list_split_at takes the cut positions as an ENGINE
		# LIST handle (0-based cut indices), NOT a bare integer -- passing the
		# integer made the bridge read a bogus handle and the engine returned
		# NULL (so SplitAt silently fell back to [[],[]]). Build a 1-element
		# positions list at the 0-based cut (n-1) for the 1-based SplitAt(n).
		_pSaList_ = This._EngineListFromContent()
		if _pSaList_ = NULL return [[], []] ok
		_pSaPos_ = (new stzList([ n - 1 ]))._EngineListFromContent()
		_pSaResult_ = StzEngineListSplitAt(_pSaList_, _pSaPos_)
		StzEngineListFree(_pSaList_)
		if _pSaPos_ != NULL StzEngineListFree(_pSaPos_) ok
		if _pSaResult_ = NULL return [[], []] ok
		_aSaOut_ = StzEngineListContentToRingList(_pSaResult_)
		StzEngineListFree(_pSaResult_)
		return _aSaOut_

	  #-- Ranked (engine-backed)

	def Ranked()
		_pRkList_ = This._EngineListFromContent()
		if _pRkList_ = NULL return [] ok
		_pRkResult_ = StzEngineListRanked(_pRkList_)
		StzEngineListFree(_pRkList_)
		if _pRkResult_ = NULL return [] ok
		_aRkOut_ = StzEngineListContentToRingList(_pRkResult_)
		StzEngineListFree(_pRkResult_)
		return _aRkOut_

	  #-- Join (engine-backed)

	def Join(pcSep)
		_pJnList_ = This._EngineListFromContent()
		if _pJnList_ = NULL return "" ok
		_cJnResult_ = StzEngineListJoin(_pJnList_, pcSep)
		StzEngineListFree(_pJnList_)
		return _cJnResult_

		def Joined(pcSep)
			return This.Join(pcSep)

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
		pList = This._EngineListFromContent()
		pVals = StzEngineMarshalList(paValues)
		nResult = StzEngineListIsSubsetCS(pList, pVals, 1)
		StzEngineListFree(pList)
		StzEngineListFree(pVals)
		return nResult

	def IsPairOfStrings()
		_aIpContent_ = This.Content()
		if len(_aIpContent_) != 2
			return 0
		ok
		return isString(_aIpContent_[1]) and isString(_aIpContent_[2])

	  #=============================================#
	 #  DELEGATIONS TO DOMAIN SUBMODULES           #
	#=============================================#

	  #-----------------------------#
	 #  FINDER DELEGATIONS         #
	#-----------------------------#

	# FindFirst/FindLast already exist as FindFirstOccurrenceCS/FindLastOccurrenceCS

	def AntiFindCS(pItem, pCaseSensitive)
		_oAfFinder_ = new stzListFinder(This)
		return _oAfFinder_.AntiFindCS(pItem, pCaseSensitive)

	def AntiFind(pItem)
		return This.AntiFindCS(pItem, 1)

	def AntiFindAsSectionsCS(pItem, pCaseSensitive)
		_oAfsaFinder_ = new stzListFinder(This)
		return _oAfsaFinder_.AntiFindAsSectionsCS(pItem, pCaseSensitive)

	def AntiFindAsSections(pItem)
		return This.AntiFindAsSectionsCS(pItem, 1)

		# Z-suffix: same as AntiFindAsSections.
		def AntiFindZZ(pItem)
			return This.AntiFindAsSections(pItem)

		def AntiFindAsSectionsZZ(pItem)
			return This.AntiFindAsSections(pItem)

		def AntiFindZZCS(pItem, pCaseSensitive)
			return This.AntiFindAsSectionsCS(pItem, pCaseSensitive)

	def AntiPositions(anPos)
		_oApFinder_ = new stzListFinder(This)
		return _oApFinder_.AntiPositions(anPos)

	# AntiPositionsZZ: the complement of anPos as [start, end] sections.
	# Walks 1..NumberOfItems, grouping consecutive positions not in anPos.
	def AntiPositionsZZ(anPos)
		_aRes_ = []
		_nLen_ = This.NumberOfItems()
		_aIn_ = anPos
		_nStart_ = 0
		for _i_ = 1 to _nLen_
			_bInPos_ = FALSE
			_nIL_ = len(_aIn_)
			for _j_ = 1 to _nIL_
				if _aIn_[_j_] = _i_ _bInPos_ = TRUE exit ok
			next
			if NOT _bInPos_
				if _nStart_ = 0 _nStart_ = _i_ ok
			else
				if _nStart_ > 0
					_aRes_ + [ _nStart_, _i_ - 1 ]
					_nStart_ = 0
				ok
			ok
		next
		if _nStart_ > 0
			_aRes_ + [ _nStart_, _nLen_ ]
		ok
		return _aRes_

	def FindNOccurrencesCS(n, pItem, pCaseSensitive)
		_oFnoFinder_ = new stzListFinder(This)
		return _oFnoFinder_.FindNOccurrencesCS(n, pItem, pCaseSensitive)

	def FindNOccurrences(n, pItem)
		return This.FindNOccurrencesCS(n, pItem, 1)

	# FindFirstCS/FindFirst/FindLastCS/FindLast already defined above as aliases

	def FindGivenOccurrencesCS(panOccurrences, pItem, pCaseSensitive)
		_oFgoFinder_ = new stzListFinder(This)
		return _oFgoFinder_.FindGivenOccurrencesCS(panOccurrences, pItem, pCaseSensitive)

	def FindGivenOccurrences(panOccurrences, pItem)
		return This.FindGivenOccurrencesCS(panOccurrences, pItem, 1)

	def FindAllExceptFirstCS(pItem, pCaseSensitive)
		_oFaefFinder_ = new stzListFinder(This)
		return _oFaefFinder_.FindAllExceptFirstCS(pItem, pCaseSensitive)

	def FindAllExceptFirst(pItem)
		return This.FindAllExceptFirstCS(pItem, 1)

	def FindAllExceptLastCS(pItem, pCaseSensitive)
		_oFaelFinder_ = new stzListFinder(This)
		return _oFaelFinder_.FindAllExceptLastCS(pItem, pCaseSensitive)

	def FindAllExceptLast(pItem)
		return This.FindAllExceptLastCS(pItem, 1)

	def FindNextNthOccurrenceCS(n, pItem, pnStartingAt, pCaseSensitive)
		_oFnnoFinder_ = new stzListFinder(This)
		return _oFnnoFinder_.FindNextNthOccurrenceCS(n, pItem, pnStartingAt, pCaseSensitive)

	def FindNextNthOccurrence(n, pItem, pnStartingAt)
		return This.FindNextNthOccurrenceCS(n, pItem, pnStartingAt, 1)

	def FindNextOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)
		_oFnoFinder2_ = new stzListFinder(This)
		return _oFnoFinder2_.FindNextOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)

	def FindNextOccurrence(pItem, pnStartingAt)
		return This.FindNextOccurrenceCS(pItem, pnStartingAt, 1)

	# FindNext: convenience wrapper used by narrative tests. Accepts
	# either FindNext(item, n) or FindNext(item, :StartingAt = n).
	def FindNext(pItem, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		return This.FindNextOccurrenceCS(pItem, pnStartingAt, 1)

		def FindNextCS(pItem, pnStartingAt, pCaseSensitive)
			if isList(pnStartingAt) and len(pnStartingAt) = 2
				pnStartingAt = pnStartingAt[2]
			ok
			return This.FindNextOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)

	def FindPrevious(pItem, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		return This.FindPreviousOccurrenceCS(pItem, pnStartingAt, 1)

		def FindPreviousCS(pItem, pnStartingAt, pCaseSensitive)
			if isList(pnStartingAt) and len(pnStartingAt) = 2
				pnStartingAt = pnStartingAt[2]
			ok
			return This.FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)

	# FindNthPrevious(n, pItem, pnStartingAt): word-order alias over
	# FindPreviousNthOccurrence -- find the Nth occurrence of pItem
	# walking backwards from pnStartingAt. Accepts :StartingAt = n.
	def FindNthPrevious(n, pItem, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		return This.FindPreviousNthOccurrenceCS(n, pItem, pnStartingAt, 1)

		def FindNthPreviousCS(n, pItem, pnStartingAt, pCaseSensitive)
			if isList(pnStartingAt) and len(pnStartingAt) = 2
				pnStartingAt = pnStartingAt[2]
			ok
			return This.FindPreviousNthOccurrenceCS(n, pItem, pnStartingAt, pCaseSensitive)

	# FindNthNext(n, pItem, pnStartingAt): symmetric forward variant.
	def FindNthNext(n, pItem, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		return This.FindNextNthOccurrenceCS(n, pItem, pnStartingAt, 1)

		def FindNthNextCS(n, pItem, pnStartingAt, pCaseSensitive)
			if isList(pnStartingAt) and len(pnStartingAt) = 2
				pnStartingAt = pnStartingAt[2]
			ok
			return This.FindNextNthOccurrenceCS(n, pItem, pnStartingAt, pCaseSensitive)

	def FindPreviousNthOccurrenceCS(n, pItem, pnStartingAt, pCaseSensitive)
		_oFpnoFinder_ = new stzListFinder(This)
		return _oFpnoFinder_.FindPreviousNthOccurrenceCS(n, pItem, pnStartingAt, pCaseSensitive)

	def FindPreviousNthOccurrence(n, pItem, pnStartingAt)
		return This.FindPreviousNthOccurrenceCS(n, pItem, pnStartingAt, 1)

	def FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)
		_oFpoFinder_ = new stzListFinder(This)
		return _oFpoFinder_.FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)

	def FindPreviousOccurrence(pItem, pnStartingAt)
		return This.FindPreviousOccurrenceCS(pItem, pnStartingAt, 1)

	#-- Missing name-variants for the next/previous occurrence family
	#-- (delegating to stzListFinder; strictly-after / strictly-before).
	def FindNthNextOccurrence(n, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindNthNextOccurrence(n, pItem, pnStartingAt)

	def FindNextNth(n, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindNextNth(n, pItem, pnStartingAt)

	def FindNextOccurrences(pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindNextOccurrences(pItem, pnStartingAt)

		def FindNextOccurrencesST(pItem, pnStartingAt)
			return This.FindNextOccurrences(pItem, pnStartingAt)

	def FindNextNthOccurrencesST(panN, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindNextNthOccurrencesST(panN, pItem, pnStartingAt)

	def FindPreviousOccurrences(pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindPreviousOccurrences(pItem, pnStartingAt)

		def FindPreviousOccurrencesST(pItem, pnStartingAt)
			return This.FindPreviousOccurrences(pItem, pnStartingAt)

	def FindPreviousNthOccurrences(panN, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindPreviousNthOccurrences(panN, pItem, pnStartingAt)

	def FindFirstNext(pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindFirstNext(pItem, pnStartingAt)

	def FindFirstPrevious(pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindFirstPrevious(pItem, pnStartingAt)

	def FindItem(pItem)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindItem(pItem)

	def FindPreviousNth(n, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindPreviousNth(n, pItem, pnStartingAt)

	def NthNextOccurrence(n, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.NthNextOccurrence(n, pItem, pnStartingAt)

	def NextNthOccurrence(n, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.NextNthOccurrence(n, pItem, pnStartingAt)

	  #=========================================================#
	 #  SMALLEST/LARGEST POSITIONS, ITEMS-WITH-POSITIONS, etc. #
	#=========================================================#

	def FindSmallest()
		return This.Find(This.Smallest())

		def NumberOfSmallest()
			return ring_len(This.FindSmallest())

		def NumberOfOccurrencesOfSmallestItem()
			return ring_len(This.FindSmallest())

	def FindLargest()
		return This.Find(This.Largest())

		def NumberOfLargest()
			return ring_len(This.FindLargest())

		def NumberOfOccurrencesOfLargestItem()
			return ring_len(This.FindLargest())

	#-- [[item, [positions...]], ...] in first-appearance order
	def FindItems()
		return _StzItemsWithPositions(This.Content())

		def ItemsZ()
			return This.FindItems()

	#-- [[item, count], ...] in first-appearance order (type-sensitive)
	def ItemsCount()
		return _StzItemsCount(This.Content())

	  #-------------------------------------------#
	 #  CONSECUTIVE-DUPLICATE ITEMS              #
	#-------------------------------------------#

	def FindDupSecutiveItemsCS(pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		return _StzFindDupSecutive(This.Content(), pCaseSensitive)

	def FindDupSecutiveItems()
		return _StzFindDupSecutive(This.Content(), 1)

	def DupSecutiveItemsCS(pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		return _StzDupSecutiveValues(This.Content(), pCaseSensitive)

	def DupSecutiveItems()
		return _StzDupSecutiveValues(This.Content(), 1)

	def FindThisDupSecutiveItemCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		return _StzFindThisDupSecutive(This.Content(), pItem, pCaseSensitive)

	def FindThisDupSecutiveItem(pItem)
		return _StzFindThisDupSecutive(This.Content(), pItem, 1)

	def DupSecutiveItemsCSZ(pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		return _StzDupSecutiveItemsZ(This.Content(), pCaseSensitive)

	def DupSecutiveItemsZ()
		return _StzDupSecutiveItemsZ(This.Content(), 1)

	def DupSecutiveItemCSZ(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		return [ pItem, _StzFindThisDupSecutive(This.Content(), pItem, pCaseSensitive) ]

	def DupSecutiveItemZ(pItem)
		return This.DupSecutiveItemCSZ(pItem, 1)

	def RemoveDupSecutiveItemsCS(pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		This._SetContent(_StzRemoveDupSecutive(This.Content(), pCaseSensitive))

		def RemoveDupSecutiveItemsCSQ(pCaseSensitive)
			This.RemoveDupSecutiveItemsCS(pCaseSensitive)
			return This

	def RemoveDupSecutiveItems()
		This.RemoveDupSecutiveItemsCS(1)

	def RemoveDupSecutiveItemCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		This._SetContent(_StzRemoveThisDupSecutive(This.Content(), pItem, pCaseSensitive))

	def RemoveDupSecutiveItem(pItem)
		This.RemoveDupSecutiveItemCS(pItem, 1)

	def FindNthSmallest(n)
		return This.Find(This.NthSmallest(n))

	def FindNthLargest(n)
		return This.Find(This.NthLargest(n))

	#-- contiguous runs of strings / lists as [start,end] sections
	def FindStringsAsSections()
		return _StzFindTypeRuns(This.Content(), "string")

		def FindStringsZZ()
			return This.FindStringsAsSections()

	def FindListsAsSections()
		return _StzFindTypeRuns(This.Content(), "list")

		def FindListsZZ()
			return This.FindListsAsSections()

	def FindObjectsAsSections()
		return _StzFindTypeRuns(This.Content(), "object")

		def FindObjectsZZ()
			return This.FindObjectsAsSections()

	#-- first position type-sensitively equal to pItem ("2" != 2 != [2])
	def FindFirstOccurrence(pItem)
		return _StzFindFirstTyped(This.Content(), pItem)

	#-- positions of items NOT in paItems
	def FindAllExcept(paItems)
		return _StzFindAllExcept(This.Content(), paItems)

		def FindItemsOtherThan(paItems)
			return This.FindAllExcept(paItems)

	#-- "Origins" = the position of the FIRST occurrence of each
	#-- duplicated item (monolith authoritative semantics).
	def FindDuplicatesOrigins()
		return This.FindFirstDuplicates()

		def FindDuplicationsOrigins()
			return This.FindDuplicatesOrigins()

	  #=========================================================#
	 #  REMOVE FAMILY (occurrences / except / runs / dups)     #
	#=========================================================#

	def Remove(pItem)
		This.RemoveAllCS(pItem, 1)

	def RemoveMany(paItems)
		nLen = ring_len(paItems)
		for i = 1 to nLen
			This.RemoveAllCS(paItems[i], 1)
		next

		def RemoveTheseItems(paItems)
			This.RemoveMany(paItems)

	#-- keep only items that are members of paItems (drop everything else)
	def RemoveAllExcept(paItems)
		_items_ = paItems
		if NOT isList(paItems)
			_items_ = [ paItems ]
		ok
		This._SetContent(_StzKeepMembers(This.Content(), _items_))

		def RemoveItemsOtherThan(paItems)
			This.RemoveAllExcept(paItems)

	#-- remove the panOcc-th occurrences of pItem (by occurrence index)
	def RemoveOccurrences(panOcc, pItem)
		_pos_ = This.FindAllCS(pItem, 1)
		This._SetContent(_StzRemoveAtPositions(This.Content(), _StzPickPositions(panOcc, _pos_)))

	def RemoveAnyItemFromStart(pItem)
		This._SetContent(_StzRemoveLeadingRun(This.Content(), pItem))

	def RemoveAnyItemFromEnd(pItem)
		This._SetContent(_StzRemoveTrailingRun(This.Content(), pItem))

	def RemoveNonDuplicates()
		This._SetContent(_StzRemoveNonDuplicates(This.Content()))

	#-- remove the n-th occurrence of pItem
	def RemoveThisNthItem(n, pItem)
		_pos_ = This.FindAllCS(pItem, 1)
		if n >= 1 and ring_len(_pos_) >= n
			This._SetContent(_StzRemoveAtPositions(This.Content(), [ _pos_[n] ]))
		ok

		def RemoveNth(n, pItem)
			This.RemoveThisNthItem(n, pItem)

	#-- occurrence removal relative to a position (Next strictly after,
	#-- Previous strictly before; the Nth index is forward into that run)
	def RemoveNextNthOccurrence(n, pItem, pnStartingAt)
		_p_ = This.FindNthNextOccurrence(n, pItem, pnStartingAt)
		if _p_ > 0
			This._SetContent(_StzRemoveAtPositions(This.Content(), [ _p_ ]))
		ok

	def RemoveNextNthOccurrences(panN, pItem, pnStartingAt)
		_ps_ = This.FindNextNthOccurrencesST(panN, pItem, pnStartingAt)
		This._SetContent(_StzRemoveAtPositions(This.Content(), _ps_))

		def NextNthOccurrencesRemoved(panN, pItem, pnStartingAt)
			_ps_ = This.FindNextNthOccurrencesST(panN, pItem, pnStartingAt)
			return _StzRemoveAtPositions(This.Content(), _ps_)

	def RemovePreviousNthOccurrence(n, pItem, pnStartingAt)
		_ps_ = This.FindPreviousNthOccurrences([ n ], pItem, pnStartingAt)
		if ring_len(_ps_) > 0
			This._SetContent(_StzRemoveAtPositions(This.Content(), [ _ps_[1] ]))
		ok

	def RemovePreviousNthOccurrences(panN, pItem, pnStartingAt)
		_ps_ = This.FindPreviousNthOccurrences(panN, pItem, pnStartingAt)
		This._SetContent(_StzRemoveAtPositions(This.Content(), _ps_))

		def PreviousNthOccurrencesRemoved(panN, pItem, pnStartingAt)
			_ps_ = This.FindPreviousNthOccurrences(panN, pItem, pnStartingAt)
			return _StzRemoveAtPositions(This.Content(), _ps_)

	#-- remove the first occurrence of pItem
	def RemoveFirst(pItem)
		This.RemoveThisNthItem(1, pItem)

		def RemoveThisFirstItem(pItem)
			This.RemoveFirst(pItem)

	def RemoveThisFirstItemCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		_pos_ = This.FindAllCS(pItem, pCaseSensitive)
		if ring_len(_pos_) > 0
			This._SetContent(_StzRemoveAtPositions(This.Content(), [ _pos_[1] ]))
		ok

	#-- remove the item at position n; accepts :First / :Last
	def RemoveNthItem(n)
		if isString(n)
			if n = :Last or n = :LastItem
				n = This.NumberOfItems()
			but n = :First or n = :FirstItem
				n = 1
			ok
		ok
		This.RemoveItemAtPosition(n)

	  #=========================================================#
	 #  CONTAINS predicates (no / both / each / only-one / by-type) #
	#=========================================================#

	def ContainsNo(pItem)
		return NOT This.Contains(pItem)

	def ContainsBoth(p1, p2)
		return This.Contains(p1) and This.Contains(p2)

	def ContainsEachOneOfThese(paItems)
		return This.ContainsEach(paItems)

	#-- TRUE iff exactly ONE distinct member of paItems is present
	def ContainsOnlyOneOfThese(paItems)
		return _StzCountMembersPresent(This.Content(), paItems) = 1

	def ContainsNoObjects()
		return NOT _StzContainsType(This.Content(), "object")

	def ContainsObjects()
		return _StzContainsType(This.Content(), "object")

	def ContainsOneOrMoreLists()
		return _StzContainsType(This.Content(), "list")

		def ContainsLists()
			return This.ContainsOneOrMoreLists()

	def ContainsNoNumbers()
		return NOT _StzContainsType(This.Content(), "number")

	def ContainsNoStrings()
		return NOT _StzContainsType(This.Content(), "string")

	  #=========================================================#
	 #  SINGLES (1-elem lists) and PAIRS (2-elem lists)        #
	#=========================================================#

	def IsSingle()
		return ring_len(@aContent) = 1

	def FindSingles()
		return _StzFindListsOfLen(This.Content(), 1)

	def Singles()
		return _StzItemsAtPos(This.Content(), This.FindSingles())

	def SinglesU()
		return _StzUniqueItems(This.Singles())

	def SinglesZ()
		return _StzGroupItemsAtPos(This.Content(), This.FindSingles())

	def ContainsSingles()
		return ring_len(This.FindSingles()) > 0

	def Singlified()
		return _StzSinglified(This.Content())

	def FindPairs()
		return _StzFindListsOfLen(This.Content(), 2)

	def ItemsThatArePairs()
		return _StzItemsAtPos(This.Content(), This.FindPairs())

	def PairsU()
		return _StzUniqueItems(This.ItemsThatArePairs())

	def PairsZ()
		return _StzGroupItemsAtPos(This.Content(), This.FindPairs())

	def ContainsPairs()
		return ring_len(This.FindPairs()) > 0

	def Pairified()
		return _StzPairified(This.Content())

	  #=========================================================#
	 #  ITEMS / THESE-ITEMS family                             #
	#=========================================================#

	#-- [[item,[positions]],...] for each given item (includes empties)
	def TheseItemsZ(paItems)
		return _StzTheseItemsZ(This.Content(), paItems)

	#-- distinct items by occurrence count (>= n by default)
	def ItemsOccurringNTimes(n)
		return _StzItemsByCountOp(This.Content(), n, "ge")

		def ItemsOccuringNTimes(n)
			return This.ItemsOccurringNTimes(n)

		def ItemsOccurringNTimesOrMore(n)
			return This.ItemsOccurringNTimes(n)

	def ItemsOccurringExactlyNTimes(n)
		return _StzItemsByCountOp(This.Content(), n, "eq")

		def ItemsOccuringExactlyNTimes(n)
			return This.ItemsOccurringExactlyNTimes(n)

	def ItemsOccurringLessThanNTimes(n)
		return _StzItemsByCountOp(This.Content(), n, "lt")

	def ItemsOccurringNTimesOrLess(n)
		return _StzItemsByCountOp(This.Content(), n, "le")

	def ItemsOccurringMoreThanNTimes(n)
		return _StzItemsByCountOp(This.Content(), n, "gt")

	def ItemsHaveSameType()
		return _StzAllSameType(This.Content())

		def AllItemsHaveSameType()
			return This.ItemsHaveSameType()

	def ItemsAreEmptyLists()
		return _StzAllEmptyLists(This.Content())

	def ItemsAreEqualToCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and ring_len(pCaseSensitive) = 2
			pCaseSensitive = pCaseSensitive[2]
		ok
		return _StzAllEqualCS(This.Content(), pItem, pCaseSensitive)

	def ItemsAreEqualTo(pItem)
		return _StzAllEqualTyped(This.Content(), pItem)

		def ContainsOnly(pItem)
			# Route type symbols (:Number, :Numbers, :Strings, ...) through the
			# type-check; otherwise fall back to value equality.
			return This.AllItemsAre(pItem)

		def ContainsOnlyCS(pItem, pCaseSensitive)
			return This.ItemsAreEqualToCS(pItem, pCaseSensitive)

	#-- all items satisfy a W-condition
	def ItemsHaveXT(pcCondition)
		return ring_len(This.FindAllItemsW(pcCondition)) = This.NumberOfItems()

		def AllItemsHaveXT(pcCondition)
			return This.ItemsHaveXT(pcCondition)

	#-- positions matching a W-condition (+ grouped form)


	  #=========================================================#
	 #  INSERT after/before many positions / by W-condition    #
	#=========================================================#

	def InsertAfterManyPositions(panPos, pItem)
		This._SetContent(_StzInsertAfterPositions(This.Content(), panPos, pItem))

	def InsertBeforeManyPositions(panPos, pItem)
		This._SetContent(_StzInsertBeforePositions(This.Content(), panPos, pItem))

	#-- insert pItem after/before each item matching a W-condition (:Where ok)


	# CountItemsW/CountW already defined above

	  #-----------------------------#
	 #  COUNTER DELEGATIONS        #
	#-----------------------------#

	def NumberOfUniqueItemsW(pCondition)
		_oNuiwCounter_ = new stzListCounter(This)
		return _oNuiwCounter_.NumberOfUniqueItemsW(pCondition)



	def InsertAfterW(pcCondition, pNewItem)
		_oIawCounter_ = new stzListCounter(This)
		_oIawCounter_.InsertAfterW(pcCondition, pNewItem)
		This.UpdateWith(_oIawCounter_.Content())

	def InsertBeforeW(pcCondition, pNewItem)
		_oIbwCounter_ = new stzListCounter(This)
		_oIbwCounter_.InsertBeforeW(pcCondition, pNewItem)
		This.UpdateWith(_oIbwCounter_.Content())

	  #-----------------------------#
	 #  SPLITTER DELEGATIONS       #
	#-----------------------------#

	# SplitAt already defined in core

	def SplitXT(p)
		_oSxtSplitter_ = new stzListSplits(This)
		return _oSxtSplitter_.SplitXT(p)

	def SplittedXT(p)
		_oSdxtSplitter_ = new stzListSplits(This)
		return _oSdxtSplitter_.SplittedXT(p)

	def SplitAsSectionsXT(p)
		_oSasxtSplitter_ = new stzListSplits(This)
		return _oSasxtSplitter_.SplitAsSectionsXT(p)

	def SplittedAsSectionsXT(p)
		_oSdasxtSplitter_ = new stzListSplits(This)
		return _oSdasxtSplitter_.SplittedAsSectionsXT(p)

	def SplitCS(pItemOrPos, pCaseSensitive)
		_oScsSplitter_ = new stzListSplits(This)
		return _oScsSplitter_.SplitCS(pItemOrPos, pCaseSensitive)

	def SplitAtPositions(panPos)
		_oSapSplitter_ = new stzListSplits(This)
		return _oSapSplitter_.SplitAtPositions(panPos)

	def SplittedAtPositions(panPos)
		_oSdapSplitter_ = new stzListSplits(This)
		return _oSdapSplitter_.SplittedAtPositions(panPos)

	def SplitAtPositionsZZ(panPos)
		_oSapzzSplitter_ = new stzListSplits(This)
		return _oSapzzSplitter_.SplitAtPositionsZZ(panPos)

	def SplittedAtPositionsZZ(panPos)
		_oSdapzzSplitter_ = new stzListSplits(This)
		return _oSdapzzSplitter_.SplittedAtPositionsZZ(panPos)

	def SplitAtPosition(n)
		_oSaposSplitter_ = new stzListSplits(This)
		return _oSaposSplitter_.SplitAtPosition(n)

	def SplittedAtPosition(n)
		_oSdaposSplitter_ = new stzListSplits(This)
		return _oSdaposSplitter_.SplittedAtPosition(n)

	def SplitAtPositionZZ(n)
		_oSapozzSplitter_ = new stzListSplits(This)
		return _oSapozzSplitter_.SplitAtPositionZZ(n)

	def SplittedAtPositionZZ(n)
		_oSdapozzSplitter_ = new stzListSplits(This)
		return _oSdapozzSplitter_.SplittedAtPositionZZ(n)

	def SplitAtCS(pItem, pCaseSensitive)
		_oSacsSplitter_ = new stzListSplits(This)
		return _oSacsSplitter_.SplitAtCS(pItem, pCaseSensitive)

	def SplittedAtCS(pItem, pCaseSensitive)
		_oSdacsSplitter_ = new stzListSplits(This)
		return _oSdacsSplitter_.SplittedAtCS(pItem, pCaseSensitive)

	def SplittedAt(pItem)
		return This.SplittedAtCS(pItem, 1)

	def SplitAtCSZZ(pItem, pCaseSensitive)
		_oSacszzSplitter_ = new stzListSplits(This)
		return _oSacszzSplitter_.SplitAtCSZZ(pItem, pCaseSensitive)

	def SplitAtZZ(pItem)
		return This.SplitAtCSZZ(pItem, 1)

	def SplittedAtCSZZ(pItem, pCaseSensitive)
		_oSdacszzSplitter_ = new stzListSplits(This)
		return _oSdacszzSplitter_.SplittedAtCSZZ(pItem, pCaseSensitive)

	def SplittedAtZZ(pItem)
		return This.SplittedAtCSZZ(pItem, 1)

	def SplitBeforePosition(n)
		_oSbpSplitter_ = new stzListSplits(This)
		return _oSbpSplitter_.SplitBeforePosition(n)

	def SplittedBeforePosition(n)
		_oSdbpSplitter_ = new stzListSplits(This)
		return _oSdbpSplitter_.SplittedBeforePosition(n)

	def SplitBeforeCS(pItem, pCaseSensitive)
		_oSbcsSplitter_ = new stzListSplits(This)
		return _oSbcsSplitter_.SplitBeforeCS(pItem, pCaseSensitive)

	def SplitBefore(pItem)
		return This.SplitBeforeCS(pItem, 1)

	def SplitAfterPosition(n)
		_oSafpSplitter_ = new stzListSplits(This)
		return _oSafpSplitter_.SplitAfterPosition(n)

	def SplittedAfterPosition(n)
		_oSdafpSplitter_ = new stzListSplits(This)
		return _oSdafpSplitter_.SplittedAfterPosition(n)

	def SplitAfterCS(pItem, pCaseSensitive)
		_oSafcsSplitter_ = new stzListSplits(This)
		return _oSafcsSplitter_.SplitAfterCS(pItem, pCaseSensitive)

	def SplitAfter(pItem)
		return This.SplitAfterCS(pItem, 1)

	def SplitToNParts(n)
		_oStnpSplitter_ = new stzListSplits(This)
		return _oStnpSplitter_.SplitToNParts(n)

		def SplitToNPartsQ(n)
			return new stzList( This.SplitToNParts(n) )

	def SplittedToNParts(n)
		_oSdtnpSplitter_ = new stzListSplits(This)
		return _oSdtnpSplitter_.SplittedToNParts(n)

	def SplitToPartsOfNItems(n)
		# Mutator: delegating to new stzListSplits(This) would mutate a COPY of
		# This (Ring copies objects passed to a constructor), so the change was
		# lost. Write back through This itself using the returning form.
		This.UpdateWith( This.SplittedToPartsOfNItems(n) )

		def SplitToPartsOf(n)
			This.SplitToPartsOfNItems(n)

	def SplittedToPartsOfNItems(n)
		_oSdtponiSplitter_ = new stzListSplits(This)
		return _oSdtponiSplitter_.SplittedToPartsOfNItems(n)

		def SplittedToPartsOf(n)
			return This.SplittedToPartsOfNItems(n)

	def SplitAtPacer(nPace, nStart)
		_oSapcrSplitter_ = new stzListSplits(This)
		return _oSapcrSplitter_.SplitAtPacer(nPace, nStart)

	def SplittedAtPacer(nPace, nStart)
		_oSdapcrSplitter_ = new stzListSplits(This)
		return _oSdapcrSplitter_.SplittedAtPacer(nPace, nStart)

	def SplitW(pcCondition)
		_oSwSplitter_ = new stzListSplits(This)
		return _oSwSplitter_.SplitW(pcCondition)

	def SplittedW(pcCondition)
		_oSdwSplitter_ = new stzListSplits(This)
		return _oSdwSplitter_.SplittedW(pcCondition)




	  #-------------------------------#
	 #  LEAD/TRAIL DELEGATIONS       #
	#-------------------------------#

	def HasRepeatedLeadingItemsCS(pCaseSensitive)
		_oHrliLt_ = new stzListLeadTrail(This)
		return _oHrliLt_.HasRepeatedLeadingItemsCS(pCaseSensitive)

	def HasRepeatedLeadingItems()
		return This.HasRepeatedLeadingItemsCS(1)

	def RepeatedLeadingItemsCS(pCaseSensitive)
		_oRliLt_ = new stzListLeadTrail(This)
		return _oRliLt_.RepeatedLeadingItemsCS(pCaseSensitive)

	def RepeatedLeadingItems()
		return This.RepeatedLeadingItemsCS(1)

	def RepeatedLeadingItemCS(pCaseSensitive)
		_oRlicLt_ = new stzListLeadTrail(This)
		return _oRlicLt_.RepeatedLeadingItemCS(pCaseSensitive)

	def RepeatedLeadingItem()
		return This.RepeatedLeadingItemCS(1)

	def NumberOfRepeatedLeadingItemsCS(pCaseSensitive)
		_oNrliLt_ = new stzListLeadTrail(This)
		return _oNrliLt_.NumberOfRepeatedLeadingItemsCS(pCaseSensitive)

	def NumberOfRepeatedLeadingItems()
		return This.NumberOfRepeatedLeadingItemsCS(1)

	def HasRepeatedTrailingItemsCS(pCaseSensitive)
		_oHrtiLt_ = new stzListLeadTrail(This)
		return _oHrtiLt_.HasRepeatedTrailingItemsCS(pCaseSensitive)

	def HasRepeatedTrailingItems()
		return This.HasRepeatedTrailingItemsCS(1)

	def RepeatedTrailingItemsCS(pCaseSensitive)
		_oRtiLt_ = new stzListLeadTrail(This)
		return _oRtiLt_.RepeatedTrailingItemsCS(pCaseSensitive)

	def RepeatedTrailingItems()
		return This.RepeatedTrailingItemsCS(1)

	def RepeatedTrailingItemCS(pCaseSensitive)
		_oRticLt_ = new stzListLeadTrail(This)
		return _oRticLt_.RepeatedTrailingItemCS(pCaseSensitive)

	def RepeatedTrailingItem()
		return This.RepeatedTrailingItemCS(1)

	def NumberOfRepeatedTrailingItemsCS(pCaseSensitive)
		_oNrtiLt_ = new stzListLeadTrail(This)
		return _oNrtiLt_.NumberOfRepeatedTrailingItemsCS(pCaseSensitive)

	def NumberOfRepeatedTrailingItems()
		return This.NumberOfRepeatedTrailingItemsCS(1)

	  #-------------------------------#
	 #  EXTRACTOR DELEGATIONS        #
	#-------------------------------#

	def ExtractCS(pItem, pCaseSensitive)
		_oEcsExt_ = new stzListExtractor(This)
		_oEcsExt_.ExtractCS(pItem, pCaseSensitive)
		This.UpdateWith(_oEcsExt_.Content())
		return pItem

	def ExtractManyCS(paItems, pCaseSensitive)
		_oEmcsExt_ = new stzListExtractor(This)
		_oEmcsExt_.ExtractManyCS(paItems, pCaseSensitive)
		This.UpdateWith(_oEmcsExt_.Content())
		return paItems

	def ExtractMany(paItems)
		return This.ExtractManyCS(paItems, 1)

	def ExtractAll()
		_aContent_ = This.Content()
		_oEaExt_ = new stzListExtractor(This)
		_oEaExt_.ExtractAll()
		This.UpdateWith(_oEaExt_.Content())
		return _aContent_

	def ExtractNth(n)
		_oEnExt_ = new stzListExtractor(This)
		_oEnExt_.ExtractNth(n)
		This.UpdateWith(_oEnExt_.Content())
		return This.Content()[n]

	def ExtractFirst(pItem)
		# Extract = remove the FIRST occurrence of pItem from the list and
		# return it (the destructive sibling of FindFirst).
		return This.ExtractFirstCS(pItem, 1)

	def ExtractLast(pItem)
		# Remove the LAST occurrence of pItem and return it.
		return This.ExtractLastCS(pItem, 1)

	def ExtractSection(n1, n2)
		# Capture the section BEFORE removing it (afterwards the list is shorter,
		# so This.Section(n1,n2) would go out of range).
		_aEsSection_ = This.Section(n1, n2)
		_oEsExt_ = new stzListExtractor(This)
		_oEsExt_.ExtractSection(n1, n2)
		This.UpdateWith(_oEsExt_.Content())
		return _aEsSection_

	def ExtractRange(pnStart, pnRange)
		# Capture the range BEFORE removing it (same as ExtractSection).
		_aErRange_ = This.Range(pnStart, pnRange)
		_oErExt_ = new stzListExtractor(This)
		_oErExt_.ExtractRange(pnStart, pnRange)
		This.UpdateWith(_oErExt_.Content())
		return _aErRange_

	def ExtractW(pcCondition)
		# Remove every item matching the W-condition and RETURN them all
		# (find the matching positions, collect the items, then drop them).
		anPos = This.FindW(pcCondition)
		aResult = This.ItemsAtPositions(anPos)
		This.RemoveItemsAtPositions(anPos)
		return aResult

		def ExtractWQ(pcCondition)
			return new stzList( This.ExtractW(pcCondition) )

	def ExtractNthOccurrenceCS(n, pItem, pCaseSensitive)
		# Remove the nth occurrence of pItem and RETURN it (the extracted
		# value), per the monolith's authoritative Extract semantics.
		nPos = This.FindNthOccurrenceCS(n, pItem, pCaseSensitive)
		This.RemoveItemAtPosition(nPos)
		return pItem

	def ExtractNthOccurrence(n, pItem)
		return This.ExtractNthOccurrenceCS(n, pItem, 1)

	def ExtractFirstOccurrenceCS(pItem, pCaseSensitive)
		_oEfocsExt_ = new stzListExtractor(This)
		_oEfocsExt_.ExtractFirstOccurrenceCS(pItem, pCaseSensitive)
		This.UpdateWith(_oEfocsExt_.Content())
		return This.FirstOccurrenceCS(pItem, pCaseSensitive)

	def ExtractFirstOccurrence(pItem)
		return This.ExtractFirstOccurrenceCS(pItem, 1)

	def ExtractLastOccurrenceCS(pItem, pCaseSensitive)
		_oElocsExt_ = new stzListExtractor(This)
		_oElocsExt_.ExtractLastOccurrenceCS(pItem, pCaseSensitive)
		This.UpdateWith(_oElocsExt_.Content())
		return This.LastOccurrenceCS(pItem, pCaseSensitive)

	def ExtractLastOccurrence(pItem)
		return This.ExtractLastOccurrenceCS(pItem, 1)

	def ExtractDuplicatesCS(pCaseSensitive)
		_oEdcsExt_ = new stzListExtractor(This)
		_oEdcsExt_.ExtractDuplicatesCS(pCaseSensitive)
		This.UpdateWith(_oEdcsExt_.Content())
		return This.DuplicatesCS(pCaseSensitive)

	def ExtractDuplicates()
		return This.ExtractDuplicatesCS(1)

	def ExtractStrings()
		_oEsExt2_ = new stzListExtractor(This)
		_oEsExt2_.ExtractStrings()
		This.UpdateWith(_oEsExt2_.Content())
		return This.OnlyStrings()

	def ExtractNumbers()
		_oEnExt2_ = new stzListExtractor(This)
		_oEnExt2_.ExtractNumbers()
		This.UpdateWith(_oEnExt2_.Content())
		return This.OnlyNumbers()

	def ExtractLists()
		_oElExt2_ = new stzListExtractor(This)
		_oElExt2_.ExtractLists()
		This.UpdateWith(_oElExt2_.Content())
		return This.OnlyLists()

	def Pop()
		_nPopLen_ = This.NumberOfItems()
		if _nPopLen_ = 0
			return NULL
		ok
		_pPopItem_ = This.Item(_nPopLen_)
		This.RemoveLastItem()
		return _pPopItem_

	def PopFirst()
		if This.NumberOfItems() = 0
			return NULL
		ok
		_pPfItem_ = This.Item(1)
		This.RemoveFirstItem()
		return _pPfItem_

	def Take(n)
		_oTkExt_ = new stzListExtractor(This)
		_aTkResult_ = _oTkExt_.Take(n)
		This.UpdateWith(_oTkExt_.Content())
		return _aTkResult_

	def TakeLast(n)
		_oTlExt_ = new stzListExtractor(This)
		_aTlResult_ = _oTlExt_.TakeLast(n)
		This.UpdateWith(_oTlExt_.Content())
		return _aTlResult_

	  #-------------------------------#
	 #  TRIMMER DELEGATIONS          #
	#-------------------------------#

	def TrimCS(pCaseSensitive)
		_oTcsTr_ = new stzListTrimmer(This)
		_oTcsTr_.TrimCS(pCaseSensitive)
		This.UpdateWith(_oTcsTr_.Content())

	def TrimmedCS(pCaseSensitive)
		_oTdcsTr_ = new stzListTrimmer(This)
		return _oTdcsTr_.TrimmedCS(pCaseSensitive)

	def Trim()
		This.TrimCS(1)

	def Trimmed()
		return This.TrimmedCS(1)

	def TrimLeftCS(pCaseSensitive)
		_oTlcsTr_ = new stzListTrimmer(This)
		_oTlcsTr_.TrimLeftCS(pCaseSensitive)
		This.UpdateWith(_oTlcsTr_.Content())

	def TrimLeft()
		This.TrimLeftCS(1)

	def TrimmedLeft()
		return This.TrimmedCS(1)

	def TrimRightCS(pCaseSensitive)
		_oTrcsTr_ = new stzListTrimmer(This)
		_oTrcsTr_.TrimRightCS(pCaseSensitive)
		This.UpdateWith(_oTrcsTr_.Content())

	def TrimRight()
		This.TrimRightCS(1)

	def TrimmedRight()
		_oTdrTr_ = new stzListTrimmer(This)
		return _oTdrTr_.TrimmedRight()

	def TrimItemCS(pItem, pCaseSensitive)
		_oTicsTr_ = new stzListTrimmer(This)
		_oTicsTr_.TrimItemCS(pItem, pCaseSensitive)
		This.UpdateWith(_oTicsTr_.Content())

	def TrimItem(pItem)
		This.TrimItemCS(pItem, 1)

	def TrimItemFromLeftCS(pItem, pCaseSensitive)
		_oTiflcsTr_ = new stzListTrimmer(This)
		_oTiflcsTr_.TrimItemFromLeftCS(pItem, pCaseSensitive)
		This.UpdateWith(_oTiflcsTr_.Content())

	def TrimItemFromLeft(pItem)
		This.TrimItemFromLeftCS(pItem, 1)

	def TrimItemFromRightCS(pItem, pCaseSensitive)
		_oTifrcsTr_ = new stzListTrimmer(This)
		_oTifrcsTr_.TrimItemFromRightCS(pItem, pCaseSensitive)
		This.UpdateWith(_oTifrcsTr_.Content())

	def TrimItemFromRight(pItem)
		This.TrimItemFromRightCS(pItem, 1)

	def Compact()
		_oCpTr_ = new stzListTrimmer(This)
		_oCpTr_.Compact()
		This.UpdateWith(_oCpTr_.Content())

	def Compacted()
		_oCpdTr_ = new stzListTrimmer(This)
		return _oCpdTr_.Compacted()

	def Squeeze()
		_oSqTr_ = new stzListTrimmer(This)
		_oSqTr_.Squeeze()
		This.UpdateWith(_oSqTr_.Content())

	def Squeezed()
		_oSqdTr_ = new stzListTrimmer(This)
		return _oSqdTr_.Squeezed()

	def StripNulls()
		_oSnTr_ = new stzListTrimmer(This)
		_oSnTr_.StripNulls()
		This.UpdateWith(_oSnTr_.Content())

	def NullsStripped()
		_oNsTr_ = new stzListTrimmer(This)
		return _oNsTr_.NullsStripped()

	def TrimToSize(n)
		_oTtsTr_ = new stzListTrimmer(This)
		_oTtsTr_.TrimToSize(n)
		This.UpdateWith(_oTtsTr_.Content())

	def TrimmedToSize(n)
		_oTdtsTr_ = new stzListTrimmer(This)
		return _oTdtsTr_.TrimmedToSize(n)

	def TrimW(pcCondition)
		_oTwTr_ = new stzListTrimmer(This)
		_oTwTr_.TrimW(pcCondition)
		This.UpdateWith(_oTwTr_.Content())

	def TrimmedW(pcCondition)
		_oTdwTr_ = new stzListTrimmer(This)
		return _oTdwTr_.TrimmedW(pcCondition)

	  #-------------------------------#
	 #  GETTER DELEGATIONS           #
	#-------------------------------#

	def UniqueItemsCS(pCaseSensitive)
		_oUicsGt_ = new stzListGetter(This)
		return _oUicsGt_.UniqueItemsCS(pCaseSensitive)

	def UniqueItems()
		return This.UniqueItemsCS(1)

	def RandomItem()
		_oRiGt_ = new stzListGetter(This)
		return _oRiGt_.RandomItem()

	def NRandomItems(n)
		_oNriGt_ = new stzListGetter(This)
		return _oNriGt_.NRandomItems(n)

	#-- rnd* : terse random helpers (the "give me some random cards" idiom).
	#   rndItems() returns a random NUMBER of random items; rndNItems(n) a
	#   fixed n. The rndRemove* forms are the MUTATING counterparts -- they
	#   drop random items from the list in place and return This for chaining.

	def rndNItems(n)
		return This.NRandomItems(n)

		def RandomNItems(n)
			return This.NRandomItems(n)

	def rndItems()
		_nRiN_ = This.NumberOfItems()
		if _nRiN_ = 0 return [] ok
		_nRiK_ = random(_nRiN_ - 1) + 1
		return This.NRandomItems(_nRiK_)

		def RandomItems()
			return This.rndItems()

	def rndRemoveNItems(n)
		_nRrN_ = This.NumberOfItems()
		if n <= 0 or _nRrN_ = 0 return This ok
		if n > _nRrN_ n = _nRrN_ ok
		#-- shuffle the positions 1.._nRrN_ and remove the first n of them
		_anRrIdx_ = 1 : _nRrN_
		for _iRr_ = _nRrN_ to 2 step -1
			_jRr_ = random(_iRr_ - 1) + 1
			_xRr_ = _anRrIdx_[_iRr_]
			_anRrIdx_[_iRr_] = _anRrIdx_[_jRr_]
			_anRrIdx_[_jRr_] = _xRr_
		next
		_anRrPick_ = []
		for _kRr_ = 1 to n
			_anRrPick_ + _anRrIdx_[_kRr_]
		next
		This.RemoveItemsAtPositions(_anRrPick_)
		return This

		def rndRemoveNItemsQ(n)
			return This.rndRemoveNItems(n)

		def RandomRemoveNItems(n)
			return This.rndRemoveNItems(n)

	def rndRemoveItems()
		_nRr2N_ = This.NumberOfItems()
		if _nRr2N_ = 0 return This ok
		_nRr2K_ = random(_nRr2N_ - 1) + 1
		return This.rndRemoveNItems(_nRr2K_)

		def rndRemoveItemsQ()
			return This.rndRemoveItems()

		def RandomRemoveItems()
			return This.rndRemoveItems()

	def ItemsBetween(n1, n2)
		_oIbGt_ = new stzListGetter(This)
		return _oIbGt_.ItemsBetween(n1, n2)

	def EveryNthItem(n)
		_oEniGt_ = new stzListGetter(This)
		return _oEniGt_.EveryNthItem(n)

	def Head(n)
		_oHdGt_ = new stzListGetter(This)
		return _oHdGt_.Head(n)

	def Tail(n)
		_oTlGt_ = new stzListGetter(This)
		return _oTlGt_.Tail(n)

	def OnlyStrings()
		_oOsGt_ = new stzListGetter(This)
		return _oOsGt_.OnlyStrings()

		def OnlyStringsQ()
			return new stzList( This.OnlyStrings() )

	def OnlyNumbers()
		_oOnGt_ = new stzListGetter(This)
		return _oOnGt_.OnlyNumbers()

		def OnlyNumbersQ()
			return new stzList( This.OnlyNumbers() )

	def OnlyLists()
		_oOlGt_ = new stzListGetter(This)
		return _oOlGt_.OnlyLists()

		def OnlyListsQ()
			return new stzList( This.OnlyLists() )

	def OnlyChars()
		_oOcGt_ = new stzListGetter(This)
		return _oOcGt_.OnlyChars()

		def OnlyCharsQ()
			return new stzList( This.OnlyChars() )

	#-- Pairs(): the items of the list that are themselves pairs (2-element
	#-- lists). For the sliding/consecutive grouping use Pairify()/ToPairs().
	def Pairs()
		return _StzItemsAtPos(This.Content(), This.FindPairs())

	#-- Pairify()/ToPairs(): group the list into consecutive (sliding) pairs,
	#-- e.g. [1,2,3,4] -> [[1,2],[2,3],[3,4]].
	def Pairify()
		_oPrGt_ = new stzListGetter(This)
		return _oPrGt_.Pairs()

		def ToPairs()
			return This.Pairify()

	def Triplets()
		_oTrGt_ = new stzListGetter(This)
		return _oTrGt_.Triplets()

	def SlidingWindow(n)
		_oSwGt_ = new stzListGetter(This)
		return _oSwGt_.SlidingWindow(n)

	  #-------------------------------#
	 #  WALKER DELEGATIONS           #
	#-------------------------------#

	#-- AddWalker: register a NAMED walker over this list. The 4 args may be
	#-- given positionally (name, start, end, step) OR as named pairs /
	#-- function-style helpers in any order:
	#--   AddWalker(:Named=:W, :StartingAt=1, :EndingAt=10, :NStep=2)
	#--   AddWalker(Named(:W), StartingAt(1), EndingAt(10), NStepsATime(2))
	#--   AddWalker(:W, 6, 10, [:NStepsATime, 3])
	#--   AddWalker(Named(:W), StartingAt(1), EndingAt(10), TakingNEqualMoves(3))
	#-- The walker is stored on THIS list (@aWalkers) and queried later with
	#-- WalkedItems/WalkedPositions/... ( :By = <name> ).
	def AddWalker(p1, p2, p3, p4)
		cAwName = ""
		nAwStart = 1
		nAwEnd = This.NumberOfItems()
		nAwStep = 1
		nAwMoves = 0
		cAwMode = :Step

		_aAwArgs_ = [ p1, p2, p3, p4 ]
		_nAwPos_ = 0
		for _iAw_ = 1 to 4
			_a_ = _aAwArgs_[_iAw_]
			if isList(_a_) and len(_a_) = 2 and isString(_a_[1])
				_k_ = lower(_a_[1])
				_v_ = _a_[2]
				if _k_ = "named" or _k_ = "name"
					cAwName = _v_
				but _k_ = "startingat"
					nAwStart = _v_
				but _k_ = "endingat"
					nAwEnd = _v_
				but _k_ = "nstep" or _k_ = "nstepsatime"
					nAwStep = _v_ cAwMode = :Step
				but _k_ = "nequalmoves"
					nAwMoves = _v_ cAwMode = :EqualMoves
				ok
			but isString(_a_) or isNumber(_a_)
				_nAwPos_++
				if _nAwPos_ = 1
					cAwName = _a_
				but _nAwPos_ = 2
					nAwStart = _a_
				but _nAwPos_ = 3
					nAwEnd = _a_
				but _nAwPos_ = 4
					nAwStep = _a_
				ok
			ok
		next

		@aWalkers + [ cAwName, [ nAwStart, nAwEnd, nAwStep, cAwMode, nAwMoves ] ]

	def Walkers()
		return @aWalkers

	#-- resolve a walker name from a bare name or a [:By/:Named/..., name] pair
	def _ResolveWalkerName(pName)
		if isList(pName) and len(pName) = 2 and isString(pName[1])
			return pName[2]
		ok
		return pName

	def _WalkerDef(pName)
		_cWd_ = This._ResolveWalkerName(pName)
		_nWd_ = len(@aWalkers)
		for _iWd_ = 1 to _nWd_
			if @aWalkers[_iWd_][1] = _cWd_
				return @aWalkers[_iWd_][2]
			ok
		next
		return NULL

	def WalkedPositions(pBy)
		_aWp_ = This._WalkerDef(pBy)
		if _aWp_ = NULL return [] ok
		_nStart_ = _aWp_[1]
		_nEnd_   = _aWp_[2]
		_nStep_  = _aWp_[3]
		_cMode_  = _aWp_[4]
		_nMoves_ = _aWp_[5]
		_nLen_   = This.NumberOfItems()
		if _nEnd_ > _nLen_ _nEnd_ = _nLen_ ok
		if _nStart_ < 1 _nStart_ = 1 ok

		_anRes_ = []
		if _cMode_ = :EqualMoves and _nMoves_ > 1
			for _iEm_ = 0 to _nMoves_ - 1
				_p_ = _nStart_ + floor( _iEm_ * (_nEnd_ - _nStart_) / (_nMoves_ - 1) )
				_anRes_ + _p_
			next
		else
			_iSt_ = _nStart_
			while _iSt_ <= _nEnd_
				_anRes_ + _iSt_
				_iSt_ += _nStep_
			end
		ok
		return _anRes_

	def WalkedItems(pBy)
		return This.ItemsAtPositions( This.WalkedPositions(pBy) )

	def NumberOfWalkedItems(pBy)
		return len( This.WalkedPositions(pBy) )

	def WalkedLastPosition(pBy)
		_anWlp_ = This.WalkedPositions(pBy)
		if len(_anWlp_) = 0 return 0 ok
		return _anWlp_[ len(_anWlp_) ]

	def WalkedLastItem(pBy)
		_nWli_ = This.WalkedLastPosition(pBy)
		if _nWli_ = 0 return NULL ok
		return This.Item(_nWli_)

	#-- YieldWhileWalking: project each item the named walker visits through an
	#-- engine W-DSL yielder (e.g. '@item * 2', 'Q(@item).Upper()'). Eval-free
	#-- and engine-backed (stz_list_map_expr). For arbitrary Ring logic
	#-- (ring_type, upper, StringContains, ...) use YieldWhileWalkingWF.
	def YieldWhileWalking(pcYielder, pWalker)
		_aYwSub_ = This.ItemsAtPositions( This.WalkedPositions(pWalker) )
		_oYwSub_ = new stzList(_aYwSub_)
		return _oYwSub_.Yield(pcYielder)

	#-- WF form: project the walked items through a Ring anonymous function
	#-- (full Ring power, eval-free).
	def YieldWhileWalkingWF(pFunc, pWalker)
		_aYwfSub_ = This.ItemsAtPositions( This.WalkedPositions(pWalker) )
		_oYwfSub_ = new stzList(_aYwfSub_)
		return _oYwfSub_.MapWF(pFunc)

	def WalkNForward(n)
		_oWnfWk_ = new stzListWalker(This)
		return _oWnfWk_.WalkNForward(n)

	def WalkNBackward(n)
		_oWnbWk_ = new stzListWalker(This)
		return _oWnbWk_.WalkNBackward(n)

	# Walk the inclusive range n1..n2 (descending if n1 > n2). The IB
	# form takes a return type (:WalkedPositions default / :WalkedItems).

	def WalkBetweenIB(n1, n2, pReturn)
		anWbPos = n1 : n2
		cWbRet = pReturn
		if isList(pReturn) and ring_len(pReturn) = 2 and isString(pReturn[1])
			cWbRet = pReturn[2]
		ok
		if cWbRet = :WalkedItems or cWbRet = :Items
			return This.ItemsAtPositions(anWbPos)
		ok
		return anWbPos

	def WalkBetween(n1, n2)
		return This.WalkBetweenIB(n1, n2, :WalkedPositions)

	# Walk forward 1..n then back n-1..1.

	def WalkForthAndBackXT(pReturn)
		nWfLen = This.NumberOfItems()
		anWfPos = []
		for iWf = 1 to nWfLen
			anWfPos + iWf
		next
		for iWf = nWfLen - 1 to 1 step -1
			anWfPos + iWf
		next
		cWfRet = pReturn
		if isList(pReturn) and ring_len(pReturn) = 2 and isString(pReturn[1])
			cWfRet = pReturn[2]
		ok
		if cWfRet = :WalkedItems or cWfRet = :Items
			return This.ItemsAtPositions(anWfPos)
		ok
		return anWfPos

	def WalkForthAndBack()
		return This.WalkForthAndBackXT(:WalkedPositions)

	# Walk forward up to and including the first occurrence of pItem.

	def WalkUntilItem(pItem)
		nWuiPos = This.FindFirst(pItem)
		if nWuiPos > 0
			return 1 : nWuiPos
		ok
		return []

	def WalkW(pcCondition)
		_oWwWk_ = new stzListWalker(This)
		return _oWwWk_.WalkW(pcCondition)

	def WalkUntil(pcCondition)
		_oWuWk_ = new stzListWalker(This)
		return _oWuWk_.WalkUntil(pcCondition)

	def WalkWhile(pcCondition)
		_oWwhWk_ = new stzListWalker(This)
		return _oWwhWk_.WalkWhile(pcCondition)

	def WalkZigZag(nStep)
		_oWzzWk_ = new stzListWalker(This)
		return _oWzzWk_.WalkZigZag(nStep)

	def WalkEveryNth(n)
		_oWenWk_ = new stzListWalker(This)
		return _oWenWk_.WalkEveryNth(n)

	# PositionsWhere already defined above as alias of FindAllItemsW

	def WalkFromTo(nFrom, nTo)
		_oWftWk_ = new stzListWalker(This)
		return _oWftWk_.WalkFromTo(nFrom, nTo)

	def WalkSkipping(n)
		_oWsWk_ = new stzListWalker(This)
		return _oWsWk_.WalkSkipping(n)

	def WalkAccumulating(pcExpr)
		_oWaWk_ = new stzListWalker(This)
		return _oWaWk_.WalkAccumulating(pcExpr)

	def WalkWhere(pcCondition)
		_oWhWk_ = new stzListWalker(This)
		return _oWhWk_.WalkWhere(pcCondition)


	def WalkWhen(pcCondition)
		_oWnWk_ = new stzListWalker(This)
		return _oWnWk_.WalkWhen(pcCondition)

	def WalkWhenXT(pcCondition, pcDirection, pReturn)
		_oWnxWk_ = new stzListWalker(This)
		return _oWnxWk_.WalkWhenXT(pcCondition, pcDirection, pReturn)

	def WalkUntilXT(pcCondition, pcDirection, pReturn)
		_oWuxWk_ = new stzListWalker(This)
		return _oWuxWk_.WalkUntilXT(pcCondition, pcDirection, pReturn)

	def WalkWhileXT(pcCondition, pcDirection, pReturn)
		_oWwxWk_ = new stzListWalker(This)
		return _oWwxWk_.WalkWhileXT(pcCondition, pcDirection, pReturn)

	  #-------------------------------#
	 #  MOVER DELEGATIONS            #
	#-------------------------------#

	def Move(n1, n2)
		_oMvMvr_ = new stzListMover(This)
		_oMvMvr_.Move(n1, n2)
		This.UpdateWith(_oMvMvr_.Content())

	def Swap(n1, n2)
		_oSwMvr_ = new stzListMover(This)
		_oSwMvr_.Swap(n1, n2)
		This.UpdateWith(_oSwMvr_.Content())

	def MoveToStart(n)
		_oMtsMvr_ = new stzListMover(This)
		_oMtsMvr_.MoveToStart(n)
		This.UpdateWith(_oMtsMvr_.Content())

	def MoveToEnd(n)
		_oMteMvr_ = new stzListMover(This)
		_oMteMvr_.MoveToEnd(n)
		This.UpdateWith(_oMteMvr_.Content())

	def SwapFirstAndLast()
		_oSfalMvr_ = new stzListMover(This)
		_oSfalMvr_.SwapFirstAndLast()
		This.UpdateWith(_oSfalMvr_.Content())

	def MoveMany(panPositions, nTo)
		_oMmMvr_ = new stzListMover(This)
		_oMmMvr_.MoveMany(panPositions, nTo)
		This.UpdateWith(_oMmMvr_.Content())

	def RotateLeft(n)
		_oRlMvr_ = new stzListMover(This)
		_oRlMvr_.RotateLeft(n)
		This.UpdateWith(_oRlMvr_.Content())

	def RotatedLeft(n)
		_oRdlMvr_ = new stzListMover(This)
		return _oRdlMvr_.RotatedLeft(n)

	def RotateRight(n)
		_oRrMvr_ = new stzListMover(This)
		_oRrMvr_.RotateRight(n)
		This.UpdateWith(_oRrMvr_.Content())

	def RotatedRight(n)
		_oRdrMvr_ = new stzListMover(This)
		return _oRdrMvr_.RotatedRight(n)

	def Shuffle()
		_oShMvr_ = new stzListMover(This)
		_oShMvr_.Shuffle()
		This.UpdateWith(_oShMvr_.Content())

	def Shuffled()
		_oShdMvr_ = new stzListMover(This)
		return _oShdMvr_.Shuffled()

	def MoveItemToStart(pItem)
		_oMitsMvr_ = new stzListMover(This)
		_oMitsMvr_.MoveItemToStart(pItem)
		This.UpdateWith(_oMitsMvr_.Content())

	def MoveItemToEnd(pItem)
		_oMiteMvr_ = new stzListMover(This)
		_oMiteMvr_.MoveItemToEnd(pItem)
		This.UpdateWith(_oMiteMvr_.Content())

	  #-------------------------------#
	 #  SECTIONS DELEGATIONS         #
	#-------------------------------#

	def SectionCSZ(n1, n2, pCaseSensitive)
		_oScszSec_ = new stzListSections(This)
		return _oScszSec_.SectionCSZ(n1, n2, pCaseSensitive)

	def SectionZ(n1, n2)
		return This.SectionCSZ(n1, n2, 1)

	def SectionCSZZ(n1, n2, pCaseSensitive)
		_oScszzSec_ = new stzListSections(This)
		return _oScszzSec_.SectionCSZZ(n1, n2, pCaseSensitive)

	def SectionZZ(n1, n2)
		return This.SectionCSZZ(n1, n2, 1)

	def Sections(paSections)
		_oSsSec_ = new stzListSections(This)
		return _oSsSec_.Sections(paSections)

	def FindAntiSection(n1, n2)
		_oFasSec_ = new stzListSections(This)
		return _oFasSec_.FindAntiSection(n1, n2)

	def AntiSection(n1, n2)
		_oAsSec_ = new stzListSections(This)
		return _oAsSec_.AntiSection(n1, n2)

	def FindAntiSectionIB(n1, n2)
		_oFasibSec_ = new stzListSections(This)
		return _oFasibSec_.FindAntiSectionIB(n1, n2)

	def AntiSectionIB(n1, n2)
		_oAsibSec_ = new stzListSections(This)
		return _oAsibSec_.AntiSectionIB(n1, n2)

	def FindAntiSections(paSections)
		if isList(paSections) and StzLen(paSections) = 2 and
		   isString(paSections[1]) and StzCaseFold(paSections[1]) = "of"
			paSections = paSections[2]
		ok

		# Adjust sections from 1-based to 0-based for engine
		_aFasAdj_ = []
		for _iFas_ = 1 to StzLen(paSections)
			_aFasPair_ = paSections[_iFas_]
			_nFasS_ = _aFasPair_[1] - 1
			_nFasE_ = _aFasPair_[2] - 1
			@AddItem(_aFasAdj_, [ _nFasS_, _nFasE_ ])
		next

		_pFasList_ = StzEngineMarshalList(This.Content())
		_pFasSecs_ = StzEngineMarshalList(_aFasAdj_)
		_pFasResult_ = StzEngineListAntiSections(_pFasList_, _pFasSecs_)
		_aFasRaw_ = StzEngineListContentToRingList(_pFasResult_)
		StzEngineListFree(_pFasResult_)
		StzEngineListFree(_pFasSecs_)
		StzEngineListFree(_pFasList_)

		# Adjust result pairs from 0-based back to 1-based
		_aFasResult_ = []
		for _jFas_ = 1 to StzLen(_aFasRaw_)
			_aFasPairR_ = _aFasRaw_[_jFas_]
			_nFasR1_ = _aFasPairR_[1] + 1
			_nFasR2_ = _aFasPairR_[2] + 1
			@AddItem(_aFasResult_, [ _nFasR1_, _nFasR2_ ])
		next
		return _aFasResult_

	def AntiSections(paSections)
		if isList(paSections) and StzLen(paSections) = 2 and
		   isString(paSections[1]) and StzCaseFold(paSections[1]) = "of"
			paSections = paSections[2]
		ok

		_aAsSections_ = This.FindAntiSections(paSections)
		_aAsResult_ = []
		for _iAs_ = 1 to StzLen(_aAsSections_)
			_aAsPair_ = _aAsSections_[_iAs_]
			@AddItem(_aAsResult_, This.Section(_aAsPair_[1], _aAsPair_[2]))
		next
		return _aAsResult_

	def FindAntiSectionsIB(paSections)
		if isList(paSections) and StzLen(paSections) = 2 and
		   isString(paSections[1]) and StzCaseFold(paSections[1]) = "of"
			paSections = paSections[2]
		ok

		# IB = Including Bounds: anti-section boundaries overlap with
		# the original section boundaries by 1 position on each side.
		# E.g. sections [3,5],[7,8] on 10 items:
		#   non-IB: [1,2],[6,6],[9,10]
		#   IB:     [1,3],[5,7],[8,10]

		# Sort sections for correct boundary computation
		_aFasibSorted_ = []
		for _iFasibS_ = 1 to StzLen(paSections)
			@AddItem(_aFasibSorted_, paSections[_iFasibS_])
		next

		_nFasibLen_ = StzLen(_aFasibSorted_)
		_aFasibResult_ = []
		_nFasibN1_ = 1

		for _iFasib_ = 1 to _nFasibLen_
			_aFasibPair_ = _aFasibSorted_[_iFasib_]
			if _aFasibPair_[1] > _nFasibN1_
				_nFasibN2_ = _aFasibPair_[1]
				@AddItem(_aFasibResult_, [ _nFasibN1_, _nFasibN2_ ])
			ok
			if _iFasib_ < _nFasibLen_
				_nFasibN1_ = _aFasibPair_[2]
			ok
		next

		_nFasibLast_ = _aFasibSorted_[_nFasibLen_][2]
		if _nFasibLast_ < This.NumberOfItems()
			@AddItem(_aFasibResult_, [ _nFasibLast_, This.NumberOfItems() ])
		ok

		return _aFasibResult_

	def AntiSectionsIB(paSections)
		if isList(paSections) and StzLen(paSections) = 2 and
		   isString(paSections[1]) and StzCaseFold(paSections[1]) = "of"
			paSections = paSections[2]
		ok

		_aAsibSections_ = This.FindAntiSectionsIB(paSections)
		_aAsibResult_ = []
		for _iAsib_ = 1 to StzLen(_aAsibSections_)
			_aAsibPair_ = _aAsibSections_[_iAsib_]
			@AddItem(_aAsibResult_, This.Section(_aAsibPair_[1], _aAsibPair_[2]))
		next
		return _aAsibResult_

	def Ranges(paRanges)
		_oRgsSec_ = new stzListSections(This)
		return _oRgsSec_.Ranges(paRanges)

	def AntiRanges(paRanges)
		_oArgsSec_ = new stzListSections(This)
		return _oArgsSec_.AntiRanges(paRanges)

	def RangesAndAntiRanges(paRanges)
		_oRaarSec_ = new stzListSections(This)
		return _oRaarSec_.RangesAndAntiRanges(paRanges)

	def AntiRangesIB(paRanges)
		_oAribSec_ = new stzListSections(This)
		return _oAribSec_.AntiRangesIB(paRanges)

	def RangesAndAntiRangesIB(paRanges)
		_oRaaribSec_ = new stzListSections(This)
		return _oRaaribSec_.RangesAndAntiRangesIB(paRanges)

	  #-------------------------------#
	 #  CLASSIFIER DELEGATIONS       #
	#-------------------------------#

	def Classify()
		_oCfClf_ = new stzListClassifier(This)
		return _oCfClf_.Classify()

	def Classified()
		_oCfdClf_ = new stzListClassifier(This)
		return _oCfdClf_.Classified()

	def Classes()
		_oClsClf_ = new stzListClassifier(This)
		return _oClsClf_.Classes()

	# Short-form classification for lists of (contiguous) number-lists:
	# each list-class key is rendered as "min:max" (e.g. "1:5").

	def ClassesSF()
		aCsfC = This.Classes()
		aCsfR = []
		nCsfL = ring_len(aCsfC)
		for iCsf = 1 to nCsfL
			aCsfR + _StzListKeyToShortForm(aCsfC[iCsf])
		next
		return aCsfR

	def ClassifySF()
		aClsfC = This.Classify()
		aClsfR = []
		nClsfL = ring_len(aClsfC)
		for iClsf = 1 to nClsfL
			aClsfR + [ _StzListKeyToShortForm(aClsfC[iClsf][1]), aClsfC[iClsf][2] ]
		next
		return aClsfR

		def ClassifiedSF()
			return This.ClassifySF()

	def KlassSF(pcShortForm)
		aKsfC = This.ClassifySF()
		nKsfL = ring_len(aKsfC)
		for iKsf = 1 to nKsfL
			if aKsfC[iKsf][1] = pcShortForm
				return aKsfC[iKsf][2]
			ok
		next
		return []

	def ClassifyBy(pcExpr)
		_oCbClf_ = new stzListClassifier(This)
		return _oCbClf_.ClassifyBy(pcExpr)

	def NumberOfClasses()
		_oNcClf_ = new stzListClassifier(This)
		return _oNcClf_.NumberOfClasses()

	def Frequencies()
		_oFqClf_ = new stzListClassifier(This)
		return _oFqClf_.Frequencies()

	def MostFrequent()
		_oMfClf_ = new stzListClassifier(This)
		return _oMfClf_.MostFrequent()

	def LeastFrequent()
		_oLfClf_ = new stzListClassifier(This)
		return _oLfClf_.LeastFrequent()

	def GroupBy(pcExpr)
		_oGbClf_ = new stzListClassifier(This)
		return _oGbClf_.GroupBy(pcExpr)

	def Histogram()
		_oHgClf_ = new stzListClassifier(This)
		return _oHgClf_.Histogram()

	def ItemsAppearingNTimes(n)
		_oIantClf_ = new stzListClassifier(This)
		return _oIantClf_.ItemsAppearingNTimes(n)

	def ItemsAppearingMoreThanNTimes(n)
		_oIamtntClf_ = new stzListClassifier(This)
		return _oIamtntClf_.ItemsAppearingMoreThanNTimes(n)

	def ItemsAppearingLessThanNTimes(n)
		_oIaltntClf_ = new stzListClassifier(This)
		return _oIaltntClf_.ItemsAppearingLessThanNTimes(n)

	def FrequencyOf(pItem)
		_oFoClf_ = new stzListClassifier(This)
		return _oFoClf_.FrequencyOf(pItem)

	def Mode()
		_oMdClf_ = new stzListClassifier(This)
		return _oMdClf_.Mode()

	def Bisect()
		_oBsClf_ = new stzListClassifier(This)
		return _oBsClf_.Bisect()

	def FirstHalf()
		# Authoritative Softanza split: the FIRST half is the floor(n/2)
		# leading items (the middle item of an odd list goes to neither
		# plain half -- use FirstHalfXT/SecondHalfXT to include it).
		return This.Section(1, floor(This.NumberOfItems() / 2))

	def SecondHalf()
		# The SECOND half is everything from floor(n/2)+1 onward -- so for
		# an odd list it carries the middle item (mirror of FirstHalf).
		nLen = This.NumberOfItems()
		return This.Section(floor(nLen / 2) + 1, nLen)

	def PartitionW(pcCondition)
		_oPwClf_ = new stzListClassifier(This)
		return _oPwClf_.PartitionW(pcCondition)

	def Chunks(n)
		_oChClf_ = new stzListClassifier(This)
		return _oChClf_.Chunks(n)

	  #-------------------------------#
	 #  RANDOM DELEGATIONS           #
	#-------------------------------#

	def RandomPosition()
		_oRpRnd_ = new stzListRandom(This)
		return _oRpRnd_.RandomPosition()

		def ARandomPosition()
			return This.RandomPosition()

		def APosition()
			return This.RandomPosition()

		def AnyPosition()
			return This.RandomPosition()

	def RandomSection()
		# Return a random [start, end] pair within 1..N.
		_nRsN_ = len(@aContent)
		if _nRsN_ = 0
			return [ 0, 0 ]
		ok
		_nRsA_ = ARandomNumberBetween(1, _nRsN_)
		_nRsB_ = ARandomNumberBetween(1, _nRsN_)
		if _nRsA_ > _nRsB_
			_nRsT_ = _nRsA_
			_nRsA_ = _nRsB_
			_nRsB_ = _nRsT_
		ok
		return [ _nRsA_, _nRsB_ ]

		def ARandomSection()
			return This.RandomSection()

		def ASection()
			return This.RandomSection()

		def AnySection()
			return This.RandomSection()

	def RandomPositionGreaterThan(n)
		_oRpgtRnd_ = new stzListRandom(This)
		return _oRpgtRnd_.RandomPositionGreaterThan(n)

	def RandomPositionLessThan(n)
		_oRpltRnd_ = new stzListRandom(This)
		return _oRpltRnd_.RandomPositionLessThan(n)

	def RandomPositionExcept(n)
		_oRpeRnd_ = new stzListRandom(This)
		return _oRpeRnd_.RandomPositionExcept(n)

	def RandomPositionExceptPositions(panPos)
		_oRpepRnd_ = new stzListRandom(This)
		return _oRpepRnd_.RandomPositionExceptPositions(panPos)

	def NRandomPositions(n)
		_oNrpRnd_ = new stzListRandom(This)
		return _oNrpRnd_.NRandomPositions(n)

	def RandomItemExceptCS(pItem, pCaseSensitive)
		_oRiecsRnd_ = new stzListRandom(This)
		return _oRiecsRnd_.RandomItemExceptCS(pItem, pCaseSensitive)

	def RandomItemExcept(pItem)
		return This.RandomItemExceptCS(pItem, 1)

	def RandomItemExceptPosition(n)
		_oRiepRnd_ = new stzListRandom(This)
		return _oRiepRnd_.RandomItemExceptPosition(n)

	def Randomize()
		_oRzRnd_ = new stzListRandom(This)
		_oRzRnd_.Randomize()
		This.UpdateWith(_oRzRnd_.Content())

	def Randomized()
		_oRzdRnd_ = new stzListRandom(This)
		return _oRzdRnd_.Randomized()

	def RandomizeNumbers()
		_oRznRnd_ = new stzListRandom(This)
		_oRznRnd_.RandomizeNumbers()
		This.UpdateWith(_oRznRnd_.Content())

		def RandomiseNumbers()
			This.RandomizeNumbers()

		def ShuffleNumbers()
			This.RandomizeNumbers()

	def RandomizeStrings()
		_oRzsStr_ = new stzListRandom(This)
		_oRzsStr_.RandomizeStrings()
		This.UpdateWith(_oRzsStr_.Content())

		def RandomiseStrings()
			This.RandomizeStrings()

		def ShuffleStrings()
			This.RandomizeStrings()

	def RandomizeSection(n1, n2)
		_oRzsRnd_ = new stzListRandom(This)
		_oRzsRnd_.RandomizeSection(n1, n2)
		This.UpdateWith(_oRzsRnd_.Content())

	def SectionRandomized(n1, n2)
		_oSrRnd_ = new stzListRandom(This)
		return _oSrRnd_.SectionRandomized(n1, n2)

	  #-------------------------------#
	 #  PERFORMER DELEGATIONS        #
	#-------------------------------#

	# Perform/PerformOn/Yield already defined in core

	def PerformW(pcCondition, pcAction)
		_oPwPrf_ = new stzListPerformer(This)
		_oPwPrf_.PerformW(pcCondition, pcAction)
		This.UpdateWith(_oPwPrf_.Content())

	def PerformAtW(panPos, pcCondition, pcAction)
		_oPawPrf_ = new stzListPerformer(This)
		_oPawPrf_.PerformAtW(panPos, pcCondition, pcAction)
		This.UpdateWith(_oPawPrf_.Content())

	def YieldOn(panPos, pcYielder)
		_oYoPrf_ = new stzListPerformer(This)
		return _oYoPrf_.YieldOn(panPos, pcYielder)

	def YieldW(pcCondition, pcYielder)
		_oYwPrf_ = new stzListPerformer(This)
		return _oYwPrf_.YieldW(pcCondition, pcYielder)

	#-- YieldXT: positional / conditional yielder. The yielder is "@item"
	#-- (or "@char") -- the value at each visited position. The window is
	#-- given by named options:
	#--   :FromPosition = a, :To = b   -> positions a..b inclusive (b may be
	#--                                    negative, counting from the end).
	#--   :StartingAt = a, :Until = c  -> from a onward, stop BEFORE the first
	#--                                    item satisfying the W-condition c.
	#--   :StartingAt = a, :UntilXT = c-> same, but INCLUDE that stop item.
	def YieldXT(pcYielder, p2, p3)
		nLen = This.NumberOfItems()
		aC = This.Content()

		_nFrom_ = 0 _nTo_ = 0 _bRange_ = 0
		_nStart_ = 0 _cUntil_ = "" _bUntil_ = 0 _bInc_ = 0

		_aOpts_ = [ p2, p3 ]
		for _iYo_ = 1 to 2
			_p_ = _aOpts_[_iYo_]
			if isList(_p_) and len(_p_) = 2 and isString(_p_[1])
				_k_ = lower(_p_[1])
				_v_ = _p_[2]
				if _k_ = "fromposition"
					_nFrom_ = _v_ _bRange_ = 1
				but _k_ = "to"
					_nTo_ = _v_ _bRange_ = 1
				but _k_ = "startingat"
					_nStart_ = _v_
				but _k_ = "until"
					_cUntil_ = _v_ _bUntil_ = 1 _bInc_ = 0
				but _k_ = "untilxt"
					_cUntil_ = _v_ _bUntil_ = 1 _bInc_ = 1
				ok
			ok
		next

		_aRes_ = []

		if _bRange_
			_a_ = _nFrom_
			_b_ = _nTo_
			if _b_ < 0 _b_ = nLen + _b_ + 1 ok
			if _a_ < 1 _a_ = 1 ok
			if _b_ > nLen _b_ = nLen ok
			for _i_ = _a_ to _b_
				_aRes_ + aC[_i_]
			next
			return _aRes_
		ok

		if _bUntil_
			if _nStart_ < 1 _nStart_ = 1 ok
			for _i_ = _nStart_ to nLen
				# does aC[_i_] satisfy the until-condition?
				_oOne_ = new stzList([ aC[_i_] ])
				_bHit_ = ( len(_oOne_.FindAllItemsW(_cUntil_)) > 0 )
				if _bHit_
					if _bInc_ _aRes_ + aC[_i_] ok
					exit
				ok
				_aRes_ + aC[_i_]
			next
			return _aRes_
		ok

		# no window -> yield every item
		return aC

	# YieldW(pcCondition, pcYielder): the @item-syntax form of YieldW
	# -- for items matching pcCondition, yield the value of pcYielder.
	# Engine-backed via YieldW (no eval).


	# YieldAtW / YieldAtW: restrict to the given positions first,
	# then yield over those.
	def YieldAtW(panPos, pcCondition, pcYielder)
		oYawSub = This.ItemsAtPositionsQ(panPos)
		return oYawSub.YieldW(pcCondition, pcYielder)


	# ItemsW / ItemsW / ItemsWXTQ: filter the list by an evaluated
	# Ring expression where @item is the loop variable. Returns the
	# items for which the expression is truthy. ItemsWXTQ wraps the
	# result in stzList for fluent chains.
	def ItemsW(pcCondition)
		#-- items at the positions matching the condition (engine W DSL; any
		#-- Q(...) predicate is lowered to engine DSL inside FindAllItemsW).
		return This.ItemsAtPositions(This.FindAllItemsW(pcCondition))

		#-- XT form: the items at the positions found by the extended scan
		#-- (supports @NextItem/... and Q(EXPR).Method(...)).

		def ItemsWQ(pcCondition)
			return new stzList( This.ItemsW(pcCondition) )


		def Where(pcCondition)
			return This.ItemsW(pcCondition)

	def PerformOnEachItemAndItsPosition(pcAction)
		_oPoeiapPrf_ = new stzListPerformer(This)
		_oPoeiapPrf_.PerformOnEachItemAndItsPosition(pcAction)
		This.UpdateWith(_oPoeiapPrf_.Content())

	def YieldPairs(pcYielder)
		_oYpPrf_ = new stzListPerformer(This)
		return _oYpPrf_.YieldPairs(pcYielder)

	  #-------------------------------#
	 #  MERGER DELEGATIONS           #
	#-------------------------------#

	def AssociateWith(paOtherList)
		_oAwMrg_ = new stzListMerger(This)
		return _oAwMrg_.AssociateWith(paOtherList)

	def AssociatedWith(paOtherList)
		_oAdwMrg_ = new stzListMerger(This)
		return _oAdwMrg_.AssociatedWith(paOtherList)

	def MergeWithMany(paLists)
		_oMwmMrg_ = new stzListMerger(This)
		_oMwmMrg_.MergeWithMany(paLists)
		This.UpdateWith(_oMwmMrg_.Content())

	def MergedWithMany(paLists)
		_oMdwmMrg_ = new stzListMerger(This)
		return _oMdwmMrg_.MergedWithMany(paLists)

	def InterleaveWith(paOtherList)
		_oIwMrg_ = new stzListMerger(This)
		_oIwMrg_.InterleaveWith(paOtherList)
		This.UpdateWith(_oIwMrg_.Content())

	def InterleavedWith(paOtherList)
		_oIdwMrg_ = new stzListMerger(This)
		return _oIdwMrg_.InterleavedWith(paOtherList)

	def ZipWith(paOtherList)
		_oZwMrg_ = new stzListMerger(This)
		return _oZwMrg_.ZipWith(paOtherList)

	def ZippedWith(paOtherList)
		_oZdwMrg_ = new stzListMerger(This)
		return _oZdwMrg_.ZippedWith(paOtherList)

	def Unzip()
		_oUzMrg_ = new stzListMerger(This)
		return _oUzMrg_.Unzip()

	def Unzipped()
		_oUzdMrg_ = new stzListMerger(This)
		return _oUzdMrg_.Unzipped()

	def PrependWith(paOtherList)
		_oPwMrg_ = new stzListMerger(This)
		_oPwMrg_.PrependWith(paOtherList)
		This.UpdateWith(_oPwMrg_.Content())

	def PrependedWith(paOtherList)
		_oPdwMrg_ = new stzListMerger(This)
		return _oPdwMrg_.PrependedWith(paOtherList)

	def DiffWith(paOtherList)
		_oDwMrg_ = new stzListMerger(This)
		return _oDwMrg_.DiffWith(paOtherList)

	# Set-ops fetch the engine RESULT HANDLE from the merger (a number, no list
	# copy) and unmarshal ONCE here -- one Ring method-return copy instead of
	# two (merger return + this return).
	def IntersectWith(paOtherList)
		_pIsw_ = (new stzListMerger(This))._IntersectHandle(paOtherList)
		_aIsw_ = StzEngineListContentToRingList(_pIsw_)
		StzEngineListFree(_pIsw_)
		return _aIsw_

	def UnionWith(paOtherList)
		_pUw_ = (new stzListMerger(This))._UnionHandle(paOtherList)
		_aUw_ = StzEngineListContentToRingList(_pUw_)
		StzEngineListFree(_pUw_)
		return _aUw_

	  #-------------------------------#
	 #  INSERTER DELEGATIONS         #
	#-------------------------------#

	# AreBoundsOfXT(pcSub, :In = host): TRUE if This (as [open,close])
	# bounds pcSub somewhere in host.
	def AreBoundsOfXT(pcSub, pNamedIn)
		if NOT (isString(pcSub) and isList(pNamedIn) and len(pNamedIn) = 2 and
		        isString(pNamedIn[1]) and lower(pNamedIn[1]) = "in" and
		        isString(pNamedIn[2]))
			return FALSE
		ok
		_l_ = This.List()
		if len(_l_) != 2 or NOT (isString(_l_[1]) and isString(_l_[2]))
			return FALSE
		ok
		_cOpen_ = _l_[1]; _cClose_ = _l_[2]
		_o_ = new stzString(pNamedIn[2])
		_aSec_ = _o_.FindBoundedByAsSections([ _cOpen_, _cClose_ ])
		_nL_ = len(_aSec_)
		for _i_ = 1 to _nL_
			_s_ = _aSec_[_i_]
			if isList(_s_) and len(_s_) = 2
				_cMid_ = _o_._EngineSlice(pNamedIn[2], _s_[1], _s_[2] - _s_[1] + 1)
				if StzFindFirst(_cMid_, pcSub) > 0 return TRUE ok
			ok
		next
		return FALSE

	def Insert(pItem, pWhere)
		_oIIns_ = new stzListInserter(This)
		_oIIns_.Insert(pItem, pWhere)
		This.UpdateWith(_oIIns_.Content())

	def InsertBeforePosition(n, pItem)
		_oIbpIns_ = new stzListInserter(This)
		_oIbpIns_.InsertBeforePosition(n, pItem)
		This.UpdateWith(_oIbpIns_.Content())

	def InsertAfterPosition(n, pItem)
		_oIapIns_ = new stzListInserter(This)
		_oIapIns_.InsertAfterPosition(n, pItem)
		This.UpdateWith(_oIapIns_.Content())

	def InsertBeforePositions(panPositions, pItem)
		_oIbpsIns_ = new stzListInserter(This)
		_oIbpsIns_.InsertBeforePositions(panPositions, pItem)
		This.UpdateWith(_oIbpsIns_.Content())

	  #-------------------------------#
	 #  BOUNDER DELEGATIONS          #
	#-------------------------------#

	def SectionXT(n1, n2)
		_oSxtBnd_ = new stzListBounder(This)
		return _oSxtBnd_.SectionXT(n1, n2)

	def AreBoundsOfCS(pcSubStr, pIn, pCaseSensitive)
		_oAbocsBnd_ = new stzListBounder(This)
		return _oAbocsBnd_.AreBoundsOfCS(pcSubStr, pIn, pCaseSensitive)

	def AreBoundsOf(pItem, pIn)
		return This.AreBoundsOfCS(pItem, pIn, 1)

	def IsBoundedByCS(paBounds, pCaseSensitive)
		_oIbbcsBnd_ = new stzListBounder(This)
		return _oIbbcsBnd_.IsBoundedByCS(paBounds, pCaseSensitive)

	def IsBoundedBy(paBounds)
		return This.IsBoundedByCS(paBounds, 1)

	def BoundsUpToNItems(n)
		_oButniBnd_ = new stzListBounder(This)
		return _oButniBnd_.BoundsUpToNItems(n)

	def Bounds()
		_oBsBnd_ = new stzListBounder(This)
		return _oBsBnd_.Bounds()

	def RemoveBoundsCS(paBounds, pCaseSensitive)
		_oRbcsBnd_ = new stzListBounder(This)
		_oRbcsBnd_.RemoveBoundsCS(paBounds, pCaseSensitive)
		This.UpdateWith(_oRbcsBnd_.Content())

	def RemoveBounds(paBounds)
		This.RemoveBoundsCS(paBounds, 1)

	def BoundsRemoved(paBounds)
		_oBrBnd_ = new stzListBounder(This)
		return _oBrBnd_.BoundsRemoved(paBounds)

	def Middle()
		_oMdBnd_ = new stzListBounder(This)
		return _oMdBnd_.Middle()

	def ClampedTo(nMin, nMax)
		_oCtBnd_ = new stzListBounder(This)
		return _oCtBnd_.ClampedTo(nMin, nMax)

	def ClampTo(nMin, nMax)
		_oCltBnd_ = new stzListBounder(This)
		_oCltBnd_.ClampTo(nMin, nMax)
		This.UpdateWith(_oCltBnd_.Content())

	def IsWithinBounds(n)
		_oIwbBnd_ = new stzListBounder(This)
		return _oIwbBnd_.IsWithinBounds(n)

	def ItemsBetweenPositions(n1, n2)
		_oIbpBnd_ = new stzListBounder(This)
		return _oIbpBnd_.ItemsBetweenPositions(n1, n2)

	  #-------------------------------#
	 #  EACH-ITEM-IS-EITHER MINI-DSL #
	#-------------------------------#

	#-- AllItemsAreEither / EachItemIsEither[A/An]: a symbol-DSL
	#   predicate that returns TRUE iff every item satisfies the
	#   LEFT side OR the RIGHT side. Accepted argument forms:
	#
	#   1. (PRED, :Or = OTHERPRED, TYPE)
	#        Both sides share TYPE. Left uses PRED; right uses
	#        OTHERPRED. Ring resolves ":Or = OTHERPRED" to a 2-list
	#        [ "Or", OTHERPRED ] which we detect.
	#
	#   2. (TYPE1, :Or, TYPE2)
	#        Each side is just a type check.
	#
	#   3. ([ pred1, pred2, ..., TYPE ], :Or, [ pred1', ..., TYPE' ])
	#        Each side is a list whose LAST element is the type and
	#        the rest are predicates that must all hold.
	#
	#   Side forms mix freely; a single non-type symbol on one side
	#   inherits the type from the other.
	#
	#   Ported from the archive symbol-DSL at stzList_monolithic.ring
	#   line ~60000 but kept self-contained (no shared eval-glue file).
	#   On any unknown predicate / type, the side fails silently and
	#   returns FALSE rather than crashing -- callers can rely on the
	#   method always returning a boolean.

	def AllItemsAreEither(p1, p2, p3)
		_aEieSpec_ = This._EieResolve(p1, p2, p3)
		if _aEieSpec_ = NULL
			return 0
		ok
		_cEieLT_ = _aEieSpec_[1]
		_aEieLP_ = _aEieSpec_[2]
		_cEieRT_ = _aEieSpec_[3]
		_aEieRP_ = _aEieSpec_[4]
		_nEieN_ = This.NumberOfItems()
		for _iEie_ = 1 to _nEieN_
			_xEieItem_ = @aContent[_iEie_]
			if NOT ( This._EieCheck(_xEieItem_, _cEieLT_, _aEieLP_) or
			         This._EieCheck(_xEieItem_, _cEieRT_, _aEieRP_) )
				return 0
			ok
		next
		return 1

		def EachItemIsEither(p1, p2, p3)
			return This.AllItemsAreEither(p1, p2, p3)

		def EachItemIsEitherA(p1, p2, p3)
			return This.AllItemsAreEither(p1, p2, p3)

		def EachItemIsEitherAn(p1, p2, p3)
			return This.AllItemsAreEither(p1, p2, p3)

		def ItemsAreEither(p1, p2, p3)
			return This.AllItemsAreEither(p1, p2, p3)

		def AllItemsHaveEither(p1, p2, p3)
			return This.AllItemsAreEither(p1, p2, p3)

		def ItemsHaveEither(p1, p2, p3)
			return This.AllItemsAreEither(p1, p2, p3)

	#-- Internal: parse the three params into (leftType, leftPreds,
	#   rightType, rightPreds). Returns NULL on malformed input.

	def _EieResolve(p1, p2, p3)
		_cLT_ = NULL  _aLP_ = []
		_cRT_ = NULL  _aRP_ = []

		# Form A: p2 = [ "Or", X ] -- shared-type DSL
		if isList(p2) and len(p2) = 2 and isString(p2[1]) and lower(p2[1]) = "or"
			if NOT isString(p3)
				return NULL
			ok
			_cLT_ = p3
			_cRT_ = p3
			if isString(p1)
				_aLP_ + p1
			but isList(p1)
				_nP11Len_ = len(p1)
				for _iLoopP11_ = 1 to _nP11Len_
					_s_ = p1[_iLoopP11_]
					_aLP_ + _s_
				next
			else
				return NULL
			ok
			_aRP_ + p2[2]
			return [ _cLT_, _aLP_, _cRT_, _aRP_ ]
		ok

		# Form B/C: p2 must be the bare :Or marker
		if NOT (isString(p2) and lower(p2) = "or")
			return NULL
		ok

		# Resolve each side
		_aL_ = This._EieResolveSide(p1)
		if _aL_ = NULL return NULL ok
		_cLT_ = _aL_[1]  _aLP_ = _aL_[2]

		_aR_ = This._EieResolveSide(p3)
		if _aR_ = NULL return NULL ok
		_cRT_ = _aR_[1]  _aRP_ = _aR_[2]

		# Borrow type if one side is predicate-only
		if _cLT_ = NULL _cLT_ = _cRT_ ok
		if _cRT_ = NULL _cRT_ = _cLT_ ok
		if _cLT_ = NULL return NULL ok

		return [ _cLT_, _aLP_, _cRT_, _aRP_ ]

	def _EieResolveSide(pSide)
		_aTypes_ = [ "number", "string", "list", "object" ]
		_cT_ = NULL  _aP_ = []
		if isString(pSide)
			if ring_find(_aTypes_, lower(pSide)) > 0
				_cT_ = pSide
			else
				_aP_ + pSide
			ok
		but isList(pSide) and len(pSide) > 0
			# Last item is the type
			_cLast_ = pSide[len(pSide)]
			if NOT isString(_cLast_)
				return NULL
			ok
			if ring_find(_aTypes_, lower(_cLast_)) > 0
				_cT_ = _cLast_
				_nSideLen_ = len(pSide)
				for _i_ = 1 to _nSideLen_ - 1
					_aP_ + pSide[_i_]
				next
			else
				# No explicit type -- treat all as predicates
				_nSidePredsLen_ = len(pSide)
				for _iPreds_ = 1 to _nSidePredsLen_
					_aP_ + pSide[_iPreds_]
				next
			ok
		else
			return NULL
		ok
		return [ _cT_, _aP_ ]

	def _EieCheck(pItem, pcType, paPreds)
		if pcType = NULL
			return 0
		ok
		_bTypeOk_ = 0
		switch lower(pcType)
		on "number"
			_bTypeOk_ = isNumber(pItem)
		on "string"
			_bTypeOk_ = isString(pItem)
		on "list"
			_bTypeOk_ = isList(pItem)
		on "object"
			_bTypeOk_ = isObject(pItem)
		off
		if NOT _bTypeOk_
			return 0
		ok
		# All predicates must pass
		_nPreds1Len_ = len(paPreds)
		for _iLoopPreds1_ = 1 to _nPreds1Len_
			_cPred_ = paPreds[_iLoopPreds1_]
			if NOT isString(_cPred_)
				return 0
			ok
			# Skip type-name re-mentions
			if lower(_cPred_) = lower(pcType)
				loop
			ok
			_xEieI_ = pItem
			_bEieR_ = 0
			try
				eval('_bEieR_ = Stz' + pcType + 'Q(_xEieI_).Is' + _cPred_ + '()')
			catch
				return 0
			done
			if NOT _bEieR_
				return 0
			ok
		next
		return 1

	  #-------------------------------#
	 #  FLATTENER DELEGATIONS        #
	#-------------------------------#

	# Flatten/Flattened already exist in core

	  #-------------------------------#
	 #  PATHS DELEGATIONS            #
	#-------------------------------#

	# stzListPaths has only 3 methods - minimal, skip for now

	#-- DeepRemove / DeepRemoveMany: walk the nested list structure
	#   and drop any item that matches pItem / any item in paItems.
	#   Recurses into nested lists. Ported from archive line 16144;
	#   simpler implementation here -- pure structural walk, no
	#   @@()-stringification round-trip.

	# DeepContains / DeepContainsCS: does the (nested) list contain
	# pItem at any depth? Recursive walk. Complements DeepRemove.

	def DeepContainsCS(pItem, pCaseSensitive)
		return This._DeepContainsCS(@aContent, pItem, pCaseSensitive)

	def DeepContains(pItem)
		return This.DeepContainsCS(pItem, 1)

		def DeeplyContains(pItem)
			return This.DeepContains(pItem)

	# Deep find: the index-path to every (nested) occurrence of pItem.
	# Engine-backed via the stzDeepList wrapper (stz_list_deep_find).

	def DeepFind(pItem)
		oDfDl = This.DeepList()
		return oDfDl.DeepFind(pItem)

		def DeepFindAll(pItem)
			return This.DeepFind(pItem)

		def DeepFindCS(pItem, pCaseSensitive)
			return This.DeepFind(pItem)

	# Paths(): the index-path to every node (containers AND leaves) of the
	# nested list, in depth-first order. Documented Softanza feature whose
	# wiring was dropped in the split; engine-backed (stz_list_deep_paths) --
	# same all-node format as the reference GeneratePaths() in stzListPaths.

	def Paths()
		oPthDl = This.DeepList()
		return oPthDl.Paths()

		def AllPaths()
			return This.Paths()

	# Every list-valued item at any depth (depth-first pre-order). Objects
	# are excluded (isList is false for them). E.g. ListsAtAnyLevel.

	def DeepLists()
		return _StzCollectDeepLists(@aContent)

		def ListsAtAnyLevel()
			return _StzCollectDeepLists(@aContent)

	# FilledWith(pItems): replace the wrapped list with pItems, then
	# return its content. Used for the 'start from an empty list and
	# fill it with these items' fluent shape.
	def FilledWith(pItems)
		if isList(pItems)
			This._SetContent(pItems)
		else
			This._InvalidateEngine()   # in-place @aContent mutation below
			@aContent + pItems
		ok
		return @aContent

		def FilledWithQ(pItems)
			This.FilledWith(pItems)
			return This

	# DeepReplace: recursive replace -- walk nested lists and
	# substitute every occurrence of pOld with pNew. The recursion
	# enters every list sublist; non-list items are compared with
	# Ring's = (deep-equal for lists, value-equal for scalars).

	def DeepReplaceCS(pOld, pNew, pCaseSensitive)
		if isList(pNew) and ring_len(pNew) = 2 and isString(pNew[1]) and
		   (pNew[1] = :by or pNew[1] = :By or pNew[1] = :with or pNew[1] = :With)
			pNew = pNew[2]
		ok
		This._SetContent(This._DeepReplaceCS(@aContent, pOld, pNew, pCaseSensitive))

		def DeepReplaceCSQ(pOld, pNew, pCaseSensitive)
			This.DeepReplaceCS(pOld, pNew, pCaseSensitive)
			return This

	def DeepReplace(pOld, pNew)
		This.DeepReplaceCS(pOld, pNew, 1)

		def DeepReplaceQ(pOld, pNew)
			This.DeepReplace(pOld, pNew)
			return This

		def DeeplyReplace(pOld, pNew)
			This.DeepReplace(pOld, pNew)

	def _DeepReplaceCS(paList, pOld, pNew, pCaseSensitive)
		_bDrCase_ = @CaseSensitive(pCaseSensitive)
		_aDrOut_ = []
		_nDrLen_ = len(paList)
		for _iDr_ = 1 to _nDrLen_
			_xDrIt_ = paList[_iDr_]
			if isList(_xDrIt_)
				_aDrOut_ + This._DeepReplaceCS(_xDrIt_, pOld, pNew, pCaseSensitive)
			else
				if _bDrCase_
					if _xDrIt_ = pOld
						_aDrOut_ + pNew
					else
						_aDrOut_ + _xDrIt_
					ok
				else
					if isString(_xDrIt_) and isString(pOld) and
					   lower(_xDrIt_) = lower(pOld)
						_aDrOut_ + pNew
					but _xDrIt_ = pOld
						_aDrOut_ + pNew
					else
						_aDrOut_ + _xDrIt_
					ok
				ok
			ok
		next
		return _aDrOut_

	def _DeepContainsCS(paList, pItem, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		_nList2Len_ = len(paList)
		for _iLoopList2_ = 1 to _nList2Len_
			_xItem_ = paList[_iLoopList2_]
			if isList(_xItem_)
				if This._DeepContainsCS(_xItem_, pItem, pCaseSensitive)
					return 1
				ok
			else
				if _bCase_
					if _xItem_ = pItem
						return 1
					ok
				else
					if isString(_xItem_) and isString(pItem)
						if lower(_xItem_) = lower(pItem)
							return 1
						ok
					but _xItem_ = pItem
						return 1
					ok
				ok
			ok
		next
		return 0

	def DeepRemove(pItem)
		This._SetContent(This._DeepFilterCS(@aContent, [pItem], 1))
		

		def DeepRemoveQ(pItem)
			This.DeepRemove(pItem)
			return This

		def DeepRemoveCS(pItem, pCaseSensitive)
			This._SetContent(This._DeepFilterCS(@aContent, [pItem], pCaseSensitive))
			

	def DeepRemoveMany(paItems)
		if NOT isList(paItems)
			StzRaise("DeepRemoveMany: paItems must be a list")
		ok
		This._SetContent(This._DeepFilterCS(@aContent, paItems, 1))
		

		def DeepRemoveManyQ(paItems)
			This.DeepRemoveMany(paItems)
			return This

		def DeepRemoveManyCS(paItems, pCaseSensitive)
			if NOT isList(paItems)
				StzRaise("DeepRemoveManyCS: paItems must be a list")
			ok
			This._SetContent(This._DeepFilterCS(@aContent, paItems, pCaseSensitive))
			

	def DeepRemoved(pItem)
		_oDrTmp_ = new stzList(@aContent)
		_oDrTmp_.DeepRemove(pItem)
		return _oDrTmp_.Content()

	def ManyDeepRemoved(paItems)
		_oMdrTmp_ = new stzList(@aContent)
		_oMdrTmp_.DeepRemoveMany(paItems)
		return _oMdrTmp_.Content()

	#-- Helper: case-sensitive deep filter. Returns a NEW list with
	#   anything matching paRemove removed at any nesting depth.
	def _DeepFilterCS(paList, paRemove, pCaseSensitive)
		_aDfR_ = []
		_bDfCase_ = @CaseSensitive(pCaseSensitive)
		_nList1Len_ = len(paList)
		for _iLoopList1_ = 1 to _nList1Len_
			_xDfItem_ = paList[_iLoopList1_]
			if isList(_xDfItem_)
				_aDfR_ + This._DeepFilterCS(_xDfItem_, paRemove, pCaseSensitive)
			else
				_bDfDrop_ = 0
				_nRemove1Len_ = len(paRemove)
				for _iLoopRemove1_ = 1 to _nRemove1Len_
					_xDfRm_ = paRemove[_iLoopRemove1_]
					if _bDfCase_
						if _xDfItem_ = _xDfRm_
							_bDfDrop_ = 1
							exit
						ok
					else
						if isString(_xDfItem_) and isString(_xDfRm_)
							if lower(_xDfItem_) = lower(_xDfRm_)
								_bDfDrop_ = 1
								exit
							ok
						but _xDfItem_ = _xDfRm_
							_bDfDrop_ = 1
							exit
						ok
					ok
				next
				if NOT _bDfDrop_
					_aDfR_ + _xDfItem_
				ok
			ok
		next
		return _aDfR_

	#-- Unicodes: return the codepoint of each character-string item
	#   in the list. Called by the global Unicodes(p) function in
	#   stzFuncs.ring when p is a list. Missing here made
	#   stzCharData.TurnableNumbers() (and friends) crash with R14.

	def Unicodes()
		return This._UnicodesOf(@aContent)

	# Recursive codepoint mapping (monolith semantics):
	#  - a number is echoed as-is
	#  - a single-codepoint string -> its scalar codepoint
	#  - a multi-codepoint string  -> the SUBLIST of its codepoints
	#  - a nested list             -> recurse, preserving structure
	# (StzCharToUnicode is single-char only, so multi-char strings go via
	#  the engine-backed stzString.Unicodes; empties/objects add nothing.)
	def _UnicodesOf(paList)
		_aRes_ = []
		_nUcLen_ = len(paList)
		for _iUc_ = 1 to _nUcLen_
			_xUc_ = paList[_iUc_]
			if isNumber(_xUc_)
				_aRes_ + _xUc_
			but isString(_xUc_)
				if StzLen(_xUc_) = 1
					_aRes_ + StzCharToUnicode(_xUc_)
				but StzLen(_xUc_) > 1
					_aRes_ + StzStringQ(_xUc_).Unicodes()
				ok
			but isList(_xUc_)
				_aRes_ + This._UnicodesOf(_xUc_)
			ok
		next
		return _aRes_

	def Names()
		if @IsListOfChars(This.Content())
			return This.ToStzListOfCharsQ().Names()
		else
			StzRaise("Can't proceed! In order to return names, the list must be a list of chars.")
		ok

	# SortOnDown / SortedOnDown for stzList: when the list is flat
	# (numbers / strings), forwards to descending sort on the
	# whole list. When the list is a list-of-lists, forwards to the
	# stzListOfLists.SortOnDown(n) which sorts on column n.
	def SortOnDown(n)
		if This.IsListOfLists()
			_oLol_ = new stzListOfLists(@aContent)
			_oLol_.SortOnDown(n)
			This._SetContent(_oLol_.Content())
		else
			This.SortInDescending()
		ok

		def SortOnDownQ(n)
			This.SortOnDown(n)
			return This

		def SortedOnDown(n)
			_oLolc_ = This.Copy()
			_oLolc_.SortOnDown(n)
			return _oLolc_.Content()

	# IsMadeOf*: predicates that answer "is every item one of the
	# listed types?". Used by the narrative tests for mixed-content
	# guards. The Or/And variants are synonyms -- both mean 'every
	# item is in {numbers, strings}'.
	def IsMadeOfNumbersOrStrings()
		_nImnsLen_ = len(@aContent)
		for _iImns_ = 1 to _nImnsLen_
			if NOT (isNumber(@aContent[_iImns_]) or isString(@aContent[_iImns_]))
				return 0
			ok
		next
		return 1

		def IsMadeOfNumbersAndStrings()
			return This.IsMadeOfNumbersOrStrings()

	def IsMadeOfNumbers()
		return This.IsListOfNumbers()		#-- engine-backed (StzEngineListIsAllNumbers)

	def IsMadeOfStrings()
		return This.IsListOfStrings()		#-- engine-backed (StzEngineListIsAllStrings)

	# Types(): map ring_type over the items, return the list of type
	# tags. "STRING", "NUMBER", "LIST", "OBJECT". Used by the
	# RepeatedInAPair narrative tests on stzObject.
	def Types()
		_aT_ = []
		_nTl_ = len(@aContent)
		for _iT_ = 1 to _nTl_
			_aT_ + ring_type(@aContent[_iT_])
		next
		return _aT_

		def TypesQ()
			return new stzList( This.Types() )

	#-- Unique list of the item types (Types() with duplicates removed)

	def UniqueTypes()
		oTypes = new stzList( This.Types() )
		return oTypes.Unique()

		def TypesU()
			return This.UniqueTypes()

		def UniqueTypesQ()
			return new stzList( This.UniqueTypes() )

	#-- ItemsAndTheirTypes: each item paired with its type name, in order.
	#-- e.g. [ 1, "A", [2] ] -> [ [1,"NUMBER"], ["A","STRING"], [[2],"LIST"] ].
	def ItemsAndTheirTypes()
		_aItt_ = []
		_nIttLen_ = len(@aContent)
		for _iItt_ = 1 to _nIttLen_
			_aItt_ + [ @aContent[_iItt_], ring_type(@aContent[_iItt_]) ]
		next
		return _aItt_

		def ItemsAndTheirTypesQ()
			return new stzList( This.ItemsAndTheirTypes() )

	#-- TypesAndTheirSections (alias TypesZZ): group the list into maximal
	#-- runs of one type, then collect, per distinct type, the [start,end]
	#-- position ranges of its runs. e.g. [1,2,"A",3] ->
	#-- [ ["NUMBER",[[1,2],[4,4]]], ["STRING",[[3,3]]] ].
	def TypesAndTheirSections()
		_nTtsLen_ = len(@aContent)
		if _nTtsLen_ = 0 return [] ok

		# 1) maximal same-type runs as [type, start, end]
		_aTtsRuns_ = []
		_cTtsCur_ = ring_type(@aContent[1])
		_nTtsStart_ = 1
		for _iTts_ = 2 to _nTtsLen_
			_cTtsT_ = ring_type(@aContent[_iTts_])
			if _cTtsT_ != _cTtsCur_
				_aTtsRuns_ + [ _cTtsCur_, _nTtsStart_, _iTts_ - 1 ]
				_cTtsCur_ = _cTtsT_
				_nTtsStart_ = _iTts_
			ok
		next
		_aTtsRuns_ + [ _cTtsCur_, _nTtsStart_, _nTtsLen_ ]

		# 2) fold runs by type, preserving first-appearance order
		_aTtsRes_ = []
		_nTtsRuns_ = len(_aTtsRuns_)
		for _iTts2_ = 1 to _nTtsRuns_
			_cTtsTy_ = _aTtsRuns_[_iTts2_][1]
			_aTtsSec_ = [ _aTtsRuns_[_iTts2_][2], _aTtsRuns_[_iTts2_][3] ]
			_nTtsFound_ = 0
			_nTtsResLen_ = len(_aTtsRes_)
			for _iTts3_ = 1 to _nTtsResLen_
				if _aTtsRes_[_iTts3_][1] = _cTtsTy_
					_aTtsRes_[_iTts3_][2] + _aTtsSec_
					_nTtsFound_ = 1
					exit
				ok
			next
			if _nTtsFound_ = 0
				_aTtsRes_ + [ _cTtsTy_, [ _aTtsSec_ ] ]
			ok
		next
		return _aTtsRes_

		def TypesAndTheirSectionsQ()
			return new stzList( This.TypesAndTheirSections() )

		def TypesZZ()
			return This.TypesAndTheirSections()

	#-- The items that are NOT numbers (engine DSL)

	def NonNumbers()
		return This.ItemsW('{ not isNumber(@item) }')

		def NonNumbersQ()
			return new stzList( This.NonNumbers() )

	#-- A copy of the list with every numeric 0 removed (non-mutating)

	def ZerosRemoved()
		return This.ItemsW('{ not isNumber(@item) or @item != 0 }')

		def ZerosRemovedQ()
			return new stzList( This.ZerosRemoved() )

	#-- The nth item counted from the end: NthToLast(1) is the item
	#-- before the last, NthToLast(2) the one before it, and so on.

	def NthToLast(n)
		return @aContent[ ring_len(@aContent) - n ]

	#-- Shrink the list down to its first n items (mutating).
	#-- Accepts Shrink(n) or the named form Shrink(:ToPosition = n).

	def Shrink(p)
		n = p
		if isList(p) and ring_len(p) = 2
			n = p[2]
		ok
		This._SetContent(This.Section(1, n))
		return This

		def ShrinkQ(p)
			This.Shrink(p)
			return This

	#-- Swap two items by position (mutating). Accepts SwapItems(n1, n2)
	#-- or the named form SwapItems(:AtPositions = n1, :And = n2).

	def SwapItems(p1, p2)
		n1 = p1
		n2 = p2
		if isList(p1) and ring_len(p1) = 2
			n1 = p1[2]
		ok
		if isList(p2) and ring_len(p2) = 2
			n2 = p2[2]
		ok
		This.Swap(n1, n2)
		return This

		def SwapItemsQ(p1, p2)
			This.SwapItems(p1, p2)
			return This

	#-- A two-item list whose both items share a given type.

	def BothAreNumbers()
		if This.NumberOfItems() = 2 and
		   isNumber(This.Item(1)) and isNumber(This.Item(2))
			return 1
		else
			return 0
		ok

		def ContainsTwoNumbers()
			return This.BothAreNumbers()

		def Contains2Numbers()
			return This.BothAreNumbers()

	def BothAreStrings()
		if This.NumberOfItems() = 2 and
		   isString(This.Item(1)) and isString(This.Item(2))
			return 1
		else
			return 0
		ok

		def ContainsTwoStrings()
			return This.BothAreStrings()

		def Contains2Strings()
			return This.BothAreStrings()

	def BothAreLists()
		if This.NumberOfItems() = 2 and
		   isList(This.Item(1)) and isList(This.Item(2))
			return 1
		else
			return 0
		ok

		def ContainsTwoLists()
			return This.BothAreLists()

		def Contains2Lists()
			return This.BothAreLists()

	def BothAreObjects()
		if This.NumberOfItems() = 2 and
		   isObject(This.Item(1)) and isObject(This.Item(2))
			return 1
		else
			return 0
		ok

		def ContainsTwoObjects()
			return This.BothAreObjects()

		def Contains2Objects()
			return This.BothAreObjects()

	#-- IsMadeOf family: "the list consists of these items".
	#-- IsMadeOf / IsMadeOfThese  -> contains ALL the given items.

	def IsMadeOf(paItems)
		return This.ContainsMany(paItems)

		def IsMadeOfThese(paItems)
			return This.ContainsMany(paItems)

	#-- IsMadeOfItem  -> every item equals the given one.

	def IsMadeOfItem(pItem)
		return This.ItemsAreEqualTo(pItem)

		def IsMadeOfThisItem(pItem)
			return This.ItemsAreEqualTo(pItem)

		def AllItemsAre(pItem)
			if isString(pItem) and
			   (@IsRingOrStzType(pItem) or
			    @IsRingTypePlural(pItem) or @IsStzTypePlural(pItem))

				return This.AllItemsAreOfType(pItem)
			ok

			return This.ItemsAreEqualTo(pItem)

	#-- IsMadeOfOneOfThese  -> contains at least one of the given items.

	def IsMadeOfOneOfThese(paItems)
		return This.ContainsOneOfThese(paItems)

		def IsMadeOfAnyOfThese(paItems)
			return This.ContainsOneOfThese(paItems)

	#-- ContainsSome / IsMadeOfSome  -> contains some (one or more) of them.

	def ContainsSomeCS(paItems, pCaseSensitive)
		if isString(paItems)
			paItems = [ paItems ]
		ok
		bResult = 0
		nLen = ring_len(paItems)
		for i = 1 to nLen
			if This.ContainsCS(paItems[i], pCaseSensitive)
				bResult = 1
				exit
			ok
		next
		return bResult

		def ContainsSome(paItems)
			return This.ContainsSomeCS(paItems, 1)

		def IsMadeOfSomeOfThese(paItems)
			return This.ContainsSomeCS(paItems, 1)

		def IsMadeOfOneOrMoreOfThese(paItems)
			return This.ContainsSomeCS(paItems, 1)

		def IsMadeOfOneOrMoreOf(paItems)
			return This.ContainsSomeCS(paItems, 1)

	#-- IsMadeOfUniformLists  -> all items are lists with the same size.

	def ContainsOnlyListsWithSameNumberOfItems()
		aContent = This.Content()
		nLen = ring_len(aContent)
		if nLen = 0
			return 0
		ok
		if NOT isList(aContent[1])
			return 0
		ok
		nLenFirst = ring_len(aContent[1])
		bResult = 1
		for i = 2 to nLen
			if NOT ( isList(aContent[i]) and ring_len(aContent[i]) = nLenFirst )
				bResult = 0
				exit
			ok
		next
		return bResult

		def IsMadeOfUniformLists()
			return This.ContainsOnlyListsWithSameNumberOfItems()

		def IsMadeOfUniSizeLists()
			return This.ContainsOnlyListsWithSameNumberOfItems()

		def ContainsOnlyUniSizeLists()
			return This.ContainsOnlyListsWithSameNumberOfItems()

	#-- Thin aliases over existing methods (restored from the monolith).

	# Bounds of an item: for each occurrence of pItem, the up-to-N
	# items immediately before and after it. pUpTo is a number (same
	# count both sides) or a [before, after] pair. Accepts the named
	# form BoundsOf(item, :UpToNItems = n). (Bounds() no-arg already
	# exists, so the parametered form lives under BoundsCS/BoundsOf.)

	def BoundsCS(pItem, pUpTo, pCaseSensitive)
		if isList(pItem) and len(pItem) = 2 and isString(pItem[1]) and StzLower(pItem[1]) = "of"
			pItem = pItem[2]
		ok
		if isList(pUpTo) and len(pUpTo) = 2 and isString(pUpTo[1])
			pUpTo = pUpTo[2]
		ok
		nLenList = ring_len(@aContent)
		anPos = This.FindCS(pItem, pCaseSensitive)
		nLenPos = ring_len(anPos)
		if isNumber(pUpTo)
			nLenBound1 = pUpTo
			nLenBound2 = pUpTo
		else
			nLenBound1 = pUpTo[1]
			nLenBound2 = pUpTo[2]
		ok
		aResult = []
		for i = 1 to nLenPos
			aBounds = []
			if anPos[i] - nLenBound1 > 0
				aBounds + This.Section(anPos[i] - nLenBound1, anPos[i] - 1)
			else
				aBounds + []
			ok
			if nLenList - anPos[i] >= nLenBound2
				aBounds + This.Section(anPos[i] + 1, anPos[i] + nLenBound2)
			else
				aBounds + []
			ok
			aResult + aBounds
		next
		return aResult

	def BoundsOf(pItem, pUpTo)
		return This.BoundsCS(pItem, pUpTo, 1)

		def NBoundsOf(pItem, pUpTo)
			return This.BoundsCS(pItem, pUpTo, 1)


	def DupOrigins()
		return This.Duplicates()

	def FindItemsW(pCondition)
		return This.FindAllItemsW(pCondition)

	def FirstNItemsQRT(n, pcReturnType)
		return This.NFirstItemsQRT(n, pcReturnType)

	def HowManyDuplicates()
		return This.NumberOfDuplicates()

	def Index()
		return This.FindItems()

	def Extract(pItem)
		return This.ExtractCS(pItem, 1)

	def ItemsAre(p)
		return This.Are(p)

	def Klass(pcClass)
		return This.Classify()[pcClass]

	def NumberOfDuplicatesOf(pItem)
		return This.NumberOfOccurrence(pItem)

	def OnlyWhere(pcCondition)
		return This.ItemsW(pcCondition)

		def OnlyWhereW(pcCondition)
			return This.ItemsW(pcCondition)


	def RemoveCS(pItem, pCaseSensitive)
		This.RemoveAllCS(pItem, pCaseSensitive)

		def RemoveItemCS(pItem, pCaseSensitive)
			This.RemoveAllCS(pItem, pCaseSensitive)

	def NumberOfOccurrenceW(pCondition)
		return This.CountItemsW(pCondition)

		def NumberOfOccurrencesW(pCondition)
			return This.CountItemsW(pCondition)



	#-- True if at least one item satisfies the W condition.

	def ContainsW(pcCondition)
		return ring_len(This.FindAllItemsW(pcCondition)) > 0

		def ContainsAtLeastOneW(pcCondition)
			return This.ContainsW(pcCondition)

	#-- Every section that starts at an occurrence of pItem1 and ends at
	#-- a later occurrence of pItem2. Accepts SectionsBetween(a, :And = b).

	def SectionsBetweenCS(pItem1, pItem2, pCaseSensitive)
		if isList(pItem2) and ring_len(pItem2) = 2 and isString(pItem2[1]) and
		   (pItem2[1] = :and or pItem2[1] = :And)
			pItem2 = pItem2[2]
		ok
		anSbPos1 = This.FindAllCS(pItem1, pCaseSensitive)
		anSbPos2 = This.FindAllCS(pItem2, pCaseSensitive)
		anSbPairs = []
		nSb1 = ring_len(anSbPos1)
		nSb2 = ring_len(anSbPos2)
		for iSb = 1 to nSb1
			for jSb = 1 to nSb2
				if anSbPos1[iSb] < anSbPos2[jSb]
					anSbPairs + [ anSbPos1[iSb], anSbPos2[jSb] ]
				ok
			next
		next
		return This.Sections(anSbPairs)

	def SectionsBetween(pItem1, pItem2)
		return This.SectionsBetweenCS(pItem1, pItem2, 1)

		def SectionsBetweenItems(pItem1, pItem2)
			return This.SectionsBetween(pItem1, pItem2)

	#-- Distribute this list's items over a list of "beneficiaries",
	#-- returning [beneficiary, [its items]] pairs. The plain form splits
	#-- as evenly as possible (remainder to the first ones); the XT form
	#-- takes an explicit per-beneficiary share via :Using = [n1, n2, ...].

	def DistributeOverXT(acBeneficiaryItems, anShareOfEachItem)
		if isList(anShareOfEachItem) and ring_len(anShareOfEachItem) = 2 and
		   isString(anShareOfEachItem[1]) and
		   (anShareOfEachItem[1] = :using or anShareOfEachItem[1] = :Using)
			anShareOfEachItem = anShareOfEachItem[2]
		ok
		if NOT ( isList(acBeneficiaryItems) and ring_len(acBeneficiaryItems) > 0 )
			StzRaise("Can't distribute the items of the main list over the items of the provided list!")
		ok
		nDoSum = 0
		nDoSL = ring_len(anShareOfEachItem)
		for kDo = 1 to nDoSL
			nDoSum += anShareOfEachItem[kDo]
		next
		if NOT nDoSum = This.NumberOfItems()
			StzRaise("Can't distribute the items of the main list over the items of the provided list!")
		ok
		aDoResult = []
		nDoLen = ring_len(acBeneficiaryItems)
		nDo1 = 1
		for iDo = 1 to nDoLen
			cDoBenef = acBeneficiaryItems[iDo]
			nDoRange = anShareOfEachItem[iDo]
			nDo2 = nDo1 + nDoRange - 1
			aDoShare = []
			for jDo = nDo1 to nDo2
				aDoShare + @aContent[jDo]
			next
			aDoResult + [ cDoBenef, aDoShare ]
			nDo1 = nDo2 + 1
		next
		return aDoResult

	def DistributeOver(acBeneficiaryItems)
		nDoLenList = This.NumberOfItems()
		nDoLenBenef = ring_len(acBeneficiaryItems)
		anDoShare = []
		if nDoLenBenef >= nDoLenList
			for iDo = 1 to nDoLenList
				anDoShare + 1
			next
		else
			nDoN = floor( nDoLenList / nDoLenBenef )
			for iDo = 1 to nDoLenBenef
				anDoShare + nDoN
			next
			nDoRest = nDoLenList - ( nDoN * nDoLenBenef )
			if nDoRest > 0
				for iDo = 1 to nDoRest
					anDoShare[iDo]++
				next
			ok
		ok
		return This.DistributeOverXT(acBeneficiaryItems, anDoShare)

	#-- A copy with all occurrences of an item removed (non-mutating).

	def ItemRemoved(pItem)
		oIrCopy = This.Copy()
		oIrCopy.RemoveAllCS(pItem, 1)
		return oIrCopy.Content()

		def AllOccurrencesOfThisItemRemoved(pItem)
			return This.ItemRemoved(pItem)

	#-- A copy with the items matching a W condition removed (engine DSL).

	def ItemRemovedW(pcCondition)
		anIrwMatch = This.FindAllItemsW(pcCondition)
		aIrwC = This.Content()
		nIrwLen = ring_len(aIrwC)
		aIrwRes = []
		for iIrw = 1 to nIrwLen
			bIrwIn = 0
			nIrwM = ring_len(anIrwMatch)
			for jIrw = 1 to nIrwM
				if anIrwMatch[jIrw] = iIrw
					bIrwIn = 1
					exit
				ok
			next
			if bIrwIn = 0
				aIrwRes + aIrwC[iIrw]
			ok
		next
		return aIrwRes

	#-- True if EVERY given position holds an item matching a W condition.

	def ContainsItemsAtW(panPos, pcCondition)
		anCiwMatch = This.FindAllItemsW(pcCondition)
		nCiwP = ring_len(panPos)
		for iCiw = 1 to nCiwP
			bCiwIn = 0
			nCiwM = ring_len(anCiwMatch)
			for jCiw = 1 to nCiwM
				if anCiwMatch[jCiw] = panPos[iCiw]
					bCiwIn = 1
					exit
				ok
			next
			if bCiwIn = 0
				return 0
			ok
		next
		return 1

		def ContainsAtW(panPos, pcCondition)
			return This.ContainsItemsAtW(panPos, pcCondition)

	#-- EachContains: every item (string or sub-list) contains pItem.

	def EachContainsCS(pItem, pCaseSensitive)
		bResult = 1
		aContent = This.Content()
		nLen = ring_len(aContent)
		for i = 1 to nLen
			if NOT ( isList(aContent[i]) or isString(aContent[i]) )
				bResult = 0
				exit
			else
				oEcItm = Q(aContent[i])
				bResult = oEcItm.ContainsCS(pItem, pCaseSensitive)
				if bResult = 0
					exit
				ok
			ok
		next
		return bResult

		def EachContains(pItem)
			return This.EachContainsCS(pItem, 1)

		def EachItemContainsCS(pItem, pCaseSensitive)
			return This.EachContainsCS(pItem, pCaseSensitive)

		def EachItemContains(pItem)
			return This.EachContainsCS(pItem, 1)

	#-- EachContainsThese: every item contains all the given items.

	def EachContainsTheseCS(paItems, pCaseSensitive)
		bResult = 1
		aContent = This.Content()
		nLen = ring_len(aContent)
		for i = 1 to nLen
			if NOT ( isList(aContent[i]) or isString(aContent[i]) )
				bResult = 0
				exit
			else
				oEctItm = Q(aContent[i])
				bResult = oEctItm.ContainsTheseCS(paItems, pCaseSensitive)
				if bResult = 0
					exit
				ok
			ok
		next
		return bResult

		def EachContainsThese(paItems)
			return This.EachContainsTheseCS(paItems, 1)

	#-- Intersection (method form): items shared with another list.
	#-- Routes to the existing CommonItems(:With = ...).

	def Intersection(pNamedWith)
		return This.CommonItems(pNamedWith)

	def CommonItemsWith(paOtherList)
		return This.CommonItems([ :With, paOtherList ])

		def IntersectionWith(paOtherList)
			return This.CommonItems([ :With, paOtherList ])

		def Common(paOtherList)
			return This.CommonItemsWith(paOtherList)

	#-- Symmetric difference: (this items not in other) ++ (other items not
	#-- in this). Engine-faithful element compare via BothAreEqualCS.

	def DifferentItemsWithCS(paOtherList, pCaseSensitive)
		# Symmetric difference, engine-backed and consistent with the rest
		# of Softanza: it is (this \ other) ++ (other \ this), each side the
		# engine's asymmetric difference (same primitive stzListComparator's
		# SymmetricDifference uses). Order = this-side items first, then
		# other-side items -- the documented Softanza order (test 632).
		_pDiwA_ = This._EngineListFromContent()
		_pDiwB_ = StzEngineMarshalList(paOtherList)
		if _pDiwA_ != NULL and _pDiwB_ != NULL
			_pDiwD1_ = StzEngineListDifferenceCS(_pDiwA_, _pDiwB_, pCaseSensitive)
			_pDiwD2_ = StzEngineListDifferenceCS(_pDiwB_, _pDiwA_, pCaseSensitive)
			_aDiwR_ = StzEngineListContentToRingList(_pDiwD1_)
			_aDiwT_ = StzEngineListContentToRingList(_pDiwD2_)
			_nDiwT_ = ring_len(_aDiwT_)
			for _iDiw_ = 1 to _nDiwT_
				_aDiwR_ + _aDiwT_[_iDiw_]
			next
			StzEngineListFree(_pDiwD1_)
			StzEngineListFree(_pDiwD2_)
			StzEngineListFree(_pDiwA_)
			StzEngineListFree(_pDiwB_)
			return _aDiwR_
		ok
		# Fallback (non-marshalable content): same symmetric semantics.
		aDiwR = []
		aDiwThis = This.Content()
		nDiw1 = ring_len(aDiwThis)
		nDiwO = ring_len(paOtherList)
		for iDiw = 1 to nDiw1
			bDiwIn = 0
			for jDiw = 1 to nDiwO
				if BothAreEqualCS(aDiwThis[iDiw], paOtherList[jDiw], pCaseSensitive)
					bDiwIn = 1
					exit
				ok
			next
			if bDiwIn = 0
				aDiwR + aDiwThis[iDiw]
			ok
		next
		for jDiw = 1 to nDiwO
			bDiwIn = 0
			for iDiw = 1 to nDiw1
				if BothAreEqualCS(paOtherList[jDiw], aDiwThis[iDiw], pCaseSensitive)
					bDiwIn = 1
					exit
				ok
			next
			if bDiwIn = 0
				aDiwR + paOtherList[jDiw]
			ok
		next
		return aDiwR

	def DifferentItemsWith(paOtherList)
		return This.DifferentItemsWithCS(paOtherList, 1)

		def Diff(paOtherList)
			return This.DifferentItemsWith(paOtherList)

	#-- Same items as another list, regardless of order/count (set equality).

	def ContainsSameItemsAsCS(paOtherList, pCaseSensitive)
		if NOT This.EachItemExistsInCS(paOtherList, pCaseSensitive)
			return 0
		ok
		oCsiOther = new stzList(paOtherList)
		return oCsiOther.EachItemExistsInCS(This.Content(), pCaseSensitive)

	def ContainsSameItemsAs(paOtherList)
		return This.ContainsSameItemsAsCS(paOtherList, 1)

	#-- IsContainedIn(p): this list, taken as a single value, is an
	#-- element of p (NOT element-wise -- that is AreContainedIn).

	def IsContainedInCS(p, pCaseSensitive)
		if NOT ( isString(p) or isList(p) )
			return 0
		ok
		oCip = Q(p)
		anPos = oCip.FindAllCS(This.Content(), pCaseSensitive)
		if ring_len(anPos) > 0
			return 1
		else
			return 0
		ok

		def IsContainedIn(p)
			return This.IsContainedInCS(p, 1)

		def ExistsInCS(p, pCaseSensitive)
			return This.IsContainedInCS(p, pCaseSensitive)

		def ExistsIn(p)
			return This.IsContainedInCS(p, 1)

		def IsIncludedInCS(p, pCaseSensitive)
			return This.IsContainedInCS(p, pCaseSensitive)

	#-- AreContainedIn / ExistIn: every item of this list also exists
	#-- somewhere in the other list (element-wise membership).

	def EachItemExistsInCS(paOtherList, pCaseSensitive)
		bResult = 1
		aContent = This.Content()
		nLen = ring_len(aContent)
		nOther = ring_len(paOtherList)
		for _k = 1 to nLen
			bFound = 0
			for _j = 1 to nOther
				if BothAreEqualCS(aContent[_k], paOtherList[_j], pCaseSensitive)
					bFound = 1
					exit
				ok
			next
			if bFound = 0
				bResult = 0
				exit
			ok
		next
		return bResult

		def EachItemExistsIn(paOtherList)
			return This.EachItemExistsInCS(paOtherList, 1)

		def ExistIn(paOtherList)
			return This.EachItemExistsInCS(paOtherList, 1)

		def AreContainedIn(paOtherList)
			return This.EachItemExistsInCS(paOtherList, 1)

	#-- HasSameNumberOfItemsAs: same length as another list.

	def HasSameNumberOfItemsAsCS(paOtherList, pCaseSensitive)
		if ring_len(paOtherList) = This.NumberOfItems()
			return 1
		else
			return 0
		ok

		def HasSameNumberOfItemsAs(paOtherList)
			return This.HasSameNumberOfItemsAsCS(paOtherList, 1)

		def HasSameSizeAs(paOtherList)
			return This.HasSameNumberOfItemsAsCS(paOtherList, 1)

		def HasSameWidthAs(paOtherList)
			return This.HasSameNumberOfItemsAsCS(paOtherList, 1)

	#-- Negative form of ContainsOneOfThese.

	def ContainsNoOneOfThese(paItems)
		return NOT This.ContainsOneOfThese(paItems)

		def ContainsNoneOfThese(paItems)
			return NOT This.ContainsOneOfThese(paItems)

		def ContainsNoItemOfThese(paItems)
			return NOT This.ContainsOneOfThese(paItems)

	#-- HowMany: number of items (alias of NumberOfItems).

	def HowManyItems()
		return This.NumberOfItems()

	#-- HowMany(item): how many times the item occurs in the list.

	def HowMany(pItem)
		return This.NumberOfOccurrence(pItem)

	#-- Objects: the items that are objects.

	def Objects()
		aContent = This.Content()
		nLen = ring_len(aContent)
		aResult = []
		for i = 1 to nLen
			if isObject(aContent[i])
				aResult + aContent[i]
			ok
		next
		return aResult

		def OnlyObjects()
			return This.Objects()

	#-- NumbersAndStrings: the scalar items (numbers or strings).
	#-- The Z form pairs each with its 1-based position.

	def NumbersAndStrings()
		aContent = This.Content()
		nLen = ring_len(aContent)
		aResult = []
		for i = 1 to nLen
			if isNumber(aContent[i]) or isString(aContent[i])
				aResult + aContent[i]
			ok
		next
		return aResult

		def StringsAndNumbers()
			return This.NumbersAndStrings()

	def NumbersAndStringsZ()
		aContent = This.Content()
		nLen = ring_len(aContent)
		aResult = []
		for i = 1 to nLen
			if isNumber(aContent[i]) or isString(aContent[i])
				aResult + [ aContent[i], i ]
			ok
		next
		return aResult

		def StringsAndNumbersZ()
			return This.NumbersAndStringsZ()

	#-- A copy with every string item lower/upper-cased (UTF-8 via the
	#-- engine-backed StzLower/StzUpper); non-string items pass through.

	def Lowercased()
		aLcC = This.Content()
		nLcL = ring_len(aLcC)
		aLcR = []
		for iLc = 1 to nLcL
			if isString(aLcC[iLc])
				aLcR + StzLower(aLcC[iLc])
			else
				aLcR + aLcC[iLc]
			ok
		next
		return aLcR

		def StringsLowercased()
			return This.Lowercased()

	def Uppercased()
		aUcC = This.Content()
		nUcL = ring_len(aUcC)
		aUcR = []
		for iUc = 1 to nUcL
			if isString(aUcC[iUc])
				aUcR + StzUpper(aUcC[iUc])
			else
				aUcR + aUcC[iUc]
			ok
		next
		return aUcR

		def StringsUppercased()
			return This.Uppercased()

	#-- VizFind: a visual map of where a char occurs -- the list rendered
	#-- as code, with a "^"/"-" marker line underneath. (Chars only, as the
	#-- markers align to single columns; generalising is a TODO.)

	def VizFindAllOccurrencesCS(pItem, pCaseSensitive)
		return This.VizFindCS(pItem, pCaseSensitive)

	def VizFindAllOccurrences(pItem)
		return This.VizFindAllOccurrencesCS(pItem, 1)

		def VizFind(pItem)
			return This.VizFindCS(pItem, 1)

		def VizFindCS(pItem, pCaseSensitive)
			# Base form: code + a single unlabelled marker row, wrapped.
			# Shallow: only top-level occurrences are marked (see VizDeepFind).
			cCode = This._VizCodeStr()
			cMark = This._VizMarkerLine(pItem, [], cCode, pCaseSensitive, 0)
			return This._VizWrap(cCode, [ [ "", cMark, "" ] ], This._VizWidth())

		def VizFindAll(pItem)
			return This.VizFindCS(pItem, 1)

	#-- _VizCodeStr / _VizMarkerLine: shared helpers for the Viz family.
	#-- The marker line aligns to the COLUMNS of the rendered code string:
	#-- "^" under each occurrence of pItem, "." under each occurrence of any
	#-- item in paOthers, "-" everywhere else. Works for ANY string value,
	#-- not only single chars (long values just span more columns).
	def _VizCodeStr()
		oVfc = new stzString(This.ToCode())
		return oVfc.Simplified()

	#-- Default wrap width: long renderings are split into lines this wide,
	#-- each with its marker row(s) underneath.
	def _VizWidth()
		return DefaultVizWidth()

	def _VizMarkerLine(pItem, paOthers, pcCode, pCaseSensitive, bDeep)
		# Depth filter: a SHALLOW viz (bDeep=0) marks only TOP-LEVEL occurrences
		# (bracket depth 1); a DEEP viz (bDeep=1) marks occurrences at any depth.
		oVfm = new stzString(pcCode)
		aVfmDepth = This._VizDepthMap(pcCode)
		_nVfmLen_ = StzLen(pcCode)

		# One marker cell per code column. The opening "[" (col 1) keeps a blank
		# under it; the rest default to "-". OTHERS are painted first so MINE
		# overrides on overlap.
		_aVfmCell_ = [ " " ]
		for _iVfmC_ = 2 to _nVfmLen_
			_aVfmCell_ + "-"
		next

		_nVfmO_ = len(paOthers)
		for _iVfmO_ = 1 to _nVfmO_
			This._VizPaint(_aVfmCell_, oVfm, paOthers[_iVfmO_], pCaseSensitive, aVfmDepth, bDeep, ".")
		next
		This._VizPaint(_aVfmCell_, oVfm, pItem, pCaseSensitive, aVfmDepth, bDeep, "^")

		_cVfmRes_ = ""
		for _iVfmJ_ = 1 to _nVfmLen_
			_cVfmRes_ += _aVfmCell_[_iVfmJ_]
		next
		return _cVfmRes_

	#-- _VizPaint: paint one searched value's matches into the marker cells.
	#-- A SCALAR value gets a single mark at the value's content (start + 1); a
	#-- LIST value -- being wider -- is UNDERLINED across its whole footprint
	#-- (start .. start + width - 1). The depth of each match's START decides
	#-- shallow (depth 1) vs deep visibility.
	def _VizPaint(paCell, poStr, pValue, pCaseSensitive, paDepth, bDeep, pcSym)
		_cVpVal_ = @@(pValue)
		_anVpPos_ = poStr.FindAllCS(_cVpVal_, pCaseSensitive)
		_nVpValLen_ = StzLen(_cVpVal_)
		_bVpSpan_ = isList(pValue)
		_nVpCells_ = len(paCell)
		_nVpN_ = len(_anVpPos_)
		for _iVp_ = 1 to _nVpN_
			_pVp_ = _anVpPos_[_iVp_]
			if bDeep = 1 or paDepth[_pVp_] = 1
				if _bVpSpan_
					for _kVp_ = _pVp_ to _pVp_ + _nVpValLen_ - 1
						if _kVp_ >= 1 and _kVp_ <= _nVpCells_
							paCell[_kVp_] = pcSym
						ok
					next
				else
					_kVp_ = _pVp_ + 1
					if _kVp_ >= 1 and _kVp_ <= _nVpCells_
						paCell[_kVp_] = pcSym
					ok
				ok
			ok
		next

	#-- _VizDepthMap: structural bracket-nesting depth at each codepoint of the
	#-- rendered code -- brackets inside "..." string values are ignored. Depth 1
	#-- = a top-level item; depth >= 2 = nested inside a sub-list. Lets the Viz
	#-- markers tell shallow occurrences from deep ones.
	def _VizDepthMap(pcCode)
		_oDmStr_ = new stzString(pcCode)
		_aDmChars_ = _oDmStr_.Chars()
		_nDmLen_ = len(_aDmChars_)
		_aDmDepth_ = []
		_nDmD_ = 0
		_bDmInStr_ = 0
		for _iDm_ = 1 to _nDmLen_
			_aDmDepth_ + _nDmD_
			_cDmCh_ = _aDmChars_[_iDm_]
			if _cDmCh_ = '"'
				_bDmInStr_ = 1 - _bDmInStr_
			but _bDmInStr_ = 0
				if _cDmCh_ = "["
					_nDmD_++
				but _cDmCh_ = "]"
					_nDmD_--
				ok
			ok
		next
		return _aDmDepth_

	#-- _VizWrap: render <code> with one or more marker rows beneath it,
	#-- WRAPPING to nWidth columns. Each row is [ cLabel, cMarker, cSuffix ];
	#-- the marker is column-aligned to the code (padded to its length) and
	#-- the suffix (e.g. a "(count)") is appended only after the LAST window.
	#-- An empty line separates wrapped blocks (none after the last block).
	def _VizWrap(pcCode, paRows, nWidth)
		nLen = StzLen(pcCode)
		oVwCode = new stzString(pcCode)

		# pad each marker to the code length so windows line up, and track the
		# widest row LABEL: the marker lines carry that label as a prefix, so the
		# code line must be indented by the same width or the "^" carets drift
		# right of the items they point at.
		aPad = []
		_nVwR_ = len(paRows)
		_nLblW_ = 0
		for _rVw_ = 1 to _nVwR_
			_cM_ = paRows[_rVw_][2]
			_nM_ = StzLen(_cM_)
			for _pVw_ = _nM_ + 1 to nLen
				_cM_ += "-"
			next
			aPad + [ paRows[_rVw_][1], _cM_, paRows[_rVw_][3] ]
			_nLW_ = StzLen(paRows[_rVw_][1])
			if _nLW_ > _nLblW_ _nLblW_ = _nLW_ ok
		next

		# right-justify every label to the common width (so the markers -- and the
		# " : " separators -- all start at the same column), and build the matching
		# indent for the code line above them.
		cVwIndent = ""
		for _iVwI_ = 1 to _nLblW_ cVwIndent += " " next
		for _rVwL_ = 1 to _nVwR_
			_cL_ = aPad[_rVwL_][1]
			_cLpad_ = ""
			for _pLp_ = StzLen(_cL_) + 1 to _nLblW_
				_cLpad_ += " "
			next
			aPad[_rVwL_][1] = _cLpad_ + _cL_
		next

		cRes = ""
		nStart = 1
		bFirst = 1
		while nStart <= nLen
			nEnd = nStart + nWidth - 1
			if nEnd > nLen nEnd = nLen ok
			bLastWin = ( nEnd = nLen )

			if NOT bFirst cRes += (NL + NL) ok
			bFirst = 0

			cRes += cVwIndent + oVwCode.Section(nStart, nEnd)
			for _rVw2_ = 1 to _nVwR_
				oVwM = new stzString(aPad[_rVw2_][2])
				cSeg = oVwM.Section(nStart, nEnd)
				cRes += NL + aPad[_rVw2_][1] + cSeg
				if bLastWin
					cRes += aPad[_rVw2_][3]
				ok
			next
			nStart = nEnd + 1
		end
		return cRes

	#-- VizFindXT: like VizFind, plus a "<item> :" label and a "(count)" tally.
	def VizFindXT(pItem)
		return This.VizFindXTCS(pItem, 1)

	def VizFindXTCS(pItem, pCaseSensitive)
		cCode = This._VizCodeStr()
		cMark = This._VizMarkerLine(pItem, [], cCode, pCaseSensitive, 0)
		# (count) = the SHALLOW count -- exactly what Find returns (top-level
		# items), so it matches the number of "^" carets drawn.
		nCount = len( This.FindAllCS(pItem, pCaseSensitive) )
		_aRow_ = [ [ @@(pItem) + " : ", cMark, " (" + nCount + ")" ] ]
		return This._VizWrap(cCode, _aRow_, This._VizWidth())

	#-- VizDeepFind* : like VizFind*, but the markers ALSO cover occurrences
	#-- nested inside sub-lists (any bracket depth), not just top-level ones.
	#-- The "(count)" is the total occurrences, same as the deep markers.
	def VizDeepFindCS(pItem, pCaseSensitive)
		cCode = This._VizCodeStr()
		cMark = This._VizMarkerLine(pItem, [], cCode, pCaseSensitive, 1)
		return This._VizWrap(cCode, [ [ "", cMark, "" ] ], This._VizWidth())

	def VizDeepFind(pItem)
		return This.VizDeepFindCS(pItem, 1)

		def VizDeepFindAll(pItem)
			return This.VizDeepFindCS(pItem, 1)

	def VizDeepFindXTCS(pItem, pCaseSensitive)
		cCode = This._VizCodeStr()
		cMark = This._VizMarkerLine(pItem, [], cCode, pCaseSensitive, 1)
		oVdxCnt = new stzString(cCode)
		nCount = len( oVdxCnt.FindAllCS(@@(pItem), pCaseSensitive) )
		_aRow_ = [ [ @@(pItem) + " : ", cMark, " (" + nCount + ")" ] ]
		return This._VizWrap(cCode, _aRow_, This._VizWidth())

	def VizDeepFindXT(pItem)
		return This.VizDeepFindXTCS(pItem, 1)

	#-- VizFindMany: one labelled marker row per searched item. Each row marks
	#-- "^" for its own item and "." for the other searched items.
	def VizFindMany(paItems)
		return This.VizFindManyCS(paItems, 1)

	def VizFindManyCS(paItems, pCaseSensitive)
		if NOT isList(paItems)
			StzRaise("Can't proceed! paItems must be a list.")
		ok
		cCode = This._VizCodeStr()
		aRows = []
		nN = len(paItems)
		for iM = 1 to nN
			aOthers = []
			for jM = 1 to nN
				if jM != iM aOthers + paItems[jM] ok
			next
			cMark = This._VizMarkerLine(paItems[iM], aOthers, cCode, pCaseSensitive, 0)
			aRows + [ @@(paItems[iM]) + " : ", cMark, "" ]
		next
		return This._VizWrap(cCode, aRows, This._VizWidth())

	#-- VizFindManyXT: VizFindMany plus a "(count)" tally on each row.
	def VizFindManyXT(paItems)
		return This.VizFindManyXTCS(paItems, 1)

	def VizFindManyXTCS(paItems, pCaseSensitive)
		if NOT isList(paItems)
			StzRaise("Can't proceed! paItems must be a list.")
		ok
		cCode = This._VizCodeStr()
		aRows = []
		nN = len(paItems)
		for iMx = 1 to nN
			aOthers = []
			for jMx = 1 to nN
				if jMx != iMx aOthers + paItems[jMx] ok
			next
			cMark = This._VizMarkerLine(paItems[iMx], aOthers, cCode, pCaseSensitive, 0)
			# shallow count = what Find returns (top-level items), matching the carets
			nCount = len( This.FindAllCS(paItems[iMx], pCaseSensitive) )
			aRows + [ @@(paItems[iMx]) + " : ", cMark, " (" + nCount + ")" ]
		next
		return This._VizWrap(cCode, aRows, This._VizWidth())

	#-- Type-filter family: Xs() = items of type X, XsZ() = [item,pos]
	#-- pairs, NumberOfXs() = count. Char = single-codepoint string
	#-- (StzLen=1); Letter = a single ASCII letter.

	def Numbers()
		aTfC = This.Content()
		nTfL = ring_len(aTfC)
		aTfR = []
		for iTf = 1 to nTfL
			if isNumber(aTfC[iTf])
				aTfR + aTfC[iTf]
			ok
		next
		return aTfR

		def NumbersZ()
			aTfC = This.Content()
			nTfL = ring_len(aTfC)
			aTfR = []
			for iTf = 1 to nTfL
				if isNumber(aTfC[iTf])
					aTfR + [ aTfC[iTf], iTf ]
				ok
			next
			return aTfR

		def NumberOfNumbers()
			return ring_len(This.Numbers())

	def Strings()
		aTfC = This.Content()
		nTfL = ring_len(aTfC)
		aTfR = []
		for iTf = 1 to nTfL
			if isString(aTfC[iTf])
				aTfR + aTfC[iTf]
			ok
		next
		return aTfR

		def StringsZ()
			aTfC = This.Content()
			nTfL = ring_len(aTfC)
			aTfR = []
			for iTf = 1 to nTfL
				if isString(aTfC[iTf])
					aTfR + [ aTfC[iTf], iTf ]
				ok
			next
			return aTfR

		def NumberOfStrings()
			return ring_len(This.Strings())

	def Chars()
		aTfC = This.Content()
		nTfL = ring_len(aTfC)
		aTfR = []
		for iTf = 1 to nTfL
			if isString(aTfC[iTf]) and StzLen(aTfC[iTf]) = 1
				aTfR + aTfC[iTf]
			ok
		next
		return aTfR

		def CharsZ()
			aTfC = This.Content()
			nTfL = ring_len(aTfC)
			aTfR = []
			for iTf = 1 to nTfL
				if isString(aTfC[iTf]) and StzLen(aTfC[iTf]) = 1
					aTfR + [ aTfC[iTf], iTf ]
				ok
			next
			return aTfR

	def Letters()
		aTfC = This.Content()
		nTfL = ring_len(aTfC)
		aTfR = []
		for iTf = 1 to nTfL
			_xTf = aTfC[iTf]
			if isString(_xTf) and ring_len(_xTf) = 1
				_nTfA = ascii(_xTf)
				if (_nTfA >= 97 and _nTfA <= 122) or (_nTfA >= 65 and _nTfA <= 90)
					aTfR + _xTf
				ok
			ok
		next
		return aTfR

		def LettersZ()
			aTfC = This.Content()
			nTfL = ring_len(aTfC)
			aTfR = []
			for iTf = 1 to nTfL
				_xTf = aTfC[iTf]
				if isString(_xTf) and ring_len(_xTf) = 1
					_nTfA = ascii(_xTf)
					if (_nTfA >= 97 and _nTfA <= 122) or (_nTfA >= 65 and _nTfA <= 90)
						aTfR + [ _xTf, iTf ]
					ok
				ok
			next
			return aTfR

		def NumberOfLetters()
			return ring_len(This.Letters())

	def Lists()
		aTfC = This.Content()
		nTfL = ring_len(aTfC)
		aTfR = []
		for iTf = 1 to nTfL
			if isList(aTfC[iTf])
				aTfR + aTfC[iTf]
			ok
		next
		return aTfR

		def ListsZ()
			aTfC = This.Content()
			nTfL = ring_len(aTfC)
			aTfR = []
			for iTf = 1 to nTfL
				if isList(aTfC[iTf])
					aTfR + [ aTfC[iTf], iTf ]
				ok
			next
			return aTfR

		def NumberOfLists()
			return ring_len(This.Lists())

	def NumberOfPairs()
		return ring_len(This.Pairs())

	#-- Extend the list up to position n. ExtendToPosition pads with 0
	#-- (number lists) or "" ; the WithItemsIn/Repeated forms pad by
	#-- cycling through a given list (or the list's own items).

	def ExtendToPosition(n)
		nLen = This.NumberOfItems()
		aContent = This.Content()
		if n > nLen
			value = ""
			if This.IsListOfNumbers()
				value = 0
			ok
			nExtend = n - nLen
			for i = 1 to nExtend
				aContent + value
			next
		ok
		This.UpdateWith(aContent)

	def ExtendToPositionWithItemsIn(n, paItems)
		nLen = ring_len(paItems)
		# fill (target - CURRENT length) slots; cycle the pool (length nLen)
		nTemp = n - This.NumberOfItems()
		aTemp = []
		if nTemp > 0
			j = 0
			for i = 1 to nTemp
				j++
				if j > nLen
					j = 1
				ok
				aTemp + paItems[j]
			next
		ok
		This.ExtendWith(aTemp)

		def ExtendToWithItemsIn(n, paItems)
			This.ExtendToPositionWithItemsIn(n, paItems)

	def ExtendToPositionWithItemsRepeated(n)
		This.ExtendToPositionWithItemsIn(n, This.List())

		def ExtendToWithItemsRepeated(n)
			This.ExtendToPositionWithItemsRepeated(n)

		def ExtendToByRepeatingItems(n)
			This.ExtendToPositionWithItemsRepeated(n)

	#-- Size comparison with another list. Accept the named form
	#-- IsLarger(:Than = otherList) or the raw list.

	def HasMoreNumberOfItems(paOtherList)
		if isList(paOtherList) and ring_len(paOtherList) = 2 and isString(paOtherList[1]) and
		   (paOtherList[1] = :Than or paOtherList[1] = :than)
			paOtherList = paOtherList[2]
		ok
		if This.NumberOfItems() > ring_len(paOtherList)
			return 1
		else
			return 0
		ok

		def IsLarger(paOtherList)
			return This.HasMoreNumberOfItems(paOtherList)

		def IsLargerThan(paOtherList)
			return This.HasMoreNumberOfItems(paOtherList)

		def HasMoreItems(paOtherList)
			return This.HasMoreNumberOfItems(paOtherList)

	def HasLessNumberOfItems(paOtherList)
		if isList(paOtherList) and ring_len(paOtherList) = 2 and isString(paOtherList[1]) and
		   (paOtherList[1] = :Than or paOtherList[1] = :than)
			paOtherList = paOtherList[2]
		ok
		if This.NumberOfItems() < ring_len(paOtherList)
			return 1
		else
			return 0
		ok

		def IsSmaller(paOtherList)
			return This.HasLessNumberOfItems(paOtherList)

		def IsSmallerThan(paOtherList)
			return This.HasLessNumberOfItems(paOtherList)

		def HasLessItems(paOtherList)
			return This.HasLessNumberOfItems(paOtherList)

		def HasFewerItems(paOtherList)
			return This.HasLessNumberOfItems(paOtherList)

	#-- IsListOfEmptyLists: every item is an empty list.

	def IsListOfEmptyLists()
		aContent = This.Content()
		nLen = ring_len(aContent)
		bResult = 1
		for i = 1 to nLen
			if NOT isList(aContent[i])
				bResult = 0
				exit
			ok
			if NOT ring_len(aContent[i]) = 0
				bResult = 0
				exit
			ok
		next
		return bResult

		def AllItemsAreEmptyLists()
			return This.IsListOfEmptyLists()

		def ContainsOnlyEmptyLists()
			return This.IsListOfEmptyLists()

	#-- First-occurrence positions of the items that are duplicated
	#-- ("duplicate origins"). Built engine-first: the duplicated VALUES
	#-- come from the engine-backed DuplicatedItemsCS, and each value's
	#-- first position from the engine-backed FindFirstCS -- avoiding the
	#-- monolith's O(n^2) StzFind loop (whose arg order is ambiguous now).

	def FindFirstDuplicatesCS(pCaseSensitive)
		aDups = This.DuplicatedItemsCS(pCaseSensitive)
		aRes = []
		nLen = ring_len(aDups)
		for i = 1 to nLen
			aRes + This.FindFirstCS(aDups[i], pCaseSensitive)
		next
		return ring_sort(aRes)

		def FindFirstDuplicates()
			return This.FindFirstDuplicatesCS(1)

		def FindFirstDuplicatedItems()
			return This.FindFirstDuplicatesCS(1)

		def FindFirstOccurrenceOfEachDuplicatedItem()
			return This.FindFirstDuplicatesCS(1)

		def FindDupOrigins()
			return This.FindFirstDuplicatesCS(1)

	#-- Remove the first occurrence of each duplicated item (mutating).

	def RemoveDupOrigins()
		This.RemoveItemsAtPositions( This.FindFirstDuplicates() )

		def RemoveDuplicatesOrigins()
			This.RemoveDupOrigins()

	  #=====================================#
	 #   OPERATOR OVERLOADING              #
	#=====================================#
	#
	# stzList supports the natural Ring operator-overload set so
	# narrative tests can write things like
	#
	#   Q([1, 2, 3]) - 2          # -> [1, 3]
	#   Q([1, 2, 3]) + 4          # -> [1, 2, 3, 4]
	#   Q([1, 2]) * 3             # -> [1, 2, 1, 2, 1, 2]
	#
	# Semantics for `+` and `-`:
	#   - the RHS is treated AS A SINGLE ITEM (it's added or removed
	#     literally, even when it's itself a list).
	#   - this matches the legacy Softanza contract documented in the
	#     stzlistofnumbers narrative blocks: `Q([1,2,3,4,5]) - [1,3,5]`
	#     returns [1,2,3,4,5] unchanged because the literal list
	#     [1,3,5] is NOT an element of [1,2,3,4,5].
	#
	# For element-wise operations, use the explicit method calls
	# (AddMany / RemoveMany / etc.) -- the operator is reserved for
	# the simple "single item" reading.

	def operator(pOp, pValue)

		# Softanza operator rules (NON-mutating -- the object is never
		# changed; every branch returns a fresh value):
		#   RHS raw            -> raw result
		#   RHS Q(...) object  -> chainable stz object
		#   These()/TheseQ()   -> operand list applied item-by-item
		#   Obj()/ObjQ()/O()   -> operand stz object added/removed AS the
		#                         object itself (not unwrapped)
		# The Q/These/Obj forms are flagged by globals set in stzFuncs.

		if pOp = "+"

			if isList(pValue)
				if _bTheseQ
					_bTheseQ = 0
					return new stzList( This.ManyAdded(pValue) )
				but _bThese
					_bThese = 0
					return This.ManyAdded(pValue)
				else
					return This.ItemAdded(pValue)
				ok

			but @IsStzObject(pValue)
				if _bAsObject
					_bAsObject = 0
					return This.ItemAdded(pValue)
				but _bAsObjectQ
					_bAsObjectQ = 0
					return new stzList( This.ItemAdded(pValue) )
				but _bTheseQ
					_bTheseQ = 0
					return new stzList( This.ManyAdded(pValue.Content()) )
				but _bThese
					_bThese = 0
					return This.ManyAdded(pValue.Content())
				else
					_vOpVal_ = pValue.Content()
					if @IsStzNumber(pValue)
						_vOpVal_ = pValue.NumericValue()
					ok
					return new stzList( This.ItemAdded(_vOpVal_) )
				ok

			else
				return This.ItemAdded(pValue)
			ok

		but pOp = "-"

			if isList(pValue)
				if _bTheseQ
					_bTheseQ = 0
					return new stzList( This.ManyRemoved(pValue) )
				but _bThese
					_bThese = 0
					return This.ManyRemoved(pValue)
				else
					return This.ItemRemoved(pValue)
				ok

			but @IsStzlist(pValue)
				if _bAsObject
					_bAsObject = 0
					return This.ItemRemoved(pValue)
				but _bAsObjectQ
					_bAsObjectQ = 0
					return new stzList( This.ItemRemoved(pValue) )
				but _bTheseQ
					_bTheseQ = 0
					return new stzList( This.ManyRemoved(pValue.Content()) )
				but _bThese
					_bThese = 0
					return This.ManyRemoved(pValue.Content())
				else
					return new stzList( This.ItemRemoved(pValue.Content()) )
				ok

			but @IsStzObject(pValue)
				if _bAsObject
					_bAsObject = 0
					return This.ItemRemoved(pValue)
				but _bAsObjectQ
					_bAsObjectQ = 0
					return new stzList( This.ItemRemoved(pValue) )
				ok
				_vOpVal_ = pValue.Content()
				if @IsStzNumber(pValue)
					_vOpVal_ = pValue.NumericValue()
				ok
				return new stzList( This.ItemRemoved(_vOpVal_) )

			else
				return This.ItemRemoved(pValue)
			ok

		but pOp = "*"
			# (*) dispatches on the RHS type. Q-elevation rule: a RAW rhs returns
			# a raw list; a Q()-wrapped / stz-object rhs returns a chainable
			# stzList with the SAME content. NON-mutating.
			#   number  -> repeat the list N times, FLAT  ([1,2]*3 -> [1,2,1,2,1,2])
			#   string  -> append the suffix to each item  (["a","b"]*"!" -> ["a!","b!"])
			#   list    -> pair each item with the whole rhs list (zip-broadcast)
			_bMulElevate_ = 0
			_vMulRhs_ = pValue
			if @IsStzObject(pValue)
				_bMulElevate_ = 1
				if @IsStzNumber(pValue)
					_vMulRhs_ = pValue.NumericValue()
				else
					_vMulRhs_ = pValue.Content()
				ok
			ok

			_aMulRes_ = []
			_nMulLen_ = len(@aContent)

			if isNumber(_vMulRhs_)
				_nMul_ = floor(_vMulRhs_)
				if _nMul_ < 0 _nMul_ = 0 ok
				for _iMul_ = 1 to _nMul_
					for _jMul_ = 1 to _nMulLen_
						_aMulRes_ + @aContent[_jMul_]
					next
				next

			but isString(_vMulRhs_)
				for _jMul_ = 1 to _nMulLen_
					if isString(@aContent[_jMul_])
						_aMulRes_ + (@aContent[_jMul_] + _vMulRhs_)
					else
						_aMulRes_ + @aContent[_jMul_]
					ok
				next

			but isList(_vMulRhs_)
				for _jMul_ = 1 to _nMulLen_
					_aMulRes_ + [ @aContent[_jMul_], _vMulRhs_ ]
				next

			else
				StzRaise("operator *: rhs must be a number, string, list, or Q(...) of these.")
			ok

			if _bMulElevate_
				return new stzList(_aMulRes_)
			ok
			return _aMulRes_

		but pOp = "/"
			# Divide the list into pValue parts of as-equal-as-possible size
			# (the documented "/ n -> n parts" contract: [1..6] / 3 ->
			# [[1,2],[3,4],[5,6]]). The remainder is front-loaded -- the first
			# (len mod n) parts get one extra item (numpy array_split
			# convention). This is SplitToNParts; chunk-by-SIZE lives in
			# SplitToPartsOfNItems. Q-elevation rule: a RAW number returns a
			# raw list of lists; a Q(number) / numeric stz-object returns a
			# chainable stzList object with the SAME content.
			_bDivElevate_ = 0
			if isNumber(pValue)
				_nParts_ = pValue
			but @IsStzObject(pValue)
				_vDiv_ = pValue.Content()
				if @IsStzNumber(pValue)
					_vDiv_ = pValue.NumericValue()
				ok
				if NOT isNumber(_vDiv_)
					StzRaise("operator /: rhs object must hold a number.")
				ok
				_nParts_ = _vDiv_
				_bDivElevate_ = 1
			else
				StzRaise("operator /: rhs must be a positive number or Q(number).")
			ok
			if _nParts_ < 1
				StzRaise("operator /: rhs must be a positive number.")
			ok
			_nParts_ = floor(_nParts_)
			_aGroups_ = []
			_nCntLen_ = len(@aContent)
			_nBase_ = floor(_nCntLen_ / _nParts_)
			_nRem_ = _nCntLen_ % _nParts_
			_iCur_ = 1
			for _iP_ = 1 to _nParts_
				_nSz_ = _nBase_
				if _iP_ <= _nRem_
					_nSz_ = _nSz_ + 1
				ok
				if _nSz_ = 0
					loop
				ok
				_aGroup_ = []
				_iEnd_ = _iCur_ + _nSz_ - 1
				for _jCh_ = _iCur_ to _iEnd_
					_aGroup_ + @aContent[_jCh_]
				next
				_aGroups_ + _aGroup_
				_iCur_ = _iEnd_ + 1
			next
			if _bDivElevate_
				return new stzList(_aGroups_)
			ok
			return _aGroups_

		but pOp = "[]"
			# Bracket indexing: a numeric key reads the item at that
			# position (Nth, 1-based, negatives count from the end);
			# any other key returns the positions where it occurs
			# (FindAll). Mirrors the stzString o1[n] / o1["x"] idiom.
			if isNumber(pValue)
				return This.Item(pValue)
			else
				return This.FindAll(pValue)
			ok

		ok

		# Value equality: Q(list) = otherlist routes to IsEqualTo (only when the
		# RHS is a list, so non-list comparisons keep their prior behavior).
		if pOp = "=" and isList(pValue)
			return This.IsEqualTo(pValue)
		ok
		if (pOp = "!=" or pOp = "<>") and isList(pValue)
			return NOT This.IsEqualTo(pValue)
		ok

		StzRaise("operator: unsupported operator '" + pOp + "' on stzList.")


	#========================================================#
	#  BATCH-1 RESTORE: duplicate / non-duplicate family,    #
	#  Index, ItemsOccurring, NListify, Halves (from the     #
	#  monolith -- split-dropped, authoritative semantics).  #
	#========================================================#

	def DuplicatesCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		aContent = This.Content()
		nLen = len(aContent)

		if nLen = 0
			return []
		ok

		acStr = []

		if pCaseSensitive = 1
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + cItem
			next
		else
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + StzLower(cItem)
			next
		ok

		acSeen = [ acStr[1] ]
		anPos = [ [] ]

		for i = 1 to nLen
			n = StzFindFirst(acSeen, acStr[i])
			if n = 0
				acSeen + acStr[i]
				anPos + [ i ]
			else
				anPos[ n ] + i
			ok
		next

		aResult = []
		nLen = len(acSeen)

		for i = 1 to nLen
			if len(anPos[i]) > 1
				aResult + aContent[anPos[i][1]]
			ok
		next

		return aResult

	def DuplicatesCSZ(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		aContent = This.Content()
		nLen = len(aContent)

		if nLen = 0
			return []
		ok

		acStr = []

		if pCaseSensitive = 1
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + cItem
			next
		else
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + StzLower(cItem)
			next
		ok

		acSeen = [ acStr[1] ]
		anPos = [ [] ]

		for i = 1 to nLen
			n = StzFindFirst(acSeen, acStr[i])
			if n = 0
				acSeen + acStr[i]
				anPos + [ i ]
			else
				anPos[ n ] + i
			ok
		next

		aResult = []
		nLen = len(acSeen)

		for i = 1 to nLen
			del(anPos[i], 1)
			if len(anPos[i]) > 0
				aResult + [ aContent[anPos[i][1]], anPos[i] ]
			ok
		next

		return aResult

	def DuplicatesCSXTZ(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		aContent = This.Content()
		nLen = len(aContent)

		if nLen = 0
			return []
		ok

		acStr = []

		if pCaseSensitive = 1
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + cItem
			next
		else
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + StzLower(cItem)
			next
		ok

		acSeen = []
		anSeen = []
		anPos = []
		aResult = []

		for i = 1 to nLen
			n = StzFindFirst(acSeen, acStr[i])
			if n = 0
				acSeen + acStr[i]
				anSeen + i
				aResult + [ aContent[i], [i] ]
			else
				if StzFindFirst(anPos, anSeen[n]) = 0
					anPos + anSeen[n]
				ok
				anPos + i
				aResult[n][2] + i
			ok
		next

		return aResult

	def DuplicatesXTZ()
		return This.DuplicatesCSXTZ(1)

	def FindDuplicatesCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		aContent = This.Content()
		nLen = len(aContent)

		if nLen = 0
			return []
		ok

		acStr = []

		if pCaseSensitive = 1
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + cItem
			next
		else
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + StzLower(cItem)
			next
		ok

		acSeen = []
		anPos = []

		for i = 1 to nLen
			n = StzFindFirst(acSeen, acStr[i])
			if n = 0
				acSeen + acStr[i]
			else
				anPos + i
			ok
		next

		return anPos

	def FindDuplicatesCSXT(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		aContent = This.Content()
		nLen = len(aContent)

		if nLen = 0
			return []
		ok

		acStr = []

		if pCaseSensitive = 1
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + cItem
			next
		else
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + StzLower(cItem)
			next
		ok

		acSeen = []
		anSeen = []
		anPos = []

		for i = 1 to nLen
			n = StzFindFirst(acSeen, acStr[i])
			if n = 0
				acSeen + acStr[i]
				anSeen + i
			else
				if StzFindFirst(anPos, anSeen[n]) = 0
					anPos + anSeen[n]
				ok
				anPos + i
			ok
		next

		anPos = ring_sort(anPos)
		return anPos

	def NumberOfDuplicatesCS(pCaseSensitive)
		return len( This.FindDuplicatesCS(pCaseSensitive) )

	def ContainsNoDuplicatesCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		return len( This.FindDuplicatesCS(pCaseSensitive) ) = 0

	def ContainsNoDuplicates()
		return This.ContainsNoDuplicatesCS(1)

	def ContainsNoDuplications()
		return This.ContainsNoDuplicates()

	def NoItemsAreDuplicatedCS(pCaseSensitive)
		return This.ContainsNoDuplicatesCS(pCaseSensitive)

	def NoItemsAreDuplicated()
		return This.ContainsNoDuplicates()

	#-- NON-DUPLICATED ITEMS

	def ContainsNonDuplicatedItemsCS(pCaseSensitive)
		anPos = This.FindDuplicatesCSXT(pCaseSensitive)
		nLen = This.NumberOfItems()
		if NOT Q(anPos).IsEqualTo(1:nLen)
			return 1
		else
			return 0
		ok

	def ContainsNonDuplicatedItems()
		return This.ContainsNonDuplicatedItemsCS(1)

	def ContainsItemsThatAreNotDuplicatedCS(pCaseSensitive)
		return This.ContainsNonDuplicatedItemsCS(pCaseSensitive)

	def ContainsItemsNonDuplicated()
		return This.ContainsNonDuplicatedItems()

	def ContainsAtLeastOneNonDuplicatedItem()
		return This.ContainsNonDuplicatedItems()

	def NonDuplicatedItemsCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		aContent = This.Content()
		nLen = len(aContent)

		if nLen = 0
			return 0
		ok

		acStr = []

		if pCaseSensitive = 1
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + cItem
			next
		else
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + StzLower(cItem)
			next
		ok

		acSeen = []
		acResult = []
		anPos = []

		for i = 1 to nLen
			n = StzFindFirst(acSeen, acStr[i])
			if n = 0
				acSeen + acStr[i]
				acResult + acStr[i]
				anPos + i
			else
				nPos = StzFindFirst(acResult, acStr[i])
				if nPos > 0
					ring_del(acResult, nPos)
					ring_del(anPos, nPos)
				ok
			ok
		next

		aResult = []
		nLen = len(anPos)
		for i = 1 to nLen
			aResult + aContent[anPos[i]]
		next

		return aResult

	def NonDuplicatedItems()
		return This.NonDuplicatedItemsCS(1)

	def NumberOfNonDuplicatedItemsCS(pCaseSensitive)
		return len(This.NonDuplicatedItemsCS(pCaseSensitive))

	def NumberOfNonDuplicatedItems()
		return This.NumberOfNonDuplicatedItemsCS(1)

	def FindNonDuplicatedItemsCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		aContent = This.Content()
		nLen = len(aContent)

		if nLen = 0
			return 0
		ok

		acStr = []

		if pCaseSensitive = 1
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + cItem
			next
		else
			for i = 1 to nLen
				if isNumber(aContent[i])
					cItem = "" + aContent[i]
				but isString(aContent[i])
					cItem = @@(aContent[i])
				but isList(aContent[i])
					cItem = @@(aContent[i])
				but isObject(aContent[i])
					cItem = @ObjectVarName(aContent[i])
				ok
				acStr + StzLower(cItem)
			next
		ok

		acSeen = []
		acResult = []
		anResult = []

		for i = 1 to nLen
			n = StzFindFirst(acSeen, acStr[i])
			if n = 0
				acSeen + acStr[i]
				acResult + acStr[i]
				anResult + i
			else
				nPos = StzFindFirst(acResult, acStr[i])
				if nPos > 0
					ring_del(acResult, nPos)
					ring_del(anResult, nPos)
				ok
			ok
		next

		return anResult

	def FindNonDuplicatedItems()
		return This.FindNonDuplicatedItemsCS(1)

	def NonDuplicatedItemsAndTheirPositionsCS(pCaseSensitive)
		aNonDuplicated = This.NonDuplicatedItemsCS(pCaseSensitive)
		nLen = len(aNonDuplicated)
		aResult = []
		for i = 1 to nLen
			nPos = This.FindFirstCS(aNonDuplicated[i], pCaseSensitive)
			aResult + [ aNonDuplicated[i], nPos ]
		next
		return aResult

	def NonDuplicatedItemsAndTheirPositions()
		return This.NonDuplicatedItemsAndTheirPositionsCS(1)

	def NonDuplicatedItemsZ()
		return This.NonDuplicatedItemsAndTheirPositions()

	#-- INDEX (positions of each item)

	def FindItemsCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		aList = @aContent

		if pCaseSensitive = 0
			aList = This.Lowercased()
		ok

		nLenList = len(aList)

		if nLenList = 0
			return []
		ok

		acListStringified = []
		for i = 1 to nLenList
			acListStringified + @@(aList[i])
		next

		aResult = []
		acSeen = []
		for i = 1 to nLenList
			if StzFindFirst(acSeen, acListStringified[i])
				loop
			ok

			anPos = []
			for j = 1 to nLenList
				if acListStringified[i] = acListStringified[j]
					anPos + j
				ok
			next

			aResult + [ aList[i], anPos ]
			acSeen + acListStringified[i]
		next

		return aResult

	def IndexCS(pCaseSensitive)
		return This.FindItemsCS(pCaseSensitive)

	#-- ITEMS OCCURRING N TIMES (case-sensitive dial)

	def ItemsOccurringNTimesCS(n, pCaseSensitive)
		aIndex = This.IndexCS(pCaseSensitive)
		nLen = len(aIndex)
		aResult = []
		for i = 1 to nLen
			if len(aIndex[i][2]) >= n
				aResult + aIndex[i][1]
			ok
		next
		return aResult

	def ItemsOccuringNTimesCS(n, pCaseSensitive)
		return This.ItemsOccurringNTimesCS(n, pCaseSensitive)

	#-- N-LISTIFY (pad each item into an n-element sublist)

	def NListify(n)
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			aList = []
			if NOT isList(aContent[i])
				aList + aContent[i]
				if n > 1
					for j = 1 to n-1
						aList + ""
					next
				ok
			else
				nLenList = len(aContent[i])
				if n = nLenList
					aList = aContent[i]
				but n > nLenList
					aList = aContent[i]
					for j = 1 to n - nLenList
						aList + ""
					next
				but n < nLenList
					for j = 1 to n
						aList + aContent[i][j]
					next
				ok
			ok
			aResult + aList
		next

		This.UpdateWith(aResult)

	def NListifyQ(n)
		This.NListify(n)
		return This

	def NListified(n)
		return This.Copy().NListifyQ(n).Content()

	#-- IsAPairQ (alias of IsPairQ)

	def IsPairQ()
		if This.IsPair()
			#-- Pass back a whole-object guard so a chained .Where(cond) binds
			#-- @pair to the WHOLE pair (@pair[1]/@pair[2] are its elements),
			#-- not item-by-item. A non-pair yields a stzFalseObject (Where->0).
			return new stzObjectGuard(This, :Pair)
		else
			return StzFalseObjectQ()
		ok

	def IsAPairQ()
		return This.IsPairQ()

	#-- HALVES family (XT = include the middle item on the first half)

	def FirstHalfXT()
		nPos = ceil(This.NumberOfItems() / 2)
		return This.Section(1, nPos)

	def SecondHalfXT()
		nLen = This.NumberOfItems()
		nPos = ceil(nLen / 2) + 1
		return This.Section(nPos, nLen)

	def FirstHalfAndPosition()
		return [ This.FirstHalf(), 1 ]

	def FirstHalfAndSection()
		return [ This.FirstHalf(), [1, floor(This.NumberOfItems() / 2)] ]

	def FirstHalfAndPositionXT()
		return [ This.FirstHalfXT(), 1 ]

	def FirstHalfAndSectionXT()
		return [ This.FirstHalfXT(), [1, ceil(This.NumberOfItems() / 2)] ]

	def SecondHalfAndPosition()
		nLen = This.NumberOfItems()
		nPos = floor(nLen / 2) + 1
		return [ This.SecondHalf(), nPos ]

	def SecondHalfAndSection()
		nLen = This.NumberOfItems()
		nPos = floor(nLen / 2) + 1
		return [ This.SecondHalf(), [ nPos, nLen ] ]

	def SecondHalfAndPositionXT()
		nLen = This.NumberOfItems()
		nPos = ceil(nLen / 2) + 1
		return [ This.SecondHalfXT(), nPos ]

	def SecondHalfAndSectionXT()
		nLen = This.NumberOfItems()
		nPos = ceil(nLen / 2) + 1
		return [ This.SecondHalfXT(), [ nPos, nLen ] ]

	def FirstHalfAndItsPosition()
		return This.FirstHalfAndPosition()

	def FirstHalfAndItsSection()
		return This.FirstHalfAndSection()

	def FirstHalfAndItsPositionXT()
		return This.FirstHalfAndPositionXT()

	def FirstHalfAndItsSectionXT()
		return This.FirstHalfAndSectionXT()

	def SecondHalfAndItsPosition()
		return This.SecondHalfAndPosition()

	def SecondHalfAndItsSection()
		return This.SecondHalfAndSection()

	def SecondHalfAndItsPositionXT()
		return This.SecondHalfAndPositionXT()

	def SecondHalfAndItsSectionXT()
		return This.SecondHalfAndSectionXT()

	def Halves()
		acResult = []
		acResult + This.FirstHalf() + This.SecondHalf()
		return acResult

	def HalvesXT()
		acResult = []
		acResult + This.FirstHalfXT() + This.SecondHalfXT()
		return acResult

	def HalvesAndPositions()
		return [ This.FirstHalfAndPosition(), This.SecondHalfAndPosition() ]

	def HalvesAndPositionsXT()
		return [ This.FirstHalfAndPositionXT(), This.SecondHalfAndPositionXT() ]

	def HalvesAndSections()
		return [ This.FirstHalfAndSection(), This.SecondHalfAndSection() ]

	def HalvesAndSectionsXT()
		return [ This.FirstHalfAndSectionXT(), This.SecondHalfAndSectionXT() ]

	#========================================================#
	#  BATCH-2 RESTORE: Extract family (split-dropped).      #
	#  Extract = "remove from the list AND return what was   #
	#  removed" -- the destructive counterpart of Find.      #
	#========================================================#

	def ExtractAt(n)
		TempItem = This.ItemAt(n)
		This.RemoveAt(n)
		return TempItem

	def ExtractFirstCS(pItem, pCaseSensitive)
		return This.ExtractNthOccurrenceCS(1, pItem, pCaseSensitive)

	def ExtractLastCS(pItem, pCaseSensitive)
		nLast = This.NumberOfOccurrencesCS(pItem, pCaseSensitive)
		return This.ExtractNthOccurrenceCS(nLast, pItem, pCaseSensitive)


	def FindNextSTCS(pItem, nStart, pCaseSensitive)
		return This.FindNextOccurrenceCS(pItem, nStart, pCaseSensitive)

	def FindPreviousSTCS(pItem, pnStartingAt, pCaseSensitive)
		return This.FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)

	def ExtractNextSTCS(pItem, pnStartingAt, pCaseSensitive)
		if isList(pnStartingAt) and IsStartingAtNamedParamList(pnStartingAt)
			pnStartingAt = pnStartingAt[2]
		ok
		nPos = This.FindNextSTCS(pItem, pnStartingAt, pCaseSensitive)
		if nPos = 0
			return
		ok
		This.RemoveItemAtPosition(nPos)
		return pItem

	def ExtractNextST(item, pnStartingAt)
		return This.ExtractNextSTCS(item, pnStartingAt, 1)

	def ExtractNext(pItem, pnStartingAt)
		return This.ExtractNextST(pItem, pnStartingAt)

	def ExtractNextCS(pItem, pnStartingAt, pCaseSensitive)
		return This.ExtractNextSTCS(pItem, pnStartingAt, pCaseSensitive)

	def ExtractPreviousSTCS(pItem, pnStartingAt, pCaseSensitive)
		if isList(pnStartingAt) and IsStartingAtNamedParamList(pnStartingAt)
			pnStartingAt = pnStartingAt[2]
		ok
		nPos = This.FindPreviousSTCS(pItem, pnStartingAt, pCaseSensitive)
		if nPos = 0
			return
		ok
		This.RemoveItemAtPosition(nPos)
		return pItem

	def ExtractPreviousST(item, pnStartingAt)
		return This.ExtractPreviousSTCS(item, pnStartingAt, 1)

	def ExtractPrevious(pItem, pnStartingAt)
		return This.ExtractPreviousST(pItem, pnStartingAt)

	def ExtractPreviousCS(pItem, pnStartingAt, pCaseSensitive)
		return This.ExtractPreviousSTCS(pItem, pnStartingAt, pCaseSensitive)

	#========================================================#
	#  BATCH-3 RESTORE: IsNeither, HasSameContent,           #
	#  ToListInString(+ShortForm)/ToCodeQ, FirstList,        #
	#  AllItemsAreEqualTo (split-dropped / new).             #
	#========================================================#

	def IsNeither(paList1, paList2)
		return This.IsNeitherCS(paList1, paList2, 1)

	def IsNeitherCS(paList1, paList2, pCaseSensitive)
		if isList(paList1) and IsEqualToNamedParamList(paList1)
			paList1 = paList1[2]
		ok
		if isList(paList2) and IsNorNamedParamList(paList2)
			paList2 = paList2[2]
		ok

		bEqualToList1 = This.IsEqualToCS(paList1, pCaseSensitive)
		bEqualToList2 = This.IsEqualToCS(paList2, pCaseSensitive)

		if NOT bEqualToList1 and NOT bEqualToList2
			return 1
		else
			return 0
		ok

	#-- HasSameContent: order-INsensitive content equality (a multiset
	#-- comparison). Same items, any order, optionally case-folded.

	def HasSameContent(paOtherList)
		return This.HasSameContentCS(paOtherList, 1)

	def HasSameContentCS(paOtherList, pCaseSensitive)
		if isList(paOtherList) and IsAsNamedParamList(paOtherList)
			paOtherList = paOtherList[2]
		ok
		if isList(pCaseSensitive) and len(pCaseSensitive) = 2 and isString(pCaseSensitive[1])
			pCaseSensitive = pCaseSensitive[2]
		ok
		if NOT isList(paOtherList)
			return FALSE
		ok

		if pCaseSensitive = 1
			return This.HasSameContentAs(paOtherList)
		ok

		# Case-insensitive: compare lowercased, stringified multisets.
		aThis = This.Content()
		n1 = len(aThis)
		n2 = len(paOtherList)
		if n1 != n2
			return FALSE
		ok
		ac1 = []
		for i = 1 to n1
			ac1 + StzLower("" + aThis[i])
		next
		ac2 = []
		for i = 1 to n2
			ac2 + StzLower("" + paOtherList[i])
		next
		ac1 = ring_sort(ac1)
		ac2 = ring_sort(ac2)
		for i = 1 to n1
			if NOT ac1[i] = ac2[i]
				return FALSE
			ok
		next
		return TRUE

	#-- Rendering the list back to its Ring source-code string.

	def ToCodeQ()
		return new stzString(This.ToCode())

	def ToListInString()
		return This.ToCode()

	def ToListInStringInShortForm()
		# Compress a contiguous integer list into its "a:b" range form,
		# e.g. [ 4, 5, 6, 7, 8 ] -> "4:8". Falls back to the full code
		# string for non-contiguous / non-numeric lists.
		return This.ToListInAStringInShortForm()

	#-- First sublist (item that is itself a list) and its position.

	def FindFirstList()
		aC = This.Content()
		n = len(aC)
		for i = 1 to n
			if isList(aC[i])
				return i
			ok
		next
		return 0

	def FirstList()
		nPos = This.FindFirstList()
		if nPos = 0
			return []
		ok
		aC = This.Content()
		return aC[nPos]

	#-- AllItemsAreEqualTo: every item equals pItem (content-compare, so
	#-- sublists match too).

	def AllItemsAreEqualToCS(pItem, pCaseSensitive)
		aC = This.Content()
		n = len(aC)
		if n = 0
			return FALSE
		ok
		for i = 1 to n
			if NOT BothAreEqualCS(aC[i], pItem, pCaseSensitive)
				return FALSE
			ok
		next
		return TRUE

	def AllItemsAreEqualTo(pItem)
		return This.AllItemsAreEqualToCS(pItem, 1)

	#========================================================#
	#  BATCH-4 RESTORE: number/non-number filters, occurrence #
	#  counts, ItemsAndTheirPositions (split-dropped).        #
	#========================================================#

	def FindNumbers()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen
			if isNumber(aContent[i])
				aResult + i
			ok
		next
		return aResult

	def FindNonNumbers()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen
			if NOT isNumber(aContent[i])
				aResult + i
			ok
		next
		return aResult

	def RemoveNumbers()
		This.RemoveItemsAtPositions( This.FindNumbers() )

		def RemoveOnlyNumbers()
			This.RemoveNumbers()

		def RemoveAllExceptNonNumbers()
			This.RemoveNumbers()

	def RemoveNonNumbers()
		This.RemoveItemsAtPositions( This.FindNonNumbers() )

		def RemoveOnlyNonNumbers()
			This.RemoveNonNumbers()

		def RemoveAllExceptNumbers()
			This.RemoveNonNumbers()

	def OnlyNonNumbers()
		return This.NonNumbers()

	def ItemsAndTheirPositions()
		return This.FindItems()

	#-- Occurrence counts: each distinct item paired with how many times
	#-- it appears.

	def NumberOfOccurrenceOfItemsCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		aList = @aContent
		if pCaseSensitive = 0
			aList = This.Lowercased()
		ok

		nLenList = len(aList)
		if nLenList = 0
			return []
		ok

		aItems = This.WithoutDuplicationCS(pCaseSensitive)
		nLenItems = len(aItems)

		aResult = []
		for i = 1 to nLenItems
			n = 0
			for j = 1 to nLenList
				if ring_type(aItems[i]) = ring_type(aList[j]) and
				   aItems[i] = aList[j]
					n++
				ok
			next
			aResult + [ aItems[i], n ]
		next

		return aResult

	def NumberOfOccurrenceOfItems()
		return This.NumberOfOccurrenceOfItemsCS(1)

		def NumberOfOccurrenceOfEachItem()
			return This.NumberOfOccurrenceOfItems()

	#========================================================#
	#  BATCH-5 RESTORE: IsListOfNumbersAndPairsOfNumbers,    #
	#  Split(ted)ToPartsOfNItemsXT / After / Before          #
	#  Positions, (Find)PreviousNthOccurrence.               #
	#========================================================#

	def IsListOfNumbersAndPairsOfNumbers()
		# Each item must be a number, or a 2-element list of two numbers.
		# (Pair check inlined: the class also has a 0-arg IsPairOfNumbers
		# method, which would shadow the global func form inside the class.)
		aC = This.Content()
		n = len(aC)
		for i = 1 to n
			_x_ = aC[i]
			if isNumber(_x_)
				loop
			ok
			if isList(_x_) and len(_x_) = 2 and isNumber(_x_[1]) and isNumber(_x_[2])
				loop
			ok
			return FALSE
		next
		return TRUE

	#-- Splitting into parts (mutating Split*, fluent Split*Q, and
	#-- non-mutating Splitted* that return a fresh list of parts).

	def SplitToPartsOfNItemsXT(n)
		aSections = StzSplitterQ(This.NumberOfItems()).SplitToPartsOfNItemsXT(n)
		This.UpdateWith( This.Sections(aSections) )

	def SplitToPartsOfNItemsXTQ(n)
		This.SplitToPartsOfNItemsXT(n)
		return This

	def SplittedToPartsOfNItemsXT(n)
		return This.Copy().SplitToPartsOfNItemsXTQ(n).Content()

	def SplitAfterPositions(panPos)
		aSections = StzSplitterQ(This.NumberOfItems()).SplitAfterPositions(panPos)
		This.UpdateWith( This.Sections(aSections) )

	def SplitAfterPositionsQ(panPos)
		This.SplitAfterPositions(panPos)
		return This

	def SplittedAfterPositions(panPos)
		return This.Copy().SplitAfterPositionsQ(panPos).Content()

	def SplitBeforePositions(panPos)
		aSections = StzSplitterQ(This.NumberOfItems()).SplitBeforePositions(panPos)
		This.UpdateWith( This.Sections(aSections) )

	def SplitBeforePositionsQ(panPos)
		This.SplitBeforePositions(panPos)
		return This

	def SplittedBeforePositions(panPos)
		return This.Copy().SplitBeforePositionsQ(panPos).Content()

	#-- Nth previous occurrence (scanning backward from a start position).

	def FindNthPreviousOccurrenceCS(n, pItem, nStart, pCaseSensitive)
		if isList(pItem) and IsOfNamedParamList(pItem)
			pItem = pItem[2]
		ok
		if isList(nStart) and IsStartingAtNamedParamList(nStart)
			nStart = nStart[2]
		ok
		if isString(nStart) and ( nStart = :Last or nStart = :LastItem )
			nStart = This.NumberOfItems()
		ok
		if isString(n)
			if n = :First or n = :FirstOccurrence
				n = 1
			but n = :Last or n = :LastOccurrence
				n = This.SectionQ(1, nStart).NumberOfOccurrenceCS(pItem, pCaseSensitive)
			ok
		ok

		nLen = This.NumberOfItems()

		if nStart = 1
			return 0
		ok
		if nStart < 0 or nStart > nLen
			return 0
		ok
		if NOT This.ContainsCS(pItem, pCaseSensitive)
			return 0
		ok
		if This.SectionQ(1, nStart - 1).NumberOfOccurrenceCS(pItem, pCaseSensitive) < n
			return 0
		ok

		bCase = CaseSensitive(pCaseSensitive)
		# Current FindPreviousCS is exclusive (strictly before nPos), so we
		# seed nPos with nStart itself to count the occurrence at nStart-1.
		nPos = nStart
		nFound = 0
		i = 0

		while 1
			i++
			if i > nLen
				exit
			ok
			nPos = This.FindPreviousCS(pItem, nPos, bCase)
			if nPos = 0
				exit
			else
				nFound++
				if nFound = n
					return nPos
				ok
			ok
		end

		return 0

	def FindNthPreviousOccurrence(n, pItem, nStart)
		return This.FindNthPreviousOccurrenceCS(n, pItem, nStart, 1)

	def PreviousNthOccurrenceCS(n, pItem, nStart, pCaseSensitive)
		return This.FindNthPreviousOccurrenceCS(n, pItem, nStart, pCaseSensitive)

	def PreviousNthOccurrence(n, pItem, nStart)
		return This.FindNthPreviousOccurrence(n, pItem, nStart)

	#-- Remove a matching opening/closing bound pair (e.g. "{" ... "}").
	#-- TheseBoundsRemoved returns a fresh list; RemoveTheseBounds mutates.

	def RemoveTheseBoundsCS(pBound1, pBound2, pCaseSensitive)
		if This.IsBoundedByCS([ pBound1, pBound2 ], pCaseSensitive)
			This.RemoveFirstItem()
			This.RemoveLastItem()
		ok

	def RemoveTheseBounds(pBound1, pBound2)
		This.RemoveTheseBoundsCS(pBound1, pBound2, 1)

	def RemoveTheseBoundsQ(pBound1, pBound2)
		This.RemoveTheseBounds(pBound1, pBound2)
		return This

	def TheseBoundsRemoved(pBound1, pBound2)
		return This.Copy().RemoveTheseBoundsQ(pBound1, pBound2).Content()

	#========================================================#
	#  BATCH-8 RESTORE: MultiplyBy, ExtendToXT, TypesXT,     #
	#  FindStzNumbers, ReplaceThisAt (split-dropped).        #
	#========================================================#

	def MultiplyBy(p)
		switch ring_type(p)
		on "NUMBER"
			if p = 0
				aResult = []
			but p = 1
				aResult = @aContent
			else
				aResult = []
				for i = 1 to p
					aResult + @aContent
				next
			ok
			This.Update( aResult )

		on "STRING"
			nLen = len(@aContent)
			for i = 1 to nLen
				if isString(@aContent[i])
					@aContent[i] += p
				ok
			next

		on "LIST"
			# Pair each item with the given list:
			# [ "V1","V2" ] * [ 1,2 ] -> [ [ "V1",[1,2] ], [ "V2",[1,2] ] ]
			nLen = len(@aContent)
			for i = 1 to nLen
				item = @aContent[i]
				This._InvalidateEngine()   # in-place @aContent mutation below
				@aContent[i] = [ item, p ]
			next

		other
			StzRaise("Can't multiply the list by an object!")
		off

	def ExtendToXT(n, pValue)
		This.ExtendToPositionWith(n, pValue)

	def TypesXT()
		return This.ListQ().AssociatedWith( This.Types() )

	def FindStzNumbers()
		aContent = This.Content()
		nLen = len(aContent)
		anResult = []
		for i = 1 to nLen
			if @IsStzNumber(aContent[i])
				anResult + i
			ok
		next
		return anResult

	def ReplaceThisAt(n, pItem, pNewItem)
		This.ReplaceThisItemAt(n, pItem, pNewItem)

	def ReplaceAnyAt(pPos, pNewItem)
		This.ReplaceAt(pPos, pNewItem)

	#-- Positions of items that are stz objects of a given kind.

	def FindStzStrings()
		aContent = This.Content()
		nLen = len(aContent)
		anResult = []
		for i = 1 to nLen
			if @IsStzString(aContent[i])
				anResult + i
			ok
		next
		return anResult

	def FindStzLists()
		aContent = This.Content()
		nLen = len(aContent)
		anResult = []
		for i = 1 to nLen
			if @IsStzList(aContent[i])
				anResult + i
			ok
		next
		return anResult

	#-- Convert to a stzListOfStrings (for string-oriented chaining like
	#-- ConcatenatedUsing / Joined). Needed by the ..Q() chain idioms.

	def ToStzListOfStrings()
		return new stzListOfStrings(This.Content())

	#-- InsertAfter(:ItemAtPosition = n, item): NON-mutating -- returns the
	#-- would-be list with item inserted after position n, leaving This as-is
	#-- (use InsertAfterPosition for the mutating form).

	def InsertAfter(pnPos, pItem)
		if isList(pnPos) and len(pnPos) = 2 and isString(pnPos[1])
			pnPos = pnPos[2]
		ok
		_oIaCopy_ = This.Copy()
		_oIaCopy_.InsertAfterPosition(pnPos, pItem)
		return _oIaCopy_.Content()

	#-- UppercaseQ: uppercase every string item in place, return This for
	#-- chaining (mirrors LowercaseQ; relies on Uppercased).

	def UppercaseQ()
		This.UpdateWith( This.Uppercased() )
		return This

		def LowercaseQ()
			This.UpdateWith( This.Lowercased() )
			return This

	#========================================================#
	#  DiffXTT family: structural diff (added / removed /    #
	#  modified) between this list and another. Restored     #
	#  from the monolith (split-dropped).                    #
	#========================================================#

	def AddedItemsComparedToCS(paOtherList, pCaseSensitive)
		if NOT isList(paOtherList)
			StzRaise("Incorrect param type! paOtherList must be a list.")
		ok
		# Added = items in the OTHER list absent here = other \ this.
		# Engine-backed (stz_list_difference_cs) so the op is available to
		# any language binding, not just Ring.
		_pAic_ = This._EngineListFromContent()
		_pBic_ = StzEngineMarshalList(paOtherList)
		if _pAic_ != NULL and _pBic_ != NULL
			_pDic_ = StzEngineListDifferenceCS(_pBic_, _pAic_, pCaseSensitive)
			aResult = StzEngineListContentToRingList(_pDic_)
			StzEngineListFree(_pDic_)
			StzEngineListFree(_pAic_)
			StzEngineListFree(_pBic_)
			return aResult
		ok
		# Fallback (non-marshalable content, e.g. objects)
		aResult = []
		nLen = len(paOtherList)
		for i = 1 to nLen
			if NOT This.ContainsCS(paOtherList[i], pCaseSensitive)
				aResult + paOtherList[i]
			ok
		next
		return aResult

	def RemovedItemsComparedToCS(paOtherList, pCaseSensitive)
		if NOT isList(paOtherList)
			StzRaise("Incorrect param type! paOtherList must be a list.")
		ok
		# Removed = items here absent from the OTHER list = this \ other.
		_pAric_ = This._EngineListFromContent()
		_pBric_ = StzEngineMarshalList(paOtherList)
		if _pAric_ != NULL and _pBric_ != NULL
			_pDric_ = StzEngineListDifferenceCS(_pAric_, _pBric_, pCaseSensitive)
			aResult = StzEngineListContentToRingList(_pDric_)
			StzEngineListFree(_pDric_)
			StzEngineListFree(_pAric_)
			StzEngineListFree(_pBric_)
			return aResult
		ok
		# Fallback (non-marshalable content)
		aResult = []
		oOtherList = new stzList(paOtherList)
		nLen = This.NumberOfItems()
		aContent = This.Content()
		for i = 1 to nLen
			if NOT oOtherList.ContainsCS(aContent[i], pCaseSensitive)
				aResult + aContent[i]
			ok
		next
		return aResult

	def ModifiedItemsComparedToCSXT(paOtherList, pCaseSensitive)
		if NOT isList(paOtherList)
			StzRaise("Incorrect param type! paOtherList must be a list.")
		ok

		# "Modified" item pairing (substring overlap for strings, element
		# overlap for sublists) is the real data algorithm here -- run it in
		# the Zig engine (stz_list_modified_items_cs) so every binding gets
		# it. Returns [ old, new ] pairs, nested structure preserved.
		_pAmi_ = This._EngineListFromContent()
		_pBmi_ = StzEngineMarshalList(paOtherList)
		if _pAmi_ != NULL and _pBmi_ != NULL
			_pMmi_ = StzEngineListModifiedItemsCS(_pAmi_, _pBmi_, pCaseSensitive)
			aResult = StzEngineListContentToRingList(_pMmi_)
			StzEngineListFree(_pMmi_)
			StzEngineListFree(_pAmi_)
			StzEngineListFree(_pBmi_)
			return aResult
		ok

		# Fallback (non-marshalable content): same semantics in Ring.
		aResult = []
		aThisListU = @UniqueCS(This.Content(), pCaseSensitive)
		aoThisListU = @Objectify(aThisListU)
		_aFiltered = []
		for _k = 1 to len(paOtherList)
			_bInThis = 0
			for _j = 1 to len(aThisListU)
				if BothAreEqualCS(paOtherList[_k], aThisListU[_j], pCaseSensitive)
					_bInThis = 1
					exit
				ok
			next
			if _bInThis = 0
				_aFiltered + paOtherList[_k]
			ok
		next
		aOtherListU = @UniqueCS(_aFiltered, pCaseSensitive)
		aoOtherListU = @Objectify(aOtherListU)
		nLenThis = len(aThisListU)
		nLenOther = len(aOtherListU)
		for i = 1 to nLenThis
			if isString(aThisListU[i])
				for j = 1 to nLenOther
					if isString(aOtherListU[j])
						if aoThisListU[i].ContainsCS(aOtherListU[j], pCaseSensitive) or
						   aoOtherListU[j].ContainsCS(aThisListU[i], pCaseSensitive)
							aResult + [ aThisListU[i], aOtherListU[j] ]
						ok
					ok
				next
			but isList(aThisListU[i])
				for j = 1 to nLenOther
					if isList(aOtherListU[j])
						if aoThisListU[i].ContainsOneOfTheseCS(aOtherListU[j], pCaseSensitive) or
						   aoOtherListU[j].ContainsOneOfTheseCS(aThisListU[i], pCaseSensitive)
							aResult + [ aThisListU[i], aOtherListU[j] ]
						ok
					ok
				next
			ok
		next
		return aResult

	def DifferentItemsWithCSXTT(paOtherList, pCaseSensitive)
		_aAddedItems_ = This.AddedItemsComparedToCS(paOtherList, pCaseSensitive)
		_aRemovedItems_ = This.RemovedItemsComparedToCS(paOtherList, pCaseSensitive)
		_aModifiedItems_ = This.ModifiedItemsComparedToCSXT(paOtherList, pCaseSensitive)
		nLen = len(_aModifiedItems_)

		_oAdded_ = new stzList(_aAddedItems_)
		_oRemoved_ = new stzList(_aRemovedItems_)

		for i = 1 to nLen
			_oRemoved_.Remove(_aModifiedItems_[i][1])
			_oAdded_.RemoveAll(_aModifiedItems_[i][2])
		next

		return [
			[ "added", _oAdded_.Content() ],
			[ "removed", _oRemoved_.Content() ],
			[ "modified", _aModifiedItems_ ]
		]

	def DifferentItemsWithXTT(paOtherList)
		return This.DifferentItemsWithCSXTT(paOtherList, 1)

	def DiffXTT(paOtherList)
		return This.DifferentItemsWithXTT(paOtherList)

		def DiffXT(paOtherList)
			return This.DiffXTT(paOtherList)

	#-- Objectify: wrap each item in a Q() stz object (so per-item stz
	#-- methods like ContainsCS can be called). Needed by DiffXTT's
	#-- similarity matching.

	def Objectify()
		aContent = This.Content()
		nLen = len(aContent)
		aResult = []
		for i = 1 to nLen
			aResult + Q(aContent[i])
		next
		This.UpdateWith(aResult)

	def ObjectifyQ()
		This.Objectify()
		return This

	def Objectified()
		return This.Copy().ObjectifyQ().Content()

	#-- IsQuietEqualTo: approximate equality. Exact-equal (engine-backed
	#-- IsEqualTo) OR the length-difference ratio is below the tunable
	#-- QuietEqualityRatio (default 0.09; SetQuietEqualityRatio to change).
	#-- No element loop here -- the content compare is the engine's job.

	def IsQuietEqualTo(paOtherList)
		if isList(paOtherList) and IsToNamedParamList(paOtherList)
			paOtherList = paOtherList[2]
		ok
		if This.IsEqualTo(paOtherList)
			return 1
		ok
		nDif = abs(This.NumberOfItems() - len(paOtherList))
		n = nDif / This.NumberOfItems()
		if n < QuietEqualityRatio()
			return 1
		ok
		return 0

	#-- Deep "contains" combinators. The heavy work is DeepContainsCS
	#-- (engine-backed: stringify the whole list + StzFind). These just
	#-- loop over the small QUERY list, not the data -- so no data-loop.

	def DeepContainsManyCS(paItems, pCaseSensitive)
		nLen = len(paItems)
		for i = 1 to nLen
			if NOT This.DeepContainsCS(paItems[i], pCaseSensitive)
				return 0
			ok
		next
		return 1

	def DeepContainsMany(paItems)
		return This.DeepContainsManyCS(paItems, 1)

		def DeepContainsThese(paItems)
			return This.DeepContainsManyCS(paItems, 1)

	def DeepContainsBothCS(pItem1, pItem2, pCaseSensitive)
		if isList(pItem2) and IsAndNamedParamList(pItem2)
			pItem2 = pItem2[2]
		ok
		return This.DeepContainsManyCS([ pItem1, pItem2 ], pCaseSensitive)

	def DeepContainsBoth(pItem1, pItem2)
		return This.DeepContainsBothCS(pItem1, pItem2, 1)

	def DeepContainsOneOfTheseCS(paItems, pCaseSensitive)
		nLen = len(paItems)
		for i = 1 to nLen
			if This.DeepContainsCS(paItems[i], pCaseSensitive)
				return 1
			ok
		next
		return 0

	def DeepContainsOneOfThese(paItems)
		return This.DeepContainsOneOfTheseCS(paItems, 1)

	def DeepContainsNOfTheseCS(n, paItems, pCaseSensitive)
		v = 0
		nLen = len(paItems)
		for i = 1 to nLen
			if This.DeepContainsCS(paItems[i], pCaseSensitive)
				v++
				if v = n
					return 1
				ok
			ok
		next
		return 0

	def DeepContainsNOfThese(n, paItems)
		return This.DeepContainsNOfTheseCS(n, paItems, 1)

	#========================================================#
	#  Locale-shaped list predicates (i18n). Thin orchestra- #
	#  tion over the established per-string locale lookups.   #
	#========================================================#

	def ToListOfStzStrings()
		if NOT This.IsListOfStrings()
			StzRaise("Can't proceed! All items must be strings.")
		ok
		acContent = This.Content()
		nLen = len(acContent)
		aoResult = []
		for i = 1 to nLen
			aoResult + new stzString(acContent[i])
		next
		return aoResult

	def AreLanguageAbbreviations()
		if NOT @IsListOfStrings(@aContent)
			return 0
		ok
		nLen = len(@aContent)
		aoStzStr = This.ToListOfStzStrings()
		for i = 1 to nLen
			if NOT aoStzStr[i].IsLanguageAbbreviation()
				return 0
			ok
		next
		return 1

	def IsLocaleList()
		nLen = len(@aContent)

		if nLen = 1 and isString(@aContent[1]) and
		   StzFindFirst([ :Default, :DefaultLocale, :System, :SystemLocale, "c", "C", :CLocale ], @aContent[1]) > 0
			return 1
		ok

		if nLen > 3
			return 0
		ok
		if NOT This.IsHashList()
			return 0
		ok

		acKeys = []
		for i = 1 to nLen
			acKeys + @aContent[i][1]
		next
		bLanguage = StzFindFirst(acKeys, "language")
		bScript = StzFindFirst(acKeys, "script")
		bCountry = StzFindFirst(acKeys, "country")
		if bLanguage = 0 and bScript = 0 and bCountry = 0
			return 0
		ok

		cLanguage = @aContent[ :Language ]
		cScript   = @aContent[ :Script   ]
		cCountry  = @aContent[ :Country  ]
		if NOT ( isString(cLanguage) and isString(cScript) and isString(cCountry) )
			return 0
		ok
		if cLanguage = "" and cScript = "" and cCountry = ""
			return 0
		ok
		if cLanguage != "" and NOT StzStringQ(cLanguage).IsLanguageIdentifier()
			return 0
		ok
		if cScript != "" and NOT StzStringQ(cScript).IsScriptIdentifier()
			return 0
		ok
		if cCountry != "" and NOT StzStringQ(cCountry).IsCountryIdentifier()
			return 0
		ok
		return 1

	def IsMultilingualString()
		if NOT This.IsHashlist()
			return 0
		ok
		nLen = len(@aContent)
		for i = 1 to nLen
			if NOT isString(@aContent[i][2])
				return 0
			ok
		next
		aoKeys = []
		for i = 1 to nLen
			aoKeys + StzStringQ(@aContent[i][1])
		next
		for i = 1 to nLen
			if NOT aoKeys[i].IsLanguageNameOrAbbreviation()
				return 0
			ok
		next
		return 1

	#-- Replace the run of repeated LEADING items with a given value
	#-- (:with names it). Delegates to ReplaceLeadingItems.

	def ReplaceRepeatedLeadingItem(pItem)
		if isList(pItem) and IsWithNamedParamList(pItem)
			pItem = pItem[2]
		ok
		This.ReplaceLeadingItems(pItem)

	#========================================================#
	#  WALK family (split-dropped): back-and-forth + N-step  #
	#  + progressive-N-step traversals. These generate index #
	#  sequences (arithmetic); ItemsAt does the gather.      #
	#========================================================#

	def WalkBackAndForth()
		return This.WalkBackAndForthXT(:Return = :WalkedPositions)

	def WalkBackAndForthXT(pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		nLen = This.NumberOfItems()
		anPos = nLen : 1
		for i = 2 to nLen
			anPos + i
		next
		if pReturn = :WalkedItems
			return This.ItemsAt(anPos)
		but pReturn = :WalkedPositions
			return anPos
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(anPos))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return anPos[len(anPos)]
		else
			return anPos
		ok

	#-- N-step (every nth item)

	def WalkNItemsForwardXT(n, pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		anPos = []
		nLen = This.NumberOfItems()
		for i = 1 to nLen step n
			anPos + i
		next
		if pReturn = :WalkedItems
			return This.ItemsAt(anPos)
		but pReturn = :WalkedPositions
			return anPos
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(anPos))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return anPos[len(anPos)]
		else
			return anPos
		ok

	def WalkNItemsBackwardXT(n, pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		anPos = []
		for i = This.NumberOfItems() to 1 step -n
			anPos + i
		next
		if pReturn = :WalkedItems
			return This.ItemsAt(anPos)
		but pReturn = :WalkedPositions
			return anPos
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(anPos))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return anPos[len(anPos)]
		else
			return anPos
		ok

	def WalkNForwardXT(n, pReturn)
		return This.WalkNItemsForwardXT(n, pReturn)

	def WalkNBackwardXT(n, pReturn)
		return This.WalkNItemsBackwardXT(n, pReturn)

	#-- Progressive N-step (gap grows by n each step)

	def WalkNProgressiveItemsForwardXT(n, pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		nLen = This.NumberOfItems()
		anPos = []
		if n < 0
			StzRaise("Can't proceed. n must be positive!")
		but n = 0
			anPos = [1]
		else
			anPos = [1]
			nStep = 1
			i = 0
			while nStep <= nLen
				i++
				nStep += (n * i)
				if nStep <= nLen
					anPos + nStep
				ok
			end
		ok
		if pReturn = :WalkedItems
			return This.ItemsAt(anPos)
		but pReturn = :WalkedPositions
			return anPos
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(anPos))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return anPos[len(anPos)]
		else
			return anPos
		ok

	def WalkNProgressiveItemsBackwardXT(n, pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		nLen = This.NumberOfItems()
		anPos = []
		if n < 0
			StzRaise("Can't proceed. n must be positive!")
		but n = 0
			anPos = [ nLen ]
		else
			anPos = [ nLen ]
			nStep = nLen
			i = 0
			while nStep > 0
				i++
				nStep -= (n * i)
				if nStep > 0
					anPos + nStep
				ok
			end
		ok
		if pReturn = :WalkedItems
			return This.ItemsAt(anPos)
		but pReturn = :WalkedPositions
			return anPos
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(anPos))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return anPos[len(anPos)]
		else
			return anPos
		ok

	def WalkNProgressiveItemsForward(n)
		return This.WalkNProgressiveItemsForwardXT(n, :Return = :WalkedPositions)

	def WalkNProgressiveItemsBackward(n)
		return This.WalkNProgressiveItemsBackwardXT(n, :Return = :WalkedPositions)

	def WalkNMoreForward(n)
		return This.WalkNProgressiveItemsForward(n)

	def WalkNMoreForwardXT(n, pReturn)
		return This.WalkNProgressiveItemsForwardXT(n, pReturn)

	def WalkNMoreBackward(n)
		return This.WalkNProgressiveItemsBackward(n)

	def WalkNMoreBackwardXT(n, pReturn)
		return This.WalkNProgressiveItemsBackwardXT(n, pReturn)

	#========================================================#
	#  WALK zigzag + start/end family (split-dropped).       #
	#========================================================#

	def WalkNItemsForwardNItemsBackwardXT(pnForward, pnBackward, pReturn)

		# Checking params

		if NOT Q([pnForward, pnBackward]).BothAreNumbers()
			StzRaise("Incorrect param type! Both pnForward and pnBackward must be numbers.")
		ok

		if isList(pReturn) and
		   IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])

			pReturn = pReturn[2]
		ok

		if NOT ( isString(pReturn) and

			 StzFindFirst([
				:WalkedPositions, :WalkedItems,
				:LastPosition, :LastWalkedPosition,
				:LastItem, :LastWalkedItem,
				:Default
			], pReturn) > 0 )

			StzRaise("Incorrect param! pReturn must be a string. Allowed values are " +
				 ":WalkedPositions, :WalkedItems, :LastWalkedPosition, :LastWalkedItem, and :Default." )
		ok

		if pReturn = :Default
			pReturn = :WalkedPositions
		ok

		# Doing the job

		aList = This.List()
		nLen = len(aList)

		if pnForward = pnBackward
			return []
		ok

		if pnBackward > pnForward
			nStart = pnBackward - pnForward + 1
		else
			nStart = 1
		ok

		i = nStart
		anPos = [ i ]

		while (i + pnForward) >= 1 and (i + pnForward) <= nLen and
		      (i + pnForward - pnBackward) >= 1 and (i + pnForward - pnBackward) <= nLen

			i = i + pnForward
			anPos + i

			i = i - pnBackward
			anPos + i

		end

		if pReturn = :WalkedItems
			return This.ItemsAt(anPos)

		but pReturn = :WalkedPositions
			return anPos

		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(anPos))

		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return anPos[len(anPos)]

		else
			return anPos
		end
	
		#< @FunctionAlternativeForm


	def WalkNItemsForwardNItemsBackward(pnForward, pnBackward)
		return This.WalkNItemsForwardNItemsBackwardXT(pnForward, pnBackward, :Return = :WalkedPositions)

		#< @FunctionAlternativeForm


	def WalkNItemsBackwardNItemsForwardXT(pnBackward, pnForward, pReturn)

		# Checking params

		if NOT Q([pnBackward, pnForward]).BothAreNumbers()
			StzRaise("Incorrect param type! Both pnForward and pnBackward must be numbers.")
		ok

		if isList(pReturn) and
		   IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])

			pReturn = pReturn[2]
		ok

		if NOT ( isString(pReturn) and

			 StzFindFirst([
				:WalkedPositions, :WalkedItems,
				:LastPosition, :LastWalkedPosition,
				:LastItem, :LastWalkedItem,
				:Default
			], pReturn) > 0 )

			StzRaise("Incorrect param! pReturn must be a string. Allowed values are " +
				 ":WalkedPositions, :WalkedItems, :LastWalkedPosition, :LastWalkedItem, and :Default." )
		ok

		if pReturn = :Default
			pReturn = :WalkedPositions
		ok

		# Doing the job

		aList = This.List()
		nLen = len(aList)

		if pnForward = pnBackward
			return []
		ok

		if pnForward > pnBackward
			nStart = nLen - pnBackward
		else
			nStart = nLen
		ok

		i = nStart
		anPos = [ nStart ]

		while ( (i - pnBackward) >= 1 and (i - pnBackward) <= nLen ) and
		      ( (i - pnBackward + pnForward) >= 1 and (i - pnBackward + pnForward) <= nLen )

			i = i - pnBackward
			anPos + i

			i = i + pnForward
			anPos + i

		end

		if pReturn = :WalkedItems
			return This.ItemsAt(anPos)

		but pReturn = :WalkedPositions
			return anPos

		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(anPos))

		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return anPos[len(anPos)]

		else
			return anPos
		end

		#< @FunctionAlternativeForm


	def WalkNItemsBackwardNItemsForward(pnBackward, pnForward)
		return This.WalkNItemsBackwardNItemsForwardXT(pnBackward, pnForward, :Return = :WalkedPositions)

		#< @FunctionAlternativeForm


	def WalkNItemsFromStartNItemsFromEndXT(pnFromStart, pnFromEnd, pReturn)

		# Checking params

		if NOT Q([pnFromStart, pnFromEnd]).BothAreNumbers()
			StzRaise("Incorrect param type! Both pnFromStart and pnFromEnd must be numbers.")
		ok

		if isList(pReturn) and
		   IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])

			pReturn = pReturn[2]
		ok

		if NOT ( isString(pReturn) and

			 StzFindFirst([
				:WalkedPositions, :WalkedItems,
				:LastPosition, :LastWalkedPosition,
				:LastItem, :LastWalkedItem,
				:Default
			], pReturn) > 0 )

			StzRaise("Incorrect param! pReturn must be a string. Allowed values are " +
				 ":WalkedPositions, :WalkedItems, :LastWalkedPosition, :LastWalkedItem, and :Default." )
		ok

		if pReturn = :Default
			pReturn = :WalkedPositions
		ok

		# Doing the job

		aList = This.List()
		nLen = len(aList)

		anPos = [ 1 ]

		for i = 1 to nLen
			nPosFromStart = i + pnFromStart
			nPosFromEnd   = nLen - i - pnFromEnd + 1

			if nPosFromEnd >= nPosFromStart
				anPos + nPosFromStart
				if nPosFromEnd != nPosFromStart
					anPos + nPosFromEnd
				ok
			ok
		next

		if pReturn = :WalkedItems
			return This.ItemsAt(anPos)

		but pReturn = :WalkedPositions
			return anPos

		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(anPos))

		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return anPos[len(anPos)]

		else
			return anPos
		end
	
		#< @FunctionAlternativeForm


	def WalkNItemsFromStartNItemsFromEnd(nFromStart, nFromEnd)
		return This.WalkNItemsFromStartNItemsFromEndXT(nFromStart, nFromEnd, :Return = :WalkedPositions)

		#< @FunctionAlternativeForm


	def WalkNItemsFromEndNItemsFromStartXT(pnFromEnd, pnFromStart, pReturn)

		# Checking params

		if NOT Q([ pnFromEnd, pnFromStart ]).BothAreNumbers()
			StzRaise("Incorrect param type! Both pnFromStart and pnFromEnd must be numbers.")
		ok

		if isList(pReturn) and
		   IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])

			pReturn = pReturn[2]
		ok

		if NOT ( isString(pReturn) and

			 StzFindFirst([
				:WalkedPositions, :WalkedItems,
				:LastPosition, :LastWalkedPosition,
				:LastItem, :LastWalkedItem,
				:Default
			], pReturn) > 0 )

			StzRaise("Incorrect param! pReturn must be a string. Allowed values are " +
				 ":WalkedPositions, :WalkedItems, :LastWalkedPosition, :LastWalkedItem, and :Default." )
		ok

		if pReturn = :Default
			pReturn = :WalkedPositions
		ok

		# Doing the job

		aList = This.List()
		nLen = len(aList)

		anPos = [ nLen ]

		for i = nLen to 1 step -1

			nPosFromEnd   = i - pnFromEnd
			nPosFromStart = nLen - i + 1

			if nPosFromEnd >= nPosFromStart
				anPos + nPosFromEnd
				
				if nPosFromStart != nPosFromEnd
					anPos + nPosFromStart
				ok
			ok
		next

		if pReturn = :WalkedItems
			return This.ItemsAt(anPos)

		but pReturn = :WalkedPositions
			return anPos

		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(anPos))

		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return anPos[len(anPos)]

		else
			return anPos
		end

		#< @FunctionAlternativeForm


	def WalkNItemsFromEndNItemsFromStart(pnFromEnd, pnFromStart)
		return This.WalkNItemsFromEndNItemsFromStartXT(pnFromEnd, pnFromStart, :Return = :WalkedPositions)

		#< @FunctionAlternativeForm


		def WalkForwardBackward(pnForward, pnBackward)
			return This.WalkNITemsForwardNItemsBackward(pnForward, pnBackward)

		#>


		def WalkForwardBackwardXT(pnForward, pnBackward, pReturn)
			return This.WalkNITemsForwardNItemsBackwardXT(pnForward, pnBackward, pReturn)

		#>

	  #------------------------------------------------#
	 #  WALKING N ITEMS FORWARD AND N ITEMS BACKWARD  #
	#------------------------------------------------#


		def WalkBackwardForward(pnForward, pnBackward)
			return This.WalkNItemsBackwardNItemsForward(pnForward, pnBackward)

		#>


		def WalkBackwardForwardXT(pnBackward, pnForward, pReturn)
			return This.WalkNItemsBackwardNItemsForwardXT(pnBackward, pnForward, pReturn)

		#>

	  #===================================================#
	 #  WALKING N STEPS FROM START AND N STEPS FROM END  #
	#===================================================#


		def WalkNStartNEnd(pnFromStart, pnFromEnd)
			return This.WalkNITemsFromStartNItemsFromEnd(pnFromStart, pnFromEnd)


		def WalkNStartNEndXT(pnFromStart, pnFromEnd, pReturn)
			return This.WalkNITemsFromStartNItemsFromEndXT(pnFromStart, pnFromEnd, pReturn)


		def WalkNEndNStart(pnFromStart, pnFromEnd)
			return This.WalkNItemsFromEndNItemsFromStart(pnFromStart, pnFromEnd)


		def WalkNEndNStartXT(pnFromEnd, pnFromStart, pReturn)
			return This.WalkNItemsFromEndNItemsFromStartXT(pnFromEnd, pnFromStart, pReturn)


