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
		return 0
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
		return 0
	ok

	_nLen_ = len(_anNumbers_)

	for i = 1 to _nLen_
		if NOT (isNumber(_anNumbers_[i]) and _anNumbers_[i] != 0)
			return 0
		ok
	next
	
	return 1

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

		if NOT (isList(panNumbers) and @IsListOfNumbers(panNumbers))
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

		if NOT (isList(panNumbers) and @IsListOfNumbers(panNumbers))
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

		if NOT (isList(panNumbers) and @IsListOfNumbers(panNumbers))
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

		if NOT (isList(panNumbers) and @IsListOfNumbers(panNumbers))
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

		if NOT (isList(panNumbers) and @IsListOfNumbers(panNumbers))
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

		if NOT (isList(panNumbers) and @IsListOfNumbers(panNumbers))
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

		if NOT (isList(panNumbers) and @IsListOfNumbers(panNumbers))
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

		if NOT (isList(panNumbers) and @IsListOfNumbers(panNumbers))
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
			primes + i
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

# Is another name for stzListOfNumbers, so every method and every form is the same.
#
# Use whichever name reads better at the call site; the class adds nothing of its own.
#
#   receiver   o1 = new stzNumbers([ 3, 1, 4, 1, 5, 9, 2, 6 ])
#   example    ? @@( o1.Top3() )
#              #--> [ 5, 6, 9 ]
#   see        stzListOfNumbers
class stzNumbers from stzListOfNumbers

