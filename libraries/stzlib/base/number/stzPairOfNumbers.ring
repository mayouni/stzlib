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
