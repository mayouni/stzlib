# A set of softanzified wrapper function ti RingFastPro extension

load "fastpro.ring"

#-- Wrappers and semantic simplifiers for FastPro functions

# pcCommand could be :set, :add, :sub, :mul, :div, :rem, :pow, :serial, :merge and :copy
# pccSelection could be :col, :row, :manycols, :manyrows and :items

#TODO: Include the uise of :rem and :pow

func CUpdate(paList, paCommand)
	return CUpdateList(paList, paCommand)

func FastProUpdate(paList, paCommand)


	# Case : FastProUpdate(myList, :set = [ :All, :with = 1000 ])

	if isList(paList) and IsListOfNumbers(paList) and paCommand = :Set and
	   isList(paCommand[2]) and len(paCommand[2]) = 2 and
	   isString(paCommand[2][1]) and paCommand[2][1] = :All and
	   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
	   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :With and
	   isNumber(paCommand[2][2][2])

		updateList(paList, :set, :items, paCommand[2][2][2])
		return paList

	ok

	# Ensuring the command is contained in a hashlist

	if isList(paCommand) and len(paCommand) = 2 and
	   isString(paCommand) and isList(paCommand[2])

		aTemp = [] + paCommand
		paCommand = aTemp
	ok

	# Doing the job: Preparing the calculated list
