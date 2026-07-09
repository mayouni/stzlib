#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLECOLUMNACCESS        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table column access subclass -- getting     #
#                  column data, positions, and names.          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableColumnAccess from stzTable

	  #===============================================#
	 #   GETTING A COLUMN DATA (IN A LIST OF CELLS)  #
	#===============================================#

	def Col(p)

		if isString(p)

			if StzFindFirst([ :First, :FirstCol, :FirstColumn ], p) > 0
				p = 1

			but StzFindFirst([ :Last, :LastCol, :LastColumn ], p) > 0
				p = This.NumberOfColumns()

			but This.HasColName(p)
				p = This.FindCol(p)
			ok
		ok

		_aResult_ = This.ColSection( p, 1, This.NumberOfRows() )

		return _aResult_

		#< @FunctionFluentForm

		def ColQ(p)
			return This.ColQRT(p, :stzList)

		def ColQRT(p, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Col(p) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Col(p) )

			on :stzListOfStrings
				return new stzListOfStrings( This.Col(p) )

			on :stzListOfLists
				return new stzListOfLists( This.Col(p) )

			on :stzListOfPairs
				return new stzListOfPairs( This.Col(p) )

			on :stzListOfHashTables
				return new stzListOfHashTables( This.Col(p) )

			on :stzListOfObjects
				return new stzListOfObjects( This.Col(p) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def Column(p)
			return This.Col(p)

			def ColumnQ(p)
				return This.ColumnQRT(p, :stzList)

			def ColumnQRT(p, pcReturnType)
				return This.ColQRT(p, pcReturnType)

		def ColumnData(p)
			return This.Col(p)

			def ColumnDataQ(p)
				return This.ColumnQRT(p, :stzList)

			def ColumnDataQRT(p, pcReturnType)
				return This.ColQRT(p, pcReturnType)

		def ColData(p)
			return This.Col(p)

			def ColDataQ(p)
				return This.ColumnQRT(p, :stzList)

			def ColDataQRT(p, pcReturnType)
				return This.ColQRT(p, pcReturnType)

		def CellsInCol(p)
			return This.Col(p)

			def CellsInColQ(p)
				return This.CellsInColQRT(p, :stzList)

			def CellsInColQRT(p, pcReturnType)
				return This.CellsInColQRT(p, pcReturnType)

		def CellsInColumn(p)
			return This.Col(p)

			def CellsInColumnQ(p)
				return This.CellsInColumnQRT(p, :stzList)

			def CellsInColumnQRT(p, pcReturnType)
				return This.CellsInColumnQRT(p, pcReturnType)

		#>

	  #-----------------------------------------------------#
	 #  GETTING THE LIST OF CELLS IN THE PROVIDED COLUMNS  #
	#-----------------------------------------------------#

	def CellsInCols(paCols)

		if NOT ( isList(paCols) and
			Q(paCols).IsListOfNumbersOrStrings() and
			This.AreColumnsIdentifiers(paCols))

			StzRaise("Incorrect param type! paCols must be a list of string containing existing columns names.")
		ok

		_nLen_ = len(paCols)

		_aResult_ = []
		for i = 1 to _nLen_
			_aResult_ + This.CellsInCol(paCols[i])
		next

		_aResult_ = Q(_aResult_).Flattened()
		return _aResult_

	  #------------------------------------------------#
	 #  GETTING THE COLUMN NAME AND THE COLUMN CELLS  #
	#------------------------------------------------#

	def ColXT(p)
		_aResult_ = [ This.ColName(p) ]

		_aCells_ = This.Col(p)
		_nLen_ = len(_aCells_)

		for i = 1 to _nLen_
			_aResult_ + _aCells_[i]
		next

		return _aResult_

		#< @FunctionFluentForm

		def ColXTQ(p)
			return This.ColXTQRT(p, :stzList)

		def ColXTQRT(p, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.ColXT(p) )

			on :stzListOfPairs
				return new stzListOfPairs( This.COlXT(p) )

			on :stzListOfLists
				return new stzListOfLists( This.ColXT(p) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def ColumnXT(p)
			return This.ColXT(p)

			def ColumnXTQ(p)
				return This.ColumnXTQRT(p, :stzList)

			def ColumnXTQRT(p, pcReturnType)
				return This.ColXTQRT(p, pcReturnType)

		def CellsInColXT(p)
			return This.ColXT(p)

			def CellsInColXTQ(p)
				return This.CellsInColXTQRT(p, :stzList)

			def CellsInColXTQRT(p, pcReturnType)
				return This.CellsInColXTQRT(p, pcReturnType)

		def CellsInColumnXT(p)
			return This.ColXT(p)

			def CellsInColumnXTQ(p)
				return This.CellsInColumnXTQRT(p, :stzList)

			def CellsInColumnXTQRT(p, pcReturnType)
				return This.CellsInColumnXTQRT(p, pcReturnType)

		#>

	  #=======================#
	 #  GETTING COLUMN NAME  #
	#=======================#

	def NthColName(_n_)
		if isString(_n_)

			if StzFindFirst([ :First, :FirstCol, :FirstColumn ], _n_) > 0
				_n_ = 1

			but StzFindFirst([ :Last, :LastCol, :LastColumn ], _n_) > 0
				_n_ = This.NumberOfColumns()

			else
				StzRaise("syntax error in (" + _n_ + ")! Allowed values are :First or :Last ( or :FirstCol or :LastCol).")

			ok
		ok

		_cResult_ = This.ColNames()[_n_]

		return _cResult_

		def NthColumnName(_n_)
			return This.NthColName(_n_)

	  #------------------------------------------------#
	 #  GETTING THE LIST OF CELLS IN THE NTH COLUMN   #
	#------------------------------------------------#

	def NthCol(_n_)
		return This.Col(_n_)

		def NthColumn(_n_)
			return This.NthCol(_n_)

		def CellsInNthCol(_n_)
			return This.NthCol(_n_)

		def CellsInNthColumn(_n_)
			return This.NthCol(_n_)

		def NthColData(_n_)
			return This.NthCol(_n_)

		def NthColumnData(_n_)
			return This.NthCol(_n_)

	  #-------------------------------------------------------------------------#
	 #  GETTING A LIST CONTAINING THE NAME OF NTH COLUMN ALONG WITH ITS CELLS  #
	#-------------------------------------------------------------------------#

	def NthColXT(_n_)
		if isString(_n_)
			if _n_ = :first or _n_ = :FirstCol or _n_ = :FirstColumn
				_n_ = 1

			but _n_ = :Last or _n_ = :LastCol or _n_ = :LastColumn
				_n_ = This.NumberOfCol()
			ok
		ok

		return This.ColXT(_n_)

		def NthColumnXT(_n_)
			return This.ColXT(_n_)

		def CellsInNthColXT(_n_)
			return This.ColXT(_n_)

		def CellsInNthColumnXT(_n_)
			return This.ColXT(_n_)

		def CellsInNthColAndTheirPositions(_n_)
			return This.ColXT(_n_)

		def CellsInColNAndTheirPositions(_n_)
			return This.ColXT(_n_)

		def CellsInNthColumnAndTheirPositions(_n_)
			return This.ColXT(_n_)

		def CellsInColumnNAndTheirPositions(_n_)
			return This.ColXT(_n_)

	  #----------------------------------------#
	 #  GETTING THE NAME OF THE FIRST COLUMN  #
	#========================================#

	def FirstColName()
		return This.NthColName(1)

		def FirstColumnName()
			return This.FirstColName()

	  #------------------------------------------------------#
	 #   GETTING FIRST COLUMN DATA (THE LIST OF ITS CELLS)  #
	#------------------------------------------------------#

	def FirstCol()
		return This.NthCol(1)

		def FirstColumn()
			return This.FirstCol()

		def FirstColData()
			return This.FirstCol()

		def FirstColumnData()
			return This.FirstCol()

	  #---------------------------------------------------------------------------#
	 #  GETTING A LIST CONTAINING THE NAME OF FIRST COLUMN ALONG WITH IST CELLS  #
	#---------------------------------------------------------------------------#

	def FirstColXT()
		return This.NthCOlXT(1)

		def FirstColumnXT()
			return This.FirstColXT()


	  #---------------------------------------#
	 #  GETTING THE NAME OF THE LAST COLUMN  #
	#=======================================#

	def LastColName()
		return This.NthColName(This.NumberOfCols())

		def LastColumnName()
			return This.LastColName()

	  #-----------------------------------------------------#
	 #   GETTING LAST COLUMN DATA (THE LIST OF ITS CELLS)  #
	#-----------------------------------------------------#

	def LastCol()
		return This.NthCol(This.NumberOfCols())

		def LastColumn()
			return This.LastCol()

		def LastColData()
			return This.LastCol()

		def LastColumnData()
			return This.LastCol()

	  #--------------------------------------------------------------------------#
	 #  GETTING A LIST CONTAINING THE NAME OF LAST COLUMN ALONG WITH IST CELLS  #
	#--------------------------------------------------------------------------#

	def LastColXT()
		return This.NthCOlXT(This.NumberOfCols())

		def LastColumnXT()
			return This.LastColXT()

	  #=======================#
	 #  GETTING COLUMN NAME  #
	#=======================#

	def ColName(_n_)
		if isString(_n_)
			if This.HasColName(_n_)
				return _n_
			else
				StzRaise("Incorrect column name! The name you provided does not exist.")
			ok
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nLenCols_ = len(@aContent)

		if _n_ < 1 or _n_ > _nLenCols_
			StzRaise("Index out of range! n must is not a valid number of column.")
		ok

		_cResult_ = @aContent[_n_][1]
		return _cResult_

		def ColNameQ(_n_)
			return new stzString( This.ColName(_n_) )

		def ColumnName(_n_)
			return This.ColName(_n_)

			def ColumnNameQ(_n_)
				return new stzString( This.ColumnName(_n_) )

	  #--------------------------------------------------------#
	 #  GETTING CELLS AND THEIR POSITIONS IN A GIVEN COLUMN   #
	#--------------------------------------------------------#

	def CellsAndPositionsInCol(p)
		_aResult_ = This.ColQ(p).AssociatedWith( This.CellsInColAsPositions(p) )

		return _aResult_

		#< @FunctionFluentForm

		def CellsAndPositionsInColQ(p)
			return This.CellsAndPositionsInColQRT(p, :stzList)

		def CellsAndPositionsInColQRT(p, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.CellsAndPositionsInCol(p) )

			on :stzListOfPairs
				return new stzListOfPairs( This.CellsAndPositionsInCol(p) )

			on :stzListOfLists
				return new stzListOfLists( This.CellsAndPositionsInCol(p) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def CellsAndPositionsInColumn(p)
			return This.CellsAndPositionsInCol(p)

			def CellsAndPositionsInColumnQ(p)
				return This.CellsAndPositionsInColumnQRT(p, :stzList)

			def CellsAndPositionsInColumnQRT(p, pcReturnType)
				return This.CellsAndPositionsInColQRT(p, pcReturnType)

		def ColZ(p)
			return This.CellsAndPositionsInCol(p)

			def ColZQ(p)
				return This.ColZQRT(p, :stzList)

			def ColZQRT(p, pcReturnType)
				return This.CellsAndPositionsInColQRT(p, pcReturnType)

		def CellsInColZ(p)
			return This.CellsAndPositionsInCol(p)

			def CellsInColZQ(p)
				return This.ColZQRT(p, :stzList)

			def CellsInColZQRT(p, pcReturnType)
				return This.CellsAndPositionsInColQRT(p, pcReturnType)

		#>

	  #----------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF A GIVEN COLUMN   #
	#----------------------------------------------------------#

	def ColAsPositions(pCol)
		if NOT This.IsCol(pCol)
			StzRaise("Incorrect param value! " + @@(pCol) + " is not a valid column identifier.")
		ok

		_nCol_ = This.ColToColNumber(pCol)

		_nNumberOfRows_ = This.NumberOfRows()

		_aResult_ = []

		for i = 1 to _nNumberOfRows_
			_aResult_ + [ _nCol_, i]
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def ColPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColumnPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsInColPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColCellsAsPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsAsPositionsInCol(pCol)
			return This.ColAsPositions(pCol)

		def CellsInColAsPositions(pCol)
			return This.ColAsPositions(pCol)

		#--

		def CellsInColumnAsPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsInColumnPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColumnCellsAsPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsAsPositionsInColumn(pCol)
			return This.ColAsPositions(pCol)

		def ColumnAsPositions(pCol)
			return This.ColAsPositions(pCol)

		#==

		def PositionsOfCellsInCol(pCol)
			return This.ColAsPositions(pCol)

		def PositionsOfCellsInColumn(pCol)
			return This.ColAsPositions(pCol)

		#==

		def CellsToColAsPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsToColPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColCellsToPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsToPositionsInCol(pCol)
			return This.ColAsPositions(pCol)

		def ColToPositions(pCol)
			return This.ColAsPositions(pCol)

		#--

		def CellsInColumnToPositions(pCol)
			return This.ColAsPositions(pCol)

		def ColumnCellsToPositions(pCol)
			return This.ColAsPositions(pCol)

		def CellsToPositionsInColumn(pCol)
			return This.ColAsPositions(pCol)

		def ColumnToPositions(pCol)
			return This.ColAsPositions(pCol)

		#>

	  #--------------------------------------------------------#
	 #   GETTING THE POSITIONS OF THE CELLS OF MANY COLUMNS   #
	#--------------------------------------------------------#

	def ColsAsPositions(paCols)
		_nLen_ = len(paCols)
		_anColNumbers_ = This.TheseColsAsNumbers(paCols)
		_aResult_ = []

		for i = 1 to _nLen_
			_aCellsPos_ = This.CellsInColAsPositions(_anColNumbers_[i])
			_nLenCells_ = len(_aCellsPos_)

			for j = 1 to _nLenCells_
				_aResult_ + _aCellsPos_[j]
			next
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def CellsInColsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColsCellsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColsToCellsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsAsPositionsInCols(paCols)
			return This.ColsAsPositions(paCols)

		def CellsInColsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		#--

		def CellsInColumnsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsInColumnsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsCellsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsToCellsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsAsPositionsInColumns(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		#==

		def PositionsOfCellsInCols(paCols)
			return This.ColsAsPositions(paCols)

		def PositionsOfCellsInColumns(paCols)
			return This.ColsAsPositions(paCols)

		#==

		def CellsToColsAsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsToColsPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColsCellsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsToPositionsInCols(pCol)
			return This.ColsAsPositions(pCol)

		def ColsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		#--

		def CellsInColumnsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsCellsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		def CellsToPositionsInColumns(paCols)
			return This.ColsAsPositions(paCols)

		def ColumnsToPositions(paCols)
			return This.ColsAsPositions(paCols)

		#>
