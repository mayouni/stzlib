/*
	NOTE:

	Semantically speaking:

	LIST	-->	Item
	SET	-->	Element
	STRING	-->	Char

*/

func StzSetQ(paList)
	return new stzSet(paList)

class stzSet from stzList
	@aContent = []

	  #-----------#
	 #    INIT   #
	#-----------#

	def init(paList)

		if NOT isList(paList)
			stzRaise(stzSetError(:CanNotCreateSet))
		ok

		oTempList = new stzList(paList)
		@aContent = oTempList.ToSet()	# From StzList		

	  #-------------#
	 #   GENERAL   #
	#-------------#

	def Content()
		return @aContent

	def Set()
		return @aContent

	def ToStzList()
		return new stzList( This.Set() )

	def Update(paOtherSet)
		if isList(paOtherSet) and
		   ( StzListQ(paOtherSet).IsWithNamedParam() or StzListQ(paOtherSet).IsUsingNamedParam() )

			paOtherSet = paOtherSet[2]

		ok

		If NOT ListIsSet(paOtherSet)
			stzRaise(stzSetError(:CanNotUpdateSetWithNonSet))
		ok

		@aContent = paOtherSet

		#< @FunctionAlternativeForms

		def UpdateWith(paOtherSet)
			This.Update(paOtherSet)

		#>

	def UpdateQ(paOtherSet)
		This.Update(paOtherSet)
		return This

		#< @FunctionAlternativeForms

		def UpdateWithQ(paOtherSet)
			This.UpdateQ(paOtherSet)

		#>

	  #------------------#
	 #    ADD ELEMENT   #
	#------------------#

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
		if NOT ListIsSet(paOtherSet)
			stzRaise(stzSetError(:CanNotComputeUnionWithNoSet))
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

		if NOT ListIsListOfSets(paListOfSets)
			stzRaise(stzSetError(:CanNotComputeUnionWithNonSets))
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
		This.Update( This.UnionWithMany(paListOfSets) )

	def UnifyWithManyQ(paListOfSets)
		This.UnifyWithMany(paListOfSets)
		return This

	  #----------------------------------#
	 #    INTERSECTION WITH OTHER SET   #
	#----------------------------------#

	def IntersectionWith(paOtherSet)
		// If necessary, transform the provided list to a set
		if NOT ListIsSet(paOtherSet)
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
		if NOT ListIsSet(paOtherSet)
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
		if NOT ListIsSet(paOtherSet)
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
