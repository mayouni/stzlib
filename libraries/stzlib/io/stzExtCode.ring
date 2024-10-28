# Set of functions and classes made to make it easy porting code
# from external languages in Ring

# The idea is to find a solution to a problem on the internet in other language,
# paste the code in Ring, and do little changes to get a computable Ring code

# See examples in stzExtLang.ring file

#TODO: Organize this file by language

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

int = new IntObject

# SQL statements

_aINSERT_INTO_VALUES = []

_aSELECT_FROM_WHERE = []

SMALLINT = :SMALLINT
TABLE = :TABLE

_oInitialTable = new stzTable([])
_oIntermediateTable = new stzTable([])

  ///////////////////
 ///  FUNCTIONS  ///
///////////////////

func iif(cCondition, pTrue, pFalse)
	cCode = 'bOk = (' + cCondition + ')'
	eval(cCode)
	if bOk
		return pTrue
	else
		return pFalse
	ok

func TempVars()

	aResult = []
	nLen = len(_aVars)
	for i = 1 to nLen
		aResult + _aVars[i][1]
	next

	return aResult

	func TempVarsNames()
		return TempVars()

	func TempVarNames()
		return TempVars()

	func @TempVars()
		return TempVars()

	func @TempVarsNames()
		return TempVars()

	func @TempVarNames()
		return TempVars()

func TempVals()
	aResult = []
	nLen = len(_aVars)
	for i = 1 to nLen
		aResult + _aVars[i][2]
	next

	return aResult

	func @TempVals()
		return TempVals()

func TempVarsVals()
	return _aVars

	func TempVarsXT()
		return TempVarsVals()

	func @TempVarsVals()
		return TempVarsVals()

func TempVar()
	if len(_var) = 0
		return []
	else
		return _var[1]
	ok

	def TempVarName()
		return TempVar()

	func @TempVar()
		return TempVar()

	def @TempVarName()
		return TempVar()

func TempVal()
	if len(_var) = 0
		return NULL
	else
		return _var[2]
	ok

	func @TempVal()
		return TempVal()

func TempVarVal()
	return _var

	func TempVarXT()
		return TempVarVal()

	func @TempVarVal()
		return TempVarVal()

	func @TempVarXT()
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

	func @V(p)
		return V(p)

func VrVl(p)
	aResult = Association([ p, v(p) ])
	return aResult

	func VarVal(p)
		return VrVl(p)

	func @VrVl(p)
		return VrVl(p)

	func @VarVal(p)
		return VrVl(p)

func vxt(cVarName)
	if NOT isString(cVarName)
		StzString("Incorrect param type! cVarName must be a string.")
	ok

	cVarName = ring_lower(cVarName)

	if NOT ring_find(TempVarNames(), cVarName)
		StzRaise("Variable name does not exist!")
	ok

	aResult = [ cVarName, v(cVarName) ]
	return aResult
	
	func @vxt(cVarName)
		return vxt(cVarName)

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

	func @SetV(paVarNamesAndTheirValues)
		SetV(paVarNamesAndTheirValues)

func ReadV(p)
	oHash = new stzHashList(_aVars)
	n = oHash.FindKey(p)
	if n = 0
		StzRaise("Undefined named variable!")
	else
		return _aVars[n][2]
	ok

	func @ReadV(p)
		return ReadV(p)

func ReadManyV(paVars)
	nLen = len(paVars)

	aResult = []
	for i = 1 to nLen
		aResult + ReadV(paVars[i])
	next

	return aResult

	func @ReadManyV(paVars)
		return ReadManyV(paVars)

func DataVars()
	nLen = len(_aVars)
	aResult = []
	for i = 1 to nLen
		aResult + _aVars[i]
	next
	return aResult

	func @DataVars()
		return DataVars()

func DataVarsXT()
	return _aVars

	func @DataVarsXT()
		return DataVarsXT()

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

	func @Vr(pacVars)
		return Vr(pacVars)

func OldVar()
	return _oldVar

	func @OldVar()
		return OldVar()

func OldVarname()
	if len(oldVar()) = 0
		return []
	else
		oldvar()[1]
	ok

	func @OldVarname()
		return OldVarname()

func OldVal()

	if len(oldvar()) = 0
		return ""
	else
		return oldvar()[2]
	ok

	func @OldVal()
		return OldVal()

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

	func @Vl(paVals)
		Vl(paVals)

func Length(p)
	return len(p)

	func @Length(p)
		return len(p)

