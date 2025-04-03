#-------------------------#
#  SOFTANZA MATRIX CLASS  #
#-------------------------#

# TODO :Potential Future Enhancements:
# -> Remaining arithmetic calculations (Subtract, Divide, Power, Modulo)
# -> More advanced mathematical operations
# -> Machine learning-specific methods

#--

#NOTE : RingFastPro Extension Usage in this class

# The RingFastPro extension provides high-performance list
# of numbers manipulation functions that are most effective
# for bulk operations on lists of numbers and matrices.

# Therefore, in this class, we use updateList() from RingFastPro
# for uniform transformations like adding/multiplying all elements,
# updating entire rows/columns, or performing serial operations.

# While we avoid using FastPro for complex computational
# logic or methods requiring individual element inspection,
# as traditional iteration remains more readable and flexible.

#-- Global functions

func StzMatrixQ(paMatrix)
	return new stzMatrix(paMatrix)

# Global matrix creation functions

func Diagonal1Matrix(paValues)

	nSize = len(paValues)
	aMatrix = []

	for i = 1 to nSize

		aRow = []

		for j = 1 to nSize

			if j = 1
				aRow + paValues[i]
			else
				aRow + 0
			ok

		next

		aMatrix + aRow

	next

	return aMatrix

func Diagonal2Matrix(paValues)

	nSize = len(paValues)
	aMatrix = []
    
	for i = 1 to nSize

		aRow = []

		for j = 1 to nSize

			if j = nSize - i + 1
				aRow + paValues[i]
			else
				aRow + 0
			ok

		next

		aMatrix + aRow

	next

	return aMatrix

func ConstantMatrix(paParams)

	nValue = paParams[1]
	aSize = paParams[2]

	nRows = aSize[1]
	nCols = aSize[2]

	aMatrix = []

	for i = 1 to nRows

		aRow = []

		for j = 1 to nCols
			aRow + nValue
		next

		aMatrix + aRow

	next

	return aMatrix


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

		nLen = len(paList)
		nLen2 = len(paList[1])

		for i = 1 to nLen
			for j = 1 to nLen2
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

		nLen = len(paList)
		nLen2 = len(paList[1])

		for i = 1 to nLen
			for j = 1 to nLen2
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


