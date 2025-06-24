#---------------------------------------------------------------------------#
# 		  SOFTANZA LIBRARY (V1.0) - STZLISTOFWALKERS2D  	    #
# 	  An accelerative library for Ring applications, and more!	    #
#---------------------------------------------------------------------------#
#									    #
# 	Description : The class for managing lists of 2D walkers in Softanza #
#	Version	    : V0.9 (2020-2025)				            #
#	Author	    : Based on stzListOfWalkers by Mansour Ayouni	    #
#								            #
#---------------------------------------------------------------------------#

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func Wks2D(paWalkers)
	return new stzListOfWalkers2D(paWalkers)

	func StzListOfWalkers2DQ(paWalkers)
		return new stzListOfWalkers2D(paWalkers)

  /////////////////
 ///   CLASS   ///
/////////////////

class stzListOfWalkers2D

	@aoWalkers = []

	  #--------------------#
	 #   INITIALIZATION   #
	#--------------------#

	def init(paoWalkers)

		if NOT isList(paoWalkers)
			StzRaise("Can't create a stzListOfWalkers2D object! paoWalkers must be a list.")
		ok

		nLen = len(paoWalkers)
		if nLen = 0
			StzRaise("Can't create the stzListOfWalkers2D object! You must provide a non empty list of stzWalker2D objects.")
		ok

		for i = 1 to nLen
			if NOT @IsWalker2D(paoWalkers[i])
				StzRaise("Incorrect param type! All items must be stzWalker2D objects.")
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
		return new stzListOfWalkers2D(This.Content())

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
		if NOT IsWalker2D(oWalker)
			StzRaise("Incorrect param type! oWalker must be a stzWalker2D object.")
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

		del(@aoWalkers, n)

	def RemoveFirstWalker()
		This.RemoveWalker(1)

	def RemoveLastWalker()
		This.RemoveWalker(This.Size())

	  #----------------------------#
	 #   COMPARATIVE OPERATIONS   #
	#----------------------------#

	def SmallestWalker()
		if This.Size() = 0
			StzRaise("Can't determine the smallest walker. The list is empty!")
		ok

		nSmallestSize = This.Walker(1).NumberOfWalkablePositions()
		nSmallestIndex = 1
		nSize = This.Size()

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
		if This.Size() = 0
			StzRaise("Can't determine the largest walker. The list is empty!")
		ok

		nLargestSize = This.Walker(1).NumberOfWalkablePositions()
		nLargestIndex = 1
		nSize = This.Size()

		for i = 2 to nSize
			if This.Walker(i).NumberOfWalkablePositions() > nLargestSize
				nLargestSize = This.Walker(i).NumberOfWalkablePositions()
				nLargestIndex = i
			ok
		next

		return This.Walker(nLargestIndex)

		def MaxWalker()
			return This.LargestWalker()

	def SortByNumberOfWalkables()
		aTemp = []
		nSize = This.Size()

		for i = 1 to nSize
			aTemp + [ i, This.Walker(i).NumberOfWalkablePositions() ]
		next

		oTemp = new stzListOfPairs(aTemp)
		oTemp.SortInAscendingOn(2)
		aTemp = oTemp.Content()
		nLen = len(aTemp)

		aResult = []

		for i = 1 to nLen
			aResult + @aoWalkers[aTemp[i][1]]
		next

		@aoWalkers = aResult

	def WalkersEqual(n1, n2)
		nSize = This.Size()
		if n1 < 1 or n1 > nSize or n2 < 1 or n2 > nSize
			StzRaise("Index out of range!")
		ok

		oWalker1 = This.Walker(n1)
		aWalkables1 = oWalker1.WalkablePositions()
		nLen1 = len(aWalkables1)

		oWalker2 = This.Walker(n2)
		aWalkables2 = oWalker2.WalkablePositions()
		nLen2 = len(aWalkables2)

		if nLen1 != nLen2
			return FALSE
		ok

		for i = 1 to nLen1
			if aWalkables1[i][1] != aWalkables2[i][1] or aWalkables1[i][2] != aWalkables2[i][2]
				return FALSE
			ok
		next

		return TRUE

		def WalkersAreEqual(n1, n2)
			return This.WalkersEqual(n1, n2)

	  #---------------------#
	 #   WALKER ANALYSIS   #
	#---------------------#

	def AllWalkersHaveSameSteps()
		nSize = This.Size()
		if nSize <= 1
			return TRUE
		ok

		steps = This.Walker(1).Steps()

		if isNumber(steps)
			# If the first walker uses a single number step
			nStep = steps
			
			for i = 2 to nSize
				tempSteps = This.Walker(i).Steps()
				if isNumber(tempSteps)
					if tempSteps != nStep
						return FALSE
					ok
				else
					# One walker uses a list of steps while others use single number
					return FALSE
				ok
			next
		else
			# If the first walker uses a list of steps
			aSteps = This.Walker(1).Steps()
			nLenSteps = len(aSteps)

			for i = 2 to nSize
				tempSteps = This.Walker(i).Steps()

				if isNumber(tempSteps)
					# One walker uses a single number while others use list
					return FALSE
				else
					if len(tempSteps) != nLenSteps
						return FALSE
					ok

					for j = 1 to nLenSteps
						if tempSteps[j] != aSteps[j]
							return FALSE
						ok
					next
				ok
			next
		ok

		return TRUE



	# Analyzing all walkers in the collection and determining which
	# step size (or step sequence) is used most frequently among them:

	def MostCommonStep()

		nSize = This.Size()
		if nSize = 0
			StzRaise("Can't determine the most common step. The list is empty!")
		ok

		aSteps = []
		aCounts = []

		for i = 1 to nSize
			pStep = This.Walker(i).Steps()
			sStep = @@(pStep)  # Convert to string for comparison
			nPos = ring_find(aSteps, sStep)

			if nPos = 0
				aSteps + sStep
				aCounts + 1
			else
				aCounts[nPos]++
			ok
		next

		nMaxCount = 0
		nMaxIndex = 0
		nLen = len(aCounts)

		for i = 1 to nLen
			if aCounts[i] > nMaxCount
				nMaxCount = aCounts[i]
				nMaxIndex = i
			ok
		next

		return aSteps[nMaxIndex]

	def WalkersWithStep(pStep)
		aResult = []
		sStep = @@(pStep)  # Convert to string for comparison
		nSize = This.Size()

		for i = 1 to nSize
			oWalker = This.Walker(i)
			if @@(oWalker.Steps()) = sStep
				aResult + oWalker
			ok
		next

		return new stzListOfWalkers2D(aResult)

	def WalkablePositions()
		aResult = []
		nSize = This.Size()

		for i = 1 to nSize
			aResult + This.Walker(i).WalkablePositions()
		next

		return aResult

		def Walkables()
			return This.WalkablePositions()

	def CommonWalkablePositions()
		nSize = This.Size()
		if nSize = 0
			return []
		ok

		# Start with all walkables from first walker
		aCommon = This.Walker(1).WalkablePositions()
		
		# Intersect with each subsequent walker
		for i = 2 to nSize

			aWalkables = This.Walker(i).WalkablePositions()
			nLenWalkables = len(aWalkables)

			aNewCommon = []
			nLenComman = len(aCommon)

			# Find positions that exist in both lists
			for j = 1 to nLenComman
				for k = 1 to nLenWalkables

					if aCommon[j][1] = aWalkables[k][1] and 
					   aCommon[j][2] = aWalkables[k][2]
						aNewCommon + aCommon[j]
						exit
					ok
				next
			next
			
			aCommon = aNewCommon
			
			# If no common walkables left, exit early
			if len(aCommon) = 0
				return []
			ok
		next
		
		return aCommon

		def OverlappingWalkablePositions()
			return This.CommonWalkablePositions()

		def SharedWalkablePositions()
			return This.CommonWalkablePositions()

		def CommonWalkables()
			return This.CommonWalkablePositions()

	def WalkedPositions()
		aResult = []
		nSize = This.Size()

		for i = 1 to nSize
			aResult + This.Walker(i).WalkedPositions()
		next

		return aResult

		def History()
			return This.WalkedPositions()

	  #-----------------#
	 #   WALKER SYNC   #
	#-----------------#

	def SetCurrentPosition(nX, nY)
		nLen = This.Size()

		for i = 1 to nLen
			if This.Walker(i).IsWalkable(nX, nY)
				This.Walker(i).SetCurrentPosition(nX, nY)
			ok
		next

		def SetCurrentPositionTo(nX, nY)
			return This.SetCurrentPosition(nX, nY)

	def SetAllToPosition(nX, nY)
		nLen = This.Size()

		for i = 1 to nLen
			if This.Walker(i).IsWalkable(nX, nY)
				This.Walker(i).SetCurrentPosition(nX, nY)
			else
				StzRaise("Position [" + nX + "," + nY + "] is not walkable for walker #" + i)
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

	  #-----------------------------#
	 #   WALKER TRANSFORMATIONS    #
	#-----------------------------#

	def MergeWalkablePositions()

		nSize = This.Size()

		if nSize = 0
			return []
		ok
		
		aAllWalkables = []
		
		# Collect all walkable positions
		for i = 1 to nSize
			aWalkables = This.Walker(i).WalkablePositions()
			nLen = len(aWalkables)

			for j = 1 to nLen
				# Check if position already exists
				bExists = FALSE
				nLenAll = len(aAllWalkables)
				for k = 1 to nLenAll
					if aAllWalkables[k][1] = aWalkables[j][1] and 
					   aAllWalkables[k][2] = aWalkables[j][2]
						bExists = TRUE
						exit
					ok
				next
				
				if NOT bExists
					aAllWalkables + aWalkables[j]
				ok
			next
		next
		
		# Sort positions by X then Y
		return This._SortPositions(aAllWalkables)

		def MergeWalkables()
			return This.MergeWalkablePositions()

		def MergedWalkablePositions()
			return This.MergeWalkablePositions()

		def MergedWalkables()
			return This.MergeWalkablePositions()

	  #-------------------#
	 #   BULK WALKING    #
	#-------------------#

	def CurrentPositions()
		anResult = []
		nSize = This.Size()

		for i = 1 to nSize
			anResult + This.Walker(i).CurrentPosition()
		next

		return anResult

	def WalkAllNSteps(n)

		nSize = This.Size()
		aResult = []

		for i = 1 to nSize
			aResult + @aoWalkers[i].WalkNSteps(n)
		next

		return aResult

		#< @FunctionAlternativeForm

		def WalkNSteps(n)
			return This.WalkAllNSteps(n)

		def WalkN(n)
			return This.WalkAllNSteps(n)

		#>

	def WalkAllToTheirEnd()
		nSize = This.Size()
		aResult = []

		for i = 1 to nSize
			aResult + @aoWalkers[i].WalkToLast()
		next

		return aResult

		#< @FunctionAlternativeForms

		def WalkAllToEnd()
			return This.WalkAllToTheirEnd()

		def WalkToEnd()
			return This.WalkAllToTheirEnd()

		def WalkToLast()
			return This.WalkAllToTheirEnd()

		def WalkAllToLast()
			return This.WalkAllToTheirEnd()

		#>

	def RestartAllWalkers()
		nSize = This.Size()
		aResult = []

		for i = 1 to nSize
			aResult + @aoWalkers[i].WalkToFirst()
		next

		return aResult

		#< @FunctionAlternativeForms

		def RestartWalkers()
			return This.RestartAllWalkers()

		def Restart()
			return This.RestartAllWalkers()

		def WalkToFirst()
			This.RestartAllWalkers()

		#>

	def WalkToPosition(nX, nY)
		nSize = This.Size()
		aResult = []

		for i = 1 to nSize
			if @aoWalkers[i].IsWalkable(nX, nY)
				aResult + @aoWalkers[i].WalkTo(nX, nY)
			else
				StzRaise("Position [" + nX + "," + nY + "] is not walkable for walker #" + i)
			ok
		next

		return aResult

		def WalkAllToPosition(nX, nY)
			This.WalkToPosition(nX, nY)

	def WalkIfPossible(nX, nY)

		aResult = []
		nSize = This.Size()

		for i = 1 to nSize
			if @aoWalkers[i].IsWalkable(nX, nY)
				aResult + @aoWalkers[i].WalkTo(nX, nY)
			ok
		next

		return aResult

	  #------------------------#
	 #  2D SPECIFIC METHODS   #
	#------------------------#

	def BoundingBox()

		nSize = This.Size()

		if nSize = 0
			return [ 0, 0, 0, 0 ]  # Empty bounding box
		ok
		
		# Initialize with extreme values

		nMinX = 99999
		nMinY = 99999
		nMaxX = -99999
		nMaxY = -99999
		
		# Iterate through all walkers and find min/max coordinates

		for i = 1 to nSize

			aPositions = This.Walker(i).Positions()
			nLen = len(aPositions)

			for j = 1 to nLen

				nX = aPositions[j][1]
				nY = aPositions[j][2]
				
				if nX < nMinX
					nMinX = nX
				ok
				
				if nX > nMaxX
					nMaxX = nX
				ok
				
				if nY < nMinY
					nMinY = nY
				ok
				
				if nY > nMaxY
					nMaxY = nY
				ok
			next
		next
		
		return [ nMinX, nMinY, nMaxX, nMaxY ]

	def ContainsPosition(nX, nY)

		nSize = This.Size()

		for i = 1 to nSize
			if This.Walker(i).IsWalkable(nX, nY)
				return TRUE
			ok
		next
		
		return FALSE

	def WalkersAtPosition(nX, nY)

		aResult = []
		nSize = This.Size()

		for i = 1 to nSize
			if This.Walker(i).IsWalkable(nX, nY)
				aResult + i
			ok
		next
		
		return aResult

	def Show()
		? This.ToString()

	def ToString()

		aBoundingBox = This.BoundingBox()
		nMinX = aBoundingBox[1]
		nMinY = aBoundingBox[2]
		nMaxX = aBoundingBox[3]
		nMaxY = aBoundingBox[4]

		nGridWidth = nMaxX - nMinX + 1
		nGridHeight = nMaxY - nMinY + 1

		# Create an empty grid filled with "."

		aGrid = newlist(nGridHeight, nGridWidth)

		for y = 1 to nGridHeight
			for x = 1 to nGridWidth
				aGrid[y][x] = "."
			next
		next

		# Track positions for border markers

		aTopMarkers = list(nGridWidth)
		aLeftMarkers = list(nGridHeight)

		# Set cell width to accommodate larger labels (E10, etc.)

		nCellWidth = 3  # Standard width for all cells

		# Mark each walker's walkable positions with numbers

		nSize = This.Size()

		for i = 1 to nSize

			nWalkerNum = i % 10  # Use modulo to keep single digit
			aWalkables = This.Walker(i).WalkablePositions()
			nLen = len(aWalkables)

			# Get start and end positions
			aStart = This.Walker(i).StartPosition()
			aEnd = This.Walker(i).EndPosition()

			for j = 1 to nLen

				nPosX = aWalkables[j][1] - nMinX + 1
				nPosY = aWalkables[j][2] - nMinY + 1

				if nPosX > 0 and nPosY > 0 and nPosX <= nGridWidth and nPosY <= nGridHeight
					# Mark start position
					if aWalkables[j][1] = aStart[1] and aWalkables[j][2] = aStart[2]
						aGrid[nPosY][nPosX] = "S" + nWalkerNum
					# Mark end position
					but aWalkables[j][1] = aEnd[1] and aWalkables[j][2] = aEnd[2]
						aGrid[nPosY][nPosX] = "E" + nWalkerNum
					# If position already has a different walker's mark, use "*" for overlap
					but aGrid[nPosY][nPosX] != "." and aGrid[nPosY][nPosX] != "" + nWalkerNum
						aGrid[nPosY][nPosX] = "*"
					else
						aGrid[nPosY][nPosX] = "" + nWalkerNum
					ok
				ok
			next

			# Mark each walker's current position with "x"+number
			aCurrPos = This.Walker(i).CurrentPosition()
			nCurrX = aCurrPos[1] - nMinX + 1
			nCurrY = aCurrPos[2] - nMinY + 1

			if nCurrX > 0 and nCurrY > 0 and nCurrX <= nGridWidth and nCurrY <= nGridHeight
	
				aGrid[nCurrY][nCurrX] = "x" + nWalkerNum
	
				# Mark borders for current positions
				aTopMarkers[nCurrX] = "v"
				aLeftMarkers[nCurrY] = ">"
			ok
		next

		# Convert grid to string representation
		# Add X-axis labels with proper alignment for each column

		sResult = "    "  # Extra space for Y-axis column

		for x = nMinX to nMaxX
			sXLabel = "" + (x % 10)
			nPadding = floor((nCellWidth - len(sXLabel)) / 2)
			sSpaceBefore = space(nPadding)
			sSpaceAfter = space(nCellWidth - len(sXLabel) - nPadding)
			sResult += sSpaceBefore + sXLabel + sSpaceAfter
		next
		sResult += NL

		# Add top border with markers

		sResult += "  ╭─"

		for x = 1 to nGridWidth

			if aTopMarkers[x] = "v"
				sBorder = "─v" + ring_copy("─", nCellWidth-2)
			else
				sBorder = ring_copy("─", nCellWidth)
			ok

			sResult += sBorder
		next

		sResult += "╮" + NL

