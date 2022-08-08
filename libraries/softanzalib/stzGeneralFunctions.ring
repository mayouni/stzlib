
_cSoftanzaLogo =
'
╭━━━┳━━━┳━━━┳━━━━┳━━━┳━╮╱╭┳━━━━┳━━━╮
┃╭━╮┃╭━╮┃╭━━┫╭╮╭╮┃╭━╮┃┃╰╮┃┣━━╮━┃╭━╮┃
┃╰━━┫┃╱┃┃╰━━╋╯┃┃╰┫┃╱┃┃╭╮╰╯┃╱╭╯╭┫┃╱┃┃
╰━━╮┃┃╱┃┃╭━━╯╱┃┃╱┃╰━╯┃┃╰╮┃┃╭╯╭╯┃╰━╯┃
┃╰━╯┃╰━╯┃┃╱╱╱╱┃┃╱┃╭━╮┃┃╱┃┃┣╯━╰━┫╭━╮┃
╰━━━┻━━━┻╯╱╱╱╱╰╯╱╰╯╱╰┻╯╱╰━┻━━━━┻╯╱╰━

Programming, by Heart! By: M.Ayouni╭
━━╮╭━━━━━━━━━━━━━━━━━━━━╮╱╭━━━━━━━━╯
  ╰╯
'
	
func SoftanzaLogo()
	return _cSoftanzaLogo

func Stringify(p)
	if isString(p)
		return p

	but isNumber(p)
		return "" + p

	but isList(p)
		return ComputableForm(p) # Same as @@(p)

	but isObject(p)
		return ComputableForm( p.Listified() ) # TODO ?
	ok

func stzRaise(paMessage)
	/*
	WARNING: Do not use stzRaise to raise errors here
	--> Stackoverflow!

	Hence, this is the unique place in the library
	where we use the native ring raise() function.

	*/

	if NOT ( isString(paMessage) or isList(paMessage) )

		raise("Error in stzRaise param type!" + NL)
	ok

	if isString(paMessage)
		raise(paMessage + NL)
	ok

	if isList(paMessage) and StzListQ(paMessage).IsRaiseNamedParamList()
		cWhere = paMessage[ :Where ]
		cWhat  = paMessage[ :What   ]
		cWhy   = paMessage[ :Why    ]
		cTodo  = paMessage[ :Todo   ]

	

		if NOT StzListQ([ cWhere, cWhat, cWhy, cTodo ]).IsListOfStrings()
			raise("Error in stzRaise param type!")
		ok
	
		cFile = StzStringQ(cWhere).WithoutSpaces()
		if isNull(cWhere)
			raise("Error in stzRaise --> Where the error happened!")
		ok
	
		cWhat = StzStringQ(cWhat).Simplified()
		cwhay = StzStringQ(cWhy).Simplified()
		cTodo = StzStringQ(cTodo).Simplified()
	
		cErrorMsg = "in file " + paMessage[:Where] + ":" + NL
	
		if cWhat != NULL
			cErrorMsg += "   What : " + paMessage[:What] + NL
		ok
	
		if cWhy != NULL
			cErrorMsg += "   Why  : " + paMessage[:Why]  + NL
		ok
	
		if cTodo != NULL
			cErrorMsg += "   Todo : " + paMessage[:Todo] + NL
		ok

		raise(cErrorMsg)
	else
		raise("Error in stzRaise > Incorrect param type!")
	ok

func IsNumberOrString(p)
	if isNumber(p) or isString(p)
		return TRUE
		else
		return FALSE
	ok

	func IsStringOrNumber(p)
		return func IsNumberOrString(p)

func IsNumberOrList(p)
	if isNumber(p) or isList(p)
		return TRUE
		else
		return FALSE
	ok

	func IsListOrNumber(p)
		return This.IsNumberOrList(p)

func IsNumberOrObject(p)
	if isNumber(p) or isObject(p)
		return TRUE
		else
		return FALSE
	ok

	func IsObjectOrNumber(p)
		return This.IsNumberOrObject(p)

func IsStringOrList(p)
	if isString(p) or isList(p)
		return TRUE
	else
		return FALSE
	ok

	def IsListOrString(p)
		return IsStringOrList(p)

func IsStringOrObject(p)
	if isString(p) or isObject(p)
		return TRUE
		else
		return FALSE
	ok

	def IsObjectOrString(p)
		return IsStringOrObject(p)

