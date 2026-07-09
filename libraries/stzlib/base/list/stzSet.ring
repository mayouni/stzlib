/*
	NOTE:

	Semantically speaking:

	_LIST_	-->	_item_
	SET	-->	Element
	_STRING_	-->	Char

*/

func StzSetQ(paList)
	return new stzSet(paList)

func IsSet(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	_nLen_ = len(paList)
	if _nLen_ = 0
		return 0
	but _nLen_ = 1
		return 1
	ok

	# Engine-backed: check if all elements are unique
	pList = StzEngineMarshalList(paList)
	_nResult_ = StzEngineListAllUniqueCS(pList, 1)
	StzEngineListFree(pList)
	return _nResult_

	#< @FunctionAlternativeForms

	func @IsSet(paList)
		return IsSet(paList)

	#--

	func IsASet(paList)
		return IsSet(paList)

	func @IsASet(paList)
		return IsSet(paList)

	#>

class stzSet from stzList
	@aContent = []

	  #-----------#
	 #    INIT   #
	#-----------#

	def init(paList)

		if NOT isList(paList)
			StzRaise(stzSetError(:CanNotCreateSet))
		ok

		# Engine-backed deduplication
		pList = StzEngineMarshalList(paList)
		pUnique = StzEngineListUniqueCS(pList, 1)
		@aContent = StzEngineListContentToRingList(pUnique)
		StzEngineListFree(pUnique)
		StzEngineListFree(pList)

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	  #-------------#
	 #   GENERAL   #
	#-------------#

	def Content()
		return @aContent

		def Value()
			return Content()

	def Set()
		return @aContent

	def ToStzList()
		return new stzList( This.Set() )

	#--

	def Update(paOtherSet)
		if CheckingParams()
			if isList(paOtherSet) and IsWithOrByOrUsingNamedParamList(paOtherSet)
				paOtherSet = paOtherSet[2]
			ok
	
			If NOT @IsSet(paOtherSet)
				StzRaise(stzSetError(:CanNotUpdateSetWithNonSet))
			ok
		ok

		@aContent = paOtherSet

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		#< @FunctionFluentForm

		def UpdateQ(paOtherSet)
			This.Update(paOtherSet)
			return This

		#>

		#< @FunctionAlternativeForms

		def UpdateWith(paOtherSet)
			This.Update(paOtherSet)

			def UpdateWithQ(paOtherSet)
				return This.UpdateQ(paOtherSet)
	
		def UpdateBy(paOtherSet)
			This.Update(paOtherSet)

			def UpdateByQ(paOtherSet)
				return This.UpdateQ(paOtherSet)

		def UpdateUsing(paOtherSet)
			This.Update(paOtherSet)

			def UpdateUsingQ(paOtherSet)
				return This.UpdateQ(paOtherSet)

		#>

	def Updated(paOtherSet)
		return paOtherSet

		#< @FunctionAlternativeForms

		def UpdatedWith(paOtherSet)
			return This.Updated(paOtherSet)

		def UpdatedBy(paOtherSet)
			return This.Updated(paOtherSet)

		def UpdatedUsing(paOtherSet)
			return This.Updated(paOtherSet)

		#>

	  #----------------------------------#
	 #   ADDING AN ELEMENT TO THE SET   #
	#----------------------------------#

	def AddElement(pElm)
		if not This.Contains(pElm)	# From StzList
			_aContent_ = This.Content()
			_aContent_ + pElm
			This.UpdateWith(_aContent_)
		ok

	def AddElementQ(pElm)
		This.AddElement(pElm)
		return This

	  #---------------------------------------#
	 #    NTH ELEMENT & NUMBER OF ELEMENTS   #
	#---------------------------------------#

	def NumberOfElements()
		return len( This.Set() )

	def Element(i)
		return This.Set()[i]

	  #---------------------------#
	 #    UNION WITH OTHER SET   #
	#---------------------------#

	def UnionWith(paOtherSet)
		// If necessary, transform the provided list to a set
		if NOT @IsSet(paOtherSet)
			StzRaise(stzSetError(:CanNotComputeUnionWithNoSet))
		ok

		# Engine-backed O(n log n) union
		pListA = StzEngineMarshalList(This.Content())
		pListB = StzEngineMarshalList(paOtherSet)
		pResult = StzEngineListUnionCS(pListA, pListB, 1)
		_aUnion_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pListB)
		StzEngineListFree(pListA)
		return _aUnion_

	def UnionWithQ(paOtherSet)
		return new stzSet( This.UnionWith(paOtherSet) )

	def UnifyWith(paOtherSet)
		This.Update( This.UnionWith(paOtherSet) )

	def UnifyWithQ(paOtherSet)
		This.UnifyWith(paOtherSet)
		return This
	
	  #---------------------------------#
	 #    UNION WITH MANY OTHER SETS   #
	#---------------------------------#

	def UnionWithMany(paListOfSets)
		#TODO // Add "These" as alternative of "Many"

		if NOT @IsListOfSets(paListOfSets)
			StzRaise(stzSetError(:CanNotComputeUnionWithNonSets))
		ok

		_aUnion_ = this.Content()
		_oTempSet_ = this
		_nListOfLists1Len_ = len(paListOfLists)
		for _iLoopListOfLists1_ = 1 to _nListOfLists1Len_
			_lst_ = paListOfLists[_iLoopListOfLists1_]
			_nLst1Len_ = len(_lst_)
			for _iLoopLst1_ = 1 to _nLst1Len_
				_item_ = _lst_[_iLoopLst1_]
				if not ItemExists(_item_,_aUnion_)
					_aUnion_ + _item_
				ok
			end
		next

		return _aUnion_

		def UnionWithManyQ(paListOfSets)
			return new stzSet( This.UnionWithMany(paListOfSets))
	
	def UnifyWithMany(paListOfSets)
		#TODO // Add "These" as alternative of "Many"

		This.Update( This.UnionWithMany(paListOfSets) )

		def UnifyWithManyQ(paListOfSets)
			This.UnifyWithMany(paListOfSets)
			return This

	  #----------------------------------#
	 #    INTERSECTION WITH OTHER SET   #
	#----------------------------------#

	def IntersectionWith(paOtherSet)
		// If necessary, transform the provided list to a set
		if NOT @IsSet(paOtherSet)
			_oTempSet_ = new stzSet(paOtherSet)
			paOtherSet = _oTempSet_.Content()
		ok

		# Engine-backed O(n log n) intersection
		pListA = StzEngineMarshalList(This.Content())
		pListB = StzEngineMarshalList(paOtherSet)
		pResult = StzEngineListIntersectionCS(pListA, pListB, 1)
		_aIntersection_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pListB)
		StzEngineListFree(pListA)
		return _aIntersection_

	  #----------------------------------------#
	 #    INTERSECTION WITH MANY OTHER SETS   #
	#----------------------------------------#

	def IntersectionWithMany(paListOfSets)
		// TODO

	  #-----------------------------------#
	 #    DIFFERENCE WITH OTHER SET     #
	#-----------------------------------#

	def DifferenceWith(paOtherSet)
		if NOT @IsSet(paOtherSet)
			_oTempSet_ = new stzSet(paOtherSet)
			paOtherSet = _oTempSet_.Content()
		ok

		# Engine-backed O(n log n) difference
		pListA = StzEngineMarshalList(This.Content())
		pListB = StzEngineMarshalList(paOtherSet)
		pResult = StzEngineListDifferenceCS(pListA, pListB, 1)
		_aDiff_ = StzEngineListContentToRingList(pResult)
		StzEngineListFree(pResult)
		StzEngineListFree(pListB)
		StzEngineListFree(pListA)
		return _aDiff_

	def DifferenceWithQ(paOtherSet)
		return new stzSet( This.DifferenceWith(paOtherSet) )

	  #-------------------------------------------#
	 #    INCLUSION OF THE SET IN AN OTHER SET   #
	#-------------------------------------------#

	def IsIncludedIn(paOtherSet)
		// If necessary, transform the provided list to a set
		if NOT @IsSet(paOtherSet)
			_oTempSet_ = new stzList(paOtherSet)
			paOtherSet = _oTempSet_.ToSet()
		ok

		# A is included in B iff A-B is empty (engine-backed)
		_aDiff_ = This.DifferenceWith(paOtherSet)
		return len(_aDiff_) = 0

	  #-------------------------------------------#
	 #    INCLUSION OF AN OTHER SET IN THE SET   #
	#-------------------------------------------#

	def Includes(paOtherSet)
		// If necessary, transform the provided list to a set
		if NOT @IsSet(paOtherSet)
			_oTempSet_ = new stzSet(paOtherSet)
			paOtherSet = _oTempSet_.Content()
		ok

		# B is included in A iff B-A is empty (engine-backed)
		_oOtherSet_ = new stzSet(paOtherSet)
		_aDiff_ = _oOtherSet_.DifferenceWith(This.Content())
		return len(_aDiff_) = 0

	def Contains(paOtherSet)
		return This.Includes(paOtherSet)

	  #-------------------------#
	 #    SUBSETS OF THE SET   #
	#-------------------------#

	def Subsets()
		// TODO

	def SubSetsOfNElements(n)
		// TODO

	def NumberOfSubsets()
		return len( This.Subsets() )
