
# TODO :Potential Future Enhancements:
# -> More advanced mathematical operations
# -> Machine learning-specific methods
# -> Performance optimizations (using RingFastPro C extension)


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

		for i = 1 to @nRows
			for j = 1 to @nCols
				@aMatrix[i][j] += pnValue
			next
		next

	# Adds a value to a specific column

	def AddInCol(pnValue, pnCol)

		for i = 1 to @nRows
			@aMatrix[i][pnCol] += pnValue
		next


	# Adds a value to a specific row

	def AddInRow(pnValue, pnRow)

		for j = 1 to @nCols
			@aMatrix[pnRow][j] += pnValue
		next

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

	 # Element-wise multiplication

	def MultiplyBy(pnValue)

		for i = 1 to @nRows
			for j = 1 to @nCols
				@aMatrix[i][j] *= pnValue
			next
		next

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
		see "┌" + copy("───", @nCols) + "┐" + nl
		for i = 1 to @nRows
			see "│ "
			for j = 1 to @nCols
				see "" + @aMatrix[i][j] + " "
			next
			see "│" + nl
		next
		see "└" + copy("───", @nCols) + "┘" + nl
