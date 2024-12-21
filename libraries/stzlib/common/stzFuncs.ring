
#TODO // general - study the compatibility of softanza comments
# with JSDoc (https://jsdoc.app/)
#--> Create a generator of a static web site documentation

_cSoftanzaLogo = '
╭━━━┳━━━┳━━━┳━━━━┳━━━┳━╮╱╭┳━━━━┳━━━╮
┃╭━╮┃╭━╮┃╭━━┫╭╮╭╮┃╭━╮┃┃╰╮┃┣━━╮━┃╭━╮┃
┃╰━━┫┃╱┃┃╰━━╋╯┃┃╰┫┃╱┃┃╭╮╰╯┃╱╭╯╭┫┃╱┃┃
╰━━╮┃┃╱┃┃╭━━╯╱┃┃╱┃╰━╯┃┃╰╮┃┃╭╯╭╯┃╰━╯┃
┃╰━╯┃╰━╯┃┃╱╱╱╱┃┃╱┃╭━╮┃┃╱┃┃┣╯━╰━┫╭━╮┃
╰━━━┻━━━┻╯╱╱╱╱╰╯╱╰╯╱╰┻╯╱╰━┻━━━━┻╯╱╰━

Programming, by Heart! By: M.Ayouni╭
━━╮╭━━━━━━━━━━━━━━━━━━━━╮╱╭━━━━━━━━╯
  ╰╯'

#TODO // Add these alternatives to NumberOf...() functions, allover the library:
#	- HowMany...() : in singular and plural forms, exp: HowManyItem() and HowManyItems()
#	- Count...()
# NB: Many have been added! Check those that haven't.

  ///////////////////////////
 ///  GLOBALS VARIABLES  ///
///////////////////////////

_FALSE_ = 0 // Avoids the risk of accidental change of _FALSE_ in a Ring program
_TRUE_ = 1  // Idem for TRUE
_NULL_ = "" // Idem for NULL

$TEMP_LIST = [] # A temp list value used with @() inside objects
$TEMP_STRING = ""
$TEMP_NUMBER = 0
$TEMP_OBJECT = _NULL_

_bKeepHisto = _FALSE_ // for keeping objec update history
_aHisto = []

_bKeepHistoXT = _FALSE_
_aHistoXT = []

_bKeepTime = _FALSE_ // for keeping object execution time
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

_aStzFindableTypes = [
	:stzListOfNumbers, :stzListOfUnicodes, :stzString, :stzMultiString,
	:stzSubString, :stzItem, :stzStopWords, :stzStopWordsData,
	:stzListOfStrings, :stzListInString, :stzListOfBytes,
	:stzCharData, :stzListOfChars, :stzList, :stzHashList,
	:stzListOfHashLists, :stzSet, :stzListOfLists, :stzSplitter,
	:stzListOfPairs, :stzPair, :stzPairOfNumbers, :stzPairOfLists,
	:stzListOfSets, :stzTree, :stzWalker, :stzTable, :stzLocaleData,
	:stzUnicodeData, :stzGrid, :stzListOfEntities, :stzText,
	:stzConstraintsData, :stzSection
]

_MainValue = _NULL_
_LastValue = _NULL_

_bThese = _FALSE_	     	# Used in case like: Q(1:5) - These(3:5) 	--> [1,2]
_bTheseQ = _FALSE_     	# Used in case like: Q(1:5) - TheseQ(3:5) 	--> Q([1,2])

_bAsObject = _FALSE_	# Used in case like: Q(1:2) + Obj(Q(3:4))	--> [ [1,2], Q([3,4]) ]
_bAsObjectQ = _FALSE_

_bModifiable = _FALSE_	# Used with operators that modify stz objects

_bParamCheck = _TRUE_  	# Activates the "# Checking params region" in softanza functions
		     	#--> Set it to _FALSE_ if the functions are used inside large loops
		    	# so you can gain performance (the checks can then be made once,
		     	# by yourself, outside the loop).
			# Use the SetParamCheckingTo(_FALSE_)

_bEarlyCheck = _TRUE_	# Used for the same reason as _bParamCheck

cCacheFileName = "stzcache.txt"
_CacheFileHandler = _NULL_

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

func KeepingHistory()
	return _bKeepHisto

	func KeepingHisto()
		return KeepingHistory()

	func KeepingObjectHistory()
		return KeepingHistory()

	func KeepingObjectHisto()
		return KeepingHistory()

	func KeepingObjHist()
		return KeepingHistory()

func KeepingHistoryXT()
	return _bKeepHistoXT

	func KeepingHistoXT()
		return KeepingHistoryXT()

	func KeepingObjectHistoryXT()
		return KeepingHistoryXT()

	func KeepingObjectHistoXT()
		return KeepingHistoryXT()

	func KeepingObjHistXT()
		return KeepingHistoryXT()

#--

func KeepHistoryON()
	_bKeepHisto = _TRUE_

	func KeepHistory()
		KeepHistoryON()

	func KeepHistoON()
		KeepHistoryON()

	func KeepHisto()
		KeepHistoryON()

func KeepHistoryONXT()
	_bKeepHistoXT = _TRUE_

	func KeepHistoryXT()
		KeepHistoryONXT()

	func KeepHistoONXT()
		KeepHistoryONXT()

	func KeepHistoXT()
		KeepHistoryONXT()

#--

func KeepHistoryOFF()
	_bKeepHisto = _FALSE_

	func DontKeepHistory()
		KeepHistoryOFF()

	func KeepHistoOFF()
		KeepHistoryOFF()

	func DontKeepHisto()
		KeepHistoryOFF()

func KeepHistoryOFFXT()
	_bKeepHistoXT = _FALSE_

	func DontKeepHistoryXT()
		KeepHistoryOFFXT()

	func KeepHistoOFFXT()
		KeepHistoryOFFXT()

	func DontKeepHistoXT()
		KeepHistoryOFFXT()
#--

func SetKeepingHistoryTo(bTrueOrFalse)
	if CheckParams()

		if NOT (isNumber(bTrueOrFalse) and isNumber(bTrueOrFalse) )
			StzRaise("Incorrect param type! bTrueOrFalse must be a number.")
		ok
	
		if NOT ( bTrueOrFalse = _FALSE_ or bTrueOrFalse = _TRUE_ )
			StzRaise("Incorrect param value! bTrueOrFalse must be 0 or 1.")
		ok

	ok

	_bKeepHisto = bTrueOrFalse


	#< @FunctionAlternativeForms

	func SetKeepHistoryTo(bTrueOrFalse)
		SetKeepingHistoryTo(bTrueOrFalse)

	func SetKeepingHistory(bTrueOrFalse)
		SetKeepingHistoryTo(bTrueOrFalse)

	func SetKeepHistory(bTrueOrFalse)
		SetKeepingHistoryTo(bTrueOrFalse)

	func SetKeepHistoTo(bTrueOrFalse)
		SetKeepingHistoryTo(bTrueOrFalse)

	#>

#---

func SetKeepingHistoryToXT(bTrueOrFalse, pcSuffix)
	if CheckParams()
		if NOT (isNumber(bTrueOrFalse) and isNumber(bTrueOrFalse) )
			StzRaise("Incorrect param type! bTrueOrFalse must be a number.")
		ok
	
		if NOT ( bTrueOrFalse = _FALSE_ or bTrueOrFalse = _TRUE_ )
			StzRaise("Incorrect param value! bTrueOrFalse must be 0 or 1.")
		ok

		if NOT isString(pcSuffix)
			StzRaise("Incorrect param type! pcSuffix must be a string!")
		ok

		if NOT ( pcSuffix = :VTTS or pcSuffix = :V )

		ok
	ok

	_bKeepHistoXT = bTrueOrFalse

	#< @FunctionAlternativeForms

	func SetKeepHistoryToXT(bTrueOrFalse)
		SetKeepingHistoryToXT(bTrueOrFalse)

	func SetKeepingHistoryXT(bTrueOrFalse)
		SetKeepingHistoryToXT(bTrueOrFalse)

	func SetKeepHistoryXT(bTrueOrFalse)
		SetKeepingHistoryToXT(bTrueOrFalse)

	func SetKeepHistoToXT(bTrueOrFalse)
		SetKeepingHistoryToXT(bTrueOrFalse)

	#>

func UpdateObjectHistory(aInfo)
	_aHisto = aInfo

func UpdateObjectHistoryXT(aInfo)
	_aHistoXT = aInfo


func TraceObjectHistory(pStzObj) # 

/*	if NOT (isObject(pStzObj) and IsStzObject(pStzObj))
		StzRaise("Incorrect param type! pStzObj must be a Softanza object.")
	ok
*/
	if KeepingHisto() = _TRUE_
		StartObjectTime()
		pStzObj.AddHistoricValue(pStzObj.Content())
	ok

	if KeepingHistoXT() = _TRUE_
		_cDisp_ = _aHistoXT[2]

		switch _cDisp_

		on :VTMS
			pStzObj.AddHistoricValueXT([
				This.Content(),
				This.StzType(),
				This.ExecTime(),
				This.SizeInBytes()
			])

		on :VTM
			pStzObj.AddHistoricValueXT([
				This.Content(),
				This.StzType(),
				This.ExecTime()
			])

		on :VTS
			pStzObj.AddHistoricValueXT([
				This.Content(),
				This.StzType(),
				This.SizeInBytes()
			])

		on :TMS
			pStzObj.AddHistoricValueXT([
				This.StzType(),
				This.ExecTime(),
				This.SizeInBytes()
			])

		on :VT
			pStzObj.AddHistoricValueXT([
				This.Content(),
				This.StzType()
			])

		on :VM
			pStzObj.AddHistoricValueXT([
				This.Content(),
				This.ExecTime()
			])

		on :VS
			pStzObj.AddHistoricValueXT([
				This.Content(),
				This.SizeInBytes()
			])

		on :TM
			pStzObj.AddHistoricValueXT([
				This.StzType(),
				This.ExecTime()
			])

		on :TS
			pStzObj.AddHistoricValueXT([
				This.StzType(),
				This.SizeInBytes()
			])

		on :MS
			pStzObj.AddHistoricValueXT([
				This.ExecTime(),
				This.SizeInBytes()
			])

		off
			StzRaise("Unsupported syntax!")
		ok

	func @TraceObjectHistory(pStzObj)
		TraceObjectHistory(pStzObj)

	func TraceStzObjectHistory(pStzObj)
		TraceObjectHistory(pStzObj)

	func @TraceStzObjectHistory(pStzObj)
		TraceObjectHistory(pStzObj)

