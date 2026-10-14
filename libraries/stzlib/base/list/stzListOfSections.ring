#TODO add a stzListOfSectionsTest.ring file

#TODO Add these methods:
#	- RemoveIncluded()

func StzListOfSectionsQ(paSections)
	return new stzListOfSections(paSections)

	func StzSectionsQ(paSections)
		return StzListOfSectionsQ(paSections)

class stzSections from stzListOfSections

# Holds a list of [ start, end ] sections of positions and merges them: the included ones, the overlapping ones, or the touching ones.
#
# A section is a pair of positions, [ 3, 7 ] meaning the third to the seventh. Build the list with
# new stzListOfSections(aSections), or with StzListOfSectionsQ or StzSectionsQ; the string module
# also builds one internally to merge the sections it finds, and stzListOfPairs hands one back
# through ToStzListOfSections. The verbs (Merge, MergeIncluded, MergeOverlapping, MergeContiguous)
# change the held sections in place, the Q form returning the object for chaining. Three things
# found today. Merge, MergeIncluded and MergeOverlapping sort the sections first and leave side-by-
# side neighbours apart ([ 1, 5 ] and [ 6, 8 ] stay two), while MergeContiguous joins neighbours but
# does not sort, so an unsorted input loses sections. And the past-tense forms (Merged,
# SectionsMerged, IncludedSectionsMerged, OverLappedSectionsMerged, ContiguousSectionsMerged) also
# change the object, because Copy returns the object itself. The pvt methods are the private helpers
# of the merges and cannot be called from outside.
#
#   receiver   o1 = new stzListOfSections([ [ 10, 12 ], [ 1, 5 ], [ 4, 8 ], [ 20, 22 ], [ 11, 15 ]
#              ])
#   example    ? @@( o1.Merged() )
#              #--> [ [ 1, 8 ], [ 10, 15 ], [ 20, 22 ] ]
#              o2 = new stzListOfSections([ [ 1, 4 ], [ 6, 8 ], [ 9, 10 ], [ 12, 13 ], [ 13, 15 ] ])
#              o2.MergeContiguous()
#              ? @@( o2.Content() )
#              #--> [ [ 1, 4 ], [ 6, 10 ], [ 12, 15 ] ]
#              o3 = new stzListOfSections([ [ 1, 5 ], [ 6, 8 ] ])
#              o3.Merge()
#              ? @@( o3.Content() )
#              #--> [ [ 1, 5 ], [ 6, 8 ] ]
#   see        stzListOfPairs, stzList, stzString
class stzListOfSections from stzLists
	@aContent

	# Builds a list of sections, each section a [ start, end ] pair of positions.
	#
	#   paSections   the sections, a list of two-number lists
	#   returns      nothing; the object is built
	#   note         a pair such as [ 3, 1 ] whose end is before its start is accepted as it stands
	#   see          Content, Merge
	def init(paSections)
		if NOT ( isList(paSections) and @IsListOfSections(paSections) )
			StzRaise("Incorrect param type! paSections must be a list of sections.")
		ok

		@aContent = paSections

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	# Returns the sections as they stand now, after the merges made so far.
	#
	#   returns    a list of [ start, end ] pairs
	#   see        Update, Merged
	def Content()
		return @aContent

	# Returns the object itself, not a separate copy.
	#
	#   returns    the same list of sections object
	#   note       new stzListOfSections(o1.Content()) builds an independent copy
	#   warning    the answer is not a copy: any edit made through it is made on the original, which
	#              is why every Merged form below changes the object it is called on
	#   see        Content, Merged
	def Copy()
		return This

	# Replaces the sections with a new list of sections.
	#
	#   paNewSections   the new sections, a list of two-number pairs, or a pair such as [ :With,
	#                   aSections ]
	#   returns         nothing; the content changes
	#   warning         anything that is not a list of pairs of numbers raises Incorrect param type!
	#                   paNewSections must be a list of pairs of numbers
	#   see             UpdateWith, Content
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

		# Replaces the sections with a new list of sections.
		#
		#   paNewSections   the new sections, a list of two-number pairs
		#   returns         nothing; the content changes
		#   note            the same call as Update
		#   see             Update, Content
		def UpdateWith(paNewSections)
			This.Update(paNewSections)

	  #----------------------------------------------------------#
	 #  MERGING THE Adjacent SECTIONS IN THE LIST OF SECTIONS  #
	#----------------------------------------------------------#

	# Joins each run of sections that touch or overlap into one section, in place.
	#
	#   returns    nothing; the content changes. MergeContiguousQ returns the object for chaining
	#   note       [ 1, 4 ], [ 6, 8 ], [ 9, 10 ], [ 12, 13 ], [ 13, 15 ] gives [ 1, 4 ], [ 6, 10 ],
	#              [ 12, 15 ]; MergeAdjuscent is the same call
	#   warning    the sections must already be sorted by start, because nothing sorts them: [ 10,
	#              12 ], [ 6, 8 ], [ 1, 5 ], [ 4, 9 ] answers just [ 10, 12 ], and [ 5, 6 ], [ 1, 2
	#              ] answers just [ 5, 6 ], the sections that start earlier being swallowed
	#   see        ContiguousSectionsMerged, MergeOverlapping, MergeIncluded
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

		# Joins each run of sections that touch or overlap into one section, in place.
		#
		#   returns    nothing; the content changes
		#   note       the same call as MergeContiguous
		#   warning    the sections must already be sorted by start, as in MergeContiguous
		#   see        MergeContiguous, ContiguousSectionsMerged
		#>
		#< @FunctionAlternativeForm
		def MergeAdjuscent()
			This.MergeContiguous()

			def MergeAdjuscentQ()
				return This.MergeContiguousQ()

	# Returns the sections with each touching or overlapping run joined into one section.
	#
	#   returns    a list of [ start, end ] pairs
	#   note       the sections must already be sorted by start, as in MergeContiguous;
	#              AdjuscentSectionsMerged is the same call
	#   warning    it also changes the object: Copy returns the object itself, so after the call
	#              Content holds the merged sections too (tried on [ 1, 4 ], [ 6, 8 ], [ 9, 10 ], [
	#              12, 13 ], [ 13, 15 ])
	#   see        MergeContiguous, IncludedSectionsMerged
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

	# Replaces each section that lies inside another by the larger one, in place, and sorts the sections.
	#
	#   returns    nothing; the content changes. MergeIncludedQ returns the object for chaining
	#   note       the sections come out sorted by start even when none is included: [ 10, 12 ], [
	#              1, 5 ], [ 4, 8 ] gives [ 1, 5 ], [ 4, 8 ], [ 10, 12 ]; sections that only overlap
	#              are left apart; MergeInclusive is the same call
	#   see        IncludedSectionsMerged, MergeOverlapping, Merge
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

		# Replaces each section that lies inside another by the larger one, in place, and sorts the sections.
		#
		#   returns    nothing; the content changes
		#   note       the same call as MergeIncluded
		#   see        MergeIncluded, IncludedSectionsMerged
		#>
		#< @FunctionAlternativeForm
		def MergeInclusive()
			This.MergeIncluded()

			def MergeInclusiveQ()
				return This.MergeIncludedQ()

	# Returns the sections with each section that lies inside another absorbed, sorted by start.
	#
	#   returns    a list of [ start, end ] pairs
	#   note       [ 1, 10 ], [ 2, 4 ], [ 12, 20 ], [ 13, 14 ], [ 30, 31 ] gives [ 1, 10 ], [ 12, 20
	#              ], [ 30, 31 ]
	#   warning    it also changes the object: Copy returns the object itself, so after the call
	#              Content holds the merged sections too (tried on [ 1, 10 ], [ 2, 4 ], [ 12, 20 ],
	#              [ 13, 14 ], [ 30, 31 ])
	#   see        MergeIncluded, OverLappedSectionsMerged
		#>
	def IncludedSectionsMerged()

		_aResult_ = This.Copy().MergeIncludedQ().Content()
		return _aResult_

		def InclusiveSectionsMerged()
			return This.IncludedSectionsMerged()

		
	  #--------------------------------#
	 #  MERGING OVERLAPPING SECTIONS  #
	#================================#

	# Joins sections that share at least one position into one section, in place, after sorting them.
	#
	#   returns    nothing; the content changes. MergeOverlappingQ returns the object for chaining
	#   note       sections that merely sit side by side do not merge: [ 1, 5 ], [ 6, 8 ] stays as
	#              it is, while [ 1, 5 ], [ 5, 8 ] becomes [ 1, 8 ]; use MergeContiguous to join
	#              neighbours; MergeOverlappingSections is the same call
	#   see        OverLappedSectionsMerged, MergeIncluded, MergeContiguous
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

		# Joins sections that share at least one position into one section, in place, after sorting them.
		#
		#   returns    nothing; the content changes
		#   note       the same call as MergeOverlapping
		#   see        MergeOverlapping, OverLappedSectionsMerged
		#>
		#< @FunctionAlternativeForms
		def MergeOverlappingSections()
			This.MergeOverlapping()

			def MergeOverlappingSectionsQ()
				return This.MergeOverlappingQ()

	# Returns the sections with those that share a position joined, sorted by start.
	#
	#   returns    a list of [ start, end ] pairs
	#   note       [ 1, 5 ], [ 4, 8 ], [ 10, 12 ], [ 11, 15 ], [ 20, 22 ] gives [ 1, 8 ], [ 10, 15
	#              ], [ 20, 22 ]
	#   warning    it also changes the object: Copy returns the object itself, so after the call
	#              Content holds the merged sections too (tried on [ 1, 5 ], [ 4, 8 ], [ 10, 12 ], [
	#              11, 15 ], [ 20, 22 ])
	#   see        MergeOverlapping, IncludedSectionsMerged
		#>
	def OverLappedSectionsMerged()
		_cResult_ = This.Copy().MergeoverLappingQ().Content()
		return _cResult_

	  #--------------------------------------------------#
	 #  MERGING SECTIONS BOTH ICLUSIVE AND OVERLAPPING  #
	#--------------------------------------------------#

	# Absorbs included sections and then joins overlapping ones, in place, so the sections come out sorted and apart.
	#
	#   returns    nothing; the content changes. MergeQ returns the object for chaining
	#   note       sections that only sit side by side are not joined, so [ 1, 5 ], [ 6, 8 ] stays
	#              as it is; the input may come in any order
	#   see        Merged, MergeIncluded, MergeOverlapping
	def Merge()
		This.MergeInclusive()
		This.MergeOverlapping()

		def MergeQ()
			This.Merge()
			return This

	# Returns the sections after absorbing included ones and joining overlapping ones, sorted by start.
	#
	#   returns    a list of [ start, end ] pairs
	#   note       the input may come in any order
	#   warning    it also changes the object: Copy returns the object itself, so after the call
	#              Content holds the merged sections too (tried on [ 10, 12 ], [ 1, 5 ], [ 4, 8 ], [
	#              20, 22 ], [ 11, 15 ])
	#   see        Merge, SectionsMerged
	def Merged()
		_aResult_ = This.Copy().MergeQ().Content()
		return _aResult_

		# Returns the sections after absorbing included ones and joining overlapping ones, sorted by start.
		#
		#   returns    a list of [ start, end ] pairs
		#   note       the same call as Merged
		#   warning    it also changes the object, as Merged does
		#   see        Merged, Merge
		def SectionsMerged()
			return This.Merged()

	#------------------------------#
	PRIVATE	# KTICHEN OF THE CLASS #
	#------------------------------#

	# Returns 1 when one of two sections lies inside the other, whichever way round they are given.
	#
	#   aSection1   the first section, [ start, end ]
	#   aSection2   the second section, [ start, end ]
	#   returns     1 or 0
	#   note        private: calling it from outside raises error R26, so it was run through a
	#               subclass; [ 1, 10 ] and [ 2, 3 ] answer 1, and [ 1, 5 ] and [ 4, 8 ] answer 0
	#   see         pvtDoOverlap, MergeIncluded
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
	
	# Returns the section that spans two given sections, from the smaller start to the larger end.
	#
	#   aSection1   the first section, [ start, end ]
	#   aSection2   the second section, [ start, end ]
	#   returns     a [ start, end ] pair
	#   note        private; run through a subclass: [ 1, 5 ] and [ 4, 8 ] give [ 1, 8 ]
	#   see         pvtMergeOverlappingSections, MergeIncluded
	func pvtMergeInclusiveSections(aSection1, aSection2)
		# Returns a new section that spans both input sections
		
		_nStart_ = pvtMin(aSection1[1], aSection2[1])
		_nEnd_ = pvtMax(aSection1[2], aSection2[2])
		
		return [_nStart_, _nEnd_]
	
	# Returns the smaller of two numbers.
	#
	#   n1         the first number
	#   n2         the second number
	#   returns    a number
	#   note       private; run through a subclass: 3 and 2 give 2
	#   see        pvtMax
	func pvtMin(n1, n2)
		if n1 < n2
			return n1
		ok
		return n2
	
	# Returns the larger of two numbers.
	#
	#   n1         the first number
	#   n2         the second number
	#   returns    a number
	#   note       private; run through a subclass: 3 and 2 give 3
	#   see        pvtMin
	func pvtMax(n1, n2)
		if n1 > n2
			return n1
		ok
		return n2

	# Returns 1 when two sections share at least one position.
	#
	#   aSection1   the first section, [ start, end ]
	#   aSection2   the second section, [ start, end ]
	#   returns     1 or 0
	#   note        private; run through a subclass: [ 1, 5 ] and [ 4, 8 ] answer 1, and [ 1, 5 ]
	#               and [ 6, 8 ] answer 0, so neighbours do not overlap
	#   see         pvtIsInclusive, MergeOverlapping
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
	
	# Returns the section that spans two given sections, from the smaller start to the larger end.
	#
	#   aSection1   the first section, [ start, end ]
	#   aSection2   the second section, [ start, end ]
	#   returns     a [ start, end ] pair
	#   note        private; run through a subclass: [ 1, 5 ] and [ 4, 8 ] give [ 1, 8 ]
	#   see         pvtMergeInclusiveSections, MergeOverlapping
	def pvtMergeOverlappingSections(aSection1, aSection2)
		# Returns a new section that spans both input sections
		
		_nStart_ = pvtMin(aSection1[1], aSection2[1])
		_nEnd_ = pvtMax(aSection1[2], aSection2[2])
		
		return [_nStart_, _nEnd_]
