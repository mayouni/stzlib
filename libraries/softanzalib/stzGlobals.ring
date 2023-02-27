

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

_t0 = 0 # Used by StartProfiler() and StopProfiler() functions

_aRingTypes = [ :number, :string, :list, :object, :cobject ]

cCacheFileName = "stzcache.txt"
_CacheFileHandler = NULL

_cCacheMemoryString = ""

_acRingFunctions = [
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
	
	:@StringItem,
		:@CurrentStringItem,
		:@PreviousStringItem,
		:@NextStringItem,
	
	:@Line,
		:@CurrentLine,
		:@PreviousLine,
		:@NextLine,
	
	:@Item,
		:@CurrentItem,
		:@PreviousSItem,
		:@NextItem,

		:@Section,
		:@Range
	
	]

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

func SetQuietEqualityRatio(n)
	if _(n).@.IsBetween(0,1)
		_nQuietEqualityRatio = n
	ok

func RingTypes()
	return _aRingTypes

func RingFunctions()
	return _acRingFunctions

func RingKeywords()
	return _acRingKeywords()

func SoftanzaLogo()
	return _cSoftanzaLogo

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
		raise("Error in StzRaise > Incorrect param type!")
	ok

#-----

# Wrappers to ring functions, that we use inside a softanza class
# where the same name is needed (example: insert() inside stzString)
# --> This will allow us to avoid conflicts!
# --> For you as a Ring programmer, this won't alter you Ring experience
#     when you want to use natibe Ring form. But if you are inside a
#     softanza object, then the softanza version will apply, unless you
#     you for the Ring's version using ring_...()


func ring_insert(paList, n, pItem)
	insert(paList, n, pItem)

func ring_find(paList, pItem)
	return find(paList, pItem)

func ring_type(p)
	return type(p)

func ring_reverse(paList)
	return reverse(paList)

func ring_sort(paList)
	return sort(paList)

func ring_methods(obj)
	return methods(obj)

func ring_attributes(obj)
	return attributes(obj)

func ring_classname(obj)
	return classname(obj)

func ring_factors(n)
	return factors(n)

func ring_LCM(n1, n2)
	return LCM(n1, n2)

func ring_GCD(n1, n2)
	return GCD(n1, n2)

func ring_exp(n)
	return exp(n)

func ring_log10(n)
	return log10(n)

func ring_log(n)
	return log(n)

func ring_tanhh(n)
	return tanhh(n)

func ring_cosh(n)
	return cosh(n)

func ring_sinh(n)
	return sinh(n)

func ring_atan2(n)
	return atan2(n)

func ring_acos(n)
	return acos(n)

func ring_asin(n)
	return asin(n)

func ring_tan(n)
	return tan(n)

func ring_cos(n)
	return cos(n)

func ring_sin(n)
	return sin(n)

func ring_pow(n)
	return pow(n)

func ring_left(str, n)
	return left(str, n)

func ring_right(str, n)
	return right(str, n)

func ring_del(paList, n)
	del(paList, n)

func ring_copy(p1, p2)
	return copy(p1, p2)

#-----

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

func IsNumberOrString(p)
	if isNumber(p) or isString(p)
		return TRUE
		else
		return FALSE
	ok

	func IsStringOrNumber(p)
		return IsNumberOrString(p)

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

func IsNumberOrStringOrList(p)
	if isNumber(p) or isString(p) or isList(p)
		return TRUE
	else
		return FALSE
	ok

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

