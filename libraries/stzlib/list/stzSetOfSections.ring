#TODO add a stzSetOfSectionsTest.ring file

func IsSetOfSections(paSections)
	if NOT isList(paSections)
		return FALSE
	ok

	if NOT IsSet(paSections)
		return FALSE
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

	def Content()
		return @aContent

	def Copy()
		return This

	def Update(paNewSections)
		if isList(paNewSections) and StzListQ(paSections).IsWithNamedParam()
			paNewSections = paNewSections[2]
		ok

		@aContent = paNewSections

		def UpdateWith(paNewSections)
			This.Update(paNewSections)

	def IntersectionWith(paOtherSetOfSections)
		StzRaise("Feature not implemented yet!")

		def Intersection(paOtherSetOfSections)
			return This.IntersectionWith(paOtherSetOfSections)
