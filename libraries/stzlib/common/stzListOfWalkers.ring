#---------------------------------------------------------------------------#
# 		     SOFTANZA LIBRARY (V1.0) - STZLISTOFWALKERS  	    #
# 	  An accelerative library for Ring applications, and more!	    #
#---------------------------------------------------------------------------#
#									    #
# 	Description : The class for managing lists of walkers in Softanza   #
#	Version	    : V0.9 (2020-2025)				            #
#	Author	    : Mansour Ayouni (kalidianow@gmail.com)		    #
#								            #
#---------------------------------------------------------------------------#

  /////////////////
 ///   CLASS   ///
/////////////////

func Wks(paoWalkers)

	if NOT isList(paoWalkers)
		StzRaise("Can't create a stzListOfWalkers object! paoWalkers must be a list.")
	ok

	if NOT len(paoWalkers) > 0
		StzRaise("Can't create a stzListOfWalkers object! paoWalkers list must not be empty.")
	ok

	if IsWalker(paoWalkers[1])
		return new stzListOfWalkers(paoWalkers)

	but isWalker2D(paoWalkers[1])
		return new stzListOfWalkers2D(paoWalkers)

	else
		StzRaise("Can't create a stzListOfWalkers object! paoWalkers list must be a list of stzWalker or stzWalker2D objects.")

	ok