# Holds a list of numbers and finds, ranks, compares, edits and sorts them, and answers sums, means and differences.
#
# A stzListOfNumbers wraps a Ring list that holds only numbers; building it from anything else
# raises an error. Reach for it when the question is about the numbers as a series: the smallest and
# largest (Min, Top3), the nearest to a value (Nearest), the steps between neighbours (Diff, Steps),
# the totals (Sum, Mean, Median), arithmetic on every number at once (AddToEach, MultiplyEachBy),
# filters (NumbersBetween) and sorting. Active forms change the list in place, passive forms (the
# ones ending in ed, or beginning with Each) return a changed copy. Rank methods such as Bottom3 and
# Top3 work on distinct values and answer in ascending order. The random picks draw from the list
# itself, every position equally likely, and raise when nothing qualifies.
#
#   receiver   o1 = new stzListOfNumbers([ 3, 1, 4, 1, 5, 9, 2, 6 ])
#   example    ? @@( o1.Top3() )
#              #--> [ 5, 6, 9 ]
#   see        stzList, stzNumber, stzNumBuffer
class stzListOfNumbers from stzList
	@aContent
	
	// TODO: Add the possibility to add a list of numbers in strings
	// --> So we can manage numbers as stzNumbers (wich can be provided
	// in strings to conserve their round.
	# Builds the list from a list of numbers, or from text that spells one; anything else raises an error.
	#
	#   returns    nothing; the object is built
	#   note       an empty list is accepted
	#@ aka  Build the list from the given Ring list of numbers.
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

	# Returns the numbers as a plain Ring list.
	#
	#   returns    a list of numbers
	#   see        Value, ListOfNumbers
	#@ aka  The numbers as a raw Ring list.
	def Content()
		return @aContent

		# Returns the held numbers as a plain Ring list, the same answer as the content.
		#
		#   returns    a list of numbers
		#   see        Content
		#@ aka  The raw numbers list (same as Content).
		def Value()
			return Content()

	# Returns a new stzListOfNumbers holding the same numbers; changing it leaves the original alone.
	#
	#   returns    a stzListOfNumbers
	#   see        ToStzList
	#@ aka  A new stzListOfNumbers with the same numbers.
	def Copy()
		return new stzListOfNumbers(This.Content())

	# Returns the numbers as a plain Ring list, in the order they are held.
	#
	#   returns    a list of numbers
	#   see        Content
	#@ aka  Same as Content: the numbers as a raw Ring list.
	def ListOfNumbers()
		return Content()

		def Numbers()
			return This.Content()

			def NumbersQ()
				return This.NumbersQRT(:stzList)

			# The numbers, in the requested return type (QRT).
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

	# The numbers satisfying the given W condition.
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

		# The numbers satisfying the W condition, in the requested
		# return type.
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

	# Returns the numbers as a stzList, to use the general list methods on them.
	#
	#   returns    a stzList
	#   see        Copy, ToStzListOfStrings
	#@ aka  The numbers as a stzList object.
	def ToStzList()
		return new stzList(This.Content())

	# Returns the numbers as a stzNumBuffer, the resident numeric tier, crossing into the engine once.
	#
	#   returns    a stzNumBuffer
	#   note       free the buffer with Free() when done; later reductions on it do not cross again
	#   see        ToStzList
	#@ aka  THE DOOR TO THE RESIDENT TIER (numeric foundation, phase 3).
	def ToStzNumBuffer()
		return new stzNumBuffer(@aContent)

		def ToNumBuffer()
			return This.ToStzNumBuffer()

	# Returns each number written as text, as a stzListOfStrings.
	#
	#   returns    a stzListOfStrings
	#   see        NumbersTurnedToStrings, ToStzList
	#@ aka  Each number turned into a string, as a stzListOfStrings.
	def ToStzListOfStrings()
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_acStrings_ = []

		for i = 1 to _nLen_
			_acStrings_ + ( ""+ _anContent_[i] )
		next

		_oResult_ = new stzListOfStrings(_acStrings_)
		return _oResult_

	# Returns each number written as text, in a plain list.
	#
	#   returns    a list of strings
	#   see        ToStzListOfStrings
	#@ aka  The numbers as strings, in a raw Ring list.
	def NumbersTurnedToStrings()
		_aResult_ = This.ToStzListOfStrings().Content()

		return _aResult_

		def Stringified()
			return This.NumbersTurnedToStrings()

		def AllNumbersTurnedToStrings()
			return This.NumbersTurnedToStrings()

	# Returns the number held at a position; a negative position counts from the end.
	#
	#   _n_        the position, 1 for the first number
	#   returns    a number
	#   note       position 0 or a position past the end raises an error
	#   see        ToStzList
	#@ aka  The number at position n.
	def NumberAt(_n_)
		return This.ItemAt(_n_)	# Inherited from stzList

		def NumberAtPosition(_n_)
			return This.NumberAt(_n_)

		def Number(_n_)
			return This.NumberAt(_n_)

	  #================================#
	 #  FINDING THE LOWEST N NUMBERS  #
	#================================#

	# Returns the n smallest distinct numbers, in ascending order; fewer when the list has fewer distinct numbers.
	#
	#   _n_        how many numbers to return
	#   returns    a list of numbers
	#   note       repeated values count once; n below 1 answers an empty list
	#   see        FindNLowestNumbers, NLargestNumbers
	#@ aka  The n smallest numbers, as a list.
	def NLowestNumbers(_n_)
		_anSet_ = This.ToSetQ().Sorted()
		_nSet_ = len(_anSet_)

		if _n_ > _nSet_
			_n_ = _nSet_
		ok

		_anResult_ = []
		for i = 1 to _n_
			_anResult_ + _anSet_[i]
		next

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

	# Returns the positions of every number that is among the n smallest distinct ones, in position order.
	#
	#   _n_        how many distinct numbers to take
	#   returns    a list of positions
	#   note       answers fewer numbers when it holds fewer than n distinct ones
	#   see        NLowestNumbers, FindNLargestNumbers
		#>
	#@ aka  The positions of the n smallest numbers.
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

	# Pairs each wanted number with every position it occupies: [ [number, position], ... ],
	# the numbers in the order given, the positions of one number ascending.
	def _PairsOfNumbersWithPositions(panWanted)
		_anContent_ = @aContent
		_nLen_ = len(_anContent_)
		_nWanted_ = len(panWanted)

		_aResult_ = []
		for j = 1 to _nWanted_
			for i = 1 to _nLen_
				if _anContent_[i] = panWanted[j]
					_aResult_ + [ panWanted[j], i ]
				ok
			next
		next

		return _aResult_

	# The n smallest numbers along with their positions:
	# [ [number, position], ... ].
	def NLowestNumbersZ(_n_)
		return This._PairsOfNumbersWithPositions( This.NLowestNumbers(_n_) )

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

		# Same as NLowestNumbersZ.
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

	# Returns the position of the first smallest number; 0 for an empty list.
	#
	#   returns    a position
	#   see        Min, FindMax
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

	# Returns the smallest number; 0 for an empty list.
	#
	#   returns    a number
	#   see        FindMin, Max
	def Min()
		_pMiList = This._EngineListFromContent()
		if _pMiList != ""
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

	# Returns the smallest number with the position of its first occurrence, as [ number, position ].
	#
	#   returns    a [ number, position ] pair; an empty list for an empty list
	#   see        Min, FindMin
	def MinZ()
		if len(@aContent) = 0
			return []
		ok

		return This.NLowestNumbersZ(1)[1]

		def MinNumberZ()
			return This.MinZ()

		def MinAndItsPosition()
			return This.MinZ()

		def MinNumberAndItsPosition()
			return This.MinZ()

	# Returns the 3 smallest distinct numbers, in ascending order.
	#
	#   returns    a list of 3 numbers
	#   note       answers fewer numbers when it holds fewer than 3 distinct ones
	#   see        Bottom5, Top3
	#@ aka  --
	def Bottom3()
		return This.BottomN(3)

	# Returns the three smallest distinct numbers, in ascending order.
	#
	#   returns    a list of 3 numbers
	#   note       answers fewer numbers when it holds fewer than 3 distinct ones
	#   see        Bottom3
	def Bottom3Numbers()
		return This.BottomN(3)

	# Returns the 5 smallest distinct numbers, in ascending order.
	#
	#   returns    a list of 5 numbers
	#   note       answers fewer numbers when it holds fewer than 5 distinct ones
	#   see        Bottom3, Top5
	def Bottom5()
		return This.BottomN(5)

	# Returns the five smallest distinct numbers, in ascending order.
	#
	#   returns    a list of 5 numbers
	#   note       answers fewer numbers when it holds fewer than 5 distinct ones
	#   see        Bottom5
	def Bottom5Numbers()
		return This.BottomN(5)

	# Returns the 7 smallest distinct numbers, in ascending order.
	#
	#   returns    a list of 7 numbers
	#   note       answers fewer numbers when it holds fewer than 7 distinct ones
	#   see        Bottom5, Top7
	def Bottom7()
		return This.BottomN(7)

	# Returns the seven smallest distinct numbers, in ascending order.
	#
	#   returns    a list of 7 numbers
	#   note       answers fewer numbers when it holds fewer than 7 distinct ones
	#   see        Bottom7
	def Bottom7Numbers()
		return This.BottomN(7)

	# Returns the 10 smallest distinct numbers, in ascending order.
	#
	#   returns    a list of 10 numbers
	#   note       answers fewer numbers when it holds fewer than 10 distinct ones
	#   see        Bottom7, Top10
	def Bottom10()
		return This.BottomN(10)

	# Returns the ten smallest distinct numbers, in ascending order.
	#
	#   returns    a list of 10 numbers
	#   note       answers fewer numbers when it holds fewer than 10 distinct ones
	#   see        Bottom10
	def Bottom10Numbers()
		return This.BottomN(10)

	# Returns the positions of every number that is among the 3 smallest distinct ones.
	#
	#   returns    a list of positions
	#   note       answers fewer numbers when it holds fewer than 3 distinct ones
	#   see        Bottom3, FindTop3
	#@ aka  --
	def FindBottom3()
		return This.FindBottomN(3)

	# Returns the positions where the three smallest distinct numbers occur, in position order.
	#
	#   returns    a list of positions
	#   note       answers fewer numbers when it holds fewer than 3 distinct ones
	#   see        FindBottom3
	def FindBottom3Numbers()
		return This.FindBottomN(3)

	# Returns the positions of every number that is among the 5 smallest distinct ones.
	#
	#   returns    a list of positions
	#   note       answers fewer numbers when it holds fewer than 5 distinct ones
	#   see        Bottom5, FindTop5
	def FindBottom5()
		return This.FindBottomN(5)

	# Returns the positions where the five smallest distinct numbers occur, in position order.
	#
	#   returns    a list of positions
	#   note       answers fewer numbers when it holds fewer than 5 distinct ones
	#   see        FindBottom5
	def FindBottom5Numbers()
		return This.FindBottomN(5)

	# Returns the positions of every number that is among the 7 smallest distinct ones.
	#
	#   returns    a list of positions
	#   note       answers fewer numbers when it holds fewer than 7 distinct ones
	#   see        Bottom7, FindTop7
	def FindBottom7()
		return This.FindBottomN(7)

	# Returns the positions where the seven smallest distinct numbers occur, in position order.
	#
	#   returns    a list of positions
	#   note       answers fewer numbers when it holds fewer than 7 distinct ones
	#   see        FindBottom7
	def FindBottom7Numbers()
		return This.FindBottomN(7)

	# Returns the positions of every number that is among the 10 smallest distinct ones.
	#
	#   returns    a list of positions
	#   note       answers fewer numbers when it holds fewer than 10 distinct ones
	#   see        Bottom10, FindTop10
	def FindBottom10()
		return This.FindBottomN(10)

	# Returns the positions where the ten smallest distinct numbers occur, in position order.
	#
	#   returns    a list of positions
	#   note       answers fewer numbers when it holds fewer than 10 distinct ones
	#   see        FindBottom10
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

	# Returns [ number, position ] pairs for the 3 smallest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Bottom3, FindBottom3
	def Bottom3AndTheirPositions()
		return This.BottomNZ(3)

	# Returns [ number, position ] pairs for the three smallest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Bottom3AndTheirPositions
	def Bottom3NumbersAndTheirPositions()
		return This.BottomNZ(3)

	# Returns [ number, position ] pairs for the 5 smallest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Bottom5, FindBottom5
	def Bottom5AndTheirPositions()
		return This.BottomNZ(5)

	# Returns [ number, position ] pairs for the five smallest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Bottom5AndTheirPositions
	def Bottom5NumbersAndTheirPositions()
		return This.BottomNZ(5)

	# Returns [ number, position ] pairs for the 7 smallest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Bottom7, FindBottom7
	def Bottom7AndTheirPositions()
		return This.BottomNZ(7)

	# Returns [ number, position ] pairs for the seven smallest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Bottom7AndTheirPositions
	def Bottom7NumbersAndTheirPositions()
		return This.BottomNZ(7)

	# Returns [ number, position ] pairs for the 10 smallest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Bottom10, FindBottom10
	def Bottom10AndTheirPositions()
		return This.BottomNZ(10)

	# Returns [ number, position ] pairs for the ten smallest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Bottom10AndTheirPositions
	def Bottom10NumbersAndTheirPositions()
		return This.BottomNZ(10)

	  #=================================#
	 #  FINDING THE LARGEST N NUMBERS  #
	#=================================#

	# Returns the n largest distinct numbers, in ascending order; fewer when the list has fewer distinct numbers.
	#
	#   _n_        how many numbers to return
	#   returns    a list of numbers
	#   note       unlike NLowestNumbers it does not raise when the list is too short
	#   see        FindNLargestNumbers, NLowestNumbers
	#@ aka  The n largest numbers, as a list.
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

		# Same as NLargestNumbers.
		def NTopNumbers(_n_)
			return This.NLargestNumbers(_n_)

		def TopNNumbers(_n_)
			return This.NLargestNumbers(_n_)

		def NTop(_n_)
			return This.NLargestNumbers(_n_)

		def TopN(_n_)
			return This.NLargestNumbers(_n_)

	# Returns the positions of every number that is among the n largest distinct ones, in position order.
	#
	#   _n_        how many distinct numbers to take
	#   returns    a list of positions
	#   see        NLargestNumbers, FindNLowestNumbers
		#>
	#@ aka  The positions of the n largest numbers.
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

		# Same as FindNLargestNumbers.
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

	# The n largest numbers along with their positions:
	# [ [number, position], ... ].
	def NLargestNumbersZ(_n_)
		return This._PairsOfNumbersWithPositions( This.NLargestNumbers(_n_) )

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

		# Same as NLargestNumbersZ.
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

		# Same as NLargestNumbersZ.
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

	# Returns the position of the first largest number; 0 for an empty list.
	#
	#   returns    a position
	#   see        Max, FindMin
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

	# Returns the largest number; 0 for an empty list.
	#
	#   returns    a number
	#   see        FindMax, Min
	def Max()
		_pMxList = This._EngineListFromContent()
		if _pMxList != ""
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

	# Returns the largest number with the position of its first occurrence, as [ number, position ].
	#
	#   returns    a [ number, position ] pair; an empty list for an empty list
	#   see        Max, FindMax
	def MaxZ()
		if len(@aContent) = 0
			return []
		ok

		return This.NLargestNumbersZ(1)[1]

		def MaxNumberZ()
			return This.MaxZ()

		def MaxAndItsPosition()
			return This.MaxZ()

		def MaxNumberAndItsPosition()
			return This.MaxZ()

	# Returns the 3 largest distinct numbers, in ascending order; fewer when there are fewer distinct numbers.
	#
	#   returns    a list of numbers
	#   see        Top5, Bottom3
	#@ aka  --
	def Top3()
		return This.TopN(3)

	# Returns the three largest distinct numbers, in ascending order.
	#
	#   returns    a list of numbers
	#   see        Top3
	def Top3Numbers()
		return This.TopN(3)

	# Returns the 5 largest distinct numbers, in ascending order; fewer when there are fewer distinct numbers.
	#
	#   returns    a list of numbers
	#   see        Top3, Bottom5
	def Top5()
		return This.TopN(5)

	# Returns the five largest distinct numbers, in ascending order.
	#
	#   returns    a list of numbers
	#   see        Top5
	def Top5Numbers()
		return This.TopN(5)

	# Returns the 7 largest distinct numbers, in ascending order; fewer when there are fewer distinct numbers.
	#
	#   returns    a list of numbers
	#   see        Top5, Bottom7
	def Top7()
		return This.TopN(7)

	# Returns the seven largest distinct numbers, in ascending order.
	#
	#   returns    a list of numbers
	#   see        Top7
	def Top7Numbers()
		return This.TopN(7)

	# Returns the 10 largest distinct numbers, in ascending order; fewer when there are fewer distinct numbers.
	#
	#   returns    a list of numbers
	#   see        Top7, Bottom10
	def Top10()
		return This.TopN(10)

	# Returns the ten largest distinct numbers, in ascending order.
	#
	#   returns    a list of numbers
	#   see        Top10
	def Top10Numbers()
		return This.TopN(10)

	# Returns the positions of every number that is among the 3 largest distinct ones, in position order.
	#
	#   returns    a list of positions
	#   see        Top3, FindBottom3
	#@ aka  --
	def FindTop3()
		return This.FindTopN(3)

	# Returns the positions where the three largest distinct numbers occur, in position order.
	#
	#   returns    a list of positions
	#   see        FindTop3
	def FindTop3Numbers()
		return This.FindTopN(3)

	# Returns the positions of every number that is among the 5 largest distinct ones, in position order.
	#
	#   returns    a list of positions
	#   see        Top5, FindBottom5
	def FindTop5()
		return This.FindTopN(5)

	# Returns the positions where the five largest distinct numbers occur, in position order.
	#
	#   returns    a list of positions
	#   see        FindTop5
	def FindTop5Numbers()
		return This.FindTopN(5)

	# Returns the positions of every number that is among the 7 largest distinct ones, in position order.
	#
	#   returns    a list of positions
	#   see        Top7, FindBottom7
	def FindTop7()
		return This.FindTopN(7)

	# Returns the positions where the seven largest distinct numbers occur, in position order.
	#
	#   returns    a list of positions
	#   see        FindTop7
	def FindTop7Numbers()
		return This.FindTopN(7)

	# Returns the positions of every number that is among the 10 largest distinct ones, in position order.
	#
	#   returns    a list of positions
	#   see        Top10, FindBottom10
	def FindTop10()
		return This.FindTopN(10)

	# Returns the positions where the ten largest distinct numbers occur, in position order.
	#
	#   returns    a list of positions
	#   see        FindTop10
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

	# Returns [ number, position ] pairs for the 3 largest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Top3, FindTop3
	def Top3AndTheirPositions()
		return This.TopNZ(3)

	# Returns [ number, position ] pairs for the three largest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Top3AndTheirPositions
	def Top3NumbersAndTheirPositions()
		return This.TopNZ(3)

	# Returns [ number, position ] pairs for the 5 largest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Top5, FindTop5
	def Top5AndTheirPositions()
		return This.TopNZ(5)

	# Returns [ number, position ] pairs for the five largest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Top5AndTheirPositions
	def Top5NumbersAndTheirPositions()
		return This.TopNZ(5)

	# Returns [ number, position ] pairs for the 7 largest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Top7, FindTop7
	def Top7AndTheirPositions()
		return This.TopNZ(7)

	# Returns [ number, position ] pairs for the seven largest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Top7AndTheirPositions
	def Top7NumbersAndTheirPositions()
		return This.TopNZ(7)

	# Returns [ number, position ] pairs for the 10 largest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Top10, FindTop10
	def Top10AndTheirPositions()
		return This.TopNZ(10)

	# Returns [ number, position ] pairs for the ten largest distinct numbers, one pair per occurrence.
	#
	#   returns    a list of [ number, position ] pairs
	#   see        Top10AndTheirPositions
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
			  StzFindFirst(pcBeforeOrAfter, [
				:Before, :After, :BeforeIt, :AfterIt,
				:BeforeOrAfter, :BeforeOrAfterIt,
				:AfterOrBefore, :AfterOrBeforeIt,

				:ComingBefore, :ComingAfter, :ComingBeforeIt, :ComingAfterIt,
				:ComingBeforeOrAfter, :ComingBeforeOrAfterIt,
				:ComingAfterOrBefore, :ComingAfterOrBeforeIt

			  ]) > 0)

			StzRaise("Incorrect param type! pcComingBeforeOrAfter must be a string equal to :Before, :After, or :BeforeOrAfter.")

		ok

		# Doing the job

		if StzFindFirst(pcBeforeOrAfter, [
			:BeforeOrAfter, :BeforeOrAfterIt,
			:AfterOrBefore, :AfterOrBeforeIt,

			:ComingBeforeOrAfter, :ComingBeforeOrAfterIt,
			:ComingAfterOrBefore, :ComingAfterOrBeforeIt
			]) > 0

			_nResult_ = This.NearestTo(_n_)

		but StzFindFirst(pcBeforeOrAfter, [
			:Before, :BeforeIt,
			:ComingBefore, :ComingBeforeIt
			]) > 0

			_anPair_ = This.NeighborsOf(_n_)
			_nResult_ = _anPair_[1]

		but StzFindFirst(pcBeforeOrAfter, [
			:After, :AfterIt,
			:ComingAfter, :ComingAfterIt
			]) > 0

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

		# The number closest to the given one, with options.
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
			  StzFindFirst(pcBeforeOrAfter, [
				:Before, :After, :BeforeIt, :AfterIt,
				:BeforeOrAfter, :BeforeOrAfterIt,
				:AfterOrBefore, :AfterOrBeforeIt,

				:ComingBefore, :ComingAfter, :ComingBeforeIt, :ComingAfterIt,
				:ComingBeforeOrAfter, :ComingBeforeOrAfterIt,
				:ComingAfterOrBefore, :ComingAfterOrBeforeIt

			  ]) > 0 )

			StzRaise("Incorrect param type! pcComingBeforeOrAfter must be a string equal to :Before, :After, or :BeforeOrAfter.")

		ok

		# Doing the job

		if StzFindFirst(pcBeforeOrAfter, [
			:BeforeOrAfter, :BeforeOrAfterIt,
			:AfterOrBefore, :AfterOrBeforeIt,

			:ComingBeforeOrAfter, :ComingBeforeOrAfterIt,
			:ComingAfterOrBefore, :ComingAfterOrBeforeIt
			]) > 0

			_nResult_ = This.FarthestTo(_n_)

		but StzFindFirst(pcBeforeOrAfter, [
			:Before, :BeforeIt,
			:ComingBefore, :ComingBeforeIt
			]) > 0

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
				_nPos_ = StzFindFirst(_n_, _anSorted_)

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

		but StzFindFirst(pcBeforeOrAfter, [
			:After, :AfterIt,
			:ComingAfter, :ComingAfterIt
			]) > 0

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
				_nPos_ = StzFindFirst(_n_, _anSorted_)

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

	# Returns the distinct number closest to n; n itself is never returned.
	#
	#   _n_        the number to measure from
	#   returns    a number; empty text for an empty list
	#   note       a tie goes to the larger number when n is in the list
	#   see        Farthest, Neighbors
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

		_nPos_ = StzFindFirst(_n_, _anSorted_)

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

		# Returns the number of the list closest to n.
		#
		#   _n_        the number to measure from
		#   returns    a number
		#   see        Nearest
		#@ aka  Same as Nearest.
		def Closest(_n_)
			return This.Nearest(_n_)

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

	# Returns the smallest or the largest number, whichever lies farther from n.
	#
	#   _n_        the number to measure from
	#   returns    a number; empty text for an empty list
	#   see        Nearest, FarthestNeighbors
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

		_nPos_ = StzFindFirst(_n_, _anSorted_)

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

	# Returns the distinct numbers just below and just above n; one number when n sits at an end.
	#
	#   _n_        the number whose neighbors are wanted
	#   returns    a list of one or two numbers
	#   see        Nearest, FarthestNeighbors
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
		_nSet_ = len(_anSorted_)	# the number of DISTINCT numbers: the list below is that long
		_nPos_ = StzFindFirst(_n_, _anSorted_)

		if _nPos_ = 0
			if _n_ < _anSorted_[1]
				return [ _anSorted_[1] ]
			ok

			if _n_ > _anSorted_[_nSet_]
				return [ _anSorted_[_nSet_] ]
			ok

			for i = 1 to _nSet_-1
				if _n_ > _anSorted_[i] and _n_ < _anSorted_[i+1]
					return [ _anSorted_[i], _anSorted_[i+1] ]
				ok
			next
		ok

		if _nSet_ = 1
			return []
		ok

		if _nPos_ = 1
			return [ _anSorted_[2] ]

		but _nPos_ = _nSet_
			return [ _anSorted_[_nSet_-1] ]

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

		# The n numbers closest to the given one.
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

		# Returns the distinct numbers just below and just above n; one number when n sits at an end.
		#
		#   _n_        the number whose neighbors are wanted
		#   returns    a list of one or two numbers
		#   note       a misspelling of Neighbors, kept as an alias
		#   see        Neighbors
		#>
		#< @FunctionMisspelledForms
		def Nighbors(_n_)
			return NeighborsOf(_n_)

		# Returns the distinct numbers just below and just above n; one number when n sits at an end.
		#
		#   _n_        the number whose neighbors are wanted
		#   returns    a list of one or two numbers
		#   note       a misspelling of NearestNeighbors, kept as an alias
		#   see        Neighbors
		def NearestNighbors(_n_)
			return NeighborsOf(_n_)

		# Returns the distinct numbers just below and just above n; one number when n sits at an end.
		#
		#   _n_        the number whose neighbors are wanted
		#   returns    a list of one or two numbers
		#   note       a misspelling of NeighborsOf, kept as an alias
		#   see        Neighbors
		def NighborsOf(_n_)
			return NeighborsOf(_n_)

		# Returns the distinct numbers just below and just above n; one number when n sits at an end.
		#
		#   _n_        the number whose neighbors are wanted
		#   returns    a list of one or two numbers
		#   note       a misspelling of NearestNeighborsOf, kept as an alias
		#   see        Neighbors
		def NearestNighborsOf(_n_)
			return NeighborsOf(_n_)

		# Returns the distinct numbers just below and just above n; one number when n sits at an end.
		#
		#   _n_        the number whose neighbors are wanted
		#   returns    a list of one or two numbers
		#   note       a misspelling of NeighborsTo, kept as an alias
		#   see        Neighbors
		def NighborsTo(_n_)
			return NeighborsOf(_n_)

		# Returns the distinct numbers just below and just above n; one number when n sits at an end.
		#
		#   _n_        the number whose neighbors are wanted
		#   returns    a list of one or two numbers
		#   note       a misspelling of NearestNeighborsTo, kept as an alias
		#   see        Neighbors
		def NearestNighborsTo(_n_)
			return NeighborsOf(_n_)

	# Returns [ smallest, largest ] of the distinct numbers, with empty text on the side n itself occupies.
	#
	#   _n_        the number to measure from
	#   returns    a pair of numbers
	#   note       [ "", "" ] when n is not in the list
	#   see        Neighbors, Farthest
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

		_nPos_ = StzFindFirst(_n_, _anSorted_)

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

	# Returns the difference between each number and the one before it.
	#
	#   returns    a list of numbers, one fewer than the list
	#   note       raises an error for a list of exactly one number
	#   see        AbsDiff, DiffWith
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

	# Returns the absolute difference between each number and the one before it.
	#
	#   returns    a list of numbers, one fewer than the list
	#   note       raises an error for a list of exactly one number
	#   see        Diff, AbsDiffWith
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

	# Returns each number minus n.
	#
	#   _n_        the number to subtract from each
	#   returns    a list of numbers, as many as the list
	#   see        AbsDiffWith, Diff
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

	# Returns the distance between each number and n.
	#
	#   _n_        the number to measure each from
	#   returns    a list of non-negative numbers
	#   see        DiffWith, AbsDiff
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

	# Returns [ pivot, numbers ] pairs, each number grouped under the closest pivot; a number equal to a pivot is left out.
	#
	#   panNumbers   the pivot numbers to group around
	#   returns      a list of [ pivot, numbers ] pairs
	#   note         a number equally far from two pivots goes to the first one given
	#   see          Nearest
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
			_nMinDiff_ = ""
			_nClosestPivot_ = ""

			for i = 1 to _nLenNumbers_

				_nPivot_ = panNumbers[i]
				_nDiff_ = @abs(_nNumber_ - _nPivot_)

				if _nMinDiff_ = "" or _nDiff_ < _nMinDiff_
					_nMinDiff_ = _nDiff_
					_nClosestPivot_ = _nPivot_
				ok

			next

			_nResultLen_ = len(_aResult_)
			for i = 1 to _nResultLen_

				if StzFindFirst(_nNumber_, panNumbers) = 0 and
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

	# Returns the shortest pattern of differences that repeats along the list.
	#
	#   returns    a list of numbers
	#   note       raises an error for fewer than two numbers; for [ 1, 2, 3, 4 ] the pattern is [ 1
	#              ]
	#   see        Diff
	#@ aka  Returns the minimal repeating pattern of steps (differences) between consecutive numbers in the list
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

	# Returns a stzWalker that starts at the first number, repeats the steps and visits the same numbers as the list.
	#
	#   returns    a stzWalker
	#   note       raises an error for fewer than two numbers
	#   see        Steps
	def Walker()
		_oWalker_ = new stzWalker(@aContent[1], @aContent[len(@aContent)], This.Steps())
		_oWalker_.WalkNumberOfTimes(len(@aContent))

		return _oWalker_

		def StzWalker()
			return This.Walker()

	  #======================================================#
	 #  LEAST COMMON NUMBER WITH AN OTHER LIST OF NUMBERS   #
	#======================================================#

	# Returns the smallest number that occurs in both this list and the other one.
	#
	#   panOtherList   the other list of numbers, or :With = list
	#   returns        a number
	#   note           raises an error when the two lists share no number
	#   see            GreatestCommonNumber
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
	
			if NOT @IsListOfNumbers(panOtherList)
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



		# Misspelled-but-kept alias (smallest common number).
		def SmallesCommonNumber(pOtherNumber)
			return This.LeastCommonNumber(pOtherNumber)


		# Misspelled-but-kept alias (least common number).
		def LeastCommunNumber(panOtherList)
			return This.LeastCommonNumber(panOtherList)

		def SmallestCommunNumber(pOtherNumber)
			return This.LeastCommonNumber(pOtherNumber)


	  #------------------------------------------------------#
	 #  LEAST COMMON NUMBER WITH AN OTHER LIST OF NUMBERS   #
	#------------------------------------------------------#

	# Returns the largest number that occurs in both this list and the other one.
	#
	#   panOtherList   the other list of numbers, or :With = list
	#   returns        a number
	#   note           raises an error when the two lists share no number
	#   see            LeastCommonNumber
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
	
			if NOT @IsListOfNumbers(panOtherList)
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

	# Returns the smallest number that every number of the list divides.
	#
	#   returns    a number
	#   note       raises an error for fewer than two numbers
	#   see        GreatestCommonNumber
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

	# Replaces every negative number by its absolute value, in place.
	#
	#   returns    nothing; the list changes
	#   see        Absoluted
	def Absolute()
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		for i = 1 to _nLen_
			if _anContent_[i] < 0
				_anContent_[i] = -_anContent_[i]
			ok
		next

		This.UpdateWith(_anContent_)

		def AbsoluteQ()
			This.Absolute()
			return This

	# Returns a copy with every number made positive; the list itself is left alone.
	#
	#   returns    a list of numbers
	#   see        Absolute
	def Absoluted()
		return This.Copy().AbsoluteQ().Content()

	  #----------------------------------------#
	 #     "NEGATING' THE LIST OF NUMBERS     #
	#----------------------------------------#

	# Turns every positive number negative, in place.
	#
	#   returns    nothing; the list changes
	#   see        Negated
	def Negate()
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		for i = 1 to _nLen_
			if _anContent_[i] > 0
				_anContent_[i] = -_anContent_[i]
			ok
		next

		This.UpdateWith(_anContent_)

		def NegateQ()
			This.Negate()
			return This

	# Returns a copy with every positive number made negative; the list itself is left alone.
	#
	#   returns    a list of numbers
	#   see        Negate
	def Negated()
		return This.Copy().NegateQ().Content()

	  #---------------------------#
	 #     BASIC CALCULATIONS    #
	#---------------------------#

	# Returns the product of all the numbers; 0 for an empty list.
	#
	#   returns    a number
	#   see        Sum
	#@ aka  The product of all the numbers.
	def Product()
		_pPrList = This._EngineListFromContent()
		if _pPrList != ""
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

	# Returns the sum of all the numbers; 0 for an empty list.
	#
	#   returns    a number
	#   see        Product, Mean
	#@ aka  The sum of all the numbers.
	def Sum()
		_pSmList = This._EngineListFromContent()
		if _pSmList != ""
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

	# Returns the arithmetic mean of the numbers; 0 for an empty list.
	#
	#   returns    a number
	#   see        Sum, Median
	#@ aka  The arithmetic mean (average) of the numbers.
	def Mean()
		_pMnList = This._EngineListFromContent()
		if _pMnList != ""
			_nMnResult = StzEngineListMean(_pMnList)
			StzEngineListFree(_pMnList)
			return _nMnResult
		ok

		return Sum() / (This.NumberOfNumbers())

		# Returns the arithmetic average of the numbers; 0 for an empty list.
		#
		#   returns    a number
		#   see        Mean
		#@ aka  Same as Mean: the arithmetic average of the numbers.
		def Average()
			return Mean()

	# Returns the middle number of the sorted list, or the mean of the two middle ones.
	#
	#   returns    a number
	#   note       raises an error for an empty list
	#   see        Mean
	#@ aka  The median of the numbers.
	def Median()
			_aValuesSorted_ = @sort(This.Content())
			_nLen_ = len(_aValuesSorted_)
			
			if _nLen_ % 2 = 1
				return _aValuesSorted_[ring_ceil(_nLen_/2)]
			else
				return (_aValuesSorted_[_nLen_/2] + _aValuesSorted_[(_nLen_/2)+1]) / 2
			ok

	# Returns the mean of the numbers weighted by the given coefficients, one per number.
	#
	#   paList     the coefficients, one per number
	#   returns    a number
	#   note       raises an error when the coefficients are not one per number
	#   see        Mean
	#@ aka  The weighted mean of the numbers, using the given coefficients.
	def MeanByCoefficient(paList)
		// [ 16, 18, 20, 17 ]
		// [  4,  2,  2,  1 ]
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		if NOT ( isList(paList) and len(paList) = _nLen_ and @IsListOfNumbers(paList) )
			StzRaise("Incorrect param! paList must hold one number per number of the list.")
		ok

		_nSumProducts_ = 0
		_nSumCoefs_ = 0

		for i = 1 to _nLen_
			_nSumProducts_ += _anContent_[i] * paList[i]
			_nSumCoefs_ += paList[i]
		next

		return _nSumProducts_ / _nSumCoefs_

	  #---------------------------------------#
	 #     CONTAINING DIVIDABLE NUMBER BY    #
	#---------------------------------------#

	# Tells whether at least one number of the list is divisible by n.
	#
	#   _n_        the divisor
	#   returns    TRUE or FALSE
	#   see        DividableNumbersBy
	def ContainsADividableNumberBy(_n_)
		if len( This.DividableNumbersBy(_n_) ) > 0
			return 1
		else
			return 0
		ok

	  #----------------------------------------------------#
	 #  GETTING THE NUMBERS DIVIDABLE BY A GIVEN NUMBER   #
	#----------------------------------------------------#

	# Returns the numbers of the list that n divides evenly, in their order.
	#
	#   _n_        the divisor; zero divides nothing
	#   returns    a list of numbers
	#   see        ContainsADividableNumberBy
	def DividableNumbersBy(_n_)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_anResult_ = []

		if _n_ = 0
			return _anResult_
		ok

		for i = 1 to _nLen_
			if _anContent_[i] % _n_ = 0
				_anResult_ + _anContent_[i]
			ok
		next

		return _anResult_

		def NumbersDividableBy(_n_)
			return This.DividableNumbersBy(_n_)

	  #--------------------------------------#
	 #     CLIPPING THE LIST OF NUMBERS     #
	#--------------------------------------#

	# Replaces every number below nMin by nMin and every number above nMax by nMax, in place.
	#
	#   nMin       the lower limit
	#   nMax       the upper limit
	#   returns    nothing; the list changes
	#   see        Cumulate
	#@ aka  Limits the values of the list by adjusting the numbers outside the provided range (nMin, nMax). Each number lesser then nMin becomes equal to nMin. And each number greater then nMax becomes equal to nMax.
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

	# Replaces the numbers from position n1 to position n2 by one number, in place.
	#
	#   _n1_       the first position
	#   _n2_       the last position
	#   _n_        the number to put in
	#   returns    nothing; the list changes
	#   note       positions past the end are ignored
	#   see        ReplaceNumberAtPosition
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

		# Replaces the numbers lying in a section of positions by one number, in place.
		#
		#   _n1_       the first position
		#   _n2_       the last position
		#   _n_        the number to put in
		#   returns    nothing; the list changes
		#   note       positions past the end are ignored
		#   see        ReplaceSectionWith
		#>
		def ReplaceNumbersInSectionWith(_n1_, _n2_, _n_)
			This.ReplaceSectionWith(_n1_, _n2_, _n_)

	  #----------------------------#
	 #     CUMULATING NUMBERS     #
	#----------------------------#

	# Turns the numbers into running sums, in place: [ 1, 2, 3, 4, 5 ] becomes [ 1, 3, 6, 10, 15 ].
	#
	#   returns    nothing; the list changes
	#   see        Cumulated
	#@ aka  Turn each number into the running sum up to it (mutating). For a copy, use Cumulated.
	def Cumulate()
		_aResult_ = []
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		for i = 2 to _nLen_
			_anContent_[i] += _anContent_[i-1]
		next
			
		This.UpdateWith(_anContent_)


		def CumulateQ()
			This.Cumulate()
			return This

		# The running sums, in the requested return type (QRT).
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

	# Returns the running sums of the numbers as a copy; the list itself is left alone.
	#
	#   returns    a list of numbers
	#   see        Cumulate
	#@ aka  The running sums of the numbers, as a copy; the original is unchanged.
	def Cumulated()
		_oCopy_ = This.Copy()
		_oCopy_.Cumulate()
		return _oCopy_.Content()

	  #-------------------------------------------------------------#
	 #  GETTING ONLY UNICODE NUMBERS AMONG THE NUMBER IN THE LIST  #
	#-------------------------------------------------------------#

	# Returns the numbers that are Unicode code points: whole numbers from 0 to 1114111.
	#
	#   returns    a list of numbers
	#   see        ToStzListOfChars
	def OnlyUnicodes()
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			_n_ = _anContent_[i]

			if _n_ = floor(_n_) and _n_ >= 0 and _n_ <= 1114111
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

	# Adds n to every number, in place.
	#
	#   _n_        the number to add
	#   returns    nothing; the list changes
	#   note       raises an error for an empty list
	#   see        AddedToEach, SubStructFromEach
	#@ aka  Add n to each number of the list (mutating).
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

		# Adds n to each of the numbers, in place.
		#
		#   _n_        the number to add
		#   returns    nothing; the list changes
		#   note       raises an error for an empty list
		#   see        AddToEach
		def AddToEachNumber(_n_)
			This.AddToEach(_n_)

			def AddToEachNumberQ(_n_)
				return This.AddToEachQ(_n_)

		# Adds n to every one of the numbers, in place.
		#
		#   _n_        the number to add
		#   returns    nothing; the list changes
		#   note       raises an error for an empty list
		#   see        AddToEach
		def AddToEveryNumber(_n_)
			This.AddToEach(_n_)

			def AddToEveryNumberQ(_n_)
				return This.AddToEachQ(_n_)

	# Returns a copy with n added to every number; the list is unchanged.
	#
	#   _n_        the number to add
	#   returns    a list of numbers
	#   see        AddToEach
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

	# Subtracts n from every number, in place.
	#
	#   _n_        the number to subtract
	#   returns    nothing; the list changes
	#   note       raises an error for an empty list
	#   see        SubStructedFromEach, AddToEach
	#@ aka  Subtract n from each number of the list (mutating).
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

		# Subtracts n from each of the numbers, in place.
		#
		#   _n_        the number to subtract
		#   returns    nothing; the list changes
		#   see        SubStructFromEach
		#>
		#< @FunctionAlternativeForms
		def SubStructFromEachNumber(_n_)
			This.SubStructFromEach(_n_)

			def SubStructFromEachNumberQ(_n_)
				return This.SubStructFromEachQ(_n_)

		# Subtracts n from every number, in place.
		#
		#   _n_        the number to subtract
		#   returns    nothing; the list changes
		#   note       a misspelling of SubtractFromEach, kept as an alias
		#   see        SubStructFromEach
		#>
		#< @FunctionAlternativeForms
		def SubstractFromEach(_n_)
			This.SubStructFromEach(_n_)

		# Subtracts n from each of the numbers, in place.
		#
		#   _n_        the number to subtract
		#   returns    nothing; the list changes
		#   note       a misspelling of SubtractFromEachNumber, kept as an alias
		#   see        SubStructFromEach
		def SubStractFromEachNumber(_n_)
			This.SubStructFromEach(_n_)

			def SubStractFromEachNumberQ(_n_)
				return This.SubStructFromEachQ(_n_)

		# Subtracts n from every number, in place.
		#
		#   _n_        the number to subtract
		#   returns    nothing; the list changes
		#   see        SubStructFromEach
		#@ aka  --
		def SubtractFromEach(_n_)
			This.SubStructFromEach(_n_)

		# Subtracts n from each of the numbers, in place.
		#
		#   _n_        the number to subtract
		#   returns    nothing; the list changes
		#   see        SubStructFromEach
		def SubtractFromEachNumber(_n_)
			This.SubStructFromEach(_n_)

			def SubtractFromEachNumberQ(_n_)
				return This.SubStructFromEachQ(_n_)

		# Subtracts n from every number, in place.
		#
		#   _n_        the number to subtract
		#   returns    nothing; the list changes
		#   note       a misspelling of SubtractFromEach, kept as an alias
		#   see        SubStructFromEach
		#@ aka  --
		def SubtructFromEach(_n_)
			This.SubStructFromEach(_n_)

		# Subtracts n from each of the numbers, in place.
		#
		#   _n_        the number to subtract
		#   returns    nothing; the list changes
		#   note       a misspelling of SubtractFromEachNumber, kept as an alias
		#   see        SubStructFromEach
		def SubtructFromEachNumber(_n_)
			This.SubStructFromEach(_n_)

			def SubtructFromEachNumberQ(_n_)
				return This.SubStructFromEachQ(_n_)

	# Returns a copy with n subtracted from every number; the list is unchanged.
	#
	#   _n_        the number to subtract
	#   returns    a list of numbers
	#   see        SubStructFromEach
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

	# Multiplies every number by n, in place.
	#
	#   _n_        the factor
	#   returns    nothing; the list changes
	#   see        EachMultipliedBy, DivideEachBy
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

		# Multiplies each of the numbers by n, in place.
		#
		#   _n_        the factor
		#   returns    nothing; the list changes
		#   see        MultiplyEachBy
		#>
		#< @FunctionAlternativeForms
		def MultiplyEachNumberBy(_n_)
			This.MultiplyEachBy(_n_)

			def MultiplyEachNumberByQ(_n_)
				return This.MultiplyEachByQ(_n_)

		# Multiplies every one of the numbers by n, in place.
		#
		#   _n_        the factor
		#   returns    nothing; the list changes
		#   see        MultiplyEachBy
		def MultiplyEveryNumberBy(_n_)
			This.MultiplyEachBy(_n_)

			def MultiplyEveryNumberByQ(_n_)
				return This.MultiplyEachByQ(_n_)
 
	# Returns a copy with every number multiplied by n; the list is unchanged.
	#
	#   _n_        the factor
	#   returns    a list of numbers
	#   see        MultiplyEachBy
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

	# Divides every number by n, in place.
	#
	#   _n_        the divisor
	#   returns    nothing; the list changes
	#   note       raises an error when n is 0
	#   see        EachDividedBy, MultiplyEachBy
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

		# Divides each of the numbers by n, in place.
		#
		#   _n_        the divisor
		#   returns    nothing; the list changes
		#   note       raises an error when n is 0
		#   see        DivideEachBy
		#>
		#< @FunctionAlternativeForms
		def DivideEachNumberBy(_n_)
			This.DivideEachBy(_n_)

			def DivideEachNumberByQ(_n_)
				return This.DivideEachByQ(_n_)

		# Divides every one of the numbers by n, in place.
		#
		#   _n_        the divisor
		#   returns    nothing; the list changes
		#   note       raises an error when n is 0
		#   see        DivideEachBy
		def DivideEveryNumberBy(_n_)
			This.DivideEachBy(_n_)

			def DivideEveryNumberByQ(_n_)
				return This.DivideEachByQ(_n_)

	# Returns a copy with every number divided by n; the list is unchanged.
	#
	#   _n_        the divisor
	#   returns    a list of numbers
	#   note       raises an error when n is 0
	#   see        DivideEachBy
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

	# Adds each given number to the number at the same position, in place; the list is cut to the shorter of the two.
	#
	#   panNumbers   the numbers to add, one per position
	#   returns      nothing; the list changes
	#   note         raises an error for an empty list
	#   see          ManyAddOneByOne
	def AddManyOneByOne(panNumbers)

		if NOT ( isList(panNumbers) and @IsListOfNumbers(panNumbers) )
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

		# Adds each given number to the number at its position, in place; the list is cut to the shorter of the two.
		#
		#   panNumbers   the numbers to add, one per position
		#   returns      nothing; the list changes
		#   note         raises an error for an empty list
		#   see          AddManyOneByOne
		#>
		#< @FunctionAlternativeForm
		def AddManyNumbersOneByOne(panNumbers)
			This.AddManyOneByOne(panNumbers)

			def AddManyNumbersOneByOneQ(panNumbers)
				return This.AddManyOneByOneQ(panNumbers)

	# Returns a copy where each given number is added to the number at its position; the list is unchanged.
	#
	#   panNumbers   the numbers to add, one per position
	#   returns      a list of numbers, as long as the shorter of the two
	#   see          AddManyOneByOne
		#>
	def ManyAddOneByOne(panNumbers)
		_anResult_ = This.Copy().AddManyOneByOneQ(panNumbers).Content()
		return _anResult_

		def ManyNumbersAddedOneByOne(panNumbers)
			return This.ManyAddOneByOne(panNumbers)

	  #------------------------------------------#
	 #   SubStructING MANY NUMBERS ONE BY ONE   #
	#------------------------------------------#

	# Subtracts each given number from the number at the same position, in place; the list is cut to the shorter of the two.
	#
	#   panNumbers   the numbers to subtract, one per position
	#   returns      nothing; the list changes
	#   see          ManySubStructedOneByOne
	def SubStructManyOneByOne(panNumbers)

		if NOT ( isList(panNumbers) and @IsListOfNumbers(panNumbers) )
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

		# Subtracts each given number from the number at its position, in place; the list is cut to the shorter of the two.
		#
		#   panNumbers   the numbers to subtract, one per position
		#   returns      nothing; the list changes
		#   see          SubStructManyOneByOne
		#>
		#< @FunctionAlternativeForm
		def SubStructManyNumbersOneByOne(panNumbers)
			This.SubStructManyOneByOne(panNumbers)

			def SubStructManyNumbersOneByOneQ(panNumbers)
				return This.SubStructManyOneByOneQ(panNumbers)

	# Returns a copy where each given number is subtracted from the number at its position; the list is unchanged.
	#
	#   panNumbers   the numbers to subtract, one per position
	#   returns      a list of numbers, as long as the shorter of the two
	#   see          SubStructManyOneByOne
		#>
	def ManySubStructedOneByOne(panNumbers)
		_aResult_ = This.Copy().SubStructManyOneByOneQ(panNumbers).Content()
		return _aResult_

		def ManyNumbersSubStructedOneByOne(panNumbers)
			return This.ManyAddOneByOne(panNumbers)


	  #----------------------------------------------------------------------#
	 #   MULTIPLYING THE NUMBERS OF THE LIST WITH MANY NUMBERS ONE BY ONE   #
	#----------------------------------------------------------------------#

	# Multiplies each number by the given number at the same position, in place; the list is cut to the shorter of the two.
	#
	#   panNumbers   the factors, one per position
	#   returns      nothing; the list changes
	#   see          MultipliedWithManyOneByOne
	def MultiplyWithManyOneByOne(panNumbers)

		if NOT ( isList(panNumbers) and @IsListOfNumbers(panNumbers) )
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

	# Returns a copy where each number is multiplied by the given number at its position; the list is unchanged.
	#
	#   panNumbers   the factors, one per position
	#   returns      a list of numbers, as long as the shorter of the two
	#   see          MultiplyWithManyOneByOne
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

	# Divides each number by the given number at the same position, in place; the list is cut to the shorter of the two.
	#
	#   panNumbers   the divisors, one per position
	#   returns      nothing; the list changes
	#   see          DividedByManyOneByOne
	def DivideByManyOneByOne(panNumbers)

		if NOT ( isList(panNumbers) and @IsListOfNumbers(panNumbers) )
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

	# Returns a copy where each number is divided by the given number at its position; the list is unchanged.
	#
	#   panNumbers   the divisors, one per position
	#   returns      a list of numbers, as long as the shorter of the two
	#   see          DivideByManyOneByOne
		#TODO
	#@ aka  Add alternatives
	def DividedByManyOneByOne(panNumbers)
		_anResult_ = This.Copy().DivideByManyOneByOneQ(panNumbers).Content()
		return _anResult_

		#TODO
		# Add alternatives

	  #===================================================#
	 #   ADDING NUMBER TO EACH UNDER A GIVEN CONDITION   #
	#===================================================#

	# Add n to each number satisfying the given W condition (mutating).
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

	# The numbers with n added where the W condition holds, as a
	# copy.
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

	# The numbers with n subtracted where the W condition holds, as
	# a copy.
	def SubStructedFromEachW(_n_)
		_aResult_ = This.Copy().SubStructFromEachWQ(_n_).Content()
		return _aResult_
	
		#TODO
		# Add alternatives

	  #--------------------------------------------------------------------#
	 #   MULTIPLYING NUMBERS BY AN OTHER NUMBER UNDER A GIVEN CONDITION   #
	#--------------------------------------------------------------------#

	# Multiplies by n the numbers whose position meets the condition, in place; the others stay as they are.
	#
	#   _n_           the factor
	#   pcCondition   a condition on @i, the position
	#   returns       nothing; the list changes
	#   note          write the condition on the position, for example "@i > 1"; a condition that
	#                 does not mention @i is refused
	#   see           EachMultipliedWithW, DivideEachWithW
	#@ aka  Multiply by n each number satisfying the given W condition (mutating).
	def MultiplyEachWithW(_n_, pcCondition)
		This._ScaleEachWithW(_n_, pcCondition, 0)

		#< @FunctionFluentForm

		def MultiplyEachWithWQ(_n_, pcCondition)
			This.MultiplyEachWithW(_n_, pcCondition)
			return This

		#>

		#< @FunctionAlternativeForm

		def MultiplyEachByW(_n_, pcCondition)
			This.MultiplyEachWithW(_n_, pcCondition)

			def MultiplyEachByWQ(_n_, pcCondition)
				This.MultiplyEachByW(_n_, pcCondition)
				return This

	# Returns a copy multiplied by n where the condition holds; the other numbers are kept.
	#
	#   _n_            the factor
	#   pcCondition    a condition on @i, the position
	#   returns        a list of numbers
	#   see            MultiplyEachWithW
		#>
	#@ aka  The numbers multiplied by n where the W condition holds, as a copy.
	def EachMultipliedWithW(_n_, pcCondition)
		_oCopy_ = This.Copy()
		_oCopy_.MultiplyEachWithW(_n_, pcCondition)
		return _oCopy_.Content()

		def EachMultipliedByW(_n_, pcCondition)
			return This.EachMultipliedWithW(_n_, pcCondition)

		#TODO
		# Add other alternatives

	# The shared body of MultiplyEachWithW and DivideEachWithW: applies the factor, or its
	# division, to the numbers whose position meets the condition, and keeps the others.
	def _ScaleEachWithW(_n_, pcCondition, bDivide)

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
			StzRaise("Can't change anything! Because the list is empty.")
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

		_anResult_ = _anContent_

		for @i = _nStart_ to _nEnd_
			eval(_cCode_)
			if bOk
				if bDivide
					_anResult_[@i] = _anContent_[@i] / _n_
				else
					_anResult_[@i] = _anContent_[@i] * _n_
				ok
			ok
		next

		This.Update( _anResult_ )

	  #-------------------------------------------------------------------#
	 #   DIVIDE EACH NUMBER BY AN OTHER NUMBER UNDER A GIVEN CONDITION   #
	#-------------------------------------------------------------------#

	# Divides by n the numbers whose position meets the condition, in place; the others stay as they are.
	#
	#   _n_           the divisor
	#   pcCondition   a condition on @i, the position
	#   returns       nothing; the list changes
	#   note          write the condition on the position, for example "@i > 4"; a condition that
	#                 does not mention @i is refused
	#   see           EachDividedWithW, MultiplyEachWithW
	def DivideEachWithW(_n_, pcCondition)
		This._ScaleEachWithW(_n_, pcCondition, 1)

		def DivideEachWithWQ(_n_, pcCondition)
			This.DivideEachWithW(_n_, pcCondition)
			return This

		def DivideEachByW(_n_, pcCondition)
			This.DivideEachWithW(_n_, pcCondition)

	# Returns a copy divided by n where the condition holds; the other numbers are kept.
	#
	#   _n_            the divisor
	#   pcCondition    a condition on @i, the position
	#   returns        a list of numbers
	#   see            DivideEachWithW
		#TODO
	#@ aka  Add alternatives
	def EachDividedWithW(_n_, pcCondition)
		_oCopy_ = This.Copy()
		_oCopy_.DivideEachWithW(_n_, pcCondition)
		return _oCopy_.Content()

		def EachDividedByW(_n_, pcCondition)
			return This.EachDividedWithW(_n_, pcCondition)

		#TODO
		# Add alternatives

	  #=====================================================#
	 #     UPDATING THE LIST WITH A NEW LIST OF NUMBERS    #
	#=====================================================#

	# Replaces the numbers by a new list of numbers, in place; an empty list is refused.
	#
	#   panNewListOfNumbers   the new numbers, or :With = list
	#   returns               nothing; the list changes
	#   note                  raises an error for an empty list or a list that holds a non-number
	#   see                   Updated
	def Update(panNewListOfNumbers)

		if CheckingParams() = 1
			if isList(panNewListOfNumbers) and Q(panNewListOfNumbers).IsWithOrByOrUsingNamedParam()
				panNewListOfNumbers = panNewListOfNumbers[2]
			ok
	
			if NOT ( isList(panNewListOfNumbers) and
				 @IsListOfNumbers(panNewListOfNumbers)
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

		# Replaces the numbers by a new list of numbers, in place; an empty list is refused.
		#
		#   panNewListOfNumbers   the new numbers, or :With = list
		#   returns               nothing; the list changes
		#   see                   Update
		#>
		#< @FunctionAlternativeForms
		def UpdateWith(panNewListOfNumbers)
			This.Update(panNewListOfNumbers)

			def UpdateWithQ(panNewListOfNumbers)
				return This.UpdateQ(panNewListOfNumbers)
	
		# Replaces the numbers by a new list of numbers, in place; an empty list is refused.
		#
		#   panNewListOfNumbers   the new numbers, or :By = list
		#   returns               nothing; the list changes
		#   see                   Update
		def UpdateBy(panNewListOfNumbers)
			This.Update(panNewListOfNumbers)

			def UpdateByQ(panNewListOfNumbers)
				return This.UpdateQ(panNewListOfNumbers)

		# Replaces the numbers by a new list of numbers, in place; an empty list is refused.
		#
		#   panNewListOfNumbers   the new numbers, or :Using = list
		#   returns               nothing; the list changes
		#   see                   Update
		def UpdateUsing(panNewListOfNumbers)
			This.Update(panNewListOfNumbers)

			def UpdateUsingQ(panNewListOfNumbers)
				return This.UpdateQ(panNewListOfNumbers)

	# Returns the given numbers as the new content of a copy; the list itself is unchanged.
	#
	#   panNewListOfNumbers   the new numbers
	#   returns               a list of numbers
	#   see                   Update
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

	# Puts a new number at a position, in place.
	#
	#   _n_           the position
	#   pnNewNumber   the new number, or :With = number
	#   returns       nothing; the list changes
	#   note          raises an error for position 0 or past the end
	#   see           ReplaceSectionWith
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

	# Reverses the order of the numbers, in place.
	#
	#   returns    nothing; the list changes
	#   note       raises an error for an empty list
	#   see        Reversed
	def Reverse()
		_aResult_ = This.ToStzList().Reversed()
		This.UpdateWith( _aResult_ )

		def ReverseQ()
			This.Reverse()
			return This

		# Reverses the order of the numbers, in place.
		#
		#   returns    nothing; the list changes
		#   note       raises an error for an empty list
		#   see        Reverse
		def ReverseNumbers()
			This.Reverse()

			def ReverseNumbersQ()
				This.ReverseNumbers()
				return This

	# Returns the numbers in reverse order; the list is unchanged.
	#
	#   returns    a list of numbers
	#   note       raises an error for an empty list
	#   see        Reverse
	def Reversed()
		_aResult_ = This.Copy().ReverseQ().Content()

		return _aResult_

		def NumbersReversed()
			return This.Reversed()

	  #===========#
	 #   MISC.   #
	#===========#

	# Returns the sorted numbers as the ends of consecutive [ start, end ] sections that begin at 1.
	#
	#   returns    a list of sections
	#   note       returns [ ] for fewer than two numbers; [ 3, 7, 12 ] gives [ [ 1, 3 ], [ 4, 7 ],
	#              [ 8, 12 ] ]
	#   see        ContiguousToSections
	#@ aka  Turn the numbers (positions) into [start, end] sections.
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

	# Returns the runs of consecutive numbers, each step one more, as [ first, last ] sections.
	#
	#   returns    a list of sections
	#   note       raises an error for an empty list; [ 1, 2, 3, 7, 8, 10 ] gives [ [ 1, 3 ], [ 7, 8
	#              ], [ 10, 10 ] ]
	#   see        ToSections, IsContiguous
	#@ aka  Group the contiguous runs of numbers into [start, end] sections.
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

	# TRUE if the object is a list of numbers, which is always the case.
	#
	#   returns    TRUE
	#   see        stzType
		#>
	#@ aka  Always TRUE: the object IS a stzListOfNumbers.
	def IsStzListOfNumbers()
		return 1

	# Returns the type name of the object, in lowercase.
	#
	#   returns    text, "stzlistofnumbers"
	#   see        IsStzListOfNumbers
	#@ aka  The Softanza type symbol: :stzListOfNumbers.
	def stzType()
		return :stzListOfNumbers

		# The lowercase class name: "stzlistofnumbers".
		def ClassName()
			return This.stzType()

	# Returns a stzListOfChars whose chars are the characters having these numbers as codes.
	#
	#   returns    a stzListOfChars
	#   note       [ 65, 66, 67 ] gives the chars A, B, C
	#   see        ToStzList
	#-----
	#@ aka  The numbers as a stzListOfChars object.
	def ToStzListOfChars()
		return new stzListOfChars( This.Content() )

	# Returns how many numbers the list holds.
	#
	#   returns    a number
	#   see        NumberAt
	#@ aka  How many numbers the list holds.
	def NumberOfNumbers()
		return len( This.Content() )

	# TRUE if each number is one more than the one before it, or each is one less.
	#
	#   returns    TRUE or FALSE
	#   note       FALSE for fewer than two numbers
	#   see        ContiguousToSections
	#@ aka  TRUE if the numbers form a contiguous sequence (each one following the previous).
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
	 #  PRIVATE HELPERS OF THE RANDOM PICKS    #
	#=========================================#

	# The random picks below draw from the engine through StzEngineRandomInt, and never
	# through a method of this class named like a global random function: a class method
	# with the name of a global shadows it inside the class (ARandomNumberBetween did).

	# One position drawn at random from a list of positions; raises when the list is empty.
	def _RandomPositionAmong(panPos)
		_nCount_ = len(panPos)
		if _nCount_ = 0
			StzRaise("No valid numbers found in the list!")
		ok

		return panPos[ StzEngineRandomInt(1, _nCount_) ]

	# Every position of the list, 1 to its size.
	def _AllPositions()
		_anPos_ = []
		_nLen_ = len(@aContent)
		for i = 1 to _nLen_
			_anPos_ + i
		next

		return _anPos_

	# The positions of the numbers strictly below n.
	def _PositionsBelow(_n_)
		_anPos_ = []
		_nLen_ = len(@aContent)
		for i = 1 to _nLen_
			if @aContent[i] < _n_
				_anPos_ + i
			ok
		next

		return _anPos_

	# The positions of the numbers strictly above n.
	def _PositionsAbove(_n_)
		_anPos_ = []
		_nLen_ = len(@aContent)
		for i = 1 to _nLen_
			if @aContent[i] > _n_
				_anPos_ + i
			ok
		next

		return _anPos_

	# The positions of the numbers that are none of the given numbers.
	def _PositionsOtherThan(panNumbers)
		_anPos_ = []
		_nLen_ = len(@aContent)
		for i = 1 to _nLen_
			if ring_find(panNumbers, @aContent[i]) = 0
				_anPos_ + i
			ok
		next

		return _anPos_

	# The positions of the numbers NOT between the two limits; both limits count as outside
	# when bIncluded is 0 (strictly between) or are kept as inside when it is 1.
	def _PositionsNotBetween(nMin, nMax, bIncluded)
		_anPos_ = []
		_nLen_ = len(@aContent)
		for i = 1 to _nLen_
			if bIncluded
				if @aContent[i] < nMin or @aContent[i] > nMax
					_anPos_ + i
				ok
			else
				if @aContent[i] <= nMin or @aContent[i] >= nMax
					_anPos_ + i
				ok
			ok
		next

		return _anPos_

	# The positions of the numbers between the two limits, bounds kept out or in.
	def _PositionsBetween(nMin, nMax, bIncluded)
		_anPos_ = []
		_nLen_ = len(@aContent)
		for i = 1 to _nLen_
			if bIncluded
				if @aContent[i] >= nMin and @aContent[i] <= nMax
					_anPos_ + i
				ok
			else
				if @aContent[i] > nMin and @aContent[i] < nMax
					_anPos_ + i
				ok
			ok
		next

		return _anPos_

	# Every position of 1 to the size of the list that is not in the given positions.
	def _PositionsOutside(panExcluded)
		_anPos_ = []
		_nLen_ = len(@aContent)
		for i = 1 to _nLen_
			if ring_find(panExcluded, i) = 0
				_anPos_ + i
			ok
		next

		return _anPos_

	# n numbers drawn at random (repeats allowed) from the given positions.
	def _NNumbersAmong(_n_, panPos)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if _n_ <= 0
			StzRaise("Can't proceed because n must be a positive number greater then 0!")
		ok

		_anResult_ = []
		for i = 1 to _n_
			_anResult_ + @aContent[ This._RandomPositionAmong(panPos) ]
		next

		return _anResult_

	# The same draw, as [ number, position ] pairs.
	def _NNumbersAmongZ(_n_, panPos)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if _n_ <= 0
			StzRaise("Can't proceed because n must be a positive number greater then 0!")
		ok

		_aResult_ = []
		for i = 1 to _n_
			_nPos_ = This._RandomPositionAmong(panPos)
			_aResult_ + [ @aContent[_nPos_], _nPos_ ]
		next

		return _aResult_

	# Some numbers (a random count from 1 to the number of positions) drawn from the given positions.
	def _SomeNumbersAmong(panPos)
		if len(panPos) = 0
			return []
		ok

		return This._NNumbersAmong( StzEngineRandomInt(1, len(panPos)), panPos )

	# The same draw, as [ number, position ] pairs.
	def _SomeNumbersAmongZ(panPos)
		if len(panPos) = 0
			return []
		ok

		return This._NNumbersAmongZ( StzEngineRandomInt(1, len(panPos)), panPos )

	  #=========================================#
	 #  GETTING A RANDOM NUMBER FROM THE LIST  #
	#=========================================#

	# Returns a number taken at random from the list, every position equally likely.
	#
	#   returns    a number
	#   note       raises an error for an empty list
	#   see        NRandomNumbers, SomeRandomNumbers
	def ARandomNumber()
		_nPos_ = This._RandomPositionAmong( This._AllPositions() )
		return @aContent[_nPos_]

		# Returns a number taken at random from the list, every position equally likely.
		#
		#   returns    a number
		#   see        ARandomNumber
		def ANumber()
			return This.ARandomNumber()

		# Returns a number taken at random from the list, every position equally likely.
		#
		#   returns    a number
		#   see        ARandomNumber
		def AnyRandomNumber()
			return This.ARandomNumber()

		# Returns a number taken at random from the list, every position equally likely.
		#
		#   returns    a number
		#   see        ARandomNumber
		def AnyNumber()
			return This.ARandomNumber()

	#-- Z/EXTENDED FORM

	# One number picked at random, along with its position.
	def ARandomNumberZ()
		_nPos_ = This._RandomPositionAmong( This._AllPositions() )
		return [ @aContent[_nPos_], _nPos_ ]

	  #------------------------------------------------------------------#
	 #  GETTING A RANDOM NUMBER FROM THE LIST LESS THAN A GIVEN NUMBER  #
	#------------------------------------------------------------------#

	# Returns a number taken at random from those below n.
	#
	#   _nNumber_   the number the answer must be below
	#   returns     a number
	#   note        raises an error when no number is below n
	#   see         NumbersSmallerThan, ARandomNumber
	def ANumberLessThan(_nNumber_)
		_nPos_ = This._RandomPositionAmong( This._PositionsBelow(_nNumber_) )
		return @aContent[_nPos_]

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

		# One number smaller than n, picked at random.
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

	# One number less than n, picked at random, with its position.
	def ANumberLessThanZ(_nNumber_)
		_nPos_ = This._RandomPositionAmong( This._PositionsBelow(_nNumber_) )
		return [ @aContent[_nPos_], _nPos_ ]

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

		# One number smaller than n, picked at random, with its
		# position.
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

	# Returns a number taken at random from those above n.
	#
	#   _nNumber_   the number the answer must be above
	#   returns     a number
	#   note        raises an error when no number is above n
	#   see         NumbersGreaterThan
	def ANumberGreaterThan(_nNumber_)
		_nPos_ = This._RandomPositionAmong( This._PositionsAbove(_nNumber_) )
		return @aContent[_nPos_]

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

	# One number greater than n, picked at random, with its
	# position.
	def ANumberGreaterThanZ(_nNumber_)
		_nPos_ = This._RandomPositionAmong( This._PositionsAbove(_nNumber_) )
		return [ @aContent[_nPos_], _nPos_ ]

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

	# Returns a number taken at random from the side of n that exists: before it, after it, or either.
	#
	#   _n_        a number of the list
	#   returns    a number
	#   note       raises an error when n is absent or is the only number
	#   see        AnyNumberBefore, AnyNumberAfter
	def AnyNumberBeforeOrAfter(_n_) # Or AnyNumberOtherThan()
		return This.AnyNumberBeforeOrAfterZ(_n_)[1]

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

	# One number OTHER than the given one, with its position.
	def AnyNumberBeforeOrAfterZ(_n_) # Or AnyNumberOtherThan()
		if isList(_n_) and Q(_n_).IsPositionNamedParam()
			_n_ = _n_[2]
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nLen_ = len(@aContent)
		_nPos_ = StzFindFirst(_n_, @aContent)

		if _nPos_ = 0
			StzRaise("Can't proceed! The number you provided does not exist in the list.")
		ok

		if _nLen_ < 2
			StzRaise("Can't proceed! The list holds no other number than the one you provided.")
		ok

		if _nPos_ = 1
			return This.AnyNumberAfterPositionZ(_nPos_)
		ok

		if _nPos_ = _nLen_
			return This.AnyNumberBeforePositionZ(_nPos_)
		ok

		if StzEngineRandomInt(0, 1) = 0
			return This.AnyNumberBeforePositionZ(_nPos_)
		ok

		return This.AnyNumberAfterPositionZ(_nPos_)

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

	# Returns a random number lying before the first occurrence of n.
	#
	#   _n_        a number of the list
	#   returns    a number
	#   note       raises an error when n is absent or is the first number
	#   see        AnyNumberBeforePosition, AnyNumberAfter
	def AnyNumberBefore(_n_)
		if isList(_n_) and Q(_n_).IsPositionNamedParam(_n_)
			return This.AnyNumberBeforePosition(_n_)
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nPos_ = StzFindFirst(_n_, This.Content())
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

	# One number occurring BEFORE the given number, with its
	# position.
	def AnyNumberBeforeZ(_n_)
		if isList(_n_) and Q(_n_).IsPositionNamedParam(_n_)
			return This.AnyNumberBeforePosition(_n_)
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nPos_ = StzFindFirst(_n_, This.Content())
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

	# Returns a random number taken from the positions before the given one.
	#
	#   _n_        the position that the answer must come before
	#   returns    a number
	#   note       raises an error unless n lies between 2 and the size of the list
	#   see        AnyNumberBefore, AnyNumberAfterPosition
	def AnyNumberBeforePosition(_n_)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nLen_ = This.NumberOfNumbers()
		
		if _n_ <= 1 or _n_ > _nLen_
			StzRaise("Index out of range!")
		ok

		_nRandom_ = StzEngineRandomInt(1, _n_ - 1)

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

	# One number before the given POSITION, with its position.
	def AnyNumberBeforePositionZ(_n_)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nLen_ = This.NumberOfNumbers()
		
		if _n_ <= 1 or _n_ > _nLen_
			StzRaise("Index out of range!")
		ok

		_nRandom_ = StzEngineRandomInt(1, _n_ - 1)

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

	# Returns a number taken at random from those after the first occurrence of n.
	#
	#   _n_        a number of the list
	#   returns    a number
	#   note       raises an error when n is absent or is the last number
	#   see        AnyNumberAfterPosition, AnyNumberBefore
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

		_nPos_ = ring_find( _anContent_, _n_ )
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

	# One number occurring AFTER the given number, with its
	# position.
	def AnyNumberAfterZ(_n_)
		if isList(_n_) and Q(_n_).IsPositionNamedParam(_n_)
			return This.AnyNumberAfterPosition(_n_)
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nPos_ = StzFindFirst(_n_, This.Content())
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

	# Returns a number taken at random from the positions after the given one.
	#
	#   _n_        the position that the answer must come after
	#   returns    a number
	#   note       raises an error unless n is below the size of the list
	#   see        AnyNumberAfter, AnyNumberBeforePosition
	def AnyNumberAfterPosition(_n_)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nLen_ = This.NumberOfNumbers()

		if _n_ < 1 or _n_ >= _nLen_
			StzRaise("Index out of range!")
		ok

		_nResult_ = This.Number( StzEngineRandomInt(_n_ + 1, _nLen_) )

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

	# One number after the given POSITION, with its position.
	def AnyNumberAfterPositionZ(_n_)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_nLen_ = This.NumberOfNumbers()

		if _n_ < 1 or _n_ >= _nLen_
			StzRaise("Index out of range!")
		ok

		_nPos_ = StzEngineRandomInt(_n_ + 1, _nLen_)
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

	# Returns a random number of the list that lies strictly between n1 and n2.
	#
	#   _n1_       the lower limit, not included
	#   _n2_       the upper limit, not included
	#   returns    a number
	#   note       raises an error when no number lies between the two limits
	#   see        NumbersBetween, AnyNumberNotBetween
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

	# One number between n1 and n2, with its position.
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

	# One number between n1 and n2, bounds INCLUDED (IB), with its
	# position.
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

	# Returns a random number of the list that is not strictly between n1 and n2.
	#
	#   _n1_       the lower limit
	#   _n2_       the upper limit
	#   returns    a number
	#   note       the limits themselves count as outside
	#   see        NumbersNotBetween, AnyNumberBetween
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

	# One number OUTSIDE n1..n2, with its position.
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

		# One number outside n1..n2 (bounds included), picked at random.
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

	# One number outside n1..n2 (bounds included), with its
	# position.
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

		# One number outside n1..n2 (bounds included), with its
		# position.
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

	# Returns the number at a random position from n1 to n2, both included, in either order.
	#
	#   _n1_       the first position
	#   _n2_       the last position
	#   returns    a number
	#   see        AnyNumberBetween
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

	# One number lying between the two given POSITIONS, with its
	# position.
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

	# Returns a number taken at random from the positions outside the two given ones, bounds included in the section.
	#
	#   _n1_       the first position
	#   _n2_       the last position
	#   returns    a number
	#   note       raises an error when the two positions cover the whole list
	#   see        AnyNumberBetweenPositions
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
		_nRandom_ = This._RandomPositionAmong( This._PositionsOutside(_anPos_) )
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

	# One number lying outside the two given positions, with its
	# position.
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
		_nRandom_ = This._RandomPositionAmong( This._PositionsOutside(_anPos_) )
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

	# Returns a number taken at random from every position but the given one.
	#
	#   _n_        the position to avoid
	#   returns    a number
	#   note       raises an error when the list holds only that position
	#   see        NumbersOutsidePosition
	def AnyNumberOutsidePosition(_n_)
		_nRandom_ = This._RandomPositionAmong( This._PositionsOutside([ _n_ ]) )
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

	# One number at a position OTHER than the given one, with its
	# position.
	def AnyNumberOutsidePositionZ(_n_)
		_nRandom_ = This._RandomPositionAmong( This._PositionsOutside([ _n_ ]) )
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

	# Returns n numbers taken at random from the list, repeats allowed.
	#
	#   _n_        how many numbers to draw
	#   returns    a list of numbers
	#   note       raises an error when n is 0, negative or greater than the size
	#   see        SomeRandomNumbers, ARandomNumber
	def NRandomNumbers(_n_)
		This._CheckHowManyRandomNumbers(_n_)

		return This._NNumbersAmong( _n_, This._AllPositions() )

		#< @FunctionAlternativeForms

		def RandomNNumbers(_n_)
			return This.NRandomNumbers(_n_)

		def NNumbers(_n_)
			return This.NRandomNumbers(_n_)

		#>

	# Z/EXTENDED FORM

	# n numbers picked at random, with their positions.
	def NRandomNumbersZ(_n_)
		This._CheckHowManyRandomNumbers(_n_)

		return This._NNumbersAmongZ( _n_, This._AllPositions() )

		#< @FunctionAlternativeForms

		def RandomNNumbersZ(_n_)
			return This.NRandomNumbersZ(_n_)

		def NNumbersZ(_n_)
			return This.NRandomNumbersZ(_n_)

		#>

	# Checks the count asked of NRandomNumbers: a positive number, and not more than the size.
	def _CheckHowManyRandomNumbers(_n_)
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

	# U/EXTENDED FORM (TODO)


	# UZ/EXTENDED FORM (TODO)


	  #------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS OTHER THEN A GIVEN NUMBER  #
	#------------------------------------------------------#

	# Returns n numbers taken at random from those that differ from a given number, repeats allowed.
	#
	#   _n_         how many numbers to draw
	#   _nNumber_   the number to leave out, or a list of numbers to leave out
	#   returns     a list of numbers
	#   note        raises an error when every number is left out
	#   see         NumbersOtherThan
	def NNumbersOtherThan(_n_, _nNumber_)
		if isList(_nNumber_)
			return This.NNumbersOtherThanMany(_n_, _nNumber_)
		ok

		if NOT isNumber(_nNumber_)
			StzRaise("Incorrect param type! nNumber must be a number.")
		ok

		return This._NNumbersAmong( _n_, This._PositionsOtherThan([ _nNumber_ ]) )

	#-- Z/EXTENDED FORM

	# n numbers other than the given one, with their positions.
	def NNumbersOtherThanZ(_n_, _nNumber_)
		if isList(_nNumber_)
			return This.NNumbersOtherThanManyZ(_n_, _nNumber_)
		ok

		if NOT isNumber(_nNumber_)
			StzRaise("Incorrect param type! nNumber must be a number.")
		ok

		return This._NNumbersAmongZ( _n_, This._PositionsOtherThan([ _nNumber_ ]) )

	# U/EXTENDED FORM (TODO)


	# UZ/EXTENDED FORM (TODO)

	  #-----------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS LESS THEN A GIVEN NUMBER  #
	#-----------------------------------------------------#

	# Returns n numbers taken at random from those below a given number, repeats allowed.
	#
	#   _n_         how many numbers to draw
	#   _nNumber_   the number the answers must be below
	#   returns     a list of numbers
	#   note        raises an error when no number is below it
	#   see         NumbersSmallerThan
	def NNumbersLessThan(_n_, _nNumber_)
		return This._NNumbersAmong( _n_, This._PositionsBelow(_nNumber_) )

		#< @FunctionAlternativeForms

		def NRandomNumbersLessThan(_n_, _nNumber_)
			return This.NNumbersLessThan(_n_, _nNumber_)

		def NNumbersSmallerThan(_n_, _nNumber_)
			return This.NNumbersLessThan(_n_, _nNumber_)

		def NRandomNumbersSmallerThan(_n_, _nNumber_)
			return This.NNumbersLessThan(_n_, _nNumber_)

		#>

	#-- Z/EXTENDED FORM

	# n numbers less than the given one, with their positions.
	def NNumbersLessThanZ(_n_, _nNumber_)
		return This._NNumbersAmongZ( _n_, This._PositionsBelow(_nNumber_) )

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

	# Returns n numbers taken at random from those above a given number, repeats allowed.
	#
	#   _n_         how many numbers to draw
	#   _nNumber_   the number the answers must be above
	#   returns     a list of numbers
	#   note        raises an error when no number is above it
	#   see         NumbersGreaterThan
	def NNumbersGreaterThan(_n_, _nNumber_)
		return This._NNumbersAmong( _n_, This._PositionsAbove(_nNumber_) )

		#< @FunctionAlternativeForms

		def NRandomNumbersGreaterThan(_n_, _nNumber_)
			return This.NNumbersGreaterThan(_n_, _nNumber_)

		def NNumbersBiggerThan(_n_, _nNumber_)
			return This.NNumbersGreaterThan(_n_, _nNumber_)

		def NRandomNumbersBiggerThan(_n_, _nNumber_)
			return This.NNumbersGreaterThan(_n_, _nNumber_)

		def NNumbersMoreThan(_n_, _nNumber_)
			return This.NNumbersGreaterThan(_n_, _nNumber_)

		def NRandomNumbersMoreThan(_n_, _nNumber_)
			return This.NNumbersGreaterThan(_n_, _nNumber_)

		#>

	#-- Z/EXTENDED FORM

	# n numbers greater than the given one, with their positions.
	def NNumbersGreaterThanZ(_n_, _nNumber_)
		return This._NNumbersAmongZ( _n_, This._PositionsAbove(_nNumber_) )

		#< @FunctionAlternativeForms

		def NRandomNumbersGreaterThanZ(_n_, _nNumber_)
			return This.NNumbersGreaterThanZ(_n_, _nNumber_)

		def NNumbersBiggerThanZ(_n_, _nNumber_)
			return This.NNumbersGreaterThanZ(_n_, _nNumber_)

		def NRandomNumbersBiggerThanZ(_n_, _nNumber_)
			return This.NNumbersGreaterThanZ(_n_, _nNumber_)

		def NNumbersMoreThanZ(_n_, _nNumber_)
			return This.NNumbersGreaterThanZ(_n_, _nNumber_)

		def NRandomNumbersMoreThanZ(_n_, _nNumber_)
			return This.NNumbersGreaterThanZ(_n_, _nNumber_)

		#>

	# U/EXTENDED FORM (TODO)


	# UZ/EXTENDED FORM (TODO)

	  #---------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS OTHER THEN THE GIVEN NUMBERS  #
	#---------------------------------------------------------#
	
	// #TODO // Add alternatives of (DifferentTo / Of / From / With) all over the library!

	def NNumbersOtherThanMany(_n_, _anNumbers_)
		return This._NNumbersAmong( _n_, This._PositionsOtherThan(_anNumbers_) )

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

	# n numbers other than the given ones, with their positions.
	def NNumbersOtherThanManyZ(_n_, _anNumbers_)
		return This._NNumbersAmongZ( _n_, This._PositionsOtherThan(_anNumbers_) )

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

	# Returns n numbers drawn at random, repeats allowed, from those strictly between nMin and nMax.
	#
	#   _n_        how many numbers to draw
	#   nMin       the lower limit, not included
	#   nMax       the upper limit, not included
	#   returns    a list of numbers
	#   see        NumbersBetween, NNumbersNotBetween
	def NNumbersBetween(_n_, nMin, nMax)
		_anNumbers_ = This.NumbersBetween(nMin, nMax)
		_anResult_ = NRandomNumbersIn(_n_, _anNumbers_)

		return _anResult_

		def NRandomNumbersBetween(nMin, nMax)
			return This.NNumbersBetween(nMin, nMax)

	#-- Z/EXTENDED FORM

	# n numbers between nMin and nMax, with their positions.
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

	# n numbers between nMin and nMax (bounds included), with their
	# positions.
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

	# Returns n numbers drawn at random, repeats allowed, from those not strictly between nMin and nMax.
	#
	#   _n_        how many numbers to draw
	#   nMin       the lower limit
	#   nMax       the upper limit
	#   returns    a list of numbers
	#   see        NumbersNotBetween, NNumbersBetween
	def NNumbersNotBetween(_n_, nMin, nMax)
		_anNumbers_ = This.NumbersNotBetween(nMin, nMax)
		_anResult_ = NRandomNumbersIn(_n_, _anNumbers_)

		return _anResult_

		def NRandomNumbersNotBetween(nMin, nMax)
			return This.NNumbersNotBetween(nMin, nMax)

	# Z/EXTENDED FORM

	# n numbers outside nMin..nMax, with their positions.
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


	# n numbers outside nMin..nMax (bounds included), with their
	# positions.
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


	# n numbers at positions OTHER than the given ones, with their
	# positions.
	def NNumbersOutsidePositionsZ(panPos)
		return This.NItemsOutsidePositionsZ(panPos)

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #--------------------------------------------------------#
	 #  GETTING N RANDOM NUMBERS OUTSIDE THE GIVEN POSITIONS  #
	#--------------------------------------------------------#

	def NNumbersOutsidePositions(panPos)
		return This.NItemsOutsidePositions(panPos)


	# Returns every number at a position outside the given one(s), as [ number, position ] pairs.
	#
	#   _anPos_    the position to avoid, or a list of positions to avoid
	#   returns    a list of [ number, position ] pairs, in position order
	#   see        NumbersOutsidePosition
	#@ aka  The numbers at positions other than the given one, with their positions.
	def NItemsOutsidePositionZ(_anPos_)
		_anAvoid_ = []
		if isNumber(_anPos_)
			_anAvoid_ + _anPos_
		but isList(_anPos_)
			_anAvoid_ = _anPos_
		else
			StzRaise("Incorrect param type! the positions must be a number or a list of numbers.")
		ok

		_aResult_ = []
		_anOutside_ = This._PositionsOutside(_anAvoid_)
		_nLen_ = len(_anOutside_)
		for i = 1 to _nLen_
			_aResult_ + [ @aContent[ _anOutside_[i] ], _anOutside_[i] ]
		next

		return _aResult_

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #---------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS FROM THE LIST  #
	#=============================================#

	# Returns some numbers picked at random, a random-sized selection of the list's items.
	#
	#   returns    a list of numbers
	#   see        NRandomNumbers, ARandomNumber
	def SomeRandomNumbers()
		return This._SomeNumbersAmong( This._AllPositions() )

		def SomeNumbers()
			return This.SomeRandomNumbers()


	# Some numbers picked at random, with their positions.
	def SomeRandomNumbersZ()
		return This._SomeNumbersAmongZ( This._AllPositions() )

	# U/EXTENDED FORM (TODO)

	
	# UZ/EXTENDED FORM (TODO)

	  #---------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS OTHER THEN A GIVEN NUMBER  #
	#---------------------------------------------------------#

	# Returns some numbers picked at random from those that differ from both given numbers.
	#
	#   _n_         a number to leave out
	#   _nNumber_   a second number to leave out
	#   returns     a list of numbers
	#   note        raises an error when a position is named instead of a number
	#   see         NumbersOtherThan, SomeRandomNumbers
	def SomeNumbersOtherThan(_n_, _nNumber_)
		if NOT ( isNumber(_n_) and isNumber(_nNumber_) )
			StzRaise("Incorrect param type! both parameters must be numbers.")
		ok

		return This._SomeNumbersAmong( This._PositionsOtherThan([ _n_, _nNumber_ ]) )

	# Some numbers other than the two given ones, with their positions.
	def SomeNumbersOtherThanZ(_n_, _nNumber_)
		if NOT ( isNumber(_n_) and isNumber(_nNumber_) )
			StzRaise("Incorrect param type! both parameters must be numbers.")
		ok

		return This._SomeNumbersAmongZ( This._PositionsOtherThan([ _n_, _nNumber_ ]) )

	  #--------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS LESS THEN A GIVEN NUMBER  #
	#--------------------------------------------------------#

	# Returns some numbers picked at random from those below a given number; the count is random.
	#
	#   _n_         not used; kept so the call reads like NNumbersLessThan
	#   _nNumber_   the number the answers must be below
	#   returns     a list of numbers; empty when none is below it
	#   see         NumbersSmallerThan
	def SomeNumbersLessThan(_n_, _nNumber_)
		return This._SomeNumbersAmong( This._PositionsBelow(_nNumber_) )


	# Some numbers less than n, with their positions.
	def SomeNumbersLessThanZ(_n_, _nNumber_)
		return This._SomeNumbersAmongZ( This._PositionsBelow(_nNumber_) )

	  #----------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS GRATER THEN A GIVEN NUMBER  #
	#----------------------------------------------------------#

	# Returns some numbers picked at random from those above a given number; the count is random.
	#
	#   _n_         not used; kept so the call reads like NNumbersGreaterThan
	#   _nNumber_   the number the answers must be above
	#   returns     a list of numbers; empty when none is above it
	#   see         NumbersGreaterThan
	def SomeNumbersGreaterThan(_n_, _nNumber_)
		return This._SomeNumbersAmong( This._PositionsAbove(_nNumber_) )


	# Some numbers greater than n, with their positions.
	def SomeNumbersGreaterThanZ(_n_, _nNumber_)
		return This._SomeNumbersAmongZ( This._PositionsAbove(_nNumber_) )

	  #------------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS OTHER THEN THE GIVEN NUMBERS  #
	#------------------------------------------------------------#

	def SomeNumbersOtherThanMany(paNumbers)
		return This._SomeNumbersAmong( This._PositionsOtherThan(paNumbers) )


	# Some numbers other than the given ones, with their positions.
	def SomeNumbersOtherThanManyZ(paNumbers)
		return This._SomeNumbersAmongZ( This._PositionsOtherThan(paNumbers) )

	  #---------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS BETWEEN TWO GIVEN NUMBERS  #
	#---------------------------------------------------------#

	# Returns some numbers picked at random from those strictly between two limits; the count is random.
	#
	#   nMin       the lower limit, not included
	#   nMax       the upper limit, not included
	#   returns    a list of numbers; empty when none lies between them
	#   see        NumbersBetween
	def SomeNumbersBetween(nMin, nMax)
		return This._SomeNumbersAmong( This._PositionsBetween(nMin, nMax, 0) )

	#-- Z/EXTENDED FORM

	def SomeNumbersBetweenZ(nMin, nMax)
		return This._SomeNumbersAmongZ( This._PositionsBetween(nMin, nMax, 0) )

	  #-------------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS NOT BETWEEN TWO GIVEN NUMBERS  #
	#-------------------------------------------------------------#

	# Returns some numbers picked at random from those outside two limits; the count is random.
	#
	#   nMin       the lower limit; the number itself counts as outside
	#   nMax       the upper limit; the number itself counts as outside
	#   returns    a list of numbers; empty when none lies outside
	#   see        NumbersNotBetween
	def SomeNumbersNotBetween(nMin, nMax)
		return This._SomeNumbersAmong( This._PositionsNotBetween(nMin, nMax, 0) )

	#-- Z/EXTENDED FORM

	def SomeNumbersNotBetweenZ(nMin, nMax)
		return This._SomeNumbersAmongZ( This._PositionsNotBetween(nMin, nMax, 0) )

	  #------------------------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#------------------------------------------------------------------------#

	def SomeNumbersBetweenIB(nMin, nMax)
		return This._SomeNumbersAmong( This._PositionsBetween(nMin, nMax, 1) )

	#-- Z/EXTENDED FORM

	def SomeNumbersBetweenIBZ(nMin, nMax)
		return This._SomeNumbersAmongZ( This._PositionsBetween(nMin, nMax, 1) )

	  #----------------------------------------------------------------------------#
	 #  GETTING SOME RANDOM NUMBERS NOT BETWEEN TWO GIVEN NUMBERS -- IB/EXTENDED  #
	#----------------------------------------------------------------------------#

	def SomeNumbersNotBetweenIB(nMin, nMax)
		return This._SomeNumbersAmong( This._PositionsNotBetween(nMin, nMax, 1) )

	#-- Z/EXTENDED FORM

	def SomeNumbersNotBetweenIBZ(nMin, nMax)
		return This._SomeNumbersAmongZ( This._PositionsNotBetween(nMin, nMax, 1) )

		return _aResult_

	  #===================================================#
	 #  GETTING THE NUMBERS SMALLER THAN A GIVEN NUMBER  #
	#===================================================#

	# Returns the numbers below n, in list order.
	#
	#   _n_        the limit, not included
	#   returns    a list of numbers
	#   see        NumbersGreaterThan, NumbersBetween
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

		_aResult_ = []

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

	# Returns the numbers above n, in list order.
	#
	#   _n_        the limit, not included
	#   returns    a list of numbers
	#   see        NumbersSmallerThan, NumbersBetween
	def NumbersGreaterThan(_n_)
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

		def NumbersGreaterThanQRT(_n_, pcReturnType)
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
			return This.NumbersGreaterThan(_n_)

			def NumbersLargerThanQ(_n_)
				return This.NumbersGreaterThanQ(_n_)

			def NumbersLargerThanQRT(_n_, pcReturnType)
				return This.NumbersGreaterThanQRT(_n_, pcReturnType)

		def NumbersBiggerThan(_n_)
			return This.NumbersGreaterThan(_n_)

			def NumbersBiggerThanQ(_n_)
				return This.NumbersGreaterThanQ(_n_)

			def NumbersBiggerThanQRT(_n_, pcReturnType)
				return This.NumbersGreaterThanQRT(_n_, pcReturnType)

		def NumbersMoreThan(_n_)
			return This.NumbersGreaterThan(_n_)

			def NumbersMoreThanQ(_n_)
				return This.NumbersGreaterThanQ(_n_)

			def NumbersMoreThanQRT(_n_, pcReturnType)
				return This.NumbersGreaterThanQRT(_n_, pcReturnType)

		#>

	#-- Z/EXTENDED FORM

	def NumbersGreaterThanZ(_n_)
		_anContent_ = This.Content()
		_nLen_ = len(_anContent_)

		_aResult_ = []

		for i = 1 to _nLen_
			if _anContent_[i] > _n_
				_aResult_ + [ _anContent_[i], i ]
			ok
		next

		return _aResult_

		#< @FunctionAlternativeForms

		def NumbersLargerThanZ(_n_)
			return This.NumbersGreaterThanZ(_n_)

		def NumbersBiggerThanZ(_n_)
			return This.NumbersGreaterThanZ(_n_)

		def NumbersMoreThanZ(_n_)
			return This.NumbersGreaterThanZ(_n_)

		#>

	  #-------------------------------------------------#
	 #  GETTING THE NUMBERS OTHER THAN A GIVEN NUMBER  #
	#-------------------------------------------------#

	# Returns the numbers that differ from n, in list order.
	#
	#   _n_        the number to leave out
	#   returns    a list of numbers
	#   see        NumbersOutsidePosition
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
		if NOT (isList(_anNumbers_) and @IsListOfNumbers(_anNumbers_))
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
		if NOT (isList(_anNumbers_) and @IsListOfNumbers(_anNumbers_))
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

	# Returns the numbers at every position but the given one.
	#
	#   _n_        the position to leave out
	#   returns    a list of numbers
	#   see        NumbersOtherThan
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

	# Returns the numbers strictly between nMin and nMax, in list order.
	#
	#   nMin       the lower limit, not included
	#   nMax       the upper limit, not included
	#   returns    a list of numbers
	#   note       returns [ ] when nMin is greater than nMax
	#   see        NumbersNotBetween, NumbersSmallerThan
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

	# Returns the numbers that are not strictly between nMin and nMax, in list order.
	#
	#   nMin       the lower limit
	#   nMax       the upper limit
	#   returns    a list of numbers
	#   note       the limits themselves count as outside
	#   see        NumbersBetween
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

	# TRUE if every number is below 0; TRUE for an empty list.
	#
	#   returns    TRUE or FALSE
	#   see        ArePositive, ContainsNegativeNumbers
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

		# TRUE if every number is negative, or, in a negated truth statement, if none is.
		#
		#   returns    TRUE or FALSE
		#   see        AreNegative
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

	# TRUE if every number is above 0; TRUE for an empty list.
	#
	#   returns    TRUE or FALSE
	#   note       0 is not positive
	#   see        AreNegative, ContainsPositiveNumbers
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

		# TRUE if every number is positive, or, in a negated truth statement, if none is.
		#
		#   returns    TRUE or FALSE
		#   see        ArePositive
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

	# TRUE if at least one number is above 0.
	#
	#   returns    TRUE or FALSE
	#   see        ArePositive, ContainsNegativeNumbers
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

	# TRUE if at least one number is below 0.
	#
	#   returns    TRUE or FALSE
	#   see        AreNegative, ContainsPositiveNumbers
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

	# Tells whether every number is strictly above n; a number equal to n makes it FALSE.
	#
	#   _n_        the limit
	#   returns    TRUE or FALSE
	#   note       the name spells Then for Than
	#   see        AreSmallerThen
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
			if _anContent_[@i] <= _n_
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def AreOver(_n_)
			return This.AreGreaterThen(_n_)

	# Tells whether every number is strictly below n; a number equal to n makes it FALSE.
	#
	#   _n_        the limit
	#   returns    TRUE or FALSE
	#   note       the name spells Then for Than
	#   see        AreGreaterThen
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
			if _anContent_[@i] >= _n_
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

		def AreUnder(_n_)
			return This.AreSmallerThen(_n_)

	# TRUE if every number is divisible by n.
	#
	#   _n_        the divisor
	#   returns    TRUE or FALSE
	#   note       raises an error when n is 0
	#   see        ContainsADividableNumberBy
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

	# Returns the numbers as text padded with spaces to one width, lined up on the decimal point.
	#
	#   returns    a list of strings
	#   note       every number is shown with the decimals of the longest one; an integer in the
	#              list gets a trailing point when no number has decimals
	#   see        AdjustUsing
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

	# Returns the numbers as text padded with the given char to one width, lined up on the decimal point.
	#
	#   c          the padding char, as a one-char text
	#   returns    a list of strings
	#   note       [ 3.5, 12, 0.25 ] with "0" gives "03.50", "12.00", "00.25"
	#   see        Adjust
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

	# Sorts the numbers from the smallest to the largest, in place.
	#
	#   returns    nothing; the list changes
	#   see        SortedInAscending, SortInDescending
	def SortInAscending()
		_aResult_ = @Sort(This.Content())
		This.UpdateWith(_aResult_)

		#< @FunctionAlternativeForms

		def SortInAscendingQ()
			This.SortInAscending()
			return This

		# Sorts the numbers from the smallest to the largest, in place.
		#
		#   returns    nothing; the list changes
		#   see        SortInAscending
		def SortUp()
			This.SortInAscending()

			def SortUpQ()
				return This.SortInAscendingQ()

	# Returns the numbers sorted from the smallest to the largest; the list is unchanged.
	#
	#   returns    a list of numbers
	#   see        SortInAscending
		#>
	def SortedInAscending()
		_aResult_ = This.Copy().SortInAscendingQ().Content()
		return _aResult_

		def SortedUp()
			return This.SortedInAscending()

	  #-------------------------------------#
	 #  SORTING THE NUMBERS IN DESCENDING  #
	#-------------------------------------#

	# Sorts the numbers from the largest to the smallest, in place.
	#
	#   returns    nothing; the list changes
	#   see        SortedInDescending, SortInAscending
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

		# Sorts the numbers from the largest to the smallest, in place.
		#
		#   returns    nothing; the list changes
		#   see        SortInDescending
		def SortDown()
			This.SortInDescending()

			def SortDownQ()
				return This.SortInDescendingQ()

	# Returns the numbers sorted from the largest to the smallest; the list is unchanged.
	#
	#   returns    a list of numbers
	#   see        SortInDescending
	def SortedInDescending()
		_acResult_ = This.Copy().SortInDescendingQ().Content()
		return _acResult_

		def SortedDown()
			return This.SortedInDescending()
 
	  #-----------------------------------------------------------------#
	 #  SORTING THE STRINGS BY AN EVALUATED EXPRESSION - IN ASCENDING  #
	#=================================================================#
 
	# Sorts the numbers in place by the value of an expression, smallest first.
	#
	#   pcExpr     an expression that contains @number, the current number
	#   returns    nothing; the list changes
	#   note       raises an error when the expression does not contain @number
	#   see        SortedBy, SortByInDescending
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

		# Sorts the numbers in place by the value of an expression, smallest first.
		#
		#   pcExpr     an expression that contains @number, the current number
		#   returns    nothing; the list changes
		#   note       raises an error when the expression does not contain @number
		#   see        SortBy
		#>
		#< @FunctionAlternativeForms
		def SortByInAscending(pcExpr)
			This.SortBy(pcExpr)

			def SortByInAscendingQ(pcExpr)
				return This.SortByQ(pcExpr)

		# Sorts the numbers in place by the value of an expression, smallest first.
		#
		#   pcExpr     an expression that contains @number, the current number
		#   returns    nothing; the list changes
		#   note       raises an error when the expression does not contain @number
		#   see        SortBy
		def SortByUp(pcExpr)
			This.SortBy(pcExpr)

			def SortByUpQ(pcExpr)
				return This.SortByQ(pcExpr)

	# Returns the numbers sorted by the value of an expression, smallest first; the list is unchanged.
	#
	#   pcExpr     an expression that contains @number, the current number
	#   returns    a list of numbers
	#   note       raises an error when the expression does not contain @number
	#   see        SortBy
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
 
	# Sorts the numbers by an expression, the largest value of the expression first, in place.
	#
	#   pcExpr     an expression that contains @number, the current number
	#   returns    nothing; the list changes
	#   see        SortBy
	def SortByInDescending(pcExpr)
		_aSorted_ = This.SortedByInAscending(pcExpr)
		_nSorted_ = len(_aSorted_)

		_aResult_ = []
		for i = _nSorted_ to 1 step -1
			_aResult_ + _aSorted_[i]
		next

		This.UpdateWith(_aResult_)

		def SortByInDescendingQ(pcExpr)
			This.SortByInDescending(pcExpr)
			return This

		# Sorts the numbers by an expression, the largest value of the expression first, in place.
		#
		#   pcExpr     an expression that contains @number, the current number
		#   returns    nothing; the list changes
		#   see        SortByInDescending
		def SortByDown(pcExpr)
			This.SortByInDescending(pcExpr)

			def SortByDownQ(pcExpr)
				return This.SortByInDescendingQ(pcExpr)

	# Returns the numbers sorted by an expression, the largest value of the expression first.
	#
	#   pcExpr     an expression that contains @number, the current number
	#   returns    a list of numbers
	#   see        SortedBy
	def SortedByInDescending(pcExpr)
		_aResult_ = This.Copy().SortByInDescendingQ(pcExpr).Content()
		return _aResult_

		def SortedByDown(pcExpr)
			return This.SortedByInDescending(pcExpr)

	  #--------------------------------------#
	 #  GETTING THE SPEEDUP OF THE NUMBERS  #
	#======================================#

	# Returns each number divided by the one that follows it.
	#
	#   returns    a list of numbers, one fewer than the list
	#   note       [ 1 ] for a list of one number
	#   see        GainsX, PerfGains
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

	# Returns each number divided by the one before it, as a factor of growth.
	#
	#   returns    a list of numbers, one fewer than the list
	#   see        SpeedUps, Gains
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

	# Returns the drop from each number to the next as a percentage of the earlier one; a rise is negative.
	#
	#   returns    a list of numbers, one fewer than the list
	#   see        SpeedUps, Gains
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

	# Returns the change from each number to the next as a percentage of the later one; a drop is negative.
	#
	#   returns    a list of numbers, one fewer than the list
	#   see        PerfGains, GainsX
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

	# TRUE if every number is prime.
	#
	#   returns    TRUE or FALSE
	#   see        AreWeiferich
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

	# TRUE if every number is a Weiferich prime (1093 and 3511 are the known ones).
	#
	#   returns    TRUE or FALSE
	#   see        ArePrimes
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

	# TRUE if some number has the opposite sign to the first number.
	#
	#   returns    TRUE or FALSE
	#   note       FALSE for fewer than two numbers
	#   see        ContainsPositiveNumbers, ContainsNegativeNumbers
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

	# TRUE if no number is 0.
	#
	#   returns    TRUE or FALSE
	#   see        ArePositive
	def AreNonZeroNumbers()
	
		_nLen_ = len(@aContent)
	
		for i = 1 to _nLen_
			if @aContent[i] = 0
				return 0
			ok
		next
		
		return 1
	
		def AreNonNullNumbers()
			return This.AreNonZeroNumbers()

	  #------------------------------------------------------#
	 #  CHECKINg IF THE NUMBERS HAVE A CONSTANT DIFFERENCE  #
	#------------------------------------------------------#

	# TRUE if the gap between each number and the next is always the same.
	#
	#   returns    TRUE or FALSE
	#   see        Steps, Diff
	def HaveSameDifference()
		return @HaveSameDifference(This.Content())


  /////////////////////////
 ///  THE WALKER CLASS  ///
/////////////////////////

# Walks from a start number toward an end number, taking a repeating pattern of steps.
#
# A stzWalker holds a start, an end and a pattern of steps; its walkables are the numbers it
# visits. stzListOfNumbers.Walker() builds the walker that reproduces a list: for [ 1, 2, 5, 6, 9, 10 ]
# the pattern is [ 1, 3 ], so from 1 it visits 1, 2, 5, 6, 9, 10. Without a number of times it stops
# when it lands on the end, or goes past it.
#
#   receiver   o1 = new stzWalker(1, 10, [ 1, 3 ])
#   example    ? @@( o1.Walkables() )
#              #--> [ 1, 2, 5, 6, 9, 10 ]
#   see        stzListOfNumbers
class stzWalker
	@nStart
	@nEnd
	@anSteps
	@nTimes = 0

	# Builds the walker from a start, an end and the steps to repeat; the steps must be a non-empty list of numbers.
	#
	#   pnStart    the number to start from
	#   pnEnd      the number to stop at
	#   panSteps   the steps taken in turn, over and over
	#   returns    nothing; the walker is built
	#   note       raises an error when a parameter is not a number or the steps are empty
	#@ aka  Build the walker from its start, its end and its steps.
	def init(pnStart, pnEnd, panSteps)
		if NOT ( isNumber(pnStart) and isNumber(pnEnd) )
			StzRaise("Incorrect param type! the start and the end must be numbers.")
		ok

		if NOT ( isList(panSteps) and len(panSteps) > 0 and @IsListOfNumbers(panSteps) )
			StzRaise("Incorrect param type! the steps must be a non-empty list of numbers.")
		ok

		@nStart = pnStart
		@nEnd = pnEnd
		@anSteps = panSteps

	# Returns the number the walker starts from.
	#
	#   returns    a number
	#   see        EndNumber
	#@ aka  The first number of the walk.
	def StartNumber()
		return @nStart

	# Returns the number the walker stops at.
	#
	#   returns    a number
	#   see        StartNumber
	#@ aka  The last number of the walk.
	def EndNumber()
		return @nEnd

	# Returns the steps the walker takes in turn.
	#
	#   returns    a list of numbers
	#   see        Walkables
	#@ aka  The repeating pattern of steps.
	def Steps()
		return @anSteps

	# Makes the walk visit exactly n numbers, whatever the end is.
	#
	#   _n_        how many numbers to visit; 0 goes back to stopping at the end
	#   returns    nothing; the walker changes
	#   see        Walkables
	#@ aka  Fix how many numbers the walk visits.
	def WalkNumberOfTimes(_n_)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		@nTimes = _n_

	# Returns the numbers the walker visits, in order, starting with the start.
	#
	#   returns    a list of numbers
	#   note       with no fixed count it stops at the end, or when it would go past it
	#   see        WalkNumberOfTimes
	#@ aka  The numbers visited by the walk.
	def Walkables()
		_anResult_ = [ @nStart ]
		_nCurrent_ = @nStart
		_nSteps_ = len(@anSteps)
		_i_ = 0

		while 1
			if @nTimes > 0
				if len(_anResult_) >= @nTimes
					exit
				ok
			else
				if _nCurrent_ = @nEnd
					exit
				ok
			ok

			_nStep_ = @anSteps[ (_i_ % _nSteps_) + 1 ]
			_nCurrent_ += _nStep_
			_i_++

			if @nTimes = 0
				if ( _nStep_ > 0 and _nCurrent_ > @nEnd ) or ( _nStep_ < 0 and _nCurrent_ < @nEnd ) or _nStep_ = 0
					exit
				ok
			ok

			_anResult_ + _nCurrent_
		end

		return _anResult_
