
#=================================================================#
#  NAMED PARAM CHECKING -- Pure Ring Implementation               #
#  Replaces 1,566 IsXxxNamedParam() methods in stzList with       #
#  a single hash-lookup against an embedded keyword registry.     #
#=================================================================#

# 768 registered named-param keywords (lowercase for O(n) scan).
# This list mirrors engine/src/named_params.zig and replaces the
# engine call StzMetaIsNamedParam() with a pure Ring lookup.

$_acStzNamedParams = [
	"after", "afterchar", "afterchars", "aftercharsw", "aftercharswhere",
	"aftercharswhereext", "aftercharswxt", "aftereach", "afterfirst", "afterib",
	"afteritem", "afteritemib", "afteritems", "afteritemsib", "afterlast",
	"aftermany", "aftermanypositions", "aftermanypositionsib", "afternth",
	"afterposition", "afterpositionib", "afterpositions", "afterpositionsib",
	"aftersection", "aftersectionib", "aftersections", "aftersectionsib",
	"aftersubstring", "aftersubstringib", "aftersubstringposition",
	"aftersubstrings", "aftersubstringsib", "aftersubstringspositions",
	"afterthese", "aftertheseitems", "aftertheseitemsib", "afterthesepositions",
	"afterthesepositionsib", "afterthesesections", "afterthesesubstrings",
	"afterthesesubstringsib", "afterthesesubstringspositions", "afterthisitem",
	"afterthisitemib", "afterthisposition", "afterthispositionib",
	"afterthissection", "afterthissubstring", "afterthissubstringib",
	"afterthissubstringposition", "afterwhere", "afterwhereext",
	"alongwith", "alongwiththeir", "among", "and", "andchar", "andcol",
	"andcolat", "andcolatposition", "andcolnamed", "andcolumn", "andcolumnat",
	"andcolumnatposition", "andcolumnnamed", "andharvest", "andharvestsection",
	"andharvestsections", "anditem", "anditemat", "anditematposition",
	"andposition", "andpositions", "andreturnas", "andreturnedas",
	"andreturnitas", "andreturnthemas", "androw", "androwat",
	"androwatposition", "andsection", "andsections", "andstring",
	"andstringat", "andstringatposition", "andsubstring", "andsubstrings",
	"andthat", "andtheir", "andthen", "andthenharvest", "andthenharvestsection",
	"andthenharvestsections", "andthenyield", "andthenyieldsection",
	"andthenyieldsections", "andthis", "andyield", "andyieldsection",
	"andyieldsections",
	"around", "aroundchar", "aroundchars", "aroundeach", "aroundfirst",
	"aroundib", "arounditemib", "arounditemsib", "aroundlast", "aroundmany",
	"aroundnth", "aroundposition", "aroundpositionib", "aroundpositions",
	"aroundpositionsib", "aroundsection", "aroundsectionib", "aroundsections",
	"aroundsectionsib", "aroundsubstring", "aroundsubstringib",
	"aroundsubstrings", "aroundsubstringsib", "aroundthese",
	"aroundtheseitemsib", "aroundthesepositionsib", "aroundthesesubstringsib",
	"aroundthisitemib", "aroundthispositionib", "aroundthissubstringib",
	"as", "at", "atchar", "atchars", "atcharsw", "atcharswhere",
	"atcharswhereext", "atcharswxt", "atib", "atitem", "atitemib", "atitems",
	"atitemsib", "atlist", "atlistofchars", "atlistofhashlists",
	"atlistoflists", "atlistofnumbers", "atlistofpairs", "atlistofranges",
	"atlistofsections", "atlistofsectionsib", "atlistofstrings",
	"atlistofsublists", "atlists", "atmanychars", "atmanyitems", "atmanylists",
	"atmanynumbers", "atmanyobjects", "atmanypairs", "atmanypositions",
	"atmanypositionsib", "atmanyranges", "atmanysections", "atmanysectionsib",
	"atmanystrings", "atmanysublists", "atmanysubstrings",
	"atmanysubstringsib", "atnumber", "atnumbers", "atobject", "atobjects",
	"atpair", "atpairs", "atposition", "atpositionib", "atpositions",
	"atpositionsib", "atrange", "atranges", "atsection", "atsectionib",
	"atsections", "atsectionsib", "atstring", "atstrings", "atsublist",
	"atsublists", "atsubstring", "atsubstringib", "atsubstrings",
	"atsubstringsib", "atthesechars", "attheseitems", "attheselists",
	"atthesenumbers", "attheseobjects", "atthesepairs", "atthesepositions",
	"atthesepositionsib", "attheseranges", "atthesesections",
	"atthesesectionsib", "atthesestrings", "atthesesublists",
	"atthesesubstrings", "atthesesubstringsib", "atthischar", "atthisitem",
	"atthislist", "atthisnumber", "atthisobject", "atthispair",
	"atthisposition", "atthispositionib", "atthisrange", "atthissection",
	"atthissectionib", "atthisstring", "atthissublist", "atthissubstring",
	"atthissubstringib", "atwhere", "atwhereext",
	"backward", "before", "beforechar", "beforechars", "beforecharsw",
	"beforecharswhere", "beforecharswhereext", "beforecharswxt", "beforeeach",
	"beforefirst", "beforeib", "beforeitem", "beforeitemib", "beforeitems",
	"beforeitemsib", "beforelast", "beforemany", "beforemanypositions",
	"beforemanypositionsib", "beforenth", "beforeposition", "beforepositionib",
	"beforepositions", "beforepositionsib", "beforesection", "beforesectionib",
	"beforesections", "beforesectionsib", "beforesubstring",
	"beforesubstringib", "beforesubstringposition", "beforesubstrings",
	"beforesubstringsib", "beforesubstringspositions", "beforethese",
	"beforetheseitems", "beforetheseitemsib", "beforethesepositions",
	"beforethesepositionsib", "beforethesesections", "beforethesesubstrings",
	"beforethesesubstringsib", "beforethesesubstringspositions",
	"beforethisitem", "beforethisitemib", "beforethisposition",
	"beforethispositionib", "beforethissection", "beforethissubstring",
	"beforethissubstringib", "beforethissubstringposition", "beforewhere",
	"beforewhereext",
	"between", "betweencs", "betweenib", "betweenposition",
	"betweenpositionib", "betweenpositions", "betweenpositionsib",
	"betweensection", "betweensubstring", "betweensubstrings",
	"betweensubstringsib", "betweenxt",
	"boundedby", "boundedbyib", "bounds", "boundsib",
	"by", "bymany", "bymanyxt", "byxt",
	"cs", "casesensitive",
	"cell", "cellpart", "cells", "cellvalue",
	"char", "charat", "charatposition", "chars",
	"col", "colnumber", "cols", "colsnumbers",
	"column", "columnnumber", "columns", "columnsnumbers",
	"coming", "concatenated", "concatenatedusing", "concatenatedwith",
	"direction", "do", "downto",
	"each", "eachnchars", "eachnitems",
	"else", "end", "endat", "endatoccurrence", "endatposition",
	"endingat", "endingatoccurrence", "endingatposition",
	"endofline", "endoflist", "endofsentence", "endofstring", "endofword",
	"endsat", "endsatoccurrence", "endsatposition",
	"equals", "equalto", "eval", "evaldirection", "evalfrom",
	"evaluate", "evaluatefrom", "evaluationdirection",
	"exactly", "except", "expression",
	"first", "firstchars", "firstnchars", "firstposition",
	"for", "foreach", "forward",
	"from", "fromend", "fromendoflist", "fromendofstring", "fromposition",
	"frompositionofchar", "frompositionofitem", "frompositionofstring",
	"frompositions", "fromstart", "fromstartoflist", "fromstartofstring",
	"going", "grandtotal", "greaterthan", "grid", "group",
	"harvest", "harvestsection", "harvestsections", "hashlist",
	"id", "if", "in",
	"ina", "inalistof", "inalistofn", "inalistofnitems", "inalistofsize",
	"inalistofsizen",
	"incell", "incells", "inchar", "incol", "incolnumber", "incols",
	"incolsnumbers", "incolumn", "incolumnnumber", "incolumns",
	"incolumnsnumbers", "inhashlist", "inlist", "inlistof", "inlistofn",
	"inlistofnitems", "inlistofsize", "inlistofsizen",
	"innumber", "inobject", "inpair", "inplan", "inposition", "inpositions",
	"inrange", "inrow", "inrownumber", "inrows", "inrowsnumbers",
	"insection", "insections", "inset", "inside",
	"insidea", "insidechar", "insidehashlist", "insidelist", "insidenumber",
	"insideobject", "insidepair", "insideset", "insidestring",
	"insidesubstring",
	"instring", "instringof", "instringofsizen", "insubstring",
	"insubstrings", "intertotal",
	"isboundedby", "isboundof", "isfirstboundof", "isgreaterthan",
	"islastboundof", "isleftboundof", "islessthan", "isofitem",
	"isrightboundof",
	"it", "item", "itemat", "itematposition", "itemfrom", "itemfromposition",
	"items", "jump", "label",
	"last", "lastchars", "lastnchars", "lastposition", "lastsep",
	"lessthan", "like", "list", "listoflists", "listsize",
	"madeof", "n", "name", "named", "namedas",
	"ncharsafter", "ncharsbefore", "next", "nextnth",
	"nfirstchars", "nfirstitems", "nlastchars", "nlastitems",
	"nor", "not", "nstep", "nsteps", "nth", "nthnext", "nthoccurrence",
	"nthprevious", "nthtofirst", "nthtolast",
	"number", "numberofchars", "numberofitems", "numbers",
	"object", "occurrence",
	"of", "ofcell", "ofcellpart", "ofcells", "ofcellvalue",
	"ofchar", "ofcol", "ofcolnumber", "ofcols", "ofcolsnumbers",
	"ofcolumn", "ofcolumnnumber", "ofcolumns", "ofcolumnsnumbers",
	"ofhashlist", "oflist", "ofnumber", "ofobject", "ofpair", "ofpart",
	"ofplan", "ofrow", "ofrownumber", "ofrows", "ofrowsnumbers",
	"ofsection", "ofsections", "ofset", "ofsize", "ofstring",
	"ofsubpart", "ofsubstring", "ofsubstrings", "ofsubvalue", "ofsubvalues",
	"ofthese", "ofthesechars", "oftheseletters", "oftheselists",
	"ofthesenumbers", "oftheseobjects", "ofthesesubstrings", "ofvalue",
	"on", "onchar", "oncomplete", "onerror", "onhashlist", "onlist",
	"onnumber", "onobject", "onpair", "onposition", "onpositions",
	"onsection", "onsectionib", "onsections", "onsectionsib", "onset",
	"onstring", "onsubstring", "onsuccess", "onupdate",
	"or", "ora", "oran", "orthat", "orthis", "otherwise",
	"pair", "paramname", "part", "pattern", "person",
	"position", "positionib", "positions", "positionsib",
	"previous", "previousnth",
	"respectively", "return", "returnas", "returnedas", "returnitas",
	"returnthemas",
	"row", "rows",
	"section", "sectionib", "sections", "sectionsib",
	"seed", "separator", "size",
	"start", "startat", "startatoccurrence", "startatposition", "startfrom",
	"startingat", "startingatoccurrence", "startingatposition", "startingfrom",
	"startoflist", "startofstring", "startsatoccurrence", "startsatposition",
	"startsfrom",
	"step", "stepping", "steps", "stop", "stopat", "stopatoccurrence",
	"stoppingat", "stoppingatoccurrence", "stoppingatposition", "stopsat",
	"stopsatoccurrence",
	"string", "stringat", "stringatposition", "strings", "stringsize",
	"subpart", "substring", "substrings", "subtotal", "subvalue", "subvalues",
	"table", "than", "that", "then",
	"thenharvest", "thenharvestsection", "thenharvestsections",
	"thenyield", "thenyieldsection", "thenyieldsections",
	"thesechars", "theseitems", "theselists", "thesenumbers", "theseobjects",
	"thesepositions", "thesepositionsib", "thesesections", "thesesectionsib",
	"thesestrings", "thesesubstrings",
	"this", "thischar", "thisitem", "thislist", "thisnumber", "thisobject",
	"thisposition", "thispositionib", "thissection", "thissectionib",
	"thisstring", "thissubstring",
	"to", "tochar", "tocharat", "tocharatposition", "toeach", "toend",
	"toendofline", "toendoflist", "toendofsentence", "toendofstring",
	"toendofword", "tofirst", "toitem", "toitemat", "toitematposition",
	"toitems", "tolast", "tolist", "tomany", "tonchars", "tonitems",
	"tonth", "tonumber", "toobject", "topair", "toposition", "topositionof",
	"topositionofchar", "topositionofitem", "topositionofstring",
	"topositions", "tosection", "tosections", "toset", "tostart",
	"tostartoflist", "tostartofstring", "tostring", "tostringat",
	"tostringatposition", "tostrings", "tosubstring", "tosubstrings",
	"tothis",
	"type", "under",
	"until", "untilchar", "untilitem", "untillist", "untilnumber",
	"untilobject", "untilposition", "untilstring", "untilsubstring",
	"untilxt",
	"upto", "uptochar", "uptoitem", "uptolist", "upton", "uptonbounds",
	"uptonchars", "uptonitems", "uptonumber", "uptoobject", "uptoposition",
	"uptostring", "uptosubstring",
	"using", "usingitem", "usingitems", "usingmany", "usingmanyxt",
	"usingstring", "usingstrings", "usingsubstring", "usingsubstrings",
	"usingtheseitems", "usingthesestrings", "usingthesesubstrings",
	"usingthisitem", "usingthisstring", "usingthissubstring",
	"value", "values", "when", "where", "wherext", "while", "width",
	"with", "withchar", "withhashlist", "withlist", "withmany", "withmanyxt",
	"withnumber", "withobject", "withpair", "withset", "withstring",
	"withsubstring", "withtheir",
	"yield", "yieldsection", "yieldsections"
]

  ///////////////////
 ///  CHECKPARAM  ///
