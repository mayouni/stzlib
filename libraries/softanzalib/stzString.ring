
# 		    SOFTANZA LIBRARY (V1.0) - STZSTRING
#		An accelerative library for Ring applications

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
	return StzStringQ(cStr).Invert()
	
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
	return Q(pcStr).StringCase()


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
			return :Lowercase

		but This.IsUppercase()
			return :Uppercase

		but This.IsCapitalcase()
			return :Capitalcase

		but This.IsTitlecase()
			return :Titlecase

		but This.IsFoldercase()
			return :Foldercase

		else
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
		return ActiveLocale().StringIsCapitalcased(This.String())

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

	  #-------------------#
	 #      LETTERS      #
	#-------------------#

	// Returns only the letters contained in the string
	def Letters()
		# t0 = clock() // Takes nearly half a second (0.60s)

		aResult = []

		for i = 1 to this.NumberOfChars()

			if StzCharQ(This.NthChar(i)).IsLetter()
				cLetter = This.NthChar(i)

				if i > 1
					if This.NthChar(i) = ArabicShaddah()
						cLetter = This.NthChar(i-1)
					
					ok
				ok

				aResult + cLetter
			
			but StzCharQ(This.NthChar(i)).IsArabic7arakah()

				if i > 1
					aResult[ i - 1 ] =  aResult[ i - 1 ] + This.NthChar(i)
				ok
			ok

		next

		# In fact, arabic shaddah is a letter (and so isLetter()
		# should return TRUE), but the shaddah should'nt appear in
		# the list of letters as sutch ("ّ ") but as the letter that
		# comes right before it!

		# ? ( clock() - t0 ) / clockspersecond()

		return aResult

		#< @FunctionFluentForm

		def LettersQ()
			return new stzListOfChars( This.Letters() )

		#>

	def ToSetOfLetters()
		return StzListQ( This.Letters() ).ToSet()

		#< @FunctionAlterativeNames

		def UniqueLetters()
			return This.ToSetOfLetters()
	
			#< @FunctionFluentForm

			def UniqueLettersQ()
				return new stzListOfChars( This.UniqueLetters() )

			def UniqueLettersQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcReturnType
				on :stzListOfChars
					return new stzListOfChars( This.UniqueLetters() )
		
				on :stzListOfStrings
					return new stzListOfStrings( This.UniqueLetters() )
		
				on :stzList
					return new stzList( This.UniqueLetters() )
		
				off
			#>
		#>

	  #-----------------#
	 #      LINES      #
	#-----------------#

	def Lines()
		return This.Split(NL)

		#< @FunctionFluentForm

		def LinesQ()
			return new stzListOfStrings( This.Lines() )

		#>
	
	def NumberOfLines()
		return len(This.Lines())

	  #----------------#
	 #    MARQUERS    #
	#----------------#

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
						cMarquer = StzStringQ(cMarquer).Section(2, :End)
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

		return This.SectionQ(pnStartingAt, :End).Marquers()

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

		oStr = This.SectionQ(pnStartingAt, :End)
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

		oStr = This.SectionQ(pnStartingAt, :End)

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

		def ToSetOfCharsQR(pcType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcType

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
	 #   REMOVING N FIRST CHARS   #
	#============================#

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

	def RemoveFirstChar()
		This.RemoveNFirstChars(1)

		def RemoveFirstCharQ()
			This.RemoveFirstChar()
			return This

	def FirstCharRemoved()
		cResult = This.Copy().RemoveFirstCharQ().Content()
		return cResult

	def RemoveLeadingChar(c)
		This.RemoveFirstChar()

		def RemoveLeadingCharQ(c)
			This.RemoveLeadingChar(c)
			return This

	def LeadingCharRemoved(c)
		cResult = This.copy().RemoveLeadingCharQ(c).Content()
		return cResult

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

	def RemoveLastChar()
		This.RemoveNLastChars(1)

		def RemoveLastCharQ()
			This.RemoveLastChar()
			return This

	def LastCharRemoved()
		cResult = This.Copy().RemoveLastCharQ().Content()
		return cResult

	def RemoveTrailingChar(c)
		This.RemoveLastChar()

		def RemoveTrailingCharQ(c)
			This.RemoveTrailingChar(c)
			return This

	def TrailingCharRemoved(c)
		cResult = This.copy().RemoveTrailingCharQ(c).Content()
		return cResult

	  #---------------------------#
	 #   REMOVING N LEFT CHARS   #
	#---------------------------#

	def RemoveNLeftChars(n)
		if This.IsLeftToRight()
			This.RemoveSection( 1, n )

		else
			This.RemoveSection( This.NumberOfChars() - n + 1, :End )
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

	def RemoveLeftChar()
		This.RemoveNLeftChars(1)

		def RemoveLeftCharQ()
			This.RemoveLeftChar()
			return This

	def LeftCharRemoved()
		cResult = This.Copy().RemoveLeftCharQ().Content()
		return cResult

	  #----------------------------#
	 #   REMOVING N RIGHT CHARS   #
	#----------------------------#

	def RemoveNRightChars(n)
		if This.IsRightToLeft()
			This.RemoveSection( 1, n)
		else
			This.RemoveSection( This.NumberOfChars() - n + 1, :End )
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

	def RemoveRightChar()
		This.RemoveNRightChars(1)

		def RemoveRightCharQ()
			This.RemoveRightChar()
			return This

	def RightCharRemoved()
		cResult = This.Copy().RemoveRightCharQ().Content()
		return cResult

	  #----------------------------#
	 #   REPEATED LEADING CHARS   #
	#----------------------------#

	def HasRepeatedLeadingChars()
		if This.RepeatedLeadingChars() != NULL
			return TRUE
		else
			return FALSE
		ok

		def HasLeadingRepeatedChars()
			return This.HasRepeatedLeadingChars()

		def HasLeadingChars()
			return This.HasRepeatedLeadingChars()
	
	def HasRepeatedTrailingChars()
		if This.RepeatedTrailingChars() != NULL
			return TRUE
		else
			return FALSE
		ok

		def HasTrailingRepeatedChars()
			return This.HasRepeatedTrailingChars()

		def HasTrailingChars()
			return This.HasRepeatedTrailingChars()
	
	def RepeatedLeadingChars()
		/* Example:
			    'eeeTUNIS' 	--> 'eee'
			'exeeeeeTUNIS' 	--> ''
		*/

		if NOT This.IsEmpty()
			cResult = ""
	
			i = 1
			while This[i] = This[1] and i <= This.NumberOfChars()
				i++
			end

			if i > 2
				return This.NFirstChars(i-1)
			ok
		ok

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
		if This.HasRepeatedLeadingChars()
			return This[1]
		ok

		def RepeatedLeadingCharQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzChar
				return new stzChar(This.RepeatedLeadingChar())
			on :stzString
				return new stzString(This.RepeatedLeadingChar())
			other
				stzRaise("Unsupported returned type!")
			off

		def RepeatedLeadingCharQ()
			return This.RepeatedLeadingCharQR(:stzChar)
	
		def LeadingRepeatedChar()
			return This.RepeatedLeadingChar()

			def LeadingRepeatedCharQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.RepeatedLeadingCharQR(pcReturnType)

			def LeadingRepeatedCharQ()
				return This.LeadingRepeatedCharQR(:stzChar)
	
		def LeadingChar()
			return This.RepeatedLeadingChar()

			def LeadingCharQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.RepeatedLeadingCharQR(pcReturnType)

			def LeadingCharQ()
				return This.LeadingCharQR(:stzChar)
	
	def NumberOfRepeatedLeadingChars()
		if This.HasRepeatedLeadingChars()
			return StzStringQ( This.RepeatedLeadingChars() ).NumberOfChars()
		else
			return 0
		ok

		def NumberOfLeadingRepeatedChars()
			return This.NumberOfRepeatedLeadingChars()

		def NumberOfLeadingChars()
			return This.NumberOfRepeatedLeadingChars()
	
	def RepeatedLeadingCharIs(c)
		if This.HasRepeatedLeadingChars() and This.FirstChar() = c
			return TRUE
		else
			return FALSE
		ok

		def LeadingRepeatedCharIs(c)
			return This.RepeatedLeadingCharIs(c)

		def LeadingCharIs(c)
			return This.RepeatedLeadingCharIs(c)
	
	  #-----------------------------#
	 #   REPEATED TRAILING CHARS   #
	#-----------------------------#

	def RepeatedTrailingChar()
		if This.HasRepeatedTrailingChars()
			return This.LastChar()
		ok

		def RepeatedTrailingCharQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzChar
				return new stzChar(This.RepeatedTrailingChar())
			on :stzString
				return new stzString(This.RepeatedTrailingChar())
			other
				stzRaise("Unsupported returned type!")
			off

		def RepeatedTrailingCharQ()
			return This.RepeatedTrailingCharQR(:stzChar)

		def TrailingRepeadtedChar()
			return This.RepeatedTrailingChar()

			def TrailingRepeatedCharQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.RepeatedTrailingCharQR(pcReturType)

			def TrailingRepeatedCharQ()
				return This.RepeatedTrailingCharQR(:stzChar)

		def TrailingChar()
			return This.RepeatedTrailingChar()

			def TrailingCharQR(pcReturnType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				return This.RepeatedTrailingCharQR(pcReturnType)

			def TrailingCharQ()
				return This.RepeatedTrailingCharQR(:stzChar)
	
	def RepeatedTrailingChars()
		cResult = This.Copy().ReverseCharsQ().RepeatedLeadingChars()
		return cResult

		def RepeatedTrailingCharsQ()
			return new stzString(This.RepeatedTrailingChars())
	
		def TrailingRepeatedChars()
			return This.RepeatedTrailingChars()

			def TrailingRepeatedCharsQ()
				return new stzString(This.TrailingRepeatedChars())
	
		def TrailingChars()
			return This.RepeatedTrailingChars()

			def TrailingCharsQ()
				return This.return new stzString(This.TrailingChars())

	def NumberOfRepeatedTrailingChars()
		if This.HasRepeatedTrailingChars()
			return StzStringQ( This.RepeatedTrailingChars() ).NumberOfChars()
		else
			return 0
		ok

		def NumberOfTrailingRepeatedChars()
			return This.NumberOfRepeatedTrailingChars()

		def NumberOfTrailingChars()
			return This.NumberOfRepeatedTrailingChars()
	
	def RepeatedTrailingCharIs(c)
		if This.HasRepeatedLeadingChars() and This.LastChar() = c
			return TRUE
		else
			return FALSE
		ok

		def TrailingRepeatedCharIs(c)
			return This.RepeatedTrailingCharIs(c)

		def TrailingCharIs(c)
			return This.RepeatedTrailingCharIs(c)
	
	  #-------------------------------------#
	 #   REMOVING REPEATED LEADING CHARS   #
	#-------------------------------------#

	def RemoveRepeatedLeadingChars()
		if This.HasRepeatedLeadingChars()
			This.RemoveFirstNChars( This.NumberOfRepeatedLeadingChars() )
		ok

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
	
	def RemoveRepeatedLeadingChar(c)
		if This.RepeatedLeadingChar() = c
			return This.RemoveRepeatedLeadingChars()
		ok

		def RemoveRepeatedLeadingCharQ(c)
			This.RemoveRepeatedLeadingChar(c)
			return This

		def RemoveLeadingRepeatedChar(c)
			This.RemoveRepeatedLeadingChar(c)

			def RemoveLeadingRepeatedCharQ(c)
				This.RemoveLeadingRepeatedChar(c)
				return This
	
	def RepeatedLeadingCharRemoved(c)
		cResult = This.Copy().RemoveRepeatedLeadingCharQ(c).Content()
		return cResult

		def LeadingRepeatedCharRemoved(c)
			return This.RepeatedLeadingCharRemoved(c)

	  #--------------------------------------#
	 #   REMOVING REPEATED TRAILING CHARS   #
	#--------------------------------------#

	def RemoveRepeatedTrailingChars()
		if This.HasRepeatedTrailingChars()
			This.RemoveLastNChars( This.NumberOfRepeatedTrailingChars() )
		ok

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
			This.RepeatedTrailingCharsRemoved()

		def TrailingCharsRemoved()
			This.RepeatedTrailingCharsRemoved()
	
	def RemoveRepeatedTrailingChar(c)
		if This.RepeatedTrailingChar() = c
			This.RemoveRepeatedTrailingChars()
		ok

		def RemoveRepeatedTrailingCharQ(c)
			This.RemoveRepeatedTrailingChar(c)
			return This
	
		def RemoveTrailingRepeatedChar(c)
			This.RemoveRepeatedTrailingChar(c)

			def RemoveTrailingRepeatedCharQ(c)
				This.RemoveTrailingRepeatedChar(c)
				return This
	
	def RepeatedTrailingCharRemoved(c)
		cResult = This.Copy().RemoveRepeatedTrailingCharQ(c).Content()
		return cResult

		def TrailingRepeatedCharRemoved(c)
			return This.RepeatedTrailingCharRemoved(c)

	  #--------------------------------------------------#
	 #   REMOVING REPEATED LEADING AND TRAILING CHARS   #
	#--------------------------------------------------#

	def RemoveRepeatedLeadingCharAndTrailingChar(c1, c2)
		This.RemoveRepeatedLeadingChar(c1)
		This.RemoveRepeatedTrailingChar(c2)

		def RemoveRepeatedLeadingcharAndTrailingCharQ(c1, c2)
			This.RemoveRepeatedLeadingCharAndTrailingChar(c1, c2)
			return This

		def RemoveLeadingCharAndTrailingChar(c1, c2)
			This.RemoveRepeatedLeadingCharAndTrailingChar(c1, c2)

			def RemoveLeadingCharAndTrailingCharQ(c1, c2)
				This.RemoveLeadingCharAndTrailingChar(c1, c2)
				return This
	
		def RemoveTrailingCharAndLeadingChar(c1, c2)
			This.RemoveRepeatedLeadingCharAndTrailingChar(c1, c2)

			def RemoveTrailingCharAndLeadingCharQ(c1, c2)
				This.RemoveTrailingCharAndLeadingChar(c1, c2)
				return This
	
	def RepeatedLeadingCharAndTrailingCharRemoved(c1, c2)
		cResult = This.Copy().RemoveRepeatedLeadingCharAndTrailingCharQ(c1, C2).Content()
		return cResult

		def RepeatedTrailingCharAndLeadingCharRemoved(c1, c2)
			return This.RepeatedLeadingCharAndTrailingCharRemoved(c1, c2)

		def LeadingCharAndTrailingCharRemoved(c1, c2)
			return This.RepeatedLeadingCharAndTrailingCharRemoved(c1, c2)

		def TrailingCharAndLeadingCharRemoved(c1, c2)
			return This.RepeatedLeadingCharAndTrailingCharRemoved(c1, c2)
	
	def RemoveRepeatedLeadingAndTrailingChars()
		This.RemoveRepeatedLeadingChars()
		This.RemoveRepeatedTrailingChars()

		def RemoveRepeatedLeadingAndTrailingCharsQ()
			This.RemoveRepeatedLeadingAndTrailingChars()
			return This
	
		def RemoveLeadingAndTrailingRepeatedChars()
			This.RemoveRepeatedLeadingAndTrailingChars()

			def RemoveLeadingAndTrailingRepeatedCharsQ()
				This.RemoveLeadingAndTrailingRepeatedChars()
				return This
	
	def RepeadtedLeadingAndTrailingCharsRemoved()
		cResult = This.Copy().RemoveRepeatedLEadingAndTrailingChars()
		return cResult

		def RepeadtedTrailingAndLeadingCharsRemoved()
			return This.RepeadtedLeadingAndTrailingCharsRemoved()

		def LeadingAndTrailingCharsRemoved()
			return This.RepeadtedLeadingAndTrailingCharsRemoved()

		def TrailingAndLeadingCharsRemoved()
			return This.RepeadtedLeadingAndTrailingCharsRemoved()
	
	  #-----------------------------#
	 #   REPLACING LEADING CHARS   #
	#-----------------------------#

	def ReplaceRepeatedLeadingCharWith(c)
		/* Example:

		StzStringQ("___VAR---").ReplaceRepeatedLeadingCharWith("-")

		--> Gives: "---VAR---"
		*/

		if This.HasRepeatedLeadingChars()
			n = This.NumberOfRepeatedLeadingChars()

			This.ReplaceSection(
				1, n,
				StzStringQ(c).RepeatNTimesQ(n).Content()
			)
		ok

		def ReplaceRepeatedLeadingCharWithQ(c)
			This.ReplaceRepeatedLeadingCharWith(c)
			return This

		def ReplaceRepeatedLeadingCharBy(c)
			This.ReplaceRepeatedLeadingCharWith(c)

			def ReplaceRepeatedLeadingCharByQ(c)
				This.ReplaceRepeatedLeadingCharBy(c)
				return This
					
		def ReplaceLeadingRepeatedCharWith(c)
			This.ReplaceRepeatedLeadingCharWith(c)

			def ReplaceLeadingRepeatedCharWithQ(c)
				This.ReplaceLeadingRepeatedCharWith(c)
				return This

			def ReplaceLeadingRepeatedCharBy(c)
				This.ReplaceLeadingRepeatedCharWith(c)

				def ReplaceLeadingRepeatedCharByQ(c)
					This.ReplaceLeadingRepeatedCharBy(c)
					return This
						
		def ReplaceLeadingRepeatedCharsWith(c)
			This.ReplaceRepeatedLeadingCharWith(c)

			def ReplaceLeadingRepeatedCharsWithQ(c)
				This.ReplaceLeadingRepeatedCharsWith(c)
				return This
		
			def ReplaceLeadingRepeatedCharsBy(c)
				This.ReplaceLeadingRepeatedCharsWith(c)

				def ReplaceLeadingRepeatedCharsByQ(c)
					This.ReplaceLeadingRepeatedCharsBy(c)
					return This
	
		def ReplaceLeadingCharWith(c)
			This.ReplaceRepeatedLeadingCharWith(c)

			def ReplaceLeadingCharWithQ(c)
				This.ReplaceLeadingCharWith(c)
				return This
		
			def ReplaceLeadingCharBy(c)
				This.ReplaceLeadingCharWith(c)

				def ReplaceLeadingCharByQ(c)
					This.ReplaceLeadingCharBy(c)
					return This
	
		def ReplaceRepeatedLeadingCharsWith(c)
			This.ReplaceRepeatedLeadingCharWith(c)

			def ReplaceRepeatedLeadingcharsWithQ(c)
				This.ReplaceRepeatedLeadingCharsWith(c)
				return This
		
			def ReplaceRepeatedLeadingCharsBy(c)
				This.ReplaceRepeatedLeadingCharsWith(c)

				def ReplaceRepeatedLeadingcharsByQ(c)
					This.ReplaceRepeatedLeadingCharsBy(c)
					return This
		
		def ReplaceLeadingCharsWith(c)
			This.ReplaceRepeatedLeadingCharWith(c)

			def ReplaceLeadingCharsWithQ(c)
				This.ReplaceLeadingCharsWith(c)
				return This
		
			def ReplaceLeadingCharsBy(c)
				This.ReplaceLeadingCharsWith(c)

				def ReplaceLeadingCharsByQ(c)
					This.ReplaceLeadingCharsWith(c)
					return This
	
	def RepeatedLeadingCharReplacedWith(c)
		cResult = This.Copy().ReplaceRepeatedLeadingCharWithQ(c).Content()
		return cResult

		def RepeatedLeadingCharReplacedBy(c)
			return This.RepeatedLeadingCharReplacedWith(c)

		def LeadingRepeatedCharReplacedWith(c)
			return This.RepeatedLeadingCharReplacedWith(c)
		
		def LeadingRepeatedCharReplacedBy(c)
			return This.RepeatedLeadingCharReplacedWith(c)
		
		def LeadingCharReplacedWith(c)
			return This.RepeatedLeadingCharReplacedWith(c)
		
		def LeadingCharReplacedBy(c)
			return This.RepeatedLeadingCharReplacedWith(c)
			
		def RepeatedLeadingCharsReplacedWith(c)
			return This.RepeatedLeadingCharReplacedWith(c)
		
		def RepeatedLeadingCharsReplacedBy(c)
			return This.RepeatedLeadingCharReplacedWith(c)
		
		def LeadingRepeatedCharsReplacedWith(c)
			return This.RepeatedLeadingCharReplacedWith(c)
		
		def LeadingRepeatedCharsReplacedBy(c)
			return This.RepeatedLeadingCharReplacedWith(c)
		
		def LeadingCharsReplacedWith(c)
			return This.RepeatedLeadingCharReplacedWith(c)
		
		def LeadingCharsReplacedBy(c)
			return This.RepeatedLeadingCharReplacedWith(c)
				
	  #------------------------------#
	 #   REPLACING TRAILING CHARS   #
	#------------------------------#

	def ReplaceRepeatedTrailingCharWith(c)
		/* Example:

		StzStringQ("___VAR---").ReplaceRepeatedTrailingCharBy("_")

		Give --> "___VAR__"
		*/

		if This.HasRepeatedTrailingChars()
			n = This.NumberOfRepeatedTrailingChars()
			
			cStr = ""
			for i = 1 to n
				cStr += c
			next

			n = This.NumberOfChars() - n + 1
			This.ReplaceSection( n, This.NumberOfChars(), cStr )

		ok

		def ReplaceRepeatedTrailingCharWithQ(c)
			This.ReplaceRepeatedTrailingCharWith(c)
			return This
	
		def ReplaceRepeatedTrailingCharBy(c)
			This.ReplaceRepeatedTrailingCharWith(c)

			def ReplaceRepeatedTrailingCharByQ(c)
				This.ReplaceRepeatedTrailingCharBy(c)
				return This
	
		def ReplaceTrailingRepeatedCharWith(c)
			This.ReplaceRepeatedTrailingCharWith(c)

			def ReplaceTrailingRepeatedCharWithQ(c)
				This.ReplaceTrailingRepeatedCharWith(c)
				return This
	
		def ReplaceTrailingRepeatedCharBy(c)
			This.ReplaceRepeatedTrailingCharWith(c)

			def ReplaceTrailingRepeatedCharByQ(c)
				This.ReplaceTrailingRepeatedCharBy(c)
				return This				
	
		def ReplaceTrailingCharWith(c)
			This.ReplaceRepeatedTrailingCharWith(c)

			def ReplaceTrailingCharWithQ(c)
				This.ReplaceTrailingCharWith(c)
				return This
	
		def ReplaceTrailingCharBy(c)
			This.ReplaceRepeatedTrailingCharWith(c)

			def ReplaceTrailingCharByQ(c)
				This.ReplaceTrailingCharBy(c)
				return This
	
		def ReplaceRepeatedTrailingCharsWith(c)
			This.ReplaceRepeatedTrailingCharWith(c)

			def ReplaceRepeatedTrailingCharsWithQ(c)
				This.ReplaceRepeatedTrailingCharsWith(c)
				return This
		
			def ReplaceRepeatedTrailingCharsBy(c)
				This.ReplaceRepeatedTrailingCharsWith(c)

				def ReplaceRepeatedTrailingCharsByQ(c)
					This.ReplaceRepeatedTrailingCharsBy(c)
					return This
		
			def ReplaceTrailingRepeatedCharsWith(c)
				This.ReplaceRepeatedTrailingCharsWith(c)

				def ReplaceTrailingRepeatedCharsWithQ(c)
					This.ReplaceTrailingRepeatedCharsWith(c)
					return This
		
			def ReplaceTrailingRepeatedCharsBy(c)
				This.ReplaceRepeatedTrailingCharsWith(c)

				def ReplaceTrailingRepeatedCharsByQ(c)
					This.ReplaceTrailingRepeatedCharsBy(c)
					return This
	
	def RepeatedTrailingCharReplacedWith(c)
		cResult = This.Copy().ReplaceRepeatedTrailingCharWithQ(c).Content()
		return cResult

		def RepeatedTrailingCharReplacedBy(c)
			return This.RepeatedTrailingCharReplacedWith(c)

		def TrailingRepeatedCharReplacedWith(c)
			return This.RepeatedTrailingCharReplacedWith(c)

		def TrailingRepeatedCharReplacedBy(c)
			return This.RepeatedTrailingCharReplacedWith(c)

		def TrailingCharReplacedWith(c)
			return This.RepeatedTrailingCharReplacedWith(c)

		def TrailingCharReplacedBy(c)
			return This.RepeatedTrailingCharReplacedWith(c)
	
		def RepeatedTrailingCharsReplacedWith(c)
			return This.RepeatedTrailingCharReplacedWith(c)

		def RepeatedTrailingCharsReplacedBy(c)
			return This.RepeatedTrailingCharReplacedWith(c)

		def TrailingRepeatedCharsReplacedWith(c)
			return This.RepeatedTrailingCharReplacedWith(c)

		def TrailingRepeatedCharsReplacedBy(c)
			return This.RepeatedTrailingCharReplacedWith(c)

		def TrailingCharsReplacedWith(c)
			return This.RepeatedTrailingCharReplacedWith(c)

		def TrailingCharsReplacedBy(c)
			return This.RepeatedTrailingCharReplacedWith(c)
	
	  #---------------------------------------------------#
	 #   REPLACING REPEATED LEADING AND TRAILING CHARS   #
	#---------------------------------------------------#

	def ReplaceRepeatedLeadingCharAndTrailingCharWith(c1, c2)
		This.ReplaceRepeatedLeadingCharWith(c1)
		This.ReplaceRepeatedTrailingCharWith(c2)

		def ReplaceRepeatedLeadingCharAndTrailingCharWithQ(c1, c2)
			This.ReplaceRepeatedLeadingCharAndTrailingCharWith(c1, c2)
			return This
	
		def ReplaceRepeatedLeadingCharAndTrailingCharBy(c1, c2)
			This.ReplaceRepeatedLeadingCharAndTrailingCharWith(c1, c2)

			def ReplaceRepeatedLeadingCharAndTrailingCharByQ(c1, c2)
				This.ReplaceRepeatedLeadingCharAndTrailingCharBy(c1, c2)
				return This
	
		def ReplaceRepeatedTrailingCharAndLeadingCharWith(c1, c2)
			This.ReplaceRepeatedLeadingCharAndTrailingCharWith(c1, c2)

			def ReplaceRepeatedTrailingCharAndLeadingCharWithQ(c1, c2)
				This.ReplaceRepeatedTrailingCharAndLeadingCharWith(c1, c2)
				return This
	
		def ReplaceRepeatedTrailingCharAndLeadingCharBy(c1, c2)
			This.ReplaceRepeatedLeadingCharAndTrailingCharWith(c1, c2)

			def ReplaceRepeatedTrailingCharAndLeadingCharByQ(c1, c2)
				This.ReplaceRepeatedTrailingCharAndLeadingCharBy(c1, c2)
				return This
	
		def ReplaceLeadingCharAndTrailingCharWith(c1, c2)
			This.ReplaceRepeatedLeadingCharAndTrailingCharWith(c1, c2)

			def ReplaceLeadingCharAndTrailingCharWithQ(c1, c2)
				This.ReplaceLeadingCharAndTrailingCharWith(c1, c2)
				return This
	
		def ReplaceLeadingCharAndTrailingCharBy(c1, c2)
			This.ReplaceRepeatedLeadingCharAndTrailingCharWith(c1, c2)

			def ReplaceLeadingCharAndTrailingCharByQ(c1, c2)
				This.ReplaceLeadingCharAndTrailingCharBy(c1, c2)
				return This
	
		def ReplaceTrailingCharAndLeadingCharWith(c1, c2)
			This.ReplaceRepeatedLeadingCharAndTrailingCharWith(c1, c2)

			def ReplaceTrailingCharAndLeadingCharWithQ(c1, c2)
				This.ReplaceTrailingCharAndLeadingCharWith(c1, c2)
				return This
	
		def ReplaceTrailingCharAndLeadingCharBy(c1, c2)
			This.ReplaceRepeatedLeadingCharAndTrailingCharWith(c1, c2)

			def ReplaceTrailingCharAndLeadingCharByQ(c1, c2)
				This.ReplaceTrailingCharAndLeadingCharBy(c1, c2)
				return This
	
	def RepeatedLeadingcharAndTrailingCharReplacedWith(c1, c2)
		cResult = This.Copy().ReplaceRepeatedLeadingCharAndTrailingCharWithQ(c1, c2).Content()
		return cResult

		def RepeatedLeadingCharAndTrailingCharReplacedBy(c1, c2)
			return This.RepeatedLeadingcharAndTrailingCharReplacedWith(c1, c2)
	
		def LeadingCharAndTrailingCharReplacedWith(c1, c2)
			return This.RepeatedLeadingcharAndTrailingCharReplacedWith(c1, c2)

			def LeadingCharAndTrailingCharReplacedBy(c1, c2)
				return This.LeadingCharAndTrailingCharReplacedWith(c1, c2)
	
		def RepeadtedTrailingCharAndLeadingCharReplacedWith(c1, c2)
			This.RepeatedLeadingcharAndTrailingCharReplacedWith(c1, c2)

			def RepeadtedTrailingCharAndLeadingCharReplacedBy(c1, c2)
				return This.RepeadtedTrailingCharAndLeadingCharReplacedWith(c1, c2)
	
		def TrailingCharAndLeadingCharReplacedWith(c1, c2)
			This.RepeatedLeadingcharAndTrailingCharReplacedWith(c1, c2)

			def TrailingCharAndLeadingCharReplacedBy(c1, c2)
				return This.TrailingCharAndLeadingCharReplacedWith(c1, c2)
	
	def ReplaceRepeatedLeadingAndTrailingCharsWith(c)
		This.ReplaceRepeatedLeadingCharWith(c)
		This.ReplaceRepeatedTrailingCharWith(c)

		def ReplaceRepeatedLeadingAndTrailingCharsWithQ(c)
			This.ReplaceRepeatedLeadingAndTrailingCharsWith(c)
			return This
	
		def ReplaceRepeatedLeadingAndTrailingCharsBy(c)
			This.ReplaceRepeatedLeadingAndTrailingCharsWith(c)

			def ReplaceRepeatedLeadingAndTrailingCharsByQ(c)
				This.ReplaceRepeatedLeadingAndTrailingCharsBy(c)
				return This
	
		def ReplaceLeadingAndTrailingCharsWith(c)
			This.ReplaceRepeatedLeadingAndTrailingCharsWith(c)

			def ReplaceLeadingAndTrailingCharsWithQ(c)
				This.ReplaceLeadingAndTrailingCharsWith(c)
				return This
	
		def ReplaceRepeatedTrailingAndLeadingCharsWith(c)
			This.ReplaceRepeatedLeadingAndTrailingCharsWith(c)

			def ReplaceRepeatedTrailingAndLeadingCharsWithQ(c)
				This.ReplaceRepeatedTrailingAndLeadingCharsWith(c)
				return This
	
		def ReplaceLeadingAndTrailingCharsBy(c)
			This.ReplaceRepeatedLeadingAndTrailingCharsWith(c)

			def ReplaceLeadingAndTrailingCharsByQ(c)
				This.ReplaceLeadingAndTrailingCharsBy(c)
				return This
	
		def ReplaceTrailingAndLeadingCharsWith(c)
			This.ReplaceRepeatedLeadingAndTrailingCharsWith(c)

			def ReplaceTrailingAndLeadingCharsWithQ(c)
				This.ReplaceTrailingAndLeadingCharsWith(c)
				return This
	
	def RepeatedLeadingAndTrailingCharsReplacedWith(c)
		cResult = This.Copy().ReplaceRepeatedLeadingAndTrailingCharsWithQ(c).Content()
		return cResult

		def RepeatedLeadingAndTrailingCharsReplacedBy(c)
			return This.RepeatedLeadingAndTrailingCharsReplacedWith(c)

		def RepeatedTrailingAndLeadingCharsReplacedWith(c)
			return This.RepeatedLeadingAndTrailingCharsReplacedWith(c)

			def RepeatedTrailingAndLeadingCharsReplacedBy(c)
				return This.RepeatedTrailingAndLeadingCharsReplacedWith(c)
	
		def LeadingAndTrailingCharsReplacedWith(c)
			return This.RepeatedLeadingAndTrailingCharsReplacedWith(c)

			def LeadingAndTrailingCharsReplacedBy(c)
				return This.LeadingAndTrailingCharsReplacedWith(c)
	
		def TrailingAndLeadingCharsReplacedWith(c)
			return This.RepeatedLeadingAndTrailingCharsReplacedWith(c)

			def TrailingAndLeadingCharsReplacedBy(c)
				return This.TrailingAndLeadingCharsReplacedWith(c)

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
		This.VerifyConstraints()

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

	  #----------------------------------------------------#
	 #    INSERTING A SUBSTRING AFTER A GIVEN POSITION    #
	#----------------------------------------------------#

	def InsertAfter(nPos, pcSubStr)
		@oQString.insert(nPos, pcSubStr)

		VerifyConstraints()

		#< @FunctionFluentForm
		
		def InsertAfterQ(nPos, pcSubStr)
			This.InsertAfter(nPos, pcSubStr)
			return This

		#>

		#< @FunctionAlternativeForm

		def InsertAfterPosition(nPos, pcSubStr)
			This.InsertBefore(nPos, pcSubStr)

			def InsertAfterePositionQ(nPos, pcSubStr)
				This.InsertAfterPosition(nPos, pcSubStr)
				return This
		#>

	   #--------------------------------------------------------#
	  #    INSERTING A SUBSTRING AFTER A POSITION DEFINED      #
	 #    BY A GIVEN CONDITION APPLIED ON THE STRING CHARS    #
	#--------------------------------------------------------#

	def InsertAfterW( pcCondition, pcSubStr )
		pcCondition = StzStringQ(pcCondition).ReplaceCSQ("@char", "@item", :CS = FALSE).Content()
		cResult = StzListQ( This.Chars() ).InsertAfterWQ( pcCondition, pcSubStr ).ToStzListOfStrings().Concatenated()
		This.Update(cResult)

		def InsertAfterWQ( pcCondition, pcSubStr )
			This.InsertAfterW( pcCondition, pcSubStr )
			return This

		def InsertAfterWhere( pcCondition, pcSubStr )
			This.InsertAfterW( pcCondition, pcSubStr )

			def InsertAfterWhereQ( pcCondition, pcSubStr )
				This.InsertAfterWhere( pcCondition, pcSubStr )
				return This

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

	  #-----------------------------------------#
	 #     REPLACING A SECTION OF THE STRING   #
	#-----------------------------------------#

	// Replaces a Section of chars in the string (defined by its start
	// and end positions) by a given substring
		
	def ReplaceSection(nStartPos, nEndPos, cNewSubStr)

		if isList(nStartPos) and StzListQ(nStartPos).IsFromParamList()
			nStartPos = nStartPos[2]
		ok

		if isList(nEndPos) and StzListQ(nEndPos).IsToParamList()
			nEndPos = nEndPos[2]
		ok

		if isList(cNewSubStr) and
		  ( StzListQ(cNewSubStr).IsWithParamList() or
		    StzListQ(cNewSubStr).IsByParamList() )

			cNewSubStr = cNewSubStr[2]
		ok

		# Evaluating the params
		# Note: same code as Section() method -> Think of how we call it once

		if ( nStartPos = :FirstChar or nStartPos = :StartOfString ) and
		   ( nEndPos   = :LastChar  or nEndPos   = :LastOfString  )

			return This.Content()

		but ( nStartPos = :LastChar or nStartPos = :EndOfString ) and
		    ( nEndPos = :FirstChar  or nEndPos = :StartOfString )

			return This.CharsReversed()
		ok

		if nStartPos = :FirstChar or nStartPos = :StartOfString
			nStartPos = 1

		but nEndPos = :LastChar or nEndPos = :EndOfString
			nEndPos = This.NumberOfChars()

		but nEndPos = :EndOfWord # TODO: Move it to stzText
					 # --> string shouldn't be aware of words!
			
			if  This[nStartPos] != " "
				
				oString = StzStringQ( This.Section(nStartPos, :End))
				nEndPos = nStartPos
				n = ListLastItem( oString.CharsQ().WalkUntil("@item = ' '") )

				if nStartPos + n < This.NumberOfChars()
					nEndPos += n - 2
				else
					nEndPos += n - 1
				ok


    			else
				nEndPos = nStartPos
			ok

		but nEndPos = :EndOfSentence # TODO: Move it to stzText
					     # --> string shouldn't be aware of sentences!

			if  This[nStartPos] != "." and This[nStartPos] != "!" and This[nStartPos] != "?"
				
				oString = StzStringQ( This.Section(nStartPos, :End))
				nEndPos = nStartPos
				n = ListLastItem(oString.CharsQ().WalkUntil("@item = '.' or Item = '!' or Item = '?'"))

				nEndPos += n - 1

    			else
				nEndPos = nStartPos
			ok

		but nEndPos = :EndOfLine

			oString = StzStringQ( This.Section(nStartPos, :End))
			nEndPos = oString.CharsQ().WalkUntil("@item = NL") - 1
		ok

		// Replacing the section
		
		cResult = NULL
	
		if (nStartPos > 0 and nEndPos > 0) and
		   (nStartPos <= This.NumberOfChars() and nEndPos <= This.NumberOfChars()) and
		   (nStartPos <= nEndPos)

			nLen = pvtDistance(nStartPos, nEndPos)
			cResult = @oQString.replace(nStartPos-1, nLen, cNewSubStr)

			This.Update( cResult )
		ok

		#< @FunctionFluentForm

		def ReplaceSectionQ(nPosStart, nPosEnd, cNewSubStr)
			This.ReplaceSection(nPosStart, nPosEnd, cNewSubStr)
			return This

		#>
	
	  #-------------------------------------------------#
	 #     REPLACING ALL OCCURRENCES OF A SUBSTRING    #
	#-------------------------------------------------#

	// Replaces ALL the occurrences of a substring inside the
	// string by a new substring (works also for a list of strings)

	def ReplaceAll(pSubStr, pNewSubStr)
		if isString(pSubStr)
			This.ReplaceAllCS(pSubStr, pNewSubStr, :Casesensitive = TRUE)

		but ListIsListOfStrings(pSubStr)
			This.ReplaceManyCS(pSubStr,  pNewSubStr, :Casesensitive = TRUE)
		ok

		#< @FunctionFluentForm

		def ReplaceAllQ(pcSubStr, pNewSubStr)
			This.ReplaceAll(pcSubStr, pNewSubStr)
			return This

		#>
	
		#< @FunctionCasesensitivityForm
	
		def ReplaceAllCS(pSubStr, pNewSubStr, pCaseSensitive)
			
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

			cType = type(pCaseSensitive)

			if NOT ( cType = "NUMBER" or cType = "LIST" )
				stzRaise(StzStringError(:IncorrectFormatOfCaseSensitiveParamList))
			ok

			if isNumber(pCaseSensitive) and NOT
			   ( pCaseSensitive = 0 or pCaseSensitive = 1)

				stzRaise(StzStringError(:IncorrectFormatOfCaseSensitiveParamList))
			ok

			if isList(pCaseSensitive) and StzListQ(pCaseSensitive).IsCaseSensitiveParamList()
				pCaseSensitive = pCaseSensitive[2]
			ok

			if isList(pNewSubStr)
				if pNewSubStr[1] = :With and
				   isString(pNewSubStr[2])

					pNewSubStr = pNewSubStr[2]

				but pNewSubStr[1] = :EachChar and
			   	   StringIsChar(pNewSubStr[2])
	
					nLen = StzStringQ(pcSubStr).NumberOfChars()
					pNewSubStr = StzStringQ(pNewSubStr[2]).RepeatNTimesQ( nLen ).Content()
				ok

			ok
	
			if isString(pSubStr) and
			   NOT StzStringQ(pNewSubStr).TrimQ().IsBoundedBy("{","}")

				cResult = @oQString.replace_2(pSubStr, pNewSubStr, pCaseSensitive)

			but ListIsListOfStrings(pSubStr)

				if  NOT StzStringQ(pNewSubStr).TrimQ().IsBoundedBy("{","}") 
					for str in pSubStr
						cResult = @oQString.replace_2(str, pNewSubStr, pCaseSensitive)
					next
				else
					for @newstr in pSubStr
						cCode = 'cNewSubStr = ' +  StzStringQ(pNewSubStr).BoundsRemoved("{","}")
						eval(cCode)
						cResult = @oQString.replace_2(@newstr, cNewSubStr, pCaseSensitive)

					next
				ok
			ok
	
			This.Update( cResult )
	
				#< @FunctionFluentForm
		
				def ReplaceAllCSQ(pcSubStr, pNewSubStr, pCaseSensitive)
					This.ReplaceAllCS(pcSubStr, pNewSubStr, pCaseSensitive)
					return This
		
				#>
		
		#>

		#< @FunctionAlternativeForms

		def Replace(pSubStr, pNewSubStr)
			This.ReplaceAll(pSubStr, pNewSubStr)

			def ReplaceQ(pSubStr, pNewSubStr)
				This.Replace(pSubStr, pNewSubStr)
				return This

			def ReplaceCS(pSubStr, pNewSubStr, pCaseSensitive)
				This.ReplaceAllCS(pSubStr, pNewSubStr, pCaseSensitive)

				def ReplaceCSQ(pSubStr, pNewSubStr, pCaseSensitive)
					This.ReplaceCS(pSubStr, pNewSubStr, pCaseSensitive)
					return This

		#>

	  #--------------------------------------------------------------------#
	 #     REPLACING ALL CHARS WITH A SUBSTRING UNDER A GIVEN CONDITION   #
	#--------------------------------------------------------------------#

	def ReplaceAllCharsW(pCondition, pValue) // TODO: fix performance lag!
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

		if isString(pCondition)
			cCondition = pCondition

		but isList(pCondition) and _@(pCondition).IsWhereParamList()
			cCondition = pCondition[2]
		ok

		cCondition = StzStringQ(pCondition[2]).ReplaceAllCSQ("@char","@item", :CS = FALSE).Content()
		pCondition[2] = cCondition

		cValue = StzStringQ(pValue[2]).ReplaceAllCSQ("@char","@item", :CS = FALSE).Content()
		pValue[2] = cValue

		cResult = StzListQ( This.Chars() ).ReplaceAllItemsWQ(pCondition, pValue).ToListOfStringsQ().ConcatenateQ().Content()
	
		This.Update( cResult )

		#< @FunctionFluentForm

		def ReplaceAllCharsWQ(pCondition, pSubStr)
			This.ReplaceAllCharsWhere(pCondition, pSubStr)
			return This

		#>

		#< @FunctionAlternativeForms

		def ReplaceAllWhere(pCondition, pSubStr)
			This.ReplaceAllCharsW(pCondition, pSubStr)

			#< @FunctionFluentForm

			def ReplaceAllWhereQ(pCondition, pSubStr)
				This.ReplaceAllWhere(pCondition, pSubStr)
				return This
			#>

		def ReplaceAllCharsWhere(pCondition, pSubStr)
			This.ReplaceAllCharsW(pCondition, pSubStr)

			#< @FunctionFluentForm

			def ReplaceAllCharsWhereQ(pCondition, pSubStr)
				This.ReplaceAllCharsWhere(pCondition, pSubStr)
				return This

			#>

		def ReplaceCharsW(pCondition, pSubStr)
			This.ReplaceAllCharsW(pCondition, pSubStr)

			#< @FunctionFluentForm

			def ReplaceCharsWQ(pCondition, pSubStr)
				This.ReplaceCharsW(pCondition, pSubStr)
				return This

			#>

		def ReplaceCharsWhere(pCondition, pSubStr)
			This.ReplaceAllCharsW(pCondition, pSubStr)

			#< @FunctionFluentForm

			def ReplaceCharsWhereQ(pCondition, pSubStr)
				This.ReplaceCharsWhere(pCondition, pSubStr)
				return This

			#>

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

		#>

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

		#>

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

	def ManySubStringsReplacedOneByOneCS(pacSubstrings, paNewSubStrings, pCaseSensitive)
		cResult = This.Copy().ReplaceManyOneByOneCSQ(pacSubstrings, paNewSubStrings, pCaseSensitive)
		return cResult

	def ReplaceManyOneByOne(pacSubstrings, paNewSubStrings)
		This.ReplaceManyOneByOneCS(pacSubStrings, paNewSubStrings, :CaseSensitive = TRUE)

		def ReplaceManyOneByOneQ(pacSubstrings, paNewSubStrings)
			This.ReplaceManyOneByOne(pacSubstrings, paNewSubStrings)
			return This

	def ManySubStringsReplaceOneByOne(pacSubstrings, paNewSubStrings)
		cResult = This.Copy().ReplaceManyOneByOneQ(pacSubstrings, paNewSubStrings)
		return cResult

	  #----------------------------------------------------#
	 #     REPLACING THE NTH OCCURRENCE OF A SUBSTRING    #
	#----------------------------------------------------#

		def ReplaceNthOccurrenceCS(n, pcSubStr, pcNewSubStr, pCaseSensitive)

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

		oPart2 = This.SectionQ(nStart, :End)
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

		cPart2 = This.Section(nStart, :End)

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

		if n = :LastChar or n = :EndOfString
			n = This.NumberOfChars()

		but n = :FirstChar or n = :StartOfString
			n = 1
		ok

		if isList(pSubStr) and
		   len(pSubStr) = 2 and
		   ListIsPairOfStrings(pSubStr)

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
	
		@oQString = new QString2()
		@oQString.append(pcNewText)

		This.VerifyConstraints()

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
		/*
		Let's be permissive: if the user misses the right order of params
		( --> enters the string before the number ) then fix it silently

		TODO: generealize this feature!
		*/

		if isString(n) and isNumber(pcSubStr)
			temp = n
			n = pcSubStr
			pcSubStr = temp
		ok

		# Also, let's facilitate the syntax a bit further

		if n = :FirstChar or n = :StartOfString
			n = 1
		but n = :LastChar or n = :EndOfString
			n = This.NumberOfOccurrence(pcSubStr)
		ok

		# And why not beautify the expression

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

		oSection = This.SectionQ(pnStartingAt, :End)

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

		def OccurrencesCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		def FindOccurrenceCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		def OccurrenceCS(pcSubStr, pCaseSensitive)
			return This.FindAllOccurrencesCS(pcSubStr, pCaseSensitive)

		def PositionsCS(pcStr, pCaseSensitive)
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

		def Occurrences(pcSubStr)
			return This.FindAllOccurrences(pcSubStr)

		def Occurrence(pcSubStr)
			return This.FindAllOccurrences(pcSubStr)

		def Positions(pcStr)
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

		def PositionsXT(pcStr)
			return This.FindAllOccurrencesXT(pcSubStr)

		#>

	   #----------------------------------------#
	  #    FINDING ALL OCCURRENCES OF A CHAR   #
	 #    VERIFYING A GIVEN CONDITION         #
	#----------------------------------------#

	def FindAllCharsW(pcCondition)
		cCondition = StzStringQ(pcCondition).ReplaceAllCSQ("@char", "@item", :CS = FALSE).Content()
		return StzListQ( This.ToListOfChars() ).FindAllItemsW(cCondition)
		
		def FindAllCharsWhere(pcCondition)
			return This.FindAllCharsW(pcCondition)

		def FindCharsW(pcCondition)
			return This.FindAllCharsW(pcCondition)

			def FindCharsWhere(pcCondition)
				return This.FindCharsW(pcCondition)

		def CharsPositionsW(pCondition)
			return This.FindAllCharsW(pcCondition)

		def CharsPositionsWhere(pCondition)
			return This.FindAllCharsW(pcCondition)

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

	def FindMany(pacSubStr)
		/*
		o1 = new stzString("My name is Mansour. What's your name please?")
		? o1.FindMany( [ "name", "your", "please" ] )

		# --> [ [ 4, 33 ], [ 28 ], [ 38 ] ]

		*/

		return This.FindManyCS(pacSubStr, :CaseSensitive = TRUE)

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

		def FindManyXTCS(pacSubStr, pCaseSensitive)
			return This.FindManyCSXT(pacSubStr, pCaseSensitive)

	def FindManyXT(pacSubStr)
		/*
		o1 = new stzString("My name is Mansour. What's your name please?")
		? o1.FindManyXT( [ "name", "your", "please" ] )

		--> [ "name" = [ 4, 33 ], "your" = [ 28 ], "please" = [ 38 ] ]

		*/

		return This.FindManyCSXT(pacSubStr, :CaseSensitive = TRUE)

	  #---------------------------------------#
	 #      FINDING BY FORMAT (REGEXP)       # TODO
	#---------------------------------------#

	// Finds all the occurrences of a given substring in the string depending on the provided format
	def FindByFormat(paFormat)
		// TODO: Use Regular expressions

	  #-------------------------------------------------------------------------#
	 #   FINDING ALL OCCURRENCES OF A SUBSTRING BETWEEN TWO OTHER SUBSTRINGS   #
	#-------------------------------------------------------------------------#

	/*
		TODO: Add all the features related to:
			- Casesensitivity
			- Alternative names
			- Fluent forms
	*/

	def FindBetween(pcSubStr, pcSubStrBefore, pcSubStrAfter)

		/* Example

		o1 = new stzString("opsus amcKLMbmi findus")
		o1.FindBetween("KLM", "amc", "bmi") # --> 10

		*/

		nLen = StzStringQ(pcSubStr).NumberOfChars()
		nLenBefore = StzStringQ(pcSubStrBefore).NumberOfChars()
		nLenAfter = StzStringQ(pcSubStrAfter).NumberOfChars()
		anPositions = This.FindAll(pcSubStr)

		anResult = []

		for n in anPositions
			if This.Section( n - nLenBefore, n - 1 ) = pcSubStrBefore and
			   This.Section( n + nLen, n + nLenAfter + 2) = pcSubStrAfter

				anResult + n
			ok
		next

		return anResult

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

	   #------------------------------------------------------------------------#
	  #      EXTRACTING SUBSTRINGS ENCLOSED BETWEEN TWO OTHER SUBSTRINGS       # 
	 #      --> SECTIONS OF STRINGS ENCLOSED BETWEEN TWO SUBSTRINGS           #
	#------------------------------------------------------------------------#

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
			#>

	#-- CASE-INSENSITIVE

	def SubstringsBoundedWith(pcSubStr1, pcSubStr2)
		return This.SubstringsBoundedWithCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def SubstringsBoundedWithQ(pcSubStr1, pcSubStr2)
			return This.SubstringsBoundedWithQR(pcSubStr1, pcSubStr2, :stzList)
		
		def SubstringsBoundedWithQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
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

	def VizFindSubString(pcSubStr)

		if NOT isString(pcSubStr)
			return NULL
		ok

		cResult = @@( This.Content() )
		anPositions = This.FindAll( pcSubStr )

		nLen = StzStringQ(cResult).NumberOfChars()

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

		def VizFindSubstringQ(pcSubStr)
			return new stzString( This.VVizFindSubstring(pcSubStr) )

		#>

		def VizFind(pcSubStr)
			return This.VizFindSubstring(pcSubStr)

	  #----------------------------------------------------#
	 #      VISUALLY FINDING AND BOXING A SUBSTRING       # TODO: Review this
	#----------------------------------------------------#

	def VizFindAllXT(pcSubstr, paOptions) # TODO
		
		# Example:
		# ? VizFindAllXT(" ", [ :Casesensitive = TRUE, :AllCorners = :Round ])


		if StzStringQ(pcSubStr).NumberOfChars() = 1

			# VizFind only one char

			if StzListQ(paOptions).IsVizFindParamList()
	
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
	
			else
				stzRaise(stzStringError(:IncorrectParameter))
			ok
		
		else
			# VizFind a substring: TODO
		ok

	def VizFindAllCS(pcSubStr, pCaseSensitive)

		# VizFind only one char

		if StzStringQ(pcSubStr).NumberOfChars() = 1
			oStzListOfChars = new stzListOfChars(This.String())
			return oStzListOfChars.BoxedXT([ :Hilighted = This.FindAllCS(pcSubStr, pCaseSensitive) ])
	
		else
			# VizFind a substring

			oStzListOfStrings = new stzListOfStrings(This.Words())

			return oStzListOfStrings.BoxedXT([
					:Attached = TRUE, :Hilighted = oStzListOfStrings.FindAllCS(pcSubStr, pCaseSensitive)
			       ])
		ok

	def VizFindAll(pcSubStr)
		return This.VizFindAllCS(pcSubStr, :CaseSensitive = TRUE)


	def VizRoundFindAllCS(pcSubStr, pCaseSensitive)

		if StzStringQ(pcSubStr).NumberOfChars() = 1

			# VizFind only one char

			oStzListOfChars = new stzListOfChars(This.String())
	
			return oStzListOfChars.BoxedXT([
					:AllCorners = :Round, :Hilighted = This.FindAllCS(pcSubStr, pCaseSensitive)
			       ])
	
		else
			# VizFind a substring

			oStzListOfStrings = new stzListOfStrings(This.Words())

			return oStzListOfStrings.BoxedXT([
					:Attached = TRUE, :Hilighted = oStzListOfStrings.FindAllCS(pcSubStr, pCaseSensitive)
			       ]) # TODO: Add Attached option
		ok

	def VizRoundFindAll(pcSubStr)
		return This.VizRoundFindAllCS(pcSubStr, :CaseSensitive = TRUE)
	
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

				return @oQString.contains(cSubStr, pCaseSensitive)

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

		if isList(cSep) and StzListQ(cSep).IsUsingParamList()
			cSep = cSep[2]
		ok

		# t0 = clock() // Very fast: takes almost 0.01s

		/*
		Example:
		paOptions --> [ :CaseSensitive = TRUE,
				:SkipEmptyParts = TRUE,

				:IncludeLeadingSep = FALSE,
				:IncludeTrailingSep = FALSE,

				:ExcludeLeadingSubstrings_FromSplittedParts = [ "<", "{" ],
				:ExcludeTrailingSubstrings_FromSplittedParts = [ "/>", "}" ],

				:ExcludeLeadingSequenceOfNChars_FromSplittedParts = [ 3, "<" ],
				:ExcludeTrailingSequenceOfNChars_FromSplittedParts = [ :AnyNumberOf, "<" ]
			      ]
		*/

		# Reading options

		bCaseSensitive = paOptions[ :CaseSensitive ]
		if bCaseSensitive = NULL { bCaseSensitive = FALSE }

		bSkipEmptyParts = paOptions[ :SkipEmptyParts ]
		if bCaseSensitive = NULL { bSkipEmptyParts = FALSE }

		bIncludeLeadingSep = paOptions[ :IncludeLeadingSep ]
		if bIncludeLeadingSep = NULL { bIncludeLeadingSep = FALSE }

		bIncludeTrailingSep = paOptions[ :IncludeTrailingSep ]
		if bIncludeTrailingSep = NULL { bIncludeTrailingSep = FALSE }

		acExcludeLeadingSubstrings_FromSplittedParts = paOptions[ :acExcludeLeadingSubstrings_FromSplittedParts ]
		if NOT StzListQ(acExcludeLeadingSubstrings_FromSplittedParts).IsListOfStrings()
			acExcludeLeadingSubstrings_FromSplittedParts = []
		ok

		
		acExcludeTrailingSubstrings_FromSplittedParts = paOptions[
			:acExcludeTrailingSubstrings_FromSplittedParts ]
		# Example: [ 3, "#" ] or [ :AnyNumberOf, "#" ]

		if NOT StzListQ(acExcludeTrailingSubstrings_FromSplittedParts).IsListOfStrings()
			acExcludeTrailingSubstrings_FromSplittedParts = []
		ok

		acExcludeLeadingSequenceOfNChars_FromSplittedParts = paOptions[
			:acExcludeLeadingSequenceOfNChars_FromSplittedParts ]

		if NOT ( isList(acExcludeLeadingSequenceOfNChars_FromSplittedParts) and
		   len(acExcludeLeadingSequenceOfNChars_FromSplittedParts) = 2 and
		   isNumber(acExcludeLeadingSequenceOfNChars_FromSplittedParts[1]) and
		   StringIsChar(acExcludeLeadingSequenceOfNChars_FromSplittedParts[2]) )

			acExcludeLeadingSequenceOfNChars_FromSplittedParts = []
		ok

		acExcludeTrailingSequenceOfNChars_FromSplittedParts = # Example: [ 3, "#" ] or [ :AnyNumberOf, "#" ]
			paOptions[ :acExcludeTrailingSequenceOfNChars_FromSplittedParts ]

		if NOT ( isList(acExcludeTrailingSequenceOfNChars_FromSplittedParts) and
		   len(acExcludeTrailingSequenceOfNChars_FromSplittedParts) = 2 and
		   isNumner(acExcludeTrailingSequenceOfNChars_FromSplittedParts[1]) and
		   StringIsChar(acExcludeTrailingSequenceOfNChars_FromSplittedParts[2]) )

			acExcludeTrailingSequenceOfNChars_FromSplittedParts = []
		ok

		# Performing the splitting

		if NOT This.Contains(cSep)
			return []
		ok

		oQStringList = @oQString.split(cSep, bSkipEmptyParts, bCaseSensitive)
		aResult = QStringListToRingList(oQStringList)

		if ( bCaseSensitive = TRUE and This.NLeftChars(1) = cSep ) OR
		   ( bCaseSensitive = FALSE and lower(This.NLeftChars(1)) = lower(cSep) )
			if bIncludeLeadingSep
				oList = new stzList(aResult)
				aResult = oList.InsertInStart()
			ok
		ok

		if (bCaseSensitive = TRUE and This.NRightChars(1) = cSep) OR
		   (bCaseSensitive = FALSE and lower(This.NRightChars(1)) = lower(cSep))
			if bIncludeLeadingSep
				aResult + cSep
			ok
		ok

		# ? ( clock() - t0 ) / clockspersecond()

		return aResult

	def SplitXTQ(cSep, paOptions)
		return new stzListOfStrings( This.SplitXT(cSep, paOptions) )

	def SplitAndSkipEmptyParts(cSep)

		aSplitOptions = [
 			:CaseSensitive = TRUE,
			:SkipEmptyParts = TRUE,
			:IncludeLeadingSep = FALSE,
			:IncludeTrailingSep = FALSE
		 ]

		return 	This.SplitXT(cSep, aSplitOptions)

	def SplitAndSkipEmptyPartsQ(cSep)
		return new stzListOfStrings( This.SplitAndSkipEmptyParts(cSep) )

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

	def SplitAndSkipEmptyPartsCSQ(cSep, aSplitOptions)
		return new stzListOfStrings( SplitAndSkipEmptyPartsCS(cSep, pCaseSensitive) )
	
	def SplitAndExcludeLeadingAndTrailingSep(cSep)

		aSplitOptions = [
 			:CaseSensitive = TRUE,
			:SkipEmptyParts = FALSE,
			:IncludeLeadingSep = TRUE,
			:IncludeTrailingSep = TRUE
		 ]

		return This.SplitXT(cSep, aSplitOptions)

	def SplitAndExcludeLeadingAndTrailingSepQ(cSep)
		return new stzListOfStrings( This.SplitAndExcludeLeadingAndTrailingSep(cSep) )

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

	def SplitAndExcludeLeadingAndTrailingSepCSQ(cSep)
		return new stzListOfStrings( This.SplitAndExcludeLeadingAndTrailingSepCS(cSep, pCaseSensitive) )

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
		return new stzListOfStrings( This.SplitForward(cSep) )

	def SplitForwardCS(cSep, pCaseSensitive)
		aSplitOptions = [
 			:CaseSensitive = TRUE,
			:SkipEmptyParts = FALSE,
			:IncludeLeadingSep = FALSE,
			:IncludeTrailingSep = FALSE
		 ]

		return This.SplitXT(cSep, aSplitOptions)


	def SplitForwardCSQ(cSep, pCaseSensitive)
		return new stzListOfStrings( This.SplitForwardCS(cSep, pCaseSensitive) )

	def SplitBackward(cSep)
		oList = new stzList( This.SplitForward(cSep) )
		return oList.Reversed()

	def SplitBackwardQ(cSep)
		return new stzListOfStrings( This.SplitBackward(cSep) )

	def SplitBackwardCS(cSep, pCaseSensitive)
		oList = new stzList( This.SplitForwardCS(cSep, pCaseSensitive) )
		return oList.Reversed()

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

	def SplitCS(cSep, pCaseSensitive)
		return This.SplitForwardCS(cSep, pCaseSensitive)

	def SplitCSQ(cSep, pCaseSensitive)
		return new stzList( This.SplitCS(cSep, pCaseSensitive) )

	  #---------------------------------------#
	 #     SPLITTING TO PARTS OF N CHARS    #
	#---------------------------------------#

	// Splits the string to parts of n Chars

	def SplitToPartsOfNCharsXT(n, pDirection)
		if n > this.NumberOfChars()
			stzRaise("Can't proceed! Range of the part ("+ n +") must not exceed the lenght of the string ("+this.NumberOfChars()+").")
		ok

		if ( pDirection = :Forward or pDirection = :Backward ) OR

		   ( isList(pDirection) and
		     len(pDirection) = 2 and 
		     pDirection[1] = :Direction and 
		     ( pDirection[2] = :Forward or pDirection[2] = :Backward ) )

			aResult = []
			nWhatRemains = 0
	
			if pDirection[2] = :Backward

				// Adding the parts
				for i = this.NumberOfChars() to 0 step -n
					if this.Range(i+1,n) != ""
						aResult + this.Range(i+1,n)
					ok
				next
	
				// Adding the remaing part of the string
				nWhatRemains = NumberOfChars() - len(aResult) * n
				aResult + This.LeftNChars(nWhatRemains)	
		
			else # Including pcOrientation = :Forward --> DEFAULT
				// Adding the parts
				for i = 1 to this.NumberOfChars() step n
					aResult + this.Range(i,n)
				next
			ok
	
			return aResult

		else
			stzRaise("Incorrect paDirection format!")
		ok

	def SplitToPartsOfNCharsXTQ(n, pDirection)
		return new stzListOfStrings( This.SplitToPartsOfNCharsXT(n, pDirection) )

	def SplitToPartsOfNChars(n)
		return This.SplitForwardToPartsOfNChars(n)

	def SplitForwardToPartsOfNChars(n)
		return This.SplitToPartssOfNCharsXT(n, :Forward)

	def SplitForwardToPartsOfNCharsQ(n)
		return new stzListOfStrings( This.SplitForwardToPartsOfNChars(n) )

	def SplitBackwardToPartsOfNChars(n)
		return This.SplitToPartsOfNCharsXT(n, :Backward)

	def SplitBackwardToPartsOfNCharsQ(n)
		return new stzListOfStrings( This.SplitBackwardToPartsOfNChars(n) )
 
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

		#< @FunctionFluentForm

		def SplitToNPartsQ(n)
			return new stzListOfStrings( This.SplitToNParts(n) )

		#>

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
			return new stzList( This.SplitBeforePositions(paPositions) )
	
	  #-----------------------------------#
	 #     SPLITTING AFTER POSITIONS     #
	#-----------------------------------#
	
	// TODO

	  #--------------------------------#
	 #     SPLITTING AT POSITIONS     #
	#--------------------------------#

	// TODO --> nth char is removed

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

	This method analyzes the string, by sequentially classifying
	its content, using a given classifier. Hence, it serves in answering
	this question:

	How is the string composed in term of some char criteria
	(beeing, for example, lowercase or uppercase, or left-oriented
	or right-oriented).

	The classifier is what we should provide to the method as a param.
	And it's called here a pcClassifier.

	A classifier is provided by one of the methods of the stzChar class.

	For example:

	o1 = new stzString("TUNIS gafsa NABEUL beja")
	? o1.Sutructure(:By = '@.CharCase()' )

	Uses the CharCase() method in stzChar as a classifier.	

	And because this method returns a string equal to :Uppercase or :Lowercase
	or NULL, then the classification done will return:

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

	def PartsAsSubstrings(pClassifier)
		/*
		Example:

		o1 = new stzString("Abc285XY&من")

		? o1.PartsAsSubstrings( :Using = '@.IsLetter()' )
		--> Gives:
		[ "Abc" = TRUE, "285" = FALSE, "XY" = TRUE, "&" = FALSE, "من" = TRUE ]

		? o1.PartsAsSubstrings( :By = '@.Orientation()' )
		--> Gives:
		[ "Abc285XY&" = :LeftToRight, "من" = :RightToLeft ]

		? o1.PartsAsSubstrings( :Using = '@.IsUppercase()' )
		--> Gives:
		[ "A" = TRUE, "bc285" = FALSE, "XY" = TRUE, "&من" = FALSE ]

		? o1.PartsAsSubstrings(:Using = '@.CharCase()' )
		--> Gives:
		[ "A" = :Uppercase, "bc" = :Lowercase, "285" = NULL, "XY" = :Uppercase, "&من" = NULL ]

		*/

		if NOT isString(pClassifier) or isList(pClassifier)
			stzRaise("Incorrect param type!")
		ok

		if isList(pClassifier) and
		   ( StzListQ(pClassifier).IsWithParamList() or
		     StzListQ(pClassifier).IsByParamList() )

			pClassifier = pClassifier[2]

			if NOT isString(pCalssifier)
				stzRaise("Incorrect param type!")
			ok
		ok

		n = StzStringQ(pClassifier).WalkUntil(' @char = "(" ')
		

		cPart = This.FirstChar()
		aParts = []
		bEndOfString = FALSE
		i = 1

		while NOT bEndOfString
			i++
			if i = This.NumberOfChars()
				bEndOfString = TRUE

				cPart += This.LastChar()

				cCode = "aParts + [ cPart, cCurrent" + pcClassifier + " ]"
				eval(cCode)
			ok

			oCurrentChar = new stzChar(This[i])

			cCode = "cCurrent" + pcClassifier + " = oCurrentChar." + pcClassifier
			eval(cCode)

			oPreviousChar = new stzChar(This[i-1])
			cCode = "cPrevious" + pcClassifier + " = oPreviousChar." + pcClassifier
			eval(cCode)

			cCode =
			"if cCurrent" + pcClassifier + " = cPrevious" + pcClassifier + NL +
				TAB + "cPart += This[i]" + NL +
			"else" + NL +
				TAB + "aParts + [ cPart, cPrevious" + pcClassifier + " ]" + NL +
				TAB + "cPart = This[i]" + NL +
			"ok"

			eval(cCode)
		end

		return aParts

		#< @FunctionFluentForm

		def PartsAsSubstringsQ(pcClassifier)
			return new stzList( This.PartsAsSubstrings(pcClassifier) )
	
		#>

		#< @FunctionAlternativeForm

		def Parts(pcClassifier)
			return This.PartsAsSubstringsQ(pcClassifier)

			def PartsQ(pcCClassifier)
				return new stzList( This.Parts(pcClassifier) )

		#>

	def PartsAsSections(pcClassifier)
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

		aParts = This.PartsAsSubstrings(pcCharClassifier)
	
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
	
	def PartsAsSubstringsAndSections(pcClassifier)
		aSubstrings = This.PartsSubstrings(pcClassifier)
		aSections   = This.PartsSections(pcClassifier)

		aResult = []

		for i = 1 to len(aSubstrings)
			aResult + [ aSubstrings[1], aSections[1], aSections[2] ]
		next

		return aResult

	def PartsAsSectionsAndSubstrings(pcClassifier)
		aSubstrings = This.PartsSubstrings(pcClassifier)
		aSections   = This.PartsSections(pcClassifier)

		aResult = []

		for i = 1 to len(aSubstrings)
			aResult + [ aSections[1], aSubstrings[1], aSubstrings[2] ]
		next

		return aResult

	#---

	def PartsAsSubstringsClassified(pcClassifier)
		// TODO

	def PartsAsSectionsClassified(pcClassifier)
		// TODO

	def PartsAsSubStringsAndSectionsClassified(pcClassifier)
		// TODO

	def PartsAsSectionsAndSubstringsClassified(pcClassifier)
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

			nQtResult = @oQString.compare(pcOtherStr, bCaseSensitive)

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

	  #------------------------------#
	 #    REMOVING ALL SUBSTRINGS   # 
	#------------------------------#

	def RemoveAll(pSubStr) # replace with @oQString.remove() when added to RingQt
		This.ReplaceAll(pSubStr , "")

		def RemoveAllQ(pSubStr)
			This.RemoveAll(pSubStr)
			return This

		def Remove(pSubStr)
			This.RemoveAll(pSubStr)

			def RemoveQ(pSubStr)
				This.Remove(pSubStr)
				return This
	
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
	
	def RemoveManyCS(pacSubStr, pCaseSensitive)
		for cSubstr in paCsubstr
			This.RemoveAllCS(cSubstr, pCaseSensitive)
		next

		def RemoveManyCSQ(pacS, pCaseSensitive, pCaseSensitive)
			This.RemoveManyCS(pacSubStr, pCaseSensitive)
			return This

		def RemoveAllOfTheseCS(pacSubstr, pCaseSensitive)
			This.RemoveMany(pacSubStr)

			def RemoveAllOfTheseCSQ(pacSubstr, pCaseSensitive)
				This.RemoveAllOfTheseCS(pacSubstr, pCaseSensitive)
				return This

	  #---------------------------------------------#
	 #    REMOVING A GIVEN CHAR FROM THE STRING    # 
	#---------------------------------------------#

	def RemoveChar(pcChar)
		if StringIsChar(pcChar)
			This.RemoveCharsW('@char = ' + @@(pcChar))
		ok

		def RemoveCharQ(pcChar)
			This.RemoveChar(pcChar)
			return This

	def CharRemoved(pcChar)
		cResult = This.Copy().RemoveCharQ(pcChar).Content()
		return cResult

	  #---------------------------------------------#
	 #    REMOVING CHARS UNDER A GIVEN CONDITION   # 
	#---------------------------------------------#

	def RemoveCharsWhere(pcCondition)
		cCondition = StzStringQ(pcCondition).ReplaceAllCSQ("@char", "@item", :CS = FALSE).Content()
		cResult = StzListQ( This.ToListOfChars() ).RemoveItemsWhereQ(cCondition).ToStzListOfStrings().ConcatenateQ().Content()

		This.Update( cResult )

		#< @FunctionFluentForm

		def RemoveAllCharsWhereQ(pcCondition)
			This.RemoveAllCharsWhere(pcCondition)
			return This

		#>

		#< @FunctionAlternativeForm

		def RemoveCharsW(pcCondition)
			This.RemoveCharsWhere(pcCondition)
			
			#< @FunctionFluentForm

			def RemoveCharsWQ(pcCondition)
				This.RemoveCharsW(pcCondition)
				return This

			#>

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

	  #-------------------------------------------------#
	 #    REMOVING FIRST OCCURRENCE OF A SUBSTRING    #
	#-------------------------------------------------#

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

		def RemoveFromStartCS(pcSubStr, pCaseSensitive)
			This.RemoveFirstOccurrenceCS(pcSubStr, pCaseSensitive)

			def RemoveFromStartCSQ(pcSubStr, pCaseSensitive)
				This.RemoveFromStartCS(pcSubStr, pCaseSensitive)
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

		def RemoveFromStart(pcSubStr)
			This.RemoveFirstOccurrence(pcSubStr)

			def RemoveFromStartQ(pcSubStr)
				This.RemoveFromStart(pcSubStr)
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

		def RemoveFromEndCS(pcSubStr, pCaseSensitive)
			This.RemoveLastOccurrenceCS(pcSubStr, pCaseSensitive)

			def RemoveFromEndCSQ(pcSubStr, pCaseSensitive)
				This.RemoveFromEndCS(pcSubStr, pCaseSensitive)
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

		def RemoveFromEnd(pcSubStr)
			This.RemoveLastOccurrence(pcSubStr)

			def RemoveFromEndQ(pcSubStr)
				This.RemoveFromEnd(pcSubStr, pCaseSensitive)
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

		oPart2 = This.SectionQ(nStart, :End)
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

		cPart2 = This.Section(nStart, :End)

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

		def RemoveFromLeftCS(pcSubStr, pCaseSensitive)
			This.RemoveLeftOccurrenceCS(pcSubStr, pCaseSensitive)

			def RemoveFromLeftCSQ(pcSubStr, pCaseSensitive)
				This.RemoveFromLeftCS(pcSubStr, pCaseSensitive)
				return This

	#-- CASE-INSENSITIVE

	def RemoveLeftOccurrence(pcSubStr)
		This.RemoveLeftOccurrenceCS(pcSubStr, :CaseSensitive = FALSE)

		def RemoveLeftOccurrenceQ(pcSubStr)
			This.RemoveLeftOccurrence(pcSubStr)
			return This

		def RemoveFromLeft(pcSubStr)
			This.RemoveLeftOccurrence(pcSubStr)

			def RemoveFromLeftQ(pcSubStr)
				This.RemoveFromLeft(pcSubStr, pCaseSensitive)
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

		def RemoveFromRightCS(pcSubStr, pCaseSensitive)
			This.RemoveRightOccurrenceCS(pcSubStr, pCaseSensitive)

			def RemoveFromRightCSQ(pcSubStr, pCaseSensitive)
				This.RemoveFromRightCS(pcSubStr, pCaseSensitive)
				return This

	def RemoveRightOccurrence(pcSubStr)
		This.RemoveRightOccurrenceCS(pcSubStr, :CaseSensitive = TRUE)

		def RemoveRightOccurrenceQ(pcSubStr)
			This.RemoveRightOccurrence(pcSubStr)
			return This

		def RemoveFromRight(pcSubStr)
			This.RemoveRightOccurrence(pcSubStr)

			def RemoveFromRightQ(pcSubStr)
				This.RemoveFromRight(pcSubStr)
				return This

	  #----------------------------#
	 #     REMOVING NTH CHAR      #
	#----------------------------#

	def RemoveNthChar(n)
		This.ReplaceNthChar(n, "")

		def RemoveNthCharQ(n)
			This.RemoveNthChar(n)
			return This

	def NthCharRemoved(n)
		cResult = This.Copy().RemoveNthCharQ(n).Content()
		return cResult

		def NthCharRemoveQ(n)
			return new stzString(This.NthCharRemoved(n))

	  #----------------------------------------------------#
	 #     REMOVING NTH CHAR UNDER A GIVEN CONDITION      #
	#----------------------------------------------------#

	def RemoveNthCharW(n, pcCondition)

		if n = :LastChar or n = :EndOfString
			n = This.NumberOfChars()

		but n = :FirstChar or n = :StartOfString
			n = 1
		ok
		
		pcCondition = StzStringQ(pcCondition).LowercaseQ().SimplifyQ().RemoveBoundsQ("{","}").Content()

		@i = 0
		for @char in [ This[n] ]
			@i++
			cCode = 'bRemove = (' + pcCondition + ')'
			eval(cCode)

			if bRemove
				This.RemoveNthChar(n)
			ok
		next

		def RemoveNthCharWQ(n, pcCondition)
				This.RemoveNthCharW(n, pcCondition)
				return This

		def RemoveNthCharWhere(n, pcCondition)
			This.RemoveNthCharW(n, pcCondition)
			
			def RemoveNthCharWhereQ(n, pcCondition)
				This.RemoveNthCharW(n, pcCondition)
				return This

	def NthCharRemovedW(n, pcCondition)
		cResult = This.Copy().RemoveNthCharWQ(n, pcCondition).Content()
		return cResult

		def NthCharRemovedWQ(n, pcCondition)
			return new stzString( This.NthCharRemovedW(n, pcCondition) )

	def RemoveFirstCharW(pcCondition)
		This.RemoveNthCharW(1, pcCondition)

		def RemoveFirstCharWQ(pcCondition)
			This.RemoveFirstCharW(pcCondition)
			return This

	def FirstCharRemovedW(pcCondition)
		cResult = This.Copy().RemoveFirstCharWQ(pcCondition).Content()
		return cResult

		def FirstCharRemovedWQ(pcCondition)
			return new stzString( This.FirstCharRemovedW(pcCondition) )

	def RemoveLastCharW(pcCondition)
		//This.RemoveNthCharW(:Last, pcCondition)
		This.RemoveNthCharW(This.NumberOfChars(), pcCondition)

		def RemoveLastCharWQ(pcCondition)
			This.RemoveLastCharW(pcCondition)
			return This

	def LastCharRemovedW(pcCondition)
		cResult = This.Copy().RemoveLastCharWQ(pcCondition).Content()
		return cResult

		def LastCharRemovedWQ(pcCondition)
			return new stzString( This.LastCharRemovedW(pcCondition) )

	  #----------------------------------#
	 #    REMOVING A SECTION OF CHARS   # 
	#----------------------------------#
	
	// Removes a portion of the string defined by its start and end positions
	def RemoveSection(n1, n2)

		if n1 = :FirstChar or n1 = :StartOfString { n1 = 1 }
		if n2 = :LastChar  or n2 = :EndOfString { n2 = This.NumberOfChars() }

		This.ReplaceSection( n1, n2, "" )

		def RemoveSectionQ(n1, n2)
			This.RemoveSection(n1, n2)
			return This

	def SectionRemoved(n1, n2)
		cResult = This.Copy().RemoveSectionQ(n1, n2).Content()
		return cResult
	
	def RemoveManySections(paListOfSections)
		// TODO

		def RemoveManySectionsQ(paListOfSections)
			This.RemoveManySections(paListOfSections)

	def ManySectionsRemoved(paListOfSections)
		cResult = This.Copy().RemoveManySectionsQ(paListOfSections).Content()
		return This

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

	def RemoveManyRanges(paListOfRanges)
		// TODO

		def RemoveManyRangesQ(paListOfRanges)
			This.RemoveManySections(paListOfRanges)

	def ManyRangesRemoved(paListOfRanges)
		cResult = This.Copy().RemoveManyRangesQ(paListOfRanges).Content()
		return This

	  #----------------------------------------------------------#
	 #    TRIMMING & REMOVING SPACES, AND SIMPLIFYING STRING    # 
	#----------------------------------------------------------#

	def Trim()
		This.Update( This.QStringObject().trimmed() )

		def TrimQ()
			This.Trim()
			return This

	def Trimmed()
		cResult = This.Copy().TrimQ().Content()
		return cResult

	def TrimStart()
		if This.HasRepeatedLeadingChars()	
			This.RemoveRepeatedLeadingChar(" ")
		ok

		if This.FirstChar() = " "
			This.RemoveFirst(" ")
		ok

		def TrimStartQ()
			This.TrimStart()
			return This

	def TrimmedFromStart()
		cResult = This.Copy().TrimStartQ().Content()
		return cResult

	def TrimEnd()
		if This.HasRepeatedTrailingChars()	
			This.RemoveRepeatedTrailingChar(" ")
		ok

		if This.LastChar() = " "
			This.RemoveLast(" ")
		ok

		def TrimEndQ()
			This.TrimEnd()
			return This
	
	def TrimmedFromEnd()
		cResult = This.Copy().TrimEndQ().Content()
		return cResult

	def TrimLeft()
		if This.IsLeftToRight()
			This.TrimStart()

		else # IsRightToLeft
			This.TrimEnd()
		ok

		def TrimLeftQ()
			This.TrimLeft()
			return This

	def TrimmedFromLeft()
		cResult = This.Copy().TrimLeftQ().Content()
		return cResult

	def TrimRight()
		if This.IsRightToLeft()
			This.TrimStart()

		else # IsLeftToRight
			This.TrimEnd()
		ok

		def TrimRightQ()
			This.TrimRight()
			return This

	def TrimmedFromRight()
		cResult = This.Copy().TrimRightQ().Content()
		return cResult

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

	def RemoveLeftSpaces()
		This.TrimLeft()

		def RemoveLeftSpacesQ()
			This.RemoveLeftSpaces()
			return This

	def LeftSpacesRemoved()
		cResult = This.Copy().RemoveLeftSpacesQ().Content()
		return cResult

		def WithoutLeftSpaces()
			return This.LeftSpacesRemoved()

	def RemoveRightSpaces()
		This.TrimRight()

		def RemoveRightSpacesQ()
			This.RemoveRightSpaces()
			return This

	def RightSpacesRemoved()
		cResult = This.Copy().RemoveRightSpacesQ().Content()
		return cResult

		def WithoutRightSpaces()
			return This.RightSpacesRemoved()

	def RemoveLeadingSpaces()
		This.TrimStart()

		def RemoveLeadingSpacesQ()
			This.RemoveLeadingSpaces()
			return This

	def LeadingSpacesRemoved()
		cResult = This.Copy().RemoveLeadingSpacesQ().Content()
		return cResult

		def WithoutLeadingSpaces()
			return This.LeadingSpacesRemoved()

	def RemoveTrailingSpaces()
		This.TrimEnd()

		def RemoveTrailingSpacesQ()
			This.RemoveTrailingSpaces()
			return This

	def TrailingSpacesRemoved()
		cResult = This.Copy().RemoveTrailingSpacesQ().Content()
		return cResult

		def WithoutTrailingSpaces()
			return This.TrailingSpacesRemoved()

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

	// Aligns the text to the left of the container of width nWidth
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

		nWidth += This.NumberOfOccurrenceOf(ArabicShaddah())

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
 
		nWidth += This.NumberOfOccurrenceOf(ArabicShaddah())

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
 
		# nWidth += This.NumberOfArabicShaddah()
		nWidth += This.NumberOfOccurrence( ArabicShaddah() )

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
 
		nWidth += This.NumberOfOccurrence( ArabicShaddah() )

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
		oTempQStr = new QString()
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

		n = len( BinaryNumberPrefix() )

		str = This.Section( n + 1, This.NumberOfChars())
		oTempStr = new stzString(str)

		if This.NLeftChars(n) != BinaryNumberPrefix()
			return FALSE
		ok

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

		n = len( HexNumberPrefix() )

		str = This.Section( n + 1, This.NumberOfChars() )
		oTempStr = new stzString(str)

		if This.NLeftChars(n) != HexNumberPrefix()
			return FALSE
		ok

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

		n = len( OctalNumberPrefix() )

		str = This.Section( n + 1, This.NumberOfChars())
		oTempStr = new stzString(str)

		if This.NLeftChars(n) != OctalNumberPrefix()
			return FALSE
		ok

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

		#< @FunctionAlternativeForms

		def ToListOfChars()
			return This.Chars()

			#< @FunctionFluentForm

			def ToListOfCharsQR(pcType)
				if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
					pcReturnType = pcReturnType[2]
				ok

				switch pcType
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

			on :stzListOfSrings
				return new stzListOfStrings( This.Chars() )
			other
				stzRaise("Unsupported type!")
			off

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
		cCondition = StzStringQ(pcCondition).ReplaceAllCSQ("@char", "@item", :CS = FALSE).SimplifyQ().Content()	
		return StzListQ( This.ToListOfChars() ).ItemsW(cCondition)

		def CharsWhere(pcCondition)
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
	
		def MultiplyByQR(pValue, pcType)	
			if isList(pcReturnType) and StzListQ(pcReturnType).IsReturnedAsParamList()
				pcReturnType = pcReturnType[2]
			ok

			This.MultiplyBy(pValue)
	
			switch pcType
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
		
			:TextAdjustedTo = :Center # or :Left or :Right or :Along

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
			if oString.IsOneOfThese([ :Left, :Center, :Right, :Along ])

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
				   This.AlignQ(This.NumberOfChars(), " ", cTextAdjustedTo).Content() +
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
			return new stzString( This.BoxedXT(paBoxOptions) )

		#>

		def BoxedXT(paBoxOptions)
			return This.BoxedXTQ(paBoxOptions).Content()

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

		if NOT This.ScriptIs(:Latin)
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

	def IsListInString()
		Left = ""
		Right = ""

		if This.IsBoundedBy("[","]")	// Not sufficient!
			eval("aTempList = " + This.Content())
			eval( "bResult = isList( aTempList )" )
			return bResult

		but This.ContainsOnlyOne(":")

			Left = This.Split(":")[1]
			Right = This.Split(":")[2]

			
			if StzStringQ(Left).NumberOfChars() = 3 and
			   StzStringQ(Right).NumberOfChars() = 3 and

			   (AreBothNumbers(StzStringQ(Left)[2], StzStringQ(Right)[2]) or
			    AreBothAsciiChars(StzStringQ(Left)[2], StzStringQ(Right)[2]))

				return TRUE
			ok
				
		else
			return FALSE
		ok


	  #----------------------------------------------#
	 #     CALLING A STRING METHOD FROM OUTSIDE     #
	#----------------------------------------------#

	// A special function used to call the String object from the outside and
	// tell it to execute the defined method that is send as a parameter
	// See StringList.lstApplyFunc for more details
	def runMethod(cMeth, pParam)
		? ":::" ? pParam ? type(pParam)
		aMethods = methods(self)
		aParam = []

		if type(pParam) = "LIST"
			aParam = pParam
		else
			aParam + pParam
		ok

		//? aParam ? type(aParam)
	
		for m in aMethods
			if cMeth != "runMethod" and
			   cMeth != "init" and
			   isPrivateMethod(self,cMeth) = FALSE and
			   cMeth = m
				cCode = "return " + m + "("
				if len(aParam)>0
					for i=1 to len(aParam)-1
						if aParam[i] != NULL {
						cCode = " " + cCode + aParam[i] + ", " }
					next i
					if aParam[i] != NULL {
					cCode += aParam[i] + " " } # Adds the last param
				ok
				cCode += ")"
				
				return eval(cCode)
			ok
		end

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
			
			if type(pValue) = "NUMBER"
				return This.NthChar(pValue)
							
			but type(pValue) = "STRING"
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

	  #-------------------------------------------------#
	       PRIVATE #  Internal kitchen of the calss 
	#--------------------------------------------------#

	# Calculates the distance (number of Chars) between 2 positions
	def pvtDistance(nPos1,nPos2) # TODO ---> Move to stzPairOfNumbers()
		nDistance = fabs(nPos2 - nPos1) + 1
		return nDistance


