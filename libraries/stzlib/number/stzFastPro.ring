# A set of softanzified wrapper function ti RingFastPro extension

load "fastpro.ring"

#-- Wrappers and semantic simplifiers for FastPro functions

# pcCommand could be :set, :add, :sub, :mul, :div, :rem, :pow, :serial, :merge and :copy
# pccSelection could be :col, :row, :manycols, :manyrows and :items

#TODO: Include the uise of :rem and :pow

func FastProUpdate(paList, paCommands)

	# This function recieves pcCommands in a hashlist like this:
	# 	FastProUpdateCol(@aMatrix, [
	# 		:mul = [ val1, val2 ],
	# 		:merge = [val1, val2],
	# 		:copy = [val1, val2]
	# 	]

	# It generates a string with the corresponding the FastPro function
	# that contains all the commands as params in the same call, like this:

	# 	cCode = 'updateColumn( @aMatrix,
	# 		:mul, val1, val2,
	# 		:merge, val1, val2,
	# 		:copy, val1, val2 )

	# And then it evaluates that string to call FastPro dynamically

	# if a 1D list is provided, wrap it in a list container, so it
	# can be processed normally with the rest of the code (made for
	# a list of lists of number, i.e. a 2D list)

	if isList(paList) and IsListofNumbers(paList)
		aTemp = [] + paList
		paList = aTemp
	ok

	# Ensuring the command is contained in a hashlist

	if isList(paCommands) and len(paCommands) = 2 and
	   isString(paCommands[1]) and isList(paCommands[2])

		aTemp = [] + paCommands
		paCommands = aTemp
	ok

	# Doing the job

	nLen = len(paCommands)

	for i = 1 to nLen

		switch paCommands[i][1]

		on :Set

			# Case: FastProUpdate(aMatrix, :Set = [ :All, :With = 5 ])

			if isList(pacommands[i][2]) and len(paCommands[i][2]) = 1 and

			   isString(paCommands[i][2][1][1]) and paCommands[i][2][1][1] = :All and

			   isList(paCommands[i][2][1][2]) and len(paCommands[i][2][1][2]) = 2 and
			   isString(paCommands[i][2][1][2][1]) and paCommands[i][2][1][2][1] = :With and

			   isNumber(paCommands[i][2][1][2][2])

				updateList(paList, :set, :manyrows, 1, len(paList), paCommands[i][2][1][2][2])
				return paList

			# Case: FastProUpdate(aMatrix, :Set = [ :Col = 2, :Step = 2 ])

			but isList(paCommands[i][2]) and len(paCommands[i][2]) = 2 and

			   isList(paCommands[i][2][1]) and len(paCommands[i][2][1]) = 2  and
			   isString(paCommands[i][2][1][1]) and paCommands[i][2][1][1] = :Col and
			   isNumber(paCommands[i][2][1][2]) and

			   isList(paCommands[i][2][2]) and len(paCommands[i][2][2]) = 2 and
			   isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :Step and
			   isNumber(paCommands[i][2][2][2])

				updateList(paList, :serial, :col, paCommands[i][2][1][2], paCommands[i][2][2][2])
				return 

			# Case: FastProUpdate(aMatrix, :Set = [ :Row = 1, :With = 5 ]) or
			#       FastProUpdate(aMatrix, :Set = [ :Col = 1, :With = 5 ])

			but isList(paCommands[i][2]) and len(paCommands[i][2]) = 2 and

			   isList(paCommands[i][2][1]) and len(paCommands[i][2][1]) = 2 and
			   isString(paCommands[i][2][1][1]) and

			   (paCommands[i][2][1][1] = :Col or paCommands[i][2][1][1] = :Row) and
			   isNumber(paCommands[i][2][1][2])


				if paCommands[i][2][1][1] = :Row

					if isList(paCommands[i][2][2]) and len(paCommands[i][2][2]) = 2 and
					   isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :With and
					   isNumber(paCommands[i][2][2][2])

						cColOrRow = :Row
						nColOrRow = paCommands[i][2][1][2]
						nValue = paCommands[i][2][2][2]

					ok

				else # paCommands[i][2][1][1] = :Col

					if isList(paCommands[i][2][2]) and len(paCommands[i][2][2]) = 2 and
					   isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :With and
					   isNumber(paCommands[i][2][2][2])

						cColOrRow = :Col
						nColOrRow = paCommands[i][2][1][2]
						nValue = paCommands[i][2][2][2]

					ok

				ok

				updateList(paList, :set, cColOrRow, nColOrRow, nValue)
				return paList

			# Case: FastProUpdate(aMatrix, :Set = [ :Rows = [ 1, 3 ], :With = 5 ]) or
			#       FastProUpdate(aMatrix, :Set = [ :Cols = [ 1, 3 ], :With = 5 ])

			but isList(paCommands[i][2]) and len(paCommands[i][2]) = 2 and

			   isList(paCommands[i][2][1]) and len(paCommands[i][2][1]) = 2 and
			   isString(paCommands[i][2][1][1]) and

			   (paCommands[i][2][1][1] = :Rows or paCommands[i][2][1][1] = :Cols) and
			   isPairOfNumbers(paCommands[i][2][1][2])


				if paCommands[i][2][1][1] = :Rows

					if isList(paCommands[i][2][2]) and len(paCommands[i][2][2]) = 2 and
					   isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :With and
					   isNumber(paCommands[i][2][2][2])

						cColsOrRows = :manyrows
						nStart = paCommands[i][2][1][2][1]
						nEnd   = paCommands[i][2][1][2][2]
						nValue = paCommands[i][2][2][2]

					ok

				else # paCommands[i][2][1][1] = :Cols

					if isList(paCommands[i][2][2]) and len(paCommands[i][2][2]) = 2 and
					   isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :With and
					   isNumber(paCommands[i][2][2][2])

						cColsOrRows = :manycols
						nStart = paCommands[i][2][1][2][1]
						nEnd   = paCommands[i][2][1][2][2]
						nValue = paCommands[i][2][2][2]

					ok

				ok

			else
				stzraise("Syntax error! The command must look like this:" + NL +
					 ":Set = [ :Rows = [ 1, 3], :With = 5 ] or :Set = [ :Cold = [ 1, 3 ], :With = 5 ]")
			ok

			updateList(paList, :set, cColsOrRows, nStart, nEnd, nValue)
			return paList

		on :Copy

			# Case: FastProUpdate(aMatrix, :Copy = [ :Row = 1, :ToRow = 3 ] or
			#       FastProUpdate(aMatrix, :Copy = [ :Col = 1, :ToCol = 3 ]

			if isList(paCommands[i][2]) and len(paCommands[i][2]) = 2 and

			   isList(paCommands[i][2][1]) and len(paCommands[i][2][1]) = 2 and
			   isString(paCommands[i][2][1][1]) and
			   (paCommands[i][2][1][1] = :Col or paCommands[i][2][1][1] = :Row) and
			   isNumber(paCommands[i][2][1][2])

				if paCommands[i][2][1][1] = :Row

					if isList(paCommands[i][2][2]) and len(paCommands[i][2][2]) = 2 and
					   isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :ToRow and
					   isNumber(paCommands[i][2][2][2])

						cColOrRow = :Row
						n1 = paCommands[i][2][1][2]
						n2 = paCommands[i][2][2][2]

					ok

				else # paCommands[i][2][1][1] = :Col

					if isList(paCommands[i][2][2]) and len(paCommands[i][2][2]) = 2 and
					   isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :ToCol and
					   isNumber(paCommands[i][2][2][2])

						cColOrRow = :Col
						n1 = paCommands[i][2][1][2]
						n2 = paCommands[i][2][2][2]

					ok

				ok

			else
				stzraise("Syntax error! The command must look like this:" + NL +
					 ":Copy = [ :Row = 1, :ToRow = 3 ] or :Copy = [ :Col = 1, :ToCol = 3 ]")
			ok

			updateList(paList, :copy, cColOrRow, n1, n2)
			return paList

		on :Add

			# Case: FastProUpdate(aMatrix, :Add = [ 8, :ToColsFrom = [1, :To = 2] ])

			if isList(paCommands[i][2]) and len(paCommands[i][2]) = 2 and
			   isNumber(paCommands[i][2][1]) and

			   isList(paCommands[i][2][2]) and len(paCommands[i][2][2]) = 2

			   	if isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :ToColsFrom and
			   	   isList(paCommands[i][2][2][2]) and len(paCommands[i][2][2][2]) = 2 and
			   	   isNumber(paCommands[i][2][2][2][1]) and

			   	   isList(paCommands[i][2][2][2][2]) and len(paCommands[i][2][2][2][2]) = 2 and
			   	   isString(paCommands[i][2][2][2][2][1]) and paCommands[i][2][2][2][2][1] = :To and
			   	   isNumber(paCommands[i][2][2][2][2][2])

					updateList(paList, :add, :manycols,
						paCommands[i][2][2][2][1], paCommands[i][2][2][2][2][2], paCommands[i][2][1])

					return paList

				but isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :ToRowsFrom and
			   	   isList(paCommands[i][2][2][2]) and len(paCommands[i][2][2][2]) = 2 and
			   	   isNumber(paCommands[i][2][2][2][1]) and

			   	   isList(paCommands[i][2][2][2][2]) and len(paCommands[i][2][2][2][2]) = 2 and
			   	   isString(paCommands[i][2][2][2][2][1]) and paCommands[i][2][2][2][2][1] = :To and
			   	   isNumber(paCommands[i][2][2][2][2][2])

					updateList(paList, :add, :manyrows,
						paCommands[i][2][2][2][1], paCommands[i][2][2][2][2][2], paCommands[i][2][1])

					return paList

				ok

			else
				stzraise("Syntax error! The command must look like this:" + NL +
					 ":Add = [ 8, :ToColsFrom = [1, :To = 2] ] or :Add = [ 8, :ToRowsFrom = [1, :To = 2] ]")

			ok

		on :Subtract

			# Case: FastProUpdate(aMatrix, :Subtract = [ 8, :FromColsFrom = [1, :To = 2] ])

			if isList(paCommands[i][2]) and len(paCommands[i][2]) = 2 and
			   isNumber(paCommands[i][2][1]) and

			   isList(paCommands[i][2][2]) and len(paCommands[i][2][2]) = 2

			   	if isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :FromColsFrom and
			   	   isList(paCommands[i][2][2][2]) and len(paCommands[i][2][2][2]) = 2 and
			   	   isNumber(paCommands[i][2][2][2][1]) and

			   	   isList(paCommands[i][2][2][2][2]) and len(paCommands[i][2][2][2][2]) = 2 and
			   	   isString(paCommands[i][2][2][2][2][1]) and paCommands[i][2][2][2][2][1] = :To and
			   	   isNumber(paCommands[i][2][2][2][2][2])

					updateList(paList, :sub, :manycols,
						paCommands[i][2][2][2][1], paCommands[i][2][2][2][2][2], paCommands[i][2][1])

					return paList

				but isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :FromRowsFrom and
			   	   isList(paCommands[i][2][2][2]) and len(paCommands[i][2][2][2]) = 2 and
			   	   isNumber(paCommands[i][2][2][2][1]) and

			   	   isList(paCommands[i][2][2][2][2]) and len(paCommands[i][2][2][2][2]) = 2 and
			   	   isString(paCommands[i][2][2][2][2][1]) and paCommands[i][2][2][2][2][1] = :To and
			   	   isNumber(paCommands[i][2][2][2][2][2])

					updateList(paList, :sub, :manyrows,
						paCommands[i][2][2][2][1], paCommands[i][2][2][2][2][2], paCommands[i][2][1])

					return paList

				ok

			else
				stzraise("Syntax error! The command must look like this:" + NL +
					 ":Subtract = [ 8, :FromColsFrom = [1, :To = 2] ] or :subtract = [ 8, :FromRowsFrom = [1, :To = 2] ]")

			ok

		on :Multiply

			if isList(paCommands[i][2]) and len(paCommands[i][2]) = 2 and

				isList(paCommands[i][2][1]) and len(paCommands[i][2][1]) = 2 and
				isString(paCommands[i][2][1][1]) and paCommands[i][2][1][1] = :Col and
				isNumber(paCommands[i][2][1][2])

				paCommands[i][2] + [ :ToCol, paCommands[i][2][1][2] ] 
			ok

			# Cases: FastProUpdate(aMatrix, :Multiply = [ :Col = 1, :By = 0.5 ] or
			#        FastProUpdate(aMatrix, :Multiply = [ :Col = 1, :By = 0.5, :ToCol = 3 ]

			if isList(paCommands[i][2]) and len(paCommands[i][2]) = 3 and
			   isList(paCommands[i][2][1]) and len(paCommands[i][2][1]) = 2 and
			   isString(paCommands[i][2][1][1])

				if paCommands[i][2][1][1] = :Col and
				   isNumber(paCommands[i][2][1][2]) and

				   isList(paCommands[i][2][2]) and len(paCommands[i][2][2]) = 2 and
				   isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :By and
				   isNumber(paCommands[i][2][2][2]) and

				   isList(paCommands[i][2][3]) and len(paCommands[i][2][3]) = 2 and
				   isString(paCommands[i][2][3][1]) and paCommands[i][2][3][1] = :ToCol and
				   isNumber(paCommands[i][2][3][2])

					nCol = paCommands[i][2][1][2]
					nVal = paCommands[i][2][2][2]
					nToCol = paCommands[i][2][3][2]
		
					updateList(paList, :mul, :col, nCol, nVal, nToCol)
					return paList

				ok

			# Case: FastProUpdate(aMatrix, :Multiply = [ :Row = 1, :By = 0.5 ]

			but isList(paCommands[i][2]) and len(paCommands[i][2]) = 2 and

			    isList(paCommands[i][2][1]) and len(paCommands[i][2][1]) = 2 and
			    isString(paCommands[i][2][1][1]) and paCommands[i][2][1][1] = :Row and
			    isNumber(paCommands[i][2][1][2]) and

			    isList(paCommands[i][2][2]) and len(paCommands[i][2][2]) = 2 and
			    isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :By and
			    isNumber(paCommands[i][2][2][2])

				updateList(paList, :mul, :row, paCommands[i][2][1][2], paCommands[i][2][2][2])
				return paList

			else

				stzraise("Syntax error! The command must look like this:" + NL +
					 ":Multiply = [ :Col = 1, :By = 2 ] or :Multiply = [ :Col = 1, :By = 2, :ToCol = 3 ]")
			ok

		on :Divide

			if isList(paCommands[i][2]) and len(paCommands[i][2]) = 2 and

				isList(paCommands[i][2][1]) and len(paCommands[i][2][1]) = 2 and
				isString(paCommands[i][2][1][1]) and paCommands[i][2][1][1] = :Col and
				isNumber(paCommands[i][2][1][2])

				paCommands[i][2] + [ :ToCol, paCommands[i][2][1][2] ] 
			ok

			# Cases: FastProUpdate(aMatrix, :Divide = [ :Col = 1, :By = 0.5 ] or
			#        FastProUpdate(aMatrix, :Divide = [ :Col = 1, :By = 0.5, :ToCol = 3 ]

			if isList(paCommands[i][2]) and len(paCommands[i][2]) = 3 and
			   isList(paCommands[i][2][1]) and len(paCommands[i][2][1]) = 2 and
			   isString(paCommands[i][2][1][1])

				if paCommands[i][2][1][1] = :Col and
				   isNumber(paCommands[i][2][1][2]) and

				   isList(paCommands[i][2][2]) and len(paCommands[i][2][2]) = 2 and
				   isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :By and
				   isNumber(paCommands[i][2][2][2]) and

				   isList(paCommands[i][2][3]) and len(paCommands[i][2][3]) = 2 and
				   isString(paCommands[i][2][3][1]) and paCommands[i][2][3][1] = :ToCol and
				   isNumber(paCommands[i][2][3][2])

					nCol = paCommands[i][2][1][2]
					nVal = paCommands[i][2][2][2]
					nToCol = paCommands[i][2][3][2]
		
					updateList(paList, :div, :col, nCol, nVal, nToCol)
					return paList

				ok

			# Case: FastProUpdate(aMatrix, :Divide = [ :Row = 1, :By = 0.5 ]

			but isList(paCommands[i][2]) and len(paCommands[i][2]) = 2 and

			    isList(paCommands[i][2][1]) and len(paCommands[i][2][1]) = 2 and
			    isString(paCommands[i][2][1][1]) and paCommands[i][2][1][1] = :Row and
			    isNumber(paCommands[i][2][1][2]) and

			    isList(paCommands[i][2][2]) and len(paCommands[i][2][2]) = 2 and
			    isString(paCommands[i][2][2][1]) and paCommands[i][2][2][1] = :By and
			    isNumber(paCommands[i][2][2][2])

				updateList(paList, :div, :row, paCommands[i][2][1][2], paCommands[i][2][2][2])
				return paList

			else

				stzraise("Syntax error! The command must look like this:" + NL +
					 ":Multiply = [ :Col = 1, :By = 2 ] or :Multiply = [ :Col = 1, :By = 2, :ToCol = 3 ]")
			ok

		on :Merge

			# Case: FastProUpdate(aImage, [
			# 	:Multiply = [ :Col = 1, :By = 0.3, :ToCol = 1 ],
			#       :Merge    = [ :Cols = [ 1, 2 ], :InCol = 1 ],
        		# 	:Copy     = [ :Row = 1, :ToRow = 3]
			# ])

			aValues = paCommands[i][2]

			# Check the softanzifed syntax

			if not (isList(aValues) and len(aValues) = 2 and

				isList(aValues[1]) and len(aValues[1]) = 2 and
				isString(aValues[1][1]) and aValues[1][1] = :Cols and

				IsPairOfNumbers(aValues[1][2]) and

				isList(aValues[2]) and len(aValues[2]) = 2 and
				isString(aValues[2][1]) and aValues[2][1] = :InCol and
				isNumber(aValues[2][2]) )

				stzraise("Syntax error! The command must look like this:" + NL + 
					 ":Merge = [ :Cols = [ 1, 3], :InCol = 1 ]")
			ok

			# Transform it to a RingFastPro-freindly syntax

			aTempCommand = [ :merge ]

			aVals = aValues[1][2]

			n = ring_find(aVals, aValues[2][2])
			del(aVals, n)

			anTempVals = [] + aValues[2][2]

			nLen = len(aVals)
			for j = 1 to nLen
				anTempVals + aVals[j]
			next
			
			aTempCommand + anTempVals
			paCommands[i] = aTempCommand
		off

	next

	# If the execution flow reatches this point, then what
	# was provided is a list of commands that we should
	# contruct dynamicall and feed to updateColumn() from
	# RingFastPro for execution.

	# Construct the updateColumn call dynamically
	cCode = "updateColumn(paList"
    
	# Iterate through commands and add to the call

	nLen = len(paCommands)

	for i = 1 to nLen

		cCmd = paCommands[i][1]
		aParams = paCommands[i][2]
		nLenParams = len(aParams)

		cCode += ", :" + cCmd

		for j = 1 to nLenParams
 			cCode += ", " + @@(aParams[j])
		next

	next
    
	cCode += ")"

	# Evaluate the dynamically constructed call

	eval(cCode)
	return paList


