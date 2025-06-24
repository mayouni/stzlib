
# Get inspiration from this great article:
# https://marketsplash.com/tutorials/python/cracking-the-code-of-randomness-pythons-secrets-revealed/

#TODO // Propose examples showing realword applications of randomness:
#	- Generating unique passwords
#	- Randomizing data
#	- Monte Carlo simulations
#	- Randomizing game scanrios
#	- etc

#TODO // Add titles to functions


_nRingMaxRandom = 999_999_999 # Based on my testing of Ring random() function
			      #NOTE// if you seed the Ring random() function
			      # with a value greater than that, you will get _NULL_
			      # as a result! Example : random(9_999_999_999)

_nRingMaxSeed = 1_999_999_999 # Idem

_nRandomRound = 3	# Defines how many decimals are supported in random01()

_nMaxRandomLoop = 1000 	# How many times Softanza loops to find a given random number
			# before it aborts the process and raises an error
			#--> Used as a safey featur with while loops inorder to
			# avoid infite lopps

_nNo = 0
_nFew = 0.15
_nSome = 0.30
_nHalf = 0.50
_nMany = 0.70
_nMost = 0.90
_nAll = 1

_nProbably = 0.50
_nUnlikely = 0.05
_nPerhaps = 0.50
_nAlmost = 0.95

# Probabilistic functions

func DefaultNo()
	return _nNo

	func DefaultAny()
		return _nNo

	func _No()
		return _nNo

	func _Any()
		return _nNo

func SetNo(n)
	_nNo = n

	func SetAny(n)
		SetNo(n)

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

		func AnyQQ(n)
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

		func NoOneOfQQ(n)
			return NoQQ(n)

	func NoOneIn(p)
		return No(p)

		func NoOneInQ(p)
			return NoQ(p)

		func NoOneInQQ(n)
			return NoQQ(n)

	func NoOneAmong(p)
		return No(p)

		func NoOneAmongQ(p)
			return NoQ(p)

		func NoOneAmongQQ(n)
			return NoQQ(n)

	func NothingOf(p)
		return No(p)

		func NothingOfQ(p)
			return NoQ(p)

		func NothingOfQQ(n)
			return NoQQ(n)

	func NothingIn(p)
		return No(p)

		func NothingInQ(p)
			return NoQ(p)

		func NothingInQQ(n)
			return NoQQ(n)

	func NothingAmong(p)
		return No(p)

		func NothingAmongQ(p)
			return NoQ(p)

		func NothingAmongQQ(n)
			return NoQQ(n)

	func NoItemIn(p)
		return No(p)

		func NoItemInQ(p)
			return NoQ(p)

		func NoItemInQQ(n)
			return NoQQ(n)

	func NoItemAmong(p)
		func NoItemAmongQ(p)
			return NoQ(p)

		func NoItemamongQQ(n)
			return NoQQ(n)

	#>

	#< @FunctionStatementForm

	func NothingInQQX(p)
		_bXStatement_ = _FALSE_
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
	return _nFew

	func _Few()
		return _nFew

func SetFew(n)
	_nFew = n

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

	n = ceil( len(paList) * nFewRatio )
	return NRandomItemsInU(n, paList)

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
	return _nSome

	func _Some()
		return _nSome
func SetSome(n)
	_nSome = n

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

	n = ceil( len(paList) * nSomeRatio )

	return NRandomItemsInU(n, paList)

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
	return _nHalf

	func _Half()
		return _nHalf
func SetHalf(n)
	_nHalf = n

