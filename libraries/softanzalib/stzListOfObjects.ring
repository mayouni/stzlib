
// TODO

func StzListOfObjectsQ()
	return new stzListOfObjects

class stzObjects from stzListOfObjects

class stzListOfObjects from stzList
	@aContent = []

	def init(paoObjects)
		if isList(paoObjects) and Q(paoObjects).IsListOfObjects()
			@aContent = paoObjects

		else
			StzRaise("Incorrect param type! paoObjects must be a list of objects.")
		ok

	def Content()
		@aContent

	def Copy()
		return new stzListOfObjects( This.Content() )
