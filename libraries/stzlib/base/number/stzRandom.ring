

#TODO // Propose examples showing realword applications of randomness:
#	- Generating unique passwords
#	- Randomizing data
#	- Monte Carlo simulations
#	- Randomizing game scanrios
#	- etc

#TODO //Organize the file into thematic sections
#	CONSTANTS
#	PROBABILISTIC FUNCTIONS
#	CONFIGURATION FUNCTIONS
# 	CORE RANDOM FUNCTIONS
# 	RANDOM NUMBER FUNCTIONS
#	RANDOM ITEM FUNCTIONS
# 	PERCENT FUNCTIONS


_nRingMaxRandom = 999_999_999 # Based on my testing of Ring random() function
			      #NOTE// if you seed the Ring random() function
			      # with a value greater than that, you will get ""
			      # as a result! Example : random(9_999_999_999)

_nRingMaxSeed = 1_999_999_999 # Idem

_nRandomRound = 3	# Defines how many decimals are supported in random01()

_nMaxRandomLoop = 1000 	# How many times Softanza loops to find a given random number
			# before it aborts the process and raises an error
			#--> Used as a safey featur with while loops inorder to
			# avoid infite lopps

_nNoRatio = 0
_nFewRatio = 0.15
_nSomeRatio = 0.30
_nHalfRatio = 0.50
_nManyRatio = 0.70
_nMostRatio = 0.90
_nAllRatio = 1

_nProbablyRatio = 0.50
_nUnlikelyRatio = 0.05
_nPerhapsRatio = 0.50
_nAlmostRatio = 0.95

# Probabilistic functions

func DefaultNo()
	return _nNoRatio

	func DefaultAny()
		return _nNoRatio

	func _No()
		return _nNoRatio

	func _Any()
		return _nNoRatio

func SetNo(_nRatio_)

	if CheckParams()
		if isList(_nRatio_) and len(_nRatio_) = 2 and
		   isString(_n_[1]) and _n_[1] = :To

			_nRatio_ = _nRatio_[2]
		ok

		if NOT ( isNumber(_nRatio_) and (_nRatio_ >= 0 and _nRatio_ <= 1) )
			StzRaise("Incorrect param! nRatio must be a number between 0 and 1.")
		ok
	ok

	_nNoRatio = _nRatio_

	func SetAny(_nRatio_)
		SetNo(_nRatio_)

	func SetNoTo(_nRatio_)
		SetNo(_nRatio_)

	func SetAnyTo(_nRatio_)
		SetNo(_nRatio_)


func No(p)
	return []

	#< @FunctionFluentForms

	func NoQ(p)
		return Q(No(p))

	func NoQQ(p)
		return QQ(No(p))

	#>

	#< @FunctionAlternativeForms

	func Any(p)
		return No(p)

		func AnyQ(p)
			return NoQ(p)

		func AnyQQ(_n_)
			return NoQQ(p)

	func NoOne(p)
		return No(p)

		func NoOneQ(p)
			return NoQ(p)

		func NoOneQQ(p)
			return NoQQ(p)

	func NoOneOf(p)
		return No(p)

		func NoOneOfQ(p)
			return NoQ(p)

		func NoOneOfQQ(_n_)
			return NoQQ(_n_)

	func NoOneIn(p)
		return No(p)

		func NoOneInQ(p)
			return NoQ(p)

		func NoOneInQQ(_n_)
			return NoQQ(_n_)

	func NoOneAmong(p)
		return No(p)

		func NoOneAmongQ(p)
			return NoQ(p)

		func NoOneAmongQQ(_n_)
			return NoQQ(_n_)

	func NothingOf(p)
		return No(p)

		func NothingOfQ(p)
			return NoQ(p)

		func NothingOfQQ(_n_)
			return NoQQ(_n_)

	func NothingIn(p)
		return No(p)

		func NothingInQ(p)
			return NoQ(p)

		func NothingInQQ(_n_)
			return NoQQ(_n_)

	func NothingAmong(p)
		return No(p)

		func NothingAmongQ(p)
			return NoQ(p)

		func NothingAmongQQ(_n_)
			return NoQQ(_n_)

	func NoItemIn(p)
		return No(p)

		func NoItemInQ(p)
			return NoQ(p)

		func NoItemInQQ(_n_)
			return NoQQ(_n_)

	func NoItemAmong(p)
		func NoItemAmongQ(p)
			return NoQ(p)

		func NoItemamongQQ(_n_)
			return NoQQ(_n_)

	#>

	#< @FunctionStatementForm

	func NothingInQQX(p)
		_bXStatement_ = 0
		return QQ(p)

		func NoNumberInQQX(p)
			return NothingInQQX(p)

	#>

func SomeOneIn(paList)
	return AnItemIn(paList)

	#< @FunctionFluentForms

	func SomeOneInQ(paList)
		return Q(SomeOneIn(paList))

	func SomeOneInQQ(paList)
		return QQ(SomeOneIn(paList))

	#>

	#< @FunctionAlternativeForms

	func RandomIn(paList)
		return SomeOneIn(paList)

	func SomeOneOf(paList)
		return SomeOneIn(paList)

		func SomeOneOfQ(paList)
			return Q(SomeThingIn(paList))

		func SomeOneOfQQ(paList)
			return QQ(SomeThingIn(paList))

	#--

	func SomeThingIn(paList)
		return SomeOneIn(paList)

		func SomeThingInQ(paList)
			return Q(SomeThingIn(paList))

		func SomeThingInQQ(paList)
			return QQ(SomeThingIn(paList))

	func SomeThingOf(paList)
		return SomeOneIn(paList)

		func SomeThingOfQ(paList)
			return Q(SomeThingIn(paList))

		func SomeThingOfQQ(paList)
			return QQ(SomeThingIn(paList))

	#--

	func SomeOneAmong(paList)
		return SomeOneIn(paList)

		func SomeOneAmongQ(paList)
			return Q(SomeThingIn(paList))

		func SomeOneAmongQQ(paList)
			return QQ(SomeThingIn(paList))

	func SomeThingAmong(paList)
		return SomeOneIn(paList)

		func SomeThingAmongQ(paList)
			return Q(SomeThingIn(paList))

		func SomeThingAmongQQ(paList)
			return QQ(SomeThingIn(paList))

	#>
#--

func DefaultFew()
	return _nFewRatio

	func _Few()
		return _nFewRatio

func SetFew(_nRatio_)

	if CheckParams()
		if isList(_nRatio_) and len(_nRatio_) = 2 and
		   isString(_n_[1]) and _n_[1] = :To

			_nRatio_ = _nRatio_[2]
		ok

		if NOT ( isNumber(_nRatio_) and (_nRatio_ >= 0 and _nRatio_ <= 1) )
			StzRaise("Incorrect param! nRatio must be a number between 0 and 1.")
		ok
	ok

	_nFewRatio = _nRatio_

func Few(paList)
	return FewXT(paList, DefaultFew())

	#< @FunctionFluentForms

	func FewQ(paList)
		return Q(Few(paList))

	func FewQQ(paList)
		return QQ(Few(paList))

	#>

	#< @FunctionAlternativeForms

	func FewOf(p)
		return Few(p)

		def FewOfQ(p)
			return FewQ(p)

		def FewOfQQ(p)
			return FewQQ(p)

	func FewIn(p)
		return Few(p)

		def FewInQ(p)
			return FewQ(p)

		def FewInQQ(p)
			return FewQQ(p)

	func FewAmong(p)
		return Few(p)

		def FewAmongQ(p)
			return FewQ(p)

		def FewAmongQQ(p)
			return FewQQ(p)
	#>

func FewXT(paList, nFewRatio)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok

		if NOT isNumber(nFewRatio)
			StzRaise("Incorrect param type! nFewRatio must be a number.")
		ok
	ok

	_n_ = ceil( len(paList) * nFewRatio )
	return NRandomItemsInU(_n_, paList)

	#< @FunctionFluentForms

	func FewXTQ(paList, nFewRatio)
		return Q(FewXT(paList, nFewRatio))

	func FewXTQQ(paList)
		return QQ(Few(paList, nFewRatio))

	#>

	#< @FunctionAlternativeForms

	func FewOfXT(paList, nFewRatio)
		return FewXT(paList, nFewRatio)

		def FewOfXTQ(paList, nFewRatio)
			return FewXTQ(paList, nFewRatio)

		def FewOfXTQQ(paList, nFewRatio)
			return FewXTQQ(paList, nFewRatio)

	func FewInXT(paList, nFewRatio)
		return FewXT(paList, nFewRatio)

		def FewInXTQ(paList, nFewRatio)
			return FewXTQ(paList, nFewRatio)

		def FewInXTQQ(paList, nFewRatio)
			return FewXTQQ(paList, nFewRatio)

	func FewAmongXT(paList, nFewRatio)
		return FewXT(paList, nFewRatio)

		def FewAmongXTQ(paList, nFewRatio)
			return FewXTQ(paList, nFewRatio)

		def FewAmongXTQQ(paList, nFewRatio)
			return FewXTQQ(paList, nFewRatio)
	#>

#--

func DefaultSome()
	return _nSomeRatio

	func _Some()
		return _nSomeRatio

func SetSome(_nRatio_)

	if CheckParams()
		if isList(_nRatio_) and len(_nRatio_) = 2 and
		   isString(_n_[1]) and _n_[1] = :To

			_nRatio_ = _nRatio_[2]
		ok

		if NOT ( isNumber(_nRatio_) and (_nRatio_ >= 0 and _nRatio_ <= 1) )
			StzRaise("Incorrect param! nRatio must be a number between 0 and 1.")
		ok
	ok

	_nSomeRatio = _nRatio_

	func SetSomeTo(_nRatio_)
		_nSomeRatio = _nRatio_

func Some(paList)
	return SomeXT(paList, DefaultSome())

	#< @FunctionFluentForms

	func SomeQ(paList)
		return Q(Some(paList))

	func SomeQQ(paList)
		return QQ(Some(paList))

	#>

	#< @FunctionAlternativeForms

	func SomeOf(paList)
		return Some(paList)

		func SomeOfQ(paList)
			return SomeQ(paList)

		func SomeOfQQ(paList)
			return SomeQQ(paList)

	func SomeIn(paList)
		return Some(paList)

		func SomeInQ(paList)
			return SomeQ(paList)

		func SomeInQQ(paList)
			return SomeQQ(paList)

	func SomeAmong(paList)
		return Some(paList)

		func SomeAmongQ(paList)
			return SomeQ(paList)

		func SomeAmongQQ(paList)
			return SomeQQ(paList)

	#>

func SomeXT(paList, nSomeRatio)

	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok

		if NOT isNumber(nSomeRatio)
			StzRaise("Incorrect param type! nSomeRatio must be a number.")
		ok
	ok

	_n_ = ceil( len(paList) * nSomeRatio )

	return NRandomItemsInU(_n_, paList)

	#< @FunctionFluentForms

	func SomeXTQ(paList, nSomeRatio)
		return Q(SomeXT(paList, nSomeRatio))

	func SomeXTQQ(paList, nSomeRatio)
		return QQ(SomeXT(paList, nSomeRatio))

	#>

	#< @FunctionAlternativeForms

	func SomeOfXT(paList, nSomeRatio)
		return SomeXT(paList, nSomeRatio)

		func SomeOfXTQ(paList, nSomeRatio)
			return SomeXTQ(paList, nSomeRatio)

		func SomeOfXTQQ(paList, nSomeRatio)
			return SomeXTQQ(paList, nSomeRatio)

	func SomeInXT(paList, nSomeRatio)
		return SomeXT(paList, nSomeRatio)

		func SomeInXTQ(paList, nSomeRatio)
			return SomeXTQ(paList, nSomeRatio)

		func SomeInXTQQ(paList, nSomeRatio)
			return SomeXTQQ(paList, nSomeRatio)

	func SomeAmongXT(paList, nSomeRatio)
		return SomeXT(paList, nSomeRatio)

		func SomeAmongXTQ(paList, nSomeRatio)
			return SomeXTQ(paList, nSomeRatio)

		func SomeAmongXTQQ(paList, nSomeRatio)
			return SomeXTQQ(paList, nSomeRatio)

	#>


#--

func DefaultHalf()
	return _nHalfRatio

	func _Half()
		return _nHalfRatio

func SetHalf(_nRatio_)

	if CheckParams()
		if isList(_nRatio_) and len(_nRatio_) = 2 and
		   isString(_n_[1]) and _n_[1] = :To

			_nRatio_ = _nRatio_[2]
		ok

		if NOT ( isNumber(_nRatio_) and (_nRatio_ >= 0 and _nRatio_ <= 1) )
			StzRaise("Incorrect param! nRatio must be a number between 0 and 1.")
		ok
	ok

	_nHalfRatio = _nRatio_

