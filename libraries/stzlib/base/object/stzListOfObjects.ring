
// TODO

func StzListOfObjectsQ()
	return new stzListOfObjects

class stzObjects from stzListOfObjects

# Is meant to hold a list of objects as a list of its own; it can not be built with a list today.
#
# Building it with a list of objects raises R14, because init calls IsListOfObjects on a stzList and
# that method does not exist; Content returns nothing; and Copy raises. Only the holder built
# without parentheses, as StzListOfObjectsQ() does, can be made, and it is empty. The class is a
# sketch whose file begins with a TODO. stzObjects is another name of it.
#
#   receiver   o1 = StzListOfObjectsQ()
#   example    ? classname(o1)
#              #--> stzlistofobjects
#              ? isString(o1.Content())
#              #--> 1
#   see        stzListOfNamedObjects, stzObjects, stzList
class stzListOfObjects from stzList
	@aContent = []

	# Raises error R14 today instead of building a list of objects from the given list.
	#
	#   paoObjects   the list of objects meant to be held
	#   returns      nothing; it raises
	#   note         new stzListOfObjects without parentheses skips init and builds an empty holder,
	#                which is what StzListOfObjectsQ() returns
	#   warning      the type check calls IsListOfObjects on a stzList, a method that does not
	#                exist, so every list raises R14 Calling Method without definition:
	#                islistofobjects (tried with one object and with two); a value that is not a
	#                list raises Incorrect param type
	#   see          Content, Copy
	def init(paoObjects)
		if isList(paoObjects) and Q(paoObjects).IsListOfObjects()
			@aContent = paoObjects

		else
			StzRaise("Incorrect param type! paoObjects must be a list of objects.")
		ok

	# Returns an empty text today instead of the list of objects, because the method names the list and does not return it.
	#
	#   returns    an empty text
	#   warning    the body is the bare name @aContent with no return, so the list is never handed
	#              back, even for a holder built without init
	#   see        init, Copy
	def Content()
		@aContent

	# Raises error today instead of returning a copy of the list: it calls Content, which returns nothing, and init then refuses it.
	#
	#   returns    nothing; it raises
	#   warning    raises Incorrect param type! paoObjects must be a list of objects
	#   see        Content, init
	def Copy()
		return new stzListOfObjects( This.Content() )
