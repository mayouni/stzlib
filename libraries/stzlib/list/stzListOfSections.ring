#TODO add a stzListOfSectionsTest.ring file

func StzListOfSectionsQ(paSections)
	return new stzListOfSections(paSections)

	func StzSectionsQ(paSections)
		return StzListOfSectionsQ(paSections)

class stzSections from stzListOfSections

class stzListOfSections from stzLists
	@aContent

	def init(paSections)
		if NOT ( isList(paSections) and @IsListOfSections(paSections) )
			StzRaise("Incorrect param type! paSections must be a list of sections.")
		ok

		@aContent = paSections

	def Content()
		return @aContent

	def Copy()
		return This

	def UpdateWith(paNewSections)
		@aContent = paNewSections

		def Update(paNewSections)
			if isList(paNewSections) and StzListQ(paNewSections).IsWithNamedParam()
				paNewSections = paNewSections[2]
			ok

			@aContent = paNewSections

	  #----------------------------------------------------------#
	 #  MERGING THE ADJASCENT SECTIONS IN THE LIST OF SECTIONS  #
	#----------------------------------------------------------#

	def MergeContiguous()
		#EXAMPLE
		/*
		o1 = new stzListOfSections([
			[ 1, 4], [6, 8], [9, 10], [12, 13], [13, 15] ]
		])
		o1.MergeContiguous()
		? o1.Content()
		#--> [ [1, 4], [6, 10], [12, 15] ]

		*/

		aContent = This.Content()
		nLen = len(aContent)

		aResult = []

		for i = 1 to nLen - 1
			aCurrentPair = This.Pair(i)
			aNextPair = This.Pair(i+1)

			if aCurrentPair[2] = aNextPair[1] or
			   aCurrentPair[2] = aNextPair[1] - 1
				bContiguous = TRUE

				aResult + [ aCurrentPair[1], aNextPair[2] ]
				i++

			else
				bContiguous = FALSE
				aResult + aCurrentPair
			ok

		next

		if bContiguous = FALSE
			aResult = aContent[nLen]
		ok

		This.UpdateWith(aResult)
		

		def MergeContiguousQ()
			This.MergeContiguous()
			return This

		def MergeAdjuscent()
			This.MergeContiguous()

			def MergeAdjuscentQ()
				return This.MergeContiguousQ()

	def ContiguousSectionsMerged()
		aResult = This.Copy().MergeContiguousQ().Content()
		return aResult

		def AdjuscentSectionsMerged()
			return This.ContiguousSectionsMerged()

		def ContiguousMerged()
			return This.ContiguousSectionsMerged()

		def AdjuscentMerged()
			return This.ContiguousSectionsMerged()

	  #---------------------------------------------------------#
	 #  MERGING THE INCLUDED SECTIONS IN THE LIST OF SECTIONS  #
	#---------------------------------------------------------#

	def MergeIncluded() #ClaudeAI

		aSections = This.Content()
		nLen = len(aSections)

		# If the list is empty or has only one section, nothing to merge
		if nLen <= 1
			return
		ok
	
		# Sort sections based on first number, then by second number
		aSectionsSorted = This.Copy().SortedInAscending()
		
		# Initialize result list with first section
		aResult = []
		aCurrentSection = aSectionsSorted[1]
		
		# Iterate through sections
		for i = 2 to nLen
			aSection = aSectionsSorted[i]
			
			# Check if current section is included in current section
			if pvtIsInclusive(aCurrentSection, aSection)
				aCurrentSection = pvtMergeInclusiveSections(aCurrentSection, aSection)
			
			# If not included, add current section to result and start new one
			else
				aResult + aCurrentSection
				aCurrentSection = aSection
			ok
		next
		
		# Add the last section
		aResult + aCurrentSection
		
		# Update content with merged result
		This.UpdateWith(aResult)

		#< @FunctionFluentForm

		def MergeIncludedQ()
			This.MergeIncluded()
			return This

		#>

		#< @FunctionAlternativeForm

		def MergeInclusive()
			This.MergeIncluded()

			def MergeInclusiveQ()
				return This.MergeIncludedQ()

		#>

	def IncludedSectionsMerged()

		aResult = This.Copy().MergeIncludedQ().Content()
		return aResult

		def InclusiveSectionsMerged()
			return This.IncludedSectionsMerged()

		
	  #--------------------------------#
	 #  MERGING OVERLAPPING SECTIONS  #
	#================================#

	def MergeOverlapping() #ClaudeAI

		aSections = This.Content()
		nLen = len(aSections)

		# If the list is empty or has only one section, nothing to merge
		if nLen <= 1
			return
		ok
	
		# Sort sections based on first number
		asections = This.Copy().SortedInAscending()
		
		# Initialize result list with first section
		aResult = []
		aCurrentSection = aSections[1]
		
		# Iterate through sections
		for i = 2 to nLen
			aSection = aSections[i]
	
			# Check if current section overlaps or is adjacent to current section
			if pvtDoOverlap(aCurrentSection, aSection)
				aCurrentSection = pvtMergeOverlappingSections(aCurrentSection, aSection)
			
			# If no overlap, add current section to result and start new one
			else
				aResult + aCurrentSection
				aCurrentSection = aSection
			ok
		next
		
		# Add the last section
		aResult + aCurrentSection
		
		# Update content with merged result
		This.UpdateWith(aResult)

		#< @FunctionFluentForm

		def MergeOverlappingQ()
			This.MergeOverLapping()
			return This

		#>

		#< @FunctionAlternativeForms

		def MergeOverlappingSections()
			This.MergeOverlapping()

			def MergeOverlappingSectionsQ()
				return This.MergeOverlappingQ()

		#>

	def OverLappedSectionsMerged()
		cResult = This.Copy().MergeoverLappingQ().Content()
		return cResult

	  #--------------------------------------------------#
	 #  MERGING SECTIONS BOTH ICLUSIVE AND OVERLAPPING  #
	#--------------------------------------------------#

	def Merge()
		This.MergeInclusive()
		This.MergeOverlapping()

		def MergeQ()
			This.Merge()
			return This

	def Merged()
		aResult = This.Copy().MergeQ().Content()
		return aResult

		def SectionsMerged()
			return This.Merged()

	#------------------------------#
	PRIVATE	# KTICHEN OF THE CLASS #
	#------------------------------#

	func pvtIsInclusive(aSection1, aSection2)
		# Returns TRUE if one section includes the other	
	
		# Check if section1 includes section2
		if aSection1[1] <= aSection2[1] and aSection1[2] >= aSection2[2]
			return TRUE
		ok
		
		# Check if section2 includes section1
		if aSection2[1] <= aSection1[1] and aSection2[2] >= aSection1[2]
			return TRUE
		ok
		
		return FALSE
	
	func pvtMergeInclusiveSections(aSection1, aSection2)
		# Returns a new section that spans both input sections
		
		nStart = pvtMin(aSection1[1], aSection2[1])
		nEnd = pvtMax(aSection1[2], aSection2[2])
		
		return [nStart, nEnd]
	
	func pvtMin(n1, n2)
		if n1 < n2
			return n1
		ok
		return n2
	
	func pvtMax(n1, n2)
		if n1 > n2
			return n1
		ok
		return n2

	def pvtDoOverlap(aSection1, aSection2)
		# Returns TRUE if one section overlaps the other	
	
		# Check if section1 overlaps section2
		if ( aSection2[1] >= aSection1[1] and aSection2[1] <= aSection1[2] ) or
		   ( aSection2[2] >= aSection1[1] and aSection2[2] <= aSection1[2] )

			return TRUE
		ok	
	
		# Check if section2 overlaps section1

		if ( aSection1[1] >= aSection2[1] and aSection1[1] <= aSection2[2] ) or
		   ( aSection1[2] >= aSection2[1] and aSection1[2] <= aSection2[2] )

			return TRUE
		ok

		return FALSE
	
	def pvtMergeOverlappingSections(aSection1, aSection2)
		# Returns a new section that spans both input sections
		
		nStart = pvtMin(aSection1[1], aSection2[1])
		nEnd = pvtMax(aSection1[2], aSection2[2])
		
		return [nStart, nEnd]
