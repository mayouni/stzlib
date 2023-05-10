/*
	TODO: complete the class
	TODO: add stzPairOfStrings, stzPairOfLists and stzPairOfObjects classes
*/

func StzPairOfNumbersQ(paPair)
	return new stzPairOfNumbers(paPair)

class stzPairOfNumbers from stzPair
	// TODO

	@aContent = []

	def init(paPair)
		if isList(paPair) and Q(paPair).IsPairOfNumbers()
			@aContent = paPair

		else
			StzRaise("Can't create the stzPairOfNumbers object. Incorrect param type!")
		ok

	def Content()
		return @aContent

		def PairOfNumber()
			return This.Content()

	def FirstNumber()
		return This.Content()[1]

	def SecondNumber()
		return This.Content()[2]
