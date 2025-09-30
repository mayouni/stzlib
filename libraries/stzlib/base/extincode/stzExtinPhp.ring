# Functions for porting PHP code to Ring

func echo(str)
	? str

func range0(p)
	# PHP...	: range(1, 3) 		--> [1, 2, 3]
	aResult = []
	if isNumber(p)
		if p > 0	
			aResult = 0 : (p - 1)
		ok
	but isList(p)
		if Q(p).IsListOfNumbers()
			if len(p) = 2
				if p[1] < p[2]
					aResult = p[1] : (p[2]-1)
				ok
			but len(p) = 3
				aResult = []
				if p[1] < p[2] and p[3] > 0
					for i = p[1] to p[2]-1 step p[3]
						aResult + i
					next
				but p[1] > p[2] and p[3] < 0
					for i = p[1] to p[2]+1 step p[3]
						aResult + i
					next
				ok
			ok
		ok
	but isString(p)
		oStr = new stzString(p)
		if oStr.NumberOfOccurrenceQ(":").IsEither(1, 2) and
		   oStr.Copy().RemoveManyQ([":", "-"]).IsNumberInString()
			acNumbers = oStr.SplitAt(":")
			nLen = len(acNumbers)
			if acNumbers[2] = ""
				StzRaise("Incorrect syntax! The second parameter must not be empty.")
			ok
			n1 = 0
			if acNumbers[1] != ""
				n1 = 0 + acNumbers[1] + 1
			ok
			n2 = 0 + acNumbers[2] - 1
			nStep = 1
			if nLen = 3
				nStep = 0 + acNumbers[3]
			ok
			aResult = []
			if nStep < 0
				nTemp = n1
				n1 = n2
				n2 = nTemp
			ok
			for i = n1 to n2 step nStep
				aResult + i
			next
		ok
	else
		StzRaise("Unsupported syntax!")
	ok
	return aResult
