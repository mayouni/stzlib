
// TODO

func StzListOfObjectsQ()
	return new stzListOfObjects

class stzObjects from stzListOfObjects

class stzListOfObjects from stzList
	@aContent = []

	def init(paoObjects)
		# IsListOfObjects is a global FUNCTION in stzListFunc taking the
		# list. Q(paoObjects) gives a stzList, which has no method of that
		# name -- only stzListChecker does -- so this raised R14 and the
		# class could not be constructed at all.
		if isList(paoObjects) and IsListOfObjects(paoObjects)
			@aContent = paoObjects

		else
			StzRaise("Incorrect param type! paoObjects must be a list of objects.")
		ok

	# Measured on 1.27: a method whose body is a bare expression returns
	# "", not the value and not an error. Without the return, Copy() below
	# handed an empty string to the constructor.
	def Content()
		return @aContent

	def Copy()
		return new stzListOfObjects( This.Content() )
