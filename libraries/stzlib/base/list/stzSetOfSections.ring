# Tells whether a value is a valid set of sections, without raising and without evaluating anything.
#
#   paSections   any value
#   returns      1 for a list of [ start, end ] pairs of numbers with no repeated pair, the empty list included; 0 for anything else
#   note         the order of the two numbers of a pair is not checked, as in stzSection, so [ 7, 5 ]
#                is a section; [ 1, 3 ] and [ 3, 1 ] are two different pairs. Two pairs are the same when
#                their numbers are equal, so [ 1, 3 ] and [ 1.0, 3.0 ] repeat each other
#   see          stzSetOfSections, IsListOfSections
func IsSetOfSections(paSections)
	if NOT isList(paSections)
		return 0
	ok

	if NOT IsListOfPairsOfNumbers(paSections)
		return 0
	ok

	if len(paSections) < 2
		return 1
	ok

	return IsSet(paSections)

	func @IsSetOfSections(paSections)
		return IsSetOfSections(paSections)

# Builds a stzSetOfSections from a list of [ start, end ] pairs and returns it, for chaining.
#
#   paSections   a list of [ start, end ] pairs of numbers with no repeated pair
#   returns      a stzSetOfSections; a list that is not a set of sections raises an error
#   see          stzSetOfSections, IsSetOfSections
func StzSetOfSectionsQ(paSections)
	return new stzSetOfSections(paSections)

