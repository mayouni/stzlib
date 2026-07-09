#---------------------------------------------------------------#
# 		    SOFTANZA LIBRARY (V0.9) - StzListOfNumbers  #
#		An accelerative library for Ring applications   #
#---------------------------------------------------------------#
#                                                               #
#   Description	: The class for managing lists of numbers       #
#   Version	: V0.9 (2020-2024)                              #
#   Author	: Mansour Ayouni (kalidianow@gmail.com)         #
#                                                               #
#---------------------------------------------------------------#

/*
Short term objective:
	Max() Min() Mean() Sum()
	
	Correlation()
	Covariance()
	AverageDeviation()
	StandardDeviation()
	StandardDeviationP()
	StatError()
	Variance()
	VarianceP()

Long terme objective:
Support all the features of NumPy
	Array Creation:
	arange, array, copy, empty, empty_like, eye, fromfile, fromfunction, identity, linspace, logspace, mgrid, ogrid, ones, ones_like, r_, zeros, zeros_like
	
	Conversions:
	ndarray.astype, atleast_1d, atleast_2d, atleast_3d, mat
	
	Manipulations:
	array_split, column_stack, concatenate, diagonal, dsplit, dstack, hsplit, hstack, ndarray.item, newaxis, ravel, repeat, reshape, resize, squeeze, swapaxes, take, transpose, vsplit, vstack
	
	Questions:
	all, any, nonzero, where
	
	Ordering:
	argmax, argmin, argsort, max, min, ptp, searchsorted, sort
	
	Operations:
	choose, compress, cumprod, cumsum, inner, ndarray.fill, imag, prod, put, putmask, real, sum
	
	Basic Statistics:
	cov, mean, std, var
	
	Basic Linear Algebra:
	cross, dot, outer, linalg.svd, vdot
*/

  ///////////////////
 ///  FUNCTIONS  ///
///////////////////

func StzListOfNumbersQ(paListOfNumbers)
	return new stzListOfNumbers(paListOfNumbers)

	func StzNumbersQ(paListOfNumbers)
		return StzListOfNumbersQ(paListOfNumbers)

func IsListOfPositiveNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	_nLen_ = len(paList)

	for i = 1 to _nLen_
		if not (isNumber(paList[i]) and paList[i] >= 0)
			return 0
		ok
	next

	return 1

func IsListOfNegativeNumbers(paList)
	if NOT isList(paList)
		return 0
	ok

	_nLen_ = len(paList)

	for i = 1 to _nLen_
		if not (isNumber(paList[i]) and paList[i] <= 0)
			return 0
		ok
	next

	return 1

func NumbersUnicodes(_anNumbers_)
	return StzListOfNumbersQ(_anNumbers_).Unicodes()

def HaveSameDifference(_anNumbers_)
    	if NOT (isList(_anNumbers_) and IsListOfNumbers(_anNumbers_))
		return FALSE
	ok

	_nLen_ = len(_anNumbers_)

	# A list with fewer than 3 elements doesn't have enough information
	# to determine a true pattern of constant difference

	if _nLen_ < 3
		return 0
	ok

	_nDiff_ = _anNumbers_[2] - _anNumbers_[1]

	for i = 2 to _nLen_ -1 
		if _anNumbers_[i+1] - _anNumbers_[i] != _nDiff_
			return 0
		ok
	next

	return 1

	func @HaveSameDifference(_anNumbers_)
		return HaveSameDifference(_anNumbers_)


func AreNonZeroNumbers(_anNumbers_)
	if NOT isList(_anNumbers_)
		return FALSE
	ok

	_nLen_ = len(_anNumbers_)

	for i = 1 to _nLen_
		if NOT (isNumber(_anNumbers_[i]) and _anNumbers_[i] != 0)
			return FALSE
		ok
	next
	
	return TRUE

	func AreNonNullNumbers(_anNumbers_)
		return AreNonZeroNumbers(_anNumbers_)

	func @AreNonZeroNumbers(_anNumbers_)
		return AreNonZeroNumbers(_anNumbers_)

	func @AreNonNullNumbers(_anNumbers_)
		return AreNonZeroNumbers(_anNumbers_)

func MinOf(panNumbers)
	return Min(panNumbers) # Defined in SoftanzaCore

	func @MinOf(panNumbers)
		return Min(panNumbers)

	func MinIn(panNumbers)
		return Min(panNumbers)

	func @MinIn(panNumbers)
		return Min(panNumbers)

func MaxOf(panNumbers)
	return Max(panNumbers) # Defined in SoftanzaCore

	func @MaxOf(panNumbers)
		return Max(panNumbers)

	func MaxIn(panNumbers)
		return Max(panNumbers)

	func @MaxIn(panNumbers)
		return Max(panNumbers)

func FindMaxIn(panNumbers)
	return FindMax(panNumbers) # Defined in SoftanzaCore

#--

func Median(panNumbers)

	if CheckParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers must be a lis tof numbers.")
		ok
	ok

	_anValuesSorted_ = @sort(panNumbers)
	_nLen_ = len(_anValuesSorted_)
	
	if _nLen_ % 2 = 1
		return _anValuesSorted_[ring_ceil(_nLen_/2)]
	else
		return (_anValuesSorted_[_nLen_/2] + _anValuesSorted_[(_nLen_/2)+1]) / 2
	ok


func Sum(panNumbers)
	if CheckingParams()
		if isList(panNumbers) and Q(panNumbers).IsOfNamedParam()
			panNumbers = panNumbers[2]
		ok

		if NOT (isList(panNumbers) and Q(panNumbers).IsListOfNumbers())
			StzRaise("Incorrect param! panNumbers must be a list of numbers!")
		ok
	ok

	if len(panNumbers) = 0
		return 0
	ok

	_nResult_ = 0
	_nLen_ = len(panNumbers)
	for i = 1 to _nLen_
		_nResult_ += panNumbers[i]
	next

	return _nResult_

	func @Sum(panNumbers)
		return Sum(panNumbers)

	func SumOf(panNumbers)
		return Sum(panNumbers)

	func @SumOf(panNumbers)
		return Sum(panNumbers)

func Substruct(panNumbers)
	if CheckingParams()
		if isList(panNumbers) and Q(panNumbers).IsOfNamedParam()
			panNumbers = panNumbers[2]
		ok

		if NOT (isList(panNumbers) and Q(panNumbers).IsListOfNumbers())
			StzRaise("Incorrect param! panNumbers must be a list of numbers!")
		ok
	ok

	_nLen_ = len(panNumbers)
	_nResult_ = panNumbers[1]
	
	for i = 2 to _nLen_
		_nResult_ = _nResult_ - panNumbers[i]
	next

	return _nResult_

	func @Substruct(panNumbers)
		return Substruct(panNumbers)

	func SubstructionOf(panNumbers)
		return Substruct(panNumbers)

	func @SubstructionOf(panNumbers)
		return Substruct(panNumbers)

func StzMul(_n1_, _n2_) # Used as ExternalCode
	return _n1_ * _n2_

	func mul(_n1_, _n2_)
		return StzMul(_n1_, _n2_)

func Product(panNumbers)
	if CheckingParams()
		if isList(panNumbers) and Q(panNumbers).IsOfNamedParam()
			panNumbers = panNumbers[2]
		ok

		if NOT (isList(panNumbers) and Q(panNumbers).IsListOfNumbers())
			StzRaise("Incorrect param! panNumbers must be a list of numbers!")
		ok
	ok

	if len(panNumbers) = 0
		return 0
	ok

	_nResult_ = 1
	_nLen_ = len(panNumbers)
	for i = 1 to _nLen_
		_nResult_ *= panNumbers[i]
	next

	return _nResult_

	#< @FunctionAlternativeForms

	func @Product(panNumbers)
		return Product(panNumbers)

	func Multiply(panNumbers)
		return Product(panNumbers)

	func @Multiply(panNumbers)
		return Product(panNumbers)

	func Multiplication(panNumbers)
		return Product(panNumbers)

	func @Multiplication(panNumbers)
		return Product(panNumbers)

	#--

	def ProductOf(panNumbers)
		return Product(panNumbers)

	func @ProductOf(panNumbers)
		return Product(panNumbers)

	func MultiplicationOf(panNumbers)
		return Product(panNumbers)

	func @MultiplicationOf(panNumbers)
		return Product(panNumbers)

	#>

func Divide(panNumbers)
	if CheckingParams()
		if isList(panNumbers) and Q(panNumbers).IsOfNamedParam()
			panNumbers = panNumbers[2]
		ok

		if NOT (isList(panNumbers) and Q(panNumbers).IsListOfNumbers())
			StzRaise("Incorrect param! panNumbers must be a list of numbers!")
		ok
	ok

	if len(panNumbers) = 0
		return 0
	ok

	_nLen_ = len(panNumbers)
	_nResult_ = panNumbers[1]
	
	for i = 2 to _nLen_
		_nResult_ = _nResult_ / panNumbers[i]
	next

	return _nResult_

	#< @FunctionAlternativeForms

	func @Divide(panNumbers)
		return Divide(panNumbers)

	func Division(panNumbers)
		return Divide(panNumbers)

	func @Division(panNumbers)
		return Divide(panNumbers)

	func DivisionOf(panNumbers)
		return Divide(panNumbers)

	func @DivisionOf(panNumbers)
		return Divide(panNumbers)

	#>

#--- Multiple claculations, cumulated

func SumXT(panNumbers)
	if CheckingParams()
		if isList(panNumbers) and Q(panNumbers).IsOfNamedParam()
			panNumbers = panNumbers[2]
		ok

		if NOT (isList(panNumbers) and Q(panNumbers).IsListOfNumbers())
			StzRaise("Incorrect param! panNumbers must be a list of numbers!")
		ok
	ok

	if len(panNumbers) = 0
		return 0
	ok

	_anResult_ = []
	_nSum_ = 0
	_nLen_ = len(panNumbers)
	for i = 1 to _nLen_
		_nSum_ += panNumbers[i]
		_anResult_ + _nSum_
	next

	return _anResult_

	#< @FunctionAlternativeForms

	func SumAndCumulate(panNumbers)
		return SumXT(panNumbers)

	func SumCumulated(panNumbers)
		return SumXT(panNumbers)

	func SumCumul(panNumbers)
		return SumXT(panNumbers)

	func CumulatedSum(panNumbers)
		return SumXT(panNumbers)

	func CumulatedSumOf(panNumbers)
		return SumXT(panNumbers)

	#--

	func @SumXT(panNumbers)
		return SumXT(panNumbers)

	func @SumAndCumulate(panNumbers)
		return SumXT(panNumbers)

	func @SumCumulated(panNumbers)
		return SumXT(panNumbers)

	func @SumCumul(panNumbers)
		return SumXT(panNumbers)

	func @CumulatedSum(panNumbers)
		return SumXT(panNumbers)

	func @CumulatedSumOf(panNumbers)
		return SumXT(panNumbers)

	#>

func SubstructXT(panNumbers)
	if CheckingParams()
		if isList(panNumbers) and Q(panNumbers).IsOfNamedParam()
			panNumbers = panNumbers[2]
		ok

		if NOT (isList(panNumbers) and Q(panNumbers).IsListOfNumbers())
			StzRaise("Incorrect param! panNumbers must be a list of numbers!")
		ok
	ok

	_anResult_ = [] + panNumbers[1]
	_nLen_ = len(panNumbers)
	_nResult_ = panNumbers[1]
	
	for i = 2 to _nLen_
		_nResult_ = _nResult_ - panNumbers[i]
		_anResult_ + _nResult_
	next

	return _anResult_

	#< @FunctionAlternativeForms

	func SubstructAndCumulate(panNumbers)
		return SubstructXT(panNumbers)

	func SubstructCumulated(panNumbers)
		return SubstructXT(panNumbers)

	func SubstructCumul(panNumbers)
		return SubstructXT(panNumbers)

	func CumulatedSubstruct(panNumbers)
		return SumXT(panNumbers)

	func CumulatedSubstructOf(panNumbers)
		return SubstructXT(panNumbers)

	func CumulatedSubstruction(panNumbers)
		return SumXT(panNumbers)

	func CumulatedSubstructionOf(panNumbers)
		return SubstructXT(panNumbers)

	#--

	func @SubstructXT(panNumbers)
		return SubstructXT(panNumbers)

	func @SubstructAndCumulate(panNumbers)
		return SubstructXT(panNumbers)

	func @SubstructCumulated(panNumbers)
		return SubstructXT(panNumbers)

	func @SubstructCumul(panNumbers)
		return SubstructXT(panNumbers)

	func @CumulatedSubstruct(panNumbers)
		return SumXT(panNumbers)

	func @CumulatedSubstructOf(panNumbers)
		return SubstructXT(panNumbers)

	func @CumulatedSubstruction(panNumbers)
		return SumXT(panNumbers)

	func @CumulatedSubstructionOf(panNumbers)
		return SubstructXT(panNumbers)

	#>

func ProductXT(panNumbers)
	if CheckingParams()
		if isList(panNumbers) and Q(panNumbers).IsOfNamedParam()
			panNumbers = panNumbers[2]
		ok

		if NOT (isList(panNumbers) and Q(panNumbers).IsListOfNumbers())
			StzRaise("Incorrect param! panNumbers must be a list of numbers!")
		ok
	ok

	if len(panNumbers) = 0
		return 0
	ok

	_anResult_ = []
	_nProduct_ = 1
	_nLen_ = len(panNumbers)
	for i = 1 to _nLen_
		_nProduct_ *= panNumbers[i]
		_anResult_ + _nProduct_
	next

	return _anResult_

	#< @FunctionAlternativeForms

	def ProductCumulated(panNumbers)
		return ProductXT(panNumbers)

	def ProductCumul(panNumbers)
		return ProductXT(panNumbers)

	def CumulProduct(panNumbers)
		return ProductXT(panNumbers)

	def CumulatedProduct(panNumbers)
		return ProductXT(panNumbers)
	
	def MultiplyXT(panNumbers)
		return ProductXT(panNumbers)

	def MultiplyAndCumulate(panNumbers)
		return ProductXT(panNumbers)

	def MultiplicationXT(panNumbers)
		return ProductXT(panNumbers)

	def CumulatedMultiplicationXT(panNumbers)
		return ProductXT(panNumbers)

	#--

	def ProductCumulOf(panNumbers)
		return ProductXT(panNumbers)

	def CumulProductOf(panNumbers)
		return ProductXT(panNumbers)

	def CumulatedProductOf(panNumbers)
		return ProductXT(panNumbers)

	def MultiplicationOfXT(panNumbers)
		return ProductXT(panNumbers)

	def CumulatedMultiplicationOfXT(panNumbers)
		return ProductXT(panNumbers)

	#==

	def @ProductXT(panNumbers)
		return ProductXT(panNumbers)

	def @ProductCumulated(panNumbers)
		return ProductXT(panNumbers)

	def @ProductCumul(panNumbers)
		return ProductXT(panNumbers)

	def @CumulProduct(panNumbers)
		return ProductXT(panNumbers)

	def @CumulatedProduct(panNumbers)
		return ProductXT(panNumbers)
	
	def @MultiplyXT(panNumbers)
		return ProductXT(panNumbers)

	def @MultiplyAndCumulate(panNumbers)
		return ProductXT(panNumbers)

	def @MultiplicationXT(panNumbers)
		return ProductXT(panNumbers)

	def @CumulatedMultiplicationXT(panNumbers)
		return ProductXT(panNumbers)

	#--

	def @ProductCumulOf(panNumbers)
		return ProductXT(panNumbers)

	def @CumulProductOf(panNumbers)
		return ProductXT(panNumbers)

	def @CumulatedProductOf(panNumbers)
		return ProductXT(panNumbers)

	def @MultiplicationOfXT(panNumbers)
		return ProductXT(panNumbers)

	def @CumulatedMultiplicationOfXT(panNumbers)
		return ProductXT(panNumbers)

	#>


func DivideXT(panNumbers)
	if CheckingParams()
		if isList(panNumbers) and Q(panNumbers).IsOfNamedParam()
			panNumbers = panNumbers[2]
		ok

		if NOT (isList(panNumbers) and Q(panNumbers).IsListOfNumbers())
			StzRaise("Incorrect param! panNumbers must be a list of numbers!")
		ok
	ok

	if len(panNumbers) = 0
		return 0
	ok

	_anResult_ = [] + panNumbers[1]
	_nLen_ = len(panNumbers)
	_nResult_ = panNumbers[1]
	
	for i = 2 to _nLen_
		_nResult_ = _nResult_ / panNumbers[i]
		_anResult_ + _nResult_
	next

	return _anResult_

	#< @FunctionAlternativeForms

	func DivisionXT(panNumbers)
		return DivideXT(panNumbers)

	func DivisionOfXT(panNumbers)
		return DivideXT(panNumbers)

	func DivideAndCumulate(panNumbers)
		return DivideXT(panNumbers)

	func CumulatedDivision(panNumbers)
		return DivideXT(panNumbers)

	func CumulateDivisionOf(panNumbers)
		return DivideXT(panNumbers)

	#==

	func @DivideXT(panNumbers)
		return DivideXT(panNumbers)

	func @DivisionXT(panNumbers)
		return DivideXT(panNumbers)

	func @DivisionOfXT(panNumbers)
		return DivideXT(panNumbers)

	func @DivideAndCumulate(panNumbers)
		return DivideXT(panNumbers)

	func @CumulatedDivision(panNumbers)
		return DivideXT(panNumbers)

	func @CumulateDivisionOf(panNumbers)
		return DivideXT(panNumbers)

	#>

#===

	func @Mean100(panNumbers)
		return Mean100(panNumbers)

	func @Average100(panNumbers)
		return Mean100(panNumbers)

func Mean(panNumbers)
	if CheckParams()
		if NOT (isList(panNumbers) and IslistOfNumbers(panNumbers))
			StzRaise("Incorrect param type! panNumbers must be a list of numbers.")
		ok
	ok

	_nLen_ = Len(panNumbers)
	if _nLen_ = 1
		return panNumbers[1]
	ok

	_nSum_ = 0
	for i = 1 to _nLen_
		_nSum_ += panNumbers[i]
	next

	return _nSum_ / _nLen_

	#< @FunctionAlternativeForms

	func Average(panNumbers)
		return Mean(panNumbers)

	func @Mean(panNumbers)
		return Mean(panNumbers)

	func @Average(panNumbers)
		return Mean(panNumbers)

	#--

	func MeanOf(panNumbers)
		return Mean(panNumbers)

	func @MeanOf(panNumbers)
		return Mean(panNumbers)

	func AverageOf(panNumbers)
		return Mean(panNumbers)

	func @AverageOf(panNumbers)
		return Mean(panNumbers)

	#>

func MultiplicationsYieldingN(_n_)
	_aResult_ = []
			
	_aFactors_ = reverse(factors(_n_))

	_nFactorsLen_2 = len(_aFactors_)
	for i = 1 to _nFactorsLen_2
		_aResult_ + [ factors(_n_)[i] , _aFactors_[i] ]
	next i

	return _aResult_

	func @MultiplicationsYieldingN(_n_)
		return MultiplicationsYieldingN(_n_)

func MultiplicationsYielding(_n_)
	return MultiplicationsYieldingN(_n_)

	func @MultiplicationsYielding(_n_)
		return MultiplicationsYielding(_n_)

func MultiplicationsYieldingN_WithoutCommutation(_n_)
	_aResult_ = []
			
	_aFactors_ = reverse(factors(_n_))

	_nFactorsLen_ = len(_aFactors_)
	for i = 1 to _nFactorsLen_-1
		if i > 1
			if factors(_n_)[i] = _aFactors_[i-1]
				exit
			ok
		ok
		_aResult_ + [ factors(_n_)[i] , _aFactors_[i] ]

	next i

	return _aResult_

	func @MultiplicationsYieldingN_WithoutCommutation(_n_)
		return MultiplicationsYieldingN_WithoutCommutation(_n_)

func NZeros(_n_)
	if CheckingParams()
		if NOT isNumber(_n_) and _n_ >= 0
			StzRaise("Incorrect param type! n must be a postive number.")
		ok
	ok

	_anResult_ = []
	for i = 1 to _n_
		_anResult_ + 0
	next

	return _anResult_

	func @NZeros(_n_)
		return NZeros(_n_)

func NumbersXT(_n1_, _n2_)
	if isList(_n1_) and IsOneOfTheseNamedParamsList(_n1_, [ :Between, :From ])
		_n1_ = _n1_[2]
	ok

	if isList(_n2_) and IsOneOfTheseNamedParamsList(_n2_, [ :And, :To ])
		_n2_ = _n2_[2]
	ok

	if NOT @BothAreNumbers(_n1_, _n2_)
		StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
	ok

	_anResult_ = _n1_ : _n2_
	return _anResult_

	#< @FunctionAlternativeForms

	func NumbersBetweenXT(_n1_, _n2_)
		return NumbersXT(_n1_, _n2_)
	
	func NumbersIB(_n1_, _n2_)
		return NumbersXT(_n1_, _n2_)
	
	func NumbersBetweenIB(_n1_, _n2_)
		return NumbersXT(_n1_, _n2_)

	#--

	func @NumbersXT(_n1_, _n2_)
		return NumbersXT(_n1_, _n2_)

	func @NumbersBetweenXT(_n1_, _n2_)
		return NumbersXT(_n1_, _n2_)
	
	func @NumbersIB(_n1_, _n2_)
		return NumbersXT(_n1_, _n2_)
	
	func @NumbersBetweenIB(_n1_, _n2_)
		return NumbersXT(_n1_, _n2_)

	#>

func NumbersBetween(_n1_, _n2_)
	if CheckingParams()

		if isList(_n1_) and IsOneOfTheseNamedParamsList(_n1_, [ :Between, :From ])
			_n1_ = _n1_[2]
		ok
	
		if isList(_n2_) and IsOneOfTheseNamedParamsList(_n2_, [ :And, :To ])
			_n2_ = _n2_[2]
		ok
	
		if NOT @BothAreNumbers(_n1_, _n2_)
			StzRaise("Incorrect param type! n1 and n2 must both be numbers.")
		ok
	
	ok

	_anResult_ = []

	if _n1_ = _n2_
		_anResult_ + _n1_

	but _n1_ < _n2_
		for i = _n1_ to _n2_
			_anResult_ + i
		next

	else
		for i = _n1_ to _n2_ step -1
			_anResult_ + i
		next
	ok

	return _anResult_

	func @NumbersBetween(nMin, nMax)
		return NumbersBetween(nMin, nMax)

func CommonNumbers(paListsOfNumbers)
	if NOT ( isList(paListsOfNumbers) and Q(paListsOfNumbers).IsListOfListsOfNumbers())
		StzRaise("Incorrect param type! paListsOfNumbers must be a list of lists of numbers.")
	ok

	return CommonItems(paListsOfNumbers)

	#< @FunctionAlternativeForm

	func @CommonNumbers(paListsOfNumbers)
		return CommonNumbers(paListsOfNumbers)

	#>

	#< @FuncionMisspelledForms

	func CommunNumbers(paListsOfNumbers)
		return CommonNumbers(paListsOfNumbers)

	func @CommunNumbers(paListsOfNumbers)
		return CommonNumbers(paListsOfNumbers)

	#>

func NumbersIn(pStrOrList)
	if CheckingParams()
		if NOT (isList(pStrOrList) or isString(pStrOrList))
			StzRaise("Incorrect param type! pStrOrList must be a string or list.")
		ok
	ok

	if isString(pStrOrList)
		return StzStringQ(pStrOrList).NumbersQ().Numberified()
	ok

	# Case where pStrOrList is a list

	_nLen_ = len(pStrOrList)
	_anResult_ = []

	for i = 1 to _nLen_
		if isNumber(pStrOrList[i])
			_anResult_ + pStrOrList[i]
		ok
	next

	return _anResult_

	#< @FunctionAlternativeForm

	func @NumbersIn(paList)
		return NumbersIn(paList)

	func Numbers(pStrOrList)

		if CheckParams()
			if isList(pStrOrList) and IsInNamedParamList(pStrOrList)
				pStrOrList = pStrOrList[2]
			ok
		ok

		return NumbersIn(pStrOrList)

	func @Numbers(pStrOrList)
		return Numbers(pStrOrList)

	#>

func PositiveNumbersIn(paList)
	if CheckingParams()
		if NOT IsList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	_nLen_ = len(paList)
	_anResult_ = []

	for i = 1 to _nLen_
		if isNumber(paList[i]) and paList[i] > 0
			_anResult_ + palist[i]
		ok
	next

	return _anResult_

	#< @FunctionAlternativeForms

	func @PositiveNumbersIn(paList)
		return PositiveNumbers(paList)

	#--

	func Positive(paList)
		return PositiveNumbers(paList)

	func @Positive(paList)
		return PositiveNumbers(paList)

	#>

func NegativeNumbersIn(paList)
	if CheckingParams()
		if NOT IsList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	_nLen_ = len(paList)
	_anResult_ = []

	for i = 1 to _nLen_
		if isNumber(paList[i]) and paList[i] < 0
			_anResult_ + palist[i]
		ok
	next

	return _anResult_

	#< @FunctionAlternativeForms

	func @NegativeNumbersIn(paList)
		return NegativeNumbers(paList)

	#--

	func Negative(paList)
		return NegativeNumbers(paList)

	func @Negative(paList)
		return NegativeNumbers(paList)

	#>

func PositiveNumbersBetween(_n1_, _n2_)
	if CheckingParams()
		if NOT @BothAreNumbers(_n1_, _n2_)
			StzRaise("Incorrect param types! n1 and n2 must both be numbers.")
		ok
	ok

	return PositiveNumbersIn(_n1_:n2)

	#< @FunctionAlternativeForms

	func @PositiveNumbersBetween(_n1_, _n2_)
		return PositiveNumbersBetween(_n1_, _n2_)

	#>

func NegativeNumbersBetween(_n1_, _n2_)
	if CheckingParams()
		if NOT @BothAreNumbers(_n1_, _n2_)
			StzRaise("Incorrect param types! n1 and n2 must both be numbers.")
		ok
	ok

	return NegativeNumbersIn(_n1_:n2)

	#< @FunctionAlternativeForms

	func @NegativeNumbersBetween(_n1_, _n2_)
		return NegativeNumbersBetween(_n1_, _n2_)

	#>

func EvenNumbersIn(paList)
	if CheckingParams()
		if NOT IsList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	_nLen_ = len(paList)
	_anResult_ = []

	for i = 1 to _nLen_
		if isNumber(paList[i]) and IsEven(paList[i])
			_anResult_ + palist[i]
		ok
	next

	return _anResult_

	#< @FunctionAlternativeForms

	func @EvenNumbersIn(paList)
		return EvenNumbers(paList)

	#--

	func Even(paList)
		return EvenNumbers(paList)

	func @Even(paList)
		return EvenNumbers(paList)

	#>

