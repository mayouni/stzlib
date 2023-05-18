/*
	TODO: complete the class
	TODO: add stzPairOfStrings, stzPairOfLists and stzPairOfObjects classes
*/

func StzPairOfNumbersQ(paPair)
	return new stzPairOfNumbers(paPair)

class stzPairOfNumbers from stzPair

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

	def BothAreBetween(n1, n2)

		if NOT Q([n1, n2]).BothAreNumbers()
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		if QR(n1, :stzNumber).IsBetween(n1, n2) and
		   QR(n2, :stzNumber).IsBetween(n1, n2)

			return TRUE
		else
			return FALSE
		ok

		def AreBothBetween(n1, n2)
			return This.BothAreBetween(n1, n2)