///////////////////

func StzCheckParam(pValue, p2, p3)

	if isList(p2) and len(p2) = 2 and isString(p2[1]) and p2[1] = :Skipping
		pacSkipping = p2[2]
	else
		pacSkipping = p2
	ok

	if isList(p3) and len(p3) = 2 and isString(p3[1]) and p3[1] = :MustBe
		cMustBe = p3[2]
	else
		cMustBe = p3
	ok

	if isList(pValue) and len(pValue) = 2 and isString(pValue[1])
		cKey = StzLower(pValue[1])
		nLen = len(pacSkipping)
		for i = 1 to nLen
			if cKey = StzLower(pacSkipping[i])
				pValue = pValue[2]
				exit
			ok
		next
	ok

	if CheckingParams()
		bOk = _CheckType(pValue, cMustBe)
		if NOT bOk
			StzRaise("Incorrect param type! " +
				 "Expected " + cMustBe + ".")
		ok
	ok

	return pValue

	func CheckParam(pValue, p2, p3)
		return StzCheckParam(pValue, p2, p3)

  ////////////////////////
 ///  CHECKPARAM (CS)  ///
////////////////////////

func StzCheckParamCS(pValue)
	if isList(pValue) and len(pValue) = 2 and isString(pValue[1])
		cKey = StzLower(pValue[1])
		if cKey = "casesensitive" or cKey = "cs"
			pValue = pValue[2]
		ok
	ok

	if NOT isNumber(pValue)
		if CheckingParams()
			StzRaise("Incorrect param type! " +
				 "CaseSensitive must be a number (0 or 1).")
		ok
		return 1
	ok

	return pValue

	func CheckParamCS(pValue)
		return StzCheckParamCS(pValue)

  ////////////////////////////
 ///  NAMED PARAM CHECKS  ///
