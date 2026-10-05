
#-------------------------#
#  SOFTANZA MATRIX CLASS  #
#-------------------------#

# TODO :Potential Future Enhancements:
# -> Remaining arithmetic calculations (Subtract, Divide, Power, Modulo)
# -> More advanced mathematical operations
# -> Machine learning-specific methods
#--> Advanced decompositions (e.g., SVD, LU)

#--

#NOTE : Bulk element operations go through the Softanza Zig engine

# Uniform transformations -- adding/multiplying all elements, or a
# whole row/column/range -- are delegated to the matrix engine via
# _UpdateRegion() -> StzEngineMatrixUpdateRegion (see stz_matrix.dll).
# This replaces the former RingFastPro updateList() dependency, which
# was removed along with every non-engine third-party dependency: the
# engine is now the single backend.

#-- Global functions

func StzMatrixQ(paMatrix)
	return new stzMatrix(paMatrix)

# Global matrix creation functions

func Diagonal1Matrix(paValues)

	_nSize_ = len(paValues)
	_aMatrix_ = []

	for i = 1 to _nSize_

		_aRow_ = []

		for j = 1 to _nSize_

			if j = 1
				_aRow_ + paValues[i]
			else
				_aRow_ + 0
			ok

		next

		_aMatrix_ + _aRow_

	next

	return _aMatrix_

func Diagonal2Matrix(paValues)

	_nSize_ = len(paValues)
	_aMatrix_ = []
    
	for i = 1 to _nSize_

		_aRow_ = []

		for j = 1 to _nSize_

			if j = _nSize_ - i + 1
				_aRow_ + paValues[i]
			else
				_aRow_ + 0
			ok

		next

		_aMatrix_ + _aRow_

	next

	return _aMatrix_

func ConstantMatrix(paParams)

	_nValue_ = paParams[1]
	_aSize_ = paParams[2]

	_nRows_ = _aSize_[1]
	_nCols_ = _aSize_[2]

	_aMatrix_ = []

	for i = 1 to _nRows_

		_aRow_ = []

		for j = 1 to _nCols_
			_aRow_ + _nValue_
		next

		_aMatrix_ + _aRow_

	next

	return _aMatrix_


func IsMatrix(paList)
	if isList(paList) and IsListOfListsOfNumbers(paList) and
	   AllListsHaveSameSize(paList)

		return 1
	else
		return 0
	ok

	func @IsMatrix(paList)
		return IsMatrix(paList)

func IsMatrixOfPositiveNumbers(paList)

	if isList(paList) and IsListOfListsOfNumbers(paList) and
	   AllListsHaveSameSize(paList)

		_nLen_ = len(paList)
		_nLen2_ = len(paList[1])

		for i = 1 to _nLen_
			for j = 1 to _nLen2_
				if NOT paList[i][j] >= 0
					return 0
				ok
			next
		next

	ok

	return 1

	func @IsMatrixOfPositiveNumbers(paList)
		return IsMatrixOfPositiveNumbers(paList)

func IsMatrixOfNonZeroPositiveNumbers(paList)

	if isList(paList) and IsListOfListsOfNumbers(paList) and
	   AllListsHaveSameSize(paList)

		_nLen_ = len(paList)
		_nLen2_ = len(paList[1])

		for i = 1 to _nLen_
			for j = 1 to _nLen2_
				if NOT paList[i][j] > 0
					return 0
				ok
			next
		next

	ok

	return 1

	func IsMatrixOfStrictlyPositiveNumbers(paList)
		return IsMatrixOfNonZeroPositiveNumbers(paList)

	func @IsMatrixOfNonzeroPositiveNumbers(paList)
		return IsMatrixOfNonZeroPositiveNumbers(paList)

	func @IsMatrixOfStrictlyPositiveNumbers(paList)
		return IsMatrixOfNonZeroPositiveNumbers(paList)

func IsListOfMatrices(paList)
	if NOT isList(paList)
		return 0
	ok

	_bResult_ = 1
	_nLen_ = len(paList)

	for i = 1 to _nLen_
		if NOT IsMAtrix(paList[i])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

