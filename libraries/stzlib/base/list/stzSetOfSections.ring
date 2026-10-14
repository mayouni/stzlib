#TODO add a stzSetOfSectionsTest.ring file

func IsSetOfSections(paSections)
	if NOT isList(paSections)
		return 0
	ok

	if NOT IsSet(paSections)
		return 0
	ok

	return StzListQ(paSections).IsListOfSections()

	func @IsSetOfSections(paSections)

func StzSetOfSectionsQ(paSections)
	return new stzSetOfSections(paSections)

# Holds a set of sections, [ start, end ] pairs of positions without a repeated pair; no object can be built today.
#
# Build one with new stzSetOfSections(aSections) or StzSetOfSectionsQ(aSections). Today every
# creation raises "Can't create the stzSetOfSections object": the validity check calls
# @IsSetOfSections, a function with an empty body, and the working IsSetOfSections fails in turn
# because stzList has no IsListOfSections method (the global function of that name exists). The
# methods below are therefore documented from their code and not run. For sections that already work
# see stzSection and stzListSections; for lists of sections, stzListOfSections.
#
#   receiver   o1 = new stzSection(2, 5, 10)
#   example    ? @@( o1.Content() )
#              #--> [ 2, 5 ]
#              ? IsListOfSections([ [ 1, 3 ], [ 5, 7 ] ])
#              #--> 1
#   see        stzSection, stzListOfSections, stzListSections
class stzSetOfSections from stzListOfSections
	@aContent

	# Raises error "Can't create the stzSetOfSections object" today for every argument instead of building a set of sections.
	#
	#   paSections   a list of [ start, end ] pairs of numbers, with no repeated pair
	#   returns      nothing: no object can be built
	#   warning      Refuses [ [1,3], [5,7] ] and every other list: the check calls
	#                @IsSetOfSections, a function whose body is empty, so it answers an empty text
	#                and the creation is always refused; the working global IsSetOfSections itself
	#                fails with R14 (stzList has no IsListOfSections method)
	#   see          Content
	def init(paSections)
		if NOT (isList(paSections) and @IsSetOfSections(paSections) )
			StzRaise("Can't create the stzSetOfSections object. You must provide a list of sections.")
		ok

		@aContent = paSections

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	# Returns the sections the set holds, as a list of [ start, end ] pairs.
	#
	#   returns    a list of pairs; not reachable today, since init never succeeds
	#   warning    Not run, because no object can be built; read from the code
	#   see        Copy
	def Content()
		return @aContent

	# Returns this same object, not an independent copy.
	#
	#   returns    the object itself; not reachable today, since init never succeeds
	#   warning    Not run, because no object can be built; read from the code, it answers This, so
	#              a change made to the "copy" changes the original
	#   see        Content
	def Copy()
		return This

	# Replaces the sections of the set by another list of pairs of numbers.
	#
	#   paNewSections   the new sections, a list of [ start, end ] pairs, or a named [ :With, list ]
	#   returns         nothing; not reachable today, since init never succeeds
	#   warning         Not run, because no object can be built; read from the code, the parameter
	#                   check spells CheckingParam and refers to a variable paSections that does not
	#                   exist, and a later line calls KeepingHisto, so it would fail on the first
	#                   call that reaches them
	#   see             UpdateWith
	def Update(paNewSections)

		if CheckingParam()
			if isList(paNewSections) and IsWithNamedParamList(paSections)
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

		# Replaces the sections of the set by another list of pairs of numbers, the same as Update.
		#
		#   paNewSections   the new sections, a list of [ start, end ] pairs
		#   returns         nothing; not reachable today, since init never succeeds
		#   warning         Not run, because no object can be built; it calls Update, see its
		#                   warning
		#   see             Update
		def UpdateWith(paNewSections)
			This.Update(paNewSections)

	# Raises the error "Feature not implemented yet!" today instead of the sections shared with another set.
	#
	#   paOtherSetOfSections   the other set of sections
	#   returns                nothing: it always raises
	#   warning                Not run on an object, since none can be built; read from the code,
	#                          the body is only a StzRaise call, and Intersection forwards to it
	def IntersectionWith(paOtherSetOfSections)
		StzRaise("Feature not implemented yet!")

		def Intersection(paOtherSetOfSections)
			return This.IntersectionWith(paOtherSetOfSections)
