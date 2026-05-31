
#TODO // general - study the compatibility of softanza comments
# with JSDoc (https://jsdoc.app/)
#--> Create a generator of a static web site documentation

_cSoftanzaLogo = '
â•­â”â”â”â”³â”â”â”â”³â”â”â”â”³â”â”â”â”â”³â”â”â”â”³â”â•®â•±â•­â”³â”â”â”â”â”³â”â”â”â•®
â”ƒâ•­â”â•®â”ƒâ•­â”â•®â”ƒâ•­â”â”â”«â•­â•®â•­â•®â”ƒâ•­â”â•®â”ƒâ”ƒâ•°â•®â”ƒâ”£â”â”â•®â”â”ƒâ•­â”â•®â”ƒ
â”ƒâ•°â”â”â”«â”ƒâ•±â”ƒâ”ƒâ•°â”â”â•‹â•¯â”ƒâ”ƒâ•°â”«â”ƒâ•±â”ƒâ”ƒâ•­â•®â•°â•¯â”ƒâ•±â•­â•¯â•­â”«â”ƒâ•±â”ƒâ”ƒ
â•°â”â”â•®â”ƒâ”ƒâ•±â”ƒâ”ƒâ•­â”â”â•¯â•±â”ƒâ”ƒâ•±â”ƒâ•°â”â•¯â”ƒâ”ƒâ•°â•®â”ƒâ”ƒâ•­â•¯â•­â•¯â”ƒâ•°â”â•¯â”ƒ
â”ƒâ•°â”â•¯â”ƒâ•°â”â•¯â”ƒâ”ƒâ•±â•±â•±â•±â”ƒâ”ƒâ•±â”ƒâ•­â”â•®â”ƒâ”ƒâ•±â”ƒâ”ƒâ”£â•¯â”â•°â”â”«â•­â”â•®â”ƒ
â•°â”â”â”â”»â”â”â”â”»â•¯â•±â•±â•±â•±â•°â•¯â•±â•°â•¯â•±â•°â”»â•¯â•±â•°â”â”»â”â”â”â”â”»â•¯â•±â•°â”

Programming, by Heart! By: M.Ayouniâ•­
â”â”â•®â•­â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â•®â•±â•­â”â”â”â”â”â”â”â”â•¯
  â•°â•¯'

#TODO // Add these alternatives to NumberOf...() functions, allover the library:
#	- HowMany...() : in singular and plural forms, exp: HowManyItem() and HowManyItems()
#	- Count...()
# NB: Many have been added! Check those that haven't.

  ///////////////////////////
 ///  GLOBALS VARIABLES  ///
///////////////////////////

_bInHistoryUpdate = 0

$TEMP_LIST = [] # A temp list value used with @() inside objects
$TEMP_STRING = ""
$TEMP_NUMBER = 0
$TEMP_OBJECT = ""

_bKeepHisto = 0 // for keeping objec update history
_aHisto = []

_aKeepHistoXT = [ 0, "" ]
_aHistoXT = []

_bKeepTime = 0 // for keeping object execution time
_nTimeInSeconds = 0
_nStartTimeInClocks = 0

_aRingTypes = [ :number, :string, :char, :list, :object, :cobject ]

_aRingTypesXT = [
		[ "number", "numbers" ],
		[ "string", "strings" ],
		[ "char", "chars" ],
		[ "list", "lists" ],
		[ "object", "objects" ]
	]

@ = 0

# Temporary Truth Statement and Negation (read X as Truth)
_bXStatement_ = 1

_aStzFindableTypes = [
	:stzListOfNumbers, :stzListOfUnicodes, :stzString, :stzMultiString,
	:stzSubString, :stzItem, :stzStopWords,
	:stzListOfStrings, :stzListInString, :stzListOfBytes,
	:stzListOfChars, :stzList, :stzHashList,
	:stzListOfHashLists, :stzSet, :stzListOfLists, :stzSplitter,
	:stzListOfPairs, :stzPair, :stzPairOfNumbers, :stzPairOfLists,
	:stzListOfSets, :stzTree, :stzWalker, :stzTable,
	:stzGrid, :stzListOfEntities, :stzText,
	:stzSection
]

_MainValue = ""
_LastValue = ""

_bThese = 0	     	# Used in case like: Q(1:5) - These(3:5) 	--> [1,2]
_bTheseQ = 0     	# Used in case like: Q(1:5) - TheseQ(3:5) 	--> Q([1,2])

_bAsObject = 0	# Used in case like: Q(1:2) + Obj(Q(3:4))	--> [ [1,2], Q([3,4]) ]
_bAsObjectQ = 0

_bModifiable = 0	# Used with operators that modify stz objects

_bParamCheck = 1  	# Activates the "# Checking params region" in softanza functions
		     	#--> Set it to FALSE if the functions are used inside large loops
		    	# so you can gain performance (the checks can then be made once,
		     	# by yourself, outside the loop).
			# Use the SetParamCheckingTo(FALSE)

_bEarlyCheck = 1	# Used for the same reason as _bParamCheck

cCacheFileName = "stzcache.txt"
_CacheFileHandler = ""

_cCacheMemoryString = ""

_acRingFunctions = [ // #TODO // Add the new functions added in Ring 1.21
	"acos",
	"add",
	"addattribute",
	"adddays",
	"addmethod",
	"addsublistsbyfastcopy",
	"addsublistsbymove",
	"ascii",
	"asin",
	"assert",
	"atan",
	"atan2",
	"attributes",
	"binarysearch",
	"bytes2double",
	"bytes2float",
	"bytes2int",
	"callgarbagecollector",
	"callgc",
	"ceil",
	"cfunctions",
	"char",
	"chdir",
	"checkoverflow",
	"classes",
	"classname",
	"clearerr",
	"clock",
	"clockspersecond",
	"closelib",
	"copy",
	"cos",
	"cosh",
	"currentdir",
	"date",
	"dec",
	"decimals",
	"del",
	"diffdays",
	"dir",
	"direxists",
	"double2bytes",
	"eval",
	"exefilename",
	"exefolder",
	"exp",
	"fabs",
	"fclose",
	"feof",
	"ferror",
	"fexists",
	"fflush",
	"fgetc",
	"fgetpos",
	"fgets",
	"filename",
	"find",
	"float2bytes",
	"floor",
	"fopen",
	"fputc",
	"fputs",
	"fread",
	"freopen",
	"fseek",
	"fsetpos",
	"ftell",
	"functions",
	"fwrite",
	"getarch",
	"getattribute",
	"getchar",
	"getpathtype",
	"getpointer",
	"getptr",
	"globals",
	"hex",
	"hex2str",
	"input",
	"insert",
	"int2bytes",
	"intvalue",
	"isalnum",
	"isalpha",
	"isandroid",
	"isattribute",
	"iscfunction",
	"isclass",
	"iscntrl",
	"isdigit",
	"isfreebsd",
	"isfunction",
	"isglobal",
	"isgraph",
	"islinux",
	"islist",
	"islocal",
	"islower",
	"ismacosx",
	"ismethod",
	"ismsdos",
	"isnull",
	"isnumber",
	"isobject",
	"ispackage",
	"ispackageclass",
	"ispointer",
	"isprint",
	"isprivateattribute",
	"isprivatemethod",
	"ispunct",
	"isspace",
	"isstring",
	"isunix",
	"isupper",
	"iswindows",
	"iswindows64",
	"isxdigit",
	"left",
	"len",
	"lines",
	"list",
	"list2str",
	"loadlib",
	"locals",
	"log",
	"log10",
	"lower",
	"max",
	"memcpy",
	"memorycopy",
	"mergemethods",
	"methods",
	"min",
	"murmur3hash",
	"newlist",
	"nofprocessors",
	"nullpointer",
	"nullptr",
	"number",
	"obj2ptr",
	"object2pointer",
	"objectid",
	"packageclasses",
	"packagename",
	"packages",
	"perror",
	"pointer2object",
	"pointer2string",
	"pointercompare",
	"pow",
	"prevfilename",
	"ptr2obj",
	"ptr2str",
	"ptrcmp",
	"raise",
	"random",
	"randomize",
	"read",
	"remove",
	"rename",
	"reverse",
	"rewind",
	"right",
	"ring_give",
	"ring_see",
	"ring_state_delete",
	"ring_state_filetokens",
	"ring_state_findvar",
	"ring_state_init",
	"ring_state_main",
	"ring_state_mainfile",
	"ring_state_new",
	"ring_state_newvar",
	"ring_state_runcode",
	"ring_state_runfile",
	"ring_state_runobjectfile",
	"ring_state_scannererror",
	"ring_state_setvar",
	"ring_state_stringtokens",
	"ringvm_callfunc",
	"ringvm_calllist",
	"ringvm_cfunctionslist",
	"ringvm_classeslist",
	"ringvm_evalinscope",
	"ringvm_fileslist",
	"ringvm_functionslist",
	"ringvm_genarray",
	"ringvm_give",
	"ringvm_hideerrormsg",
	"ringvm_info",
	"ringvm_memorylist",
	"ringvm_packageslist",
	"ringvm_passerror",
	"ringvm_scopescount",
	"ringvm_see",
	"ringvm_settrace",
	"ringvm_tracedata",
	"ringvm_traceevent",
	"ringvm_tracefunc",
	"setattribute",
	"setpointer",
	"setptr",
	"shutdown",
	"sin",
	"sinh",
	"sort",
	"space",
	"sqrt",
	"srandom",
	"str2hex",
	"str2hexcstyle",
	"str2list",
	"strcmp",
	"string",
	"substr",
	"swap",
	"sysget",
	"sysset",
	"system",
	"sysunset",
	"tan",
	"tanh",
	"tempfile",
	"tempname",
	"time",
	"timelist",
	"trim",
	"type",
	"ungetc",
	"unsigned",
	"upper",
	"uptime",
	"variablepointer",
	"varptr",
	"version",
	"windowsnl",
	"write"
]

#TODO // Review the list for last ring version
_acRingKeywords = [
	"again",
	"and",
	"but",
	"bye",
	"call",
	"case",
	"catch",
	"changeringkeyword",
	"changeringoperator",
	"class",
	"def",
	"do",
	"done",
	"else",
	"elseif",
	"end",
	"exit",
	"for",
	"from",
	"func",
	"get",
	"give",
	"if",
	"import",
	"in",
	"load",
	"loadsyntax",
	"loop",
	"new",
	"next",
	"not",
	"off",
	"ok",
	"on",
	"or",
	"other",
	"package",
	"private",
	"put",
	"return",
	"see",
	"step",
	"switch",
	"to",
	"try",
	"while",
	"endfunc",
	"endclass",
	"endpackage"
]

_nQuietEqualityRatio = 0.09

# Softanza keywords used in Conditaional Code (CCode)

_acStzCCKeywords = [
	:@Number,
		:@CurrentNumber,
		:@PreviousNumber,
		:@NextNumber,
	
	:@Char,
		:@CurrentChar,
		:@PreviousChar,
		:@NextChar,
	
	:@String,
		:@CurrentString,
		:@PreviousString,
		:@NextString,
	
	:@Line,
		:@CurrentLine,
		:@PreviousLine,
		:@NextLine,
	
	:@Item,
		:@CurrentItem,
		:@PreviousItem,
		:@NextItem,

		:@Section,
		:@Range,
	
	:@List,
		:@CurrentList,
		:@PreviousList,
		:@NextList,

	:@Pair,
		:@CurrentPair,
		:@PreviousPair,
		:@NextPair,

	:@Object,
		:@CurrentObject,
		:@PreviousObject,
		:@NextObject
	]

  //////////////////////////
 ///  GLOBAL FUNCTIONS  ///
//////////////////////////

func StzFindAllCS(pContainer, pVal, pCaseSensitive)
	if CheckParams()
		if NOt (isString(pContainer) or isList(pContainer))
			StzRaise("Incorrect param type! pContainer must be a string or list.")
		ok
	ok

	if isString(pContainer)
		return StzStringQ(pContainer).FindCS(pVal, pCaseSensitive)

	else
		# Engine-backed find for string items
		if isString(pVal)
			_pFacList = StzEngineMarshalList(pContainer)
			_pFacResult = StzEngineListFindAllStringCS(_pFacList, pVal, CaseSensitive(pCaseSensitive))
			StzEngineListFree(_pFacList)
			if _pFacResult != NULL
				_aFacPositions = StzEngineContentFromList(_pFacResult)
				StzEngineListFree(_pFacResult)
				return _aFacPositions
			ok
			return []
		ok

		# Fallback for non-string items
		aResult = []
		nLen = len(pContainer)
		for i = 1 to nLen
			if BothAreEqualCS(pContainer[i], pVal, pCaseSensitive)
				aResult + i
			ok
		next
		return aResult
	ok

	func FindCS(pContainer, pVal, pCaseSensitive)
		return StzFindAllCS(pContainer, pVal, pCaseSensitive)

	func @FindCS(pContainer, pVal, pCaseSensitive)
		return StzFindAllCS(pContainer, pVal, pCaseSensitive)

	func FindAllCS(pContainer, pVal, pCaseSensitive)
		return StzFindAllCS(pContainer, pVal, pCaseSensitive)

	func @FindAllCS(pContainer, pVal, pCaseSensitive)
		return StzFindAllCS(pContainer, pVal, pCaseSensitive)

func StzFindAll(pContainer, pVal)
	return StzFindAllCS(pContainer, pVal, 1)

	func @Find(pContainer, pVal)
		return StzFindAll(pContainer, pVal)

	func FindAll(pContainer, pVal)
		return StzFindAll(pContainer, pVal)

	func @FindAll(pContainer, pVal)
		return StzFindAll(pContainer, pVal)


#---

func StzTruthStatement()
	return _bXStatement_

	func TruthStatement()
		return StzTruthStatement()

#---

func StzKeepingTime()
	return _bKeepTime

	func KeepingTime()
		return StzKeepingTime()

	func KeepingExecutionTime()
		return StzKeepingTime()

	func ObjectKeepingTime()
		return StzKeepingTime()

	func KeepingObjectTime()
		return StzKeepingTime()

func StzSetKeepingTimeTo(bTrueOrFalse)
	if CheckParams()
		if NOT (isNumber(bTrueOrFalse) and isNumber(bTrueOrFalse) )
			StzRaise("Incorrect param type! bTrueOrFalse must be a number.")
		ok

		if NOT ( bTrueOrFalse = 0 or bTrueOrFalse = 1 )
			StzRaise("Incorrect param value! bTrueOrFalse must be 0 or 1.")
		ok
	ok

	_bKeepTime = bTrueOrFalse
	_nStartTimeInClocks = clock()

	func SetKeepingTimeTo(bTrueOrFalse)
		StzSetKeepingTimeTo(bTrueOrFalse)

	func SetKeepingTime(bTrueOrFalse)
		StzSetKeepingTimeTo(bTrueOrFalse)

	func SetKeepTime(bTrueOrFalse)
		StzSetKeepingTimeTo(bTrueOrFalse)

	func SetObjectKeepingTimeTo(bTrueOrFalse)
		StzSetKeepingTimeTo(bTrueOrFalse)

	func SetKeepingObjectTimeTo(bTrueOrFalse)
		StzSetKeepingTimeTo(bTrueOrFalse)

func StzStartObjectTime()
	_nStartTimeInClocks = clock()

	func StartObjectTime()
		StzStartObjectTime()

	func StartObjectTimeInClocks()
		StzStartObjectTime()

#-- Managing temporal values (used with @() inside objects)

func StzTempList()
	return $TEMP_LIST

	func TempList()
		return StzTempList()

func StzSetTempList(aList)
	if NOT isList(aList)
		StzRaise("Incorrect param type! aList must be a list.")
	ok

	$TEMP_LIST = aList

	func SetTempList(aList)
		StzSetTempList(aList)

func StzEraseTempList()
	$TEMP_LIST = []

	func EraseTempList()
		StzEraseTempList()

#--

func StzTempString()
	return $TEMP_STRING

	func TempString()
		return StzTempString()

