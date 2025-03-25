load "../max/stzmax.ring"


pr()
	# Test basic matrix creation and element-level operations
	? "Matrix Creation and Element Operations Test"
	
	# Create a 3x3 matrix
	m = new stzMatrix([
		[1, 2, 3],
		[4, 5, 6],
		[7, 8, 9]
	])

	? "Original Matrix:"
	m.Show()

	# Add a value to entire matrix
	m.Add(10)
	? "After adding 10 to all elements:"
	m.Show()

	# Add to specific column
	m.AddInCol(5, 2)
	? "After adding 5 to second column:"
	m.Show()

	# Add to specific row
	m.AddInRow(3, 1)
	? "After adding 3 to first row:"
	m.Show()

	# Statistical operations
	? "Matrix Statistics:"
	? "Sum: " + m.Sum()
	? "Mean: " + m.Mean()
	? "Max: " + m.Max()
	? "Min: " + m.Min()

	# Submatrix extraction
	? "Submatrix Extraction:"
	subM = m.SubMatrixQ([1,3], [1,3])
	? "Submatrix of first and third rows, first and third columns:"
	subM.Show()

	# Diagonal extraction
	? "Diagonal Elements:"
	? m.Diagonal()

	# Column replacement
	m.ReplaceCol(2, [100, 200, 300])
	? "After replacing second column:"
	m.Show()

pf()
