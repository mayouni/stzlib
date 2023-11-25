
// TODO

func StzListOfObjectsQ()
	return new stzListOfObjects

class stzListOfObjects from stzList
	@aContent = []

	def init(paObjects)
		if isList(paObjects) and Q(paObjects).IsListOfObjects()
			@aContent = paObjects

		else
			StzRaise("Incorrect param type! paObjects must be a list of objects.")
		ok

	def Content()
		@aContent

	def Copy()
		return new stzListOfObjects( This.Content() )