func OddNumbersIn(paList)
	if CheckingParams()
		if NOT IsList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	_nLen_ = len(paList)
	_anResult_ = []

	for i = 1 to _nLen_
		if isNumber(paList[i]) and IsOdd(paList[i])
			_anResult_ + palist[i]
		ok
	next

	return _anResult_

	#< @FunctionAlternativeForms

	func @OddNumbersIn(paList)
		return OddNumbers(paList)

	#--

	func Odd(paList)
		return OddNumbers(paList)

	func @Odd(paList)
		return OddNumbers(paList)

	#>

func PrimeNumbersIn(paList)
	if CheckingParams()
		if NOT IsList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	_nLen_ = len(paList)
	_anResult_ = []

	for i = 1 to _nLen_
		if isNumber(paList[i]) and IsPrime(paList[i])
			_anResult_ + palist[i]
		ok
	next

	return _anResult_

	#< @FunctionAlternativeForms

	func @PrimeNumbersIn(paList)
		return PrimeNumbers(paList)

	#--

	func Prime(paList)
		return PrimeNumbers(paList)

	func @Prime(paList)
		return PrimeNumbers(paList)

	#>

#---- Getting the first n prime numbers #ClaudeAI

func FirstNPrimes(_n_)
	/*
	The _sieve_ of Eratosthenes Algorithm is used

	This is an ancient and efficient algorithm for finding prime numbers,
	discovered by Greek mathematician Eratosthenes (276-194 BC).

	Here's how it works:

	1. Start with a list of numbers from 2 to _n_
	2. Take the first unmarked number (it's prime)
	3. Mark all its multiples as non-prime (composite)
	4. Repeat steps 2-3 until you've processed all numbers up to sqrt(n)

	Example for _n_ = 20:

	[2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]   #~> Initial list
	[2 3 X 5 X 7 X 9 X  11 X  13 X  15 X  17 X  19 X ] #~> After marking 2's multiples
	[2 3 X 5 X 7 X X X  11 X  13 X  X  X  17 X  19 X ] #~> After marking 3's multiples
	[2 3 X 5 X 7 X X X  11 X  13 X  X  X  17 X  19 X ] #~> After marking 5's multiples

	Why it's efficient:
	- Each composite number is marked exactly once by its smallest prime _factor_
	- We only need to check up to sqrt(_n_) because if _n_ is composite, it must 
	  have a _factor_ less than or equal to its square root
	*/


	if _n_ <= 0 return [] ok
	    
	_limit_ = ceil(_n_ * log(_n_) + _n_ * log(log(_n_)))
	if _limit_ < 2 _limit_ = 2 ok
	    
	# Create boolean array, initially all marked as potential primes
	_sieve_ = list(_limit_)
	for i = 1 to _limit_
		_sieve_[i] = 1
	next
    
	# Start sieving - mark all composite numbers
	_sieve_[1] = 0  # 1 is not prime
	for i = 2 to sqrt(_limit_)
		if _sieve_[i] = 1
			# Mark all multiples starting from i*i
			# (smaller multiples would have been marked by smaller primes)
			for _j_ = i * i to _limit_ step i
				_sieve_[_j_] = 0
			next
		ok
	next
    
	# Collect the first n primes from our sieve
	primes = []
	for i = 2 to _limit_
		if _sieve_[i] = 1
			add(primes, i)
			if len(primes) = _n_
				exit
			ok
		ok
	next
    
	return primes

	#< @FunctionFluentForms

	func FirstNPRimesQ(_n_)
		return new stzList(FirstNPrimes(_n_))

	func FirstNPrimesQRT(_n_, pcReturnType)
		if NOT isString(pcReturnType)
			StzRaise("Incorrect param type! pcReturnType must be a string.")
		ok

		switch pcReturnType
		on :stzList
			return new stzList(FirstNPrimes(_n_))
		on :stzListOfNumbers
			return new stzListOfNumbers(FirstNPrimes(_n_))
		other
			StzRaise("Can't transform the list into the provided type.")
		off

	#>

	#< @FunctionAlternativeForm

	func @FirstNPrimes(_n_)
		return FirstNPrimes(_n_)

		func @firstNPrimesQ(_n_)
			return FirstNPrimesQ(_n_)

		func @FirstNPrimesQRT(_n_, pcReturnType)
			return FirstNPrimesQRT(_n_, pcReturnType)

	#>

func NextPrimeST(_nbr_)
	return NextNthPrimeST(1, _nbr_)

	#< @FunctionAlternativeForms

	func NextPrime(Start)
		return NextPrimeST(_nStart_)

	func NextPrimeAfter(_nStart_)
		return NextPrimeST(_nStart_)

	#--

	func @NextPrimeST(_nStart_)
		return NextPrimeST(_nStart_)

	func @NextPrime(_nStart_)
		return NextPrimeST(_nStart_)

	func @NextPrimeAfter(_nStart_)
		return NextPrimeST(_nStart_)

	#>

func NextNthPrimeST(nth, _nbr_)
	if CheckingParams()
		if NOT isNumber(nth)
			StzRaise("Incorrect param type! nth must be a number.")
		ok
	
		if isList(_nbr_) and IsStartingAtOrAfterNamedParamList(_nbr_)
			_nbr_ = _nbr_[2]
		ok

		if NOT isNumber(_nbr_)
			StzRaise("Incorrect param type! nbr must be a number.")
		ok
	ok

	if nth < 1 return 0 ok
    
	_found_ = 0
	_num_ = _nbr_ + 1
    
	while _found_ < nth
		if isPrime(_num_)
			_found_++
			if _found_ = nth
				return _num_
			ok
        	ok
       		 _num_++
    	end
    
    	return _num_ - 1

	#< @FunctionAlternativeForms

	func NextNthPrime(nth, _nbr_)
		return NextNthPrimeST(nth, _nbr_)

	func NextNthPrimeAfter(nth, _nbr_)
		return NextNthPrimeST(nth, _nbr_)

	#--

	func @NextNthPrimeST(nth, _nbr_)
		return NextNthPrimeST(nth, _nbr_)

	func @NextNthPrime(nth, _nbr_)
		return NextNthPrimeST(nth, _nbr_)

	func @NextNthPrimeAfter(nth, _nbr_)
		return NextNthPrimeST(nth, _nbr_)

	#==

	func NthNextprimeST(nth, _nbr_)
		return NextNthPrimeST(nth, _nbr_)

	func NthNextPrime(nth, _nbr_)
		return NextNthPrimeST(nth, _nbr_)

	func NthNextPrimeAfter(nth, _nbr_)
		return NextNthPrimeST(nth, _nbr_)

	#--

	func @NthNextPrimeST(nth, _nbr_)
		return NextNthPrimeST(nth, _nbr_)

	func @NthNextPrime(nth, _nbr_)
		return NextNthPrimeST(nth, _nbr_)

	func @NthNextPrimeAfter(nth, _nbr_)
		return NextNthPrimeST(nth, _nbr_)

	#>

func PreviousPrimeST(_nbr_)
	return PreviousNthPrimeST(1, _nbr_)

	#< @FunctionAlternativeForms

	func PreviousPrime(_nbr_)
		return PreviousPrimeST(_nbr_)

	func PreviousPrimeBefore(_nbr_)
		return PreviousPrimeST(_nbr_)

	#--

	func @PreviousPrimeST(_nbr_)
		return PreviousPrimeST(_nbr_)

	func @PreviousPrime(_nbr_)
		return PreviousPrimeST(_nbr_)

	func @PreviousPrimeBefore(_nbr_)
		return PreviousPrimeST(_nbr_)

	#>

func PreviousNthPrimeST(nth, _nbr_)
	if CheckingParams()
		if NOT isNumber(nth)
			StzRaise("Incorrect param type! nth must be a number.")
		ok
	
		if isList(_nbr_) and IsStartingAtOrBeforeNamedParamList(_nbr_)
			_nbr_ = _nbr_[2]
		ok

		if NOT isNumber(_nbr_)
			StzRaise("Incorrect param type! nbr must be a number.")
		ok
	ok

    	if nth < 1 return 0 ok
    	if _nbr_ <= 2 return 0 ok  # No primes before 2
    
    	_found_ = 0
   	_num_ = _nbr_ - 1
    
   	while _found_ < nth and _num_ >= 2
        	if isPrime(_num_)
          		_found_++
            		if _found_ = nth
                		return _num_
            		ok
        	ok
       		 _num_--
    	end
    
    	# If we couldn't find enough primes before the number

   	 if _found_ < nth
        	return 0
    	ok
    
   	return _num_ + 1

	#< @FunctionAlternativeForms

	func PreviousNthPrime(nth, _nbr_)
		return PreviousNthPrimeST(nth, _nbr_)

	func PreviousNthPrimeBefore(nth, _nbr_)
		return PreviousNthPrimeST(nth, _nbr_)

	#--

	func @PreviousNthPrimeST(nth, _nbr_)
		return PreviousNthPrimeST(nth, _nbr_)

	func @PreviousNthPrime(nth, _nbr_)
		return PreviousNthPrimeST(nth, _nbr_)

	func @PreviousNthPrimeBefore(nth, _nbr_)
		return PreviousNthPrimeST(nth, _nbr_)

	#==

	func NthPreviousprimeST(nth, _nbr_)
		return PreviousNthPrimeST(nth, _nbr_)

	func NthPreviousPrime(nth, _nbr_)
		return PreviousNthPrimeST(nth, _nbr_)

	func NthPreviousPrimeAfter(nth, _nbr_)
		return PreviousNthPrimeST(nth, _nbr_)

	#--

	func @NthPreviousPrimeST(nth, _nbr_)
		return PreviousNthPrimeST(nth, _nbr_)

	func @NthPreviousPrime(nth, _nbr_)
		return PreviousNthPrimeST(nth, _nbr_)

	func @NthPreviousPrimeAfter(nth, _nbr_)
		return PreviousNthPrimeST(nth, _nbr_)

	#>

func FirstNPrimesW(_n_, pcCondition)
	/* EXAMPLE

	_o1_.FirstNPrimesW(25, ' Q(@number).DigitsQRT(:stzListOfNumbers).ArePrime() ')
	#--> [ ... ]

	*/
	if CheckingParams()

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if isList(pcCondition) and IsWhereNamedParamList(pcCondition)
			pcCondition = pcCondition[2]
		ok

		if NOT isString(pcCondition)
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

	ok

	if StringContainsCS(pcCondition, "@prime", 0) = 0
		StzRaise("Incorrect syntax! pcCondition must be a string containg Ring conditional code.")
	ok

	nMax = MaxRingNumber()

	_cCode_ = 'bOk = (' + _StzStripBraces(pcCondition) + ' )'

	_anResult_ = []

	@prime = 0
	_j_ = 0

	while 1
		_j_++
		if _j_ > nMax
			StzRaise("Can't proceed! Maximum Ring number exceeded.")
		ok

		@prime = NextPrimeAfter(@prime)

		eval(_cCode_)
		if bOk
			_anResult_ + @prime
			if len(_anResult_) = _n_
				exit
			ok
		ok

	end

	return _anResult_

	func NFirstPrimesW(_n_, pcCondition)
		return FirstNPrimesW(_n_, pcCondition)

func PrimesUnder(_n_)
	return PrimesUnderIB(_n_-1)

	func PrimesUnderQ(_n_)
		return new stzList(PrimesUnder(_n_))

	func PrimesUnderQQ(_n_)
		return new stzListOfNumbers(PrimesUnder(_n_))

func PrimesUnderIB(_n_)
	if _n_ < 2 return [] ok
    
	# Create a list of boolean values, initially all set to 1
	# Index i represents whether number i is prime
	_sieve_ = list(_n_+1)
	for i = 1 to _n_+1
		_sieve_[i] = 1
	next
    
	# 0 and 1 are not prime
	_sieve_[1] = 0
    
	# Implement Sieve of Eratosthenes
	for i = 2 to floor(sqrt(_n_))
		if _sieve_[i]
			# Mark all multiples of i as non-prime
			for _j_ = i * i to _n_ step i
				_sieve_[_j_] = 0
			next
		ok
	next
    
	# Collect all prime numbers
	primes = []
	for i = 2 to _n_
		if _sieve_[i]
			Add(primes, i)
		ok
	next
    
	return primes

	func PrimesUnderIBQ(_n_)
		return new stzList(PrimesUnderIB(_n_))

	func PrimesUnderIBQQ(_n_)
		return new stzListOfNumbers(PrimesUnderIB(_n_))

func IsListOfNonZeroPositiveNumbers(paList)

	if CheckParams()
		if NOT isList(paList)
			stzraise("Incorrect param type! paList must be a list of numbers.")
		ok
	ok

	_nLen_ = len(paList)
	if _nLen_ = 0
		return 0
	ok

	_bResult_ = 1

	for i = 1 to _nLen_
		if NOT ( isNumber(paList[i]) and paList[i] > 0 )
			_bResult_ = 0
			exit
		ok
	next

	return _bResult_

	func IsListOfStrictlyPositiveNumbers(paList)
		return IsListOfNonZeroPositiveNumbers(paList)

	func @IsListOfNonZeroPositiveNumbers(paList)
		return IsListOfNonZeroPositiveNumbers(paList)

	func @IsListOfStrictlyPositiveNumbers(paList)
		return IsListOfNonZeroPositiveNumbers(paList)


  ////////////////
 ///  CLASS   ///
////////////////

class stzNumbers from stzListOfNumbers