////////////////////////////

func StzIsNamedParamList(paList)
	if NOT isList(paList)
		return 0
	ok

	if len(paList) != 2
		return 0
	ok

	if NOT isString(paList[1])
		return 0
	ok

	return ring_find($_acStzNamedParams, StzLower(paList[1])) > 0

	func IsNamedParamList(paList)
		return StzIsNamedParamList(paList)

func StzIsThisNamedParam(paList, cKeyword)
	if NOT isList(paList)
		return 0
	ok

	if len(paList) != 2
		return 0
	ok

	if NOT isString(paList[1])
		return 0
	ok

	if StzLower(paList[1]) = StzLower(cKeyword)
		return 1
	ok

	return 0

	func IsThisNamedParam(paList, cKeyword)
		return StzIsThisNamedParam(paList, cKeyword)

func StzIsOneOfTheseNamedParamsList(paList, pacKeywords)
	if NOT isList(paList)
		return 0
	ok

	if len(paList) != 2
		return 0
	ok

	if NOT isString(paList[1])
		return 0
	ok

	cParam = StzLower(paList[1])
	nLen = len(pacKeywords)

	for i = 1 to nLen
		if cParam = StzLower(pacKeywords[i])
			return 1
		ok
	next

	return 0

	func IsOneOfTheseNamedParamsList(paList, pacKeywords)
		return StzIsOneOfTheseNamedParamsList(paList, pacKeywords)

  /////////////////////////
 ///  TYPE CHECK LOGIC  ///
