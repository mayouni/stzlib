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

	if NOT @BothAreNumbers(n1, n2)
		StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
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

	if NOT @BothAreNumbers(n1, n2)
		StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
	ok

	nResult = GCD(n1, n2) # A Ring function
	return nResult

	#< @FunctionAlternativeForm

	func CommonGreatestDividor(n1, n2)
		return This.GreatestCommonDividor(n1, n2)

	#>

#-- SpeedUp and PerfGain
#-- Inspired by a discussion with Mahmoud on the google group

func SpeedUp(n1, n2)
	if CheckParams()
		if isList(n1) and StzListQ(n1).IsFromOrBetweenNamedParam()
			n1 = n1[2]
		ok

		if isList(n2) and StzListQ(n2).IsToOrAndNamedParam()
			n2 = n2[2]
		ok
	ok

	return StzPairOfNumbersQ([ n1, n2 ]).SpeedUp()

	func SpeedUpX(n1, n2) # X ~> ouput is a factor
		return SpeedUp(n1, n2)

	func PerfGainX(n1, n2)
		return SpeedUp(n1, n2)

func GainFactor(n1, n2)
	return StzPairOfNumbersQ([ n1, n2 ]).GainFactor()

	func GainX(n1, n2)
		return GainFactor(n1, n2)

func PerfGain(n1, n2)
	return StzPairOfNumbersQ([ n1, n2 ]).PerfGain()

	func PerfGain100(n1, n2) # 100 ~> Output is a percentage
		return PerfGain(n1, n2)

func RelativeGain(n1, n2)
	return StzPairOfNumbersQ([ n1, n2 ]).RelativeGain()

	func Gain100(n1, n2)
		return RelativeGain(n1, n2)

	func Gain(n1, n2)
		return RelativeGain(n1, n2)

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

		def Value()
			return Content()

	def FirstNumber()
		return This.Content()[1]

	def SecondNumber()
		return This.Content()[2]

	def BothAreBetween(n1, n2)

		if NOT Q([n1, n2]).BothAreNumbers()
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		if QR(This.FirstNumber(), :stzNumber).IsBetween(n1, n2) and
		   QR(This.SecondNumber(), :stzNumber).IsBetween(n1, n2)

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

	  #--------------------------------------#
	 #  GETTING THE SPEEDUP OF THE NUMBERS  #
	#======================================#

	def SpeedUp()
		anNumbers = This.Content()

		n1 = anNumbers[1]
		n2 = anNumbers[2]

		nResult = n1 / n2

		return nResult

		def SpeedUpX()
			return This.SpeedUp()

	  #-------------------------------------------------#
	 #  GETTING THE GAIN FACTOR FROM NUMBER TO NUMBER  #
	#-------------------------------------------------#

	def GainFactor()
		anNumbers = This.Content()

		n1 = anNumbers[1]
		n2 = anNumbers[2]

		nResult = n2 / n1

		return nResult
	
		def GainX()
			return This.GainFactor()
	
		def PerfGainX()
			return This.GainFactor()

	  #-----------------------------------------#
	 #  GETTING THE PERFGAIN FROM THE NUMBERS  #
	#=========================================#

	def PerfGain() # In percentage
		anNumbers = This.Content()

		n1 = anNumbers[1]
		n2 = anNumbers[2]

		nResult = ( (n1 - n2) / n1) * 100

		return nResult

		def PerfGain100()
			return This.PerfGain()

	  #---------------------------------------------------------#
	 #   GETTING THE GAIN IN PERCENTAGE FROM NUMBER TO NUMBER  #
	#---------------------------------------------------------#

	def Gain()
		anNumbers = This.Content()

		n1 = anNumbers[1]
		n2 = anNumbers[2]

		nResult = ( (n2 - n1) / n2) * 100

		return nResult

		def RelativeGain()
			return This.Gain()
	
		def Gain100()
			return This.Gain()