class stzListOfWalkers

	@aoWalkers = []

	  #---------------------#
	 #   INITIALIZATION    #
	#---------------------#

	def init(paoWalkers)

		if NOT isList(paoWalkers)
			StzRaise("Incorrect param type! paoWalkers must be a list.")
		ok

		nLen = len(paoWalkers)
		if nLen = 0
			StzRaise("Can't create the stzListOfWalkers object! You must provide a non empty list of stzWalker objects.")
		ok


		for i = 1 to nLen
			if NOT @IsWalker(paoWalkers[i])
				StzRaise("Incorrect param type! All items must be stzWalker objects.")
			ok
		next
			
		@aoWalkers = paoWalkers

	  #------------------#
	 #   GENERAL INFO   #
	#------------------#

	def Content()
		return @aoWalkers

		def Value()
			return @aoWalkers

		def Walkers()
			return @aoWalkers

		def WalkersObjects()
			return @aoWalkers

	def Copy()
		return new stzListOfWalkers(This.Content())

	def Size()
		return len(@aoWalkers)

		def Count()
			return This.Size()

		def NumberOfWalkers()
			return This.Size()

		def CountWalkers()
			return This.Size()

		def HowManyWalkers()
			return This.Size()

	def Walker(n)
		if n < 1 or n > This.Size()
			StzRaise("Index out of range!")
		ok

		return @aoWalkers[n]

		def WalkerAt(n)
			return This.Walker(n)

	def FirstWalker()
		return This.Walker(1)

	def LastWalker()
		return This.Walker(This.Size())

	def AddWalker(oWalker)
		if NOT @IsWalker(oWalker)
			StzRaise("Incorrect param type! oWalker must be a stzWalker object.")
		ok

		@aoWalkers + oWalker

	def AddWalkers(paoWalkers)
		nLen = len(paoWalkers)
		for i = 1 to nLen
			This.AddWalker(paoWalkers[i])
		next

	def RemoveWalker(n)
		if n < 1 or n > This.Size()
			StzRaise("Index out of range!")
		ok

		del(@aoWalkers , n)

	def RemoveFirstWalker()
		This.RemoveWalker(1)

	def RemoveLastWalker()
		This.RemoveWalker(This.Size())

	  #----------------------------#
	 #   COMPARATIVE OPERATIONS   #
	#----------------------------#

	def SmallestWalker()

		nSize = This.Size()

		if nSize = 0
			StzRaise("Can't determine the smallest walker. The list is empty!")
		ok

		nSmallestSize = This.Walker(1).NumberOfWalkablePositions()
		nSmallestIndex = 1

		for i = 2 to nSize
			if This.Walker(i).NumberOfWalkablePositions() < nSmallestSize
				nSmallestSize = This.Walker(i).NumberOfWalkablePositions()
				nSmallestIndex = i
			ok
		next

		return This.Walker(nSmallestIndex)

		def MinWalker()
			return This.SmallestWalker()

	def LargestWalker()

		nSize = This.Size()

		if nSize = 0
			StzRaise("Can't determine the largest walker. The list is empty!")
		ok

		nLargestSize = This.Walker(1).NumberOfWalkablePositions()
		nLargestIndex = 1

		for i = 2 to nSize
			if This.Walker(i).NumberOfWalkablePositions() > nLargestSize
				nLargestSize = This.Walker(i).NumberOfWalkablePositions()
				nLargestIndex = i
			ok
		next

		return This.Walker(nLargestIndex)

		def MaxWalker()
			return This.LargestWalker()

	def WalkerWithLeastSteps()
		return This.SmallestWalker()

	def WalkerWithMostSteps()
		return This.LargestWalker()

	def SortByNumberOfWalkables()

		nSize = This.Size()

		aTemp = []
		for i = 1 to nSize
			aTemp + [ i, This.Walker(i).NumberOfWalkablePositions() ]
		next

		oTemp = new stzListOfPairs(aTemp)
		oTemp.SortInAscendingOn(2)
		aTemp = oTemp.Content()

		aResult = []
		nLen = len(aTemp)

		for i = 1 to nLen
			aResult + @aoWalkers [aTemp[i][1]]
		next

		@aoWalkers = aResult

	def WalkersEqual(n1, n2)

		nSize = This.Size()

		if n1 < 1 or n1 > nSize or n2 < 1 or n2 > nSize
			StzRaise("Index out of range!")
		ok

		oWalker1 = This.Walker(n1)
		aWalkables1 = oWalker1.Walkables()
		nLen1 = len(aWalkables1)

		oWalker2 = This.Walker(n2)
		aWalkables2 = oWalker2.Walkables()
		nLen2 = len(aWalkables2)

		if nLen1 != nLen2
			return FALSE
		ok

		for i = 1 to nLen1
			if aWalkables1[i] != aWalkables2[i]
				return FALSE
			ok
		next

		return TRUE

	  #---------------------#
	 #   WALKER ANALYSIS   #
	#---------------------#

	def AllWalkersUseTheSameStep()

		nSize = This.Size()

		if nSize <= 1
			return TRUE
		ok

		nStep = This.Walker(1).NStep()
		
		for i = 2 to nSize
			if This.Walker(i).NStep() != nStep
				return FALSE
			ok
		next

		return TRUE

	def MostCommonStep()

		nSize = This.Size()

		if nSize = 0
			StzRaise("Can't determine the most common step. The list is empty!")
		ok

		aSteps = []
		aCounts = []

		for i = 1 to nSize
			nStep = This.Walker(i).NStep()
			nPos = ring_find(aSteps, nStep)

			if nPos = 0
				aSteps + nStep
				aCounts + 1
			else
				aCounts[nPos]++
			ok
		next

		nLenCounts = len(aCounts)
		nMaxCount = 0
		nMaxIndex = 0

		for i = 1 to nLenCounts
			if aCounts[i] > nMaxCount
				nMaxCount = aCounts[i]
				nMaxIndex = i
			ok
		next

		return aSteps[nMaxIndex]

	def WalkersWithStep(nStep)

		nSize = This.Size()
		aResult = []
		
		for i = 1 to nSize
			if This.Walker(i).NStep() = nStep
				aResult + This.Walker(i)
			ok
		next

		return new stzListOfWalkers(aResult)

	def Walkables()
		aResult = []
		nLen = len(@aoWalkers)

		for i = 1 to nLen
			aResult + @aoWalkers[i].Content()
		next

		return aResult

	def CommonWalkables()
		return @Intersection(This.Walkables())

		def OverlappingWalkables()
			return This.CommonWalkables()

		def SharedWalkables()
			return This.CommonWalkables()

	def WalkedPositions()
		_aResult_ = []
		_nLen_ = len(@aoWalkers)

		for i = 1 to _nLen_
			_aResult_ + @aoWalkers[i].WalkedPositions()
		next

		return _aResult_

		def History()
			return This.WalkedPositions()

	  #-----------------#
	 #   WALKER SYNC   #
	#-----------------#

	def SetCurrentPosition(n)

		nLen = len(@aoWalkers)

		for i = 1 to nLen
			@aoWalkers.SetCurrentPosition(n)
		next

		def SetCurrentPositionTo(n)
			This.SetCurrentPosition(n)

	  #-----------------------------#
	 #   WALKER TRANSFORMATIONS    #
	#-----------------------------#

	def MergeWalkables()
		return sort(U(@Merge(This.Walkables())))

	  #-------------------#
	 #   BULK WALKING    #
	#-------------------#

	def CurrentPositions()
		anResult = []
		nLen = len(@aoWalkers)

		for i = 1 to nLen
			anResult + @aoWalkers[i].CurrentPosition()
		next

		return anResult

	def WalkAllNSteps(n)
		aResult = []
		nLen = len(@aoWalkers)

		for i = 1 to nLen
			aResult + @aoWalkers[i].WalkNSteps(n)
		next


		return aResult

		def WalkNSteps(n)
			This.WalkAllNSteps(n)

	def WalkAllToTheirEnd()

		aResult = []
		nLen = len(@aoWalkers)

		for i = 1 to nLen
			aResult + @aoWalkers[i].WalkToLast()
		next

		return aResult

		def WalkAllToEnd()
			This.WalkAllToTheirEnd()

		def WalkToEnd()
			This.WalkAllToTheirEnd()


	def RestartAllWalkers()
		nLen = len(@aoWalkers)

		for i = 1 to nLen
			@aoWalkers[i].SetCurrentPosition(@aoWalkers[i].@anWalkables[1])

		next

		return This.CurrentPositions()


		def RestartWalkers()
			This.RestartAllWalkers()

		def Restart()
			This.RestartAllWalkers()

		def WalkToFirst()
			This.RestartAllWalkers()

		def Reset()
			This.RestartAllWalkers()

		def ResetAllWalkers()
			This.RestartAllWalkers()

	def WalkToPosition(n)
		aResult = []
		nLen = len(@aoWalkers)

		for i = 1 to nLen
			aResult + @aoWalkers[i].WalkToPosition(n)
		next
    
		return aResult

		def WalkAllToPosition(n)
		return This.WalkToPosition(n)


	  #-------------------#
	 #  FINDING WALKERS  #
	#-------------------#

	#NOTE // "Finding" is a specific concept interpreted by Softanza as
	# identifying the walkers (by their positions in the @aWalkers container)
	# who either have the given path in their history (they have already walked it)
	# or in their walkable plan (they intend to walk it).

	def FindWalkedPath(panPositions)
		
		if CheckParams()
			if NOT (isList(panPositions) and @IsListOfNumbers(panPositions))
				stzraise("Incorrect param type! panPositions must be a list of numbers.")
			ok
		ok

		_cPositions_ = ring_substr2( @@(panPositions), "[", "" )
		_cPositions_ = ring_substr2( _cPositions_, "]", "" )
		_cPositions_ = @trim(_cPositions_)

		_anResult_ = []

		_anLists_ = This.WalkedPositions()
		_nLen_ = len(_anLists_)

		for i = 1 to _nLen_
			if @Contains( @@(_anLists_[i]), _cPositions_ )
				_anResult_ + i
			ok
		next

		return _anResult_


	def FindWalkablePath(panPositions)

		if CheckParams()
			if NOT (isList(panPositions) and @IsListOfNumbers(panPositions))
				stzraise("Incorrect param type! panPositions must be a list of numbers.")
			ok
		ok

		_cPositions_ = ring_substr2( @@(panPositions), "[", "" )
		_cPositions_ = ring_substr2( _cPositions_, "]", "" )
		_cPositions_ = @trim(_cPositions_)

		_anResult_ = []

		_anLists_ = This.Walkables()
		_nLen_ = len(_anLists_)

		for i = 1 to _nLen_
			if @Contains( @@(_anLists_[i]), _cPositions_ )
				_anResult_ + i
			ok
		next

		return _anResult_

	  #-----------------#
	 #   WALKER SYNC   #
	#-----------------#

	def SetAllToPosition(n)
		nLen = This.Size()

		for i = 1 to nLen
			if This.Walker(i).IsWalkable(n)
				This.Walker(i).SetCurrentPosition(n)
			else
				StzRaise("Position [" + n + "] is not walkable for walker #" + i)
			ok
		next

	def SetAllToStep(pStep)

		if CheckParams()
			if NOT ( isNumber(pStep) or ( isList(pStep) and @IsListOfNumbers(pSteps) ) )
				StzRaise("Incorrect param type! pStep must be a number or a list of numbers.")
			ok
		ok

		nLen = len(@aoWalkers)
		for i = 1 to nLen
			@aoWalkers.@step = pStep
		next