#---

func KeepingTime()
	return _bKeepTime

	func KeepingExecutionTime()
		return KeepingTime()

func SetKeepingTimeTo(bTrueOrFalse)
	if CheckParams()
		if NOT (isNumber(bTrueOrFalse) and isNumber(bTrueOrFalse) )
			StzRaise("Incorrect param type! bTrueOrFalse must be a number.")
		ok
	
		if NOT ( bTrueOrFalse = _FALSE_ or bTrueOrFalse = _TRUE_ )
			StzRaise("Incorrect param value! bTrueOrFalse must be 0 or 1.")
		ok
	ok

	_bKeepTime = bTrueOrFalse


	#< @FunctionAlternativeForms

	func SetKeepingTime(bTrueOrFalse)
		SetKeepingTimeTo(bTrueOrFalse)

	func SetKeepTime(bTrueOrFalse)
		SetKeepingTimeTo(bTrueOrFalse)

	#>

func StartObjectTime()
	_nStartTimeInClocks = clock()

	func StartObjectTimeInClocks()
		StartObjectTime()

#-- Managing temporal values (used with @() inside objects)

func TempList()
	return $TEMP_LIST

func SetTempList(aList)
	if NOT isList(aList)
		StzRaise("Incorrect param type! aList must be a list.")
	ok

	$TEMP_LIST = aList

func EraseTempList()
	$TEMP_LIST = []

#--

func TempString()
	return $TEMP_STRING

func SetTempString(cStr)
	if NOT isString(cStr)
		StzRaise("Incorrect param type! cStr must be a string.")
	ok

	$TEMP_STRING = cStr

func EraseTempString()
	$TEMP_STRING = _NULL_

#--

func TempNumber()
	return $TEMP_NUMBER

func SetTempNumber(n)
	if NOT isNumber(n)
		StzRaise("Incorrect param type! n must be a number.")
	ok

	$TEMP_NUMBER = n

func EraseTempnumber()
	$TEMP_NUMBER = 0

#--

func TempObject()
	return $TEMP_OBJECT

func SetTempObject(pObj)
	if NOT isObject(pObj)
		StzRaise("Incorrect param type! pObj must be an object.")
	ok

	$TEMP_OBJECt = pObj

func EraseTempObject()
	$TEMP_STRING = _NULL_

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

		# Using Qt for concatenation because Ring is not performant
		# in concatenation large unicode strings (tested with 1M
		# arabic string)

		_@oQStrList_ = new QStringList()

		for @i = 1 to n
			_@oQStrList_.append(pStrOrItem)
		next

		_cResult_ = _@oQStrList_.join("")
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

	_bAsObject = _TRUE_
	_bAsObjectQ = _FALSE_

	return pObject

	# Must be reset to _FALSE_ everytime These() is used.

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

	_bAsObjectQ = _TRUE_
	_bAsObject = _FALSE_

	return pObject

	# Must be reset to _FALSE_ everytime These() is used.

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

	_bModifiable = _TRUE_
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

	_bThese = _TRUE_
	_bTheseQ = _FALSE_

	return p
	# Must be reset to _FALSE_ everytime These() is used.

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
	_bThese = _TRUE_
	_bTheseQ = _FALSE_

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
	# Must be reset to _FALSE_ everytime TheseNumbers() is used.

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
	_bThese = _TRUE_
	_bTheseQ = _FALSE_

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
	# Must be reset to _FALSE_ everytime TheseChars() is used.

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
	_bThese = _TRUE_
	_bTheseQ = _FALSE_

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
	# Must be reset to _FALSE_ everytime TheseStrings() is used.

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
	_bThese = _TRUE_
	_bTheseQ = _FALSE_

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
	# Must be reset to _FALSE_ everytime TheseLists() is used.

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
	_bThese = _TRUE_
	_bTheseQ = _FALSE_

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
	# Must be reset to _FALSE_ everytime TheseObjects() is used.

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
	_bThese = _TRUE_
	_bTheseQ = _FALSE_

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
	# Must be reset to _FALSE_ everytime TheseStzNumbers() is used.

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
	_bThese = _TRUE_
	_bTheseQ = _FALSE_

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
	# Must be reset to _FALSE_ everytime TheseStzChars() is used.

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
	_bThese = _TRUE_
	_bTheseQ = _FALSE_

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
	# Must be reset to _FALSE_ everytime TheseStzStrings() is used.

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
	_bThese = _TRUE_
	_bTheseQ = _FALSE_

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
	# Must be reset to _FALSE_ everytime TheseStzLists() is used.

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
	_bThese = _TRUE_
	_bTheseQ = _FALSE_

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
	# Must be reset to _FALSE_ everytime TheseStzObjects() is used.

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

func TheseQtObjects(p)
	_bThese = _TRUE_
	_bTheseQ = _FALSE_

	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsQtObject(p[i])
			aoResult + p[i]
		ok
	next

	return aoResult
	# Must be reset to _FALSE_ everytime TheseStzObjects() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseQtObjects(p)
		return TheseQtObjects(p)

	func EachOneOfTheseQtObjects(p)
		return TheseStzObjects(p)

	func AllTheseQtObjects(p)
		return TheseQtObjects(p)

	func AllOfTheseQtObjects(p)
		return TheseQtObjects(p)

	#==

	func @TheseQtObjects(p)
		return TheseQtObjects()

	func @EachOfTheseQtObjects(p)
		return TheseQtObjects(p)

	func @EachOneOfTheseQtObjects(p)
		return TheseQtObjects(p)

	func @AllTheseQtObjects(p)
		return TheseQtObjects(p)

	func @AllOfTheseQtObjects(p)
		return TheseQtObjects(p)

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

	_bTheseQ = _TRUE_
	_bThese = _FALSE_

	return p
	# _bTheseQ Must be reset to _FALSE_ everytime These() is used.

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

	_bTheseQ = _TRUE_
	_bThese = _FALSE_

	nLen = len(p)
	anResult = []

	for i = 1 to nLen
		if isNumber(p[i])
			anResult + p[i]
		ok
	next

	return new stzListOfNumbers(anResult)
	# _bTheseQ must be reset to _FALSE_ everytime TheseNumbers() is used.

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

	_bTheseQ = _TRUE_
	_bThese = _FALSE_

	nLen = len(p)
	acResult = []

	for i = 1 to nLen
		if isString(p[i])
			acResult + p[i]
		ok
	next

	return new stzListOfChars(acResult)
	# _bTheseQ must be reset to _FALSE_ everytime TheseChars() is used.

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

	_bTheseQ = _TRUE_
	_bThese = _FALSE_

	nLen = len(p)
	acResult = []

	for i = 1 to nLen
		if isString(p[i])
			acResult + p[i]
		ok
	next

	return new stzListOfStrings(acResult)
	# _bTheseQ must be reset to _FALSE_ everytime TheseStrings() is used.

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

	_bTheseQ = _TRUE_
	_bThese = _FALSE_

	nLen = len(p)
	aResult = []

	for i = 1 to nLen
		if isString(p[i])
			aResult + p[i]
		ok
	next

	return new stzListOfLists(aResult)
	# _bTheseQ must be reset to _FALSE_ everytime TheseLists() is used.

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

	_bTheseQ = _TRUE_
	_bThese = _FALSE_

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i])
			aoResult + p[i]
		ok
	next

	return new stzListOfObjects(aoResult)
	# _bTheseQ must be reset to _FALSE_ everytime TheseObjects() is used.

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

	_bTheseQ = _TRUE_
	_bThese = _FALSE_

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzNumber(p[i])
			aoResult + p[i]
		ok
	next

	return new stzListOfNumbers(aoResult)
	# _bTheseQ must be reset to _FALSE_ everytime TheseStzNumbers() is used.

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

	_bTheseQ = _TRUE_
	_bThese = _FALSE_

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzChar(p[i])
			aoResult + p[i]
		ok
	next

	return aoResult
	# _bTheseQ must be reset to _FALSE_ everytime TheseStzChars() is used.

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

	_bTheseQ = _TRUE_
	_bThese = _FALSE_

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzString(p[i])
			aoResult + p[i]
		ok
	next

	return new stzListOfStrings(aoResult)
	# Must be reset to _FALSE_ everytime TheseStzStrings() is used.

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

	_bTheseQ = _TRUE_
	_bThese = _FALSE_

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzList(p[i])
			aoResult + p[i]
		ok
	next

	return new stzListOfLists(aoResult)
	# _bTheseQ must be reset to _FALSE_ everytime TheseStzLists() is used.

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

	_bTheseQ = _TRUE_
	_bThese = _FALSE_

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsStzObject(p[i])
			aoResult + p[i]
		ok
	next

	return new stzListOfObjects(aoResult)
	# _bTheseQ = _TRUE_ must be reset to _FALSE_ everytime TheseStzObjects() is used.

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

func TheseQtObjectsQ(p)
	
	if CheckingParams()
		if NOT isList(p)
			StzRaise("Incorrect param type! p must be a list.")
		ok
	ok

	_bTheseQ = _TRUE_
	_bThese = _FALSE_

	nLen = len(p)
	aoResult = []

	for i = 1 to nLen
		if isObject(p[i]) and IsQtObject(p[i])
			aoResult + p[i]
		ok
	next

	return new stzListOfObjects(aoResult)
	# _bTheseQ must be reset to _FALSE_ everytime TheseStzObjects() is used.

	#< @FunctionAlternativeForms

	func EachOfTheseQtObjectsQ(p)
		return TheseQtObjectsQ(p)

	func EachOneOfTheseQtObjectsQ(p)
		return TheseStzObjectsQ(p)

	func AllTheseQtObjectsQ(p)
		return TheseQtObjectsQ(p)

	func AllOfTheseQtObjectsQ(p)
		return TheseQtObjectsQ(p)

	#==

	func @TheseQtObjectsQ(p)
		return TheseQtObjectsQ()

	func @EachOfTheseQtObjectsQ(p)
		return TheseQtObjectsQ(p)

	func @EachOneOfTheseQtObjectsQ(p)
		return TheseQtObjectsQ(p)

	func @AllTheseQtObjectsQ(p)
		return TheseQtObjectsQ(p)

	func @AllOfTheseQtObjectsQ(p)
		return TheseQtObjectsQ(p)

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

