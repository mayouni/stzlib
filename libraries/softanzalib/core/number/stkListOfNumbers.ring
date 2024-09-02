
#~~~~~~~~~~~~~#
#  FUNCTIONS  #
#~~~~~~~~~~~~~#

func Max(panNumbers) // #TODO Move to stkListOfNumbers when made
	
	nLen = len(panNumbers)
	if nLen = 1
		return panNumbers[1]
	ok

	nMax = panNumbers[1]

	for i = 2 to nLen
		if panNumbers[i] > nMax
			nMax = panNumbers[i]
		ok
	next

	return nMax

	func @Max(panNumbers)
		return Max(panNumbers)

func Min(panNumbers) // #TODO Move to stkListOfNumbers when made
	if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers))
		StzRaise("Incorrect param type! panNumbers must be a list of numbers.")
	ok

	nLen = len(panNumbers)
	if nLen = 1
		return panNumbers[1]
	ok

	nMin = panNumbers[1]

	for i = 2 to nLen step -1
		if panNumbers[i] < nMin
			nMin = panNumbers[i]
		ok
	next

	return nMin

	func @Min(panNumbers)
		return Min(panNumbers)

#~~~~~~~~~#
#  CLASS  #
#~~~~~~~~~#

class stzCoreListOfNumbers from stkListOfNumbers

class stkListOfNumbers