class stzMatrix

	# Matrix core attributes

	@aMatrix     # Stores the actual matrix data
	@nRows       # Number of rows
	@nCols       # Number of columns

	# Constructor with flexible initialization

	def init(paInput)

		if isList(paInput)

			# If input is a list, directly use it as matrix

			@aMatrix = paInput
			@nRows = len(paInput)
			@nCols = len(paInput[1])

		but isNumber(paInput[1]) and isNumber(paInput[2])

			# If input is dimensions, create zero matrix

			@nRows = paInput[1]
			@nCols = paInput[2]
			@aMatrix = list(@nRows)

			for i = 1 to @nRows
				@aMatrix[i] = list(@nCols, 0)
			next
		ok

	# Raw matrix access

	def Content()
		return @aMatrix

	def Copy()
		return new stzMatrix(@aMatrix)

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

	def Add(pnValue)

		if isList(pnValue) and @IsMatrix(pnValue)
			This.AddMatrix(pnValue)
			return
		ok

		# Using RingFastPro

		updateList(@aMatrix, :add, :manyrows, 1, @nRows, pnValue)

		# Innstead of this:

		# for i = 1 to @nRows
		# 	for j = 1 to @nCols
		# 		@aMatrix[i][j] += pnValue
		# 	next
		# next

	# Adds a value to a specific column

	def AddInCol(pnValue, pnCol)

		# Using RingFastPro

		updateList(@aMatrix, :add, :col, pnCol, pnValue)

		# Instead of this:

		# for i = 1 to @nRows
		# 	@aMatrix[i][pnCol] += pnValue
		# next

	# Adds a value to a specific row

	def AddInRow(pnValue, pnRow)

		# Using RingFastPro

		updateList(@aMatrix, :add, :row, pnRow, pnValue)

		# Instead of this:

		# for j = 1 to @nCols
		# 	@aMatrix[pnRow][j] += pnValue
		# next

	# Adds a value to multiple columns

	def AddInCols(pnValue, paColumns)

		if CheckParams()
			if NOT isNumber(pnValue)
				stzeaise("Incorrect param type! pnVakue must be a number.")
			ok

			if NOT isList(paColumns)
				stzeaise("Incorrect param type! paColumns must be a list.")
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

			updateList(@aMatrix, :add, :manycols, paColumns[1][2], paColumns[2][2], pnValue)
			return
		ok

		#-- Other cases

		for nCol in paColumns
			for i = 1 to @nRows
				@aMatrix[i][nCol] += pnValue
			next
		next

	# Adds a value to multiple rows

	def AddInRows(pnValue, paRows)

		if CheckParams()
			if NOT isNumber(pnValue)
				stzeaise("Incorrect param type! pnVakue must be a number.")
			ok

			if NOT isList(paColumns)
				stzeaise("Incorrect param type! paColumns must be a list.")
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

			updateList(@aMatrix, :add, :manyrows, paColumns[1][2], paColumns[2][2], pnValue)
			return
		ok

		#-- Other cases

		for nRow in paRows
			for j = 1 to @nCols
				@aMatrix[nRow][j] += pnValue
			next
		next

	# Add value to main diagonal elements

	def AddInDiagonal(pnValue)

		nMin = @min([@nRows, @nCols])

		for i = 1 to nMin
			@aMatrix[i][i] += pnValue
		next

	# Add value to secondary diagonal elements

	def AddInDiagonal2(pnValue)

		nMin = @min([@nRows, @nCols])

		for i = 1 to nMin
			@aMatrix[i][@nCols - i + 1] += pnValue
		next

	  #-----------------------------#
	 # Element-wise multiplication #
	#-----------------------------#

	def MultiplyBy(pnValue)

		if isList(pnValue) and @IsMatrix(pnValue)
			This.MultiplyByMatrix(pnValue)
			return
		ok

		for i = 1 to @nRows
			for j = 1 to @nCols
				@aMatrix[i][j] *= pnValue
			next
		next

		def MultiplyByQ(pnValue)
			This.MultiplyBy(pnValue)
			return This

	# Multiply a specific column by a value

	def MultiplyCol(pnCol, pnValue)

		if CheckParams()

			if NOT isNumber(pnCol)
				stzraise("Incorrect param type! pnCol must be a number.")
			ok
	
			if isList(pnValue) and StzListQ(pnValue).IsByOrInColNamedParam()
				pnValue = pnValue[2]
	
				if NOT isNumber(pnValue)
					stzraise("Incorrect param type! pnValue must be a number.")
				ok
			ok
		ok

		updatelist(@aMatrix, :mul, :col, pnCol, pnValue)

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

			if NOT isList(panCols) and @IsListOfNumbers(panCols)
				stzraise("Incorrect param type! panCols must be a list of numbers.")
			ok
	
			if isList(pnValue) and StzListQ(pnValue).IsByOrInColNamedParam()
				pnValue = pnValue[2]
	
				if NOT isNumber(pnValue)
					stzraise("Incorrect param type! pnValue must be a number.")
				ok
			ok
		ok

		# Doing the job

		nLen = len(panCols)

		aCommands = []

		for i = 1 to nLen
			aCommands + [ :mul, :col, panCols[i], pnValue ]
		next

		# Using Softanza FastPro enhancement

		FastProUpdateMany(@aMatrix, aCommands)

		# More performant then:

		# for i = 1 to nLen
		# 	updateList(@aMatrix, :mul, :col, panCols[i], pnValue)
		# next

	# Multiply a specific row by a value

	def MultiplyRow(pnRow, pnValue)

		if CheckParams()

			if NOT isNumber(pnRow)
				stzraise("Incorrect param type! pnRow must be a number.")
			ok
	
			if isList(pnValue) and StzListQ(pnValue).IsByOrInRowNamedParam()
				pnValue = pnValue[2]
	
				if NOT isNumber(pnValue)
					stzraise("Incorrect param type! pnValue must be a number.")
				ok
			ok
		ok

		updatelist(@aMatrix, :mul, :row, pnRow, pnValue)

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

			if NOT isList(panRows) and @IsListOfNumbers(panRows)
				stzraise("Incorrect param type! panRows must be a list of numbers.")
			ok
	
			if isList(pnValue) and StzListQ(pnValue).IsByOrInColNamedParam()
				pnValue = pnValue[2]
	
				if NOT isNumber(pnValue)
					stzraise("Incorrect param type! pnValue must be a number.")
				ok
			ok
		ok

		# Doing the job

		nLen = len(panRows)

		aCommands = []

		for i = 1 to nLen
			aCommands + [ :mul, :row, panRows[i], pnValue ]
		next

		# Using Softanza FastPro enhancement

		FastProUpdateMany(@aMatrix, aCommands)

		# More performant then:

		# for i = 1 to nLen
		# 	updateList(@aMatrix, :mul, :row, panRows[i], pnValue)
		# next

	# Multiply main diagonal elements by a value

	def MultiplyDiagonal1(pnValue)

		if CheckParams()
			if isList(pnValue) and StzListQ(pnValue).IsByNamedParam()
				pnValue = pnValue[2]
			ok
		ok

		nMin = @min([@nRows, @nCols])

		for i = 1 to nMin
			@aMatrix[i][i] *= pnValue
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
			if isList(pnValue) and StzListQ(pnValue).IsByNamedParam()
				pnValue = pnValue[2]
			ok
		ok

		nMin = @min([@nRows, @nCols])

		for i = 1 to nMin
			@aMatrix[i][@nCols - i + 1] *= pnValue
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

		nInputRows = len(paMatrix)
		nInputCols = len(paMatrix[1])

		if @nRows != nInputRows or @nCols != nInputCols
			raise("Matrices must have the same dimensions")
		ok

		# Element-wise addition

		for i = 1 to @nRows
			for j = 1 to @nCols
				@aMatrix[i][j] += paMatrix[i][j]
			next
		next

	def MultiplyByMatrix(paMatrix)

		# Validate input is a list of lists

		if not (isList(paMatrix) and isList(paMatrix[1]))
			raise("Input must be a list of lists of numbers")
		ok

		# Check matrix multiplication dimensions

		nInputRows = len(paMatrix)
		nInputCols = len(paMatrix[1])
    
		if @nCols != nInputRows
			raise("Matrices cannot be multiplied: incompatible dimensions")
		ok

		# Create temporary result matrix

		aResultMatrix = []

		for i = 1 to @nRows

			aResultRow = []

			for j = 1 to nInputCols

				nSum = 0

				for k = 1 to @nCols
					nSum += @aMatrix[i][k] * paMatrix[k][j]
				next

				aResultRow + nSum
			next

			aResultMatrix + aResultRow
		next
    
		# Update the current matrix with the result

		@aMatrix = aResultMatrix
		@nCols = nInputCols

		def MultiplyByMatrixQ(pMatrix)
			return new stzMatrix(This.MultiplyByMatrix(pMatrix))

	  #------------------------#
	 # Statistical Operations #
	#------------------------#

	# Calculates the sum of all elements

	def Sum()

		nTotal = 0

		for i = 1 to @nRows

			for j = 1 to @nCols
				nTotal += @aMatrix[i][j]
			next

		next

		return nTotal

	# Calculates the mean of all elements

	def Mean()
		return Sum() / (@nRows * @nCols)

	# Finds the maximum value in the matrix

	def Max()

		nMax = @aMatrix[1][1]

		for i = 1 to @nRows
			for j = 1 to @nCols
				if @aMatrix[i][j] > nMax
					nMax = @aMatrix[i][j]
				ok
			next
		next

		return nMax

	# Finds the minimum value in the matrix

	def Min()

		nMin = @aMatrix[1][1]

		for i = 1 to @nRows
			for j = 1 to @nCols
				if @aMatrix[i][j] < nMin
					nMin = @aMatrix[i][j]
				ok
			next
		next

		return nMin

	#-------------------------------#
	#  FINDING THING IN THE MATRIX  #
	#-------------------------------#

	def FindElement(nElm)
		#TODO

	def FindElements(panElms)
		#TODO

	def FindCol(panCol)
		#TODO

	def FindCols(panCols)
		#TODO

	def FindRow(panRow)
		#TODO

	def FindRows(panRows)
		#TODO

	  #-----------------------------#
	 # Matrix Manipulation Methods #
	#-----------------------------#

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

		aResult = []

		for i = panStart[1] to panEnd[1]
			aRow = []
			for j = panStart[2] to panEnd[2]
				aRow + @aMatrix[i][j]
			next

			aResult + aRow
		next

		return aResult

		def SubMatrixQ(panStart, panEnd)
			return new stzMatrix(This.SubMatrix(panStart, panEnd))

		def Section(panStart, panEnd)
			return SubMatrix(panStart, panEnd)

	# Replaces a specific column with a given list

	def ReplaceCol(pnCol, panNewCol)

		if CheckParams()

			if NOT isNumber(pnCol)
				stzraise("Incorrect param type! pnCol must be a number.")
			ok

			if isList(panNewCol) and StzListQ(panNewCol).IsByOrWithNamedParam()
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
			@aMatrix[i][pnCol] = panNewCol[i]
		next

	# Replace multiple columns

	def ReplaceCols(panCols, panNewCols)

		if CheckParams()
			if NOT ( isList(panCols) and @IsListOfNonZeroPositiveNumbers(panCols) )
				stzraise("Incorrect param type! panCols must be a list of strictictly positive numbers.")
			ok

			if isList(panNewCols) and StzListQ(panNewCols).IsByOrWithNamedParam()
				panNewCols = panNewCols[2]
			ok

			if NOT ( isList(panNewCols) and @IsMatrixOfNonZeroPositiveNumbers(panNewCols) )
				stzraise("Incorrect param type! paNewCols must be a list of lists of NonZero positive numbers having the same size.")
			ok
		ok

		# Logical cheks

		nLenNewCols = len(panNewCols)

		if len(panNewCols[1]) != @nRows
			raise("Can't proceed! Replacement columns must match matrix rows")
		ok

		nLenCols = len(panCols)

		if nLenCols != len(panNewCols)
			raise("Can't proceed! Number of columns to replace must match new columns")
		ok

		# Doing the job

		for k = 1 to nLenCols

			nCol = panCols[k]

			for i = 1 to @nRows
				@aMatrix[i][nCol] = panNewCols[k][i]
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

			if isList(panNewRow) and StzListQ(panNewRow).IsByOrUsingNamedParam()
				panNewRow = panNewRow[2]
			ok

			if NOT @IsListOfNonZeroPositiveNumbers(panNewRow)
				stzraise("Incorrect param type! panNewRow must be a list of NonZero positive numbers.")
			ok
		ok

		if len(panNewRow) != @nCols
			raise("Can't proceed! New row must match matrix columns.")
		ok

		@aMatrix[pnRow] = panNewRow

	# Replace multiple rows

	def ReplaceRows(panRows, paNewRows)

		if CheckParams()
			if NOT ( isList(panRows) and @IsListOfNonZeroPositiveNumbers(panRows) )
				stzraise("Incorrect param type! panRows must be a list of strictictly positive numbers.")
			ok

			if isList(paNewRows) and StzListQ(paNewRows).IsByOrWithNamedParam()
				paNewRows = paNewRows[2]
			ok

			if NOT ( isList(paNewRows) and @IsMatrixOfNonZeroPositiveNumbers(paNewRows) )
				stzraise("Incorrect param type! paNewRows must be a list of lists of NonZero positive numbers having the same size.")
			ok
		ok

		nLenRows = len(panRows)

		if nLenRows != len(paNewRows)
			raise("Number of rows to replace must match new rows")
		ok

		for k = 1 to nLenRows

			nRow = panRows[k]

			if len(paNewRows[k]) != @nCols
				raise("Replacement row must match matrix columns")
			ok

			@aMatrix[nRow] = paNewRows[k]
		next

	  #------------------------------------#
	 #  REPLACING ELEMENTS IN THE MATRIX  #
	#------------------------------------#

	# Replacing all the occurrence of an element by a new element

	def ReplaceElement(pnElm, pnNewElm)

		if isList(pnNewElm)
			This.ReplaceElementByMany(pnElm, pnNewElm)
		ok

		#TODO

		def ReplaceAllOccurrences(pnElm, pnNewElm)
			This.ReplaceElement(pnElm, pnNewElm)

	# Replacing any element at the given position by a new element

	def ReplaceElmentAt(pnRow, pnCol, pnNewElm)
		#TODO

	# Replacing a given element by a new element, only if
	# it exists at the given posisiton

	def ReplaceThisElementAt(pnElm, pnRow, pnCol, pnNewElm)

		if CheckParams()
			if NOT (isNumber(pnRow) and isNumber(pnCol))
				stzraise("Incorrect param types! pnRow and pnCol must be both numbers.")
			ok

			if NOT (pnRow > 0 and pnCol > 0)
				stzraise("Incorrect param values! pnRow and pnCol must be both non-zero positive integers.")
			ok

			if NOT isNumber(pnNewElm)
				stzraise("Incorrect param type! pnNewElm must be a number.")
			ok
		ok

		@aMatrix[pnRow][pnCol] = pnNewElm

	# Replacing the occureences of the given elements in the matrix by
	# the given new element, only they exist at the given positions

	def RepalaceTheseElementsAt(panElms, panPos, pnNewElm)
		#TODO

	  #--------------------------------#
	 #  REPLACEMENT BY MANY ELEMENTS  #
	#--------------------------------#

	# Replacing all the occurrences of an element by the given new element

	def ReplaceElementByMany(pnElm, panNewElms)
		#TODO
		# consider the @min() of the number of occurrences of pnElm
		# in the matrix and the lenght of panNewElms

		def ReplaceAllOccurrencesByMany(pnElm, panNewElms)
			This.ReplaceElementByMany(pnElm, panNewElms)

	def ReplaceElementByManyXT(pnElm, panNewElms)
		#TODO
		# if the number of occurrences of pnElm is different then
		# the lenght of panNewElms then go cyclic (in case there
		# are less elements in panNewElms, restart from the first)

		def ReplaceAllOccurrencesXT(pnElm, panNewElms)
			This.ReplaceElementXT(pnElm, panNewElms)

	#--

	# Replacing the occureences of the given elements in the matrix by
	# the given new elements, only if they exist at the given positions

	def RepalaceTheseElementsAtByMany(panElms, panPos, panNewElms)
		#TODO
		# consider the @min() of the number of occurrences of panElms
		# in the matrix and the lenght of panNewElms

	def RepalaceTheseElementsAtByManyXT(panElms, panPos, panNewElms)
		#TODO
		# if the number of occurrences of panElms is different then
		# the lenght of panNewElms then go cyclic (in case there
		# are less elements in panNewElms, restart from the first)

	  #-----------------------------#
	 # Specialized Data Extraction #
	#-----------------------------#

	# Extracts diagonal elements

	def Diagonal()

		nMin = @min([ @nRows, @nCols ])
		aDiagonal = []

		for i = 1 to nMin
			aDiagonal + @aMatrix[i][i]
		next

		return aDiagonal

		func Diagonal1()

	# Secondary diagonal elements

	def Diagonal2()

		nMin = @min([@nRows, @nCols])
		aDiagonal = []

		for i = 1 to nMin
			aDiagonal + @aMatrix[i][@nCols - i + 1]
		next

		return aDiagonal

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

		# Base cases

		if @nRows = 1
			return @aMatrix[1][1]
		ok

		if @nRows = 2

			return  @aMatrix[1][1] * @aMatrix[2][2] - 
				@aMatrix[1][2] * @aMatrix[2][1]
		ok

		# Recursive calculation for larger matrices

		nDeterminant = 0
		nSign = 1

		for j = 1 to @nCols

			# Create submatrix

			aSubMatrix = []

			for k = 2 to @nRows

				aRow = []

				for l = 1 to @nCols
					if l != j
						aRow + @aMatrix[k][l]
					ok
				next

				aSubMatrix + aRow
			next

			# Recursive determinant calculation

			nDeterminant += nSign * @aMatrix[1][j] * 
                        		StzMatrixQ(aSubMatrix).Determinant()

			nSign *= -1
		next

		return nDeterminant

	# Simple Gaussian elimination for matrix inversion
	# ~> Reliable up to ~50x50 matrices

	def Inverse()

		# Only handle square matrices

		if @nRows != @nCols
			raise("Inverse is only defined for square matrices")
		ok

		# Check determinant

		nDet = This.Determinant()

		if nDet = 0
			raise("Matrix is not invertible (determinant is zero)")
		ok

		# Create augmented matrix with identity

		aAugmented = []

		for i = 1 to @nRows
	
			aRow = []
	
			for j = 1 to @nCols
				aRow + @aMatrix[i][j]
			next
	
			for j = 1 to @nCols
				if j = i
					aRow + 1
				else
					aRow + 0
				ok
			next
	
			aAugmented + aRow
		next

		# Gaussian elimination
	
		for i = 1 to @nRows
	
			# Find pivot
	
			nPivot = aAugmented[i][i]
			nTwice = 2*@nCols
	
			for j = i to nTwice
				aAugmented[i][j] /= nPivot
			next
	
			# Eliminate other rows
	
			for k = 1 to @nRows
	
				if k != i
	
					nFactor = aAugmented[k][i]
	
					for j = i to nTwice
						aAugmented[k][j] -= nFactor * aAugmented[i][j]
					next
				ok
			next
		next

		# Extract inverse matrix
	
		aInverse = []
	
		for i = 1 to @nRows
	
			aRow = []
	
			for j = @nCols + 1 to nTwice
				aRow + aAugmented[i][j]
			next
	
			aInverse + aRow
		next
	
		@aMatrix = aInverse


	# Computes the difference between adjacent elements in the matrix

	def Diff()

		aResult = []
		
		for i = 1 to @nRows

			rowDiffs = []

			for j = 2 to @nCols
				rowDiffs + (@aMatrix[i][j] - @aMatrix[i][j-1])
			next

			aResult + rowDiffs

		next

		return aResult

	# Subtracts the mean of each row from its respective elements

	def SubMean()

		aResult = []
		
		for i = 1 to @nRows
	
			rowMean = @Mean(@aMatrix[i])
	
			rowAdjusted = []
	
			for j = 1 to @nCols
				rowAdjusted + (@aMatrix[i][j] - rowMean)
			next
	
			aResult + rowAdjusted
		next
	
		@aMatrix = aResult

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
			see "┌┐" + nl + "└┘" + nl
			return
		ok

		# Calculate the maximum width for each column

		anColWidths = []

		for i = 1 to @nCols
			anColWidths + 0
		next

		# Determine max width considering formatted numbers

		for j = 1 to @nCols

			nMaxWidth = 0

			for i = 1 to @nRows

				# Format number to remove unnecessary decimals

				cFormattedNum = _FormatNumber(@aMatrix[i][j])
				nWidth = len(cFormattedNum)

				if nWidth > nMaxWidth
					nMaxWidth = nWidth
				ok

			next

			anColWidths[j] = nMaxWidth
		next

		# Calculate total width for border

		nTotalWidth = @sum(anColWidths) + @nCols + 1

		# Top border

		see "┌" + ring_copy(" ", nTotalWidth) + "┐" + NL

		# Matrix content

		for i = 1 to @nRows

			see "│ "

			for j = 1 to @nCols

				# Format and left-pad numbers

				cFormattedNum = _FormatNumber(@aMatrix[i][j])
				see ring_copy(" ", anColWidths[j] - len(cFormattedNum)) + cFormattedNum + " "

			next

			see "│" + NL
		next

		# Bottom border

		see "└" + ring_copy(" ", nTotalWidth) + "┘" + nl

		#< @FunctionMisspelledForm

		def Shwo()
			return Show()

		#>

	# Helper function to format numbers

	def _FormatNumber(pnNum)

		# Convert to string, removing trailing zeros after decimal

		cNum = "" + pnNum

		# If decimal point exists

		if ring_substr1(cNum, ".") > 0

			# Remove trailing zeros

			while cNum[len(cNum)] = "0"
				cNum = left(cNum, len(cNum) - 1)
			end

			# Remove trailing decimal point if it's the last character

			if cNum[len(cNum)] = "."
				cNum = left(cNum, len(cNum) - 1)
			ok
		ok

		return cNum
