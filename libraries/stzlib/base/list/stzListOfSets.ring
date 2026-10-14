
func StzListOfSetsQ(paList)
	return new stzListOfSets(paList)

class stzSets from stzListOfSets

# Holds a list of sets, each a list without repeated items; it builds only from an empty list today.
#
# Its init checks the argument with a method named IsListOfSets that stzList does not have (only the
# global function of that name exists), so new stzListOfSets(aList) raises error R14 for every non-
# empty list, and a value that is not a list raises R3 because the error text function is missing.
# Only an empty list builds. For one set use stzSet; for plain lists of lists use stzListOfLists.
#
#   receiver   o1 = new stzListOfSets([ ])
#   example    ? o1.NumberOfItems()
#              #--> 0
#              ? @@( o1.Sets() )
#              #--> [ ]
#   see        stzSet, stzListOfLists
class stzListOfSets from stzListOfLists
	@aContent

	# Builds a list of sets from a list whose items are sets, with no repeated item inside any one.
	#
	#   paList     a list whose items are sets, lists with no repeated item, or [ ]
	#   returns    nothing; only an empty list builds today
	#   warning    Raises error R14 "Calling Method without definition: islistofsets" today for
	#              every non-empty list, valid or not, instead of building the object: the check is
	#              written as a method of stzList that does not exist (only the global IsListOfSets
	#              does); a value that is not a list raises R3 (stzListOfSetsError is not defined);
	#              only [ ] builds
	#   see        Content
	def init(paList)

		if isList(paList) and
		   ( Q(paList).IsEmpty() or Q(paList).IsListOfSets() )

			@aContent = paList

		else
			StzRaise(stzListOfSetsError(:CanNotCreateListOfSets))
		ok

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	# Returns the sets the object holds, as they were given.
	#
	#   returns    a list of lists
	#   note       reachable only for an empty list today, because init fails on the others
	#   see        Value, Sets
	def Content()
		return @aContent

		# Returns the sets the object holds, the same answer as Content.
		#
		#   returns    a list of lists
		#   see        Content
		def Value()
			return Content()

	# Returns a new stzListOfSets holding the same sets.
	#
	#   returns    a new stzListOfSets
	#   see        Content
	def Copy()
		return new stzListOfSets( This.Content() )

	# Returns the sets the object holds, the same answer as Content.
	#
	#   returns    a list of lists
	#   see        Content
	def Sets()
		return Content()
