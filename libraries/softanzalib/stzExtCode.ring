# Set of functions and classes made to make it easy porting code
# from external languages in Ring

# The idea is to find a solution to a problem on the internet in other langauge,
# paste the code in Ring, and do little changes to get a computable Ring code

# See examples in stzExtLang.ring file

# TODO: Organize this file by language

  ///////////////////
 ///  VARIABLES  ///
///////////////////


_aTempVars = []
_aVars = []	# the list of all temp vars and their values

_bVarReset = FALSE
_var = []	# Current temp var and its value
_oldVar = []	# A copy of the temp var before it is changed

console = new console
None = NULL

_b = false 	# Used for ternary operators in C
_bv = null	# Idem

say = new say	# Raku / Perl language

  ///////////////////
 ///  FUNCTIONS  ///
///////////////////

func TempVars()
	aResult = QR( _aVars, :stzHashList).Keys()
	return aResult

	func TempVarsNames()
		return TempVars()

func TempVals()
	aResult = QR( _aVars, :stzHashList).Values()
	return aResult

func TempVarsVals()
	return _aVars

	func TempVarsXT()
		return TempVarsVals()

func TempVar()
	if len(_var) = 0
		return []
	else
		return _var[1]
	ok

	def TempVarName()
		return TempVar()

func TempVal()
	if len(_var) = 0
		return NULL
	else
		return _var[2]
	ok

func TempVarVal()
	return _var

	func TempVarXT()
		return TempVarVal()

func V(p)
	if isList(p) and Q(p).IsPair()
		aTemp = []
		aTemp + p
		SetV(aTemp)

	but isList(p) and Q(p).IsHashList()
		SetV(p)

	but isList(p) and Q(p).IsListOfStrings()
		return ReadManyV(p)

	else

		return ReadV(p)
	ok

	func VrVl(p)
		return V(p)

	func VarVal(p)
		return V(p)

func SetV(paVarNamesAndTheirValues)
	if isList(paVarNamesAndTheirValues) and
	   len(paVarNamesAndTheirValues) = 2 and
	   isString(paVarNamesAndTheirValues[1])

		aTemp = []
		aTemp + paVarNamesAndTheirValues
		paVarNamesAndTheirValues = aTemp
	ok

	if NOT ( isList(paVarNamesAndTheirValues) and Q(paVarNamesAndTheirValues).IsHashList() )
		StzRaise("Incorrect param type! paVarNamesAndTheirValues must be a hashlist.")
	ok

	# Memorizing the current var

	if len(_aVars) = 0
		_oldVar = []
	else
		_oldVar = _aVars[ len(_aVars) ]
	ok

	# Setting the new var

	nLen = len(paVarNamesAndTheirValues)
	oHash = new stzHashList(_aVars)

	for i = 1 to nLen
		n = oHash.FindKey(paVarNamesAndTheirValues[i][1])
		if n = 0
			_aVars + paVarNamesAndTheirValues[i]
		else
			_aVars[n] = paVarNamesAndTheirValues[i]
		ok
	next

	# The new var is the temp var

	_var = _aVars[len(_aVars)]


func ReadV(p)
	oHash = new stzHashList(_aVars)
	n = oHash.FindKey(p)
	if n = 0
		StzRaise("Undefined named variable!")
	else
		return _aVars[n][2]
	ok

func ReadManyV(paVars)
	nLen = len(paVars)

	aResult = []
	for i = 1 to nLen
		aResult + ReadV(paVars[i])
	next

	return aResult

func DataVars()
	nLen = len(_aVars)
	aResult = []
	for i = 1 to nLen
		aResult + _aVars[i]
	next
	return aResult

func DataVarsXT()
	return _aVars


