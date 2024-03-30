/*
TODO:
	- Rank vs Position?
	- Should a szGrid host only strings?
		I think so...
		A grid is a visual asset after all.
		If you need to host other values, use a stzTable insetad.

	--> DECISION: stzGrid would contains only nodes that are strings.

	Also: the Show() function will not show an accurate grif if nodes
	contains strings of many chars! So:

	- Should stzGrid contain only chars?
*/

_cEmptyNodeChar = "."
_cGridSeparator = ":"

func IsGrid(paList)
	if isList(paList) and IsListOfLists(paList) and AllListsHaveSameSize(paList)
		return TRUE
	else
		return FALSE
	ok

	func @IsGrid(paList)
		return IsGrid(paList)

	#--

	func IsAGrid(paList)
		return IsGrid(paList)

	func @IsAGrid(paList)
		return IsGrid(paList)

	#>

func GridEmptyNodeChar()
	return _cEmptyNodeChar

	func StzGridEmptyNodeChar()
		return GridEmptyNodeChar()

	func EmptyNodeChar()
		return GridEmptyNodeChar()

	func EmptyNode()
		return GridEmptyNodeChar()

func SetGridEmptyNodeChar(cChar)
	if NOT (isString(cChar) and Q(cChar).IsAChar())
		StzRaise("Incorrect param type! cChar must be a char.")
	ok

	_cEmptyNodeChar = cChar

	func SetStzGridEmptyNodeChar(cChar)
		SetGridEmptyNodeChar(cChar)

	func SetEmptyNodeChar(cChar)
		SetGridEmptyNodeChar(cChar)

func GridSeparator()
	return _cGridSeparator

	func StzGridSeparator()
		return GridSeparator()

	func GridSep()
		return GridSeparator()

	func StzGridSep()
		return GridSeparator()

func SetGridSeparator(cSep)
	if NOT isString(cSep)
		StzRaise("Incorrect param type! cSep must be a string.")
	ok

	_cGridSeparator = cSep

	func SetStzGridSeparator(cSep)
		SetGridSeparator(cSep)

	func SetGridSep(cSep)
		SetGridSeparator(cSep)

	func SetStzGridSep(cSep)
		SetGridSeparator(cSep)

func StzGrid(p)
	return new stzGrid(p)

func StzGridQ(p)
	return new stzGrid(p)

