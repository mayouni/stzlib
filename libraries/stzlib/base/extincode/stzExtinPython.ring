# Functions for porting Python code to Ring

func range0(p)
	# Python...	: range(3) 		--> [0, 1, 2]
	# Python..	: range(-3, 4, 2)	--> [-3, -1, 1, 3 ]
	aResult = []
	if isNumber(p)
		# range(n) : 0 <= x < n	--> n not included!
		if p > 0	
			aResult = 0 : (p - 1)
		ok
	but isList(p)
		if Q(p).IsListOfNumbers()
			# range(n1, n2): n1 <= x < n2
			#--> n1 included, but n2 not included!
			if len(p) = 2
				if p[1] < p[2]
					aResult = p[1] : (p[2]-1)
				ok
			# range(n1, n2, step): n1 <= x < n2 (increasing by step)
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
	func range0Q(p)
		return new stzList(@range(p))
	func range(p)
		return range0(p)
		func @range(p)
			return range0(p)
		return rangeQ(p)
			return range0Q(p)

func range1(p)
	aResult = []
	if isNumber(p)
		# Example: range1(3) #--> [ 1, 2, 3 ]
		aResult = 1 : p
	but isList(p)
		if Q(p).IsListOfNumbers()
			if len(p) = 3
				aResult = []
				for i = p[1] to p[2] step p[3]
					aResult + i
				next
			but len(p) = 2
				aResult = p[1] : p[2]
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
			n1 = 1
			if acNumbers[1] != ""
				n1 = 0 + acNumbers[1]
			ok
			n2 = 0 + acNumbers[2]
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
	def range1Q(p)
		return new stzList(range1(p))

func print(str)
	? str

	func echo(str)
		print(str)

	func WriteLine(str)
		print(str)

	func println(str)
		print(str)

	func printf(str)
		print(str)

func f(str)
	return Interpoltate(str)

func exec(cCode)
	eval(cCode)

func _if(pExpressionOrBoolean)
	if len(_aTempVars) = 0
	    StzRaise("No temp vars defined! Call vr() first.")
	ok
	_bVarReset = 0
	bTemp = 1
	if isString(pExpressionOrBoolean)
		cCode = 'bTemp = (' + pExpressionOrBoolean + ')'
		eval(cCode)
	but ( isNumber(pExpressionOrBoolean) and (pExpressionOrBoolean = 0 or pExpressionOrBoolean = 1) )
		bTemp = pExpressionOrBoolean
	ok
	if bTemp = 0
		_bVarReset = 1
	ok
	func if_(pExpressionOrBoolean)
		return _if(pExpressionOrBoolean)

func _else(value)
    aValues = []
    if NOT isList(value)
        aTemp = []
        aTemp + value
        value = aTemp
    ok
    aValues = value
    if _bVarReset = 1 and len(_aTempVars) > 0
        nTempVars = len(_aTempVars)
        nValues = len(aValues)
        nLen = Min([ nTempVars, nValues ])
        oHash = new stzHashList(_aVars)
        for i = 1 to nLen
            cVarName = _aTempVars[i][1]
            _aTempVars[i][2] = aValues[i]
            n = oHash.FindKey(cVarName)
            if n > 0
                _aVars[n][2] = aValues[i]
            else
                _aVars + [ cVarName, aValues[i] ]
            ok
            if ObjectIsStzObject(aValues[i])
                aValues[i].SetObjectVarNameTo(cVarName)
            ok
        next
        if nLen > 0
            _var = [ _aTempVars[nLen][1], aValues[nLen] ]
        ok
        if oldval() = ""
            _oldVar = _var
        ok
    ok
    func else_(value)
        return _else(value)