# Holds a rectangle of numbers and edits it in place, searches it, and answers linear-algebra questions such as determinant, inverse, rank and eigenvalues.
#
# A stzMatrix is a list of rows of numbers, all of the same length, or a zero matrix built from a [
# rows, columns ] pair. Positions are [ row, column ] and start at 1. Methods that add, multiply,
# replace or transpose change the matrix itself and answer nothing; methods that ask a question
# (Sum, Rank, Determinant, Inverse, SVD, the matrix functions such as MatrixExp) answer a plain Ring
# list or number and leave the matrix alone, and their Q forms wrap the answer in a stzMatrix. The
# heavy numeric work runs in the Softanza engine. Power raises every element to a power, while
# MatrixPower and GeneralPower raise the matrix itself. Several decompositions refuse what has no
# real answer (a singular matrix has no logarithm, a defective one no full set of eigenvectors) with
# an error rather than a wrong number. Known gaps today, each carried as a warning on its method:
# Section reads its corners as [ column, row ] and FindElementsInSection returns [ column, row ]
# pairs, so ReplaceSection changes the wrong cells on a non-square rectangle; MultiplyByInRow scales
# a column; Add given a matrix adds it and then raises; Diagonal1 answers nothing.
#
#   receiver   o1 = new stzMatrix([ [ 1, 2, 3 ], [ 4, 5, 6 ] ])
#   example    ? @@( o1.Size() )
#              #--> [ 2, 3 ]
#   see        stzListOfLists, stzListOfNumbers, stzNumBuffer, stzComplex
class stzMatrix from stzListOfLists

	# Matrix core attributes

	@aContent     # Stores the actual matrix data
	@nRows       # Number of rows
	@nCols       # Number of columns
	@pEngineMatrix = ""

	# Returns the class name as lowercase text.
	#
	#   returns    the string stzmatrix
	#   note       the StzClassName form answers the same
	#   see        Size
	def ClassName()
		return "stzmatrix"

		def StzClassName()
			return This.ClassName()

	# Builds the matrix from a list of rows, or a zero matrix from a [ rows, columns ] pair of numbers.
	#
	#   paInput    a list of rows, each a list of numbers of the same length, or a pair of two
	#              numbers [ rows, columns ] for a matrix of zeros
	#   returns    nothing; the object is built
	#   note       the rows are kept as given, with the first row setting the column count
	#   warning    a list of exactly two numbers is read as the size of a zero matrix, never as a
	#              1x2 matrix (write [ [ 2, 3 ] ] for that); an empty list raises R2 and anything
	#              that is not a list raises an error; row lengths are not checked
	#   see        StzMatrixQ, Copy
	#@ aka  Constructor with flexible initialization
	def init(paInput)

		if NOT isList(paInput)
			stzRaise("Incorrect input! stzMatrix needs a 2D list or a [rows, cols] dim pair.")
		ok

		# Disambiguate: [n, m] (two numbers) -> zero-matrix of those
		# dims; anything else is a 2D list of rows. The earlier
		# implementation checked `isList` first and crashed on
		# `len(paInput[1])` for the dim-pair form (paInput[1] is a
		# number, not a list).
		if len(paInput) = 2 and isNumber(paInput[1]) and isNumber(paInput[2])

			# Zero matrix of given dimensions
			@nRows = paInput[1]
			@nCols = paInput[2]

			# Build rows explicitly. Do NOT use the `list()` builtin
			# here: stzMatrix now inherits stzList, whose List()
			# method shadows Ring's `list()` in class scope (Ring is
			# case-insensitive), so `list(n)` would call List(n) -> R20.
			@aContent = []
			for i = 1 to @nRows
				_row_ = []
				for j = 1 to @nCols
					_row_ + 0
				next
				@aContent + _row_
			next

		else
			# 2D matrix list
			@aContent = paInput
			@nRows = len(paInput)
			@nCols = len(paInput[1])
		ok

	# The engine matrix is a TRANSIENT built from the Ring content, not a cache
	# kept alive between calls.
	#
	# FIXED 2026-07-25 (numeric foundation phase 3). It used to return the existing
	# handle if there was one, which is correct only while every method that writes
	# @aContent remembers to invalidate it. Seventeen of the twenty-three writers
	# did not -- the whole Replace* family among them -- so:
	#
	#     o = new stzMatrix([[1,2],[3,4]])
	#     o.Determinant()              -->  -2      (and builds the engine copy)
	#     o.ReplaceRow(1, [99,2])
	#     o.Content()                  -->  [[99,2],[3,4]]     the new matrix
	#     o.Determinant()              -->  -2      THE OLD ONE. Should be 390.
	#
	# A silent wrong answer, from a cache nobody invalidated. Adding the missing
	# seventeen calls would fix today and leave the eighteenth method to reopen it,
	# so the discipline is removed instead of relied upon: every call site is a
	# ONE-SHOT engine operation (determinant, inverse, transpose, multiply,
	# update-region), so nothing was gaining from the cache in the first place.
	def _EnsureEngineMatrix()
		This._InvalidateEngineMatrix()
		@pEngineMatrix = StzEngineMatrixNewFromList(@nRows, @nCols, @aContent)

	def _InvalidateEngineMatrix()
		if @pEngineMatrix != ""
			StzEngineMatrixFree(@pEngineMatrix)
			@pEngineMatrix = ""
		ok

	def _SyncFromEngine()
		if @pEngineMatrix = ""
			return
		ok
		_nEmRows = StzEngineMatrixRows(@pEngineMatrix)
		_nEmCols = StzEngineMatrixCols(@pEngineMatrix)
		@nRows = _nEmRows
		@nCols = _nEmCols
		@aContent = []
		for _iSf = 1 to _nEmRows
			_aRow = []
			for _jSf = 1 to _nEmCols
				_aRow + StzEngineMatrixGet(@pEngineMatrix, _iSf - 1, _jSf - 1)
			next
			@aContent + _aRow
		next

	# Engine-backed in-place region update (replaces the removed RingFastPro
	# updateList dependency). Applies +nVal (:add) or *nVal (:mul) to the cells
	# in rows nR1..nR2 x cols nC1..nC2 (1-based, inclusive) inside the Zig
	# matrix engine, then syncs @aContent back.
	def _UpdateRegion(cOp, nR1, nR2, nC1, nC2, nVal)
		_nOp_ = 0
		if cOp = :mul
			_nOp_ = 1
		ok
		This._EnsureEngineMatrix()
		StzEngineMatrixUpdateRegion(@pEngineMatrix, _nOp_, nR1, nR2, nC1, nC2, nVal)
		This._SyncFromEngine()

	# Returns the rows as a list of lists of numbers.
	#
	#   returns    a list of rows
	#   see        Copy, Size
	#@ aka  Raw matrix access
	def Content()
		return @aContent

	# Returns a new stzMatrix with the same rows, so the copy can change without touching this one.
	#
	#   returns    a new stzMatrix
	#   see        Content
	def Copy()
		return new stzMatrix(@aContent)

	# Returns the number of rows.
	#
	#   returns    a number
	#   see        Cols, Size
	#@ aka  Matrix Structure Queries
	def Rows()
		return @nRows

	# Returns the number of columns, counted on the first row.
	#
	#   returns    a number
	#   see        Rows, Size
	def Cols()
		return @nCols

	# Returns the dimensions as the pair [ rows, columns ].
	#
	#   returns    a list of two numbers
	#   see        Rows, Cols
	def Size()
		return [ @nRows, @nCols ]

	  #--------------------------#
	 # Element-Level Operations #
	#--------------------------#

	# Adds a number to every element, or to one row or column when given as a pair, changing the matrix in place.
	#
	#   p          a number for every element
	#   returns    nothing; the matrix changes in place
	#   note       AddMatrix is the call for adding a matrix
	#   warning    a matrix argument is added and then the call raises Incorrect param type or
	#              incorrect syntax; the [ value, :ToCol = n ] and [ value, :ToRow = n ] spellings
	#              read the pair backwards and change nothing
	#   see        AddInCol, AddInRow, AddMatrix
	#@ aka  Adds a value to each matrix element
	def Add(p)

		if isList(p) and len(p) = 2 and
		   isList(p[2]) and IsToOrToColOrToRowNamedParamList(p[2])

			_aTemp_ = []
			_aTemp_ = [ p[1], p[2][2] ]
			p = _aTemp_

		ok

		if isList(p) and @IsMatrix(p)
			This.AddMatrix(p)

		but isNumber(p)
			This._UpdateRegion(:add, 1, @nRows, 1, @nCols, p)
			return

		but isList(p) and @IsMatrix(p)
			This.AddMatrix(p)
			return
		ok

		# Using RingFastPro
		if isList(p) and len(p) = 2

			if isNumber(p[1]) and isNumber(p[2])
				This.AddInRow(p[1], p[2])
				return
	
			but isNumber(p[1]) and isList(p[2]) and len(p[2]) = 2 and
			    isString(p[2][1]) and isNumber(p[2][2])
	

				if p[2][1] = :InCol
		    			This.AddInCol(p[2][2], p[1])
					return

				but  p[2][1] = :Inrow
		    			This.AddInRow(p[2][2], p[1])
					return
				ok

			ok
		ok

		stzraise("Incorrect param type or incorrect syntax!")

	# Adds a value to every element of one column, changing the matrix in place.
	#
	#   _nCol_     the column to change
	#   _nValue_   the value to add
	#   returns    nothing; the matrix changes in place
	#   note       the column then the value
	#   see        AddInCol, AddVC
	def AddCV(_nCol_, _nValue_)
		This.AddInCol(_nCol_, _nValue_)

	# Adds a value to every element of one column, changing the matrix in place.
	#
	#   _nValue_   the value to add
	#   _nCol_     the column to change
	#   returns    nothing; the matrix changes in place
	#   note       the value then the column
	#   see        AddInCol, AddCV
	def AddVC(_nValue_, _nCol_)
		This.AddInCol(_nCol_, _nValue_)

	# Adds a value to every element of one row, changing the matrix in place.
	#
	#   _nRow_     the row to change
	#   _nValue_   the value to add
	#   returns    nothing; the matrix changes in place
	#   note       the row then the value
	#   see        AddInRow, AddVR
	def AddRV(_nRow_, _nValue_)
		This.AddInRow(_nRow_, _nValue_)

	# Adds a value to every element of one row, changing the matrix in place.
	#
	#   _nValue_   the value to add
	#   _nRow_     the row to change
	#   returns    nothing; the matrix changes in place
	#   note       the value then the row
	#   see        AddInRow, AddRV
	def AddVR(_nValue_, _nRow_)
		This.AddInRow(_nRow_, _nValue_)

	# Adds a value to every element of one column, changing the matrix in place.
	#
	#   _nCol_     the column to change
	#   _nValue_   the value to add
	#   returns    nothing; the matrix changes in place
	#   note       the column then the value
	#   see        AddInCol, AddToColumn
	#@ aka  The "To" spelling, which test 01 has always documented -- both the names and the resulting matrices -- while nothing defined them.
	def AddToCol(_nCol_, _nValue_)
		This.AddInCol(_nCol_, _nValue_)

		# Adds a value to every element of one column, changing the matrix in place.
		#
		#   _nCol_     the column to change
		#   _nValue_   the value to add
		#   returns    nothing; the matrix changes in place
		#   note       the column then the value
		#   see        AddInCol, AddToCol
		def AddToColumn(_nCol_, _nValue_)
			This.AddInCol(_nCol_, _nValue_)

	# Adds a value to every element of one row, changing the matrix in place.
	#
	#   _nRow_     the row to change
	#   _nValue_   the value to add
	#   returns    nothing; the matrix changes in place
	#   note       the row then the value
	#   see        AddInRow, AddToCol
	def AddToRow(_nRow_, _nValue_)
		This.AddInRow(_nRow_, _nValue_)

	# Adds a value to a specific column

	# AddXT(value, :InCol = n) / (:InRow = n) / (:InCols = [..]) / (:InRows = [..])
	# and the position-free forms AddXT(value, :InDiagonal) / :InDiagonal2.
	#
	# This method was broken in four independent ways and could not succeed on any
	# input:
	#   - it asked stzList for the IsIn*NamedParam predicates, which live on
	#     stzListNamedParams (R14);
	#   - it passed (value, index) into AddInCol(pnCol, pnValue), which takes
	#     (index, value) -- Add()'s own :InCol branch has the order right;
	#   - it called AddInDiagonal / AddInDiagonal2 with two arguments where both
	#     take one (R20);
	#   - and IsInDiagonal / IsInDiagonal1 / IsInDiagonal2 exist NOWHERE in the
	#     library.
	#
	# The diagonal forms are spelled as bare markers rather than named pairs
	# because AddInDiagonal(pnValue) takes no position -- a diagonal is fixed by
	# the matrix, so there is no second value for [:InDiagonal, x] to carry.
	# Nothing in the library anchors the old pair spelling; the arity is what
	# settles it.
	def AddXT(pnValue, p)

		if isString(p)

			if p = :InDiagonal or p = :InDiagonal1
				This.AddInDiagonal(pnValue)
				return

			but p = :InDiagonal2
				This.AddInDiagonal2(pnValue)
				return
			ok

		but isList(p)
			_oList_ = new stzListNamedParams(p)

			if _oList_.IsInColNamedParam()

				This.AddInCol(p[2], pnValue)
				return

			but _oList_.IsInRowNamedParam()

				This.AddInRow(p[2], pnValue)
				return

			but _oList_.IsInColsNamedParam()

				This.AddInCols(p[2], pnValue)
				return

			but _oList_.IsInRowsNamedParam()

				This.AddInRows(p[2], pnValue)
				return

			ok
		ok

		stzraise("Unsupported syntax!")

	# Adds a value to every element of one column, changing the matrix in place.
	#
	#   pnCol      the column to change
	#   pnValue    the value to add
	#   returns    nothing; the matrix changes in place
	#   note       done in the engine in one pass
	#   see        AddInRow, AddInCols
	def AddInCol(pnCol, pnValue)

		# Using RingFastPro

		This._UpdateRegion(:add, 1, @nRows, pnCol, pnCol, pnValue)

	# Adds a value to every element of one row, changing the matrix in place.
	#
	#   pnRow      the row to change
	#   pnValue    the value to add
	#   returns    nothing; the matrix changes in place
	#   note       done in the engine in one pass
	#   see        AddInCol, AddInRows
	#@ aka  Instead of this:
	def AddInRow(pnRow, pnValue)

		# Using RingFastPro

		This._UpdateRegion(:add, pnRow, pnRow, 1, @nCols, pnValue)

	# Adds a value to every element of several columns, changing the matrix in place.
	#
	#   paColumns   a list of columns, or a range written [ :From = 1, :To = 3 ]
	#   pnValue     the value to add
	#   returns     nothing; the matrix changes in place
	#   note        raises an error when pnValue is not a number
	#   see         AddInCol, AddInRows
	#@ aka  Instead of this:
	def AddInCols(paColumns, pnValue)

		if CheckParams()
			if NOT isNumber(pnValue)
				StzRaise("Incorrect param type! pnVakue must be a number.")
			ok

			if NOT isList(paColumns)
				StzRaise("Incorrect param type! paColumns must be a list.")
			ok
		ok

		 # Case: AddInCols(8, [ :From = 1, :To = 3 ])

		if len(paColumns) = 2 and

		   isList(paColumns[1]) and len(paColumns[1]) = 2 and
		   isString(paColumns[1][1]) and paColumns[1][1] = :From and
		   isNumber(paColumns[1][2]) and

		   isList(paColumns[2]) and len(paColumns[2]) = 2 and
		   isString(paColumns[2][1]) and paColumns[2][1] = :To and
		   isNumber(paColumns[2][2])

			This._UpdateRegion(:add, 1, @nRows, paColumns[1][2], paColumns[2][2], pnValue)
			return
		ok

		#-- Other cases

		_nColumns1Len_ = len(paColumns)
		for _iLoopColumns1_ = 1 to _nColumns1Len_
			_nCol_ = paColumns[_iLoopColumns1_]
			for i = 1 to @nRows
				@aContent[i][_nCol_] += pnValue
			next
		next

	# Adds a value to every element of several rows, changing the matrix in place.
	#
	#   paRows     a list of rows, or a range written [ :From = 1, :To = 3 ]
	#   pnValue    the value to add
	#   returns    nothing; the matrix changes in place
	#   note       raises an error when pnValue is not a number
	#   see        AddInRow, AddInCols
	#@ aka  Adds a value to multiple rows
	def AddInRows(paRows, pnValue)

		if CheckParams()
			if NOT isNumber(pnValue)
				StzRaise("Incorrect param type! pnValue must be a number.")
			ok

			if NOT isList(paRows)
				StzRaise("Incorrect param type! paRows must be a list.")
			ok
		ok

		 # Case: AddInRows([ :From = 1, :To = 3 ], 8)

		if len(paRows) = 2 and

		   isList(paRows[1]) and len(paRows[1]) = 2 and
		   isString(paRows[1][1]) and paRows[1][1] = :From and
		   isNumber(paRows[1][2]) and

		   isList(paRows[2]) and len(paRows[2]) = 2 and
		   isString(paRows[2][1]) and paRows[2][1] = :To and
		   isNumber(paRows[2][2])

			This._UpdateRegion(:add, paRows[1][2], paRows[2][2], 1, @nCols, pnValue)
			return
		ok

		#-- Other cases

		_nRows1Len_ = len(paRows)
		for _iLoopRows1_ = 1 to _nRows1Len_
			_nRow_ = paRows[_iLoopRows1_]
			for j = 1 to @nCols
				@aContent[_nRow_][j] += pnValue
			next
		next

	# Adds a value to the main diagonal, the cells from the top left down, changing the matrix in place.
	#
	#   pnValue    the value to add
	#   returns    nothing; the matrix changes in place
	#   note       a rectangular matrix has min(rows, columns) diagonal cells
	#   see        AddInDiagonal2, MultiplyDiagonal1
	#@ aka  Add value to main diagonal elements
	def AddInDiagonal(pnValue)

		_nMin_ = @min([@nRows, @nCols])

		for i = 1 to _nMin_
			@aContent[i][i] += pnValue
		next

	# Adds a value to the secondary diagonal, the cells from the top right down, changing the matrix in place.
	#
	#   pnValue    the value to add
	#   returns    nothing; the matrix changes in place
	#   note       a rectangular matrix has min(rows, columns) diagonal cells
	#   see        AddInDiagonal, MultiplyDiagonal2
	#@ aka  Add value to secondary diagonal elements
	def AddInDiagonal2(pnValue)

		_nMin_ = @min([@nRows, @nCols])

		for i = 1 to _nMin_
			@aContent[i][@nCols - i + 1] += pnValue
		next

	  #-----------------------------#
	 # Element-wise multiplication #
	#-----------------------------#

	# Multiplies every element by a number, or one row or column when given as a pair, changing the matrix in place.
	#
	#   p          a number for every element, :By = n for the same, [ row, factor ] for one row, or
	#              [ :Col = c, :By = f ] or [ :Row = r, :By = f ]
	#   returns    nothing; the matrix changes in place
	#   note       raises Incorrect param type or incorrect syntax for any other shape
	#   see        MultiplyBy, MultiplyCol, MultiplyRow
	def Multiply(p)

		if isList(p) and IsByNamedParamList(p)
			p = p[2]
		ok

		if isNumber(p)
			This.MultiplyBy(p)
			return
		ok

		if isList(p) and len(p) = 2

			if isNumber(p[1]) and isNumber(p[2])
				This.MultiplyRow(p[1], p[2])
				return

			but isList(p[1]) and len(p[1]) = 2 and
			    isString(p[1][1]) and isNumber(p[1][2]) and

			    isList(p[2]) and len(p[2]) = 2 and
			    isString(p[2][1]) and p[2][1] = :By and
			    isNumber(p[2][2])

				if p[1][1] = :Col
					This.MultiplyCol(p[1][2], p[2][2])
					return

				but p[1][1] = :Row
					This.MultiplyRow(p[1][2], p[2][2])
					return

				ok
			ok
		ok

		stzraise("Incorrect param type or incorrect syntax!")

	# Multiplies every element of one column by a number, changing the matrix in place.
	#
	#   _nCol_     the column to scale
	#   _nValue_   the factor
	#   returns    nothing; the matrix changes in place
	#   note       the column then the factor
	#   see        MultiplyCol, MultiplyVC
	def MultiplyCV(_nCol_, _nValue_)
		This.MultiplyCol(_nCol_, _nValue_)

	# Multiplies every element of one column by a number, changing the matrix in place.
	#
	#   _nValue_   the factor
	#   _nCol_     the column to scale
	#   returns    nothing; the matrix changes in place
	#   note       the factor then the column
	#   see        MultiplyCol, MultiplyCV
	def MultiplyVC(_nValue_, _nCol_)
		This.MultiplyCol(_nCol_, _nValue_)

	# Multiplies every element of one row by a number, changing the matrix in place.
	#
	#   _nRow_     the row to scale
	#   _nValue_   the factor
	#   returns    nothing; the matrix changes in place
	#   note       the row then the factor
	#   see        MultiplyRow, MultiplyVR
	def MultiplyRV(_nRow_, _nValue_)
		This.MultiplyRow(_nRow_, _nValue_)

	# Multiplies every element of one row by a number, changing the matrix in place.
	#
	#   _nValue_   the factor
	#   _nRow_     the row to scale
	#   returns    nothing; the matrix changes in place
	#   note       the factor then the row
	#   see        MultiplyRow, MultiplyRV
	def MultiplyVR(_nValue_, _nRow_)
		This.MultiplyRow(_nRow_, _nValue_)

	# Multiplies every element by a number, or takes the matrix product with a second matrix on the right, in place.
	#
	#   pnValue    a number to scale every element, or a matrix (a list of rows) whose row count
	#              equals this matrix's column count
	#   returns    nothing; the matrix changes in place
	#   note       with a matrix it gives the same result as MultiplyByMatrix and the shape changes
	#   see        MultiplyByMatrix, Multiply
	def MultiplyBy(pnValue)

		if isList(pnValue) and @IsMatrix(pnValue)
			This.MultiplyByMatrix(pnValue)
			return
		ok

		This._UpdateRegion(:mul, 1, @nRows, 1, @nCols, pnValue)

		def MultiplyByQ(pnValue)
			This.MultiplyBy(pnValue)
			return This

	# Multiplies every element of one column by a number, changing the matrix in place.
	#
	#   pnCol      the column to scale
	#   pnValue    the factor, or written :By = factor
	#   returns    nothing; the matrix changes in place
	#   note       raises an error when pnCol is not a number
	#   see        MultiplyCols, MultiplyRow
	#@ aka  Multiply a specific column by a value
	def MultiplyCol(pnCol, pnValue)

		if CheckParams()

			if NOT isNumber(pnCol)
				stzraise("Incorrect param type! pnCol must be a number.")
			ok
	
			if isList(pnValue) and IsByOrInColNamedParamList(pnValue)
				pnValue = pnValue[2]
	
				if NOT isNumber(pnValue)
					stzraise("Incorrect param type! pnValue must be a number.")
				ok
			ok
		ok

		This._UpdateRegion(:mul, 1, @nRows, pnCol, pnCol, pnValue)

		# Multiplies every element of one column by a number, changing the matrix in place.
		#
		#   pnCol      the column to scale
		#   pnValue    the factor
		#   returns    nothing; the matrix changes in place
		#   note       raises an error when pnValue is not a number
		#   see        MultiplyCol
		def MultiplyColBy(pnCol, pnValue)
			if NOT isNumber(pnValue)
				stzraise("Incorrect param type! pnValue must be a number.")
			ok

			This.MultiplyCol(pnCol, pnValue)

		# Multiplies every element of one column by a number, changing the matrix in place.
		#
		#   pnValue    the factor
		#   pnCol      the column to scale
		#   returns    nothing; the matrix changes in place
		#   note       the factor then the column
		#   see        MultiplyCol, MultiplyColBy
		def MultiplyByInCol(pnValue, pnCol)
			This.MultiplyColBy(pnCol, pnValue)

	# Multiplies every element of several columns by a number, changing the matrix in place.
	#
	#   panCols    a list of columns, or a range written [ :From = 1, :To = 3 ]
	#   pnValue    the factor, or written :By = factor
	#   returns    nothing; the matrix changes in place
	#   see        MultiplyCol, MultiplyRows
	#@ aka  Multiply many columns at one time
	def MultiplyCols(panCols, pnValue)

		if CheckParams()
			if isList(pnValue) and IsByOrInColNamedParamList(pnValue)
				pnValue = pnValue[2]
	
				if NOT isNumber(pnValue)
					stzraise("Incorrect param type! pnValue must be a number.")
				ok
			ok
		ok

		# Early check for the case: MultiplyCols([:from = 2, :to = 3], :By = 2)

		if isList(panCols) and len(panCols) = 2 and

		   isList(panCols[1]) and len(panCols[1]) = 2 and
		   isString(panCols[1][1]) and panCols[1][1] = :From and
		   isNumber(panCols[1][2]) and

		   isList(panCols[2]) and len(panCols[2]) = 2 and
		   isString(panCols[2][1]) and panCols[2][1] = :To and
		   isNumber(panCols[2][2])

			This._UpdateRegion(:mul, 1, @nRows, panCols[1][2], panCols[2][2], pnValue)
			return
		ok

		# Doing the job, for the normal case: MultiplyCols([ 1, 3 ], :By = 2)

		if CheckParams()
			if NOT isList(panCols) and @IsListOfNumbers(panCols)
				stzraise("Incorrect param type! panCols must be a list of numbers.")
			ok
		ok

		# Doing the job
		#
		# This used to BUILD A STRING OF RING CODE and eval() it, calling a function
		# named updateColumn that does not exist -- in this library, or in Ring --
		# so every call raised R3. One column at a time through the engine instead,
		# which is what the From..To branch above already does and what every
		# sibling (AddInRow, MultiplyRow) uses.

		_nLen_ = len(panCols)

		for i = 1 to _nLen_
			This._UpdateRegion(:mul, 1, @nRows, panCols[i], panCols[i], pnValue)
		next

	# Multiplies every element of one row by a number, changing the matrix in place.
	#
	#   pnRow      the row to scale
	#   pnValue    the factor, or written :By = factor
	#   returns    nothing; the matrix changes in place
	#   note       raises an error when pnRow is not a number
	#   see        MultiplyRows, MultiplyCol
	#@ aka  Multiply a specific row by a value
	def MultiplyRow(pnRow, pnValue)

		if CheckParams()

			if NOT isNumber(pnRow)
				stzraise("Incorrect param type! pnRow must be a number.")
			ok
	
			if isList(pnValue) and IsByOrInRowNamedParamList(pnValue)
				pnValue = pnValue[2]
	
				if NOT isNumber(pnValue)
					stzraise("Incorrect param type! pnValue must be a number.")
				ok
			ok
		ok

		This._UpdateRegion(:mul, pnRow, pnRow, 1, @nCols, pnValue)

		# Multiplies every element of one row by a number, changing the matrix in place.
		#
		#   pnRow      the row to scale
		#   pnValue    the factor
		#   returns    nothing; the matrix changes in place
		#   note       raises an error when pnValue is not a number
		#   see        MultiplyRow
		def MultiplyRowBy(pnRow, pnValue)
			if NOT isNumber(pnValue)
				stzraise("Incorrect param type! pnValue must be a number.")
			ok

			This.MultiplyRow(pnRow, pnValue)

		# Multiplies every element of one COLUMN by a number today, changing the matrix in place, where the row was meant.
		#
		#   pnValue    the factor
		#   pnRow      the position scaled, which is taken as a column
		#   returns    nothing; the matrix changes in place
		#   note       the arguments are the factor then the position
		#   warning    scales column pnRow instead of row pnRow, because the body calls
		#              MultiplyColBy; MultiplyRow and MultiplyRowBy scale the row
		#   see        MultiplyRow, MultiplyByInCol
		def MultiplyByInRow(pnValue, pnRow)
			This.MultiplyColBy(pnRow, pnValue)

	# Multiplies every element of several rows by a number, changing the matrix in place.
	#
	#   panRows    a list of rows, or a range written [ :From = 1, :To = 3 ]
	#   pnValue    the factor, or written :By = factor
	#   returns    nothing; the matrix changes in place
	#   see        MultiplyRow, MultiplyCols
	#@ aka  Multiply many rows at one time
	def MultiplyRows(panRows, pnValue)

		if CheckParams()
			if isList(pnValue) and IsByOrInColNamedParamList(pnValue)
				pnValue = pnValue[2]
	
				if NOT isNumber(pnValue)
					stzraise("Incorrect param type! pnValue must be a number.")
				ok
			ok
		ok

		# Early check for the case: MultiplyRows([:from = 2, :to = 3], :By = 2)

		if isList(panRows) and len(panRows) = 2 and

		   isList(panRows[1]) and len(panRows[1]) = 2 and
		   isString(panRows[1][1]) and panRows[1][1] = :From and
		   isNumber(panRows[1][2]) and

		   isList(panRows[2]) and len(panRows[2]) = 2 and
		   isString(panRows[2][1]) and panRows[2][1] = :To and
		   isNumber(panRows[2][2])

			This._UpdateRegion(:mul, panRows[1][2], panRows[2][2], 1, @nCols, pnValue)
			return
		ok

		# Doing the job, for the normal case: MultiplyRows([ 1, 3 ], :By = 2)

		if CheckParams()
			if NOT isList(panRows) and @IsListOfNumbers(panRows)
				stzraise("Incorrect param type! panRows must be a list of numbers.")
			ok
		ok

		# Doing the job

		_nLen_ = len(panRows)

		for i = 1 to _nLen_
		 	This._UpdateRegion(:mul, panRows[i], panRows[i], 1, @nCols, pnValue)
		next

	# Multiplies the main diagonal, the cells from the top left down, by a number, changing the matrix in place.
	#
	#   pnValue    the factor, or written :By = factor
	#   returns    nothing; the matrix changes in place
	#   note       a rectangular matrix has min(rows, columns) diagonal cells
	#   see        MultiplyDiagonal2, AddInDiagonal
	#@ aka  Multiply main diagonal elements by a value
	def MultiplyDiagonal1(pnValue)

		if CheckParams()
			if isList(pnValue) and IsByNamedParamList(pnValue)
				pnValue = pnValue[2]
			ok
		ok

		_nMin_ = @min([@nRows, @nCols])

		for i = 1 to _nMin_
			@aContent[i][i] *= pnValue
		next

		# Multiplies the main diagonal by a number, changing the matrix in place.
		#
		#   pnValue    the factor
		#   returns    nothing; the matrix changes in place
		#   note       the same as the main-diagonal form
		#   see        MultiplyDiagonal1
		#< @FunctionAlternativeForms
		def MultiplyDiagonal(pnValue)
			This.MultiplyDiagonal1(pnValue)

		# Multiplies the main diagonal by a number, changing the matrix in place.
		#
		#   pnValue    the factor
		#   returns    nothing; the matrix changes in place
		#   note       the same as the main-diagonal form
		#   see        MultiplyDiagonal1
		def MultiplyByInDiagonal1(pnValue)
			This.MultiplyDiagonal1(pnValue)

		# Multiplies the main diagonal by a number, changing the matrix in place.
		#
		#   pnValue    the factor
		#   returns    nothing; the matrix changes in place
		#   note       the same as the main-diagonal form
		#   see        MultiplyDiagonal1
		def MultiplyByInDiagonal(pnValue)
			This.MultiplyDiagonal1(pnValue)

	# Multiplies the secondary diagonal, the cells from the top right down, by a number, changing the matrix in place.
	#
	#   pnValue    the factor, or written :By = factor
	#   returns    nothing; the matrix changes in place
	#   note       a rectangular matrix has min(rows, columns) diagonal cells
	#   see        MultiplyDiagonal1, AddInDiagonal2
		#>
	#@ aka  Multiply secondary diagonal elements by a value
	def MultiplyDiagonal2(pnValue)

		if CheckParams()
			if isList(pnValue) and IsByNamedParamList(pnValue)
				pnValue = pnValue[2]
			ok
		ok

		_nMin_ = @min([@nRows, @nCols])

		for i = 1 to _nMin_
			@aContent[i][@nCols - i + 1] *= pnValue
		next

		# Multiplies the secondary diagonal by a number, changing the matrix in place.
		#
		#   pnValue    the factor
		#   returns    nothing; the matrix changes in place
		#   note       the spelling Dagonal is in the name as shipped
		#   see        MultiplyDiagonal2
		def MultiplyByInDagonal2(pnValue)
			This.MultiplyDiagonal2(pnValue)

	  #-------------------------------#
	 #  Matrix-to-Matrix Operations  #
	#-------------------------------#

	# Adds another matrix element by element, changing this one in place.
	#
	#   paMatrix   the matrix to add, a list of rows with the same size as this one
	#   returns    nothing; the matrix changes in place
	#   note       raises Matrices must have the same dimensions before changing anything when the
	#              sizes differ
	#   see        SubtractMatrix, Add
	def AddMatrix(paMatrix)

		# Validate input is a matrix with same dimensions

		if not (isList(paMatrix) and @IsMatrix(paMatrix))
			raise("Input must be a valid matrix")
		ok

		_nInputRows_ = len(paMatrix)
		_nInputCols_ = len(paMatrix[1])

		if @nRows != _nInputRows_ or @nCols != _nInputCols_
			raise("Matrices must have the same dimensions")
		ok

		# Element-wise addition

		for i = 1 to @nRows
			for j = 1 to @nCols
				@aContent[i][j] += paMatrix[i][j]
			next
		next
		This._InvalidateEngineMatrix()

	# Subtracts another matrix element by element, changing this one in place.
	#
	#   paMatrix   the matrix to subtract, a list of rows with the same size as this one
	#   returns    nothing; the matrix changes in place
	#   note       raises Matrices must have the same dimensions before changing anything when the
	#              sizes differ
	#   see        AddMatrix
	#@ aka  R4 step 1 -- MATRIX HYGIENE: the training prerequisites (elementwise ops, trace, norm, Ax=b). Ring floor; the engine tier accelerates behind the same surface later.
	def SubtractMatrix(paMatrix)
		if not (isList(paMatrix) and @IsMatrix(paMatrix))
			raise("Input must be a valid matrix")
		ok
		if @nRows != len(paMatrix) or @nCols != len(paMatrix[1])
			raise("Matrices must have the same dimensions")
		ok
		for i = 1 to @nRows
			for j = 1 to @nCols
				@aContent[i][j] -= paMatrix[i][j]
			next
		next
		This._InvalidateEngineMatrix()

	# Multiplies by another matrix element by element, which is the Hadamard product, changing this one in place.
	#
	#   paMatrix   the matrix of factors, a list of rows with the same size as this one
	#   returns    nothing; the matrix changes in place
	#   note       not the matrix product: that is MultiplyByMatrix
	#   see        HadamardProduct, MultiplyByMatrix
	def MultiplyElementwise(paMatrix)
		if not (isList(paMatrix) and @IsMatrix(paMatrix))
			raise("Input must be a valid matrix")
		ok
		if @nRows != len(paMatrix) or @nCols != len(paMatrix[1])
			raise("Matrices must have the same dimensions")
		ok
		for i = 1 to @nRows
			for j = 1 to @nCols
				@aContent[i][j] *= paMatrix[i][j]
			next
		next
		This._InvalidateEngineMatrix()

		# Multiplies by another matrix element by element, changing this one in place.
		#
		#   paMatrix   the matrix of factors, a list of rows with the same size as this one
		#   returns    nothing; the matrix changes in place
		#   note       the name mathematicians use for the element-by-element product
		#   see        MultiplyElementwise
		def HadamardProduct(paMatrix)
			This.MultiplyElementwise(paMatrix)

	# Divides by another matrix element by element, changing this one in place.
	#
	#   paMatrix   the matrix of divisors, a list of rows with the same size as this one
	#   returns    nothing; the matrix changes in place
	#   note       raises Matrices must have the same dimensions before changing anything when the
	#              sizes differ
	#   warning    raises Division by zero at (row, col) at the first zero divisor, after the cells
	#              before it have already been divided, so the matrix is left half changed
	#   see        MultiplyElementwise
	def DivideElementwise(paMatrix)
		if not (isList(paMatrix) and @IsMatrix(paMatrix))
			raise("Input must be a valid matrix")
		ok
		if @nRows != len(paMatrix) or @nCols != len(paMatrix[1])
			raise("Matrices must have the same dimensions")
		ok
		for i = 1 to @nRows
			for j = 1 to @nCols
				if paMatrix[i][j] = 0
					raise("Division by zero at (" + i + ", " + j + ")")
				ok
				@aContent[i][j] /= paMatrix[i][j]
			next
		next
		This._InvalidateEngineMatrix()

	# Returns the sum of the main diagonal.
	#
	#   returns    a number
	#   note       raises an error unless the matrix is square
	#   see        Diagonal, Determinant
	def Trace()
		if @nRows != @nCols
			raise("Trace is only defined for square matrices")
		ok
		_nT_ = 0
		for i = 1 to @nRows
			_nT_ += @aContent[i][i]
		next
		return _nT_

	# Returns the square root of the sum of the squares of every element.
	#
	#   returns    a number
	#   note       the Norm form answers the same
	#   see        Sum, Rank
	def FrobeniusNorm()
		_nS_ = 0
		for i = 1 to @nRows
			for j = 1 to @nCols
				_nS_ += @aContent[i][j] * @aContent[i][j]
			next
		next
		return sqrt(_nS_)

		def Norm()
			return This.FrobeniusNorm()

	# Solves the linear system A x = b for x, where this matrix is A, and returns x.
	#
	#   paB        the right-hand side, a list of as many numbers as the matrix has rows
	#   returns    a list of n numbers, one per column
	#   note       the matrix is not changed; the Solve form answers the same
	#   warning    raises an error when the matrix is not square, when paB has the wrong length, or
	#              when the system is singular
	#   see        LeastSquaresFor, Inverse
	#@ aka  Solve A x = b -- returns the solution VECTOR (list). Singular systems REFUSE (LAW 3); no least-squares guessing.
	def SolveFor(paB)
		if @nRows != @nCols
			raise("SolveFor needs a square system (A must be n x n)")
		ok
		if NOT (isList(paB) and len(paB) = @nRows)
			raise("b must be a list of " + @nRows + " numbers")
		ok

		# Engine fast path
		This._EnsureEngineMatrix()
		if @pEngineMatrix != ""
			_aBCol_ = []
			for _iSf_ = 1 to @nRows
				_aBCol_ + [ paB[_iSf_] ]
			next
			_pBSf_ = StzEngineMatrixNewFromList(@nRows, 1, _aBCol_)
			if _pBSf_ != ""
				_pXSf_ = StzEngineMatrixSolve(@pEngineMatrix, _pBSf_)
				StzEngineMatrixFree(_pBSf_)
				if _pXSf_ != ""
					_anXSf_ = []
					for _jSf_ = 1 to @nRows
						_anXSf_ + StzEngineMatrixGet(_pXSf_, _jSf_ - 1, 0)
					next
					StzEngineMatrixFree(_pXSf_)
					return _anXSf_
				ok
				# NULL means the engine found it singular. Same refusal the Ring
				# path gives, raised here rather than falling through -- otherwise
				# a singular system would be solved twice before being refused.
				raise("Singular system: no unique solution")
			ok
		ok

		# augmented copy [A|b]
		_aM_ = []
		for i = 1 to @nRows
			_aRow_ = []
			for j = 1 to @nCols
				_aRow_ + @aContent[i][j]
			next
			_aRow_ + paB[i]
			_aM_ + _aRow_
		next
		_nN_ = @nRows
		for i = 1 to _nN_
			# partial pivot: swap in the largest |value| below
			_nP_ = i
			for k = i + 1 to _nN_
				if fabs(_aM_[k][i]) > fabs(_aM_[_nP_][i])
					_nP_ = k
				ok
			next
			if fabs(_aM_[_nP_][i]) < 0.000000000001
				raise("Singular system: no unique solution (pivot ~ 0 at column " + i + ")")
			ok
			if _nP_ != i
				_aTmp_ = _aM_[i]
				_aM_[i] = _aM_[_nP_]
				_aM_[_nP_] = _aTmp_
			ok
			_nPiv_ = _aM_[i][i]
			for j = i to _nN_ + 1
				_aM_[i][j] /= _nPiv_
			next
			for k = 1 to _nN_
				if k != i
					_nF_ = _aM_[k][i]
					for j = i to _nN_ + 1
						_aM_[k][j] -= _nF_ * _aM_[i][j]
					next
				ok
			next
		next
		_aX_ = []
		for i = 1 to _nN_
			_aX_ + _aM_[i][_nN_ + 1]
		next
		return _aX_

		def Solve(paB)
			return This.SolveFor(paB)

	# R4 step 2 -- THE GGML TIER for matmul (the bridge seed, 5.9):
	# BLAS-grade threaded kernel through the neural DLL. Same semantics
	# as MultiplyByMatrix (mutates This); FALLS BACK to the naive path
	# when the tier is unavailable; Why() names the tier that ran.
	def MultiplyByMatrixXT(paMatrix)
		if not (isList(paMatrix) and @IsMatrix(paMatrix))
			raise("Input must be a valid matrix")
		ok
		_nBRows_ = len(paMatrix)
		_nBCols_ = len(paMatrix[1])
		if @nCols != _nBRows_
			raise("Matrix dimensions incompatible: " + @nCols +
				" columns vs " + _nBRows_ + " rows")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix != ""
			_pB_ = StzEngineMatrixNewFromList(_nBRows_, _nBCols_, paMatrix)
			_pC_ = StzEngineMatrixNew(@nRows, _nBCols_)
			if _pB_ != "" and _pC_ != ""
				_bOk_ = 0
				try
					_bOk_ = StzEngineMatrixMulGgml(@pEngineMatrix, _pB_, _pC_)
				catch
					_bOk_ = 0
				done
				if _bOk_ = 1
					_aNew_ = []
					for _iMm_ = 1 to @nRows
						_aRowMm_ = []
						for _jMm_ = 1 to _nBCols_
							_aRowMm_ + StzEngineMatrixGet(_pC_, _iMm_ - 1, _jMm_ - 1)
						next
						_aNew_ + _aRowMm_
					next
					StzEngineMatrixFree(_pB_)
					StzEngineMatrixFree(_pC_)
					@aContent = _aNew_
					@nCols = _nBCols_
					This._InvalidateEngineMatrix()
					$cStzLastWhyB = "matmul ran on the GGML tier (threaded f32 kernel)"
					return
				ok
				StzEngineMatrixFree(_pB_)
				StzEngineMatrixFree(_pC_)
			ok
		ok
		# graceful degradation: the naive engine/Ring path
		This.MultiplyByMatrix(paMatrix)
		$cStzLastWhyB = "matmul ran on the NAIVE tier (ggml unavailable)"

	# Replaces this matrix by its matrix product with a second matrix on the right.
	#
	#   paMatrix   the right factor, a list of rows whose count equals this matrix's column count
	#   returns    nothing; the matrix changes in place and may change shape
	#   note       a 2x3 times a 3x2 becomes a 2x2
	#   warning    raises Matrices cannot be multiplied: incompatible dimensions when the counts
	#              differ; the Q form of this call raises today because it wraps an answer that is
	#              nothing
	#   see        MultiplyBy, MultiplyElementwise
	def MultiplyByMatrix(paMatrix)

		# Validate input is a list of lists

		if not (isList(paMatrix) and isList(paMatrix[1]))
			raise("Input must be a list of lists of numbers")
		ok

		# Check matrix multiplication dimensions

		_nInputRows_ = len(paMatrix)
		_nInputCols_ = len(paMatrix[1])

		if @nCols != _nInputRows_
			raise("Matrices cannot be multiplied: incompatible dimensions")
		ok

		# Engine fast path
		This._EnsureEngineMatrix()
		if @pEngineMatrix != ""
			_pMbB = StzEngineMatrixNewFromList(_nInputRows_, _nInputCols_, paMatrix)
			if _pMbB != ""
				_pMbResult = StzEngineMatrixMultiply(@pEngineMatrix, _pMbB)
				StzEngineMatrixFree(_pMbB)
				if _pMbResult != ""
					StzEngineMatrixFree(@pEngineMatrix)
					@pEngineMatrix = _pMbResult
					This._SyncFromEngine()
					return
				ok
			ok
		ok

		# Ring fallback

		_aResultMatrix_ = []

		for i = 1 to @nRows

			_aResultRow_ = []

			for j = 1 to _nInputCols_

				_nSum_ = 0

				for k = 1 to @nCols
					_nSum_ += @aContent[i][k] * paMatrix[k][j]
				next

				_aResultRow_ + _nSum_
			next

			_aResultMatrix_ + _aResultRow_
		next

		# Update the current matrix with the result

		@aContent = _aResultMatrix_
		@nCols = _nInputCols_
		This._InvalidateEngineMatrix()

		def MultiplyByMatrixQ(pMatrix)
			return new stzMatrix(This.MultiplyByMatrix(pMatrix))

	  #------------------------#
	 # Statistical Operations #
	#------------------------#

	# Returns the sum of every element.
	#
	#   returns    a number
	#   note       computed in the engine
	#   see        Mean, Max
	#@ aka  Calculates the sum of all elements
	def Sum()
		This._EnsureEngineMatrix()
		if @pEngineMatrix != ""
			return StzEngineMatrixSum(@pEngineMatrix)
		ok

		_nTotal_ = 0

		for i = 1 to @nRows

			for j = 1 to @nCols
				_nTotal_ += @aContent[i][j]
			next

		next

		return _nTotal_

	# Returns the average of every element.
	#
	#   returns    a number
	#   note       the sum divided by rows times columns
	#   see        Sum
	#@ aka  Calculates the mean of all elements
	def Mean()
		return Sum() / (@nRows * @nCols)

	# Returns the largest element.
	#
	#   returns    a number
	#   note       computed in the engine
	#   see        Min
	#@ aka  Finds the maximum value in the matrix
	def Max()
		This._EnsureEngineMatrix()
		if @pEngineMatrix != ""
			return StzEngineMatrixMax(@pEngineMatrix)
		ok

		_nMax_ = @aContent[1][1]

		for i = 1 to @nRows
			for j = 1 to @nCols
				if @aContent[i][j] > _nMax_
					_nMax_ = @aContent[i][j]
				ok
			next
		next

		return _nMax_

	# Returns the smallest element.
	#
	#   returns    a number
	#   note       computed in the engine
	#   see        Max
	#@ aka  Finds the minimum value in the matrix
	def Min()
		This._EnsureEngineMatrix()
		if @pEngineMatrix != ""
			return StzEngineMatrixMin(@pEngineMatrix)
		ok

		_nMin_ = @aContent[1][1]

		for i = 1 to @nRows
			for j = 1 to @nCols
				if @aContent[i][j] < _nMin_
					_nMin_ = @aContent[i][j]
				ok
			next
		next

		return _nMin_

	# Raises every element to a power, changing the matrix in place.
	#
	#   n          the exponent, a number
	#   returns    nothing; the matrix changes in place
	#   note       element by element, not the matrix power: Power(2) squares each cell,
	#              MatrixPower(2) multiplies the matrix by itself
	#   see        MatrixPower, GeneralPower
	#@ aka  Calculates the power of all elements
	def Power(n)
		This._EnsureEngineMatrix()
		if @pEngineMatrix != ""
			StzEngineMatrixPower(@pEngineMatrix, n)
			This._SyncFromEngine()
			return
		ok

		_nTotal_ = 0

		for i = 1 to @nRows

			for j = 1 to @nCols
				@aContent[i][j] = pow(@aContent[i][j], n)
			next

		next

		def PowerQ(n)
			This.Power(n)
			return This

		# Raises every element to a power, changing the matrix in place.
		#
		#   n          the exponent, a number
		#   returns    nothing; the matrix changes in place
		#   note       element by element, not the matrix power
		#   see        Power, MatrixPower
		def RaiseToPower(n)
			This.Power(n)

			def RaiseToPowerQ(n)
				return This.PowerQ(n)

		# Raises every element to a power, changing the matrix in place.
		#
		#   n          the exponent, a number
		#   returns    nothing; the matrix changes in place
		#   note       element by element, not the matrix power
		#   see        Power, MatrixPower
		def ToPower(n)
			This.Power(n)

			def ToPowerQ(n)
				return This.PowerQ(n)

	#-------------------------------#
	#  FINDING THING IN THE MATRIX  #
	#-------------------------------#

	# Returns the positions [ row, column ] of every cell equal to a number, scanning row by row.
	#
	#   nElm       the number to look for
	#   returns    a list of [ row, column ] pairs; empty when absent
	#   note       the matrix is not changed
	#   see        FindElements, FindRow
	def FindElement(nElm)
		_aPositions_ = []
    
		for i = 1 to @nRows
			for j = 1 to @nCols
				if @aContent[i][j] = nElm
					_aPositions_ + [i, j]
				ok
			next
		next
    
		return _aPositions_

	# Returns the positions [ row, column ] of every cell equal to any of several numbers, grouped by number.
	#
	#   panElms    the numbers to look for
	#   returns    a list of [ row, column ] pairs; empty when none is found
	#   note       the positions of the first number come first, then those of the second
	#   see        FindElement
	def FindElements(panElms)

		_aResult_ = []
		_nLen_ = len(panElms)

		for i = 1 to _nLen_

			_aPositions_ = This.FindElement(panElms[i])
			_nLen2_ = len(_aPositions_)

			for j = 1 to _nLen2_
				_aResult_ + _aPositions_[j]
			next

		next

		return _aResult_

	# Returns the positions of the columns that are equal to a given column, written as a list of numbers.
	#
	#   paCol      the column to match, a list with one number per row
	#   returns    a list of column positions; empty when none matches
	#   note       the whole column must match
	#   see        FindCols, FindRow
	#@ aka  `def`, not `func`. Inside a class body `func` does not define a method, so FindCol was unreachable and FindCols -- its only caller -- raised R14. It was the sole `func` among 95 definitions here; FindRow, FindRows and FindCols all use `def`.
	def FindCol(paCol)
		_aResult_ = []

		for nColIndex = 1 to @nCols
			_bMatch_ = 1

			for nRowIndex = 1 to @nRows
				if @aContent[nRowIndex][nColIndex] != paCol[nRowIndex]
					_bMatch_ = 0
					exit
				ok
			next

			if _bMatch_
				_aResult_ + nColIndex
			ok
		next
    
		return _aResult_

	# Returns the positions of the columns that match any of several given columns, sorted and without repeats.
	#
	#   panCols    the columns to match, a list of lists with one number per row each
	#   returns    a list of column positions; empty when none matches
	#   note       a plain list of numbers raises R5: wrap each column in its own list
	#   see        FindCol, FindRows
	def FindCols(panCols)
		
		_nLen_ = len(panCols)
		_anResult_ = []

		for i = 1 to _nLen_

			_anPos_ = This.FindCol(panCols[i])
			_nLenPos_ = len(_anPos_)

			for j = 1 to _nLenPos_
				_anResult_ + _anPos_[j]
			next
		next

		return U(@sort(_anResult_))

	# Returns the positions of the rows that are equal to a given row, written as a list of numbers.
	#
	#   panRow     the row to match, a list with one number per column
	#   returns    a list of row positions; empty when none matches
	#   note       the whole row must match
	#   see        FindRows, FindCol
	def FindRow(panRow)
		_anResult_ = []

		for nRowIndex = 1 to @nRows
			_bMatch_ = 1

			for nColIndex = 1 to @nCols
				if @aContent[nRowIndex][nColIndex] != panRow[nColIndex]
					_bMatch_ = 0
					exit
				ok
			next

			if _bMatch_
				_anResult_ + nRowIndex
			ok
		next
    
		return _anResult_

	# Returns the positions of the rows that match any of several given rows, sorted and without repeats.
	#
	#   panRows    the rows to match, a list of lists with one number per column each
	#   returns    a list of row positions; empty when none matches
	#   note       a plain list of numbers raises R5: wrap each row in its own list
	#   see        FindRow, FindCols
	def FindRows(panRows)

		_nLen_ = len(panRows)
		_anResult_ = []

		for i = 1 to _nLen_

			_anPos_ = This.FindRow(panRows[i])
			_nLenPos_ = len(_anPos_)

			for j = 1 to _nLenPos_
				_anResult_ + _anPos_[j]
			next
		next

		return U(@sort(_anResult_))

	# Returns the cells of the rectangle between two corners as [ column, row ] pairs, row by row of the rectangle.
	#
	#   panStart   the first corner [ row, column ], or :From = pair
	#   panEnd     the last corner [ row, column ], or :To = pair
	#   returns    a list of [ column, row ] pairs
	#   note       the corners are read as [ row, column ] here
	#   warning    the pairs come out as [ column, row ], the reverse of every other Find method, so
	#              on a rectangular section the pairs name the wrong cells (a 2x3 rectangle returns
	#              a row 3 that does not exist) and ReplaceSection changes the wrong cells
	#   see        FindElementInSection, Section
	#@ aka  --
	def FindElementsInSection(panStart, panEnd)
		if CheckParams()

			if isList(panStart) and IsFromNamedParamList(panStart)
				panStart = panStart[2]
			ok

			if NOT (isList(panStart) and len(panStart) = 2 and
				isNumber(panStart[1]) and isNumber(panStart[2]))
	
				stzraise("Incorrect param type! panStart must be a pair of numbers.")
			ok

			if isList(panEnd) and IsToNamedParamList(panEnd)
				panEnd = panEnd[2]
			ok

			if NOT (isList(panEnd) and len(panEnd) = 2 and
				isNumber(panEnd[1]) and isNumber(panEnd[2]))
	
				stzraise("Incorrect param type! panEnd must be a pair of numbers.")
			ok
		ok

		_aResult_ = []

		for i = panStart[1] to panEnd[1]
			_aRow_ = []

			for j = panStart[2] to panEnd[2]
				_aRow_ + [j, i]
			next

			_nLen_ = len(_aRow_)
			for j = 1 to _nLen_
				_aResult_ + _aRow_[j]
			next
		next

		return _aResult_

		def FindNumbersInSection(panStart, panEnd)
			return This.FindElementsInSection(panStart, panEnd)

	# Returns the positions [ row, column ] inside a rectangle of one number or of any of several numbers.
	#
	#   pElmOrMany   a number, or a list of numbers
	#   panStart     the first corner [ row, column ]
	#   panEnd       the last corner [ row, column ]
	#   returns      a list of [ row, column ] pairs
	#   note         a number goes to FindElementInSection and a list to FindTheseElementsInSection
	#   warning      raises an error when pElmOrMany is neither a number nor a list
	#   see          FindElementInSection, FindTheseElementsInSection
	def FindInSection(pElmOrMany, panStart, panEnd)

		if isNumber(pElmOrMany)
			return This.FindElementInSection(pElmOrMany, panStart, panEnd)

		but isList(pElmOrMany)
			# FindTheseElementsInSection, not FindElementsInSection: the latter
			# takes only the section bounds and returns the POSITIONS in it (test
			# 45 documents that), so calling it with an element list raised R20.
			return This.FindTheseElementsInSection(pElmOrMany, panStart, panEnd)
		else
			stzraise("Incorrect param type! pElmOrMany must be a number or a list of numbers.")
		ok

	# Returns the positions [ row, column ] of a number inside the rectangle between two corners, scanning row by row.
	#
	#   pnElm      the number to look for
	#   panStart   the first corner [ row, column ], or :From = pair
	#   panEnd     the last corner [ row, column ], or :To = pair
	#   returns    a list of [ row, column ] pairs; empty when absent
	#   note       the corners are included
	#   see        FindTheseElementsInSection, FindElement
	def FindElementInSection(pnElm, panStart, panEnd)

		if CheckParams()

			if NOT isNumber(pnElm)
				stzraise("Incorrect param type! pnElm must be a number.")
			ok

			if isList(panStart) and IsFromNamedParamList(panStart)
				panStart = panStart[2]
			ok

			if NOT ( isList(panStart) and len(panStart) = 2 and
				 isNumber(panStart[1]) and isNumber(panStart[2]))

				stzraise("Incorrect param type! panStart must be a pair of numbers.")
			ok

			if isList(panEnd) and IsToNamedParamList(panEnd)
				panEnd = panEnd[2]
			ok

			if NOT ( isList(panEnd) and len(panEnd) = 2 and
				isNumber(panEnd[1]) and isNumber(panEnd[2]))

				stzraise("Incorrect param type! panEnd must be a pair of numbers.")
			ok
		ok

		_aResult_ = []

		for i = panStart[1] to panEnd[1]

			for j = panStart[2] to panEnd[2]

				if @aContent[i][j] = pnElm
					_aResult_ + [i, j]
				ok

			next
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def FindThisElementInSection(pnElm, panStart, panEnd)
			return This.FindElementInSection(pnElm, panStart, panEnd)

		def FindNumberInSection(pnElm, panStart, panEnd)
			return This.FindElementInSection(pnElm, panStart, panEnd)

		def FindThisNumberInSection(pnElm, panStart, panEnd)
			return This.FindElementInSection(pnElm, panStart, panEnd)

	# Returns the positions [ row, column ] inside the rectangle between two corners of every cell equal to any of several numbers.
	#
	#   panElms    the numbers to look for
	#   panStart   the first corner [ row, column ], or :From = pair
	#   panEnd     the last corner [ row, column ], or :To = pair
	#   returns    a list of [ row, column ] pairs; empty when none is found
	#   note       the corners are included and the scan goes row by row
	#   see        FindElementInSection, FindElements
		#>
	def FindTheseElementsInSection(panElms, panStart, panEnd)

		if CheckParams()

			if NOT (isList(panElms) and @IsListOfNumbers(panElms))
				stzraise("Incorrect param type! panElms must be a list of numbers.")
			ok

			if isList(panStart) and IsFromNamedParamList(panStart)
				panStart = panStart[2]
			ok

			if NOT (isList(panStart) and len(panStart) = 2 and
				isNumber(panStart[1]) and isNumber(panStart[2]))

				stzraise("Incorrect param type! panStart must be a pair of numbers.")
			ok

			if isList(panEnd) and IsToNamedParamList(panEnd)
				panEnd = panEnd[2]
			ok

			if NOT (isList(panEnd) and len(panEnd) = 2 and
				isNumber(panEnd[1]) and isNumber(panEnd[2]))

				stzraise("Incorrect param type! panEnd must be a pair of numbers.")
			ok
		ok

		# Doing the job

		_anElms_ = U(panElms)
		_aResult_ = []

		for i = panStart[1] to panEnd[1]

			for j = panStart[2] to panEnd[2]

				if StzFindFirst(_anElms_, @aContent[i][j]) > 0
					_aResult_ + [i, j]
				ok

			next
 		next

		return _aResult_

		def FindTheseNumbersInSection(panElms, panStart, panEnd)
			return This.FindTheseElementsInSection(panElms, panStart, panEnd)

	# Returns the numbers of the rectangle between two corners as one flat list, reading column by column.
	#
	#   panStart   the first corner, read as [ column, row ], or :From = pair
	#   panEnd     the last corner, read as [ column, row ], or :To = pair
	#   returns    a flat list of numbers, column by column
	#   note       the matrix is not changed
	#   warning    the corners are read as [ column, row ], the reverse of SubMatrix, so Section([
	#              1, 1 ], [ 2, 3 ]) raises R2 on a 2x3 matrix; a section one column wide comes back
	#              wrapped in one more list
	#   see        SubMatrix, FindElementInSection
	def Section(panStart, panEnd)

		if CheckParams()

			if isList(panStart) and IsFromNamedParamList(panStart)
				panStart = panStart[2]
			ok

			if NOT (isList(panStart) and len(panStart) = 2 and
				isNumber(panStart[1]) and isNumber(panStart[2]))
	
				stzraise("Incorrect param type! panStart must be a pair of numbers.")
			ok

			if isList(panEnd) and IsToNamedParamList(panEnd)
				panEnd = panEnd[2]
			ok

			if NOT (isList(panEnd) and len(panEnd) = 2 and
				isNumber(panEnd[1]) and isNumber(panEnd[2]))
	
				stzraise("Incorrect param type! panEnd must be a pair of numbers.")
			ok
		ok

		_aResult_ = []

		for i = panStart[1] to panEnd[1]
			_aRow_ = []
			for j = panStart[2] to panEnd[2]
				_aRow_ + @aContent[j][i]
			next

			_aResult_ + _aRow_
		next

		return @Merge(_aResult_)

		#< @FunctionFluentForms

		def SectionQ(panStart, panEnd)
			return new stzList(This.Section(panStart, panEnd))

		def SectionQQ(panStart, panEnd)
			return new stzListOfNumbers(This.Section(panStart, panEnd))

		#>

		#< @FunctionAlternativeForm

		def ElementsInSection(panStart, panEnd)
			return This.Section(panStart, panEnd)

			def ElementsInSectionQ(panStart, panEnd)
				return This.SectionQ(panStart, panEnd)

			def ElementsInSectionQQ(panStart, panEnd)
				return This.SectionQQ(panStart, panEnd)

		def NumbersInSection(panStart, panEnd)
			return This.Section(panStart, panEnd)

			def NumbersInSectionQ(panStart, panEnd)
				return This.SectionQ(panStart, panEnd)

			def NumbersInSectionQQ(panStart, panEnd)
				return This.SectionQQ(panStart, panEnd)

		#>

	def ElementsInSectionZ(panStart, panEnd)
		_aResult_ = @Association([
			This.ElementsInSection(panStart, panEnd),
			This.FindElementsInSection(panStart, panEnd)
		])

		return _aResult_

		def NumbersInSectionZ(panStart, panEnd)
			return This.ElementsInSectionZ(panStart, panEnd)

	# Returns a new stzMatrix made of the rows and columns between two corners, both included.
	#
	#   panStart   the first corner [ row, column ]
	#   panEnd     the last corner [ row, column ]
	#   returns    a new stzMatrix
	#   note       the original is not changed
	#   see        Section, Copy
	#@ aka  Creates a submatrix by extracting specific rows and columns
	def SubMatrix(panStart, panEnd)

		if CheckParams()

			if NOT (isList(panStart) and len(panStart) = 2 and
				isNumber(panStart[1]) and isNumber(panStart[2]))
	
				stzraise("Incorrect param type! panStart must be a pair of numbers.")
			ok

			if NOT (isList(panEnd) and len(panEnd) = 2 and
				isNumber(panEnd[1]) and isNumber(panEnd[2]))
	
				stzraise("Incorrect param type! panEnd must be a pair of numbers.")
			ok
		ok

		_aResult_ = []

		for i = panStart[1] to panEnd[1]
			_aRow_ = []
			for j = panStart[2] to panEnd[2]
				_aRow_ + @aContent[i][j]
			next

			_aResult_ + _aRow_
		next

		return new stzMatrix(_aResult_)

		def SubMatrixQ(panStart, panEnd)
			return This.SubMatrix(panStart, panEnd)

	  #----------------------------------#
	 #  REPLACING THINGS IN THE MATRIX  #
	#----------------------------------#

	# Replaces one column with a list of new numbers, changing the matrix in place.
	#
	#   pnCol       the column to replace
	#   panNewCol   the new values, one per row, or written :By = list
	#   returns     nothing; the matrix changes in place
	#   note        any numbers are accepted, zero and negative ones included
	#   warning     raises Can't proceed when the list length differs from the row count
	#   see         ReplaceCols, ReplaceRow
	#@ aka  Replaces a specific column with a given list
	def ReplaceCol(pnCol, panNewCol)

		if CheckParams()

			if NOT isNumber(pnCol)
				stzraise("Incorrect param type! pnCol must be a number.")
			ok

			if isList(panNewCol) and IsByNamedParamList(panNewCol)
				panNewCol = panNewCol[2]
			ok

			if NOT ( isList(panNewCol) and @IsListOfNumbers(panNewCol) )
				stzraise("Incorrect param type! panNewCol must be a list of numbers.")
			ok

		ok

		if len(panNewCol) != @nRows
			stzraise("Can't proceed! Column replacement must match matrix rows.")
		ok
		
		for i = 1 to @nRows
			@aContent[i][pnCol] = panNewCol[i]
		next

	# Replaces several columns with lists of new numbers, changing the matrix in place.
	#
	#   panCols      the columns to replace, positive numbers
	#   panNewCols   a list of new columns, each with one number per row, or written :By = lists
	#   returns      nothing; the matrix changes in place
	#   note         the nth column of panCols takes the nth new column
	#   warning      raises Incorrect param type when a new value is zero or negative, because the
	#                check wants strictly positive numbers; raises when the counts or lengths differ
	#   see          ReplaceCol, ReplaceRows
	#@ aka  Replace multiple columns
	def ReplaceCols(panCols, panNewCols)

		if CheckParams()
			if NOT ( isList(panCols) and @IsListOfNonZeroPositiveNumbers(panCols) )
				stzraise("Incorrect param type! panCols must be a list of strictictly positive numbers.")
			ok

			if isList(panNewCols) and IsByNamedParamList(panNewCols)
				panNewCols = panNewCols[2]
			ok

			if NOT ( isList(panNewCols) and @IsMatrixOfNonZeroPositiveNumbers(panNewCols) )
				stzraise("Incorrect param type! paNewCols must be a list of lists of NonZero positive numbers having the same size.")
			ok
		ok

		# Logical cheks

		_nLenNewCols_ = len(panNewCols)

		if len(panNewCols[1]) != @nRows
			raise("Can't proceed! Replacement columns must match matrix rows")
		ok

		_nLenCols_ = len(panCols)

		if _nLenCols_ != len(panNewCols)
			raise("Can't proceed! Number of columns to replace must match new columns")
		ok

		# Doing the job

		for k = 1 to _nLenCols_

			_nCol_ = panCols[k]

			for i = 1 to @nRows
				@aContent[i][_nCol_] = panNewCols[k][i]
			next
		next

	# Replaces one row with a list of new numbers, changing the matrix in place.
	#
	#   pnRow       the row to replace, a positive number
	#   panNewRow   the new values, one per column, or written :By = list
	#   returns     nothing; the matrix changes in place
	#   note        ReplaceCol has no such limit on the values
	#   warning     raises Incorrect param type when a new value is zero or negative, because the
	#               check wants strictly positive numbers; raises when the list length differs from
	#               the column count
	#   see         ReplaceRows, ReplaceCol
	#@ aka  Replace a specific row
	def ReplaceRow(pnRow, panNewRow)

		if CheckParams()
			if NOT isNumber(pnRow)
				stzraise("Incorrect param type! pnRow must be a number.")
			ok

			if NOT pnRow > 0
				stzraise("Incorrect param value! pnRow must be a NonZero positive number.")
			ok

			if isList(panNewRow) and IsByNamedParamList(panNewRow)
				panNewRow = panNewRow[2]
			ok

			if NOT @IsListOfNonZeroPositiveNumbers(panNewRow)
				stzraise("Incorrect param type! panNewRow must be a list of NonZero positive numbers.")
			ok
		ok

		if len(panNewRow) != @nCols
			raise("Can't proceed! New row must match matrix columns.")
		ok

		@aContent[pnRow] = panNewRow

	# Replaces several rows with lists of new numbers, changing the matrix in place.
	#
	#   panRows     the rows to replace, positive numbers
	#   paNewRows   a list of new rows, each with one number per column, or written :By = lists
	#   returns     nothing; the matrix changes in place
	#   note        the nth row of panRows takes the nth new row
	#   warning     raises Incorrect param type when a new value is zero or negative, because the
	#               check wants strictly positive numbers; raises when the counts or lengths differ
	#   see         ReplaceRow, ReplaceCols
	#@ aka  Replace multiple rows
	def ReplaceRows(panRows, paNewRows)

		if CheckParams()
			if NOT ( isList(panRows) and @IsListOfNonZeroPositiveNumbers(panRows) )
				stzraise("Incorrect param type! panRows must be a list of strictictly positive numbers.")
			ok

			if isList(paNewRows) and IsByOrWithNamedParamList(paNewRows)
				paNewRows = paNewRows[2]
			ok

			if NOT ( isList(paNewRows) and @IsMatrixOfNonZeroPositiveNumbers(paNewRows) )
				stzraise("Incorrect param type! paNewRows must be a list of lists of NonZero positive numbers having the same size.")
			ok
		ok

		_nLenRows_ = len(panRows)

		if _nLenRows_ != len(paNewRows)
			raise("Number of rows to replace must match new rows")
		ok

		for k = 1 to _nLenRows_

			_nRow_ = panRows[k]

			if len(paNewRows[k]) != @nCols
				raise("Replacement row must match matrix columns")
			ok

			@aContent[_nRow_] = paNewRows[k]
		next

	  #------------------------------------#
	 #  REPLACING ELEMENTS IN THE MATRIX  #
	#------------------------------------#

	# Replaces every cell equal to one number by another number, changing the matrix in place.
	#
	#   pnElm      the number to replace
	#   pnNewElm   the new number, or written :By = n, or :ByMany = list to spread several values
	#              over the occurrences
	#   returns    nothing; the matrix changes in place
	#   note       the occurrences are taken row by row
	#   see        ReplaceElementByMany, ReplaceElementAt
	#@ aka  Replacing all the occurrence of an element by a new element
	def ReplaceElement(pnElm, pnNewElm)

		_bXT_ = 0

		if isList(pnNewElm)

			if isString(pnNewElm[1])

				if ( pnNewElm[1] = :ByMany or
			     	     pnNewElm[1] = :WithMany or 
			     	     pnNewElm[1] = :UsingMany )

					pnNewElm[1] = :By

				but ( pnNewElm[1] = :ByManyXT or
			     	     pnNewElm[1] = :WithManyXT or 
			     	     pnNewElm[1] = :UsingManyXT )

					pnNewElm[1] = :ByXT
					_bXT_ = 1
				ok

			ok


			if IsByNamedParamList(pnNewElm)
				pnNEwElm = pnNewElm[2]
			ok

			if NOT _bXT_
				if isNumber(pnNewElm)
					_anTemp_ = []
					_anTemp_ + pnNewElm
					pnNewElm = _anTemp_
				ok
				This.ReplaceElementByMany(pnElm, pnNewElm)
			else
				
				This.ReplaceElementByManyXT(pnElm, pnNewElm[2])
			ok

			return
		ok

		if CheckParams()
			if isList(pnNewElm) and IsByNamedParamList(pnNewElm)
				pnNewElm = pnNewElm[2]
			ok

			if NOT isNumber(pnNewElm)
				stzraise("Incorrect param type! pnNewElm must be a number.")
			ok
		ok

		for i = 1 to @nRows
			for j = 1 to @nCols
				if @aContent[i][j] = pnElm
					@aContent[i][j] = pnNewElm
				ok
			next
		next

		# Replaces every cell equal to one number by another number, changing the matrix in place.
		#
		#   pnElm      the number to replace
		#   pnNewElm   the new number
		#   returns    nothing; the matrix changes in place
		#   see        ReplaceElement
		def ReplaceAllOccurrences(pnElm, pnNewElm)
			This.ReplaceElement(pnElm, pnNewElm)

		# Replaces every cell equal to one number by another number, changing the matrix in place.
		#
		#   pnElm      the number to replace
		#   pnNewElm   the new number
		#   returns    nothing; the matrix changes in place
		#   see        ReplaceElement
		def ReplaceNumber(pnElm, pnNewElm)
			This.ReplaceElement(pnElm, pnNewElm)

	# Puts a new number in the cell at a position, changing the matrix in place.
	#
	#   panRowCol   the position as [ row, column ]
	#   pnNewElm    the new number
	#   returns     nothing; the matrix changes in place
	#   note        the old value is not checked
	#   warning     raises R2 when the position is outside the matrix
	#   see         ReplaceThisElementAt, ReplaceElementsAt
	#@ aka  Replacing any element at the given position by a new element
	def ReplaceElementAt(panRowCol, pnNewElm)

		if CheckParams()

			if NOT (isList(panRowCol) and len(panRowCol) = 2 and
				isNumber(panRowCol[1]) and isNumber(panRowCol[2]) )

				stzraise("Incorrect param types! panRowCol must be a pair of numbers.")
			ok

			if isList(pnNewElm) and IsByNamedParamList(pnNewElm)
				pnNewElm = pnNewElm[2]
			ok

			if NOT isNumber(pnNewElm)
				stzraise("Incorrect param type! pnNewElm must be a number.")
			ok

		ok

		_nRow_ = panRowCol[1]
		_nCol_ = panRowCol[2]

		@aContent[_nRow_][_nCol_] = pnNewElm

		# Puts a new number in the cell at a position, changing the matrix in place.
		#
		#   panRowCol   the position as [ row, column ]
		#   pnNewElm    the new number
		#   returns     nothing; the matrix changes in place
		#   warning     raises R2 when the position is outside the matrix
		#   see         ReplaceElementAt
		def ReplaceNumberAt(panRowCol, pnNewElm)
			This.ReplaceElementAt(panRowCol, pnNewElm)

	# Puts a new number in the cell at a position only when it holds a given number, changing the matrix in place.
	#
	#   pnElm       the number the cell must hold
	#   panRowCol   the position as [ row, column ]
	#   pnNewElm    the new number
	#   returns     nothing; the matrix changes in place
	#   note        the matrix is left unchanged in that case
	#   warning     raises Can't proceed when the cell holds another number, instead of leaving it
	#               alone
	#   see         ReplaceElementAt
	#@ aka  Replacing a given element by a new element, only if it exists at the given posisiton
	def ReplaceThisElementAt(pnElm, panRowCol, pnNewElm)

		if CheckParams()

			if NOT (isList(panRowCol) and len(panRowCol) = 2 and
				isNumber(panRowCol[1]) and isNumber(panRowCol[2]) )

				stzraise("Incorrect param types! panRowCol must be a pair of numbers.")
			ok

			if isList(pnNewElm) and IsByNamedParamList(pnNewElm)
				pnNewElm = pnNewElm[2]
			ok

			if NOT isNumber(pnNewElm)
				stzraise("Incorrect param type! pnNewElm must be a number.")
			ok

		ok

		_nRow_ = panRowCol[1]
		_nCol_ = panRowCol[2]

		if @aContent[_nRow_][_nCol_] = pnElm
			@aContent[_nRow_][_nCol_] = pnNewElm
		else
			stzraise("Can't proceed! pnElm must be equal to the element in position panRowCol.")
		ok

		# Puts a new number in the cell at a position only when it holds a given number, changing the matrix in place.
		#
		#   pnElm       the number the cell must hold
		#   panRowCol   the position as [ row, column ]
		#   pnNewElm    the new number
		#   returns     nothing; the matrix changes in place
		#   warning     raises Can't proceed when the cell holds another number, instead of leaving
		#               it alone
		#   see         ReplaceThisElementAt
		def ReplaceThisNumberAt(pnElm, panRowCol, pnNewElm)
			This.ReplaceThisElementAt(pnElm, panRowCol, pnNewElm)

	# Replaces the cells at several positions by one number, each only when it holds the matching number of a list.
	#
	#   panElms    the numbers expected, the nth at the nth position
	#   panPos     the positions as [ row, column ] pairs
	#   pnNewElm   the new number
	#   returns    nothing; the matrix changes in place
	#   note       a position that does not hold its number, or lies outside the matrix, is skipped
	#              without a message
	#   see        ReplaceThisElementAt, ReplaceElementsAt
	#@ aka  Replacing the occureences of the given elements in the matrix by the given new element, only they exist at the given positions
	def ReplaceTheseElementsAt(panElms, panPos, pnNewElm)

		if CheckParams()
			if NOT isList(panElms)
				stzraise("Incorrect param type! panElms must be a list.")
			ok
	
			if NOT isList(panPos)
				stzraise("Incorrect param type! panPos must be a list of position pairs.")
			ok

			if isList(pnNewElm) and IsByNamedParamList(pnNewElm)
				pnNewElm = pnNewElm[2]
			ok

			if NOT isNumber(pnNewElm)
				stzraise("Incorrect param type! pnNewElm must be a number.")
			ok
		ok

		_nLen_ = len(panPos)
	
		for i = 1 to _nLen_
			_nRow_ = panPos[i][1]
			_nCol_ = panPos[i][2]
	
			if _nRow_ <= @nRows and _nCol_ <= @nCols
				if i <= len(panElms)
					if @aContent[_nRow_][_nCol_] = panElms[i]
						@aContent[_nRow_][_nCol_] = pnNewElm
					ok
				ok
			ok
		next

		# Replaces the cells at several positions by one number, each only when it holds the matching number of a list.
		#
		#   panElms    the numbers expected, the nth at the nth position
		#   panPos     the positions as [ row, column ] pairs
		#   pnNewElm   the new number
		#   returns    nothing; the matrix changes in place
		#   note       a position that does not hold its number is skipped without a message
		#   see        ReplaceTheseElementsAt
		def ReplaceTheseNumbersAt(panElms, panPos, pnNewElm)
			This.ReplaceTheseElementsAt(panElms, panPos, pnNewElm)

	  #--------------------------------#
	 #  REPLACEMENT BY MANY ELEMENTS  #
	#--------------------------------#

	# Replaces the occurrences of a number, taken row by row, by a list of new numbers in order, changing the matrix in place.
	#
	#   pnElm        the number to replace
	#   panNewElms   the new numbers, the first for the first occurrence
	#   returns      nothing; the matrix changes in place
	#   note         extra new numbers are ignored and occurrences beyond the list are left as they
	#                are
	#   see          ReplaceElementByManyXT, ReplaceElement
	#@ aka  Replacing all the occurrences of an element by the given new element
	def ReplaceElementByMany(pnElm, panNewElms)

		if CheckParams()
			if NOT isNumber(pnElm)
				stzraise("Incorrect param type! pnElm must be a number.")
			ok

			if NOT isList(panNewElms)
				stzraise("Incorrect param type! panNewElms must be a list of numbers.")
			ok
		ok

		_aPositions_ = This.FindElement(pnElm)
		_nLen_ = len(_aPositions_)
		_nNewElmsLen_ = len(panNewElms)
    
		# Consider the minimum of occurrences and replacement values

		_nToReplace_ = @min([_nLen_, _nNewElmsLen_])

		for i = 1 to _nToReplace_
			_nRow_ = _aPositions_[i][1]
			_nCol_ = _aPositions_[i][2]
			@aContent[_nRow_][_nCol_] = panNewElms[i]
		next

		# Replaces the occurrences of a number, taken row by row, by a list of new numbers in order, changing the matrix in place.
		#
		#   pnElm        the number to replace
		#   panNewElms   the new numbers, the first for the first occurrence
		#   returns      nothing; the matrix changes in place
		#   note         extra new numbers are ignored and occurrences beyond the list are left as
		#                they are
		#   see          ReplaceElementByMany
		def ReplaceAllOccurrencesByMany(pnElm, panNewElms)
			This.ReplaceElementByMany(pnElm, panNewElms)

		# Replaces the occurrences of a number, taken row by row, by a list of new numbers in order, changing the matrix in place.
		#
		#   pnElm        the number to replace
		#   panNewElms   the new numbers, the first for the first occurrence
		#   returns      nothing; the matrix changes in place
		#   note         extra new numbers are ignored and occurrences beyond the list are left as
		#                they are
		#   see          ReplaceElementByMany
		def ReplaceNumberByMany(pnElm, panNewElms)
			This.ReplaceElementByMany(pnElm, panNewElms)

	def ReplaceElementByManyXT(pnElm, panNewElms)

		if CheckParams()
			if NOT isNumber(pnElm)
				stzraise("Incorrect param type! pnElm must be a number.")
			ok

			if NOT isList(panNewElms)
				stzraise("Incorrect param type! panNewElms must be a list of numbers.")
			ok
		ok

		_aPositions_ = This.FindElement(pnElm)
		_nLen_ = len(_aPositions_)
		_nNewElmsLen_ = len(panNewElms)

		# If no replacement values, exit

		if _nNewElmsLen_ = 0 return ok

		# Replace all occurrences with cycling through replacement values

		for i = 1 to _nLen_
			_nRow_ = _aPositions_[i][1]
			_nCol_ = _aPositions_[i][2]
			_nIndex_ = ((i-1) % _nNewElmsLen_) + 1  # Cycle through new elements
			@aContent[_nRow_][_nCol_] = panNewElms[_nIndex_]
		next

		def ReplaceAllOccurrencesXT(pnElm, panNewElms)
			This.ReplaceElementByManyXT(pnElm, panNewElms)

		def ReplaceNumberByManyXT(pnElm, panNewElms)
			This.ReplaceElementByManyXT(pnElm, panNewElms)

	# Replaces the cells at several positions by the numbers of a list, each only when it holds the matching expected number.
	#
	#   panElms      the numbers expected, the nth at the nth position
	#   panPos       the positions as [ row, column ] pairs
	#   panNewElms   the new numbers, the nth for the nth position
	#   returns      nothing; the matrix changes in place
	#   note         positions that do not hold their expected number are skipped, and the shortest
	#                of the three lists sets how many are tried
	#   see          ReplaceTheseElementsAt, ReplaceElementsAtByMany
	#@ aka  --
	def ReplaceTheseElementsAtByMany(panElms, panPos, panNewElms)

		if CheckParams()

			if NOT isList(panElms)
				stzraise("Incorrect param type! panElms must be a list.")
			ok

			if NOT isList(panPos)
				stzraise("Incorrect param type! panPos must be a list of position pairs.")
			ok

			if NOT isList(panNewElms)
				stzraise("Incorrect param type! panNewElms must be a list of numbers.")
			ok
		ok

		_nLen_ = len(panPos)
		_nElmsLen_ = len(panElms)
		_nNewElmsLen_ = len(panNewElms)

		# Consider minimum of occurrences, elements, and replacement values

		_nToReplace_ = @min([_nLen_, _nElmsLen_, _nNewElmsLen_])

		for i = 1 to _nToReplace_

			_nRow_ = panPos[i][1]
			_nCol_ = panPos[i][2]

			if _nRow_ <= @nRows and _nCol_ <= @nCols

				if @aContent[_nRow_][_nCol_] = panElms[i]
					@aContent[_nRow_][_nCol_] = panNewElms[i]
				ok

			ok
		next

		# Replaces the cells at several positions by the numbers of a list, each only when it holds the matching expected number.
		#
		#   panElms      the numbers expected, the nth at the nth position
		#   panPos       the positions as [ row, column ] pairs
		#   panNewElms   the new numbers, the nth for the nth position
		#   returns      nothing; the matrix changes in place
		#   note         positions that do not hold their expected number are skipped
		#   see          ReplaceTheseElementsAtByMany
		def ReplaceTheseNumbersAtByMany(panElms, panPos, panNewElms)
			This.ReplaceTheseElementsAtByMany(panElms, panPos, panNewElms)

	def ReplaceTheseElementsAtByManyXT(panElms, panPos, panNewElms)

		if CheckParams()

			if NOT isList(panElms)
				stzraise("Incorrect param type! panElms must be a list.")
			ok

			if NOT isList(panPos)
				stzraise("Incorrect param type! panPos must be a list of position pairs.")
			ok

			if NOT isList(panNewElms)
				stzraise("Incorrect param type! panNewElms must be a list of numbers.")
			ok

		ok

		_nLen_ = len(panPos)
		_nElmsLen_ = len(panElms)
		_nNewElmsLen_ = len(panNewElms)

		# If no replacement values, exit

		if _nNewElmsLen_ = 0 return ok

		# Replace elements with cycling through replacement values

		for i = 1 to @min([_nLen_, _nElmsLen_])

			_nRow_ = panPos[i][1]
			_nCol_ = panPos[i][2]

			if _nRow_ <= @nRows and _nCol_ <= @nCols
				if @aContent[_nRow_][_nCol_] = panElms[i]
					_nIndex_ = ((i-1) % _nNewElmsLen_) + 1  # Cycle through new elements
					@aContent[_nRow_][_nCol_] = panNewElms[_nIndex_]
				ok
			ok

		next

		def ReplaceTheseNumbersAtByManyXT(panElms, panPos, panNewElms)
			This.ReplaceTheseElementsAtByManyXT(panElms, panPos, panNewElms)

	# Puts one number, or a list of numbers in order, at several positions, changing the matrix in place.
	#
	#   panPos     the positions as [ row, column ] pairs
	#   pBy        a number for every position, a list of numbers taken in order, :ByMany = list, or
	#              :ByManyXT = list to cycle through the list
	#   returns    nothing; the matrix changes in place
	#   note       the old values are not checked
	#   warning    raises R2 when a position is outside the matrix
	#   see        ReplaceElementsAtByMany, ReplaceElementAt
	#@ aka  --
	def ReplaceElementsAt(panPos, pBy)

		if CheckParams() and isList(pBy)

			# stzListNamedParams, NOT stzList: the named-param vocabulary lives on
			# the dedicated class, and stzList exposes only a handful of it as
			# convenience methods. Asking stzList for IsByManyNamedParam raised R14
			# and took the whole ReplaceElementsAt / ReplaceSection family with it.
			_oList_ = new stzListNamedParams(pBy)

			if _oList_.IsByManyNamedParam()
				This.ReplaceElementsAtByMany(panPos, pBy[2])
				return

			but _oList_.IsByManyXTNamedParam() or _oList_.IsByXTNamedParam()
				This.ReplaceElementsAtByManyXT(panPos, pBy[2])
				return
			ok

			if _oList_.IsByNamedParam()
				pBy = pBy[2]
			ok

			if isList(pBy)
				This.ReplaceElementsAtByMany(panPos, pBy)
				return
			ok

			if NOT isNumber(pBy)
				stzraise("Incorrect param type! pBy must be a number.")
			ok

		ok

		# Doing the job

		_nLen_ = len(panPos)

		for i = 1 to _nLen_
			@aContent[ panPos[i][1] ][ panPos[i][2] ] = pBy
		next

	# Puts the numbers of a list, in order, at several positions, changing the matrix in place.
	#
	#   panPos     the positions as [ row, column ] pairs
	#   panMany    the new numbers, the nth for the nth position
	#   returns    nothing; the matrix changes in place
	#   note       the shorter of the two lists sets how many cells change
	#   see        ReplaceElementsAt
	def ReplaceElementsAtByMany(panPos, panMany)

		if CheckParams()
			if NOT ( isList(panMany) and @IsListOfNumbers(panMany) )
				stzraise("Incorrect param type! panMany must be a list of numbers.")
			ok
		ok

		_nMin_ = @Min([ len(panPos), len(panMany) ])

		for i = 1 to _nMin_
			@aContent[ panPos[i][1] ][ panPos[i][2] ] = panMany[i]
		next
		
	def ReplaceElementsAtByManyXT(panPos, panByMany)

		_nLen_ = len(panPos)
		_nNewElmsLen_ = len(panByMany)

		# If no replacement values, exit

		if _nNewElmsLen_ = 0 return ok

		# Replace all occurrences with cycling through replacement values

		for i = 1 to _nLen_
			_nRow_ = panPos[i][1]
			_nCol_ = panPos[i][2]
			_nIndex_ = ((i-1) % _nNewElmsLen_) + 1  # Cycle through new elements
			@aContent[_nRow_][_nCol_] = panByMany[_nIndex_]
		next

	# Sets every cell of the rectangle between two corners to one number, but changes the wrong cells on a non-square rectangle today.
	#
	#   panStart   the first corner [ row, column ]
	#   panEnd     the last corner [ row, column ]
	#   pBy        the new number
	#   returns    nothing; the matrix changes in place
	#   note       a square rectangle such as [ 1, 1 ] to [ 2, 2 ] is right
	#   warning    takes the cells from FindElementsInSection, whose pairs are [ column, row ]: on a
	#              3x3 matrix ReplaceSection([ 1, 1 ], [ 1, 3 ], 0) zeroes column 1 instead of row
	#              1, and on a 2x3 matrix it raises R2 after changing some cells
	#   see        ReplaceElementInSection, SubMatrix
	def ReplaceSection(panStart, panEnd, pBy)
		_aElmsPos_ = This.FindElementsInSection(panStart, panEnd)
		This.ReplaceElementsAt(_aElmsPos_, pby)

	# Fills the rectangle between two corners with a list of numbers in order, but reads the cells in the wrong order today.
	#
	#   panStart   the first corner [ row, column ]
	#   panEnd     the last corner [ row, column ]
	#   paMany     the new numbers, taken in order
	#   returns    nothing; the matrix changes in place
	#   note       the shorter of the two lists sets how many cells change
	#   warning    takes the cells from FindElementsInSection, whose pairs are [ column, row ]: a
	#              square rectangle is filled down each column in turn, and a non-square rectangle
	#              changes the wrong cells
	#   see        ReplaceSection, ReplaceElementsAtByMany
	def ReplaceSectionByMany(panStart, panEnd, paMany)
		_aElmsPos_ = This.FindElementsInSection(panStart, panEnd)
		This.ReplaceElementsAtByMany(_aElmsPos_, paMany)

		# Fills the rectangle between two corners with a list of numbers in order, but reads the cells in the wrong order today.
		#
		#   panStart   the first corner [ row, column ]
		#   panEnd     the last corner [ row, column ]
		#   paMany     the new numbers, taken in order
		#   returns    nothing; the matrix changes in place
		#   warning    takes the cells from FindElementsInSection, whose pairs are [ column, row ]:
		#              a square rectangle is filled down each column in turn, and a non-square
		#              rectangle changes the wrong cells
		#   see        ReplaceSectionByMany
		def ReplaceElementsInSectionByMany(panStart, panEnd, paMany)
			This.ReplaceSectionByMany(panStart, panEnd, paMany)

	# Replaces every cell equal to one number inside a rectangle by another number, changing the matrix in place.
	#
	#   pnElm      the number to replace
	#   panStart   the first corner [ row, column ]
	#   panEnd     the last corner [ row, column ]
	#   pBy        the new number, or :ByMany = list
	#   returns    nothing; the matrix changes in place
	#   note       the corners are included; cells outside the rectangle are not touched
	#   see        ReplaceTheseElementsInSection, ReplaceElementAt
	def ReplaceElementInSection(pnElm, panStart, panEnd, pBy)
		_aElmsPos_ = This.FindElementInSection(pnElm, panStart, panEnd)
		This.ReplaceElementsAt(_aElmsPos_, pby)

		# Replaces every cell equal to one number inside a rectangle by another number, changing the matrix in place.
		#
		#   pnElm      the number to replace
		#   panStart   the first corner [ row, column ]
		#   panEnd     the last corner [ row, column ]
		#   pBy        the new number
		#   returns    nothing; the matrix changes in place
		#   note       cells outside the rectangle are not touched
		#   see        ReplaceElementInSection
		def ReplaceThisElementInSection(pnElm, panStart, panEnd, pBy)
			This.ReplaceElementInSection(pnElm, panStart, panEnd, pBy)

	# Replaces the occurrences of a number inside a rectangle by a list of new numbers in order, changing the matrix in place.
	#
	#   pnElm      the number to replace
	#   panStart   the first corner [ row, column ]
	#   panEnd     the last corner [ row, column ]
	#   paMany     the new numbers, the first for the first occurrence
	#   returns    nothing; the matrix changes in place
	#   note       the shorter of the two lists sets how many cells change
	#   see        ReplaceElementInSection, ReplaceElementsAtByMany
	def ReplaceElementInSectionByMany(pnElm, panStart, panEnd, paMany)
		# pnElm was being DROPPED here -- the call passed only the bounds into a
		# method that takes (element, start, end), so it raised R20. Its sibling
		# ReplaceElementInSection above has the call right.
		_aElmsPos_ = This.FindElementInSection(pnElm, panStart, panEnd)
		This.ReplaceElementsAtByMany(_aElmsPos_, paMany)

		# Replaces the occurrences of a number inside a rectangle by a list of new numbers in order, changing the matrix in place.
		#
		#   pnElm      the number to replace
		#   panStart   the first corner [ row, column ]
		#   panEnd     the last corner [ row, column ]
		#   paMany     the new numbers, the first for the first occurrence
		#   returns    nothing; the matrix changes in place
		#   note       the shorter of the two lists sets how many cells change
		#   see        ReplaceElementInSectionByMany
		def ReplaceThisElementInSectionByMany(pnElm, panStart, panEnd, paMany)
			This.ReplaceElementInSectionByMany(pnElm, panStart, panEnd, paMany)

	def ReplaceElementInSectionByManyXT(pnElm, panStart, panEnd, paMany)
		# same dropped element as ReplaceElementInSectionByMany above
		_aElmsPos_ = This.FindElementInSection(pnElm, panStart, panEnd)
		This.ReplaceElementsAtByManyXT(_aElmsPos_, paMany)

		def ReplaceThisElementInSectionByManyXT(pnElm, panStart, panEnd, paMany)
			This.ReplaceElementInSectionByManyXT(pnElm, panStart, panEnd, paMany)

	# Replaces every cell inside a rectangle that equals any of several numbers by one new number, in place.
	#
	#   panElms    the numbers to replace
	#   panStart   the first corner [ row, column ]
	#   panEnd     the last corner [ row, column ]
	#   pBy        the new number
	#   returns    nothing; the matrix changes in place
	#   note       cells outside the rectangle are not touched
	#   see        ReplaceElementInSection, FindTheseElementsInSection
	def ReplaceTheseElementsInSection(panElms, panStart, panEnd, pBy)
		_aElmsPos_ = This.FindTheseElementsInSection(panElms, panStart, panEnd)
		This.ReplaceElementsAt(_aElmsPos_, pby)

	# Replaces the cells inside a rectangle that equal any of several numbers by a list of new numbers in order, in place.
	#
	#   panElms    the numbers to replace
	#   panStart   the first corner [ row, column ]
	#   panEnd     the last corner [ row, column ]
	#   paMany     the new numbers, taken in order
	#   returns    nothing; the matrix changes in place
	#   note       the cells are taken row by row; the shorter of the two lists sets how many cells
	#              change
	#   see        ReplaceTheseElementsInSection
	def ReplaceTheseElementsInSectionByMany(panElms, panStart, panEnd, paMany)
		_aElmsPos_ = This.FindTheseElementsInSection(panElms, panStart, panEnd)
		This.ReplaceElementsAtByMany(_aElmsPos_, paMany)

	def ReplaceTheseElementsInSectionByManyXT(panElms, panStart, panEnd, paMany)
		_aElmsPos_ = This.FindTheseElementsInSection(panElms, panStart, panEnd)
		This.ReplaceElementsAtByManyXT(_aElmsPos_, paMany)


	  #-----------------------------#
	 # Specialized Data Extraction #
	#-----------------------------#

	# Returns the main diagonal, the cells from the top left down, as a list of numbers.
	#
	#   returns    a list of min(rows, columns) numbers
	#   note       the matrix is not changed
	#   see        Diagonal2, Trace
	#@ aka  Extracts diagonal elements
	def Diagonal()

		_nMin_ = @min([ @nRows, @nCols ])
		_aDiagonal_ = []

		for i = 1 to _nMin_
			_aDiagonal_ + @aContent[i][i]
		next

		return _aDiagonal_

		# Returns nothing today instead of the main diagonal, because its body is empty.
		#
		#   returns    nothing today
		#   note       the intended answer is the same as Diagonal
		#   warning    the method exists but has no body, so it answers an empty value for every
		#              matrix; Diagonal gives the main diagonal
		#   see        Diagonal
		func Diagonal1()

	# Returns the secondary diagonal, the cells from the top right down, as a list of numbers.
	#
	#   returns    a list of min(rows, columns) numbers
	#   note       the matrix is not changed
	#   see        Diagonal, AddInDiagonal2
	#@ aka  Secondary diagonal elements
	def Diagonal2()

		_nMin_ = @min([@nRows, @nCols])
		_aDiagonal_ = []

		for i = 1 to _nMin_
			_aDiagonal_ + @aContent[i][@nCols - i + 1]
		next

		return _aDiagonal_

	  #-----------------------#
	 # Advanced Calculations #
	#-----------------------#

	# Returns the determinant of a square matrix, the signed volume factor of the transformation it describes.
	#
	#   returns    a number
	#   note       raises an error unless the matrix is square; the engine does the work, with a
	#              recursive Ring fallback efficient up to about 10x10
	#   see        Inverse, Rank, Trace
	#@ aka  Recursive method for calculating determinant ~> Efficient up to ~10x10 matrices
	def Determinant()

		# Only handle square matrices

		if @nRows != @nCols
			raise("Determinant is only defined for square matrices")
		ok

		# Engine fast path
		This._EnsureEngineMatrix()
		if @pEngineMatrix != ""
			return StzEngineMatrixDeterminant(@pEngineMatrix)
		ok

		# Base cases

		if @nRows = 1
			return @aContent[1][1]
		ok

		if @nRows = 2

			return  @aContent[1][1] * @aContent[2][2] - 
				@aContent[1][2] * @aContent[2][1]
		ok

		# Recursive calculation for larger matrices

		_nDeterminant_ = 0
		_nSign_ = 1

		for j = 1 to @nCols

			# Create submatrix

			_aSubMatrix_ = []

			for k = 2 to @nRows

				_aRow_ = []

				for l = 1 to @nCols
					if l != j
						_aRow_ + @aContent[k][l]
					ok
				next

				_aSubMatrix_ + _aRow_
			next

			# Recursive determinant calculation

			_nDeterminant_ += _nSign_ * @aContent[1][j] * 
                        		StzMatrixQ(_aSubMatrix_).Determinant()

			_nSign_ *= -1
		next

		return _nDeterminant_

	# Returns the coefficients x that minimise the length of A x - b, where this matrix is A, using Householder QR.
	#
	#   panB       the observations, a list with one number per row
	#   returns    a list of one coefficient per column; an empty list when the columns are
	#              dependent
	#   note       the LeastSquares and BestFitFor forms answer the same; the matrix is not changed
	#   warning    raises an error when the length of panB differs from the row count, or when there
	#              are fewer rows than columns
	#   see        MinimumNormSolutionFor, SolveFor
	#@ aka  Simple Gaussian elimination for matrix inversion ~> Reliable up to ~50x50 matrices
	def LeastSquaresFor(panB)

		if NOT isList(panB) or len(panB) != @nRows
			StzRaise("LeastSquaresFor: give me one observation per row (" +
			         @nRows + " expected, got " + len(panB) + ").")
		ok

		if @nRows < @nCols
			StzRaise("LeastSquaresFor: an underdetermined system (" + @nRows +
			         " equations, " + @nCols + " unknowns) has infinitely many " +
			         "exact solutions; least squares does not choose between them.")
		ok

		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok

		_aBLs_ = []
		for _iLs_ = 1 to @nRows
			_aBLs_ + [ panB[_iLs_] ]
		next
		_pBLs_ = StzEngineMatrixNewFromList(@nRows, 1, _aBLs_)
		if _pBLs_ = ""
			return []
		ok

		_pXLs_ = StzEngineMatrixLeastSquares(@pEngineMatrix, _pBLs_)
		StzEngineMatrixFree(_pBLs_)
		if _pXLs_ = ""
			return []
		ok

		_anXLs_ = []
		for _jLs_ = 1 to @nCols
			_anXLs_ + StzEngineMatrixGet(_pXLs_, _jLs_ - 1, 0)
		next
		StzEngineMatrixFree(_pXLs_)
		return _anXLs_

		#< @FunctionAlternativeForms

		def LeastSquares(panB)
			return This.LeastSquaresFor(panB)

		def BestFitFor(panB)
			return This.LeastSquaresFor(panB)

	# Returns a real square root of any square matrix, symmetric or not, built from its Schur form.
	#
	#   returns    a list of rows, the root
	#   note       the Q form returns a stzMatrix; the matrix is not changed
	#   warning    raises an error when the matrix has a negative real eigenvalue, whose root is
	#              complex, and it also refuses the nilpotent matrix [ [ 0, 1 ], [ 0, 0 ] ]
	#   see        MatrixSquareRoot, MatrixLog
		#>
	#@ aka  THE MOORE-PENROSE PSEUDO-INVERSE, A+. Works for ANY shape and ANY rank -- wide, tall, square, singular -- which is what makes it the true generalisation of an inverse rather than a fallback for one.
	def GeneralSquareRoot()
		if @nRows = 0 or @nRows != @nCols
			StzRaise("GeneralSquareRoot: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pGsV_ = StzEngineMatrixSqrtGeneral(@pEngineMatrix)
		if _pGsV_ = ""
			StzRaise("GeneralSquareRoot: refused. A negative real eigenvalue has a " +
				"square root, but a COMPLEX one, and this returns real matrices. " +
				"(A complex eigenvalue PAIR is fine -- only a lone negative real is " +
				"the obstacle.)")
		ok
		_aGsV_ = This._MatrixFromHandle(_pGsV_)
		StzEngineMatrixFree(_pGsV_)
		return _aGsV_

		def GeneralSquareRootQ()
			return new stzMatrix(This.GeneralSquareRoot())

	# Returns the matrix cotangent, cos(A) times the inverse of sin(A), as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the function of the matrix, not of each element; the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and for every singular matrix (an
	#              eigenvalue at 0 or at k*pi makes sin(A) singular)
	#   see        MatrixTan, MatrixCoth
	#@ aka  THE MATRIX COTANGENT, and its hyperbolic partner.
	def MatrixCot()
		return This._Cotangent(:Circular)

		def MatrixCotQ()
			return new stzMatrix(This.MatrixCot())

	# Returns the hyperbolic matrix cotangent, cosh(A) times the inverse of sinh(A), as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the function of the matrix, not of each element; the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and for every singular matrix,
	#              because sinh(A) is singular at an eigenvalue 0
	#   see        MatrixCot, MatrixTanh
	def MatrixCoth()
		return This._Cotangent(:Hyperbolic)

		def MatrixCothQ()
			return new stzMatrix(This.MatrixCoth())

	def _Cotangent(pcMode)
		if @nRows = 0 or @nRows != @nCols
			StzRaise("MatrixCot: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		if pcMode = :Circular
			_pCtV_ = StzEngineMatrixCot(@pEngineMatrix)
		else
			_pCtV_ = StzEngineMatrixCoth(@pEngineMatrix)
		ok
		if _pCtV_ = ""
			StzRaise("MatrixCot: refused -- the sine being divided by is singular here. " +
				"For MatrixCot() that means an eigenvalue at k*pi, WHICH INCLUDES ZERO, " +
				"so every singular matrix is out of reach -- the same narrow domain as " +
				"MatrixCsc(), and for the same reason. Note that MatrixTan() would be " +
				"answered on this matrix: it divides by the cosine instead.")
		ok
		_aCtV_ = This._MatrixFromHandle(_pCtV_)
		StzEngineMatrixFree(_pCtV_)
		return _aCtV_

	# Returns the matrix secant, the inverse of cos(A), as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the function of the matrix, not of each element; the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and when an eigenvalue sits at pi/2
	#              + k*pi where cos(A) is singular
	#   see        MatrixCsc, MatrixCos
	#@ aka  THE MATRIX SECANT AND COSECANT, and their hyperbolic partners.
	def MatrixSec()
		return This._Reciprocal("sec")

		def MatrixSecQ()
			return new stzMatrix(This.MatrixSec())

	# Returns the matrix cosecant, the inverse of sin(A), as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the function of the matrix, not of each element; the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and for every singular matrix
	#              because sin(A) is singular at an eigenvalue 0
	#   see        MatrixSec, MatrixSin
	def MatrixCsc()
		return This._Reciprocal("csc")

		def MatrixCscQ()
			return new stzMatrix(This.MatrixCsc())

	# Returns the hyperbolic matrix secant, the inverse of cosh(A), as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the function of the matrix, not of each element; the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square; a real spectrum never makes cosh(A)
	#              singular
	#   see        MatrixSec, MatrixCosh
	def MatrixSech()
		return This._Reciprocal("sech")

		def MatrixSechQ()
			return new stzMatrix(This.MatrixSech())

	# Returns the hyperbolic matrix cosecant, the inverse of sinh(A), as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the function of the matrix, not of each element; the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and for every singular matrix
	#              because sinh(A) is singular at an eigenvalue 0
	#   see        MatrixCsc, MatrixSinh
	def MatrixCsch()
		return This._Reciprocal("csch")

		def MatrixCschQ()
			return new stzMatrix(This.MatrixCsch())

	def _Reciprocal(cWhich)
		if @nRows = 0 or @nRows != @nCols
			StzRaise("MatrixSec/MatrixCsc: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		if cWhich = "sec"
			_pRcV_ = StzEngineMatrixSec(@pEngineMatrix)
		but cWhich = "csc"
			_pRcV_ = StzEngineMatrixCsc(@pEngineMatrix)
		but cWhich = "sech"
			_pRcV_ = StzEngineMatrixSech(@pEngineMatrix)
		else
			_pRcV_ = StzEngineMatrixCsch(@pEngineMatrix)
		ok
		if _pRcV_ = ""
			StzRaise("MatrixSec/MatrixCsc: refused -- the function being inverted is " +
				"singular here. For MatrixSec() that means an eigenvalue at pi/2 + " +
				"k*pi, exactly where sec(x) is undefined. For MatrixCsc() it means an " +
				"eigenvalue at k*pi, WHICH INCLUDES ZERO -- so every singular matrix " +
				"is out of reach, and that is the narrowest domain in this family.")
		ok
		_aRcV_ = This._MatrixFromHandle(_pRcV_)
		StzEngineMatrixFree(_pRcV_)
		return _aRcV_

	# Returns the matrix arcsecant, the arccosine of the inverse, as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, for a singular matrix, and unless
	#              every eigenvalue lies strictly outside [-1, 1]
	#   see        MatrixAcsc, MatrixAcos
	#@ aka  THE MATRIX ARCSECANT AND ARCCOSECANT, and their hyperbolic partners.
	def MatrixAsec()
		return This._ArcReciprocal("asec")

		def MatrixAsecQ()
			return new stzMatrix(This.MatrixAsec())

	# Returns the matrix arccosecant, the arcsine of the inverse, as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, for a singular matrix, and unless
	#              every eigenvalue lies strictly outside [-1, 1]
	#   see        MatrixAsec, MatrixAsin
	def MatrixAcsc()
		return This._ArcReciprocal("acsc")

		def MatrixAcscQ()
			return new stzMatrix(This.MatrixAcsc())

	# Returns the hyperbolic matrix arcsecant, the hyperbolic arccosine of the inverse, as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and unless every eigenvalue is
	#              positive and at most 1 (a singular matrix raises)
	#   see        MatrixAsec, MatrixAcosh
	def MatrixAsech()
		return This._ArcReciprocal("asech")

		def MatrixAsechQ()
			return new stzMatrix(This.MatrixAsech())

	# Returns the hyperbolic matrix arccosecant, the hyperbolic arcsine of the inverse, as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and for a singular matrix; both
	#              signs of eigenvalue are accepted
	#   see        MatrixAcsc, MatrixAsinh
	def MatrixAcsch()
		return This._ArcReciprocal("acsch")

		def MatrixAcschQ()
			return new stzMatrix(This.MatrixAcsch())

	def _ArcReciprocal(cWhich)
		if @nRows = 0 or @nRows != @nCols
			StzRaise("MatrixAsec/MatrixAcsc: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		if cWhich = "asec"
			_pArV_ = StzEngineMatrixAsec(@pEngineMatrix)
		but cWhich = "acsc"
			_pArV_ = StzEngineMatrixAcsc(@pEngineMatrix)
		but cWhich = "asech"
			_pArV_ = StzEngineMatrixAsech(@pEngineMatrix)
		else
			_pArV_ = StzEngineMatrixAcsch(@pEngineMatrix)
		ok
		if _pArV_ = ""
			StzRaise("MatrixAsec/MatrixAcsc: refused -- for one of two distinct reasons. " +
				"Either the matrix is SINGULAR, and all four of these go through the " +
				"inverse; or its eigenvalues are in the wrong half. MatrixAsec() and " +
				"MatrixAcsc() want every eigenvalue OUTSIDE the unit interval -- the " +
				"exact complement of what MatrixAsin() and MatrixAcos() want -- and " +
				"MatrixAsech() wants them positive and inside it, 0 < L <= 1. Note the " +
				"boundary |L| = 1 belongs to NEITHER circular reciprocal: MatrixAsin() " +
				"and MatrixAsec() both pass through (I - A^2)^(-1/2), which dies exactly " +
				"there -- though MatrixAsech(), built on a forward square root, takes " +
				"L = 1 without trouble.")
		ok
		_aArV_ = This._MatrixFromHandle(_pArV_)
		StzEngineMatrixFree(_pArV_)
		return _aArV_

	# Returns the matrix arccotangent, pi/2 times the identity minus the arctangent, as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and where MatrixAtan raises; a
	#              singular matrix is accepted, and an eigenvalue 0 gives pi/2
	#   see        MatrixAtan, MatrixAcoth
	#@ aka  THE MATRIX ARCCOTANGENT, and its hyperbolic partner.
	def MatrixAcot()
		return This._Arccotangent(:Circular)

		def MatrixAcotQ()
			return new stzMatrix(This.MatrixAcot())

	# Returns the hyperbolic matrix arccotangent, the hyperbolic arctangent of the inverse, as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, for a singular matrix, and unless
	#              every eigenvalue lies strictly outside [-1, 1]
	#   see        MatrixAcot, MatrixAtanh
	#@ aka  -- AND HERE THERE IS NO SUBTRACTION TO TAKE --
	def MatrixAcoth()
		return This._Arccotangent(:Hyperbolic)

		def MatrixAcothQ()
			return new stzMatrix(This.MatrixAcoth())

	def _Arccotangent(pcMode)
		if @nRows = 0 or @nRows != @nCols
			StzRaise("MatrixAcot: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		if pcMode = :Circular
			_pAcV_ = StzEngineMatrixAcot(@pEngineMatrix)
		else
			_pAcV_ = StzEngineMatrixAcoth(@pEngineMatrix)
		ok
		if _pAcV_ = ""
			if pcMode = :Circular
				StzRaise("MatrixAcot: refused -- and only where MatrixAtan() is, since " +
					"this is the subtraction (pi/2)I - atan(A) and not a second " +
					"algorithm. A SINGULAR MATRIX IS NOT THE PROBLEM: acot(0) = pi/2, " +
					"and it is answered.")
			else
				StzRaise("MatrixAcoth: refused -- this one genuinely needs the matrix " +
					"INVERTIBLE, because acoth(A) = atanh(A^-1) is its only real route. " +
					"atanh wants |x| < 1 and acoth wants |x| > 1, disjoint domains " +
					"joined only by an imaginary constant, so there is no subtraction " +
					"to take as there was for MatrixAcot(). An eigenvalue at 1 or -1 " +
					"refuses it too, inherited from MatrixAtanh().")
			ok
		ok
		_aAcV_ = This._MatrixFromHandle(_pAcV_)
		StzEngineMatrixFree(_pAcV_)
		return _aAcV_

	# Returns the matrix arcsine as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and unless every eigenvalue lies
	#              strictly between -1 and 1 (an eigenvalue 1 raises)
	#   see        MatrixAcos, MatrixAsinh
	#@ aka  THE MATRIX ARCSINE AND ARCCOSINE.
	def MatrixAsin()
		return This._ArcTrig("asin")

		def MatrixAsinQ()
			return new stzMatrix(This.MatrixAsin())

	# Returns the matrix arccosine, pi/2 times the identity minus the arcsine, as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and unless every eigenvalue lies
	#              strictly between -1 and 1
	#   see        MatrixAsin, MatrixAcosh
	def MatrixAcos()
		return This._ArcTrig("acos")

		def MatrixAcosQ()
			return new stzMatrix(This.MatrixAcos())

	# Returns the hyperbolic matrix arcsine as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square; any real eigenvalue is accepted, but
	#              a complex pair can still be refused
	#   see        MatrixAsin, MatrixAcosh
	#@ aka  THE HYPERBOLIC ARCSINE AND ARCCOSINE, both closed forms in the logarithm:
	def MatrixAsinh()
		return This._ArcTrig("asinh")

		def MatrixAsinhQ()
			return new stzMatrix(This.MatrixAsinh())

	# Returns the hyperbolic matrix arccosine as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and unless every eigenvalue is at
	#              least 1
	#   see        MatrixAcos, MatrixAsinh
	def MatrixAcosh()
		return This._ArcTrig("acosh")

		def MatrixAcoshQ()
			return new stzMatrix(This.MatrixAcosh())

	def _ArcTrig(cWhich)
		if @nRows = 0 or @nRows != @nCols
			StzRaise("MatrixAsin/MatrixAcos: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		if cWhich = "asin"
			_pArV_ = StzEngineMatrixAsin(@pEngineMatrix)
		but cWhich = "acos"
			_pArV_ = StzEngineMatrixAcos(@pEngineMatrix)
		but cWhich = "asinh"
			_pArV_ = StzEngineMatrixAsinh(@pEngineMatrix)
		else
			_pArV_ = StzEngineMatrixAcosh(@pEngineMatrix)
		ok
		if _pArV_ = ""
			StzRaise("MatrixAsin/MatrixAcos/MatrixAsinh/MatrixAcosh: refused. The " +
				"circular pair needs every eigenvalue INSIDE [-1, 1] -- asin(2) has no " +
				"real value and neither has the arcsine of a matrix with an eigenvalue " +
				"at 2. MatrixAcosh() wants the RAY [1, inf) -- positive and at least " +
				"one, NOT the two-sided outside: an eigenvalue at -2 is refused too, by " +
				"the logarithm rather than the square root. " +
				"MatrixAsinh() asks least of all, but wants a REAL spectrum: real " +
				"entries are not the same thing, and a complex pair can still decline.")
		ok
		_aArV_ = This._MatrixFromHandle(_pArV_)
		StzEngineMatrixFree(_pArV_)
		return _aArV_

	# Returns the matrix arctangent as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and when an eigenvalue lies on the
	#              imaginary axis beyond +i or -i
	#   see        MatrixAtanh, MatrixTan
	#@ aka  THE MATRIX ARCTANGENT.
	def MatrixAtan()
		return This._ArcTangent("atan")

		def MatrixAtanQ()
			return new stzMatrix(This.MatrixAtan())

	# Returns the hyperbolic matrix arctangent as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and unless every eigenvalue lies
	#              strictly between -1 and 1
	#   see        MatrixAtan, MatrixTanh
	#@ aka  THE HYPERBOLIC ARCTANGENT: (1/2) [ MatrixLog(I + A) - MatrixLog(I - A) ].
	def MatrixAtanh()
		return This._ArcTangent("atanh")

		def MatrixAtanhQ()
			return new stzMatrix(This.MatrixAtanh())

	def _ArcTangent(cWhich)
		if @nRows = 0 or @nRows != @nCols
			StzRaise("MatrixAtan/MatrixAtanh: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		if cWhich = "atan"
			_pAtV_ = StzEngineMatrixAtan(@pEngineMatrix)
		else
			_pAtV_ = StzEngineMatrixAtanh(@pEngineMatrix)
		ok
		if _pAtV_ = ""
			StzRaise("MatrixAtan/MatrixAtanh: refused. For the circular arctangent " +
				"that means an eigenvalue on the imaginary axis beyond +/- i, which " +
				"are its BRANCH POINTS -- there is no principal value there. For the " +
				"hyperbolic one it means an eigenvalue of +/- 1, where atanh runs to " +
				"infinity exactly as atanh(1) does.")
		ok
		_aAtV_ = This._MatrixFromHandle(_pAtV_)
		StzEngineMatrixFree(_pAtV_)
		return _aAtV_

	# Returns the matrix tangent, sin(A) times the inverse of cos(A), as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and when an eigenvalue sits at pi/2
	#              + k*pi where cos(A) is singular
	#   see        MatrixTanh, MatrixCot
	#@ aka  THE MATRIX TANGENT: MatrixSin() * MatrixCos()^-1.
	def MatrixTan()
		return This._Tangent("tan")

		def MatrixTanQ()
			return new stzMatrix(This.MatrixTan())

	# Returns the hyperbolic matrix tangent, sinh(A) times the inverse of cosh(A), as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square; a real spectrum never makes it fail
	#   see        MatrixTan, MatrixCoth
	#@ aka  THE HYPERBOLIC TANGENT: MatrixSinh() * MatrixCosh()^-1.
	def MatrixTanh()
		return This._Tangent("tanh")

		def MatrixTanhQ()
			return new stzMatrix(This.MatrixTanh())

	def _Tangent(cWhich)
		if @nRows = 0 or @nRows != @nCols
			StzRaise("MatrixTan/MatrixTanh: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		if cWhich = "tan"
			_pTnV_ = StzEngineMatrixTan(@pEngineMatrix)
		else
			_pTnV_ = StzEngineMatrixTanh(@pEngineMatrix)
		ok
		if _pTnV_ = ""
			StzRaise("MatrixTan/MatrixTanh: refused -- the cosine of this matrix is " +
				"singular, so the tangent does not exist. For the circular tangent " +
				"that means an eigenvalue at pi/2 + k*pi, exactly as tan(pi/2) is " +
				"undefined; for the hyperbolic one it takes a purely imaginary " +
				"eigenvalue, which a real spectrum cannot produce.")
		ok
		_aTnV_ = This._MatrixFromHandle(_pTnV_)
		StzEngineMatrixFree(_pTnV_)
		return _aTnV_

	# Returns the hyperbolic matrix sine as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the function of the matrix, not of each element; the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square
	#   see        MatrixCosh, MatrixSin
	#@ aka  THE HYPERBOLIC MATRIX SINE AND COSINE.
	def MatrixSinh()
		return This._Hyperbolic("sinh")

		def MatrixSinhQ()
			return new stzMatrix(This.MatrixSinh())

	# Returns the hyperbolic matrix cosine as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the function of the matrix, not of each element; the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square
	#   see        MatrixSinh, MatrixCos
	def MatrixCosh()
		return This._Hyperbolic("cosh")

		def MatrixCoshQ()
			return new stzMatrix(This.MatrixCosh())

	def _Hyperbolic(cWhich)
		if @nRows = 0 or @nRows != @nCols
			StzRaise("MatrixSinh/MatrixCosh: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		if cWhich = "sinh"
			_pHyV_ = StzEngineMatrixSinh(@pEngineMatrix)
		else
			_pHyV_ = StzEngineMatrixCosh(@pEngineMatrix)
		ok
		if _pHyV_ = ""
			StzRaise("MatrixSinh/MatrixCosh: the engine refused this matrix.")
		ok
		_aHyV_ = This._MatrixFromHandle(_pHyV_)
		StzEngineMatrixFree(_pHyV_)
		return _aHyV_

	# Returns the matrix sine as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the function of the matrix, not of each element: sin of a zero matrix is zero;
	#              the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square
	#   see        MatrixCos, MatrixSinh
	#@ aka  THE MATRIX SINE AND COSINE.
	def MatrixSin()
		return This._Trig("sin")

		def MatrixSinQ()
			return new stzMatrix(This.MatrixSin())

	# Returns the matrix cosine as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the function of the matrix, not of each element: cos of a zero matrix is the
	#              identity; the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square
	#   see        MatrixSin, MatrixCosh
	def MatrixCos()
		return This._Trig("cos")

		def MatrixCosQ()
			return new stzMatrix(This.MatrixCos())

	def _Trig(cWhich)
		if @nRows = 0 or @nRows != @nCols
			StzRaise("MatrixSin/MatrixCos: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		if cWhich = "sin"
			_pTgV_ = StzEngineMatrixSin(@pEngineMatrix)
		else
			_pTgV_ = StzEngineMatrixCos(@pEngineMatrix)
		ok
		if _pTgV_ = ""
			StzRaise("MatrixSin/MatrixCos: the engine refused this matrix.")
		ok
		_aTgV_ = This._MatrixFromHandle(_pTgV_)
		StzEngineMatrixFree(_pTgV_)
		return _aTgV_

	# Returns the matrix logarithm, the matrix X with MatrixExp(X) equal to this matrix, as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, for a singular matrix, and for a
	#              negative real eigenvalue
	#   see        MatrixExp, GeneralPower
	#@ aka  THE MATRIX LOGARITHM: the X with MatrixExp(X) = A.
	def MatrixLog()
		if @nRows = 0 or @nRows != @nCols
			StzRaise("MatrixLog: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pMlV_ = StzEngineMatrixLog(@pEngineMatrix)
		if _pMlV_ = ""
			StzRaise("MatrixLog: refused. A SINGULAR matrix has no logarithm at all -- " +
				"the exponential is never singular, so nothing maps to it. And a " +
				"NEGATIVE REAL eigenvalue has only a complex logarithm, for the same " +
				"reason it has only a complex square root.")
		ok
		_aMlV_ = This._MatrixFromHandle(_pMlV_)
		StzEngineMatrixFree(_pMlV_)
		return _aMlV_

		def MatrixLogQ()
			return new stzMatrix(This.MatrixLog())

	# Returns the matrix raised to any real power, as exp(p log A), for a matrix with no symmetry required.
	#
	#   p          the exponent, any real number
	#   returns    a list of rows, the same size as the matrix
	#   note       prefer repeated multiplication for a whole-number power; the Q form returns a
	#              stzMatrix
	#   warning    raises an error unless the matrix is square, for a singular matrix, and for a
	#              negative real eigenvalue
	#   see        MatrixPower, MatrixLog
	#@ aka  A RAISED TO ANY REAL POWER, for a matrix with no symmetry: exp(p * log(A)).
	def GeneralPower(p)
		if @nRows = 0 or @nRows != @nCols
			StzRaise("GeneralPower: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pGpV_ = StzEngineMatrixPowerGeneral(@pEngineMatrix, p)
		if _pGpV_ = ""
			StzRaise("GeneralPower: refused -- it goes through the logarithm, so it " +
				"needs a non-singular matrix with no negative real eigenvalue.")
		ok
		_aGpV_ = This._MatrixFromHandle(_pGpV_)
		StzEngineMatrixFree(_pGpV_)
		return _aGpV_

		def GeneralPowerQ(p)
			return new stzMatrix(This.GeneralPower(p))

	# Returns the matrix exponential as a list of rows, by scaling and squaring with a Pade approximant.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the exponential of the matrix, not of each element: exp of a zero matrix is the
	#              identity; the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square
	#   see        MatrixLog, MatrixSin
	#@ aka  THE MATRIX EXPONENTIAL -- and it does NOT want a Schur decomposition.
	def MatrixExp()
		if @nRows = 0 or @nRows != @nCols
			StzRaise("MatrixExp: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pMeV_ = StzEngineMatrixExp(@pEngineMatrix)
		if _pMeV_ = ""
			StzRaise("MatrixExp: the Pade denominator came out singular, which means " +
				"the scaling did not bring this matrix into range.")
		ok
		_aMeV_ = This._MatrixFromHandle(_pMeV_)
		StzEngineMatrixFree(_pMeV_)
		return _aMeV_

		def MatrixExpQ()
			return new stzMatrix(This.MatrixExp())

	# Returns the orthogonal factor Q of the Schur decomposition A = Q T Q', as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the SchurQQ form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, or when the QR iteration does not
	#              converge
	#   see        SchurT, GeneralSquareRoot
	#@ aka  -- THE SCHUR DECOMPOSITION: A = Q T Q', with Q ORTHOGONAL --
	def SchurQ()
		return This._SchurPart("q")

		def SchurQQ()
			return new stzMatrix(This.SchurQ())

	# Returns the quasi-triangular factor T of the Schur decomposition A = Q T Q', as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       1x1 blocks on the diagonal for real eigenvalues, 2x2 for complex pairs; the
	#              SchurTQ form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, or when the QR iteration does not
	#              converge
	#   see        SchurQ, GeneralSquareRoot
	def SchurT()
		return This._SchurPart("t")

		def SchurTQ()
			return new stzMatrix(This.SchurT())

	def _SchurPart(cWhich)
		if @nRows = 0 or @nRows != @nCols
			StzRaise("Schur: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		if cWhich = "q"
			_pScV_ = StzEngineMatrixSchurQ(@pEngineMatrix)
		else
			_pScV_ = StzEngineMatrixSchurT(@pEngineMatrix)
		ok
		if _pScV_ = ""
			StzRaise("Schur: the QR iteration did not converge on this matrix.")
		ok
		_aScV_ = This._MatrixFromHandle(_pScV_)
		StzEngineMatrixFree(_pScV_)
		return _aScV_

	# Returns the inverse computed as Q T^-1 Q' from the Schur form, a slower route to the usual inverse.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       LUInverse reaches the same answer by direct factorisation and is the one to
	#              prefer
	#   warning    raises an error unless the matrix is square, and for a numerically singular one
	#   see        LUInverse, PseudoInverse
	#@ aka  A^-1 = Q T^-1 Q'. CORRECT, AND THE WRONG ROUTE TO USE.
	def SchurInverse()
		if @nRows = 0 or @nRows != @nCols
			StzRaise("SchurInverse: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pSiV_ = StzEngineMatrixSchurInverse(@pEngineMatrix)
		if _pSiV_ = ""
			StzRaise("SchurInverse: refused -- this matrix is numerically singular, " +
				"so T has a diagonal block that cannot be inverted. PseudoInverse() " +
				"answers instead. And for a matrix that IS invertible, LUInverse() " +
				"reaches the same answer by a direct factorisation rather than an " +
				"iterative one.")
		ok
		_aSiV_ = This._MatrixFromHandle(_pSiV_)
		StzEngineMatrixFree(_pSiV_)
		return _aSiV_

		def SchurInverseQ()
			return new stzMatrix(This.SchurInverse())

	# Returns the inverse of a square matrix by LU factorisation, the fastest route for a general invertible matrix.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Q form returns a stzMatrix; the matrix is not changed
	#   warning    raises an error unless the matrix is square, and for a numerically singular one
	#              (PseudoInverse answers there)
	#   see        QRInverse, CholeskyInverse, PseudoInverse
	#@ aka  -- INVERTING AN LU DECOMPOSITION: the fastest general square route --
	def LUInverse()
		if @nRows = 0 or @nRows != @nCols
			StzRaise("LUInverse: this needs a square matrix. For a tall one, " +
				"QRInverse() gives the pseudo-inverse; for any shape at all, " +
				"PseudoInverse() does.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pLuV_ = StzEngineMatrixLUInverse(@pEngineMatrix)
		if _pLuV_ = ""
			StzRaise("LUInverse: refused -- the factorisation found a pivot at " +
				"rounding level, so this matrix is numerically singular and has no " +
				"inverse. PseudoInverse() answers instead, with the minimum-norm " +
				"least-squares operator, which is the principled thing to return " +
				"when a true inverse does not exist.")
		ok
		_aLuV_ = This._MatrixFromHandle(_pLuV_)
		StzEngineMatrixFree(_pLuV_)
		return _aLuV_

		def LUInverseQ()
			return new stzMatrix(This.LUInverse())

	# Returns the inverse by QR factorisation, which for a tall full-rank matrix is its pseudo-inverse.
	#
	#   returns    a list of columns-by-rows numbers, the inverse or pseudo-inverse
	#   note       needs at least as many rows as columns; the Q form returns a stzMatrix
	#   warning    raises an error for a wide matrix, and for a rank-deficient one
	#   see        LUInverse, PseudoInverse
	#@ aka  -- INVERTING A QR DECOMPOSITION: the route for a matrix with no symmetry --
	def QRInverse()
		if @nRows = 0 or @nCols = 0 or @nRows < @nCols
			StzRaise("QRInverse: this needs at least as many rows as columns. A wide " +
				"matrix has no QR inverse in this sense -- PseudoInverse() is the one " +
				"that answers for every shape.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pQiV_ = StzEngineMatrixQRInverse(@pEngineMatrix)
		if _pQiV_ = ""
			StzRaise("QRInverse: refused -- this matrix is rank deficient, so R has a " +
				"diagonal entry at rounding level and back-substituting through it " +
				"would return confident garbage. Use PseudoInverse(): a rank-deficient " +
				"system has infinitely many least-squares solutions, and picking the " +
				"minimum-norm one needs singular values rather than a triangular factor.")
		ok
		_aQiV_ = []
		for _iQi_ = 1 to @nCols
			_aRowQi_ = []
			for _jQi_ = 1 to @nRows
				_aRowQi_ + StzEngineMatrixGet(_pQiV_, _iQi_ - 1, _jQi_ - 1)
			next
			_aQiV_ + _aRowQi_
		next
		StzEngineMatrixFree(_pQiV_)
		return _aQiV_

		def QRInverseQ()
			return new stzMatrix(This.QRInverse())

	# Returns the inverse of a symmetric positive-definite matrix through its Cholesky factor, the cheapest route.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       its source comment measures it about 19 times faster than MatrixPower(-1) on a
	#              120x120 matrix; the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and when it is not symmetric
	#              positive definite
	#   see        LUInverse, CholeskyFactor
	#@ aka  -- INVERTING A CHOLESKY DECOMPOSITION: the same inverse, the cheapest road --
	def CholeskyInverse()
		if @nRows = 0 or @nRows != @nCols
			StzRaise("CholeskyInverse: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pCiV_ = StzEngineMatrixCholeskyInverse(@pEngineMatrix)
		if _pCiV_ = ""
			StzRaise("CholeskyInverse: refused -- this matrix is not symmetric " +
				"positive definite, so it has no real triangular factor and there is " +
				"no Cholesky inverse to have. It may still HAVE an inverse: try " +
				"MatrixPower(-1) or PseudoInverse(), which do not need positive " +
				"definiteness.")
		ok
		_aCiV_ = This._MatrixFromHandle(_pCiV_)
		StzEngineMatrixFree(_pCiV_)
		return _aCiV_

		def CholeskyInverseQ()
			return new stzMatrix(This.CholeskyInverse())

	# Returns the inverse of the Cholesky factor L, a triangular whitening matrix, as a list of rows.
	#
	#   returns    a list of rows, lower triangular
	#   note       differs from WhiteningMatrix, which is symmetric: both whiten, neither is more
	#              correct; the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and when it is not symmetric
	#              positive definite
	#   see        CholeskyFactor, WhiteningMatrix
	#@ aka  THE INVERSE OF THE FACTOR ITSELF, and it is a WHITENING MATRIX.
	def CholeskyFactorInverse()
		if @nRows = 0 or @nRows != @nCols
			StzRaise("CholeskyFactorInverse: this needs a square matrix.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pCfV_ = StzEngineMatrixCholeskyFactorInverse(@pEngineMatrix)
		if _pCfV_ = ""
			StzRaise("CholeskyFactorInverse: refused -- this matrix is not symmetric " +
				"positive definite, so it has no triangular factor to invert.")
		ok
		_aCfV_ = This._MatrixFromHandle(_pCfV_)
		StzEngineMatrixFree(_pCfV_)
		return _aCfV_

		def CholeskyFactorInverseQ()
			return new stzMatrix(This.CholeskyFactorInverse())

	# Returns a symmetric matrix raised to a real power through its eigendecomposition, as a list of rows.
	#
	#   p          the exponent, any real number
	#   returns    a list of rows, the same size as the matrix
	#   note       not Power: that one raises every element to a power; the Q form returns a
	#              stzMatrix
	#   warning    raises an error unless the matrix is square and symmetric; a negative power also
	#              needs it non-singular and a fractional power non-negative eigenvalues
	#   see        GeneralPower, MatrixSquareRoot
	#@ aka  -- INVERTING AN EIGENDECOMPOSITION, which is one power among several --
	def MatrixPower(p)
		if @nRows = 0 or @nRows != @nCols
			StzRaise("MatrixPower: this needs a square matrix -- an eigendecomposition " +
				"of anything else does not exist. For a rectangular one, LowRank() and " +
				"PseudoInverse() are the operations that do.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pMpV_ = StzEngineMatrixMatrixPower(@pEngineMatrix, p)
		if _pMpV_ = ""
			StzRaise("MatrixPower: refused. The matrix must be symmetric; a negative " +
				"power also needs it non-singular, and a fractional power needs every " +
				"eigenvalue non-negative. Refused rather than returned as NaN, because " +
				"a NaN travels quietly through everything downstream.")
		ok
		_aMpV_ = This._MatrixFromHandle(_pMpV_)
		StzEngineMatrixFree(_pMpV_)
		return _aMpV_

		def MatrixPowerQ(p)
			return new stzMatrix(This.MatrixPower(p))

	# Returns the principal square root of a symmetric positive semi-definite matrix, itself symmetric, as a list of rows.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       MatrixPower(0.5); the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square and symmetric with no negative
	#              eigenvalue
	#   see        MatrixPower, GeneralSquareRoot
	#@ aka  THE PRINCIPAL SQUARE ROOT: symmetric, positive semi-definite, and unique.
	def MatrixSquareRoot()
		return This.MatrixPower(0.5)

		def MatrixSquareRootQ()
			return new stzMatrix(This.MatrixSquareRoot())

	# Returns the symmetric whitening transform A^-0.5, the matrix W with W A W equal to the identity.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       MatrixPower(-0.5); the Q form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, symmetric and positive definite
	#   see        MatrixPower, CholeskyFactorInverse
	#@ aka  THE WHITENING TRANSFORM, A^-0.5: the matrix W for which W A W is the identity.
	def WhiteningMatrix()
		return This.MatrixPower(-0.5)

		def WhiteningMatrixQ()
			return new stzMatrix(This.WhiteningMatrix())

	# Returns a symmetric matrix rebuilt from its k leading eigenpairs, as a list of rows.
	#
	#   k          how many of the largest eigenpairs to keep, at least 1
	#   returns    a list of rows, the same size as the matrix
	#   note       for a symmetric positive-definite matrix it equals LowRank(k); the Q form returns
	#              a stzMatrix
	#   warning    raises an error unless the matrix is square and symmetric, or when k is below 1
	#   see        LowRank, EigenValues
	#@ aka  A rebuilt from its k leading eigenpairs. For a symmetric positive-definite matrix this and LowRank() agree exactly -- the singular values ARE the eigenvalues -- and they are kept separate so that a caller thinking in eigenpairs need not reach for a different factorisation to ask the question.
	def EigenReconstructed(k)
		if @nRows = 0 or @nRows != @nCols
			StzRaise("EigenReconstructed: this needs a square matrix.")
		ok
		if NOT isNumber(k) or k < 1
			StzRaise("EigenReconstructed: k must be at least 1.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pErV_ = StzEngineMatrixEigenReconstruct(@pEngineMatrix, k)
		if _pErV_ = ""
			StzRaise("EigenReconstructed: refused -- the matrix must be symmetric.")
		ok
		_aErV_ = This._MatrixFromHandle(_pErV_)
		StzEngineMatrixFree(_pErV_)
		return _aErV_

		def EigenReconstructedQ(k)
			return new stzMatrix(This.EigenReconstructed(k))

	# read an engine handle back as a Ring list, in this matrix's own shape
	def _MatrixFromHandle(pHandle)
		_aMfh_ = []
		for _iMfh_ = 1 to @nRows
			_aRowMfh_ = []
			for _jMfh_ = 1 to @nCols
				_aRowMfh_ + StzEngineMatrixGet(pHandle, _iMfh_ - 1, _jMfh_ - 1)
			next
			_aMfh_ + _aRowMfh_
		next
		return _aMfh_

	# Returns the best rank-k approximation of the matrix, from its k largest singular values, as a list of rows.
	#
	#   k          how many singular values to keep, at least 1
	#   returns    a list of rows, the same size as the matrix
	#   note       works for any shape; keeping every value returns the matrix itself; the Q form
	#              returns a stzMatrix
	#   warning    raises an error when k is below 1
	#   see        EigenReconstructed, SVD
	#@ aka  -- THE OTHER SENSE OF INVERTING AN SVD: the best rank-k approximation --
	def LowRank(k)
		if @nRows = 0 or @nCols = 0
			StzRaise("LowRank: the matrix is empty.")
		ok
		if NOT isNumber(k) or k < 1
			StzRaise("LowRank: k must be at least 1 -- a rank-zero approximation is " +
				"the zero matrix, which needs no decomposition to find.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pLrV_ = StzEngineMatrixLowRank(@pEngineMatrix, k)
		if _pLrV_ = ""
			return []
		ok
		_aLrV_ = []
		for _iLr_ = 1 to @nRows
			_aRowLr_ = []
			for _jLr_ = 1 to @nCols
				_aRowLr_ + StzEngineMatrixGet(_pLrV_, _iLr_ - 1, _jLr_ - 1)
			next
			_aLrV_ + _aRowLr_
		next
		StzEngineMatrixFree(_pLrV_)
		return _aLrV_

		def LowRankQ(k)
			return new stzMatrix(This.LowRank(k))

	# Returns the Moore-Penrose pseudo-inverse, defined for every shape and rank, as a list of rows.
	#
	#   returns    a list of columns-by-rows numbers
	#   note       for an invertible matrix it is the ordinary inverse; the MoorePenroseInverse form
	#              answers the same
	#   see        Inverse, QRInverse, MinimumNormSolutionFor
	def PseudoInverse()

		if @nRows = 0 or @nCols = 0
			StzRaise("PseudoInverse: the matrix is empty.")
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pPiV_ = StzEngineMatrixPseudoInverse(@pEngineMatrix)
		if _pPiV_ = ""
			return []
		ok
		# A is nRows x nCols, so A+ is nCols x nRows
		_aPiV_ = []
		for _iPi_ = 1 to @nCols
			_aRowPi_ = []
			for _jPi_ = 1 to @nRows
				_aRowPi_ + StzEngineMatrixGet(_pPiV_, _iPi_ - 1, _jPi_ - 1)
			next
			_aPiV_ + _aRowPi_
		next
		StzEngineMatrixFree(_pPiV_)
		return _aPiV_

		#< @FunctionAlternativeForms

		def MoorePenroseInverse()
			return This.PseudoInverse()

	# Returns the shortest vector among the least-squares solutions of A x = b, where this matrix is A.
	#
	#   panB       the right-hand side, a list with one number per row
	#   returns    a list of one number per column
	#   note       answers for rank-deficient and underdetermined systems where LeastSquaresFor
	#              refuses; the MinimumNormSolution form answers the same
	#   warning    raises an error when the length of panB differs from the row count
	#   see        LeastSquaresFor, PseudoInverse
		#>
	#@ aka  THE MINIMUM-NORM LEAST-SQUARES SOLUTION, x = A+b.
	def MinimumNormSolutionFor(panB)

		if NOT isList(panB) or len(panB) != @nRows
			StzRaise("MinimumNormSolutionFor: give me one observation per row (" +
			         @nRows + " expected, got " + len(panB) + ").")
		ok

		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok

		_aBMn_ = []
		for _iMn_ = 1 to @nRows
			_aBMn_ + [ panB[_iMn_] ]
		next
		_pBMn_ = StzEngineMatrixNewFromList(@nRows, 1, _aBMn_)
		if _pBMn_ = ""
			return []
		ok

		_pXMn_ = StzEngineMatrixMinNormSolve(@pEngineMatrix, _pBMn_)
		StzEngineMatrixFree(_pBMn_)
		if _pXMn_ = ""
			return []
		ok

		_anXMn_ = []
		for _jMn_ = 1 to @nCols
			_anXMn_ + StzEngineMatrixGet(_pXMn_, _jMn_ - 1, 0)
		next
		StzEngineMatrixFree(_pXMn_)
		return _anXMn_

		#< @FunctionAlternativeForms

		def MinimumNormSolution(panB)
			return This.MinimumNormSolutionFor(panB)

	# Returns the lower-triangular Cholesky factor L, with the matrix equal to L times its transpose, as a list of rows.
	#
	#   returns    a list of rows, or an empty list when the matrix is not symmetric positive
	#              definite
	#   note       the cells above the diagonal are zero
	#   warning    raises an error unless the matrix is square
	#   see        CholeskyInverse, IsPositiveDefinite
		#>
	#@ aka  The Cholesky factor L, where A = L * L-transpose. Lower triangular, zeros above the diagonal. Returns [] when the matrix is not symmetric positive definite -- the factorisation exists exactly when that property holds, which is what makes IsPositiveDefinite() below cheap.
	def CholeskyFactor()

		if @nRows != @nCols
			StzRaise("CholeskyFactor is only defined for square matrices.")
		ok

		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok

		_pLCh_ = StzEngineMatrixCholesky(@pEngineMatrix)
		if _pLCh_ = ""
			return []
		ok

		_aLCh_ = []
		for _iCh_ = 1 to @nRows
			_aRowCh_ = []
			for _jCh_ = 1 to @nCols
				_aRowCh_ + StzEngineMatrixGet(_pLCh_, _iCh_ - 1, _jCh_ - 1)
			next
			_aLCh_ + _aRowCh_
		next
		StzEngineMatrixFree(_pLCh_)
		return _aLCh_

	# Returns the eigenvalues as plain numbers: largest first for a symmetric matrix, in the order found for any other.
	#
	#   returns    a list of numbers, one per row
	#   note       the matrix is not changed
	#   warning    raises an error unless the matrix is square, and when the matrix has complex
	#              eigenvalues (use ComplexEigenValues)
	#   see        ComplexEigenValues, EigenVectors
	#@ aka  EIGENVALUES of a symmetric matrix, sorted DESCENDING -- the convention PCA expects, so the first is the dominant one.
	def EigenValues()

		if @nRows != @nCols
			StzRaise("EigenValues is only defined for square matrices.")
		ok
		# PHASE 7 LIFTED THE OLD REFUSAL. This used to raise for ANY non-symmetric
		# matrix, because a general one can have complex eigenvalues and there was
		# no complex type. There is now (stzComplex), and a Francis double-shift QR
		# behind it, so a non-symmetric matrix with a REAL spectrum is answered
		# normally -- an upper-triangular matrix, a companion matrix, a Markov
		# transition. What still raises is a matrix whose eigenvalues are genuinely
		# complex, because this method's contract is a list of numbers and quietly
		# dropping an imaginary part is exactly the kind of plausible wrong answer
		# the original refusal existed to prevent. ComplexEigenValues() is the door.
		if NOT This.IsSymmetric()
			_aZs_ = This.ComplexEigenValues()
			_anReal_ = []
			for _iZ_ = 1 to len(_aZs_)
				if NOT _aZs_[_iZ_].IsReal()
					StzRaise("EigenValues: this matrix has complex eigenvalues (" +
					         _aZs_[_iZ_].Content() + " among them), and this method " +
					         "returns plain numbers. Use ComplexEigenValues().")
				ok
				_anReal_ + _aZs_[_iZ_].RealPart()
			next
			return _anReal_
		ok

		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pEvV_ = StzEngineMatrixEigenValues(@pEngineMatrix)
		if _pEvV_ = ""
			return []
		ok
		_anEvV_ = []
		for _iEv_ = 1 to @nRows
			_anEvV_ + StzEngineMatrixGet(_pEvV_, _iEv_ - 1, 0)
		next
		StzEngineMatrixFree(_pEvV_)
		return _anEvV_

	# Returns every eigenvalue, complex ones included, as a list of stzComplex objects in the order they were found.
	#
	#   returns    a list of stzComplex, one per row
	#   note       a rotation such as [ [ 0, -1 ], [ 1, 0 ] ] gives i and -i
	#   warning    raises an error unless the matrix is square, or when the QR iteration does not
	#              converge
	#   see        EigenValues, ComplexEigenVectors
	#@ aka  EVERY eigenvalue, complex ones included, as stzComplex objects (phase 7).
	def ComplexEigenValues()

		if @nRows != @nCols
			StzRaise("ComplexEigenValues is only defined for square matrices.")
		ok

		_aFlatCe_ = []
		for _iCe_ = 1 to @nRows
			for _jCe_ = 1 to @nCols
				_aFlatCe_ + @aContent[_iCe_][_jCe_]
			next
		next

		_aPairsCe_ = StzEngineEigenGeneral(_aFlatCe_, @nRows)
		if NOT isList(_aPairsCe_) or len(_aPairsCe_) != @nRows * 2
			StzRaise("ComplexEigenValues: the QR iteration did not converge on " +
			         "this matrix.")
		ok

		_aOutCe_ = []
		for _iCe_ = 1 to @nRows
			_aOutCe_ + new stzComplex(_aPairsCe_[(_iCe_ - 1) * 2 + 1],
			                          _aPairsCe_[(_iCe_ - 1) * 2 + 2])
		next
		return _aOutCe_

	# Returns the eigenvectors, complex ones included, as a matrix of stzComplex objects with one eigenvector per column.
	#
	#   returns    a list of rows of stzComplex; column j belongs to the jth complex eigenvalue
	#   note       each vector has unit length with its largest part real and positive
	#   warning    raises an error unless the matrix is square
	#   see        EigenVectors, ComplexEigenValues
	#@ aka  EVERY eigenvector, complex ones included (phase 7, second pass). Row i, column j is component i of the eigenvector belonging to ComplexEigenValues()[j].
	def ComplexEigenVectors()
		return This._EigenSystem()[:vectors]

	# Returns how many linearly independent eigenvectors the matrix has.
	#
	#   returns    a number, at most the row count
	#   note       [ [ 1, 1 ], [ 0, 1 ] ] has one
	#   warning    raises an error unless the matrix is square
	#   see        IsDefective, EigenVectors
	#@ aka  How many of the eigenvectors are linearly independent. Fewer than the size of the matrix means it is DEFECTIVE: a repeated eigenvalue without a full set of eigenvectors. [[1,1],[0,1]] is the smallest example -- eigenvalue 1 twice, one eigenvector. No algorithm can supply the second, so this reports the shortfall rather than returning two vectors of which one is a copy.
	def NumberOfIndependentEigenVectors()
		return This._EigenSystem()[:independent]

	# TRUE if the matrix has fewer independent eigenvectors than rows, so it cannot be diagonalised.
	#
	#   returns    TRUE or FALSE
	#   note       [ [ 1, 1 ], [ 0, 1 ] ] is defective
	#   warning    raises an error unless the matrix is square
	#   see        IsDiagonalizable, NumberOfIndependentEigenVectors
	def IsDefective()
		return This.NumberOfIndependentEigenVectors() < @nRows

	# TRUE if the matrix has a full set of independent eigenvectors.
	#
	#   returns    TRUE or FALSE
	#   note       the opposite of IsDefective
	#   warning    raises an error unless the matrix is square
	#   see        IsDefective
	def IsDiagonalizable()
		return NOT This.IsDefective()

	# one engine crossing serving all of the above
	def _EigenSystem()

		if @nRows != @nCols
			StzRaise("The eigen-system is only defined for square matrices.")
		ok

		_aFlatEs_ = []
		for _iEs_ = 1 to @nRows
			for _jEs_ = 1 to @nCols
				_aFlatEs_ + @aContent[_iEs_][_jEs_]
			next
		next

		_aEs_ = StzEngineEigenSystem(_aFlatEs_, @nRows)
		_nWantEs_ = 1 + @nRows * 2 + @nRows * @nRows * 2
		if NOT isList(_aEs_) or len(_aEs_) != _nWantEs_
			StzRaise("The eigen-system: the QR iteration did not converge on this " +
			         "matrix.")
		ok

		_aValsEs_ = []
		for _iEs_ = 1 to @nRows
			_aValsEs_ + new stzComplex(_aEs_[1 + (_iEs_-1)*2 + 1],
			                           _aEs_[1 + (_iEs_-1)*2 + 2])
		next

		_nAtEs_ = 1 + @nRows * 2
		_aVecsEs_ = []
		for _iEs_ = 1 to @nRows
			_aRowEs_ = []
			for _jEs_ = 1 to @nCols
				_aRowEs_ + new stzComplex(_aEs_[_nAtEs_ + 1], _aEs_[_nAtEs_ + 2])
				_nAtEs_ += 2
			next
			_aVecsEs_ + _aRowEs_
		next

		return [ :independent = _aEs_[1], :values = _aValsEs_, :vectors = _aVecsEs_ ]

	# Returns the unit eigenvectors as the columns of a matrix, in the same order as the eigenvalues.
	#
	#   returns    a list of rows; column j is the eigenvector of eigenvalue j
	#   note       orthonormal for a symmetric matrix
	#   warning    raises an error unless the matrix is square, for a defective matrix, and when an
	#              eigenvector is complex
	#   see        EigenValues, ComplexEigenVectors
	#@ aka  The eigenvectors, as a matrix whose COLUMN j is the unit eigenvector belonging to eigenvalue j -- same order as EigenValues(), so column 1 goes with the first (largest) eigenvalue. For a symmetric matrix they are orthonormal.
	def EigenVectors()

		if @nRows != @nCols
			StzRaise("EigenVectors is only defined for square matrices.")
		ok
		# PHASE 7, SECOND PASS, LIFTED THIS TOO. It used to refuse every
		# non-symmetric matrix; now it refuses only what it must -- a matrix whose
		# eigenvectors are genuinely complex (this method returns plain numbers), or
		# a DEFECTIVE one, which does not have a full set of eigenvectors at all and
		# for which no algorithm can invent the missing ones.
		if NOT This.IsSymmetric()
			_aSysEv_ = This._EigenSystem()
			if _aSysEv_[:independent] < @nRows
				StzRaise("EigenVectors: this matrix is DEFECTIVE -- it has " +
				         @nRows + " eigenvalues but only " + _aSysEv_[:independent] +
				         " independent eigenvector(s), so no full set exists. " +
				         "ComplexEigenVectors() returns what there is.")
			ok
			_aVecsEv_ = _aSysEv_[:vectors]
			_aOutEv_ = []
			for _iEv_ = 1 to @nRows
				_aRowEv_ = []
				for _jEv_ = 1 to @nCols
					if NOT _aVecsEv_[_iEv_][_jEv_].IsReal()
						StzRaise("EigenVectors: this matrix has complex " +
						         "eigenvectors, and this method returns plain " +
						         "numbers. Use ComplexEigenVectors().")
					ok
					_aRowEv_ + _aVecsEv_[_iEv_][_jEv_].RealPart()
				next
				_aOutEv_ + _aRowEv_
			next
			return _aOutEv_
		ok

		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pEvc_ = StzEngineMatrixEigenVectors(@pEngineMatrix)
		if _pEvc_ = ""
			return []
		ok
		_aEvc_ = []
		for _iEc_ = 1 to @nRows
			_aRowEc_ = []
			for _jEc_ = 1 to @nCols
				_aRowEc_ + StzEngineMatrixGet(_pEvc_, _iEc_ - 1, _jEc_ - 1)
			next
			_aEvc_ + _aRowEc_
		next
		StzEngineMatrixFree(_pEvc_)
		return _aEvc_

	# TRUE if the matrix equals its transpose within a relative tolerance of one part in 10^12.
	#
	#   returns    TRUE or FALSE
	#   note       a matrix that is not square answers FALSE
	#   see        Transposed, IsPositiveDefinite
	#@ aka  Is the matrix equal to its own transpose? Compared with a RELATIVE tolerance, because data that came out of a real computation is rarely symmetric to the last bit and an exact test would reject matrices symmetric in every meaningful sense.
	def IsSymmetric()

		if @nRows != @nCols
			return 0
		ok
		_nScaleSy_ = 0
		for _iSy_ = 1 to @nRows
			for _jSy_ = 1 to @nCols
				if fabs(@aContent[_iSy_][_jSy_]) > _nScaleSy_
					_nScaleSy_ = fabs(@aContent[_iSy_][_jSy_])
				ok
			next
		next
		if _nScaleSy_ = 0
			return 1
		ok
		_nTolSy_ = _nScaleSy_ / 1000000000000
		for _iSy_ = 1 to @nRows
			for _jSy_ = _iSy_ + 1 to @nCols
				if fabs(@aContent[_iSy_][_jSy_] - @aContent[_jSy_][_iSy_]) > _nTolSy_
					return 0
				ok
			next
		next
		return 1

	# Returns the ratio of the largest to the smallest singular value, a measure of how much a solve can lose; infinite when singular.
	#
	#   returns    a number, inf for a singular matrix
	#   note       works for any shape; 10^k costs about k digits
	#   see        Rank, SingularValues
	#@ aka  THE CONDITION NUMBER: the largest eigenvalue over the smallest, in magnitude. It answers "how many digits can a solve with this matrix lose?" -- a condition number of 10^k costs about k of the sixteen a double has. Infinite for a singular matrix, which is the honest answer rather than a large finite one. GENERAL since phase 4 slice 9: a rectangular matrix is answered from its SINGULAR values, a sq
	def ConditionNumber()

		# ANY SHAPE since phase 7, for the same reason as Rank(): cond(A) = cond(A'),
		# so which orientation you happen to hold is a fact about your data layout
		# and not about the matrix. The engine transposes internally when it needs to.
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return 0
		ok

		# a square symmetric matrix goes through the eigenvalues, which resolve the
		# small ones slightly better; everything else through the SVD
		if @nRows = @nCols and This.IsSymmetric()
			return StzEngineMatrixConditionNumber(@pEngineMatrix)
		ok
		return StzEngineMatrixConditionGeneral(@pEngineMatrix)

	# Returns the singular value decomposition A = U S V' as a hash of three parts.
	#
	#   returns    a hash with the keys u, singularValues and v: u and v are lists of rows with one
	#              column per singular value
	#   note       singular values come back non-negative and in descending order
	#   warning    raises an error when the sweeps do not converge
	#   see        SingularValues, LowRank
	#@ aka  THE FULL DECOMPOSITION A = U S V' (phase 7).
	def SVD()

		if @nRows = 0 or @nCols = 0
			StzRaise("SVD: this matrix has no entries.")
		ok

		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			StzRaise("SVD: the engine refused the matrix.")
		ok

		_aSvd_ = StzEngineMatrixSvdFull(@pEngineMatrix)
		if NOT isList(_aSvd_) or len(_aSvd_) < 2
			StzRaise("SVD: the decomposition did not converge on this matrix.")
		ok
		if _aSvd_[1] = 0
			StzRaise("SVD: the one-sided Jacobi sweeps did not converge.")
		ok

		_nK_ = _aSvd_[2]
		_nAt_ = 2

		_aU_ = []
		for _i_ = 1 to @nRows
			_aRow_ = []
			for _j_ = 1 to _nK_
				_nAt_++
				_aRow_ + _aSvd_[_nAt_]
			next
			_aU_ + _aRow_
		next

		_anS_ = []
		for _i_ = 1 to _nK_
			_nAt_++
			_anS_ + _aSvd_[_nAt_]
		next

		_aV_ = []
		for _i_ = 1 to @nCols
			_aRow_ = []
			for _j_ = 1 to _nK_
				_nAt_++
				_aRow_ + _aSvd_[_nAt_]
			next
			_aV_ + _aRow_
		next

		return [ :u = _aU_, :singularValues = _anS_, :v = _aV_ ]

	# Returns the left singular vectors, one per column, an orthonormal basis of the column space.
	#
	#   returns    a list of rows
	#   note       ordered by the size of the singular value
	#   see        RightSingularVectors, SVD
	#@ aka  The LEFT singular vectors: an orthonormal basis for the column space, ordered by how much of the matrix each direction accounts for.
	def LeftSingularVectors()
		return This.SVD()[:u]

	# Returns the right singular vectors, one per column, an orthonormal basis of the row space.
	#
	#   returns    a list of rows
	#   note       ordered by the size of the singular value
	#   see        LeftSingularVectors, SVD
	#@ aka  The RIGHT singular vectors: an orthonormal basis for the row space, same order.
	def RightSingularVectors()
		return This.SVD()[:v]

	# Returns the singular values, never negative, largest first.
	#
	#   returns    a list of min(rows, columns) numbers
	#   note       works for any shape
	#   see        SVD, Rank
	#@ aka  The SINGULAR VALUES, sorted descending. Defined for any matrix with at least as many rows as columns, and always non-negative -- a singular value has no sign.
	def SingularValues()

		# WIDE MATRICES ARE ANSWERED SINCE PHASE 7. This used to say "give me at
		# least as many rows as columns (transpose it -- the singular values are the
		# same)". The values ARE the same, which is why the advice worked; what it
		# did not say is that U and V SWAP under a transpose, so a caller who
		# followed it for the FACTORS got a decomposition of A' rather than of A.
		# The transpose now happens inside the engine, once, with the swap done
		# right. There are min(rows, cols) singular values.
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return []
		ok
		_pSvV_ = StzEngineMatrixSingularValues(@pEngineMatrix)
		if _pSvV_ = ""
			return []
		ok
		_nKsv_ = @nCols
		if @nRows < _nKsv_
			_nKsv_ = @nRows
		ok
		_anSvV_ = []
		for _iSv_ = 1 to _nKsv_
			_anSvV_ + StzEngineMatrixGet(_pSvV_, _iSv_ - 1, 0)
		next
		StzEngineMatrixFree(_pSvV_)
		return _anSvV_

	# Returns the number of singular values that are not negligible next to the largest.
	#
	#   returns    a number
	#   note       works for any shape; an all-zero matrix has rank 0
	#   see        IsFullRank, ConditionNumber
	#@ aka  THE RANK: how many eigenvalues are non-negligible relative to the largest. Relative, not absolute -- an absolute threshold would call a matrix of uniformly tiny entries rank zero. GENERAL since slice 9, by the same rule as ConditionNumber above. Counted from whichever spectrum applies, with ONE definition of "negligible" shared between them -- so a matrix called rank deficient always has an infini
	def Rank()

		# ANY SHAPE since phase 7. rank(A) = rank(A') always, so refusing one
		# orientation was an artefact of the SVD's precondition rather than a fact
		# about the matrix.
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return 0
		ok
		if @nRows = @nCols and This.IsSymmetric()
			return StzEngineMatrixRank(@pEngineMatrix)
		ok
		return StzEngineMatrixRankGeneral(@pEngineMatrix)

	# TRUE if the rank is smaller than the number of columns, so the columns are dependent.
	#
	#   returns    TRUE or FALSE
	#   note       for a wide matrix it is always TRUE, because the rank cannot exceed the row
	#              count; the IsRankDeficient form answers the same
	#   see        Rank, IsFullRank
	#@ aka  Rank deficient? For a rectangular matrix that means the COLUMNS are dependent, which is exactly when LeastSquaresFor has no unique answer.
	def IsSingular()
		return This.Rank() < @nCols

		def IsRankDeficient()
			return This.IsSingular()

	# TRUE if the rank equals the number of columns.
	#
	#   returns    TRUE or FALSE
	#   note       for a wide matrix it is always FALSE
	#   see        Rank, IsSingular
	def IsFullRank()
		return This.Rank() = @nCols

	# TRUE if the matrix is symmetric with only positive eigenvalues, tested by attempting its Cholesky factor.
	#
	#   returns    TRUE or FALSE
	#   note       a matrix that is not square answers FALSE
	#   see        CholeskyFactor, IsSymmetric
	#@ aka  Symmetric positive definite? Asked of the Cholesky factorisation, which succeeds if and only if the property holds -- so this is the cheapest test available, and needs no eigenvalues. (numeric_eigen_narrated cross-checks it against "every eigenvalue is positive", which is the same question answered by an unrelated algorithm.)
	def IsPositiveDefinite()
		if @nRows != @nCols
			return 0
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return 0
		ok
		return StzEngineMatrixIsPositiveDefinite(@pEngineMatrix) = 1

	# Returns the inverse of a square matrix as a list of rows, leaving the matrix itself unchanged.
	#
	#   returns    a list of rows, the same size as the matrix
	#   note       the Inverted form answers the same and the InverseQ form returns a stzMatrix
	#   warning    raises an error unless the matrix is square, and when it is singular
	#   see        Invert, LUInverse, PseudoInverse
	def Inverse()

		# Only handle square matrices

		if @nRows != @nCols
			raise("Inverse is only defined for square matrices")
		ok

		# Engine fast path
		This._EnsureEngineMatrix()
		if @pEngineMatrix != ""
			_pInvResult = StzEngineMatrixInverse(@pEngineMatrix)
			if _pInvResult != ""
				_nInvRows = StzEngineMatrixRows(_pInvResult)
				_nInvCols = StzEngineMatrixCols(_pInvResult)
				_aInvMatrix = []
				for _iInv = 1 to _nInvRows
					_aInvRow = []
					for _jInv = 1 to _nInvCols
						_aInvRow + StzEngineMatrixGet(_pInvResult, _iInv - 1, _jInv - 1)
					next
					_aInvMatrix + _aInvRow
				next
				StzEngineMatrixFree(_pInvResult)
				return _aInvMatrix
			ok
		ok

		# Check determinant

		_nDet_ = This.Determinant()

		if _nDet_ = 0
			raise("Matrix is not invertible (determinant is zero)")
		ok

		# Create augmented matrix with identity

		_aAugmented_ = []

		for i = 1 to @nRows

			_aRow_ = []
	
			for j = 1 to @nCols
				_aRow_ + @aContent[i][j]
			next
	
			for j = 1 to @nCols
				if j = i
					_aRow_ + 1
				else
					_aRow_ + 0
				ok
			next
	
			_aAugmented_ + _aRow_
		next

		# Gaussian elimination
	
		for i = 1 to @nRows
	
			# Find pivot
	
			_nPivot_ = _aAugmented_[i][i]
			_nTwice_ = 2*@nCols
	
			for j = i to _nTwice_
				_aAugmented_[i][j] /= _nPivot_
			next
	
			# Eliminate other rows
	
			for k = 1 to @nRows
	
				if k != i
	
					_nFactor_ = _aAugmented_[k][i]
	
					for j = i to _nTwice_
						_aAugmented_[k][j] -= _nFactor_ * _aAugmented_[i][j]
					next
				ok
			next
		next

		# Extract inverse matrix
	
		_aInverse_ = []
	
		for i = 1 to @nRows
	
			_aRow_ = []
	
			for j = @nCols + 1 to _nTwice_
				_aRow_ + _aAugmented_[i][j]
			next
	
			_aInverse_ + _aRow_
		next

		return _aInverse_

		def Inverted()
			return This.Inverse()

		def InverseQ()
			return new stzMatrix(This.Inverse())

			def InvertedQ()
				return This.InverseQ()

	# Replaces this matrix by its inverse, changing it in place.
	#
	#   returns    nothing; the matrix changes in place
	#   note       the verb that changes the matrix, where Inverse hands back the answer
	#   warning    raises an error unless the matrix is square, and when it is singular
	#   see        Inverse, Transpose
	#@ aka  Replace this matrix BY its inverse -- the verb form, mutating in place, the way Transpose() does.
	def Invert()
		@aContent = This.Inverse()
		This._InvalidateEngineMatrix()

		def InvertQ()
			This.Invert()
			return This


	# Swaps rows and columns, so a 2x3 matrix becomes 3x2, changing the matrix in place.
	#
	#   returns    nothing; the matrix changes in place
	#   note       the TransposeQ form returns the matrix itself for chaining
	#   see        Transposed, Invert
	#@ aka  Transpose the matrix in place (engine-backed, pure-Ring fallback)
	def Transpose()

		# Engine fast path

		This._EnsureEngineMatrix()

		if @pEngineMatrix != ""

			_pTrResult = StzEngineMatrixTranspose(@pEngineMatrix)

			if _pTrResult != ""

				_nTrRows = StzEngineMatrixRows(_pTrResult)
				_nTrCols = StzEngineMatrixCols(_pTrResult)
				_aTrMatrix = []

				for _iTr = 1 to _nTrRows
					_aTrRow = []
					for _jTr = 1 to _nTrCols
						_aTrRow + StzEngineMatrixGet(_pTrResult, _iTr - 1, _jTr - 1)
					next
					_aTrMatrix + _aTrRow
				next

				StzEngineMatrixFree(_pTrResult)

				@aContent = _aTrMatrix
				_nTrTmp = @nRows
				@nRows = @nCols
				@nCols = _nTrTmp

				This._InvalidateEngineMatrix()
				return
			ok
		ok

		# Pure-Ring fallback

		_aTr_ = []

		for j = 1 to @nCols
			_aRow_ = []
			for i = 1 to @nRows
				_aRow_ + @aContent[i][j]
			next
			_aTr_ + _aRow_
		next

		@aContent = _aTr_
		_nTrTmp = @nRows
		@nRows = @nCols
		@nCols = _nTrTmp

		This._InvalidateEngineMatrix()

		def TransposeQ()
			This.Transpose()
			return This

	# Returns the transposed rows as a list, leaving this matrix unchanged.
	#
	#   returns    a list of rows, columns by rows
	#   note       the TransposedQ form returns a stzMatrix
	#   see        Transpose
	#@ aka  Passive form: the transposed content, original unchanged
	def Transposed()
		_oTrCopy_ = new stzMatrix(This.Content())
		_oTrCopy_.Transpose()
		return _oTrCopy_.Content()

		def TransposedQ()
			return new stzMatrix(This.Transposed())


	# Returns the differences between neighbouring elements of each row, a list of rows one column shorter.
	#
	#   returns    a list of rows with one fewer column
	#   note       the matrix is not changed; a 3x3 gives 3x2
	#   see        SubMean, Diagonal
	#@ aka  Computes the difference between adjacent elements in the matrix
	def Diff()

		_aResult_ = []
		
		for i = 1 to @nRows

			_rowDiffs_ = []

			for j = 2 to @nCols
				_rowDiffs_ + (@aContent[i][j] - @aContent[i][j-1])
			next

			_aResult_ + _rowDiffs_

		next

		return _aResult_

	# Subtracts the mean of its row from every element, changing the matrix in place so each row sums to zero.
	#
	#   returns    nothing; the matrix changes in place
	#   note       the SubMeanQ form returns the matrix itself for chaining
	#   see        SubtractMean, Mean
	#@ aka  Subtracts the mean of each row from its respective elements
	def SubMean()

		_aResult_ = []
		
		for i = 1 to @nRows
	
			_rowMean_ = @Mean(@aContent[i])
	
			_rowAdjusted_ = []
	
			for j = 1 to @nCols
				_rowAdjusted_ + (@aContent[i][j] - _rowMean_)
			next
	
			_aResult_ + _rowAdjusted_
		next
	
		@aContent = _aResult_

		def SubMeanQ()
			This.SubMean()
			return This

		# Subtracts the mean of its row from every element, changing the matrix in place so each row sums to zero.
		#
		#   returns    nothing; the matrix changes in place
		#   note       the same as SubMean
		#   see        SubMean
		def SubtractMean()
			This.SubMean()

			def SubtractMeanQ()
				return This.SubMeanQ()

	  #-----------------------------#
	 # Visualization of the matrix #
	#-----------------------------#

	# Prints the matrix to the console as a bordered grid of right-aligned numbers, without trailing zeros.
	#
	#   returns    nothing; it prints
	#   note       the matrix is not changed; an empty matrix prints an empty frame
	#   see        Content
	def Show()

		# If matrix is empty, just show empty border

		if @nRows = 0 or @nCols = 0
			see char(226) + char(148) + char(140) + char(226) + char(148) + char(144) + nl + char(226) + char(148) + char(148) + char(226) + char(148) + char(152) + nl
			return
		ok

		# Calculate the maximum width for each column

		_anColWidths_ = []

		for i = 1 to @nCols
			_anColWidths_ + 0
		next

		# Determine max width considering formatted numbers

		for j = 1 to @nCols

			_nMaxWidth_ = 0

			for i = 1 to @nRows

				# Format number to remove unnecessary decimals

				_cFormattedNum_ = _FormatNumber(@aContent[i][j])
				_nWidth_ = StzLen(_cFormattedNum_)

				if _nWidth_ > _nMaxWidth_
					_nMaxWidth_ = _nWidth_
				ok

			next

			_anColWidths_[j] = _nMaxWidth_
		next

		# Calculate total width for border

		_nTotalWidth_ = @sum(_anColWidths_) + @nCols + 1

		# Top border

		see char(226) + char(148) + char(140) + ring_copy(" ", _nTotalWidth_) + char(226) + char(148) + char(144) + char(10)

		# Matrix content

		for i = 1 to @nRows

			see char(226) + char(148) + char(130) + " "

			for j = 1 to @nCols

				# Format and left-pad numbers

				_cFormattedNum_ = _FormatNumber(@aContent[i][j])
				see ring_copy(" ", _anColWidths_[j] - StzLen(_cFormattedNum_)) + _cFormattedNum_ + " "

			next

			see char(226) + char(148) + char(130) + char(10)
		next

		# Bottom border

		see char(226) + char(148) + char(148) + ring_copy(" ", _nTotalWidth_) + char(226) + char(148) + char(152) + nl

		# Prints the matrix as a bordered grid, the misspelt twin of Show.
		#
		#   returns    nothing; it prints
		#   note       the misspelling is in the name as shipped
		#   see        Show
		#< @FunctionMisspelledForm
		def Shwo()
			return Show()

		#>

	# Helper function to format numbers

	def _FormatNumber(pnNum)

		# Convert to string, removing trailing zeros after decimal

		_cNum_ = "" + pnNum

		# If decimal point exists

		if ring_substr1(_cNum_, ".") > 0

			# Remove trailing zeros

			while _cNum_[StzLen(_cNum_)] = "0"
				_cNum_ = StzLeft(_cNum_, StzLen(_cNum_) - 1)
			end

			# Remove trailing decimal point if it's the last character

			if _cNum_[StzLen(_cNum_)] = "."
				_cNum_ = StzLeft(_cNum_, StzLen(_cNum_) - 1)
			ok
		ok

		return _cNum_