func Vr(pacVars)

	if isString(pacVars)
		aTemp = []
		aTemp + pacVars
		pacVars = aTemp
	ok

	if NOT ( isList(pacVars) and Q(pacVars).IsListOfStrings() )
		StzRaise("Incorrect param type! pcVars must be a list of strings.")
	ok

	_aTempVars = []
	nLen = len(pacVars)

	for i = 1 to nLen

		_aTempVars + [ pacVars[i], NULL ]

		oHash = StzHashListQ(_aVars)
		n = oHash.FindKey(pacVars[i])
		if n = 0
			_aVars + [ pacVars[i], NULL ]

		else
			_aVars[n][2] = []
		ok
	next

func oldVar()
	return _oldVar

func oldVarname()
	if len(oldVar()) = 0
		return []
	else
		oldvar()[1]
	ok

func oldVal()

	if len(oldvar()) = 0
		return ""
	else
		return oldvar()[2]
	ok

func Vl(paVals)

	# Checking the paVals param

	if len(_aTempVars) = 0 or (isList(paVals) and len(paVals) = 0)
		return
	ok

	# In case one value is provided (not a list), make it a list

	if NOT isList(paVals)
		aTemp = []
		aTemp + paVals
		paVals = aTemp
	ok

	# Taking a copy of the current temp var

	_oldVar = _Var

	# Doing the job

	nLen = Min([ len(_aTempVars), len(paVals) ])

	oHash = new stzHashList(_aVars)

	for i = 1 to nLen

		_aTempVars[i][2] = paVals[i]
		n = oHash.FindKey(_aTempVars[i][1])

		if n > 0
			_aVars[n][2] = paVals[i]
			if ObjectIsStzObject(paVals[i])

				paVals[i].SetObjectVarNameTo(_aVars[n][1])
			ok
		else
			_aVars + [ _aTempVars[i][1], paVals[i] ]
			if ObjectIsStzObject(paVals[i])
				paVals[i].SetObjectVarNameTo(_aTempVars[i][1])
			ok
		ok
	next

	# Memorizing the last variable/value processed

	_var = [ _aTempVars[nLen][1], paVals[nLen] ]

	if oldval() = ""
		_oldVar = _var
	ok

# Used for ternary operator in Python

func _if(pExpressionOrBoolean)
	_bVarReset = FALSE
	bTemp = TRUE

	if isString(pExpressionOrBoolean)
		cCode = 'bTemp = (' + pExpressionOrBoolean + ')'
		eval(cCode)

	but IsBoolean(pExpressionOrBoolean)
		bTemp = pExpressionOrBoolean
	ok

	if bTemp = FALSE
		_bVarReset = TRUE
	ok

func _else(value)

	aValues = []

	if NOT isList(value)
		aTemp = []
		aTemp + value
		value = aTemp
	ok

	aValues = value

	nLen = len(aValues)
	acTempVarsNames = TempVarsNames()

	if _bVarReset = TRUE
		for i = 1 to nLen
			setV([ acTempVarsNames[i], aValues[i] ])
		next
	ok

# Used for ternary operator in C

func b(e)
	_b = e

func bv(val1, val2)
	nLen = len(_aVars)
	if _b = true
		_aVars[nLen][2] = val1
	else
		_aVars[nLen][2] = val2
	ok	

func bt(val)
	nLen = len(_aVars)
	if _b = true
		_aVars[nLen][2] = val
	ok

func bf(val)
	nLen = len(_aVars)
	if _b = false
		_aVars[nLen][2] = val
	ok