# Used for ternary operator in Python

func _if(pExpressionOrBoolean)
	_bVarReset = FALSE
	bTemp = TRUE

	if isString(pExpressionOrBoolean)
		cCode = 'bTemp = (' + pExpressionOrBoolean + ')'
		eval(cCode)

	but ( isNumber(pExpressionOrBoolean) and (pExpressionOrBoolean = 0 or pExpressionOrBoolean = 1) )
		bTemp = pExpressionOrBoolean
	ok

	if bTemp = FALSE
		_bVarReset = TRUE
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

	nLen = len(aValues)
	acTempVarsNames = TempVarsNames()

	if _bVarReset = TRUE
		for i = 1 to nLen
			setV([ acTempVarsNames[i], aValues[i] ])
		next
	ok

	func else_(value)
		return _else(value)

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

		#NOTE the method we used here is misspelled. Normally we
		# should write it correctly as "Interpolate(str)". But I left
		# as is to show how Softanza can be permissive to spelling
		#ERRors when you are under time pressure in writing code ;)
	
	else
		return v(str)
	ok

func f(str) // Python
	return Interpoltate(str)

func exec(cCode) // Python
	eval(cCode)

# Used for SQL

func VARCHAR(n)
	# Does nothing now --> TODO (future)

	#< @FunctionAlternativeForms

	func _VARCHAR(n)
		return VARCHAR(n)

	func VARCHAR_(n)
		return VARCHAR(n)

	func _VARCHAR_(n)
		return VARCHAR(n)

	func @VARCHAR(n)
		return VARCHAR(n)

	func VARCHAR@(n)
		return VARCHAR(n)

	func @VARCHAR@(n)
		return VARCHAR(n)

	#>

func CREATE_TABLE(pcName)

	oTable = new stzTable([])
	oTable.SetName(pcName)

	Vr(pcName) '=' Vl(oTable)

	return v(pcName)

	#< @FunctionAlternativeForms

	func _CREATE_TABLE(pcName)
		return CREATE_TABLE(pcName)

	func CREATE_TABLE_(pcName)
		return CREATE_TABLE(pcName)

	func _CREATE_TABLE_(pcName)
		return CREATE_TABLE(pcName)

	func @CREATE_TABLE(pcName)
		return CREATE_TABLE(pcName)

	func CREATE_TABLE@(pcName)
		return INSERT_INTO(pcName)

	func @CREATE_TABLE@(pcName)
		return CREATE_TABLE(pcName)

	#>

func INSERT_INTO(pcTableName, pacColNames)

	/* EXAMPLE

	INSERT_INTO( :persons, [ :id, :name, :score ] )

	VALUES([
		[ 1, 'Bob', 120 ],
		[ 2, 'Dan',  89 ],
		[ 3, 'Tim',  56 ]
	]);

	*/

	if CheckParams()
		if NOT isString(pcTableName)
			StzRaise("Incorrect param type! pcTableName must be a string.")
		ok

		if NOT ring_find(TempVars(), pcTableName) > 0
			StzRaise("Undefined named variable!")
		ok

		if NOT ( isList(pacColNames) and Q(pacColNames).IsListOfStrings() )
			StzRaise("Incorrect param type! pacColNames must be a list of string.")
		ok

	ok

	_aINSERT_INTO_VALUES = [ pcTableName, pacColNames ]

	#< @FunctionAlternativeForms

	func _INSERT_INTO(pcTableName, pacColNames)
		return INSERT_INTO(pcTableName, pacColNames)

	func INSERT_INTO_(pcTableName, pacColNames)
		return INSERT_INTO(pcTableName, pacColNames)

	func _INSERT_INTO_(pcTableName, pacColNames)
		return INSERT_INTO(pcTableName, pacColNames)

	func @INSERT_INTO(pcTableName, pacColNames)
		return INSERT_INTO(pcTableName, pacColNames)

	func INSERT_INTO@(pcTableName, pacColNames)
		return INSERT_INTO(pcTableName, pacColNames)

	func @INSERT_INTO@(pcTableName, pacColNames)
		return INSERT_INTO(pcTableName, pacColNames)

	#>