func Half(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	_n_ = ceil( len(paList) / 2 )
	return NRandomItemsInU(_n_, paList)

	#< @FunctionFluentForms

	func HalfQ(paList)
		return Q(Half(paList))

	func HalfQQ(paList)
		return QQ(Half(paList))

	#>

func HalfXT(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	_nLen_ = len(paList)
	if IsEven(_nLen_)
		_n_ = _nLen_ / 2
	else
		_n_ = ceil( _nLen_ / 2 )
	ok

	#< @FunctionFluentForms

	func HalfXTQ(paList)
		return Q(HalfXT(paList))

	func HalfXTQQ(paList)
		return QQ(HalfXT(paList))

	#>

#--

func DefaultMany()
	return _nManyRatio

	func _Many()
		return _nManyRatio

func Among(p)
	if CheckParams()

		if NOT (isList(p) or isString(p))
			StzRaise("Incorrect param type! p must be a list or string.")
		ok

	ok

	return p

	func AmongQ(p)
		return Q(Among(p))

	func AmongQQ(p)
		return QQ(Among(p))

func SetMany(_n_)
	_nManyRatio = _n_

func Many(paList)
	return ManyXT(paList, DefaultMany())

	#< @FunctionFluentForms

	func ManyQ(paList)
		return Q(Many(paList))

	func ManyQQ(paList)
		return QQ(Many(paList))

	#>

	#< @FunctionAlternativeForms

	func ManyIn(paList)
		return Many(paList)

		func ManyInQ(paList)
			return ManyQ(paList)

		func ManyInQQ(paList)
			return ManyQQ(paList)

	func ManyOf(paList)
		return Many(paList)

		func ManyOfQ(paList)
			return ManyQ(paList)

		func ManyOfQQ(paList)
			return ManyQQ(paList)

	func ManyAmong(paList)
		return Many(paList)

		func ManyAmongQ(paList)
			return ManyQ(paList)

		func ManyAmongQQ(paList)
			return ManyQQ(paList)

	#>

func ManyXT(paList, nManyRatio)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
		if NOT isNumber(nManyRatio)
			StzRaise("Incorrect param type! nManyRatio must be a number.")
		ok
	ok

	_n_ = ceil( len(paList) * nManyRatio )
	return NRandomItemsInU(_n_, paList)

	#< @FunctionFluentForms

	func ManyXTQ(paList)
		return Q(Many(paList))

	func ManyXTQQ(paList)
		return QQ(Many(paList))

	#>

	#< @FunctionAlternativeForms

	func ManyInXT(paList, nManyRatio)
		return ManyXT(paList, nManyRatio)

		func ManyInXTQ(paList, nManyRatio)
			return ManyXTQ(paList, nManyRatio)

		func ManyInXTQQ(paList, nManyRatio)
			return ManyXTQQ(paList, nManyRatio)

	func ManyOfXT(paList, nManyRatio)
		return ManyXT(paList, nManyRatio)

		func ManyOfXTQ(paList, nManyRatio)
			return ManyXTQ(paList, nManyRatio)

		func ManyOfXTQQ(paList, nManyRatio)
			return ManyXTQQ(paList, nManyRatio)

	func ManyAmongXT(paList, nManyRatio)
		return ManyXT(paList, nManyRatio)

		func ManyAmongXTQ(paList, nManyRatio)
			return ManyXTQ(paList, nManyRatio)

		func ManyAmongXTQQ(paList, nManyRatio)
			return ManyXTQQ(paList, nManyRatio)

	#>

#--

func DefaultMost()
	return _nMostRatio

	func _Most()
		return _nMostRatio

func SetMost(_nRatio_)

	if CheckParams()
		if isList(_nRatio_) and len(_nRatio_) = 2 and
		   isString(_n_[1]) and _n_[1] = :To

			_nRatio_ = _nRatio_[2]
		ok

		if NOT ( isNumber(_nRatio_) and (_nRatio_ >= 0 and _nRatio_ <= 1) )
			StzRaise("Incorrect param! nRatio must be a number between 0 and 1.")
		ok
	ok

	_nMostRatio = _nRatio_

func Most(paList)
	return MostXT(paList, DefaultMost())

	#< @FunctionFluentForms

	func MostQ(paList)
		return Q(Most(paList))

	func MostQQ(paList)
		return QQ(Most(paList))

	#>

	#< @FunctionAlternativeForms

	func MostOf(paList)
		return Most(paList)

		func MostOfQ(paList)
			return MostQ(paList)

		func MostOfQQ(paList)
			return MostQQ(paList)

	#>

func MostXT(paList, nMostRatio)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
		if NOT isNumber(nMostRatio)
			StzRaise("Incorrect param type! nMostRatio must be a number.")
		ok
	ok

	_n_ = floor( len(paList) * nMostRatio )
	return NRandomItemsInU(_n_, paList)

	#< @FunctionFluentForms

	func MostXTQ(paList, nMostRatio)
		return Q(MostXT(paList, nMostRatio))

	func MostXTQQ(paList, nMostRatio)
		return QQ(MostXT(paList, nMostRatio))

	#>

	#< @FunctionAlternativeForms

	func MostOfXT(paList, nMostRatio)
		return MostXT(paList, nMostRatio)

		func MostOfXTQ(paList, nMostRatio)
			return MostXTQ(paList, nMostRatio)

		func MostOfXTQQ(paList, nMostRatio)
			return MostXTQQ(paList, nMostRatio)

	#>

#--

func DefaultAll()
	return _nAllRatio

	func _All()
		return n_All

func SetAll(_nRatio_)

	if CheckParams()
		if isList(_nRatio_) and len(_nRatio_) = 2 and
		   isString(_n_[1]) and _n_[1] = :To

			_nRatio_ = _nRatio_[2]
		ok

		if NOT ( isNumber(_nRatio_) and (_nRatio_ >= 0 and _nRatio_ <= 1) )
			StzRaise("Incorrect param! nRatio must be a number between 0 and 1.")
		ok
	ok

	_nAllRatio = _nRatio_

func All(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	return paList

	#< @FunctionFluentForms

	func AllQ(paList)
		return Q(All(paList))

	func AllQQ(paList)
		return QQ(All(paList))

	#>

	#< @FunctionAlternativeForms

	func AllOf(paList)
		return All(paList)

		func AllOfQ(paList)
			return AllQ(paList)

		func AllOfQQ(paList)
			return AllQQ(paList)

	func AllIn(paList)
		return All(paList)

		func AllInQ(paList)
			return AllQ(paList)

		func AllInQQ(paList)
			return AllQQ(paList)

	func AllAmong(paList)
		return All(paList)

		func AllAmongQ(paList)
			return AllQ(paList)

		func AllAmongQQ(paList)
			return AllQQ(paList)

	func Every(paList)
		return All(paList)

		func EveryQ(paList)
			return AllQ(paList)

		func EveryQQ(paList)
			return AllQQ(paList)

	func EveryItemIn(paList)
		return All(paList)

		func EveryItemInQ(paList)
			return AllQ(paList)

		func EveryItemInQQ(paList)
			return AllQQ(paList)

	func EveryThingIn(paList)
		return All(paList)

		func EveryThingInQ(paList)
			return AllQ(paList)

		func EveryThingInQQ(paList)
			return AllQQ(paList)

	func EveryItemAmong(paList)
		return All(paList)

		func EveryItemAmongQ(paList)
			return AllQ(paList)

		func EveryItemAmongQQ(paList)
			return AllQQ(paList)

	func EveryThingAmong(paList)
		return All(paList)

		func EveryThingAmongQ(paList)
			return AllQ(paList)

		func EveryThingAmongQQ(paList)
			return AllQQ(paList)

	#>

	#< @FunctionStatementForm

	func EveryThingInQQX(p)
		_bXStatement_ = 1
		return QQ(p)

	#>

func AllNumbers(panList)
	if CheckingParams()

		if NOT isList(panList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok

		_aLast_ = panList[len(panList)]
		if isList(aList) and IsAndNamedParamList(_aLast_)
			del(panList, len(panList))
			panList + _aLast_[2]
		ok

		if NOT isListOfNumbers(panList)
			StzRaise("Incorrect param type! paList must be a list of numbers.")
		ok
	ok

	return paList

	#< @FunctionFluentForms

	func AllNumbersQ(paList)
		return Q(AllNumbers(paList))

	func AllNumbersQQ(paList)
		return QQ(AllNumbers(paList))

	#>

	#< @FunctionAlternativeForms

	func AllNumbersIn(panList)
		return AllNumbers(panList)

		func AllNumbersInQ(panList)
			return AllNumbersQ(panList)

		func AllNumbersInQQ(paList)
			return AllNumbersQQ(panList)

	func EveryNumber(panList)
		return AllNumbers(panList)

		func EveryNumberQ(panList)
			return AllNumbersQ(panList)

		func EveryNumberQQ(paList)
			return AllNumbersQQ(panList)

	func EachNumber(panList)
		return AllNumbers(panList)

		func EachNumberQ(panList)
			return AllNumbersQ(panList)

		func EachNumberQQ(paList)
			return AllNumbersQQ(panList)

	func EveryNumberIn(panList)
		return AllNumbers(panList)

		func EveryNumberInQ(panList)
			return AllNumbersQ(panList)

		func EveryNumberInQQ(paList)
			return AllNumbersQQ(panList)

	func EachNumberIn(panList)
		return AllNumbers(panList)

		func EachNumberInQ(panList)
			return AllNumbersQ(panList)

		func EachNumberInQQ(paList)
			return AllNumbersQQ(panList)

	#>

	#< @FunctionStatementForm

	func AllNumbersQQX(panList)
		_bXStatement_ = 1
		return QQ(panList)

		func AllNumbersInQQX(panList)
			return AllNumbersQQX(panList)

	#>

#==

func MaxRandomLoop()
	return _nMaxRandomLoop

func SetMaxRandomLoop(_n_)
	if CheckingParams()
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	_nMaxRandomLoop = _n_

func RingMaxRandom()
	return _nRingMaxRandom

	func MaxRingRandom()
		return RingMaxRandom()

func RingMaxSeed()
	return _nRingMaxSeed

	func MaxRingSeed()
		return RingMaxSeed()

func RandomRound()
	return _nRandomRound

func RandomRoundXT()
	return pow(10, _nRandomRound)

func SetRandomRound(_n_)
	if CheckingParams()
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	_nRandomRound = _n_
				
func StzRandom(_n_)
	if CheckingParams()
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	if _n_ > RingMaxRandom()
		StzRaise("Can't proceed. n must be less than " + RingMaxRandom() + ".")
	ok

	if _n_ = 0
		return 0
	but _n_ > 0
		return StzEngineRandomInt(1, _n_)
	else
		return StzEngineRandomInt(_n_, -1)
	ok

	#--

	func StzRandom01()
		return StzEngineRandomFloat(0, 1)

	func Random01()
		return StzRandom01()

func StzSRandom(_n_)
	if CheckingParams()
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	if _n_ > RingMaxSeed()
		StzRaise("Can't proceed. n must be less than " + RingMaxSeed() + ".")
	ok

	return srandom(_n_)

func StzRandomXT(_n_, _nSeed_)
	if CheckingParams()
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if isList(_nSeed_) and Q(_nSeed_).IsSeedNamedParam()
			_nSeed_ = _nSeed_[2]
		ok

		if NOT isNumber(_nSeed_)
			StzRaise("Incorrect param type! nSeed must be a number.")
		ok
	ok

	SeedRandom(_nSeed_)
	return StzRandom(_n_)

	#--

	func StzRandom01XT(_nSeed_)
		_nResult_ = RandomNumberBetweenXT(0, RandomRoundXT(), _nSeed_) / RandomRoundXT()
		return _nResult_

	func Random01XT(_nSeed_)
		return StzRandom01XT(_nSeed_)

func SeedRandom(_n_)
	if CheckingParams()
		if isList(_n_) and Q(_n_).IsWithOrByOrUsingNamedParam()
			_n_ = _n_[2]
		ok
	ok

	if _n_ > RingMaxSeed()
		StzRaise("Can't proceed. n must be less than " + RingMaxSeed() + ".")
	ok

	srandom(_n_)

#---

func RandomNumber()
	return StzEngineRandomInt(1, RingMaxRandom())

	#< @FunctionAlternativeForms

	func ARandomNumber()
		return RandomNumber()

	func AnyRandomNumber()
		return RandomNumber()

	func AnyNumber()
		return RandomNumber()

	# Named-param DSL: ARandomNumberBetweenAnd(:Between = n1, :And = n2)
	# returns a random integer in [n1, n2] (inclusive). Strict bounds
	# (n1, n2) exclusive: use ARandomNumberStrictlyBetweenAnd.
	#
	# (ARandomNumberXT is already defined elsewhere as the seeded
	# bare-call form, so we don't reuse that name here.)

	func ARandomNumberBetweenAnd(p1, p2)
		return _ARandomNumberBetweenAnd(p1, p2, 0)   # inclusive

	func ARandomNumberStrictlyBetweenAnd(p1, p2)
		return _ARandomNumberBetweenAnd(p1, p2, 1)   # exclusive

	func _ARandomNumberBetweenAnd(p1, p2, bStrict)
		if NOT (isList(p1) and len(p1) = 2 and isString(p1[1]) and
		        lower(p1[1]) = "between" and isNumber(p1[2]))
			StzRaise("ARandomNumber: first arg must be :Between = <number>.")
		ok
		if NOT (isList(p2) and len(p2) = 2 and isString(p2[1]) and
		        lower(p2[1]) = "and" and isNumber(p2[2]))
			StzRaise("ARandomNumber: second arg must be :And = <number>.")
		ok
		_nMin_ = p1[2]
		_nMax_ = p2[2]
		if bStrict
			_nMin_ += 1
			_nMax_ -= 1
			if _nMin_ > _nMax_
				return _nMin_ - 1
			ok
		ok
		return RandomNumberBetween(_nMin_, _nMax_)

	#==

	func RandomNumber01()
		return StzRandom01()

	func ARandomNumber01()
		return StzRandom01()

	func AnyRandomNumber01()
		return StzRandom01()

	func AnyNumber01()
		return StzRandom01()

	#>

func RandomNumberXT(_nSeed_)
	StzSRandom(_nSeed_)
	return RandomNumber()

	#< @FunctionAlternativeForms

	func ARandomNumberXT(_nSeed_)
		return RandomNumberXT(_nSeed_)

	func AnyRandomNumberXT(_nSeed_)
		return RandomNumberXT(_nSeed_)

	func AnyNumberXT(_nSeed_)
		return RandomNumberXT(_nSeed_)

	#==

	func RandomNumber01XT(_nSeed_)
		return StzNumbers01XT(_nSeed_)

	func ARandomNumber01XT(_nSeed_)
		return StzNumbers01XT(_nSeed_)

	func AnyRandomNumber01XT(_nSeed_)
		return StzNumbers01XT(_nSeed_)

	func AnyNumber01XT(_nSeed_)
		return StzNumbers01XT(_nSeed_)

	#>

#--

func RandomNumberLessThan(_n_)
	return RandomNumberIn(1 : _n_)

	#< @FunctionAlternativeForms

	func ARandomNumberLessThan(_n_)
		return RandomNumberLessThan(_n_)

	func RandomNumberSmallerThan(_n_)
		return RandomNumberLessThan(_n_)

	func ARandomNumberSmallerThan(_n_)
		return RandomNumberLessThan(_n_)

	func ANumberSmallerThan(_n_)
		return RandomNumberLessThan(_n_)

	func ANumberLessThan(_n_)
		return RandomNumberLessThan(_n_)

	func AnyNumberSmallerThan(_n_)
		return RandomNumberLessThan(_n_)

	func AnyNumberLessThan(_n_)
		return RandomNumberLessThan(_n_)

	#==

	func RandomNumberLessThan01(_n_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
	
			if NOT ( _n_ >= 0 and _n_ <= 1 )
				StzRaise("Incorrect value! n must be a value between 0 and 1.")
			ok
		ok
	
		_i_ = 0
		_nRandom_ = 0
		while 1
			_i_++
			_nRandom_ = StzRandom01()
			if _nRandom_ < _n_ or _i_ = MaxRandomLoop()
				exit
			ok
		end
	
		if _nRandom_ >= _n_
			StzRaise("Can't proceed! A random number less than " + _n_ + " has not been reached after " + MaxRandomLoop() + " trials.")
		ok
	
		return _nRandom_
	

	func ARandomNumberLessThan01(_n_)
		return RandomNumberLessThan01(_n_)

	func RandomNumberSmallerThan01(_n_)
		return RandomNumberLessThan01(_n_)

	func ARandomNumberSmallerThan01(_n_)
		return RandomNumberLessThan01(_n_)

	func ANumberSmallerThan01(_n_)
		return RandomNumberLessThan01(_n_)

	func ANumberLessThan01(_n_)
		return RandomNumberLessThan01(_n_)

	func AnyNumberSmallerThan01(_n_)
		return RandomNumberLessThan01(_n_)

	func AnyNumberLessThan01(_n_)
		return RandomNumberLessThan01(_n_)

	#>

func RandomNumberLessThanXT(_n_, _nSeed_)
	StzSRandom(_nSeed_)
	return RandomNumberLessThan(_n_)

	#< @FunctionAlternativeForms

	func ARandomNumberLessThanXT(_n_, _nSeed_)
		return RandomNumberLessThanXT(_n_, _nSeed_)

	func RandomNumberSmallerThanXT(_n_, _nSeed_)
		return RandomNumberLessThanXT(_n_, _nSeed_)

	func ARandomNumberSmallerThanXT(_n_, _nSeed_)
		return RandomNumberLessThanXT(_n_, _nSeed_)

	func ANumberSmallerThanXT(_n_, _nSeed_)
		return RandomNumberLessThanXT(_n_, _nSeed_)

	func ANumberLessThanXT(_n_, _nSeed_)
		return RandomNumberLessThanXT(_n_, _nSeed_)

	func AnyNumberSmallerThanXT(_n_, _nSeed_)
		return RandomNumberLessThanXT(_n_, _nSeed_)

	func AnyNumberLessThanXT(_n_, _nSeed_)
		return RandomNumberLessThanXT(_n_, _nSeed_)

	#==

	func RandomNumberLessThan01XT(_n_, _nSeed_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
	
			if NOT ( _n_ >= 0 and _n_ <= 1 )
				StzRaise("Incorrect value! n must be a value between 0 and 1.")
			ok
		ok
	
		_i_ = 0
		_nRandom_ = 0
		while 1
			_i_++
			_nRandom_ = StzRandom01XT(_nSeed_)
			if _nRandom_ < _n_ or _i_ = MaxRandomLoop()
				exit
			ok
		end
	
		if _nRandom_ >= _n_
			StzRaise("Can't proceed! A random number less than " + _n_ + " has not been reached after " + MaxRandomLoop() + " trials.")
		ok
	
		return _nRandom_

	func ARandomNumberLessThan01XT(_n_, _nSeed_)
		return RandomNumberLessThan01XT(_n_, _nSeed_)

	func RandomNumberSmallerThan01XT(_n_, _nSeed_)
		return RandomNumberLessThan01XT(_n_, _nSeed_)

	func ARandomNumberSmallerThan01XT(_n_, _nSeed_)
		return RandomNumberLessThan01XT(_n_, _nSeed_)

	func ANumberSmallerThan01XT(_n_, _nSeed_)
		return RandomNumberLessThan01XT(_n_, _nSeed_)

	func ANumberLessThan01XT(_n_, _nSeed_)
		return RandomNumberLessThan01XT(_n_, _nSeed_)

	func AnyNumberSmallerThan01XT(_n_, _nSeed_)
		return RandomNumberLessThan01XT(_n_, _nSeed_)

	func AnyNumberLessThan01XT(_n_, _nSeed_)
		return RandomNumberLessThan01XT(_n_, _nSeed_)

	#>

#--

func RandomNumberGreaterThan(_n_)
	if CheckingParams()
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok
	
	return RandomNumberIn(_n_+1 : MaxRingNumber())

	#< @FunctionAlternativeForms

	func ARandomNumberGreaterThan(_n_)
		return RandomNumberGreaterThan(_n_)

	func RandomNumberBiggerThan(_n_)
		return RandomNumberGreaterThan(_n_)

	func ARandomNumberBiggerThan(_n_)
		return RandomNumberGreaterThan(_n_)

	func ANumberGreaterThan(_n_)
		return RandomNumberGreaterThan(_n_)

	func ANumberBiggerThan(_n_)
		return RandomNumberGreaterThan(_n_)

	func ANumberLargerThan(_n_)
		return RandomNumberGreaterThan(_n_)

	func AnyRandomNumberGreaterThan(_n_)
		return RandomNumberGreaterThan(_n_)

	func AnyRandomNumberBiggerThan(_n_)
		return RandomNumberGreaterThan(_n_, _nSeed_)

	func AnyNumberGreaterThan(_n_)
		return RandomNumberGreaterThan(_n_)

	func AnyNumberBiggerThan(_n_)
		return RandomNumberGreaterThan(_n_)

	func AnyNumberLargerThan(_n_)
		return RandomNumberGreaterThan(_n_)

	#==

	func RandomNumberGreaterThan01(_n_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
	
			if NOT ( _n_ >= 0 and _n_ <= 1 )
				StzRaise("Incorrect value! n must be a value between 0 and 1.")
			ok
		ok
	
		_i_ = 0
		_nRandom_ = 0
		while 1
			_i_++
			_nRandom_ = StzRandom01()
			if _nRandom_ > _n_ or _i_ = MaxRandomLoop()
				exit
			ok
		end
	
		if _nRandom_ <= _n_
			StzRaise("Can't proceed! A random number greater than " + _n_ + " has not been reached after " + MaxRandomLoop() + " trials.")
		ok
	
		return _nRandom_


	func ARandomNumberGreaterThan01(_n_)
		return RandomNumberGreaterThan01(_n_)

	func RandomNumberBiggerThan01(_n_)
		return RandomNumberGreaterThan01(_n_)

	func ARandomNumberBiggerThan01(_n_)
		return RandomNumberGreaterThan01(_n_)

	func ANumberGreaterThan01(_n_)
		return RandomNumberGreaterThan01(_n_)

	func ANumberBiggerThan01(_n_)
		return RandomNumberGreaterThan01(_n_)

	func ANumberLargerThan01(_n_)
		return RandomNumberGreaterThan01(_n_)

	func AnyRandomNumberGreaterThan01(_n_)
		return RandomNumberGreaterThan01(_n_)

	func AnyRandomNumberBiggerThan01(_n_)
		return RandomNumberGreaterThan01(_n_, _nSeed_)

	func AnyNumberGreaterThan01(_n_)
		return RandomNumberGreaterThan01(_n_)

	func AnyNumberBiggerThan01(_n_)
		return RandomNumberGreaterThan01(_n_)

	func AnyNumberLargerThan01(_n_)
		return RandomNumberGreaterThan01(_n_)

	#>

func RandomNumberGreaterThanXT(_n_, _nSeed_)
	StzSRandom(_nSeed_)
	return RandomNumberGreaterThan(_n_)

	#< @FunctionAlternativeForms

	func ARandomNumberGreaterThanXT(_n_, _nSeed_)
		return RandomNumberGreaterThanXT(_n_, _nSeed_)

	func RandomNumberBiggerThanXT(_n_, _nSeed_)
		return RandomNumberGreaterThanXT(_n_, _nSeed_)

	func ARandomNumberBiggerThanXT(_n_, _nSeed_)
		return RandomNumberGreaterThanXT(_n_, _nSeed_)

	func ANumberGreaterThanXT(_n_, _nSeed_)
		return RandomNumberGreaterThanXT(_n_, _nSeed_)

	func ANumberBiggerThanXT(_n_, _nSeed_)
		return RandomNumberGreaterThanXT(_n_, _nSeed_)

	func ANumberLargerThanXT(_n_, _nSeed_)
		return RandomNumberGreaterThanXT(_n_, _nSeed_)

	func AnyRandomNumberGreaterThanXT(_n_, _nSeed_)
		return RandomNumberGreaterThanXT(_n_, _nSeed_)

	func AnyRandomNumberBiggerThanXT(_n_, _nSeed_)
		return RandomNumberGreaterThanXT(_n_, _nSeed_)

	func AnyNumberGreaterThanXT(_n_, _nSeed_)
		return RandomNumberGreaterThanXT(_n_, _nSeed_)

	func AnyNumberBiggerThanXT(_n_, _nSeed_)
		return RandomNumberGreaterThanXT(_n_, _nSeed_)

	func AnyNumberLargerThanXT(_n_, _nSeed_)
		return RandomNumberGreaterThanXT(_n_, _nSeed_)

	#==

	func RandomNumberGreaterThan01XT(_n_, _nSeed_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
	
			if NOT ( _n_ >= 0 and _n_ <= 1 )
				StzRaise("Incorrect value! n must be a value between 0 and 1.")
			ok
		ok
	
		_i_ = 0
		_nRandom_ = 0
		while 1
			_i_++
			_nRandom_ = StzRandom01XT(_nSeed_)
			if _nRandom_ > _n_ or _i_ = MaxRandomLoop()
				exit
			ok
		end
	
		if _nRandom_ <= _n_
			StzRaise("Can't proceed! A random number greater than " + _n_ + " has not been reached after " + MaxRandomLoop() + " trials.")
		ok
	
		return _nRandom_

	func ARandomNumberGreaterThan01XT(_n_)
		return RandomNumberGreaterThan01XT(_n_)

	func RandomNumberBiggerThan01XT(_n_)
		return RandomNumberGreaterThan01XT(_n_)

	func ARandomNumberBiggerThan01XT(_n_)
		return RandomNumberGreaterThan01XT(_n_)

	func ANumberGreaterThan01XT(_n_)
		return RandomNumberGreaterThan01XT(_n_)

	func ANumberBiggerThan01XT(_n_)
		return RandomNumberGreaterThan01XT(_n_)

	func ANumberLargerThan01XT(_n_)
		return RandomNumberGreaterThan01XT(_n_)

	func AnyRandomNumberGreaterThan01XT(_n_)
		return RandomNumberGreaterThan01XT(_n_)

	func AnyRandomNumberBiggerThan01XT(_n_)
		return RandomNumberGreaterThan01XT(_n_, _nSeed_)

	func AnyNumberGreaterThan01XT(_n_)
		return RandomNumberGreaterThan01XT(_n_)

	func AnyNumberBiggerThan01XT(_n_)
		return RandomNumberGreaterThan01XT(_n_)

	func AnyNumberLargerThan01XT(_n_)
		return RandomNumberGreaterThan01XT(_n_)

	#>

#--

func RandomNumberOtherThan(_n_)
	_nResult_ = RandomNumberIn(1 : MaxRingNumber())
	if _nResult_ = _n_
		_nResult_ = _n_ - 1
		if _nResult_ < 0
			_nResult_ = 0
		ok
	ok
	return _nResult_

	#< @FunctionAlternativeForm

	func ARandomNumberOtherThan(_n_)
		return RandomNumberOtherThan(_n_)

	func AnyRandomNumberOtherThan(_n_)
		return RandomNumberOtherThan(_n_)

	func ANumberOtherThan(_n_)
		return RandomNumberOtherThan(_n_)

	func AnyNumberOtherThan(_n_)
		return RandomNumberOtherThan(_n_)

	func NumberOtherThan(_n_)
		return RandomNumberOtherThan(_n_)

	#--

	func ARandomNumberExcept(_n_)
		return RandomNumberOtherThan(_n_)

	func AnyRandomNumberExcept(_n_)
		return RandomNumberOtherThan(_n_)

	func ANumberExcept(_n_)
		return RandomNumberOtherThan(_n_)

	func AnyNumberExcept(_n_)
		return RandomNumberOtherThan(_n_)

	#==

	func RandomNumberOtherThan01(_n_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number")
			ok
	
			if NOT ( _n_ >= 0 and _n_ <=1 )
				StzRaise("Incorrect value! n must be a value between 0 and 1.")
			ok
		ok
	
		_i_ = 0
		_nRandom_ = 0
		while 1
			_i_++
			_nRandom_ = StzRandom01()
			if _nRandom_ != _n_ or _i_ = MaxRandomLoop()
				exit
			ok
		end
	
		if _nRandom_ = _n_
			StzRaise("Can't proceed! A random number different from " + _n_ + " has not been reached after " + MaxRandomLoop() + " trials.")
		ok
	
		return _nRandom_

	func AnyRandomNumberOtherThan01(_n_)
		return RandomNumberOtherThan01(_n_)

	func ANumberOtherThan01(_n_)
		return RandomNumberOtherThan01(_n_)

	func AnyNumberOtherThan01(_n_)
		return RandomNumberOtherThan01(_n_)

	func NumberOtherThan01(_n_)
		return RandomNumberOtherThan01(_n_)

	#--

	func ARandomNumberExcept01(_n_)
		return RandomNumberOtherThan01(_n_)

	func AnyRandomNumberExcept01(_n_)
		return RandomNumberOtherThan01(_n_)

	func ANumberExcept01(_n_)
		return RandomNumberOtherThan01(_n_)

	func AnyNumberExcept01(_n_)
		return RandomNumberOtherThan01(_n_)

	#>

func RandomNumberOtherThanXT(_n_, _nSeed_)
	StzSRandom(_nSeed_)
	return RandomNumberOtherThan(_n_)

	#< @FunctionAlternativeForm

	func ARandomNumberOtherThanXT(_n_, _nSeed_)
		return RandomNumberOtherThanXT(_n_, _nSeed_)

	func AnyRandomNumberOtherThanXT(_n_, _nSeed_)
		return RandomNumberOtherThanXT(_n_, _nSeed_)

	func ANumberOtherThanXT(_n_, _nSeed_)
		return RandomNumberOtherThanXT(_n_, _nSeed_)

	func AnyNumberOtherThanXT(_n_, _nSeed_)
		return RandomNumberOtherThanXT(_n_, _nSeed_)

	func NumberOtherThanXT(_n_, _nSeed_)
		return RandomNumberOtherThanXT(_n_, _nSeed_)

	#--

	func ARandomNumberExceptXT(_n_, _nSeed_)
		return RandomNumberOtherThanXT(_n_, _nSeed_)

	func AnyRandomNumberExceptXT(_n_, _nSeed_)
		return RandomNumberOtherThanXT(_n_, _nSeed_)

	func ANumberExceptXT(_n_, _nSeed_)
		return RandomNumberOtherThanXT(_n_, _nSeed_)

	func AnyNumberExceptXT(_n_, _nSeed_)
		return RandomNumberOtherThanXT(_n_, _nSeed_)

	#==

	func ARandomNumberOtherThan01XT(_n_, _nSeed_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number")
			ok

			if NOT ( _n_ >= 0 and _n_ <=1 )
				StzRaise("Incorrect value! n must be a value between 0 and 1.")
			ok
		ok

		_i_ = 0
		while 1
			_i_++
			_nRandom_ = ARandomNumber01XT(_nSeed_)
			if _nRandom_ != _n_ or _i_ = MaxRandomLoop()
				exit
			ok
		end

		if _nRandom_ != _n_
			_nResult_ = _nRandom_
		else
			StzRaise("Can't proceed! A random number has not been reached after " + MaxRandomLoop() + " trials.")
		ok

		return _nResult_

	func AnyRandomNumberOtherThan01XT(_n_, _nSeed_)
		return RandomNumberOtherThan01XT(_n_, _nSeed_)

	func ANumberOtherThan01XT(_n_, _nSeed_)
		return RandomNumberOtherThan01XT(_n_, _nSeed_)

	func AnyNumberOtherThan01XT(_n_, _nSeed_)
		return RandomNumberOtherThan01XT(_n_, _nSeed_)

	func NumberOtherThan01XT(_n_, _nSeed_)
		return RandomNumberOtherThan01XT(_n_, _nSeed_)

	#--

	func ARandomNumberExcept01XT(_n_, _nSeed_)
		return RandomNumberOtherThan01XT(_n_, _nSeed_)

	func AnyRandomNumberExcept01XT(_n_, _nSeed_)
		return RandomNumberOtherThan01XT(_n_, _nSeed_)

	func ANumberExcept01XT(_n_, _nSeed_)
		return RandomNumberOtherThan01XT(_n_, _nSeed_)

	func AnyNumberExcept01XT(_n_, _nSeed_)
		return RandomNumberOtherThan01XT(_n_, _nSeed_)

	#>

#==

func SomeRandomNumbersGreaterThan(nValue)
	_n_ = floor( _Some() * 10 )
	return NRandomNumbersGreaterThan(_n_, nValue)

	#< @FunctionAlternativeForms

	func SomeNumbersGreaterThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	func AnyRandomNumbersGreaterThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	func AnyNumbersGreaterThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	#--

	func SomeRandomNumbersBiggerThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	func SomeNumbersBiggerThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	func AnyRandomNumbersBiggerThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	func AnyNumbersBiggerThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	#--

	func RandomNumbersGreaterThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	func RandomNumbersBiggerThan(nValue)
		return SomeRandomNumbersGreaterThan(nValue)

	#==

	func SomeRandomNumbersGreaterThan01(nValue)
		_nSome_ = RandomNumberLessThan( floor(_Some() * 10) )
		_anResult_ = []
	
		for _i_ = 1 to _nSome_
			_anResult_ + RandomNumberGreaterThan01(nValue)
		next
	
		return _anResult_

	func SomeNumbersGreaterThan01(nValue)
		return SomeRandomNumbersGreaterThan01(nValue)

	func AnyRandomNumbersGreaterThan01(nValue)
		return SomeRandomNumbersGreaterThan01(nValue)

	func AnyNumbersGreaterThan01(nValue)
		return SomeRandomNumbersGreaterThan01(nValue)

	#--

	func SomeRandomNumbersBiggerThan01(nValue)
		return SomeRandomNumbersGreaterThan01(nValue)

	func SomeNumbersBiggerThan01(nValue)
		return SomeRandomNumbersGreaterThan01(nValue)

	func AnyRandomNumbersBiggerThan01(nValue)
		return SomeRandomNumbersGreaterThan01(nValue)

	func AnyNumbersBiggerThan01(nValue)
		return SomeRandomNumbersGreaterThan01(nValue)

	#--

	func RandomNumbersGreaterThan01(nValue)
		return SomeRandomNumbersGreaterThan01(nValue)

	func RandomNumbersBiggerThan01(nValue)
		return SomeRandomNumbersGreaterThan01(nValue)

	#>

func SomeRandomNumbersGreaterThanXT(_n_, _nSeed_)
	StzSRandom(_nSeed_)
	return SomeRandomNumbersGreaterThan(_n_)

	#< @FunctionAlternativeForms

	func SomeNumbersGreaterThanXT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThanXT(_n_, _nSeed_)

	func AnyRandomNumbersGreaterThanXT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThanXT(_n_, _nSeed_)

	func AnyNumbersGreaterThanXT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThanXT(_n_, _nSeed_)

	#--

	func SomeRandomNumbersBiggerThanXT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThanXT(_n_, _nSeed_)

	func SomeNumbersBiggerThanXT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThanXT(_n_, _nSeed_)

	func AnyRandomNumbersBiggerThanXT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThanXT(_n_, _nSeed_)

	func AnyNumbersBiggerThanXT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThanXT(_n_, _nSeed_)

	#==

	func RandomNumbersGreaterThanXT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThanXT(_n_, _nSeed_)

	func RandomNumbersBiggerThanXT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThanXT(_n_, _nSeed_)

	#==

	func SomeRandomNumbersGreaterThan01XT(_n_, _nSeed_)
		_nSome_ = RandomNumberLessThan( floor( _Some() * 10) )
		_anResult_ = []
	
		for _i_ = 1 to _nSome_
			_anResult_ + RandomNumberGreaterThan01XT(_n_, _nSeed_)
		next
	
		return _anResult_

	func SomeNumbersGreaterThan01XT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XT(_n_, _nSeed_)

	func AnyRandomNumbersGreaterThan01XT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XT(_n_, _nSeed_)

	func AnyNumbersGreaterThan01XT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XT(_n_, _nSeed_)

	#--

	func SomeRandomNumbersBiggerThan01XT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XT(_n_, _nSeed_)

	func SomeNumbersBiggerThan01XT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XT(_n_, _nSeed_)

	func AnyRandomNumbersBiggerThan01XT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XT(_n_, _nSeed_)

	func AnyNumbersBiggerThan01XT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XT(_n_, _nSeed_)

	#--

	func RandomNumbersGreaterThan01XT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XT(_n_, _nSeed_)

	func RandomNumbersBiggerThan01XT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XT(_n_, _nSeed_)

	#>

#--

func SomeRandomNumbersGreaterThanU(_n_)
	return NRandomNumbersGreaterThanU( floor( _Some() * 10), _n_)

	#< @FunctionAlternativeForms

	func SomeNumbersGreaterThanU(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	func AnyRandomNumbersGreaterThanU(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	func AnyNumbersGreaterThanU(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	#--

	func SomeRandomNumbersBiggerThanU(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	func SomeNumbersBiggerThanU(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	func AnyRandomNumbersBiggerThanU(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	func AnyNumbersBiggerThanU(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	#--

	func SomeUniqueRandomNumbersGreaterThanU(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	func SomeUniqueNumbersGreaterThanU(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	#--

	func SomeUniqueRandomNumbersBiggerThanU(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	func SomeUniqueNumbersBiggerThanU(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	#--

	func RandomNumbersGreaterThanU(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	func RandomNumbersBiggerThanU(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	func UniqueRandomNumbersGreaterThan(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	func UniqueRandomNumbersBiggerThan(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	#==

	func SomeRandomNumbersGreaterThan01U(_n_)
		_nSome_ = RandomNumberLessThan( floor(_Some() * 10) )
		_anResult_ = []
	
		while 1
			_nRandom_ = RandomNumberGreaterThan01(_n_)
			if StzFindFirst(_anResult_, _nRandom_) = 0
				_anResult_ + _nRandom_
	
				if len(_anResult_) = _nSome_
					exit
				ok
			ok
		end
	
		return _anResult_

	func SomeNumbersGreaterThan01U(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	func AnyRandomNumbersGreaterThan01U(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	func AnyNumbersGreaterThan01U(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	#--

	func SomeRandomNumbersBiggerThan01U(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	func SomeNumbersBiggerThan01U(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	func AnyRandomNumbersBiggerThan01U(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	func AnyNumbersBiggerThan01U(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	#--

	func SomeUniqueRandomNumbersGreaterThan01U(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	func SomeUniqueNumbersGreaterThan01U(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	#--

	func SomeUniqueRandomNumbersBiggerThan01U(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	func SomeUniqueNumbersBiggerThan01U(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	#--

	func RandomNumbersGreaterThan01U(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	func RandomNumbersBiggerThan01U(_n_)
		return SomeRandomNumbersGreaterThanU(_n_)

	func UniqueRandomNumbersGreaterThan01(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	func UniqueRandomNumbersBiggerThan01(_n_)
		return SomeRandomNumbersGreaterThan01U(_n_)

	#>

func SomeRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)
	StzSRandom(_nSeed_)
	return NRandomNumbersGreaterThanU(_n_, nValue)

	#< @FunctionAlternativeForms

	func SomeNumbersGreaterThanXTU(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(nValue, _nSeed_)

	func AnyRandomNumbersGreaterThanXTU(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(nValue, _nSeed_)

	func AnyNumbersGreaterThanXTU(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(nValue, _nSeed_)

	#--

	func SomeRandomNumbersBiggerThanXTU(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(nValue, _nSeed_)

	func SomeNumbersBiggerThanXTU(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(nValue, _nSeed_)

	func AnyRandomNumbersBiggerThanXTU(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(nValue, _nSeed_)

	func AnyNumbersBiggerThanXTU(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(nValue, _nSeed_)

	#--

	func SomeUniqueRandomNumbersGreaterThanXTU(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(nValue, _nSeed_)

	func SomeUniqueNumbersGreaterThanXTU(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(nValue, _nSeed_)

	#--

	func SomeUniqueRandomNumbersBiggerThanXTU(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(nValue, _nSeed_)

	func SomeUniqueNumbersBiggerThanXTU(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(nValue, _nSeed_)

	#--

	func RandomNumbersGreaterThanXTU(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(nValue, _nSeed_)

	func RandomNumbersBiggerThanXTU(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(nValue, _nSeed_)

	func UniqueRandomNumbersGreaterThanXT(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXT(nValue, _nSeed_)

	func UniqueRandomNumbersBiggerThanXT(nValue, _nSeed_)
		return SomeRandomNumbersGreaterThanXT(nValue, _nSeed_)

	#==

	func SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number")
			ok
		ok
	
		_nSome_ = RandomNumberLessThan(floor(_Some() * 10))
		_anResult_ = []
	
		while 1
			_nRandom_ = RandomNumberGreaterThan01XT(_n_, _nSeed_)
			if StzFindFirst(_anResult_, _nRandom_) = 0
				_anResult_ + _nRandom_
	
				if len(_anResult_) = _nSome_
					exit
				ok
			ok
		end
	
		return _anResult_

	func SomeNumbersGreaterThan01XTU(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	func AnyRandomNumbersGreaterThan01XTU(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	func AnyNumbersGreaterThan01XTU(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	#--

	func SomeRandomNumbersBiggerThan01XTU(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	func SomeNumbersBiggerThan01XTU(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	func AnyRandomNumbersBiggerThan01XTU(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	func AnyNumbersBiggerThan01XTU(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	#--

	func SomeUniqueRandomNumbersGreaterThan01XTU(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	func SomeUniqueNumbersGreaterThan01XTU(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	#--

	func SomeUniqueRandomNumbersBiggerThan01XTU(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	func SomeUniqueNumbersBiggerThan01XTU(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	#--

	func RandomNumbersGreaterThan01XTU(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	func RandomNumbersBiggerThan01XTU(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThanXTU(_n_, _nSeed_)

	func UniqueRandomNumbersGreaterThan01XT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	func UniqueRandomNumbersBiggerThan01XT(_n_, _nSeed_)
		return SomeRandomNumbersGreaterThan01XTU(_n_, _nSeed_)

	#>


#==

func NRandomNumbersGreaterThan(_n_, nValue)
	if NOT (isNumber(_n_) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	_anResult_ = []
	for _i_ = 1 to _n_
		_anResult_ + RandomNumberGreaterThan(nValue)
	next

	return _anResult_

	#< @FunctionAlternativeForm

	func NRandomNumbersLargerThan(_n_, nValue)
		return NRandomNumbersGreaterThan(_n_, nValue)

	func NRandomNumbersBiggerThan(_n_, nValue)
		return NRandomNumbersGreaterThan(_n_, nValue)

	func NNumbersGreaterThan(_n_, nValue)
		return NRandomNumbersGreaterThan(_n_, nValue)

	func NNumbersLargerThan(_n_, nValue)
		return NRandomNumbersGreaterThan(_n_, nValue)

	func NNumbersBiggerThan(_n_, nValue)
		return NRandomNumbersGreaterThan(_n_, nValue)


	func AnyNNumbersGreaterThan(_n_, nValue)
		return NRandomNumbersGreaterThan(_n_, nValue)

	func AnyNNumbersLargerThan(_n_, nValue)
		return NRandomNumbersGreaterThan(_n_, nValue)

	func AnyNNumbersBiggerThan(_n_, nValue)
		return NRandomNumbersGreaterThan(_n_, nValue)

	#==

	func NRandomNumbersGreaterThan01(_n_, nValue)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok
	
		_anResult_ = []
	
		for _i_ = 1 to _n_
			_anResult_ + RandomNumberGreaterThan01(nValue)
		next
	
		return _anResult_

	func NRandomNumbersLargerThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01(_n_, nValue)

	func NRandomNumbersBiggerThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01(_n_, nValue)

	func NNumbersGreaterThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01(_n_, nValue)

	func NNumbersLargerThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01(_n_, nValue)

	func NNumbersBiggerThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01(_n_, nValue)

	func AnyNNumbersGreaterThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01(_n_, nValue)

	func AnyNNumbersLargerThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01(_n_, nValue)

	func AnyNNumbersBiggerThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01(_n_, nValue)

	#>

func NRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)
	StzSRandom(_nSeed_)
	return NRandomNumbersGreaterThan(_n_, nValue)

	#< @FunctionAlternativeForm

	func NRandomNumbersLargerThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)

	func NRandomNumbersBiggerThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)

	func NNumbersGreaterThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)

	func NNumbersLargerThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)

	func NNumbersBiggerThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)

	func AnyNNumbersGreaterThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)

	func AnyNNumbersLargerThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)

	func AnyNNumbersBiggerThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)

	#==

	func NRandomNumbersGreaterThan01XT(_n_, nValue, _nSeed_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok
	
		_anResult_ = []
	
		for _i_ = 1 to _n_
			_anResult_ + RandomNumberGreaterThan01XT(nValue, _nSeed_)
		next
	
		return _anResult_

	func NRandomNumbersLargerThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XT(_n_, nValue, _nSeed_)

	func NRandomNumbersBiggerThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XT(_n_, nValue, _nSeed_)

	func NNumbersGreaterThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XT(_n_, nValue, _nSeed_)

	func NNumbersLargerThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XT(_n_, nValue, _nSeed_)

	func NNumbersBiggerThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XT(_n_, nValue, _nSeed_)

	func AnyNNumbersGreaterThan01XT(_n_, nValue)
		return NRandomNumbersGreaterThan01XT(_n_, nValue, _nSeed_)

	func AnyNNumbersLargerThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XT(_n_, nValue, _nSeed_)

	func AnyNNumbersBiggerThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XT(_n_, nValue, _nSeed_)

	#>

func NRandomNumbersGreaterThanU(_n_, nValue)
	if NOT (isNumber(_n_) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	_anResult_ = []

	while 1

		_nRandom_ = ARandomNumberGreaterThan(nValue)

		if StzFindFirst(_anResult_, _nRandom_) = 0
			_anResult_ + _nRandom_
			if len(_anResult_) = _n_
				exit
			ok
		ok

	end

	return _anResult_

	#< @FunctionAlternativeForm

	func NRandomNumbersLargerThanU(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	func NRandomNumbersBiggerThanU(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	func NNumbersGreaterThanU(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	func NNumbersLargerThanU(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	func NNumbersBiggerThanU(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	func AnyNNumbersGreaterThanU(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	func AnyNNumbersLargerThanU(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	func AnyNNumbersBiggerThanU(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	#--

	func NUniqueRandomNumbersGreaterThan(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	func NUniqueRandomNumbersLargerThan(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	func NUniqueRandomNumbersBiggerThan(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	func NUniqueNumbersGreaterThan(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	func NUniqueNumbersLargerThan(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	func NUniqueNumbersBiggerThan(_n_, nValue)
		return NRandomNumbersGreaterThanU(_n_, nValue)

	#==

	func NRandomNumbersGreaterThan01U(_n_, nValue)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_anResult_ = []

		while 1

			_nRandom_ = ARandomNumberGreaterThan01(nValue)

			if StzFindFirst(_anResult_, _nRandom_)
				_anResult_ + _nRandom_
				if len(_anResult_) = _n_
					exit
				ok
			ok
		end

		return _anResult_

	func NRandomNumbersLargerThan01U(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	func NRandomNumbersBiggerThan01U(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	func NNumbersGreaterThan01U(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	func NNumbersLargerThan01U(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	func NNumbersBiggerThan01U(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	func AnyNNumbersGreaterThan01U(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	func AnyNNumbersLargerTha01nU(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	func AnyNNumbersBiggerThan01U(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	#--

	func NUniqueRandomNumbersGreaterThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	func NUniqueRandomNumbersLargerThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	func NUniqueRandomNumbersBiggerThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	func NUniqueNumbersGreaterThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	func NUniqueNumbersLargerThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	func NUniqueNumbersBiggerThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01U(_n_, nValue)

	#>

func NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)
	StzSRandom(_nSeed_)
	return NRandomNumbersGreaterThanU(_n_, nValue)

	#< @FunctionAlternativeForm

	func NRandomNumbersLargerThanXTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)

	func NRandomNumbersBiggerThanXTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)


	func NNumbersGreaterThanXTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)

	func NNumbersLargerThanXTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)

	func NNumbersBiggerThanXTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)


	func AnyNNumbersGreaterThanXTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)

	func AnyNNumbersLargerThanXTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)

	func AnyNNumbersBiggerThanXTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)

	#--

	func NUniqueRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)

	func NUniqueRandomNumbersLargerThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)

	func NUniqueRandomNumbersBiggerThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)

	func NUniqueNumbersGreaterThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)

	func NUniqueNumbersLargerThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)

	func NUniqueNumbersBiggerThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXTU(_n_, nValue, _nSeed_)

	#==

	func NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_anResult_ = []

		while 1

			_nRandom_ = ARandomNumberGreaterThan01XT(nValue, _nSeed_)

			if StzFindFirst(_anResult_, _nRandom_)
				_anResult_ + _nRandom_
				if len(_anResult_) = _n_
					exit
				ok
			ok
		end

		return _anResult_

	func NRandomNumbersLargerThan01XTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	func NRandomNumbersBiggerThan01XTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	func NNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	func NNumbersLargerThan01XTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	func NNumbersBiggerThan01XTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	func AnyNNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	func AnyNNumbersLargerThan01XTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	func AnyNNumbersBiggerThan01XTU(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	#--

	func NUniqueRandomNumbersGreaterThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	func NUniqueRandomNumbersLargerThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	func NUniqueRandomNumbersBiggerThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	func NUniqueNumbersGreaterThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	func NUniqueNumbersLargerThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	func NUniqueNumbersBiggerThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XTU(_n_, nValue, _nSeed_)

	#>

#==

func NRandomNumbersLessThan(_n_, nValue)
	if NOT (isNumber(_n_) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	_anResult_ = []
	for _i_ = 1 to _n_
		_anResult_ + ARandomNumberLessThan(nValue)
	next

	return _anResult_

	#< @FunctionAlternativeForm

	func NRandomNumbersSmallerThan(_n_, nValue)
		return NRandomNumbersGreaterThan(_n_, nValue)


	func NNumbersLessThan(_n_, nValue)
		return NRandomNumbersLessThan(_n_, nValue)

	func NNumbersSmallerThan(_n_, nValue)
		return NRandomNumbersGreaterThan(_n_, nValue)

	func AnyNNumbersLessThan(_n_, nValue)
		return NRandomNumbersLessThan(_n_, nValue)

	func AnyNNumbersSmallerThan(_n_, nValue)
		return NRandomNumbersLessThan(_n_, nValue)

	#==

	func NRandomNumbersLessThan01(_n_, nValue)
		if CheckingParams()
			if NOT isNumber(nValue)
				StzRaise("Incorrect param type! nValue must be a number.")
			ok

			if NOT ( nValue >= 0 and nValue <= 1 )
				StzRaise("Incorrect value! nValue must be a value between 0 and 1.")
			ok
		ok

		_anResult_ = []

		for _i_ = 1 to _n_
			_anResult_ + ARandomNumberLessThan01(nValue)
		next

		return _anResult_

	func NRandomNumbersSmallerThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01(_n_, nValue)


	func NNumbersLessThan01(_n_, nValue)
		return NRandomNumbersLessThan01(_n_, nValue)

	func NNumbersSmallerThan01(_n_, nValue)
		return NRandomNumbersGreaterThan01(_n_, nValue)

	func AnyNNumbersLessThan01(_n_, nValue)
		return NRandomNumbersLessThan01(_n_, nValue)

	func AnyNNumbersSmallerThan01(_n_, nValue)
		return NRandomNumbersLessThan01(_n_, nValue)

	#>

func NRandomNumbersLessThanXT(_n_, nValue, _nSeed_)
	StzSRandom(_nSeed_)
	return NRandomNumbersLessThan(_n_, nValue)

	#< @FunctionAlternativeForm

	func NRandomNumbersSmallerThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)


	func NNumbersLessThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersLessThanXT(_n_, nValue, _nSeed_)

	func NNumbersSmallerThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)

	func AnyNNumbersLessThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersLessThanXT(_n_, nValue, _nSeed_)

	func AnyNNumbersSmallerThanXT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThanXT(_n_, nValue, _nSeed_)

	#==

	func NRandomNumbersLessThan01XT(_n_, nValue, _nSeed_)
		if CheckingParams()
			if NOT isNumber(nValue)
				StzRaise("Incorrect param type! nValue must be a number.")
			ok

			if NOT ( nValue >= 0 and nValue <= 1 )
				StzRaise("Incorrect value! nValue must be a value between 0 and 1.")
			ok
		ok

		_anResult_ = []

		for _i_ = 1 to _n_
			_anResult_ + ARandomNumberLessThan01XT(nValue, _nSeed_)
		next

		return _anResult_

	func NRandomNumbersSmallerThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XT(_n_, nValue, _nSeed_)


	func NNumbersLessThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersLessThan01XT(_n_, nValue, _nSeed_)

	func NNumbersSmallerThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersGreaterThan01XT(_n_, nValue, _nSeed_)

	func AnyNNumbersLessThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersLessThan01XT(_n_, nValue, _nSeed_)

	func AnyNNumbersSmallerThan01XT(_n_, nValue, _nSeed_)
		return NRandomNumbersLessThan01XT(_n_, nValue, _nSeed_)

	#>

func NRandomNumbersLessThanU(_n_, nValue)
	if NOT (isNumber(_n_) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	_anResult_ = []

	while 1

		_nRandom_ = ARandomNumberLessThan(nValue)

		if StzFindFirst(_anResult_, _nRandom_) = 0
			_anResult_ + _nRandom_
			if len(_anResult_) = _n_
				exit
			ok
		ok

	end

	return _anResult_

	#< @FunctionAlternativeForm

	func NNumbersLessThanU(_n_, nValue)
		return NRandomNumbersLessThanU(_n_, nValue)

	func NNumbersSmallerThanU(_n_, nValue)
		return NRandomNumbersLessThanU(_n_, nValue)

	func AnyNNumbersLessThanU(_n_, nValue)
		return NRandomNumbersLessThanU(_n_, nValue)

	func AnyNNumbersSmallerThanU(_n_, nValue)
		return NRandomNumbersLessThanU(_n_, nValue)

	#--

	func NUniqueRandomNumbersLessThan(_n_, nValue)
		return NRandomNumbersLessThanU(_n_, nValue)

	func NUniqueRandomNumbersSmallerThan(_n_, nValue)
		return NRandomNumbersLessThanU(_n_, nValue)


	func NUniqueNumbersLessThan(_n_, nValue)
		return NRandomNumbersLessThanU(_n_, nValue)

	func NUniqueNumbersSmallerThan(_n_, nValue)
		return NRandomNumbersLessThanU(_n_, nValue)

	#==

	func NRandomNumbersLessThan01U(_n_, nValue)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_anResult_ = []

		_i_ = 0
		while 1
			_i_++
			_nRandom_ = ARandomNumberLessthan01(_n_, nValue)

			if StzFindFirst(_anResult_, _nRandom_) = 0
				_anResult_ + _nRandom_
				if len(_anResult_) = _n_ or _i_ = MaxRandomLoop()
					exit
				ok
			ok

		end

		if len(_anResult_) = _n_
			return _anResult_
		else
			StzRaise("Can't proceed. No random number generated after " + MaxRandomLoop() + " trials.")
		ok

	func NNumbersLessThan01U(_n_, nValue)
		return NRandomNumbersLessThan01U(_n_, nValue)

	func NNumbersSmallerThan01U(_n_, nValue)
		return NRandomNumbersLessThan01U(_n_, nValue)

	func AnyNNumbersLessThan01U(_n_, nValue)
		return NRandomNumbersLessThan01U(_n_, nValue)

	func AnyNNumbersSmallerThan01U(_n_, nValue)
		return NRandomNumbersLessThan01U(_n_, nValue)

	#--

	func NUniqueRandomNumbersLessThan01(_n_, nValue)
		return NRandomNumbersLessThan01U(_n_, nValue)

	func NUniqueRandomNumbersSmallerThan01(_n_, nValue)
		return NRandomNumbersLessThan01U(_n_, nValue)


	func NUniqueNumbersLessThan01(_n_, nValue)
		return NRandomNumbersLessThan01U(_n_, nValue)

	func NUniqueNumbersSmallerThan01(_n_, nValue)
		return NRandomNumbersLessThan01U(_n_, nValue)

	#>

func NRandomNumbersLessThanXTU(_n_, nValue, _nSeed_)
	StzSRandom(_nSeed_)
	return NRandomNumbersLessThanU(_n_, nValue)

	#< @FunctionAlternativeForm

	func NNumbersLessThanXTU(_n_, nValue)
		return NRandomNumbersLessThanXTU(_n_, nValue)

	func NNumbersSmallerThanXTU(_n_, nValue)
		return NRandomNumbersLessThanXTU(_n_, nValue)

	func AnyNNumbersLessThanXTU(_n_, nValue)
		return NRandomNumbersLessThanXTU(_n_, nValue)

	func AnyNNumbersSmallerThanXTU(_n_, nValue)
		return NRandomNumbersLessThanXTU(_n_, nValue)

	#--

	func NUniqueRandomNumbersLessThanXT(_n_, nValue)
		return NRandomNumbersLessThanXTU(_n_, nValue)

	func NUniqueRandomNumbersSmallerThanXT(_n_, nValue)
		return NRandomNumbersLessThanXTU(_n_, nValue)


	func NUniqueNumbersLessThanXT(_n_, nValue)
		return NRandomNumbersLessThanXTU(_n_, nValue)

	func NUniqueNumbersSmallerThanXT(_n_, nValue)
		return NRandomNumbersLessThanXTU(_n_, nValue)

	#==

	func NRandomNumbersLessThanXT01U(_n_, nValue, _nSeed_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_anResult_ = []

		_i_ = 0
		while 1
			_i_++
			_nRandom_ = ARandomNumberLessthanXT01(_n_, nValue, _nSeed_)

			if StzFindFirst(_anResult_, _nRandom_) = 0
				_anResult_ + _nRandom_
				if len(_anResult_) = _n_ or _i_ = MaxRandomLoop()
					exit
				ok
			ok

		end

		if len(_anResult_) = _n_
			return _anResult_
		else
			StzRaise("Can't proceed. No random number generated after " + MaxRandomLoop() + " trials.")
		ok

	func NNumbersLessThanXT01U(_n_, nValue, _nSeed_)
		return NRandomNumbersLessThan01U(_n_, nValue)

	func NNumbersSmallerThanXT01U(_n_, nValue, _nSeed_)
		return NRandomNumbersLessThanXT01U(_n_, nValue, _nSeed_)

	func AnyNNumbersLessThanXT01U(_n_, nValue, _nSeed_)
		return NRandomNumbersLessThanXT01U(_n_, nValue, _nSeed_)

	func AnyNNumbersSmallerThanXT01U(_n_, nValue, _nSeed_)
		return NRandomNumbersLessThanXT01U(_n_, nValue, _nSeed_)

	#--

	func NUniqueRandomNumbersLessThanXT01(_n_, nValue, _nSeed_)
		return NRandomNumbersLessThanXT01U(_n_, nValue, _nSeed_)

	func NUniqueRandomNumbersSmallerThanXT01(_n_, nValue, _nSeed_)
		return NRandomNumbersLessThanXT01U(_n_, nValue, _nSeed_)


	func NUniqueNumbersLessThanXT01(_n_, nValue, _nSeed_)
		return NRandomNumbersLessThanXT01U(_n_, nValue, _nSeed_)

	func NUniqueNumbersSmallerThanXT01(_n_, nValue, _nSeed_)
		return NRandomNumbersLessThanXT01U(_n_, nValue, _nSeed_)

	#>

#== A RANDOM NUMBER AMONG THE NUMBERS IN A LIST

func RandomNumberIn(panNumbers)
	if NOT isList(panNumbers)
		StzRaise("Incorrect param type! panNumbers must be a list.")
	ok

	_nLen_ = len(panNumbers)
	_anNumbers_ = []
	for _i_ = 1 to _nLen_
		if isNumber(panNumbers[_i_])
			_anNumbers_ + panNumbers[_i_]
		ok
	next

	_nLen_ = len(_anNumbers_)
	if _nLen_ = 0
		StzRaise("No valid numbers found in the list!")
	ok

	_nPos_ = StzEngineRandomInt(1, _nLen_)
	_nResult_ = _anNumbers_[_nPos_]
	return _nResult_

	#< @FunctionAlternativeForms

	func ARandomNumberIn(panNumbers)
		return RandomNumberIn(panNumbers)

	func ANumberIn(panNumbers)
		return RandomNumberIn(panNumbers)

	func AnyNumberIn(panNumbers)
		return RandomNumberIn(panNumbers)

	func AnyRandomNumberIn(panNumbers)
		return RandomNumberIn(panNumbers)

	#==

	func RandomNumberFrom(panNumbers)
		return RandomNumberIn(panNumbers)

	func ARandomNumberFrom(panNumbers)
		return RandomNumberIn(panNumbers)

	func ANumberFrom(panNumbers)
		return RandomNumberIn(panNumbers)

	func AnyNumberFrom(panNumbers)
		return RandomNumberIn(panNumbers)

	func AnyRandomNumberFrom(panNumbers)
		return RandomNumberIn(panNumbers)

	#==

	func RandomNumberBetween(_nMin_, _nMax_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok
	
		if _nMin_ = _nMax_
			return _nMin_
		ok
	
		# Ensure nMin is actually the minimum
		if _nMin_ > _nMax_
			_nTemp_ = _nMin_
			_nMin_ = _nMax_
			_nMax_ = _nTemp_
		ok
	
		if BothAreIntegers(_nMin_, _nMax_)
			return StzEngineRandomInt(_nMin_, _nMax_)
		else
			return StzEngineRandomFloat(_nMin_, _nMax_)
		ok


	func ARandomNumberBetween(_nMin_, _nMax_)
		return RandomNumberBetween(_nMin_, _nMax_)

	func ANumberBetween(_nMin_, _nMax_)
		return RandomNumberBetween(_nMin_, _nMax_)

	func AnyNumberBetween(_nMin_, _nMax_)
		return RandomNumberBetween(_nMin_, _nMax_)

	func AnyRandomNumberBetween(_nMin_, _nMax_)
		return RandomNumberBetween(_nMin_, _nMax_)

	#>

#--

func RandomNumberInZ(panNumbers)
	if NOT isList(panNumbers)
		StzRaise("Incorrect param type! panNumbers must be a list.")
	ok

	_nLen_ = len(panNumbers)
	_anNumbers_ = []

	for _i_ = 1 to _nLen_
		if isNumber(panNumbers[_i_])
			_anNumbers_ + panNumbers[_i_]
		ok
	next

	_nLen_ = len(_anNumbers_)
	if _nLen_ = 0
		return [0, 0]
	ok

	_nPos_ = StzEngineRandomInt(1, _nLen_)
	_aResult_ = [ _anNumbers_[_nPos_], _nPos_ ]

	return _aResult_

	#< @FunctionAlternativeForms

	func ARandomNumberInZ(panNumbers)
		return RandomNumberInZ(panNumbers)

	func ANumberInZ(panNumbers)
		return RandomNumberInZ(panNumbers)

	func AnyNumberInZ(panNumbers)
		return RandomNumberInZ(panNumbers)

	func AnyRandomNumberInZ(panNumbers)
		return RandomNumberIn(panNumbers)

	#==

	func RandomNumberFromZ(panNumbers)
		return RandomNumberInZ(panNumbers)

	func ARandomNumberFromZ(panNumbers)
		return RandomNumberInZ(panNumbers)

	func ANumberFromZ(panNumbers)
		return RandomNumberInZ(panNumbers)

	func AnyNumberFromZ(panNumbers)
		return RandomNumberInZ(panNumbers)

	func AnyRandomNumberFromZ(panNumbers)
		return RandomNumberIn(panNumbers)

	#==

	func RandomNumberBetweenZ(_nMin_, _nMax_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return RandomNumberInZ(_nMin_:nMax)

	func ARandomNumberBetweenZ(_nMin_, _nMax_)
		return RandomNumberBetweenZ(_nMin_, _nMax_)

	func ANumberBetweenZ(_nMin_, _nMax_)
		return RandomNumberBetweenZ(_nMin_, _nMax_)

	func AnyNumberBetweenZ(_nMin_, _nMax_)
		return RandomNumberBetweenZ(_nMin_, _nMax_)

	func AnyRandomNumberBetweenZ(_nMin_, _nMax_)
		return RandomNumberBetweenZ(_nMin_, _nMax_)

	#>

#==

func RandomNumberInXT(panNumbers, _nSeed_)
	StzSRandom(_nSeed_)
	_nResult_ = StzRandomNumberIn(panNumbers)

	return _nResult_

	#< @FunctionAlternativeForms

	func ARandomNumberInXT(panNumbers, _nSeed_)
		return RandomNumberInXT(panNumbers, _nSeed_)

	func ANumberInXT(panNumbers, _nSeed_)
		return RandomNumberInXt(panNumbers, _nSeed_)

	func AnyNumberInXT(panNumbers, _nSeed_)
		return RandomNumberInXT(panNumbers, _nSeed_)

	func AnyRandomNumberInXT(panNumbers, _nSeed_)
		return RandomNumberInXT(panNumbers, _nSeed_)

	#==

	func RandomNumberFromXT(panNumbers, _nSeed_)
		return RandomNumberInXT(panNumbers, _nSeed_)

	func ARandomNumberFromXT(panNumbers, _nSeed_)
		return RandomNumberInXT(panNumbers, _nSeed_)

	func ANumberFromXT(panNumbers, _nSeed_)
		return RandomNumberInXt(panNumbers, _nSeed_)

	func AnyNumberFromXT(panNumbers, _nSeed_)
		return RandomNumberInXT(panNumbers, _nSeed_)

	func AnyRandomNumberFromXT(panNumbers, _nSeed_)
		return RandomNumberInXT(panNumbers, _nSeed_)

	#==

	func RandomNumberBetweenXT(_nMin_, _nMax_, _nSeed_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumberInXT(_nMin_:nMax, _nSeed_)

	func ARandomNumberBetweenXT(_nMin_, _nMax_, _nSeed_)
		return RandomNumberBetweenXT(_nMin_, _nMax_, _nSeed_)

	func ANumberBetweenXT(_nMin_, _nMax_, _nSeed_)
		return RandomNumberBetweenXT(_nMin_, _nMax_, _nSeed_)

	func AnyNumberBetweenXT(_nMin_, _nMax_, _nSeed_)
		return RandomNumberBetweenXT(_nMin_, _nMax_, _nSeed_)

	func AnyRandomNumberBetweenXT(_nMin_, _nMax_, _nSeed_)
		return RandomNumberBetweenXT(_nMin_, _nMax_, _nSeed_)

	#>

func RandomNumberInXTZ(panNumbers, _nSeed_)
	if CheckingParams()

		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers must be a list of numbers.")
		ok

	ok

	StzSRandom(_nSeed_)
	_nPos_ = ARandomNumberIn(1:len(panNumbers))
	_aResult_ = [ panNumbers[_nPos_], _nPos_ ]
	return _aResult_

	#< @FunctionAlternativeForms

	func ARandomNumberInXTZ(panNumbers, _nSeed_)
		return RandomNumberInXTZ(panNumbers, _nSeed_)

	func ANumberInXTZ(panNumbers, _nSeed_)
		return RandomNumberInXTZ(panNumbers, _nSeed_)

	func AnyNumberInXTZ(panNumbers, _nSeed_)
		return RandomNumberInXTZ(panNumbers, _nSeed_)

	func AnyRandomNumberInXTZ(panNumbers, _nSeed_)
		return RandomNumberInXTZ(panNumbers, _nSeed_)

	#==

	func RandomNumberFromXTZ(panNumbers, _nSeed_)
		return RandomNumberInXTZ(panNumbers, _nSeed_)

	func ARandomNumberFromXTZ(panNumbers, _nSeed_)
		return RandomNumberInXTZ(panNumbers, _nSeed_)

	func ANumberFromXTZ(panNumbers, _nSeed_)
		return RandomNumberInXTZ(panNumbers, _nSeed_)

	func AnyNumberFromXTZ(panNumbers, _nSeed_)
		return RandomNumberInXTZ(panNumbers, _nSeed_)

	func AnyRandomNumberFromXTZ(panNumbers, _nSeed_)
		return RandomNumberInXTZ(panNumbers, _nSeed_)

	#==

	func RandomNumberBetweenXTZ(_nMin_, _nMax_, _nSeed_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumberInXTZ(_nMin_:nMax, _nSeed_)

	func ARandomNumberBetweenXTZ(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumberBetweenXTZ(_nMin_, _nMax_, _nSeed_)

	func ANumberBetweenXTZ(_nMin_, _nMax_, _nSeed_)
		return ARandomNumberBetweenXTZ(_nMin_, _nMax_, _nSeed_)

	func AnyNumberBetweenXTZ(_nMin_, _nMax_, _nSeed_)
		return ARandomNumberBetweenXTZ(_nMin_, _nMax_, _nSeed_)

	func AnyRandomNumberBetweenXTZ(_nMin_, _nMax_, _nSeed_)
		return ARandomNumberBetweenXTZ(_nMin_, _nMax_, _nSeed_)

	#>

#==

func SomeRandomNumbersIn(panNumbers)
	if CheckingParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	_n_ = floor( _Some() * len(panNumbers) )
	return NRandomNumbersIn(_n_, panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersIn(panNumbers)
		return SomeRandomNumbersIn(panNumbers)

	func AnyRandomNumbersIn(panNumbers)
		return SomeRandomNumbersIn(panNumbers)

	func AnyNumbersIn(panNumbers)
		return SomeRandomNumbersIn(panNumbers)

	#--

	func RandomNumbersIn(panNumbers)
		return SomeRandomNumbersIn(panNumbers)

	#==

	func SomeNumbersFrom(panNumbers)
		return SomeRandomNumbersIn(panNumbers)

	func AnyRandomNumbersFrom(panNumbers)
		return SomeRandomNumbersIn(panNumbers)

	func AnyNumbersFrom(panNumbers)
		return SomeRandomNumbersIn(panNumbers)

	#--

	func RandomNumbersFrom(panNumbers)
		return SomeRandomNumbersIn(panNumbers)

	#==

	func SomeRandomNumbersBetween(_nMin_, _nMax_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersIn(_nMin_ : _nMax_)

	func SomeNumbersBetween(_nMin_, _nMax_)
		return SomeRandomNumbersBetween(_nMin_, _nMax_)

	func AnyRandomNumbersBetween(_nMin_, _nMax_)
		return SomeRandomNumbersBetween(_nMin_, _nMax_)

	func AnyNumbersBetween(_nMin_, _nMax_)
		return SomeRandomNumbersBetween(_nMin_, _nMax_)

	#--

	func RandomNumbersBetween(_nMin_, _nMax_)
		return SomeRandomNumbersBetween(_nMin_, _nMax_)

	#>

func SomeRandomNumbersInZ(panNumbers)
	if CheckingParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	_n_ = floor( _Some() * len(panNumbers) )
	return NRandomNumbersInZ(_n_, panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInZ(panNumbers)
		return RandomNumbersInZ(panNumbers)

	func AnyRandomNumbersInZ(panNumbers)
		return RandomNumbersInZ(panNumbers)

	func AnyNumbersInZ(panNumbers)
		return RandomNumbersInZ(panNumbers)

	#--

	func RandomNumbersInZ(panNumbers)
		return RandomNumbersInZ(panNumbers)

	#==

	func SomeNumbersFromZ(panNumbers)
		return RandomNumbersInZ(panNumbers)

	func AnyRandomNumbersFromZ(panNumbers)
		return RandomNumbersInZ(panNumbers)

	func AnyNumbersFromZ(panNumbers)
		return RandomNumbersInZ(panNumbers)

	#--

	func RandomNumbersFromZ(panNumbers)
		return RandomNumbersInZ(panNumbers)

	#==

	func SomeRandomNumbersBetweenZ(_nMin_, _nMax_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersInZ(_nMin_ : _nMax_)

	func SomeNumbersBetweenZ(_nMin_, _nMax_)
		return RandomNumbersBetweenZ(_nMin_, _nMax_)

	func AnyRandomNumbersBetweenZ(_nMin_, _nMax_)
		return RandomNumbersBetweenZ(_nMin_, _nMax_)

	func AnyNumbersBetweenZ(_nMin_, _nMax_)
		return RandomNumbersBetweenZ(_nMin_, _nMax_)

	#--

	func RandomNumbersBetweenZ(_nMin_, _nMax_)
		return RandomNumbersBetweenZ(_nMin_, _nMax_)

	#>

#==

func SomeRandomNumbersInXT(panNumbers, _nSeed_)
	StzSRandom(_nSeed_)
	return SomeRandomNumbersIn(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXT(panNumbers, _nSeed_)
		return SomeRandomNumbersInXT(panNumbers, _nSeed_)

	func AnyRandomNumbersInXT(panNumbers, _nSeed_)
		return SomeRandomNumbersInXT(panNumbers, _nSeed_)

	func AnyNumbersInXT(panNumbers, _nSeed_)
		return SomeRandomNumbersInXT(panNumbers, _nSeed_)

	#--

	func RandomNumbersInXT(panNumbers, _nSeed_)
		return SomeRandomNumbersInXT(panNumbers, _nSeed_)

	#==

	func SomeNumbersFromXT(panNumbers, _nSeed_)
		return SomeRandomNumbersInXT(panNumbers, _nSeed_)

	func AnyRandomNumbersFromXT(panNumbers, _nSeed_)
		return SomeRandomNumbersInXT(panNumbers, _nSeed_)

	func AnyNumbersFromXT(panNumbers, _nSeed_)
		return SomeRandomNumbersInXT(panNumbers, _nSeed_)

	#--

	func RandomNumbersFromXT(panNumbers, _nSeed_)
		return SomeRandomNumbersInXT(panNumbers, _nSeed_)

	#==

	func SomeRandomNumbersBetweenXT(_nMin_, _nMax_, _nSeed_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersInXT(_nMin_ : _nMax_, _nSeed_)

	func SomeNumbersBetweenXT(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBetweenXT(_nMin_, _nMax_, _nSeed_)

	func AnyRandomNumbersBetweenXT(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBetweenXT(_nMin_, _nMax_, _nSeed_)

	func AnyNumbersBetweenXT(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBetweenXT(_nMin_, _nMax_, _nSeed_)

	#--

	func RandomNumbersBetweenXT(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBetweenXT(_nMin_, _nMax_, _nSeed_)

	#>

func SomeRandomNumbersInXTZ(panNumbers, _nSeed_)
	StzSRandom(_nSeed_)
	return SomeRandomNumbersInZ(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXTZ(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTZ(panNumbers, _nSeed_)

	func AnyRandomNumbersInXTZ(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTZ(panNumbers, _nSeed_)

	func AnyNumbersInXTZ(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTZ(panNumbers, _nSeed_)

	#--

	func RandomNumbersInXTZ(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTZ(panNumbers, _nSeed_)

	#==

	func SomeNumbersFromXTZ(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTZ(panNumbers, _nSeed_)

	func AnyRandomNumbersFromXTZ(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTZ(panNumbers, _nSeed_)

	func AnyNumbersFromXTZ(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTZ(panNumbers, _nSeed_)

	#--

	func RandomNumbersFromXTZ(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTZ(panNumbers, _nSeed_)

	#==

	func SomeRandomNumbersBetweenXTZ(_nMin_, _nMax_, _nSeed_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersInXTZ(_nMin_ : _nMax_, _nSeed_)

	func SomeNumbersBetweenXTZ(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBetweenXTZ(_nMin_, _nMax_, _nSeed_)

	func AnyRandomNumbersBetweenXTZ(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBetweenXTZ(_nMin_, _nMax_, _nSeed_)

	func AnyNumbersBetweenXTZ(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBetweenXTZ(_nMin_, _nMax_, _nSeed_)

	#--

	func RandomNumbersBetweenXTZ(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBteweenXTZ(_nMin_, _nMax_, _nSeed_)

	#>

#==

func SomeRandomNumbersInU(panNumbers)
	if CheckingParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	_n_ = floor( len(panNumbers) * _Some() )
	return NRandomNumbersInU(_n_, panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInU(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	func AnyRandomNumbersInU(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	func AnyNumbersInU(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	#--

	func UniqueRandomNumbersIn(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	func SomeUniqueNumbersIn(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	#--

	func RandomNumbersInU(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	#==

	func SomeNumbersFromU(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	func AnyRandomNumbersFromU(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	func AnyNumbersFromU(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	#--

	func UniqueRandomNumbersFrom(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	func SomeUniqueNumbersFrom(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	#--

	func RandomNumbersFromU(panNumbers)
		return SomeRandomNumbersInU(panNumbers)

	#==

	func SomeRandomNumbersBetweenU(_nMin_, _nMax_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok
		return SomeRandomNumbersInU(_nMin_ : _nMax_)

	func SomeNumbersBetweenU(_nMin_, _nMax_)
		return SomeRandomNumbersBetweenU(_nMin_, _nMax_)

	func AnyRandomNumbersBetweenU(_nMin_, _nMax_)
		return SomeRandomNumbersBetweenU(_nMin_, _nMax_)

	func AnyNumbersBetweenU(_nMin_, _nMax_)
		return SomeRandomNumbersBetweenU(_nMin_, _nMax_)

	#--

	func UniqueRandomNumbersBetween(_nMin_, _nMax_)
		return SomeRandomNumbersBetweenU(_nMin_, _nMax_)

	func SomeUniqueNumbersBetween(_nMin_, _nMax_)
		return SomeRandomNumbersBetweenU(_nMin_, _nMax_)

	#--

	func RandomNumbersBetweenU(_nMin_, _nMax_)
		return SomeRandomNumbersBetweenU(_nMin_, _nMax_)

	#>

func SomeRandomNumbersInUZ(panNumbers)
	if CheckingParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	_n_ = floor( _Some() * len(panNumbers) )
	return NRandomNumbersInUZ(_n_, panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInUZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	func AnyRandomNumbersInUZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	func AnyNumbersInUZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	#--

	func UniqueRandomNumbersInZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	func SomeUniqueNumbersInZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	#--

	func RandomNumbersInUZ(_nMin_, _nMax_)
		return SomeRandomNumbersInUZ(panNumbers)

	#==

	func SomeNumbersFromUZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	func AnyRandomNumbersFromUZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	func AnyNumbersFromUZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	#--

	func UniqueRandomNumbersFromZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	func SomeUniqueNumbersFromZ(panNumbers)
		return SomeRandomNumbersInUZ(panNumbers)

	#--

	func RandomNumbersFromUZ(_nMin_, _nMax_)
		return SomeRandomNumbersInUZ(panNumbers)

	#==

	func SomeRandomNumbersBetweenUZ(_nMin_, _nMax_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok
		return SomeRandomNumbersInUZ(_nMin_ : _nMax_)

	func SomeNumbersBetweenUZ(_nMin_, _nMax_)
		return SomeRandomNumbersBetweenUZ(_nMin_, _nMax_)

	func AnyRandomNumbersBetweenUZ(_nMin_, _nMax_)
		return SomeRandomNumbersBetweenUZ(_nMin_, _nMax_)

	func AnyNumbersBetweenUZ(_nMin_, _nMax_)
		return SomeRandomNumbersBetweenUZ(_nMin_, _nMax_)

	#--

	func UniqueRandomNumbersBetweenZ(_nMin_, _nMax_)
		return SomeRandomNumbersBetweenUZ(_nMin_, _nMax_)

	func SomeUniqueNumbersBetweenZ(_nMin_, _nMax_)
		return SomeRandomNumbersBetweenUZ(_nMin_, _nMax_)

	#--

	func RandomNumbersBetweenUZ(_nMin_, _nMax_)
		return SomeRandomNumbersBetweenUZ(_nMin_, _nMax_)

	#>

#==

func SomeRandomNumbersInXTU(panNumbers, _nSeed_)
	StzSRandom(_nSeed_)
	return SomeRandomNumbersInU(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXTU(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTU(panNumbers, _nSeed_)

	func AnyRandomNumbersInXTU(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTU(panNumbers, _nSeed_)

	func AnyNumbersInXTU(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTU(panNumbers, _nSeed_)

	#--

	func UniqueRandomNumbersInXT(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTU(panNumbers, _nSeed_)

	func SomeUniqueNumbersInXT(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTU(panNumbers, _nSeed_)

	#--

	func RandomNumbersInXTU(panNumbers, _nSeed_)
		return SomeRandomNumbersInXTU(panNumbers, _nSeed_)

	#==

	func SomeRandomNumbersBetweenXTU(_nMin_, _nMax_, _nSeed_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersInXTU(_nMin_ : _nMax_)

	func SomeNumbersBetweenXTU(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBetweenXTU(_nMin_, _nMax_, _nSeed_)

	func AnyRandomNumbersBetweenXTU(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBetweenXTU(_nMin_, _nMax_, _nSeed_)

	func AnyNumbersBetweenXTU(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBetweenXTU(_nMin_, _nMax_, _nSeed_)

	#--

	func UniqueRandomNumbersBetweenXT(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBetweenXTU(_nMin_, _nMax_, _nSeed_)

	func SomeUniqueNumbersBetweenXT(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBetweenXTU(_nMin_, _nMax_, _nSeed_)

	#--

	func RandomNumbersBetweenXTU(_nMin_, _nMax_, _nSeed_)
		return SomeRandomNumbersBetweenXTU(panNumbers, _nSeed_)

	#>

func SomeRandomNumbersInXTUZ(panNumbers, _nSeed_)
	StzSRandom(_nSeed_)
	return SomeRandomNumbersInUZ(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXTUZ(panNumbers, _nSeed_)
		return RandomNumbersInXTUZ(panNumbers, _nSeed_)

	func AnyRandomNumbersInXTUZ(panNumbers, _nSeed_)
		return RandomNumbersInXTUZ(panNumbers, _nSeed_)

	func AnyNumbersInXTUZ(panNumbers, _nSeed_)
		return RandomNumbersInXTUZ(panNumbers, _nSeed_)

	#--

	func UniqueRandomNumbersInXTZ(panNumbers, _nSeed_)
		return RandomNumbersInXTUZ(panNumbers, _nSeed_)

	func SomeUniqueNumbersInXTZ(panNumbers, _nSeed_)
		return RandomNumbersInXTUZ(panNumbers, _nSeed_)

	#--

	func RandomNumbersInXTUZ(panNumbers, _nSeed_)
		return RandomNumbersInXTUZ(panNumbers, _nSeed_)

	#==

	func RandomNumbersFromXTUZ(panNumbers, _nSeed_)
		return RandomNumbersInXTUZ(panNumbers, _nSeed_)

	func SomeNumbersFromXTUZ(panNumbers, _nSeed_)
		return RandomNumbersInXTUZ(panNumbers, _nSeed_)

	func AnyRandomNumbersFromXTUZ(panNumbers, _nSeed_)
		return RandomNumbersInXTUZ(panNumbers, _nSeed_)

	func AnyNumbersFromXTUZ(panNumbers, _nSeed_)
		return RandomNumbersInXTUZ(panNumbers, _nSeed_)

	#--

	func UniqueRandomNumbersFromXTZ(panNumbers, _nSeed_)
		return RandomNumbersInXTUZ(panNumbers, _nSeed_)

	func SomeUniqueNumbersFromXTZ(panNumbers, _nSeed_)
		return RandomNumbersInXTUZ(panNumbers, _nSeed_)

	#==

	func SomeRandomNumbersBetweenXTUZ(_nMin_, _nMax_, _nSeed_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return RandomNumbersInXTUZ(_nMin_ : _nMax_)

	func SomeNumbersBetweenXTUZ(_nMin_, _nMax_, _nSeed_)
		return RandomNumbersBetweenXTUZ(_nMin_, _nMax_, _nSeed_)

	func AnyRandomNumbersBetweenXTUZ(_nMin_, _nMax_, _nSeed_)
		return RandomNumbersBetweenXTUZ(_nMin_, _nMax_, _nSeed_)

	func AnyNumbersBetweenXTUZ(_nMin_, _nMax_, _nSeed_)
		return RandomNumbersBetweenXTUZ(_nMin_, _nMax_, _nSeed_)

	#--

	func UniqueRandomNumbersBetweenXTZ(_nMin_, _nMax_, _nSeed_)
		return RandomNumbersBetweenXTUZ(_nMin_, _nMax_, _nSeed_)

	func SomeUniqueNumbersBetweenXTZ(_nMin_, _nMax_, _nSeed_)
		return RandomNumbersBetweenXTUZ(_nMin_, _nMax_, _nSeed_)

	#--

	func RandomNumbersBetweenXTUZ(_nMin_, _nMax_, _nSeed_)
		return RandomNumbersBetweenXTUZ(_nMin_, _nMax_, _nSeed_)

	#>

#== N RANDOM NUMBERS FROM A LIST OF NUMBERS

func NRandomNumbersIn(_n_, panNumbers)

	#NOTE: The same number can appear more than once
	# To avoid this, use the function with the ...U() extension

	_nLen_ = len(panNumbers)

	_anResult_ = []

	while 1
		_nPos_ = ARandomNumberIn(1 : _nLen_)
		_anResult_ + panNumbers[_nPos_]
		if len(_anResult_) = _n_
			exit
		ok
	end

	return _anResult_

	#< @FunctionAlternativeForms

	func RandomNNumbersIn(_n_, panNumbers)
		return NRandomNumbersIn(_n_, panNumbers)

	func AnyNNumbersIn(_n_, panNumbers)
		return NRandomNumbersIn(_n_, panNumbers)

	func NNumbersIn(_n_, panNumbers)
		return NRandomNumbersIn(_n_, panNumbers)

	#==

	func NRandomNumbersFrom(_n_, panNumbers)
		return NRandomNumbersIn(_n_, panNumbers)

	func RandomNNumbersFrom(_n_, panNumbers)
		return NRandomNumbersIn(_n_, panNumbers)

	func AnyNNumbersFrom(_n_, panNumbers)
		return NRandomNumbersIn(_n_, panNumbers)

	func NNumbersFrom(_n_, panNumbers)
		return NRandomNumbersIn(_n_, panNumbers)

	#==

	func NRandomNumbersBetween(_n_, _nMin_, _nMax_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersIn(_n_, _nMin_:nMax)

	func RandomNNumbersBetween(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetween(_n_, _nMin_, _nMax_)

	func AnyNNumbersBetween(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetween(_n_, _nMin_, _nMax_)

	func NNumbersBetween(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetween(_n_, _nMin_, _nMax_)

	#>

func NRandomNumbersInZ(_n_, panNumbers)

	_nLen_ = len(panNumbers)
	_nRandom_ = ARandomNumberIn(1 : _nLen_)

	_anNumbers_ = []
	_anPos_ = []

	while 1
		_nPos_ = ARandomNumberIn(1 : _nLen_)
		_anNumbers_ + panNumbers[_nPos_]
		_anPos_ + _nPos_
		if len(_anNumbers_) = _n_
			exit
		ok
	end

	_aResult_ = Association([ _anNumbers_, _anPos_ ])

	return _aResult_

	#< @FunctionAlternativeForms

	func RandomNNumbersInZ(_n_, panNumbers)
		return NRandomNumbersInZ(_n_, panNumbers)

	func AnyNNumbersInZ(_n_, panNumbers)
		return NRandomNumbersInZ(_n_, panNumbers)

	func NNumbersInZ(_n_, panNumbers)
		return NRandomNumbersInZ(_n_, panNumbers)

	#==

	func NRandomNumbersFromZ(_n_, panNumbers)
		return NRandomNumbersInZ(_n_, panNumbers)

	func RandomNNumbersFromZ(_n_, panNumbers)
		return NRandomNumbersInZ(_n_, panNumbers)

	func AnyNNumbersFromZ(_n_, panNumbers)
		return NRandomNumbersInZ(_n_, panNumbers)

	func NNumbersFromZ(_n_, panNumbers)
		return NRandomNumbersInZ(_n_, panNumbers)

	#==

	func NRandomNumbersBetweenZ(_n_, _nMin_, _nMax_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInZ(_n_, _nMin_:nMax)

	func RandomNNumbersBetweenZ(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenZ(_n_, _nMin_, _nMax_)

	func AnyNNumbersBetweenZ(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenZ(_n_, _nMin_, _nMax_)

	func NNumbersBetweenZ(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenZ(_n_, _nMin_, _nMax_)

	#>

#--

func NRandomNumbersInXT(_n_, panNumbers, _nSeed_)
	StzSRandom(_nSeed_)
	return NRandomNumbersIn(_n_, panNumbers)

	#< @FunctionAlternativeForms

	func RandomNNumbersInXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXT(_n_, panNumbers, _nSeed_)

	func AnyNNumbersInXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXT(_n_, panNumbers, _nSeed_)

	func NNumbersInXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXT(_n_, panNumbers, _nSeed_)

	#==

	func NRandomNumbersFromXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXT(_n_, panNumbers, _nSeed_)

	func RandomNNumbersFromXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXT(_n_, panNumbers, _nSeed_)

	func AnyNNumbersFromXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXT(_n_, panNumbers, _nSeed_)

	func NNumbersFromXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXT(_n_, panNumbers, _nSeed_)

	#==

	func NRandomNumbersBetweenXT(_n_, _nMin_, _nMax_, _nSeed_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInXT(_n_, _nMin_:nMax, _nSeed_)

	func RandomNNumbersBetwwenXT(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXT(_n_, _nMin_, _nMax_, _nSeed_)

	func AnyNNumbersBetweenXT(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXT(_n_, _nMin_, _nMax_, _nSeed_)

	func NNumbersBetweenXT(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXT(_n_, _nMin_, _nMax_, _nSeed_)

	#>

func NRandomNumbersInXTZ(_n_, panNumbers, _nSeed_)
	StzSRandom(_nSeed_)
	return NRandomNumbersInZ(_n_, panNumbers)

	#< @FunctionAlternativeForms

	func RandomNNumbersInXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTZ(_n_, panNumbers, _nSeed_)

	func AnyNNumbersInXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTZ(_n_, panNumbers, _nSeed_)

	func NNumbersInXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTZ(_n_, panNumbers, _nSeed_)

	#==

	func NRandomNumbersFromXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTZ(_n_, panNumbers, _nSeed_)

	func RandomNNumbersFromXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTZ(_n_, panNumbers, _nSeed_)

	func AnyNNumbersFromXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTZ(_n_, panNumbers, _nSeed_)

	func NNumbersFromXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTZ(_n_, panNumbers, _nSeed_)

	#==

	func NRandomNumbersBetweenXTZ(_n_, _nMin_, _nMax_, _nSeed_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInXTZ(_n_, _nMin_:nMax, _nSeed_)

	func RandomNNumbersBetweenXTZ(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTZ(_n_, _nMin_, _nMax_, _nSeed_)

	func AnyNNumbersBetweenXTZ(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTZ(_n_, _nMin_, _nMax_, _nSeed_)

	func NNumbersBetweenXTZ(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTZ(_n_, _nMin_, _nMax_, _nSeed_)

	#>

#==

func NRandomNumbersInU(_n_, panNumbers)

	#NOTE: The generated numbers are guranteed to be unique

	_anResult_ = []

	while 1

		_nRandom_ = ARandomNumberIn(panNumbers)
		
		if StzFindFirst(_anResult_, _nRandom_) = 0
			_anResult_ + _nRandom_

			if len(_anResult_) = _n_
				exit
			ok
		ok
	end

	return _anResult_

	#< @FunctionAlternativeForms

	func RandomNNumbersInU(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	func AnyNNumbersInU(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	func NNumbersInU(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	#--

	func NUniqueRandomNumbersIn(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	func UniqueNRandomNumbersIn(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	func NUniqueNumbersIn(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	func UniqueNNumbersIn(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	#==

	func RandomNNumbersFromU(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	func AnyNNumbersFromU(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	func NNumbersFromU(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	#--

	func NRandomNumbersFromU(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	func NUniqueRandomNumbersFrom(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	func UniqueNRandomNumbersFrom(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	func NUniqueNumbersFrom(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	func UniqueNNumbersFrom(_n_, panNumbers)
		return NRandomNumbersInU(_n_, panNumbers)

	#==

	func NRandomNumbersBetweenU(_n_, _nMin_, _nMax_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInU(_n_, _nMin_:nMax)

	func RandomNNumbersBetweenU(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenU(_n_, _nMin_, _nMax_)

	func AnyNNumbersBetweenU(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenU(_n_, _nMin_, _nMax_)

	func NNumbersBetweenU(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenU(_n_, _nMin_, _nMax_)

	#--

	func NUniqueRandomNumbersBetween(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenU(_n_, _nMin_, _nMax_)

	func UniqueNRandomNumbersBetween(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenU(_n_, _nMin_, _nMax_)

	func NUniqueNumbersBetween(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenU(_n_, _nMin_, _nMax_)

	func UniqueNNumbersBetween(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenU(_n_, _nMin_, _nMax_)

	#>

func NRandomNumbersInUZ(_n_, panNumbers)

	_anNumbers_ = []
	_anPos_ = []

	while 1

		_anRandomZ_ = ARandomNumberInZ(panNumbers)
		
		if StzFindFirst(_anNumbers_, _anRandomZ_[1]) = 0
			_anNumbers_ + _anRandomZ_[1]
			_anPos_ + _anRandomZ_[2]

			if len(_anNumbers_) = _n_
				exit
			ok
		ok
	end

	_aResult_ = Association([ _anNumbers_, _anPos_ ])

	return _aResult_

	#< @FunctionAlternativeForms

	func RandomNNumbersInUZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	func AnyNNumbersInUZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	func NNumbersInUZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	#--

	func NUniqueRandomNumbersInZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	func UniqueNRandomNumbersInZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	func NUniqueNumbersInZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	func UniqueNNumbersInZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	#==

	func RandomNNumbersFromUZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	func AnyNNumbersFromUZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	func NNumbersFromUZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	#--

	func NRandomNumbersFromUZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	func NUniqueRandomNumbersFromZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	func UniqueNRandomNumbersFromZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	func NUniqueNumbersFromZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	func UniqueNNumbersFromZ(_n_, panNumbers)
		return NRandomNumbersInUZ(_n_, panNumbers)

	#==

	func NRandomNumbersBetweenUZ(_n_, _nMin_, _nMax_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInUZ(_n_, _nMin_:nMax)

	func RandomNNumbersBetweenUZ(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenUZ(_n_, _nMin_, _nMax_)

	func AnyNNumbersBetweenUZ(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenUZ(_n_, _nMin_, _nMax_)

	func NNumbersBetweenUZ(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenUZ(_n_, _nMin_, _nMax_)

	#--

	func NUniqueRandomNumbersBetweenZ(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenUZ(_n_, _nMin_, _nMax_)

	func UniqueNRandomNumbersBetweenZ(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenUZ(_n_, _nMin_, _nMax_)

	func NUniqueNumbersBetweenZ(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenUZ(_n_, _nMin_, _nMax_)

	func UniqueNNumbersBetweenZ(_n_, _nMin_, _nMax_)
		return NRandomNumbersBetweenUZ(_n_, _nMin_, _nMax_)

	#>

#--

func NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)
	StzSRandom(_nSeed_)
	return NRandomNumbersInXTU(_n_, panNumbers)

	#< @FunctionAlternativeForms

	func RandomNNumbersInXTU(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	func AnyNNumbersInXTU(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	func NNumbersInXTU(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	#--

	func NUniqueRandomNumbersInXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	func UniqueNRandomNumbersInXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	func NUniqueNumbersInXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	func UniqueNNumbersInXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	#==

	func NRandomNumbersFromXTU(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	func RandomNNumbersFromXTU(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	func AnyNNumbersFromXTU(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	func NNumbersFromXTU(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	#--

	func NUniqueRandomNumbersFromXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	func UniqueNRandomNumbersFromXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	func NUniqueNumbersFromXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	func UniqueNNumbersFromXT(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTU(_n_, panNumbers, _nSeed_)

	#==

	func NRandomNumbersBetweenXTU(_n_, _nMin_, _nMax_, _nSeed_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInXTU(_n_, _nMin_:nMax, _nSeed_)

	func RandomNNumbersBetweenXTU(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTU(_n_, _nMin_, _nMax_, _nSeed_)

	func AnyNNumbersBetweenXTU(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTU(_n_, _nMin_, _nMax_, _nSeed_)

	func NNumbersBetweenXTU(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTU(_n_, _nMin_, _nMax_, _nSeed_)

	#--

	func NUniqueRandomNumbersBetweenXT(_n_, _nMin_, _nMax_, _nSeed_)
		returnNRandomNumbersBetweenXTU(_n_, _nMin_, _nMax_, _nSeed_)

	func UniqueNRandomNumbersBetweenXT(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTU(_n_, _nMin_, _nMax_, _nSeed_)

	func NUniqueNumbersBetweenXT(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTU(_n_, _nMin_, _nMax_, _nSeed_)

	func UniqueNNumbersBetweenXT(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTU(_n_, _nMin_, _nMax_, _nSeed_)

	#>

func NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)
	StzSRandom(_nSeed_)
	return NRandomNumbersInUZ(_n_, panNumbers)

	#< @FunctionAlternativeForms

	func RandomNNumbersInXTUZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	func AnyNNumbersInXTUZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	func NNumbersInXTUZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	#--

	func NUniqueRandomNumbersInXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	func UniqueNRandomNumbersInXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	func NUniqueNumbersInXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	func UniqueNNumbersInXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	#==

	func NRandomNumbersFromXTUZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	func RandomNNumbersFromXTUZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	func AnyNNumbersFromXTUZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	func NNumbersFromXTUZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	#--

	func NUniqueRandomNumbersFromXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	func UniqueNRandomNumbersFromXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	func NUniqueNumbersFromXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	func UniqueNNumbersFromXTZ(_n_, panNumbers, _nSeed_)
		return NRandomNumbersInXTUZ(_n_, panNumbers, _nSeed_)

	#==

	func NRandomNumbersBetweenXTUZ(_n_, _nMin_, _nMax_, _nSeed_)
		if CheckingParams()
			if NOT @BothAreNumbers(_nMin_, _nMax_)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInXTUZ(_n_, _nMin_:nMax, _nSeed_)

	func RandomNNumbersBetweenXTUZ(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTUZ(_n_, _nMin_, _nMax_, _nSeed_)

	func AnyNNumbersBetweenXTUZ(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTUZ(_n_, _nMin_, _nMax_, _nSeed_)

	func NNumbersBetweenXTUZ(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTUZ(_n_, _nMin_, _nMax_, _nSeed_)

	#--

	func NUniqueRandomNumbersBetweenXTZ(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTUZ(_n_, _nMin_, _nMax_, _nSeed_)

	func UniqueNRandomNumbersBetweenXTZ(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTUZ(_n_, _nMin_, _nMax_, _nSeed_)

	func NUniqueNumbersBetweenXTZ(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTUZ(_n_, _nMin_, _nMax_, _nSeed_)

	func UniqueNNumbersBetweenXTZ(_n_, _nMin_, _nMax_, _nSeed_)
		return NRandomNumbersBetweenXTUZ(_n_, _nMin_, _nMax_, _nSeed_)

	#>

#==

func ARandomItemIn(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	_nPos_ = ARandomNumberIn(1:len(paList))
	_aResult_ = paList[_nPos_]

	return _aResult_

	#< @FunctionAlternativeForms

	func AnItemIn(paList)
		return ARandomItemIn(paList)

	func OneItemIn(paList)
		return ARandomItemIn(paList)

	func 1ItemIn(paList)
		return ARandomItemIn(paList)

	#--

	func ARandomItemFrom(paList)
		return ARandomItemIn(paList)

	func AnItemFrom(paList)
		return ARandomItemIn(paList)

	func OneItemFrom(paList)
		return ARandomItemIn(paList)

	func 1ItemFrom(paList)
		return ARandomItemIn(paList)

	#>

func NRandomItemsIn(_n_, paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	_anPos_ = NRandomNumbersIn(_n_, 1:len(paList))
	_nLen_ = len(_anPos_)

	_aResult_ = []

	for _i_ = 1 to _nLen_
		_aResult_ + paList[_anPos_[_i_]]
	next

	return _aResult_

	func NItemsIn(_n_, paList)
		return NRandomItemsIn(_n_, paList)

	func NRandomItemsFrom(_n_, paList)
		return NRandomItemsIn(_n_, paList)

	func NItemsFrom(_n_, paList)
		return NRandomItemsIn(_n_, paList)

func NRandomItemsInU(_n_, paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	_aResult_ = []

	while 1
		_item_ = ARandomItemIn(paList)
		if StzFindFirst(_aResult_, _item_) = 0
			_aResult_ + _item_
			if len(_aResult_) = _n_
				exit
			ok
		ok
	end

	return _aResult_

	#< @FunctionAlternativeForms

	func NUniqueRandomItemsIn(_n_, paList)
		return NRandomItemsInU(_n_, paList)

	func NItemsInU(_n_, paList)
		return NRandomItemsInU(_n_, paList)

	func NUniqueItemsIn(_n_, paList)
		return NRandomItemsInU(_n_, paList)

	#--

	func NRandomItemsFromU(_n_, paList)
		return NRandomItemsInU(_n_, paList)

	func NUniqueRandomItemsFrom(_n_, paList)
		return NRandomItemsInU(_n_, paList)

	func NItemsFromU(_n_, paList)
		return NRandomItemsFromU(_n_, paList)

	func NUniqueItemsFrom(_n_, paList)
		return NRandomItemsFromU(_n_, paList)

	#>