func range0(p)
	# Python...	: range(3) 		--> [0, 1, 2]
	# Python..	: range(-3, 4, 2)	--> [-3, -1, 1, 3 ]
	# JS/PHP/...	: range(1, 3) 		--> [1, 2, 3]

	aResult = []
	if isNumber(p)
		# range(n) : 0 <= x < n	--> n not included!

		# Example 1 : range(3)  #--> [ 0, 1, 2 ]
		# Example 2 : range(-3) #--> []

		if p > 0	
			aResult = 0 : (p - 1)
		ok

	but isList(p)
		if Q(p).IsListOfNumbers()

			# range(n1, n2): n1 <= x < n2
			#--> n1 included, but n2 not included!
			if len(p) = 2
				# Example 1: range(1, 5) #--> [1, 2, 3, 4 ]
				# Example 2 : range(5, 1) #--> []

				if p[1] < p[2]
					aResult = p[1] : (p[2]-1)
				ok

			# range(n1, n2, step): n1 <= x < n2 (increasing by step)
			but len(p) = 3

				# Example: range(-3, 3, 2) #--> [ -3, -1, 1 ]
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

			/* EXAMPLES
	
			? range0(':5:-1')
			#--> [ 4, 3, 2, 1, 0 ]
	
			? range0('2:8:2')
			#--> [ 3, 5, 7 ]
	
			*/
	
			acNumbers = oStr.SplitAt(":")
			nLen = len(acNumbers)
	
			if acNumbers[2] = NULL
				StzRaise("Incorrect syntax! The second parameter must not be empty.")
			ok
	
			n1 = 0
			if acNumbers[1] != NULL
				n1 = 0+ acNumbers[1] + 1
			ok
	
			n2 = 0+ acNumbers[2] - 1
	
			nStep = 1
			if nLen = 3
				nStep = 0+ acNumbers[3]
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

	def range0Q(p)
		return new stzList(range(p))

	def range(p)
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
				#                      step
				# 			 v
				# Example: range1(-3, 4, 2) #--> [ -3, -1, 1, 3 ]
				aResult = []

				for i = p[1] to p[2] step p[3]
					aResult + i
				next
	
			but len(p) = 2

				# Example: range(1, 5) #--> [1, 2, 3, 4 ]
				aResult = p[1] : p[2]
			
			ok
		ok

	but isString(p)

		oStr = new stzString(p)

		if oStr.NumberOfOccurrenceQ(":").IsEither(1, 2) and
		oStr.Copy().RemoveManyQ([":", "-"]).IsNumberInString()

			/* EXAMPLES
	
			? range1(':5:-1')
			#--> [ 5, 4, 3, 2, 1 ]
	
			? range1('2:8:2')
			#--> [ 2, 4, 6, 8 ]
	
			*/
	
			acNumbers = oStr.SplitAt(":")
			nLen = len(acNumbers)
	
			if acNumbers[2] = NULL
				StzRaise("Incorrect syntax! The second parameter must not be empty.")
			ok
	
			n1 = 1
			if acNumbers[1] != NULL
				n1 = 0+ acNumbers[1]
			ok
	
			n2 = 0+ acNumbers[2]
	
			nStep = 1
			if nLen = 3
				nStep = 0+ acNumbers[3]
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

func $$(cVarName)
	if isString(cVarName)
		return v(v(cVarName))
	else
		StzRaise("Syntax error!")
	ok

	func vv(cVarName)
		return v(v(cVarName))

func $(str) // C#
	if isList(str) and ( Q(str).IsPair() or Q(str).IsHashList() )
		VrVl(str)

	but isString(str) and Q(str).ContainsSubStringsBoundedBy([ "{", "}" ])
		return Interpoltate(str) // Ring (SoftanzaLib)

		# NOTE the method we used here is misspelled. Normally we
		# should write it correctly as "Interpolate(str)". But I left
		# as is to show how Softanza can be permissive to spelling
		# errors when you are under time pressure in writing code ;)
	
	else
		return v(str)
	ok

func f(str) // Python
	return Interpoltate(str)

func exec(cCode) // Python
	eval(cCode)

  /////////////////
 ///  CLASSES  ///
/////////////////

class say # Raku / Perl
	vr(:say)

	def braceend()
		? v(:say)

class IntObject // C#
	MinValue
	MaxValue
	
	def getMinValue()
		return RingMinIntegerXT()

	def getMaxValue()
		return RingMaxIntegerXT()

class console // JS, C#, Java
	def log(str)
		? str

	def WriteLine(str)
		? str
	
