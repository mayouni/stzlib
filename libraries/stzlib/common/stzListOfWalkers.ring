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

class stzListOfWalkers

	@aoWalkers = []

	  #------------------------#
	 #   INITIALIZATION      #
	#------------------------#

	def init(paWalkers)
		if isList(paWalkers)
			for oWalker in paWalkers
				if NOT @IsWalker(oWalker)
					StzRaise("Incorrect param type! All items must be stzWalker objects.")
				ok
			next
			
			@aoWalkers = paWalkers

		but @IsWalker(paWalkers)
			@aoWalkers = [ paWalkers ]

		else
			StzRaise("Incorrect param type! paWalkers must be either a stzWalker object or a list of stzWalker objects.")
		ok

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
		return This

	def RemoveFirstWalker()
		return This.RemoveWalker(1)

	def RemoveLastWalker()
		return This.RemoveWalker(This.Size())

	  #----------------------------#
	 #   COMPARATIVE OPERATIONS   #
	#----------------------------#

	def SmallestWalker()
		if This.Size() = 0
			StzRaise("Can't determine the smallest walker. The list is empty!")
		ok

		nSmallestSize = This.Walker(1).NumberOfWalkablePositions()
		nSmallestIndex = 1

		for i = 2 to This.Size()
			if This.Walker(i).NumberOfWalkablePositions() < nSmallestSize
				nSmallestSize = This.Walker(i).NumberOfWalkablePositions()
				nSmallestIndex = i
			ok
		next

		return This.Walker(nSmallestIndex)

		def MinWalker()
			return This.SmallestWalker()

	def LargestWalker()
		if This.Size() = 0
			StzRaise("Can't determine the largest walker. The list is empty!")
		ok

		nLargestSize = This.Walker(1).NumberOfWalkablePositions()
		nLargestIndex = 1

		for i = 2 to This.Size()
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
		aTemp = []
		for i = 1 to This.Size()
			aTemp + [ i, This.Walker(i).NumberOfWalkablePositions() ]
		next

		StzListOfPairsQ(aTemp).SortInAscendingBySecondItem()
		aResult = []

		for i = 1 to len(aTemp)
			aResult + @aoWalkers [aTemp[i][1]]
		next

		@aoWalkers = aResult
		return This

	def WalkersEqual(n1, n2)
		if n1 < 1 or n1 > This.Size() or n2 < 1 or n2 > This.Size()
			StzRaise("Index out of range!")
		ok

		oWalker1 = This.Walker(n1)
		oWalker2 = This.Walker(n2)

		if oWalker1.NumberOfWalkablePositions() != oWalker2.NumberOfWalkablePositions()
			return FALSE
		ok

		aWalkables1 = oWalker1.WalkablePositions()
		aWalkables2 = oWalker2.WalkablePositions()

		for i = 1 to len(aWalkables1)
			if aWalkables1[i] != aWalkables2[i]
				return FALSE
			ok
		next

		return TRUE

	  #---------------------#
	 #   WALKER ANALYSIS   #
	#---------------------#

	def AllWalkersUseTheSameStep()
		if This.Size() <= 1
			return TRUE
		ok

		nStep = This.Walker(1).NStep()
		
		for i = 2 to This.Size()
			if This.Walker(i).NStep() != nStep
				return FALSE
			ok
		next

		return TRUE

	def MostCommonStep()
		if This.Size() = 0
			StzRaise("Can't determine the most common step. The list is empty!")
		ok

		aSteps = []
		aCounts = []

		for i = 1 to This.Size()
			nStep = This.Walker(i).NStep()
			nPos = ring_find(aSteps, nStep)

			if nPos = 0
				aSteps + nStep
				aCounts + 1
			else
				aCounts[nPos]++
			ok
		next

		nMaxCount = 0
		nMaxIndex = 0

		for i = 1 to len(aCounts)
			if aCounts[i] > nMaxCount
				nMaxCount = aCounts[i]
				nMaxIndex = i
			ok
		next

		return aSteps[nMaxIndex]

	def WalkersWithStep(nStep)
		aResult = []
		
		for i = 1 to This.Size()
			if This.Walker(i).NStep() = nStep
				aResult + This.Walker(i)
			ok
		next

		return new stzListOfWalkers(aResult)

	def Walkables()
		aResult = []
		nLen = len(@aoWalkers )

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
		nLen = len(@aoWalkers)

		for i = 1 to nLen
			@aoWalkers[i].WalkNSteps(n)
		next

		def WalkNSteps(n)
			This.WalkAllNSteps(n)

	def WalkAllToTheirEnd()
		nLen = len(@aoWalmkers)

		for i = 1 to This.Size()
			@aoWalkers[i].WalkToLast()
		next

		def WalkAllToEnd()
			This.WalkAllToTheirEnd()

		def WalkToEnd()
			This.WalkAllToTheirEnd()

	def RestartAllWalkers()
		nLen = len(@aoWalkers)

		for i = 1 to This.Size()
			@aoWalkers[i].WalkToFirst()
		next

		def RestartWalkers()
			This.RestartAllWalkers()

		def Restart()
			This.RestartAllWalkers()

		def WalkToFirst()
			This.RestartAllWalkers()

	def WalkToPosition(n)
		nLen = len(@aoWalkers)

		for i = 1 to nLen
			if @aoWalkers[i].IsWalkable(n)
				This.Walker(i).WalkToPosition(n)
			else
				stzraise("Can't walk to position n!")
			ok
		next

		def WalkAllToPosition(n)
			This.WalkToPosition(n)

	  #-------------------#
	 #  FINDING WALKERS  #
	#-------------------#

	# Finding is a particular subject that is interepred by Softanza as
	# returning the walkers (by their positions in the @aWolkers container)
	# that have the give path (to be found) in their history (they already
	# walked through it) or in their walkable plan.

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
