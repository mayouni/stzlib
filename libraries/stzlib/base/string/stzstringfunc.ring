  /////////////////////////////////////////////
 ///   FUNCTIONS FOR THE STZSTRING CLASS   ///
/////////////////////////////////////////////

func StzStringQ(str)
	return new stzString(str)

	#< @FunctionMisspelledForm

	func StzSrtringQ(str)
		return StzStringQ(str)

func StzNamedString(paNamed)
	if CheckingParams()
		if NOT (isList(paNamed) and Q(paNamed).IsPairOfStrings())
			StzRaise("Incorrect param type! paNamed must be a pair of strings.")
		ok
	ok

	oStr = new stzString(paNamed[2])
	oStr.SetName(paNamed[1])
	return ostr

	func StzNamedStringQ(paNamed)
		return StzNamedString(paNamed)

	func StzNamedStringXTQ(paNamed)
		return StzNamedString(paNamed)

func StzStringMethods()
	return Stz(:String, :Methods)

func StzStringAttributes()
	return Stz(:String, :Attributes)

func StzStringClassName()
	return Stz(:String, :ClassName)

	func StzStringClass()
		return StzStringClassName()

#--

func StringIsInListCS(str, aList, pCaseSensitive)
	return ListContainsCS(aList, str, pCaseSensitive)

func StringIsInList(str, aList)
	return ListContains(aList, str)

func PadRight(cText, nWidth)
	return PAdtRightXT(cText, nWidth, " ")

func PadRightXT(text, width, c)
    cStr = "" + text
    nPad = width - len(cStr)
    if nPad > 0
        return cStr + copy(c, nPad)
    else
        return cStr
    ok

func PadLeft(cText, nWidth)
	return PadLeftXT(cText, nWidth, " ")

func PadLeftXT(text, width, c) #TODO Use stzString
    cStr = "" + text
    nPad = width - len(cStr)
    if nPad > 0
        return copy(c, nPad) + cStr
    else
        return cStr
    ok

func Center(text, width) #TODO Use stzString
    cStr = "" + text
    nPadTotal = width - len(cStr)
    if nPadTotal <= 0
        return cStr
    ok
    
    nPadLeft = floor(nPadTotal / 2)
    nPadRight = nPadTotal - nPadLeft
    
    return copy(" ", nPadLeft) + cStr + copy(" ", nPadRight)

#---


func Capitalize(str)
		if len(str) = 0 return str ok
		return upper(str[1]) + substr(str, 2)

		func Capitalise(str)
			return Capitalize(str)

		func @Capitalize(str)
			return Capitalize(str)

		func @Capitalise(str)
			return Capitalize(str)
#--

func IsInvisibleString(str)

	if CheckParams()
		if NOT isString(str)
			stzraise("Incorrect param type! str must be a string.")
		ok
	ok

	_acChars_ = Chars(str)
	_nLen_ = len(_acChars_)

	_bResult_ = 1

	for @i = 1 to _nLen_
		if NOT IsInvisibleChar(_acChars_[@i])
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

	func @IsInvisibleString(str)
		return IsInvisibleString(str)

	func IsInvisible(str)
		return IsInvisibleString(str)

	func @IsInvisible(str)
		return IsInvisibleString(str)

#--

func IsNotString(pcStr)
	return NOT isString(pcStr)

	func IsNotAString(pcStr)
		return IsNotString(pcStr)

	func @IsNotString(pcStr)
		return IsNotString(pcStr)

	func @IsNotAString(pcStr)
		return IsNotString(pcStr)

func @IsAlpha(cStr)
	nLen = len(cStr)
	if nLen = 0 return 0 ok
	for i = 1 to nLen
		n = ascii(substr(cStr, i, 1))
		if NOT ((n >= 65 and n <= 90) or (n >= 97 and n <= 122))
			return 0
		ok
	next
	return 1

	#< @FunctionAlternativeForms

	func IsAlphabetical(cStr)
		return @IsAlpha(cStr)

	func @IsAlphabetical(cStr)
		return @IsAlpha(cStr)

	#--

	func IsAlphabetic(cStr)
		return @IsAlpha(cStr)

	func @IsAlphabetic(cStr)
		return @IsAlpha(cStr)

	#>

func @IsAlnum(cStr)
	nLen = len(cStr)
	if nLen = 0 return 0 ok
	for i = 1 to nLen
		n = ascii(substr(cStr, i, 1))
		if NOT ((n >= 65 and n <= 90) or (n >= 97 and n <= 122) or (n >= 48 and n <= 57))
			return 0
		ok
	next
	return 1

	#< @FunctionAlternativeForms

	func IsAlphaNumerical(cStr)
		return @IsAlnum(cStr)

	func @IsAlphaNumerical(cStr)
		return @IsAlnum(cStr)

	#--

	func IsAlphaNumeric(cStr)
		return @IsAlnum(cStr)

	func @IsAlphanumeric(cStr)
		return @IsAlnum(cStr)

	#>

func IsEmpty(p)
	if isString(p)
		return IsNullString(p)

	but isNumber(p)
		return FALSE

	but isList(p) and len(p) = 0
		return TRUE

	but isObject(p) and IsNullObject(p)
		return TRUE

	else
		return FALSE
	ok

	func @IsEmpty(p)
		return IsNullString(p)


func IsNull(p)
	if isString(p)
		return IsNullString(p)

	but isObject(p) and IsNullObject(p)
		return TRUE

	else
		return FALSE
	ok

	#--

	func @IsNull(cStr)
		return IsNull(cStr)

func IsNullString(cStr)
	if isString(cStr) and cStr = ""
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsEmptyString(cStr)
		return IsNullString(cStr)

	func ANullString(pcStr)
		return IsNullString(cStr)

	func IsAnEmptyString(cStr)
		return IsNullString(cStr)

	#--

	func @IsNullString(cStr)
		return IsNullString(cStr)

	func @IsEmptyString(cStr)
		return IsNullString(cStr)

	func @ANullString(pcStr)
		return IsNullString(cStr)

	func @IsAnEmptyString(cStr)
		return IsNullString(cStr)

	#==

		func StringIsNull(pcStr)
			return isString(pcStr) and pcStr = ""

	#>

func IsNonNullString(cStr)
	return NOT IsNullString(cStr)

	#< @FunctionAlternativeForms

	func IsNonEmptyString(cStr)
		return IsNonNullString(cStr)

	func ANonNullString(pcStr)
		return IsNonNullString(cStr)

	func IsANonEmptyString(cStr)
		return IsNonNullString(cStr)

	#--

	func @IsNonNullString(cStr)
		return IsNonNullString(cStr)

	func @IsNonEmptyString(cStr)
		return IsNonNullString(cStr)

	func @ANonNullString(pcStr)
		return IsNonNullString(cStr)

	func @IsANonEmptyString(cStr)
		return IsNonNullString(cStr)

	#>

func IsBlank(pcStr)
	nLen = len(pcStr)
	if nLen = 0 return 0 ok
	for i = 1 to nLen
		if substr(pcStr, i, 1) != " " return 0 ok
	next
	return 1

	#< @FunctionAlternativeForms

	func IsBlankString(pcStr)
		return IsBlank(pcStr)

	func IsABlankString(pcStr)
		return IsBlank(pcStr)

	#--

	func @IsBlank(pcStr)
		return IsBlank(pcStr)

	func @IsBlankString(pcStr)
		return IsBlank(pcStr)

	func @IsABlankString(pcStr)
		return IsBlank(pcStr)

	#>

#TODO Some of these functions should call their corresponding (same)
# functions in the core layer

func ContainsCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
	if isString(pStrOrList)
		return StringContainsCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

	but isList(pStrOrList)
		return ListContainsCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
	else
		StzRaise("Can't proceed! pStrOrList must be a string or list.")
	ok

	func @ContainsCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return ContainsCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

func Contains(pStrOrList, pSubStrOrItem)
	return ContainsCS(pStrOrList, pSubStrOrItem, 1)

	func @Contains(pStrOrList, pSubStrOrItem)
		return Contains(pStrOrList, pSubStrOrItem)

func ContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
	if isString(pStrOrList)
		return StringContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

	but isList(pStrOrList)
		return ListContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
	else
		StzRaise("Can't proceed! pStrOrList must be a string or list.")
	ok

	func @ContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return ContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

func ContainsOneOfThese(pStrOrList, pSubStrOrItem)
	return ContainsOneOfTheseCS(pStrOrList, pSubStrOrItem, 1)

	func @ContainsOneOfThese(pStrOrList, pSubStrOrItem)
		return ContainsOneOfThese(pStrOrList, pSubStrOrItem)

