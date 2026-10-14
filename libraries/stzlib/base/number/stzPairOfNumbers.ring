/*
	TODO: complete the class
	TODO: add stzPairOfStrings, stzPairOfLists and stzPairOfObjects classes
*/


func StzPairOfNumbersQ(paPair)
	return new stzPairOfNumbers(paPair)

func LeastCommonMuliple( _n1_, _n2_ )
	# EXAMPLE
	# ? LastCommonMuliplier( :Of = 25, :And = 42 )

	if isList(_n1_) and Q(_n1_).IsOfNamedParam()
		_n1_ = _n1_[2]
	ok

	if isList(_n2_) and Q(_n2_).IsAndNamedParam()
		_n2_ = _n2_[2]
	ok

	if NOT @BothAreNumbers(_n1_, _n2_)
		StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
	ok

	_nResult_ = LCM(_n1_, _n2_) # A Ring function
	return _nResult_

	#< @FunctionAlternativeForm

	func CommonLeastMultiple(_n1_, _n2_)
		return This.LastCommonMuliple(_n1_, _n2_)

	#>

func GreatestCommonDividor( _n1_, _n2_ )

	if isList(_n1_) and Q(_n1_).IsOfNamedParam()
		_n1_ = _n1_[2]
	ok

	if isList(_n2_) and Q(_n2_).IsAndNamedParam()
		_n2_ = _n2_[2]
	ok

	if NOT @BothAreNumbers(_n1_, _n2_)
		StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
	ok

	_nResult_ = GCD(_n1_, _n2_) # A Ring function
	return _nResult_

	#< @FunctionAlternativeForm

	func CommonGreatestDividor(_n1_, _n2_)
		return GreatestCommonDividor(_n1_, _n2_)

	func CommonDividor(_n1_, _n2_)
		return GreatestCommonDividor(_n1_, _n2_)

	#>

#-- SpeedUp and PerfGain
#-- Inspired by a discussion with Mahmoud on the google group

func SpeedUp(_n1_, _n2_)
	if CheckingParams()
		if isList(_n1_) and IsFromOrBetweenNamedParamList(_n1_)
			_n1_ = _n1_[2]
		ok

		if isList(_n2_) and IsToOrAndNamedParamList(_n2_)
			_n2_ = _n2_[2]
		ok
	ok

	return StzPairOfNumbersQ([ _n1_, _n2_ ]).SpeedUp()

	func SpeedUpX(_n1_, _n2_) # X ~> ouput is a factor
		return SpeedUp(_n1_, _n2_)

	func SpeedX(_n1_, _n2_)
		return SpeedUp(_n1_, _n2_)

	func SpeedFactor(_n1_, _n2_)
		return SpeedUp(_n1_, _n2_)

	func PerfGainX(_n1_, _n2_)
		return SpeedUp(_n1_, _n2_)

func GainFactor(_n1_, _n2_)
	return StzPairOfNumbersQ([ _n1_, _n2_ ]).GainFactor()

	func GainX(_n1_, _n2_)
		return GainFactor(_n1_, _n2_)

func PerfGain(_n1_, _n2_)
	return StzPairOfNumbersQ([ _n1_, _n2_ ]).PerfGain()

	func PerfGain100(_n1_, _n2_) # 100 ~> Output is a percentage
		return PerfGain(_n1_, _n2_)

func RelativeGain(_n1_, _n2_)
	return StzPairOfNumbersQ([ _n1_, _n2_ ]).RelativeGain()

	func Gain100(_n1_, _n2_)
		return RelativeGain(_n1_, _n2_)

	func Gain(_n1_, _n2_)
		return RelativeGain(_n1_, _n2_)

