	  #=======================================#
	 #   SPLITTING THE LIST -- XT/EXTENDED   #
	#=======================================#

	#TODO
	# Add SplitAround(), SplitAroundPosition(), SplitAroundPositions(),
	# SplitAroundItem(), SplitAroundItems(),
	# SplitAroundSection(), SplitAroundSections()
	
	# Add ..IB() extensions to all those functions

	#todo
	# Make same feature in stzList

	#todo
	# add to...() as alternative of SplitTo..() all over the library


	def SplitCSXT(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isList(pItem)
			return This.SplitAtItemCS(pItem, pCaseSensitive)

		else

			oParam = Q(pItem)

			#-- SPLITTING AT / USING

			if oParam.IsOneOfTheseNamedParams([ :At, :Using ])
				return This.SplitAtCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtPosition, :AtThisPosition ]) 
				return This.SplitAtPosition(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AtPositions, :AtThesePositions ]) 
				return This.SplitAtPositions(pItem[2])

			but oParam.IsOneOfTheseNamedParams([
						:AtItem, :AtThisItem,
						:UsingItem, :UsingThisItem ]) 

				return This.SplitAtItemCS(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([
						:AtItems, :AtTheseItems,
						:UsingItems, :UsingTheseItems ]) 

				return This.SplitAtItemsCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtSection, :AtThisSection ]) 
				return This.SplitAtSection(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AtSections, :AtTheseSections ]) 
				return This.SplitAtSections(pItem[2])

			#-- SPLITTING BEFORE

			but oParam.IsBeforeNamedParam()
				return This.SplitBeforeCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforePosition, :BeforeThisPosition ]) 
				return This.SplitBeforePosition(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :BeforePositions, :BeforeThesePositions ]) 
				return This.SplitBeforePositions(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :BeforeItem, :BeforeThisItem ]) 
				return This.SplitBeforeItemCS(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeItems, :BeforeTheseItems ]) 
				return This.SplitBeforeItemsCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforeSection, :BeforeThisSection ]) 
				return This.SplitBeforeSection(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeSections, :BeforeTheseSections ]) 
				return This.SplitBeforeSections(pItem[2])

			#-- SPLITTING AFTER

			but oParam.IsAfterNamedParam()
				return This.SplitAfterCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterPosition, :AfterThisPosition ]) 
				return This.SplitAfterPosition(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AfterPositions, :AfterThesePositions ]) 
				return This.SplitAfterPositions(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :AfterItem, :AfterThisItem ]) 
				return This.SplitAfterItemCS(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :AfterItems, :AfterTheseItems ]) 
				return This.SplitAfterItemsCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterSection, :AfterThisSection ]) 
				return This.SplitAfterSection(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AfterSections, :AfterTheseSections ]) 
				return This.SplitAfterSections(pItem[2])

			# SPLITTING BETWEEN

			but oParam.IsBetweenNamedParam() and
				isList(pItem) and len(pItem) = 2
				
				if isList(pItem[2]) and Q(pItem[2]).IsAndNamedParam()
					pItem[2] = pItem[2][2]
				ok

				return This.SplitBetweenCS(pItem[1], pItem[2], pCaseSensitive)

			but oParam.IsBetweenPositionsNamedParam()
				return This.SplitBetweenPositions(pItem[1], pItem[2])

			but oParam.IsBetweenItemsNamedParam()
				return This.SplitBetweenItemsCS(pItem[1], pItem[2], pCaseSensitive)

			# SPLITTING TO PARTS

			but oParam.IsToNPartsNamedParam()
				return This.SplitToNParts(pItem[2])

			but oParam.IsToPartsOfNItemsNamedParam()
				return This.SplitToPartsOfNItems(pItem[2])

			but oParam.IsToPartsOfExactlyNItemsNamedParam()
				return This.SplitToPartsOfExactlyNItems(pItem[2])

			but oParam.IsToPartsOfNItemsXTNamedParam()
				return This.SplitToPartsOfNItemsXT(pItem[2])

			# SPLITTING WHERE

			but oParam.IsWhereOrAtWhereNamedParam()
				return This.SplitAtW(pItem[2])

			but oParam.IsBeforeWhereNamedParam()
				return This.SplitBeforeW(pItem[2])

			but oParam.IsAfterWhereNamedParam()
				return This.SplitAfterW(pItem[2])

			else
				return This.SplitAtItemCS(pItem, pCaseSensitive)

			ok
		ok

		#< @FunctionFluentForm

		def SplitCSXTQ(pItem, pCaseSensitive)
			return This.SplitCSXTQR(pItem, pCaseSensitive, :stzList)

		def SplitCSXTQR(pItem, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
				on :stzList
					return new stzList( This.SplitCS(pItem, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitCSXT(pItem, pCaseSensitive) )
	
				on :stzListOfItems
					return new stzListOfItems( This.SplitCSXT(pItem, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SplitCSXT(pItem, pCaseSensitive) )
	
				on :stzListOfObjects
					return new stzListOfObjects( This.SplitCSXT(pItem, pCaseSensitive) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitCSXT(pItem, pCaseSensitive) )
	
				on :stzListOfPairs
					return new stzListOfpairs( This.SplitCSXT(pItem, pCaseSensitive) )
	
				on :stzListOfSets
					return new stzListOfSets( This.SplitCSXT(pItem, pCaseSensitive) )
	
				on :stzListOfHashLists
					return new stzListOfHashLists( This.SplitCSXT(pItem, pCaseSensitive) )
	
				on :stzListOfGrids
					return new stzListOfGrids( This.SplitCSXT(pItem, pCaseSensitive) )
	
				on :stzListOfTables
					return new stzListOfTables( This.SplitCSXT(pItem, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off

		#>

	def SplittedCSXT(pItem, pCaseSensitive)
		return This.SplitCSXT(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitXT(pItem)
		return This.SplitCSXT(pItem, TRUE)

		#< @FunctionFluentForm

		def SplitXTQ(pItem)
			return This.SplitXTQR(pItem, :stzList)

		def SplitXTQR(pItem, pcReturnType)
			return This.SplitCSXTQR(pItem, TRUE, pcReturnType)

		#>

	def SplittedXT(pItem)
		return This.SplitXT(pItem)

	  #--------------------------------------#
	 #  SPLITTING THE LIST -- XTZ/EXTENDED  #
	#--------------------------------------#

	def SplitCSXTZ(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isList(pItem)
			return This.SplitAtItemCSZ(pItem, pCaseSensitive)

		else

			oParam = Q(pItem)

			#-- SPLITTING AT / USING

			if oParam.IsOneOfTheseNamedParams([ :At, :Using ])
				return This.SplitAtCSZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtPosition, :AtThisPosition ]) 
				return This.SplitAtPositionZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AtPositions, :AtThesePositions ]) 
				return This.SplitAtPositionsZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([
						:AtItem, :AtThisItem,
						:UsingItem, :UsingThisItem ]) 

				return This.SplitAtItemCSZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([
						:AtItems, :AtTheseItems,
						:UsingItems, :UsingTheseItems ]) 

				return This.SplitAtItemsCSZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtSection, :AtThisSection ]) 
				return This.SplitAtSectionZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AtSections, :AtTheseSections ]) 
				return This.SplitAtSectionsZ(pItem[2])

			#-- SPLITTING BEFORE

			but oParam.IsBeforeNamedParam()
				return This.SplitBeforeCSZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforePosition, :BeforeThisPosition ]) 
				return This.SplitBeforePositionZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :BeforePositions, :BeforeThesePositions ]) 
				return This.SplitBeforePositionsZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :BeforeItem, :BeforeThisItem ]) 
				return This.SplitBeforeItemCSZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeItems, :BeforeTheseItems ]) 
				return This.SplitBeforeItemsCSZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforeSection, :BeforeThisSection ]) 
				return This.SplitBeforeSectionZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeSections, :BeforeTheseSections ]) 
				return This.SplitBeforeSectionsZ(pItem[2])

			#-- SPLITTING AFTER

			but oParam.IsAfterNamedParam()
				return This.SplitAfterCSZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterPosition, :AfterThisPosition ]) 
				return This.SplitAfterPositionZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AfterPositions, :AfterThesePositions ]) 
				return This.SplitAfterPositionsZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :AfterItem, :AfterThisItem ]) 
				return This.SplitAfterItemCSZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :AfterItems, :AfterTheseItems ]) 
				return This.SplitAfterItemsCSZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterSection, :AfterThisSection ]) 
				return This.SplitAfterSectionZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AfterSections, :AfterTheseSections ]) 
				return This.SplitAfterSectionsZ(pItem[2])

			# SPLITTING BETWEEN

			but oParam.IsBetweenNamedParam() and
				isList(pItem) and len(pItem) = 2
				
				if isList(pItem[2]) and Q(pItem[2]).IsAndNamedParam()
					pItem[2] = pItem[2][2]
				ok

				return This.SplitBetweenCSZ(pItem[1], pItem[2], pCaseSensitive)

			but oParam.IsBetweenPositionsNamedParam()
				return This.SplitBetweenPositionsZ(pItem[1], pItem[2])

			but oParam.IsBetweenItemsNamedParam()
				return This.SplitBetweenItemsCSZ(pItem[1], pItem[2], pCaseSensitive)

			# SPLITTING TO PARTS

			but oParam.IsToNPartsNamedParam()
				return This.SplitToNPartsZ(pItem[2])

			but oParam.IsToPartsOfNItemsNamedParam()
				return This.SplitToPartsOfNItemsZ(pItem[2])

			# SPLITTING WHERE

			but oParam.IsWhereOrAtWhereNamedParam()
				return This.SplitAtWZ(pItem[2])

			but oParam.IsBeforeWhereNamedParam()
				return This.SplitBeforeWZ(pItem[2])

			but oParam.IsAfterWhereNamedParam()
				return This.SplitAfterWZ(pItem[2])

			else
				return This.SplitAtItemCSZ(pItem, pCaseSensitive)

			ok
		ok

		#< @FunctionFluentForm

		def SplitCSXTZQ(pItem, pCaseSensitive)
			return This.SplitCSXTZQR(pItem, pCaseSensitive, :stzList)

		def SplitCSXTZQR(pItem, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
				on :stzList
					return new stzList( This.SplitCSXTZ(pItem, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitCSXTZ(pItem, pCaseSensitive) )
	
				on :stzListOfItems
					return new stzListOfItems( This.SplitCSXTZ(pItem, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SplitCSXTZ(pItem, pCaseSensitive) )
	
				on :stzListOfObjects
					return new stzListOfObjects( This.SplitCSXTZ(pItem, pCaseSensitive) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitCSXTZ(pItem, pCaseSensitive) )
	
				on :stzListOfPairs
					return new stzListOfpairs( This.SplitCSXTZ(pItem, pCaseSensitive) )
	
				on :stzListOfSets
					return new stzListOfSets( This.SplitCSXTZ(pItem, pCaseSensitive) )
	
				on :stzListOfHashLists
					return new stzListOfHashLists( This.SplitCSXTZ(pItem, pCaseSensitive) )
	
				on :stzListOfGrids
					return new stzListOfGrids( This.SplitCSXTZ(pItem, pCaseSensitive) )
	
				on :stzListOfTables
					return new stzListOfTables( This.SplitCSXTZ(pItem, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off

		#>

	def SplittedCSXTZ(pItem, pCaseSensitive)
		return This.SplitCSXTZ(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitXTZ(pItem)
		return This.SplitCSXTZ(pItem, TRUE)

		def SplitXTZQ(pItem)
			return This.SplitXTZQR(pItem, :stzlist)

		def SplitXTZQR(pItem, pcReturnType)
			return This.SplitCSXTZQR(pItem, TRUE, pcReturnType)

	def SplittedXTZ(pItem)
		return This.SplitXTZ(pItem)

	  #---------------------------------------#
	 #  SPLITTING THE LIST -- XTZZ/EXTENDED  #
	#---------------------------------------#

	def SplitCSXTZZ(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isList(pItem)
			return This.SplitAtItemCSZZ(pItem, pCaseSensitive)

		else

			oParam = Q(pItem)

			#-- SPLITTING AT / USING

			if oParam.IsOneOfTheseNamedParams([ :At, :Using ])
				return This.SplitAtCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtPosition, :AtThisPosition ]) 
				return This.SplitAtPositionZZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AtPositions, :AtThesePositions ]) 
				return This.SplitAtPositionsZZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([
						:AtItem, :AtThisItem,
						:UsingItem, :UsingThisItem ]) 

				return This.SplitAtItemCSZZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([
						:AtItems, :AtTheseItems,
						:UsingItems, :UsingTheseItems ]) 

				return This.SplitAtItemsCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtSection, :AtThisSection ]) 
				return This.SplitAtSectionZZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AtSections, :AtTheseSections ]) 
				return This.SplitAtSectionsZZ(pItem[2])

			#-- SPLITTING BEFORE

			but oParam.IsBeforeNamedParam()
				return This.SplitBeforeCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforePosition, :BeforeThisPosition ]) 
				return This.SplitBeforePositionZZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :BeforePositions, :BeforeThesePositions ]) 
				return This.SplitBeforePositionsZZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :BeforeItem, :BeforeThisItem ]) 
				return This.SplitBeforeItemCSZZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeItems, :BeforeTheseItems ]) 
				return This.SplitBeforeItemsCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforeSection, :BeforeThisSection ]) 
				return This.SplitBeforeSectionZZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeSections, :BeforeTheseSections ]) 
				return This.SplitBeforeSectionsZZ(pItem[2])

			#-- SPLITTING AFTER

			but oParam.IsAfterNamedParam()
				return This.SplitAfterCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterPosition, :AfterThisPosition ]) 
				return This.SplitAfterPositionZZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AfterPositions, :AfterThesePositions ]) 
				return This.SplitAfterPositionsZZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :AfterItem, :AfterThisItem ]) 
				return This.SplitAfterItemCSZZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :AfterItems, :AfterTheseItems ]) 
				return This.SplitAfterItemsCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterSection, :AfterThisSection ]) 
				return This.SplitAfterSectionZZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AfterSections, :AfterTheseSections ]) 
				return This.SplitAfterSectionsZZ(pItem[2])

			# SPLITTING BETWEEN

			but oParam.IsBetweenNamedParam() and
				isList(pItem) and len(pItem) = 2
				
				if isList(pItem[2]) and Q(pItem[2]).IsAndNamedParam()
					pItem[2] = pItem[2][2]
				ok

				return This.SplitBetweenCSZZ(pItem[1], pItem[2], pCaseSensitive)

			but oParam.IsBetweenPositionsNamedParam()
				return This.SplitBetweenPositionsZZ(pItem[1], pItem[2])

			but oParam.IsBetweenItemsNamedParam()
				return This.SplitBetweenItemsCSZZ(pItem[1], pItem[2], pCaseSensitive)

			# SPLITTING TO PARTS

			but oParam.IsToNPartsNamedParam()
				return This.SplitToNPartsZZ(pItem[2])

			but oParam.IsToPartsOfNItemsNamedParam()
				return This.SplitToPartsOfNItemsZZ(pItem[2])

			# SPLITTING WHERE

			but oParam.IsWhereOrAtWhereNamedParam()
				return This.SplitAtWZZ(pItem[2])

			but oParam.IsBeforeWhereNamedParam()
				return This.SplitBeforeWZZ(pItem[2])

			but oParam.IsAfterWhereNamedParam()
				return This.SplitAfterWZZ(pItem[2])

			else
				return This.SplitAtItemCSZZ(pItem, pCaseSensitive)

			ok
		ok

		#< @FunctionFluentForm

		def SplitCSXTZZQ(pItem, pCaseSensitive)
			return This.SplitCSXTZZQR(pItem, pCaseSensitive, :stzList)

		def SplitCSXTZZQR(pItem, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
				on :stzList
					return new stzList( This.SplitCSXTZZ(pItem, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitCSXTZZ(pItem, pCaseSensitive) )
	
				on :stzListOfItems
					return new stzListOfItems( This.SplitCSXTZZ(pItem, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SplitCSXTZZ(pItem, pCaseSensitive) )
	
				on :stzListOfObjects
					return new stzListOfObjects( This.SplitCSXTZZ(pItem, pCaseSensitive) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitCSXTZZ(pItem, pCaseSensitive) )
	
				on :stzListOfPairs
					return new stzListOfpairs( This.SplitCSXTZZ(pItem, pCaseSensitive) )
	
				on :stzListOfSets
					return new stzListOfSets( This.SplitCSXTZZ(pItem, pCaseSensitive) )
	
				on :stzListOfHashLists
					return new stzListOfHashLists( This.SplitCSXTZZ(pItem, pCaseSensitive) )
	
				on :stzListOfGrids
					return new stzListOfGrids( This.SplitCSXTZZ(pItem, pCaseSensitive) )
	
				on :stzListOfTables
					return new stzListOfTables( This.SplitCSXTZZ(pItem, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off

		#>

	def SplittedCSXTZZ(pItem, pCaseSensitive)
		return This.SplitCSXTZZ(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitXTZZ(pItem)
		return This.SplitCSXTZZ(pItem, TRUE)

		def SplitXTZZQ(pItem)
			return This.SplitXTZZQR(pItem, :stzlist)

		def SplitXTZZQR(pItem, pcReturnType)
			return This.SplitCSXTZZQR(pItem, TRUE, pcReturnType)

	def SplittedXTZZ(pItem)
		return This.SplitXTZZ(pItem)

	  #------------------------------#
	 #   SPLITTING AT A GIVEN Item  #
	#==============================#

	def SplitAtCS(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isList(pItem)
			return This.SplitAtItemCS(pItem, pCaseSensitive)

		else

			oParam = Q(pItem)

			if oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.SplitAtPosition(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.SplitAtPositions(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.SplitAtItemCS(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.SplitAtItemsCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.SplitAtSection(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.SplitAtSections(pItem[2])

			else
				return This.SplitAtItemCS(pItem, pCaseSensitive)

			ok
		ok

		#< @FunctionFluentForm

		def SplitCSQ(pItem, pCaseSensitive)
			return This.SplitCSQR(pItem, pCaseSensitive, :stzList)

		def SplitCSQR(pItem, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
				on :stzList
					return new stzList( This.SplitCS(pItem, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitCS(pItem, pCaseSensitive) )
	
				on :stzListOfItems
					return new stzListOfItems( This.SplitCS(pItem, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SplitCS(pItem, pCaseSensitive) )
	
				on :stzListOfObjects
					return new stzListOfObjects( This.SplitCS(pItem, pCaseSensitive) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitCS(pItem, pCaseSensitive) )
	
				on :stzListOfPairs
					return new stzListOfpairs( This.SplitCS(pItem, pCaseSensitive) )
	
				on :stzListOfSets
					return new stzListOfSets( This.SplitCS(pItem, pCaseSensitive) )
	
				on :stzListOfHashLists
					return new stzListOfHashLists( This.SplitCS(pItem, pCaseSensitive) )
	
				on :stzListOfGrids
					return new stzListOfGrids( This.SplitCS(pItem, pCaseSensitive) )
	
				on :stzListOfTables
					return new stzListOfTables( This.SplitCS(pItem, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off


		#>

	def SplittedAtCS(pItem, pCaseSensitive)
		return This.SplitAtCS(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitAt(pItem)
		return This.SplitAtCS(pItem, TRUE)

		def SplitAtQ(pItem)
			return This.SplitAtQR(pItem, :stzList)

		def SplitAtQR(pItem, pcReturnType)
			return This.SplitAtCSQR(pItem, TRUE, pcReturnType)

	def SplittedAt(pItem)
		return This.SplitAt(pItem)

	  #-----------------------------------#
	 #   SPLITTING AT A GIVEN POSITION   #
	#===================================#

	def SplitAtPosition(n)
		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect pram type! n must be a number.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAtPosition(n)
		aResult = This.Sections(aSections)

		return aResult

		#< @FunctionFluentForm

		def SplitAtPositionQ(pItem, pCaseSensitive)
			return This.SplitAtPositionQR(pItem, pCaseSensitive, :stzList)

		def SplitAtPositionQR(pItem, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
				on :stzList
					return new stzList( This.SplitAtPosition(n) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitAtPosition(n) )
	
				on :stzListOfItems
					return new stzListOfItems( This.SplitAtPosition(n) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SplitAtPosition(n) )
	
				on :stzListOfObjects
					return new stzListOfObjects( This.SplitAtPosition(n) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitAtPosition(n) )
	
				on :stzListOfPairs
					return new stzListOfpairs( This.SplitAtPosition(n) )
	
				on :stzListOfSets
					return new stzListOfSets( This.SplitAtPosition(n) )
	
				on :stzListOfHashLists
					return new stzListOfHashLists( This.SplitAtPosition(n) )
	
				on :stzListOfGrids
					return new stzListOfGrids( This.SplitAtPosition(n) )
	
				on :stzListOfTables
					return new stzListOfTables( This.SplitAtPosition(n) )
	
				other
					StzRaise("Unsupported param type!")
				off

		#>

		#< @FunctionAlternativeForm

		def SplitAtThisPosition(n)
			return This.SplitAtPosition(n)

			def SplitAtThisPositionQ(n)
				return This.SplitAtThisPositionQR(n, :stzList)

			def SplitAtThisPositionQR(n, pcReturnType)
				return This.SplitAtPositionQR(n, pcReturnType)

		#>

	def SplittedAtPosition(n)
		return This.SplitAtPositions(n)

		def SplittedAtThisPosition(n)
			return This.SplitAtPositions(n)

	  #---------------------------------#
	 #   SPLITTING AT MANY POSITIONS   #
	#---------------------------------#

	def SplitAtPositions(anPos)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aSections = StzSplitterQ(This.NumberOfItems()).SplitAtPositions(anPos)
		aResult = This.Sections(aSections)

		return aResult

		#< @FunctionFluentForm

		def SplitAtPositionsQ(pItem, pCaseSensitive)
			return This.SplitAtPositions(anPos)QR(pItem, pCaseSensitive, :stzList)

		def SplitAtPositionsQR(pItem, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
				on :stzList
					return new stzList( This.SplitAtPositions(anPos) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitAtPositions(anPos) )
	
				on :stzListOfItems
					return new stzListOfItems( This.SplitAtPositions(anPos) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SplitAtPositions(anPos) )
	
				on :stzListOfObjects
					return new stzListOfObjects( This.SplitAtPositions(anPos) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitAtPositions(anPos) )
	
				on :stzListOfPairs
					return new stzListOfpairs( This.SplitAtPositions(anPos) )
	
				on :stzListOfSets
					return new stzListOfSets( This.SplitAtPositions(anPos) )
	
				on :stzListOfHashLists
					return new stzListOfHashLists( This.SplitAtPositions(anPos) )
	
				on :stzListOfGrids
					return new stzListOfGrids( This.SplitAtPositions(anPos) )
	
				on :stzListOfTables
					return new stzListOfTables( This.SplitAtPositions(anPos) )
	
				other
					StzRaise("Unsupported param type!")
				off


		#>

		#< @FunctionAlternativeForms

		def SplitAtThesePositions(anPos)
			return This.SplitAtPositions(anPos)

			def SplitAtThesePositionsQ(anPos)
				return This.SplitAtThesePositionsQR(anPos, :stzList)
	
			def SplitAtThesePositionsQR(anPos, pcReturnType)
				return This.SplitAtPositionsQR(anPos, pcReturnType)

		def SplitAtManyPositions(anPos)
			return This.SplitAtPositions(anPos)

			def SplitAtManyPositionsQ(anPos)
				return This.SplitAtManyPositionsQR(anPos, :stzList)
	
			def SplitAtManyPositionsQR(anPos, pcReturnType)
				return This.SplitAtPositionsQR(anPos, pcReturnType)

		#>

	def SplittedAtPositions(anPos)
		return This.SplitAtPositions(anPos)

		#< @FunctionAlternativeForms

		def SplittedAtThesePositions(anPos)
			return This.SplitAtPositions(anPos)

		def SplittedAtManyPositions(anPos)
			return This.SplitAtPositions(anPos)

		#>

	  #------------------------------------#
	 #   SPLITTING AT A GIVEN Item   #
	#====================================#

	def SplitAtItemCS(pItem, pCaseSensitive)
		anPos = This.FindCS(pItem, pCaseSensitive)
		aSections = StzSplitterQ(This.NumberOfItems()).SplitAtPositions(anPos)
		aResult = This.Sections(aSections)

		return aResult

		#< @FunctionFluentForm

		def SplitAtItemCSQ(pItem, pCaseSensitive)
			return This.SplitAtItemCSQR(pItem, pCaseSensitive, :stzList)

		def SplitAtItemCSQR(pItem, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
				on :stzList
					return new stzList( This.SplitAtItemCS(pItem, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitAtItemCS(pItem, pCaseSensitive) )
	
				on :stzListOfItems
					return new stzListOfItems( This.SplitAtItemCS(pItem, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SplitAtItemCS(pItem, pCaseSensitive) )
	
				on :stzListOfObjects
					return new stzListOfObjects( This.SplitAtItemCS(pItem, pCaseSensitive) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitAtItemCS(pItem, pCaseSensitive) )
	
				on :stzListOfPairs
					return new stzListOfpairs( This.SplitAtItemCS(pItem, pCaseSensitive) )
	
				on :stzListOfSets
					return new stzListOfSets( This.SplitAtItemCS(pItem, pCaseSensitive) )
	
				on :stzListOfHashLists
					return new stzListOfHashLists( This.SplitAtItemCS(pItem, pCaseSensitive) )
	
				on :stzListOfGrids
					return new stzListOfGrids( This.SplitAtItemCS(pItem, pCaseSensitive) )
	
				on :stzListOfTables
					return new stzListOfTables( This.SplitAtItemCS(pItem, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off

		#>

		#< @FunctionAlternativeForms

		def SplitsAtItemCS(pItem, pCaseSensitive)
			return This.SplitAtItemCS(pItem, pCaseSensitive)

			def SplitsAtItemCSQ(pItem, pCaseSensitive)
				return This.SplitAtItemCSQ(pItem, pCaseSensitive)

			def SplitsAtItemCSQR(pItem, pCaseSensitive, pcReturnType)
				return This.SplitAtItemCSQR(pItem, pCaseSensitive, pcReturnType)

		def SplitAtThisItemCS(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.SplitAtItemCS(pItem, pCaseSensitive)

			def SplitAtThisItemCSQ(pItem, pCaseSensitive)
				return This.AtThisItemCSQR(pItem, pCaseSensitive, :stzList)
	
			def SplitAtThisItemCSQR(pItem, pCaseSensitive, pcReturnType)
				return This.SplitAtItemCSQR(pItem, pCaseSensitive, pcReturnType)

		def SplitsAtThisItemCS(pItem, pCaseSensitive)
			return This.SplitAtThisItemCS(pItem, pCaseSensitive)

			def SplitsAtThisItemCSQ(pItem, pCaseSensitive)
				return This.SplitAtThisItemCSQR(pItem, pCaseSensitive, :stzList)
	
			def SplitsAtThisItemCSQR(pItem, pCaseSensitive, pcReturnType)
				return This.SplitAtItemCSQR(pItem, pCaseSensitive, pcReturnType)

		#>

	def SplittedAtItemCS(pItem, pCaseSensitive)
		return This.SplitAtItemCS(pItem, pCaseSensitive)

		def SplittedAtThisItemCS(pItem, pCaseSensitive)
			return This.SplittedAtItemCS(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitAtItem(pItem)
		return This.SplitAtItemCS(pItem, TRUE)

		#< @FunctionFluentForm

		def SplitAtItemQ(pItem)
			return This.SplitAtItemQR(pItem, :stzList)

		def SplitAtItemQR(pItem, pcReturnType)
			return This.SplitAtItemCSQR(pItem, TRUE, pcReturnType)

		#>

		#< @FunctionAlternativeForms

		def SplitsAtItem(pItem)
			return This.SplitAtItem(pItem)

			def SplitsAtItemQ(pItem)
				return This.SplitAtItemQ(pItem)

			def SplitsAtItemQR(pItem, pcReturnType)
				return This.SplitAtItemQR(pItem, pcReturnType)

		def SplitAtThisItem(pItem)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.SplitAtItem(pItem)

			def SplitAtThisItemQ(pItem)
				return This.SplitAtThisItemQR(pItem, :stzList)
	
			def SplitAtThisItemQR(pItem, pcReturnType)
				return This.SplitAtItemCSQR(pItem, pcReturnType)

		def SplitsAtThisItem(pItem)
			return This.SplitAtThisItem(pItem)

			def SplitsAtThisItemQ(pItem)
				return This.SplitAtThisItemQ(pItem)

			def SplitsAtThisItemQR(pItem, pcReturnType)
				return This.SplitAtThisItemQ(pItem, pcReturnType)

		#>

	def SplittedAtItem(pItem)
		return This.SplitAtItem(pItem)

		def SplittedAtThisItem(pItem)
			return This.SplittedAtItem(pItem)

	  #---------------------------------------------#
	 #  SPLITS AT A Item AND THEIR POSITIONS  #
	#---------------------------------------------#

	#TODO
	# Check it for performance

	def SplitAtItemCSZ(pItem, pCaseSensitive)
		acSplits = This.SplitAtItemCS(pItem, pCaseSensitive)
		anPos = This.FindSplitsAtItemCS(pItem, pCaseSensitive)

		aResult = Association([ acSplits, anPos ])
		return aResult

		#< @FunctionAlternativeForms


		def SplitsAtItemCSZ(pItem, pCaseSensitive)
			return This.SplitAtItemCSZ(pItem, pCaseSensitive)

		def SplitAtThisItemCSZ(pItem, pCaseSensitive)
			return This.SplitAtItemCSZ(pItem, pCaseSensitive)

		def SplitsAtThisItemCSZ(pItem, pCaseSensitive)
			return This.SplitAtItemCSZ(pItem, pCaseSensitive)

		#--

		def SplitCSZ(pItem, pCaseSensitive)
			acSplits = This.SplitAtCS(pItem, pCaseSensitive)
			anPos = FindSplitsAtCS(pItem, pCaseSensitive)

			aResult = Association([ acSplits, anPos ])
			return aResult
	
		def SplitsCSZ(pItem, pCaseSensitive)
			return This.SplitCSZ(pItem, pCaseSensitive)

		#>

	def SplittedAtItemCSZ(pItem, pCaseSensitive)
		return This.SplitAtItemCSZ(pItem, pCaseSensitive)

		def SplittedAtThisItemCSZ(pItem, pCaseSensitive)
			return This.SplittedAtItemCSZ(pItem, pCaseSensitive)

		def SplittedCSZ(pItem, pCaseSensitive)
			return This.SPlitCSZ(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitAtItemZ(pItem)
		return This.SplitAtItemCSZ(pItem, TRUE)

		#< @FunctionAlternativeForms

		def SplitsAtItemZ(pItem)
			return This.SplitAtItemZ(pItem)

		def SplitAtThisItemZ(pItem)
			return This.SplitAtItemZ(pItem)

		def SplitsAtThisItemZ(pItem)
			return This.SplitAtItemZ(pItem)

		#--

		def SplitZ(pItem)
			acSplits = This.SplitAt(pItem)
			anPos = FindSplitsAt(pItem)

			aResult = Association([ acSplits, anPos ])
			return aResult
	
		def SplitsZ(pItem)
			return This.SplitZ(pItem)

		#>

	def SplittedAtItemZ(pItem)
		return This.SplitAtItemZ(pItem)

		def SplittedAtThisItemZ(pItem)
			return This.SplittedAtItemZ(pItem)

		def SplittedZ(pItem)
			return This.SplitZ(pItem)

	  #--------------------------------------------#
	 #  SPLITS AT A Item AND THEIR SECTIONS  #
	#--------------------------------------------#

	#TODO
	# Check it for performance

	def SplitAtItemCSZZ(pItem, pCaseSensitive)
		acSplits  = This.SplitAtItemCS(pItem, pCaseSensitive)
		aSections = FindSplitsAtItemCSZZ(pItem, pCaseSensitive)

		aResult = Association([ acSplits, aSections ])
		return aResult

		#< @FunctionAlternativeForms


		def SplitsAtItemCSZZ(pItem, pCaseSensitive)
			return This.SplitAtItemCSZZ(pItem, pCaseSensitive)

		def SplitAtThisItemCSZZ(pItem, pCaseSensitive)
			return This.SplitAtItemCSZZ(pItem, pCaseSensitive)

		def SplitsAtThisItemCSZZ(pItem, pCaseSensitive)
			return This.SplitAtItemCSZZ(pItem, pCaseSensitive)

		#>

	def SplittedAtItemCSZZ(pItem, pCaseSensitive)
		return This.SplitAtItemCSZZ(pItem, pCaseSensitive)

		def SplittedAtThisItemCSZZ(pItem, pCaseSensitive)
			return This.SplittedAtItemCSZZ(pItem, pCaseSensitive)

		def SplittedCSZZ(pItem, pCaseSensitive)
			return This.SplitCSZZ(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitAtItemZZ(pItem)
		return This.SplitAtItemCSZZ(pItem, TRUE)

		#< @FunctionAlternativeForms

		def SplitsAtItemZZ(pItem)
			return This.SplitAtItemZZ(pItem)

		def SplitAtThisItemZZ(pItem)
			return This.SplitAtItemZZ(pItem)

		def SplitsAtThisItemZZ(pItem)
			return This.SplitAtItemZZ(pItem)

		#>

	def SplittedAtItemZZ(pItem)
		return This.SplitAtItemZZ(pItem)

		def SplittedAtThisItemZZ(pItem)
			return This.SplittedAtItemZZ(pItem)

		def SplittedZZ(pItem)
			return This.SplitZZ(pItem)

	  #----------------------------------#
	 #   SPLITTING AT MANY Items   #
	#==================================#

	def SplitAtItemsCS(paItems, pCaseSensitive)
		if CheckParams()
			if This.IsEmpty()
				return []
			ok
		ok

		anPos = This.FindManyCS(paItems, pCaseSensitive)
		aResult = This.SplitAtPositions(anPos)

		return aResult

		#< @FunctionFluentForms

		def SplitAtItemsCSQ(paItems, pCaseSensitive)
			return This.SplitAtItemsCSQR(paItems, pCaseSensitive, :stzList)

		def SplitAtItemsCSQR(paItems, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
				on :stzList
					return new stzList( This.SplitAtItemsCS(paItems, pCaseSensitive) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitAtItemsCS(paItems, pCaseSensitive) )
	
				on :stzListOfItems
					return new stzListOfItems( This.SplitAtItemsCS(paItems, pCaseSensitive) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SplitAtItemsCS(paItems, pCaseSensitive) )
	
				on :stzListOfObjects
					return new stzListOfObjects( This.SplitAtItemsCS(paItems, pCaseSensitive) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitAtItemsCS(paItems, pCaseSensitive) )
	
				on :stzListOfPairs
					return new stzListOfpairs( This.SplitAtItemsCS(paItems, pCaseSensitive) )
	
				on :stzListOfSets
					return new stzListOfSets( This.SplitAtItemsCS(paItems, pCaseSensitive) )
	
				on :stzListOfHashLists
					return new stzListOfHashLists( This.SplitAtItemsCS(paItems, pCaseSensitive) )
	
				on :stzListOfGrids
					return new stzListOfGrids( This.SplitAtItemsCS(paItems, pCaseSensitive) )
	
				on :stzListOfTables
					return new stzListOfTables( This.SplitAtItemsCS(paItems, pCaseSensitive) )
	
				other
					StzRaise("Unsupported param type!")
				off

		#>

		#< @FunctionAlternativeForms

		def SplitAtTheseItemsCS(paItems, pCaseSensitive)
			return This.SplitAtItemsCS(paItems, pCaseSensitive)

			def SplitAtTheseItemsCSQ(paItems, pCaseSensitive)
				return This.SplitAtTheseItemsCSQR(paItems, pCaseSensitive, :stzList)
	
			def SplitAtTheseItemsCSQR(paItems, pCaseSensitive, pcReturnType)
				return This.SplitAtItemsCSQR(paItems, pCaseSensitive, pcReturnType)

		def SplitAtManyItemsCS(paItems, pCaseSensitive)
			return This.SplitAtItemsCS(paItems, pCaseSensitive)

			def SplitAtManyItemsCSQ(paItems, pCaseSensitive)
				return This.SplitAtManyItemsCSQR(paItems, pCaseSensitive, :stzList)
	
			def SplitAtManyItemsCSQR(paItems, pCaseSensitive, pcReturnType)
				return This.SplitAtItemsCSQR(paItems, pCaseSensitive, pcReturnType)

		#>

	def SplittedAtItemsCS(paItems, pCaseSensitive)
		return This.SplitAtItemsCS(paItems, pCaseSensitive)

		#< @FunctionAlternativeForms

		def SplittedAtTheseItemsCS(paItems, pCaseSensitive)
			return This.SplitAtItemsCS(paItems, pCaseSensitive)

		def SplittedAtManyItemsCS(paItems, pCaseSensitive)
			return This.SplitAtItemsCS(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def SplitAtItems(paItems)
		return This.SplitAtItemsCS(paItems, TRUE)

		#< @FunctionFluentForm

		def SplitAtItemsQ(paItems)
			return This.SplitAtItemsQR(paItems, pCaseSensitive, :stzList)

		def SplitAtItemsQR(paItems, pcReturnType)
			return This.SplitAtItemsCSQR(paItems, TRUE, pcReturnType)

		#>

		#< @FunctionAlternativeForms

		def SplitAtTheseItems(paItems)
			return This.SplitAtItems(paItems)

			def SplitAtTheseItemsQ(paItems)
				return This.SplitAtTheseItemsQR(paItems, :stzList)
	
			def SplitAtTheseItemsQR(paItems, pcReturnType)
				return This.SplitAtItemsCSQR(paItems, TRUE, pcReturnType)
	
		def SplitAtManyItems(paItems)
			return This.SplitAtItems(paItems)

			def SplitAtManyItemsQ(paItems)
				return This.SplitAtManyItemsQR(paItems, pCaseSensitive, :stzList)
	
			def SplitAtManyItemsQR(paItems, pcReturnType)
				return This.SplitAtItemsCSQR(pItem, TRUE, pcReturnType)

		#>

	def SplittedAtItems(paItems)
		return This.SplitAtItems(paItems)

		#< @FunctionAlternativeForms

		def SplittedAtTheseItems(paItems)
			return This.SplitAtItems(paItems)

		def SplittedAtManyItems(paItems)
			return This.SplitAtItems(paItems)

		#>

	  #----------------------------------#
	 #   SPLITTING AT A GIVEN SECTION   #
	#==================================#

	def SplitAtSection(n1, n2)
		if This.IsEmpty()
			return []
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAtSection(n1, n2)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForm

		def SplitAtSectionQ(n1, n2)
			return This.SplitAtSectionQR(n1, n2, :stzList)

		def SplitAtSectionQR(n1, n2, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
				on :stzList
					return new stzList( This.SplitAtSection(n1, n2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitAtSection(n1, n2) )
	
				on :stzListOfItems
					return new stzListOfItems( This.SplitAtSection(n1, n2) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SplitAtSection(n1, n2) )
	
				on :stzListOfObjects
					return new stzListOfObjects( This.SplitAtSection(n1, n2) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitAtSection(n1, n2) )
	
				on :stzListOfPairs
					return new stzListOfpairs( This.SplitAtSection(n1, n2) )
	
				on :stzListOfSets
					return new stzListOfSets( This.SplitAtSection(n1, n2) )
	
				on :stzListOfHashLists
					return new stzListOfHashLists( This.SplitAtSection(n1, n2) )
	
				on :stzListOfGrids
					return new stzListOfGrids( This.SplitAtSection(n1, n2) )
	
				on :stzListOfTables
					return new stzListOfTables( This.SplitAtSection(n1, n2) )
	
				other
					StzRaise("Unsupported param type!")
				off

		#>


		#< @FunctionAlternativeForm

		def SplitAtThisSection(n1, n2)
			return This.SplitAtSection(n1, n2)

			def SplitAtThisSectionQ(n1, n2)
				return This.SplitAtThisSectionQR(n1, n2, :stzList)

			def SplitAtThisSectionQR(n1, n2, pcReturnType)
				return This.SplitAtSectionQR(n1, n2, pcReturnType)

		#>


	def SplittedAtSection(n1, n2)
		return This.SplitAtSection(n1, n2)

		def SplittedAtThisSection(n1, n2)
			return This.SplittedAtSection(n1, n2)

	  #-----------------------------------------------------#
	 #   SPLITTING AT A GIVEN SECTION -- INCLUDING BOUNDS  #
	#-----------------------------------------------------#

	def SplitAtSectionIB(n1, n2)
		if This.IsEmpty()
			return []
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAtSectionIB(n1, n2)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForm

		def SplitAtSectionIBQ(n1, n2)
			return This.SplitAtSectionIBQR(n1, n2, :stzList)

		def SplitAtSectionIBQR(n1, n2, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
				on :stzList
					return new stzList( This.SplitAtSectionIB(n1, n2) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitAtSectionIB(n1, n2) )
	
				on :stzListOfItems
					return new stzListOfItems( This.SplitAtSectionIB(n1, n2) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SplitAtSectionIB(n1, n2) )
	
				on :stzListOfObjects
					return new stzListOfObjects( This.SplitAtSectionIB(n1, n2) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitAtSectionIB(n1, n2) )
	
				on :stzListOfPairs
					return new stzListOfpairs( This.SplitAtSectionIB(n1, n2) )
	
				on :stzListOfSets
					return new stzListOfSets( This.SplitAtSectionIB(n1, n2) )
	
				on :stzListOfHashLists
					return new stzListOfHashLists( This.SplitAtSectionIB(n1, n2) )
	
				on :stzListOfGrids
					return new stzListOfGrids( This.SplitAtSectionIB(n1, n2) )
	
				on :stzListOfTables
					return new stzListOfTables( This.SplitAtSectionIB(n1, n2) )
	
				other
					StzRaise("Unsupported param type!")
				off

		#>

		#< @FunctionAlternativeForm

		def SplitAtThisSectionIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

			def SplitAtThisSectionIBQ(n1, n2)
				return This.SplitAtThisSectionIBQR(n1, n2, :stzList)

			def SplitAtThisSectionIBQR(n1, n2, pcReturnType)
				return This.SplitAtSectionIBQR(n1, n2, pcReturnType)

		#>

	def SplittedAtSectionIB(n1, n2)
		return This.SplitAtSectionIB(n1, n2)

		def SplittedAtThisSectionIB(n1, n2)
			return This.SplittedAtSectionIB(n1, n2)

	  #--------------------------------#
	 #   SPLITTING AT MANY SECTIONS   #
	#--------------------------------#

	def SplitAtSections(paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAtSections(paSections)
		aResult = This.AntiSections( paSections )

		return aResult

		#< @FunctionFluentForm

		def SplitAtSectionsQ(paSections)
			return This.SplitAtSectionsQR(pItem, :stzList)

		def SplitAtSectionsQR(paSections, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
				on :stzList
					return new stzList( This.SplitAtSections(paSections) )
	
				on :stzListOfStrings
					return new stzListOfStrings( This.SplitAtSections(paSections) )
	
				on :stzListOfItems
					return new stzListOfItems( This.SplitAtSections(paSections) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SplitAtSections(paSections) )
	
				on :stzListOfObjects
					return new stzListOfObjects( This.SplitAtSections(paSections) )
	
				on :stzListOfLists
					return new stzListOfLists( This.SplitAtSections(paSections) )
	
				on :stzListOfPairs
					return new stzListOfpairs( This.SplitAtSections(paSections) )
	
				on :stzListOfSets
					return new stzListOfSets( This.SplitAtSections(paSections) )
	
				on :stzListOfHashLists
					return new stzListOfHashLists( This.SplitAtSections(paSections) )
	
				on :stzListOfGrids
					return new stzListOfGrids( This.SplitAtSections(paSections) )
	
				on :stzListOfTables
					return new stzListOfTables( This.SplitAtSections(paSections) )
	
				other
					StzRaise("Unsupported param type!")
				off

		#>


		#< @FunctionAlternativeForms

		def SplitAtTheseSections(paSections)
			return This.SplitAtSections(paSections)

			def SplitAtTheseSectionsQ(paSections)
				return This.SplitAtTheseSectionsQR(paSections, :stzList)

			def SplitAtTheseSectionsQR(paSections, pcReturnType)
				return This.SplitAtSectionsQR(paSections, pcReturnType)

		#>

	def SplittedAtSections(paSections)
		return This.SplitAtSections(paSections)

		def SplittedAtTheseSections(paSections)
			return This.SplittedAtSections(paSections)

	  #---------------------------------------------------#
	 #   SPLITTING AT MANY SECTIONS -- INCLUDING BOUNDS  #
	#---------------------------------------------------#

	def SplitAtSectionsIB(paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAtSectionsIB(paSections)
		aResult = This.AntiSections( paSections )

		return aResult

		#< @FunctionFluentForms

		def SplitAtSectionsIBQ(n1, n2)
			return This.SplitAtSectionsIBQR(n1, n2, pcReturnType)

		def SplitAtSectionsIBQR(n1, n2, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAtSectionsIB(n1, n2) )
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAtSectionsIB(n1, n2) )
			on :stzListOfItems
				return new stzListOfItems( This.SplitAtSectionsIB(n1, n2) )
			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def SplitAtTheseSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

			def SplitAtTheseSectionsIBQ(paSections)
				return This.SplitAtTheseSectionsIBQR(paSections, :stzList)

			def SplitAtTheseSectionsIBQR(paSections, pcReturnType)
				return This.SplitAtSectionsIBQR(paSections, pcReturnType)

		#>

	def SplittedAtSectionsIB(paSections)
		return This.SplitAtSections(paSections)

		def SplittedAtTheseSectionsIB(paSections)
			return This.SplittedAtSections(paSections)

	  #----------------------------------------------------#
	 #   SPLITTING BEFORE A GIVEN ITEM   #
	#----------------------------------------------------#

	def SplitBeforeCS(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isList(pItem)
			return This.SplitBeforeItemCS(pItem, pCaseSensitive)

		else

			#-- Case when named params are provided

			if Q(pItem).IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.SplitBeforePosition(pItem[2])
	
			but Q(pItem).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.SplitBeforePositions(pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.SplitBeforeItemCS(pItem[2], pCaseSensitive)
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.SplitBeforeItemsCS(pItem[2], pCaseSensitive)

			but Q(pItem).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.SplitBeforeSection(pItem[2])
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.SplitBeforeSections(pItem[2])

			else
				return This.SplitBeforeItemCS(pItem, pCaseSensitive)
			ok
		ok

		#< @FunctionFluentForms

		def SplitBeforeCSQ(pItem, pCaseSensitive)
			return This.SplitBeforeCSQR(pItem, pCaseSensitive, :stzList)

		def SplitBeforeCSQR(pItem, pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforeCS(pItem, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforeCS(pItem, pCaseSensitive) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBeforeCS(pItem, pCaseSensitive) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

	def SplittedBeforeCS(pItem, pCaseSensitive)
		return This.SplitBeforeCS(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitBefore(pItem)
		return This.SplitBeforeCS(pItem, TRUE)

		def SplitBeforeQ(pItem)
			return This.SplitBeforeQR(pItem, :stzList)

		def SplitBeforeQR(pItem, pcReturnType)
			return This.SplitBeforeCSQR(pItem, TRUE, pcReturnType)

	def SplittedBefore(pItem)
		return This.SplitBefore(pItem)

	  #---------------------------------------#
	 #   SPLITTING BEFORE A GIVEN POSITION   #
	#---------------------------------------#

	def SplitBeforePosition(n)
		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitBeforePosition(n)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitBeforePositionQ(n)
			return This.SplitBeforePositionQR(n, :stzList)

		def SplitBeforePositionQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforePosition(n) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforePosition(n) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBeforePosition(n) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForms

		def SplitBeforeThisPosition(n)
			return This.SplitBeforePosition(n)

			def SplitBeforeThisPositionQ(n)
				return This.SplitBeforeThisPositionQR(n, :stzList)

			def SplitBeforeThisPositionQR(n, pcReturnType)
				return This.SplitBeforePositionQR(n, pcReturnType)

		#>

	def SplittedBeforePosition(n)
		return This.SplitBeforePosition(n)

		def SplittedBeforeThisPosition(n)
			return This.SplitBeforePosition(n)

	  #-------------------------------------#
	 #   SPLITTING BEFORE MANY POSITIONS   #
	#-------------------------------------#

	def SplitBeforePositions(anPos)

		if CheckParams()
			if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
				StzRaise("Incorrect param type! anPos must be a list of numbers.")
			ok
		ok

		if This.IsEmpty()
			return []
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitBeforePositions(anPos)
		aResult = This.Sections( aSections )

		return aResult			

		#< @FunctionFluentForms

		def SplitBeforePositionsQ(anPos)
			return This.SplitBeforePositionsQR(anPos, :stzList)

		def SplitBeforePositionsQR(anPos, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforePositions(anPos) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforePositions(anPos) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBeforePositions(anPos) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForms

		def SplitBeforeThesePositions(anPos)
			return This.SplitBeforePositions(anPos)

			def SplitBeforeThesePositionsQ(anPos)
				return This.SplitBeforThesePositionsQR(anPos, :stzList)

			def SplitBeforeThesePositionsQR(anPos, pcReturnType)
				return This.SplitBeforePositionsQR(anPos, pcReturnType)

		def SplitBeforeManyPositions(anPos)
			return This.SplitBeforePositions(anPos)

			def SplitBeforeManyPositionsQ(anPos)
				return This.SplitBeforeManyPositionsQR(anPos, :stzList)

			def SplitBeforeManyPositionsQR(anPos, pcReturnType)
				return This.SplitBeforePositionsQR(anPos, pcReturnType)

		#>

	def SplittedBeforePositions(anPos)
		return This.SplitBeforePositions(anPos)

		def SplittedBeforeThesePoitions(anPos)
			return This.SplittedBeforePositions(anPos)

		def SplittedBeforeManyPoitions(anPos)
			return This.SplittedBeforePositions(anPos)

	  #----------------------------------------#
	 #   SPLITTING BEFORE A GIVEN Item   #
	#----------------------------------------#

	def SplitBeforeItemCS(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		anPos = This.FindCS(pItem, pCaseSensitive)
		aSections = StzSplitterQ( This.NumberOfItems() ).SplitBeforePositions(anPos)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitBeforeItemCSQ(pItem, pCaseSensitive)
			return This.SplitBeforeItemCSQR(pItem, pCaseSensitive, :stzList)

		def SplitBeforeItemCSQR(pItem, pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforeItemCS(pItem, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforeItemCS(pItem, pCaseSensitive) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBeforeItemCS(pItem, pCaseSensitive) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitBeforeThisItemCS(pItem, pCaseSensitive)
			return This.SplitBeforeItemCS(pItem, pCaseSensitive)

			def SplitBeforeThisItemCSQ(pItem, pCaseSensitive)
				return This.SplitBeforeThisItemCSQR(pItem, pCaseSensitive, :stzList)

			def SplitBeforeThisItemCSQR(pItem, pCaseSensitive, pcReturnType)
				return This.SplitBeforeItemCSQR(pItem, pCaseSensitive, pcReturnType)

		#>
				
	def SplittedBeforeItemCS(pItem, pCaseSensitive)
		return This.SplitBeforeItemCS(pItem, pCaseSensitive)

		def SplittedBeforeThisItemCS(pItem, pCaseSensitive)
			return This.SplittedBeforeItemCS(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitBeforeItem(pItem)
		return This.SplitBeforeItemCS(pItem, TRUE)

		#< @FunctionFluentForms

		def SplitBeforeItemQ(pItem)
			return This.SplitBeforeItemQR(pItem, :stzList)

		def SplitBeforeItemQR(pItem, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforeItem(pItem) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforeItem(pItem) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBeforeItem(pItem) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitBeforeThisItem(pItem)
			return This.SplitBeforeItem(pItem)

			def SplitBeforeThisItemQ(pItem)
				return This.SplitBeforeThisItemQR(pItem, :stzList)

			def SplitBeforeThisItemQR(pItem, pcReturnType)
				return This.SplitBeforeItemQR(pItem, pcReturnType)

		#>

	def SplittedBeforeItem(pItem)
		return This.SplitBeforeItem(pItem)

		def SplittedBeforeThisItem(pItem)
			return This.SplittedBeforeItem(pItem)

	  #--------------------------------------#
	 #   SPLITTING BEFORE MANY Items   #
	#--------------------------------------#

	def SplitBeforeItemsCS(paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		anPos = This.FindManyCS( paItems, pCaseSensitive )
		aSections = StzSplitterQ( This.NumberOfItems() ).SplitBeforePositions(anPos)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitBeforeItemsCSQ(paItems, pCaseSensitive)
			return This.SplitBeforeItemsCSQR(paItems, pCaseSensitive, :stzList)

		def SplitBeforeItemsCSQR(paItems, pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforeItemsCS(paItems, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforeItemsCS(paItems, pCaseSensitive) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBeforeItemsCS(paItems, pCaseSensitive) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForms

		def SplitBeforeTheseItemsCS(paItems, pCaseSensitive)
			return This.SplitBeforeItemsCS(paItems, pCaseSensitive)

			def SplitBeforeTheseItemsCSQ(paItems, pCaseSensitive)
				return This.SplitBeforeThisItemsCSQR(paItems, pCaseSensitive, :stzList)

			def SplitBeforeTheseItemsCSQR(paItems, pCaseSensitive, pcReturnType)
				return This.SplitBeforeItemsCSQR(paItems, pCaseSensitive, pcReturnType)

		def SplitBeforeManyItemsCS(paItems, pCaseSensitive)
			return This.SplitBeforeItemsCS(paItems, pCaseSensitive)

			def SplitBeforeManyItemsCSQ(paItems, pCaseSensitive)
				return This.SplitBeforeManyItemsCSQR(paItems, pCaseSensitive, :stzList)

			def SplitBeforeManyItemsCSQR(paItems, pCaseSensitive, pcReturnType)
				return This.SplitBeforeItemsCSQR(paItems, pCaseSensitive, pcReturnType)

		#>

	def SplittedBeforeItemsCS(paItems, pCaseSensitive)
		return This.SplitBeforeItemsCS(paItems, pCaseSensitive)

		def SplittedBeforeTheseItemsCS(paItems, pCaseSensitive)
			return This.SplittedBeforeItemsCS(paItems, pCaseSensitive)

		def SplittedBeforeManyItemsCS(paItems, pCaseSensitive)
			return This.SplittedBeforeItemsCS(paItems, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitBeforeItems(paItems)
		return This.SplitBeforeItemsCS(paItems, TRUE)
	
		#< @FunctionFluentForms

		def SplitBeforeItemsQ(paItems)
			return This.SplitBeforeItemsQR(paItems, :stzList)

		def SplitBeforeItemsQR(paItems, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforeItems(paItems) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforeItems(paItems) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBeforeItemsCS(paItems) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForms

		def SplitBeforeTheseItems(paItems)
			return This.SplitBeforeItems(paItems)

			def SplitBeforeTheseItemsQ(paItems)
				return This.SplitBeforeThisItemsQR(paItems, :stzList)

			def SplitBeforeTheseItemsQR(paItems, pcReturnType)
				return This.SplitBeforeItemsQR(paItems, pcReturnType)

		def SplitBeforeManyItems(paItems)
			return This.SplitBeforeItems(paItems)

			def SplitBeforeManyItemsQ(paItems)
				return This.SplitBeforeManyItemsQR(paItems, :stzList)

			def SplitBeforeManyItemsQR(paItems, pcReturnType)
				return This.SplitBeforeItemsQR(paItems, pcReturnType)

		#>

	def SplittedBeforeItems(paItems)
		return This.SplitBeforeItems(paItems)

		def SplittedBeforeTheseItems(paItems)
			return This.SplittedBeforeItems(paItems)

		def SplittedBeforeManyItems(paItems)
			return This.SplittedBeforeItems(paItems)

	  #--------------------------------------#
	 #   SPLITTING BEFORE A GIVEN SECTION   #
	#--------------------------------------#

	def SplitBeforeSection(n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitBeforeSection(n1, n2)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitBeforeSectionQ(n1, n2)
			return This.SplitBeforeSectionQR(n1, n2, :stzList)

		def SplitBeforeSectionQR(n1, n2, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforeSection(n1, n2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforeSection(n1, n2) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBeforeSubSection(n1, n2) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitBeforeThisSection(n1, n2)
			return This.SplitBeforeSection(n1, n2)

			def SplitBeforeThisSectionQ(n1, n2)
				return This.SplitBeforeThisSectionQR(n1, n2, :stzList)

			def SplitBeforeThisSectionQR(n1, n2, pcReturnType)
				return This.SplitBeforeSectionQR(n1, n2, pcReturnType)

		#>

	def SplittedBeforeSection(n1, n2)
		return This.SplitBeforeSection(n1, n2)

		def SplittedBeforeThisSection(n1, n2)
			return This.SplittedBeforeSection(n1, n2)

	  #--------------------------------------------------------#
	 #   SPLITTING BEFORE A GIVEN SECTION -- INCLUDING BOUND  #
	#--------------------------------------------------------#

	def SplitBeforeSectionIB(n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitBeforeSectionIB(n1, n2)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitBeforeSectionIBQ(n1, n2)
			return This.SplitBeforeSectionIBQR(n1, n2, :stzList)

		def SplitBeforeSectionIBQR(n1, n2, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforeSectionIB(n1, n2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforeSectionIB(n1, n2) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBeforeSubSectionIB(n1, n2) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitBeforeThisSectionIB(n1, n2)
			return This.SplitBeforeSectionIB(n1, n2)

			def SplitBeforeThisSectionIBQ(n1, n2)
				return This.SplitBeforeThisSectionIBQR(n1, n2, :stzList)

			def SplitBeforeThisSectionIBQR(n1, n2, pcReturnType)
				return This.SplitBeforeSectionIBQR(n1, n2, pcReturnType)

		#>

	def SplittedBeforeSectionIB(n1, n2)
		return This.SplitBeforeSectionIB(n1, n2)

		def SplittedBeforeThisSectionIB(n1, n2)
			return This.SplittedBeforeSectionIB(n1, n2)

	  #------------------------------------#
	 #   SPLITTING BEFORE MANY SECTIONS   #
	#------------------------------------#

	def SplitBeforeSections(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitBeforeSections(paSections)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitBeforeSectionsQ(paSections)
			return This.SplitBeforeSectionsQR(paSections, :stzList)

		def SplitBeforeSectionsQR(paSections, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforeSections(paSections) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforeSections(paSections) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBeforeSubSections(paSections) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForms

		def SplitBeforeTheseSections(paSections)
			return This.SplitBeforeSections(paSections)

			def SplitBeforeTheseSectionsQ(paSections)
				return This.SplitBeforeThesesSectionsQR(paSections, :stzList)

			def SplitBeforeTheseSectionsQR(paSections, pcReturnType)
				return This.SplitBeforeSectionsQR(paSections, pcReturnType)

		def SplitBeforeManySections(paSections)
			return This.SplitBeforeSections(paSections)

			def SplitBeforeManySectionsQ(paSections)
				return This.SplitBeforeTheseSectionsQR(paSections, :stzList)

			def SplitBeforeManySectionsQR(paSections, pcReturnType)
				return This.SplitBeforeSectionsQR(paSections, pcReturnType)

		#>

	def SplittedBeforeSections(paSections)
		return This.SplitBeforeSections(paSections)

		def SplittedBeforeTheseSections(paSections)
			return This.SplittedBeforeSections(paSections)

		def SplittedBeforeManySections(paSections)
			return This.SplittedBeforeSections(paSections)

	  #------------------------------------------------------#
	 #   SPLITTING BEFORE MANY SECTIONS -- INCLUDING BOUND  #
	#------------------------------------------------------#

	def SplitBeforeSectionsIB(paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitBeforeSectionsIB(paSections)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitBeforeSectionsIBQ(paSections)
			return This.SplitBeforeSectionsIBQR(paSections, :stzList)

		def SplitBeforeSectionsIBQR(paSections, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforeSectionsIB(paSections) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforeSectionsIB(paSections) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBeforeSubSectionsIB(paSections) )

			other
				StzRaise("Unsupported param type!")
			off

		#>


		#< @FunctionAlternativeForms

		def SplitBeforeTheseSectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)

			def SplitBeforeTheseSectionsIBQ(paSections)
				return This.SplitBeforeThesesSectionsIBQR(paSections, :stzList)

			def SplitBeforeTheseSectionsIBQR(paSections, pcReturnType)
				return This.SplitBeforeSectionsIBQR(paSections, pcReturnType)

		def SplitBeforeManySectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)

			def SplitBeforeManySectionsIBQ(paSections)
				return This.SplitBeforeTheseSectionsIBQR(paSections, :stzList)

			def SplitBeforeManySectionsIBQR(paSections, pcReturnType)
				return This.SplitBeforeSectionsIBQR(paSections, pcReturnType)

		#>

	def SplittedBeforeSectionsIB(paSections)
		return This.SplitBeforeSectionsIB(paSections)

		def SplittedBeforeTheseSectionsIB(paSections)
			return This.SplittedBeforeSectionsIB(paSections)

		def SplittedBeforeManySectionsIB(paSections)
			return This.SplittedBeforeSectionsIB(paSections)

	  #--------------------------------------------------#
	 #   SPLITTING AFTER A GIVEN ITEM  #
	#--------------------------------------------------#

	def SplitAfterCS(pItem, pCaseSensitive)
		if NOT isList(pItem)
			return This.SplitAfterItemCS(pItem, pCaseSensitive)

		else

			oItem = Q(pItem)

			if oItem.IsOneOfTheseNamedParams([ :Position, :ThisPosition ])

				return This.SplitAfterPosition(pItem[2])
	
			but oItem.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.SplitAfterPositions(pItem[2])

			but oItem.IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.SplitAfterItemCS(pItem[2], pCaseSensitive)
		
			but oItem.IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.SplitAfterItemsCS(pItem[2], pCaseSensitive)

			but oItem.IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.SplitAfterSection(pItem[2])
		
			but oItem.IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.SplitAfterSections(pItem[2])

			#-- Providing numbers, strings, or pairs of numbers,
			#   directly without named params

			but oItem.IsListOfNumbers()
				return This.SplitAfterPositions(pItem)

			but oItem.IsListOfStrings()
				return This.SplitAfterItems(pItem)

			but oItem.IsListOfPairsOfNumbers()
				return This.SplitAfterSections(pItem)

			else
				return This.SplitAfterItemCS(pItem, pCaseSensitive)
			ok

		ok

		#< @FunctionFluentForms

		def SplitAfterCSQ(pItem, pCaseSensitive)
			return This.SplitAfterCSQR(pItem, pCaseSensitive, :stzList)

		def SplitAfterCSQR(pItem, pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAfterCS(pItem, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAfterCS(pItem, pCaseSensitive) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitAfterCS(pItem, pCaseSensitive) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

	def SplittedAfterCS(pItem, pCaseSensitive)
		return This.SplitAfterCS(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitAfter(pItem)
		return This.SplitAfterCS(pItem, TRUE)

		#< @FunctionFluentForm

		def SplitAfterQ(pItem)
			return This.SplitAfterQR(pItem, :stzList)

		def SplitAfterQR(pItem, pcReturnType)
			return This.SplitAfterCSQR(pItem, TRUE, pcReturnType)

		#>

	def SplittedAfter(pItem)
		return This.SplitAfter(pItem)

	  #---------------------------------------#
	 #   SPLITTING BEFORE A GIVEN POSITION   #
	#---------------------------------------#

	def SplitAfterPosition(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAfterPosition(n)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitAfterPositionQ(n)
			return This.SplitAfterPositionQR(n, :stzList)

		def SplitAfterPositionQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAfterPosition(n) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAfterPosition(n) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitAfterPosition(n) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitAfterThisPosition(n)
			return This.SplitAfterPosition(n)

			def SplitAfterThisPositionQ(n)
				return This.SplitAfterThisPositionQR(n, :stzList)

			def SplitAfterThisPositionQR(n, pcReturnType)
				return This.SplitAfterPositionQR(n, pcReturnType)

		#>

	def SplittedAfterPosition(n)
		return This.SplitAfterPosition(n)

		def SplittedAfterThisPosition(n)
			return This.SplittedAfterPosition(n)

	  #-------------------------------------#
	 #   SPLITTING BEFORE MANY POSITIONS   #
	#-------------------------------------#

	def SplitAfterPositions(anPos)
		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAfterPositions(anPos)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitAfterPositionsQ(anPos)
			return This.SplitAfterPositionsQR(anPos, :stzList)

		def SplitAfterPositionsQR(anPos, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAfterPositions(anPos) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAfterPositions(anPos) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitAfterPositions(anPos) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitAfterThesePositions(anPos)
			return This.SplitAfterThesePositions(anPos)

			def SplitAfterThesePositionsQ(anPos)
				return This.SplitAfterThesePositionsQR(anPos, :stzList)

			def SplitAfterThesePositionsQR(anPos, pcReturnType)
				return This.SplitAfterPositionQR(n, pcReturnType)

		def SplitAfterManyPositions(anPos)
			return This.SplitAfterManyPositions(anPos)

			def SplitAfterManyPositionsQ(anPos)
				return This.SplitAfterManyPositionsQR(anPos, :stzList)

			def SplitAfterManyPositionsQR(anPos, pcReturnType)
				return This.SplitAfterPositionQR(n, pcReturnType)

		#>

	def SplittedAfterPositions(anPos)
		return This.SplitAfterPositions(anPos)

		def SplittedAfterThesePositions(anPos)
			return This.SplittedAfterPositions(anPos)

		def SplittedAfterManyPositions(anPos)
			return This.SplittedAfterPositions(anPos)

	  #----------------------------------------#
	 #   SPLITTING BEFORE A GIVEN Item   #
	#----------------------------------------#

	def SplitAfterItemCS(pItem, pCaseSensitive)

		anPos = This.FindCS(pItem, pCaseSensitive)
		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAfterPositions(anPos)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitAfterItemCSQ(pItem, pCaseSensitive)
			return This.SplitAfterItemCSQR(pItem, pCaseSensitive, :stzList)

		def SplitAfterItemCSQR(pItem, pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAfterItemCS(pItem, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAfterItemCS(pItem, pCaseSensitive) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitAfterItemCS(pItem, pCaseSensitive) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitAfterThisItemCS(pItem, pCaseSensitive)
			return This.SplitAfterItemCS(pItem, pCaseSensitive)

			def SplitAfterThisItemQCS(pItem, pCaseSensitive)
				return This.SplitAfterThisItemCSQR(pItem, pCaseSensitive, :stzList)

			def SplitAfterThisItemCSQR(pItem, pCaseSensitive, pcReturnType)
				return This.SplitAfterItemCSQR(pItem, pCaseSensitive, pcReturnType)

		#>

	def SplittedAfterItemCS(pItem, pCaseSensitive)
		return This.SplitAfterItemCS(pItem, pCaseSensitive)

		def SplittedAfterThisItemCS(pItem, pCaseSensitive)
			return This.SplittedAfterItemCS(pItem, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitAfterItem(pItem)
		return This.SplitAfterItemCS(pItem, TRUE)

		#< @FunctionFluentForms

		def SplitAfterItemQ(pItem)
			return This.SplitAfterItemQR(pItem)

		def SplitAfterItemQR(pItem)
			return This.SplitAfterThisItemCSQR(pItem, :pCaseSensitive = TRUE, pcReturnType)

		#>

		#< @FunctionAlternativeForm

		def SplitAfterThisItem(pItem)
			return This.SplitAfterItem(pItem)

			def SplitAfterThisItemQ(pItem)
				return This.SplitAfterThisItemQR(pItem, :stzList)

			def SplitAfterThisItemQR(pItem, pcReturnType)
				return This.SplitAfterItemQR(pItem, pcReturnType)

		#>

	def SplittedAfterItem(pItem)
		return This.SplitAfterItem(pItem)

		def SplittedAfterThisItem(pItem)
			return This.SplittedAfterItem(pItem)

	  #--------------------------------------#
	 #   SPLITTING BEFORE MANY Items   #
	#--------------------------------------#

	def SplitAfterItemsCS(paItems, pCaseSensitive)
		if NOT ( isList(paItems) and Q(paItems).IsListOfStrings() )
			StzRaise("Incorrect param type! paItems must be a list of strings.")
		ok

		anPos = This.FindCS( paItems, pCaseSensitive )
		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAfterPositions(anPos)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitAfterItemsCSQ(paItems, pCaseSensitive)
			return This.SplitAfterItemsCSQR(paItems, pCaseSensitive, :stzList)

		def SplitAfterItemsCSQR(paItems, pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAfterItemsCS(paItems, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAfterItemsCS(paItems, pCaseSensitive) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitAfterItemsCS(paItems, pCaseSensitive) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitAfterTheseItemsCS(paItems, pCaseSensitive)
			return This.SplitAfterItemsCS(paItems, pCaseSensitive)

			def SplitAfterTheseItemsQCS(paItems, pCaseSensitive)
				return This.SplitAfterTheseItemsCSQR(paItems, pCaseSensitive, :stzList)

			def SplitAfterTheseItemsCSQR(paItems, pCaseSensitive, pcReturnType)
				return This.SplitAfterItemsCSQR(paItems, pCaseSensitive, pcReturnType)

		def SplitAfterManyItemsCS(paItems, pCaseSensitive)
			return This.SplitAfterItemsCS(paItems, pCaseSensitive)

			def SplitAfterManyItemsQCS(paItems, pCaseSensitive)
				return This.SplitAfterManyItemsCSQR(paItems, pCaseSensitive, :stzList)

			def SplitAfterManyItemsCSQR(paItems, pCaseSensitive, pcReturnType)
				return This.SplitAfterItemsCSQR(paItems, pCaseSensitive)

		#>

	def SplittedAfterItemsCS(paItems, pCaseSensitive)
		return This.SplitAfterItemsCS(paItems, pCaseSensitive)

		def SplittedAfterTheseItemsCS(paItems, pCaseSensitive)
			return This.SplittedAfterItemsCS(paItems, pCaseSensitive)

		def SplittedAfterManyItemsCS(paItems, pCaseSensitive)
			return This.SplittedAfterItemsCS(paItems, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitAfterItems(paItems)
		return This.SplitAfterItemsCS(paItems, TRUE)

		#< @FunctionFluentForms

		def SplitAfterItemsQ(paItems)
			return This.SplitAfterItemsQR(paItems, :stzList)

		def SplitAfterItemsQR(paItems, pcReturnType)
			return This.SplitAfterItemsCSQR(paItems, :CaseSensitive, pcReturnType)

		#>

		#< @FunctionAlternativeForm

		def SplitAfterTheseItems(paItems)
			return This.SplitAfterItems(paItems)

			def SplitAfterTheseItemsQ(paItems)
				return This.SplitAfterTheseItemsQR(paItems, :stzList)

			def SplitAfterTheseItemsQR(paItems, pcReturnType)
				return This.SplitAfterItemsQR(paItems, pcReturnType)

		def SplitAfterManyItems(paItems)
			return This.SplitAfterItems(paItems)

			def SplitAfterManyItemsQ(paItems)
				return This.SplitAfterManyItemsQR(paItems, :stzList)

			def SplitAfterManyItemsQR(paItems, pcReturnType)
				return This.SplitAfterItemsQR(paItems, pcReturnType)

		#>

	def SplittedAfterItems(paItems)
		return This.SplitAfterItems(paItems)

		def SplittedAfterTheseItems(paItems)
			return This.SplitAfterItems(paItems)

		def SplittedAfterManyItems(paItems)
			return This.SplitAfterItems(paItems)

	  #-------------------------------------#
	 #   SPLITTING AFTER A GIVEN SECTION   #
	#-------------------------------------#

	def SplitAfterSection(n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAfterSection(n1 , n2)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitAfterSectionQ(n1, n2)
			return This.SplitAfterSectionQR(n1, n2)

		def SplitAfterSectionQR(n1, n2, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAfterSection(n1, n2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAfterSection(n1, n2) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitAfterSection(n1, n2) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitAfterThisSection(n1, n2)
			return This.SplitAfterSection(n1, n2)

			def SplitAfterThisSectionQ(n1, n2)
				return This.SplitAfterThisSectionQR(n1, n2, :stzList)

			def SplitAfterThisSectionQR(n1, n2, pcReturnType)
				return This.SplitAfterSectionQR(n1, n2, pcReturnType)

		#>

	def SplittedAfterSection(n1, n2)
		return This.SplitAfterSection(n1, n2)

		def SplittedAfterThisSection(n1, n2)
			return This.SplittedAfterSection(n1, n2)

	  #-------------------------------------------------------#
	 #   SPLITTING AFTER A GIVEN SECTION -- INCLUDING BOUND  #
	#-------------------------------------------------------#

	def SplitAfterSectionIB(n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAfterSectionIB(n1 , n2)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitAfterSectionIBQ(n1, n2)
			return This.SplitAfterSectionIBQR(n1, n2, :stzList)

		def SplitAfterSectionIBQR(n1, n2, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAfterSectionIB(n1, n2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAfterSectionIB(n1, n2) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitAfterSectionIB(n1, n2) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitAfterThisSectionIB(n1, n2)
			return This.SplitAfterSectionIB(n1, n2)

			def SplitAfterThisSectionIBQ(n1, n2)
				return This.SplitAfterThisSectionIBQR(n1, n2, :stzList)

			def SplitAfterThisSectionIBQR(n1, n2, pcReturnType)
				return This.SplitAfterSectionIBQR(n1, n2, pcReturnType)

		#>

	def SplittedAfterSectionIB(n1, n2)
		return This.SplitAfterSectionIB(n1, n2)

		def SplittedAfterThisSectionIB(n1, n2)
			return This.SplittedAfterSectionIB(n1, n2)

	  #-----------------------------------#
	 #   SPLITTING AFTER MANY SECTIONS   #
	#-----------------------------------#

	def SplitAfterSections(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAfterSections(paSections)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitAfterSectionsQ(paSections)
			return This.SplitAfterSectionsQR(paSections, :stzList)

		def SplitAfterSectionsQR(paSections, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAfterSections(paSections) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAfterSections(paSections) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitAfterSections(paSections) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitAfterTheseSections(paSections)
			return This.SplitAfteSections(paSections)

			def SplitAfterTheseSectionsQ(paSections)
				return This.SplitAfterTheseSectionsQR(paSections, :stzList)

			def SplitAfterTheseSectionsQR(paSections, pcReturnType)
				return This.SplitAfterSectionsQR(paSections, pcReturnType)

		#>

	def SplittedAfterSections(paSections)
		return This.SplitAfterSections(paSections)

		def SplittedAfterTheseSections(paSections)
			return This.SplittedAfterSections(paSections)

	  #------------------------------------------------------#
	 #   SPLITTING AFTER MANY SECTIONS -- INCLUDING BOUNDS  #
	#------------------------------------------------------#

	def SplitAfterSectionsIB(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aSections = StzSplitterQ( This.NumberOfItems() ).SplitAfterSectionsIB(paSections)
		aResult = This.Sections( aSections )

		return aResult

		#< @FunctionFluentForms

		def SplitAfterSectionsIBQ(paSections)
			return This.SplitAfterSectionsIBQR(paSections, :stzList)

		def SplitAfterSectionsIBQR(paSections, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAfterSectionsIB(paSections) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAfterSectionsIB(paSections) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitAfterSectionsIB(paSections) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitAfterTheseSectionsIB(paSections)
			return This.SplitAfteSectionsIB(paSections)

			def SplitAfterTheseSectionsIBQ(paSections)
				return This.SplitAfterTheseSectionsIBQR(paSections, :stzList)

			def SplitAfterTheseSectionsIBQR(paSections, pcReturnType)
				return This.SplitAfterSectionsIBQR(paSections, pcReturnType)

		#>

	def SplittedAfterSectionsIB(paSections)
		return This.SplitAfterSectionsIB(paSections)

		def SplittedAfterTheseSectionsIB(paSections)
			return This.SplittedAfterSectionsIB(paSections)

	  #-------------------------------------------------#
	 #  SPLITTING BETWEEN TWO POSITIONS OR Items  #
	#=================================================#

	#TODO
	# Check it for correctness

	def SplitBetweenCS(pItem1, pItem2, pCaseSensitive)

		anFirstBounds  = This.FindAllCS(pItem1, pCaseSensitive)
		anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

		aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
		anFirstBounds  = aListOfBounds[1]
		anSecondBounds = aListOfBounds[2]

		aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)
		aResult = This.Sections(aSections)

		return aResult

		#< @FunctionFluentForms

		def SplitBetweenCSQ(Bound1, pItem2, pCaseSensitive)
			return This.SplitBetweenCSQR(Bound1, pItem2, pCaseSensitive, :stzList)

		def SplitBetweenCSQR(Bound1, pItem2, pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBetweenCS(pItem1, pItem2, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBetweenCS(pItem1, pItem2, pCaseSensitive) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBetweenCS(pItem1, pItem2, pCaseSensitive) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

	def SplittedBetweenCS(pItem1, pItem2, pCaseSensitive)
		return This.SplitBetweenCS(pItem1, pItem2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitBetween(pItem1, pItem2)
		return This.SplitBetweenCS(pItem1, pItem2, TRUE)

		#< @FunctionFluentForms

		def SplitBetweenQ(Bound1, pItem2, pCaseSensitive)
			return This.SplitBetweenQR(Bound1, pItem2, :stzList)

		def SplitBetweenQR(Bound1, pItem2, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBetween(pItem1, pItem2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBetween(pItem1, pItem2) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBetween(pItem1, pItem2) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

	def SplittedBetween(pItem1, pItem2)
		return This.SplitBetween(pItem1, pItem2)

	  #---------------------------------------------------------------------#
	 #  SPLITTING BETWEEN TWO POSITIONS OR Items -- INCLUDING BOUNDS  #
	#---------------------------------------------------------------------#

	#TODO
	# Check it for correctness

	def SplitBetweenCSIB(pItem1, pItem2, pCaseSensitive)
		anFirstBounds  = This.FindAllCS(pItem1, pCaseSensitive)
		anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

		aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
		anFirstBounds  = aListOfBounds[1]
		anSecondBounds = aListOfBounds[2]

		nLen = len(anFirstBounds)
		for i = 1 to nLen
			anFirstBounds[i]--
			anSecondBounds[i]++
		next

		aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)
		aResult = This.Sections(aSections)

		return aResult

		#< @FunctionFluentForms

		def SplitBetweenCSIBQ(Bound1, pItem2, pCaseSensitive)
			return This.SplitBetweenCSIBQR(Bound1, pItem2, pCaseSensitive, :stzList)

		def SplitBetweenCSIBQR(Bound1, pItem2, pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBetweenCSIB(pItem1, pItem2, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBetweenCSIB(pItem1, pItem2, pCaseSensitive) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBetweenCSIB(pItem1, pItem2, pCaseSensitive) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

	def SplittedBetweenCSIB(pItem1, pItem2, pCaseSensitive)
		return This.SplitBetweenCSIB(pItem1, pItem2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitBetweenIB(pItem1, pItem2)
		return This.SplitBetweenCSIB(pItem1, pItem2, TRUE)

		#< @FunctionFluentForms

		def SplitBetweenIBQ(Bound1, pItem2, pCaseSensitive)
			return This.SplitBetweenIBQR(Bound1, pItem2, :stzList)

		def SplitBetweenIBQR(Bound1, pItem2, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBetweenIB(pItem1, pItem2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBetweenIB(pItem1, pItem2) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBetweenIB(pItem1, pItem2) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

	def SplittedBetweenIB(pItem1, pItem2)
		return This.SplitBetweenIB(pItem1, pItem2)

	  #------------------------------------#
	 #  SPLITTING BETWEEN TWO POSITIONS   #
	#------------------------------------#

	def SplitBetweenPositions(n1, n2)
		This.SplitAtSection(n1, n2)

		#< @FunctionFluentForms

		def SplitBetweenPositionsQ(n1, n2)
			return This.SplitBetweenPositionsQR(n1, n2, :stzList)

		def SplitBetweenPositionsQR(n1, n2, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBetweenPositions(n1, n2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBetweenPositions(n1, n2) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBetweenPositions(n1, n2) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitBetweenThesePositions(n1, n2)
			return This.SplitBetweenPositions(n1, n2)

			def SplitBetweenThesePositionsQ(n1, n2)
				return This.SplitBetweenThesePositionsQR(n1, n2, :stzList)

			def SplitBetweenThesePositionsQR(n1, n2, pcReturnType)
				return This.SplitBetweenPositionsQR(n1, n2, pcReturnType)

		#>

	def SplittedBetweenPositions(n1, n2)
		return This.SplitBetweenPositions(n1, n2)

		def SplittedBetweenThesePositions(n1, n2)
			return This.SplittedBetweenPositions(n1, n2)

	  #-------------------------------------------------------#
	 #  SPLITTING BETWEEN TWO POSITIONS -- INCLUDING BOUNDS  #
	#-------------------------------------------------------#

	def SplitBetweenPositionsIB(n1, n2)
		This.SplitAtSectionIB(n1, n2)

		#< @FunctionFluentForms

		def SplitBetweenPositionsIBQ(n1, n2)
			return This.SplitBetweenPositionsIBQR(n1, n2, :stzList)

		def SplitBetweenPositionsIBQR(n1, n2, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBetweenPositionsIB(n1, n2) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBetweenPositionsIB(n1, n2) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBetweenPositionsIB(n1, n2) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitBetweenThesePositionsIB(n1, n2)
			return This.SplitBetweenPositionsIB(n1, n2)

			def SplitBetweenThesePositionsIBQ(n1, n2)
				return This.SplitBetweenThesePositionsIBQR(n1, n2, :stzList)

			def SplitBetweenThesePositionsIBQR(n1, n2, pcReturnType)
				return This.SplitBetweenPositionsIBQR(n1, n2, pcReturnType)

		#>

	def SplittedBetweenPositionsIB(n1, n2)
		return This.SplitBetweenPositionsIB(n1, n2)

		def SplittedBetweenThesePositionsIB(n1, n2)
			return This.SplittedBetweenPositionsIB(n1, n2)

	  #-------------------------------#
	 #  SPLITTING BETWEEN TWO Items  #
	#-------------------------------#

	def SplitBetweenItemsCS(paItems, pCaseSensitive)
		aSections = This.FindAsSectionsCS(paItems, pCaseSensitive)
		aResult = This.SplitBetweenSections(aSections)
		return aResult

		#< @FunctionFluentForms

		def SplitBetweenItemsCSQ(paItems, pCaseSensitive)
			return This.SplitBetweenItemsCSQR(paItems, pCaseSensitive, :stzList)

		def SplitBetweenItemsCSQR(paItems, pCaseSensitive, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBetweenItemsCS(paItems, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBetweenItemsCS(paItems, pCaseSensitive) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBetweenItemsCS(paItems, pCaseSensitive) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitBetweenTheseItemsCS(paItems, pCaseSensitive)
			return This.SplitBetweenItemsCS(paItems, pCaseSensitive)

			def SplitBetweenTheseItemsCSQ(paItems, pCaseSensitive)
				return This.SplitBetweenTheseItemsCSQR(paItems, pCaseSensitive, :stzList)

			def SplitBetweenTheseItemsCSQR(paItems, pCaseSensitive, pcReturntype)
				return This.SplitBetweenItemsCSQR(paItems, pCaseSensitive, pcReturnType)

		#>

	def SplittedBetweenItemsCS(paItems, pCaseSensitive)
		aResult = This.Copy().SplitBetweenItemsCSQ(paItems, pCaseSensitive).Content()
		return aResult

		def SplittedBetweenTheseItemsCs(paItems, pCaseSensitive)
			return This.SplittedBetweenItemsCS(paItems, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SplitBetweenItems(paItems)
		return This.SplitBetweenItemsCS(paItems, TRUE)

		#< @FunctionFluentForms

		def SplitBetweenItemsQ(paItems)
			return This.SplitBetweenItemsQR(paItems, :stzList)

		def SplitBetweenItemsQR(paItems, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBetweenItems(paItems) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBetweenItems(paItems) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitBetweenItems(paItems) )

			other
				StzRaise("Unsupported param type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitBetweenTheseItems(paItems)
			return This.SplitBetweenItems(paItems)

			def SplitBetweenTheseItemsQ(paItems)
				return This.SplitBetweenTheseItemsQR(paItems, :stzList)

			def SplitBetweenTheseItemsQR(paItems, pcReturntype)
				return This.SplitBetweenItemsQR(paItems, pcReturnType)

		#>

	def SplittedBetweenItems(paItems)
		return This.SplittedBetweenItemsCS(paItems, TRUE)

		def SplittedBetweenTheseItems(paItems)
			return This.SplittedBetweenItems(paItems)

	  #----------------------------#
	 #    SPLITTING TO N PARTS    #
	#============================#

	def SplitToNParts(n)
		aSections = StzSplitterQ( This.NumberOfItems() ).SplitToNParts(n)
		aResult = This.Sections(aSections)

		return aResult

		#< @FunctionFluentForms

		def SplitToNPartsQ(n)
			return This.SplitToNPartsQR(n, :stzList)

		def SplitToNPartsQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitToNParts(n) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitToNParts(n) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitToNParts(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

	def SplittedToNParts(n)
		return This.SplitToNParts(n)

	  #---------------------------------------------#
	 #   SPLITTING TO PARTS OF (EXACTLY) N Items   #
	#---------------------------------------------#
	# Remaining part less the n Items is not returned

	def SplitToPartsOfNItems(n)
		aSections = StzSplitterQ( This.NumberOfItems() ).
				SplitToPartsOfExactlyNPositions(n)

		aResult = This.Sections( aSections )
		return aResult

		#< @FunctionFluentForms

		def SplitToPartsOfNItemsQ(n)
			return This.SplitToPartsOfNItemsQR(n, :stzList)

		def SplitToPartsOfNItemsQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitToPartsOfNItems(n) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitToPartsOfNItems(n) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitToPartsOfNItems(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def SplitToPartsOfExactlyNItems(n)
			return This.SplitToPartsOfNItems(n)

			def SplitToPartsOfExactlyNItemsQ(n)
				return This.SplitToPartsOfExactlyNItemsQR(n, :stzList)

			def SplitToPartsOfExactlyNItemsQR(n, pcReturnType)
				return This.SplitToPartsOfNItemsQR(n, pcReturnType)

		#>

	def SplittedToPartsOfNItems(n)
		return This.SplitToPartsOfNItems(n)

		def SplittedToPartsOfExactlyNItems(n)
			return This.SplitToPartsOfNItems(n)

	  #----------------------------------------------#
	 #   SPLITTING TO PARTS OF N Items -- EXTENDED  #
	#----------------------------------------------#
	# The remaing part (if any) less then n Items is also returned

	def SplitToPartsOfNItemsXT(n)
		aSections = StzSplitterQ( This.NumberOfItems() ).
				SplitToPartsOfNPositions(n)

		aResult = This.Sections(aSections)

		return aResult

		#< @FunctionFluentForms

		def SplitToPartsOfNItemsXTQ(n)
			return This.SplitToPartsOfNItemsXTQR(n, :stzList)

		def SplitToPartsOfNItemsXTQR(n, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitToPartsOfNItemsXT(n) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SplitToPartsOfNItemsXT(n) )

			on :stzListOfItems
				return new stzListOfItems( This.SplitToPartsOfNItemsXT(n) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

	def SplittedToPartsOfNItemsXT(n)
		return This.SplitToPartsOfNItemsXT(n)

		def SplittedToPartsOfExactlyNItemsXT(n)
			return This.SplitToPartsOfNItemsXT(n)

	  #---------------------------------------#
	 #    SPLITTING UNDER A GIVEN CONDTION   #
	#=======================================#

	def SplitW(pcCondition)
		/*
		? StzListQ(1:5).SplitW('Q(@item).IsMultipleOf(2)')
		*/

		if isList(pcCondition)

			if Q(pcCondition).IsWhereNamedParam()
				return This.SplitAtW(pcCondition[2])

			but Q(pcCondition).IsAtNamedParam()
				return This.SplitAtW(pcCondition[2])

			but Q(pcCondition).IsBeforeNamedParam()
				return This.SplitBeforeW(pcCondition[2])

			but Q(pcCondition).IsAfterNamedParam()
				return This.SplitAfterW(pcCondition[2])

			ok
		
		else

			return This.SplitAtW(pcCondition)
		ok

		#< @FunctionFluentForms

		def SplitWQ(pcCondition)
			return This.SplitWQR(pcCondition, :stzList)

		def SplitWQR(pcCondition, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitW(pcCondition) )
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitW(pcCondition) )
			on :stzListOfItems
				return new stzListOfItems( This.SplitW(pcCondition) )
			other
				StzRaise("Unsupported return type!")
			off

		#>

	def SplittedW(pcConditon)
		return This.SplitW(pcCondition)

	  #------------------------------------#
	 #    SPLITTING AT A GIVEN CONDTION   #
	#------------------------------------#

	def SplitAtW(pcCondition)
			
		if isList(pcCondition) and Q(pcCondition).IsWhereNamedParam()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		aResult = []

		pcCondition = Q(pcCondition).TrimQ().TheseBoundsRemoved( "{","}" )

		if Q(pcCondition).ContainsCS("@Item", :CS = FALSE)

			aSections = This.FindItemsAsSectionsW(pcCondition)
			aResult = This.SplitAtSections(aSections)

		else

			anPos = This.FindW(pcCondition)
			aResult = This.SplitAtPositions(anPos)
		ok

		return aResult

		#< @FunctionFluentForms

		def SplitAtWQ(pcCondition)
			return This.SplitAtWQR(pcCondition, :stzList)

		def SplitAtWQR(pcCondition, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAtW(pcCondition) )
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAtW(pcCondition) )
			on :stzListOfItems
				return new stzListOfItems( This.SplitAtW(pcCondition) )
			other
				StzRaise("Unsupported return type!")
			off

		#>

	def SplittedAtW(pcConditon)
		return This.SplitAtW(pcCondition)

	  #----------------------------------------#
	 #    SPLITTING BEFORE A GIVEN CONDTION   #
	#----------------------------------------#

	def SplitBeforeW(pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsW(pcCondition)

		else
			anPos = This.FindItemsW(pcCondition)
		ok

		aResult = This.SplitBeforePositions(anPos)

		return aResult

		#< @FunctionFluentForms

		def SplitBeforeWQ(pcCondition)
			return This.SplitBeforeWQR(pcCondition, :stzList)

		def SplitBeforeWQR(pcCondition, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitBeforeW(pcCondition) )
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitBeforeW(pcCondition) )
			on :stzListOfItems
				return new stzListOfItems( This.SplitBeforeW(pcCondition) )
			other
				StzRaise("Unsupported return type!")
			off

		#>

	def SplittedBeforeW(pcConditon)
		return This.SplitBeforeW(pcCondition)

	  #---------------------------------------#
	 #    SPLITTING AFTER A GIVEN CONDTION   #
	#---------------------------------------#

	def SplitAfterW(pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsW(pcCondition)

		else
			anPos = This.FindItemsW(pcCondition)
		ok

		aResult = This.SplitAfterPositions(anPos)

		return aResult

		#< @FunctionFluentForms

		def SplitAfterWQ(pcCondition)
			return This.SplitAfterWQR(pcCondition, :stzList)

		def SplitAfterWQR(pcCondition, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.SplitAfterW(pcCondition) )
			on :stzListOfStrings
				return new stzListOfStrings( This.SplitAfterW(pcCondition) )
			on :stzListOfItems
				return new stzListOfItems( This.SplitAfterW(pcCondition) )
			other
				StzRaise("Unsupported return type!")
			off

		#>

	def SplittedAfterW(pcConditon)
		return This.SplitAfterW(pcCondition)

	  #----------------------------------------------------------------#
	 #  NTH Item AFTER SPLITTING STRING USING A GIVEN SEPARATOR  #
	#================================================================#
	# Utility function used to simplify code in stzListOfStrings

	def NthItemAfterSplittingStringUsing(n, cSep)
	#TODO: Remake it using FindNthSplitZZ(n)

		return This.Split(cSep)[n]

		def NthSplit(n, cSep)
			return This.NthItemAfterSplittingStringUsing(n, cSep)

	  #========================#
	 #   FINDING THE SPLITS   #
	#========================#

	def FindSplitsCSXT(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pItem)
			return This.FindSplitsAtItemCS(pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindSplitsAtPosition(pItem)

		but isList(pItem) and Q(pItem).IsListOfNumbers()
			return This.FindSplitsAtPositions(pItem)

		but isList(pItem) and Q(pItem).IsPairOfNumbers()
			return This.FindSplitsAtSection(pItem[1], pItem[2])

		but isList(pItem) and Q(pItem).IsListOfPairsOfNumbers()
			return This.FindSplitsAtSections(pItem)

		but isList(pItem)

			oParam = Q(pItem)

			#-- SPLITTING AT / USING

			if oParam.IsOneOfTheseNamedParams([ :At, :Using ])
				return This.FindSplitsAtCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtPosition, :AtThisPosition ]) 
				return This.FindSplitsAtPosition(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AtPositions, :AtThesePositions ]) 
				return This.FindSplitsAtPositions(pItem[2])

			but oParam.IsOneOfTheseNamedParams([
						:AtItem, :AtThisItem,
						:UsingItem, :UsingThisItem ]) 

				return This.FindSplitsAtItemCS(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([
						:AtItems, :AtTheseItems,
						:UsingItems, :UsingTheseItems ]) 

				return This.FindSplitsAtItemsCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtSection, :AtThisSection ]) 
				return This.FindSplitsAtSection(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AtSections, :AtTheseSections ]) 
				return This.FindSplitsAtSections(pItem[2])

			#-- SPLITTING BEFORE

			but oParam.IsBeforeNamedParam()
				return This.FindSplitsBeforeCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforePosition, :BeforeThisPosition ]) 
				return This.FindSplitsBeforePosition(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :BeforePositions, :BeforeThesePositions ]) 
				return This.FindSplitsBeforePositions(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :BeforeItem, :BeforeThisItem ]) 
				return This.FindSplitsBeforeItemCS(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeItems, :BeforeTheseItems ]) 
				return This.SplitBeforeItemsCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforeSection, :BeforeThisSection ]) 
				return This.FindSplitsBeforeSection(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeSections, :BeforeTheseSections ]) 
				return This.FindSplitsBeforeSections(pItem[2])

			#-- SPLITTING AFTER

			but oParam.IsAfterNamedParam()
				return This.FindSplitsAfterCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterPosition, :AfterThisPosition ]) 
				return This.FindSplitsAfterPosition(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AfterPositions, :AfterThesePositions ]) 
				return This.FindSplitsAfterPositions(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :AfterItem, :AfterThisItem ]) 
				return This.FindSplitsAfterItemCS(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :AfterItems, :AfterTheseItems ]) 
				return This.FindSplitsAfterItemsCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterSection, :AfterThisSection ]) 
				return This.FindSplitsAfterSection(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AfterSections, :AfterTheseSections ]) 
				return This.FindSplitsAfterSections(pItem[2])

			# SPLITTING BETWEEN

			but oParam.IsBetweenNamedParam() and
				isList(pItem) and len(pItem) = 2
				
				if isList(pItem[2]) and Q(pItem[2]).IsAndNamedParam()
					pItem[2] = pItem[2][2]
				ok

				return This.FindSplitsBetweenCS(pItem[1], pItem[2], pCaseSensitive)

			but oParam.IsBetweenPositionsNamedParam()
				return This.FindSplitsBetweenPositions(pItem[1], pItem[2])

			but oParam.IsBetweenItemsNamedParam()
				return This.FindSplitsBetweenItemsCS(pItem[1], pItem[2], pCaseSensitive)

			# SPLITTING TO PARTS

			but oParam.IsToNPartsNamedParam()
				return This.FindSplitsToNParts(pItem[2])

			but oParam.IsToPartsOfNItemsNamedParam()
				return This.FindSplitsToPartsOfNItems(pItem[2])

			# SPLITTING WHERE

			but oParam.IsWhereOrAtWhereNamedParam()
				return This.FindSplitsAtW(pItem[2])

			but oParam.IsBeforeWhereNamedParam()
				return This.FindSplitsBeforeW(pItem[2])

			but oParam.IsAfterWhereNamedParam()
				return This.FindSplitsAfterW(pItem[2])

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindSplitsCSXTZ(pItem, pCaseSensitive)
			return This.FindSplitsCSXT(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsXT(pItem)
		return This.FindSplitsCSXT(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsXTZ(pItem)
			return This.FindSplitsXT(pItem)

		#>

	  #----------------------------------------------------#
	 #   FINDING SPLITS AT A GIVEN Item  #
	#====================================================#

	def FindSplitsAtCS(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pItem)
			return This.FindSplitsAtItemCS(pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindSplitsAtPosition(pItem)

		but isList(pItem) and Q(pItem).IsListOfNumbers()
			return This.FindSplitsAtPositions(pItem)

		but isList(pItem) and Q(pItem).IsPairOfNumbers()
			return This.FindSplitsAtSection(pItem[1], pItem[2])

		but isList(pItem) and Q(pItem).IsListOfPairsOfNumbers()
			return This.FindSplits(pItem)

		but isList(pItem)

			oParam = Q(pItem)

			#-- Case when named params are provided

			if oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindSplitsAtPosition(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindSplitsAtPositions(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindSplitsAtItemCS(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindSplitsAtItemsCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindSplitsAtSection(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindSplitsAtSections(pItem[2])

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindSplitsAtCSZ(pItem, pCaseSensitive)
			return This.FindSplitsAtCS(pSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAt(pItem)
		return This.FindSplitsAtCS(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAtZ(pItem)
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

		aResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsAtPosition(n)
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

		aResult = StzSplitterQ(This.NumberOfItems()).FindSplitsAtPositions(anPos)
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
	 #   FINDING SPLITS AT A GIVEN Item   #
	#=========================================#

	def FindSplitsAtItemCS(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT isString(pItem)
				StzRaise("Incorrect param type! pItem must be a string.")
			ok
	
			if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
				pCaseSensitive = pCaseSensitive[2]
			ok
	
			if NOT IsBoolean(pCaseSensitive)
				StzRaise("Incorrect param type! pCaseSensitive must be a boolean (TRUE or FALSE).")
			ok

		ok

		anResult = This.FindManyCS( This.SplitsAtItemCS(pItem, pCaseSensitive), pCaseSensitive)
		return anResult

		#< @FunctionAlternativeForms

		def FindSplitsCS(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindSplitsAtItemCS(pItem, pCaseSensitive)

		def FindSplitsAtThisItemCS(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindSplitsAtItemCS(pItem, pCaseSensitive)

		#--

		def FindSplitsAtItemCSZ(pItem, pCaseSensitive)
			return This.FindSplitsAtItemCS(pItem, pCaseSensitive)

		def FindSplitsCSZ(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindSplitsAtItemCS(pItem, pCaseSensitive)

		def FindSplitsAtThisItemCSZ(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindSplitsAtItemCS(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtItem(pItem)
		return This.FindSplitsAtItemCS(pItem, TRUE)

		#< @FunctionAlternativeForms

		def FindSplits(pItem)
			return This.FindSplitsCS(pItem, TRUE)

		def FindSplitsAtThisItem(pItem)
			return This.FindSplitsAtThisItemCS(pItem, TRUE)
		#--

		def FindSplitsAtItemZ(pItem)
			return This.FindSplitsAtItemCS(pItem, TRUE)

		def FindSplitsZ(pItem)
			return This.FindSplitsCS(pItem, TRUE)

		def FindSplitsAtThisItemZ(pItem)
			return This.FindSplitsAtThisItemCS(pItem, TRUE)

		#>

	  #----------------------------------------#
	 #   FINDING SPLITS AT GIVEN Items   #
	#----------------------------------------#

	def FindSplitsAtItemsCS(paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		anPos = This.FindCS(paItems, pCaseSensitive)

		aResult = This.FindSplitsAtPositions(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseItemsCS(paItems, pCaseSensitive)
			return This.FindSplitsAtItemsCS(paItems, pCaseSensitive)

		def FindSplitsAtManyItemsCS(paItems, pCaseSensitive)
			return This.FindSplitsAtItemsCS(paItems, pCaseSensitive)

		#--

		def FindSplitsAtItemsCSZ(paItems, pCaseSensitive)
			return This.FindSplitsAtItemsCS(paItems, pCaseSensitive)

		def FindSplitsAtTheseItemsCSZ(paItems, pCaseSensitive)
			return This.FindSplitsAtItemsCS(paItems, pCaseSensitive)

		def FindSplitsAtManyItemsCSZ(paItems, pCaseSensitive)
			return This.FindSplitsAtItemsCS(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtItems(paItems)
		return This.FindSplitsAtItemsCS(paItems, TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseItems(paItems)
			return This.FindSplitsAtItems(paItems)
	
		def FindSplitsAtManyItems(paItems)
			return This.FindSplitsAtItems(paItems)

		#--

		def FindSplitsAtItemsZ(paItems)
			return This.FindSplitsAtItems(paItems)

		def FindSplitsAtTheseItemsZ(paItems)
			return This.FindSplitsAtItems(paItems)

		def FindSplitsAtManyItemsZ(paItems)
			return This.FindSplitsAtItems(paItems)

		#>

	  #---------------------------------------#
	 #   FINDING SPLITS AT A GIVEN SECTION   #
	#=======================================#

	def FindSplitsAtSectionCS(n1, n2, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		acSplits = This.SplitsAtSection(n1, n2)
		anResult = This.FindManyCS(acSplits, pCaseSensitive)

		return anResult

		#< @FunctionAlternativeForm

		def FindSplitsAtThisSectionCS(n1, n2, pCaseSensitive)
			return This.FindSplitsAtSectionCS(n1, n2, pCaseSensitive)

		#--

		def FindSplitsAtSectionCSZ(n1, n2, pCaseSensitive)
			return This.FindSplitsAtSectionCS(n1, n2, pCaseSensitive)

		def FindSplitsAtThisSectionCSZ(n1, n2, pCaseSensitive)
			return This.FindSplitsAtSectionCS(n1, n2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtSection(n1, n2)
		return This.FindSplitsAtSectionCS(n1, n2, TRUE)

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
	#==========================================================#

	def FindSplitsAtSectionCSIB(n1, n2, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		acSplits = This.SplitsAtSectionIB(n1, n2)
		anResult = This.FindManyCS(acSplits, pCaseSensitive)

		return anResult

		#< @FunctionAlternativeForm

		def FindSplitsAtThisSectionCSIB(n1, n2, pCaseSensitive)
			return This.SplitAtSectionCSIB(n1, n2, pCaseSensitive)

		#--

		def FindSplitsAtSectionCSIBZ(n1, n2, pCaseSensitive)
			return This.FindSplitsAtSectionCSIB(n1, n2, pCaseSensitive)

		def FindSplitsAtThisSectionCSIBZ(n1, n2, pCaseSensitive)
			return This.SplitAtSectionCSIB(n1, n2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtSectionIB(n1, n2)
		return This.FindSplitsAtSectionCSIB(n1, n2, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAtThisSectionIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		#--

		def FindSplitsAtSectionIBZ(n1, n2)
			return This.FindSplitsAtSectionIB(n1, n2)

		def FindSplitsAtThisSectionIBZ(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		#>

	  #------------------------------------#
	 #   FINDING SPLITS AT MANY SECTIONS  #
	#====================================#

	def FindSplitsAtSectionsCS(paSections, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
				StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
			ok

		ok

		acSplits = This.SplitsAtSections(paSections)
		anResult = This.FindManyCS(acSplits, pCaseSensitive)

		return anResult
		
		#< @FunctionAlternativeForms

		def FindSplitsAtTheseSectionsCS(paSections, pCaseSensitive)
			return This.FindSplitsAtSectionsCS(paSections, pCaseSensitive)

		#--

		def FindSplitsAtSectionsCSZ(paSections, pCaseSensitive)
			return This.FindSplitsAtSectionsCS(paSections, pCaseSensitive)

		def FindSplitsAtTheseSectionsCSZ(paSections, pCaseSensitive)
			return This.FindSplitsAtSectionsCS(paSections, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtSections(paSections)
		return This.FindSplitsAtSectionsCS(paSections, TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseSections(paSections)
			return This.FindSplitsAtSections(paSections)

		#--

		def FindSplitsAtSectionsZ(paSections)
			return This.FindSplitsAtSections(paSections)

		def FindSplitsAtTheseSectionsZ(paSections)
			return This.FindSplitsAtSections(paSections)

		#>

	  #--------------------------------------------------------#
	 #   FINDING SPLITS AT MANY SECTIONS -- BOUNDS INCLUDED   #
	#========================================================#

	def FindSplitsAtSectionsCSIB(paSections, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
				StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
			ok
	
		ok

		acSplits = This.SplitsAtSectionsIB(paSections)
		anResult = This.FindManyCS(acSplits, pCaseSensitive)

		return anResult

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseSectionsCSIB(paSections, pCaseSensitive)
			return This.FindSplitsAtSectionsCSIB(paSections, pCaseSensitive)

		#--

		def FindSplitsAtSectionsCSIBZ(paSections, pCaseSensitive)
			return This.FindSplitsAtSectionsCSIB(paSections, pCaseSensitive)

		def FindSplitsAtTheseSectionsCSIBZ(paSections, pCaseSensitive)
			return This.FindSplitsAtSectionsCSIB(paSections, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtSectionsIB(paSections)
		return This.FindSplitsAtSectionsCSIB(paSections, TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseSectionsIB(paSections)
			return This.FindSplitsAtSectionsIB(paSections)

		#--

		def FindSplitsAtSectionsIBZ(paSections)
			return This.FindSplitsAtSectionsIB(paSections)

		def FindSplitsAtTheseSectionsIBZ(paSections)
			return This.FindSplitsAtSectionsIB(paSections)

		#>

	  #---------------------------------------------------------#
	 #   FINDING SPLITS BEFORE A GIVEN ITEM   #
	#=========================================================#

	def FindSplitsBeforeCS(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pItem)
			return This.FindSplitsBeforeItemCS(pItem, pCaseSensitive)

		but isList(pItem) and Q(pItem).IsListOfStrings()
			return This.FindSplitsBeforeItemsCS(pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindSplitsBeforePosition(pItem)

		but isList(pItem) and Q(pItem).IsListOfNumbers()
			return This.FindSplitsBeforePositions(pItem)

		but isList(pItem) and Q(pItem).IsPairOfNumbers()
			return This.FindSplitsBeforeSection(pItem[1], pItem[2])

		but isList(pItem) and Q(pItem).IsListOfPairsOfNumbers()
			return This.FindSplitsBeforeSections(pItem[1], pItem[2])

		but isList(pItem)

			#-- Case when named params are provided

			if Q(pItem).IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindSplitsBeforePosition(pItem[2])
	
			but Q(pItem).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindSplitsBeforePositions(pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindSplitsBeforeItemCS(pItem[2], pCaseSensitive)
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindSplitsBeforeItemsCS(pItem[2], pCaseSensitive)

			but Q(pItem).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindSplitsBeforeSection(pItem[2])
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindSplitsBeforeSections(pItem[2])

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForms

		def FindSplitsBeforeCSZ(pItem, pCaseSensitive)
			return This.FindSplitsBeforeCS(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBefore(pItem)
		return This.FindSplitsBeforeCS(pItem, TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsBeforeZ(pItem)
			return This.FindSplitsBefore(pItem)

		#>

	  #--------------------------------------------#
	 #   FINDING SPLITS BEFORE A GIVEN POSITION   #
	#============================================#

	def FindSplitsBeforePositionCS(n, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		acSplits = This.SplitsBeforePosition(n)
		anResult = This.FindManyCS(acSplits, pCaseSensitive)
		return anResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeThisPositionCS(n, pCaseSensitive)
			return This.FindSplitsBeforePositionCS(n, pCaseSensitive)

		#--

		def FindSplitsBeforePositionCSZ(n, pCaseSensitive)
			return This.FindSplitsBeforePositionCS(n, pCaseSensitive)

		def FindSplitsBeforeThisPositionCSZ(n, pCaseSensitive)
			return This.FindSplitsBeforePositionCS(n, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforePosition(n)
		return This.FindSplitsBeforePositionCS(n, TRUE)

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
	#==========================================#

	def FindSplitsBeforePositionsCS(anPos, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
				StzRaise("Incorrect param type! anPos must be a list of numbers.")
			ok

		ok

		acSplits = This.SplitsBeforePositionsCS(anPos)
		anResult = This.FindManyCS(acSplits, pCaseSensitive)

		return anResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeThesePositionsCS(anPos, pCaseSensitive)
			return This.FindSplitsBeforePositionsCS(anPos, pCaseSensitive)

		def FindSplitsBeforeManyPositionsCS(anPos, pCaseSensitive)
			return This.FindSplitsBeforePositionsCS(anPos, pCaseSensitive)

		#--

		def FindSplitsBeforePositionsCSZ(anPos, pCaseSensitive)
			return This.FindSplitsBeforePositionsCS(anPos, pCaseSensitive)

		def FindSplitsBeforeThesePositionsCSZ(anPos, pCaseSensitive)
			return This.FindSplitsBeforePositionsCS(anPos, pCaseSensitive)

		def FindSplitsBeforeManyPositionsCSZ(anPos, pCaseSensitive)
			return This.FindSplitsBeforePositionsCS(anPos, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforePositions(anPos)
		return This.FindSplitsBeforePositionsCS(anPos, TRUE)

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
	 #   FINDING SPLITS BEFORE A GIVEN Item   #
	#---------------------------------------------#

	def FindSplitsBeforeItemCS(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isString(pItem)
			StzRaise("Incorrect param type! pItem must be a string.")
		ok

		anPos = This.FindCS(pItem, pCaseSensitive)
		aResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsBeforePositions(anPos)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisItemCS(pItem, pCaseSensitive)
			return This.FindSplitsBeforeItemCS(pItem, pCaseSensitive)

		#--

		def FindSplitsBeforeItemCSZ(pItem, pCaseSensitive)
			return This.FindSplitsBeforeItemCS(pItem, pCaseSensitive)

		def FindSplitsBeforeThisItemCSZ(pItem, pCaseSensitive)
			return This.FindSplitsBeforeItemCS(pItem, pCaseSensitive)

		#>
				
	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeItem(pItem)
		return This.FindSplitsBeforeItemCS(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisItem(pItem)
			return This.FindSplitsBeforeItem(pItem)

		#--

		def FindSplitsBeforeItemZ(pItem)
			return This.FindSplitsBeforeItem(pItem)

		def FindSplitsBeforeThisItemZ(pItem)
			return This.FindSplitsBeforeItem(pItem)	

		#>

	  #-------------------------------------------#
	 #   FINDING SPLITS BEFORE MANY Items   #
	#-------------------------------------------#

	def FindSplitsBeforeItemsCS(paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paItems) and Q(paItems).IsListOfStrings() )
			StzRaise("Incorrect param type! paItems must be a list of strings.")
		ok

		anPos = This.FindCS( paItems, pCaseSensitive )
		aResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsBeforePositions(anPos)

		return anResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseItemsCS(paItems, pCaseSensitive)
			return This.FindSplitsBeforeItemsCS(paItems, pCaseSensitive)

		def FindSplitsBeforeManyItemsCS(paItems, pCaseSensitive)
			return This.FindSplitsBeforeItemsCS(paItems, pCaseSensitive)

		#--

		def FindSplitsBeforeItemsCSZ(paItems, pCaseSensitive)
			return This.FindSplitsBeforeItemsCS(paItems, pCaseSensitive)

		def FindSplitsBeforeTheseItemsCSZ(paItems, pCaseSensitive)
			return This.FindSplitsBeforeItemsCS(paItems, pCaseSensitive)

		def FindSplitsBeforeManyItemsCSZ(paItems, pCaseSensitive)
			return This.FindSplitsBeforeItemsCS(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeItems(paItems)
		return This.FindSplitsBeforeItemsCS(paItems, TRUE)
	
		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseItems(paItems)
			return This.FindSplitsBeforeItems(paItems)

		def FindSplitsBeforeManyItems(paItems)
			return This.FindSplitsBeforeItems(paItems)

		#--

		def FindSplitsBeforeItemsZ(paItems)
			return This.FindSplitsBeforeItems(paItems)

		def FindSplitsBeforeTheseItemsZ(paItems)
			return This.FindSplitsBeforeItems(paItems)

		def FindSplitsBeforeManyItemsZ(paItems)
			return This.FindSplitsBeforeItems(paItems)

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

		aResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsBeforeSection(n1, n2)
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

		aResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsBeforeSectionIB(n1, n2)
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

		aResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsBeforeSections(paSections)
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

	  #-----------------------------------------------------------#
	 #   FINDING SPLITS BEFORE MANY SECTIONS -- INCLUDING BOUND  #
	#-----------------------------------------------------------#

	def FindSplitsBeforeSectionsIB(paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		anResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsBeforeSectionsIB(paSections)
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
	 #   FINDING SPLITS AFTER A GIVEN ITEM  #
	#-------------------------------------------------------#

	def FindSplitsAfterCS(pItem, pCaseSensitive)
		if isString(pItem)
			return This.FindSplitsAfterItemCS(pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindSplitsAfterPosition(pItem)

		but isList(pItem)

			#-- Case when named params are provided

			if Q(pItem).IsOneOfTheseNamedParams([ :Position, :ThisPosition ])

				return This.FindSplitsAfterPosition(pItem[2])
	
			but Q(pItem).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindSplitsAfterPositions(pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindSplitsAfterItemCS(pItem[2], pCaseSensitive)
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindSplitsAfterItemsCS(pItem[2], pCaseSensitive)

			but Q(pItem).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindSplitsAfterSection(pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindSplitsAfterSections(pItem[2])

			#-- Providing numbers, strings, or pairs of numbers,
			#   directly without named params

			but Q(pItem).IsListOfNumbers()
				return This.FindSplitsAfterPositions(pItem)

			but Q(pItem).IsListOfStrings()
				return This.FindSplitsAfterItems(pItem)

			but Q(pItem).IsListOfPairsOfNumbers()
				return This.FindSplitsAfterSections(pItem)

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindSplitsAfterCSZ(pItem, pCaseSensitive)
			return This.FindSplitsAfterCS(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfter(pItem)
		return This.FindSplitsAfterCS(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterZ(pItem)
			return This.FindSplitsAfterCS(pItem, pCaseSensitive)

		#>

	  #--------------------------------------------#
	 #   FINDING SPLITS BEFORE A GIVEN POSITION   #
	#--------------------------------------------#

	def FindSplitsAfterPosition(n)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		anResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsAfterPosition(n)
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

		anResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsAfterPositions(anPos)
		return anResult

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
	 #   FINDING SPLITS BEFORE A GIVEN Item   #
	#---------------------------------------------#

	def FindSplitsAfterItemCS(pItem, pCaseSensitive)
		if NOT isString(pItem)
			StzRaise("Incorrect param type! pItem must be a string.")
		ok

		anPos = This.FindCS(pItem, pCaseSensitive)
		anResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsAfterPositions(anPos)
		return anResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisItemCS(pItem, pCaseSensitive)
			return This.FindSplitsAfterItemCS(pItem, pCaseSensitive)

		#--

		def FindSplitsAfterItemCSZ(pItem, pCaseSensitive)
			return This.FindSplitsAfterItemCS(pItem, pCaseSensitive)

		def FindSplitsAfterThisItemCSZ(pItem, pCaseSensitive)
			return This.FindSplitsAfterItemCS(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterItem(pItem)
		return This.FindSplitsAfterItemCS(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisItem(pItem)
			return This.FindSplitsAfterItem(pItem)

		#--

		def FindSplitsAfterItemZ(pItem)
			return This.FindSplitsAfterItem(pItem)

		def FindSplitsAfterThisItemZ(pItem)
			return This.FindSplitsAfterItem(pItem)

		#>

	  #-------------------------------------------#
	 #   FINDING SPLITS BEFORE MANY Items   #
	#-------------------------------------------#

	def FindSplitsAfterItemsCS(paItems, pCaseSensitive)
		if NOT ( isList(paItems) and Q(paItems).IsListOfStrings() )
			StzRaise("Incorrect param type! paItems must be a list of strings.")
		ok

		anPos = This.FindCS( paItems, pCaseSensitive )
		anResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsAfterPositions(anPos)
		return anResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterTheseItemsCS(paItems, pCaseSensitive)
			return This.FindSplitsAfterItemsCS(paItems, pCaseSensitive)

		def FindSplitsAfterManyItemsCS(paItems, pCaseSensitive)
			return This.FindSplitsAfterItemsCS(paItems, pCaseSensitive)

		#--

		def FindSplitsAfterItemsCSZ(paItems, pCaseSensitive)
			return This.FindSplitsAfterItemsCS(paItems, pCaseSensitive)

		def FindSplitsAfterTheseItemsCSZ(paItems, pCaseSensitive)
			return This.FindSplitsAfterItemsCS(paItems, pCaseSensitive)

		def FindSplitsAfterManyItemsCSZ(paItems, pCaseSensitive)
			return This.FindSplitsAfterItemsCS(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterItems(paItems)
		return This.FindSplitsAfterItemsCS(paItems, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterTheseItems(paItems)
			return This.FindSplitsAfterItems(paItems)

		def FindSplitsAfterManyItems(paItems)
			return This.FindSplitsAfterItems(paItems)

		#--

		def FindSplitsAfterItemsZ(paItems)
			return This.FindSplitsAfterItems(paItems)

		def FindSplitsAfterTheseItemsZ(paItems)
			return This.FindSplitsAfterItems(paItems)

		def FindSplitsAfterManyItemsZ(paItems)
			return This.FindSplitsAfterItems(paItems)

		#>

	  #-----------------------------------------#
	 #   FINDING SPLITS AFTER A GIVEN SECTION  #
	#-----------------------------------------#

	def FindSplitsAfterSection(n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		anResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsAfterSection(n1 , n2)
		return anResult

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

		anResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsAfterSectionIB(n1 , n2)
		return anResult

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

		anResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsAfterSections(paSections)
		return anResult

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

		anResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsAfterSectionsIB(paSections)
		return anResult

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
	 #  FINDING SPLITS BETWEEN TWO POSITIONS OR Items  #
	#======================================================#

	def FindSplitsBetweenCS(pItem1, pItem2, pCaseSensitive)
		anFirstBounds  = This.FindAllCS(pItem1, pCaseSensitive)
		anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

		aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
		anFirstBounds  = aListOfBounds[1]
		anSecondBounds = aListOfBounds[2]

		aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)

		anResult = StzSplitterQ( This.NumberOfItems() ).
			   FindSplitsBetweenSections(aSections)
			
		return anResult

		#< @FunctionAlternativeForm

		def FindSplitsBetweenCSZ(pItem1, pItem2, pCaseSensitive)
			return This.FindSplitsBetweenCS(pItem1, pItem2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetween(pItem1, pItem2)
		return This.FindSplitsBetweenCS(pItem1, pItem2, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsBetweenZ(pItem1, pItem2)
			return This.FindSplitsBetween(pItem1, pItem2)

		#>

	  #---------------------------------------------------------------------#
	 #  FINDING SPLITS BETWEEN TWO POSITIONS OR Items -- INCLUDING BOUNDS  #
	#---------------------------------------------------------------------#

	def FindSplitsBetweenCSIB(pItem1, pItem2, pCaseSensitive)

		anFirstBounds  = This.FindAllCS(pItem1, pCaseSensitive)
		anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

		aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
		anFirstBounds  = aListOfBounds[1]
		anSecondBounds = aListOfBounds[2]

		nLen = len(anFirstBounds)
		for i = 1 to nLen
			anFirstBounds[i]--
			anSecondBounds[i]++
		next

		aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)

		anResult = StzSplitterQ( This.NumberOfItems() ).
			   FindSplitsBetweenSections(aSections)
	
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBetweenCSIBZ(pItem1, pItem2, pCaseSensitive)
			return This.FindSplitsBetweenCSIB(pItem1, pItem2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetweenIB(pItem1, pItem2)
		return This.FindSplitsBetweenCSIB(pItem1, pItem2, TRUE)


		#< @FunctionAlternativeForm

		def FindSplitsBetweenIBZ(pItem1, pItem2)
			return This.FindSplitsBetweenIB(pItem1, pItem2)

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
	 #  FINDING SPLITS BETWEEN TWO Items  #
	#-----------------------------------------#

	def FindSplitsBetweenItemsCS(paItems, pCaseSensitive)
		aSections = This.Find(paItems, pCaseSensitive)
		anResult = This.FindSplitsBetweenSections(aSections)
		return anResult

		#< @FunctionAlternativeForms

		def FindSplitsBetweenTheseItemsCS(paItems, pCaseSensitive)
			return This.FindSplitsBetweenItemsCS(paItems, pCaseSensitive)

		#--

		def FindSplitsBetweenItemsCSZ(paItems, pCaseSensitive)
			return This.FindSplitsBetweenItemsCS(paItems, pCaseSensitive)

		def FindSplitsBetweenTheseItemsCSZ(paItems, pCaseSensitive)
			return This.FindSplitsBetweenItemsCS(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetweenItems(paItems)
		return This.FindSplitsBetweenItemsCS(paItems, TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsBetweenTheseItems(paItems)
			return This.FindSplitsBetweenItems(paItems)

		#--

		def FindSplitsBetweenItemsZ(paItems)
			return This.FindSplitsBetweenItems(paItems)

		def FindSplitsBetweenTheseItemsZ(paItems)
			return This.FindSplitsBetweenItems(paItems)

		#>

	  #---------------------------------#
	 #    FINDING SPLITS TO N PARTS    #
	#=================================#

	def FindSplitsToNParts(n)
		anResult = StzSplitterQ( This.NumberOfItems() ).FindSplitsToNParts(n)
		return anResult

		def FindSplitsToNPartsZ(n)
			return This.FindSplitsToNParts(n)

	  #--------------------------------------------------#
	 #   FINDING SPLITS TO PARTS OF (EXACTLY) N Items   #
	#--------------------------------------------------#
	# Remaining part less the n Items is not returned

	def FindSplitsToPartsOfNItems(n)
		anResult = StzSplitterQ( This.NumberOfItems() ).
				FindSplitsToPartsOfExactlyNPositions(n)

		return anResult

		#< @FunctionAlternativeForm

		def FindSplitsToPartsOfExactlyNItems(n)
			return This.FindSplitsToPartsOfNItems(n)

		#--

		def FindSplitsToPartsOfNItemsZ(n)
			return This.FindSplitsToPartsOfNItems(n)

		def FindSplitsToPartsOfExactlyNItemsZ(n)
			return This.FindSplitsToPartsOfNItems(n)

		#>

	  #----------------------------------------------------#
	 #   FINDING SPLITS TO PARTS OF N Items -- EXTENDED   #
	#----------------------------------------------------#
	# The remaing part (if any) less then n Items is also returned

	def FindSplitsToPartsOfNItemsXT(n)
		anResult = StzSplitterQ( This.NumberOfItems() ).
				FindSplitsToPartsOfNPositionsXT(n)

		return anResult

		def FindSplitsToPartsOfNItemsXTZ(n)
			return This.FindSplitsToPartsOfNItemsXT(n)

	  #-------------------------------------------#
	 #   FINDING SPLITS UNDER A GIVEN CONDTION   #
	#===========================================#

	def FindSplitsW(pcCondition)

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

		pcCondition = Q(pcCondition).TrimQ().TheseBoundsRemoved( "{","}" )

		if Q(pcCondition).ContainsCS("@Item", :CS = FALSE)

			aSections = This.FindItemsW(pcCondition)
			anResult = This.FindSplitsAtSectionsZ(aSections)

		else

			anPos = This.FindW(pcCondition)
			anResult = This.FindSplitsAtPositionsZ(anPos)
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

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsW(pcCondition)

		else
			anPos = This.FindItemsW(pcCondition)
		ok

		anResult = This.FindSplitsBeforePositions(anPos)

		return anResult

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

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsW(pcCondition)

		else
			anPos = This.FindItemsW(pcCondition)
		ok

		anResult = This.FindSplitsAfterPositions(anPos)

		return anResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterWZ(pcCondition)
			return This.FindSplitsAfterW(pcCondition)

		#>

	  #==================================================#
	 #   FINDING THE SPLITS AS SECTIONS -- ZZ/EXTENDED  #
	#==================================================#

	def FindSplitsCSXTZZ(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pItem)
			return This.FindSplitsAtItemCSZZ(pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindSplitsAtPositionZZ(pItem)

		but isList(pItem) and Q(pItem).IsListOfNumbers()
			return This.FindSplitsAtPositionsZZ(pItem)

		but isList(pItem) and Q(pItem).IsPairOfNumbers()
			return This.FindSplitsAtSectionZZ(pItem[1], pItem[2])

		but isList(pItem) and Q(pItem).IsListOfPairsOfNumbers()
			return This.FindSplitsAtSectionsZZ(pItem)

		but isList(pItem)

			oParam = Q(pItem)

			#-- SPLITTING AT / USING

			if oParam.IsOneOfTheseNamedParams([ :At, :Using ])
				return This.FindSplitsAtCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtPosition, :AtThisPosition ]) 
				return This.FindSplitsAtPositionZZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AtPositions, :AtThesePositions ]) 
				return This.FindSplitsAtPositionsZZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([
						:AtItem, :AtThisItem,
						:UsingItem, :UsingThisItem ]) 

				return This.FindSplitsAtItemCSZZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([
						:AtItems, :AtTheseItems,
						:UsingItems, :UsingTheseItems ]) 

				return This.FindSplitsAtItemsCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtSection, :AtThisSection ]) 
				return This.FindSplitsAtSectionZZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AtSections, :AtTheseSections ]) 
				return This.FindSplitsAtSectionsZZ(pItem[2])

			#-- SPLITTING BEFORE

			but oParam.IsBeforeNamedParam()
				return This.FindSplitsBeforeCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforePosition, :BeforeThisPosition ]) 
				return This.FindSplitsBeforePositionZZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :BeforePositions, :BeforeThesePositions ]) 
				return This.FindSplitsBeforePositionsZZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :BeforeItem, :BeforeThisItem ]) 
				return This.FindSplitsBeforeItemCSZZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeItems, :BeforeTheseItems ]) 
				return This.SplitBeforeItemsCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforeSection, :BeforeThisSection ]) 
				return This.FindSplitsBeforeSectionZZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeSections, :BeforeTheseSections ]) 
				return This.FindSplitsBeforeSectionsZZ(pItem[2])

			#-- SPLITTING AFTER

			but oParam.IsAfterNamedParam()
				return This.FindSplitsAfterCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterPosition, :AfterThisPosition ]) 
				return This.FindSplitsAfterPositionZZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AfterPositions, :AfterThesePositions ]) 
				return This.FindSplitsAfterPositionsZZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :AfterItem, :AfterThisItem ]) 
				return This.FindSplitsAfterItemCSZZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :AfterItems, :AfterTheseItems ]) 
				return This.FindSplitsAfterItemsCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterSection, :AfterThisSection ]) 
				return This.FindSplitsAfterSectionZZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AfterSections, :AfterTheseSections ]) 
				return This.FindSplitsAfterSectionsZZ(pItem[2])

			# SPLITTING BETWEEN

			but oParam.IsBetweenNamedParam() and
				isList(pItem) and len(pItem) = 2
				
				if isList(pItem[2]) and Q(pItem[2]).IsAndNamedParam()
					pItem[2] = pItem[2][2]
				ok

				return This.FindSplitsBetweenCSZZ(pItem[1], pItem[2], pCaseSensitive)

			but oParam.IsBetweenPositionsNamedParam()
				return This.FindSplitsBetweenPositionsZZ(pItem[1], pItem[2])

			but oParam.IsBetweenItemsNamedParam()
				return This.FindSplitsBetweenItemsCSZZ(pItem[1], pItem[2], pCaseSensitive)

			# SPLITTING TO PARTS

			but oParam.IsToNPartsNamedParam()
				return This.FindSplitsToNPartsZZ(pItem[2])

			but oParam.IsToPartsOfNItemsNamedParam()
				return This.FindSplitsToPartsOfNItemsZZ(pItem[2])

			# SPLITTING WHERE

			but oParam.IsWhereOrAtWhereNamedParam()
				return This.FindSplitsAtWZZ(pItem[2])

			but oParam.IsBeforeWhereNamedParam()
				return This.FindSplitsBeforeWZZ(pItem[2])

			but oParam.IsAfterWhereNamedParam()
				return This.FindSplitsAfterWZZ(pItem[2])

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindSplitsAsSectionsCSXT(pItem, pCaseSensitive)
			return This.FindSplitsAsSectionsCSXTZZ(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsXTZZ(pItem)
		return This.FindSplitsCSXTZZ(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAsSectionsAsSectionsXT(pItem)
			return This.FindSplitsAsSectionsXTZZ(pItem)

		#>

	  #------------------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AT A GIVEN Item  #
	#==================================================================#

	def FindSplitsAtCSZZ(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isList(pItem)
			return This.FindSplitsAtItemCSZZ(pItem, pCaseSensitive)

		else

			oParam = Q(pItem)

			#-- Case when named params are provided

			if oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindSplitsAtPositionZZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindSplitsAtPositionsZZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindSplitsAtItemCSZZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindSplitsAtItemsCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindSplitsAtSectionZZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindSplitsAtSectionsZZ(pItem[2])

			else
				return This.FindSplitsAtItemCSZZ(pItem, pCaseSensitive)
			ok

		ok

		#< @FunctionAlternativeForm

		def FindSplitsAtAsSectionsCS(pItem, pCaseSensitive)
			return This.FindSplitsAtCSZZ(pSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtZZ(pItem)
		return This.FindSplitsAtCSZZ(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAtAsSections(pItem)
			return This.FindSplitsAtCSZZ(pSubStr)

		#>

	  #------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AT A GIVEN POSITION   #
	#======================================================#

	def FindSplitsAtPositionCSZZ(n, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()
	
			if NOT isNumber(n)
				StzRaise("Incorrect pram type! n must be a number.")
			ok

		ok

		acSplits = This.SplitsAtPosition(n)
		aResult = This.FindManyAsSections(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAtThisPositionAsSectionsCS(n, pCaseSensitive)
			return This.FindSplitsAtPositionCSZZ(n, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtPositionZZ(n)
		return This.FindSplitsAtPositionCSZZ(n, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAtThisPositionAsSections(n)
			return This.FindSplitsAtPositionZZ(n)

		#>

	  #----------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AT MANY POSITIONS   #
	#----------------------------------------------------#

	def FindSplitsAtPositionsCSZZ(anPos, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
				StzRaise("Incorrect param type! anPos must be a list of numbers.")
			ok
		ok

		acSplits = This.SplitsAtPositions(anPos)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAtThesePositionsCSZZ(anPos, pCaseSensitive)
			return This.FindSplitsAtPositionsCSZZ(anPos, pCaseSensitive)

		def FindSplitsAtManyPositionsCSZZ(anPos, pCaseSensitive)
			return This.FindSplitsAtPositionsCSZZ(anPos, pCaseSensitive)

		#--

		def FindSplitsAtPositionsAsSectionsCS(anPos, pCaseSensitive)
			return This.FindSplitsAtPositionsCSZZ(anPos, pCaseSensitive)

		def FindSplitsAtThesePositionsAsSectionsCS(anPos, pCaseSensitive)
			return This.FindSplitsAtPositionsCSZZ(anPos, pCaseSensitive)

		def FindSplitsAtManyPositionsAsSectionsCS(anPos, pCaseSensitive)
			return This.FindSplitsAtPositionsCSZZ(anPos, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtPositionsZZ(anPos)
		return This.FindSplitsAtPositionsCSZZ(anPos, TRUE)

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
	 #   FINDING SPLITS (AS SECTIONS) AT A GIVEN Item   #
	#=======================================================#

	def FindSplitsAtItemCSZZ(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		acSplits = This.SplitsAtItemCS(pItem, pCaseSensitive)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsCSZZ(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindSplitsAtItemCSZZ(pItem, pCaseSensitive)

		def FindSplitsAtThisItemCSZZ(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindSplitsAtItemCSZZ(pItem, pCaseSensitive)

		#--

		def FindSplitsAtItemAsSectionsCSZZ(pItem, pCaseSensitive)
			return This.FindSplitsAtItemCSZZ(pItem, pCaseSensitive)

		def FindSplitsAsSectionsCS(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindSplitsAtItemCSZZ(pItem, pCaseSensitive)

		def FindSplitsAtThisItemAsSectionsCS(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindSplitsAtItemCSZZ(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtItemZZ(pItem)
		return This.FindSplitsAtItemCSZZ(pItem, TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsZZ(pItem)
			return This.FindSplitsCSZZ(pItem, TRUE)

		def FindSplitsAtThisItemZZ(pItem)
			return This.FindSplitsAtThisItemCSZZ(pItem, TRUE)
		#--

		def FindSplitsAtItemAsSectionsZZ(pItem)
			return This.FindSplitsAtItemAsSectionsCSZZ(pItem, TRUE)

		def FindSplitsAsSections(pItem)
			return This.FindSplitsAsSectionsCS(pItem, TRUE)

		def FindSplitsAtThisItemAsSections(pItem)
			return This.FindSplitsAtThisItemAsSectionsCS(pItem, TRUE)

		#>


	  #------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AT GIVEN Items   #
	#------------------------------------------------------#

	def FindSplitsAtItemsCSZZ(paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		acSplits = This.SplitsAtItemsCS(paItems, pCaseSensitive)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseItemsCSZZ(paItems, pCaseSensitive)
			return This.FindSplitsAtItemsCSZZ(paItems, pCaseSensitive)

		def FindSplitsAtManyItemsCSZZ(paItems, pCaseSensitive)
			return This.FindSplitsAtItemsCSZZ(paItems, pCaseSensitive)

		#--

		def FindSplitsAtItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindSplitsAtItemsCSZZ(paItems, pCaseSensitive)

		def FindSplitsAtTheseItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindSplitsAtItemsCSZZ(paItems, pCaseSensitive)

		def FindSplitsAtManyItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindSplitsAtItemsCSZZ(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtItemsZZ(paItems)
		return This.FindSplitsAtItemsCSZZ(paItems, TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseItemsZZ(paItems)
			return This.FindSplitsAtItemsZZ(paItems)
	
		def FindSplitsAtManyItemsZZ(paItems)
			return This.FindSplitsAtItemsZZ(paItems)

		#--

		def FindSplitsAtItemsAsSections(paItems)
			return This.FindSplitsAtItemsZZ(paItems)

		def FindSplitsAtTheseItemsAsSections(paItems)
			return This.FindSplitsAtItemsZZ(paItems)

		def FindSplitsAtManyItemsAsSections(paItems)
			return This.FindSplitsAtItemsZZ(paItems)

		#>

	  #-----------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) AT A GIVEN SECTION   #
	#=====================================================#

	def FindSplitsAtSectionCSZZ(n1, n2, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		acSplits = This.SplitsAtSection(n1, n2)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAtThisSectionCSZZ(n1, n2, pCaseSensitive)
			return This.FindSplitsAtSectionCSZZ(n1, n2, pCaseSensitive)

		#--

		def FindSplitsAtSectionAsSectionsCS(n1, n2, pCaseSensitive)
			return This.FindSplitsAtSectionCSZZ(n1, n2, pCaseSensitive)

		def FindSplitsAtThisSectionAsSectionsCS(n1, n2, pCaseSensitive)
			return This.FindSplitsAtSectionCSZZ(n1, n2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtSectionZZ(n1, n2)
		return This.FindSplitsAtSectionCSZZ(n1, n2, TRUE)

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

	def FindSplitsAtSectionCSIBZZ(n1, n2, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()
			if NOT @BothAreNumbers(n1, n2)
				StzRaise("Incorrect param type! n1 and n2 must be numbers.")
			ok
		ok

		acSplits = This.SplitsAtSectionIB(n1, n2)
		aResult = This.FindManyAsSectionsCSIB(n1, n2, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAtThisSectionCSIBZZ(n1, n2, pCaseSensitive)
			return This.SplitAtSectionCSIBZZ(n1, n2, pCaseSensitive)

		#--

		def FindSplitsAtSectionAsSectionsCSIB(n1, n2, pCaseSensitive)
			return This.FindSplitsAtSectionCSIBZZ(n1, n2, pCaseSensitive)

		def FindSplitsAtThisSectionAsSectionsCSIB(n1, n2, pCaseSensitive)
			return This.SplitAtSectionCSIBZZ(n1, n2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtSectionIBZZ(n1, n2)
		return This.FindSplitsAtSectionCSIBZZ(n1, n2, TRUE)

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

	def FindSplitsAtSectionsCSZZ(paSections, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
				StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
			ok

		ok

		acSplits = This.SplitsAtSections(paSections)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAtTheseSectionsCSZZ(paSections, pCaseSensitive)
			return This.FindSplitsAtSectionsCSZZ(paSections, pCaseSensitive)

		#--

		def FindSplitsAtSectionsAsSectionsCS(paSections, pCaseSensitive)
			return This.FindSplitsAtSectionsCSZZ(paSections, pCaseSensitive)

		def FindSplitsAtTheseSectionsAsSectionsCS(paSections, pCaseSensitive)
			return This.FindSplitsAtSectionsCSZZ(paSections, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtSectionsZZ(paSections, pCaseSensitive)
		return This.FindSplitsAtSectionsCSZZ(paSections, pCaseSensitive)

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
	 #   FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN ITEM   #
	#-----------------------------------------------------------------------#

	def FindSplitsBeforeCSZZ(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isList(pItem)
			return This.FindSplitsBeforeItemCSZZ(pItem, pCaseSensitive)

		else

			#-- Case when named params are provided

			if Q(pItem).IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindSplitsBeforePositionZZ(pItem[2])
	
			but Q(pItem).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindSplitsBeforePositionsZZ(pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindSplitsBeforeItemCSZZ(pItem[2], pCaseSensitive)
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindSplitsBeforeItemsCSZZ(pItem[2], pCaseSensitive)

			but Q(pItem).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindSplitsBeforeSectionZZ(pItem[2])
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindSplitsBeforeSectionsZZ(pItem[2])

			else
				return This.FindSplitsBeforeItemCSZZ(pItem, pCaseSensitive)
			ok
		ok

		#< @FunctionAlternativeForms

		def FindSplitsBeforeAsSectionsCS(pItem, pCaseSensitive)
			return This.FindSplitsBeforeCSZZ(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeZZ(pItem)
		return This.FindSplitsBeforeCSZZ(pItem, TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsBeforeAsSections(pItem)
			return This.FindSplitsBeforeZZ(pItem)

		#>

	  #----------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN POSITION   #
	#----------------------------------------------------------#

	def FindSplitsBeforePositionCSZZ(n, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

		ok

		acSplits = This.SplitsBeforePosition(n)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeThisPositionCSZZ(n, pCaseSensitive)
			return This.FindSplitsBeforePositionCSZZ(n, pCaseSensitive)

		#--

		def FindSplitsBeforePositionAsSectionsCS(n, pCaseSensitive)
			return This.FindSplitsBeforePositionCSZZ(n, pCaseSensitive)

		def FindSplitsBeforeThisPositionAsSectionsCS(n, pCaseSensitive)
			return This.FindSplitsBeforePositionCSZZ(n, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforePositionZZ(n)
		return This.FindSplitsBeforePositionCSZZ(n, TRUE)

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

	def FindSplitsBeforePositionsCSZZ(anPos, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
				StzRaise("Incorrect param type! anPos must be a list of numbers.")
			ok

		ok

		acSplits = This.SplitsBeforePositions(anPos)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeThesePositionsCSZZ(anPos, pCaseSensitive)
			return This.FindSplitsBeforePositionsCSZZ(anPos, pCaseSensitive)

		def FindSplitsBeforeManyPositionsCSZZ(anPos, pCaseSensitive)
			return This.FindSplitsBeforePositionsCSZZ(anPos, pCaseSensitive)

		#--

		def FindSplitsBeforePositionsAsSectionsCS(anPos, pCaseSensitive)
			return This.FindSplitsBeforePositionsCSZZ(anPos, pCaseSensitive)

		def FindSplitsBeforeThesePositionsAsSectionsCS(anPos, pCaseSensitive)
			return This.FindSplitsBeforePositionsCSZZ(anPos, pCaseSensitive)

		def FindSplitsBeforeManyPositionsAsSectionsCS(anPos, pCaseSensitive)
			return This.FindSplitsBeforePositionsCSZZ(anPos, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforePositionsZZ(anPos)
		return This.FindSplitsBeforePositionsCSZZ(anPos, TRUE)

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
	 #   FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN Item   #
	#-----------------------------------------------------------#

	def FindSplitsBeforeItemCSZZ(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		acSplits = This.SplitsBeforeItemCS(pItem, pCaseSensitive)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult


		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisItemCSZZ(pItem, pCaseSensitive)
			return This.FindSplitsBeforeItemCSZZ(pItem, pCaseSensitive)

		#--

		def FindSplitsBeforeItemAsSectionsCS(pItem, pCaseSensitive)
			return This.FindSplitsBeforeItemCSZZ(pItem, pCaseSensitive)

		def FindSplitsBeforeThisItemAsSectionsCS(pItem, pCaseSensitive)
			return This.FindSplitsBeforeItemCSZZ(pItem, pCaseSensitive)

		#>
				
	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeItemZZ(pItem)
		return This.FindSplitsBeforeItemCSZZ(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisItemZZ(pItem)
			return This.FindSplitsBeforeItem(pItem)

		#--

		def FindSplitsBeforeItemAsSections(pItem)
			return This.FindSplitsBeforeItemZZ(pItem)

		def FindSplitsBeforeThisItemAsSections(pItem)
			return This.FindSplitsBeforeItemZZ(pItem)	

		#>

	  #---------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE MANY Items   #
	#---------------------------------------------------------#

	def FindSplitsBeforeItemsCSZZ(paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		acSplits = This.SplitsBeforeItemsCS(paItems, pCaseSensitive)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult


		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseItemsCSZZ(paItems, pCaseSensitive)
			return This.FindSplitsBeforeItemsCSZZ(paItems, pCaseSensitive)

		def FindSplitsBeforeManyItemsCSZZ(paItems, pCaseSensitive)
			return This.FindSplitsBeforeItemsCSZZ(paItems, pCaseSensitive)

		#--

		def FindSplitsBeforeItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindSplitsBeforeItemsCSZZ(paItems, pCaseSensitive)

		def FindSplitsBeforeTheseItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindSplitsBeforeItemsCSZZ(paItems, pCaseSensitive)

		def FindSplitsBeforeManyItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindSplitsBeforeItemsCSZZ(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeItemsZZ(paItems)
		return This.FindSplitsBeforeItemsCSZZ(paItems, TRUE)
	
		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseItemsZZ(paItems)
			return This.FindSplitsBeforeItemsZZ(paItems)

		def FindSplitsBeforeManyItemsZZ(paItems)
			return This.FindSplitsBeforeItemsZZ(paItems)

		#--

		def FindSplitsBeforeItemsAsSections(paItems)
			return This.FindSplitsBeforeItemsZZ(paItems)

		def FindSplitsBeforeTheseItemsAsSections(paItems)
			return This.FindSplitsBeforeItemsZZ(paItems)

		def FindSplitsBeforeManyItemsAsSections(paItems)
			return This.FindSplitsBeforeItemsZZ(paItems)

		#>

	  #---------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN SECTION   #
	#---------------------------------------------------------#

	def FindSplitsBeforeSectionCSZZ(n1, n2, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT BothAreNumbers(n1, n2)
				StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
			ok

		ok

		acSplits = This.SplitsBeforeSection(n1, n2)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisSectionCSZZ(n1, n2, pCaseSensitive)
			return This.FindSplitsBeforeSectionCSZZ(n1, n2, pCaseSensitive)

		#--

		def FindSplitsBeforeSectionAsSectionsCS(n1, n2, pCaseSensitive)
			return This.FindSplitsBeforeSectionCSZZ(n1, n2, pCaseSensitive)

		def FindSplitsBeforeThisSectionAsSectionsCS(n1, n2, pCaseSensitive)
			return This.FindSplitsBeforeSectionCSZZ(n1, n2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeSectionZZ(n1, n2)
		return This.FindSplitsBeforeSectionCSZZ(n1, n2, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisSectionZZ(n1, n2)
			return This.FindSplitsBeforeSectionZZ(n1, n2)

		#--

		def FindSplitsBeforeSectionAsSections(n1, n2)
			return This.FindSplitsBeforeSectionZZ(n1, n2)

		def FindSplitsBeforeThisSectionAsSections(n1, n2)
			return This.FindSplitsBeforeSectionZZ(n1, n2)

		#>

	  #----------------------------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN SECTION -- INCLUDING BOUND   #
	#----------------------------------------------------------------------------#

	def FindSplitsBeforeSectionCSIBZZ(n1, n2, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT BothAreNumbers(n1, n2)
				StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
			ok

		ok

		acSplits = This.SplitsBeforeSectionIB(n1, n2)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBeforeThisSectionCSIBZZ(n1, n2, pCaseSensitive)
			return This.FindSplitsBeforeSectionCSIBZZ(n1, n2, pCaseSensitive)

		#--

		def FindSplitsBeforeSectionAsSectionsCSIB(n1, n2, pCaseSensitive)
			return This.FindSplitsBeforeSectionCSIBZZ(n1, n2, pCaseSensitive)

		def FindSplitsBeforeThisSectionAsSectionsCsIB(n1, n2, pCaseSensitive)
			return This.FindSplitsBeforeSectionCSIBZZ(n1, n2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeSectionIBZZ(n1, n2)
		return This.FindSplitsBeforeSectionCSIBZZ(n1, n2, TRUE)

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

	def FindSplitsBeforeSectionsCSZZ(paSections, pCaseSensitive)

		if CheckParams()

			if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
				StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
			ok

		ok

		acSplits = This.SplitsBeforeSections(paSections)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseSectionsCSZZ(paSections, pCaseSensitive)
			return This.FindSplitsBeforeSectionsCSZZ(paSections, pCaseSensitive)

		def FindSplitsBeforeManySectionsCSZZ(paSections, pCaseSensitive)
			return This.SplitBeforeSectionsCSZZ(paSections, pCaseSensitive)

		#--

		def FindSplitsBeforeSectionsAsSectionsCS(paSections, pCaseSensitive)
			return This.FindSplitsBeforeSectionsCSZZ(paSections, pCaseSensitive)

		def FindSplitsBeforeTheseSectionsAsSectionsCS(paSections, pCaseSensitive)
			return This.FindSplitsBeforeSectionsCSZZ(paSections, pCaseSensitive)

		def FindSplitsBeforeManySectionsAsSectionsCS(paSections, pCaseSensitive)
			return This.SplitBeforeSectionsCSZZ(paSections, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeSectionsZZ(paSections)
		return This.FindSplitsBeforeSectionsCSZZ(paSections, TRUE)

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

	  #-------------------------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE MANY SECTIONS -- INCLUDING BOUND  #
	#-------------------------------------------------------------------------#

	def FindSplitsBeforeSectionsCSIBZZ(paSections, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()
			if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
				StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
			ok
		ok

		acSplits = This.SplitsBeforeSectionsIB(paSections)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBeforeTheseSectionsCSIBZZ(paSections, pCaseSensitive)
			return This.FindSplitsBeforeSectionsCSIBZZ(paSections, pCaseSensitive)

		def FindSplitsBeforeManySectionsCSIBZZ(paSections, pCaseSensitive)
			return This.FindSplitsBeforeSectionsCSIBZZ(paSections, pCaseSensitive)

		#--

		def FindSplitsBeforeSectionsAsSectionsCSIB(paSections, pCaseSensitive)
			return This.FindSplitsBeforeSectionsCSIBZZ(paSections, pCaseSensitive)

		def FindSplitsBeforeTheseSectionsAsSectionsCSIB(paSections, pCaseSensitive)
			return This.FindSplitsBeforeSectionsCSIBZZ(paSections, pCaseSensitive)

		def FindSplitsBeforeManySectionsAsSectionsCSIB(paSections, pCaseSensitive)
			return This.FindSplitsBeforeSectionsCSIBZZ(paSections, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeSectionsIBZZ(paSections)
		return This.FindSplitsBeforeSectionsCSIBZZ(paSections, TRUE)

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
	 #   FINDING SPLITS (AS SECTIONS) AFTER A GIVEN ITEM  #
	#---------------------------------------------------------------------#

	def FindSplitsAfterCSZZ(pItem, pCaseSensitive)
		if NOT isList(pItem)
			return This.FindSplitsAfterItemCSZZ(pItem, pCaseSensitive)

		else

			#-- Case when named params are provided

			if Q(pItem).IsOneOfTheseNamedParams([ :Position, :ThisPosition ])

				return This.FindSplitsAfterPositionZZ(pItem[2])
	
			but Q(pItem).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindSplitsAfterPositionsZZ(pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindSplitsAfterItemCSZZ(pItem[2], pCaseSensitive)
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindSplitsAfterItemsCSZZ(pItem[2], pCaseSensitive)

			but Q(pItem).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindSplitsAfterSectionZZ(pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindSplitsAfterSectionsZZ(pItem[2])

			#-- Providing numbers, strings, or pairs of numbers,
			#   directly without named params

			but Q(pItem).IsListOfNumbers()
				return This.FindSplitsAfterPositionsZZ(pItem)

			but Q(pItem).IsListOfStrings()
				return This.FindSplitsAfterItemsZZ(pItem)

			but Q(pItem).IsListOfPairsOfNumbers()
				return This.FindSplitsAfterSectionsZZ(pItem)

			else
				return This.FindSplitsAfterItemCSZZ(pItem, pCaseSensitive)
			ok
		ok

		#< @FunctionAlternativeForm

		def FindSplitsAfterAsSectionsCS(pItem, pCaseSensitive)
			return This.FindSplitsAfterCSZZ(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterZZ(pItem)
		return This.FindSplitsAfterCSZZ(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterAsSections(pItem)
			return This.FindSplitsAfterCSZZ(pItem, pCaseSensitive)

		#>

	  #----------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN POSITION   #
	#----------------------------------------------------------#

	def FindSplitsAfterPositionCSZZ(n, pCaseSensitive)

		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

		ok

		acSplits = This.SplitsAfterPosition(n)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisPositionCSZZ(n, pCaseSensitive)
			return This.FindSplitsAfterPositionCSZZ(n, pCaseSensitive)

		def FindSplitsAfterThisPositionAsSectionsCS(n, pCaseSensitive)
			return This.FindSplitsAfterPositionCSZZ(n, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterPositionZZ(n)
		return This.FindSplitsAfterPositionCSZZ(n, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisPositionZZ(n)
			return This.FindSplitsAfterPositionZZ(n)

		def FindSplitsAfterThisPositionAsSections(n)
			return This.FindSplitsAfterPositionZZ(n)

		#>

	  #--------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE MANY POSITIONS   #
	#--------------------------------------------------------#

	def FindSplitsAfterPositionsCSZZ(anPos, pCaseSensitive)

		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
				StzRaise("Incorrect param type! anPos must be a list of numbers.")
			ok
		ok

		acSplits = This.plitsAfterPositions(anPos)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThesePositionsCSZZ(anPos, pCaseSensitive)
			return This.FindSplitsAfterThesePositionsCSZZ(anPos, pCaseSensitive)

		def FindSplitsAfterManyPositionsCSZZ(anPos, pCaseSensitive)
			return This.FindSplitsAfterManyPositionsCSZZ(anPos, pCaseSensitive)

		#--

		def FindSplitsAfterPositionsAsSectionsCS(anPos, pCaseSensitive)
			return This.FindSplitsAfterPositionsCSZZ(anPos, pCaseSensitive)

		def FindSplitsAfterThesePositionsAsSectionsCS(anPos, pCaseSensitive)
			return This.FindSplitsAfterThesePositionsCSZZ(anPos, pCaseSensitive)

		def FindSplitsAfterManyPositionsAsSectionsCS(anPos, pCaseSensitive)
			return This.FindSplitsAfterManyPositionsCSZZ(anPos, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterPositionsZZ(anPos)
		return This.FindSplitsAfterPositionsCSZZ(anPos, TRUE)

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
	 #   FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN Item   #
	#-----------------------------------------------------------#

	def FindSplitsAfterItemCSZZ(pItem, pCaseSensitive)

		if This.IsEmpty()
			return []
		ok

		acSplits = This.SplitsAfterItemCS(pItem, pCaseSensitive)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisItemCSZZ(pItem, pCaseSensitive)
			return This.FindSplitsAfterItemCSZZ(pItem, pCaseSensitive)

		#--

		def FindSplitsAfterItemAsSectionsCS(pItem, pCaseSensitive)
			return This.FindSplitsAfterItemCSZZ(pItem, pCaseSensitive)

		def FindSplitsAfterThisItemAsSectionsCS(pItem, pCaseSensitive)
			return This.FindSplitsAfterItemCSZZ(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterItemZZ(pItem)
		return This.FindSplitsAfterItemCSZZ(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisItemZZ(pItem)
			return This.FindSplitsAfterItemZZ(pItem)

		#--

		def FindSplitsAfterItemAsSections(pItem)
			return This.FindSplitsAfterItemZZ(pItem)

		def FindSplitsAfterThisItemAsSections(pItem)
			return This.FindSplitsAfterItemZZ(pItem)

		#>

	  #---------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) BEFORE MANY Items   #
	#---------------------------------------------------------#

	def FindSplitsAfterItemsCSZZ(paItems, pCaseSensitive)

		if This.IsEmpty()
			return []
		ok

		acSplits = This.SplitsAfterItemsCS(paItems, pCaseSensitive)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterTheseItemsCSZZ(paItems, pCaseSensitive)
			return This.FindSplitsAfterItemsCSZZ(paItems, pCaseSensitive)

		def FindSplitsAfterManyItemsCSZZ(paItems, pCaseSensitive)
			return This.FindSplitsAfterItemsCSZZ(paItems, pCaseSensitive)

		#--

		def FindSplitsAfterItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindSplitsAfterItemsCSZZ(paItems, pCaseSensitive)

		def FindSplitsAfterTheseItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindSplitsAfterItemsCSZZ(paItems, pCaseSensitive)

		def FindSplitsAfterManyItemsAsSectionsCSZZ(paItems, pCaseSensitive)
			return This.FindSplitsAfterItemsCSZZ(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterItemsZZ(paItems)
		return This.FindSplitsAfterItemsCSZZ(paItems, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterTheseItemsZZ(paItems)
			return This.FindSplitsAfterItemsZZ(paItems)

		def FindSplitsAfterManyItemsZZ(paItems)
			return This.FindSplitsAfterItemsZZ(paItems)

		#--

		def FindSplitsAfterItemsAsSections(paItems)
			return This.FindSplitsAfterItemsZZ(paItems)

		def FindSplitsAfterTheseItemsAsSections(paItems)
			return This.FindSplitsAfterItemsZZ(paItems)

		def FindSplitsAfterManyItemsAsSectionsZZ(paItems)
			return This.FindSplitsAfterItemsZZ(paItems)

		#>

	  #--------------------------------------------------------#
	 #   FINDING SPLITS (َAS SECTIONS) AFTER A GIVEN SECTION   #
	#--------------------------------------------------------#

	def FindSplitsAfterSectionCSZZ(n1, n2, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT BothAreNumbers(n1, n2)
				StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
			ok
		ok

		acSplits = This.SplitsAfterSection(n1, n2)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)
		
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisSectionCSZZ(n1, n2, pCaseSensitive)
			return This.FindSplitsAfterSectionCSZZ(n1, n2, pCaseSensitive)

		#--

		def FindSplitsAfterSectionAsSectionsCS(n1, n2, pCaseSensitive)
			return This.FindSplitsAfterSectionCSZZ(n1, n2, pCaseSensitive)

		def FindSplitsAfterThisSectionAsSectionsCS(n1, n2, pCaseSensitive)
			return This.FindSplitsAfterSectionCSZZ(n1, n2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterSectionZZ(n1, n2)
		return This.FindSplitsAfterSectionCSZZ(n1, n2, TRUE)

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

	def FindSplitsAfterSectionCSIBZZ(n1, n2, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT BothAreNumbers(n1, n2)
				StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
			ok
		ok

		acSplits = This.SplitsAfterSectionIB(n1, n2)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterThisSectionCSIBZZ(n1, n2, pCaseSensitive)
			return This.FindSplitsAfterSectionCSIBZZ(n1, n2, pCaseSensitive)

		#--

		def FindSplitsAfterSectionAsSectionsCSIB(n1, n2, pCaseSensitive)
			return This.FindSplitsAfterSectionCSIBZZ(n1, n2, pCaseSensitive)

		def FindSplitsAfterThisSectionAsSectionsCSIB(n1, n2, pCaseSensitive)
			return This.FindSplitsAfterSectionCSIBZZ(n1, n2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterSectionIBZZ(n1, n2)
		return This.FindSplitsAfterSectionCSIBZZ(n1, n2, TRUE)

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

	def FindSplitsAfterSectionsCSZZ(paSections, pCaseSensitive)

		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
				StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
			ok
		ok

		acSplits = This.SplitsAfterSections(paSections)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsAfterTheseSectionsCSZZ(paSections, pCaseSensitive)
			return This.FindSplitsAfterTheseSectionsCSZZ(paSections, pCaseSensitive)

		#--

		def FindSplitsAfterSectionsAsSectionsCS(paSections, pCaseSensitive)
			return This.FindSplitsAfterSectionsCSZZ(paSections, pCaseSensitive)

		def FindSplitsAfterTheseSectionsAsSectionsCS(paSections, pCaseSensitive)
			return This.FindSplitsAfterTheseSectionsCSZZ(paSections, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterSectionsZZ(paSections)
		return This.FindSplitsAfterSectionsCSZZ(paSections, TRUE)

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

	def FindSplitsAfterSectionsCSIBZZ(paSections, pCaseSensitive)

		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
				StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
			ok
		ok

		acSplits = This.SplitsAfterSectionsIB(paSections)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

		return aResult


		#< @FunctionAlternativeForms

		def FindSplitsAfterTheseSectionsCSIBZZ(paSections, pCaseSensitive)
			return This.FindSplitsAfterSectionsCSIBZZ(paSections, pCaseSensitive)

		#--

		def FindSplitsAfterSectionsAsSectionsCSIB(paSections, pCaseSensitive)
			return This.FindSplitsAfterSectionsCSIBZZ(paSections, pCaseSensitive)

		def FindSplitsAfterTheseSectionsAsSectionsCSIB(paSections, pCaseSensitive)
			return This.FindSplitsAfterSectionsCSIBZZ(paSections, pCaseSensitive)

		#>

	#-- WITHOUT CASESNSITIVITY

	def FindSplitsAfterSectionsIBZZ(paSections)
		return This.FindSplitsAfterSectionsCSIBZZ(paSections, TRUE)

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
	 #  FINDING SPLITS (AS SECTIONS) BETWEEN TWO POSITIONS OR Items  #
	#====================================================================#

	def FindSplitsBetweenCSZZ(pItem1, pItem2, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT ( BothAreStringsOrNumbers(pItem1, pItem2) )
				StzRaise("Incorrect params types! pItem1 and pItem2 must be both numbers or strings.")
			ok
		ok

		anFirstBounds  = This.FindAllCS(pItem1, pCaseSensitive)
		anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

		aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
		anFirstBounds  = aListOfBounds[1]
		anSecondBounds = aListOfBounds[2]

		aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)
		aResult = This.FindSplitsBetweenSectionsCSZZ(aSections, pCaseSensitive)
		
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBetweenAsSectionsCS(pItem1, pItem2, pCaseSensitive)
			return This.FindSplitsBetweenCSZZ(pItem1, pItem2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetweenZZ(pItem1, pItem2)
		return This.FindSplitsBetweenCS(pItem1, pItem2, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsBetweenAsSections(pItem1, pItem2)
			return This.FindSplitsBetweenZZ(pItem1, pItem2)

		#>

	  #----------------------------------------------------------------------------------------#
	 #  FINDING SPLITS (AS SECTIONS) BETWEEN TWO POSITIONS OR Items -- INCLUDING BOUNDS  #
	#----------------------------------------------------------------------------------------#

	def FindSplitsBetweenCSIBZZ(pItem1, pItem2, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		anFirstBounds  = This.FindAllCS(pItem1, pCaseSensitive)
		anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

		aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
		anFirstBounds  = aListOfBounds[1]
		anSecondBounds = aListOfBounds[2]

		nLen = len(anFirstBounds)
		for i = 1 to nLen
			anFirstBounds[i]--
			anSecondBounds[i]++
		next

		aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)
		aResult = This.FindSplitsBetweenSectionsCSZZ(aSections, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBetweenAsSectionsCSIB(pItem1, pItem2, pCaseSensitive)
			return This.FindSplitsBetweenCSIBZZ(pItem1, pItem2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetweenIBZZ(pItem1, pItem2)
		return This.FindSplitsBetweenCSIBZZ(pItem1, pItem2, TRUE)


		#< @FunctionAlternativeForm

		def FindSplitsBetweenAsSectionsIB(pItem1, pItem2)
			return This.FindSplitsBetweenIBZZ(pItem1, pItem2)

		#>

	  #------------------------------------------------------#
	 #  FINDING SPLITS (AS SECTIONS) BETWEEN TWO POSITIONS  #
	#------------------------------------------------------#

	def FindSplitsBetweenPositionsCSZZ(n1, n2, pCaseSensitive)
		return This.FindSplitsAtSectionCSZZ(n1, n2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindSplitsBetweenThesePositionsCSZZ(n1, n2, pCaseSensitive)
			return This.FindSplitsBetweenPositionsCSZZ(n1, n2, pCaseSensitive)

		#--

		def FindSplitsBetweenPositionsAsSectionsCS(n1, n2, pCaseSensitive)
			return This.FindSplitsBetweenPositionsCSZZ(n1, n2, pCaseSensitive)

		def FindSplitsBetweenThesePositionsAsSectionsCS(n1, n2, pCaseSensitive)
			return This.FindSplitsBetweenPositionsCSZZ(n1, n2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetweenPositionsZZ(n1, n2)
		return This.FindSplitsAtSectionCSZZ(n1, n2, TRUE)

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

	def FindSplitsBetweenPositionsCSIBZZ(n1, n2, pCaseSensitive)
		return This.FindSplitsAtSectionCSIBZZ(n1, n2, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindSplitsBetweenThesePositionsCSIBZZ(n1, n2, pCaseSensitive)
			return This.FindSplitsBetweenPositionsCSIBZZ(n1, n2, pCaseSensitive)

		#--

		def FindSplitsBetweenPositionsAsSectionsCSIB(n1, n2, pCaseSensitive)
			return This.FindSplitsBetweenPositionsCSIBZZ(n1, n2, pCaseSensitive)

		def FindSplitsBetweenThesePositionsAsSectionsCSIB(n1, n2, pCaseSensitive)
			return This.FindSplitsBetweenPositionsCSIBZZ(n1, n2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetweenPositionsIBZZ(n1, n2)
		return This.FindSplitsAtSectionCSIBZZ(n1, n2, TRUE)

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
	 #  FINDING SPLITS (AS SECTIONS) BETWEEN TWO Items  #
	#-------------------------------------------------------#

	def FindSplitsBetweenItemsCSZZ(paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		acSplits = This.SplitsBetweenItemsCS(paItems, pCaseSensitive)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)
		return aResult

		#< @FunctionAlternativeForms

		def FindSplitsBetweenTheseItemsCSZZ(paItems, pCaseSensitive)
			return This.FindSplitsBetweenItemsCSZZ(paItems, pCaseSensitive)

		#--

		def FindSplitsBetweenItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindSplitsBetweenItemsCSZZ(paItems, pCaseSensitive)

		def FindSplitsBetweenTheseItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindSplitsBetweenItemsCSZZ(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBetweenItemsZZ(paItems)
		return This.FindSplitsBetweenItemsCSZZ(paItems, TRUE)

		#< @FunctionAlternativeForms

		def FindSplitsBetweenTheseItemsZZ(paItems)
			return This.FindSplitsBetweenItemsZZ(paItems)

		#--

		def FindSplitsBetweenItemsAsSections(paItems)
			return This.FindSplitsBetweenItemsZZ(paItems)

		def FindSplitsBetweenTheseItemsAsSections(paItems)
			return This.FindSplitsBetweenItemsZZ(paItems)

		#>

	  #-----------------------------------------------#
	 #    FINDING SPLITS (AS SECTIONS) TO N PARTS    #
	#===============================================#

	def FindSplitsToNPartsCSZZ(n, pCaseSensitive)
		if This.IsEmppty()
			return []
		ok

		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		acSplits = This.SplitsToNPartsZZ(n)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)
		return aResult

		def FindSplitsToNPartsAsSectionsCS(n, pCaseSensitive)
			return This.FindSplitsToNPartsCSZZ(n, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsToNPartsZZ(n)
		return This.FindSplitsToNPartsCSZZ(n, TRUE)

		def FindSplitsToNPartsAsSections(n)
			return This.FindSplitsToNPartsZZ(n)

	  #--------------------------------------------------#
	 #   FINDING SPLITS TO PARTS OF (EXACTLY) N Items   #
	#--------------------------------------------------#
	# Remaining part less the n Items is not returned

	def FindSplitsToPartsOfNItemsCSZZ(n, pCaseSensitive)
		if This.IsEmppty()
			return []
		ok

		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		acSplits = This.SplitsToPartsOfNItemsZZ(n)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsToPartsOfExactlyNItemsCSZZ(n, pCaseSensitive)
			return This.FindSplitsToPartsOfNItemsCSZZ(n, pCaseSensitive)

		#--

		def FindSplitsToPartsOfNItemsAsSectionsCS(n, pCaseSensitive)
			return This.FindSplitsToPartsOfNItemsCSZZ(n, pCaseSensitive)

		def FindSplitsToPartsOfExactlyNItemsAsSectionsCS(n, pCaseSensitive)
			return This.FindSplitsToPartsOfNItemsCSZZ(n, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsToPartsOfNItemsZZ(n)
		return This.FindSplitsToPartsOfNItemsCSZZ(n, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsToPartsOfExactlyNItemsZZ(n)
			return This.FindSplitsToPartsOfNItemsZZ(n)

		#--

		def FindSplitsToPartsOfNItemsAsSections(n)
			return This.FindSplitsToPartsOfNItemsZZ(n)

		def FindSplitsToPartsOfExactlyNItemsAsSections(n)
			return This.FindSplitsToPartsOfNItemsZZ(n)

		#>

	  #------------------------------------------------------------------#
	 #   FINDING SPLITS (AS SECTIONS) TO PARTS OF N Items -- EXTENDED   #
	#------------------------------------------------------------------#
	# The remaing part (if any) less then n Items is also returned

	def FindSplitsToPartsOfNItemsCSXTZZ(n, pCaseSensitive)
		if This.IsEmppty()
			return []
		ok

		if CheckParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		acSplits = This.SplitsToPartsOfNItemsXTZZ(n)
		aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)
		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsToPartsOfNItemsAsSectionsCSXT(n, pCaseSensitive)
			return This.FindSplitsToPartsOfNItemsCSXTZZ(n, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY()

	def FindSplitsToPartsOfNItemsXTZZ(n)
		return This.FindSplitsToPartsOfNItemsCSXTZZ(n, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsToPartsOfNItemsAsSectionsXT(n)
			return This.FindSplitsToPartsOfNItemsXTZZ(n)

		#>

	  #----------------------------------------------------------#
	 #    FINDING SPLITS (AS SECTIONS) UNDER A GIVEN CONDTION   #
	#==========================================================#

	def FindSplitsWCSZZ(pcCondition, pCaseSensitive)

		if This.IsEmpty()
			return []
		ok

		if isList(pcCondition)
			oCondition = StzStringQ(pcCondition)
			if oCondition.IsWhereNamedParam()
				return This.FindSplitsAtWCSZZ(pcCondition[2], pCaseSensitive)

			but oCondition.IsAtNamedParam()
				return This.FindSplitsAtWCSZZ(pcCondition[2], pCaseSensitive)

			but oCondition.IsBeforeNamedParam()
				return This.FindSplitsBeforeWCSZZ(pcCondition[2], pCaseSensitive)

			but oCondition.IsAfterNamedParam()
				return This.FindSplitsAfterWCSZZ(pcCondition[2], pCaseSensitive)

			ok
		
		else

			return This.FindSplitsAtWCSZZ(pcCondition, pCaseSensitive)
		ok

		#< @FunctionAlternativeForm

		def FindSplitsAsSectionsWCS(pcCondition, pCaseSensitive)
			return This.FindSplitsWCSZZ(pcCondition, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsWZZ(pcCondition)
		return This.FindSplitsWCSZZ(pcCondition, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAsSectionsW(pcCondition)
			return This.FindSplitsWZZ(pcCondition)

		#>

	  #-------------------------------------------------------#
	 #    FINSING SPLITS (AS SECTIONS) AT A GIVEN CONDTION   #
	#-------------------------------------------------------#

	def FindSplitsAtWCSZZ(pcCondition, pCaseSensitive)

		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if isList(pcCondition) and Q(pcCondition).IsWhereNamedParam()
				pcCondition = pcCondition[2]
			ok
	
			if NOT isString(pcCondition)
				StzRaise("Incorrect param type! pcCondition must be a string.")
			ok

		ok

		aResult = []

		pcCondition = Q(pcCondition).TrimQ().TheseBoundsRemoved( "{","}" )

		if Q(pcCondition).ContainsCS("@Item", :CS = FALSE)

			aSections = This.FindItemsAsSectionsWCS(pcCondition, pCaseSensitive)
			aResult = This.FindSplitsAtSectionsCSZZ(aSections, pCaseSensitive)

			/* TODO: should we resolve it like this:

			acSplits = This.SplitsAtWCSZZ(pcCondition, pCaseSensitive)
			aResult = This.FindManyAsSectionsCS(acSplits, pCaseSensitive)

			*/

		else

			anPos = This.FindWCS(pcCondition, pCaseSensitive)
			aResult = This.FindSplitsAtPositionsCSZZ(anPos, pCaseSensitive)

		ok

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAtAsSectiosnWCS(pcCondition, pCaseSensitive)
			return This.FindSplitsAtWCSZZ(pcCondition, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAtWZZ(pcCondition)
		return This.FindSplitsAtWCSZZ(pcCondition, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAtAsSectiosnW(pcCondition)
			return This.FindSplitsAtWZZ(pcCondition)

		#>

	  #-----------------------------------------------------------#
	 #    FINDING SPLITS (AS SECTIONS) BEFORE A GIVEN CONDTION   #
	#-----------------------------------------------------------#

	def FindSplitsBeforeWCSZZ(pcCondition, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT isString(pcCondition)
				StzRaise("Incorrect param type! pcCondition must be a string.")
			ok

		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsWCS(pcCondition, pCaseSensitive)

		else
			anPos = This.FindItemsWCS(pcCondition, pCaseSensitive)
		ok

		aResult = This.FindSplitsBeforePositionsCSZZ(anPos, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsBeforeAsSectionsWCS(pcCondition, pCaseSensitive)
			return This.FindSplitsBeforeWCSZZ(pcCondition, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsBeforeWZZ(pcCondition)
		return This.FindSplitsBeforeWCSZZ(pcCondition, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsBeforeAsSectionsW(pcCondition)
			return This.FindSplitsBeforeWZZ(pcCondition)

		#>

	  #----------------------------------------------------------#
	 #    FINDING SPLITS (AS SECTIONS) AFTER A GIVEN CONDTION   #
	#----------------------------------------------------------#

	def FindSplitsAfterWCSZZ(pcCondition, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT isString(pcCondition)
				StzRaise("Incorrect param type! pcCondition must be a string.")
			ok

		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsWCS(pcCondition, pCaseSensitive)

		else
			anPos = This.FindItemsWCS(pcCondition, pCaseSensitive)
		ok

		aResult = This.FindSplitsAfterPositionsCSZZ(anPos, pCaseSensitive)

		return aResult

		#< @FunctionAlternativeForm

		def FindSplitsAfterAsSectionsWCS(pcCondition, pCaseSensitive)
			return This.FindSplitsAfterWCSZZ(pcCondition, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSplitsAfterWZZ(pcCondition)
		return This.FindSplitsAfterWCSZZ(pcCondition, TRUE)

		#< @FunctionAlternativeForm

		def FindSplitsAfterAsSectionsW(pcCondition)
			return This.FindSplitsAfterWZZ(pcCondition)

		#>

	  #===========================#
	 #   FINDING THE NTH SPLIT   #
	#===========================#

	def FindNthSplitCSXT(n, pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isList(pItem)
			return This.FindNthSplitAtItemCS(n, pItem, pCaseSensitive)

		else

			oParam = Q(pItem)

			#-- SPLITTING AT / USING

			if oParam.IsOneOfTheseNamedParams([ :At, :Using ])
				return This.FindNthSplitAtCS(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtPosition, :AtThisPosition ]) 
				return This.FindNthSplitAtPositionCS(n, pItem[2], pCaseSensitive)
	
			but oParam.IsOneOfTheseNamedParams([ :AtPositions, :AtThesePositions ]) 
				return This.FindNthSplitAtPositionsCS(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([
						:AtItem, :AtThisItem,
						:UsingItem, :UsingThisItem ]) 

				return This.FindNthSplitAtItemCS(n, pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([
						:AtItems, :AtTheseItems,
						:UsingItems, :UsingTheseItems ]) 

				return This.FindNthSplitAtItemsCS(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtSection, :AtThisSection ]) 
				return This.FindNthSplitAtSectionCS(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :AtSections, :AtTheseSections ]) 
				return This.FindNthSplitAtSectionsCS(n, pItem[2], pCaseSensitive)

			#-- SPLITTING BEFORE

			but oParam.IsBeforeNamedParam()
				return This.FindNthSplitBeforeCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforePosition, :BeforeThisPosition ]) 
				return This.FindNthSplitBeforePositionCS(n, pItem[2], pCaseSensitive)
	
			but oParam.IsOneOfTheseNamedParams([ :BeforePositions, :BeforeThesePositions ]) 
				return This.FindNthSplitBeforePositionsCS(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforeItem, :BeforeThisItem ]) 
				return This.FindNthSplitBeforeItemCS(n, pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeItems, :BeforeTheseItems ]) 
				return This.SplitBeforeItemsCS(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforeSection, :BeforeThisSection ]) 
				return This.FindNthSplitBeforeSectionCS(n, pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeSections, :BeforeTheseSections ]) 
				return This.FindNthSplitBeforeSectionsCS(n, pItem[2], pCaseSensitive)

			#-- SPLITTING AFTER

			but oParam.IsAfterNamedParam()
				return This.FindNthSplitAfterCS(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterPosition, :AfterThisPosition ]) 
				return This.FindNthSplitAfterPositionCS(n, pItem[2], pCaseSensitive)
	
			but oParam.IsOneOfTheseNamedParams([ :AfterPositions, :AfterThesePositions ]) 
				return This.FindNthSplitAfterPositionsCS(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterItem, :AfterThisItem ]) 
				return This.FindNthSplitAfterItemCS(n, pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :AfterItems, :AfterTheseItems ]) 
				return This.FindNthSplitAfterItemsCS(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterSection, :AfterThisSection ]) 
				return This.FindNthSplitAfterSectionCS(n, pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :AfterSections, :AfterTheseSections ]) 
				return This.FindNthSplitAfterSectionsCS(n, pItem[2], pCaseSensitive)

			# SPLITTING BETWEEN

			but oParam.IsBetweenNamedParam() and
				isList(pItem) and len(pItem) = 2
				
				if isList(pItem[2]) and Q(pItem[2]).IsAndNamedParam()
					pItem[2] = pItem[2][2]
				ok

				return This.FindNthSplitBetweenCS(n, pItem[1], pItem[2], pCaseSensitive)

			but oParam.IsBetweenPositionsNamedParam()
				return This.FindNthSplitBetweenPositionsCS(n, pItem[1], pItem[2], pCaseSensitive)

			but oParam.IsBetweenItemsNamedParam()
				return This.FindNthSplitBetweenItemsCS(n, pItem[1], pItem[2], pCaseSensitive)

			# SPLITTING TO PARTS

			but oParam.IsToNPartsNamedParam()
				return This.FindNthSplitToNPartsCS(n, pItem[2], pCaseSensitive)

			but oParam.IsToPartsOfNItemsNamedParam()
				return This.FindNthSplitToPartsOfNItemsCS(n, pItem[2], pCaseSensitive)

			# SPLITTING WHERE

			but oParam.IsWhereOrAtWhereNamedParam()
				return This.FindNthSplitAtWCS(n, pItem[2], pCaseSensitive)

			but oParam.IsBeforeWhereNamedParam()
				return This.FindNthSplitBeforeWCS(n, pItem[2], pCaseSensitive)

			but oParam.IsAfterWhereNamedParam()
				return This.FindNthSplitAfterWCS(n, pItem[2], pCaseSensitive)

			else
				return This.FindNthSplitAtItemCS(n, pItem, pCaseSensitive)
			ok
		ok

		#< @FunctionAlternativeForm

		def FindNthSplitCSXTZ(pItem, pCaseSensitive)
			return This.FindNthSplitCSXT(n, pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitXT(n, pItem)
		return This.FindNthSplitCSXT(n, pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitXTZ(n, pItem)
			return This.FindNthSplitXT(n, pItem)

		#>

	  #-------------------------------------------------------#
	 #   FINDING NTH SPLIT AT A GIVEN Item  #
	#=======================================================#

	def FindNthSplitAtCS(n, pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isList(pItem)
			return This.FindNthSplitAtItemCS(n, pItem, pCaseSensitive)

		else

			oParam = Q(pItem)

			#-- Case when named params are provided

			if oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindNthSplitAtPositionCS(n, pItem[2], pCaseSensitive)
	
			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindNthSplitAtPositionsCS(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindNthSplitAtItemCS(n, pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindNthSplitAtItemsCS(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindNthSplitAtSectionCS(n, pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindNthSplitAtSectionsCS(n, pItem[2], pCaseSensitive)

			else
				return This.FindNthSplitAtItemCS(n, pItem, pCaseSensitive)
			ok
		ok

		#< @FunctionAlternativeForm

		def FindNthSplitAtCSZ(n, pItem, pCaseSensitive)
			return This.FindNthSplitAtCS(n, pSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitAt(n, pItem)
		return This.FindNthSplitAtCS(n, pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitAtZ(n, pItem)
			return This.FindNthSplitAtCS(n, pSubStr)

		#>

	  #-------------------------------------------#
	 #   FINDING NTH SPLIT AT A GIVEN POSITION   #
	#===========================================#

	#NOTE
	# Case sensitivty has no added value here,
	# since the split is based on position
	# and there is no use of ...CS() functions
	# in the implementatin

	def FindNthSplitAtPosition(n, nPos) 
		    
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT isNumber(n, nPos) and (n = 1 or n = 2)
				StzRaise("Incorrect pram type! n must be a number equal to 1 or 2.")
				# Because after splitting the string at a given position, there will
				# be only two splits, right?
			ok

		ok

		nResult = 0

		if n = 1
			nResult = 1

		but n = 2
			nResult + (nPos + 1)
		ok

		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitAtThisPosition(n, nPos)
			return This.FindNthSplitAtPosition(n, nPos)

		def FindNthSplitAtPositionZ(n, nPos)
			return This.FindNthSplitAtPosition(n, nPos)

		def FindNthSplitAtThisPositionZ(n, nPos)
			return This.FindNthSplitAtPosition(n, nPos)

		#>

	  #-----------------------------------------#
	 #   FINDING NTH SPLIT AT MANY POSITIONS   #
	#-----------------------------------------#

	def FindNthSplitAtPositions(n, anPos)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()

			if NOT ( isNumber(n) and n > 0 )
				StzRaise("Incorrect param type! n must be a number greater then 0.")
			ok

			if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
				StzRaise("Incorrect param type! anPos must be a list of numbers.")
			ok

		ok

		if n = 1
			return 1
		ok

		acSplits = This.SplitsAtPositions(anPos)
		
		for i = 1 to n-1
			nLen = StzStringQ(acSplits[i]).NumberOfItems()
			nResult += ( nLen + 1 )
		next

		return nResult

		#< @FunctionAlternativeForms

		def FindNthSplitAtThesePositions(n, anPos)
			return This.FindNthSplitAtPositions(n, anPos)

		def FindNthSplitAtManyPositions(n, anPos)
			return This.FindNthSplitAtPositions(n, anPos)

		#--

		def FindNthSplitAtPositionsZ(n, anPos)
			return This.FindNthSplitAtPositions(n, anPos)

		def FindNthSplitAtThesePositionsZ(n, anPos)
			return This.FindNthSplitAtPositions(n, anPos)

		def FindNthSplitAtManyPositionsZ(n, anPos)
			return This.FindNthSplitAtPositions(n, anPos)

		#>

	  #---------------------------------------#
	 #   FINDING NTH SPLIT AT A GIVEN ITEM   #
	#=======================================#

	def FindNthSplitAtItemCS(n, pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()
	
			if NOT ( isNumber(n) and n > 0 )
				StzRaise("Incorrect param type! n must be a number greater then 0.")
			ok

			if NOT isString(pItem)
				StzRaise("Incorrect param type! pItem must be a string.")
			ok
		ok

		if n = 1
			return 1
		ok

		nLenSubStr = StzStringQ(pItem).NumberOfItems()
		acSplits = This.SplitsAtItemCS(pItem, pCaseSensitive)
		
		for i = 1 to n-1
			nLen = StzStringQ(acSplits[i]).NumberOfItems()
			nResult += ( nLen + nLenSubStr )
		next

		return nResult

		#< @FunctionAlternativeForms

		def FindNthSplitCS(n, pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindNthSplitAtItemCS(n, pItem, pCaseSensitive)

		def FindNthSplitAtThisItemCS(n, pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindNthSplitAtItemCS(n, pItem, pCaseSensitive)

		#--

		def FindNthSplitAtItemCSZ(n, pItem, pCaseSensitive)
			return This.FindNthSplitAtItemCS(n, pItem, pCaseSensitive)

		def FindNthSplitCSZ(n, pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindNthSplitAtItemCS(n, pItem, pCaseSensitive)

		def FindNthSplitAtThisItemCSZ(n, pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindNthSplitAtItemCS(n, pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitAtItem(n, pItem)
		return This.FindNthSplitAtItemCS(n, pItem, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSplit(n, pItem)
			return This.FindNthSplitCS(n, pItem, TRUE)

		def FindNthSplitAtThisItem(n, pItem)
			return This.FindNthSplitAtThisItemCS(n, pItem, TRUE)
		#--

		def FindNthSplitAtItemZ(n, pItem)
			return This.FindNthSplitAtItemCS(n, pItem, TRUE)

		def FindNthSplitZ(n, pItem)
			return This.FindNthSplitCS(n, pItem, TRUE)

		def FindNthSplitAtThisItemZ(pItem)
			return This.FindNthSplitAtThisItemCS(n, pItem, TRUE)

		#>

	  #--------------------------------------#
	 #   FINDING NTH SPLIT AT GIVEN ITEMS   #
	#--------------------------------------#

	def FindNthSplitAtItemsCS(n, paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()
	
			if NOT ( isNumber(n) and n > 0 )
				StzRaise("Incorrect param type! n must be a number greater then 0.")
			ok

			if NOT (isList(paItems) and Q(paItems).IsListOfStrings())
				StzRaise("Incorrect param type! paItems must be a list of strings.")
			ok
		ok

		#>

		if n = 1
			return 1
		ok

		acSplits = This.SplitsAtItemCS(pItem, pCaseSensitive)
		
		for i = 1 to n-1
			nLen = StzStringQ(acSplits[i]).NumberOfItems()
			nLenSubStr = StzStringQ(paItems[i]).NumberOfItems()
			nResult += ( nLen + nLenSubStr )
		next

		return nResult


		#< @FunctionAlternativeForms

		def FindNthSplitAtTheseItemsCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitAtItemsCS(n, paItems, pCaseSensitive)

		def FindNthSplitAtManyItemsCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitAtItemsCS(n, paItems, pCaseSensitive)

		#--

		def FindNthSplitAtItemsCSZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitAtItemsCS(n, paItems, pCaseSensitive)

		def FindNthSplitAtTheseItemsCSZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitAtItemsCS(n, paItems, pCaseSensitive)

		def FindNthSplitAtManyItemsCSZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitAtItemsCS(n, paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitAtItems(n, paItems)
		return This.FindNthSplitAtItemsCS(n, paItems, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSplitAtTheseItems(n, paItems)
			return This.FindNthSplitAtItems(n, paItems)
	
		def FindNthSplitAtManyItems(n, paItems)
			return This.FindNthSplitAtItems(n, paItems)

		#--

		def FindNthSplitAtItemsZ(n, paItems)
			return This.FindNthSplitAtItems(n, paItems)

		def FindNthSplitAtTheseItemsZ(n, paItems)
			return This.FindNthSplitAtItems(n, paItems)

		def FindNthSplitAtManyItemsZ(n, paItems)
			return This.FindNthSplitAtItems(n, paItems)

		#>

	  #------------------------------------------#
	 #   FINDING NTH SPLIT AT A GIVEN SECTION   #
	#==========================================#

	def FindNthSplitAtSection(n, n1, n2)
		if This.IsEmpty()
			return []
		ok

		if CheckParams()
			if NOT @AllAreNumbers([n, n1, n2 ])
				StzRaise("Incorrect params type! n, n1 and n2 must all be numbers.")
			ok

			if NOT ( n = 1 or n = 2 )
				StzRaise("Incorrect values ! n must be equal to 1 or 2.")
				# Since the split make two parts only.
			ok
		ok

		if n = 1
			return 1
		
		but n = 2
			return n2 + 1
		ok
		
		#< @FunctionAlternativeForm

		def FindNthSplitAtThisSection(n, n1, n2)
			return This.FindNthSplitAtSection(n, n1, n2)

		#--

		def FindNthSplitAtSectionZ(n, n1, n2)
			return This.FindNthSplitAtSection(n, n1, n2)

		def FindNthSplitAtThisSectionZ(n, n1, n2)
			return This.FindNthSplitAtSection(n, n1, n2)

		#>

	  #-------------------------------------------------------------#
	 #   FINDING NTH SPLIT AT A GIVEN SECTION -- INCLUDING BOUNDS  #
	#-------------------------------------------------------------#

	def FindNthSplitAtSectionIB(n, n1, n2)
		nResult = This.FindNthSplitAtSection(n, n1, n2)
		if nResult > 1
			nResult - (n2 - n1)
		ok

		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitAtThisSectionIB(n, n1, n2)
			return This.SplitAtSectionIB(n, n1, n2)

		#--

		def FindNthSplitAtSectionIBZ(n, n1, n2)
			return This.FindNthSplitAtSectionIB(n, n1, n2)

		def FindNthSplitAtThisSectionIBZ(n, n1, n2)
			return This.SplitAtSectionIB(n, n1, n2)

		#>

	  #----------------------------------------#
	 #   FINDING NTH SPLIT AT MANY SECTIONS   #
	#----------------------------------------#

	def FindNthSplitAtSections(n, paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		StzRaise("Feature not yet implemented!")

		#< @FunctionAlternativeForms

		def FindNthSplitAtTheseSections(n, paSections)
			return This.FindNthSplitAtSections(n, paSections)

		#--

		def FindNthSplitAtSectionsZ(n, paSections)
			return This.FindNthSplitAtSections(n, paSections)

		def FindNthSplitAtTheseSectionsZ(n, paSections)
			return This.FindNthSplitAtSections(n, paSections)

		#>

	  #------------------------------------------------------------#
	 #   FINDING NTH SPLIT BEFORE A GIVEN ITEM   #
	#------------------------------------------------------------#

	def FindNthSplitBeforeCS(n, pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isList(pItem)
			return This.FindNthSplitBeforeItemCS(n, pItem, pCaseSensitive)

		else

			oItem = Q(pItem)

			if oItem.IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindNthSplitBeforePosition(n, pItem[2])
	
			but oItem.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindNthSplitBeforePositions(n, pItem[2])

			but oItem.IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindNthSplitBeforeItemCS(n, pItem[2], pCaseSensitive)
		
			but oItem.IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindNthSplitBeforeItemsCS(n, pItem[2], pCaseSensitive)

			but oItem.IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindNthSplitBeforeSection(n, pItem[2])
		
			but oItem.IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindNthSplitBeforeSections(n, pItem[2])

			else
				return This.FindNthSplitBeforeItemCS(n, pItem, pCaseSensitive)

			ok
		ok

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeCSZ(n, pItem, pCaseSensitive)
			return This.FindNthSplitBeforeCS(n, pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitBefore(n, pItem)
		return This.FindNthSplitBeforeCS(n, pItem, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeZ(n, pItem)
			return This.FindNthSplitBefore(n, pItem)

		#>

	  #-----------------------------------------------#
	 #   FINDING NTH SPLIT BEFORE A GIVEN POSITION   #
	#-----------------------------------------------#

	def FindNthSplitBeforePosition(n, nPos)
		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforePosition(n, nPos)
		return aResult

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeThisPosition(n, nPos)
			return This.FindNthSplitBeforePosition(n, nPos)

		#--

		def FindNthSplitBeforePositionZ(n, nPos)
			return This.FindNthSplitBeforePosition(n, nPos)

		def FindNthSplitBeforeThisPositionZ(n, nPos)
			return This.FindNthSplitBeforePosition(n, nPos)

		#>

	  #---------------------------------------------#
	 #   FINDING NTH SPLIT BEFORE MANY POSITIONS   #
	#---------------------------------------------#

	def FindNthSplitBeforePositions(n, anPos)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforePositions(n, anPos)
		return aResult			

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeThesePositions(n, anPos)
			return This.FindNthSplitBeforePositions(n, anPos)

		def FindNthSplitBeforeManyPositions(n, anPos)
			return This.FindNthSplitBeforePositions(n, anPos)

		#--

		def FindNthSplitBeforePositionsZ(n, anPos)
			return This.FindNthSplitBeforePositions(n, anPos)

		def FindNthSplitBeforeThesePositionsZ(n, anPos)
			return This.FindNthSplitBeforePositions(n, anPos)

		def FindNthSplitBeforeManyPositionsZ(n, anPos)
			return This.FindNthSplitBeforePositions(n, anPos)

		#>

	  #------------------------------------------------#
	 #   FINDING NTH SPLIT BEFORE A GIVEN Item   #
	#------------------------------------------------#

	def FindNthSplitBeforeItemCS(n, pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		anPos = This.FindCS(pItem, pCaseSensitive)
		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforePositions(n, anPos)

		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitBeforeThisItemCS(n, pItem, pCaseSensitive)
			return This.FindNthSplitBeforeItemCS(n, pItem, pCaseSensitive)

		#--

		def FindNthSplitBeforeItemCSZ(n, pItem, pCaseSensitive)
			return This.FindNthSplitBeforeItemCS(n, pItem, pCaseSensitive)

		def FindNthSplitBeforeThisItemCSZ(n, pItem, pCaseSensitive)
			return This.FindNthSplitBeforeItemCS(n, pItem, pCaseSensitive)

		#>
				
	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitBeforeItem(n, pItem)
		return This.FindNthSplitBeforeItemCS(n, pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitBeforeThisItem(n, pItem)
			return This.FindNthSplitBeforeItem(n, pItem)

		#--

		def FindNthSplitBeforeItemZ(n, pItem)
			return This.FindNthSplitBeforeItem(n, pItem)

		def FindNthSplitBeforeThisItemZ(n, pItem)
			return This.FindNthSplitBeforeItem(n, pItem)	

		#>

	  #-----------------------------------------#
	 #   FINDING NTH SPLIT BEFORE MANY ITEMS   #
	#-----------------------------------------#

	def FindNthSplitBeforeItemsCS(n, paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		anPos = This.FindManyCS( paItems, pCaseSensitive )
		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforePositions(n, anPos)

		return nResult

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeTheseItemsCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitBeforeItemsCS(n, paItems, pCaseSensitive)

		def FindNthSplitBeforeManyItemsCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitBeforeItemsCS(n, paItems, pCaseSensitive)

		#--

		def FindNthSplitBeforeItemsCSZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitBeforeItemsCS(n, paItems, pCaseSensitive)

		def FindNthSplitBeforeTheseItemsCSZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitBeforeItemsCS(n, paItems, pCaseSensitive)

		def FindNthSplitBeforeManyItemsCSZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitBeforeItemsCS(n, paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitBeforeItems(n, paItems)
		return This.FindNthSplitBeforeItemsCS(n, paItems, TRUE)
	
		#< @FunctionAlternativeForms

		def FindNthSplitBeforeTheseItems(n, paItems)
			return This.FindNthSplitBeforeItems(n, paItems)

		def FindNthSplitBeforeManyItems(n, paItems)
			return This.FindNthSplitBeforeItems(n, paItems)

		#--

		def FindNthSplitBeforeItemsZ(n, paItems)
			return This.FindNthSplitBeforeItems(n, paItems)

		def FindNthSplitBeforeTheseItemsZ(n, paItems)
			return This.FindNthSplitBeforeItems(n, paItems)

		def FindNthSplitBeforeManyItemsZ(n, paItems)
			return This.FindNthSplitBeforeItems(n, paItems)

		#>

	  #----------------------------------------------#
	 #   FINDING NTH SPLIT BEFORE A GIVEN SECTION   #
	#----------------------------------------------#

	def FindNthSplitBeforeSection(n, n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforeSection(n, n1, n2)
		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitBeforeThisSection(n, n1, n2)
			return This.FindNthSplitBeforeSection(n, n1, n2)

		#--

		def FindNthSplitBeforeSectionZ(n, n1, n2)
			return This.FindNthSplitBeforeSection(n, n1, n2)

		def FindNthSplitBeforeThisSectionZ(n, n1, n2)
			return This.FindNthSplitBeforeSection(n, n1, n2)

		#>

	  #-----------------------------------------------------------------#
	 #   FINDING NTH SPLIT BEFORE A GIVEN SECTION -- INCLUDING BOUND   #
	#-----------------------------------------------------------------#

	def FindNthSplitBeforeSectionIB(n, n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n, n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforeSectionIB(n, n1, n2)
		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitBeforeThisSectionIB(n, n1, n2)
			return This.FindNthSplitBeforeSectionIB(n, n1, n2)

		#--

		def FindNthSplitBeforeSectionIBZ(n, n1, n2)
			return This.FindNthSplitBeforeSectionIB(n, n1, n2)

		def FindNthSplitBeforeThisSectionIBZ(n, n1, n2)
			return This.FindNthSplitBeforeSectionIB(n, n1, n2)

		#>

	  #--------------------------------------------#
	 #   FINDING NTH SPLIT BEFORE MANY SECTIONS   #
	#--------------------------------------------#

	def FindNthSplitBeforeSections(n, paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforeSections(n, paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeTheseSections(n, paSections)
			return This.FindNthSplitBeforeSections(n, paSections)

		def FindNthSplitBeforeManySections(n, paSections)
			return This.SplitBeforeSections(n, paSections)

		#--

		def FindNthSplitBeforeSectionsZ(n, paSections)
			return This.FindNthSplitBeforeSections(n, paSections)

		def FindNthSplitBeforeTheseSectionsZ(n, paSections)
			return This.FindNthSplitBeforeSections(n, paSections)

		def FindNthSplitBeforeManySectionsZ(n, paSections)
			return This.SplitBeforeSections(n, paSections)

		#>

	  #-------------------------------------------------------------#
	 #   FINING NTH SPLIT BEFORE MANY SECTIONS -- INCLUDING BOUND  #
	#-------------------------------------------------------------#

	def FindNthSplitBeforeSectionsIB(n, paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforeSectionsIB(n, paSections)
		return nResult

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeTheseSectionsIB(n, paSections)
			return This.FindNthSplitBeforeSectionsIB(n, paSections)

		def FindNthSplitBeforeManySectionsIB(paSections)
			return This.FindNthSplitBeforeSectionsIB(n, paSections)

		#--

		def FindNthSplitBeforeSectionsIBZ(n, paSections)
			return This.FindNthSplitBeforeSectionsIB(n, paSections)

		def FindNthSplitBeforeTheseSectionsIBZ(n, paSections)
			return This.FindNthSplitBeforeSectionsIB(n, paSections)

		def FindNthSplitBeforeManySectionsIBZ(n, paSections)
			return This.FindNthSplitBeforeSectionsIB(n, paSections)

		#>

	  #-----------------------------------------#
	 #   FINDING NTH SPLIT AFTER A GIVEN ITEM  #
	#-----------------------------------------#

	def FindNthSplitAfterCS(n, pItem, pCaseSensitive)
		if NOT isList(pItem)
			return This.FindNthSplitAfterItemCS(n, pItem, pCaseSensitive)

		else

			oItem = Q(pItem)

			if oItem.IsOneOfTheseNamedParams([ :Position, :ThisPosition ])

				return This.FindNthSplitAfterPosition(n, pItem[2])
	
			but oItem.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindNthSplitAfterPositions(n, pItem[2])

			but oItem.IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindNthSplitAfterItemCS(n, pItem[2], pCaseSensitive)
		
			but oItem.IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindNthSplitAfterItemsCS(n, pItem[2], pCaseSensitive)

			but oItem.IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindNthSplitAfterSection(n, pItem[2])

			but oItem.IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindNthSplitAfterSections(n, pItem[2])

			else
				return This.FindNthSplitAfterItemCS(n, pItem, pCaseSensitive)
			ok
		ok

		#< @FunctionAlternativeForm

		def FindNthSplitAfterCSZ(n, pItem, pCaseSensitive)
			return This.FindNthSplitAfterCS(n, pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitAfter(n, pItem)
		return This.FindNthSplitAfterCS(n, pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitAfterZ(n, pItem)
			return This.FindNthSplitAfterCS(n, pItem, pCaseSensitive)

		#>

	  #-----------------------------------------------#
	 #   FINDING NTH SPLIT BEFORE A GIVEN POSITION   #
	#-----------------------------------------------#

	def FindNthSplitAfterPosition(n, nPos)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterPosition(n, nPos)
		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterThisPosition(n, nPos)
			return This.FindNthSplitAfterPosition(n, nPos)

		def FindNthSplitAfterPositionZ(n, nPos)
			return This.FindNthSplitAfterPosition(n, nPos)

		def FindNthSplitAfterThisPositionZ(n, nPos)
			return This.FindNthSplitAfterPosition(n, nPos)

		#>

	  #---------------------------------------------#
	 #   FINDING NTH SPLIT BEFORE MANY POSITIONS   #
	#---------------------------------------------#

	def FindNthSplitAfterPositions(n, anPos)
		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterPositions(n, anPos)
		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterThesePositions(n, anPos)
			return This.FindNthSplitAfterThesePositions(n, anPos)

		def FindNthSplitAfterManyPositions(n, anPos)
			return This.FindNthSplitAfterManyPositions(n, anPos)

		#--

		def FindNthSplitAfterPositionsZ(n, anPos)
			return This.FindNthSplitAfterPositions(n, anPos)

		def FindNthSplitAfterThesePositionsZ(n, anPos)
			return This.FindNthSplitAfterThesePositions(n, anPos)

		def FindNthSplitAfterManyPositionsZ(n, anPos)
			return This.FindNthSplitAfterManyPositions(n, anPos)

		#>

	  #-------------------------------------------#
	 #   FINDING NTH SPLIT BEFORE A GIVEN ITEM   #
	#-------------------------------------------#

	def FindNthSplitAfterItemCS(n, pItem, pCaseSensitive)

		anPos = This.FindCS(pItem, pCaseSensitive)
		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterPositions(n, anPos)
		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterThisItemCS(n, pItem, pCaseSensitive)
			return This.FindNthSplitAfterItemCS(n, pItem, pCaseSensitive)

		#--

		def FindNthSplitAfterItemCSZ(n, pItem, pCaseSensitive)
			return This.FindNthSplitAfterItemCS(n, pItem, pCaseSensitive)

		def FindNthSplitAfterThisItemCSZ(n, pItem, pCaseSensitive)
			return This.FindNthSplitAfterItemCS(n, pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitAfterItem(n, pItem)
		return This.FindNthSplitAfterItemCS(n, pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitAfterThisItem(n, pItem)
			return This.FindNthSplitAfterItem(n, pItem)

		#--

		def FindNthSplitAfterItemZ(n, pItem)
			return This.FindNthSplitAfterItem(n, pItem)

		def FindNthSplitAfterThisItemZ(n, pItem)
			return This.FindNthSplitAfterItem(n, pItem)

		#>

	  #----------------------------------------------#
	 #   FINDING NTH SPLIT BEFORE MANY Items   #
	#----------------------------------------------#

	def FindNthSplitAfterItemsCS(n, paItems, pCaseSensitive)

		anPos = This.FindManyCS( paItems, pCaseSensitive )
		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterPositions(n, anPos)
		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterTheseItemsCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitAfterItemsCS(n, paItems, pCaseSensitive)

		def FindNthSplitAfterManyItemsCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitAfterItemsCS(n, paItems, pCaseSensitive)

		#--

		def FindNthSplitAfterItemsCSZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitAfterItemsCS(n, paItems, pCaseSensitive)

		def FindNthSplitAfterTheseItemsCSZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitAfterItemsCS(n, paItems, pCaseSensitive)

		def FindNthSplitAfterManyItemsCSZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitAfterItemsCS(n, paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitAfterItems(n, paItems)
		return This.FindNthSplitAfterItemsCS(n, paItems, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitAfterTheseItems(n, paItems)
			return This.FindNthSplitAfterItems(n, paItems)

		def FindNthSplitAfterManyItems(n, paItems)
			return This.FindNthSplitAfterItems(n, paItems)

		#--

		def FindNthSplitAfterItemsZ(n, paItems)
			return This.FindNthSplitAfterItems(n, paItems)

		def FindNthSplitAfterTheseItemsZ(n, paItems)
			return This.FindNthSplitAfterItems(n, paItems)

		def FindNthSplitAfterManyItemsZ(n, paItems)
			return This.FindNthSplitAfterItems(n, paItems)

		#>

	  #--------------------------------------------#
	 #   FINDING NTH SPLIT AFTER A GIVEN SECTION  #
	#--------------------------------------------#

	def FindNthSplitAfterSection(n, n1, n2)

		if NOT BothAreNumbers(n, n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterSection(n, n1 , n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterThisSection(n, n1, n2)
			return This.FindNthSplitAfterSection(n, n1, n2)

		#--

		def FindNthSplitAfterSectionZ(n, n1, n2)
			return This.FindNthSplitAfterSection(n, n1, n2)

		def FindNthSplitAfterThisSectionZ(n, n1, n2)
			return This.FindNthSplitAfterSection(n, n1, n2)

		#>

	  #---------------------------------------------------------------#
	 #   FINDING NTH SPLIT AFTER A GIVEN SECTION -- INCLUDING BOUND  #
	#---------------------------------------------------------------#

	def FindNthSplitAfterSectionIB(n, n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterSectionIB(n, n1 , n2)
		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterThisSectionIB(n, n1, n2)
			return This.FindNthSplitAfterSectionIB(n, n1, n2)

		#--

		def FindNthSplitAfterSectionIBZ(n, n1, n2)
			return This.FindNthSplitAfterSectionIB(n, n1, n2)

		def FindNthSplitAfterThisSectionIBZ(n, n1, n2)
			return This.FindNthSplitAfterSectionIB(n, n1, n2)


		#>

	  #-------------------------------------------#
	 #   FINDING NTH SPLIT AFTER MANY SECTIONS   #
	#-------------------------------------------#

	def FindNthSplitAfterSections(n, paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterSections(n, paSections)
		return nResult

		#< @FunctionAlternativeForms

		def FindNthSplitAfterTheseSections(n, paSections)
			return This.FindNthSplitAfterTheseSections(n, paSections)

		#--

		def FindNthSplitAfterSectionsZ(n, paSections)
			return This.FindNthSplitAfterSections(n, paSections)

		def FindNthSplitAfterTheseSectionsZ(n, paSections)
			return This.FindNthSplitAfterTheseSections(n, paSections)

		#>

	  #--------------------------------------------------------------#
	 #   FINDING NTH SPLIT AFTER MANY SECTIONS -- INCLUDING BOUNDS  #
	#--------------------------------------------------------------#

	def FindNthSplitAfterSectionsIB(n, paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterSectionsIB(n, paSections)
		return nResult

		#< @FunctionAlternativeForms

		def FindNthSplitAfterTheseSectionsIB(n, paSections)
			return This.FindNthSplitAfterSectionsIB(n, paSections)

		#--

		def FindNthSplitAfterSectionsIBZ(n, paSections)
			return This.FindNthSplitAfterSectionsIB(n, paSections)

		def FindNthSplitAfterTheseSectionsIBZ(n, paSections)
			return This.FindNthSplitAfterSectionsIB(n, paSections)

		#>

	  #---------------------------------------------------------#
	 #  FINDING NTH SPLIT BETWEEN TWO POSITIONS OR Items  #
	#=========================================================#

	def FindNthSplitBetweenCS(n, pItem1, pItem2, pCaseSensitive)

		anFirstBounds  = This.FindAllCS(pItem1, pCaseSensitive)
		anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

		aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
		anFirstBounds  = aListOfBounds[1]
		anSecondBounds = aListOfBounds[2]

		aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)

		nResult = StzSplitterQ( This.NumberOfItems() ).
			   FindNthSplitBetweenSections(n, aSections)

		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitBetweenCSZ(n, pItem1, pItem2, pCaseSensitive)
			return This.FindNthSplitBetweenCS(n, pItem1, pItem2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitBetween(n, pItem1, pItem2)
		return This.FindNthSplitBetweenCS(n, pItem1, pItem2, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitBetweenZ(n, pItem1, pItem2)
			return This.FindNthSplitBetween(n, pItem1, pItem2)

		#>

	  #-----------------------------------------------------------------------------#
	 #  FINDING NTH SPLIT BETWEEN TWO POSITIONS OR Items -- INCLUDING BOUNDS  #
	#-----------------------------------------------------------------------------#

	def FindNthSplitBetweenCSIB(n, pItem1, pItem2, pCaseSensitive)

		anFirstBounds  = This.FindAllCS(pItem1, pCaseSensitive)
		anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

		aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
		anFirstBounds  = aListOfBounds[1]
		anSecondBounds = aListOfBounds[2]

		nLen = len(anFirstBounds)
		for i = 1 to nLen
			anFirstBounds[i]--
			anSecondBounds[i]++
		next

		aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)

		nResult = StzSplitterQ( This.NumberOfItems() ).
			   FindNthSplitBetweenSections(n, aSections)

		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitBetweenCSIBZ(n, pItem1, pItem2, pCaseSensitive)
			return This.FindNthSplitBetweenCSIB(n, pItem1, pItem2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitBetweenIB(n, pItem1, pItem2)
		return This.FindNthSplitBetweenCSIB(n, pItem1, pItem2, TRUE)


		#< @FunctionAlternativeForm

		def FindNthSplitBetweenIBZ(n, pItem1, pItem2)
			return This.FindNthSplitBetweenIB(n, pItem1, pItem2)

		#>

	  #-------------------------------------------#
	 #  FINDING NTH SPLIT BETWEEN TWO POSITIONS  #
	#-------------------------------------------#

	def FindNthSplitBetweenPositions(n, n1, n2)
		This.FindNthSplitAtSection(n, n1, n2)

		#< @FunctionAlternativeForms

		def FindNthSplitBetweenThesePositions(n, n1, n2)
			return This.FindNthSplitBetweenPositions(n, n1, n2)

		#--

		def FindNthSplitBetweenPositionsZ(n, n1, n2)
			return This.FindNthSplitBetweenPositions(n, n1, n2)

		def FindNthSplitBetweenThesePositionsZ(n, n1, n2)
			return This.FindNthSplitBetweenPositions(n, n1, n2)

		#>
		
	  #---------------------------------------------------------------#
	 #  FINDING NTH SPLIT BETWEEN TWO POSITIONS -- INCLUDING BOUNDS  #
	#---------------------------------------------------------------#

	def FindNthSplitBetweenPositionsIB(n, n1, n2)
		This.FindNthSplitAtSectionIB(n, n1, n2)

		#< @FunctionAlternativeForms

		def FindNthSplitBetweenThesePositionsIB(n, n1, n2)
			return This.FindNthSplitBetweenPositionsIB(n, n1, n2)

		#--

		def FindNthSplitBetweenPositionsIBZ(n, n1, n2)
			return This.FindNthSplitBetweenPositionsIB(n, n1, n2)

		def FindNthSplitBetweenThesePositionsIBZ(n, n1, n2)
			return This.FindNthSplitBetweenPositionsIB(n, n1, n2)

		#>

	  #--------------------------------------------#
	 #  FINDING NTH SPLIT BETWEEN TWO Items  #
	#--------------------------------------------#

	def FindNthSplitBetweenItemsCS(n, paItems, pCaseSensitive)
		aSections = This.Find(paItems, pCaseSensitive)
		nResult = This.FindNthSplitBetweenSections(n, aSections)
		return nResult

		#< @FunctionAlternativeForms

		def FindNthSplitBetweenTheseItemsCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitBetweenItemsCS(n, paItems, pCaseSensitive)

		#--

		def FindNthSplitBetweenItemsCSZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitBetweenItemsCS(n, paItems, pCaseSensitive)

		def FindNthSplitBetweenTheseItemsCSZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitBetweenItemsCS(n, paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitBetweenItems(n, paItems)
		return This.FindNthSplitBetweenItemsCS(n, paItems, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSplitBetweenTheseItems(n, paItems)
			return This.FindNthSplitBetweenItems(n, paItems)

		#--

		def FindNthSplitBetweenItemsZ(n, paItems)
			return This.FindNthSplitBetweenItems(n, paItems)

		def FindNthSplitBetweenTheseItemsZ(n, paItems)
			return This.FindNthSplitBetweenItems(n, paItems)

		#>

	  #------------------------------------#
	 #    FINDING NTH SPLIT TO N PARTS    #
	#====================================#

	def FindNthSplitToNParts(n, nPos)
		nResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitToNParts(n, nPos)
		return nResult

		def FindNthSplitToNPartsZ(n, nPos)
			return This.FindNthSplitToNParts(n, nPos)

	  #-----------------------------------------------------#
	 #   FINDING NTH SPLIT TO PARTS OF (EXACTLY) N Items   #
	#-----------------------------------------------------#
	# Remaining part less the n Items is not returned

	def FindNthSplitToPartsOfNItems(n, nPos)
		nResult = StzSplitterQ( This.NumberOfItems() ).
				FindNthSplitToPartsOfExactlyNPositions(n, nPos)

		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitToPartsOfExactlyNItems(n, nPos)
			return This.FindNthSplitToPartsOfNItems(n, nPos)

		#--

		def FindNthSplitToPartsOfNItemsZ(n, nPos)
			return This.FindNthSplitToPartsOfNItems(n, nPos)

		def FindNthSplitToPartsOfExactlyNItemsZ(n, nPos)
			return This.FindNthSplitToPartsOfNItems(n, nPos)

		#>

	  #-------------------------------------------------------#
	 #   FINDING NTH SPLIT TO PARTS OF N Items -- EXTENDED   #
	#-------------------------------------------------------#
	# The remaing part (if any) less then n Items is also returned

	def FindNthSplitToPartsOfNItemsXT(n, nPos)
		nResult = StzSplitterQ( This.NumberOfItems() ).
				FindNthSplitToPartsOfNPositionsXT(n, nPos)

		return nResult

		def FindNthSplitToPartsOfNItemsXTZ(n, nPos)
			return This.FindNthSplitToPartsOfNItemsXT(n, nPos)

	  #----------------------------------------------#
	 #   FINDING NTH SPLIT UNDER A GIVEN CONDTION   #
	#==============================================#

	def FindNthSplitW(n, pcCondition)
		/*
		? StzSplitterQ(1:5).FindNthSplitW('Q(@item).IsMultipleOf(2)')
		*/

		if isList(pcCondition)

			if Q(pcCondition).IsWhereNamedParam()
				return This.FindNthSplitAtW(n, pcCondition[2])

			but Q(pcCondition).IsAtNamedParam()
				return This.FindNthSplitAtW(n, pcCondition[2])

			but Q(pcCondition).IsBeforeNamedParam()
				return This.FindNthSplitBeforeW(n, pcCondition[2])

			but Q(pcCondition).IsAfterNamedParam()
				return This.FindNthSplitAfterW(n, pcCondition[2])

			ok
		
		else

			return This.FindNthSplitAtWZ(n, pcCondition)
		ok

		#< @FunctionAlternativeForm

		def FindNthSplitWZ(n, pcCondition)
			return This.FindNthSplitWZ(n, pcCondition)

		#>

	  #-------------------------------------------#
	 #   FINSING NTH SPLIT AT A GIVEN CONDTION   #
	#-------------------------------------------#

	def FindNthSplitAtW(n, pcCondition)
			
		if isList(pcCondition) and Q(pcCondition).IsWhereNamedParam()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok


		pcCondition = Q(pcCondition).TrimQ().TheseBoundsRemoved( "{","}" )

		if Q(pcCondition).ContainsCS("@Item", :CS = FALSE)

			aSections = This.FindItemsW(pcCondition)
			nResult = This.FindNthSplitAtSectionsZ(n, aSections)

		else

			anPos = This.FindW(pcCondition)
			nResult = This.FindNthSplitAtPositionsZ(n, anPos)
		ok

		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitAtWZ(n, pcCondition)
			return This.FindNthSplitAtW(n, pcCondition)

		#>

	  #-----------------------------------------------#
	 #   FINDING NTH SPLIT BEFORE A GIVEN CONDTION   #
	#-----------------------------------------------#

	def FindNthSplitBeforeW(n, pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsW(pcCondition)

		else
			anPos = This.FindItemsW(pcCondition)
		ok

		nResult = This.FindNthSplitBeforePositions(n, anPos)

		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitBeforeWZ(n, pcCondition)
			return This.FindNthSplitBeforeW(n, pcCondition)

		#>

	  #----------------------------------------------#
	 #   FINDING NTH SPLIT AFTER A GIVEN CONDTION   #
	#----------------------------------------------#

	def FindNthSplitAfterW(n, pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsW(pcCondition)

		else
			anPos = This.FindItemsW(pcCondition)
		ok

		nResult = This.FindNthSplitAfterPositions(n, anPos)

		return nResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterWZ(pcCondition)
			return This.FindNthSplitAfterW(pcCondition)

		#>

	  #====================================================#
	 #   FINDING THE NTH SPLIT AS SECTION -- ZZ/EXTENDED  #
	#====================================================#

	def FindNthSplitCSXTZZ(n, pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isList(pItem)
			return This.FindNthSplitAtItemCSZZ(n, pItem, pCaseSensitive)
		else

			oParam = Q(pItem)

			#-- SPLITTING AT / USING

			if oParam.IsOneOfTheseNamedParams([ :At, :Using ])
				return This.FindNthSplitAtCSZZ(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtPosition, :AtThisPosition ]) 
				return This.FindNthSplitAtPositionZZ(n, pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AtPositions, :AtThesePositions ]) 
				return This.FindNthSplitAtPositionsZZ(n, pItem[2])

			but oParam.IsOneOfTheseNamedParams([
						:AtItem, :AtThisItem,
						:UsingItem, :UsingThisItem ]) 

				return This.FindNthSplitAtItemCSZZ(n, pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([
						:AtItems, :AtTheseItems,
						:UsingItems, :UsingTheseItems ]) 

				return This.FindNthSplitAtItemsCSZZ(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtSection, :AtThisSection ]) 
				return This.FindNthSplitAtSectionZZ(n, pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AtSections, :AtTheseSections ]) 
				return This.FindNthSplitAtSectionsZZ(n, pItem[2])

			#-- SPLITTING BEFORE

			but oParam.IsBeforeNamedParam()
				return This.FindNthSplitBeforeCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforePosition, :BeforeThisPosition ]) 
				return This.FindNthSplitBeforePositionZZ(n, pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :BeforePositions, :BeforeThesePositions ]) 
				return This.FindNthSplitBeforePositionsZZ(n, pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :BeforeItem, :BeforeThisItem ]) 
				return This.FindNthSplitBeforeItemCSZZ(n, pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeItems, :BeforeTheseItems ]) 
				return This.SplitBeforeItemsCSZZ(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforeSection, :BeforeThisSection ]) 
				return This.FindNthSplitBeforeSectionZZ(n, pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeSections, :BeforeTheseSections ]) 
				return This.FindNthSplitBeforeSectionsZZ(n, pItem[2])

			#-- SPLITTING AFTER

			but oParam.IsAfterNamedParam()
				return This.FindNthSplitAfterCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterPosition, :AfterThisPosition ]) 
				return This.FindNthSplitAfterPositionZZ(n, pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AfterPositions, :AfterThesePositions ]) 
				return This.FindNthSplitAfterPositionsZZ(n, pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :AfterItem, :AfterThisItem ]) 
				return This.FindNthSplitAfterItemCSZZ(n, pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :AfterItems, :AfterTheseItems ]) 
				return This.FindNthSplitAfterItemsCSZZ(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterSection, :AfterThisSection ]) 
				return This.FindNthSplitAfterSectionZZ(n, pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AfterSections, :AfterTheseSections ]) 
				return This.FindNthSplitAfterSectionsZZ(n, pItem[2])

			# SPLITTING BETWEEN

			but oParam.IsBetweenNamedParam() and
				isList(pItem) and len(pItem) = 2
				
				if isList(pItem[2]) and Q(pItem[2]).IsAndNamedParam()
					pItem[2] = pItem[2][2]
				ok

				return This.FindNthSplitBetweenCSZZ(n, pItem[1], pItem[2], pCaseSensitive)

			but oParam.IsBetweenPositionsNamedParam()
				return This.FindNthSplitBetweenPositionsZZ(n, pItem[1], pItem[2])

			but oParam.IsBetweenItemsNamedParam()
				return This.FindNthSplitBetweenItemsCSZZ(n, pItem[1], pItem[2], pCaseSensitive)

			# SPLITTING TO PARTS

			but oParam.IsToNPartsNamedParam()
				return This.FindNthSplitToNPartsZZ(n, pItem[2])

			but oParam.IsToPartsOfNItemsNamedParam()
				return This.FindNthSplitToPartsOfNItemsZZ(n, pItem[2])

			# SPLITTING WHERE

			but oParam.IsWhereOrAtWhereNamedParam()
				return This.FindNthSplitAtWZZ(n, pItem[2])

			but oParam.IsBeforeWhereNamedParam()
				return This.FindNthSplitBeforeWZZ(n, pItem[2])

			but oParam.IsAfterWhereNamedParam()
				return This.FindNthSplitAfterWZZ(n, pItem[2])

			else
				return This.FindNthSplitAtItemCSZZ(n, pItem, pCaseSensitive)
			ok
		ok

		#< @FunctionAlternativeForm

		def FindNthSplitAsSectionCSXT(n, pItem, pCaseSensitive)
			return This.FindNthSplitCSXTZZ(n, pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitXTZZ(n, pItem)
		return This.FindNthSplitCSXTXT(n, pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitAsSectionXT(n, pItem)
			return This.FindNthSplitXTZZ(n, pItem)

		#>

	  #----------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) AT A GIVEN ITEM   #
	#====================================================#

	def FindNthSplitAtCSZZ(n, pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isList(pItem)
			return This.FindNthSplitAtItemCSZZ(n, pItem, pCaseSensitive)

		else

			oParam = Q(pItem)

			if oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindNthSplitAtPositionZZ(n, pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindNthSplitAtPositionsZZ(n, pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindNthSplitAtItemCSZZ(n, pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindNthSplitAtItemsCSZZ(n, pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindNthSplitAtSectionZZ(n, pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindNthSplitAtSectionsZZ(n, pItem[2])

			else
				return This.FindNthSplitAtItemCSZZ(n, pItem, pCaseSensitive)
			ok
		ok

		#< @FunctionAlternativeForm

		def FindNthSplitAtAsSectionCS(n, pItem, pCaseSensitive)
			return This.FindNthSplitAtCSZZ(n, pSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitAtZZ(n, pItem)
		return This.FindNthSplitAtCSZZ(n, pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitAtAsSection(n, pItem)
			return This.FindNthSplitAtCSZZ(n, pSubStr)

		#>

	  #--------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) AT A GIVEN POSITION   #
	#========================================================#

	def FindNthSplitAtPositionZZ(n, nPos)
		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect pram type! n must be a number.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAtPositionZZ(n, nPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitAtThisPositionAsSection(n, nPos)
			return This.FindNthSplitAtPositionZZ(n, nPos)

		#>

	  #-----------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) AT MANY POSITIONS  #
	#-----------------------------------------------------#

	def FindNthSplitAtPositionsZZ(n, anPos)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aResult = StzSplitterQ(This.NumberOfItems()).FindNthSplitAtPositionsZZ(n, anPos)
		return aResult

		#< @FunctionAlternativeForms

		def FindNthSplitAtThesePositionsZZ(n, anPos)
			return This.FindNthSplitAtPositionsZZ(n, anPos)

		def FindNthSplitAtManyPositionsZZ(n, anPos)
			return This.FindNthSplitAtPositionsZZ(n, anPos)

		#--

		def FindNthSplitAtPositionsAsSection(n, anPos)
			return This.FindNthSplitAtPositionsZZ(n, anPos)

		def FindNthSplitAtThesePositionsAsSection(n, anPos)
			return This.FindNthSplitAtPositionsZZ(n, anPos)

		def FindNthSplitAtManyPositionsAsSection(n, anPos)
			return This.FindNthSplitAtPositionsZZ(n, anPos)

		#>

	  #---------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) AT A GIVEN ITEM  #
	#===================================================#

	def FindNthSplitAtItemCSZZ(n, pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT IsBoolean(pCaseSensitive)
			StzRaise("Incorrect param type! pCaseSensitive must be a boolean (TRUE or FALSE).")
		ok

		aSections = This.FindAsSectionsCS(pItem, pCaseSensitive)
		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAtSectionsZZ(n, aSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindNthSplitCSZZ(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindNthSplitAtItemCSZZ(n, pItem, pCaseSensitive)

		def FindNthSplitAtThisItemCSZZ(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindNthSplitAtItemCSZZ(n, pItem, pCaseSensitive)

		#--

		def FindNthSplitAtItemAsSectionsCSZZ(pItem, pCaseSensitive)
			return This.FindNthSplitAtItemCSZZ(n, pItem, pCaseSensitive)

		def FindNthSplitAsSectionsCS(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindNthSplitAtItemCSZZ(n, pItem, pCaseSensitive)

		def FindNthSplitAtThisItemAsSectionsCS(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindNthSplitAtItemCSZZ(n, pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitAtItemZZ(pItem)
		return This.FindNthSplitAtItemCSZZ(n, pItem, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSplitZZ(pItem)
			return This.FindNthSplitAtItemZZ(n, pItem, TRUE)

		def FindNthSplitAtThisItemZZ(pItem)
			return This.FindNthSplitAtItemZZ(n, pItem, TRUE)
		#--

		def FindNthSplitAtItemAsSectionZZ(pItem)
			return This.FindNthSplitAtItemZZ(n, pItem, TRUE)

		def FindNthSplitAsSection(pItem)
			return This.FindNthSplitAtItemZZ(n, pItem, TRUE)

		def FindNthSplitAtThisItemAsSection(pItem)
			return This.FindNthSplitAtItemZZ(n, pItem, TRUE)

		#>

	  #--------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTIONS) AT GIVEN Items  #
	#--------------------------------------------------------#

	def FindNthSplitAtItemsCSZZ(n, paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		anPos = This.FindCS(paItems, pCaseSensitive)

		aResult = This.FindNthSplitAtPositionsZZ(n, anPos)
		return aResult

		#< @FunctionAlternativeForms

		def FindNthSplitAtTheseItemsCSZZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitAtItemsCSZZ(n, paItems, pCaseSensitive)

		def FindNthSplitAtManyItemsCSZZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitAtItemsCSZZ(n, paItems, pCaseSensitive)

		#--

		def FindNthSplitAtItemsAsSectionsCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitAtItemsCSZZ(n, paItems, pCaseSensitive)

		def FindNthSplitAtTheseItemsAsSectionsCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitAtItemsCSZZ(n, paItems, pCaseSensitive)

		def FindNthSplitAtManyItemsAsSectionsCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitAtItemsCSZZ(n, paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitAtItemsZZ(n, paItems)
		return This.FindNthSplitAtItemsCSZZ(n, paItems, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSplitAtTheseItemsZZ(n, paItems)
			return This.FindNthSplitAtItemsZZ(n, paItems)
	
		def FindNthSplitAtManyItemsZZ(n, paItems)
			return This.FindNthSplitAtItemsZZ(n, paItems)

		#--

		def FindNthSplitAtItemsAsSections(n, paItems)
			return This.FindNthSplitAtItemsZZ(n, paItems)

		def FindNthSplitAtTheseItemsAsSections(n, paItems)
			return This.FindNthSplitAtItemsZZ(n, paItems)

		def FindNthSplitAtManyItemsAsSections(n, paItems)
			return This.FindNthSplitAtItemsZZ(n, paItems)

		#>

	  #-------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) AT A GIVEN SECTION   #
	#=======================================================#

	def FindNthSplitAtSectionZZ(n, n1, n2)
		if This.IsEmpty()
			return []
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAtSectionZZ(n, n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitAtThisSectionZZ(n, n1, n2)
			return This.FindNthSplitAtSectionZZ(n, n1, n2)

		#--

		def FindNthSplitAtSectionAsSection(n, n1, n2)
			return This.FindNthSplitAtSectionZZ(n, n1, n2)

		def FindNthSplitAtThisSectionAsSection(n, n1, n2)
			return This.FindNthSplitAtSectionZZ(n, n1, n2)

		#>

	  #--------------------------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) AT A GIVEN SECTION -- INCLUDING BOUNDS  #
	#--------------------------------------------------------------------------#

	def FindNthSplitAtSectionIBZZ(n, n1, n2)
		if This.IsEmpty()
			return []
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAtSectionIBZZ(n, n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitAtThisSectionIBZZ(n, n1, n2)
			return This.SplitAtSectionIBZZ(n, n1, n2)

		#--

		def FindNthSplitAtSectionAsSectionIB(n, n1, n2)
			return This.FindNthSplitAtSectionIBZZ(n, n1, n2)

		def FindNthSplitAtThisSectionAsSectionIB(n, n1, n2)
			return This.SplitAtSectionIBZZ(n, n1, n2)

		#>

	  #-----------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) AT MANY SECTIONS   #
	#-----------------------------------------------------#

	def FindNthSplitAtSectionsZZ(n, paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAtSectionsZZ(n, paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindNthSplitAtTheseSectionsZZ(paSections)
			return This.FindNthSplitAtSectionsZZ(paSections)

		#--

		def FindNthSplitAtSectionsAsSection(paSections)
			return This.FindNthSplitAtSectionsZZ(paSections)

		def FindNthSplitAtTheseSectionsAsSection(paSections)
			return This.FindNthSplitAtSectionsZZ(paSections)

		#>

	  #------------------------------------------------------------------------#
	 #   FINDING NTH SPIT (AS SECTION) BEFORE A GIVEN ITEM   #
	#------------------------------------------------------------------------#

	def FindNthSplitBeforeCSZZ(n, pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pItem)
			return This.FindNthSplitBeforeItemCSZZ(n, pItem, pCaseSensitive)

		but isList(pItem) and Q(pItem).IsListOfStrings()
			return This.FindNthSplitBeforeItemsCSZZ(n, pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindNthSplitBeforePositionZZ(n, pItem)

		but isList(pItem) and Q(pItem).IsListOfNumbers()
			return This.FindNthSplitBeforePositionsZZ(n, pItem)

		but isList(pItem) and Q(pItem).IsPairOfNumbers()
			return This.FindNthSplitBeforeSectionZZ(n, pItem[1], pItem[2])

		but isList(pItem) and Q(pItem).IsListOfPairsOfNumbers()
			return This.FindNthSplitBeforeSectionsZZ(n, pItem[1], pItem[2])

		but isList(pItem)

			#-- Case when named params are provided

			if Q(pItem).IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindNthSplitBeforePositionZZ(n, pItem[2])
	
			but Q(pItem).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindNthSplitBeforePositionsZZ(n, pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindNthSplitBeforeItemCSZZ(n, pItem[2], pCaseSensitive)
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindNthSplitBeforeItemsCSZZ(n, pItem[2], pCaseSensitive)

			but Q(pItem).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindNthSplitBeforeSectionZZ(n, pItem[2])
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindNthSplitBeforeSectionsZZ(n, pItem[2])

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeAsSectionCS(n, pItem, pCaseSensitive)
			return This.FindNthSplitBeforeCSZZ(n, pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitBeforeZZ(n, pItem)
		return This.FindNthSplitBeforeCSZZ(n, pItem, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeAsSection(n, pItem)
			return This.FindNthSplitBeforeZZ(n, pItem)

		#>

	  #------------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) BEFORE A GIVEN POSITION   #
	#------------------------------------------------------------#

	def FindNthSplitBeforePositionZZ(n, nPos)
		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforePositionZZ(n, nPos)
		return aResult

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeThisPositionZZ(n, nPos)
			return This.FindNthSplitBeforePositionZZ(n, nPos)

		#--

		def FindNthSplitBeforePositionAsSection(n, nPos)
			return This.FindNthSplitBeforePositionZZ(n, nPos)

		def FindNthSplitBeforeThisPositionAsSection(n, nPos)
			return This.FindNthSplitBeforePositionZZ(n, nPos)

		#>

	  #----------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) BEFORE MANY POSITIONS   #
	#----------------------------------------------------------#

	def FindNthSplitBeforePositionsZZ(n, anPos)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforePositionsZZ(n, anPos)
		return aResult			

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeThesePositionsZZ(n, anPos)
			return This.FindNthSplitBeforePositionsZZ(n, anPos)

		def FindNthSplitBeforeManyPositionsZZ(n, anPos)
			return This.FindNthSplitBeforePositionsZZ(n, anPos)

		#--

		def FindNthSplitBeforePositionsAsSection(n, anPos)
			return This.FindNthSplitBeforePositionsZZ(n, anPos)

		def FindNthSplitBeforeThesePositionsAsSection(n, anPos)
			return This.FindNthSplitBeforePositionsZZ(n, anPos)

		def FindNthSplitBeforeManyPositionsAsSection(n, anPos)
			return This.FindNthSplitBeforePositionsZZ(n, anPos)

		#>

	  #-------------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) BEFORE A GIVEN Item   #
	#-------------------------------------------------------------#

	def FindNthSplitBeforeItemCSZZ(n, pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isString(pItem)
			StzRaise("Incorrect param type! pItem must be a string.")
		ok

		anPos = This.FindCS(pItem, pCaseSensitive)
		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforePositionsZZ(n, anPos)

		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitBeforeThisItemCSZZ(n, pItem, pCaseSensitive)
			return This.FindNthSplitBeforeItemCSZZ(n, pItem, pCaseSensitive)

		#--

		def FindNthSplitBeforeItemAsSectionsCS(n, pItem, pCaseSensitive)
			return This.FindNthSplitBeforeItemCSZZ(n, pItem, pCaseSensitive)

		def FindNthSplitBeforeThisItemAsSectionsCS(n, pItem, pCaseSensitive)
			return This.FindNthSplitBeforeItemCSZZ(n, pItem, pCaseSensitive)

		#>
				
	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitBeforeItemZZ(n, pItem)
		return This.FindNthSplitBeforeItemCSZZ(n, pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitBeforeThisItemZZ(n, pItem)
			return This.FindNthSplitBeforeItem(n, pItem)

		#--

		def FindNthSplitBeforeItemAsSection(n, pItem)
			return This.FindNthSplitBeforeItemZZ(n, pItem)

		def FindNthSplitBeforeThisItemAsSection(n, pItem)
			return This.FindNthSplitBeforeItemZZ(n, pItem)	

		#>

	  #-----------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) BEFORE MANY Items   #
	#-----------------------------------------------------------#

	def FindNthSplitBeforeItemsCSZZ(n, paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paItems) and Q(paItems).IsListOfStrings() )
			StzRaise("Incorrect param type! paItems must be a list of strings.")
		ok

		anPos = This.FindCS( paItems, pCaseSensitive )
		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforePositionsZZ(n, anPos)

		return aResult

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeTheseItemsCSZZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitBeforeItemsCSZZ(n, paItems, pCaseSensitive)

		def FindNthSplitBeforeManyItemsCSZZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitBeforeItemsCSZZ(n, paItems, pCaseSensitive)

		#--

		def FindNthSplitBeforeItemsAsSectionsCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitBeforeItemsCSZZ(n, paItems, pCaseSensitive)

		def FindNthSplitBeforeTheseItemsAsSectionsCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitBeforeItemsCSZZ(n, paItems, pCaseSensitive)

		def FindNthSplitBeforeManyItemsAsSectionsCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitBeforeItemsCSZZ(n, paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitBeforeItemsZZ(n, paItems)
		return This.FindNthSplitBeforeItemsCSZZ(n, paItems, TRUE)
	
		#< @FunctionAlternativeForms

		def FindNthSplitBeforeTheseItemsZZ(n, paItems)
			return This.FindNthSplitBeforeItemsZZ(n, paItems)

		def FindNthSplitBeforeManyItemsZZ(n, paItems)
			return This.FindNthSplitBeforeItemsZZ(n, paItems)

		#--

		def FindNthSplitBeforeItemsAsSection(n, paItems)
			return This.FindNthSplitBeforeItemsZZ(n, paItems)

		def FindNthSplitBeforeTheseItemsAsSection(n, paItems)
			return This.FindNthSplitBeforeItemsZZ(n, paItems)

		def FindNthSplitBeforeManyItemsAsSection(n, paItems)
			return This.FindNthSplitBeforeItemsZZ(n, paItems)

		#>

	  #-----------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) BEFORE A GIVEN SECTION   #
	#-----------------------------------------------------------#

	def FindNthSplitBeforeSectionZZ(n, n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforeSectionZZ(n, n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitBeforeThisSectionZZ(n, n1, n2)
			return This.FindNthSplitBeforeSectionZZ(n, n1, n2)

		#--

		def FindNthSplitBeforeSectionAsSection(n, n1, n2)
			return This.FindNthSplitBeforeSectionZZ(n, n1, n2)

		def FindNthSplitBeforeThisSectionAsSection(n, n1, n2)
			return This.FindNthSplitBeforeSectionZZ(n, n1, n2)

		#>

	  #------------------------------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) BEFORE A GIVEN SECTION -- INCLUDING BOUND   #
	#------------------------------------------------------------------------------#

	def FindNthSplitBeforeSectionIBZZ(n, n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforeSectionIBZZ(n, n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitBeforeThisSectionIBZZ(n, n1, n2)
			return This.FindNthSplitBeforeSectionIBZZ(n, n1, n2)

		#--

		def FindNthSplitBeforeSectionAsSectionsIB(n, n1, n2)
			return This.FindNthSplitBeforeSectionIBZZ(n, n1, n2)

		def FindNthSplitBeforeThisSectionAsSectionsIB(n, n1, n2)
			return This.FindNthSplitBeforeSectionIBZZ(n, n1, n2)

		#>

	  #---------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) BEFORE MANY SECTIONS   #
	#---------------------------------------------------------#

	def FindNthSplitBeforeSectionsZZ(n, paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBeforeSectionsZZ(n, paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeTheseSectionsZZ(n, paSections)
			return This.FindNthSplitBeforeSectionsZZ(n, paSections)

		def FindNthSplitBeforeManySectionsZZ(n, paSections)
			return This.SplitBeforeSectionsZZ(n, paSections)

		#--

		def FindNthSplitBeforeSectionsAsSection(n, paSections)
			return This.FindNthSplitBeforeSectionsZZ(n, paSections)

		def FindNthSplitBeforeTheseSectionsAsSection(n, paSections)
			return This.FindNthSplitBeforeSectionsZZ(n, paSections)

		def FindNthSplitBeforeManySectionsAsSection(n, paSections)
			return This.SplitBeforeSectionsZZ(n, paSections)

		#>

	  #--------------------------------------------------------------------------#
	 #   FINING NTH SPLIT (AS SECTION) BEFORE MANY SECTIONS -- INCLUDING BOUND  #
	#--------------------------------------------------------------------------#

	def FindNthSplitBeforeSectionsIBZZ(n, paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).SplitBeforeSectionsIBZZ(n, paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindNthSplitBeforeTheseSectionsIBZZ(n, paSections)
			return This.FindNthSplitBeforeSectionsIBZZ(n, paSections)

		def FindNthSplitBeforeManySectionsIBZZ(n, paSections)
			return This.FindNthSplitBeforeSectionsIBZZ(paSections)

		#--

		def FindNthSplitBeforeSectionsAsSectionIB(n, paSections)
			return This.FindNthSplitBeforeSectionsIBZZ(n, paSections)

		def FindNthSplitBeforeTheseSectionsAsSectionIB(n, paSections)
			return This.FindNthSplitBeforeSectionIBZZ(n, paSections)

		def FindNthSplitBeforeManySectionsAsSectionIB(n, paSections)
			return This.FindNthSplitBeforeSectionIBZZ(n, paSections)

		#>

	  #-----------------------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) AFTER A GIVEN ITEM  #
	#-----------------------------------------------------------------------#

	def FindNthSplitAfterCSZZ(n, pItem, pCaseSensitive)
		if isString(pItem)
			return This.FindNthSplitAfterItemCSZZ(n, pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindNthSplitAfterPositionZZ(n, pItem)

		but isList(pItem)

			#-- Case when named params are provided

			if Q(pItem).IsOneOfTheseNamedParams([ :Position, :ThisPosition ])

				return This.FindNthSplitAfterPositionZZ(n, pItem[2])
	
			but Q(pItem).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindNthSplitAfterPositionsZZ(n, pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindNthSplitAfterItemCSZZ(n, pItem[2], pCaseSensitive)
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindNthSplitAfterItemsCSZZ(n, pItem[2], pCaseSensitive)

			but Q(pItem).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindNthSplitAfterSectionZZ(n, pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindNthSplitAfterSectionsZZ(n, pItem[2])

			#-- Providing numbers, strings, or pairs of numbers,
			#   directly without named params

			but Q(pItem).IsListOfNumbers()
				return This.FindNthSplitAfterPositionsZZ(n, pItem)

			but Q(pItem).IsListOfStrings()
				return This.FindNthSplitAfterItemsZZ(n, pItem)

			but Q(pItem).IsListOfPairsOfNumbers()
				return This.FindNthSplitAfterSectionsZZ(n, pItem)

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindNthSplitAfterAsSectionCS(n, pItem, pCaseSensitive)
			return This.FindNthSplitAfterCSZZ(n, pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitAfterZZ(n, pItem)
		return This.FindNthSplitAfterCSZZ(n, pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitAfterAsSection(n, pItem)
			return This.FindNthSplitAfterCSZZ(n, pItem, pCaseSensitive)

		#>

	  #-------------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) BEFORE A GIVEN POSITION   #
	#-------------------------------------------------------------#

	def FindNthSplitAfterPositionZZ(n, Pos)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterPositionZZ(n, nPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterThisPositionZZ(n, nPos)
			return This.FindNthSplitAfterPositionZZ(n, nPos)

		def FindNthSplitAfterThisPositionAsSection(n, nPos)
			return This.FindNthSplitAfterPositionZZ(n, nPos)

		#>

	  #----------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) BEFORE MANY POSITIONS   #
	#----------------------------------------------------------#

	def FindNthSplitAfterPositionsZZ(n, anPos)
		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterPositionsZZ(n, anPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterThesePositionsZZ(n, anPos)
			return This.FindNthSplitAfterThesePositionsZZ(n, anPos)

		def FindNthSplitAfterManyPositionsZZ(n, anPos)
			return This.FindNthSplitAfterManyPositionsZZ(n, anPos)

		#--

		def FindNthSplitAfterPositionsAsSection(n, anPos)
			return This.FindNthSplitAfterPositionsZZ(anPos)

		def FindNthSplitAfterThesePositionsAsSection(n, anPos)
			return This.FindNthSplitAfterThesePositionsZZ(n, anPos)

		def FindNthSplitAfterManyPositionsAsSection(n, anPos)
			return This.FindNthSplitAfterManyPositionsZZ(n, anPos)

		#>

	  #-------------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) BEFORE A GIVEN Item   #
	#-------------------------------------------------------------#

	def FindNthSplitAfterItemCSZZ(n, pItem, pCaseSensitive)
		if NOT isString(pItem)
			StzRaise("Incorrect param type! pItem must be a string.")
		ok

		anPos = This.FindCS(pItem, pCaseSensitive)
		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterPositionsZZ(n, anPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterThisItemCSZZ(n, pItem, pCaseSensitive)
			return This.FindNthSplitAfterItemCSZZ(n, pItem, pCaseSensitive)

		#--

		def FindNthSplitAfterItemAsSectionCS(n, pItem, pCaseSensitive)
			return This.FindNthSplitAfterItemCSZZ(n, pItem, pCaseSensitive)

		def FindNthSplitAfterThisItemAsSectionCS(n, pItem, pCaseSensitive)
			return This.FindNthSplitAfterItemCSZZ(n, pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitAfterItemZZ(n, pItem)
		return This.FindNthSplitAfterItemCSZZ(n, pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitAfterThisItemZZ(n, pItem)
			return This.FindNthSplitAfterItemZZ(n, pItem)

		#--

		def FindNthSplitAfterItemAsSection(n, pItem)
			return This.FindNthSplitAfterItemZZ(n, pItem)

		def FindNthSplitAfterThisItemAsSection(n, pItem)
			return This.FindNthSplitAfterItemZZ(n, pItem)

		#>

	  #-----------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) BEFORE MANY Items   #
	#-----------------------------------------------------------#

	def FindNthSplitAfterItemsCSZZ(n, paItems, pCaseSensitive)
		if NOT ( isList(paItems) and Q(paItems).IsListOfStrings() )
			StzRaise("Incorrect param type! paItems must be a list of strings.")
		ok

		anPos = This.FindCS( paItems, pCaseSensitive )
		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterPositionsZZ(n, anPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterTheseItemsCSZZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitAfterItemsCSZZ(n, paItems, pCaseSensitive)

		def FindNthSplitAfterManyItemsCSZZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitAfterItemsCSZZ(n, paItems, pCaseSensitive)

		#--

		def FindNthSplitAfterItemsAsSectionCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitAfterItemsCSZZ(n, paItems, pCaseSensitive)

		def FindNthSplitAfterTheseItemsAsSectionCS(paItems, pCaseSensitive)
			return This.FindNthSplitAfterItemsCSZZ(n, paItems, pCaseSensitive)

		def FindNthSplitAfterManyItemsAsSectionCSZZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitAfterItemsCSZZ(n, paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitAfterItemsZZ(n, paItems)
		return This.FindNthSplitAfterItemsCSZZ(n, paItems, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitAfterTheseItemsZZ(n, paItems)
			return This.FindNthSplitAfterItemsZZ(n, paItems)

		def FindNthSplitAfterManyItemsZZ(n, paItems)
			return This.FindNthSplitAfterItemsZZ(n, paItems)

		#--

		def FindNthSplitAfterItemsAsSection(n, paItems)
			return This.FindNthSplitAfterItemsZZ(n, paItems)

		def FindNthSplitAfterTheseItemsAsSection(n, paItems)
			return This.FindNthSplitAfterItemsZZ(n, paItems)

		def FindNthSplitAfterManyItemsAsSectionZZ(n, paItems)
			return This.FindNthSplitAfterItemsZZ(paItems)

		#>

	  #----------------------------------------------------------#
	 #   FINDING NTH SPLIT (َAS SECTION) AFTER A GIVEN SECTION   #
	#----------------------------------------------------------#

	def FindNthSplitAfterSectionZZ(n, n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterSectionZZ(n, n1 , n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterThisSectionZZ(n, n1, n2)
			return This.FindNthSplitAfterSectionZZ(n, n1, n2)

		#--

		def FindNthSplitAfterSectionAsSections(n, n1, n2)
			return This.FindNthSplitAfterSectionZZ(n, n1, n2)

		def FindNthSplitAfterThisSectionAsSections(n, n1, n2)
			return This.FindNthSplitAfterSectionZZ(n, n1, n2)

		#>

	  #----------------------------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) AFTER A GIVEN SECTION -- INCLUDING BOUND  #
	#----------------------------------------------------------------------------#

	def FindNthSplitAfterSectionIBZZ(n, n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterSectionIBZZ(n, n1 , n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterThisSectionIBZZ(n, n1, n2)
			return This.FindNthSplitAfterSectionIBZZ(n, n1, n2)

		#--

		def FindNthSplitAfterSectionAsSectionIB(n, n1, n2)
			return This.FindNthSplitAfterSectionIBZZ(n, n1, n2)

		def FindNthSplitAfterThisSectionAsSectionIB(n, n1, n2)
			return This.FindNthSplitAfterSectionIBZZ(n1, n2)

		#>

	  #--------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) AFTER MANY SECTIONS   #
	#--------------------------------------------------------#

	def FindNthSplitAfterSectionsZZ(n, paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterSectionsZZ(n, paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindNthSplitAfterTheseSectionsZZ(n, paSections)
			return This.FindNthSplitAfterTheseSectionsZZ(n, paSections)

		#--

		def FindNthSplitAfterSectionsAsSection(n, paSections)
			return This.FindNthSplitAfterSectionsZZ(n, paSections)

		def FindNthSplitAfterTheseSectionsAsSection(n, paSections)
			return This.FindNthSplitAfterTheseSectionsZZ(n, paSections)

		#>

	  #---------------------------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) AFTER MANY SECTIONS -- INCLUDING BOUNDS  #
	#---------------------------------------------------------------------------#

	def FindNthSplitAfterSectionsIBZZ(n, paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitAfterSectionsIBZZ(n, paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindNthSplitAfterTheseSectionsIBZZ(n, paSections)
			return This.FindNthSplitAfterSectionsIBZZ(n, paSections)

		#--

		def FindNthSplitAfterSectionsAsSectionsIB(n, paSections)
			return This.FindNthSplitAfterSectionsIBZZ(n, paSections)

		def FindNthSplitAfterTheseSectionsAsSectionsIB(n, paSections)
			return This.FindNthSplitAfterSectionsIBZZ(n, paSections)

		#>

	  #----------------------------------------------------------------------#
	 #  FINDING NTH SPLIT (AS SECTION) BETWEEN TWO POSITIONS OR Items  #
	#======================================================================#

	def FindNthSplitBetweenCSZZ(n, pItem1, pItem2, pCaseSensitive)
		if NOT ( BothAreStringsOrNumbers(pItem1, pItem2) )
			StzRaise("Incorrect params types! pItem1 and pItem2 must be both numbers or strings.")
		ok

		if BothAreNumbers(pItem1, pItem2)
			aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBetweenZZ(n, pItem1, pItem2)

		else # case if BothAreStrings()
			anFirstBounds  = This.FindAllCS(pItem1, pCaseSensitive)
			anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

			aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
			anFirstBounds  = aListOfBounds[1]
			anSecondBounds = aListOfBounds[2]

			aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)

			aResult = StzSplitterQ( This.NumberOfItems() ).
				   FindNthSplitBetweenSectionsZZ(n, aSections)
		ok
		
		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitBetweenAsSectionCS(n, pItem1, pItem2, pCaseSensitive)
			return This.FindNthSplitBetweenCSZZ(n, pItem1, pItem2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitBetweenZZ(n, pItem1, pItem2)
		return This.FindNthSplitBetweenCS(n, pItem1, pItem2, TRUE)

		#< @FunctionAlternativeForm

		def FindNthSplitBetweenAsSection(n, pItem1, pItem2)
			return This.FindNthSplitBetweenZZ(n, pItem1, pItem2)

		#>

	  #------------------------------------------------------------------------------------------#
	 #  FINDING NTH SPLIT (AS SECTION) BETWEEN TWO POSITIONS OR Items -- INCLUDING BOUNDS  #
	#------------------------------------------------------------------------------------------#

	def FindNthSplitBetweenCSIBZZ(n, pItem1, pItem2, pCaseSensitive)
		if NOT ( BothAreStringsOrNumbers(pItem1, pItem2) )
			StzRaise("Incorrect params types! pItem1 and pItem2 must be both numbers or strings.")
		ok

		if BothAreNumbers(pItem1, pItem2)
			aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitBetweenIBZZ(n, pItem1, pItem2)

		else # case if BothAreStrings()
			anFirstBounds  = This.FindAllCS(pItem1, pCaseSensitive)
			anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

			aListOfBounds  = StzListOfListsQ([ anFirstBounds, anSecondBounds ]).ReducedToSmallestSize()
			anFirstBounds  = aListOfBounds[1]
			anSecondBounds = aListOfBounds[2]

			nLen = len(anFirstBounds)
			for i = 1 to nLen
				anFirstBounds[i]--
				anSecondBounds[i]++
			next

			aSections = Q(anFirstBounds).AssociatedWith(anSecondBounds)

			aResult = StzSplitterQ( This.NumberOfItems() ).
				   FindNthSplitBetweenSectionsZZ(n, aSections)
		ok

		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitBetweenAsSectionCSIB(n, pItem1, pItem2, pCaseSensitive)
			return This.FindNthSplitBetweenCSIBZZ(n, pItem1, pItem2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitBetweenIBZZ(n, pItem1, pItem2)
		return This.FindNthSplitBetweenCSIBZZ(n, pItem1, pItem2, TRUE)


		#< @FunctionAlternativeForm

		def FindNthSplitBetweenAsSectionIB(n, pItem1, pItem2)
			return This.FindNthSplitBetweenIBZZ(n, pItem1, pItem2)

		#>

	  #--------------------------------------------------------#
	 #  FINDING NTH SPLIT (AS SECTION) BETWEEN TWO POSITIONS  #
	#--------------------------------------------------------#

	def FindNthSplitBetweenPositionsZZ(n, n1, n2)
		This.FindNthSplitAtSectionZZ(n, n1, n2)

		#< @FunctionAlternativeForms

		def FindNthSplitBetweenThesePositionsZZ(n, n1, n2)
			return This.FindNthSplitBetweenPositionsZZ(n, n1, n2)

		#--

		def FindNthSplitBetweenPositionsAsSection(n, n1, n2)
			return This.FindNthSplitBetweenPositionsZZ(n, n1, n2)

		def FindNthSplitBetweenThesePositionsAsSection(n, n1, n2)
			return This.FindNthSplitBetweenPositionsZZ(n, n1, n2)

		#>
		
	  #-----------------------------------------------------------------------------#
	 #  FINDING NTH SPLIT (AS SECTIONS) BETWEEN TWO POSITIONS -- INCLUDING BOUNDS  #
	#-----------------------------------------------------------------------------#

	def FindNthSplitBetweenPositionsIBZZ(n, n1, n2)
		This.FindNthSplitAtSectionIBZZ(n, n1, n2)

		#< @FunctionAlternativeForms

		def FindNthSplitBetweenThesePositionsIBZZ(n, n1, n2)
			return This.FindNthSplitBetweenPositionsIBZZ(n, n1, n2)

		#--

		def FindNthSplitBetweenPositionsAsSectionIB(n, n1, n2)
			return This.FindNthSplitBetweenPositionsIBZZ(n, n1, n2)

		def FindNthSplitBetweenThesePositionsAsSectionIB(n, n1, n2)
			return This.FindNthSplitBetweenPositionsIBZZ(n, n1, n2)

		#>

	  #---------------------------------------------------------#
	 #  FINDING NTH SPLIT (AS SECTION) BETWEEN TWO Items  #
	#---------------------------------------------------------#

	def FindNthSplitBetweenItemsCSZZ(n, paItems, pCaseSensitive)
		aSections = This.FindAsSections(paItems, pCaseSensitive)
		aResult = This.FindNthSplitBetweenSectionsZZ(n, aSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindNthSplitBetweenTheseItemsCSZZ(n, paItems, pCaseSensitive)
			return This.FindNthSplitBetweenItemsCSZZ(n, paItems, pCaseSensitive)

		#--

		def FindNthSplitBetweenItemsAsSectionCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitBetweenItemsCSZZ(n, paItems, pCaseSensitive)

		def FindNthSplitBetweenTheseItemsAsSectionCS(n, paItems, pCaseSensitive)
			return This.FindNthSplitBetweenItemsCSZZ(n, paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSplitBetweenItemsZZ(n, paItems)
		return This.FindNthSplitBetweenItemsCSZZ(n, paItems, TRUE)

		#< @FunctionAlternativeForms

		def FindNthSplitBetweenTheseItemsZZ(n, paItems)
			return This.FindNthSplitBetweenItemsZZ(n, paItems)

		#--

		def FindNthSplitBetweenItemsAsSection(n, paItems)
			return This.FindNthSplitBetweenItemsZZ(n, paItems)

		def FindNthSplitBetweenTheseItemsAsSection(n, paItems)
			return This.FindNthSplitBetweenItemsZZ(n, paItems)

		#>

	  #-------------------------------------------------#
	 #    FINDING NTH SPLIT (AS SECTION) TO N PARTS    #
	#=================================================#

	def FindNthSplitToNPartsZZ(n, nPos)
		aResult = StzSplitterQ( This.NumberOfItems() ).FindNthSplitToNPartsZZ(n, nPos)
		return aResult

		def FindNthSplitToNPartsAsSection(n, nPos)
			return This.FindNthSplitToNPartsZZ(n, nPos)

	  #-----------------------------------------------------#
	 #   FINDING NTH SPLIT TO PARTS OF (EXACTLY) N Items   #
	#-----------------------------------------------------#
	# Remaining part less the n Items is not returned

	def FindNthSplitToPartsOfNItemsZZ(n, nPos)
		aResult = StzSplitterQ( This.NumberOfItems() ).
				FindNthSplitToPartsOfExactlyNPositionsZZ(n, nPos)

		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitToPartsOfExactlyNItemsZZ(n, nPos)
			return This.FindNthSplitToPartsOfNItemsZZ(n, nPos)

		#--

		def FindNthSplitToPartsOfNItemsAsSection(n, nPos)
			return This.FindNthSplitToPartsOfNItemsZZ(n, nPos)

		def FindNthSplitToPartsOfExactlyNItemsAsSection(n, nPos)
			return This.FindNthSplitToPartsOfNItemsZZ(n, nPos)

		#>

	  #----------------------------------------------------------------------------#
	 #   FINDING NTH SPLIT (AS SECTION) TO PARTS OF N Items -- INCLUDING BOUNDS   #
	#----------------------------------------------------------------------------#
	# The remaing part (if any) less then n Items is also returned

	def FindNthSplitToPartsOfNItemsIBZZ(n, nPos)
		aResult = StzSplitterQ( This.NumberOfItems() ).
				FindNthSplitToPartsOfNPositionsIBZZ(n, nPos)

		return aResult

	  #------------------------------------------------------------#
	 #    FINDING NTH SPLIT (AS SECTION) UNDER A GIVEN CONDTION   #
	#============================================================#

	def FindNthSplitWZZ(n, pcCondition)

		if isList(pcCondition)

			if Q(pcCondition).IsWhereNamedParam()
				return This.FindNthSplitAtWZZ(n, pcCondition[2])

			but Q(pcCondition).IsAtNamedParam()
				return This.FindNthSplitAtWZZ(n, pcCondition[2])

			but Q(pcCondition).IsBeforeNamedParam()
				return This.FindNthSplitBeforeWZZ(n, pcCondition[2])

			but Q(pcCondition).IsAfterNamedParam()
				return This.FindNthSplitAfterWZZ(n, pcCondition[2])

			ok
		
		else

			return This.FindNthSplitAtWZZ(n, pcCondition)
		ok

		#< @FunctionAlternativeForm

		def FindNthSplitAsSectionW(n, pcCondition)
			return This.FindNthSplitWZZ(n, pcCondition)

		#>

	  #---------------------------------------------------------#
	 #    FINSING NTH SPLIT (AS SECTION) AT A GIVEN CONDTION   #
	#---------------------------------------------------------#

	def FindNthSplitAtWZZ(n, pcCondition)
			
		if isList(pcCondition) and Q(pcCondition).IsWhereNamedParam()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		aResult = []

		pcCondition = Q(pcCondition).TrimQ().TheseBoundsRemoved( "{","}" )

		if Q(pcCondition).ContainsCS("@Item", :CS = FALSE)

			aSections = This.FindItemsAsSectionsW(pcCondition)
			aResult = This.FindNthSplitAtSectionsZZ(n, aSections)

		else

			anPos = This.FindW(pcCondition)
			aResult = This.FindNthSplitAtPositionsZZ(n, anPos)
		ok

		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitAtAsSectionW(n, pcCondition)
			return This.FindNthSplitAtWZZ(n, pcCondition)

		#>

	  #--------------------------------------------------------------#
	 #    FINDING NTH SPLIT (AS SECTIONS) BEFORE A GIVEN CONDTION   #
	#--------------------------------------------------------------#

	def FindNthSplitBeforeWZZ(n, pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsW(pcCondition)

		else
			anPos = This.FindItemsW(pcCondition)
		ok

		aResult = This.FindNthSplitBeforePositionsZZ(n, anPos)

		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitBeforeAsSectionW(n, pcCondition)
			return This.FindNthSplitBeforeWZZ(n, pcCondition)

		#>

	  #------------------------------------------------------------#
	 #    FINDING NTH SPLIT (AS SECTION) AFTER A GIVEN CONDTION   #
	#------------------------------------------------------------#

	def FindNthSplitAfterWZZ(n, pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsW(pcCondition)

		else
			anPos = This.FindItemsW(pcCondition)
		ok

		aResult = This.FindNthSplitAfterPositionsZZ(n, anPos)

		return aResult

		#< @FunctionAlternativeForm

		def FindNthSplitAfterAsSectionW(n, pcCondition)
			return This.FindNthSplitAfterWZZ(n, pcCondition)

		#>

	  #============================#
	 #   FINDING THE LAST SPLIT   #
	#============================#

	def FindLastSplitCSXT(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pItem)
			return This.FindLastSplitAtItemCS(pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindLastSplitAtPosition(pItem)

		but isList(pItem) and Q(pItem).IsListOfNumbers()
			return This.FindLastSplitAtPositions(pItem)

		but isList(pItem) and Q(pItem).IsPairOfNumbers()
			return This.FindLastSplitAtSection(pItem[1], pItem[2])

		but isList(pItem) and Q(pItem).IsListOfPairsOfNumbers()
			return This.FindLastSplitAtSections(pItem)

		but isList(pItem)

			oParam = Q(pItem)

			#-- SPLITTING AT / USING

			if oParam.IsOneOfTheseNamedParams([ :At, :Using ])
				return This.FindLastSplitAtCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtPosition, :AtThisPosition ]) 
				return This.FindLastSplitAtPosition(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AtPositions, :AtThesePositions ]) 
				return This.FindLastSplitAtPositions(pItem[2])

			but oParam.IsOneOfTheseNamedParams([
						:AtItem, :AtThisItem,
						:UsingItem, :UsingThisItem ]) 

				return This.FindLastSplitAtItemCS(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([
						:AtItems, :AtTheseItems,
						:UsingItems, :UsingTheseItems ]) 

				return This.FindLastSplitAtItemsCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtSection, :AtThisSection ]) 
				return This.FindLastSplitAtSection(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AtSections, :AtTheseSections ]) 
				return This.FindLastSplitAtSections(pItem[2])

			#-- SPLITTING BEFORE

			but oParam.IsBeforeNamedParam()
				return This.FindLastSplitBeforeCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforePosition, :BeforeThisPosition ]) 
				return This.FindLastSplitBeforePosition(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :BeforePositions, :BeforeThesePositions ]) 
				return This.FindLastSplitBeforePositions(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :BeforeItem, :BeforeThisItem ]) 
				return This.FindLastSplitBeforeItemCS(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeItems, :BeforeTheseItems ]) 
				return This.SplitBeforeItemsCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforeSection, :BeforeThisSection ]) 
				return This.FindLastSplitBeforeSection(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeSections, :BeforeTheseSections ]) 
				return This.FindLastSplitBeforeSections(pItem[2])

			#-- SPLITTING AFTER

			but oParam.IsAfterNamedParam()
				return This.FindLastSplitAfterCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterPosition, :AfterThisPosition ]) 
				return This.FindLastSplitAfterPosition(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AfterPositions, :AfterThesePositions ]) 
				return This.FindLastSplitAfterPositions(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :AfterItem, :AfterThisItem ]) 
				return This.FindLastSplitAfterItemCS(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :AfterItems, :AfterTheseItems ]) 
				return This.FindLastSplitAfterItemsCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterSection, :AfterThisSection ]) 
				return This.FindLastSplitAfterSection(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AfterSections, :AfterTheseSections ]) 
				return This.FindLastSplitAfterSections(pItem[2])

			# SPLITTING BETWEEN

			but oParam.IsBetweenNamedParam() and
				isList(pItem) and len(pItem) = 2
				
				if isList(pItem[2]) and Q(pItem[2]).IsAndNamedParam()
					pItem[2] = pItem[2][2]
				ok

				return This.FindLastSplitBetweenCS(pItem[1], pItem[2], pCaseSensitive)

			but oParam.IsBetweenPositionsNamedParam()
				return This.FindLastSplitBetweenPositions(pItem[1], pItem[2])

			but oParam.IsBetweenItemsNamedParam()
				return This.FindLastSplitBetweenItemsCS(pItem[1], pItem[2], pCaseSensitive)

			# SPLITTING TO PARTS

			but oParam.IsToNPartsNamedParam()
				return This.FindLastSplitToNParts(pItem[2])

			but oParam.IsToPartsOfNItemsNamedParam()
				return This.FindLastSplitToPartsOfNItems(pItem[2])

			# SPLITTING WHERE

			but oParam.IsWhereOrAtWhereNamedParam()
				return This.FindLastSplitAtW(pItem[2])

			but oParam.IsBeforeWhereNamedParam()
				return This.FindLastSplitBeforeW(pItem[2])

			but oParam.IsAfterWhereNamedParam()
				return This.FindLastSplitAfterW(pItem[2])

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindLastSplitCSXTZ(pItem, pCaseSensitive)
			return This.FindLastSplitCSXT(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitXT(pItem)
		return This.FindLastSplitCSXT(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitXTZ(pItem)
			return This.FindLastSplitXT(pItem)

		#>

	  #--------------------------------------------------------#
	 #   FINDING LAST SPLIT AT A GIVEN Item  #
	#========================================================#

	def FindLastSplitAtCS(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pItem)
			return This.FindLastSplitAtItemCS(pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindLastSplitAtPosition(pItem)

		but isList(pItem) and Q(pItem).IsListOfNumbers()
			return This.FindLastSplitAtPositions(pItem)

		but isList(pItem) and Q(pItem).IsPairOfNumbers()
			return This.FindLastSplitAtSection(pItem[1], pItem[2])

		but isList(pItem) and Q(pItem).IsListOfPairsOfNumbers()
			return This.FindLastSplit(pItem)

		but isList(pItem)

			oParam = Q(pItem)

			#-- Case when named params are provided

			if oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindLastSplitAtPosition(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindLastSplitAtPositions(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindLastSplitAtItemCS(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindLastSplitAtItemsCS(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindLastSplitAtSection(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindLastSplitAtSections(pItem[2])

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindLastSplitAtCSZ(pItem, pCaseSensitive)
			return This.FindLastSplitAtCS(pSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitAt(pItem)
		return This.FindLastSplitAtCS(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitAtZ(pItem)
			return This.FindLastSplitAtCS(pSubStr)

		#>

	  #--------------------------------------------#
	 #   FINDING LAST SPLIT AT A GIVEN POSITION   #
	#============================================#

	def FindLastSplitAtPosition(nPos)
		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(nPos)
			StzRaise("Incorrect pram type! n must be a number.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAtPosition(nPos)
		return nResult

		#< @FunctionAlternativeForm

		def FindLastSplitAtThisPosition(nPos)
			return This.FindLastSplitAtPosition(nPos)

		def FindLastSplitAtPositionZ(nPos)
			return This.FindLastSplitAtPosition(nPos)

		def FindLastSplitAtThisPositionZ(nPos)
			return This.FindLastSplitAtPosition(nPos)

		#>

	  #------------------------------------------#
	 #   FINDING LAST SPLIT AT MANY POSITIONS   #
	#------------------------------------------#

	def FindLastSplitAtPositions(anPos)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		nResult = StzSplitterQ(This.NumberOfItems()).FindLastSplitAtPositions(anPos)
		return nResult

		#< @FunctionAlternativeForms

		def FindLastSplitAtThesePositions(anPos)
			return This.FindLastSplitAtPositions(anPos)

		def FindLastSplitAtManyPositions(anPos)
			return This.FindLastSplitAtPositions(anPos)

		#--

		def FindLastSplitAtPositionsZ(anPos)
			return This.FindLastSplitAtPositions(anPos)

		def FindLastSplitAtThesePositionsZ(anPos)
			return This.FindLastSplitAtPositions(anPos)

		def FindLastSplitAtManyPositionsZ(anPos)
			return This.FindLastSplitAtPositions(anPos)

		#>

	  #---------------------------------------------#
	 #   FINDING LAST SPLIT AT A GIVEN Item   #
	#=============================================#

	def FindLastSplitAtItemCS(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isString(pItem)
			StzRaise("Incorrect param type! pItem must be a string.")
		ok

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT IsBoolean(pCaseSensitive)
			StzRaise("Incorrect param type! pCaseSensitive must be a boolean (TRUE or FALSE).")
		ok

		aSections = This.FindCS(pItem, pCaseSensitive)
		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAtSections(aSections)
		return nResult

		#< @FunctionAlternativeForms

		def FindLastSplitCS(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindLastSplitAtItemCS(pItem, pCaseSensitive)

		def FindLastSplitAtThisItemCS(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindLastSplitAtItemCS(pItem, pCaseSensitive)

		#--

		def FindLastSplitAtItemCSZ(pItem, pCaseSensitive)
			return This.FindLastSplitAtItemCS(pItem, pCaseSensitive)

		def FindLastSplitCSZ(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindLastSplitAtItemCS(pItem, pCaseSensitive)

		def FindLastSplitAtThisItemCSZ(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindLastSplitAtItemCS(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitAtItem(pItem)
		return This.FindLastSplitAtItemCS(pItem, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSplit(pItem)
			return This.FindLastSplitCS(pItem, TRUE)

		def FindLastSplitAtThisItem(pItem)
			return This.FindLastSplitAtThisItemCS(pItem, TRUE)
		#--

		def FindLastSplitAtItemZ(pItem)
			return This.FindLastSplitAtItemCS(pItem, TRUE)

		def FindLastSplitZ(pItem)
			return This.FindLastSplitCS(pItem, TRUE)

		def FindLastSplitAtThisItemZ(pItem)
			return This.FindLastSplitAtThisItemCS(pItem, TRUE)

		#>

	  #--------------------------------------------#
	 #   FINDING LAST SPLIT AT GIVEN Items   #
	#--------------------------------------------#

	def FindLastSplitAtItemsCS(paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		anPos = This.FindCS(paItems, pCaseSensitive)
		nResult = This.FindLastSplitAtPositions(anPos)

		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitAtTheseItemsCS(paItems, pCaseSensitive)
			return This.FindLastSplitAtItemsCS(paItems, pCaseSensitive)

		def FindLastSplitAtManyItemsCS(paItems, pCaseSensitive)
			return This.FindLastSplitAtItemsCS(paItems, pCaseSensitive)

		#--

		def FindLastSplitAtItemsCSZ(paItems, pCaseSensitive)
			return This.FindLastSplitAtItemsCS(paItems, pCaseSensitive)

		def FindLastSplitAtTheseItemsCSZ(paItems, pCaseSensitive)
			return This.FindLastSplitAtItemsCS(paItems, pCaseSensitive)

		def FindLastSplitAtManyItemsCSZ(paItems, pCaseSensitive)
			return This.FindLastSplitAtItemsCS(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitAtItems(paItems)
		return This.FindLastSplitAtItemsCS(paItems, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSplitAtTheseItems(paItems)
			return This.FindLastSplitAtItems(paItems)
	
		def FindLastSplitAtManyItems(paItems)
			return This.FindLastSplitAtItems(paItems)

		#--

		def FindLastSplitAtItemsZ(paItems)
			return This.FindLastSplitAtItems(paItems)

		def FindLastSplitAtTheseItemsZ(paItems)
			return This.FindLastSplitAtItems(paItems)

		def FindLastSplitAtManyItemsZ(paItems)
			return This.FindLastSplitAtItems(paItems)

		#>

	  #-------------------------------------------#
	 #   FINDING LAST SPLIT AT A GIVEN SECTION   #
	#===========================================#

	def FindLastSplitAtSection(n1, n2)
		if This.IsEmpty()
			return []
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAtSection(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAtThisSection(n1, n2)
			return This.FindLastSplitAtSection(n1, n2)

		#--

		def FindLastSplitAtSectionZ(n1, n2)
			return This.FindLastSplitAtSection(n1, n2)

		def FindLastSplitAtThisSectionZ(n1, n2)
			return This.FindLastSplitAtSection(n1, n2)

		#>

	  #--------------------------------------------------------------#
	 #   FINDING LAST SPLIT AT A GIVEN SECTION -- INCLUDING BOUNDS  #
	#--------------------------------------------------------------#

	def FindLastSplitAtSectionIB(n1, n2)
		if This.IsEmpty()
			return []
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAtSectionIB(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAtThisSectionIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		#--

		def FindLastSplitAtSectionIBZ(n1, n2)
			return This.FindLastSplitAtSectionIB(n1, n2)

		def FindLastSplitAtThisSectionIBZ(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		#>

	  #-----------------------------------------#
	 #   FINDING LAST SPLIT AT MANY SECTIONS   #
	#-----------------------------------------#

	def FindLastSplitAtSections(paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAtSections(paSections)
		return nResult

		#< @FunctionAlternativeForms

		def FindLastSplitAtTheseSections(paSections)
			return This.FindLastSplitAtSections(paSections)

		#--

		def FindLastSplitAtSectionsZ(paSections)
			return This.FindLastSplitAtSections(paSections)

		def FindLastSplitAtTheseSectionsZ(paSections)
			return This.FindLastSplitAtSections(paSections)

		#>

	  #-----------------------------------------------------------#
	 #   FINDING LAST SPLIT AT MANY SECTIONS -- BOUNDS INCLUDED  #
	#-----------------------------------------------------------#

	def FindLastSplitAtSectionsIB(paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAtSectionsIB(paSections)
		return nResult

		#< @FunctionAlternativeForms

		def FindLastSplitAtTheseSectionsIB(paSections)
			return This.FindLastSplitAtSectionsIB(paSections)

		#--

		def FindLastSplitAtSectionsIBZ(paSections)
			return This.FindLastSplitAtSectionsIB(paSections)

		def FindLastSplitAtTheseSectionsIBZ(paSections)
			return This.FindLastSplitAtSectionsIB(paSections)

		#>

	  #-------------------------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE A GIVEN ITEM   #
	#-------------------------------------------------------------#

	def FindLastSplitBeforeCS(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pItem)
			return This.FindLastSplitBeforeItemCS(pItem, pCaseSensitive)

		but isList(pItem) and Q(pItem).IsListOfStrings()
			return This.FindLastSplitBeforeItemsCS(pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindLastSplitBeforePosition(pItem)

		but isList(pItem) and Q(pItem).IsListOfNumbers()
			return This.FindLastSplitBeforePositions(pItem)

		but isList(pItem) and Q(pItem).IsPairOfNumbers()
			return This.FindLastSplitBeforeSection(pItem[1], pItem[2])

		but isList(pItem) and Q(pItem).IsListOfPairsOfNumbers()
			return This.FindLastSplitBeforeSections(pItem[1], pItem[2])

		but isList(pItem)

			#-- Case when named params are provided

			if Q(pItem).IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindLastSplitBeforePosition(pItem[2])
	
			but Q(pItem).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindLastSplitBeforePositions(pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindLastSplitBeforeItemCS(pItem[2], pCaseSensitive)
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindLastSplitBeforeItemsCS(pItem[2], pCaseSensitive)

			but Q(pItem).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindLastSplitBeforeSection(pItem[2])
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindLastSplitBeforeSections(pItem[2])

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeCSZ(pItem, pCaseSensitive)
			return This.FindLastSplitBeforeCS(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitBefore(pItem)
		return This.FindLastSplitBeforeCS(pItem, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeZ(pItem)
			return This.FindLastSplitBefore(pItem)

		#>

	  #------------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE A GIVEN POSITION   #
	#------------------------------------------------#

	def FindLastSplitBeforePosition(nPos)
		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforePosition(nPos)
		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeThisPosition(nPos)
			return This.FindLastSplitBeforePosition(nPos)

		#--

		def FindLastSplitBeforePositionZ(nPos)
			return This.FindLastSplitBeforePosition(nPos)

		def FindLastSplitBeforeThisPositionZ(nPos)
			return This.FindLastSplitBeforePosition(nPos)

		#>

	  #----------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE MANY POSITIONS   #
	#----------------------------------------------#

	def FindLastSplitBeforePositions(anPos)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforePositions(anPos)
		return aResult			

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeThesePositions(anPos)
			return This.FindLastSplitBeforePositions(anPos)

		def FindLastSplitBeforeManyPositions(anPos)
			return This.FindLastSplitBeforePositions(anPos)

		#--

		def FindLastSplitBeforePositionsZ(anPos)
			return This.FindLastSplitBeforePositions(anPos)

		def FindLastSplitBeforeThesePositionsZ(anPos)
			return This.FindLastSplitBeforePositions(anPos)

		def FindLastSplitBeforeManyPositionsZ(anPos)
			return This.FindLastSplitBeforePositions(anPos)

		#>

	  #-------------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE A GIVEN Item   #
	#-------------------------------------------------#

	def FindLastSplitBeforeItemCS(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isString(pItem)
			StzRaise("Incorrect param type! pItem must be a string.")
		ok

		anPos = This.FindCS(pItem, pCaseSensitive)
		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforePositions(anPos)

		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitBeforeThisItemCS(pItem, pCaseSensitive)
			return This.FindLastSplitBeforeItemCS(pItem, pCaseSensitive)

		#--

		def FindLastSplitBeforeItemCSZ(pItem, pCaseSensitive)
			return This.FindLastSplitBeforeItemCS(pItem, pCaseSensitive)

		def FindLastSplitBeforeThisItemCSZ(pItem, pCaseSensitive)
			return This.FindLastSplitBeforeItemCS(pItem, pCaseSensitive)

		#>
				
	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitBeforeItem(pItem)
		return This.FindLastSplitBeforeItemCS(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitBeforeThisItem(pItem)
			return This.FindLastSplitBeforeItem(pItem)

		#--

		def FindLastSplitBeforeItemZ(pItem)
			return This.FindLastSplitBeforeItem(pItem)

		def FindLastSplitBeforeThisItemZ(pItem)
			return This.FindLastSplitBeforeItem(pItem)	

		#>

	  #-----------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE MANY Items   #
	#-----------------------------------------------#

	def FindLastSplitBeforeItemsCS(paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paItems) and Q(paItems).IsListOfStrings() )
			StzRaise("Incorrect param type! paItems must be a list of strings.")
		ok

		anPos = This.FindCS( paItems, pCaseSensitive )
		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforePositions(anPos)

		return nResult

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeTheseItemsCS(paItems, pCaseSensitive)
			return This.FindLastSplitBeforeItemsCS(paItems, pCaseSensitive)

		def FindLastSplitBeforeManyItemsCS(paItems, pCaseSensitive)
			return This.FindLastSplitBeforeItemsCS(paItems, pCaseSensitive)

		#--

		def FindLastSplitBeforeItemsCSZ(paItems, pCaseSensitive)
			return This.FindLastSplitBeforeItemsCS(paItems, pCaseSensitive)

		def FindLastSplitBeforeTheseItemsCSZ(paItems, pCaseSensitive)
			return This.FindLastSplitBeforeItemsCS(paItems, pCaseSensitive)

		def FindLastSplitBeforeManyItemsCSZ(paItems, pCaseSensitive)
			return This.FindLastSplitBeforeItemsCS(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitBeforeItems(paItems)
		return This.FindLastSplitBeforeItemsCS(paItems, TRUE)
	
		#< @FunctionAlternativeForms

		def FindLastSplitBeforeTheseItems(paItems)
			return This.FindLastSplitBeforeItems(paItems)

		def FindLastSplitBeforeManyItems(paItems)
			return This.FindLastSplitBeforeItems(paItems)

		#--

		def FindLastSplitBeforeItemsZ(paItems)
			return This.FindLastSplitBeforeItems(paItems)

		def FindLastSplitBeforeTheseItemsZ(paItems)
			return This.FindLastSplitBeforeItems(paItems)

		def FindLastSplitBeforeManyItemsZ(paItems)
			return This.FindLastSplitBeforeItems(paItems)

		#>

	  #-----------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE A GIVEN SECTION   #
	#-----------------------------------------------#

	def FindLastSplitBeforeSection(n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforeSection(n1, n2)
		return nResult

		#< @FunctionAlternativeForm

		def FindLastSplitBeforeThisSection(n1, n2)
			return This.FindLastSplitBeforeSection(n1, n2)

		#--

		def FindLastSplitBeforeSectionZ(n1, n2)
			return This.FindLastSplitBeforeSection(n1, n2)

		def FindLastSplitBeforeThisSectionZ(n1, n2)
			return This.FindLastSplitBeforeSection(n1, n2)

		#>

	  #------------------------------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE A GIVEN SECTION -- INCLUDING BOUND   #
	#------------------------------------------------------------------#

	def FindLastSplitBeforeSectionIB(n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforeSectionIB(n1, n2)
		return nResult

		#< @FunctionAlternativeForm

		def FindLastSplitBeforeThisSectionIB(n1, n2)
			return This.FindLastSplitBeforeSectionIB(n1, n2)

		#--

		def FindLastSplitBeforeSectionIBZ(n1, n2)
			return This.FindLastSplitBeforeSectionIB(n1, n2)

		def FindLastSplitBeforeThisSectionIBZ(n1, n2)
			return This.FindLastSplitBeforeSectionIB(n1, n2)

		#>

	  #---------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE MANY SECTIONS   #
	#---------------------------------------------#

	def FindLastSplitBeforeSections(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforeSections(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeTheseSections(paSections)
			return This.FindLastSplitBeforeSections(paSections)

		def FindLastSplitBeforeManySections(paSections)
			return This.SplitBeforeSections(paSections)

		#--

		def FindLastSplitBeforeSectionsZ(paSections)
			return This.FindLastSplitBeforeSections(paSections)

		def FindLastSplitBeforeTheseSectionsZ(paSections)
			return This.FindLastSplitBeforeSections(paSections)

		def FindLastSplitBeforeManySectionsZ(paSections)
			return This.SplitBeforeSections(paSections)

		#>

	  #---------------------------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE MANY SECTIONS -- INCLUDING BOUND  #
	#---------------------------------------------------------------#

	def FindLastSplitBeforeSectionsIB(paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforeSectionsIB(paSections)
		return nResult

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeTheseSectionsIB(paSections)
			return This.FindLastSplitBeforeSectionsIB(paSections)

		def FindLastSplitBeforeManySectionsIB(paSections)
			return This.FindLastSplitBeforeSectionsIB(paSections)

		#--

		def FindLastSplitBeforeSectionsIBZ(paSections)
			return This.FindLastSplitBeforeSectionsIB(paSections)

		def FindLastSplitBeforeTheseSectionsIBZ(paSections)
			return This.FindLastSplitBeforeSectionsIB(paSections)

		def FindLastSplitBeforeManySectionsIBZ(paSections)
			return This.FindLastSplitBeforeSectionsIB(paSections)

		#>

	  #-----------------------------------------------------------#
	 #   FINDING LAST SPLIT AFTER A GIVEN ITEM  #
	#-----------------------------------------------------------#

	def FindLastSplitAfterCS(pItem, pCaseSensitive)
		if isString(pItem)
			return This.FindLastSplitAfterItemCS(pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindLastSplitAfterPosition(pItem)

		but isList(pItem)

			#-- Case when named params are provided

			if Q(pItem).IsOneOfTheseNamedParams([ :Position, :ThisPosition ])

				return This.FindLastSplitAfterPosition(pItem[2])
	
			but Q(pItem).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindLastSplitAfterPositions(pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindLastSplitAfterItemCS(pItem[2], pCaseSensitive)
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindLastSplitAfterItemsCS(pItem[2], pCaseSensitive)

			but Q(pItem).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindLastSplitAfterSection(pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindLastSplitAfterSections(pItem[2])

			#-- Providing numbers, strings, or pairs of numbers,
			#   directly without named params

			but Q(pItem).IsListOfNumbers()
				return This.FindLastSplitAfterPositions(pItem)

			but Q(pItem).IsListOfStrings()
				return This.FindLastSplitAfterItems(pItem)

			but Q(pItem).IsListOfPairsOfNumbers()
				return This.FindLastSplitAfterSections(pItem)

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindLastSplitAfterCSZ(pItem, pCaseSensitive)
			return This.FindLastSplitAfterCS(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitAfter(pItem)
		return This.FindLastSplitAfterCS(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitAfterZ(pItem)
			return This.FindLastSplitAfterCS(pItem, pCaseSensitive)

		#>

	  #------------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE A GIVEN POSITION   #
	#------------------------------------------------#

	def FindLastSplitAfterPosition(nPos)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterPosition(nPos)
		return nResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterThisPosition(nPos)
			return This.FindLastSplitAfterPosition(nPos)

		def FindLastSplitAfterPositionZ(nPos)
			return This.FindLastSplitAfterPosition(nPos)

		def FindLastSplitAfterThisPositionZ(nPos)
			return This.FindLastSplitAfterPosition(nPos)

		#>

	  #----------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE MANY POSITIONS   #
	#----------------------------------------------#

	def FindLastSplitAfterPositions(anPos)
		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterPositions(anPos)
		return nResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterThesePositions(anPos)
			return This.FindLastSplitAfterThesePositions(anPos)

		def FindLastSplitAfterManyPositions(anPos)
			return This.FindLastSplitAfterManyPositions(anPos)

		#--

		def FindLastSplitAfterPositionsZ(anPos)
			return This.FindLastSplitAfterPositions(anPos)

		def FindLastSplitAfterThesePositionsZ(anPos)
			return This.FindLastSplitAfterThesePositions(anPos)

		def FindLastSplitAfterManyPositionsZ(anPos)
			return This.FindLastSplitAfterManyPositions(anPos)

		#>

	  #-------------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE A GIVEN Item   #
	#-------------------------------------------------#

	def FindLastSplitAfterItemCS(pItem, pCaseSensitive)
		if NOT isString(pItem)
			StzRaise("Incorrect param type! pItem must be a string.")
		ok

		anPos = This.FindCS(pItem, pCaseSensitive)
		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterPositions(anPos)
		return nResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterThisItemCS(pItem, pCaseSensitive)
			return This.FindLastSplitAfterItemCS(pItem, pCaseSensitive)

		#--

		def FindLastSplitAfterItemCSZ(pItem, pCaseSensitive)
			return This.FindLastSplitAfterItemCS(pItem, pCaseSensitive)

		def FindLastSplitAfterThisItemCSZ(pItem, pCaseSensitive)
			return This.FindLastSplitAfterItemCS(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitAfterItem(pItem)
		return This.FindLastSplitAfterItemCS(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitAfterThisItem(pItem)
			return This.FindLastSplitAfterItem(pItem)

		#--

		def FindLastSplitAfterItemZ(pItem)
			return This.FindLastSplitAfterItem(pItem)

		def FindLastSplitAfterThisItemZ(pItem)
			return This.FindLastSplitAfterItem(pItem)

		#>

	  #-----------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE MANY Items   #
	#-----------------------------------------------#

	def FindLastSplitAfterItemsCS(paItems, pCaseSensitive)
		if NOT ( isList(paItems) and Q(paItems).IsListOfStrings() )
			StzRaise("Incorrect param type! paItems must be a list of strings.")
		ok

		anPos = This.FindCS( paItems, pCaseSensitive )
		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterPositions(anPos)
		return nResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterTheseItemsCS(paItems, pCaseSensitive)
			return This.FindLastSplitAfterItemsCS(paItems, pCaseSensitive)

		def FindLastSplitAfterManyItemsCS(paItems, pCaseSensitive)
			return This.FindLastSplitAfterItemsCS(paItems, pCaseSensitive)

		#--

		def FindLastSplitAfterItemsCSZ(paItems, pCaseSensitive)
			return This.FindLastSplitAfterItemsCS(paItems, pCaseSensitive)

		def FindLastSplitAfterTheseItemsCSZ(paItems, pCaseSensitive)
			return This.FindLastSplitAfterItemsCS(paItems, pCaseSensitive)

		def FindLastSplitAfterManyItemsCSZ(paItems, pCaseSensitive)
			return This.FindLastSplitAfterItemsCS(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitAfterItems(paItems)
		return This.FindLastSplitAfterItemsCS(paItems, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitAfterTheseItems(paItems)
			return This.FindLastSplitAfterItems(paItems)

		def FindLastSplitAfterManyItems(paItems)
			return This.FindLastSplitAfterItems(paItems)

		#--

		def FindLastSplitAfterItemsZ(paItems)
			return This.FindLastSplitAfterItems(paItems)

		def FindLastSplitAfterTheseItemsZ(paItems)
			return This.FindLastSplitAfterItems(paItems)

		def FindLastSplitAfterManyItemsZ(paItems)
			return This.FindLastSplitAfterItems(paItems)

		#>

	  #---------------------------------------------#
	 #   FINDING LAST SPLIT AFTER A GIVEN SECTION  #
	#---------------------------------------------#

	def FindLastSplitAfterSection(n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterSection(n1 , n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterThisSection(n1, n2)
			return This.FindLastSplitAfterSection(n1, n2)

		#--

		def FindLastSplitAfterSectionZ(n1, n2)
			return This.FindLastSplitAfterSection(n1, n2)

		def FindLastSplitAfterThisSectionZ(n1, n2)
			return This.FindLastSplitAfterSection(n1, n2)

		#>

	  #----------------------------------------------------------------#
	 #   FINDING LAST SPLIT AFTER A GIVEN SECTION -- INCLUDING BOUND  #
	#----------------------------------------------------------------#

	def FindLastSplitAfterSectionIB(n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterSectionIB(n1 , n2)
		return nResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterThisSectionIB(n1, n2)
			return This.FindLastSplitAfterSectionIB(n1, n2)

		#--

		def FindLastSplitAfterSectionIBZ(n1, n2)
			return This.FindLastSplitAfterSectionIB(n1, n2)

		def FindLastSplitAfterThisSectionIBZ(n1, n2)
			return This.FindLastSplitAfterSectionIB(n1, n2)


		#>

	  #--------------------------------------------#
	 #   FINDING LAST SPLIT AFTER MANY SECTIONS   #
	#--------------------------------------------#

	def FindLastSplitAfterSections(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterSections(paSections)
		return nResult

		#< @FunctionAlternativeForms

		def FindLastSplitAfterTheseSections(paSections)
			return This.FindLastSplitAfterTheseSections(paSections)

		#--

		def FindLastSplitAfterSectionsZ(paSections)
			return This.FindLastSplitAfterSections(paSections)

		def FindLastSplitAfterTheseSectionsZ(paSections)
			return This.FindLastSplitAfterTheseSections(paSections)

		#>

	  #---------------------------------------------------------------#
	 #   FINDING LAST SPLIT AFTER MANY SECTIONS -- INCLUDING BOUNDS  #
	#---------------------------------------------------------------#

	def FindLastSplitAfterSectionsIB(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterSectionsIB(paSections)
		return nResult

		#< @FunctionAlternativeForms

		def FindLastSplitAfterTheseSectionsIB(paSections)
			return This.FindLastSplitAfterSectionsIB(paSections)

		#--

		def FindLastSplitAfterSectionsIBZ(paSections)
			return This.FindLastSplitAfterSectionsIB(paSections)

		def FindLastSplitAfterTheseSectionsIBZ(paSections)
			return This.FindLastSplitAfterSectionsIB(paSections)

		#>

	  #----------------------------------------------------------#
	 #  FINDING LAST SPLIT BETWEEN TWO POSITIONS OR Items  #
	#==========================================================#

	def FindLastSplitBetweenCS(pItem1, pItem2, pCaseSensitive)
		if NOT ( BothAreStringsOrNumbers(pItem1, pItem2) )
			StzRaise("Incorrect params types! pItem1 and pItem2 must be both numbers or strings.")
		ok

		if BothAreNumbers(pItem1, pItem2)
			nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBetween(pItem1, pItem2)

		else # case if BothAreStrings()
			anLastBounds  = This.FindAllCS(pItem1, pCaseSensitive)
			anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

			aListOfBounds  = StzListOfListsQ([ anLastBounds, anSecondBounds ]).ReducedToSmallestSize()
			anLastBounds  = aListOfBounds[1]
			anSecondBounds = aListOfBounds[2]

			aSections = Q(anLastBounds).AssociatedWith(anSecondBounds)

			nResult = StzSplitterQ( This.NumberOfItems() ).
				   FindLastSplitBetweenSections(aSections)
		ok
		
		return nResult

		#< @FunctionAlternativeForm

		def FindLastSplitBetweenCSZ(pItem1, pItem2, pCaseSensitive)
			return This.FindLastSplitBetweenCS(pItem1, pItem2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitBetween(pItem1, pItem2)
		return This.FindLastSplitBetweenCS(pItem1, pItem2, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitBetweenZ(pItem1, pItem2)
			return This.FindLastSplitBetween(pItem1, pItem2)

		#>

	  #------------------------------------------------------------------------------#
	 #  FINDING LAST SPLIT BETWEEN TWO POSITIONS OR Items -- INCLUDING BOUNDS  #
	#------------------------------------------------------------------------------#

	def FindLastSplitBetweenCSIB(pItem1, pItem2, pCaseSensitive)
		if NOT ( BothAreStringsOrNumbers(pItem1, pItem2) )
			StzRaise("Incorrect params types! pItem1 and pItem2 must be both numbers or strings.")
		ok

		if BothAreNumbers(pItem1, pItem2)
			nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBetweenIB(pItem1, pItem2)

		else # case if BothAreStrings()
			anLastBounds  = This.FindAllCS(pItem1, pCaseSensitive)
			anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

			aListOfBounds  = StzListOfListsQ([ anLastBounds, anSecondBounds ]).ReducedToSmallestSize()
			anLastBounds  = aListOfBounds[1]
			anSecondBounds = aListOfBounds[2]

			nLen = len(anLastBounds)
			for i = 1 to nLen
				anLastBounds[i]--
				anSecondBounds[i]++
			next

			aSections = Q(anLastBounds).AssociatedWith(anSecondBounds)

			nResult = StzSplitterQ( This.NumberOfItems() ).
				   FindLastSplitBetweenSections(aSections)
		ok

		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitBetweenCSIBZ(pItem1, pItem2, pCaseSensitive)
			return This.FindLastSplitBetweenCSIB(pItem1, pItem2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitBetweenIB(pItem1, pItem2)
		return This.FindLastSplitBetweenCSIB(pItem1, pItem2, TRUE)


		#< @FunctionAlternativeForm

		def FindLastSplitBetweenIBZ(pItem1, pItem2)
			return This.FindLastSplitBetweenIB(pItem1, pItem2)

		#>

	  #--------------------------------------------#
	 #  FINDING LAST SPLIT BETWEEN TWO POSITIONS  #
	#--------------------------------------------#

	def FindLastSplitBetweenPositions(n1, n2)
		This.FindLastSplitAtSection(n1, n2)

		#< @FunctionAlternativeForms

		def FindLastSplitBetweenThesePositions(n1, n2)
			return This.FindLastSplitBetweenPositions(n1, n2)

		#--

		def FindLastSplitBetweenPositionsZ(n1, n2)
			return This.FindLastSplitBetweenPositions(n1, n2)

		def FindLastSplitBetweenThesePositionsZ(n1, n2)
			return This.FindLastSplitBetweenPositions(n1, n2)

		#>
		
	  #----------------------------------------------------------------#
	 #  FINDING LAST SPLIT BETWEEN TWO POSITIONS -- INCLUDING BOUNDS  #
	#----------------------------------------------------------------#

	def FindLastSplitBetweenPositionsIB(n1, n2)
		This.FindLastSplitAtSectionIB(n1, n2)

		#< @FunctionAlternativeForms

		def FindLastSplitBetweenThesePositionsIB(n1, n2)
			return This.FindLastSplitBetweenPositionsIB(n1, n2)

		#--

		def FindLastSplitBetweenPositionsIBZ(n1, n2)
			return This.FindLastSplitBetweenPositionsIB(n1, n2)

		def FindLastSplitBetweenThesePositionsIBZ(n1, n2)
			return This.FindLastSplitBetweenPositionsIB(n1, n2)

		#>

	  #---------------------------------------------#
	 #  FINDING LAST SPLIT BETWEEN TWO Items  #
	#---------------------------------------------#

	def FindLastSplitBetweenItemsCS(paItems, pCaseSensitive)
		aSections = This.Find(paItems, pCaseSensitive)
		nResult = This.FindLastSplitBetweenSections(aSections)
		return nResult

		#< @FunctionAlternativeForms

		def FindLastSplitBetweenTheseItemsCS(paItems, pCaseSensitive)
			return This.FindLastSplitBetweenItemsCS(paItems, pCaseSensitive)

		#--

		def FindLastSplitBetweenItemsCSZ(paItems, pCaseSensitive)
			return This.FindLastSplitBetweenItemsCS(paItems, pCaseSensitive)

		def FindLastSplitBetweenTheseItemsCSZ(paItems, pCaseSensitive)
			return This.FindLastSplitBetweenItemsCS(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitBetweenItems(paItems)
		return This.FindLastSplitBetweenItemsCS(paItems, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSplitBetweenTheseItems(paItems)
			return This.FindLastSplitBetweenItems(paItems)

		#--

		def FindLastSplitBetweenItemsZ(paItems)
			return This.FindLastSplitBetweenItems(paItems)

		def FindLastSplitBetweenTheseItemsZ(paItems)
			return This.FindLastSplitBetweenItems(paItems)

		#>

	  #-------------------------------------#
	 #    FINDING LAST SPLIT TO N PARTS    #
	#=====================================#

	def FindLastSplitToNParts(nPos)
		nResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitToNParts(nPos)
		return nResult

		def FindLastSplitToNPartsZ(nPos)
			return This.FindLastSplitToNParts(nPos)

	  #------------------------------------------------------#
	 #   FINDING LAST SPLIT TO PARTS OF (EXACTLY) N Items   #
	#------------------------------------------------------#
	# Remaining part less the n Items is not returned

	def FindLastSplitToPartsOfNItems(nPos)
		nResult = StzSplitterQ( This.NumberOfItems() ).
				FindLastSplitToPartsOfExactlyNPositions(nPos)

		return nResult

		#< @FunctionAlternativeForm

		def FindLastSplitToPartsOfExactlyNItems(nPos)
			return This.FindLastSplitToPartsOfNItems(nPos)

		#--

		def FindLastSplitToPartsOfNItemsZ(nPos)
			return This.FindLastSplitToPartsOfNItems(nPos)

		def FindLastSplitToPartsOfExactlyNItemsZ(nPos)
			return This.FindLastSplitToPartsOfNItems(nPos)

		#>

	  #----------------------------------------------------------------#
	 #   FINDING LAST SPLIT TO PARTS OF N Items -- INCLUDING BOUNDS   #
	#----------------------------------------------------------------#
	# The remaing part (if any) less then n Items is also returned

	def FindLastSplitToPartsOfNItemsXT(nPos)
		nResult = StzSplitterQ( This.NumberOfItems() ).
				FindLastSplitToPartsOfNPositionsXT(nPos)

		return nResult

		def FindLastSplitToPartsOfNItemsXTZ(nPos)
			return This.FindLastSplitToPartsOfNItemsXT(nPos)

	  #-----------------------------------------------#
	 #   FINDING LAST SPLIT UNDER A GIVEN CONDTION   #
	#===============================================#

	def FindLastSplitW(pcCondition)
		/*
		? StzSplitterQ(1:5).FindLastSplitW('Q(@item).IsMultipleOf(2)')
		*/

		if isList(pcCondition)

			if Q(pcCondition).IsWhereNamedParam()
				return This.FindLastSplitAtW(pcCondition[2])

			but Q(pcCondition).IsAtNamedParam()
				return This.FindLastSplitAtW(pcCondition[2])

			but Q(pcCondition).IsBeforeNamedParam()
				return This.FindLastSplitBeforeW(pcCondition[2])

			but Q(pcCondition).IsAfterNamedParam()
				return This.FindLastSplitAfterW(pcCondition[2])

			ok
		
		else

			return This.FindLastSplitAtWZ(pcCondition)
		ok

		#< @FunctionAlternativeForm

		def FindLastSplitWZ(pcCondition)
			return This.FindLastSplitWZ(pcCondition)

		#>

	  #--------------------------------------------#
	 #   FINSING LAST SPLIT AT A GIVEN CONDTION   #
	#--------------------------------------------#

	def FindLastSplitAtW(pcCondition)
			
		if isList(pcCondition) and Q(pcCondition).IsWhereNamedParam()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok


		pcCondition = Q(pcCondition).TrimQ().TheseBoundsRemoved( "{","}" )

		if Q(pcCondition).ContainsCS("@Item", :CS = FALSE)

			aSections = This.FindItemsW(pcCondition)
			nResult = This.FindLastSplitAtSectionsZ(aSections)

		else

			anPos = This.FindW(pcCondition)
			nResult = This.FindLastSplitAtPositionsZ(anPos)
		ok

		return nResult

		#< @FunctionAlternativeForm

		def FindLastSplitAtWZ(pcCondition)
			return This.FindLastSplitAtW(pcCondition)

		#>

	  #------------------------------------------------#
	 #   FINDING LAST SPLIT BEFORE A GIVEN CONDTION   #
	#------------------------------------------------#

	def FindLastSplitBeforeW(pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsW(pcCondition)

		else
			anPos = This.FindItemsW(pcCondition)
		ok

		nResult = This.FindLastSplitBeforePositions(anPos)

		return nResult

		#< @FunctionAlternativeForm

		def FindLastSplitBeforeWZ(pcCondition)
			return This.FindLastSplitBeforeW(pcCondition)

		#>

	  #-----------------------------------------------#
	 #   FINDING LAST SPLIT AFTER A GIVEN CONDTION   #
	#-----------------------------------------------#

	def FindLastSplitAfterW(pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsW(pcCondition)

		else
			anPos = This.FindItemsW(pcCondition)
		ok

		nResult = This.FindLastSplitAfterPositions(anPos)

		return nResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterWZ(pcCondition)
			return This.FindLastSplitAfterW(pcCondition)

		#>

	  #=====================================================#
	 #   FINDING THE LAST SPLIT AS SECTION -- ZZ/EXTENDED  #
	#=====================================================#

	def FindLastSplitCSXTZZ(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pItem)
			return This.FindLastSplitAtItemCSZZ(pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindLastSplitAtPositionZZ(pItem)

		but isList(pItem) and Q(pItem).IsListOfNumbers()
			return This.FindLastSplitAtPositionsZZ(pItem)

		but isList(pItem) and Q(pItem).IsPairOfNumbers()
			return This.FindLastSplitAtSectionZZ(pItem[1], pItem[2])

		but isList(pItem) and Q(pItem).IsListOfPairsOfNumbers()
			return This.FindLastSplitAtSectionsZZ(pItem)

		but isList(pItem)

			oParam = Q(pItem)

			#-- SPLITTING AT / USING

			if oParam.IsOneOfTheseNamedParams([ :At, :Using ])
				return This.FindLastSplitAtCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtPosition, :AtThisPosition ]) 
				return This.FindLastSplitAtPositionZZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AtPositions, :AtThesePositions ]) 
				return This.FindLastSplitAtPositionsZZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([
						:AtItem, :AtThisItem,
						:UsingItem, :UsingThisItem ]) 

				return This.FindLastSplitAtItemCSZZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([
						:AtItems, :AtTheseItems,
						:UsingItems, :UsingTheseItems ]) 

				return This.FindLastSplitAtItemsCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AtSection, :AtThisSection ]) 
				return This.FindLastSplitAtSectionZZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AtSections, :AtTheseSections ]) 
				return This.FindLastSplitAtSectionsZZ(pItem[2])

			#-- SPLITTING BEFORE

			but oParam.IsBeforeNamedParam()
				return This.FindLastSplitBeforeCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforePosition, :BeforeThisPosition ]) 
				return This.FindLastSplitBeforePositionZZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :BeforePositions, :BeforeThesePositions ]) 
				return This.FindLastSplitBeforePositionsZZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :BeforeItem, :BeforeThisItem ]) 
				return This.FindLastSplitBeforeItemCSZZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeItems, :BeforeTheseItems ]) 
				return This.SplitBeforeItemsCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :BeforeSection, :BeforeThisSection ]) 
				return This.FindLastSplitBeforeSectionZZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :BeforeSections, :BeforeTheseSections ]) 
				return This.FindLastSplitBeforeSectionsZZ(pItem[2])

			#-- SPLITTING AFTER

			but oParam.IsAfterNamedParam()
				return This.FindLastSplitAfterCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterPosition, :AfterThisPosition ]) 
				return This.FindLastSplitAfterPositionZZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :AfterPositions, :AfterThesePositions ]) 
				return This.FindLastSplitAfterPositionsZZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :AfterItem, :AfterThisItem ]) 
				return This.FindLastSplitAfterItemCSZZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :AfterItems, :AfterTheseItems ]) 
				return This.FindLastSplitAfterItemsCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :AfterSection, :AfterThisSection ]) 
				return This.FindLastSplitAfterSectionZZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :AfterSections, :AfterTheseSections ]) 
				return This.FindLastSplitAfterSectionsZZ(pItem[2])

			# SPLITTING BETWEEN

			but oParam.IsBetweenNamedParam() and
				isList(pItem) and len(pItem) = 2
				
				if isList(pItem[2]) and Q(pItem[2]).IsAndNamedParam()
					pItem[2] = pItem[2][2]
				ok

				return This.FindLastSplitBetweenCSZZ(pItem[1], pItem[2], pCaseSensitive)

			but oParam.IsBetweenPositionsNamedParam()
				return This.FindLastSplitBetweenPositionsZZ(pItem[1], pItem[2])

			but oParam.IsBetweenItemsNamedParam()
				return This.FindLastSplitBetweenItemsCSZZ(pItem[1], pItem[2], pCaseSensitive)

			# SPLITTING TO PARTS

			but oParam.IsToNPartsNamedParam()
				return This.FindLastSplitToNPartsZZ(pItem[2])

			but oParam.IsToPartsOfNItemsNamedParam()
				return This.FindLastSplitToPartsOfNItemsZZ(pItem[2])

			# SPLITTING WHERE

			but oParam.IsWhereOrAtWhereNamedParam()
				return This.FindLastSplitAtWZZ(pItem[2])

			but oParam.IsBeforeWhereNamedParam()
				return This.FindLastSplitBeforeWZZ(pItem[2])

			but oParam.IsAfterWhereNamedParam()
				return This.FindLastSplitAfterWZZ(pItem[2])

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindLastSplitAsSectionCSXT(pItem, pCaseSensitive)
			return This.FindLastSplitCSXTZZ(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitZZXT(pItem)
		return This.FindLastSplitCSXTZZ(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitAsSectionXT(pItem)
			return This.FindLastSplitXTZZ(pItem)

		#>

	  #---------------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) AT A GIVEN Item  #
	#=====================================================================#

	def FindLastSplitAtCSZZ(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pItem)
			return This.FindLastSplitAtItemCSZZ(pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindLastSplitAtPositionZZ(pItem)

		but isList(pItem) and Q(pItem).IsListOfNumbers()
			return This.FindLastSplitAtPositionsZZ(pItem)

		but isList(pItem) and Q(pItem).IsPairOfNumbers()
			return This.FindLastSplitAtSectionZZ(pItem[1], pItem[2])

		but isList(pItem) and Q(pItem).IsListOfPairsOfNumbers()
			return This.FindLastSplitAsSectionsZZ(pItem)

		but isList(pItem)

			oParam = Q(pItem)

			#-- Case when named params are provided

			if oParam.IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindLastSplitAtPositionZZ(pItem[2])
	
			but oParam.IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindLastSplitAtPositionsZZ(pItem[2])

			but oParam.IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindLastSplitAtItemCSZZ(pItem[2], pCaseSensitive)
		
			but oParam.IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindLastSplitAtItemsCSZZ(pItem[2], pCaseSensitive)

			but oParam.IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindLastSplitAtSectionZZ(pItem[2])
		
			but oParam.IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindLastSplitAtSectionsZZ(pItem[2])

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindLastSplitAtAsSectionCS(pItem, pCaseSensitive)
			return This.FindLastSplitAtCSZZ(pSubStr, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitAtZZ(pItem)
		return This.FindLastSplitAtCSZZ(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitAtAsSection(pItem)
			return This.FindLastSplitAtCSZZ(pSubStr)

		#>

	  #---------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) AT A GIVEN POSITION   #
	#=========================================================#

	def FindLastSplitAtPositionZZ(nPos)
		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect pram type! n must be a number.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAtPositionZZ(nPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAtThisPositionAsSection(nPos)
			return This.FindLastSplitAtPositionZZ(nPos)

		#>

	  #------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) AT MANY POSITIONS  #
	#------------------------------------------------------#

	def FindLastSplitAtPositionsZZ(anPos)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aResult = StzSplitterQ(This.NumberOfItems()).FindLastSplitAtPositionsZZ(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitAtThesePositionsZZ(anPos)
			return This.FindLastSplitAtPositionsZZ(anPos)

		def FindLastSplitAtManyPositionsZZ(anPos)
			return This.FindLastSplitAtPositionsZZ(anPos)

		#--

		def FindLastSplitAtPositionsAsSection(anPos)
			return This.FindLastSplitAtPositionsZZ(anPos)

		def FindLastSplitAtThesePositionsAsSection(anPos)
			return This.FindLastSplitAtPositionsZZ(anPos)

		def FindLastSplitAtManyPositionsAsSection(anPos)
			return This.FindLastSplitAtPositionsZZ(anPos)

		#>

	  #---------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) AT A GIVEN Item  #
	#=========================================================#

	def FindLastSplitAtItemCSZZ(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isString(pItem)
			StzRaise("Incorrect param type! pItem must be a string.")
		ok

		if isList(pCaseSensitive) and Q(pCaseSensitive).IsCaseSensitiveNamedParam()
			pCaseSensitive = pCaseSensitive[2]
		ok

		if NOT IsBoolean(pCaseSensitive)
			StzRaise("Incorrect param type! pCaseSensitive must be a boolean (TRUE or FALSE).")
		ok

		aSections = This.FindAsSectionsCS(pItem, pCaseSensitive)
		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAtSectionsZZ(aSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitCSZZ(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindLastSplitAtItemCSZZ(pItem, pCaseSensitive)

		def FindLastSplitAtThisItemCSZZ(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindLastSplitAtItemCSZZ(pItem, pCaseSensitive)

		#--

		def FindLastSplitAtItemAsSectionsCSZZ(pItem, pCaseSensitive)
			return This.FindLastSplitAtItemCSZZ(pItem, pCaseSensitive)

		def FindLastSplitAsSectionsCS(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindLastSplitAtItemCSZZ(pItem, pCaseSensitive)

		def FindLastSplitAtThisItemAsSectionsCS(pItem, pCaseSensitive)
			if isList(pItem) and Q(pItem).IsAtOrAtItemNamedParam()
				pItem = pItem[2]
			ok

			return This.FindLastSplitAtItemCSZZ(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitAtItemZZ(pItem)
		return This.FindLastSplitAtItemCSZZ(pItem, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSplitZZ(pItem)
			return This.FindLastSplitAtItemZZ(pItem, TRUE)

		def FindLastSplitAtThisItemZZ(pItem)
			return This.FindLastSplitAtItemZZ(pItem, TRUE)
		#--

		def FindLastSplitAtItemAsSectionZZ(pItem)
			return This.FindLastSplitAtItemZZ(pItem, TRUE)

		def FindLastSplitAsSection(pItem)
			return This.FindLastSplitAtItemZZ(pItem, TRUE)

		def FindLastSplitAtThisItemAsSection(pItem)
			return This.FindLastSplitAtItemZZ(pItem, TRUE)

		#>

	  #---------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTIONS) AT GIVEN Items  #
	#---------------------------------------------------------#

	def FindLastSplitAtItemsCSZZ(paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		anPos = This.FindCS(paItems, pCaseSensitive)

		aResult = This.FindLastSplitAtPositionsZZ(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitAtTheseItemsCSZZ(paItems, pCaseSensitive)
			return This.FindLastSplitAtItemsCSZZ(paItems, pCaseSensitive)

		def FindLastSplitAtManyItemsCSZZ(paItems, pCaseSensitive)
			return This.FindLastSplitAtItemsCSZZ(paItems, pCaseSensitive)

		#--

		def FindLastSplitAtItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindLastSplitAtItemsCSZZ(paItems, pCaseSensitive)

		def FindLastSplitAtTheseItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindLastSplitAtItemsCSZZ(paItems, pCaseSensitive)

		def FindLastSplitAtManyItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindLastSplitAtItemsCSZZ(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitAtItemsZZ(paItems)
		return This.FindLastSplitAtItemsCSZZ(paItems, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSplitAtTheseItemsZZ(paItems)
			return This.FindLastSplitAtItemsZZ(paItems)
	
		def FindLastSplitAtManyItemsZZ(paItems)
			return This.FindLastSplitAtItemsZZ(paItems)

		#--

		def FindLastSplitAtItemsAsSections(paItems)
			return This.FindLastSplitAtItemsZZ(paItems)

		def FindLastSplitAtTheseItemsAsSections(paItems)
			return This.FindLastSplitAtItemsZZ(paItems)

		def FindLastSplitAtManyItemsAsSections(paItems)
			return This.FindLastSplitAtItemsZZ(paItems)

		#>

	  #--------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) AT A GIVEN SECTION   #
	#========================================================#

	def FindLastSplitAtSectionZZ(n1, n2)
		if This.IsEmpty()
			return []
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAtSectionZZ(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAtThisSectionZZ(n1, n2)
			return This.FindLastSplitAtSectionZZ(n1, n2)

		#--

		def FindLastSplitAtSectionAsSection(n1, n2)
			return This.FindLastSplitAtSectionZZ(n1, n2)

		def FindLastSplitAtThisSectionAsSection(n1, n2)
			return This.FindLastSplitAtSectionZZ(n1, n2)

		#>

	  #---------------------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) AT A GIVEN SECTION -- INCLUDING BOUNDS  #
	#---------------------------------------------------------------------------#

	def FindLastSplitAtSectionIBZZ(n1, n2)
		if This.IsEmpty()
			return []
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAtSectionIBZZ(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAtThisSectionIBZZ(n1, n2)
			return This.SplitAtSectionIBZZ(n1, n2)

		#--

		def FindLastSplitAtSectionAsSectionIB(n1, n2)
			return This.FindLastSplitAtSectionIBZZ(n1, n2)

		def FindLastSplitAtThisSectionAsSectionIB(n1, n2)
			return This.SplitAtSectionIBZZ(n1, n2)

		#>

	  #------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) AT MANY SECTIONS   #
	#------------------------------------------------------#

	def FindLastSplitAtSectionsZZ(paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAtSectionsZZ(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitAtTheseSectionsZZ(paSections)
			return This.FindLastSplitAtSectionsZZ(paSections)

		#--

		def FindLastSplitAtSectionsAsSection(paSections)
			return This.FindLastSplitAtSectionsZZ(paSections)

		def FindLastSplitAtTheseSectionsAsSection(paSections)
			return This.FindLastSplitAtSectionsZZ(paSections)

		#>

	  #-------------------------------------------------------------------------#
	 #   FINDING LAST SPIT (AS SECTION) BEFORE A GIVEN ITEM   #
	#-------------------------------------------------------------------------#

	def FindLastSplitBeforeCSZZ(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if isString(pItem)
			return This.FindLastSplitBeforeItemCSZZ(pItem, pCaseSensitive)

		but isList(pItem) and Q(pItem).IsListOfStrings()
			return This.FindLastSplitBeforeItemsCSZZ(pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindLastSplitBeforePositionZZ(pItem)

		but isList(pItem) and Q(pItem).IsListOfNumbers()
			return This.FindLastSplitBeforePositionsZZ(pItem)

		but isList(pItem) and Q(pItem).IsPairOfNumbers()
			return This.FindLastSplitBeforeSectionZZ(pItem[1], pItem[2])

		but isList(pItem) and Q(pItem).IsListOfPairsOfNumbers()
			return This.FindLastSplitBeforeSectionsZZ(pItem[1], pItem[2])

		but isList(pItem)

			#-- Case when named params are provided

			if Q(pItem).IsOneOfTheseNamedParams([ :Position, :ThisPosition ]) 
				return This.FindLastSplitBeforePositionZZ(pItem[2])
	
			but Q(pItem).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindLastSplitBeforePositionsZZ(pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindLastSplitBeforeItemCSZZ(pItem[2], pCaseSensitive)
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindLastSplitBeforeItemsCSZZ(pItem[2], pCaseSensitive)

			but Q(pItem).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindLastSplitBeforeSectionZZ(pItem[2])
		
			but Q(pItem).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindLastSplitBeforeSectionsZZ(pItem[2])

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeAsSectionCS(pItem, pCaseSensitive)
			return This.FindLastSplitBeforeCSZZ(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitBeforeZZ(pItem)
		return This.FindLastSplitBeforeCSZZ(pItem, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeAsSection(pItem)
			return This.FindLastSplitBeforeZZ(pItem)

		#>

	  #-------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) BEFORE A GIVEN POSITION   #
	#-------------------------------------------------------------#

	def FindLastSplitBeforePositionZZ(nPos)
		if This.IsEmpty()
			return []
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforePositionZZ(nPos)
		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeThisPositionZZ(nPos)
			return This.FindLastSplitBeforePositionZZ(nPos)

		#--

		def FindLastSplitBeforePositionAsSection(nPos)
			return This.FindLastSplitBeforePositionZZ(nPos)

		def FindLastSplitBeforeThisPositionAsSection(nPos)
			return This.FindLastSplitBeforePositionZZ(nPos)

		#>

	  #-----------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) BEFORE MANY POSITIONS   #
	#-----------------------------------------------------------#

	def FindLastSplitBeforePositionsZZ(anPos)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforePositionsZZ(anPos)
		return aResult			

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeThesePositionsZZ(anPos)
			return This.FindLastSplitBeforePositionsZZ(anPos)

		def FindLastSplitBeforeManyPositionsZZ(anPos)
			return This.FindLastSplitBeforePositionsZZ(anPos)

		#--

		def FindLastSplitBeforePositionsAsSection(anPos)
			return This.FindLastSplitBeforePositionsZZ(anPos)

		def FindLastSplitBeforeThesePositionsAsSection(anPos)
			return This.FindLastSplitBeforePositionsZZ(anPos)

		def FindLastSplitBeforeManyPositionsAsSection(anPos)
			return This.FindLastSplitBeforePositionsZZ(anPos)

		#>

	  #--------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) BEFORE A GIVEN Item   #
	#--------------------------------------------------------------#

	def FindLastSplitBeforeItemCSZZ(pItem, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT isString(pItem)
			StzRaise("Incorrect param type! pItem must be a string.")
		ok

		anPos = This.FindCS(pItem, pCaseSensitive)
		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforePositionsZZ(anPos)

		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitBeforeThisItemCSZZ(pItem, pCaseSensitive)
			return This.FindLastSplitBeforeItemCSZZ(pItem, pCaseSensitive)

		#--

		def FindLastSplitBeforeItemAsSectionsCS(pItem, pCaseSensitive)
			return This.FindLastSplitBeforeItemCSZZ(pItem, pCaseSensitive)

		def FindLastSplitBeforeThisItemAsSectionsCS(pItem, pCaseSensitive)
			return This.FindLastSplitBeforeItemCSZZ(pItem, pCaseSensitive)

		#>
				
	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitBeforeItemZZ(pItem)
		return This.FindLastSplitBeforeItemCSZZ(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitBeforeThisItemZZ(pItem)
			return This.FindLastSplitBeforeItem(pItem)

		#--

		def FindLastSplitBeforeItemAsSection(pItem)
			return This.FindLastSplitBeforeItemZZ(pItem)

		def FindLastSplitBeforeThisItemAsSection(pItem)
			return This.FindLastSplitBeforeItemZZ(pItem)	

		#>

	  #------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) BEFORE MANY Items   #
	#------------------------------------------------------------#

	def FindLastSplitBeforeItemsCSZZ(paItems, pCaseSensitive)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paItems) and Q(paItems).IsListOfStrings() )
			StzRaise("Incorrect param type! paItems must be a list of strings.")
		ok

		anPos = This.FindCS( paItems, pCaseSensitive )
		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforePositionsZZ(anPos)

		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeTheseItemsCSZZ(paItems, pCaseSensitive)
			return This.FindLastSplitBeforeItemsCSZZ(paItems, pCaseSensitive)

		def FindLastSplitBeforeManyItemsCSZZ(paItems, pCaseSensitive)
			return This.FindLastSplitBeforeItemsCSZZ(paItems, pCaseSensitive)

		#--

		def FindLastSplitBeforeItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindLastSplitBeforeItemsCSZZ(paItems, pCaseSensitive)

		def FindLastSplitBeforeTheseItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindLastSplitBeforeItemsCSZZ(paItems, pCaseSensitive)

		def FindLastSplitBeforeManyItemsAsSectionsCS(paItems, pCaseSensitive)
			return This.FindLastSplitBeforeItemsCSZZ(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitBeforeItemsZZ(paItems)
		return This.FindLastSplitBeforeItemsCSZZ(paItems, TRUE)
	
		#< @FunctionAlternativeForms

		def FindLastSplitBeforeTheseItemsZZ(paItems)
			return This.FindLastSplitBeforeItemsZZ(paItems)

		def FindLastSplitBeforeManyItemsZZ(paItems)
			return This.FindLastSplitBeforeItemsZZ(paItems)

		#--

		def FindLastSplitBeforeItemsAsSection(paItems)
			return This.FindLastSplitBeforeItemsZZ(paItems)

		def FindLastSplitBeforeTheseItemsAsSection(paItems)
			return This.FindLastSplitBeforeItemsZZ(paItems)

		def FindLastSplitBeforeManyItemsAsSection(paItems)
			return This.FindLastSplitBeforeItemsZZ(paItems)

		#>

	  #------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) BEFORE A GIVEN SECTION   #
	#------------------------------------------------------------#

	def FindLastSplitBeforeSectionZZ(n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforeSectionZZ(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitBeforeThisSectionZZ(n1, n2)
			return This.FindLastSplitBeforeSectionZZ(n1, n2)

		#--

		def FindLastSplitBeforeSectionAsSection(n1, n2)
			return This.FindLastSplitBeforeSectionZZ(n1, n2)

		def FindLastSplitBeforeThisSectionAsSection(n1, n2)
			return This.FindLastSplitBeforeSectionZZ(n1, n2)

		#>

	  #-------------------------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) BEFORE A GIVEN SECTION -- INCLUDING BOUND   #
	#-------------------------------------------------------------------------------#

	def FindLastSplitBeforeSectionIBZZ(n1, n2)
		if This.IsEmpty()
			return []
		ok

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must be both numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforeSectionIBZZ(n1, n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitBeforeThisSectionIBZZ(n1, n2)
			return This.FindLastSplitBeforeSectionIBZZ(n1, n2)

		#--

		def FindLastSplitBeforeSectionAsSectionsIB(n1, n2)
			return This.FindLastSplitBeforeSectionIBZZ(n1, n2)

		def FindLastSplitBeforeThisSectionAsSectionsIB(n1, n2)
			return This.FindLastSplitBeforeSectionIBZZ(n1, n2)

		#>

	  #----------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) BEFORE MANY SECTIONS   #
	#----------------------------------------------------------#

	def FindLastSplitBeforeSectionsZZ(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBeforeSectionsZZ(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeTheseSectionsZZ(paSections)
			return This.FindLastSplitBeforeSectionsZZ(paSections)

		def FindLastSplitBeforeManySectionsZZ(paSections)
			return This.SplitBeforeSectionsZZ(paSections)

		#--

		def FindLastSplitBeforeSectionsAsSection(paSections)
			return This.FindLastSplitBeforeSectionsZZ(paSections)

		def FindLastSplitBeforeTheseSectionsAsSection(paSections)
			return This.FindLastSplitBeforeSectionsZZ(paSections)

		def FindLastSplitBeforeManySectionsAsSection(paSections)
			return This.SplitBeforeSectionsZZ(paSections)

		#>

	  #---------------------------------------------------------------------------#
	 #   FINING LAST SPLIT (AS SECTION) BEFORE MANY SECTIONS -- INCLUDING BOUND  #
	#---------------------------------------------------------------------------#

	def FindLastSplitBeforeSectionsIBZZ(paSections)
		if This.IsEmpty()
			return []
		ok

		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).SplitBeforeSectionIBZZ(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitBeforeTheseSectionsIBZZ(paSections)
			return This.FindLastSplitBeforeSectionsIBZZ(paSections)

		def FindLastSplitBeforeManySectionsIBZZ(paSections)
			return This.FindLastSplitBeforeSectionsIBZZ(paSections)

		#--

		def FindLastSplitBeforeSectionsAsSectionIB(paSections)
			return This.FindLastSplitBeforeSectionsIBZZ(paSections)

		def FindLastSplitBeforeTheseSectionsAsSectionIB(paSections)
			return This.FindLastSplitBeforeSectionIBZZ(paSections)

		def FindLastSplitBeforeManySectionsAsSectionIB(paSections)
			return This.FindLastSplitBeforeSectionIBZZ(paSections)

		#>

	  #------------------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) AFTER A GIVEN ITEM  #
	#------------------------------------------------------------------------#

	def FindLastSplitAfterCSZZ(pItem, pCaseSensitive)
		if isString(pItem)
			return This.FindLastSplitAfterItemCSZZ(pItem, pCaseSensitive)

		but isNumber(pItem)
			return This.FindLastSplitAfterPositionZZ(pItem)

		but isList(pItem)

			#-- Case when named params are provided

			if Q(pItem).IsOneOfTheseNamedParams([ :Position, :ThisPosition ])

				return This.FindLastSplitAfterPositionZZ(pItem[2])
	
			but Q(pItem).IsOneOfTheseNamedParams([ :Positions, :ThesePositions ]) 
				return This.FindLastSplitAfterPositionsZZ(pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Item, :ThisItem ]) 
				return This.FindLastSplitAfterItemCSZZ(pItem[2], pCaseSensitive)

			but Q(pItem).IsOneOfTheseNamedParams([ :Items, :TheseItems ]) 
				return This.FindLastSplitAfterItemsCSZZ(pItem[2], pCaseSensitive)

			but Q(pItem).IsOneOfTheseNamedParams([ :Section, :ThisSection ]) 
				return This.FindLastSplitAfterSectionZZ(pItem[2])

			but Q(pItem).IsOneOfTheseNamedParams([ :Sections, :TheseSections ]) 
				return This.FindLastSplitAfterSectionsZZ(pItem[2])

			#-- Providing numbers, strings, or pairs of numbers,
			#   directly without named params

			but Q(pItem).IsListOfNumbers()
				return This.FindLastSplitAfterPositionsZZ(pItem)

			but Q(pItem).IsListOfStrings()
				return This.FindLastSplitAfterItemsZZ(pItem)

			but Q(pItem).IsListOfPairsOfNumbers()
				return This.FindLastSplitAfterSectionsZZ(pItem)

			ok
		else
			StzRaise("Incorrect param type! pItem must be position(s), string(s), or section(s).")
		ok

		#< @FunctionAlternativeForm

		def FindLastSplitAfterAsSectionCS(pItem, pCaseSensitive)
			return This.FindLastSplitAfterCSZZ(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitAfterZZ(pItem)
		return This.FindLastSplitAfterCSZZ(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitAfterAsSection(pItem)
			return This.FindLastSplitAfterCSZZ(pItem, pCaseSensitive)

		#>

	  #-------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) BEFORE A GIVEN POSITION   #
	#-------------------------------------------------------------#

	def FindLastSplitAfterPositionZZ(Pos)
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterPositionZZ(nPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterThisPositionZZ(nPos)
			return This.FindLastSplitAfterPositionZZ(nPos)

		def FindLastSplitAfterThisPositionAsSection(nPos)
			return This.FindLastSplitAfterPositionZZ(nPos)

		#>

	  #-----------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) BEFORE MANY POSITIONS   #
	#-----------------------------------------------------------#

	def FindLastSplitAfterPositionsZZ(anPos)
		if NOT ( isList(anPos) and Q(anPos).IsListOfNumbers() )
			StzRaise("Incorrect param type! anPos must be a list of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterPositionsZZ(anPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterThesePositionsZZ(anPos)
			return This.FindLastSplitAfterThesePositionsZZ(anPos)

		def FindLastSplitAfterManyPositionsZZ(anPos)
			return This.FindLastSplitAfterManyPositionsZZ(anPos)

		#--

		def FindLastSplitAfterPositionsAsSection(anPos)
			return This.FindLastSplitAfterPositionsZZ(anPos)

		def FindLastSplitAfterThesePositionsAsSection(anPos)
			return This.FindLastSplitAfterThesePositionsZZ(anPos)

		def FindLastSplitAfterManyPositionsAsSection(anPos)
			return This.FindLastSplitAfterManyPositionsZZ(anPos)

		#>

	  #--------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) BEFORE A GIVEN Item   #
	#--------------------------------------------------------------#

	def FindLastSplitAfterItemCSZZ(pItem, pCaseSensitive)
		if NOT isString(pItem)
			StzRaise("Incorrect param type! pItem must be a string.")
		ok

		anPos = This.FindCS(pItem, pCaseSensitive)
		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterPositionsZZ(anPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterThisItemCSZZ(pItem, pCaseSensitive)
			return This.FindLastSplitAfterItemCSZZ(pItem, pCaseSensitive)

		#--

		def FindLastSplitAfterItemAsSectionCS(pItem, pCaseSensitive)
			return This.FindLastSplitAfterItemCSZZ(pItem, pCaseSensitive)

		def FindLastSplitAfterThisItemAsSectionCS(pItem, pCaseSensitive)
			return This.FindLastSplitAfterItemCSZZ(pItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitAfterItemZZ(pItem)
		return This.FindLastSplitAfterItemCSZZ(pItem, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitAfterThisItemZZ(pItem)
			return This.FindLastSplitAfterItemZZ(pItem)

		#--

		def FindLastSplitAfterItemAsSection(pItem)
			return This.FindLastSplitAfterItemZZ(pItem)

		def FindLastSplitAfterThisItemAsSection(pItem)
			return This.FindLastSplitAfterItemZZ(pItem)

		#>

	  #------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) BEFORE MANY Items   #
	#------------------------------------------------------------#

	def FindLastSplitAfterItemsCSZZ(paItems, pCaseSensitive)
		if NOT ( isList(paItems) and Q(paItems).IsListOfStrings() )
			StzRaise("Incorrect param type! paItems must be a list of strings.")
		ok

		anPos = This.FindCS( paItems, pCaseSensitive )
		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterPositionsZZ(anPos)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterTheseItemsCSZZ(paItems, pCaseSensitive)
			return This.FindLastSplitAfterItemsCSZZ(paItems, pCaseSensitive)

		def FindLastSplitAfterManyItemsCSZZ(paItems, pCaseSensitive)
			return This.FindLastSplitAfterItemsCSZZ(paItems, pCaseSensitive)

		#--

		def FindLastSplitAfterItemsAsSectionCS(paItems, pCaseSensitive)
			return This.FindLastSplitAfterItemsCSZZ(paItems, pCaseSensitive)

		def FindLastSplitAfterTheseItemsAsSectionCS(paItems, pCaseSensitive)
			return This.FindLastSplitAfterItemsCSZZ(paItems, pCaseSensitive)

		def FindLastSplitAfterManyItemsAsSectionCSZZ(paItems, pCaseSensitive)
			return This.FindLastSplitAfterItemsCSZZ(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitAfterItemsZZ(paItems)
		return This.FindLastSplitAfterItemsCSZZ(paItems, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitAfterTheseItemsZZ(paItems)
			return This.FindLastSplitAfterItemsZZ(paItems)

		def FindLastSplitAfterManyItemsZZ(paItems)
			return This.FindLastSplitAfterItemsZZ(paItems)

		#--

		def FindLastSplitAfterItemsAsSection(paItems)
			return This.FindLastSplitAfterItemsZZ(paItems)

		def FindLastSplitAfterTheseItemsAsSection(paItems)
			return This.FindLastSplitAfterItemsZZ(paItems)

		def FindLastSplitAfterManyItemsAsSectionZZ(paItems)
			return This.FindLastSplitAfterItemsZZ(paItems)

		#>

	  #-----------------------------------------------------------#
	 #   FINDING LAST SPLIT (َAS SECTION) AFTER A GIVEN SECTION   #
	#-----------------------------------------------------------#

	def FindLastSplitAfterSectionZZ(n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterSectionZZ(n1 , n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterThisSectionZZ(n1, n2)
			return This.FindLastSplitAfterSectionZZ(n1, n2)

		#--

		def FindLastSplitAfterSectionAsSections(n1, n2)
			return This.FindLastSplitAfterSectionZZ(n1, n2)

		def FindLastSplitAfterThisSectionAsSections(n1, n2)
			return This.FindLastSplitAfterSectionZZ(n1, n2)

		#>

	  #-----------------------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) AFTER A GIVEN SECTION -- INCLUDING BOUND  #
	#-----------------------------------------------------------------------------#

	def FindLastSplitAfterSectionIBZZ(n1, n2)

		if NOT BothAreNumbers(n1, n2)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterSectionIBZZ(n1 , n2)
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterThisSectionIBZZ(n1, n2)
			return This.FindLastSplitAfterSectionIBZZ(n1, n2)

		#--

		def FindLastSplitAfterSectionAsSectionIB(n1, n2)
			return This.FindLastSplitAfterSectionIBZZ(n1, n2)

		def FindLastSplitAfterThisSectionAsSectionIB(n1, n2)
			return This.FindLastSplitAfterSectionIBZZ(n1, n2)

		#>

	  #---------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) AFTER MANY SECTIONS   #
	#---------------------------------------------------------#

	def FindLastSplitAfterSectionsZZ(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterSectionsZZ(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitAfterTheseSectionsZZ(paSections)
			return This.FindLastSplitAfterTheseSectionsZZ(paSections)

		#--

		def FindLastSplitAfterSectionsAsSection(paSections)
			return This.FindLastSplitAfterSectionsZZ(paSections)

		def FindLastSplitAfterTheseSectionsAsSection(paSections)
			return This.FindLastSplitAfterTheseSectionsZZ(paSections)

		#>

	  #----------------------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) AFTER MANY SECTIONS -- INCLUDING BOUNDS  #
	#----------------------------------------------------------------------------#

	def FindLastSplitAfterSectionsIBZZ(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSectiosn must be a list of pairs of numbers.")
		ok

		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitAfterSectionsIBZZ(paSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitAfterTheseSectionsIBZZ(paSections)
			return This.FindLastSplitAfterSectionsIBZZ(paSections)

		#--

		def FindLastSplitAfterSectionsAsSectionsIB(paSections)
			return This.FindLastSplitAfterSectionsIBZZ(paSections)

		def FindLastSplitAfterTheseSectionsAsSectionsIB(paSections)
			return This.FindLastSplitAfterSectionsIBZZ(paSections)

		#>

	  #-----------------------------------------------------------------------#
	 #  FINDING LAST SPLIT (AS SECTION) BETWEEN TWO POSITIONS OR Items  #
	#=======================================================================#

	def FindLastSplitBetweenCSZZ(pItem1, pItem2, pCaseSensitive)
		if NOT ( BothAreStringsOrNumbers(pItem1, pItem2) )
			StzRaise("Incorrect params types! pItem1 and pItem2 must be both numbers or strings.")
		ok

		if BothAreNumbers(pItem1, pItem2)
			aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBetweenZZ(pItem1, pItem2)

		else # case if BothAreStrings()
			anLastBounds  = This.FindAllCS(pItem1, pCaseSensitive)
			anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

			aListOfBounds  = StzListOfListsQ([ anLastBounds, anSecondBounds ]).ReducedToSmallestSize()
			anLastBounds  = aListOfBounds[1]
			anSecondBounds = aListOfBounds[2]

			aSections = Q(anLastBounds).AssociatedWith(anSecondBounds)

			aResult = StzSplitterQ( This.NumberOfItems() ).
				   FindLastSplitBetweenSectionsZZ(aSections)
		ok
		
		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitBetweenAsSectionCS(pItem1, pItem2, pCaseSensitive)
			return This.FindLastSplitBetweenCSZZ(pItem1, pItem2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitBetweenZZ(pItem1, pItem2)
		return This.FindLastSplitBetweenCS(pItem1, pItem2, TRUE)

		#< @FunctionAlternativeForm

		def FindLastSplitBetweenAsSection(pItem1, pItem2)
			return This.FindLastSplitBetweenZZ(pItem1, pItem2)

		#>

	  #-------------------------------------------------------------------------------------------#
	 #  FINDING LAST SPLIT (AS SECTION) BETWEEN TWO POSITIONS OR Items -- INCLUDING BOUNDS  #
	#-------------------------------------------------------------------------------------------#

	def FindLastSplitBetweenCSIBZZ(pItem1, pItem2, pCaseSensitive)
		if NOT ( BothAreStringsOrNumbers(pItem1, pItem2) )
			StzRaise("Incorrect params types! pItem1 and pItem2 must be both numbers or strings.")
		ok

		if BothAreNumbers(pItem1, pItem2)
			aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitBetweenIBZZ(pItem1, pItem2)

		else # case if BothAreStrings()
			anLastBounds  = This.FindAllCS(pItem1, pCaseSensitive)
			anSecondBounds = This.FindAllCS(pItem2, pCaseSensitive)

			aListOfBounds  = StzListOfListsQ([ anLastBounds, anSecondBounds ]).ReducedToSmallestSize()
			anLastBounds  = aListOfBounds[1]
			anSecondBounds = aListOfBounds[2]

			nLen = len(anLastBounds)
			for i = 1 to nLen
				anLastBounds[i]--
				anSecondBounds[i]++
			next

			aSections = Q(anLastBounds).AssociatedWith(anSecondBounds)

			aResult = StzSplitterQ( This.NumberOfItems() ).
				   FindLastSplitBetweenSectionsZZ(aSections)
		ok

		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitBetweenAsSectionCSIB(pItem1, pItem2, pCaseSensitive)
			return This.FindLastSplitBetweenCSIBZZ(pItem1, pItem2, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitBetweenIBZZ(pItem1, pItem2)
		return This.FindLastSplitBetweenCSIBZZ(pItem1, pItem2, TRUE)


		#< @FunctionAlternativeForm

		def FindLastSplitBetweenAsSectionIB(pItem1, pItem2)
			return This.FindLastSplitBetweenIBZZ(pItem1, pItem2)

		#>

	  #---------------------------------------------------------#
	 #  FINDING LAST SPLIT (AS SECTION) BETWEEN TWO POSITIONS  #
	#---------------------------------------------------------#

	def FindLastSplitBetweenPositionsZZ(n1, n2)
		This.FindLastSplitAtSectionZZ(n1, n2)

		#< @FunctionAlternativeForms

		def FindLastSplitBetweenThesePositionsZZ(n1, n2)
			return This.FindLastSplitBetweenPositionsZZ(n1, n2)

		#--

		def FindLastSplitBetweenPositionsAsSection(n1, n2)
			return This.FindLastSplitBetweenPositionsZZ(n1, n2)

		def FindLastSplitBetweenThesePositionsAsSection(n1, n2)
			return This.FindLastSplitBetweenPositionsZZ(n1, n2)

		#>
		
	  #------------------------------------------------------------------------------#
	 #  FINDING LAST SPLIT (AS SECTIONS) BETWEEN TWO POSITIONS -- INCLUDING BOUNDS  #
	#------------------------------------------------------------------------------#

	def FindLastSplitBetweenPositionsIBZZ(n1, n2)
		This.FindLastSplitAtSectionIBZZ(n1, n2)

		#< @FunctionAlternativeForms

		def FindLastSplitBetweenThesePositionsIBZZ(n1, n2)
			return This.FindLastSplitBetweenPositionsIBZZ(n1, n2)

		#--

		def FindLastSplitBetweenPositionsAsSectionIB(n1, n2)
			return This.FindLastSplitBetweenPositionsIBZZ(n1, n2)

		def FindLastSplitBetweenThesePositionsAsSectionIB(n1, n2)
			return This.FindLastSplitBetweenPositionsIBZZ(n1, n2)

		#>

	  #----------------------------------------------------------#
	 #  FINDING LAST SPLIT (AS SECTION) BETWEEN TWO Items  #
	#----------------------------------------------------------#

	def FindLastSplitBetweenItemsCSZZ(paItems, pCaseSensitive)
		aSections = This.FindAsSections(paItems, pCaseSensitive)
		aResult = This.FindLastSplitBetweenSectionsZZ(aSections)
		return aResult

		#< @FunctionAlternativeForms

		def FindLastSplitBetweenTheseItemsCSZZ(paItems, pCaseSensitive)
			return This.FindLastSplitBetweenItemsCSZZ(paItems, pCaseSensitive)

		#--

		def FindLastSplitBetweenItemsAsSectionCS(paItems, pCaseSensitive)
			return This.FindLastSplitBetweenItemsCSZZ(paItems, pCaseSensitive)

		def FindLastSplitBetweenTheseItemsAsSectionCS(paItems, pCaseSensitive)
			return This.FindLastSplitBetweenItemsCSZZ(paItems, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSplitBetweenItemsZZ(paItems)
		return This.FindLastSplitBetweenItemsCSZZ(paItems, TRUE)

		#< @FunctionAlternativeForms

		def FindLastSplitBetweenTheseItemsZZ(paItems)
			return This.FindLastSplitBetweenItemsZZ(paItems)

		#--

		def FindLastSplitBetweenItemsAsSection(paItems)
			return This.FindLastSplitBetweenItemsZZ(paItems)

		def FindLastSplitBetweenTheseItemsAsSection(paItems)
			return This.FindLastSplitBetweenItemsZZ(paItems)

		#>

	  #--------------------------------------------------#
	 #    FINDING LAST SPLIT (AS SECTION) TO N PARTS    #
	#==================================================#

	def FindLastSplitToNPartsZZ(nPos)
		aResult = StzSplitterQ( This.NumberOfItems() ).FindLastSplitToNPartsZZ(nPos)
		return aResult

		def FindLastSplitToNPartsAsSection(nPos)
			return This.FindLastSplitToNPartsZZ(nPos)

	  #------------------------------------------------------#
	 #   FINDING LAST SPLIT TO PARTS OF (EXACTLY) N Items   #
	#------------------------------------------------------#
	# Remaining part less the n Items is not returned

	def FindLastSplitToPartsOfNItemsZZ(nPos)
		aResult = StzSplitterQ( This.NumberOfItems() ).
				FindLastSplitToPartsOfExactlyNPositionsZZ(nPos)

		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitToPartsOfExactlyNItemsZZ(nPos)
			return This.FindLastSplitToPartsOfNItemsZZ(nPos)

		#--

		def FindLastSplitToPartsOfNItemsAsSection(nPos)
			return This.FindLastSplitToPartsOfNItemsZZ(nPos)

		def FindLastSplitToPartsOfExactlyNItemsAsSection(nPos)
			return This.FindLastSplitToPartsOfNItemsZZ(nPos)

		#>

	  #-----------------------------------------------------------------------------#
	 #   FINDING LAST SPLIT (AS SECTION) TO PARTS OF N Items -- INCLUDING BOUNDS   #
	#-----------------------------------------------------------------------------#
	# The remaing part (if any) less then n Items is also returned

	def FindLastSplitToPartsOfNItemsIBZZ(nPos)
		aResult = StzSplitterQ( This.NumberOfItems() ).
				FindLastSplitToPartsOfNPositionsIBZZ(nPos)

		return aResult

	  #-------------------------------------------------------------#
	 #    FINDING LAST SPLIT (AS SECTION) UNDER A GIVEN CONDTION   #
	#=============================================================#

	def FindLastSplitWZZ(pcCondition)

		if isList(pcCondition)

			if Q(pcCondition).IsWhereNamedParam()
				return This.FindLastSplitAtWZZ(pcCondition[2])

			but Q(pcCondition).IsAtNamedParam()
				return This.FindLastSplitAtWZZ(pcCondition[2])

			but Q(pcCondition).IsBeforeNamedParam()
				return This.FindLastSplitBeforeWZZ(pcCondition[2])

			but Q(pcCondition).IsAfterNamedParam()
				return This.FindLastSplitAfterWZZ(pcCondition[2])

			ok
		
		else

			return This.FindLastSplitAtWZZ(pcCondition)
		ok

		#< @FunctionAlternativeForm

		def FindLastSplitAsSectionW(pcCondition)
			return This.FindLastSplitWZZ(pcCondition)

		#>

	  #----------------------------------------------------------#
	 #    FINSING LAST SPLIT (AS SECTION) AT A GIVEN CONDTION   #
	#----------------------------------------------------------#

	def FindLastSplitAtWZZ(pcCondition)
			
		if isList(pcCondition) and Q(pcCondition).IsWhereNamedParam()
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		aResult = []

		pcCondition = Q(pcCondition).TrimQ().TheseBoundsRemoved( "{","}" )

		if Q(pcCondition).ContainsCS("@Item", :CS = FALSE)

			aSections = This.FindItemsAsSectionsW(pcCondition)
			aResult = This.FindLastSplitAtSectionsZZ(aSections)

		else

			anPos = This.FindW(pcCondition)
			aResult = This.FindLastSplitAtPositionsZZ(anPos)
		ok

		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAtAsSectionW(pcCondition)
			return This.FindLastSplitAtWZZ(pcCondition)

		#>

	  #---------------------------------------------------------------#
	 #    FINDING LAST SPLIT (AS SECTIONS) BEFORE A GIVEN CONDTION   #
	#---------------------------------------------------------------#

	def FindLastSplitBeforeWZZ(pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsW(pcCondition)

		else
			anPos = This.FindItemsW(pcCondition)
		ok

		aResult = This.FindLastSplitBeforePositionsZZ(anPos)

		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitBeforeAsSectionW(pcCondition)
			return This.FindLastSplitBeforeWZZ(pcCondition)

		#>

	  #-------------------------------------------------------------#
	 #    FINDING LAST SPLIT (AS SECTION) AFTER A GIVEN CONDTION   #
	#-------------------------------------------------------------#

	def FindLastSplitAfterWZZ(pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		oCondition = new stzString(pcCondition)

		if oCondition.ContainsCS("@Item",  :CaseSensitive = FALSE)
			anPos = This.FindItemsW(pcCondition)

		else
			anPos = This.FindItemsW(pcCondition)
		ok

		aResult = This.FindLastSplitAfterPositionsZZ(anPos)

		return aResult

		#< @FunctionAlternativeForm

		def FindLastSplitAfterAsSectionW(pcCondition)
			return This.FindLastSplitAfterWZZ(pcCondition)

		#>