#==

func StartsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
	return Q(pStrOrList).StartsWithCS(pSubStrOrItem, bCaseSensitive)

	func BeginsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StartsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

	func @StartsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StartsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

	func @BeginsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return StartsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

func StzStartsWith(pStrOrList, pSubStrOrItem) # startsWith() seems to be reserved by Ring StdLib
	return Q(pStrOrList).StartsWith(pSubStrOrItem)

	func @StartsWith(pStrOrList, pSubStrOrItem)
		return StzStartsWith(pStrOrList, pSubStrOrItem)

	func BeginsWith(pStrOrList, pSubStrOrItem)
		return StzStartsWith(pStrOrList, pSubStrOrItem)

	func @BeginsWith(pStrOrList, pSubStrOrItem)
		return StzStartsWith(pStrOrList, pSubStrOrItem)

#--

func EndsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
	return Q(pStrOrList).EndsWithCS(pSubStrOrItem, bCaseSensitive)

	func @EndsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)
		return EndsWithCS(pStrOrList, pSubStrOrItem, bCaseSensitive)

func StzEndsWith(pStrOrList, pSubStrOrItem) # endsWith() seems to be reserved by Ring StdLib
	return Q(pStrOrList).EndsWith(pSubStrOrItem)

	func @EndsWith(pStrOrList, pSubStrOrItem)
		return StzEndsWith(pStrOrList, pSubStrOrItem)

#==

# A Ring-based implementation
# This is made as altenartive to show how Softanza enhances Ring

#~> Solves the problem where substr() function in Ring returns 1
# if we are searching for an empty string!

func StringContainsCS(pcStr, pcSubStr, pCaseSensitive)
	if CheckParams()
		if NOT ( isString(pcStr) and isString(pcSubStr) )
			StzRaise("Incorrect param type! pcStr and pcSubStr must be both strings.")
		ok
	ok

	if pcStr = "" or
	   pcSubStr = ""
		return 0
	ok

	bCase = CaseSensitive(pCaseSensitive)

	if bCase = 1
		if ring_substr1(pcStr, pcSubStr) > 0
			return 1
		else
			return 0
		ok
	else
		cStrLow = lower(pcStr)
		cSubStrLow = lower(pcSubStr)

		if ring_substr1(cStrLow, cSubStrLow) > 0
			return 1
		else
			return 0
		ok

	ok

	#< @FunctionAlternativeForms

	func @StringContainsCS(pcStr, pcSubStr, bCaseSensitive)
		return StringContainsCS(pcStr, pcSubStr, bCaseSensitive)

	func StzStringContainsCS(pcStr, pcSubStr, bCaseSensitive)
		return StringContainsCS(pcStr, pcSubStr, bCaseSensitive)

	func @StzStringContainsCS(pcStr, pcSubStr, bCaseSensitive)
		return StringContainsCS(pcStr, pcSubStr, bCaseSensitive)

	#>

func StringContains(pcStr, pcSubStr)
	return StringContainsCS(pcStr, pcSubStr, 1)

	func @StringContains(pcStr, pcSubStr)
		return StringContains(pcStr, pcSubStr)

	func StzStringContains(pcStr, pcSubStr)
		return StringContains(pcStr, pcSubStr)

	func @StzStringContains(pcStr, pcSubStr)
		return StringContains(pcStr, pcSubStr)

#--

func StringContainsOneOfTheseCS(pcStr, pacSubStr, pCaseSensitive)
	if CheckParams()
		if NOT isString(pcStr)
			StzRaise("Incorrect param type! pcStr must be a string.")
		ok

		if NOT IsListOfStrings(pacSubStr)
			StzRaise("Incorrect param type! pacSubStr must be a list of strings.")
		ok
	ok

	nLenSubStr = len(pacSubStr)

	if pcStr = "" or
	   len(pacSubStr) = 0
		return 0
	ok

	bResult = 0
	for i = 1 to nLenSubStr
		if StringContainsCS(pcStr, pacSubStr[i], pCaseSensitive)
			bResult = 1
			exit
		ok
	next

	return bResult
	

	#< @FunctionAlternativeForms

	func @StringContainsOneOfTheseCS(pcStr, pcSubStr, bCaseSensitive)
		return StringContainsOneOfTheseCS(pcStr, pcSubStr, bCaseSensitive)

	func StzStringContainsOneOfTheseCS(pcStr, pcSubStr, bCaseSensitive)
		return StringContainsOneOfTheseCS(pcStr, pcSubStr, bCaseSensitive)

	func @StzStringContainsOneOfTheseCS(pcStr, pcSubStr, bCaseSensitive)
		return StringContainsOneOfTheseCS(pcStr, pcSubStr, bCaseSensitive)

	#>

func StringContainsOneOfThese(pcStr, pcSubStr)
	return StringContainsOneOfTheseCS(pcStr, pcSubStr, 1)

	func @StringContainsOneOfThese(pcStr, pcSubStr)
		return StringContainsOneOfThese(pcStr, pcSubStr)

	func StzStringContainsOneOfThese(pcStr, pcSubStr)
		return StringContainsOneOfThese(pcStr, pcSubStr)

	func @StzStringContainsOneOfThese(pcStr, pcSubStr)
		return StringContainsOneOfThese(pcStr, pcSubStr)

#==

func StzReplaceCS(cStr, cSubStr, cNewSubStr, bCaseSensitive)
	if CheckParams()
		if NOT ( isString(cStr) and isString(cSubStr) and isString(cNewSubStr) )
			StzRaise("Incorrect params types! cStr, cSubStr, and cNewSubStr must all be strings.")
		ok
	ok

	if cStr = "" or cSubStr = ''
		return cStr
	ok
	
	bCase = CaseSensitive(bCaseSensitive)

	if bCase = 1
		cResult = substr(cStr, cSubStr, cNewSubStr)
	else
		cTemp = lower(cStr)
		cSubLow = lower(cSubStr)
		cResult = ""
		nPos = 1
		while TRUE
			nFound = substr(cTemp, nPos, cSubLow)
			if nFound = 0
				cResult += substr(cStr, nPos)
				exit
			ok
			cResult += substr(cStr, nPos, nFound - nPos) + cNewSubStr
			nPos = nFound + len(cSubStr)
		end
	ok
	return cResult

	#< @FunctionAlternativeForms

	func @ReplaceCS(cStr, cSubStr, cNewSubStr, bCaseSensitive)
		return StzReplaceCS(cStr, cSubStr, cNewSubStr, bCaseSensitive)

	func ReplaceCS(str, cSubStr, cNewSubStr, bCaseSensitive)
		return StzReplaceCS(cStr, cSubStr, cNewSubStr, bCaseSensitive)

	#>

func StzReplace(cStr, cSubStr, cNewSubStr)
	return StzReplaceCS(cStr, cSubStr, cNewSubStr, 1)

	func @Replace(cStr, cSubStr, cNewSubStr)
		return StzReplace(cStr, cSubStr, cNewSubStr)

	func Replace(cStr, cSubStr, cNewSubStr)
		return StzReplace(cStr, cSubStr, cNewSubStr)

func StzSplitCS(cStr, cSubStr, bCaseSensitive)
	return StkSplitCS(cStr, cSubStr, bCaseSensitive)

func StzSplit(cStr, cSubStr)
	return StkSplit(cStr, cSubStr)

#--

# Trim function (to use instead of the one provided by the standard library)

func StzTrim(cStrOrList)
	if CheckParams()
		if NOT (isString(cStrOrList) or isList(cStrOrList))
			StzRaise("Incorrect param type! cStrOrList must be a string or list.")
		ok
	ok

	if isString(cStrOrList)
		return TrimString(cStrOrList)

	else // isList()
		return TrimList(cStrOrList)
	ok

	func @trim(cStrOrList)
		return StzTrim(cStrOrList)

	func Trim(pcStr)
		return trim(pcStr)

func TrimString(cStr)
	if CheckParams()
		if NOT isString(cStr)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok
	ok

	return trim(cStr)

	func @TrimString(cStr)
		return TrimString(cStr)

	func StzTrimString(cStr)
		return TrimString(cStr)

func TrimLines(pStrOrList)
	if CheckParams()
		if NOT (isString(pStrOrList) or isList(pStrOrList))
			StzRaise("Incorrect param type! pStrOrList must be a string or list.")
		ok
	ok

	if stzleft(pStrOrList, 1) != NL and stzright(pStrOrList, 1) != NL
		return pStrOrList
	ok

	if isString(pStrOrList)
		acSplits = @split(pStrOrList, NL)
	else
		acSplits = pStrOrList
	ok

	return TrimList(acSplits)


