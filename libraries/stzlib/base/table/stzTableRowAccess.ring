#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLEROWACCESS           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table row access subclass -- getting row    #
#                  data, positions, first/last row.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableRowAccess from stzTable

	  #==============================#
	 #  GETTING THE CELLS OF A ROW  #
	#==============================#

	def Row(n)

		if isString(n)

			if StzFind([ :First, :FirstRow ], n) > 0
				n = 1

			but StzFind([ :Last, :LastRow ], n) > 0
				n = This.NumberOfRows()

			ok
		ok

		aResult = This.RowSection( n, 1, This.NumberOfCols() )
		return aResult

		#< @FunctionFluentForm

		def RowQ(n)
			return This.RowQRT(n, :stzList)

		def RowQRT(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Row(n) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Row(n) )

			on :stzListOfStrings
				return new stzListOfNumbers( This.Row(n) )

			on :stzListOfLists
				return new stzListOfLists( This.Row(n) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Row(n) )

			on :stzListOfHashTables
				return new stzListOfHashTables( This.Row(n) )

			on :stzListOfObjects
				return new stzListOfObjects( This.Row(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def RowN(n)
			return This.Row(n)

			def RowNQ(n)
				return This.RownQRT(n, :stzList)

			def RowNQRT(n, pcReturnType)
				return This.CellsInRowQRT(n, pcReturnType)

		def NthRow(n)
			return This.Row(n)

			def NthRowQ(n)
				return This.NthRowQRT(n, :stzList)

			def NthRowQRT(n, pcReturnType)
				return This.CellsInRowQRT(n, pcReturnType)

		def CellsInRow(n)
			return This.Row(n)

			def CellsInRowQ(n)
				return This.CellsInRowQRT(n, :stzList)

			def CellsInRowQRT(n, pcReturnType)
				return This.CellsInRowQRT(n, pcReturnType)

		def CellsInRowN(n)
			return This.Row(n)

			def CellsInRowNQ(n)
				return This.CellsInRowNQRT(n, :stzList)

			def CellsInRowNQRT(n, pcReturnType)
				return This.CellsInRowQRT(n, pcReturnType)

		def CellsInNthRow(n)
			return This.Row(n)

			def CellsInNthRowQ(n)
				return This.CellsInNthRowQRT(n, :stzList)

			def CellsInNthRowQRT(n, pcReturnType)
				return This.CellsInRowQRT(n, pcReturnType)
		#>

	  #----------------------------------#
	 #  GETTING THE CELLS OF MANY ROWS  #
	#----------------------------------#

	def CellsInRows(panRows)
		if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
			StzRaise("Incorrect param type! panRows must be a list of numbers.")
		ok

		aResult = This.TheseCells(RowsAsPositions(panRows))
		return aResult

	  #-----------------------#
	 #   GETTING FIRST ROW   #
	#-----------------------#

	def FirstRow()
		return This.NthRow(1)

	def FirstRowXT()
		return This.NthRowXT(1)

	  #----------------------#
	 #   GETTING LAST ROW   #
	#----------------------#

	def LastRowXT()
		return This.NthRowXT(This.NumberOfRows())

	def LastRow()
		return This.NthRow(This.NumberOfRows())

	  #--------------------------------#
	 #   GETTING THE NUMBER OF ROWS   #
	#--------------------------------#

	def NumberOfRows()
		if ring_len(@aContent) = 0
			return 0
		else
			return ring_len(@aContent[1][2])
		ok

		def Size()
			return NumberOfRows()

	  #------------------------------#
	 #   GETTING THE LIST OF ROWS   #
	#------------------------------#

	def Rows()
		nRows   = This.NumberOfRows()
		aResult = []

		for i = 1 to nRows
			aResult + This.RowN(i)
		next

		return aResult

		def RowsQ()
			return This.RowsQRT(:stzList)

		def RowsQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Rows() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Rows() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Rows() )

			on :stzListOfChars
				return new stzListOfChars( This.Rows() )

			on :stzListOfLists
				return new stzListOfLists( This.Rows() )

			on :stzListOfHashLists
				return new stzListOfHashLists( This.Rows() )

			on :stzListOfPairs
				return new stzListOfPairs( This.Rows() )

			on :stzListOfSets
				return new stzListOfSets( This.Rows() )

			on :stzListOfObjects
				return new stzListOfNumbers( This.Rows() )

			other
				StzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def AllRows() # In contrast with TheseRows(panRows)
			return This.Rows()

			def AllRowsQ()
				return This.AllRowsQRT(:stzList)

			def AllRowsQRT(pcReturnType)
				return This.RowsQRT(pcReturnType)

		#>

	  #-----------------------------------------------------#
	 #   GETTING CELLS AND THEIR POSITIONS IN A GIVN ROW   #
	#-----------------------------------------------------#

	def RowZ(n)
		aResult = RowQ(n).AssociatedWith( This.CellsInRowAsPositions(n) )
		return aResult

		#< @FunctionFluentForm

		def RowZQ(n)
			return This.RowZQRT(p, :stzList)

		def RowZQRT(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.RowZ(n) )

			on :stzListOfPairs
				return new stzListOfPairs( This.RowZ(n) )

			on :stzListOfLists
				return new stzListOfLists( This.RowZ(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsAndPositionsInRow(n)
			return This.RowZ(n)

			def CellsAndPositionsInRowQ(n)
				return This.CellsAndPositionsInRowNQRT(n, :stzList)

			def CellsAndPositionsInRowQRT(n, pcReturnType)
				return This.RowZQRT(n, pcReturnType)

		def CellsInRowZ(n)
			return This.RowZ(n)

			def CellsInRowZQ(n)
				return This.CellsInRowZQRT(n, :stzList)

			def CellsInRowZQRT(n, pcReturnType)
				return This.RowZQRT(n, pcReturnType)

		def CellsInRowNAndTheirPositions(n)
			return This.RowZ(p)

			def CellsInRowNAndTheirsPositionsQ(n)
				return This.CellsInRowNAndTheirsPositionsQRT(n, :stzList)

			def CellsInRowNAndTheirsPositionsQRT(n, pcReturnType)
				return This.RowZQRT(n, pcReturnType)

		def CellsAndPositionsInRowN(n)
			return This.RowZ(n)

			def CellsAndPositionsInRowNQ(n)
				return This.CellsAndPositionsInRowNQRT(n, :stzList)

			def CellsAndPositionsInRowNQRT(n, pcReturnType)
				return This.RowZQRT(n, pcReturnType)

		def CellsAndPositionsInNthRow(n)
			return This.RowZ(p)

			def CellsAndPositionsInNthRowQ(n)
				return This.CellsAndPositionsInNthRowQRT(n, :stzList)

			def CellsAndPositionsInNthRowQRT(n, pcReturnType)
				return This.RowZQRT(n, pcReturnType)

		def CellsInNthRowAndTheirPositions(n)
			return This.RowZ(p)

			def CellsInNthRowAndTheirPositionsQ(n)
				return This.CellsInNthRowAndTheirPositionsQRT(n, :stzList)

			def CellsInNthRowAndTheirPositionsQRT(n, pcReturnType)
				return This.RowZQRT(n, pcReturnType)

		def RowNZ(n)
			return This.RowZ(n)

			def RowNZQ(n)
				return This.RowNZQRT(n, :stzList)

			def RowNZQRT(n, pcReturnType)
				return This.RowZQRT(n, pcReturnType)

		def NthRowZ(n)
			return This.RowZ(n)

			def NtRowZQ(n)
				return This.NthRowZQRT(n, :stzList)

			def NthRowZQRT(n, pcReturnType)
				return This.RowZQRT(n, pcReturnType)

		#>

	  #-------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF A GIVEN ROW   #
	#-------------------------------------------------------#

	def RowAsPositions(pnRow)
		if CheckingParams()

			if isString(pnRow)
				if pnRow = :First or pnRow = :FirstRow
					pnRow = 1

				but pnRow = :Last or pnRow = :LastRow
					pnRow = This.NumberOfRows()
				ok
			ok

			if NOT isNumber(pnRow)
				StzRaise("Incorrect param type! pnRow must be a number.")
			ok

		ok

		nNumberOfCols = This.NumberOfCols()
		aResult = []

		for i = 1 to nNumberOfCols
			aResult + [ i, pnRow ]
		next

		return aResult

		#< @Alternativefunctions

		def CellsInRowPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def RowCellsAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsAsPositionsInRow(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsInRowAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		#--

		def CellsInRowToPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def RowCellsToPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsToPositionsInRow(pnRow)
			return This.RowAsPositions(pnRow)

		#==

		def CellsInThisRowAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsInThisRowPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def ThisRowCellsAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsAsPositionsInThisRow(pnRow)
			return This.RowAsPositions(pnRow)

		#--

		def CellsInThisRowToPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def ThisRowCellsToPositions(pnRow)
			return This.RowAsPositions(pnRow)

		def CellsToPositionsInThisRow(pnRow)
			return This.RowAsPositions(pnRow)

		#--

		def RowToCellsAsPositions(pnRow)
			return This.RowAsPositions(pnRow)

		#>
	  #----------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF MANY ROWS  #
	#----------------------------------------------------#

	def RowsAsPositions(panRows)
		nNumberOfCols = This.NumberOfCols()
		nLenRows = ring_len(panRows)

		aResult = []

		for i = 1 to nLenRows

			for j = 1 to nNumberOfCols
				aResult + [ j, panRows[i] ]
			next

		next

		return aResult

		#< @FunctionAlternativeForms

		def CellsInRowsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def RowsCellsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsAsPositionsInRows(panRows)
			return This.RowsAsPositions(panRows)

		def CellsInRowsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		#--

		def CellsInRowsToPositions(panRows)
			return This.RowsAsPositions(panRows)

		def RowsCellsToPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsToPositionsInRows(panRows)
			return This.RowsAsPositions(panRows)

		#==

		def CellsInTheseRowsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsInTheseRowsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def TheseRowsCellsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsAsPositionsInTheseRows(panRows)
			return This.RowsAsPositions(panRows)

		#--

		def CellsInTheseRowsToPositions(panRows)
			return This.RowsAsPositions(panRows)

		def TheseRowsCellsToPositions(panRows)
			return This.RowsAsPositions(panRows)

		def CellsToPositionsInTheseRows(panRows)
			return This.RowsAsPositions(panRows)

		#--

		def RowsToCellsAsPositions(panRows)
			return This.RowsAsPositions(panRows)

		#>