func StzSetTempString(cStr)
	if NOT isString(cStr)
		StzRaise("Incorrect param type! cStr must be a string.")
	ok

	$TEMP_STRING = cStr

	func SetTempString(cStr)
		StzSetTempString(cStr)

func StzEraseTempString()
	$TEMP_STRING = ""

	func EraseTempString()
		StzEraseTempString()

#--

func StzTempNumber()
	return $TEMP_NUMBER

	func TempNumber()
		return StzTempNumber()

func StzSetTempNumber(n)
	if NOT isNumber(n)
		StzRaise("Incorrect param type! n must be a number.")
	ok

	$TEMP_NUMBER = n

	func SetTempNumber(n)
		StzSetTempNumber(n)

func StzEraseTempNumber()
	$TEMP_NUMBER = 0

	func EraseTempnumber()
		StzEraseTempNumber()

#--

func StzTempObject()
	return $TEMP_OBJECT

	func TempObject()
		return StzTempObject()

func StzSetTempObject(pObj)
	if NOT isObject(pObj)
		StzRaise("Incorrect param type! pObj must be an object.")
	ok

	$TEMP_OBJECt = pObj

	func SetTempObject(pObj)
		StzSetTempObject(pObj)

func StzEraseTempObject()
	$TEMP_STRING = ""

	func EraseTempObject()
		StzEraseTempObject()

#===

func AttributesValues(pObject) # Compliments Ring attributes() function
	if NOT isObject(pObject)
		Raise("Incorrect param type! pObject must be an object.")
	ok

	aResult = []

	acAttributes = attributes(pObject)
	nLen = len(acAttributes)

	for i = 1 to nLen
		cCode = 'value = pObject.' + acAttributes[i]
		eval(cCode)
		aResult + value
	next

	return aResult

	func @AttributesValues(pObject)
		return AttributesValues(pObject)

#====== REPEATING A VALUE N TIMES

func @N(n, item)
	# EXAMPLE
	# ? @N(3 ,"A")	#--> [ "A", "A", "A" ]

	if CheckParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	return @NXT(n, item, :InAList)

	#< @FunctionSpecificForms

	func @1(val)
		return @N(1, val)

		func One(val)
			return @N(1, val)

	func @2(val)
		return @N(2, val)

		func Two(val)
			return @N(2, val)

	func @3(val)
		return @N(3, val)

		func Three(val)
			return @N(3, val)

	func @4(val)
		return @N(4, val)
	
		func Four(val)
			return @N(4, val)

	func @5(val)
		return @N(5, val)

		func Five(val)
			return @N(5, val)

	func @6(val)
		return @N(6, val)

		func Six(val)
			return @N(6, val)

	func @7(val)
		return @N(7, val)

		func Seven(val)
			return @N(7, val)

	func @8(val)
		return @N(8, val)

		func Eight(val)
			return @N(8, val)

	func @9(val)
		return @N(9, val)

		func Nine(val)
			return @N(9, val)

	func @10(val)
		return @N(10, val)

		func Ten(val)
			return @N(10, val)

	#>

func @NXT(n, pStrOrItem, pcInStrOrList)
	# EXAMPLES
	# ? @NXT(3 ,"A", :InAString)	#--> "AAA"
	# ? @NXT(3, "A", :InAList)	#--> [ "A", "A", "A" ]

	if CheckParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if NOT isString(pcInStrOrList)
			StzRaise("Incorrect param type! pcInStrOrList must be a string.")
		ok
	ok

	if pcInStrOrList = :InList or pcInStrOrList = :InAList or
	   pcInStrOrList = :AsList or pcInStrOrList = :AsAList or
	   pcInStrOrList = :List

		_aResult_ = []
	
		for @i = 1 to n
			_aResult_ + pStrOrItem
		next
	
		return _aResult_

	but pcInStrOrList = :InString or pcInStrOrList = :InAString or
	    pcInStrOrList = :AsString or pcInStrOrList = :AsAString or
	    pcInStrOrList = :String

		_cResult_ = copy(pStrOrItem, n)
		return _cResult_

	else
		StzRaise("Incorrect syntax! pcInStrOrList must be a string equal to :InString or :InList.")
	ok

	#< @FunctionSpecificForms

	func @1XT(pStrOrItem, pcInStrOrList)
		return @NXT(1, pStrOrItem, pcInStrOrList)

		func OneXT(pStrOrItem, pcInStrOrList)
			return @N(1, pStrOrItem, pcInStrOrList)

	func @2XT(pStrOrItem, pcInStrOrList)
		return @NXT(2, pStrOrItem, pcInStrOrList)

		func TwoXT(pStrOrItem, pcInStrOrList)
			return @NXT(2, pStrOrItem, pcInStrOrList)

	func @3XT(pStrOrItem, pcInStrOrList)
		return @NXT(3, pStrOrItem, pcInStrOrList)

		func ThreeXT(pStrOrItem, pcInStrOrList)
			return @NXT(3, pStrOrItem, pcInStrOrList)

	func @4XT(pStrOrItem, pcInStrOrList)
		return @NXT(4, pStrOrItem, pcInStrOrList)
	
		func FourXT(pStrOrItem, pcInStrOrList)
			return @NXT(4, pStrOrItem, pcInStrOrList)

	func @5XT(pStrOrItem, pcInStrOrList)
		return @NXT(5, pStrOrItem, pcInStrOrList)

		func FiveXT(pStrOrItem, pcInStrOrList)
			return @NXT(5, pStrOrItem, pcInStrOrList)

	func @6XT(pStrOrItem, pcInStrOrList)
		return @NXT(6, pStrOrItem, pcInStrOrList)

		func SixXT(pStrOrItem, pcInStrOrList)
			return @NXT(6, pStrOrItem, pcInStrOrList)

	func @7XT(pStrOrItem, pcInStrOrList)
		return @NXT(7, pStrOrItem, pcInStrOrList)

		func SevenXT(pStrOrItem, pcInStrOrList)
			return @NXT(7, pStrOrItem, pcInStrOrList)

	func @8XT(pStrOrItem, pcInStrOrList)
		return @NXT(8, pStrOrItem, pcInStrOrList)

		func EightXT(pStrOrItem, pcInStrOrList)
			return @NXT(8, pStrOrItem, pcInStrOrList)

	func @9XT(pStrOrItem, pcInStrOrList)
		return @NXT(9, pStrOrItem, pcInStrOrList)

		func NineXT(pStrOrItem, pcInStrOrList)
			return @NXT(9, pStrOrItem, pcInStrOrList)

	func @10XT(pStrOrItem, pcInStrOrList)
		return @NXT(10, pStrOrItem, pcInStrOrList)

		func TenXT(pStrOrItem, pcInStrOrList)
			return @NXT(10, pStrOrItem, pcInStrOrList)

	#>

#====== FUNCTIONS USEDS WITH OPERATORS OVERLOADED ON STZLIST

func Obj(pObject)
	# Used in the fellowing situation:
	# Used in case like:

	# ? Q([1, 2]) + AsObject( Q([3, 4]) )
	#--> [ [1,2], Q([3,4]) ]

	# ~> Q([3, 4]) which is is a stzList object is then added
	# to the Q([1, 3]) list as an object.

	# You will appreciate the role of this small function
	# when you write the same expression without it and
	# see the difference:

	# Q([1, 2]) + Q([3, 4])
	#--> A stzList object containing [ 1, 2, [ 3, 4 ] ]

	# To add an object and return a stzList, use AsObjectQ():

	# Q([1, 2]) + AsObjectQ( Q([3, 4]) )
	# A stzList object containing 
	
	# REMINDER

	# ? Q([1,2]) + [3, 4]
	#--> [ 1, 2, [ 3, 4 ] ]

	# ? Q([1, 2]) + These([3, 4])
	#--> [ 1, 2, 3, 4 ]

	# Q([1, 2]) + TheseQ([3, 4])
	#--> A stzList object containing [1, 2, 3, 4 ]

	if CheckingParams()
		if NOT isObject(pObject)
			StzRaise("Incorrect param type! pObject must be an object.")
		ok
	ok

	_bAsObject = 1
	_bAsObjectQ = 0

	return pObject

	# Must be reset to FALSE everytime These() is used.

	#< @FunctionAlternativeForms

	func AsObj(pObject)
		return Obj(pObject)

	func AsObject(pObject)
		return Obj(pObject)

	func O(pObject)
		return Obj(pObject)

	#>

func ObjQ(pObject)
	if CheckingParams()
		if NOT isObject(pObject)
			StzRaise("Incorrect param type! pObject must be an object.")
		ok
	ok

	_bAsObjectQ = 1
	_bAsObject = 0

	return pObject

	# Must be reset to FALSE everytime These() is used.

	#< @FunctionAlternativeForms

	func AsObjQ(pObject)
		return ObjQ(pObject)

	func AsObjectQ(pObject)
		return ObjQ(pObject)

	func OQ(pObject)
		return ObjQ(pObject)

	#>

func M(poStzObject)

	if CheckingParams()
		if NOT (isObject(poStzObject) and IsStzObject(poStzObject))
			StzRaise("Incorrect param type! poStzObject must be a Softanza object.")
		ok
	ok

	_bModifiable = 1
	return poStzObject

func These(p)

	# Used in the fellowing situation:
	#  ? Q([ 1, 2, "x", 3, "y" ]) - These([ "x", "y"]) #--> [ 1, 2, 3 ]

	# while not using These() and writing:
	#  ? Q([ 1, 2, "x", 3, "y" ]) - [ "x", "y"] #--> [ 1, 2, "x", 3, "y" ]

	# will not change any thing, because [ "x", "y" ] is treated as
	# a hole item of type list, not two items. The main list does not
	# contains an item like that, using the - operator has no effect.

	# In the contrary, if [ "x", "y" ] was existant, it will be removed:
	# ? Q([ 1, 2, ["x", "y"], 3 ]) - [ "x", "y"] #--> [ 1, 2, 3 ]

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	_bThese = 1
	_bTheseQ = 0

	return p
	# Must be reset to FALSE everytime These() is used.

	#< @FunctionAlternativeForms

	func EachOfThese(p)
		return These(p)

	func EachOneOfThese(p)
		return These(p)

	func EachItemOfThese(p)
		return These(p)

	func AllThese(p)
		return These(p)

	func AllOfThese(p)
		return These(p)

	#--

	func TheseItems(p)
		return These(p)

	func EachOfTheseItems(p)
		return These(p)

	func EachOneOfTheseItems(p)
		return These(p)

	func AllTheseItems(p)
		return These(p)

	func AllOfTheseItems(p)
		return These(p)

	#--

	func EachIn(p)
		return These(p)

	func EachItemIn(p)
		return These(p)

	#==

	func @These(p)
		return These(p)

	func @EachOfThese(p)
		return These(p)

	func @EachOneOfThese(p)
		return These(p)

	func @EachItemOfThese(p)
		return These(p)

	func @AllThese(p)
		return These(p)

	func @AllOfThese(p)
		return These(p)

	#--

	func @TheseItems(p)
		return These(p)

	func @EachOfTheseItems(p)
		return These(p)

	func @EachOneOfTheseItems(p)
		return These(p)

	func @AllTheseItems(p)
		return These(p)

	func @AllOfTheseItems(p)
		return These(p)

	#--

	func @EachIn(p)
		return These(p)

	func @EachItemIn(p)
		return These(p)

	#>

func TheseNumbers(p)
	_bThese = 1
	_bTheseQ = 0

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	nLen = len(p)
	anResult = []

	for i = 1 to nLen
		if isNumber(p[i])
			anResult + p[i]
		ok
	next

	return anResult
	# Must be reset to FALSE everytime TheseNumbers() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseNumbers(p)
		return TheseNumbers(p)

	func EachOneOfTheseNumbers(p)
		return TheseNumbers(p)

	func AllTheseNumbers(p)
		return TheseNumbers(p)

	func AllOfTheseNumbers(p)
		return TheseNumbers(p)


	#==

	func @TheseNumbers(p)
		return TheseNumbers()

	func @EachOfTheseNumbers(p)
		return TheseNumbers(p)

	func @EachOneOfTheseNumbers(p)
		return TheseNumbers(p)

	func @AllTheseNumbers(p)
		return TheseNumbers(p)

	func @AllOfTheseNumbers(p)
		return TheseNumbers(p)

	#>

func TheseChars(p)
	_bThese = 1
	_bTheseQ = 0

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	nLen = len(p)
	acResult = []

	for i = 1 to nLen
		if isString(p[i])
			acResult + p[i]
		ok
	next

	return acResult
	# Must be reset to FALSE everytime TheseChars() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseChars(p)
		return TheseChars(p)

	func EachOneOfTheseChars(p)
		return TheseChars(p)

	func AllTheseChars(p)
		return TheseChars(p)

	func AllOfTheseChars(p)
		return TheseChars(p)


	#==

	func @TheseChars(p)
		return TheseChars()

	func @EachOfTheseChars(p)
		return TheseChars(p)

	func @EachOneOfTheseChars(p)
		return TheseChars(p)

	func @AllTheseChars(p)
		return TheseChars(p)

	func @AllOfTheseChars(p)
		return TheseChars(p)

	#>

func TheseStrings(p)
	_bThese = 1
	_bTheseQ = 0

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	nLen = len(p)
	acResult = []

	for i = 1 to nLen
		if isString(p[i])
			acResult + p[i]
		ok
	next

	return acResult
	# Must be reset to FALSE everytime TheseStrings() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseStrings(p)
		return TheseStrings(p)

	func EachOneOfTheseStrings(p)
		return TheseStrings(p)

	func AllTheseStrings(p)
		return TheseStrings(p)

	func AllOfTheseStrings(p)
		return TheseStrings(p)


	#==

	func @TheseStrings(p)
		return TheseStrings()

	func @EachOfTheseStrings(p)
		return TheseStrings(p)

	func @EachOneOfTheseStrings(p)
		return TheseStrings(p)

	func @AllTheseStrings(p)
		return TheseStrings(p)

	func @AllOfTheseStrings(p)
		return TheseStrings(p)

	#>

func TheseLists(p)
	_bThese = 1
	_bTheseQ = 0

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	nLen = len(p)
	aResult = []

	for i = 1 to nLen
		if isString(p[i])
			aResult + p[i]
		ok
	next

	return aResult
	# Must be reset to FALSE everytime TheseLists() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseLists(p)
		return TheseLists(p)

	func EachOneOfTheseLists(p)
		return TheseLists(p)

	func AllTheseLists(p)
		return TheseLists(p)

	func AllOfTheseLists(p)
		return TheseLists(p)


	#==

	func @TheseLists(p)
		return TheseLists()

	func @EachOfTheseLists(p)
		return TheseLists(p)

	func @EachOneOfTheseLists(p)
		return TheseLists(p)

	func @AllTheseLists(p)
		return TheseLists(p)

	func @AllOfTheseLists(p)
		return TheseLists(p)

	#>

func TheseObjects(p)
	_bThese = 1
	_bTheseQ = 0

	if CheckingParams()
		if NOT isObject(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i])
			aoResult + p[i]
		ok
	next

	return aoResult
	# Must be reset to FALSE everytime TheseObjects() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseObjects(p)
		return TheseObjects(p)

	func EachOneOfTheseObjects(p)
		return TheseObjects(p)

	func AllTheseObjects(p)
		return TheseObjects(p)

	func AllOfTheseObjects(p)
		return TheseObjects(p)


	#==

	func @TheseObjects(p)
		return TheseObjects()

	func @EachOfTheseObjects(p)
		return TheseObjects(p)

	func @EachOneOfTheseObjects(p)
		return TheseObjects(p)

	func @AllTheseObjects(p)
		return TheseObjects(p)

	func @AllOfTheseObjects(p)
		return TheseObjects(p)

	#>

#--

