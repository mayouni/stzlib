# 		    SOFTANZA LIBRARY (V1.0) - STZSTRING			    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The core class for managing Unicode strings       #
#	Version		: V1.0 (2020-2022)				    #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#---------------------------------------------------------------------------#

/*
	TODO Add:
	QStringRef methods
*/

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzStringQ(str)
	return new stzString(str)
	
func IsNotString(pcStr)
	return NOT isString(pcStr)
	
func IsNullString(cStr)
	if isString(cStr) and cStr != NULL
		return TRUE
	else
		return FALSE
	ok

	func IsEmptyString(cStr)
		return IsNullString(cStr)

func IsNonNullString(cStr)
	return NOT IsNullString(cStr)

	func IsNonEmptyString(cStr)
		return This.IsNonNullString(cStr)

	func IsFullString(cStr)
		return This.IsNonNullString(cStr)

func StringToQString(cStr)
	oStr = new stzString(cStr)
	return oStr.QStringObject()
	
func IsQString(p)
	if isObject(p) and classname(p) = "qstring"
		return TRUE
	else
		return FALSE
	ok
	
func QStringContent(oQStr)
	return QStringToString(oQStr)
	
func QStringToString(oQStr)
	if IsQString(oQStr)
		return oQStr.left(oQStr.count())
	else
		stzRaise(stzStringError(:CanNotTransformQStringToString))
	ok
	
func QStringToStzString(oQString)
	return new stzString(QStringToString(oQString))
	
func StringIsEmpty(pcStr)
	return pcStr = ""

func StringIsNull(pcStr)
	return pcStr = ""

func StzStringToQString(oStr)
	return oStr.QStringObject()
	
func StringIsLocaleAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLocaleAbbreviation()
	
func StringIsLanguageAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLanguageAbbreviation()
	
func StringIsShortLanguageAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsShortLanguageAbbreviation()
	
func StringIsLongLanguageAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLongLanguageAbbreviation()
	
func StringIsLanguageName(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLanguageName()
	
func StringIsLanguageNumber(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLanguageNumber()
	
func StringIsCountryAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsCountryAbbreviation()
	
func StringIsCountryName(cStr)
	oStr = new stzString(cStr)
	return oStr.IsCountryName()
	
func StringIsCountryNumber(cStr)
	oStr = new stzString(cStr)
	return oStr.IsCountryNumber()
	
func StringIsShortCountryAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsShortCountryAbbreviation()
	
func StringIsLongCountryAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsLongCountryAbbreviation()
	
func StringIsScriptAbbreviation(cStr)
	oStr = new stzString(cStr)
	return oStr.IsScriptAbbreviation()
	
func StringIsScriptName(cStr)
	oStr = new stzString(cStr)
	return oStr.IsScriptName()
	
func StringIsScriptNumber(cStr)
	oStr = new stzString(cStr)
	return oStr.IsScriptNumber()
	
func StringIsLowercase(cStr)
	return StzStringQ(cStr).IsLowercase()

func StringIsUppercase(cStr)
	return StzStringQ(cStr).IsUppercase()

func StringLowercased(cStr)
	oStr = new stzString(cStr)
	return oStr.Lowercased()
	
	func StringLowercase(cStr)
		return StringLowercased(cStr)

func StringUppercased(cStr)
	oStr = new stzString(cStr)
	return oStr.Uppercased()
	
	func StringUppercase(cStr)
		return StringUppercased(cStr)
	
func StringTitlecased(cStr)
	oStr = new stzString(cStr)
	return oStr.Titlecased()
	
	func StringTitlecase(cStr)
		return StringTitlecased(cStr)

	func Titlecase(cStr)
		return StringTitlecased(cStr)

	func Titlecased(cStr)
		return StringTitlecased(cStr)

	
func StringAlign(cString, nWidth, cChar, cDirection)
	oString = new stzString(cString)
	return oString.AlignQ(nWidth, cChar, cDirection).Content()
	
func StringLeftAlign(cString, nWidth, cChar)
	return StringAlign(cString, nWidth, cChar, :Left)
	
func StringRightAlign(cString, nWidth, cChar)
	return StringAlign(cString, nWidth, cChar, :Right)
	
func StringCenterAlign(cString, nWidth, cChar)
	return StringAlign(cString, nWidth, cChar, :Center)
	
func StringRepeat(cString, n)
	oString = new stzString(cString)
	return oString.RepeatNTimesQ(n).Content()
	
func StringNumberOfChars(cStr)
	oString = new stzString(cStr)
	return oString.NumberOfChars()
	
func StringReverseChars(cStr)
	oString = new stzString(cStr)
	return oString.CharsReversed()
	
func StringIsWord(cStr)
	oString = new stzString(cStr)
	return oString.IsWord()
	
func StringContains(pcStr, pcSubStr)
	return StzStringQ(pcStr).Contains(pcSubStr)
	
func StringNumberOfOccurrence(pcStr, pcSubStr)
	return StzStringQ(pcStr).NumberOfOccurrence(pcSubStr)
	
func StringToUnicodes(pcStr)
	return StzStringQ(pcStr).Unicodes()
	
	func StringUnicodes(pcStr)
		return StringToUnicodes(pcStr)
	
func StringInvert(cStr)
	return StzStringQ(cStr).Inverted()
	
func StringScript(cStr)
	return StzStringQ(cStr).Script()

# Some functions used mainly in natural-code

func UppercaseOf(cStr)
	return StzStringQ(cStr).Uppercased()

	func UppercaseIn(cStr)
		return UppercaseOf(cStr)

func LowercaseOf(cStr)
	return StzStringQ(cStr).Lowercased()

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

func String(pcStr)
	if isString(pcStr)
		return pcStr
	ok

func Text(pcStr)
	# NOTE: In the future, there will be a difference
	# between String and Text
	if isString(pcStr)
		return pcStr
	ok

func Word(pcStr)
	if StringIsWord(pcStr)
		return pcStr
	ok

func String@(pcStr)
	if isString(pcStr)
		return ComputableForm(pcStr)
	ok

func NumberOfCharsOf(pcStr)
	return StzStringQ(pcStr).NumberOfChars()

	func NumberOfCharsIn(pcStr)
		return NumberOfCharsOf(pcStr)

func BothStringsAreEqualCS(pcStr1, pcStr2, pCaseSensitive)
	return StringsAreEqualCS( [ pcStr1, pcStr2 ], pCaseSensitive )

func BothStringsAreEqual(pcStr1, pcStr2)
	return BothStringsAreEqualCS(pcStr1, pcStr2, :CaseSensitive = TRUE)

func StringsAreEqualCS(paStrings, pCaseSensitive)
	if NOT ListIsListOfStrings(paStrings)
		stzRaise("You must provide a list of strings!")
	ok

	if NOT len(paStrings) > 1
		stzRaise("You must provide at least two strings in the list!")
	ok

	if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
		pCaseSensitive = pCaseSensitive[2]
	ok

	bResult = TRUE

	if pCaseSensitive = TRUE
		
		cFirstStr = StzStringQ(paStrings[1]).Lowercased()

		for i = 2 to len(paStrings)
			if StzStringQ(paStrings[i]).Lowercased() != cFirstStr
				bResult = FALSE
				exit
			ok 
		next

		return bResult
	else

		cFirstStr = paStrings[1]

		for i = 1 to len(paStrings)
			if paStrings[i] != cFirstStr
				bResult = FALSE
				exit
			ok
		next

	ok

	return bResult

func StringsAreEqual(paStrings)
	return StringsAreEqualCS(paStrings, :CaseSensitive = TRUE)

func RemoveDiacritics(pcStr)
	return StzStringQ(pcStr).DiacriticsRemoved()

func StringCases()
	return [ :Lowercase, :Uppercase, :Capitalcase, :Titlecase, :Foldercase ]

func StringCase(pcStr)

	return StzStringQ(pcStr).StringCase()


  /////////////////
 ///   CLASS   ///
/////////////////

class stzString from stzObject

	@oQString
	@@aConstraints = []

	@cLanguage = :English	# Set explicitly using SetLanguage()
				# TODO (future): Infere the language from the string

	// Initializes the content of the softanza string object
	def init(pcStr)

		@oQString = new QString2()
		@oQString.append(pcStr)

	  #--------------------------#
	 #   CHECKING CONSTRAINTS   #
	#--------------------------#
	
	# TODO: Generalize this feature to other classes

	def EnforcedConstraints()
		return @@aConstraints

		def Constraints()
			return This.EnforcedConstraints()

	def VerifyConstraint(pcConstraintName)

		@str = This.Content()

		cCondition = Constraints()[ :OnStzString ][ pcConstraintName ]

		if cCondition = NULL
			stzRaise("Inexsitant contraint!")
		ok

		CompileConstraint(cCondition)

		StzStringQ(cCondition) {

			ReplaceCS("@string", :With = @str, :CS = FALSE)
			Simplify()
			RemoveBounds("{", "}")

			cCondition = Content()
		}

		cCode  = 'bResult = ""+ (' + cCondition + ')'
		eval(cCode)

		if bResult = FALSE
			stzRaise([
				:Where = "stzString.ring > VerifyCondition()",
				:What  = "Execution is cancelled by Softanza",
				:Why   = "A constraint on the string object is not verified!",
				:Todo  = "Check that constraint (" + pcName + ") and adjust your logic accordingly ;)"

			])
		ok

	def VerifyConstraints()
		bResult = TRUE

		for aPair in This.Constraints()
			cConstraintName = aPair[1]
			This.VerifyConstraint(cConstraintName) = FALSE
			
		next

	  #-------------------------------#
	 #     APPENDING & PEPENDING     #
	#-------------------------------#

	// Appends the main string by an other string
	def Append(pcOtherStr)
		cResult = This.String() + pcOtherStr
		This.Update( cResult )

		#< @FunctionFluentForm

		def AppendQ(pcOtherStr)
			This.Append(pcOtherStr)
			return This
	
		#>

	// Prepends the string by an other string
	def Prepend(pcOtherStr)
		cResult = pcOtherStr + This.String()
		This.Update( cResult )

		#< @FunctionFluentForm

		def PrependQ(pcOtherStr)
			This.Prepend(pcOtherStr)
			return This
	
		#>

	  #---------------------------------------#
	 #     GETTING CONTENT OF THE STRING     #
	#---------------------------------------#

	// Returns the string's content
	def Content()
		return @oQString.left( @oQString.count() )

		#< @FunctionFluentForm

		def ContentQ()
			return This

		#>
	
	def QStringObject()
		return @oQString

	def String()
		return This.Content()

		#< @FunctionFluentForm

		def StringQ()
			return This
	
		#>

	  #---------------------------------------------#
	 #     GETTING A COPY OF THE STRING OBJECT     #
	#---------------------------------------------#

	def Copy()

		# t0 = clock()

		oCopy = new stzString( This.String() )

		# ? ( clock() - t0 ) / clockspersecond()

		return oCopy

	def ReversedCopy()
		return This.ReverseQ()

	  #-------------------------------#
	 #     CASE OF THE STRING        #
	#-------------------------------#

	def StringCase()

		if This.IsLowercase()
? "ici 1"
			return :Lowercase

		but This.IsUppercase()
? "ici 2"
			return :Uppercase

		but This.IsCapitalcase()
? "ici 3"
			return :Capitalcase

		but This.IsTitlecase()
? "ici 4"
			return :Titlecase

		but This.IsFoldercase()
? "ici 5"
			return :Foldercase

		else
? "ici 6"
			return :Hybridcase
		ok

	def CharCase()
		if This.NumberOfChars() = 1
			return This.StringCase()
		ok

	def IsHybridcase()
		return _@( This.StringCase() ).IsNotOneOfThese([ StringCases() ])

		def IsHybridCased()
			return This.IsHybridcase()

	  #-------------------------------#
	 #     LOWERCASING THE STRING    #
	#-------------------------------#

	// Transforms the string to lowercase
	def ApplyLowercase() # Understand it as a verb, an action on main string!
		oLocale = ActiveLocale()
		This.Update( oLocale.StringLowercased(This.String()) )

		#< @FunctionFluentForm

	 	// Transforms the string to lowercase AND Returns the lowercased
		// stzString object to take other actions on it!
		def ApplyLowercaseQ() # Q for Queue -> a chain of actions
			This.ApplyLowercase()
			return This

		#>

		#< @FunctionAlternativeForm	// TODO: replace with @FunctionAlternativeFormForm

		def Lowercase() # Understand it as a verb that "lowercases" the string
			This.ApplyLowercase()

			def LowercaseQ()
				This.Lowercase()
				return This
	
		#>

	// Tranforms the string to LOCALE-SENSITIVE lowercase
	def ApplyLowercaseInLocale(pcLocale)
		/*
		Apply the special cases documented in unicode here:
		--> http://unicode.org/Public/UNIDATA/SpecialCasing.txt

		*/

		oLocale = new stzLocale(pcLocale)
		This.Update( oLocale.ToLowercase(This.String()) )

		#< @FunctionFluentForm

		def ApplyLowercaseInLocaleQ(pcLocale)
			This.ApplyLowercaseInLocale(pcLocale)
			return This
	
		#>

		#< @FunctionAlternativeForm	// TODO: replace with @FunctionAlternativeFormForm

		def LowercaseInLocale(pLocale) # Understand it as a verb that "lowercases" the string in the givan locale
			This.ApplyLowercaseInLocale(pLocale)

			def LowercaseInLocaleQ(pLocale)
				This.LowercaseInLocale(pLocale)
				return This
	
		#>

	def Lowercased()
		oLocale = ActiveLocale()
		return oLocale.toLowercase( This.String() )
			
	def LowercasedInLocale(pcLocale)
		oLocale = new stzLocale(pcLocale)
		return oLocale.ToLowercase(This.String())

		#< @FunctionFluentForm

		def LowercasedInLocaleQ(pLocale)
			return new stzString( This.LowercasedInLocale(pLocale) )

		#>

	def IsLowercase()
		return ActiveLocale().StringLowercased(This.String()) = This.String()

		#< @FunctionAlternativeForm

		def IsLowercased()
			return This.IsLowercase()

		def AllLettersAreLowercase()
			return This.IsLowercase()

		def AllLettersAreLowercased()
			return This.IsLowercase()
	
		#>

		#< @FunctionNegationForm

		def IsNotLowercase()
			return NOT This.IsLowercase()

		def IsNotLowercased()
			return This.IsNotLowercase()
		#>

		#< @FunctionAdditionForm

		def IsAlsoLowercase()
			return This.IsLowercase()

			def IsAlsoLowercased()
				return This.IsAlsoLowercase()

		#>

	def IsLowercaseInLocale(pLocale)
		return StzLocaleQ(pLocale).StringLowercased(This.String()) = This.String() # TODO: replace with DefaultLocale

	def IsLowercaseOf(pcStr)
		return StzStringQ(pcStr).Lowercased() = This.String()

	def IsLowercaseOfXT(pcStr, paLocale)
		/* Example
		_("many").IsLowercaseOfXT("MANY", :InThisLocale = "fr_FR")
		*/
	
		if NOT ( isList(paLocale) and len(paLocale) = 2 )
			stzRaise("Incorrect format!")
		ok
	
		if NOT isString(paLocale[1])
			stzRaise("Incorrect format!")
		ok
	
		if NOT ( _(paLocale[1]).Q.IsOneOfThese([ :InThisLocale, :InLocale ]) )
			stzRaise("Incorrect format!")
		ok
	
		if NOT ( isString(paLocale[2]) or (isList([paLocale[2]]) and len(paLocale[2]) = 2) )
			stzRaise("Incorrect format!")
		ok
	
		if isString(paLocale[2]) and NOT StzStringQ(paLocale[2]).IsLocaleAbbreviation()
			stzRaise("Incorrect format!")
		ok
	
		if isList(paLocale[2]) and NOT StzListQ(paLocale[2]).IsLocaleList()
			stzRaise("Incorrect format!")
		ok
	
		return _@(pcStr).LowercasedInLocale(paLocale[2]) = This.String()

	  #-------------------------------#
	 #     UPPERCASING THE STRING    #
	#-------------------------------#

	def ApplyUppercase()
		oLocale = ActiveLocale()
		This.Update( oLocale.toUppercase(This.String()) )

		#< @FunctionFluentForm

		def ApplyUppercaseQ()
			This.ApplyUppercase()
			return This
	
		#>

		#< @FunctionAlternativeForm	// TODO: replace with @FunctionAlternativeFormForm

		def Uppercase() # Understand it as a verb that "uppercases" the string
			This.ApplyUppercase()

			def UppercaseQ()
				This.Uppercase()
				return This
	
		#>

	// Tranforms the string to LOCALE-SENSITIVE UPPERCase
	def ApplyUppercaseInLocale(pcLocale)
		oLocale = new stzLocale(pcLocale)
		This.Update( oLocale.ToUpperCase(This.String()) )

		#< @FunctionFluentForm

		def ApplyUppercaseInLocaleQ(pcLocale)
			This.ApplyUppercaseInLocale(pcLocale)
			return This

		#>

		#< @FunctionAlternativeForm	// TODO: replace with @FunctionAlternativeFormForm

		def UppercaseInrLocale(pLocale) # Understand it as a verb that "uppercases" the string in the givan locale
			This.ApplyUppercaseInLocale(pLocale)

			def UppercaseInLocaleQ(pLocale)
				This.ApplyUppercaseInLocale(pLocale)
				return This
	
		#>

	def Uppercased()
		oLocale = ActiveLocale()
		return oLocale.toUpperCase(This.String())

	def UppercasedInLocale(pcLocale)
		oLocale = new stzLocale(pcLocale)
		return oLocale.ToUpperCase(This.String())

		#< @FunctionFluentForm

		def UPPERcasedInLocaleQ()
			return new stzString( This.UppercasedInLocale(pcLocale) )
	
		#>

	def IsUppercase()
		If This.IsEmpty()
			return FALSE
		ok

		bResult = TRUE

		for i = 1 to This.NumberOfChars()
			if This.CharAtQ(i).IsLetter() and
			   (NOT This.CharAtQ(i).IsUppercase())

				bResult = FALSE
				exit
			ok
		next

		return bResult

		#< @FunctionAlternativeForm

		def IsUppercased()
			return This.IsUppercase()

		def AllLettersAreUppercase()
			return This.IsUppercase()

		def AllLettersAreUppercased()
			return This.IsUppercase()

		#>
	
		#< @FunctionNegationForm

		def IsNotUppercase()
			return NOT This.IsUppercase()

		def IsNotUppercased()
			return This.IsNotUppercase()
		#>

		#< @FunctionAdditionForm

		def IsAlsoUppercase()
			return This.IsUppercase()

			def IsAlsoUppercased()
				return This.IsAlsoUppercase()

		#>

	def IsUppercaseOf(pcStr)
		return This.Uppercased() = pcStr

	def IsUppercaseOfInLocale(pcStr, pLocale)
		return This.UppercasedInLocale(pLocale) = pcStr


	  #--------------------------------#
	 #     CAPITALIZING THE STRING    #
	#--------------------------------#

	def ApplyCapitalcase()
		oLocale = ActiveLocale()
		This.Update( oLocale.ToCapitalcase(This.String()) )

		#< @FunctionFluentForm

		def ApplyCapitalcaseQ()
			This.ApplyCapitalcase()
			return This		

		#>

		#< @FunctionAlternativeFormForm

		def Capitalcase() # Understand it as a verb that "capitalcases" the string
			This.ApplyTitlecase()
			return This

			def CapitalcaseQ()
				This.Capitalcase()
				return This

		#>	
	
	// Tranforms the string to LOCALE-SENSITIVE titlecase
	def ApplyCapitalcaseInLocale(pLocale)
		oLocale = new stzLocale(pLocale)
		This.Update( oLocale.ToCapitalcase(This.String()) )

		#< @FunctionFluentForm

		def ApplyCapitalcaseInLocaleQ(pLocale)
			This.ApplyCapitalcaseInLocale(pLocale)
			return This
	
		#>

		#< @FunctionAlternativeForm

		def CapitalcaseInLocale(pLocale) # Understand it as a verb that "capitalcases" the string in the givan locale
			This.ApplyCapitalcaseInLocale(pLocale)

			def CapitalcaseInLocaleQ(pLocale)
				This.CapitalcaseInLocale(pLocale)
				return This
		
		#>

	def Capitalcased()
		oLocale = ActiveLocale()
		return oLocale.toCapitalcase(This.String())

		def Capitalised()
			return This.Capitalcased()

		def Capitalized()
			return This.Capitalcased()
		
	def CapitalcasedInLocale(pLocale)
		oLocale = new stzLocale(pLocale)
		return oLocale.ToCapitalcase(This.String())

		#< @FunctionFluentForm

		def CapitalcasedInLocaleQ()
			return new stzString( This.CapitalcasedInLocale() )

		#>

		#< @FunctionAlternativeForms

		def CapitalisedInLocale(pLocale)
			return CapitalcasedInLocale(pLocale)

			def CapitalisedInLocaleQ(pLocale)
				return new stzString( This.CapitalisedInLocale(pLocale) )

		def CapitalizedInLocale(pLocale)
			return CapitalcasedInLocale(pLocale)

			def CapitalizedInLocaleQ(pLocale)
				return new stzString( This.CapitalisedInLocale(pLocale) )

		#>

	def IsCapitalcase()
		oLocale = ActiveLocale()
		return oLocale.StringIsCapitalcased(This.String())

		#< @FunctionAlternativeFormForm

		def IsCapitalcased()
			return This.IsCapitalcase()

		def IsCapitalised()
			return This.IsCapitalcase()

		def IsCapitalized()
			return This.IsCapitalcase()

		#>

		#< @FunctionNegationForm

		def IsNotCapitalcase()
			return NOT This.IsCapitalcase()

		def IsNotCapitalcased()
			return This.IsNotCapitalcase()

		def IsNotCapitalised()
			return NOT This.IsCapitalised()

		def IsNotCapitalized()
			return NOT This.IsCapitalized()

		#>

		#< @FunctionAdditionForm

		def IsAlsoCapitalcase()
			return This.IsCapitalcase()

			def IsAlsoCapitalcased()
				return This.IsAlsoCapitalcase()

		def IsAlsoCapitalised()
			return NOT This.IsCapitalised()

		def IsAlsoCapitalized()
			return NOT This.IsCapitalized()

		#>

	def IsCapitalcaseOf(pcStr)
		return This.Capitalcased() = pcStr

	def IsCapitalcaseOfInLocale(pcStr, pLocale)
		return This.CapitalcasedInLocale(pLocale) = pcStr

	  #-------------------------------#
	 #     TITLECASING THE STRING    #
	#-------------------------------#

	def ApplyTitlecase()
		oLocale = ActiveLocale()
		This.Update( oLocale.ToTitlecase(This.String()) )

		#< @FunctionFluentForm

		def ApplyTitlecaseQ()
			This.ApplyTitlecase()
			return This		

		#>

		#< @FunctionAlternativeFormForm

		def Titlecase() # Understand it as a verb that "titlecases" the string
			This.ApplyTitlecase()
			return This

			def TitlecaseQ()
				This.Titlecase()
				return This

		#>	
	
	// Tranforms the string to LOCALE-SENSITIVE titlecase
	def ApplyTitlecaseInLocale(pLocale)
		oLocale = new stzLocale(pLocale)
		This.Update( oLocale.ToTitlecase(This.String()) )

		#< @FunctionFluentForm

		def ApplyTitlecaseInLocaleQ(pLocale)
			This.ApplyTitlecaseInLocale(pLocale)
			return This
	
		#>

		#< @FunctionAlternativeForm

		def TitlecaseInLocale(pLocale) # Understand it as a verb that "titlecases" the string in the givan locale
			This.ApplyTitlecaseInLocale(pLocale)

			def TitlecaseInLocaleQ(pLocale)
				This.TitelcaseInLocale(pLocale)
				return This
		
		#>

	def Titlecased()
		oLocale = ActiveLocale()
		return oLocale.toTitlecase(This.String())
			
	def TitlecasedInLocale(pLocale)
		oLocale = new stzLocale(pLocale)
		return oLocale.ToTitlecase(This.String())

		#< @FunctionFluentForm

		def TitlecasedInLocaleQ()
			return new stzString( This.TitlecasedInLocale() )

		#>

	def IsTitlecase()
		return ActiveLocale().StringIsTitleCased(This.String())

		#< @FunctionAlternativeFormForm

		def IsTitlecased()
			return This.IsTitlecase()

		#>

		#< @FunctionNegationForm

		def IsNotTitlecase()
			return NOT This.IsTitlecase()

		def IsNotTitlecased()
			return This.IsNotTitlecase()

		#>

		#< @FunctionAdditionForm

		def IsAlsoTitlecase()
			return This.IsTitlecase()

			def IsAlsoTitlecased()
				return This.IsAlsoTitlecase()

		#>

	def IsTitlecaseOf(pcStr)
		return This.Titlecased() = pcStr

	  #----------------------------------#
	 #      CASEFOLDING THE STRING      #
	#----------------------------------#

	# TODO: Review the structure of this section --> Should be same as Lowercase,
	# Uppercase, Titlecase, and Capitalcase...

	/*
	The casefold() method is an aggressive lower() method which
	converts strings to case folded strings for caseless matching.
	*/

	/* TODO:
	Review the Qt behaviour regarding QString.toCaseFolded() method.

	In fact, when writing:

	? StzStringQ("der Fluß").CaseFolded()

	We should have as rsult:

	"der fluss"

	since "ß" is casefolded to "ss" in german.

	But, Qt don't do that!
	
	*/

	// Transforms the string to casefolded style
	def CaseFold() # Understand it as a verb that "casefolds" the string
		This.Update( This.CaseFolded() )

		#< @FunctionFluentForm

		def CaseFoldQ()
			This.CaseFold()
			return This
	
		#>

	def CaseFolded()
		return @oQString.toCasefolded()

	def IsCaseFolded()
		If This.IsEmpty()
			return FALSE
		ok

		if This.Copy().CaseFolded() = This.Content()
			return TRUE
		else
			return FALSE
		ok

		return bResult

		#< @FunctionAlternativeForm

		def IsCaseFold()
			return This.IsCaseFolded()

		def AllLettersAreCaseFolded()
			return This.IsCaseFolded()

		def AllLettersAreCaseFold()
			return This.IsCaseFolded()

		#>
	
		#< @FunctionNegationForm

		def IsNotCaseFolded()
			return NOT This.IsCaseFolded()

		def IsNotCaseFold()
			return NOT This.IsCaseFolded()

		def AllLettersAreNotCaseFolded()
			return NOT This.IsCaseFolded()

		def AllLettersAreNotCaseFold()
			return NOT This.IsCaseFolded()

		#>

		#< @FunctionAdditionForm

		def IsAlsoCaseFolded()
			return This.IsCaseFolded()

		def IsAlsoCaseFold()
			return This.IsCaseFolded()

		def AllLettersAreAlsoCaseFolded()
			return This.IsCaseFolded()

		def AllLettersAreAlsoCaseFold()
			return This.IsCaseFolded()

		#>

	def IsCaseFoldedOf(pcStr)
		return This.CaseFolded() = pcStr
		
	  #------------------------#
	 #      CONTRACTIONS      #
	#------------------------#

	def Expand()
		// TODO

		/*
		don't	--> do not
		we've	--> we have
		did'nt	--> did not
		*/

	def Abbreviate()
		// TODO: inverse of Expand()

	  #---------------------------------#
	 #   CHECKING IF STRING IS WORD    #
	#---------------------------------#

	def IsWord()

		if This.IsEmpty() or This.IsNumberInString()
			return FALSE
		ok

		bResult = TRUE

		for i = 1 to This.NumberOfChars()
			c = This.NthChar(i)
			oChar = new stzChar(c)

			if oChar.IsNotLetter() and
			   oChar.IsNotNumber() and
			   c != HyphenShort() and
			   c != HyphenLong() and
			   c != Underscore() and
			   oChar.IsNotArabic7arakah() and
			   c != ArabicTamdeed()

				bResult = FALSE
				exit
			ok

		next

		return bResult

	def IsArabicWord()
		bResult = This.ToStzText().IsArabicWord()
		return bResult

	def IsLatinWord()
		bResult = This.ToStzText().IsLatinWord()
		return bResult

	  #-------------------------------------#
	 #   CHECKING IF STRING IS STOPWORD    #
	#-------------------------------------#

	def IsStopWord()
		return StopWordsQ().Contains(This.Lowercased())

	def IsStopWordIn(pcLang)
		bResult = This.ToStzText().IsStopWordIn(pcLang)
		return bResult

	def LanguageIfStopWord()
		cResult = This.ToStzText().LanguageIfStopWord()
		return cResult

	  #===================#
	 #      LETTERS      #
	#===================#

	// Returns the letters contained in the string
	def Letters()
		# t0 = clock()

		acResult = This.CharsW('StzCharQ(@char).IsLetter()')
		return acResult



		# ? ( clock() - t0 ) / clockspersecond()

		return acResult

		def LettersQ()
			return This.LettersQR(:stzList)

		def LettersQR(pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Icorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Letters() )

			on :stzListOfStings
				return new stzListOfStrings( This.Letters() )

			on :stzListOfChars
				return new stzListOfChars( This.Letters() )

			other
				stzRaise("Unsupported return type!")
			off

	def LettersXT(paOptions)
		if NOT isList(paOptions)
			stzRaise("Incorrect param type! paOptions must be a list.")
		ok

		if len(paOptions) = 0
			return This.Letters()
		ok

		if paOptions[ :ManageArabicShaddah ] = TRUE

			# MANAGING THE SPECIAL CASE OF ARABIC SHADDAH ("ّ ")
	
			# In fact, arabic shaddah is a letter (and so isLetter()
			# should return TRUE), but the shaddah should'nt appear in
			# the list of letters as sutch ("ّ ") but as the letter that
			# comes right before it!
	
			acResult = This.Letters()

			if This.Contains(ArabicShaddah())
				anPos = StzListOfStringsQ(acResult).FindAll(ArabicShaddah())

				for n in anPos
					if n > 1
						acResult[n] = acResult[n-1]
					ok
				next
	
			ok
		ok

		return acResult

		def LettersXTQ(paOptions)
			return This.LettersXTQR(paOptions, :stzList)

		def LettersXTQR(paOptions, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Icorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.LettersXT(paOptions) )

			on :stzListOfStings
				return new stzListOfStrings( This.LettersXT(paOptions) )

			on :stzListOfChars
				return new stzListOfChars( This.LettersXT(paOptions) )

			other
				stzRaise("Unsupported return type!")
			off

	def UniqueLettersXT(paOptions)
		return This.LettersXTQ(paOptions).DuplicatesRemoved()

		def UniqueLettersXTQ(paOptions)
			return This.UniqueLettersXTQR(paOptions, :stzList)

		def UniqueLettersXTQR(paOptions, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				stzRaise("Icorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueLettersXT(paOptions) )

			on :stzListOfStings
				return new stzListOfStrings( This.UniqueLettersXT(paOptions) )

			on :stzListOfChars
				return new stzListOfChars( This.UniqueLettersXT(paOptions) )

			other
				stzRaise("Unsupported return type!")
			off

		def ToSetOfLettersXT(paOptions)
			return This.UniqueLettersXT(paOptions)

			def ToSetOfLettersXTQ(paOptions)
				return This.ToSetOfLettersXTQR(paOptions, :stzList)
	
			def ToSetOfLettersXTQR(paOptions, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				if NOT isString(pcReturnType)
					stzRaise("Icorrect param! pcReturnType must be a string.")
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.ToSetOfLettersXT(paOptions) )
	
				on :stzListOfStings
					return new stzListOfStrings( This.ToSetOfLettersXT(paOptions) )
	
				on :stzListOfChars
					return new stzListOfChars( This.ToSetOfLettersXT(paOptions) )
	
				other
					stzRaise("Unsupported return type!")
				off

	  #=================#
	 #      LINES      #
	#=================#

	def Lines()
		return This.Split(NL)

		#< @FunctionFluentForm

		def LinesQ()
			return new stzListOfStrings( This.Lines() )

		#>
	
	def NumberOfLines()
		return len(This.Lines())

	  #================#
	 #    MARQUERS    #
	#================#

	// Removing zeros at the begining of marquer numbers
	def NormalizeMarquers()
		/* Example

		StzStringQ("The first candidate is #003, the second is #01, while the third is #2!") {	
			NormalizeMarquers()
			? Content()
		}

		# --> "The first candidate is #3, the second is #1, while the third is #2!"
		*/
		if This.Contains("#0")

			bContinue = TRUE
	
			While bContinue
	
				n = This.ReplaceLast("#0", :With = "#")
	
				if This.ContainsNo("#0")
					bContinue = FALSE
				ok
			end
		ok

		def NormaliseMarquers()
			This.NormaliseMarquers()

	def ContainsMarquers()
		if This.NumberOfMarquers() > 0
			return TRUE
		else
			return FALSE
		ok

	def Marquers()
		anPos = This.FindAll("#")

		if len(anPos) = 0
			return []
		ok

		aResult = []

		for n in anPos
			n1 = n + 1
			n2 = This.WalkForeward( :StartingAt = n+1, :Until = '{ NOT StzStringQ(@char).RepresentsNumberInDecimalForm() }' )

			if n1 != n2

				cMarquer = This.SectionQ(n1, n2).OnlyNumbersQ().RemoveRepeatedLeadingCharQ("0").Content()

				if cMarquer != ""
					if cMarquer[1] = "0"
						cMarquer = StzStringQ(cMarquer).Section(2, :LastChar)
					ok
				
					aResult + ("#" + cMarquer)
				ok
			ok
			
		next

		return aResult

		def MarquersQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType

			on :stzListOfStrings
				return new stzListOfStrings(This.Marquers())

			on :stzList
				return new stzList(This.Marquers())

			other
				stzRaise("Unsupported return type!")
			off

	def UniqueMarquers()
		return StzListQ(This.Marquers()).UniqueItems()

		def UniqueMarquersQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType

			on :stzListOfStrings
				return new stzListOfStrings(This.UniqueMarquers())

			on :stzList
				return new stzList(This.UniqueMarquers())

			other
				stzRaise("Unsupported return type!")
			off

		def SetOfMarquers()
			return This.UniqueMarquers()

			def SetOfMarquersQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
	
				on :stzListOfStrings
					return new stzListOfStrings(This.SetOfMarquers())
	
				on :stzList
					return new stzList(This.SetOfMarquers())
	
				other
					stzRaise("Unsupported return type!")
				off

	def NumberOfMarquers()
		return len(This.Marquers())

	def NumberOfCharsInEachMarquer()
		aResult = []
		for cMarquer in This.Marquers()
			aResult + len(cMarquer)
		next

		return aResult

		def MarquersNumbersOfChars()
			return This.NumberOfCharsInEachMarquer()

	  #----------------------------------#
	 #   MARQUERS AND THEIR POSITIONS   #
	#----------------------------------#

	def MarquersPositions()
		/* Example:

		StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
		
			? MarquersPositions()
			# --> [   12,   25,   44,   66 ]
		
		}
		*/

		acMarquers = This.Marquers()
		aResult = []

		n = 1

		for cMarquer in acMarquers
			n = This.FindNextOccurrence( :Of = cMarquer, :StartingAt = n )
			/* WARNING: Don't use:
			n = This.FindNextMarquer(cMarquer)
			--> Circular call --> Stackoverflow
			*/
			aResult + n
		next

		return aResult

		#< @FunctionFluentForm

		def MarquersPositionsQ()
			return This.MarquersPositionsQR(:stzListOfNumbers)

		def MarquersPositionsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType

			on :stzListOfNumbers
				return new stzListOfNumbers(This.MarquersPositions())

			on :stzList
				return new stzList(This.MarquersPositions())

			other
				stzRaise("Unsupported return type!")
			off
		#>

		#< @FunctionAlternativeForm

		def MarquersOccurrences()
			return This.MarquersPositions()

			def MarquersOccurrencesQ()
				return This.MarquersOccurrencesQR(:stzListOfNumbers)
	
			def MarquersOccurrencesQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
	
				on :stzListOfNumbers
					return new stzListOfNumbers(This.MarquersOccurrences())
	
				on :stzList
					return new stzList(This.MarquersOccurrences())
	
				other
					stzRaise("Unsupported return type!")
				off

		#>

	def MarquersAndPositions()
		/* Example:

		StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
		
			? MarquersAndPositions()
			# --> [ "#1" = 12, "#2" = 25 , "#3" = 44, "#1" = 66 ]
		
		}
		*/

		aResult = StzPairOfListsQ( This.Marquers(), This.MarquersPositions() ).AssociateQ().Content()
		return aResult

		#< @FunctionFluentForm

		def MarquersAndPositionsQ()
			return This.MarquersAndPositionsQR(:stzList)

		def MarquersAndPositionsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.MarquersAndPositions() )

			on :stzHashList
				return new stzHashList( This.MarquersAndPositions() )

			other
				stzRaise("Insupported returned type!")
			off

		#>

		#< @FunctionAlternativeForms

		def MarquersAndOccurrences()
			return This.MarquersAndPositions()

			def MarquersAndOccurrencesQ()
				return This.MarquersAndPositionsQ()

			def MarquersAndOccurrencesQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.MarquersAndPositionsQR(pcReturnType)
		#>

	def MarquersAndTheirPositions()
		/* Example:

		StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
		
			? MarquersAndTheirpositions()
			# --> [ "#1" = [12, 66], "#2" = [26], "#3" = [44] ]
		
		}
		*/
		acMarquers = This.UniqueMarquers()
		aResult = []

		for cMarquer in acMarquers
			anPos = This.FindAll(cMarquer)
			aResult + [ cMarquer, anPos ]
		next

		return aResult
		
		#< @FunctionFluentForm

		def MarquersAndTheirPositionsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType

			on :stzHashList
				return new stzHashList( This.MarquersAndTheirPositions() )

			on :stzList
				return new stzList( This.MarquersAndTheirPositions() )

			other
				stzRaise("Invalid param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def MarquersAndTheirOccurrences()
			return This.MarquersAndTheirPositions()

		#>

	  #----------------------------#
	 #      FINDING MARQUERS      #
	#----------------------------#

	def OccurrencesOfMarquer(pcMarquer)
		
		aResult = This.MarquersAndTheirPositions()[pcMarquer]
		if isString(aResult) and aResult = NULL
			return []
		else
			return aResult
		ok

		#< @FunctionFluentForm

		def OccurrencesOfMarquerQ(pcMarquer)
			return This.OccurrencesOfMarquerQR(pcMarquer, :stzList)

		def OccurrencesOfMarquerQR(pcMarquer, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.OccurrencesOfMarquer(pcMArquer) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.OccurrencesOfMarquer(pcMArquer) )

			other
				stzRaise("Unsupported return type!")

			off
		#>

		def PositionsOfMarquer(pcMarquer)
			return This.OccurrencesOfMarquer(pcMarquer)

			#< @FunctionFluentForm

			def PositionsOfMarquerQ(pcMarquer)
				return This.PositionsOfMarquerQR(pcMarquer, :stzList)
	
			def PositionsOfMarquerQR(pcMarquer, pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.PositionsOfMarquer(pcMArquer) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.PositionsOfMarquer(pcMArquer) )
	
				other
					stzRaise("Unsupported return type!")
	
				off

			#>

	def MarquerByPosition(pnPosition)
		aMarquers = This.MarquersAndTheirPositions()
		cResult = ""

		for aLine in aMarquers
			n = find(aLine[2], pnPosition)
			if n > 0
				cResult = aLine[1]
				exit
			ok
		next

		return cResult

		def MarquerByPositionQ(pnPosition)
			return new stzString( This.MarquerByPosition() )

		def MarquerByOccurrence(pnPosition)
			return This.MarquerByPosition(pnPosition)

			def MarquerByOccurrenceQ(pnPosition)
				return new stzString( This.MarquerByOccurrence(pnPosition) )

	  #---------------------------------#
	 #   MARQUERS AND THEIR SECTIONS   #
	#---------------------------------#

	def MarquersSections()
		/* Example:

		StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
		
			? MarquersPositions()
			# --> [  [12, 13], [ 25, 26],  [44, 45], [66, 67]  ]
		
		}
		*/

		anStartPos  = This.MarquersPositions()
		anNbOfChars = This.MarquersNumbersOfChars()

		aResult = []

		for i = 1 to len(anStartPos)
			aResult + [ anStartPos[i], anStartPos[i] + anNbOfChars[i] - 1 ]
		next

		return aResult


		#< @FunctionFluentForm

		def MarquersSectionsQ()
			return new stzList( This.MarquersSections() )

		#>

	def MarquersAndSections()
		/* Example:

		StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
		
			? MarquersAndPositions()
			# --> [ "#1" = 12, "#2" = 25 , "#3" = 44, "#1" = 66 ]
		
		}
		*/

		aResult = StzPairOfListsQ( This.Marquers(), This.MarquersSections() ).AssociateQ().Content()
		return aResult

		#< @FunctionFluentForm

		def MarquersAndSectionsQ()
			return This.MarquersAndSectionsQR(:stzList)

		def MarquersAndSectionsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.MarquersAndSections() )

			on :stzHashList
				return new stzHashList( This.MarquersAndSections() )

			other
				stzRaise("Insupported returned type!")
			off

		#>

	def MarquersAndTheirSections()
		/* Example:

		StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
		
			? MarquersAndTheirpositions()
			# --> [ "#1" = [12, 66], "#2" = [26], "#3" = [44] ]
		
		}
		*/

		aMarquers = This.MarquersAndTheirPositions()
		aResult = []

		for aMarquer in aMarquers
			cMarquer = aMarquer[1]
			anMarquerPositions = aMarquer[2]

			aMarquerSections = []

			for nPos in anMarquerPositions
				aMarquerSections + [ nPos, nPos + len(cMarquer) - 1 ]
			next

			aResult + [ cMarquer, aMarquerSections ]
		next
		
		return aResult

		#< @FunctionFluentForm

		def MarquersAndTheirSectionsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType

			on :stzHashList
				return new stzHashList( This.MarquersAndTheirSections() )

			on :stzList
				return new stzList( This.MarquersAndTheirSections() )

			other
				stzRaise("Invalid param type!")
			off

		#>
	
	  #-----------------------------------------#
	 #    SORTING MARQUERS INSIDE THE STRING   #
	#-----------------------------------------#

	def MarquersAreSorted()
		bResult = StzListQ(This.Marquers()).ItemsAreSorted()
		return bResult

	def MarquersSortingOrder()
		bResult = StzListQ(This.Marquers()).SortingOrder()
		return bResult

	def MarquersAreUnsorted()
		bResult = StzListQ(This.Marquers()).ItemsAreUnsorted()
		return bResult

		def MarquersAreNotSorted()
			return This.MarquersAreUnsorted()

	def MarquersAreSortedInAscending()
		bResult = StzListQ(This.Marquers()).ItemsAreSortedInAscending()
		return bResult

	def MarquersAreSortedInDescending()
		bResult = StzListQ(This.Marquers()).ItemsAreSortedInDescending()
		return bResult

	def MarquersSortedInAscending()
		bResult = StzListQ(This.Marquers()).SortedInAscending()
		return aResult

	def MarquersSortedInDescending()
		aResult = StzListQ(This.Marquers()).SortedInDescending()
		return aResult

	def MarquersPositionsSortedInAscending()
		aResult = StzListQ(This.MarquersPositions()).SortedInAscending()
		return aResult

	def MarquersPositionsSortedInDescending()
		aResult = StzListQ(This.MarquersPositions()).SortedInDescending()
		return aResult

	def MarquersAndPositionsSortedInAscending()
		acMarquers  = This.MarquersSortedInAscending()
		anPositions = This.MarquersPositionsSortedInAscending()

		aResult = StzPairOfListsQ( acMarquers, anPositions).Associate()

		return aResult

		def MarquersSortedInAscendingAndTheirPositions()
			return This.MarquersAndPositionsSortedInAscending()


	def MarquersAndPositionsSortedInDescending()
		acMarquers  = This.MarquersSortedInDescending()
		anPositions = This.MarquersPositionsSortedInDescending()

		aResult = StzPairOfListsQ( acMarquers, anPositions ).Associate()

		return aResult

		def MarquersSortedInDescendingAndTheirPositions()
			return This.MarquersAndPositionsSortedInDescending()

	def MarquersAndSectionsSortedInAscending()
		acMarquers  = This.MarquersSortedInAscending()
		anPositions = This.MarquersPositionsSortedInAscending()

		aResult = []
		i = 0

		for cMarquer in acMarquers
			i++

			n1 = anPositions[i]
			n2 = n1 + len(cMarquer) - 1
		
			aResult + [ cMarquer, [ n1, n2 ] ]
		next

		return aResult

		def MarquersSortedInAscendingAndTheirSections()
			return This.MarquersAndSectionsSortedInAscending()

	def MarquersAndSectionsSortedInDescending()
		acMarquers  = This.MarquersSortedInDescending()
		anPositions = This.MarquersPositionsSortedInAscending()

		aResult = []
		i = 0

		for cMarquer in acMarquers
			i++

			n1 = anPositions[i]
			n2 = n1 + len(cMarquer) - 1
		
			aResult + [ cMarquer, [ n1, n2 ] ]
		next

		return aResult

		def MarquersSortedInDescendingAndTheirSections()
			return This.MarquersAndSectionsSortedInDescending()

	def SortMarquersInAscending()
		#< @MotherFunction = This.ReplaceSection() > @QtBased = TRUE #>

		/* Example

		Q("My name is #2, may age is #1, and my job is #3.") {
			SortMarquersInAscending()
			? Content()
		}

		# !--> My name is #1, may age is #2, and my job is #3.
		*/

		aMarquersSections = This.MarquersAndSectionsSortedInAscending()
		/* Reminder
		# --> [ "#1" = [12, 13], "#1" = [26, 27], "#2" = [44, 45], "#3" = [66, 67] ]
		*/

		for i = len(aMarquersSections) to 1 step -1
			cMarquer = aMarquersSections[i][1]
			n1 = aMarquersSections[i][2][1]
			n2 = aMarquersSections[i][2][2]

			This.ReplaceSection(:From = n1, :To = n2, :With = cMarquer)
		next

		def SortMarquersInAscendingQ()
			This.SortMarquersInAscending()
			return This

	def StringWithMaquersSortedInAscending()
		cResult = This.Copy().SortMarquersInAscendingQ().Content()
		return cResult

	def SortMarquersInDescending()
		#< @MotherFunction = This.ReplaceSection() > @QtBased = TRUE #>

		/* Example

		Q("My name is #2, may age is #1, and my job is #3.") {
			SortMarquersInDescending()
			? Content()
		}

		# !--> My name is #3, may age is #2, and my job is #1.
		*/

		aMarquersSections = This.MarquersAndSectionsSortedInDescending()
		/* Reminder
		Q("My name is #2, may age is #1, and my job is #3.") {
			? MarquersAndSectionsSortedInDescending()
		}

		# --> [ "#3" = [45, 46], "#2" = [27, 28], "#1" = [12, 13] ]
		*/

		for i = 1 to len(aMarquersSections)
			cMarquer = aMarquersSections[i][1]
			n1 = aMarquersSections[i][2][1]
			n2 = aMarquersSections[i][2][2]

			This.ReplaceSection(:From = n1, :To = n2, :With = cMarquer)
		next

		def SortMarquersInDescendingQ()
			This.SortMarquersInDescending()
			return This

	def StringWithMaquersSortedInDescending()
		cResult = This.Copy().SortMarquersInDescendingQ().Content()
		return cResult

	  #------------------------------------------#
	 #    REPLACING SUBSTRINGS WITH MARQUERS    # TODO: Test it
	#------------------------------------------#

	def ReplaceSubstringsWithMarquersCS(pacSubstrings, pCaseSensitive)

		acSubStrings = StzListOfStringsQ(pacSubstrings).DuplicatesRemovedCS(pCaseSensitive)

		acMarquers = []

		for i = 1 to len(acSubStrings)
			acMarquers + ( "#" + i )
		next

		This.ReplaceManyOneByOneCS( acSubStrings, :With = acMarquers, pCaseSensitive )

		def ReplaceSubstringsWithMarquersCSQ(pacSubstrings, pCaseSensitive)
			This.ReplaceSubstringsWithMarquersCS(pacSubstrings, pCaseSensitive)
			return This

	def SubstringsReplacedWithMarquersCS(pacSubstrings, pCaseSensitive)
		cResult = This.Copy().ReplaceSubstringsWithMarquersCSQ(pacSubstrings, pCaseSensitive).Content()
		return cResult

	def ReplaceSubstringsWithMarquers(pacSubstrings)
		This.ReplaceSubstringsWithMarquersCS(pacSubstrings, :CaseSensitive = TRUE)

	  #------------------------#
	 #    PARSING MARQUERS    #
	#------------------------#

	def NthMarquer(n)
		if NOT isNumber(n)
			stzRaise("Incorrect param type! n should be a number.")
		ok

		try
			return This.Marquers()[n]
		catch
			return NULL
		done

		def NthMarquerQ(n)
			return new stzString( This.NthMarquer(n) )

	def FirstMarquer()
		return This.NthMarquer(1)

		def FirstMarquerQ()
			return new stzString( This.LastMarquer() )

	def LastMarquer()
		return This.Marquers()[ This.NumberOfMarquers() ]

		def LastMarquerQ()
			return new stzString( This.LastMarquer() )

	#-----

	def FindNthMarquer(n)
		if isString(n)
			if n = :FirstChar or n = :StartOfString
				n = 1
			but n = :LastChar or n = :EndOfString
				n = This.NumberOfMarquers()
			ok
		ok

		return This.FindNthOccurrence( n, :Of = "#" )

		def NthMarquerOccurrence(n)
			return This.FindNthMarquer(n)

		def NthMarquerPosition(n)
			return This.FindNthMarquer(n)

	def FindFirstMarquer()
		return This.FindNthMarquer(1)

		def FirstMarquerOccurrence()
			return This.FindFirstMarquer()

		def FirstMarquerPosition()
			return This.FindFirstMarquer()

	def FindLastMarquer()
			return This.FindNthMarquer(:Last)

		def LastMarquerOccurrence()
			return This.FindLastMarquer()

		def LastMarquerPosition()
			return This.FindLastMarquer()

	#----- NEXT MARQUERS

	def NextMarquers(pnStartingAt)
		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		return This.SectionQ(pnStartingAt, :LastChar).Marquers()

		def NextMarquersQ(pnStartingAt)
			return This.NextMarquersQR(pnstartingAt, :stzList)

		def NextMarquersQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NextMarquers(pnStartingAt) )
	
			on :stzListOfStrings
				return new stzListOfStrings( This.NextMarquers(pnStartingAt) )

			other
				stzRaise("Unsupported return type!")
			off

	def NthNextMarquer(n, pnStartingAt)
		/*
		StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
			? NthNextMarquer(2, :StartingAt = 14)
		}

		# --> #3
		*/

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		oStr = This.SectionQ(pnStartingAt, :LastChar)
		return oStr.Marquers()[ n ]


		def NthNextMarquerQ(n, pnStartingAt)
			return new stzString( This.NthNextMarquer(n, pnStartingAt) )

		def NextNthMarquer(n, pnStartingAt)
			return This.NthNextMarquer(n, pnStartingAt)

			def NextNthMarquerQ(n, pnStartingAt)
				return new stzString( This.NextNthMarquer(n, pnStartingAt) )

	def FindNthNextMarquer(n, pnStartingAt)
		/*
		StzStringQ("My name is #1, my age is #2, and my job is #3. Again: my name is #1!") {
			? NthNextMarquer(2, :StartingAt = 14)
		}

		# --> 44
		*/

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		oStr = This.SectionQ(pnStartingAt, :LastChar)

		nPos = oStr.MarquersPositions()[ n ] + pnStartingAt - 1
		
		return nPos

		def FindNextNthMarquer(n, pnStartingAt)
			return This.FindNthNextMarquer(n, pnStartingAt)

		def NextNthMarquerOccurrence(n, pnStartingAt)
			return This.FindNthNextMarquer(n, pnStartingAt)

		def NthNextMarquerOccurrence(n, pnStartingAt)
			return This.FindNthNextMarquer(n, pnStartingAt)		

		def NthNextMarquerPosition(n, pnStartingAt)
			return This.FindNthNextMarquer(n, pnStartingAt)

		def NextNthMarquerPosition(n, pnStartingAt)
			return This.FindNthNextMarquer(n, pnStartingAt)

	def NthNextMarquerAndItsPosition(n, pnStartingAt)
		cMarquer  = This.NthNextMarquer(n, pnStartingAt)
		nPosition = This.FindNthNextMarquer(n, pnStartingAt)

		return [ cMarquer, nPosition ]

		#< @FunctionFluentForm

		def NthNextMarquerAndItsPositionQ(n, pnStartingAt)
			return This.NthNextMarquerAndItsPositionQR(n, pnStartingAt, pnStartingAt, :stzList)

		def NthNextMarquerAndItsPositionQR(n, pnStartingAt, pnStartingAt, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NthNextMarquerAndItsPosition(n, pnStartingAt) )

			on :stzHashList
				return new stzHashList( This.NthNextMarquerAndItsPosition(n, pnStartingAt) )

			other
				stzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def NextNthMarquerAndItsPosition(n, pnStartingAt)
			return This.NthNextMarquerAndItsPosition(n, pnStartingAt)

		#>

	def FindNextMarquer(pnStartingAt)

		return This.FindNthNextMarquer(1, pnStartingAt)

		def NextMarquerPosition(pnStartingAt)
			return This.FindNextMarquer(pnStartingAt)

		def NextMarquerOccurrence(pnStartingAt)
			return This.FindNextMarquer(pnStartingAt)

	def NextMarquer(pnStartingAt)
		return This.NthNextMarquer(1, pnStartingAt)

		def NextMarquerQ(pnStartingAt)
			return new stzString( This.NextMarquer(pnStartingAt) )

	def NextMarquerAndItsPosition(pnStartingAt)
		cMarquer  = This.NextMarquer(pnStartingAt)
		nPosition = This.NextMarquerPosition(pnStartingAt)

		return [ cMarquer, nPosition ]

		def NextMarquerAndItsPositionQ(pnStartingAt)
			return new stzString( This.NextMarquerAndItsPosition(pnStartingAt) )

		def NextMarquerAndItsOccurrence(pnStartingAt)
			return This.NextMarquerAndItsPosition(pnStartingAt)

			def NextMarquerAndItsOccurrenceQ(pnStartingAt)
				return new stzString( This.NextMarquerAndItsOccurrence(pnStartingAt) )

	#----- PREVIOUS MARQUERS

	def PreviousMarquers(pnStartingAt)
		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		return This.SectionQ(1, pnStartingAt).Marquers()

		def PreviousMarquersQ(pnStartingAt)
			return This.PreviousMarquersQR(pnstartingAt, :stzList)

		def PreviousMarquersQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.PreviousMarquers(pnStartingAt) )
	
			on :stzListOfStrings
				return new stzListOfStrings( This.PreviousMarquers(pnStartingAt) )

			other
				stzRaise("Unsupported return type!")
			off

	def NthPreviousMarquer(n, pnStartingAt)
		nPos = This.FindNthPreviousMarquer(n, pnStartingAt)

		return This.MarquerByPosition(nPos)
		
		def NthPreviousMarquerQ(n, pnStartingAt)
			return new stzString( This.NthPreviousMarquer(n, pnStartingAt) )

		def PreviousNthMarquer(n, pnStartingAt)
			return This.NthPreviousMarquer(n, pnStartingAt)

			def PreviousNthMarquerQ(n, pnStartingAt)
				return new stzString( This.PreviousNthMarquer(n, pnStartingAt) )

	def FindNthPreviousMarquer(n, pnStartingAt)

		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		oStr = This.SectionQ(1,  pnStartingAt)

		aPositions = oStr.MarquersPositions()
		
		try
			return aPositions[ len(aPositions) - n + 1 ]
		catch
			return 0
		done
		
		#< @FunctionAlternativeForm

		def FindPreviousNthMarquer(n, pnStartingAt)
			return This.FindNthPreviousMarquer(n, pnStartingAt)

		def PreviousNthMarquerOccurrence(n, pnStartingAt)
			return This.FindNthPreviousMarquer(n, pnStartingAt)

		def NthPreviousMarquerOccurrence(n, pnStartingAt)
			return This.FindNthPreviousMarquer(n, pnStartingAt)		

		def NthPreviousMarquerPosition(n, pnStartingAt)
			return This.FindNthPreviousMarquer(n, pnStartingAt)

		def PreviousNthMarquerPosition(n, pnStartingAt)
			return This.FindNthPreviousMarquer(n, pnStartingAt)

		#>

	def NthPreviousMarquerAndItsPosition(n, pnStartingAt)
		cMarquer  = This.NthPreviousMarquer(n, pnStartingAt)
		nPosition = This.FindNthPreviousMarquer(n, pnStartingAt)

		return [ cMarquer, nPosition ]

		#< @FunctionFluentForm

		def NthPreviousMarquerAndItsPositionQ(n, pnStartingAt)
			return This.NthPreviousMarquerAndItsPositionQR(n, pnStartingAt, pcReturnType)

		def NthPreviousMarquerAndItsPositionQR(n, pnStartingAt, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NthPreviousMarquerAndItsPosition(n, pnStartingAt) )

			on :stzHashList
				return new stzHashList( This.NthPreviousMarquerAndItsPosition(n, pnStartingAt) )

			other
				stzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def PreviousNthMarquerAndItsPosition(n, pnStartingAt)
			return This.NthPreviousMarquerAndItsPosition(n, pnStartingAt)

		#>

	def FindPreviousMarquer(pnStartingAt)
		return This.FindNthPreviousMarquer(1, pnStartingAt)

		def PreviousMarquerPosition(pnStartingAt)
			return This.FindPreviousMarquer(pnStartingAt)

		def PreviousMarquerOccurrence(pnStartingAt)
			return This.FindPreviousMarquer(pnStartingAt)

	def PreviousMarquer(pnStartingAt)
		return This.NthPreviousMarquer(1, pnStartingAt)

		def PreviousMarquerQ(pnStartingAt)
			return new stzString( This.PreviousMarquer(pnStartingAt) )

	def PreviousMarquerAndItsPosition(pnStartingAt)
		cMarquer  = This.PreviousMarquer(pnStartingAt)
		nPosition = This.PreviousMarquerPosition(pnStartingAt)

		return [ cMarquer, nPosition ]

		def PreviousMarquerAndItsPositionQ(pnStartingAt)
			return new stzString( This.PreviousMarquerAndItsPosition(pnStartingAt) )

		def PreviousMarquerAndItsOccurrence(pnStartingAt)
			return This.PreviousMarquerAndItsPosition(pnStartingAt)

			def PreviousMarquerAndItsOccurrenceQ(pnStartingAt)
				return new stzString( This.PreviousMarquerAndItsOccurrence(pnStartingAt) )


	  #------------------#
	 #      TO TEXT     #
	#------------------#

	def ToStzText()
		return new stzText( This.String() )

	  #---------------------------#
	 #      TO SET OF CHARS      #
	#---------------------------#

	def ToSetOfChars()

		t0 = clock()

		aResult = []

		for i = 1 to This.NumberOfChars()

			c = This.NthChar(i)

			if NOT find(aResult, c)
				aResult + c
			ok

		next

		? ( clock() - t0 ) / clockspersecond()

		return aResult

		#< @FunctionFluentForm

		def ToSetOfCharsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType

			on :stzSet
				return new stzSet( This.ToSetOfChars() )

			on :stzList
				return new stzList( This.ToSetOfChars() )

			on :stzListOfChars
				return new stzListOfChars( This.ToSetOfChars() )

			on :stzListOfStrings
				return new stzListOfStrings( This.ToSetOfChars() )
			off

		def ToSetOfCharsQ()
			return This.ToSetOfCharsQR(:stzSet)

		#>

	  #-----------------------------------------------#
	 #      NUMBER OF OCCURRENCE OF A SUBSTRING      #
	#-----------------------------------------------#

	def NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
		nResult = len( This.FindAllCS(pcSubStr, pCaseSensitive) )
		return nResult

		#< @FunctionAlternativeForm
	
		def NumberOfOccurrencesCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

		def NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)

			def NumberOfOccurrencesOfSubstringCS(pcSubStr, pCaseSensitive)
				return This.NumberOfOccurrenceOfSubstringCS(pcSubStr, pCaseSensitive)
	
		#>

	def NumberOfOccurrence(pcStr)
		if isList(pcStr) and StzListQ(pcStr).IsOfParamList()
			pcStr = pcStr[2]
		ok

		return NumberOfOccurrenceCS(pcStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def NumberOfOccurrences(pcStr)
			return This.NumberOfOccurrence(pcStr)

		def NumberOfOccurrenceOfSubstring(pcStr)
			return This.NumberOfOccurrence(pcStr)

			def NumberOfOccurrencesOfSubstring(pcStr)
				return This.NumberOfOccurrenceOfSubstring(pcStr)

		#>

	  #-------------------------------------------------------#
	 #    CHECKING IF THE STRING IS ONE OF THE RING TYPES    #
	#-------------------------------------------------------#

	def IsRingType()
		return This.UppercaseQ().IsOneOfThese([ "NUMBER", "STRING", "LIST", "OBJECT", "COBJECT" ])

	  #-------------------------#
	 #      SIZE IN BYTES      #
	#-------------------------#

	def NumberOfBytes()
		return This.ToStzListOfBytes().NumberOfBytes()

		#< @FunctionAlternativeForm

		def SizeInBytes()
			return This.NumberOfBytes()

		#>
	
	def NumberOfBytesPerChar()
		aResult = []

		for i = 1 to This.NumberOfChars()
			aResult + [ This[i], StzStringQ(This[i]).NumberOfBytes() ]
		next

		return aResult

	  #-----------------------------------------#
	 #   N CHARS, LEFT & RIGHT, FIRST & LAST   #
	#-----------------------------------------#
							
	// Returns n chars from the right
	def NRightChars(n)

		if n = 0
			return NULL
		else
			if This.IsRightToleft()
				cResult = This.Section( 1, n )
			else
				cResult = This.Section( This.NumberOfChars()-n+1, NumberOfChars() )
			end
					
			return cResult
		ok

		#< @FunctionFluentForm

		def NRightCharsQ(n)
			return new stzString( This.NRightChars(n) )

		#>

		#< @FunctionAlternativeForm

		def RightNChars(n)
			return This.NRightChars(n)

			#< @FunctionFluentForm
	
			def RightNCharsQ(n)
				return This.NRightCharsQ(n)
	
			#>

		#>

	// Returns n Chars from the left
	def NLeftChars(n)
		if n = 0
			return NULL
		else
			if IsRightToleft()
				cResult = Section( This.NumberOfChars()-n+1, NumberOfChars() )
			else
				cResult = Section( 1, n)
			end
	
			return cResult
		ok

		#< @FunctionFluentForm

		def NLeftCharsQ(n)
			return new stzString( This.NLeftChars(n) )

		#>

		#< @FunctionAlternativeForm

		def LeftNChars(n)
			return This.NLeftChars(n)

			#< @FunctionFluentForm
	
			def LeftNCharsQ(n)
				return This.NLeftCharsQ(n)
	
			#>

		#>

	def NFirstChars(n)
		if This.IsRightToLeft()
			return This.NRightChars(n)
		else
			return This.NLeftChars(n)
		ok

		#< @FunctionFluentForm

		def NFirstCharsQ(n)
			return new stzString( This.NFirstChars(n) )

		#>

		#< @FunctionAlternativeForm

		def FirstNChars(n)
			return This.NFirstChars(n)

			#< @FunctionFluentForm
	
			def FirstNCharsQ(n)
				return This.NFirstCharsQ(n)
	
			#>

		#>

	def NLastChars(n)
		if This.IsRightToLeft()
			return This.NLeftChars(n)
		else
			return This.NRightChars(n)
		ok

		#< @FunctionFluentForm

		def NLastCharsQ(n)
			return new stzString( This.NLastChars(n) )

		#>

		#< @FunctionAlternativeForm

		def LastNChars(n)
			return This.NLastChars(n)

			#< @FunctionFluentForm
	
			def LastNCharsQ(n)
				return This.NLastCharsQ(n)
	
			#>

		#>

	  #------------------------------#
	 #   BYTES AND BYTES PER CHAR   #
	#------------------------------#

	def ToStzListOfBytes()
		return new stzListOfBytes( This.String() )

	def Bytes()
		return This.ToStzListOfBytes().Content()

		#< @FunctionFluentForm

		def BytesQ()
			return This.ToStzListOfBytes()

		#>
	
		#< @FunctionAlternativeForm

		def ToListOfBytes()
			return This.Bytes()

			#< @FunctionFluentForm
	
			def ToListOfBytesQ()
				return This.BytesQ()
		
			#>
	
		#>

	def BytesPerChar()
		return This.ToStzListOfBytes().BytesPerChar()

	  #--------------------------------------#
	 #   BYTECODES AND BYTECODES PER CHAR   #
	#--------------------------------------#

	def Bytecodes()
		return This.ToStzListOfBytes().Bytecodes()

	def BytecodesPerChar()
		return This.ToStzListOfBytes().BytecodesPerChar()

	  #==============================#
	 #     BOUNDS OF THE STRING     #
	#==============================#

	// Verifies if the string is bounded by substrings 1 and 2 
	def IsBoundedBy(pcSubstr1, pcSubstr2)
		return This.IsBoundedByCS(pcSubstr1, pcSubstr2, :Casesensitive = TRUE)

		#< @FunctionCasesensitivityForm

		def IsBoundedByCS(pcSubstr1, pcSubstr2, pCaseSensitive)
			if This.BeginsWithCS(pcSubstr1, pCaseSensitive) and
			   This.EndsWithCS(pcSubStr2, pCaseSensitive)

				return TRUE
			else
				return FALSE
			ok

	// Returns the bounds of the string up to n Chars
	def BoundsUpToNChars(n)
		return [ This.NFirstChars(n), This.NLastChars(n) ]

		#< @FunctionFluentForm
	
		def BoundsUpToNCharsQ(n)
			return new stzList( This.BoundsUpToNChars(n) )

		#>

	def IsBoundedManyTimesBy(paPairsOfBounds)
		/*
		o1 = new stzString("|<- Scope of Life ->|")
		? o1.IsBoundedManyTimesBy([ ["|","|"], ["<",">"], ["-","-"] ])

		--> TRUE
		*/

		return This.IsBoundedManyTimesByCS(paPairsOfBounds, :Casesensitive = TRUE)

		#< @FunctionCasesensitiveForm

		def IsBoundedManyTimesByCS(paPairsOfBounds, pCaseSensitive)

			bResult = TRUE
	
			oCopy = This.Copy()
	
			for aPair in paPairsOfBounds
	
				if NOT oCopy.IsBoundedByCS(aPair[1], aPair[2], pCaseSensitive)
					bResult = FALSE
					exit
				else
					oCopy.RemoveBoundsCS(aPair[1], aPair[2], pCaseSensitive)
				ok
			next
	
			return bResult

		#>

	  #------------------------------------#
	 #     ADDING BOUNDS TO THE STRING    #
	#------------------------------------#

	def AddBounds(pcSubStr1, pcSubStr2)
		if BothAreStrings(pcSubStr1, pcSubStr2)
			cResult = pcSubStr1 + This.String() + pcSubStr2
			This.UpdateWith( cResult )
		ok

		def AddBoundsQ(pcSubStr1, pcSubStr2)
			This.AddBounds(pcSubStr1, pcSubStr2)
			return This

		def BoundWith(pcSubStr1, pcSubStr2)
			This.AddBounds(pcSubStr1, pcSubStr2)

			def BoundWithQ(pcSubStr1, pcSubStr2)
				This.BoundWith(pcSubStr1, pcSubStr2)
				return This

	def StringWithBoundsAdded(pcSubStr1, pcSubStr2)
		cResult = This.Copy().AddBoundsQ(pcSubStr1, pcSubStr2).Content()

		def StringBoundedWith(pcSubStr1, pcSubStr2)
			return This.StringWithBoundsAdded(pcSubStr1, pcSubStr2)

		def BoundedWith()
			return This.StringWithBoundsAdded(pcSubStr1, pcSubStr2)

		def BoundsAdded()
			return This.StringWithBoundsAdded(pcSubStr1, pcSubStr2)

	  #-------------------------------#
	 #     REMOVING BOTH BOUNDS      #
	#-------------------------------#

	def RemoveBounds(pcSubstr1, pcSubstr2)
		This.RemoveBoundsCS(pcSubstr1, pcSubstr2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveBoundsQ(pcSubstr1, pcSubstr2)
			This.RemoveBounds(pcSubstr1, pcSubstr2)
			return This
		#>

		#> @FunctionCasesensitivityForm

		def RemoveBoundsCS(pcSubstr1, pcSubstr2, pCaseSensitive)

			if This.IsBoundedByCS(pcSubstr1, pcSubstr2, pCaseSensitive)
				This.RemoveFirstCS(pcSubStr1, pCaseSensitive)
				This.RemoveLastCS(pcSubStr2, pCaseSensitive)
			ok
		
			#< @FunctionFluentForm
	
			def RemoveBoundsCSQ(pcSubstr1, pcSubstr2, pCaseSensitive)
				This.RemoveBoundsCS(pcSubstr1, pcSubstr2, pCaseSensitive)
				return This
		
			#>

		#>

	def BoundsRemoved(pcSubstr1, pcSubstr2)
		cResult = This.Copy().RemoveBoundsQ(pcSubstr1, pcSubstr2).Content()
		return cResult

		def BoundsRemovedCS(pcSubstr1, pcSubstr2, pCaseSensitive)
			cResult = This.Copy().RemoveManyBoundsCSQ(paPairsOfBounds).Content()
			return cResult

	def RemoveManyBounds(paPairsOfBounds)
		This.RemoveManyBoundsCS(paPairsOfBounds, :CaseSensitive = TRUE)

		def RemoveManyBoundsQ(paPairsOfBounds)
			This.RemoveManyBounds(paPairsOfBounds)
			return This

		def RemoveManyBoundsCS(paPairsOfBounds, pCaseSensitive)
			for aPair in paPairsOfBounds
				This.RemoveBoundsCS(aPair[1], aPair[2], pCaseSensitive)
			next

			def RemoveManyBoundsCSQ(paPairsOfBounds, pCaseSensitive)
				This.RemoveManyBoundsCS(paPairsOfBounds, pCaseSensitive)
				return This
		
	def ManyBoundsRemoved(paPairsOfBounds)
		cResult = This.Copy().RemoveManyBoundsQ(paPairsOfBounds).Content()
		return cResult

		def ManyBoundsRemovedCS(paPairsOfBounds, pCaseSensitive)
			cResult = This.Copy().RemoveManyBoundsCSQ(paPairsOfBounds, pCaseSensitive).Content()
			return cResult

	  #-----------------------------#
	 #     REMOVING LEFT BOUND     #
	#-----------------------------#

	def RemoveLeftBound(pcSubStr)
		This.RemoveLeftBoundCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveLeftBoundQ(pcSubStr)
			This.RemoveLeft(pcSubStr)
			return This
		#>

		#< @FunctionCasesensitivityForm

		def RemoveLeftBoundCS(pcSubStr, pCaseSensitive)
	
			nLenSubStr = StzStringQ( pcSubStr).NumberOfChars()
	
			if This.LeftNChars( nLenSubStr ) = pcSubStr
				This.ReplaceFirstOccurrenceCS(pcSubStr, "", pCaseSensitive)
			ok
	
			#< @FunctionFluentForm

			def RemoveLeftBoundCSQ(pcSubStr, pCaseSensitive)
				This.RemoveLeftBoundCS(pcSubStr, pCaseSensitive)
				return This
			#>
		#>

	def LeftBoundRemoved(pcSubStr)
		cResult = This.Copy().RemoveLeftBoundQ(pcSubStr).Content()
		return cResult

		def LeftBoundRemovedCS(pcSubStr, pCaseSensitive)
			cResult = This.Copy().RemoveLeftBoundCSQ(pcSubStr, pCaseSensitive).Content()
			return cResult

	  #------------------------------#
	 #     REMOVING RIGHT BOUND     #
	#------------------------------#

	def RemoveRightBound(pcSubStr)
		This.RemoveRightBoundCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveRightBoundQ(pcSubStr)
			This.RemoveRightBound(pcSubStr)
			return This

		#>

		#< @FunctionCasesensitivityForm
		
		def RemoveRightBoundCS(pcSubStr, pCaseSensitive)
	
			nLenSubStr = StzStringQ( pcSubStr).NumberOfChars()
	
			if This.RightNChars( nLenSubStr ) = pcSubStr
				This.ReplaceLastOccurrenceCS(pcSubStr, "", pCaseSensitive)
			ok
	
			#< @FunctionFluentForm

			def RemoveRightBoundCSQ(pcSubStr, pCaseSensitive)
				This.RemoveRightBoundCS(pcSubStr, pCaseSensitive)
				return This
	
			#>
		#>

	def RightBoundRemoved(pcSubStr)
		cResult = This.Copy().RemoveRightBoundQ(pcSubStr).Content()
		return cResult

		def RightBoundRemovedCS(pcSubStr, pCaseSensitive)
			cResult = This.Copy().RemoveRightBoundCSQ(pcSubStr, pCaseSensitive).Content()
			return cResult

	  #------------------------------#
	 #     REMOVING FIRST BOUND     #
	#------------------------------#

	def RemoveFirstBound(pcSubStr)
		This.RemoveFirstBoundCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveFirstBoundQ(pcSubStr)
			This.RemoveFirstBound(pcSubStr)
			return This

		#>

		#< @FunctionCasesensitivityForm

		def RemoveFirstBoundCS(pcSubStr, pCaseSensitive)
	
			if This.IsLeftToRight()
				This.RemoveLeftBoundCS(pcSubStr, pCaseSensitive)
	
			else
				# It IsRightToTeft() than...
				This.RemoveRightBoundCS(pcSubStr, pCaseSensitive)
				
			ok
	
			#< @FunctionFluentForm
	
			def RemoveFirstBoundCSQ(pcSubStr, pCaseSensitive)
				This.RemoveFirstBoundCS(pcSubStr, pCaseSensitive)
				return This
	
			#>
		#>

	def FirstBoundRemoved(pcSubStr)
		cRresult = This.Copy().RemoveFirstBoundQ(pcSubStr).Content()
		return cResult

		def FirstBoundRemovedCS(pcSubStr, pCaseSensitive)
			cResult = This.Copy().RemoveFirstBoundCSQ(pcSubStr, pCaseSensitive).Content()
			return cResult

	  #-----------------------------#
	 #     REMOVING LAST BOUND     #
	#-----------------------------#
	
	def RemoveLastBound(pcSubStr)
		This.RemoveLastBoundCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveLastBoundQ(pcSubStr)
			This.RemoveFirstBound(pcSubStr)
			return This
	
		#>

		#< @FunctionCasesensitivityForm

		def RemoveLastBoundCS(pcSubStr, pCaseSensitive)
	
			if This.IsLeftToRight()
				This.RemoveRightBoundsCS(pcSubStr, pCaseSensitive)
	
			else
				# It IsRightToTeft() then...
				This.RemoveLeftBoundsCS(pcSubStr, pCaseSensitive)
				
			ok
	
			#< @FunctionFluentForm

			def RemoveLastBoundCSQ(pcSubStr, pCaseSensitive)
				This.RemoveLastBoundCS(pcSubStr, pCaseSensitive)
				return This

			#>
		#>

	def LastBoundRemoved(pcSubStr)
		cResult = This.Copy().RemoveLastBoundQ(pcSubStr).Content()
		return cResult

		def LastBoundRemovedCS(pcSubStr, pCaseSensitive)
			cResult = This.Copy().RemoveLastBoundCSQ(pcSubStr, pCaseSensitive).Content()
			return cResult


	  #-----------------------------#
	 #     IDENTIFYING BOUNDS      # TODO (future)
	#-----------------------------#
	
	def Bounds()
		/* EXAMPLE

		o1 = new stzString("<<word>>")
		
		? o1.Bounds() # !--> [ "<<", ">>" ]
		*/

	def LeftBound()
		// TODO (future)

	def RightBound()
		// TODO (future)

	def FirstBound()
		// TODO (future)
		# For general use with left-to-right and right-toleft strings

	def LastBound()
		// TODO (future)
		
	  #============================#
	 #   REPEATED LEADING CHARS   #
	#============================#

	def HasRepeatedLeadingCharsCS(pCaseSensitive)

		if This.RepeatedLeadingCharsCS(pCaseSensitive) != NULL
			return TRUE
		else

			return FALSE
		ok

		def HasLeadingRepeatedCharsCS(pCaseSensitive)
			return This.HasRepeatedLeadingCharsCS(pCaseSensitive)

		def HasLeadingCharsCS(pCaseSensitive)
			return This.HasRepeatedLeadingCharsCS(pCaseSensitive)
	
	def RepeatedLeadingCharsCS(pCaseSensitive)
		/* Example:
			    'eeeTUNIS' 	--> 'eee'
			'exeeeeeTUNIS' 	--> ''
		*/

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveparamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT isBoolean(pCaseSensitive)
			stzRaise("Incorrect param! pCaseSensitive must be TRUE or FALSE.")
		ok

		if NOT This.IsEmpty()

			cResult = ""
	
			bContinue = TRUE
			cFirstChar = This.FirstChar()
			i = 1

			while bContinue
				i++

				if i > This.NumberOfChars()
					bContinue = FALSE
				ok

				cCurrentChar = This[i]

				if NOT StzStringQ(cCurrentChar).IsEqualToCS(cFirstChar, pCaseSensitive)
					bContinue = FALSE
				ok

			end

			if i > 2
				return This.NFirstChars(i-1)
			ok
		ok

		def RepeatedLeadingCharsCSQ(pCaseSensitive)
			return new stzString( This.RepeatedLeadingCharsCS(pCaseSensitive) )
	
		def LeadingRepeatedCharsCS(pCaseSensitive)
			return This.RepeatedLeadingCharsCS(pCaseSensitive)

			def LeadingRepeatedCharsCSQ(pCaseSensitive)
				return new stzString( This.LeadingRepeatedCharsCS(pCaseSensitive) )
	
		def LeadingCharsCS(pCaseSensitive)
			return This.RepeatedLeadingCharsCS(pCaseSensitive)

			def LeadingCharsCSQ(pCaseSensitive)
				return new stzString( This.LeadingCharsCS(pCaseSensitive) )
	
	def RepeatedLeadingCharCS(pCaseSensitive)

		if This.HasRepeatedLeadingCharsCS(pCaseSensitive)
			return This[1]
		ok

		def RepeatedLeadingCharCSQR(pcReturnType, pCaseSensitive)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzChar
				return new stzChar(This.RepeatedLeadingCharCS(pCaseSensitive))

			on :stzString
				return new stzString(This.RepeatedLeadingChar(pCaseSensitive))
			other
				stzRaise("Unsupported returned type!")
			off

		def RepeatedLeadingCharCSQ(pCaseSensitive)
			return This.RepeatedLeadingCharCSQR(:stzChar, pCaseSensitive)
	
		def LeadingRepeatedCharCS(pCaseSensitive)
			return This.RepeatedLeadingCharCS(pCaseSensitive)

			def LeadingRepeatedCharCSQR(pcReturnType, pCaseSensitive)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.RepeatedLeadingCharCSQR(pcReturnType, pCaseSensitive)

			def LeadingRepeatedCharCSQ(pCaseSensitive)
				return This.LeadingRepeatedCharQR(:stzChar, pCaseSensitive)
	
		def LeadingCharCS(pCaseSensitive)
			return This.RepeatedLeadingCharCS(pCaseSensitive)

			def LeadingCharCSQR(pcReturnType, pCaseSensitive)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.RepeatedLeadingCharCSQR(pcReturnType, pCaseSensitive)

			def LeadingCharCSQ(pCaseSensitive)
				return This.LeadingCharCSQR(:stzChar, pCaseSensitive)
	
	def NumberOfRepeatedLeadingCharsCS(pCaseSensitive)
		if This.HasRepeatedLeadingCharsCS(pCaseSensitive)
			return StzStringQ( This.RepeatedLeadingCharsCS(pCaseSensitive) ).NumberOfChars()
		else
			return 0
		ok

		def NumberOfLeadingRepeatedCharsCS(pCaseSensitive)
			return This.NumberOfRepeatedLeadingCharsCS(pCaseSensitive)

		def NumberOfLeadingCharsCS(pCaseSensitive)
			return This.NumberOfRepeatedLeadingCharsCS(pCaseSensitive)
	
	def RepeatedLeadingCharIsCS(c, pCaseSensitive)
		if This.HasRepeatedLeadingCharsCS(pCaseSensitive) and
		   This.FirstCharQ().IsEqualToCS(c, pCaseSensitive)

			return TRUE
		else
			return FALSE
		ok

		def LeadingRepeatedCharIsCS(c, pCaseSensitive)
			return This.RepeatedLeadingCharIsCS(c, pCaseSensitive)

		def LeadingCharIsCS(c, pCaseSensitive)
			return This.RepeatedLeadingCharIsCS(c, pCaseSensitive)
	
	#-- CASE-INSENSITIVE

	def HasRepeatedLeadingChars()
		return This.HasRepeatedLeadingCharsCS(:CaseSensitive = TRUE)

		def HasLeadingRepeatedChars()
			return This.HasRepeatedLeadingChars()

		def HasLeadingChars()
			return This.HasRepeatedLeadingChars()
	
	def RepeatedLeadingChars()
		/* Example:
			    'eeeTUNIS' 	--> 'eee'
			'exeeeeeTUNIS' 	--> ''
		*/

		return This.RepeatedLeadingCharsCS(:CaseSensitive = TRUE)

		def RepeatedLeadingCharsQ()
			return new stzString( This.RepeatedLeadingChars() )
	
		def LeadingRepeatedChars()
			return This.RepeatedLeadingChars()

			def LeadingRepeatedCharsQ()
				return new stzString( This.LeadingRepeatedChars() )
	
		def LeadingChars()
			return This.RepeatedLeadingChars()

			def LeadingCharsQ()
				return new stzString( This.LeadingChars() )
	
	def RepeatedLeadingChar()
		cResult = This.RepeatedLeadingCharCS(:CaseSensitive = TRUE)
		return cResult

		def RepeatedLeadingCharQ()
			return This.RepeatedLeadingCharQR(:stzString)

		def RepeatedLeadingCharQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzString
				return new stzString(This.RepeatedLeadingChar())

			on :stzChar
				return new stzChar(This.RepeatedLeadingChar())


			other
				stzRaise("Unsupported returned type!")
			off
	
		def LeadingRepeatedChar()
			return This.RepeatedLeadingChar()

			def LeadingRepeatedCharQ()
				return This.LeadingRepeatedCharQR(:stzString)

			def LeadingRepeatedCharQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.RepeatedLeadingCharQR(pcReturnType)
	
		def LeadingChar()
			return This.RepeatedLeadingChar()

			def LeadingCharQ()
				return This.LeadingCharQR(:stzString)

			def LeadingCharQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.RepeatedLeadingCharQR(pcReturnType)
	
	def NumberOfRepeatedLeadingChars()
		return This.NumberOfRepeatedLeadingCharsCS(:CaseSensitive = TRUE)

		def NumberOfLeadingRepeatedChars()
			return This.NumberOfRepeatedLeadingChars()

		def NumberOfLeadingChars()
			return This.NumberOfRepeatedLeadingChars()
	
	def RepeatedLeadingCharIs(c)
		return This.RepeatedLeadingCharIsCS(c, :CaseSensitive = TRUE)

		def LeadingRepeatedCharIs(c)
			return This.RepeatedLeadingCharIs(c)

		def LeadingCharIs(c)
			return This.RepeatedLeadingCharIs(c)

	  #-----------------------------#
	 #   REPEATED TRAILING CHARS   #
	#-----------------------------#

	def HasRepeatedTrailingCharsCS(pCaseSensitive)
		return This.Copy().ReverseCharsQ().HasRepeatedLeadingCharsCS(pCaseSensitive)

		def HasTrailingRepeatedCharsCS(pCaseSensitive)
			return This.HasRepeatedTrailingCharsCS(pCaseSensitive)

		def HasTrailingCharsCS(pCaseSensitive)
			return This.HasRepeatedTrailingCharsCS(pCaseSensitive)
	
	def RepeatedTrailingCharsCS(pCaseSensitive)
		/* Example:
			    'TUNISeee' 	--> 'eee'
			'TUNISexeeeee' 	--> ''
		*/

		cResult = This.Copy().ReverseCharsQ().RepeatedLeadingCharsCS(pCaseSensitive)
		return cResult

		def RepeatedTrailingCharsCSQ(pCaseSensitive)
			return new stzString( This.RepeatedTrailingCharsCS(pCaseSensitive) )
	
		def TrailingRepeatedCharsCS(pCaseSensitive)
			return This.RepeatedTrailingCharsCS(pCaseSensitive)

			def TrailingRepeatedCharsCSQ(pCaseSensitive)
				return new stzString( This.TrailingRepeatedCharsCS(pCaseSensitive) )
	
		def TrailingCharsCS(pCaseSensitive)
			return This.RepeatedTrailingCharsCS(pCaseSensitive)

			def TrailingCharsCSQ(pCaseSensitive)
				return new stzString( This.TrailingCharsCS(pCaseSensitive) )
	
	def RepeatedTrailingCharCS(pCaseSensitive)
		if This.HasRepeatedTrailingCharsCS(pCaseSensitive)
			return This[:LastChar]
		ok

		def RepeatedTrailingCharCSQ(pCaseSensitive)
			return This.RepeatedTrailingCharCSQR(:stzString, pCaseSensitive)

		def RepeatedTrailingCharCSQR(pcReturnType, pCaseSensitive)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzString
				return new stzString(This.RepeatedTrailingChar(pCaseSensitive))

			on :stzChar
				return new stzChar(This.RepeatedTrailingCharCS(pCaseSensitive))

			other
				stzRaise("Unsupported returned type!")
			off
	
		def TrailingRepeatedCharCS(pCaseSensitive)
			return This.RepeatedTrailingCharCS(pCaseSensitive)

			def TrailingRepeatedCharCSQ(pCaseSensitive)
				return This.TrailingRepeatedCharQR(:stzString, pCaseSensitive)

			def TrailingRepeatedCharCSQR(pcReturnType, pCaseSensitive)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.RepeatedTrailingCharCSQR(pcReturnType, pCaseSensitive)
	
		def TrailingCharCS(pCaseSensitive)
			return This.RepeatedTrailingCharCS(pCaseSensitive)

			def TrailingCharCSQR(pcReturnType, pCaseSensitive)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.RepeatedTrailingCharCSQR(pcReturnType, pCaseSensitive)

			def TrailingCharCSQ(pCaseSensitive)
				return This.TrailingCharCSQR(:stzChar, pCaseSensitive)
	
	def NumberOfRepeatedTrailingCharsCS(pCaseSensitive)
		if This.HasRepeatedTrailingCharsCS(pCaseSensitive)
			return StzStringQ( This.RepeatedTrailingCharsCS(pCaseSensitive) ).NumberOfChars()
		else
			return 0
		ok

		def NumberOfTrailingRepeatedCharsCS(pCaseSensitive)
			return This.NumberOfRepeatedTrailingCharsCS(pCaseSensitive)

		def NumberOfTrailingCharsCS(pCaseSensitive)
			return This.NumberOfRepeatedTrailingCharsCS(pCaseSensitive)
	
	def RepeatedTrailingCharIsCS(c, pCaseSensitive)
		if This.HasRepeatedTrailingCharsCS(pCaseSensitive) and
		   This.LastCharQ().IsEqualToCS(c, pCaseSensitive)

			return TRUE
		else
			return FALSE
		ok

		def TrailingRepeatedCharIsCS(c, pCaseSensitive)
			return This.RepeatedTrailingCharIsCS(c, pCaseSensitive)

		def TrailingCharIsCS(c, pCaseSensitive)
			return This.RepeatedTrailingCharIsCS(c, pCaseSensitive)
	
	#-- CASE-INSENSITIVE
	
	def HasRepeatedTrailingChars()
		return This.HasRepeatedTrailingCharsCS(:CaseSensitive = TRUE)

		def HasTrailingRepeatedChars()
			return This.HasRepeatedTrailingChars()

		def HasTrailingChars()
			return This.HasRepeatedTrailingChars()
	
	def RepeatedTrailingChars()
		/* Example:
			    'TUNISeee' 	--> 'eee'
			'TUNISexeeeee' 	--> ''
		*/

		return This.RepeatedTrailingCharsCS(:CaseSensitive = TRUE)

		def RepeatedTrailingCharsQ()
			return new stzString( This.RepeatedTrailingChars() )
	
		def TrailingRepeatedChars()
			return This.RepeatedTrailingChars()

			def TrailingRepeatedCharsQ()
				return new stzString( This.TrailingRepeatedChars() )
	
		def TrailingChars()
			return This.RepeatedTrailingChars()

			def TrailingCharsQ()
				return new stzString( This.TrailingChars() )
	
	def RepeatedTrailingChar()
		return This.RepeatedTrailingCharCS(:CaseSensitive = TRUE)

		def RepeatedTrailingCharQ()
			return This.RepeatedTrailingCharQR(:stzString)

		def RepeatedTrailingCharQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzString
				return new stzString(This.RepeatedTrailingChar())

			on :stzChar
				return new stzChar(This.RepeatedTrailingChar())

			other
				stzRaise("Unsupported returned type!")
			off
	
		def TrailingRepeatedChar()
			return This.RepeatedTrailingChar()

			def TrailingRepeatedCharQ()
				return This.TrailingRepeatedCharQR(:stzString)

			def TrailingRepeatedCharQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.RepeatedTrailingCharQR(pcReturnType)

		def TrailingChar()
			return This.RepeatedTrailingChar()


			def TrailingCharQ()
				return This.TrailingCharQR(:stzString)

			def TrailingCharQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.RepeatedTrailingCharQR(pcReturnType)
	
	def NumberOfRepeatedTrailingChars()
		return This.NumberOfRepeatedTrailingCharsCS(:CaseSensitive = TRUE)

		def NumberOfTrailingRepeatedChars()
			return This.NumberOfRepeatedTrailingChars()

		def NumberOfTrailingChars()
			return This.NumberOfRepeatedTrailingChars()
	
	def RepeatedTrailingCharIs(c)
		return This.RepeatedTrailingCharIsCS(c, :CaseSensitive = TRUE)

		def TrailingRepeatedCharIs(c)
			return This.RepeatedTrailingCharIs(c)

		def TrailingCharIs(c)
			return This.RepeatedTrailingCharIs(c)
	
	  #-------------------------------------#
	 #   REMOVING REPEATED LEADING CHARS   #
	#-------------------------------------#

	def RemoveRepeatedLeadingCharsCS(pCaseSensitive)
		if This.HasRepeatedLeadingCharsCS(pCaseSensitive)
			This.RemoveFirstNChars( This.NumberOfRepeatedLeadingCharsCS(pCaseSensitive) )
		ok

		def RemoveRepeatedLeadingCharsCSQ()
			This.RemoveRepeatedLeadingCharsCS(pCaseSensitive)
			return This

		def RemoveLeadingRepeatedCharsCS(pCaseSensitive)
			This.RemoveRepeatedLeadingCharsCS(pCaseSensitive)

			def RemoveLeadingRepeatedCharsCSQ(pCaseSensitive)
				This.RemoveLeadingRepeatedCharsCS(pCaseSensitive)
				return This
	
		def RemoveLeadingCharsCS(pCaseSensitive)
			This.RemoveRepeatedLeadingCharsCS(pCaseSensitive)

			def RemoveLeadingCharsCSQ(pCaseSensitive)
				This.RemoveLeadingCharsCS(pCaseSensitive)
				return This
	
	def RepeatedLeadingCharsRemovedCS(pCaseSensitive)
		cResult = This.Copy().RemoveRepeatedLeadingCharsCSQ(pCaseSensitive).Content()
		return cResult

		def LeadingRepeatedCharsRemovedCS(pCaseSensitive)
			return This.RepeatedLeadingCharsRemovedCS(pCaseSensitive)

		def LeadingCharsRemovedCS(pCaseSensitive)
			return This.RepeatedLeadingCharsRemovedCS(pCaseSensitive)

	#-- CASE-INSENSITIVE

	def RemoveRepeatedLeadingChars()
		This.RemoveRepeatedLeadingCharsCS(:CaseSensitive = TRUE)

		def RemoveRepeatedLeadingCharsQ()
			This.RemoveRepeatedLeadingChars()
			return This

		def RemoveLeadingRepeatedChars()
			This.RemoveRepeatedLeadingChars()

			def RemoveLeadingRepeatedCharsQ()
				This.RemoveLeadingRepeatedChars()
				return This
	
		def RemoveLeadingChars()
			This.RemoveRepeatedLeadingChars()

			def RemoveLeadingCharsQ()
				This.RemoveLeadingChars()
				return This
	
	def RepeatedLeadingCharsRemoved()
		cResult = This.Copy().RemoveRepeatedLeadingCharsQ().Content()
		return cResult

		def LeadingRepeatedCharsRemoved()
			return This.RepeatedLeadingCharsRemoved()

		def LeadingCharsRemoved()
			return This.RepeatedLeadingCharsRemoved()

	  #--------------------------------------#
	 #   REMOVING REPEATED TRAILING CHARS   #
	#--------------------------------------#

	def RemoveRepeatedTrailingCharsCS(pCaseSensitive)
		if This.HasRepeatedTrailingCharsCS(pCaseSensitive)
			This.RemoveLastNChars( This.NumberOfRepeatedTrailingCharsCS(pCaseSensitive) )
		ok

		def RemoveRepeatedTrailingCharsCSQ()
			This.RemoveRepeatedTrailingCharsCS(pCaseSensitive)
			return This

		def RemoveTrailingRepeatedCharsCS(pCaseSensitive)
			This.RemoveRepeatedTrailingCharsCS(pCaseSensitive)

			def RemoveTrailingRepeatedCharsCSQ(pCaseSensitive)
				This.RemoveTrailingRepeatedCharsCS(pCaseSensitive)
				return This
	
		def RemoveTrailingCharsCS(pCaseSensitive)
			This.RemoveRepeatedTrailingCharsCS(pCaseSensitive)

			def RemoveTrailingCharsCSQ(pCaseSensitive)
				This.RemoveTrailingCharsCS(pCaseSensitive)
				return This
	
	def RepeatedTrailingCharsRemovedCS(pCaseSensitive)
		cResult = This.Copy().RemoveRepeatedTrailingCharsCSQ(pCaseSensitive).Content()
		return cResult

		def TrailingRepeatedCharsRemovedCS(pCaseSensitive)
			return This.RepeatedTrailingCharsRemovedCS(pCaseSensitive)

		def TrailingCharsRemovedCS(pCaseSensitive)
			return This.RepeatedTrailingCharsRemovedCS(pCaseSensitive)

	#-- CASE-INSENSITIVE

	def RemoveRepeatedTrailingChars()
		This.RemoveRepeatedTrailingCharsCS(:CaseSensitive = TRUE)

		def RemoveRepeatedTrailingCharsQ()
			This.RemoveRepeatedTrailingChars()
			return This

		def RemoveTrailingRepeatedChars()
			This.RemoveRepeatedTrailingChars()

			def RemoveTrailingRepeatedCharsQ()
				This.RemoveTrailingRepeatedChars()
				return This
	
		def RemoveTrailingChars()
			This.RemoveRepeatedTrailingChars()

			def RemoveTrailingCharsQ()
				This.RemoveTrailingChars()
				return This
	
	def RepeatedTrailingCharsRemoved()
		cResult = This.Copy().RemoveRepeatedTrailingCharsQ().Content()
		return cResult

		def TrailingRepeatedCharsRemoved()
			return This.RepeatedTrailingCharsRemoved()

		def TrailingCharsRemoved()
			return This.RepeatedTrailingCharsRemoved()
	
	  #--------------------------------------------#
	 #   REMOVING A GIVEN REPEATED LEADING CHAR   #
	#--------------------------------------------#

	def RemoveThisRepeatedLeadingCharCS(c, pCaseSensitive)
		if This.RepeatedLeadingCharQ().IsEqualToCS(c, pCaseSensitive)
			This.RemoveRepeatedLeadingCharsCS(pCaseSensitive)
		ok

		def RemoveThisRepeatedLeadingCharCSQ(c, pCaseSensitive)
			This.RemoveThisRepeatedLeadingCharCS(c, pCaseSensitive)
			return This

		def RemoveThisLeadingRepeatedCharCS(c, pCaseSensitive)
			This.RemoveThisRepeatedLeadingCharCS(c, pCaseSensitive)

			def RemoveThisLeadingRepeatedCharCSQ(c, pCaseSensitive)
				This.RemoveThisLeadingRepeatedCharCS(c, pCaseSensitive)
				return This

		def RemoveThisLeadingCharCS(c, pCaseSensitive)
			This.RemoveThisRepeatedLeadingCharCS(c, pCaseSensitive)

			def RemoveThisLeadingCharCSQ(c, pCaseSensitive)
				This.RemoveThisLeadingCharCS(c, pCaseSensitive)
				return This

	def ThisRepeatedLeadingCharRemovedCS(c, pCaseSensitive)
		cResult = This.Copy().RemoveThisRepeatedLeadingCharCSQ(c, pCaseSensitive).Content()
		return cResult

		def ThisLeadingRepeatedCharRemovedCS(c, pCaseSensitive)
			return This.ThisRepeatedLeadingCharRemoved(c, pCaseSensitive)

		def ThisLeadingCharRemovedCS(c, pCaseSensitive)
			return This.ThisRepeatedLeadingCharRemoved(c, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def RemoveThisRepeatedLeadingChar(c)
		if This.RepeatedLeadingCharQ().IsEqualTo(c)
			This.RemoveThisRepeatedLeadingCharCS(c, :CaseSensitive = TRUE)
		ok

		def RemoveThisRepeatedLeadingCharQ(c)
			This.RemoveThisRepeatedLeadingChar(c)
			return This

		def RemoveThisLeadingRepeatedChar(c)
			This.RemoveThisRepeatedLeadingChar(c)

			def RemoveThisLeadingRepeatedCharQ(c)
				This.RemoveThisLeadingRepeatedChar(c)
				return This

		def RemoveThisLeadingChar(c)
			This.RemoveThisRepeatedLeadingChar(c)

			def RemoveThisLeadingCharQ(c)
				This.RemoveThisLeadingChar(c)
				return This

	def ThisRepeatedLeadingCharRemoved(c)
		cResult = This.Copy().RemoveThisRepeatedLeadingCharQ(c).Content()
		return cResult

		def ThisLeadingRepeatedCharRemoved(c)
			return This.ThisRepeatedLeadingCharRemoved(c)

		def ThisLeadingCharRemoved(c)
			return This.ThisRepeatedLeadingCharRemoved(c)

	  #---------------------------------------------#
	 #   REMOVING A GIVEN REPEATED TRAILING CHAR   #
	#---------------------------------------------#

	def RemoveThisRepeatedTrailingCharCS(c, pCaseSensitive)
		if This.RepeatedTrailingCharQ().IsEqualToCS(c, pCaseSensitive)
			This.RemoveRepeatedTrailingCharsCS(pCaseSensitive)
		ok

		def RemoveThisRepeatedTrailingCharCSQ(c, pCaseSensitive)
			This.RemoveThisRepeatedTrailingCharCS(c, pCaseSensitive)
			return This

		def RemoveThisTrailingRepeatedCharCS(c, pCaseSensitive)
			This.RemoveThisRepeatedTrailingCharCS(c, pCaseSensitive)

			def RemoveThisTrailingRepeatedCharCSQ(c, pCaseSensitive)
				This.RemoveThisTrailingRepeatedCharCS(c, pCaseSensitive)
				return This

		def RemoveThisTrailingCharCS(c, pCaseSensitive)
			This.RemoveThisRepeatedTrailingCharCS(c, pCaseSensitive)

			def RemoveThisTrailingCharCSQ(c, pCaseSensitive)
				This.RemoveThisTrailingCharCS(c, pCaseSensitive)
				return This

	def ThisRepeatedTrailingCharRemovedCS(c, pCaseSensitive)
		cResult = This.Copy().RemoveThisRepeatedTrailingCharCSQ(c, pCaseSensitive).Content()
		return cResult

		def ThisTrailingRepeatedCharRemovedCS(c, pCaseSensitive)
			return This.ThisRepeatedTrailingCharRemoved(c, pCaseSensitive)

		def ThisTrailingCharRemovedCS(c, pCaseSensitive)
			return This.ThisRepeatedTrailingCharRemoved(c, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def RemoveThisRepeatedTrailingChar(c)
		if This.RepeatedTrailingCharQ().IsEqualTo(c)
			This.RemoveThisRepeatedTrailingCharCS(c, :CaseSensitive = TRUE)
		ok

		def RemoveThisRepeatedTrailingCharQ(c)
			This.RemoveThisRepeatedTrailingChar(c)
			return This

		def RemoveThisTrailingRepeatedChar(c)
			This.RemoveThisRepeatedTrailingChar(c)

			def RemoveThisTrailingRepeatedCharQ(c)
				This.RemoveThisTrailingRepeatedChar(c)
				return This

		def RemoveThisTrailingChar(c)
			This.RemoveThisRepeatedTrailingChar(c)

			def RemoveThisTrailingCharQ(c)
				This.RemoveThisTrailingChar(c)
				return This

	def ThisRepeatedTrailingCharRemoved(c)
		cResult = This.Copy().RemoveThisRepeatedTrailingCharQ(c).Content()
		return cResult

		def ThisTrailingRepeatedCharRemoved(c)
			return This.ThisRepeatedTrailingCharRemoved(c)

		def ThisTrailingCharRemoved(c)
			return This.ThisRepeatedTrailingCharRemoved(c)

	  #--------------------------------------------------------#
	 #   REMOVING GIVEN REPEATED LEADING AND TRAILING CHARS   #
	#--------------------------------------------------------#

	def RemoveTheseRepeatedLeadingAndTrailingCharsCS(c1, c2, pCaseSensitive)
		This.RemoveThisRepeatedLeadingCharCS(c1, pCaseSensitive)
		This.RemoveThisRepeatedTrailingCharCS(c2, pCaseSensitive)
		
		def RemoveTheseRepeatedLeadingAndTrailingCharsCSQ(c1, c2, pCaseSensitive)
			This.RemoveTheseRepeatedLeadingAndTrailingCharsCS(c1, c2, pCaseSensitive)
			return This

		def RemoveTheseLeadingAndRepeatedCharsCS(c1, c2, pCaseSensitive)
			This.RemoveTheseRepeatedLeadingAndTrailingCharsCS(c1, c2, pCaseSensitive)

			def RemoveTheseLeadingAndRepeatedCharsCSQ(c1, c2, pCaseSensitive)
				This.RemoveTheseLeadingAndRepeatedCharsCS(c1, c2, pCaseSensitive)
				return This

		def RemoveTheseLeadingAndTrailingCharsCS(c1, c2, pCaseSensitive)
			This.RemoveTheseRepeatedLeadingAndTrailingCharsCS(c1, c2, pCaseSensitive)

			def RemoveTheseLeadingAndTrailingCharsCSQ(c1, c2, pCaseSensitive)
				This.RemoveTheseLeadingAndTrailingCharsCS(c1, c2, pCaseSensitive)
				return This

	def TheseRepeatedLeadingAndTrailingCharsRemovedCS(c1, c2, pCaseSensitive)
		cResult = This.Copy().RemoveTheseRepeatedLeadingAndTrailingCharsCSQ(c1, c2, pCaseSensitive).Content()
		return cResult

		def TheseLeadingAndRepeatedCharsRemovedCS(c1, c2, pCaseSensitive)
			return This.TheseRepeatedLeadingAndTrailingCharsRemoved(c1, c2, pCaseSensitive)

		def TheseLeadingAndTrailingCharsRemovedCS(c1, c2, pCaseSensitive)
			return This.TheseRepeatedLeadingAndTrailingCharsRemoved(c1, c2, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def RemoveTheseRepeatedLeadingAndTrailingChars(c1, c2)
		This.RemoveTheseRepeatedLeadingAndTrailingCharsCS(c1, c2, :CaseSensitive = TRUE)

		def RemoveTheseRepeatedLeadingAndTrailingCharsQ(c1, c2)
			This.RemoveTheseRepeatedLeadingAndTrailingChars(c1, c2)
			return This

		def RemoveTheseLeadingAndRepeatedChars(c1, c2)
			This.RemoveTheseRepeatedLeadingAndTrailingChars(c1, c2)

			def RemoveTheseLeadingAndRepeatedCharsQ(c1, c2)
				This.RemoveTheseLeadingAndRepeatedChars(c1, c2)
				return This

		def RemoveTheseLeadingAndTrailingChars(c1, c2)
			This.RemoveTheseRepeatedLeadingAndTrailingChars(c1, c2)

			def RemoveTheseLeadingAndTrailingCharsQ(c1, c2)
				This.RemoveTheseLeadingAndTrailingChars(c1, c2)
				return This

	def TheseRepeatedLeadingAndTrailingCharsRemoved(c1, c2)
		cResult = This.Copy().RemoveTheseRepeatedLeadingAndTrailingCharsQ(c1, c2).Content()
		return cResult

		def TheseLeadingAndRepeatedCharsRemoved(c1, c2)
			return This.TheseRepeatedLeadingAndTrailingCharsRemoved(c1, c2)

		def TheseLeadingAndTrailingCharsRemoved(c1, c2)
			return This.TheseRepeatedLeadingAndTrailingCharsRemoved(c1, c2)
	
	  #-----------------------------#
	 #   REPLACING LEADING CHARS   #
	#-----------------------------#

	def ReplaceRepeatedLeadingCharsCS(cNewSubStr, pCaseSensitive)
		#< @MotherFunction = This.ReplaceSection() > @QtBased = TRUE #>

		/* Example:

		StzStringQ("aaaAAAH RING!").
		ReplaceRepeatedLeadingCharsCS( :With = "O", :CS = TRUE)
		--> Gives: "OOOAAAH RING!"

		StzStringQ("aaaAVAR").
		ReplaceRepeatedLeadingCharsCS( :With = "O", :CS = FALSE)
		--> Gives: "OOOOOOH RING!"

		*/

		if isList(cNewSubStr) and StzListQ(cNewSubStr).IsWithOrByParamList()
			cNewSubStr = cNewSubStr[2]
		ok

		n = This.NumberOfRepeatedLeadingCharsCS(pCaseSensitive)

		if n > 0
			This.ReplaceSection(
				1, n,
				StzStringQ(cNewSubStr).RepeatedNTimes(n)
			)
		ok

		#< @FunctionFluentForm


		def ReplaceRepeatedLeadingCharsCSQ(cNewSubStr, pCaseSensitive)
			This.ReplaceRepeatedLeadingCharsCS(cNewSubStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceLeadingCharsCS(cNewSubStr, pCaseSensitive)
			This.ReplaceRepeatedLeadingCharsCS(cNewSubStr, pCaseSensitive)

			def ReplaceLeadingCharsCSQ(cNewSubStr, pCaseSensitive)
				This.ReplaceLeadingCharsCS(cNewSubStr, pCaseSensitive)
				return This

		def ReplaceLeadingRepeatedCharsCS(cNewSubStr, pCaseSensitive)
			This.ReplaceRepeatedLeadingCharsCS(cNewSubStr, pCaseSensitive)

			def ReplaceLeadingRepeatedCharsCSQ(cNewSubStr, pCaseSensitive)
				This.ReplaceLeadingRepeatedCharsCS(cNewSubStr, pCaseSensitive)
				return This
		#>

	def RepeatedLeadingCharsReplacedCS(cNewSubStr, pCaseSensitive)
		cResult = This.
			  Copy().
			  ReplaceRepeatedLeadingCharsCSQ(cNewSubStr, pCaseSensitive).
			  Content()

		return cResult

		def LeadingCharsReplacedCS(cNewSubStr, pCaseSensitive)
			return This.RepeatedLeadingCharsReplacedCS(cNewSubStr, pCaseSensitive)

		def LeadingRepeatedCharsReplacedCS(cNewSubStr, pCaseSensitive)
			return This.RepeatedLeadingCharsReplacedCS(cNewSubStr, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def ReplaceRepeatedLeadingChars(cNewSubStr)

		This.ReplaceRepeatedLeadingCharsCS(cNewSubStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceRepeatedLeadingCharsQ(cNewSubStr)
			This.ReplaceRepeatedLeadingChars(cNewSubStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceLeadingChars(cNewSubStr)
			This.ReplaceRepeatedLeadingChars(cNewSubStr)

			def ReplaceLeadingCharsQ(cNewSubStr)
				This.ReplaceLeadingChars(cNewSubStr)
				return This

		def ReplaceLeadingRepeatedChars(cNewSubStr)
			This.ReplaceRepeatedLeadingChars(cNewSubStr)

			def ReplaceLeadingRepeatedCharsQ(cNewSubStr)
				This.ReplaceLeadingRepeatedChars(cNewSubStr)
				return This
		#>

	def RepeatedLeadingCharsReplaced(cNewSubStr)
		cResult = This.
			  Copy().
			  ReplaceRepeatedLeadingCharsQ(cNewSubStr).
			  Content()

		return cResult

		def LeadingCharsReplaced(cNewSubStr)
			return This.RepeatedLeadingCharsReplaced(cNewSubStr)

		def LeadingRepeatedCharsReplaced(cNewSubStr)
			return This.RepeatedLeadingCharsReplaced(cNewSubStr)

	  #------------------------------#
	 #   REPLACING TRAILING CHARS   #
	#------------------------------#

	def ReplaceRepeatedTrailingCharsCS(cNewSubStr, pCaseSensitive)
		#< @MotherFunction = This.ReplaceSection() > @QtBased = TRUE #>

		/* Example:

		StzStringQ("RINGaaaAAA").
		ReplaceRepeatedTrailingCharsCS( :With = "O", :CS = TRUE)
		--> Gives: "RINGaaaOOO"

		StzStringQ("RINGaaaAAA").
		ReplaceRepeatedTrailingCharsCS( :With = "O", :CS = FALSE)
		--> Gives: "RINGOOOOOO"

		*/

		if isList(cNewSubStr) and StzListQ(cNewSubStr).IsWithOrByParamList()
			cNewSubStr = cNewSubStr[2]
		ok

		n = This.NumberOfRepeatedTrailingCharsCS(pCaseSensitive)

		if n > 0
			nStart = This.NumberOfChars() - n + 1
			This.ReplaceSection(
				nStart, This.NumberOfChars(),
				StzStringQ(cNewSubStr).RepeatedNTimes(n)
			)
		ok

		#< @FunctionFluentForm


		def ReplaceRepeatedTrailingCharsCSQ(cNewSubStr, pCaseSensitive)
			This.ReplaceRepeatedTrailingCharsCS(cNewSubStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceTrailingCharsCS(cNewSubStr, pCaseSensitive)
			This.ReplaceRepeatedTrailingCharsCS(cNewSubStr, pCaseSensitive)

			def ReplaceTrailingCharsCSQ(cNewSubStr, pCaseSensitive)
				This.ReplaceTrailingCharsCS(cNewSubStr, pCaseSensitive)
				return This

		def ReplaceTrailingRepeatedCharsCS(cNewSubStr, pCaseSensitive)
			This.ReplaceRepeatedTrailingCharsCS(cNewSubStr, pCaseSensitive)

			def ReplaceTrailingRepeatedCharsCSQ(cNewSubStr, pCaseSensitive)
				This.ReplaceTrailingRepeatedCharsCS(cNewSubStr, pCaseSensitive)
				return This
		#>

	def RepeatedTrailingCharsReplacedCS(cNewSubStr, pCaseSensitive)
		cResult = This.
			  Copy().
			  ReplaceRepeatedTrailingCharsCSQ(cNewSubStr, pCaseSensitive).
			  Content()

		return cResult

		def TrailingCharsReplacedCS(cNewSubStr, pCaseSensitive)
			return This.RepeatedTrailingCharsReplacedCS(cNewSubStr, pCaseSensitive)

		def TrailingRepeatedCharsReplacedCS(cNewSubStr, pCaseSensitive)
			return This.RepeatedTrailingCharsReplacedCS(cNewSubStr, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def ReplaceRepeatedTrailingChars(cNewSubStr)

		This.ReplaceRepeatedTrailingCharsCS(cNewSubStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceRepeatedTrailingCharsQ(cNewSubStr)
			This.ReplaceRepeatedTrailingChars(cNewSubStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceTrailingChars(cNewSubStr)
			This.ReplaceRepeatedTrailingChars(cNewSubStr)

			def ReplaceTrailingCharsQ(cNewSubStr)
				This.ReplaceTrailingChars(cNewSubStr)
				return This

		def ReplaceTrailingRepeatedChars(cNewSubStr)
			This.ReplaceRepeatedTrailingChars(cNewSubStr)

			def ReplaceTrailingRepeatedCharsQ(cNewSubStr)
				This.ReplaceTrailingRepeatedChars(cNewSubStr)
				return This
		#>

	def RepeatedTrailingCharsReplaced(cNewSubStr)
		cResult = This.
			  Copy().
			  ReplaceRepeatedTrailingCharsQ(cNewSubStr).
			  Content()

		return cResult

		def TrailingCharsReplaced(cNewSubStr)
			return This.RepeatedTrailingCharsReplaced(cNewSubStr)

		def TrailingRepeatedCharsReplaced(cNewSubStr)
			return This.RepeatedTrailingCharsReplaced(cNewSubStr)

	  #---------------------------------------------------#
	 #   REPLACING REPEATED LEADING AND TRAILING CHARS   #
	#---------------------------------------------------#
	
	def ReplaceRepeatedLeadingAndTrailingCharsCS(cNewSubStr, pCaseSensitive)
		This.ReplaceRepeatedLeadingCharsCS(cNewSubStr, pCaseSensitive)
		This.ReplaceRepeatedTrailingCharsCS(cNewSubStr, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplaceRepeatedLeadingAndTrailingCharsCSQ(cNewSubStr, pCaseSensitive)
			This.ReplaceRepeatedLeadingAndTrailingCharsCS(cNewSubStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceRepeatedTrailingAndLeadingCharsCS(cNewSubStr, pCaseSensitive)
			This.ReplaceRepeatedLeadingAndTrailingCharsCS(cNewSubStr, pCaseSensitive)

			def ReplaceRepeatedTrailingAndLeadingCharsCSQ(cNewSubStr, pCaseSensitive)
				This.ReplaceRepeatedTrailingAndLeadingCharsCS(cNewSubStr, pCaseSensitive)
				return This

		def ReplaceLeadingAndTrailingCharsCS(cNewSubStr, pCaseSensitive)
			This.ReplaceRepeatedLeadingAndTrailingCharsCS(cNewSubStr, pCaseSensitive)

			def ReplaceLeadingAndTrailingCharsCSQ(cNewSubStr, pCaseSensitive)
				This.ReplaceLeadingAndTrailingCharsCS(cNewSubStr, pCaseSensitive)
				return This

		def ReplaceTrailingAndLeadingCharsCS(cNewSubStr, pCaseSensitive)
			This.ReplaceRepeatedTrailingAndLeadingCharsCS(cNewSubStr, pCaseSensitive)

			def ReplaceTrailingAndLeadingCharsCSQ(cNewSubStr, pCaseSensitive)
				This.ReplaceTrailingAndLeadingCharsCS(cNewSubStr, pCaseSensitive)
				return This

		def ReplaceLeadingAndTrailingRepeatedCharsCS(cNewSubStr, pCaseSensitive)
			This.ReplaceRepeatedLeadingAndTrailingCharsCS(cNewSubStr, pCaseSensitive)

			def ReplaceLeadingAndTrailingRepeatedCharsCSQ(cNewSubStr, pCaseSensitive)
				This.ReplaceLeadingAndTrailingRepeatedCharsCS(cNewSubStr, pCaseSensitive)
				return This

		def ReplaceTrailingAndLeadingRepeatedCharsCS(cNewSubStr, pCaseSensitive)
			This.ReplaceRepeatedTrailingAndLeadingCharsCS(cNewSubStr, pCaseSensitive)

			def ReplaceTrailingAndLeadingRepeatedCharsCSQ(cNewSubStr, pCaseSensitive)
				This.ReplaceTrailingAndLeadingRepeatedCharsCS(cNewSubStr, pCaseSensitive)
				return This
		#>

	def RepeatedLeadingAndTrailingCharsReplacedCS(cNewSubStr, pCaseSensitive)
		cResult = This.
			  Copy().
			  ReplaceRepeatedLeadingAndTrailingCharsCSQ(cNewSubStr, pCaseSensitive).
			  Content()

		return cResult

		def RepeatedTrailingAndLeadingCharsReplacedCS(cNewSubStr, pCaseSensitive)
			return This.RepeatedLeadingAndTrailingCharsReplacedCS(cNewSubStr, pCaseSensitive)

		def LeadingAndTrailingCharsReplacedCS(cNewSubStr, pCaseSensitive)
			return This.RepeatedLeadingAndTrailingCharsReplacedCS(cNewSubStr, pCaseSensitive)

		def TrailingAndLeadingCharsReplacedCS(cNewSubStr, pCaseSensitive)
			return This.RepeatedTrailingAndLeadingCharsReplacedCS(cNewSubStr, pCaseSensitive)

		def LeadingAndTrailingRepeatedCharsReplacedCS(cNewSubStr, pCaseSensitive)
			return This.RepeatedLeadingAndTrailingCharsReplacedCS(cNewSubStr, pCaseSensitive)

		def TrailingAndLeadingRepeatedCharsReplacedCS(cNewSubStr, pCaseSensitive)
			return This.RepeatedTrailingAndLeadingCharsReplacedCS(cNewSubStr, pCaseSensitive)

	#-- CASE-INSENSITIVE

		def ReplaceRepeatedLeadingAndTrailingChars(cNewSubStr)
		This.ReplaceRepeatedLeadingChars(cNewSubStr)
		This.ReplaceRepeatedTrailingChars(cNewSubStr)

		#< @FunctionFluentForm

		def ReplaceRepeatedLeadingAndTrailingCharsQ(cNewSubStr)
			This.ReplaceRepeatedLeadingAndTrailingChars(cNewSubStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceRepeatedTrailingAndLeadingChars(cNewSubStr)
			This.ReplaceRepeatedLeadingAndTrailingChars(cNewSubStr)

			def ReplaceRepeatedTrailingAndLeadingCharsQ(cNewSubStr)
				This.ReplaceRepeatedTrailingAndLeadingChars(cNewSubStr)
				return This

		def ReplaceLeadingAndTrailingChars(cNewSubStr)
			This.ReplaceRepeatedLeadingAndTrailingChars(cNewSubStr)

			def ReplaceLeadingAndTrailingCharsQ(cNewSubStr)
				This.ReplaceLeadingAndTrailingChars(cNewSubStr)
				return This

		def ReplaceTrailingAndLeadingChars(cNewSubStr)
			This.ReplaceRepeatedTrailingAndLeadingChars(cNewSubStr)

			def ReplaceTrailingAndLeadingCharsQ(cNewSubStr)
				This.ReplaceTrailingAndLeadingChars(cNewSubStr)
				return This

		def ReplaceLeadingAndTrailingRepeatedChars(cNewSubStr)
			This.ReplaceRepeatedLeadingAndTrailingChars(cNewSubStr)

			def ReplaceLeadingAndTrailingRepeatedCharsQ(cNewSubStr)
				This.ReplaceLeadingAndTrailingRepeatedChars(cNewSubStr)
				return This

		def ReplaceTrailingAndLeadingRepeatedChars(cNewSubStr)
			This.ReplaceRepeatedTrailingAndLeadingChars(cNewSubStr)

			def ReplaceTrailingAndLeadingRepeatedCharsQ(cNewSubStr)
				This.ReplaceTrailingAndLeadingRepeatedChars(cNewSubStr)
				return This
		#>

	def RepeatedLeadingAndTrailingCharsReplaced(cNewSubStr)
		cResult = This.
			  Copy().
			  ReplaceRepeatedLeadingAndTrailingCharsQ(cNewSubStr).
			  Content()

		return cResult

		def RepeatedTrailingAndLeadingCharsReplaced(cNewSubStr)
			return This.RepeatedLeadingAndTrailingCharsReplaced(cNewSubStr)

		def LeadingAndTrailingCharsReplaced(cNewSubStr)
			return This.RepeatedLeadingAndTrailingCharsReplaced(cNewSubStr)

		def TrailingAndLeadingCharsReplaced(cNewSubStr)
			return This.RepeatedTrailingAndLeadingCharsReplaced(cNewSubStr)

		def LeadingAndTrailingRepeatedCharsReplaced(cNewSubStr)
			return This.RepeatedLeadingAndTrailingCharsReplaced(cNewSubStr)

		def TrailingAndLeadingRepeatedCharsReplaced(cNewSubStr)
			return This.RepeatedTrailingAndLeadingCharsReplaced(cNewSubStr)

	  #---------------------------------------------#
	 #   REPLACING A GIVEN REPEATED LEADING CHAR   #
	#---------------------------------------------#

	def ReplaceThisRepeatedLeadingCharCS(c, cNewSubStr, pCaseSensitive)
		#< @MotherFunction = This.ReplaceSection() > @QtBased = TRUE #>

		if isList(cNewSubStr) and StzListQ(cNewSubStr).IsWithOrByParamList()
			cNewSubStr = cNewSubStr[2]
		ok

		if This.RepeatedLeadingCharQ().IsEqualToCS(c, pCaseSensitive)
			This.ReplaceRepeatedLeadingCharsCS(cNewSubStr, pCaseSensitive)
		ok

		#< @FunctionFluentForm


		def ReplaceThisRepeatedLeadingCharCSQ(c, cNewSubStr, pCaseSensitive)
			This.ReplaceThisRepeatedLeadingCharCS(c, cNewSubStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceThisLeadingCharCS(c, cNewSubStr, pCaseSensitive)
			This.ReplaceThisRepeatedLeadingCharCS(c, cNewSubStr, pCaseSensitive)

			def ReplaceThisLeadingCharCSQ(c, cNewSubStr, pCaseSensitive)
				This.ReplaceThisLeadingCharCS(c, cNewSubStr, pCaseSensitive)
				return This

		def ReplaceThisLeadingRepeatedCharCS(c, cNewSubStr, pCaseSensitive)
			This.ReplaceThisRepeatedLeadingCharCS(c, cNewSubStr, pCaseSensitive)

			def ReplaceThisLeadingRepeatedCharCSQ(c, cNewSubStr, pCaseSensitive)
				This.ReplaceThisLeadingRepeatedCharCS(c, cNewSubStr, pCaseSensitive)
				return This
		#>

	def ThisRepeatedLeadingCharReplacedCS(c, cNewSubStr, pCaseSensitive)
		cResult = This.
			  Copy().
			  ReplaceThisRepeatedLeadingCharCSQ(c, cNewSubStr, pCaseSensitive).
			  Content()

		return cResult

		def ThisLeadingCharReplacedCS(c, cNewSubStr, pCaseSensitive)
			return This.ThisRepeatedLeadingCharReplacedCS(c, cNewSubStr, pCaseSensitive)

		def ThisLeadingRepeatedCharReplacedCS(c, cNewSubStr, pCaseSensitive)
			return This.ThisRepeatedLeadingCharReplacedCS(c, cNewSubStr, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def ReplaceThisRepeatedLeadingChar(c, cNewSubStr)

		This.ReplaceThisRepeatedLeadingCharCS(c, cNewSubStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceThisRepeatedLeadingCharQ(c, cNewSubStr)
			This.ReplaceThisRepeatedLeadingChar(c, cNewSubStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceThisLeadingChar(c, cNewSubStr)
			This.ReplaceThisRepeatedLeadingChar(c, cNewSubStr)

			def ReplaceThisLeadingCharQ(c, cNewSubStr)
				This.ReplaceThisLeadingChar(c, cNewSubStr)
				return This

		def ReplaceThisLeadingRepeatedChar(c, cNewSubStr)
			This.ReplaceThisRepeatedLeadingChar(c, cNewSubStr)

			def ReplaceThisLeadingRepeatedCharQ(c, cNewSubStr)
				This.ReplaceThisLeadingRepeatedChar(c, cNewSubStr)
				return This
		#>

	def ThisRepeatedLeadingCharReplaced(c, cNewSubStr)
		cResult = This.
			  Copy().
			  ReplaceThisRepeatedLeadingCharQ(c, cNewSubStr).
			  Content()

		return cResult

		def ThisLeadingCharReplaced(c, cNewSubStr)
			return This.ThisRepeatedLeadingCharReplaced(c, cNewSubStr)

		def ThisLeadingRepeatedCharReplaced(c, cNewSubStr)
			return This.ThisRepeatedLeadingCharReplaced(c, cNewSubStr)

	  #----------------------------------------------#
	 #   REPLACING A GIVEN REPEATED TRAILING CHAR   #
	#----------------------------------------------#

	def ReplaceThisRepeatedTrailingCharCS(c, cNewSubStr, pCaseSensitive)
		#< @MotherFunction = This.ReplaceSection() > @QtBased = TRUE #>

		if isList(cNewSubStr) and StzListQ(cNewSubStr).IsWithOrByParamList()
			cNewSubStr = cNewSubStr[2]
		ok

		if This.RepeatedTrailingCharQ().IsEqualToCS(c, pCaseSensitive)
			This.ReplaceRepeatedTrailingCharsCS(cNewSubStr, pCaseSensitive)
		ok

		#< @FunctionFluentForm


		def ReplaceThisRepeatedTrailingCharCSQ(c, cNewSubStr, pCaseSensitive)
			This.ReplaceThisRepeatedTrailingCharCS(c, cNewSubStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceThisTrailingCharCS(c, cNewSubStr, pCaseSensitive)
			This.ReplaceThisRepeatedTrailingCharCS(c, cNewSubStr, pCaseSensitive)

			def ReplaceThisTrailingCharCSQ(c, cNewSubStr, pCaseSensitive)
				This.ReplaceThisTrailingCharCS(c, cNewSubStr, pCaseSensitive)
				return This

		def ReplaceThisTrailingRepeatedCharCS(c, cNewSubStr, pCaseSensitive)
			This.ReplaceThisRepeatedTrailingCharCS(c, cNewSubStr, pCaseSensitive)

			def ReplaceThisTrailingRepeatedCharCSQ(c, cNewSubStr, pCaseSensitive)
				This.ReplaceThisTrailingRepeatedCharCS(c, cNewSubStr, pCaseSensitive)
				return This
		#>

	def ThisRepeatedTrailingCharReplacedCS(c, cNewSubStr, pCaseSensitive)
		cResult = This.
			  Copy().
			  ReplaceThisRepeatedTrailingCharCSQ(c, cNewSubStr, pCaseSensitive).
			  Content()

		return cResult

		def ThisTrailingCharReplacedCS(c, cNewSubStr, pCaseSensitive)
			return This.ThisRepeatedTrailingCharReplacedCS(c, cNewSubStr, pCaseSensitive)

		def ThisTrailingRepeatedCharReplacedCS(c, cNewSubStr, pCaseSensitive)
			return This.ThisRepeatedTrailingCharReplacedCS(c, cNewSubStr, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def ReplaceThisRepeatedTrailingChar(c, cNewSubStr)

		This.ReplaceThisRepeatedTrailingCharCS(c, cNewSubStr, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceThisRepeatedTrailingCharQ(c, cNewSubStr)
			This.ReplaceThisRepeatedTrailingChar(c, cNewSubStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceThisTrailingChar(c, cNewSubStr)
			This.ReplaceThisRepeatedTrailingChar(c, cNewSubStr)

			def ReplaceThisTrailingCharQ(c, cNewSubStr)
				This.ReplaceThisTrailingChar(c, cNewSubStr)
				return This

		def ReplaceThisTrailingRepeatedChar(c, cNewSubStr)
			This.ReplaceThisRepeatedTrailingChar(c, cNewSubStr)

			def ReplaceThisTrailingRepeatedCharQ(c, cNewSubStr)
				This.ReplaceThisTrailingRepeatedChar(c, cNewSubStr)
				return This
		#>

	def ThisRepeatedTrailingCharReplaced(c, cNewSubStr)
		cResult = This.
			  Copy().
			  ReplaceThisRepeatedTrailingCharQ(c, cNewSubStr).
			  Content()

		return cResult

		def ThisTrailingCharReplaced(c, cNewSubStr)
			return This.ThisRepeatedTrailingCharReplaced(c, cNewSubStr)

		def ThisTrailingRepeatedCharReplaced(c, cNewSubStr)
			return This.ThisRepeatedTrailingCharReplaced(c, cNewSubStr)

	  #---------------------------------------------------------#
	 #   REPLACING GIVEN REPEATED LEADING AND TRAILING CHARS   #
	#---------------------------------------------------------#

	def ReplaceTheseRepeatedLeadingAndTrailingCharsCS(c1, c2, cNewSubStr, pCaseSensitive)
	
		This.ReplaceThisRepeatedLeadingCharCS(c1, cNewSubStr, pCaseSensitive)
		This.ReplaceThisRepeatedTrailingCharCS(c2, cNewSubStr, pCaseSensitive)

		#< @FunctionFluentForm

		def ReplaceTheseRepeatedLeadingAndTrailingCharsCSQ(c1, c2, cNewSubStr, pCaseSensitive)
			This.ReplaceTheseRepeatedTrailingCharsCS(c1, c2, cNewSubStr, pCaseSensitive)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceTheseRepeatedTrailingAndLeadingCharsCS(c1, c2, cNewSubStr, pCaseSensitive)
			This.ReplaceTheseRepeatedLeadingAndTrailingCharsCS(c1, c2, cNewSubStr, pCaseSensitive)

			def ReplaceTheseRepeatedTrailingAndLeadingCharsCSQ(c1, c2, cNewSubStr, pCaseSensitive)
				This.ReplaceTheseRepeatedTrailingAndLeadingCharsCS(c1, c2, cNewSubStr, pCaseSensitive)
				return This

		def ReplaceTheseLeadingAndTrailingCharsCS(c1, c2, cNewSubStr, pCaseSensitive)
			This.ReplaceTheseRepeatedLeadingAndTrailingCharsCS(c1, c2, cNewSubStr, pCaseSensitive)

			def ReplaceTheseLeadingAndTrailingCharsCSQ(c1, c2, cNewSubStr, pCaseSensitive)
				This.ReplaceTheseLeadingAndTrailingCharsCS(c1, c2, cNewSubStr, pCaseSensitive)
				return This

		def ReplaceTheseTraingAndLeadingCharsCS(c1, c2, cNewSubStr, pCaseSensitive)
			This.ReplaceTheseRepeatedLeadingAndTrailingCharsCS(c1, c2, cNewSubStr, pCaseSensitive)

			def ReplaceTheseTraingAndLeadingCharsCSQ(c1, c2, cNewSubStr, pCaseSensitive)
				This.ReplaceTheseTraingAndLeadingCharsCS(c1, c2, cNewSubStr, pCaseSensitive)
				return This

		#>

	def TheseRepeatedLeadingAndTrailingCharsReplacedCS(c1, c2, cNewSubStr, pCaseSensitive)
		cResult = This.
			  Copy().
			  ReplaceTheseRepeatedLeadingAndTrailingCharsCSQ(c1, c2, cNewSubStr, pCaseSensitive).
			  Content()

		return cResult

		def TheseRepeatedTrailingAndLeadingCharsReplacedCS(c1, c2, cNewSubStr, pCaseSensitive)
			return This.TheseRepeatedLeadingAndTrailingCharsReplacedCS(c1, c2, cNewSubStr, pCaseSensitive)

		def TheseLeadingAndTrailingCharsReplacedCS(c1, c2, cNewSubStr, pCaseSensitive)
			return This.TheseRepeatedLeadingAndTrailingCharsReplacedCS(c1, c2, cNewSubStr, pCaseSensitive)

		def TheseTrailingAndLeadingCharsReplacedCS(c1, c2, cNewSubStr, pCaseSensitive)
			return This.TheseRepeatedLeadingAndTrailingCharsReplacedCS(c1, c2, cNewSubStr, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def ReplaceTheseRepeatedLeadingAndTrailingChars(c1, c2, cNewSubStr)
	
		This.ReplaceTheseRepeatedLeadingAndTrailingCharsCS(c1, c2, cNewSubStr, :CaseSensitive = TRUE)
	

		#< @FunctionFluentForm

		def ReplaceTheseRepeatedLeadingAndTrailingCharsQ(c1, c2, cNewSubStr)
			This.ReplaceTheseRepeatedTrailingChars(c1, c2, cNewSubStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceTheseRepeatedTrailingAndLeadingChars(c1, c2, cNewSubStr)
			This.ReplaceTheseRepeatedLeadingAndTrailingChars(c1, c2, cNewSubStr)

			def ReplaceTheseRepeatedTrailingAndLeadingCharsQ(c1, c2, cNewSubStr)
				This.ReplaceTheseRepeatedTrailingAndLeadingChars(c1, c2, cNewSubStr)
				return This

		def ReplaceTheseLeadingAndTrailingChars(c1, c2, cNewSubStr)
			This.ReplaceTheseRepeatedLeadingAndTrailingChars(c1, c2, cNewSubStr)

			def ReplaceTheseLeadingAndTrailingCharsQ(c1, c2, cNewSubStr)
				This.ReplaceTheseLeadingAndTrailingChars(c1, c2, cNewSubStr)
				return This

		def ReplaceTheseTraingAndLeadingChars(c1, c2, cNewSubStr)
			This.ReplaceTheseRepeatedLeadingAndTrailingChars(c1, c2, cNewSubStr)

			def ReplaceTheseTraingAndLeadingCharsQ(c1, c2, cNewSubStr)
				This.ReplaceTheseTraingAndLeadingChars(c1, c2, cNewSubStr)
				return This

		#>

	def TheseRepeatedLeadingAndTrailingCharsReplaced(c1, c2, cNewSubStr)
		cResult = This.
			  Copy().
			  ReplaceTheseRepeatedLeadingAndTrailingCharsQ(c1, c2, cNewSubStr).
			  Content()

		return cResult

		def TheseRepeatedTrailingAndLeadingCharsReplaced(c1, c2, cNewSubStr)
			return This.TheseRepeatedLeadingAndTrailingCharsReplaced(c1, c2, cNewSubStr)

		def TheseLeadingAndTrailingCharsReplaced(c1, c2, cNewSubStr)
			return This.TheseRepeatedLeadingAndTrailingCharsReplaced(c1, c2, cNewSubStr)

		def TheseTrailingAndLeadingCharsReplaced(c1, c2, cNewSubStr)
			return This.TheseRepeatedLeadingAndTrailingCharsReplaced(c1, c2, cNewSubStr)

	  #-------------------------------#
	 #     FORWARD TO END OF LINE    #
        #-------------------------------#

	def ForwardToEndOfLine(nStart)

		if isList(nStart) and len(nStart) = 2 and
		   nStart[1] = :StartingAt and isNumber(nStart[2])

			nStart = nStart[2]

		ok

		if nStart < 1 or nStart > This.NumberOfChars()
			return NULL
		ok

		bInside = TRUE
		cResult = ""
		i = nStart - 1

		while bInside
			i++
						 
			if i = This.NumberOfChars() or
			   This.CharAtQ(i).IsLineSeparator()
			   
				bInside = FALSE

			else
				cResult += This.NthChar(i)
			ok	
		end

		return cResult

		#< @FunctionFluentForm
	
		def ForwardToEndOfLineQ(nStart)
			return new stzString( This.ForwardToEndOfLine(nStart) )
	
		#>

	  #----------------------------------#
	 #     BACKWARD TO START OF LINE    #
        #----------------------------------#

	def BackwardToStartOfLine( nStart )

		/* Example:
	
			o1 = new stzString( "Mohammed Ali
				Ben Salah" )
			? o1.BackwardToStartOfLine( :StartingAt = 16 ) # --> Ben
			
		*/

		# Enabling the :StartingAt syntax

		if isList(nStart) and len(nStart) = 2 and
		   nStart[1] = :StartingAt and isNumber(nStart[2])

			nStart = nStart[2]

		ok

		# Checking the range of possible values for nStart param

		if nStart < 1 or nStart > This.NumberOfChars()
			return NULL
		ok

		# Computing the rest of the line

		bInside = TRUE
		cResult = ""
		i = nStart + 1

		while bInside
			i--
					 
			if i = 0 or This.CharAtQ(i).IsLineSeparator()

				bInside = FALSE
			
			else
				cResult += This.NthChar(i)
			ok
				
		end

		return StringReverse(cResult)

		#< @FunctionFluentForm

		def BackwardToStartOfLineQ( nStart )
			return new stzString( This.BackToStartOfLine( nStart ) )
	
		#>

	  #--------------------------------#
	 #   SECTION (OR SLICE) & RANGE   #
	#--------------------------------#

	// Returns a subset of the string between n1 and n2 positions
	def Section(n1, n2)

		if isList(n1) and StzListQ(n1).IsFromParamList()
			n1 = n1[2]
		ok

		if isList(n2) and StzListQ(n2).IsToParamList()
			n2 = n2[2]
		ok

		# If the params are strings then interpret them as numbers

		if n1 = :FirstChar or n1 = :StartOfString
			 n1 = 1
		ok

		if n2 = :LastChar or n2 = :EndOfString
			n2 = This.NumberOfChars()
		ok

		if NOT BothAreNumbers(n1, n2)
			stzRaise("Incorrect params! n1 and n2 should be numbers and n1 <= n2.")
		ok

		if n1 > n2
			nTemp = n1
			n1 = n2
			n2 = nTemp
		ok

		if isNumber(n1) and n1 > 0 and n2 = :EndOfSentence
			return This.ToStzText().ForwardToEndOfSentence( :StartingAt = n1 )
		ok

		if isNumber(n1) and n1 > 0 and n2 = :EndOfLine
			return This.ForwardToEndOfLine( :StartingAt = n1 )
		ok

		if isNumber(n1) and n1 > 0 and n2 = :EndOfWord # TODO: should move to stzText?
			return This.ToStzText().ForwardToEndOfWord( :StartingAt = n1 )
		ok
		
		# Now the params are numbers, let's fix any anomaly

		if n1 = 0 or n2 = 0
			return NULL
		ok

		if n1 < 0
			n1 = -n1
			n1 = This.NumberOfChars() - n1 + 1
		ok
	
		if n2 < 0
			n2 = -n2
			n2 = This.NumberOfChars() - n2 + 1
		ok

		if n1 > n2
			nTemp = n1
			n1 = n2
			n2 = nTemp
		ok

		# Finally, we're ready to extract the section

		return @oQString.mid( (n1 - 1) , (n2 - n1 + 1) )

		#< @FunctionFluentForm

		def SectionQ(n1, n2)
			return new stzString( This.Section(n1, n2) )

		#>

		#< @FunctionAlternativeForm

		def Slice(n1, n2)
			return This.Section(n1, n2)

			#< @FunctionFluentForm

			def SliceQ(n1, n2)
				return This.SectionQ(n1, n2)

			#>
		#>	

	// Returns a subset of the string starting from nStart and ranging over nRange Chars
	def Range(nStartPos, nRange)
		
		if nRange = 0
			return NULL
		else
			return Section( nStartPos, nStartPos + nRange -1 )
		ok

		#< @FunctionFluentForm

		def RangeQ(nStartPos, nRange)
			return new stzString( This.Range(nStartPos, nRange) )
	
		#>

		#< @FunctionNamedParamForm

		def nmdRange(paParams)
			
			// Default values
			nStartPos = 1
			nRange = This.NumberOfChars()

			// Reading the params
			if StzListQ(paParams).IsRangeParamList()
				if isNumber(paParams[ :Start ])
					nStartPos = paParams[ :Start ]
				ok

				if isNumber(paParams[ :Range ])
					nRange = paParams[ :Range ]
				ok

				return This.Range(nStartPos, nRange)
			else
				stzRaise("Incorrect params!")
			ok

		#>

		#< @FunctionInfoForm

		def infRange()
			return [
				:Syntax = "Range(pnstart, pnRange)",
				:Description = "Returns pnRange chars starting at pnStart position",
				:ReturnType = "STRING",
				:NumberOfParams = 2,
				:Params = [
					[
						:Param = "pnStart",
						:Type = "NUMBER",
						:Description = "Start position",
						:Default = 1
					],
					[
						:Param = "pnRange",
						:Type = "NUMBER",
						:Description = "Number of chars of the range",
						:Default = This.NumberOfChars()
					]
				]
			]
		#>

		#< @FunctionDefaultForm

		def dftRange()
			return This.nmdRange([ :Start = 1, :Range = This.NumberOfChars() ])

		#>

		#< @FunctionExampleForm

		def expRange()
			return 	'StzStringQ("Ring programming language").Range(6, 11)' + NL +
				'--> "programming"'

		#>

		#< @FunctionRandomForm

		def rndRange()
			nStart = random( This.NumberOfChars() )
			nRange = random( This.NumberOfChars() - nStart )

			return 	'This.Range(' + nStart + ', ' + nRange + ')' + NL +
				'--> ' + This.Range(nStart, nRange)

		#>

		#< @FunctionTestForm

		def tstRange()
			nCases = This.tstRangeXT()[ :NumberOfTestCases ]
			nSucceeded = This.tstRangeXT()[ :NumberOfSuccessfulCases ]
			nFailed = This.tstRangeXT()[ :NumberOfFailedCases ]


			if nCases = 0
				return "Failed! (" + nFailed + "/" + nCases + ")"

			but nFailed = 0
				return "SUCCESS! (" + nSucceeded + "/" + nCases + ")"
			ok

			if nSucceeded != 0
				return "FAILED! (" + nFailed + "/" + nCases + ")"
			ok

		def tstRangeXT()
			aTestCases = [
			['StzStringQ("Ringorialand").Range(9, 4)' , 'land'],
			['StzStringQ("Ringorialand").Range(1, 4)' , 'Ring'],
			['StzStringQ("Ringorialand").Range(4, 6)' , 'gorial']
			]

			aSucceeded = []
			aFailed = []
			i = 0

			for aTest in aTestCases
				i++
				cCode = "cResult = " + aTest[1]

				try
					 eval(cCode)

					if cResult = aTest[2]
						aSucceeded + i
					else
						aFailed + i
					ok
				catch
					aFailed + i
				done
			next
			
			aResult = [
				:NumberOfTestCases = len(aTestCases),
				:NumberOfSuccessfulCases = len(aSucceeded),
				:NumberOfFailedCases = len(aFailed),

				:SuccessfulCases = aSucceeded,
				:FailedCases = aFailed,

				:TestCases = aTestCases
			]

			return aResult

		#>

	  #----------------------------------------#
	 #   MANY SECTIONS (OR SLICES) & RANGES   #
	#----------------------------------------#

	def Sections(paSections)
		aResult = []

		for aSection in paSections
			aResult + This.Section( aSection[1], aSection[2] )
		next

		return aResult

		def ManySections(paSections)
			return This.Sections(paSections)

		def Slices(paSections)
			return This.Sections(paSections)

		def ManySlices(paSections)
			return This.Sections(paSections)

	def Ranges(paRanges)
		aResult = []

		for aRange in paRanges
			aResult + This.Range( aRange[1], aRange[2] )
		next

		return aResult

		def ManyRanges(paSections)
			return This.Ranges(paRanges)

	  #----------------------------#
	 #    REPEATING THE STRING    #
	#----------------------------#

	// Repeats the string n times
	def RepeatNTimes(n)
		if n != 0
			This.Update( @oQString.repeated(n) )
		ok

		#< @FunctionFluentForm

		def RepeatNTimesQ(n)
			This.RepeatNTimes(n)
			return This

		#>

	def RepeatedNTimes(n)
		cResult = This.Copy().RepeatNTimesQ(n).Content()
		return cResult

		def RepeatedNTimesQ(n)
			return new stzString( This.RepeatedNTimes(n) )
	
	  #----------------------------------------------------#
	 #    INSERTING A SUBSTRING BEFORE A GIVEN POSITION   #
	#----------------------------------------------------#

	/* Inserts a substring:

	 	- in a given position inside the string
	 	  Note: in this case, if nPos > NumberOfChars()
		  --> string is extended with white spaces

		- or, before the occurrence of a given substring
	*/
	 
	def InsertBefore(nPos, pcSubStr)
		@oQString.insert(nPos-1, pcSubStr)

		# The string has changed, check constraints...
		//This.VerifyConstraints()

		#< @FunctionFluentForm
		
		def InsertBeforeQ(nPos, pcSubStr)
			This.InsertBefore(nPos, pcSubStr)
			return This

		#>

		#< @FunctionAlternativeForm

		def InsertBeforePosition(nPos, pcSubStr)
			This.InsertBefore(nPos, pcSubStr)

			def InsertBeforePositionQ(nPos, pcSubStr)
				This.InsertBeforePosition(nPos, pcSubStr)
				return This
		#>

	   #--------------------------------------------------------#
	  #    INSERTING A SUBSTRING BEFORE A POSITION DEFINED     #
	 #    BY A GIVEN CONDITION APPLIED ON THE STRING CHARS    #
	#--------------------------------------------------------#

	def InsertBeforeW( pcCondition, pcSubStr )
		if isList(pcCondition) and StzListQ(pcCondition).IsWhereParamList()
			pcCondition = pcCondition[2]

			if NOT isString(pcCondition)
				stzRaise("Incorrect param type! pcCondition must be a string.")
			ok
		ok

		pcCondition = StzStringQ(pcCondition).ReplaceCSQ("@char", "@item", :CS = FALSE).Content()
		cResult = StzListQ( This.Chars() ).InsertBeforeWQ( pcCondition, pcSubStr ).ToStzListOfStrings().Concatenated()
		This.Update(cResult)

		def InsertBeforeWQ( pcCondition, pcSubStr )
			This.InsertBeforeW( pcCondition, pcSubStr )
			return This

		def InsertBeforeWhere( pcCondition, pcSubStr )
			This.InsertBeforeW( pcCondition, pcSubStr )

			def InsertBeforeWhereQ( pcCondition, pcSubStr )
				This.InsertBeforeWhere( pcCondition, pcSubStr )
				return This

		def InsertBeforeCharAtPosition(nPos, pcSubStr)
			This.InsertBefore(nPos, pcSubStr)

			def InsertBeforeCharAtPositionQ(nPos, pcSubStr)
				This.InsertBeforeCharAtPosition(nPos, pcSubStr)
				return This

	  #----------------------------------------------------#
	 #    INSERTING A SUBSTRING AFTER A GIVEN POSITION    #
	#----------------------------------------------------#

	def InsertAfter(nPos, pcSubStr)
		@oQString.insert(nPos, pcSubStr)

		//VerifyConstraints()

		#< @FunctionFluentForm
		
		def InsertAfterQ(nPos, pcSubStr)
			This.InsertAfter(nPos, pcSubStr)
			return This

		#>

		#< @FunctionAlternativeForm

		def InsertAfterPosition(nPos, pcSubStr)
			This.InsertAfer(nPos, pcSubStr)

			def InsertAfterePositionQ(nPos, pcSubStr)
				This.InsertAfterPosition(nPos, pcSubStr)
				return This

		def InsertAfterCharAtPosition(nPos, pcSubStr)
			This.InsertAfter(nPos, pcSubStr)

			def InsertAfterCharAtPositionQ(nPos, pcSubStr)
				This.InsertAfterCharAtPosition(nPos, pcSubStr)
				return This

		#>

	   #--------------------------------------------------------#
	  #    INSERTING A SUBSTRING AFTER A POSITION DEFINED      #
	 #    BY A GIVEN CONDITION APPLIED ON THE STRING CHARS    #
	#--------------------------------------------------------#

	def InsertAfterW( pcCondition, pcSubStr )
		if isList(pcCondition) and StzListQ(pcCondition).IsWhereParamList()
			pcCondition = pcCondition[2]

			if NOT isString(pcCondition)
				stzRaise("Incorrect param type! pcCondition must be a string.")
			ok
		ok

		pcCondition = StzStringQ(pcCondition).ReplaceCSQ("@char", "@item", :CS = FALSE).Content()

		cResult = This.CharsQ().InsertAfterWQ( pcCondition, pcSubStr ).ToStzListOfStrings().Concatenated()

		This.Update(cResult)

		def InsertAfterWQ( pcCondition, pcSubStr )
			This.InsertAfterW( pcCondition, pcSubStr )
			return This

		def InsertAfterWhere( pcCondition, pcSubStr )
			This.InsertAfterW( pcCondition, pcSubStr )

			def InsertAfterWhereQ( pcCondition, pcSubStr )
				This.InsertAfterWhere( pcCondition, pcSubStr )
				return This

		def InserAfterEachCharW( pcCondition, pcSubStr )
			This.InsertAfterW( pcCondition, pcSubStr )

			def InserAfterEachCharWQ( pcCondition, pcSubStr )
				This.InserAfterEachCharW( pcCondition, pcSubStr )
				return This

	  #------------------------------------------------#
	 #   INSERTING A SUBSTRING AFTER MANY POSITIONS   #
	#------------------------------------------------#

	 def InsertAfterThesePositions(paPositions, pcSubStr)
		if NOT isList(paPositions) and Q(paPositions).IsListOfNumbers()
			stzRaise("Incorrect param! paPositions must be a list of numbers.")
		ok

		if NOT isString(pcSubStr)
			stzRaise("Incorrect param! pcSubStr must be a string.")
		ok

		if NOT len(paPositions) = 0
			anPositions = StzListQ(paPositions).SortedInDescending()
	
			for n in anPositions
				This.InsertAfter(n, pcSubStr)
			next
		ok

	  #-------------------------------------------------#
	 #   INSERTING A SUBSTRING BEFORE MANY POSITIONS   #
	#-------------------------------------------------#

	 def InsertBeforeThesePositions(paPositions, pcSubStr)
		if NOT isList(paPositions) and Q(paPositions).IsListOfNumbers()
			stzRaise("Incorrect param! paPositions must be a list of numbers.")
		ok

		paPositions = StzListOfNumbersQ(paPositions).SubstractFromEachQ(1).Content()
		This.InsertAfterThesePositions(paPositions, pcSubStr)

	  #-------------------------------------#
	 #    INSERTING A LIST OF SUBSTRINGS   #
	#-------------------------------------#

	// Inserts many substrings in a given position of the main string
	// by concatenating them according to a specific format
	def InsertListOfSubstringsXT( nPos, aSubStr, paOptions)
		/*
		Example:
	
		o1 = new stzString("All our software versions must be updated!")
		# Defining the position of insertion
		nPosition = o1.PositionAfterSubstring("versions") + 1
			
		# Inserting the list of string using extended configuration
		? o1.InsertListOfSubstringsXT(
			nPosition, [ "V1", "V2", "V3", "V4", "V5" ],
			
			[
			:cInsertBeforOrAfter = :Before,
			:OpeningChar = "(",
			:ClosingChar = ")", 
		
			:MainSeparator = ",",
			:AddSpaceAfterSeparator = TRUE,
			
			:LastSeparator = "and",
			:AddLastToMainSeparator = TRUE,
			
			:SpaceOption = :optEnsureLeadingSpace + :optEnsureTrailingSpace
			])
	
		Gives :
		All our software versions (V1, V2, V3, V4, and V5) must be updated!
		*/
	
		# Setting the default options
			
		cInsertBeforeOrAfter = :Before
		cOpeningChar = "("
		cClosingChar = ")"
			
		cMainSeparator = ","
		bAddSpaceAfterSeparator = TRUE
					
		cLastSeparator = NULL
		bAddLastToMainSeparator = FALSE
			
		cSpaceOption = :EnsureLeadingSpace + :EnsureTrailingSpace
	
		# Verifying the syntax of the options provided
		if NOT ( len(paOptions) = 0 or
			 ( len(paOptions) = 1 and paOptions[1] = :Default) )
	
			aPossibleOptions = [ :InsertBeforeOrAfter, :OpeningChar, :ClosingChar, :MainSeparator,
				  :AddSpaceAfterSeparator, :LastSeparator, :AddLastToMainSeparator,
				  :SpaceOption ]
		
			oHash = new stzHashList(paOptions)
			aListOfProvidedOptions = oHash.Keys()
		
			oListOfProvidedOptions = new stzList(aListOfProvidedOptions)
		
			if NOT oListOfProvidedOptions.IsMadeOfSome(aPossibleOptions)
				stzRaise(stzStringError(:UnsupportedOptionsWhileInsertingListOfStrings))
			ok
		
			# If some options are provided then we take them
			# Note : if paOptions = [] or paOptions = [ :Default ] then we preserve
			# the default options already defined
				
			cInsertBeforeOrAfter = paOptions[ :InsertBeforeOrAfter ]	
			cOpeningChar = paOptions[ :OpeningChar ]
			cClosingChar = paOptions[ :ClosingChar ]
					
			cMainSeparator = paOptions[ :MainSeparator ]
			bAddSpaceAfterSeparator = paOptions[ :AddSpaceAfterSeparator ]
		
			cLastSeparator = paOptions[ :LastSeparator ]
			bAddLastToMainSeparator = paOptions[ :AddLastToMainSeparator ]
		
			cSpaceOption = paOptions[ :SpaceOption ]
		ok
	
		# At this level, all the options are defined
		# Beginning the substring construction but the opening char
	
		cSubStr = cOpeningChar
			
		# Checking the behavior of the first inserted substring in regard of adjacent left space
	
		if NOT cSpaceOption = :DoNothingForSpace
			if cSpaceOption = :EnsureLeadingSpace OR
			   cSpaceOption = :EnsureLeadingSpace + :EnsureTrailingSpace
	
				if nPos > 1 and This.NthChar(nPos - 1) != " "
					cSubStr = " " + cOpeningChar
				ok
			ok
		ok
	
		# Looping over the list of strings to concatenate them
		# depending on the logic defined by the options
	
		for i = 1 to len(aSubStr)
			# we add the string itslef
			cSubStr += aSubStr[i]
	
			# while we are not on the last item, or
			# we are on the last item but we are not asked
			# to use an alternative separator at the end
	
			if i < len(aSubStr) - 1 OR
			   (i = len(aSubStr)-1 and cLastSeparator = NULL)
	
				# Add the main separator after each string
				cSubStr += cMainSeparator
	
				# Add space after separator if required
				if bAddSpaceAfterSeparator = TRUE
						cSubstr += " "
				ok	
	
			# When reaching the last string, and an alternative
			# separator must be used (it's not null), we check
			# if we should use this last separator alone or
			# in addition to the main separator
	
			but i = len(aSubStr) - 1
	
				if bAddLastToMainSeparator = TRUE
					cSubStr += cMainSeparator
				ok
	
				if bAddSpaceAfterSeparator = TRUE
					cSubstr += " "
				ok
	
				if cLastSeparator != NULL
					cSubStr += cLastSeparator
				ok
	
				if bAddSpaceAfterSeparator = TRUE
					cSubstr += " "
				ok
			ok		
		next
	
		# Add the closing char to get the final substring
	
		cSubStr += cClosingChar
	
		# Checking the option of leaving the trailing space
	
		if cSpaceOption = :EnsureTrailingSpace OR
		   cSpaceOption = :EnsureLeadingSpace + :EnsureTrailingSpace
	
			cSubStr += " "
		ok
	
		if cInsertBeforeOrAfter = :After
			nPos++
		ok


		This.InsertBefore(nPos, cSubStr)
	
		#< @FunctionFluentForm
		
		def InsertListOfSubstringsXTQ( nPos, aSubStr, paOptions)
			This.InsertListOfSubstringsXT( nPos, aSubStr, paOptions)
			return This
		
		#>

	// Inserts many substrings in a given position of the main string
	def InsertListOfSubstrings(nPos, aSubStr)
		return This.InsertListOfSubstringsXT( nPos, aSubStr, [:Default] )

		#< @FunctionFluentForm

		def InsertListOfSubstringsQ(nPos, aSubStr)
			This.InsertListOfSubstrings(nPos, aSubStr)
			return This

		#>

		#< @FunctionAlternativeForm

		def InsertListOfSubstringsBeforePositions(nPos, aSubStr)
			This.InsertListOfSubstrings(nPos, aSubStr)

			def InsertListOfSubstringsBeforePositionsQ(nPos, aSubStr)
				This.InsertListOfSubstringsBeforePositions(nPos, aSubStr)
				return This

		#>
			
	   #-----------------------------------------------#
	  #    INSERTING A NEW SUBSTRING BEFORE NTH       #
	 #    OCCURRENCEOF AN EXISTANT SUBSTRING         #
	#-----------------------------------------------#

	def InsertBeforeNthOccurrence(n, pcSubStr, pcNewSubStr)
		This.InsertBeforePosition( This.FindNthOccurrence(n, pcSubStr), pcNewSubStr )

	def InsertBeforeFirstOccurrence(pcSubStr, pcNewSubStr)
		This.InsertBeforeNthOccurrence(1, pcSubStr, pcNewSubStr)

	def InsertBeforeLastOccurrence(pcSubStr, pcNewSubStr)
		This.InsertBeforeNthOccurrence(This.NumberOfOccurrence(pcSubStr), pcSubStr, pcNewSubStr)

	def InsertBeforeSubstring(pcSubStr, pcNewSubStr)

		nLenSubStr = Q(pcSubStr).NumberOfChars()
		anPos = StzListOfNumbersQ( This.FindAll(cSubStr) ).AddToEachQ(nLenSubStr).Content()
		aParts = This.SplitBeforePositions(anPos)
	
		cResult = StzPairOfListsQ( aParts, ListOfNTimes(len(aParts)-1, pcNewSubStr) ).AlternateQ().ToStzListOfStrings().Concatenate()
		
		This.Update( cResult )

		#< @FunctionAlternativeForms

		def InsertBeforeEachOccurrenceOfSubstring(pcSubStr, pcNewSubStr)
			This.InsertBeforeSubstring(pcSubStr, pcNewSubStr)

		def InsertBeforeEachOccurrence(pcSubStr, pcNewSubStr)
			This.InsertBeforeSubstring(pcSubStr, pcNewSubStr)

		#>

		#< @FunctionFluentForm

		def InsertBeforeSubstringQ(pcSubStr, pcNewSubStr)
			This.InsertBeforeSubstring(pcSubStr, pcNewSubStr)
			return This
	
		#>

	   #-----------------------------------------------#
	  #    INSERTING A NEW SUBSTRING AFTER NTH        #
	 #    OCCURRENCEOF AN EXISTANT SUBSTRING         #
	#-----------------------------------------------#

	def InsertAfterNthOccurrence(n, pcSubStr, pcNewSubStr)
		This.InsertAfterPosition( This.FindNthOccurrence(n, pcSubStr) )

	def InsertAfterFirstOccurrence(pcSubStr, pcNewSubStr)
		This.InsertAfterNthOccurrence(1, pcSubStr, pcNewSubStr)

	def InsertAfterLastOccurrence(pcSubStr, pcNewSubStr)
		This.InsertBeforeNthOccurrence(This.NumberOfChars(), pcSubStr, pcNewSubStr)

	def InsertAfterSubstring(pcSubStr, pcNewSubStr)
		acParts = This.Split(pcSubStr)
		cResult = ""

		for i = 1 to len(acParts)-1
			cResult += (acParts[i] + pcSubStr + pcNewSubStr)
		next

		This.Update( cResult + acParts[ len(acParts) ] )

		#< @FunctionFluentForm

		def InsertAfterSubstringQ(pcSubStr, pcNewSubStr)
			This.InsertAfterSubstring(pcSubStr, pcNewSubStr)
			return This	
	
		#>
	
	  #-------------------------------------------------#
	 #     REPLACING ALL OCCURRENCES OF A SUBSTRING    #
	#-------------------------------------------------#
	
	def ReplaceAllCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		#< @MotherFunction = YES | @QtBased #>

		/* Example 1:
	
		StzStringQ( "Tunis is the holder of my memories. Tunis is my dream!") {
			ReplaceAllCS("tunis", "Regueb", :CS = FALSE )
			? Content()
		}
	
		--> "Regueb is the holder of my memories. Regueb is my dream!"
	
		Example 2:
	
		StzStringQ( "Tunis is the holder of my memories. Tunis is my dream!") {
			ReplaceAllCS("tunis", :EachChar = "*", :CS = FALSE )
			? Content()
		}
	
		--> "***** is the holder of my memories. ***** is my dream!"
		*/

	
		# Checking the correctness of pcSubStr param

		if NOT isString(pcSubstr)
			stzRaise("Incorrect param typs! pcSubstr must be a string.")
		ok

		# Checking the correctness of pcNewSubStr param

		bWellFormed = FALSE

		if isString(pcNewSubStr)
			bWellFormed = TRUE

		but isList(pcNewSubStr) and StzListQ(pcNewSubStr).IsWithOrByParamList()
			
			if isString(pcNewSubStr[2])
				bWellFormed = TRUE
				# Detecting the case where a conditonal value is provided
				# via the :With@ or :By@ keywords
	
				if Q(pcNewSubStr[1]).IsOneOfThese([ :With@, :By@ ])
					pcNewSubStr = pcNewSubStr[2]
	
					cCode = Q(pcNewSubStr).
						SimplifyQ().
						RemoveBoundsQ("{","}").
						ReplaceCSQ("@section", This.Section(n1, n2), :CaseSensitive = FALSE ).
						Content()
	
					cCode = "pcNewSubStr = " + cCode
					eval(cCode)
	
				else
					pcNewSubStr = pcNewSubStr[2]
				ok

			ok

		ok

		# Checking the correctness of pCaseSensitive param

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
			bWellFormed = TRUE

		else
			if isBoolean(pCaseSensitive)
				bWellFormed = TRUE
			ok
		ok

		if NOT bWellFormed
			stzRaise("Incorrect param types!")
		ok

		# Doing the job

		@oQString.replace_2(pcSubStr, pcNewSubStr, pCaseSensitive)

	
		#< @FunctionFluentForm
		
		def ReplaceAllCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceAllCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This
		
		#>
		
		#>

		#< @FunctionAlternativeForms

		def ReplaceCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceAllCS(pcSubStr, pcNewSubStr, pCaseSensitive)

			def ReplaceCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
				This.ReplaceCS(pcSubStr, pcNewSubStr, pCaseSensitive)
				return This

		def ReplaceSubstringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceAllCS(pcSubStr, pcNewSubStr, pCaseSensitive)

			def ReplaceSubstringCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
				This.ReplaceSubstringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
				return This

		def ReplaceAllOccurrencesCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			if isList(pcSubStr) and Q(pcSubStr).IsOfParamList()
				pcSubStr = pcSubStr[2]
			ok

			This.ReplaceAllCS(pcSubStr, pcNewSubStr, pCaseSensitive)

			def ReplaceAllOccurrencesCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
				This.ReplaceAllOccurrencesCS(pcSubStr, pcNewSubStr, pCaseSensitive)
				return This

		def ReplaceAllOccurrencesOfSubstringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceAllCS(pcSubStr, pcNewSubStr, pCaseSensitive)

			def ReplaceAllOccurrencesOfSubstringCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
				This.ReplaceAllOccurrencesOfSubstringCS(pcSubStr, pcNewSubStr, pCaseSensitive)
				return This		
		
		#>

	#-- CASE-INSENSITIVE

	def ReplaceAll(pcSubStr, pcNewSubStr)
		This.ReplaceAllCS(pcSubStr, pcNewSubStr, :CaseSensitive = TRUE)
		
		def ReplaceAllQ(pcSubStr, pcNewSubStr)
			This.ReplaceAll(pcSubStr, pcNewSubStr)
			return This

		def Replace(pcSubStr, pcNewSubStr)
			This.ReplaceAll(pcSubStr, pcNewSubStr)

			def ReplaceQ(pcSubStr, pcNewSubStr)
				This.Replace(pcSubStr, pcNewSubStr)
				return This

		def ReplaceSubstring(pcSubStr, pcNewSubStr)
			This.ReplaceAll(pcSubStr, pcNewSubStr)

			def ReplaceSubstringQ(pcSubStr, pcNewSubStr)
				This.ReplaceSubstring(pcSubStr, pcNewSubStr)
				return This

		def ReplaceAllOccurrences(pcSubStr, pcNewSubStr)
			if isList(pcSubStr) and Q(pcSubStr).IsOfParamList()
				pcSubStr = pcSubStr[2]
			ok

			This.ReplaceAllCS(pcSubStr, pcNewSubStr)

			def ReplaceAllOccurrencesQ(pcSubStr, pcNewSubStr)
				This.ReplaceAllOccurrences(pcSubStr, pcNewSubStr)
				return This

		def ReplaceAllOccurrencesOfSubstring(pcSubStr, pcNewSubStr)
			This.ReplaceAll(pcSubStr, pcNewSubStr)

			def ReplaceAllOccurrencesOfSubstringQ(pcSubStr, pcNewSubStr)
				This.ReplaceAllOccurrencesOfSubstringCS(pcSubStr, pcNewSubStr)
				return This		
		
		#>

	  #-------------------------------------------------------------------------#
	 #  REPLACING ALL OCCURRENCES OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS  #
	#-------------------------------------------------------------------------#

	def ReplaceBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
		aSections = This.FindSectionsBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		This.ReplaceSections(aSections, pcNewSubStr)

		def ReplaceBetweenCSQ(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
			This.ReplaceBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
			return This

		def ReplaceSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
			This.ReplaceBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)

			def ReplaceSubStringBetweenCSQ(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
				This.ReplaceSubStringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
				return This

	def SubstringBetweenReplacedCS(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
		cResult = This.ReplaceBetweenCSQ(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive).Content()
		return cResult

	#-- CASE-INSENSITIVE

	def ReplaceBetween(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr)
		This.ReplaceBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr, :CaseSensitive = TRUE)
		
		def ReplaceBetweenQ(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr)
			This.ReplaceBetween(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr)
			return This

		def ReplaceSubStringBetween(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr)
			This.ReplaceBetween(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr)

			def ReplaceSubStringBetweenQ(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr)
				This.ReplaceSubStringBetween(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr)
				return This

	def SubstringBetweenReplaced(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr)
		cResult = This.ReplaceBetweenQ(pcSubStr, pcSubStr1, pcSubStr2, pcNewSubstr).Content()
		return cResult

	  #--------------------------------------------------------#
	 #  REPLACING ANY SUBSTRING BETWEEN TWO OTHER SUBSTRINGS  #
	#--------------------------------------------------------#

	def ReplaceAnyBetweenCS(pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
		aSections = This.FindAnySectionsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		This.ReplaceManySections(aSections, pcNewSubStr)

		def ReplaceAnyBetweenCSQ(pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
			This.ReplaceAnyBetweenCS(pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
			return This

		def ReplaceAnySubStringBetweenCS(pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
			This.ReplaceAnyBetweenCS(pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)

			def ReplaceAnySubStringBetweenCSQ(pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
				This.ReplaceSubStringBetweenCS(pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
				return This

	def AnySubstringBetweenReplacedCS(pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive)
		cResult = This.ReplaceAnyBetweenCSQ(pcSubStr1, pcSubStr2, pcNewSubstr, pCaseSensitive).Content()
		return cResult

	#-- CASE-INSENSITIVE

	def ReplaceAnyBetween(pcSubStr1, pcSubStr2, pcNewSubstr)
		This.ReplaceAnyBetweenCS(pcSubStr1, pcSubStr2, pcNewSubstr, :CaseSensitive = TRUE)
		
		def ReplaceAnyBetweenQ(pcSubStr1, pcSubStr2, pcNewSubstr)
			This.ReplaceAnyBetween(pcSubStr1, pcSubStr2, pcNewSubstr)
			return This

		def ReplaceAnySubStringBetween(pcSubStr1, pcSubStr2, pcNewSubstr)
			This.ReplaceAnyBetween(pcSubStr1, pcSubStr2, pcNewSubstr)

			def ReplaceAnySubStringBetweenQ(pcSubStr1, pcSubStr2, pcNewSubstr)
				This.ReplaceSubStringBetween(pcSubStr1, pcSubStr2, pcNewSubstr)
				return This

	def AnySubstringBetweenReplaced(pcSubStr1, pcSubStr2, pcNewSubstr)
		cResult = This.ReplaceAnyBetweenQ(pcSubStr1, pcSubStr2, pcNewSubstr).Content()
		return cResult

	  #------------------------------------------#
	 #   REPLACING A CHAR AT A GIVEN POSITION   #
	#------------------------------------------#

	def ReplaceCharAtPosition(n, pcNewSubStr)
		#< @MotherFunction = This.ReplaceSection() > @QtBased = TRUE #>

		This.ReplaceSection(n, n, pcNewSubStr)

		def ReplaceCharAtPositionQ(n, pcNewSubStr)
			This.ReplaceCharAtPosition(n, pcNewSubStr)
			return This

		def ReplaceCharAt(n, pcNewSubStr)

		def ReplaceCharAtThisPosition(n, pcNewSubStr)

	def CharReplacedAtPsoition(n, pcNewSubStr)
		#< @MotherFunction = This.ReplaceSection() > @QtBased = TRUE #>

		cResult = This.Copy().ReplaceCharAtPositionQ(n, pcNewSubStr).Content()
		return cResult

		def CharReplacedAtThisPsoition(n, pcNewSubStr)
			return This.CharReplacedAtPsoition(n, pcNewSubStr)

		def CharAtPositionNReplaced(n, pcNewSubStr)
			return This.CharReplacedAtPsoition(n, pcNewSubStr)

	  #----------------------------------------#
	 #   REPLACING CHARS AT GIVEN POSITIONS   #
	#----------------------------------------#

	def ReplaceCharsAtPositions(panPositions, pcNewSubStr)
		#< @MotherFunction = This.ReplaceSection() > @QtBased = TRUE #>

		# Checking the correctness of panPositions param

		if NOT isList(panPositions) and Q(panPositions).IsListOfNumbers()
			stzRaise("Incorrect param! panPositions must be list of numbers.")
		ok

		# Checking the correctness of the pcNewSubStr param

		bCorrect = FALSE
		cCode = ""

		if isString(pcNewSubStr)
			bCorrect = TRUE

		but isList(pcNewSubStr) and StzListQ(pcNewSubStr).IsWithOrByParamList()
			
			if isString(pcNewSubStr[2])
				bCorrect = TRUE
				# Detecting the case where a conditonal value is provided
				# via the :With@ or :By@ keywords
	
				if Q(pcNewSubStr[1]).IsOneOfThese([ :With@, :By@ ])
					pcNewSubStr = pcNewSubStr[2]

					cCode = Q(pcNewSubStr).
						SimplifyQ().
						RemoveBoundsQ("{","}").
						Content()
	
					cCode = "pcNewSubStr = " + cCode
	
				else
					pcNewSubStr = pcNewSubStr[2]
				ok

			ok
		ok

		if NOT bCorrect
			stzRaise([
				:Where 	= "stzString (4999) > ReplaceCharsAtPositions(panPositions, pcNewSubStr)",
				:What	= "Can't replace chars with the given substring!",
				:Why	= "The param you provided as a substring (pcNewSubStr) is not well formed.",
				:Todo	= "Provide a substring in a string or a list of the form (:With = substring)."
			])
		ok

		anPos = sort(panPositions)

		Previous@ = 0
		Next@i = 0

		for @i = len(anPos) to 1 step -1

			if @i <= This.NumberOfChars()
				Next@i = @i + 1
			ok

			if @i > 1
				Previous@i = @i - 1
			ok

			nPos = anPos[@i]

			if cCode != NULL
				@char = This[@i]
				eval(cCode)
			ok

			This.ReplaceCharAtPosition(nPos, pcNewSubStr)
		next

		def ReplaceCharsAtPositionsQ(panPositions, pcNewSubStr)
			This.ReplaceCharsAtPositions(panPositions, pcNewSubStr)
			return This

		def ReplaceCharsAt(panPositions, pcNewSubStr)
			This.ReplaceCharsAtPositions(panPositions, pcNewSubStr)

		def ReplaceCharsAtThesePositions(panPositions, pcNewSubStr)
			This.ReplaceCharsAtPositions(panPositions, pcNewSubStr)

	def CharsReplacedAtPsoitions(panPositions, pcNewSubStr)
		cResult = This.Copy().ReplaceCharsAtPositionsQ(panPositions, pcNewSubStr).Content()
		return cResult

		def CharsReplacedAtThesePsoitions(panPositions, pcNewSubStr)
			return This.CharsReplacedAtPsoitions(panPositions, pcNewSubStr)

		def CharsAtThesePositionsReplaced(panPositions, pcNewSubStr)
			return This.CharsReplacedAtPsoitions(panPositions, pcNewSubStr)


	  #--------------------------------------------------------------------#
	 #     REPLACING ALL CHARS WITH A SUBSTRING UNDER A GIVEN CONDITION   #
	#--------------------------------------------------------------------#

	def ReplaceAllCharsW(pcCondition, pcNewSubStr)
		#< @MotherFunctions:
		#	This.FindAllCharsW()  > @RingBased
		#	This.ReplaceSection() > @QtBased
		#>

		/*
		Example:

		StzStringQ( "Text processing with Ring" ) {

			ReplaceAllCharsW(
				:Where = '{ @char = "i" }',
				:With = "*"
			)

			? Content()
		}

		--> Returns: "Text process*ng w*th R*ng"
		*/

		# Checking the correctness of the pcCondition param
			# --> Not necessary! It will be done by the
			# mother function FindAllCharsW()

		# Checking the correctness of the pcNewSubStr param
			# --> Not necceary! It will be done by the
			# called function ReplaceCharsAtPositions()

		# Doing the job

		anPositions = This.FindCharsW(pcCondition)

		This.ReplaceCharsAtPositions(anPositions, pcNewSubStr)


		#< @FunctionFluentForm

		def ReplaceAllCharsWQ(pCondition, pcNewSubStr)
			This.ReplaceAllCharsWhere(pCondition, pcNewSubStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceAllWhere(pCondition, pcNewSubStr)
			This.ReplaceAllCharsW(pCondition, pcNewSubStr)

			def ReplaceAllWhereQ(pCondition, pcNewSubStr)
				This.ReplaceAllWhere(pCondition, pcNewSubStr)
				return This

		def ReplaceAllCharsWhere(pCondition, pcNewSubStr)
			This.ReplaceAllCharsW(pCondition, pcNewSubStr)

			def ReplaceAllCharsWhereQ(pCondition, pcNewSubStr)
				This.ReplaceAllCharsWhere(pCondition, pcNewSubStr)
				return This

		def ReplaceCharsW(pCondition, pcNewSubStr)
			This.ReplaceAllCharsW(pCondition, pcNewSubStr)

			def ReplaceCharsWQ(pCondition, pcNewSubStr)
				This.ReplaceCharsW(pCondition, pcNewSubStr)
				return This

		def ReplaceCharsWhere(pCondition, pcNewSubStr)
			This.ReplaceAllCharsW(pCondition, pcNewSubStr)

			def ReplaceCharsWhereQ(pCondition, pcNewSubStr)
				This.ReplaceCharsWhere(pCondition, pcNewSubStr)
				return This

		def ReplaceW(pCondition, pcNewSubStr)
			This.ReplaceAllCharsW(pCondition, pcNewSubStr)

			def ReplaceWQ(pCondition, pcNewSubStr)
				This.ReplaceW(pCondition, pcNewSubStr)
				return This

		#>

	  #-------------------------------------------#
	 #     REPLACING MANY SUBSTRINGS AT ONCE     #
	#-------------------------------------------#

	def ReplaceManyCS(pacSubstr, pNewSubstr, pCaseSensitive)
		/* Example 1:
	
		o1 = new stzString( "a + b - c / d = 0")
		 o1.ReplaceManyCS( ["+", "-", "=", "/" ], "*", :CaseSensitive = FALSE )
		 ? o1.Content()
	
		--> Gives: "a * b * c * d = 0"
	
		Example 2:
	
		o1 = new stzString( "Tunis is my town. Tunisa is my nation!")
		o1.ReplaceManyCS( [ "Tunis", "Tunisia" ], :EachChar = "*" )
		? o1.Content()
	
		*/

		for str in pacSubstr
			This.ReplaceAllCS( str, pNewSubStr, pCaseSensitive )
		next
	
		#< @FunctionFluentForm
	
		def ReplaceManyCSQ(pacSubstr, pNewSubstr, pCaseSensitive)
			This.ReplaceManyCS(pacSubstr, pNewSubstr, pCaseSensitive)
			return This
		
		#>

		def ReplaceAllOfTheseCS(pacSubstr, pNewSubstr, pCaseSensitive)
			This.ReplaceManyCS(pacSubstr, pNewSubstr, pCaseSensitive)

			def ReplaceAllOfTheseCSQ(pacSubstr, pNewSubstr, pCaseSensitive)
				This.ReplaceAllOfTheseCS(pacSubstr, pNewSubstr, pCaseSensitive)
				return This

		def ReplaceManySubstringsCS(pacSubstr, pNewSubstr, pCaseSensitive)
			This.ReplaceManyCS(pacSubstr, pNewSubstr, pCaseSensitive)

			def ReplaceManySubstringsCSQ(pacSubstr, pNewSubstr, pCaseSensitive)
				This.ReplaceManySubstringsCS(pacSubstr, pNewSubstr, pCaseSensitive)
				return This
		#>

	def ManySubstringsReplacedCS(pacSubstr, pNewSubstr, pCaseSensitive)
		acResult = This.Copy().ReplaceManySubstringsCSQ(pacSubstr, pNewSubstr, pCaseSensitive).Content()
		return acResult

		def ManyReplacedCS(pacSubstr, pNewSubstr, pCaseSensitive)
			return This.ManySubstringsReplacedCS(pacSubstr, pNewSubstr, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def ReplaceMany(pacSubstr, pcNewSubstr)
		This.ReplaceManyCS( pacSubstr, pcNewSubstr, :CaseSensitive = TRUE )

		#< @FunctionFluentFormn

		def ReplaceManyQ(pacSubStr, pcNewSubStr)
			This.ReplaceMany(pacSubstr, pcNewSubstr)
			return This
		#>

		#< @FunctionAlternativeForm
	
		def ReplaceAllOfThese(pacSubStr, pcNewSubStr)
			This.ReplaceMany(pacSubstr, pcNewSubstr)

			def ReplaceAllOfTheseQ(pacSubStr, pcNewSubStr)
				This.ReplaceAllOfThese(pacSubStr, pcNewSubStr)
				return This

		def ReplaceManySubstrings(pacSubstr, pNewSubstr)
			This.ReplaceMany(pacSubstr, pNewSubstr)

			def ReplaceManySubstringsQ(pacSubstr, pNewSubstr)
				This.ReplaceManySubstrings(pacSubstr, pNewSubstr)
				return This

		#>

	def ManySubstringsReplaced(pacSubstr, pNewSubstr)
		acResult = This.Copy().ReplaceManySubstringsQ(pacSubstr, pNewSubstr).Content()
		return acResult

		def ManyReplaced(pacSubstr, pNewSubstr)
			return This.ManySubstringsReplaced(pacSubstr, pNewSubstr)

	  #---------------------------------------------------------------#
	 #    REPLACING SUBSTRINGS BY MANY NEW SUBSTRINGS, ONE BY ONE    #
	#---------------------------------------------------------------#

	def ReplaceManyOneByOneCS(pacSubstrings, paNewSubStrings, pCaseSensitive)

		if NOT IsListOfStrings(pacSubstrings) and isList(paNewSubStrings)
		   stzRaise("Incorrect params!")
		ok

		if isList(paNewSubStrings) and
		   ( (StzListQ(paNewSubStrings).IsWithParamList() or
		     StzListQ(paNewSubStrings).IsByParamList()) and IsListOfStrings(paNewSubStrings[2]) )

			paNewSubStrings = paNewSubStrings[2]
		ok

		n = Min( len(pacSubstrings), len(paNewSubStrings) )

		for i = 1 to n
			This.ReplaceAllCS(pacSubstrings[i], :With = paNewSubStrings[i], pCaseSensitive )
		next

		def ReplaceManyOneByOneCSQ(pacSubstrings, paNewSubStrings, pCaseSensitive)
			This.ReplaceManyOneByOneCS(pacSubstrings, paNewSubStrings, pCaseSensitive)
			return This

		def ReplaceSubstringsOneByOneCS(pacSubstrings, paNewSubStrings, pCaseSensitive)
			This.ReplaceManyOneByOneCS(pacSubstrings, paNewSubStrings, pCaseSensitive)

			def ReplaceSubstringsOneByOneCSQ(pacSubstrings, paNewSubStrings, pCaseSensitive)
				This.ReplaceSubstringsOneByOneCS(pacSubstrings, paNewSubStrings, pCaseSensitive)
				return This

	def ManySubStringsReplacedOneByOneCS(pacSubstrings, paNewSubStrings, pCaseSensitive)
		cResult = This.Copy().ReplaceManyOneByOneCSQ(pacSubstrings, paNewSubStrings, pCaseSensitive)
		return cResult

		def SubstringsReplacedOneByOneCS(pacSubStrings, paNewSubStrings, pCaseSensitive)
			return This.ManySubStringsReplacedOneByOneCS(pacSubStrings, paNewSubStrings, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def ReplaceManyOneByOne(pacSubstrings, paNewSubStrings)
		This.ReplaceManyOneByOneCS(pacSubStrings, paNewSubStrings, :CaseSensitive = TRUE)

		def ReplaceManyOneByOneQ(pacSubstrings, paNewSubStrings)
			This.ReplaceManyOneByOne(pacSubstrings, paNewSubStrings)
			return This

		def ReplaceSubstringsOneByOne(pacSubstrings, paNewSubStrings)
			This.ReplaceManyOneByOne(pacSubstrings, paNewSubStrings)

			def ReplaceSubstringsOneByOneQ(pacSubstrings, paNewSubStrings)
				This.ReplaceSubstringsOneByOne(pacSubstrings, paNewSubStrings)
				return This

	def ManySubStringsReplaceOneByOne(pacSubstrings, paNewSubStrings)
		cResult = This.Copy().ReplaceManyOneByOneQ(pacSubstrings, paNewSubStrings)
		return cResult

		def SubStringsReplacedOneByOne(pacSubStrings, paNewSubStrings)
			return This.ManySubStringsReplacedOneByOne(pacSubStrings, paNewSubStrings)


	  #----------------------------------------------------#
	 #     REPLACING THE NTH OCCURRENCE OF A SUBSTRING    #
	#----------------------------------------------------#

	def ReplaceNthOccurrenceCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
		#< @MotherFunction = This.ReplaceSection() > @QtBased = TRUE #>
		
		if isList(pcSubStr) and StzListQ(pcSubStr).IsOfParamList(pcSubStr)
			pcSubStr = pcSubStr[2]
		ok

		if isList(pcNewSubStr) and StzListQ(pcNewSubStr).IsWithParamList()
			pcNewSubStr = pcNewSubStr[2]
		ok
	
		if n = :First
			n = 1
	
		but n = :Last
			n = This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
	
		ok
	
		n = This.FindNthOccurrenceCS(n, pcSubStr, pCaseSensitive)
	
		if n > 0
			oSubStr = new stzString(pcSubStr)
			This.ReplaceSection( n, n + oSubStr.NumberOfChars()-1, pcNewSubStr)
		ok
	
		#< @FunctionFluentForm
	
		def ReplaceNthOccurrenceCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceNthOccurrenceCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			return This
		
		#>

		def ReplaceNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceNthOccurrenceCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)

			def ReplaceNthCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive)
				This.ReplaceNthCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)
				return This

	def ReplaceNthOccurrence(n, pcSubStr, pcNewSubStr)
		This.ReplaceNthOccurrenceCS(n, pcSubStr, pcNewSubStr, :Casesensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceNthOccurrenceQ(n, pcSubStr, pcNewSubStr)
			This.ReplaceNthOccurrence(n, pcSubStr, pcNewSubStr)
			return This
	
		#>

		def ReplaceNth(n, pcSubStr, pcNewSubStr)
			This.ReplaceNthOccurrence(n, pcSubStr, pcNewSubStr)

			def ReplaceNthQ(n, pcSubStr, pcNewSubStr)
				This.ReplaceNth(n, pcSubStr, pcNewSubStr)
				return This

	  #-------------------------------------------------#
	 #    REPLACING FIRST OCCURRENCE OF A SUBSTRING    #
	#-------------------------------------------------#

	def ReplaceFirstOccurrenceCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		This.ReplaceNthOccurrenceCS(1, pcSubStr, pcNewSubStr, pCaseSensitive)
	
		#< @FunctionFluentForm
	
		def ReplaceFirstOccurrenceCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceFirstOccurrenceCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This
		
		#>

	def ReplaceFirstOccurrence(pcSubStr, pcNewSubStr)
		This.ReplaceFirstOccurrenceCS(pcSubStr, pcNewSubStr, :Casesensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceFirstOccurrenceQ(pcSubStr, pcNewSubStr)
			This.ReplaceFirstOccurrence(pcSubStr, pcNewSubStr)
			return This
	
		#>

		def ReplaceFirst(pcSubStr, pcNewSubStr)
			This.ReplaceFirstOccurrence(pcSubStr, pcNewSubStr)

			def ReplaceFirstQ(pcSubStr, pcNewSubStr)
				This.ReplaceFirst(pcSubStr, pcNewSubStr)
				return This

	  #--------------------------------------------------#
	 #     REPLACING LAST OCCURRENCE OF A SUBSTRING     #
	#--------------------------------------------------#

	def ReplaceLastOccurrenceCS(pcSubStr, pcNewSubStr, pCaseSensitive)
		This.ReplaceNthOccurrenceCS(:Last, pcSubStr, pcNewSubStr, pCaseSensitive)
	
		#< @FunctionFluentForm
	
		def ReplaceLastOccurrenceCSQ(pcSubStr, pcNewSubStr, pCaseSensitive)
			This.ReplaceLastOccurrenceCS(pcSubStr, pcNewSubStr, pCaseSensitive)
			return This
		
		#>

	def ReplaceLastOccurrence(pcSubStr, pcNewSubStr)
		This.ReplaceLastOccurrenceCS(pcSubStr, pcNewSubStr, :Casesensitive = TRUE)

		#< @FunctionFluentForm

		def ReplaceLastOccurrenceQ(pcSubStr, pcNewSubStr)
			This.ReplaceLastOccurrence(pcSubStr, pcNewSubStr)
			return This
	
		#>

		def ReplaceLast(pcSubStr, pcNewSubStr)
			This.ReplaceLastOccurrence(pcSubStr, pcNewSubStr)

			def ReplaceLastQ(pcSubStr, pcNewSubStr)
				This.ReplaceLast()
				return This

	   #----------------------------------------------------#
	  #    REPLACING NEXT NTH OCCURRENCE OF A SUBSTRING    # 
	 #    STARTING AT A GIVEN POSITION                    #
	#----------------------------------------------------#

	def ReplaceNextNthOccurrenceCS(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
		
		if isList(nStart) and StzListQ(nStart).IsStartingAtParamList()
			nStart = nStart[2]
		ok

		if isList(pcSubStr) and StzListQ(pcSubStr).IsOfParamList()
			pcSubStr = pcSubStr[2]
		ok

		if isList(pcNewSubStr) and StzListQ(pcNewSubStr).IsWithParamList()
			pcNewSubStr = pcNewSubStr[2]
		ok

		cPart1 = This.Section(1, nStart - 1)

		oPart2 = This.SectionQ(nStart, :LastChar)
		cPart2 = oPart2.ReplaceNthOccurrenceCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive).Content()

		cResult = cPart1 + cPart2
		This.Update( cResult )

		def ReplaceNextNthOccurrenceCSQ(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
			This.ReplaceNextNthOccurrenceCS(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
			return This

		def ReplaceNthNextOccurrenceCS(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
			This.ReplaceNextNthOccurrenceCS(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)

			def ReplaceNthNextOccurrenceCSQ(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
				This.ReplaceNthNextOccurrenceCS(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
				return This

	def ReplaceNextNthOccurrence(n, pcSubStr, nStart, pcNewSubStr)
		This.ReplaceNextNthOccurrenceCS(n, pcSubStr, nStart, pcNewSubStr, :CaseSensitive = TRUE)

		def ReplaceNextNthOccurrenceQ(n, pcSubStr, nStart, pcNewSubStr)
			This.ReplaceNextNthOccurrence(n, pcSubStr, nStart, pcNewSubStr)
			return This

		def ReplaceNthNextOccurrence(n, pcSubStr, nStart, pcNewSubStr)
			This.ReplaceNextNthOccurrence(n, pcSubStr, nStart, pcNewSubStr)

			def ReplaceNthNextOccurrenceQ(n, pcSubStr, nStart, pcNewSubStr)
				return This.ReplaceNthNextOccurrence(n, pcSubStr, nStart, pcNewSubStr)

	   #------------------------------------------------#
	  #    REPLACING NEXT OCCURRENCE OF A SUBSTRING    # 
	 #    STARTING AT A GIVEN POSITION                #
	#------------------------------------------------#

	def ReplaceNextOccurrenceCS(pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
		This.ReplaceNextNthOccurrenceCS(1, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)

		def ReplaceNextOccurrenceCSQ(pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
			This.ReplaceNextOccurrenceCS(pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
			return This

	def ReplaceNextOccurrence(pcSubStr, nStart, pcNewSubStr)
		This.ReplaceNextNthOccurrenceCS(1, pcSubStr, nStart, pcNewSubStr, :CaseSensitive = TRUE)

		def ReplaceNextOccurrenceQ(pcSubStr, nStart, pcNewSubStr)
			This.ReplaceNextOccurrence(pcSubStr, nStart, pcNewSubStr)
			return This

	   #--------------------------------------------------------#
	  #    REPLACING PREVIOUS NTH OCCURRENCE OF A SUBSTRING    # 
	 #    STARTING AT A GIVEN POSITION                        #
	#--------------------------------------------------------#

	def ReplacePreviousNthOccurrenceCS(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
		
		if isList(nStart) and StzListQ(nStart).IsStartingAtParamList()
			nStart = nStart[2]
		ok

		if isList(pcSubStr) and StzListQ(pcSubStr).IsOfParamList()
			pcSubStr = pcSubStr[2]
		ok

		if isList(pcNewSubStr) and StzListQ(pcNewSubStr).IsWithParamList()
			pcNewSubStr = pcNewSubStr[2]
		ok

		oPart1 = This.SectionQ(1, nStart - 1)
		n = oPart1.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive) - n + 1
		cPart1 = oPart1.ReplaceNthOccurrenceCSQ(n, pcSubStr, pcNewSubStr, pCaseSensitive).Content()

		cPart2 = This.Section(nStart, :LastChar)

		cResult = cPart1 + cPart2
		This.Update( cResult )

		def ReplacePreviousNthOccurrenceCSQ(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
			This.ReplacePreviousNthOccurrenceCS(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
			return This

		def ReplaceNthPreviousOccurrenceCS(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
			This.ReplacePreviousNthOccurrenceCS(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)

			def ReplaceNthPreviousOccurrenceCSQ(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
				This.ReplaceNthPreviousOccurrenceCS(n, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
				return This

	def ReplacePreviousNthOccurrence(n, pcSubStr, nStart, pcNewSubStr)
		This.ReplacePreviousNthOccurrenceCS(n, pcSubStr, nStart, pcNewSubStr, :CaseSensitive = TRUE)

		def ReplacePreviousNthOccurrenceQ(n, pcSubStr, nStart, pcNewSubStr)
			This.ReplacePreviousNthOccurrence(n, pcSubStr, nStart, pcNewSubStr)
			return This

		def ReplaceNthPreviousOccurrence(n, pcSubStr, nStart, pcNewSubStr)
			This.ReplacePreviousNthOccurrence(n, pcSubStr, nStart, pcNewSubStr)

			def ReplaceNthPreviousOccurrenceQ(n, pcSubStr, nStart, pcNewSubStr)
				This.ReplaceNthPreviousOccurrence(n, pcSubStr, nStart, pcNewSubStr)
				return This

	   #----------------------------------------------------#
	  #    REPLACING PREVIOUS OCCURRENCE OF A SUBSTRING    # 
	 #    STARTING AT A GIVEN POSITION                    #
	#----------------------------------------------------#

	def ReplacePreviousOccurrenceCS(pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
		This.ReplacePreviousNthOccurrenceCS(1, pcSubStr, nStart, pcNewSubStr, pCaseSensitive)

		def ReplacePreviousOccurrenceCSQ(pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
			This.ReplacePreviousOccurrenceCS(pcSubStr, nStart, pcNewSubStr, pCaseSensitive)
			return This

	def ReplacePreviousOccurrence(pcSubStr, nStart, pcNewSubStr)
		This.ReplacePreviousNthOccurrenceCS(1, pcSubStr, nStart, pcNewSubStr, :CaseSensitive = TRUE)

		def ReplacePreviousOccurrenceQ(pcSubStr, nStart, pcNewSubStr)
			This.ReplacePreviousOccurrence(pcSubStr, nStart, pcNewSubStr)
			return This

	  #-------------------------#
	 #    REPLACING NTH CHAR   # 
	#-------------------------#

	def ReplaceNthChar(n, pSubStr)
		#< @MotherFunction = This.ReplaceSection() > @QtBased = TRUE #>

		if n = :LastChar or n = :EndOfString
			n = This.NumberOfChars()

		but n = :FirstChar or n = :StartOfString
			n = 1
		ok

		if isList(pSubStr) and
		   len(pSubStr) = 2 and
		   StzListQ(pSubStr).IsPairOfStrings()

			if pSubStr[1] = :With
				pSubStr = pSubStr[2]

			but pSubStr[1] = :With@
				cCode = 'pSubStr = ' + StzStringQ(pSubStr[2]).SimplifyQ().RemoveBoundsQ("{","}").Content()
				eval(cCode)
			ok
		ok

		This.ReplaceSection(n, n , pSubStr)

		#< @FunctionFluentForm

		def ReplaceNthCharQ(n, pcSubStr)
			This.ReplaceNthChar(n, pcSubStr)
			return This

		#>

	def NthCharReplaced(n, pValue)
		cResult = This.Copy().ReplaceNthCharQ(n, pValue).Content()
		return cResult

	  #---------------------------#
	 #    REPLACING FIRST CHAR   # 
	#---------------------------#

	def ReplaceFirstChar(pSubStr)
		This.ReplaceNthChar(1, pSubStr)

		#< @FunctionFluentForm

		def ReplaceFirstCharQ(pcSubStr)
			This.ReplaceFirstChar(pcSubStr)
			return This

		#>

	def FirstCharReplaced(n, pValue)
		cResult = This.Copy().ReplaceFirstCharQ(n, pValue).Content()
		return cResult

	  #---------------------------#
	 #    REPLACING LAST CHAR    # 
	#---------------------------#

	def ReplaceLastChar(pSubStr)
		This.ReplaceNthChar(:Last, pSubStr)

		#< @FunctionFluentForm

		def ReplaceLastCharQ(pcSubStr)
			This.ReplaceLastChar(pcSubStr)
			return This

		#>

	def LastCharReplaced(n, pValue)
		cResult = This.Copy().ReplaceLastCharQ(n, pValue).Content()
		return cResult

	  #--------------------------#
	 #    REPLACING ALL CHARS   # 
	#--------------------------#

	def ReplaceAllChars(pcSubStr)

		if isList(pcSubStr) and _@(pcSubStr).IsWithParamList()
			pcSubStr = pcSubStr[2]
		ok

		cResult = ""
		for i = 1 to This.NumberOfChars()
			cResult += pcSubStr
		next

		This.Update( cResult )

		#< @FunctionFluentForm

		def ReplaceAllCharsQ(pcSubStr)
			This.ReplaceAllChars(pcSubStr)
			return This

		#>

	def AllCharsReplaced(pcSubStr)
		cResult = This.Copy().ReplaceAllCharsQ(pcSubStr).Content()
		return cResult

	  #--------------------------------#
	 #    INTERPOLATING THE STRING    # 
	#--------------------------------#

	def Interpolate()
		/*
		@lang = "Ring"
		? StzStringQ('My best programming language is @lang!').Interpolate()

		# --> My best programming language is Ring!
		*/
		if This.ContainsVars()
			acVars = This.ExtractVars()
			aValues = []

			for var in acVars
				// TODO
			next

			
		ok

	def ContainsVars()
		
		acVars = variables()

		for cVar in acVars
			cVar = " " + cVar + " "
		next

		cString = " " + This.String() + " "

		This.FindMany(acVars)
		// TODO

	def InterpolateUsing(paValues)
		/*
		? StzString('My kids are #1, #2, and #3!').InterpolateUsing([ "Teeba", "Haneen", "Hussein" ])

		#--> My kids are Teeba, Heneen, and Hussein!
		*/

		if This.ContainsMarkers()
			acMarkers = This.ExtractMarkers()
			// TODO
		ok

	def ContainsMarkers()
		/*
		? StzString('My kids are #1, #2, and #3!').ContainsMarkers() --> TRUE
		*/

		if This.NumberOfMarkers() > 0
			return TRUE
		else
			return FALSE
		ok

	def ExtractMarkers()
		/*
		? StzString('My kids are #1, #2, and #3!').ExtractMarkers()

		# --> [ "#1", "#2", "#3" ]
		*/

		return StzHashListQ( This.ExtractMarkersXT() ).Keys()

	def NumberOfMarkers()
		return len( This.ExtractMarkers() )

	def ExtractMarkersPositions()
		/*
		? StzString('My kids are #1, #2, and #3!').ExtractMarkersXT()

		# --> [ 13, 16, 23 ]
		*/

		return StzHashListQ( This.ExtractMarkersXT() ).Values()

	def ExtractMarkersXT()
		/*
		? StzString('My kids are #1, #2, and #3!').ExtractMarkersXT()

		# --> [ "#1" = 13, "#2" = 16, "#3" = 23 ]
		*/

		def ExtractMArkersAndTheirPositions()
			return This.ExtractMarkersXT()

	  #---------------------------------------------#
	 #    CHECKING IF THE STRING IS A RING CODE    # 
	#---------------------------------------------#

	def IsValidRingCode()

		try
			eval(This.Copy().Content())
			return TRUE
		catch
			return FALSE
		done

		def IsEvaluableRingCode()
			return This.IsValidRingCode()

		def IsRingCode()
			return This.IsValidRingCode()

	  #------------------------------------------------#
	 #    EXECUTING RING CODE HOSTED IN THE STRING    # 
	#------------------------------------------------#

	def Execute()
		if This.IsValidRingCode()
			eval(This.String())
		ok

		def Run()
			This.Execute()

	def ExecuteAndReturn()
		if This.StartsWithCS("return ", :CS = FALSE)
			eval(This.String())
		else
			cCode = "return " + This.String()
			eval(cCode)
		ok

		def RunAndReturn()
			This.ExecuteAndReturn()

	  #----------------------------#
	 #     CLEARING THE STRING    #
	#----------------------------#

	// Clears the string (text becomes "")
	def Clear()
		This.Update("")

		#< @FunctionFluentForm

		// Clears the string and return it as a StzObject
		// to take other actions on it
		def ClearQ()
			This.Clear()
			return This

		#>

	// Verifies if the string text is empty (null)
	def IsEmpty()
		return This.Content() = ""

		def IsNull()
			return This.IsEmpty()

	  #---------------------------------------#
	 #      RESIZING, FILLING & UPDATING     #
	#---------------------------------------#

	// Resizes the string and fills the new Chars with cChar
	def Fill(n, cChar)
		// TODO

		#< @FunctionFluentForm

		def FillQ(n, cChar)
			This.Fill(n, cChar)
			return This

		#>
		
	// Sets the size of the string to n Chars
	def Resize(n)
		cResult = NULL

		if n <= NumberOfChars()
			cResult = Left(n)
		else
			cResult = This.SplitForward(n)
		ok

		This.Update(cResult)
		
		#< @FunctionFluentForm

		def ResizeQ(n)
			This.Resize(n)
			return This
	
		#>

	// Updates the string with a new text
	def Update(pcNewText)
		if isList(pcNewText) and
		   ( StzListQ(pcNewText).IsWithParamList() or StzListQ(pcNewText).IsUsingParamList() )

			pcNewText = pcNewText[2]

		ok
	
		@oQString.clear()
		@oQString.append(pcNewText)

		//This.VerifyConstraints()

		#< @FunctionAlternativeForms

		def UpdateWith(cNewText)
			This.Update(cNewText)

		#>

		#< @FunctionFluentForm	

		def UpdateQ(cNewText)
			This.Update()
			return This

			#< @FunctionAlternativeForms

			def UpdateWithQ(cNewText)
				This.UpdateWith(cNewText)
				return This		

			#>

		#>

	  #----------------------------------------#
	 #     CONTAINING ONLY SPACES & LETTERS   #
	#----------------------------------------#

	// Verifies if the string contains only spaces
	def ContainsOnlySpaces()
		if This.content() = ""
			return FALSE
		ok

		bResult = TRUE

		for i = 1 to This.NumberOfChars()
			c = This.NthChar(i)

			if c != " "
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def ContainsOnlyLetters()
		bResult = TRUE

		for i = 1 to This.NumberOfChars()
			if NOT This.CharAtQ(i).IsLetter()
				bResult = FALSE
				exit
			ok
		next

		return bResult

	  #-----------------------------------------#
	 #      STARTS OR ENDS WITH A SUBSTRING    #
	#-----------------------------------------#

	// Verifies if the string begins with a given substring

	def StartsWithCS(pcSubStr, pCaseSensitive)
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT 	isNumber(pCaseSensitive) and
			( pCaseSensitive = 0 or pCaseSensitive = 1 )

			stzRaise("Invalid param. pCaseSensitive must be 0 or 1 (TRUE or FALSE).")

		else
			return @oQString.startsWith(pcSubStr, pCaseSensitive)
		ok

		def BeginsWithCS(pcSubStr, pCaseSensitive)
			return This.StartsWithCS(pcSubStr, pCaseSensitive)
	
	def StartsWith(pcSubStr)
		return @oQString.startsWith(pcSubStr, 0)

		def BeginsWith(pcSubStr)
			return This.StartsWith(pcSubStr)

	def BeginsWithOneOfTheseCS(paSubStr, pCaseSensitive)
		bResult = FALSE

		for cSubStr in paSubStr
			if This.BeginsWithCS(cSubStr, pCaseSensitive)
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def StartsWithOneOfTheseCS(paSubStr, pCaseSensitive)
			return This.BeginsWithOneOfTheseCS(paSubStr, pCaseSensitive)

	def BeginsWithOneOfThese(paSubStr)
		return This.BeginsWithOneOfTheseCS(paSubStr, :CaseSensitive = TRUE)

		def StartsWithOneOfThese(paSubStr)
			return This.BeginsWithOneOfThese(paSubStr)

	// Verifies if the string begins with a given substring
	def EndsWithCS(pcSubStr, pCaseSensitive)
		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT 	isNumber(pCaseSensitive) and
			( pCaseSensitive = 0 or pCaseSensitive = 1 )

			stzRaise("Invalid param. pCaseSensitive must be TRUE or FALSE (0 or 1).")

		else

			return @oQString.endsWith(pcSubStr, pCaseSensitive)
		ok

		def FinishsWithCS(pcSubStr, pCaseSensitive)
				return This.EndsWithCS(pcSubStr, pCaseSensitive)

	def EndsWith(pcSubStr)
		return @oQString.endsWith(pcSubStr, 0)

		def FinishsWith(pcSubStr)
			return This.EndsWith()

	def EndsWithOneOfTheseCS(paSubStr, pCaseSensitive)
		bResult = FALSE

		for cSubStr in paSubStr
			if This.EndsWithCS(cSubStr, pCaseSensitive)
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def FinishsWithOneOfTheseCS(paSubStr, pCaseSensitive)
			return This.EndsWithOneOfTheseCS(paSubStr, pCaseSensitive)

	def endsWithOneOfThese(paSubStr)
		return This.BeginsWithOneOfTheseCS(paSubStr, :CaseSensitive = TRUE)

		def FinsihsWithOneOfThese(paSubStr)
			return This.EndsWithOneOfThese(paSubStr)

	  #----------------------------------------------------#
	 #      FINDING THE NTH OCCURRENCE OF SUBSTRING       #
	#----------------------------------------------------#

	def NthOccurrenceCS(n, pcSubstr, pCaseSensitive) # --> Returns 0 if nothing found

		if n = :FirstChar or n = :StartOfString
			n = 1
		but n = :LastChar or n = :EndOfString
			n = This.NumberOfOccurrence(pcSubStr)
		ok

		if isList(pcSubStr) and StzListQ(pcSubStr).IsOfParamList()
			pcSubStr = pcSubStr[2]
		ok

		if n >= 1 and n <= This.NumberOfOccurrenceCS(pcSubstr, pCaseSensitive)
			return This.FindAllCS(pcSubStr, pCaseSensitive)[n]

		else
			return 0
		ok

		#< @FunctionAlternativeForm

		def FindNthOccurrenceCS(n, pcSubstr, pCaseSensitive)
			return This.NthOccurrenceCS(n, pcSubstr, pCaseSensitive)

		#>

	def NthOccurrence(n, pcSubstr)
		return This.NthOccurrenceCS(n, pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindNthOccurrence(n, pcSubstr)
			return This.NthOccurrence(n, pcSubStr)
	
		#>

	  #---------------------------------------------------#
	 #      FINDING FIRST OCCURRENCE OF A SUBSTRING      #
	#---------------------------------------------------#

	// Returns the position of the 1st occurrence of the substring inside the string
	// or returns 0 if nothing found

	def FindFirstOccurrenceCS(pcSubStr, pCaseSensitive)

		if isList(pcSubStr) and StzListQ(pcSubStr).IsOfParamList()
			pcSubStr = pcSubStr[2]
		ok

		nPos = 0 
		aResult = []

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT 	isNumber(pCaseSensitive) and
			( pCaseSensitive = 0 or pCaseSensitive = 1 )

			stzRaise("Invalid param. pCaseSensitive must be TRUE or FALSE (0 or 1).")

		else
		
			oSubStr = new stzString(pcSubStr)
			nLenSubStr = oSubStr.NumberOfChars()
		
			return @oQString.indexOf(pcSubStr, 0, pCaseSensitive) + 1
		ok

		#< @FunctionAlternativeForms

		def FindFirstCS(pcSubStr, pCaseSensitive)
			return This.FindFirstOccurrenceCS(pcSubStr, pCaseSensitive)

		def FirstOccurrenceCS(pcSubStr, pCaseSensitive)
			return This.FindFirstOccurrenceCS(pcSubStr, pCaseSensitive)

		#>

	def FindFirstOccurrence(pcSubstr)
		return This.FindFirstOccurrenceCS(pcSubstr, :CaseSensitive = TRUE)
	
		#< @FunctionAlternativeForms
	
		def FirstOccurrenceOf(pcSubStr)
			return This.FindFirstOccurrence(pcSubStr)
	
		def FindFirst(pcSubStr)
			return This.FindFirstOccurrence(pcSubStr)
	
		def FirstOccurrence(pcSubStr)
			return This.FindFirstOccurrence(pcSubStr)
		
		#>

	  #-------------------------------------------------#
	 #      FINDING LAST OCCURRENCE OF A SUBSTRING     #
	#-------------------------------------------------#

	def FindLastOccurrenceCS(pcSubstr, pCaseSensitive)
		if isList(pcSubStr) and StzListQ(pcSubStr).IsOfParamList()
			pcSubStr = pcSubStr[2]
		ok
	
		aTemp = This.FindAllCS(pcSubStr, pCaseSensitive)
		return aTemp[ len(aTemp) ]
	
		#< @FunctionAlternativeForm
	
		def FindLastCS(pcSubStr, pCaseSensitive)
			return This.FindLastOccurrenceCS(pcSubStr, pCaseSensitive)
			
		#>

	def FindLastOccurrence(pcSubStr)
		return This.FindLastOccurrenceCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindLast(pcSubStr)
			return This.FindLastOccurrence(pcSubStr)

		#>

	   #---------------------------------------------#
	  #   FINDING NEXT OCCURRENCES OF A SUBSTRING   #
	 #   STARTING AT A GIVEN POSITION              #
	#---------------------------------------------#

	def FindNextOccurrencesCS(pcSubStr, pnStartingAt, pCaseSensitive)
		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		oSection = This.SectionQ(pnStartingAt, :LastChar)

		anPositions = oSection.FindAllCS(pcSubStr, pCaseSensitive)
		
		anResult = StzListOfNumbersQ(anPositions).AddToEachQ(pnStartingAt).Content()

		return anResult

		#< @FunctionAlternativeForms

		def FindAllNextCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrencesCS(pcSubStr, pnStartingAt, pCaseSensitive)

		def NextOccurrencesCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindNextOccurrencesCS(pcSubStr, pnStartingAt, pCaseSensitive)

		#>
		
	def FindNextOccurrences(pcSubStr, pnStartingAt)
		aResult = This.FindNextOccurrencesCS(pcSubStr, pnStartingAt, :CaseSensitive = TRUE)
		return aResult

		#< @FunctionAlternativeForms

		def FindAllNext(pcSubStr, pnStartingAt)
			return This.FindNextOccurrences(pcSubStr, pnStartingAt)

		def NextOccurrences(pcSubStr, pnStartingAt)
			return This.FindNextOccurrencesCS(pcSubStr, pnStartingAt)

		#>

	   #-------------------------------------------------#
	  #   FINDING PREVIOUS OCCURRENCES OF A SUBSTRING   #
	 #   STARTING AT A GIVEN POSITION                  #
	#-------------------------------------------------#

	def FindPreviousOccurrencesCS(pcSubStr, pnStartingAt, pCaseSensitive)
		if isList(pnStartingAt) and StzListQ(pnStartingAt).IsStartingAtParamList()
			pnStartingAt = pnStartingAt[2]
		ok

		oSection = This.SectionQ(1, pnStartingAt)

		anPositions = oSection.FindAllCS(pcSubStr, pCaseSensitive)
		
		return anPositions

		#< @FunctionAlternativeForms

		def FindAllPreviousCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrencesCS(pcSubStr, pnStartingAt, pCaseSensitive)

		def PreviousOccurrencesCS(pcSubStr, pnStartingAt, pCaseSensitive)
			return This.FindPreviousOccurrencesCS(pcSubStr, pnStartingAt, pCaseSensitive)

		#>

	def FindPreviousOccurrences(pcSubStr, pnStartingAt)
		aResult = This.FindPreviousOccurrencesCS(pcSubStr, pnStartingAt, :CaseSensitive = TRUE)
		return aResult

		#< @FunctionAlternativeForms

		def FindAllPrevious(pcSubStr, pnStartingAt)
			return This.FindPreviousOccurrences(pcSubStr, pnStartingAt)

		def PreviousOccurrences(pcSubStr, pnStartingAt)
			return This.FindPreviousOccurrences(pcSubStr, pnStartingAt)

		#>

	   #-----------------------------------------------------#
	  #      FINDING NTH NEXT OCCURRENCE OF A SUBSTRING     #
	 #      STARTING AT A GIVEN POSITION                   #
	#-----------------------------------------------------#

	def FindNthNextOccurrenceCS( n, pcSubStr, nStart, pCaseSensitive )
		if isList(pcSubStr) and StzListQ(pcSubStr).IsOfParamList()
			pcSubStr = pcSubStr[2]
		ok

		if isList(nStart) and StzListQ(nStart).IsStartingAtParamList()
			nStart = nStart[2]
		ok

		oString = This.SectionQ(nStart, :LastChar)

		nNumberOfOccurrences = oString.NumberOfOccurrenceCS( pcSubStr, pCaseSensitive )

		if n > 0 and n <= nNumberOfOccurrences and
		   nStart > 0 and nStart <= This.NumberOfChars()

			nResult = oString.FindNthOccurrenceCS(n, pcSubStr, pCaseSensitive) + nStart - 1
			return nResult

		else
			return 0
		ok

		def FindNextNthOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthNextOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def FindNextNthCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthNextOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def FindNthNextCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthNextOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def PositionOfNthNextOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthNextOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def PositionOfNextNthOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthNextOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def PositionOfNextNthCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthNextOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def PositionOfNthNextCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthNextOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def NthNextOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthNextOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def NextNthOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthNextOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

	def FindNthNextOccurrence(n, pcSubStr, nStart)
		return This.FindNthNextOccurrenceCS(n, pcSubStr, nStart, :CaseSensitive = TRUE)

		def FindNextNthOccurrence(n, pcSubStr, nStart)
			return This.FindNthNextOccurrence(n, pcSubStr, nStart)

		def FindNextNth(n, pcSubStr, nStart)
			return This.FindNthNextOccurrence(n, pcSubStr, nStart)

		def FindNthNext(n, pcSubStr, nStart)
			return This.FindNthNextOccurrence(n, pcSubStr, nStart)

		def PositionOfNthNextOccurrence(n, pcSubStr, nStart)
			return This.FindNthNextOccurrence(n, pcSubStr, nStart)

		def PositionOfNextNthOccurrence(n, pcSubStr, nStart)
			return This.FindNthNextOccurrence(n, pcSubStr, nStart)

		def PositionOfNextNth(n, pcSubStr, nStart)
			return This.FindNthNextOccurrence(n, pcSubStr, nStart)

		def PositionOfNthNext(n, pcSubStr, nStart)
			return This.FindNthNextOccurrence(n, pcSubStr, nStart)

		def NthNextOccurrence(n, pcSubStr, nStart)
			return This.FindNthNextOccurrence(n, pcSubStr, nStart)

		def NextNthOccurrence(n, pcSubStr, nStart)
			return This.FindNthNextOccurrence(n, pcSubStr, nStart)

	   #---------------------------------------------------------#
	  #      FINDING NTH PREVIOUS OCCURRENCE OF A SUBSTRING     #
	 #      STARTING AT A GIVEN POSITION                       #
	#---------------------------------------------------------#

	def FindNthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		if isList(pcSubStr) and StzListQ(pcSubStr).IsOfParamList()
			pcSubStr = pcSubStr[2]
		ok

		if isList(nStart) and StzListQ(nStart).IsStartingAtParamList()
			nStart = nStart[2]
		ok

		oString = This.SectionQ(1, nStart)

		anPositions = oString.FindAllCS(pcSubStr, pCaseSensitive)
		nNumberOfOccurrences = len(anPositions)

		if nNumberOfOccurrences = 0 or n > nNumberOfOccurrences
			return 0
		else
			return anPositions[ nNumberOfOccurrences - n + 1 ]
		ok

		#< @FunctionAlternativeForms

		def FindPreviousNthOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def FindPreviousNthCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def FindNthPreviousCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def PositionOfNthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def PositionOfPreviousNthOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def PositionOfPreviousNthCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def PositionOfNthPreviousCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def NthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

		def PreviousNthOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			return This.FindNthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

	def FindNthPreviousOccurrence(n, pcSubStr, nStart)
		return This.FindNthPreviousOccurrenceCS(n, pcSubStr, nStart, :CaseSensitive = TRUE)

		def FindPreviousNthOccurrence(n, pcSubStr, nStart)
			return This.FindNthPreviousOccurrence(n, pcSubStr, nStart)

		def FindPreviousNth(n, pcSubStr, nStart)
			return This.FindNthPreviousOccurrence(n, pcSubStr, nStart)

		def FindNthPrevious(n, pcSubStr, nStart)
			return This.FindNthPreviousOccurrence(n, pcSubStr, nStart)

		def PositionOfNthPreviousOccurrence(n, pcSubStr, nStart)
			return This.FindNthPreviousOccurrence(n, pcSubStr, nStart)

		def PositionOfPreviousNthOccurrence(n, pcSubStr, nStart)
			return This.FindNthPreviousOccurrence(n, pcSubStr, nStart)

		def PositionOfPreviousNth(n, pcSubStr, nStart)
			return This.FindNthPreviousOccurrence(n, pcSubStr, nStart)

		def PositionOfNthPrevious(n, pcSubStr, nStart)
			return This.FindNthPreviousOccurrence(n, pcSubStr, nStart)

		def NthPreviousOccurrence(n, pcSubStr, nStart)
			return This.FindNthPreviousOccurrence(n, pcSubStr, nStart)

		def PreviousNthOccurrence(n, pcSubStr, nStart)
			return This.FindNthPreviousOccurrence(n, pcSubStr, nStart)
	   #-------------------------------------------------#
	  #      FINDING NEXT OCCURRENCE OF A SUBSTRING     #
	 #      STARTING AT A GIVEN POSITION               #
	#-------------------------------------------------#

	def FindNextOccurrenceCS(pcSubStr, nStart, pCaseSensitive)
		return This.FindNextNthOccurrenceCS(1, pcSubStr, nStart, pCaseSensitive)
	
		def FindNextCS(pcSubStr, nStart, pCaseSensitive)
			return This.FindNextOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def FindNextFirstCS()
			return This.FindNextOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def FindFirstNextCS()
			return This.FindNextOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def PositionOfNextFirstCS()
			return This.FindNextOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def PositionOfFirstNextCS()
			return This.FindNextOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def NextOccurrenceCS(pcSubStr, nStart, pCaseSensitive)
			return This.FindNextOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def NextFirstOccurrenceCS()
			return This.FindNextOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def FirstNextOccurrenceCS()
			return This.FindNextOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def FindNextOccurrence(pcSubStr, nStart)
		return This.FindNextOccurrenceCS(pcSubStr, nStart, :CaseSensitive = TRUE)
	
		def FindNext(pcSubStr, nStart)
			return This.FindNextOccurrence(pcSubStr, nStart)

		def FindNextFirst()
			return This.FindNextOccurrenceCS(pcSubStr, nStart)

		def FindFirstNext()
			return This.FindNextOccurrence(pcSubStr, nStart)

		def PositionOfNextFirst()
			return This.FindNextOccurrenceC(pcSubStr, nStart)

		def PositionOfFirstNext()
			return This.FindNextOccurrence(pcSubStr, nStart)

		def NextOccurrence(pcSubStr, nStart)
			return This.FindNextOccurrence(pcSubStr, nStart)

		def NextFirstOccurrence()
			return This.FindNextOccurrenceCS(pcSubStr, nStart)

		def FirstNextOccurrence()
			return This.FindNextOccurrenceCS(pcSubStr, nStart)

	   #-----------------------------------------------------#
	  #      FINDING PREVIOUS OCCURRENCE OF A SUBSTRING     #
	 #      STARTING FROM A GIVEN POSITION N               #
	#-----------------------------------------------------#

	def FindPreviousOccurrenceCS(pcSubStr, nStart, pCaseSensitive)
		return This.FindPreviousNthOccurrenceCS(1, pcSubStr, nStart, pCaseSensitive)
	
		def FindPreviousCS(pcSubStr, nStart, pCaseSensitive)
			return This.FindPreviousOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def FindPreviousFirstCS()
			return This.FindPreviousOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def FindFirstPreviousCS()
			return This.FindPreviousOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def PositionOfPreviousFirstCS()
			return This.FindPreviousOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def PositionOfFirstPreviousCS()
			return This.FindPreviousOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def PreviousOccurrenceCS(pcSubStr, nStart, pCaseSensitive)
			return This.FindPreviousOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def PreviousFirstOccurrenceCS()
			return This.FindPreviousOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

		def FirstPreviousOccurrenceCS()
			return This.FindPreviousOccurrenceCS(pcSubStr, nStart, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def FindPreviousOccurrence(pcSubStr, nStart)
		return This.FindPreviousOccurrenceCS(pcSubStr, nStart, :CaseSensitive = TRUE)
	
		def FindPrevious(pcSubStr, nStart)
			return This.FindPreviousOccurrence(pcSubStr, nStart)

		def FindPreviousFirst()
			return This.FindPreviousOccurrenceCS(pcSubStr, nStart)

		def FindFirstPrevious()
			return This.FindPreviousOccurrence(pcSubStr, nStart)

		def PositionOfPreviousFirst()
			return This.FindPreviousOccurrenceC(pcSubStr, nStart)

		def PositionOfFirstPrevious()
			return This.FindPreviousOccurrence(pcSubStr, nStart)

		def PreviousOccurrence(pcSubStr, nStart)
			return This.FindPreviousOccurrence(pcSubStr, nStart)

		def PreviousFirstOccurrence()
			return This.FindPreviousOccurrenceCS(pcSubStr, nStart)

		def FirstPreviousOccurrence()
			return This.FindPreviousOccurrenceCS(pcSubStr, nStart)

	  #-------------------------------------------------#
	 #      FINDING ALL OCCURRENCES OF A SUBSTRING     #
	#-------------------------------------------------#

	// Returns the list of start-positions of the substring inside the string
	def FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		if isList(pcSubStr) and StzListQ(pcSubStr).IsOfParamList()
			pcSubStr = pcSubStr[2]
		ok

		if This.ContainsNoCS(pcSubStr, pCaseSensitive)
			return NULL
		ok

		aResult = []

		oCopy = This.Copy()

		bSomeOccurrencesLeft = TRUE

		while bSomeOccurrencesLeft
	
			nPos = oCopy.FindFirstCS(pcSubStr, pCaseSensitive)

			if nPos = 0
				bSomeOccurrencesLeft = FALSE
			else
				// An occurrence is found
				aResult + nPos

				// Removing the substring and rewinding
				oCopy.RemoveSection(1, nPos + StzStringQ(pcSubStr).NumberOfChars()-1 )	
			ok
			
		end

		if len(aResult) > 1
			for i = 2 to len(aResult)
				aResult[i] += aResult[i-1] + StzStringQ(pcSubStr).NumberOfChars()-1
			next i
		ok

		return aResult

		#< @FunctionAlternativeForms

		def FindCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		def FindAllCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		def FindOccurrencesCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		def FindSubstringCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		def OccurrencesCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		def FindOccurrenceCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		def OccurrenceCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		def PositionsCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		def PositionsOfSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		def FindPositionsCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		#>

	def FindAllOccurrences(pcSubStr)
		return This.FindAllOccurrencesCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		# NOTE: we don't include find(pcSubStr) as an alternatives
		# because we don't want to make a confusion with the native
		# Ring function find(aList, pItem)

		def FindAll(pcSubStr)
			return This.FindAllOccurrences(pcSubStr)

		def FindOccurrences(pcSubStr)
			return This.FindAllOccurrences(pcSubStr)

		def FindOccurrence(pcSubStr)
			return This.FindAllOccurrences(pcSubStr)

		def FindSubString(pcSubStr)
			return This.FindAllOccurrences(pcSubStr)

		def Occurrences(pcSubStr)
			return This.FindAllOccurrences(pcSubStr)

		def Occurrence(pcSubStr)
			return This.FindAllOccurrences(pcSubStr)

		def Positions(pcStr)
			return This.FindAllOccurrences(pcSubStr)

		def PositionsOfSubString(pcStr)
			return This.FindAllOccurrences(pcSubStr)

		def FindPositions(pcSubStr)
			return This.FindAllOccurrences(pcSubStr)

		#>

	// Returns the list of sections representing the occurrences of
	//  the substring inside the string
	def FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)

		anStartPositions = This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		nLen = StzStringQ(pcSubStr).NumberOfChars()

		anEndPositions = StzListOfNumbers( anStartPositions ).AddToEachQ( nLen - 1 ).Content()

		aResult = StzListQ(anStartPositions).AssociatedWith(anEndPositions)

		return aResult

		#< @FunctionAlternativeForms

		def FindAllOccurrencesXTCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)

		def FindCSXT(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)

			def FindXTCS(pcSubStr, pCaseSensitive)
				return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)

		def FindAllCSXT(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)

			def FindAllXTCS(pcSubStr, pCaseSensitive)
				return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)
	
		def FindOccurrencesCSXT(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)

			def FindOccurrencesXTCS(pcSubStr, pCaseSensitive)
				return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)
	
		def OccurrencesCSXT(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)

			def OccurrencesXTCS(pcSubStr, pCaseSensitive)
				return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)
	
		def FindOccurrenceCSXT(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)

			def FindOccurrenceXTCS(pcSubStr, pCaseSensitive)
				return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)
	
		def OccurrenceCSXT(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)

			def OccurrenceXTCS(pcSubStr, pCaseSensitive)
				return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)
	
		def PositionsCSXT(pcStr, pCaseSensitive)
			return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)

			def PositionsXTCS(pcStr, pCaseSensitive)
				return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)

		def FindPositionsCSXT(pcStr, pCaseSensitive)
			return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)

			def FindPositionsXTCS(pcStr, pCaseSensitive)
				return This.FindAllOccurrencesCSXT(pcSubStr, pCaseSensitive)

		#>

	def FindAllOccurrencesXT(pcSubStr)
		return This.FindAllOccurrencesCSXT(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindXT(pcSubStr)
			return This.FindAllOccurrencesXT(pcSubStr)

		def FindAllXT(pcSubStr)
			return This.FindAllOccurrencesXT(pcSubStr)

		def FindOccurrencesXT(pcSubStr)
			return This.FindAllOccurrencesXT(pcSubStr)

		def FindOccurrenceXT(pcSubStr)
			return This.FindAllOccurrencesXT(pcSubStr)

		def OccurrencesXT(pcSubStr)
			return This.FindAllOccurrencesXT(pcSubStr)

		def OccurrenceXT(pcSubStr)
			return This.FindAllOccurrencesXT(pcSubStr)

		def PositionsXT(pcSubStr)
			return This.FindAllOccurrencesXT(pcSubStr)

		def FindPositionsXT(pcSubStr)
			return This.FindAllOccurrencesXT(pcSubStr)

		#>

	   #---------------------------------------------------------------------#
	  #    FINDING ALL OCCURRENCES OF A CHAR VERIFYING A GIVEN CONDITION    #
	#----------------------------------------------------------------------#

	def FindAllCharsW(pcCondition)
		#< @MotherFunction = YES | @RingBased #>

		if isList(pcCondition) and StzListQ(pcCondition).IsWhereParamList()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			stzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		cCondition = StzStringQ(pcCondition).
				SimplifyQ().
				RemoveBoundsQ("{","}").
				Content()

		cCode = "bOk = ( " + cCondition + " )"

		anResult = []

		@char = ""
		for @i = 1 to This.NumberOfChars()
			@char = This[@i]

			eval(cCode)

			if bOk
				anResult + @i
			ok

		next

		return anResult

		#< @FunctionFluentForm

		def FindAllCharsWQ(pcCondition)
			return This.FindAllCharsWQR(pcCondition, :stzList)

		def FindAllCharsWQR(pcCondition, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllCharsW(pcCondition) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllCharsW(pcCondition) )

			other
				return stzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def FindAllCharsWhere(pcCondition)
			return This.FindAllCharsW(pcCondition)

			def FindAllCharsWhereQ(pcCondition)
				return This.FindAllCharsWhereQR(pcCondition, :stzList)
	
			def FindAllCharsWhereQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.FindAllCharsWhere(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindAllCharsWhere(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off

		def FindCharsW(pcCondition)
			return This.FindAllCharsW(pcCondition)

			def FindCharsWQ(pcCondition)
				return This.FindCharsWQR(pcCondition, :stzList)
	
			def FindCharsWQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.FindCharsW(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindCharsW(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off

		def FindCharsWhere(pcCondition)
			return This.FindCharsW(pcCondition)

			def FindCharsWhereQ(pcCondition)
				return This.FindCharsWhereQR(pcCondition, :stzList)
	
			def FindCharsWhereQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.FindCharsWhere(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindCharsWhere(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off

		def CharsPositionsW(pCondition)
			return This.FindAllCharsW(pcCondition)

			def CharsPositionsWQ(pcCondition)
				return This.CharsPositionsWQR(pcCondition, :stzList)
	
			def CharsPositionsWQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.CharsPositionsW(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.CharsPositionsW(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off

		def CharsPositionsWhere(pCondition)
			return This.FindAllCharsW(pcCondition)

			def CharsPositionsWhereQ(pcCondition)
				return This.CharsPositionsWhereQR(pcCondition, :stzList)
	
			def CharsPositionsWhereQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.CharsPositionsWhere(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.CharsPositionsWhere(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off

		def FindCharsPositionsW(pcCondition)
			return This.FindAllCharsW(pcCondition)

			def FindCharsPositionsWQ(pcCondition)
				return This.FindCharsPositionsWQR(pcCondition, :stzList)
	
			def FindCharsPositionsWQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.FindCharsPositionsW(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindCharsPositionsW(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off

		def FindCharsPositionsWhere(pcCondition)
			return This.FindAllCharsW(pcCondition)

			def FindCharsPositionsWhereQ(pcCondition)
				return This.FindCharsPositionsWhereQR(pcCondition, :stzList)
	
			def FindCharsPositionsWhereQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.FindCharsPositionsWhere(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindCharsPositionsWhere(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off

		def FindW(pcCondition)
			return This.FindAllCharsW(pcCondition)

			def FindWQ(pcCondition)
				return This.FindWQR(pcCondition, :stzList)
	
			def FindWQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.FindW(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindW(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off
			

		#>

	  #--------------------------------------------------#
	 #      FINDING MANY SYBSTRINGS IN THE SAME TIME    # 
	#--------------------------------------------------#

	def FindManyCS(pacSubStr, pCaseSensitive)
		/*
		o1 = new stzString("My name is Mansour. What's your name please?")
		? o1.FindManyCS( [ "name", "your", "please" ], :CS = TRUE )

		# --> [ [ 4, 33 ], [ 28 ], [ 38 ] ]

		*/

		aResult = []

		for str in pacSubStr
			aResult + This.FindAllCS(str, pCaseSensitive)
		next

		return aResult

		def FindManySubStringsCS(pacSubStr, pCaseSensitive)
			return This.FindManyCS(pacSubStr, pCaseSensitive)

	def FindMany(pacSubStr)
		/*
		o1 = new stzString("My name is Mansour. What's your name please?")
		? o1.FindMany( [ "name", "your", "please" ] )

		# --> [ [ 4, 33 ], [ 28 ], [ 38 ] ]

		*/

		return This.FindManyCS(pacSubStr, :CaseSensitive = TRUE)

		def FindManySubStrings(pacSubStr)
			return This.FindMany(pacSubStr)

	def FindManyCSXT(pacSubStr, pCaseSensitive)
		/*
		o1 = new stzString("My name is Mansour. What's your name please?")
		? o1.FindManyCSXT( [ "name", "your", "please" ], :CS = TRUE )

		--> [ "name" = [ 4, 33 ], "your" = [ 28 ], "please" = [ 38 ] ]

		*/

		aResult = []

		for str in pacSubStr
			aResult + [ str, This.FindAllCS(str, pCaseSensitive) ]
		next

		return aResult

		def FindManySubstringsCSXT(pacSubStr, pCaseSensitive)
			return This.FindManyCSXT(pacSubStr, pCaseSensitive)

		def FindManyXTCS(pacSubStr, pCaseSensitive)
			return This.FindManyCSXT(pacSubStr, pCaseSensitive)

		def FindManySubstringsXTCS(pacSubStr, pCaseSensitive)
			return This.FindManyCSXT(pacSubStr, pCaseSensitive)

	def FindManyXT(pacSubStr)
		/*
		o1 = new stzString("My name is Mansour. What's your name please?")
		? o1.FindManyXT( [ "name", "your", "please" ] )

		--> [ "name" = [ 4, 33 ], "your" = [ 28 ], "please" = [ 38 ] ]

		*/

		return This.FindManyCSXT(pacSubStr, :CaseSensitive = TRUE)

		def FindManySubstringsXT(pacSubStr)
			return This.FindManyXT(pacSubStr)

#-------------------------------------------------------------------------------------------
	  #---------------------------------------#
	 #      FINDING BY FORMAT (REGEXP)       # TODO
	#---------------------------------------#

	// Finds all the occurrences of a given substring in the string depending on the provided format
	def FindByFormat(paFormat)
		// TODO: Use Regular expressions


	def FindInside(pcTemplate) // TODO
		/*
		o1 = new stzString("opsus amcKLMbmi findus")
		o1.FindInside("KLM", 'amc@bmi') # --> 10

		o1.FindInside("KLM", lower("AMC") + '@' + lower("BMI") # -->

		*/

	def FindInsideW(pcTemplate, pcCondition) # TODO
		/*
		o1 = new stzString("opsus amcKLMbmi findus")
		o1.FindInsideW("KLM", :Where = [
			'{ _(3).CharsBefore = "amc" }',
			'{ _(3).CharsAfter = "bmi" ='
		])
		*/

	  #--------------------------------------------------------------------------#
	 #   FINDING SUBSTRING BETWEEN TWO SUBSTRINGS AND RETURN RELATIVE SECTIONS  #
	#--------------------------------------------------------------------------#

	def FindSectionsOfSubStringCS(pcSubStr, pCaseSensitive)
		anFirstPositions = This.FindAllCS(pcSubStr, pCaseSensitive)

		nLen = StzStringQ(pcSubStr).NumberOfChars()

		anLastPositions = StzListOfNumbersQ(anFirstPositions).AddToEachQ(nLen-1).Content()

		aResult = StzListQ(anFirstPositions).AssociatedWith(anLastPositions)

		return aResult

		def FindSectionsCS(pcSubStr, pCaseSensitive)
			return This.FindSectionsOfSubStringCS(pcSubStr, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def FindSectionsOfSubString(pcSubStr)
		return This.FindSectionsOfSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def FindSections(pcSubStr)
			return This.FindSectionsOfSubString(pcSubStr)


	  #-------------------------------------------------------------------------#
	 #   FINDING ALL OCCURRENCES OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS   #
	#-------------------------------------------------------------------------#

	def FindSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
		? o1.FindBetweenCS("word", "<<", ">>", :CaseSensitive = FALSE)
		
		(we used here the simple form of the function)

		#--> [ 9, 41 ]
		*/

		aSections = FindSectionsOfSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		
		anResult = []

		for aPair in aSections
			anResult + aPair[1]
		next

		return anResult

		#< @FunctionFluentForm

		def FindSubstringBoundedWithCSQ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringBoundedWithCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSubstringBoundedWithCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off
	
		#>

		#< @FunctionAlternativeForms

		def FindSubstringBoundedByCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSubstringBoundedByCSQ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSubstringBoundedByCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSubstringBoundedByCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubstringBoundedByCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSubstringBoundedByCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off				

		def FindSubstringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSubstringBetweenCSQ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSubstringBetweenCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSubstringBetweenCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubstringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSubstringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindBetweenCSQ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindBetweenCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindBetweenCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

	#-- CASE-INSENSITIVE

	def FindSubstringBoundedWith(pcSubStr, pcSubStr1, pcSubStr2)
		return This.FindSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindSubstringBoundedWithQ(pcSubStr, pcSubStr1, pcSubStr2)
			return This.FindSubstringBoundedWithQR(pcSubStr, pcSubStr1, pcSubStr2, :stzList)

			def FindSubstringBoundedWithQR(pcSubStr, pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubstringBoundedWith(pcSubStr, pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSubstringBoundedWith(pcSubStr, pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off
	
		#>

		#< @FunctionAlternativeForms

		def FindSubstringBoundedBy(pcSubStr, pcSubStr1, pcSubStr2)
			return This.FindSubstringBoundedWith(pcSubStr, pcSubStr1, pcSubStr2)

			def FindSubstringBoundedByQ(pcSubStr, pcSubStr1, pcSubStr2)
				return This.FindSubstringBoundedByQR(pcSubStr, pcSubStr1, pcSubStr2, :stzList)

			def FindSubstringBoundedByQR(pcSubStr, pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubstringBoundedBy(pcSubStr, pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSubstringBoundedBy(pcSubStr, pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off				

		def FindSubstringBetween(pcSubStr, pcSubStr1, pcSubStr2)
			return This.FindSubstringBoundedWith(pcSubStr, pcSubStr1, pcSubStr2)

			def FindSubstringBetweenQ(pcSubStr, pcSubStr1, pcSubStr2)
				return This.FindSubstringBetweenQR(pcSubStr, pcSubStr1, pcSubStr2, :stzList)

			def FindSubstringBetweenQR(pcSubStr, pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubstringBetween(pcSubStr, pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSubstringBetween(pcSubStr, pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindBetween(pcSubStr, pcSubStr1, pcSubStr2)
			return This.FindSubstringBoundedWith(pcSubStr, pcSubStr1, pcSubStr2)

			def FindBetweenQ(pcSubStr, pcSubStr1, pcSubStr2)
				return This.FindBetweenQR(pcSubStr, pcSubStr1, pcSubStr2, :stzList)

			def FindBetweenQR(pcSubStr, pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindBetween(pcSubStr, pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindBetween(pcSubStr, pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

	   #-------------------------------------------------------------#
	  #   FINDING ALL OCCURRENCES OF A SUBSTRING BETWEEN            #
	 #   TWO OTHER SUBSTRINGS AND RETURN THEIR RELATIVE SECTIONS   #
	#-------------------------------------------------------------#

	def FindSectionsOfSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
		/* EXAMPLE
		o1 = new stzString("bla bla <<word>> bla bla <<noword>> bla <<word>>")
		? o1.FindSectionsBetweenCS("word", "<<", ">>", :CaseSensitive = FALSE)
		
		(we used here the simple form of the function)

		#--> [ [ 9, 10 ], [ 26, 27 ], [ 41, 42 ] ]
		*/

		# Getting all the occurrences of pcSubStr in the string

		aSections = This.FindSectionsCS(pcSubStr, pCaseSensitive)
		#--> [ [ 11, 15 ], [ 30, 34 ], [ 43, 47 ] ]

		# Checking the ones that are boundede by pcSubStr1 (<<) and pcSubStr2 (>>)

		nLen1 = StzStringQ(pcSubStr1).NumberOfChars()
		nLen2 = StzStringQ(pcSubStr2).NumberOfChars()

		for aPair in aSections
			aPair[1] -= nLen1
			aPair[2] += nLen2
		next

		anResult = []

		for aPair in aSections
			cStr = This.Section(aPair[1], aPair[2])
			if StzStringQ(cStr).IsBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive)
				anResult + aPair
			ok
		next

		return anResult

		#< @FunctionFluentForm

		def FindSectionsOfSubstringBoundedWithCSQ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsOfSubstringBoundedWithCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSectionsOfSubstringBoundedWithCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off
	
		#>

		#< @FunctionAlternativeForms

		def FindSectionsOfSubstringBoundedByCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsOfSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSectionsOfSubstringBoundedByCSQ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSectionsOfSubstringBoundedByCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSectionsOfSubstringBoundedByCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfSubstringBoundedByCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfSubstringBoundedByCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off				

		def FindSectionsOfSubstringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsOfSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSectionsOfSubstringBetweenCSQ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSectionsOfSubstringBetweenCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSectionsOfSubstringBetweenCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfSubstringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfSubstringBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindSectionsBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsOfSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSectionsBetweenCSQ(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSectionsBetweenCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSectionsBetweenCSQR(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsBetweenCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

	#-- CASE-INSENSITIVE

	def FindSectionsOfSubstringBoundedWith(pcSubStr, pcSubStr1, pcSubStr2)
		return This.FindSectionsOfSubstringBoundedWithCS(pcSubStr, pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def FindSectionsOfSubstringBoundedWithQ(pcSubStr, pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringBoundedWithQR(pcSubStr, pcSubStr1, pcSubStr2, :stzList)

			def FindSectionsOfSubstringBoundedWithQR(pcSubStr, pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfSubstringBoundedWith(pcSubStr, pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfSubstringBoundedWith(pcSubStr, pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off
	
		#>

		#< @FunctionAlternativeForms

		def FindSectionsOfSubstringBoundedBy(pcSubStr, pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringBoundedWith(pcSubStr, pcSubStr1, pcSubStr2)

			def FindSectionsOfSubstringBoundedByQ(pcSubStr, pcSubStr1, pcSubStr2)
				return This.FindSectionsOfSubstringBoundedByQR(pcSubStr, pcSubStr1, pcSubStr2, :stzList)

			def FindSectionsOfSubstringBoundedByQR(pcSubStr, pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfSubstringBoundedBy(pcSubStr, pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfSubstringBoundedBy(pcSubStr, pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off				

		def FindSectionsOfSubstringBetween(pcSubStr, pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringBoundedWith(pcSubStr, pcSubStr1, pcSubStr2)

			def FindSectionsOfSubstringBetweenQ(pcSubStr, pcSubStr1, pcSubStr2)
				return This.FindSectionsOfSubstringBetweenQR(pcSubStr, pcSubStr1, pcSubStr2, :stzList)

			def FindSectionsOfSubstringBetweenQR(pcSubStr, pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfSubstringBetween(pcSubStr, pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfSubstringBetween(pcSubStr, pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindSectionsBetween(pcSubStr, pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringBoundedWith(pcSubStr, pcSubStr1, pcSubStr2)

			def FindSectionsBetweenQ(pcSubStr, pcSubStr1, pcSubStr2)
				return This.FindSectionsBetweenQR(pcSubStr, pcSubStr1, pcSubStr2, :stzList)

			def FindSectionsBetweenQR(pcSubStr, pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsBetween(pcSubStr, pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsBetween(pcSubStr, pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

	  #-----------------------------------------------------------------------#
	 #   FINDING OCCURRENCES OF ANY SUBSTRING BETWEEN TWO OTHER SUBSTRINGS   #
	#-----------------------------------------------------------------------#

	def FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
		? o1.SubstringsBoundedBy("<<", ">>", :CS = FALSE)

		# --> [ "word1", "word2" ]

		The simple form if this method is:

		FindBetween( pcStr, pcSubStr1, pcSubStr2)
		--> Finds all occurrences of pcStr bounded by pcSubStr1 and pcSubStr2

		Remember that:

		FindAnyBetween( pcSubStr1, pcSubStr )
		--> Finds any substring bounded by pcSubStr1 and pcSubStr2

		*/
		aResult = []

		n1 = 1
		n2 = 1

		nLen1 = StzStringQ(pcSubStr1).NumberOfChars()
		nLen2 = StzStringQ(pcSubstr2).NumberOfChars()

		i = 0
		while TRUE
			i++
			if i > This.NumberOfChars() { exit }

			n1 = This.FindNextCS(pcSubStr1, :StartingAt = n1, pCaseSensitive)

			if n1 = 0
				exit
			ok

			n2 = This.FindNextCS(pcSubStr2, :StartingAt = n1 + nLen1, pCaseSensitive)

			if n2 = 0 or n2 > This.NumberOfChars()
				exit
			ok

			aResult + n1 //This.Section(n1 + nLen1, n2 - 1)

			n1 = n2 + nLen2

		end

		return aResult

		#< @FunctionFluentForm

		def FindSubstringsBoundedWithCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringsBoundedWithCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSubstringsBoundedWithCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off
	
		#>

		#< @FunctionAlternativeForms

		def FindSubstringsBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSubstringsBoundedByCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSubstringsBoundedByCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSubstringsBoundedByCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubstringsBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSubstringsBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off				

		def FindSubstringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSubstringsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSubstringsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSubstringsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubstringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSubstringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindBetweenSubstringsCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindBetweenSubstringsCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindBetweenSubstringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindBetweenSubstringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindBetweenSubstringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindBetweenSubstringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindBetweenTheseSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindBetweenTheseSubStringsCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindBetweenTheseSubStringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindBetweenTheseSubStringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindBetweenTheseSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindBetweenTheseSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindBetweenTheseTwoSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindBetweenTheseTwoSubStringsCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindBetweenTheseTwoSubStringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindBetweenTheseTwoSubStringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindBetweenTheseTwoSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindBetweenTheseTwoSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		#--

		def FindAnySubstringBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindAnySubstringBoundedWithCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindAnySubstringBoundedWithCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindAnySubstringBoundedWithCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindAnySubstringBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindAnySubstringBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindAnySubstringBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindAnySubstringBoundedByCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindAnySubstringBoundedByCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindAnySubstringBoundedByCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindAnySubstringBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindanySubstringBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off			

		def FindAnySubstringBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindAnySubstringBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindanySubstringBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindAnySubstringBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindAnySubstringBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindAnySubstringBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindAnyBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindAnyBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindAnyBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindAnyBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindAnyBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindAnyBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off		

		#>

	#-- CASE-INSENSITIVE

	def FindSubstringsBoundedWith(pcSubStr1, pcSubStr2)
		return This.FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, :CaseSensitive = FALSE)

		#< @FunctionFluentForm

		def FindSubstringsBoundedWithQ(pcSubStr1, pcSubStr2)
			return This.FindSubstringsBoundedWithQR(pcSubStr1, pcSubStr2, :stzList)

			def FindSubstringsBoundedWithQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubstringsBoundedWith(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSubstringsBoundedWith(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off
	
		#>

		#< @FunctionAlternativeForms

		def FindSubstringsBoundedBy(pcSubStr1, pcSubStr2)
			return This.FindSubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def FindSubstringsBoundedByQ(pcSubStr1, pcSubStr2)
				return This.FindSubstringsBoundedByQR(pcSubStr1, pcSubStr2, :stzList)

			def FindSubstringsBoundedByQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubstringsBoundedBy(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSubstringsBoundedBy(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off				

		def FindSubstringsBetween(pcSubStr1, pcSubStr2)
			return This.FindSubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def FindSubstringsBetweenQ(pcSubStr1, pcSubStr2)
				return This.FindSubstringsBetweenQR(pcSubStr1, pcSubStr2, :stzList)

			def FindSubstringsBetweenQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubstringsBetween(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSubstringsBetween(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindBetweenSubstrings(pcSubStr1, pcSubStr2)
			return This.FindSubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def FindBetweenSubstringsQ(pcSubStr1, pcSubStr2)
				return This.FindBetweenSubstringsQR(pcSubStr1, pcSubStr2, :stzList)

			def FindBetweenSubstringsQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindBetweenSubstrings(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindBetweenSubstrings(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindBetweenTheseSubStrings(pcSubStr1, pcSubStr2)
			return This.FindSubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def FindBetweenTheseSubStringsQ(pcSubStr1, pcSubStr2)
				return This.FindBetweenTheseSubStringsQR(pcSubStr1, pcSubStr2, :stzList)

			def FindBetweenTheseSubStringsQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindBetweenTheseSubStrings(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindBetweenTheseSubStrings(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindBetweenTheseTwoSubStrings(pcSubStr1, pcSubStr2)
			return This.FindSubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def FindBetweenTheseTwoSubStringsQ(pcSubStr1, pcSubStr2)
				return This.FindBetweenTheseTwoSubStringsQR(pcSubStr1, pcSubStr2, :stzList)

			def FindBetweenTheseTwoSubStringsQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindBetweenTheseTwoSubStrings(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindBetweenTheseTwoSubStrings(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		#--

		def FindAnySubstringBoundedWith(pcSubStr1, pcSubStr2)
			return This.FindSubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def FindAnySubstringBoundedWithQ(pcSubStr1, pcSubStr2)
				return This.FindAnySubstringBoundedWithQR(pcSubStr1, pcSubStr2, :stzList)

			def FindAnySubstringBoundedWithQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindAnySubstringBoundedWith(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindAnySubstringBoundedWith(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindAnySubstringBoundedBy(pcSubStr1, pcSubStr2)
			return This.FindSubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def FindAnySubstringBoundedByQ(pcSubStr1, pcSubStr2)
				return This.FindAnySubstringBoundedByQR(pcSubStr1, pcSubStr2, :stzList)

			def FindAnySubstringBoundedByQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindAnySubstringBoundedBy(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindanySubstringBoundedBy(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off			

		def FindAnySubstringBetween(pcSubStr1, pcSubStr2)
			return This.FindSubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def FindAnySubstringBetweenQ(pcSubStr1, pcSubStr2)
				return This.FindanySubstringBetweenQR(pcSubStr1, pcSubStr2, :stzList)

			def FindAnySubstringBetweenQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindAnySubstringBetween(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindAnySubstringBetween(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindAnyBetween(pcSubStr1, pcSubStr2)
			return This.FindSubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def FindAnyBetweenQ(pcSubStr1, pcSubStr2)
				return This.FindAnyBetweenQR(pcSubStr1, pcSubStr2, :stzList)

			def FindAnyBetweenQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindAnyBetween(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindAnyBetween(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off		

		#>

	   #-------------------------------------------------------------#
	  #   FINDING ALL OCCURRENCES OF A SUBSTRING BETWEEN            #
	 #   TWO OTHER SUBSTRINGS AND RETURN THEIR RELATIVE SECTIONS   #
	#-------------------------------------------------------------#

	def FindSectionsOfSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		
		anStartPositions = This.FindSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		
		anResult = []
		for n in anStartPositions
			n1 = n
			n2 = This.FindNextOccurrenceCS( :Of = pcSubStr2, :StartingAt = n1, pCaseSensitive )
			nLen = n2 - n1

			anResult + [ n1, n2 ]
		next

		return anResult

		#< @FunctionFluentForm

		def FindSectionsOfSubstringsBoundedWithCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsOfSubstringsBoundedWithCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSectionsOfSubstringsBoundedWithCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off
	
		#>

		#< @FunctionAlternativeForms

		def FindSectionsOfSubstringsBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsOfSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSectionsOfSubstringsBoundedByCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSectionsOfSubstringsBoundedByCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSectionsOfSubstringsBoundedByCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfSubstringsBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfSubstringsBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off				

		def FindSectionsOfSubstringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsOfSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSectionsOfSubstringsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSectionsOfSubstringsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSectionsOfSubstringsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfSubstringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfSubstringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindSectionsBetweenSubstringsCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsOfSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSectionsBetweenSubstringsCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSectionsBetweenSubstringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSectionsBetweenSubstringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsBetweenSubstringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsBetweenSubstringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindSectionsBetweenTheseSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSectionsBetweenTheseSubStringsCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSectionsBetweenTheseSubStringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSectionsBetweenTheseSubStringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsBetweenTheseSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsBetweenTheseSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindSectionsBetweenTheseTwoSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSectionBetweenTheseTwoSubStringsCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSectionBetweenTheseTwoSubStringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSectionsBetweenTheseTwoSubStringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsBetweenTheseTwoSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsBetweenTheseTwoSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		#--

		def FindSectionsOfAnySubstringBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsOfSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSectionsOfAnySubstringBoundedWithCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSectionsOfAnySubstringBoundedWithCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSectionsOfAnySubstringBoundedWithCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfAnySubstringBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfAnySubstringBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindSectionsOfAnySubstringBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsOfSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSectionsOfAnySubstringBoundedByCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSectionsOfAnySubstringBoundedByCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSectionsOfAnySubstringBoundedByCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfAnySubstringBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfanySubstringBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off			

		def FindSectionsOfAnySubstringBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsOfSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindSectionsOfAnySubstringBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindSectionsOfAnySubstringBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindSectionsOfAnySubstringBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfAnySubstringBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfAnySubstringBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindAnySectionsCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.FindSectionsOfSubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def FindAnySectionsCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.FindAnySectionsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def FindAnySectionsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindAnySectionsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindAnySectionsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		#>

	#-- CASE-INSENSITIVE

		def FindSectionsOfSubstringsBoundedBy(pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringsBoundedByCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

			def FindSectionsOfSubstringsBoundedByQ(pcSubStr1, pcSubStr2)
				return This.FindSectionsOfSubstringsBoundedByQR(pcSubStr1, pcSubStr2, :stzList)

			def FindSectionsOfSubstringsBoundedByQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfSubstringsBoundedBy(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfSubstringsBoundedBy(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off				

		def FindSectionsOfSubstringsBoundedWith(pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringsBoundedBy(pcSubStr1, pcSubStr2)

			def FindSectionsOfSubstringsBoundedWithQ(pcSubStr1, pcSubStr2)
				return This.FindSectionsOfSubstringsBoundedWithQR(pcSubStr1, pcSubStr2, :stzList)

			def FindSectionsOfSubstringsBoundedWithQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfSubstringsBoundedWith(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfSubstringsBoundedWith(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindSectionsOfSubstringsBetween(pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringsBoundedBy(pcSubStr1, pcSubStr2)

			def FindSectionsOfSubstringsBetweenQ(pcSubStr1, pcSubStr2)
				return This.FindSectionsOfSubstringsBetweenQR(pcSubStr1, pcSubStr2, :stzList)

			def FindSectionsOfSubstringsBetweenQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfSubstringsBetween(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfSubstringsBetween(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindSectionsBetweenSubstrings(pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringsBoundedBy(pcSubStr1, pcSubStr2)

			def FindSectionsBetweenSubstringsQ(pcSubStr1, pcSubStr2)
				return This.FindSectionsBetweenSubstringsQR(pcSubStr1, pcSubStr2, :stzList)

			def FindSectionsBetweenSubstringsQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsBetweenSubstrings(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsBetweenSubstrings(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindSectionsBetweenTheseSubStrings(pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringsBoundedBy(pcSubStr1, pcSubStr2)

			def FindSectionsBetweenTheseSubStringsQ(pcSubStr1, pcSubStr2)
				return This.FindSectionsBetweenTheseSubStringsQR(pcSubStr1, pcSubStr2, :stzList)

			def FindSectionsBetweenTheseSubStringsQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsBetweenTheseSubStrings(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsBetweenTheseSubStrings(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindSectionsBetweenTheseTwoSubStrings(pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringsBoundedBy(pcSubStr1, pcSubStr2)

			def FindSectionBetweenTheseTwoSubStringsQ(pcSubStr1, pcSubStr2)
				return This.FindSectionBetweenTheseTwoSubStringsQR(pcSubStr1, pcSubStr2, :stzList)

			def FindSectionsBetweenTheseTwoSubStringsQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsBetweenTheseTwoSubStrings(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsBetweenTheseTwoSubStrings(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		#--

		def FindSectionsOfAnySubstringBoundedWith(pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringsBoundedBy(pcSubStr1, pcSubStr2)

			def FindSectionsOfAnySubstringBoundedWithQ(pcSubStr1, pcSubStr2)
				return This.FindSectionsOfAnySubstringBoundedWithQR(pcSubStr1, pcSubStr2, :stzList)

			def FindSectionsOfAnySubstringBoundedWithQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfAnySubstringBoundedWith(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfAnySubstringBoundedWith(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindSectionsOfAnySubstringBoundedBy(pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringsBoundedBy(pcSubStr1, pcSubStr2)

			def FindSectionsOfAnySubstringBoundedByQ(pcSubStr1, pcSubStr2)
				return This.FindSectionsOfAnySubstringBoundedByQR(pcSubStr1, pcSubStr2, :stzList)

			def FindSectionsOfAnySubstringBoundedByQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfAnySubstringBoundedBy(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfanySubstringBoundedBy(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off			

		def FindSectionsOfAnySubstringBetween(pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringsBoundedBy(pcSubStr1, pcSubStr2)

			def FindSectionsOfAnySubstringBetweenQ(pcSubStr1, pcSubStr2)
				return This.FindSectionsOfAnySubstringBetweenQR(pcSubStr1, pcSubStr2, :stzList)

			def FindSectionsOfAnySubstringBetweenQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSectionsOfAnySubstringBetween(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindSectionsOfAnySubstringBetween(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def FindAnySectionsBetween(pcSubStr1, pcSubStr2)
			return This.FindSectionsOfSubstringsBoundedBy(pcSubStr1, pcSubStr2)

			def FindAnySectionsBetweenQ(pcSubStr1, pcSubStr2)
				return This.FindAnySectionsBetweenQR(pcSubStr1, pcSubStr2, :stzList)

			def FindAnySectionsBetweenQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.FindAnySectionsBetween(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.FindAnySectionsBetween(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		#>

	  #------------------------------------------------------------------#
	 #   EXTRACTING SUBSTRINGS ENCLOSED BETWEEN TWO OTHER SUBSTRINGS    # 
	#------------------------------------------------------------------#

	def SubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
		? o1.SubstringsBoundedBy("<<", ">>", :CS = FALSE)

		# --> [ "word1", "word2" ]
		*/
		aResult = []

		n1 = 1
		n2 = 1

		nLen1 = StzStringQ(pcSubStr1).NumberOfChars()
		nLen2 = StzStringQ(pcSubstr2).NumberOfChars()

		while TRUE

			n1 = This.FindNextCS(pcSubStr1, :StartingAt = n1, pCaseSensitive)

			if n1 = 0 or n1 > This.NumberOfChars()
				exit
			ok

			n2 = This.FindNextCS(pcSubStr2, :StartingAt = n1 + nLen1, pCaseSensitive)

			if n2 = 0 or n2 > This.NumberOfChars()
				exit
			ok

			aResult + This.Section(n1 + nLen1, n2 - 1)

			n1 = n2 + nLen2

		end

		return aResult

		#< @FunctionFluentForm

		def SubstringsBoundedWithCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBoundedWithCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

		def SubstringsBoundedWithCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.SubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off
			
		#>

		#< @FunctionAlternativeForms

		def AnySubstringBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubstringBoundedWithCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.AnySubstringBoundedWithCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def AnySubstringBoundedWithCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.AnySubstringBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.AnySubstringBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		#--

		def SubstringsBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def SubstringsBoundedByCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SubstringsBoundedByCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def SubstringsBoundedByCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.SubstringsBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SubstringsBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off				

		def AnySubstringBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubstringBoundedByCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.AnySubstringBoundedByCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def AnySubstringBoundedByCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.AnySubstringBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.AnySubstringBoundedByCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off				

		#--

		def SubstringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def SubstringsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SubstringsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def SubstringsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.SubstringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SubstringsBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def AnySubstringBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubstringBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.AnySubstringBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def AnySubstringBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.AnySubstringBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.AnySubstringBetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		#-- 

		def BetweenSubstringsCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def BetweenSubstringsCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.BetweenSubstringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def BetweenSubstringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.BetweenSubstringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.BetweenSubstringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def BetweenTheseSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def BetweenTheseSubStringsCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.BetweenTheseSubStringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def BetweenTheseSubStringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.BetweenTheseSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.BetweenTheseSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def BetweenTheseTwoSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBoundedWithCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def BetweenTheseTwoSubStringsCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.BetweenTheseTwoSubStringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

			def BetweenTheseTwoSubStringsCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.BetweenTheseTwoSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.BetweenTheseTwoSubStringsCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off

			def BetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.BetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.BetweenCS(pcSubStr1, pcSubStr2, pCaseSensitive) )
	
				other
					stzRaise("Unsupported return type!")
				off
		#>

	#-- CASE-INSENSITIVE

	def SubstringsBoundedWith(pcSubStr1, pcSubStr2)
		return This.SubstringsBoundedWithCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def SubstringsBoundedWithQ(pcSubStr1, pcSubStr2)
			return This.SubstringsBoundedWithQR(pcSubStr1, pcSubStr2, :stzList)

		def SubstringsBoundedWithQR(pcSubStr1, pcSubStr2, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.SubstringsBoundedWith(pcSubStr1, pcSubStr2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SubstringsBoundedWith(pcSubStr1, pcSubStr2) )

			other
				stzRaise("Unsupported return type!")
			off
			
		#>

		#< @FunctionAlternativeForms

		def AnySubstringBoundedWith(pcSubStr1, pcSubStr2)
			return This.SubstringsBoundedWith(pcSubStr1, pcSubStr2)

		#--

		def SubstringsBoundedBy(pcSubStr1, pcSubStr2)
			return This.SubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def SubstringsBoundedByQ(pcSubStr1, pcSubStr2)
				return This.SubstringsBoundedByQR(pcSubStr1, pcSubStr2, :stzList)

			def SubstringsBoundedByQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.SubstringsBoundedBy(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SubstringsBoundedBy(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off				

		def AnySubstringBoundedBy(pcSubStr1, pcSubStr2)
			return This.SubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def AnySubstringBoundedByQ(pcSubStr1, pcSubStr2)
				return This.AnySubstringBoundedByQR(pcSubStr1, pcSubStr2, :stzList)

			def AnySubstringBoundedByQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.AnySubstringBoundedBy(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.AnySubstringBoundedBy(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off				

		#--

		def SubstringsBetween(pcSubStr1, pcSubStr2)
			return This.SubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def SubstringsBetweenQ(pcSubStr1, pcSubStr2)
				return This.SubstringsBetweenQR(pcSubStr1, pcSubStr2, :stzList)

			def SubstringsBetweenQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.SubstringsBetween(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SubstringsBetween(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def AnySubstringBetween(pcSubStr1, pcSubStr2)
			return This.SubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def AnySubstringBetweenQ(pcSubStr1, pcSubStr2)
				return This.AnySubstringBetweenQR(pcSubStr1, pcSubStr2, :stzList)

			def AnySubstringBetweenQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.AnySubstringBetween(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.AnySubstringBetween(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		#--

		def BetweenSubstrings(pcSubStr1, pcSubStr2)
			return This.SubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def BetweenSubstringsQ(pcSubStr1, pcSubStr2)
				return This.BetweenSubstringsCQR(pcSubStr1, pcSubStr2, :stzList)

			def BetweenSubstringsQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.BetweenSubstrings(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.BetweenSubstrings(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def BetweenTheseSubStrings(pcSubStr1, pcSubStr)
			return This.SubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def BetweenTheseSubStringsQ(pcSubStr1, pcSubStr2)
				return This.BetweenTheseSubStringsQR(pcSubStr1, pcSubStr2, :stzList)

			def BetweenTheseSubStringsQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.BetweenTheseSubStrings(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.BetweenTheseSubStrings(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def BetweenTheseTwoSubStrings(pcSubStr1, pcSubStr2)
			return This.SubstringsBoundedWith(pcSubStr1, pcSubStr2)

			def BetweenTheseTwoSubStringsQ(pcSubStr1, pcSubStr2)
				return This.BetweenTheseTwoSubStringsQR(pcSubStr1, pcSubStr2, :stzList)

			def BetweenTheseTwoSubStringsQR(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.BetweenTheseTwoSubStrings(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.BetweenTheseTwoSubStrings(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off

		def Between(pcSubStr1, pcSubStr2, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.Between(pcSubStr1, pcSubStr2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.Between(pcSubStr1, pcSubStr2) )
	
				other
					stzRaise("Unsupported return type!")
				off
		#>

	  #------------------------------------------------#
	 #      VISUALLY FINDING CHARS IN THE STRING      #
	#------------------------------------------------#

	def VizFindChar(c)
		if IsStzChar(c)
			c = c.Content()
		ok

		if NOT ( isString(c) and StringIsChar(c) )
			return NULL
		ok

		cResult = @@( This.Content() )
		anPositions = This.FindAll( c )

		nLen = StzString(cRrsult).NumberOfChars()

		cViz = " "
		for i = 1 to nLen - 2
			
			if StzNumberQ(i).IsOneOfThese(anPositions)
				cViz += "^"
			else
				cViz += "-"
			ok

		next

		cResult += (NL + cViz)

		return cResult

		#< @FunctionFluentForm

		def VizFindCharQ(pItem)
			return new stzString( This.VizFindChar(pItem) )

		#>

	  #-----------------------------------------#
	 #      VISUALLY FINDING A SUBSTRING       #
	#-----------------------------------------#

	def VizFindXT(pcSubStr, paOptions)

		/* THE LOGIC ADOPTED IN CHECKING FUNCTION CORRECNESS
		   -------------------------------------------------

		   1. Checking the correctness of the TYPES of the params

		   2. Reading the VALUES of the params prvided and giving
		      default values to them if necessary

		   3. Checking the correctness of those values

		   4. Doing the required job

		TODO --> This logic should be generalized everywhere
		in the library to keep code consistand and knowledgable!

		FUTURE --> Replace all these checks with declarative Constraints.

		*/

		# STEP 1: Checking params TYPES
		
		if NOT isString(pcSubStr)
			stzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		if NOT ( isList(paOptions)
			 and Q(paOptions).IsHashList() and

			 StzHashListQ(paOptions).KeysQ().IsMadeOfSome([
				:CaseSensitive, :CS, :PositionSign,
				:BlankSign, :Numbered, :Spacified,
				:Boxed, :BoxOptions
			 ])

		       )

			stzRaise("Incorrect param type! paOptions must be a wellformed hashlist.")
		ok

		# At this level, we are sure pcSubStr is a string and
		# paOptions is a hashlist made of some of the allowed keys for boxing

		# Before going further, Delegate the work to VizFindBoxedXT()
		# when boxing is required

		if StzHashListQ(paOptions).ContainsKey(:Boxed) and
		   IsBoolean(paOptions[ :Boxed ]) and paOptions[ :Boxed ] = TRUE

			return This.VizFindBoxedXT(pcSubStr, paOptions)
		ok

		if StzHashListQ(paOptions).KeysQ().ContainsBoth(:CaseSensitive, :CS)
			stzRaise("Incorrect options! :CaseSensitive and its short form :CS must not be used both.")
		ok

		# Unfying the :CaseSensitive / :CS keyword

		n = StzHashListQ(paOptions).FindKey(:CS)
		if n > 0
			paOptions[n][1] = :CaseSensitive
		ok


		# # STEP 2: Reading params values

		bCaseSensitive = TRUE
		if ( isString(paOptions[:CaseSensitive]) and paOptions[:CaseSensitive] != NULL ) or
		   ( isNumber(paOptions[:CaseSensitive]) and IsBoolean(paOptions[:CaseSensitive])  )

			bCaseSensitive = paOptions[:CaseSensitive]
		ok

		cPositionSign = "^"
		if isString(paOptions[:PositionSign]) and paOptions[:PositionSign] != NULL
			cPositionSign = paOptions[:PositionSign]
		ok

		cBlankSign = "-"
		if isString(paOptions[:BlankSign]) and paOptions[:BlankSign] != NULL
			cBlankSign = paOptions[:BlankSign]
		ok

		bNumbered = FALSE
		if ( isString(paOptions[:Numbered]) and paOptions[:Numbered] != NULL ) or
		   ( isNumber(paOptions[:Numbered]) and IsBoolean(paOptions[:Numbered])  )

			bNumbered = paOptions[:Numbered]
		ok

		bSpacified = FALSE
		if ( isString(paOptions[:Spacified]) and paOptions[:Spacified] != NULL ) or
		   ( isNumber(paOptions[:Spacified]) and IsBoolean(paOptions[:Spacified])  )

			bSpacified = paOptions[:Spacified]
		ok

		# STEP 3: Checking the correctness of the provided values

		bCorrect = TRUE
		acWhy = [] # Will host the reasons of the errors

		If NOT IsBoolean(bCaseSensitive)

			bCorrect = FALSE
			acWhy + ":CaseSensitive option must be a boalean"
		ok

		if NOT ( isString(cPositionSign) and StringIsChar(cPositionSign) )

			bCorrect = FALSE
			acWhy + ":PositionSign option must be a char"
		ok

		if NOT ( isString(cBlankSign) and StringIsChar(cBlankSign) )

			bCorrect = FALSE
			acWhy + ":BlankSign option must be char"
		ok

		if NOT cPositionSign != cBlankSign

			bCorrect = FALSE
			acWhy + ":PositionSign and :BlankSign options must be different"
		ok

		If NOT IsBoolean(bNumbered)

			bCorrect = FALSE
			acWhy + ":Numbered option must be a boalean"
		ok

		If NOT IsBoolean(bSpacified)

			bCorrect = FALSE
			acWhy + ":Spacified option must be a boalean"
		ok

		if NOT bCorrect
			stzRaise([
				:Where	= "stzString (9676) > vizFindXT()",
				:What	= StzListOfStringsQ(acWhy).ConcatenatedUsing(", ") + "."
			])
		ok

		# At this level, we are sur the params are well formed
		# --> Let's do our job of boxing the string!

		if bSpacified
			cString= @@( This.Spacified() )
		else
			cString = @@( This.Content() )
		ok

		oString = new stzString(cString)

		anPositions = oString.FindAllCS( pcSubStr, :CS = bCaseSensitive )

		anVizPositions = StzListOfNumbersQ(anPositions).
				SubstractFromEachQ(1).Content()

		nLen = oString.NumberOfChars()

		cVizLine = " "
		for i = 1 to nLen - 2
			
			if StzNumberQ(i).IsOneOfThese(anVizPositions)
				cVizLine += cPositionSign
			else
				cVizLine += cBlankSign
			ok

		next

		cResult = oString.Content() + NL + cVizLine

		if bNumbered

			oVizLine = new stzString(cVizLine)

			oVizLine {
	
				Replace(cBlankSign, " ")

				cCondition = '@char = ' + @@(cPositionSign)

				if NOT bSpacified

					cReplacement@ = '{ Q( ""+ ( This.FindAll(' +
						 @@(cPositionSign) +
						 ')[@i] - 1 ) ).LastChar() }'

				else

					cReplacement@ = '{ Q( ""+ ( This.FindAll(' +
						 @@(cPositionSign) +
						 ')[@i] / 2 ) ).LastChar() }'
					
				ok

				ReplaceW( :Where = cCondition, :With@ = cReplacement@ )

			}

			cResult += NL + oVizLine.TrailingSpacesRemoved()

		ok

		return cResult

		#< @FunctionFluentForm

		def VizFindXTQ(pcSubStr, paOptions)
			return new stzString( This.VizFindXT(pcSubStr, paOptions) )

		#>

	def VizFind(pcSubStr)
		return This.VizFindXT(pcSubStr, [] )

	def VizFindCS(pcSubStr, pCaseSensitive)
		return This.VizFindXT(pcSubStr, [ pCaseSensitive ])
		
	  #----------------------------------------------------#
	 #      VISUALLY FINDING AND BOXING A SUBSTRING       # TODO: Review this
	#----------------------------------------------------#

	def VizFindBoxedXT(pcSubstr, paOptions) # TODO
		/* EXAMLPE

		*/

		if NOT ( isString(pcSubStr) or
		  	sList(paOptions) and StzListQ(paOptions).IsBoxParamList() )

			stzRaise("Incorrect params!")
		ok

		


/*
	
			if paOptions[ :Casesensitive ] = TRUE or
			   paOptions[ :CS ] = TRUE
	
				paOptions + [ :Hilighted, 
					      This.FindAllCS(pcSubStr, :CS = TRUE)
					    ]
			else
				paOptions + [ :Hilighted, 
					      This.FindAllCS(pcSubStr, :CS = FALSE)
					    ]
			ok
	
			StzHashListQ(paOptions) {
				RemovePairByKeyQ(:Casesensitive)
				RemovePairByKeyQ(:CS)
				paOptions = Content()
			}
	
			oStzListOfChars = new stzListOfChars(This.String())
			return oStzListOfChars.BoxedXT(paOptions)
	*/


	
	  #--------------------------------#
	 #      CONTAINING SUBSTRINGS     #
	#--------------------------------#

	// Verifies the existence of a substring in a string
	def Contains(cSubStr)
		return This.ContainsCS(cSubstr, :CaseSensitive = TRUE)

		#< @FunctionNegationForm

		def ContainsNo(cSubStr)
			return NOT This.Contains(cSubStr)

			def IncludesNo(cSubStr)
				return This.ContainsNo(cSubStr)

		#>

		def Includes(cSubStr)
			return This.Contains(cSubStr)

		#< @FunctionCaseSensitiveForm

		def ContainsCS(cSubStr, pCaseSensitive) # :CaseSensitive = TRUE or :CaseSensitive = FALSE
	
			if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
				pCaseSensitive = pCaseSensitive[2]
			ok

			if isNumber(pCaseSensitive) and
			   (pCaseSensitive = 0 or pCaseSensitive = 1)

				return QStringObject().contains(cSubStr, pCaseSensitive)

			else
				stzRaise("Error in param value! pCaseSensitive must be 0 or 1 (TRUE or FALSE).")
	
			ok

			#< @FunctionNegationForm
	
			def ContainsNoCS(cSubStr, pCaseSensitive)
				return NOT This.ContainsCS(cSubStr, pCaseSensitive)
	
				def IncludesNoCS(cSubStr, pCaseSensitive)
					return This.ContainsNoCS(cSubStr, pCaseSensitive)
			#>

			def IncludesCS(cSubStr, pCaseSensitive)
				return This.ContainsCS(cSubStr, pCaseSensitive)
		#>

	def ContainsNoOneOfTheseCS(paSubStr, pCaseSensitive)
		bResult = NOT This.ContainsOneOfTheseCS(paSubStr, pCaseSensitive)

	def ContainsNoOneOfThese(paSubStr)
		return This.ContainsNoOneOfTheseCS(paSubStr, :Casesensitive = TRUE)

	def ContainsOneOfTheseCS(paSubStr, pCaseSensitive)
		bResult = FALSE

		for str in paSubStr
			if This.ContainsCS( str,  pCaseSensitive)
				bResult = TRUE
				exit
			ok
		next

		return bResult

	def ContainsOneOfThese(paSubStr)
		return This.ContainsOneOfTheseCS(paSubStr, :Casesensitive = TRUE)

	// Verifies if the string contains each one of the substrings provided
	def ContainsEachCS(paSubStr, pCaseSensitive)
		bContainsThemAll = TRUE
		for str in paSubStr
			bContainsThemAll = This.ContainsCS(str, pCaseSensitive)
			if bContainsThemAll = FALSE
				exit
			ok
		next
		return bContainsThemAll

	def ContainsEach(paSubStr)
		return This.ContainsEachCS(paSubStr, :CaseSensitive = TRUE)

	def ContainsBothCS(pcStr1, pcStr2, pCaseSensitive)
		return This.ContainsEachCS( [pcStr1, pcStr2], pCaseSensitive)

	def ContainsBoth(pcStr1, pcStr2)
		return This.ContainsBothCS(pcStr1, pcStr2, :CaseSensitive = TRUE)
	
	  #------------------------------------------------#
	 #    CONTAINING N OCCURRENCES OF A SUBSTRING     #
	#------------------------------------------------#

	def ContainsNTimesCS(n, pcSubstr, pCaseSensitive)
		return This.NumberOfOccurrencesCS(pcSubStr, pCaseSensitive) = n

		def ContainsNTimes(n, pcSubStr)
			return This.ContainsNTimesCS(n, pcSubstr, :CaseSensitive = TRUE)
	
		def ContainsNTimesTheSubstringCS(n, pcSubstr, pCaseSensitive)
			return ContainsNTimesCS(n, pcSubstr, pCaseSensitive)

		def ContainsNTimeTheSubstring(n, pcSubStr)
			return ContainsNTimes(n, pcSubStr)

	def ContainsNTimesTheChar(n, pcChar)
		if NOT IsChar(pcChar)
			return FALSE
		ok
		
		return This.ContainsNTimesCS(n, pcChar, :CaseSensitive = FALSE)

	def ContainsOneOccurrenceCS(pcSubStr, pCaseSensitive)
		return This.ContainsNTimesCS(1, pcSubStr, pCaseSensitive)

		def ContainsOneOccurrence(pcSubStr)
			return This.ContainsOneOccurrenceCS(pcSubstr, :CaseSensitive = TRUE)
	
		def ContainsOnlyOneCS(pcSubStr, pCaseSensitive)
			return This.ContainsOneOccurrenceCS(pcSubStr, :CaseSensitive = TRUE)

			def ContainsOnlyOne(pcSubStr)
				return This.ContainsOnlyOneCS(pcSubStr, :CaseSensitive = TRUE)

	def ContainsMoreThanOneOccurrenceCS(pcSubstr, pCaseSensitive)
		return This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive) > 1

		def ContainsMoreThanOneOccurrence(pcSubStr)
			return This.NumberOfOccurrence(pcSubStr) > 1

	  #------------------------#
	 #    CONTAINING SPACES   #
	#------------------------#

	def ContainsSpaces()
		return This.Contains(" ")
			
	  #-----------------------------------------#
	 #    CONTAINING CHARS IN A GIVEN SCRIPT   #
	#-----------------------------------------#

	def ContainsCharsInScript(pcScript)
		return This.ContainsScript(pcScript)

		#< @FunctionNegationForm

		def ContainsNocharsInScript(pcScript)
			return NOT This.ContainsCharsInScript(pcScript)

		#>

	  #---------------------------#
	 #    CONTAINING LETTERS     #
	#---------------------------#

	def ContainsLetters()
		bResult = FALSE
		for i = 1 to This.NumberOfChars()
			if StzCharQ( This[i] ).IsLetter()
				bResult = TRUE
				exit
			ok
		next
		return bResult

		#< @FunctionNegationForm

		def ContainsNoLetters()
			return NOT This.ContainsNumbers()

		#>

	def ContainsTheLetters(pacLetters)
		if ListIsListOfLetters(pacLetters)
			bResult = TRUE
			oStr = This.UppercaseQ()

			pacLetters = StzListOfCharsQ(pacLetters).Uppercased()
			for cLetter in pacLetters
				if oStr.ContainsNo(cLetter)
					bResult = FALSE
					exit
				ok
			next

			return bResult
		ok

	def ContainsArabicLetters()
		bResult = FALSE
		for i = 1 to This.NumberOfChars()
			if StzCharQ( This[i] ).IsArabicLetter()
				bResult = TRUE
				exit
			ok
		next
		return bResult

		#< @FunctionNegationForm

		def ContainsNoArabicLetters()
			return NOT This.ContainsArabicNumbers()

		#>

	def ContainsLatinLetters()
		bResult = FALSE
		for i = 1 to This.NumberOfChars()
			if StzCharQ( This[i] ).IsLatinLetter()
				bResult = TRUE
				exit
			ok
		next
		return bResult

		#< @FunctionNegationForm

		def ContainsNoLatinLetters()
			return NOT This.ContainsLatinNumbers()

		#>

	def ContainsLettersInScript(pcScript)
		bResult = FALSE
		for i = 1 to This.NumberOfChars()
			if StzCharQ( This[i] ).IsLetterInScript(pcScript)
				bResult = TRUE
				exit
			ok
		next
		return bResult

		#< @FunctionNegationForm

		def ContainsNoLettersInScript(pcScript)
			return NOT This.ContainsNumbers(pcScript)

		#>

	  #-------------------#
	 #     SPLITTING     #
	#-------------------#

	def SplitXT(cSep, paOptions)
		if This.IsEmpty()
			return NULL
		ok

		# Checking types pf the params

		if NOT ( isString(cSep) or
		
			isList(cSep) and StzListQ(cSep).IsUsingParamList() )

			stzRaise("Incorrect param type! cSep must be a string.")
		ok

		if NOT ( isList(paOptions) and StzListQ(paOptions).IsHashList() )
			stzRaise("Incorrect param type! paOptions must be a hashlist.")
		ok

		if isList(cSep) and StzListQ(cSep).IsUsingParamList()
			cSep = cSep[2]
		ok

		if NOT This.Contains(cSep)
			return []
		ok

		if NOT StzHashListQ(paOptions).KeysQ().IsMadeOfSome([
				:CaseSensitive,
				:CS,
				:SkipEmptyParts,

				:IncludeLeadingSep,
				:IncludeTrailingSep,

				:ExcludeLeadingSubstrings_FromSplittedParts,
				:ExcludeTrailingSubstrings_FromSplittedParts,

				:ExcludeLeadingSequenceOfNChars_FromSplittedParts,
				:ExcludeTrailingSequenceOfNChars_FromSplittedParts
			      ])

			stzRaise("Incorrect param! paOptions must be a wellformed hashlist.")
		ok

		if StzHashListQ(paOptions).KeysQ().ContainsBoth(:CaseSensitive, :CS)
			stzRaise("Incorrect options! :CaseSensitive and its short form :CS must not be used both.")
		ok

		# Unfying the :CaseSensitive / :CS keyword

		n = StzHashListQ(paOptions).FindKey(:CS)
		if n > 0
			paOptions[n][1] = :CaseSensitive
		ok

		# Reading options

		if StzHashListQ(paOptions).ContainsKey(:CaseSensitive)
			bCaseSensitive = paOptions[ :CaseSensitive ]
		else
			bCaseSensitive = TRUE
		ok

		if NOT isBoolean(bCaseSensitive)
			stzRaise("Incorrect value! bCaseSensitive must be a boolean.")
		ok

		#--

		if StzHashListQ(paOptions).ContainsKey(:SkipEmptyParts)
			bSkipEmptyParts = paOptions[ :SkipEmptyParts ]
		else
			bSkipEmptyParts = FALSE
		ok

		if NOT isBoolean(bSkipEmptyParts)
			stzRaise("Incorrect value! bSkipEmptyParts must be a boolean.")
		ok

		#--

		if StzHashListQ(paOptions).ContainsKey(:IncludeLeadingSep)
			bIncludeLeadingSep = paOptions[ :IncludeLEadingSep ]
		else
			bIncludeLeadingSep = FALSE
		ok

		if NOT isBoolean(bIncludeLeadingSep)
			stzRaise("Incorrect value! bIncludeLeadingSep must be a boolean.")
		ok

		#--

		if StzHashListQ(paOptions).ContainsKey(:IncludeTrailingSep)
			bIncludeTrailingSep = paOptions[ :IncludeTrailingSep ]
		else
			bIncludeTrailingSep = FALSE
		ok

		if NOT isBoolean(bIncludeTrailingSep)
			stzRaise("Incorrect value! bIncludeTrailingSep must be a boolean.")
		ok

		#--

		if StzHashListQ(paOptions).ContainsKey(:ExcludeLeadingSubstrings_FromSplittedParts)
			acExcludeLeadingSubstrings_FromSplittedParts =
			paOptions[ :ExcludeLeadingSubstrings_FromSplittedParts ]
		else
			acExcludeLeadingSubstrings_FromSplittedParts = []
		
		ok

		if NOT isList(acExcludeLeadingSubstrings_FromSplittedParts)
			stzRaise("Incorrect value! :ExcludeLeadingSubstrings_FromSplittedParts must be a list")
		ok

		if NOT ( ( len(acExcludeLeadingSubstrings_FromSplittedParts) = 0 ) or

			 ( StzListQ(acExcludeLeadingSubstrings_FromSplittedParts).IsListOfStrings() )
		       )

			stzRaise("Inccorect value! :ExcludeLeadingSubstrings_FromSplittedParts must be an empty list or a list of strings")
		ok

		#--

		if StzHashListQ(paOptions).ContainsKey(:ExcludeTrailingSubstrings_FromSplittedParts)
			acExcludeTrailingSubstrings_FromSplittedParts =
			paOptions[ :ExcludeTrailingSubstrings_FromSplittedParts ]
		else
			acExcludeTrailingSubstrings_FromSplittedParts = []
		
		ok

		if NOT isList(acExcludeTrailingSubstrings_FromSplittedParts)
			stzRaise("Incorrect value! :ExcludeTrailingSubstrings_FromSplittedParts must be a list")
		ok

		if NOT ( ( len(acExcludeTrailingSubstrings_FromSplittedParts) = 0 ) or

			 ( StzListQ(acExcludeTrailingSubstrings_FromSplittedParts).IsListOfStrings() )
		       )

			stzRaise("Inccorect value! :ExcludeTrailingSubstrings_FromSplittedParts must be an empty list or a list of strings")
		ok

		#--

		// Example: [ 3, "#" ] or [ :AnyNumberOf, "#" ]
		if StzHashListQ(paOptions).ContainsKey(:ExcludeLeadingSequenceOfNChars_FromSplittedParts)
			acExcludeLeadingSequenceOfNChars_FromSplittedParts =
			paOptions[ :ExcludeLeadingSequenceOfNChars_FromSplittedParts ]

		else
			acExcludeLeadingSequenceOfNChars_FromSplittedParts = []
		ok

		if NOT isList(acExcludeLeadingSequenceOfNChars_FromSplittedParts)
			stzRaise("Incorrect value! :acExcludeLeadingSequenceOfNChars_FromSplittedParts must be a list")
		ok

		if NOT ( len(acExcludeLeadingSequenceOfNChars_FromSplittedParts) = 0 or
	  		 len(acExcludeLeadingSequenceOfNChars_FromSplittedParts) = 2 )

			stzRaise("Inccorect value! :acExcludeLeadingSequenceOfNChars_FromSplittedParts must be an empty list or a list of 2 items")
		ok

		if len(acExcludeLeadingSequenceOfNChars_FromSplittedParts) = 2
			if NOT ( isString(acExcludeLeadingSequenceOfNChars_FromSplittedParts[2]) and
				 StringIsChar(acExcludeLeadingSequenceOfNChars_FromSplittedParts[2]) )

				stzRaise("Incorrect value! the second item of :acExcludeLeadingSequenceOfNChars_FromSplittedParts must be a char")
			ok
		ok

		if len(acExcludeLeadingSequenceOfNChars_FromSplittedParts) = 2
			if NOT ( ( isString(acExcludeLeadingSequenceOfNChars_FromSplittedParts[1]) and
				acExcludeLeadingSequenceOfNChars_FromSplittedParts[1] = :AnyNumberOf ) or

				isNumber(acExcludeLeadingSequenceOfNChars_FromSplittedParts[1])
			       )

				stzRaise("Incorrect value! the second item of :acExcludeLeadingSequenceOfNChars_FromSplittedParts must be a char")
			ok
		ok

		#--

		if StzHashListQ(paOptions).ContainsKey(:ExcludeTrailingSequenceOfNChars_FromSplittedParts)
			acExcludeTrailingSequenceOfNChars_FromSplittedParts =
			paOptions[ :ExcludeTrailingSequenceOfNChars_FromSplittedParts ]

		else
			acExcludeTrailingSequenceOfNChars_FromSplittedParts = []
		ok

		if NOT isList(acExcludeTrailingSequenceOfNChars_FromSplittedParts)
			stzRaise("Incorrect value! :acExcludeTrailingSequenceOfNChars_FromSplittedParts must be a list")
		ok

		if NOT ( len(acExcludeTrailingSequenceOfNChars_FromSplittedParts) = 0 or
	  		 len(acExcludeTrailingSequenceOfNChars_FromSplittedParts) = 2 )

			stzRaise("Inccorect value! :acExcludeTrailingSequenceOfNChars_FromSplittedParts must be an empty list or a list of 2 items")
		ok

		if len(acExcludeTrailingSequenceOfNChars_FromSplittedParts) = 2
			if NOT ( isString(acExcludeTrailingSequenceOfNChars_FromSplittedParts[2]) and
				 StringIsChar(acExcludeTrailingSequenceOfNChars_FromSplittedParts[2]) )

				stzRaise("Incorrect value! the second item of :acExcludeTrailingSequenceOfNChars_FromSplittedParts must be a char")
			ok
		ok

		if len(acExcludeTrailingSequenceOfNChars_FromSplittedParts) = 2
			if NOT ( ( isString(acExcludeTrailingSequenceOfNChars_FromSplittedParts[1]) and
				acExcludeTrailingSequenceOfNChars_FromSplittedParts[1] = :AnyNumberOf ) or

				isNumber(acExcludeTrailingSequenceOfNChars_FromSplittedParts[1])
			       )

				stzRaise("Incorrect value! the second item of :acExcludeTrailingSequenceOfNChars_FromSplittedParts must be a char")
			ok
		ok	

		#--

		# Performing the splitting

		# --> bCaseSensitive and bSkipEmptyParts options are done by Qt for free
	
		oQStringList = @oQString.split(cSep, bSkipEmptyParts, bCaseSensitive)
		oStzListOfStr = new stzListOfStrings( QStringListToRingList(oQStringList) )

		# Managinng :IncludeLeadingSep option

		if bIncludeLeadingSep = FALSE
			if oStzListOfStr.FirstStringQ().IsEqualToCS(cSep, bCaseSensitive)
				oStzListOfStr.RemoveFirstString()
			ok
		ok

		# Managing :IncludeTrailingSep

		if bIncludeTrailingSep = FALSE
			if oStzListOfStr.LastStringQ().IsEqualToCS(cSep, bCaseSensitive)
				oStzListOfStr.RemoveLastString()
			ok
		ok

		# Managing :ExcludeLeadingSubstrings_FromSplittedParts option

		if len(acExcludeLeadingSubstrings_FromSplittedParts) > 1
			for str in oStzListOfStr.Content()
				for cSubStr in acExcludeLeadingSubstrings_FromSplittedParts
	
					str = StzStringQ(str).
						RemoveFromStartCSQ(cSubStr, bCaseSensitive).
						Content()
				next
			next
		ok

		# Managing :ExcludeTrailingSubstrings_FromSplittedParts option

		if len(acExcludeTrailingSubstrings_FromSplittedParts) > 1
			for str in oStzListOfStr.Content()
				for cSubStr in acExcludeTrailingSubstrings_FromSplittedParts
	
					str = StzStringQ(str).
						RemoveFromEndCSQ(cSubStr, bCaseSensitive).
						Content()
				next
			next
		ok

		# Managing ExcludeLeadingSequenceOfNChars_FromSplittedParts option
		
		if len(acExcludeLeadingSequenceOfNChars_FromSplittedParts) = 2
			n = acExcludeLeadingSequenceOfNChars_FromSplittedParts[1]
			c = acExcludeLeadingSequenceOfNChars_FromSplittedParts[2]
	
			for str in oStzListOfStr.Content()
	
				if n = :AnyNumberOf
	
					str = StzStringQ(str).
					      RemoveLeadingCharCSQ(c, bCaseSensitive).
					      Content()
	
				else
	
					if ( Q(c) * n ).IsEqualCS( This.FirstNChars(n), bCaseSensitive )
	
						str = StzStringQ(str).
						      RemoveFirstNCharsQ(n).
						      Content()
					ok
	
				ok
			next

		ok

		# Managing :ExcludeTrailingSequenceOfNChars_FromSplittedParts
	
		if len(acExcludeTrailingSequenceOfNChars_FromSplittedParts) = 2
			n = acExcludeTrailingSequenceOfNChars_FromSplittedParts[1]
			c = acExcludeTrailingSequenceOfNChars_FromSplittedParts[2]
	
			for str in oStzListOfStr.Content()
	
				if n = :AnyNumberOf
	
					str = StzStringQ(str).
					      RemoveTrailingCharCSQ(c, bCaseSensitive).
					      Content()
	
				else
	
					if ( Q(c) * n ).IsEqualCS( This.LastNChars(n), bCaseSensitive )
	
						str = StzStringQ(str).
						      RemoveLastNCharsQ(n).
						      Content()
					ok
	
				ok
			next

		ok


		# Returning the result of splitting
		aResult = oStzListOfStr.Content()
		return aResult

		#< @FunctionFluentForm

		def SplitXTQ(cSep, paOptions)
			return This.SplitXTQR(cSep, paOptions, :stzList)

		def SplitXTQR(cSep, paOptions, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitXT(cSep, paOptions) )
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitXT(cSep, paOptions) )
			other
				stzRaise("Unsupported return type!")
			off

		#>

		def SplittedXT(cSep, paOptions)
			return This.SplitXT(cSep, paOptions)

	def SplitAndSkipEmptyParts(cSep)

		aSplitOptions = [
 			:CaseSensitive = TRUE,
			:SkipEmptyParts = TRUE,
			:IncludeLeadingSep = FALSE,
			:IncludeTrailingSep = FALSE
		 ]

		return 	This.SplitXT(cSep, aSplitOptions)

		def SplitAndSkipEmptyPartsQ(cSep)
			return This.SplitAndSkipEmptyPartsQR(cSep, :stzList)

		def SplitAndSkipEmptyPartsQR(cSep, pcReturnType)
			switch pcReturnType

			on :stzList
				return new stzList( This.SplitAndSkipEmptyParts(cSep) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAndSkipEmptyParts(cSep) )
			other
				stzRaise("Unsupported return type!")
			off

		def SplittedAndEmptyPartsSkipped(cSep)
			return This.SplitAndSkipEmptyParts(cSep)

	def SplitAndSkipEmptyPartsCS(cSep, pCaseSensitive)

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		aSplitOptions = [
 			:CaseSensitive = pCaseSensitive,
			:SkipEmptyParts = TRUE,
			:IncludeLeadingSep = FALSE,
			:IncludeTrailingSep = FALSE
		 ]

		return 	This.SplitXT(cSep, aSplitOptions)

		def SplitAndSkipEmptyPartsCSQ(cSep, pCaseSensitive)
			return This.SplitAndSkipEmptyPartsCSQR(cSep, pCaseSensitive, :stzList)

		def SplitAndSkipEmptyPartsCSQR(cSep, pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAndSkipEmptyPartsCS(cSep, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAndSkipEmptyPartsCS(cSep, pCaseSensitive) )
			other
				stzRaise("Unsupported return type!")
			off

		def SplittedAndEmptyPartsSkippedCS(cSep, pCaseSensitive)
			return This.SplitAndSkipEmptyPartsCS(cSep, pCaseSensitive)

	def SplitAndExcludeLeadingAndTrailingSep(cSep)

		aSplitOptions = [
 			:CaseSensitive = TRUE,
			:SkipEmptyParts = FALSE,
			:IncludeLeadingSep = TRUE,
			:IncludeTrailingSep = TRUE
		 ]

		return This.SplitXT(cSep, aSplitOptions)

		def SplitAndExcludeLeadingAndTrailingSepQ(cSep)
			return This.SplitAndExcludeLeadingAndTrailingSepQR(cSep, :stzList)

		def SplitAndExcludeLeadingAndTrailingSepQR(cSep, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAndExcludeLeadingAndTrailingSep(cSep) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAndExcludeLeadingAndTrailingSep(cSep) )
			other
				stzRaise("Unsupported return type!")
			off

		def SplittedAndLeadingAndTrailingSepExcluded(cSep)
			return This.SplitAndExcludeLeadingAndTrailingSep(cSep)

	def SplitAndExcludeLeadingAndTrailingSepCS(cSep, pCaseSensitive)

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		aSplitOptions = [
 			:CaseSensitive = pCaseSensitive,
			:SkipEmptyParts = FALSE,
			:IncludeLeadingSep = TRUE,
			:IncludeTrailingSep = TRUE
		 ]

		return This.SplitXT(cSep, aSplitOptions)
	
		def SplitAndExcludeLeadingAndTrailingSepCSQ(cSep, pCaseSensitive)
			return This.SplitAndExcludeLeadingAndTrailingSepCSQR(cSep, pCaseSensitive, :stzList)

		def SplitAndExcludeLeadingAndTrailingSepCSQR(cSep, pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAndExcludeLeadingAndTrailingSepCS(cSep, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAndExcludeLeadingAndTrailingSepCS(cSep, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off

		def SplittedAndLeadingAndTrailingSepExcludedCS(cSep, pCaseSensitive)
			return This.SplitAndExcludeLeadingAndTrailingSepCS(cSep, pCaseSensitive)

	def SplitForward(pcSep)

		aSplitOptions = [
 			:CaseSensitive = FALSE,
			:SkipEmptyParts = FALSE,
			:IncludeLeadingSep = FALSE,
			:IncludeTrailingSep = FALSE
		 ]

		aResult = This.SplitXT(pcSep, aSplitOptions)

		return aResult

		def SplitForwardQ(cSep)
			return This.SplitForwardQR(cSep, :stzList)

		def SplitForwardQR(cSep, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitForward(cSep) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitForwardQ(cSep) )

			other
				stzRaise("Unsupported return type!")
			off

		def SplittedForward(pcSep)
			return This.SplitForward(pcSep)

	def SplitForwardCS(cSep, pCaseSensitive)
		aSplitOptions = [
 			:CaseSensitive = TRUE,
			:SkipEmptyParts = FALSE,
			:IncludeLeadingSep = FALSE,
			:IncludeTrailingSep = FALSE
		 ]

		return This.SplitXT(cSep, aSplitOptions)

		def SplitForwardCSQ(cSep, pCaseSensitive)
			return This.SplitForwardCSQR(cSep, pCaseSensitive, :stzList)

		def SplitForwardCSQR(cSep, pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitForwardCS(cSep, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitForwardCS(cSep, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off

		def SplittedForwardCS(cSep, pCaseSensitive)
			return This.SplitForwardCS(cSep, pCaseSensitive)

	def SplitBackward(cSep)
		oList = new stzList( This.SplitForward(cSep) )
		return oList.Reversed()

		def SplitBackwardQ(cSep)
			return This.SplitBackwardQR(cSep, :stzList)

		def SplitBackwardQR(cSep, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBackward(cSep) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBackward(cSep) )

			other
				stzRaise("Unsupported return type!")
			off

		def SplittedBackward(pcSep)
			return This.SplitBackward(pcSep)

	def SplitBackwardCS(cSep, pCaseSensitive)
		oList = new stzList( This.SplitForwardCS(cSep, pCaseSensitive) )
		return oList.Reversed()

		def SplitBackwardCSQ(cSep, pCaseSensitive)
			return This.SplitBackwardCSQR(cSep, pCaseSensitive, :stzList)

		def SplitBackwardCSQR(cSep, pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBackwardCS(cSep, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBackwardCS(cSep, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off

		def SplittedBackwardCS(pcSep, pCaseSensitive)
			return This.SplitBakwardCS(pcSep, pCaseSensitive)

	// Splits the string using the given separator
	def Split(cSep)

		aResult = This.SplitForward(cSep)
		return aResult

		def SplitQ(cSep)
			return This.SplitQR(cSep, :stzList)

		def SplitQR(cSep, pcReturnType )
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Split(cSep) )
	
			on :stzListOfStrings
				return new stzListOfStrings( This.Split(cSep) )
	
			other
				stzRaise("Unsupported return type!")
	
			off

		def Splitted(pcSep)
			return This.Split(pcSep)

	def SplitCS(cSep, pCaseSensitive)
		return This.SplitForwardCS(cSep, pCaseSensitive)

		def SplitCSQ(cSep, pCaseSensitive)
			return This.SplitCSQR(cSep, pCaseSensitive, :stzList)

		def SplitCSQR(cSep, pCaseSensitive, pcReturnType )
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.SplitCS(cSep, pCaseSensitive) )
	
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitCS(cSep, pCaseSensitive) )
	
			other
				stzRaise("Unsupported return type!")
	
			off

		def SplittedCS(pcSep, pCaseSensitive)
			return This.SplitCS(pcSep, pCaseSensitive)

	  #---------------------------------------#
	 #     SPLITTING TO PARTS OF N CHARS    #
	#---------------------------------------#

	// Splits the string to parts of n Chars


	def SplitToPartsOfNCharsXT(n, pcDirection)
		#< @MotherFunction = YES | @RingBased #>
		
		# Checking the correctness of n param
		
		if NOT isNumber(n) and  n <= this.NumberOfChars()
			stzRaise("Invalid param! n must be a number <= number of chars of the string.")
		ok

		# Checking the correctness of pcDirection param

		bCorrect = FALSE

		if isString(pcDirection) and Q(pcDirection).IsOneOfThese([ :Forward, :Backward ])
			bCorrect = TRUE

		but isList(pcDirection) and Q(pcDirection).IsDirectionParamList()
			bCorrect = TRUE
			pcDirection = pcDirection[2]
		ok

		if NOT bCorrect
			stzRaise("Incorrect param! pcDirection must be a string equal to :Forward or :Backward.")
		ok

		# Doing the job

		aResult = []
		nWhatRemains = 0
	
		if pcDirection = :Backward

			# Adding the parts

			for i = this.NumberOfChars() to 0 step -n
				if this.Range(i+1,n) != ""
					aResult + this.Range(i+1,n)
				ok
			next
	
			# Adding the remaing part of the string

			nWhatRemains = NumberOfChars() - len(aResult) * n
			aResult + This.LeftNChars(nWhatRemains)	
		
		else #--> Direction = :Forward

			# Adding the parts

			for i = 1 to this.NumberOfChars() step n
				aResult + this.Range(i,n)
			next

		ok
	
		return aResult

		

		def SplitToPartsOfNCharsXTQ(n, pDirection)
			return This.SplitToPartsOfNCharsXTQR(n, pDirection, :stzList)

		def SplitToPartsOfNCharsXTQR(n, pDirection, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.SplitToPartsOfNCharsXT(n, pDirection) )
	
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitToPartsOfNCharsXT(n, pDirection) )
	
			other
				stzRaise("Unsupported return type!")
	
			off

		def SplittedToPartsOfNCharsXT(n, pDirection)
			return This.SplitToPartsOfNCharsXT(n, pDirection)


	def SplitForwardToPartsOfNChars(n)
		#< @MotherFunction = SplitToPartsOfNCharsXT() > @RingBased #>

		return This.SplitToPartsOfNCharsXT(n, :Forward)
	
		#< @FunctionFluentForm

		def SplitForwardToPartsOfNCharsQ(n)
			return This.SplitForwardToPartsOfNCharsQR(n, :stzList)

		def SplitForwardToPartsOfNCharsQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.SplitForwardToPartsOfNChars(n) )
	
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitForwardToPartsOfNChars(n) )
	
			other
				stzRaise("Unsupported return type!")
	
			off
			
		#>

		#< @FunctionAlternativeForms

		def SplitToPartsOfNChars(n)
			return This.SplitForwardToPartsOfNChars(n)

			def SplitToPartsOfNCharsQ(n)
				return This.SplitToPartsOfNCharsQR(n, :stzList)
	
			def SplitToPartsOfNCharsQR(n, pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
	
				switch pcReturnType
				on :stzList
					return new stzList( This.SplitToPartsOfNChars(n) )
		
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitToPartsOfNChars(n) )
		
				other
					stzRaise("Unsupported return type!")
		
				off	

		def SplittedToPartsOfNChars()
			return This.SplitForwardToPartsOfNChars(n)

		def SplittedForwardToPartsOfNChars(n)
			return This.SplitForwardToPartsOfNChars(n)

		#>

	def SplitBackwardToPartsOfNChars(n)
		#< @MotherFunction = SplitToPartsOfNCharsXT() > @RingBased #>

		return This.SplitToPartsOfNCharsXT(n, :Backward)

		def SplitBackwardToPartsOfNCharsQ(n)
			return This.SplitBackwardToPartsOfNCharsQR(n, :stzList)
	
		def SplitBackwardToPartsOfNCharsQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBackwardToPartsOfNChars(n) )
		
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBackwardToPartsOfNChars(n) )
		
			other
				stzRaise("Unsupported return type!")
		
			off

		def SplittedBackwardToPartsOfNChars(n)
			return This.SplitBackwardToPartsOfNChars(n)

	   #-----------------------------#
	  #     SPLITTING TO N PARTS    #
	 #-----------------------------#

	def SplitToNParts(n)
		aResult = []
	
		nParts = ceil( This.NumberOfChars() / n )

		for i=1 to This.NumberOfChars() step nParts
			cTemp = @oQString.mid(i-1,nParts)
			aResult + cTemp	
		next

		return aResult

		def SplitToNPartsQ(n)
			return This.SplitToNPartsQR(n, :stzList)
	
		def SplitToNPartsQR(n, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitToNParts(n) )
		
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitToNParts(n) )
		
			other
				stzRaise("Unsupported return type!")
		
			off

		def SplittedToNParts(n)
			return This.SplitToNParts(n)

	  #------------------------------------#
	 #     SPLITTING BEFORE POSITIONS     #
	#------------------------------------#

	def SplitBeforePositions(paPositions)
		aPositions = sort(paPositions)
		str = This.Content()
		aTemp = [1]

		for i in aPositions
			aTemp + (i-1) + i
		next

		aTemp + This.NumberOfChars()
		oTemp = new stzList(aTemp)
		aTemp = oTemp.SplitToPartsOf(2)

		aResult = []
		oTempList = new stzList(1:This.NumberOfChars())

		aTempList = oTempList.SplitBeforePositions(paPositions)	

		for item in aTempList
			if isList(item)
				aResult + This.Section(item[1],item[len(item)])
			but isNumber(item)
				aResult + This[item]
			but isNull(item)
				aResult + NULL
			ok
		next

		return aResult

		def SplitBeforePositionsQ(paPositions)
			return This.SplitBeforePositionsQR(paPositions, :stzList)
	
		def SplitBeforePositionsQR(paPositions, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforePositions(paPositions) )
		
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforePositions(paPositions) )
		
			other
				stzRaise("Unsupported return type!")
		
			off
	
		def SplittedBeforePositions(paPositions)
			return This.SplitBeforePositions(paPositions)

	  #-----------------------------------#
	 #     SPLITTING AFTER POSITIONS     #
	#-----------------------------------#
	
	def SplitAfterPositions(paPositions)

		if NOT isList(paPositions) and StzListQ(paPositions).IsListOfNumbers()
			stzRaise("Incorrect param type!")
		ok

		anPositions = StzListQ(paPositions).
				AddedToEachQ(2).
				RemoveItemsWQ('@item > This.NumberOfChars()').
				Content()

		aResult = This.SpliteBeforePositions(anPositions)

		return aResult

		def SplitAfterPositionsQ(paPositions)
			return This.SplitAfterPositionsQR(paPositions, :stzList)
	
		def SplitAfterPositionsQR(paPositions, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAfterPositions(paPositions) )
		
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAfterPositions(paPositions) )
		
			other
				stzRaise("Unsupported return type!")
		
			off

		def SplittedAfterPositions(paPositions)
			return This.SplitAfterPositions(paPositions)

	  #-----------------------------------------------------------#
	 #    SPLITTING BEFORE A CHAR VERIFYING A GIVEN CONDITION    #
	#-----------------------------------------------------------#

	def SplitBeforeW(pcCondition)

		anPositions = This.FindCharsW(pcCondition)
		aResult = This.SplitBeforePositions(anPositions)

		return aResult	

		def SplitBeforeWQ(pCondition)
			return This.SplitBeforeWQR(pCondition, :stzList)

		def SplitBeforeWQR(pCondition, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforeW(paPositions) )
		
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforeW(paPositions) )
		
			other
				stzRaise("Unsupported return type!")
		
			off			

		def SplittedBeforeW(pcCondition)
			return This.SplitBeforeW(pCondition)

		def SplitBeforeWhere(pCondition)
			return This.SplitBeforeW(pCondition)

			def SplitBeforeWhereQ(pCondition)
				return This.SplitBeforeWhereQR(pCondition, :stzList)
	
			def SplitBeforeWhereQR(pCondition, pcType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
		
				switch pcReturnType
				on :stzList
					return new stzList( This.SplitBeforeWhere(paPositions) )
			
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitBeforeWhere(paPositions) )
			
				other
					stzRaise("Unsupported return type!")
			
				off	

		def SplittedBeforeWhere(pcCondition)
			return This.SplitBeforeW(pCondition)

	  #-----------------------------------------------------------#
	 #    SPLITTING AFTER AN ITEM VERIFYING A GIVEN CONDITION    #
	#-----------------------------------------------------------#

	def SplitAfterW(pCondition)
		anPositions = This.FindCharsW(pcCondition)
		aResult = This.SplitAfterPositions(anPositions)

		return aResult	

		def SplitAfterWQ(pCondition)
			return This.SplitAfterWQR(pCondition, :stzList)

		def SplitAfterWQR(pCondition, pcType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAfterW(paPositions) )
		
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAfterW(paPositions) )
		
			other
				stzRaise("Unsupported return type!")
		
			off			

		def SplittedAfterW(pcCondition)
			return This.SplitAfterW(pCondition)

		def SplitAfterWhere(pCondition)
			return This.SplitAfterW(pCondition)

			def SplitAfterWhereQ(pCondition)
				return This.SplitAfterWhereQR(pCondition, :stzList)
	
			def SplitAfterWhereQR(pCondition, pcType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok
		
				switch pcReturnType
				on :stzList
					return new stzList( This.SplitAfterWhere(paPositions) )
			
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitAfterWhere(paPositions) )
			
				other
					stzRaise("Unsupported return type!")
			
				off	

		def SplittedAfterWhere(pcCondition)
			return This.SplitAfterW(pCondition)

	   #-------------------------------------#
	  #    NTH SUBSTRING AFTER SPLITTING    #
	 #    STRING USING A GIVEN SEPARATOR   #
	#-------------------------------------#

	def NthSubstring(n, acSep)
		if isNumber(n) and
		   ListIsListOfStrings(acSep) and
		   len(acSep) = 2 and
		   acSep[1] = :AfterSplittingStringUsing

			return This.NthSubstringAfterSplittingStringUsing(n, acSep[2])
		else
			stzRaise("Incorrect param types!")
		ok

		#< @FunctionFluentForm

		def NthSubstringQ(n, acSep)
			return new stzStrings( This.NthSubstring(n, acSep) )

		#>

	def NthSubstringAfterSplittingStringUsing(n, cSep)
		return This.Split(cSep)[n]

	  #---------------------#
	 #     STRING PARTS    #
	#---------------------#

	/* Note:

	This method analyzes the string, by sequentially partitioning
	its content, using a given "partinonner". Hence, it serves
	in answering this kind of question:

	How is the string composed in term of some char criteria
	(beeing, for example, lowercase or uppercase, or left-oriented
	or right-oriented).

	The partionner is what we should provide to the method as
	a param as a conditional code containing the @char keyword.

	For example:

	o1 = new stzString("TUNIS gafsa NABEUL beja")
	? o1.Parts(:Using = 'Q(@char).CharCase()' ) # NOTE: Parts() is the simple
						    # form of PartsAsSubstrings()

	Uses the CharCase() method in stzChar as a partionner.	

	And because this method returns a string equal to :Uppercase or
	:Lowercase or NULL, then the classification done will return:

	[
		"TUNIS" = :Uppercase,
		" " = NULL,
		"gafsa" = :Lowercase,
		" " = NULL,
		"NABEUL" = :Uppercase,
		" " = NULL,
		"beja" = :Lowercase
	]

	*/

	def PartsAsSubstrings(pcPartionner)
		/*
		Example:

		o1 = new stzString("Abc285XY&من")

		? o1.PartsAsSubstrings( :Using = 'Q(@char).IsLetter()' )
		--> Gives:
		[ "Abc" = TRUE, "285" = FALSE, "XY" = TRUE, "&" = FALSE, "من" = TRUE ]

		? o1.PartsAsSubstrings( :Using = 'Q(@char).Orientation()' )
		--> Gives:
		[ "Abc285XY&" = :LeftToRight, "من" = :RightToLeft ]

		? o1.PartsAsSubstrings( :Using = 'Q(@char).IsUppercase()' )
		--> Gives:
		[ "A" = TRUE, "bc285" = FALSE, "XY" = TRUE, "&من" = FALSE ]

		? o1.PartsAsSubstrings(:Using = 'Q(@char).CharCase()' )
		--> Gives:
		[ "A" = :Uppercase, "bc" = :Lowercase, "285" = NULL, "XY" = :Uppercase, "&من" = NULL ]

		*/


		if isList(pcPartionner) and StzListQ(pcPartionner).IsUsingParamList()

			pcPartionner = pcPartionner[2]

			if NOT isString(pcPartionner)
				stzRaise("Incorrect param type!")
			ok
		ok

		cCode = StzStringQ(pcPartionner).
				SimplifyQ().
				RemoveBoundsQ("{","}").
				ReplaceCSQ("@item", "@char", :CaseSensitive = FALSE).
				Content()

		cCode = "cPartionner = ( '' + " + cCode + " )"

		if This.NumberOfChars() = 1
			@char = This[1]
			eval(cCode)
			aResult = [ @char, cPartionner ]

			return aResult
		ok

		cPart = This.FirstChar()
		aParts = []

		@char = This[1]
		eval(cCode)
		cPrevious = cPartionner

		for i = 2 to This.NumberOfChars()
			

			oCurrentChar = new stzChar(This[i])
			@char = oCurrentChar.Content()

			eval(cCode)
			cCurrent = cPartionner

			oPreviousChar = new stzChar(This[i-1])
			@char = oPreviousChar.Content()
			eval(cCode)
			cPrevious = cPartionner

			if cCurrent = cPrevious
				cPart += This[i]

			else
				aParts + [ cPart, cPrevious ]
				cPart = This[i]
			ok

		end

		oLastChar = This.LastCharQ()
		@char = oLastChar.Content()
		eval(cCode)
		aParts + [ cPart, cPartionner ]

		return aParts

		#< @FunctionFluentForm

		def PartsAsSubstringsQ(pcPractionner)
			return PartsAsSubstringsQ(pcPractionner, :stzList)

		def PartsAsSubstringsQR(pcPartionner, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnTyp).IsUsingParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.PartsAsSubstrings(pcPartionner) )

			on :stzHashList
				return new stzHashList( This.PartsAsSubStrings(pcPartionner) )

			other
				stzRaise("Unsupported return type!")
			off
	
		#>

		#< @FunctionAlternativeForm

		def Parts(pcPartionner)
			return This.PartsAsSubstrings(pcPartionner)

			def PartsQ(pcPartionner)
				return new stzList( This.Parts(pcPartionner) )

		#>

	def PartsAsSections(pcPartionner)
		/*
		o1 = new stzString("TUNIS1250XT")
		? o1.PartsAsSections( :Using = :IsNumber )
		--> Gives
			[
				[ [ 1,  5], FALSE ],
				[ [ 6,  9], TRUE  ],
				[ [10, 11], FALSE ]
			]
		*/

		aParts = This.PartsAsSubstrings(pcPartionner)
	
		aResult = []
		n1 = 1
		n2 = 1
		aSection = []
	
		i = 0
		for aPair in aParts
			i++
			cPart = aPair[1]
			nLenPart = StzStringQ(cPart).NumberOfChars()

			n2 = n1 + nLenPart - 1
			aSection = [n1, n2]
	
			aResult + [ aSection, aPair[2] ]
			n1 += nLenPart
	
		next
	
		return aResult

		def PartsAsSectionsQ(pcPractionner)
			return PartsAsSectionsQ(pcPractionner, :stzList)

		def PartsAsSectionsQR(pcPartionner, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnTyp).IsUsingParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.PartsAsSections(pcPartionner) )

			on :stzHashList
				return new stzHashList( This.PartsAsSections(pcPartionner) )

			on :stzHashList@C
				return new stzHashList( This.PartsAsSections@C(pcPartionner) )

			other
				stzRaise("Unsupported return type!")
			off

	def PartsAsSections@C(pcPartionner)
		oPartsAsSections = This.PartsAsSectionsQ(:stzHashlList)
		aResult = oPartsAsSections.Classify@C(pcPartionner)

		return aResult

		def PartsAsSections@CQ(pcPractionner)
			return PartsAsSections@CQR(pcPractionner, :stzList)

		def PartsAsSections@CQR(pcPartionner, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnTyp).IsUsingParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.PartsAsSections@C(pcPartionner) )

			on :stzHashList
				return new stzHashList( This.PartsAsSections@C(pcPartionner) )

			other
				stzRaise("Unsupported return type!")
			off

	#--

	def PartsAsSubstringsAndSections(pcPartionner)
		aSubstrings = This.PartsAsSubstrings(pcPartionner)
		aSections   = This.PartsAsSections(pcPartionner)

		aResult = []

		for i = 1 to len(aSubstrings)
			aResult + [ aSubstrings[i][1], aSections[i][1], aSections[i][2] ]
		next

		return aResult

	def PartsAsSectionsAndSubstrings(pcPartionner)
		aSubstrings = This.PartsAsSubstrings(pcPartionner)
		aSections   = This.PartsAsSections(pcPartionner)

		aResult = []

		for i = 1 to len(aSubstrings)
			aResult + [ aSections[i][1], aSubstrings[i][1], aSubstrings[i][2] ]
		next

		return aResult

	  #------------------------------------#
	 #     UNIQUE PARTS OF THE STRING     #
	#------------------------------------#

	def UniqueParts(pcPartionner)
		aResult = This.PartsQ(pcPartionner).DuplicatesRemoved()
		return aResult

		def UniquePartsQ(pcPartionner)
			return This.UniquePartsQR(pcPartionner, :stzList)

		def UniquePartsQR(pcPartionner, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList(This.UniqueParts(pcPartionner))

			on :stzListOfStrings
				return new stzListOfStrings(This.UniqueParts(pcPartionner))

			other
				stzRaise("Unsupported return type!")
			off

	  #---------------------------------------#
	 #     PARTS OF THE STRING CLASSIFIED    #
	#---------------------------------------#

	def PartsAsSubstringsClassified(pcPartionner)
		// TODO

	def PartsAsSectionsClassified(pcPartionner)
		// TODO

	def PartsAsSubStringsAndSectionsClassified(pcPartionner)
		// TODO

	def PartsAsSectionsAndSubstringsClassified(pcPartionner)
		// TODO

	  #-----------------------------#
	 #     DIVIDING THE STRING     #
	#-----------------------------#

	def DivideBy(pDividor) 	# TODO: should by be included in the param
				# and function become simply Divide()?
		
		switch type(pDividor)

		on "NUMBER"
			This.SplitToNParts(n)

		on "STRING"
			n = This.NumberOfOccurrence(:Of = pDividor)
			oTempStr = StzStringQ(pDividor) * n
			
			if oTempStr.IsEqualTo(This.String())
				return n
			else
				oTempStr = ( This.Copy() - oTempStr.Content() )
				nLen = oTempStr.NumberOfChars()
				if oTempStr.IsEqualTo( This.Section(1, n) )
					nResult = n + nLen / StzStringQ(pDividor).NumberOfChars()
					return nResult
				else
					return n
				ok
			ok
		off

	  #-------------------------------------#
	 #   SORTING THE CHARS OF THE STRING   #
	#-------------------------------------#

	def CharsSortingOrder()
		cResult = :Unsorted

		if This.CharsAreSorted()
			if This.CharsAreSortedInAscending()
				cResult = :Ascending
			else
				cResult = :Descending
			ok
		ok

		return cResult

		def SortingOrder()
			return This.CharsSortingOrder()
			

	def HasSameCharsSortingOrderAs(pcOtherStr)

		oTemp = new stzString(pcOtherStr)
		if oTemp.CharsSortingOrder() = This.CharsSortingOrder()
			return TRUE
		else
			return FALSE
		ok

		def HasSameCharsOrderAs(pcOtherStr)
			return This.HasSameCharsSortingOrderAs(pcOtherStr)

		def HasSameSortingOrderAs(pcOtherStr)
			return This.HasSameCharsSortingOrderAs(pcOtherStr)

	def CharsAreSorted()
		if This.CharsAreSortedInAscending() or
		   This.CharsAreSortedInDescending()
			return TRUE
		else
			return FALSE
		ok

		def IsSorted()
			return This.CharsAreSorted()

	def CharsAreSortedInAscending()
		/*
		The idea is to sort a copy of the string in ascending order
		and then compare the copy to the original string...
		If they are identical, then the string is sorted in ascending order!
		*/

		oSortedInAscending = This.Copy().SortCharsInAscendingQ()

		for i = 1 to This.NumberOfChars()
			if NOT AreEqual([ oSortedInAscending[i] , This[i] ])
				return FALSE
			ok
		next

		return TRUE

		def IsSortedInAscending()
			return This.CharsAreSortedInAscending()

	def CharsAreSortedInDescending()
		/*
		The idea is to reverse the string, and check if its reversed
		copy is sorted in ASCENDING order. If so, then the string itself
		is actually sorted in DESCENDING order!
		*/
		oTemp = new stzString( This.CharsReversed() )
		if oTemp.CharsAreSortedInAscending()
			return TRUE
		else
			return FALSE
		ok

		def IsSortedInDescending()
			return This.CharsAreSortedInDescending()

	def SortCharsInAscending()
		
		aResult = This.CharsQ().SortInAscendingQ().ToStzListOfStrings().Concatenated()

		This.Update( aResult )

		def SortCharsInAscendingQ()
			This.SortCharsInAscending()
			return This

		def SortInAscending()
			This.SortCharsInAscending()

			def SortInAscendingQ()
				This.SortInAscending()
				return This
			
	def StringWithCharsSortedInAscending()
		cResult = This.Copy().SortCharsInAscendingQ().Content()
		return cResult

		def SortedInAscending()
			return This.StringWithCharsSortedInAscending()

		def Sorted()
			return This.SortedInAscending()

	def SortCharsInDescending()
		aReversed = ListReverse( This.SortCharsInAscendingQ().Chars() )
		cResult = StzListOfStringsQ(aReversed).Concatenated()

		This.Update( cResult )

		def SortCharsInDescendingQ()
			This.SortCharsInDescending()
			return This

		def SortInDescending()
			This.SortCharsInDescending()

			def SortInDescendingQ()
				This.SortInDescending()
				return This
			
	def StringWithCharsSortedInDescending()
		cResult = This.Copy().SortCharsInDescendingQ().Content()
		return cResult

		def SortedInDescending()
			return This.StringWithCharsSortedInDescending()

	  #------------------------------------------------------------#
	 #     COMPARING THE STRING TO OTHER STRINGS USING UNICODE    #
	#------------------------------------------------------------#
	# TODO: add Casesensitivity support

	// Compares the main string with an other string (base on the unicode code table)
	// --> Use this for internal string comparisons and sorting
	// --> For lists presented to the user, use SystemLocaleCompare()

	def UnicodeCompareWithCS(pcOtherStr, pCaseSensitive)
		# pCaseSensitive -> :CaseSensitive = TRUE or FALSE

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if isNumber(pCaseSensitive) and
		   ( pCaseSensitive = 0 or pCaseSensitive = 1 )

			nQtResult = @oQString.compare(pcOtherStr, pCaseSensitive)

		else
			stzRaise("Incorrect value of pCaseSensitive! Should be 0 or 1 (TRUE or FALSE).")
		ok
	
		if  nQtResult = 0
			return :Equal	# Be careful :Equal is "equal" and not "Equal" with capital "E"

		but nQtResult < 0
			return :Less

		but  nQtResult > 0
			return :Greater
		ok
		/*
		Returns :Equal, :Less, or :Greater:

		:Equal   --> The 2 strings are equal
		:Less    --> The main string is "less" then the substring
		:Greater --> The main string is "greater" then the substring
		
		"less" and "greater" should be understood at the sense
		provided to them by Qt. Read this:
	
		https://doc.qt.io/qt-5/qstring.html#comparing-strings
		*/

	def UnicodeCompareWith(pcOtherStr)
		return CompareWithCS(pcOtherStr, :CaseSensitive = TRUE)

	def UnicodeCompareWithInSystemLocale(pcOtherString)
		nQtResult = @oQString.localeAwareCompare(pcOtherString)

		if nQtResult = 0
			return :equal
		but nQtResult < 0
			return :less
		but nQtResult > 0
			return :greater
		ok
		/*
		From Qt documentation:
	
		The comparison is performed in a locale- and also
		platform-dependent manner. Use this function to present
		sorted lists of strings to the user.

		NOTE:
		This works only for the current system locale.

		To compare for a defined locale, softanza should rely on
		the QCollator class in RingQt (which is not implemented yet)

		--> TODO: Add QCollator class to RingQt and make CompareWithInLocale()
		*/

	def UnicodeCompareWithInLocale(pcOtherString, pLocale) # TODO
		// Needs the implementation of QCollator class in RingQt (read comment
		// in SystemLocaleCompareWith() methof above

	def IsUnicodeEqualTo(pcOtherString)
		return This.UnicodeCompareWith(pcOtherNumber) = :Equal

		def IsUnicodeDifferentFrom(pcOtherString)
			return NOT This.IsUnicodeEqualTo(pcOtherString)

		def IsNotUnicodeEqualTo(pcOtherString)
			return NOT This.IsUnicodeEqualTo(pcOtherString)

	def IsUnicodeEqualToInLocale(pcOtherString, pLocale)
		return This.UnicodeCompareWithInLocale(pcOtherNumber, pLocale) = :Equal

		def IsUnicodeDifferentFromInLocale(pcOtherString, pLocale)
			return NOT This.IsUnicodeEqualToInLocale(pcOtherString, pLocale)

		def IsNotUnicodeEqualToInLocale(pcOtherString, pLocale)
			return NOT This.IsUnicodeEqualToInLocale(pcOtherString, pLocale)

	def IsUnicodeLessThan(pcOtherString)
		return This.UnicodeCompareWith(pcOtherNumber) = :Less

		def IsUnicodeLessThanInLocale(pcOtherString, pLocale)
			return This.UnicodeCompareWithInLocale(pcOtherNumber, pLocale) = :Less
	
	def IsUnicodeGreaterThan(pcOtherString)
		return This.UnicodeCompareWith(pcOtherNumber) = :Greater

		def IsUnicodeGreaterThanInLocale(pcOtherString, pLocale)
			return This.UnicodeCompareWithInLocale(pcOtherNumber, pLocale) = :Greater

	  #-----------------------------------------------#
	 #     COMPARING THE STRING TO OTHER STRINGS     #
	#-----------------------------------------------#

	def IsEqualToCS(pcOtherString, pCaseSensitive)

		if NOT isString(pcOtherString)
			return FALSE
		ok

		if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if pCaseSensitive = TRUE

			return This.String() = pcOtherString

		but pCaseSensitive = FALSE
			return This.Lowercased() = StzStringQ(pcOtherString).Lowercased()
		ok
		
	def IsEqualTo(pcOtherString)
		return This.IsEqualToCS(pcOtherString, :CaseSensitive = TRUE)

		#< @FunctionNegationForm

		def IsNotEqualTo(pcOtherString)
			return NOT This.IsEqualTo(pcOtherString)

			def IsDifferentFrom(pcOtherString)
				return This.IsNotEqualTo(pcOtherString)
	
		#>

	def IsStrictlyEqualToCS(pcOtherString, pCaseSensitive)
		if This.IsEqualToCS(pcOtherString, pCaseSensitive) and
		   This.HasSameSortingOrderAs(pcOtherString)

			return TRUE

		else
			return FALSE
		ok

		#< @FunctionNegationForm

		def IsNotStrictlyEqualToCS(pcOtherString, pCaseSensitive)
			return NOT This.IsStrictlyEqualTo(pcOtherString, pCaseSensitive)
	
		#>

	def IsStrictlyEqualTo(pcOtherString)
		return This.IsStrictlyEqualToCS(pcOtherString, :CaseSensitive = TRUE)

		def IsNotStrictlyEqualTo(pcOtherString)
			return NOT This.IsStrictlyEqualTo(pcOtherString)

	def IsLessThan(pcOtherString)
		return This.IsIncludedIn(pcOtherString)

		def IsStrictlyLessThan(pcOtherString)
			return This.IsLessThan(pcOtherString)

	def IsGreaterThan(pcOtherString)
		return This.Contains(pcOtherString)

		def IsStrictlyGreaterThan(pcOtherString)
			return This.IsGreaterThan(pcOtherString)

	def IsQuietEqualTo(pcOtherString)
		# WARNING: Performance issue is caused by DiacriticsRemoved()

		cThisString = This.LowercaseQ().DiacriticsRemoved()

		cOtherString = StzStringQ(pcOtherString).LowercaseQ().DiacriticsRemoved()

		if cThisString = cOtherString
			return TRUE
		ok

		nDif = abs(This.NumberOfChars() - StzStringQ(pcOtherString).NumberOfChars())
		n = nDif / This.NumberOfChars()
		
		if n <= QuietEqualityRatio() # 0.09 by default, can be changed with SetQuietEqualityRatio(n)
			return TRUE
		ok

		return FALSE

	  #-------------------------------------------------#
	 #     STRING IS A MULTIPLE OF AN OTHER STRING     #
	#-------------------------------------------------#

	def IsMultipleOfCS(pcSubStr, pCaseSensitive)
		if NOT isString(pcSubStr)
			return FALSE
		ok

		n = This.NumberOfOccurrenceCS( :Of = pcSubStr, pCaseSensitive )

		oStr = StzStringQ(pcSubStr) * n

		return oStr.IsEqualToCS(This.String(), pCaseSensitive)

	def IsMultipleOf(pcSubStr)
		return This.IsMultipleOfCS(pcSubStr, :CaseSensitive = TRUE)

	def IsNTimesMultipleOfCS(n, pcSubStr, pCaseSensitive)
		if NOT isString(pcSubStr)
			return FALSE
		ok

		oStr = StzStringQ(pcSubStr) * n

		return oStr.IsEqualToCS(This.String(), pCaseSensitive)

	def IsNTimesMultipleOf(n, pcSubStr)
		return This.IsNTimesMultipleOfCS(n, pcSubStr, :CaseSensitive = TRUE)

	  #------------------------------------------------#
	 #     STRING IS A SPLITTER OF AN OTHER STRING    #
	#------------------------------------------------#

	def IsSplitterOfCS(pcOtherString, pCaseSensitive)
		if Not isString(pcOtherString)
			return FALSE
		ok

		bResult = StzStringQ(pcOtherString).NumberOfOccurrenceCS( :Of = This.String(), pCaseSensitive ) > 1
		return bResult

	def IsSplitterOf(pcOtherString)
		bResult = This.IsSplitterOfCS(pcOtherString, :CaseSensitive = TRUE)
		return bResult

	  #---------------------------------------------------#
	 #     STRING IS SPLITTABLE USING AN OTHER STRING    #
	#---------------------------------------------------#

	def IsSplittableUsingCS(pcSubStr)
		if Not isString(pcOtherString)
			return FALSE
		ok

		return Q(pcSubStr).IsSplitterOfCS( This.String(), pCaseSensitive )

	def IsSplittableUsing(pcSubStr)
		return This.IsSplittableUsingCS(pcSubStr, pCaseSensitive)

	  #==============================#
	 #    REMOVING ALL SUBSTRINGS   # 
	#==============================#

	def RemoveAllCS(pSubStr, pCaseSensitive)
		This.ReplaceAllCS(pSubstr, "", pCaseSensitive)

		def RemoveAllCSQ(pSubStr, pCaseSensitive)
			This.RemoveAllCS(pSubStr, pCaseSensitive)
			return This
	
		def RemoveCS(pSubStr, pCaseSensitive)
			This.RemoveAllCS(pSubStr, pCaseSensitive)

			def RemoveCSQ(pSubStr, pCaseSensitive)
				This.RemoveCS(pSubStr, pCaseSensitive)
				return This

		def RemoveSubstringCS(pcSubStr, pCaseSensitive)
			This.RemoveAllCS(pcSubStr, pCaseSensitive)

			def RemoveSubstringCSQ(pSubStr, pCaseSensitive)
				This.RemoveSubstringCS(pSubStr, pCaseSensitive)
				return This

		def RemoveAllOccurrencesOfSubstringCS(pcSubStr, pCaseSensitive)
			This.RemoveAllCS(pcSubStr, pCaseSensitive)

			def RemoveAllOccurrencesOfSubstringQ(pSubStr, pCaseSensitive)
				This.RemoveAllOccurrencesOfSubstring(pSubStr, pCaseSensitive)
				return This

	#-- CASE-INSENSITIVE

	def RemoveAll(pcSubStr) # replace with @oQString.remove() when added to RingQt
		This.ReplaceAll(pcSubStr , "")

		def RemoveAllQ(pcSubStr)
			This.RemoveAll(pcSubStr)
			return This

		def Remove(pcSubStr)
			This.RemoveAll(pcSubStr)

			def RemoveQ(pcSubStr)
				This.Remove(pcSubStr)
				return This

		def RemoveSubstring(pcSubStr)
			This.RemoveAll(pcSubStr)


		def RemoveAllOccurrencesOfSubstring(pcSubStr)
			This.RemoveAll(pcSubStr)
	
	  #----------------------------------------------#
	 #   REMOVING MANY SUBSTRING AT THE SAME TIME   #
	#----------------------------------------------#

	def RemoveManyCS(pacSubStr, pCaseSensitive)
		for cSubstr in paCsubstr
			This.RemoveAllCS(cSubstr, pCaseSensitive)
		next

		def RemoveManyCSQ(pacSubStr, pCaseSensitive, pCaseSensitive)
			This.RemoveManyCS(pacSubStr, pCaseSensitive)
			return This

		def RemoveAllOfTheseCS(pacSubStr, pCaseSensitive)
			This.RemoveMany(pacSubStr)

			def RemoveAllOfTheseCSQ(pacSubStr, pCaseSensitive)
				This.RemoveAllOfTheseCS(pacSubstr, pCaseSensitive)
				return This

		def RemoveManySubstringsCS(pcSubStr, pCaseSensitive)
			This.RemoveAllCS(pcSubStr, pCaseSensitive)

			def RemoveManySubstringsCSQ(pSubStr, pCaseSensitive)
				This.RemoveManySubstringsCS(pSubStr, pCaseSensitive)
				return This

	def ManySubstringsRemovedCS(pacSubStr, pCaseSensitive)
		return This.Copy().RemoveManySubstringsCS(pacSubStr, pCaseSensitive).Content()

		def SubstringsRemovedCS(pacSubStr, pCaseSensitive)
			return This. ManySubstringsRemovedCS(pacSubStr, pCaseSensitive)

	#-- CASEèSENSITIVE

	def RemoveMany(pacSubStr)
		for cSubstr in paCsubstr
			This.RemoveAll(cSubstr)
		next

		def RemoveManyQ(pacSubStr)
			This.RemoveMany(pacSubstr)
			return This

		def RemoveAllOfThese(pacSubstr)
			This.RemoveMany(pacSubStr)

			def RemoveAllOfTheseQ(pacSubstr)
				This.RemoveAllOfThese(pacSubstr)
				return This

		def RemoveManySubstrings(pcSubStr)
			This.RemoveMany(pacSubStr)

			def RemoveManySubstringsQ(pSubStr)
				This.RemoveManySubstrings(pSubStr, pCaseSensitive)
				return This

	def ManySubstringsRemoved(pacSubStr)
		return This.Copy().RemoveManySubstrings(pacSubStr).Content()

		def SubstringsRemoved(pacSubStr)
			return This. ManySubstringsRemoved(pacSubStr)

	  #---------------------------------------#
	 #   REMOVING CHAR AT A GIVEN POSITION   #
	#---------------------------------------#

	def RemoveCharAtPosition(n)
		This.ReplaceNthChar(n, "")

		cResult = This.CharsQR(:stzListOfStrings).
				RemoveStringAtPositionQ(n).
				Concatenated()

		This.Update( cResult )

		def RemoveCharAtPositionQ(n)
			This.RemoveCharAtPosition(n)
			return This

		def RemoveCharAt(n)
			This.RemoveCharAtPosition(n)

			def RemoveCharAtQ(n)
				This.RemoveCharAt(n)
				return This

		def RemoveNthChar(n)
			This.RemoveCharAtPosition(n)

	def CharAtPositionRemoved(n)
		return This.Copy().RemoveCharAtPositionQ(n).Content()

		def NthCharRemoved(n)
			return This.CharAtPositionRemoved(n)

	  #---------------------------------#
	 #   REMOVING FIRST & LAST CHARS   #
	#---------------------------------#

	def RemoveFirstChar()
		This.RemoveNthChar(1)

		def RemoveFirstCharQ()
			This.RemoveFirstChar()
			return This

	def FirstCharRemoved()
		return This.Copy().RemoveFirstCharQ().Content()

	#--

	def RemoveLastChar()
		This.RemoveNthChar(:Last)

		def RemoveLastCharQ()
			This.RemoveLastChar()
			return This

	def LastCharRemoved()
		return This.Copy().RemoveLasttCharQ().Content()

	  #---------------------------------#
	 #   REMOVING LEFT & RIGHT CHARS   #
	#---------------------------------#

	def RemoveLeftChar()
		This.RemoveNLeftChars(1)

		def RemoveLeftCharQ()
			This.RemoveLeftChar()
			return This

	def LeftCharRemoved()
		cResult = This.Copy().RemoveLeftCharQ().Content()
		return cResult

	def RemoveRightChar()
		This.RemoveNRightChars(1)

		def RemoveRightCharQ()
			This.RemoveRightChar()
			return This

	def RightCharRemoved()
		cResult = This.Copy().RemoveRightCharQ().Content()
		return cResult

	  #----------------------------#
	 #   REMOVING N FIRST CHARS   #
	#----------------------------#

	def RemoveNFirstChars(n)
		if This.IsRightToLeft()
			This.RemoveNRightChars(n)
		else
			This.RemoveNLeftChars(n)
		ok
		
		#< @FunctionFluentForm

		def RemoveNFirstCharsQ(n)
			This.RemoveNFirstChars(n)
			return This
	
		#>

		#< @FunctionAlternativeForm

		def RemoveFirstNChars(n)
			This.RemoveNFirstChars(n)

			#< @FuncFluentForm
	
			def RemoveFirstNCharsQ(n)
				This.RemoveNFirstCharsQ(n)
	
			#>

		#>
	
	def NFirstCharsRemoved(n)
		cRresult = This.Copy().RemoveNFirstCharsQ(n).Content()
		return cResult

		def FirstNCharsRemoved(n)
			return This.NFirstCharsRemoved(n)

	  #---------------------------#
	 #   REMOVING N LAST CHARS   #
	#---------------------------#

	def RemoveNLastChars(n)

		if This.IsLeftToRight()
			This.RemoveNRightChars(n)
		else
			This.RemoveNLeftChars(n)
		ok	

		#< @FunctionFluentForm

		def RemoveNLastCharsQ(n)
			This.RemoveNLastChars(n)
			return This
	
		#>

		#< @FunctionAlternativeForm

		def RemoveLastNChars(n)
			This.RemoveNLastChars(n)

			#< @FuncFluentForm
	
			def RemoveLastNCharsQ(n)
				This.RemoveNLastCharsQ(n)
	
			#>

		#>
	
	def NLastCharsRemoved(n)
		cResult = This.Copy().RemoveNLastCharsQ(n).Content()
		return cResult

		def LastNCharsRemoved(n)
			return This.NLastCharsRemoved(n)

	  #---------------------------#
	 #   REMOVING N LEFT CHARS   #
	#---------------------------#

	def RemoveNLeftChars(n)
		if This.IsLeftToRight()
			This.RemoveSection( 1, n )

		else
			This.RemoveSection( This.NumberOfChars() - n + 1, :LastChar )
		ok

		#< @FunctionFluentForm

		def RemoveNLeftCharsQ(n)
			This.RemoveNLeftChars(n)
			return This
	
		#>

		#< @FunctionAlternativeForm

		def RemoveLeftNChars(n)
			This.RemoveNLeftChars(n)

			#< @FuncFluentForm
	
			def RemoveLeftNCharsQ(n)
				This.RemoveNLeftCharsQ(n)
	
			#>
		#>
	
	def NLeftCharsRemoved(n)
		cResult = This.Copy().RemoveNLeftCharsQ(n).Content()
		return cResult

		def LeftNCharsRemoved(n)
			return This.NLeftCharsRemoved(n)

	  #----------------------------#
	 #   REMOVING N RIGHT CHARS   #
	#----------------------------#

	def RemoveNRightChars(n)
		if This.IsRightToLeft()
			This.RemoveSection( 1, n)
		else
			This.RemoveSection( This.NumberOfChars() - n + 1, :LastChar )
		ok

		#< @FunctionFluentForm

		def RemoveNRightCharsQ(n)
			This.RemoveNRightChars(n)
			return This
	
		#>

		#< @FunctionAlternativeForm

		def RemoveRightNChars(n)
			This.RemoveNRightChars(n)

			#< @FuncFluentForm
	
			def RemoveRightNCharsQ(n)
				This.RemoveNRightCharsQ(n)
	
			#>
		#>
	
	def NRightCharsRemoved(n)
		cResult = This.Copy().RemoveNRightCharsQ(n).Content()
		return cResult

		def RightNCharsRemoved(n)
			return This.NRightCharsRemoved(n)

	  #---------------------------------------------#
	 #    REMOVING A GIVEN CHAR FROM THE STRING    # 
	#---------------------------------------------#

	def RemoveCharCS(pcChar, pCaseSensitive) # TODO (future): accept also stzChar objects
		if NOT StringIsChar(pcChar)
			stzRaise("Incorrect param type! You must provide a string containing char")
		ok

		This.RemoveCharsCSW('@char = ' + @@(pcChar), pCaseSensitive)

		def RemoveCharCSQ(pcChar, pCaseSensitive)
			This.RemoveCharCS(pcChar, pCaseSensitive)
			return This

	def CharRemovedCS(pcChar, pCaseSensitive)
		cResult = This.Copy().RemoveCharCSQ(pcChar, pCaseSensitive).Content()
		return cResult

	#-- CASE-INSENSITIVE

	def RemoveChar(pcChar)
		if NOT StringIsChar(pcChar)
			stzRaise("Incorrect param type! You must provide a string containing char")
		ok

		This.RemoveCharsW('@char = ' + @@(pcChar))

		def RemoveCharQ(pcChar)
			This.RemoveChar(pcChar)
			return This

	def CharRemoved(pcChar)
		cResult = This.Copy().RemoveCharQ(pcChar).Content()
		return cResult

	  #----------------------------------#
	 #    REMOVING A SECTION OF CHARS   # 
	#----------------------------------#
	
	// Removes a portion of the string defined by its start and end positions
	def RemoveSection(n1, n2)
		#< @MotherFunction = This.ReplaceSection() > @QtBased = TRUE #>

		if n1 = :FirstChar or n1 = :StartOfString { n1 = 1 }
		if n2 = :LastChar  or n2 = :EndOfString { n2 = This.NumberOfChars() }

		This.ReplaceSection( n1, n2, "" )

		def RemoveSectionQ(n1, n2)
			This.RemoveSection(n1, n2)
			return This

	def SectionRemoved(n1, n2)
		cResult = This.Copy().RemoveSectionQ(n1, n2).Content()
		return cResult
	
	  #-------------------------------------------------------#
	 #    REMOVING MANY SECTIONS OF CHARS AT THE SAME TIME   # 
	#-------------------------------------------------------#

	def RemoveManySections(paListOfSections)
		if isList(paListOfSections) and Q(paListOfSections).IsListOfPairsOfNumbers()
			stzRaise([
				:Where = "stzString (10747) > RemoveManySections(paListOfSections)",
				:What  = "Can't remove many sections from the string.",
				:Why   = "The value is you provided (paListOfSections) is not a list of pairs of numbers."
			])
		ok

		/* EXAMPLE
		
		o1 = new stzString("**word1***word2**word3***")
		? o1.Sections([ [1,2], [8, 10], [16, 17], [23, 25] ])
		#--> [ "**", "***", "**", "***" ]
		
		o1.RemoveManySections([
			[1,2], [8, 10], [16, 17], [23, 25]
		])
		
		? o1.Content() # --> "blablablablabla"

		*/

		# For each section, remove the section, and then adjust the positions
		# inside the other sections that come after it, to reflect the
		# changed content of the string

		n = 0
		nNumberOfSections = len(paListOfSections)
		
		for aSection in paListOfSections
			nNumberOfCharsInSection = aSection[2] - aSection[1] + 1
			n++
			# Remove the section
			This.RemoveSection(aSection[1], aSection[2])

			# Adjust the positions of the remaing sections
			for i = n + 1 to nNumberOfSections
				# If this section comes to the right of the section
				# removed, then adjust the positions
				if paListOfSections[i][1] > aSection[2]
						paListOfSections[i][1] -= nNumberOfCharsInSection
						paListOfSections[i][2] -= nNumberOfCharsInSection
				ok
			next

		next

		def RemoveManySectionsQ(paListOfSections)
			This.RemoveManySections(paListOfSections)
			return This

		def RemoveSections(paListOfSections)
			This.RemoveManySections(paListOfSections)

			def RemoveSectionsQ(paListOfSections)
				This.RemoveSections(paListOfSections)
				return This

	def ManySectionsRemoved(paListOfSections)
		cResult = This.Copy().RemoveManySectionsQ(paListOfSections).Content()
		return This

		def SectionsRemoved(paListOfSections)
			return This.ManySectionsRemoved(paListOfSections)

	  #--------------------------------#
	 #    REMOVING A RANGE OF CHARS   # 
	#--------------------------------#

	// Removes a portion of the string defined by a start position and
	// a range of n chars
	def RemoveRange(nStart, nNumberOfChars)

		if nStart = :FirstChar or nStart = :StartOfString { nStart = 1 }
		if nNumberOfChars = :EndOfString { nNumberOfChars = This.NumberOfChars() - nStart + 1 }

		This.RemoveSection(nStart, nStart + nNumberOfChars - 1)

		def RemoveRangeQ(nStart, nNumberOfChars)
			This.RemoveRange(nStart, nNumberOfChars)
			return This

	def RangeRemoved(nStart, nNumberOfChars)
		cResult = This.RemoveRangeQ(nStart, nNumberOfChars).Content()
		return cResult

	  #-----------------------------------------------------#
	 #    REMOVING MANY RANGES OF CHARS AT THE SAME TIME   # 
	#-----------------------------------------------------#

	def RemoveManyRanges(paListOfRanges)

		# Tranform ranges to sections and then use RemoveManySections()

		aSections = []
		for aRange in paListOfRanges
			n1 = aRange[1]
			n2 = aRange[1] + aRange[2] - 1

			aSections + [ n1, n2 ]
		next
		
		This.RemoveManySections(aSections)

		def RemoveManyRangesQ(paListOfRanges)
			This.RemoveManySections(paListOfRanges)

		def RemoveRanges(paListOfRanges)
			This.RemoveManyRanges(paListOfRanges)

			def RemoveRangesQ(paListOfRanges)
				This.RemoveRanges(paListOfRanges)
				return This

	def ManyRangesRemoved(paListOfRanges)
		cResult = This.Copy().RemoveManyRangesQ(paListOfRanges).Content()
		return This

		def RangedRemoved(paListOfRanges)
			return This.ManyRangesRemoved(paListOfRanges)

	  #-------------------------------------------------------------#
	 #    REMOVING SECTIONS OF CHARS VERIFYING A GIVEN CONDITION   # 
	#-------------------------------------------------------------#

	def RemoveSectionsW(paSections, pcCondition)
		/* EXAMPLE

		o1 = new stzString("..AA..aa..BB..bb")
		o1.RemoveSectionsW(
			[3, 4], [7,8], [11,12], [15,16],
			:Wehre = '{ Q(This(@section)).IsLowercase() }'
		)

		#--> "..AA....BB.."
		*/

		if isList(pcCondition) and StzListQ(pcCondition).IsWhereParamList()
			pcCondition = pcCondition[2]

		else
			// TODO: add this check everywhere in the library!
			stzRaise("Incorrect condition format!")
		ok

		pcCondition = StzStringQ(pcCondition).
				SimplifyQ().
				RemoveBoundsQ("{","}").
				Content()

		cCode = "bOk = ( " + pcCondition + " )"

		aSubStrings = This.Sections(paSections)

		aSectionsToRemove = []
		for i = 1 to len( paSections )
			@n1 = paSections[i][1]
			@n2 = paSections[i][2]

			@range = aSubStrings[i]

			eval(cCode)

			if bOk
				aSectionsToRemove + [ @n1, @n2 ]
			ok
		next

		This.RemoveManySections(aSectionsToRemove)

		#< @FunctionFluentForm

		def RemoveSectionsWQ(paSections, pcCondition)
			This.RemoveSectionsW(paSections, pcCondition)
			return This

		def RemoveSectionsWhere(paSections, pcCondition)
			This.RemoveSectionsW(paSections, pcCondition)

			def RemoveSectionsWhereQ(paSections, pcCondition)
				This.RemoveSectionsWhere(paSections, pcCondition)
				return This

		def RemoveManySectionsW(paSections, pcCondition)
			This.RemoveSectionsW(paSections, pcCondition)
	
			def RemoveManySectionsWQ(paSections, pcCondition)
				This.RemoveManySectionsW(paSections, pcCondition)
				return This

		def RemoveManySectionsWhere(paSections, pcCondition)
			This.RemoveSectionsW(paSections, pcCondition)

			def RemoveManySectionsWhereQ(paSections, pcCondition)
				This.RemoveManySectionsWhere(paSections, pcCondition)
				return This

	def ManySectionsRemovedW(paSections, pcCondition)
		cResult = This.Copy().RemoveManySectionsQ(paSections, pcCondition).Content()
		return cResult

		def ManySectionsRemovedWhere(paSections, pcCondition)
			return This.ManySectionsRemovedW(paSections, pcCondition)

	  #----------------------------------------------------------------#
	 #    REMOVING MANY RANGES OF CHARS VERIFYING A GIVEN CONDITION   # 
	#----------------------------------------------------------------#

	def RemoveManyRangesW(paListOfRanges, pcCondition)

		# Tranform ranges to sections and then use RemoveManySectionsW()

		aSections = []
		for aRange in paListOfRanges
			n1 = aRange[1]
			n2 = aRange[1] + aRange[2] - 1

			aSections + [ n1, n2 ]
		next
		
		This.RemoveManySectionsW(aSections, pcCondition)

		def RemoveManyRangesWQ(paListOfRanges, pcCondition)
			This.RemoveManyRangesW(paListOfRanges, pcCondition)

		def RemoveRangesW(paListOfRanges, pcCondition)
			This.RemoveManyRangesW(paListOfRanges, pcCondition)

			def RemoveRangesWQ(paListOfRanges, pcCondition)
				This.RemoveRangesW(paListOfRanges, pcCondition)
				return This

	def ManyRangesRemovedW(paListOfRanges, pcCondition)
		cResult = This.Copy().RemoveManyRangesWQ(paListOfRanges, pcCondition).Content()
		return cResult

		def RangedRemovedW(paListOfRanges, pcCondition)
			return This.ManyRangesRemovedW(paListOfRanges, pcCondition)

	  #-------------------------------------------------#
	 #    REMOVING CHARS VERIFYING A GIVEN CONDITION   # 
	#-------------------------------------------------#

	def RemoveCharsWhere(pcCondition)

		if isList(pcCondition) and stzListQ(pcCondition).IsWhereParamList()
			pcCondition = pcCondition[2]

			if NOT isString(pcCondition)
				stzRaise("Incorrect param type! pcCondition mus tbe a string.")
			ok
		ok

		anPositions = This.FindAllCharsWhereQ( pcCondition ).SortedInDescending()

		for for n in anPositions
			This.RemoveCharAtPosition(n)
		next

		#< @FunctionFluentForm

		def RemoveCharsWhereQ(pcCondition)
			This.RemoveCharsWhere(pcCondition)
			return This

		#>

		def RemoveCharsW(pcCondition)
			This.RemoveCharsWhere(pcCondition)

			def RemoveCharsWQ(pcCondition)
				This.RemoveCharsW(pcCondition)
				return This

		def RemoveAllcharsWhere(pcCondition)
			This.RemoveCharsWhere(pcCondition)

			def RemoveAllcharsWhereQ(pcCondition)
				This.RemoveAllcharsWhere(pcCondition)
				return This

		def RemoveAllcharsW(pcCondition)
			This.RemoveCharsWhere(pcCondition)

			def RemoveAllcharsWQ(pcCondition)
				This.RemoveAllCharsWhere(pcCondition)
				return This

		def RemoveW(pCondition)
			This.RemoveCharsWhere(pCondition)

			def RemoveWQ(pCondition)
				This.RemoveW(pCondition)
				return This

	  #-----------------------------------#
	 #    REPLACING A SECTION OF CHARS   # 
	#-----------------------------------#
	
	// Replaces a portion of the string defined by its start and end positions

	def ReplaceSection(n1, n2, pcNewSubStr)
		#< @MotherFunction = YES | @QtBased #>

		# Checking the correctness of n1 and n2 params

		if NOT BothAreNumbers(n1, n2)
			stzRaise("Incorrect param types! n1 and n2 must be numbers.")
		ok

		if n1 = :FirstChar or n1 = :StartOfString { n1 = 1 }
		if n2 = :LastChar  or n2 = :EndOfString { n2 = This.NumberOfChars() }

		# Checking the correctness of pcNewSubStr param

		if isString(pcNewSubStr)
			cNewSubStr = pcNewSubStr
	
		but isList(pcNewSubstr) and Q(pcNewSubStr).IsWithParamList()
			cNewSubStr = pcNewSubStr[2]

			if pcNewSubStr[1] = :With@

				cCode = StzStringQ(cNewSubStr).
					SimplifyQ().
					RemoveBoundsQ("{","}").
					Content()

				@section = This.Section(n1, n2)
				cCode = "cNewSubStr = " + cCode

				eval(cCode)
			
			ok

		else
			stzRaise("Incorrect param type! pcNewSubStr must be a string.")
		ok

		# Doing the job

		QStringObject().replace(n1 - 1, n2 - n1 + 1, cNewSubStr)

		#< @FunctionFluentForm

		def ReplaceSectionQ(n1, n2, pcNewSubStr)
			This.ReplaceSection(n1, n2, pcNewSubStr)
			return This

		#>

	def SectionReplaced(n1, n2, pcNewSubStr)
		cResult = This.Copy().ReplaceSectionQ(n1, n2, pcNewSubStr).Content()
		return cResult
	
	  #--------------------------------------------------------#
	 #    REPLACING MANY SECTIONS OF CHARS AT THE SAME TIME   # 
	#--------------------------------------------------------#

	def ReplaceManySections(paListOfSections, pcNewSubStr)
		if isList(paListOfSections) and Q(paListOfSections).IsListOfPairsOfNumbers()
			stzRaise([
				:Where = "stzString (10747) > ReplaceManySections(paListOfSections, pcNewSubStr)",
				:What  = "Can't Replace many sections from the string.",
				:Why   = "The value is you provided (paListOfSections) is not a list of pairs of numbers."
			])
		ok

		/* EXAMLE
		
		o1 = new stzString("**word1***word2**word3***")
		? o1.Sections([ [1,2], [8, 10], [16, 17], [23, 25] ])
		#--> [ "**", "***", "**", "***" ]
		
		o1.ReplaceManySections([ [1,2], [8, 10], [16, 17], [23, 25] ], "_"
		
		? o1.Content() # --> "_word1_word2_word3_"

		*/

		# For each section, Replace the section, and then adjust the positions
		# inside the other sections that come after it, to reflect the
		# changed content of the string

		n = 0
		nNumberOfSections = len(paListOfSections)
		
		for aSection in paListOfSections
			nNumberOfCharsInSection = aSection[2] - aSection[1] + 1
			n++
			# Replace the section
			This.ReplaceSection(aSection[1], aSection[2], pcNewSubStr)

			# Adjust the positions of the remaing sections
			for i = n + 1 to nNumberOfSections
				# If this section comes to the right of the section
				# Replaced, then adjust the positions
				if paListOfSections[i][1] > aSection[2]
						paListOfSections[i][1] -= nNumberOfCharsInSection
						paListOfSections[i][2] -= nNumberOfCharsInSection
				ok
			next

		next

		def ReplaceManySectionsQ(paListOfSections, pcNewSubStr)
			This.ReplaceManySections(paListOfSections, pcNewSubStr)
			return This


		def ReplaceSections(paListOfSections, pcNewSubStr)
			This.ReplaceManySections(paListOfSections, pcNewSubStr)

			def ReplaceSectionsQ(paListOfSections, pcNewSubStr)
				This.ReplaceSections(paListOfSections, pcNewSubStr)
				return This

	def ManySectionsReplaced(paListOfSections, pcNewSubStr)
		cResult = This.Copy().ReplaceManySectionsQ(paListOfSections, pcNewSubStr).Content()
		return This

		def SectionsReplaced(paListOfSections, pcNewSubStr)
			return This.ManySectionsReplaced(paListOfSections, pcNewSubStr)

	  #---------------------------------#
	 #    REPLACING A RANGE OF CHARS   # 
	#---------------------------------#

	// Replaces a portion of the string defined by a start position and
	// a range of n chars
	def ReplaceRange(nStart, nNumberOfChars, pcNewSubStr)

		if nStart = :FirstChar or nStart = :StartOfString { nStart = 1 }
		if nNumberOfChars = :EndOfString { nNumberOfChars = This.NumberOfChars() - nStart + 1 }

		This.ReplaceSection(nStart, nStart + nNumberOfChars - 1, pcNewSubStr)

		def ReplaceRangeQ(nStart, nNumberOfChars, pcNewSubStr)
			This.ReplaceRange(nStart, nNumberOfChars, pcNewSubStr)
			return This

	def RangeReplaced(nStart, nNumberOfChars, pcNewSubStr)
		cResult = This.ReplaceRangeQ(nStart, nNumberOfChars, pcNewSubStr).Content()
		return cResult

	  #------------------------------------------------------#
	 #    REPLACING MANY RANGES OF CHARS AT THE SAME TIME   # 
	#------------------------------------------------------#

	def ReplaceManyRanges(paListOfRanges, pcNewSubStr)

		# Tranform ranges to sections and then use ReplaceManySections()

		aSections = []
		for aRange in paListOfRanges
			n1 = aRange[1]
			n2 = aRange[1] + aRange[2] - 1

			aSections + [ n1, n2 ]
		next
		
		This.ReplaceManySections(aSections, pcNewSubStr)

		def ReplaceManyRangesQ(paListOfRanges, pcNewSubStr)
			This.ReplaceManySections(paListOfRanges, pcNewSubStr)

		def ReplaceRanges(paListOfRanges, pcNewSubStr)
			This.ReplaceManyRanges(paListOfRanges, pcNewSubStr)

			def ReplaceRangesQ(paListOfRanges, pcNewSubStr)
				This.ReplaceRanges(paListOfRanges, pcNewSubStr)
				return This

	def ManyRangesReplaced(paListOfRanges, pcNewSubStr)
		cResult = This.Copy().ReplaceManyRangesQ(paListOfRanges, pcNewSubStr).Content()
		return This

		def RangedReplaced(paListOfRanges, pcNewSubStr)
			return This.ManyRangesReplaced(paListOfRanges, pcNewSubStr)

	  #--------------------------------------------------------------#
	 #    REPLACING SECTIONS OF CHARS VERIFYING A GIVEN CONDITION   # 
	#--------------------------------------------------------------#

	def ReplaceSectionsW(paSections, pcNewSubStr, pcCondition)
		/* EXAMPLE

		o1 = new stzString("..AA..aa..BB..bb")
		o1.ReplaceSectionsW(
			[3, 4], [7,8], [11,12], [15,16],
			:With = "_",
			:Wehre = '{ Q(This(@section)).IsLowercase() }'
		)

		#--> "..AA.._..BB.._"
		*/

		if isList(pcCondition) and StzListQ(pcCondition).IsWhereParamList()
			pcCondition = pcCondition[2]

		else
			// TODO: add this check everywhere in the library!
			stzRaise("Incorrect condition format!")
		ok

		pcCondition = StzStringQ(pcCondition).
				SimplifyQ().
				ReplaceBoundsQ("{","}").
				Content()

		cCode = "bOk = ( " + pcCondition + " )"

		aSubStrings = This.Sections(paSections)

		aSectionsToReplace = []
		for i = 1 to len( paSections )
			@n1 = paSections[i][1]
			@n2 = paSections[i][2]

			@range = aSubStrings[i]

			eval(cCode)

			if bOk
				aSectionsToReplace + [ @n1, @n2 ]
			ok
		next

		This.ReplaceManySections(aSectionsToReplace, pcNewSubStr)

		#< @FunctionFluentForm

		def ReplaceSectionsWQ(paSections, pcNewSubStr, pcCondition)
			This.ReplaceSectionsW(paSections, pcNewSubStr, pcCondition)
			return This

		def ReplaceSectionsWhere(paSections, pcNewSubStr, pcCondition)
			This.ReplaceSectionsW(paSections, pcNewSubStr, pcCondition)

			def ReplaceSectionsWhereQ(paSections, pcNewSubStr, pcCondition)
				This.ReplaceSectionsWhere(paSections, pcNewSubStr, pcCondition)
				return This

		def ReplaceManySectionsW(paSections, pcNewSubStr, pcCondition)
			This.ReplaceSectionsW(paSections, pcNewSubStr, pcCondition)
	
			def ReplaceManySectionsWQ(paSections, pcNewSubStr, pcCondition)
				This.ReplaceManySectionsW(paSections, pcNewSubStr, pcCondition)
				return This

		def ReplaceManySectionsWhere(paSections, pcNewSubStr, pcCondition)
			This.ReplaceSectionsW(paSections, pcNewSubStr, pcCondition)

			def ReplaceManySectionsWhereQ(paSections, pcNewSubStr, pcCondition)
				This.ReplaceManySectionsWhere(paSections, pcNewSubStr, pcCondition)
				return This

	def ManySectionsReplacedW(paSections, pcNewSubStr, pcCondition)
		cResult = This.Copy().ReplaceManySectionsWQ(paSections, pcNewSubStr, pcCondition).Content()
		return cResult

		def ManySectionsReplacedWhere(paSections, pcCondition)
			return This.ManySectionsReplacedW(paSections, pcCondition)

	  #-----------------------------------------------------------------#
	 #    REPLACING MANY RANGES OF CHARS VERIFYING A GIVEN CONDITION   # 
	#-----------------------------------------------------------------#

	def ReplaceManyRangesW(paListOfRanges, pcNewSubStr, pcCondition)

		# Tranform ranges to sections and then use ReplaceManySectionsW()

		aSections = []
		for aRange in paListOfRanges
			n1 = aRange[1]
			n2 = aRange[1] + aRange[2] - 1

			aSections + [ n1, n2 ]
		next
		
		This.ReplaceManySectionsW(aSections, pcNewSubStr, pcCondition)

		def ReplaceManyRangesWQ(paListOfRanges, pcNewSubStr, pcCondition)
			This.ReplaceManyRangesW(paListOfRanges, pcNewSubStr, pcCondition)

		def ReplaceRangesW(paListOfRanges, pcNewSubStr, pcCondition)
			This.ReplaceManyRangesW(paListOfRanges, pcNewSubStr, pcCondition)

			def ReplaceRangesWQ(paListOfRanges, pcNewSubStr, pcCondition)
				This.ReplaceRangesW(paListOfRanges, pcNewSubStr, pcCondition)
				return This

	def ManyRangesReplacedW(paListOfRanges, pcNewSubStr, pcCondition)
		cResult = This.Copy().ReplaceManyRangesWQ(paListOfRanges, pcNewSubStr, pcCondition).Content()
		return cResult

		def RangedReplacedW(paListOfRanges, pcNewSubStr, pcCondition)
			return This.ManyRangesReplacedW(paListOfRanges, pcNewSubStr, pcCondition)

	  #----------------------------------------#
	 #    REMOVING NUMBERS FROM THE STRING    # 
	#----------------------------------------#

	def RemoveNumbers()
		cResult = ""
	
		aStzChars = This.ToListOfStzChars()

		for oChar in aStzChars
			if NOT oChar.IsANumber()
				cResult += oChar.Content()
			ok
		next
	
		This.Update( cResult )

	
		def RemoveNumbersQ()
			This.RemoveNumbers()
			return This

	  #----------------------------------------------------#
	 #     REMOVING THE NTH OCCURRENCE OF A SUBSTRING     #
	#----------------------------------------------------#

	def RemoveNthOccurrenceCS(n, pcSubStr, pCaseSensitive)
		This.ReplaceNthOccurrenceCS(n, pcSubStr, "", pCaseSensitive)

		#< @FunctionFluentForm
	
		def RemoveNthOccurrenceCSQ(n, pcSubStr, pCaseSensitive)
			This.RemoveNthOccurrenceCS(n, pcSubStr, pCaseSensitive)
			return This
		
		#>

		def RemoveNthCS(n, pcSubStr, pCaseSensitive)
			This.RemoveNthOccurrenceCS(n, pcSubStr, pCaseSensitive)

			def RemoveNthCSQ(n, pcSubStr, pCaseSensitive)
				This.RemoveNthCS(n, pcSubStr, pCaseSensitive)
				return This

	def RemoveNthOccurrence(n, pcSubStr)
		This.RemoveNthOccurrenceCS(n, pcSubStr, :Casesensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveNthOccurrenceQ(n, pcSubStr)
			This.RemoveNthOccurrence(n, pcSubStr)
			return This
	
		#>

		def RemoveNth(n, pcSubStr)
			This.RemoveNthOccurrence(n, pcSubStr)

			def RemoveNthQ(n, pcSubStr)
				This.RemoveNth(n, pcSubStr)
				return This

	  #------------------------------------------------#
	 #    REMOVING FIRST OCCURRENCE OF A SUBSTRING    #
	#------------------------------------------------#

	def RemoveFirstOccurrenceCS(pcSubStr, pCaseSensitive)
		This.ReplaceNthOccurrenceCS(1, pcSubStr, "", pCaseSensitive)
	
		#< @FunctionFluentForm
	
		def RemoveFirstOccurrenceCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFirstOccurrenceCS(pcSubStr, pCaseSensitive)
			return This
		
		#>

		def RemoveFirstCS(pcSubStr, pCaseSensitive)
			This.RemoveFirstOccurrenceCS(pcSubStr, pCaseSensitive)

			def RemoveFirstCSQ(pcSubStr, pCaseSensitive)
				This.RemoveFirstCS(pcSubStr, pCaseSensitive)
				return This

	def RemoveFirstOccurrence(pcSubStr)
		This.RemoveFirstOccurrenceCS(pcSubStr, :Casesensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveFirstOccurrenceQ(pcSubStr, pcNewSubStr)
			This.RemoveFirstOccurrence(pcSubStr)
			return This
	
		#>

		def RemoveFirst(pcSubStr)
			This.RemoveFirstOccurrence(pcSubStr)

			def RemoveFirstQ(pcSubStr)
				This.RemoveFirst(pcSubStr)
				return This

	  #--------------------------------------------------#
	 #     REMOVING LAST OCCURRENCE OF A SUBSTRING      #
	#--------------------------------------------------#

	def RemoveLastOccurrenceCS(pcSubStr, pCaseSensitive)
		This.ReplaceNthOccurrenceCS(:Last, pcSubStr, "", pCaseSensitive)
	
		#< @FunctionFluentForm
	
		def RemoveLastOccurrenceCSQ(pcSubStr, pCaseSensitive)
			This.RemoveLastOccurrenceCS(pcSubStr, pCaseSensitive)
			return This
		
		#>

		def RemoveLastCS(pcSubStr, pCaseSensitive)
			This.RemoveLastOccurrenceCS(pcSubStr, pCaseSensitive)

			def RemoveLastCSQ(pcSubStr, pCaseSensitive)
				This.RemoveLastCS(pcSubStr, pCaseSensitive)
				return This

	def RemoveLastOccurrence(pcSubStr)
		This.RemoveLastOccurrenceCS(pcSubStr, :Casesensitive = TRUE)

		#< @FunctionFluentForm

		def RemoveLastOccurrenceQ(pcSubStr)
			This.RemoveLastOccurrence(pcSubStr)
			return This
	
		#>

		def RemoveLast(pcSubStr)
			This.RemoveLastOccurrence(pcSubStr)

			def RemoveLastQ(pcSubStr)
				This.RemoveLast(pcSubStr)
				return This

	   #----------------------------------------------------#
	  #    REMOVING NEXT NTH OCCURRENCE OF A SUBSTRING    # 
	 #    STARTING AT A GIVEN POSITION                    #
	#----------------------------------------------------#

	def RemoveNextNthOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
		
		if isList(nStart) and StzListQ(nStart).IsStartingAtParamList()
			nStart = nStart[2]
		ok

		if isList(pcSubStr) and StzListQ(pcSubStr).IsOfParamList()
			pcSubStr = pcSubStr[2]
		ok

		if isList(pcNewSubStr) and StzListQ(pcNewSubStr).IsWithParamList()
			pcNewSubStr = pcNewSubStr[2]
		ok

		cPart1 = This.Section(1, nStart - 1)

		oPart2 = This.SectionQ(nStart, :LastChar)
		cPart2 = oPart2.RemoveNthOccurrenceCSQ(n, pcSubStr, pCaseSensitive).Content()

		cResult = cPart1 + cPart2
		This.Update( cResult )

		def RemoveNextNthOccurrenceCSQ(n, pcSubStr, nStart, pCaseSensitive)
			This.RemoveNextNthOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			return This

		def RemoveNthNextOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			This.RemoveNextNthOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

			def RemoveNthNextOccurrenceCSQ(n, pcSubStr, nStart, pCaseSensitive)
				This.RemoveNthNextOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
				return This

	def RemoveNextNthOccurrence(n, pcSubStr, nStart, pcNewSubStr)
		This.RemoveNextNthOccurrenceCS(n, pcSubStr, nStart, :CaseSensitive = TRUE)

		def RemoveNextNthOccurrenceQ(n, pcSubStr, nStart, pcNewSubStr)
			This.RemoveNextNthOccurrence(n, pcSubStr, nStart, pcNewSubStr)
			return This

		def RemoveNthNextOccurrence(n, pcSubStr, nStart, pcNewSubStr)
			This.RemoveNextNthOccurrence(n, pcSubStr, nStart, pcNewSubStr)

			def RemoveNthNextOccurrenceQ(n, pcSubStr, nStart, pcNewSubStr)
				return This.RemoveNthNextOccurrence(n, pcSubStr, nStart, pcNewSubStr)

	   #------------------------------------------------#
	  #    REMOVING NEXT OCCURRENCE OF A SUBSTRING    # 
	 #    STARTING AT A GIVEN POSITION                #
	#------------------------------------------------#

	def RemoveNextOccurrenceCS(pcSubStr, nStart, pCaseSensitive)
		This.RemoveNextNthOccurrenceCS(1, pcSubStr, nStart, pCaseSensitive)

		def RemoveNextOccurrenceCSQ(pcSubStr, nStart, pCaseSensitive)
			This.RemoveNextOccurrenceCS(pcSubStr, nStart, pCaseSensitive)
			return This

	def RemoveNextOccurrence(pcSubStr, nStart, pcNewSubStr)
		This.RemoveNextNthOccurrenceCS(1, pcSubStr, nStart, :CaseSensitive = TRUE)

		def RemoveNextOccurrenceQ(pcSubStr, nStart, pcNewSubStr)
			This.RemoveNextOccurrence(pcSubStr, nStart, pcNewSubStr)
			return This

	   #--------------------------------------------------------#
	  #    REMOVING PREVIOUS NTH OCCURRENCE OF A SUBSTRING    # 
	 #    STARTING AT A GIVEN POSITION                        #
	#--------------------------------------------------------#

	def RemovePreviousNthOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
		
		if isList(nStart) and Q(nStart).IsStartingAtParamList()
			nStart = nStart[2]
		ok

		if isList(pcSubStr) and Q(pcSubStr).IsOfParamList()
			pcSubStr = pcSubStr[2]
		ok

		if isList(pcNewSubStr) and Q(pcNewSubStr).IsWithParamList()
			pcNewSubStr = pcNewSubStr[2]
		ok

		oPart1 = This.SectionQ(1, nStart - 1)
		n = oPart1.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive) - n + 1
		cPart1 = oPart1.RemoveNthOccurrenceCSQ(n, pcSubStr, pCaseSensitive).Content()

		cPart2 = This.Section(nStart, :LastChar)

		cResult = cPart1 + cPart2
		This.Update( cResult )

		def RemovePreviousNthOccurrenceCSQ(n, pcSubStr, nStart, pCaseSensitive)
			This.RemovePreviousNthOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			return This

		def RemoveNthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
			This.RemovePreviousNthOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)

			def RemoveNthPreviousOccurrenceCSQ(n, pcSubStr, nStart, pCaseSensitive)
				This.RemoveNthPreviousOccurrenceCS(n, pcSubStr, nStart, pCaseSensitive)
				return This

	def RemovePreviousNthOccurrence(n, pcSubStr, nStart, pcNewSubStr)
		This.RemovePreviousNthOccurrenceCS(n, pcSubStr, nStart, :CaseSensitive = TRUE)

		def RemovePreviousNthOccurrenceQ(n, pcSubStr, nStart, pcNewSubStr)
			This.RemovePreviousNthOccurrence(n, pcSubStr, nStart, pcNewSubStr)
			return This

		def RemoveNthPreviousOccurrence(n, pcSubStr, nStart, pcNewSubStr)
			This.RemovePreviousNthOccurrence(n, pcSubStr, nStart, pcNewSubStr)

			def RemoveNthPreviousOccurrenceQ(n, pcSubStr, nStart, pcNewSubStr)
				This.RemoveNthPreviousOccurrence(n, pcSubStr, nStart, pcNewSubStr)
				return This

	   #----------------------------------------------------#
	  #    REMOVING PREVIOUS OCCURRENCE OF A SUBSTRING     # 
	 #    STARTING AT A GIVEN POSITION                    #
	#----------------------------------------------------#

	def RemovePreviousOccurrenceCS(pcSubStr, nStart, pCaseSensitive)
		This.RemovePreviousNthOccurrenceCS(1, pcSubStr, nStart, pCaseSensitive)

		def RemovePreviousOccurrenceCSQ(pcSubStr, nStart, pCaseSensitive)
			This.RemovePreviousOccurrenceCS(pcSubStr, nStart, pCaseSensitive)
			return This

	def RemovePreviousOccurrence(pcSubStr, nStart, pcNewSubStr)
		This.RemovePreviousNthOccurrenceCS(1, pcSubStr, nStart, :CaseSensitive = TRUE)

		def RemovePreviousOccurrenceQ(pcSubStr, nStart, pcNewSubStr)
			This.RemovePreviousOccurrence(pcSubStr, nStart, pcNewSubStr)
			return This

	  #-----------------------------------------------#
	 #    REMOVING LEFT OCCURRENCE OF A SUBSTRING    # 
	#-----------------------------------------------#

	def RemoveLeftOccurrenceCS(pcSubStr, pCaseSensitive)
		if This.IsLeftToRight()
			This.RemoveNthOccurrenceCS(1, pcSubStr, pCaseSensitive)

		else # This.IsRightToLeft()
			n = This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
			This.RemoveNthOccurrenceCS( n, pcSubStr, pCaseSensitive)
		ok

		def RemoveLeftOccurrenceCSQ(pcSubStr, pCaseSensitive)
			This.RemoveLeftOccurrenceCS(pcSubStr, pCaseSensitive)
			return This

	#-- CASE-INSENSITIVE

	def RemoveLeftOccurrence(pcSubStr)
		This.RemoveLeftOccurrenceCS(pcSubStr, :CaseSensitive = FALSE)

		def RemoveLeftOccurrenceQ(pcSubStr)
			This.RemoveLeftOccurrence(pcSubStr)
			return This

	  #---------------------------------------------#
	 #    REMOVING RIGHT OCCURRENCE OF SUBSTRING   # 
	#---------------------------------------------#

	def RemoveRightOccurrenceCS(pcSubStr, pCaseSensitive)
		if This.IsRightToLeft()
			This.RemoveNthOccurrenceCS(1, pcSubStr, pCaseSensitive)

		else # This.IsLeftToRight()

			n = This.NumberOfOccurrenceCS(pcSubStr, pCaseSensitive)
			This.RemoveNthOccurrenceCS( n, pcSubStr, pCaseSensitive)
		ok

		def RemoveRightOccurrenceCSQ(pcSubStr, pCaseSensitive)
			This.RemoveRightOccurrenceCS(pcSubStr, pCaseSensitive)
			return This

	def RemoveRightOccurrence(pcSubStr)
		This.RemoveRightOccurrenceCS(pcSubStr, :CaseSensitive = TRUE)

		def RemoveRightOccurrenceQ(pcSubStr)
			This.RemoveRightOccurrence(pcSubStr)
			return This

	  #-------------------------------------#
	 #   REMOVING A SUBSTRING FROM LEFT    #
	#-------------------------------------#

	def RemoveFromLeftCS(pcSubStr, pCaseSensitive)
		if This.BeginsWithCS(pcSubStr, pCaseSensitive)
			n1 = 1
			n2 = StzStringQ(pcSubStr).NumberOfChars()
			This.RemoveSection(n1, n2)
		ok

		def RemoveFromLeftCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromLeftCS(pcSubStr, pCaseSensitive)
			return This

		def RemovSubStringFromLeftCS(pcSubStr, pCaseSensitive)
			This.RemoveFromLeftCS(pcSubStr, pCaseSensitive)

			def RemovSubStringFromLeftCSQ(pcSubStr, pCaseSensitive)
				This.RemovSubStringFromLeftCS(pcSubStr, pCaseSensitive)
				return This

	def RemovedFromLeftCS(pcSubStr, pCaseSensitive)
		cResult = This.Copy().RemoveFromLeftCSQ(pcSubStr, pCaseSensitive)
		return cResult

		def SubStringRemovedFromLeftCS(pcSubStr, pCaseSensitive)
			return This.RemovedFromLeftCS(pcSubStr, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def RemoveFromLeft(pcSubStr)
		This.RemoveFromLeftCS(pcSubStr, :CaseSensitive = TRUE)

		def RemoveFromLeftQ(pcSubStr)
			This.RemoveFromLeft(pcSubStr)
			return This

		def RemovSubStringFromLeft(pcSubStr)
			This.RemoveFromLeft(pcSubStr)

			def RemovSubStringFromLeftQ(pcSubStr)
				This.RemovSubStringFromLeft(pcSubStr)
				return This

	def RemovedFromLeft(pcSubStr)
		cResult = This.Copy().RemoveFromLeftQ(pcSubStr)
		return cResult

		def SubStringRemovedFromLeft(pcSubStr)
			return This.RemovedFromLeft(pcSubStr)

	  #-------------------------------------#
	 #   REMOVING A SUBSTRING FROM RIGHT   #
	#-------------------------------------#

	def RemoveFromRightCS(pcSubStr, pCaseSensitive)
		if This.BeginsWithCS(pcSubStr, pCaseSensitive)
			nLen = StzStringQ(pcSubStr).NumberOfChars()
			n1 = This.NumberOfChars() - nLen + 1
			n2 = This.NumberOfChars()
			This.RemoveSection(n1, n2)
		ok

		def RemoveFromRightCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromRightCS(pcSubStr, pCaseSensitive)
			return This

		def RemoveRightCS(pcSubStr, pCaseSensitive)
			This.RemoveFromRightCS(pcSubStr, pCaseSensitive)

			def RemoveRightCSQ(pcSubStr, pCaseSensitive)
				This.RemoveRightCS(pcSubStr, pCaseSensitive)
				return This

		def RemovSubStringFromRightCS(pcSubStr, pCaseSensitive)
			This.RemoveFromRightCS(pcSubStr, pCaseSensitive)

			def RemovSubStringFromRightCSQ(pcSubStr, pCaseSensitive)
				This.RemovSubStringFromRightCS(pcSubStr, pCaseSensitive)
				return This

	def RemovedFromRightCS(pcSubStr, pCaseSensitive)
		cResult = This.Copy().RemoveFromRightCSQ(pcSubStr, pCaseSensitive)
		return cResult

		def SubStringRemovedFromRightCS(pcSubStr, pCaseSensitive)
			return This.RemovedFromRightCS(pcSubStr, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def RemoveFromRight(pcSubStr)
		This.RemoveFromRightCS(pcSubStr, :CaseSensitive = TRUE)

		def RemoveFromRightQ(pcSubStr)
			This.RemoveFromRight(pcSubStr)
			return This

		def RemoveRight(pcSubStr)
			This.RemoveFromRight(pcSubStr)

			def RemoveRightQ(pcSubStr)
				This.RemoveRight(pcSubStr)
				return This

		def RemovSubStringFromRight(pcSubStr)
			This.RemoveFromRight(pcSubStr)

			def RemovSubStringFromRightQ(pcSubStr)
				This.RemovSubStringFromRight(pcSubStr)
				return This

	def RemovedFromRight(pcSubStr)
		cResult = This.Copy().RemoveFromRightQ(pcSubStr)
		return cResult

		def SubStringRemovedFromRight(pcSubStr)
			return This.RemovedFromRight(pcSubStr)	

	  #-------------------------------------#
	 #   REMOVING A SUBSTRING FROM START   #
	#-------------------------------------#

	def RemoveFromStartCS(pcSubStr, pCaseSensitive)
		if This.IsLeftToRight()
			This.RemoveFromLeftCS(pcSubStr, pCaseSensitive)
		else
			This.RemoveFromRightCS(pcSubStr, pCaseSensitive)
		ok

		def RemoveFromStartCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromStartCS(pcSubStr, pCaseSensitive)
			return This

		def RemovSubStringFromStartCS(pcSubStr, pCaseSensitive)
			This.RemoveFromStartCS(pcSubStr, pCaseSensitive)

			def RemovSubStringFromStartCSQ(pcSubStr, pCaseSensitive)
				This.RemovSubStringFromStartCS(pcSubStr, pCaseSensitive)
				return This

	def RemovedFromStartCS(pcSubStr, pCaseSensitive)
		cResult = This.Copy().RemoveFromStartCSQ(pcSubStr, pCaseSensitive)
		return cResult

		def SubStringRemovedFromStartCS(pcSubStr, pCaseSensitive)
			return This.RemovedFromStartCS(pcSubStr, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def RemoveFromStart(pcSubStr)
		This.RemoveFromStartCS(pcSubStr, :CaseSensitive = TRUE)

		def RemoveFromStartQ(pcSubStr)
			This.RemoveFromStart(pcSubStr)
			return This

		def RemovSubStringFromStart(pcSubStr)
			This.RemoveFromStart(pcSubStr)

			def RemovSubStringFromStartQ(pcSubStr)
				This.RemovSubStringFromStart(pcSubStr)
				return This

	def RemovedFromStart(pcSubStr)
		cResult = This.Copy().RemoveFromStartQ(pcSubStr)
		return cResult

		def SubStringRemovedFromStart(pcSubStr)
			return This.RemovedFromStart(pcSubStr)

	  #-----------------------------------#
	 #   REMOVING A SUBSTRING FROM END   #
	#-----------------------------------#

	def RemoveFromEndCS(pcSubStr, pCaseSensitive)
		if This.IsLeftToRight()
			This.RemoveFromRightCS(pcSubStr, pCaseSensitive)
		else
			This.RemoveFromLeftCS(pcSubStr, pCaseSensitive)
		ok

		def RemoveFromEndCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromEndCS(pcSubStr, pCaseSensitive)
			return This

		def RemovSubStringFromEndCS(pcSubStr, pCaseSensitive)
			This.RemoveFromEndCS(pcSubStr, pCaseSensitive)

			def RemovSubStringFromEndCSQ(pcSubStr, pCaseSensitive)
				This.RemovSubStringFromEndCS(pcSubStr, pCaseSensitive)
				return This

	def RemovedFromEndCS(pcSubStr, pCaseSensitive)
		cResult = This.Copy().RemoveFromEndCSQ(pcSubStr, pCaseSensitive)
		return cResult

		def SubStringRemovedFromEndCS(pcSubStr, pCaseSensitive)
			return This.RemovedFromEndCS(pcSubStr, pCaseSensitive)

	#-- CASE-INSENSITIVE

	def RemoveFromEnd(pcSubStr)
		This.RemoveFromEndCS(pcSubStr, :CaseSensitive = TRUE)

		def RemoveFromEndQ(pcSubStr)
			This.RemoveFromEnd(pcSubStr)
			return This

		def RemovSubStringFromEnd(pcSubStr)
			This.RemoveFromEnd(pcSubStr)

			def RemovSubStringFromEndQ(pcSubStr)
				This.RemovSubStringFromEnd(pcSubStr)
				return This

	def RemovedFromEnd(pcSubStr)
		cResult = This.Copy().RemoveFromEndQ(pcSubStr)
		return cResult

		def SubStringRemovedFromEnd(pcSubStr)
			return This.RemovedFromEnd(pcSubStr)

	  #--------------------------------------------------------#
	 #    REMOVING CHARS FROM LEFT UNDER A GIVEN CONDITION    # 
	#--------------------------------------------------------#

	def RemoveCharsFromLeftW(pcCondition)
		if isList(pcCondition) and StzListQ(pcCondition).IsWhereParamList()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			stzRaise("Incorrect param type! Condition should be in a string.")
		ok

		pcCondition = StzStringQ(pcCondition).
				SimplifyQ().
				RemoveBoundsQ("{","}").
				Content()

		cCode = "bOk = ( " + pcCondition + " )"

		cSubStrToRemove = ""

		for @i = 1 to This.NumberOfChars()
			@char = This[i]
			eval(cCode)
			if bOk
				cSubStrToRemove += @charName
			ok
		next

		This.RemoveSubStringFromLeft(cSubStrToRemove)

		def RemoveCharsFromLeftWWQ(pcCondition)
			This.RemoveCharsFromLeftW(pcCondition)
			return This

		def RemoveFromLeftW(pcCondition)
			This.RemoveCharsFromLeftW(pcCondition)

			def RemoveFromLeftWQ(pcCondition)
				This.RemoveFromLeftW(pcCondition)
				return This

		def RemoveLeftW(pcCondition)
			This.RemoveFromLeftW(pcCondition)

			def RemoveLeftWQ(pcCondition)
				This.RemoveLeftW(pcCondition)
				return This

	def CharsRemovedFromLeft(pcCondition)
		cResult = This.Copy().RemoveCharsFromLeftWQ(pcCondition).Content()
		return cResult

	  #---------------------------------------------------------#
	 #    REMOVING CHARS FROM RIGHT UNDER A GIVEN CONDITION    # 
	#---------------------------------------------------------#

	def RemoveCharsFromRightW(pcCondition)
		if isList(pcCondition) and StzListQ(pcCondition).IsWhereParamList()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			stzRaise("Incorrect param type! Condition should be in a string.")
		ok

		pcCondition = StzStringQ(pcCondition).
				SimplifyQ().
				RemoveBoundsQ("{","}").
				Content()

		cCode = "bOk = ( " + pcCondition + " )"

		cSubStrToRemove = ""

		for @i = 1 to This.NumberOfChars()
			@char = This[i]
			eval(cCode)
			if bOk
				cSubStrToRemove += @charName
			ok
		next

		This.RemoveSubStringFromRight(cSubStrToRemove)

		def RemoveCharsFromRightWWQ(pcCondition)
			This.RemoveCharsFromRightW(pcCondition)
			return This

		def RemoveFromRightW(pcCondition)
			This.RemoveCharsFromRightW(pcCondition)

			def RemoveFromRightWQ(pcCondition)
				This.RemoveFromRightW(pcCondition)
				return This

		def RemoveRightW(pcCondition)
			This.RemoveFromRightW(pcCondition)

			def RemoveRightWQ(pcCondition)
				This.RemoveRightW(pcCondition)
				return This

	def CharsRemovedFromRight(pcCondition)
		cResult = This.Copy().RemoveCharsFromRightWQ(pcCondition).Content()
		return cResult

	  #---------------------------------------------------------#
	 #    REMOVING CHARS FROM START UNDER A GIVEN CONDITION    # 
	#---------------------------------------------------------#

	def RemoveCharsFromStartW(pcCondition)
		if This.IsLeftToRight()
			This.RemoveCharsFromLeftW(pcCondition)

		else
			This.RemoveCharsFromRightW(pcCondition)
		ok


		def RemoveCharsFromStartWWQ(pcCondition)
			This.RemoveCharsFromStartW(pcCondition)
			return This

		def RemoveFromStartW(pcCondition)
			This.RemoveCharsFromStartW(pcCondition)

			def RemoveFromStartWQ(pcCondition)
				This.RemoveFromStartW(pcCondition)
				return This

		def RemoveStartW(pcCondition)
			This.RemoveFromStartW(pcCondition)

			def RemoveStartWQ(pcCondition)
				This.RemoveStartW(pcCondition)
				return This

	def CharsRemovedFromStart(pcCondition)
		cResult = This.Copy().RemoveCharsFromStartWQ(pcCondition).Content()
		return cResult

	  #---------------------------------------------------------#
	 #    REMOVING CHARS FROM END UNDER A GIVEN CONDITION    # 
	#---------------------------------------------------------#

	def RemoveCharsFromEndW(pcCondition)
		if This.IsLeftToRight()
			This.RemoveCharsFromRighttW(pcCondition)

		else
			This.RemoveCharsFromLeftW(pcCondition)
		ok

		def RemoveCharsFromEndWWQ(pcCondition)
			This.RemoveCharsFromEndW(pcCondition)
			return This

		def RemoveFromEndW(pcCondition)
			This.RemoveCharsFromEndW(pcCondition)

			def RemoveFromEndWQ(pcCondition)
				This.RemoveFromEndW(pcCondition)
				return This

		def RemoveEndW(pcCondition)
			This.RemoveFromEndW(pcCondition)

			def RemoveEndWQ(pcCondition)
				This.RemoveEndW(pcCondition)
				return This

	def CharsRemovedFromEnd(pcCondition)
		cResult = This.Copy().RemoveCharsFromEndWQ(pcCondition).Content()
		return cResult

	  #-------------------------------------------------------------------------#
	 #    TRIMMING & REMOVING SPACES, SIMPLIFYING AND SPACIFYING THE STRING    # 
	#-------------------------------------------------------------------------#

	def Trim()
		This.Update( This.QStringObject().trimmed() )

		def TrimQ()
			This.Trim()
			return This

	def Trimmed()
		cResult = This.Copy().TrimQ().Content()
		return cResult

		def WithoutLeadingAndTrailingSpaces()
			return This.Trimmed()

	def TrimStart()
		if This.HasRepeatedLeadingChars()	
			This.RemoveThisRepeatedLeadingChar(" ")
		ok

		if This.FirstChar() = " "
			This.RemoveFirst(" ")
		ok

		def TrimStartQ()
			This.TrimStart()
			return This

		def RemoveLeadingSpaces()
			This.TrimStart()

			def RemoveLeadingSpacesQ()
				This.RemoveLeadingSpaces()
				return This

	def TrimmedFromStart()
		cResult = This.Copy().TrimStartQ().Content()
		return cResult

		def LeadingSpacesRemoved()
			return This.TrimmedFromStart()

		def WithoutLeadingSpaces()
			return This.TrimmedFromStart()

	def TrimEnd()

		This.RemoveThisRepeatedTrailingChar(" ")

		if This.LastChar() = " "
			This.RemoveLast(" ")
		ok

		def TrimEndQ()
			This.TrimEnd()
			return This

		def RemoveTrailingSpaces()
			This.TrimEnd()

			def RemoveTrailingSpacesQ()
				This.RemoveTrailingSpaces()
				return This
	
	def TrimmedFromEnd()
		cResult = This.Copy().TrimEndQ().Content()
		return cResult

		def TrailingSpacesRemoved()
			return This.TrimmedFromEnd()

		def WithoutTrailingSpaces()
			return This.TrimmedFromEnd()

	def TrimLeft()
		if This.IsLeftToRight()
			This.TrimStart()

		else # IsRightToLeft
			This.TrimEnd()
		ok

		def TrimLeftQ()
			This.TrimLeft()
			return This

		def RemoveLeftSpaces()
			This.TrimeLeft()

			def RemoveLeftSpacesQ()
				This.RemoveLeftSpaces()
				return This

	def TrimmedFromLeft()
		cResult = This.Copy().TrimLeftQ().Content()
		return cResult

		def LeftSpacesRemoved()
			return This.TrimmedFromLeft()

		def WithoutLeftSpaces()
			return This.TrimmedFromLeft()

	def TrimRight()
		if This.IsRightToLeft()
			This.TrimStart()

		else # IsLeftToRight
			This.TrimEnd()
		ok

		def TrimRightQ()
			This.TrimRight()
			return This

		def RemoveRightSpaces()
			This.TrimRight()

			def RemoveRightSpacesQ()
				This.RemoveRightSpaces()
				return This

	def TrimmedFromRight()
		cResult = This.Copy().TrimRightQ().Content()
		return cResult

		def RightSpacesRemoved()
			return This.TrimmedFromRight()

		def WithoutRightSpaces()
			return This.TrimmedFromRight()

	def RemoveSpaces()
		This.RemoveAll(" ")

		def RemoveSpacesQ()
			This.RemoveSpaces()
			return This

	def SpacesRemoved()
		cResult = This.Copy().RemoveSpacesQ().Content()
		return cResult

		def WithoutSpaces()
			return This.SpacesRemoved()

	// Simplifies this string by removing duplicated spaces

	def Simplify()

		# t0 = clock() // Veryf fast, takes almost 0.01s

		This.Update( @oQString.simplified() )

		# ? ( clock() - t0 ) / clockspersecond()

		def SimplifyQ()
			This.Simplify()
			return This

	def Simplified()
		cResult = This.Copy().SimplifyQ().Content()
		return cResult


	def Spacify()
		/* EXAMPLE

		? StzStringQ("RINGORIALAND").Spacified()
		#--> R I N G O R I A L A N D

		*/

		This.SpacifyN(1)

		def SpacifyQ()
			This.Spacify()
			return This

	def Spacified()
		cResult = This.Copy().SpacifyQ().Content()
		return cResult

	def SpacifyN(n)
		This.RemoveSpaces()

		cInterSpaces = ( Q(" ") * n ).Content()
		This.InsertAfterW('@i = Previous@i + 1', cInterSpaces)
		

		def SpacifyNQ(n)
			This.SpacifyN(n)
			return This

	def SpacifiedN(n)
		return This.Copy().SpacifyQ(n).Content()

	  #------------------------------------------------#
	 #    GETTING POSITION AFTER A GIVEN SUBSTRING    #
	#------------------------------------------------#

	def PositionAfterCS(cSubStr, pCaseSensitive)
		return This.PositionAfterNthOccurrenceCS(1, cSubStr, pCaseSensitive)

	def PositionAfterNthOccurrenceCS(n, cSubStr, pCaseSensitive)
		n = This.FindNthOccurrenceCS(n, cSubStr, pCaseSensitive)
		oStr = new stzString(cSubStr)
		return n + oStr.NumberOfChars()

	def PositionAfter(cSubStr)
		return This.PositionAfterCS(cSubStr, :CaseSensitive = TRUE)

	def PositionAfterNthOccurrence(n, cSubStr)
		return This.PositionAfterNthOccurrenceCS(n, cSubStr, :CaseSensitive = TRUE)

	  #---------------------------------------------------#
	 #    GETTING POSITION BEFORE  A GIVEN SUBSTRING     #
	#---------------------------------------------------#

	def PositionBeforeCS(cSubStr, pCaseSensitive)
		return This.PositionBeforeNthOccurrenceCS(1, cSubStr, pCaseSensitive)

	def PositionBeforeNthOccurrenceCS(n, cSubStr, pCaseSensitive)
		return This.FindNthOccurrenceCS(cSubStr, pCaseSensitive)
	
	def PositionBefore(cSubStr)
		return This.PositionBeforeCS(cSubStr, :CaseSensitve = FALSE)

	def PositionBeforeNthOccurrence(n, cSubStr)
		return This.PositionBeforeNthOccurrenceCS(n, cSubStr, pCaseSensitive)

	  #--------------------#
	 #    CENTRAL CHAR    #
	#--------------------#
	
	// Returns the position (if any) of the central Char in the string
	def CentralCharPosition()

		oNumberOfChars = new stzNumber(This.NumberOfChars())
		if oNumberOfChars.IsOdd()
			return ( This.NumberOfChars() + 1 ) / 2
		ok

	def CentralChar()
		if This.CentralCharPosition() != NULL
			return This.NthChar( This.CentralCharPosition() )
		ok

		def CentralCharQ()
			return This.CentralCharQR(:stzChar)
	
		def CentralCharQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzChar
				return new stzChar( This.CentralChar() )
			on :stzString
				return new stzString( This.CentralChar() )
			on :stzListOfBytes
				return new stzListOfBytes( This.CentralChar() )
			off

	def ContainsCentralChar()
		return This.NumberOfCharsQ().IsNotEven()

		def HasCentralChar()
			return This.ContainsCentralChar()

	def ContainsThisCharInTheCenter(c)
		return This.CentralChar() = c

		def HasThisCharInTheCenter(c)
			return This.ContainsThisCharInTheCenter(c)

	  #------------------------#
	 #    MIDDLE SUBSTRING    #
	#------------------------#

	def ContainsMiddleSubstring()
		if This.MiddleSubstring() = NULL
			return FALSE

		else
			return TRUE
		ok

		def HasMiddleSubstring()
			return This.ContainsMiddleSubstring()

	def HasThisSubstringInTheMiddle(pcSubStr)
		if IsStzString(pcSubStr)
			pcSubStr = pcSubStr.Content()
		ok

		if This.MiddleSubstring() = pcSubStr
			return TRUE
		else
			return FALSE
		ok

		def ContainsThisSubstringInTheMiddle(c)
			return This.HasThisSubstringInTheMiddle(c)

	def MiddleSubstringPosition()
		// TODO
		
	def MiddleSubstring()
		return This[ This.MiddleSubstringPosition() ]

	  #--------------------------------#
	 #   GETTING STRING ORIENTATION   #
	#--------------------------------#

	/*
	Note that we distinguish between string 'orientation', 
	char 'orientation', and char 'unicode direction'.

	The first says if a string is left-to-right or right-to-left oriented, and
	uses the Orientation() method, here, in stzString.

	The second says the same thing for the individual chars, and uses
	the Orientation() method on stzChar.

	While the third informs us about the technical direction of the char,
	in terms of UNICODE standard, and is returned using UnicodeDirection()
	method on stzChar.
	*/

	// Returns the orientation of the string (:RightToLeft OR :LeftToRight)
	def Orientation()
		if This.IsRightToLeft()
			return :RightToLeft
		else
			return :LeftToRight
		ok

	// Verifies if the string is right-to-left (like arabic) : SEE Orientation()
	def IsRightToleft()
		bResult = @oQString.isRightToleft()

		return bResult

	// Verifies if the string is left-to-right (like english)
	def IsLeftToRight()
		IF NOT This.IsRightToLeft()
			return TRUE
		else
			return FALSE

		ok

	// Checks if the text is hybrid (containing :RightToLeft AND :LeftToRight" texts)
	def ContainsHybridOrientation()
		aStzChars = This.ToListOfStzChars()

		bIsHybrid = FALSE
		cFlag = aStzChars[1].Orientation()

		for i=2 to len(aStzChars)
			if aStzChars[i].Orientation() != cFlag
				bIsHybrid = TRUE
				exit
			ok
		next

		return bIsHybrid

	// Transforms the string to a list of chars with indication of their orientation
	def CharsWithOrientation()
		aResult = []

		for i = 1 to This.NumberOfChars()
			oTempChar = new stzChar(This[i])
			aResult + [ This[i] , oTempChar.Orientation() ]
		next

		return aResult

	def CharsWithOrientationQ()
		return new stzList( This.CharsWithOrientation() )

	// Transforms the string to a list of letters with indication of their orientation
	def LettersWithOrientation()
		aResult = []

		for i = 1 to This.NumberOfChars()
			oTempChar = new stzChar(This[i])
			if oTempChar.isLetter()
				aResult + [ This[i] , oTempChar.Orientation() ]
			ok
		next

		return aResult

	def LettersWithOrientationQ()
		return new stzList( This.LettersWithOrientation() )

	  #----------------------#
	 #     ONLY NUMBERS     #
	#----------------------#
		
	/* Returns (as a string) only the numbers contained in the string

	   Note: if the string contains "㊱", for example, then it is returned
	   as the number 36 contained in a string ("36")!

	   To return just numbers formed from decimal digits from 0 to 9,
	   use OnlyDecimalDigits()
	*/

	def OnlyNumbers()
		cResult = ""

		for i = 1 to This.NumberOfChars()
			c = This.NthChar(i)

			oChar = new stzChar(c)
			if oChar.IsANumber()
				cResult += c
			ok
		next
		return cResult

		def OnlyNumbersQ()
			return new stzString( This.OnlyNumbers() )

	def OnlyDecimalDigits()
		cResult = NULL

		for i = 1 to This.NumberOfChars()
			c = This.NthChar(i)

			oChar = new stzChar(c)
			if oChar.IsDecimalDigit()
				cResult += c
			ok
		next
		return cResult

	def OnlyDecimalDigitsQ()
		return new stzList( This.OnlyDecimalDigits() )

	  #------------------------------------------#
	 #     ONLY LETTERS AND SPACES ANS CHARS    #
	#------------------------------------------#

	// Returns (as a string) only the letters contained in the string
	def OnlyLetters()
		cResult = NULL

		for i = 1 to This.NumberOfChars()
			c = This.NthChar(i)

			oChar = new stzChar(c)
			if oChar.isLetter()
				cResult += c
			ok
		next
		return cResult

	def OnlyLettersQ()
		return new stzList(This.OnlyLetters())

	#----

	def OnlyLettersAndSpaces()
		cResult = ""

		for i = 1 to This.NumberOfChars()
			c = This.NthChar(i)

			if StzCharQ( c ).IsLetterOrSpace()

				cResult += c
			ok
		next

		return cResult

	def OnlyLettersAndSpacesQ()
		return new stzString( This.OnlyLettersAndSpaces() )

	#----

	def OnlyLettersAndSpacesAndChar(pcChar)

		# t0 = clock() # Takes almost 0.62s

		cResult = ""

		for i = 1 to This.NumberOfChars()
			c = This.NthChar(i)
			oChar = new stzChar( c )

			if oChar.IsLetterOrSpaceOrChar(pcChar)
				cResult += c
			ok
		next

		# ? ( clock() - t0 ) / clockspersecond()

		return cResult

		def OnlyLettersAndSpacesAndThisChar(pcChar)
			return This.OnlyLettersAndSpacesAndChar(pcChar)

	def OnlyLettersAndSpacesAndCharQ(pcChar)
		return new stzString( This.OnlyLettersAndSpacesAndChar(pcChar) )

		def OnlyLettersAndSpacesAndThisCharQ(pcChar)
			return OnlyLettersAndSpacesAndCharQ(pcChar)

	#----

	def OnlyLettersAndSpacesAndChars(pacChars)
		return This.ItemsWhere('isLetter(@item) or isSpace(@item) or Q(@item).IsOneOfThese(pacChars)')

		def OnlyLettersAndSpacesAndCharsQ(paChars)
			return This.OnlyLettersAndSpacesAndChars(pacChars)

		def OnlyLettersAndSpacesAndTheseChars(pacChars)
			return This.OnlyLettersAndSpacesAndChars(pacChars)

	def IsLetterOrSpaceOrChar(pcChar)
		return This.IsLetterOrSpaceOrOneOfTheseChars([ pcChar ])

		def IsLetterOrSpaceOrThisChar(pcChar)
			return IsLetterOrSpaceOrChar(pcChar)

	def IsLetterOrSpaceOrChars(pacChar)
		bResult = FALSE

		if This.IsLetter() or This.IsSpace() or
		   This.IsOneOfThese(pacChars)

			return TRUE
		else
			return FALSE
		ok

		def IsLetterOrSpaceOrOneOfTheseChars(pacChar)
			return This.IsLetterOrSpaceOreChars(pacChar)


	  #-----------------------------------#
	 #    TRANSFORMING STRING TO LIST    #
	#-----------------------------------#

	def Listify()
		return This.ListifyXT([ :NumberInStringIsTransformedToNumber = FALSE ])

	def ListifyXT(paOptions)

		if NOT StzListQ(paOptions).IsStringListifyParamList()
			stzRaise("Unsupported option list!")
		else
			# By default, or if specified, add the string
			# as a string (without any casting) inside the list
			if len(paOptions) = 0 or
			   (len(paOptions) = 1 and paOptions[1][1] = NULL)

				aResult = [ This.String() ]
				return aResult
			ok

			if This.RepresentsNumber()
				if paOptions[ :NumberInStringIsTransformedToNumber ] = TRUE
					aResult = [ 0+ This.String() ]
					return aResult
	
				but paOptions[ :NumberInStringIsTransformedToNumber ] = FALSE
					aResult = [ This.String() ]
					return aResult
	
				else
					stzRaise("Unsupported option value!")
				ok
			ok

		ok

	  #----------------------------------------------------#
	 #    ALIGNING THE STRING IN A CONTAINER OF N CHARS   #
	#----------------------------------------------------#

	// Aligns the text in a container of width nWidth
	// Note: if the width is smaller then the string, nothing is done!

	def Align(nWidth, cChar, cDirection)
		# cChar is the char to fill the 'blanks" with.

		switch cDirection

		on :Left
			return This.AlignLeft(nWidth, cChar)

		on :Right
			return This.AlignRight(nWidth, cChar)

		on :Center
			return This.AlignCenter(nWidth, cChar)

		on :Justified
			return This.Justify(nWidth, cChar)

		other
			stzRaise(stzStringError(:UnsupportedStringJustificationDirection))
		end

		def AlignQ(nWidth, cChar, cDirection)
			This.Align(nWidth, cChar, cDirection)
			return This
	
	def Aligned(nWidth, cChar, cDirection)
		cResult = This.Copy().AlignQ(nWidth, cChar, cDirection).Content()
		return cResult

	def LeftAlign(nWidth, cChar)

		/*
		Managing the special case of the arabic char (Shaddah)
		which can alter the justification of text, because Qt
		treats it as a spearate char with its own position in
		the resulting string, while it must set on top of chars!

		Note: The same case of arabic diacritics (7araket)
		 is not managed in this version (In the future,
		an extended arabic library will manage those (and other)
		specificities or arabic.

		Warning: In this version, if your arabic text contains
		arabic diactritics (7arakets), then the alignbment
		won't be correct!
 		*/

		nWidth += This.NumberOfOccurrence( :Of = ArabicShaddah() )

		# Computing the alignment using Qt

		if nWidth > This.NumberOfChars()
			oChar = new stzChar(cChar)
			oQChar = oChar.QCharObject()

			// Take in account a logical error of Qt in aligning non
			// left-to-right strings (like arabic and hebrew)

			if This.IsRightToLeft()
				cJustified = @oQString.rightJustified(nWidth, oQChar, FALSE)
			else
				cJustified = @oQString.leftJustified(nWidth, oQChar, FALSE)
			ok
	
			This.Update( cJustified )
		ok

		def LeftAlignQ(nWidth, cChar)
			This.LeftAlign(nWidth, cChar)
			return This

		def AlignLeft(nWidth, cChar)
			This.LeftAlign(nWidth, cChar)

			def AlignLeftQ(nWidth, cChar)
				This.AlignLeft(nWidth, cChar)
				return This

	def LeftAligned(nWidth, cChar, cDirection)
		cResult = This.Copy().LeftAlignQ(nWidth, cChar, cDirection).Content()
		return cResult

	def RightAlign(nWidth, cChar)

		# See comment in LeftAlign() method
 
		nWidth += This.NumberOfOccurrence( :Of = ArabicShaddah() )

		# Computing the justification using Qt

		if nWidth > This.NumberOfChars()
			oChar = new stzChar(cChar)
			oQChar = oChar.QCharObject()

			if This.IsRightToLeft()
				cJustified = @oQString.leftJustified(nWidth, oQChar, FALSE)
			else
				cJustified = @oQString.rightJustified(nWidth, oQChar, FALSE)
			ok
	
			This.Update( cJustified )
		ok

		def RightAlignQ(nWidth, cChar)
			
			This.RightAlign(nWidth, cChar)
			return This

		def AlignRight(nWidth, cChar)
			This.RightAlign(nWidth, cChar)

			def AlignRightQ(nWidth, cChar)
				This.AlignRight(nWidth, cChar)
				return This

	def RightAligned(nWidth, cChar, cDirection)
		cResult = This.Copy().RightAlignQ(nWidth, cChar, cDirection).Content()
		return cResult

	def CenterAlign(nWidth, cChar)

		# See comment in LeftAlign() method
 
		nWidth += This.NumberOfOccurrence( :Of = ArabicShaddah() )

		# Computing the justification using Qt

		if nWidth > This.NumberOfChars()

			n = nWidth - This.NumberOfChars()
			n1 = 0
			n2 = 0

			oNumber = new stzNumber(n)
			if oNumber.IsEven()
				n1 = n / 2
				n2 = n1
			else
				n1 = (n - 1) / 2
				n2 = n1 + 1
			ok

			cResult = StringRepeat(cChar, n1) +
				  This.String() +
				  StringRepeat(cChar, n2)

			This.Update( cResult )
		ok

		def CenterAlignQ(nWidth, cChar)
			This.CenterAlign(nWidth, cChar)
			return This

		def AlignCenter(nWidth, cChar)
			This.CenterAlign(nWidth, cChar)

			def AlignCenterQ(nWidth, cChar)
				This.AlignCenter(nWidth, cChar)
				return This

	def CenterAligned(nWidth, cChar, cDirection)
		cResult = This.Copy().CenterAlignQ(nWidth, cChar, cDirection).Content()
		return cResult

	def Justify(nWidth, cChar)

		# See comment in LeftAlign() method
 
		nWidth += This.NumberOfOccurrence( :Of = ArabicShaddah() )

		# Computing the justification using Qt

		if nWidth <= This.NumberOfChars()
			return NULL
		ok

		nPoints = nWidth - This.NumberOfChars()
		aTemp = []
		for i = 1 to This.NumberOfChars() - 1
			if NOT (CharIsArabicShaddah(This[i]) or CharIsArabic7arakah(This[i]))
				aTemp + This[i]
			else
				if len(aTemp) != 0
					aTemp[ len(aTemp) ] = aTemp[ len(aTemp) ] + This[i]
				ok
			ok
		next

		while nPoints > 0
			for i = 1 to len(aTemp)
				aTemp[i] = aTemp[i] + cChar
				nPoints--
				if nPoints = 0 { exit }
			next
		end

		aTemp + This.LastChar()

		cResult = ""
		for str in aTemp
			cResult += str
		next

		This.Update( cResult )

		def JustifyQ(nWidth, cChar)
			This.Justify(nWidth, cChar)
			return This

	def Justified(nWidth, cChar)
		cResult = This.Copy().JustifyQ(nWidth, cChar).Content()

	  #----------------------------------#
	 #    TEXT ENCODING & CONVERTING    #
	#----------------------------------#

	//Returns a UTF-8 representation of the string as a QByteArray
	def ToUTF8()
		return QByteArrayToList( @oQString.toUtf8() )

	def ToUTF8Q()
		return new stzString( This.ToUTF8() )

	def FromUTF8(pcUTF8String)
		// TODO

	def ToLatin1()
		return @oQString.toLatin1()

	def FromLatin1(pcLatin1String)
		// TODO

	def ToLocal8Bit()
		return @oQString.toLocal8Bit()

	def ToBase64()
		return This.ToStzListOfBytes().ToBase64()

		def ToBase64Q()
			return new stzString( This.ToBase64() )

	// Transforms the content of the string to a url-like encoded string
	def ToPercentEncoding(pcExcludedFromEncoding, pcIncludedInEncoding, pcPercentAsciiChar)
		/* Example:
		o1 = new stzString("{a fishy string?}")
		? o1.ToPercentEncoding( "{}", "s" )

		--> {a%20fi%73hy%20%73tring%3F}
		*/

	// Updates the list of bytes with an url-like decoded copy of the provided string
	def FromPercentEncoding(pcPercentEncodedString, pcPercentAsciiChar)
		/* Example:
		o1 = new stzString("")
		o1.FromPercentEncoding( "{a%20fi%73hy%20%73tring%3F}", "%" )
		o1.Content()

		--> {a fishy string?}
		*/

	def ToHex()
		return str2hex( This.String() )

		def ToHexQ()
			return new stzString( This.ToHex() )
	
	def FromHex(cHex)
		@oQString = new QString2()
		@oQString.append(hex2str(cHex))

		def FromHexQ(cHex)
			This.FromHex(cHex)
			return This

	// Escapes HTML special Chars in the string
	def EscapeHtml()
		cResult = @oQString.toHtmlEscaped()

		return cResult

		def EscapeHtmlQ()
			return new stzString( This.EscapeHtml() )

	def HtmlEscaped()
		return This.EscapeHtmlQ().Content()
	
	  #------------------------------------------------#
	 #    UNICODE CODES OF THE CHARS OF THE STRING    #
	#------------------------------------------------#

	// Transforms the string to a number based on the defined format
	// --> TODO: Use the ApplyFormat() method in the stzNumber class...
	// Rething the naming!
	def ToNumber(cFormat) // TODO
		/*
		o1 = new stzString("+12500,14")
		? o1.ToNumber("+99 999.99") --> 12 500.14
		*/

	def ToNumberQ(cFormat)
		return new stzNumber( This.ToNumber() )
	

	  #------------------------------------------------#
	 #    UNICODE CODES OF THE CHARS OF THE STRING    #
	#------------------------------------------------#

	// The following method is mainly used by stzChar class to
	// create a characrer object from text
	def UnicodeOfCharN(n)
		oTempQStr = new QString2()
		oTempQStr.append(This[n])
		return oTempQStr.unicode().unicode()
		/*
		The first unicode() on QString returns a QChar,
		while the seconde unicode() on this QChar returns
		the actual decimal unicode of the Char
		*/

	// Returns a list of unicodes of all the Chars in the string
	def Unicodes()
		aResult = []
		for i = 1 to This.NumberOfChars()
			aResult + This.UnicodeOfCharN(i)
		next

		return aResult

	def Unicode()
		if This.NumberOfChars() = 1
			return This.UnicodeOfCharN(1)

		else
			return This.Unicodes()
		ok

	def CharsAndUnicodes()
		aResult = []
		for i = 1 to This.NumberOfChars()
			aResult + [ This[i], This.UnicodeOfCharN(i) ]
		next

		return aResult

	def UnicodesPerChar()
		aResult = []
		for i = 1 to This.NumberOfChars()
			aResult + [ This[i], Unicodes()[i] ]
		next
		return aResult

	  #-------------------#
	 #    CHARS NAMES    #
	#-------------------#

	def CharsNames()
		acResult = []

		for i = 1 to This.NumberOfChars()
			acResult + StzCharQ( This[i] ).Name()
		next

		return acResult

		def CharNamesQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			if pcReturnType = :stzList
				return new stzList(This.CharNames())

			pcReturnType = :stzListOfStrings
				return new stzListOfString(This.CharNames())

			else
				stzRaise("Unsupported return type!")
			ok

		def CharNamesQ()
			return This.CharNamesQR(:stzListOfStrings)

	def CharName()
		return This.CharsNames()[1]

		def CharNameQ()
			return new stzString(This.CharName())

	  #-------------------------------#
	 #    MULTINGUAL & LOCLAE INFO   #
	#-------------------------------#

	/*
	In Softanza, a unicode code of a language, country or locale can be:
		* number : like "6" for arabic
		* name : like "arabic" for arabic
		* abbreviation : like "ar" (short form) and "ara" (long form) for arabic
	*/

	def IsLanguageIdentifier()
		return 	This.IsLanguageNumber() or
			This.IsLanguageAbbreviation() or
			This.IsLanguageName()

	def IsLanguageNumber()
		if This.IsEmpty() { return FALSE }

		bResult = FALSE
		for aLanguageInfo in LocaleLanguagesXT()
			if aLanguageInfo[1] = This.String()
				bResult = TRUE
				exit
			ok
		next
	
		return bResult

		def IsLanguageCode()
			return This.IsLanguageNumber()

	def IsLanguageNumberXT()
		/*
		Returns :
		[ TRUE/FALSE, :LanguageName ]
		*/
		if This.IsEmpty() { return FALSE }

		bLangNumber = This.IsLanguageNumber()
		cLang = :Nothing

		if This.IsLanguageNumber()
			oList = new stzList(LocaleLanguageNumbers())
			if oList.Contains(This.String())
				oLocale = new stzLocale(This.String())
				cLang = oLocale.LanguageName()
			ok

		ok

		return [ bLangNumber, cLang ]


	def IsShortLanguageAbbreviation()
		if This.IsEmpty() { return FALSE }

		bResult = FALSE
		for aLanguageInfo in LocaleLanguagesXT()
			if lower(aLanguageInfo[3]) = lower(This.String())
				bResult = TRUE
				exit
			ok
		next
	
		return bResult

	def IsLongLanguageAbbreviation()
		if This.IsEmpty() { return FALSE }

		bResult = FALSE
		for aLanguageInfo in LocaleLanguagesXT()
			if lower(aLanguageInfo[4]) = lower(This.String())
				bResult = TRUE
				exit
			ok
		next
	
		return bResult

	def IsLanguageAbbreviation()
		/* Could be written expressively like this:

		return This.IsLanguageShotAbbreviation() OR This.IsLanguageLongAbbreviation()

		but the following is mutch more efficient: */

		if This.IsEmpty() { return FALSE }

		bResult = FALSE
		for aLanguageInfo in LocaleLanguagesXT()

			if lower(aLanguageInfo[3]) = lower(This.String()) OR
			   lower(aLanguageInfo[4]) = lower(This.String())
				bResult = TRUE
				exit
			ok
		next
	
		return bResult

	def IsLanguageShortAbbreviation()
		if This.IsEmpty() { return FALSE }

		bResult = FALSE
		for aLanguageInfo in LocaleLanguagesXT()
			if lower(aLanguageInfo[3]) = lower(This.String())
				bResult = TRUE
				exit
			ok
		next
	
		return bResult

	def IsLanguageLongAbbreviation()
		if This.IsEmpty() { return FALSE }

		bResult = FALSE
		for aLanguageInfo in LocaleLanguagesXT()
			if lower(aLanguageInfo[4]) = lower(This.String())
				bResult = TRUE
				exit
			ok
		next
	
		return bResult

	def IsLanguageAbbreviationXT()
		/*
		Returns :
		[ TRUE, :Short ] or [ :TRUE, :Long ] or [ FALSE, NULL ]
		*/
		if This.IsEmpty() { return FALSE }

		bAbbr = This.IsLanguageAbbreviation()
		ctype = :Nothing

		if This.IsLanguageShortAbbreviation()
			cType = :Short
		but This.IsLanguageLongAbbreviation()
			cType = :Long
		ok

		return [ bAbbr, cType ]

	def IsLanguageName() # In english

		if This.IsEmpty() { return FALSE }

		bResult = FALSE
		for aLanguageInfo in LocaleLanguagesXT()
			if lower(aLanguageInfo[2]) = lower(This.String())
				bResult = TRUE
				exit
			ok
		next
	
		return bResult

		def IsNotLanguageName()
			return NOT This.IsLanguageName()

	def IsNativeLanguageName() # Locale-specific
		if This.IsEmpty() { return FALSE }

		stzRaise(stzStringError(:UnsupportedFeatureInThisVersion)) # TODO

	def IsCountryIdentifier()
		return 	This.IsCountryNumber() or
			This.IsCountryAbbreviation() or
			This.IsCountryName() or
			This.IsCountryPhoneCode()

	def IsCountryAbbreviation()
		if This.IsEmpty() { return FALSE }

		cAbbr = This.String()
		bResult = FALSE
		for aCountryInfo in LocaleCountriesXT()
			if UPPER(aCountryInfo[3]) = UPPER(cAbbr) OR
			   UPPER(aCountryInfo[4]) = UPPER(cAbbr)

				bResult = TRUE
				exit
			ok
		next
	
		return bResult

	def IsCountryName()
		if This.IsEmpty() { return FALSE }

		cName = This.String()
		bResult = FALSE
		for aCountryInfo in LocaleCountriesXT()
			if lower(aCountryInfo[2]) = lower(cName)
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def IsNotCountryName()
			return NOT This.IsCountryName()

	def IsNativeCountryName() # Locale-specific
		if This.IsEmpty() { return FALSE }

		stzRaise(stzString(:UnsupportedFeatureInThisVersion))

	def IsCountryPhoneCode()
		if This.IsEmpty() { return FALSE }

		cPhoneCode = This.String()
		bResult = FALSE

		for aCountryInfo in LocaleCountriesXT()
			if aCountryInfo[5] = cPhoneCode
				bResult = TRUE
				exit
			ok
		next

		return bResult

	def IsCountryNumber()
		if This.IsEmpty() { return FALSE }

		cNumber = This.String()
		bResult = FALSE

		for aCountryInfo in LocaleCountriesXT()
			if lower(aCountryInfo[1]) = lower(cNumber)
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def IsCountryCode()
			return This.IsCountryNumber()

	def IsShortCountryAbbreviation()
		if This.IsEmpty() { return FALSE }

		cAbbr = This.String()
		bResult = FALSE
		for aCountryInfo in LocaleCountriesXT()
			if UPPER(aCountryInfo[3]) = UPPER(cAbbr)

				bResult = TRUE
				exit
			ok
		next
	
		return bResult

		def IsCountryShortAbbreviation()
			return This.IsShortCountryAbbreviation()

	def IsLongCountryAbbreviation()
		if This.IsEmpty() { return FALSE }

		cAbbr = This.String()
		bResult = FALSE
		for aCountryInfo in LocaleCountriesXT()
			if UPPER(aCountryInfo[4]) = UPPER(cAbbr)
				bResult = TRUE
				exit
			ok
		next
	
		return bResult

		def IsCountryLongAbbreviation()
			return This.IsLongCouontryAbbreviation()

	def IsCountryAbbreviationXT()
		/*
		Returns :
		[ TRUE, :Short ] or [ :TRUE, :Long ] or [ FALSE, NULL ]
		*/

		if This.IsEmpty() { return FALSE }

		bAbbr = This.IsCountryAbbreviation()
		ctype = :Nothing

		if This.IsShortCountryAbbreviation()
			cType = :Short
		but This.IsLongCountryAbbreviation()
			cType = :Long
		ok

		return [ bAbbr, cType ]
	
	def IsScriptIdentifier()
		return 	This.IsScriptNumber() or
			This.IsScriptAbbreviation() or
			This.IsScriptName()

	# Script abbreviation can't be short or long, it is always 4 chars long!
	def IsScriptAbbreviation()
		if This.IsEmpty() { return FALSE }

		cAbbr = This.String()
		bResult = FALSE
		for aScriptInfo in LocaleScriptsXT()
			if lower(aScriptInfo[3]) = lower(cAbbr)
				bResult = TRUE
				exit
			ok
		next
	
		return bResult

	def IsScriptName()
		if This.IsEmpty() { return FALSE }

		cScript = This.String()
		bResult = FALSE

		for aScriptInfo in LocaleScriptsXT()
			if lower(aScriptInfo[2]) = lower(cScript)
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def IsScript()
			return This.IsScriptName()

		def IsNotScriptName()
			return NOT This.IsScriptName()

	def IsScriptNumber()
		if This.IsEmpty() { return FALSE }

		cScript = This.String()
		bResult = FALSE
		for aScriptInfo in LocaleScriptsXT()
			if lower(aScriptInfo[1]) = lower(cScript)
				bResult = TRUE
				exit
			ok
		next

		return bResult

		def IsScriptCode()
			return This.IsScriptNumber()

	def IsLocaleAbbreviation()
		cThisString = This.ReplaceQ("_", :With = "-").Content()
		oLocalesInString = StzStringQ( LocaleAbbreviationsHostedInString() )
		bResult = oLocalesInString.ContainsCS( cThisString, :CaseSensitive = FALSE )

		return bResult
	
	def ContainsLocaleSeparator()
		return This.Contains("_") or This.Contains("-")

	def ExtractLocaleSeparator()

		if This.ContainsLocaleSeparator()
			if This.Contains("_")
				return "_"

			but This.Contains("-")
				return "-"
			ok
		ok

	def ContainsNoLocaleSeparator()
		return NOT This.ContainsLocaleSeparator()

	def ContainsOneLocaleSeparator()
		return  This.ContainsNTimes(1, "_") or
			This.ContainsNTimes(1, "_")

	def IsLocaleSeparator()
		return This.Content() = "_" or This.Content() = "-"

	def IsCurrencyName()
		if This.IsEmpty() { return FALSE }

		bResult = FALSE

		for aCurrencyInfo in CurrenciesXT()
			if lower(aCurrencyInfo[1]) = This.Lowercased()
				bResult = TRUE
				exit
			ok
		next

		return bResult	

	def IsCurrencySymbol()	# TODO
		if This.IsEmpty() { return FALSE }
		
	def IsBp64LocaleAbbreviation() # Like "ar-TN" for example
		if This.IsEmpty() { return FALSE }

		stzRaise(:UnsupportedFeatureInThisVersion)

	def IsDayName() # In english

		return This.IsDayNameIn(:English)

	def IsDayNameIn(pcLanguageName)
		if This.IsEmpty() { return FALSE }

		return This.LowercaseQ().IsOnOfThese(NamesOfDaysIn(pcLanguageName))

	def IsNativeDayNameInLocale(pLocale) # Locale-specific
		if This.IsEmpty() { return FALSE }

		return This.IsEqualToCS(StzLocaleQ(pLocale).NativeDayName(), :CaseSensitive = FALSE)

	def IsMonthName() # In english
		stzRaise(:UnsupportedFeatureInThisVersion)

	def IsNativeMonthName() # Locale-specific
		stzRaise(:UnsupportedFeatureInThisVersion)

	  #------------------------#
	 #    NUMBER IN STRING    #
	#------------------------#

	def RepresentsNumber()

		if This.RepresentsNumberInDecimalForm() or
		   This.RepresentsNumberInBinaryForm() or
		   This.RepresentsNumberInOctalForm() or
		   This.RepresentsNumberInHexForm() or
		   This.RepresentsNumberInScientificNotation()
			
			return TRUE

		else

			return FALSE
		ok

		#< @FunctionAlternativeForms

		def IsNumberInString()
			return This.RepresentsNumber()

		def RepresentsNumberInString()
			return This.RepresentsNumber()

		#>
	
	def RepresentsSignedNumber()
		if This.RepresentsNumber() and
		   (This.FirstChar() = "+" or This.FirstChar() = "-")

			return TRUE
		else
			return FALSE
		ok

	def RepresentsUnsignedNumber()
		if This.RepresentsNumber() and
		   NOT (This.FirstChar() = "+" or This.FirstChar() = "-")

			return TRUE
		else
			return FALSE
		ok		

	def RepresentsCalculableNumber() 

		if This.RepresentsCalculableInteger() or
		   This.RepresentsCalculableRealNumber()

			return TRUE

		else
			return FALSE
		ok
				 
		/*
		Non calculable numbers are: 
		-  other numbers in Uniocde, like circled number icons,
		   roman and indian numbers and others

		- numbers in any form (decimal, binary, octal, hex, scientific)
		  that can not be calculated "precisily" with Ring, as defined by
		  MinCalculableNumber() and MaxCalculableNumber()
		*/

	def RepresentsInteger()
		if This.RepresentsNumber() and This.ContainsNo(".")
			return TRUE
		else
			return FALSE
		ok

	def RepresentsSignedInteger()
		if This.RepresentsInteger() and
		   (This.FirstChar() = "+" or This.FirstChar() = "-")

			return TRUE
		else
			return FALSE
		ok

	def RepresentsUnsignedInteger()
		if This.RepresentsInteger() and
		   NOT (This.FirstChar() = "+" or This.FirstChar() = "-")

			return TRUE
		else
			return FALSE
		ok

	def RepresentsCalculableInteger()

		if This.representsInteger()

			# Step 1: we define the number of digits of
			# the integer and the maximum number of digits
			# allowed by Ring for integers
			
			if This.RepresentsSignedInteger()

				nNumberOfDigits = This.NumberOfChars() - 1
				nMaxNumberOfDigits = MaxNumberOfDigitsInSignedInteger()

			else

				nNumberOfDigits = This.NumberOfChars()
				nMaxNumberOfDigits = MaxNumberOfDigitsInUnsignedInteger()
			ok

			# Step 2: we compare between them to kwow if this
			# integer is calculable precisely by Ring or not

			if nNumberOfDigits <= nMaxNumberOfDigits
				return TRUE
			else
				return FALSE
			ok

		else
			return FALSE
		ok

	def RepresentsRealNumber()
		if This.RepresentsNumber() and This.Contains(".")
			return TRUE
		else
			return FALSE
		ok		

	def RepresentsSignedRealNumber()
		if This.RepresentsRealNumber() and
		   (This.FirstChar() = "+" or This.FirstChar() = "-")

			return TRUE
		else
			return FALSE
		ok

	def RepresentsUnsignedRealNumber()
		if This.RepresentsRealNumber() and
		   NOT (This.FirstChar() = "+" or This.FirstChar() = "-")

			return TRUE
		else
			return FALSE
		ok

	def RepresentsCalculableRealNumber()
		
		if This.RepresentsRealNumber()

			# Step1: We split the string to get integer and
			# decimal parts and calculate the number of
			# digits in the real number

			cIntegerPart = This.Split(".")[1]
			nNumberOfDigitsIncIntegerPart = len(cIntegerPart)

		 	if left(cIntegerPart,1) = "+" or
			   left(cIntegerPart,1) = "-"
				nNumberOfDigitsIncIntegerPart--
			ok

			cFractionalPart = This.Split(".")[2]
			nNumberInDigitsInFractionalPart = len(cFractionalPart)

			nNumberOfDigits = nNumberOfDigitsIncIntegerPart +
					  nNumberInDigitsInFractionalPart

			# Step 2: We compute the maximum number of digits allowed
			# depending on the real number being singed or unsigned

			nMaxNumberOfDigits = 0
			if This.RepresentsSignedRealNumber()
				nMaxNumberOfDigits = MaxNumberOfDigitsInSignedRealNumber()
			else
				nMaxNumberOfDigits = MaxNumberOfDigitsInUnsignedRealNumber()
			ok

			# Step 3: we compare between them to kwow if this real
			# number is calculable precisely by Ring or not

			if nNumberOfDigits <= nMaxNumberOfDigits
				return TRUE
			else
				return FALSE
			ok

		else
			return FALSE
		ok

	def RepresentsNumberInDecimalForm()

		# Rule 1: String shouldn't be null

		if This.Content() = ""
			return FALSE
		ok

		# Rule 2: String shouldn't be just one of these chars

		if This.NumberOfChars() = 1 and
		   (This.Content() = "+" or This.Content() = "-" or
		    This.Content() = "." or This.Content() = "_" or
		    This.Content() = " ")

			return FALSE
		ok

		# Rule 3: String shouldn't contain more then once these chars

		if This.NumberOfOccurrence("-") > 1 or
		   This.NumberOfOccurrence("+") > 1 or
		   This.NumberOfOccurrence(".") > 1

			return FALSE
		ok

		# Rule 4: If "-" sign exits, then it should prefix the string

		if This.Contains("-") and This.FirstChar() != "-"
			return FALSE
		ok

		# Rule 5: If "+" sign exits, then it should prefix the string

		if This.Contains("+") and This.FirstChar() != "+"
			return FALSE
		ok

		# Rule 6: If "." separator exists, then it shouldn't be at the end

		if This.Contains(".") and This.LastChar() = "."
			return FALSE
		ok

		# Now, let's check the chars correspond to digits, signs or separators

		oPossibleChars = new stzList( "0":"9" + "-" + "+" + "." + "_" )

		for i = 1 to This.NumberOfChars()
			c = This.NthChar(i)

			if NOT oPossibleChars.Contains(c)
				return FALSE
			ok

		next

		# At this level, we can be sure the string is a decimal number

		return TRUE

	// Checks if the string corresponds to a binary number started by the
	// prefix defined in BinaryNumberPrefix() and composed of 0s and 1s

	def RepresentsNumberInBinaryForm()

		# Rule 1: String shouldn't be null or formed of just spaces

		if This.IsEmpty()
			return FALSE
		ok

		# Rule 2: String should be prefixed with a binary prefix

		bTemp = FALSE

		for cBinPrefix in BinaryPrefixes()
			oCopy = This.Copy()
			oCopy.RemoveFromLeftQ("-").RemoveFromLeftQ("+")

			if oCopy.StartsWithCS(cBinPrefix, :CaseSensitive = FALSE)
				bTemp = TRUE
				exit
			ok
		next
		if bTemp = FALSE { return FALSE }

		# Rule 3: String shouldn't be just one of these chars

		if This.NumberOfChars() = 1 and
		   (This.Content() = "+" or This.Content() = "-" or
		    This.Content() = "." or This.Content() = "_")

			return FALSE
		ok

		# Rule 4: String shouldn't contain more then once these chars

		if This.NumberOfOccurrence("-") > 1 or
		   This.NumberOfOccurrence("+") > 1 or
		   This.NumberOfOccurrence(".") > 1

			return FALSE
		ok

		# Rule 5: If "-" sign exits, then it should prefix the string

		if This.Contains("-") and This.FirstChar() != "-"
			return FALSE
		ok

		# Rule 6: If "+" sign exits, then it should prefix the string

		if This.Contains("+") and This.FirstChar() != "+"
			return FALSE
		ok

		# Rule 7: If "." separator exists, then it shouldn't be at the end

		if This.Contains(".") and This.LastChar() = "."
			return FALSE
		ok

		# Now, let's check the chars correspond to digits, signs or separators

		oPossibleChars = new stzList( "0":"1" + "b" + "-" + "+" + "." + "_" )

		for i = 1 to This.NumberOfChars()
			c = This.NthChar(i)

			if NOT oPossibleChars.Contains(c)
				return FALSE
			ok

		next

		# At this level, we can be sure the string is a decimal number

		return TRUE

	// Checks if the string corresponds to a hex number form
	def RepresentsNumberInHexForm()

		# Rule 1: String shouldn't be null or formed of just spaces

		if This.IsEmpty()
			return FALSE
		ok

		# Rule 2: String should be prefixed with a hex prefix

		bTemp = FALSE

		for cHexPrefix in HexPrefixes()
			oCopy = This.Copy()
			oCopy.RemoveFromLeftQ("-").RemoveFromLeftQ("+")

			if oCopy.StartsWithCS(cHexPrefix, :CaseSensitive = FALSE)
				bTemp = TRUE
				exit
			ok
		next
		if bTemp = FALSE { return FALSE }

		# Rule 3: String shouldn't be formed of these chars alone

		if This.NumberOfChars() = 1 and
		   (This.Content() = "+" or This.Content() = "-" or
		    This.Content() = "." or This.Content() = "_" )

			return FALSE
		ok

		# Rule 4: String shouldn't contain more then once these chars

		if This.NumberOfOccurrence("-") > 1 or
		   This.NumberOfOccurrence("+") > 1 or
		   This.NumberOfOccurrence(".") > 1

			return FALSE
		ok

		# Rule 5: If "-" sign exits, then it should prefix the string

		if This.Contains("-") and This.FirstChar() != "-"
			return FALSE
		ok

		# Rule 6: If "+" sign exits, then it should prefix the string

		if This.Contains("+") and This.FirstChar() != "+"
			return FALSE
		ok

		# Rule 7: If "." separator exists, then it shouldn't be at the end

		if This.Contains(".") and This.LastChar() = "."
			return FALSE
		ok

		# Now, let's check that chars correspond to digits, signs or separators

		oPossibleChars = new stzList( HexChars() + "x" + "-" + "+" + "." + "_" )

		for i = 1 to This.NumberOfChars()
			c = This.NthChar(i)	

			if NOT oPossibleChars.Contains(c)
				return FALSE
			ok

		next

		# At this level, we can be sure the string is a hex number

		return TRUE

	def RepresentsNumberInUnicodeHexForm()
		if NOT This.LeftNCharsQ(2).Uppercased() = "U+"
			return FALSE
		ok
	
		cNumber = This.LeftNCharsRemoved(2)
	
		if IsHexNumber( HexPrefix() + cNumber )
			return TRUE
		else
			return FALSE
		ok

	// Checks if the string corresponds to an octal number
	def RepresentsNumberInOctalForm()

		# Rule 1: String shouldn't be null or formed of just spaces

		if This.IsEmpty()
			return FALSE
		ok

		# Rule 2: String should be prefixed with an octal prefix

		bTemp = FALSE

		for cOctalPrefix in OctalPrefixes()
			oCopy = This.Copy()
			oCopy.RemoveFromLeftQ("-").RemoveFromLeftQ("+")

			if oCopy.StartsWithCS(cOctalPrefix, :CaseSensitive = FALSE)
				bTemp = TRUE
				exit
			ok
		next
		if bTemp = FALSE { return FALSE }

		# Rule 3: String shouldn't be formed of these chars alone

		if This.NumberOfChars() = 1 and
		   (This.Content() = "+" or This.Content() = "-" or
		    This.Content() = "." or This.Content() = "_" )

			return FALSE
		ok

		# Rule 4: String shouldn't contain more then once these chars

		if This.NumberOfOccurrence("-") > 1 or
		   This.NumberOfOccurrence("+") > 1 or
		   This.NumberOfOccurrence(".") > 1

			return FALSE
		ok

		# Rule 5: If "-" sign exits, then it should prefix the string

		if This.Contains("-") and This.FirstChar() != "-"
			return FALSE
		ok

		# Rule 6: If "+" sign exits, then it should prefix the string

		if This.Contains("+") and This.FirstChar() != "+"
			return FALSE
		ok

		# Rule 7: If "." separator exists, then it shouldn't be at the end

		if This.Contains(".") and This.LastChar() = "."
			return FALSE
		ok

		# Now, let's check that the chars correspond to digits, signs or separators

		oPossibleChars = new stzList( OctalChars() + "o" + "-" + "+" + "." + "_" )

		for i = 1 to This.NumberOfChars()
			c = This.NthChar(i)

			if NOT oPossibleChars.Contains(c)
				return FALSE
			ok

		next

		# At this level, we can be sure the string is a decimal number

		return TRUE

	def RepresentsNumberInScientificNotation()
		// TODO

	def StringIsNumberFraction() # of the form "1/2" or "۱/٢" or "Ⅰ/Ⅱ" or
					  # even "一/二" (in mandarin numerals)
		bResult = FALSE

		if This.NumberOfChars() = 3
			aStzChars = This.ToListOfStzChars()
			if aStzChars[1].IsANumber() and
			   (aStzChars[2].Content() = "/" or aStzChars[2].Content() = ":") and
			   aStzChars[3].IsANumber()

				bResult = TRUE
			ok
		ok

	  #==============#
	 #    CHARS     #
	#==============#

	// Returns the string as a list of Chars
	def Chars()
		aResult = []
		for i = 1 to This.NumberOfChars()
			aResult + This.NthChar(i)
		next
		return aResult

		#< @FunctionFluentForm

		def CharsQ()
			return This.CharsQR(:stzList)

		def CharsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Chars() )

			on :stzListOfChars
				return new stzListOfChars( This.Chars() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Chars() )
			other
				stzRaise([
					:Where = "stzString (13237) > CharsQR()",
					:What  = "Unsupported type!"
				])
			off

		#>

		#< @FunctionAlternativeForms

		def ToListOfChars()
			return This.Chars()

			#< @FunctionFluentForm

			def ToListOfCharsQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.Chars() )

				on :stzListOfChars
					return new stzListOfChars( This.Chars() )

				on :stzListOfStrings
					return new stzListOfStrings( This.Chars() )

				other
					stzRaise("Unsupported type!")
				off 

			def ToListOfCharsQ()
				return This.ToListOfCharsQR(:stzListOfChars)

			def ToStzListOfChars()
				return This.ToListOfCharsQR(:stzListOfChars)


			#>
	
		#>
			
	def ToListOfStzChars()
		aResult = []
		for i = 1 to This.NumberOfChars()
		# Warning: Note that using 'for in' yields erronous
		# result for strings coded on more then 1 byte
			aResult + new stzChar(This[i])
		next
		return aResult

		#< @FunctionFluentForm

		def ToListOfStzCharsQ()
			return new stzList( This.ToListOfStzChars() )

		#>

	  #---------------------------------------------#
	 #      CHARS VERIFYING A GIVEN CONDITION      #
	#---------------------------------------------#
	
	def CharsW(pcCondition)
		if isList(pcCondition) and StzListQ(pcCondition).IsWhereParamList()
			pcCondition = pcCondition[2]

			if NOT isString(pcCondition)
				stzRaise("Incorrect param type! pcCondition must be a string.")
			ok
		ok

		cCondition = StzStringQ(pcCondition).ReplaceAllCSQ("@char", "@item", :CS = FALSE).SimplifyQ().Content()	
		aResult = StzListQ( This.ToListOfChars() ).ItemsW(cCondition)
		return aResult

		def CharsWhere(pcCondition)
			return This.CharsW(pcCondition)

		def AllCharsWhere(pcCondition)
			return This.CharsW(pcCondition)

		def AllCharsW(pcCondition)
			return This.CharsW(pcCondition)

		def OnlyW(pcCondition)
			return This.CharsW(pcCondition)

		# The use of Item instead of Char is required by some
		# features of natural-coding (namely the IsA() function
		# is stzChainOfTruth class
		def ItemsW(pcCondition)
			return GetCharsW(pcCondition)

		def ItemsWhere(pcCondition)
			return GetCharsW(pcCondition)

	  #-------------------------------------------------------#
	 #      NUMBER OF CHARS VERIFYING A GIVEN CONDITION      #
	#-------------------------------------------------------#

	def NumberOfCharsW(pcCondition)
		return len( This.CharsW(pcCondition) )

		def NumberOfCharsWhere(pcCondition)
			return This.NumberOfCharsW(pcCondition)

		def CountCharsW(pcCondition)
			return This.NumberOfCharsW(pcCondition)

		def CountW(pcCondition)
			return This.NumberOfCharsW(pcCondition)

		def CountCharsWhere(pcCondition)
			return This.NumberOfCharsW(pcCondition)

		# Items-based naming as required for natural-coding

		def NumberOfItemsW(pcCondition)
			return This.NumberOfCharsW(pcCondition)

		def NumberOfItemsWhere(pcCondition)
			return This.NumberOfCharsW(pcCondition)

	  #-----------------------#
	 #   STRING IS A CHAR?   #
	#-----------------------#

	def IsChar()
		if This.NumberOfChars() = 1
			return TRUE
		else
			return FALSE
		ok

	def IsAsciiChar()
		if This.Unicode() <= 255
			return TRUE
		else
			return FALSE
		ok

		if oCopy.IsEmpty()
			return TRUE
		else
			return FALSE
		ok

	  #---------------------------#
	 #   STRING MADE OF CHARS?   #
	#---------------------------#

	def IsMadeOfChar(c)
		if ( NOT This.IsEmpty() ) and  StringIsChar(c)
			return This.IsMadeOf([ c ])
		else
			return FALSE
		ok

	def IsMadeOfSome(acSubstrings)
		oCopy = This.Copy()
		
		for cSubstr in acSubstrings
			if This.Contains(cSubStr)
				oCopy.RemoveAll(cSubStr)
			ok
		next

		if oCopy.IsEmpty()
			return TRUE
		else
			return FALSE
		ok

		return FALSE

		def IsMadeOfSomeOfThese(acSubstrings)
			return This.IsMadeOfSome(acSubstrings)

		def IsMadeOfSomeOfTheseSubstrings(acSubstrings)
			return This.IsMadeOfSome(acSubstrings)

	def IsMadeOfSomeOfTheseChars(acChars)
		if ListIsListOfChars(acChars)
			return This.IsMadeOfSome(acChars)
		else
			stzRaise("You must provide a list of chars!")
		ok

	   #------------------------------------------------#
	 #   STRING IS A CHAR IN A COMPUTABLE FORM ("c")   #
	#-------------------------------------------------#

	def IsCharInComputableForm()
		if This.IsChar() and This.IsInComputableForm()
			return TRUE
		else
			return FALSE
		ok

	def IsAsciiCharInString()
		if This.NumberOfChars() = 3 and
		   (This.IsBoundedBy("'", "'") or
		   This.IsBoundedBy('"', '"'))
			return StzStringQ(This[2]).IsAsciiChar()
		else
			return FALSE
		ok

	  #------------------#
	 #   UNIQUE CHARS   #
	#------------------#

	def UniqueChars()
		return This.ToSetOfChars()

		#< @FunctionFluentForm

			def UniqueCharsQ()
			return This.UniqueCharsQR(:stzList)
		#>

		def UniqueCharsQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.UniqueChars() )

			on :stzListOfStrings
				return new stzListOfStrings( This.UniqueChars() )

			on :stzListOfChars
				return new stzListOfChars( This.UniqueChars() )

			other
				stzRaise("Unsupported return type!")
			off

		#>

		def RemoveDuplicatedChars()
			This.Update( This.UniqueChars() )

			def RemoveDuplicatedCharsQ()
				This.RemoveDuplicatedChars()
				return This
	
	  #-------------------------------#
	 #   CHAR AT A GIVEN POSITION    #
	#-------------------------------#	
	
	// Returs the Char at the given position
	def NthChar(nPos)
		if NOT isNumber(nPos)
			stzRaise("Incorrect param type! n should be a number.")
		ok

		if nPos = 0 or nPos > This.NumberOfChars()
			return NULL
		else
			return @oQString.mid(nPos-1,1)
		ok

		#< @FunctionFluentForm
		
		def NthCharQR(nPos, pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzChar
				return new stzChar( This.NthChar(nPos) )
			on :stzString
				return new stzString( This.NthChar(nPos) )
			other
				stzRaise("Unsupported return type!")
			off

		def NthCharQ(nPos)
			return This.NthCharQR(nPos, :stzChar)

		#>
	
		#< @FunctionAlternativeForms

		def CharAt(nPos)
			return This.NthChar(nPos)

			def CharAtQR(nPos, pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.NthCharQR(nPos, pcReturnType)
	
			def CharAtQ(nPos)
				return This.CharAtQR(nPos, :stzChar)

		def CharAtPosition(n)
			return This.NthChar(nPos)

			def CharAtPositionQR(n, pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.NthCharQR(nPos, pcReturnType)

			def CharAtPositionQ(n, pcReturnType)
				return This.CharAtPositionQR(n, :stzChar)

		#>

	  #---------------------------#
	 #   FIRST AND LAST CHARS    #
	#---------------------------#
		
	def FirstChar()
		return This[1]

		#< @FunctionFluentForm

		def FirstCharQ()
			return This.FirstCharQR(:stzString)

		def FirstCharQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzString
				return new stzString( This.FirstChar() )
			on :stzChar
				return new stzChar( This.FirstChar() )
			other
				stzRaise("Unsupported return type!")
			off

		#>

	def LastChar()
		return This[ This.NumberOfChars() ]

		#< @FunctionFluentForm

		def LastCharQ()
			return This.LastCharQR(:stzString)

		def LastCharQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzString
				return new stzString( This.LastChar() )
			on :stzChar
				return new stzChar( This.LastChar() )
			other
				stzRaise("Unsupported return type!")
			off
	
		#>

	  #---------------------------#
	 #   LEFT AND RIGHT CHARS    #
	#---------------------------#
		
	def LeftChar()
		if This.IsLeftToRight()
			return This.FirstChar()
		else
			return This.LastChar()
		ok

		#< @FunctionFluentForm

		def LeftCharQ()
			return This.LeftCharQR(:stzString)

		def LeftCharQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzString
				return new stzString( This.LeftChar() )
			on :stzChar
				return new stzChar( This.LeftChar() )
			other
				stzRaise("Unsupported return type!")
			off

		#>

	def RightChar()
		if This.IsLeftToRight()
			return This.LastChar()
		else
			return This.FirstChar()
		ok

		#< @FunctionFluentForm

		def RightCharQ()
			return This.RightCharQR(:stzString)

		def RightCharQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzString
				return new stzString( This.RightChar() )
			on :stzChar
				return new stzChar( This.RightChar() )
			other
				stzRaise("Unsupported return type!")
			off
	
		#>

	  #-----------------------#
	 #   NUMBER OF CHARS     #
	#-----------------------#

	def NumberOfChars()
		return @oQString.count()

		def NumberOfCharsQ()
			return new stzNumber(This.NumberOfChars())
	
	def NumberOfLetters()
		return len(This.OnlyLetters())

		def NumberOfLettersQ()
			return new stzNumber(This.NumberOfLetters())
	
	def NumberOfSpaces()
		return len(This.FindAll(" "))

		def NumberOfSpacesQ()
			return new stzNumber(This.NumberOfSpaces())

	  #-----------------------#
	 #   IS IT A LERRER?     #
	#-----------------------#

	def IsLetter()
		if This.IsChar() and StzCharQ(This.Content()).IsLetter()
			return TRUE
		else
			return FALSE
		ok
		
	  #------------------------------------------------------#
	 #    STRING IS IN A COMPUTABLE FORM ("str" or 'str')   #
	#------------------------------------------------------#

	def IsInComputableForm()
		if This.NumberOfChars() > 2 and
		   (This.IsBoundedBy("'", "'") or
		    This.IsBoundedBy('"', '"'))

			return TRUE
		else
			return FALSE
		ok
	
	  #-------------------------#
	 #    MADE OF SUBSTRINGS   #
	#-------------------------#

	def IsMadeOf(acSubStr)
		oCopy = This.Copy()
		
		for cSubstr in acSubStr
			if NOT This.Contains(cSubStr)
				return FALSE
			ok

			oCopy.RemoveAll(cSubStr)
		next

		if oCopy.IsEmpty()
			return TRUE
		else
			return FALSE
		ok

		def IsMadeOfThese(acSubStr)
			return This.IsMadeOf(acSubStr)

		def IsMadeOfTheseSubstrings(acSubStr)
			This.IsMadeOf(acSubStr)

	def IsMadeOfTheseChars(acChars)
		if ListIsListOfChars(acChars)
			return This.IsMadeOf(acChars)
		else
			stzRaise("You must provide a list of chars!")
		ok

	
	  #-----------------#
	 #   MULTIPLY BY   #	TODO: reclassify it with other calculations
	#-----------------#

	def MultiplyBy(pValue)
			cResult = NULL

			if type(pValue) = "NUMBER"
				cResult = This.RepeatNTimesQ(pValue).Content()
		
			but type(pValue) = "STRING"

				if pValue = NULL { return NULL }

				cResult = NULL
				cTemp = NULL

				for i=1 to This.NumberOfChars()
					cTemp = @oQString.mid(i-1,1) + pValue
					cResult += cTemp
				next
		
			but type(pValue) = "LIST"
				aValue = pValue // just for expressivity
				cResult = ""
				cTemp = ""
				
				for i=1 to This.NumberOfChars()
					for v=1 to len(aValue)
						cTemp = @oQString.mid(i-1,1) + aValue[v]
						cResult += cTemp 
					next
										
					if i != NumberOfChars() // avoiding adding space at the end
						cResult += " "
					ok
				next
			ok

			This.Update( cResult )

		#< @FunctionFluentForm

		def MultiplyByQ(pValue)
			This.MultiplyBy(pValue)
			return This
	
		def MultiplyByQR(pValue, pcReturnType)	
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			This.MultiplyBy(pValue)
	
			switch pcReturnType
			on :String
				return This.String()
	
			on :List
				return This / len(
			off

		#>

	  #----------------------------------------#
	 #     BOXING THE STRING AND ITS CHARS    #
	#----------------------------------------#
	
	def Box() # Undersatnd it as a verb action on the string

		return This.BoxXT([])

		#< @FunctionFluentForm

		def BoxQ()
			return new stzString( This.Box() )
		#>

		def Boxed()
			return This.BoxQ().Content()

	def BoxDashed()
		return This.BoxXT([ :Line = :Dashed ])

		#< @FunctionFluentForm

		def BoxDashedQ()
			return new stzString( This.BoxDashed() )
		#>

		def BoxedDashed()
			return This.BoxDashedQ().Content()

	def BoxRound()
		return This.BoxXT([ :AllCorners = :Round ])

		#< @FunctionFluentForm

		def BoxRoundQ()
			return new stzString( This.BoxRound() )
		#>

		def BoxedRound()
			return This.BoxRoundQ().Content()

	def BoxRoundDashed()
		return This.BoxXT([ :Line = :Dashed, :AllCorners = :Round ])

		#< @FunctionFluentForm

		def BoxRoundDashedQ()
			return new stzString( This.BoxRoundDashed() )
		#>

		def BoxedRoundDashed()
			return This.BoxRoundDashedQ().Content()

	def BoxDashedRound()
		return This.BoxRoundDashed()

		#< @FunctionFluentForm

		def BoxDashedRoundQ()
			return new stzString( This.BoxDashedRound() )
		#>

		def BoxedDashedRound()
			return This.BoxDashedRoundQ().Content()

	def BoxEachChar()
		return This.BoxXT([ :EachChar = TRUE ])

		#< @FunctionFluentForm

		def BoxEachCharQ()
			return new stzString( This.BoxEachChar() )
		#>

		def EachCharBoxed()
			return This.BoxEachCharQ().Content()

	def BoxEachCharRound()
		return This.BoxXT( [ :AllCorners = :Round, :EachChar = TRUE ])

		#< @FunctionFluentForm

		def BoxEachCharRoundQ()
			return new stzString( This.BoxEachCharRound() )
		#>

		def EachCharboxedRound()
			return This.BoxEachCharRoundQ().Content()

	def BoxEachCharXT(paBoxOptions)
		if StzHashListQ(paBoxOptions).ContainsKey( :EachChar )
			paBoxOptions = StzHashListQ(paBoxOptions).UpdateValueByKeyQ( :EachChar, TRUE ).Content()
		else
			paBoxOptions = StzHashListQ(paBoxOptions).AddPairQ( :EachChar = TRUE ).Content()
		ok

		return This.BoxedXT(paBoxOptions)

		#< @FunctionFluentForm

		def BoxEachCharXTQ(paBoxOptions)
			return new stzString( This.BoxedEachCharXT(paBoxOptions) )

		#>

		def EachCharBoxedXT(paBoxOptions)
			return This.BoxEachCharXTQ(paBoxOptions).Content()

	def BoxXT(paBoxOptions)

		/*
		Example:

		? StzStringQ("TEXT1").BoxXT([

			:Line = :Thin,	# or :Dashed
		
			:AllCorners = :Round, # can also be :Rectangualr
			# :Corners = [ :Round, :Rectangular, :Round, :Rectangular ],
		
			:TextAdjustedTo = :Center # or :Left or :Right or :Justified

		]).Content()

		--> Gives:
		╭───────────────╮
		│     TEXT1     │ 
		╰───────────────╯

		The list of possible options, as you find inforced in
		stzList.IsTextBoxedParamList(), are:

			aListOfBoxOptions = [
				# General options
				:Line,
				:AllCorners,
				:Corners,
				:Width,
				:TextAdjustedTo,

				# Options speciefic to list of chars and words
				:EachChar,
				:EachWord,
				:Hilighted,
				:HilightedIf,
				:Numbered
			]

		*/

		if StzListQ(paBoxOptions).IsTextBoxedParamList()

			# Reading the type of line (thin or dashed)

			cLine = :Thin # By default

			if paBoxOptions[ :Line ] = :Dashed
				cLine = :Dashed
			ok

			# Reading the type of corners (rectangualr or round)

			cAllCorners = :Rectangular # By default

			if paBoxOptions[ :AllCorners ] = :Round
				cAllCorners = :Round
			ok

			aCorners = []
			if cAllCorners = :Rectangular
				 # By default
				aCorners = [ :Rectangular, :Rectangular, :Rectangular, :Rectangular ]

			but cAllCorners = :Round
				aCorners = [ :Round, :Round, :Round, :Round ]

			ok

			if len(paBoxOptions[:Corners]) = 4 and
			   StzListQ( paBoxOptions[:Corners] ).IsMadeOfSome([ :Rectangular, :Round ])
	
				aCorners = paBoxOptions[:Corners]

			ok

			# If the boxing happens at the char level, delegate it
			# to the stzListOfChars class

			if paBoxOptions[ :EachChar ] = TRUE
				return StzListOfCharsQ( This.String() ).BoxedXT(paBoxOptions)
			ok

			# If the boxing happens at the word level, delegate it
			# to the stzListOfStrings class

			if paBoxOptions[ :EachWord ] = TRUE
				return This.ToListOfStringsQ().Boxed(paBoxOptions)
			ok

			# Reading the width of the box in number of chars

			nWidth = This.NumberOfChars() + 2 # By default

			if isNumber(paBoxOptions[:Width]) and
			   paBoxOptions[:Width] > This.NumberOfChars() + 2

				nWidth = paBoxOptions[:Width]
			ok

			# Reading the text adjustment option

			cTextAdjustedTo = :Center # By default

			oString = new stzString( paBoxOptions[ :TextAdjustedTo ] )
			if oString.IsOneOfThese([ :Left, :Center, :Right, :Justified ])

				cTextAdjustedTo = paBoxOptions[ :TextAdjustedTo ]
			ok
 
			# Composing the box

			cVTrait  = "│"

			cHTrait  = "─"

			if cLine = :Dashed
				cHTrait = "╌"
				cVTrait = "┊"
			ok
			
			
			cCorner1 = "┌"
			cCorner2 = "┐"
			cCorner3 = "┘"
			cCorner4 = "└"

			if  aCorners[1] = :Round
				cCorner1 = "╭"
			ok

			if aCorners[2] = :Round
				cCorner2 = "╮"
			ok

			if aCorners[3] = :Round
				cCorner3 = "╯"
			ok

			if aCorners[4] = :Round
				cCorner4 = "╰"
			ok

			cUpLine = cCorner1 +
				  StzStringQ(cHTrait).RepeatNTimesQ(nWidth).Content() +
				  cCorner2 

			
			cMidLine = cVTrait + " " +
				   This.AlignQ(nWidth - 2, " ", cTextAdjustedTo).Content() +
				   " " +
				   cVTrait

			cDownLine = cCorner4 +
				  StzStringQ(cHTrait).RepeatNTimesQ(nWidth).Content() +
				  cCorner3 

			return cUpLine + NL + cMidLine + NL + cDownLine

		but isList(paBoxOptions) and len(paBoxOptions) = 0
			# Do nothing, takes default options for boxing

		else
			stzRaise(stzStringError(:CanNotBoxTheString))
		ok

		#< @FunctionFluentForm

		def BoxedXTQ(paBoxOptions)
			return new stzString( This.BoxXT(paBoxOptions) )

		#>

		def BoxedXT(paBoxOptions)
			return This.BoxXT(paBoxOptions)

	  #-------------------------------------------------------------#
	 #    STRING EXISTENCE (AS A SUBSTRING) IN AN OTHER STRING     #
	#-------------------------------------------------------------#

	def ExistsInThisStringCS(pcStr, pCaseSensitive)
		bResult = StzStringQ(pcStr).ContainsCS( This.String(), pCaseSensitive )
		return bResult

		def IsContainedInThisStringCS(pStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def IsIncludedInThisStringCS(pStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def BelongsToThisStringCS(pStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def IsPartOfThisStringCS(pcStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def IsPartOfCS(pcStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def AppearsInThisStringCS(pcStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def IsSubStringOfThisStringCS(pcStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def IsSubStringOfCS(pcStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def ExistsInStringCS(pcStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def IsContainedInStringCS(pStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def IsIncludedInStringCS(pStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def BelongsToStringCS(pStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def IsPartOfStringCS(pcStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def AppearsInStringCS(pcStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def IsSubStringInStringCS(pcStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

		def IsSubStringInCS(pcStr, pCaseSensitive)
			return This.ExistsInThisStringCS(pcStr, pCaseSensitive)

	def ExistsInThisString(pcStr)
		bResult = This.ExistsInThisStringCS(pcStr, :CaseSensitive = TRUE)
		return bResult

		def IsContainedInThisString(pStr)
			return This.ExistsInThisString(pcStr)

		def IsIncludedInThisString(pStr)
			return This.ExistsInThisString(pcStr)

		def BelongsToThisString(pStr)
			return This.ExistsInThisString(pcStr)

		def IsPartOfThisString(pcStr)
			return This.ExistsInThisString(pcStr)

		def IsPartOf(pcStr)
			return This.ExistsInThisString(pcStr)

		def AppearsInThisString(pcStr)
			return This.ExistsInThisString(pcStr)

		def IsSubStringOfThisString(pcStr)
			return This.ExistsInThisString(pcStr)

		def IsSubStringOf(pcStr)
			return This.ExistsInThisString(pcStr)

		def ExistsInString(pcStr)
			return This.ExistsInThisString(pcStr)

		def IsContainedInString(pStr)
			return This.ExistsInThisString(pcStr)

		def IsIncludedInString(pStr)
			return This.ExistsInThisString(pcStr)

		def BelongsToString(pStr)
			return This.ExistsInThisString(pcStr)

		def IsPartOfString(pcStr)
			return This.ExistsInThisString(pcStr)

		def AppearsInString(pcStr)
			return This.ExistsInThisString(pcStr)

		def IsSubStringInString(pcStr)
			return This.ExistsInThisString(pcStr)

		def IsSubStringIn(pcStr, pCaseSensitive)
			return This.ExistsInThisString(pcStr)

	  #----------------------------------------------#
	 #    STRING EXISTENCE IN A LIST OF STRINGS     #
	#----------------------------------------------#

	def IsOneOfTheseStringsCS(paListOfStrings, pCaseSensitive)

		if NOT ( isList(paListOfString) and
			 StzListQ(paListOfString).IsListOfStrings() )

			return FALSE
		ok

		bResult = StzListOfStringsQ(paListOfStrings).ContainsCS(This.String(), pCaseSensitive)
		return bResult

		#< @FunctionNegativeForm

		def IsNotOneOfTheseStringsCS(paListOfStrings, pCaseSensitive)
			return NOT This.IsOneOfTheseStringsCS(paListOfStrings, pCaseSensitive)

		#>
	
	def IsOneOfTheseStrings(paListOfStrings)
		return IsOneOfTheseStringsCS(paListOfStrings, :CaseSensitive = TRUE)

		#< @FunctionNegativeForm

		def IsNotOneOfTheseStrings(paListOfStrings)
			return NOT This.IsOneOfThese(paListOfStrings)

		#>

	  #------------------------------------------------#
	 #   STRING EXISTENCE IN A GIVEN (HYBRID) LIST    #
	#------------------------------------------------#

	def IsItemOfThisList(paList)

		if NOT isList(paList)
			stzRaise("Invalid param type! You must provide a list.")
		ok

		bResult = StzListQ(paList).Contains(This.String())
		return bResult

		def ExistsInThisList(paList)
			return This.IsItemOfThisList(paList)

		def BelongsToThisList(paList)
			return This.IsItemOfThisList(paList)

		def IsContainedInThisList(paList)
			return This.IsItemOfThisList(paList)

		def IsIncludedInThisList(paList)
			return This.IsItemOfThisList(paList)

		def IsOneOfThese(paList)
			return This.IsItemOfThisList(paList)

		def IsItemOfList(paList)
			return This.IsItemOfThisList(paList)

		def IsItemInList(paList)
			return This.IsItemOfThisList(paList)

		def IsItemInThisList(paList)
			return This.IsItemOfThisList(paList)

		def ExistsInList(paList)
			return This.IsItemOfThisList(paList)

		def BelongsToList(paList)
			return This.IsItemOfThisList(paList)

		def IsContainedInList(paList)
			return This.IsItemOfThisList(paList)

		def IsIncludedInList(paList)
			return This.IsItemOfThisList(paList)

	  #----------------------------------------------#
	 #     STRING EXISTENCE IN STRING OR LIST       #
	#----------------------------------------------#

	def ExistsIn(p)
		if isList(p)
			return This.ExistsInList(p)

		but isString(p)
			return This.ExistsInString(p)

		else
			# TODO: object and number types are not managed
			# --> Reconsider them after solving the Equality
			# problem between all types in Ring

			stzRaise("Unsupported type!")

		ok

		def IsContainedIn(p)
			return This.ExistsIn(p)

		def IsIncludedIn(p)
			return This.ExistsIn(p)

	  #---------------------------#
	 #     SWAPPING & INVERSING  #
	#---------------------------#
	
	def SwapWith(pOtherStzStr)
		if IsStzString(pOtherStzStr)
			oTemp = This
			This.Update( pOtherStzStr.Content() )
			pOtherStzStr = oTemp

		else
			stzRaise(stzStringError(:CanNotSwapWithNonStzStringObject))
		ok

		#< @FunctionFluentForm

		def SwapWithQ(pOtherStzStr)
			This.SwapWith(pOtherStzStr)
			return This

		#>
	
	// Reverses the string

	def ReverseChars()
		cResult = ""
		
		for i = This.NumberOfChars() to 1 step -1
			cResult += This.NthChar(i)
		next
				
		This.Update( cResult )

		#< @FunctionFluentForm

		def ReverseCharsQ()
			This.ReverseChars()
			return This
	
		#>

	def StringWithCharsReversed()
		cResult = This.Copy().ReverseCharsQ().Content()
		return cResult

		def CharsReversed()
			return This.StringWithCharsReversed()

		def Reversed()
			return This.StringWithCharsReversed()

		def StringWithReversedChars()
			return This.StringWithCharsReversed()

		def ReversedChars()
			return This.StringWithCharsReversed()

	  #------------------------#
	 #   HASHING THE STRING   #
	#------------------------#
	
	# Currently we use the native hashing functions of Ring StdLib
	# NOTE: other algortithms can be added through RingQt

	def Hash(pcHashingAlgo)

		cHashed = ""

		switch pcHashingAlgo

		on :MD5
			cHashed = md5( This.String() )

		on :SHA1
			cHashed = sha1( This.String() )

		on :SHA256
			cHashed = sha256( This.String() )

		on :SHA512
			cHashed = sha512( This.String() )

		on :SHA384
			cHashed = sha384( This.String() )

		on :SHA224
			cHashed = sha224( This.String() )

		other
			stzRaise("Unsupported hashing algorithm!")
		off

		This.Update( cHashed )

		#< @FunctionFluidVersion

		def HashQ(pcHashingAlgo)
			return new stzString( This.Hash(pcHashingAlgo) )

		#>

		#< @FunctionAlternativeForms

		def HashWithAlgo(pcHashingAlgo)
			return This.Hash(pcHashingAlgo)

			#< @FunctionFluentForm

			def HashWithAlgoQ(pcHashingAlgo)
				return new stzString( This.HashWithAlgo(pcHashingAlgo) )

			#>
		#>

	def HashWithMD5()
		This.Hash(:MD5)

		#< @FunctionAlternativeForms
		#>

	def HashWithSHA1()
		This.Hash(:SHA1)

		#< @FunctionAlternativeForms
		#>

	def HashWithSHA256()
		This.Hash(:SHA256)

		#< @FunctionAlternativeForms
		#>

	def HashWithSHA384()
		This.Hash(:SHA384)

		#< @FunctionAlternativeForms
		#>

	def HashWithSHA224()
		This.Hash(:SHA224)

		#< @FunctionAlternativeForms
		#>

	  #------------------------------------------#
	 #   ENCRYPTING AND DECRYPTING THE STRING   #
	#------------------------------------------#
	
	# Encrypts the string using the blowfish algorithm:
	# --> returns what's called a cipher in a binary string

	# --> TODO: - what the cIV param means?
	# 	    - check: key must be between 4 and 56 bytes long 

	def EncryptWithBlowfish(cSecretKey, cIV)
		cEncrypted = encrypt( This.String(), cSecretKey, cIV)
		This.Update( cEncrypted )

		#< @FunctionAlternativeForms

		def EncryptWithBlowfishQ(cSecretKey, cIV)
			return new stzListOfBytes( EncryptWithBlowfish(cSecretKey, cIV) )

		#>

	# Updates the string from a cipher encrypted with the blowfish algorithm
	# --> cCypher should be in binary form (list of bytes)
	def FromDecryptedWithBlowfish(cCypher, cSecret, cIV)
		This.Update( decrypt(cCypher, cSecret, cIV) )

		#< @FunctionAlternativeForms

		def FromBlowfishCipher(cCypher, cSecret, cIV)
			This.FromDecryptedWithBlowfish(cCypher, cSecret, cIV)

		#>

	  #------------------------------#
	 #   GETTING TEXT FROM A URL    #
	#------------------------------#

	def UpdateFromURL(cURL)
		This.Update( download(cURL) )

		def UpdateFromURLQ(cURL)
			This.UpdateFromURLL(cURL)
			return This

	def UpdatedFromURL(cURL)
		cResult = This.Copy().UpdateFromURLQ(cURL).Content()
		return cResult

		def FromURL(cURL)
			return This.ImportedFromURL(cURL)

	  #--------------------------------------------#
	 #   WALKING STARTING FROM N UNTIL CHAR IS    #
	#--------------------------------------------#

	def WalkBackward( paStartingAt, pcCondition )
		/*
		str = "Ring Programming Languge"
		StzStringQ(str).WalkBackward( :StartingAt = 12, :Until = '{ @char = " " }' )

		--> Returns 5
		*/

		cResult = ""
		bStopWalking = FALSE
		nCurrentPosition = paStartingAt[2] + 1

		while NOT bStopWalking

			nCurrentPosition--
			if nCurrentPosition = 1
				exit
			ok

			@char = This[ nCurrentPosition ]
			@i = nCurrentPosition

			cCondition = StzStringQ(pcCondition[2]).SimplifyQ().RemoveBoundsQ("{","}").Content()

			cCode = "if " + cCondition + NL +
				TAB + "exit" + NL +
			"ok"

			eval(cCode)
		end

		return nCurrentPosition

	def WalkUntil(pcCondition)
		return This.WalkForeward(:StartingAt = 1, :Until = pcCondition)

	def WalkForeward( paStartingAt, pcCondition )
		/*
		str = "Ring Programming Languge"
		StzStringQ(str).WalkForeward( :StartingAt = 6, :UntilBefore = '{ @char = "r" }' )

		--> Returns 9
		*/

		cResult = ""
		bStopWalking = FALSE
		nCurrentPosition = paStartingAt[2] + 1

		while NOT bStopWalking
			nCurrentPosition++
			if nCurrentPosition = This.NumberOfChars()
				exit
			ok

			@char = This[ nCurrentPosition ]
			@i = nCurrentPosition

			cCondition = StzStringQ(pcCondition[2]).SimplifyQ().RemoveBoundsQ("{","}").Content()

			cCode = "if " + cCondition + NL +
				TAB + "exit" + NL +
			"ok"

			eval(cCode)			
		end

		if nCurrentPosition = This.NumberOfChars()
			nResult = 0
		else
			nResult = nCurrentPosition-1
		ok

		return nResult

	  #-----------------------------------#
	 #     TURNING STRING UP OR DOWN     #
	#-----------------------------------#

	def Invert()
		/*
		Example:
		? StzStringQ("LIFE").Inverted()
		# --> ƎℲI⅂
		*/

		# Applies to latin script only

		if NOT This.ToStzText().ScriptIs(:Latin)
			return This.String()
		ok

		cResult = ""

		aStzChars = This.ToListOfStzChars()

		for i = This.NumberOfChars() to 1 step -1
			cTurned = aStzChars[i].Inverted()
			cResult += cTurned
		next

		This.Update( cResult )

		def InvertQ()
			This.Invert()
			return This

	def Inverted()
		return This.Copy().InvertQ().Content()

	  #----------------------------------------------------#
	 #     COMPRESSING THE STRING WITH A BINARY SCHEMA    #
	#----------------------------------------------------#

	// Example : ABCDEFGH > 10011011 => ADEGH
	def CompressUsingBinary(cBinary)

		oBinary = new stzString(cBinary)
		if NOT oBinary.IsMadeOf(["0", "1"])
			stzRaise(stzStringError(:CanNotCompressStringUsingBinary))
		ok

		cCompressed = ""

		for i=1 to len(cBinary)
			if cBinary[i] = "1" and i <= This.NumberOfChars()					
				cCompressed += This[i]
			ok
		next
			
		if This.NumberOfChars() > len(cBinary)
			for i = len(cBinary)+1 to This.NumberOfChars()
				cCompressed += This[i] 
			next
		ok

		This.Update( cCompressed )

		#< @FunctionFluentForm

		def CompressUsingBinaryQ(cBinary)
			This.CompressUsingBinary(cBinary)
			return This

		#>

	  #--------------------------------------------------------------#
	 #    CHECKING IF THE STRING CORRESPONDS TO A STZ CLASS NAME    #
	#--------------------------------------------------------------#

	def IsStzClassName()
		bResult = This.LowercaseQ().ExistsIn( StzClasses() )
		return bResult

	  #---------------------------------#
	 #    CHECKING A LIST IN STRING    #
	#---------------------------------#
	/*
	EXAMPLE

	o1 = new stzString('[ "A","B", "C", "D" ]')
	? o1.IsListInString() #--> TRUE
	
	o1 = new stzString(' "A":"D" ')
	? o1.IsListInString() #--> TRUE
	
	o1 = new stzString('[ "ا", "ب", "ج" ]')
	? o1.IsListInString() #--> TRUE
	
	o1 = new stzString(' "ا":"ج": ')
	? o1.IsListInString() #--> TRUE
	*/

	def IsListInString()

		# A list can not be written with less then 2 chars ('[]')

		if This.SimplifyQ().NumberOfChars() < 2
			return FALSE
		ok

		bResult = FALSE

		# Case 1 : The list is in normal [_,_,_] fprm

		if This.SimplifyQ().IsBoundedBy("[","]") and
			This.Contains(",")

			cCode = "aTempList = " + This.String()
			eval(cCode)

			bResult = isList(aTempList)

		else

		# Case 2 : The list is in short _:_ form

			if This.ContainsOneOccurrence(:of = ":")

				# the : separator in _:_ can not be at the
				# beginning or the end of the list in string

				n = This.FindFirst(":")
				if NOT ( n > 1 and n < This.NumberOfChars() )

					bResult = FALSE

				ok

				# The list is in short form, let's analyze it
				# and tranform it to a normal syntax

				aListMembers = This.Split( :Using = ":" )
					
				cMember1 = aListMembers[1]
				cMember2 = aListMembers[2]
		
				cCode = "pMember1 = " + cMember1
				eval(cCode)
		
				cCode = "pMember2 = " + cMember2
				eval(cCode)
		
				cNormalSyntax = "[ "
	
				if ( isString(pMember1) and StringIsChar(pMember1) ) and
				   ( isString(pMember2) and StringIsChar(pMember2) )
						
					n1 = CharUnicode(pMember1)
					n2 = CharUnicode(pMember2)
		
					if n1 <= n2
						for n = n1 to n2
							cNormalSyntax += '"' + StzCharQ(n).Content() + '"'
							if n < n2
								cNormalSyntax += ", "
							ok
						next
		
					but n1 > n2
						for n = n1 to n2 step -1
							cNormalSyntax += '"' + StzCharQ(n).Content() + '"'
							if n > n2
								cNormalSyntax += ", "
							ok
						next
					ok
		
					cNormalSyntax += " ]"
		
				but isNumber(pMember1) and isNumber(pMember2)

					n1 = pMember1
					n2 = pMember2
		
					if n1 <= n2

						for n = n1 to n2
							cNormalSyntax += (""+ n)
							if n < n2
								cNormalSyntax += ", "
							ok
						next
		
					but n1 > n2

						for n = n1 to n2 stzp -1
							cNormalSyntax += (""+ n)
							if n > n2
								cNormalSyntax += ", "
							ok
						next
		
					ok
		
					cNormalSyntax += " ]"
				ok

				cCode = "aTempList = " + cNormalSyntax
				eval(cCode)

				bResult = isList(aTempList)

			ok  
		ok

		return bResult

	def IsListInNormalForm()
		if NOT This.IsListInString()
			return FALSE
		ok

		if This.SimplifyQ().IsBoundedBy("[","]")
			return TRUE
		else
			return FALSE
		ok

	def IsListInShortForm()
		if This.IsListInString() and
		   NOT This.IsListInNormalForm()

			return TRUE
		else
			return FALSE
		ok

	  #--------------------------------------------#
	 #    CHECKING A CONTIGUOUS LIST IN STRING    #
	#--------------------------------------------#

	def IsContiguousListInString()

		cCode = "aTempList = " + This.ToListInNormalForm()
		eval(cCode)
		bResult = StzListQ(aTempList).IsContiguous()

		return bResult

		def IsContinuousListInString()
			return This.IsContiguousListInString()

	def IsContiguousListInNormalForm()
	
		if This.IsContiguousListInString() and
		   This.IsListInNormalForm()
		  
			return TRUE
		else
			return FALSE
		ok

		def IsContinuousListInNormalForm()
			return This.IsContiguousListInNormalForm()

	def IsContiguousListInShortForm()

		if This.IsContiguousListInString() and
		   This.IsListInShortForm()
		   
			return TRUE
		else
			return FALSE
		ok

		def IsContinuousListInShortForm()
			return This.IsContiguousListInShortForm()

	  #---------------------------------------------------------------#
	 #   CPNVERTING CONTINUOUS LISTS BETWEEN NORMAL AND SHORT FORMS   #
	#---------------------------------------------------------------#

	def ToListInShortForm()
	
		if NOT This.IsContiguousListInString()
			stzRaise([
				:Where = "stzString (16140) > ToStringListInShortForm()",
				:What  = "Can't convert the list in string to short form!",
				:Why   = "The list in string is not contiguous list."
			])
		ok

		cResult = ""

		if This.IsListInShortForm()
			cResult  =  This.Copy().
					RemoveSpacesQ().
					ReplaceQ(":", " : ").
					Content()

		but This.IsListInNormalForm()

			cCode = "aTempList = " + This.String()
			eval(cCode)

			if StzListQ(aTempList).IsContiguous()

				acMembers = This.SimplifyQ().
						RemoveBoundsQ("[","]").
						SplitQ(",").
						FirstAndLastItems()
						
				cMember1 = StzStringQ(acMembers[1]).Simplified()
				cMember2 = StzStringQ(acMembers[len(acMembers)]).Simplified()

				cResult = cMember1 + " : " + cMember2

			else
				cResult = This.Simplified()
			ok
		ok

		return cResult

	def ToListInNormalForm()

		If NOT This.IsListInString()
			stzRaise([
				:Where = "stzString (16182) > ToStringListInNormalForm()",
				:What  = "Can't convert the string to short form list!",
				:Why   = "The string is not a list in string."
			])
		ok

		if This.IsListInNormalForm()
			cResult = This.Simplified()

		but This.IsListInShortForm()

			# The list is in short form, let's analyze it
			# and tranform it to a normal syntax

			aListMembers = This.Split( :Using = ":" )
					
			cMember1 = aListMembers[1]
			cMember2 = aListMembers[2]
		
			cCode = "pMember1 = " + cMember1
			eval(cCode)
		
			cCode = "pMember2 = " + cMember2
			eval(cCode)
	
			cNormalSyntax = "[ "
	
			if ( isString(pMember1) and StringIsChar(pMember1) ) and
			   ( isString(pMember2) and StringIsChar(pMember2) )
						
				n1 = CharUnicode(pMember1)
				n2 = CharUnicode(pMember2)
		
				if n1 <= n2
					for n = n1 to n2
						cNormalSyntax += '"' + StzCharQ(n).Content() + '"'
						if n < n2
							cNormalSyntax += ", "
						ok
					next
		
				but n1 > n2
					for n = n1 to n2 step -1
						cNormalSyntax += '"' + StzCharQ(n).Content() + '"'
						if n > n2
							cNormalSyntax += ", "
						ok
					next
				ok
		
				cNormalSyntax += " ]"
		
			but isNumber(pMember1) and isNumber(pMember2)

				n1 = pMember1
				n2 = pMember2
		
				if n1 <= n2

					for n = n1 to n2
						cNormalSyntax += (""+ n)
						if n < n2
							cNormalSyntax += ", "
						ok
					next
		
				but n1 > n2

					for n = n1 to n2 stzp -1
						cNormalSyntax += (""+ n)
						if n > n2
							cNormalSyntax += ", "
						ok
					next
		
				ok
		
				cNormalSyntax += " ]"
			ok

			cResult = cNormalSyntax

		ok  

		return cResult

	def ToListInstring()
		return This.ToListInNormalForm()

	def ToListInString@C()
		return This.ToListInShortForm()

	def ToList()
		if NOT This.IsListInString()
			stzRaise("Can't evaluate the list in string!")
		ok

		cCode = "aResult = " + This.ToListInNormalForm()
		eval(cCode)

		return aResult

	  #----------------------------#
	 #  OPERATORS OVERLOADING     #
	#----------------------------#

	/*
		TODO: Operators should carry same semantics in all classes...
	*/

	def operator(pOp,pValue)

		// string access : str[n]
		// string search : str[substr]

		if pOp = "[]"
			
			if isString(pValue)
				if pValue = :First or pValue = :FirsChar
					pValue = 1

				but pValue = :Last or pValue = :LastChar
					pValue = This.NumberOfChars()
				ok
			ok

			if isNumber(pValue)
			   
				return This.NthChar(pValue)
							
			but isString(pValue)
				if StzStringQ(pValue).SimplifyQ().IsBoundedBy("{","}")
					pcCondition = StzStringQ(pValue).SimplifyQ().BoundsRemoved("{","}")
					anResult = []

					@char = ""
					for i = 1 to This.NumberOfChars()
						@char = This[i]
						cCode = 'if ( ' + pcCondition + ' )' + NL +
							'	anResult + i' + NL +
							'ok'
						eval(cCode)
					next

					return anResult
				else
					return This.FindAll(pValue)
				ok	
			ok
				// Add an item at the beginning of the list
		but pOp = "<<"
			This.Prepend(1)

		// Add an item at the end of the list
		but pOp = ">>"
			This.Append(value)

		// compare equality : oString = str

		but pOp = "="
			return This.IsEqualTo(value)

		// Compare strict equality (case-sensitive)

		but pOp = "=="
			return This.IsStrictlyEqualTo(value)
	
		// oString < str

		but pOp = "<"
			return This.IsStrictlyLessThan(pValue)

		but pOp = "<="
			return This.IsLessThan(pValue)
		
		// compare : oString > str

		but pOp = ">"
			return This.IsStrictlyGreaterThan(pValue)

		but pOp = ">="
			return This.IsGreaterThan(pValue)
	
		// add : string + string | string + ListOfStrings

		but pOp = "+"
			if type(pValue) = "STRING"
				This.Append(pValue)
				return This
		
			but StzListQ(pValue).IsListOfStrings()
				This.InsertListOfSubstrings(pValue)
				return This	
			ok

		// Multiply: string * n | string * string | string * list
	
		but pOp = "*"
			This.MultiplyBy(pValue)
			return This

		// Split: String / n  | String / str	| String / list

		but pOp = "/"
			if isString(pValue)
				return This.SplitForward(pValue)

			but isNumber(pValue)
				return This.SplitToNParts(pValue)

			but ListIsListOfStrings(pValue)
				acResult = []
				acSplits = This.SplitToNParts( len(pValue) )
				
				i = 0
				for str in pValue
					i++
					acResult + [ str, acSplits[i] ]
				next
					
				return acResult
			ok
					
		// String % n : returns the rest of letters after dividing String / n

		but pOp = "%"
			cResult = NULL

			if type(pValue) = "NUMBER"	
				aParts = []
		
				nParts = ceil( This.NumberOfChars() / pValue )
				for i=1 to This.NumberOfChars() step nParts
					cTemp = @oQString.mid(i-1,nParts)
					aParts + cTemp	
				next
		
				if len(aParts) < pValue
					for i = len(aParts) to pValue-1
						aParts + "_"
					next
				ok
		
				if aParts[len(aParts)] != "_"
					return aParts[len(aParts)]
				ok
			ok

			return cResult
		
		// string - string | string - .25 | string - 3
		but pOp = "-"
			cResult = NULL
						
			if isString(pValue)
				This.RemoveAllQ(pValue)
				return This
			ok
		
			if isNumber(pValue)
				if pValue < This.NumberOfChars()
					if pValue > 0 and pValue < 1 // str - 0.5
						// Eats a portion of the string (half: 0.5, quarter0.25,...)
						n = floor( This.NumberOfChars() * pValue)
						cResult = This.Section( 1, This.NumberOfChars() - n ) // @oQString.mid(0,nLenStr-n)
					else
						cResult = This.Section(1, This.NumberOfChars() - pValue )
					ok		
				ok

				This.Update( cResult )
				return This
			ok

			if StzListQ(pValue).IsListOfStrings()
				for item in pValue
					This.RemoveAll(item)
				next
				return This
			ok

			if StzListQ(pValue).IsListOfLists() and len(pValue) = 1
				/*
				Example:

				o1 = new stzString("XRingorialand")
				o1 - [[ :FirstCharIf, :EqualTo, :X ]]

				Gives -> "Ringorialand"

				NB: We use the two brackets here to differenciate
				the syntax with:

					 o1 - [ "X", "oria", "land" ] --> "Ring"

				which means : remove this ist of substrings from
				the main string
				*/

				aListOfConditions = [
					:EqualTo, :LesserThan, :GreaterThan,
					:LesserThanOrEqual, :GreaterThanOrEqual,
					:DifferentThan ]

				cFirstOrLast = pValue[1][1]
		 		cCondition = pValue[1][2]
				value = pValue[1][3]

				oCondition = new stzString(cCondition)

				if NOT ( len(pValue[1]) = 3 AND
				   (cFirstOrLast = :FirstCharIf or cFirstOrLast = :LastCharIf) AND
				   oCondition.ExistsInList(aListOfConditions) AND
				   isString(value) )

					stzRaise(stzStringError(:UnsupportedExpressionInOverloadedMinusOperator))
				ok
					
				if cFirstOrLast = :FirstCharIf

					if cCondition = :EqualTo
						if IsNumberOrString(value)
							if This.FirstChar() = value
								This.RemoveFirstChar()
								return This
							ok
						ok

						if StzListQ(value).IsListOfStrings()
							oList = value
							if oList.IsEqualTo(cFirstOrLast)
								This.RemoveMany(value)
								return This
							ok
						ok

					but cCondition = :LesserThan
						stzRaise(:UnsupportedFeatureInThisVersion)

					but cCondition = :GreaterThan
						stzRaise(:UnsupportedFeatureInThisVersion)

					but cCondition = :LesserOrEqualThan
						stzRaise(:UnsupportedFeatureInThisVersion)

					but cCondition = :GreaterOrEqualThan
						stzRaise(:UnsupportedFeatureInThisVersion)
					
					but cCondition = :DifferentThan
						stzRaise(:UnsupportedFeatureInThisVersion)
					ok

				but cFirstOrLast = :LastCharIf

					if cCondition = :EqualTo
						if StringIsChar(value) and This.LastChar() = value
							This.RemoveNthChar(This.NumberOfChars())
							return This
						ok

						if ListIsListOfChars(value)
							oList = value
							if value.IsEqualTo(cFirstOrLast)
								This.RemoveMany(value)
								return This
							ok
							
						ok

					but cCondition = :LesserThan
						stzRaise(:UnsupportedFeatureInThisVersion)

					but cCondition = :GreaterThan
						stzRaise(:UnsupportedFeatureInThisVersion)

					but cCondition = :LesserOrEqualThan
						stzRaise(:UnsupportedFeatureInThisVersion)

					but cCondition = :GreaterOrEqualThan
						stzRaise(:UnsupportedFeatureInThisVersion)
					
					but cCondition = :DifferentThan
						stzRaise(:UnsupportedFeatureInThisVersion)
					ok

				ok

			ok
		ok // --- End of operator overloading section

	  #--------------------------------#
	 #     USED FOR NATURAL-CODING    #
	#--------------------------------#

	def IsAlmostAFunctionCall()
		# Why almost? Because it doesn't analyse the correctness of the params
		# which we should do in the future, but this is sufficient for our
		# actual needs in stzChainOfTruth and other classes of natural-coding

		# PS: if you you don't like sutch a precison, use the alternative name
		# IsFunctionCall() instead.

		if This.NumberOfOccurrence("(") = 1 and
		   This.NumberOfOccurrence(")") = 1 and
		   This.FindFirst("(") > 1 and
		   This.FindFirst("(") < This.FindFirst(")") and
		   This.LastChar() = ")" // and # TODO: complete this and remove "Almost" from the function name!
		   //This.SectionQ(1,  This.FindFirst("(") - 1).ContainsOnly(:CompterCodeChars)
		
			return TRUE
		else
			return FALSE
		ok

		#< FunctionAlternativeForms >

		def IsFunctionCall()
			return This.IsAlmostAFunctionCall()
		#>

	def IsAMethodOfThisObject(pObject)
		return This.String().ExistsIn( classes(pObject) )

		def IsMethodOfObject(pObject)
			return IsAMethodOfThisObject(pObject)

	def IsAnAttributeOfThisObject(pObject)
		return This.String().ExistsIn( attributes(pObject) )

		def IsAttributeOfObject(pObject)
			return IsAnAttributeOfThisObject(pObject)		 


	#-----------------

	def DataType()
		return :String

	#--- ITEM

	def IsItem()
		return TRUE

	def IsItemOf(paList)
		return StzListQ(paList).Contains(This.Content())
	
		def AsAnItemOf(paList)
			return This.IsItemOf(paList)
	
	def IsItemIn(paList)
		return This.IsItemOf(paList)
	
		def IsAnItemIn(paList)
			return This.IsItemOf(paList)

	# 
	def IsMember()
		return TRUE

	def IsMemberOf(paList)
		return StzListQ(paList).Contains(This.Content())
	
		def AsAMemberOf(paList)
			return This.IsMemberOf(paList)
	
	def IsMemberIn(paList)
		return This.IsMemberOf(paList)
	
		def IsAMemberIn(paList)
			return This.IsMemberOf(paList)

	#--- NUMBER

	def IsANumber()
		return FALSE

	def IsNumberOf(paList)
		return FALSE

		def IsANumberOf(paList)
			return FALSE
	
	def IsNumberIn(paList)
		return FALSE
	
		def IsANumberIn(paList)
			return FALSE

	#--- STRING

	def IsAString()
		return TRUE

	def IsALetter()
		return This.IsLetter()

	def IsLetterOf(pStrOrListOfChars)
		if isString(pStrOrListOfChars)
			if This.IsLetter()
				return StzCharQ(This.Content()).IsLetterOf(pStrOrListOfChars)
			else
				return FALSE
			ok

		but isList(pStrOrListOfChars)
			if This.IsLetter()
				return StzListQ(pStrOrListOfChars).Contains(This.Content())
			else
				return FALSE
			ok
		ok

		def IsALetterOf(pcStr)
			return This.IsLetterOf(pcStr)
	
	def IsLetterIn(pcStr)
		return This.IsLetterOf(pcStr)

		def IsALetterIn(pcStr)
			return This.IsLetterOf(pcStr)

	def IsCharOf(pStrOrListOfChars)
		if isString(pStrOrListOfChars)
			if This.IsChar()
				return StzCharQ(This.Content()).IsCharOf(pStrOrListOfChars)
			else
				return FALSE
			ok

		but isList(pStrOrListOfChars)
			if This.IsChar()
				return StzListQ(pStrOrListOfChars).Contains(This.Content())
			else
				return FALSE
			ok
		ok

		def IsACharOf(pcStr)
			return This.IsLetterOf(pcStr)

	def IsCharIn(pcStr)
		return This.IsLetterOf(pcStr)

		def IsACharIn(pcStr)
			return This.IsLetterOf(pcStr)

	def IsCharName()
		cStr = This.String()
		oUnicodeStr = new stzString( UnicodeNamesInString() )
		n = oUnicodeStr.FindFirstCS(cStr, :CS = FALSE)

		if n > 0
			return TRUE
		else
			return FALSE
		ok

	def Stringify()
		return This.String()

		def Stringified()
			return This.Stringify()
	  #-----------#
	 #   MISC.   #
	#-----------#
		
	def HasSameTypeAs(p)
		return isString(p)

	def IsAnagramOf(pcOtherString)
		oTheseChars = This.Chars().ToSetQR(:stzList).SortInAscendingQ()
		cOtherChars = StzStringQ( pcOtherString ).CharsQ().SortInAscendingQ().ToSetQR( :stzList ).Content()
	
		bResult = StzListQ( oTheseChars ).IsEqualTo( cOtherChars )

		return bResult

	def UpTo(pcChar)
		if This.IsChar() and ( isString(pcChar) and StzStringQ(pcChar).IsChar() ) and
		   This.Unicode() < CharUnicode(pcChar)

			acResult = []
			for n = This.Unicode() to CharUnicode(pcChar)
				acResult + StzCharQ(n).Content()
			next
			return acResult
		ok

	def DownTo(pcChar)
		if This.IsChar() and ( isString(pcChar) and StzStringQ(pcChar).IsChar() ) and
		   This.Unicode() > CharUnicode(pcChar)

			acResult = []
			for n = This.Unicode() to CharUnicode(pcChar) step -1 
				acResult + StzCharQ(n).Content()
			next

			return acResult
		ok

	def FirstAndLastChars()
		aResult = [ This.FirstChar(), This.LastChar() ]
		return aResult

	def LastAndFirstChars()
		aResult = [ This.LastChar(), FirstChar() ]
		return aResult