class stzListOfNumbers from stzList
	@aContent
	
	// TODO: Add the possibility to add a list of numbers in strings
	// --> So we can manage numbers as stzNumbers (wich can be provided
	// in strings to conserve their round.
	def init(paList)
		if isList(paList) and
		   ( len(paList) = 0 or @IsListOfNumbers(paList) )
	
			@aContent = paList
	
		but isString(paList)
			try
				_aList_ = Q(paList).ToList()
				if IsListOfNumbers(_aList_)
					@aContent = _aList_
				else
					StzRaise("The list in the string you provided is not a list of numbers!")
				ok
	
			catch
				StzRaise("Can't transform the string into a llist of numbers!")
			done
		else
			StzRaise("Can't create a stzListOfNumbers object!")
		ok

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	def Content()
		_aResult_ = @aContent

		return _aResult_

		def Value()
			return Content()

	def Copy()
		return new stzListOfNumbers(This.Content())

	def ListOfNumbers()
		return Content()

		def Numbers()
			return This.Content()

			def NumbersQ()
				return This.NumbersQRT(:stzList)

			def NumbersQRT(pcReturnType)
				if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamType()
					pcReturnType = pcReturnType[2]
				ok

				if NOT isString(pcReturnType)
					StzRaise("Incorrect param! pcReturnType must be a string.")
				ok

				switch pcReturnType
				on :stzList
					return new stzList( This.Numbers() )

				on :stzListOfStrings
					return new stzListOfStrings( This.Numbers() )

				other
					StzRaise("Unsupported return type!")
				off

	def NumbersW(pcCondition)
		return This.YieldW('@number', pcCondition)

		def NumbersWQ(pcCondition)
			return NumbersWQRT(pcCondition, :stzList)

		# Short aliases used by the narrative tests:
		#   PrimesUnderQ(5000).WXT(' isWeiferich(@number) ')
		# Same eval-and-collect contract as NumbersW.

		def W(pcCondition)
			return This.NumbersW(pcCondition)

		def Where(pcCondition)
			return This.NumbersW(pcCondition)

		def NumbersWQRT(pcCondition, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedParamType()
				pcReturnType = pcReturnType[2]
			ok

			if NOT isString(pcReturnType)
				StzRaise("Incorrect param! pcReturnType must be a string.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.NumbersW(pcCondition) )

			on :stzListOfNumbers
				return new stzListOfStrings( This.NumbersW(pcCondition) )

			other
				StzRaise("Unsupported return type!")
			off

	def ToStzList()
		return new stzList(This.Content())

	def ToStzListOfStrings()
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_acStrings_ = []

		for i = 1 to _nLen_
			_acStrings_ + ( ""+ _anContent_[i] )
		next

		_oResult_ = new stzListOfStrings(_acStrings_)
		return _oResult_

	def NumbersTurnedToStrings()
		_aResult_ = This.ToStzListOfStrings().Content()

		return _aResult_

		def Stringified()
			return This.NumbersTurnedToStrings()

		def AllNumbersTurnedToStrings()
			return This.NumbersTurnedToStrings()

	def NumberAt(_n_)
		return This.ItemAt(_n_)	# Inherited from stzList

		def NumberAtPosition(_n_)
			return This.NumberAt(_n_)

		def Number(_n_)
			return This.NumberAt(_n_)

	  #================================#
	 #  FINDING THE LOWEST N NUMBERS  #
	#================================#

	def NLowestNumbers(_n_)
		_anResult_ = This.ToStzList().RemoveDuplicatesQ().SortInAscendingQ().Section(1, _n_)
		return _anResult_

		#< @FunctionAlternativeForms

		def MinNNumbers(_n_)
			return This.NLowestNumbers(_n_)

		def NMinNumbers(_n_)
			return This.NLowestNumbers(_n_)

		def NMin(_n_)
			return This.NLowestNumbers(_n_)

		def MinN(_n_)
			return This.NLowestNumbers(_n_)

		def NSmallestNumbers(_n_)
			return This.NLowestNumbers(_n_)

		def SmallestNNumbers(_n_)
			return This.NLowestNumbers(_n_)

		def SmallestN(_n_)
			return This.NLowestNumbers(_n_)

		def LowestNNumbers(_n_)
			return This.NLowestNumbers(_n_)

		def LowestN(_n_)
			return This.NLowestNumbers(_n_)

		def NSmallest(_n_)
			return This.NLowestNumbers(_n_)

		#--

		def NBottomNumbers(_n_)
			return This.NLowestNumbers(_n_)

		def BottomNNumbers(_n_)
			return This.NLowestNumbers(_n_)

		def NBottom(_n_)
			return This.NLowestNumbers(_n_)

		def BottomN(_n_)
			return This.NLowestNumbers(_n_)

		#>

	def FindNLowestNumbers(_n_)
		_anNumbers_ = This.NLowestNumbers(_n_)
		_anResult_  = This.FindMany(_anNumbers_)

		return _anResult_

		#< @FunctionAlternativeForms

		def FindMinNNumbers(_n_)
			return This.FindNLowestNumbers(_n_)

		def FindNMinNumbers(_n_)
			return This.FindNLowestNumbers(_n_)

		def FindNMin(_n_)
			return This.FindNLowestNumbers(_n_)

		def FindMinN(_n_)
			return This.FindNLowestNumbers(_n_)

		def FindNSmallestNumbers(_n_)
			return This.FindNLowestNumbers(_n_)

		def FindSmallestNNumbers(_n_)
			return This.FindNLowestNumbers(_n_)

		def FindSmallestN(_n_)
			return This.FindNLowestNumbers(_n_)

		def FindLowestNNumbers(_n_)
			return This.FindNLowestNumbers(_n_)

		def FindLowestN(_n_)
			return This.FindNLowestNumbers(_n_)

		def FindNSmallest(_n_)
			return This.FindNLowestNumbers(_n_)

		#--

		def FindNBottomNumbers(_n_)
			return This.FindNLowestNumbers(_n_)

		def FindBottomNNumbers(_n_)
			return This.FindNLowestNumbers(_n_)

		def FindNBottom(_n_)
			return This.FindNLowestNumbers(_n_)

		def FindBottomN(_n_)
			return This.FindNLowestNumbers(_n_)

		#>

	  #------------------------------------------------------------#
	 #  GETTING THE LOWEST N NUMBERS ALONG WITH THEIR POSITIONS  #
	#------------------------------------------------------------#

	def NLowestNumbersZ(_n_)
		_aResult_ = @Association([ This.NLowestNumbers(_n_), This.FindNLowestNumbers(_n_) ])
		return _aResult_

		#< @FunctionAlternativeForms

		def MinNNumbersZ(_n_)
			return This.NLowestNumbersZ(_n_)

		def NMinNumbersZ(_n_)
			return This.NLowestNumbersZ(_n_)

		def NMinZ(_n_)
			return This.NLowestNumbersZ(_n_)

		def MinNZ(_n_)
			return This.NLowestNumbersZ(_n_)

		def NSmallestNumbersZ(_n_)
			return This.NLowestNumbersZ(_n_)

		def SmallestNNumbersZ(_n_)
			return This.NLowestNumbersZ(_n_)

		def SmallestNZ(_n_)
			return This.NLowestNumbersZ(_n_)

		def LowestNNumbersZ(_n_)
			return This.NLowestNumbersZ(_n_)

		def LowestNZ(_n_)
			return This.NLowestNumbersZ(_n_)

		def NSmallestZ(_n_)
			return This.NLowestNumbersZ(_n_)

		#--

		#--

		def NBottomNumbersZ(_n_)
			return This.NLowestNumbersZ(_n_)

		def BottomNNumbersZ(_n_)
			return This.NLowestNumbersZ(_n_)

		def NBottomZ(_n_)
			return This.NLowestNumbersZ(_n_)

		def BottomNZ(_n_)
			return This.NLowestNumbersZ(_n_)

		#==

		def MinNNumbersAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		def NMinNumbersAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		def NMinAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		def MinNAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		def NSmallestNumbersAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		def SmallestNNumbersAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		def SmallestNAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		def LowestNNumbersAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		def LowestNAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		def NSmallestAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		#--

		def NBottomNumbersAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		def BottomNNumbersAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		def NBottomAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		def BottomNAndTheirPositions(_n_)
			return This.NLowestNumbersZ(_n_)

		#>

	  #==============================#
	 #  FINDING THE SMALLES NUMBER  #
	#==============================#

	def FindMin()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		# Early check

		if _nLen_ = 0
			return 0

		but _nLen_ = 1
			return 1
		ok

		_nResult_ = 1
		_nTempNumber_ = _aContent_[1]

		for i = 2 to _nLen_
			if _aContent_[i] < _nTempNumber_
				_nResult_ = i
				_nTempNumber_ = _aContent_[i]
			ok
		next

		return _nResult_

	def Min()
		_pMiList = This._EngineListFromContent()
		if _pMiList != NULL
			_nMiResult = StzEngineListMin(_pMiList)
			StzEngineListFree(_pMiList)
			return _nMiResult
		ok

		_anContent_ = This.Content()
		_oChain_ = new stzList( _anContent_ )
		_nResult_ = _oChain_.Sorted()[1]
		return _nResult_

		def MinNumber()
			return This.Min()

	def MinZ()
		return This.TopNZ(1)[1]

		def MinNumberZ()
			return This.MinZ()

		def MinAndItsPosition()
			return This.MinZ()

		def MinNumberAndItsPosition()
			return This.MinZ()

	#--

	def Bottom3()
		return This.BottomN(3)

	def Bottom3Numbers()
		return This.BottomN(3)

	def Bottom5()
		return This.BottomN(5)

	def Bottom5Numbers()
		return This.BottomN(5)

	def Bottom7()
		return This.BottomN(7)

	def Bottom7Numbers()
		return This.BottomN(7)

	def Bottom10()
		return This.BottomN(10)

	def Bottom10Numbers()
		return This.BottomN(10)

	#--

	def FindBottom3()
		return This.FindBottomN(3)

	def FindBottom3Numbers()
		return This.FindBottomN(3)

	def FindBottom5()
		return This.FindBottomN(5)

	def FindBottom5Numbers()
		return This.FindBottomN(5)

	def FindBottom7()
		return This.FindBottomN(7)

	def FindBottom7Numbers()
		return This.FindBottomN(7)

	def FindBottom10()
		return This.FindBottomN(10)

	def FindBottom10Numbers()
		return This.FindBottomN(10)

	#--

	def Bottom3Z()
		return This.BottomNZ(3)

	def Bottom3NumbersZ()
		return This.BottomNZ(3)

	def Bottom5Z()
		return This.BottomNZ(5)

	def Bottom5NumbersZ()
		return This.BottomNZ(5)

	def Bottom7Z()
		return This.BottomNZ(7)

	def Bottom7NumbersZ()
		return This.BottomNZ(7)

	def Bottom10Z()
		return This.BottomNZ(10)

	def Bottom10NumbersZ()
		return This.BottomNZ(10)

	def Bottom3AndTheirPositions()
		return This.BottomNZ(3)

	def Bottom3NumbersAndTheirPositions()
		return This.BottomNZ(3)

	def Bottom5AndTheirPositions()
		return This.BottomNZ(5)

	def Bottom5NumbersAndTheirPositions()
		return This.BottomNZ(5)

	def Bottom7AndTheirPositions()
		return This.BottomNZ(7)

	def Bottom7NumbersAndTheirPositions()
		return This.BottomNZ(7)

	def Bottom10AndTheirPositions()
		return This.BottomNZ(10)

	def Bottom10NumbersAndTheirPositions()
		return This.BottomNZ(10)

	  #=================================#
	 #  FINDING THE LARGEST N NUMBERS  #
	#=================================#

	def NLargestNumbers(_n_)
		_anResult_ = This.ToStzList().RemoveDuplicatesQ().SortInAscendingQ().LastNItems(_n_)
		return _anResult_

		#< @FunctionAlternativeForms

		def MaxNNumbers(_n_)
			return This.NLargestNumbers(_n_)

		def NMaxNumbers(_n_)
			return This.NLargestNumbers(_n_)

		def NMax(_n_)
			return This.NLargestNumbers(_n_)

		def MaxN(_n_)
			return This.NLargestNumbers(_n_)

		def NBiggestNumbers(_n_)
			return This.NLargestNumbers(_n_)

		def BiggestNNumbers(_n_)
			return This.NLargestNumbers(_n_)

		def BiggestN(_n_)
			return This.NLargestNumbers(_n_)

		def LargestNNumbers(_n_)
			return This.NLargestNumbers(_n_)

		def LargestN(_n_)
			return This.NLargestNumbers(_n_)

		def NBiggest(_n_)
			return This.NLargestNumbers(_n_)

		#--

		def NGreatestNumbers(_n_)
			return This.NLargestNumbers(_n_)

		def GreatestNNumbers(_n_)
			return This.NLargestNumbers(_n_)

		def NGreatest(_n_)
			return This.NLargestNumbers(_n_)

		def GreatestN(_n_)
			return This.NLargestNumbers(_n_)

		#==

		def NTopNumbers(_n_)
			return This.NLargestNumbers(_n_)

		def TopNNumbers(_n_)
			return This.NLargestNumbers(_n_)

		def NTop(_n_)
			return This.NLargestNumbers(_n_)

		def TopN(_n_)
			return This.NLargestNumbers(_n_)

		#>

	def FindNLargestNumbers(_n_)
		_anNumbers_ = This.NLargestNumbers(_n_)
		_anResult_  = This.FindMany(_anNumbers_)

		return _anResult_

		#< @FunctionAlternativeForms

		def FindMaxNNumbers(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindNMaxNumbers(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindNMax(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindMaxN(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindNBiggestNumbers(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindBiggestNNumbers(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindBiggestN(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindLargestNNumbers(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindLargestN(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindNBiggest(_n_)
			return This.FindNLargestNumbers(_n_)

		#--

		def FindNGreatestNumbers(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindGreatestNNumbers(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindNGreatest(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindGreatestN(_n_)
			return This.FindNLargestNumbers(_n_)

		#==

		def FindNTopNumbers(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindTopNNumbers(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindNTop(_n_)
			return This.FindNLargestNumbers(_n_)

		def FindTopN(_n_)
			return This.FindNLargestNumbers(_n_)

		#>

	  #------------------------------------------------------------#
	 #  GETTING THE LARGEST N NUMBERS ALONG WITH THEIR POSITIONS  #
	#------------------------------------------------------------#

	def NLargestNumbersZ(_n_)
		_aResult_ = Association([ This.NLargestNumbers(_n_), This.FindNLargestNumbers(_n_) ])
		return _aResult_

		#< @FunctionAlternativeForms

		def MaxNNumbersZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def NMaxNumbersZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def NMaxZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def MaxNZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def NBiggestNumbersZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def BiggestNNumbersZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def BiggestNZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def LargestNNumbersZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def LargestNZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def NBiggestZ(_n_)
			return This.NLargestNumbersZ(_n_)

		#--

		def NGreatestNumbersZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def GreatestNNumbersZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def NGreatestZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def GreatestNZ(_n_)
			return This.NLargestNumbersZ(_n_)

		#==

		def MaxNNumbersAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def NMaxNumbersAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def NMaxAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def MaxNAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def NBiggestNumbersAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def BiggestNNumbersAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def BiggestNAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def LargestNNumbersAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def LargestNAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def NBiggestAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		#--

		def NGreatestNumbersAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def GreatestNNumbersAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def NGreatestAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def GreatestNAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		#==

		def NTopNumbersZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def TopNNumbersZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def NTopZ(_n_)
			return This.NLargestNumbersZ(_n_)

		def TopNZ(_n_)
			return This.NLargestNumbersZ(_n_)

		#--

		def NTopNumbersAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def TopNNumbersAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def NTopAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		def TopNAndTheirPositions(_n_)
			return This.NLargestNumbersZ(_n_)

		#>

	  #==============================#
	 #  FINDING THE LARGEST NUMBER  #
	#==============================#

	def FindMax()
		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		# Early check

		if _nLen_ = 0
			return 0

		but _nLen_ = 1
			return 1
		ok

		_nResult_ = 1
		_nTempNumber_ = _aContent_[1]

		for i = 2 to _nLen_
			if _aContent_[i] > _nTempNumber_
				_nResult_ = i
				_nTempNumber_ = _aContent_[i]
			ok
		next

		return _nResult_

	def Max()
		_pMxList = This._EngineListFromContent()
		if _pMxList != NULL
			_nMxResult = StzEngineListMax(_pMxList)
			StzEngineListFree(_pMxList)
			return _nMxResult
		ok

		_anContent_ = This.Content()
		_oChain_ = new stzList( _anContent_ )
		_nResult_ = _oChain_.SortedInDescending()[1]
		return _nResult_

		def MaxNumber()
			return This.Max()

	def MaxZ()
		return This.TopNZ(1)[1]

		def MaxNumberZ()
			return This.MaxZ()

		def MaxAndItsPosition()
			return This.MaxZ()

		def MaxNumberAndItsPosition()
			return This.MaxZ()

	#--

	def Top3()
		return This.TopN(3)

	def Top3Numbers()
		return This.TopN(3)

	def Top5()
		return This.TopN(5)

	def Top5Numbers()
		return This.TopN(5)

	def Top7()
		return This.TopN(7)

	def Top7Numbers()
		return This.TopN(7)

	def Top10()
		return This.TopN(10)

	def Top10Numbers()
		return This.TopN(10)

	#--

	def FindTop3()
		return This.FindTopN(3)

	def FindTop3Numbers()
		return This.FindTopN(3)

	def FindTop5()
		return This.FindTopN(5)

	def FindTop5Numbers()
		return This.FindTopN(5)

	def FindTop7()
		return This.FindTopN(7)

	def FindTop7Numbers()
		return This.FindTopN(7)

	def FindTop10()
		return This.FindTopN(10)

	def FindTop10Numbers()
		return This.FindTopN(10)

	#--

	def Top3Z()
		return This.TopNZ(3)

	def Top3NumbersZ()
		return This.TopNZ(3)

	def Top5Z()
		return This.TopNZ(5)

	def Top5NumbersZ()
		return This.TopNZ(5)

	def Top7Z()
		return This.TopNZ(7)

	def Top7NumbersZ()
		return This.TopNZ(7)

	def Top10Z()
		return This.TopNZ(10)

	def Top10NumbersZ()
		return This.TopNZ(10)

	def Top3AndTheirPositions()
		return This.TopNZ(3)

	def Top3NumbersAndTheirPositions()
		return This.TopNZ(3)

	def Top5AndTheirPositions()
		return This.TopNZ(5)

	def Top5NumbersAndTheirPositions()
		return This.TopNZ(5)

	def Top7AndTheirPositions()
		return This.TopNZ(7)

	def Top7NumbersAndTheirPositions()
		return This.TopNZ(7)

	def Top10AndTheirPositions()
		return This.TopNZ(10)

	def Top10NumbersAndTheirPositions()
		return This.TopNZ(10)

	  #==========================================================================#
	 #  NEAREST NUMBER IN THE LIST TO A GIVEN NUMBER COMING BEFORE OR AFTER IT  #
	#==========================================================================#

	def NearestXT(_n_, pcBeforeOrAfter)

		# Checking the n param

		if isList(_n_) and Q(_n_).IsToNamedParam()
			_n_ = _n_[2]
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		# Checking the pcBeforeOrAfter param

		if isList(pcBeforeOrAfter) and
		   Q(pcBeforeOrAfter).IsComingNamedParam()

			pcBeforeOrAfter = pcBeforeOrAfter[2]
		ok

		if NOT 	( isString(pcBeforeOrAfter) and
			  StzFindFirst([
				:Before, :After, :BeforeIt, :AfterIt,
				:BeforeOrAfter, :BeforeOrAfterIt,
				:AfterOrBefore, :AfterOrBeforeIt,

				:ComingBefore, :ComingAfter, :ComingBeforeIt, :ComingAfterIt,
				:ComingBeforeOrAfter, :ComingBeforeOrAfterIt,
				:ComingAfterOrBefore, :ComingAfterOrBeforeIt

			  ], pcBeforeOrAfter) > 0)

			StzRaise("Incorrect param type! pcComingBeforeOrAfter must be a string equal to :Before, :After, or :BeforeOrAfter.")

		ok

		# Doing the job

		if StzFindFirst([
			:BeforeOrAfter, :BeforeOrAfterIt,
			:AfterOrBefore, :AfterOrBeforeIt,

			:ComingBeforeOrAfter, :ComingBeforeOrAfterIt,
			:ComingAfterOrBefore, :ComingAfterOrBeforeIt
			], pcBeforeOrAfter) > 0

			_nResult_ = This.NearestTo(_n_)

		but StzFindFirst([
			:Before, :BeforeIt,
			:ComingBefore, :ComingBeforeIt
			], pcBeforeOrAfter) > 0

			_anPair_ = This.NeighborsOf(_n_)
			_nResult_ = _anPair_[1]

		but StzFindFirst([
			:After, :AfterIt,
			:ComingAfter, :ComingAfterIt
			], pcBeforeOrAfter) > 0

			_anPair_ = This.NeighborsOf(_n_)
			_nResult_ = _anPair_[2]

		else # Impossible case, but let's deal with it
			StzRaise("Syntax error!")
		ok

		return _nResult_

		#< @FunctionAlternativeForm

		def NearestToXT(_n_, pcBeforeOrAfter)
			return This.NearestXT(_n_, pcBeforeOrAfter)

		#--

		def NearestNumberXT(_n_, pcBeforeOrAfter)
			return This.NearestXT(_n_, pcBeforeOrAfter)

		def NearestNumberToXT(_n_, pcBeforeOrAfter)
			return This.NearestXT(_n_, pcBeforeOrAfter)

		#==

		def ClosestXT(_n_, pcBeforeOrAfter)
			return This.NearestXT(_n_, pcBeforeOrAfter)

		def ClosestToXT(_n_, pcBeforeOrAfter)
			return This.NearestXT(_n_, pcBeforeOrAfter)

		#--

		def ClosestNumberXT(_n_, pcBeforeOrAfter)
			return This.NearestXT(_n_, pcBeforeOrAfter)

		def ClosestNumberToXT(_n_, pcBeforeOrAfter)
			return This.NearestXT(_n_, pcBeforeOrAfter)


		#>

		#< @FunctionMisspelledForm

		def NearstXT(_n_, pcBeforeOrAfter)
			return This.NearestXT(_n_, pcBeforeOrAfter)

		def NearstToXT(_n_, pcBeforeOrAfter)
			return This.NearestXT(_n_, pcBeforeOrAfter)

		#--

		def NearstNumberXT(_n_, pcBeforeOrAfter)
			return This.NearestXT(_n_, pcBeforeOrAfter)

		def NearstNumberToXT(_n_, pcBeforeOrAfter)
			return This.NearestXT(_n_, pcBeforeOrAfter)

		#>

	  #---------------------------------------------------------------------------#
	 #  FARTHEST NUMBER IN THE LIST TO A GIVEN NUMBER COMING BEFORE OR AFTER IT  #
	#---------------------------------------------------------------------------#

	def FarthestXT(_n_, pcBeforeOrAfter)

		# Checking the n param

		if isList(_n_) and Q(_n_).IsToNamedParam()
			_n_ = _n_[2]
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		# Checking the pcBeforeOrAfter param

		if isList(pcBeforeOrAfter) and
		   Q(pcBeforeOrAfter).IsComingNamedParam()

			pcBeforeOrAfter = pcBeforeOrAfter[2]
		ok

		if NOT ( isString(pcBeforeOrAfter) and
			  StzFindFirst([
				:Before, :After, :BeforeIt, :AfterIt,
				:BeforeOrAfter, :BeforeOrAfterIt,
				:AfterOrBefore, :AfterOrBeforeIt,

				:ComingBefore, :ComingAfter, :ComingBeforeIt, :ComingAfterIt,
				:ComingBeforeOrAfter, :ComingBeforeOrAfterIt,
				:ComingAfterOrBefore, :ComingAfterOrBeforeIt

			  ], pcBeforeOrAfter) > 0 )

			StzRaise("Incorrect param type! pcComingBeforeOrAfter must be a string equal to :Before, :After, or :BeforeOrAfter.")

		ok

		# Doing the job

		if StzFindFirst([
			:BeforeOrAfter, :BeforeOrAfterIt,
			:AfterOrBefore, :AfterOrBeforeIt,

			:ComingBeforeOrAfter, :ComingBeforeOrAfterIt,
			:ComingAfterOrBefore, :ComingAfterOrBeforeIt
			], pcBeforeOrAfter) > 0

			_nResult_ = This.FarthestTo(_n_)

		but StzFindFirst([
			:Before, :BeforeIt,
			:ComingBefore, :ComingBeforeIt
			], pcBeforeOrAfter) > 0

			_anSorted_ = This.ToSetQ().Sorted()
			_nLen_ = len(_anSorted_)
			
			if _nLen_ = 0
				return ""

			but _nLen_ = 1
				if _anSorted_[1] = _n_
					return ""

				else
					return _anSorted_[1]
				ok

			else
				_nPos_ = StzFindFirst(_anSorted_, _n_)

				if _nPos_ > 1
					_nFirst_ = _anSorted_[1]
					_nLast_  = _anSorted_[_nLen_]

					_nDif1_ = abs(_n_ - _nFirst_)
					_nDif2_ = abs(_n_ - _nLast_)

					if _nDif1_ > _nDif2_
						return _nLast_
					else
						return _nFirst_
					ok

				else
					return ""
				ok

			ok

		but StzFindFirst([
			:After, :AfterIt,
			:ComingAfter, :ComingAfterIt
			], pcBeforeOrAfter) > 0

			_anSorted_ = This.ToSetQ().Sorted()
			_nLen_ = len(_anSorted_)

			if _nLen_ = 0
				return ""

			but _nLen_ = 1
				if _anSorted_[1] = _n_
					return ""

				else
					return _anSorted_[1]
				ok

			else
				_nPos_ = StzFindFirst(_anSorted_, _n_)

				if _nPos_ > 0 and _nPos_ < _nLen_
					_nFirst_ = _anSorted_[1]
					_nLast_  = _anSorted_[_nLen_]

					_nDif1_ = abs(_n_ - _nFirst_)
					_nDif2_ = abs(_n_ - _nLast_)

					if _nDif1_ > _nDif2_
						return _nFirst_
					else
						return _nLast_
					ok

				else
					return ""
				ok

			ok		

		ok

		return _nResult_

		#< @FunctionAlternativeForm

		def FarthestToXT(_n_, pcBeforeOrAfter)
			return This.FarthestXT(_n_, pcBeforeOrAfter)

		#>

		#< @FunctionMisspelledForm

		def FarthstXT(_n_, pcBeforeOrAfter)
			return This.FarthestXT(_n_, pcBeforeOrAfter)

		def FarthstToXT(_n_, pcBeforeOrAfter)
			return This.FarthestXT(_n_, pcBeforeOrAfter)

		#--

		def FarthestNumberXT(_n_, pcBeforeOrAfter)
			return This.FarthestXT(_n_, pcBeforeOrAfter)

		def FarthstNumberXT(_n_, pcBeforeOrAfter)
			return This.FarthestXT(_n_, pcBeforeOrAfter)

		def FarthstNumberToXT(_n_, pcBeforeOrAfter)
			return This.FarthestXT(_n_, pcBeforeOrAfter)

		#>

	  #----------------------------------------------------#
	 #     NEAREST NUMBER IN THE LIST TO A GIVEN NUMBER   #
	#----------------------------------------------------#

	def Nearest(_n_)
		/* EXAMPLE

		? Q([ 2, 7, 18, 10, 25, 4 ]).NearestTo(12)
		#--> 10
		
		*/

		# Checking the n param

		if isList(_n_) and Q(_n_).IsToNamedParam()
			_n_ = _n_[2]
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		# Doing the job

		_anSorted_ = This.ToSetQ().Sorted()
		_nLen_ = len(_anSorted_)

		# Case where the list contains only one number
		# (even if duplicated, like in [ 2, 2, 2 ])

		if _nLen_ = 0
			return ""

		but _nLen_ = 1
			if _anSorted_[1] = _n_
				return ""
			else
				return _anSorted_[1]
			ok
		ok

		# Case where n exists in the list

		_nPos_ = StzFindFirst(_anSorted_, _n_)

		if _nPos_ > 0
			if _nPos_ = 1
				return _anSorted_[2]

			but _nPos_ = _nLen_
				return _anSorted_[_nLen_ - 1]

			else
				_nDif1_ = abs( _n_ - _anSorted_[_nPos_-1] )
				_nDif2_ = abs( _n_ - _anSorted_[_nPos_+1] )

				if _nDif1_ < _nDif2_
					return _anSorted_[_nPos_-1]
				else
					return _anSorted_[_nPos_+1]
				ok
			ok

		# Case where n does not exist in the list

		else

			_nNearest_ = _anSorted_[1]
			for i = 2 to _nLen_
	
				_nDif2_ = abs(_n_ - _anSorted_[i])
				_nDif1_ = abs(_n_ - _anSorted_[i-1])
	
				if _nDif2_ < _nDif1_
					_nNearest_ = _anSorted_[i]
				ok
						
			next
		
			return _nNearest_
		ok

		#< @FunctionAlternativeForms

		def NearestTo(_n_)
			return This.Nearest(_n_)

		#--

		def NearestNumber(_n_)
			return This.Nearest(_n_)

		def NearstNumber(_n_)
			return This.Nearest(_n_)

		def NearstNumberTo(_n_)
			return This.Nearest(_n_)

		#==

		def Closest(_n_)
			return This.Nearest()

		#--

		def ClosestTo(_n_)
			return This.Nearest(_n_)

		#--

		def ClosestNumber(_n_)
			return This.Nearest(_n_)

		def ClosestNumberTo(_n_)
			return This.Nearest(_n_)

		#>

		#< @MisspelledForms

		def NearstTo(_n_)
			return This.Nearest(_n_)

		def Nearst(_n_)
			return This.Nearest(_n_)

		#>
	  #---------------------------------------------------#
	 #   FARTHEST NUMBER IN THE LIST TO A GIVEN NUMBER   #
	#---------------------------------------------------#

	def Farthest(_n_)

		# Checking the n param

		if isList(_n_) and Q(_n_).IsToNamedParam()
			_n_ = _n_[2]
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		# Doing the job

		_anSorted_ = This.ToSetQ().Sorted()
		_nLen_ = len(_anSorted_)

		# Case where the list contains only one number
		# (even if duplicated, like in [ 2, 2, 2 ])

		if _nLen_ = 0
			return ""

		but _nLen_ = 1
			if _anSorted_[1] = _n_
				return ""
			else
				return _anSorted_[1]
			ok
		ok

		# Case where n exists in the list

		_nPos_ = StzFindFirst(_anSorted_, _n_)

		if _nPos_ > 0
			_nDif1_ = abs( _n_ - _anSorted_[1] )
			_nDif2_ = abs( _n_ - _anSorted_[_nLen_] )

			if _nDif1_ > _nDif2_
				return _anSorted_[1]
			else
				return _anSorted_[_nLen_]
			ok
		
		# Case where n does not extist in the list
		else

			_nFarthest_ = _anSorted_[1]
			for i = 2 to _nLen_
	
				_nDif2_ = abs(_n_ - _anSorted_[1])
				_nDif1_ = abs(_n_ - _anSorted_[_nLen_])
	
				if _nDif2_ < _nDif1_
					_nFarthest_ = _anSorted_[_nLen_]
				ok
						
			next
		
			return _nFarthest_
		ok

		#< @FunctionAlternativeForm

		def FarthestTo(_n_)
			return This.Farthest(_n_)

		#--

		def FarthestNumber(_n_)
			return This.Farthest(_n_)

		#>

		#< @FunctionMisspelledForms

		def Fartehst(_n_)
			return This.Farthest(_n_)

		def FartehstTo(_n_)
			return This.Farthest(_n_)

		def Farthst(_n_)
			return This.Farthest(_n_)

		def FarthstTo(_n_)
			return This.Farthest(_n_)

		#--

		def FartehstNumber(_n_)
			return This.Farthest(_n_)

		def FartehstNumberTo(_n_)
			return This.Farthest(_n_)

		def FarthstNumber(_n_)
			return This.Farthest(_n_)

		def FarthstNumberTo(_n_)
			return This.Farthest(_n_)

		#>

	  #-------------------------------------------------------#
	 #  GETTING THE TWO NIGHBORS (IF ANY) OF A GIVEN NUMBER  #
	#-------------------------------------------------------#

	def Neighbors(_n_)
		/* EXAMPLE

		_o1_ = new stzListOfNumbers([ 1, 4, 6, 11, 18 ])
		? _o1_.NeighborsOf(5)
		#--> [4, 6]
		
		*/

		# Checking the n param

		if isList(_n_) and Q(_n_).IsToOrOfNamedParam()
			_n_ = _n_[2]
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		# Doing the job
	
		_nLen_ = len(@aContent)

		if _nLen_ = 0
			return []

		but _nLen_ = 1
			return [ @aContent[1] ]
		ok

		_anSorted_ = This.ToSetQ().Sorted()
		_nPos_ = StzFindFirst(_anSorted_, _n_)

		if _nPos_ = 0
			if _n_ < _anSorted_[1]
				return [ _anSorted_[1] ]

			but _n_ > _nLen_
				return [ _anSorted_[_nLen_] ]

			but _n_ = _anSorted_[1]
				return [ _anSorted_[2] ]

			but _n_ = _anSorted_[_nLen_]
				return [ _anSorted_[_nLen_-1] ]

			else
				for i = 1 to _nLen_-1
					if _n_ > _anSorted_[i] and _n_ < _anSorted_[i+1]
						return [ _anSorted_[i], _anSorted_[i+1] ]
					ok
				next
			ok

		but _nPos_ = 1
			return [ _anSorted_[2] ]

		but _nPos_ = _nLen_
			return [ _anSorted_[_nLen_-1] ]

		else
			return [ _anSorted_[_nPos_-1], _anSorted_[_nPos_+1] ]
		ok

		#< @functionAlternativeForm

		def NeighborsOf(_n_)
			return This.Neighbors(_n_)

		def NNeighbors(_n_)
			return This.Neighbors(_n_)

		def NNeighborsOf(_n_)
			return This.Neighbors(_n_)

		def NNeighborsTo(_n_)
			return This.Neighbors(_n_)

		#--

		def NeighboringNumbers(_n_)
			return This.Neighbors(_n_)

		def NeighboringNumbersOf(_n_)
			return This.Neighbors(_n_)

		def NNeighboringNumbers(_n_)
			return This.Neighbors(_n_)

		def NNeighboringNumbersOf(_n_)
			return This.Neighbors(_n_)

		def NNeighboringNumbersTo(_n_)
			return This.Neighbors(_n_)

		#==

		def NearestNeighbors(_n_)
			return This.Neighbors(_n_)

		def NearestNeighborsOf(_n_)
			return This.Neighbors(_n_)

		def NearestNeighborsTo(_n_)
			return This.Neighbors(_n_)

		def NearestNeighboringNumbers(_n_)
			return This.Neighbors(_n_)

		def NearestNeighboringNumbersOf(_n_)
			return This.Neighbors(_n_)

		def NearestNeighboringNumbersTo(_n_)
			return This.Neighbors(_n_)

		#--

		def ClosesestNeighbors(_n_)
			return This.Neighbors(_n_)

		def ClosestNeighborsOf(_n_)
			return This.Neighbors(_n_)

		def ClosestNeighborsTo(_n_)
			return This.Neighbors(_n_)

		def ClosestNeighboringNumbers(_n_)
			return This.Neighbors(_n_)

		def ClosestNeighboringNumbersOf(_n_)
			return This.Neighbors(_n_)

		def ClosestNeighboringNumbersTo(_n_)
			return This.Neighbors(_n_)

		#>

		#< @FunctionMisspelledForms

		def Nighbors(_n_)
			return NeighborsOf(_n_)

		def NearestNighbors(_n_)
			return NeighborsOf(_n_)

		def NighborsOf(_n_)
			return NeighborsOf(_n_)

		def NearestNighborsOf(_n_)
			return NeighborsOf(_n_)

		def NighborsTo(_n_)
			return NeighborsOf(_n_)

		def NearestNighborsTo(_n_)
			return NeighborsOf(_n_)

		#>

	def FarthestNeighbors(_n_)

		# Checking the n param

		if isList(_n_) and Q(_n_).IsToOrOfNamedParam()
			_n_ = _n_[2]
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		# Doing the job
	
		_anSorted_ = This.ToSetQ().Sorted()
		_nLen_ = len(_anSorted_)
			
		if _nLen_ = 0
			return [ "", "" ]
		ok

		_nPos_ = StzFindFirst( _anSorted_, _n_ )

		if _nPos_ = 0
			return [ "", "" ]
		ok

		_n1_ = _anSorted_[1]
		_n2_ = _anSorted_[_nLen_]

		if _nPos_ = 1
			_n1_ = ""

		but _nPos_ = _nLen_
			_n2_ = ""
		ok

		_anResult_ = [ _n1_, _n2_ ]
		return _anResult_

		#< @FunctionAlternativeForms

		def FNeighbors(_n_)
			return This.FarthestNeighbors(_n_)

		def FarthestNeighborsOf(_n_)
			return This.FarthestNeighbors(_n_)

		def FNeighborsOf(_n_)
			return This.FarthestNeighbors(_n_)

		def FarthestNeighborsTo(_n_)
			return This.FarthestNeighbors(_n_)

		def FNeighborsTo(_n_)
			return This.FarthestNeighbors(_n_)


		#--

		def FarthestNeighboringNumbers(_n_)
			return This.FarthestNeighbors(_n_)

		def FNeighboringNumbers(_n_)
			return This.FarthestNeighbors(_n_)

		def FarthestNeighboringNumbersOf(_n_)
			return This.FarthestNeighbors(_n_)

		def FNeighboringNumbersOf(_n_)
			return This.FarthestNeighbors(_n_)

		def FarthestNeighboringNumbersTo(_n_)
			return This.FarthestNeighbors(_n_)

		def FNeighboringNumbersTo(_n_)
			return This.FarthestNeighbors(_n_)

		#>

		#< @FunctionMisspelledForms

		def FarthestNighbors(_n_)
			return This.FarthestNeighbors(_n_)

		def FNighbors(_n_)
			return This.FarthestNeighbors(_n_)

		def FarthstNeighbors(_n_)
			return This.FarthestNeighbors(_n_)

		def FarthstNighbors(_n_)
			return This.FarthestNeighbors(_n_)

		#>

	  #=====================================================#
	 #  GETTING THE SEQUENTIAL DIFFERENCE BETWEEN NUMBERS  #
	#=====================================================#

	def Diff()
		_anResult_ = []
		_nLen_ = len(@aContent)
		if _nLen_ = 1
			StzRaise("Can't compute the Diffs! The ist must contain more then 1 number.")
		ok

		for i = 2 to _nLen_
			_anResult_ + ( @aContent[i] - @aContent[i-1] )
		next

		return _anResult_

		def Diffs()
			return This.Diff()

		def Differences()
			return This.Diff()

	def AbsDiff()
		_anResult_ = []
		_nLen_ = len(@aContent)
		if _nLen_ = 1
			StzRaise("Can't compute the Diffs! The ist must contain more then 1 number.")
		ok

		for i = 2 to _nLen_
			_anResult_ + @Abs( @aContent[i] - @aContent[i-1] )
		next

		return _anResult_

		def AbsDiffs()
			return This.AbsDiff()

		def AbsoluteDifferences()
			return This.AbsDiff()

	  #-------------------------------------------------------------------#
	 #  GETTING THE DIFFRERENCES BETWEEN A GIVEN NUMBER AND ALL NUMBERS  #
	#-------------------------------------------------------------------#

	def DiffWith(_n_)

		if CheckParams() and NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")				
		ok

		_anResult_ = []
		_nLen_ = len(@aContent)
		if _nLen_ = 1
			StzRaise("Can't compute the Diffs! The ist must contain more then 1 number.")
		ok

		for i = 1 to _nLen_
			_anResult_ + ( @aContent[i] - _n_ )
		next

		return _anResult_

		def DiffsWith(_n_)
			return This.DiffWith(_n_)

		def DifferencesWith(_n_)
			return This.DiffWith(_n_)

	def AbsDiffWith(_n_)

		if CheckParams() and NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")				
		ok

		_anResult_ = []
		_nLen_ = len(@aContent)
		if _nLen_ = 1
			StzRaise("Can't compute the Diffs! The ist must contain more then 1 number.")
		ok

		for i = 1 to _nLen_
			_anResult_ + @Abs( @aContent[i] - _n_ )
		next

		return _anResult_

		def AbsDiffsWith(_n_)
			return This.AbsDiffWith(_n_)

		def AbsoluteDifferencesWith(_n_)
			return This.AbsDiffWith(_n_)

	  #---------------------------------------------------#
	 #  CLASSIFYING NUMBERS BY NEAREST TO GIVEN NUMBERS  #
	#---------------------------------------------------#

	def ClassifyByNearestTo(panNumbers)

		if CheckParams() and
		   NOT (isList(panNumbers) and @IsListOfNumbers(panNumbers))

			StzRaise("Incorrect param type! panNumbers must be a list of numbers.")
		ok

		_aResult_ = []
		panNumbers = U(panNumbers)
		_nLenNumbers_ = len(panNumbers)

		for i = 1 to _nLenNumbers_
			_aResult_ + [ panNumbers[i], [] ]
		next

		_nLenContent_ = len(@aContent)

		for _j_ = 1 to _nLenContent_

			_nNumber_ = @aContent[_j_]
			_nMinDiff_ = NULL
			_nClosestPivot_ = NULL

			for i = 1 to _nLenNumbers_

				_nPivot_ = panNumbers[i]
				_nDiff_ = @abs(_nNumber_ - _nPivot_)

				if _nMinDiff_ = NULL or _nDiff_ < _nMinDiff_
					_nMinDiff_ = _nDiff_
					_nClosestPivot_ = _nPivot_
				ok

			next

			_nResultLen_ = len(_aResult_)
			for i = 1 to _nResultLen_

				if StzFindFirst(panNumbers, _nNumber_) = 0 and
				   _aResult_[i][1] = _nClosestPivot_

					_aResult_[i][2] + _nNumber_
					exit
				ok
			next
		next

		return _aResult_

	  #==========================================#
	 #  GETTING THE STEPS TAKNE BY THE NUMBERS  #
	#==========================================#

	# Returns the minimal repeating pattern of steps (differences)
	# between consecutive numbers in the list

	# Made for use with stzWalker classes

	def Steps()

		# EXAMPLES

		# [1,2,3,4,5] returns [1] because the step is constantly 1
		# [1,2,5,6,9,10] returns [1,3] because the pattern of steps is 1,3,1,3,1...
		# [4,8,2,3,7,1,2] returns [4,-6,1,4,-6,1] because the steps pattern is 4,-6,1

		if len(@aContent) <= 1
			StzRaise("Can't compute steps! The list must contain at least 2 numbers.")
  		ok
    
		# Calculate all differences

		_anDiffs_ = []

		_nContentLen_ = len(@aContent)
		for i = 2 to _nContentLen_
			_anDiffs_ + (@aContent[i] - @aContent[i-1])
		next

		# Find shortest repeating pattern

		_nLen_ = len(_anDiffs_)

		# Special case for [1,2,3,4,5]

		if U(_anDiffs_) = _anDiffs_[1]
			return [ _anDiffs_[1] ]
		ok
    
		# Try to find the repeating pattern

		for i = 1 to _nLen_

			# Build pattern from first i elements

			_anPattern_ = []
			for _j_ = 1 to i
				_anPattern_ + _anDiffs_[_j_]
			next

			# Check if this pattern repeats throughout

			_bMatches_ = 1
			_nLenPattern_ = len(_anPattern_)

			for _j_ = 1 to _nLen_
				if _anDiffs_[_j_] != _anPattern_[(_j_-1) % _nLenPattern_ + 1]
					_bMatches_ = 0
					exit
  				ok
			next

			if _bMatches_
				return _anPattern_
			ok
		next
    
    		return _anDiffs_

	  #-------------------------------------------------------------------#
	 #  REVERSE-ENGENEERING THE LIST OF NUMBERS INTO A STZWALKER OBJECT  #
	#-------------------------------------------------------------------#

	def Walker()
		return new stzWalker(@aContent[1], @aContent[len(@aContent)], This.Steps())

		def StzWalker()
			return This.Walker()

	  #======================================================#
	 #  LEAST COMMON NUMBER WITH AN OTHER LIST OF NUMBERS   #
	#======================================================#

	def LeastCommonNumber(panOtherList)
		/* EXAMPLE

		? StzListOfNumbersQ([8, 12, 46, 102]).
			LeastCommonNumber( :With = [4, 6, 12, 89, 102, 122 ] )

		#--> 12
		*/

		if CheckingParam()
			if isList(panOtherList) and Q(panOtherList).IsWithNamedParam()
				panOtherList = panOtherList[2]
			ok
	
			if NOT Q(panOtherList).IsListOfNumbers()
				StzRaise("Incorrect pram type! panOtherList must be a list of numbers.")
			ok
		ok

		# Doing the job

		_anThisSorted_ = This.SortedInAscending()
		_anOtherSorted_ = Q(panOtherList).SortedInAscending()

		_anMain_ = []
		if len(_anThisSorted_) <= len(_anOtherSorted_)
			_anMain_  = _anThisSorted_
			_anOther_ = _anOtherSorted_
		else
			_anMain_  = _anOtherSorted_
			_anOther_ = _anThisSorted_
		ok

		_nLen_ = len(_anMain_)

		for i = 1 to _nLen_
			if Q(_anOther_).FindFirst(_anMain_[i]) > 0
				return _anMain_[i]
			ok
		next

		StzRaise("There is no Common Numbers at all between the two lists!")

		def LCN(pOtherNumber)
			return This.LeastCommonNumber(pOtherNumber)


		#-- Alternative

		def SmallesCommonNumber(pOtherNumber)
			return This.LeastCommonNumber(pOtherNumber)

		#-- Misspelled

		def LeastCommunNumber(panOtherList)
			return This.LeastCommonNumber(panOtherList)

		def SmallestCommunNumber(pOtherNumber)
			return This.LeastCommonNumber(pOtherNumber)


	  #------------------------------------------------------#
	 #  LEAST COMMON NUMBER WITH AN OTHER LIST OF NUMBERS   #
	#------------------------------------------------------#

	def GreatestCommonNumber(panOtherList)
		/* EXAMPLE

		? StzListOfNumbersQ([8, 12, 46, 102]).
			GreatestCommonNumber( :With = [4, 6, 12, 89, 102, 122 ] )

		#--> 102
		*/

		if CheckingParams()
			if isList(panOtherList) and Q(panOtherList).IsWithNamedParam()
				panOtherList = panOtherList[2]
			ok
	
			if NOT Q(panOtherList).IsListOfNumbers()
				StzRaise("Incorrect pram type! panOtherList must be a list of numbers.")
			ok
		ok

		# Doing the job

		_anThisSorted_ = This.SortedInDescending()
		_anOtherSorted_ = Q(panOtherList).SortedInDescending()

		_anMain_ = []
		if len(_anThisSorted_) <= len(_anOtherSorted_)
			_anMain_  = _anThisSorted_
			_anOther_ = _anOtherSorted_
		else
			_anMain_  = _anOtherSorted_
			_anOther_ = _anThisSorted_
		ok
		_nLen_ = len(_anMain_)

		for i = 1 to _nLen_
			if Q(_anOther_).FindFirst(_anMain_[i]) > 0
				return _anMain_[i]
			ok
		next

		StzRaise("There is no Common Numbers at all between the two lists!")

		def GCN(pOtherNumber)
			return This.GreatestCommonNumber(pOtherNumber)

	  #--------------------------------------------#
	 #  THE LEAST COMMON MULTIPLE OF THE NUMBERS  #
	#--------------------------------------------#

	def LeastCommonMultiple()
		if len( This.ListOfNumbers() ) < 2
			StzRaise("Incorrect value! The list must contain at least 2 numbers.")
		ok

		_nResult_ = 0+ StzNumberQ( This.FirstItem() ).LCM( :With = This.Section(2, :LastItem) )

		return _nResult_

		def LCM()
			return This.LeastCommonMultiple()

	  #----------------------------------------#
	 #     "ABSOLUTING' THE LIST OF NUMBERS   #
	#----------------------------------------#

	def Absolute()
		_anContent_ = This.Content()*
		_nLen_ = len(_anContent_)

		for i = 1 to _nLen_
			if _anContent_[i] < 0
				_anContent_[i] = -_anContent_[i]
			ok
		next

		def AbsoluteQ()
			This.Absolute()
			return This

	def Absoluted()
		return This.Copy().AbsoluteQ().Content()

	  #----------------------------------------#
	 #     "NEGATING' THE LIST OF NUMBERS     #
	#----------------------------------------#

	def Negate()
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		for i = 1 to _nLen_
			if _anContent_[i] > 0
				_anContent_[i] = -_anContent_[i]
			ok
		next

		def NegateQ()
			This.Negate()
			return This

	def Negated()
		return This.Copy().NegateQ().Content()

	  #---------------------------#
	 #     BASIC CALCULATIONS    #
	#---------------------------#

	def Product()
		_pPrList = This._EngineListFromContent()
		if _pPrList != NULL
			_nPrResult = StzEngineListProduct(_pPrList)
			StzEngineListFree(_pPrList)
			return _nPrResult
		ok

		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_nResult_ = 1

		for i = 1 to _nLen_
			_nResult_ *= _anContent_[i]
		next

		return _nResult_

	def Sum()
		_pSmList = This._EngineListFromContent()
		if _pSmList != NULL
			_nSmResult = StzEngineListSum(_pSmList)
			StzEngineListFree(_pSmList)
			return _nSmResult
		ok

		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)
		_nResult_ = 0

		for i = 1 to _nLen_
			_nResult_ += _anContent_[i]
		next

		return _nResult_

	def Mean()
		_pMnList = This._EngineListFromContent()
		if _pMnList != NULL
			_nMnResult = StzEngineListMean(_pMnList)
			StzEngineListFree(_pMnList)
			return _nMnResult
		ok

		return Sum() / (This.NumberOfNumbers())

		def Average()
			return Mean()

	def Median()
			_aValuesSorted_ = @sort(This.Content())
			_nLen_ = len(_aValuesSorted_)
			
			if _nLen_ % 2 = 1
				return _aValuesSorted_[ring_ceil(_nLen_/2)]
			else
				return (_aValuesSorted_[_nLen_/2] + _aValuesSorted_[(_nLen_/2)+1]) / 2
			ok

	def MeanByCoefficient(paList)
		// [ 16, 18, 20, 17 ]
		// [  4,  2,  2,  1 ]
		@i = 0
		_anContent_ = This.Content()

		_aProduct_ = []
		_nLen_ = This.NumberOfNumbers()

		for @i = 1 to _nLen_
			_aProduct_ + _anContent_[@i] * paList[@i]
		next

		_oTempList_ = new steListOfNumbers(_aProduct_)
		_oCoefList_ = new steListOfNumbers(_paList_)

		_nResult_ = _oTempList_.Sum() / _oCoefList_.Sum()

		return _nResult_

	  #---------------------------------------#
	 #     CONTAINING DIVIDABLE NUMBER BY    #
	#---------------------------------------#

	def ContainsADividableNumberBy(_n_)
		_oNumber_ = new stzNumber( This.Product() )

		if _oNumber_.IsDividableBy(_n_)
			return 1
		else
			return 0
		ok

	  #----------------------------------------------------#
	 #  GETTING THE NUMBERS DIVIDABLE BY A GIVEN NUMBER   #
	#----------------------------------------------------#

	def DividableNumbersBy(_n_)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_anResult_ = []

		for i = 1 to _nLen_
			if _anContent_[i] % 2 = 0
				_anResult_ + _anContent_[i]
			ok
		next

		return _anResult_

		def NumbersDividableBy(_n_)
			return This.DividableNumbersBy(_n_)

	  #--------------------------------------#
	 #     CLIPPING THE LIST OF NUMBERS     #
	#--------------------------------------#

	# Limits the values of the list by adjusting the numbers outside
	# the provided range (nMin, nMax). Each number lesser then nMin
	# becomes equal to nMin. And each number greater then nMax becomes
	# equal to nMax.

	def Clip(nMin, nMax)
		/*
		_o1_ = new stzListOfNumbers([1, 2, 3, 4, 5, 6, 7, 8 ])
		? _o1_.Clip(3, 5)
		// --> Should return: [ 3, 3, 3, 4, 5, 5, 5, 5, 5 ])
		*/

		_nLen_ = len(@aContent)

		for i = 1 to _nLen_
			if @aContent[i] < nMin
				@aContent[i] = nMin

			but @aContent[i] > nMax
				@aContent[i] = nMax
			ok
		next

		def ClipQ(nMin, nMax)
			return This.ClipQRT(nMin, nMax, pcReturnType)

		def ClipQRT(nMin, nMax, pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType, [ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Clip(nMin, nMax) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Clip(nMin, nMax) )

			other
				StzRaise("Unsupported return type!")
			off

	  #-----------------------------------------#
	 #     REPLACING A SECTION OF THE LIST     #
	#-----------------------------------------#

	def ReplaceSectionWith(_n1_, _n2_, _n_)
		_nLen_ = len(@aContent)
		for i = 1 to _nLen_
			if i >= _n1_ and i <= _n2_
				@aContent[i] = _n_
			ok
		next

		#< @FunctionFluentForms

		def ReplaceSectionWithQ(_n1_, _n2_, _n_)
			return This.ReplaceSectionWithQRT(_n1_, _n2_, _n_, :stzList)

		def ReplaceSectionWithQRT(_n1_, _n2_, _n_, pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType, [ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.ReplaceSectionWith(_n1_, _n2_, _n_) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.ReplaceSectionWith(_n1_, _n2_, _n_) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		def ReplaceNumbersInSectionWith(_n1_, _n2_, _n_)
			This.ReplaceSectionWith(_n1_, _n2_, _n_)

	  #----------------------------#
	 #     CUMULATING NUMBERS     #
	#----------------------------#

	def Cumulate()
		_aResult_ = []
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		for i = 3 to _nLen_
			_anContent_[i] += _anContent_[i-1]
		next
			
		This.UpdateWith(_anContent_)


		def CumulateQ()
			return This.CumulateQRT()

		def CumulateQRT()
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType, [ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.Cumulate() )

			on :stzListOfNumbers
				return new stzList( This.Cumulate(_n1_) )

			other
				StzRaise("Unsupported return type!")
			off

	def Cumulated()
		_anResult_ = This.Copy().CumulateQ().Content()
		return _anResult_

	  #-------------------------------------------------------------#
	 #  GETTING ONLY UNICODE NUMBERS AMONG THE NUMBER IN THE LIST  #
	#-------------------------------------------------------------#

	def OnlyUnicodes()
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			_n_ = _anContent_[i]

			if IsUnicodeNumber(_n_)
				_aResult_ + _n_
			ok
		next

		return _aResult_

		#< @FunctionFluentForm

		def OnlyUnicodesQ()
			return This.CumulateQRT(:stzList)

		def OnlyUnicodesQRT(pcReturnType)
			if isList(pcReturnType) and IsOneOfTheseNamedParamsList(pcReturnType, [ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok
	
			switch pcReturnType
			on :stzList
				return new stzList( This.OnlyUnicodes() )
	
			on :stzListOfNumbers
				return new stzList( This.OnlyUnicodes() )
	
			other
				StzRaise("Unsupported return type!")
			off

		#>

	  #========================================#
	 #     ADDING A NUMBER TO EACH NUMBER     #
	#========================================#

	def AddToEach(_n_)
		
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)
		if _nLen_ = 0
			StzRaise("Can't add anything! Because the list is empty.")
		ok

		_anResult_ = []

		for i = 1 to _nLen_
			_anResult_ + (_anContent_[i] + _n_)
		next

		This.Update(_anResult_)

		def AddToEachQ(_n_)
			This.AddToEach(_n_)
			return This

		def AddToEachNumber(_n_)
			This.AddToEach(_n_)

			def AddToEachNumberQ(_n_)
				return This.AddToEachQ(_n_)

		def AddToEveryNumber(_n_)
			This.AddToEach(_n_)

			def AddToEveryNumberQ(_n_)
				return This.AddToEachQ(_n_)

	def AddedToEach(_n_)
		_anResult_ = This.Copy().AddToEachQ(_n_).Content()
		return _anResult_

		def AddedToEachNumber(_n_)
			return This.AddedToEach(_n_)

		def AddedToEveryNumber(_n_)
			return This.AddedToEach(_n_)

	  #------------------------------------------------#
	 #     SubStructING A NUMBER FROM EACH NUMBER     #
	#------------------------------------------------#

	def SubStructFromEach(_n_)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)
		if _nLen_ = 0
			StzRaise("Can't substruct anything! Because the list is empty.")
		ok

		_anResult_ = []

		for i = 1 to _nLen_
			_anResult_ + (_anContent_[i] - _n_)
		next

		This.Update(_anResult_)

		#< @FunctionFluentForm

		def SubStructFromEachQ(_n_)
			This.SubStructFromEach(_n_)
			return This

		#>

		#< @FunctionAlternativeForms

		def SubStructFromEachNumber(_n_)
			This.SubStructFromEach(_n_)

			def SubStructFromEachNumberQ(_n_)
				return This.SubStructFromEachQ(_n_)

		#>

		#< @FunctionAlternativeForms

		def SubstractFromEach(_n_)
			This.SubStructFromEach(_n_)

		def SubStractFromEachNumber(_n_)
			This.SubStructFromEach(_n_)

			def SubStractFromEachNumberQ(_n_)
				return This.SubStructFromEachQ(_n_)

		#--

		def SubtractFromEach(_n_)
			This.SubStructFromEach(_n_)

		def SubtractFromEachNumber(_n_)
			This.SubStructFromEach(_n_)

			def SubtractFromEachNumberQ(_n_)
				return This.SubStructFromEachQ(_n_)

		#--

		def SubtructFromEach(_n_)
			This.SubStructFromEach(_n_)

		def SubtructFromEachNumber(_n_)
			This.SubStructFromEach(_n_)

			def SubtructFromEachNumberQ(_n_)
				return This.SubStructFromEachQ(_n_)

		#>

	def SubStructedFromEach(_n_)
		_anResult_ = This.Copy().SubStructFromEachQ(_n_).Content()
		return _anResult_

		#< @FunctionAlternativeForm

		def SubStructedFromEachNumber(_n_)
			return This.SubStructedFromEach(_n_)

		def SubStructedFromEveryNumber(_n_)
			return This.SubStructedFromEach(_n_)

		#>

		#< @FunctionAlternativeForms

		def SubstractedFromEach(_n_)
			return This.SubStructFromEach(_n_)

		def SubstractedFromEachNumber(_n_)
			return This.SubStructedFromEach(_n_)

		def SubstractedFromEveryNumber(_n_)
			return This.SubStructedFromEach(_n_)

		#--

		def SubtractedFromEach(_n_)
			return This.SubStructFromEach(_n_)

		def SubtractedFromEachNumber(_n_)
			return This.SubStructedFromEach(_n_)

		def SubtractedFromEveryNumber(_n_)
			return This.SubStructedFromEach(_n_)

		#--

		def SubtructedFromEach(_n_)
			return This.SubStructFromEach(_n_)

		def SubtructedFromEachNumber(_n_)
			return This.SubStructedFromEach(_n_)

		def SubtructedFromEveryNumber(_n_)
			return This.SubStructedFromEach(_n_)

		#>

	  #---------------------------------------------#
	 #     MULTIPLYING EACH NUMBER BY A NUMBER     #
	#---------------------------------------------#

	def MultiplyEachBy(_n_)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)
		if _nLen_ = 0
			StzRaise("Can't multiply anything! Because the list is empty.")
		ok

		_anResult_ = []

		for i = 1 to _nLen_
			_anResult_ + (_anContent_[i] * _n_)
		next

		This.Update(_anResult_)

		#< @FunctionFluentForm

		def MultiplyEachByQ(_n_)
			This.MultiplyEachBy(_n_)
			return This

		#>

		#< @FunctionAlternativeForms

		def MultiplyEachNumberBy(_n_)
			This.MultiplyEachBy(_n_)

			def MultiplyEachNumberByQ(_n_)
				return This.MultiplyEachByQ(_n_)

		def MultiplyEveryNumberBy(_n_)
			This.MultiplyEachBy(_n_)

			def MultiplyEveryNumberByQ(_n_)
				return This.MultiplyEachByQ(_n_)
 
		#>

	def EachMultipliedBy(_n_)
		_anResult_ = This.Copy().MultiplyEachByQ(_n_).Content()
		return _anResult_

		def EachNumberMultipliedBy(_n_)
			return This.EachMultipliedBy(_n_)

		def EveryNumberMultipliedBy(_n_)
			return This.EachMultipliedBy(_n_)

	  #------------------------------------------#
	 #     DIVIDING EACH NUMBER BY A NUMBER     # 
	#------------------------------------------#

	def DivideEachBy(_n_)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)
		if _nLen_ = 0
			StzRaise("Can't divide anything! Because the list is empty.")
		ok

		_anResult_ = []

		for i = 1 to _nLen_
			_anResult_ + (_anContent_[i] / _n_)
		next

		This.Update(_anResult_)

		#< @FunctionFluentForm

		def DivideEachByQ(_n_)
			This.DivideEachBy(_n_)
			return This

		#>

		#< @FunctionAlternativeForms

		def DivideEachNumberBy(_n_)
			This.DivideEachBy(_n_)

			def DivideEachNumberByQ(_n_)
				return This.DivideEachByQ(_n_)

		def DivideEveryNumberBy(_n_)
			This.DivideEachBy(_n_)

			def DivideEveryNumberByQ(_n_)
				return This.DivideEachByQ(_n_)

		#>

	def EachDividedBy(_n_)
		_anResult_ = This.Copy().DivideEachByQ(_n_).Content()
		return _anResult_

		def EachNumberDividedBy(_n_)
			return This.EachDividedBy(_n_)

		def EveryNumberDividedBy(_n_)
			return This.EachDividedBy(_n_)

	  #====================================#
	 #   ADDING MANY NUMBERS ONE BY ONE   #
	#====================================#

	def AddManyOneByOne(panNumbers)

		if NOT ( isList(panNumbers) and Q(panNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		_anContent_ = This.Content()
		_nLen1_ = This.NumberOfNumbers()
		if _nLen1_ = 0
			StzRaise("Can't add anything! Because the list is empty.")
		ok

		_nLen2_ = len(panNumbers)

		_nLen_ = _nLen1_
		if _nLen2_ < _nLen1_
			_nLen_ = _nLen2_
		ok

		_anResult_ = []

		for i = 1 to _nLen_
			_nSum_ = _anContent_[i] + panNumbers[i]
			_anResult_ + _nSum_
		next

		This.Update(_anResult_)

		#< @FunctionFluentForm

		def AddManyOneByOneQ(panNumbers)
			This.AddManyOneByOne(panNumbers)
			return This

		#>

		#< @FunctionAlternativeForm

		def AddManyNumbersOneByOne(panNumbers)
			This.AddManyOneByOne(panNumbers)

			def AddManyNumbersOneByOneQ(panNumbers)
				return This.AddManyOneByOneQ(panNumbers)

		#>

	def ManyAddOneByOne(panNumbers)
		_anResult_ = This.Copy().AddManyOneByOneQ(panNumbers).Content()
		return _anResult_

		def ManyNumbersAddedOneByOne(panNumbers)
			return This.ManyAddOneByOne(panNumbers)

	  #------------------------------------------#
	 #   SubStructING MANY NUMBERS ONE BY ONE   #
	#------------------------------------------#

	def SubStructManyOneByOne(panNumbers)

		if NOT ( isList(panNumbers) and Q(panNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		_anContent_ = This.Content()
		_nLen1_ = This.NumberOfNumbers()
		if _nLen1_ = 0
			StzRaise("Can't substruct anything! Because the list is empty.")
		ok

		_nLen2_ = len(panNumbers)

		_nLen_ = _nLen1_
		if _nLen2_ < _nLen1_
			_nLen_ = _nLen2_
		ok

		_anResult_ = []

		for i = 1 to _nLen_
			_nDif_ = _anContent_[i] - panNumbers[i]
			_anResult_ + _nDif_
		next

		This.Update(_anResult_)

		#< @FunctionFluentForm

		def SubStructManyOneByOneQ(panNumbers)
			This.SubStructManyOneByOne(panNumbers)
			return This

		#>

		#< @FunctionAlternativeForm

		def SubStructManyNumbersOneByOne(panNumbers)
			This.SubStructManyOneByOne(panNumbers)

			def SubStructManyNumbersOneByOneQ(panNumbers)
				return This.SubStructManyOneByOneQ(panNumbers)

		#>

	def ManySubStructedOneByOne(panNumbers)
		_aResult_ = This.Copy().SubStructManyOneByOneQ(panNumbers).Content()
		return _aResult_

		def ManyNumbersSubStructedOneByOne(panNumbers)
			return This.ManyAddOneByOne(panNumbers)


	  #----------------------------------------------------------------------#
	 #   MULTIPLYING THE NUMBERS OF THE LIST WITH MANY NUMBERS ONE BY ONE   #
	#----------------------------------------------------------------------#

	def MultiplyWithManyOneByOne(panNumbers)

		if NOT ( isList(panNumbers) and Q(panNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		_anContent_ = This.Content()
		_nLen1_ = This.NumberOfNumbers()
		if _nLen1_ = 0
			StzRaise("Can't multiply anything! Because the list is empty.")
		ok

		_nLen2_ = len(panNumbers)

		_nLen_ = _nLen1_
		if _nLen2_ < _nLen1_
			_nLen_ = _nLen2_
		ok

		_anResult_ = []

		for i = 1 to _nLen_
			_nProd_ = _anContent_[i] * panNumbers[i]
			_anResult_ + _nProd_
		next

		This.Update(_anResult_)

		#< @FunctionFluentForm

		def MultiplyWithManyOneByOneQ(panNumbers)
			This.MultiplyWithManyOneByOne(panNumbers)
			return This

		#>

		#< @FunctionAlternativeForms

		def MultiplyByManyOneByOne(panNumbers)
			return This.MultiplyWithManyOneByOne(panNumbers)

			def MultiplyByManyOneByOneQ(panNumbers)
				return This.MultiplyWithManyOneByOneQ(panNumbers)

		def MultiplyByManyNumbersOneByOne(panNumbers)
			return This.MultiplyWithManyOneByOne(panNumbers)

			def MultiplyByManyNumbersOneByOneQ(panNumbers)
				return This.MultiplyWithManyOneByOneQ(panNumbers)

		def MultiplyWithManyNumbersOneByOne(panNumbers)
			return This.MultiplyWithManyOneByOne(panNumbers)

			def MultiplyWithManyNumbersOneByOneQ(panNumbers)
				return This.MultiplyWithManyOneByOneQ(panNumbers)

		#>

	def MultipliedWithManyOneByOne(panNumbers)
		_anResult_ = This.Copy().MultiplyWithManyOneByOneQ(panNumbers).Content()
		return _anResult_

		#< @FunctionAlternativeForms

		def MultipliedByManyOneByOne(panNumbers)
			return This.MultipliedWithManyOneByOne(panNumbers)

		def MultipliedByManyNumbersOneByOne(panNumbers)
			return This.MultipliedWithManyOneByOne(panNumbers)

		def MultipliedWithManyNumbersOneByOne(panNumbers)
			return This.MultipliedWithManyOneByOne(panNumbers)

		#>

	  #-------------------------------------------------------------------#
	 #   DEVIDING THE NUMBERS OF THE LIST WITH MANY NUMBERS ONE BY ONE   #
	#-------------------------------------------------------------------#

	def DivideByManyOneByOne(panNumbers)

		if NOT ( isList(panNumbers) and Q(panNumbers).IsListOfNumbers() )
			StzRaise("Incorrect param type! You must provide a list of numbers.")
		ok

		_anContent_ = This.Content()
		_nLen1_ = This.NumberOfNumbers()
		if _nLen1_ = 0
			StzRaise("Can't divide anything! Because the list is empty.")
		ok

		_nLen2_ = len(panNumbers)

		_nLen_ = _nLen1_
		if _nLen2_ < _nLen1_
			_nLen_ = _nLen2_
		ok

		_anResult_ = []

		for i = 1 to _nLen_
			_nDiv_ = _anContent_[i] / panNumbers[i]
			_anResult_ + _nDiv_
		next

		This.Update(_anResult_)

		def DivideByManyOneByOneQ(panNumbers)
			This.DivideByManyOneByOne(panNumbers)
			return This

		#TODO
		# Add alternatives

	def DividedByManyOneByOne(panNumbers)
		_anResult_ = This.Copy().DivideByManyOneByOneQ(panNumbers).Content()
		return _anResult_

		#TODO
		# Add alternatives

	  #===================================================#
	 #   ADDING NUMBER TO EACH UNDER A GIVEN CONDITION   #
	#===================================================#

	def AddToEachW(_n_, pcCondition)

		# Checking params

		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
	
			if isList(pcCondition) and Q(pcCondition).IsWhereNamedParam()
				pcCondition = pcCondition[2]
			ok
	
			if NOT isString(pcCondition)
				StzRaise("Incorrect param type! pcCondition must be a string.")
			ok
		ok

		# Doing the job

		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)
		if _nLen_ = 0
			StzRaise("Can't add anything! Because the list is empty.")
		ok

		_oCCode_ = StzCCodeQ(pcCondition)
		_aSection_ = _oCCode_.ExecutableSection()

		_nStart_ = _aSection_[1]

		_nEnd_ = _aSection_[2]
		if isString(_nEnd_) and _nEnd_ = :Last
			_nEnd_ = _nLen_
		ok

		_cCode_ = _oCCode_.Transpiled()
		_cCode_ = 'bOk = (' + _cCode_ + ')'

		_anResult_ = []

		for @i = _nStart_ to _nEnd_
			eval(_cCode_)
			if bOk
				_anResult_ + (_anContent_[@i] + _n_)
			ok
		next

		This.Update( _anResult_ )

		#< @FunctionFluentForm

		def AddToEachWQ(_n_)
			This.AddToEachW(_n_)
			return This

		#>

		#TODO
		# Add alternatives

	def AddedToEachW(_n_)
		_aResult_ = This.Copy().AddToEachWQ(_n_).Content()
		return _aResult_

		#TODO
		# Add alternatives

	  #--------------------------------------------------------#
	 #   SubStruct NUMBER FROM EACH UNDER A GIVEN CONDITION   #
	#--------------------------------------------------------#

	def SubStructFromEachW(_n_, pcCondition)
		This.AddToEachW(-_n_, pcCondition)

		def SubStructFromEachWQ(_n_)
			This.SubStructFromEachW(_n_)
			return This

		#TODO
		# Add alternatives

	def SubStructedFromEachW(_n_)
		_aResult_ = This.Copy().SubStructFromEachWQ(_n_).Content()
		return _aResult_
	
		#TODO
		# Add alternatives

	  #--------------------------------------------------------------------#
	 #   MULTIPLYING NUMBERS BY AN OTHER NUMBER UNDER A GIVEN CONDITION   #
	#--------------------------------------------------------------------#

	def MultiplyEachWithW(_n_, pcCondition)

		# Checking params

		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
	
			if isList(pcCondition) and Q(pcCondition).IsWhereNamedParam()
				pcCondition = pcCondition[2]
			ok
	
			if NOT isString(pcCondition)
				StzRaise("Incorrect param type! pcCondition must be a string.")
			ok
		ok

		# Doing the job

		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)
		if _nLen_ = 0
			StzRaise("Can't multiply anything! Because the list is empty.")
		ok

		_oCCode_ = StzCCodeQ(pcCondition)
		_aSection_ = _oCCode_.ExecutableSection()

		_nStart_ = _aSection_[1]

		_nEnd_ = _aSection_[2]
		if isString(_nEnd_) and _nEnd_ = :Last
			_nEnd_ = _nLen_
		ok

		_cCode_ = _oCCode_.Transpiled()
		_cCode_ = 'bOk = (' + _cCode_ + ')'

		_anResult_ = []

		for @i = _nStart_ to _nEnd_
			eval(_cCode_)
			if bOk
				_anResult_ + (_anContent_[@i] * _n_)
			ok
		next

		This.Update( _anResult_ )

		#< @FunctionFluentForm

		def MultiplyEachWithWQ(_n_)
			This.MultiplyEachWithW(_n_)
			return This

		#>

		#< @FunctionAlternativeForm

		def MultiplyEachByW()
			This.MultiplyEachWithW(_n_, pcCondition)

			def MultiplyEachByWQ()
				This.MultiplyEachByW()
				return This

		#>

		#TODO
		# Add other alternatives

	def EachMultipliedWithW(_n_)
		_aResult_ = This.Copy().MultiplyEachWithWQ(_n_).Content()
		return _aResult_

		def EachMultipliedByW(_n_)
			return This.EachMultipliedWithW(_n_)

		#TODO
		# Add other alternatives

	  #-------------------------------------------------------------------#
	 #   DIVIDE EACH NUMBER BY AN OTHER NUMBER UNDER A GIVEN CONDITION   #
	#-------------------------------------------------------------------#

	def DivideEachWithW(_n_, pcCondition)
		This.MultiplyEachWithW( 1/_n_, pcCondition )

		def DivideEachWithWQ(_n_)
			This.DivideEachWithW(_n_)
			return This

		def DivideEachByW(_n_, pcCondition)
			This.DivideEachWithW(_n_, pcCondition)

		#TODO
		# Add alternatives

	def EachDividedWithW(_n_)
		_aResult_ = This.Copy().DivideEachWithWQ(_n_).Content()
		return _aResult_

		def EachDividedByW(_n_)
			return This.EachDividedWithW(_n_)
	
		#TODO
		# Add alternatives

	  #=====================================================#
	 #     UPDATING THE LIST WITH A NEW LIST OF NUMBERS    #
	#=====================================================#

	def Update(panNewListOfNumbers)

		if CheckingParams() = 1
			if isList(panNewListOfNumbers) and Q(panNewListOfNumbers).IsWithOrByOrUsingNamedParam()
				panNewListOfNumbers = panNewListOfNumbers[2]
			ok
	
			if NOT ( isList(panNewListOfNumbers) and
				 Q(panNewListOfNumbers).IsListOfNumbers()
			       )
	
				StzRaise("Incorrect param type!")
			ok
		ok

		@aContent = panNewListOfNumbers

		if KeepingHisto() = 1
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		#< @FunctionFluentForm

		def UpdateQ(panNewListOfNumbers)
			This.Update(panNewListOfNumbers)
			return This

		#>

		#< @FunctionAlternativeForms

		def UpdateWith(panNewListOfNumbers)
			This.Update(panNewListOfNumbers)

			def UpdateWithQ(panNewListOfNumbers)
				return This.UpdateQ(panNewListOfNumbers)
	
		def UpdateBy(panNewListOfNumbers)
			This.Update(panNewListOfNumbers)

			def UpdateByQ(panNewListOfNumbers)
				return This.UpdateQ(panNewListOfNumbers)

		def UpdateUsing(panNewListOfNumbers)
			This.Update(panNewListOfNumbers)

			def UpdateUsingQ(panNewListOfNumbers)
				return This.UpdateQ(panNewListOfNumbers)

		#>

	def Updated(panNewListOfNumbers)
		return panNewListOfNumbers

		#< @FunctionAlternativeForms

		def UpdatedWith(panNewListOfNumbers)
			return This.Updated(panNewListOfNumbers)

		def UpdatedBy(panNewListOfNumbers)
			return This.Updated(panNewListOfNumbers)

		def UpdatedUsing(panNewListOfNumbers)
			return This.Updated(panNewListOfNumbers)

		#>

	  #-----------------------------------------------------------#
	 #     REPLACING A NUMBER AT A GIVEN POSITION IN THE LIST    #
	#-----------------------------------------------------------#

	def ReplaceNumberAtPosition(_n_, pnNewNumber)

		if NOT isNumber(_n_)
			StzRaise("Incorrect param! n must be a number.")
		ok

		if isList(pnNewNumber) and Q(pnNewNumber).IsWithOrByNamedParam()
			pnNewNumber = pnNewNumber[2]
		ok

		if NOT isNumber(pnNewNumber)
			StzRaise("Incorrect param! pnNewNumber must be a number.")
		ok

		_anContent_ = This.Content()
		_anContent_[_n_] = pnNewNumber
		This.UpdateWith(_anContent_)


	  #---------------------------------------#
	 #     REVERSING THE LIST OF NUMBERS     #
	#---------------------------------------#

	def Reverse()
		_aResult_ = This.ToStzList().Reversed()
		This.UpdateWith( _aResult_ )

		def ReverseQ()
			This.Reverse()
			return This

		def ReverseNumbers()
			This.Reverse()

			def ReverseNumbersQ()
				This.ReverseNumbers()
				return This

	def Reversed()
		_aResult_ = This.Copy().ReverseQ().Content()

		return _aResult_

		def NumbersReversed()
			return This.Reversed()

	  #===========#
	 #   MISC.   #
	#===========#

	def ToSections()
		/* EXAMPLE

		_o1_ = new stzListOfNumbers([ 3, 7, 12, 15 ])
		
		? @@( _o1_.ToSections() ) # Or Sectioned()
		#--> [ [ 1, 3 ], [ 4, 7 ], [ 8, 12 ], [ 13, 15 ] ]
		*/

		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)
		if _nLen_ < 2
			return []
		ok

		_oChain_ = new stzList(_anContent_)

		_anSorted_ = _oChain_.Sorted()
		_aSections_ = []
		_n_ = 0

		_n1_ = 1

		if _anSorted_[1] = 1
			del(_anSorted_, 1)
			_nLen_--
		ok

		for i = 1 to _nLen_
			
			_n2_ = _anSorted_[i]
			_aSections_ + [ _n1_, _n2_ ]
			_n1_ = _anSorted_[i] + 1

		next

		return _aSections_

		def Sectioned()
			return This.ToSections()

	def ContiguousToSections()
		_anNumbers_ = @aContent
		_nLen_ = len(_anNumbers_)

		_aResult_ = []
		_aSection_ = [] + _anNumbers_[1]

		_anNumbers_ + 0 # A tactical addition to let the algorithm
			      # deel with the last section

		for i = 2 to _nLen_ + 1

			if _anNumbers_[i] = _anNumbers_[i-1] + 1
				// Do nothing

			else
				_aSection_ + _anNumbers_[i-1]
				_aResult_ + _aSection_
				_aSection_ = [] + _anNumbers_[i]

			ok	
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def ContiguousItemsToSections()
			return This.ContiguousToSections()

		def AdjacentToSections()
			return This.ContiguousToSections()

		def AdjuscentItemsToSections()
			return This.ContiguousToSections()

		#--

		def ContigItemsToSections()
			return This.ContiguousToSections()

		def ContigToSections()
			return This.ContiguousToSections()

		#>

	def IsStzListOfNumbers()
		return 1

	def stzType()
		return :stzListOfNumbers

		def ClassName()
			return This.stzType()

	#-----

	def ToStzListOfChars()
		return new stzListOfChars( This.Content() )

	def NumberOfNumbers()
		return len( This.Content() )

	def IsContiguous()
		_nLen_ = This.NumberOfNumbers()

		if _nLen_ = 0 or _nLen_ = 1
			return 0
		ok

		_aContent_ = This.Content()

		if _nLen_ = 2
			if _aContent_[1] = _aContent_[2]
				return 0
			ok
		ok

		# Case nLen > 2 (3 and more)

		_n1_ = _aContent_[1]
		_n2_ = _aContent_[2]

		_bResult_ = 1
		# Loop must start at i=2 -- starting at i=3 silently skipped
		# the gap between positions [1] and [2], so e.g. [1, 5, 6]
		# wrongly returned contiguous (1->5 jump never checked, only
		# the direction was set by `if n1 < n2`).
		if _n1_ < _n2_
			for i = 2 to _nLen_
				if _aContent_[i] != _aContent_[i-1] + 1
					_bResult_ = 0
					exit
				ok
			next
		else // n1 > n2
			for i = 2 to _nLen_
				if _aContent_[i] != _aContent_[i-1] - 1
					_bResult_ = 0
					exit
				ok
			next

		ok

		return _bResult_

		def IsContinuous()
			return This.IsContiguous()

	  #=========================================#
	 #  GETTING A RANDOM NUMBER FROM THE LIST  #
	#=========================================#

	def ARandomNumber()
		_nRandom_  = ARandomNumberBetween(1, This.NumberOfNumbers())
		_anResult_ = This.Content()[_nRandom_]

		return _anResult_

		def ANumber()
			return ARandomNumber()

		def AnyRandomNumber()
			return ARandomNumber()

		def AnyNumber()
			return ARandomNumber()

	#-- Z/EXTENDED FORM

	def ARandomNumberZ()
		_nRandom_  = ARandomNumberBetween(1, This.NumberOfNumbers())
		_aResult_ = [ This.Content()[_nRandom_], _nRandom_ ]

		return _aResult_

	  #------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LIST LESS THAN A GIVEN NUMBER  #
	#------------------------------------------------------------------#

	def ANumberLessThan(_nNumber_)
		_nResult_ = This.NumbersLessThanQRT(_nNumber_, :stzListOfNumbers).ARandomNumber()
		return _nResult_

		#< @FunctionAlternativeForms

		def AnyNumberLessThan(_nNumber_)
			return This.ANumberLessThan(_nNumber_)

		def NumberLessThan(_nNumber_)
			return This.ANumberLessThan(_nNumber_)

		#--

		def ARandomNumberLessThan(_nNumber_)
			return This.ANumberLessThan(_nNumber_)

		def RandomNumberLessThan(_nNumber_)
			return This.ANumberLessThan(_nNumber_)

		#==

		def ANumberSmallerThan(_nNumber_)
			return This.ANumberLessThan(_nNumber_)

		def AnyNumberSmallerThan(_nNumber_)
			return This.ANumberLessThan(_nNumber_)

		def NumberSmallerThan(_nNumber_)
			return This.ANumberLessThan(_nNumber_)

		#--

		def ARandomNumberSmallerThan(_nNumber_)
			return This.ANumberLessThan(_nNumber_)

		def RandomNumberSmallerThan(_nNumber_)
			return This.ANumberLessThan(_nNumber_)

		#>

	#-- Z/EXTENDED FORM

	def ANumberLessThanZ(_nNumber_)
		_aResult_ = This.NumbersLessThanQRT(_nNumber_, :stzListOfNumbers).ARandomNumberZ()

		return _aResult_

		#< @FunctionAlternativeForms

		def AnyNumberLessThanZ(_nNumber_)
			return This.ANumberLessThanZ(_nNumber_)

		def NumberLessThanZ(_nNumber_)
			return This.ANumberLessThanZ(_nNumber_)

		#--

		def ARandomNumberLessThanZ(_nNumber_)
			return This.ANumberLessThanZ(_nNumber_)

		def RandomNumberLessThanZ(_nNumber_)
			return This.ANumberLessThanZ(_nNumber_)

		#==

		def ANumberSmallerThanZ(_nNumber_)
			return This.ANumberLessThanZ(_nNumber_)

		def AnyNumberSmallerThanZ(_nNumber_)
			return This.ANumberLessThanZ(_nNumber_)

		def NumberSmallerThanZ(_nNumber_)
			return This.ANumberLessThanZ(_nNumber_)

		#--

		def ARandomNumberSmallerThanZ(_nNumber_)
			return This.ANumberLessThanZ(_nNumber_)

		def RandomNumberSmallerThanZ(_nNumber_)
			return This.ANumberLessThanZ(_nNumber_)

		#>

	  #---------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LIST GREATER THAN A GIVEN NUMBER  #
	#---------------------------------------------------------------------#

	def ANumberGreaterThan(_nNumber_)
		_nResult_ = This.NumbersGreaterThanQRT(_nNumber_, :stzListOfNumbers).ARandomNumber()
		return _nResult_

		#< @FunctionAlternativeForms

		def AnyNumberGreaterThan(_nNumber_)
			return This.ANumberGreaterThan(_nNumber_)

		def NumberGreaterThan(_nNumber_)
			return This.ANumberGreaterThan(_nNumber_)

		#--

		def ARandomNumberGreaterThan(_nNumber_)
			return This.ANumberGreaterThan(_nNumber_)

		def RandomNumberGreaterThan(_nNumber_)
			return This.ANumberGreaterThan(_nNumber_)

		#--

		def ANumberLargerThan(_nNumber_)
			return This.ANumberGreaterThan(_nNumber_)

		def AnyNumberLargerThan(_nNumber_)
			return This.ANumberGreaterThan(_nNumber_)

		def NumberLargerThan(_nNumber_)
			return This.ANumberGreaterThan(_nNumber_)

		def ARandomNumberLargerThan(_nNumber_)
			return This.ANumberGreaterThan(_nNumber_)

		def RandomNumberLargerThan(_nNumber_)
			return This.ANumberGreaterThan(_nNumber_)

		#--

		def AnyNumberMoreThan(_nNumber_)
			return This.ANumberGreaterThan(_nNumber_)

		def NumberMoreThan(_nNumber_)
			return This.ANumberGreaterThan(_nNumber_)

		def ARandomNumberMoreThan(_nNumber_)
			return This.ANumberGreaterThan(_nNumber_)

		def RandomNumberMoreThan(_nNumber_)
			return This.ANumberGreaterThan(_nNumber_)

		#>

	#-- Z/EXTENDED FORM

	def ANumberGreaterThanZ(_nNumber_)
		_aResult_ = This.NumbersGreaterThanQRT(_nNumber_, :stzListOfNumbers).ARandomNumberZ()
		return _aResult_

		#< @FunctionAlternativeForms

		def AnyNumberGreaterThanZ(_nNumber_)
			return This.ANumberGreaterThanZ(_nNumber_)

		def NumberGreaterThanZ(_nNumber_)
			return This.ANumberGreaterThanZ(_nNumber_)

		#--

		def ARandomNumberGreaterThanZ(_nNumber_)
			return This.ANumberGreaterThanZ(_nNumber_)

		def RandomNumberGreaterThanZ(_nNumber_)
			return This.ANumberGreaterThanZ(_nNumber_)

		#--

		def ANumberLargerThanZ(_nNumber_)
			return This.ANumberGreaterThanZ(_nNumber_)

		def AnyNumberLargerThanZ(_nNumber_)
			return This.ANumberGreaterThanZ(_nNumber_)

		def NumberLargerThanZ(_nNumber_)
			return This.ANumberGreaterThanZ(_nNumber_)

		def ARandomNumberLargerThanZ(_nNumber_)
			return This.ANumberGreaterThanZ(_nNumber_)

		def RandomNumberLargerThanZ(_nNumber_)
			return This.ANumberGreaterThanZ(_nNumber_)

		#--

		def AnyNumberMoreThanZ(_nNumber_)
			return This.ANumberGreaterThanZ(_nNumber_)

		def NumberMoreThanZ(_nNumber_)
			return This.ANumberGreaterThanZ(_nNumber_)

		def ARandomNumberMoreThanZ(_nNumber_)
			return This.ANumberGreaterThanZ(_nNumber_)

		def RandomNumberMoreThanZ(_nNumber_)
			return This.ANumberGreaterThanZ(_nNumber_)

		#>

	  #------------------------------------------------------------------#
	 #  GETTING ANY NUMBER BEFORE OR AFTER A GIVEN NUMBER (OTHER THAN)  #
	#==================================================================#

	def AnyNumberBeforeOrAfter(_n_) # Or AnyNumberOtherThan()
		if isList(_n_) and Q(_n_).IsPositionNamedParam()
			_n_ = _n_[2]
		ok

		_nPos_ = 0
		if random(1) = 0
			_nPos_ = This.AnyNumberBefore(_n_)

		else
			_nPos_ = This.AnyNumberAfter(_n_)
		ok

		_nResult_ = This.Item(_nPos_)
		return _nResult_

		#< @FunctionAlternativeForms

		def AnyNumberAfterOrBefore(_n_)
			return This.AnyNumberBeforeOrAfter(_n_)

		def ANumberBeforeOrAfter(_n_)
			return This.AnyNumberBeforeOrAfter(_n_)

		def ANumberAfterOrBefore(_n_)
			return This.AnyNumberBeforeOrAfter(_n_)

		def NumberBeforeOrAfter(_n_)
			return This.AnyNumberBeforeOrAfter(_n_)

		def NumberAfterOrBefore(_n_)
			return This.AnyNumberBeforeOrAfter(_n_)

		#--

		def AnyNumberOtherThan(_n_)
			return This.AnyNumberBeforeOrAfter(_n_)

		def ANumberOtherThan(_n_)
			return This.AnyNumberBeforeOrAfter(_n_)

		def NumberOtherThan(_n_)
			return This.AnyNumberBeforeOrAfter(_n_)

		#--

		def ARandoomNumberAfterOrBefore(_n_)
			return This.AnyNumberBeforeOrAfter(_n_)

		def RandomNumberBeforeOrAfter(_n_)
			return This.AnyNumberBeforeOrAfter(_n_)

		def RandomNumberAfterOrBefore(_n_)
			return This.AnyNumberBeforeOrAfter(_n_)

		def ARandomNumberOtherThan(_n_)
			return This.AnyNumberBeforeOrAfter(_n_)

		def RandomNumberOtherThan(_n_)
			return This.AnyNumberBeforeOrAfter(_n_)

		#--
	
		def ANumberDifferentThan(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		def ANumberDifferentFrom(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		#--
	
		def NumberDifferentThan(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		def NumberDifferentFrom(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		#--
	
		def AnyNumberDifferentThan(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		def AnyNumberDifferentFrom(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		#--

		def ARandomNumberDifferentThan(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		def ARandomNumberDifferentFrom(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		def RandomNumberDifferentThan(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)
	
		def RandomNumberDifferentFrom(pcChar)
			return This.AnyNumberBeforeOrAfter(pcChar)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberBeforeOrAfterZ(_n_) # Or AnyNumberOtherThan()
		if isList(_n_) and Q(_n_).IsPositionNamedParam()
			_n_ = _n_[2]
		ok

		_nPos_ = 0
		if random(1) = 0
			_nPos_ = This.AnyNumberBefore(_n_)

		else
			_nPos_ = This.AnyNumberAfter(_n_)
		ok

		_aResult_ = [ This.Item(_nPos_), _nPos_ ]
		return _aResult_

		#< @FunctionAlternativeForms

		def AnyNumberAfterOrBeforeZ(_n_)
			return This.AnyNumberBeforeOrAfterZ(_n_)

		def ANumberBeforeOrAfterZ(_n_)
			return This.AnyNumberBeforeOrAfterZ(_n_)

		def ANumberAfterOrBeforeZ(_n_)
			return This.AnyNumberBeforeOrAfterZ(_n_)

		def NumberBeforeOrAfterZ(_n_)
			return This.AnyNumberBeforeOrAfterZ(_n_)

		def NumberAfterOrBeforeZ(_n_)
			return This.AnyNumberBeforeOrAfterZ(_n_)

		#--

		def AnyNumberOtherThanZ(_n_)
			return This.AnyNumberBeforeOrAfterZ(_n_)

		def ANumberOtherThanZ(_n_)
			return This.AnyNumberBeforeOrAfterZ(_n_)

		def NumberOtherThanZ(_n_)
			return This.AnyNumberBeforeOrAfterZ(_n_)

		#--

		def ARandoomNumberAfterOrBeforeZ(_n_)
			return This.AnyNumberBeforeOrAfterZ(_n_)

		def RandomNumberBeforeOrAfterZ(_n_)
			return This.AnyNumberBeforeOrAfterZ(_n_)

		def RandomNumberAfterOrBeforeZ(_n_)
			return This.AnyNumberBeforeOrAfterZ(_n_)

		def ARandomNumberOtherThanZ(_n_)
			return This.AnyNumberBeforeOrAfterZ(_n_)

		def RandomNumberOtherThanZ(_n_)
			return This.AnyNumberBeforeOrAfterZ(_n_)

		#--
	
		def ANumberDifferentThanZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		def ANumberDifferentFromZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		#--
	
		def NumberDifferentThanZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		def NumberDifferentFromZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		#--
	
		def AnyNumberDifferentThanZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		def AnyNumberDifferentFromZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		#--

		def ARandomNumberDifferentThanZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		def ARandomNumberDifferentFromZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		def RandomNumberDifferentThanZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)
	
		def RandomNumberDifferentFromZ(pcChar)
			return This.AnyNumberBeforeOrAfterZ(pcChar)

		#>

	  #--------------------------------------------------------#
	 #  GETTING ANY NUMBER BEFORE A GIVEN NUMBER OR POSITION  #
	#--------------------------------------------------------#

	def AnyNumberBefore(_n_)
		if isList(_n_) and Q(_n_).IsPositionNamedParam(_n_)
			return This.AnyNumberBeforePosition(_n_)
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nPos_ = StzFindFirst( This.Content(), _n_)
		_nResult_ = This.AnyNumberBeforePosition(_nPos_)

		return _nResult_

		#< @FunctionAlternativeForms

		def ANumberBefore(_n_)
			return This.AnyNumberBefore(_n_)

		def NumberBefore(_n_)
			return This.AnyNumberBefore(_n_)

		def ARandomNumberBefore(_n_)
			return This.AnyNumberBefore(_n_)

		def RandomNumberBefore(_n_)
			return This.AnyNumberBefore(_n_)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberBeforeZ(_n_)
		if isList(_n_) and Q(_n_).IsPositionNamedParam(_n_)
			return This.AnyNumberBeforePosition(_n_)
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nPos_ = StzFindFirst( This.Content(), _n_)
		_aResult_ = This.AnyNumberBeforePositionZ(_nPos_)

		return _aResult_

		#< @FunctionAlternativeForms

		def ANumberBeforeZ(_n_)
			return This.AnyNumberBeforeZ(_n_)

		def NumberBeforeZ(_n_)
			return This.AnyNumberBeforeZ(_n_)

		def ARandomNumberBeforeZ(_n_)
			return This.AnyNumberBeforeZ(_n_)

		def RandomNumberBeforeZ(_n_)
			return This.AnyNumberBeforeZ(_n_)

		#>

	  #----------------------------------------------#
	 #  GETTING ANY NUMBER BEFORE A GIVEN POSITION  #
	#----------------------------------------------#

	def AnyNumberBeforePosition(_n_)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nLen_ = This.NumberOfNumbers()
		
		if _n_ <= 1 or _n_ > _nLen_
			StzRaise("Index out of range!")
		ok

		if _n_ = 2
			return This.Number(1)
		ok

		_nRandom_ = random(_n_ - 1)
		if _nRandom_ = 0
			_nRandom_ = 1
		ok

		_nResult_ = This.Number(_nRandom_)

		return _nResult_

		#< @FunctionAlternativeForms

		def ANumberBeforePosition(_n_)
			return This.AnyNumberBeforePosition(_n_)

		def NumberBeforePosition(_n_)
			return This.AnyNumberBeforePosition(_n_)

		def ARandomNumberBeforePosition(_n_)
			return This.AnyNumberBeforePosition(_n_)

		def RandomNumberBeforePosition(_n_)
			return This.AnyNumberBeforePosition(_n_)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberBeforePositionZ(_n_)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nLen_ = This.NumberOfNumbers()
		
		if _n_ <= 1 or _n_ > _nLen_
			StzRaise("Index out of range!")
		ok

		if _n_ = 2
			return This.Number(1)
		ok

		_nRandom_ = random(_n_ - 1)
		if _nRandom_ = 0
			_nRandom_ = 1
		ok

		_aResult_ = [ This.Number(_nRandom_), _nRandom_ ]

		return _aResult_

		#< @FunctionAlternativeForms

		def ANumberBeforePositionZ(_n_)
			return This.AnyNumberBeforePositionZ(_n_)

		def NumberBeforePositionZ(_n_)
			return This.AnyNumberBeforePositionZ(_n_)

		def ARandomNumberBeforePositionZ(_n_)
			return This.AnyNumberBeforePositionZ(_n_)

		def RandomNumberBeforePositionZ(_n_)
			return This.AnyNumberBeforePositionZ(_n_)

		#>

	  #-------------------------------------------------------#
	 #  GETTING ANY NUMBER AFTER A GIVEN NUMBER OR POSITION  #
	#-------------------------------------------------------#

	def AnyNumberAfter(_n_)
		if isList(_n_) and Q(_n_).IsPositionNamedParam(_n_)
			return This.AnyNumberAfterPosition(_n_)
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		if _nLen_ = 0
			StzRaise("Can't proceed! The list of numbers is empty.")
		ok

		if ring_find(_anContent_, _n_) = 0
			stzRaise("Can't proceed! The number you provided does not exist in the list.")
		ok

		_anReverse_ = []

		for i = _nLen_ to 1 step -1
			_anReverse_ + _anContent_[i]
		next

		_nPos_ = ring_find( _anReverse_, _n_ )
		_nResult_ = This.AnyNumberAfterPosition(_nPos_)

		return _nResult_

		#< @FunctionAlternativeForms

		def ANumberAfter(_n_)
			return This.AnyNumberAfter(_n_)

		def NumberAfter(_n_)
			return This.AnyNumberAfter(_n_)

		def ARandomNumberAfter(_n_)
			return This.AnyNumberAfter(_n_)

		def RandomNumberAfter(_n_)
			return This.AnyNumberAfter(_n_)

		#>

	# Z/EXTENDED FORM

	def AnyNumberAfterZ(_n_)
		if isList(_n_) and Q(_n_).IsPositionNamedParam(_n_)
			return This.AnyNumberAfterPosition(_n_)
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nPos_ = StzFindFirst( new stzList(This.Content()).Reversed(), _n_ )
		_aResult_ = This.AnyNumberAfterPositionZ(_nPos_)

		return _aResult_

		#< @FunctionAlternativeForms

		def ANumberAfterZ(_n_)
			return This.AnyNumberAfterZ(_n_)

		def NumberAfterZ(_n_)
			return This.AnyNumberAfterZ(_n_)

		def ARandomNumberAfterZ(_n_)
			return This.AnyNumberAfterZ(_n_)

		def RandomNumberAfterZ(_n_)
			return This.AnyNumberAfterZ(_n_)

		#>

	  #---------------------------------------------#
	 #  GETTING ANY NUMBER AFETR A GIVEN POSITION  #
	#---------------------------------------------#

	def AnyNumberAfterPosition(_n_)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nLen_ = This.NumberOfNumbers()

		if _n_ < 1 or _n_ >= _nLen_
			StzRaise("Index out of range!")
		ok

		if _n_ = _nLen_ - 1
			return This.Number(_nLen_)
		ok

		_n_--
		_nRandom_ = random(_n_)
		if _nRandom_ = 0
			_nRandom_ = 1
		ok

		_nResult_ = This.Number(_n_ + _nRandom_ - 1)

		return _nResult_

		#< @FunctionAlternativeForms

		def ANumberAfterPosition(_n_)
			return This.AnyNumberAfterPosition(_n_)

		def NumberAfterPosition(_n_)
			return This.AnyNumberAfterPosition(_n_)

		def ARandomNumberAfterPosition(_n_)
			return This.AnyNumberAfterPosition(_n_)

		def RandomNumberAfterPosition(_n_)
			return This.AnyNumberAfterPosition(_n_)

		#>

	# Z/EXTENDED FORM

	def AnyNumberAfterPositionZ(_n_)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nLen_ = This.NumberOfNumbers()

		if _n_ < 1 or _n_ >= _nLen_
			StzRaise("Index out of range!")
		ok

		if _n_ = _nLen_ - 1
			return This.Number(_nLen_)
		ok

		_n_--
		_nRandom_ = random(_n_)
		if _nRandom_ = 0
			_nRandom_ = 1
		ok

		_nPos_ = _n_ + _nRandom_ - 1
		_aResult_ = [ This.Number(_nPos_), _nPos_ ]

		return _aResult_

		#< @FunctionAlternativeForms

		def ANumberAfterPositionZ(_n_)
			return This.AnyNumberAfterPositionZ(_n_)

		def NumberAfterPositionZ(_n_)
			return This.AnyNumberAfterPositionZ(_n_)

		def ARandomNumberAfterPositionZ(_n_)
			return This.AnyNumberAfterPositionZ(_n_)

		def RandomNumberAfterPositionZ(_n_)
			return This.AnyNumberAfterPositionZ(_n_)

		#>

	  #--------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LISTS BETWEEN TOW OTHER NUMBERS  #
	#--------------------------------------------------------------------#

	def AnyNumberBetween(_n1_, _n2_)
		if isList(_n1_) and Q(_n1_).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(_n1_[2], _n2_)
		ok

		if isList(_n2_) and Q(_n2_).IsAndNamedParam()
			_n2_ = _n2_[2]
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_anNumbers_ = This.NumbersBetween(_n1_, _n2_)
		_nResult_ = ARandomNumberIn(_anNumbers_) #TODO // Add ARandomItemIn() function to stzRandomFunctions.ring

		return _nResult_

		#< @FunctionAlternativeForms

		def ANumberBetween(_n1_, _n2_)
			return This.AnyNumberBetween(_n1_, _n2_)

		def NumberBetween(_n1_, _n2_)
			return This.AnyNumberBetween(_n1_, _n2_)

		#--

		def ARandomNumberBetween(_n1_, _n2_)
			return This.AnyNumberBetween(_n1_, _n2_)

		def RandomNumberBetween(_n1_, _n2_)
			return This.AnyNumberBetween(_n1_, _n2_)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberBetweenZ(_n1_, _n2_)
		if isList(_n1_) and Q(_n1_).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(_n1_[2], _n2_)
		ok

		if isList(_n2_) and Q(_n2_).IsAndNamedParam()
			_n2_ = _n2_[2]
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_anNumbers_ = This.NumbersBetween(_n1_, _n2_)
		_aResult_ = ARandomNumberInZ(_anNumbers_)
		
		return _aResult_

		#< @FunctionAlternativeForms

		def ANumberBetweenZ(_n1_, _n2_)
			return This.AnyNumberBetweenZ(_n1_, _n2_)

		def NumberBetweenZ(_n1_, _n2_)
			return This.AnyNumberBetweenZ(_n1_, _n2_)

		#--

		def ARandomNumberBetweenZ(_n1_, _n2_)
			return This.AnyNumberBetweenZ(_n1_, _n2_)

		def RandomNumberBetweenZ(_n1_, _n2_)
			return This.AnyNumberBetweenZ(_n1_, _n2_)

		#>

	  #---------------------------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LISTS BETWEEN TOW OTHER NUMBERS -- INCLUDING BOUNDS #
	#---------------------------------------------------------------------------------------#

	def AnyNumberBetweenIB(_n1_, _n2_)
		if isList(_n1_) and Q(_n1_).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(_n1_[2], _n2_)
		ok

		if isList(_n2_) and Q(_n2_).IsAndNamedParam()
			_n2_ = _n2_[2]
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_anNumbers_ = This.NumbersBetweenIB(_n1_, _n2_)
		_nResult_ = ARandomNumberIn(_anNumbers_)

		return _nResult_

		#< @FunctionAlternativeForms

		def ANumberBetweenIB(_n1_, _n2_)
			return This.AnyNumberBetweenIB(_n1_, _n2_)

		def NumberBetweenIB(_n1_, _n2_)
			return This.AnyNumberBetweenIB(_n1_, _n2_)

		#--

		def AnyNumberBetweenXT(_n1_, _n2_)
			return This.AnyNumberBetweenIB(_n1_, _n2_)

		def ANumberBetweenXT(_n1_, _n2_)
			return This.AnyNumberBetweenIB(_n1_, _n2_)

		def NumberBetweenXT(_n1_, _n2_)
			return This.AnyNumberBetweenIB(_n1_, _n2_)

		#--

		def ARandomNumberBetweenIB(_n1_, _n2_)
			return This.AnyNumberBetweenIB(_n1_, _n2_)

		def RandomNumberBetweenIB(_n1_, _n2_)
			return This.AnyNumberBetweenIB(_n1_, _n2_)

		def ARandomNumberBetweenXT(_n1_, _n2_)
			return This.AnyNumberBetweenIB(_n1_, _n2_)

		def RandomNumberBetweenXT(_n1_, _n2_)
			return This.AnyNumberBetweenIB(_n1_, _n2_)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberBetweenIBZ(_n1_, _n2_)
		if isList(_n1_) and Q(_n1_).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(_n1_[2], _n2_)
		ok

		if isList(_n2_) and Q(_n2_).IsAndNamedParam()
			_n2_ = _n2_[2]
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_anNumbers_ = This.NumbersBetweenIB(_n1_, _n2_)
		_aResult_ = ARandomNumberInZ(_anNumbers_)

		return _aResult_

		#< @FunctionAlternativeForms

		def ANumberBetweenIBZ(_n1_, _n2_)
			return This.AnyNumberBetweenIBZ(_n1_, _n2_)

		def NumberBetweenIBZ(_n1_, _n2_)
			return This.AnyNumberBetweenIBZ(_n1_, _n2_)

		#--

		def AnyNumberBetweenXTZ(_n1_, _n2_)
			return This.AnyNumberBetweenIBZ(_n1_, _n2_)

		def ANumberBetweenXTZ(_n1_, _n2_)
			return This.AnyNumberBetweenIBZ(_n1_, _n2_)

		def NumberBetweenXTZ(_n1_, _n2_)
			return This.AnyNumberBetweenIBZ(_n1_, _n2_)

		#--

		def ARandomNumberBetweenIBZ(_n1_, _n2_)
			return This.AnyNumberBetweenIBZ(_n1_, _n2_)

		def RandomNumberBetweenIBZ(_n1_, _n2_)
			return This.AnyNumberBetweenIBZ(_n1_, _n2_)

		def ARandomNumberBetweenXTZ(_n1_, _n2_)
			return This.AnyNumberBetweenIBZ(_n1_, _n2_)

		def RandomNumberBetweenXTZ(_n1_, _n2_)
			return This.AnyNumberBetweenIBZ(_n1_, _n2_)

		#>

	  #------------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LISTS NOT BETWEEN TWO OTHER NUMBERS  #
	#-----------------------------------------------------------------------#

	def AnyNumberNotBetween(_n1_, _n2_)
		if isList(_n1_) and Q(_n1_).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(_n1_[2], _n2_)
		ok

		if isList(_n2_) and Q(_n2_).IsAndNamedParam()
			_n2_ = _n2_[2]
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_anNumbers_ = This.NumbersNotBetween(_n1_, _n2_) #TODO
		_nResult_ = ARandomNumberIn(_anNumbers_)

		return _nResult_

		#< @FunctionAlternativeForms

		def ANumberNotBetween(_n1_, _n2_)
			return This.AnyNumberNotBetween(_n1_, _n2_)

		def NumberNotBetween(_n1_, _n2_)
			return This.AnyNumberNotBetween(_n1_, _n2_)

		#--

		def ARandomNumberNotBetween(_n1_, _n2_)
			return This.AnyNumberNotBetween(_n1_, _n2_)

		def RandomNumberNotBetween(_n1_, _n2_)
			return This.AnyNumberNotBetween(_n1_, _n2_)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberNotBetweenZ(_n1_, _n2_)
		if isList(_n1_) and Q(_n1_).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(_n1_[2], _n2_)
		ok

		if isList(_n2_) and Q(_n2_).IsAndNamedParam()
			_n2_ = _n2_[2]
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_anNumbers_ = This.NumbersNotBetween(_n1_, _n2_)
		_aResult_ = ARandomNumberInZ(_anNumbers_)

		return _aResult_

		#< @FunctionAlternativeForms

		def ANumberNotBetweenZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenZ(_n1_, _n2_)

		def NumberNotBetweenZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenZ(_n1_, _n2_)

		#--

		def ARandomNumberNotBetweenZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenZ(_n1_, _n2_)

		def RandomNumberNotBetweenZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenZ(_n1_, _n2_)

		#>

	  #-------------------------------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LISTS NOT BETWEEN TWO OTHER NUMBERS -- INCLUDING BOUNDS #
	#-------------------------------------------------------------------------------------------#

	def AnyNumberNotBetweenIB(_n1_, _n2_)
		if isList(_n1_) and Q(_n1_).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(_n1_[2], _n2_)
		ok

		if isList(_n2_) and Q(_n2_).IsAndNamedParam()
			_n2_ = _n2_[2]
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_anNumbers_ = This.NumbersNotBetweenIB(_n1_, _n2_) #TODO
		_nResult_ = ARandomNumberIn(_anNumbers_) #TODO // Add ARandomItemIn() function to stzRandomFunctions.ring

		return _nResult_

		#< @FunctionAlternativeForms

		def ANumberNotBetweenIB(_n1_, _n2_)
			return This.AnyNumberNotBetweenIB(_n1_, _n2_)

		def NumberNotBetweenIB(_n1_, _n2_)
			return This.AnyNumberNotBetweenIB(_n1_, _n2_)

		#--

		def AnyNumberNotBetweenXT(_n1_, _n2_)
			return This.AnyNumberNotBetweenIB(_n1_, _n2_)

		def ANumberNotBetweenXT(_n1_, _n2_)
			return This.AnyNumberNotBetweenIB(_n1_, _n2_)

		def NumberNotBetweenXT(_n1_, _n2_)
			return This.AnyNumberNotBetweenIB(_n1_, _n2_)

		#==

		def ARandomNumberNotBetweenIB(_n1_, _n2_)
			return This.AnyNumberNotBetweenIB(_n1_, _n2_)

		def RandomNumberNotBetweenIB(_n1_, _n2_)
			return This.AnyNumberNotBetweenIB(_n1_, _n2_)

		#--

		def ARandomNumberNotBetweenXT(_n1_, _n2_)
			return This.AnyNumberNotBetweenIB(_n1_, _n2_)

		def RandomNumberNotBetweenXT(_n1_, _n2_)
			return This.AnyNumberNotBetweenIB(_n1_, _n2_)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberNotBetweenIBZ(_n1_, _n2_)
		if isList(_n1_) and Q(_n1_).IsPositionOrPositionsNamedParam()
			return AnyNumberBetweenPositions(_n1_[2], _n2_)
		ok

		if isList(_n2_) and Q(_n2_).IsAndNamedParam()
			_n2_ = _n2_[2]
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_anNumbers_ = This.NumbersNotBetweenIB(_n1_, _n2_)
		_aResult_   = ARandomNumberInZ(_anNumbers_)

		return _aResult_

		#< @FunctionAlternativeForms

		def ANumberNotBetweenIBZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenIBZ(_n1_, _n2_)

		def NumberNotBetweenIBZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenIBZ(_n1_, _n2_)

		#--

		def AnyNumberNotBetweenXTZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenIBZ(_n1_, _n2_)

		def ANumberNotBetweenXTZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenIBZ(_n1_, _n2_)

		def NumberNotBetweenXTZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenIBZ(_n1_, _n2_)

		#==

		def ARandomNumberNotBetweenIBZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenIBZ(_n1_, _n2_)

		def RandomNumberNotBetweenIBZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenIBZ(_n1_, _n2_)

		#--

		def ARandomNumberNotBetweenXTZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenIBZ(_n1_, _n2_)

		def RandomNumberNotBetweenXTZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenIBZ(_n1_, _n2_)

		#>

	  #----------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LISTS BETWEEN TOW OTHER POSITIONS  #
	#----------------------------------------------------------------------#

	def AnyNumberBetweenPositions(_n1_, _n2_)
		if isList(_n2_) and Q(_n2_).IsAndNamedParam()
			_n2_ = _n2_[2]
		ok

		if NOT @BothAreNumbers(_n1_, _n2_)
			StzRaise("Incorrect param types! n1 and n2 must both be numbers.")
		ok

		nMin = @Min([ _n1_, _n2_ ])
		nMax = @Max([ _n1_, _n2_ ])

		_anPos_ = nMin : nMax
		_nRandom_ = AnyNumberIn(_anPos_)
		_nResult_ = This.Number(_nRandom_)

		return _nResult_

		#< @FunctionAlternativeForms

		def RandomNumberBetweenPositions(_n1_, _n2_)
			return This.AnyNumberBetweenPositions(_n1_, _n2_)

		def ARandomNumberBetweenPositions(_n1_, _n2_)
			return This.AnyNumberBetweenPositions(_n1_, _n2_)

		def ANumberBetweenPositions(_n1_, _n2_)
			return This.AnyNumberBetweenPositions(_n1_, _n2_)

		def NumberBetweenPositions(_n1_, _n2_)
			return This.AnyNumberBetweenPositions(_n1_, _n2_)

		#--

		def RandomNumberInSection(_n1_, _n2_)
			return This.AnyNumberBetweenPositions(_n1_, _n2_)

		def ARandomNumberInSection(_n1_, _n2_)
			return This.AnyNumberInSection(_n1_, _n2_)

		def ANumberInSection(_n1_, _n2_)
			return This.AnyNumberBetweenPositions(_n1_, _n2_)

		def NumberInSection(_n1_, _n2_)
			return This.AnyNumberBetweenPositions(_n1_, _n2_)

		def AnyNumberInSection(_n1_, _n2_)
			return This.AnyNumberBetweenPositions(_n1_, _n2_)

		#>

	#-- Z/EXTENDED FORM

	def AnyNumberBetweenPositionsZ(_n1_, _n2_)
		if isList(_n2_) and Q(_n2_).IsAndNamedParam()
			_n2_ = _n2_[2]
		ok

		if NOT @BothAreNumbers(_n1_, _n2_)
			StzRaise("Incorrect param types! n1 and n2 must both be numbers.")
		ok

		nMin = @Min([ _n1_, _n2_ ])
		nMax = @Max([ _n1_, _n2_ ])

		_anPos_ = nMin : nMax
		_nRandom_ = AnyNumberIn(_anPos_)
		_aResult_ = [ This.Number(_nRandom_), _nRandom_ ]

		return _aResult_

		#< @FunctionAlternativeForms

		def RandomNumberBetweenPositionsZ(_n1_, _n2_)
			return This.AnyNumberBetweenPositionsZ(_n1_, _n2_)

		def ARandomNumberBetweenPositionsZ(_n1_, _n2_)
			return This.AnyNumberBetweenPositionsZ(_n1_, _n2_)

		def ANumberBetweenPositionsZ(_n1_, _n2_)
			return This.AnyNumberBetweenPositionsZ(_n1_, _n2_)

		def NumberBetweenPositionsZ(_n1_, _n2_)
			return This.AnyNumberBetweenPositionsZ(_n1_, _n2_)

		#--

		def RandomNumberInSectionZ(_n1_, _n2_)
			return This.AnyNumberBetweenPositionsZ(_n1_, _n2_)

		def ARandomNumberInSectionZ(_n1_, _n2_)
			return This.AnyNumberInSectionZ(_n1_, _n2_)

		def ANumberInSectionZ(_n1_, _n2_)
			return This.AnyNumberBetweenPositionsZ(_n1_, _n2_)

		def NumberInSectionZ(_n1_, _n2_)
			return This.AnyNumberBetweenPositionsZ(_n1_, _n2_)

		def AnyNumberInSectionZ(_n1_, _n2_)
			return This.AnyNumberBetweenPositionsZ(_n1_, _n2_)

		#>

	  #--------------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LISTS NOT BETWEEN TWO OTHER POSITIONS  #
	#--------------------------------------------------------------------------#

	def AnyNumberNotBetweenPositions(_n1_, _n2_)
		if isList(_n2_) and Q(_n2_).IsAndNamedParam()
			_n2_ = _n2_[2]
		ok

		if NOT @BothAreNumbers(_n1_, _n2_)
			StzRaise("Incorrect param types! n1 and n2 must both be numbers.")
		ok

		nMin = @Min([ _n1_, _n2_ ])
		nMax = @Max([ _n1_, _n2_ ])

		_anPos_ = nMin : nMax
		_nRandom_ = AnyNumberNotIn(_anPos_) #TODO
		_nResult_ = This.Number(_nRandom_)

		return _nResult_

		#< @FunctionAlternativeForms

		def RandomNumberNotBetweenPositions(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositions(_n1_, _n2_)

		def ARandomNumberNotBetweenPositions(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositions(_n1_, _n2_)

		def ANumberNotBetweenPositions(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositions(_n1_, _n2_)

		def NumberNotBetweenPositions(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositions(_n1_, _n2_)

		#--

		def RandomNumberNotInSection(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositions(_n1_, _n2_)

		def ARandomNumberNotInSection(_n1_, _n2_)
			return This.AnyNumberNotInSection(_n1_, _n2_)

		def ANumberNotInSection(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositions(_n1_, _n2_)

		def NumberNotInSection(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositions(_n1_, _n2_)

		def AnyNumberNotInSection(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositions(_n1_, _n2_)

		#--

		def RandomNumberOutsideSection(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositions(_n1_, _n2_)

		def ARandomNumberOutsideSection(_n1_, _n2_)
			return This.AnyNumberNotInSection(_n1_, _n2_)

		def ANumberOutsideSection(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositions(_n1_, _n2_)

		def NumberOutsideSection(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositions(_n1_, _n2_)

		def AnyNumberOutsideSection(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositions(_n1_, _n2_)

		#>

	#-- Z/EXTENDED FROM

	def AnyNumberNotBetweenPositionsZ(_n1_, _n2_)
		if isList(_n2_) and Q(_n2_).IsAndNamedParam()
			_n2_ = _n2_[2]
		ok

		if NOT @BothAreNumbers(_n1_, _n2_)
			StzRaise("Incorrect param types! n1 and n2 must both be numbers.")
		ok

		nMin = @Min([ _n1_, _n2_ ])
		nMax = @Max([ _n1_, _n2_ ])

		_anPos_ = nMin : nMax
		_nRandom_ = AnyNumberNotIn(_anPos_)
		_aResult_ = [ This.Number(_nRandom_), _nRandom_ ]

		return _aResult_

		#< @FunctionAlternativeForms

		def RandomNumberNotBetweenPositionsZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositionsZ(_n1_, _n2_)

		def ARandomNumberNotBetweenPositionsZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositionsZ(_n1_, _n2_)

		def ANumberNotBetweenPositionsZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositionsZ(_n1_, _n2_)

		def NumberNotBetweenPositionsZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositionsZ(_n1_, _n2_)

		#--

		def RandomNumberNotInSectionZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositionsZ(_n1_, _n2_)

		def ARandomNumberNotInSectionZ(_n1_, _n2_)
			return This.AnyNumberNotInSectionZ(_n1_, _n2_)

		def ANumberNotInSectionZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositionsZ(_n1_, _n2_)

		def NumberNotInSectionZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositionsZ(_n1_, _n2_)

		def AnyNumberNotInSectionZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositionsZ(_n1_, _n2_)

		#--

		def RandomNumberOutsideSectionZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositionsZ(_n1_, _n2_)

		def ARandomNumberOutsideSectionZ(_n1_, _n2_)
			return This.AnyNumberNotInSectionZ(_n1_, _n2_)

		def ANumberOutsideSectionZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositionsZ(_n1_, _n2_)

		def NumberOutsideSectionZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositionsZ(_n1_, _n2_)

		def AnyNumberOutsideSectionZ(_n1_, _n2_)
			return This.AnyNumberNotBetweenPositionsZ(_n1_, _n2_)

		#>

	  #---------------------------------------------------#
	 #  GETTING A RANDOM NUMBER OUSIDE A GIVEN POSITION  #
	#---------------------------------------------------#

	def AnyNumberOutsidePosition(_n_)
		_anPositions_ = Q(1 : This.NumberOfItems()) - _n_
		_nRandom_ = AnyNumberIn(_anPos_)
		_nResult_ = This.Number(_nRandom_)

		return _nResult_

		#< @FunctionAlternativeForms

		def ANumberOutsidePosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		def NumberOutsidePosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		#--

		def AnyNumberBeforeOrAfterPosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		def AnyNumberAfterOrBeforePosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		def ANumberBeforeOrAfterPosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		def ANumberAfterOrBeforePosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		def NumberBeforeOrAfterPosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		def NumberAfterOrBeforePosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		#--

		def ARandomNumberOutsidePosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		def RandomNumberOutsidePosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		def ARandomNumberBeforeOrAfterPosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		def ARandomNumberAfterOrBeforePosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		def RandomNumberBeforeOrAfterPosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		def RandomNumberAfterOrBeforePosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		#--

		def ARandomNumberNotAtPosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		def RandomNumberNotAtPosition(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		#--

		def ARandomNumberNotAt(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		def RandomNumberNotAt(_n_)
			return This.AnyNumberOutsidePosition(_n_)

		#>

	# Z/EXTENDED FORM

	def AnyNumberOutsidePositionZ(_n_)
		_anPositions_ = Q(1 : This.NumberOfItems()) - _n_
		_nRandom_ = AnyNumberIn(_anPos_)
		_aResult_ = [ This.Number(_nRandom_), _nRandom_ ]

		return _aResult_

		#< @FunctionAlternativeForms

		def ANumberOutsidePositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		def NumberOutsidePositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		#--

		def AnyNumberBeforeOrAfterPositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		def AnyNumberAfterOrBeforePositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		def ANumberBeforeOrAfterPositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		def ANumberAfterOrBeforePositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		def NumberBeforeOrAfterPositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		def NumberAfterOrBeforePositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		#--

		def ARandomNumberOutsidePositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		def RandomNumberOutsidePositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		def ARandomNumberBeforeOrAfterPositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		def ARandomNumberAfterOrBeforePositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		def RandomNumberBeforeOrAfterPositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		def RandomNumberAfterOrBeforePositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		#--

		def ARandomNumberNotAtPositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		def RandomNumberNotAtPositionZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		#--

		def ARandomNumberNotAtZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		def RandomNumberNotAtZ(_n_)
			return This.AnyNumberOutsidePositionZ(_n_)

		#>

	  #------------------------------------------#
	 #  GETTING N RANDOM NUMBERS FROM THE LIST  #
	#------------------------------------------#

	def NRandomNumbers(_n_)

		# Checking param n and the size of the list of numbers

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok
		if _n_ <= 0
			StzRaise("Can't proceed because n must be a positive number greater then 0!")
		ok

		_nLen_ = This.NumberOfNumbers()
		if _nLen_ = 0
			StzRaise("Can't get random numbers because the list is empty!")
		ok

		if _n_ > _nLen_
			StzRaise("Can't proceed because n must be a number equal or less then the size of the list ("+ _nLen_ +")!")
		ok

		# Doing the job

		_anResult_ = []

		for i = 1 to _n_
			_anResult_ + ARandomNumberBetween(1, _nLen_)
		next

		return _anResult_

		#< @FunctionAlternativeForms

		def RandomNNumbers(_n_)
			return This.NRandomNumbers(_n_)

		def NNumbers(_n_)
			return This.NRandomNumbers(_n_)

		#>

	# Z/EXTENDED FORM

	def NRandomNumbersZ(_n_)

		# Checking param n and the size of the list of numbers

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok
		if _n_ <= 0
			StzRaise("Can't proceed because n must be a positive number greater then 0!")
		ok

		_nLen_ = This.NumberOfNumbers()
		if _nLen_ = 0
			StzRaise("Can't get random numbers because the list is empty!")
		ok

		if _n_ > _nLen_
			StzRaise("Can't proceed because n must be a number equal or less then the size of the list ("+ _nLen_ +")!")
		ok

		# Doing the job

		_aResult_ = []

		for i = 1 to _n_
			_aResult_ + ARandomNumberBetweenZ(1, _nLen_)
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def RandomNNumbersZ(_n_)
			return This.NRandomNumbersZ(_n_)

		def NNumbersZ(_n_)
			return This.NRandomNumbersZ(_n_)

		#>

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)


	  #------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS OTHER THEN A GIVEN NUMBER  #
	#------------------------------------------------------#

	def NNumbersOtherThan(_n_, _nNumber_)
		if isList(_n_)

			_oParam_ = new stzList(_n_)

			if _oParam_.IsPositionNamedParam()
				return This.NNumbersOutSidePosition(_n_[2], _nNumber_)

			but _oParam_.IsPositionsNamedParam()
				return This.NNumbersOutsidePositions(_n_[2], _nNumber_)

			else
				return This.NNumbersOutsidePositions(_n_, _nNumber_)
			ok
		ok

		_anPos_ = This.Find(_n_)
		_anPos_ = Q( 1 : This.NumberOfNumbers() ) - These(_anPos_)
		// #TODO Make a more performant solution!

		_anRandoms_ = NRandomNumbersIn(_anPos_)
		_anResult_ = This.ItemsAtPositions(_anRandoms_)

		return _anResult_

	#-- Z/EXTENDED FORM

	def NNumbersOtherThanZ(_n_, _nNumber_)
		if isList(_n_)

			_oParam_ = new stzList(_n_)

			if _oParam_.IsPositionNamedParam()
				return This.NNumbersOutSidePosition(_n_[2], _nNumber_)

			but _oParam_.IsPositionsNamedParam()
				return This.NNumbersOutsidePositions(_n_[2], _nNumber_)

			else
				return This.NNumbersOutsidePositions(_n_, _nNumber_)
			ok
		ok

		_anPos_ = This.Find(_n_)
		_anPos_ = Q( 1 : This.NumberOfNumbers() ) - These(_anPos_)
		// #TODO Make a more performant solution!

		_anRandoms_ = NRandomNumbersIn(_anPos_)
		_nLen_ = len(_anRandoms_)

		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + [ This.ItemAtPosition(_anRandoms_[i]), _anRandoms_[i] ]
		next

		return _aResult_

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #-----------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS LESS THEN A GIVEN NUMBER  #
	#-----------------------------------------------------#

	def NNumbersLessThan(_n_, _nNumber_)
		_anResult_ = This.NumbersLessThanQ(_nNumber_).NRandomNumbers(_n_)
		return _anResult_

		#< @FunctionAlternativeForms

		def NRandomNumbersLessThan(_n_, _nNumber_)
			return This.NNumbersLessThan(_n_, _nNumber_)

		def NNumbersSmallerThan(_n_, _nNumber_)
			return This.NNumbersLessThan(_n_, _nNumber_)

		def NRandomNumbersSmallerThan(_n_, _nNumber_)
			return This.NNumbersLessThan(_n_, _nNumber_)

		#>

	#-- Z/EXTENDED FORM

	def NNumbersLessThanZ(_n_, _nNumber_)
		_aResult_ = This.NumbersLessThanQ(_nNumber_).NRandomNumbersZ(_n_)
		return _anResult_

		#< @FunctionAlternativeForms

		def NRandomNumbersLessThanZ(_n_, _nNumber_)
			return This.NNumbersLessThanZ(_n_, _nNumber_)

		def NNumbersSmallerThanZ(_n_, _nNumber_)
			return This.NNumbersLessThanZ(_n_, _nNumber_)

		def NRandomNumbersSmallerThanZ(_n_, _nNumber_)
			return This.NNumbersLessThanZ(_n_, _nNumber_)

		#>

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #--------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS GREATER THEN A GIVEN NUMBER  #
	#--------------------------------------------------------#

	def NNumbersGreaterThan(_n_, _nNumber_)
		_anResult_ = This.NumbersGreaterThanQ(_nNumber_).NRandomNumbers(_n_)
		return _anResult_

		#< @FunctionAlternativeForms

		def NRandomNumbersGreaterThan(_n_, _nNumber_)
			return This.NNumbersLessThan(_n_, _nNumber_)

		def NNumbersBiggerThan(_n_, _nNumber_)
			return This.NNumbersLessThan(_n_, _nNumber_)

		def NRandomNumbersBiggerThan(_n_, _nNumber_)
			return This.NNumbersLessThan(_n_, _nNumber_)

		def NNumbersMoreThan(_n_, _nNumber_)
			return This.NNumbersLessThan(_n_, _nNumber_)

		def NRandomNumbersMoreThan(_n_, _nNumber_)
			return This.NNumbersLessThan(_n_, _nNumber_)

		#>

	#-- Z/EXTENDED FORM

	def NNumbersGreaterThanZ(_n_, _nNumber_)
		_aResult_ = This.NumbersGreaterThanQ(_nNumber_).NRandomNumbersZ(_n_)
		return _aResult_

		#< @FunctionAlternativeForms

		def NRandomNumbersGreaterThanZ(_n_, _nNumber_)
			return This.NNumbersLessThanZ(_n_, _nNumber_)

		def NNumbersBiggerThanZ(_n_, _nNumber_)
			return This.NNumbersLessThanZ(_n_, _nNumber_)

		def NRandomNumbersBiggerThanZ(_n_, _nNumber_)
			return This.NNumbersLessThanZ(_n_, _nNumber_)

		def NNumbersMoreThanZ(_n_, _nNumber_)
			return This.NNumbersLessThanZ(_n_, _nNumber_)

		def NRandomNumbersMoreThanZ(_n_, _nNumber_)
			return This.NNumbersLessThanZ(_n_, _nNumber_)

		#>

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #---------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS OTHER THEN THE GIVEN NUMBERS  #
	#---------------------------------------------------------#
	
	// #TODO // Add alternatives of (DifferentTo / Of / From / With) all over the library!

	def NNumbersOtherThanMany(_n_, _anNumbers_)

		_anPos_ = Q( 1 : This.NumberOfItems() ) - These(This.Find(_anNumbers_))
		// #TODO Make a more performant solution!

		_anRandoms_ = NRandomNumbersIn(_anPos_)
		_aResult_ = This.ItemsAtPositions(_anRandoms_)

		return _anResult_

		#< @FunctionAlternativeForms

		def NNumbersDifferentFromMany(_n_, _anNumbers_)
			return This.NNumbersOtherThanMany(_n_, _anNumbers_)

		def NNumbersDifferentToMany(_n_, _anNumbers_)
			return This.NNumbersOtherThanMany(_n_, _anNumbers_)

		def NNumbersDifferentWithMany(_n_, _anNumbers_)
			return This.NNumbersOtherThanMany(_n_, _anNumbers_)

		def NNumbersDifferentOfMany(_n_, _anNumbers_)
			return This.NNumbersOtherThanMany(_n_, _anNumbers_)

		#--

		def NRandomNumbersOtherThanMany(_n_, _anNumbers_)
			return This.NNumbersOtherThanMany(_n_, _anNumbers_)

		def NRandomNumbersDifferentFromMany(_n_, _anNumbers_)
			return This.NNumbersOtherThanMany(_n_, _anNumbers_)

		def NRandomNumbersDifferentToMany(_n_, _anNumbers_)
			return This.NNumbersOtherThanMany(_n_, _anNumbers_)

		def NRandomNumbersDifferentWithMany(_n_, _anNumbers_)
			return This.NNumbersOtherThanMany(_n_, _anNumbers_)

		def NRandomNumbersDifferentOfMany(_n_, _anNumbers_)
			return This.NNumbersOtherThanMany(_n_, _anNumbers_)

		#>

	#-- Z/EXTENDED FORM

	def NNumbersOtherThanManyZ(_n_, _anNumbers_)

		_anPos_ = Q( 1 : This.NumberOfItems() ) - These(This.Find(_anNumbers_))
		// #TODO Make a more performant solution!

		_anRandoms_ = NRandomNumbersIn(_anPos_)
		_nLen_ = len(aRandoms)
		
		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + [ This.ItemAtPosition(_anRandoms_[i]), _anRandoms_[i] ]
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def NNumbersDifferentFromManyZ(_n_, _anNumbers_)
			return This.NNumbersOtherThanManyZ(_n_, _anNumbers_)

		def NNumbersDifferentToManyZ(_n_, _anNumbers_)
			return This.NNumbersOtherThanManyZ(_n_, _anNumbers_)

		def NNumbersDifferentWithManyZ(_n_, _anNumbers_)
			return This.NNumbersOtherThanManyZ(_n_, _anNumbers_)

		def NNumbersDifferentOfManyZ(_n_, _anNumbers_)
			return This.NNumbersOtherThanManyZ(_n_, _anNumbers_)

		#--

		def NRandomNumbersOtherThanManyZ(_n_, _anNumbers_)
			return This.NNumbersOtherThanManyZ(_n_, _anNumbers_)

		def NRandomNumbersDifferentFromManyZ(_n_, _anNumbers_)
			return This.NNumbersOtherThanManyZ(_n_, _anNumbers_)

		def NRandomNumbersDifferentToManyZ(_n_, _anNumbers_)
			return This.NNumbersOtherThanManyZ(_n_, _anNumbers_)

		def NRandomNumbersDifferentWithManyZ(_n_, _anNumbers_)
			return This.NNumbersOtherThanManyZ(_n_, _anNumbers_)

		def NRandomNumbersDifferentOfManyZ(_n_, _anNumbers_)
			return This.NNumbersOtherThanManyZ(_n_, _anNumbers_)

		#>

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)


	  #--------------------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS FROM THE LIST BETWEEN TWO GIVEN NUMBERS  #
	#--------------------------------------------------------------------#

	def NNumbersBetween(_n_, nMin, nMax)
		_anNumbers_ = This.NumbersBetween(nMin, nMax)
		_anResult_ = NRandomNumbersIn(_n_, _anNumbers_)

		return _anResult_

		def NRandomNumbersBetween(nMin, nMax)
			return This.NNumbersBetween(nMin, nMax)

	#-- Z/EXTENDED FORM

	def NNumbersBetweenZ(_n_, nMin, nMax)
		_anNumbers_ = This.NumbersBetween(nMin, nMax)
		_aResult_ = NRandomNumbersInZ(_n_, _anNumbers_)

		return _aResult_

		def NRandomNumbersBetweenZ(nMin, nMax)
			return This.NNumbersBetweenZ(nMin, nMax)

	#-- U/EXTENDED FORM (TODO)

	#-- UZ/EXTENDED FORM (TODO)


	  #-----------------------------------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS FROM THE LIST BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#-----------------------------------------------------------------------------------#

	def NNumbersBetweenIB(_n_, nMin, nMax)
		_anNumbers_ = This.NumbersBetweenIB(nMin, nMax)
		_anResult_ = NRandomNumbersIn(_n_, _anNumbers_)

		return _anResult_

		def NRandomNumbersBetweenIB(nMin, nMax)
			return This.NNumbersBetweenIB(nMin, nMax)

	# Z/EXTENDED FORM

	def NNumbersBetweenIBZ(_n_, nMin, nMax)
		_anNumbers_ = This.NumbersBetweenIB(nMin, nMax)
		_aResult_ = NRandomNumbersInZ(_n_, _anNumbers_)

		return _anResult_

		def NRandomNumbersBetweenIBZ(nMin, nMax)
			return This.NNumbersBetweenIBZ(nMin, nMax)


	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)


	  #------------------------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS FROM THE LIST NOT BETWEEN TWO GIVEN NUMBERS  #
	#------------------------------------------------------------------------#

	def NNumbersNotBetween(_n_, nMin, nMax)
		_anNumbers_ = This.NumbersNotBetween(nMin, nMax)
		_anResult_ = NRandomNumbersIn(_n_, _anNumbers_)

		return _anResult_

		def NRandomNumbersNotBetween(nMin, nMax)
			return This.NNumbersNotBetween(nMin, nMax)

	# Z/EXTENDED FORM

	def NNumbersNotBetweenZ(_n_, nMin, nMax)
		_anNumbers_ = This.NumbersNotBetween(nMin, nMax)
		_aResult_ = NRandomNumbersInZ(_n_, _anNumbers_)

		return _aResult_

		def NRandomNumbersNotBetweenZ(nMin, nMax)
			return This.NNumbersNotBetweenZ(nMin, nMax)

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)


	  #---------------------------------------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS FROM THE LIST NOT BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#---------------------------------------------------------------------------------------#

	def NNumbersNotBetweenIB(_n_, nMin, nMax)
		_anNumbers_ = This.NumbersNotBetweenIB(nMin, nMax)
		_anResult_ = NRandomNumbersIn(_n_, _anNumbers_)

		return _anResult_

		def NRandomNumbersNotBetweenIB(nMin, nMax)
			return This.NNumbersNotBetweenIB(nMin, nMax)

	# Z/EXTENDED FORM

	def NNumbersNotBetweenIBZ(_n_, nMin, nMax)
		_anNumbers_ = This.NumbersNotBetweenIB(nMin, nMax)
		_aResult_ = NRandomNumbersInZ(_n_, _anNumbers_)

		return _aResult_

		def NRandomNumbersNotBetweenIBZ(nMin, nMax)
			return This.NNumbersNotBetweenIBZ(nMin, nMax)

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #-----------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS OUTSIDE A GIVEN POSITION  #
	#=====================================================#

	def NNumbersOutsidePosition(_nPos_)
		return This.NItemsOutsidePosition(_nPos_)

	#-- 2/EXTENDED FORM

	def NNumbersOutsidePositionsZ(panPos)
		return This.NItemsOutsidePositionsZ(panPos)

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #--------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS OUTSIDE THE GIVEN POSITIONS  #
	#--------------------------------------------------------#

	def NNumbersOutsidePositions(panPos)
		return This.NItemsOutsidePositions(panPos)

	# Z/EXTENDED FORM

	def NItemsOutsidePositionZ(_anPos_)
		return This.NItemsOutsidePositionZ(_anPos_)

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #---------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS FROM THE LIST  #
	#=============================================#

	def SomeRandomNumbers()
		_anPos_ = SomeRandomNumbersIn(1 : This.NumberOfItems())
		_anResult_ = This.ItemsAtPositions(_anPos_)

		return _anResult_

		def SomeNumbers()
			return This.SomeRandomNumbers()

	# Z/EXTENDED FORM

	def SomeRandomNumbersZ()
		_anPos_ = SomeRandomNumbersIn(1 : This.NumberOfItems())
		_nLen_  = len(_anPos_)

		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + [ This.Number(i), _anPos_[i] ]
		next

		return _aResult_

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #---------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS OTHER THEN A GIVEN NUMBER  #
	#---------------------------------------------------------#

	def SomeNumbersOtherThan(_n_, _nNumber_)
		if isList(_n_)

			_oParam_ = new stzList(_n_)

			if _oParam_.IsPositionNamedParam()
				return This.SomeNumbersOutSidePosition(_n_[2], _nNumber_)

			but _oParam_.IsPositionsNamedParam()
				return This.SomeNumbersOutsidePositions(_n_[2], _nNumber_)

			else
				return This.SomeNumbersOutsidePositions(_n_, _nNumber_)
			ok
		ok

		_anPos_ = This.Find(_n_)
		_anPos_ = Q( 1 : This.NumberOfNumbers() ) - These(_anPos_)
		// #TODO Make a more performant solution!

		_anRandoms_ = SomeRandomNumbersIn(_anPos_)
		_anResult_ = This.ItemsAtPositions(_anRandoms_)

		return _anResult_

	  #--------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS LESS THEN A GIVEN NUMBER  #
	#--------------------------------------------------------#

	def SomeNumbersLessThan(_n_, _nNumber_)
		_anNumbers_ = This.NumbersLessThan(_nNumber_)
		_anResult_ = StzListOfNumbers(_anNumbers_).SomeRandomNumbers()

		return _anResult_

	#-- Z/EXTENDED FORM

	def SomeNumbersLessThanZ(_n_, _nNumber_)
		_anNumbers_ = This.NumbersLessThan(_nNumber_)
		_aResult_ = StzListOfNumbers(_anNumbers_).SomeRandomNumbersZ()

		return _aResult_

	  #----------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS GRATER THEN A GIVEN NUMBER  #
	#----------------------------------------------------------#

	def SomeNumbersGreaterThan(_n_, _nNumber_)
		_anNumbers_ = This.NumbersGreaterThan(_nNumber_)
		_anResult_ = StzListOfNumbers(_anNumbers_).SomeRandomNumbers()

		return _anResult_

	#-- Z/EXTENDED FORM

	def SomeNumbersGreaterThanZ(_n_, _nNumber_)
		_anNumbers_ = This.NumbersGreaterThan(_nNumber_)
		_aResult_ = StzListOfNumbers(_anNumbers_).SomeRandomNumbersZ()

		return _aResult_

	  #------------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS OTHER THEN THE GIVEN NUMBERS  #
	#------------------------------------------------------------#

	def SomeNumbersOtherThanMany(paNumbers)
		_anNumbers_ = This.NumbersOtherThanMany(paNumbers)
		_anResult_  = StzListOfNumbers(_anNumbers_).SomeRandomNumbers()

		return _anResult_

	#-- Z/EXTENDED FORM

	def SomeNumbersOtherThanManyZ(paNumbers)
		_anNumbers_ = This.NumbersOtherThanMany(_nNumber_)
		_aResult_   = StzListOfNumbers(_anNumbers_).SomeRandomNumbersZ()

		return _aResult_

	  #---------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS BETWEEN TWO GIVEN NUMBERS  #
	#---------------------------------------------------------#

	func SomeNumbersBetween(nMin, nMax)
		_anNumbers_ = This.NumbersBetween(nMin, nMax)
		_anResult_  = StzListOfNumbers(_anNumbers_).SomeRandomNumbers()

		return _anResult_

	#-- Z/EXTENDED FORM

	def SomeNumbersBetweenZ(nMin, nMax)
		_anNumbers_ = This.NumbersBetween(nMin, nMax)
		_aResult_   = StzListOfNumbers(_anNumbers_).SomeRandomNumbersZ()

		return _aResult_

	  #-------------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS NOT BETWEEN TWO GIVEN NUMBERS  #
	#-------------------------------------------------------------#

	func SomeNumbersNotBetween(nMin, nMax)
		_anNumbers_ = This.NumbersNotBetween(nMin, nMax)
		_anResult_  = StzListOfNumbers(_anNumbers_).SomeRandomNumbers()

		return _anResult_

	#-- Z/EXTENDED FORM

	def SomeNumbersNotBetweenZ(nMin, nMax)
		_anNumbers_ = This.NumbersNotBetween(nMin, nMax)
		_aResult_   = StzListOfNumbers(_anNumbers_).SomeRandomNumbersZ()

		return _aResult_

	  #------------------------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#------------------------------------------------------------------------#

	func SomeNumbersBetweenIB(nMin, nMax)
		_anNumbers_ = This.NumbersBetweenIB(nMin, nMax)
		_anResult_  = StzListOfNumbers(_anNumbers_).SomeRandomNumbers()

		return _anResult_

	#-- Z/EXTENDED FORM

	def SomeNumbersBetweenIBZ(nMin, nMax)
		_anNumbers_ = This.NumbersBetweenIB(nMin, nMax)
		_aResult_   = StzListOfNumbers(_anNumbers_).SomeRandomNumbersZ()

		return _aResult_

	  #----------------------------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS NOT BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#----------------------------------------------------------------------------#

	func SomeNumbersNotBetweenIB(nMin, nMax)
		_anNumbers_ = This.NumbersNotBetween(nMin, nMax)
		_anResult_  = StzListOfNumbers(_anNumbers_).SomeRandomNumbers()

		return _anResult_

	#-- Z/EXTENDED FORM

	def SomeNumbersNotBetweenIBZ(nMin, nMax)
		_anNumbers_ = This.NumbersNotBetween(nMin, nMax)
		_aResult_   = StzListOfNumbers(_anNumbers_).SomeRandomNumbersZ()

		return _aResult_

	  #===================================================#
	 #  GETTING THE NUMBERS SMALLER THAN A GIVEN NUMBER  #
	#===================================================#

	def NumbersSmallerThan(_n_)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_anResult_ = []

		for i = 1 to _nLen_
			if _anContent_[i] < _n_
				_anResult_ + _anContent_[i]
			ok
		next

		return _anResult_

		#< @FunctionFluentForms

		def NumbersSmallerThanQ(_n_)
			return This.NumbersSmallerThanQRT(_n_, :stzList)

		def NumbersSmallerThanQRT(_n_, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.NumbersSmallerThan(_n_) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NumbersSmallerThan(_n_) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def NumbersLessThan(_n_)
			return This.NumbersSmallerThan(_n_)

			def NumbersLessThanQ(_n_)
				return This.NumbersSmallerThanQ(_n_)

			def NumbersLessThanQRT(_n_, pcReturnType)
				return This.NumbersSmallerThanQRT(_n_, pcReturnType)

		#>

	#-- Z/EXTENDED FORM

	def NumbersSmallerThanZ(_n_)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_anResult_ = []

		for i = 1 to _nLen_
			if _anContent_[i] < _n_
				_aResult_ + [ _anContent_[i], i ]
			ok
		next

		return _aResult_

		#< @FunctionAlternativeForm

		def NumbersLessThanZ(_n_)
			return This.NumbersSmallerThanZ(_n_)

		#>

	  #---------------------------------------------------#
	 #  GETTING THE NUMBERS GREATER THAN A GIVEN NUMBER  #
	#---------------------------------------------------#

	def NumbersGreaterThan(_n_)
		if NOT This.Contains(_n_)
			return []
		ok
	
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_anResult_ = []

		for i = 1 to _nLen_
			if _anContent_[i] > _n_
				_anResult_ + _anContent_[i]
			ok
		next

		return _anResult_

		#< @FunctionFluentForms

		def NumbersGreaterThanQ(_n_)
			return This.NumbersGreaterThanQRT(_n_, :stzList)

		def NumberGreaterThanQRT(_n_, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.NumbersGreaterThan(_n_) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NumbersGreaterThan(_n_) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def NumbersLargerThan(_n_)
			return This.NumberSmallerThan(_n_)

			def NumbersLargerThanQ(_n_)
				return This.NumberSmallerThanQ(_n_)

			def NumbersLargerThanQRT(_n_, pcReturnType)
				return This.NumberSmallerThanQ(_n_, pcReturnType)

		def NumbersBiggerThan(_n_)
			return This.NumberSmallerThan(_n_)

			def NumbersBiggerThanQ(_n_)
				return This.NumberSmallerThanQ(_n_)

			def NumbersBiggerThanQRT(_n_, pcReturnType)
				return This.NumberSmallerThanQ(_n_, pcReturnType)

		def NumbersMoreThan(_n_)
			return This.NumberSmallerThan(_n_)

			def NumbersMoreThanQ(_n_)
				return This.NumberSmallerThanQ(_n_)

			def NumbersMoreThanQRT(_n_, pcReturnType)
				return This.NumberSmallerThanQ(_n_, pcReturnType)

		#>

	#-- Z/EXTENDED FORM

	def NumbersGreaterThanZ(_n_)
		if NOT This.Contains(_n_)
			return []
		ok
	
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			if _anContent_[i] > _n_
				_aResult_ + [ _aContent_[i], i ]
			ok
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def NumbersLargerThanZ(_n_)
			return This.NumberSmallerThan(_n_)

		def NumbersBiggerThanZ(_n_)
			return This.NumberSmallerThan(_n_)

		def NumbersMoreThanZ(_n_)
			return This.NumberSmallerThan(_n_)

		#>

	  #-------------------------------------------------#
	 #  GETTING THE NUMBERS OTHER THAN A GIVEN NUMBER  #
	#-------------------------------------------------#

	def NumbersOtherThan(_n_)
		if isList(_n_)
			return This.NumbersOtherThanMany(_n_)
		ok

		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_anResult_ = []

		for i = 1 to _nLen_
			if _anContent_[i] != _n_
				_anResult_ + _anContent_[i]
			ok
		next

		return _anResult_

		#< @FunctionFluentForms

		def NumbersOtherThanQ(_n_)
			return new NumbersOtherThanQRT(_n_, :stzList)

		def NumbersOtherThanQRT(_n_, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.NumbersOtherThan(_n_) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.NumbersOtherThan(_n_) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def NumbersDifferentFrom(_n_)
			return This.NumbersOtherThan(_n_)

			def NumbersDifferentFromQ(_n_)
				return This.NumbersOtherThanQ(_n_)

			def NumbersDifferentFromQRT(_n_, pcReturnType)
				return This.NumbersOtherThanQRT(_n_, pcReturnType)

		def NumbersDifferentOf(_n_)
			return This.NumbersOtherThan(_n_)

			def NumbersDifferentOfQ(_n_)
				return This.NumbersOtherThanQ(_n_)

			def NumbersDifferentOfQRT(_n_, pcReturnType)
				return This.NumbersOtherThanQRT(_n_, pcReturnType)

		def NumbersDifferentTo(_n_)
			return This.NumbersOtherThan(_n_)

			def NumbersDifferentToQ(_n_)
				return This.NumbersOtherThanQ(_n_)

			def NumbersDifferentToQRT(_n_, pcReturnType)
				return This.NumbersOtherThanQRT(_n_, pcReturnType)

		#>

	#-- Z/EXTENDED FORM

	def NumbersOtherThanZ(_n_)
		if isList(_n_)
			return This.NumbersOtherThanMany(_n_)
		ok

		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			if _anContent_[i] != _n_
				_aResult_ + [ _aContent_[i], i ]
			ok
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def NumbersDifferentFromZ(_n_)
			return This.NumbersOtherThanZ(_n_)

		def NumbersDifferentOfZ(_n_)
			return This.NumbersOtherThanZ(_n_)

		def NumbersDifferentToZ(_n_)
			return This.NumbersOtherThanZ(_n_)

		#>

	  #-----------------------------------------------------#
	 #  GETTING THE NUMBERS OTHER THAN MANY GIVEN NUMBERS  #
	#-----------------------------------------------------#

	def NumbersOtherThanMany(_anNumbers_)
		if NOT (isList(_anNumbers_) and Q(_anNumbers_).IsListOfNumbers())
			StzRaise("Incorrect param type! anNumbers must be a list of numbers.")
		ok

		_anContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_anResult_ = []

		for i = 1 to _nLen_
			if NOT StzFindFirst(_anNumbers_, _anContent_[i])
				_anResult_ + _aContent_[i]
			ok
		next

		return _anResult_

		#< @FunctionAlternativeForms

		def NumbersDifferentFromMany(_anNumbers_)
			return This.NumbersOtherThanMany(_anNumbers_)

		def NumbersDifferentOfMany(_anNumbers_)
			return This.NumbersOtherThanMany(_anNumbers_)

		def NumbersDifferentToMany(_anNumbers_)
			return This.NumbersOtherThanMany(_anNumbers_)

		#--

		def NumbersOtherThanThese(_anNumbers_)
			return This.NumbersOtherThanMany(_anNumbers_)

		def NumbersDifferentFromThese(_anNumbers_)
			return This.NumbersOtherThanMany(_anNumbers_)

		def NumbersDifferentOfThese(_anNumbers_)
			return This.NumbersOtherThanMany(_anNumbers_)

		def NumbersDifferentThese(_anNumbers_)
			return This.NumbersOtherThanMany(_anNumbers_)

		#>

	#-- Z/EXTENDED FORM

	def NumbersOtherThanManyZ(_anNumbers_)
		if NOT (isList(_anNumbers_) and Q(_anNumbers_).IsListOfNumbers())
			StzRaise("Incorrect param type! anNumbers must be a list of numbers.")
		ok

		_anContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			if NOT StzFindFirst(_anNumbers_, _anContent_[i])
				_aResult_ + [ _aContent_[i], i ]
			ok
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def NumbersDifferentFromManyZ(_anNumbers_)
			return This.NumbersOtherThanManyZ(_anNumbers_)

		def NumbersDifferentOfManyZ(_anNumbers_)
			return This.NumbersOtherThanManyZ(_anNumbers_)

		def NumbersDifferentToManyZ(_anNumbers_)
			return This.NumbersOtherThanManyZ(_anNumbers_)

		#--

		def NumbersOtherThanTheseZ(_anNumbers_)
			return This.NumbersOtherThanManyZ(_anNumbers_)

		def NumbersDifferentFromTheseZ(_anNumbers_)
			return This.NumbersOtherThanManyZ(_anNumbers_)

		def NumbersDifferentOfTheseZ(_anNumbers_)
			return This.NumbersOtherThanManyZ(_anNumbers_)

		def NumbersDifferentTheseZ(_anNumbers_)
			return This.NumbersOtherThanManyZ(_anNumbers_)

		#>

	  #--------------------------------------------#
	 #  GETTING NUMBERS OUTSIDE A GIVEN POSITION  #
	#--------------------------------------------#

	def NumbersOutsidePosition(_n_)
		_anPos_ = Q( 1 : This.NumberOfItems() ) - _n_
		_anResult_ = This.ItemsAtPositions(_anPos_)

		return _anResult_

		#< @FunctionAlternativeForms

		def NumbersBeforeAndAfterPosition(_n_)
			return This.NumbersOutsidePosition(_n_)

		def NumbersAfterAndBeforePosition(_n_)
			return This.NumbersOutsidePosition(_n_)

		def NumbersBeforeOrAfterPosition(_n_)
			return This.NumbersOutsidePosition(_n_)

		def NumbersAfterOrBeforePosition(_n_)
			return This.NumbersOutsidePosition(_n_)

		#>

	#-- Z/EXTENDED FORM

	def NumbersOutsidePositionZ(_n_)
		_anPos_ = Q( 1 : This.NumberOfItems() ) - _n_
		_nLen_ = len(_anPos_)

		_aResult_ = []

		for i = 1 to _nLen_
			_aResult_ + [ This.Item(_anPos_[i]), _anPos_[i] ]
		next

		return _nResult_

		#< @FunctionAlternativeForms

		def NumbersBeforeAndAfterPositionZ(_n_)
			return This.NumbersOutsidePositionZ(_n_)

		def NumbersAfterAndBeforePositionZ(_n_)
			return This.NumbersOutsidePositionZ(_n_)

		def NumbersBeforeOrAfterPositionZ(_n_)
			return This.NumbersOutsidePositionZ(_n_)

		def NumbersAfterOrBeforePositionZ(_n_)
			return This.NumbersOutsidePositionZ(_n_)

		#>

	  #----------------------------------------------------------#
	 #  GETTING NUMNBERS IN THE LIST BETWEEN TWO GIVEN NUMBERS  #
	#==========================================================#

	def NumbersBetween(nMin, nMax)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_anResult_ = []

		for i = 1 to _nLen_
			if _anContent_[i] > nMin and _anContent_[i] < nMax
				_anResult_ + _anContent_[i]
			ok
		next

		return _anResult_

	#-- Z/EXTENDED FORM

	def NumbersBetweenZ(nMin, nMax)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			if _anContent_[i] > nMin and _anContent_[i] < nMax
				_aResult_ + [ _anContent_[i], i ]
			ok
		next

		return _aResult_

	  #------------------------------------------------------------------------#
	 #  GETTING NUMNBERS IN THE LIST BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#------------------------------------------------------------------------#

	def NumbersBetweenIB(nMin, nMax)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_anResult_ = []

		for i = 1 to _nLen_
			if _anContent_[i] >= nMin and _anContent_[i] <= nMax
				_anResult_ + _anContent_[i]
			ok
		next

		return _anResult_

	#-- Z/EXTENDED FORM

	def NumbersBetweenIBZ(nMin, nMax)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			if _anContent_[i] >= nMin and _anContent_[i] <= nMax
				_aResult_ + [ _anContent_[i], i ]
			ok
		next

		return _aResult_

	  #--------------------------------------------------------------#
	 #  GETTING NUMNBERS IN THE LIST NOT BETWEEN TWO GIVEN NUMBERS  #
	#===============================================================#

	def NumbersNotBetween(nMin, nMax)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_anResult_ = []

		for i = 1 to _nLen_
			if NOT( _anContent_[i] > nMin and _anContent_[i] < nMax )
				_anResult_ + _anContent_[i]
			ok
		next

		return _anResult_

	#-- Z/EXTENDED FORM

	def NumbersNotBetweenZ(nMin, nMax)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			if NOT ( _anContent_[i] > nMin and _anContent_[i] < nMax )
				_aResult_ + [ _anContent_[i], i ]
			ok
		next

		return _aResult_

	  #-----------------------------------------------------------------------------#
	 #  GETTING NUMNBERS IN THE LIST NOT BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#-----------------------------------------------------------------------------#

	def NumbersNotBetweenIB(nMin, nMax)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_anResult_ = []

		for i = 1 to _nLen_
			if NOT ( _anContent_[i] >= nMin and _anContent_[i] <= nMax )
				_anResult_ + _anContent_[i]
			ok
		next

		return _anResult_

	#-- Z/EXTENDED FORM

	def NumbersNotBetweenIBZ(nMin, nMax)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			if NOT ( _anContent_[i] >= nMin and _anContent_[i] <= nMax )
				_aResult_ + [ _anContent_[i], i ]
			ok
		next

		return _aResult_

	def AreNegative()
		
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT (0+ _anContent_[i]) < 0
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		#< @FunctionFluentForm

		def AreNegativeQ()
			if This.AreNegative()
				return This
			else
				return AFalseObject()
			ok
		#>

		#< @FunctionAlternativeForm

		def Nagative()
			return This.AreNagative()

			def NegaiveQ()
				return This.AreNegativeQ()
		#>

		#< @FunctionStatementForms

		def IsNegativeX()
			return This.AreNegativeX()

		def AreNegativeX()
	
			_bTruth_ = TruthStatement()
	
			if _bTruth_ = 1
	
				return This.AreNegative()
	
			else
	
				if This.ContainsNegativeNumbers()
					return 0
				else
					return 1
				ok
	
			ok

			def NegativeX()
				return This.AreNegativeX()

		#>

	def ArePositive()
		
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT (0+ _anContent_[i]) > 0
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		#< @FunctionFluentForm

		def ArePositiveQ()
			if This.ArePositive()
				return This
			else
				return AFalseObject()
			ok
		#>

		#< @FunctionAlternativeForm

		def Positive()
			return This.ArePositive()

			def PositiveQ()
				return This.ArePositiveQ()
		#>

		#< @FunctionStatementForms

		def IsPositiveX()
			return This.ArePositiveX()

		def ArePositiveX()
	
			_bTruth_ = TruthStatement()
	
			if _bTruth_ = 1
	
				return This.ArePositive()
	
			else

				if This.ContainsPositiveNumbers()
					return 0
				else
					return 1
				ok
	
			ok

			def PositiveX()
				return This.ArePositiveX()

		#>

	def ContainsPositiveNumbers()
		_bResult_ = 0

		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		for @i = 1 to _nLen_
			if _anContent_[@i] > 0
				_bResult_ = 1
				exit
			ok
		next

		return _bResult_

	def ContainsNegativeNumbers()
		_bResult_ = 0

		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		for @i = 1 to _nLen_
			if _anContent_[@i] < 0
				_bResult_ = 1
				exit
			ok
		next

		return _bResult_

	def AreGreaterThen(_n_)
		if CheckParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_bResult_ = 1

		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		for @i = 1 to _nLen_
			if _anContent_[@i] < _n_
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def AreOver(_n_)
			return This.AreGreaterThen(_n_)

	def AreSmallerThen(_n_)
		if CheckParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_bResult_ = 1

		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		for @i = 1 to _nLen_
			if _anContent_[@i] > _n_
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def AreUnder(_n_)
			return This.AreSmallerThen(_n_)

	def IsDividableBy(_n_)
		
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_bResult_ = 1

		for i = 1 to _nLen_
			if NOT ( (0+ _anContent_[i]) % _n_ = 0 )
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		#< @FunctionFluentForm

		def IsDividableByQ(_n_)
			if This.IsDividableBy(_n_)
				return This
			else
				return AFalseObject()
			ok

		#>

		#< @FunctionAlternativeForms

		def DividableBy(_n_)
			return This.IsDividableBy(_n_)

			def DividableByQ(_n_)
				return This.IsDividableByQ(_n_)

		#--

		def IsDivisibleBy(_n_)
			return This.IsDividableBy(_n_)

			def IsDivisibleByD(_n_)
				return This.IsDividableByQ(_n_)

		#==

		def CanBeDividedBy(_n_)
			return This.IsDividableBy(_n_)

			def CanBiDividedByQ(_n_)
				return This.IsDividableByQ(_n_)

		def CanBeDivisedBy(_n_)
			return This.IsDividableBy(_n_)

			def CanBeDivisedByQ(_n_)
				return This.IsDividableByQ(_n_)	

	  #==================================================+===============#
	 #  JSUTIFYING THE LIST OF NUMBERS (RETURNED AS A LIST OF STRINGS)  #
	#=================================================+================#

	def Adjust()
		_acResult_ = This.AdjustUsing(" ")
		return _acResult_

		#< @FunctionFluentForm

		def AdjustQ()
			return new stzList( This.Adjust() )

		def AdjustQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Adjust() )

			on :stzListOfStrings
				return new stzListOfStrings( This.Adjust() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def Adjusted()
			return This.Adjust()

			def AdjustedQ()
				return This.AdjustQ()

			def AdjustedQRT(pcReturnType)
				return This.AdjustQRT(pcReturnType)

		def Justified()
			return This.Adjust()

			def JustifiedQ()
				return This.AdjustQ()

			def JustifiedQRT(pcReturnType)
				return This.AdjustQRT(pcReturnType)

		def Justify()
			return This.Adjust()

			def JustifyQ()
				return This.AdjustQ()

			def JustifyQRT(pcReturnType)
				return This.AdjustQRT(pcReturnType)
		#>

	  #---------------------------------------------------------#
	 #  JSUTIFYING THE NUMBERS IN THE LIST USING A GIVEN CHAR  #
	#---------------------------------------------------------#

	def AdjustUsing(c)
		if CheckingParams()
			if NOT (isString(c) and @IsChar(c))
				StzRaise("Incorrect param type! c must be a char.")
			ok
		ok

		_aContent_ = This.Content()
		_nLen_ = len(_aContent_)

		_nMaxSize_ = 0
		_nMaxLeft_ = 0
		_nMaxRight_ = 0

		for i = 1 to _nLen_

			_cNumber_ = ""+ _aContent_[i]

			_nSize_ = len(_cNumber_)
			if _nSize_ > _nMaxSize_
				_nMaxSize_ = _nSize_
			ok

			_nDotPos_ = ring_substr1( _cNumber_, "." )

			if _nDotPos_ = 0
				_nLenLeft_ = _nSize_
				_nLenRight_ = 0

			else
				_nLenLeft_ = _nDotPos_ - 1
				_nLenRight_ = _nSize_ - _nDotPos_

			ok

			if _nLenLeft_ > _nMaxLeft_
				_nMaxLeft_ = _nLenLeft_
			ok

			if _nLenRight_ > _nMaxRight_
				_nMaxRight_ = _nLenRight_
			ok

		next

		# The number without decimal part are adjusted
		# first, by adding a dot and some 0s to them

		for i = 1 to _nLen_

			_cNumber_ = ""+ _aContent_[i]
			_nLenNumber_ = len(_cNumber_)
			_nPosDot_ = ring_substr1(_cNumber_, ".")
			
			if _nPosDot_ = 0
				
				_nAddLeft_ = _nMaxLeft_ - _nLenNumber_
				_nAddRight_ = _nMaxRight_

				_cExtLeft_ = ""
				_cExtRight_ = ""

				for _j_ = 1 to _nAddLeft_
					_cExtLeft_ += c
				next

				for _j_ = 1 to _nAddRight_
					_cExtRight_ += "0"
				next

				_cNumber_ = _cExtLeft_ + _cNumber_ + "." + _cExtRight_

			else
				_nAddLeft_ = _nMaxLeft_ - (_nPosDot_ - 1)
				_nAddRight_ = _nMaxRight_ - (_nLenNumber_ - _nPosDot_)

				_cExtLeft_ = ""
				_cExtRight_ = ""

				for _j_ = 1 to _nAddLeft_
					_cExtLeft_ += c
				next

				for _j_ = 1 to _nAddRight_
					_cExtRight_ += "0"
				next

				_cNumber_ = _cExtLeft_ + _cNumber_ + _cExtRight_

			ok

			_aContent_[i] = _cNumber_

		next

		return _aContent_

		#< @FunctionFluentForm

		def AdjustUsingQ(c)
			return new stzList( This.AdjustUsing(c) )

		def AdjustUsingQRT(c, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.AdjustUsing(c) )

			on :stzListOfStrings
				return new stzListOfStrings( This.AdjustUsing(c) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def AdjustedUsing(c)
			return This.AdjustUsing(c)

			def AdjustedUsingQ(c)
				return This.AdjustUsingQ(c)

			def AdjustedUsingQRT(c, pcReturnType)
				return This.AdjustUsingQRT(c, pcReturnType)

		def JustifiedUsing(c)
			return This.AdjustUsing(c)

			def JustifiedUsingQ(c)
				return This.AdjustUsingQ(c)

			def JustifiedUsingQRT(c, pcReturnType)
				return This.AdjustUsingQRT(c, pcReturnType)

		def JustifyUsing(c)
			return This.AdjustUsing(c)

			def JustifyUsingQ(c)
				return This.AdjustUsingQ(c)

			def JustifyUsingQRT(c, pcReturnType)
				return This.AdjustUsingQRT(c, pcReturnType)

		#>

	  #-------------------------------------------------------#
	 #  JSUTIFYING THE NUMBERS IN THE LIST -- EXTENDED FORM  #
	#-------------------------------------------------------#

	def AdjustXT()
		_acResult_ = This.AdjustUsing("0")
		return _acResult_

		#< @FunctionFluentForm

		def AdjustXTQ()
			return new stzList( This.AdjustXT() )

		def AdjustXTQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.AdjustXT() )

			on :stzListOfStrings
				return new stzListOfStrings( This.AdjustXT() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def AdjustedXT()
			return This.AdjustXT()

			def AdjustedXTQ()
				return This.AdjustXTQ()

			def AdjustedXTQRT(pcReturnType)
				return This.AdjustXTQRT(pcReturnType)

		def JustifiedXT()
			return This.AdjustXT()

			def JustifiedXTQ()
				return This.AdjustXTQ()

			def JustifiedXTQRT(pcReturnType)
				return This.AdjustXTQRT(pcReturnType)

		def JustifyXT()
			return This.AdjustXT()

			def JustifyXTQ()
				return This.AdjustXTQ()

			def JustifyXTQRT(pcReturnType)
				return This.AdjustXTQRT(pcReturnType)
		#>

	  #====================================#
	 #  SORTING THE NUMBERS IN ASCENDING  #
	#====================================#

	def SortInAscending()
		_aResult_ = @Sort(This.Content())
		This.UpdateWith(_aResult_)

		#< @FunctionAlternativeForms

		def SortInAscendingQ()
			This.SortInAscending()
			return This

		def SortUp()
			This.SortInAscending()

			def SortUpQ()
				return This.SortInAscendingQ()

		#>

	def SortedInAscending()
		_aResult_ = This.Copy().SortInAscendingQ().Content()
		return _aResult_

		def SortedUp()
			return This.SortedInAscending()

	  #-------------------------------------#
	 #  SORTING THE NUMBERS IN DESCENDING  #
	#-------------------------------------#

	def SortInDescending()
		# Active form: must mutate self, not just compute and return.
		# Original code did `aResult = new stzList(...).Reversed()` --
		# chained method call on a `new` expression which Ring's
		# parser was choking on (R13 "Object is required"). Split
		# into two statements + actually persist the result.
		_aSidSorted_ = @Sort(This.Content())
		_oSidTemp_ = new stzList(_aSidSorted_)
		_aSidResult_ = _oSidTemp_.Reversed()
		This.UpdateWith(_aSidResult_)

		def SortInDescendingQ()
			This.SortInDescending()
			return This

		def SortDown()
			This.SortInDescending()

			def SortDownQ()
				return This.SortInDescendingQ()

	def SortedInDescending()
		_acResult_ = This.Copy().SortInDescendingQ().Content()
		return _acResult_

		def SortedDown()
			return This.SortedInDescending()
 
	  #-----------------------------------------------------------------#
	 #  SORTING THE STRINGS BY AN EVALUATED EXPRESSION - IN ASCENDING  #
	#=================================================================#
 
	def SortBy(pcExpr)

		if NOT (isString(pcExpr) and Q(pcExpr).ContainsCS("@number", 0))
			StzRaise("Incorrect param! pcExpr must be a string containing @number keyword.")
		ok

		pcExpr = Q(pcExpr).ReplaceQ("@number", "@item").Content()

		_aContent_ = This.ToStzList().SortedBy(pcExpr)
		This.UpdateWith(_aContent_)

		#< @FunctionFluentForm

		def SortByQ(pcExpr)
			This.SortBy(pcExpr)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortByInAscending(pcExpr)
			This.SortBy(pcExpr)

			def SortByInAscendingQ(pcExpr)
				return This.SortByQ(pcExpr)

		def SortByUp(pcExpr)
			This.SortBy(pcExpr)

			def SortByUpQ(pcExpr)
				return This.SortByQ(pcExpr)

		#>

	def SortedBy(pcExpr)
		_aResult_ = This.Copy().SortByQ(pcExpr).Content()
		return _aResult_

		def SortedByInAscending(pcExpr)
			return This.SortedBy(pcExpr)

		def SortedByUp(pcExpr)
			return This.SortedBy(pcExpr)

	  #--------------------------------------------------------#
	 #  SORTING THE NUMBERS BY AN EXPRESSION - IN DESCENDING  #
	#--------------------------------------------------------#
 
	def SortByInDescending(pcExpr)
		_aResult_ = new stzList( This.SortedByInAscending(pcExpr) ).Reversed()
		This.UpdateWith(_aResult_)

		def SortByInDescendingQ(pcExpr)
			This.SortByInDescending(pcExpr)
			return This

		def SortByDown(pcExpr)
			This.SortByInDescending(pcExpr)

			def SortByDownQ(pcExpr)
				return This.SortByInDescendingQ(pcExpr)

	def SortedByInDescending(pcExpr)
		_aResult_ = This.Copy().SortByInDescendingQ(pcExpr).Content()
		return _aResult_

		def SortedByDown(pcExpr)
			return This.SortedByInDescending(pcExpr)

	  #--------------------------------------#
	 #  GETTING THE SPEEDUP OF THE NUMBERS  #
	#======================================#

	def SpeedUps()
		_anNumbers_ = This.Content()
		_nLen_ = len(_anNumbers_)

		if _nLen_ = 1
			return [ 1 ]
		ok

		_anResult_ = []

		for i = 2 to _nLen_
			_n1_ = _anNumbers_[i-1]
			_n2_ = _anNumbers_[i]

			_factor_ = _n1_ / _n2_
			_anResult_ + _factor_
		next

		return _anResult_

		#< @FunctionAlternativeForms

		def SpeedUpsX()
			return This.SpeedUps()

		def SpeedUp()
			return This.SpeedUps()

		def SpeedUpX()
			return This.SpeedUps()

		def PerfGainsX()
			return This.SpeedUps()

		def PerfGainX()
			return This.SpeedUps()

		#>

	  #-------------------------------------------------#
	 #  GETTING THE GAIN FACTOR FROM NUMBER TO NUMBER  #
	#-------------------------------------------------#

	def GainsX()

		_anNumbers_ = This.Content()
		_nLen_ = len(_anNumbers_)

		if _nLen_ = 1
			return [ 1 ]
		ok

		_anResult_ = []

		for i = 2 to _nLen_
			_n1_ = _anNumbers_[i-1]
			_n2_ = _anNumbers_[i]

			_factor_ = _n2_ / _n1_
			_anResult_ + _factor_
		next

		return _anResult_

		#< @FunctionAlternativeForms

		def GainsFactors()
			return This.GainsX()

		def GainX()
			return This.GainsX()

		def GainFactor()
			return This.GainsX()

		def GainsFactor()
			return This.GainsX()

		def GainFactors()
			return This.GainsX()

		#>

	  #-----------------------------------------#
	 #  GETTING THE PERFGAIN FROM THE NUMBERS  #
	#=========================================#

	def PerfGains() # In percentage

		_anNumbers_ = This.Content()
		_nLen_ = len(_anNumbers_)

		if _nLen_ = 1
			return [ 1 ]
		ok

		_anResult_ = []

		for i = 2 to _nLen_
			_n1_ = _anNumbers_[i-1]
			_n2_ = _anNumbers_[i]

			_factor_ = ( (_n1_ - _n2_) / _n1_) * 100
			_anResult_ + _factor_
		next

		return _anResult_

		#< @AlternativeForms

		def PerfGains100()
			return This.PerfGains()

		def PerfGain()
			return This.PerfGains()

		def PerfGain100()
			return This.PerfGains()

	  #---------------------------------------------------#
	 #  GETTING THE RELATIVE GAIN FROM NUMBER TO NUMBER  #
	#---------------------------------------------------#

	def Gains() # In Percentage

		_anNumbers_ = This.Content()
		_nLen_ = len(_anNumbers_)

		if _nLen_ = 1
			return [ 1 ]
		ok

		_anResult_ = []

		for i = 2 to _nLen_
			_n1_ = _anNumbers_[i-1]
			_n2_ = _anNumbers_[i]

			_factor_ = ( (_n2_ - _n1_) / _n2_) * 100
			_anResult_ + _factor_
		next

		return _anResult_

		#< @FunctionAlternativeForms

		def Gain()
			return This.Gains()

		def RelativeGains()
			return This.Gains()

		def RelativeGain()
			return This.Gains()

		#--

		def Gains100()
			return This.Gains()

		def Gain100()
			return This.Gains()

		def RelativeGains100()
			return This.Gains()

		def RelativeGain100()
			return This.Gains()

		#>

	  #------------------------------------------#
	 #  CHECKING IF THE NUMBERS ARE ALL PRIMES  #
	#------------------------------------------#

	def ArePrimes()
		_bResult_ = 1
		_nLen_ = len(@aContent)

		for i = 1 to _nLen_
			if NOT ring_isprime(@aContent[i])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

	  #---------------------------------------------#
	 #  CHECKING IF THE NUMBERS ARE ALL WEIFERICH  #
	#---------------------------------------------#

	def AreWeiferich()
		_bResult_ = 1
		_nLen_ = len(@aContent)

		for i = 1 to _nLen_
			if NOT @IsWeiferich(@aContent[i])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

	  #-----------------------------------------------------------------#
	 #  CHECKINg IF THE LISt IS MADE OF POSITIVE NAD NEGATIVE NUMBERS  #
	#-----------------------------------------------------------------#

	def ContainsPositiveAndNegativeNumbers()

		_nLen_ = len(@aContent)
		if _nLen_ < 2
			return 0
		ok

		for @i = 2 to _nLen_

			if (@aContent[1] > 0 and @aContent[@i] < 0) or
			   (@aContent[1] < 0 and @aContent[@i] > 0)

				return 1
			ok
		next

		return 0

		#< @FunctionAlternativeForms

		def ContainsNegativeAndPositiveNumbers()
			return This.ContainsPositiveAndNegativeNumbers()

		def IsMadeOfPositiveAndNegativeNumbers()
			return This.ContainsPositiveAndNegativeNumbers()

		def IsMadeOfNegativeAndPositiveNumbers()
			return This.ContainsPositiveAndNegativeNumbers()

		#>

	  #---------------------------------------------------------#
	 #  CHECKINg IF THE LISt IS MADE OF ONLY NON-ZERO NUMBERS  #
	#---------------------------------------------------------#

	def AreNonZeroNumbers()
	
		_nLen_ = len(@aContent)
	
		for i = 1 to _nLen_
			if @aContent[i] = 0
				return FALSE
			ok
		next
		
		return TRUE
	
		def AreNonNullNumbers()
			return This.AreNonZeroNumbers()

	  #------------------------------------------------------#
	 #  CHECKINg IF THE NUMBERS HAVE A CONSTANT DIFFERENCE  #
	#------------------------------------------------------#

	def HaveSameDifference()
		return @HaveSameDifference(This.Content())