/*
? @@(paCommand[2])
? isList(paCommand[2]) and len(paCommand[2]) = 2 + NL

? isList(paCommand[2][1]) and len(paCommand[2][1]) = 2
? isString(paCommand[2][1][1]) and paCommand[2][1][1] = :Col
?isNumber(paCommand[2][1][2]) + NL

? isList(paCommand[2][2]) and len(paCommand[2][2]) = 2
? isString(paCommand[2][2][1]) and paCommand[2][2][1] = :With
?  isNumber(paCommand[2][2][2])
*/
# FastProUpdate(aMatrix, :set = [ :col = 1, :with = 100 ])
	switch paCommand[1]

	on :Set

		# Case: FastProUpdate(aMatrix, :Set = [ :All, :With = 5 ])

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isString(paCommand[2][1]) and paCommand[2][1] = :All and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :With and

		   isNumber(paCommand[2][2][2])

			updateList(paList, :set, :manyrows, 1, len(paList), paCommand[2][2][2])
			return paList

		# Case: FastProUpdate(aMatrix, :Set = [ :Col = 2, :With = 2 ])

		but isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2  and
		   isString(paCommand[2][1][1]) and paCommand[2][1][1] = :Col and
		   isNumber(paCommand[2][1][2]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :With and
		   isNumber(paCommand[2][2][2])

			updateList(paList, :set, :col, paCommand[2][1][2], paCommand[2][2][2]) 
			return paList

		# Case: FastProUpdate(aMatrix, :Set = [ :Col = 2, :Step = 2 ])

		but isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2  and
		   isString(paCommand[2][1][1]) and paCommand[2][1][1] = :Col and
		   isNumber(paCommand[2][1][2]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :Step and
		   isNumber(paCommand[2][2][2])

			updateList(paList, :serial, :col, paCommand[2][1][2], paCommand[2][2][2]) 
			return paList

		# Case: FastProUpdate(aMatrix, :Set = [ :Row = 1, :With = 5 ]) or
		#       FastProUpdate(aMatrix, :Set = [ :Col = 1, :With = 5 ])

		but isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and

		   (paCommand[2][1][1] = :Col or paCommand[2][1][1] = :Row) and
		   isNumber(paCommand[2][1][2])


			if paCommand[2][1][1] = :Row

				if isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
				   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :With and
				   isNumber(paCommand[2][2][2])

					cColOrRow = :Row
					nColOrRow = paCommand[2][1][2]
					nValue = paCommand[2][2][2]

				ok

			else # paCommand[2][1][1] = :Col

				if isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
				   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :With and
				   isNumber(paCommand[2][2][2])

					cColOrRow = :Col
					nColOrRow = paCommand[2][1][2]
					nValue = paCommand[2][2][2]

				ok

			ok

			updateList(paList, :set, cColOrRow, nColOrRow, nValue)
			return paList

		# Case: FastProUpdate(aMatrix, :Set = [ :Rows = [ 1, 3 ], :With = 5 ]) or
		#       FastProUpdate(aMatrix, :Set = [ :Cols = [ 1, 3 ], :With = 5 ])

		but isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and

		   (paCommand[2][1][1] = :Rows or paCommand[2][1][1] = :Cols) and
		   isPairOfNumbers(paCommand[2][1][2])

			if paCommand[2][1][1] = :Rows

				if isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
				   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :With and
				   isNumber(paCommand[2][2][2])

					nStart = paCommand[2][1][2][1]
					nEnd   = paCommand[2][1][2][2]
					nValue = paCommand[2][2][2]

					updateList(paList, :set, :manyrows, nStart, nEnd, nValue)
					return paList
				ok

			else # paCommand[2][1][1] = :Cols

				if isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
				   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :With and
				   isNumber(paCommand[2][2][2])

					nStart = paCommand[2][1][2][1]
					nEnd   = paCommand[2][1][2][2]
					nValue = paCommand[2][2][2]

					updateList(paList, :set, :manycols, nStart, nEnd, nValue)
					return paList
				ok

			ok

		else
			stzraise("Syntax error! The command must look like this:" + NL +
				 ":Set = [ :Rows = [ 1, 3], :With = 5 ] or :Set = [ :Cols = [ 1, 3 ], :With = 5 ]")
		ok

	on :Copy

		# Case: FastProUpdate(aMatrix, :Copy = [ :Row = 1, :ToRow = 3 ] or
		#       FastProUpdate(aMatrix, :Copy = [ :Col = 1, :ToCol = 3 ]

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and
		   (paCommand[2][1][1] = :Col or paCommand[2][1][1] = :Row) and
		   isNumber(paCommand[2][1][2])

			if paCommand[2][1][1] = :Row

				if isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
				   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :ToRow and
				   isNumber(paCommand[2][2][2])

					cColOrRow = :Row
					n1 = paCommand[2][1][2]
					n2 = paCommand[2][2][2]

				ok

			else # paCommand[2][1][1] = :Col

				if isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
				   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :ToCol and
				   isNumber(paCommand[2][2][2])

					cColOrRow = :Col
					n1 = paCommand[2][1][2]
					n2 = paCommand[2][2][2]

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

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and
		   isNumber(paCommand[2][1]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2

		   	if isString(paCommand[2][2][1]) and paCommand[2][2][1] = :ToColsFrom and
		   	   isList(paCommand[2][2][2]) and len(paCommand[2][2][2]) = 2 and
		   	   isNumber(paCommand[2][2][2][1]) and

		   	   isList(paCommand[2][2][2][2]) and len(paCommand[2][2][2][2]) = 2 and
		   	   isString(paCommand[2][2][2][2][1]) and paCommand[2][2][2][2][1] = :To and
		   	   isNumber(paCommand[2][2][2][2][2])

				updateList(paList, :add, :manycols,
					paCommand[2][2][2][1], paCommand[2][2][2][2][2], paCommand[2][1])
				return paList

			but isString(paCommand[2][2][1]) and paCommand[2][2][1] = :ToRowsFrom and
		   	   isList(paCommand[2][2][2]) and len(paCommand[2][2][2]) = 2 and
		   	   isNumber(paCommand[2][2][2][1]) and

		   	   isList(paCommand[2][2][2][2]) and len(paCommand[2][2][2][2]) = 2 and
		   	   isString(paCommand[2][2][2][2][1]) and paCommand[2][2][2][2][1] = :To and
		   	   isNumber(paCommand[2][2][2][2][2])

				updateList(paList, :add, :manyrows,
					paCommand[2][2][2][1], paCommand[2][2][2][2][2], paCommand[2][1])
				return paList
			ok

		else
			stzraise("Syntax error! The command must look like this:" + NL +
				 ":Add = [ 8, :ToColsFrom = [1, :To = 2] ] or :Add = [ 8, :ToRowsFrom = [1, :To = 2] ]")

		ok

	on :Subtract

		# Case: FastProUpdate(aMatrix, :Subtract = [ 8, :FromColsFrom = [1, :To = 2] ])

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and
		   isNumber(paCommand[2][1]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2

		   	if isString(paCommand[2][2][1]) and paCommand[2][2][1] = :FromColsFrom and
		   	   isList(paCommand[2][2][2]) and len(paCommand[2][2][2]) = 2 and
		   	   isNumber(paCommand[2][2][2][1]) and

		   	   isList(paCommand[2][2][2][2]) and len(paCommand[2][2][2][2]) = 2 and
		   	   isString(paCommand[2][2][2][2][1]) and paCommand[2][2][2][2][1] = :To and
		   	   isNumber(paCommand[2][2][2][2][2])

				updateList(paList, :sub, :manycols,
					paCommand[2][2][2][1], paCommand[2][2][2][2][2], paCommand[2][1])
				return paList

			but isString(paCommand[2][2][1]) and paCommand[2][2][1] = :FromRowsFrom and
		   	   isList(paCommand[2][2][2]) and len(paCommand[2][2][2]) = 2 and
		   	   isNumber(paCommand[2][2][2][1]) and

		   	   isList(paCommand[2][2][2][2]) and len(paCommand[2][2][2][2]) = 2 and
		   	   isString(paCommand[2][2][2][2][1]) and paCommand[2][2][2][2][1] = :To and
		   	   isNumber(paCommand[2][2][2][2][2])

				updateList(paList, :sub, :manyrows,
					paCommand[2][2][2][1], paCommand[2][2][2][2][2], paCommand[2][1])
				return paList
			ok

		else
			stzraise("Syntax error! The command must look like this:" + NL +
				 ":Subtract = [ 8, :FromColsFrom = [1, :To = 2] ] or :subtract = [ 8, :FromRowsFrom = [1, :To = 2] ]")

		ok

	on :Multiply

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and

			isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
			isString(paCommand[2][1][1]) and paCommand[2][1][1] = :Col and
			isNumber(paCommand[2][1][2])

			paCommand[2] + [ :ToCol, paCommand[2][1][2] ] 
		ok

		# Cases: FastProUpdate(aMatrix, :Multiply = [ :Col = 1, :By = 0.5 ] or
		#        FastProUpdate(aMatrix, :Multiply = [ :Col = 1, :By = 0.5, :ToCol = 3 ]

		if isList(paCommand[2]) and len(paCommand[2]) = 3 and
		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1])

			if paCommand[2][1][1] = :Col and
			   isNumber(paCommand[2][1][2]) and

			   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
			   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :By and
			   isNumber(paCommand[2][2][2]) and

			   isList(paCommand[2][3]) and len(paCommand[2][3]) = 2 and
			   isString(paCommand[2][3][1]) and paCommand[2][3][1] = :ToCol and
			   isNumber(paCommand[2][3][2])

				nCol = paCommand[2][1][2]
				nVal = paCommand[2][2][2]
				nToCol = paCommand[2][3][2]
	
				updateList(paList, :mul, :col, nCol, nVal, nToCol)
				return paList
			ok

		# Case: FastProUpdate(aMatrix, :Multiply = [ :Row = 1, :By = 0.5 ]

		but isList(paCommand[2]) and len(paCommand[2]) = 2 and

		    isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		    isString(paCommand[2][1][1]) and paCommand[2][1][1] = :Row and
		    isNumber(paCommand[2][1][2]) and

		    isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		    isString(paCommand[2][2][1]) and paCommand[2][2][1] = :By and
		    isNumber(paCommand[2][2][2])

			updateList(paList, :mul, :row, paCommand[2][1][2], paCommand[2][2][2])
			return paList
		else

			stzraise("Syntax error! The command must look like this:" + NL +
				 ":Multiply = [ :Col = 1, :By = 2 ] or :Multiply = [ :Col = 1, :By = 2, :ToCol = 3 ]")
		ok

	on :Divide

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and

			isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
			isString(paCommand[2][1][1]) and paCommand[2][1][1] = :Col and
			isNumber(paCommand[2][1][2])

			paCommand[2] + [ :ToCol, paCommand[2][1][2] ] 
		ok

		# Cases: FastProUpdate(aMatrix, :Divide = [ :Col = 1, :By = 0.5 ] or
		#        FastProUpdate(aMatrix, :Divide = [ :Col = 1, :By = 0.5, :ToCol = 3 ]

		if isList(paCommand[2]) and len(paCommand[2]) = 3 and
		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1])

			if paCommand[2][1][1] = :Col and
			   isNumber(paCommand[2][1][2]) and

			   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
			   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :By and
			   isNumber(paCommand[2][2][2]) and

			   isList(paCommand[2][3]) and len(paCommand[2][3]) = 2 and
			   isString(paCommand[2][3][1]) and paCommand[2][3][1] = :ToCol and
			   isNumber(paCommand[2][3][2])

				nCol = paCommand[2][1][2]
				nVal = paCommand[2][2][2]
				nToCol = paCommand[2][3][2]
	
				updateList(paList, :div, :col, nCol, nVal, nToCol)
				return paList
			ok

		# Case: FastProUpdate(aMatrix, :Divide = [ :Row = 1, :By = 0.5 ]

		but isList(paCommand[2]) and len(paCommand[2]) = 2 and

		    isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		    isString(paCommand[2][1][1]) and paCommand[2][1][1] = :Row and
		    isNumber(paCommand[2][1][2]) and

		    isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		    isString(paCommand[2][2][1]) and paCommand[2][2][1] = :By and
		    isNumber(paCommand[2][2][2])

			updateList(paList, :div, :row, paCommand[2][1][2], paCommand[2][2][2])
			return paList
		else

			stzraise("Syntax error! The command must look like this:" + NL +
				 ":Multiply = [ :Col = 1, :By = 2 ] or :Multiply = [ :Col = 1, :By = 2, :ToCol = 3 ]")
		ok

	on :Raise

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and paCommand[2][1][1] = :Col and
		   isNumber(paCommand[2][1][2]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :ToPower and
		   isNumber(paCommand[2][2][2])

			updateColumn(paList, :pow, paCommand[2][1][2], paCommand[2][2][2])
			return paList

		else
			stzraise("Syntax error! The command must look like this:" + NL +
				 ":Raise = [ :Col = 1, :ToPower = 2 ]")

		ok

	on :Merge

		# Case: FastProUpdate(aMatrix, :Merge = [ :Cols = [ 1, 2 ], :InCol = 1 ])

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and paCommand[2][1][1] = :Cols and
		   isList(paCommand[2][1][2]) and len(paCommand[2][1][2]) = 2 and
		   isNumber(paCommand[2][1][2][1]) and isNumber(paCommand[2][1][2][2]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :InCol and
		   isNumber(paCommand[2][2][2])


		   	nPos = ring_find(paCommand[2][1][2], paCommand[2][2][2])
			if nPos = 0
				stzraise("Can't proceed! The :InCol number must be one of the two numbers in :Cols list.")
			ok

			if nPos = 1
				nOtherPos = 2
			else
				nOtherPos = 1
			ok

			updateList(paList, :merge, :col, paCommand[2][2][2], paCommand[2][1][2][nOtherPos])
			return paList

		# Case: FastProUpdate(aMatrix, :Merge = [ :Cols = [ 1, 2 ], :InCol = 1 ])

		but isList(paCommand[2]) and len(paCommand[2]) = 2 and

		    isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		    isString(paCommand[2][1][1]) and paCommand[2][1][1] = :Rows and
		    isList(paCommand[2][1][2]) and len(paCommand[2][1][2]) = 2 and
		    isNumber(paCommand[2][1][2][1]) and isNumber(paCommand[2][1][2][2]) and

		    isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		    isString(paCommand[2][2][1]) and paCommand[2][2][1] = :InRow and
		    isNumber(paCommand[2][2][2])


		   	nPos = ring_find(paCommand[2][1][2], paCommand[2][2][2])
			if nPos = 0
				stzraise("Can't proceed! The :InRow number must be one of the two numbers in :Rows list.")
			ok

			if nPos = 1
				nOtherPos = 2
			else
				nOtherPos = 1
			ok

			updateList(paList, :merge, :row, paCommand[2][2][2], paCommand[2][1][2][nOtherPos])
			return paList
							
		else
			stzraise("Syntax error! The command must look like this:" + NL +
				 ":Merge = [ :Cols = [ 1, 2 ], :InCol = 2 ] or" + NL +
				 ":Merge = [ :Rows = [ 1, 2 ], :InRow = 2 ]")

		ok

	off



func FastProUpdateMany(paList, paListOfCommands)
	# This function recieves pcCommands in a hashlist like this:
	# 	CUpdateListCol(@aMatrix, [
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


		/*
		on :Merge

			# Case: FastProUpdate(aImage, [
			# 	:Multiply = [ :Col = 1, :By = 0.3, :ToCol = 1 ],
			#       :Merge    = [ :Cols = [ 1, 2 ], :ToCol = 1 ],
        		# 	:Copy     = [ :Row = 1, :ToRow = 3]
			# ])

			aValues = paCommand[2]

			# Check the softanzifed syntax

			if not (isList(aValues) and len(aValues) = 2 and

				isList(aValues[1]) and len(aValues[1]) = 2 and
				isString(aValues[1][1]) and aValues[1][1] = :Cols and

				IsPairOfNumbers(aValues[1][2]) and

				isList(aValues[2]) and len(aValues[2]) = 2 and
				isString(aValues[2][1]) and (aValues[2][1] = :InCol or aValues[2][1] = :ToCol) and
				isNumber(aValues[2][2]) )

				stzraise("Syntax error! The command must look like this:" + NL + 
					 ":Merge = [ :Cols = [ 1, 3], :InCol = 1 ]")
			ok

			# Transform it to a RingFastPro-freindly syntax

			aTempCommand = [ :merge ]

			aVals = aValues[1][2]

			n = ring_find(aVals, aValues[2][2])
			if n > 0
				del(aVals, n)
			ok

			anTempVals = [] + aValues[2][2]

			nLen = len(aVals)
			for j = 1 to nLen
				anTempVals + aVals[j]
			next
			
			aTempCommand + anTempVals
			paCommand = aTempCommand

			# Construct the updateColumn call dynamically
			cCode = "updateColumn(paList"
		    
			# Iterate through commands and add to the call
		
			nLen = len(paCommand)
		
			for i = 1 to nLen
		
				cCmd = paCommand
				aParams = paCommand[2]
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
		off

	next	


func FastProUpdateListList(paList, pcCommand, pcSelection, panValues)


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

func FastProUpdateListList1(paList, pcCommand, pcSelection, p1)
	updateList(paList, pcCommand, pcSelection, p1)
	return paList

	# Examples:

	# updateList(<aList>,:set,:items,<nValue>)
	
func FastProUpdateListList2(paList, pcCommand, pcSelection, p1, p2)
	updateList(paList, pcCommand, pcSelection, p1, p2)
	return paList

	# Examples:

	# updateList(<aList>,:set,:row,<nRow>,<nValue>)
	# updateList(<aList>,:set,:col,<nCol>,<nValue>)

	# updateList(<aList>,:copy,:row,<nRowSrc>,<nRowDest>)
	# updateList(<aList>,:copy,:col,<nColSrc>,<nColDest>)

	# updateList(<aList>,:merge,:row,<nRowDest>,<nRow>)
	# updateList(<aList>,:merge,:col,<nColDest>,<nCol>)

func FastProUpdateListList3(paList, pcCommand, pcSelection, p1, p2, p3)
	updateList(paList, pcCommand, pcSelection, p1, p2)
	return paList

	# Examples:

	# updateList(<aList>,:set,:manyrows,<nRowStart>,<nRowEnd>,<nValue>)
	# updateList(<aList>,:set,:manycols,<nColStart>,<nColEnd>,<nValue>)
	# updateList(<aList>,:mul,:col,<nCol>,<nValue>,<nColDest>)
