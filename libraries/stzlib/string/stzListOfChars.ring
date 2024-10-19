#---------------------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V1.0) - StzListOfChars		    #
#		An accelerative library for Ring applications		    #
#---------------------------------------------------------------------------#
#									    #
# 	Description	: The class for managing lists of chars             #
#	Version		: V1.0 (2020-2024)				    #
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
	
func AreChars(pacChars)
	if CheckParams()
		if NOT islist(pacChars)
			StzRaise("Incorrect param type! pacChars must be a list.")
		ok
	ok

	nLen = len(pacChars)
	bResult = TRUE

	for i = 1 to nLen
		if NOT ( isString(pacChars[i]) and @IsChar(pacChars[i]) )
			bResult = FALSE
			exit
		ok
	next
	return bResult

	func @AreChars(pacChars)
		return AreChars(pacChars)

func AreBothChars(p1, p2)
	return AreChars([ p1, p2 ])

	func BothAreChars(p1, p2)
		return AreBothChars(p1, p2)
	
	func @AreBothChars(p1, p2)
		return AreBothChars(p1, p2)

	func @BothAreChars(p1, p2)
		return AreBothChars(p1, p2)

func AreBothAsciiChars(p1, p2)
	if IsAsciiChar(p1) and IsAsciiChar(p2)
		return TRUE
	else
		return FALSE
	ok

	func BothAreAsciiChars(p1, p2)
		return AreBothAsciiChars(p1, p2)

	func @AreBothAsciiChars(p1, p2)
		return AreBothAsciiChars(p1, p2)

	func @BothAreAsciiChars(p1, p2)
		return AreBothAsciiChars(p1, p2)

#--

func AreLetters(pacLetters)
	if CheckParams()
		if NOT islist(pacLetters)
			StzRaise("Incorrect param type! pacLetters must be a list.")
		ok
	ok

	nLen = len(pacLetters)
	bResult = TRUE

	for i = 1 to nLen
		if NOT ( isString(pacLetters[i]) and @IsLetter(pacLetters[i]) )
			bResult = FALSE
			exit
		ok
	next
	return bResult

	func @AreLetters(pacLetters)
		return AreLetters(pacLetters)

func AreBothLetters(p1, p2)
	return AreLetters([ p1, p2 ])

	func BothAreLetters(p1, p2)
		return AreBothLetters(p1, p2)
	
	func @AreBothLetters(p1, p2)
		return AreBothLetters(p1, p2)

	func @BothAreLetters(p1, p2)
		return AreBothLetters(p1, p2)
#--

func CharsBetween(c1, c2)

	if CheckParams()
		if isList(c2) and StzlistQ(c2).IsAndNamedParam()
			c2 = c2[2]
		ok

		if NOT @BothAreChars(c1, c2)
			StzRaise("Incorrect param type!")
		ok
	ok

	nUnicode1 = Unicode(c1)
	nUnicode2 = Unicode(c2)

	nStep = 1
	if nUnicode1 > nUnicode2
		nStep = -1
	ok

	acResult = []
	for i = nUnicode1 to nUnicode2 step nStep
		acResult + StzCharQ(i).Content()
	next

	return acResult

func NumberOfCharsBetween(c1, c2)
	if CheckParams()
		if NOT @BothAreChars(c1, c2)
			StzRaise("Incorrect param type!")
		ok
	ok

	nUnicode1 = Unicode(c1)
	nUnicode2 = Unicode(c2)

	nResult = Abs(nUnicode2 - nUnicode1) + 1
	return nResult

	func HowManyCharsBetween(c1, c2)
		return NumberOfCharsBetween(c1, c2)

func HilightChar()
	return _cHilightChar
	
func SetHilightChar(c)
	if @IsChar(c)
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
	if @IsListOfChars(paList)
		return paList
	ok

