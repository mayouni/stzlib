
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

		return TRUE
	else
		return FALSE
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
					return FALSE
				ok
			next
		next

	ok

	return TRUE

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
					return FALSE
				ok
			next
		next

	ok

	return TRUE

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
	@pEngineMatrix = NULL

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

	def _EnsureEngineMatrix()
		if @pEngineMatrix != NULL
			return
		ok
		@pEngineMatrix = StzEngineMatrixNewFromList(@nRows, @nCols, @aContent)

	def _InvalidateEngineMatrix()
		if @pEngineMatrix != NULL
			StzEngineMatrixFree(@pEngineMatrix)
			@pEngineMatrix = NULL
		ok

	def _SyncFromEngine()
		if @pEngineMatrix = NULL
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

	# Adds a value to a specific column

	def AddXT(pnValue, p)

		if isList(p)
			_oList_ = new stzList(p)

			if _oList_.IsInColNamedParam()

				This.AddInCol(pnValue, p[2])
				return

			but _oList_.IsInRowNamedParam()

				This.AddInRow(pnValue, p[2])
				return

			but _oList_.IsInColsNamedParam()

				This.AddInCols(pnValue, p[2])
				return

			but _oList_.IsInRowsNamedParam()

				This.AddInRows(pnValue, p[2])
				return

			but _oList_.IsInDiagonal() or _oList_.IsInDiagonal1()

				This.AddInDiagonal(pnValue, p[2])
				return

			but _oList_.IsInDiagonal2()

				This.AddInDiagonal2(pnValue, p[2])
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

	def AddInRows(paRows, pnValue)

		if CheckParams()
			if NOT isNumber(pnValue)
				StzRaise("Incorrect param type! pnVakue must be a number.")
			ok

			if NOT isList(paColumns)
				StzRaise("Incorrect param type! paColumns must be a list.")
			ok
		ok

		 # Case: AddInRows(8, [ :From = 1, :To = 3 ])

		if len(paColumns) = 2 and

		   isList(paColumns[1]) and len(paColumns[1]) = 2 and
		   isString(paColumns[1][1]) and paColumns[1][1] = :From and
		   isNumber(paColumns[1][2]) and

		   isList(paColumns[2]) and len(paColumns[2]) = 2 and
		   isString(paColumns[2][1]) and paColumns[2][1] = :To and
		   isNumber(paColumns[2][2])

			This._UpdateRegion(:add, paColumns[1][2], paColumns[2][2], 1, @nCols, pnValue)
			return
		ok

		#-- Other cases

		_nLen_ = len(panRows)

		for i = 1 to _nLen_
			for j = 1 to @nCols
				@aContent[_nRow_][j] += pnValue
				@aContent[panRows[i]][j] += pnValue
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

		_nLen_ = len(panCols)

		_aCommands_ = []
		_cCode_ = 'updateColumn(@aContent, '

		for i = 1 to _nLen_
			_cCode_ += ':mul, ' + panCols[i] + ', ' + pnValue + ', '
		next

		_cCode_ += ')'
		_cCode_ = StzReplace(_cCode_, ", )", ")")

		eval(_cCode_)

		# More performant then:

		# for i = 1 to nLen
		# 	updateList(@aContent, :mul, :col, panCols[i], pnValue)
		# next

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

	# Solve A x = b by Gauss-Jordan with partial pivoting -- returns
	# the solution VECTOR (list). Singular systems REFUSE (LAW 3);
	# no least-squares guessing.
	def SolveFor(paB)
		if @nRows != @nCols
			raise("SolveFor needs a square system (A must be n x n)")
		ok
		if NOT (isList(paB) and len(paB) = @nRows)
			raise("b must be a list of " + @nRows + " numbers")
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
		if @pEngineMatrix != NULL
			_pB_ = StzEngineMatrixNewFromList(_nBRows_, _nBCols_, paMatrix)
			_pC_ = StzEngineMatrixNew(@nRows, _nBCols_)
			if _pB_ != NULL and _pC_ != NULL
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
		if @pEngineMatrix != NULL
			_pMbB = StzEngineMatrixNewFromList(_nInputRows_, _nInputCols_, paMatrix)
			if _pMbB != NULL
				_pMbResult = StzEngineMatrixMultiply(@pEngineMatrix, _pMbB)
				StzEngineMatrixFree(_pMbB)
				if _pMbResult != NULL
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
		if @pEngineMatrix != NULL
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
		if @pEngineMatrix != NULL
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
		if @pEngineMatrix != NULL
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
		if @pEngineMatrix != NULL
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

	func FindCol(paCol)
		_aResult_ = []

		for nColIndex = 1 to @nCols
			_bMatch_ = True

			for nRowIndex = 1 to @nRows
				if @aContent[nRowIndex][nColIndex] != paCol[nRowIndex]
					_bMatch_ = False
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
			_bMatch_ = True

			for nColIndex = 1 to @nCols
				if @aContent[nRowIndex][nColIndex] != panRow[nColIndex]
					_bMatch_ = False
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
			return This.FindElementsInSection(pElmOrMany, panStart, panEnd)
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

		_bXT_ = FALSE

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
					_bXT_ = TRUE
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

			_oList_ = new stzList(pBy)

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
		_aElmsPos_ = This.FindThisElementInSection(panStart, panEnd)
		This.ReplaceElementsAtByMany(_aElmsPos_, paMany)

		def ReplaceThisElementInSectionByMany(pnElm, panStart, panEnd, paMany)
			This.ReplaceElementInSectionByMany(pnElm, panStart, panEnd, paMany)

	def ReplaceElementInSectionByManyXT(pnElm, panStart, panEnd, paMany)
		_aElmsPos_ = This.FindThisElementInSection(panStart, panEnd)
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
		if @pEngineMatrix != NULL
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

	def Inverse()

		# Only handle square matrices

		if @nRows != @nCols
			raise("Inverse is only defined for square matrices")
		ok

		# Engine fast path
		This._EnsureEngineMatrix()
		if @pEngineMatrix != NULL
			_pInvResult = StzEngineMatrixInverse(@pEngineMatrix)
			if _pInvResult != NULL
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
				@aContent = _aInvMatrix
				This._InvalidateEngineMatrix()
				return
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
	
		@aContent = _aInverse_


	# Transpose the matrix in place (engine-backed, pure-Ring fallback)

	def Transpose()

		# Engine fast path

		This._EnsureEngineMatrix()

		if @pEngineMatrix != NULL

			_pTrResult = StzEngineMatrixTranspose(@pEngineMatrix)

			if _pTrResult != NULL

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

		see char(226) + char(148) + char(140) + ring_copy(" ", _nTotalWidth_) + char(226) + char(148) + char(144) + NL

		# Matrix content

		for i = 1 to @nRows

			see char(226) + char(148) + char(130) + " "

			for j = 1 to @nCols

				# Format and left-pad numbers

				_cFormattedNum_ = _FormatNumber(@aContent[i][j])
				see ring_copy(" ", _anColWidths_[j] - StzLen(_cFormattedNum_)) + _cFormattedNum_ + " "

			next

			see char(226) + char(148) + char(130) + NL
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