/////////////////////////

func _CheckType(pValue, cExpected)
	switch cExpected
	on :string
		return isString(pValue)
	on :number
		return isNumber(pValue)
	on :list
		return isList(pValue)
	on :object
		return isObject(pValue)
	on :string_or_number
		return isString(pValue) or isNumber(pValue)
	on :number_or_string
		return isString(pValue) or isNumber(pValue)
	on :string_or_list
		return isString(pValue) or isList(pValue)
	on :list_or_string
		return isString(pValue) or isList(pValue)
	on :any
		return 1
	other
		return 1
	off

  //////////////////////////////////
 ///  SPECIFIC PARAM CHECKERS  ///
//////////////////////////////////

func StzIsOfNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Of

	func IsOfNamedParamList(paList)
		return StzIsOfNamedParamList(paList)

func StzIsCaseSensitiveNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	if NOT isNumber(paList[2]) return 0 ok
	if NOT (paList[1] = :CaseSensitive or paList[1] = :CS) return 0 ok
	if NOT (paList[2] = 0 or paList[2] = 1) return 0 ok
	return 1

	func IsCaseSensitiveNamedParamList(paList)
		return StzIsCaseSensitiveNamedParamList(paList)

func StzIsAndNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :And or paList[1] = :And@

	func IsAndNamedParamList(paList)
		return StzIsAndNamedParamList(paList)

func StzIsWithOrByNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	cKey = paList[1]
	return cKey = :With or cKey = :With@ or cKey = :By or cKey = :By@

	func IsWithOrByNamedParamList(paList)
		return StzIsWithOrByNamedParamList(paList)

func StzIsToNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :To

	func IsToNamedParamList(paList)
		return StzIsToNamedParamList(paList)

func StzIsStartingAtNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StartingAt

	func IsStartingAtNamedParamList(paList)
		return StzIsStartingAtNamedParamList(paList)

func StzIsStartingAtOrStartingAtPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StartingAt or paList[1] = :StartingAtPosition

	func IsStartingAtOrStartingAtPositionNamedParamList(paList)
		return StzIsStartingAtOrStartingAtPositionNamedParamList(paList)

func StzIsAtNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :At

	func IsAtNamedParamList(paList)
		return StzIsAtNamedParamList(paList)

func StzIsAtOrAtSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :At or paList[1] = :AtSubString

	func IsAtOrAtSubStringNamedParamList(paList)
		return StzIsAtOrAtSubStringNamedParamList(paList)

func StzIsAtOrAtItemNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :At or paList[1] = :AtItem

	func IsAtOrAtItemNamedParamList(paList)
		return StzIsAtOrAtItemNamedParamList(paList)

func StzIsInNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :In

	func IsInNamedParamList(paList)
		return StzIsInNamedParamList(paList)

func StzIsBoundedByNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BoundedBy

	func IsBoundedByNamedParamList(paList)
		return StzIsBoundedByNamedParamList(paList)

func StzIsBoundedByOrBoundsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BoundedBy or paList[1] = :Bounds

	func IsBoundedByOrBoundsNamedParamList(paList)
		return StzIsBoundedByOrBoundsNamedParamList(paList)

func StzIsBoundsOrBoundedByNamedParamList(paList)
	return StzIsBoundedByOrBoundsNamedParamList(paList)

	func IsBoundsOrBoundedByNamedParamList(paList)
		return StzIsBoundsOrBoundedByNamedParamList(paList)

func StzIsPatternNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Pattern

	func IsPatternNamedParamList(paList)
		return StzIsPatternNamedParamList(paList)

func StzIsWithOrByOrUsingNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :By or paList[1] = :Using

	func IsWithOrByOrUsingNamedParamList(paList)
		return StzIsWithOrByOrUsingNamedParamList(paList)

func StzIsWhereNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Where

	func IsWhereNamedParamList(paList)
		return StzIsWhereNamedParamList(paList)

func StzIsFromNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :From or paList[1] = :FromPosition

	func IsFromNamedParamList(paList)
		return StzIsFromNamedParamList(paList)

func StzIsByNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :By or paList[1] = :By@

	func IsByNamedParamList(paList)
		return StzIsByNamedParamList(paList)

func StzIsEachNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Each or paList[1] = :Each@

	func IsEachNamedParamList(paList)
		return StzIsEachNamedParamList(paList)

func StzIsReturnedAsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :ReturnedAs

	func IsReturnedAsNamedParamList(paList)
		return StzIsReturnedAsNamedParamList(paList)

func StzIsBetweenNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Between

	func IsBetweenNamedParamList(paList)
		return StzIsBetweenNamedParamList(paList)

func StzIsItemNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Item

	func IsItemNamedParamList(paList)
		return StzIsItemNamedParamList(paList)

func StzIsWithNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :With@

	func IsWithNamedParamList(paList)
		return StzIsWithNamedParamList(paList)

func StzIsOfOrOfSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Of or paList[1] = :OfSubString

	func IsOfOrOfSubStringNamedParamList(paList)
		return StzIsOfOrOfSubStringNamedParamList(paList)

func StzIsOrNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Or

	func IsOrNamedParamList(paList)
		return StzIsOrNamedParamList(paList)

func StzIsUsingOrWithOrByOrWhereNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Using or paList[1] = :With or paList[1] = :By or paList[1] = :Where

	func IsUsingOrWithOrByOrWhereNamedParamList(paList)
		return StzIsUsingOrWithOrByOrWhereNamedParamList(paList)

func StzIsPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Position

	func IsPositionNamedParamList(paList)
		return StzIsPositionNamedParamList(paList)

func StzIsNorNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Nor

	func IsNorNamedParamList(paList)
		return StzIsNorNamedParamList(paList)

func StzIsInSectionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :InSection

	func IsInSectionNamedParamList(paList)
		return StzIsInSectionNamedParamList(paList)

func StzIsThanNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Than

	func IsThanNamedParamList(paList)
		return StzIsThanNamedParamList(paList)

func StzIsToOrToPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :To or paList[1] = :ToPosition

	func IsToOrToPositionNamedParamList(paList)
		return StzIsToOrToPositionNamedParamList(paList)

func StzIsWithOrUsingOrByNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :Using or paList[1] = :By

	func IsWithOrUsingOrByNamedParamList(paList)
		return StzIsWithOrUsingOrByNamedParamList(paList)

func StzIsPositionOrPositionsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Position or paList[1] = :Positions

	func IsPositionOrPositionsNamedParamList(paList)
		return StzIsPositionOrPositionsNamedParamList(paList)

func StzIsPositionOrSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Position or paList[1] = :SubString

	func IsPositionOrSubStringNamedParamList(paList)
		return StzIsPositionOrSubStringNamedParamList(paList)

func StzIsAndThenNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :AndThen

	func IsAndThenNamedParamList(paList)
		return StzIsAndThenNamedParamList(paList)

func StzIsForNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :For

	func IsForNamedParamList(paList)
		return StzIsForNamedParamList(paList)

func StzIsSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :SubString

	func IsSubStringNamedParamList(paList)
		return StzIsSubStringNamedParamList(paList)

func StzIsUpToNCharsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :UpToNChars

	func IsUpToNCharsNamedParamList(paList)
		return StzIsUpToNCharsNamedParamList(paList)

func StzIsAsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :As

	func IsAsNamedParamList(paList)
		return StzIsAsNamedParamList(paList)

func StzIsNthNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Nth

	func IsNthNamedParamList(paList)
		return StzIsNthNamedParamList(paList)

func StzIsBeforeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Before

	func IsBeforeNamedParamList(paList)
		return StzIsBeforeNamedParamList(paList)

func StzIsUsingNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Using

	func IsUsingNamedParamList(paList)
		return StzIsUsingNamedParamList(paList)

func StzIsAfterNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :After

	func IsAfterNamedParamList(paList)
		return StzIsAfterNamedParamList(paList)

func StzIsAtOrAtPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :At or paList[1] = :AtPosition

	func IsAtOrAtPositionNamedParamList(paList)
		return StzIsAtOrAtPositionNamedParamList(paList)

func StzIsAtPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :AtPosition

	func IsAtPositionNamedParamList(paList)
		return StzIsAtPositionNamedParamList(paList)

func StzIsAtPositionsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :AtPositions

	func IsAtPositionsNamedParamList(paList)
		return StzIsAtPositionsNamedParamList(paList)

func StzIsBeforePositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BeforePosition

	func IsBeforePositionNamedParamList(paList)
		return StzIsBeforePositionNamedParamList(paList)

func StzIsAfterPositionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :AfterPosition

	func IsAfterPositionNamedParamList(paList)
		return StzIsAfterPositionNamedParamList(paList)

func StzIsBeforeOrAfterNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Before or paList[1] = :After

	func IsBeforeOrAfterNamedParamList(paList)
		return StzIsBeforeOrAfterNamedParamList(paList)

func StzIsBetweenIBNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BetweenIB

	func IsBetweenIBNamedParamList(paList)
		return StzIsBetweenIBNamedParamList(paList)

func StzIsBoundedByIBNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :BoundedByIB

	func IsBoundedByIBNamedParamList(paList)
		return StzIsBoundedByIBNamedParamList(paList)

func StzIsByOrWithNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :By or paList[1] = :With

	func IsByOrWithNamedParamList(paList)
		return StzIsByOrWithNamedParamList(paList)

func StzIsDirectionNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Direction

	func IsDirectionNamedParamList(paList)
		return StzIsDirectionNamedParamList(paList)

func StzIsDirectionOrGoingNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Direction or paList[1] = :Going

	func IsDirectionOrGoingNamedParamList(paList)
		return StzIsDirectionOrGoingNamedParamList(paList)

func StzIsEqualToNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :EqualTo

	func IsEqualToNamedParamList(paList)
		return StzIsEqualToNamedParamList(paList)

func StzIsFirstNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :First

	func IsFirstNamedParamList(paList)
		return StzIsFirstNamedParamList(paList)

func StzIsLastNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Last

	func IsLastNamedParamList(paList)
		return StzIsLastNamedParamList(paList)

func StzIsListNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :List

	func IsListNamedParamList(paList)
		return StzIsListNamedParamList(paList)

func StzIsRangeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Range

	func IsRangeNamedParamList(paList)
		return StzIsRangeNamedParamList(paList)

func StzIsRespectivelyNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Respectively

	func IsRespectivelyNamedParamList(paList)
		return StzIsRespectivelyNamedParamList(paList)

func StzIsReturnTypeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :ReturnType

	func IsReturnTypeNamedParamList(paList)
		return StzIsReturnTypeNamedParamList(paList)

func StzIsSectionsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Sections

	func IsSectionsNamedParamList(paList)
		return StzIsSectionsNamedParamList(paList)

func StzIsStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :String

	func IsStringNamedParamList(paList)
		return StzIsStringNamedParamList(paList)

func StzIsStringOrSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :String or paList[1] = :SubString

	func IsStringOrSubStringNamedParamList(paList)
		return StzIsStringOrSubStringNamedParamList(paList)

func StzIsSubStringsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :SubStrings

	func IsSubStringsNamedParamList(paList)
		return StzIsSubStringsNamedParamList(paList)

func StzIsSubStringOrSubStringsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :SubString or paList[1] = :SubStrings

	func IsSubStringOrSubStringsNamedParamList(paList)
		return StzIsSubStringOrSubStringsNamedParamList(paList)

func StzIsUsingOrByOrWithNamedParamList(paList)
	return StzIsWithOrByOrUsingNamedParamList(paList)

	func IsUsingOrByOrWithNamedParamList(paList)
		return StzIsUsingOrByOrWithNamedParamList(paList)

