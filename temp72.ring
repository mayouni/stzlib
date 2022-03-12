load "stzlib.ring"

// Finding all occurrences of a substring in a string

o1 = new stzString("me just amc you amc me amc me")
o1 = new stzString("we are tunisians from tunisia capital is tunis")

? FindAll("tunis")

func FindAll(cSubStr)

	// Splitting the string over the substring
	aSplitted = o1.split(cSubStr)
	
	// Computing the cumulated positions of the splitted substrings
	
	aLenSplitted = []
	for i = 1 to len(aSplitted) - 1
		aLenSplitted + len(aSplitted[i])
	next
	
	aLenSplittedCumul = []
	aLenSplittedCumul + (aLenSplitted[1] + 1)
	
	for i = 2 to len(aLenSplitted)
		nCumul = aLenSplitted[i] + aLenSplittedCumul[i-1] + len(cSubStr)
		aLenSplittedCumul + nCumul
	next
	
	// Returning the result
	return aLenSplittedCumul
	