func TheseStzNumbers(p)
	_bThese = 1
	_bTheseQ = 0

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzNumber(p[i])
			aoResult + p[i]
		ok
	next

	return aoResult
	# Must be reset to FALSE everytime TheseStzNumbers() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseStzNumbers(p)
		return TheseStzNumbers(p)

	func EachOneOfTheseStzNumbers(p)
		return TheseStzNumbers(p)

	func AllTheseStzNumbers(p)
		return TheseStzNumbers(p)

	func AllOfTheseStzNumbers(p)
		return TheseStzNumbers(p)


	#==

	func @TheseStzNumbers(p)
		return TheseStzNumbers()

	func @EachOfTheseStzNumbers(p)
		return TheseStzNumbers(p)

	func @EachOneOfTheseStzNumbers(p)
		return TheseStzNumbers(p)

	func @AllTheseStzNumbers(p)
		return TheseStzNumbers(p)

	func @AllOfTheseStzNumbers(p)
		return TheseStzNumbers(p)

	#>

func TheseStzChars(p)
	_bThese = 1
	_bTheseQ = 0

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzChar(p[i])
			aoResult + p[i]
		ok
	next

	return aoResult
	# Must be reset to FALSE everytime TheseStzChars() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseStzChars(p)
		return TheseStzChars(p)

	func EachOneOfTheseStzChars(p)
		return TheseStzChars(p)

	func AllTheseStzChars(p)
		return TheseStzChars(p)

	func AllOfTheseStzChars(p)
		return TheseStzChars(p)


	#==

	func @TheseStzChars(p)
		return TheseStzChars()

	func @EachOfTheseStzChars(p)
		return TheseStzChars(p)

	func @EachOneOfTheseStzChars(p)
		return TheseStzChars(p)

	func @AllTheseStzChars(p)
		return TheseStzChars(p)

	func @AllOfTheseStzChars(p)
		return TheseStzChars(p)

	#>

func TheseStzStrings(p)
	_bThese = 1
	_bTheseQ = 0

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzString(p[i])
			aoResult + p[i]
		ok
	next

	return aoResult
	# Must be reset to FALSE everytime TheseStzStrings() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseStzStrings(p)
		return TheseStzStrings(p)

	func EachOneOfTheseStzStrings(p)
		return TheseStzStrings(p)

	func AllTheseStzStrings(p)
		return TheseStzStrings(p)

	func AllOfTheseStzStrings(p)
		return TheseStzStrings(p)


	#==

	func @TheseStzStrings(p)
		return TheseStzStrings()

	func @EachOfTheseStzStrings(p)
		return TheseStzStrings(p)

	func @EachOneOfTheseStzStrings(p)
		return TheseStzStrings(p)

	func @AllTheseStzStrings(p)
		return TheseStzStrings(p)

	func @AllOfTheseStzStrings(p)
		return TheseStzStrings(p)

	#>

func TheseStzLists(p)
	_bThese = 1
	_bTheseQ = 0

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzList(p[i])
			aoResult + p[i]
		ok
	next

	return aoResult
	# Must be reset to FALSE everytime TheseStzLists() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseStzLists(p)
		return TheseStzLists(p)

	func EachOneOfTheseStzLists(p)
		return TheseStzLists(p)

	func AllTheseStzLists(p)
		return TheseStzLists(p)

	func AllOfTheseStzLists(p)
		return TheseStzLists(p)


	#==

	func @TheseStzLists(p)
		return TheseStzLists()

	func @EachOfTheseStzLists(p)
		return TheseStzLists(p)

	func @EachOneOfTheseStzLists(p)
		return TheseStzLists(p)

	func @AllTheseStzLists(p)
		return TheseStzLists(p)

	func @AllOfTheseStzLists(p)
		return TheseStzLists(p)

	#>

func TheseStzObjects(p)
	_bThese = 1
	_bTheseQ = 0

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzObject(p[i])
			aoResult + p[i]
		ok
	next

	return aoResult
	# Must be reset to FALSE everytime TheseStzObjects() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseStzObjects(p)
		return TheseStzObjects(p)

	func EachOneOfTheseStzObjects(p)
		return TheseStzObjects(p)

	func AllTheseStzObjects(p)
		return TheseStzObjects(p)

	func AllOfTheseStzObjects(p)
		return TheseStzObjects(p)


	#==

	func @TheseStzObjects(p)
		return TheseStzObjects()

	func @EachOfTheseStzObjects(p)
		return TheseStzObjects(p)

	func @EachOneOfTheseStzObjects(p)
		return TheseStzObjects(p)

	func @AllTheseStzObjects(p)
		return TheseStzObjects(p)

	func @AllOfTheseStzObjects(p)
		return TheseStzObjects(p)

	#>

#---

func TheseQ(p)

	# Used in the fellowing situation:
	#  ? Q([ 1, 2, "x", 3, "y" ]) - TheseQ([ "x", "y"]) #--> Q([ 1, 2, 3 ])

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	_bTheseQ = 1
	_bThese = 0

	return p
	# _bTheseQ Must be reset to FALSE everytime These() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseQ(p)
		return TheseQ(p)

	func EachOneOfTheseQ(p)
		return TheseQ(p)

	func EachItemOfTheseQ(p)
		return TheseQ(p)

	func AllTheseQ(p)
		return TheseQ(p)

	func AllOfTheseQ(p)
		return TheseQ(p)

	#--

	func TheseItemsQ(p)
		return TheseQ(p)

	func EachOfTheseItemsQ(p)
		return TheseQ(p)

	func EachOneOfTheseItemsQ(p)
		return TheseQ(p)

	func AllTheseItemsQ(p)
		return TheseQ(p)

	func AllOfTheseItemsQ(p)
		return TheseQ(p)

	#--

	func EachInQ(p)
		return TheseQ(p)

	func EachItemInQ(p)
		return TheseQ(p)

	#==

	func @TheseQ(p)
		return TheseQ(p)

	func @EachOfTheseQ(p)
		return TheseQ(p)

	func @EachOneOfTheseQ(p)
		return TheseQ(p)

	func @EachItemOfTheseQ(p)
		return TheseQ(p)

	func @AllTheseQ(p)
		return TheseQ(p)

	func @AllOfTheseQ(p)
		return TheseQ(p)

	#--

	func @TheseItemsQ(p)
		return TheseQ(p)

	func @EachOfTheseItemsQ(p)
		return TheseQ(p)

	func @EachOneOfTheseItemsQ(p)
		return TheseQ(p)

	func @AllTheseItemsQ(p)
		return TheseQ(p)

	func @AllOfTheseItemsQ(p)
		return TheseQ(p)

	#--

	func @EachInQ(p)
		return TheseQ(p)

	func @EachItemInQ(p)
		return TheseQ(p)

	#>

func TheseNumbersQ(p)
	
	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	_bTheseQ = 1
	_bThese = 0

	nLen = len(p)
	anResult = []

	for i = 1 to nLen
		if isNumber(p[i])
			anResult + p[i]
		ok
	next

	return new stzListOfNumbers(anResult)
	# _bTheseQ Must be reset to FALSE everytime TheseNumbers() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseNumbersQ(p)
		return TheseNumbersQ(p)

	func EachOneOfTheseNumbersQ(p)
		return TheseNumbersQ(p)

	func AllTheseNumbersQ(p)
		return TheseNumbersQ(p)

	func AllOfTheseNumbersQ(p)
		return TheseNumbersQ(p)

	#==

	func @TheseNumbersQ(p)
		return TheseNumbersQ()

	func @EachOfTheseNumbersQ(p)
		return TheseNumbersQ(p)

	func @EachOneOfTheseNumbersQ(p)
		return TheseNumbersQ(p)

	func @AllTheseNumbersQ(p)
		return TheseNumbersQ(p)

	func @AllOfTheseNumbersQ(p)
		return TheseNumbersQ(p)

	#>

func TheseCharsQ(p)
	
	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	_bTheseQ = 1
	_bThese = 0

	nLen = len(p)
	acResult = []

	for i = 1 to nLen
		if isString(p[i])
			acResult + p[i]
		ok
	next

	return new stzListOfChars(acResult)
	# _bTheseQ Must be reset to FALSE everytime TheseChars() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseCharsQ(p)
		return TheseCharsQ(p)

	func EachOneOfTheseCharsQ(p)
		return TheseCharsQ(p)

	func AllTheseCharsQ(p)
		return TheseCharsQ(p)

	func AllOfTheseCharsQ(p)
		return TheseCharsQ(p)

	#==

	func @TheseCharsQ(p)
		return TheseCharsQ()

	func @EachOfTheseCharsQ(p)
		return TheseCharsQ(p)

	func @EachOneOfTheseCharsQ(p)
		return TheseCharsQ(p)

	func @AllTheseCharsQ(p)
		return TheseCharsQ(p)

	func @AllOfTheseCharsQ(p)
		return TheseCharsQ(p)

	#>

func TheseStringsQ(p)
	
	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	_bTheseQ = 1
	_bThese = 0

	nLen = len(p)
	acResult = []

	for i = 1 to nLen
		if isString(p[i])
			acResult + p[i]
		ok
	next

	return new stzListOfStrings(acResult)
	# _bTheseQ Must be reset to FALSE everytime TheseStrings() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseStringsQ(p)
		return TheseStringsQ(p)

	func EachOneOfTheseStringsQ(p)
		return TheseStringsQ(p)

	func AllTheseStringsQ(p)
		return TheseStringsQ(p)

	func AllOfTheseStringsQ(p)
		return TheseStringsQ(p)

	#==

	func @TheseStringsQ(p)
		return TheseStringsQ()

	func @EachOfTheseStringsQ(p)
		return TheseStringsQ(p)

	func @EachOneOfTheseStringsQ(p)
		return TheseStringsQ(p)

	func @AllTheseStringsQ(p)
		return TheseStringsQ(p)

	func @AllOfTheseStringsQ(p)
		return TheseStringsQ(p)

	#>

func TheseListsQ(p)
	
	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	_bTheseQ = 1
	_bThese = 0

	nLen = len(p)
	aResult = []

	for i = 1 to nLen
		if isString(p[i])
			aResult + p[i]
		ok
	next

	return new stzListOfLists(aResult)
	# _bTheseQ Must be reset to FALSE everytime TheseLists() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseListsQ(p)
		return TheseListsQ(p)

	func EachOneOfTheseListsQ(p)
		return TheseListsQ(p)

	func AllTheseListsQ(p)
		return TheseListsQ(p)

	func AllOfTheseListsQ(p)
		return TheseListsQ(p)

	#==

	func @TheseListsQ(p)
		return TheseListsQ()

	func @EachOfTheseListsQ(p)
		return TheseListsQ(p)

	func @EachOneOfTheseListsQ(p)
		return TheseListsQ(p)

	func @AllTheseListsQ(p)
		return TheseListsQ(p)

	func @AllOfTheseListsQ(p)
		return TheseListsQ(p)

	#>

func TheseObjectsQ(p)
	
	if CheckingParams()
		if NOT isObject(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	_bTheseQ = 1
	_bThese = 0

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i])
			aoResult + p[i]
		ok
	next

	return new stzListOfObjects(aoResult)
	# _bTheseQ Must be reset to FALSE everytime TheseObjects() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseObjectsQ(p)
		return TheseObjectsQ(p)

	func EachOneOfTheseObjectsQ(p)
		return TheseObjectsQ(p)

	func AllTheseObjectsQ(p)
		return TheseObjectsQ(p)

	func AllOfTheseObjectsQ(p)
		return TheseObjectsQ(p)

	#==

	func @TheseObjectsQ(p)
		return TheseObjectsQ()

	func @EachOfTheseObjectsQ(p)
		return TheseObjectsQ(p)

	func @EachOneOfTheseObjectsQ(p)
		return TheseObjectsQ(p)

	func @AllTheseObjectsQ(p)
		return TheseObjectsQ(p)

	func @AllOfTheseObjectsQ(p)
		return TheseObjectsQ(p)

	#>

func TheseStzNumbersQ(p)

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	_bTheseQ = 1
	_bThese = 0

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzNumber(p[i])
			aoResult + p[i]
		ok
	next

	return new stzListOfNumbers(aoResult)
	# _bTheseQ Must be reset to FALSE everytime TheseStzNumbers() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseStzNumbersQ(p)
		return TheseStzNumbersQ(p)

	func EachOneOfTheseStzNumbersQ(p)
		return TheseStzNumbersQ(p)

	func AllTheseStzNumbersQ(p)
		return TheseStzNumbersQ(p)

	func AllOfTheseStzNumbersQ(p)
		return TheseStzNumbersQ(p)

	#==

	func @TheseStzNumbersQ(p)
		return TheseStzNumbersQ()

	func @EachOfTheseStzNumbersQ(p)
		return TheseStzNumbers(p)

	func @EachOneOfTheseStzNumbersQ(p)
		return TheseStzNumbersQ(p)

	func @AllTheseStzNumbersQ(p)
		return TheseStzNumbersQ(p)

	func @AllOfTheseStzNumbersQ(p)
		return TheseStzNumbersQ(p)

	#>

func TheseStzCharsQ(p)

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	_bTheseQ = 1
	_bThese = 0

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzChar(p[i])
			aoResult + p[i]
		ok
	next

	return aoResult
	# _bTheseQ Must be reset to FALSE everytime TheseStzChars() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseStzCharsQ(p)
		return TheseStzCharsQ(p)

	func EachOneOfTheseStzCharsQ(p)
		return TheseStzCharsQ(p)

	func AllTheseStzCharsQ(p)
		return TheseStzCharsQ(p)

	func AllOfTheseStzCharsQ(p)
		return TheseStzCharsQ(p)

	#==

	func @TheseStzCharsQ(p)
		return TheseStzCharsQ()

	func @EachOfTheseStzCharsQ(p)
		return TheseStzCharsQ(p)

	func @EachOneOfTheseStzCharsQ(p)
		return TheseStzCharsQ(p)

	func @AllTheseStzCharsQ(p)
		return TheseStzCharsQ(p)

	func @AllOfTheseStzCharsQ(p)
		return TheseStzCharsQ(p)

	#>

func TheseStzStringsQ(p)
	
	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	_bTheseQ = 1
	_bThese = 0

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzString(p[i])
			aoResult + p[i]
		ok
	next

	return new stzListOfStrings(aoResult)
	# Must be reset to FALSE everytime TheseStzStrings() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseStzStringsQ(p)
		return TheseStzStringsQ(p)

	func EachOneOfTheseStzStringsQ(p)
		return TheseStzStringsQ(p)

	func AllTheseStzStringsQ(p)
		return TheseStzStringsQ(p)

	func AllOfTheseStzStringsQ(p)
		return TheseStzStringsQ(p)

	#==

	func @TheseStzStringsQ(p)
		return TheseStzStringsQ()

	func @EachOfTheseStzStringsQ(p)
		return TheseStzStringsQ(p)

	func @EachOneOfTheseStzStringsQ(p)
		return TheseStzStringsQ(p)

	func @AllTheseStzStringsQ(p)
		return TheseStzStringsQ(p)

	func @AllOfTheseStzStringsQ(p)
		return TheseStzStringsQ(p)

	#>

func TheseStzListsQ(p)

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	_bTheseQ = 1
	_bThese = 0

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzList(p[i])
			aoResult + p[i]
		ok
	next

	return new stzListOfLists(aoResult)
	# _bTheseQ Must be reset to FALSE everytime TheseStzLists() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseStzListsQ(p)
		return TheseStzListsQ(p)

	func EachOneOfTheseStzListsQ(p)
		return TheseStzListsQ(p)

	func AllTheseStzListsQ(p)
		return TheseStzListsQ(p)

	func AllOfTheseStzListsQ(p)
		return TheseStzListsQ(p)

	#==

	func @TheseStzListsQ(p)
		return TheseStzListsQ()

	func @EachOfTheseStzListsQ(p)
		return TheseStzListsQ(p)

	func @EachOneOfTheseStzListsQ(p)
		return TheseStzListsQ(p)

	func @AllTheseStzListsQ(p)
		return TheseStzListsQ(p)

	func @AllOfTheseStzListsQ(p)
		return TheseStzListsQ(p)

	#>

