#TODO add a stzListOfSectionsTest.ring file

#TODO Add these methods:
#	- RemoveIncluded()

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

		if KeepingHistory() = _TRUE_
			This.AddHistoricValue(This.Content())
		ok

	def Content()
		return @aContent

	def Copy()
		return This

	def Update(paNewSections)
		if CheckingParam()
			if isList(paNewSections) and StzListQ(paNewSections).IsWithNamedParam()
				paNewSections = paNewSections[2]
			ok

			if NOT @IsListOfPairsOfNumbers(paNewSections)
				StzRaise("Incorrect param type! paNewSections must be a list of pairs of numbers.")
			ok
		ok

		@aContent = paNewSections

		if KeepingHisto() = _TRUE_
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		def UpdateWith(paNewSections)
			This.Update(paNewSections)

	  #----------------------------------------------------------#
	 #  MERGING THE Adjacent SECTIONS IN THE LIST OF SECTIONS  #
	#----------------------------------------------------------#

	def MergeContiguous() #ai #claude

		/* EXAMPLE

		o1 = new stzListOfSections([
			[ 1, 4], [6, 8], [9, 10], [12, 13], [13, 15] ]
		])
		o1.MergeContiguous()
		? o1.Content()
		#--> [ [1, 4], [6, 10], [12, 15] ]

		*/

    		aContent = This.Content()
    		nLen = len(aContent)

    		if nLen = 0
        		return
    		ok

    		aResult = []
    		aCurrentMerged = aContent[1]

		for i = 2 to nLen
		        aNextPair = This.Item(i)
		
		        if aCurrentMerged[2] >= aNextPair[1] - 1

		            # Merge sections

		            aCurrentMerged[2] = @max([ aCurrentMerged[2], aNextPair[2] ])

		        else

		            # Add current merged section and start a new merge

		            aResult + aCurrentMerged
		            aCurrentMerged = aNextPair
		        ok
		next
		
		# Add the last merged section

		aResult + aCurrentMerged
		
		This.UpdateWith(aResult)

		#< @FunctionFluentForm	

		def MergeContiguousQ()
			This.MergeContiguous()
			return This

		#>

		#< @FunctionAlternativeForm

		def MergeAdjuscent()
			This.MergeContiguous()

			def MergeAdjuscentQ()
				return This.MergeContiguousQ()

		#>

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
		# Returns _TRUE_ if one section includes the other	
	
		# Check if section1 includes section2
		if aSection1[1] <= aSection2[1] and aSection1[2] >= aSection2[2]
			return _TRUE_
		ok
		
		# Check if section2 includes section1
		if aSection2[1] <= aSection1[1] and aSection2[2] >= aSection1[2]
			return _TRUE_
		ok
		
		return _FALSE_
	
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
		# Returns _TRUE_ if one section overlaps the other	
	
		# Check if section1 overlaps section2
		if ( aSection2[1] >= aSection1[1] and aSection2[1] <= aSection1[2] ) or
		   ( aSection2[2] >= aSection1[1] and aSection2[2] <= aSection1[2] )

			return _TRUE_
		ok	
	
		# Check if section2 overlaps section1

		if ( aSection1[1] >= aSection2[1] and aSection1[1] <= aSection2[2] ) or
		   ( aSection1[2] >= aSection2[1] and aSection1[2] <= aSection2[2] )

			return _TRUE_
		ok

		return _FALSE_
	
	def pvtMergeOverlappingSections(aSection1, aSection2)
		# Returns a new section that spans both input sections
		
		nStart = pvtMin(aSection1[1], aSection2[1])
		nEnd = pvtMax(aSection1[2], aSection2[2])
		
		return [nStart, nEnd]