func TrimList(aList)
	if CheckParams()
		if NOT isList(aList)
			StzRaise("Incorrect param type! aList must be a list.")
		ok
	ok

	oList = new stzList(aList)
	aResult = oList.Trimmed()
	return aResult

	func @TrimList(aList)
		return TrimList(aList)

	func StzTrimList(aList)
		return TrimList(aList)

func StzTrimLeft(cStrOrList)
	if CheckParams()
		if NOT (isString(cStrOrList) or isList(cStrOrList))
			StzRaise("Incorrect param type! cStrOrList must be a string or list.")
		ok
	ok

	if isString(cStrOrList)
		nLen = len(cStrOrList)
		nStart = 1
		for i = 1 to nLen
			if substr(cStrOrList, i, 1) != " " and substr(cStrOrList, i, 1) != char(9) and substr(cStrOrList, i, 1) != char(10) and substr(cStrOrList, i, 1) != char(13)
				nStart = i
				exit
			ok
		next
		return substr(cStrOrList, nStart)
	else
		return StzListQ(cStrOrList).TrimmedLeft()
	ok

	func @TrimLeft(cStrOrList)
		return StzTrimLeft(cStrOrList)

	func LeftTrim(cStrOrList)
		return StzTrimLeft(cStrOrList)

	func @LeftTrim(cStrOrList)
		return StzTrimLeft(cStrOrList)

	func ltrim(cStrOrList)
		return StzTrimLeft(cStrOrList)

	func @ltrim(cStrOrList)
		return StzTrimLeft(cStrOrList)

func StzTrimRight(cStrOrList)
	if CheckParams()
		if NOT (isString(cStrOrList) or isList(cStrOrList))
			StzRaise("Incorrect param type! cStrOrList must be a string or list.")
		ok
	ok

	if isString(cStrOrList)
		nLen = len(cStrOrList)
		nEnd = nLen
		for i = nLen to 1 step -1
			if substr(cStrOrList, i, 1) != " " and substr(cStrOrList, i, 1) != char(9) and substr(cStrOrList, i, 1) != char(10) and substr(cStrOrList, i, 1) != char(13)
				nEnd = i
				exit
			ok
		next
		return substr(cStrOrList, 1, nEnd)
	else
		return StzListQ(cStrOrList).Trimmedright()
	ok

	func @TrimRight(cStrOrList)
		return StzTrimRight(cStrOrList)

	func RightTrim(cStrOrList)
		return StzTrimRight(cStrOrList)

	func @RightTrim(cStrOrList)
		return StzTrimRight(cStrOrList)

	func rtrim(cStrOrList)
		return StzTrimRight(cStrOrList)

	func @rtrim(cStrOrList)
		return StzTrimRight(cStrOrList)

func StzTrimStart(cStrOrList)
	if CheckParams()
		if NOT (isString(cStrOrList) or isList(cStrOrList))
			StzRaise("Incorrect param type! cStrOrList must be a string or list.")
		ok
	ok

	if isString(cStrOrList)
		return StzStringQ(cStrOrList).TrimmedStart()
	else
		return StzListQ(cStrOrList).TrimmedStart()
	ok

	func @TrimStart(cStrOrList)
		return StzTrimStart(cStrOrList)

	func TrimStart(cStrOrList)
		return StzTrimStart(cStrOrList)

func StzTrimEnd(cStrOrList)
	if CheckParams()
		if NOT (isString(cStrOrList) or isList(cStrOrList))
			StzRaise("Incorrect param type! cStrOrList must be a string or list.")
		ok
	ok

	if isString(cStrOrList)
		return StzStringQ(cStrOrList).TrimmedEnd()
	else
		return StzListQ(cStrOrList).Trimmedright()
	ok

	func @TrimEnd(cStrOrList)
		return StzTrimEnd(cStrOrList)

	func TrimEnd(cStrOrList)
		return StzTrimStart(cStrOrList)


#--

func _StzSimplifyString(cStr)
	cStr = StkTrim(cStr)
	cStr = ring_substr2(cStr, char(9), " ")
	cStr = ring_substr2(cStr, char(10), " ")
	cStr = ring_substr2(cStr, char(13), " ")
	while substr(cStr, "  ") > 0
		cStr = ring_substr2(cStr, "  ", " ")
	end
	return cStr

#--

func StzStringContent(oStr)
	return oStr.Content()

func StringIsLocaleAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLocaleAbbreviation()
	
	func IsLocaleAbbreviation(cStr)
		return StringIsLocaleAbbreviation(cStr)

	func @IsLocaleAbbreviation(cStr)
		return StringIsLocaleAbbreviation(cStr)

func StringIsLanguageAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLanguageAbbreviation()

	func IsLanguageAbbreviation(cStr)
		return StringIsLanguageAbbreviation(cStr)

	func @IsLanguageAbbreviation(cStr)
		return StringIsLanguageAbbreviation(cStr)

func StringIsShortLanguageAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsShortLanguageAbbreviation()

	func @IsShortLanguageAbbreviation(cStr)
		return StringIsShortLanguageAbbreviation(cStr)

func StringIsLongLanguageAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLongLanguageAbbreviation()

	func IsLongLanguageAbbreviation(cStr)
		return StringIsLongLanguageAbbreviation(cStr)

	func @IsLongLanguageAbbreviation(cStr)
		return StringIsLongLanguageAbbreviation(cStr)