func IsListOrObject(p)
	if isList(p) or isObject(p)
		return TRUE
		else
		return FALSE
	ok

func ListOfListsOfStzTypes() # TODO: complete the list
	return [
		:ListOfStzNumbers,
		:ListOfStzStrings,
		:ListOfStzLists,
		:ListOfStzObjects,
		:ListOfStzChars,
		:ListOfStzHashlists,
		:ListOfStzPairs,
		:ListOfStzSets,
		:ListOfStzGrids
	]

func InfereDataTypeFromString(pcStr)
	cStr = Q(pcStr).Lowercased()

	if cStr = :number or cStr = :numbers or Q(cStr).BeginsWith(:Number)
		return :Number

	but cStr = :string or cStr = :strings or Q(cStr).BeginsWith(:String)
		return :String

	but cStr = :list or cStr = :lists or Q(cStr).BeginsWith(:List) or
	    cStr = :pair or cStr = :pairs or Q(cStr).BeginsWith(:pair)
		return :List

	but cStr = :object or cStr = :objects or Q(cStr).BeginsWith(:Object)
		return :Object

	ok


	if Q(cStr).BeginsWithCS("stz", :CS = FALSE)

		for aPair in StzClassesXT()
			if aPair[1] = cStr or aPair[2] = cStr
				return aPair[1]
			ok
		next

	ok

	func InfereTypeFromString(pcStr)
		return InfereDataTypeFromString(pcStr)

func DataType(p)
	return lower(type(p))


# DO TWO VARIABLES HAVE SAME TYPE?

