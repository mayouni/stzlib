load "fastpro.ring"

# TODO :Potential Future Enhancements:
# -> More advanced mathematical operations
# -> Machine learning-specific methods
# -> Performance optimizations (using RingFastPro C extension)

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

#--

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
		return [@nRows, @nCols]

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

		for nCol in paColumns
			for i = 1 to @nRows
				@aMatrix[i][nCol] += pnValue
			next
		next

	# Adds a value to multiple rows

	def AddInRows(pnValue, paRows)

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

	def MultiplyByInCol(pnValue, pnCol)

		for i = 1 to @nRows
			@aMatrix[i][pnCol] *= pnValue
		next

	# Multiply a specific row by a value

	def MultiplyByInRow(pnValue, pnRow)

		for j = 1 to @nCols
			@aMatrix[pnRow][j] *= pnValue
		next

	# Multiply main diagonal elements by a value

	def MultiplyByInDiagonal1(pnValue)

		nMin = @min([@nRows, @nCols])

		for i = 1 to nMin
			@aMatrix[i][i] *= pnValue
		next

	# Multiply secondary diagonal elements by a value

	def MultiplyByInDagonal2(pnValue)

		nMin = @min([@nRows, @nCols])

		for i = 1 to nMin
			@aMatrix[i][@nCols - i + 1] *= pnValue
		next

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

	  #-----------------------------#
	 # Matrix Manipulation Methods #
	#-----------------------------#

	# Creates a submatrix by extracting specific rows and columns

	def SubMatrix(panRows, panCols)

		aSubMatrix = []
		nLenRows = len(panRows)
		nLenCols = len(panCols)

		for i = 1 to nLenRows

			aSubRow = []

			for j = 1 to nLenCols
				aSubRow + @aMatrix[panRows[i]][panCols[i]]
			next

			aSubMatrix + aSubRow

		next

		return aSubMatrix

		def SubMatrixQ(panRows, panCols)
			return new stzMatrix(This.SubMatrix(panRows, panCols))

	# Replaces a specific column with a given list

	def ReplaceCol(pnCol, paNewCol)

		if len(paNewCol) != @nRows
			raise("Column replacement must match matrix rows")
		ok
		
		for i = 1 to @nRows
			@aMatrix[i][pnCol] = paNewCol[i]
		next

	# Replace multiple columns

	def ReplaceCols(panCols, paNewCols)

		nLenCols = len(panCols)

		if nLenCols != len(paNewCols)
			raise("Number of columns to replace must match new columns")
		ok

		for k = 1 to nLenCols

			nCol = panCols[k]

			if len(paNewCols[k]) != @nRows
				raise("Replacement column must match matrix rows")
			ok

			for i = 1 to @nRows
				@aMatrix[i][nCol] = paNewCols[k][i]
			next
		next

	# Replace a specific row

	def ReplaceRow(pnRow, paNewRow)

		if len(paNewRow) != @nCols
			raise("New row must match matrix columns")
		ok

		@aMatrix[pnRow] = paNewRow

	# Replace multiple rows

	def ReplaceRows(panRows, paNewRows)

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