func TheseStzObjectsQ(p)

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	_bTheseQ = 1
	_bThese = 0

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzObject(p[i])
			aoResult + p[i]
		ok
	next

	return new stzListOfObjects(aoResult)
	# _bTheseQ = 1 must be reset to FALSE everytime TheseStzObjects() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseStzObjectsQ(p)
		return TheseStzObjectsQ(p)

	func EachOneOfTheseStzObjectsQ(p)
		return TheseStzObjectsQ(p)

	func AllTheseStzObjectsQ(p)
		return TheseStzObjectsQ(p)

	func AllOfTheseStzObjectsQ(p)
		return TheseStzObjectsQ(p)


	#==

	func @TheseStzObjectsQ(p)
		return TheseStzObjectsQ()

	func @EachOfTheseStzObjectsQ(p)
		return TheseStzObjectsQ(p)

	func @EachOneOfTheseStzObjectsQ(p)
		return TheseStzObjectsQ(p)

	func @AllTheseStzObjectsQ(p)
		return TheseStzObjectsQ(p)

	func @AllOfTheseStzObjectsQ(p)
		return TheseStzObjectsQ(p)

	#>


#===

func @ForEach(p, pIn)
	/* EXAMPLES

	@ForEach( :Item, :In = [ "a", "b", "c" ] ) { X('
		? v(:Item)
	') }
	#--> "a"
	#--> "b"
	#--> "c"

	? ""

	@ForEach( :Char, :In = "ABC" ) { X('
		? v(:Char)
	') }
	#--> "A"
	#--> "B"
	#--> "C"

	? ""

	@ForEach( [ :Char, :Number ], :In = [ [ "A", 1 ], [ "B", 2 ], [ "C", 3 ] ] ) { X('
		? v(:Char) + v(:Number)
	') }
	#--> "A1"
	#--> "B2"
	#--> "C3'

	*/

	return new stzForEachObject(p, pIn)
	

# Setting the param checking state at the global level
# --> Useful to decativate it when your functions are used
# in large loops where performance gains are criticial!
# --> In this case, you deactivate param checking inside
# functions, and if you need it, do it by yourself outside teh loop/

	#< @FunctionAlternatives

	func SetCheckParamTo(bTrueOrFalse)
		SetParamCheckingTo(bTrueOrFalse)

	func SetCheckingParamTo(bTrueOrFalse)
		SetParamCheckingTo(bTrueOrFalse)

	#--

	func SetParamsCheckTo(bTrueOrFalse)
		SetParamCheckingTo(bTrueOrFalse)

	func SetParamsCheckingTo(bTrueOrFalse)
		SetParamCheckingTo(bTrueOrFalse)
 
	func SetCheckParamsTo(bTrueOrFalse)
		SetParamCheckingTo(bTrueOrFalse)

	func SetCheckingParamsTo(bTrueOrFalse)
		SetParamCheckingTo(bTrueOrFalse)

	#==

	func SetParamChecking(bTrueOrFalse)
		if isList(bTrueOrFalse) and Q(bTrueOrFalse).IsToNamedParam()
			bTrueOrFalse = bTrueOrFalse[2]
		ok

		SetParamCheckingTo(bTrueOrFalse)

	func SetCheckParam(bTrueOrFalse)
		SetParamChecking(bTrueOrFalse)

	func SetCheckingParam(bTrueOrFalse)
		SetParamChecking(bTrueOrFalse)

	#--

	func SetParamsCheck(bTrueOrFalse)
		SetParamChecking(bTrueOrFalse)

	func SetParamsChecking(bTrueOrFalse)
		SetParamCheckingTo(bTrueOrFalse)
 
	func SetCheckParams(bTrueOrFalse)
		SetParamChecking(bTrueOrFalse)

	func SetCheckingParams(bTrueOrFalse)
		SetParamChecking(bTrueOrFalse)

	#>

func StzActivateParamChecking()
	_bParamCheck = 1

	func ActivateParamChecking()
		StzActivateParamChecking()

	func ActivateParamCheck()
		StzActivateParamChecking()

	func ActivateParamsChecking()
		ActivateParamChecking()

	func ActivateParamsCheck()
		ActivateParamChecking()

	#--

	func EnableParamCheck()
		DesactivateParamChecking()

	func EnableParamsChecking()
		DesactivateParamChecking()

	func EnableParamsCheck()
		DesactivateParamChecking()

	#--

	func CheckParamOn()
		ActivateParamChecking()

	func ParamCheckOn()
		ActivateParamChecking()

	func CheckParamsOn()
		ActivateParamChecking()

	func ParamsCheckOn()
		ActivateParamChecking()

	#>

func StzDesactivateParamChecking()
	_bParamCheck = 0

	func DesactivateParamChecking()
		StzDesactivateParamChecking()

	#< @FunctionAlternativeForms

	func DesactivateParamCheck()
		DesactivateParamChecking()

	func DeasctivateParamsChecking()
		DesactivateParamChecking()

	func DesactivateParamsCheck()
		DesactivateParamChecking()

	#--

	func DisableParamCheck()
		DesactivateParamChecking()

	func DisableParamsChecking()
		DesactivateParamChecking()

	func DisableParamsCheck()
		DesactivateParamChecking()

	#--

	func CheckParamOff()
		DesactivateParamChecking()

	func ParamCheckOff()
		DesactivateParamChecking()

	func CheckParamsOff()
		DesactivateParamChecking()

	func ParamsCheckOff()
		DesactivateParamChecking()

	#>

func StzParamChecking()
	return _bParamCheck

	func ParamChecking()
		return StzParamChecking()

	#< @FunctionAlternativeForms

	func ParamsChecking()
		return _bParamCheck

	func ParamCheck()
		return _bParamCheck

	func ParamsCheck()
		return _bParamCheck

	# NOTE: CheckParam(pValue, p2, p3) is defined in stznamedparams_engine.ring
	# The 0-arg alias was removed to avoid Ring's redefinition error.

	func CheckingParam()
		return _bParamCheck

	func CheckParams()
		return _bParamCheck

	#>

	#< @FunctionMisspelledForms
	# Forgetting the "c" in "Check"

	func ParamCheking()
		return _bParamCheck

	func ParamsCheking()
		return _bParamCheck

	func ParamChek()
		return _bParamCheck

	func ParamsChek()
		return _bParamCheck

	func ChekParam()
		return _bParamCheck

	func ChekingParam()
		return _bParamCheck

	func ChekParams()
		return _bParamCheck

	func ChekingParams()
		return _bParamCheck

	func ChekcParams()
		return _bParamCheck

	#>

#--

func StzEarlyCheck()
	return _bEarlyCheck

	func EarlyCheck()
		return StzEarlyCheck()

	func EarlyChecks()
		return StzEarlyCheck()

func StzEarlyCheckOn()
	_bEarlyCheck = 1

	func EarlyCheckOn()
		StzEarlyCheckOn()

	func ActivateEarlyCheck()
		_bEarlyCheck = 1

	func EarlyChecksOn()
		_bEarlyCheck = 1

	func ActivateEarlyChecks()
		_bEarlyCheck = 1

func StzEarlyCheckOff()
	_bEarlyCheck = 0

	func EarlyCheckOff()
		StzEarlyCheckOff()

	func DeactivateEarlyCheck()
		StzEarlyCheckOff()

	func EarlyChecksOff()
		StzEarlyCheckOff()

	func DectivateEarlyChecks()
		StzEarlyCheckOff()

func StzSetEarlyCheck(b)
	if CheckingParams()
		if NOT (isNumber(b) and (b = 0 or b = 1) )
			StzRaise("Incorrect param! b must be a boolean (1 or FALSE).")
		ok
	ok

	_bEarlyCheck = b

	func SetEarlyCheck(b)
		StzSetEarlyCheck(b)

	func SetEarlyCheckTo(b)
		StzSetEarlyCheck(b)

	func SetEarlyChecks(b)
		StzSetEarlyCheck(b)

	func SetEarlyChecksTo(b)
		StzSetEarlyCheck(b)

#--

func StzStartingAt(p)
	if isNumber(p)
		return p

	but isString(p)
		p = StzLower(p)

		if p = :first
			return 1

		but p = :Last
			// do nothing

		else
			StzRaise("Incorrect param type! p, when it is a string, must be a equal to :First or :Last").
		ok

	but isList(p)
		if len(p) = 2 and Q(p).IsStartingAtNamedParam()
			return p[2]

		else
			StzRaise("Incorrect param! p, when it is a list, must be a named param of the form :StartingAt = number.")
		ok
	ok

	StzRaise("Incorrect param type! p must be string or a list containing a named param.")

	func StartingAt(p)
		return StzStartingAt(p)

	func @StartingAt(p)
		return StzStartingAt(p)

func StzStoppingAt(p)
	if isNumber(p)
		return p

	but isString(p)
		p = StzLower(p)

		if p = :first
			return 1

		but p = :Last
			// do nothing

		else
			StzRaise("Incorrect param type! p, when it is a string, must be a equal to :First or :Last").
		ok

	but isList(p)
		if len(p) = 2 and Q(p).IsStoppingAtNamedParam()
			return p[2]

		else
			StzRaise("Incorrect param! p, when it is a list, must be a named param of the form :StoppingAt = number.")
		ok
	ok

	StzRaise("Incorrect param type! p must be string or a list containing a named param.")

	func StoppingAt(p)
		return StzStoppingAt(p)

	func @StoppingAt(p)
		return StzStoppingAt(p)

	func EndingAt(p)
		return StzStoppingAt(p)

	func @EndingAt(p)
		return StzStoppingAt(p)

#==

func StzBounds(pBounds)

	if NOT ( isString(pBounds) or ( isList(pBounds) and len(pBounds) = 2 and isString(pBounds[1]) ) )
			StzRaise("Incorrect param type! pBounds must be a string or a list of two strings.")
	ok

	if isString(pBounds)
		return [ pBounds, pBounds ]
	ok

	# Now, pBounds is a list of two items where 1st item is a string

	p1 = pBounds[1]
	p2 = pBounds[2]

	if isList(p2) and IsAndNamedParamList(p2)
		p2 = p2[2]
	ok

	if NOT isString(p2)
		StzRaise("Incorrect param type! The second item of pBounds must be also a string.")
	ok

	return [ p1, p2 ]

	func Bounds(pBounds)
		return StzBounds(pBounds)

	func @Bounds(pBounds)
		return StzBounds(pBounds)

#--

func StzDirection(p)
	if isString(p)

		p = StzLower(p)

		if p = :Forward or p = :Backward
			return p

		else
			StzRaise("Incorrect param! p must be a string containing :Forward or :Backward.")
		ok

	but isList(p)
		if len(p) = 2 and Q(p).IsDirectionOrGoingNamedParam()
			return p[2]

		else
			StzRaise("Incorrect param! p must be a named param containing :Forward or :Backward.")
		ok

	ok

	StzRaise("Incorrect param type! p must be string or a list containing a named param.")

	func Direction(p)
		return StzDirection(p)

	func @Direction(p)
		return StzDirection(p)
	
#--


func StzIsCaseSensitive(p)

	if (isNumber(p) and p = 1) or
	   (isList(p) and Q(p).IsCaseSensitiveNamedParam() and p[2] = 1)

		return 1

	but (isNumber(p) and p = 0) or
	   (isList(p) and Q(p).IsCaseSensitiveNamedParam() and p[2] = 0)

		return 0

	else
		StzRaise("Incorrect param! p must be 1 or FALSE.")
	ok

	func IsCaseSensitive(p)
		return StzIsCaseSensitive(p)

	func @IsCaseSensitive(p)
		return StzIsCaseSensitive(p)

func StzCaseSensitive(p)

	if isNumber(p)
		if p = 1
			return 1
		but p = 0
			return 0
		ok

	but isList(p) and IsCaseSensitiveNamedParamList(p)
		p = p[2]

		if isNumber(p)
			if p = 1
				return 1
			but p = 0
				return 0
			ok
		ok

	else
		StzRaise("Incorrect param type! p must be a bolean (1 or FALSE).")
	ok

	func CaseSensitive(p)
		return StzCaseSensitive(p)

	func @CaseSensitive(p)
		return StzCaseSensitive(p)

#--

func StzKeywords()
	return _acStzCCKeywords

	func StzCCodeKeywords()
		return StzKeywords()

	func StzConditionalCodeKeywords()
		return StzKeywords()

func StzASpace()
	return StzNSpaces(1)

	func ASpace()
		return StzASpace()

	func SingleSpace()
		return StzASpace()

	func BlankSpace()
		return StzASpace()

	func OneSpace()
		return StzASpace()

func StzDoubleSpace()
	return StzNSpaces(2)

	func DoubleSpace()
		return StzDoubleSpace()

	func DoubleBlankSpace()
		return StzDoubleSpace()

func StzNSpaces(n)
	return copy(" ", n)

	func NSpaces(n)
		return StzNSpaces(n)

	def NBlankSpaces(n)
		return StzNSpaces(n)

func StzQuietEqualityRatio()
	return _nQuietEqualityRatio

	func QuietEqualityRatio()
		return StzQuietEqualityRatio()

	func ApproximateEqualityRatio()
		return StzQuietEqualityRatio()

	func ApproximativeEqualityRatio()
		return StzQuietEqualityRatio()

func StzSetQuietEqualityRatio(n)
	if NOT isNumber(n)
		StzRaise("Incorrect param type! n must be a number.")
	ok

	if n >= 0 and n <= 1
		_nQuietEqualityRatio = n
	ok

	func SetQuietEqualityRatio(n)
		StzSetQuietEqualityRatio(n)

	def SetApproximateEqualityRatio(n)
		StzSetQuietEqualityRatio(n)

	def SetApproximativeEqualityRation(n)
		StzSetQuietEqualityRatio(n)

func StzRingTypes()
	return _aRingTypes

	func RingTypes()
		return StzRingTypes()

func StzRingFunctions()
	return _acRingFunctions

	func RingFunctions()
		return StzRingFunctions()

func StzRingKeywords()
	return _acRingKeywords()

	func RingKeywords()
		return StzRingKeywords()

func StzRaise(paMessage)
	/*
	WARNING: Do not use StzRaise to raise errors here
	--> Stackoverflow!

	Hence, this is the unique place in the library
	where we use the native ring raise() function.

	*/

	if NOT ( isString(paMessage) or isList(paMessage) )

		raise("Error in StzRaise param type!" + NL)
	ok

	if isString(paMessage)
		raise(paMessage + NL)
	ok

	if isList(paMessage) and IsRaiseNamedParamList(paMessage)
		cWhere = paMessage[ :Where  ]
		cWhat  = paMessage[ :What   ]
		cWhy   = paMessage[ :Why    ]
		cTodo  = paMessage[ :Todo   ]

	

		if NOT IsListOfStrings([ cWhere, cWhat, cWhy, cTodo ])
			raise("Error in StzRaise param type!")
		ok
	
		cFile = StzReplace(cWhere, " ", "")
		if isNull(cWhere)
			raise("Error in StzRaise --> Where the error happened!")
		ok
	
		cWhat = StringSimplified(cWhat)
		cwhay = StringSimplified(cWhy)
		cTodo = StringSimplified(cTodo)
	
		cErrorMsg = "in file " + paMessage[:Where] + ":" + NL
	
		if cWhat != ""
			cErrorMsg += "   What : " + paMessage[:What] + NL
		ok
	
		if cWhy != ""
			cErrorMsg += "   Why  : " + paMessage[:Why]  + NL
		ok
	
		if cTodo != ""
			cErrorMsg += "   Todo : " + paMessage[:Todo] + NL
		ok

		raise(cErrorMsg)
	else
		raise("Error in StzRaise > Incorrect param type!")
	ok

	#< @FunctionMisspelledForm >

	func StzRais(paMessage)
		return StzRaise(paMessage)

	func SzRaise(paMessage)
		return StzRaise(paMessage)

	#>

#-----

