/*
	NOTE:

	Semantically speaking:

	LIST	-->	Item
	SET	-->	Element
	STRING	-->	Char

*/

func StzSetQ(paList)
	return new stzSet(paList)

func IsSet(paList)
	if CheckParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	nLen = len(paList)
	if nLen = 0
		return FALSE
	but nLen = 1
		return TRUE
	ok

	bResult = TRUE
	aSeen = []
	for i = 1 to nLen
		if find(aSeen, paList[i]) = 0
			aSeen + paList[i]
		else
			bResult = FALSE
			exit
		ok
	next

	return bResult

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

		oTempList = new stzList(paList)
		@aContent = oTempList.ToSet()	# From StzList		

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
		if isList(paOtherSet) and Q(paOtherSet).IsWithOrByOrUsingNamedParam()
			paOtherSet = paOtherSet[2]
		ok

		If NOT @IsSet(paOtherSet)
			StzRaise(stzSetError(:CanNotUpdateSetWithNonSet))
		ok

		@aContent = paOtherSet

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
			@aContent + pElm
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

		aUnion = this.Content()
		for item in paOtherSet
			if not ItemExists(item,aUnion) # -> ListContains(aUnion, item)
				aUnion + item
			ok
		next
		return aUnion

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
		#TODO: Add "These" as alternative of "Many"

		if NOT @IsListOfSets(paListOfSets)
			StzRaise(stzSetError(:CanNotComputeUnionWithNonSets))
		ok

		aUnion = this.Content()
		oTempSet = this
		for lst in paListOfLists
			for item in lst
				if not ItemExists(item,aUnion)
					aUnion + item
				ok
			end
		next

		return aUnion

		def UnionWithManyQ(paListOfSets)
			return new stzSet( This.UnionWithMany(paListOfSets))
	
	def UnifyWithMany(paListOfSets)
		#TODO: Add "These" as alternative of "Many"

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
			oTempSet = new stzSet(paOtherSet)
			paOtherSet = oTempSet.Content()
		ok

		aIntersection = []
		// NB: For sets, I prefer using elem (element) as an iterator
		// rather than item which is preserved to lists.
		for elem in this.Content()	
			if ItemExists(elem, paOtherSet)
				aIntersection + elem
			ok
		next
		return aIntersection

	  #----------------------------------------#
	 #    INTERSECTION WITH MANY OTHER SETS   #
	#----------------------------------------#

	def IntersectionWithMany(paListOfSets)
		// TODO

	  #-------------------------------------------#
	 #    INCLUSION OF THE SET IN AN OTHER SET   #
	#-------------------------------------------#

	def IsIncludedIn(paOtherSet)
		// If necessary, transform the provided list to a set
		if NOT @IsSet(paOtherSet)
			oTempSet = new stzList(paOtherSet)
			paOtherSet = oTempSet.ToSet()
		ok

		bResult = TRUE
		for elem in This.Set()
			if NOT ListExists(elem, paOtherSet)
				bResult = FALSE
				exit
			ok
		end
		return bResult

	  #-------------------------------------------#
	 #    INCLUSION OF AN OTHER SET IN THE SET   #
	#-------------------------------------------#

	def Includes(paOtherSet)
		// If necessary, transform the provided list to a set
		if NOT @IsSet(paOtherSet)
			oTempSet = new stzSet(paOtherSet)
			paOtherSet = oTempSet.Content()
		ok

		bResult = TRUE
		for elem in paOtherSet
			if NOT This.ToStzList().Contains(elem)
				bResult = FALSE
				exit
			ok
		end
		return bResult

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
