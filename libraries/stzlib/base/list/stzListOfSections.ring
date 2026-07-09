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

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	def Content()
		return @aContent

	def Copy()
		return This

	def Update(paNewSections)
		if CheckingParam()
			if isList(paNewSections) and IsWithNamedParamList(paNewSections)
				paNewSections = paNewSections[2]
			ok

			if NOT @IsListOfPairsOfNumbers(paNewSections)
				StzRaise("Incorrect param type! paNewSections must be a list of pairs of numbers.")
			ok
		ok

		@aContent = paNewSections

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		def UpdateWith(paNewSections)
			This.Update(paNewSections)

	  #----------------------------------------------------------#
	 #  MERGING THE Adjacent SECTIONS IN THE LIST OF SECTIONS  #
	#----------------------------------------------------------#

	def MergeContiguous() #ai #claude

		/* EXAMPLE

		_o1_ = new stzListOfSections([
			[ 1, 4], [6, 8], [9, 10], [12, 13], [13, 15] ]
		])
		_o1_.MergeContiguous()
		? _o1_.Content()
		#--> [ [1, 4], [6, 10], [12, 15] ]

		*/

    		_aContent_ = This.Content()
    		_nLen_ = len(_aContent_)

    		if _nLen_ = 0
        		return
    		ok

    		_aResult_ = []
    		_aCurrentMerged_ = _aContent_[1]

		for i = 2 to _nLen_
		        _aNextPair_ = This.Item(i)
		
		        if _aCurrentMerged_[2] >= _aNextPair_[1] - 1

		            # Merge sections

		            _aCurrentMerged_[2] = @max([ _aCurrentMerged_[2], _aNextPair_[2] ])

		        else

		            # Add current merged section and start a new merge

		            _aResult_ + _aCurrentMerged_
		            _aCurrentMerged_ = _aNextPair_
		        ok
		next
		
		# Add the last merged section

		_aResult_ + _aCurrentMerged_
		
		This.UpdateWith(_aResult_)

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
		_aResult_ = This.Copy().MergeContiguousQ().Content()
		return _aResult_

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

		_aSections_ = This.Content()
		_nLen_ = len(_aSections_)

		# If the list is empty or has only one section, nothing to merge
		if _nLen_ <= 1
			return
		ok
	
		# Sort sections based on first number, then by second number
		_aSectionsSorted_ = This.Copy().SortedInAscending()
		
		# Initialize result list with first section
		_aResult_ = []
		_aCurrentSection_ = _aSectionsSorted_[1]
		
		# Iterate through sections
		for i = 2 to _nLen_
			_aSection_ = _aSectionsSorted_[i]
			
			# Check if current section is included in current section
			if pvtIsInclusive(_aCurrentSection_, _aSection_)
				_aCurrentSection_ = pvtMergeInclusiveSections(_aCurrentSection_, _aSection_)
			
			# If not included, add current section to result and start new one
			else
				_aResult_ + _aCurrentSection_
				_aCurrentSection_ = _aSection_
			ok
		next
		
		# Add the last section
		_aResult_ + _aCurrentSection_
		
		# Update content with merged result
		This.UpdateWith(_aResult_)

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

		_aResult_ = This.Copy().MergeIncludedQ().Content()
		return _aResult_

		def InclusiveSectionsMerged()
			return This.IncludedSectionsMerged()

		
	  #--------------------------------#
	 #  MERGING OVERLAPPING SECTIONS  #
	#================================#

	def MergeOverlapping() #ClaudeAI

		_aSections_ = This.Content()
		_nLen_ = len(_aSections_)

		# If the list is empty or has only one section, nothing to merge
		if _nLen_ <= 1
			return
		ok
	
		# Sort sections based on first number
		_aSections_ = This.Copy().SortedInAscending()
		
		# Initialize result list with first section
		_aResult_ = []
		_aCurrentSection_ = _aSections_[1]
		
		# Iterate through sections
		for i = 2 to _nLen_
			_aSection_ = _aSections_[i]
	
			# Check if current section overlaps or is adjacent to current section
			if pvtDoOverlap(_aCurrentSection_, _aSection_)
				_aCurrentSection_ = pvtMergeOverlappingSections(_aCurrentSection_, _aSection_)
			
			# If no overlap, add current section to result and start new one
			else
				_aResult_ + _aCurrentSection_
				_aCurrentSection_ = _aSection_
			ok
		next
		
		# Add the last section
		_aResult_ + _aCurrentSection_
		
		# Update content with merged result
		This.UpdateWith(_aResult_)

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
		_cResult_ = This.Copy().MergeoverLappingQ().Content()
		return _cResult_

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
		_aResult_ = This.Copy().MergeQ().Content()
		return _aResult_

		def SectionsMerged()
			return This.Merged()

	#------------------------------#
	PRIVATE	# KTICHEN OF THE CLASS #
	#------------------------------#

	func pvtIsInclusive(aSection1, aSection2)
		# Returns 1 if one section includes the other	
	
		# Check if section1 includes section2
		if aSection1[1] <= aSection2[1] and aSection1[2] >= aSection2[2]
			return 1
		ok
		
		# Check if section2 includes section1
		if aSection2[1] <= aSection1[1] and aSection2[2] >= aSection1[2]
			return 1
		ok
		
		return 0
	
	func pvtMergeInclusiveSections(aSection1, aSection2)
		# Returns a new section that spans both input sections
		
		_nStart_ = pvtMin(aSection1[1], aSection2[1])
		_nEnd_ = pvtMax(aSection1[2], aSection2[2])
		
		return [_nStart_, _nEnd_]
	
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
		# Returns 1 if one section overlaps the other	
	
		# Check if section1 overlaps section2
		if ( aSection2[1] >= aSection1[1] and aSection2[1] <= aSection1[2] ) or
		   ( aSection2[2] >= aSection1[1] and aSection2[2] <= aSection1[2] )

			return 1
		ok	
	
		# Check if section2 overlaps section1

		if ( aSection1[1] >= aSection2[1] and aSection1[1] <= aSection2[2] ) or
		   ( aSection1[2] >= aSection2[1] and aSection1[2] <= aSection2[2] )

			return 1
		ok

		return 0
	
	def pvtMergeOverlappingSections(aSection1, aSection2)
		# Returns a new section that spans both input sections
		
		_nStart_ = pvtMin(aSection1[1], aSection2[1])
		_nEnd_ = pvtMax(aSection1[2], aSection2[2])
		
		return [_nStart_, _nEnd_]