func FastProUpdateList(paList, pcCommand, pcSelection, panValues)


	if isNumber(panValues)
		updateList(paList, pcCommand, pcSelection, panValues)
		return paList
	ok

	if CheckParams()
		if NOT ( isList(panValues) and IsListOfNumbers(panValues) )
			stzraise("Incorrect param type! panValues must be a list of numbers.")
		ok
	ok

	nLen = len(panValues)

	switch nLen
	on 1
		updateList(paList, pcCommand, pcSelection, panValues[1])
	on 2
		updateList(paList, pcCommand, pcSelection, panValues[1], panValues[2])
	on 3
		updateList(paList, pcCommand, pcSelection, panValues[1], panValues[2], panValues[3])
	off

	return paList

func FastProUpdateList1(paList, pcCommand, pcSelection, p1)
	updateList(paList, pcCommand, pcSelection, p1)
	return paList

	# Examples:

	# updateList(<aList>,:set,:items,<nValue>)
	
func FastProUpdateList2(paList, pcCommand, pcSelection, p1, p2)
	updateList(paList, pcCommand, pcSelection, p1, p2)
	return paList

	# Examples:

	# updateList(<aList>,:set,:row,<nRow>,<nValue>)
	# updateList(<aList>,:set,:col,<nCol>,<nValue>)

	# updateList(<aList>,:copy,:row,<nRowSrc>,<nRowDest>)
	# updateList(<aList>,:copy,:col,<nColSrc>,<nColDest>)

	# updateList(<aList>,:merge,:row,<nRowDest>,<nRow>)
	# updateList(<aList>,:merge,:col,<nColDest>,<nCol>)

func FastProUpdateList3(paList, pcCommand, pcSelection, p1, p2, p3)
	updateList(paList, pcCommand, pcSelection, p1, p2)
	return paList

	# Examples:

	# updateList(<aList>,:set,:manyrows,<nRowStart>,<nRowEnd>,<nValue>)
	# updateList(<aList>,:set,:manycols,<nColStart>,<nColEnd>,<nValue>)
	# updateList(<aList>,:mul,:col,<nCol>,<nValue>,<nColDest>)
