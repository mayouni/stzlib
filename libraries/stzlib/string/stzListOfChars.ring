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
	if CheckingParams()
		if NOT islist(pacChars)
			StzRaise("Incorrect param type! pacChars must be a list.")
		ok
	ok

	nLen = len(pacChars)
	bResult = _TRUE_

	for i = 1 to nLen
		if NOT ( isString(pacChars[i]) and @IsChar(pacChars[i]) )
			bResult = _FALSE_
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
		return _TRUE_
	else
		return _FALSE_
	ok

	func BothAreAsciiChars(p1, p2)
		return AreBothAsciiChars(p1, p2)

	func @AreBothAsciiChars(p1, p2)
		return AreBothAsciiChars(p1, p2)

	func @BothAreAsciiChars(p1, p2)
		return AreBothAsciiChars(p1, p2)

#--

func AreLetters(pacLetters)
	if CheckingParams()
		if NOT islist(pacLetters)
			StzRaise("Incorrect param type! pacLetters must be a list.")
		ok
	ok

	nLen = len(pacLetters)
	bResult = _TRUE_

	for i = 1 to nLen
		if NOT ( isString(pacLetters[i]) and @IsLetter(pacLetters[i]) )
			bResult = _FALSE_
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

	if CheckingParams()
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
	if CheckingParams()
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

	func HilightSign()
		return _cHilightChar

	func PositionChar()
		return _cHilightChar

	func PositionSign()
		return _cHilightChar