func SetParamCheckingTo(bTrueOrFalse) #TODO // Test it!
	_bParamCheck = bTrueOrFalse
 
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

func ActivateParamChecking()
	_bParamCheck = _TRUE_

	#< FunctionAlternativeForms

	func ActivateParamCheck()
		ActivateParamChecking()

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

func DesactivateParamChecking()
	_bParamCheck = _FALSE_

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

func ParamChecking()
	return _bParamCheck

	#< @FunctionAlternativeForms

	func ParamsChecking()
		return _bParamCheck

	func ParamCheck()
		return _bParamCheck

	func ParamsCheck()
		return _bParamCheck

	func CheckParam()
		return _bParamCheck

	func CheckingParam()
		return _bParamCheck

	func CheckParams()
		return _bParamCheck

	func CheckingParams()
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

	#>

#--

func EarlyCheck()
	return _bEarlyCheck

	func EarlyChecks()
		return _bEarlyCheck

func EarlyCheckOn()
	_bEarlyCheck = _TRUE_

	func ActivateEarlyCheck()
		_bEarlyCheck = _TRUE_

	func EarlyChecksOn()
		_bEarlyCheck = _TRUE_

	func ActivateEarlyChecks()
		_bEarlyCheck = _TRUE_

func EarlyCheckOff()
	_bEarlyCheck = _FALSE_

	func DeactivateEarlyCheck()
		_bEarlyCheck = _FALSE_

	func EarlyChecksOff()
		_bEarlyCheck = _FALSE_

	func DectivateEarlyChecks()
		_bEarlyCheck = _FALSE_

func SetEarlyCheck(b)
	if CheckingParams()
		if NOT (isNumber(b) and (b = 0 or b = 1) )
			StzRaise("Incorrect param! b must be a boolean (_TRUE_ or _FALSE_).")
		ok
	ok

	_bEarlyCheck = b

	func SetEarlyCheckTo(b)
		SetEarlyCheck(b)

	func SetEarlyChecks(b)
		SetEarlyCheck(b)

	func SetEarlyChecksTo(b)
		SetEarlyCheck(b)

#--

func StartingAt(p)
	if isNumber(p)
		return p

	but isString(p)
		p = lower(p)

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

	func @StartingAt(p)
		return StartingAt(p)

func StoppingAt(p)
	if isNumber(p)
		return p

	but isString(p)
		p = lower(p)

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

	func @StoppingAt(p)
		return StoppingAt(p)

	func EndingAt(p)
		return StoppingAt(p)

	func @EndingAt(p)
		return StoppingAt(p)

#==