func StringIsLanguageName(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLanguageName()

	func IsLanguageName(cStr)
		return StringIsLanguageName(cStr)


	func IsLanguage(cStr)
		return StringIsLanguageName(cStr)

	func @IsLanguageName(cStr)
		return StringIsLanguageName(cStr)

	func @IsLanguage(cStr)
		return StringIsLanguageName(cStr)

func StringIsLanguageNumber(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLanguageNumber()

	func IsLanguageNumber(cStr)
		return StringIsLanguageNumber(cStr)

	func @IsLanguageNumber(cStr)
		return StringIsLanguageNumber(cStr)

func StringIsCountryAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsCountryAbbreviation()

	func IsCountryAbbreviation(cStr)
		return StringIsCountryAbbreviation(cStr)

	func @IsCountryAbbreviation(cStr)
		return StringIsCountryAbbreviation(cStr)

func StringIsCountryName(cStr)
	oStr = new stzString(cStr)
	return oStr.IsCountryName()

	func IsCountryName(cStr)
		return StringIsCountryName(cStr)

	func IsCountry(cStr)
		return StringIsCountryName(cStr)

	func @IsCountryName(cStr)
		return StringIsCountryName(cStr)

	func @IsCountry(cStr)
		return StringIsCountryName(cStr)

func StringIsCountryNumber(cStr)
	oStr = new stzString(cStr)
	return oStr.IsCountryNumber()

	func IsCountryNumber(cStr)
		return StringIsCountryNumber(cStr)

	func @IsCountryNumber(cStr)
		return StringIsCountryNumber(cStr)

func StringIsShortCountryAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsShortCountryAbbreviation()

	func IsShortCountryAbbreviation(cStr)
		return StringIsShortCountryAbbreviation(cStr)

	func @IsShortCountryAbbreviation(cStr)
		return StringIsShortCountryAbbreviation(cStr)

func StringIsLongCountryAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLongCountryAbbreviation()

	func IsLongCountryAbbreviation(cStr)
		return StringIsLongCountryAbbreviation(cStr)

	func @IsLongCountryAbbreviation(cStr)
		return StringIsLongCountryAbbreviation(cStr)

func StringIsScriptAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsScriptAbbreviation()

	func IsScriptAbbreviation(cStr)
		return StringIsScriptAbbreviation(cStr)

	func @IsScriptAbbreviation(cStr)
		return StringIsScriptAbbreviation(cStr)

func StringIsScriptName(cStr)
	oStr = new stzString(cStr)
	return oStr.IsScriptName()

	func IsScriptName(cStr)
		return StringIsScriptName(cStr)

	func IsScript(cStr)
		return StringIsScriptName(cStr)

	func @IsScriptName(cStr)
		return StringIsScriptName(cStr)

	func @IsScript(cStr)
		return StringIsScriptName(cStr)

func StringIsScriptNumber(cStr)
	oStr = new stzString(cStr)
	return oStr.IsScriptNumber()

	func IsScriptNumber(cStr)
		return StringIsScriptNumber(cStr)

	func @IsScriptNumber(cStr)
		return StringIsScriptNumber(cStr)

func StringIsLowercase(cStr)
	return cStr = lower(cStr)

func StringIsUppercase(cStr)
	return cStr = upper(cStr)

func StringLowercased(cStr)
	return lower(cStr)
	
	func Lowercased(cStr)
		return StringLowercased(cStr)

	func Lowercase(cStr)
		return StringLowercased(cStr)

	func StringLowercase(cStr)
		return StringLowercased(cStr)

	func @Lowercased(cStr)
		return StringLowercased(cStr)

	func @Lowercase(cStr)
		return StringLowercased(cStr)

func StringUppercased(cStr)
	return upper(cStr)
	
	func Uppercase(cStr)
		return StringUppercased(cStr)

	func Uppercased(cStr)
		return StringUppercased(cStr)

	func StringUppercase(cStr)
		return StringUppercased(cStr)

	func @Uppercased(cStr)
		return StringUppercased(cStr)

	func @Uppercase(cStr)
		return StringUppercased(cStr)

func StringTitlecased(cStr)
	oStr = new stzString(cStr)
	return oStr.Titlecased()
	
	func Titlecase(cStr)
		return StringTitlecased(cStr)

	func Titlecased(cStr)
		return StringTitlecased(cStr)

	func StringTitlecase(cStr)
		return StringTitlecased(cStr)

	func @Titlecased(cStr)
		return StringTitlecased(cStr)
	
	func @Titlecase(cStr)
		return StringTitlecased(cStr)

#===

func IsSorted(pcStrOrList)
	if IsSortedString(pcStrOrList) or IsSortedList(pcStrOrList)
		return 1
	else
		return 0
	ok

	func @IsSorted(pcStrOrList)
		return IsSorted(pcStrOrList)

func IsSortedInAscending(pcStrOrList)
	if IsSortedStringInAscending(pcStrOrList) or IsSortedListInAscending(pcStrOrList)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsSortedUp(pcStrOrList)
		return IsSortedInAscending(pcStrOrList)

	#--

	func @IsSortedInAscending(pcStrOrList)
		return IsSortedInAscending(pcStrOrList)

	func @IsSortedUp(pcStrOrList)
		return IsSortedInAscending(pcStrOrList)

	#>

func IsSortedInDescending(pcStrOrList)
	if IsSortedStringInDescending(pcStrOrList) or IsSortedListInDescending(pcStrOrList)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsSortedDown(pcStrOrList)
		return IsSortedInDescending(pcStrOrList)

	func @IsSortedInDescending(pcStrOrList)
		return IsSortedInDescending(pcStrOrList)

	func @IsSortedDown(pcStrOrList)
		return IsSortedInDescending(pcStrOrList)

	#>

#--

func IsSortedString(pcStr)
	if IsSortedStringInAscending(pcStr) or IsSortedStringInDescending(pcStr)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsStringSorted(pcStr)
		return IsSortedString(pcStr)

	#--

	func @IsSortedString(pcStr)
		return IsSortedString(pcStr)

	func @IsStringSorted(pcStr)
		return IsSortedString(pcStr)

	#>

func IsSortedStringInAscending(pcStr)
	if NOT isString(pcStr)
		return 0
	ok

	return StzStringQ(pcStr).IsSortedInAscending()

	#< @FunctionAlternativeForms

	func IsStringSortedInAscending(pcStr)
		return IsSortedStringInAscending(pcStr)

	#--

	func IsSortedStringUp(pcStr)
		return IsSortedStringInAscending(pcStr)

	func IsSortedUpString(pcStr)
		return IsSortedStringInAscending(pcStr)

	func IsStringSortedUp(pcStr)
		return IsSortedStringInAscending(pcStr)

	#==

	func @IsSortedStringInAscending(pcStr)
		return IsSortedStringInAscending(pcStr)

	func @IsStringSortedInAscending(pcStr)
		return IsSortedStringInAscending(pcStr)

	#--

	func @IsSortedStringUp(pcStr)
		return IsSortedStringInAscending(pcStr)

	func @IsSortedUpString(pcStr)
		return IsSortedStringInAscending(pcStr)

	func @IsStringSortedUp(pcStr)
		return IsSortedStringInAscending(pcStr)

	#>

func IsSortedStringInDescending(pcStr)

	if NOT isString(pcStr)
		return 0
	ok

	return StzStringQ(pcStr).IsSortedInDescending()

	#< @FunctionAlternativeForms

	func IsStringSortedInDescending(pcStr)
		return IsSortedStringInDescending(pcStr)

	#--

	func IsSortedStringDown(pcStr)
		return IsSortedStringInDescending(pcStr)

	func IsSortedDownString(pcStr)
		return IsSortedStringInDescending(pcStr)

	func IsStringSortedDown(pcStr)
		return IsSortedStringInDescending(pcStr)

	#==

	func @IsSortedStringInDescending(pcStr)
		return IsSortedStringInDescending(pcStr)

	func @IsStringSortedInDescending(pcStr)
		return IsSortedStringInDescending(pcStr)

	#--

	func @IsSortedStringDown(pcStr)
		return IsSortedStringInDescending(pcStr)

	func @IsSortedDownString(pcStr)
		return IsSortedStringInDescending(pcStr)

	func @IsStringSortedDown(pcStr)
		return IsSortedStringInDescending(pcStr)

	#>

#===

#TODO: Review if the String...() functions are necessary

func StringAlignXT(cStr, nWidth, cChar, cDirection)
	oString = new stzString(cStr)
	return oString.AlignXTQ(nWidth, cChar, cDirection).Content()
	
	func @AlignXT(cStr, nWidth, cChar, cDirection)
		return StringAlignXT(cStr, nWidth, cChar, cDirection)

	func AlignXT(cStr, nWidth, cChar, cDirection)
		return StringAlignXT(cStr, nWidth, cChar, cDirection)

#--

func StringLeftAlign(cStr, nWidth)
	return StringAlignXT(cStr, nWidth, " ", :Left)

	func StringAlignLeft(cStr, nWidth)
		return StringLeftAlign(cStr, nWidth)

	func LeftAlign(cStr, nWidth)
		return StringLeftAlign(cStr, nWidth)

	func AlignLeft(cStr, nWidth)
		return StringLeftAlign(cStr, nWidth)

	func @LeftAlign(cStr, nWidth)
		return StringLeftAlign(cStr, nWidth)

	func @AlignLeft(cStr, nWidth)
		return StringLeftAlign(cStr, nWidth)

func StringLeftAlignXT(cStr, nWidth, cChar)
	return StringAlignXT(cStr, nWidth, cChar, :Left)

	func StringAlignLeftXT(cStr, nWidth, cChar)
		return StringLeftAlignXT(cStr, nWidth, cChar)

	func LeftAlignXT(cStr, nWidth, cChar)
		return StringLeftAlignXT(cStr, nWidth, cChar)

	func AlignLeftXT(cStr, nWidth, cChar)
		return StringLeftAlignXT(cStr, nWidth, cChar)

	func @LeftAlignXT(cStr, nWidth, cChar)
		return StringLeftAlignXT(cStr, nWidth, cChar)

	func @AlignLeftXT(cStr, nWidth, cChar)
		return StringLeftAlignXT(cStr, nWidth, cChar)

#--

func StringRightAlign(cStr, nWidth)
	return StringAlignXT(cStr, nWidth, " ", :Right)

	func StringAlignRight(cStr, nWidth)
		return StringRightAlign(cStr, nWidth)

	func RightAlign(cStr, nWidth)
		return StringRightAlign(cStr, nWidth)

	func AlignRight(cStr, nWidth)
		return StringRightAlign(cStr, nWidth)

	func @RightAlign(cStr, nWidth)
		return StringRightAlign(cStr, nWidth)

	func @AlignRight(cStr, nWidth)
		return StringRightAlign(cStr, nWidth)

func StringRightAlignXT(cStr, nWidth, cChar)
	return StringAlignXT(cStr, nWidth, cChar, :Right)

	func StringAlignRightXT(cStr, nWidth, cChar)
		return StringRightAlignXT(cStr, nWidth, cChar)

	func RightAlignXT(cStr, nWidth, cChar)
		return StringRightAlignXT(cStr, nWidth, cChar)

	func AlignRightXT(cStr, nWidth, cChar)
		return StringRightAlignXT(cStr, nWidth, cChar)

	func @RightAlignXT(cStr, nWidth, cChar)
		return StringRightAlignXT(cStr, nWidth, cChar)

	func @AlignRightXT(cStr, nWidth, cChar)
		return StringRightAlignXT(cStr, nWidth, cChar)
#--

func StringCenterAlign(cStr, nWidth)
	return StringAlignXT(cStr, nWidth, " ", :Center)

	func StringAlignCenter(cStr, nWidth)
		return StringCenterAlign(cStr, nWidth)

	func CenterAlign(cStr, nWidth)
		return StringCenterAlign(cStr, nWidth)

	func AlignCenter(cStr, nWidth)
		return StringCenterAlign(cStr, nWidth)

	func @CenterAlign(cStr, nWidth)
		return StringCenterAlign(cStr, nWidth)

	func @AlignCenter(cStr, nWidth)
		return StringCenterAlign(cStr, nWidth)

func StringCenterAlignXT(cStr, nWidth, cChar)
	return StringAlignXT(cStr, nWidth, cChar, :Center)

	func StringAlignCenterXT(cStr, nWidth, cChar)
		return StringCenterAlignXT(cStr, nWidth, cChar)

	func CenterAlignXT(cStr, nWidth, cChar)
		return StringCenterAlignXT(cStr, nWidth, cChar)

	func AlignCenterXT(cStr, nWidth, cChar)
		return StringCenterAlignXT(cStr, nWidth, cChar)

	func @CenterAlignXT(cStr, nWidth, cChar)
		return StringCenterAlignXT(cStr, nWidth, cChar)

	func @AlignCenterXT(cStr, nWidth, cChar)
		return StringCenterAlignXT(cStr, nWidth, cChar)
#===

func CountCS(pStrOrList, pSubStrOrItem, pCaseSensitive)
	if isSrtring(pStrOrList)
		return StringCountCS(pStrOrList, pSubStrOrItem, pCaseSensitive)

	but isList(pStrOrList)
		return ListCountCS(pStrOrList, pSubStrOrItem, pCaseSensitive)

	else
		StzRaise("Incorrect param type! pStrOrList must be a string or list.")
	ok

	func StzCountCS(pStrOrList, pSubStrOrItem, pCaseSensitive)
		return CountCS(pStrOrList, pSubStrOrItem, pCaseSensitive)

func Count(pStrOrList, pSubStrOrItem)
	return CountCS(pstrOrList, pSubStrOrItem, 1)

	func StzCount(pStrOrList, pSubStrOrItem)
		return Count(pStrOrList, pSubStrOrItem)

#--

func StringCountCS(pcStr, pcSubStr, pCaseSensitive)
	if CheckingParams()

		if isList(pcSubStr) and IsOfNamedParamList(pcSubStr)
			pcSubStr = pcSubStr[2]
		ok

	ok

	if pcSubStr = ""
		return 0
	ok

	bCase = @CaseSensitive(pCaseSensitive)

	_cTempStr_ = pcStr
	_cSubStr_ = pcSubStr

	if bCase = 0
		_cTempStr_ = ring_lower(_cTempStr_)
		_cSubStr_  = ring_lower(_cSubStr_)
	ok

	# Early check

	n = ring_substr1(_cTempStr_, _cSubStr_)
	if n = 0
		return 0
	ok

	# Removing the substring from the string

	nLenBeforeRemove = len(_cTempStr_)
	_cTempStr2_ = ring_substr2(_cTempStr_, _cSubStr_, "")
	nLenAfterRemove = len(_cTempStr2_)

	nLenSubStr = len(_cSubStr_)
	nResult = ( (nLenBeforeRemove - nLenAfterRemove) / nLenSubStr )

	return nResult

	func StzStringCountCS(pcStr, pcSubStr, pCaseSensitive)
		return StringCountCS(pcStr, pcSubStr, pCaseSensitive)

func StringCount(pcStr, pcSubStr)
	return StringCount(pcStr, pcSubStr, 1)

	func StzStringCount(pcStr, pcSubStr)
		return StringCount(pcStr, pcSubStr)

#--

func StringNumberOfChars(cStr)
	return len(cStr)
	
	func @NumberOfChars(cStr)
		return StringNumberOfChars(cStr)

func StringReverseChars(cStr)
	oString = new stzString(cStr)
	return oString.CharsReversed()
	
	func @ReverseChars(cStr)
		return StringReverseChars(cStr)

func StringIsWord(cStr)
	oString = new stzString(cStr)
	return oString.IsWord()
	
	func @IsWord(cStr)
		return StringIsWord(cStr)

func StringNumberOfOccurrence(pcStr, pcSubStr)
	return StzStringQ(pcStr).NumberOfOccurrence(pcSubStr)
	
	func @NumberOfOccurrence(pcStr, pcSubStr)
		return StringNumberOfOccurrence(pcStr, pcSubStr)

func StringToUnicodes(pcStr)
	return StzStringQ(pcStr).Unicodes()
		
	func @ToUnicodes(pcStr)
		return StringToUnicodes(pcStr)

# Some functions used mainly in natural-code

func UppercaseOf(cStr)
	return upper(cStr)

	func UppercaseIn(cStr)
		return UppercaseOf(cStr)

func LowercaseOf(cStr)
	return lower(cStr)

	func LowercaseIn(cStr)
		return LowercaseOf(cStr)

func FoldcaseOf(cStr)
	return StzStringQ(cStr).Foldcase()

	func FoldcaseIn(cStr)
		return FoldcaseOf(cStr)

func NthCharOf(n, cStr)
	return StzStringQ(cStr)[n]

	func NthCharIn(n, cStr)
		return NthCharOf(n, cStr)

func NthLetterOf(n, cStr)
		aOnlyLetters = StzStringQ(cStr).OnlyLetters()
		return aOnlyLetters[n]

	func NthLetterIn(n, cStr)
		return NthLetterOf(n, cStr)

func StringIsArabicWord(pcStr)
	return StzStringQ(pcStr).IsArabicWord()

func StringIsCharName(pcStr)
	return StzStringQ(pcStr).IsCharName()

# Used for natural-coding

func Text(pcStr)
	#NOTE: In the future, there will be a difference
	# between String and Text
	if isString(pcStr)
		return pcStr
	ok

func NumberOfCharsOf(pcStr)
	return len(pcStr)

	func NumberOfCharsIn(pcStr)
		return NumberOfCharsOf(pcStr)

func BothStringsAreEqualCS(pcStr1, pcStr2, pCaseSensitive)
	_bCase_ = @CaseSensitive(pCaseSensitive)
	if _bCase_ = 1
		return lower(pcStr1) = lower(pcStr2)
	else
		return pcStr1 = pcStr2
	ok

func BothStringsAreEqual(pcStr1, pcStr2)
	return BothStringsAreEqualCS(pcStr1, pcStr2, 1)

func StringsAreEqualCS(pacStr, pCaseSensitive)

	if CheckParams()
		if NOT @IsListOfStrings(pacStr)
			stzRaise("Incorrect param type! pacStr must b a list of strings!")
		ok
	
		if NOT len(pacStr) > 1
			stzRaise("You must provide at least two strings pacStr!")
		ok
	ok

	# Resolving pCaseSensitive

	_bCase_ = @CaseSensitive(pCaseSensitive)

	# Doing the job

	bResult = 1
	nLen = len(pacStr)

	if _bCase_ = 1
		
		cFirstStr = lower(pacStr[1])
		
		for i = 2 to nLen
			if lower(pacStr[i]) != cFirstStr
				bResult = 0
				exit
			ok 
		next

		return bResult
	else

		cFirstStr = pacStr[1]
		
		for i = 1 to nLen
			if pacStr[i] != cFirstStr
				bResult = 0
				exit
			ok
		next

	ok

	return bResult

func StringsAreEqual(paStr)
	return StringsAreEqualCS(paStr, 1)

func RemoveDiacritics(pcStr)
	return StzStringQ(pcStr).DiacriticsRemoved()

func StringCases()
	return [ :Lowercase, :Uppercase, :Capitalcase, :Titlecase, :Foldercase ]

func StringCase(pcStr)

	return StzStringQ(pcStr).StringCase()

func Interpolate(pcStr)
	return Q(pcStr).Interpolated()

	#< @FunctionMisspelledForm

	func Interpoltate(pcStr)
		return Intrepolate(pcStr)

	func Intrepolate(pcStr)
		return Interpolate(pcStr)

	#>

func NCopies(n, p)
	if isList(p) and Q(p).IsFromOrOfNamedParam()
		p = p[2]
	ok

	return Q(p).CopiedNTimes(n)

	func 2Copies(p)
		return NCopies(2, p)
	
	func 3Copies(p)
		return NCopies(3, p)

	func 4Copies(p)
		return NCopies(4, p)

	func 5Copies(p)
		return NCopies(3, p)

func WithoutSpaces(pcStr)
	return ring_substr2(pcStr, " ", "")

	func @WithoutSpaces(pcStr)
		return WithoutSpaces(pcStr)

	#< @FunctionMisspelledForms

	func WithoutSapces(pcStr)
		return WithoutSpaces(pcStr)

	func @WithoutSapces(pcStr)
		return WithoutSpaces(pcStr)

	#>

func WithoutQuotes(cStr)

	cStr = @trim(cStr)
	oStr = new stzString(cStr)

	if oStr.IsBoundedBy('"') or
	   oStr.IsBoundedBy("'")

		oStr.RemoveFirstAndLastChars()
		return oStr.Content()
	ok

	return cStr

	func @WithoutQuotes(cStr)
		return WithoutQuotes(cStr)

func Simplify(pcStr)
	return _StzSimplifyString(pcStr)

	func @Simplify(pcStr)
		return _StzSimplifyString(pcStr)

	func StringSimplified(pcStr)
		return _StzSimplifyString(pcStr)

	func Simplified(pcStr)
		return _StzSimplifyString(pcStr)

func Spacify(str)
	nLen = len(str)
	if nLen < 2 return str ok
	cResult = str[1]
	for i = 2 to nLen
		cResult += " " + str[i]
	next
	return cResult

	func @Spacify(str)
		return Spacify(str)

func SpacifyXT(str, pSep, pStep, pDirection)
	cResult = StzStringQ(str).SpacifyXTQ(pSep, pStep, pDirection).Content()
	return cResult

	func @SpacifyXT(str, pSep, pStep, pDirection)
		return SpacifyXT(str, pSep, pStep, pDirection)

func IsMarquer(cStr)
	if CheckingParams()
		if NOT isString(cStr)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok
	ok

	return Q(cStr).IsMarquer()

	func IsAMarquer(cStr)
		return IsMarquer(cStr)

	func StringIsMarquer(cStr)
		return IsMarquer(cStr)

	func StringIsAMarquer(cStr)
		return IsMarquer(cStr)

	func @IsMarquer(cStr)
		return IsMarquer(cStr)

	func @IsAMarquer(cStr)
		return IsMarquer(cStr)

	func @StringIsMarquer(cStr)
		return IsMarquer(cStr)

	func @StringIsAMarquer(cStr)
		return IsMarquer(cStr)

func RepeatInString(pcSubStr, nTimes)
	if CheckParams()
		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		if NOT isNumber(nTimes)
			StzRaise("incorrect param type! nTimes must be a number.")
		ok
	ok

	#WARING // don't use Ring + concatenation, becuase it shows performance
	# issues with large unciode strings (tested with an arabic string, 1M times)

	cResult = ""
	for i = 1 to nTimes
		cResult += pcSubStr
	next
	return cResult

	#< @FunctionAlternativeForms

	func RepeatInAString(pcSubStr, nTimes)
		return RepeatInString(pcSubStr, nTimes)

	func @RepeatInString(pcSubStr, nTimes)
		return RepeatInString(pcSubStr, nTimes)

	func @RepeatInAString(pcSubStr, nTimes)
		return RepeatInString(pcSubStr, nTimes)

	#>

func BothAreMarquers(pcStr1, pcStr2)
	if BothAreStrings(pcStr1, pcStr2) and
	   Q(pcStr1).IsMarquer() and Q(pcStr2).IsMarquer()

		return 1
	else
		return 0
	ok

	func @BothAreMarquers(pcStr1, pcStr2)
		return BothAreMarquers(pcStr1, pcStr2)

func ring_number(cNumberInStr) #TODO // Move it to stzRingFuncs.ring
	return number(cNumberInStr)

func @Number(pNumberOrString) # An enhanced version of the Ring number() function.

	if isNumber(pNumberOrString)
		return pNumberOrString
	ok

	if isString(pNumberOrString) and pNumberOrString = ""
		return 0
	ok

	if NOT isString(pNumberOrString)
		StzRaise("Incorrect param type! pNumberOrString must be a string.")
	ok

	# Removing spaces and underscores (because we use them in numbers)

	cNumberInStr = ring_substr2(pNumberOrString, " ", "")
	cNumberInStr = ring_substr2(cNumberInStr, "_", "")

	if cNumberInStr = ""
		StzRaise("Incorrect param value! pNumberOrString must contain a number.")
	ok

	# Now, it is safe ti use the Ring Number() function

	try
		_nResult_ = ring_number(cNumberInStr)
		return _nResult_
	catch
		stzRaise("Can't proceed! pNumberOrString contains a literal not a number in string.")
	done

func IsNumberInString(str)
	if NOT isString(str)
		return FALSE
	ok

	return rx(pat(:number)).Match(str) # Regex-base, more performant then:

	func @IsNumberInstring(str)
		return IsNumberInString(str)

func IsIntegerInString(str)
	return StzStringQ(str).IsIntegerInString()

	func @IsIntegerInstring(str)
		return IsIntegerInString(str)

func IsNumberOrListInString(str)
	return StzStringQ(str).IsNumberOrListInString()

	func IsStringOrNumberInString(str)
		return IsNumberOrListInString(str)

	func @IsNumberOrListInString(str)
		return IsNumberOrListInString(str)

	func @IsStringOrNumberInString(str)
		return IsNumberOrListInString(str)

func IsRealInString(str)
	return StzStringQ(str).IsRealInString()

	func @IsRealInstring(str)
		return IsRealInString(str)

func @IsPalindrome(p)
	if isList(p)
		if len(p) < 2
			return 0
		ok

		return StzListQ(p).IsPalindrome()

	but isString(p)
		nLen = len(p)
		if nLen < 2
			return 0
		ok
		cLow = lower(p)
		for i = 1 to nLen / 2
			if substr(cLow, i, 1) != substr(cLow, nLen - i + 1, 1)
				return 0
			ok
		next
		return 1
	else
		StzRaise("Incorrect param type! p must be a string or list.")
	ok

	def IsPalindrom(p)
		return @IsPalindrome(p)

	func @IsPalindrom(p)
		return @IsPalindrome(p)

	func IsMirrored(p)
		return @IsPalindrome(p)

	func @IsMirrored(p)
		return @IsPalindrome(p)

func @IsPunct(p)
	if isString(p)
		nLen = len(p)
		if nLen = 0 return 0 ok
		for i = 1 to nLen
			n = ascii(substr(p, i, 1))
			if (n >= 33 and n <= 47) or (n >= 58 and n <= 64) or (n >= 91 and n <= 96) or (n >= 123 and n <= 126)
				# ok, is punctuation
			else
				return 0
			ok
		next
		return 1

	but isList(p) and @IsListOfChars(p)
		#TODO
	else
		StzRaise("Incorrect param type! p must be a string or list of chars.")
	ok

#--

func MarquerChar()
	return _cMarquerChar

	func DefaultMarquerChar()
		return _cMarquerChar

	func @MarquerChar()
		return _cMarquerChar

	func Marquer()
		return _cMarquerChar

	func @Marquer()
		return _cMarquerChar

func SetMarquerChar(c)
	if NOT (isString(c) and IsChar(c))
		StzRaise("Incorrect param type! c must be a char.")
	ok

	_cMarquerChar = c

	#NOTE // A marquer char can be set at the global level or string object level

	func SetDefaultMarquerChar()
		_cMarquerChar = c

	func @SetMarquerChar()
		_cMarquerChar = c

	func SetMarquer()
		_cMarquerChar = c

	func @SetMarquer()
		_cMarquerChar = c

func SplitAtCS(cData, cSubStr, pCaseSensitive)
	if NOT (isString(cData) and isString(cSubStr))
		StzRaise("Incorrect param type! cData and cSubStr must both be strings.")
	ok

	bCase = CaseSensitive(pCaseSensitive)
	return StzSplitCS(cData, cSubStr, bCase)

	func @SplitAtCS(cData, cSubStr, pCaseSensitive)
		return SplitAtCS(cData, cSubStr, pCaseSensitive)

	func SplitCS(cData, cSubStr, pCaseSensitive)
		return SplitAtCS(cData, cSubStr, pCaseSensitive)

	func @SplitCS(cData, cSubStr, pCaseSensitive)
		return SplitAtCS(cData, cSubStr, pCaseSensitive)


func @SplitAt(cData, cSubStr)
	if NOT (isString(cData) and isString(cSubStr))
		StzRaise("Incorrect param type! cData and cSubStr must both be strings.")
	ok

	return StzSplitCS(cData, cSubStr, 0)

	func SplitAt(cData, cSubStr)
		return @SplitAt(cData, cSubStr)

	func @Split(cData, cSubStr)
		return @SplitAt(cData, cSubStr)

func IsFileName(pcStr)
	if NOT isString(pcStr)
		return FALSE
	ok

	return Rx(pat(:fileName)).Match(pcStr)

	
func IsCsvFileName(pcStr)

	if NOT isString(pcStr)
		return FALSE
	ok

	if NOT Rx(pat(:fileName)).Match(pcStr)
		return FALSE
	ok

	if lower( @split(pcStr, ".")[2] ) = "csv"
		return TRUE
	else
		return FALSE
	ok

func IsHtmlFileName(pcStr)
	if NOT isString(pcStr)
		return FALSE
	ok

	if NOT isString(pcStr)
		return FALSE
	ok

	if NOT Rx(pat(:fileName)).Match(pcStr)
		return FALSE
	ok

	cExtension = lower( @split(pcStr, ".")[2] )

	if cExtension = "html" or cExtension = "htm"
		return TRUE
	else
		return FALSE
	ok

func IsCsvString(pcStr)
	if NOT isString(pcStr)
		return FALSE
	ok

	return StzStringQ(pcStr).IsCSV()

func IsHtmlTableString(pcStr)

	if NOT isString(pcStr)
		return FALSE
	ok

	return StzStringQ(pcStr).IsHtmlTable()



func Boxify(str)
	oTempStr = new stzString(str)
	oTempStr.Boxify()
	return otempStr.Content()

	func Box(str)
		return Boxify(str)

	func @Boxify(str)
		return Boxify(str)

	func @Box(str)
		return Boxify(str)


func BoxifyRound(str)
	oTempStr = new stzString(str)
	oTempStr.BoxifyRound()
	return otempStr.Content()

	#< @FunctionAlternativeForms

	func BoxRound(str)
		return BoxifyRound(str)

	func BoxRounded(str)
		return BoxifyRound(str)

	func BoxedRound(str)
		return BoxifyRound(str)

	func BoxedRounded(str)
		return BoxifyRound(str)

	func BoxifiedRound(str)
		return BoxifyRound(str)

	func BoxifiedRounded(str)
		return BoxifyRound(str)

	#--

	func @BoxifyRound(str)
		return BoxifyRound(str)

	func @BoxRound(str)
		return BoxifyRound(str)

	func @BoxRounded(str)
		return BoxifyRound(str)

	func @BoxedRound(str)
		return BoxifyRound(str)

	func @BoxedRounded(str)
		return BoxifyRound(str)

	func @BoxifiedRound(str)
		return BoxifyRound(str)

	func @BoxifiedRounded(str)
		return BoxifyRound(str)

	#--

	func RoundBox(str)
		return BoxifyRound(str)

	func RoundedBox(str)
		return BoxifyRound(str)

	func RoundedBoxed(str)
		return BoxifyRound(str)

	func RoundBoxed(str)
		return BoxifyRound(str)

	func @RoundBox(str)
		return BoxifyRound(str)

	func @RoundedBox(str)
		return BoxifyRound(str)

	func @RoundedBoxed(str)
		return BoxifyRound(str)

	func @RoundBoxed(str)
		return BoxifyRound(str)
	
	#>

func BoxifyDash(str)
	oTempStr = new stzString(str)
	oTempStr.BoxifyDash()
	return otempStr.Content()

	#< @FunctionAlternativeForms

	func BoxDash(str)
		return BoxifyDash(str)

	func BoxDashed(str)
		return BoxifyDash(str)

	func BoxedDash(str)
		return BoxifyDash(str)

	func BoxedDashed(str)
		return BoxifyDash(str)

	func BoxifiedDash(str)
		return BoxifyDash(str)

	func BoxifiedDashed(str)
		return BoxifyDash(str)

	#--

	func @BoxifyDash(str)
		return BoxifyDash(str)

	func @BoxDash(str)
		return BoxifyDash(str)

	func @BoxDashed(str)
		return BoxifyDash(str)

	func @BoxedDash(str)
		return BoxifyDash(str)

	func @BoxedDashed(str)
		return BoxifyDash(str)

	func @BoxifiedDash(str)
		return BoxifyDash(str)

	func @BoxifiedDashed(str)
		return BoxifyDash(str)

	#>

func BoxDashRound(str)
	oTempStr = new stzString(str)
	oTempStr.BoxifyDashRound()
	return oTempStr.Content()

	func @BoxDashRound(str)
		return BoxDashRound(str)

func BoxChars(str)

	_oTempStr_ = new stzString(str)
	_oTempStr_.BoxEachChar()
	return _oTempStr_.Content()

	#< @FunctionAlternativeForms

	func BoxedChars(str)
		return BoxChars(str)

	#--

	func @BoxChars(str)
		return BoxChars(str)

	func @BoxedChars(str)
		return BoxChars(str)

	#>

func BoxRoundChars(str)

	_oTempStr_ = new stzString(str)
	_oTempStr_.BoxRoundEachChar()
	return _oTempStr_.Content()

	#< @FunctionAlternativeForms

	func BoxRoundedChars(str)
		return BoxRoundChars(str)

	func BoxedRoundChars(str)
		return BoxRoundChars(str)

	func BoxedRoundedChars(str)
		return BoxRoundChars(str)

	#--

	func @BoxRoundChars(str)
		return BoxRoundChars(str)

	func @BoxRoundedChars(str)
		return BoxRoundChars(str)

	func @BoxedRoundChars(str)
		return BoxRoundChars(str)

	func @BoxedRoundedChars(str)
		return BoxRoundChars(str)

	#>


func BoxDashChars(str)

	_oTempStr_ = new stzString(str)
	_oTempStr_.BoxDashEachChar()
	return _oTempStr_.Content()

	#< @FunctionAlternativeForms

	func BoxedDashChars(str)
		return BoxDashChars(str)

	func BoxedDashedChars(str)
		return BoxDashChars(str)

	func BoxDashedChars(str)
		return BoxDashChars(str)

	#--

	func @BoxDashChars(str)
		return BoxDashChars(str)

	func @BoxedDashChars(str)
		return BoxDashChars(str)

	func @BoxedDashedChars(str)
		return BoxDashChars(str)

	func @BoxDashedChars(str)
		return BoxDashChars(str)

	#>

func BoxRoundDashChars(str)

	_oTempStr_ = new stzString(str)
	_oTempStr_.BoxRoundDashEachChar()
	return _oTempStr_.Content()

	#< @FunctionAlternativeForms

	func BoxedRoundDashChars(str)
		return BoxRoundDashChars(str)

	func BoxedRoundedDashedChars(str)
		return BoxRoundDashChars(str)

	func BoxRoundDashedChars(str)
		return BoxRoundDashChars(str)

	#--

	func @BoxRoundDashChars(str)
		return BoxRoundDashChars(str)

	func @BoxedRoundDashChars(str)
		return BoxRoundDashChars(str)

	func @BoxedRoundedDashedChars(str)
		return BoxRoundDashChars(str)

	func @BoxRoundDashedChars(str)
		return BoxRoundDashChars(str)

	#>

func @substr(str, p1, p2) #TODO // Move to stzExtCode

	if isNumber(p1) and isNumber(p2)
		return StringSection(str, p1, p2)

	but isString(p1) and isNumber(p2)

		nLen = len(str)

		cStrRight = right(str, nLen-p2+1)
		nResult = ring_substr1(cStrRight, p1) + p2 - 1

		return nResult

	but isString(p1) and ( (isList(p2) and len(p2)=0) or (isNumber(p2) and p2 = 0) )
		return substr(str, p1)

	else

		return substr(str, p1, p2)
	ok

func substrXT(paParams)
	if NOt isList(paParams)
		StzRaise("Incorrect param type! paParams must be a list.")
	ok

	nLen = len(paParams)
	if nLen < 2 or nLen > 3
		StzRaise("Incorrect param! paParams list size must be 2, or 3.")
	ok

	if NOT isString(paParams[1])
		StzRaise("Incorrect param value! The first item in the paParams list must be a string.")
	ok

	if nLen = 2
		 cType = type(paParams[2])
		if cType = "STRING"
			return ring_substr1(paParams[1], paParams[2])

		else
			StzRaise("Unsupported format of the @substrXT() function.")
		ok

	else // nLen = 3
		if isNumber(paParams[2]) and isNumber(paParams[3])
			return StringSection(paParams[1], paParams[2], paParams[3])

		but isString(paParams[2]) and isString(paParams[3])
			return ring_substr2(paParams[1], paParams[2], paParams[3])

		but isString(paParams[2]) and isNumber(paParams[3])
			return @substr(paParams[1], paParams[2], paParams[3])

		else
			StzRaise("Unsupported format of the @substrXT() function.")
		ok
	ok

	func @substrXT(paParams)
		return substrXT(paParams)

func StringSection(str, n1, n2)
	if CheckParams()
		if NOT isString(str)
			StzRaise("Incorrect param type! str must be a string.")
		ok

		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("Incorrect param type! Both n1 and n2 must be numbers.")
		ok
	ok

	return substr(str, n1, (n2 - n1 + 1))

func stzleft(str, n)
	if isList(str)
		return ListSection(str, 1, n)
	ok

	return StringSection(str, 1, n)

func stzRight(str, n)
	if isList(str)
		nLen = len(str)
		return ListSection(str, nLen+1-n, n)
	ok

	nLen = len(str)
	return StringSection(str, nLen-n+1, nLen)


func Chars(str)
	if isList(str) and len(str) = 2 and isString(str[1]) and str[1] = :In
		str = str[2]
	ok

	nLen = len(str)
	acResult = []

	for i = 1 to nLen
		acResult + substr(str, i, 1)
	next

	return acResult

	func @Chars(str)
		return Chars(str)


func _StrContainsCS(cStr, cSubStr, bCaseSensitive)
	if bCaseSensitive = 1
		return substr(cStr, cSubStr) > 0
	ok
	return substr(lower(cStr), lower(cSubStr)) > 0

func Lines(str)
	acResult = @split(str, NL)
	return acResult

	func @Lines(str)
		return Lines(str)
		
func IsLatin(p)

	if IsChar(p)
		return StzCharQ(p).IsLatin()

	but isString(p)
		return StzStringQ(p).IsLatin()

	but IsListOfChars(p)
		return StzListOfCharsQ(p).IsLatin()

	but IsListOfStrings(p)
		return StzListOfStringsQ(p).IsLatin()

	else
		StzRaise("Unsupported param type!")
	ok

	func @IsLatin(p)
		return IsLatin(p)

#--

  //////////////////////////////////////////////
 ///   Q-CONSTRUCTORS FOR MODULAR CLASSES   ///
//////////////////////////////////////////////

func StzStringXTQ(str)
	return new stzStringXT(str)

func StzStringFinderQ(str)
	return new stzStringFinder(str)

func StzStringFinderXTQ(str)
	return new stzStringFinderXT(str)

func StzStringReplacerQ(str)
	return new stzStringReplacer(str)

func StzStringReplacerXTQ(str)
	return new stzStringReplacerXT(str)

func StzStringSplitterQ(str)
	return new stzStringSplitter(str)

func StzStringSplitterXTQ(str)
	return new stzStringSplitterXT(str)

func StzStringBounderQ(str)
	return new stzStringBounder(str)

func StzStringBounderXTQ(str)
	return new stzStringBounderXT(str)

func StzStringCheckerQ(str)
	return new stzStringChecker(str)

func StzStringCheckerXTQ(str)
	return new stzStringCheckerXT(str)

func StzStringFormatterQ(str)
	return new stzStringFormatter(str)

func StzStringFormatterXTQ(str)
	return new stzStringFormatterXT(str)

func StzStringWalkerQ(str)
	return new stzStringWalker(str)

func StzStringWalkerXTQ(str)
	return new stzStringWalkerXT(str)

func StzStringVisualizerQ(str)
	return new stzStringVisualizer(str)

func StzStringVisualizerXTQ(str)
	return new stzStringVisualizerXT(str)

func StzStringLinesQ(str)
	return new stzStringLines(str)

func StzStringWordsQ(str)
	return new stzStringWords(str)

func StzStringEncoderQ(str)
	return new stzStringEncoder(str)

func StzStringNumbersQ(str)
	return new stzStringNumbers(str)

func StzStringDuplicatesQ(str)
	return new stzStringDuplicates(str)

func StzStringCodeQ(str)
	return new stzStringCode(str)

func StzStringIOQ(str)
	return new stzStringIO(str)

func StzStringRandomizerQ(str)
	return new stzStringRandomizer(str)

func StzStringLocaleQ(str)
	return new stzStringLocale(str)

func StzStringCryptoQ(str)
	return new stzStringCrypto(str)

func StzStringViewQ(str)
	return new stzStringView(str)

func StzStringWordsXTQ(str)
	return new stzStringWordsXT(str)

func StzStringDuplicatesXTQ(str)
	return new stzStringDuplicatesXT(str)

func StzStringCodeXTQ(str)
	return new stzStringCodeXT(str)

func StzStringIOXTQ(str)
	return new stzStringIOXT(str)

func StzStringRandomizerXTQ(str)
	return new stzStringRandomizerXT(str)

func StzStringLocaleXTQ(str)
	return new stzStringLocaleXT(str)

func StzStringCryptoXTQ(str)
	return new stzStringCryptoXT(str)

# Phase 2 Q-constructors (new subclass pairs)

func StzStringRemoverQ(str)
	return new stzStringRemover(str)

func StzStringRemoverXTQ(str)
	return new stzStringRemoverXT(str)

func StzStringInserterQ(str)
	return new stzStringInserter(str)

func StzStringInserterXTQ(str)
	return new stzStringInserterXT(str)

func StzStringCounterQ(str)
	return new stzStringCounter(str)

func StzStringCounterXTQ(str)
	return new stzStringCounterXT(str)

func StzStringSectionsQ(str)
	return new stzStringSections(str)

func StzStringSectionsXTQ(str)
	return new stzStringSectionsXT(str)

func StzStringGetterQ(str)
	return new stzStringGetter(str)

func StzStringGetterXTQ(str)
	return new stzStringGetterXT(str)

func StzStringExtractorQ(str)
	return new stzStringExtractor(str)

func StzStringExtractorXTQ(str)
	return new stzStringExtractorXT(str)

func StzStringTrimmerQ(str)
	return new stzStringTrimmer(str)

func StzStringTrimmerXTQ(str)
	return new stzStringTrimmerXT(str)

func StzStringComparatorQ(str)
	return new stzStringComparator(str)

func StzStringComparatorXTQ(str)
	return new stzStringComparatorXT(str)

func StzStringLeadTrailQ(str)
	return new stzStringLeadTrail(str)

func StzStringLeadTrailXTQ(str)
	return new stzStringLeadTrailXT(str)

func StzStringPerformerQ(str)
	return new stzStringPerformer(str)

func StzStringPerformerXTQ(str)
	return new stzStringPerformerXT(str)

func StzStringConcatQ(str)
	return new stzStringConcat(str)

func StzStringConcatXTQ(str)
	return new stzStringConcatXT(str)

func StzStringCaseChangerQ(str)
	return new stzStringCaseChanger(str)

func StzStringCaseChangerXTQ(str)
	return new stzStringCaseChangerXT(str)

func StzStringAlignerQ(str)
	return new stzStringAligner(str)

func StzStringAlignerXTQ(str)
	return new stzStringAlignerXT(str)


  ///////////////////////////////////
 ///   LEGACY UTILITY FUNCTIONS  ///
///////////////////////////////////

func @Section(pStrOrList, n1, n2) #TODO // Review the naming of Section() in stzSection

	if CheckParams()
		if NOT (isString(pStrOrList) or isList(pStrOrList))
			StzRaise("Incorrect param type! pStrOrList must be a string or list.")
		ok

		if NOT (isNumber(n1) and isNumber(n2))
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok
	ok

	aItems = []

	if isList(pStrOrList)
		if len(pStrOrList) = 0
			StzRaise("Can't get a section from an empty list!")
		ok

		aItems = pStrOrList

	else
		if pStrOrList = ""
			StzRaise("Can't get a section from an empty string!")
		ok

		aItems = Chars(pStrOrList)
	ok

	nLen = len(aItems)

	if n1 < 1 or n1 > nLen
		StzRaise("Index out of range! n1 must be between 1 and " + nLen + "!")
	ok

	if n2 < 1 or n2 > nLen
		StzRaise("Index out of range! n1 must be between 1 and " + nLen + "!")
	ok

	if n2 < n1
		nTemp = n2
		n2 = n1
		n1 = nTemp
	ok

	if isList(pStrOrList)

		aResult = []
	
		for i = n1 to n2
			aResult + aItems[i]
		next

		return aResult

	else
		cResult = ""

		for i = n1 to n2
			cResult += aItems[i]
		next

		return cResult
	ok

	

//func @Range(pStrOrList, nStart, nRange) #TODO //Review the naming of Range in stzExtinPyhton


