#TODO add a stzSetOfSectionsTest.ring file

func IsSetOfSections(paSections)
	if NOT isList(paSections)
		return _FALSE_
	ok

	if NOT IsSet(paSections)
		return _FALSE_
	ok

	return StzListQ(paSections).IsListOfSections()

	func @IsSetOfSections(paSections)

func StzSetOfSectionsQ(paSections)
	return new stzSetOfSections(paSections)

class stzSetOfSections from stzListOfSections
	@aContent

	def init(paSections)
		if NOT (isList(paSections) and @IsSetOfSections(paSections) )
			StzRaise("Can't create the stzSetOfSections object. You must provide a list of sections.")
		ok

		@aContent = paSections

		if KeepingHistory() = _TRUE_
			This.AddHistoricValue(This.Content())
		ok

	def Content()
		return @aContent

	def Copy()
		return This

	def Update(paNewSections)

		if CheckingParam()
			if isList(paNewSections) and StzListQ(paSections).IsWithNamedParam()
				paNewSections = paNewSections[2]
			ok

			if NOT @IsListOfPairsOfNumbers(paNewSections)
				StzRaise("Incorrect param type! paNewSections must be a list of pairs of numbers.")
			ok
		ok

		@aContent = paNewSections

		if KeepingHisto() = _TRUE_
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		def UpdateWith(paNewSections)
			This.Update(paNewSections)

	def IntersectionWith(paOtherSetOfSections)
		StzRaise("Feature not implemented yet!")

		def Intersection(paOtherSetOfSections)
			return This.IntersectionWith(paOtherSetOfSections)