class stzGrid from stzObject
	@aContent
	@nNumberOfVLines
	@nNumberOfHLines

	@bShowRanks = FALSE
	@bShowCenter = FALSE

	@nOpacity
	@aLayers

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(p)
		/* There are 4 ways of creating a stzGrid object:
	
		Way 1 :
			o1 = new stzGrid(12)
	
		Way 2 :
			o1 = new stzGrid([3,4])
	
		Way 3 :
			o1 = new setGrid([
				["A","B","C"],
				["E","F","G"],
				["H","I","J"]
			])
	
		Way 4:
			o1 = new stzGrid("
				. : 1 : . : . : .
				1 : 2 : 3 : 4 : 5
				. : 3 : . : . : .
				. : 4 : . : . : .
				. : 5 : . : . : .
				")
		*/
	
		This.SetGrid(p)

	  #--------------------#
	 #  SETTING THE GRID  #
	#--------------------#

	def SetGrid(p) 
	/*
		Example 1 : 	SetGrid(12)

		Example 2 : 	SetGrid([3,4])

		Example 3 :
				SetGrid([
					["A","B","C"],
					["E","F","G"],
					["H","I","J"]
				])

		Example 4 (TODO):

			SetGrid("
				. : 1 : . : . : .
				1 : 2 : 3 : 4 : 5
				. : 3 : . : . : .
				. : 4 : . : . : .
				. : 5 : . : . : .
			")
	*/

		aTempGrid = []
		aHLine = []
		nV = 0
		nH = 0

		switch ring_type(p)	
		on "NUMBER"
			aPossibleVH = MultiplicationsYieldingN_WithoutCommutation(p)
			if len(aPossibleVH) = 1
				nV = aPossibleVH[1][1]
				nH = aPossibleVH[1][2]
			else
				n = len(aPossibleVH)
				nV = aPossibleVH[n][1]
				nH = aPossibleVH[n][2]
			ok

			for i = 1 to nV
				aHLine + EmptyNode()
			next i
		
			for i = 1 to nH
				aTempGrid + aHLine
			next i
		
		on "LIST"

			if len(p) = 2

				nV = p[1]
				if isList(nV) and Q(nV).IsOfNamedParam()
					nV = nV[2]
				ok

				nH = p[2]
				if isList(nH) and Q(nH).IsByNamedParam()
					nH = nH[2]
				ok

				if NOT @BothAreNumbers(nV, nH)
					StzRaise("Incorrect param! p must be a pair of numbers.")
				ok

				for i=1 to nV
					aHLine + EmptyNode()
				next i
		
				for i=1 to nH
					aTempGrid + aHLine
				next i

			else
				if Q(p).IsListOf(:ListsOfStrings) and
				   Q(p).SublistsHaveSameNumberOfItems()

					nV = len( p[1] )
					nH = len(p)

					for i = 1 to nH
						aTempGrid + p[i]
					next

				ok
			ok

		on "STRING"
			if Q(p).ContainsOneOfThese([ NL, GridSep() ])

				aTempGrid = Q(p).RemoveEmptyLinesQ().
						LinesQR(:stzListOfStrings).
						TrimQ().
						StringsSplitted(:Using = GridSep())

				nV = len(aTempGrid)
				nH = len(aTempGrid[1])
			ok
		off

		@aContent = aTempGrid

		@nNumberOfVLines = nV
		@nNumberOfHLines = nH

	  #-----------------#
	 #     GENERAL     #
	#-----------------#

	def Content()
		return @aContent

		def Value()
			return Content()

	def Size()
		anResult = [ This.NumberOfHLines(), This.NumberOfVLines() ]
		return anResult

		def Dimensions()
			return This.Size()

	def NumberOfVLines()
		return @nNumberOfVLines

		def HowManyVlines()
			return This.NumberOfVLines()

		def HowManyVLine()
			return This.NumberOfVLines()

	def NumberOfHLines()
		return @nNumberOfHLines

		def HowManyHlines()
			return This.NumberOfHLines()

		def HowManyHLine()
			return This.NumberOfHLines()

	def NumberOfNodes()
		return This.NumberOfVLines() * This.NumberOfHLines()

		def HowManyNodes()
			return This.NumberOfNodes()

		def HowManyNode()
			return This.NumberOfNodes()

	def NumberOfNodesPerHLine()
		return This.NumberOfVLines()

		def HowManyNodesPerHLine()
			return This.NumberOfNodesPerHLine()

		def HowManyNodePerHLine()
			return This.NumberOfNodesPerHLine()

	def NumberOfNodesPerVLine()
		return This.NumberOfHLines()

		def HowManyNodesPerVLine()
			return This.NumberOfNodesPerVLine()

		def HowManyNodePerVLine()
			return This.NumberOfNodesPerVLine()

	def HasNVLines(n)
		if This.NumberOfVlines() = n
			return TRUE
		else
			return FALSE
		ok

		def ContainsNVLines(n)
			return This.HasNVLines(n)

	def HasNHLines(n)
		if This.NumberOfHLines() = n
			return TRUE
		else
			return FALSE
		ok

		def ContainsNHLines(n)
			return This.HasNHLines(n)

	def HasNNodes(n)
		if This.NumberOfNodes() = n
			return TRUE
		else
			return FALSE
		ok

		def ContainsNVNodes(n)
			return This.HasNVNodes(n)
		
	def AllNodesOf_NthVLineAre_Strings(n)
		bResult = TRUE
		for node in This.VLine(n)
			if NOT isString(node)
				bResult = FALSE
			ok
		next
		return bResult

	def AllNodesOf_NthHLineAre_Strings(n)
		// TODO

	  #-----------------------------------------#
	 #     GETTING Nodes, HLines, & VLines     #
	#-----------------------------------------#
	
	def VLine(n)
		aResult = []
		for i = 1 to This.NumberOfHLines()
			aResult + This.HLine(i)[n]
		next i
		return aResult

	def FirstVLine()
		return This.VLine(1)

	def LastVLine()
		return This.VLine( This.NumberOfVLines() )

	def VLines()
		aResult = []
		for i = 1 to This.NumberOfVLines()
			aResult + This.VLine(i)
		next

		return aResult

	def HLine(n)
		return This.Content()[n]

	def FirstHLine()
		return This.HLine(1)

	def LastHLine()
		return This.HLine( This.NumberOfHLines() )

	def HLines()
		aResult = []

		for i = 1 to This.NumberOfHLines()
			aResult + This.HLine(i)
		next

		return aResult

	def NodeAtPosition(nVLine, nHLine)
		return This.HLine(nHLine)[nVLine]

		def Node(nVLine, nHLine)
			return This.NodeAtPosition(nVLine, nHLine)

	def NthNode()
		aPosition = This.PositionOfNode(n)
		nVLine = aPosition[1]
		nHLine = aPosition[2]
		return This.NodeAtPosition(nVLine, nHLine)

	def PositionOfNode(n)
		if n <= NumberOfVLines
			nVLine = n
			nHLine = 1
		else

			nHLine = StzNumberQ( ""+ n / This.NumberOfVLines() ).IntegerPartValue()
			nVLine = n - nHLine * This.NumberOfVLines()

			if nVLine = 0
				nVLine = This.NumberOfVLines()
			but nVLine > 0
				nHLine++
			ok
		ok

		aPosition = [ nVLine, nHLine ]
		return aPosition

		def NodePosition(n)
			return PositionOfNode(n)

	  #----------------------------------------#
	 #     NUMBERED VLines, HLines & GRID     #
	#----------------------------------------#

	def NumberedVLines(pnVLine)
		n = StzCounterQ([ :StartAt = 1, :WhenYouReach = 10, :RestartAt = 0 ]).CountTo(pnVLine)

		/* TODO: Replace with this when stzList is up!
		oTempList = new stzList( VLine(n) )
		return oTempList.InsertInStart(n) */

		aResult = [ n ]
		for i = 1 to This.NumberOfHLines()
			aResult + This.VLine(pnVLine)[i]
		next

		return aResult

	def NumberedHLines(pnHLine)
		n = StzCounterQ([ :StartAt = 1, :WhenYouReach = 10, :RestartAt = 0 ]).CountTo(pnHLine)

		/* Replace with this when stzList is up!
		oTempList = new stzList( HLine(n) )
		return oTempList.InsertInStart(n) */

		aResult = [ n ]
		for i = 1 to This.NumberOfVLines()
			aResult + This.HLine(pnHLine)[i]
		next

		return aResult


	  #--------------------------------------#
	 #     CENTRAL VLine, HLine & Node      #
	#--------------------------------------#

	def HasCentralHLine()
		if StzNumberQ( ""+ This.NumberOfHLines() ).IsOdd()
			return TRUE
		else
			return FALSE
		ok

		def ContainsCentralHLine()
			return This.HasCentralHLine()

	def RankOfCentralHLine()
		if This.HasCentralHLine()
			return 1+ StzNumberQ( ""+ (This.NumberOfHLines()/2) ).IntegerPart()

		else
			StzRaise("The grid has no central HLine!")
			StzRaise(stzGridError(:CanNotDefineRankOfCentralHorizontalLine))
		ok

	def CentralHLine()
		return HLine( RankOfCentralHLine() )

	def HasCentralVLine()
		if StzNumberQ( ""+ NumberOfVLines() ).IsOdd()
			return TRUE
		else
			return FALSE
		ok

		def ContainsCentralVLine()
			return This.HasCentralVLine()

	def RankOfCentralVLine()
		if This.HasCentralVLine() 
			return 1+ StzNumberQ( ""+ (This.NumberOfVLines()/2) ).IntegerPart()		

		else
			StzRaise("The grid has no central VLine!")
		ok

	def CentralVLine()
		return This.VLine( This.RankOfCentralVLine() )

	def HasCentralNode()
		if This.HasCentralVLine() and This.HasCentralHLine()
			return TRUE
		else
			return FALSE
		ok

		def ContainsCentralNode()
			return This.HasCentralNode()

	def HasCentralRegion()
		if NOT This.HasCentralNode()
			return TRUE
		else
			return FALSE

		ok

		def ContainsCentralRegion()
			return This.HasCentralRegion()

	def PositionOfCentralNode()
		if This.HasCentralNode()
			aPosition = [ This.RankOfCentralVLine(),
				      This.RankOfCentralHLine() ]
			return  aPosition
		ok

		def CentralNodePosition()
			return This.PositionOfCentralNode()
	
	def CentralNode()
		If This.HasCentralNode()
			return This.Node( This.RankOfCentralNode() )
		else
			StzRaise("The grid has no central Node!")
		ok

	def RankOfCentralNode()
		return This.RankOfNode( This.RankOfCentralVLine(),
					This.RankOfCentralHLine() )

	def CenterRank()
		return This.RankOfCentralNode()

	def RankOfCenter()
		return This.RankOfCentralNode()

	def RankOfNode(nVLine, nHLine)
		return This.NumberOfNodesPerHLine() * (nHLine - 1) + nVLine

	def Center()
		if This.HasCentralNode()
			return This.CentralNode()
		else
			return This.CentralRegion()
		ok

	def Diagonal()
		if This.NumberOfVLines() = This.NumberOfHLines()
			aResult = []
			for i=1 to This.NumberOfVLines()
				aResult + This.NodeAtPosition(i,i)
			next
			return aResult
		ok

	def Diagonal1()
		if This.NumberOfVLines() = This.NumberOfHLines()
			aResult = []
			for i=1 to This.NumberOfVLines()
				aResult + This.NodeAtPosition(i,i)
			next
			return aResult
		ok

	def Diagonal2()
		if This.NumberOfVLines() = This.NumberOfHLines()
			aResult = []
			for i = 1 to This.NumberOfHLines()
				aResult + This.NodeAtPosition( This.NumberOfHLines()-i+1, i )
			next
			return aResult
		ok

	  #-----------------------------------------#
	 #     SETTING Nodes, HLines, & VLines     #
	#-----------------------------------------#			

	def SetNode(nVLine, nHLine, pValue)

		if nVLine = :FirstVLine
			nVLine = 1

		but nVLine = :LastVLine
			nVLine = This.NumberOfVLines()

		but nVLine = :CentralVLine
			nVLine = This.RankOfCentralVLine() // TODO

		but nVLine = :AnyVLine
			nVLine = random( This.NumberOfVLines() )
		ok

		if nHLine = :FirstHLine
			nHLine = 1

		but nHLine = :LastHLine
			nHLine = This.NumberOfHLines()

		but nHLine = :CentralHLine
			nHLine = This.RankOfCentralHLine() // TODO

		but nHLine = :AnyHLine
			nHLine = random( This.NumberOfHLines() )
		ok

		// Setting the Node
		This.Content()[nHLine][nVLine] = pValue

	def SetCentralNode(pNode)
		if This.HasCentralNode()
			This.SetNode( :CentralVLine, :CentralHLine, pNode)
		else
			StzRaise("The grid has no central Node!")
		ok

	def SetNodeAtRank(n, pValue)
		aPosition = PositionOfNode(n)
		nVLine = aPosition[1]
		nHLine = aPosition[2]
		This.SetNode( nVLine, nHLine, pValue)

	def SetHLine(nHLine, paHLine)
		for nVLine = 1 to NumberOfVLines()
			if nVLine <= len(paHLine)
				cHLine = paHLine[nVLine]
			else
				cHLine = NULL
			ok
			This.SetNode(nVLine, nHLine, cHLine)
		next

	def SetHLineSection(nHLine, nStart, nEnd, paHLine)
		// TODO

	def SetHLineStartingFrom(nHLine, nStart, paHLine)
		// TODO

	def SetHLineEndingAt(nHLine, nEnd, paHLine)
		// TODO

	def SetVLine(nVLine, paVLine)
		for nHLine = 1 to This.NumberOfHLines()
			if nHLine <= len(paVLine)
				cVLine = paVLine[nHLine]
			else
				cVLine = NULL
			ok
			This.SetNode(nVLine, nHLine, cVLine)
		next
	
	def SetVLineSection(nVLine, nStart, nEnd, paVLine)
		// TODO

	def SetVLineStartingFrom(nVLine, nStart, paVLine)
		// TODO

	def SetVLineEndingAt(nVLine, nEnd, paVLine)
		// TODO

	def SetCentralRegion(paNodes)
		if This.HasCentralRegion()
			aPositions = This.CentralRegion()
			for i = 1 to len( aPositions )
				nVLine = aPositions[i][1]
				nHLine = aPositions[i][2]
				This.SetNode(nVLine, nHLine, paNodes[i])
			next i
		
		else
			StzRaise("The grid has no central region!")
		ok

	def SetCenter(pNode)
		aPositions = []
		if This.HasCentralNode()
			aPositions + This.CentralNodePosition()

		else
			// HasCentralRegion = TRUE
			aPositions = This.CentralRegion() // Should be CentralRegionPositions()
		ok

		for i = 1 to len(aPositions)
			nVLine = aPositions[i][1]
			nHLine = aPositions[i][2]
			This.SetNode(nVLine, nHLine, pNode)
		next

  	  #----------------------------------------#
	 #     SWAP AND REVERSE LINES & NODES     #
	#----------------------------------------#

	def SwapLines()
		/*
			A 1 E		A B C
			B 2 F	  =>	1 2 3
			C 3 G		E F G
		*/

		aVLines = This.VLines()

		for i = 1 to This.NumberOfHLines()
			This.SetHLine(i, aVLines[i])
		next

	def SwapLinesQ()
		This.SwapLines()
		return This

	def ReverseHLines()
		/*
			1 2 3		7 8 9
			4 5 6	  =>	4 5 6
			7 8 9		1 2 3
		*/

		@aContent = StzListQ( This.HLines() ).Reversed()

	def ReverseHLinesQ()
		This.ReverseHLines()
		return This

	def ReverseVLines()
		/*
			1 2 3		3 2 1
			4 5 6	  =>	6 5 4
			7 8 9		9 8 7
		*/

		#TODO
		StzRaise("TODO feature!")

	def ReverseVLinesQ()
		This.ReverseVLines()
		return This

	def ReverseNodesInHLines()
		/*
			1 2 3		3 2 1
			4 5 6	  =>	6 5 4
			7 8 9		9 8 7
		*/

		#TODO

	def ReverseNodesInHLinesQ()
		This.ReverseHLines()
		return This

	def ReverseNodesInVLines()
		/*
			1 2 3		7 8 9
			4 5 6	  =>	4 5 6
			7 8 9		1 2 3
		*/
		n = 0
		for vLine in This.VLines()
			n++
			This.SetVLine( n, (StzListQ( vLine ).Reversed()) )
		next

	def ReverseNodesInVLinesQ()
		This.ReverseNodesInVLines()
		return This

	def ReverseNodes()
		/*
			1 2 3		9 8 7
			4 5 6	  =>	6 5 4
			7 8 9		3 2 1
		*/

		// TODO

	def ReverseNodesQ()
		This.ReverseNodes()
		return This

	  #-----------------------------------#
	 #     TURN GRID TO LEFT & RIGHT     #
	#-----------------------------------#

	def TurnToLeft()
		/*
			1 2 3		3 6 9
			4 5 6	  =>	2 5 8
			7 8 9		1 4 7
		*/

		#TODO

	def TurnToLeftQ()
		This.TurnToLeft()
		return This

	def TurnToRight()
		/*
			1 2 3		7 4 1
			4 5 6	  =>	8 5 2
			7 8 9		9 6 3
		*/

		#TODO

	def TurnToRightQ()
		This.TurnToRight()
		return This

	def TurnToLeftNTimes(n)
		for i = i to n
			This.TurnToLeft()
		next

	def TurnToLeftNTimesQ(n)
		This.TurnToLeftNTimes(n)
		return This

	def TurnToRightNTimes(n)
		for i = i to n
			This.TurnToRight()
		next

	def TurnToRightNTimesQ(n)
		This.TurnToRightNTimes(n)
		return This

	  #---------------------------------------#
	 #     POPULATING THE GRID WITH DATA     #
	#---------------------------------------#

	def PopulateAllWith(pValue)
		// TODO

	def PopulateAllWithQ(pValue)
		This.PopulateAllWith(pValue)
		return This

	  #----------------------------------------#
	 #     SHOWING GRID, HLines, & VLines     #
	#----------------------------------------#	

	def ShowHLine(n)
		if n = :First
			n = 1
		but n = :Last
			n = This.NumberOfHLines()

		ok

		cStr = ""
		if @bShowRanks = TRUE
			cStr = "" +
			StzCounterQ([
				:StartAt = 1,
				:WhenYouReach = 10,
				:RestartAt = 0,
				:Step = 1 ]).
			CountingTo( This.NumberOfVLines() )[n] + SingleSpace()
		ok

		for i = 1 to This.NumberOfVLines()
			cStr += "" + This.HLine(n)[i]

			if i < This.NumberOfVLines()
				cStr += SingleSpace()
			ok
		next
		? cStr

		#< @FuntionMisspelledForm

		def ShwoHLine(n)
			This.ShowHLine(n)

		#>

	def ShowVLine(n)
		if n = :FirstOne
			n = 1
		but n = :LastOne
			n = This.NumberOfVLines()

		ok

		cStr = ""
		if @bShowRanks = TRUE
			cStr = "" + This.NumberedVLine(n)[1] + NL
		ok

		for i = 1 to This.NumberOfHLines()
			cStr += @@( This.VLine(n)[i] )

			if i < This.NumberOfHLines()
				cStr += NL
			ok
		next
		? cStr

		#< @FuntionMisspelledForm

		def ShwoVLine(n)
			This.ShowVLine(n)

		#>

	def Show()
		if @bShowRanks = TRUE
			aTemp = []

			oCounter = new stzCounter([
				:StartAt=1,
				:WhenYouReach = 10,
				:RestartAt = 1,
				:Step = 1 ])

			aTemp = oCounter.CountingTo( This.NumberOfVLines() )

			cStr = DoubleSpace()
			for j = 1 to len(aTemp)
				cStr += ""+ aTemp[j]
				if j < len(aTemp)
					cStr += SingleSpace()
				ok
			next
	
			? cStr
		ok

		if @bShowCenter = TRUE
			This.SetCenter("+")
		ok

		for j = 1 to This.NumberOfHLines()
			This.ShowHLine(j)
		next
		? ""
		
		#< @FuntionMisspelledForm

		def Shwo()
			This.Show()

		#>

	def ShowXT(paOptions) // TODO
		# :ShowCenter, :ShowRanks

		StzRaise("TODO")

		#< @FuntionMisspelledForm

		def ShwoXT(paOptions)
			This.ShowXT(paOptions)

		#>

	def ShowRegion(paRegion)
		// TODO

		#< @FuntionMisspelledForm

		def ShwoRegion(paRegion)
			This.ShowRegion(paRegion)

		#>

	def ShowRegionStroke(paRegion)
		// TODO

		#< @FuntionMisspelledForm

		def ShwoRegionStroke(paRegion)
			This.ShowRegionStroke(paRegion)

		#>

	def ShowRegionCenter(paRegion)
		// TODO

		#< @FuntionMisspelledForm

		def ShwoRegionCenter(paRegion)
			This.ShowRegionCenter(paRegion)

		#>

	  #------------------#
	 #     Sections     #
	#------------------#

	def Section( paNode1, paNode2 )
		// TODO

	  #-----------------#
	 #     REGIONS     #
	#-----------------#

	def Region(paNode1, paNode2)
		aRegion = []

		nVLine1 = paNode1[1]
		nHLine1 = paNode1[2]

		nVLine2 = paNode2[1]
		nHLine2 = paNode2[2]

		for j = nHLine1 to nHLine2
			for i = nVLine1 to nVLine2
				aRegion + [ i, j ]
			next i
		next j

		return aRegion

	def RegionPositions(paPosition1, paPosition2)
		return This.Region(paPosition1, paPosition2)

	def RegionNumberOfNodes(paPosition1, paPosition2)
		return len( This.RegionPositions(paPosition1, paPosition2) )

	def RegionNodes(paPosition1, paPosition2)
		aResult = []
		aPositions = This.RegionPositions(paPosition1, paPosition2)

		for i = 1 to len(aPositions)
			nVLine = aPositions[i][1]
			nHLine = aPositions[i][2]
			aResult + This.NodeAtPosition(nVLine,nHLine)
		next

		return aResult

	def CentralRegion()
		aPositions = []

		if This.HasCentralRegion()
			aPositions = This.Region(
				[ (This.NumberOfVLines() / 2) , (This.NumberOfHLines() / 2) ],
				[ (This.NumberOfVLines() / 2) + 1 , (This.NumberOfHLines() / 2) + 1 ])
		else
			StzRaise("The grid has no central region!")
		ok
		return aPositions

	def CentralRegionPositions()
		return This.CentralRegion()

	def CentralRegionNumberOfNodes()
		return len( This.CentralRegion() ) // 4 or 1

	def CentralRegionNodes()
		aResult = []
		aPositions = This.CentralRegionPositions()

		for i = 1 to len(aPositions)
			nVLine = aPositions[i][1]
			nHLine = aPositions[i][2]
			aResult + This.NodeAtPosition(nVLine, nHLine)
		next

		return aResult

	def RegionCentralNode()
		// TODO

	def IsRegionHasCenter()
		// TODO

	  #-------------------#
	 #     SPLITTING     #
	#-------------------#

	def SplitVerticallyBeforeVLine(n)
		// TODO

	def SplitVerticallyAfterVLine(n)
		// TODO

	def SplitVerticallyAndRandomly()
		// TODO

	def SplitHorizontallyBeforeHLine(n)
		// TODO

	def SplitHorizontallyAfterHLine(n)
		// TODO

	def SplitHorizontallyAndRandomly()
		// TODO

	  #-----------------------------------#
	 #     DESIGNING SHAPES USING PEN   #
	#----------------------------------#

	def StartPenAt(pNode)
		// TODO

	def MovePenRight(n)
		// TODO

	def MovePenDown(n)
		// TODO

	def MovePenLeft(n)
		// TODO

	def MovePenUp(n)
		// TODO

	  #---------------#
	 #     LAYERS    #
	#---------------#

	def Layers()
		return aLayers

	def SetCurrentLayer(n)
		CurrentLayer = n

	def SetOpacity(n)
		if n = 0 or n = 1
			Opacity = n
		else
			StzRaise("Opacity can be eighter 0 or 1!")
		ok

	def Opacity()
		return @nOpacity

	def IsOpaque()
		if This.Opacity() = 1
			return TRUE
		else
			return FALSE
		ok

	def IsTransparent()
		if Opacity() = 0
			return TRUE
		else
			return FALSE
		ok

	def RemoveLayer(n)
		del(@aLayers, n)

	def RemoveCurrentLayer()
		del(@aLayers, CurrentLayer() )

	def MoveLayerToLevel(n)
		// TODO

	def MergeLayers(paLayers)
		// TODO

	def SetSuperpositionMode(pcFeature)
		// TODO

	  #------------------------------------------#
	 #  REPLACING ALL NODES WITH A GIVEN VALUE  #
	#------------------------------------------#

	def ReplaceAll(pcValue)
		if isList(pcValue) and Q(pcValue).IsWithOrByNamedParam()
			pcValue = pcValue[2]
		ok

		for h = 1 to This.NumberOfHLines()
			for v = 1 to this.NumberOfVLines()
				This.Content()[h][v] = pcValue
			next
		next

		def ReplaceAllQ(pcValue)
			This.ReplaceAll(pcValue)
			return This

	  #------------------------------------------#
	 #  FILLING THE GRID WITH A LIST OF ITEMS   #
	#------------------------------------------#
	#NOTE: Currently, only adding a list of chars is allowed

	def FillWith(paList)
		This.FillWithXT(paList, :Direction = :Horizontally)

		def FillWithQ(paList)
			This.FillWith(paList)
			return This

	def FillWithXT(paList, pcDirection)

		# Checking params

		if NOT ( isList(paList) and Q(paList).IsListOfChars() )
			StzRaise("Incorrect param type! paList must be a list of chars.")
		ok

		if isList(pcDirection) and
		   Q(pcDirection).IsOneOfTheseNamedParams([ :Direction, :Going ])

			pcDirection = pcDirection[2]
		ok

		if NOT ( isString(pcDirection) and Q(pcDirection).IsOneOfThese([ :Horizontally, :Vertically ]) )
			StzRaise("Incorrect param! pcDirection must be a string equal to :Horizontally, :Vertically, or :Default.")
		ok

		# Doing the job

		nLen = len(paList)

		aTemp = []

		if pcDirection = :Default or pcDirection = :Horizontally

			aTemp = []
			nV = This.NumberOfVLines()

			for i = 1 to nLen step nV

				nEnd = i + nV - 1
				if i = nLen
					nEnd = nLen
				ok

				aTemp + Q(paList).Section( i, nEnd)
			next

			aTemp = StzListOfListsQ(aTemp).Extended()

			This.SetGrid(aTemp)

		but pcDirection = :Vertically
			StzRaise("Feature unavailable in this release!")

		ok

		#< @FunctionFluentForm

		def FillWithXTQ(paList, pcDirection)
			This.FillWithXT(paList, pcDirection)
			return This

		#>

		#< @FunctionAlternativess

		def FillWithD(paList, pcDirection)
			This.FillWithXT(paList, pcDirection)

			def FillWithDQ(paList, pcDirection)
				This.FillWithD(paList, pcDirection)
				return This

		#>

	  #-----------#
	 #   MISC.   #
	#-----------#

	def IsAGrid() # required by stzChainOfTruth
		return TRUE

	def StzType()
		return :stzgrid

	def SetGridSize(pnNumberOfVLines, pnNumberOfHLines) #TODO
		/* ... */
		StzRaise("Inexistant feature in this release!")

	def Extend() #TODO
		/* ... */
		StzRaise("Inexistant feature in this release!")

	def Shrink() #TODO
		/* ... */
		StzRaise("Inexistant feature in this release!")