func Half(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	n = ceil( len(paList) / 2 )
	return NRandomItemsInU(n, paList)

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

	nLen = len(paList)
	if IsEven(nLen)
		n = nLen / 2
	else
		n = ceil( nLen / 2 )
	ok

	#< @FunctionFluentForms

	func HalfXTQ(paList)
		return Q(HalfXT(paList))

	func HalfXTQQ(paList)
		return QQ(HalfXT(paList))

	#>

#--

func DefaultMany()
	return _nMany

	func _Many()
		return _nMany

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

func SetMany(n)
	_nMany = n

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

	n = ceil( len(paList) * nManyRatio )
	return NRandomItemsInU(n, paList)

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
	return _nMost

	func _Most()
		return _nMost

func SetMost(n)
	_nMost = n

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

	n = floor( len(paList) * nMostRatio )
	return NRandomItemsInU(n, paList)

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
	return _nAll

	func _All()
		return n_All

func SetAll(n)
	_nAll = n

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
		_bXStatement_ = _TRUE_
		return QQ(p)

	#>

func AllNumbers(panList)
	if CheckingParams()

		if NOT isList(panList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok

		aLast = panList[len(panList)]
		if isList(aList) and StzListQ(aLast).IsAndNamedParam()
			del(panList, len(panList))
			panList + aLast[2]
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
		_bXStatement_ = _TRUE_
		return QQ(panList)

		func AllNumbersInQQX(panList)
			return AllNumbersQQX(panList)

	#>

#==

func MaxRandomLoop()
	return _nMaxRandomLoop

func SetMaxRandomLoop(n)
	if CheckingParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	_nMaxRandomLoop = n

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

func SetRandomRound(n)
	if CheckingParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	_nRandomRound = n
				
func StzRandom(n)
	if CheckingParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	if n > RingMaxRandom()
		StzRaise("Can't proceed. n must be less then " + MaxRingRandom() + ".")
	ok

	if n = 0
		return 0

	but n > 0
		return ARandomNumberIn(1:n)
	else
		return ARandomNumberIn(n:-1)
	ok

	#--

	func StzRandom01()
		nResult = ARandomNumberBetween(0, RandomRoundXT()) / RandomRoundXT()
		return nResult

	func Random01()
		return StzRandom01()

func StzSRandom(n)
	if CheckingParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	if n > RingMaxSeed()
		StzRaise("Can't proceed. n must be less then " + RingMaxSeed() + ".")
	ok

	return srandom(n)

func StzRandomXT(n, nSeed)
	if CheckingParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		if isList(nSeed) and Q(nSeed).IsSeedNamedParam()
			nSeed = nSeed[2]
		ok

		if NOT isNumber(nSeed)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	SeedRandom(nSeed)
	return StzRandom(n)

	#--

	func StzRandom01XT(nSeed)
		nResult = ARandomNumberBetweenXT(0, RandomRoundXT(), nSeed) / RandomRoundXT()
		return nResult

	func Random01XT(nSeed)
		return StzRandom01XT(nSeed)

func SeedRandom(n)
	if CheckingParams()
		if isList(n) and Q(n).IsWithOrByOrUsingNamedParam()
			n = n[2]
		ok
	ok

	if n > RingMaxSeed()
		StzRaise("Can't proceed. n must be less than " + RingMaxSeed() + ".")
	ok

	srandom(n)

#---

func RandomNumber()
	return ring_random( RingMaxRandom() )

	#< @FunctionAlternativeForms

	func ARandomNumber()
		return RandomNumber()

	func AnyRandomNumber()
		return RandomNumber()

	func AnyNumber()
		return RandomNumber()

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

func RandomNumberXT(nSeed)
	StzSRandom(nSeed)
	return RandomNumber()

	#< @FunctionAlternativeForms

	func ARandomNumberXT(nSeed)
		return RandomNumberXT(nSeed)

	func AnyRandomNumberXT(nSeed)
		return RandomNumberXT(nSeed)

	func AnyNumberXT(nSeed)
		return RandomNumberXT(nSeed)

	#==

	func RandomNumber01XT(nSeed)
		return StzNumbers01XT(nSeed)

	func ARandomNumber01XT(nSeed)
		return StzNumbers01XT(nSeed)

	func AnyRandomNumber01XT(nSeed)
		return StzNumbers01XT(nSeed)

	func AnyNumber01XT(nSeed)
		return StzNumbers01XT(nSeed)

	#>

#--

func RandomNumberLessThan(n)
	return RandomNumberIn(1 : n)

	#< @FunctionAlternativeForms

	func ARandomNumberLessThan(n)
		return RandomNumberLessThan(n)

	func RandomNumberSmallerThan(n)
		return RandomNumberLessThan(n)

	func ARandomNumberSmallerThan(n)
		return RandomNumberLessThan(n)

	func ANumberSmallerThan(n)
		return RandomNumberLessThan(n)

	func ANumberLessThan(n)
		return RandomNumberLessThan(n)

	func AnyNumberSmallerThan(n)
		return RandomNumberLessThan(n)

	func AnyNumberLessThan(n)
		return RandomNumberLessThan(n)

	#==

	func RandomNumberLessThan01(n)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n musrt be a number.")
			ok

			if NOT ( n >= 0 and n <= 1 )
				StzRaise("Incorrect value! n must be a value between 0 and 1.")
			ok
		ok

		i = 0
		while _TRUE_
			i++
			nRandom = StzRandom01()
			if nRandom < n or i = MaxRandomLoop()
				exit
			ok
		end

		if nRandom < n
			nResult = nRandom
		else
			StzRaise("Can't proceed! A random number has not been reached after " + MaxRandomLoop() + " trials.")
		ok

		return nResult

	func ARandomNumberLessThan01(n)
		return RandomNumberLessThan01(n)

	func RandomNumberSmallerThan01(n)
		return RandomNumberLessThan01(n)

	func ARandomNumberSmallerThan01(n)
		return RandomNumberLessThan01(n)

	func ANumberSmallerThan01(n)
		return RandomNumberLessThan01(n)

	func ANumberLessThan01(n)
		return RandomNumberLessThan01(n)

	func AnyNumberSmallerThan01(n)
		return RandomNumberLessThan01(n)

	func AnyNumberLessThan01(n)
		return RandomNumberLessThan01(n)

	#>

func RandomNumberLessThanXT(n, nSeed)
	StzSRandom(nSeed)
	return RandomNumberLessThan(n)

	#< @FunctionAlternativeForms

	func ARandomNumberLessThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	func RandomNumberSmallerThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	func ARandomNumberSmallerThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	func ANumberSmallerThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	func ANumberLessThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	func AnyNumberSmallerThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	func AnyNumberLessThanXT(n, nSeed)
		return RandomNumberLessThanXT(n, nSeed)

	#==

	func RandomNumberLessThan01XT(n, nSeed)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n musrt be a number.")
			ok

			if NOT ( n >= 0 and n <= 1 )
				StzRaise("Incorrect value! n must be a value between 0 and 1.")
			ok
		ok


		i = 0
		while _TRUE_
			i++
			nRandom = StzRandom01XT(nSeed)
			if nRandom < n or i = MaxRandomLoop()
				exit
			ok
		end

		if nRandom < n
			nResult = nRandom
		else
			StzRaise("Can't proceed! A random number has not been reached after " + MaxRandomLoop() + " trials.")
		ok

		return nResult

	func ARandomNumberLessThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	func RandomNumberSmallerThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	func ARandomNumberSmallerThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	func ANumberSmallerThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	func ANumberLessThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	func AnyNumberSmallerThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	func AnyNumberLessThan01XT(n, nSeed)
		return RandomNumberLessThan01XT(n, nSeed)

	#>

#--

func RandomNumberGreaterThan(n)
	return RandomNumberIn(n : MaxRingNumber())

	#< @FunctionAlternativeForms

	func ARandomNumberGreaterThan(n)
		return RandomNumberGreaterThan(n)

	func RandomNumberBiggerThan(n)
		return RandomNumberGreaterThan(n)

	func ARandomNumberBiggerThan(n)
		return RandomNumberGreaterThan(n)

	func ANumberGreaterThan(n)
		return RandomNumberGreaterThan(n)

	func ANumberBiggerThan(n)
		return RandomNumberGreaterThan(n)

	func ANumberLargerThan(n)
		return RandomNumberGreaterThan(n)

	func AnyRandomNumberGreaterThan(n)
		return RandomNumberGreaterThan(n)

	func AnyRandomNumberBiggerThan(n)
		return RandomNumberGreaterThan(n, nSeed)

	func AnyNumberGreaterThan(n)
		return RandomNumberGreaterThan(n)

	func AnyNumberBiggerThan(n)
		return RandomNumberGreaterThan(n)

	func AnyNumberLargerThan(n)
		return RandomNumberGreaterThan(n)

	#==

	func RandomNumberGreaterThan01(n)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n musrt be a number.")
			ok

			if NOT ( n >= 0 and n <= 1 )
				StzRaise("Incorrect value! n must be a value between 0 and 1.")
			ok
		ok


		i = 0
		while _TRUE_
			i++
			nRandom = StzRandom01()
			if nRandom > n or i = MaxRandomLoop()
				exit
			ok
		end

		if nRandom < n
			nResult = nRandom
		else
			StzRaise("Can't proceed! A random number has not been reached after " + MaxRandomLoop() + " trial.")
		ok

		return nResult

	func ARandomNumberGreaterThan01(n)
		return RandomNumberGreaterThan01(n)

	func RandomNumberBiggerThan01(n)
		return RandomNumberGreaterThan01(n)

	func ARandomNumberBiggerThan01(n)
		return RandomNumberGreaterThan01(n)

	func ANumberGreaterThan01(n)
		return RandomNumberGreaterThan01(n)

	func ANumberBiggerThan01(n)
		return RandomNumberGreaterThan01(n)

	func ANumberLargerThan01(n)
		return RandomNumberGreaterThan01(n)

	func AnyRandomNumberGreaterThan01(n)
		return RandomNumberGreaterThan01(n)

	func AnyRandomNumberBiggerThan01(n)
		return RandomNumberGreaterThan01(n, nSeed)

	func AnyNumberGreaterThan01(n)
		return RandomNumberGreaterThan01(n)

	func AnyNumberBiggerThan01(n)
		return RandomNumberGreaterThan01(n)

	func AnyNumberLargerThan01(n)
		return RandomNumberGreaterThan01(n)

	#>

func RandomNumberGreaterThanXT(n, nSeed)
	StzSRandom(nSeed)
	return RandomNumberGreaterThan(n)

	#< @FunctionAlternativeForms

	func ARandomNumberGreaterThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func RandomNumberBiggerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func ARandomNumberBiggerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func ANumberGreaterThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func ANumberBiggerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func ANumberLargerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func AnyRandomNumberGreaterThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func AnyRandomNumberBiggerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func AnyNumberGreaterThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func AnyNumberBiggerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	func AnyNumberLargerThanXT(n, nSeed)
		return RandomNumberGreaterThanXT(n, nSeed)

	#==

	func RandomNumberGreaterThan01XT(n)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n musrt be a number.")
			ok

			if NOT ( n >= 0 and n <= 1 )
				StzRaise("Incorrect value! n must be a value between 0 and 1.")
			ok
		ok

		i = 0
		while _TRUE_
			i++
			nRandom = StzRandom01XT()
			if nRandom > n or i = MaxRandomLoop()
				exit
			ok
		end

		if nRandom < n
			nResult = nRandom
		else
			StzRaise("Can't proceed! A random number has not been reached after " + MaxRandomLoop() + " trials.")
		ok

		return nResult

	func ARandomNumberGreaterThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func RandomNumberBiggerThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func ARandomNumberBiggerThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func ANumberGreaterThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func ANumberBiggerThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func ANumberLargerThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func AnyRandomNumberGreaterThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func AnyRandomNumberBiggerThan01XT(n)
		return RandomNumberGreaterThan01XT(n, nSeed)

	func AnyNumberGreaterThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func AnyNumberBiggerThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	func AnyNumberLargerThan01XT(n)
		return RandomNumberGreaterThan01XT(n)

	#>

#--

func RandomNumberOtherThan(n)
	nResult = RandomNumberIn(1 : MaxRingNumber())
	if nResult = n
		nResult = n - 1
		if nResult < 0
			nResult = 0
		ok
	ok
	return nResult

	#< @FunctionAlternativeForm

	func ARandomNumberOtherThan(n)
		return RandomNumberOtherThan(n)

	func AnyRandomNumberOtherThan(n)
		return RandomNumberOtherThan(n)

	func ANumberOtherThan(n)
		return RandomNumberOtherThan(n)

	func AnyNumberOtherThan(n)
		return RandomNumberOtherThan(n)

	func NumberOtherThan(n)
		return RandomNumberOtherThan(n)

	#--

	func ARandomNumberExcept(n)
		return RandomNumberOtherThan(n)

	func AnyRandomNumberExcept(n)
		return RandomNumberOtherThan(n)

	func ANumberExcept(n)
		return RandomNumberOtherThan(n)

	func AnyNumberExcept(n)
		return RandomNumberOtherThan(n)

	#==

	func ARandomNumberOtherThan01(n)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number")
			ok

			if NOT ( n >= 0 and n <=1 )
				StzRaise("Incorrect value! n must be a value between 0 and 1.")
			ok
		ok

		i = 0
		while _TRUE_
			i++
			nRandom = ARandomNumbers01()
			if nRandom != n or i = MaxRandomLoop()
				exit
			ok
		end

		if nRandom != n
			nResult = nRandom
		else
			StzRaise("Can't proceed! A random number has not been reached after " + MaxRandomLoop() + " trials.")
		ok

		return nResult

	func AnyRandomNumberOtherThan01(n)
		return RandomNumberOtherThan01(n)

	func ANumberOtherThan01(n)
		return RandomNumberOtherThan01(n)

	func AnyNumberOtherThan01(n)
		return RandomNumberOtherThan01(n)

	func NumberOtherThan01(n)
		return RandomNumberOtherThan01(n)

	#--

	func ARandomNumberExcept01(n)
		return RandomNumberOtherThan01(n)

	func AnyRandomNumberExcept01(n)
		return RandomNumberOtherThan01(n)

	func ANumberExcept01(n)
		return RandomNumberOtherThan01(n)

	func AnyNumberExcept01(n)
		return RandomNumberOtherThan01(n)

	#>

func RandomNumberOtherThanXT(n, nSeed)
	StzSRandom(nSeed)
	return RandomNumberOtherThan(n)

	#< @FunctionAlternativeForm

	func ARandomNumberOtherThanXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func AnyRandomNumberOtherThanXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func ANumberOtherThanXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func AnyNumberOtherThanXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func NumberOtherThanXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	#--

	func ARandomNumberExceptXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func AnyRandomNumberExceptXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func ANumberExceptXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	func AnyNumberExceptXT(n, nSeed)
		return RandomNumberOtherThanXT(n, nSeed)

	#==

	func ARandomNumberOtherThan01XT(n, nSeed)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number")
			ok

			if NOT ( n >= 0 and n <=1 )
				StzRaise("Incorrect value! n must be a value between 0 and 1.")
			ok
		ok

		i = 0
		while _TRUE_
			i++
			nRandom = ARandomNumber01XT(nSeed)
			if nRandom != n or i = MaxRandomLoop()
				exit
			ok
		end

		if nRandom != n
			nResult = nRandom
		else
			StzRaise("Can't proceed! A random number has not been reached after " + MaxRandomLoop() + " trials.")
		ok

		return nResult

	func AnyRandomNumberOtherThan01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	func ANumberOtherThan01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	func AnyNumberOtherThan01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	func NumberOtherThan01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	#--

	func ARandomNumberExcept01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	func AnyRandomNumberExcept01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	func ANumberExcept01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	func AnyNumberExcept01XT(n, nSeed)
		return RandomNumberOtherThan01XT(n, nSeed)

	#>

#==

func SomeRandomNumbersGreaterThan(nValue)
	n = floor( _Some() * 10 )
	return NRandomNumbersGreaterThan(n, nValue)

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

		nSome = ARandomNumberLessThan( floor(_Some() * 10) )
		anResult = []

		for i = 1 to nSome
			anResult + ARanomNumberGreaterThan01(nValue)
		next

		return anResult

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

func SomeRandomNumbersGreaterThanXT(n, nSeed)
	StzSRandom(nSeed)
	return SomeRandomNumbersGreaterThan(n)

	#< @FunctionAlternativeForms

	func SomeNumbersGreaterThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	func AnyRandomNumbersGreaterThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	func AnyNumbersGreaterThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	#--

	func SomeRandomNumbersBiggerThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	func SomeNumbersBiggerThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	func AnyRandomNumbersBiggerThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	func AnyNumbersBiggerThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	#==

	func RandomNumbersGreaterThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	func RandomNumbersBiggerThanXT(n, nSeed)
		return SomeRandomNumbersGreaterThanXT(n, nSeed)

	#==

	func SomeRandomNumbersGreaterThan01XT(n, nSeed)

		nSome = ARandomNumberLessThan( floor( _Some() * 10) )
		anResult = []

		for i = 1 to nSome
			anResult + ARanomNumberGreaterThan01XT(n, nSeed)
		next

		return anResult

	func SomeNumbersGreaterThan01XT(n, nSeed)
		return SomeRandomNumbersGreaterThan01XT(n, nSeed)

	func AnyRandomNumbersGreaterThan01XT(n, nSeed)
		return SomeRandomNumbersGreaterThan01XT(n, nSeed)

	func AnyNumbersGreaterThan01XT(n, nSeed)
		return SomeRandomNumbersGreaterThan01XT(n, nSeed)

	#--

	func SomeRandomNumbersBiggerThan01XT(n, nSeed)
		return SomeRandomNumbersGreaterThan01XT(n, nSeed)

	func SomeNumbersBiggerThan01XT(n, nSeed)
		return SomeRandomNumbersGreaterThan01XT(n, nSeed)

	func AnyRandomNumbersBiggerThan01XT(n, nSeed)
		return SomeRandomNumbersGreaterThan01XT(n, nSeed)

	func AnyNumbersBiggerThan01XT(n, nSeed)
		return SomeRandomNumbersGreaterThan01XT(n, nSeed)

	#--

	func RandomNumbersGreaterThan01XT(n, nSeed)
		return SomeRandomNumbersGreaterThan01XT(n, nSeed)

	func RandomNumbersBiggerThan01XT(n, nSeed)
		return SomeRandomNumbersGreaterThan01XT(n, nSeed)

	#>

#--

func SomeRandomNumbersGreaterThanU(n)
	return NRandomNumbersGreaterThanU( floor( _Some() * 10), n)

	#< @FunctionAlternativeForms

	func SomeNumbersGreaterThanU(n)
		return SomeRandomNumbersGreaterThanU(n)

	func AnyRandomNumbersGreaterThanU(n)
		return SomeRandomNumbersGreaterThanU(n)

	func AnyNumbersGreaterThanU(n)
		return SomeRandomNumbersGreaterThanU(n)

	#--

	func SomeRandomNumbersBiggerThanU(n)
		return SomeRandomNumbersGreaterThanU(n)

	func SomeNumbersBiggerThanU(n)
		return SomeRandomNumbersGreaterThanU(n)

	func AnyRandomNumbersBiggerThanU(n)
		return SomeRandomNumbersGreaterThanU(n)

	func AnyNumbersBiggerThanU(n)
		return SomeRandomNumbersGreaterThanU(n)

	#--

	func SomeUniqueRandomNumbersGreaterThanU(n)
		return SomeRandomNumbersGreaterThanU(n)

	func SomeUniqueNumbersGreaterThanU(n)
		return SomeRandomNumbersGreaterThanU(n)

	#--

	func SomeUniqueRandomNumbersBiggerThanU(n)
		return SomeRandomNumbersGreaterThanU(n)

	func SomeUniqueNumbersBiggerThanU(n)
		return SomeRandomNumbersGreaterThanU(n)

	#--

	func RandomNumbersGreaterThanU(n)
		return SomeRandomNumbersGreaterThanU(n)

	func RandomNumbersBiggerThanU(n)
		return SomeRandomNumbersGreaterThanU(n)

	func UniqueRandomNumbersGreaterThan(n)
		return SomeRandomNumbersGreaterThanU(n)

	func UniqueRandomNumbersBiggerThan(n)
		return SomeRandomNumbersGreaterThanU(n)

	#==

	func SomeRandomNumbersGreaterThan01U(n)

		nSome = ARandomNumberLessThan( floor(_Some() * 10) )
		anResult = []

		while _TRUE_
			nRandom = ARanomNumberGreaterThan01(n)
			if ring_find(anResult, nRandom) = 0
				anResult + nRandom

				if len(anResult) = nSome
					exit
				ok
			ok
		end

		return anResult

	func SomeNumbersGreaterThan01U(n)
		return SomeRandomNumbersGreaterThan01U(n)

	func AnyRandomNumbersGreaterThan01U(n)
		return SomeRandomNumbersGreaterThan01U(n)

	func AnyNumbersGreaterThan01U(n)
		return SomeRandomNumbersGreaterThan01U(n)

	#--

	func SomeRandomNumbersBiggerThan01U(n)
		return SomeRandomNumbersGreaterThan01U(n)

	func SomeNumbersBiggerThan01U(n)
		return SomeRandomNumbersGreaterThan01U(n)

	func AnyRandomNumbersBiggerThan01U(n)
		return SomeRandomNumbersGreaterThan01U(n)

	func AnyNumbersBiggerThan01U(n)
		return SomeRandomNumbersGreaterThan01U(n)

	#--

	func SomeUniqueRandomNumbersGreaterThan01U(n)
		return SomeRandomNumbersGreaterThan01U(n)

	func SomeUniqueNumbersGreaterThan01U(n)
		return SomeRandomNumbersGreaterThan01U(n)

	#--

	func SomeUniqueRandomNumbersBiggerThan01U(n)
		return SomeRandomNumbersGreaterThan01U(n)

	func SomeUniqueNumbersBiggerThan01U(n)
		return SomeRandomNumbersGreaterThan01U(n)

	#--

	func RandomNumbersGreaterThan01U(n)
		return SomeRandomNumbersGreaterThan01U(n)

	func RandomNumbersBiggerThan01U(n)
		return SomeRandomNumbersGreaterThanU(n)

	func UniqueRandomNumbersGreaterThan01(n)
		return SomeRandomNumbersGreaterThan01U(n)

	func UniqueRandomNumbersBiggerThan01(n)
		return SomeRandomNumbersGreaterThan01U(n)

	#>

func SomeRandomNumbersGreaterThanXTU(n, nValue, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersGreaterThanU(n, nValue)

	#< @FunctionAlternativeForms

	func SomeNumbersGreaterThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func AnyRandomNumbersGreaterThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func AnyNumbersGreaterThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	#--

	func SomeRandomNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func SomeNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func AnyRandomNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func AnyNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	#--

	func SomeUniqueRandomNumbersGreaterThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func SomeUniqueNumbersGreaterThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	#--

	func SomeUniqueRandomNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func SomeUniqueNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	#--

	func RandomNumbersGreaterThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func RandomNumbersBiggerThanXTU(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXTU(nValue, nSeed)

	func UniqueRandomNumbersGreaterThanXT(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXT(nValue, nSeed)

	func UniqueRandomNumbersBiggerThanXT(nValue, nSeed)
		return SomeRandomNumbersGreaterThanXT(nValue, nSeed)

	#==

	func SomeRandomNumbersGreaterThan01XTU(n, nSeed)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number")
			ok
		ok

		nSome = ARandomNumberLessThan(floor(_Some() * 10))
		anResult = []

		while _TRUE_
			nRandom = ARanomNumberBetween01XT(n, nSeed)
			if ring_find(anResult, nRandom) = 0
				anResult + nRandom

				if len(anResult) = nSome
					exit
				ok
			ok
		end

		return anResult

	func SomeNumbersGreaterThan01XTU(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	func AnyRandomNumbersGreaterThan01XTU(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	func AnyNumbersGreaterThan01XTU(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	#--

	func SomeRandomNumbersBiggerThan01XTU(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	func SomeNumbersBiggerThan01XTU(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	func AnyRandomNumbersBiggerThan01XTU(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	func AnyNumbersBiggerThan01XTU(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	#--

	func SomeUniqueRandomNumbersGreaterThan01XTU(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	func SomeUniqueNumbersGreaterThan01XTU(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	#--

	func SomeUniqueRandomNumbersBiggerThan01XTU(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	func SomeUniqueNumbersBiggerThan01XTU(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	#--

	func RandomNumbersGreaterThan01XTU(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	func RandomNumbersBiggerThan01XTU(n, nSeed)
		return SomeRandomNumbersGreaterThanXTU(n, nSeed)

	func UniqueRandomNumbersGreaterThan01XT(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	func UniqueRandomNumbersBiggerThan01XT(n, nSeed)
		return SomeRandomNumbersGreaterThan01XTU(n, nSeed)

	#>


#==

func NRandomNumbersGreaterThan(n, nValue)
	if NOT (isNumber(n) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	anResult = []
	for i = 1 to n
		anResult + ARandomNumberGreaterThan(nValue)
	next

	return anResult

	#< @FunctionAlternativeForm

	func NRandomNumbersLargerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func NRandomNumbersBiggerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func NNumbersGreaterThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func NNumbersLargerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func NNumbersBiggerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)


	func AnyNNumbersGreaterThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func AnyNNumbersLargerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func AnyNNumbersBiggerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	#==

	func NRandomNumbersGreaterThan01(n, nValue)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		anResult = []

		for i = 1 to n
			anResult + ARandomNumberGreaterThan01(nValue)
		next

		return anResult

	func NRandomNumbersLargerThan01(n, nValue)
		return NRandomNumbersGreaterThan01(n, nValue)

	func NRandomNumbersBiggerThan01(n, nValue)
		return NRandomNumbersGreaterThan01(n, nValue)

	func NNumbersGreaterThan01(n, nValue)
		return NRandomNumbersGreaterThan01(n, nValue)

	func NNumbersLargerThan01(n, nValue)
		return NRandomNumbersGreaterThan01(n, nValue)

	func NNumbersBiggerThan01(n, nValue)
		return NRandomNumbersGreaterThan01(n, nValue)

	func AnyNNumbersGreaterThan01(n, nValue)
		return NRandomNumbersGreaterThan01(n, nValue)

	func AnyNNumbersLargerThan01(n, nValue)
		return NRandomNumbersGreaterThan01(n, nValue)

	func AnyNNumbersBiggerThan01(n, nValue)
		return NRandomNumbersGreaterThan01(n, nValue)

	#>

func NRandomNumbersGreaterThanXT(n, nValue, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersGreaterThan(n, nValue)

	#< @FunctionAlternativeForm

	func NRandomNumbersLargerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func NRandomNumbersBiggerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func NNumbersGreaterThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func NNumbersLargerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func NNumbersBiggerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func AnyNNumbersGreaterThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func AnyNNumbersLargerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func AnyNNumbersBiggerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	#==

	func NRandomNumbersGreaterThan01XT(n, nValue, nSeed)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		anResult = []

		for i = 1 to n
			anResult + ARandomNumberGreaterThan01XT(nValue, nSeed)
		next

		return anResult

	func NRandomNumbersLargerThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XT(n, nValue, nSeed)

	func NRandomNumbersBiggerThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XT(n, nValue, nSeed)

	func NNumbersGreaterThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XT(n, nValue, nSeed)

	func NNumbersLargerThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XT(n, nValue, nSeed)

	func NNumbersBiggerThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XT(n, nValue, nSeed)

	func AnyNNumbersGreaterThan01XT(n, nValue)
		return NRandomNumbersGreaterThan01XT(n, nValue, nSeed)

	func AnyNNumbersLargerThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XT(n, nValue, nSeed)

	func AnyNNumbersBiggerThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XT(n, nValue, nSeed)

	#>

func NRandomNumbersGreaterThanU(n, nValue)
	if NOT (isNumber(n) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	anResult = []

	while _TRUE_

		nRandom = ARandomNumberGreaterThan(nValue)

		if ring_find(anResult, nRandom) = 0
			anResult + nRandom
			if len(anResult) = n
				exit
			ok
		ok

	end

	return anResult

	#< @FunctionAlternativeForm

	func NRandomNumbersLargerThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NRandomNumbersBiggerThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NNumbersGreaterThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NNumbersLargerThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NNumbersBiggerThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func AnyNNumbersGreaterThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func AnyNNumbersLargerThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func AnyNNumbersBiggerThanU(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	#--

	func NUniqueRandomNumbersGreaterThan(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NUniqueRandomNumbersLargerThan(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NUniqueRandomNumbersBiggerThan(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NUniqueNumbersGreaterThan(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NUniqueNumbersLargerThan(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	func NUniqueNumbersBiggerThan(n, nValue)
		return NRandomNumbersGreaterThanU(n, nValue)

	#==

	func NRandomNumbersGreaterThan01U(n, nValue)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		anResult = []

		while _TRUE_

			nRandom = ARandomNumberGreaterThan01(nValue)

			if ring_find(anResult, nRandom)
				anResult + nRandom
				if len(anResult) = n
					exit
				ok
			ok
		end

		return anResult

	func NRandomNumbersLargerThan01U(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	func NRandomNumbersBiggerThan01U(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	func NNumbersGreaterThan01U(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	func NNumbersLargerThan01U(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	func NNumbersBiggerThan01U(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	func AnyNNumbersGreaterThan01U(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	func AnyNNumbersLargerTha01nU(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	func AnyNNumbersBiggerThan01U(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	#--

	func NUniqueRandomNumbersGreaterThan01(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	func NUniqueRandomNumbersLargerThan01(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	func NUniqueRandomNumbersBiggerThan01(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	func NUniqueNumbersGreaterThan01(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	func NUniqueNumbersLargerThan01(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	func NUniqueNumbersBiggerThan01(n, nValue)
		return NRandomNumbersGreaterThan01U(n, nValue)

	#>

func NRandomNumbersGreaterThanXTU(n, nValue, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersGreaterThanU(n, nValue)

	#< @FunctionAlternativeForm

	func NRandomNumbersLargerThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NRandomNumbersBiggerThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)


	func NNumbersGreaterThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func NNumbersLargerThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NNumbersBiggerThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)


	func AnyNNumbersGreaterThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func AnyNNumbersLargerThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func AnyNNumbersBiggerThanXTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	#--

	func NUniqueRandomNumbersGreaterThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NUniqueRandomNumbersLargerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NUniqueRandomNumbersBiggerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NUniqueNumbersGreaterThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NUniqueNumbersLargerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	func NUniqueNumbersBiggerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXTU(n, nValue, nSeed)

	#==

	func NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		anResult = []

		while _TRUE_

			nRandom = ARandomNumberGreaterThan01XT(nValue, nSeed)

			if ring_find(anResult, nRandom)
				anResult + nRandom
				if len(anResult) = n
					exit
				ok
			ok
		end

		return anResult

	func NRandomNumbersLargerThan01XTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	func NRandomNumbersBiggerThan01XTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	func NNumbersGreaterThan01XTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	func NNumbersLargerThan01XTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	func NNumbersBiggerThan01XTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	func AnyNNumbersGreaterThan01XTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	func AnyNNumbersLargerThan01XTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	func AnyNNumbersBiggerThan01XTU(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	#--

	func NUniqueRandomNumbersGreaterThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	func NUniqueRandomNumbersLargerThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	func NUniqueRandomNumbersBiggerThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	func NUniqueNumbersGreaterThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	func NUniqueNumbersLargerThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	func NUniqueNumbersBiggerThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XTU(n, nValue, nSeed)

	#>

#==

func NRandomNumbersLessThan(n, nValue)
	if NOT (isNumber(n) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	anResult = []
	for i = 1 to n
		anResult + ARandomNumberLessThan(nValue)
	next

	return anResult

	#< @FunctionAlternativeForm

	func NRandomNumbersSmallerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)


	func NNumbersLessThan(n, nValue)
		return NRandomNumbersLessThan(n, nValue)

	func NNumbersSmallerThan(n, nValue)
		return NRandomNumbersGreaterThan(n, nValue)

	func AnyNNumbersLessThan(n, nValue)
		return NRandomNumbersLessThan(n, nValue)

	func AnyNNumbersSmallerThan(n, nValue)
		return NRandomNumbersLessThan(n, nValue)

	#==

	func NRandomNumbersLessThan01(n, nValue)
		if CheckingParams()
			if NOT isNumber(nValue)
				StzRaise("Incorrect param type! nValue must be a number.")
			ok

			if NOT ( nValue >= 0 and nValue <= 1 )
				StzRaise("Incorrect value! nValue must be a value between 0 and 1.")
			ok
		ok

		anResult = []

		for i = 1 to n
			anResult + ARandomNumberLessThan01(nValue)
		next

		return anResult

	func NRandomNumbersSmallerThan01(n, nValue)
		return NRandomNumbersGreaterThan01(n, nValue)


	func NNumbersLessThan01(n, nValue)
		return NRandomNumbersLessThan01(n, nValue)

	func NNumbersSmallerThan01(n, nValue)
		return NRandomNumbersGreaterThan01(n, nValue)

	func AnyNNumbersLessThan01(n, nValue)
		return NRandomNumbersLessThan01(n, nValue)

	func AnyNNumbersSmallerThan01(n, nValue)
		return NRandomNumbersLessThan01(n, nValue)

	#>

func NRandomNumbersLessThanXT(n, nValue, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersLessThan(n, nValue)

	#< @FunctionAlternativeForm

	func NRandomNumbersSmallerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)


	func NNumbersLessThanXT(n, nValue, nSeed)
		return NRandomNumbersLessThanXT(n, nValue, nSeed)

	func NNumbersSmallerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	func AnyNNumbersLessThanXT(n, nValue, nSeed)
		return NRandomNumbersLessThanXT(n, nValue, nSeed)

	func AnyNNumbersSmallerThanXT(n, nValue, nSeed)
		return NRandomNumbersGreaterThanXT(n, nValue, nSeed)

	#==

	func NRandomNumbersLessThan01XT(n, nValue, nSeed)
		if CheckingParams()
			if NOT isNumber(nValue)
				StzRaise("Incorrect param type! nValue must be a number.")
			ok

			if NOT ( nValue >= 0 and nValue <= 1 )
				StzRaise("Incorrect value! nValue must be a value between 0 and 1.")
			ok
		ok

		anResult = []

		for i = 1 to n
			anResult + ARandomNumberLessThan01XT(nValue, nSeed)
		next

		return anResult

	func NRandomNumbersSmallerThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XT(n, nValue, nSeed)


	func NNumbersLessThan01XT(n, nValue, nSeed)
		return NRandomNumbersLessThan01XT(n, nValue, nSeed)

	func NNumbersSmallerThan01XT(n, nValue, nSeed)
		return NRandomNumbersGreaterThan01XT(n, nValue, nSeed)

	func AnyNNumbersLessThan01XT(n, nValue, nSeed)
		return NRandomNumbersLessThan01XT(n, nValue, nSeed)

	func AnyNNumbersSmallerThan01XT(n, nValue, nSeed)
		return NRandomNumbersLessThan01XT(n, nValue, nSeed)

	#>

func NRandomNumbersLessThanU(n, nValue)
	if NOT (isNumber(n) and isNumber(nValue))
		StzRaise("Incorrect param type! n and nValue must be numbers.")
	ok

	anResult = []

	while _TRUE_

		nRandom = ARandomNumberLessThan(nValue)

		if ring_find(anResult, nRandom) = 0
			anResult + nRandom
			if len(anResult) = n
				exit
			ok
		ok

	end

	return anResult

	#< @FunctionAlternativeForm

	func NNumbersLessThanU(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	func NNumbersSmallerThanU(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	func AnyNNumbersLessThanU(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	func AnyNNumbersSmallerThanU(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	#--

	func NUniqueRandomNumbersLessThan(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	func NUniqueRandomNumbersSmallerThan(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)


	func NUniqueNumbersLessThan(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	func NUniqueNumbersSmallerThan(n, nValue)
		return NRandomNumbersLessThanU(n, nValue)

	#==

	func NRandomNumbersLessThan01U(n, nValue)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		anResult = []

		i = 0
		while _TRUE_
			i++
			nRandom = ARandomNumberLessthan01(n, nValue)

			if ring_find(anResult, nRandom) = 0
				anResult + nRandom
				if len(anResult) = n or i = MaxRandomLoop()
					exit
				ok
			ok

		end

		if len(anResult) = n
			return anResult
		else
			StzRaise("Can't proceed. No random number generated after " + MaxRandomLoop() + " trials.")
		ok

	func NNumbersLessThan01U(n, nValue)
		return NRandomNumbersLessThan01U(n, nValue)

	func NNumbersSmallerThan01U(n, nValue)
		return NRandomNumbersLessThan01U(n, nValue)

	func AnyNNumbersLessThan01U(n, nValue)
		return NRandomNumbersLessThan01U(n, nValue)

	func AnyNNumbersSmallerThan01U(n, nValue)
		return NRandomNumbersLessThan01U(n, nValue)

	#--

	func NUniqueRandomNumbersLessThan01(n, nValue)
		return NRandomNumbersLessThan01U(n, nValue)

	func NUniqueRandomNumbersSmallerThan01(n, nValue)
		return NRandomNumbersLessThan01U(n, nValue)


	func NUniqueNumbersLessThan01(n, nValue)
		return NRandomNumbersLessThan01U(n, nValue)

	func NUniqueNumbersSmallerThan01(n, nValue)
		return NRandomNumbersLessThan01U(n, nValue)

	#>

func NRandomNumbersLessThanXTU(n, nValue, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersLessThanU(n, nValue)

	#< @FunctionAlternativeForm

	func NNumbersLessThanXTU(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	func NNumbersSmallerThanXTU(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	func AnyNNumbersLessThanXTU(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	func AnyNNumbersSmallerThanXTU(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	#--

	func NUniqueRandomNumbersLessThanXT(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	func NUniqueRandomNumbersSmallerThanXT(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)


	func NUniqueNumbersLessThanXT(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	func NUniqueNumbersSmallerThanXT(n, nValue)
		return NRandomNumbersLessThanXTU(n, nValue)

	#==

	func NRandomNumbersLessThanXT01U(n, nValue, nSeed)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		anResult = []

		i = 0
		while _TRUE_
			i++
			nRandom = ARandomNumberLessthanXT01(n, nValue, nSeed)

			if ring_find(anResult, nRandom) = 0
				anResult + nRandom
				if len(anResult) = n or i = MaxRandomLoop()
					exit
				ok
			ok

		end

		if len(anResult) = n
			return anResult
		else
			StzRaise("Can't proceed. No random number generated after " + MaxRandomLoop() + " trials.")
		ok

	func NNumbersLessThanXT01U(n, nValue, nSeed)
		return NRandomNumbersLessThan01U(n, nValue)

	func NNumbersSmallerThanXT01U(n, nValue, nSeed)
		return NRandomNumbersLessThanXT01U(n, nValue, nSeed)

	func AnyNNumbersLessThanXT01U(n, nValue, nSeed)
		return NRandomNumbersLessThanXT01U(n, nValue, nSeed)

	func AnyNNumbersSmallerThanXT01U(n, nValue, nSeed)
		return NRandomNumbersLessThanXT01U(n, nValue, nSeed)

	#--

	func NUniqueRandomNumbersLessThanXT01(n, nValue, nSeed)
		return NRandomNumbersLessThanXT01U(n, nValue, nSeed)

	func NUniqueRandomNumbersSmallerThanXT01(n, nValue, nSeed)
		return NRandomNumbersLessThanXT01U(n, nValue, nSeed)


	func NUniqueNumbersLessThanXT01(n, nValue, nSeed)
		return NRandomNumbersLessThanXT01U(n, nValue, nSeed)

	func NUniqueNumbersSmallerThanXT01(n, nValue, nSeed)
		return NRandomNumbersLessThanXT01U(n, nValue, nSeed)

	#>

#== A RANDOM NUMBER AMONG THE NUMBERS IN A LIST

func RandomNumberIn(panNumbers)
	if NOT isList(panNumbers)
		StzRaise("Incorrect param type! panNumbers must be a list.")
	ok

	nLen = len(panNumbers)
	anNumbers = []
	for i = 1 to nLen
		if isNumber(panNumbers[i])
			anNumbers + panNumbers[i]
		ok
	next

	nLen = len(anNumbers)
	nPos = ring_random(nLen)

	if nPos = 0
		nPos = 1
	ok

	nResult = anNumbers[nPos]

	return nResult

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

	func RandomNumberBetween(nMin, nMax)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		
		if nMin = nMax
			return nMin

		but BothAreIntegers(nMin, nMax)

			if Abs(nMin - nMax) = 1
				anTemp = ring_sort([ nMin, nMax ])
				nRandom01 = ARandomNumber01()
				nResult = anTemp[1] + nRandom01
				return nResult

			else
				return RandomNumberIn(nMin:nMax)
			ok

		else

			nMin01 = 0
			nMax01 = 0
			nRandomMin01 = 0
			nRandomMax01 = 0

			oMin = new stzNumber(nMin)
			oMax = new stzNumber(nMax)

			if oMin.IsReal()
				nMin   = 0+ oMin.IntegerPart()
				nMin01 = 0+ oMin.DecimalPart()

				nRandomMin01 = ARanomNumberGreaterThan01(nMin01)
				nRandomMax01 = 0

			but oMax.IsReal()
				nMax   = 0+ oMax.IntegerPart() 
				nMax01 = 0+ oMax.DecimalPart()
			ok

			/* ... */
		ok

	func ARandomNumberBetween(nMin, nMax)
		return RandomNumberBetween(nMin, nMax)

	func ANumberBetween(nMin, nMax)
		return RandomNumberBetween(nMin, nMax)

	func AnyNumberBetween(nMin, nMax)
		return RandomNumberBetween(nMin, nMax)

	func AnyRandomNumberBetween(nMin, nMax)
		return RandomNumberBetween(nMin, nMax)

	#>

#--

func RandomNumberInZ(panNumbers)
	if NOT isList(panNumbers)
		StzRaise("Incorrect param type! panNumbers must be a list.")
	ok

	nLen = len(panNumbers)
	anNumbers = []

	for i = 1 to nLen
		if isNumber(panNumbers[i])
			anNumbers + panNumbers[i]
		ok
	next

	nLen = len(anNumbers)
	nPos = ring_random(nLen)

	if nPos = 0
		nPos = 1
	ok

	aResult = [ anNumbers[nPos], nPos ]

	return aResult

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

	func RandomNumberBetweenZ(nMin, nMax)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return RandomNumberInZ(nMin:nMax)

	func ARandomNumberBetweenZ(nMin, nMax)
		return RandomNumberBetweenZ(nMin, nMax)

	func ANumberBetweenZ(nMin, nMax)
		return RandomNumberBetweenZ(nMin, nMax)

	func AnyNumberBetweenZ(nMin, nMax)
		return RandomNumberBetweenZ(nMin, nMax)

	func AnyRandomNumberBetweenZ(nMin, nMax)
		return RandomNumberBetweenZ(nMin, nMax)

	#>

#==

func RandomNumberInXT(panNumbers, nSeed)
	StzSRandom(nSeed)
	nResult = StzRandomNumberIn(panNumbers)

	return nResult

	#< @FunctionAlternativeForms

	func ARandomNumberInXT(panNumbers, nSeed)
		return RandomNumberInXT(panNumbers, nSeed)

	func ANumberInXT(panNumbers, nSeed)
		return RandomNumberInXt(panNumbers, nSeed)

	func AnyNumberInXT(panNumbers, nSeed)
		return RandomNumberInXT(panNumbers, nSeed)

	func AnyRandomNumberInXT(panNumbers, nSeed)
		return RandomNumberInXT(panNumbers, nSeed)

	#==

	func RandomNumberFromXT(panNumbers, nSeed)
		return RandomNumberInXT(panNumbers, nSeed)

	func ARandomNumberFromXT(panNumbers, nSeed)
		return RandomNumberInXT(panNumbers, nSeed)

	func ANumberFromXT(panNumbers, nSeed)
		return RandomNumberInXt(panNumbers, nSeed)

	func AnyNumberFromXT(panNumbers, nSeed)
		return RandomNumberInXT(panNumbers, nSeed)

	func AnyRandomNumberFromXT(panNumbers, nSeed)
		return RandomNumberInXT(panNumbers, nSeed)

	#==

	func RandomNumberBetweenXT(nMin, nMax, nSeed)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumberInXT(nMin:nMax, nSeed)

	func ARandomNumberBetweenXT(nMin, nMax, nSeed)
		return RandomNumberBetweenXT(nMin, nMax, nSeed)

	func ANumberBetweenXT(nMin, nMax, nSeed)
		return RandomNumberBetweenXT(nMin, nMax, nSeed)

	func AnyNumberBetweenXT(nMin, nMax, nSeed)
		return RandomNumberBetweenXT(nMin, nMax, nSeed)

	func AnyRandomNumberBetweenXT(nMin, nMax, nSeed)
		return RandomNumberBetweenXT(nMin, nMax, nSeed)

	#>

func RandomNumberInXTZ(panNumbers, nSeed)
	if CheckingParams()

		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers must be a list of numbers.")
		ok

	ok

	StzSRandom(nSeed)
	nPos = ARandomNumberIn(1:len(panNumbers))
	aResult = [ panNumbers[nPos], nPos ]
	return aResult

	#< @FunctionAlternativeForms

	func ARandomNumberInXTZ(panNumbers, nSeed)
		return RandomNumberInXTZ(panNumbers, nSeed)

	func ANumberInXTZ(panNumbers, nSeed)
		return RandomNumberInXTZ(panNumbers, nSeed)

	func AnyNumberInXTZ(panNumbers, nSeed)
		return RandomNumberInXTZ(panNumbers, nSeed)

	func AnyRandomNumberInXTZ(panNumbers, nSeed)
		return RandomNumberInXTZ(panNumbers, nSeed)

	#==

	func RandomNumberFromXTZ(panNumbers, nSeed)
		return RandomNumberInXTZ(panNumbers, nSeed)

	func ARandomNumberFromXTZ(panNumbers, nSeed)
		return RandomNumberInXTZ(panNumbers, nSeed)

	func ANumberFromXTZ(panNumbers, nSeed)
		return RandomNumberInXTZ(panNumbers, nSeed)

	func AnyNumberFromXTZ(panNumbers, nSeed)
		return RandomNumberInXTZ(panNumbers, nSeed)

	func AnyRandomNumberFromXTZ(panNumbers, nSeed)
		return RandomNumberInXTZ(panNumbers, nSeed)

	#==

	func RandomNumberBetweenXTZ(nMin, nMax, nSeed)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumberInXTZ(nMin:nMax, nSeed)

	func ARandomNumberBetweenXTZ(nMin, nMax, nSeed)
		return SomeRandomNumberBetweenXTZ(nMin, nMax, nSeed)

	func ANumberBetweenXTZ(nMin, nMax, nSeed)
		return ARandomNumberBetweenXTZ(nMin, nMax, nSeed)

	func AnyNumberBetweenXTZ(nMin, nMax, nSeed)
		return ARandomNumberBetweenXTZ(nMin, nMax, nSeed)

	func AnyRandomNumberBetweenXTZ(nMin, nMax, nSeed)
		return ARandomNumberBetweenXTZ(nMin, nMax, nSeed)

	#>

#==

func SomeRandomNumbersIn(panNumbers)
	if CheckingParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	n = floor( _Some() * len(panNumbers) )
	return NRandomNumbersIn(n, panNumbers)

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

	func SomeRandomNumbersBetween(nMin, nMax)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersIn(nMin : nMax)

	func SomeNumbersBetween(nMin, nMax)
		return SomeRandomNumbersBetween(nMin, nMax)

	func AnyRandomNumbersBetween(nMin, nMax)
		return SomeRandomNumbersBetween(nMin, nMax)

	func AnyNumbersBetween(nMin, nMax)
		return SomeRandomNumbersBetween(nMin, nMax)

	#--

	func RandomNumbersBetween(nMin, nMax)
		return SomeRandomNumbersBetween(nMin, nMax)

	#>

func SomeRandomNumbersInZ(panNumbers)
	if CheckingParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	n = floor( _Some() * len(panNumbers) )
	return NRandomNumbersInZ(n, panNumbers)

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

	func SomeRandomNumbersBetweenZ(nMin, nMax)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersInZ(nMin : nMax)

	func SomeNumbersBetweenZ(nMin, nMax)
		return RandomNumbersBetweenZ(nMin, nMax)

	func AnyRandomNumbersBetweenZ(nMin, nMax)
		return RandomNumbersBetweenZ(nMin, nMax)

	func AnyNumbersBetweenZ(nMin, nMax)
		return RandomNumbersBetweenZ(nMin, nMax)

	#--

	func RandomNumbersBetweenZ(nMin, nMax)
		return RandomNumbersBetweenZ(nMin, nMax)

	#>

#==

func SomeRandomNumbersInXT(panNumbers, nSeed)
	StzSRandom(nSeed)
	return SomeRandomNumbersIn(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXT(panNumbers, nSeed)
		return SomeRandomNumbersInXT(panNumbers, nSeed)

	func AnyRandomNumbersInXT(panNumbers, nSeed)
		return SomeRandomNumbersInXT(panNumbers, nSeed)

	func AnyNumbersInXT(panNumbers, nSeed)
		return SomeRandomNumbersInXT(panNumbers, nSeed)

	#--

	func RandomNumbersInXT(panNumbers, nSeed)
		return SomeRandomNumbersInXT(panNumbers, nSeed)

	#==

	func SomeNumbersFromXT(panNumbers, nSeed)
		return SomeRandomNumbersInXT(panNumbers, nSeed)

	func AnyRandomNumbersFromXT(panNumbers, nSeed)
		return SomeRandomNumbersInXT(panNumbers, nSeed)

	func AnyNumbersFromXT(panNumbers, nSeed)
		return SomeRandomNumbersInXT(panNumbers, nSeed)

	#--

	func RandomNumbersFromXT(panNumbers, nSeed)
		return SomeRandomNumbersInXT(panNumbers, nSeed)

	#==

	func SomeRandomNumbersBetweenXT(nMin, nMax, nSeed)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersInXT(nMin : nMax, nSeed)

	func SomeNumbersBetweenXT(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXT(nMin, nMax, nSeed)

	func AnyRandomNumbersBetweenXT(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXT(nMin, nMax, nSeed)

	func AnyNumbersBetweenXT(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXT(nMin, nMax, nSeed)

	#--

	func RandomNumbersBetweenXT(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXT(nMin, nMax, nSeed)

	#>

func SomeRandomNumbersInXTZ(panNumbers, nSeed)
	StzSRandom(nSeed)
	return SomeRandomNumbersInZ(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXTZ(panNumbers, nSeed)
		return SomeRandomNumbersInXTZ(panNumbers, nSeed)

	func AnyRandomNumbersInXTZ(panNumbers, nSeed)
		return SomeRandomNumbersInXTZ(panNumbers, nSeed)

	func AnyNumbersInXTZ(panNumbers, nSeed)
		return SomeRandomNumbersInXTZ(panNumbers, nSeed)

	#--

	func RandomNumbersInXTZ(panNumbers, nSeed)
		return SomeRandomNumbersInXTZ(panNumbers, nSeed)

	#==

	func SomeNumbersFromXTZ(panNumbers, nSeed)
		return SomeRandomNumbersInXTZ(panNumbers, nSeed)

	func AnyRandomNumbersFromXTZ(panNumbers, nSeed)
		return SomeRandomNumbersInXTZ(panNumbers, nSeed)

	func AnyNumbersFromXTZ(panNumbers, nSeed)
		return SomeRandomNumbersInXTZ(panNumbers, nSeed)

	#--

	func RandomNumbersFromXTZ(panNumbers, nSeed)
		return SomeRandomNumbersInXTZ(panNumbers, nSeed)

	#==

	func SomeRandomNumbersBetweenXTZ(nMin, nMax, nSeed)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersInXTZ(nMin : nMax, nSeed)

	func SomeNumbersBetweenXTZ(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTZ(nMin, nMax, nSeed)

	func AnyRandomNumbersBetweenXTZ(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTZ(nMin, nMax, nSeed)

	func AnyNumbersBetweenXTZ(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTZ(nMin, nMax, nSeed)

	#--

	func RandomNumbersBetweenXTZ(nMin, nMax, nSeed)
		return SomeRandomNumbersBteweenXTZ(nMin, nMax, nSeed)

	#>

#==

func SomeRandomNumbersInU(panNumbers)
	if CheckingParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	n = floor( len(panNumbers) * _Some() )
	return NRandomNumbersInU(n, panNumbers)

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

	func SomeRandomNumbersBetweenU(nMin, nMax)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok
		return SomeRandomNumbersInU(nMin : nMax)

	func SomeNumbersBetweenU(nMin, nMax)
		return SomeRandomNumbersBetweenU(nMin, nMax)

	func AnyRandomNumbersBetweenU(nMin, nMax)
		return SomeRandomNumbersBetweenU(nMin, nMax)

	func AnyNumbersBetweenU(nMin, nMax)
		return SomeRandomNumbersBetweenU(nMin, nMax)

	#--

	func UniqueRandomNumbersBetween(nMin, nMax)
		return SomeRandomNumbersBetweenU(nMin, nMax)

	func SomeUniqueNumbersBetween(nMin, nMax)
		return SomeRandomNumbersBetweenU(nMin, nMax)

	#--

	func RandomNumbersBetweenU(nMin, nMax)
		return SomeRandomNumbersBetweenU(nMin, nMax)

	#>

func SomeRandomNumbersInUZ(panNumbers)
	if CheckingParams()
		if NOT ( isList(panNumbers) and IsListOfNumbers(panNumbers) )
			StzRaise("Incorrect param type! panNumbers.")
		ok
	ok

	n = floor( _Some() * len(panNumbers) )
	return NRandomNumbersInUZ(n, panNumbers)

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

	func RandomNumbersInUZ(nMin, nMax)
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

	func RandomNumbersFromUZ(nMin, nMax)
		return SomeRandomNumbersInUZ(panNumbers)

	#==

	func SomeRandomNumbersBetweenUZ(nMin, nMax)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok
		return SomeRandomNumbersInUZ(nMin : nMax)

	func SomeNumbersBetweenUZ(nMin, nMax)
		return SomeRandomNumbersBetweenUZ(nMin, nMax)

	func AnyRandomNumbersBetweenUZ(nMin, nMax)
		return SomeRandomNumbersBetweenUZ(nMin, nMax)

	func AnyNumbersBetweenUZ(nMin, nMax)
		return SomeRandomNumbersBetweenUZ(nMin, nMax)

	#--

	func UniqueRandomNumbersBetweenZ(nMin, nMax)
		return SomeRandomNumbersBetweenUZ(nMin, nMax)

	func SomeUniqueNumbersBetweenZ(nMin, nMax)
		return SomeRandomNumbersBetweenUZ(nMin, nMax)

	#--

	func RandomNumbersBetweenUZ(nMin, nMax)
		return SomeRandomNumbersBetweenUZ(nMin, nMax)

	#>

#==

func SomeRandomNumbersInXTU(panNumbers, nSeed)
	StzSRandom(nSeed)
	return SomeRandomNumbersInU(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXTU(panNumbers, nSeed)
		return SomeRandomNumbersInXTU(panNumbers, nSeed)

	func AnyRandomNumbersInXTU(panNumbers, nSeed)
		return SomeRandomNumbersInXTU(panNumbers, nSeed)

	func AnyNumbersInXTU(panNumbers, nSeed)
		return SomeRandomNumbersInXTU(panNumbers, nSeed)

	#--

	func UniqueRandomNumbersInXT(panNumbers, nSeed)
		return SomeRandomNumbersInXTU(panNumbers, nSeed)

	func SomeUniqueNumbersInXT(panNumbers, nSeed)
		return SomeRandomNumbersInXTU(panNumbers, nSeed)

	#--

	func RandomNumbersInXTU(panNumbers, nSeed)
		return SomeRandomNumbersInXTU(panNumbers, nSeed)

	#==

	func SomeRandomNumbersBetweenXTU(nMin, nMax, nSeed)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return SomeRandomNumbersInXTU(nMin : nMax)

	func SomeNumbersBetweenXTU(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTU(nMin, nMax, nSeed)

	func AnyRandomNumbersBetweenXTU(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTU(nMin, nMax, nSeed)

	func AnyNumbersBetweenXTU(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTU(nMin, nMax, nSeed)

	#--

	func UniqueRandomNumbersBetweenXT(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTU(nMin, nMax, nSeed)

	func SomeUniqueNumbersBetweenXT(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTU(nMin, nMax, nSeed)

	#--

	func RandomNumbersBetweenXTU(nMin, nMax, nSeed)
		return SomeRandomNumbersBetweenXTU(panNumbers, nSeed)

	#>

func SomeRandomNumbersInXTUZ(panNumbers, nSeed)
	StzSRandom(nSeed)
	return SomeRandomNumbersInUZ(panNumbers)

	#< @FunctionAlternativeForms

	func SomeNumbersInXTUZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	func AnyRandomNumbersInXTUZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	func AnyNumbersInXTUZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	#--

	func UniqueRandomNumbersInXTZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	func SomeUniqueNumbersInXTZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	#--

	func RandomNumbersInXTUZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	#==

	func RandomNumbersFromXTUZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	func SomeNumbersFromXTUZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	func AnyRandomNumbersFromXTUZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	func AnyNumbersFromXTUZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	#--

	func UniqueRandomNumbersFromXTZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	func SomeUniqueNumbersFromXTZ(panNumbers, nSeed)
		return RandomNumbersInXTUZ(panNumbers, nSeed)

	#==

	func SomeRandomNumbersBetweenXTUZ(nMin, nMax, nSeed)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return RandomNumbersInXTUZ(nMin : nMax)

	func SomeNumbersBetweenXTUZ(nMin, nMax, nSeed)
		return RandomNumbersBetweenXTUZ(nMin, nMax, nSeed)

	func AnyRandomNumbersBetweenXTUZ(nMin, nMax, nSeed)
		return RandomNumbersBetweenXTUZ(nMin, nMax, nSeed)

	func AnyNumbersBetweenXTUZ(nMin, nMax, nSeed)
		return RandomNumbersBetweenXTUZ(nMin, nMax, nSeed)

	#--

	func UniqueRandomNumbersBetweenXTZ(nMin, nMax, nSeed)
		return RandomNumbersBetweenXTUZ(nMin, nMax, nSeed)

	func SomeUniqueNumbersBetweenXTZ(nMin, nMax, nSeed)
		return RandomNumbersBetweenXTUZ(nMin, nMax, nSeed)

	#--

	func RandomNumbersBetweenXTUZ(nMin, nMax, nSeed)
		return RandomNumbersBetweenXTUZ(nMin, nMax, nSeed)

	#>

#== N RANDOM NUMBERS FROM A LIST OF NUMBERS

func NRandomNumbersIn(n, panNumbers)

	#NOTE: The same number can appear more than once
	# To avoid this, use the function with the ...U() extension

	nLen = len(panNumbers)

	anResult = []

	while _TRUE_
		nPos = ARandomNumberIn(1 : nLen)
		anResult + panNumbers[nPos]
		if len(anResult) = n
			exit
		ok
	end

	return anResult

	#< @FunctionAlternativeForms

	func RandomNNumbersIn(n, panNumbers)
		return NRandomNumbersIn(n, panNumbers)

	func AnyNNumbersIn(n, panNumbers)
		return NRandomNumbersIn(n, panNumbers)

	func NNumbersIn(n, panNumbers)
		return NRandomNumbersIn(n, panNumbers)

	#==

	func NRandomNumbersFrom(n, panNumbers)
		return NRandomNumbersIn(n, panNumbers)

	func RandomNNumbersFrom(n, panNumbers)
		return NRandomNumbersIn(n, panNumbers)

	func AnyNNumbersFrom(n, panNumbers)
		return NRandomNumbersIn(n, panNumbers)

	func NNumbersFrom(n, panNumbers)
		return NRandomNumbersIn(n, panNumbers)

	#==

	func NRandomNumbersBetween(n, nMin, nMax)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersIn(n, nMin:nMax)

	func RandomNNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetween(n, nMin, nMax)

	func AnyNNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetween(n, nMin, nMax)

	func NNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetween(n, nMin, nMax)

	#>

func NRandomNumbersInZ(n, panNumbers)

	nLen = len(panNumbers)
	nRandom = ARandomNumberIn(1 : nLen)

	anNumbers = []
	anPos = []

	while _TRUE_
		nPos = ARandomNumberIn(1 : nLen)
		anNumbers + panNumbers[nPos]
		anPos + nPos
		if len(anNumbers) = n
			exit
		ok
	end

	aResult = Association([ anNumbers, anPos ])

	return aResult

	#< @FunctionAlternativeForms

	func RandomNNumbersInZ(n, panNumbers)
		return NRandomNumbersInZ(n, panNumbers)

	func AnyNNumbersInZ(n, panNumbers)
		return NRandomNumbersInZ(n, panNumbers)

	func NNumbersInZ(n, panNumbers)
		return NRandomNumbersInZ(n, panNumbers)

	#==

	func NRandomNumbersFromZ(n, panNumbers)
		return NRandomNumbersInZ(n, panNumbers)

	func RandomNNumbersFromZ(n, panNumbers)
		return NRandomNumbersInZ(n, panNumbers)

	func AnyNNumbersFromZ(n, panNumbers)
		return NRandomNumbersInZ(n, panNumbers)

	func NNumbersFromZ(n, panNumbers)
		return NRandomNumbersInZ(n, panNumbers)

	#==

	func NRandomNumbersBetweenZ(n, nMin, nMax)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInZ(n, nMin:nMax)

	func RandomNNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenZ(n, nMin, nMax)

	func AnyNNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenZ(n, nMin, nMax)

	func NNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenZ(n, nMin, nMax)

	#>

#--

func NRandomNumbersInXT(n, panNumbers, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersIn(n, panNumbers)

	#< @FunctionAlternativeForms

	func RandomNNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXT(n, panNumbers, nSeed)

	func AnyNNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXT(n, panNumbers, nSeed)

	func NNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXT(n, panNumbers, nSeed)

	#==

	func NRandomNumbersFromXT(n, panNumbers, nSeed)
		return NRandomNumbersInXT(n, panNumbers, nSeed)

	func RandomNNumbersFromXT(n, panNumbers, nSeed)
		return NRandomNumbersInXT(n, panNumbers, nSeed)

	func AnyNNumbersFromXT(n, panNumbers, nSeed)
		return NRandomNumbersInXT(n, panNumbers, nSeed)

	func NNumbersFromXT(n, panNumbers, nSeed)
		return NRandomNumbersInXT(n, panNumbers, nSeed)

	#==

	func NRandomNumbersBetweenXT(n, nMin, nMax, nSeed)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInXT(n, nMin:nMax, nSeed)

	func RandomNNumbersBetwwenXT(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXT(n, nMin, nMax, nSeed)

	func AnyNNumbersBetweenXT(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXT(n, nMin, nMax, nSeed)

	func NNumbersBetweenXT(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXT(n, nMin, nMax, nSeed)

	#>

func NRandomNumbersInXTZ(n, panNumbers, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersInZ(n, panNumbers)

	#< @FunctionAlternativeForms

	func RandomNNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTZ(n, panNumbers, nSeed)

	func AnyNNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTZ(n, panNumbers, nSeed)

	func NNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTZ(n, panNumbers, nSeed)

	#==

	func NRandomNumbersFromXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTZ(n, panNumbers, nSeed)

	func RandomNNumbersFromXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTZ(n, panNumbers, nSeed)

	func AnyNNumbersFromXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTZ(n, panNumbers, nSeed)

	func NNumbersFromXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTZ(n, panNumbers, nSeed)

	#==

	func NRandomNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInXTZ(n, nMin:nMax, nSeed)

	func RandomNNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTZ(n, nMin, nMax, nSeed)

	func AnyNNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTZ(n, nMin, nMax, nSeed)

	func NNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTZ(n, nMin, nMax, nSeed)

	#>

#==

func NRandomNumbersInU(n, panNumbers)

	#NOTE: The generated numbers are guranteed to be unique

	anResult = []

	while _TRUE_

		nRandom = ARandomNumberIn(panNumbers)
		
		if ring_find(anResult, nRandom) = 0
			anResult + nRandom

			if len(anResult) = n
				exit
			ok
		ok
	end

	return anResult

	#< @FunctionAlternativeForms

	func RandomNNumbersInU(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func AnyNNumbersInU(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func NNumbersInU(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	#--

	func NUniqueRandomNumbersIn(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func UniqueNRandomNumbersIn(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func NUniqueNumbersIn(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func UniqueNNumbersIn(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	#==

	func RandomNNumbersFromU(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func AnyNNumbersFromU(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func NNumbersFromU(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	#--

	func NRandomNumbersFromU(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func NUniqueRandomNumbersFrom(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func UniqueNRandomNumbersFrom(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func NUniqueNumbersFrom(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	func UniqueNNumbersFrom(n, panNumbers)
		return NRandomNumbersInU(n, panNumbers)

	#==

	func NRandomNumbersBetweenU(n, nMin, nMax)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInU(n, nMin:nMax)

	func RandomNNumbersBetweenU(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	func AnyNNumbersBetweenU(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	func NNumbersBetweenU(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	#--

	func NUniqueRandomNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	func UniqueNRandomNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	func NUniqueNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	func UniqueNNumbersBetween(n, nMin, nMax)
		return NRandomNumbersBetweenU(n, nMin, nMax)

	#>

func NRandomNumbersInUZ(n, panNumbers)

	anNumbers = []
	anPos = []

	while _TRUE_

		anRandomZ = ARandomNumberInZ(panNumbers)
		
		if ring_find(anNumbers, anRandomZ[1]) = 0
			anNumbers + anRandomZ[1]
			anPos + anRandomZ[2]

			if len(anNumbers) = n
				exit
			ok
		ok
	end

	aResult = Association([ anNumbers, anPos ])

	return aResult

	#< @FunctionAlternativeForms

	func RandomNNumbersInUZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func AnyNNumbersInUZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func NNumbersInUZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	#--

	func NUniqueRandomNumbersInZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func UniqueNRandomNumbersInZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func NUniqueNumbersInZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func UniqueNNumbersInZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	#==

	func RandomNNumbersFromUZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func AnyNNumbersFromUZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func NNumbersFromUZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	#--

	func NRandomNumbersFromUZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func NUniqueRandomNumbersFromZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func UniqueNRandomNumbersFromZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func NUniqueNumbersFromZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	func UniqueNNumbersFromZ(n, panNumbers)
		return NRandomNumbersInUZ(n, panNumbers)

	#==

	func NRandomNumbersBetweenUZ(n, nMin, nMax)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInUZ(n, nMin:nMax)

	func RandomNNumbersBetweenUZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	func AnyNNumbersBetweenUZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	func NNumbersBetweenUZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	#--

	func NUniqueRandomNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	func UniqueNRandomNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	func NUniqueNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	func UniqueNNumbersBetweenZ(n, nMin, nMax)
		return NRandomNumbersBetweenUZ(n, nMin, nMax)

	#>

#--

func NRandomNumbersInXTU(n, panNumbers, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersInXTU(n, panNumbers)

	#< @FunctionAlternativeForms

	func RandomNNumbersInXTU(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func AnyNNumbersInXTU(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func NNumbersInXTU(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	#--

	func NUniqueRandomNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func UniqueNRandomNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func NUniqueNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func UniqueNNumbersInXT(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	#==

	func NRandomNumbersFromXTU(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func RandomNNumbersFromXTU(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func AnyNNumbersFromXTU(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func NNumbersFromXTU(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	#--

	func NUniqueRandomNumbersFromXT(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func UniqueNRandomNumbersFromXT(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func NUniqueNumbersFromXT(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	func UniqueNNumbersFromXT(n, panNumbers, nSeed)
		return NRandomNumbersInXTU(n, panNumbers, nSeed)

	#==

	func NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInXTU(n, nMin:nMax, nSeed)

	func RandomNNumbersBetweenXTU(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	func AnyNNumbersBetweenXTU(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	func NNumbersBetweenXTU(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	#--

	func NUniqueRandomNumbersBetweenXT(n, nMin, nMax, nSeed)
		returnNRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	func UniqueNRandomNumbersBetweenXT(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	func NUniqueNumbersBetweenXT(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	func UniqueNNumbersBetweenXT(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTU(n, nMin, nMax, nSeed)

	#>

func NRandomNumbersInXTUZ(n, panNumbers, nSeed)
	StzSRandom(nSeed)
	return NRandomNumbersInUZ(n, panNumbers)

	#< @FunctionAlternativeForms

	func RandomNNumbersInXTUZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func AnyNNumbersInXTUZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func NNumbersInXTUZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	#--

	func NUniqueRandomNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func UniqueNRandomNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func NUniqueNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func UniqueNNumbersInXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	#==

	func NRandomNumbersFromXTUZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func RandomNNumbersFromXTUZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func AnyNNumbersFromXTUZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func NNumbersFromXTUZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	#--

	func NUniqueRandomNumbersFromXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func UniqueNRandomNumbersFromXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func NUniqueNumbersFromXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	func UniqueNNumbersFromXTZ(n, panNumbers, nSeed)
		return NRandomNumbersInXTUZ(n, panNumbers, nSeed)

	#==

	func NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)
		if CheckingParams()
			if NOT @BothAreNumbers(nMin, nMax)
				StzRaise("Incorrect params types! nMin and nMax must be numbers.")
			ok
		ok

		return NRandomNumbersInXTUZ(n, nMin:nMax, nSeed)

	func RandomNNumbersBetweenXTUZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	func AnyNNumbersBetweenXTUZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	func NNumbersBetweenXTUZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	#--

	func NUniqueRandomNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	func UniqueNRandomNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	func NUniqueNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	func UniqueNNumbersBetweenXTZ(n, nMin, nMax, nSeed)
		return NRandomNumbersBetweenXTUZ(n, nMin, nMax, nSeed)

	#>

#==

func ARandomItemIn(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	nPos = ARandomNumberIn(1:len(paList))
	aResult = paList[nPos]

	return aResult

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

func NRandomItemsIn(n, paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	anPos = NRandomNumbersIn(n, 1:len(paList))
	nLen = len(anPos)

	aResult = []

	for i = 1 to nLen
		aResult + paList[anPos[i]]
	next

	return aResult

	func NItemsIn(n, paList)
		return NRandomItemsIn(n, paList)

	func NRandomItemsFrom(n, paList)
		return NRandomItemsIn(n, paList)

	func NItemsFrom(n, paList)
		return NRandomItemsIn(n, paList)

func NRandomItemsInU(n, paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	ok

	aResult = []

	while _TRUE_
		item = ARandomItemIn(paList)
		if ring_find(aResult, item) = 0
			aResult + item
			if len(aResult) = n
				exit
			ok
		ok
	end

	return aResult

	#< @FunctionAlternativeForms

	func NUniqueRandomItemsIn(n, paList)
		return NRandomItemsInU(n, paList)

	func NItemsInU(n, paList)
		return NRandomItemsInU(n, paList)

	func NUniqueItemsIn(n, paList)
		return NRandomItemsInU(n, paList)

	#--

	func NRandomItemsFromU(n, paList)
		return NRandomItemsInU(n, paList)

	func NUniqueRandomItemsFrom(n, paList)
		return NRandomItemsInU(n, paList)

	func NItemsFromU(n, paList)
		return NRandomItemsFromU(n, paList)

	func NUniqueItemsFrom(n, paList)
		return NRandomItemsFromU(n, paList)

	#>

func NPercentOf(n, p)
	if NOT IsNumberOrStringOrList(p)
		StzRaise("Incorrect param type! p must be number or string or list.")
	ok

	if isNumber(p)
		return p * n / 100

	but isList(p)
		nItems = ceil( len(p) * n / 100 )
		return NRandomItemsIn(nItems, p)

	but isString(p)
		oStr = new stzString(p)
		nLen = ceil( oStr.Size() * n / 100 )
		return oStr.FirstNChars(nLen)

	ok

	func NPercent(n, p)
		return NPercentOf(n, p)

func 1PercentOf(p)
	return NPercentOf(1, p)

	def OnePercentOf(p)
		return 1PercentOf(p)

	func 1Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 1PercentOf(p)

	def OnePercent(p)
		return 1Percent(p)

func 10PercentOf(p)
	return NPercentOf(10, p)

	func 10Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 10PercentOf(p)

func 20PercentOf(p)
	return NPercentOf(20, p)

	func 20Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 20PercentOf(p)

func 30PercentOf(p)
	return NPercentOf(30, p)

	func 30Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 30PercentOf(p)

func 40PercentOf(p)
	return NPercentOf(40, p)

	func 40Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 40PercentOf(p)

func 50PercentOf(p)
	return NPercentOf(50, p)

	func 50Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 50PercentOf(p)

func 60PercentOf(p)
	return NPercentOf(60, p)

	func 60Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 60PercentOf(p)

func 70PercentOf(p)
	return NPercentOf(70, p)

	func 70Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 70PercentOf(p)

func 80PercentOf(p)
	return NPercentOf(80, p)

	func 80Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 80PercentOf(p)

func 90PercentOf(p)
	return NPercentOf(90, p)

	func 90Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 90PercentOf(p)

func 100PercentOf(p)
	return p

	func 100Percent(p)
		if isList(p) and Q(p).IsOfNamedParam()
			p = p[2]
		ok
		return 100PercentOf(p)