func StzIsClassName(cStr)
	if CheckingParams()
		if NOT isString(cStr)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok
	ok

	bResult = find( ClassesNames(), cStr)
	return bResult

	func IsClassName(cStr)
		return StzIsClassName(cStr)

	func @IsClassName(pcStr)
		return StzIsClassName(pcStr)

	func IsAClassName(pcStr)
		return StzIsClassName(pcStr)

func StzIsPackageName(cStr)
	if CheckingParams()
		if NOT isString(cStr)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok
	ok

	bResult = find( packages(), StzLower(cStr))
	return bResult

	func IsPackageName(cStr)
		return StzIsPackageName(cStr)

	func @IsPackageName(cStr)
		return StzIsPackageName(cStr)

	func IsAPackageName(cStr)
		return StzIsPackageName(cStr)

	func @IsAPackageName(cStr)
		return StzIsPackageName(cStr)


func StzVars()
	return globals()

	func Vars()
		return StzVars()

#----

func StzFindCS(pThing, paIn, pCaseSensitive)
	if isList(paIn) and Q(paIn).IsInNamedParam()
		paIn = paIn[2]
	ok

	anPos = Q(paIn).FindAllCS(pThing, pCaseSensitive)
	return anPos

func StzFind(p1, p2)
	# Named param support: StzFind(x, [:in, list])
	if isList(p2) and len(p2) = 2 and isString(p2[1]) and p2[1] = :in
		p2 = p2[2]
	ok

	# Case 1: p2 is a list -> find p1 in p2
	if isList(p2)
		_nSfLen_ = len(p2)
		for _nSfI_ = 1 to _nSfLen_
			if p2[_nSfI_] = p1
				return _nSfI_
			ok
		next
		return 0
	ok

	# Case 2: p1 is a list -> find p2 in p1 (backward compat with stzGraph etc.)
	if isList(p1)
		_nSfLen_ = len(p1)
		for _nSfI_ = 1 to _nSfLen_
			if p1[_nSfI_] = p2
				return _nSfI_
			ok
		next
		return 0
	ok

	# Case 3: Both strings -> find p2 as substring in p1
	if isString(p1) and isString(p2)
		_pSfH_ = StzEngineString(p1)
		_nSfPos_ = StzEngineStringFindFirstFromCS(_pSfH_, p2, 1, 1)
		StzEngineStringFree(_pSfH_)
		if _nSfPos_ > 0
			return _nSfPos_
		ok
		return 0
	ok

	return 0

#-----

func StzIsNumberOrNumberInString(p)
	if isNumber(p) or IsNumberInString(p)
		return 1
	else
		return 0
	ok

	func IsNumberOrNumberInString(p)
		return StzIsNumberOrNumberInString(p)

	func @IsNumberOrNumberInString(p)
		return StzIsNumberOrNumberInString(p)

	func IsNumberInStringOrNumber(p)
		return StzIsNumberOrNumberInString(p)

	func @IsNumberInStringOrNumber(p)
		return StzIsNumberOrNumberInString(p)

func StzIsNumberOrString(p)
	if isNumber(p) or isString(p)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsNumberOrString(p)
		return StzIsNumberOrString(p)

	func IsStringOrNumber(p)
		return StzIsNumberOrString(p)

	func @IsNumberOrString(p)
		return StzIsNumberOrString(p)

	func @IsStringOrNumber(p)
		return StzIsNumberOrString(p)

	func IsANumberOrString(p)
		return StzIsNumberOrString(p)

	func IsANumberOrAString(p)
		return StzIsNumberOrString(p)

	func IsAStringOrNumber(p)
		return StzIsNumberOrString(p)

	func IsAStringOrANumber(p)
		return StzIsNumberOrString(p)

	func @IsANumberOrString(p)
		return StzIsNumberOrString(p)

	func @IsANumberOrAString(p)
		return StzIsNumberOrString(p)

	func @IsAStringOrNumber(p)
		return StzIsNumberOrString(p)

	func @IsAStringOrANumber(p)
		return StzIsNumberOrString(p)

	#>

func StzIsNumberOrList(p)
	if isNumber(p) or isList(p)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsNumberOrList(p)
		return StzIsNumberOrList(p)

	func IsListOrNumber(p)
		return StzIsNumberOrList(p)

	func @IsNumberOrList(p)
		return StzIsNumberOrList(p)

	func @IsListOrNumber(p)
		return StzIsNumberOrList(p)

	func IsANumberOrList(p)
		return StzIsNumberOrList(p)

	func IsANumberOrAList(p)
		return StzIsNumberOrList(p)

	func IsAListOrNumber(p)
		return StzIsNumberOrList(p)

	func IsAListOrANumber(p)
		return StzIsNumberOrList(p)

	func @IsANumberOrList(p)
		return StzIsNumberOrList(p)

	func @IsANumberOrAList(p)
		return StzIsNumberOrList(p)

	func @IsAListOrNumber(p)
		return StzIsNumberOrList(p)

	func @IsAListOrANumber(p)
		return StzIsNumberOrList(p)

	#>

func StzIsNumberOrObject(p)
	if isNumber(p) or isObject(p)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsNumberOrObject(p)
		return StzIsNumberOrObject(p)

	func IsObjectOrNumber(p)
		return StzIsNumberOrObject(p)

	func @IsNumberOrSObject(p)
		return StzIsNumberOrObject(p)

	func @IsObjectOrNumber(p)
		return StzIsNumberOrObject(p)

	func IsANumberOrObject(p)
		return StzIsNumberOrObject(p)

	func IsANumberOrAObject(p)
		return StzIsNumberOrObject(p)

	func IsAObjectOrNumber(p)
		return StzIsNumberOrObject(p)

	func IsAObjectOrANumber(p)
		return StzIsNumberOrObject(p)

	func @IsANumberOrObject(p)
		return StzIsNumberOrObject(p)

	func @IsANumberOrAObject(p)
		return StzIsNumberOrObject(p)

	func @IsAObjectOrNumber(p)
		return StzIsNumberOrObject(p)

	func @IsAObjectOrANumber(p)
		return StzIsNumberOrObject(p)

	#>

func StzIsStringOrList(p)
	if isString(p) or isList(p)
		return 1
	else
		return 0
	ok

	func IsStringOrList(p)
		return StzIsStringOrList(p)

	def IsListOrString(p)
		return StzIsStringOrList(p)

	func @IsStringOrList(p)
		return StzIsStringOrList(p)

	func @IsListOrString(p)
		return StzIsStringOrList(p)

func StzIsStringOrListOfStrings(p)
	if isString(p) or IsListOfStrings(p)
		return 1
	else
		return 0
	ok

	func IsStringOrListOfStrings(p)
		return StzIsStringOrListOfStrings(p)

	def IsListOfStringsOrString(p)
		return StzIsStringOrListOfStrings(p)

	func @IsStringOrListOfStrings(p)
		return StzIsStringOrListOfStrings(p)

	func @IsListOfStringsOrString(p)
		return StzIsStringOrListOfStrings(p)

func StzIsStringOrObject(p)
	if isString(p) or isObject(p)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsStringOrObject(p)
		return StzIsStringOrObject(p)

	def IsObjectOrString(p)
		return StzIsStringOrObject(p)

	func @IsStringOrObject(p)
		return StzIsStringOrObject(p)

	func @IsObjectOrString(p)
		return StzIsStringOrObject(p)

	func IsAStringOrObject(p)
		return StzIsStringOrObject(p)

	func IsAStringOrAObject(p)
		return StzIsStringOrObject(p)

	func IsAObjectOrString(p)
		return StzIsStringOrObject(p)

	func IsAObjectOrAString(p)
		return StzIsStringOrObject(p)

	func @IsAStringOrObject(p)
		return StzIsStringOrObject(p)

	func @IsAStringOrAObject(p)
		return StzIsStringOrObject(p)

	func @IsAObjectOrString(p)
		return StzIsStringOrObject(p)

	func @IsAObjectOrAString(p)
		return StzIsStringOrObject(p)

	#>

func StzIsListOrObject(p)
	if isList(p) or isObject(p)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsListOrObject(p)
		return StzIsListOrObject(p)

	def IsObjectOrList(p)
		return StzIsListOrObject(p)

	func @IsListOrObject(p)
		return StzIsListOrObject(p)

	func @IsObjectOrList(p)
		return StzIsListOrObject(p)

	func IsAListOrObject(p)
		return StzIsListOrObject(p)

	func IsAListOrAObject(p)
		return StzIsListOrObject(p)

	func IsAObjectOrList(p)
		return StzIsListOrObject(p)

	func IsAObjectOrAList(p)
		return StzIsListOrObject(p)

	func @IsAListOrObject(p)
		return StzIsListOrObject(p)

	func @IsAListOrAObject(p)
		return StzIsListOrObject(p)

	func @IsAObjectOrList(p)
		return StzIsListOrObject(p)

	func @IsAObjectOrAList(p)
		return StzIsListOrObject(p)

	#>

func StzIsNumberOrStringOrList(p)
	if isNumber(p) or isString(p) or isList(p)
		return 1
	else
		return 0
	ok

	#<@FunctionAlternativeForms

	func IsNumberOrStringOrList(p)
		return StzIsNumberOrStringOrList(p)

	def IsNumberOrListOrString(p)
		return StzIsNumberOrStringOrList(p)

	def IsStringOrNumberOrList(p)
		return StzIsNumberOrStringOrList(p)

	def IsStringOrListOrNumber(p)
		return StzIsNumberOrStringOrList(p)

	def IsListOrNumberOrString(p)
		return StzIsNumberOrStringOrList(p)

	def IsListOrStringOrNumber(p)
		return StzIsNumberOrStringOrList(p)

	def @IsNumberOrStringOrList(p)
		return StzIsNumberOrStringOrList(p)

	def @IsNumberOrListOrString(p)
		return StzIsNumberOrStringOrList(p)

	def @IsStringOrNumberOrList(p)
		return StzIsNumberOrStringOrList(p)

	def @IsStringOrListOrNumber(p)
		return StzIsNumberOrStringOrList(p)

	def @IsListOrNumberOrString(p)
		return StzIsNumberOrStringOrList(p)

	def @IsListOrStringOrNumber(p)
		return StzIsNumberOrStringOrList(p)

	#>

#--

func StzIsCharOrNumber(p)
	if isNumber(p) or IsChar(p)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsCharOrNumber(p)
		return StzIsCharOrNumber(p)

	func IsNumberOrChar(p)
		return StzIsCharOrNumber(p)

	func @IsCharOrNumber(p)
		return StzIsCharOrNumber(p)

	func @IsNumberOrChar(p)
		return StzIsCharOrNumber(p)

	func IsACharOrNumber(p)
		return StzIsCharOrNumber(p)

	func IsACharOrANumber(p)
		return StzIsCharOrNumber(p)

	func IsANumberOrChar(p)
		return StzIsCharOrNumber(p)

	func IsANumberOrAChar(p)
		return StzIsCharOrNumber(p)

	func @IsACharOrNumber(p)
		return StzIsCharOrNumber(p)

	func @IsACharOrANumber(p)
		return StzIsCharOrNumber(p)

	func @IsANumberOrChar(p)
		return StzIsCharOrNumber(p)

	func @IsANumberOrAChar(p)
		return StzIsCharOrNumber(p)

	#>

func StzIsCharOrString(p)
	if isString(p)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsCharOrString(p)
		return StzIsCharOrString(p)

	func IsStringOrChar(p)
		return StzIsCharOrString(p)

	func @IsCharOrString(p)
		return StzIsCharOrString(p)

	func @IsStringOrChar(p)
		return StzIsCharOrString(p)

	func IsACharOrString(p)
		return StzIsCharOrString(p)

	func IsACharOrAString(p)
		return StzIsCharOrString(p)

	func IsAStringOrChar(p)
		return StzIsCharOrString(p)

	func IsAStringOrAChar(p)
		return StzIsCharOrString(p)

	func @IsACharOrString(p)
		return StzIsCharOrString(p)

	func @IsACharOrAString(p)
		return StzIsCharOrString(p)

	func @IsAStringOrChar(p)
		return StzIsCharOrString(p)

	func @IsAStringOrAChar(p)
		return StzIsCharOrString(p)

	#>

func StzIsCharOrList(p)
	if isList(p) or IsChar(p)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsCharOrList(p)
		return StzIsCharOrList(p)

	func IsListOrChar(p)
		return StzIsCharOrList(p)

	func @IsCharOrList(p)
		return StzIsCharOrList(p)

	func @IsListOrChar(p)
		return StzIsCharOrList(p)

	func IsACharOrList(p)
		return StzIsCharOrList(p)

	func IsACharOrAList(p)
		return StzIsCharOrList(p)

	func IsAListOrChar(p)
		return StzIsCharOrList(p)

	func IsAListOrAChar(p)
		return StzIsCharOrList(p)

	func @IsACharOrList(p)
		return StzIsCharOrList(p)

	func @IsACharOrAList(p)
		return StzIsCharOrList(p)

	func @IsAListOrChar(p)
		return StzIsCharOrList(p)

	func @IsAListOrAChar(p)
		return StzIsCharOrList(p)

	#>

func StzIsCharOrObject(p)
	if isObject(p) or IsChar(p)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsCharOrObject(p)
		return StzIsCharOrObject(p)

	func IsObjectOrChar(p)
		return StzIsCharOrObject(p)

	func @IsCharOrObject(p)
		return StzIsCharOrObject(p)

	func @IsObjectOrChar(p)
		return StzIsCharOrObject(p)

	func IsACharOrObject(p)
		return StzIsCharOrObject(p)

	func IsACharOrAObject(p)
		return StzIsCharOrObject(p)

	func IsAObjectOrChar(p)
		return StzIsCharOrObject(p)

	func IsAObjectOrAChar(p)
		return StzIsCharOrObject(p)

	func @IsACharOrObject(p)
		return StzIsCharOrObject(p)

	func @IsACharOrAObject(p)
		return StzIsCharOrObject(p)

	func @IsAObjectOrChar(p)
		return StzIsCharOrObject(p)

	func @IsAObjectOrAChar(p)
		return StzIsCharOrObject(p)

	#>

#--

func StzListOfListsOfStzTypes() #TODO // complete the list
	return [
		:stzListOfObjects,
		:stzListOfNumbers,
		:stzListOfUnicodes,
		:stzListOfStrings,
		:stzListOfBytes,
		:stzListOfChars,
		:stzListOfHashLists,
		:stzListOfLists,
		:stzListOfPairs,
		:stzListOfSets,
		:stzListOfEntities
	]

	func ListOfListsOfStzTypes()
		return StzListOfListsOfStzTypes()