# Holds a set of sections, [ start, end ] pairs of numbers with no repeated pair, in the order they were given.
#
# Build one with new stzSetOfSections(aSections) or StzSetOfSectionsQ(aSections). The argument is a
# list of pairs of numbers, the empty list being the empty set; anything else raises "Can't create
# the stzSetOfSections object": a value that is not a list, a pair of three items, a pair holding a
# text, or a pair given twice. IsSetOfSections answers the same question without raising. The rule
# follows stzSection and IsListOfSections: the order of the two numbers is not checked, so [ 7, 5 ]
# is a section, floats are numbers, and [ 1, 3 ] and [ 3, 1 ] are two different pairs. Update
# replaces the sections, Copy gives an independent set, and IntersectionWith gives a new set of the
# pairs found in both sets, as the sets of pairs they are: it does not compute the range shared by
# two overlapping sections, which none of the section classes offers. The inherited verbs that change
# the sections (AddItem, Merge, Sort, Reverse) go through UpdateWith, so they keep the set a set:
# AddItem of a pair already held raises.
#
#   receiver   o1 = new stzSetOfSections([ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ] ])
#   example    ? @@( o1.Content() )
#              #--> [ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ] ]
#              o2 = o1.IntersectionWith([ [ 2, 9 ], [ 1, 3 ], [ 4, 4 ] ])
#              ? @@( o2.Content() )
#              #--> [ [ 1, 3 ], [ 2, 9 ] ]
#              o3 = o1.Copy()
#              o3.Update([ [ 8, 8 ] ])
#              ? @@( o1.Content() )
#              #--> [ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ] ]
#              ? IsSetOfSections([ [ 1, 3 ], [ 1, 3 ] ])
#              #--> 0
#   see        stzListOfSections, stzSection, stzListSections, IsSetOfSections
class stzSetOfSections from stzListOfSections
	@aContent

	# Builds the set from a list of sections; a value that is not a set of sections raises an error.
	#
	#   paSections   a list of [ start, end ] pairs of numbers with no repeated pair; [ ] is the empty set
	#   returns      nothing; the object is built
	#   warning      a value that is not a list, a pair that is not two numbers or a pair given twice
	#                raises "Can't create the stzSetOfSections object. You must provide a list of
	#                sections."; the list is never kept, but Ring has already put the new object in
	#                the variable, so a variable that held a set holds the empty set afterwards
	#   see          Content, Update, IsSetOfSections
	def init(paSections)
		if NOT IsSetOfSections(paSections)
			StzRaise("Can't create the stzSetOfSections object. You must provide a list of sections.")
		ok

		@aContent = paSections

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	# Returns the sections the set holds, as a list of [ start, end ] pairs in the order given.
	#
	#   returns    a list of pairs; a list of its own, so changing it leaves the set as it was
	#   see        Copy, Update
	def Content()
		return @aContent

	# Returns a new set holding the same sections, which shares nothing with this one.
	#
	#   returns    a stzSetOfSections; updating either one leaves the other as it was
	#   see        Content, Update
	def Copy()
		return new stzSetOfSections(@aContent)

	# Replaces the sections of the set by a new list of sections; an invalid list raises and changes nothing.
	#
	#   paNewSections   the new sections, checked as the constructor checks them: a list of
	#                   [ start, end ] pairs of numbers with no repeated pair, or the named form
	#                   [ :With, aSections ]
	#   returns         nothing; the content changes
	#   warning         a value that is not a set of sections raises "Incorrect param type!
	#                   paNewSections must be a list of sections without a repeated pair." and the set
	#                   keeps the sections it had
	#   see             UpdateWith, Content, IsSetOfSections
	def Update(paNewSections)
		_aNewSections_ = []

		if isList(paNewSections) and IsWithNamedParamList(paNewSections)
			_aNewSections_ = paNewSections[2]
		else
			_aNewSections_ = paNewSections
		ok

		if NOT IsSetOfSections(_aNewSections_)
			StzRaise("Incorrect param type! paNewSections must be a list of sections without a repeated pair.")
		ok

		@aContent = _aNewSections_

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		# Replaces the sections of the set by a new list of sections, the same call as Update.
		#
		#   paNewSections   the new sections, a list of [ start, end ] pairs of numbers with no repeated pair
		#   returns         nothing; the content changes
		#   see             Update, Content
		def UpdateWith(paNewSections)
			This.Update(paNewSections)

	# Returns a new set of the sections found in both this set and another, in the order of this set.
	#
	#   paOtherSetOfSections   a stzSetOfSections, or a list of [ start, end ] pairs of numbers with
	#                          no repeated pair
	#   returns                a new stzSetOfSections; neither set changes. Two sections are the same
	#                          when their numbers are equal, so [ 1, 3 ] and [ 3, 1 ] are not shared
	#   note                   this is the intersection of two sets of pairs, not the range two
	#                          overlapping sections have in common: [ 1, 5 ] and [ 3, 8 ] share nothing
	#   warning                a value that is neither raises "Can't intersect with the other
	#                          sections. You must provide a stzSetOfSections or a list of sections
	#                          without a repeated pair."
	#   see                    Content, Copy, stzSet
	def IntersectionWith(paOtherSetOfSections)
		_aOther_ = []

		if isObject(paOtherSetOfSections)
			if ring_classname(paOtherSetOfSections) = "stzsetofsections"
				_aOther_ = paOtherSetOfSections.Content()
			else
				StzRaise("Can't intersect with the other sections. You must provide a stzSetOfSections or a list of sections without a repeated pair.")
			ok
		but isList(paOtherSetOfSections) and IsSetOfSections(paOtherSetOfSections)
			_aOther_ = paOtherSetOfSections
		else
			StzRaise("Can't intersect with the other sections. You must provide a stzSetOfSections or a list of sections without a repeated pair.")
		ok

		if len(@aContent) = 0 or len(_aOther_) = 0
			return new stzSetOfSections([])
		ok

		# Engine-backed, as stzSet.IntersectionWith: the pairs of this set that the other set holds, in this order
		_pA_ = StzEngineMarshalList(@aContent)
		_pB_ = StzEngineMarshalList(_aOther_)
		_pR_ = StzEngineListIntersectionCS(_pA_, _pB_, 1)
		_aShared_ = StzEngineListContentToRingList(_pR_)
		StzEngineListFree(_pR_)
		StzEngineListFree(_pB_)
		StzEngineListFree(_pA_)

		return new stzSetOfSections(_aShared_)

		def Intersection(paOtherSetOfSections)
			return This.IntersectionWith(paOtherSetOfSections)