func VALUES(paValues)
	if CheckParams()
		if NOT ( isList(paValues) and Q(paValues).IsListOfLists() )
			StzRaise("Incorrect param type! paValues must be a list of lists.")
		ok
	ok

	_aINSERT_INTO_VALUES + paValues

	cTableName = _aINSERT_INTO_VALUES[1]
	oStzTable  = v(_aINSERT_INTO_VALUES[1])

	nLen = len(paValues)

	if nLen > 0

		# Case 1 : stzTable contains no rows (other than the null
		# 	   row 1 added by default when the object is created

		if oStzTable.NumberOfRows() = 1 AND oStzTable.IsEmpty()

			oStzTable.ReplaceRow(1, paValues[1])
	
			if nLen > 1
				ring_remove(paValues, 1)
				oStzTable.AddRows(paValues)
			ok

		else
		# Case 2 : stzTable already contains data
			oStzTable.AddRows(paValues)

		ok
	ok

	_aVars[cTableName] = oStzTable

	#< @FunctionAlternativeForms

	func _VALUES(paValues)
		return VALUES(paValues)

	func VALUES_(paValues)
		return VALUES(paValues)

	func _VALUES_(paValues)
		return VALUES(paValues)

	func @VALUES(paValues)
		return VALUES(paValues)

	func VALUES@(paValues)
		return VALUES(paValues)

	func @VALUES@(paValues)
		return VALUES(paValues)

	#>

func SELECT(pacColNames)

	if CheckParams()

		if NOT ( isString(pacColNames) or
			( isList(pacColNames) and Q(pacColNames).IsListOfStrings() ) )
			StzRaise("Incorrect param type! pacColNames must be a list of string.")
		ok

	ok

	_aSELECT_FROM_WHERE + pacColNames

	#< @FunctionAlternativeForms

	func _SELECT(pacColNames)
		return SELECT(pacColNames)

	func SELECT_(pacColNames)
		return SELECT(pacColNames)

	func _SELECT_(pacColNames)
		return SELECT(pacColNames)

	func @SELECT(pacColNames)
		return SELECT(pacColNames)

	func SELECT@(pacColNames)
		return SELECT(pacColNames)

	func @SELECT@(pacColNames)
		return SELECT(pacColNames)

	#>

func FROM_(pcTableName)

	if CheckParams()
		if NOT isString(pcTableName)
			StzRaise("Incorrect param type! pcTableName must be a string.")
		ok

		# Check if the pcTableName exists as a named variable
		# and containing a stzTable object as a value

		if isString(v(pcTableName)) and v(pcTableName) = NULL
			StzRaise("Incorrect type! The stzTable object managed by the SQL statement is not defined as a global named variable.")
		ok

		if NOT @IsStzTable(v(pcTableName))
			StzRaise("Incorrect param type! The named variable managed by the SQL statement is not a stzTable object.")
		ok
	ok

	_aSELECT_FROM_WHERE + pcTableName

	_oInitialTable = v(pcTableName)
	_oIntermediateTable = _oInitialTable

	if isString(_aSELECT_FROM_WHERE[1]) and 
	   _aSELECT_FROM_WHERE[1] = "*"

		// do nothing
	else

		_oIntermediateTable.RemoveColsOtherThan(_aSELECT_FROM_WHERE[1])
		return _oIntermediateTable
	ok

	#< @FunctionAlternativeForms

	func _FROM(pcTableName)
		return FROM_(pcTableName)

	func _FROM_(pcTableName)
		return FROM_(pcTableName)

	func @FROM(pcTableName)
		return FROM_(pcTableName)

	func FROM@(pcTableName)
		return FROM_(pcTableName)

	func @FROM@(pcTableName)
		return FROM_(pcTableName)

	#>

func WHERE_(pcCondition) #NOTE: Where() is used in an other place

	if CheckParams()
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		if NOT Q(pcCondition).ContainsOneOfTheseCS(_oIntermediateTable.ColsNames(), :CS = FALSE)
			StzRaise("Incorrect param type! The pcCondition must contain columns names of the stzTable object managed by the SQL statement.")
		ok
	ok

	# Managing the info of the SQL query()

	_aSELECT_FROM_WHERE + pcCondition

	acColNames  = _aSELECT_FROM_WHERE[1]

	cTableName = _aSELECT_FROM_WHERE[2]
	cCondition  = _aSELECT_FROM_WHERE[3]

	# Computing the condition (TODO: support complex conditions)

	aRows = _oIntermediateTable.Rows()
	nLen = len(aRows)

	acColNames = _oIntermediateTable.ColNames()
	nLenCols = len(acColNames)

	# Resolving the condition

	for i = 1 to nLenCols

		cColName = acColNames[i]
		cCondition = Q(cCondition).ReplaceQ( cColName,  'v(cTableName).cell(:' + cColName + ', i)' ).Content()
		cCode = 'bOk = ' + cCondition

	next

	# Applying the condition

	anPos = []

	for i = 1 to nLen
		eval(cCode)

		if NOT bOk
			anPos + i
		ok
	next

	_oIntermediateTable.RemoveRows(anPos)
	_aVars[cTableName] = _oInitialTable

	return _oIntermediateTable


	#< @FunctionAlternativeForms

	func _WHERE(pcCondition)
		return WHERE_(pcCondition)

	func _WHERE_(pcCondition)
		return WHERE_(pcCondition)

	func @WHERE(pcCondition)
		return WHERE_(pcCondition)

	func WHERE@(pcCondition)
		return WHERE_(pcCondition)

	func @WHERE@(pcCondition)
		return WHERE_(pcCondition)

	#>

