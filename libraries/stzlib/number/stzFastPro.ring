# A set of softanzified wrapper function ti RingFastPro extension

load "fastpro.ring"

#-- Wrappers for FastPro functions

# pcCommand could be :set, :add, :sub, :mul, :div, :rem, :pow, :serial, :merge and :copy
# pccSelection could be :col, :row, :manycols, :manyrows and :items

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


func FastProUpdateCol(paList, paCommands)

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
	
	# Construct the updateColumn call dynamically
	cCode = "updateColumn(paList"
    
	# Iterate through commands and add to the call

	nLen = len(paCommands)

	for i = 1 to nLen

		cCom = aCommands[i][1]
		aParams = aCommands[i][2]
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