# Holds two numbers and compares them: least common multiple, greatest common divisor, speed-up factor and percentage gain.
#
# Build one with new stzPairOfNumbers([ a, b ]) or StzPairOfNumbersQ([ a, b ]); it is a stzPair, so
# Item1, Item2, Swap and the rest of the pair vocabulary are inherited. The measures are written for
# a before and an after, such as two timings: SpeedUp is a divided by b, GainFactor is b divided by
# a, PerfGain is the drop as a percentage of a, Gain is the rise as a percentage of b. Global
# functions of the same names (SpeedUp, PerfGain, GainFactor, RelativeGain, LeastCommonMuliple,
# GreatestCommonDividor) take the two numbers directly. BothAreBetween has a defect with a large
# first number.
#
#   receiver   o1 = new stzPairOfNumbers([ 12, 18 ])
#   example    ? o1.GreatestCommonDividor()
#              #--> 6
#              ? o1.LeastCommonMuliple()
#              #--> 36
#              ? o1.PerfGain()
#              #--> -50
#              ? SpeedUp(10, 2)
#              #--> 5
#   see        stzPair, stzNumber
class stzPairOfNumbers from stzPair

	@aContent = []

	# Builds a pair from a list of exactly two numbers.
	#
	#   paPair     a list of two numbers
	#   returns    nothing; the object is built
	#   warning    a list of another length, or holding a non-number, raises "Can't create the
	#              stzPairOfNumbers object. Incorrect param type!"
	#   see        FirstNumber, SecondNumber
	def init(paPair)
		if isList(paPair) and Q(paPair).IsPairOfNumbers()
			@aContent = paPair

		else
			StzRaise("Can't create the stzPairOfNumbers object. Incorrect param type!")
		ok

	# Returns the two numbers as a list.
	#
	#   returns    a list of two numbers
	#   see        Value, FirstNumber
	def Content()
		return @aContent

		def PairOfNumber()
			return This.Content()

		# Returns the two numbers as a list, the same answer as Content.
		#
		#   returns    a list of two numbers
		#   see        Content
		def Value()
			return Content()

	# Returns the first number of the pair.
	#
	#   returns    a number
	#   see        SecondNumber
	def FirstNumber()
		return This.Content()[1]

	# Returns the second number of the pair.
	#
	#   returns    a number
	#   see        FirstNumber
	def SecondNumber()
		return This.Content()[2]

	# TRUE if both numbers of the pair lie between two bounds, the bounds included.
	#
	#   _n1_       the lower bound
	#   _n2_       the upper bound
	#   returns    TRUE or FALSE; but see the warning
	#   note       AreBothBetween is the same method; a bound that is not a number raises an error
	#   warning    The first number is not checked against the upper bound today: [ 20, 12 ] is
	#              reported between 10 and 15, and [ 99, 5 ] between 0 and 10, because the test
	#              reads the second number twice; it is right when the first number is the smaller
	#   see        Content
	def BothAreBetween(_n1_, _n2_)

		if NOT Q([_n1_, _n2_]).BothAreNumbers()
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok

		if ( @aContent[1] >= _n1_ and @aContent[2] <= _n2_ ) and
		   ( @aContent[2] >= _n1_ and @aContent[2] <= _n2_ )

			return 1
		else
			return 0
		ok

		def AreBothBetween(_n1_, _n2_)
			return This.BothAreBetween(_n1_, _n2_)

	  #---------------------------------------------------------------#
	 #   CALCULATIONG THE LEAST COMMON MULTIPLE OF THE TWO NUMBERS   #
	#---------------------------------------------------------------#

	# Returns the smallest number that both numbers divide into, using Ring's LCM.
	#
	#   returns    a number
	#   note       the global function LeastCommonMuliple(4, 6) answers 12 too
	#   warning    CommonLeastMultiplier, the alias, raises R14 today (it calls a method of another
	#              spelling); the name keeps the spelling Muliple
	#   see        GreatestCommonDividor
	def LeastCommonMuliple()
		_nResult_ = LCM( This.FirstNumber(), This.SecondNumber() ) # A Ring function
		return _nResult_
			
		#< @FunctionAlternativeForms

		def CommonLeastMultiplier()
			return This.LeastCommonMuliplier()

		#>

	  #-----------------------------------------------------------------#
	 #   CALCULATIONG THE GREATEST COMMON DIVIDOR OF THE TWO NUMBERS   #
	#-----------------------------------------------------------------#

	# Returns the largest number that divides both numbers, using Ring's GCD.
	#
	#   returns    a number
	#   note       CommonGreatestDividor is the same method; the spelling Dividor is the library's
	#   see        LeastCommonMuliple
	def GreatestCommonDividor()
		_nResult_ = GCD( This.FirstNumber(), This.SecondNumber() ) # A Ring function
		return _nResult_
			
		#< @FunctionAlternativeForms

		def CommonGreatestDividor()
			return This.GreatestCommonDividor()

		#>

	  #--------------------------------------#
	 #  GETTING THE SPEEDUP OF THE NUMBERS  #
	#======================================#

	# Returns how many times faster the first number is than the second, the first divided by the second.
	#
	#   returns    a number
	#   note       for two timings, 10 and 2 seconds give 5; a second number of 0 raises "Can't
	#              divide by zero"; SpeedUpX is the same method
	#   see        GainFactor, PerfGain
	def SpeedUp()
		_anNumbers_ = This.Content()

		_n1_ = _anNumbers_[1]
		_n2_ = _anNumbers_[2]

		_nResult_ = _n1_ / _n2_

		return _nResult_

		def SpeedUpX()
			return This.SpeedUp()

	  #-------------------------------------------------#
	 #  GETTING THE GAIN FACTOR FROM NUMBER TO NUMBER  #
	#-------------------------------------------------#

	# Returns the second number divided by the first, the factor of change from the first to the second.
	#
	#   returns    a number
	#   note       10 then 20 gives 2; a first number of 0 raises "Can't divide by zero"; GainX and
	#              PerfGainX are the same method
	#   see        SpeedUp, Gain
	def GainFactor()
		_anNumbers_ = This.Content()

		_n1_ = _anNumbers_[1]
		_n2_ = _anNumbers_[2]

		_nResult_ = _n2_ / _n1_

		return _nResult_
	
		def GainX()
			return This.GainFactor()
	
		def PerfGainX()
			return This.GainFactor()

	  #-----------------------------------------#
	 #  GETTING THE PERFGAIN FROM THE NUMBERS  #
	#=========================================#

	# Returns the drop from the first number to the second as a percentage of the first.
	#
	#   returns    a number, negative for an increase
	#   note       10 then 2 gives 80 and 12 then 18 gives -50; a first number of 0 raises "Can't
	#              divide by zero"; PerfGain100 is the same method
	#   see        Gain, SpeedUp
	def PerfGain() # In percentage
		_anNumbers_ = This.Content()

		_n1_ = _anNumbers_[1]
		_n2_ = _anNumbers_[2]

		_nResult_ = ( (_n1_ - _n2_) / _n1_) * 100

		return _nResult_

		def PerfGain100()
			return This.PerfGain()

	  #---------------------------------------------------------#
	 #   GETTING THE GAIN IN PERCENTAGE FROM NUMBER TO NUMBER  #
	#---------------------------------------------------------#

	# Returns the rise from the first number to the second as a percentage of the second.
	#
	#   returns    a number, negative for a decrease
	#   note       10 then 20 gives 50, since the divisor is the second number; a second number of 0
	#              raises "Can't divide by zero"; RelativeGain and Gain100 are the same method
	#   see        PerfGain, GainFactor
	def Gain()
		_anNumbers_ = This.Content()

		_n1_ = _anNumbers_[1]
		_n2_ = _anNumbers_[2]

		_nResult_ = ( (_n2_ - _n1_) / _n2_) * 100

		return _nResult_

		def RelativeGain()
			return This.Gain()
	
		def Gain100()
			return This.Gain()
