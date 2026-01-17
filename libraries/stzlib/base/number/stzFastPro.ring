//@ -1,837 +1,846 @@
# A softanzified wrapper function to RingFastPro extension

load "fastpro.ring"

_aCommandsXT = [
	:set = [ :set, 1, 2 ],
	:add = [ :add, 2, 1 ],
	:subtract = [ :sub, 2, 1 ],
	:multiply = [ :mul, 1, 2 ],
	:divide = [ :div, 1, 2 ],
	:raise = [ :pow, 1, 2 ],
	:modulo = [ :rem, 1, 2 ],
	:copy = [ :copy, 1, 2 ],
	:merge = [ :merge, 1, 2 ]
]

func FastProUpdate(paList, paCommand)
	if isList(paCommand) and IsListOfLists(paCommand)
		return FastProUpdateMany(paList, paCommand)
	ok

	# Case : FastProUpdate(myList, :set = [ :All, :with = 1000 ])
	
	if isList(paList) and IsListOfNumbers(paList) and
	   isList(paCommand) and len(paCommand) = 2 and paCommand[1] = :Set and
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

		# Case: FastProUpdate(aMatrix, :Set = [ :RowsFrom = [ 1, :To = 3 ], :With = 5 ]) or
		#       FastProUpdate(aMatrix, :Set = [ :ColsFrom = [ 1, :To = 3 ], :With = 5 ])

		but isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and paCommand[2][1][1] = :ColsFrom and

		   isList(paCommand[2][1][2]) and len(paCommand[2][1][2]) = 2 and
		   isNumber(paCommand[2][1][2][1]) and

		   isList(paCommand[2][1][2][2]) and len(paCommand[2][1][2][2]) = 2 and
		   isString(paCommand[2][1][2][2][1]) and paCommand[2][1][2][2][1] = :To and
		   isNumber(paCommand[2][1][2][2][2])


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

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and
		   isNumber(paCommand[2][1]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2

			# Case: FastProUpdate(aMatrix, :Add = [ 9, :ToCol = 1 ])

			if isString(paCommand[2][2][1]) and paCommand[2][2][1] = :ToCol and
		   	   isNumber(paCommand[2][2][2])

				updateList(paList, :add, :col, paCommand[2][2][2], paCommand[2][1])
				return paList

			# Case: FastProUpdate(aMatrix, :Add = [ 9, :ToRow = 1 ])

			but isString(paCommand[2][2][1]) and paCommand[2][2][1] = :ToRow and
		   	    isNumber(paCommand[2][2][2])

				updateList(paList, :add, :row, paCommand[2][2][2], paCommand[2][1])
				return paList

			# Case: FastProUpdate(aMatrix, :Add = [ 8, :ToColsFrom = [1, :To = 2] ])

		   	but isString(paCommand[2][2][1]) and paCommand[2][2][1] = :ToColsFrom and
		   	   isList(paCommand[2][2][2]) and len(paCommand[2][2][2]) = 2 and
		   	   isNumber(paCommand[2][2][2][1]) and

		   	   isList(paCommand[2][2][2][2]) and len(paCommand[2][2][2][2]) = 2 and
		   	   isString(paCommand[2][2][2][2][1]) and paCommand[2][2][2][2][1] = :To and
		   	   isNumber(paCommand[2][2][2][2][2])

				updateList(paList, :add, :manycols,
					paCommand[2][2][2][1], paCommand[2][2][2][2][2], paCommand[2][1])
				return paList

			# Case: FastProUpdate(aMatrix, :Add = [ 8, :ToRowsFrom = [1, :To = 2] ])

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
				 ":Add = [ 8, :ToCol = 2 ] or :Add = [ 8, :ToRow = 2 ] or" + NL +				  
				 ":Add = [ 8, :ToColsFrom = [1, :To = 2] ] or :Add = [ 8, :ToRowsFrom = [1, :To = 2] ]")

		ok

	on :Subtract

		# Case: FastProUpdate(aMatrix, :Subtract = [ 8, :FromColsFrom = [1, :To = 2] ])

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and
		   isNumber(paCommand[2][1]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2

			# Case: FastProUpdate(aMatrix, :Subtract = [ 9, :FromCol = 1 ])

			if isString(paCommand[2][2][1]) and paCommand[2][2][1] = :FromCol and
		   	   isNumber(paCommand[2][2][2])

				updateList(paList, :sub, :col, paCommand[2][2][2], paCommand[2][1])
				return paList

			# Case: FastProUpdate(aMatrix, :Add = [ 9, :FromRow = 1 ])

			but isString(paCommand[2][2][1]) and paCommand[2][2][1] = :FromRow and
		   	    isNumber(paCommand[2][2][2])

				updateList(paList, :sub, :row, paCommand[2][2][2], paCommand[2][1])
				return paList

			# Case: FastProUpdate(aMatrix, :Subtract = [ 8, :FromColsFrom = [ 1, :To = 3])

		   	but isString(paCommand[2][2][1]) and paCommand[2][2][1] = :FromColsFrom and
		   	   isList(paCommand[2][2][2]) and len(paCommand[2][2][2]) = 2 and
		   	   isNumber(paCommand[2][2][2][1]) and

		   	   isList(paCommand[2][2][2][2]) and len(paCommand[2][2][2][2]) = 2 and
		   	   isString(paCommand[2][2][2][2][1]) and paCommand[2][2][2][2][1] = :To and
		   	   isNumber(paCommand[2][2][2][2][2])

				updateList(paList, :sub, :manycols,
					paCommand[2][2][2][1], paCommand[2][2][2][2][2], paCommand[2][1])
				return paList

			# Case: FastProUpdate(aMatrix, :Subtract = [ 8, :FromRowsFrom = [ 1, :To = 3])

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

		# Case: FastProUpdate(aMatrix, :Multiply = [ :ColsFrom = [ 1, :To = 3], :By = 3 ])

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and paCommand[2][1][1] = :ColsFrom and

		   isList(paCommand[2][1][2]) and len(paCommand[2][1][2]) = 2 and
		   isNumber(paCommand[2][1][2][1]) and

		   isList(paCommand[2][1][2][2]) and len(paCommand[2][1][2][2]) = 2 and
		   isString(paCommand[2][1][2][2][1]) and paCommand[2][1][2][2][1] = :To and
		   isNumber(paCommand[2][1][2][2][2]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :By and
		   isNumber(paCommand[2][2][2])

			updateList(paList, :mul, :manycols,
				paCommand[2][1][2][1],
				paCommand[2][1][2][2][2],
				paCommand[2][2][2])

			return paList

		but isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and paCommand[2][1][1] = :RowsFrom and

		   isList(paCommand[2][1][2]) and len(paCommand[2][1][2]) = 2 and
		   isNumber(paCommand[2][1][2][1]) and

		   isList(paCommand[2][1][2][2]) and len(paCommand[2][1][2][2]) = 2 and
		   isString(paCommand[2][1][2][2][1]) and paCommand[2][1][2][2][1] = :To and
		   isNumber(paCommand[2][1][2][2][2]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :By and
		   isNumber(paCommand[2][2][2])

			updateList(paList, :mul, :manyrows,
				paCommand[2][1][2][1],
				paCommand[2][1][2][2][2],
				paCommand[2][2][2])

			return paList

		ok

		#---

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

		# Case: FastProUpdate(aMatrix, :Divide = [ :ColsFrom = [ 1, :To = 3], :By = 3 ])

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and paCommand[2][1][1] = :ColsFrom and

		   isList(paCommand[2][1][2]) and len(paCommand[2][1][2]) = 2 and
		   isNumber(paCommand[2][1][2][1]) and

		   isList(paCommand[2][1][2][2]) and len(paCommand[2][1][2][2]) = 2 and
		   isString(paCommand[2][1][2][2][1]) and paCommand[2][1][2][2][1] = :To and
		   isNumber(paCommand[2][1][2][2][2]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :By and
		   isNumber(paCommand[2][2][2])

			updateList(paList, :div, :manycols,
				paCommand[2][1][2][1],
				paCommand[2][1][2][2][2],
				paCommand[2][2][2])

			return paList

		but isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and paCommand[2][1][1] = :RowsFrom and

		   isList(paCommand[2][1][2]) and len(paCommand[2][1][2]) = 2 and
		   isNumber(paCommand[2][1][2][1]) and

		   isList(paCommand[2][1][2][2]) and len(paCommand[2][1][2][2]) = 2 and
		   isString(paCommand[2][1][2][2][1]) and paCommand[2][1][2][2][1] = :To and
		   isNumber(paCommand[2][1][2][2][2]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :By and
		   isNumber(paCommand[2][2][2])

			updateList(paList, :div, :manyrows,
				paCommand[2][1][2][1],
				paCommand[2][1][2][2][2],
				paCommand[2][2][2])

			return paList

		ok

		#---

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

		# Case: FastProUpdate(aMatrix, :Raise = [ :ColsFrom = [ 1, :To = 3], :ToPower = 3 ])

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and paCommand[2][1][1] = :ColsFrom and

		   isList(paCommand[2][1][2]) and len(paCommand[2][1][2]) = 2 and
		   isNumber(paCommand[2][1][2][1]) and

		   isList(paCommand[2][1][2][2]) and len(paCommand[2][1][2][2]) = 2 and
		   isString(paCommand[2][1][2][2][1]) and paCommand[2][1][2][2][1] = :To and
		   isNumber(paCommand[2][1][2][2][2]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :ToPower and
		   isNumber(paCommand[2][2][2])

			updateList(paList, :pow, :manycols,
				paCommand[2][1][2][1],
				paCommand[2][1][2][2][2],
				paCommand[2][2][2])

			return paList

		but isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and paCommand[2][1][1] = :RowsFrom and

		   isList(paCommand[2][1][2]) and len(paCommand[2][1][2]) = 2 and
		   isNumber(paCommand[2][1][2][1]) and

		   isList(paCommand[2][1][2][2]) and len(paCommand[2][1][2][2]) = 2 and
		   isString(paCommand[2][1][2][2][1]) and paCommand[2][1][2][2][1] = :To and
		   isNumber(paCommand[2][1][2][2][2]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :ToPower and
		   isNumber(paCommand[2][2][2])

			updateList(paList, :pow, :manyrows,
				paCommand[2][1][2][1],
				paCommand[2][1][2][2][2],
				paCommand[2][2][2])

			return paList

		ok

		#---

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

	on :Modulo

		# Case: FastProUpdate(aMatrix, :Modulo = [ :ColsFrom = [ 1, :To = 3], :By = 3 ])

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and paCommand[2][1][1] = :ColsFrom and

		   isList(paCommand[2][1][2]) and len(paCommand[2][1][2]) = 2 and
		   isNumber(paCommand[2][1][2][1]) and

		   isList(paCommand[2][1][2][2]) and len(paCommand[2][1][2][2]) = 2 and
		   isString(paCommand[2][1][2][2][1]) and paCommand[2][1][2][2][1] = :To and
		   isNumber(paCommand[2][1][2][2][2]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :By and
		   isNumber(paCommand[2][2][2])

			updateList(paList, :rem, :manycols,
				paCommand[2][1][2][1],
				paCommand[2][1][2][2][2],
				paCommand[2][2][2])

			return paList

		but isList(paCommand[2]) and len(paCommand[2]) = 2 and

		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and paCommand[2][1][1] = :RowsFrom and

		   isList(paCommand[2][1][2]) and len(paCommand[2][1][2]) = 2 and
		   isNumber(paCommand[2][1][2][1]) and

		   isList(paCommand[2][1][2][2]) and len(paCommand[2][1][2][2]) = 2 and
		   isString(paCommand[2][1][2][2][1]) and paCommand[2][1][2][2][1] = :To and
		   isNumber(paCommand[2][1][2][2][2]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :By and
		   isNumber(paCommand[2][2][2])

			updateList(paList, :rem, :manyrows,
				paCommand[2][1][2][1],
				paCommand[2][1][2][2][2],
				paCommand[2][2][2])

			return paList

		ok

		#---

		# Case: FastProUpdate(aMatrix, :Modulo = [ :Col = 3, :By = 2 ])

		if isList(paCommand[2]) and len(paCommand[2]) = 2 and
		   isList(paCommand[2][1]) and len(paCommand[2][1]) = 2 and
		   isString(paCommand[2][1][1]) and

		   paCommand[2][1][1] = :Col and
		   isNumber(paCommand[2][1][2]) and

		   isList(paCommand[2][2]) and len(paCommand[2][2]) = 2 and
		   isString(paCommand[2][2][1]) and paCommand[2][2][1] = :By and
		   isNumber(paCommand[2][2][2])

			UpdateColumn(paList, :rem, paCommand[2][1][2], paCommand[2][2][2])
			return paList

		else

			stzraise("Syntax error! The command must look like this:" + NL +
				 ":Modulo = [ :Col = 1, :By = 2 ]")

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

func FastProUpdateMany(paList, paCommandLists)

	cCode = "updateColumn( paList, " + NL + TAB

	nLen = len(paCommandLists)

	for i = 1 to nLen

		cCommandList = @Simplify(@@(paCommandLists[i]))

		if ring_substr1(cCommandList, "set") > 0
			cCommand = "set"

		but ring_substr1(cCommandList, "add") > 0
			cCommand = "add"

		but ring_substr1(cCommandList, "subtract") > 0
			cCommand = "subtract"

		but ring_substr1(cCommandList, "multiply") > 0
			cCommand = "multiply"

		but ring_substr1(cCommandList, "divide") > 0
			cCommand = "divide"

		but ring_substr1(cCommandList, "raise") > 0
			cCommand = "raise"

		but ring_substr1(cCommandList, "modulo") > 0
			cCommand = "modulo"

		but ring_substr1(cCommandList, "copy") > 0
			cCommand = "copy"

		but ring_substr1(cCommandList, "merge") > 0
			cCommand = "merge"

		else
			stzraise("Insupported command or syntax error!")
		ok

		anNumbers = NumbersIn(cCommandList)

		cCode += ":" + _aCommandsXT[cCommand][1] + ", " + anNumbers[_aCommandsXT[cCommand][2]] + ", " +
			 anNumbers[_aCommandsXT[cCommand][3]]

		if i < nLen
			cCode += "," + NL + TAB
		ok

	next

	cCode += " )"
//? ccode
	eval(cCode)
	return paList
