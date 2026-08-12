
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

class stzMatrix from stzListOfLists

	# Matrix core attributes

	@aContent     # Stores the actual matrix data
	@nRows       # Number of rows
	@nCols       # Number of columns
	@pEngineMatrix = ""

	def ClassName()
		return "stzmatrix"

		def StzClassName()
			return This.ClassName()

	# Constructor with flexible initialization

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

	# Raw matrix access

	def Content()
		return @aContent

	def Copy()
		return new stzMatrix(@aContent)

	# Matrix Structure Queries

	def Rows()
		return @nRows

	def Cols()
		return @nCols

	def Size()
		return [ @nRows, @nCols ]

	  #--------------------------#
	 # Element-Level Operations #
	#--------------------------#

	# Adds a value to each matrix element

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

	def AddCV(_nCol_, _nValue_)
		This.AddInCol(_nCol_, _nValue_)

	def AddVC(_nValue_, _nCol_)
		This.AddInCol(_nCol_, _nValue_)

	def AddRV(_nRow_, _nValue_)
		This.AddInRow(_nRow_, _nValue_)

	def AddVR(_nValue_, _nRow_)
		This.AddInRow(_nRow_, _nValue_)

	# The "To" spelling, which test 01 has always documented -- both the names and
	# the resulting matrices -- while nothing defined them.
	def AddToCol(_nCol_, _nValue_)
		This.AddInCol(_nCol_, _nValue_)

		def AddToColumn(_nCol_, _nValue_)
			This.AddInCol(_nCol_, _nValue_)

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

	def AddInCol(pnCol, pnValue)

		# Using RingFastPro

		This._UpdateRegion(:add, 1, @nRows, pnCol, pnCol, pnValue)

		# Instead of this:

		# for i = 1 to @nRows
		# 	@aContent[i][pnCol] += pnValue
		# next

	# Adds a value to a specific row

	def AddInRow(pnRow, pnValue)

		# Using RingFastPro

		This._UpdateRegion(:add, pnRow, pnRow, 1, @nCols, pnValue)

		# Instead of this:

		# for j = 1 to @nCols
		# 	@aContent[pnRow][j] += pnValue
		# next

	# Adds a value to multiple columns

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

	# Adds a value to multiple rows

	# A copy of AddInCols that was never finished being renamed: every reference
	# below said `paColumns`, which is not a parameter of this method, and the
	# fallback loop read `panRows` and `_nRow_`, which do not exist either -- while
	# adding the value TWICE per cell. The method could not run on any input.
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

	# Add value to main diagonal elements

	def AddInDiagonal(pnValue)

		_nMin_ = @min([@nRows, @nCols])

		for i = 1 to _nMin_
			@aContent[i][i] += pnValue
		next

	# Add value to secondary diagonal elements

	def AddInDiagonal2(pnValue)

		_nMin_ = @min([@nRows, @nCols])

		for i = 1 to _nMin_
			@aContent[i][@nCols - i + 1] += pnValue
		next

	  #-----------------------------#
	 # Element-wise multiplication #
	#-----------------------------#

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

	def MultiplyCV(_nCol_, _nValue_)
		This.MultiplyCol(_nCol_, _nValue_)

	def MultiplyVC(_nValue_, _nCol_)
		This.MultiplyCol(_nCol_, _nValue_)

	def MultiplyRV(_nRow_, _nValue_)
		This.MultiplyRow(_nRow_, _nValue_)

	def MultiplyVR(_nValue_, _nRow_)
		This.MultiplyRow(_nRow_, _nValue_)

	def MultiplyBy(pnValue)

		if isList(pnValue) and @IsMatrix(pnValue)
			This.MultiplyByMatrix(pnValue)
			return
		ok

		This._UpdateRegion(:mul, 1, @nRows, 1, @nCols, pnValue)

		def MultiplyByQ(pnValue)
			This.MultiplyBy(pnValue)
			return This

	# Multiply a specific column by a value

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

		def MultiplyColBy(pnCol, pnValue)
			if NOT isNumber(pnValue)
				stzraise("Incorrect param type! pnValue must be a number.")
			ok

			This.MultiplyCol(pnCol, pnValue)

		def MultiplyByInCol(pnValue, pnCol)
			This.MultiplyColBy(pnCol, pnValue)

	# Multiply many columns at one time

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

	# Multiply a specific row by a value

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

		def MultiplyRowBy(pnRow, pnValue)
			if NOT isNumber(pnValue)
				stzraise("Incorrect param type! pnValue must be a number.")
			ok

			This.MultiplyRow(pnRow, pnValue)

		def MultiplyByInRow(pnValue, pnRow)
			This.MultiplyColBy(pnRow, pnValue)

	# Multiply many rows at one time

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

	# Multiply main diagonal elements by a value

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

		#< @FunctionAlternativeForms

		def MultiplyDiagonal(pnValue)
			This.MultiplyDiagonal1(pnValue)

		def MultiplyByInDiagonal1(pnValue)
			This.MultiplyDiagonal1(pnValue)

		def MultiplyByInDiagonal(pnValue)
			This.MultiplyDiagonal1(pnValue)

		#>

	# Multiply secondary diagonal elements by a value

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

		def MultiplyByInDagonal2(pnValue)
			This.MultiplyDiagonal2(pnValue)

	  #-------------------------------#
	 #  Matrix-to-Matrix Operations  #
	#-------------------------------#

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

	# R4 step 1 -- MATRIX HYGIENE: the training prerequisites
	# (elementwise ops, trace, norm, Ax=b). Ring floor; the engine
	# tier accelerates behind the same surface later.

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

		def HadamardProduct(paMatrix)
			This.MultiplyElementwise(paMatrix)

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

	def Trace()
		if @nRows != @nCols
			raise("Trace is only defined for square matrices")
		ok
		_nT_ = 0
		for i = 1 to @nRows
			_nT_ += @aContent[i][i]
		next
		return _nT_

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

	# Solve A x = b -- returns the solution VECTOR (list). Singular systems
	# REFUSE (LAW 3); no least-squares guessing.
	#
	# ENGINE-BACKED since phase 4 of the numeric foundation: one LU factorisation
	# with partial pivoting, then forward and back substitution, in linalg.zig.
	# The Ring-side Gauss-Jordan below is kept as the fallback for when the engine
	# is unavailable -- it implements the same algorithm class and the same
	# contract, so the two agree; it is simply an O(n^3) triple loop running in the
	# interpreter, which is the cost §2.4 of the plan is about. Measured over a
	# 60x60 system, ten solves: 0.21s in Ring, 0.01s through the engine.
	#
	# A note on what NOT to do here: this method already existed, and the first
	# instinct on adding an engine solve was to write a new one beside it. That is
	# exactly how LCM and GCD became second, divergent implementations that
	# answered 0 instead of 24. A short name must alias the full method, and a
	# faster path must replace the slow one INSIDE it -- never sit next to it.
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

	# Calculates the sum of all elements

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

	# Calculates the mean of all elements

	def Mean()
		return Sum() / (@nRows * @nCols)

	# Finds the maximum value in the matrix

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

	# Finds the minimum value in the matrix

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

	# Calculates the power of all elements

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

		def RaiseToPower(n)
			This.Power(n)

			def RaiseToPowerQ(n)
				return This.PowerQ(n)

		def ToPower(n)
			This.Power(n)

			def ToPowerQ(n)
				return This.PowerQ(n)

	#-------------------------------#
	#  FINDING THING IN THE MATRIX  #
	#-------------------------------#

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

	# `def`, not `func`. Inside a class body `func` does not define a method, so
	# FindCol was unreachable and FindCols -- its only caller -- raised R14. It was
	# the sole `func` among 95 definitions here; FindRow, FindRows and FindCols all
	# use `def`.
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

	#--

	# Getting the section of elements between two positions

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

	# Creates a submatrix by extracting specific rows and columns

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

	# Replaces a specific column with a given list

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

	# Replace multiple columns

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

	# Replace a specific row

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

	# Replace multiple rows

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

	# Replacing all the occurrence of an element by a new element

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

		def ReplaceAllOccurrences(pnElm, pnNewElm)
			This.ReplaceElement(pnElm, pnNewElm)

		def ReplaceNumber(pnElm, pnNewElm)
			This.ReplaceElement(pnElm, pnNewElm)

	# Replacing any element at the given position by a new element

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

		def ReplaceNumberAt(panRowCol, pnNewElm)
			This.ReplaceElementAt(panRowCol, pnNewElm)

	# Replacing a given element by a new element, only if
	# it exists at the given posisiton

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

		def ReplaceThisNumberAt(pnElm, panRowCol, pnNewElm)
			This.ReplaceThisElementAt(pnElm, panRowCol, pnNewElm)

	# Replacing the occureences of the given elements in the matrix by
	# the given new element, only they exist at the given positions

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

		def ReplaceTheseNumbersAt(panElms, panPos, pnNewElm)
			This.ReplaceTheseElementsAt(panElms, panPos, pnNewElm)

	  #--------------------------------#
	 #  REPLACEMENT BY MANY ELEMENTS  #
	#--------------------------------#

	# Replacing all the occurrences of an element by the given new element

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

		def ReplaceAllOccurrencesByMany(pnElm, panNewElms)
			This.ReplaceElementByMany(pnElm, panNewElms)

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

	#--

	# Replacing the occureences of the given elements in the matrix by
	# the given new elements, only if they exist at the given positions

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

	#--

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

	def ReplaceSection(panStart, panEnd, pBy)
		_aElmsPos_ = This.FindElementsInSection(panStart, panEnd)
		This.ReplaceElementsAt(_aElmsPos_, pby)

	def ReplaceSectionByMany(panStart, panEnd, paMany)
		_aElmsPos_ = This.FindElementsInSection(panStart, panEnd)
		This.ReplaceElementsAtByMany(_aElmsPos_, paMany)

		def ReplaceElementsInSectionByMany(panStart, panEnd, paMany)
			This.ReplaceSectionByMany(panStart, panEnd, paMany)

	def ReplaceElementInSection(pnElm, panStart, panEnd, pBy)
		_aElmsPos_ = This.FindElementInSection(pnElm, panStart, panEnd)
		This.ReplaceElementsAt(_aElmsPos_, pby)

		def ReplaceThisElementInSection(pnElm, panStart, panEnd, pBy)
			This.ReplaceElementInSection(pnElm, panStart, panEnd, pBy)

	def ReplaceElementInSectionByMany(pnElm, panStart, panEnd, paMany)
		# pnElm was being DROPPED here -- the call passed only the bounds into a
		# method that takes (element, start, end), so it raised R20. Its sibling
		# ReplaceElementInSection above has the call right.
		_aElmsPos_ = This.FindElementInSection(pnElm, panStart, panEnd)
		This.ReplaceElementsAtByMany(_aElmsPos_, paMany)

		def ReplaceThisElementInSectionByMany(pnElm, panStart, panEnd, paMany)
			This.ReplaceElementInSectionByMany(pnElm, panStart, panEnd, paMany)

	def ReplaceElementInSectionByManyXT(pnElm, panStart, panEnd, paMany)
		# same dropped element as ReplaceElementInSectionByMany above
		_aElmsPos_ = This.FindElementInSection(pnElm, panStart, panEnd)
		This.ReplaceElementsAtByManyXT(_aElmsPos_, paMany)

		def ReplaceThisElementInSectionByManyXT(pnElm, panStart, panEnd, paMany)
			This.ReplaceElementInSectionByManyXT(pnElm, panStart, panEnd, paMany)

	def ReplaceTheseElementsInSection(panElms, panStart, panEnd, pBy)
		_aElmsPos_ = This.FindTheseElementsInSection(panElms, panStart, panEnd)
		This.ReplaceElementsAt(_aElmsPos_, pby)

	def ReplaceTheseElementsInSectionByMany(panElms, panStart, panEnd, paMany)
		_aElmsPos_ = This.FindTheseElementsInSection(panElms, panStart, panEnd)
		This.ReplaceElementsAtByMany(_aElmsPos_, paMany)

	def ReplaceTheseElementsInSectionByManyXT(panElms, panStart, panEnd, paMany)
		_aElmsPos_ = This.FindTheseElementsInSection(panElms, panStart, panEnd)
		This.ReplaceElementsAtByManyXT(_aElmsPos_, paMany)


	  #-----------------------------#
	 # Specialized Data Extraction #
	#-----------------------------#

	# Extracts diagonal elements

	def Diagonal()

		_nMin_ = @min([ @nRows, @nCols ])
		_aDiagonal_ = []

		for i = 1 to _nMin_
			_aDiagonal_ + @aContent[i][i]
		next

		return _aDiagonal_

		func Diagonal1()

	# Secondary diagonal elements

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

	# Recursive method for calculating determinant
	# ~> Efficient up to ~10x10 matrices

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

	# Simple Gaussian elimination for matrix inversion
	# ~> Reliable up to ~50x50 matrices

	# LEAST SQUARES: the coefficients minimising ||A x - b||, where this matrix is A.
	#
	# NEW in phase 4 slice 7 of the numeric foundation, and it is a capability rather
	# than a speedup. An OVERDETERMINED system -- more equations than unknowns, which
	# is what fitting a model to data always is -- had no answer anywhere in the
	# library. SolveFor needs a square A; stats.zig's regression is SIMPLE
	# regression, one predictor giving a slope and an intercept. This is multiple
	# regression.
	#
	#     # fit z = c1 + c2*u + c3*v to five observations
	#     oA = new stzMatrix([ [1,1,1], [1,2,1], [1,3,2], [1,4,3], [1,5,5] ])
	#     oA.LeastSquaresFor([ 1.5, 3.5, 4, 4.5, 3.5 ])
	#     #--> [ 3, 2, -1.50 ]
	#
	# Householder QR, not the normal equations. Forming A-transpose-A SQUARES THE
	# CONDITION NUMBER -- a fit that would lose 8 digits loses 16, which in a double
	# is all of them. Householder costs about twice as much and is unconditionally
	# stable, which is the right trade for something computed once.
	#
	# Returns [] when the columns are linearly dependent: there is no unique
	# minimiser then, and choosing one of infinitely many silently would be worse
	# than saying so.
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

		#>

	# THE MOORE-PENROSE PSEUDO-INVERSE, A+. Works for ANY shape and ANY rank -- wide,
	# tall, square, singular -- which is what makes it the true generalisation of an
	# inverse rather than a fallback for one.
	#
	#     new stzMatrix([ [4,7], [2,6] ]).PseudoInverse()   # = the ordinary inverse
	#
	# It generalises everything around it:
	#     square and invertible  ->  A+ IS the inverse
	#     tall and full rank     ->  A+b IS the least-squares solution
	#     rank deficient         ->  A+b is the MINIMUM-NORM least-squares solution
	#     wide                   ->  A+b is the minimum-norm EXACT solution
	#
	# Defined by the four Penrose conditions, which is also how it is tested:
	# A A+ A = A, A+ A A+ = A+, and both A A+ and A+ A symmetric. Those four
	# determine A+ uniquely, so nothing else needs asserting.
	# -- MATRIX FUNCTIONS OF A NON-SYMMETRIC MATRIX: f(A) = Q f(T) Q' --
	#
	# MatrixSquareRoot() above applies f to a DIAGONAL and is done, which is why it
	# refuses every non-symmetric matrix. Here T is only quasi-triangular, so f(T) has
	# to be built block by block -- and that block recurrence is the whole algorithm.
	#
	# -- WHY NOT JUST DIAGONALISE --
	#
	# Because it does not always work. A DEFECTIVE matrix has fewer eigenvectors than
	# dimensions, so there is nothing to diagonalise -- while EVERY real matrix has a
	# Schur form. [[1,1],[0,1]] is the smallest example: one eigenvector, and a square
	# root of [[1,0.5],[0,1]] that no eigendecomposition can reach.
	#
	# Refused rather than returned as NaN when the matrix has a NEGATIVE REAL
	# eigenvalue: that square root exists and is COMPLEX, and this returns real
	# matrices. A complex eigenvalue PAIR is fine -- that is what T's 2x2 blocks are
	# for, and inside one the arithmetic is ordinary complex arithmetic wearing a real
	# basis.
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

	# THE MATRIX COTANGENT, and its hyperbolic partner.
	#
	#     MatrixCot()  = MatrixCos()  * MatrixSin()^-1
	#     MatrixCoth() = MatrixCosh() * MatrixSinh()^-1
	#
	# -- AND NOT MatrixTan()^-1, THOUGH cot(x) = 1/tan(x) IS EXACT --
	#
	# The scalar identity is exact and the matrix one is too: everything here commutes, so
	# the two expressions give the same matrix wherever both exist. The difference is in
	# WHERE BOTH EXIST.
	#
	#     MatrixTan()^-1   needs cos(A) invertible TO FORM THE TANGENT AT ALL, then sin(A)
	#     Cos * Sin^-1     needs sin(A) invertible, and nothing else
	#
	# So the route through the tangent is STRICTLY NARROWER, and it is narrower exactly
	# where cos(A) is singular -- an eigenvalue at pi/2 + k*pi. WHICH IS WHERE THE
	# COTANGENT IS ZERO. cot(pi/2) = 0/1 = 0, as untroubled a value as it ever takes, and
	# deriving it as 1/tan(pi/2) asks for the reciprocal of an infinity that was never
	# there. Taking the obvious identity as the implementation would have thrown away a
	# piece of the domain, silently, at the one point where the answer is easiest.
	#
	# -- AND THE DOMAINS PAIR OFF BY DENOMINATOR, NOT BY FAMILY --
	#
	#     MatrixTan() and MatrixSec()   both need cos(A) invertible
	#     MatrixCot() and MatrixCsc()   both need sin(A) invertible
	#
	# Which puts the cotangent in the narrow half with the cosecant: sin(A) is singular
	# whenever A is, so MatrixCot() refuses EVERY SINGULAR MATRIX, while MatrixTan() --
	# sharing its domain with the secant -- takes them all. Four functions, two domains,
	# and the pairing is by which of sin/cos sits in the denominator, not by whether the
	# name starts with "co".
	def MatrixCot()
		return This._Cotangent(:Circular)

		def MatrixCotQ()
			return new stzMatrix(This.MatrixCot())

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

	# THE MATRIX SECANT AND COSECANT, and their hyperbolic partners.
	#
	#     MatrixSec()   = MatrixCos()^-1        MatrixSech() = MatrixCosh()^-1
	#     MatrixCsc()   = MatrixSin()^-1        MatrixCsch() = MatrixSinh()^-1
	#
	# -- THERE IS NO ALGORITHM HERE, AND THAT IS THE POINT --
	#
	# Every other function in this family had something to construct: a series to scale,
	# a recurrence to climb, a decomposition to walk. These are one inverse of a matrix
	# already computed. All four are the same three lines.
	#
	# So the entire content is WHICH MATRIX IS SINGULAR WHEN, and the four answers are
	# not alike:
	#
	#     MatrixSec()    cos(A) singular at an eigenvalue of pi/2 + k*pi
	#     MatrixCsc()    sin(A) singular at an eigenvalue of k*pi -- INCLUDING ZERO
	#     MatrixSech()   cosh(A) singular only at a purely imaginary i*pi/2 + i*k*pi
	#     MatrixCsch()   sinh(A) singular at zero, or at a purely imaginary i*k*pi
	#
	# -- THE COSECANT'S DOMAIN IS THE NARROW ONE --
	#
	# Zero is an eigenvalue of sin(A) whenever it is an eigenvalue of A, so MatrixCsc()
	# refuses EVERY SINGULAR MATRIX -- and MatrixCsch() with it. Nothing else in this
	# family is that narrow, and it is the difference between a function that
	# occasionally declines and one that declines a whole common class.
	#
	# A nilpotent matrix makes it concrete in a line: cos(N) = I - N^2/2 is invertible
	# and sin(N) = N is not, so THE SAME MATRIX HAS A SECANT AND NO COSECANT.
	def MatrixSec()
		return This._Reciprocal("sec")

		def MatrixSecQ()
			return new stzMatrix(This.MatrixSec())

	def MatrixCsc()
		return This._Reciprocal("csc")

		def MatrixCscQ()
			return new stzMatrix(This.MatrixCsc())

	def MatrixSech()
		return This._Reciprocal("sech")

		def MatrixSechQ()
			return new stzMatrix(This.MatrixSech())

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

	# THE MATRIX ARCSECANT AND ARCCOSECANT, and their hyperbolic partners.
	#
	#     MatrixAsec()  = MatrixAcos()  of the INVERSE
	#     MatrixAcsc()  = MatrixAsin()  of the INVERSE
	#     MatrixAsech() = MatrixAcosh() of the INVERSE
	#     MatrixAcsch() = MatrixAsinh() of the INVERSE
	#
	# -- THESE INVERT THE DOMAIN OF MatrixAsin() AND MatrixAcos() --
	#
	# MatrixAsin() and MatrixAcos() want every eigenvalue INSIDE the unit interval,
	# |L| < 1, because that is where the scalar functions are real. Going through the
	# inverse turns that condition inside out: MatrixAsec() and MatrixAcsc() want every
	# eigenvalue OUTSIDE it, |L| > 1.
	#
	# So a matrix with an eigenvalue at 2 has an arcsecant and no arcsine, and one with an
	# eigenvalue at 0.5 has an arcsine and no arcsecant. Both directions hold.
	#
	# -- AND THE BOUNDARY BELONGS TO NEITHER --
	#
	# The domains are complements, so one would expect them to meet on the unit circle.
	# THEY DO NOT. MatrixAsin() is built on (I - A^2)^(-1/2), and at |L| = 1 that is the
	# inverse of a zero matrix, so the arcsine dies exactly at the endpoint -- and the
	# arcsecant dies there too, since the inverse carries the same eigenvalue into the
	# same wall. The scalar functions are perfectly ordinary there (asin(1) = pi/2,
	# asec(1) = 0), so this is the ROUTE's boundary and not the function's, and it leaves
	# a gap of measure zero between two domains that otherwise tile the line.
	#
	# -- AND THE ROUTE THAT AVOIDS THE INVERSE IS A DIFFERENT FUNCTION --
	#
	# asec(x) = atan(sqrt(x^2 - 1)) is a real identity needing no inverse at all, and it
	# is CORRECT FOR POSITIVE x AND WRONG FOR NEGATIVE x, because the square root discards
	# the sign. Note what kind of wrong: MatrixAcot()'s two routes differed by EXACTLY pi,
	# a constant, the same function shifted. Here the gap is 1.4595, 1.0472, 0.6797 at
	# x = -1.5, -2, -3 -- IT VARIES WITH THE EIGENVALUE. The true relation is
	# asec(-x) = pi - asec(x), a REFLECTION, and no constant offset repairs a reflection.
	# The cheap route is not another branch of this function; it is a different function
	# that happens to agree on half the line.
	#
	# -- AND ALL FOUR REFUSE A SINGULAR MATRIX --
	#
	# Every one of them goes through the inverse, so for once there is no wide partner to
	# contrast with. MatrixAsech() is the narrowest thing here -- it wants 0 < L <= 1,
	# POSITIVE and inside the unit interval, not merely |L| < 1: a negative eigenvalue in
	# (-1, 0) lands on acosh's forbidden left ray and is refused. MatrixAcsch() is the
	# widest, refusing nothing but singularity, since MatrixAsinh() is ODD and has no
	# branch point on the real line -- so it takes BOTH signs where MatrixAsech() takes
	# only the positive one. Their round trips say it plainest: csch(acsch(A)) = A holds
	# on the whole punctured line, sech(asech(A)) = A only on a positive spectrum.
	def MatrixAsec()
		return This._ArcReciprocal("asec")

		def MatrixAsecQ()
			return new stzMatrix(This.MatrixAsec())

	def MatrixAcsc()
		return This._ArcReciprocal("acsc")

		def MatrixAcscQ()
			return new stzMatrix(This.MatrixAcsc())

	def MatrixAsech()
		return This._ArcReciprocal("asech")

		def MatrixAsechQ()
			return new stzMatrix(This.MatrixAsech())

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

	# THE MATRIX ARCCOTANGENT, and its hyperbolic partner.
	#
	#     MatrixAcot()  = (pi/2) I - MatrixAtan()
	#     MatrixAcoth() = MatrixAtanh() of the INVERSE
	#
	# -- TWO ROUTES AGAIN, AND THIS TIME THEY DISAGREE --
	#
	# MatrixCot() had two candidate definitions that differed only in DOMAIN. Here there
	# are two again, and the difference is worse than domain:
	#
	#     (pi/2) I - MatrixAtan(A)        and        MatrixAtan(A^-1)
	#
	# They agree on a positive eigenvalue and DIFFER BY EXACTLY pi on a negative one.
	# arccot(-2) is 2.6779 by the first and -0.4636 by the second -- both are arccotangents
	# of the same number, sitting on different branches. So choosing a route here is not
	# choosing how much domain to keep. IT IS CHOOSING WHICH FUNCTION TO IMPLEMENT.
	#
	# -- AND THE OBVIOUS TEST CANNOT TELL THEM APART --
	#
	# MatrixCot() has period pi. So cot(acot(A)) = A holds for BOTH routes, exactly, to
	# full precision. The round trip -- the first thing anyone would reach for -- is blind
	# to the difference, and a branch error would pass it without a murmur. What
	# distinguishes them is the VALUE on a negative eigenvalue, and nothing else does.
	#
	# The subtraction is taken here: it is the continuous branch, range (0, pi), and it is
	# defined at zero, where acot(0) = pi/2 and the reciprocal route has nothing to say.
	# Being exact rather than a second algorithm, it inherits MatrixAtan()'s domain
	# UNCHANGED -- a singular matrix has an arccotangent, which is the second half of the
	# same point.
	def MatrixAcot()
		return This._Arccotangent(:Circular)

		def MatrixAcotQ()
			return new stzMatrix(This.MatrixAcot())

	# -- AND HERE THERE IS NO SUBTRACTION TO TAKE --
	#
	# The circular pair share a domain: atan and acot are both defined on the whole real
	# line, so one can be written as a constant minus the other. THE HYPERBOLIC PAIR HAVE
	# DISJOINT DOMAINS -- atanh wants |x| < 1 and acoth wants |x| > 1 -- and the identity
	# connecting them, acoth(x) = atanh(x) + i*pi/2, is IMAGINARY. There is no real
	# constant to subtract, so the inverse is not one route of two. It is the only one.
	#
	# Which makes this THE FIRST PLACE WHERE THE CIRCULAR SIDE IS THE WIDER ONE.
	# Everywhere else the hyperbolic partner refused less; here MatrixAcot() takes every
	# matrix MatrixAtan() takes, singular ones included, while MatrixAcoth() needs the
	# matrix invertible on top of everything MatrixAtanh() needed.
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

	# THE MATRIX ARCSINE AND ARCCOSINE.
	#
	#     asin(A) = MatrixAtan( A * (I - A^2)^(-1/2) )
	#     acos(A) = (pi/2) I - asin(A)
	#
	# The scalar identities lifted. Everything commutes -- A and any function of A -- so
	# the lift is the same expression with matrix inverses where the divisions were, and
	# nothing has to be reordered. The arccosine is EXACT rather than a second
	# algorithm: acos + asin = pi/2 holds term by term, so it is a subtraction.
	#
	# -- AND THE REFUSAL IS THE BRANCH POINT AGAIN --
	#
	# sqrt(I - A^2) needs I - A^2 to have no negative real eigenvalue, and for a real
	# eigenvalue L that is 1 - L^2 -- negative exactly when |L| passes ONE. Which is
	# where asin stops being real: asin(2) has no real value, and neither has the
	# arcsine of a matrix with an eigenvalue at 2.
	#
	# Compare MatrixAtan(), whose obstacle was |b| > 1 on the IMAGINARY axis. Same
	# square root, same mechanism, different branch points -- because they belong to
	# different functions.
	def MatrixAsin()
		return This._ArcTrig("asin")

		def MatrixAsinQ()
			return new stzMatrix(This.MatrixAsin())

	def MatrixAcos()
		return This._ArcTrig("acos")

		def MatrixAcosQ()
			return new stzMatrix(This.MatrixAcos())

	# THE HYPERBOLIC ARCSINE AND ARCCOSINE, both closed forms in the logarithm:
	#
	#     asinh(A) = MatrixLog( A + sqrt(A^2 + I) )
	#     acosh(A) = MatrixLog( A + sqrt(A^2 - I) )
	#
	# WHICH COMPLETES A PATTERN WORTH STATING. Every hyperbolic inverse here is a closed
	# form in the logarithm -- atanh, asinh, acosh alike -- while each circular one had
	# to be built: MatrixAtan() needed a halving recurrence, and MatrixAsin() is defined
	# through it. The families matched sign for sign all the way up and part company at
	# the inverses.
	#
	# -- AND ONE CHARACTER SEPARATES THE LAST TWO --
	#
	# The MINUS in acosh inverts the domain -- but NOT into a mirror image, which is the
	# part easy to get wrong. A^2 - I gives L^2 - 1, so the square root wants |L| >= 1,
	# the opposite of MatrixAcos()'s inside; but THEN the log wants L + sqrt(L^2 - 1) > 0,
	# which fails for L <= -1. Only the intersection survives: MatrixAcos() owns the open
	# interval (-1, 1), MatrixAcosh() owns the RAY [1, inf), not the two-sided outside.
	#
	# MatrixAsinh() refuses nothing for a REAL spectrum: A^2 + I gives 1 + L^2, always
	# positive. Note "real SPECTRUM", not "real entries" -- a real matrix may have
	# complex eigenvalues, and then it can decline after all.
	def MatrixAsinh()
		return This._ArcTrig("asinh")

		def MatrixAsinhQ()
			return new stzMatrix(This.MatrixAsinh())

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

	# THE MATRIX ARCTANGENT.
	#
	# -- THE FIRST INVERSE HERE, AND IT NEEDED A DIFFERENT IDEA --
	#
	# Everything before it had either a series that converges after scaling (MatrixExp,
	# MatrixSin, MatrixCos) or a decomposition that hands the answer over block by block
	# (GeneralSquareRoot). The arctangent has neither: its Taylor series converges only
	# for ||X|| < 1, and there is no doubling recurrence to climb back with.
	#
	# What it has is a HALVING one:
	#
	#     atan(A) = 2 * atan( A * (I + sqrt(I + A^2))^-1 )
	#
	# the half-angle formula for the tangent read backwards. Apply it until the argument
	# is small, take the series there, multiply by 2^k on the way out. So the scaling is
	# done by the identity itself rather than by dividing -- and each step costs a
	# MATRIX SQUARE ROOT, another layer on the same construction.
	#
	# -- WHAT IT REFUSES IS THE BRANCH POINT, NOT A LIMITATION --
	#
	# sqrt(I + A^2) needs I + A^2 to have no negative real eigenvalue. A real eigenvalue
	# L gives 1 + L^2, comfortably positive; a PURELY IMAGINARY one i*b gives 1 - b^2,
	# which turns negative once |b| passes one.
	#
	# That is the mathematics. atan has branch points at exactly +i and -i, so a matrix
	# with an eigenvalue on the imaginary axis beyond them has no principal arctangent.
	def MatrixAtan()
		return This._ArcTangent("atan")

		def MatrixAtanQ()
			return new stzMatrix(This.MatrixAtan())

	# THE HYPERBOLIC ARCTANGENT: (1/2) [ MatrixLog(I + A) - MatrixLog(I - A) ].
	#
	# -- AND THIS ONE NEEDED NO NEW IDEA AT ALL --
	#
	# Where the circular arctangent had to invent a halving recurrence, its hyperbolic
	# twin is a closed form in the logarithm, which was already here. Two logs and a
	# subtraction.
	#
	# THE ASYMMETRY IS WORTH NOTICING rather than glossing. The two families have
	# matched each other line for line all the way up -- MatrixSin against MatrixSinh,
	# MatrixCos against MatrixCosh, MatrixTan against MatrixTanh, each differing by one
	# sign -- and at the inverse they stop. atanh has a real closed form and atan does
	# not, because the logarithm expressing atan wants complex arguments and the one
	# expressing atanh does not.
	#
	# Refused at an eigenvalue of +/- 1, where atanh runs to infinity exactly as
	# atanh(1) does.
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

	# THE MATRIX TANGENT: MatrixSin() * MatrixCos()^-1.
	#
	# -- AND THE SIDE DOES NOT MATTER, WHICH IS NOT OBVIOUS --
	#
	# For two arbitrary matrices X*Y^-1 and Y^-1*X are different things, and writing one
	# where the other was meant is a classic way to be quietly wrong. Here they are
	# EQUAL, because sin(A) and cos(A) are both functions of the SAME A -- limits of
	# polynomials in it -- and any two such functions commute.
	#
	# So there is no left-tangent and right-tangent to choose between. The guard asserts
	# the two orders agree rather than leaving it to be assumed.
	#
	# -- AND UNLIKE THE SINE AND COSINE, THIS ONE CAN FAIL TO EXIST --
	#
	# cos(A) is singular exactly when A has an eigenvalue at pi/2 + k*pi, and there the
	# tangent is undefined for the same reason tan(pi/2) is. MatrixSin() and
	# MatrixCos() refuse nothing; this refuses, and the refusal is the mathematics
	# rather than a limitation of the method.
	def MatrixTan()
		return This._Tangent("tan")

		def MatrixTanQ()
			return new stzMatrix(This.MatrixTan())

	# THE HYPERBOLIC TANGENT: MatrixSinh() * MatrixCosh()^-1.
	#
	# Same two lines, same commuting property. What differs is when it can fail: cosh(A)
	# is singular only at PURELY IMAGINARY eigenvalues, so a real matrix with a real
	# spectrum can never break this, while a single diagonal entry of pi/2 breaks the
	# circular one.
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

	# THE HYPERBOLIC MATRIX SINE AND COSINE.
	#
	# -- THE SAME ROUTINE AS THE CIRCULAR PAIR, WITH ONE SIGN CHANGED --
	#
	# Write the two families out and the difference is a single alternating sign:
	#
	#     cos(X)  = I - X^2/2! + X^4/4! - ...    cosh(X) = I + X^2/2! + X^4/4! + ...
	#     sin(X)  = X - X^3/3! + X^5/5! - ...    sinh(X) = X + X^3/3! + X^5/5! + ...
	#
	# And the double-angle recurrences that climb back from the scaled matrix are not
	# merely similar -- they are IDENTICAL:
	#
	#     cos(2X)  = 2 cos(X)^2  - I             cosh(2X) = 2 cosh(X)^2 - I
	#     sin(2X)  = 2 sin(X) cos(X)             sinh(2X) = 2 sinh(X) cosh(X)
	#
	# So underneath there is ONE routine and a flag. A second copy would be a second
	# transcription of one algorithm, and two copies drift.
	#
	# The check that keeps them honest is a nilpotent matrix, where N^3 = 0 truncates
	# both series exactly: cos(N) = I - N^2/2 while cosh(N) = I + N^2/2. The only
	# difference is that sign, so the pair of tests pins the shared branch from both
	# sides -- a routine that ignored the flag would pass one and fail the other.
	#
	# Nothing is refused: every real matrix has these, as it has the circular pair.
	def MatrixSinh()
		return This._Hyperbolic("sinh")

		def MatrixSinhQ()
			return new stzMatrix(This.MatrixSinh())

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

	# THE MATRIX SINE AND COSINE.
	#
	# -- SCALING AND THE DOUBLE-ANGLE RECURRENCES --
	#
	# The Taylor series converge everywhere, but slowly for a large matrix and with
	# cancellation that eats the answer. So the same trick as MatrixExp(): scale A down
	# until its norm is small, where a handful of terms is exact to rounding, then climb
	# back with
	#
	#     cos(2X) = 2 cos(X)^2 - I
	#     sin(2X) = 2 sin(X) cos(X)
	#
	# The two are computed TOGETHER underneath, because the sine's recurrence needs the
	# cosine -- so asking for both costs no more than asking for one.
	#
	# -- AND THESE NEED NOTHING BENEATH THEM --
	#
	# GeneralSquareRoot() needed a Schur form, MatrixLog() needed the square root, and
	# GeneralPower() needed the logarithm. These need none of it: no eigenvalues, no
	# triangularisation, no factorisation at all.
	#
	# Worth saying, because three entries in a row might suggest a house style. A
	# decomposition is reached for when the algorithm requires one, and here it does not.
	#
	# Nothing is refused: every real matrix has a sine and a cosine. There is no
	# singularity to trip over and no eigenvalue whose real answer fails to exist.
	#
	# THIS IS sin OF THE MATRIX, not of its entries -- the same distinction Power() and
	# MatrixPower() carry. sin(A)^2 here means the matrix squared, and for a
	# non-symmetric A that is a very different object from squaring each entry.
	def MatrixSin()
		return This._Trig("sin")

		def MatrixSinQ()
			return new stzMatrix(This.MatrixSin())

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

	# THE MATRIX LOGARITHM: the X with MatrixExp(X) = A.
	#
	# -- INVERSE SCALING AND SQUARING, the exponential's method run backwards --
	#
	# A series for log converges only near the identity, and a general matrix is not
	# near it. So: take repeated SQUARE ROOTS until it is, evaluate the series there,
	# and multiply back by 2^k, since log(A) = 2^k * log(A^(1/2^k)).
	#
	# THE SQUARE ROOTS ARE GeneralSquareRoot(). This is the third layer of one
	# construction: the Schur form gives the square root, the square root gives the
	# logarithm, and the logarithm with the exponential gives every real power. Each is
	# short because the one beneath it did the work.
	#
	# -- WHAT IT REFUSES, AND WHY THE REASONS DIFFER --
	#
	# A SINGULAR matrix has no logarithm at all: MatrixExp() is never singular, so
	# nothing maps to one. A NEGATIVE REAL eigenvalue has only a complex logarithm, for
	# exactly the reason it has only a complex square root -- and that refusal arrives
	# from GeneralSquareRoot(), which is where the constraint actually lives.
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

	# A RAISED TO ANY REAL POWER, for a matrix with no symmetry: exp(p * log(A)).
	#
	# MatrixPower() refuses every non-symmetric matrix, and this is the answer it could
	# not give. It is two lines in the engine, because the logarithm and the exponential
	# above did the work -- which is what a foundation is supposed to look like.
	#
	# The constraints follow through: no negative real eigenvalue, and non-singular. An
	# INTEGER power needs neither and is better done by repeated multiplication; this is
	# for the fractional case, where there is no other route.
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

	# THE MATRIX EXPONENTIAL -- and it does NOT want a Schur decomposition.
	#
	# Scaling and squaring with a Pade approximant: exp(A) = (exp(A/2^s))^(2^s), the
	# inner one accurate precisely because A/2^s has been made small. It is what every
	# serious library uses, and it needs no decomposition at all.
	#
	# Worth saying next to the square root: NOT EVERY MATRIX FUNCTION WANTS A SCHUR
	# FORM. The square root does -- the block recurrence IS the algorithm. The
	# exponential does not, and routing it through one would be slower and no more
	# accurate. A decomposition is a tool, not a house style.
	#
	# This is exp of the MATRIX, not of its entries. There is no elementwise Exp() next
	# door today, but the distinction is the same one Power() and MatrixPower() carry.
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

	# -- THE SCHUR DECOMPOSITION: A = Q T Q', with Q ORTHOGONAL --
	#
	# T is quasi-upper-triangular: 1x1 blocks on the diagonal for real eigenvalues, 2x2
	# for conjugate pairs. Every real matrix has one, which is more than can be said for
	# an eigendecomposition -- a defective matrix has no full set of eigenvectors, and
	# this exists regardless.
	#
	# -- IT NEEDED A SECOND HESSENBERG REDUCTION, AND THAT WAS MEASURED --
	#
	# The eigenvalue path already produced a triangular T. Its accumulated transform is
	# NOT orthogonal: it reduces by Gaussian elimination, which is cheaper and perfectly
	# good for eigenvalues. On a 4x4:
	#
	#     elimination path    ||Z'Z - I|| = 0.607    ||Z T Z' - A|| = 3.38
	#     this one            ||Q'Q - I|| = 6.7e-16  ||Q T Q' - A|| = 7.1e-11
	#
	# A decomposition whose Q is not orthogonal is not a Schur decomposition -- it is a
	# similarity that happens to end in triangular form, and everything worth having
	# downstream rests on Q' being Q-inverse. So this reduces by Householder reflections
	# instead, on its own path, leaving the eigenvalue numerics untouched.
	def SchurQ()
		return This._SchurPart("q")

		def SchurQQ()
			return new stzMatrix(This.SchurQ())

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

	# A^-1 = Q T^-1 Q'. CORRECT, AND THE WRONG ROUTE TO USE.
	#
	# It agrees with the other five and it is the one not to reach for: this runs an
	# ITERATIVE QR to arrive where LUInverse() arrives by direct factorisation. It is
	# here because the decomposition is worth having and an inverse is the obvious thing
	# to ask of a decomposition -- so it should exist, and it should say what it is.
	#
	# WHAT THE SCHUR FORM IS ACTUALLY FOR is f(A) for a NON-SYMMETRIC matrix: the square
	# root, the exponential, a general power. MatrixPower() refuses every non-symmetric
	# matrix by construction, and an eigendecomposition cannot always supply one. This
	# function is the f = 1/x case, and the least interesting of them.
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

	# -- INVERTING AN LU DECOMPOSITION: the fastest general square route --
	#
	# A = P L U, so each column of the inverse is one forward and one back substitution
	# against a unit vector, with the factorisation done once. This completes the set:
	#
	#     CholeskyInverse()   symmetric positive definite   ~n^3/6   fastest of all
	#     LUInverse()         any nonsingular SQUARE        ~n^3/3   fastest general
	#     QRInverse()         any full-rank square or TALL  ~2n^3/3
	#     MatrixPower(-1)     symmetric                     iterative, gives powers too
	#     PseudoInverse()     everything, incl. rank-def.   iterative, most general
	#
	# -- WHY BOTH THIS AND QR, WHEN LU DOES HALF THE WORK --
	#
	# Not stability, which is what I assumed and measured to be false. On the 9x9
	# Hilbert matrix, condition number around 1e12:
	#
	#     LU   residual 3.81e-6
	#     QR   residual 8.34e-6
	#
	# "QR is more stable than LU" is a rule about LEAST SQUARES, where the alternative
	# is forming A'A and squaring the condition number. Inverting a square matrix never
	# faces that choice, and LU with partial pivoting is famously well behaved -- here
	# it is twice as accurate, not half.
	#
	# THE REAL REASON IS SHAPE. QR takes a tall matrix and this cannot, which is why
	# LeastSquares stays QR's. Reach for LU when the matrix is square and merely
	# invertible; for QR when it is tall.
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

	# -- INVERTING A QR DECOMPOSITION: the route for a matrix with no symmetry --
	#
	# A = Q R with Q orthogonal and R upper triangular, so A^-1 = R^-1 Q': one
	# back-substitution per column, no iteration anywhere.
	#
	# -- THE GAP THIS FILLS, WHICH IS WHY IT EXISTS --
	#
	# There are four routes to an inverse here now, and until this one the plain
	# general square case had no fast road at all:
	#
	#     CholeskyInverse()    symmetric positive definite ONLY    fastest
	#     MatrixPower(-1)      symmetric ONLY
	#     QRInverse()          any full-rank square or tall        no symmetry needed
	#     PseudoInverse()      everything, including rank-deficient    slowest
	#
	# A transition matrix, a Jacobian, a change of basis -- these are symmetric only by
	# accident, so the first two decline and the SVD was all that was left.
	#
	# -- AND FOR A TALL MATRIX THE SAME FORMULA IS THE PSEUDO-INVERSE --
	#
	# Unchanged, not adapted. When A is m-by-n with m > n and full column rank,
	# R^-1 Q' IS the Moore-Penrose inverse, which is why LeastSquares has always been a
	# QR solve underneath. Building it column by column just makes the operator itself
	# available rather than one solution at a time.
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

	# -- INVERTING A CHOLESKY DECOMPOSITION: the same inverse, the cheapest road --
	#
	# A = L L' for a symmetric positive-definite A, and once you have that triangular
	# factor the inverse is forward-and-back substitution: no iteration, no sweeps,
	# nothing to converge.
	#
	# THIS IS NOT A FOURTH OPINION ABOUT WHAT A-INVERSE IS. PseudoInverse() reaches the
	# same matrix through an SVD and MatrixPower(-1) through an eigendecomposition; all
	# three agree, and the guard checks them against each other rather than against a
	# tabulated answer. What differs is the work. MEASURED on a 120x120 SPD matrix:
	#
	#     CholeskyInverse()     6 ms
	#     MatrixPower(-1)     112 ms     19x
	#     PseudoInverse()     123 ms     20x
	#
	# Both of the others run an iterative diagonalisation to answer a question that
	# direct substitution settles. Reach for this one when the matrix is SPD -- a
	# covariance, a Gram matrix, a normal-equations matrix -- and for the others when it
	# is not.
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

	# THE INVERSE OF THE FACTOR ITSELF, and it is a WHITENING MATRIX.
	#
	# A = L L', so L^-1 A L^-1' = I -- the defining property. WhiteningMatrix() produces
	# one too, and THEY ARE DIFFERENT MATRICES. Neither is more correct.
	#
	# WHITENING IS NOT UNIQUE. Any W with W A W' = I qualifies, and if W works then so
	# does QW for any orthogonal Q. The eigen route picks the SYMMETRIC whitener; this
	# one picks the TRIANGULAR one, which is cheaper and is what a sampler wants -- it
	# turns independent normals into correlated ones with a single multiply.
	#
	# The same distinction as the two square roots above, and for the same reason: "give
	# me something that undoes A" is a question with many answers.
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

	# -- INVERTING AN EIGENDECOMPOSITION, which is one power among several --
	#
	# A = Q L Q', so A^p = Q L^p Q' -- apply the power to the EIGENVALUES and reassemble.
	# Undoing the decomposition is p = 1. The inverse is p = -1. But nothing in the
	# machinery cares which function reaches the diagonal, and the two that earn their
	# keep are the ones no other decomposition here offers:
	#
	#     MatrixSquareRoot()      p =  0.5
	#     WhiteningMatrix()       p = -0.5
	#
	# So the inverse arrives as a special case rather than as the feature.
	#
	# -- NOT Power(), WHICH IS NEXT DOOR AND MEANS SOMETHING ELSE --
	#
	# Power(n) raises every ELEMENT to a power. This raises the MATRIX to one. They
	# agree only for a diagonal matrix, and they are one keystroke apart, so the names
	# have to carry the difference.
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

	# THE PRINCIPAL SQUARE ROOT: symmetric, positive semi-definite, and unique.
	#
	# Cholesky() also gives a "square root" -- L with L L' = A -- but that one is
	# TRIANGULAR and one of many. Both square back to A; only this one is itself a
	# covariance-shaped object you can hand to something expecting symmetry.
	def MatrixSquareRoot()
		return This.MatrixPower(0.5)

		def MatrixSquareRootQ()
			return new stzMatrix(This.MatrixSquareRoot())

	# THE WHITENING TRANSFORM, A^-0.5: the matrix W for which W A W is the identity.
	#
	# Named for what it is for rather than for the arithmetic. Given a covariance, it is
	# the transform under which every direction has unit variance and none correlate --
	# the operation no other decomposition here provides, and the reason a general power
	# is worth more than an inverse.
	def WhiteningMatrix()
		return This.MatrixPower(-0.5)

		def WhiteningMatrixQ()
			return new stzMatrix(This.WhiteningMatrix())

	# A rebuilt from its k leading eigenpairs. For a symmetric positive-definite matrix
	# this and LowRank() agree exactly -- the singular values ARE the eigenvalues -- and
	# they are kept separate so that a caller thinking in eigenpairs need not reach for
	# a different factorisation to ask the question.
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

	# -- THE OTHER SENSE OF INVERTING AN SVD: the best rank-k approximation --
	#
	# PseudoInverse() below answers "undo this transformation". This answers "keep the k
	# strongest directions and discard the rest" -- the sense the embedding work means
	# by an inverse. PCA's reconstruction is exactly this, on the centered matrix.
	#
	# ITS ERROR IS AN IDENTITY, NOT A MEASUREMENT. Eckart and Young proved that no
	# rank-k matrix is closer in the Frobenius norm, and that the distance is exactly
	# the squares of the singular values dropped:
	#
	#     ||A - A_k||_F^2  =  s_(k+1)^2 + s_(k+2)^2 + ...
	#
	# So a caller who kept k components already knows what it cost, from
	# SingularValues() alone and without reconstructing anything. It is the same shape
	# of statement as PCA's "reconstruction error equals discarded variance", and for
	# the same reason -- these are the same theorem wearing two names.
	#
	# Keeping every singular value returns the matrix itself, to rounding.
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

		#>

	# THE MINIMUM-NORM LEAST-SQUARES SOLUTION, x = A+b.
	#
	# This is the method LeastSquaresFor sends you to. That one REFUSES a
	# rank-deficient system, on the grounds that infinitely many coefficient vectors
	# share the minimum residual and least squares has no opinion about which to
	# prefer. This one does have an opinion, and a principled one: among all the
	# minimisers it returns the SHORTEST. Same for an underdetermined system, where
	# infinitely many solutions are exact and this returns the smallest.
	#
	#     oA = new stzMatrix([ [1,0,1], [0,1,1], [1,1,2], [2,0,2], [0,3,3] ])
	#     oA.LeastSquaresFor(ab)              #--> [ ]   -- refuses, rank deficient
	#     oA.MinimumNormSolutionFor(ab)       #--> the shortest of the minimisers
	#
	# Prefer LeastSquaresFor when the design is full rank: a refusal there is
	# information -- it means your predictors are collinear -- and silently accepting
	# it would hide that.
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

		#>

	# The Cholesky factor L, where A = L * L-transpose. Lower triangular, zeros
	# above the diagonal. Returns [] when the matrix is not symmetric positive
	# definite -- the factorisation exists exactly when that property holds, which
	# is what makes IsPositiveDefinite() below cheap.
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

	# EIGENVALUES of a symmetric matrix, sorted DESCENDING -- the convention PCA
	# expects, so the first is the dominant one.
	#
	# NEW in phase 4 slice 8. Symmetric only, and that is a refusal rather than a
	# limitation: a general matrix has COMPLEX eigenvalues, which needs a different
	# algorithm and a complex type the library does not have. Handed a non-symmetric
	# matrix this raises, instead of returning the eigenvalues of (A + A')/2 and
	# letting you believe they belong to A.
	#
	#     new stzMatrix([ [2,1], [1,2] ]).EigenValues()   #--> [ 3, 1 ]
	#
	# Cyclic Jacobi rotations. Slower than the tridiagonal-QR iteration LAPACK uses,
	# but eighty lines instead of several hundred, and it gets the SMALL eigenvalues
	# to high relative accuracy -- which is what a condition number and a rank test
	# actually depend on.
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

	# EVERY eigenvalue, complex ones included, as stzComplex objects (phase 7).
	#
	# A real symmetric matrix has real eigenvalues. A general real one need not: a
	# quarter-turn rotation [[0,-1],[1,0]] has eigenvalues +i and -i, and no amount
	# of care produces a real answer, because a rotation genuinely has no real
	# eigendirection. Complex eigenvalues of a REAL matrix always come in conjugate
	# pairs, so they arrive here that way.
	#
	# Balanced, reduced to Hessenberg form, then Francis double-shift QR -- the
	# standard three steps. The double shift is what lets an implementation in real
	# arithmetic find complex pairs at all: shifting by a complex number would need
	# complex arithmetic throughout, while shifting by a conjugate PAIR is an
	# equivalent real operation.
	#
	# The order is the order deflation found them, and is deliberately not sorted:
	# imposing one would be a claim about which eigenvalue is "first" that the
	# mathematics does not make.
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

	# EVERY eigenvector, complex ones included (phase 7, second pass). Row i,
	# column j is component i of the eigenvector belonging to ComplexEigenValues()[j].
	#
	# WHY THIS IS HARDER THAN THE EIGENVALUES WERE. Eigenvalues can be read off a
	# matrix you have destroyed -- balancing, Hessenberg reduction and QR are all
	# similarities, and a similarity does not move the spectrum. An EIGENVECTOR of
	# the final triangular matrix belongs to THAT matrix, so getting back to one of
	# the original needs every transformation the eigenvalue routine threw away.
	# The whole pipeline accumulates now: v_A = D . Q . Z . v_T.
	#
	# NORMALISATION: unit length, with the largest component rotated to be real and
	# positive. An eigenvector is only defined up to scale and (when complex) phase,
	# so "the" eigenvector is a family; pinning both is what makes two runs agree.
	def ComplexEigenVectors()
		return This._EigenSystem()[:vectors]

	# How many of the eigenvectors are linearly independent. Fewer than the size of
	# the matrix means it is DEFECTIVE: a repeated eigenvalue without a full set of
	# eigenvectors. [[1,1],[0,1]] is the smallest example -- eigenvalue 1 twice, one
	# eigenvector. No algorithm can supply the second, so this reports the shortfall
	# rather than returning two vectors of which one is a copy.
	def NumberOfIndependentEigenVectors()
		return This._EigenSystem()[:independent]

	def IsDefective()
		return This.NumberOfIndependentEigenVectors() < @nRows

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

	# The eigenvectors, as a matrix whose COLUMN j is the unit eigenvector belonging
	# to eigenvalue j -- same order as EigenValues(), so column 1 goes with the
	# first (largest) eigenvalue. For a symmetric matrix they are orthonormal.
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

	# Is the matrix equal to its own transpose? Compared with a RELATIVE tolerance,
	# because data that came out of a real computation is rarely symmetric to the
	# last bit and an exact test would reject matrices symmetric in every meaningful
	# sense.
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

	# THE CONDITION NUMBER: the largest eigenvalue over the smallest, in magnitude.
	# It answers "how many digits can a solve with this matrix lose?" -- a condition
	# number of 10^k costs about k of the sixteen a double has. Infinite for a
	# singular matrix, which is the honest answer rather than a large finite one.
	# GENERAL since phase 4 slice 9: a rectangular matrix is answered from its
	# SINGULAR values, a square symmetric one from its eigenvalues. Slice 8 could only
	# do the symmetric case and raised otherwise -- but a DESIGN MATRIX is neither
	# square nor symmetric, and "are my predictors collinear?" is the question a fit
	# most needs answered.
	#
	#     oA = new stzMatrix([ [1,0,1], [0,1,1], [1,1,2], [2,0,2], [0,3,3] ])
	#     oA.Rank()               #--> 2   (column 3 IS column 1 + column 2)
	#     oA.ConditionNumber()    #--> inf, so LeastSquaresFor would refuse
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

	# THE FULL DECOMPOSITION A = U S V' (phase 7).
	#
	#   aD = oM.SVD()
	#   aD[:u]                 the left singular vectors, COLUMN j for value j
	#   aD[:singularValues]    min(rows, cols) of them, descending, never negative
	#   aD[:v]                 the right singular vectors, same column convention
	#
	# UNTIL NOW ONLY THE SINGULAR VALUES REACHED RING. That was enough for rank,
	# conditioning and a least-squares diagnosis -- which is what phase 4 built it
	# for -- and not enough for anything that needs the DIRECTIONS: a principal-
	# component analysis, a low-rank approximation, an orthonormal basis for the
	# range or the null space. The values say how much; the vectors say where.
	#
	# WHY U AND V ARE NOT INTERCHANGEABLE, which is the trap the old advice hid.
	# "Transpose it, the singular values are the same" is true, and a caller who
	# followed it to get the FACTORS ended up with a decomposition of A' -- because
	# transposing swaps U and V. The engine does the transpose internally now.
	#
	# A SINGULAR VALUE HAS NO SIGN. They come back non-negative and descending, so
	# the first is the largest and the ratio of first to last is the condition
	# number. The sign a caller might expect lives in the vectors instead.
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

	# The LEFT singular vectors: an orthonormal basis for the column space, ordered
	# by how much of the matrix each direction accounts for.
	def LeftSingularVectors()
		return This.SVD()[:u]

	# The RIGHT singular vectors: an orthonormal basis for the row space, same order.
	def RightSingularVectors()
		return This.SVD()[:v]

	# The SINGULAR VALUES, sorted descending. Defined for any matrix with at least as
	# many rows as columns, and always non-negative -- a singular value has no sign.
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

	# THE RANK: how many eigenvalues are non-negligible relative to the largest.
	# Relative, not absolute -- an absolute threshold would call a matrix of
	# uniformly tiny entries rank zero.
	# GENERAL since slice 9, by the same rule as ConditionNumber above. Counted from
	# whichever spectrum applies, with ONE definition of "negligible" shared between
	# them -- so a matrix called rank deficient always has an infinite condition
	# number, and never the finite 9e16 the two used to disagree on.
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

	# Rank deficient? For a rectangular matrix that means the COLUMNS are dependent,
	# which is exactly when LeastSquaresFor has no unique answer.
	def IsSingular()
		return This.Rank() < @nCols

		def IsRankDeficient()
			return This.IsSingular()

	def IsFullRank()
		return This.Rank() = @nCols

	# Symmetric positive definite? Asked of the Cholesky factorisation, which
	# succeeds if and only if the property holds -- so this is the cheapest test
	# available, and needs no eigenvalues. (numeric_eigen_narrated cross-checks it
	# against "every eigenvalue is positive", which is the same question answered by
	# an unrelated algorithm.)
	def IsPositiveDefinite()
		if @nRows != @nCols
			return 0
		ok
		This._EnsureEngineMatrix()
		if @pEngineMatrix = ""
			return 0
		ok
		return StzEngineMatrixIsPositiveDefinite(@pEngineMatrix) = 1

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

	# Replace this matrix BY its inverse -- the verb form, mutating in place, the
	# way Transpose() does.
	#
	# WHY BOTH FORMS EXIST. Inverse() used to be the mutating one, and it returned
	# nothing, so `aInv = oM.Inverse()` handed back an empty value AND destroyed the
	# caller's matrix. Two things settled which way to fix it: the six noun-named
	# siblings -- LUInverse(), QRInverse(), CholeskyInverse(),
	# CholeskyFactorInverse(), SchurInverse(), PseudoInverse() -- all RETURN the
	# inverse as data and leave the receiver alone, and this class already carries
	# the Transpose()/Transposed()/TransposeQ() trio. So the noun returns data, and
	# the verb mutates:
	#
	#     Inverse()  / Inverted()   the inverse AS DATA, receiver untouched
	#     InverseQ()                the inverse as a chainable stzMatrix
	#     Invert()   / InvertQ()    replace THIS matrix by its inverse
	def Invert()
		@aContent = This.Inverse()
		This._InvalidateEngineMatrix()

		def InvertQ()
			This.Invert()
			return This


	# Transpose the matrix in place (engine-backed, pure-Ring fallback)

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

	# Passive form: the transposed content, original unchanged

	def Transposed()
		_oTrCopy_ = new stzMatrix(This.Content())
		_oTrCopy_.Transpose()
		return _oTrCopy_.Content()

		def TransposedQ()
			return new stzMatrix(This.Transposed())


	# Computes the difference between adjacent elements in the matrix

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

	# Subtracts the mean of each row from its respective elements

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

		def SubtractMean()
			This.SubMean()

			def SubtractMeanQ()
				return This.SubMeanQ()

	  #-----------------------------#
	 # Visualization of the matrix #
	#-----------------------------#

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
