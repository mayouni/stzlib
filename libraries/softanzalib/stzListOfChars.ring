#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V1.0) - StzListOfChars			    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The core class for managing lists of chars        #
#	Version		: V1.0 (2020-2023)				    #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)		    #
#									    #
#---------------------------------------------------------------------------#

_cHilightChar = "•"

  /////////////////////
 ///   FUNCTIONS   ///
/////////////////////

func StzListOfCharsQ(p)
	return new stzListOfChars(p)

	func StzCharsQ(p)
		return StzListOfCharsQ(p)
	
func LC(p)
	if isList(p)
		return StzListQ(p).OnlyChars()

	but isString(p) and Q(p).IsListInString()
		aResult = Q(p).ToListQ().OnlyChars()
		return aResult

	but isNumber(p)
		aResult = []
		for i = 1 to p
			aResult + ""
		next
		return aResult

	ok

	func LCQ(p)
		return Q(LC(p))

		func QLC(p)
			return LCQ(p)

	func LoC(p)
		return LC(p)

		func LoCQ(p)
			return LCQ(p)

func IsListOfChars(paList)
	if CheckParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type!")
		ok
	ok

	bResult = TRUE
	nLen = len(paList)

	for i = 1 to nLen
		if NOT IsChar(paList[i])
			bResult = FALSE
			exit
		ok
	next i

	return bResult

	#< @FunctionAlternativeForms

	func @IsListOfChars(paList)
		return IsListOfChars(paList)

	func ListIsListOfChars(paList)
		return IsListOfChars(paList)

	#--

	func IsAListOfChars(paList)
		return IsListOfChars(paList)

	func @IsAListOfChars(paList)
		return IsListOfChars(paList)

	func ListIsAListOfChars(paList)
		return IsListOfChars(paList)

	#>

func HilightChar()
	return _cHilightChar
	
func SetHilightChar(c)
	if StringIsChar(c)
		_cHilightChar = c
	else
		StzRaise(:CanNotSetHilightChar)
	ok
	
func CharsToUnicodes(paList)
	return StzListOfCharsQ(paList).Unicodes()
	
	#< @FunctionAlternativeForms
	
	func CharsUnicodes(paList)
		return CharsToUnicodes(paList)
	
	func ListOfCharsToUnicodes(paList)
		return CharsToUnicodes(paList)

	#--

	func @CharsToUnicodes(paList)
		return CharsToUnicodes(paList)

	func @CharsUnicodes(paList)
		return CharsToUnicodes(paList)

	#>

func CharsToUnicodesXT(paList)
	return StzListOfCharsQ(paList).UnicodesXT()
	
	#< @FunctionAlternativeForms
	
	func CharsUnicodesXT(paList)
		return CharsToUnicodesXT(paList)
	
	func ListOfCharsToUnicodesXT(paList)
		return CharsToUnicodesXT(paList)

	#--

	func @CharsToUnicodesXT(paList)
		return CharsToUnicodesXT(paList)

	func @CharsUnicodesXT(paList)
		return CharsToUnicodesXT(paList)

	#>

func CharsNames(paList)
	return StzListOfCharsQ(paList).Names()

	func CharsToNames(paList)
		return CharsNames(paList)

	func @CharsNames(paList)
		return CharsNames(paList)

	func @CharsToNames(paList)
		return CharsNames(paList)

func CharsNamesXT(paList)
	return StzListOfCharsQ(paList).NamesXT()

	func CharsToNamesXT(paList)
		return CharsNamesXT(paList)

	func CharsNamesAndUnicodes(paList)
		return CharsNamesXT(paList)

	func @CharsNamesXT(paList)
		return CharsNamesXT(paList)

	func @CharsToNamesXT(paList)
		return CharsNamesXT(paList)

	func @CharsNamesAndUnicodes(paList)
		return CharsNamesXT(paList)

func CharsAndNames(paList)
	return StzListOfCharsQ(paList).CharsAndNames()

	func CharsAndTheirNames(palist)
		return CharsAndNames(paList)

	func @CharsAndNames(paList)
		return CharsAndNames(paList)

	func @CharsAndTheirNames(palist)
		return CharsAndNames(paList)

func CharsScripts(acListOfChars)
	return StzListOfCharsQ(acListOfChars).Scripts()

	#< @FunctionAlternativeForm

	func @CharsScripts(acListOfChars)
		return CharsScripts(acListOfChars)

	func ListOfCharsScripts(acListOfChars)
		return CharsScripts(acListOfChars)

	#>

