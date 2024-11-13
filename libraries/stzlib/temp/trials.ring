
load "../max/stzmax.ring"


//puts Prime.each(5000).select{|p| 2.pow(p-1 ,p*p) == 1 }

/*--------

pron()

? PrimesUnder(19)
#--> [ 2, 3, 5, 7, 11, 13, 17 ]

? PrimesUnderIB(19)
#--> [ 2, 3, 5, 7, 11, 13, 17, 19 ]

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*------- #ring
*/
pron()


FirstNPrimes(5000)

/*
aPrimes = []

for i = 1 to 5000
	if isPrime(i)
		aPrimes + i
	ok
next
# Executed in 0.01 second(s) in Ring 1.21
*/
proff()

/*-------

pron()

for i = 1 to 5000
	if isWeiferich(i)
		? i
	ok
next

proff()

function isWeiferich(p)
    if not isPrime(p)
       return False
    ok
    q = 1
    p2 = pow(p,2)
    while p > 1
        q = (2 * q) % p2
        p -= 1
    end 
    if q = 1
       return True
    else
       return False
    ok

/*--- @ring

pron()

aHash = [ :1 = "One", :2 = "Two", :3 = "Three" ]

? @@(aHash)
#--> [ [ "1", "One" ], [ "2", "Two" ], [ "3", "Three" ] ]

? isString(aHash[1][1]) # "1"
#--> TRUE

? @@( aHash[1] )
#--> [ "1", "One" ]

? aHash[:1]
#--> "One"

proff()
# Executed in almost 0 second(s) in Ring 1.21

/*


	  #========================================#
	 #    SPLITTING : THE GENERIC FUNCTION    #
	#========================================#

	def SplitXT(p)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitXT(p)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsXT(p)
			return This.SplitXT(p)

	  #--------------------#
	 #    SPLITTING AT    #
	#====================#

	def SplitAt(p)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAt(p)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsAt(p)
			return This.SplitAt(p)

	  #-----------------------------------#
	 #   SPLITTING AT A GIVEN POSITION   #
	#-----------------------------------#

	def SplitAtPosition(n)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAtPosition(p)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsAtPosition(n)
			return This.SplitAtPosition(n)

	  #---------------------------------#
	 #   SPLITTING AT MANY POSITIONS   #
	#---------------------------------#

	def SplitAtPositions(panPos)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAtPositions(p)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def SplitAtThesePositions(panPos)
			return This.SplitAtPositions(panPos)

		def SplitAtManyPositions(panPos)
			return This.SplitAtPositions(panPos)

		#--

		def SplitsAtPositions(panPos)
			return This.SplitAtPositions(panPos)

		def SplitsAtThesePositions(panPos)
			return This.SplitAtPositions(panPos)

		def SplitsAtManyPositions(panPos)
			return This.SplitAtPositions(panPos)

		#>

	  #------------------------#
	 #    SPLITTING BEFORE    #
	#========================#

	def SplitBefore(p)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitBefore(p)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsBefore(p)
			return This.SplitBefore(p)

	  #---------------------------------#
	 #   SPLITTING BEFORE A POSITION   #
	#---------------------------------#

	def SplitBeforePosition(n)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitBeforePosition(n)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsBeforePosition(n)
			return This.SplitBeforePosition(n)

	  #-------------------------------------#
	 #   SPLITTING BEFORE MANY POSITIONS   #
	#-------------------------------------#

	def SplitBeforePositions(panPos)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitBeforePositions(panPos)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def SplitBeforeThesePositions(panPos)
			return This.SplitBeforePositions(panPos)

		def SplitBeforeManyPositions(panPos)
			return This.SplitBeforePositions(panPos)

		#--

		def SplitsBeforePositions(panPos)
			return This.SplitsBeforePositions(panPos)

		def SplitsBeforeThesePositions(panPos)
			return This.SplitBeforePositions(panPos)

		def SplitsBeforeManyPositions(panPos)
			return This.SplitBeforePositions(panPos)

		#>

	  #-----------------------#
	 #    SPLITTING AFTER    #
	#=======================#

	def SplitAfter(p)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAfter(p)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsAfter(p)
			return This.SplitAfter(p)

	  #--------------------------------------#
	 #   SPLITTING AFTER A GIVEN POSITION   #
	#--------------------------------------#

	def SplitAfterPosition(n)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAfterPosition(n)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsAfterPosition(n)
			return This.SplitAfterPosition(n)

	  #------------------------------------#
	 #   SPLITTING AFTER MANY POSITIONS   #
	#------------------------------------#

	def SplitAfterPositions(panPos)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAfterPositions(panPos)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def SplitAfterThesePositions(panPos)
			return This.SplitAfterPositions(panPos)

		def SplitAfterManyPositions(panPos)
			return This.SplitAfterPositions(panPos)

		#--

		def SplitsAfterPositions(panPos)
			return This.SplitAfterPositions(panPos)

		def SplitsAfterThesePositions(panPos)
			return This.SplitAfterPositions(panPos)

		def SplitsAfterManyPositions(panPos)
			return This.SplitAfterPositions(panPos)

		#>

	  #---------------------------------#
	 #  SPLITTING AT A GIVEN SECTION   #
	#=================================#

	def SplitAtSection(n1, n2)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAtSection(n1, n2)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunnctionAlternativeForms

		def SplitAtThisSection(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitBetween(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitBetweenPositions(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitBetweenThesePositions(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitBetweenManyPositions(n1, n2)
			return This.SplitAtSection(n1, n2)

		#--

		def SplitsAtSection(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitsAtThisSection(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitsBetween(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitsBetweenPositions(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitsBetweenThesePositions(n1, n2)
			return This.SplitAtSection(n1, n2)

		def SplitsBetweenManyPositions(n1, n2)
			return This.SplitAtSection(n1, n2)

		#>

	def SplitAtSectionIB(n1, n2)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAtSectionIB(n1, n2)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunnctionAlternativeForms

		def SplitAtThisSectionIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitBetweenIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitBetweenPositionsIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitBetweenThesePositionsIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitBetweenManyPositionsIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		#--

		def SplitsAtSectionIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitsAtThisSectionIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitsBetweenIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitsBetweenPositionsIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitsBetweenThesePositionsIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		def SplitsBetweenManyPositionsIB(n1, n2)
			return This.SplitAtSectionIB(n1, n2)

		#>

	  #------------------------------#
	 #  SPLITTING AT MANY SECTIONS  #
	#------------------------------#

	def SplitAtSections(paSections)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAtSections(paSections)
		aResult = This.PositionsAt(anPos)
		return aResult


		#< @FunnctionAlternativeForms

		def SplitAtTheseSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitBetweenSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitBetweenTheseSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitAtManySections(paSections)
			return This.SplitAtSections(paSections)

		def SplitBetweenManySections(paSections)
			return This.SplitAtSections(paSections)

		#--

		def SplitsAtSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitsAtTheseSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitsBetweenSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitsBetweenTheseSections(paSections)
			return This.SplitAtSections(paSections)

		def SplitsAtManySections(paSections)
			return This.SplitAtSections(paSections)

		def SplitsBetweenManySections(paSections)
			return This.SplitAtSections(paSections)

		#>

	def SplitAtSectionsIB(paSections)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAtSectionsIB(paSections)
		aResult = This.PositionsAt(anPos)
		return aResult
			
		#< @FunnctionAlternativeForms

		def SplitAtTheseSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitBetweenSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitBetweenTheseSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitAtManySectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitBetweenManySectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		#--

		def SplitsAtSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitsAtTheseSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitsBetweenSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitsBetweenTheseSectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitsAtManySectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		def SplitsBetweenManySectionsIB(paSections)
			return This.SplitAtSectionsIB(paSections)

		#>

	  #=====================================#
	 #  SPLITTING BEFORE A GIVEN SECTION   #
	#=====================================#

	def SplitBeforeSection(n1, n2)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitBeforeSection(n1, n2)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunnctionAlternativeForm

		def SplitBeforeThisSection(n1, n2)
			return This.SplitBeforeSection(n1, n2)

		#--

		def SplitsBeforeSection(n1, n2)
			return This.SplitBeforeSection(n1, n2)

		def SplitsBeforeThisSection(n1, n2)
			return This.SplitBeforeSection(n1, n2)

		#>

	def SplitBeforeSectionIB(n1, n2)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitBeforeSectionIB(n1, n2)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunnctionAlternativeForm

		def SplitBeforeThisSectionIB(n1, n2)
			return This.SplitBeforeSectionIB(n1, n2)

		#--

		def SplitsBeforeSectionIB(n1, n2)
			return This.SplitBeforeSectionIB(n1, n2)

		def SplitsBeforeThisSectionIB(n1, n2)
			return This.SplitBeforeSectionIB(n1, n2)

		#>

	  #----------------------------------#
	 #  SPLITTING BEFORE MANY SECTIONS  #
	#----------------------------------#

	def SplitBeforeSections(paSections)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitBeforeSections(paSections)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def SplitBeforeTheseSections(paSections)
			return This.SplitBeforeSections(paSections)

		def SplitBeforeManySections(paSections)
			return This.SplitBeforeSections(paSections)

		#--

		def SplitsBeforeSections(paSections)
			return This.SplitBeforeSections(paSections)

		def SplitsBeforeTheseSections(paSections)
			return This.SplitBeforeSections(paSections)

		def SplitsBeforeManySections(paSections)
			return This.SplitBeforeSections(paSections)

		#>

	def SplitBeforeSectionsIB(paSections)
		if NOT ( isList(paSections) and Q(paSections).IsListOfPairsOfNumbers() )
			StzRaise("Incorrect param type! paSections must be a list of pairs of numbers.")
		ok

		anPos = StzListOfPairsQ(paSections).FirstItems()
		nLen = len(anPos)

		anTempPos = []
		for i = 1 to nLen
			anTempPos + (anPos[i] + 1)
		next

		return This.SplitBeforePositions(anTempPos)

		#< @FunctionAlternativeForms

		def SplitBeforeTheseSectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)

		def SplitBeforeManySectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)

		#--

		def SplitsBeforeSectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)

		def SplitsBeforeTheseSectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)

		def SplitsBeforeManySectionsIB(paSections)
			return This.SplitBeforeSectionsIB(paSections)
	
		#>

	  #------------------------------------#
	 #  SPLITTING AFTER A GIVEN SECTION   #
	#====================================#

	def SplitAfterSection(n1, n2)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAfterSection(n1, n2)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def SplitAfterThisSection(n1, n2)
			return This.SplitAfterSection(n1, n2)

		#--

		def SplitsAfterSection(n1, n2)
			return This.SplitAfterSection(n1, n2)

		def SplitsAfterThisSection(n1, n2)
			return This.SplitAfterSection(n1, n2)

		#>

	def SplitAfterSectionIB(n1, n2)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAfterSectionIB(n1, n2)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def SplitAfterThisSectionIB(n1, n2)
			return This.SplitAfterSectionIB(n1, n2)

		#--

		def SplitsAfterSectionIB(n1, n2)
			return This.SplitAfterSectionIB(n1, n2)

		def SplitsAfterThisSectionIB(n1, n2)
			return This.SplitAfterSectionIB(n1, n2)

		#>

	  #---------------------------------#
	 #  SPLITTING AFTER MANY SECTIONS  #
	#---------------------------------#

	def SplitAfterSections(paSections)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAfterSections(paSections)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def SplitAfterTheseSections(paSections)
			return This.SplitAfterSections(paSections)

		def SplitAfterManySections(paSections)
			return This.SplitAfterSections(paSections)

		#--

		def SplitsAfterSections(paSections)
			return This.SplitAfterSections(paSections)

		def SplitsAfterTheseSections(paSections)
			return This.SplitAfterSections(paSections)

		def SplitsAfterManySections(paSections)
			return This.SplitAfterSections(paSections)

		#>

	def SplitAfterSectionsIB(paSections)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAfterSectionsIB(paSections)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def SplitAfterTheseSectionsIB(paSections)
			return This.SplitAfterSectionsIB(paSections)

		def SplitAfterManySectionsIB(paSections)
			return This.SplitAfterSectionsIB(paSections)

		#--

		def SplitsAfterSectionsIB(paSections)
			return This.SplitAfterSectionsIB(paSections)

		def SplitsAfterTheseSectionsIB(paSections)
			return This.SplitAfterSectionsIB(paSections)

		def SplitsAfterManySectionsIB(paSections)
			return This.SplitAfterSectionsIB(paSections)

		#>

	  #-----------------------------------#
	 #   SPLITTING TO PARTS OF N ITEMS   #
	#===================================#

	def SplitToPartsOfNItems(n)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitToPartsOfNItems(n)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunctionAlternativeForm

		def SplitToPartsOfN(n)
			return This.SplitToPartsOfNItems(n)

		def SplitToPartsOf(n)
			return This.SplitToPartsOfNItems(n)

		def SplitToPartsOfNPositions(n)
			return This.SplitToPartsOfNItems(n)

		#--

		def SplitsToPartsOfNItems(n)
			return This.SplitToPartsOfNItems(n)

		def SplitsToPartsOfN(n)
			return This.SplitToPartsOfNItems(n)

		def SplitsToPartsOf(n)
			return This.SplitToPartsOfNItems(n)

		def SplitsToPartsOfNPositions(n)
			return This.SplitToPartsOfNItems(n)

		#>

	  #---------------------------------------------#
	 #    SPLITTING TO PARTS OF EXACTLY N ITEMS    #
	#---------------------------------------------#

	def SplitToPartsOfExactlyNItems(n)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitToPartsOfExactlyNItems(n)
		aResult = This.PositionsAt(anPos)
		return aResult

		#< @FunctionAlternativeForms

		def SplitToPartsOfExactlyNPositions(n)
			return This.SplitToPartsOfExactlyNItems(n)

		#--

		def SplitsToPartsOfExactlyNItems(n)
			return This.SplitToPartsOfExactlyNItems(n)

		def SplitsToPartsOfExactlyNPositions(n)
			return This.SplitToPartsOfExactlyNItems(n)

		#>

	  #----------------------------#
	 #    SPLITTING TO N PARTS    #
	#----------------------------#

	def SplitToNParts(n)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitToNParts(n)
		aResult = This.PositionsAt(anPos)
		return aResult	

		def SplitsToNParts(n)
			return This.SplitToNParts(n)

	  #-----------------------------------------------#
	 #  SPLITTING AROUND POSITION(S) OR SECTTION(s)  #
	#===============================================#

	def SplitAround(p)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAround(p)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsAround(p)
			return This.SplitAround(p)

	def SplitAroundIB(n)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAroundIB(p)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsAroundIB(n)
			return This.SplitAroundIB(n)

	  #-------------------------------#
	 #  SPLITTING AROUND A POSITION  #
	#===============================#

	def SplitAroundPosition(n)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAroundPosition(n)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsAroundPosition(n)
			return This.SplitAroundPosition(n)

	def SplitAroundPositionIB(n)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAroundPositionIB(n)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsAroundPositionIB(n)
			return This.SplitAroundPositionIB(n)

	  #------------------------------#
	 #  SPLITTING AROUND POSITIONS  #
	#------------------------------#

	def SplitAroundPositions(panPos)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAroundPositions(panPos)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsAroundPositions(panPos)
			return This.SplitAroundPositions(panPos)

	def SplitAroundPositionsIB(panPos)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAroundPositionsIB(panPos)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsAroundPositionsIB(panPos)
			return This.SplitAroundPositionsIB(panPos)

	  #------------------------------#
	 #  SPLITTING AROUND A SECTION  #
	#------------------------------#

	def SplitAroundSection(n1, n2)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAroundSection(n1, n2)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsAroundSection(n1, n2)
			return This.SplitAroundSection(n1, n2)

	def SplitAroundSectionIB(n1, n2)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAroundSectionIB(n1, n2)
		aResult = This.PositionsAt(anPos)
		return aResult
		
		def SplitsAroundSectionIB(n1, n2)
			return This.SplitAroundSectionIB(n1, n2)

	  #-----------------------------#
	 #  SPLITTING AROUND SECTIONS  #
	#-----------------------------#

	def SplitAroundSections(panSections)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAroundSections(panSections)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsAroundSections(panSections)
			return This.SplitAroundSections(panSections)

	def SplitAroundSectionsIB(panSections)
		anPos = StzSplitterQ(This.NumberOfItems()).SplitAroundSectionsIB(panSections)
		aResult = This.PositionsAt(anPos)
		return aResult

		def SplitsAroundSectionsIB(panSections)
			return This.SplitAroundSectionsIB(panSections)

/*---

pron()

# Given the string: "abracadabra", replace programatically:
#
#	the first 'a' with 'A'
#	the second 'a' with 'B'
#	the fourth 'a' with 'C'
#	the fifth 'a' with 'D'
#	the first 'b' with 'E'
#	the second 'r' with 'F'
#
# The answer should, of course, be : "AErBcadCbFD".

Q("abracadabra") {

	ReplaceNth(5, 'a', :with = 'D')
	ReplaceNth(4, 'a', :with = 'C')
	ReplaceNth(2, 'a', :with = 'B')
	ReplaceNth(1, 'a', :with = 'A')

	ReplaceNth(1, 'b', :with = 'E')
	ReplaceNth(2, 'r', :with = 'F')

	? Content()
	#--> AErBcadCbFD
}

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*---

pron()

Q("abracadabra") {
	ReplaceManyNthSubStrings([
		[ 1, 'a', :with = 'A' ],
		[ 2, 'a', :with = 'B' ],
		[ 4, 'a', :with = 'C' ],
		[ 5, 'a', :with = 'D' ],
	
		[ 1, 'b', :with = 'E' ],
		[ 2, 'r', :with = 'F' ]
	])

	? Content()
}

proff()

/*---

pron()

Naturally() {
	Given the string "abracadabra" replace programatically

		the first 'a' with 'A'
		the second 'a' with 'B'
		the fourth 'a' with 'C'
		the fifth 'a' with 'D'
		the first 'b' with 'E'
		the second 'r' with 'F'

	The answer should of course be "AErBcadCbFD"
}

proff()