func StzIsUsingOrWithOrByNamedParamList(paList)
	return StzIsWithOrByOrUsingNamedParamList(paList)

	func IsUsingOrWithOrByNamedParamList(paList)
		return StzIsUsingOrWithOrByNamedParamList(paList)

func StzIsWithOrUsingNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :Using

	func IsWithOrUsingNamedParamList(paList)
		return StzIsWithOrUsingNamedParamList(paList)

func StzIsWithOrUsingOrInNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :With or paList[1] = :Using or paList[1] = :In

	func IsWithOrUsingOrInNamedParamList(paList)
		return StzIsWithOrUsingOrInNamedParamList(paList)

func StzIsInOrInsideNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :In or paList[1] = :Inside

	func IsInOrInsideNamedParamList(paList)
		return StzIsInOrInsideNamedParamList(paList)

func StzIsOfTypeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :OfType

	func IsOfTypeNamedParamList(paList)
		return StzIsOfTypeNamedParamList(paList)

func StzIsOrOrAndNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Or or paList[1] = :And

	func IsOrOrAndNamedParamList(paList)
		return StzIsOrOrAndNamedParamList(paList)

func StzIsStartingAtOrAfterNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StartingAt or paList[1] = :After

	func IsStartingAtOrAfterNamedParamList(paList)
		return StzIsStartingAtOrAfterNamedParamList(paList)

func StzIsStartingAtOrBeforeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StartingAt or paList[1] = :Before

	func IsStartingAtOrBeforeNamedParamList(paList)
		return StzIsStartingAtOrBeforeNamedParamList(paList)

func StzIsStoppingAtNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :StoppingAt

	func IsStoppingAtNamedParamList(paList)
		return StzIsStoppingAtNamedParamList(paList)

func StzIsANamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :A

	func IsANamedParamList(paList)
		return StzIsANamedParamList(paList)

func StzIsNameOrNamedNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Name or paList[1] = :Named

	func IsNameOrNamedNamedParamList(paList)
		return StzIsNameOrNamedNamedParamList(paList)

func StzIsNCharsAfterNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :NCharsAfter

	func IsNCharsAfterNamedParamList(paList)
		return StzIsNCharsAfterNamedParamList(paList)

func StzIsNCharsBeforeNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :NCharsBefore

	func IsNCharsBeforeNamedParamList(paList)
		return StzIsNCharsBeforeNamedParamList(paList)

func StzIsLastCharsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :LastChars

	func IsLastCharsNamedParamList(paList)
		return StzIsLastCharsNamedParamList(paList)

func StzIsLastNCharsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :LastNChars

	func IsLastNCharsNamedParamList(paList)
		return StzIsLastNCharsNamedParamList(paList)

func StzIsNLastCharsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :NLastChars

	func IsNLastCharsNamedParamList(paList)
		return StzIsNLastCharsNamedParamList(paList)

func StzIsUpToOrUpToNItemsNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :UpTo or paList[1] = :UpToNItems

	func IsUpToOrUpToNItemsNamedParamList(paList)
		return StzIsUpToOrUpToNItemsNamedParamList(paList)

func StzIsAndOrAndPositionOrAndSubStringNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :And or paList[1] = :AndPosition or paList[1] = :AndSubString

	func IsAndOrAndPositionOrAndSubStringNamedParamList(paList)
		return StzIsAndOrAndPositionOrAndSubStringNamedParamList(paList)

func StzIsOfOrToNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Of or paList[1] = :To

	func IsOfOrToNamedParamList(paList)
		return StzIsOfOrToNamedParamList(paList)

func StzIsSayOrReturnNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Say or paList[1] = :Return

	func IsSayOrReturnNamedParamList(paList)
		return StzIsSayOrReturnNamedParamList(paList)

func StzIsElseOrOtherwiseNamedParamList(paList)
	if NOT isList(paList) return 0 ok
	if len(paList) != 2 return 0 ok
	if NOT isString(paList[1]) return 0 ok
	return paList[1] = :Else or paList[1] = :Otherwise

	func IsElseOrOtherwiseNamedParamList(paList)
		return StzIsElseOrOtherwiseNamedParamList(paList)
