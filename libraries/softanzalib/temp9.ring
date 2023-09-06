	  #========================#
	 #   FINDING THE SPLITS   #
	#========================#

	def FindSplitsCSXT(pSubStrOrPos, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isList(pSubStrOrPos) and Q(pSubStrOrPos).IsUsingNamedParam()
			pSubStrOrPos = pSubStrOrPos[2]
		ok

		if isString(pSubStrOrPos)
			return This.FindSplitsAtSubStringCS(pSubStrOrPos, pCaseSensitive)

		but isNumber(pSubStrOrPos)
			return This.FindSplitsAtPosition(pSubStrOrPos)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfNumbers()
			return This.FindSplitsAtPositions(pSubStrOrPos)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsPairOfNumbers()
			return This.FindSplitsAtSection(pSubStrOrPos[1], pSubStrOrPos[2])

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfPairsOfNumbers()
			return This.FindSplitsAtSections(pSubStrOrPos)

		but isList(pSubStrOrPos)

			oParam = Q(pSubStrOrPos)

			#-- SPLITTING AT / USING

			if oParam.IsOneOfTheseNamedParams([ :At, :Using ])
				return This.FindSplitsAtCS(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtPosition, :AtThisPosition ]) 
				return This.FindSplitsAtPosition(pSubStrOrPos[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AtPositions, :AtThesePositions ]) 
				return This.FindSplitsAtPositions(pSubStrOrPos[2])

			but oParam.IsOneOfTheseNamedParams([
						:AtSubString, :AtThisSubString,
						:UsingSubString, :UsingThisSubString ]) 

				return This.FindSplitsAtSubStringCS(pSubStrOrPos[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([
						:AtSubStrings, :AtTheseSubStrings,
						:UsingSubStrings, :UsingTheseSubStrings ]) 

				return This.FindSplitsAtSubStringsCS(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtSection, :AtThisSection ]) 
				return This.FindSplitsAtSection(pSubStrOrPos[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AtSections, :AtTheseSections ]) 
				return This.FindSplitsAtSections(pSubStrOrPos[2])

			#-- SPLITTING BEFORE

			but oParam.IsBeforeNamedParam()
				return This.FindSplitsBeforeCS(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforePosition, :BeforeThisPosition ]) 
				return This.FindSplitsBeforePosition(pSubStrOrPos[2])
	
			but oParam.IsOneOfTheseNamedParams([ :BeforePositions, :BeforeThesePositions ]) 
				return This.FindSplitsBeforePositions(pSubStrOrPos[2])

			but oParam.IsOneOfTheseNamedParams([ :BeforeSubString, :BeforeThisSubString ]) 
				return This.FindSplitsBeforeSubStringCS(pSubStrOrPos[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeSubStrings, :BeforeTheseSubStrings ]) 
				return This.SplitBeforeSubStringsCS(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforeSection, :BeforeThisSection ]) 
				return This.FindSplitsBeforeSection(pSubStrOrPos[2])
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeSections, :BeforeTheseSections ]) 
				return This.FindSplitsBeforeSections(pSubStrOrPos[2])

			#-- SPLITTING AFTER

			but oParam.IsAfterNamedParam()
				return This.FindSplitsAfterCS(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterPosition, :AfterThisPosition ]) 
				return This.FindSplitsAfterPosition(pSubStrOrPos[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AfterPositions, :AfterThesePositions ]) 
				return This.FindSplitsAfterPositions(pSubStrOrPos[2])

			but oParam.IsOneOfTheseNamedParams([ :AfterSubString, :AfterThisSubString ]) 
				return This.FindSplitsAfterSubStringCS(pSubStrOrPos[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :AfterSubStrings, :AfterTheseSubStrings ]) 
				return This.FindSplitsAfterSubStringsCS(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterSection, :AfterThisSection ]) 
				return This.FindSplitsAfterSection(pSubStrOrPos[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AfterSections, :AfterTheseSections ]) 
				return This.FindSplitsAfterSections(pSubStrOrPos[2])

			# SPLITTING BETWEEN

			but oParam.IsBetweenNamedParam() and
				isList(pcSubStrOrPos) and len(pcSubStrOrPos) = 2
				
				if isList(pcSubStrOrPos[2]) and Q(pcSubStrOrPos[2]).IsAndNamedParam()
					pcSubStrOrPos[2] = pcSubStrOrPos[2][2]
				ok

				return This.FindSplitsBetweenCS(pcSubStrOrPos[1], pcSubStrOrPos[2], pCaseSensitive)

			but oParam.IsBetweenPositionsNamedParam()
				return This.FindSplitsBetweenPositions(pcSubStrOrPos[1], pcSubStrOrPos[2])

			but oParam.IsBetweenSubStringsNamedParam()
				return This.FindSplitsBetweenSubStringsCS(pcSubStrOrPos[1], pcSubStrOrPos[2], pCaseSensitive)

			# SPLITTING TO PARTS

			but oParam.IsToNPartsNamedParam()
				return This.FindSplitsToNParts(pcSubStrOrPos[2])

			but oParam.IsToPartsOfNCharsNamedParam()
				return This.FindSplitsToPartsOfNChars(pcSubStrOrPos[2])

			# SPLITTING WHERE

			but oParam.IsWhereOrAtWhereNamedParam()
				return This.FindSplitsAtW(pcSubStrOrPos[2])

			but oParam.IsBeforeWhereNamedParam()
				return This.FindSplitsBeforeW(pcSubStrOrPos[2])

			but oParam.IsAfterWhereNamedParam()
				return This.FindSplitsAfterW(pcSubStrOrPos[2])

			ok
		else
			StzRaise("Incorrect param type! pSubStrOrPos must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindSplitsCSXTZ(pSubStrOrPos, pCaseSensitive)
			return This.FindSplitsCSXT(pSubStrOrPos, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsXT(pSubStrOrPos)
		return This.FindSplitsCSXT(pSubStrOrPos, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsXTZ(pSubStrOrPos)
			return This.FindSplitsXT(pSubStrOrPos)

		#>

	  #----------------------------------------------------#
	 #   FINDING SPLITS AT A GIVEN SUBSTRING OR POSITION  #
	#====================================================#

	def FindSplitsAtCS(pSubStrOrPos, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pSubStrOrPos)
			return This.FindSplitsAtSubStringCS(pSubStrOrPos, pCaseSensitive)

		but isNumber(pSubStrOrPos)
			return This.FindSplitsAtPosition(pSubStrOrPos)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfNumbers()
			return This.FindSplitsAtPositions(pSubStrOrPos)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsPairOfNumbers()
			return This.FindSplitsAtSection(pSubStrOrPos[1], pSubStrOrPos[2])

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfPairsOfNumbers()
			return This.FindSplits(pSubStrOrPos)

		but isList(pSubStrOrPos)

			oParam = Q(pSubStrOrPos)

			#-- Case when named params are provided

			if oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindSplitsAtPosition(pSubStrOrPos[2])
	
			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindSplitsAtPositions(pSubStrOrPos[2])

			but oParam.IsOneOfTheseNamedParams([ :SubString, :ThisSubString ]) 
				return This.FindSplitsAtSubStringCS(pSubStrOrPos[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :SubStrings, :TheseSubStrings ]) 
				return This.FindSplitsAtSubStringsCS(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindSplitsAtSection(pSubStrOrPos[2])
		
			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindSplitsAtSections(pSubStrOrPos[2])

			ok
		else
			StzRaise("Incorrect param type! pSubStrOrPos must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindSplitsAtCSZ(pSubStrOrPos, pCaseSensitive)
			return This.FindSplitsAtCS(pSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAt(pSubStrOrPos)
		return This.FindSplitsAtCS(pSubStrOrPos, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAtZ(pSubStrOrPos)
			return This.FindSplitsAtCS(pSubStr)

		#>

	  #----------------------------------------#
	 #   FINDING SPLITS AT A GIVEN POSITION   #
	#========================================#

	def FindSplitsAtPosition(n)
		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect pram type! n must be a number.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAtPosition(n)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAtThisPosition(n)
			return This.FindSplitsAtPosition(n)

		def FindSplitsAtPositionZ(n)
			return This.FindSplitsAtPosition(n)

		def FindSplitsAtThisPositionZ(n)
			return This.FindSplitsAtPosition(n)

		#>

	  #--------------------------------------#
	 #   FINDING SPLITS AT MANY POSITIONS   #
	#--------------------------------------#

	def FindSplitsAtPositions(anPos)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aResult = StzSplitterQ(This.NumberOfChars()).FindSplitsAtPositions(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAtThesePositions(anPos)
			return This.FindSplitsAtPositions(anPos)

		def FindSplitsAtManyPositions(anPos)
			return This.FindSplitsAtPositions(anPos)

		#--

		def FindSplitsAtPositionsZ(anPos)
			return This.FindSplitsAtPositions(anPos)

		def FindSplitsAtThesePositionsZ(anPos)
			return This.FindSplitsAtPositions(anPos)

		def FindSplitsAtManyPositionsZ(anPos)
			return This.FindSplitsAtPositions(anPos)

		#>

	  #-----------------------------------------#
	 #   FINDING SPLITS AT A GIVEN SUBSTRING   #
	#=========================================#

	def FindSplitsAtSubStringCS(pcSubStr, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcsubStr must be a string.")
		ok

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT IsBoolean(pCaseSensitive)
			StzRaise("Incorrect param type! pCaseSensitive must be a boolean (TRUE or FALSE).")
		ok

		aSections = This.FindCS(pcSubStr, pCaseSensitive)
		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAtSections(aSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsCS(pcSubStr, pCaseSensitive)
			if isList(pcSubStr) and Q(pcSubstr).IsAtOrAtSubStringNamedParam()
				pcSubStr = pcSubstr[2]
			ok

			return This.FindSplitsAtSubStringCS(pcSubStr, pCaseSensitive)

		def FindSplitsAtThisSubStringCS(pcSubStr, pCaseSensitive)
			if isList(pcSubStr) and Q(pcSubstr).IsAtOrAtSubStringNamedParam()
				pcSubStr = pcSubstr[2]
			ok

			return This.FindSplitsAtSubStringCS(pcSubStr, pCaseSensitive)

		#--

		def FindSplitsAtSubStringCSZ(pcSubStr, pCaseSensitive)
			return This.FindSplitsAtSubStringCS(pcSubStr, pCaseSensitive)

		def FindSplitsCSZ(pcSubStr, pCaseSensitive)
			if isList(pcSubStr) and Q(pcSubstr).IsAtOrAtSubStringNamedParam()
				pcSubStr = pcSubstr[2]
			ok

			return This.FindSplitsAtSubStringCS(pcSubStr, pCaseSensitive)

		def FindSplitsAtThisSubStringCSZ(pcSubStr, pCaseSensitive)
			if isList(pcSubStr) and Q(pcSubstr).IsAtOrAtSubStringNamedParam()
				pcSubStr = pcSubstr[2]
			ok

			return This.FindSplitsAtSubStringCS(pcSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtSubString(pcSubStr)
		return This.FindSplitsAtSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSplits(pcSubStr)
			return This.FindSplitsCS(pcSubStr, :CaseSensitive = TRUE)

		def FindSplitsAtThisSubString(pcSubStr)
			return This.FindSplitsAtThisSubStringCS(pcSubStr, :CaseSensitive = TRUE)
		#--

		def FindSplitsAtSubStringZ(pcSubStr)
			return This.FindSplitsAtSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		def FindSplitsZ(pcSubStr)
			return This.FindSplitsCS(pcSubStr, :CaseSensitive = TRUE)

		def FindSplitsAtThisSubStringZ(pcSubStr)
			return This.FindSplitsAtThisSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		#>

	  #----------------------------------------#
	 #   FINDING SPLITS AT GIVEN SUBSTRINGS   #
	#----------------------------------------#

	def FindSplitsAtSubStringsCS(pacSubStr, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		anPos = This.FindCS(pacSubStr, pCaseSensitive)

		aResult = This.FindSplitsAtPositions(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseSubStringsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsAtSubStringsCS(pacSubStr, pCaseSensitive)

		def FindSplitsAtManySubStringsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsAtSubStringsCS(pacSubStr, pCaseSensitive)

		#--

		def FindSplitsAtSubStringsCSZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsAtSubStringsCS(pacSubStr, pCaseSensitive)

		def FindSplitsAtTheseSubStringsCSZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsAtSubStringsCS(pacSubStr, pCaseSensitive)

		def FindSplitsAtManySubStringsCSZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsAtSubStringsCS(pacSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtSubStrings(pacSubStr)
		return This.FindSplitsAtSubStringsCS(pacSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseSubStrings(pacSubStr)
			return This.FindSplitsAtSubStrings(pacSubStr)
	
		def FindSplitsAtManySubStrings(pacSubStr)
			return This.FindSplitsAtSubStrings(pacSubStr)

		#--

		def FindSplitsAtSubStringsZ(pacSubStr)
			return This.FindSplitsAtSubStrings(pacSubStr)

		def FindSplitsAtTheseSubStringsZ(pacSubStr)
			return This.FindSplitsAtSubStrings(pacSubStr)

		def FindSplitsAtManySubStringsZ(pacSubStr)
			return This.FindSplitsAtSubStrings(pacSubStr)

		#>

	  #---------------------------------------#
	 #   FINDING SPLITS AT A GIVEN SECTION   #
	#=======================================#

	def FindSplitsAtSection(n1, n2)
		if This.IsEmpty()
			return []
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAtSection(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAtThisSection(n1, n2)
			return This.FindSplitsAtSection(n1, n2)

		#--

		def FindSplitsAtSectionZ(n1, n2)
			return This.FindSplitsAtSection(n1, n2)

		def FindSplitsAtThisSectionZ(n1, n2)
			return This.FindSplitsAtSection(n1, n2)

		#>

	  #----------------------------------------------------------#
	 #   FINDING SPLITS AT A GIVEN SECTION -- INCLUDING BOUNDS  #
	#----------------------------------------------------------#

	def FindSplitsAtSectionIB(n1, n2)
		if This.IsEmpty()
			return []
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAtSectionIB(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAtThisSectionIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		#--

		def FindSplitsAtSectionIBZ(n1, n2)
			return This.FindSplitsAtSectionIB(n1, n2)

		def FindSplitsAtThisSectionIBZ(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		#>

	  #-------------------------------------#
	 #   FINDING SPLITS AT MANY SECTIONS   #
	#-------------------------------------#

	def FindSplitsAtSections(paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		anResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAtSections(paSections)
		return anResult

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseSections(paSections)
			return This.FindSplitsAtSections(paSections)

		#--

		def FindSplitsAtSectionsZ(paSections)
			return This.FindSplitsAtSections(paSections)

		def FindSplitsAtTheseSectionsZ(paSections)
			return This.FindSplitsAtSections(paSections)

		#>

	  #---------------------------------------------------------#
	 #   FINDING SPLITS BEFORE A GIVEN POSITION OR SUBSTRING   #
	#---------------------------------------------------------#

	def FindSplitsBeforeCS(pSubStrOrPos, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pSubStrOrPos)
			return This.FindSplitsBeforeSubStringCS(pSubStrOrPos, pCaseSensitive)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfStrings()
			return This.FindSplitsBeforeSubStringsCS(pSubStrOrPos, pCaseSensitive)

		but isNumber(pSubStrOrPos)
			return This.FindSplitsBeforePosition(pSubStrOrPos)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfNumbers()
			return This.FindSplitsBeforePositions(pSubStrOrPos)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsPairOfNumbers()
			return This.FindSplitsBeforeSection(pSubStrOrPos[1], pSubStrOrPos[2])

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfPairsOfNumbers()
			return This.FindSplitsBeforeSections(pSubStrOrPos[1], pSubStrOrPos[2])

		but isList(pSubStrOrPos)

			#-- Case when named params are provided

			if Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindSplitsBeforePosition(pSubStrOrPos[2])
	
			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindSplitsBeforePositions(pSubStrOrPos[2])

			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :SubString, :ThisSubString ]) 
				return This.FindSplitsBeforeSubStringCS(pSubStrOrPos[2], pCaseSensitive)
		
			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :SubStrings, :TheseSubStrings ]) 
				return This.FindSplitsBeforeSubStringsCS(pSubStrOrPos[2], pCaseSensitive)

			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindSplitsBeforeSection(pSubStrOrPos[2])
		
			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindSplitsBeforeSections(pSubStrOrPos[2])

			ok
		else
			StzRaise("Incorrect param type! pSubStrOrPos must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForms

		def FindSplitsBeforeCSZ(pSubStrOrPos, pCaseSensitive)
			return This.FindSplitsBeforeCS(pSubStrOrPos, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBefore(pSubStrOrPos)
		return This.FindSplitsBeforeCS(pSubStrOrPos, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsBeforeZ(pSubStrOrPos)
			return This.FindSplitsBefore(pSubStrOrPos)

		#>

	  #--------------------------------------------#
	 #   FINDING SPLITS BEFORE A GIVEN POSITION   #
	#--------------------------------------------#

	def FindSplitsBeforePosition(n)
		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforePosition(n)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeThisPosition(n)
			return This.FindSplitsBeforePosition(n)

		#--

		def FindSplitsBeforePositionZ(n)
			return This.FindSplitsBeforePosition(n)

		def FindSplitsBeforeThisPositionZ(n)
			return This.FindSplitsBeforePosition(n)

		#>

	  #------------------------------------------#
	 #   FINDING SPLITS BEFORE MANY POSITIONS   #
	#------------------------------------------#

	def FindSplitsBeforePositions(anPos)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforePositions(anPos)
		return aResult			

		#< @FunctionAlternativeForms

		def FindSplitsBeforeThesePositions(anPos)
			return This.FindSplitsBeforePositions(anPos)

		def FindSplitsBeforeManyPositions(anPos)
			return This.FindSplitsBeforePositions(anPos)

		#--

		def FindSplitsBeforePositionsZ(anPos)
			return This.FindSplitsBeforePositions(anPos)

		def FindSplitsBeforeThesePositionsZ(anPos)
			return This.FindSplitsBeforePositions(anPos)

		def FindSplitsBeforeManyPositionsZ(anPos)
			return This.FindSplitsBeforePositions(anPos)

		#>

	  #---------------------------------------------#
	 #   FINDING SPLITS BEFORE A GIVEN SUBSTRING   #
	#---------------------------------------------#

	def FindSplitsBeforeSubStringCS(pcSubStr, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		anPos = This.FindCS(pcSubStr, pCaseSensitive)
		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforePositions(anPos)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringCS(pcSubStr, pCaseSensitive)

		#--

		def FindSplitsBeforeSubStringCSZ(pcSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringCS(pcSubStr, pCaseSensitive)

		def FindSplitsBeforeThisSubStringCSZ(pcSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringCS(pcSubStr, pCaseSensitive)

		#>
				
	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeSubString(pcSubStr)
		return This.FindSplitsBeforeSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisSubString(pcSubStr)
			return This.FindSplitsBeforeSubString(pcSubStr)

		#--

		def FindSplitsBeforeSubStringZ(pcSubStr)
			return This.FindSplitsBeforeSubString(pcSubStr)

		def FindSplitsBeforeThisSubStringZ(pcSubStr)
			return This.FindSplitsBeforeSubString(pcSubStr)	

		#>

	  #-------------------------------------------#
	 #   FINDING SPLITS BEFORE MANY SUBSTRINGS   #
	#-------------------------------------------#

	def FindSplitsBeforeSubStringsCS(pacSubStr, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(pacSubStr) and Q(pacSubStr).IsListOfStrings() )
			StzRaise("Incorrect param type! pacSubStr must be a list of strings.")
		ok

		anPos = This.FindCS( pacSubStr, pCaseSensitive )
		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforePositions(anPos)

		return anResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseSubStringsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringsCS(pacSubStr, pCaseSensitive)

		def FindSplitsBeforeManySubStringsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringsCS(pacSubStr, pCaseSensitive)

		#--

		def FindSplitsBeforeSubStringsCSZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringsCS(pacSubStr, pCaseSensitive)

		def FindSplitsBeforeTheseSubStringsCSZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringsCS(pacSubStr, pCaseSensitive)

		def FindSplitsBeforeManySubStringsCSZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringsCS(pacSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeSubStrings(pacSubStr)
		return This.FindSplitsBeforeSubStringsCS(pacSubStr, :CaseSensitive = TRUE)
	
		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseSubStrings(pacSubStr)
			return This.FindSplitsBeforeSubStrings(pacSubStr)

		def FindSplitsBeforeManySubStrings(pacSubStr)
			return This.FindSplitsBeforeSubStrings(pacSubStr)

		#--

		def FindSplitsBeforeSubStringsZ(pacSubStr)
			return This.FindSplitsBeforeSubStrings(pacSubStr)

		def FindSplitsBeforeTheseSubStringsZ(pacSubStr)
			return This.FindSplitsBeforeSubStrings(pacSubStr)

		def FindSplitsBeforeManySubStringsZ(pacSubStr)
			return This.FindSplitsBeforeSubStrings(pacSubStr)

		#>

	  #-------------------------------------------#
	 #   FINDING SPLITS BEFORE A GIVEN SECTION   #
	#-------------------------------------------#

	def FindSplitsBeforeSection(n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforeSection(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisSection(n1, n2)
			return This.FindSplitsBeforeSection(n1, n2)

		#--

		def FindSplitsBeforeSectionZ(n1, n2)
			return This.FindSplitsBeforeSection(n1, n2)

		def FindSplitsBeforeThisSectionZ(n1, n2)
			return This.FindSplitsBeforeSection(n1, n2)

		#>

	  #--------------------------------------------------------------#
	 #   FINDING SPLITS BEFORE A GIVEN SECTION -- INCLUDING BOUND   #
	#--------------------------------------------------------------#

	def FindSplitsBeforeSectionIB(n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforeSectionIB(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisSectionIB(n1, n2)
			return This.FindSplitsBeforeSectionIB(n1, n2)

		#--

		def FindSplitsBeforeSectionIBZ(n1, n2)
			return This.FindSplitsBeforeSectionIB(n1, n2)

		def FindSplitsBeforeThisSectionIBZ(n1, n2)
			return This.FindSplitsBeforeSectionIB(n1, n2)

		#>

	  #-----------------------------------------#
	 #   FINDING SPLITS BEFORE MANY SECTIONS   #
	#-----------------------------------------#

	def FindSplitsBeforeSections(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforeSections(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseSections(paSections)
			return This.FindSplitsBeforeSections(paSections)

		def FindSplitsBeforeManySections(paSections)
			return This.SplitBeforeSections(paSections)

		#--

		def FindSplitsBeforeSectionsZ(paSections)
			return This.FindSplitsBeforeSections(paSections)

		def FindSplitsBeforeTheseSectionsZ(paSections)
			return This.FindSplitsBeforeSections(paSections)

		def FindSplitsBeforeManySectionsZ(paSections)
			return This.SplitBeforeSections(paSections)

		#>

	  #----------------------------------------------------------#
	 #   FINING SPLITS BEFORE MANY SECTIONS -- INCLUDING BOUND  #
	#----------------------------------------------------------#

	def FindSplitsBeforeSectionsIB(paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).SplitBeforeSectionIB(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseSectionsIB(paSections)
			return This.FindSplitsBeforeSectionsIB(paSections)

		def FindSplitsBeforeManySectionsIB(paSections)
			return This.FindSplitsBeforeSectionsIB(paSections)

		#--

		def FindSplitsBeforeSectionsIBZ(paSections)
			return This.FindSplitsBeforeSectionsIB(paSections)

		def FindSplitsBeforeTheseSectionsIBZ(paSections)
			return This.FindSplitsBeforeSectionsIB(paSections)

		def FindSplitsBeforeManySectionsIBZ(paSections)
			return This.FindSplitsBeforeSectionsIB(paSections)

		#>

	  #-------------------------------------------------------#
	 #   FINDING SPLITS AFTER A GIVEN POSITION OR SUBSTRING  #
	#-------------------------------------------------------#

	def FindSplitsAfterCS(pSubStrOrPos, pCaseSensitive)
		if isString(pSubStrOrPos)
			return This.FindSplitsAfterSubStringCS(pSubStrOrPos, pCaseSensitive)

		but isNumber(pSubStrOrPos)
			return This.FindSplitsAfterPosition(pSubStrOrPos)

		but isList(pSubStrOrPos)

			#-- Case when named params are provided

			if Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Position, :ThisPosition ])

				return This.FindSplitsAfterPosition(pSubStrOrPos[2])
	
			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindSplitsAfterPositions(pSubStrOrPos[2])

			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :SubString, :ThisSubString ]) 
				return This.FindSplitsAfterSubStringCS(pSubStrOrPos[2], pCaseSensitive)
		
			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :SubStrings, :TheseSubStrings ]) 
				return This.FindSplitsAfterSubStringsCS(pSubStrOrPos[2], pCaseSensitive)

			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindSplitsAfterSection(pSubStrOrPos[2])

			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindSplitsAfterSections(pSubStrOrPos[2])

			#-- Providing numbers, strings, or pairs of numbers,
			#   directly without named params

			but Q(pSubStrOrPos).IsListOfNumbers()
				return This.FindSplitsAfterPositions(pSubStrOrPos)

			but Q(pSubStrOrPos).IsListOfStrings()
				return This.FindSplitsAfterSubStrings(pSubStrOrPos)

			but Q(pSubStrOrPos).IsListOfPairsOfNumbers()
				return This.FindSplitsAfterSections(pSubStrOrPos)

			ok
		else
			StzRaise("Incorrect param type! pSubStrOrPos must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindSplitsAfterCSZ(pSubStrOrPos, pCaseSensitive)
			return This.FindSplitsAfterCS(pSubStrOrPos, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfter(pSubStrOrPos)
		return This.FindSplitsAfterCS(pSubStrOrPos, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterZ(pSubStrOrPos)
			return This.FindSplitsAfterCS(pSubStrOrPos, pCaseSensitive)

		#>

	  #--------------------------------------------#
	 #   FINDING SPLITS BEFORE A GIVEN POSITION   #
	#--------------------------------------------#

	def FindSplitsAfterPosition(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		anResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterPosition(n)
		return anResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisPosition(n)
			return This.FindSplitsAfterPosition(n)

		def FindSplitsAfterPositionZ(n)
			return This.FindSplitsAfterPosition(n)

		def FindSplitsAfterThisPositionZ(n)
			return This.FindSplitsAfterPosition(n)

		#>

	  #------------------------------------------#
	 #   FINDING SPLITS BEFORE MANY POSITIONS   #
	#------------------------------------------#

	def FindSplitsAfterPositions(anPos)
		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterPositions(anPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThesePositions(anPos)
			return This.FindSplitsAfterThesePositions(anPos)

		def FindSplitsAfterManyPositions(anPos)
			return This.FindSplitsAfterManyPositions(anPos)

		#--

		def FindSplitsAfterPositionsZ(anPos)
			return This.FindSplitsAfterPositions(anPos)

		def FindSplitsAfterThesePositionsZ(anPos)
			return This.FindSplitsAfterThesePositions(anPos)

		def FindSplitsAfterManyPositionsZ(anPos)
			return This.FindSplitsAfterManyPositions(anPos)

		#>

	  #---------------------------------------------#
	 #   FINDING SPLITS BEFORE A GIVEN SUBSTRING   #
	#---------------------------------------------#

	def FindSplitsAfterSubStringCS(pcSubStr, pCaseSensitive)
		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		anPos = This.FindCS(pcSubStr, pCaseSensitive)
		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterPositions(anPos)
		return anResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisSubStringCS(pcSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringCS(pcSubStr, pCaseSensitive)

		#--

		def FindSplitsAfterSubStringCSZ(pcSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringCS(pcSubStr, pCaseSensitive)

		def FindSplitsAfterThisSubStringCSZ(pcSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringCS(pcSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterSubString(pcSubStr)
		return This.FindSplitsAfterSubStringCS(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisSubString(pcSubStr)
			return This.FindSplitsAfterSubString(pcSubStr)

		#--

		def FindSplitsAfterSubStringZ(pcSubStr)
			return This.FindSplitsAfterSubString(pcSubStr)

		def FindSplitsAfterThisSubStringZ(pcSubStr)
			return This.FindSplitsAfterSubString(pcSubStr)

		#>

	  #-------------------------------------------#
	 #   FINDING SPLITS BEFORE MANY SUBSTRINGS   #
	#-------------------------------------------#

	def FindSplitsAfterSubStringsCS(pacSubStr, pCaseSensitive)
		if NOT ( isList(pacSubStr) and Q(pacSubStr).IsListOfStrings() )
			StzRaise("Incorrect param type! pacSubStr must be a list of strings.")
		ok

		anPos = This.FindCS( pacSubStr, pCaseSensitive )
		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterPositions(anPos)
		return anResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterTheseSubStringsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringsCS(pacSubStr, pCaseSensitive)

		def FindSplitsAfterManySubStringsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringsCS(pacSubStr, pCaseSensitive)

		#--

		def FindSplitsAfterSubStringsCSZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringsCS(pacSubStr, pCaseSensitive)

		def FindSplitsAfterTheseSubStringsCSZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringsCS(pacSubStr, pCaseSensitive)

		def FindSplitsAfterManySubStringsCSZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringsCS(pacSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterSubStrings(pacSubStr)
		return This.FindSplitsAfterSubStringsCS(pacSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterTheseSubStrings(pacSubStr)
			return This.FindSplitsAfterSubStrings(pacSubStr)

		def FindSplitsAfterManySubStrings(pacSubStr)
			return This.FindSplitsAfterSubStrings(pacSubStr)

		#--

		def FindSplitsAfterSubStringsZ(pacSubStr)
			return This.FindSplitsAfterSubStrings(pacSubStr)

		def FindSplitsAfterTheseSubStringsZ(pacSubStr)
			return This.FindSplitsAfterSubStrings(pacSubStr)

		def FindSplitsAfterManySubStringsZ(pacSubStr)
			return This.FindSplitsAfterSubStrings(pacSubStr)

		#>

	  #-----------------------------------------#
	 #   FINDING SPLITS AFTER A GIVEN SECTION  #
	#-----------------------------------------#

	def FindSplitsAfterSection(n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterSection(n1 , n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisSection(n1, n2)
			return This.FindSplitsAfterSection(n1, n2)

		#--

		def FindSplitsAfterSectionZ(n1, n2)
			return This.FindSplitsAfterSection(n1, n2)

		def FindSplitsAfterThisSectionZ(n1, n2)
			return This.FindSplitsAfterSection(n1, n2)

		#>

	  #------------------------------------------------------------#
	 #   FINDING SPLITS AFTER A GIVEN SECTION -- INCLUDING BOUND  #
	#------------------------------------------------------------#

	def FindSplitsAfterSectionIB(n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterSectionIB(n1 , n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisSectionIB(n1, n2)
			return This.FindSplitsAfterSectionIB(n1, n2)

		#--

		def FindSplitsAfterSectionIBZ(n1, n2)
			return This.FindSplitsAfterSectionIB(n1, n2)

		def FindSplitsAfterThisSectionIBZ(n1, n2)
			return This.FindSplitsAfterSectionIB(n1, n2)


		#>

	  #----------------------------------------#
	 #   FINDING SPLITS AFTER MANY SECTIONS   #
	#----------------------------------------#

	def FindSplitsAfterSections(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterSections(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAfterTheseSections(paSections)
			return This.FindSplitsAfterTheseSections(paSections)

		#--

		def FindSplitsAfterSectionsZ(paSections)
			return This.FindSplitsAfterSections(paSections)

		def FindSplitsAfterTheseSectionsZ(paSections)
			return This.FindSplitsAfterTheseSections(paSections)

		#>

	  #-----------------------------------------------------------#
	 #   FINDING SPLITS AFTER MANY SECTIONS -- INCLUDING BOUNDS  #
	#-----------------------------------------------------------#

	def FindSplitsAfterSectionsIB(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterSectionsIB(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAfterTheseSectionsIB(paSections)
			return This.FindSplitsAfterSectionsIB(paSections)

		#--

		def FindSplitsAfterSectionsIBZ(paSections)
			return This.FindSplitsAfterSectionsIB(paSections)

		def FindSplitsAfterTheseSectionsIBZ(paSections)
			return This.FindSplitsAfterSectionsIB(paSections)

		#>

	  #------------------------------------------------------#
	 #  FINDING SPLITS BETWEEN TWO POSITIONS OR SUBSTRINGS  #
	#======================================================#

	def FindSplitsBetweenCS(pBound1, pBound2, pCaseSensitive)
		if NOT ( BothAreStringsOrNumbers(pBound1, pBound2) )
			StzRaise("Incorrect params types! pBound1 and pBound2 must be both numbers or strings.")
		ok

		if BothAreNumbers(pBound1, pBound2)
			aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBetween(pBound1, pBound2)

		else # case if BothAreStrings()
			anFirstBounds  = This.FindAllCS(pBound1, pCaseSensitive)
			anSecondBounds = This.FindAllCS(pBound2, pCaseSensitive)

			aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
			anFirstBounds  = aListOfBounds[1]
			anSecondBounds = aListOfBounds[2]

			aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)

			aResult = StzSplitterQ( This.NumberOfChars() ).
				   FindSplitsBetweenSections(aSections)
		ok
		
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBetweenCSZ(pBound1, pBound2, pCaseSensitive)
			return This.FindSplitsBetweenCS(pBound1, pBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetween(pBound1, pBound2)
		return This.FindSplitsBetweenCS(pBound1, pBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsBetweenZ(pBound1, pBound2)
			return This.FindSplitsBetween(pBound1, pBound2)

		#>

	  #--------------------------------------------------------------------------#
	 #  FINDING SPLITS BETWEEN TWO POSITIONS OR SUBSTRINGS -- INCLUDING BOUNDS  #
	#--------------------------------------------------------------------------#

	def FindSplitsBetweenCSIB(pBound1, pBound2, pCaseSensitive)
		if NOT ( BothAreStringsOrNumbers(pBound1, pBound2) )
			StzRaise("Incorrect params types! pBound1 and pBound2 must be both numbers or strings.")
		ok

		if BothAreNumbers(pBound1, pBound2)
			aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBetweenIB(pBound1, pBound2)

		else # case if BothAreStrings()
			anFirstBounds  = This.FindAllCS(pBound1, pCaseSensitive)
			anSecondBounds = This.FindAllCS(pBound2, pCaseSensitive)

			aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
			anFirstBounds  = aListOfBounds[1]
			anSecondBounds = aListOfBounds[2]

			nLen = len(anFirstBounds)
			for i = 1 to nLen
				anFirstBounds[i]--
				anSecondBounds[i]++
			next

			aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)

			aResult = StzSplitterQ( This.NumberOfChars() ).
				   FindSplitsBetweenSections(aSections)
		ok

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBetweenCSIBZ(pBound1, pBound2, pCaseSensitive)
			return This.FindSplitsBetweenCSIB(pBound1, pBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetweenIB(pBound1, pBound2)
		return This.FindSplitsBetweenCSIB(pBound1, pBound2, :CaseSensitive = TRUE)


		#< @FunctionAlternativeForm

		def FindSplitsBetweenIBZ(pBound1, pBound2)
			return This.FindSplitsBetweenIB(pBound1, pBound2)

		#>

	  #----------------------------------------#
	 #  FINDING SPLITS BETWEEN TWO POSITIONS  #
	#----------------------------------------#

	def FindSplitsBetweenPositions(n1, n2)
		This.FindSplitsAtSection(n1, n2)

		#< @FunctionAlternativeForms

		def FindSplitsBetweenThesePositions(n1, n2)
			return This.FindSplitsBetweenPositions(n1, n2)

		#--

		def FindSplitsBetweenPositionsZ(n1, n2)
			return This.FindSplitsBetweenPositions(n1, n2)

		def FindSplitsBetweenThesePositionsZ(n1, n2)
			return This.FindSplitsBetweenPositions(n1, n2)

		#>
		
	  #------------------------------------------------------------#
	 #  FINDING SPLITS BETWEEN TWO POSITIONS -- INCLUDING BOUNDS  #
	#------------------------------------------------------------#

	def FindSplitsBetweenPositionsIB(n1, n2)
		This.FindSplitsAtSectionIB(n1, n2)

		#< @FunctionAlternativeForms

		def FindSplitsBetweenThesePositionsIB(n1, n2)
			return This.FindSplitsBetweenPositionsIB(n1, n2)

		#--

		def FindSplitsBetweenPositionsIBZ(n1, n2)
			return This.FindSplitsBetweenPositionsIB(n1, n2)

		def FindSplitsBetweenThesePositionsIBZ(n1, n2)
			return This.FindSplitsBetweenPositionsIB(n1, n2)

		#>

	  #-----------------------------------------#
	 #  FINDING SPLITS BETWEEN TWO SUBSTRINGS  #
	#-----------------------------------------#

	def FindSplitsBetweenSubStringsCS(pacSubStr, pCaseSensitive)
		aSections = This.Find(pacSubStr, pCaseSensitive)
		aResult = This.FindSplitsBetweenSections(aSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBetweenTheseSubStringsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsBetweenSubStringsCS(pacSubStr, pCaseSensitive)

		#--

		def FindSplitsBetweenSubStringsCSZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsBetweenSubStringsCS(pacSubStr, pCaseSensitive)

		def FindSplitsBetweenTheseSubStringsCSZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsBetweenSubStringsCS(pacSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetweenSubStrings(pacSubStr)
		return This.FindSplitsBetweenSubStringsCS(pacSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsBetweenTheseSubStrings(pacSubStr)
			return This.FindSplitsBetweenSubStrings(pacSubStr)

		#--

		def FindSplitsBetweenSubStringsZ(pacSubStr)
			return This.FindSplitsBetweenSubStrings(pacSubStr)

		def FindSplitsBetweenTheseSubStringsZ(pacSubStr)
			return This.FindSplitsBetweenSubStrings(pacSubStr)

		#>

	  #---------------------------------#
	 #    FINDING SPLITS TO N PARTS    #
	#=================================#

	def FindSplitsToNParts(n)
		anResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsToNParts(n)
		return aResult

		def FindSplitsToNPartsZ(n)
			return This.FindSplitsToNParts(n)

	  #--------------------------------------------------#
	 #   FINDING SPLITS TO PARTS OF (EXACTLY) N CHARS   #
	#--------------------------------------------------#
	# Remaining part less the n chars is not returned

	def FindSplitsToPartsOfNChars(n)
		anResult = StzSplitterQ( This.NumberOfChars() ).
				FindSplitsToPartsOfExactlyNPositions(n)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsToPartsOfExactlyNChars(n)
			return This.FindSplitsToPartsOfNChars(n)

		#--

		def FindSplitsToPartsOfNCharsZ(n)
			return This.FindSplitsToPartsOfNChars(n)

		def FindSplitsToPartsOfExactlyNCharsZ(n)
			return This.FindSplitsToPartsOfNChars(n)

		#>

	  #------------------------------------------------------------#
	 #   FINDING SPLITS TO PARTS OF N CHARS -- INCLUDING BOUNDS   #
	#------------------------------------------------------------#
	# The remaing part (if any) less then n chars is also returned

	def FindSplitsToPartsOfNCharsIB(n)
		aResult = StzSplitterQ( This.NumberOfChars() ).
				FindSplitsToPartsOfNPositionsIB(n)

		return aResult

		def FindSplitsToPartsOfNCharsIBZ(n)
			return This.FindSplitsToPartsOfNCharsIB(n)

	  #-------------------------------------------#
	 #   FINDING SPLITS UNDER A GIVEN CONDTION   #
	#===========================================#

	def FindSplitsW(pcCondition)
		/*
		? StzSplitterQ(1:5).FindSplitsW('Q(@item).IsMultipleOf(2)')
		*/

		if isList(pcCondition)

			if Q(pcCondition).IsWhereNamedParam()
				return This.FindSplitsAtW(pcCondition[2])

			but Q(pcCondition).IsAtNamedParam()
				return This.FindSplitsAtW(pcCondition[2])

			but Q(pcCondition).IsBeforeNamedParam()
				return This.FindSplitsBeforeW(pcCondition[2])

			but Q(pcCondition).IsAfterNamedParam()
				return This.FindSplitsAfterW(pcCondition[2])

			ok
		
		else

			return This.FindSplitsAtWZ(pcCondition)
		ok

		#< @FunctionAlternativeForm

		def FindSplitsWZ(pcCondition)
			return This.FindSplitsWZ(pcCondition)

		#>

	  #-----------------------------------------#
	 #   FINSING SPLITS  AT A GIVEN CONDTION   #
	#-----------------------------------------#

	def FindSplitsAtW(pcCondition)
			
		if isList(pcCondition) and Q(pcCondition).IsWhereNamedParam()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		aResult = []

		pcCondition = Q(pcCondition).TrimQ().BoundsRemoved(["{","}"])

		if Q(pcCondition).ContainsCS("@SubString", :CS = FALSE)

			aSections = This.FindSubStringsW(pcCondition)
			anResult = This.FindSplitsAtSectionsZ(aSections)

		else

			anPositions = This.FindW(pcCondition)
			anResult = This.FindSplitsAtPositionsZ(anPositions)
		ok

		return anResult

		#< @FunctionAlternativeForm

		def FindSplitsAtWZ(pcCondition)
			return This.FindSplitsAtW(pcCondition)

		#>

	  #--------------------------------------------#
	 #   FINDING SPLITS BEFORE A GIVEN CONDTION   #
	#--------------------------------------------#

	def FindSplitsBeforeW(pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsBothCS("@char", "@substring", :CaseSensitive = FALSE)
			StzRaise("Incorrect syntax! pcCondition must contain either @Char or @SubString keywords but not both.")
		ok

		if oCondition.ContainsCS("@substring",  :CaseSensitive = FALSE)
			anPositions = This.FindSubStringsW(pcCondition)

		else
			anPositions = This.FindCharsW(pcCondition)
		ok

		aResult = This.FindSplitsBeforePositions(anPositions)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBeforeWZ(pcCondition)
			return This.FindSplitsBeforeW(pcCondition)

		#>

	  #-------------------------------------------#
	 #   FINDING SPLITS AFTER A GIVEN CONDTION   #
	#-------------------------------------------#

	def FindSplitsAfterW(pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsBothCS("@char", "@substring", :CaseSensitive = FALSE)
			StzRaise("Incorrect syntax! pcCondition must contain either @Char or @SubString keywords but not both.")
		ok

		if oCondition.ContainsCS("@substring",  :CaseSensitive = FALSE)
			anPositions = This.FindSubStringsW(pcCondition)

		else
			anPositions = This.FindCharsW(pcCondition)
		ok

		aResult = This.FindSplitsAfterPositions(anPositions)

		return anResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterWZ(pcCondition)
			return This.FindSplitsAfterW(pcCondition)

		#>

	  #===================================#
	 #   FINDING THE SPLITS AS SECTIONS  #
	#===================================#

	def FindSplitsCSXTZZ(pSubStrOrPos, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isList(pSubStrOrPos) and Q(pSubStrOrPos).IsUsingNamedParam()
			pSubStrOrPos = pSubStrOrPos[2]
		ok

		if isString(pSubStrOrPos)
			return This.FindSplitsAtSubStringCSZZ(pSubStrOrPos, pCaseSensitive)

		but isNumber(pSubStrOrPos)
			return This.FindSplitsAtPositionZZ(pSubStrOrPos)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfNumbers()
			return This.FindSplitsAtPositionsZZ(pSubStrOrPos)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsPairOfNumbers()
			return This.FindSplitsAtSectionZZ(pSubStrOrPos[1], pSubStrOrPos[2])

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfPairsOfNumbers()
			return This.FindSplitsAtSectionsZZ(pSubStrOrPos)

		but isList(pSubStrOrPos)

			oParam = Q(pSubStrOrPos)

			#-- SPLITTING AT / USING

			if oParam.IsOneOfTheseNamedParams([ :At, :Using ])
				return This.FindSplitsAtCSZZ(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtPosition, :AtThisPosition ]) 
				return This.FindSplitsAtPositionZZ(pSubStrOrPos[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AtPositions, :AtThesePositions ]) 
				return This.FindSplitsAtPositionsZZ(pSubStrOrPos[2])

			but oParam.IsOneOfTheseNamedParams([
						:AtSubString, :AtThisSubString,
						:UsingSubString, :UsingThisSubString ]) 

				return This.FindSplitsAtSubStringCSZZ(pSubStrOrPos[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([
						:AtSubStrings, :AtTheseSubStrings,
						:UsingSubStrings, :UsingTheseSubStrings ]) 

				return This.FindSplitsAtSubStringsCSZZ(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtSection, :AtThisSection ]) 
				return This.FindSplitsAtSectionZZ(pSubStrOrPos[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AtSections, :AtTheseSections ]) 
				return This.FindSplitsAtSectionsZZ(pSubStrOrPos[2])

			#-- SPLITTING BEFORE

			but oParam.IsBeforeNamedParam()
				return This.FindSplitsBeforeCSZZ(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforePosition, :BeforeThisPosition ]) 
				return This.FindSplitsBeforePositionZZ(pSubStrOrPos[2])
	
			but oParam.IsOneOfTheseNamedParams([ :BeforePositions, :BeforeThesePositions ]) 
				return This.FindSplitsBeforePositionsZZ(pSubStrOrPos[2])

			but oParam.IsOneOfTheseNamedParams([ :BeforeSubString, :BeforeThisSubString ]) 
				return This.FindSplitsBeforeSubStringCSZZ(pSubStrOrPos[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeSubStrings, :BeforeTheseSubStrings ]) 
				return This.SplitBeforeSubStringsCSZZ(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforeSection, :BeforeThisSection ]) 
				return This.FindSplitsBeforeSectionZZ(pSubStrOrPos[2])
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeSections, :BeforeTheseSections ]) 
				return This.FindSplitsBeforeSectionsZZ(pSubStrOrPos[2])

			#-- SPLITTING AFTER

			but oParam.IsAfterNamedParam()
				return This.FindSplitsAfterCSZZ(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterPosition, :AfterThisPosition ]) 
				return This.FindSplitsAfterPositionZZ(pSubStrOrPos[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AfterPositions, :AfterThesePositions ]) 
				return This.FindSplitsAfterPositionsZZ(pSubStrOrPos[2])

			but oParam.IsOneOfTheseNamedParams([ :AfterSubString, :AfterThisSubString ]) 
				return This.FindSplitsAfterSubStringCSZZ(pSubStrOrPos[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :AfterSubStrings, :AfterTheseSubStrings ]) 
				return This.FindSplitsAfterSubStringsCSZZ(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterSection, :AfterThisSection ]) 
				return This.FindSplitsAfterSectionZZ(pSubStrOrPos[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AfterSections, :AfterTheseSections ]) 
				return This.FindSplitsAfterSectionsZZ(pSubStrOrPos[2])

			# SPLITTING BETWEEN

			but oParam.IsBetweenNamedParam() and
				isList(pcSubStrOrPos) and len(pcSubStrOrPos) = 2
				
				if isList(pcSubStrOrPos[2]) and Q(pcSubStrOrPos[2]).IsAndNamedParam()
					pcSubStrOrPos[2] = pcSubStrOrPos[2][2]
				ok

				return This.FindSplitsBetweenCSZZ(pcSubStrOrPos[1], pcSubStrOrPos[2], pCaseSensitive)

			but oParam.IsBetweenPositionsNamedParam()
				return This.FindSplitsBetweenPositionsZZ(pcSubStrOrPos[1], pcSubStrOrPos[2])

			but oParam.IsBetweenSubStringsNamedParam()
				return This.FindSplitsBetweenSubStringsCSZZ(pcSubStrOrPos[1], pcSubStrOrPos[2], pCaseSensitive)

			# SPLITTING TO PARTS

			but oParam.IsToNPartsNamedParam()
				return This.FindSplitsToNPartsZZ(pcSubStrOrPos[2])

			but oParam.IsToPartsOfNCharsNamedParam()
				return This.FindSplitsToPartsOfNCharsZZ(pcSubStrOrPos[2])

			# SPLITTING WHERE

			but oParam.IsWhereOrAtWhereNamedParam()
				return This.FindSplitsAtWZZ(pcSubStrOrPos[2])

			but oParam.IsBeforeWhereNamedParam()
				return This.FindSplitsBeforeWZZ(pcSubStrOrPos[2])

			but oParam.IsAfterWhereNamedParam()
				return This.FindSplitsAfterWZZ(pcSubStrOrPos[2])

			ok
		else
			StzRaise("Incorrect param type! pSubStrOrPos must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindSplitsAsSectionsCSXT(pSubStrOrPos, pCaseSensitive)
			return This.FindSplitsAsSectionsCSXTZZ(pSubStrOrPos, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsXTZZ(pSubStrOrPos)
		return This.FindSplitsCSXTZZ(pSubStrOrPos, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAsSectionsAsSectionsXT(pSubStrOrPos)
			return This.FindSplitsAsSectionsXTZZ(pSubStrOrPos)

		#>

	  #------------------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AT A GIVEN SUBSTRING OR POSITION  #
	#==================================================================#

	def FindSplitsAtCSZZ(pSubStrOrPos, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pSubStrOrPos)
			return This.FindSplitsAtSubStringCSZZ(pSubStrOrPos, pCaseSensitive)

		but isNumber(pSubStrOrPos)
			return This.FindSplitsAtPositionZZ(pSubStrOrPos)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfNumbers()
			return This.FindSplitsAtPositionsZZ(pSubStrOrPos)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsPairOfNumbers()
			return This.FindSplitsAtSectionZZ(pSubStrOrPos[1], pSubStrOrPos[2])

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfPairsOfNumbers()
			return This.FindSplitsAsSectionsZZ(pSubStrOrPos)

		but isList(pSubStrOrPos)

			oParam = Q(pSubStrOrPos)

			#-- Case when named params are provided

			if oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindSplitsAtPositionZZ(pSubStrOrPos[2])
	
			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindSplitsAtPositionsZZ(pSubStrOrPos[2])

			but oParam.IsOneOfTheseNamedParams([ :SubString, :ThisSubString ]) 
				return This.FindSplitsAtSubStringCSZZ(pSubStrOrPos[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :SubStrings, :TheseSubStrings ]) 
				return This.FindSplitsAtSubStringsCSZZ(pSubStrOrPos[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindSplitsAtSectionZZ(pSubStrOrPos[2])
		
			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindSplitsAtSectionsZZ(pSubStrOrPos[2])

			ok
		else
			StzRaise("Incorrect param type! pSubStrOrPos must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindSplitsAtAsSectionsCS(pSubStrOrPos, pCaseSensitive)
			return This.FindSplitsAtCSZZ(pSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtZZ(pSubStrOrPos)
		return This.FindSplitsAtCSZZ(pSubStrOrPos, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAtAsSections(pSubStrOrPos)
			return This.FindSplitsAtCSZZ(pSubStr)

		#>

	  #------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AT A GIVEN POSITION   #
	#======================================================#

	def FindSplitsAtPositionZZ(n)
		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect pram type! n must be a number.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAtPositionZZ(n)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAtThisPositionAsSections(n)
			return This.FindSplitsAtPositionZZ(n)

		#>

	  #----------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AT MANY POSITIONS   #
	#----------------------------------------------------#

	def FindSplitsAtPositionsZZ(anPos)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aResult = StzSplitterQ(This.NumberOfChars()).FindSplitsAtPositionsZZ(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAtThesePositionsZZ(anPos)
			return This.FindSplitsAtPositionsZZ(anPos)

		def FindSplitsAtManyPositionsZZ(anPos)
			return This.FindSplitsAtPositionsZZ(anPos)

		#--

		def FindSplitsAtPositionsAsSections(anPos)
			return This.FindSplitsAtPositionsZZ(anPos)

		def FindSplitsAtThesePositionsAsSections(anPos)
			return This.FindSplitsAtPositionsZZ(anPos)

		def FindSplitsAtManyPositionsAsSections(anPos)
			return This.FindSplitsAtPositionsZZ(anPos)

		#>

	  #-------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AT A GIVEN SUBSTRING   #
	#=======================================================#

	def FindSplitsAtSubStringCSZZ(pcSubStr, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcsubStr must be a string.")
		ok

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT IsBoolean(pCaseSensitive)
			StzRaise("Incorrect param type! pCaseSensitive must be a boolean (TRUE or FALSE).")
		ok

		aSections = This.FindAsSectionsCS(pcSubStr, pCaseSensitive)
		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAtSectionsZZ(aSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsCSZZ(pcSubStr, pCaseSensitive)
			if isList(pcSubStr) and Q(pcSubstr).IsAtOrAtSubStringNamedParam()
				pcSubStr = pcSubstr[2]
			ok

			return This.FindSplitsAtSubStringCSZZ(pcSubStr, pCaseSensitive)

		def FindSplitsAtThisSubStringCSZZ(pcSubStr, pCaseSensitive)
			if isList(pcSubStr) and Q(pcSubstr).IsAtOrAtSubStringNamedParam()
				pcSubStr = pcSubstr[2]
			ok

			return This.FindSplitsAtSubStringCSZZ(pcSubStr, pCaseSensitive)

		#--

		def FindSplitsAtSubStringAsSectionsCSZZ(pcSubStr, pCaseSensitive)
			return This.FindSplitsAtSubStringCSZZ(pcSubStr, pCaseSensitive)

		def FindSplitsAsSectionsCS(pcSubStr, pCaseSensitive)
			if isList(pcSubStr) and Q(pcSubstr).IsAtOrAtSubStringNamedParam()
				pcSubStr = pcSubstr[2]
			ok

			return This.FindSplitsAtSubStringCSZZ(pcSubStr, pCaseSensitive)

		def FindSplitsAtThisSubStringAsSectionsCS(pcSubStr, pCaseSensitive)
			if isList(pcSubStr) and Q(pcSubstr).IsAtOrAtSubStringNamedParam()
				pcSubStr = pcSubstr[2]
			ok

			return This.FindSplitsAtSubStringCSZZ(pcSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtSubStringZZ(pcSubStr)
		return This.FindSplitsAtSubStringCSZZ(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsZZ(pcSubStr)
			return This.FindSplitsCSZZ(pcSubStr, :CaseSensitive = TRUE)

		def FindSplitsAtThisSubStringZZ(pcSubStr)
			return This.FindSplitsAtThisSubStringCSZZ(pcSubStr, :CaseSensitive = TRUE)
		#--

		def FindSplitsAtSubStringAsSectionsZZ(pcSubStr)
			return This.FindSplitsAtSubStringAsSectionsCSZZ(pcSubStr, :CaseSensitive = TRUE)

		def FindSplitsAsSections(pcSubStr)
			return This.FindSplitsAsSectionsCS(pcSubStr, :CaseSensitive = TRUE)

		def FindSplitsAtThisSubStringAsSections(pcSubStr)
			return This.FindSplitsAtThisSubStringAsSectionsCS(pcSubStr, :CaseSensitive = TRUE)

		#>


	  #------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AT GIVEN SUBSTRINGS   #
	#------------------------------------------------------#

	def FindSplitsAtSubStringsCSZZ(pacSubStr, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		anPos = This.FindCS(pacSubStr, pCaseSensitive)

		aResult = This.FindSplitsAtPositionsZZ(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseSubStringsCSZZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsAtSubStringsCSZZ(pacSubStr, pCaseSensitive)

		def FindSplitsAtManySubStringsCSZZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsAtSubStringsCSZZ(pacSubStr, pCaseSensitive)

		#--

		def FindSplitsAtSubStringsAsSectionsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsAtSubStringsCSZZ(pacSubStr, pCaseSensitive)

		def FindSplitsAtTheseSubStringsAsSectionsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsAtSubStringsCSZZ(pacSubStr, pCaseSensitive)

		def FindSplitsAtManySubStringsAsSectionsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsAtSubStringsCSZZ(pacSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtSubStringsZZ(pacSubStr)
		return This.FindSplitsAtSubStringsCSZZ(pacSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseSubStringsZZ(pacSubStr)
			return This.FindSplitsAtSubStringsZZ(pacSubStr)
	
		def FindSplitsAtManySubStringsZZ(pacSubStr)
			return This.FindSplitsAtSubStringsZZ(pacSubStr)

		#--

		def FindSplitsAtSubStringsAsSections(pacSubStr)
			return This.FindSplitsAtSubStringsZZ(pacSubStr)

		def FindSplitsAtTheseSubStringsAsSections(pacSubStr)
			return This.FindSplitsAtSubStringsZZ(pacSubStr)

		def FindSplitsAtManySubStringsAsSections(pacSubStr)
			return This.FindSplitsAtSubStringsZZ(pacSubStr)

		#>

	  #-----------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AT A GIVEN SECTION   #
	#=====================================================#

	def FindSplitsAtSectionZZ(n1, n2)
		if This.IsEmpty()
			return []
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAtSectionZZ(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAtThisSectionZZ(n1, n2)
			return This.FindSplitsAtSectionZZ(n1, n2)

		#--

		def FindSplitsAtSectionAsSections(n1, n2)
			return This.FindSplitsAtSectionZZ(n1, n2)

		def FindSplitsAtThisSectionAsSections(n1, n2)
			return This.FindSplitsAtSectionZZ(n1, n2)

		#>

	  #------------------------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AT A GIVEN SECTION -- INCLUDING BOUNDS  #
	#------------------------------------------------------------------------#

	def FindSplitsAtSectionIBZZ(n1, n2)
		if This.IsEmpty()
			return []
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAtSectionIBZZ(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAtThisSectionIBZZ(n1, n2)
			return This.SplitAtSectionIBZZ(n1, n2)

		#--

		def FindSplitsAtSectionAsSectionsIB(n1, n2)
			return This.FindSplitsAtSectionIBZZ(n1, n2)

		def FindSplitsAtThisSectionAsSectionsIB(n1, n2)
			return This.SplitAtSectionIBZZ(n1, n2)

		#>

	  #---------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AT MANY SECTIONS   #
	#---------------------------------------------------#

	def FindSplitsAtSectionsZZ(paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAtSectionsZZ(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseSectionsZZ(paSections)
			return This.FindSplitsAtSectionsZZ(paSections)

		#--

		def FindSplitsAtSectionsAsSections(paSections)
			return This.FindSplitsAtSectionsZZ(paSections)

		def FindSplitsAtTheseSectionsAsSections(paSections)
			return This.FindSplitsAtSectionsZZ(paSections)

		#>

	  #-----------------------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN POSITION OR SUBSTRING   #
	#-----------------------------------------------------------------------#

	def FindSplitsBeforeCSZZ(pSubStrOrPos, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pSubStrOrPos)
			return This.FindSplitsBeforeSubStringCSZZ(pSubStrOrPos, pCaseSensitive)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfStrings()
			return This.FindSplitsBeforeSubStringsCSZZ(pSubStrOrPos, pCaseSensitive)

		but isNumber(pSubStrOrPos)
			return This.FindSplitsBeforePositionZZ(pSubStrOrPos)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfNumbers()
			return This.FindSplitsBeforePositionsZZ(pSubStrOrPos)

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsPairOfNumbers()
			return This.FindSplitsBeforeSectionZZ(pSubStrOrPos[1], pSubStrOrPos[2])

		but isList(pSubStrOrPos) and Q(pSubStrOrPos).IsListOfPairsOfNumbers()
			return This.FindSplitsBeforeSectionsZZ(pSubStrOrPos[1], pSubStrOrPos[2])

		but isList(pSubStrOrPos)

			#-- Case when named params are provided

			if Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindSplitsBeforePositionZZ(pSubStrOrPos[2])
	
			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindSplitsBeforePositionsZZ(pSubStrOrPos[2])

			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :SubString, :ThisSubString ]) 
				return This.FindSplitsBeforeSubStringCSZZ(pSubStrOrPos[2], pCaseSensitive)
		
			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :SubStrings, :TheseSubStrings ]) 
				return This.FindSplitsBeforeSubStringsCSZZ(pSubStrOrPos[2], pCaseSensitive)

			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindSplitsBeforeSectionZZ(pSubStrOrPos[2])
		
			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindSplitsBeforeSectionsZZ(pSubStrOrPos[2])

			ok
		else
			StzRaise("Incorrect param type! pSubStrOrPos must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForms

		def FindSplitsBeforeAsSectionsCS(pSubStrOrPos, pCaseSensitive)
			return This.FindSplitsBeforeCSZZ(pSubStrOrPos, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeZZ(pSubStrOrPos)
		return This.FindSplitsBeforeCSZZ(pSubStrOrPos, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsBeforeAsSections(pSubStrOrPos)
			return This.FindSplitsBeforeZZ(pSubStrOrPos)

		#>

	  #----------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN POSITION   #
	#----------------------------------------------------------#

	def FindSplitsBeforePositionZZ(n)
		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforePositionZZ(n)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeThisPositionZZ(n)
			return This.FindSplitsBeforePositionZZ(n)

		#--

		def FindSplitsBeforePositionAsSections(n)
			return This.FindSplitsBeforePositionZZ(n)

		def FindSplitsBeforeThisPositionAsSections(n)
			return This.FindSplitsBeforePositionZZ(n)

		#>

	  #--------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE MANY POSITIONS   #
	#--------------------------------------------------------#

	def FindSplitsBeforePositionsZZ(anPos)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforePositionsZZ(anPos)
		return aResult			

		#< @FunctionAlternativeForms

		def FindSplitsBeforeThesePositionsZZ(anPos)
			return This.FindSplitsBeforePositionsZZ(anPos)

		def FindSplitsBeforeManyPositionsZZ(anPos)
			return This.FindSplitsBeforePositionsZZ(anPos)

		#--

		def FindSplitsBeforePositionsAsSections(anPos)
			return This.FindSplitsBeforePositionsZZ(anPos)

		def FindSplitsBeforeThesePositionsAsSections(anPos)
			return This.FindSplitsBeforePositionsZZ(anPos)

		def FindSplitsBeforeManyPositionsAsSections(anPos)
			return This.FindSplitsBeforePositionsZZ(anPos)

		#>

	  #-----------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN SUBSTRING   #
	#-----------------------------------------------------------#

	def FindSplitsBeforeSubStringCSZZ(pcSubStr, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		anPos = This.FindCS(pcSubStr, pCaseSensitive)
		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforePositionsZZ(anPos)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisSubStringCSZZ(pcSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringCSZZ(pcSubStr, pCaseSensitive)

		#--

		def FindSplitsBeforeSubStringAsSectionsCS(pcSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringCSZZ(pcSubStr, pCaseSensitive)

		def FindSplitsBeforeThisSubStringAsSectionsCS(pcSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringCSZZ(pcSubStr, pCaseSensitive)

		#>
				
	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeSubStringZZ(pcSubStr)
		return This.FindSplitsBeforeSubStringCSZZ(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisSubStringZZ(pcSubStr)
			return This.FindSplitsBeforeSubString(pcSubStr)

		#--

		def FindSplitsBeforeSubStringAsSections(pcSubStr)
			return This.FindSplitsBeforeSubStringZZ(pcSubStr)

		def FindSplitsBeforeThisSubStringAsSections(pcSubStr)
			return This.FindSplitsBeforeSubStringZZ(pcSubStr)	

		#>

	  #---------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE MANY SUBSTRINGS   #
	#---------------------------------------------------------#

	def FindSplitsBeforeSubStringsCSZZ(pacSubStr, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(pacSubStr) and Q(pacSubStr).IsListOfStrings() )
			StzRaise("Incorrect param type! pacSubStr must be a list of strings.")
		ok

		anPos = This.FindCS( pacSubStr, pCaseSensitive )
		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforePositionsZZ(anPos)

		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseSubStringsCSZZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringsCSZZ(pacSubStr, pCaseSensitive)

		def FindSplitsBeforeManySubStringsCSZZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringsCSZZ(pacSubStr, pCaseSensitive)

		#--

		def FindSplitsBeforeSubStringsAsSectionsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringsCSZZ(pacSubStr, pCaseSensitive)

		def FindSplitsBeforeTheseSubStringsAsSectionsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringsCSZZ(pacSubStr, pCaseSensitive)

		def FindSplitsBeforeManySubStringsAsSectionsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsBeforeSubStringsCSZZ(pacSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeSubStringsZZ(pacSubStr)
		return This.FindSplitsBeforeSubStringsCSZZ(pacSubStr, :CaseSensitive = TRUE)
	
		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseSubStringsZZ(pacSubStr)
			return This.FindSplitsBeforeSubStringsZZ(pacSubStr)

		def FindSplitsBeforeManySubStringsZZ(pacSubStr)
			return This.FindSplitsBeforeSubStringsZZ(pacSubStr)

		#--

		def FindSplitsBeforeSubStringsAsSections(pacSubStr)
			return This.FindSplitsBeforeSubStringsZZ(pacSubStr)

		def FindSplitsBeforeTheseSubStringsAsSections(pacSubStr)
			return This.FindSplitsBeforeSubStringsZZ(pacSubStr)

		def FindSplitsBeforeManySubStringsAsSections(pacSubStr)
			return This.FindSplitsBeforeSubStringsZZ(pacSubStr)

		#>

	  #---------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN SECTION   #
	#---------------------------------------------------------#

	def FindSplitsBeforeSectionZZ(n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforeSectionZZ(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisSectionZZ(n1, n2)
			return This.FindSplitsBeforeSectionZZ(n1, n2)

		#--

		def FindSplitsBeforeSectionAsSections(n1, n2)
			return This.FindSplitsBeforeSectionZZ(n1, n2)

		def FindSplitsBeforeThisSectionAsSections(n1, n2)
			return This.FindSplitsBeforeSectionZZ(n1, n2)

		#>

	  #--------------------------------------------------------------------------#
	 #   FINDING SPLITS (AS SPLITS) BEFORE A GIVEN SECTION -- INCLUDING BOUND   #
	#--------------------------------------------------------------------------#

	def FindSplitsBeforeSectionIBZZ(n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforeSectionIBZZ(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisSectionIBZZ(n1, n2)
			return This.FindSplitsBeforeSectionIBZZ(n1, n2)

		#--

		def FindSplitsBeforeSectionAsSectionsIB(n1, n2)
			return This.FindSplitsBeforeSectionIBZZ(n1, n2)

		def FindSplitsBeforeThisSectionAsSectionsIB(n1, n2)
			return This.FindSplitsBeforeSectionIBZZ(n1, n2)

		#>

	  #-------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE MANY SECTIONS   #
	#-------------------------------------------------------#

	def FindSplitsBeforeSectionsZZ(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBeforeSectionsZZ(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseSectionsZZ(paSections)
			return This.FindSplitsBeforeSectionsZZ(paSections)

		def FindSplitsBeforeManySectionsZZ(paSections)
			return This.SplitBeforeSectionsZZ(paSections)

		#--

		def FindSplitsBeforeSectionsAsSections(paSections)
			return This.FindSplitsBeforeSectionsZZ(paSections)

		def FindSplitsBeforeTheseSectionsAsSections(paSections)
			return This.FindSplitsBeforeSectionsZZ(paSections)

		def FindSplitsBeforeManySectionsAsSections(paSections)
			return This.SplitBeforeSectionsZZ(paSections)

		#>

	  #------------------------------------------------------------------------#
	 #   FINING SPLITS (AS SECTIONS) BEFORE MANY SECTIONS -- INCLUDING BOUND  #
	#------------------------------------------------------------------------#

	def FindSplitsBeforeSectionsIBZZ(paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).SplitBeforeSectionIBZZ(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseSectionsIBZZ(paSections)
			return This.FindSplitsBeforeSectionsIBZZ(paSections)

		def FindSplitsBeforeManySectionsIBZZ(paSections)
			return This.FindSplitsBeforeSectionsIBZZ(paSections)

		#--

		def FindSplitsBeforeSectionsAsSectionsIB(paSections)
			return This.FindSplitsBeforeSectionsIBZZ(paSections)

		def FindSplitsBeforeTheseSectionsAsSectionsIB(paSections)
			return This.FindSplitsBeforeSectionsIBZZ(paSections)

		def FindSplitsBeforeManySectionsAsSectionsIB(paSections)
			return This.FindSplitsBeforeSectionsIBZZ(paSections)

		#>

	  #---------------------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AFTER A GIVEN POSITION OR SUBSTRING  #
	#---------------------------------------------------------------------#

	def FindSplitsAfterCSZZ(pSubStrOrPos, pCaseSensitive)
		if isString(pSubStrOrPos)
			return This.FindSplitsAfterSubStringCSZZ(pSubStrOrPos, pCaseSensitive)

		but isNumber(pSubStrOrPos)
			return This.FindSplitsAfterPositionZZ(pSubStrOrPos)

		but isList(pSubStrOrPos)

			#-- Case when named params are provided

			if Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Position, :ThisPosition ])

				return This.FindSplitsAfterPositionZZ(pSubStrOrPos[2])
	
			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindSplitsAfterPositionsZZ(pSubStrOrPos[2])

			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :SubString, :ThisSubString ]) 
				return This.FindSplitsAfterSubStringCSZZ(pSubStrOrPos[2], pCaseSensitive)
		
			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :SubStrings, :TheseSubStrings ]) 
				return This.FindSplitsAfterSubStringsCSZZ(pSubStrOrPos[2], pCaseSensitive)

			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindSplitsAfterSectionZZ(pSubStrOrPos[2])

			but Q(pSubStrOrPos).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindSplitsAfterSectionsZZ(pSubStrOrPos[2])

			#-- Providing numbers, strings, or pairs of numbers,
			#   directly without named params

			but Q(pSubStrOrPos).IsListOfNumbers()
				return This.FindSplitsAfterPositionsZZ(pSubStrOrPos)

			but Q(pSubStrOrPos).IsListOfStrings()
				return This.FindSplitsAfterSubStringsZZ(pSubStrOrPos)

			but Q(pSubStrOrPos).IsListOfPairsOfNumbers()
				return This.FindSplitsAfterSectionsZZ(pSubStrOrPos)

			ok
		else
			StzRaise("Incorrect param type! pSubStrOrPos must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindSplitsAfterAsSectionsCS(pSubStrOrPos, pCaseSensitive)
			return This.FindSplitsAfterCSZZ(pSubStrOrPos, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterZZ(pSubStrOrPos)
		return This.FindSplitsAfterCSZZ(pSubStrOrPos, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterAsSections(pSubStrOrPos)
			return This.FindSplitsAfterCSZZ(pSubStrOrPos, pCaseSensitive)

		#>

	  #----------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN POSITION   #
	#----------------------------------------------------------#

	def FindSplitsAfterPositionZZ(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterPositionZZ(n)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisPositionZZ(n)
			return This.FindSplitsAfterPositionZZ(n)

		def FindSplitsAfterThisPositionAsSections(n)
			return This.FindSplitsAfterPositionZZ(n)

		#>

	  #--------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE MANY POSITIONS   #
	#--------------------------------------------------------#

	def FindSplitsAfterPositionsZZ(anPos)
		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterPositionsZZ(anPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThesePositionsZZ(anPos)
			return This.FindSplitsAfterThesePositionsZZ(anPos)

		def FindSplitsAfterManyPositionsZZ(anPos)
			return This.FindSplitsAfterManyPositionsZZ(anPos)

		#--

		def FindSplitsAfterPositionsAsSections(anPos)
			return This.FindSplitsAfterPositionsZZ(anPos)

		def FindSplitsAfterThesePositionsAsSections(anPos)
			return This.FindSplitsAfterThesePositionsZZ(anPos)

		def FindSplitsAfterManyPositionsAsSections(anPos)
			return This.FindSplitsAfterManyPositionsZZ(anPos)

		#>

	  #-----------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN SUBSTRING   #
	#-----------------------------------------------------------#

	def FindSplitsAfterSubStringCSZZ(pcSubStr, pCaseSensitive)
		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		anPos = This.FindCS(pcSubStr, pCaseSensitive)
		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterPositionsZZ(anPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisSubStringCSZZ(pcSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringCSZZ(pcSubStr, pCaseSensitive)

		#--

		def FindSplitsAfterSubStringAsSectionsCS(pcSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringCSZZ(pcSubStr, pCaseSensitive)

		def FindSplitsAfterThisSubStringAsSectionsCS(pcSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringCSZZ(pcSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterSubStringZZ(pcSubStr)
		return This.FindSplitsAfterSubStringCSZZ(pcSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisSubStringZZ(pcSubStr)
			return This.FindSplitsAfterSubStringZZ(pcSubStr)

		#--

		def FindSplitsAfterSubStringAsSections(pcSubStr)
			return This.FindSplitsAfterSubStringZZ(pcSubStr)

		def FindSplitsAfterThisSubStringAsSections(pcSubStr)
			return This.FindSplitsAfterSubStringZZ(pcSubStr)

		#>

	  #---------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE MANY SUBSTRINGS   #
	#---------------------------------------------------------#

	def FindSplitsAfterSubStringsCSZZ(pacSubStr, pCaseSensitive)
		if NOT ( isList(pacSubStr) and Q(pacSubStr).IsListOfStrings() )
			StzRaise("Incorrect param type! pacSubStr must be a list of strings.")
		ok

		anPos = This.FindCS( pacSubStr, pCaseSensitive )
		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterPositionsZZ(anPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterTheseSubStringsCSZZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringsCSZZ(pacSubStr, pCaseSensitive)

		def FindSplitsAfterManySubStringsCSZZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringsCSZZ(pacSubStr, pCaseSensitive)

		#--

		def FindSplitsAfterSubStringsAsSectionsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringsCSZZ(pacSubStr, pCaseSensitive)

		def FindSplitsAfterTheseSubStringsAsSectionsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringsCSZZ(pacSubStr, pCaseSensitive)

		def FindSplitsAfterManySubStringsAsSectionsCSZZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsAfterSubStringsCSZZ(pacSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterSubStringsZZ(pacSubStr)
		return This.FindSplitsAfterSubStringsCSZZ(pacSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterTheseSubStringsZZ(pacSubStr)
			return This.FindSplitsAfterSubStringsZZ(pacSubStr)

		def FindSplitsAfterManySubStringsZZ(pacSubStr)
			return This.FindSplitsAfterSubStringsZZ(pacSubStr)

		#--

		def FindSplitsAfterSubStringsAsSections(pacSubStr)
			return This.FindSplitsAfterSubStringsZZ(pacSubStr)

		def FindSplitsAfterTheseSubStringsAsSections(pacSubStr)
			return This.FindSplitsAfterSubStringsZZ(pacSubStr)

		def FindSplitsAfterManySubStringsAsSectionsZZ(pacSubStr)
			return This.FindSplitsAfterSubStringsZZ(pacSubStr)

		#>

	  #--------------------------------------------------------#
	 #   FINDING SPLITS (َAS SECTIONS) AFTER A GIVEN SECTION   #
	#--------------------------------------------------------#

	def FindSplitsAfterSectionZZ(n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterSectionZZ(n1 , n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisSectionZZ(n1, n2)
			return This.FindSplitsAfterSectionZZ(n1, n2)

		#--

		def FindSplitsAfterSectionAsSections(n1, n2)
			return This.FindSplitsAfterSectionZZ(n1, n2)

		def FindSplitsAfterThisSectionAsSections(n1, n2)
			return This.FindSplitsAfterSectionZZ(n1, n2)

		#>

	  #--------------------------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AFTER A GIVEN SECTION -- INCLUDING BOUND  #
	#--------------------------------------------------------------------------#

	def FindSplitsAfterSectionIBZZ(n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterSectionIBZZ(n1 , n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisSectionIBZZ(n1, n2)
			return This.FindSplitsAfterSectionIBZZ(n1, n2)

		#--

		def FindSplitsAfterSectionAsSectionsIB(n1, n2)
			return This.FindSplitsAfterSectionIBZZ(n1, n2)

		def FindSplitsAfterThisSectionAsSectionsIB(n1, n2)
			return This.FindSplitsAfterSectionIBZZ(n1, n2)


		#>

	  #------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AFTER MANY SECTIONS   #
	#------------------------------------------------------#

	def FindSplitsAfterSectionsZZ(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterSectionsZZ(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAfterTheseSectionsZZ(paSections)
			return This.FindSplitsAfterTheseSectionsZZ(paSections)

		#--

		def FindSplitsAfterSectionsAsSections(paSections)
			return This.FindSplitsAfterSectionsZZ(paSections)

		def FindSplitsAfterTheseSectionsAsSections(paSections)
			return This.FindSplitsAfterTheseSectionsZZ(paSections)

		#>

	  #-------------------------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AFTER MANY SECTIONS -- INCLUDING BOUNDS  #
	#-------------------------------------------------------------------------#

	def FindSplitsAfterSectionsIBZZ(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsAfterSectionsIBZZ(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAfterTheseSectionsIBZZ(paSections)
			return This.FindSplitsAfterSectionsIBZZ(paSections)

		#--

		def FindSplitsAfterSectionsAsSectionsIB(paSections)
			return This.FindSplitsAfterSectionsIBZZ(paSections)

		def FindSplitsAfterTheseSectionsAsSectionsIB(paSections)
			return This.FindSplitsAfterSectionsIBZZ(paSections)

		#>

	  #--------------------------------------------------------------------#
	 #  FINDING SPLITS (AS SECTIONS) BETWEEN TWO POSITIONS OR SUBSTRINGS  #
	#====================================================================#

	def FindSplitsBetweenCSZZ(pBound1, pBound2, pCaseSensitive)
		if NOT ( BothAreStringsOrNumbers(pBound1, pBound2) )
			StzRaise("Incorrect params types! pBound1 and pBound2 must be both numbers or strings.")
		ok

		if BothAreNumbers(pBound1, pBound2)
			aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBetweenZZ(pBound1, pBound2)

		else # case if BothAreStrings()
			anFirstBounds  = This.FindAllCS(pBound1, pCaseSensitive)
			anSecondBounds = This.FindAllCS(pBound2, pCaseSensitive)

			aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
			anFirstBounds  = aListOfBounds[1]
			anSecondBounds = aListOfBounds[2]

			aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)

			aResult = StzSplitterQ( This.NumberOfChars() ).
				   FindSplitsBetweenSectionsZZ(aSections)
		ok
		
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBetweenAsSectionsCS(pBound1, pBound2, pCaseSensitive)
			return This.FindSplitsBetweenCSZZ(pBound1, pBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetweenZZ(pBound1, pBound2)
		return This.FindSplitsBetweenCS(pBound1, pBound2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsBetweenAsSections(pBound1, pBound2)
			return This.FindSplitsBetweenZZ(pBound1, pBound2)

		#>

	  #----------------------------------------------------------------------------------------#
	 #  FINDING SPLITS (AS SECTIONS) BETWEEN TWO POSITIONS OR SUBSTRINGS -- INCLUDING BOUNDS  #
	#----------------------------------------------------------------------------------------#

	def FindSplitsBetweenCSIBZZ(pBound1, pBound2, pCaseSensitive)
		if NOT ( BothAreStringsOrNumbers(pBound1, pBound2) )
			StzRaise("Incorrect params types! pBound1 and pBound2 must be both numbers or strings.")
		ok

		if BothAreNumbers(pBound1, pBound2)
			aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsBetweenIBZZ(pBound1, pBound2)

		else # case if BothAreStrings()
			anFirstBounds  = This.FindAllCS(pBound1, pCaseSensitive)
			anSecondBounds = This.FindAllCS(pBound2, pCaseSensitive)

			aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
			anFirstBounds  = aListOfBounds[1]
			anSecondBounds = aListOfBounds[2]

			nLen = len(anFirstBounds)
			for i = 1 to nLen
				anFirstBounds[i]--
				anSecondBounds[i]++
			next

			aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)

			aResult = StzSplitterQ( This.NumberOfChars() ).
				   FindSplitsBetweenSectionsZZ(aSections)
		ok

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBetweenAsSectionsCSIB(pBound1, pBound2, pCaseSensitive)
			return This.FindSplitsBetweenCSIBZZ(pBound1, pBound2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetweenIBZZ(pBound1, pBound2)
		return This.FindSplitsBetweenCSIBZZ(pBound1, pBound2, :CaseSensitive = TRUE)


		#< @FunctionAlternativeForm

		def FindSplitsBetweenAsSectionsIB(pBound1, pBound2)
			return This.FindSplitsBetweenIBZZ(pBound1, pBound2)

		#>

	  #------------------------------------------------------#
	 #  FINDING SPLITS (AS SECTIONS) BETWEEN TWO POSITIONS  #
	#------------------------------------------------------#

	def FindSplitsBetweenPositionsZZ(n1, n2)
		This.FindSplitsAtSectionZZ(n1, n2)

		#< @FunctionAlternativeForms

		def FindSplitsBetweenThesePositionsZZ(n1, n2)
			return This.FindSplitsBetweenPositionsZZ(n1, n2)

		#--

		def FindSplitsBetweenPositionsAsSections(n1, n2)
			return This.FindSplitsBetweenPositionsZZ(n1, n2)

		def FindSplitsBetweenThesePositionsAsSections(n1, n2)
			return This.FindSplitsBetweenPositionsZZ(n1, n2)

		#>
		
	  #--------------------------------------------------------------------------#
	 #  FINDING SPLITS (AS SECTIONS) BETWEEN TWO POSITIONS -- INCLUDING BOUNDS  #
	#--------------------------------------------------------------------------#

	def FindSplitsBetweenPositionsIBZZ(n1, n2)
		This.FindSplitsAtSectionIBZZ(n1, n2)

		#< @FunctionAlternativeForms

		def FindSplitsBetweenThesePositionsIBZZ(n1, n2)
			return This.FindSplitsBetweenPositionsIBZZ(n1, n2)

		#--

		def FindSplitsBetweenPositionsAsSectionsIB(n1, n2)
			return This.FindSplitsBetweenPositionsIBZZ(n1, n2)

		def FindSplitsBetweenThesePositionsAsSectionsIB(n1, n2)
			return This.FindSplitsBetweenPositionsIBZZ(n1, n2)

		#>

	  #-------------------------------------------------------#
	 #  FINDING SPLITS (AS SECTIONS) BETWEEN TWO SUBSTRINGS  #
	#-------------------------------------------------------#

	def FindSplitsBetweenSubStringsCSZZ(pacSubStr, pCaseSensitive)
		aSections = This.FindAsSections(pacSubStr, pCaseSensitive)
		aResult = This.FindSplitsBetweenSectionsZZ(aSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBetweenTheseSubStringsCSZZ(pacSubStr, pCaseSensitive)
			return This.FindSplitsBetweenSubStringsCSZZ(pacSubStr, pCaseSensitive)

		#--

		def FindSplitsBetweenSubStringsAsSectionsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsBetweenSubStringsCSZZ(pacSubStr, pCaseSensitive)

		def FindSplitsBetweenTheseSubStringsAsSectionsCS(pacSubStr, pCaseSensitive)
			return This.FindSplitsBetweenSubStringsCSZZ(pacSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetweenSubStringsZZ(pacSubStr)
		return This.FindSplitsBetweenSubStringsCSZZ(pacSubStr, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsBetweenTheseSubStringsZZ(pacSubStr)
			return This.FindSplitsBetweenSubStringsZZ(pacSubStr)

		#--

		def FindSplitsBetweenSubStringsAsSections(pacSubStr)
			return This.FindSplitsBetweenSubStringsZZ(pacSubStr)

		def FindSplitsBetweenTheseSubStringsAsSections(pacSubStr)
			return This.FindSplitsBetweenSubStringsZZ(pacSubStr)

		#>

	  #-----------------------------------------------#
	 #    FINDING SPLITS (AS SECTIONS) TO N PARTS    #
	#===============================================#

	def FindSplitsToNPartsZZ(n)
		aResult = StzSplitterQ( This.NumberOfChars() ).FindSplitsToNPartsZZ(n)
		return aResult

		def FindSplitsToNPartsAsSections(n)
			return This.FindSplitsToNPartsZZ(n)

	  #--------------------------------------------------#
	 #   FINDING SPLITS TO PARTS OF (EXACTLY) N CHARS   #
	#--------------------------------------------------#
	# Remaining part less the n chars is not returned

	def FindSplitsToPartsOfNCharsZZ(n)
		aResult = StzSplitterQ( This.NumberOfChars() ).
				FindSplitsToPartsOfExactlyNPositionsZZ(n)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsToPartsOfExactlyNCharsZZ(n)
			return This.FindSplitsToPartsOfNCharsZZ(n)

		#--

		def FindSplitsToPartsOfNCharsAsSections(n)
			return This.FindSplitsToPartsOfNCharsZZ(n)

		def FindSplitsToPartsOfExactlyNCharsAsSections(n)
			return This.FindSplitsToPartsOfNCharsZZ(n)

		#>

	  #--------------------------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) TO PARTS OF N CHARS -- INCLUDING BOUNDS   #
	#--------------------------------------------------------------------------#
	# The remaing part (if any) less then n chars is also returned

	def FindSplitsToPartsOfNCharsIBZZ(n)
		aResult = StzSplitterQ( This.NumberOfChars() ).
				FindSplitsToPartsOfNPositionsIBZZ(n)

		return aResult

	  #----------------------------------------------------------#
	 #    FINDING SPLITS (AS SECTIONS) UNDER A GIVEN CONDTION   #
	#==========================================================#

	def FindSplitsWZZ(pcCondition)
		/*
		? StzSplitterQ(1:5).FindSplitsWZZ('Q(@item).IsMultipleOf(2)')
		*/

		if isList(pcCondition)

			if Q(pcCondition).IsWhereNamedParam()
				return This.FindSplitsAtWZZ(pcCondition[2])

			but Q(pcCondition).IsAtNamedParam()
				return This.FindSplitsAtWZZ(pcCondition[2])

			but Q(pcCondition).IsBeforeNamedParam()
				return This.FindSplitsBeforeWZZ(pcCondition[2])

			but Q(pcCondition).IsAfterNamedParam()
				return This.FindSplitsAfterWZZ(pcCondition[2])

			ok
		
		else

			return This.FindSplitsAtWZZ(pcCondition)
		ok

		#< @FunctionAlternativeForm

		def FindSplitsAsSectionsW(pcCondition)
			return This.FindSplitsWZZ(pcCondition)

		#>

	  #-------------------------------------------------------#
	 #    FINSING SPLITS (AS SECTIONS) AT A GIVEN CONDTION   #
	#-------------------------------------------------------#

	def FindSplitsAtWZZ(pcCondition)
			
		if isList(pcCondition) and Q(pcCondition).IsWhereNamedParam()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		aResult = []

		pcCondition = Q(pcCondition).TrimQ().BoundsRemoved(["{","}"])

		if Q(pcCondition).ContainsCS("@SubString", :CS = FALSE)

			aSections = This.FindSubStringsAsSectionsW(pcCondition)
			aResult = This.FindSplitsAtSectionsZZ(aSections)

		else

			anPositions = This.FindW(pcCondition)
			aResult = This.FindSplitsAtPositionsZZ(anPositions)
		ok

		return aResult

	  #-----------------------------------------------------------#
	 #    FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN CONDTION   #
	#-----------------------------------------------------------#

	def FindSplitsBeforeWZZ(pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsBothCS("@char", "@substring", :CaseSensitive = FALSE)
			StzRaise("Incorrect syntax! pcCondition must contain either @Char or @SubString keywords but not both.")
		ok

		if oCondition.ContainsCS("@substring",  :CaseSensitive = FALSE)
			anPositions = This.FindSubStringsW(pcCondition)

		else
			anPositions = This.FindCharsW(pcCondition)
		ok

		aResult = This.FindSplitsBeforePositionsZZ(anPositions)

		return aResult

	  #----------------------------------------------------------#
	 #    FINDING SPLITS (AS SECTIONS) AFTER A GIVEN CONDTION   #
	#----------------------------------------------------------#

	def FindSplitsAfterWZZ(pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsBothCS("@char", "@substring", :CaseSensitive = FALSE)
			StzRaise("Incorrect syntax! pcCondition must contain either @Char or @SubString keywords but not both.")
		ok

		if oCondition.ContainsCS("@substring",  :CaseSensitive = FALSE)
			anPositions = This.FindSubStringsW(pcCondition)

		else
			anPositions = This.FindCharsW(pcCondition)
		ok

		aResult = This.FindSplitsAfterPositionsZZ(anPositions)

		return aResult