# Used for natural-coding

func ListOfChars(paList)
	if ListIsListOfChars(paList)
		return paList
	ok

func ListOfLetters(paList)
	if ListIsListOfLetters(paList)
		return StzListOfCharsQ(paList).Uppercased()
	ok

func UnicodesNames(panUnicodes)
	if CheckParams()
		if NOT (isList(panUnicodes) and Q(panUnicodes).IsListOfNumbers())
			StzRaise("Incorrect param type! panUnicodes must be a list of numbers.")
		ok
	ok

	acResult = StzListOfCharsQ(panUnicodes).Names()
	return acResult

  /////////////////
 ///   CLASS   ///
/////////////////

class stzChars from stzListOfChars

class stzListOfChars from stzListOfStrings
	@aContent = []
	
	@aStzChars
	@cString

	def init(pValue)

		if isList(pValue) and Q(pValue).IsListOfNumbers()
			nLen = len(pValue)
			for i = 1 to nLen
				nUnicode = pValue[i]
				@aContent + StzCharQ(nUnicode).Content()
			next

		but isList(pValue) and Q(pValue).IsListOfChars()

			@aContent = pValue

		but isString(pValue)

			oStr = StzStringQ(pValue)
			nLen = oStr.NumberOfChars()

			@aContent = []
			for i = 1 to nLen
				@aContent + oStr.Char(i)
			next

		else
			StzRaise(stzListOfCharsError(:CanNotCreateListOfChars))
		ok

	def Content()
		return @aContent

		def ListOfChars()
			return This.Content()

		def Value()
			return Content()

	def Copy()
		return new stzListOfChars(This.Content())

	def NumberOfChars()
		return len(This.Content())

	def NthChar(n)
		return This.Content()[n]

		#< @FunctionAlternativeForms

		def CharAt(n)
			return This.Nthchar(n)

		#>

	#--

	def Update(paOtherListOfChars)
		if isList(paOtherListOfChars) and Q(paOtherListOfChars).IsWithOrByOrUsingNamedParam()
			paOtherListOfChars = paOtherListOfChars[2]
		ok

		if Q(paOtherListOfChars).IsListOfChars()
			@aContent = paOtherListOfChars
			@cString = Q(paOtherListOfChars).Concatenated()
			@aStzChars = Q(paOtherListOfChars).ToListOfStzChars()
		else
			StzRaise(stzListOfCharsError(:CanNotUpdateListOfChars)) # TODO
		ok

		#< @FunctionAlternativeForms

		def UpdateWith(paOtherListOfChars)
			This.Update(paOtherListOfChars)

			def UpdateWithQ(paOtherListOfChars)
				return This.UpdateQ(paOtherListOfChars)
	
		def UpdateBy(paOtherListOfChars)
			This.Update(paOtherListOfChars)

			def UpdateByQ(paOtherListOfChars)
				return This.UpdateQ(paOtherListOfChars)

		def UpdateUsing(paOtherListOfChars)
			This.Update(paOtherListOfChars)

			def UpdateUsingQ(paOtherListOfChars)
				return This.UpdateQ(paOtherListOfChars)

		#>

	def Updated(paOtherListOfChars)
		return paOtherListOfChars

		#< @FunctionAlternativeForms

		def UpdatedWith(paOtherListOfChars)
			return This.Updated(paOtherListOfChars)

		def UpdatedBy(paOtherListOfChars)
			return This.Updated(paOtherListOfChars)

		def UpdatedUsing(paOtherListOfChars)
			return This.Updated(paOtherListOfChars)

		#>

	#--

	def ToListOfStzChars()
		aResult = []

		for i = 1 to This.NumberOfChars()
			oTempchar = new stzChar( This.NthChar(i) )
			aResult + oTempChar
		next i

		return aResult

	def IsNeutral()

	def IsArabic()
		bArabic = TRUE
		// We should check only the letters
		// (exclude symbols, marks, punctuations...)
		for oStzChar in This.OnlyLettersAsStzChars()
			if NOT oStzChar.isArabicLetter()
				bArabic = FALSE
				exit
			ok
		next
		return bArabic

	def IsLatin()
		bLatin = TRUE

		for oStzChar in This.OnlyLettersAsStzChars()
			if NOT oStzChar.IsLatinLetter()
				bLatin = FALSE
				exit
			ok
		next
		return bLatin

	def ScriptIs(cScript)
		bResult = TRUE

		for oStzChar in This.OnlyLettersAsStzChars()
			cCode = "id NOT oStzChar.Is" + cScript + "letter()" + NL +
				TAB + "bResult = FALSE" + NL +
				"exist" + NL +
				"ok"
		next

		return bResult

	def OnlyLetters()
		aResult = []

		for oStzChar in This.ContentAsStzChars()
			if oStzChar.IsLetter()
				aResult + oStzChar.Content()
			ok
		next
		return aResult

	def OnlyLettersAsStzChars()
		aResult = []

		for oStzChar in This.ContentAsStzChars()
			if oStzChar.IsLetter()
				aResult + oStzChar
			ok
		next
		return aResult

	  #---------------------------------------------#
	 #   GETTING THE (UNICODE) NAMES OF THE CHARS  #
	#---------------------------------------------#

	def Names()
		acContent = This.Content()
		nLen = len(acContent)

		acResult = []

		for i = 1 to nLen
			acResult + StzCharQ(acContent[i]).Name()
		next

		return acResult

		#< @FunctionAlternativeForms

		def NamesInUnicode()
			return This.Names()

		def UnicodeNames()
			return This.Names()

		#>

	def NamesAndTheirUnicodes()
		aResult = Association([ This.Names(), This.Unicodes() ])
		return aResult

		def NamesXT()
			return This.NamesAndTheirUnicodes()

	def CharsAndTheirUnicodes()
		aResult = Association([ This.Chars(), This.Unicodes() ])
		return aResult

	def CharsAndTheirNames()
		aResult = Association([ This.Chars(), This.Names() ])
		return aResult

		def CharsXT()
			return This.CharsAndTheirNames()

		def CharsAndNames()
			return This.CharsAndTheirNames()

	def CharsAndTheirNamesAndTheirUnicodes()
		aResult = Assocciation([
			This.Chars(), This.Names(), This.Unicodes()
		])

		return aResult

		def CharsXTT()
			return This.CharsAndTheirNamesAndTheirUnicodes()

	def CharsAndTheirUnicodesAndTheirNames()
		aResult = Assocciation([
			This.Chars(), This.Unicodes(), This.Names()
		])

		return aResult

	  #---------------------------------------#
	 #    CONCATENATING CHARS IN A STRING    #
	#---------------------------------------#

	def Concatenate()
		return StzListOfStringsQ( This.Content() ).Concatenate()

		def ConcatenateQ()
			return new stzString( This.Concatenate() )

	  #-----------------------------#
	 #    UPPERCASING THE CHARS    #
	#-----------------------------#

	def Uppercased()
		acResult = []

		for oChar in This.ToListOfStzChars()
			acResult + oChar.Uppercased()
		next

		return acResult

	def ApplyUppercase()
		This.Update( This.Uppercased() )

	def Lowercased()
		acResult = []

		for oChar in This.ToListOfStzChars()
			acResult + oChar.Lowerrcased()
		next

		return acResult

	def ApplyLowercase()
		This.Update( This.Lowercased() )

	  #-------------------------#
	 #     BOXING THE CHARS    #
	#-------------------------#
	
	def Boxed()
		return This.BoxedXT([])

	def BoxedDashed()
		return This.BoxedXT([ :Line = :Dashed ])

	def BoxedRound()
		return This.BoxedXT([ :AllCorners = :Round ])

	def BoxedRoundDashed()
		return This.BoxedXT([ :Line = :Dashed, :AllCorners = :Round ])

	def BoxedDashedRound()
		return This.BoxedRoundDashed()

	def BoxedXT(paBoxOptions)

		/*
		Example:

		? StzListOfCharsQ("TEXT").BoxedXT([
			:Line = :Thin,	# or :Dashed
		
			:AllCorners = :Round # can also be :Rectangualr

			# Or you can specify evey corner like this:
			# :Corners = [ :Round, :Rectangular, :Round, :Rectangular ],

			# :Hilighted = [ 3 ] # The 3rd char is hilighted
		
		])

		--> Gives:
		╭───┬───┬───┬───╮
		│ T │ E │ X │ T │
		╰───┴───┴─•─┴───╯	
		*/
		
		if StzListQ(paBoxOptions).IsTextBoxedOptionsNamedParam()

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

			# Reading the hilightening option
			
			aHilighted = NULL

			if isList(paBoxOptions[ :Hilighted ]) and
			   # len( paBoxOptions[ :Hilighted ] ) <= This.NumberOfChars() and
			   StzListQ(paBoxOptions[ :Hilighted ]).IsListOfNumbers() and
			   ListIsSet( paBoxOptions[ :Hilighted ] )

				if StzListQ( paBoxOptions[ :Hilighted ] ).IsMadeOfSome( 1:This.NumberOfChars() )
					aHilighted = paBoxOptions[ :Hilighted ]

				else

					aHilighted = []
					for n in paBoxOptions[ :Hilighted ]
						if n <= This.NumberOfChars()
							aHilighted + n
						ok
					next

				ok
			ok

			# Reading the hilightening condition

			cHilightIf = NULL
		
			if paBoxOptions[ :HilightedIf ] != NULL
				cHilightIf = paBoxOptions[ :HilightedIf ]
			ok

			# Reading the numbering option

			bNumbered = FALSE

			if paBoxOptions[ :Numbered ] != NULL and
			   paBoxOptions[ :Numbered ] = TRUE

				bNumbered = TRUE
			ok

			# Composing the boxed list of strings

			cVTrait  = "│"		cUpSep   = "┬"

			cHTrait  = "───"	cDownSep = "┴"

			cHilight = "─" + HilightChar() + "─"

			if cLine = :Dashed
				cHTrait = "╌╌╌"
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

			nWidth = This.NumberOfChars()

			cUpLine = cCorner1 +
				  StzStringQ(cHTrait + cUpSep).RepeatedNTimes(nWidth-1) +
				  cHTrait + cCorner2 

			
			cMidLine = cVTrait

			for c in This.ListOfChars()
				cMidLine += " " + c + " " + cVTrait
			next

			if NOT isList(aHilighted)
				cDownLine = cCorner4 +
					  StzStringQ(cHTrait + cDownSep).RepeatedNTimes(nWidth-1) +
					  cHTrait + cCorner3

			else
				# Hilight some chars

				cDownLine = cCorner4
				cTrait = ""

				for i = 1 to nWidth - 1

					if StzListQ(aHilighted).Contains(i) 
						cTrait = cHilight

					else
						cTrait = cHTrait
					ok

					cDownLine += cTrait + cDownSep				

				next

				# Speciefic case of the last char

				if StzListQ(aHilighted).Contains(nWidth)
					cDownLine += cHilight + cCorner3
				else
					cDownLine += cHTrait + cCorner3
				ok

			ok

			cResult = cUpLine + NL + cMidLine + NL + cDownLine

			cNumberLine = ""

			if bNumbered
				oCounter = new stzCounter([
					:StartAt = 1,
					:AfterYouSkip = 9,
					:RestartAt = 0,
					:Step = 1
				])

				aNumbers = oCounter.CountingTo( nWidth )

				for i = 1 to nWidth
					cNumberLine += "  " + aNumbers[i] + " "
				next
				cResult += NL + cNumberLine
			ok

			return cResult
			

		else
			StzRaise(stzListOfCharsError(:CanNotBoxTheListOfChars))
		ok

	  #--------------------------------------------------#
	 #  GETTING THE UNICODE (CODE NUMBER) OF EACH CHAR  #
	#==================================================#

	def Unicodes()
		
		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen
			aResult + @Unicode(aContent[i])
		next

		return aResult

		def UnicodesQR(pcReturnType)
			if isList(pcReturnType) and StzListQ(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Unicodes() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Unicodes() )

			other
				StzRaise("Unsupported return type!")
			off

	def CharsAndUnicodes()
		aResult = []


		for char in This.ListOfChars()
			aResult + [ This.Content(), StzCharQ(char).Unicode() ]
		next

		return aResult

	def UnicodesXT()
		aResult = Association([ This.Unicodes(), This.Chars() ])
		return aResult


		def UnicodesAndChars()
			return This.UnicodesXT()

	  #----------------#
	 #     SCRIPTS    #
	#----------------#

	def Scripts()
		acResult = []

		for char in This.ListOfChars()
			acResult + StzCharQ(char).Script()
		next

		return acResult

	 #-----------#
	 #   MISC.   #
	#-----------#

	def AllCharsAreNumbers()
		bResult = TRUE

		for c in This.ListOfChars()
			if NOT StzCharQ(c).IsNumber()
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def AllCharsAreLetters()
		bResult = TRUE

		for c in This.ListOfChars()
			if NOT StzCharQ(c).IsLetter()
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def IsContiguous()
		return This.UnicodesQR(:stzListOfNumbers).IsContiguous()

		def IsContinuous()
			return This.IsContiguous()
