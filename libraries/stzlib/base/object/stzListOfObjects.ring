func StzListOfObjectsQ()
	return new stzListOfObjects

# Is another name of stzListOfObjects: a list whose every item is an object, with every method of it.
#
# The class adds nothing: it is built, read and copied exactly as a stzListOfObjects, and Copy
# answers a stzListOfObjects.
#
#   receiver   o1 = new stzObjects([ new stzString("ab"), new stzString("cd") ])
#   example    ? len(o1.Content())
#              #--> 2
#   see        stzListOfObjects
class stzObjects from stzListOfObjects

# Holds a list whose every item is an object of any class, and hands the list back whole.
#
# Reach for it when a list of objects must travel as one value that was checked once: a library
# class and a class of your own may sit side by side. The holder keeps its own objects. Ring copies
# an object when it is assigned, so the list given to init is copied in, and a list taken from
# Content or Copy into a variable holds copies: a change made to one of those objects, or to the
# caller's own list or objects afterwards, does not reach the holder. The one form that does is a
# call chained on an element of the answer, o.Content()[1].Rename("x"), which acts on the holder's
# own object. The empty list is a valid holder. The other methods are those of stzList.
#
#   receiver   o1 = new stzListOfObjects([ new stzString("ab"), new stzString("cd") ])
#   example    ? len(o1.Content())
#              #--> 2
#              ? o1.Copy().Content()[2].Content()
#              #--> cd
#   see        stzListOfNamedObjects, stzObjects, stzList
class stzListOfObjects from stzList
	@aContent = []

	# Builds the holder from a list whose every item is an object, and raises an error for anything else.
	#
	#   paoObjects   the list of objects to hold, of any classes; the empty list is accepted
	#   returns      nothing; the holder is built
	#   note         a list holding one item that is not an object (a number, a text, a list, an
	#                empty list) is refused, and so is a value that is not a list; the holder keeps
	#                copies, so changing the caller's list afterwards leaves it alone; new
	#                stzListOfObjects without parentheses skips this method and builds an empty
	#                holder, which is what StzListOfObjectsQ() returns
	#   see          Content, Copy
	def init(paoObjects)
		if isList(paoObjects) and IsListOfObjects(paoObjects)
			@aContent = paoObjects

		else
			StzRaise("Incorrect param type! paoObjects must be a list of objects.")
		ok

	# Returns the held objects as a plain Ring list, which a variable takes as copies of them.
	#
	#   returns    a list of objects, empty for an empty holder
	#   note       Ring copies an object when it is assigned: a list taken into a variable holds
	#              copies, so renaming one of them or growing the list leaves the holder as it was;
	#              the one exception is a call chained on an element of the answer, as in
	#              o.Content()[1].Rename("x"), which acts on the holder's own object
	#   see        init, Copy
	def Content()
		return @aContent

	# Returns a new holder of the same objects, which changing leaves this one alone.
	#
	#   returns    a stzListOfObjects
	#   note       the copy holds its own copies of the objects; a copy of a stzObjects is a
	#              stzListOfObjects
	#   see        Content, init
	def Copy()
		return new stzListOfObjects( This.Content() )