func SetHilightChar(c)
	if @IsChar(c)
		_cHilightChar = c
	else
		StzRaise(:CanNotSetHilightChar)
	ok

	func SetHilightSign(c)
		SetHilightChar(c)

	func SetPositionChar(c)
		SetHilightChar(c)

	func SetPositionSign(c)
		SetHilightChar(c)



	
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

		if KeepingHistory() = _TRUE_
			This.AddHistoricValue(This.Content())
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
		if CheckingParams() = _TRUE_
			if isList(paOtherListOfChars) and Q(paOtherListOfChars).IsWithOrByOrUsingNamedParam()
				paOtherListOfChars = paOtherListOfChars[2]
			ok

			if NOT @IsListOfChars(paOtherListOfChars)
				StzRaise("Incorrect param type! paOtherListOfChars must be a list of chars.")
			ok
		ok

		@aContent = paOtherListOfChars
		@cString = Q(paOtherListOfChars).Concatenated()
		@aStzChars = Q(paOtherListOfChars).ToListOfStzChars()

		if KeepingHisto() = _TRUE_
			This.AddHistoricValue(This.Content())  # From the parent stzObject
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

		_acContent_ = This.Content()
		_nLen_ = len(_acContent_)
		_aResult_ = []

		for @i = 1 to _nLen_
			_oTempchar_ = new stzChar( _acContent_[@i] )
			_aResult_ + _oTempChar_
		next

		return _aResult_

	def IsArabic()

		bResult = _TRUE_

		// We should check only the letters
		// (exclude symbols, marks, punctuations...)

		aoStzChars = This.OnlyLettersAsStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			if NOT aoStzChars[i].isArabicLetter()
				bResult = _FALSE_
				exit
			ok
		next

		return bResult

	def IsLatin()

		bResult = _TRUE_

		// We should check only the letters
		// (exclude symbols, marks, punctuations...)

		aoStzChars = This.OnlyLettersAsStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			if NOT aoStzChars[i].isLatinLetter()
				bResult = _FALSE_
				exit
			ok
		next

		return bResult

	def ScriptIs(cScript)

		bResult = _TRUE_

		// We should check only the letters
		// (exclude symbols, marks, punctuations...)

		aoStzChars = This.OnlyLettersAsStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			cCode = 'bResult = aoStzChars[i].Is' + cScript + 'letter()'
			eval(cCode)
			if bResult = _FALSE_
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

	  #=========================#
	 #     BOXING THE CHARS    #
	#=========================#
	
	def Box()
		return This.BoxedXT([])

		def Boxed()
			return This.Box()

		def Boxified()
			return This.Box()

		def Boxify()
			return This.Box()

	def BoxDash()
		return This.BoxedXT([ :Line = :Dashed ])

		#< @FunctionAlternativeForms

		def BoxedDashed()
			return This.BoxDash()

		def BoxifyDash()
			return This.BoxDash()

		def BoxifiedDashed()
			return This.BoxDash()

		#>

	def BoxRound()
		return This.BoxedXT([ :Rounded = _TRUE_, :AllCorners = :Round ])

		#< @FunctionAlternativeForms

		def BoxedRounded()
			return This.BoxRound()

		def BoxifyRound()
			return This.BoxRound()

		def BoxifiedRounded()
			return This.BoxRound()

		#>


	def BoxRoundDash()
		return This.BoxedXT([ :Rounded = _TRUE_, :Line = :Dashed, :AllCorners = :Round ])

		#< @FunctionAlternativeForms

		def BoxDashRound()
			return This.BoxRoundDash()

		#--

		def BoxedRoundedDashed()
			return This.BoxRoundDash()

		def BoxedDashedRounded()
			return This.BoxRoundDash()

		#==

		def BoxifyRoundDash()
			return This.BoxRoundDash()

		def BoxifyDashRound()
			return This.BoxRoundDash()

		def BoxifiedRoundedDashed()
			return This.BoxRoundDash()

		def BoxifiedDashedRounded()
			return This.BoxRoundDash()

		#>

	def BoxXT(paBoxOptions)

		/*
		Example:

		? StzListOfCharsQ("TEXT").BoxXT([
			:Line = :Solid,	# or :Dashed
		
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

		if NOT isList(paBoxOptions)
			StzRaise("Incorrect param type! paBoxOptions must be a list.")
		ok

		# Checking the hashlist of params

		if StzListQ(paBoxOptions).IsTextBoxedOptionsNamedParam()

			# Reading the type of line (thin or dashed)

			cLine = :Solid # By default

			if paBoxOptions[ :Line ] = :Dashed
				cLine = :Dashed
			ok

			if isNumber(paBoxOptions[ :Solid ]) and
			   paBoxOptions[ :Solid ] = _TRUE_

					cLine = :Solid

			but isNumber(paBoxOptions[ :Dashed ]) and
			    paBoxOptions[ :Dashed ] = _TRUE_

					cLine = :Dashed
			ok

			# Reading if the box is rounded

			bRounded = _NULL_ # By default

			if isNumber(paBoxOptions[ :Rounded ])

				if paBoxOptions[ :Rounded ] = _TRUE_
					bRounded = _TRUE_

				but paBoxOptions[ :Rounded ] = _FALSE_
					bRounded = _FALSE_

				ok
			ok

			# Reading the type of corners (rectangualar or round)

			cAllCorners = :Rectangular # By default

			if paBoxOptions[ :AllCorners ] = :Round or
			   paBoxOptions[ :AllCorners ] = :Rounded

				if isString(bRounded) and bRounded = _NULL_
					bRounded = _TRUE_
				ok

				cAllCorners = :Round
			ok

			aCorners = []

			if cAllCorners = :Rectangular or cAllCorners = :Rect

				if isString(bRounded) and bRounded = _NULL_
					bRounded = _FALSE_
				ok

				 # By default
				aCorners = [ :Rectangular, :Rectangular, :Rectangular, :Rectangular ]

			but cAllCorners = :Round or cAllCorners = :Rounded

				if isString(bRounded) and bRounded = _NULL_
					bRounded = _TRUE_
				ok

				aCorners = [ :Round, :Round, :Round, :Round ]

			ok

			if len(paBoxOptions[:Corners]) = 4 and
			   StzListQ( paBoxOptions[:Corners] ).IsMadeOfSome([ :Rectangular, :Round ])
	
				if isString(bRounded) and bRounded = _NULL_
					bRounded = _TRUE_
				ok

				aCorners = paBoxOptions[:Corners]

			ok

			if bRounded = _TRUE_ and
			   ring_find(aCorners, :round) = 0

				aCorners = [ :round, :round, :round, :round ]
			ok

			if len(aCorners) = 0 and bRounded = _NULL_
				if isString(bRounded) and bRounded = _NULL_
					bRounded = _FALSE_
				ok
			ok

			# Reading the hilightening option
			
			anHilighted = []

			if paBoxOptions[ :Hilight ] != _NULL_ or
			   paBoxOptions[ :HilightPositions ] != _NULL_ or
			   paBoxOptions[ :ShowPositions ] != _NULL_

				for i = 1 to len(paBoxOptions)
					if paBoxOptions[i][1] = :Hilight or
					   paBoxOptions[i][1] = :HilightPositions or
					   paBoxOptions[i][1] = :ShowPositions

						paBoxOptions[i][1] = :Hilighted
					ok
				next
			ok

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

			if ( paBoxOptions[ :PositionSign ] != _NULL_ and @IsChar(paBoxOptions[ :PositionSign ]) )
				cSign = paBoxOptions[ :PositionSign ]

			but ( paBoxoptions[ :PositionChar ] != _NULL_ and @IsChar(paBoxOptions[ :PositionChar ]) )
				cSign = paBoxOptions[ :PositionChar ]

			but ( paBoxOptions[ :HilightSign ] != _NULL_ and @IsChar(paBoxOptions[ :HilightSign ]) )
				cSign = paBoxOptions[ :HilightSign ]

			but ( paBoxoptions[ :HilightChar ] != _NULL_ and @IsChar(paBoxOptions[ :HilightChar ]) )
				cSign = paBoxOptions[ :HilightChar ]

			ok

			# Reading the numbering option

			bNumbered = _FALSE_

			if (paBoxOptions[ :Numbered ] != _NULL_ and
			   paBoxOptions[ :Numbered ] = _TRUE_) or

			   (paBoxOptions[ :Numbers ] != _NULL_ and
			   paBoxOptions[ :Numbers ] = _TRUE_) or

			   (paBoxOptions[ :ShowPositions ] != _NULL_ and
			   paBoxOptions[ :ShowPositions ] = _TRUE_)

				bNumbered = _TRUE_
			ok

			# Reading the numbering option

			bNumbered = _FALSE_

			if (paBoxOptions[ :Numbered ] != _NULL_ and
			   paBoxOptions[ :Numbered ] = _TRUE_) or

			   (paBoxOptions[ :Numbers ] != _NULL_ and
			   paBoxOptions[ :Numbers ] = _TRUE_) or

			   (paBoxOptions[ :ShowPositions ] != _NULL_ and
			   paBoxOptions[ :ShowPositions ] = _TRUE_)

				bNumbered = _TRUE_
			ok

			#---

			bNumberedXT = _FALSE_

			if (paBoxOptions[ :NumberedXT ] != _NULL_ and
			   paBoxOptions[ :NumberedXT ] = _TRUE_) or

			   (paBoxOptions[ :NumbersXT ] != _NULL_ and
			   paBoxOptions[ :NumbersXT ] = _TRUE_) or

			   (paBoxOptions[ :ShowPositionsXT ] != _NULL_ and
			   paBoxOptions[ :ShowPositionsXT ] = _TRUE_) or

			   (paBoxOptions[ :ShowAllPositions ] != _NULL_ and
			   paBoxOptions[ :ShowAllPositions ] = _TRUE_) or

			   (paBoxOptions[ :AllPositions ] != _NULL_ and
			   paBoxOptions[ :AllPositions ] = _TRUE_)

				bNumberedXT = _TRUE_
				bNumbered = _FALSE_
			ok

			# Reading the sectioned option

			bSectioned = _FALSE_

			if paBoxOptions[:Sectioned] != _NULL_ and
			   paBoxOptions[:Sectioned] = _TRUE_

				bSectioned = _TRUE_
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

			if bRounded = _TRUE_
				
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

			if bSectioned = _TRUE_
	
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

			# Constructing the positions line, depending on wether the
			# :Sectioned option is requested or not

			#NOTE // :Sectioned option is used internally by
			# the vizFindBoxedZZ() function in stzString

			cNumbersLine = ""

			if bNumberedXT or (bNumbered and len(anHilighted) = 0)

				oMidLine = new stzString(cMidLine)
				anPos = oMidLine.FindMany(This.Content())

				acNumbers = []

				for i = 1 to nLen
					acNumbers + (""+ i )
				next
				
				aSections = []

				for i = 1 to nLen
					n1 = anPos[i]
					n2 = n1 + ( len(acNumbers[i]) - 1 )
					aSections + [ n1, n2]
				next

				oNumbersLine = new stzString(cSpaceLine)
				oNumbersLine.ReplaceSectionsByMany(aSections, acNumbers)
				cNumbersLine = oNumbersLine.TrimRightQ().Content()

				cResult += NL + cNumbersLine

			but bNumbered and bSectioned

				aSectionsOfNumbers = Q(anHilighted).SplittedToPartsOfN(2)
				nLenSectionsOfNumbers = len(aSectionsOfNumbers)

				acSectionsOfNumbers = []
				acSegments = []

				for i = 1 to nLenSectionsOfNumbers

					acSectionsOfNumbers + [
						(""+ aSectionsOfNumbers[i][1]),
						(""+ aSectionsOfNumbers[i][2])
					]

					nLen1 = len(acSectionsOfNumbers[i][2])
					nLen2 = len(acSectionsOfNumbers[i][2])

					aSections[i][2] -= (nLen2-1)

					cSegment = acSectionsOfNumbers[i][1]
					nDiff = aSections[i][2] - aSections[i][1] - nLen2
					
					for j = 1 to nDiff
						cSegment += " "
					next
					cSegment += acSectionsOfNumbers[i][2]
					acSegments + cSegment

				next
	
				oSpaceLine = new stzString(cSpaceLine)

				cNumbersLine = oSpaceLine.ReplaceSectionsByManyQ(aSections, acSegments).
						TrimRightQ().Content()

				cResult += NL + cNumbersLine

			but NOT bSectioned and len(anHilighted) > 0

				aSectionsOfNumbers = Q(anHilighted).SplitToPartsOfN(2)
				nLenSectionsOfNumbers = len(aSectionsOfNumbers)

				acSectionsOfNumbers = []
				nLenStrNumbers = 0
				acSegments = []

				for i = 1 to nLenSectionsOfNumbers

					acSectionsOfNumbers + [
						(""+ aSectionsOfNumbers[i][1]),
						(""+ aSectionsOfNumbers[i][2])
					]

					nLen1 = len(acSectionsOfNumbers[i][2])
					nLen2 = len(acSectionsOfNumbers[i][2])

					aSections[i][2] -= (nLen2-1)

					cSegment = acSectionsOfNumbers[i][1]
					nDiff = aSections[i][2] - aSections[i][1] - nLen2
					
					for j = 1 to nDiff
						cSegment += " "
					next
					cSegment += acSectionsOfNumbers[i][2]
					acSegments + cSegment

				next

				oSpaceLine = new stzString(cSpaceLine)

				cNumbersLine = oSpaceLine.ReplaceSectionsByManyQ(aSections, acSegments).
						TrimRightQ().Content()

				cResult += NL + cNumbersLine
	

			ok

			# Returning the result

			cResult = StzStringQ(cResult).ThisLastCharRemoved(NL)
			return cResult
			

		else
			StzRaise(stzListOfCharsError(:CanNotBoxTheListOfChars))
		ok

		#< @FunctionAlternativeForms

		def BoxedXT(paBoxOptions)
			return This.BoxXT(paBoxOptions)

		def BoxifyXT(paBoxOptions)
			return This.BoxXT(paBoxOptions)

		def BoxifiedXT(paBoxOptions)
			return This.BoxXT(paBoxOptions)

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
		bResult = _TRUE_

		aoStzChars = This.ToListOfStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			if NOT aoStzChars[i].IsNumber()
				bResult = _FALSE_
				exit
			ok
		next

		return bResult

	def AllCharsAreLetters()
		bResult = _TRUE_

		aoStzChars = This.ToListOfStzChars()
		nLen = len(aoStzChars)

		for i = 1 to nLen
			if NOT aoStzChars[i].IsLetter()
				bResult = _FALSE_
				exit
			ok
		next

		return bResult

	def IsContiguous()
		return This.UnicodesQR(:stzListOfNumbers).IsContiguous()

		def IsContinuous()
			return This.IsContiguous()