func WITH_(pcSQL)
	/* EXAMPLE

	WITH(:sql).AS([

	SELECT([ :name, :score ]),
	FROM_( :persons ),
	WHERE_( 'score > 100' ) #TODO: check WHERE_( 'name = "Dan"' );

	])

	? v(:sql)

	*/

	return new WITH(pcSQL)

	#< @FunctionAlternativeForms

	func _WITH(pcSQL)
		return WITH_(pcSQL)

	func _WITH_(pcSQL)
		return WITH_(pcSQL)

	func @WITH(pcSQL)
		return WITH_(pcSQL)

	func @WITH@(pcSQL)
		return WITH_(pcSQL)

	#>

func ORDER_BY(pcColName, pcSortOrder)
	if CheckParams()
		if NOT isString(pcColName)
			StzRaise("Incorrect param type! pcColName must be a string.")
		ok

		if NOT ( isString(pcSortOrder) and Q(pcSortOrder).IsEither(:ASC, :DESC))
			StzRaise("Incorrect param type! pcSortOrder must be a string equal to :ASC or :DESC.")
		ok
	ok

	if pcSortOrder = :ASC
		v(:sqlTable).SortOnInAscending(pcColName)

		#NOTE // Very important:

		# Don't use SprtByInAscending(pcColName) here, becase
		# in Softanza terms, the "By" means that we should
		# provide an expression to sort the table with.

		# As it is clear, in our case, we want to sort the
		# table ON a given column (contained in pcColName)
		# ~> In Softanza, "On" is used to sort on a COLUMN.

	else
		v(:sqlTable).SortOnInDescending(pcColName)
	ok

	#< @FunctionAlternativeForms

	func _ORDER_BY(pcColName, pcSortOrder)
		ORDER_BY(pcColName, pcSortOrder)

	func ORDER_BY_(pcColName, pcSortOrder)
		ORDER_BY(pcColName, pcSortOrder)

	func _ORDER_BY_(pcColName, pcSortOrder)
		ORDER_BY(pcColName, pcSortOrder)

	func @ORDER_BY(pcColName, pcSortOrder)
		ORDER_BY(pcColName, pcSortOrder)

	func @ORDER_BY@(pcColName, pcSortOrder)
		ORDER_BY(pcColName, pcSortOrder)

  /////////////////
 ///  CLASSES  ///
/////////////////

class WITH // used in supporting SQL semantics

	cSQL

	def init(pcSQL)
		if CheckParams()
			if NOT isString(pcSQL)
				StzRaise("Incorrect param type! pcSQL must be a string.")
			ok
		ok

		cSQL = pcSQL

	def As(paParams)
		if CheckParams()
			if NOT ( isList(paParams) and
				 len(paParams) > 0 and len(paParams) <= 3 )

				StzRaise("Incorrect param type! paParams must be a list of 1 to 3 items.")
			ok
		ok

		n = StzHashListQ(_aVars).FindKey(cSQL)

		if n = 0
			_aVars + [ cSQL, _oIntermediateTable.rows() ]
			_aVars + [ cSQL + 'Data', _oIntermediateTable.rows() ]
			_aVars + [ cSQL + 'Table', _oIntermediateTable ]
			_aVars + [ cSQL + 'Object', _oIntermediateTable ]
	
		else
			_aVars[n] = [ cSQL, _oIntermediateTable.rows() ]
			_aVars[n] = [ cSQL + 'Data', _oIntermediateTable.rows() ]
			_aVars[n] = [ cSQL + 'Table', _oIntermediateTable ]
			_aVars[n] = [ cSQL + 'Object', _oIntermediateTable ]

		ok

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
	