func ListOfLetters(paList)
	if @IsListOfLetters(paList)
		return StzListOfCharsQ(paList).Uppercased()
	ok

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

		def HowManyChars()
			return This.NumberOfChars()

		def SizeInChars()
			return This.NumberOfChars()

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
			StzRaise(stzListOfCharsError(:CanNotUpdateListOfChars)) #TODO
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

	def IsArabic()

		bResult = TRUE

		// We should check only the letters
		// (exclude symbols, marks, punctuations...)

		aoStzChars = This.OnlyLettersAsStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			if NOT aoStzChars[i].isArabicLetter()
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def IsLatin()

		bResult = TRUE

		// We should check only the letters
		// (exclude symbols, marks, punctuations...)

		aoStzChars = This.OnlyLettersAsStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			if NOT aoStzChars[i].isLatinLetter()
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def ScriptIs(cScript)

		bResult = TRUE

		// We should check only the letters
		// (exclude symbols, marks, punctuations...)

		aoStzChars = This.OnlyLettersAsStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			cCode = 'bResult = aoStzChars[i].Is' + cScript + 'letter()'
			eval(cCode)
			if bResult = FALSE
				exit
			ok
		next

		return bResult


	def OnlyLetters()

		acResult = []

		aoStzChars = This.OnlyLettersAsStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			if aoStzChars[i].IsLetter()
				aResult + aoStzChars[i].Content()
			ok
		next

		return acResult

	def OnlyLettersAsStzChars()
		acResult = []

		aoStzChars = This.OnlyLettersAsStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			if aoStzChars[i].IsLetter()
				aResult + aoStzChars[i]
			ok
		next

		return acResult

	  #---------------------------------------------#
	 #   GETTING THE (UNICODE) NAMES OF THE CHARS  #
	#---------------------------------------------#

	def Names()
		acContent = This.Content()
		nLen = len(acContent)

		acResult = []

		for i = 1 to nLen
			cName = StzCharQ(acContent[i]).Name()
			acResult + cName
		next

		return acResult

		#< @FunctionAlternativeForm

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

	  #-------------------------#
	 #     BOXING THE CHARS    #
	#-------------------------#
	
	def Boxed()
		return This.BoxedXT([])

		def Boxified()
			return Boxed()

	def BoxedDashed()
		return This.BoxedXT([ :Line = :Dashed ])

		def BoxifiedDashed()
			return This.BoxedDashed()

	def BoxedRound()
		return This.BoxedXT([ :Rounded = TRUE, :AllCorners = :Round ])

		def BoxifiedRound()
			return This.BoxedRound()

		def BoxdedRounded()
			return This.BoxedRound()

		def BoxifiedRounded()
			return This.BoxedRound()

	def BoxedRoundDashed()
		return This.BoxedXT([ :Rounded = TRUE, :Line = :Dashed, :AllCorners = :Round ])

		#< @FunctionAlternativeForms

		def BoxedRoundedDashed()
			return This.BoxedRoundDashed()

		def BoxifiedRoundDashed()
			return This.BoxedRoundDashed()

		def BoxifiedRoundedDashed()
			return This.BoxedRoundDashed()

		def BoxedDashedRound()
			return This.BoxedRoundDashed()

		def BoxedDashedRounded()
			return This.BoxedRoundDashed()

		def BoxifiedDashedRound()
			return This.BoxedRoundDashed()

		def BoxifiedDashedRounded()
			return This.BoxedRoundDashed()

		#>

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

			# Reading if the box is rounded

			bRounded = NULL # By default

			if isNumber(paBoxOptions[ :Rounded ])

				if paBoxOptions[ :Rounded ] = TRUE
					bRounded = TRUE

				but paBoxOptions[ :Rounded ] = FALSE
					bRounded = FALSE

				ok
			ok

			# Reading the type of corners (rectangualar or round)

			cAllCorners = :Rectangular # By default

			if paBoxOptions[ :AllCorners ] = :Round or
			   paBoxOptions[ :AllCorners ] = :Rounded

				if isString(bRounded) and bRounded = NULL
					bRounded = TRUE
				ok

				cAllCorners = :Round
			ok

			aCorners = []

			if cAllCorners = :Rectangular or cAllCorners = :Rect

				if isString(bRounded) and bRounded = NULL
					bRounded = TRUE
				ok

				 # By default
				aCorners = [ :Rectangular, :Rectangular, :Rectangular, :Rectangular ]

			but cAllCorners = :Round or cAllCorners = :Rounded

				if isString(bRounded) and bRounded = NULL
					bRounded = TRUE
				ok

				aCorners = [ :Round, :Round, :Round, :Round ]

			ok

			if len(paBoxOptions[:Corners]) = 4 and
			   StzListQ( paBoxOptions[:Corners] ).IsMadeOfSome([ :Rectangular, :Round ])
	
				if isString(bRounded) and bRounded = NULL
					bRounded = TRUE
				ok

				aCorners = paBoxOptions[:Corners]

			ok

			if bRounded = TRUE and
			   ring_find(aCorners, :round) = 0

				aCorners = [ :round, :round, :round, :round ]
			ok

			# Reading the hilightening option
			
			anHilighted = []

			if isList(paBoxOptions[ :Hilighted ]) and
			   # len( paBoxOptions[ :Hilighted ] ) <= This.NumberOfChars() and
			   StzListQ(paBoxOptions[ :Hilighted ]).IsListOfNumbers() and
			   @IsSet( paBoxOptions[ :Hilighted ] )

				if StzListQ( paBoxOptions[ :Hilighted ] ).IsMadeOfSome( 1:This.NumberOfChars() )
					anHilighted = paBoxOptions[ :Hilighted ]

				else

					anTemp = paBoxOptions[ :Hilighted ]
					nLenTemp = len(anTemp)

					anHilighted = []

					for i = 1 to nLenTemp
						if anTemp[i] <= This.NumberOfChars()
							anHilighted + anTemp[i]
						ok
					next

				ok
			ok

			# Reading the Hiligthening char

			cSign = HilightChar()

			if ( paBoxOptions[ :PositionSign ] != NULL and @IsChar(paBoxOptions[ :PositionSign ]) ) or
			   ( paBoxoptions[ :PositionChar ] != NULL and @IsChar(paBoxOptions[ :PositionChar ]) )

				cSign = paBoxOptions[ :PositionSign ]
			ok

			# Reading the numbering option

			bNumbered = FALSE

			if (paBoxOptions[ :Numbered ] != NULL and
			   paBoxOptions[ :Numbered ] = TRUE) or

			   (paBoxOptions[ :Numbers ] != NULL and
			   paBoxOptions[ :Numbers ] = TRUE) or

			   (paBoxOptions[ :ShowPositions ] != NULL and
			   paBoxOptions[ :ShowPositions ] = TRUE)

				bNumbered = TRUE
			ok

			# Reading the numbering option

			bNumberedXT = FALSE

			if (paBoxOptions[ :NumberedXT ] != NULL and
			   paBoxOptions[ :NumberedXT ] = TRUE) or

			   (paBoxOptions[ :NumbersXT ] != NULL and
			   paBoxOptions[ :NumbersXT ] = TRUE) or

			   (paBoxOptions[ :ShowPositionsXT ] != NULL and
			   paBoxOptions[ :ShowPositionsXT ] = TRUE) or

			   (paBoxOptions[ :ShowAllPositions ] != NULL and
			   paBoxOptions[ :ShowAllPositions ] = TRUE) or

			   (paBoxOptions[ :AllPositions ] != NULL and
			   paBoxOptions[ :AllPositions ] = TRUE)

				bNumberedXT = TRUE
			ok

			# Reading the sectioned option

			bSectioned = FALSE

			if paBoxOptions[:Sectioned] != NULL and
			   paBoxOptions[:Sectioned] = TRUE

				bSectioned = TRUE
			ok

			# Composing the boxed list of strings

			cVTrait  = "│"		cUpSep   = "┬"

			cHTrait  = "───"	cDownSep = "┴"

			cHilight = "─" + cSign + "─"

			if cLine = :Dashed
				cHTrait = "╌╌╌"
				cVTrait = "┊"
			ok
			
			cCorner1 = "┌"
			cCorner2 = "┐"
			cCorner3 = "┘"
			cCorner4 = "└"

			if bRounded = TRUE
				
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
			ok

			#--

			nWidth = This.NumberOfChars()

			cTemp = ""
			for i = 1 to nWidth-1
				cTemp += (cHTrait + cUpSep)
			next
			
			cUpline = cCorner1 + cTemp + cHTrait + cCorner2

			cMidLine = cVTrait

			acChars = This.Content()
			nLen = len(acChars)

			for i = 1 to nLen
				cMidLine += " " + acChars[i] + " " + cVTrait
			next

			#--

			if NOT isList(anHilighted)

				cTemp = ""
				for i = 1 to nWidth-1
					cTemp += (cHTrait + cDownSep)
				next

				cDownLine = cCorner4 + cTemp + cHTrait + cCorner3

			else
				# Hilight some chars

				cDownLine = cCorner4
				cTrait = ""

				for i = 1 to nWidth - 1

					if ring_find(anHilighted, i) > 0
						cTrait = cHilight

					else
						cTrait = cHTrait
					ok

					cDownLine += cTrait + cDownSep				

				next

				# Speciefic case of the last char

				if ring_find(anHilighted, nWidth)
					cDownLine += cHilight + cCorner3
				else
					cDownLine += cHTrait + cCorner3
				ok

			ok

			cResult = cUpLine + NL + cMidLine + NL + cDownLine

			# Constructing the sectioned parts

			oDownLine = new stzString(cDownLine)
			nLenDownLine = oDownLine.NumberOfChars()

			cSpaceLine = ""
			for i = 1 to nLenDownLine
				cSpaceLine += " "
			next

			if bSectioned = TRUE

				anPosSign = oDownLine.Find(cSign)
				nLenPosSign = len(anPosSign)
	
				aSections = []
				aSection = []
	
				for i = 1 to nLenPosSign
					aSection + anPosSign[i]
					if len(aSection) = 2
						aSections + aSection
						aSection = []
					ok
				next
	
				nLenSections = len(aSections)
	
				acSegments = []
	
				for i = 1 to nLenSections
	
					cSegment = ""
	
					n1 = aSections[i][1]
					n2 = aSections[i][2]
	
					for j = n1 to n2
						if j = n1 or j = n2
							cSegment += "'"
						else
							cSegment += "-"
						ok
					next
	
					acSegments + cSegment
					
				next
	
				oSectionLine = new stzString(cSpaceLine)
				oSectionLine.ReplaceSectionsByMany(aSections, acSegments)
				cSectionsLine = oSectionLine.TrimRightQ().Content()
	
				cResult += NL + cSectionsLine
			ok

			# Constructing the positions line

			cNumbersLine = ""

			if bNumbered or bNumberedXT

				anPosSign = oDownLine.Find(cSign)
				nLenPosSign = len(anPosSign)
	
				aSections = []
				aSection = []
	
				for i = 1 to nLenPosSign
					aSection + anPosSign[i]
					if len(aSection) = 2
						aSections + aSection
						aSection = []
					ok
				next
	
				nLenSections = len(aSections)
	
				acSegments = []
	

				for i = 1 to nLenSections
	
					cSegment = ""
	
					n1 = aSections[i][1]
					n2 = aSections[i][2]

					nLen1 = len(""+n1)
					nLen2 = len(""+n2)
					nDiff = n2 - n1 - (nLen1-1) - (nLen2-1)

					n = 0
					for j = n1 to n2
						n++

						if j = n1
							cSegment += ""+ n1

						but j = n2
							cSegment += ""+ n2
						else
							if n <= nDiff
								cSegment += " "
							ok
						ok
					next
	
					acSegments + cSegment
					
				next
	
				oSectionLine = new stzString(cSpaceLine)
				oSectionLine.ReplaceSectionsByMany(aSections, acSegments)
				cNumbersLine = oSectionLine.TrimRightQ().Content()
	
			ok

			cResult += NL + cNumbersLine
			return cResult
			

		else
			StzRaise(stzListOfCharsError(:CanNotBoxTheListOfChars))
		ok

		#< @FunctionAlternativeForms

		def BoxifiedXT(paBoxOptions)
			return This.BoxedXT(paBoxOptions)

		def BoxXT(paBoxOptions)
			return This.BoxedXT(paBoxOptions)

		def BoxifyXT(paBoxOptions)
			return This.BoxedXT(paBoxOptions)

		#>

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

		aoStzChars = This.ToListOfStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			aResult + [ aoStzChars[i].Content(), aoStzChars[i].Unicode() ]
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

		aoStzChars = This.ToListOfStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			acResult + aoStzChars[i].Script()
		next

		return acResult

	 #-----------#
	 #   MISC.   #
	#-----------#

	def AllCharsAreNumbers()
		bResult = TRUE

		aoStzChars = This.ToListOfStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			if NOT aoStzChars[i].IsNumber()
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def AllCharsAreLetters()
		bResult = TRUE

		aoStzChars = This.ToListOfStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			if NOT aoStzChars[i].IsLetter()
				bResult = FALSE
				exit
			ok
		next

		return bResult

	def IsContiguous()
		return This.UnicodesQR(:stzListOfNumbers).IsContiguous()

		def IsContinuous()
			return This.IsContiguous()