func Bounds(pBounds)

	if NOT ( isString(pBounds) or ( isList(pBounds) and len(pBounds) = 2 and isString(pBounds[1]) ) )
			StzRaise("Incorrect param type! pBounds must be a string or a list of two strings.")
	ok

	if isString(pBounds)
		return [ pBounds, pBounds ]
	ok

	# Now, pBounds is a list of two items where 1st item is a string

	p1 = pBounds[1]
	p2 = pBounds[2]

	if isList(p2) and StzListQ(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if NOT isString(p2)
		StzRaise("Incorrect param type! The second item of pBounds must be also a string.")
	ok

	return [ p1, p2 ]


	func @Bounds(pBounds)
		return Bounds(pBounds)

#--

func Direction(p)
	if isString(p)

		p = lower(p)

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

	func @Direction(p)
		return Direction(p)
	
#--


func IsCaseSensitive(p)

	if (isNumber(p) and p = 1) or
	   (isList(p) and Q(p).IsCaseSensitiveNamedParam() and p[2] = 1)

		return _TRUE_

	but (isNumber(p) and p = 0) or
	   (isList(p) and Q(p).IsCaseSensitiveNamedParam() and p[2] = 0)

		return _FALSE_

	else
		StzRaise("Incorrect param! p must be _TRUE_ or _FALSE_.")
	ok

	func @IsCaseSensitive(p)
		return IsCaseSensitive(p)

func CaseSensitive(p)

	if isNumber(p)
		if p = 1
			return _TRUE_
		but p = 0
			return _FALSE_
		ok

	but isList(p) and StzListQ(p).IsCaseSensitiveNamedParam()
		p = p[2]

		if isNumber(p)
			if p = 1
				return _TRUE_
			but p = 0
				return _FALSE_
			ok
		ok

	else
		StzRaise("Incorrect param type! p must be a bolean (_TRUE_ or _FALSE_).")
	ok


	func @CaseSensitive(p)
		return CaseSensitive(p)

#--

func StzKeywords()
	return _acStzCCKeywords

	func StzCCodeKeywords()
		return StzKeywords()

	func StzConditionalCodeKeywords()
		return StzKeywords()

func ASpace() # We don't use Space() because it is reserved by Ring standard library
	return NSpaces(1)

	func SingleSpace()
		return ASpace()

	func BlankSpace()
		return ASpace()

	func OneSpace()
		return ASpace()

func DoubleSpace()
	return NSpaces(2)

	func DoubleBlankSpace()
		return DoubleSpace()

func NSpaces(n)
	return copy(" ", n)

	def NBlankSpaces(n)
		return NSpaces()

func QuietEqualityRatio()
	return _nQuietEqualityRatio

	func ApproximateEqualityRatio()
		return _nQuietEqualityRatio

	func ApproximativeEqualityRatio()
		return _nQuietEqualityRatio

func SetQuietEqualityRatio(n)
	if NOT isNumber(n)
		StzRaise("Incorrect param type! n must be a number.")
	ok

	if n >= 0 and n <= 1
		_nQuietEqualityRatio = n
	ok

	def SetApproximateEqualityRatio(n)
		SetQuietEqualityRatio(n)

	def SetApproximativeEqualityRation(n)
		SetQuietEqualityRatio(n)

func RingTypes()
	return _aRingTypes

func RingFunctions()
	return _acRingFunctions

func RingKeywords()
	return _acRingKeywords()

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

	if isList(paMessage) and StzListQ(paMessage).IsRaiseNamedParam()
		cWhere = paMessage[ :Where  ]
		cWhat  = paMessage[ :What   ]
		cWhy   = paMessage[ :Why    ]
		cTodo  = paMessage[ :Todo   ]

	

		if NOT StzListQ([ cWhere, cWhat, cWhy, cTodo ]).IsListOfStrings()
			raise("Error in StzRaise param type!")
		ok
	
		cFile = StzStringQ(cWhere).WithoutSpaces()
		if isNull(cWhere)
			raise("Error in StzRaise --> Where the error happened!")
		ok
	
		cWhat = StzStringQ(cWhat).Simplified()
		cwhay = StzStringQ(cWhy).Simplified()
		cTodo = StzStringQ(cTodo).Simplified()
	
		cErrorMsg = "in file " + paMessage[:Where] + ":" + NL
	
		if cWhat != _NULL_
			cErrorMsg += "   What : " + paMessage[:What] + NL
		ok
	
		if cWhy != _NULL_
			cErrorMsg += "   Why  : " + paMessage[:Why]  + NL
		ok
	
		if cTodo != _NULL_
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

func IsClassName(cStr)
	if CheckingParams()
		if NOT isString(cStr)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok
	ok

	bResult = find( ClassesNames(), cStr)
	return bResult

	func @IsClassName(pcStr)
		return IsClassName

	func IsAClassName(pcStr)
		return IsClassName

func IsPackageName(cStr)
	if CheckingParams()
		if NOT isString(cStr)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok
	ok

	bResult = find( packages(), lower(cStr))
	return bResult

	func @IsPackageName(cStr)
		return IsPackageName(cStr)

	func IsAPackageName(cStr)
		return IsPackageName(cStr)

	func @IsAPackageName(cStr)
		return IsPackageName(cStr)


func Vars()
	return globals()

#----

func StzFindCS(pThing, paIn, pCaseSensitive)
	if isList(paIn) and Q(paIn).IsInNamedParam()
		paIn = paIn[2]
	ok

	anPos = Q(paIn).FindAllCS(pThing, pCaseSensitive)
	return anPos

func StzFind(pThing, paIn)
	if isList(paIn) and Q(paIn).IsInNamedParam()
		paIn = paIn[2]
	ok

	anPos = Q(paIn).FindAll(pThing)

	return anPos

#-----

func IsNumberOrNumberInString(p)
	if isNumber(p) or IsNumberInString(p)
		return _TRUE_
	else
		return _FALSE_
	ok

	func @IsNumberOrNumberInString(p)
		return IsNumberOrNumberInString(p)

	func IsNumberInStringOrNumber(p)
		return IsNumberOrNumberInString(p)

	func @IsNumberInStringOrNumber(p)
		return IsNumberOrNumberInString(p)

func IsNumberOrString(p)
	if isNumber(p) or isString(p)
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func IsStringOrNumber(p)
		return IsNumberOrString(p)

	#-- Alternatives added so the function can be called from
	#-- inside an object that already contains a method of
	#-- the same name obj.IsNumberOrString()

	func @IsNumberOrString(p)
		return IsNumberOrString(p)

	func @IsStringOrNumber(p)
		return IsNumberOrString(p)

	#--

	func IsANumberOrString(p)
		return IsNumberOrString(p)

	func IsANumberOrAString(p)
		return IsNumberOrString(p)

	func IsAStringOrNumber(p)
		return IsNumberOrString(p)

	func IsAStringOrANumber(p)
		return IsNumberOrString(p)


	func @IsANumberOrString(p)
		return IsNumberOrString(p)

	func @IsANumberOrAString(p)
		return IsNumberOrString(p)

	func @IsAStringOrNumber(p)
		return IsNumberOrString(p)

	func @IsAStringOrANumber(p)
		return IsNumberOrString(p)

	#>

func IsNumberOrList(p)
	if isNumber(p) or isList(p)
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func IsListOrNumber(p)
		return This.IsNumberOrList(p)

	func @IsNumberOrList(p)
		return IsNumberOrList(p)

	func @IsListOrNumber(p)
		return IsNumberOrList(p)

	#--

	func IsANumberOrList(p)
		return IsNumberOrList(p)

	func IsANumberOrAList(p)
		return IsNumberOrList(p)

	func IsAListOrNumber(p)
		return IsNumberOrList(p)

	func IsAListOrANumber(p)
		return IsNumberOrList(p)


	func @IsANumberOrList(p)
		return IsNumberOrList(p)

	func @IsANumberOrAList(p)
		return IsNumberOrList(p)

	func @IsAListOrNumber(p)
		return IsNumberOrList(p)

	func @IsAListOrANumber(p)
		return IsNumberOrList(p)

	#>

func IsNumberOrObject(p)
	if isNumber(p) or isObject(p)
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func IsObjectOrNumber(p)
		return This.IsNumberOrObject(p)

	func @IsNumberOrSObject(p)
		return IsNumberOrObject(p)

	func @IsObjectOrNumber(p)
		return IsNumberOrObject(p)

	#--

	func IsANumberOrObject(p)
		return IsNumberOrObject(p)

	func IsANumberOrAObject(p)
		return IsNumberOrObject(p)

	func IsAObjectOrNumber(p)
		return IsNumberOrObject(p)

	func IsAObjectOrANumber(p)
		return IsNumberOrObject(p)


	func @IsANumberOrObject(p)
		return IsNumberOrObject(p)

	func @IsANumberOrAObject(p)
		return IsNumberOrObject(p)

	func @IsAObjectOrNumber(p)
		return IsNumberOrObject(p)

	func @IsAObjectOrANumber(p)
		return IsNumberOrObject(p)

	#>

func IsStringOrList(p)
	if isString(p) or isList(p)
		return _TRUE_
	else
		return _FALSE_
	ok

	def IsListOrString(p)
		return IsStringOrList(p)

	func @IsStringOrList(p)
		return IsStringOrList(p)

	func @IsListOrString(p)
		return IsStringOrList(p)

func IsStringOrListOfStrings(p)
	if isString(p) or IsListOfStrings(p)
		return _TRUE_
	else
		return _FALSE_
	ok

	def IsListOfStringsOrString(p)
		return IsStringOrListOfStrings(p)

	func @IsStringOrListOfStrings(p)
		return IsStringOrListOfStrings(p)

	func @IsListOfStringsOrString(p)
		return IsStringOrListOfStrings(p)

func IsStringOrObject(p)
	if isString(p) or isObject(p)
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	def IsObjectOrString(p)
		return IsStringOrObject(p)

	func @IsStringOrObject(p)
		return IsStringOrObject(p)

	func @IsObjectOrString(p)
		return IsStringOrObject(p)

	#--

	func IsAStringOrObject(p)
		return IsStringOrObject(p)

	func IsAStringOrAObject(p)
		return IsStringOrObject(p)

	func IsAObjectOrString(p)
		return IsStringOrObject(p)

	func IsAObjectOrAString(p)
		return IsStringOrObject(p)


	func @IsAStringOrObject(p)
		return IsStringOrObject(p)

	func @IsAStringOrAObject(p)
		return IsStringOrObject(p)

	func @IsAObjectOrString(p)
		return IsStringOrObject(p)

	func @IsAObjectOrAString(p)
		return IsStringOrObject(p)

	#>

func IsListOrObject(p)
	if isList(p) or isObject(p)
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	def IsObjectOrList(p)
		return IsListOrObject(p)

	func @IsListOrObject(p)
		return IsListOrObject(p)

	func @IsObjectOrList(p)
		return IsListOrObject(p)

	#--

	func IsAListOrObject(p)
		return IsListOrObject(p)

	func IsAListOrAObject(p)
		return IsListOrObject(p)

	func IsAObjectOrList(p)
		return IsListOrObject(p)

	func IsAObjectOrAList(p)
		return IsListOrObject(p)


	func @IsAListOrObject(p)
		return IsListOrObject(p)

	func @IsAListOrAObject(p)
		return IsListOrObject(p)

	func @IsAObjectOrList(p)
		return IsListOrObject(p)

	func @IsAObjectOrAList(p)
		return IsListOrObject(p)

	#>

func IsNumberOrStringOrList(p)
	if isNumber(p) or isString(p) or isList(p)
		return _TRUE_
	else
		return _FALSE_
	ok

	#<@FunctionAlternativeForms

	def IsNumberOrListOrString(p)
		return IsNumberOrStringOrList(p)

	def IsStringOrNumberOrList(p)
		return IsNumberOrStringOrList(p)

	def IsStringOrListOrNumber(p)
		return IsNumberOrStringOrList(p)

	def IsListOrNumberOrString(p)
		return IsNumberOrStringOrList(p)

	def IsListOrStringOrNumber(p)
		return IsNumberOrStringOrList(p)

	#--

	def @IsNumberOrStringOrList(p)
		return IsNumberOrStringOrList(p)

	def @IsNumberOrListOrString(p)
		return IsNumberOrStringOrList(p)

	def @IsStringOrNumberOrList(p)
		return IsNumberOrStringOrList(p)

	def @IsStringOrListOrNumber(p)
		return IsNumberOrStringOrList(p)

	def @IsListOrNumberOrString(p)
		return IsNumberOrStringOrList(p)

	def @IsListOrStringOrNumber(p)
		return IsNumberOrStringOrList(p)

	#>

#--

func IsCharOrNumber(p)
	if isNumber(p) or IsChar(p)
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func IsNumberOrChar(p)
		return IsCharOrNumber(p)

	func @IsCharOrNumber(p)
		return IsCharOrNumber(p)

	func @IsNumberOrChar(p)
		return IsCharOrNumber(p)

	#--

	func IsACharOrNumber(p)
		return IsCharOrNumber(p)

	func IsACharOrANumber(p)
		return IsCharOrNumber(p)

	func IsANumberOrChar(p)
		return IsCharOrNumber(p)

	func IsANumberOrAChar(p)
		return IsCharOrNumber(p)


	func @IsACharOrNumber(p)
		return IsCharOrNumber(p)

	func @IsACharOrANumber(p)
		return IsCharOrNumber(p)

	func @IsANumberOrChar(p)
		return IsCharOrNumber(p)

	func @IsANumberOrAChar(p)
		return IsCharOrNumber(p)

	#>

func IsCharOrString(p)
	if isString(p)
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func IsStringOrChar(p)
		return IsCharOrString(p)

	func @IsCharOrString(p)
		return IsCharOrString(p)

	func @IsStringOrChar(p)
		return IsCharOrString(p)

	#--

	func IsACharOrString(p)
		return IsCharOrString(p)

	func IsACharOrAString(p)
		return IsCharOrString(p)

	func IsAStringOrChar(p)
		return IsCharOrString(p)

	func IsAStringOrAChar(p)
		return IsCharOrString(p)


	func @IsACharOrString(p)
		return IsCharOrString(p)

	func @IsACharOrAString(p)
		return IsCharOrString(p)

	func @IsAStringOrChar(p)
		return IsCharOrString(p)

	func @IsAStringOrAChar(p)
		return IsCharOrString(p)

	#>

func IsCharOrList(p)
	if isList(p) or IsChar(p)
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func IsListOrChar(p)
		return IsCharOrList(p)

	func @IsCharOrList(p)
		return IsCharOrList(p)

	func @IsListOrChar(p)
		return IsCharOrList(p)

	#--

	func IsACharOrList(p)
		return IsCharOrList(p)

	func IsACharOrAList(p)
		return IsCharOrList(p)

	func IsAListOrChar(p)
		return IsCharOrList(p)

	func IsAListOrAChar(p)
		return IsCharOrList(p)


	func @IsACharOrList(p)
		return IsCharOrList(p)

	func @IsACharOrAList(p)
		return IsCharOrList(p)

	func @IsAListOrChar(p)
		return IsCharOrList(p)

	func @IsAListOrAChar(p)
		return IsCharOrList(p)

	#>

func IsCharOrObject(p)
	if isObject(p) or IsChar(p)
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func IsObjectOrChar(p)
		return IsCharOrObject(p)

	func @IsCharOrObject(p)
		return IsCharOrObject(p)

	func @IsObjectOrChar(p)
		return IsCharOrObject(p)

	#--

	func IsACharOrObject(p)
		return IsCharOrObject(p)

	func IsACharOrAObject(p)
		return IsCharOrObject(p)

	func IsAObjectOrChar(p)
		return IsCharOrObject(p)

	func IsAObjectOrAChar(p)
		return IsCharOrObject(p)


	func @IsACharOrObject(p)
		return IsCharOrObject(p)

	func @IsACharOrAObject(p)
		return IsCharOrObject(p)

	func @IsAObjectOrChar(p)
		return IsCharOrObject(p)

	func @IsAObjectOrAChar(p)
		return IsCharOrObject(p)

	#>

#--

func ListOfListsOfStzTypes() #TODO // complete the list
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

func BothAreNumbers(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isNumber(p1) and isNumber(p2)
		return _TRUE_
	else
		return _FALSE_
	ok

	func AreBothNumbers(p1, p2)
		return BothAreNumbers(p1, p2)

	#-- Alternatives added so the function can be called from
	#-- inside an object that already contains a method of
	#-- the same name obj.BothAreNumbers()

	func @BothAreNumbers(p1, p2)
		return BothAreNumbers(p1, p2)

	func @AreBothNumbers(p1, p2)
		return BothAreNumbers(p1, p2)

func BothAreNumbersInStrings(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isString(p1) and isString(p2) and
	   Q(p1).IsNumberInString() and
	   Q(p2).IsNumberInString()

		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func AreBothNumbersInStrings(p1, p2)
		return BothAreNumbersInStrings(p1, p2)

	func @BothAreNumbersInStrings(p1, p2)
		return BothAreNumbersInStrings(p1, p2)

	func @AreBothNumbersInStrings(p1, p2)
		return BothAreNumbersInStrings(p1, p2)

	#--

	func BothAreNumbersInString(p1, p2)
		return BothAreNumbersInStrings(p1, p2)

	func AreBothNumbersInString(p1, p2)
		return BothAreNumbersInStrings(p1, p2)

	func @BothAreNumbersInString(p1, p2)
		return BothAreNumbersInStrings(p1, p2)

	func @AreBothNumbersInString(p1, p2)
		return BothAreNumbersInStrings(p1, p2)

	#>

func BothAreIntegers(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isNumber(p1) and isNumber(p2) and Q(p1).IsInteger() and Q(p2).IsInteger()
		return _TRUE_
	else
		return _FALSE_
	ok

	func AreBothIntegers(p1, p2)
		return BothAreIntegers(p1, p2)

	func @BothAreIntegers(p1, p2)
		return BothAreIntegers(p1, p2)

	func @AreBothIntegers(p1, p2)
		return BothAreIntegers(p1, p2)

func BothAreIntegersInStrings(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isString(p1) and isString(p2) and
	   Q(p1).IsIntegerInString() and Q(p2).IsIntegerInString()

		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func AreBothIntegersInStrings(p1, p2)
		return BothAreIntegersInStrings(p1, p2)

	func @BothAreIntegersInStrings(p1, p2)
		return BothAreIntegersInStrings(p1, p2)

	func @AreBothIntegersInStrings(p1, p2)
		return BothAreIntegersInStrings(p1, p2)

	#--

	func BothAreIntegersInString(p1, p2)
		return BothAreIntegersInStrings(p1, p2)

	func AreBothIntegersInString(p1, p2)
		return BothAreIntegersInStrings(p1, p2)

	func @BothAreIntegersInString(p1, p2)
		return BothAreIntegersInStrings(p1, p2)

	func @AreBothIntegersInString(p1, p2)
		return BothAreIntegersInStrings(p1, p2)

	#>

func BothAreReals(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isNumber(p1) and isNumber(p2) and Q(p1).IsReal() and Q(p2).IsReal()
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func AreBothReals(p1, p2)
		return BothAreReals(p1, p2)

	func @BothAreReals(p1, p2)
		return BothAreReals(p1, p2)

	func @AreBothReals(p1, p2)
		return BothAreReals(p1, p2)

	#--

	func BothAreRealNumbers(p1, p2)
		return BothAreReals(p1, p2)

	func AreBothRealNumbers(p1, p2)
		return BothAreReals(p1, p2)

	func @BothAreRealNumbers(p1, p2)
		return BothAreReals(p1, p2)

	func @AreBothRealNumbers(p1, p2)
		return BothAreReals(p1, p2)

	#>

func BothAreRealsInStrings(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isString(p1) and isString(p2) and
	   Q(p1).IsRealInString() and Q(p2).IsRealInString()

		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func AreBothRealsInStrings(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	func @BothAreRealsInStrings(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	func @AreBothRealsInStrings(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	#--

	func BothAreRealsInString(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	func AreBothRealsInString(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	func @BothAreRealsInString(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	func @AreBothRealsInString(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	#==

	func BothAreRealInString(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	func AreBothRealInString(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	func @BothAreRealInString(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	func @AreBothRealInString(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	#--

	func BothAreRealInStrings(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	func AreBothRealInStrings(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	func @BothAreRealInStrings(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	func @AreBothRealInStrings(p1, p2)
		return BothAreRealsInStrings(p1, p2)

	#>

func BothArePairsOfNumbers(p1, p2)
	if BothAreLists(p1, p2) and
	   isList(p1) and Q(p1).IsPairOfNumbers() and
	   isList(p2) and Q(p2).IsPairOfNumbers()

		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func AreBothPairsOfNumbers(p1, p2)
		return BothArePairsOfNumbers(p1, p2)

	func @BothArePairsOfNumbers(p1, p2)
		return BothArePairsOfNumbers(p1, p2)

	func @AreBothPairsOfNumbers(p1, p2)
		return BothArePairsOfNumbers(p1, p2)


	#--

	func BothArePairOfNumbers(p1, p2)
		return BothArePairsOfNumbers(p1, p2)

		func AreBothPairOfNumbers(p1, p2)
			return BothArePairsOfNumbers(p1, p2)
	
	func @BothArePairOfNumbers(p1, p2)
		return BothArePairsOfNumbers(p1, p2)

		func @AreBothPairOfNumbers(p1, p2)
			return BothArePairsOfNumbers(p1, p2)

	func BothArePairOfNumber(p1, p2)
		return BothArePairsOfNumbers(p1, p2)

		func AreBothPairOfNumber(p1, p2)
			return BothArePairsOfNumbers(p1, p2)
	
	func @BothArePairOfNumber(p1, p2)
		return BothArePairsOfNumbers(p1, p2)

		func @AreBothPairOfNumber(p1, p2)
			return BothArePairsOfNumbers(p1, p2)

	func BothArePairsOfNumber(p1, p2)
		return BothArePairsOfNumbers(p1, p2)

		func AreBothPairsOfNumber(p1, p2)
			return BothArePairsOfNumbers(p1, p2)
	
	func @BothArePairsOfNumber(p1, p2)
		return BothArePairsOfNumbers(p1, p2)

		func @AreBothPairsOfNumber(p1, p2)
			return BothArePairsOfNumbers(p1, p2)

	#>

func BothArePairsOfStrings(p1, p2)
	if BothAreLists(p1, p2) and
	   isList(p1) and Q(p1).IsPairOfStrings() and
	   isList(p2) and Q(p2).IsPairOfStrings()

		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func AreBothPairsOfStrings(p1, p2)
		return BothArePairsOfStrings(p1, p2)

	func @BothArePairsOfStrings(p1, p2)
		return BothArePairsOfStrings(p1, p2)

	func @AreBothPairsOfStrings(p1, p2)
		return BothArePairsOfStrings(p1, p2)

	#--

	func BothArePairOfStrings(p1, p2)
		return BothArePairsOfStrings(p1, p2)

		func AreBothPairOfStrings(p1, p2)
			return BothArePairsOfStrings(p1, p2)
	
	func @BothArePairOfStrings(p1, p2)
		return BothArePairsOfStrings(p1, p2)

		func @AreBothPairOfStrings(p1, p2)
			return BothArePairsOfStrings(p1, p2)

	func BothArePairOfString(p1, p2)
		return BothArePairsOfStrings(p1, p2)

		func AreBothPairOfString(p1, p2)
			return BothArePairsOfStrings(p1, p2)
	
	func @BothArePairOfString(p1, p2)
		return BothArePairsOfStrings(p1, p2)

		func @AreBothPairOfString(p1, p2)
			return BothArePairsOfStrings(p1, p2)

	func BothArePairsOfString(p1, p2)
		return BothArePairsOfStrings(p1, p2)

		func AreBothPairsOfString(p1, p2)
			return BothArePairsOfStrings(p1, p2)
	
	func @BothArePairsOfString(p1, p2)
		return BothArePairsOfStrings(p1, p2)

		func @AreBothPairsOfString(p1, p2)
			return BothArePairsOfStrings(p1, p2)
	#>

func BothArePairsOfLists(p1, p2)
	if BothAreLists(p1, p2) and
	   isList(p1) and Q(p1).IsPairOfLists() and
	   isList(p2) and Q(p2).IsPairOfLists()

		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func AreBothPairsOfLists(p1, p2)
		return BothArePairsOfLists(p1, p2)

	func @BothArePairsOfLists(p1, p2)
		return BothArePairsOfLists(p1, p2)

	func @AreBothPairsOfLists(p1, p2)
		return BothArePairsOfLists(p1, p2)

	#--

	func BothArePairOfLists(p1, p2)
		return BothArePairsOfLists(p1, p2)

		func AreBothPairOfLists(p1, p2)
			return BothArePairsOfLists(p1, p2)
	
	func @BothArePairOfLists(p1, p2)
		return BothArePairsOfLists(p1, p2)

		func @AreBothPairOfLists(p1, p2)
			return BothArePairsOfLists(p1, p2)

	func BothArePairOfList(p1, p2)
		return BothArePairsOfLists(p1, p2)

		func AreBothPairOfList(p1, p2)
			return BothArePairsOfLists(p1, p2)
	
	func @BothArePairOfList(p1, p2)
		return BothArePairsOfLists(p1, p2)

		func @AreBothPairOfList(p1, p2)
			return BothArePairsOfLists(p1, p2)

	func BothArePairsOfList(p1, p2)
		return BothArePairsOfLists(p1, p2)

		func AreBothPairsOfList(p1, p2)
			return BothArePairsOfLists(p1, p2)
	
	func @BothArePairsOfList(p1, p2)
		return BothArePairsOfLists(p1, p2)

		func @AreBothPairsOfList(p1, p2)
			return BothArePairsOfLists(p1, p2)

	#>

func BothArePairsOfObjects(p1, p2)
	if BothAreLists(p1, p2) and
	   isList(p1) and Q(p1).IsPairOfObjects() and
	   isList(p2) and Q(p2).IsPairOfObjects()

		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func AreBothPairsOfObjects(p1, p2)
		return BothArePairsOfObjects(p1, p2)

	func @BothArePairsOfObjects(p1, p2)
		return BothArePairsOfObjects(p1, p2)

	func @AreBothPairsOfObjects(p1, p2)
		return BothArePairsOfObjects(p1, p2)

	#--

	func BothArePairOfObjects(p1, p2)
		return BothArePairsOfObjects(p1, p2)

		func AreBothPairOfObjects(p1, p2)
			return BothArePairsOfObjects(p1, p2)
	
	func @BothArePairOfObjects(p1, p2)
		return BothArePairsOfObjects(p1, p2)

		func @AreBothPairOfObjects(p1, p2)
			return BothArePairsOfObjects(p1, p2)

	func BothArePairOfObject(p1, p2)
		return BothArePairsOfObjects(p1, p2)

		func AreBothPairOfObject(p1, p2)
			return BothArePairsOfObjects(p1, p2)
	
	func @BothArePairOfObject(p1, p2)
		return BothArePairsOfObjects(p1, p2)

		func @AreBothPairOfObject(p1, p2)
			return BothArePairsOfObjects(p1, p2)

	func BothArePairsOfObject(p1, p2)
		return BothArePairsOfObjects(p1, p2)

		func AreBothPairsOfObject(p1, p2)
			return BothArePairsOfObjects(p1, p2)
	
	func @BothArePairsOfObject(p1, p2)
		return BothArePairsOfObjects(p1, p2)

		func @AreBothPairsOfObject(p1, p2)
			return BothArePairsOfObjects(p1, p2)

	#>

func BothAreCharsInComputableForm(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	bResult = _FALSE_

	if BothAreStringsInComputableForm(p1, p2)
		c1 = '"'
		c2 = "'"

		bOk1 = StzStringQ(p1).RemoveManyQ([ c1, c2 ]).IsAChar()
		bOk2 = StzStringQ(p2).RemoveManyQ([ c1, c2 ]).IsAChar()

		if bOk1 and bOk2
			bResult = _TRUE_
		ok
	ok

	return bResult
	
	func AreBothCharsInComputableForm(p1, p2)
		return BothAreCharsInComputableForm(p1, p2)

	#-- Alternatives added so the function can be called from
	#-- inside an object that already contains a method of
	#-- the same name obj.BothAreNumbersInStrings()

	func @BothAreCharsInComputableForm(p1, p2)
		return BothAreCharsInComputableForm(p1, p2)

	func @AreBothCharsInComputableForm(p1, p2)
		return BothAreCharsInComputableForm(p1, p2)
	 
func BothAreStringsInComputableForm(p1, p2)
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

		return _TRUE_

	else
		return _FALSE_
	ok

	func AreBothStringsInComputableForm(p1, p2)
		return BothAreStringsInComputableForm(p1, p2)

	#-- Alternatives added so the function can be called from
	#-- inside an object that already contains a method of
	#-- the same name obj.BothAreStringsInComputableForm()

	func @BothAreStringsInComputableForm(p1, p2)
		return BothAreStringsInComputableForm(p1, p2)

	func @AreBothStringsInComputableForm(p1, p2)
		return BothAreStringsInComputableForm(p1, p2)

func BothAreStzNumbers(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if IsStzNumber(p1) and IsStzNumber(p2)
		return _TRUE_
	else
		return _FALSE_
	ok

	func AreBothStzNumbers(p1, p2)
		return BothAreStzNumbers(p1, p2)

	#-- Alternatives added so the function can be called from
	#-- inside an object that already contains a method of
	#-- the same name obj.BothAreStzNumbers()

	func @BothAreStzNumbers(p1, p2)
		return BothAreStzNumbers(p1, p2)

	func @AreBothStzNumbers(p1, p2)
		return BothAreStzNumbers(p1, p2)

func BothAreStrings(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isString(p1) and isString(p2)
		return _TRUE_
	else
		return _FALSE_
	ok

	func AreBothStrings(p1, p2)
		return BothAreStrings(p1, p2)

	#-- Alternatives added so the function can be called from
	#-- inside an object that already contains a method of
	#-- the same name obj.BothAreStrings()

	func @BothAreStrings(p1, p2)
		return BothAreStrings(p1, p2)

	func @AreBothStrings(p1, p2)
		return BothAreStrings(p1, p2)

func BothAreStzStrings(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if IsStzString(p1) and IsStzString(p2)
		return _TRUE_
	else
		return _FALSE_
	ok

	func AreBothStzStrings(p1, p2)
		return BothAreStzStrings(p1, p2)

	#-- Alternatives added so the function can be called from
	#-- inside an object that already contains a method of
	#-- the same name obj.BothAreStzStrings()

	func @BothAreStzStrings(p1, p2)
		return BothAreStzStrings(p1, p2)

	func @AreBothStzStrings(p1, p2)
		eturn BothAreStzStrings(p1, p2)

func BothAreLists(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isList(p1) and isList(p2)
		return _TRUE_
	else
		return _FALSE_
	ok

	func AreBothLists(p1, p2)
		return BothAreLists(p1, p2)

	#-- Alternatives added so the function can be called from
	#-- inside an object that already contains a method of
	#-- the same name obj.BothAreLists()

	func @BothAreLists(p1, p2)
		return BothAreLists(p1, p2)

	func @AreBothLists(p1, p2)
		eturn BothAreLists(p1, p2)

func BothAreStzLists(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if IsStzList(p1) and IsStzList(p2)
		return _TRUE_
	else
		return _FALSE_
	ok

	func AreBothStzLists()
		return BothAreStzLists()

	#-- Alternatives added so the function can be called from
	#-- inside an object that already contains a method of
	#-- the same name obj.BothAreStzLists()

	func @BothAreStzLists(p1, p2)
		return BothAreStzLists(p1, p2)

	func @AreBothStzLists(p1, p2)
		return BothAreStzLists(p1, p2)

func BothAreObjects(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isObject(p1) and isObject(p2)
		return _TRUE_
	else
		return _FALSE_
	ok

	func AreBothObjects(p1, p2)
		return BothAreObjects(p1, p2)

	#-- Alternatives added so the function can be called from
	#-- inside an object that already contains a method of
	#-- the same name obj.BothAreObjects()

	func @BothAreObjects(p1, p2)
		return BothAreObjects(p1, p2)

	func @AreBothObjects(p1, p2)
		return BothAreObjects(p1, p2)

func BothAreStzObjects(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if ObjectIsStzObject(p1) and IsStzObject(p2)
		return _TRUE_
	else
		return _FALSE_
	ok

	func AreBothStzObjects(p1, p2)
		return BothAreStzObjects(p1, p2)

	#-- Alternatives added so the function can be called from
	#-- inside an object that already contains a method of
	#-- the same name obj.BothAreStzObjects()

	func @BothAreStzObjects(p1, p2)
		return BothAreStzObjects(p1, p2)

	func @AreBothStzObjects(p1, p2)
		return BothAreStzObjects(p1, p2)

func BothHaveSameStzType(p1, p2)

	if BothAreObjects(p1, p2) and
	   p1.StzType() = p2.StzType()

		return _TRUE_
	else
		return _FALSE_
	ok

# ARE TWO OBJECTS THE SAME?

func AreSameObject(pcVarName1, pcVarName2) #TODO
	if isList(pcVarName2) and Q(pcVarName2).IsAndNamedParam()
		pcVarName2 = pcVarName2[2]
	ok

	return StzObjectQ(pcVarName1).IsEqualTo( pcVarName2 )

	func @AreSameObject(pcVarName1, pcVarName2)
		return AreSameObject(pcVarName1, pcVarName2)
# OTHER STAFF

func IsStzType(pcStr)
	if NOT isString(pcStr)
		StzRaise("Incorrect param type! pcStr must be a string.")
	ok

	acTypes = StzTypes() # Assumes they are lowercase strings

	if find(acTypes, pcStr) > 0
		return _TRUE_
	else
		return _FALSE_
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

	pcStr = lower(pcStr)
	acRingTypes = RingTypes()

	if find( RingTypes(), pcStr) > 0
		return _TRUE_
	else
		return _FALSE_
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
		return _TRUE_
	else
		return _FALSE_
	ok

	def IsStzOrRingType(pcStr)
		return IsRingOrStzType(pcStr)

	def @IsRingOrStzType(pcStr)
		return IsRingOrStzType(pcStr)

	def @IsStzOrRingType(pcStr)
		return IsRingOrStzType(pcStr)

	#-- #TODO // Add other alternatives (see IsRingType() and IsStzType() functions)


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
		StzRaise("Unsupported parameter type!")
	ok

	func @StzLen(p)
		return StzLen(p)

func Unicode(p)
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

	func @Unicode(p)
		return Unicode(p)

	func UnicodeOf(p)
		return Unicode(p)

	func @UnicodeOf(p)
		return Unicode(p)

func HexUnicode(p)
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

	func @HexUnicode(p)
		return HexUnicode(p)

	func HexUnicodeOf(p)
		return hexUnicode(p)

	func @HexUnicodeOf(p)
		return hexUnicode(p)

func Unicodes(p)
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

	func @Unicodes(p)
		return Unicodes(p)

	func UnicodesOf(p)
		return Unciodes(p)

	func @UnicodesOf(p)
		return Unciodes(p)

func HexUnicodes(p)
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

	func @HexUnicodes(p)
		return HexUnicodes(p)

	func HexUnicodesOf(p)
		return HexUnicodes(p)

	func @HexUnicodesOf(p)
		return HexUnicodes(p)



#---

func YaAllah()
	return "يَا أَلله"

func YaMuhammed()
	return "يا مُحَمَّدْ"

func SalatNabee()
	return "صلّى الله على نبيّه الأكرم"

func NHearts(n)
	return Q(Heart()).RepeatedNTimes(n)

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
	return Q(Star()).RepeatedNTimes(n)

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

func Empty(pcStzType)
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
		return new stzLangauge([])

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



func new_stz(cType, p)
	
	if NOT isString(cType)
		StzRaise("Incorrect param type! cType must be a string.")
	ok
	
	cCode = 'oObject = new stz' + cType + '(' + @@(p) + ')'

	eval(cCode)

	return oObject

	func stzQ(cType, p)
		return stz(cType, p)

	func stz@(cType, p)
		return stz(cType, p)

	func new@stz(cType, p)
		return stz(cType, p)

func Softanzify(p)
	return Q(p)s

func TheNumberQ(n)
	if NOT isNumber(n)
		StzRaise("Incorrect param type! n must be a number.")
	ok

	obj = new stzNumber(n)
	return obj

	func NumberQ(n)
		return TheNumberQ(n)

func TheNumberQM(n)
	obj = TheNumberQ(n)
	SetMainObject(obj)
	return obj

	def NumberQM(n)
		return TheNumberQM(n)

func TheListQ(aList)
	if NOT isList(aList)
		StzRaise("Incorrect param type! aList must be a list.")
	ok

	obj = new stzList(aList)
	return obj

	func ListQ(aList)
		return TheListQ(aList)

func TheListQM(aList)
	obj = TheListQ(aList)
	SetMainObject(obj)
	return obj

	func ListQM(aList)
		return TheListQM(aList)

func TheList(aList)
	if NOT isList(aList)
		StzRaise("Incorrect param type! aList must be a list.")
	ok

	return aList

func TheStringQ(str)
	if NOT isString(str)
		StzRaise("Incorrect param type! str must be a string.")
	ok

	obj = new stzString(str)
	return obj

	func StringQ(str)
		return TheStringQ(str)

	#--

	func TheWordQ(str)
		return TheStringQ(str)

	func WordQ(str)
		return TheStringQ(str)

func TheStringQM(str)
	obj = TheStringQ(str)
	SetMainObject(obj)
	return obj

	func StringQM(str)
		return TheStringQM(str)

	func TheWordQM(str)
		return TheStringQM(str)

	func WordQM(str)
		return TheStringQM(str)

func TheString(str)
	if NOT isString(str)
		StzRaise("Incorrect param type! str must be a string.")
	ok

	return str

	func TheWord(str)
		return TheString(str)




func Todo()
	return TodoXT(:InCurrent)

func TodoInFuture()
	return TodoXT(:InFuture)

	func TodoFuture()
		return TodoInFuture()

	func TodoInFutureRelease()
		return TodoInFuture()

	func TodoFutureRelease()
		return TodoInFuture()

func TodoInCurrent()
	return TodoXT(:InCurrent)

	func TodoCurrent()
		return TodoInCurrent()

	func TodoInCurrentRelease()
		return TodoInCurrent()

	func TodoCurrentRelease()
		return TodoInCurrent()

func TodoXT(pcCurrentOrFuture)
	if NOT ( isString(pcCurrentOrFuture) and
	   	 ring_find([
			:Current, :InCurrent, :Future, :InFuture,
			:CurrentRelease, :InCurrentRelease, :FutureRelease, :InFutureRelease,

			# Misspelled variations
			:Fture, :InFture, :FtureRelease, :InFtureRelease ], pcCurrentOrFuture) ) > 0

		StzRaise("Incorrect param! pcCurrentOrFuture must be a string equal to :Current or :Future.")
	ok

	if ring_find([ :Future, :InFuture, :FutureRelase, :InFutureRelase ], pcCurrentOrFuture) > 0
		StzRaise("Unavailable feature in current version (TODO in the future!)")

	else
		StzRaise("Feature not yet implemented, but it should be (TODO in current release)")
	ok

func AreBothListsOfNumbers(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfNumbers() and
	   Q(aList2).IsListOfNumbers()

		return _TRUE_

	else
		return _FALSE_
	ok

func AreBothListsOfStrings(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfStrings() and
	   Q(aList2).IsListOfStrings()

		return _TRUE_

	else
		return _FALSE_
	ok

func AreBothListsOfLists(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfLists() and
	   Q(aList2).IsListOfLists()

		return _TRUE_

	else
		return _FALSE_
	ok

func AreBothListsOfPairs(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfPairs() and
	   Q(aList2).IsListOfPairs()

		return _TRUE_

	else
		return _FALSE_
	ok

func AreBothListsOfSets(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfSets() and
	   Q(aList2).IsListOfSets()

		return _TRUE_

	else
		return _FALSE_
	ok

func AreBothListsOfHashLists(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfHashLists() and
	   Q(aList2).IsListOfHashLists()

		return _TRUE_

	else
		return _FALSE_
	ok

func AreBothListsOfObjects(aList1, aList2)
	if isList(aList1) and
	   isList(aList2) and
	   Q(aList1).IsListOfObjects() and
	   Q(aList2).IsListOfObjects()

		return _TRUE_

	else
		return _FALSE_
	ok

func EuclideanDistance(anNumbers1, anNumbers2)
	if isList(anNumbers1) and StzListQ(anNumbers1).IsBetweenNamedParam()
		anNumbers1 = anNumbers1[1]
	ok
	if isList(anNumbers2) and StzListQ(anNumbers2).IsAndNamedParam()
		anNumbers2 = anNumbers2[1]
	ok
	
	if NOT AreBothListsOfNumbers(anNumbers1, anNumbers2)
		StzRaise("Incorrect param types! anNumbers1 and anNumbers2 must be both lists of numbers.")
	ok
	
	if len(anNumbers1) != len(anNumbers2)
		StzRaise("Incorrect lists sizes! anNumbers1 and anNumbers2 must both have the same size.")
	ok

	nResult = euc_dist(anNumbers1, anNumbers2)
	return nResult

func euc_dist(a,b)

	s = 0
	n = len(a)

	for i = 1 to n

		dist = a[i] - b[i]
		s += dist * dist
	next

	return sqrt(s)

func @IsList(paList)
	if isList(paList)
		return _TRUE_
	else
		return _FALSE_
	ok

	func IsAList(paList)
		return isList(paList)

	func @IsAList(paList)
		return isList(paList)

func @IsNumber(n)
	if isNumber(n)
		return _TRUE_
	else
		return _FALSE_
	ok

	func IsANumber(n)
		return isNumber(n)

	func @IsANumber(n)
		return isNumber(n)

func @IsString(str)
	if isString(str)
		return _TRUE_
	else
		return _FALSE_
	ok

	func IsAString(str)
		return isString(str)

	func @IsAString(str)
		return isString(str)

func @IsObject(obj)
	if isObject(obj)
		return _TRUE_
	else
		return _FALSE_
	ok

	func IsAnObject(obj)
		return isObject(obj)

	func @IsAnObject(obj)
		return isObject(obj)

#--

func IsNeitherNorCS(p, p1, p2, pCaseSensitive)
	return Q(p).IsNeitherCS(p1, p2, pCaseSensitive)

	func @IsNeitherNorCS(p, p1, p2, pCaseSensitive)
		return IsNeitherNorCS(p, p1, p2, pCaseSensitive)

func IsNeitherNor(p, p1, p2)
	return Q(p).IsNeither(p1, p2)

	func @IsNeitherNor(p, p1, p2)
		return IsNeitherNor(p, p1, p2)

#==

func BothStartWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)

	if Q(pStrOrList1).StartsWithCS(pSubStrOrSubList, pCaseSensitive) and
	   Q(pStrOrList2).StartsWithCS(pSubStrOrSubList, pCaseSensitive)

		return _TRUE_
	else
		return _FALSE_
	ok

	func @BothStartWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)
		return BothStartWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)

func BothStartWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)
	return BothStartWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, _TRUE_)

	func @BothStartWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)
		return BothStartWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)

#--

func BothEndWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)

	if Q(pStrOrList1).endsWithCS(pSubStrOrSubList, pCaseSensitive) and
	   Q(pStrOrList2).EndsWithCS(pSubStrOrSubList, pCaseSensitive)

		return _TRUE_
	else
		return _FALSE_
	ok

	func @BothEndWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)
		return BothEndWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, pCaseSensitive)

func BothEndWith(pStrOrList1, pStrOrList2)
	return BothEndWithCS(pStrOrList1, pStrOrList2, pSubStrOrSubList, _TRUE_)

	func @BothEndWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)
		return BothEndWith(pStrOrList1, pStrOrList2, pSubStrOrSubList)

#==

func BothStartWithANumber(p1, p2)
	if Q(p1).StartsWithANumber() and Q(p2).StartsWithANumber()
		return _TRUE_
	else
		return _FALSE_
	ok

func BothEndWithANumber(p1, p2)
	if Q(p1).EndsWithANumber() and Q(p2).EndsWithANumber()
		return _TRUE_
	else
		return _FALSE_
	ok

func HowMany(paList)
	if NOT isList(paList)
		StzRaise("Incorrect param type! paList must be a list.")
	ok

	return len(paList)

	func HowManyItemsIn(paList)
		return HowMany(paList)

	func HowManyItems(paList)
		if isList(paList) and Q(paList).IsInNamedParam()
			paList = paList[2]
		ok

		return HowMany(paList)

	#-- @FunctionMisspelledForms
	#TODO // Add "Hwo" as an alternative of "Hwo" in all functions

	func HwoMany(paList)
		return HowMany(paList)

	func HwoManyItemsIn(paList)
		return HowMany(paList)

	func HwoManyItems(paList)
		return HowManyItems(paList)

func NewLine()
	return NL

	func NL()
		return NL

	func EmptyLine()
		return NL

func NumberOfStzFindableTypes()
	return len(_aStzFindableTypes)

func IsStzFindableType(cType)
	if NOT isString(cType)
		StzRaise("Incorrect param type! cType must be a string.")
	ok

	cType = lower(cType)
	if ring_find( StzFindableTypes(), cType) > 0
		return _TRUE_
	else
		return _FALSE_
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
		return _FALSE_
	ok

	cStzType = p.StzType()
	if ring_find( StzFindableTypes(), cStzType ) > 0
		return _TRUE_
	else
		return _FALSE_
	ok

	func @IsStzFindable(p)
		return IsStzFindable(p)

#----

func RingQtClasses()
	#TODO // Update it tp Ring 1.19
	aRingQtClasses = [
		:QAbstractAspect,
		:QAbstractButton,
		:QAbstractCameraController,
		:QAbstractItemView,
		:QAbstractPrintDialog,
		:QAbstractScrollArea,
		:QAbstractSeries,
		:QAbstractSlider,
		:QAbstractSocket,
		:QAbstractSpinBox,
		:QAction,
		:QAllEvents,
		:QApp,
		:QAreaLegendMarker,
		:QAreaSeries,
		:QAspectEngine,
		:QAxBase,
		:QAxObject,
		:QAxWidget,
		:QAxWidget2,
		:QBarCategoryAxis,
		:QBarLegendMarker,
		:QBarSeries,
		:QBarSet,
		:QBitmap,
		:QBluetoothAddress,
		:QBluetoothDeviceDiscoveryAgent,
		:QBluetoothDeviceInfo,
		:QBluetoothHostInfo,
		:QBluetoothLocalDevice,
		:QBluetoothServer,
		:QBluetoothServiceDiscoveryAgent,
		:QBluetoothServiceInfo,
		:QBluetoothSocket,
		:QBluetoothTransferManager,
		:QBluetoothTransferReply,
		:QBluetoothTransferRequest,
		:QBluetoothUuid,
		:QBoxLayout,
		:QBoxPlotLegendMarker,
		:QBoxPlotSeries,
		:QBoxSet,
		:QBrush,
		:QBuffer,
		:QButtonGroup,
		:QByteArray,
		:QCalendarWidget,
		:QCamera,
		:QCameraImageCapture,
		:QCameraLens,
		:QCameraSelector,
		:QCameraViewfinder,
		:QCandlestickLegendMarker,
		:QCandlestickModelMapper,
		:QCandlestickSeries,
		:QCandlestickSet,
		:QCategoryAxis,
		:QChar,
		:QChart,
		:QChartView,
		:QCheckBox,
		:QChildEvent,
		:QClipboard,
		:QColor,
		:QColorDialog,
		:QComboBox,
		:QCompleter,
		:QCompleter2,
		:QCompleter3,
		:QCompleter4,
		:QConeGeometry,
		:QConeMesh,
		:QCoreApplication,
		:QCuboidMesh,
		:QCullFace,
		:QCursor,
		:QCylinderMesh,
		:QDate,
		:QDateEdit,
		:QDateTime,
		:QDateTimeAxis,
		:QDateTimeEdit,
		:QDepthTest,
		:QDesktopServices,
		:QDesktopWidget,
		:QDial,
		:QDialog,
		:QDiffuseSpecularMaterial,
		:QDir,
		:QDirModel,
		:QDockWidget,
		:QDrag,
		:QDragEnterEvent,
		:QDragLeaveEvent,
		:QDragMoveEvent,
		:QDropEvent,
		:QEffect,
		:QEntity,
		:QEvent,
		:QExtrudedTextMesh,
		:QFile,
		:QFile2,
		:QFileDevice,
		:QFileDialog,
		:QFileInfo,
		:QFileSystemModel,
		:QFirstPersonCameraController,
		:QFont,
		:QFontDialog,
		:QFontMetrics,
		:QForwardRenderer,
		:QFrame,
		:QFrame2,
		:QFrame3,
		:QFrameAction,
		:QGeoAddress,
		:QGeoAreaMonitorInfo,
		:QGeoAreaMonitorSource,
		:QGeoCircle,
		:QGeoCoordinate,
		:QGeoPositionInfo,
		:QGeoPositionInfoSource,
		:QGeoRectangle,
		:QGeoSatelliteInfo,
		:QGeoSatelliteInfoSource,
		:QGeoShape,
		:QGoochMaterial,
		:QGradient,
		:QGraphicsScene,
		:QGraphicsVideoItem,
		:QGraphicsView,
		:QGridLayout,
		:QGuiApplication,
		:QHBarModelMapper,
		:QHBoxLayout,
		:QHBoxPlotModelMapper,
		:QHCandlestickModelMapper,
		:QHPieModelMapper,
		:QHXYModelMapper,
		:QHeaderView,
		:QHorizontalBarSeries,
		:QHorizontalPercentBarSeries,
		:QHorizontalStackedBarSeries,
		:QHostAddress,
		:QHostInfo,
		:QIODevice,
		:QIcon,
		:QImage,
		:QInputAspect,
		:QInputDialog,
		:QJsonArray,
		:QJsonDocument,
		:QJsonObject,
		:QJsonParseError,
		:QJsonValue,
		:QKeySequence,
		:QLCDNumber,
		:QLabel,
		:QLayout,
		:QLegend,
		:QLegendMarker,
		:QLineEdit,
		:QLineSeries,
		:QLinearGradient,
		:QListView,
		:QListWidget,
		:QListWidgetItem,
		:QLocale,
		:QLogValueAxis,
		:QLogicAspect,
		:QMainWindow,
		:QMaterial,
		:QMatrix4x4,
		:QMdiArea,
		:QMdiSubWindow,
		:QMedIsAObject,
		:QMediaPlayer,
		:QMediaPlaylist,
		:QMenu,
		:QMenuBar,
		:QMesh,
		:QMessageBox,
		:QMetalRoughMaterial,
		:QMimeData,
		:QMorphPhongMaterial,
		:QMovie,
		:QMutex,
		:QMutexLocker,
		:QNetworkAccessManager,
		:QNetworkProxy,
		:QNetworkReply,
		:QNetworkRequest,
		:QNmeaPositionInfoSource,
		:QNode,
		:QObject,
		:QObjectPicker,
		:QOpenGLBuffer,
		:QOpenGLContext,
		:QOpenGLDebugLogger,
		:QOpenGLFramebufferObject,
		:QOpenGLFunctions,
		:QOpenGLFunctions_3_2_Core,
		:QOpenGLPaintDevice,
		:QOpenGLShader,
		:QOpenGLShaderProgram,
		:QOpenGLTexture,
		:QOpenGLTimerQuery,
		:QOpenGLVersionProfile,
		:QOpenGLVertexArrayObject,
		:QOpenGLWidget,
		:QOrbitCameraController,
		:QPageSetupDialog,
		:QPaintDevice,
		:QPainter,
		:QPainter2,
		:QPainterPath,
		:QPen,
		:QPerVertexColorMaterial,
		:QPercentBarSeries,
		:QPhongMaterial,
		:QPicture,
		:QPieLegendMarker,
		:QPieSeries,
		:QPieSlice,
		:QPixmap,
		:QPixmap2,
		:QPlainTextEdit,
		:QPlaneMesh,
		:QPoint,
		:QPointF,
		:QPointLight,
		:QPolarChart,
		:QPrintDialog,
		:QPrintPreviewDialog,
		:QPrintPreviewWidget,
		:QPrinter,
		:QPrinterInfo,
		:QProcess,
		:QProgressBar,
		:QPushButton,
		:QQmlEngine,
		:QQmlError,
		:QQuaternion,
		:QQuickView,
		:QQuickWidget,
		:QRadioButton,
		:QRect,
		:QRegion,
		:QRegularExpression,
		:QRegularExpressionMatch,
		:QRegularExpressionMatchIterator,
		:QRenderAspect,
		:QRenderPass,
		:QScatterSeries,
		:QSceneLoader,
		:QScreen,
		:QScrollArea,
		:QScrollBar,
		:QSerialPort,
		:QSerialPortInfo,
		:QSize,
		:QSkyboxEntity,
		:QSlider,
		:QSphereMesh,
		:QSpinBox,
		:QSplashScreen,
		:QSplineSeries,
		:QSplitter,
		:QSqlDatabase,
		:QSqlDriver,
		:QSqlDriverCreatorBase,
		:QSqlError,
		:QSqlField,
		:QSqlIndex,
		:QSqlQuery,
		:QSqlRecord,
		:QStackedBarSeries,
		:QStackedWidget,
		:QStandardPaths,
		:QStatusBar,
		:QString,
		:QString2,
		:QStringList,
		:QStringRef,
		:QSurfaceFormat,
		:QSystemTrayIcon,
		:QTabBar,
		:QTabWidget,
		:QTableView,
		:QTableWidget,
		:QTableWidgetItem,
		:QTcpServer,
		:QTcpSocket,
		:QTechnique,
		:QTest,
		:QText2DEntity,
		:QTextBlock,
		:QTextBrowser,
		:QTextCharFormat,
		:QTextCodec,
		:QTextCursor,
		:QTextDocument,
		:QTextEdit,
		:QTextStream,
		:QTextStream2,
		:QTextStream3,
		:QTextStream4,
		:QTextStream5,
		:QTextToSpeech,
		:QTextureLoader,
		:QTextureMaterial,
		:QThread,
		:QThreadPool,
		:QTime,
		:QTimer,
		:QToolBar,
		:QToolButton,
		:QTorusMesh,
		:QTransform,
		:QTreeView,
		:QTreeWidget,
		:QTreeWidgetItem,
		:QUrl,
		:QUuid,
		:QVBarModelMapper,
		:QVBoxLayout,
		:QVBoxPlotModelMapper,
		:QVCandlestickModelMapper,
		:QVPieModelMapper,
		:QVXYModelMapper,
		:QValueAxis,
		:QVariant,
		:QVariant2,
		:QVariant3,
		:QVariant4,
		:QVariant5,
		:QVariantDouble,
		:QVariantFloat,
		:QVariantInt,
		:QVariantString,
		:QVector2D,
		:QVector3D,
		:QVector4D,
		:QVectorQVoice,
		:QVideoWidget,
		:QVideoWidgetControl,
		:QViewport,
		:QVoice,
		:QWebEnginePage,
		:QWebEngineView,
		:QWebView,
		:QWebView,
		:QWidget,
		:QWindow,
		:QXYLegendMarker,
		:QXYSeries,
		:QXmlStreamAttribute,
		:QXmlStreamAttributes,
		:QXmlStreamEntityDeclaration,
		:QXmlStreamEntityResolver,
		:QXmlStreamNamespaceDeclaration,
		:QXmlStreamNotationDeclaration,
		:QXmlStreamReader,
		:QXmlStreamWriter,
		:Qt3DCamera,
		:Qt3DWindow,
		:RingCodeHighlighter,
		:QTextOption # Added in Ring 1.18
		
	]

	return aRingQtClasses

func NumberOfRingQtClasses()
	return len(RingQtClasses())

	func HowManyRingQtClasses()
		return NumberOfRingQtClasses()

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

func InfereType(cType)
	return StzStringQ(cType).InfereType()

	func @InfereType(cType)
		return InfereType(cType)

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
			
			if NOT StzListQ(pIn).IsListOfLists()
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

			if NOT StzListQ(pIn).IsListOfLists()
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

