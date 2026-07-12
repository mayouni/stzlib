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
	_Those_

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
		_Those_ = This

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

		_aResult_ = []

		if pCaseSensitive = 1
			_aResult_ = @aContent

		else
			_aResult_ = This.WithoutDuplicationCS(0)

		ok

		return _aResult_

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
		_nResult_ = len( This.ContentCS(pCaseSensitive) )
		return _nResult_

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
		_nResult_ = len(@aContent)
		return _nResult_

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

	def Item(_n_)

		if CheckingParams()

			if isString(_n_)
				if _n_ = "first"
					_n_ = 1

				but _n_ = "last"
					_n_ = This.NumberOfItems()

				ok
			ok

			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n should be a number.")
			ok
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _n_ > _nLen_
			StzRaise("Index outside the list!" + NL +
			 "Trying to access position " + _n_ + " in a list of "  + _nLen_ + " items!")
		but _n_ < 0
			_n_ = _nLen_ + _n_ + 1
		ok

		return @aContent[_n_]

		def ItemQ(_n_)
			return Q(This.Item(_n_))

		#@ aka  item at position, element at, get by index, the nth one
		def NthItem(_n_)
			return This.Item(_n_)

			def NthItemQ(_n_)
				return This.ItemQ(_n_)

		def ItemAtPosition(_n_)
			return This.Item(_n_)

		def ItemAt(_n_)
			return This.Item(_n_)

	  #--------------------------------------#
	 #  GETTING THE FIRST ITEM IN THE LIST  #
	#--------------------------------------#

	#@ aka  head, front, first element, the top, beginning item
	def FirstItem()
		return This.NthItem(1)

		def FirstItemQ()
			return Q(This.FirstItem())

	  #-------------------------------------#
	 #  GETTING THE LAST ITEM IN THE LIST  #
	#-------------------------------------#

	#@ aka  tail, back, last element, the end, final item
	def LastItem()
		return This.NthItem( This.NumberOfItems() )

		def LastItemQ()
			return Q(This.LastItem())

	  #------------------------------------------------#
	 #  GETTING THE FIRST AND LAST ITEMS IN THE LIST  #
	#------------------------------------------------#

	def FirstAndLastItems()
		_aResult_ = [ This.FirstItem(), This.LastItem() ]
		return _aResult_

	def LastAndFirstItems()
		_aResult_ = [ This.LastItem(), FirstItem() ]
		return _aResult_

	  #--------------------------------------------#
	 #  GETTING THE CENTRAL POSITION IN THE LIST  #
	#--------------------------------------------#

	def CentralPosition()
		_oTemp_ = new stzNumber( (This.NumberOfItems()/2) )
		_n_ = _oTemp_.IntegerPartValue()
		return _n_

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

	def NFirstItems(_n_)
		_aContent_ = This.Content()
		_aResult_ = []

		for _i_ = 1 to _n_
			_aResult_ + _aContent_[_i_]
		next

		return _aResult_

		def NFirstItemsQ(_n_)
			return NFirstItemsQRT(_n_, :stzList)

		def NFirstItemsQRT(_n_, pcReturnType)
			if isList(pcReturnType) and
			   Q(pcReturnType).IsReturnedAsNamedParam()

				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NFirstItems(_n_) )

			on :stzListOfStrings
				return new stzListOfStrings( This.NFirstItems(_n_) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NFirstItems(_n_) )

			other
				StzRaise("Unsupported return type!")
			off

	  #------------------------------------#
	 #  GETTING THE LIST OF N LAST ITEMS  #
	#------------------------------------#

	def NLastItems(_n_)
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_n1_ = _nLen_ - _n_ + 1
		_n2_ = _nLen_

		_aResult_ = []

		for _i_ = _n1_ to _n2_
			_aResult_ + _aContent_[_i_]
		next

		return _aResult_

		def NLastItemsQ(_n_)
			return NLastItemsQRT(_n_, :stzList)

		def NLastItemsQRT(_n_, pcReturnType)
			if isList(pcReturnType) and
			   Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param type! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NLastItems(_n_) )

			on :stzListOfStrings
				return new stzListOfStrings( This.NLastItems(_n_) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NLastItems(_n_) )

			other
				StzRaise("Unsupported return type!")
			off

	  #-------------------------------------------------#
	 #  GETTING NEXT/PREVIOUS N ITEMS FROM A POSITION  #
	#-------------------------------------------------#

	def NextNItems(_n_, pnStartingAt)

		if NOT isNumber(_n_)
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

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		# The n items AFTER the starting position (exclusive), matching
		# the string-side NextNChars(:StartingAt) semantics.
		_n1_ = pnStartingAt + 1
		_n2_ = pnStartingAt + _n_
		if _n2_ > _nLen_
			_n2_ = _nLen_
		ok

		_aResult_ = []
		for _i_ = _n1_ to _n2_
			_aResult_ + _aContent_[_i_]
		next

		return _aResult_

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

	# The value the list would be updated to (the passive twin of Update).
	def Updated(paNewList)
		return paNewList

		def UpdatedWith(paNewList)
			return This.Updated(paNewList)

		def UpdatedBy(paNewList)
			return This.Updated(paNewList)

	  #----------------------#
	 #     ADDING ITEMS     #
	#----------------------#

	# Add the given item at the end of the list (mutating).
	def AddItem(pItem)
		_aCopy_ = This.Content()
		_aCopy_ + pItem
		This.UpdateWith(_aCopy_)

		def AddItemQ(pItem)
			This.AddItem(pItem)
			return This

		#@ aka  append, push, add to the end, put at the back
		def Add(pItem)
			This.AddItem(pItem)

			def AddQ(pItem)
				This.Add(pItem)
				return This

		# Same as AddItem: append the item at the end (mutating).
		def Append(pItem)
			if isList(pItem) and IsWithOrUsingOrByNamedParamList(pItem)
				pItem = pItem[2]
			ok

			This.AddItem(pItem)

			def AppendQ(pItem)
				This.Append(pItem)
				return This

	# A copy of the list with the item appended; the original is unchanged.
	def ItemAdded(pItem)
		_aResult_ = This.Copy().AddItemQ(pItem).Content()
		return _aResult_

		def Added(pItem)
			return This.ItemAdded(pItem)

	# A copy with each item of paItems appended; the original is unchanged.
	def ManyAdded(paItems)
		# Non-mutating: append each item of paItems to a copy.
		_aResult_ = This.Copy().AddManyQ(paItems).Content()
		return _aResult_

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

	def AddItemAt(_n_, pItem)

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if _n_ <= This.NumberOfItems()
			This.InsertAt(_n_, pItem)

		else
			This.ExtendToPositionXT(_n_ - 1, :With = "")
			This.Add(pItem)
		ok

		def AddItemAtQ(_n_, pItem)
			This.AddItemAt(_n_, pItem)
			return This

	  #-----------------------------------------#
	 #  ADDING MANY ITEMS TO THE LIST          #
	#-----------------------------------------#

	def AddMany(paItems)
		if NOT isList(paItems)
			StzRaise("Incorrect param type! paItems must be a list.")
		ok

		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			This.AddItem(paItems[_i_])
		next

		def AddManyQ(paItems)
			This.AddMany(paItems)
			return This

		def AddItems(paItems)
			This.AddMany(paItems)

	  #-------------------#
	 #     IS EMPTY      #
	#-------------------#

	#@ aka  empty, blank, has no items, nothing in it, contains nothing
	# TRUE if the list has no items.
	def IsEmpty()
		return This.NumberOfItems() = 0

	# TRUE if the list has at least one item.
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
		_nResult_ = StzEngineListAllItemsEqualCS(pList, pCaseSensitive)
		StzEngineListFree(pList)
		return _nResult_

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

	# The list rendered as a computable string (the @@ form).
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

	# Print the list to stdout in its computable @@ form.
	def Show()
		? @@( This.Content() )

	# Print an abbreviated form of the list (first items ... last items).
	def ShowShort()
		? @@S( This.Content() )

	def ShowShortN(_n_)
		? ComputableShortFormXT( This.Content(), _n_ )

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

	def ReplaceNthCS(_n_, pItem, pNewItem, pCaseSensitive)
		_oRplN_ = new stzListReplacer(This)
		_oRplN_.ReplaceNthOccurrenceCS(_n_, pItem, pNewItem, pCaseSensitive)
		This._SetContent(_oRplN_.Content())

	def ReplaceNth(_n_, pItem, pNewItem)
		This.ReplaceNthCS(_n_, pItem, pNewItem, 1)

	# Occurrence-replace delegation, accepting the named-param call
	# form ReplaceNthOccurrence(n, :Of = item, :With = newItem).

	def ReplaceNthOccurrenceCS(_n_, pItem, pNewItem, pCaseSensitive)
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
		_oRplNO_.ReplaceNthOccurrenceCS(_n_, pItem, pNewItem, pCaseSensitive)
		This._SetContent(_oRplNO_.Content())

	def ReplaceNthOccurrence(_n_, pItem, pNewItem)
		This.ReplaceNthOccurrenceCS(_n_, pItem, pNewItem, 1)

	# Replace the nth occurrence of an item counting backward from a
	# given position. Named form:
	#   ReplacePreviousNthOccurrence(n, :Of=item, :By=new, :StartingAt=p)

	def ReplacePreviousNthOccurrenceCS(_n_, pItem, pNewItem, pnStartingAt, pCaseSensitive)
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
		_oRpvSec_ = This.SectionQ(1, pnStartingAt)
		_anRpvPos_ = _oRpvSec_.FindAllCS(pItem, pCaseSensitive)
		_nRpvPos_ = _anRpvPos_[ ring_len(_anRpvPos_) - _n_ + 1 ]
		This.ReplaceAt(_nRpvPos_, pNewItem)

	def ReplacePreviousNthOccurrence(_n_, pItem, pNewItem, pnStartingAt)
		This.ReplacePreviousNthOccurrenceCS(_n_, pItem, pNewItem, pnStartingAt, 1)

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
		_oFpnSec_ = This.SectionQ(1, pnStartingAt - 1)
		_anFpnAll_ = _oFpnSec_.FindAllCS(pItem, pCaseSensitive)
		_anFpnRes_ = []
		_nFpnL_ = ring_len(panList)
		for iFpn = 1 to _nFpnL_
			_anFpnRes_ + _anFpnAll_[ panList[iFpn] ]
		next
		return _anFpnRes_

	def FindNextNthOccurrencesCS(panList, pItem, pnStartingAt, pCaseSensitive)
		if isList(pItem) and ring_len(pItem) = 2 and isString(pItem[1]) and
		   (pItem[1] = :of or pItem[1] = :Of)
			pItem = pItem[2]
		ok
		if isList(pnStartingAt) and ring_len(pnStartingAt) = 2 and isString(pnStartingAt[1]) and
		   (pnStartingAt[1] = :startingat or pnStartingAt[1] = :StartingAt)
			pnStartingAt = pnStartingAt[2]
		ok
		_oFnnSec_ = This.SectionQ(pnStartingAt + 1, This.NumberOfItems())
		_anFnnRel_ = _oFnnSec_.FindAllCS(pItem, pCaseSensitive)
		_anFnnAll_ = []
		_nFnnRel_ = ring_len(_anFnnRel_)
		for iFnn = 1 to _nFnnRel_
			_anFnnAll_ + ( _anFnnRel_[iFnn] + pnStartingAt )
		next
		_anFnnRes_ = []
		_nFnnL_ = ring_len(panList)
		for iFnn = 1 to _nFnnL_
			_anFnnRes_ + _anFnnAll_[ panList[iFnn] ]
		next
		return _anFnnRes_

	def ReplacePreviousNthOccurrencesST(panList, pItem, pNewItem, pnStartingAt)
		if isList(pNewItem) and ring_len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :with or pNewItem[1] = :With or pNewItem[1] = :by or pNewItem[1] = :By)
			pNewItem = pNewItem[2]
		ok
		_anRpnPos_ = This.FindPreviousNthOccurrencesCS(panList, pItem, pnStartingAt, 1)
		This.ReplaceItemsAtPositions(_anRpnPos_, pNewItem)

		def ReplacePreviousNthOccurrences(panList, pItem, pNewItem, pnStartingAt)
			This.ReplacePreviousNthOccurrencesST(panList, pItem, pNewItem, pnStartingAt)

	def ReplaceNextNthOccurrences(panList, pItem, pNewItem, pnStartingAt)
		if isList(pNewItem) and ring_len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :with or pNewItem[1] = :With or pNewItem[1] = :by or pNewItem[1] = :By)
			pNewItem = pNewItem[2]
		ok
		_anRnnPos_ = This.FindNextNthOccurrencesCS(panList, pItem, pnStartingAt, 1)
		This.ReplaceItemsAtPositions(_anRnnPos_, pNewItem)

		def ReplaceNextNthOccurrencesST(panList, pItem, pNewItem, pnStartingAt)
			This.ReplaceNextNthOccurrences(panList, pItem, pNewItem, pnStartingAt)

	# Passive (non-mutating) forms: return a fresh content list.

	def NextNthOccurrencesReplaced(panList, pItem, pNewItem, pnStartingAt)
		_oNnrCopy_ = This.Copy()
		_oNnrCopy_.ReplaceNextNthOccurrences(panList, pItem, pNewItem, pnStartingAt)
		return _oNnrCopy_.Content()

	def PreviousNthOccurrencesReplaced(panList, pItem, pNewItem, pnStartingAt)
		_oPnrCopy_ = This.Copy()
		_oPnrCopy_.ReplacePreviousNthOccurrencesST(panList, pItem, pNewItem, pnStartingAt)
		return _oPnrCopy_.Content()

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

	def ReplaceSection(_n1_, _n2_, pNewItem)
		_oRpS_ = new stzListReplacer(This)
		_oRpS_.ReplaceSection(_n1_, _n2_, pNewItem)
		This._SetContent(_oRpS_.Content())

		def ReplaceSectionQ(_n1_, _n2_, pNewItem)
			This.ReplaceSection(_n1_, _n2_, pNewItem)
			return This

	def ReplaceSectionByMany(_n1_, _n2_, paNewItems)
		_oRpSM_ = new stzListReplacer(This)
		_oRpSM_.ReplaceSectionByMany(_n1_, _n2_, paNewItems)
		This._SetContent(_oRpSM_.Content())

		def ReplaceSectionByManyQ(_n1_, _n2_, paNewItems)
			This.ReplaceSectionByMany(_n1_, _n2_, paNewItems)
			return This

	# Positional replace: swap whatever lives at position n with pNewItem.
	# Mirrors AddItemAt / InsertAt / RemoveAt naming.

	def ReplaceAt(_n_, pNewItem)
		if isList(pNewItem) and len(pNewItem) = 2 and isString(pNewItem[1]) and
		   (pNewItem[1] = :by or pNewItem[1] = :By or pNewItem[1] = :with or
		    pNewItem[1] = :With or pNewItem[1] = :using or pNewItem[1] = :Using)
			pNewItem = pNewItem[2]
		ok
		# A LIST of positions replaces each of those positions (ReplaceAnyAt).
		if isList(_n_)
			_nRaLen_ = len(_n_)
			for _iRa_ = 1 to _nRaLen_
				if _n_[_iRa_] >= 1 and _n_[_iRa_] <= len(@aContent)
					This._InvalidateEngine()   # in-place @aContent mutation below
					@aContent[ _n_[_iRa_] ] = pNewItem
				ok
			next
			return
		ok
		if _n_ >= 1 and _n_ <= len(@aContent)
			This._InvalidateEngine()   # in-place @aContent mutation below
			@aContent[_n_] = pNewItem
		ok

		def ReplaceAtQ(_n_, pNewItem)
			This.ReplaceAt(_n_, pNewItem)
			return This

		def UpdateAt(_n_, pNewItem)
			This.ReplaceAt(_n_, pNewItem)

		def SetItemAt(_n_, pNewItem)
			This.ReplaceAt(_n_, pNewItem)

		def ReplaceAnyItemAt(_n_, pNewItem)
			This.ReplaceAt(_n_, pNewItem)

		def ReplaceItemAtPosition(_n_, pNewItem)
			This.ReplaceAt(_n_, pNewItem)

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

	def ReplaceThisItemAt(_n_, pItem, pNewItem)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceThisItemAt(_n_, pItem, pNewItem)
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

	def ReplaceNextNthOccurrence(_n_, pItem, pNewItem, pnStartingAt)
		_o_ = new stzListReplacer(This)
		_o_.ReplaceNextNthOccurrence(_n_, pItem, pNewItem, pnStartingAt)
		This._SetContent(_o_.Content())

		def ReplaceNextNthOccurrenceST(_n_, pItem, pNewItem, pnStartingAt)
			This.ReplaceNextNthOccurrence(_n_, pItem, pNewItem, pnStartingAt)

		def ReplaceNthNextOccurrenceST(_n_, pItem, pNewItem, pnStartingAt)
			This.ReplaceNextNthOccurrence(_n_, pItem, pNewItem, pnStartingAt)

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
			_b1_ = This.ContainsCS(pItem1, pCaseSensitive)
			_b2_ = This.ContainsCS(pItem2, pCaseSensitive)
			if (_b1_ = 1 and _b2_ = 0) or (_b1_ = 0 and _b2_ = 1)
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
		# Enforced per-object constraints guard the single update point
		This._NNLGuardUpdate(paRing)
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

	# Sort the items by the given expression, descending (mutating).
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

	# Same as Sort: ascending, in place (mutating).
	def SortUp()
		This.Sort()

		def SortUpQ()
			This.Sort()
			return This

	# Same as SortInDescending: descending, in place (mutating).
	def SortDown()
		This.SortInDescending()

		def SortDownQ()
			This.SortInDescending()
			return This

	#@ aka  order, arrange, rank, ascending, smallest to largest
	# Sort the items in ascending order in place (mutating). For a copy, use Sorted.
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
		_aResult_ = StzEngineListContentToRingList(pList)
		StzEngineListFree(pList)
		return _aResult_

	# An ascending-sorted copy of the list; the original is unchanged.
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

	# Sort the items in descending order in place (mutating). For a copy, use SortedInDescending.
	def SortInDescending()
		This.SortInDescendingCS(1)

		def SortInDescendingQ()
			This.SortInDescending()
			return This

	# A descending-sorted copy of the list; the original is unchanged.
	def SortedInDescendingCS(pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		pList = This._EngineListFromContent()
		if pList = NULL return [] ok

		StzEngineListSortDescendingCS(pList, pCaseSensitive)
		_aResult_ = StzEngineListContentToRingList(pList)
		StzEngineListFree(pList)
		return _aResult_

	def SortedInDescending()
		return This.SortedInDescendingCS(1)

	  #------------------------------#
	 #  REVERSING (engine-backed)   #
	#------------------------------#

	#@ aka  flip, backwards, invert order, last to first
	# Reverse the order of the items in place (mutating). For a copy,
	# use Reversed.
	def Reverse()
		pList = This._Engine()
		if pList = NULL return ok

		StzEngineListReverse(pList)
		This._RefreshFromEngine()

		def ReverseQ()
			This.Reverse()
			return This

	# A reversed copy of the list; the original is unchanged.
	def Reversed()
		pList = This._EngineListFromContent()
		if pList = NULL return [] ok

		StzEngineListReverse(pList)
		_aResult_ = StzEngineListContentToRingList(pList)
		StzEngineListFree(pList)
		return _aResult_

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
		_aResult_ = []
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			# content compare so a list-valued p is matched (raw != can't
			# compare sub-lists -> would wrongly keep an equal list item).
			if NOT BothAreEqualCS(@aContent[_i_], p, 1)
				_aResult_ + @aContent[_i_]
			ok
		next
		return _aResult_

		def ItemsExcept(p)
			return This.AllItemsExcept(p)

	# First n items (clamped to the list length; n<=0 -> empty).
	def FirstNItems(_n_)
		if NOT isNumber(_n_) or _n_ <= 0
			return []
		ok
		if _n_ > len(@aContent)
			_n_ = len(@aContent)
		ok
		_aResult_ = []
		for _i_ = 1 to _n_
			_aResult_ + @aContent[_i_]
		next
		return _aResult_

	# Max nesting depth (a flat list is 1 level).
	def NumberOfLevels()
		return This._DepthOf(@aContent)

		def NestingDepth()
			return This.NumberOfLevels()

	def _DepthOf(_aList_)
		_nMax_ = 1
		_nLen_ = len(_aList_)
		for _i_ = 1 to _nLen_
			if isList(_aList_[_i_])
				_nD_ = 1 + This._DepthOf(_aList_[_i_])
				if _nD_ > _nMax_
					_nMax_ = _nD_
				ok
			ok
		next
		return _nMax_

	# TRUE if any two adjacent items are equal.
	def ContainsDupSecutiveItems()
		_nLen_ = len(@aContent)
		for _i_ = 2 to _nLen_
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
		_aResult_ = []
		_nLen_ = len(@aContent)
		_nP_ = len(paItems)
		for _i_ = 1 to _nLen_
			_bRemove_ = FALSE
			for _j_ = 1 to _nP_
				if BothAreEqualCS(@aContent[_i_], paItems[_j_], 1)
					_bRemove_ = TRUE
					exit
				ok
			next
			if NOT _bRemove_
				_aResult_ + @aContent[_i_]
			ok
		next
		return _aResult_

	# TRUE if this list's items appear inside paOther in the same relative
	# order (i.e. this list is an order-preserving subsequence of paOther).
	def ItemsHaveSameOrderAs(paOther)
		if NOT isList(paOther)
			return FALSE
		ok
		_nThis_ = len(@aContent)
		_nOther_ = len(paOther)
		_nIdx_ = 1
		for _i_ = 1 to _nOther_
			if _nIdx_ <= _nThis_ and paOther[_i_] = @aContent[_nIdx_]
				_nIdx_++
			ok
		next
		return _nIdx_ > _nThis_

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

		_nResult_ = 0
		if isString(pItem)
			_nResult_ = StzEngineListFindStringCS(pList, pItem, pCaseSensitive)
		else
			# Non-string items (lists, numbers): go through the engine-backed
			# FindAllOccurrencesCS so Contains stays CONSISTENT with Find and
			# compares list items by content (the old raw `=` loop silently
			# missed sub-list items -> Contains disagreed with Find).
			_anFfe_ = This.FindAllOccurrencesCS(pItem, pCaseSensitive)
			if ring_len(_anFfe_) > 0
				_nResult_ = _anFfe_[1]
			ok
		ok

		return _nResult_

	  #----------------------------------------------#
	 #  CONTAINS (engine-backed)                    #
	#----------------------------------------------#

	def ContainsCS(pItem, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		return This._FindFirstEngine(pItem, pCaseSensitive) > 0

	#@ aka  includes, has, is in, member of, present, holds
	# TRUE if the list contains the given item.
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

	#@ aka  unique, distinct, dedupe, remove repeats, deduplicate, drop duplicates
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
		_aResult_ = @aContent
		if pUnique != NULL
			_aResult_ = StzEngineListContentToRingList(pUnique)
			StzEngineListFree(pUnique)
		ok
		return _aResult_

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

	# TRUE if some item occurs more than once in the list.
	def ContainsDuplicatedItemsCS(pCaseSensitive)
		_oDupChk_ = new stzListDuplicates(This)
		return _oDupChk_.HasDuplicatesCS(pCaseSensitive)

	def ContainsDuplicatedItems()
		return This.ContainsDuplicatedItemsCS(1)

		# TRUE if some item occurs more than once in the list.
		def HasDuplicates()
			return This.ContainsDuplicatedItems()

		def HasDuplicatesCS(pCaseSensitive)
			return This.ContainsDuplicatedItemsCS(pCaseSensitive)

		def ContainsDuplicates()
			return This.ContainsDuplicatedItems()

	def DuplicatedItemsCS(pCaseSensitive)
		_oDupItm_ = new stzListDuplicates(This)
		return _oDupItm_.DuplicatedItemsCS(pCaseSensitive)

	# The items that occur more than once in the list.
	def DuplicatedItems()
		return This.DuplicatedItemsCS(1)

	# How many duplicated items the list holds.
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

	# The position of every 2nd+ occurrence of each duplicated item.
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

		# Same as FindDuplicates.
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
	def FindNextNthItem(_n_, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		_nIdx_ = pnStartingAt + _n_
		if _nIdx_ < 1 or _nIdx_ > This.NumberOfItems()
			return 0
		ok
		return _nIdx_

		def NextNthItem(_n_, pnStartingAt)
			_nP_ = This.FindNextNthItem(_n_, pnStartingAt)
			if _nP_ = 0 return NULL ok
			return This.Content()[_nP_]

	# FindPreviousNthItem(n, :StartingAt = pos): the POSITION of the n-th
	# item counting BACK from pos inclusive (pos-n+1).
	def FindPreviousNthItem(_n_, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		_nIdx_ = pnStartingAt - _n_ + 1
		if _nIdx_ < 1 or _nIdx_ > This.NumberOfItems()
			return 0
		ok
		return _nIdx_

		def PreviousNthItem(_n_, pnStartingAt)
			_nP_ = This.FindPreviousNthItem(_n_, pnStartingAt)
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

	def StringIsDuplicatedNTimesCS(pItem, _n_, pCaseSensitive)
		return This.NumberOfDuplicatesOfStringCS(pItem, pCaseSensitive) = _n_

	def StringIsDuplicatedNTimes(pItem, _n_)
		return This.StringIsDuplicatedNTimesCS(pItem, _n_, 1)

		def ItemIsDuplicatedNTimesCS(pItem, _n_, pCaseSensitive)
			return This.StringIsDuplicatedNTimesCS(pItem, _n_, pCaseSensitive)

		def ItemIsDuplicatedNTimes(pItem, _n_)
			return This.StringIsDuplicatedNTimesCS(pItem, _n_, 1)

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

	# TRUE if the given sublist occurs in the list as a consecutive
	# run of items.
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

	# A copy flattened by ONE level: sublists spread out, other items
	# kept as they are.
	def Merged()
		_oMdTmp_ = new stzList(@aContent)
		_oMdTmp_.Merge()
		return _oMdTmp_.Content()

	#@ aka  unnest, merge levels, single level, ungroup, collapse nesting
	# Flatten the nested list to a single level in place (mutating).
	# For a copy, use Flattened.
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

	# A fully-flattened copy of the nested list; the original is unchanged.
	def Flattened()
		pList = This._Engine()
		if pList = NULL return [] ok

		pFlat = StzEngineListFlatten(pList)
		_aResult_ = []
		if pFlat != NULL
			_aResult_ = StzEngineListContentToRingList(pFlat)
			StzEngineListFree(pFlat)
		ok
		return _aResult_

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
		_aResult_ = StzEngineListContentToRingList(pResult)

		StzEngineListFree(pResult)
		return _aResult_

		def MapQ(pcExpr)
			return new stzList(This.Map(pcExpr))

	#@ aka  keep where, select, subset, matching items, pick out
	def Filter(pcExpr)
		pList = This._Engine()
		if pList = NULL return [] ok

		pcExpr = _StzStripBraces(pcExpr)
		pResult = StzEngineListFilterExpr(pList, pcExpr)
		_aResult_ = StzEngineListContentToRingList(pResult)

		StzEngineListFree(pResult)
		return _aResult_

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
		_result_ = StzEngineListReduceExpr(pList, pcExpr, pInitValue)

		return _result_

	def ReduceNoInit(pcExpr)
		pList = This._Engine()
		if pList = NULL return 0 ok

		pcExpr = _StzStripBraces(pcExpr)
		_result_ = StzEngineListReduceExprNoInit(pList, pcExpr)

		return _result_

	def CountW(pcCondition)
		pList = This._Engine()
		if pList = NULL return 0 ok

		pcCondition = _StzStripBraces(pcCondition)
		_nResult_ = StzEngineListCountW(pList, pcCondition)

		return _nResult_

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

	# TRUE if the items are sorted, ascending OR descending.
	def IsSorted()
		return This.IsSortedInAscending() or This.IsSortedInDescending()

	# TRUE if the items are in ascending order.
	def IsSortedInAscending()
		return _ListSortingOrder(@aContent) = :Ascending

	# TRUE if the items are in descending order.
	def IsSortedInDescending()
		return _ListSortingOrder(@aContent) = :Descending

	# The sorting order of the items (:Ascending, :Descending, ...).
	def SortingOrder()
		return _ListSortingOrder(@aContent)

	# TRUE if the given list is sorted the same way as this one.
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

	# TRUE if every item is a [key, value] pair (a hash list).
	def IsHashList()
		_bResult_ = 1
		_aTempKeys_ = []
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			if NOT ( isList(@aContent[_i_]) and len(@aContent[_i_]) = 2 and
				 isString(@aContent[_i_][1]) )
				_bResult_ = 0
				exit
			else
				_cKey_ = @aContent[_i_][1]
				_nKeyLen_ = len(_aTempKeys_)
				for _j_ = 1 to _nKeyLen_
					if _aTempKeys_[_j_] = _cKey_
						_bResult_ = 0
						exit 2
					ok
				next
				_aTempKeys_ + _cKey_
			ok
		next
		return _bResult_

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

	# TRUE if the list holds exactly two items.
	def IsPair()
		return len(@aContent) = 2

		def IsAPair()
			return This.IsPair()

	# TRUE if the list is non-empty and every item is a string.
	def IsListOfStrings()
		if len(@aContent) = 0 return 0 ok   # empty is NOT a list-of-strings (monolith semantics)
		pList = This._EngineListFromContent()
		_nResult_ = StzEngineListIsAllStrings(pList)
		StzEngineListFree(pList)
		return _nResult_

		def IsAListOfStrings()
			return This.IsListOfStrings()

	# TRUE if the list is non-empty and every item is a number.
	def IsListOfNumbers()
		if len(@aContent) = 0 return 0 ok   # empty is NOT a list-of-numbers (monolith semantics)
		pList = This._EngineListFromContent()
		_nResult_ = StzEngineListIsAllNumbers(pList)
		StzEngineListFree(pList)
		return _nResult_

		def IsAListOfNumbers()
			return This.IsListOfNumbers()

	# TRUE if every item is a single char.
	def IsListOfChars()
		return @IsListOfChars(@aContent)

		def IsAListOfChars()
			return This.IsListOfChars()

	# Polymorphic membership test: IsListOf(:Numbers/:Strings/:Chars/
	# :Lists/:StzNumbers/:StzStrings/:ListsOfNumbers/:PairsOfNumbers).
	def IsListOf(pType)
		_cType_ = StzLower("" + pType)
		switch _cType_
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
		_nLen_ = len(@aContent)
		if _nLen_ = 0
			return FALSE
		ok
		for _i_ = 1 to _nLen_
			if NOT isObject(@aContent[_i_])
				return FALSE
			ok
			if StzLower("" + @aContent[_i_].StzType()) != StzLower(cStzType)
				return FALSE
			ok
		next
		return TRUE

	# All items are lists of numbers (optionally each a 2-element pair).
	def _AllItemsAreNumberLists(bPairsOnly)
		_nLen_ = len(@aContent)
		if _nLen_ = 0
			return FALSE
		ok
		for _i_ = 1 to _nLen_
			_it_ = @aContent[_i_]
			if NOT isList(_it_)
				return FALSE
			ok
			if bPairsOnly and len(_it_) != 2
				return FALSE
			ok
			_m_ = len(_it_)
			for _j_ = 1 to _m_
				if NOT isNumber(_it_[_j_])
					return FALSE
				ok
			next
		next
		return TRUE

	# All items are lists of strings.
	def _AllItemsAreStringLists()
		_nLen_ = len(@aContent)
		if _nLen_ = 0 return FALSE ok
		for _i_ = 1 to _nLen_
			_it_ = @aContent[_i_]
			if NOT isList(_it_) return FALSE ok
			_m_ = len(_it_)
			for _j_ = 1 to _m_
				if NOT isString(_it_[_j_]) return FALSE ok
			next
		next
		return TRUE

	# All items are lists whose items are stz objects of the given stztype.
	def _AllItemsAreStzTypeLists(cStzType)
		_nLen_ = len(@aContent)
		if _nLen_ = 0 return FALSE ok
		for _i_ = 1 to _nLen_
			_it_ = @aContent[_i_]
			if NOT isList(_it_) return FALSE ok
			_m_ = len(_it_)
			for _j_ = 1 to _m_
				if NOT isObject(_it_[_j_]) return FALSE ok
				if StzLower("" + _it_[_j_].StzType()) != StzLower(cStzType) return FALSE ok
			next
		next
		return TRUE

	# TRUE if every item is a list (vacuously TRUE when empty).
	def IsListOfLists()
		if len(@aContent) = 0 return TRUE ok		#-- vacuously true (engine returns 0 on empty)
		pList = This._EngineListFromContent()
		_nResult_ = StzEngineListIsAllLists(pList)
		StzEngineListFree(pList)
		return _nResult_

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

	# TRUE if every item is a list and all the sublists have the same size.
	def IsListOfListsOfSameSize()
		pList = This._EngineListFromContent()
		_nResult_ = StzEngineListIsAllListsSameSize(pList)
		StzEngineListFree(pList)
		return _nResult_

		def ItemsAreListsOfSameSize()
			return This.IsListOfListsOfSameSize()

		def AllItemsAreListsOfSameSize()
			return This.IsListOfListsOfSameSize()

	# TRUE if the list is exactly a pair of two numbers.
	def IsPairOfNumbers()
		if len(@aContent) = 2 and isNumber(@aContent[1]) and isNumber(@aContent[2])
			return 1
		else
			return 0
		ok

		def IsAPairOfNumbers()
			return This.IsPairOfNumbers()

	# TRUE if every item is a pair (vacuously TRUE when empty).
	def IsListOfPairs()
		if len(@aContent) = 0 return TRUE ok		#-- vacuously true (engine returns 0 on empty)
		pList = This._EngineListFromContent()
		_nResult_ = StzEngineListIsAllPairs(pList)
		StzEngineListFree(pList)
		return _nResult_

		def IsAListOfPairs()
			return This.IsListOfPairs()

	# True iff the list of numbers is sorted ascending with consecutive
	# values (e.g. [3,4,5] -> TRUE, [3,5,6] -> FALSE).
	def IsContiguous()
		_nLen_ = len(@aContent)
		if _nLen_ < 2
			return TRUE
		ok
		for _i_ = 1 to _nLen_
			if NOT isNumber(@aContent[_i_])
				return FALSE
			ok
		next
		for _i_ = 2 to _nLen_
			if @aContent[_i_] != @aContent[_i_-1] + 1
				return FALSE
			ok
		next
		return TRUE

		def AreContiguous()
			return This.IsContiguous()

	# TRUE if every item is a pair of numbers.
	def IsListOfPairsOfNumbers()
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			p = @aContent[_i_]
			if NOT (isList(p) and len(p) = 2 and isNumber(p[1]) and isNumber(p[2]))
				return FALSE
			ok
		next
		return TRUE

		def IsAListOfPairsOfNumbers()
			return This.IsListOfPairsOfNumbers()

	# TRUE if every item is a pair of strings.
	def IsListOfPairsOfStrings()
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			p = @aContent[_i_]
			if NOT (isList(p) and len(p) = 2 and isString(p[1]) and isString(p[2]))
				return FALSE
			ok
		next
		return TRUE

		def IsAListOfPairsOfStrings()
			return This.IsListOfPairsOfStrings()

	# TRUE if all the items are unique (the list is a set).
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
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			for _j_ = _i_ + 1 to _nLen_
				if @aContent[_i_] = @aContent[_j_]
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

	# The raw Ring list content (same as Content).
	def List()
		return This.Content()

		def ListQ()
			return This

	  #-- Section: extract items between two positions

	def SectionCS(_n1_, _n2_, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_nLen_ = This.NumberOfItems()

		if CheckingParams()
			_n1_ = This._SectionResolveBound(_n1_, TRUE)
			_n2_ = This._SectionResolveBound(_n2_, FALSE)

			# :@ mirrors the partner index (Section(3,:@)==Section(3,3));
			# :@ on both sides spans the whole list.
			if _n1_ = :@ and _n2_ = :@
				_n1_ = 1
				_n2_ = _nLen_
			but _n1_ = :@ and isNumber(_n2_)
				_n1_ = _n2_
			but _n2_ = :@ and isNumber(_n1_)
				_n2_ = _n1_
			ok

			if NOT @BothAreNumbers(_n1_, _n2_)
				StzRaise("Incorrect params! n1 and n2 must be numbers.")
			ok
		ok

		if (_n1_ < 1 or _n1_ > _nLen_) or (_n2_ < 1 or _n2_ > _nLen_)
			StzRaise("Indexes out of range!")
		ok

		if _n2_ < _n1_
			_nTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nTemp_
		ok

		_aContent_ = This.Content()
		_aResult_ = []
		for _i_ = _n1_ to _n2_
			_aResult_ + _aContent_[_i_]
		next

		return _aResult_

		def SectionCSQ(_n1_, _n2_, pCaseSensitive)
			return new stzList(This.SectionCS(_n1_, _n2_, pCaseSensitive))

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

	def Section(_n1_, _n2_)
		return This.SectionCS(_n1_, _n2_, 1)

		def SectionQ(_n1_, _n2_)
			return new stzList(This.Section(_n1_, _n2_))

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
			_n1_ = pnStart + pnRange + 1
			if _n1_ > 0
				return This.Section(_n1_, pnStart)
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

	def InsertAt(_n_, pItem)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_, [ :Position, :ItemAt, :ItemAtPosition ])
			_n_ = _n_[2]
		ok

		_aContent_ = @aContent
		ring_insert(_aContent_, _n_, pItem)
		This.UpdateWith(_aContent_)

		def InsertBefore(_n_, pItem)
			This.InsertAt(_n_, pItem)

		def InsertAtQ(_n_, pItem)
			This.InsertAt(_n_, pItem)
			return This

	  #-- RemoveItemAtPosition: remove item at a specific position

	def RemoveItemAtPosition(_n_)
		if isString(_n_)
			if StzFindFirst([:First, :FirstPosition, :FirstItem], _n_) > 0
				_n_ = 1
			but StzFindFirst([:Last, :LastPosition, :LastItem], _n_) > 0
				_n_ = This.NumberOfItems()
			ok
		ok

		if NOT (isNumber(_n_) and _n_ != 0)
			StzRaise("Incorrect param! n must be a number different from zero.")
		ok

		if _n_ <= This.NumberOfItems()
			_aContent_ = This.Content()
			ring_del(_aContent_, _n_)
			This.UpdateWith(_aContent_)
		ok

		def RemoveItemAtPositionQ(_n_)
			This.RemoveItemAtPosition(_n_)
			return This

		def RemoveAt(_n_)
			This.RemoveItemAtPosition(_n_)

	  #-- RemoveItemsAtPositions: remove items at multiple positions

	def RemoveItemsAtPositions(panPos)
		if NOT isList(panPos)
			StzRaise("Incorrect param type! panPos must be a list.")
		ok

		_oChain_ = new stzList(panPos)

		panSorted = _oChain_.Sorted()
		_nLen_ = len(panSorted)

		for _i_ = _nLen_ to 1 step -1
			This.RemoveItemAtPosition(panSorted[_i_])
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

	def RemoveSection(_n1_, _n2_)
		_nLen_ = This.NumberOfItems()

		if CheckingParams()
			if isString(_n1_)
				if StzFindFirst([:First, :FirstPosition, :FirstItem], _n1_) > 0
					_n1_ = 1
				ok
			ok

			if isString(_n2_)
				if StzFindFirst([:Last, :LastPosition, :LastItem], _n2_) > 0
					_n2_ = _nLen_
				ok
			ok

			if NOT @BothAreNumbers(_n1_, _n2_)
				StzRaise("Incorrect param type! n1 and n2 must be numbers.")
			ok

			if _n2_ < _n1_
				_nTemp_ = _n1_
				_n1_ = _n2_
				_n2_ = _nTemp_
			ok
		ok

		if _nLen_ = 0
			return
		ok

		if _n1_ = 1 and _n2_ = _nLen_
			This.UpdateWith([])
			return
		ok

		if _n1_ = _n2_
			This.RemoveItemAtPosition(_n1_)
			return
		ok

		_aContent_ = This.Content()
		_aResult_ = []

		for _i_ = 1 to _n1_ - 1
			_aResult_ + _aContent_[_i_]
		next

		for _i_ = _n2_ + 1 to _nLen_
			_aResult_ + _aContent_[_i_]
		next

		This.UpdateWith(_aResult_)

		def RemoveSectionQ(_n1_, _n2_)
			This.RemoveSection(_n1_, _n2_)
			return This

	  #-- RemoveW / RemoveW: drop items where the eval'd predicate
	  #   is TRUE. Forwards to stzListRemover.RemoveW. The XT variant
	  #   is alias (the underlying remover handles both shapes).

	def RemoveW(pcCondition)
		_oRwRemover_ = new stzListRemover(This)
		_oRwRemover_.RemoveW(pcCondition)
		This._SetContent(_oRwRemover_.Content())

		def RemoveWQ(pcCondition)
			_StzHistoOpen(This.Content())
			This.RemoveW(pcCondition)
			_StzHistoAdd(This.Content())
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
			_StzHistoOpen(This.Content())
			This.RemoveSpaces()
			_StzHistoAdd(This.Content())
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
			_StzHistoOpen(This.Content())
			This.RemoveDuplicatedItems()
			_StzHistoAdd(This.Content())
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

	def RemoveRange(_nStart_, nRange)
		if nRange > 0
			This.RemoveSection(_nStart_, _nStart_ + nRange - 1)
		but nRange < 0
			_n1_ = _nStart_ + nRange + 1
			if _n1_ > 0
				This.RemoveSection(_n1_, _nStart_)
			ok
		ok

	  #-- RemoveAllItems

	# Empty the list (mutating).
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

		# Find the given item: the positions of EVERY occurrence, as a
		# list (engine-backed).
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
	def LastNItemsQRT(_n_, pcType)
		_l_ = This.List()
		_nL_ = len(_l_)
		if _n_ < 1 return new stzList([]) ok
		if _n_ > _nL_ _n_ = _nL_ ok
		_a_ = []
		for _i_ = _nL_ - _n_ + 1 to _nL_
			_a_ + _l_[_i_]
		next
		# Wrap the slice so callers can chain methods.
		if isString(pcType)
			_kw_ = lower(pcType)
			if ring_left(_kw_, 1) = ":" _kw_ = StzMidToEnd(_kw_, 2) ok
			if _kw_ = "stzlistofstrings" return new stzListOfStrings(_a_) ok
		ok
		return new stzList(_a_)

	def LastNItems(_n_)
		_o_ = This.LastNItemsQRT(_n_, :stzList)
		if isObject(_o_) return _o_.List() ok
		return _o_

	# AddedToEach(n): add n to every numeric item; return a new list.
	def AddedToEach(_n_)
		_l_ = This.List()
		_nL_ = len(_l_)
		_aR_ = []
		for _i_ = 1 to _nL_
			_v_ = _l_[_i_]
			if isNumber(_v_)
				_aR_ + (_v_ + _n_)
			else
				_aR_ + _v_
			ok
		next
		return _aR_

	def AddToEach(_n_)
		_l_ = This.List()
		_nL_ = len(_l_)
		for _i_ = 1 to _nL_
			if isNumber(_l_[_i_]) _l_[_i_] = _l_[_i_] + _n_ ok
		next
		This._SetContent(_l_)

	def LastNItemsQ(_n_)
		return new stzList( This.LastNItems(_n_) )

	# SectionsOfSameItems(): group consecutive equal items into runs.
	# "AABBCCAA" -> [["A","A"], ["B","B"], ["C","C"], ["A","A"]]
	def SectionsOfSameItems()
		# Groups the SAME items together across the whole list
		# (first-seen order), not just adjacent runs:
		# [ONE, TWO, TWO, ONE] -> [[ONE, ONE], [TWO, TWO]].
		_l_ = This.List()
		_nL_ = len(_l_)
		_aVals_ = []
		_aRes_ = []
		for _i_ = 1 to _nL_
			_nAt_ = ring_find(_aVals_, _l_[_i_])
			if _nAt_ = 0
				_aVals_ + _l_[_i_]
				_aRes_ + [ _l_[_i_] ]
			else
				_aRes_[_nAt_] + _l_[_i_]
			ok
		next
		return _aRes_

	# FindInSections(pItem, aSections): absolute-position occurrences of
	# pItem inside any of the given sections.
	def FindInSections(pItem, _aSections_)
		_aRes_ = []
		if NOT isList(_aSections_) return _aRes_ ok
		_aAll_ = This.FindAllOccurrencesCS(pItem, 1)
		_nP_ = len(_aAll_)
		_nS_ = len(_aSections_)
		for _i_ = 1 to _nP_
			_pos_ = _aAll_[_i_]
			for _j_ = 1 to _nS_
				_s_ = _aSections_[_j_]
				if isList(_s_) and len(_s_) >= 2 and isNumber(_s_[1]) and isNumber(_s_[2]) and
				   _pos_ >= _s_[1] and _pos_ <= _s_[2]
					_aRes_ + _pos_
					exit
				ok
			next
		next
		return _aRes_

	def CountInSections(pItem, _aSections_)
		return len(This.FindInSections(pItem, _aSections_))

	def NumberOfOccurrencesInSections(pItem, _aSections_)
		return This.CountInSections(pItem, _aSections_)

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
		# Accept CommonItems(:With = list) or a direct list argument.
		_other_ = pNamedWith
		if isList(pNamedWith) and len(pNamedWith) = 2 and
		   isString(pNamedWith[1]) and lower(pNamedWith[1]) = "with"
			_other_ = pNamedWith[2]
		ok
		if NOT isList(_other_) return [] ok
		# CommonItems is the SET intersection: This's items that also appear
		# in _other_, in This's order, each once (duplicates in the host
		# appear once per its narrative doc). The engine's IntersectionCS
		# already does exactly that -- host order + first-occurrence dedup --
		# in ONE O(n+m) hash pass. (The old path called the multiset
		# CommonItemsCS and then a UNIQUE pass in Ring that was O(k^2) and
		# effectively hung at ~1,000,000 shared items.)
		_pCiA_ = This._EngineListFromContent()
		_pCiB_ = StzEngineMarshalList(_other_)
		if _pCiA_ != NULL and _pCiB_ != NULL
			_pCiR_ = StzEngineListIntersectionCS(_pCiA_, _pCiB_, 1)
			_aR_ = StzEngineListContentToRingList(_pCiR_)
			StzEngineListFree(_pCiR_)
			StzEngineListFree(_pCiA_)
			StzEngineListFree(_pCiB_)
			return _aR_
		ok
		if _pCiA_ != NULL StzEngineListFree(_pCiA_) ok
		if _pCiB_ != NULL StzEngineListFree(_pCiB_) ok

		# Fallback (non-marshalable content): O(n*m) membership test with a
		# first-occurrence dedup folded into the same pass.
		_a_ = This.List()
		_nL_ = len(_a_)
		_nB_ = len(_other_)
		_aU_ = []
		for _i_ = 1 to _nL_
			_v_ = _a_[_i_]
			_bIn_ = FALSE
			for _j_ = 1 to _nB_
				if BothAreEqualCS(_v_, _other_[_j_], 1) _bIn_ = TRUE exit ok
			next
			if _bIn_
				_bSeen_ = FALSE
				_nUL_ = len(_aU_)
				for _k_ = 1 to _nUL_
					if BothAreEqualCS(_v_, _aU_[_k_], 1) _bSeen_ = TRUE exit ok
				next
				if NOT _bSeen_ _aU_ + _v_ ok
			ok
		next
		return _aU_

	# PreviousNItems: two shapes --
	#   PreviousNItems(n, :StartingAt/:StartingAtPosition = p): the n
	#   items strictly BEFORE position p;
	#   PreviousNItems(pcAnchor, n): the n items before the anchor item.
	def PreviousNItems(pcAnchor, _n_)
		_l_ = This.List()
		_nL_ = len(_l_)
		_pos_ = 0
		if isNumber(pcAnchor) and isList(_n_) and len(_n_) = 2 and
		   isString(_n_[1]) and
		   (lower(_n_[1]) = "startingat" or lower(_n_[1]) = "startingatposition")
			_pos_ = _n_[2]
			_n_ = pcAnchor
		else
			for _i_ = 1 to _nL_
				if _l_[_i_] = pcAnchor _pos_ = _i_ exit ok
			next
		ok
		if _pos_ <= 1 return [] ok
		_start_ = _pos_ - _n_
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

	# Substrongs/Substrinks (deliberate Softanza wordplay): the string
	# items that CONTAIN another item of the list, and the ones that are
	# CONTAINED IN another item (case-sensitive, engine-backed find).
	def SubStrongs()
		_aSbg_ = This.Content()
		_nSbg_ = ring_len(_aSbg_)
		_aSbgRes_ = []
		for _iSbg_ = 1 to _nSbg_
			if NOT isString(_aSbg_[_iSbg_]) loop ok
			for _jSbg_ = 1 to _nSbg_
				if _iSbg_ != _jSbg_ and isString(_aSbg_[_jSbg_]) and
				   _aSbg_[_iSbg_] != _aSbg_[_jSbg_] and
				   StzFindFirst(_aSbg_[_iSbg_], _aSbg_[_jSbg_]) > 0
					_aSbgRes_ + _aSbg_[_iSbg_]
					exit
				ok
			next
		next
		return _aSbgRes_

	def SubStrinks()
		_aSbk_ = This.Content()
		_nSbk_ = ring_len(_aSbk_)
		_aSbkRes_ = []
		for _iSbk_ = 1 to _nSbk_
			if NOT isString(_aSbk_[_iSbk_]) loop ok
			for _jSbk_ = 1 to _nSbk_
				if _iSbk_ != _jSbk_ and isString(_aSbk_[_jSbk_]) and
				   _aSbk_[_iSbk_] != _aSbk_[_jSbk_] and
				   StzFindFirst(_aSbk_[_jSbk_], _aSbk_[_iSbk_]) > 0
					_aSbkRes_ + _aSbk_[_iSbk_]
					exit
				ok
			next
		next
		return _aSbkRes_

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
		# REAL collective check (the old stub answered TRUE for ANY
		# non-empty list, so mixed lists passed as :Numbers): dispatch
		# to IsListOfXxx when it exists, else test each item against
		# the SINGULAR descriptor (morphology machinery)
		_l_ = This.List()
		if len(_l_) = 0
			return 0
		ok
		_cAreM_ = "islistof" + StzLower("" + p)
		if StzFindFirst(ring_methods(This), _cAreM_) > 0
			eval("_bAre_ = This." + _cAreM_ + "()")
			return _bAre_
		ok
		_cAreSing_ = Singular(StzLower("" + p))
		_nAre_ = len(_l_)
		for _iAre_ = 1 to _nAre_
			_vAreItem_ = _l_[_iAre_]
			eval("_bAreOne_ = @is" + _cAreSing_ + "(_vAreItem_)")
			if NOT _bAreOne_
				return 0
			ok
		next
		return 1

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
		# [ [name, [positions...]], ... ] grouped by object name in
		# first-seen order (@noname objects grouped together).
		_l_ = This.List()
		_nL_ = len(_l_)
		_acOzNames_ = []
		_aOzRes_ = []
		for _i_ = 1 to _nL_
			if NOT isObject(_l_[_i_]) loop ok
			_cOzN_ = "@noname"
			try
				_cOzN_ = _l_[_i_].ObjectName()
			catch
			done
			if NOT isString(_cOzN_) _cOzN_ = "@noname" ok
			_nOzAt_ = ring_find(_acOzNames_, _cOzN_)
			if _nOzAt_ = 0
				_acOzNames_ + _cOzN_
				_aOzRes_ + [ _cOzN_, [ _i_ ] ]
			else
				_aOzRes_[_nOzAt_][2] + _i_
			ok
		next
		return _aOzRes_

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
		# A string names the object: FindObject(:oGreeting) -> the
		# positions of objects carrying that name.
		if isString(pObj)
			_cFoN_ = lower(pObj)
			for _i_ = 1 to _nL_
				if NOT isObject(_l_[_i_]) loop ok
				_cFoV_ = ""
				try
					_cFoV_ = _l_[_i_].ObjectName()
				catch
				done
				if isString(_cFoV_) and lower(_cFoV_) = _cFoN_
					_aR_ + _i_
				ok
			next
			return _aR_
		ok
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
		# ring_insert places AT the position, so AFTER p means p + 1.
		# No trailing insert after the FINAL item (block #941).
		for _i_ = 1 to _nL_
			_p_ = _aSorted_[_i_]
			if isNumber(_p_) and _p_ >= 1 and _p_ < len(@aContent)
				This._InvalidateEngine()   # in-place @aContent mutation below
				ring_insert(@aContent, (_p_ + 1), pItem)
			ok
		next

	def ReplaceItemsAtPositionsByMany(_anPos_, paNewList)
		if NOT (isList(_anPos_) and isList(paNewList)) return ok
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
		_nPL_ = len(_anPos_)
		_nAL_ = len(_aNew_)
		_nMax_ = _nPL_
		if _nAL_ < _nMax_ _nMax_ = _nAL_ ok
		_l_ = This.List()
		_nLL_ = len(_l_)
		for _i_ = 1 to _nMax_
			_p_ = _anPos_[_i_]
			if isNumber(_p_) and _p_ >= 1 and _p_ <= _nLL_
				_l_[_p_] = _aNew_[_i_]
			ok
		next
		This._SetContent(_l_)


	def IsIncludedIn(pOther)
		if NOT isList(pOther) return FALSE ok
		pList = This._EngineListFromContent()
		pOth = StzEngineMarshalList(pOther)
		_nResult_ = This.IsContainedInCS(pOther, 1)  # singular = whole-list-as-element (ExistsIn); AreIncludedIn = subset
		StzEngineListFree(pList)
		StzEngineListFree(pOth)
		return _nResult_

	def NumberOfLeadingItems()
		_nLen_ = len(@aContent)
		if _nLen_ <= 1 return _nLen_ ok		#-- engine reports 0 for n<2
		pList = This._EngineListFromContent()
		_nResult_ = StzEngineListLeadingCountCS(pList, 1)
		StzEngineListFree(pList)
		#-- engine returns 0 when the first item isn't repeated (run length 1);
		#-- our contract counts the first item itself, so map 0 -> 1.
		if _nResult_ = 0 return 1 ok
		return _nResult_

	def NumberOfTrailingItems()
		_nLen_ = len(@aContent)
		if _nLen_ <= 1 return _nLen_ ok		#-- engine reports 0 for n<2
		pList = This._EngineListFromContent()
		_nResult_ = StzEngineListTrailingCountCS(pList, 1)
		StzEngineListFree(pList)
		if _nResult_ = 0 return 1 ok
		return _nResult_

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

	# TheseCharsZ([chars]): each char grouped with ALL its positions in
	# the list -- [ [c, [positions]], ... ].
	def TheseCharsZ(pacChars)
		if NOT isList(pacChars) return [] ok
		_l_ = This.List()
		_nL_ = ring_len(_l_)
		_nP_ = ring_len(pacChars)
		_aR_ = []
		for _j_ = 1 to _nP_
			_aPos_ = []
			for _i_ = 1 to _nL_
				if _l_[_i_] = pacChars[_j_] _aPos_ + _i_ ok
			next
			_aR_ + [ pacChars[_j_], _aPos_ ]
		next
		return _aR_

	def NextNItemsAfter(pcAnchor, _n_)
		_l_ = This.List()
		_nL_ = len(_l_)
		_pos_ = 0
		for _i_ = 1 to _nL_
			if _l_[_i_] = pcAnchor _pos_ = _i_ exit ok
		next
		if _pos_ = 0 or _pos_ >= _nL_ return [] ok
		_end_ = _pos_ + _n_
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

	def FindNthOccurrenceCS(_n_, pItem, pCaseSensitive)
		if CheckingParams()
			if isString(_n_)
				if _n_ = :First or _n_ = :FirstOccurrence
					_n_ = 1
				but _n_ = :Last or _n_ = :LastOccurrence
					_n_ = This.NumberOfOccurrenceCS(pItem, pCaseSensitive)
				ok
			ok

			if isList(pItem) and IsOfNamedParamList(pItem)
				pItem = pItem[2]
			ok

			if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
				pCaseSensitive = pCaseSensitive[2]
			ok
		ok

		_anPositions_ = This.FindAllOccurrencesCS(pItem, pCaseSensitive)
		_nLen_ = len(_anPositions_)

		if _n_ < 1 or _n_ > _nLen_
			return 0
		ok

		return _anPositions_[_n_]

		def FindNthCS(_n_, pItem, pCaseSensitive)
			return This.FindNthOccurrenceCS(_n_, pItem, pCaseSensitive)

		def NthOccurrenceCS(_n_, pItem, pCaseSensitive)
			return This.FindNthOccurrenceCS(_n_, pItem, pCaseSensitive)

	# Case-insensitive word-order aliases used by narrative tests.
	# (Cannot live inside FindNthOccurrenceCS as nested defs because
	# they take a different arity -- top-level methods instead.)
	def FindNth(_n_, pItem)
		return This.FindNthOccurrenceCS(_n_, pItem, 1)

		def FindNthOccurrence(_n_, pItem)
			return This.FindNthOccurrenceCS(_n_, pItem, 1)

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
		_anAll_ = This.FindAllOccurrencesCS(pItem, pCaseSensitive)
		_nLen_ = len(_anAll_)
		if _nLen_ = 0
			return 0
		ok
		return _anAll_[_nLen_]

		def FindLastCS(pItem, pCaseSensitive)
			return This.FindLastOccurrenceCS(pItem, pCaseSensitive)

		def FindLast(pItem)
			return This.FindLastOccurrenceCS(pItem, 1)

	  #-- FindManyCS: find multiple items at once

	def FindManyCS(paItems, pCaseSensitive)
		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		_anResult_ = []
		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			_anPos_ = This.FindAllOccurrencesCS(paItems[_i_], pCaseSensitive)
			_nPosLen_ = len(_anPos_)
			for _j_ = 1 to _nPosLen_
				_anResult_ + _anPos_[_j_]
			next
		next

		# Ring 1.26 parser dislikes `new X(...).Sorted()` chaining
		# (raises R13 "Object is required" at the dot). Bind to a
		# local first.
		_oFmcsTmp_ = new stzList(_anResult_)
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

		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			if NOT This.ContainsCS(paItems[_i_], pCaseSensitive)
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

		_anPos_ = This.FindAllOccurrencesCS(pItem, pCaseSensitive)
		_nLenPos_ = len(_anPos_)

		for _i_ = _nLenPos_ to 1 step -1
			This.RemoveItemAtPosition(_anPos_[_i_])
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

		_nLen_ = This.NumberOfItems()
		if _nLen_ = 0 return [] ok

		#-- Transpile the expressive navigation keywords (@NextItem -> This[@i+1],
		#-- etc.) only when present, so the simple path stays free of parse cost.
		#-- Using a navigation keyword also opts in to executable-section
		#-- bounding below (so neighbour access never steps out of range);
		#-- raw This[@i+k] index math stays unbounded (you own the bounds).
		_bNavKeyword_ = 0
		if ring_len( StzFindCS("@Next", pcCondition, 1) ) > 0 or
		   ring_len( StzFindCS("@Previous", pcCondition, 1) ) > 0
			pcCondition = StzCCodeQ(pcCondition).Transpiled()
			_bNavKeyword_ = 1
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
		_nStart_ = 1
		_nEnd_ = _nLen_
		if _bNavKeyword_ and ring_len( StzFindCS("@i", pcCondition, 1) ) > 0
			_anSec_ = StzCCodeQ("{ " + pcCondition + " }").ExecutableSection()
			_nStart_ = _anSec_[1]
			_nEnd_   = _anSec_[2]

			if isString(_nEnd_)
				_nEnd_ = _nLen_
			but isNumber(_nEnd_) and _nEnd_ < 0
				_nEnd_ += _nLen_
			ok
			if isString(_nStart_)
				_nStart_ = 1
			ok
			if _nStart_ < 1 _nStart_ = 1 ok
			if _nEnd_ > _nLen_ _nEnd_ = _nLen_ ok
		ok

		pList = This._Engine()
		if pList = NULL return [] ok
		# Engine returns a ready list of 1-based positions (built Zig-side).
		_anAll_ = StzEngineListFindAllW(pList, pcCondition)

		#-- Fast path: no bounding needed.
		if _nStart_ = 1 and _nEnd_ = _nLen_
			return _anAll_
		ok

		_anResult_ = []
		_nA_ = len(_anAll_)
		for _i_ = 1 to _nA_
			p = _anAll_[_i_]
			if p >= _nStart_ and p <= _nEnd_
				_anResult_ + p
			ok
		next
		return _anResult_

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
	def NthItemWF(_n_, pFunc)
		_aWf_ = This.ItemsWF(pFunc)
		if _n_ >= 1 and _n_ <= ring_len(_aWf_) return _aWf_[_n_] ok
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

		_aContent_ = This.Content()
		_nLen_ = len(panPos)
		_aResult_ = []

		for _i_ = 1 to _nLen_
			_aResult_ + _aContent_[panPos[_i_]]
		next

		return _aResult_

		def ItemsAtPositionsQ(panPos)
			return new stzList(This.ItemsAtPositions(panPos))

		def ItemsAt(panPos)
			return This.ItemsAtPositions(panPos)

	  #-- ExtendToPositionXT: extend list to a given position

	def ExtendToPositionXT(_n_, pWith)
		if isList(pWith) and IsWithOrByOrUsingNamedParamList(pWith)
			pWith = pWith[2]
		ok

		_nLen_ = This.NumberOfItems()
		if _n_ > _nLen_
			for _i_ = _nLen_ + 1 to _n_
				This.AddItem(pWith)
			next
		ok

		def ExtendToPositionWith(_n_, pWith)
			This.ExtendToPositionXT(_n_, pWith)

	# Sugar aliases over ExtendToPositionXT: the same operation
	# but using the more natural "ExtendTo" / "Extend" naming.
	# Default filler is the empty string.

	def ExtendTo(_n_)
		# Type-aware padding: 0 for an all-number list, "" otherwise
		# (ExtendToPosition decides). Use ExtendToXT(n, :With=v) to choose.
		This.ExtendToPosition(_n_)

		def ExtendToQ(_n_)
			This.ExtendTo(_n_)
			return This

		def ExtendToWith(_n_, pWith)
			This.ExtendToPositionXT(_n_, pWith)

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

	def ShrinkTo(_n_)
		_nShLen_ = len(@aContent)
		if _n_ < 0
			_n_ = 0
		ok
		if _n_ >= _nShLen_
			return
		ok
		_aShNew_ = []
		for _iSh_ = 1 to _n_
			_aShNew_ + @aContent[_iSh_]
		next
		This._SetContent(_aShNew_)

		def ShrinkToQ(_n_)
			This.ShrinkTo(_n_)
			return This

		def TruncateTo(_n_)
			This.ShrinkTo(_n_)

		def KeepFirst(_n_)
			This.ShrinkTo(_n_)

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
		_nLen_ = len(panPos)
		pList = This._EngineListFromContent()
		if pList = NULL return ok

		pResult = StzEngineListMapExpr(pList, pcAction)
		_aNew_ = StzEngineListContentToRingList(pResult)

		for _i_ = 1 to _nLen_
			_nPos_ = panPos[_i_]
			if _nPos_ >= 1 and _nPos_ <= len(@aContent)
				This._InvalidateEngine()   # in-place @aContent mutation below
				@aContent[_nPos_] = _aNew_[_nPos_]
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

	#@ aka  smallest, minimum, lowest, least
	def Min()
		if len(@aContent) = 0
			return 0
		ok

		# Engine-backed O(n) min
		pList = This._EngineListFromContent()
		_nResult_ = StzEngineListMin(pList)
		StzEngineListFree(pList)
		return _nResult_

		def Smallest()
			return This.Min()

		def Lowest()
			return This.Min()

	#@ aka  largest, maximum, highest, biggest, greatest
	def Max()
		if len(@aContent) = 0
			return 0
		ok

		# Engine-backed O(n) max
		pList = This._EngineListFromContent()
		_nResult_ = StzEngineListMax(pList)
		StzEngineListFree(pList)
		return _nResult_

		def Greatest()
			return This.Max()

		def Largest()
			return This.Max()

		def Highest()
			return This.Max()

	  #-- Sum / Product / Mean (engine-backed)

	#@ aka  total, add up, aggregate, sum of the numbers
	def Sum()
		if len(@aContent) = 0 return 0 ok
		_pSmList_ = This._Engine()
		_nSmResult_ = StzEngineListSum(_pSmList_)
		return _nSmResult_

	#@ aka  multiply all, times all together, multiplied product
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

		#@ aka  mean, avg, typical value, arithmetic mean
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

	#@ aka  middle value, midpoint, the median
	def Median()
		if len(@aContent) = 0 return 0 ok
		_pMdList_ = This._Engine()
		_nMdResult_ = StzEngineListMedian(_pMdList_)
		return _nMdResult_

	def NthSmallest(_n_)
		# The n-th smallest DISTINCT value (dedup, then ascending rank),
		# matching the monolith. (The engine NthSmallest ranks with
		# duplicates; dedup first so [3,3,7,8,8,10] -> 3rd smallest = 8.)
		if len(@aContent) = 0 return 0 ok
		_oNs_ = This.Copy()
		_oNs_.RemoveDuplicates()
		return _oNs_.Sorted()[_n_]

	def NthLargest(_n_)
		if len(@aContent) = 0 return 0 ok
		_oNl_ = This.Copy()
		_oNl_.RemoveDuplicates()
		return _oNl_.SortedInDescending()[_n_]

	  #-- Repeat (engine-backed)

	def Repeat(_n_)
		if CheckParams()
			if isList(_n_) and len(_n_) = 2 and
			   isNumber(_n_[1]) and isString(_n_[2]) and
			   (_n_[2] = :NTimes or _n_[2] = :Times)

				_n_ = _n_[1]
			ok
		ok

		# Mutating, nesting (in place): [1,2].Repeat(3) -> [ [1,2], [1,2], [1,2] ].
		_aRptContent_ = This.Content()
		_aRptRes_ = []
		for _iRpt_ = 1 to _n_
			_aRptRes_ + _aRptContent_
		next
		This._SetContent(_aRptRes_)

		def RepeatQ(_n_)
			This.Repeat(_n_)
			return This

	def Repeated(_n_)
		if CheckParams()
			if isList(_n_) and len(_n_) = 2 and
			   isNumber(_n_[1]) and isString(_n_[2]) and
			   _n_[2] = :Times

				_n_ = _n_[1]
			ok
		ok

		# Repeating a list yields a list CONTAINING that list n times (NESTED):
		# [1,2].Repeated(3) -> [ [1,2], [1,2], [1,2] ]. (The flat concatenation
		# is the (*) operator's job: o1 * 3 -> [1,2,1,2,1,2].)
		_aRpdContent_ = This.Content()
		_aRpdOut_ = []
		for _iRpd_ = 1 to _n_
			_aRpdOut_ + _aRpdContent_
		next
		return _aRpdOut_

		def RepeatedNTimes(_n_)
			return This.Repeated(_n_)

		def RepeatNTimes(_n_)
			return This.Repeated(_n_)

	  #-- SplitAt (engine-backed)

	def SplitAt(_n_)
		# The engine's stz_list_split_at takes the cut positions as an ENGINE
		# LIST handle (0-based cut indices), NOT a bare integer -- passing the
		# integer made the bridge read a bogus handle and the engine returned
		# NULL (so SplitAt silently fell back to [[],[]]). Build a 1-element
		# positions list at the 0-based cut (n-1) for the 1-based SplitAt(n).
		_pSaList_ = This._EngineListFromContent()
		if _pSaList_ = NULL return [[], []] ok
		_pSaPos_ = (new stzList([ _n_ - 1 ]))._EngineListFromContent()
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
		_nResult_ = StzEngineListIsSubsetCS(pList, pVals, 1)
		StzEngineListFree(pList)
		StzEngineListFree(pVals)
		return _nResult_

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

	# The [start, end] sections of the runs of items DIFFERENT from
	# the given item.
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

	def AntiPositions(_anPos_)
		_oApFinder_ = new stzListFinder(This)
		return _oApFinder_.AntiPositions(_anPos_)

	# AntiPositionsZZ: the complement of anPos as [start, end] sections.
	# Walks 1..NumberOfItems, grouping consecutive positions not in anPos.
	def AntiPositionsZZ(_anPos_)
		_aRes_ = []
		_nLen_ = This.NumberOfItems()
		_aIn_ = _anPos_
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

	def FindNOccurrencesCS(_n_, pItem, pCaseSensitive)
		_oFnoFinder_ = new stzListFinder(This)
		return _oFnoFinder_.FindNOccurrencesCS(_n_, pItem, pCaseSensitive)

	# The positions of the first n occurrences of the given item.
	def FindNOccurrences(_n_, pItem)
		return This.FindNOccurrencesCS(_n_, pItem, 1)

	# FindFirstCS/FindFirst/FindLastCS/FindLast already defined above as aliases

	def FindGivenOccurrencesCS(panOccurrences, pItem, pCaseSensitive)
		_oFgoFinder_ = new stzListFinder(This)
		return _oFgoFinder_.FindGivenOccurrencesCS(panOccurrences, pItem, pCaseSensitive)

	def FindGivenOccurrences(panOccurrences, pItem)
		return This.FindGivenOccurrencesCS(panOccurrences, pItem, 1)

	def FindAllExceptFirstCS(pItem, pCaseSensitive)
		_oFaefFinder_ = new stzListFinder(This)
		return _oFaefFinder_.FindAllExceptFirstCS(pItem, pCaseSensitive)

	# The positions of every occurrence of the item EXCEPT the first.
	def FindAllExceptFirst(pItem)
		return This.FindAllExceptFirstCS(pItem, 1)

	def FindAllExceptLastCS(pItem, pCaseSensitive)
		_oFaelFinder_ = new stzListFinder(This)
		return _oFaelFinder_.FindAllExceptLastCS(pItem, pCaseSensitive)

	# The positions of every occurrence of the item EXCEPT the last.
	def FindAllExceptLast(pItem)
		return This.FindAllExceptLastCS(pItem, 1)

	def FindNextNthOccurrenceCS(_n_, pItem, pnStartingAt, pCaseSensitive)
		_oFnnoFinder_ = new stzListFinder(This)
		return _oFnnoFinder_.FindNextNthOccurrenceCS(_n_, pItem, pnStartingAt, pCaseSensitive)

	def FindNextNthOccurrence(_n_, pItem, pnStartingAt)
		return This.FindNextNthOccurrenceCS(_n_, pItem, pnStartingAt, 1)

	def FindNextOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)
		_oFnoFinder2_ = new stzListFinder(This)
		return _oFnoFinder2_.FindNextOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)

	# The position of the next occurrence of the item after the given
	# position (0 when there is none).
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
	def FindNthPrevious(_n_, pItem, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		return This.FindPreviousNthOccurrenceCS(_n_, pItem, pnStartingAt, 1)

		def FindNthPreviousCS(_n_, pItem, pnStartingAt, pCaseSensitive)
			if isList(pnStartingAt) and len(pnStartingAt) = 2
				pnStartingAt = pnStartingAt[2]
			ok
			return This.FindPreviousNthOccurrenceCS(_n_, pItem, pnStartingAt, pCaseSensitive)

	# FindNthNext(n, pItem, pnStartingAt): symmetric forward variant.
	def FindNthNext(_n_, pItem, pnStartingAt)
		if isList(pnStartingAt) and len(pnStartingAt) = 2
			pnStartingAt = pnStartingAt[2]
		ok
		return This.FindNextNthOccurrenceCS(_n_, pItem, pnStartingAt, 1)

		def FindNthNextCS(_n_, pItem, pnStartingAt, pCaseSensitive)
			if isList(pnStartingAt) and len(pnStartingAt) = 2
				pnStartingAt = pnStartingAt[2]
			ok
			return This.FindNextNthOccurrenceCS(_n_, pItem, pnStartingAt, pCaseSensitive)

	def FindPreviousNthOccurrenceCS(_n_, pItem, pnStartingAt, pCaseSensitive)
		_oFpnoFinder_ = new stzListFinder(This)
		return _oFpnoFinder_.FindPreviousNthOccurrenceCS(_n_, pItem, pnStartingAt, pCaseSensitive)

	def FindPreviousNthOccurrence(_n_, pItem, pnStartingAt)
		return This.FindPreviousNthOccurrenceCS(_n_, pItem, pnStartingAt, 1)

	def FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)
		_oFpoFinder_ = new stzListFinder(This)
		return _oFpoFinder_.FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)

	# The position of the nearest occurrence of the item before the
	# given position (0 when there is none).
	def FindPreviousOccurrence(pItem, pnStartingAt)
		return This.FindPreviousOccurrenceCS(pItem, pnStartingAt, 1)

	#-- Missing name-variants for the next/previous occurrence family
	#-- (delegating to stzListFinder; strictly-after / strictly-before).
	def FindNthNextOccurrence(_n_, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindNthNextOccurrence(_n_, pItem, pnStartingAt)

	def FindNextNth(_n_, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindNextNth(_n_, pItem, pnStartingAt)

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

	#@ aka  index of, position of, locate, where is, at what index
	def FindItem(pItem)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindItem(pItem)

	def FindPreviousNth(_n_, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.FindPreviousNth(_n_, pItem, pnStartingAt)

	def NthNextOccurrence(_n_, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.NthNextOccurrence(_n_, pItem, pnStartingAt)

	def NextNthOccurrence(_n_, pItem, pnStartingAt)
		_oFnx_ = new stzListFinder(This)
		return _oFnx_.NextNthOccurrence(_n_, pItem, pnStartingAt)

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

	# The items that repeat in consecutive runs (dup-secutive:
	# duplicated AND consecutive).
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

	def FindNthSmallest(_n_)
		return This.Find(This.NthSmallest(_n_))

	def FindNthLargest(_n_)
		return This.Find(This.NthLargest(_n_))

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
		_nLen_ = ring_len(paItems)
		for _i_ = 1 to _nLen_
			This.RemoveAllCS(paItems[_i_], 1)
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
	def RemoveThisNthItem(_n_, pItem)
		_pos_ = This.FindAllCS(pItem, 1)
		if _n_ >= 1 and ring_len(_pos_) >= _n_
			This._SetContent(_StzRemoveAtPositions(This.Content(), [ _pos_[_n_] ]))
		ok

		def RemoveNth(_n_, pItem)
			This.RemoveThisNthItem(_n_, pItem)

	#-- occurrence removal relative to a position (Next strictly after,
	#-- Previous strictly before; the Nth index is forward into that run)
	def RemoveNextNthOccurrence(_n_, pItem, pnStartingAt)
		_p_ = This.FindNthNextOccurrence(_n_, pItem, pnStartingAt)
		if _p_ > 0
			This._SetContent(_StzRemoveAtPositions(This.Content(), [ _p_ ]))
		ok

	def RemoveNextNthOccurrences(panN, pItem, pnStartingAt)
		_ps_ = This.FindNextNthOccurrencesST(panN, pItem, pnStartingAt)
		This._SetContent(_StzRemoveAtPositions(This.Content(), _ps_))

		def NextNthOccurrencesRemoved(panN, pItem, pnStartingAt)
			_ps_ = This.FindNextNthOccurrencesST(panN, pItem, pnStartingAt)
			return _StzRemoveAtPositions(This.Content(), _ps_)

	def RemovePreviousNthOccurrence(_n_, pItem, pnStartingAt)
		_ps_ = This.FindPreviousNthOccurrences([ _n_ ], pItem, pnStartingAt)
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
	def RemoveNthItem(_n_)
		if isString(_n_)
			if _n_ = :Last or _n_ = :LastItem
				_n_ = This.NumberOfItems()
			but _n_ = :First or _n_ = :FirstItem
				_n_ = 1
			ok
		ok
		This.RemoveItemAtPosition(_n_)

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
	def ItemsOccurringNTimes(_n_)
		return _StzItemsByCountOp(This.Content(), _n_, "ge")

		def ItemsOccuringNTimes(_n_)
			return This.ItemsOccurringNTimes(_n_)

		def ItemsOccurringNTimesOrMore(_n_)
			return This.ItemsOccurringNTimes(_n_)

	def ItemsOccurringExactlyNTimes(_n_)
		return _StzItemsByCountOp(This.Content(), _n_, "eq")

		def ItemsOccuringExactlyNTimes(_n_)
			return This.ItemsOccurringExactlyNTimes(_n_)

	def ItemsOccurringLessThanNTimes(_n_)
		return _StzItemsByCountOp(This.Content(), _n_, "lt")

	def ItemsOccurringNTimesOrLess(_n_)
		return _StzItemsByCountOp(This.Content(), _n_, "le")

	def ItemsOccurringMoreThanNTimes(_n_)
		return _StzItemsByCountOp(This.Content(), _n_, "gt")

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

	# SplitAtPositions MUTATES the content into the list of parts; the
	# items AT the positions are DROPPED (split "at", not "before").
	def SplitAtPositions(panPos)
		if NOT isList(panPos) return [ This.Content() ] ok
		_aSap_ = This.Content()
		_nSapL_ = ring_len(_aSap_)
		_nSapPL_ = ring_len(panPos)
		_aSapParts_ = []
		_aSapCur_ = []
		for _iSap_ = 1 to _nSapL_
			_bSapAnchor_ = FALSE
			for _jSap_ = 1 to _nSapPL_
				if panPos[_jSap_] = _iSap_
					_bSapAnchor_ = TRUE
					exit
				ok
			next
			if _bSapAnchor_
				if ring_len(_aSapCur_) > 0 _aSapParts_ + _aSapCur_ ok
				_aSapCur_ = []
			else
				_aSapCur_ + _aSap_[_iSap_]
			ok
		next
		if ring_len(_aSapCur_) > 0 _aSapParts_ + _aSapCur_ ok
		This.Update(_aSapParts_)
		return _aSapParts_

	def SplittedAtPositions(panPos)
		_oSdapSplitter_ = new stzListSplits(This)
		return _oSdapSplitter_.SplittedAtPositions(panPos)

	def SplitAtPositionsZZ(panPos)
		_oSapzzSplitter_ = new stzListSplits(This)
		return _oSapzzSplitter_.SplitAtPositionsZZ(panPos)

	def SplittedAtPositionsZZ(panPos)
		_oSdapzzSplitter_ = new stzListSplits(This)
		return _oSdapzzSplitter_.SplittedAtPositionsZZ(panPos)

	def SplitAtPosition(_n_)
		_oSaposSplitter_ = new stzListSplits(This)
		return _oSaposSplitter_.SplitAtPosition(_n_)

	def SplittedAtPosition(_n_)
		_oSdaposSplitter_ = new stzListSplits(This)
		return _oSdaposSplitter_.SplittedAtPosition(_n_)

	def SplitAtPositionZZ(_n_)
		_oSapozzSplitter_ = new stzListSplits(This)
		return _oSapozzSplitter_.SplitAtPositionZZ(_n_)

	def SplittedAtPositionZZ(_n_)
		_oSdapozzSplitter_ = new stzListSplits(This)
		return _oSdapozzSplitter_.SplittedAtPositionZZ(_n_)

	def SplitAtCS(pItem, pCaseSensitive)
		_oSacsSplitter_ = new stzListSplits(This)
		return _oSacsSplitter_.SplitAtCS(pItem, pCaseSensitive)

	def SplittedAtCS(pItem, pCaseSensitive)
		_oSdacsSplitter_ = new stzListSplits(This)
		return _oSdacsSplitter_.SplittedAtCS(pItem, pCaseSensitive)

	# The parts of the list split at each occurrence of the given item
	# (the item itself is not kept in the parts).
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

	def SplitBeforePosition(_n_)
		_oSbpSplitter_ = new stzListSplits(This)
		return _oSbpSplitter_.SplitBeforePosition(_n_)

	def SplittedBeforePosition(_n_)
		_oSdbpSplitter_ = new stzListSplits(This)
		return _oSdbpSplitter_.SplittedBeforePosition(_n_)

	def SplitBeforeCS(pItem, pCaseSensitive)
		_oSbcsSplitter_ = new stzListSplits(This)
		return _oSbcsSplitter_.SplitBeforeCS(pItem, pCaseSensitive)

	# Split the list before each occurrence of the item: each
	# occurrence starts a new part.
	def SplitBefore(pItem)
		return This.SplitBeforeCS(pItem, 1)

	def SplitAfterPosition(_n_)
		_oSafpSplitter_ = new stzListSplits(This)
		return _oSafpSplitter_.SplitAfterPosition(_n_)

	def SplittedAfterPosition(_n_)
		_oSdafpSplitter_ = new stzListSplits(This)
		return _oSdafpSplitter_.SplittedAfterPosition(_n_)

	def SplitAfterCS(pItem, pCaseSensitive)
		_oSafcsSplitter_ = new stzListSplits(This)
		return _oSafcsSplitter_.SplitAfterCS(pItem, pCaseSensitive)

	# Split the list after each occurrence of the item: each
	# occurrence closes its part.
	def SplitAfter(pItem)
		return This.SplitAfterCS(pItem, 1)

	def SplitToNParts(_n_)
		_oStnpSplitter_ = new stzListSplits(This)
		return _oStnpSplitter_.SplitToNParts(_n_)

		def SplitToNPartsQ(_n_)
			return new stzList( This.SplitToNParts(_n_) )

	def SplittedToNParts(_n_)
		_oSdtnpSplitter_ = new stzListSplits(This)
		return _oSdtnpSplitter_.SplittedToNParts(_n_)

	def SplitToPartsOfNItems(_n_)
		# Mutator: delegating to new stzListSplits(This) would mutate a COPY of
		# This (Ring copies objects passed to a constructor), so the change was
		# lost. Write back through This itself using the returning form.
		This.UpdateWith( This.SplittedToPartsOfNItems(_n_) )

		def SplitToPartsOf(_n_)
			This.SplitToPartsOfNItems(_n_)

	def SplittedToPartsOfNItems(_n_)
		_oSdtponiSplitter_ = new stzListSplits(This)
		return _oSdtponiSplitter_.SplittedToPartsOfNItems(_n_)

		def SplittedToPartsOf(_n_)
			return This.SplittedToPartsOfNItems(_n_)

	def SplitAtPacer(nPace, _nStart_)
		_oSapcrSplitter_ = new stzListSplits(This)
		return _oSapcrSplitter_.SplitAtPacer(nPace, _nStart_)

	def SplittedAtPacer(nPace, _nStart_)
		_oSdapcrSplitter_ = new stzListSplits(This)
		return _oSdapcrSplitter_.SplittedAtPacer(nPace, _nStart_)

	# SplitW MUTATES the content into the list of parts (the matching
	# items are dropped; SplittedW is the passive twin).
	def SplitW(pcCondition)
		return This.SplitAtPositions( This.FindW(pcCondition) )

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

	def ExtractNth(_n_)
		_oEnExt_ = new stzListExtractor(This)
		_oEnExt_.ExtractNth(_n_)
		This.UpdateWith(_oEnExt_.Content())
		return This.Content()[_n_]

	def ExtractFirst(pItem)
		# Extract = remove the FIRST occurrence of pItem from the list and
		# return it (the destructive sibling of FindFirst).
		return This.ExtractFirstCS(pItem, 1)

	def ExtractLast(pItem)
		# Remove the LAST occurrence of pItem and return it.
		return This.ExtractLastCS(pItem, 1)

	def ExtractSection(_n1_, _n2_)
		# Capture the section BEFORE removing it (afterwards the list is shorter,
		# so This.Section(n1,n2) would go out of range).
		_aEsSection_ = This.Section(_n1_, _n2_)
		_oEsExt_ = new stzListExtractor(This)
		_oEsExt_.ExtractSection(_n1_, _n2_)
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
		_anPos_ = This.FindW(pcCondition)
		_aResult_ = This.ItemsAtPositions(_anPos_)
		This.RemoveItemsAtPositions(_anPos_)
		return _aResult_

		def ExtractWQ(pcCondition)
			return new stzList( This.ExtractW(pcCondition) )

	def ExtractNthOccurrenceCS(_n_, pItem, pCaseSensitive)
		# Remove the nth occurrence of pItem and RETURN it (the extracted
		# value), per the monolith's authoritative Extract semantics.
		_nPos_ = This.FindNthOccurrenceCS(_n_, pItem, pCaseSensitive)
		This.RemoveItemAtPosition(_nPos_)
		return pItem

	def ExtractNthOccurrence(_n_, pItem)
		return This.ExtractNthOccurrenceCS(_n_, pItem, 1)

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

	def Take(_n_)
		_oTkExt_ = new stzListExtractor(This)
		_aTkResult_ = _oTkExt_.Take(_n_)
		This.UpdateWith(_oTkExt_.Content())
		return _aTkResult_

	def TakeLast(_n_)
		_oTlExt_ = new stzListExtractor(This)
		_aTlResult_ = _oTlExt_.TakeLast(_n_)
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

	def TrimToSize(_n_)
		_oTtsTr_ = new stzListTrimmer(This)
		_oTtsTr_.TrimToSize(_n_)
		This.UpdateWith(_oTtsTr_.Content())

	def TrimmedToSize(_n_)
		_oTdtsTr_ = new stzListTrimmer(This)
		return _oTdtsTr_.TrimmedToSize(_n_)

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

	def NRandomItems(_n_)
		_oNriGt_ = new stzListGetter(This)
		return _oNriGt_.NRandomItems(_n_)

	#-- rnd* : terse random helpers (the "give me some random cards" idiom).
	#   rndItems() returns a random NUMBER of random items; rndNItems(n) a
	#   fixed n. The rndRemove* forms are the MUTATING counterparts -- they
	#   drop random items from the list in place and return This for chaining.

	def rndNItems(_n_)
		return This.NRandomItems(_n_)

		def RandomNItems(_n_)
			return This.NRandomItems(_n_)

	def rndItems()
		_nRiN_ = This.NumberOfItems()
		if _nRiN_ = 0 return [] ok
		_nRiK_ = random(_nRiN_ - 1) + 1
		return This.NRandomItems(_nRiK_)

		def RandomItems()
			return This.rndItems()

	def rndRemoveNItems(_n_)
		_nRrN_ = This.NumberOfItems()
		if _n_ <= 0 or _nRrN_ = 0 return This ok
		if _n_ > _nRrN_ _n_ = _nRrN_ ok
		#-- shuffle the positions 1.._nRrN_ and remove the first n of them
		_anRrIdx_ = 1 : _nRrN_
		for _iRr_ = _nRrN_ to 2 step -1
			_jRr_ = random(_iRr_ - 1) + 1
			_xRr_ = _anRrIdx_[_iRr_]
			_anRrIdx_[_iRr_] = _anRrIdx_[_jRr_]
			_anRrIdx_[_jRr_] = _xRr_
		next
		_anRrPick_ = []
		for _kRr_ = 1 to _n_
			_anRrPick_ + _anRrIdx_[_kRr_]
		next
		This.RemoveItemsAtPositions(_anRrPick_)
		return This

		def rndRemoveNItemsQ(_n_)
			return This.rndRemoveNItems(_n_)

		def RandomRemoveNItems(_n_)
			return This.rndRemoveNItems(_n_)

	def rndRemoveItems()
		_nRr2N_ = This.NumberOfItems()
		if _nRr2N_ = 0 return This ok
		_nRr2K_ = random(_nRr2N_ - 1) + 1
		return This.rndRemoveNItems(_nRr2K_)

		def rndRemoveItemsQ()
			return This.rndRemoveItems()

		def RandomRemoveItems()
			return This.rndRemoveItems()

	def ItemsBetween(_n1_, _n2_)
		_oIbGt_ = new stzListGetter(This)
		return _oIbGt_.ItemsBetween(_n1_, _n2_)

	def EveryNthItem(_n_)
		_oEniGt_ = new stzListGetter(This)
		return _oEniGt_.EveryNthItem(_n_)

	def Head(_n_)
		_oHdGt_ = new stzListGetter(This)
		return _oHdGt_.Head(_n_)

	def Tail(_n_)
		_oTlGt_ = new stzListGetter(This)
		return _oTlGt_.Tail(_n_)

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

	def SlidingWindow(_n_)
		_oSwGt_ = new stzListGetter(This)
		return _oSwGt_.SlidingWindow(_n_)

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
		_cAwName_ = ""
		_nAwStart_ = 1
		_nAwEnd_ = This.NumberOfItems()
		_nAwStep_ = 1
		_nAwMoves_ = 0
		_cAwMode_ = :Step

		_aAwArgs_ = [ p1, p2, p3, p4 ]
		_nAwPos_ = 0
		for _iAw_ = 1 to 4
			_a_ = _aAwArgs_[_iAw_]
			if isList(_a_) and len(_a_) = 2 and isString(_a_[1])
				_k_ = lower(_a_[1])
				_v_ = _a_[2]
				if _k_ = "named" or _k_ = "name"
					_cAwName_ = _v_
				but _k_ = "startingat"
					_nAwStart_ = _v_
				but _k_ = "endingat"
					_nAwEnd_ = _v_
				but _k_ = "nstep" or _k_ = "nstepsatime"
					_nAwStep_ = _v_ _cAwMode_ = :Step
				but _k_ = "nequalmoves"
					_nAwMoves_ = _v_ _cAwMode_ = :EqualMoves
				ok
			but isString(_a_) or isNumber(_a_)
				_nAwPos_++
				if _nAwPos_ = 1
					_cAwName_ = _a_
				but _nAwPos_ = 2
					_nAwStart_ = _a_
				but _nAwPos_ = 3
					_nAwEnd_ = _a_
				but _nAwPos_ = 4
					_nAwStep_ = _a_
				ok
			ok
		next

		@aWalkers + [ _cAwName_, [ _nAwStart_, _nAwEnd_, _nAwStep_, _cAwMode_, _nAwMoves_ ] ]

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

	def WalkNForward(_n_)
		_oWnfWk_ = new stzListWalker(This)
		return _oWnfWk_.WalkNForward(_n_)

	def WalkNBackward(_n_)
		_oWnbWk_ = new stzListWalker(This)
		return _oWnbWk_.WalkNBackward(_n_)

	# Walk the inclusive range n1..n2 (descending if n1 > n2). The IB
	# form takes a return type (:WalkedPositions default / :WalkedItems).

	def WalkBetweenIB(_n1_, _n2_, pReturn)
		_anWbPos_ = _n1_ : _n2_
		_cWbRet_ = pReturn
		if isList(pReturn) and ring_len(pReturn) = 2 and isString(pReturn[1])
			_cWbRet_ = pReturn[2]
		ok
		if _cWbRet_ = :WalkedItems or _cWbRet_ = :Items
			return This.ItemsAtPositions(_anWbPos_)
		ok
		return _anWbPos_

	def WalkBetween(_n1_, _n2_)
		return This.WalkBetweenIB(_n1_, _n2_, :WalkedPositions)

	# Walk forward 1..n then back n-1..1.

	def WalkForthAndBackXT(pReturn)
		_nWfLen_ = This.NumberOfItems()
		_anWfPos_ = []
		for iWf = 1 to _nWfLen_
			_anWfPos_ + iWf
		next
		for iWf = _nWfLen_ - 1 to 1 step -1
			_anWfPos_ + iWf
		next
		_cWfRet_ = pReturn
		if isList(pReturn) and ring_len(pReturn) = 2 and isString(pReturn[1])
			_cWfRet_ = pReturn[2]
		ok
		if _cWfRet_ = :WalkedItems or _cWfRet_ = :Items
			return This.ItemsAtPositions(_anWfPos_)
		ok
		return _anWfPos_

	def WalkForthAndBack()
		return This.WalkForthAndBackXT(:WalkedPositions)

	# Walk forward up to and including the first occurrence of pItem.

	def WalkUntilItem(pItem)
		_nWuiPos_ = This.FindFirst(pItem)
		if _nWuiPos_ > 0
			return 1 : _nWuiPos_
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

	def WalkZigZag(_nStep_)
		_oWzzWk_ = new stzListWalker(This)
		return _oWzzWk_.WalkZigZag(_nStep_)

	def WalkEveryNth(_n_)
		_oWenWk_ = new stzListWalker(This)
		return _oWenWk_.WalkEveryNth(_n_)

	# PositionsWhere already defined above as alias of FindAllItemsW

	def WalkFromTo(nFrom, nTo)
		_oWftWk_ = new stzListWalker(This)
		return _oWftWk_.WalkFromTo(nFrom, nTo)

	def WalkSkipping(_n_)
		_oWsWk_ = new stzListWalker(This)
		return _oWsWk_.WalkSkipping(_n_)

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

	# Move / Swap accept the named-param spellings
	# Move(:ItemFromPosition = a, :To = b), Swap(:Positions = a, :And = b),
	# and the value form Swap(item1, :And = item2).
	def Move(_n1_, _n2_)
		if isList(_n1_) and len(_n1_) = 2 and isString(_n1_[1]) and
		   (lower(_n1_[1]) = "itemfromposition" or lower(_n1_[1]) = "fromposition" or
		    lower(_n1_[1]) = "from") and isNumber(_n1_[2])
			_n1_ = _n1_[2]
		ok
		if isList(_n2_) and len(_n2_) = 2 and isString(_n2_[1]) and
		   (lower(_n2_[1]) = "to" or lower(_n2_[1]) = "toposition") and isNumber(_n2_[2])
			_n2_ = _n2_[2]
		ok
		_oMvMvr_ = new stzListMover(This)
		_oMvMvr_.Move(_n1_, _n2_)
		This.UpdateWith(_oMvMvr_.Content())

	#@ aka  exchange, swap positions, interchange two items
	def Swap(_n1_, _n2_)
		if isList(_n1_) and len(_n1_) = 2 and isString(_n1_[1]) and
		   (lower(_n1_[1]) = "positions" or lower(_n1_[1]) = "position") and
		   isNumber(_n1_[2])
			_n1_ = _n1_[2]
		ok
		if isList(_n2_) and len(_n2_) = 2 and isString(_n2_[1]) and
		   lower(_n2_[1]) = "and"
			# Swap(item1, :And = item2) -- swap the two VALUES' positions.
			if NOT isNumber(_n1_)
				_nSw1_ = This.FindFirst(_n1_)
				_nSw2_ = This.FindFirst(_n2_[2])
				if _nSw1_ < 1 or _nSw2_ < 1 return ok
				_n1_ = _nSw1_
				_n2_ = _nSw2_
			but isNumber(_n2_[2])
				_n2_ = _n2_[2]
			ok
		ok
		_oSwMvr_ = new stzListMover(This)
		_oSwMvr_.Swap(_n1_, _n2_)
		This.UpdateWith(_oSwMvr_.Content())

	def MoveToStart(_n_)
		_oMtsMvr_ = new stzListMover(This)
		_oMtsMvr_.MoveToStart(_n_)
		This.UpdateWith(_oMtsMvr_.Content())

	def MoveToEnd(_n_)
		_oMteMvr_ = new stzListMover(This)
		_oMteMvr_.MoveToEnd(_n_)
		This.UpdateWith(_oMteMvr_.Content())

	def SwapFirstAndLast()
		_oSfalMvr_ = new stzListMover(This)
		_oSfalMvr_.SwapFirstAndLast()
		This.UpdateWith(_oSfalMvr_.Content())

	def MoveMany(panPositions, nTo)
		_oMmMvr_ = new stzListMover(This)
		_oMmMvr_.MoveMany(panPositions, nTo)
		This.UpdateWith(_oMmMvr_.Content())

	def RotateLeft(_n_)
		_oRlMvr_ = new stzListMover(This)
		_oRlMvr_.RotateLeft(_n_)
		This.UpdateWith(_oRlMvr_.Content())

	def RotatedLeft(_n_)
		_oRdlMvr_ = new stzListMover(This)
		return _oRdlMvr_.RotatedLeft(_n_)

	def RotateRight(_n_)
		_oRrMvr_ = new stzListMover(This)
		_oRrMvr_.RotateRight(_n_)
		This.UpdateWith(_oRrMvr_.Content())

	def RotatedRight(_n_)
		_oRdrMvr_ = new stzListMover(This)
		return _oRdrMvr_.RotatedRight(_n_)

	def Shuffle()
		_oShMvr_ = new stzListMover(This)
		_oShMvr_.Shuffle()
		This.UpdateWith(_oShMvr_.Content())

	#@ aka  randomize, mix, scramble, random order, jumble
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

	def SectionCSZ(_n1_, _n2_, pCaseSensitive)
		_oScszSec_ = new stzListSections(This)
		return _oScszSec_.SectionCSZ(_n1_, _n2_, pCaseSensitive)

	def SectionZ(_n1_, _n2_)
		return This.SectionCSZ(_n1_, _n2_, 1)

	def SectionCSZZ(_n1_, _n2_, pCaseSensitive)
		_oScszzSec_ = new stzListSections(This)
		return _oScszzSec_.SectionCSZZ(_n1_, _n2_, pCaseSensitive)

	def SectionZZ(_n1_, _n2_)
		return This.SectionCSZZ(_n1_, _n2_, 1)

	def Sections(paSections)
		_oSsSec_ = new stzListSections(This)
		return _oSsSec_.Sections(paSections)

	def FindAntiSection(_n1_, _n2_)
		_oFasSec_ = new stzListSections(This)
		return _oFasSec_.FindAntiSection(_n1_, _n2_)

	def AntiSection(_n1_, _n2_)
		_oAsSec_ = new stzListSections(This)
		return _oAsSec_.AntiSection(_n1_, _n2_)

	def FindAntiSectionIB(_n1_, _n2_)
		_oFasibSec_ = new stzListSections(This)
		return _oFasibSec_.FindAntiSectionIB(_n1_, _n2_)

	def AntiSectionIB(_n1_, _n2_)
		_oAsibSec_ = new stzListSections(This)
		return _oAsibSec_.AntiSectionIB(_n1_, _n2_)

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
		_aCsfC_ = This.Classes()
		_aCsfR_ = []
		_nCsfL_ = ring_len(_aCsfC_)
		for iCsf = 1 to _nCsfL_
			_aCsfR_ + _StzListKeyToShortForm(_aCsfC_[iCsf])
		next
		return _aCsfR_

	def ClassifySF()
		_aClsfC_ = This.Classify()
		_aClsfR_ = []
		_nClsfL_ = ring_len(_aClsfC_)
		for iClsf = 1 to _nClsfL_
			_aClsfR_ + [ _StzListKeyToShortForm(_aClsfC_[iClsf][1]), _aClsfC_[iClsf][2] ]
		next
		return _aClsfR_

		def ClassifiedSF()
			return This.ClassifySF()

	def KlassSF(pcShortForm)
		_aKsfC_ = This.ClassifySF()
		_nKsfL_ = ring_len(_aKsfC_)
		for iKsf = 1 to _nKsfL_
			if _aKsfC_[iKsf][1] = pcShortForm
				return _aKsfC_[iKsf][2]
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

	def ItemsAppearingNTimes(_n_)
		_oIantClf_ = new stzListClassifier(This)
		return _oIantClf_.ItemsAppearingNTimes(_n_)

	def ItemsAppearingMoreThanNTimes(_n_)
		_oIamtntClf_ = new stzListClassifier(This)
		return _oIamtntClf_.ItemsAppearingMoreThanNTimes(_n_)

	def ItemsAppearingLessThanNTimes(_n_)
		_oIaltntClf_ = new stzListClassifier(This)
		return _oIaltntClf_.ItemsAppearingLessThanNTimes(_n_)

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
		_nLen_ = This.NumberOfItems()
		return This.Section(floor(_nLen_ / 2) + 1, _nLen_)

	def PartitionW(pcCondition)
		_oPwClf_ = new stzListClassifier(This)
		return _oPwClf_.PartitionW(pcCondition)

	def Chunks(_n_)
		_oChClf_ = new stzListClassifier(This)
		return _oChClf_.Chunks(_n_)

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

	def RandomPositionGreaterThan(_n_)
		_oRpgtRnd_ = new stzListRandom(This)
		return _oRpgtRnd_.RandomPositionGreaterThan(_n_)

	def RandomPositionLessThan(_n_)
		_oRpltRnd_ = new stzListRandom(This)
		return _oRpltRnd_.RandomPositionLessThan(_n_)

	def RandomPositionExcept(_n_)
		_oRpeRnd_ = new stzListRandom(This)
		return _oRpeRnd_.RandomPositionExcept(_n_)

	def RandomPositionExceptPositions(panPos)
		_oRpepRnd_ = new stzListRandom(This)
		return _oRpepRnd_.RandomPositionExceptPositions(panPos)

	def NRandomPositions(_n_)
		_oNrpRnd_ = new stzListRandom(This)
		return _oNrpRnd_.NRandomPositions(_n_)

	def RandomItemExceptCS(pItem, pCaseSensitive)
		_oRiecsRnd_ = new stzListRandom(This)
		return _oRiecsRnd_.RandomItemExceptCS(pItem, pCaseSensitive)

	def RandomItemExcept(pItem)
		return This.RandomItemExceptCS(pItem, 1)

	def RandomItemExceptPosition(_n_)
		_oRiepRnd_ = new stzListRandom(This)
		return _oRiepRnd_.RandomItemExceptPosition(_n_)

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

	def RandomizeSection(_n1_, _n2_)
		_oRzsRnd_ = new stzListRandom(This)
		_oRzsRnd_.RandomizeSection(_n1_, _n2_)
		This.UpdateWith(_oRzsRnd_.Content())

	def SectionRandomized(_n1_, _n2_)
		_oSrRnd_ = new stzListRandom(This)
		return _oSrRnd_.SectionRandomized(_n1_, _n2_)

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
		_nLen_ = This.NumberOfItems()
		_aC_ = This.Content()

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
			if _b_ < 0 _b_ = _nLen_ + _b_ + 1 ok
			if _a_ < 1 _a_ = 1 ok
			if _b_ > _nLen_ _b_ = _nLen_ ok
			for _i_ = _a_ to _b_
				_aRes_ + _aC_[_i_]
			next
			return _aRes_
		ok

		if _bUntil_
			if _nStart_ < 1 _nStart_ = 1 ok
			for _i_ = _nStart_ to _nLen_
				# does aC[_i_] satisfy the until-condition?
				_oOne_ = new stzList([ _aC_[_i_] ])
				_bHit_ = ( len(_oOne_.FindAllItemsW(_cUntil_)) > 0 )
				if _bHit_
					if _bInc_ _aRes_ + _aC_[_i_] ok
					exit
				ok
				_aRes_ + _aC_[_i_]
			next
			return _aRes_
		ok

		# no window -> yield every item
		return _aC_

	# YieldW(pcCondition, pcYielder): the @item-syntax form of YieldW
	# -- for items matching pcCondition, yield the value of pcYielder.
	# Engine-backed via YieldW (no eval).


	# YieldAtW / YieldAtW: restrict to the given positions first,
	# then yield over those.
	def YieldAtW(panPos, pcCondition, pcYielder)
		_oYawSub_ = This.ItemsAtPositionsQ(panPos)
		return _oYawSub_.YieldW(pcCondition, pcYielder)


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

	#@ aka  put at position, add at, place into, inject at index
	def Insert(pItem, pWhere)
		_oIIns_ = new stzListInserter(This)
		_oIIns_.Insert(pItem, pWhere)
		This.UpdateWith(_oIIns_.Content())

	def InsertBeforePosition(_n_, pItem)
		_oIbpIns_ = new stzListInserter(This)
		_oIbpIns_.InsertBeforePosition(_n_, pItem)
		This.UpdateWith(_oIbpIns_.Content())

	def InsertAfterPosition(_n_, pItem)
		_oIapIns_ = new stzListInserter(This)
		_oIapIns_.InsertAfterPosition(_n_, pItem)
		This.UpdateWith(_oIapIns_.Content())

	def InsertBeforePositions(panPositions, pItem)
		if NOT isList(panPositions) return ok
		_aIbpSorted_ = _ListCopy(panPositions)
		_nIbpL_ = len(_aIbpSorted_)
		# Sort descending so earlier inserts stay valid.
		for _iIbp_ = 2 to _nIbpL_
			_vIbp_ = _aIbpSorted_[_iIbp_]
			_jIbp_ = _iIbp_ - 1
			while _jIbp_ >= 1 and _aIbpSorted_[_jIbp_] < _vIbp_
				_aIbpSorted_[_jIbp_ + 1] = _aIbpSorted_[_jIbp_]
				_jIbp_--
			end
			_aIbpSorted_[_jIbp_ + 1] = _vIbp_
		next
		# ring_insert places AT the position = right before the old
		# p-th item.
		for _iIbp_ = 1 to _nIbpL_
			_pIbp_ = _aIbpSorted_[_iIbp_]
			if isNumber(_pIbp_) and _pIbp_ >= 1 and _pIbp_ <= len(@aContent)
				This._InvalidateEngine()
				ring_insert(@aContent, _pIbp_, pItem)
			ok
		next

	  #-------------------------------#
	 #  BOUNDER DELEGATIONS          #
	#-------------------------------#

	def SectionXT(_n1_, _n2_)
		_oSxtBnd_ = new stzListBounder(This)
		return _oSxtBnd_.SectionXT(_n1_, _n2_)

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

	def BoundsUpToNItems(_n_)
		_oButniBnd_ = new stzListBounder(This)
		return _oButniBnd_.BoundsUpToNItems(_n_)

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

	def ClampedTo(nMin, _nMax_)
		_oCtBnd_ = new stzListBounder(This)
		return _oCtBnd_.ClampedTo(nMin, _nMax_)

	def ClampTo(nMin, _nMax_)
		_oCltBnd_ = new stzListBounder(This)
		_oCltBnd_.ClampTo(nMin, _nMax_)
		This.UpdateWith(_oCltBnd_.Content())

	def IsWithinBounds(_n_)
		_oIwbBnd_ = new stzListBounder(This)
		return _oIwbBnd_.IsWithinBounds(_n_)

	def ItemsBetweenPositions(_n1_, _n2_)
		_oIbpBnd_ = new stzListBounder(This)
		return _oIbpBnd_.ItemsBetweenPositions(_n1_, _n2_)

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
		_oDfDl_ = This.DeepList()
		return _oDfDl_.DeepFind(pItem)

		def DeepFindAll(pItem)
			return This.DeepFind(pItem)

		def DeepFindCS(pItem, pCaseSensitive)
			return This.DeepFind(pItem)

	# Paths(): the index-path to every node (containers AND leaves) of the
	# nested list, in depth-first order. Documented Softanza feature whose
	# wiring was dropped in the split; engine-backed (stz_list_deep_paths) --
	# same all-node format as the reference GeneratePaths() in stzListPaths.

	def Paths()
		_oPthDl_ = This.DeepList()
		return _oPthDl_.Paths()

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

	# Remove every occurrence of the item at ANY depth of the nested
	# list (mutating).
	def DeepRemove(pItem)
		This._SetContent(This._DeepFilterCS(@aContent, [pItem], 1))
		

		def DeepRemoveQ(pItem)
			This.DeepRemove(pItem)
			return This

		def DeepRemoveCS(pItem, pCaseSensitive)
			This._SetContent(This._DeepFilterCS(@aContent, [pItem], pCaseSensitive))
			

	# DeepRemove applied to each item of the given list (mutating).
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

	# The Unicode codepoint of each character-string item in the list.
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
	def SortOnDown(_n_)
		if This.IsListOfLists()
			_oLol_ = new stzListOfLists(@aContent)
			_oLol_.SortOnDown(_n_)
			This._SetContent(_oLol_.Content())
		else
			This.SortInDescending()
		ok

		def SortOnDownQ(_n_)
			This.SortOnDown(_n_)
			return This

		def SortedOnDown(_n_)
			_oLolc_ = This.Copy()
			_oLolc_.SortOnDown(_n_)
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
		_oTypes_ = new stzList( This.Types() )
		return _oTypes_.Unique()

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

	def NthToLast(_n_)
		return @aContent[ ring_len(@aContent) - _n_ ]

	#-- Shrink the list down to its first n items (mutating).
	#-- Accepts Shrink(n) or the named form Shrink(:ToPosition = n).

	def Shrink(p)
		_n_ = p
		if isList(p) and ring_len(p) = 2
			_n_ = p[2]
		ok
		This._SetContent(This.Section(1, _n_))
		return This

		def ShrinkQ(p)
			This.Shrink(p)
			return This

	#-- Swap two items by position (mutating). Accepts SwapItems(n1, n2)
	#-- or the named form SwapItems(:AtPositions = n1, :And = n2).

	def SwapItems(p1, p2)
		_n1_ = p1
		_n2_ = p2
		if isList(p1) and ring_len(p1) = 2
			_n1_ = p1[2]
		ok
		if isList(p2) and ring_len(p2) = 2
			_n2_ = p2[2]
		ok
		This.Swap(_n1_, _n2_)
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
		_bResult_ = 0
		_nLen_ = ring_len(paItems)
		for _i_ = 1 to _nLen_
			if This.ContainsCS(paItems[_i_], pCaseSensitive)
				_bResult_ = 1
				exit
			ok
		next
		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		if _nLen_ = 0
			return 0
		ok
		if NOT isList(_aContent_[1])
			return 0
		ok
		_nLenFirst_ = ring_len(_aContent_[1])
		_bResult_ = 1
		for _i_ = 2 to _nLen_
			if NOT ( isList(_aContent_[_i_]) and ring_len(_aContent_[_i_]) = _nLenFirst_ )
				_bResult_ = 0
				exit
			ok
		next
		return _bResult_

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
		_nLenList_ = ring_len(@aContent)
		_anPos_ = This.FindCS(pItem, pCaseSensitive)
		_nLenPos_ = ring_len(_anPos_)
		if isNumber(pUpTo)
			_nLenBound1_ = pUpTo
			_nLenBound2_ = pUpTo
		else
			_nLenBound1_ = pUpTo[1]
			_nLenBound2_ = pUpTo[2]
		ok
		_aResult_ = []
		for _i_ = 1 to _nLenPos_
			_aBounds_ = []
			if _anPos_[_i_] - _nLenBound1_ > 0
				_aBounds_ + This.Section(_anPos_[_i_] - _nLenBound1_, _anPos_[_i_] - 1)
			else
				_aBounds_ + []
			ok
			if _nLenList_ - _anPos_[_i_] >= _nLenBound2_
				_aBounds_ + This.Section(_anPos_[_i_] + 1, _anPos_[_i_] + _nLenBound2_)
			else
				_aBounds_ + []
			ok
			_aResult_ + _aBounds_
		next
		return _aResult_

	def BoundsOf(pItem, pUpTo)
		return This.BoundsCS(pItem, pUpTo, 1)

		def NBoundsOf(pItem, pUpTo)
			return This.BoundsCS(pItem, pUpTo, 1)


	def DupOrigins()
		return This.Duplicates()

	def FindItemsW(pCondition)
		return This.FindAllItemsW(pCondition)

	def FirstNItemsQRT(_n_, pcReturnType)
		return This.NFirstItemsQRT(_n_, pcReturnType)

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
		_anSbPos1_ = This.FindAllCS(pItem1, pCaseSensitive)
		_anSbPos2_ = This.FindAllCS(pItem2, pCaseSensitive)
		_anSbPairs_ = []
		_nSb1_ = ring_len(_anSbPos1_)
		_nSb2_ = ring_len(_anSbPos2_)
		for iSb = 1 to _nSb1_
			for jSb = 1 to _nSb2_
				if _anSbPos1_[iSb] < _anSbPos2_[jSb]
					_anSbPairs_ + [ _anSbPos1_[iSb], _anSbPos2_[jSb] ]
				ok
			next
		next
		return This.Sections(_anSbPairs_)

	def SectionsBetween(pItem1, pItem2)
		return This.SectionsBetweenCS(pItem1, pItem2, 1)

		def SectionsBetweenItems(pItem1, pItem2)
			return This.SectionsBetween(pItem1, pItem2)

	#-- Distribute this list's items over a list of "beneficiaries",
	#-- returning [beneficiary, [its items]] pairs. The plain form splits
	#-- as evenly as possible (remainder to the first ones); the XT form
	#-- takes an explicit per-beneficiary share via :Using = [n1, n2, ...].

	def DistributeOverXT(acBeneficiaryItems, _anShareOfEachItem_)
		if isList(_anShareOfEachItem_) and ring_len(_anShareOfEachItem_) = 2 and
		   isString(_anShareOfEachItem_[1]) and
		   (_anShareOfEachItem_[1] = :using or _anShareOfEachItem_[1] = :Using)
			_anShareOfEachItem_ = _anShareOfEachItem_[2]
		ok
		if NOT ( isList(acBeneficiaryItems) and ring_len(acBeneficiaryItems) > 0 )
			StzRaise("Can't distribute the items of the main list over the items of the provided list!")
		ok
		_nDoSum_ = 0
		_nDoSL_ = ring_len(_anShareOfEachItem_)
		for kDo = 1 to _nDoSL_
			_nDoSum_ += _anShareOfEachItem_[kDo]
		next
		if NOT _nDoSum_ = This.NumberOfItems()
			StzRaise("Can't distribute the items of the main list over the items of the provided list!")
		ok
		_aDoResult_ = []
		_nDoLen_ = ring_len(acBeneficiaryItems)
		_nDo1_ = 1
		for iDo = 1 to _nDoLen_
			_cDoBenef_ = acBeneficiaryItems[iDo]
			_nDoRange_ = _anShareOfEachItem_[iDo]
			_nDo2_ = _nDo1_ + _nDoRange_ - 1
			_aDoShare_ = []
			for jDo = _nDo1_ to _nDo2_
				_aDoShare_ + @aContent[jDo]
			next
			_aDoResult_ + [ _cDoBenef_, _aDoShare_ ]
			_nDo1_ = _nDo2_ + 1
		next
		return _aDoResult_

	def DistributeOver(acBeneficiaryItems)
		_nDoLenList_ = This.NumberOfItems()
		_nDoLenBenef_ = ring_len(acBeneficiaryItems)
		_anDoShare_ = []
		if _nDoLenBenef_ >= _nDoLenList_
			for iDo = 1 to _nDoLenList_
				_anDoShare_ + 1
			next
		else
			_nDoN_ = floor( _nDoLenList_ / _nDoLenBenef_ )
			for iDo = 1 to _nDoLenBenef_
				_anDoShare_ + _nDoN_
			next
			_nDoRest_ = _nDoLenList_ - ( _nDoN_ * _nDoLenBenef_ )
			if _nDoRest_ > 0
				for iDo = 1 to _nDoRest_
					_anDoShare_[iDo]++
				next
			ok
		ok
		return This.DistributeOverXT(acBeneficiaryItems, _anDoShare_)

	#-- A copy with all occurrences of an item removed (non-mutating).

	def ItemRemoved(pItem)
		_oIrCopy_ = This.Copy()
		_oIrCopy_.RemoveAllCS(pItem, 1)
		return _oIrCopy_.Content()

		def AllOccurrencesOfThisItemRemoved(pItem)
			return This.ItemRemoved(pItem)

	#-- A copy with the items matching a W condition removed (engine DSL).

	def ItemRemovedW(pcCondition)
		_anIrwMatch_ = This.FindAllItemsW(pcCondition)
		_aIrwC_ = This.Content()
		_nIrwLen_ = ring_len(_aIrwC_)
		_aIrwRes_ = []
		for iIrw = 1 to _nIrwLen_
			_bIrwIn_ = 0
			_nIrwM_ = ring_len(_anIrwMatch_)
			for jIrw = 1 to _nIrwM_
				if _anIrwMatch_[jIrw] = iIrw
					_bIrwIn_ = 1
					exit
				ok
			next
			if _bIrwIn_ = 0
				_aIrwRes_ + _aIrwC_[iIrw]
			ok
		next
		return _aIrwRes_

	#-- True if EVERY given position holds an item matching a W condition.

	def ContainsItemsAtW(panPos, pcCondition)
		_anCiwMatch_ = This.FindAllItemsW(pcCondition)
		_nCiwP_ = ring_len(panPos)
		for iCiw = 1 to _nCiwP_
			_bCiwIn_ = 0
			_nCiwM_ = ring_len(_anCiwMatch_)
			for jCiw = 1 to _nCiwM_
				if _anCiwMatch_[jCiw] = panPos[iCiw]
					_bCiwIn_ = 1
					exit
				ok
			next
			if _bCiwIn_ = 0
				return 0
			ok
		next
		return 1

		def ContainsAtW(panPos, pcCondition)
			return This.ContainsItemsAtW(panPos, pcCondition)

	#-- EachContains: every item (string or sub-list) contains pItem.

	def EachContainsCS(pItem, pCaseSensitive)
		_bResult_ = 1
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		for _i_ = 1 to _nLen_
			if NOT ( isList(_aContent_[_i_]) or isString(_aContent_[_i_]) )
				_bResult_ = 0
				exit
			else
				_oEcItm_ = Q(_aContent_[_i_])
				_bResult_ = _oEcItm_.ContainsCS(pItem, pCaseSensitive)
				if _bResult_ = 0
					exit
				ok
			ok
		next
		return _bResult_

		def EachContains(pItem)
			return This.EachContainsCS(pItem, 1)

		def EachItemContainsCS(pItem, pCaseSensitive)
			return This.EachContainsCS(pItem, pCaseSensitive)

		def EachItemContains(pItem)
			return This.EachContainsCS(pItem, 1)

	#-- EachContainsThese: every item contains all the given items.

	def EachContainsTheseCS(paItems, pCaseSensitive)
		_bResult_ = 1
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		for _i_ = 1 to _nLen_
			if NOT ( isList(_aContent_[_i_]) or isString(_aContent_[_i_]) )
				_bResult_ = 0
				exit
			else
				_oEctItm_ = Q(_aContent_[_i_])
				_bResult_ = _oEctItm_.ContainsTheseCS(paItems, pCaseSensitive)
				if _bResult_ = 0
					exit
				ok
			ok
		next
		return _bResult_

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
		_aDiwR_ = []
		_aDiwThis_ = This.Content()
		_nDiw1_ = ring_len(_aDiwThis_)
		_nDiwO_ = ring_len(paOtherList)
		for iDiw = 1 to _nDiw1_
			_bDiwIn_ = 0
			for jDiw = 1 to _nDiwO_
				if BothAreEqualCS(_aDiwThis_[iDiw], paOtherList[jDiw], pCaseSensitive)
					_bDiwIn_ = 1
					exit
				ok
			next
			if _bDiwIn_ = 0
				_aDiwR_ + _aDiwThis_[iDiw]
			ok
		next
		for jDiw = 1 to _nDiwO_
			_bDiwIn_ = 0
			for iDiw = 1 to _nDiw1_
				if BothAreEqualCS(paOtherList[jDiw], _aDiwThis_[iDiw], pCaseSensitive)
					_bDiwIn_ = 1
					exit
				ok
			next
			if _bDiwIn_ = 0
				_aDiwR_ + paOtherList[jDiw]
			ok
		next
		return _aDiwR_

	def DifferentItemsWith(paOtherList)
		return This.DifferentItemsWithCS(paOtherList, 1)

		def Diff(paOtherList)
			return This.DifferentItemsWith(paOtherList)

	#-- Same items as another list, regardless of order/count (set equality).

	def ContainsSameItemsAsCS(paOtherList, pCaseSensitive)
		if NOT This.EachItemExistsInCS(paOtherList, pCaseSensitive)
			return 0
		ok
		_oCsiOther_ = new stzList(paOtherList)
		return _oCsiOther_.EachItemExistsInCS(This.Content(), pCaseSensitive)

	def ContainsSameItemsAs(paOtherList)
		return This.ContainsSameItemsAsCS(paOtherList, 1)

	#-- IsContainedIn(p): this list, taken as a single value, is an
	#-- element of p (NOT element-wise -- that is AreContainedIn).

	def IsContainedInCS(p, pCaseSensitive)
		if NOT ( isString(p) or isList(p) )
			return 0
		ok
		_oCip_ = Q(p)
		_anPos_ = _oCip_.FindAllCS(This.Content(), pCaseSensitive)
		if ring_len(_anPos_) > 0
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
		_bResult_ = 1
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		_nOther_ = ring_len(paOtherList)
		for _k = 1 to _nLen_
			_bFound_ = 0
			for _j = 1 to _nOther_
				if BothAreEqualCS(_aContent_[_k], paOtherList[_j], pCaseSensitive)
					_bFound_ = 1
					exit
				ok
			next
			if _bFound_ = 0
				_bResult_ = 0
				exit
			ok
		next
		return _bResult_

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
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			if isObject(_aContent_[_i_])
				_aResult_ + _aContent_[_i_]
			ok
		next
		return _aResult_

		def OnlyObjects()
			return This.Objects()

	#-- NumbersAndStrings: the scalar items (numbers or strings).
	#-- The Z form pairs each with its 1-based position.

	def NumbersAndStrings()
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			if isNumber(_aContent_[_i_]) or isString(_aContent_[_i_])
				_aResult_ + _aContent_[_i_]
			ok
		next
		return _aResult_

		def StringsAndNumbers()
			return This.NumbersAndStrings()

	def NumbersAndStringsZ()
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			if isNumber(_aContent_[_i_]) or isString(_aContent_[_i_])
				_aResult_ + [ _aContent_[_i_], _i_ ]
			ok
		next
		return _aResult_

		def StringsAndNumbersZ()
			return This.NumbersAndStringsZ()

	#-- A copy with every string item lower/upper-cased (UTF-8 via the
	#-- engine-backed StzLower/StzUpper); non-string items pass through.

	def Lowercased()
		_aLcC_ = This.Content()
		_nLcL_ = ring_len(_aLcC_)
		_aLcR_ = []
		for iLc = 1 to _nLcL_
			if isString(_aLcC_[iLc])
				_aLcR_ + StzLower(_aLcC_[iLc])
			else
				_aLcR_ + _aLcC_[iLc]
			ok
		next
		return _aLcR_

		def StringsLowercased()
			return This.Lowercased()

	def Uppercased()
		_aUcC_ = This.Content()
		_nUcL_ = ring_len(_aUcC_)
		_aUcR_ = []
		for iUc = 1 to _nUcL_
			if isString(_aUcC_[iUc])
				_aUcR_ + StzUpper(_aUcC_[iUc])
			else
				_aUcR_ + _aUcC_[iUc]
			ok
		next
		return _aUcR_

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
			_cCode_ = This._VizCodeStr()
			_cMark_ = This._VizMarkerLine(pItem, [], _cCode_, pCaseSensitive, 0)
			return This._VizWrap(_cCode_, [ [ "", _cMark_, "" ] ], This._VizWidth())

		def VizFindAll(pItem)
			return This.VizFindCS(pItem, 1)

	#-- _VizCodeStr / _VizMarkerLine: shared helpers for the Viz family.
	#-- The marker line aligns to the COLUMNS of the rendered code string:
	#-- "^" under each occurrence of pItem, "." under each occurrence of any
	#-- item in paOthers, "-" everywhere else. Works for ANY string value,
	#-- not only single chars (long values just span more columns).
	def _VizCodeStr()
		_oVfc_ = new stzString(This.ToCode())
		return _oVfc_.Simplified()

	#-- Default wrap width: long renderings are split into lines this wide,
	#-- each with its marker row(s) underneath.
	def _VizWidth()
		return DefaultVizWidth()

	def _VizMarkerLine(pItem, paOthers, pcCode, pCaseSensitive, bDeep)
		# Depth filter: a SHALLOW viz (bDeep=0) marks only TOP-LEVEL occurrences
		# (bracket depth 1); a DEEP viz (bDeep=1) marks occurrences at any depth.
		_oVfm_ = new stzString(pcCode)
		_aVfmDepth_ = This._VizDepthMap(pcCode)
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
			This._VizPaint(_aVfmCell_, _oVfm_, paOthers[_iVfmO_], pCaseSensitive, _aVfmDepth_, bDeep, ".")
		next
		This._VizPaint(_aVfmCell_, _oVfm_, pItem, pCaseSensitive, _aVfmDepth_, bDeep, "^")

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
		_nLen_ = StzLen(pcCode)
		_oVwCode_ = new stzString(pcCode)

		# pad each marker to the code length so windows line up, and track the
		# widest row LABEL: the marker lines carry that label as a prefix, so the
		# code line must be indented by the same width or the "^" carets drift
		# right of the items they point at.
		_aPad_ = []
		_nVwR_ = len(paRows)
		_nLblW_ = 0
		for _rVw_ = 1 to _nVwR_
			_cM_ = paRows[_rVw_][2]
			_nM_ = StzLen(_cM_)
			for _pVw_ = _nM_ + 1 to _nLen_
				_cM_ += "-"
			next
			_aPad_ + [ paRows[_rVw_][1], _cM_, paRows[_rVw_][3] ]
			_nLW_ = StzLen(paRows[_rVw_][1])
			if _nLW_ > _nLblW_ _nLblW_ = _nLW_ ok
		next

		# right-justify every label to the common width (so the markers -- and the
		# " : " separators -- all start at the same column), and build the matching
		# indent for the code line above them.
		_cVwIndent_ = ""
		for _iVwI_ = 1 to _nLblW_ _cVwIndent_ += " " next
		for _rVwL_ = 1 to _nVwR_
			_cL_ = _aPad_[_rVwL_][1]
			_cLpad_ = ""
			for _pLp_ = StzLen(_cL_) + 1 to _nLblW_
				_cLpad_ += " "
			next
			_aPad_[_rVwL_][1] = _cLpad_ + _cL_
		next

		_cRes_ = ""
		_nStart_ = 1
		_bFirst_ = 1
		while _nStart_ <= _nLen_
			_nEnd_ = _nStart_ + nWidth - 1
			if _nEnd_ > _nLen_ _nEnd_ = _nLen_ ok
			_bLastWin_ = ( _nEnd_ = _nLen_ )

			if NOT _bFirst_ _cRes_ += (NL + NL) ok
			_bFirst_ = 0

			_cRes_ += _cVwIndent_ + _oVwCode_.Section(_nStart_, _nEnd_)
			for _rVw2_ = 1 to _nVwR_
				_oVwM_ = new stzString(_aPad_[_rVw2_][2])
				_cSeg_ = _oVwM_.Section(_nStart_, _nEnd_)
				_cRes_ += NL + _aPad_[_rVw2_][1] + _cSeg_
				if _bLastWin_
					_cRes_ += _aPad_[_rVw2_][3]
				ok
			next
			_nStart_ = _nEnd_ + 1
		end
		return _cRes_

	#-- VizFindXT: like VizFind, plus a "<item> :" label and a "(count)" tally.
	def VizFindXT(pItem)
		return This.VizFindXTCS(pItem, 1)

	def VizFindXTCS(pItem, pCaseSensitive)
		_cCode_ = This._VizCodeStr()
		_cMark_ = This._VizMarkerLine(pItem, [], _cCode_, pCaseSensitive, 0)
		# (count) = the SHALLOW count -- exactly what Find returns (top-level
		# items), so it matches the number of "^" carets drawn.
		_nCount_ = len( This.FindAllCS(pItem, pCaseSensitive) )
		_aRow_ = [ [ @@(pItem) + " : ", _cMark_, " (" + _nCount_ + ")" ] ]
		return This._VizWrap(_cCode_, _aRow_, This._VizWidth())

	#-- VizDeepFind* : like VizFind*, but the markers ALSO cover occurrences
	#-- nested inside sub-lists (any bracket depth), not just top-level ones.
	#-- The "(count)" is the total occurrences, same as the deep markers.
	def VizDeepFindCS(pItem, pCaseSensitive)
		_cCode_ = This._VizCodeStr()
		_cMark_ = This._VizMarkerLine(pItem, [], _cCode_, pCaseSensitive, 1)
		return This._VizWrap(_cCode_, [ [ "", _cMark_, "" ] ], This._VizWidth())

	def VizDeepFind(pItem)
		return This.VizDeepFindCS(pItem, 1)

		def VizDeepFindAll(pItem)
			return This.VizDeepFindCS(pItem, 1)

	def VizDeepFindXTCS(pItem, pCaseSensitive)
		_cCode_ = This._VizCodeStr()
		_cMark_ = This._VizMarkerLine(pItem, [], _cCode_, pCaseSensitive, 1)
		_oVdxCnt_ = new stzString(_cCode_)
		_nCount_ = len( _oVdxCnt_.FindAllCS(@@(pItem), pCaseSensitive) )
		_aRow_ = [ [ @@(pItem) + " : ", _cMark_, " (" + _nCount_ + ")" ] ]
		return This._VizWrap(_cCode_, _aRow_, This._VizWidth())

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
		_cCode_ = This._VizCodeStr()
		_aRows_ = []
		_nN_ = len(paItems)
		for iM = 1 to _nN_
			_aOthers_ = []
			for jM = 1 to _nN_
				if jM != iM _aOthers_ + paItems[jM] ok
			next
			_cMark_ = This._VizMarkerLine(paItems[iM], _aOthers_, _cCode_, pCaseSensitive, 0)
			_aRows_ + [ @@(paItems[iM]) + " : ", _cMark_, "" ]
		next
		return This._VizWrap(_cCode_, _aRows_, This._VizWidth())

	#-- VizFindManyXT: VizFindMany plus a "(count)" tally on each row.
	def VizFindManyXT(paItems)
		return This.VizFindManyXTCS(paItems, 1)

	def VizFindManyXTCS(paItems, pCaseSensitive)
		if NOT isList(paItems)
			StzRaise("Can't proceed! paItems must be a list.")
		ok
		_cCode_ = This._VizCodeStr()
		_aRows_ = []
		_nN_ = len(paItems)
		for iMx = 1 to _nN_
			_aOthers_ = []
			for jMx = 1 to _nN_
				if jMx != iMx _aOthers_ + paItems[jMx] ok
			next
			_cMark_ = This._VizMarkerLine(paItems[iMx], _aOthers_, _cCode_, pCaseSensitive, 0)
			# shallow count = what Find returns (top-level items), matching the carets
			_nCount_ = len( This.FindAllCS(paItems[iMx], pCaseSensitive) )
			_aRows_ + [ @@(paItems[iMx]) + " : ", _cMark_, " (" + _nCount_ + ")" ]
		next
		return This._VizWrap(_cCode_, _aRows_, This._VizWidth())

	#-- Type-filter family: Xs() = items of type X, XsZ() = [item,pos]
	#-- pairs, NumberOfXs() = count. Char = single-codepoint string
	#-- (StzLen=1); Letter = a single ASCII letter.

	def Numbers()
		_aTfC_ = This.Content()
		_nTfL_ = ring_len(_aTfC_)
		_aTfR_ = []
		for iTf = 1 to _nTfL_
			if isNumber(_aTfC_[iTf])
				_aTfR_ + _aTfC_[iTf]
			ok
		next
		return _aTfR_

		def NumbersZ()
			_aTfC_ = This.Content()
			_nTfL_ = ring_len(_aTfC_)
			_aTfR_ = []
			for iTf = 1 to _nTfL_
				if isNumber(_aTfC_[iTf])
					_aTfR_ + [ _aTfC_[iTf], iTf ]
				ok
			next
			return _aTfR_

		def NumberOfNumbers()
			return ring_len(This.Numbers())

	def Strings()
		_aTfC_ = This.Content()
		_nTfL_ = ring_len(_aTfC_)
		_aTfR_ = []
		for iTf = 1 to _nTfL_
			if isString(_aTfC_[iTf])
				_aTfR_ + _aTfC_[iTf]
			ok
		next
		return _aTfR_

		def StringsZ()
			_aTfC_ = This.Content()
			_nTfL_ = ring_len(_aTfC_)
			_aTfR_ = []
			for iTf = 1 to _nTfL_
				if isString(_aTfC_[iTf])
					_aTfR_ + [ _aTfC_[iTf], iTf ]
				ok
			next
			return _aTfR_

		def NumberOfStrings()
			return ring_len(This.Strings())

	def Chars()
		_aTfC_ = This.Content()
		_nTfL_ = ring_len(_aTfC_)
		_aTfR_ = []
		for iTf = 1 to _nTfL_
			if isString(_aTfC_[iTf]) and StzLen(_aTfC_[iTf]) = 1
				_aTfR_ + _aTfC_[iTf]
			ok
		next
		return _aTfR_

		def CharsZ()
			_aTfC_ = This.Content()
			_nTfL_ = ring_len(_aTfC_)
			_aTfR_ = []
			for iTf = 1 to _nTfL_
				if isString(_aTfC_[iTf]) and StzLen(_aTfC_[iTf]) = 1
					_aTfR_ + [ _aTfC_[iTf], iTf ]
				ok
			next
			return _aTfR_

	def Letters()
		_aTfC_ = This.Content()
		_nTfL_ = ring_len(_aTfC_)
		_aTfR_ = []
		for iTf = 1 to _nTfL_
			_xTf = _aTfC_[iTf]
			if isString(_xTf) and ring_len(_xTf) = 1
				_nTfA = ascii(_xTf)
				if (_nTfA >= 97 and _nTfA <= 122) or (_nTfA >= 65 and _nTfA <= 90)
					_aTfR_ + _xTf
				ok
			ok
		next
		return _aTfR_

		def LettersZ()
			_aTfC_ = This.Content()
			_nTfL_ = ring_len(_aTfC_)
			_aTfR_ = []
			for iTf = 1 to _nTfL_
				_xTf = _aTfC_[iTf]
				if isString(_xTf) and ring_len(_xTf) = 1
					_nTfA = ascii(_xTf)
					if (_nTfA >= 97 and _nTfA <= 122) or (_nTfA >= 65 and _nTfA <= 90)
						_aTfR_ + [ _xTf, iTf ]
					ok
				ok
			next
			return _aTfR_

		def NumberOfLetters()
			return ring_len(This.Letters())

	def Lists()
		_aTfC_ = This.Content()
		_nTfL_ = ring_len(_aTfC_)
		_aTfR_ = []
		for iTf = 1 to _nTfL_
			if isList(_aTfC_[iTf])
				_aTfR_ + _aTfC_[iTf]
			ok
		next
		return _aTfR_

		def ListsZ()
			_aTfC_ = This.Content()
			_nTfL_ = ring_len(_aTfC_)
			_aTfR_ = []
			for iTf = 1 to _nTfL_
				if isList(_aTfC_[iTf])
					_aTfR_ + [ _aTfC_[iTf], iTf ]
				ok
			next
			return _aTfR_

		def NumberOfLists()
			return ring_len(This.Lists())

	def NumberOfPairs()
		return ring_len(This.Pairs())

	#-- Extend the list up to position n. ExtendToPosition pads with 0
	#-- (number lists) or "" ; the WithItemsIn/Repeated forms pad by
	#-- cycling through a given list (or the list's own items).

	def ExtendToPosition(_n_)
		_nLen_ = This.NumberOfItems()
		_aContent_ = This.Content()
		if _n_ > _nLen_
			value = ""
			if This.IsListOfNumbers()
				value = 0
			ok
			_nExtend_ = _n_ - _nLen_
			for _i_ = 1 to _nExtend_
				_aContent_ + value
			next
		ok
		This.UpdateWith(_aContent_)

	def ExtendToPositionWithItemsIn(_n_, paItems)
		_nLen_ = ring_len(paItems)
		# fill (target - CURRENT length) slots; cycle the pool (length nLen)
		_nTemp_ = _n_ - This.NumberOfItems()
		_aTemp_ = []
		if _nTemp_ > 0
			_j_ = 0
			for _i_ = 1 to _nTemp_
				_j_++
				if _j_ > _nLen_
					_j_ = 1
				ok
				_aTemp_ + paItems[_j_]
			next
		ok
		This.ExtendWith(_aTemp_)

		def ExtendToWithItemsIn(_n_, paItems)
			This.ExtendToPositionWithItemsIn(_n_, paItems)

	def ExtendToPositionWithItemsRepeated(_n_)
		This.ExtendToPositionWithItemsIn(_n_, This.List())

		def ExtendToWithItemsRepeated(_n_)
			This.ExtendToPositionWithItemsRepeated(_n_)

		def ExtendToByRepeatingItems(_n_)
			This.ExtendToPositionWithItemsRepeated(_n_)

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
		_aContent_ = This.Content()
		_nLen_ = ring_len(_aContent_)
		_bResult_ = 1
		for _i_ = 1 to _nLen_
			if NOT isList(_aContent_[_i_])
				_bResult_ = 0
				exit
			ok
			if NOT ring_len(_aContent_[_i_]) = 0
				_bResult_ = 0
				exit
			ok
		next
		return _bResult_

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
		_aDups_ = This.DuplicatedItemsCS(pCaseSensitive)
		_aRes_ = []
		_nLen_ = ring_len(_aDups_)
		for _i_ = 1 to _nLen_
			_aRes_ + This.FindFirstCS(_aDups_[_i_], pCaseSensitive)
		next
		return ring_sort(_aRes_)

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

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return []
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = [ _acStr_[1] ]
		_anPos_ = [ [] ]

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
				_anPos_ + [ _i_ ]
			else
				_anPos_[ _n_ ] + _i_
			ok
		next

		_aResult_ = []
		_nLen_ = len(_acSeen_)

		for _i_ = 1 to _nLen_
			if len(_anPos_[_i_]) > 1
				_aResult_ + _aContent_[_anPos_[_i_][1]]
			ok
		next

		return _aResult_

	def DuplicatesCSZ(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return []
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = [ _acStr_[1] ]
		_anPos_ = [ [] ]

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
				_anPos_ + [ _i_ ]
			else
				_anPos_[ _n_ ] + _i_
			ok
		next

		_aResult_ = []
		_nLen_ = len(_acSeen_)

		for _i_ = 1 to _nLen_
			del(_anPos_[_i_], 1)
			if len(_anPos_[_i_]) > 0
				_aResult_ + [ _aContent_[_anPos_[_i_][1]], _anPos_[_i_] ]
			ok
		next

		return _aResult_

	def DuplicatesCSXTZ(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return []
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = []
		_anSeen_ = []
		_anPos_ = []
		_aResult_ = []

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
				_anSeen_ + _i_
				_aResult_ + [ _aContent_[_i_], [_i_] ]
			else
				if StzFindFirst(_anPos_, _anSeen_[_n_]) = 0
					_anPos_ + _anSeen_[_n_]
				ok
				_anPos_ + _i_
				_aResult_[_n_][2] + _i_
			ok
		next

		return _aResult_

	def DuplicatesXTZ()
		return This.DuplicatesCSXTZ(1)

	def FindDuplicatesCS(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return []
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = []
		_anPos_ = []

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
			else
				_anPos_ + _i_
			ok
		next

		return _anPos_

	def FindDuplicatesCSXT(pCaseSensitive)

		if isList(pCaseSensitive) and IsCaseSensitiveNamedParamList(pCaseSensitive)
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT ( pCaseSensitive = 1 or pCaseSensitive = 0 )
			StzRaise("Incorrect param! pCaseSensitive must be a boolean (1 or 0).")
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return []
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = []
		_anSeen_ = []
		_anPos_ = []

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
				_anSeen_ + _i_
			else
				if StzFindFirst(_anPos_, _anSeen_[_n_]) = 0
					_anPos_ + _anSeen_[_n_]
				ok
				_anPos_ + _i_
			ok
		next

		_anPos_ = ring_sort(_anPos_)
		return _anPos_

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
		_anPos_ = This.FindDuplicatesCSXT(pCaseSensitive)
		_nLen_ = This.NumberOfItems()
		if NOT Q(_anPos_).IsEqualTo(1:nLen)
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

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return 0
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = []
		_acResult_ = []
		_anPos_ = []

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
				_acResult_ + _acStr_[_i_]
				_anPos_ + _i_
			else
				_nPos_ = StzFindFirst(_acResult_, _acStr_[_i_])
				if _nPos_ > 0
					ring_del(_acResult_, _nPos_)
					ring_del(_anPos_, _nPos_)
				ok
			ok
		next

		_aResult_ = []
		_nLen_ = len(_anPos_)
		for _i_ = 1 to _nLen_
			_aResult_ + _aContent_[_anPos_[_i_]]
		next

		return _aResult_

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

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		if _nLen_ = 0
			return 0
		ok

		_acStr_ = []

		if pCaseSensitive = 1
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + _cItem_
			next
		else
			for _i_ = 1 to _nLen_
				if isNumber(_aContent_[_i_])
					_cItem_ = "" + _aContent_[_i_]
				but isString(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isList(_aContent_[_i_])
					_cItem_ = @@(_aContent_[_i_])
				but isObject(_aContent_[_i_])
					_cItem_ = @ObjectVarName(_aContent_[_i_])
				ok
				_acStr_ + StzLower(_cItem_)
			next
		ok

		_acSeen_ = []
		_acResult_ = []
		_anResult_ = []

		for _i_ = 1 to _nLen_
			_n_ = StzFindFirst(_acSeen_, _acStr_[_i_])
			if _n_ = 0
				_acSeen_ + _acStr_[_i_]
				_acResult_ + _acStr_[_i_]
				_anResult_ + _i_
			else
				_nPos_ = StzFindFirst(_acResult_, _acStr_[_i_])
				if _nPos_ > 0
					ring_del(_acResult_, _nPos_)
					ring_del(_anResult_, _nPos_)
				ok
			ok
		next

		return _anResult_

	def FindNonDuplicatedItems()
		return This.FindNonDuplicatedItemsCS(1)

	def NonDuplicatedItemsAndTheirPositionsCS(pCaseSensitive)
		_aNonDuplicated_ = This.NonDuplicatedItemsCS(pCaseSensitive)
		_nLen_ = len(_aNonDuplicated_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			_nPos_ = This.FindFirstCS(_aNonDuplicated_[_i_], pCaseSensitive)
			_aResult_ + [ _aNonDuplicated_[_i_], _nPos_ ]
		next
		return _aResult_

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

		_aList_ = @aContent

		if pCaseSensitive = 0
			_aList_ = This.Lowercased()
		ok

		_nLenList_ = len(_aList_)

		if _nLenList_ = 0
			return []
		ok

		_acListStringified_ = []
		for _i_ = 1 to _nLenList_
			_acListStringified_ + @@(_aList_[_i_])
		next

		_aResult_ = []
		_acSeen_ = []
		for _i_ = 1 to _nLenList_
			if StzFindFirst(_acSeen_, _acListStringified_[_i_])
				loop
			ok

			_anPos_ = []
			for _j_ = 1 to _nLenList_
				if _acListStringified_[_i_] = _acListStringified_[_j_]
					_anPos_ + _j_
				ok
			next

			_aResult_ + [ _aList_[_i_], _anPos_ ]
			_acSeen_ + _acListStringified_[_i_]
		next

		return _aResult_

	def IndexCS(pCaseSensitive)
		return This.FindItemsCS(pCaseSensitive)

	#-- ITEMS OCCURRING N TIMES (case-sensitive dial)

	def ItemsOccurringNTimesCS(_n_, pCaseSensitive)
		_aIndex_ = This.IndexCS(pCaseSensitive)
		_nLen_ = len(_aIndex_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			if len(_aIndex_[_i_][2]) >= _n_
				_aResult_ + _aIndex_[_i_][1]
			ok
		next
		return _aResult_

	def ItemsOccuringNTimesCS(_n_, pCaseSensitive)
		return This.ItemsOccurringNTimesCS(_n_, pCaseSensitive)

	#-- N-LISTIFY (pad each item into an n-element sublist)

	def NListify(_n_)
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_aResult_ = []

		for _i_ = 1 to _nLen_
			_aList_ = []
			if NOT isList(_aContent_[_i_])
				_aList_ + _aContent_[_i_]
				if _n_ > 1
					for _j_ = 1 to _n_-1
						_aList_ + ""
					next
				ok
			else
				_nLenList_ = len(_aContent_[_i_])
				if _n_ = _nLenList_
					_aList_ = _aContent_[_i_]
				but _n_ > _nLenList_
					_aList_ = _aContent_[_i_]
					for _j_ = 1 to _n_ - _nLenList_
						_aList_ + ""
					next
				but _n_ < _nLenList_
					for _j_ = 1 to _n_
						_aList_ + _aContent_[_i_][_j_]
					next
				ok
			ok
			_aResult_ + _aList_
		next

		This.UpdateWith(_aResult_)

	def NListifyQ(_n_)
		This.NListify(_n_)
		return This

	def NListified(_n_)
		return This.Copy().NListifyQ(_n_).Content()

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
		_nPos_ = ceil(This.NumberOfItems() / 2)
		return This.Section(1, _nPos_)

	def SecondHalfXT()
		_nLen_ = This.NumberOfItems()
		_nPos_ = ceil(_nLen_ / 2) + 1
		return This.Section(_nPos_, _nLen_)

	def FirstHalfAndPosition()
		return [ This.FirstHalf(), 1 ]

	def FirstHalfAndSection()
		return [ This.FirstHalf(), [1, floor(This.NumberOfItems() / 2)] ]

	def FirstHalfAndPositionXT()
		return [ This.FirstHalfXT(), 1 ]

	def FirstHalfAndSectionXT()
		return [ This.FirstHalfXT(), [1, ceil(This.NumberOfItems() / 2)] ]

	def SecondHalfAndPosition()
		_nLen_ = This.NumberOfItems()
		_nPos_ = floor(_nLen_ / 2) + 1
		return [ This.SecondHalf(), _nPos_ ]

	def SecondHalfAndSection()
		_nLen_ = This.NumberOfItems()
		_nPos_ = floor(_nLen_ / 2) + 1
		return [ This.SecondHalf(), [ _nPos_, _nLen_ ] ]

	def SecondHalfAndPositionXT()
		_nLen_ = This.NumberOfItems()
		_nPos_ = ceil(_nLen_ / 2) + 1
		return [ This.SecondHalfXT(), _nPos_ ]

	def SecondHalfAndSectionXT()
		_nLen_ = This.NumberOfItems()
		_nPos_ = ceil(_nLen_ / 2) + 1
		return [ This.SecondHalfXT(), [ _nPos_, _nLen_ ] ]

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
		_acResult_ = []
		_acResult_ + This.FirstHalf() + This.SecondHalf()
		return _acResult_

	def HalvesXT()
		_acResult_ = []
		_acResult_ + This.FirstHalfXT() + This.SecondHalfXT()
		return _acResult_

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

	def ExtractAt(_n_)
		_TempItem_ = This.ItemAt(_n_)
		This.RemoveAt(_n_)
		return _TempItem_

	def ExtractFirstCS(pItem, pCaseSensitive)
		return This.ExtractNthOccurrenceCS(1, pItem, pCaseSensitive)

	def ExtractLastCS(pItem, pCaseSensitive)
		_nLast_ = This.NumberOfOccurrencesCS(pItem, pCaseSensitive)
		return This.ExtractNthOccurrenceCS(_nLast_, pItem, pCaseSensitive)


	def FindNextSTCS(pItem, _nStart_, pCaseSensitive)
		return This.FindNextOccurrenceCS(pItem, _nStart_, pCaseSensitive)

	def FindPreviousSTCS(pItem, pnStartingAt, pCaseSensitive)
		return This.FindPreviousOccurrenceCS(pItem, pnStartingAt, pCaseSensitive)

	def ExtractNextSTCS(pItem, pnStartingAt, pCaseSensitive)
		if isList(pnStartingAt) and IsStartingAtNamedParamList(pnStartingAt)
			pnStartingAt = pnStartingAt[2]
		ok
		_nPos_ = This.FindNextSTCS(pItem, pnStartingAt, pCaseSensitive)
		if _nPos_ = 0
			return
		ok
		This.RemoveItemAtPosition(_nPos_)
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
		_nPos_ = This.FindPreviousSTCS(pItem, pnStartingAt, pCaseSensitive)
		if _nPos_ = 0
			return
		ok
		This.RemoveItemAtPosition(_nPos_)
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

		_bEqualToList1_ = This.IsEqualToCS(paList1, pCaseSensitive)
		_bEqualToList2_ = This.IsEqualToCS(paList2, pCaseSensitive)

		if NOT _bEqualToList1_ and NOT _bEqualToList2_
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
		_aThis_ = This.Content()
		_n1_ = len(_aThis_)
		_n2_ = len(paOtherList)
		if _n1_ != _n2_
			return FALSE
		ok
		_ac1_ = []
		for _i_ = 1 to _n1_
			_ac1_ + StzLower("" + _aThis_[_i_])
		next
		_ac2_ = []
		for _i_ = 1 to _n2_
			_ac2_ + StzLower("" + paOtherList[_i_])
		next
		_ac1_ = ring_sort(_ac1_)
		_ac2_ = ring_sort(_ac2_)
		for _i_ = 1 to _n1_
			if NOT _ac1_[_i_] = _ac2_[_i_]
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
		_aC_ = This.Content()
		_n_ = len(_aC_)
		for _i_ = 1 to _n_
			if isList(_aC_[_i_])
				return _i_
			ok
		next
		return 0

	def FirstList()
		_nPos_ = This.FindFirstList()
		if _nPos_ = 0
			return []
		ok
		_aC_ = This.Content()
		return _aC_[_nPos_]

	#-- AllItemsAreEqualTo: every item equals pItem (content-compare, so
	#-- sublists match too).

	def AllItemsAreEqualToCS(pItem, pCaseSensitive)
		_aC_ = This.Content()
		_n_ = len(_aC_)
		if _n_ = 0
			return FALSE
		ok
		for _i_ = 1 to _n_
			if NOT BothAreEqualCS(_aC_[_i_], pItem, pCaseSensitive)
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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			if isNumber(_aContent_[_i_])
				_aResult_ + _i_
			ok
		next
		return _aResult_

	def FindNonNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			if NOT isNumber(_aContent_[_i_])
				_aResult_ + _i_
			ok
		next
		return _aResult_

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

		_aList_ = @aContent
		if pCaseSensitive = 0
			_aList_ = This.Lowercased()
		ok

		_nLenList_ = len(_aList_)
		if _nLenList_ = 0
			return []
		ok

		_aItems_ = This.WithoutDuplicationCS(pCaseSensitive)
		_nLenItems_ = len(_aItems_)

		_aResult_ = []
		for _i_ = 1 to _nLenItems_
			_n_ = 0
			for _j_ = 1 to _nLenList_
				if ring_type(_aItems_[_i_]) = ring_type(_aList_[_j_]) and
				   _aItems_[_i_] = _aList_[_j_]
					_n_++
				ok
			next
			_aResult_ + [ _aItems_[_i_], _n_ ]
		next

		return _aResult_

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
		_aC_ = This.Content()
		_n_ = len(_aC_)
		for _i_ = 1 to _n_
			_x_ = _aC_[_i_]
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

	def SplitToPartsOfNItemsXT(_n_)
		_aSections_ = StzSplitterQ(This.NumberOfItems()).SplitToPartsOfNItemsXT(_n_)
		This.UpdateWith( This.Sections(_aSections_) )

	def SplitToPartsOfNItemsXTQ(_n_)
		This.SplitToPartsOfNItemsXT(_n_)
		return This

	def SplittedToPartsOfNItemsXT(_n_)
		return This.Copy().SplitToPartsOfNItemsXTQ(_n_).Content()

	def SplitAfterPositions(panPos)
		_aSections_ = StzSplitterQ(This.NumberOfItems()).SplitAfterPositions(panPos)
		This.UpdateWith( This.Sections(_aSections_) )

	def SplitAfterPositionsQ(panPos)
		This.SplitAfterPositions(panPos)
		return This

	def SplittedAfterPositions(panPos)
		return This.Copy().SplitAfterPositionsQ(panPos).Content()

	def SplitBeforePositions(panPos)
		_aSections_ = StzSplitterQ(This.NumberOfItems()).SplitBeforePositions(panPos)
		This.UpdateWith( This.Sections(_aSections_) )

	def SplitBeforePositionsQ(panPos)
		This.SplitBeforePositions(panPos)
		return This

	def SplittedBeforePositions(panPos)
		return This.Copy().SplitBeforePositionsQ(panPos).Content()

	#-- Nth previous occurrence (scanning backward from a start position).

	def FindNthPreviousOccurrenceCS(_n_, pItem, _nStart_, pCaseSensitive)
		if isList(pItem) and IsOfNamedParamList(pItem)
			pItem = pItem[2]
		ok
		if isList(_nStart_) and IsStartingAtNamedParamList(_nStart_)
			_nStart_ = _nStart_[2]
		ok
		if isString(_nStart_) and ( _nStart_ = :Last or _nStart_ = :LastItem )
			_nStart_ = This.NumberOfItems()
		ok
		if isString(_n_)
			if _n_ = :First or _n_ = :FirstOccurrence
				_n_ = 1
			but _n_ = :Last or _n_ = :LastOccurrence
				_n_ = This.SectionQ(1, _nStart_).NumberOfOccurrenceCS(pItem, pCaseSensitive)
			ok
		ok

		_nLen_ = This.NumberOfItems()

		if _nStart_ = 1
			return 0
		ok
		if _nStart_ < 0 or _nStart_ > _nLen_
			return 0
		ok
		if NOT This.ContainsCS(pItem, pCaseSensitive)
			return 0
		ok
		if This.SectionQ(1, _nStart_ - 1).NumberOfOccurrenceCS(pItem, pCaseSensitive) < _n_
			return 0
		ok

		_bCase_ = CaseSensitive(pCaseSensitive)
		# Current FindPreviousCS is exclusive (strictly before nPos), so we
		# seed nPos with nStart itself to count the occurrence at nStart-1.
		_nPos_ = _nStart_
		_nFound_ = 0
		_i_ = 0

		while 1
			_i_++
			if _i_ > _nLen_
				exit
			ok
			_nPos_ = This.FindPreviousCS(pItem, _nPos_, _bCase_)
			if _nPos_ = 0
				exit
			else
				_nFound_++
				if _nFound_ = _n_
					return _nPos_
				ok
			ok
		end

		return 0

	def FindNthPreviousOccurrence(_n_, pItem, _nStart_)
		return This.FindNthPreviousOccurrenceCS(_n_, pItem, _nStart_, 1)

	def PreviousNthOccurrenceCS(_n_, pItem, _nStart_, pCaseSensitive)
		return This.FindNthPreviousOccurrenceCS(_n_, pItem, _nStart_, pCaseSensitive)

	def PreviousNthOccurrence(_n_, pItem, _nStart_)
		return This.FindNthPreviousOccurrence(_n_, pItem, _nStart_)

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
				_aResult_ = []
			but p = 1
				_aResult_ = @aContent
			else
				_aResult_ = []
				for _i_ = 1 to p
					_aResult_ + @aContent
				next
			ok
			This.Update( _aResult_ )

		on "STRING"
			_nLen_ = len(@aContent)
			for _i_ = 1 to _nLen_
				if isString(@aContent[_i_])
					@aContent[_i_] += p
				ok
			next

		on "LIST"
			# Pair each item with the given list:
			# [ "V1","V2" ] * [ 1,2 ] -> [ [ "V1",[1,2] ], [ "V2",[1,2] ] ]
			_nLen_ = len(@aContent)
			for _i_ = 1 to _nLen_
				item = @aContent[_i_]
				This._InvalidateEngine()   # in-place @aContent mutation below
				@aContent[_i_] = [ item, p ]
			next

		other
			StzRaise("Can't multiply the list by an object!")
		off

	def ExtendToXT(_n_, pValue)
		This.ExtendToPositionWith(_n_, pValue)

	def TypesXT()
		return This.ListQ().AssociatedWith( This.Types() )

	def FindStzNumbers()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_anResult_ = []
		for _i_ = 1 to _nLen_
			if @IsStzNumber(_aContent_[_i_])
				_anResult_ + _i_
			ok
		next
		return _anResult_

	def ReplaceThisAt(_n_, pItem, pNewItem)
		This.ReplaceThisItemAt(_n_, pItem, pNewItem)

	def ReplaceAnyAt(pPos, pNewItem)
		This.ReplaceAt(pPos, pNewItem)

	#-- Positions of items that are stz objects of a given kind.

	def FindStzStrings()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_anResult_ = []
		for _i_ = 1 to _nLen_
			if @IsStzString(_aContent_[_i_])
				_anResult_ + _i_
			ok
		next
		return _anResult_

	def FindStzLists()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_anResult_ = []
		for _i_ = 1 to _nLen_
			if @IsStzList(_aContent_[_i_])
				_anResult_ + _i_
			ok
		next
		return _anResult_

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
		_StzHistoOpen(This.Content())
		This.UpdateWith( This.Uppercased() )
		_StzHistoAdd(This.Content())
		return This

		def LowercaseQ()
			_StzHistoOpen(This.Content())
			This.UpdateWith( This.Lowercased() )
			_StzHistoAdd(This.Content())
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
			_aResult_ = StzEngineListContentToRingList(_pDic_)
			StzEngineListFree(_pDic_)
			StzEngineListFree(_pAic_)
			StzEngineListFree(_pBic_)
			return _aResult_
		ok
		# Fallback (non-marshalable content, e.g. objects)
		_aResult_ = []
		_nLen_ = len(paOtherList)
		for _i_ = 1 to _nLen_
			if NOT This.ContainsCS(paOtherList[_i_], pCaseSensitive)
				_aResult_ + paOtherList[_i_]
			ok
		next
		return _aResult_

	def RemovedItemsComparedToCS(paOtherList, pCaseSensitive)
		if NOT isList(paOtherList)
			StzRaise("Incorrect param type! paOtherList must be a list.")
		ok
		# Removed = items here absent from the OTHER list = this \ other.
		_pAric_ = This._EngineListFromContent()
		_pBric_ = StzEngineMarshalList(paOtherList)
		if _pAric_ != NULL and _pBric_ != NULL
			_pDric_ = StzEngineListDifferenceCS(_pAric_, _pBric_, pCaseSensitive)
			_aResult_ = StzEngineListContentToRingList(_pDric_)
			StzEngineListFree(_pDric_)
			StzEngineListFree(_pAric_)
			StzEngineListFree(_pBric_)
			return _aResult_
		ok
		# Fallback (non-marshalable content)
		_aResult_ = []
		_oOtherList_ = new stzList(paOtherList)
		_nLen_ = This.NumberOfItems()
		_aContent_ = This.Content()
		for _i_ = 1 to _nLen_
			if NOT _oOtherList_.ContainsCS(_aContent_[_i_], pCaseSensitive)
				_aResult_ + _aContent_[_i_]
			ok
		next
		return _aResult_

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
			_aResult_ = StzEngineListContentToRingList(_pMmi_)
			StzEngineListFree(_pMmi_)
			StzEngineListFree(_pAmi_)
			StzEngineListFree(_pBmi_)
			return _aResult_
		ok

		# Fallback (non-marshalable content): same semantics in Ring.
		_aResult_ = []
		_aThisListU_ = @UniqueCS(This.Content(), pCaseSensitive)
		_aoThisListU_ = @Objectify(_aThisListU_)
		_aFiltered = []
		for _k = 1 to len(paOtherList)
			_bInThis = 0
			for _j = 1 to len(_aThisListU_)
				if BothAreEqualCS(paOtherList[_k], _aThisListU_[_j], pCaseSensitive)
					_bInThis = 1
					exit
				ok
			next
			if _bInThis = 0
				_aFiltered + paOtherList[_k]
			ok
		next
		_aOtherListU_ = @UniqueCS(_aFiltered, pCaseSensitive)
		_aoOtherListU_ = @Objectify(_aOtherListU_)
		_nLenThis_ = len(_aThisListU_)
		_nLenOther_ = len(_aOtherListU_)
		for _i_ = 1 to _nLenThis_
			if isString(_aThisListU_[_i_])
				for _j_ = 1 to _nLenOther_
					if isString(_aOtherListU_[_j_])
						if _aoThisListU_[_i_].ContainsCS(_aOtherListU_[_j_], pCaseSensitive) or
						   _aoOtherListU_[_j_].ContainsCS(_aThisListU_[_i_], pCaseSensitive)
							_aResult_ + [ _aThisListU_[_i_], _aOtherListU_[_j_] ]
						ok
					ok
				next
			but isList(_aThisListU_[_i_])
				for _j_ = 1 to _nLenOther_
					if isList(_aOtherListU_[_j_])
						if _aoThisListU_[_i_].ContainsOneOfTheseCS(_aOtherListU_[_j_], pCaseSensitive) or
						   _aoOtherListU_[_j_].ContainsOneOfTheseCS(_aThisListU_[_i_], pCaseSensitive)
							_aResult_ + [ _aThisListU_[_i_], _aOtherListU_[_j_] ]
						ok
					ok
				next
			ok
		next
		return _aResult_

	def DifferentItemsWithCSXTT(paOtherList, pCaseSensitive)
		_aAddedItems_ = This.AddedItemsComparedToCS(paOtherList, pCaseSensitive)
		_aRemovedItems_ = This.RemovedItemsComparedToCS(paOtherList, pCaseSensitive)
		_aModifiedItems_ = This.ModifiedItemsComparedToCSXT(paOtherList, pCaseSensitive)
		_nLen_ = len(_aModifiedItems_)

		_oAdded_ = new stzList(_aAddedItems_)
		_oRemoved_ = new stzList(_aRemovedItems_)

		for _i_ = 1 to _nLen_
			_oRemoved_.Remove(_aModifiedItems_[_i_][1])
			_oAdded_.RemoveAll(_aModifiedItems_[_i_][2])
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
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)
		_aResult_ = []
		for _i_ = 1 to _nLen_
			_aResult_ + Q(_aContent_[_i_])
		next
		This.UpdateWith(_aResult_)

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
		_nDif_ = abs(This.NumberOfItems() - len(paOtherList))
		_n_ = _nDif_ / This.NumberOfItems()
		if _n_ < QuietEqualityRatio()
			return 1
		ok
		return 0

	#-- Deep "contains" combinators. The heavy work is DeepContainsCS
	#-- (engine-backed: stringify the whole list + StzFind). These just
	#-- loop over the small QUERY list, not the data -- so no data-loop.

	def DeepContainsManyCS(paItems, pCaseSensitive)
		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			if NOT This.DeepContainsCS(paItems[_i_], pCaseSensitive)
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
		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			if This.DeepContainsCS(paItems[_i_], pCaseSensitive)
				return 1
			ok
		next
		return 0

	def DeepContainsOneOfThese(paItems)
		return This.DeepContainsOneOfTheseCS(paItems, 1)

	def DeepContainsNOfTheseCS(_n_, paItems, pCaseSensitive)
		_v_ = 0
		_nLen_ = len(paItems)
		for _i_ = 1 to _nLen_
			if This.DeepContainsCS(paItems[_i_], pCaseSensitive)
				_v_++
				if _v_ = _n_
					return 1
				ok
			ok
		next
		return 0

	def DeepContainsNOfThese(_n_, paItems)
		return This.DeepContainsNOfTheseCS(_n_, paItems, 1)

	#========================================================#
	#  Locale-shaped list predicates (i18n). Thin orchestra- #
	#  tion over the established per-string locale lookups.   #
	#========================================================#

	def ToListOfStzStrings()
		if NOT This.IsListOfStrings()
			StzRaise("Can't proceed! All items must be strings.")
		ok
		_acContent_ = This.Content()
		_nLen_ = len(_acContent_)
		_aoResult_ = []
		for _i_ = 1 to _nLen_
			_aoResult_ + new stzString(_acContent_[_i_])
		next
		return _aoResult_

	def AreLanguageAbbreviations()
		if NOT @IsListOfStrings(@aContent)
			return 0
		ok
		_nLen_ = len(@aContent)
		_aoStzStr_ = This.ToListOfStzStrings()
		for _i_ = 1 to _nLen_
			if NOT _aoStzStr_[_i_].IsLanguageAbbreviation()
				return 0
			ok
		next
		return 1

	def IsLocaleList()
		_nLen_ = len(@aContent)

		if _nLen_ = 1 and isString(@aContent[1]) and
		   StzFindFirst([ :Default, :DefaultLocale, :System, :SystemLocale, "c", "C", :CLocale ], @aContent[1]) > 0
			return 1
		ok

		if _nLen_ > 3
			return 0
		ok
		if NOT This.IsHashList()
			return 0
		ok

		_acKeys_ = []
		for _i_ = 1 to _nLen_
			_acKeys_ + @aContent[_i_][1]
		next
		_bLanguage_ = StzFindFirst(_acKeys_, "language")
		_bScript_ = StzFindFirst(_acKeys_, "script")
		_bCountry_ = StzFindFirst(_acKeys_, "country")
		if _bLanguage_ = 0 and _bScript_ = 0 and _bCountry_ = 0
			return 0
		ok

		_cLanguage_ = @aContent[ :Language ]
		_cScript_   = @aContent[ :Script   ]
		_cCountry_  = @aContent[ :Country  ]
		if NOT ( isString(_cLanguage_) and isString(_cScript_) and isString(_cCountry_) )
			return 0
		ok
		if _cLanguage_ = "" and _cScript_ = "" and _cCountry_ = ""
			return 0
		ok
		if _cLanguage_ != "" and NOT StzStringQ(_cLanguage_).IsLanguageIdentifier()
			return 0
		ok
		if _cScript_ != "" and NOT StzStringQ(_cScript_).IsScriptIdentifier()
			return 0
		ok
		if _cCountry_ != "" and NOT StzStringQ(_cCountry_).IsCountryIdentifier()
			return 0
		ok
		return 1

	def IsMultilingualString()
		if NOT This.IsHashlist()
			return 0
		ok
		_nLen_ = len(@aContent)
		for _i_ = 1 to _nLen_
			if NOT isString(@aContent[_i_][2])
				return 0
			ok
		next
		_aoKeys_ = []
		for _i_ = 1 to _nLen_
			_aoKeys_ + StzStringQ(@aContent[_i_][1])
		next
		for _i_ = 1 to _nLen_
			if NOT _aoKeys_[_i_].IsLanguageNameOrAbbreviation()
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
		_nLen_ = This.NumberOfItems()
		_anPos_ = _nLen_ : 1
		for _i_ = 2 to _nLen_
			_anPos_ + _i_
		next
		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)
		but pReturn = :WalkedPositions
			return _anPos_
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]
		else
			return _anPos_
		ok

	#-- N-step (every nth item)

	def WalkNItemsForwardXT(_n_, pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		_anPos_ = []
		_nLen_ = This.NumberOfItems()
		for _i_ = 1 to _nLen_ step _n_
			_anPos_ + _i_
		next
		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)
		but pReturn = :WalkedPositions
			return _anPos_
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]
		else
			return _anPos_
		ok

	def WalkNItemsBackwardXT(_n_, pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		_anPos_ = []
		for _i_ = This.NumberOfItems() to 1 step -_n_
			_anPos_ + _i_
		next
		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)
		but pReturn = :WalkedPositions
			return _anPos_
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]
		else
			return _anPos_
		ok

	def WalkNForwardXT(_n_, pReturn)
		return This.WalkNItemsForwardXT(_n_, pReturn)

	def WalkNBackwardXT(_n_, pReturn)
		return This.WalkNItemsBackwardXT(_n_, pReturn)

	#-- Progressive N-step (gap grows by n each step)

	def WalkNProgressiveItemsForwardXT(_n_, pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		_nLen_ = This.NumberOfItems()
		_anPos_ = []
		if _n_ < 0
			StzRaise("Can't proceed. n must be positive!")
		but _n_ = 0
			_anPos_ = [1]
		else
			_anPos_ = [1]
			_nStep_ = 1
			_i_ = 0
			while _nStep_ <= _nLen_
				_i_++
				_nStep_ += (_n_ * _i_)
				if _nStep_ <= _nLen_
					_anPos_ + _nStep_
				ok
			end
		ok
		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)
		but pReturn = :WalkedPositions
			return _anPos_
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]
		else
			return _anPos_
		ok

	def WalkNProgressiveItemsBackwardXT(_n_, pReturn)
		if isList(pReturn) and IsOneOfTheseNamedParamsList(pReturn, [ :Return, :AndReturn ])
			pReturn = pReturn[2]
		ok
		_nLen_ = This.NumberOfItems()
		_anPos_ = []
		if _n_ < 0
			StzRaise("Can't proceed. n must be positive!")
		but _n_ = 0
			_anPos_ = [ _nLen_ ]
		else
			_anPos_ = [ _nLen_ ]
			_nStep_ = _nLen_
			_i_ = 0
			while _nStep_ > 0
				_i_++
				_nStep_ -= (_n_ * _i_)
				if _nStep_ > 0
					_anPos_ + _nStep_
				ok
			end
		ok
		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)
		but pReturn = :WalkedPositions
			return _anPos_
		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))
		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]
		else
			return _anPos_
		ok

	def WalkNProgressiveItemsForward(_n_)
		return This.WalkNProgressiveItemsForwardXT(_n_, :Return = :WalkedPositions)

	def WalkNProgressiveItemsBackward(_n_)
		return This.WalkNProgressiveItemsBackwardXT(_n_, :Return = :WalkedPositions)

	def WalkNMoreForward(_n_)
		return This.WalkNProgressiveItemsForward(_n_)

	def WalkNMoreForwardXT(_n_, pReturn)
		return This.WalkNProgressiveItemsForwardXT(_n_, pReturn)

	def WalkNMoreBackward(_n_)
		return This.WalkNProgressiveItemsBackward(_n_)

	def WalkNMoreBackwardXT(_n_, pReturn)
		return This.WalkNProgressiveItemsBackwardXT(_n_, pReturn)

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

		_aList_ = This.List()
		_nLen_ = len(_aList_)

		if pnForward = pnBackward
			return []
		ok

		if pnBackward > pnForward
			_nStart_ = pnBackward - pnForward + 1
		else
			_nStart_ = 1
		ok

		_i_ = _nStart_
		_anPos_ = [ _i_ ]

		while (_i_ + pnForward) >= 1 and (_i_ + pnForward) <= _nLen_ and
		      (_i_ + pnForward - pnBackward) >= 1 and (_i_ + pnForward - pnBackward) <= _nLen_

			_i_ = _i_ + pnForward
			_anPos_ + _i_

			_i_ = _i_ - pnBackward
			_anPos_ + _i_

		end

		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)

		but pReturn = :WalkedPositions
			return _anPos_

		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))

		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]

		else
			return _anPos_
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

		_aList_ = This.List()
		_nLen_ = len(_aList_)

		if pnForward = pnBackward
			return []
		ok

		if pnForward > pnBackward
			_nStart_ = _nLen_ - pnBackward
		else
			_nStart_ = _nLen_
		ok

		_i_ = _nStart_
		_anPos_ = [ _nStart_ ]

		while ( (_i_ - pnBackward) >= 1 and (_i_ - pnBackward) <= _nLen_ ) and
		      ( (_i_ - pnBackward + pnForward) >= 1 and (_i_ - pnBackward + pnForward) <= _nLen_ )

			_i_ = _i_ - pnBackward
			_anPos_ + _i_

			_i_ = _i_ + pnForward
			_anPos_ + _i_

		end

		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)

		but pReturn = :WalkedPositions
			return _anPos_

		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))

		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]

		else
			return _anPos_
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

		_aList_ = This.List()
		_nLen_ = len(_aList_)

		_anPos_ = [ 1 ]

		for _i_ = 1 to _nLen_
			_nPosFromStart_ = _i_ + pnFromStart
			_nPosFromEnd_   = _nLen_ - _i_ - pnFromEnd + 1

			if _nPosFromEnd_ >= _nPosFromStart_
				_anPos_ + _nPosFromStart_
				if _nPosFromEnd_ != _nPosFromStart_
					_anPos_ + _nPosFromEnd_
				ok
			ok
		next

		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)

		but pReturn = :WalkedPositions
			return _anPos_

		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))

		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]

		else
			return _anPos_
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

		_aList_ = This.List()
		_nLen_ = len(_aList_)

		_anPos_ = [ _nLen_ ]

		for _i_ = _nLen_ to 1 step -1

			_nPosFromEnd_   = _i_ - pnFromEnd
			_nPosFromStart_ = _nLen_ - _i_ + 1

			if _nPosFromEnd_ >= _nPosFromStart_
				_anPos_ + _nPosFromEnd_
				
				if _nPosFromStart_ != _nPosFromEnd_
					_anPos_ + _nPosFromStart_
				ok
			ok
		next

		if pReturn = :WalkedItems
			return This.ItemsAt(_anPos_)

		but pReturn = :WalkedPositions
			return _anPos_

		but pReturn = :LastItem or pReturn = :LastWalkedItem
			return This.ItemAt(len(_anPos_))

		but pReturn = :LastPosition or pReturn = :LastWalkedPosition
			return _anPos_[len(_anPos_)]

		else
			return _anPos_
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