func BothAreNumbers(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isNumber(p1) and isNumber(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothNumbers(p1, p2)
		return BothAreNumbers(p1, p2)

func BothAreNumbersInStrings(p1, p2) # NOTE: hex and octal numbers are excluded
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if BothAreStrings(p1, p2) and
	   Q(p1).IsDecimalNumberInString() and
	   Q(p2).IsDecimalNumberInString()

		return TRUE

	else
		return FALSE
	ok

func BothAreCharsInComputableForm(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

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

		return TRUE

	else
		return FALSE
	ok

func BothAreStzNumbers(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if IsStzNumber(p1) and IsStzNumber(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothStzNumbers(p1, p2)
		return BothAreStzNumbers(p1, p2)

func BothAreStrings(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isString(p1) and isString(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothStrings(p1, p2)
		return BothAreStrings(p1, p2)

func BothAreStzStrings(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if IsStzString(p1) and IsStzString(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothStzStrings(p1, p2)
		return BothAreStzStrings(p1, p2)

func BothAreLists(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isList(p1) and isList(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothLists(p1, p2)
		return BothAreLists(p1, p2)

func BothAreStzLists(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if IsStzList(p1) and IsStzList(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothStzLists()
		return BothAreStzLists()

func BothAreObjects(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if isObject(p1) and isObject(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothObjects(p1, p2)
		return BothAreObjects(p1, p2)

func BothAreStzObjects(p1, p2)
	if isList(p2) and Q(p2).IsAndNamedParam()
		p2 = p2[2]
	ok

	if IsStzObject(p1) and IsStzObject(p2)
		return TRUE
	else
		return FALSE
	ok

	func AreBothStzObjects(p1, p2)
		return BothAreStzObjects(p1, p2)

# ARE TWO OBJECTS THE SAME?

func AreSameObject(pcObjectName1, pcObjectName2) # TODO
	if isList(pcObjectName2) and Q(pcObjectName2).IsAndNamedParam()
		pcObjectName2 = pcObjectName2[2]
	ok

	return StzObjectQ(pcObjectName1).IsEqualTo( pcObjectName2 )

# REPEATING A THING N TIME

func One(pThing)
	return pThing

func Two(pThing)
	return Q(pThing).RepeatedNTimes(2)

func Three(pThing)
	return Q(pThing).RepeatedNTimes(3)

func Four(pThing)
	return Q(pThing).RepeatedNTimes(4)

func Five(pThing)
	return Q(pThing).RepeatedNTimes(5)

func Six(pThing)
	return Q(pThing).RepeatedNTimes(6)

func Seven(pThing)
	return Q(pThing).RepeatedNTimes(7)

func Eight(pThing)
	return Q(pThing).RepeatedNTimes(8)

func Nine(pThing)
	return Q(pThing).RepeatedNTimes(9)

func Ten(pThing)
	return Q(pThing).RepeatedNTimes(10)

# OTHER STAFF

func IsRingType(pcString)
	return StzStringQ(pcString).LowercaseQ().ExistsIn( RingTypes() )

func StringIsStzClassName(pcString)
	return StzStringQ(pcString).IsStzClassName()

func StringIsChar(pcStr)
	oStzString = new stzString(pcStr)
	return oStzString.IsChar()

func CharIsLetter(pcStr)
	oStzChar = new stzChar(pcStr)
	return oStzChar.IsLetter()

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
		StzRaise("Incorrect param type!")
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

		cChar = ""

		if Q('"').
		   Occurs( :Before = "'", :In = pValue )
			cChar = '"'

		else
			cChar = "'"
		ok

		return cChar + pValue + cChar

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

	cResult = ""

	if isNumber(pValue)
		cResult = ""+ pValue

	but isString(pValue)
		# NOTE: strings inside the pValue must be enclosed
		# between two (")s anf not between two (')s.

		oStr = new stzString(pValue)

		cChar = ""

		if Q('"').
		   Occurs( :Before = "'", :In = pValue )
			cChar = '"'

		else
			cChar = "'"
		ok

		if oStr.ContainsNo('"')
			cResult = cChar + Q(pValue).Simplified() + cChar
		else

			aAntiSections = oStr.FindAntiSections( oStr.FindBetweenAsSections('"','"') )
		
			oStr.ReplaceSections(aAntiSections, :With@ = ' Q(@Section).Simplified() ')
			#--> this code : txt1 = "<    leave spaces    >" and this code: txt2 = "< leave spaces >"

			cResult = cChar + oStr.Content() + cChar
		ok

	but isList(pValue)
		cResult = @@Q(pValue).Simplified()
	ok

	return cResult

	func ComputableFormSimplifiedQ(pValue)
		return new stzString( ComputableFormSimplified(pValue) )

	func @@SF(pValue)
		return ComputableFormSimplified(pValue)

		func @@SFQ(pValue)
			return new stzString( @@SF(pValue) )

	func @@S(pValue)
		return ComputableFormSimplified(pValue)

		func @@SQ(pValue)
			return new stzString( @@S(pValue) )

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

func StzW(cType, paMethodAndFilter)
	/* EXAMPLE
	? Stz(:Char, [ :Methods, :Where = 'Q(@Method).StartsWith("is")' ])
	*/

	if NOT ( isList(paMethodAndFilter) and len(paMethodAndFilter) = 2 and
		 isList(paMethodAndFilter[2]) and
		 Q(paMethodAndFilter[2]).IsWhereNamedParam() and
		 isString(paMethodAndFilter[2][2]) )

		StzRaise('Incorrect param type! paMethodAndFilter must be a pair of the form [ :Methods, :Where = "@Method..." ], for example.')
	ok

	aTempList = Stz(cType, paMethodAndFilter[1])
	cCondition = Q(paMethodAndFilter[2][2]).
			ReplaceCSQ("@Method", "@Item", :CS=FALSE).
			Content()
	
	aResult = QR(aTempList, :stzListOfStrings).StringsW(ccondition)

	return aResult

func Stz(cType, pInfo)
	/* EXAMPLE
		? Stz(:Char, :Methods) #--> [ :Init, :Content, ... ]
	*/

	if isList(pInfo) and len(pInfo) = 2 and
		 isList(pInfo[2]) and
		 Q(pInfo[2]).IsWhereNamedParam() and
		 isString(pInfo[2][2])

		return stzW(cType, pInfo)
	ok

	cInfo = pInfo

	If NOT BothAreStrings(cType, :And = cInfo)
		StzRaise("Incorrect params type! Botht cType and cInfo must be strings.")
	ok

	cClass = 'stz' + cType

	if NOT Q(cClass).IsStzClassName()
		StzRaise("Incorrect param! cType must be a valid softanza type.")
	ok

	oEmptyObject = Empty(cClass)

	switch cInfo
	on :Class
		return cClass

	on :ClassName
		return cClass

	on :Methods
		return methods(oEmptyObject)

	on :Attributes
		return attributes(oEmptyObject)

	other
		StzRaise("Unsupported information! Allowed values are :Methods and :Attributes.")
	off

func new_stz(cType, p)
	
	if NOT isString(cType)
		StzRaise("Incorrect param type! cType must be a string.")
	ok
	
	cCode = 'oObject = new stz' + cType + '(' + @@S(p) + ')'

	eval(cCode)

	return oObject

	func stzQ(cType, p)
		return stz(cType, p)

	func stz@(cType, p)
		return stz(cType, p)

	func new@stz(cType, p)
		return stz(cType, p)


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
		StzRaise("Invalid param type! pcType should be a string containing the name of a softanza class.")
	ok

	if StringIsStzClassName(pcType)
		cCode = "oResult = new " + pcType + "(" + @@(p) + ")"
		eval(cCode)

		return oResult
	else
		StzRaise("Unsupported Softanza type!")
	ok

# This function tries its best to infere a convenient type
# by analysing a value hosted in a string

func QQ(p)

	/* EXAMPLE 1

	? QQ("19")		# stzNumber
	#--> Note that this is a number in string:
	? Q("19").IsNumberInString() #--> TRUE

	EXAMPLE 2

	? QQ("[1, 2, 3]")	#--> stzListOfNumbers
	#--> Note that this is a list in string:
	? Q("[1, 2, 3]").IsListOfNumbersInString() #--> TRUE

	EXAMPLE 3

	? QQ(' [ "one", "two", "three" ] ')	#--> stzListOfStrings
	#--> Note that this is a list of strings in a string:
	? Q(' [ "one", "two", "three" ] ').IsListOfStringsInString #--> TRUE

	*/

	if isString(p)

		if Q(p).IsNumberInString()
			return new stzNumber(p)

		but Q(p).IsListInString() # TODO: check Q(' "A" : "C" ').IsListInString()
			return new stzList(p)
			# TODO: check new stzList("[1, 2, 3]")

		but Q(p).IsChar()
			return new stzChar(p)

		else
			return new stzString(p)

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

		else
			return new stzList(p)
		ok

	else
		return Q(p)
	ok

func W(cCode)
	if NOT isString(cCode)
		StzRaise("Uncorrect param type! cCode must be a string.")
	ok

	cCode = Q(cCode).Trimmed()
	if NOT Q(cCode).IsBoundedBy(["{", "}"])
		cCode = "{ " + cCode + " }"
	ok

	aResult = [:Where, cCode]
	return aResult

	func Where(cCode)
		return W(cCode)

func STOP()
	StzRaise( NL + 	"----------------" + NL +
		       	"    STOPPED!    " + NL +
			"----------------" + NL )

func StartTimer()
	_t0 = clock()

func ResetTimer()
	_t0 = 0

func ElapsedTime()
	return ElapsedTimeXT(:In = :Seconds)

	func ElpasedTime()
		return ElapsedTime()
		# NOTE
		# This function name alternative contains a spelling error.
		# Despite that, I'll take it. Because I always make this
		# error and don't want to be blocked for that.

func ElapsedTimeXT(pIn)
	if isList(pIn) and Q(pIn).IsInNamedParam()
		pIn = pIn[2]
	ok

	if NOT isString(pIn)
		StzRaise("Incorrect param type! pIn must be a string.")
	ok

	if NOT Q(pIn).IsOneOfThese([ :Clocks, :Seconds, :Minutes, :Hours ])
		# TODO - Future: Add days, weeks, months, years...
		StzRaise("Incorrect value of pIn param! Allowed values are: " +
		":Clocks, :Seconds, :Minutes and :Hours.")
	ok

	if Q(pIn).FirstNChars(2) != "in"
		pIn = "in" + pIn
	ok

	switch pIn
	on :InClocks
		return clock() - _t0 + " clocks"

	on :InSeconds
		nTime = ( clock() - _t0 ) / clockspersecond()
		cTime = "" + nTime
		return cTime + " second(s)"

	on :InMinutes
		nTime = ( clock() - _t0 ) / clockspersecond() / 60
		cTime = "" + nTime
		return cTime + " minute(s)"

	on :InHours
		nTime = ( clock() - _t0 ) / clockspersecond() / 3600
		cTime = "" + nTime
		return cTime + " hour(s)"

	off
	
	func ElpasedTimeXT(pIn)
		return ElapsedTimeXT(pIn)

func StartProfiler()
	StartTimer()

	func Profon()
		StartProfiler()

	func Pron()
		StartProfiler()

func StopProfiler()
	? NL + "Executed in " + ElapsedTime()
	ResetTimer()
	STOP()

	func EndProfiler()
		StopProfiler()

	func Profoff()
		StopProfiler()

	func Proff()
		StopProfiler()

func eval@(pcExpr, paItems) # WARNING: if you change paItems name,
			    # change it also in the evaluated code

	# Checking params

	if isList(pcExpr) and Q(pcExpr).IsExpressionNamedParam()
		pcExpr = pcExpr[2]
	ok

	if NOT isString(pcExpr)
		StzRaise("Incorrect param type! pcExpr must be a string.")
	ok

	if isList(paItems) and
	   Q(paItems).IsOneOfTheseNamedParams([ :On, :OnItems ])

		paItems = paItems[2]
	ok

	if NOT isList(paItems)
		StzRaise("Incorrect param type! paItems must be a list.")
	ok
	
	nLen = len(paItems)

	# Doing the job

	aResult = []
	cExpr = StzCCodeQ(pcExpr).Transpiled()

	cCode = 'value = (' +
		Q(cExpr).ReplaceCSQ("This", "paItems", :CS = FALSE).Content() +
		')'

	for @i = 1 to nLen
		eval(cCode)
		aResult + value
	next

	return aResult