func StzBothAreNumbers(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isNumber(p1) and isNumber(p2)
		return 1
	else
		return 0
	ok

	func BothAreNumbers(p1, p2)
		return StzBothAreNumbers(p1, p2)

	func AreBothNumbers(p1, p2)
		return StzBothAreNumbers(p1, p2)

	func @BothAreNumbers(p1, p2)
		return StzBothAreNumbers(p1, p2)

	func @AreBothNumbers(p1, p2)
		return StzBothAreNumbers(p1, p2)

func StzBothAreNumbersInStrings(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isString(p1) and isString(p2) and
	   Q(p1).IsNumberInString() and
	   Q(p2).IsNumberInString()

		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func BothAreNumbersInStrings(p1, p2)
		return StzBothAreNumbersInStrings(p1, p2)

	func AreBothNumbersInStrings(p1, p2)
		return StzBothAreNumbersInStrings(p1, p2)

	func @BothAreNumbersInStrings(p1, p2)
		return StzBothAreNumbersInStrings(p1, p2)

	func @AreBothNumbersInStrings(p1, p2)
		return StzBothAreNumbersInStrings(p1, p2)

	#--

	func BothAreNumbersInString(p1, p2)
		return StzBothAreNumbersInStrings(p1, p2)

	func AreBothNumbersInString(p1, p2)
		return StzBothAreNumbersInStrings(p1, p2)

	func @BothAreNumbersInString(p1, p2)
		return StzBothAreNumbersInStrings(p1, p2)

	func @AreBothNumbersInString(p1, p2)
		return StzBothAreNumbersInStrings(p1, p2)

	#>

func StzBothAreIntegers(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isNumber(p1) and isNumber(p2) and Q(p1).IsInteger() and Q(p2).IsInteger()
		return 1
	else
		return 0
	ok

	func BothAreIntegers(p1, p2)
		return StzBothAreIntegers(p1, p2)

	func AreBothIntegers(p1, p2)
		return StzBothAreIntegers(p1, p2)

	func @BothAreIntegers(p1, p2)
		return StzBothAreIntegers(p1, p2)

	func @AreBothIntegers(p1, p2)
		return StzBothAreIntegers(p1, p2)

func StzBothAreIntegersInStrings(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isString(p1) and isString(p2) and
	   Q(p1).IsIntegerInString() and Q(p2).IsIntegerInString()

		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func BothAreIntegersInStrings(p1, p2)
		return StzBothAreIntegersInStrings(p1, p2)

	func AreBothIntegersInStrings(p1, p2)
		return StzBothAreIntegersInStrings(p1, p2)

	func @BothAreIntegersInStrings(p1, p2)
		return StzBothAreIntegersInStrings(p1, p2)

	func @AreBothIntegersInStrings(p1, p2)
		return StzBothAreIntegersInStrings(p1, p2)

	#--

	func BothAreIntegersInString(p1, p2)
		return StzBothAreIntegersInStrings(p1, p2)

	func AreBothIntegersInString(p1, p2)
		return StzBothAreIntegersInStrings(p1, p2)

	func @BothAreIntegersInString(p1, p2)
		return StzBothAreIntegersInStrings(p1, p2)

	func @AreBothIntegersInString(p1, p2)
		return StzBothAreIntegersInStrings(p1, p2)

	#>

func StzBothAreReals(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isNumber(p1) and isNumber(p2) and Q(p1).IsReal() and Q(p2).IsReal()
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func BothAreReals(p1, p2)
		return StzBothAreReals(p1, p2)

	func AreBothReals(p1, p2)
		return StzBothAreReals(p1, p2)

	func @BothAreReals(p1, p2)
		return StzBothAreReals(p1, p2)

	func @AreBothReals(p1, p2)
		return StzBothAreReals(p1, p2)

	#--

	func BothAreRealNumbers(p1, p2)
		return StzBothAreReals(p1, p2)

	func AreBothRealNumbers(p1, p2)
		return StzBothAreReals(p1, p2)

	func @BothAreRealNumbers(p1, p2)
		return StzBothAreReals(p1, p2)

	func @AreBothRealNumbers(p1, p2)
		return StzBothAreReals(p1, p2)

	#>

func StzBothAreRealsInStrings(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isString(p1) and isString(p2) and
	   Q(p1).IsRealInString() and Q(p2).IsRealInString()

		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func BothAreRealsInStrings(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	func AreBothRealsInStrings(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	func @BothAreRealsInStrings(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	func @AreBothRealsInStrings(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	#--

	func BothAreRealsInString(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	func AreBothRealsInString(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	func @BothAreRealsInString(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	func @AreBothRealsInString(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	#==

	func BothAreRealInString(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	func AreBothRealInString(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	func @BothAreRealInString(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	func @AreBothRealInString(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	#--

	func BothAreRealInStrings(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	func AreBothRealInStrings(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	func @BothAreRealInStrings(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	func @AreBothRealInStrings(p1, p2)
		return StzBothAreRealsInStrings(p1, p2)

	#>

func StzBothArePairsOfNumbers(p1, p2)
	if BothAreLists(p1, p2) and
	   isList(p1) and Q(p1).IsPairOfNumbers() and
	   isList(p2) and Q(p2).IsPairOfNumbers()

		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func BothArePairsOfNumbers(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func AreBothPairsOfNumbers(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func @BothArePairsOfNumbers(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func @AreBothPairsOfNumbers(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func BothArePairOfNumbers(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func AreBothPairOfNumbers(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func @BothArePairOfNumbers(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func @AreBothPairOfNumbers(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func BothArePairOfNumber(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func AreBothPairOfNumber(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func @BothArePairOfNumber(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func @AreBothPairOfNumber(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func BothArePairsOfNumber(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func AreBothPairsOfNumber(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func @BothArePairsOfNumber(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	func @AreBothPairsOfNumber(p1, p2)
		return StzBothArePairsOfNumbers(p1, p2)

	#>

func StzBothArePairsOfStrings(p1, p2)
	if BothAreLists(p1, p2) and
	   isList(p1) and Q(p1).IsPairOfStrings() and
	   isList(p2) and Q(p2).IsPairOfStrings()

		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func BothArePairsOfStrings(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func AreBothPairsOfStrings(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func @BothArePairsOfStrings(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func @AreBothPairsOfStrings(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func BothArePairOfStrings(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func AreBothPairOfStrings(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func @BothArePairOfStrings(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func @AreBothPairOfStrings(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func BothArePairOfString(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func AreBothPairOfString(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func @BothArePairOfString(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func @AreBothPairOfString(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func BothArePairsOfString(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func AreBothPairsOfString(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func @BothArePairsOfString(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	func @AreBothPairsOfString(p1, p2)
		return StzBothArePairsOfStrings(p1, p2)

	#>

func StzBothArePairsOfLists(p1, p2)
	if BothAreLists(p1, p2) and
	   isList(p1) and Q(p1).IsPairOfLists() and
	   isList(p2) and Q(p2).IsPairOfLists()

		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func BothArePairsOfLists(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func AreBothPairsOfLists(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func @BothArePairsOfLists(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func @AreBothPairsOfLists(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func BothArePairOfLists(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func AreBothPairOfLists(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func @BothArePairOfLists(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func @AreBothPairOfLists(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func BothArePairOfList(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func AreBothPairOfList(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func @BothArePairOfList(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func @AreBothPairOfList(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func BothArePairsOfList(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func AreBothPairsOfList(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func @BothArePairsOfList(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	func @AreBothPairsOfList(p1, p2)
		return StzBothArePairsOfLists(p1, p2)

	#>

func StzBothArePairsOfObjects(p1, p2)
	if BothAreLists(p1, p2) and
	   isList(p1) and Q(p1).IsPairOfObjects() and
	   isList(p2) and Q(p2).IsPairOfObjects()

		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func BothArePairsOfObjects(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func AreBothPairsOfObjects(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func @BothArePairsOfObjects(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func @AreBothPairsOfObjects(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func BothArePairOfObjects(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func AreBothPairOfObjects(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func @BothArePairOfObjects(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func @AreBothPairOfObjects(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func BothArePairOfObject(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func AreBothPairOfObject(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func @BothArePairOfObject(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func @AreBothPairOfObject(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func BothArePairsOfObject(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func AreBothPairsOfObject(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func @BothArePairsOfObject(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	func @AreBothPairsOfObject(p1, p2)
		return StzBothArePairsOfObjects(p1, p2)

	#>

func StzBothAreCharsInComputableForm(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	bResult = 0

	if BothAreStringsInComputableForm(p1, p2)
		c1 = '"'
		c2 = "'"

		cClean1 = StzReplace(StzReplace(p1, c1, ""), c2, "")
		bOk1 = (len(cClean1) = 1)
		cClean2 = StzReplace(StzReplace(p2, c1, ""), c2, "")
		bOk2 = (len(cClean2) = 1)

		if bOk1 and bOk2
			bResult = 1
		ok
	ok

	return bResult

	func BothAreCharsInComputableForm(p1, p2)
		return StzBothAreCharsInComputableForm(p1, p2)

	func AreBothCharsInComputableForm(p1, p2)
		return StzBothAreCharsInComputableForm(p1, p2)

	func @BothAreCharsInComputableForm(p1, p2)
		return StzBothAreCharsInComputableForm(p1, p2)

	func @AreBothCharsInComputableForm(p1, p2)
		return StzBothAreCharsInComputableForm(p1, p2)
	 
func StzBothAreStringsInComputableForm(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	c1 = '"'
	c2 = "'"

	if BothAreStrings(p1, p2) and

	   ( ( Q(p1).FirstChar() = c1 and Q(p1).LastChar() = c1 ) or
	     ( Q(p1).LastChar()  = c2 and Q(p1).LastChar() = c2 ) ) and

	   ( ( Q(p2).FirstChar() = c1 and Q(p2).LastChar() = c1 ) or
	     ( Q(p2).LastChar()  = c2 and Q(p2).LastChar() = c2 ) )

		return 1

	else
		return 0
	ok

	func BothAreStringsInComputableForm(p1, p2)
		return StzBothAreStringsInComputableForm(p1, p2)

	func AreBothStringsInComputableForm(p1, p2)
		return StzBothAreStringsInComputableForm(p1, p2)

	func @BothAreStringsInComputableForm(p1, p2)
		return StzBothAreStringsInComputableForm(p1, p2)

	func @AreBothStringsInComputableForm(p1, p2)
		return StzBothAreStringsInComputableForm(p1, p2)

func StzBothAreStzNumbers(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if IsStzNumber(p1) and IsStzNumber(p2)
		return 1
	else
		return 0
	ok

	func BothAreStzNumbers(p1, p2)
		return StzBothAreStzNumbers(p1, p2)

	func AreBothStzNumbers(p1, p2)
		return StzBothAreStzNumbers(p1, p2)

	func @BothAreStzNumbers(p1, p2)
		return StzBothAreStzNumbers(p1, p2)

	func @AreBothStzNumbers(p1, p2)
		return StzBothAreStzNumbers(p1, p2)

func StzBothAreStrings(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isString(p1) and isString(p2)
		return 1
	else
		return 0
	ok

	func BothAreStrings(p1, p2)
		return StzBothAreStrings(p1, p2)

	func AreBothStrings(p1, p2)
		return StzBothAreStrings(p1, p2)

	func @BothAreStrings(p1, p2)
		return StzBothAreStrings(p1, p2)

	func @AreBothStrings(p1, p2)
		return StzBothAreStrings(p1, p2)

func StzBothAreStzStrings(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if IsStzString(p1) and IsStzString(p2)
		return 1
	else
		return 0
	ok

	func BothAreStzStrings(p1, p2)
		return StzBothAreStzStrings(p1, p2)

	func AreBothStzStrings(p1, p2)
		return StzBothAreStzStrings(p1, p2)

	func @BothAreStzStrings(p1, p2)
		return StzBothAreStzStrings(p1, p2)

	func @AreBothStzStrings(p1, p2)
		return StzBothAreStzStrings(p1, p2)

func StzBothAreLists(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isList(p1) and isList(p2)
		return 1
	else
		return 0
	ok

	func BothAreLists(p1, p2)
		return StzBothAreLists(p1, p2)

	func AreBothLists(p1, p2)
		return StzBothAreLists(p1, p2)

	func @BothAreLists(p1, p2)
		return StzBothAreLists(p1, p2)

	func @AreBothLists(p1, p2)
		return StzBothAreLists(p1, p2)

func StzBothAreStzLists(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if IsStzList(p1) and IsStzList(p2)
		return 1
	else
		return 0
	ok

	func BothAreStzLists(p1, p2)
		return StzBothAreStzLists(p1, p2)

	func AreBothStzLists(p1, p2)
		return StzBothAreStzLists(p1, p2)

	func @BothAreStzLists(p1, p2)
		return StzBothAreStzLists(p1, p2)

	func @AreBothStzLists(p1, p2)
		return StzBothAreStzLists(p1, p2)

func StzBothAreObjects(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isObject(p1) and isObject(p2)
		return 1
	else
		return 0
	ok

	func BothAreObjects(p1, p2)
		return StzBothAreObjects(p1, p2)

	func AreBothObjects(p1, p2)
		return StzBothAreObjects(p1, p2)

	func @BothAreObjects(p1, p2)
		return StzBothAreObjects(p1, p2)

	func @AreBothObjects(p1, p2)
		return StzBothAreObjects(p1, p2)

func StzBothAreStzObjects(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if ObjectIsStzObject(p1) and IsStzObject(p2)
		return 1
	else
		return 0
	ok

	func BothAreStzObjects(p1, p2)
		return StzBothAreStzObjects(p1, p2)

	func AreBothStzObjects(p1, p2)
		return StzBothAreStzObjects(p1, p2)

	func @BothAreStzObjects(p1, p2)
		return StzBothAreStzObjects(p1, p2)

	func @AreBothStzObjects(p1, p2)
		return StzBothAreStzObjects(p1, p2)

func StzBothHaveSameStzType(p1, p2)

	if BothAreObjects(p1, p2) and
	   p1.StzType() = p2.StzType()

		return 1
	else
		return 0
	ok

	func BothHaveSameStzType(p1, p2)
		return StzBothHaveSameStzType(p1, p2)

# ARE TWO OBJECTS THE SAME?

func StzAreSameObject(pcVarName1, pcVarName2) #TODO
	if isList(pcVarName2) and Q(pcVarName2).IsAndNamedParam()
		pcVarName2 = pcVarName2[2]
	ok

	return StzObjectQ(pcVarName1).IsEqualTo( pcVarName2 )

	func AreSameObject(pcVarName1, pcVarName2)
		return StzAreSameObject(pcVarName1, pcVarName2)

	func @AreSameObject(pcVarName1, pcVarName2)
		return StzAreSameObject(pcVarName1, pcVarName2)
# OTHER STAFF

func IsStzType(pcStr)
	if NOT isString(pcStr)
		StzRaise("Incorrect param type! pcStr must be a string.")
	ok

	acTypes = StzTypes() # Assumes they are lowercase strings

	if find(acTypes, pcStr) > 0
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsStzClass(pcStr)
		return IsStzType(pcStr)

	func IsStzClassName(pcStr)
		return IsStzType(pcStr)

	#--

	func IsAStzType(pcStr)
		return IsStzType(pcStr)

	func IsAStzClass(pcStr)
		return IsStzType(pcStr)

	func IsAStzClassName(pcStr)
		return IsStzType(pcStr)

	#==

	func @IsStzType(pcStr)
		return IsStzType(pcStr)

	func @IsStzClass(pcStr)
		return IsStzType(pcStr)

	func @IsStzClassName(pcStr)
		return IsStzType(pcStr)

	#--

	func @IsAStzType(pcStr)
		return IsStzType(pcStr)

	func @IsAStzClass(pcStr)
		return IsStzType(pcStr)

	func @IsAStzClassName(pcStr)
		return IsStzType(pcStr)

	#>

func IsRingType(pcStr)
	if NOT isString(pcStr)
		StzRaise("Incorrect param type! pcStr must be a string.")
	ok

	pcStr = StzLower(pcStr)
	acRingTypes = RingTypes()

	if find( RingTypes(), pcStr) > 0
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsRingType(pcStr)
		return IsRingType(pcStr)

	func IsARingType(pcStr)
		return IsRingType(pcStr)

	func @IsARingType(pcStr)
		return IsRingType(pcStr)

	#>

func IsRingOrStzType(pcStr)
	if IsRingType(pcStr) or IsStzType(pcStr)
		return 1
	else
		return 0
	ok

	def IsStzOrRingType(pcStr)
		return IsRingOrStzType(pcStr)

	def @IsRingOrStzType(pcStr)
		return IsRingOrStzType(pcStr)

	def @IsStzOrRingType(pcStr)
		return IsRingOrStzType(pcStr)

	#-- #TODO // Add other alternatives (see IsRingType() and IsStzType() functions)


func StzHowMany(paList)

	if NOT isList(paList)
		StzRaise("Incorrect param type! paList must be a list.")
	ok

	return len(paList)

	#< @FunctionAlternativeForms

	func HowMany(paList)
		return StzHowMany(paList)

	func @HowMany(paList)
		return StzHowMany(palist)

	func HowManyItemsIn(paList)
		return StzHowMany(paList)

	func HowManyItems(paList)
		if isList(paList) and Q(paList).IsInNamedParam()
			paList = paList[2]
		ok

		return StzHowMany(paList)

	func HwoMany(paList)
		return StzHowMany(paList)

	func HwoManyItemsIn(paList)
		return StzHowMany(paList)

	func HwoManyItems(paList)
		return StzHowMany(paList)

	#>

func StzUnicode(p)
	if isList(p) and Q(p).IsOfNamedParam()
		p = p[2]
	ok

	if isString(p)
		nResult = StzStringQ(p).Unicode()
		return nResult

	but isList(p)
		anResult = StzListQ(p).Unicode()
		return anResult

	else
		StzRaise("Incorrect param type! p must be either a string or list.")
	ok

	func Unicode(p)
		return StzUnicode(p)

	func @Unicode(p)
		return StzUnicode(p)

	func UnicodeOf(p)
		return StzUnicode(p)

	func @UnicodeOf(p)
		return StzUnicode(p)

func StzHexUnicode(p)
	if isList(p) and Q(p).IsOfNamedParam()
		p = p[2]
	ok

	if isString(p)
		nResult = StzStringQ(p).HexUnicode()
		return nResult

	but isList(p)
		anResult = StzListQ(p).HexUnicode()
		return anResult

	else
		StzRaise("Incorrect param type! p must be either a string or list.")
	ok

	func HexUnicode(p)
		return StzHexUnicode(p)

	func @HexUnicode(p)
		return StzHexUnicode(p)

	func HexUnicodeOf(p)
		return StzHexUnicode(p)

	func @HexUnicodeOf(p)
		return StzHexUnicode(p)

func StzUnicodes(p)
	if isList(p) and Q(p).IsOfNamedParam()
		p = p[2]
	ok

	if isString(p)
		anResult = StzStringQ(p).Unicodes()
		return anResult

	but isList(p)
		anResult = StzListQ(p).Unicodes()
		return anResult

	else
		StzRaise("Incorrect param type! p must be either a string or list.")
	ok

	func Unicodes(p)
		return StzUnicodes(p)

	func @Unicodes(p)
		return StzUnicodes(p)

	func UnicodesOf(p)
		return StzUnicodes(p)

	func @UnicodesOf(p)
		return StzUnicodes(p)

func StzHexUnicodes(p)
	if isList(p) and Q(p).IsOfNamedParam(p)
		p = p[2]
	ok

	if isString(p)
		anResult = StzStringQ(p).HexUnicodes()
		return anResult

	but isList(p)
		anResult = StzListQ(p).HexUnicodes()
		return anResult

	else
		StzRaise("Incorrect param type! p must be either a string or list.")
	ok

	func HexUnicodes(p)
		return StzHexUnicodes(p)

	func @HexUnicodes(p)
		return StzHexUnicodes(p)

	func HexUnicodesOf(p)
		return StzHexUnicodes(p)

	func @HexUnicodesOf(p)
		return StzHexUnicodes(p)



#---

func YaAllah()
	return "ÙŠÙŽا أÙŽÙ„Ù„Ù‡"

func YaMuhammed()
	return "ÙŠا Ù…ُحÙŽÙ…Ù‘ÙŽدÙ’"

func SalatNabee()
	return "صÙ„Ù‘Ù‰ اÙ„Ù„Ù‡ عÙ„Ù‰ Ù†بÙŠÙ‘Ù‡ اÙ„أÙƒرÙ…"

func StzNHearts(n)
	return Q(Heart()).RepeatedNTimes(n)

	func NHearts(n)
		return StzNHearts(n)

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

func StzNStars(n)
	return Q(Star()).RepeatedNTimes(n)

	func NStars(n)
		return StzNStars(n)

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

func StzEmpty(pcStzType)
	if NOT isString(pcStzType)
		StzRaise("Incorrect param type! pcStzType must be a string.")
	ok

	if NOT Q(pcStzType).IsStzClassName()
		StzRaise("Incorrect param! pcStzType must be a valid class name.")
	ok

	switch pcStzType
	on :stzChar
		return new stzChar("_")

	on :stzString
		return new stzString("")

	on :stzNumber
		return new stzNumber(0)

	on :stzList
		return new stzList([])

	on :stzobject
		return new stzObject( new stzString("") )

	on :stzText
		return new stzText("")

	on :stzlistofobjects
		return new stzListOfObjects([])

	on :stzlistofnumbers
		return new stzListOfNumbers([])

	on :stzlistofstrings
		return new stzListOfStrings([])
		
	on :stzlistofchars
		return new stzListOfChars([])

	on :stzhashlist
		return new stzHashList([])

	on :stzlistofhashlists
		return new stzListOfHashLists([])

	on :stzset
		return new stzSet([])

	on :stzlistoflists
		return new stzListOfLists([])

	on :stzlistofpairs
		return new stzListOfPairs([])

	on :stzpair
		return new stzPair([])

	on :stzlistofsets
		return new stzListOfSets([])

	on :stzpairoflists
		return new stzPairOfLists([])

	on :stztree
		return new stzTree([])

	on :stztable
		return new stzTable([])

	on :stzlocale
		return new stzLocale([])

	on :stzcountry
		return new stzCountry([])

	on :stzlanguage
		return new stzLanguage([])

	on :stzscript
		return new stzScript([])

	on :stzcurrency
		return new stzCurrency("")

	on :stzgrid
		return new stzGrid([])

	on :stzentity
		return new stzEnity(:nothing)

	on :stzlistofentities
		return new stzListOfEntities([])

	on :stzstringart
		return new stzStringArt("")

	off

	func Empty(pcStzType)
		return StzEmpty(pcStzType)

func StzSwap(p1, p2)
	_temp_ = p2
	p2 = p1
	p1 = _temp_

	return [p1, p2]

	func Swap(p1, p2)
		return StzSwap(p1, p2)

	func @Swap(p1, p2)
		return StzSwap(p1, p2)

func new_stz(cType, p)
	
	if NOT isString(cType)
		StzRaise("Incorrect param type! cType must be a string.")
	ok
	
	cCode = 'oObject = new stz' + cType + '(' + @@(p) + ')'

	eval(cCode)

	return oObject

	func StzTypedQ(cType, p)
		return stz(cType, p)

	func stz@(cType, p)
		return stz(cType, p)

	func new@stz(cType, p)
		return stz(cType, p)

func StzSoftanzify(p)
	return Q(p)

	func Softanzify(p)
		return StzSoftanzify(p)

func StzTheNumberQ(n)
	if NOT isNumber(n)
		StzRaise("Incorrect param type! n must be a number.")
	ok

	obj = new stzNumber(n)
	return obj

	func TheNumberQ(n)
		return StzTheNumberQ(n)

	func NumberQ(n)
		return StzTheNumberQ(n)

func StzTheNumberQM(n)
	obj = StzTheNumberQ(n)
	SetMainObject(obj)
	return obj

	func TheNumberQM(n)
		return StzTheNumberQM(n)

	def NumberQM(n)
		return StzTheNumberQM(n)

func StzTheListQ(aList)
	if NOT isList(aList)
		StzRaise("Incorrect param type! aList must be a list.")
	ok

	obj = new stzList(aList)
	return obj

	func TheListQ(aList)
		return StzTheListQ(aList)

	func ListQ(aList)
		return StzTheListQ(aList)

func StzTheListQM(aList)
	obj = StzTheListQ(aList)
	SetMainObject(obj)
	return obj

	func TheListQM(aList)
		return StzTheListQM(aList)

	func ListQM(aList)
		return StzTheListQM(aList)

func StzTheList(aList)
	if NOT isList(aList)
		StzRaise("Incorrect param type! aList must be a list.")
	ok

	return aList

	func TheList(aList)
		return StzTheList(aList)

func StzTheStringQ(str)
	if NOT isString(str)
		StzRaise("Incorrect param type! str must be a string.")
	ok

	obj = new stzString(str)
	return obj

	func TheStringQ(str)
		return StzTheStringQ(str)

	func StringQ(str)
		return StzTheStringQ(str)

	func TheWordQ(str)
		return StzTheStringQ(str)

	func WordQ(str)
		return StzTheStringQ(str)

func StzTheStringQM(str)
	obj = StzTheStringQ(str)
	SetMainObject(obj)
	return obj

	func TheStringQM(str)
		return StzTheStringQM(str)

	func StringQM(str)
		return StzTheStringQM(str)

	func TheWordQM(str)
		return StzTheStringQM(str)

	func WordQM(str)
		return StzTheStringQM(str)

func StzTheString(str)
	if NOT isString(str)
		StzRaise("Incorrect param type! str must be a string.")
	ok

	return str

	func TheString(str)
		return StzTheString(str)

	func TheWord(str)
		return StzTheString(str)




func StzTodo()
	return StzTodoXT(:InCurrent)

	func Todo()
		return StzTodo()

func StzTodoInFuture()
	return StzTodoXT(:InFuture)

	func TodoInFuture()
		return StzTodoInFuture()

	func TodoFuture()
		return StzTodoInFuture()

	func TodoInFutureRelease()
		return StzTodoInFuture()

	func TodoFutureRelease()
		return StzTodoInFuture()

func StzTodoInCurrent()
	return StzTodoXT(:InCurrent)

	func TodoInCurrent()
		return StzTodoInCurrent()

	func TodoCurrent()
		return StzTodoInCurrent()

	func TodoInCurrentRelease()
		return StzTodoInCurrent()

	func TodoCurrentRelease()
		return StzTodoInCurrent()

func StzTodoXT(pcCurrentOrFuture)
	if NOT ( isString(pcCurrentOrFuture) and
	   	 StzFind([
			:Current, :InCurrent, :Future, :InFuture,
			:CurrentRelease, :InCurrentRelease, :FutureRelease, :InFutureRelease,

			# Misspelled variations
			:Fture, :InFture, :FtureRelease, :InFtureRelease ], pcCurrentOrFuture) ) > 0

		StzRaise("Incorrect param! pcCurrentOrFuture must be a string equal to :Current or :Future.")
	ok

	if StzFind([ :Future, :InFuture, :FutureRelase, :InFutureRelase ], pcCurrentOrFuture) > 0
		StzRaise("Unavailable feature in current version (TODO in the future!)")

	else
		StzRaise("Feature not yet implemented, but it should be (TODO in current release)")
	ok

	func TodoXT(pcCurrentOrFuture)
		return StzTodoXT(pcCurrentOrFuture)

func StzAreBothListsOfNumbers(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfNumbers() and
	   Q(aList2).IsListOfNumbers()

		return 1

	else
		return 0
	ok

	func AreBothListsOfNumbers(aList1, aList2)
		return StzAreBothListsOfNumbers(aList1, aList2)

func StzAreBothListsOfStrings(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfStrings() and
	   Q(aList2).IsListOfStrings()

		return 1

	else
		return 0
	ok

	func AreBothListsOfStrings(aList1, aList2)
		return StzAreBothListsOfStrings(aList1, aList2)

func StzAreBothListsOfLists(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfLists() and
	   Q(aList2).IsListOfLists()

		return 1

	else
		return 0
	ok

	func AreBothListsOfLists(aList1, aList2)
		return StzAreBothListsOfLists(aList1, aList2)

func StzAreBothListsOfPairs(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfPairs() and
	   Q(aList2).IsListOfPairs()

		return 1

	else
		return 0
	ok

	func AreBothListsOfPairs(aList1, aList2)
		return StzAreBothListsOfPairs(aList1, aList2)

func StzAreBothListsOfSets(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfSets() and
	   Q(aList2).IsListOfSets()

		return 1

	else
		return 0
	ok

	func AreBothListsOfSets(aList1, aList2)
		return StzAreBothListsOfSets(aList1, aList2)

func StzAreBothListsOfHashLists(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfHashLists() and
	   Q(aList2).IsListOfHashLists()

		return 1

	else
		return 0
	ok

	func AreBothListsOfHashLists(aList1, aList2)
		return StzAreBothListsOfHashLists(aList1, aList2)

func StzAreBothListsOfObjects(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfObjects() and
	   Q(aList2).IsListOfObjects()

		return 1

	else
		return 0
	ok

	func AreBothListsOfObjects(aList1, aList2)
		return StzAreBothListsOfObjects(aList1, aList2)

func StzEuclideanDistance(anNumbers1, anNumbers2)

	if CheckParams()
		if isList(anNumbers1) and IsBetweenNamedParamList(anNumbers1)
			anNumbers1 = anNumbers1[1]
		ok
		if isList(anNumbers2) and IsAndNamedParamList(anNumbers2)
			anNumbers2 = anNumbers2[1]
		ok
		
		if NOT AreBothListsOfNumbers(anNumbers1, anNumbers2)
			StzRaise("Incorrect param types! anNumbers1 and anNumbers2 must be both lists of numbers.")
		ok
		
		if len(anNumbers1) != len(anNumbers2)
			StzRaise("Incorrect lists sizes! anNumbers1 and anNumbers2 must both have the same size.")
		ok
	ok

	nResult = euc_dist(anNumbers1, anNumbers2)
	return nResult

	func EuclideanDistance(anNumbers1, anNumbers2)
		return StzEuclideanDistance(anNumbers1, anNumbers2)

func euc_dist(a,b)

	if CheckParams()
		if NOT ( isNumber(a) and isNumber(b) )
			StzRaise("Incorrect param types! a and b must be bother numbers.")
		ok
	ok

	s = 0
	n = len(a)

	for i = 1 to n

		dist = a[i] - b[i]
		s += dist * dist
	next

	return sqrt(s)

func @IsList(paList)
	if isList(paList)
		return 1
	else
		return 0
	ok

	func IsAList(paList)
		return isList(paList)

	func @IsAList(paList)
		return isList(paList)

func @IsNumber(n)
	if isNumber(n)
		return 1
	else
		return 0
	ok

	func IsANumber(n)
		return isNumber(n)

	func @IsANumber(n)
		return isNumber(n)

func @IsString(str)
	if isString(str)
		return 1
	else
		return 0
	ok

	func IsAString(str)
		return isString(str)

	func @IsAString(str)
		return isString(str)

	func IsAnObject(obj)
		return isObject(obj)

	func @IsAnObject(obj)
		return isObject(obj)

#--

func StzIsNeitherNorCS(p, p1, p2, pCaseSensitive)
	return Q(p).IsNeitherCS(p1, p2, pCaseSensitive)

	func IsNeitherNorCS(p, p1, p2, pCaseSensitive)
		return StzIsNeitherNorCS(p, p1, p2, pCaseSensitive)

	func @IsNeitherNorCS(p, p1, p2, pCaseSensitive)
		return StzIsNeitherNorCS(p, p1, p2, pCaseSensitive)

func StzIsNeitherNor(p, p1, p2)
	return Q(p).IsNeither(p1, p2)

	func IsNeitherNor(p, p1, p2)
		return StzIsNeitherNor(p, p1, p2)

	func @IsNeitherNor(p, p1, p2)
		return StzIsNeitherNor(p, p1, p2)

#==

func StzBothStartWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)

	if Q(pStrOrList1).StartsWithCS(pSubStrOrSubList, pCaseSensitive) and
	   Q(pStrOrList2).StartsWithCS(pSubStrOrSubList, pCaseSensitive)

		return 1
	else
		return 0
	ok

	func BothStartWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)
		return StzBothStartWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)

	func @BothStartWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)
		return StzBothStartWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)

func StzBothStartWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)
	return StzBothStartWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, 1)

	func BothStartWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)
		return StzBothStartWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)

	func @BothStartWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)
		return StzBothStartWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)

#--

func StzBothEndWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)

	if Q(pStrOrList1).endsWithCS(pSubStrOrSubList, pCaseSensitive) and
	   Q(pStrOrList2).EndsWithCS(pSubStrOrSubList, pCaseSensitive)

		return 1
	else
		return 0
	ok

	func BothEndWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)
		return StzBothEndWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)

	func @BothEndWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)
		return StzBothEndWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)

func StzBothEndWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)
	return StzBothEndWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, 1)

	func BothEndWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)
		return StzBothEndWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)

	func @BothEndWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)
		return StzBothEndWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)

#==

func StzBothStartWithANumber(p1, p2)
	if Q(p1).StartsWithANumber() and Q(p2).StartsWithANumber()
		return 1
	else
		return 0
	ok

	func BothStartWithANumber(p1, p2)
		return StzBothStartWithANumber(p1, p2)

func StzBothEndWithANumber(p1, p2)
	if Q(p1).EndsWithANumber() and Q(p2).EndsWithANumber()
		return 1
	else
		return 0
	ok

	func BothEndWithANumber(p1, p2)
		return StzBothEndWithANumber(p1, p2)

func StzNewLine()
	return NL

	func NewLine()
		return StzNewLine()

	func NL()
		return NL

	func EmptyLine()
		return StzNewLine()

func StzNumberOfStzFindableTypes()
	return len(_aStzFindableTypes)

	func NumberOfStzFindableTypes()
		return StzNumberOfStzFindableTypes()

func IsStzFindableType(cType)
	if NOT isString(cType)
		StzRaise("Incorrect param type! cType must be a string.")
	ok

	cType = StzLower(cType)
	if StzFind( StzFindableTypes(), cType) > 0
		return 1
	else
		return 0
	ok

	func IsAStzFindableType(cType)
		return IsStzFindableType(cType)

	func @IsStzFindableType(cType)
		return IsStzFindableType(cType)

	func @IsAStzFindableType(cType)
		return IsStzFindableType(cType)

func StzFindableTypes()
	return _aStzFindableTypes

func IsStzFindable(p)
	if NOT ( isObject(p) and IsStzObject(p) )
		return 0
	ok

	cStzType = p.StzType()
	if StzFind( StzFindableTypes(), cStzType ) > 0
		return 1
	else
		return 0
	ok

	func @IsStzFindable(p)
		return IsStzFindable(p)

#----


func StzClasses()
	aResult = []
	acStzClassesXT = StzClassesXT()
	nLen = len(acStzClassesXT)

	for i = 1 to nLen
		aResult + acStzClassesXT[i][1]
	next

	return aResult

	func StzTypes()
		return StzClasses()

func NumberOfStzClasses()
	return len(StzClasses())

	func HowManyStzClasses()
		return NumberOfStzClasses()

func StzClassesXT()
	#TODO // Update this list!
	aStzClassesXT = [
		# [ :Singular,			:Plural			]
		[ :stzObject, 			:stzObjects 		],
		[ :stzListOfObjects, 		:stzListsOfObjects 	],
		[ :stzNumber, 			:stzNumbers		],

		[ :stzListOfNumbers, 		:stzListsOfNumbers	],
		[ :stzListOfUnicodes, 		:stzListsOfUnicodes	],
		[ :stzBinaryNumber, 		:stzBinaryNumbers	],

		[ :stzHexNumber, 		:stzHexNumbers		],
		[ :stzOctalNumber, 		:stzOctalNumbers	],
		[ :stzString, 			:stzStrings		],

		[ :stzSplitter,			:stzSplitters		],
		[ :stzMultiString, 		:stzMultiStrings	],
		[ :stzMultilingualString, 	:stzMultilingualStrings ],
		
		[ :stzStopWords, 		:stzStopWords		],
		[ :stzListOfStrings, 		:stzListsOfStrings	],
		[ :stzListInString, 		:stzListsInStrings	],

		[ :stzListOfBytes, 		:stzListsOfBytes	],
		[ :stzChar, 			:stzChars		],
		[ :stzUnicodeNames, 		:stzUnicodeNames	],

		[ :stzListOfChars, 		:stzListsOfChars	],
		[ :stzList, 			:stzLists		],
		[ :stzHashList, 		:stzHashLists		],
		[ :stzListOfHashLists,		:stzListsOfHashLists	],

		[ :stzAssociativeList, 		:stzAssociativeLists	],
		[ :stzSet, 			:stzSets		],
		[ :stzListOfLists, 		:stzListsOfLists	],

		[ :stzListOfPairs, 		:stzListsOfPairs	],
		[ :stzPair, 			:stzPairs		],
		[ :stzPairOfNumbers, 		:stzPairsOfNumbers	],
		[ :stzPairOfLists,		:stzPairsOfList		],
		
		[ :stzListOfSets, 		:stzListsOfSets		],
		[ :stzTree, 			:stzTrees		],

		[ :stzWalker, 			:stzWalkers		],
		[ :stzTable, 			:stzTables		],
		[ :stzListOfTables,		:stzListsOfTables	],
		[ :stzLocale, 			:stzLocales		],
		
		[ :stzCountry, 			:stzCountries		],
		[ :stzLanguage, 		:stzLanguages		],
		[ :stzScript, 			:stzScripts		],

		[ :stzCurrency, 		:stzCurrencies		],
		[ :stzListParser, 		:stzListsParsers	],
		[ :stzGrid, 			:stzGrids		],
		[ :stzListOfGrids,		:stzListsOfGrids	],

		[ :stzCounter, 			:stzCounters		],
		[ :stzDate, 			:stzDates		],
		[ :stzTime, 			:stzTimes		],

		[ :stzFile, 			:stzFiles		],
		[ :stzFolder, 			:stzFolders		],
		[ :stzRunTime, 			:stzRuntimes		],

		[ :stzTextEncoding, 		:stzTextEncodings	],
		[ :stzNaturalCode, 		:stzNaturalCodes	],
		[ :stzChainOfValue, 		:stzChainsOfValues	],

		[ :stzChainOfTruth, 		:stzChainsOfTruth	],
		[ :stzEntity, 			:stzEntities		],
		[ :stzListOfEntities, 		:stzListsOfEntities	],

		[ :stzText, 			:stzTexts		],
		[ :stzStringArt, 		:stzStringArts		],
		[ :stzConstraints, 		:stzConstraints		],
		
		[ :stzCCode, 			:stzCCodes		],
		[ :stzNullObject,		:stzNullObjects		],
		[ :stzFalseObject,		:stzFalsebjects		],
		[ :stzTrueObject,		:stzTruebjects		],

		[ :stzExtCode,			:stzExtCodes		],
		
		[ :stzSection,			:stzSections		],

		[ :stzNullObject,		:stzNullObjects		],
		[ :stzTrueObject,		:stzTrueObjects		],
		[ :stzFalseObjects,		:stzFalseObjects	]
	]

	return aStzClassesXT

	func StzTypesXT()
		return StzClassesXT()

	func StzClassesAndTheirPluralForm()
		return StzClassesXT()

func StzType(oStzObj)
	if CheckingParams()
		if NOT ( isObject(oStzObj) and IsStzObject(oStzObj) )
			StzRaise("Incorrect param type! oStzObject must be a stzObject.")
		ok
	ok

	return oStzObj.StzType()

	func @StzType(oStzObj)
		return StzType(oStzObj)

func StzInfereType(cType)
	return StzStringQ(cType).InfereType()

	func InfereType(cType)
		return StzInfereType(cType)

	func @InfereType(cType)
		return StzInfereType(cType)

#---

# Viewing a file in the default program in the system

func StzView(cFileName)
	if CheckParams()
		if NOT isString(cFileName)
			stzraise("Incorrect param type! cFileName mlust be a string.")
		ok
	ok

	if fexists(cFileName)
		osysCall = new stzSystemCall("")
		oSysCall.OpenFile(cFileName)

	else
		stzraise("Can't proceed! The file you provided does not exist.")
	ok

	func View(cFileName)
		StzView(cFileName)

	func @View(cFileName)
		StzView(cFileName)


  ////////////////////////
 ///  GLOBAL CLASSES  ///
////////////////////////

#WARNING: Be careful! don't put global functions after theses classes,
# because Ring will consider them as methods of the classes and not global functons!

class stzForEachObjectOld
	@acVars
	@aValues

	def init(p, pIn)

		# Checking params
	
		if isList(pIn) and Q(pIn).IsInNamedParam()
			pIn = pIn[2]
		else
			StzRaise("Syntax error! pIn must be a named param of the form :In = ...")
		ok
	
		if NOT ( isString(p) or ( isList(p) and Q(p).IsListOfStrings() ) )
			StzRaise("Incorrect param type! p must be a string or a list of strings.")
		ok
	
		if NOT (isList(pIn) or isString(pIn))
			StzRaise("Incorrect param type! pIn must be a string or list.")
		ok
	
		if isString(pIn) and isList(p)
			StzRaise("Incorrect params! pIn can't be a string when p is a List.")
		ok
	
		if isList(p)
			nLen = len(p)
			
			if NOT IsListOfLists(pIn)
				StzRaise("Incorrect param! pIn must be a list of lists containing " + nLen + " items in each list.")
			ok
	
			if NOT StzListOfListsQ(pIn).SizeOfEach@Is(nLen)
	
				StzRaise("Syntax error! Each list in pIn must have the same size as the number of params in p.")
			ok
	
		ok
	
		if isString(p)
			aTemp = []
			aTemp + p
			p = aTemp

			if isList(pIn)
				nLen = len(pIn)
				aTemp = []
				for i = 1 to nLen
					aTemp + [ pIn[i] ]
				next
				pIn = aTemp
			ok
		ok

		@acVars = p
 		@aValues = pIn

	def Vars()
		return @acVars

		def VarNames()
			return This.Vars()

	def NumberOfVars()
		return len(@acVars)

		def NumbersOfVarNames()
			return This.NumberOfVars()

		def HowManyVars()
			return This.NumberOfVars()

		def HowManyVar()
			return This.NumberOfVars()

		def HowManyVarNames()
			return This.NumberOfVars()

		def HowManyVarName()
			return This.NumberOfVars()

	def Values()
		return @aValues

	def NumberOfIterations()
		return len(@aValues)

		def NumberOfValues()
			return This.NumberOfIterations()

		def HowManyIterations()
			return This.NumberOfIterations()

		def HowManyIteration()
			return This.NumberOfIterations()

		def HowManyValues()
			return This.NumberOfIterations()

		def HowManyValue()
			return This.NumberOfIterations()

	def @(pcCode)

		for i = 1 to len(@aValues)

			for j = 1 to len(@aValues[i])
				cCode = @acVars[j] + ' = @aValues[i][j]'
				eval(cCode)
			next

			eval(pcCode)
		next

		return

class stzForEachObject
	@acVars
	@aValues

	@aDataVars
	@i

	@Iterations

	def init(p, pIn)

		# Checking params
	
		if isList(pIn) and Q(pIn).IsInNamedParam()
			pIn = pIn[2]
		else
			StzRaise("Syntax error! pIn must be a named param of the form :In = ...")
		ok
	
		if NOT ( isString(p) or ( isList(p) and Q(p).IsListOfStrings() ) )
			StzRaise("Incorrect param type! p must be a string or a list of strings.")
		ok
	
		if NOT (isList(pIn) or isString(pIn))
			StzRaise("Incorrect param type! pIn must be a string or list.")
		ok
	
		if isString(pIn) and isList(p)
			StzRaise("Incorrect params! pIn can't be a string when p is a List.")
		ok
	
		if isList(p)
			nLen = len(p)

			if NOT IsListOfLists(pIn)
				StzRaise("Incorrect param! pIn must be a list of lists containing " + nLen + " items in each list.")
			ok
	
			if NOT StzListOfListsQ(pIn).SizeOfEach@Is(nLen)
	
				StzRaise("Syntax error! Each list in pIn must have the same size as the number of params in p.")
			ok
	
		ok
	
		if isString(p)
			@Iterations = 1 : len(pIn)

			aTemp = []
			aTemp + [ p, pIn ]
			p = aTemp
			@aDataVars = p

			@aValues = @aDataVars[1][2]
			
		else

			@acVars = p
	 		@aValues = pIn
	
			@aDataVars = []
	
			for i = 1 to len(p)
				@aDataVars + [ p[i], [] ]
			next
	
	
			for i = 1 to len(@aDataVars)
				for j = 1 to len(@aValues)
					@aDataVars[i][2] + @aValues[j][i]
				next
			next

			@Iterations = 1 : len(@aValues)
		ok

	

	def @Vars()
		if This.@NumberOfVars() = 1
			return [ @aDataVars[1][1] ]

		else
			return @acVars
		ok

		def @VarNames()
			return This.@Vars()

	def @NumberOfVars()
		return len(This.@VarsXT())

		def @NumbersOfVarNames()
			return This.@NumberOfVars()

	def @Values()
		return @aValues

	def @Content()
		return @aDataVars

		#< @FunctionAlternativeForms

		def @VarValues()
			return This.@Content()

		def @VarsAndValues()
			return This.@Content()

		def @VarsAndTheirValues()
			return This.@Content()

		def @VarsXT()
			return This.@Content()

		def @VarVal()
			return This.@Content()

		#>

	def @NumberOfIterations()
		return len(@aValues)

		def @NumberOfValues()
			return This.@NumberOfIterations()

	def @CurrentIteration()
		return @i

		def @CurrentIndex()
			return This.@CurrentIteration()

	def @SetIterations(panPos)
		@Iterations = panPos

		def @Iterations(panPos)
			@SetIterations(panPos)

		def @Scope(panPos)
			@SetIterations(panPos)

		def @SetScope(panPos)
			@SetIterations(panPos)

		def @IterateOn(panPos)
			@SetIterations(panPos)

		def @IterateOnThesePositions(panPos)
			@SetIterations(panPos)

		def @IterateOnlyOn(panPos)
			@SetIterations(panPos)

		def @IterateOnLyOnThesePositions(panPos)
			@SetIterations(panPos)

	def Exec(pcCode)

		if isList(pcCode) and len(pcCode) = 2
			ExecN(pcCode[1], pcCode[2])
			return
		ok

		nLen = len(@Iterations)

		if This.@NumberOfVars() = 1

			for i = 1 to nLen
				@i = @Iterations[i]
				cCode = @acVars[1] + ' = @aValues[' + @Iterations[i] + ']'
				eval(cCode)
				eval(pcCode)
			next

		else

			for i = 1 to nLen
				@i = @Iterations[i]
				for j = 1 to len(@aValues[@i])
					cCode = @acVars[j] + ' = @aValues[' + @Iterations[i] + '][' + j + ']'
					eval(cCode)
				next
	
				eval(pcCode)
			next

		ok

		def Execute(pcCode)
			This.Exec(pcCode)

		def Run(pcCode)
			This.Exec(pcCode)

		def @(pcCode)
			This.Exec(pcCode)

		def _(pcCode)
			This.Exec(pcCode)

		def X(pcCode)
			This.Exec(pcCode)

	def ExecN(n, pcCode)
		anPos = []

		if isNumber(n)
			anPos + n

		but isList(n) and Q(n).IsListOfNumbers()
			anPos = n
		ok

		nLen = len(anPos)

		if This.@NumberOfVars() = 1

			for i = 1 to nLen
				@i = anPos[i]
				cCode = @acVars[1] + ' = @aValues[' + anPos[i] + ']'
				eval(cCode)
				eval(pcCode)
			next

		else

			for i = 1 to nLen
				@i = anPos[i]
				for j = 1 to len(@aValues[@i])
					cCode = @acVars[j] + ' = @aValues[' + anPos[i] + '][' + j + ']'
					eval(cCode)
				next
	
				eval(pcCode)
			next

		ok

		def ExecuteN(n, pcCode)
			This.ExecN(n, pcCode)

		def RunN(n, pcCode)
			This.ExecN(n, pcCode)

		def @n(n, pcCode)
			This.ExecN(n, pcCode)

		def _n(n, pcCode)
			This.ExecN(n, pcCode)

		def Xn(n, pcCode)
			This.ExecN(n, pcCode)

	def v(pcVar)

		if This.@NumberOfVars() = 1
			return This.@VarsXT()[1][2][@i]

		else
			return This.@VarsXT()[pcVar][@i]
		ok

#WARNING
# DO NOT ADD GLOBAL FUNCTIONS HERE BECAUSE THIS IS A CLASS REGION

