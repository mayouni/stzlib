load "fastpro.ring"

# TODO :Potential Future Enhancements:
# -> More advanced mathematical operations
# -> Machine learning-specific methods
# -> Performance optimizations (using RingFastPro C extension)

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

		# Using RingFastPro

		updateList(@aMatrix, :add, :items, pnValue)

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

		# Using RingFastPro

		for nCol in paColumns
			updateList(@aMatrix, :add, :col, nCol, pnValue)
		next

		# Instead of this:

		# for nCol in paColumns
		# 	for i = 1 to @nRows
		# 		@aMatrix[i][nCol] += pnValue
		# 	next
		# next

	# Adds a value to multiple rows

	def AddInRows(pnValue, paRows)

		# Using RingFastPro

		for nRow in paRows
			updateList(@aMatrix, :add, :row, nRow, pnValue)
		next

		# Instead of this:

		# for nRow in paRows
		# 	for j = 1 to @nCols
		# 		@aMatrix[nRow][j] += pnValue
		# 	next
		# next

	  #-----------------------------#
	 # Element-wise multiplication #
	#-----------------------------#

	def MultiplyBy(pnValue)

		if isList(pnValue) and @IsMatrix(pnValue)
			This.MultiplyByMatrix(pnValue)
			return
		ok

		# Using RingFastPro

		updateList(@aMatrix, :mul, :items, pnValue)

		# Instead of this:

		# for i = 1 to @nRows
		# 	for j = 1 to @nCols
		# 		@aMatrix[i][j] *= pnValue
		# 	next
		# next

	  #-------------------------------#
	 #  Matrix-to-Matrix Operations  #
	#-------------------------------#

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

	def SubMatrix(panRows, panColumns)

		aSubMatrix = []

		for nRow in panRows

			aSubRow = []

			for nCol in panColumns
				aSubRow + @aMatrix[nRow][nCol]
			next

			aSubMatrix + aSubRow

		next

		return aSubMatrix

		def SubMatrixQ(panRows, panColumns)
			return new stzMatrix(This.SubMatrix(panRows, panColumns))

	# Replaces a specific column with a given list

	def ReplaceCol(pnCol, paNewColumn)

		if len(paNewColumn) != @nRows
			raise("Column replacement must match matrix rows")
		ok
		
		for i = 1 to @nRows
			@aMatrix[i][pnCol] = paNewColumn[i]
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

	  #-----------------------#
	 # Advanced Calculations #
	#-----------------------#

	func Determinant()

		# Implement determinant calculation
		# This requires recursive or iterative methods

		stzraise("Not yet implemented!")

	func Inverse()

		# Implement matrix inversion
		# Requires sophisticated linear algebra

		stzraise("Not yet implemented!")

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

		for j = 1 to @nCols

			nMaxWidth = 0

			for i = 1 to @nRows

				nWidth = len("" + @aMatrix[i][j])

				if nWidth > nMaxWidth
					nMaxWidth = nWidth
				ok
			next

			anColWidths[j] = nMaxWidth
		next

		# Calculate total width for border

		nTotalWidth = @sum(anColWidths) + @nCols + 1

		# Top border

		see "┌" + copy(" ", nTotalWidth) + "┐" + nl

		# Matrix content

		for i = 1 to @nRows

			see "│ "

			for j = 1 to @nCols
				# Left-pad numbers with spaces to align them properly
				see copy(" ", anColWidths[j] - len("" + @aMatrix[i][j])) + @aMatrix[i][j] + " "
			next

			see "│" + nl
		next

		# Bottom border

		see "└" + copy(" ", nTotalWidth) + "┘" + nl