# Add rows with Y-axis labels and borders
for y = 1 to nGridHeight
    sYLabel = "" + ((y+nMinY-1) % 10)
    
    # Fix: Replace the vertical line with ">" when there's a marker
    if aLeftMarkers[y] = ">"
        sResult += sYLabel + " > " # Show y-coordinate and ">" as the border
    else
        sResult += sYLabel + " │ " # Show y-coordinate and normal border
    ok
    
    for x = 1 to nGridWidth
        sContent = aGrid[y][x]
        nPadding = floor((nCellWidth - len(sContent)) / 2)
        sSpaceBefore = ring_copy(" ", nPadding)
        sSpaceAfter = ring_copy(" ", nCellWidth - len(sContent) - nPadding)
        sResult += sSpaceBefore + sContent + sSpaceAfter
    next
    
    sResult += "│" + NL
next

		# Add bottom border

		sResult += "  ╰─"

		for x = 1 to nGridWidth
			sResult += ring_copy("─", nCellWidth)
		next
		sResult += "╯" + NL
    
		return sResult   

		def Stringified()
			return This.ToString()

	def Legend()

		cResult =  "  . = Empty position" + NL
		cResult += "1-9 = Walker's walkable position" + NL
		cResult += "  * = Overlapping walkable positions" + NL
		cResult += " x# = Current position of walker #" + NL
		cResult += " S# = Start position of walker #" + NL
		cResult += " E# = End position of walker #" + NL
		cResult += "v/> = Markers of current positions on grid borders" + NL
    
		return cResult

	  #------------------------------#
	 #  FINDING WALKABLE POSITIONS  #
	#------------------------------#

	# Identifying which walkers can walk on specific position(s)

	def FindWalkable(paPosition)
		return This.FindWalkables([paPosition])

	def FindWalkables(paPositions)

		if NOT isList(paPositions)
			StzRaise("Incorrect param type! paPositions must be a list of [x,y] positions.")
		ok
		
		aWalkables = This.Walkables()

		oLoL = new stzListOfLists(This.Walkables())
		aResult = oLoL.FindManyInLists(paPositions)

		return aResult

	# Identifiying walkers whose entire bounding box fits
	# within a specified rectangular section

	def FindWalkersInSection(panStartPos, panEndPos)

		if NOT (isList(panStartPos) and len(panStartPos) and
			isNumber(panStartPos[1]) and isNumber(panStartPos[2]) and

			isList(panEndPos) and len(panEndPos) and
			isNumber(panEndPos[1]) and isNumber(panEndPos[2]) )

			StzRaise("Incorrect param type! panStartPos and panEndPos must be pairs of numbers.")
		ok

		nX1 = panStartPos[1]
		nY1 = panStartPos[2]
		nX2 = panEndPos[1]
		nY2 = panEndPos[2]

		aResult = []
		nSize = This.Size()

		for i = 1 to nSize
			aBBox = This._GetWalkerBoundingBox(This.Walker(i))
			
			# Check if walker's bounding box is completely within the given box
			if aBBox[1] >= nX1 and aBBox[2] >= nY1 and 
			   aBBox[3] <= nX2 and aBBox[4] <= nY2
				aResult + i
			ok
		next
		
		return aResult

	# Determining which walkers have walkable positions that
	# overlap with a specific path

	def FindWalkersIntersectingPath(paPositions)

		if NOT isList(paPositions)
			StzRaise("Incorrect param type! paPositions must be a list of [x,y] positions.")
		ok
		
		aResult = []
		nSize = This.Size()
		nLenPos = len(paPositions)

		for i = 1 to nSize

			bIntersects = FALSE
			
			for j = 1 to nLenPos
				if This.Walker(i).IsWalkable(paPositions[j][1], paPositions[j][2])
					bIntersects = TRUE
					exit
				ok
			next
			
			if bIntersects
				aResult + i
			ok
		next
		
		return aResult

	  #----------------------#
	 #   HELPER METHODS     #
	#----------------------#

	def _GetWalkerBoundingBox(oWalker)
		aPositions = oWalker.Positions()
		nLenPos = len(aPositions)

		if nLenPos = 0
			return [0, 0, 0, 0]
		ok
		
		nMinX = 99999
		nMinY = 99999
		nMaxX = -99999
		nMaxY = -99999
		
		for i = 1 to nLenPos
			nX = aPositions[i][1]
			nY = aPositions[i][2]
			
			if nX < nMinX
				nMinX = nX
			ok
			
			if nX > nMaxX
				nMaxX = nX
			ok
			
			if nY < nMinY
				nMinY = nY
			ok
			
			if nY > nMaxY
				nMaxY = nY
			ok
		next
		
		return [ nMinX, nMinY, nMaxX, nMaxY ]

	def _SortPositions(aPositions)
		# Simple bubble sort to order positions by X, then Y
		nLen = len(aPositions)
		
		for i = 1 to nLen - 1
			for j = 1 to nLen - i
				if aPositions[j][1] > aPositions[j+1][1] or 
				  (aPositions[j][1] = aPositions[j+1][1] and aPositions[j][2] > aPositions[j+1][2])
					temp = aPositions[j]
					aPositions[j] = aPositions[j+1]
					aPositions[j+1] = temp
				ok
			next
		next
		
		return aPositions
