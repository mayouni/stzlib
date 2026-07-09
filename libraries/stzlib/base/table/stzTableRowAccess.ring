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

	def Row(_n_)

		if isString(_n_)

			if StzFindFirst([ :First, :FirstRow ], _n_) > 0
				_n_ = 1

			but StzFindFirst([ :Last, :LastRow ], _n_) > 0
				_n_ = This.NumberOfRows()

			ok
		ok

		_aResult_ = This.RowSection( _n_, 1, This.NumberOfCols() )
		return _aResult_

		#< @FunctionFluentForm

		def RowQ(_n_)
			return This.RowQRT(_n_, :stzList)

		def RowQRT(_n_, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Row(_n_) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Row(_n_) )

			on :stzListOfStrings
				return new stzListOfNumbers( This.Row(_n_) )

			on :stzListOfLists
				return new stzListOfLists( This.Row(_n_) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Row(_n_) )

			on :stzListOfHashTables
				return new stzListOfHashTables( This.Row(_n_) )

			on :stzListOfObjects
				return new stzListOfObjects( This.Row(_n_) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def RowN(_n_)
			return This.Row(_n_)

			def RowNQ(_n_)
				return This.RownQRT(_n_, :stzList)

			def RowNQRT(_n_, pcReturnType)
				return This.CellsInRowQRT(_n_, pcReturnType)

		def NthRow(_n_)
			return This.Row(_n_)

			def NthRowQ(_n_)
				return This.NthRowQRT(_n_, :stzList)

			def NthRowQRT(_n_, pcReturnType)
				return This.CellsInRowQRT(_n_, pcReturnType)

		def CellsInRow(_n_)
			return This.Row(_n_)

			def CellsInRowQ(_n_)
				return This.CellsInRowQRT(_n_, :stzList)

			def CellsInRowQRT(_n_, pcReturnType)
				return This.CellsInRowQRT(_n_, pcReturnType)

		def CellsInRowN(_n_)
			return This.Row(_n_)

			def CellsInRowNQ(_n_)
				return This.CellsInRowNQRT(_n_, :stzList)

			def CellsInRowNQRT(_n_, pcReturnType)
				return This.CellsInRowQRT(_n_, pcReturnType)

		def CellsInNthRow(_n_)
			return This.Row(_n_)

			def CellsInNthRowQ(_n_)
				return This.CellsInNthRowQRT(_n_, :stzList)

			def CellsInNthRowQRT(_n_, pcReturnType)
				return This.CellsInRowQRT(_n_, pcReturnType)
		#>

	  #----------------------------------#
	 #  GETTING THE CELLS OF MANY ROWS  #
	#----------------------------------#

	def CellsInRows(panRows)
		if NOT ( isList(panRows) and Q(panRows).IsListOfNumbers() )
			StzRaise("Incorrect param type! panRows must be a list of numbers.")
		ok

		_aResult_ = This.TheseCells(RowsAsPositions(panRows))
		return _aResult_

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
		if len(@aContent) = 0
			return 0
		else
			return len(@aContent[1][2])
		ok

		def Size()
			return NumberOfRows()

	  #------------------------------#
	 #   GETTING THE LIST OF ROWS   #
	#------------------------------#

	def Rows()
		_nRows_   = This.NumberOfRows()
		_aResult_ = []

		for i = 1 to _nRows_
			_aResult_ + This.RowN(i)
		next

		return _aResult_

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

	def RowZ(_n_)
		_aResult_ = RowQ(_n_).AssociatedWith( This.CellsInRowAsPositions(_n_) )
		return _aResult_

		#< @FunctionFluentForm

		def RowZQ(_n_)
			return This.RowZQRT(p, :stzList)

		def RowZQRT(_n_, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.RowZ(_n_) )

			on :stzListOfPairs
				return new stzListOfPairs( This.RowZ(_n_) )

			on :stzListOfLists
				return new stzListOfLists( This.RowZ(_n_) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsAndPositionsInRow(_n_)
			return This.RowZ(_n_)

			def CellsAndPositionsInRowQ(_n_)
				return This.CellsAndPositionsInRowNQRT(_n_, :stzList)

			def CellsAndPositionsInRowQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		def CellsInRowZ(_n_)
			return This.RowZ(_n_)

			def CellsInRowZQ(_n_)
				return This.CellsInRowZQRT(_n_, :stzList)

			def CellsInRowZQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		def CellsInRowNAndTheirPositions(_n_)
			return This.RowZ(p)

			def CellsInRowNAndTheirsPositionsQ(_n_)
				return This.CellsInRowNAndTheirsPositionsQRT(_n_, :stzList)

			def CellsInRowNAndTheirsPositionsQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		def CellsAndPositionsInRowN(_n_)
			return This.RowZ(_n_)

			def CellsAndPositionsInRowNQ(_n_)
				return This.CellsAndPositionsInRowNQRT(_n_, :stzList)

			def CellsAndPositionsInRowNQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		def CellsAndPositionsInNthRow(_n_)
			return This.RowZ(p)

			def CellsAndPositionsInNthRowQ(_n_)
				return This.CellsAndPositionsInNthRowQRT(_n_, :stzList)

			def CellsAndPositionsInNthRowQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		def CellsInNthRowAndTheirPositions(_n_)
			return This.RowZ(p)

			def CellsInNthRowAndTheirPositionsQ(_n_)
				return This.CellsInNthRowAndTheirPositionsQRT(_n_, :stzList)

			def CellsInNthRowAndTheirPositionsQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		def RowNZ(_n_)
			return This.RowZ(_n_)

			def RowNZQ(_n_)
				return This.RowNZQRT(_n_, :stzList)

			def RowNZQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

		def NthRowZ(_n_)
			return This.RowZ(_n_)

			def NtRowZQ(_n_)
				return This.NthRowZQRT(_n_, :stzList)

			def NthRowZQRT(_n_, pcReturnType)
				return This.RowZQRT(_n_, pcReturnType)

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

		_nNumberOfCols_ = This.NumberOfCols()
		_aResult_ = []

		for i = 1 to _nNumberOfCols_
			_aResult_ + [ i, pnRow ]
		next

		return _aResult_

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
		_nNumberOfCols_ = This.NumberOfCols()
		_nLenRows_ = len(panRows)

		_aResult_ = []

		for i = 1 to _nLenRows_

			for j = 1 to _nNumberOfCols_
				_aResult_ + [ j, panRows[i] ]
			next

		next

		return _aResult_

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