func BothAreNumbers(p1, p2)
	if isNumber(p1) and isNumber(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothNumbers(p1, p2)
		return BothAreNumbers(p1, p2)

func BothAreNumbersInStrings(p1, p2) # NOTE: hex and octal numbers are excluded

	if BothAreStrings(p1, p2) and Q(p1).IsDecimalNumberInString() and Q(p2).IsDecimalNumberInString()
		return TRUE

	else
		return FALSE
	ok

func BothAreCharsInComputableForm(p1, p2)

	bResult = FALSE

	if BothAreStringsInComputableForm(p1, p2)
		c1 = '"'
		c2 = "'"

		bOk1 = StzStringQ(p1).RemoveManyQ([ c1, c2 ]).IsAChar()
		bOk2 = StzStringQ(p2).RemoveManyQ([ c1, c2 ]).IsAChar()

		if bOk1 and bOk2
			bResult = TRUE
		ok
	ok

	return bResult
	
	 
func BothAreStringsInComputableForm(p1, p2)
	c1 = '"'
	c2 = "'"

	if BothAreStrings(p1, p2) and

	   ( ( Q(p1).FirstChar() = c1 and Q(p1).LastChar() = c1 ) or
	     ( Q(p1).LastChar()  = c2 and Q(p1).LastChar() = c2 )
	   ) and

	   ( ( Q(p2).FirstChar() = c1 and Q(p2).LastChar() = c1 ) or
	     ( Q(p2).LastChar()  = c2 and Q(p2).LastChar() = c2 )
	   )

		return TRUE

	else
		return FALSE
	ok

func BothAreStzNumbers(p1, p2)
	if IsStzNumber(p1) and IsStzNumber(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothStzNumbers(p1, p2)
		return BothAreStzNumbers(p1, p2)

func BothAreStrings(p1, p2)
	if isString(p1) and isString(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothStrings(p1, p2)
		return BothAreStrings(p1, p2)

func BothAreStzStrings(p1, p2)
	if IsStzString(p1) and IsStzString(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothStzStrings(p1, p2)
		return BothAreStzStrings(p1, p2)

func BothAreLists(p1, p2)
	if isList(p1) and isList(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothLists(p1, p2)
		return BothAreLists(p1, p2)

func BothAreStzLists(p1, p2)
	if IsStzList(p1) and IsStzList(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothStzLists()
		return BothAreStzLists()

func BothAreObjects(p1, p2)
	if isObject(p1) and isObject(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothObjects(p1, p2)
		return BothAreObjects(p1, p2)

func BothAreStzObjects(p1, p2)
	if IsStzObject(p1) and IsStzObject(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothStzObjects(p1, p2)
		return BothAreStzObjects(p1, p2)

# ARE TWO OBJECTS THE SAME?

func AreSameObject(pcObjectName1, pcObjectName2) # TODO
	return StzObjectQ(pcObjectName1).IsEqualTo( pcObjectName2 )

# REPEATING A THING N TIME

func RepeatNTimes(n, pThing)
	switch type(pThing)
	on "STRING"
		return StzStringQ(pThing).RepeatedNTimes(n)

	on "LIST"
		return StzListQ(pThing).RepeatedNTimes(n)

	on "NUMBER"
		return StzNumberQ(pThing).RepeatedNTimes(n)

	on "OBJECT"
		return StzObjectQ(pThing).RepeatedNTimes(n)
	off

func One(pThing)
	return pThing

func Two(pThing)
	return RepeatNTimes(2, pThing)

func Three(pThing)
	return RepeatNTimes(3, pThing)

func Four(pThing)
	return RepeatNTimes(4, pThing)

func Five(pThing)
	return RepeatNTimes(5, pThing)

func Six(pThing)
	return RepeatNTimes(6, pThing)

func Seven(pThing)
	return RepeatNTimes(7, pThing)

func Eight(pThing)
	return RepeatNTimes(8, pThing)

func Nine(pThing)
	return RepeatNTimes(9, pThing)

func Ten(pThing)
	return RepeatNTimes(10, pThing)

# OTHER STAFF

func IsRingType(pcString)
	return StzStringQ(pcString).LowercaseQ().ExistsIn( RingTypes() )

	def IsRingDataType(pcString)
		return IsRingType(pcString)

func StringIsStzClassName(pcString)
	return StzStringQ(pcString).IsStzClassName()

func StringIsChar(pcStr)
	oStzString = new stzString(pcStr)
	return oStzString.IsChar()

func CharIsLetter(pcStr)
	oStzChar = new stzChar(pcStr)
	return oStzChar.IsLetter()

func IsTrue(p)
	if isNumber(p) and p = 1
		return TRUE
	ok

	if isList(p) and len(p) = 2 and isString(p[1]) and p[2] = TRUE
		return TRUE
	ok

	# else

	return FALSE

func IsFalse(p)
	if isNumber(p) and p = 0
		return TRUE
	ok

	if isList(p) and len(p) = 2 and isString(p[1]) and p[2] = FALSE
		return TRUE
	ok

	# else

	return FALSE

func StzLen(p)
	if isString(p)
		return StzStringQ(p).NumberOfChars()

	but IsStzString(p)
		return p.NumberOfChars()

	but isList(p)
		return len(p)

	but IsStzList(p)
		return p.NumberOfItems()

	else
		stzRaise("Unsupported parameter type!")
	ok

func Unicode(p)

	if isString(p) and StringIsChar(p)
		return CharUnicode(p)

	but isString(p)
		return StringUnicodes(p)

	but isList(p) and ListIsListOfChars(p)
		return CharsUnicodes(p)

	but isList(p) and ListIsListOfStrings(p)
		return StringsUnicodes(p)

	else
		stzRaise("Incorrect param type!")
	ok

	#< @FunctionAlternativeForm

	func Unicodes(p)
		return Unicode(p)

	#>

func Scripts(paListStr)
	return StzListOfStringsQ(paListStr).Scripts()

// Computable form, (equivalent of ring listtocode() function)
func ComputableForm(pValue) # TODO: case of object --> return its name

	if isNumber(pValue)
		return ""+ pValue

	but isString(pValue)
		return '"' + pValue + '"'

	but isList(pValue)
		return ListToCode(pValue)
	ok

	#< @FunctionFluentForm

	func ComputableFormQ(pValue)
		return new stzString( ComputableForm(pValue) )

	#>

	#< @FunctionAlternativeForms

	func @@(pValue)
		return ComputableForm(pValue)

		func @@Q(pValue)
			return new stzString( @@(pValue) )

	func CF(pValue)
		return ComputableForm(pValue)

		func CFQ(pValue)
			return new stzString( CF(pValue) )

	#>

func ComputableFormSimplified(pValue)
	if isNumber(pValue)
		return ""+ pValue

	but isString(pValue)

		oStr = new stzString(pValue)
		aAntiSections = oStr.FindAntiSections( oStr.FindAnySectionsBetween('"','"') )
		
		oStr.ReplaceSections(aAntiSections, :With@ = ' Q(@Section).Simplified() ')
		#--> this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"
		
		cChar = ""

		if Q('"').
		   Occurs( :Before = "'", :In = pValue )
			cChar = '"'

		else
			cChar = "'"
		ok

		cResult = cChar + oStr.Content() + cChar

	but isList(pValue)
		return @@Q(pValue).Simplified()
	ok

	return cResult

	func ComputableFormSimplifiedQ(pValue)
		return new stzString( ComputableFormSimplified(pValue) )

	func @@SF(pValue)
		return ComputableFormSimplified(pValue)

		func @@SFQ(pValue)
			return new stzString( @@(pValue) )

	func @@S(pValue)
		return ComputableFormSimplified(pValue)

		func @@SQ(pValue)
			return new stzString( @@(pValue) )



func YaAllah()
	return "يَا أَلله"

func YaMuhammed()
	return "يا مُحَمَّدْ"

func SalatNabee()
	return "صلّى الله على نبيّه الأكرم"

func NTimes(n, pThing)
	result = NULL

	if isString(pThing)
		cResult = copy(pThing, n)
		return cResult

	but isNumber(pThing)
		cTemp = copy( ""+ pThing, n )
		nResult = 0+ cTemp
		return nResult

	but isList(pThing) or isObject(pThing)
		aResult = []
		for i = 1 to n
			aResult + pThing
		next
		return aResult

	ok 

	def NTimesQ(n, pThing)
		return Q(NTimes(n, pThing))

func NHearts(n)
	return NTimes(n, Heart())

	func 2Hearts()
		return NHearts(2)

	func 3Hearts()
		return NHearts(3)

	func 5Hearts()
		return NHearts(5)

	func 7Hearts()
		return NHearts(7)

	func 9Hearts()
		return NHearts(9)

func NStars(n)
	return NTimes(n, Star())

	func 2Stars()
		return NStars(2)

	func 3Stars()
		return NStars(3)

	func 5Stars()
		return NStars(5)

	func 7Stars()
		return NStars(7)

	func 9Stars()
		return NStars(9)

func IfWith@Eval(p)

	if isList(p) and Q(p).IsWithNamedParamList()

		if Q(p[1]).LastChar() = "@"
				
			cCode = 'cValue = (' +
				 Q(p[2]).BoundsRemoved("{","}") +
				')'

			eval(cCode)
			p = cValue

		else
			p = p[2]
		ok
	
	ok

	return p

	func EvalIfWith@(p)
		return IfWith@Eval(p)

# Returns the softanza object related to the type of p
func Q(p)

	if isString(p)
		return new stzString(p)

	but isNumber(p)
		return new stzNumber(p)

	but isList(p)
		return new stzList(p)

	but isObject(p)
		return new stzObject(p)
	ok

	func _Q(p)
		return Q(p)

	func _@(p)
		return Q(p)

	func @(p)
		return Q(p)

	func Softanzify(p)
		return Q(p)

func QR(p, pcType)
	if NOT isString(pcType)
		stzRaise("Invalid param type! pcType should be a string containing the name of a softanza class.")
	ok

	if StringIsStzClassName(pcType)
		cCode = "oResult = new " + pcType + "(" + @@(p) + ")"
		eval(cCode)

		return oResult
	else
		stzRaise("Unsupported Softanza type!")
	ok

func QQ(p)
	if isString(p)
		if Q(p).IsNumberInString()
			return new stzNumber(p)

		but Q(p).IsListInString() # TODO: check Q(' "A" : "C" ').IsListInString()
			return new stzList(p)
			# TODO: check new stzList("[1, 2, 3]")

		but Q(p).IsChar()
			return new stzChar(p)

		ok

	but isList(p)
		oQTemp = Q(p)
		if oQTemp.IsListOfNumbers()
			return new stzListOfNumbers(p)

		but oQTemp.IsListOfChars()
			return new stzListOfChars(p)

		but oQTemp.IsListOfStrings()
			return new stzListOfStrings(p)

		but oQTemp.IsListOfHashLists()
			return new stzListOfHashLists(p)

		but oQTemp.IsListOfPairs()
			return new stzListOfPairs(p)

		but oQTemp.IsListOfLists()
			return new stzListOfLists(p)
		ok

	else
		return Q(p)
	ok

func STOP()
	StzRaise( NL + "----------------" + "STOPPED!" )
