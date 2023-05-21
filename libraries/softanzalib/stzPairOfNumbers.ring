/*
	TODO: complete the class
	TODO: add stzPairOfStrings, stzPairOfLists and stzPairOfObjects classes
*/


func StzPairOfNumbersQ(paPair)
	return new stzPairOfNumbers(paPair)

func LeastCommonMuliple( n1, n2 )
	# EXAMPLE
	# ? LastCommonMuliplier( :Of = 25, :And = 42 )

	if isList(n1) and Q(n1).IsOfNamedParam()
		n1 = n1[2]
	ok

	if isList(n2) and Q(n2).IsAndNamedParam()
		n2 = n2[2]
	ok

	if NOT BothAreNumbers(n1, n2)
		StzRaise("Uncorrect param type! n1 and n2 must both be numbers.")
	ok

	nResult = LCM(n1, n2) # A Ring function
	return nResult

	#< @FunctionAlternativeForm

	func CommonLeastMultiple(n1, n2)
		return This.LastCommonMuliple(n1, n2)

	#>

func GreatestCommonDividor( n1, n2 )

	if isList(n1) and Q(n1).IsOfNamedParam()
		n1 = n1[2]
	ok

	if isList(n2) and Q(n2).IsAndNamedParam()
		n2 = n2[2]
	ok

	if NOT BothAreNumbers(n1, n2)
		StzRaise("Uncorrect param type! n1 and n2 must both be numbers.")
	ok

	nResult = GCD(n1, n2) # A Ring function
	return nResult

	#< @FunctionAlternativeForm

	func CommonGreatestDividor(n1, n2)
		return This.GreatestCommonDividor(n1, n2)

	#>

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

	  #---------------------------------------------------------------#
	 #   CALCULATIONG THE LEAST COMMON MULTIPLE OF THE TWO NUMBERS   #
	#---------------------------------------------------------------#

	def LeastCommonMuliple()
		nResult = LCM( This.FirstNumber(), This.SecondNumber() ) # A Ring function
		return nResult
			
		#< @FunctionAlternativeForms

		def CommonLeastMultiplier()
			return This.LeastCommonMuliplier()

		#>

	  #-----------------------------------------------------------------#
	 #   CALCULATIONG THE GREATEST COMMON DIVIDOR OF THE TWO NUMBERS   #
	#-----------------------------------------------------------------#

	def GreatestCommonDividor()
		nResult = GCD( This.FirstNumber(), This.SecondNumber() ) # A Ring function
		return nResult
			
		#< @FunctionAlternativeForms

		def CommonGreatestDividor()
			return This.GreatestCommonDividor()

		#>
