#------------------------------------------------------------#
#                                                            #
#   Class        : stzNumber                                 #
#   Description  : The class for managing softanza numbers   #
#   Version      : V0.9 (2019, 2025)                         #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)     #
#                                                            #
#============================================================#

/*
	This class expects you to provide it with a normal number or a
	number hosted in a string (if you want to be specific about
	how the number is formatted).

	Internally, the class stores the number always in a string.

	The string must must contain a number in decimal form.

	If the string is "" then the number is "0".

	Of course, the number must be calculable precisely by Ring 
	(read NOTE hereafter).

	If a type NUMBER is provided, then the class transforms it
	automatically to a string with the round that is active in
	the runtime by the current Ring code.

	This may generate a loss of precision like in the following example:

	o1 = new stzNumber(12.234)
	? o1.Content() #--> "12.23" # if the current round was left at its
				    # default Ring value or has been set
				    # explicitly to decimals(2)

	Therefore, if you want to force a precise round, (and that's why the
	class is made), you should provide a number in string like this:

	o1 = new stzNumber("12.234")
	? o1.Content() #--> "12.234"

	 NOTE
	------

	Double is a 64 bit IEEE 754 double precision Floating Point
	Number (1 bit for the sign, 11 bits for the exponent, and 52* bits
	for the value), _i_.e. double has 15 decimal digits of precision.
	
	Double range is '2.2250738585072014 E-308' to '1.7976931348623158 E+308'.
	Subsequently the size and length varies accordingly.
	It has nothing to do with the language one is using.
	
	<Ilir>
		+/-2.23 x 10-308 to +/-1.80 x 10 308
		
		Min and max numbers for a double type which Ring uses are
		+/-2.23 x 10-308 to +/-1.80 x 1030.
	
		Maximum of 15 digits are allowed.
		
		Of course, if you use a bignumber library, you are not
		limited, except numbers are only integers.
		
		Otherwise, max numbers without loosing precision are between
		2^53-1 = -4.503.599.627.370.496 to 4.503.599.627.370.495,
		numbers are exactly the integers , e.g. 2^52 (plus sign bit).
		
		From 2^53 to 2^54, everything is multiplied by 2, so numbers becomes even.
	</Ilir>

	GET INSPIRED:
	-------------
		- By Frink language (specialized in real world calculations):
		  --> https://frinklang.org/

*/

  ///////////////////
 ///   GLOBALS   ///
///////////////////
	
	_nDefaultRound = 2
	_nActiveRound = 2

	_nMaxRound = 14		# Ring says that the max round is 90. But actually
				# the most calculable number can't exceed 15 digits.
				# That's why, I will take 14 as a realistic maximum
				# round in Softanza.

				#TODO // Check this with Mahmoud and Ilir.

	StzDecimals(2)		# Softanza sets the number of round to 2 by default,
				# in confrmity with Ring defaults.

	# ── "CALCULABLE" IS A PRE-ENGINE CONCEPT, AND ITS PREMISE IS GONE ──
	#
	# These bounds were chosen before the Zig engine existed, to answer a question
	# that mattered enormously then: WILL RING COPE WITH THIS NUMBER? Every operation
	# went straight to a C double, so a 16-digit integer silently lost its low digits,
	# and refusing one up front was genuinely protective. 999_999_999_999_999 is a
	# deliberately safe under-estimate of Ring's 2^53, picked so that every 15-digit
	# integer is exactly representable.
	#
	# THE ENGINE CHANGED WHAT IS TRUE. stzNumber stores a STRING and dispatches to big
	# integers, exact scaled decimals, rationals, or f64 only where the operation is
	# inherently approximate. Measured today:
	#
	#     new stzNumber("99999999999999999999")   -- twenty digits
	#         .Content()          -> 99999999999999999999
	#         .IsExact()          -> TRUE
	#         .Representation()   -> biginteger
	#         .Add("1")           -> 100000000000000000000     EXACTLY
	#
	# where a double would answer 1e20 and lose the tail. So Softanza calculates far
	# beyond MaxCalculableNumber(), exactly, and the bound describes nothing it does.
	#
	# THE CONCEPT WAS ALSO ALREADY HOLLOW. Every check that bore the name had been
	# reduced to its plain twin -- RepresentsCalculableNumber() is RepresentsNumber(),
	# RepresentsCalculableInteger() is RepresentsInteger(), and so on -- and no code
	# anywhere enforced the bound. All that survived was the NAME, promising a
	# distinction that no longer existed, and two error messages telling users to
	# respect a limit nothing checked.
	#
	# WHAT REPLACED IT is the vocabulary phases 1-2 built for exactly this question:
	# IsExact(), WhyNotExact(), Representation(). "Is this calculable?" was the
	# pre-engine ancestor of "is this exact, and if not, why?" -- a better question,
	# because it is about the OPERATION rather than the magnitude.
	#
	# WHAT REMAINS TRUE, and is worth keeping, is the fact about RING ITSELF: a Ring
	# double is exact only up to 2^53. That is a real limit a caller may need to know
	# when handing a value to bare Ring arithmetic, and it is what RingMaxNumber()
	# ought to have meant all along. It is stated below at its true value.
	_cMaxCalculableInteger = "999_999_999_999_999"
	_nMaxNumberOfDigitsInUnsignedInteger = 15
	
	_cMaxCalculableRealNumber = "9_999_999_999_999.9"
	_nMaxNumberOfDigitsInUnsignedRealNumber = 14
	
	# 2^53 -- the largest integer a Ring double holds EXACTLY. Above it, n and n+1
	# can be the same value: (2^53 + 1) = 2^53 is TRUE in Ring.
	_cRingMaxExactInteger = "9007199254740992"
	
	_cMoneyNumberPrefix = "0m"

	_cNumberFractionalSeparator = "."

	_anDecimalDigits = 0:9

	_anOctalDigits = 0:7

	_anBinaryDigits = [0,1]


  //////////////////////
 ///    FUNCTIONS   ///
//////////////////////

# ── THE REGIME, NAMED WHERE THE VALUE IS BORN ───────────────────────────
#
# Scope-Oriented Programming M3 puts the frame at the call site. For rounding that
# meant the verb (RoundedToHalfEven). For the quantity itself it means the
# CONSTRUCTOR: you say what kind of number this is once, where it enters the
# program, and it carries that with it.
#
#   StzMoneyQ("19.99")        2 places, banker's rounding, always
#   StzExactQ("1/3")          refuses to become approximate -- raises instead
#   StzMeasuredQ("2.5", 3)    3 places, banker's -- approximate by nature
#   StzNumberQ(2.5)           unchanged: the machine regime, today's behaviour
#
# The regime PROPAGATES: the receiver's regime governs the result, so a price
# plus anything is still a price, rounded and stored as one.

#@ aka  a price, an amount, currency, money
func StzMoneyQ(pValue)
	_o_ = new stzNumber(pValue)
	_o_.SetRegime(:money, 2)
	return _o_

	func StzMoney(pValue)
		return StzMoneyQ(pValue)

#@ aka  must be exact, no approximation, refuse rounding
func StzExactQ(pValue)
	_o_ = new stzNumber(pValue)
	_o_.SetRegime(:exact, 0)
	return _o_

	func StzExactNumber(pValue)
		return StzExactQ(pValue)

#@ aka  a measurement, significant places, approximate by nature
func StzMeasuredQ(pValue, pnPlaces)
	_o_ = new stzNumber(pValue)
	_o_.SetRegime(:measured, pnPlaces)
	return _o_

	func StzMeasured(pValue, pnPlaces)
		return StzMeasuredQ(pValue, pnPlaces)

func StzNumberQ(_cNumber_)
	return new stzNumber(_cNumber_)

func StzNamedNumber(paNamed)
	if CheckingParams()

	ok

	_oNumber_ = new stzNumber(paNamed[2])
	_oNumber_.SetName(paNamed[1])
	return _oNumber_

	func StzNamedNumberQ(paNamed)
		return StzNamedNumber(paNamed)

	func StzNamedNumberXTQ(paNamed)
		return StzNamedNumber(paNamed)

func Numberify(p)
	return Q(p).Numberified()

func StzNumberMethods()
	return Stz(:Number, :Methods)

func stzNumberAttributes()
	return Stz(:Number, :Attributes)

func StzNumberClass()
	return "stznumber"

	func StzNumberClassName()
		return StzNumberClass()

func Digits()
	return 0:9

func IsBoolean(n)
	if isNumber(n) and
	   (n = 0 or n = 1)

		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsBooleanNumber(n)
		return IsBoolean(n)

	func NumberIsBoolean(n)
		return IsBoolean(n)

	func IsABoolean(n)
		return IsBoolean(n)

	func IsABooleanNumber(n)
		return IsBoolean(n)

	func NumberIsABoolean(n)
		return IsBoolean(n)

	#--

	func @IsBoolean(n)
		return IsBoolean(n)

	func @IsBooleanNumber(n)
		return IsBoolean(n)

	func @NumberIsBoolean(n)
		return IsBoolean(n)

	func @IsABoolean(n)
		return IsBoolean(n)

	func @IsABooleanNumber(n)
		return IsBoolean(n)

	func @NumberIsABoolean(n)
		return IsBoolean(n)

	#--

	def IsLogical(n)
		return IsBoolean(n)
	#>

func MaxNumberOfDigitsInUnsignedInteger()
	return _nMaxNumberOfDigitsInUnsignedInteger
	
func MaxNumberOfDigitsInSignedInteger()
	return MaxNumberOfDigitsInUnsignedInteger() - 1
	
func MaxNumberOfDigitsInUnsignedRealNumber()
	return _nMaxNumberOfDigitsInUnsignedRealNumber
	
func MaxNumberOfDigitsInSignedRealNumber()
	return MaxNumberOfDigitsInUnsignedRealNumber() - 1
	
# THE LARGEST INTEGER RING ITSELF HOLDS EXACTLY: 2^53 = 9007199254740992.
#
# This is the honest name for the only part of the old "calculable" idea that is
# still true. Softanza is NOT bounded by it -- see the note on the constants above,
# and IsExact() / Representation() for the question that replaced it. Use this when
# you are about to hand a value to BARE RING arithmetic and need to know whether Ring
# will keep every digit.
func RingMaxExactInteger()
	return 0 + _cRingMaxExactInteger

	func RingMinExactInteger()
		return -1 * RingMaxExactInteger()

# RETIRED NAME, kept because it is published surface. It used to answer
# 999_999_999_999_999, which was wrong for both readings of its name: Softanza is not
# bounded at all, and Ring's own limit is 2^53 -- nine times larger. It now tells the
# truth about Ring, which is what RingMaxNumber() (its long-standing alias) always
# implied. Nothing in the library ever enforced the old value; it appeared only in two
# error messages, both of which now say something accurate instead.
func MaxCalculableNumber()
	return RingMaxExactInteger()
	# The removed body used to strip the "_" separators out of the constant with a
	# whole stzString, because `0 + "999_999_999_999_999"` answers 999 in Ring -- it
	# stops at the first non-digit. The constant above carries no separators, so the
	# bare `0 +` is safe there; the readable form with separators is the XT twin below.

	func RingMaxNumber()
		return MaxCalculableNumber()

	func MaxRingNumber()
		return MaxCalculableNumber()

//	func MaxNumber()
//		return MaxCalculableNumber()

	func MaxNumberInRing()
		return MaxCalculableNumber()

	func GreatestNumber()
		return MaxCalculableNumber()

	func GreatestNumberInRing()
		return MaxCalculableNumber()

	func LargestNumber()
		return MaxCalculableNumber()

	func LargestNumberInRing()
		return MaxCalculableNumber()

	#--

	# the same limit as a readable literal
	func MaxCalculableNumberXT()
		return "9_007_199_254_740_992"

	func RingMaxNumberXT()
		return MaxCalculableNumberXT()

	func MaxRingNumberXT()
		return MaxCalculableNumberXT()

func MinCalculableNumber()
	return -1 * MaxCalculableNumber()
		
	func RingMinNumber()
		return MinCalculableNumber()

	func MinRingNumber()
		return MinCalculableNumber()

	func MinNumberInRing()
		return MinCalculableNumber()

	func SmallestRingNumber()
		return MinCalculableNumber()

	func RingSmallestNumber()
		return MinCalculableNumber()

	func SmallestNumberInRing()
		return MinCalculableNumber()

//	func MinNumber()
//		return MinCalculableNumber()

	func SmallestNumber()
		return MinCalculableNumber()

	#--

	func MinCalculableNumberXT()
		return "-" + MaxCalculableNumberXT()

	func SmallestCalculableNumberXT()
		return MinCalculableNumberXT()

	func CalculableMinNumberXT()
		return MinCalculableNumberXT()

	func CalculableSmallestNumberXT()
		return "-" + _cMaxCalculableInteger

	func RingMinNumberXT()
		return MinCalculableNumberXT()

	func MinRingNumberXT()
		return MinCalculableNumberXT()

func MaxCalculableInteger()
	return MaxCalculableNumber()
		
	#< @FunctionAlternativeForms
 
	func RingMaxInteger()
		return MaxCalculableInteger()

	func MaxRingInteger()
		return MaxCalculableInteger()

	func RingLargestInteger()
		return MaxCalculableInteger()

	func RingGreatestInteger()
		return MaxCalculableInteger()

	func LargestRingInteger()
		return MaxCalculableInteger()

	func GreatestRingInteger()
		return MaxCalculableInteger()

	#--

	func MaxCalculableIntegerXT()
		return _cMaxCalculableInteger

	func RingMaxIntegerXT()
		return MaxCalculableIntegerXT()

	func MaxRingIntegerXT()
		return MaxCalculableIntegerXT()

	func RingLargestIntegerXT()
		return MaxCalculableIntegerXT()

	func RingGreatestIntegerXT()
		return MaxCalculableIntegerXT()

	func LargestRingIntegerXT()
		return MaxCalculableIntegerXT()

	func GreatestRingIntegerXT()
		return MaxCalculableIntegerXT()
	
	#>

func MinCalculableInteger()
	return MinCalculableNumber()
		
	#< @FunctionAlternativeForms

	func RingMinInteger()
		return MinCalculableInteger()

	func MinRingInteger()
		return MinCalculableInteger()

	func RingSmallestInteger()
		return MinCalculableInteger()

	func SmallestRingInteger()
		return MinCalculableInteger()

	#--

	func MinCalculableIntegerXT()
		return "-" + _cMaxCalculableInteger

	func RingMinIntegerXT()
		return MinCalculableIntegerXT()

	func MinRingIntegerXT()
		return MinCalculableIntegerXT()

	func RingSmallestIntegerXT()
		return MinCalculableIntegerXT()

	func SmallestRingIntegerXT()
		return MinCalculableIntegerXT()

	#>

func MaxCalculableRealNumber()
	_oStr_ = new stzString(_cMaxCalculableRealNumber)
	_cMax_ - "_"
	_cMax_ = _oStr_.Content()

	return 0+ _cMax_

	#< @FunctionAlternativeForms

	func GreatestCalculableRealNumber()
		return MaxCalculableRealNumber()

	func LargestCalculableRealNumber()
		return MaxCalculableRealNumber()

	func RingMaxRealNumber()
		return MaxCalculableRealNumber()

	func RingGreatestRealNumber()
		return MaxCalculableRealNumber()

	func RingLargestRealNumber()
		return MaxCalculableRealNumber()

	#--

	func MaxCalculableRealNumberXT()
		return _cMaxCalculableRealNumber

	func GreatestCalculableRealNumberXT()
		return MaxCalculableRealNumberXT()

	func LargestCalculableRealNumberXT()
		return MaxCalculableRealNumberXT()

	func RingMaxRealNumberXT()
		return MaxCalculableRealNumberXT()

	func RingGreatestRealNumberXT()
		return MaxCalculableRealNumberXT()

	func RingLargestRealNumberXT()
		return MaxCalculableRealNumberXT()

	#>
		
func MinCalculableRealNumber()
	return -1 * MaxCalculableRealNumber()
	
	#< @FunctionAlternativeForms

	func SmallestCalculableRealNumber()
		return MinCalculableRealNumber()

	func RingMinRealNumber()
		return MinCalculableRealNumber()

	#--

	func MinCalculableRealNumberXT()
		return "-" + _cMaxCalculableRealNumber

	func RingMinRealNumberXT()
		return MinCalculableRealNumberXT()

	func RingSmallestRealNumberXT()
		return MinCalculableRealNumberXT()

	#>

func MoneyNumberPrefix()
	return _cMoneyNumberPrefix

	#< @FunctionAlternativeForm

	func MoneyPrefix()
		return MoneyNumberPrefix()

	#>

func DefaultFractionalSeparator()
	return _cNumberFractionalSeparator

	func DefaultDecimalSeparator()
		return This.DefaultFractionalSeparator()
	
	#-- @Misspelled

	func DefaultFractionalSeperator()
		return DefaultFractionalSeparator()

	func DefaultDecimalSeperator()
		return This.DefaultFractionalSeparator()


func StringRepresentsInteger(_cNumber_)
	_oStr_ = new stzString(_cNumber_)
	return _oStr_.RepresentsInteger()

func StringRepresentsCalculableNumber(_cNumber_)
	_oStr_ = new stzString(_cNumber_)
	return _oStr_.RepresentsCalculableNumber()
			
func StringRepresentsRealNumber(_cNumber_)
	_oStr_ = new stzString(_cNumber_)
	return _oStr_.RepresentsRealNumber()

func StringRepresentsSignedNumber(_cNumber_)
	_oStr_ = new stzString(_cNumber_)
	return _oStr_.RepresentsSignedNumber()

/*func IsInteger(n)
	if isNumber(n) and Q(n).IsInteger()
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func @IsInteger(n)
		return IsInteger(n)
*/
	func IsAnInteger(n)
		return IsInteger(n)

	func @IsAnInteger(n)
		return IsInteger(n)

	#>

func IsReal(n)
	if isNumber(n) and Q(n).IsReal()
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsRealNumber(n)
		return IsReal(n)

	func @IsReal(n)
		return IsReal(n)

	func @IsRealNumber(n)
		return IsReal(n)

	#--

	func IsAReal(n)
		return IsReal(n)

	func IsARealNumber(n)
		return IsReal(n)

	func @IsAReal(n)
		return IsReal(n)

	func @IsARealNumber(n)
		return IsReal(n)

	#>

func IsBit(n)
	if NOT isNumber(n)
		StzRaise("Incorrect param! n must be a number!")
	ok

	if n = 0 or n = 1
		return 1
	else
		return 0

	ok

	#< @FunctionAlternativeForms

	func IsABit(n)
		return IsBit(n)

	func @IsBit(n)
		return IsBit(n)

	func @IsABit(n)
		return IsBit(n)

	#>

func IsRGBColor(anColor)
	if CheckParams() and NOT IsListOfNumbers(anColor)
		StzRaise("Incorrect param type! anColor must be a list of numbers")

	ok

	if len(anColor) != 3
		StzRaise("Incorrect param value! anColor must contain 3 numbers.")
	ok

	for _i_ = 1 to 3
		# sigil'd: a bare `n` here BINDS a caller's global of that name
		# (the global-capture trap) instead of making a local
		_n_ = anColor[_i_]

		if _n_ != floor(_n_)
			return 0
		ok

		if _n_ < 0 or _n_ > 255
			return 0
		ok
	next

	return 1

	func @IsRGBColor(anColor)
		return IsRGBColor(anColor)

	func IsRGB(anColor)
		return IsRGBColor(anColor)

	func @IsRGB(anColor)
		return IsRGBColor(anColor)


func DecimalDigits()
	return _anDecimalDigits

func OctalDigits()
	return _anOctalDigits

func Double(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok
			
	return n * 2

	func DoubleOf(n)
		if isNumber(n)
			return Double(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

	/* TODO

	Allow providing n in a string to preserver round:

	Double("23.124") --> "46.248"

	*/

func Triple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok
			
	return n * 3

	func TripleOf(n)		
		if isNumber(n)
			return Triple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Quadruple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 4

	func QuadrupleOf(n)
		if isNumber(n)
			return Quadruple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Quintuple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 5

	func QuintupleOf(n)
		if isNumber(n)
			return Quintuple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Sextuple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 6

	func SextupleOf(n)
		if isNumber(n)
			return Sextuple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Septuple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 7

	func SeptupleOf(n)
		if isNumber(n)
			return Septuple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Octuple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 8

	func OctupleOf(n)
		if isNumber(n)
			return Octuple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Nonuple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 9

	func NonupleOf(n)
		if isNumber(n)
			return Nonuple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok

func Decuple(n)
	if isList(n) and IsOfNamedParamList(n)
		n = n[2]
	ok

	return n * 10
	
	func DecoupleOf(n)
		if isNumber(n)
			return Decuple(n)

		else
			StzRaise("Invalid param type! n must be a number.")

		ok
	
//func Abs(n)
//	return fabs(n)

func OddOrEven(n)
	if isList(n)
		if ListIsOdd(n)
			return :Odd
		else
			return :Even
		ok
	ok

	if NOT isNumber(n)
		StzRaise("Incorrect param type! n must be a number.")
	ok

	if n % 2 = 0
		return :Even
	else
		return :Odd
	ok

/*func IsEven(n)
	if isList(n)
		return IsEvenList(n)
	ok

	return n % 2 = 0

	func @IsEven(n)
		return IsEven(n)
*/
	func IsZawji(n)
		return IsEven(n)

	func @IsZawji(n)
		return IsEven(n)

/*func IsOdd(n)
	if isList(n)
		return IsOddList(n)
	ok

	return n % 2 != 0

	func @IsOdd(n)
		return IsOdd(n)
*/
	func IsFardi(n)
		return IsOdd(n)

	func @IsFardi(n)
		return IsOdd(n)

#---- ROUNDS

func MaxRingRound()
	return _nMaxRound

	func RingMaxRound()
		 return MaxRingRound()

//	func MaxRound()
//		return MaxRingRound()

	func MaxRoundInRing()
		return MaxRingRound()

func DefaultRound()
	return _nDefaultRound

	func StzDefaultRound()
		return DefaultRound()

	func InitialRound()
		return DefaultRound()

	func StzInitialRound()
		return DefaultRound()

func StzResetRound()
	SetActiveRound(_nDefaultRound)

	func ResetRound()
		StzResetRound()

func SetActiveRound(n)
	if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
	ok

	if NOT ( n >= 0 and n <= MaxRoundInRing() )
		StzRaise("Incorrect value! n must be in the range 1 to " + MaxRoundInRing() + ".")
	ok

	_nActiveRound = n
	decimals(n)

	func StzDecimals(n)
		SetActiveRound(n)

	func SetStzRound(n)
		SetActiveRound(n)

	func SetRound(n)
		SetActiveRound(n)
	
func StzRound(p) # TODO use Round() from SoftanzaCore

	if isList(p) and IsPair(p)
		if isList(p[2]) and Q(p[2]).IsToNamedParam()
			p[2] = p[2][2]
		ok

		_nNumber_ = p[1]
		_nRound_ = p[2]
	else
		_nNumber_ = p
		_nRound_ = CurrentRound()
	ok


	return StzNumberQ(_nNumber_).RoundedTo(_nRound_)

func RoundN(_nNumber_, _nRound_)
	return StzNumberQ(_nNumber_).RoundedTo(_nRound_)

func StzRoundXT(p)
	if isList(p) and IsPair(p)
		if isList(p[2]) and Q(p[2]).IsToNamedParam()
			p[2] = p[2][2]
		ok

		_nNumber_ = p[1]
		_nRound_ = p[2]
	else
		_nNumber_ = p
		_nRound_ = CurrentRound()
	ok

	return StzNumberQ(_nNumber_).RoundedToXT(_nRound_)

	func RoundXT(p)
		return StzRoundXT(p)

# Getting the active round inforced by the last use of
# the ring StzDecimals() function in the program

func GetActiveRound()
	return _nActiveRound

	#< @FunctionAlternativeForms

	func ActiveRound()
		return GetActiveRound()

	func StzGetActiveRound()
		return GetActiveRound()

	func StzActiveRound()
		return GetActiveRound()

	#--

	func StzGetCurrentRound()
		return GetActiveRound()

	func StzCurrentRound()
		return GetActiveRound()

	#>
	
func NumberIsCalculable(_nNumber_)
	if CheckingParams()
		if NOT isString(_nNumber_)
			StzRaise("Incorrect param type! nNumber must be a number.")
		ok
	ok

	_oStr_ = new stzString(""+ _nNumber_)
	return _oStr_.RepresentsCalculableNumber()


func StringToNumber(_cNumber_) # TESTING IN PROGESS
	if isNumber(_cNumber_)
		return _cNumber_
	ok

	if NOt isString(_cNumber_)
		StzRaise("Incorrect param type! cNumber must be a string.")
	ok

	# Deletig unnecessary spaces

	# StzTrimString, not Q(...).Trimmed(): the wrapper builds a stzString whose
	# engine handle Ring never gives back (see the note in stzNumber's init). The
	# global frees its own handles and answers the same string.
	_cNumber_ = StzTrimString(_cNumber_)
	if _cNumber_ = ""
		_cNumber_ = "0"
	ok

	# Setting the decimal number depending on the form provided

	if StringRepresentsNumberInDecimalForm(_cNumber_)

		_oNumber_ = new stzNumber(_cNumber_)
		return _oNumber_.NumericValue()
			
	but StringRepresentsNumberInBinaryForm(_cNumber_)

		_oBinNumber_ = new stzBinaryNumber(_cNumber_)
		return _oBinNumber_.ToStzNumber().NumericValue()

	but StringRepresentsNumberInHexForm(_cNumber_)
		_oHexNumber_ = new stzHexNumber(_cNumber_)
		return _oHexNumber_.ToStzNumber().NumericValue()

	but StringRepresentsNumberInOctalForm(_cNumber_)
		_oOctNumber_ = new stzOctalNumber(_cNumber_)
		return _oOctNumber_.ToStzNumber().NumericValue()

	but StringRepresentsNumberInScientificNotation(_cNumber_)
		// TODO
		StzRaise("Feature not implemented yet!")
	other
		StzRaise(stzNumberError(:UnsupportedNumberForm))
	ok

	#< @FunctionAlternativeForms

	func ToNumber(_cNumber_)
		return StringToNumber(_cNumber_)

	func @ToNumber(_cNumber_)
		return StringToNumber(_cNumber_)

	func String2Number(_cNumber_)
		return StringToNumber(_cNumber_)

	func StrToNbr(_cNumber_)
		return StringToNumber(_cNumber_)

	func Str2Nbr(_cNumber_)
		return StringToNumber(_cNumber_)

	#>

func NumberToString(n)
	if CheckingParams()
		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok
	ok

	return ""+ n

	#< @FunctionAlternativeForms

	func ToString(n)
		return NumberToString(n)

	func @ToString(n)
		return NumberToString(n)

	func Number2String(n)
		return NumberToString(n)

	func NbrToStr(n)
		return NumberToString(n)

	func Nbr2Str(n)
		return NumberToString(n)

	#>

# Decimal form

func StringRepresentsNumberInDecimalForm(pcNumber)
	if CheckingParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	_pH_ = StzEngineString(pcNumber)
	_nResult_ = StzEngineStringIsNumericString(_pH_)
	if _nResult_ = 0
		_nResult_ = StzEngineStringIsFloat(_pH_)
	ok
	StzEngineStringFree(_pH_)
	return _nResult_

func CharIsDigit(c)
	return isDigit(c) # It's a native ring function

# Binary form

func StringRepresentsNumberInBinaryform(pcNumber)
	if CheckingParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	_pH_ = StzEngineString(pcNumber)
	_nResult_ = StzEngineStringIsBinaryString(_pH_)
	StzEngineStringFree(_pH_)
	return _nResult_

# Hex form

func StringRepresentsNumberInHexForm(pcNumber)
	if CheckingParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	_pH_ = StzEngineString(pcNumber)
	_nResult_ = StzEngineStringIsHexString(_pH_)
	StzEngineStringFree(_pH_)
	return _nResult_

func StringRepresentsNumberInUnicodeHexForm(pcNumber)
	if CheckingParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	if StzLen(pcNumber) < 3
		return 0
	ok
	_cPrefix_ = StzUpper(StzLeft(pcNumber, 2))
	if _cPrefix_ != "U+"
		return 0
	ok
	_cHexPart_ = StzRight(pcNumber, StzLen(pcNumber) - 2)
	return StringRepresentsNumberInHexForm("0x" + _cHexPart_)

# Octal form

func StringRepresentsNumberInOctalForm(pcNumber)
	if CheckingParams()
		if NOT isString(pcNumber)
			StzRaise("Incorrect param type! pcNumber must be a string.")
		ok
	ok

	_pH_ = StzEngineString(pcNumber)
	_nResult_ = StzEngineStringIsOctalString(_pH_)
	StzEngineStringFree(_pH_)
	return _nResult_

# Scientific notation form

func StringRepresentsNumberInScientificNotation(pNumber)
	// TODO
	StzRaise("Feature not implemented yet!")

# Takes a number of 3 digits and returns the following hashlist:
# [ :Units = ..., :Dozens = ..., :Hundreds = ... ]
func GetUnitsDozensAndHundreds(pNumber)	// Or simplier : GetMicroStructure(pNumber)
	#WARNING: We rely on Ring native functions (len, right, left, substr)
	# In principle this is correct, since the number string contains only digits and some
	# other ascii symbols (like "." and "," separators, and "+" and "-" signs).

	pcNumber = "" + pNumber
		
	// Ensuring the number provided doesn't exceed 3 digits
	if StzLen(pcNumber) > 3
		// Considering the case where the number is preceeded by a + or - sign
		// --> In This case, the sign is simply ignored
		if StzLen(pcNumber)=4 and
		   ( StzLeft(pcNumber,1) = "+" or
		     StzLeft(pcNumber,1) = "-")

			pcNumber = pcNumber[2] + pcNumber[3] + pcNumber[4]
		else
			StzRaise("Can't proceed! The length of the number should not exceed 3.")
		ok
	ok

	// Constructing the microstructure of the number (units, dozens, and hundreds)
	_cUnits_ = "0"
	_cDozens_ = "0"
	_cHundreds_ = "0"
	
	switch StzLen(pcNumber)
	on 1
		_cUnits_ = pcNumber

	on 2
		_cUnits_ = StzRight(pcNumber,1)
		_cDozens_ = StzLeft(pcNumber,1)

	on 3
		_cUnits_ = StzRight(pcNumber,1)
		# FIXED 2026-07-25: was Section(2, 1) -- a BACKWARDS range, which returns
		# "23" of "234" instead of the middle digit "3". The dozens of a 3-digit
		# group is one character, at position 2. It stayed hidden while the groups
		# themselves were wrong (see _StzDigitGroupsOfThree); correcting the grouping
		# is what made a real 3-digit group reach this line.
		_cDozens_ = StzStringQ(pcNumber).Section(2, 2)
		_cHundreds_ = StzLeft(pcNumber,1)
	off

	return [ :Units = _cUnits_, :Dozens = _cDozens_, :Hundreds = _cHundreds_ ]

func GetMicroStructure(pNumber)
	return GetUnitsDozensAndHundreds(pNumber)

func ZeroIfEmpty(pcStr)
	if isEmpty(pcStr)
		return ""
	ok

func Derivative(pFunction)
	_nTemp_ = call pFunction(_n1_)
	return _nTemp_ * (1 - _nTemp_)
		
func NumberIsDividorOf(pNumber,pOf)
	_oStzNumber_ = new stzNumber(pNumber)
	return _oStzNumber_.IsDividorOf(pOf)

func NumberIsDividableBy(pNumber, pBy)
	_oStzNumber_ = new stzNumber(pNumber)
	return _oStzNumber_.IsDividableBy(pBy)

func NumberConvert(pNumber, pcFrom, pcTo)
	pcNumber = ""+ pNumber

	switch pcFrom
	on :FromDecimalForm
		if NOT StringRepresentsNumberInDecimalForm(pcNumber)
			StzRaise(stzNumberError(:CanNotConvertNumberFromDecimalInThisForm))
		ok

		_oStzNumber_ = new stzNumber(pcNumber)
		switch pcTo
		on :ToDecimalForm
			return pcNumber
		on :ToBinaryForm
			return _oStzNumber_.ToBinaryForm()
		on :ToHexform
			return _oStzNumber_.ToHexForm()

		on :ToUnicodeHexForm
			return _oStzNumber_.ToUnicodeHexForm()

		on :ToOctalForm
			return _oStzNumber_.ToOctalForm()
		other
			StzRaise(stzNumberError(:UnsupportedNumberConversionTargetForm1))
		off

	on :FromBinaryForm
		if NOT NumberIsInBinaryForm(pcNumber)
			StzRaise(stzNumberError(:CanNotConvertNumberFromBinaryInThisForm))
		ok

		_oBinNumber_ = new stzBinaryNumber(pcNumber)

		switch pcTo
		on :ToDecimalForm
			return _oBinNumber_.ToDecimalForm()
		on :ToBinaryForm
			return pcNumber
		on :ToHexForm
			return _oBinNumber_.ToHexForm()

		on :ToUnicodeHexForm
			return _oBinNumber_.ToUnicodeHexForm()

		on :ToOctalForm
			return _oBinNumber_.ToOctalForm()
		other
			StzRaise(stzNumberError(:UnsupportedNumberConversionTargetForm))
		off

	on :FromHexForm
		if NOT StringContainsNumberInHexForm(pcNumber)
			StzRaise(stzNumberError(:CanNotConvertNumberFromHexInThisForm))
		ok

		_oHexNumber_ = new stzHexNumber(pcNumber)
		switch pcTo
		on :ToDecimalForm
			return _oHexNumber_.ToDecimalForm()
		on :ToBinaryForm
			return _oHexNumber_.ToBinaryForm()
		on :ToHexForm
			return pcNumber

		on :ToUnicodeHexForm
			return _oHexNumber_.ToUnicodeHexNumber()

		on :ToOctalForm
			return _oHexNumber_.ToOctalForm()
		other
			StzRaise(stzNumberError(:UnsupportedNumberConversionTargetForm))
		off

	on :FromOctalForm
		if NOT NumberIsInOctalForm(pcNumber)
			StzRaise(stzNumberError(:CanNotConvertNumberFromOctalInThisForm))
		ok

		_oOctalNumber_ = new stzOctalNumber(pcNumber)

		switch pcTo
		on :ToDecimalForm
			return _oOctalNumber_.ToDecimalForm()

		on :ToBinaryForm
			return _oOctalNumber_.ToBinaryForm()

		on :ToHexForm
			return _oOctalNumber_.ToHexForm()

		on :ToUnicodeHexForm
			return _oOctalNumber_.ToUnicodeHexForm()

		on :ToOctalForm
			return pcNumber

		other
			StzRaise(stzNumberError(:UnsupportedNumberConversionTargetForm))
		off

	other
		StzRaise(stzNumberError(:UnsupportedNumberConversionSourceForm))
	off
		
func NumberIsEven(n)
	return StzNumberQ(n).IsEven()

func NumberIsOdd(n)
	return StzNumberQ(n).IsOdd()

func DecimalToHex(n)
	return NumberConvert(n, :FromDecimalForm, :ToHexForm)

func DecimalToHexUnicode(n)
	return NumberConvert(n, :FromDecimalForm, :ToHexUnicodeForm)

#--

func BothArePositive(_n1_, _n2_)
	if BothAreNumbers(_n1_, _n2_) and _n1_ > 0 and _n2_ > 0
		return 1
	else
		return 0
	ok

func BothAreNegative(_n1_, _n2_)
	if BothAreNumbers(_n1_, _n2_) and _n1_ < 0 and _n2_ < 0
		return 1
	else
		return 0
	ok

func BothAreZeros(_n1_, _n2_)
	if BothAreNumbers(_n1_, _n2_) and _n1_ = 0 and _n2_ = 0
		return 1
	else
		return 0
	ok

func IsDecimalNumber(n)
	return isNumber(n)

	func @IsDecimalNumber(n)
		return IsDecimalNumber(n)

	func IsADecimalNumber(n)
		return IsDecimalNumber(n)

	func @IsADecimalNumber(n)
		return IsDecimalNumber(n)

func IsStzNumber(pObject)
	if isObject(pObject) and classname(pObject) = "stznumber"
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	def @IsStzNumber(pObject)
		return IsStzNumber(pObject)

	def IsAStzNumber(pObject)
		return IsStzNumber(pObject)

	def @IsAStzNumber(pObject)
		return IsStzNumber(pObject)

	#--

	def IsStzDecimalNumber(pObject)
		return IsStzNumber(pObject)

	def @IsStzDecimalNumber(pObject)
		return IsStzNumber(pObject)

	def IsAStzDecimalNumber(pObject)
		return IsStzNumber(pObject)

	def @IsAStzDecimalNumber(pObject)
		return IsStzNumber(pObject)

	#>

#---

func Add(p, value)
	if isNumber(p) or isString(p)
		p += value
	but isList(p)
		p + value
	else
		raise("Incorrect param type! p must be a number, string, or list.")
	ok

	return p

	func @Add(p, value)
		return p

#-- Generated by ClaudeAI, used bu stzGrid
func MostSquareLikeFactors(n)
	if n <= 0 return [0, 0] ok

	_bestA_ = 1
	_bestB_ = n
	_bestRatio_ = n

	for a = 1 to floor(sqrt(n))
		_b_ = ceil(n / a)
		_ratio_ = ring_max([ _b_ / a, a / _b_ ])

		if _ratio_ < _bestRatio_
			_bestRatio_ = _ratio_
			_bestA_ = a
			_bestB_ = _b_
		ok
	next

	return [_bestA_, _bestB_]

	#< @FunctionAlternativeForms

	func MSLF(n)
		return MostSquareLikeFactors(n)

	#--

	func @MostSquareLikeFactors(n)
		return MostSquareLikeFactors(n)

	func @MSLF(n)
		return MostSquareLikeFactors(n)

	#>

#NOTE The isWeiferich() function has been contributed
# to Softanza by Gal Calmosoft in his RosettaCode
# solution to tje Weiferich primes case made here:
# https://rosettacode.org/wiki/Wieferich_primes#Ring

func StzIsWeiferich(p)
	if not isPrime(p)
		return 0
	ok

	q = 1
	p2 = pow(p,2)

	while p > 1
		q = (2 * q) % p2
		p -= 1
	end

	if q = 1
		return 1
	else
		return 0
	ok

	func isWeiferich(p)
		return StzIsWeiferich(p)

	func @isWeiferich(p)
		return StzIsWeiferich(p)

#-- Percent functions

func NPercentOf(n, p)
	if NOT IsNumberOrStringOrList(p)
		StzRaise("Incorrect param type! p must be number or string or list.")
	ok

	if isNumber(p)
		return p * n / 100

	but isList(p)
		_nItems_ = ceil( len(p) * n / 100 )
		return NRandomItemsIn(_nItems_, p)

	but isString(p)
		_oStr_ = new stzString(p)
		_nLen_ = ceil( _oStr_.Size() * n / 100 )
		return _oStr_.FirstNChars(_nLen_)

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


  #=============================================#
 #  ENGINE-BACKED GLOBAL NUMBER FUNCTIONS      #
#=============================================#

func StzIsPrime(n)
	return StzEngineNumberIsPrime(n)

func StzGCD(_n1_, _n2_)
	return StzEngineNumberGcd(_n1_, _n2_)

func StzLCM(_n1_, _n2_)
	return StzEngineNumberLcm(_n1_, _n2_)

func StzFactorial(n)
	pBigInt = StzEngineNumberFactorial(n)
	_cResult_ = StzEngineBigIntToString(pBigInt)
	StzEngineBigIntFree(pBigInt)
	return _cResult_

func StzFibonacci(n)
	pBigInt = StzEngineNumberFibonacci(n)
	_cResult_ = StzEngineBigIntToString(pBigInt)
	StzEngineBigIntFree(pBigInt)
	return _cResult_

func StzIsPerfectNumber(n)
	return StzEngineNumberIsPerfect(n)

func StzDigitCount(n)
	return StzEngineNumberDigitCount(n)

func StzDigitSum(n)
	return StzEngineNumberDigitSum(n)

func StzReverseDigits(n)
	return StzEngineNumberReverseDigits(n)

func StzIsDigitPalindrome(n)
	return StzEngineNumberIsPalindrome(n)

  ///////////////////////////
 ///   STZNUMBER CLASS   ///
///////////////////////////
	

  #===============================================================#
 #  EXACTNESS HELPERS (numeric foundation phase 1)                 #
#===============================================================#
#
# Global funcs, placed BEFORE the classes so they are reachable from the class
# methods that call them (a func defined after a class lands in that class's
# region and is not truly global).
#
# These implement two things pvtCalculate needs and Ring cannot express: the
# DECIMAL PLACES a result is entitled to, and exact integer arithmetic beyond
# 2^53 via the engine's arbitrary-precision integers.

# The digits after the decimal point of a numeric string ("" when there are none).
func _StzDecimalsPart(pcNum)
	_c_ = ring_trim("" + pcNum)
	_n_ = StzFindFirst(".", _c_)
	if _n_ = 0
		return ""
	ok
	return StzMidToEnd(_c_, _n_ + 1)

func _StzPlacesOf(pcNum)
	return len( _StzDecimalsPart(pcNum) )

# Two numeric strings denoting the SAME number. "1.50" = "1.5" = "1.500"; this is
# what Same() means, as against Ring's `=` on the rendered text.
func _StzSameNumberString(pcA, pcB)
	_a_ = _StzNormalizedNumberString(pcA)
	_b_ = _StzNormalizedNumberString(pcB)
	return _a_ = _b_

func _StzNormalizedNumberString(pcNum)
	_c_ = ring_trim("" + pcNum)
	if _c_ = ""
		return "0"
	ok
	_sign_ = ""
	if _c_[1] = "-"
		_sign_ = "-"
		_c_ = StzMidToEnd(_c_, 2)
	but _c_[1] = "+"
		_c_ = StzMidToEnd(_c_, 2)
	ok
	_int_ = _c_
	_frac_ = ""
	_dot_ = StzFindFirst(".", _c_)
	if _dot_ > 0
		_int_ = StzMid(_c_, 1, _dot_ - 1)
		_frac_ = StzMidToEnd(_c_, _dot_ + 1)
	ok
	# strip leading zeros of the integer part, trailing zeros of the fraction
	while len(_int_) > 1 and _int_[1] = "0"
		_int_ = StzMidToEnd(_int_, 2)
	end
	if _int_ = ""
		_int_ = "0"
	ok
	while len(_frac_) > 0 and _frac_[len(_frac_)] = "0"
		_frac_ = StzMid(_frac_, 1, len(_frac_) - 1)
	end
	if _int_ = "0" and _frac_ = ""
		return "0"          # -0 and 0 are the same number
	ok
	if _frac_ = ""
		return _sign_ + _int_
	ok
	return _sign_ + _int_ + "." + _frac_

# An integer, written plainly (no decimal point, no exponent). "" counts as one
# (the absent operand of a unary operation).
func _pvtLooksLikeInteger(pcNum)
	_c_ = ring_trim("" + pcNum)
	if _c_ = ""
		return 1
	ok
	if _c_[1] = "-" or _c_[1] = "+"
		_c_ = StzMidToEnd(_c_, 2)
	ok
	if _c_ = ""
		return 0
	ok
	_n_ = len(_c_)
	for _i_ = 1 to _n_
		if StzFindFirst(_c_[_i_], "0123456789") = 0
			return 0
		ok
	next
	return 1

func _pvtIsExactIntegerOp(pcOp)
	return StzFindFirst(pcOp, [ "+", "-", "*", "%", "^", "/" ]) > 0

func _pvtIsTranscendental(pcOp)
	return StzFindFirst(pcOp, [ "sin", "cos", "tan", "cotan", "sinh", "cosh",
		"tanh", "exp", "log", "log10", "sqrt", "sigmoid", "DerivativeSigmoid",
		"inverse" ]) > 0

# Would this integer operation leave the range where an f64 is exact (2^53)?
# Decided from the OPERAND DIGITS, never from the f64 result -- by the time a
# result exists the information is already gone.
func _pvtNeedsBigIntegers(pcOp, pcA, pcB)
	_da_ = len( _StzDigitsOnly(pcA) )
	_db_ = len( _StzDigitsOnly(pcB) )
	if _da_ > 15 or _db_ > 15
		return 1
	ok
	if pcOp = "*"
		return (_da_ + _db_) > 15          # the product may not fit
	ok
	if pcOp = "^"
		if pcB = "" return 0 ok
		return (_da_ * (0 + pcB)) > 15
	ok
	if pcOp = "+" or pcOp = "-"
		return (_da_ + 1) > 15 or (_db_ + 1) > 15
	ok
	return 0

func _StzDigitsOnly(pcNum)
	_out_ = ""
	_c_ = "" + pcNum
	_n_ = len(_c_)
	for _i_ = 1 to _n_
		if StzFindFirst(_c_[_i_], "0123456789") > 0
			_out_ += _c_[_i_]
		ok
	next
	return _out_

# Does this operation deserve the exact path? Yes when either operand carries
# decimals (the f64 route is what produced 0.1*0.1 = 0.0), or when plain integers
# would leave the range an f64 represents exactly.
func _pvtWantsExactPath(pcOp, pcA, pcB)
	if pcOp = "/"
		return 1        # try for a terminating quotient; fall back if not
	ok
	if _StzPlacesOf(pcA) > 0 or _StzPlacesOf(pcB) > 0
		return 1
	ok
	if _pvtLooksLikeInteger(pcA) and _pvtLooksLikeInteger(pcB)
		return _pvtNeedsBigIntegers(pcOp, pcA, pcB)
	ok
	return 0

# Did rendering the f64 to this decimal string lose anything? Answered by
# round-trip: a string that parses back to the very same double lost nothing.
func _pvtRendersExactly(pcRendered, pnResult)
	return (0 + ("" + pcRendered)) = pnResult

# EXACT DECIMAL ARITHMETIC ON SCALED INTEGERS.
#
# A decimal is an integer and a place count: 19.99 is (1999, 2). Align the places
# and the operation becomes integer arithmetic, which the engine does exactly at
# any size. Returns "" when it cannot be done exactly (a negative exponent, a
# malformed operand) so the caller falls back to the f64 path.
func _pvtExactDecimalCalc(pcOp, pcA, pcB)
	if NOT ( _StzIsPlainDecimal(pcA) and _StzIsPlainDecimal(pcB) )
		return ""
	ok
	_pa_ = _StzPlacesOf(pcA)
	_pb_ = _StzPlacesOf(pcB)

	if pcOp = "^"
		if NOT (_pvtLooksLikeInteger(pcB) and pcB != "")
			return ""
		ok
		_e_ = 0 + ring_trim("" + pcB)
		if _e_ < 0
			return ""
		ok
		_pR_ = StzEngineBigIntPow( _StzScaledBigInt(pcA), _e_ )
		if _pR_ = ""  return "" ok
		return _StzPlaceDecimalPoint( StzEngineBigIntToString(_pR_), _pa_ * _e_ )
	ok

	if pcOp = "*"
		_pR_ = StzEngineBigIntMul( _StzScaledBigInt(pcA), _StzScaledBigInt(pcB) )
		if _pR_ = ""  return "" ok
		return _StzPlaceDecimalPoint( StzEngineBigIntToString(_pR_), _pa_ + _pb_ )
	ok

	# DIVISION, exactly, WHEN IT TERMINATES.
	#
	# a/b = (ia * 10^pb) / (ib * 10^pa). Asking for k decimal places means asking
	# whether ia * 10^(pb+k) divides evenly by ib * 10^pa. The smallest k that does
	# is the shortest exact form (1/8 -> k=3, "0.125"); if no k up to 20 works the
	# quotient does not terminate (1/3) and we return "" so the caller falls back to
	# the f64 path, which reports itself approximate.
	if pcOp = "/"
		_pIb_ = _StzScaledBigInt(pcB)
		if _pIb_ = "" or StzEngineBigIntIsZero(_pIb_)
			return ""                              # let the normal path handle /0
		ok
		_pD_ = _StzMulPowerOfTen(_pIb_, _pa_)
		if _pD_ = ""  return "" ok
		_pIa_ = _StzScaledBigInt(pcA)
		if _pIa_ = ""  return "" ok
		for _k_ = 0 to 20
			_pN_ = _StzMulPowerOfTen(_pIa_, _pb_ + _k_)
			if _pN_ = ""  return "" ok
			_pMod_ = StzEngineBigIntMod(_pN_, _pD_)
			if _pMod_ != "" and StzEngineBigIntIsZero(_pMod_)
				_pQ_ = StzEngineBigIntDiv(_pN_, _pD_)
				if _pQ_ = ""  return "" ok
				return _StzPlaceDecimalPoint( StzEngineBigIntToString(_pQ_), _k_ )
			ok
		next
		return ""
	ok

	# + - % : align both operands to the same number of places first
	_pMax_ = _pa_
	if _pb_ > _pMax_
		_pMax_ = _pb_
	ok
	_pA_ = _StzScaledBigIntTo(pcA, _pMax_)
	_pB_ = _StzScaledBigIntTo(pcB, _pMax_)
	if _pA_ = "" or _pB_ = ""
		return ""
	ok
	_pR_ = ""
	switch pcOp
	on "+"
		_pR_ = StzEngineBigIntAdd(_pA_, _pB_)
	on "-"
		_pR_ = StzEngineBigIntSub(_pA_, _pB_)
	on "%"
		_pR_ = StzEngineBigIntMod(_pA_, _pB_)
	off
	if _pR_ = ""
		return ""
	ok
	return _StzPlaceDecimalPoint( StzEngineBigIntToString(_pR_), _pMax_ )

# A plain decimal: optional sign, digits, at most one dot, no exponent.
func _StzIsPlainDecimal(pcNum)
	_c_ = ring_trim("" + pcNum)
	if _c_ = ""
		return 1
	ok
	if _c_[1] = "-" or _c_[1] = "+"
		_c_ = StzMidToEnd(_c_, 2)
	ok
	if _c_ = ""
		return 0
	ok
	_nDots_ = 0
	_n_ = len(_c_)
	for _i_ = 1 to _n_
		if _c_[_i_] = "."
			_nDots_++
		but StzFindFirst(_c_[_i_], "0123456789") = 0
			return 0
		ok
	next
	return _nDots_ <= 1

# "19.99" -> the big integer 1999 (the value scaled by its own places).
func _StzScaledBigInt(pcNum)
	_c_ = ring_trim("" + pcNum)
	if _c_ = ""
		_c_ = "0"
	ok
	_sign_ = ""
	if _c_[1] = "-"
		_sign_ = "-"
		_c_ = StzMidToEnd(_c_, 2)
	but _c_[1] = "+"
		_c_ = StzMidToEnd(_c_, 2)
	ok
	_digits_ = _StzDigitsOnly(_c_)
	if _digits_ = ""
		_digits_ = "0"
	ok
	return StzEngineBigIntFromString(_sign_ + _digits_)

# Every item is a number, or a number written as a string. Neither
# @IsListOfNumbers (rejects "6") nor any stzList predicate covers the mixed case.
func _StzIsListOfNumbersOrNumberStrings(paList)
	if NOT isList(paList)
		return 0
	ok
	_n_ = len(paList)
	if _n_ = 0
		return 0
	ok
	for _i_ = 1 to _n_
		_it_ = paList[_i_]
		if isNumber(_it_)
			loop
		ok
		if isString(_it_) and _StzIsPlainDecimal(_it_) and ring_trim(_it_) != ""
			loop
		ok
		return 0
	next
	return 1

# A Ring number rendered as a string WITHOUT LOSING IT.
#
# `"" + n` uses the process-global decimals(), which truncates: with the default of
# 2, 1e-20 renders as "0.00". stzNumber stores that string AS its value, so the
# number is gone -- not mis-displayed, gone.
#
# The ordinary rendering is kept whenever it round-trips, so nothing about existing
# output changes. Only when it fails to round-trip is the shortest plain decimal
# used instead (from the engine, which tries increasing precision until the value
# reads back). PLAIN and never scientific: "1e-20" would defeat IntegerPart,
# NumberOfDigits and the scaled-integer arithmetic, all of which expect digits.
func _StzNumberContentWithoutLoss(pnNumber)
	# NOT A NUMBER, AND SAID SO. Ring answers isNumber(inf) with TRUE and
	# inf > 0 with TRUE, so an overflow travels silently -- and stzNumber used to
	# store the literal text "inf" (or "-nan(ind)") and then report
	# Representation() = :decimal, which is a lie every later operation inherits.
	#
	# The engine's plain-shortest renderer returns "" for both, which is the cheapest
	# reliable test available here.
	if StzEngineNumberPlainShortest(pnNumber) = "" and NOT (pnNumber = 0)
		StzRaise("This value is not a finite number (an infinity or a NaN). " +
		         "It usually means an earlier calculation overflowed or divided " +
		         "zero by zero -- the place to fix it is there, not here.")
	ok
	_cPlain_ = "" + pnNumber
	if (0 + _cPlain_) = pnNumber
		return _cPlain_                 # nothing lost -- leave it alone
	ok
	_cBest_ = StzEngineNumberPlainShortest(pnNumber)
	if _cBest_ = ""
		return _cPlain_                 # NaN / Inf: keep whatever Ring said
	ok
	return _cBest_

# THE DIGIT GROUPS OF A NUMBER, in threes FROM THE RIGHT, units group FIRST:
#   "1234567" -> [ "567", "234", "1" ]
#   "12590"   -> [ "590", "12" ]
#   "5"       -> [ "5" ]
#
# FIXED 2026-07-25. Both Structure() and StructureXT() built this with
# `SplitToNPartsQ(3)`, which splits into THREE PARTS OF EQUAL LENGTH, not into
# parts OF three -- "N parts" read as "parts of N". So 1234567 came apart as
# 123/45/67 and the number's Millions/Thousands/Hundreds were all wrong, taking
# ApplyFormatXT's thousands separator with them. The grouping is the same for both
# methods, so it lives in one place now.
#
# Units-group-first is deliberate: it is the order both callers index (_aTemp_[1]
# is the hundreds group, [2] the thousands...), and it is the order the grouping
# naturally produces when walking from the right.
func _StzDigitGroupsOfThree(pcDigits)
	_c_ = _StzDigitsOnly("" + pcDigits)
	_aOut_ = []
	if _c_ = ""
		return _aOut_
	ok
	_nEnd_ = len(_c_)
	while _nEnd_ > 0
		_nStart_ = _nEnd_ - 2
		if _nStart_ < 1
			_nStart_ = 1
		ok
		_aOut_ + StzMid(_c_, _nStart_, _nEnd_ - _nStart_ + 1)
		_nEnd_ = _nStart_ - 1
	end
	return _aOut_

# ── RATIONALS: exact fractions p/q (numeric foundation phase 1, slice 3) ──
#
# The rung the plan asks for that decimals cannot reach. 1/3 has no finite decimal
# form, so slice 1's exact-decimal path can only approximate it and honestly says
# so. As a FRACTION it is exact, and "1/3" + "2/3" is exactly 1.
#
# Represented as the content string "p/q", always in LOWEST TERMS with the sign on
# the numerator, and collapsing to a plain integer when the denominator reduces to
# 1 (so "4/2" becomes "2", and Representation() then honestly says :integer).
#
# PROMOTION IS UPWARD: mixing a rational with a decimal or an integer yields a
# RATIONAL, because that is the representation able to hold the answer exactly.
# 0.25 + 1/4 is 1/2, not 0.5 -- one of them is exact in every case, the other is not.

func _StzIsRationalString(pcStr)
	_c_ = ring_trim("" + pcStr)
	# StzFind returns ALL positions as a list; exactly one slash makes a fraction
	if len( StzFind("/", _c_) ) != 1
		return 0
	ok
	_n_ = StzFindFirst("/", _c_)
	_num_ = StzMid(_c_, 1, _n_ - 1)
	_den_ = StzMidToEnd(_c_, _n_ + 1)
	if NOT (_pvtLooksLikeInteger(_num_) and _num_ != "")
		return 0
	ok
	if NOT (_pvtLooksLikeInteger(_den_) and _den_ != "")
		return 0
	ok
	if _StzDigitsOnly(_den_) = "" or (0 + _StzDigitsOnly(_den_)) = 0
		return 0                    # a denominator of zero is not a number
	ok
	return 1

# -> [ numerator, denominator ] as strings, for ANY numeric content: a rational,
# a decimal (0.25 -> [ "25", "100" ]) or an integer (7 -> [ "7", "1" ]).
func _StzAsRationalParts(pcStr)
	_c_ = ring_trim("" + pcStr)
	if _StzIsRationalString(_c_)
		_n_ = StzFindFirst("/", _c_)
		return [ StzMid(_c_, 1, _n_ - 1), StzMidToEnd(_c_, _n_ + 1) ]
	ok
	_places_ = _StzPlacesOf(_c_)
	if _places_ = 0
		if _c_ = ""
			return [ "0", "1" ]
		ok
		return [ _c_, "1" ]
	ok
	# a decimal is its digits over the matching power of ten
	_sign_ = ""
	if len(_c_) > 0 and _c_[1] = "-"
		_sign_ = "-"
	ok
	_den_ = "1"
	for _i_ = 1 to _places_
		_den_ += "0"
	next
	return [ _sign_ + _StzDigitsOnly(_c_), _den_ ]

# p/q in lowest terms, sign on the numerator, collapsing to an integer when q is 1.
func _StzReducedRational(pcNum, pcDen)
	_pN_ = StzEngineBigIntFromString(ring_trim("" + pcNum))
	_pD_ = StzEngineBigIntFromString(ring_trim("" + pcDen))
	if _pN_ = "" or _pD_ = ""
		return ""
	ok
	if StzEngineBigIntIsZero(_pD_)
		return ""
	ok
	# a zero numerator is just 0, whatever the denominator
	if StzEngineBigIntIsZero(_pN_)
		return "0"
	ok
	# keep the sign on the numerator: 1/-2 becomes -1/2
	if StzEngineBigIntIsNegative(_pD_)
		_pN_ = StzEngineBigIntNegate(_pN_)
		_pD_ = StzEngineBigIntNegate(_pD_)
	ok
	_pG_ = StzEngineBigIntGcd(_pN_, _pD_)
	if _pG_ != "" and NOT StzEngineBigIntIsZero(_pG_)
		_pN_ = StzEngineBigIntDiv(_pN_, _pG_)
		_pD_ = StzEngineBigIntDiv(_pD_, _pG_)
	ok
	_cN_ = StzEngineBigIntToString(_pN_)
	_cD_ = StzEngineBigIntToString(_pD_)
	if _cD_ = "1"
		return _cN_                     # no longer a fraction
	ok
	return _cN_ + "/" + _cD_

# The exact result of an operation when either side is a fraction. "" when it
# cannot be done exactly, so the caller falls back.
func _StzExactRationalCalc(pcOp, pcA, pcB)
	_a_ = _StzAsRationalParts(pcA)
	_b_ = _StzAsRationalParts(pcB)
	_pAn_ = StzEngineBigIntFromString(_a_[1])
	_pAd_ = StzEngineBigIntFromString(_a_[2])
	_pBn_ = StzEngineBigIntFromString(_b_[1])
	_pBd_ = StzEngineBigIntFromString(_b_[2])
	if _pAn_ = "" or _pAd_ = "" or _pBn_ = "" or _pBd_ = ""
		return ""
	ok
	_pRn_ = ""
	_pRd_ = ""
	switch pcOp
	on "+"
		# a/b + c/d = (ad + cb) / bd
		_pRn_ = StzEngineBigIntAdd( StzEngineBigIntMul(_pAn_, _pBd_),
		                            StzEngineBigIntMul(_pBn_, _pAd_) )
		_pRd_ = StzEngineBigIntMul(_pAd_, _pBd_)
	on "-"
		_pRn_ = StzEngineBigIntSub( StzEngineBigIntMul(_pAn_, _pBd_),
		                            StzEngineBigIntMul(_pBn_, _pAd_) )
		_pRd_ = StzEngineBigIntMul(_pAd_, _pBd_)
	on "*"
		_pRn_ = StzEngineBigIntMul(_pAn_, _pBn_)
		_pRd_ = StzEngineBigIntMul(_pAd_, _pBd_)
	on "/"
		if StzEngineBigIntIsZero(_pBn_)
			return ""                   # division by zero: not our business
		ok
		_pRn_ = StzEngineBigIntMul(_pAn_, _pBd_)
		_pRd_ = StzEngineBigIntMul(_pAd_, _pBn_)
	off
	if _pRn_ = "" or _pRd_ = ""
		return ""
	ok
	return _StzReducedRational( StzEngineBigIntToString(_pRn_),
	                            StzEngineBigIntToString(_pRd_) )

# The f64 nearest a fraction -- for NumericValue(), comparisons and anything that
# has to leave exact arithmetic behind.
func _StzRationalToFloat(pcStr)
	_a_ = _StzAsRationalParts(pcStr)
	_d_ = ring_number(_a_[2])
	if _d_ = 0
		return 0
	ok
	return ring_number(_a_[1]) / _d_

# ── ROUNDING A DECIMAL STRING, EXACTLY, IN A NAMED MODE ─────────────────
#
# RoundToXT rounds by going through NumericValue() -- an f64 -- so it inherits
# binary tie behaviour and Ring's 14-place ceiling, and it cannot express
# half-even at all. Rounding the DIGITS instead is exact, has no ceiling, and makes
# the tie rule a decision rather than an accident of representation.
#
#   :HalfUp    a tie goes AWAY FROM ZERO   (0.5 -> 1, 2.5 -> 3, -1.5 -> -2)
#   :HalfEven  a tie goes to the EVEN digit (0.5 -> 0, 2.5 -> 2, 1.5 -> 2)
#
# Half-even is the accounting default -- and the reason is not taste. Half-up is
# biased: over many roundings it drifts upward, because every tie moves the same
# way. Half-even splits ties between up and down, so the bias cancels. On a ledger
# of thousands of lines that difference is money.
func _StzRoundDecimalString(pcNum, pnPlaces, pcMode)
	_c_ = ring_trim("" + pcNum)
	if NOT _StzIsPlainDecimal(_c_)
		return _c_                          # not ours to round
	ok
	_n_ = pnPlaces
	if _n_ < 0
		_n_ = 0
	ok

	_sign_ = ""
	if len(_c_) > 0 and _c_[1] = "-"
		_sign_ = "-"
		_c_ = StzMidToEnd(_c_, 2)
	but len(_c_) > 0 and _c_[1] = "+"
		_c_ = StzMidToEnd(_c_, 2)
	ok

	_int_ = _c_
	_frac_ = ""
	_dot_ = StzFindFirst(".", _c_)
	if _dot_ > 0
		_int_ = StzMid(_c_, 1, _dot_ - 1)
		_frac_ = StzMidToEnd(_c_, _dot_ + 1)
	ok
	if _int_ = ""
		_int_ = "0"
	ok

	# already short enough: pad and go
	if len(_frac_) <= _n_
		while len(_frac_) < _n_
			_frac_ += "0"
		end
		if _n_ = 0
			return _sign_ + _int_
		ok
		return _sign_ + _int_ + "." + _frac_
	ok

	_keep_ = StzMid(_frac_, 1, _n_)
	_rest_ = StzMidToEnd(_frac_, _n_ + 1)

	# Is the discarded tail more than, less than, or exactly one half?
	_cmp_ = _StzCompareTailToHalf(_rest_)

	_bRoundAway_ = 0
	if _cmp_ > 0
		_bRoundAway_ = 1
	but _cmp_ = 0
		if StzLower("" + pcMode) = "halfeven"
			# the tie goes to the EVEN last kept digit
			_last_ = "0"
			if _n_ > 0
				_last_ = _keep_[_n_]
			else
				_last_ = _int_[len(_int_)]
			ok
			if StzFindFirst(_last_, "13579") > 0
				_bRoundAway_ = 1
			ok
		else
			_bRoundAway_ = 1              # :HalfUp -- away from zero
		ok
	ok

	if NOT _bRoundAway_
		# a value that rounds to nothing is zero, not MINUS zero
		_dg_ = _StzDigitsOnly(_int_ + _keep_)
		_bAllZero_ = 1
		_nd_ = len(_dg_)
		for _k_ = 1 to _nd_
			if _dg_[_k_] != "0"
				_bAllZero_ = 0
				exit
			ok
		next
		if _bAllZero_
			_sign_ = ""
		ok
		if _n_ = 0
			return _sign_ + _int_
		ok
		return _sign_ + _int_ + "." + _keep_
	ok

	# round away from zero: increment the kept digits AS ONE INTEGER, so the carry
	# runs into the integer part correctly (9.99 -> 10.0, not 9.100)
	_whole_ = _int_ + _keep_
	_pB_ = StzEngineBigIntFromString(_whole_)
	if _pB_ = ""
		return _sign_ + _int_ + "." + _keep_
	ok
	_pOne_ = StzEngineBigIntFromString("1")
	_cInc_ = StzEngineBigIntToString( StzEngineBigIntAdd(_pB_, _pOne_) )
	# put the point back n from the right
	while len(_cInc_) <= _n_
		_cInc_ = "0" + _cInc_
	end
	if _n_ = 0
		return _sign_ + _cInc_
	ok
	_cut_ = len(_cInc_) - _n_
	return _sign_ + StzMid(_cInc_, 1, _cut_) + "." + StzMidToEnd(_cInc_, _cut_ + 1)

# Compare a discarded tail against one half: >0, =0 or <0.
# "5" and "50" and "500" are all exactly half; "51" is more; "4999" is less.
func _StzCompareTailToHalf(pcTail)
	_t_ = "" + pcTail
	if _t_ = ""
		return -1
	ok
	_first_ = _t_[1]
	if StzFindFirst(_first_, "01234") > 0
		return -1
	ok
	if StzFindFirst(_first_, "6789") > 0
		return 1
	ok
	# leading 5: exactly half only if everything after it is zero
	_rest_ = StzMidToEnd(_t_, 2)
	_n_ = len(_rest_)
	for _i_ = 1 to _n_
		if _rest_[_i_] != "0"
			return 1
		ok
	next
	return 0

# "007" -> "7"; "00.5" -> "0.5". One zero is kept before the point, because ".5"
# is not a number anybody wants back.
func _StzStripLeadingZeros(pcNum)
	_c_ = ring_trim("" + pcNum)
	if _c_ = ""
		return "0"
	ok
	_sign_ = ""
	if _c_[1] = "-" or _c_[1] = "+"
		if _c_[1] = "-"
			_sign_ = "-"
		ok
		_c_ = StzMidToEnd(_c_, 2)
	ok
	_int_ = _c_
	_rest_ = ""
	_dot_ = StzFindFirst(".", _c_)
	if _dot_ > 0
		_int_ = StzMid(_c_, 1, _dot_ - 1)
		_rest_ = StzMidToEnd(_c_, _dot_)      # keeps the dot
	ok
	while len(_int_) > 1 and _int_[1] = "0"
		_int_ = StzMidToEnd(_int_, 2)
	end
	if _int_ = ""
		_int_ = "0"
	ok
	return _sign_ + _int_ + _rest_

# "1.500" -> "1.5"; "1.000" -> "1". Only touches the FRACTIONAL part, so the
# trailing zeros of an integer are never at risk.
func _StzStripTrailingFractionZeros(pcNum)
	_c_ = ring_trim("" + pcNum)
	_dot_ = StzFindFirst(".", _c_)
	if _dot_ = 0
		return _c_
	ok
	_int_ = StzMid(_c_, 1, _dot_ - 1)
	_frac_ = StzMidToEnd(_c_, _dot_ + 1)
	while len(_frac_) > 0 and _frac_[len(_frac_)] = "0"
		_frac_ = StzMid(_frac_, 1, len(_frac_) - 1)
	end
	if _frac_ = ""
		return _int_
	ok
	return _int_ + "." + _frac_

# A big integer multiplied by 10^k (k >= 0).
func _StzMulPowerOfTen(pBig, pnK)
	if pnK <= 0
		return pBig
	ok
	_cTen_ = "1"
	for _i_ = 1 to pnK
		_cTen_ += "0"
	next
	return StzEngineBigIntMul(pBig, StzEngineBigIntFromString(_cTen_))

# ...and scaled to a GIVEN number of places, by appending zeros.
func _StzScaledBigIntTo(pcNum, pnPlaces)
	_p_ = _StzPlacesOf(pcNum)
	_pB_ = _StzScaledBigInt(pcNum)
	if _pB_ = ""
		return ""
	ok
	_k_ = pnPlaces - _p_
	if _k_ <= 0
		return _pB_
	ok
	_cTen_ = "1"
	for _i_ = 1 to _k_
		_cTen_ += "0"
	next
	return StzEngineBigIntMul(_pB_, StzEngineBigIntFromString(_cTen_))

# Put the decimal point back: ("29985", 4) -> "2.9985"; ("5", 3) -> "0.005".
func _StzPlaceDecimalPoint(pcDigits, pnPlaces)
	_c_ = "" + pcDigits
	if pnPlaces <= 0
		return _c_
	ok
	_sign_ = ""
	if len(_c_) > 0 and _c_[1] = "-"
		_sign_ = "-"
		_c_ = StzMidToEnd(_c_, 2)
	ok
	while len(_c_) <= pnPlaces
		_c_ = "0" + _c_
	end
	_cut_ = len(_c_) - pnPlaces
	return _sign_ + StzMid(_c_, 1, _cut_) + "." + StzMidToEnd(_c_, _cut_ + 1)

# The operation redone through the engine's arbitrary-precision integers.
# Returns "" if it cannot be done exactly, so the caller falls back.
func _pvtBigIntegerCalc(pcOp, pcA, pcB)
	_pA_ = StzEngineBigIntFromString(ring_trim("" + pcA))
	if _pA_ = ""
		return ""
	ok
	_pR_ = ""
	if pcOp = "^"
		_e_ = 0 + ring_trim("" + pcB)
		if _e_ < 0
			return ""
		ok
		_pR_ = StzEngineBigIntPow(_pA_, _e_)
	else
		_pB_ = StzEngineBigIntFromString(ring_trim("" + pcB))
		if _pB_ = ""
			return ""
		ok
		switch pcOp
		on "+"
			_pR_ = StzEngineBigIntAdd(_pA_, _pB_)
		on "-"
			_pR_ = StzEngineBigIntSub(_pA_, _pB_)
		on "*"
			_pR_ = StzEngineBigIntMul(_pA_, _pB_)
		on "%"
			_pR_ = StzEngineBigIntMod(_pA_, _pB_)
		off
	ok
	if _pR_ = ""
		return ""
	ok
	return StzEngineBigIntToString(_pR_)

# THE DECIMAL PLACES A RESULT IS ENTITLED TO.
#
#   + - %   max(places(a), places(b))   -- no new places can appear
#   *       places(a) + places(b)       -- exactly the places a product needs
#   ^       places(a) * exponent
#   /       see below: division is the one that cannot be answered from the
#           operands alone, because the quotient may not terminate
#   floor / ceil                        -- an integer
#   everything else (sin, log, sqrt...) -- inherently approximate
func _pvtResultPlaces_(pcOp, pcA, pcB, pnSelfRound)
	_pa_ = _StzPlacesOf(pcA)
	_pb_ = _StzPlacesOf(pcB)

	if pcOp = "floor" or pcOp = "ceil"
		return 0
	ok

	# EVERYTHING THAT IS NOT ARITHMETIC KEEPS THE ORIGINAL RULE -- the receiver's
	# own round. That was never the defect: sin/cos/log/sqrt have no exact decimal
	# form, so the caller's requested precision is the only sensible answer, and
	# changing it here silently coarsened trigonometry from 5 places to 2.
	if NOT _pvtIsArithmetic(pcOp)
		return pnSelfRound
	ok
	if pcOp = "+" or pcOp = "-" or pcOp = "%" or pcOp = "LCM" or pcOp = "GCD"
		if _pa_ > _pb_
			return _pa_
		ok
		return _pb_
	ok
	if pcOp = "*"
		_p_ = _pa_ + _pb_
		if _p_ > 14
			_p_ = 14
		ok
		return _p_
	ok
	if pcOp = "^"
		if _pvtLooksLikeInteger(pcB) and pcB != ""
			_e_ = 0 + ring_trim("" + pcB)
			if _e_ >= 0 and (_pa_ * _e_) <= 14
				return _pa_ * _e_
			ok
		ok
		return _StzInexactPlaces(_pa_, _pb_)
	ok
	# DIVISION. A quotient terminates only when the reduced denominator has no
	# prime factors besides 2 and 5, so the places cannot be read off the operands.
	# Give it room to land on the exact value when it does terminate (1/8 = 0.125,
	# 0.1/4 = 0.025) and let _pvtNoteExactness report the truth when it does not.
	# The rendering trims nothing, so a terminating quotient shows its own places.
	if pcOp = "/"
		# room to land on the exact value when the quotient terminates
		# (1/8 = 0.125, 0.1/4 = 0.025). StzDecimals accepts at most 14.
		return _StzInexactPlaces(_pa_ + _pb_ + 6, 0)
	ok
	return _StzInexactPlaces(_pa_, _pb_)

func _pvtIsArithmetic(pcOp)
	return StzFindFirst(pcOp, [ "+", "-", "*", "/", "%", "^" ]) > 0

# The places to use when the result has no exact decimal form: honour whatever
# the caller asked for globally, but never fewer than the operands carried.
func _StzInexactPlaces(pnA, pnB)
	_n_ = pnA
	if pnB > _n_
		_n_ = pnB
	ok
	_cur_ = StzCurrentRound()
	if _cur_ > _n_
		_n_ = _cur_
	ok
	if _n_ > 14           # StzDecimals refuses more than 14
		_n_ = 14
	ok
	if _n_ < 1
		_n_ = 1
	ok
	return _n_


class stzDecimalNumber from stzNumber

class stzNumber from stzObject

	@cContent = ""
	# What init() was HANDED, verbatim -- number, string or pair. Stored
	# because InitialContent() used to `return pNumber`, init's own
	# parameter, which is gone the moment init returns: the accessor raised
	# R24 on every call it has ever received.
	@pInitialValue = ""
	# THE EXACTNESS REGISTER (numeric foundation phase 1). A number knows whether
	# its current value is an exact representation of the computation that produced
	# it, and can say why not. :exact | :inexact
	@cExactness = :exact
	@cInexactReason = ""
	# THE REGIME (numeric foundation phase 2): what KIND of quantity this is, and
	# therefore how it must round and how exact it must be. Carried BY THE VALUE,
	# because unlike a regex scope (per match) or a system scope (per object), a
	# number's regime is a property of the quantity and travels through a whole
	# calculation: a price stays a price.
	@cRegime = :machine
	@nRegimePlaces = 0
	#--> Holds the number WITHOUT eventual
	# underscores introduced by the user!

	@nRound = DefaultRound()

	@cReturnType = :Number # Or :String depending on the type of the input

	_These_
	_Those_

	  #------------#
	 #    INIT    #
	#------------#

	# Build the number from a number, a number-in-string, or another
	# stzNumber.
	def init(pNumber)

		# A stzNumber object can be initiated in 3 ways:

		# 1- By providing a number, in this case the current round is taken.
		#    ~> Example : new stzNumber(12)

		# 2- By provising a number in string. In this case, if the number
		#   contains decimals, then the round is the number of decimals.
		#   Otherwise, the current round is taken.
		#   ~> Example : new stzNumber("12.375")

		# 3- By providing a pair containing the number itself (as a number
		#    or as a number in string), and the round to be taken.
		#    ~> Example : new stzNumber([ 12.275865, :Round = 3 ])

		if CheckingParams()
			if NOT (isNumber(pNumber) or isString(pNumber) or @IsPair(pNumber))
				StzRaise(stzNumberError(:CanNotCreateStzNumberObject))
			ok
		ok

		@pInitialValue = pNumber

		# CASE 1
		if isNumber(pNumber)

			# NO SILENT LOSS, 2026-07-25 (numeric foundation phase 1). `"" + n`
			# renders through Ring's PROCESS-GLOBAL decimals(), so with the default
			# of 2 the value 1e-20 became the string "0.00" -- and since the string
			# IS the value here, the number was DESTROYED, not merely mis-shown:
			# NumericValue() answered 0 afterwards.
			#
			# So the rendering is checked, and only REPLACED WHEN IT LOSES the value.
			# A number that renders as "0.10" has lost nothing and is left exactly as
			# it was; this is a loss fix, not a reformatting.
			@cContent = _StzNumberContentWithoutLoss(pNumber)
			@nRound = StzCurrentRound()
			@cReturnType = :Number

		# CASE 2
		but isString(pNumber)

			@cReturnType = :String

			# Case where a char is provided in the form
			# of Unicode circled numbers
			# ~> Example : new stzNumber(char(226) + char(145) + char(166))
			# THE OBJECT LEAK, FIXED 2026-07-26.
			#
			# This read `StzStringQ(pNumber).IsAChar() and StzCharQ(pNumber).
			# IsCircledNumber()` -- two throwaway objects built on EVERY string
			# construction just to ask a question about circled Unicode numerals,
			# which is the wrap-to-validate anti-pattern this library already has
			# on record. And RING'S `and` EVALUATES BOTH SIDES, so the stzChar was
			# constructed even when the string was plainly not one character.
			#
			# Ring has no destructors, so each of those objects took an engine
			# handle and never gave it back. The table (ring_api.zig) holds 8192,
			# `releaseSlot` is only reached through an explicit Free that a
			# garbage-collected object never calls, and so:
			#
			#     new stzChar("1")      failed at call 4097   (2 handles each)
			#     new stzNumber("1")    failed at call 1639
			#     StringToNumber("1")   failed at call 1366
			#
			# and once the table filled, EVERY later call needing a handle failed
			# too -- surfacing as "Can not create char object!" from a validation
			# branch that had simply run out of room to build its evidence.
			#
			# THE CHEAP GUARD IS EXACT, not an approximation. A circled numeral is
			# U+2460 or above, so it is ONE codepoint and MORE THAN ONE BYTE.
			# StzLen counts codepoints, len counts bytes, and neither allocates
			# anything. Every ASCII string -- which is every ordinary number --
			# fails this instantly and builds nothing at all.
			if StzLen(pNumber) = 1 and len(pNumber) > 1
				# Straight to the engine -- no objects at all now. This built
				# TWO throwaway stzChars (IsCircledNumber, then NumericValue),
				# which is exactly the handle leak the note above records; and
				# NumericValue was broken anyway -- it switched the circled
				# glyph against "0".."9", matched nothing, and answered empty,
				# so every circled digit constructed the number "".
				#
				# The engine reads the value from Unicode's own data, so this
				# door now also admits fullwidth, superscript, Arabic-Indic,
				# Devanagari and the other one-codepoint numerals -- not just
				# the circled set. -1 means "not a numeral": fall through and
				# let the ordinary string paths judge it.
				_nUniVal_ = StzEngineUnicodeNumericValue(StzUnicode(pNumber))
				if _nUniVal_ >= 0
					@cContent = "" + _nUniVal_
					@nRound = StzCurrentRound()

					return
				ok
			ok

			# Case where the string provided is empty
			if pNumber = ""
				@cContent = "0"
				@nRound = StzCurrentRound()

			# A RATIONAL, written p/q (numeric foundation phase 1, slice 3).
			# Stored in lowest terms, so "2/4" arrives as "1/2" and "4/2" as "2".
			but _StzIsRationalString(pNumber)
				_cRat_ = _StzReducedRational( _StzAsRationalParts(pNumber)[1],
				                             _StzAsRationalParts(pNumber)[2] )
				if _cRat_ = ""
					StzRaise(stzNumberError(:CanNotCreateDecimalNumber1))
				ok
				@cContent = _cRat_
				@nRound = StzCurrentRound()

			# Case where the user provides a number in string
			# with a dot "." at the end (a "0" is then added)
			but StzRight(pNumber, 1) = "." and
			   StringRepresentsNumberInDecimalForm(StzMid(pNumber, 1, StzLen(pNumber) - 1))

				# FIXED 2026-07-25: this appended "0" to the LOCAL pNumber and then
				# fell out of the chain without ever assigning @cContent, so
				# new stzNumber("12.") had empty content and a value of 0.
				@cContent = pNumber + "0"
				@nRound = 1
	
			# Case where pNumber is a non null string
			else
				if StringRepresentsNumberInDecimalForm(pNumber)
		
					# INLINED, not StringRepresentsCalculableNumber(pNumber).
					# That global is `new stzString(x)` + one method call, and it is
					# leak-free when called at global scope -- but called from inside
					# this class it leaked one engine handle per construction, which
					# is what made `new stzNumber("1")` die at call 1639 and
					# StringToNumber at 1366. The identical work written out here
					# does not leak. Bare-name resolution inside a Ring class is
					# already known to be its own hazard in this codebase (see
					# CLAUDE.md on `len()`/`trim()` needing `ring_len`/`ring_trim`);
					# this is the same family.
					#
					# The check is NOT redundant with the decimal-form test above,
					# which was worth confirming before touching it: "12." and ".5"
					# are decimal-form yet NOT calculable, so dropping it would have
					# silently accepted both.
					_oCalc_ = new stzString(pNumber)
					if _oCalc_.RepresentsCalculableNumber()
						# A THIRD leaked object, for the same reason: a stzString
						# built only to ask "do you contain an underscore, and a
						# dot?". CLAUDE.md's own rule covers this -- "Don't wrap to
						# find/contain, use StzFind/StzFindFirst/StzReplace" -- and
						# those globals answer without allocating.
						if StzFindFirst("_", pNumber) > 0
							@cContent = StzReplace(pNumber, "_", "")
						else
							@cContent = pNumber
						ok

						_nDotAt_ = StzFindFirst(".", pNumber)
						if _nDotAt_ > 0
							@nRound = StzLen(pNumber) - _nDotAt_
						else
							@nRound = StzCurrentRound()
						ok
					else
						StzRaise(stzNumberError(:CanNotCreateDecimalNumber2))
					ok
		
				else
					StzRaise(stzNumberError(:CanNotCreateDecimalNumber1))
				ok
			ok

		# Case 3 where a pair is provided
		but isPair(pNumber)

			if NOT @IsNumberOrString(pNumber[1])
				StzRaise("Incorrect param type! The first item in the pair must be a number or string.")
			ok

			# Reading the round (from the second item in the pair)

			if isNumber(pNumber[2])
				@nRound = pNumber[2]
				@cReturnType = :Number

			but @IsPair(pNumber[2]) and isString(pNumber[2][1]) and
			   ( pNumber[2][1] = :Round or pNumber[2][1] = :RoundedTo ) and
			   isNumber(pNumber[2][2])

				@nRound = pNumber[2][2]	
				@cReturnType = :Number

			else
				StzRaise("Incorrect param type! The second item of the pair must be a number or" + 
					 " a named param of the form :Round = n.")
			ok

			# Reading the number (from the first item in the pair)

			if isNumber(pNumber[1])

				@cReturnType = :Number

				_nCurrentRound_ = StzCurrentRound()
				StzDecimals(@nRound)
				# same guard as CASE 1: an explicit round must not silently destroy
				# the value it was given
				@cContent = _StzNumberContentWithoutLoss(pNumber[1])
				StzDecimals(_nCurrentRound_)

			but isString(pNumber[1])
				@cContent = pNumber[1]
				@cReturnType = :String

			ok

		ok

		_These_ = This
		_Those_ = This

	  #-------------------------#
	 #    CONTENT AND VALUE    #
	#-------------------------#

	# The number as it is held: a STRING (use NumericValue for the number).
	def Content()
		return @cContent

		def ContentQ()
			return new stzNumber(This.Content())

	# Same as NumericValue: the number as a Ring number.
	def Number()
		return This.NumericValue()

		def NumberQ() # Same as Copy()
			return new stzNumber( This.Content() )

	# The value the number was created with.
	def InitialContent()
		return @pInitialValue

	# A new stzNumber with the same content.
	def Copy()
		_oCopy_ = new stzNumber( This.Content() )
		return _oCopy_

	# Whether values are returned as :Number or :String.
	def ReturnType()
		return @cReturnType

	# Choose whether values are returned as :Number or :String.
	def SetReturnType(_cType_)
		if CheckingParams()
			if isList(_cType_) and Q(_cType_).IsToOrAsNamedParams()
				_cType_ = _cType_[2]
			ok

			if NOT isString(_cType_)
				StzRaise("Incorrect param type! cType must be a string.")
			ok
		ok

		if NOT ( _cType_ = :Number or _cType_ = :String )
			StzRaise("Incorrect value! cType must be equal to :Number or :String.")
		ok

		@cReturnType = _cType_

		#< @FunctionAlternativeForms

		# Choose whether values come back as :Number or :String.
		def SetReturnTypeTo(_cType_)
			if CheckingParams()
				if NOT isString(_cType_)
					StzRaise("Incorrect param type! cType must be a string.")
				ok
			ok

			This.SetReturnType(_cType_)

		# Choose whether values come back as :Number or :String.
		def SetReturnTypeAs(_cType_)
			SetReturnTypeTo(_cType_)

		#>

	# Make values come back as :Number (the return-type dial).
	def ReturnNumber()
		SetReturnType(:Number)
		
	# The number as a string with its explicit sign (+ or -).
	def NumberWithSign()
		If This.IsPositive()
			return "+" + This.Content()

		else
			return This.Content()
		ok

	# The number as a Ring number.
	def NumericValue()
		# a fraction has to be divided out before it can be an f64 -- and the
		# result is an APPROXIMATION of an exact value, which is the whole reason
		# rationals exist (1/3 has no finite decimal form)
		if _StzIsRationalString(@cContent)
			return _StzRationalToFloat(@cContent)
		ok
		# number() not 0+ : Ring's 0+str coercion returns 0 on the first
		# use after ANY caught raise (VM quirk); number() is immune
		return ring_number(@cContent)

		# The numeric value of the number.
		def Value()
			return This.NumericValue()
	

		# Misspelled-but-kept alias of NumericValue.
		def NumbericValue()
			return This.NumericValue()

	# The number as a string (rendered with its round).
	def StringValue()

		# Memorizing the current round (to reset it before leaving)

		_nCurrentRound_ = StzCurrentRound()

		# Activating the round of the number as saved in the object

		StzDecimals(This.Round())

		# Casting the number in a string using the round above

		@cContent = "" + This.NumbericValue()

		# Resetting the round active in the program

		StzDecimals(_nCurrentRound_)

		# Returning the string form of the number

		return @cContent

		def StringValueQ()
			return new stzString( This.StringValue() )

	  #------------------------------------#
	 #  CHECKING IF THE NUMBER IS A CHAR  #
	#------------------------------------#

	def IsChar()

		if This.IsInteger()
			_nTemp_ = This.NumericValue()
			if _nTemp_ >= 0 and _nTemp_ <= 9
				return 1
			ok
		ok

		return 1

		def IsAChar()
			return This.IsChar()

	  #-------------------------#
	 #   UPDATING THE NUMBER   #
	#-------------------------#

	# Replace the content with the given number (mutating; the single
	# update point).
	def Update(pNumber)
		if CheckingParams() = 1

			if isList(pNumber) and Q(pNumber).IsWithOrByOrUsingNamedParam()
				pNumber = pNumber[2]
			ok

			# a FRACTION is a number too (numeric foundation phase 1, slice 3) --
			# Q("1/2").IsNumberInString() is FALSE, so without this the exact
			# rational path could compute an answer the object then refused to hold
			if NOT ( isNumber(pNumber) or
			         ( isString(pNumber) and ( Q(pNumber).IsNumberInString() or
			                                   _StzIsRationalString(pNumber) ) ) )
				StzRaise("Incorrect param type! pNumber must be a number, a string containing " +
				         "a number, or a fraction written p/q.")
			ok

		ok

		# Enforced per-object constraints guard the single update point
		# (typed: the guard sees the NUMBER, not its string form)
		if isString(pNumber)
			if _StzIsRationalString(pNumber)
				# the guard wants the VALUE; a fraction has to be divided out first
				This._NNLGuardUpdate( _StzRationalToFloat(pNumber) )
			else
				This._NNLGuardUpdate(ring_number(StzReplace(pNumber, "_", "")))
			ok
		else
			This._NNLGuardUpdate(pNumber)
		ok

		# THE REGIME IS APPLIED HERE, at the single point a value changes, so a
		# money number is still money after arithmetic, after a round, after
		# anything. (:machine, the default, returns the value untouched -- which is
		# why nothing existing moves.)
		pNumber = This._pvtApplyRegime(pNumber)

		if isString(pNumber)

			@cReturnType = :String

			_oStr_ = new stzString(pNumber)
			@cContent = _oStr_.RemoveQ("_").Content()

			@nRound = StzCurrentRound()

			if _oStr_.Contains(".")
				@nRound = _oStr_.NumberOfChars() - _oStr_.FindFirst(".") + 1
			ok

		else # isNumber(pNumber)

			@cReturnType = :Number

			@cContent = ""+ pNumber
			@nRound = StzCurrentRound()
		ok

	    # Tracing the history of updates (only if not already in history update)
	    if _bInHistoryUpdate = 0
	        @TraceObjectHistory(This)
	    ok

		# Object constraints: DONE -- the enforcement guard at the top of this method

		#< ... >


		#< @FunctionFluentForm

		def UpdateQ(pNumber)
			This.Update(pNumber)
			return This

		#>

		#< @FunctionAlternativeForms

		# Same as Update: replace the content with the given number
		# (mutating).
		def UpdateWith(pNumber)
			This.Update(pNumber)

			def UpdateWithQ(pNumber)
				return This.UpdateQ(pNumber)
	
		# Same as Update: replace the content with the given number
		# (mutating).
		def UpdateBy(pNumber)
			This.Update(pNumber)

			def UpdateByQ(pNumber)
				return This.UpdateQ(pNumber)

		# Same as Update: replace the content with the given number
		# (mutating).
		def UpdateUsing(pNumber)
			This.Update(pNumber)

			def UpdateUsingQ(pNumber)
				return This.UpdateQ(pNumber)

		#>

	# The value the number would be updated to (passive twin of Update).
	def Updated(pNumber)
		return pNumber

		#< @FunctionAlternativeForms

		def UpdatedWith(pNumber)
			return This.Updated(pNumber)

		def UpdatedBy(pNumber)
			return This.Updated(pNumber)

		def UpdatedUsing(pNumber)
			return This.Updated(pNumber)

		#>

	  #--------------------------------------------------#
	 #  GETTING THE UNICODE (CODE POINT) OF THE NUMBER  #
	#--------------------------------------------------#

	/*
		THE NUMBER READ AS A CODEPOINT -- 65 is 'A', 128512 is an emoji.

		That is the convention the rest of the library already keeps:
		stzChar's init treats a NUMBER as a codepoint
		(StzEngineCharToUtf8(pChar)), and ToUnicodeHexForm() documents
		itself as "the number in Unicode hex form (U+0041)". This method
		used to keep it only for 0..9 and, above that, decompose the
		number's DIGITS instead -- so 65 answered [ 54, 53 ], the
		codepoints of '6' and '5'. Two branches of one method disagreed
		about what the number meant.

		Nothing can have depended on the old upper branch: it called a
		method that does not exist (ToChars() on an stzString) and died
		with R14 for every number above 9, until that was repaired in
		the same session as this.

		The digit-decomposition reading still exists, under the name
		that describes it -- Unicodes(), plural, over the STRING form.

		RANGE IS CHECKED HERE, not left to the engine: StzCharQ(-3)
		does not raise, it PANICS the process out of stz_string.dll
		("integer part of floating point value out of bounds"), which
		no try/catch can hold. A legible refusal beats a crash.
	*/
	def Unicode()
		_n_ = This.NumericValue()
		if _n_ != floor(_n_)
			StzRaise("stzNumber.Unicode(): " + _n_ + " is not a codepoint -- " +
				"codepoints are whole numbers. (For the codepoints of the " +
				"number's digits, use Unicodes().)")
		ok
		if _n_ < 0 or _n_ > 1114111
			StzRaise("stzNumber.Unicode(): " + _n_ + " is outside the Unicode " +
				"range 0..1114111 (U+0000..U+10FFFF).")
		ok
		return _n_

	# The codepoints of the number's WRITTEN FORM, digit by digit:
	# 65 -> [ 54, 53 ], the codepoints of '6' and '5'. A different
	# question from Unicode() above, despite the singular/plural
	# names -- that one reads the number AS a codepoint.
	#
	# Chars(), not ToChars(): StringValueQ() hands back an stzString,
	# and ToChars() lives on stzStringUnicodeList -- so this raised
	# R14 for every caller until 2026-08-02.
	def Unicodes()
		_acChars_ = This.StringValueQ().Chars()
		_anResult_ = StzListOfCharsQ(_acChars_).Unicodes()
		return _anResult_

	  #-----------------------------------#
	 #  CHECKING IF THE NUMBER IS DIGIT  #
	#-----------------------------------#

	def IsADigit()
		_n_ = This.NumericValue()
		if 0 <= _n_ and _n_ <= 9
			return 1
		else
			return 0
		ok

		def IsDigit()
			return This.IsADigit()

	  #---------------------------------------------------------#
	 #   CHECKING IF THE NUMBER IS MULTIPLE OF A GIVEN NUMBER  #
	#---------------------------------------------------------#

	def IsMultipleOf(n)

		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		if This.NumericValue() = 0
			return 0
		ok

		if This.NumericValue() % n = 0
			return 1
		else
			return 0
		ok

		def IsAMultipleOf(n)
			return This.IsMultipleOf(n)

		def IsTheMultipleOf(n)
			return This.IsMultipleOf(n)

	def IsDoubleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = DoubleOf(n)
			return 1
		else
			return 0
		ok

		def IsADoubleOf(n)
			return This.IsDoubleOf(n)

		def IsTheDoubleOf(n)
			return This.IsDoubleOf(n)

	def IsTripleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = TripleOf(n)
			return 1
		else
			return 0
		ok

		def IsAtripleOf(n)
			return This.IsTripleOf(n)

		def IsTheTripleOf(n)
			return This.IsTripleOf(n)

	def IsQuadrupleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = QuadrupleOf(n)
			return 1
		else
			return 0
		ok

		def IsAQuadrupleOf(n)
			return This.IsQuadrupleOf(n)

		def IsTheQuadrupleOf(n)
			return This.IsQuadrupleOf(n)

	def IsQuintupleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = QuintupleOf(n)
			return 1
		else
			return 0
		ok

		def IsAQuintupleOf(n)
			return This.IsQuintupleOf(n)

		def IsTheQuintupleOf(n)
			return This.IsQuintupleOf(n)

	def IsSextupleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = SextupleOf(n)
			return 1
		else
			return 0
		ok

		def IsASextupleOf(n)
			return This.IsSextupleOf(n)

		def IsTheSextupleOf(n)
			return This.IsSextupleOf(n)


	def IsOctupleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = OctupleOf(n)
			return 1
		else
			return 0
		ok

		def IsAnOctupleOf(n)
			return This.IsOctupleOf(n)

		def IsTheOctupleOf(n)
			return This.IsOctupleOf(n)

	def IsNonupleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = Nonuple(n)
			return 1
		else
			return 0
		ok

		def IsANonupleOf(n)
			return This.IsNonupleOf(n)

		def IsTheNonupleOf(n)
			return This.IsNonupleOf(n)

	def IsDecupleOf(n)
		if CheckingParams()
			if NOT @IsStringOrNumber(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsNumberInString()
				StzRaise("Incorrect value! The string n must contain a decimal number.")
			ok

		ok

		if isString(n)
			n = StzNumberQ(n).NumericValue()
		ok

		If This.NumericValue() = Decuple(n)
			return 1
		else
			return 0
		ok

		def IsADecupleOf(n)
			return This.IsDecupleOf(n)

		def IsTheDecupleOf(n)
			return This.IsDecupleOf(n)

	  #-----------------#
	 #    BOUNDNESS    #
	#-----------------#

	# TRUE if the number lies between n1 and n2.
	def IsBoundedBy(_n1_, _n2_)
		if CheckingParams()
			if NOT ( @IsStringOrNumber(_n1_) and @IsStringOrNumber(_n2_) )
				StzRaise("Incorrect param type! n1 and n2 must be numbers or strings.")
			ok

			if isString(_n1_) and NOT Q(_n1_).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n1 must contain a decimal number.")
			ok

			if isString(_n2_) and NOT Q(_n2_).IsDecimalNumberInString()
				StzRaise("Incorrect value! The string n2 must contain a decimal number.")
			ok

		ok

		if isString(_n1_)
			_n1_ = StzNumberQ(_n1_).NumericValue()
		ok

		if isString(_n2_)
			_n2_ = StzNumberQ(_n2_).NumericValue()
		ok

		if _n1_ > _n2_
			_nTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nTemp_
		ok
 
		if This.NumericValue() >= _n1_ and This.NumericValue() <= _n2_
			return 1
		else
			return 0
		ok

	  #------------#
	 #    TYPE    #
        #------------#

	# TRUE if the number has no fractional part.
	def IsInteger()
		if NOT This.HasFractionalPart()
			return 1
		else
			return 0
		ok

	# TRUE if the number is an integer greater than zero.
	def IsPositiveInteger()
		if This.IsInteger() and This.IsPositive()
			return 1
		else
			return 0
		ok

	# TRUE if the number is an integer less than zero.
	def IsNegativeInteger()
		if This.IsInteger() and This.IsNegative()
			return 1
		else
			return 0
		ok

	# TRUE if the number has a fractional part.
	def IsReal()
		if This.HasFractionalPart()
			return 1
		else
			return 0
		ok

		def IsRealNumber()
			return This.IsReal()

	# TRUE if the number has more digits than the configured maximum.
	def IsBigNumber()
		if This.NumberOfDigits() > This.MaxNumberOfDigits()
			return 1
		else
			return 0
		ok

	# TRUE if the number is a single-digit integer.
	def IsOneDigit()
		if This.IsInteger() and len(This.Content()) = 1
			return 1
		else
			return 0
		ok

	# TRUE if the number is odd.
	#@ aka  not divisible by two, odd number
	def IsOdd()
		return StzEngineNumberIsOdd(This.NumericValue())

		#< @FunctionAlternativeForm

		def IsFardi() # Added because I have a confusion between odd() and even()
			return This.IsOdd()

		ded IsNotMultipleOf2()
			return This.IsOdd()

		#>

		#< @FunctionNegativeForm

		# TRUE if the number is even.
		def IsNotOdd()
			return NOT This.IsOdd()

		#>

	# TRUE if the number is even.
	#@ aka  divisible by two, even number
	def IsEven()
		return StzEngineNumberIsEven(This.NumericValue())

		#< @FunctionAlternativeForm

		def IsZawji() # Added because I have a confusion between odd() and even()
			return This.IsEven()

		ded IsMultipleOf2()
			return This.IsEven()

		#>

		#< @FunctionNegativeForm

		# TRUE if the number is odd.
		def IsNotEven()
			return NOT This.IsEven()

		#>

	# :Odd or :Even, whichever the number is.
	def IsOddOrEven()
		If This.IsOdd()
			return :Odd
		else
			return :Even
		ok

		def IsEvenOrOdd()
			return This.IsOddOrEven()

		# Two alternatives (in arabic) made
		# because I always get confused in
		# distniguishing Odd fro Even!
		#--> PX, or Programmer Experience

		def IsZawjiOrFardi()
			If This.IsZawji()
				return :Zawji
			else
				return :Fardi
			ok

		def IsFardiOrZawji()
			return This.IsZawjiOrFardi()

	# TRUE if the number is prime.
	#@ aka  prime number, only divisible by one and itself
	def IsPrime()
		if This.IsInteger() and This.IsGreaterThan(1)
			return StzEngineNumberIsPrime( This.NumericValue() )
		else
			return 0
		ok

		def IsAPrimeNumber()
			return This.IsPrime()

		def IsAPrime()
			return This.IsPrime()

		def IsPrimeNumber()
			return This.IsPrime()

	# TRUE if the number is a Wieferich prime.
	def isWeiferich(s)
		_bResult_ = @isWeiferich(This.NumericValue())

	# TRUE if the number is 0 or 1.
	def IsBoolean()
		if This.Number() = 1 or This.Number() = 0
			return 1
		else
			return 0
		ok

	# TRUE if the number is 1.
	def IsTrue()
		if This.Number() = 1
			return 1
		else
			return 0
		ok

	# TRUE if the number is 0.
	def IsFalse()
		if This.Number() = 0
			return 1
		else
			return 0
		ok
		
	  #----------------------------------#
	 #    NULL, POSITIVE OR NEGATIVE    #
	#----------------------------------#

	def IsZero()
		if This.Content() = "0"
			return 1
		else
			return 0
		ok

	#@ aka  below zero, less than zero, minus, negative sign
	def IsNegative()
		if This.Sign() = "-"
			return 1
		else
			return 0
		ok	
		 
	def IsStrictlyNegative()
		if This.IsNegative() or This.IsZero()
			return 1

		else
			return 0
		ok

	#@ aka  above zero, greater than zero, plus, positive sign
	def IsPositive()
		if This.IsNotSigned() or This.Sign() = "+"
			return 1
		else
			return 0
		ok

	def IsStrictlyPositive()
		if This.IsPositive() or This.IsZero()
			return 1

		else
			return 0
		ok

	  #------------#
	 #    SIGN    #
	#------------#
	
	# The sign of the number: "+", "-" or "" for zero.
	def Sign()

		_oStr_ = new stzString(This.Content())
		_cLeft_ = _oStr_.LeftChar()

		if _cLeft_ = "+"
			return "+"

		but _cLeft_ = "-"
			return "-"

		ok

	# Drop the sign from the number (mutating).
	def RemoveSign()
		_cNumber_ = This.Content()
		_nLenNumber_ = len(_cNumber_)

		_cSign_ = This.Sign()

		if _cSign_ = "+" or _cSign_ = "-"

			This.Update( StzReplace(_cNumber_, 2, _nLenNumber_ -2 ) )
		ok

		def RemoveSignQ()
				This.RemoveSign()
				return This

	# A copy without the sign; the original is unchanged.
	def SignRemoved()
		_cResult_ = This.Copy().RemoveSignQ().Content()
		return _cResult_

	# TRUE if the number carries an explicit sign.
	def IsSigned()
		if This.Sign() != ""
			return 1
		else
			return 0
		ok

		# TRUE if the number carries no explicit sign.
		def IsNotSigned()
			return NOT IsSigned()

	# TRUE if the number carries no explicit sign.
	def IsUnsigned()
		if This.IsSigned() = 1
			return 0
		else
			return 1
		ok

	# Same as IsSigned.
	def HasSign()
		return This.IsSigned()

		def HasASign()
			return This.HasSign()

		def ContainsSign()
			return This.HasSign()

		def ContainsASign()
			return This.HasSign()

	  #-------------------#
	 #    COMPARAISON    #
        #-------------------#
	
	def IsEqualTo(pOtherNumber)

		if NOT @IsNumberOrNumberInString(pOtherNumber)
			return 0
		ok

		_nCurrentRound_ = StzCurrentRound()

		StzDecimals(This.Round())

		_bResult_ = (This.NumericValue() = 0+ pOtherNumber)
		StzDecimals(_nCurrentRound_)

		return _bResult_

		#< @FunctionAlternativeForms

		def IsEqual(pOtherNumber)
			if isList(pOtherNumber) and Q(pOtherNumber).IsToNamedParam()
				pOtherNumber = pOtherNumber[2]
			ok

			return This.IsEqualTo(pOtherNumber)

		# TRUE if the number equals the given one.
		def EqualTo(pOtherNumber)
			return This.IsEqual(pOtherNumber)

		def Equals(pOtherNumber)
			return This.IsEqual(pOtherNumber)


		# TRUE if the number equals the given one (case dial for string
		# forms).
		def IsEqualToCS(pOtherNumber, pCaseSensitive)
			return This.IsEqualTo(pOtherNumber)

		def IsEqualCS(pOtherNumber, pCaseSensitive)
			return This.IsEqualTo(pOtherNumber)

		def EqualsCS(pOtherNumber, pCaseSensitive)
			return This.IsEqualTo(pOtherNumber)

		#>

		#< @FunctionNegativeForm

		# TRUE if the number differs from the given one.
		def IsNotEqualTo(pOtherNumber)
			return NOT This.IsEqualTo(pOtherNumber)
	
			#< @FunctionAlternativeForm

			# TRUE if the number differs from the given one.
			def IsDifferentFrom(pOtherNumber)
				return This.IsNotEqualTo(pOtherNumber)

			# TRUE if the number differs from the given one.
			def IsDifferentTo(pOtherNumber)
				return This.IsNotEqualTo(pOtherNumber)

			# TRUE if the number differs from the given one.
			def IsDifferentOf(pOtherNumber)
				return This.IsNotEqualTo(pOtherNumber)

			#>

		#--

		def IsNotEqualToCS(pOtherNumber, pCaseSensitive)
			return This.IsNotEqualTo(pOtherNumber)
	
			#< @FunctionAlternativeForm

			def IsDifferentFromCS(pOtherNumber, pCaseSensitive)
				return This.IsNotEqualTo(pOtherNumber)

			def IsDifferentToCS(pOtherNumber, pCaseSensitive)
				return This.IsNotEqualTo(pOtherNumber)

			def IsDifferentOfCS(pOtherNumber, pCaseSensitive)
				return This.IsNotEqualTo(pOtherNumber)

			#>

		#>

		#< @FunctionMisspelledForm

		def IsEqualtTo(pcOtherNumber)
			return This.IsEqualTo(pcOtherNumber)

			def IsEqualtToCS(pcOtherNumber, pCaseSensitive)
				return This.IsEqualTo(pcOtherNumber)

		#>

	#=====

	# TRUE if the number equals NEITHER of the two given numbers.
	def IsNeither(_n1_, _n2_)
		if CheckingParams()
			if isList(_n1_) and Q(_n1_).IsEqualToNamedParam()
				_n1_ = _n1_[2]
			ok

			if isList(_n2_) and Q(_n2_).IsNorNamedParam()
				_n2_ = _n2_[2]
			ok

			if @BothAreStrings(_n1_, _n2_) and
			   NOT @BothAreNumbersInStrings(_n1_, _n2_)

				return This.@IsNeither(_n1_, _n2_)
			ok

			if NOT ( @BothAreNumbers(_n1_, _n2_) or @BothAreNumbersInStrings(_n1_, _n2_) )
				StzRaise("Incorrect param type! n1 and n2 must both be numbers or numbers in strings.")
			ok
		ok

		_bEqualToN1_ = This.IsEqualTo(_n1_)
		_bEqualToN2_ = This.IsEqualTo(_n2_)

		if NOT _bEqualToN1_ and NOT _bEqualToN2_
			return 1
		else
			return 0
		ok

		def IsNeitherEqualTo(_n1_, _n2_)
			return This.IsNeither(_n1_, _n2_)

	# TRUE if the number is less than or equal to the given one.
	def IsLess(pOtherNumber)
		if CheckingParams()
			if NOT Q(pOtherNumber).IsNumberOrString()
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_nCurrentRound_ = StzCurrentRound()

		StzDecimals(This.Round())
		_bResult_ = (This.NumericValue() <= 0+ pOtherNumber)
		StzDecimals(_nCurrentRound_)

		return _bResult_

		#< @FunctionAlternativeForms

		def IsLessThan(pOtherNumber)
			return This.IsLess(pOtherNumber)

		def IsLessOrEqualTo(pOtherNumber)
			return This.IsLess(pOtherNumber)

		def IsSmallerOrEqualTo(pOtherNumber)
			return This.IsLess(pOtherNumber)

		def IsEqualOrLessThan(pOtherNumber)
			return This.IsLess(pOtherNumber)

		def IsEqualOrSmallerThan(pOtherNumber)
			return This.IsLess(pOtherNumber)

		def IsSmallerThqn(pOtherNumber)
			return This.IsLess(pOtherNumber)

		#>
	
	# TRUE if the number is strictly less than the given one.
	#
	# FIXED 2026-07-25: the canonical method was spelled IsStriclyLess (missing a
	# "t") while all SIX of its alternative forms below called the correct
	# IsStrictlyLess -- so every one of them raised R14. Canonical name corrected;
	# the misspelling is kept as an alias.
	def IsStrictlyLess(pOtherNumber)
		if CheckingParams()
			if NOT Q(pOtherNumber).IsNumberOrString()
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_nCurrentRound_ = StzCurrentRound()

		StzDecimals(This.Round())
		_bResult_ = (This.NumericValue() < 0+ pOtherNumber)
		StzDecimals(_nCurrentRound_)

		return _bResult_

		#< @FunctionAlternativeForms

		# TRUE if the number is strictly less than the given one.
		def IsStrictlyLessThan(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		# TRUE if the number is less than or equal to the given one.
		def IsStrictlyLessOrEqualTo(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		# TRUE if the number is less than or equal to the given one.
		def IsStrictlySmallerOrEqualTo(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		# TRUE if the number is less than or equal to the given one.
		def IsStrictlyEqualOrLessThan(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		# TRUE if the number is less than or equal to the given one.
		def IsStrictlyEqualOrSmallerThan(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		# Misspelled-but-kept alias of IsStrictlyLessThan.
		def IsStrictlySmallerThqn(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		# the historical misspelling of the canonical name, kept for callers
		def IsStriclyLess(pOtherNumber)
			return This.IsStrictlyLess(pOtherNumber)

		#>

	# TRUE if the number is greater than or equal to the given one.
	def IsGreater(pOtherNumber)
		if CheckingParams()
			if NOT Q(pOtherNumber).IsNumberOrString()
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_nCurrentRound_ = StzCurrentRound()

		StzDecimals(This.Round())
		_bResult_ = (This.NumericValue() >= 0+ pOtherNumber)
		StzDecimals(_nCurrentRound_)

		return _bResult_

		#< @FunctionAlternativeForms

		def IsGreaterThan(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsEqualOrGreater(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsEqualOrGreaterThan(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsBigger(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsBiggerThan(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsEqualOrBigger(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsEqualOrBiggerThan(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		#>

	# TRUE if the number is strictly greater than the given one.
	def IsStrictlyGreater(pOtherNumber)
		if CheckingParams()
			if NOT Q(pOtherNumber).IsNumberOrString()
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_nCurrentRound_ = StzCurrentRound()

		StzDecimals(This.Round())
		_bResult_ = (This.NumericValue() > 0+ pOtherNumber)
		StzDecimals(_nCurrentRound_)

		return _bResult_

		#< @FunctionAlternativeForms

		def IsStrictlyGreaterThan(pOtherNumber)
			return This.IsStrictlyGreater(pOtherNumber)

		def IsStrictlyEqualOrGreater(pOtherNumber)
			return This.IsStrictlyGreater(pOtherNumber)

		def IsStrictlyEqualOrGreaterThan(pOtherNumber)
			return This.IsGreater(pOtherNumber)

		def IsStrictlyBigger(pOtherNumber)
			return This.IsStrictlyGreater(pOtherNumber)

		def IsStrictlyBiggerThan(pOtherNumber)
			return This.IsStrictlyGreater(pOtherNumber)

		def IsStrictlyEqualOrBigger(pOtherNumber)
			return This.IsStrictlyGreater(pOtherNumber)

		def IsStrictlyEqualOrBiggerThan(pOtherNumber)
			return This.IsStrictlyGreater(pOtherNumber)

		#>

	# TRUE if the number lies between the two given numbers (bounds
	# included).
	def IsBetween(pNumber1, pNumber2)

		if CheckingParams()
			if isList(pNumber2) and Q(pNumber2).IsAndNamedParam()
				pNumber2 = pNumber2[2]
			ok
	
			if NOT ( Q(pNumber1).IsNumberOrString() and Q(pNumber2).IsNumberOrString() )
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_n1_ = 0+ pNumber1
		_n2_ = 0+ pNumber2

		_n_ = This.NumericValue()

		_bResult_ = 1

		if NOT ( _n1_ < _n_ and _n_ < _n2_ )
			_bResult_  = 0
		ok

		return _bResult_

	# TRUE if the number lies between the two given numbers, bounds
	# INCLUDED (IB).
	def IsBetweenIB(pNumber1, pNumber2)

		if CheckingParams()
			if isList(pNumber2) and Q(pNumber2).IsAndNamedParam()
				pNumber2 = pNumber2[2]
			ok
	
			if NOT ( Q(pNumber1).IsNumberOrString() and Q(pNumber2).IsNumberOrString() )
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_n1_ = 0+ pNumber1
		_n2_ = 0+ pNumber2

		_n_ = This.NumericValue()

		_bResult_ = 1

		if NOT ( _n1_ <= _n_ and _n_ <= _n2_ )
			_bResult_  = 0
		ok

		return _bResult_

		def IsBetweenXT(pNumber1, pNumber2)
			return This.IsBetweenIB(pNumber1, pNumber2)

	# TRUE if the number lies strictly between the two given numbers
	# (bounds excluded).
	def IsStrictlyBetween(pNumber1, pNumber2)
		if CheckingParams()
			if isList(pNumber2) and Q(pNumber2).IsAndNamedParam()
				pNumber2 = pNumber2[2]
			ok
	
			if NOT ( Q(pNumber1).IsNumberOrString() and Q(pNumber2).IsNumberOrString() )
				StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
			ok
		ok

		_nCurrentRound_ = StzCurrentRound()
		StzDecimals(This.Round())

		_bResult_ = ( This.NumericValue() > 0+ pNumber1 and
			    This.NumericValue() < 0+ pNumber2 )

		StzDecimals(_nCurrentRound_)

		return _bResult_

	# Quiet equality: TRUE if the values match, tolerating
	# number/string form.
	def IsQuietEqualTo(pOtherNumber)

		if NOT Q(pOtherNumber).IsNumberOrString()
			StzRaise("Incorrect param types! pNumber1 and pNumber2 must be numbers or strings.")
		ok

		_nCurrentRound_ = StzCurrentRound()

		StzDecimals(This.Round())
		_bResult_ = ( fabs( (This - pOtherNumber).NumericValue() ) <= QuietEqualityRatio() )
		StzDecimals(_nCurrentRound_)

		return _bResult_

		def IsQuietEqual(pOtherNumber)
			return This.IsQuietEqualTo(pOtherNumber)

		def IsApproximativelyEqual(pOtherNumber)
			return This.IsQuietEqualTo(pOtherNumber)

		def IsApproximativelyEqualTo(pOtherNumber)
			return This.IsQuietEqualTo(pOtherNumber)

	  #-------------------------------------------------------------#
	 #    INTEGER & FRACTIONAL PARTS (CALLED ALSO DECIMAL PARTS)   #
	#-------------------------------------------------------------#

	def NumberOfDigits()
		return This.NumberOfDigitsInIntegerPart() + This.NumberOfDigitsInFractionalPart()

		#< @FunctionAlternativeForm

		def NumberOfDigitsTheNumberActuallyContains()
			return This.NumberOfDigits()

		#>

	def IntegerPart()
		if This.HasFractionalPart()
			return This.ToStzString().Split(".")[1]
		else
			return This.Content()
		ok

		#< @FunctionFluentForms

		# FIXED 2026-07-25: this was named IntegrPartQ (missing an "e") and its body
		# called This.InterPart() (missing "eger") -- two typos in three lines, so the
		# correctly-named IntegerPartQ that six sibling forms call never existed.
		def IntegerPartQ()
			return new stzString(This.IntegerPart())

			# the historical misspelling, kept so existing callers keep working
			def IntegrPartQ()
				return This.IntegerPartQ()

		def IntegerPartStringValue()
			return This.IntegerPart()

			def IntegerPartStringValueQ()
				return This.IntegrPartQ()

		#>

		#< @FunctionMisspelledForms

		def IntergerPart()
			return This.IntegerPart()

			def IntergerPartQ()
				return This.IntegerPartQ()

		def IntergerPartStringValue()
			return This.IntegerPart()

			def IntergerPartStringValueQ()
				return This.IntegrPartQ()

		#>

	def IntegerPartWithoutSign()
		if NOT This.IsSigned()
			return This.IntegerPart()
		ok
		# FIXED 2026-07-25: this called StzReplace(host, 2, len-1) -- passing NUMBERS
		# where a replace wants the substring to find and the one to put in its place,
		# so it raised "cStr, cSubStr and cNewSubStr must all be strings". The intent
		# is plainly a SUBSTRING (from position 2, taking the rest), i.e. drop the
		# leading sign. It surfaced only once ApplyFormatXT could reach it at all.
		return StzMidToEnd( This.IntegerPart(), 2 )

		def IntegerPartWithoutSignQ()
			return new stzString(This.IntegerPartWithoutSign())

		def IntegerPartStringValueWithoutSign()
			return This.IntegerPartWithoutSign()

			def IntegerPartStringValueWithoutSignQ()
				return This.IntegerPartWithoutSignQ()

	def NumberOfDigitsInIntegerPart()
		if This.Sign() = ""
			return len(This.IntegerPart())
		else
			return len(This.IntegerPart()) - 1
		ok

		def NumberOfIntegers()
			return This.NumberOfDigitsInIntegerPart()

	def HasFractionalPart()
		if This.ToStzString().Contains(".")
			return 1
		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def HasDecimalPart()
			return This.HasFractionalPart()

		def ContainsFractionalPart()
			return This.HasFractionalPart()

		def ContainsDecimalPart()
			return This.HasFractionalPart()

		#--

		def HasAFractionalPart()
			return This.HasFractionalPart()

		def HasADecimalPart()
			return This.HasFractionalPart()

		def ContainsAFractionalPart()
			return This.HasFractionalPart()

		def ContainsADecimalPart()
			return This.HasFractionalPart()

		#>

	// Returns the fraction part of the number (with a leading "0.")
	def FractionalPart()
		if This.HasFractionalPart()
			if This.IsNegative()
				return "-0." + This.FractionalPartWithoutZeroDot()
			else
				return "0." + This.FractionalPartWithoutZeroDot()
			ok
		ok

		def FractionalPartQ()
			return new stzString(This.FractionalPart())

		def DecimalPart()
			return This.FractionalPart()

			def DecimalPartQ()
				return This.FractionalPartQ()

		def FractionalPartStringValue()
			return This.FractionalPart()

			def FractionalPartStringValueQ()
				return This.FractionalPartQ()

		def DecimalPartStringValue()
			return This.FractionalPart()

			def DecimalPartStringValueQ()
				return This.FractionalPartQ()

	// Returninig only the digits of the fractional part without the "0."
	def FractionalPartWithoutZeroDot()
		if This.HasFractionalPart()
			return This.ToStzString().Split(".")[2]
		else
			return ""
		ok

		#< @FunctionFluentForm

		def FractionalPartWithoutZeroDotQ()
			return new stzString(This.FractionalPartWithoutZeroDot())

		#>

		#< @FunctionAlternativeForms


		def DecimalPartWithoutZeroDot()
			return This.FractionalPartWithoutZeroDot()

			def DecimalPartWithoutZeroDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		def FractionalPartWithoutDot()
			return This.FractionalPartWithoutZeroDot()

			def FractionalPartWithoutDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		def DecimalPartWithoutDot()
			return This.FractionalPartWithoutZeroDot()

			def DecimalPartWithoutDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		#>

		#< @FunctionMisspelledForms # without -> wihtout

		def FractionalPartwihtoutZeroDot()
			return This.FractionalPartWithoutZeroDot()

			def FractionalPartwihtoutZeroDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		def DecimalPartwihtoutZeroDot()
			return This.FractionalPartWithoutZeroDot()

			def DecimalPartwihtoutZeroDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		def FractionalPartwihtoutDot()
			return This.FractionalPartWithoutZeroDot()

			def FractionalPartwihtoutDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		def DecimalPartwihtoutDot()
			return This.FractionalPartWithoutZeroDot()

			def DecimalPartwihtoutDotQ()
				return This.FractionalPartWithoutZeroDotQ()

		#>

	def NumberOfDecimals()
		return len(This.FractionalPartWithoutZeroDot())

	def NumberOfDigitsInFractionalPart()
		if NOT This.HasFractionalPart()
			return 0
		else
			return len(This.FractionalPartWithoutZeroDot())
		end

		def NumberOfDigitsInDecimalPart()
			return This.NumberOfDigitsInFractionalPart()

	def MaxNumberOfDigits() # Maximum number of digits the number can contain
		_nMaxDigits_ = 0
		switch This.IsIntegerOrReal()
		on "INTEGER"
			if This.IsSigned()
				_nMaxDigits_ = MaxNumberOfDigitsInSignedInteger()
			else
				_nMaxDigits_ = MaxNumberOfDigitsInUnsignedInteger()
			ok
		
		on "REAL"
			if This.IsSigned()
				_nMaxDigits_ = MaxNumberOfDigitsInSignedRealNumber()
			else
				_nMaxDigits_ = MaxNumberOfDigitsInUnsignedRealNumber()
			ok
		off
		
		return _nMaxDigits_

		#< @FunctionAlternativeForm

		def MaxNumberOfDigitsTheNumberCanContain()
			return This.MaxNumberOfDigits()

		#>

	def IsIntegerOrReal()
		if This.IsInteger()
			return "INTEGER"
		but This.IsReal()
			return "REAL"
		ok
		
		#< @FunctionMisspelledForm

		def IsIntergerOrReal()
			return This.IsIntegerOrReal()

		#>

	def Integers()
		_anResult_ = This.IntegerPartWithoutSignQ().CharsQ().Numberified()
		return _anResult_

		#< @FunctionFluentFroms

		def IntegersQ()
			return This.IntegersQRT(:stzList)

		def IntegersQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Integers() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Integers() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionMisspelledForms

		def Intergers()
			return This.Integers()

			def IntergersQ()
				return This.IntegersQ()

			def IntergersQRT(pcReturnType)
				return This.IntegersQRT(pcReturnType)

		#>

	def Decimals()
		_anResult_ = This.DecimalPartWihtoutDotQ().CharsQ().Numberified()
		#NOTE // This is a misspelled form in Wihtout (sould be Without)
		# But Softanza recognises it understands what you meant!

		return _anResult_

		#< @FunctionFluentFroms

		def DecimalsQ()
			return This.DecimalsQRT(:stzList)

		def DecimalsQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Decimals() )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.Decimals() )

			other
				StzRaise("Unsupported return type!")
			off

		#>

	def SumOfIntegers()
		_nResult_ = This.IntegersQRT(:stzListOfNumbers).Sum()
		return _nResult_

	def SumOfDecimals()
		_nResult_ = This.DecimalsQRT(:stzListOfNumbers).Sum()
		return _nResult_

	  #--------------#
	 #    ROUNDS    #
	#--------------#

	/*
	TODO: Actually, softanza rounds numbers using the native rounding service
	      provided by Ring decimals() standard function.

	      In the future, Study and reflect on enabling _Those_ rounding modes:
	      	- RoundCeiling: see if it is same as RoundUp()?
	       	- RoundFloor: see if it is same as RoundDown()?
	       	- RoundDown,
	       	- RoundUp,
	       	- RoundHalfEven,
	       	- RoundHalfDown,
	       	- RoundHalfUp,
	       	- RoundUnnecessary
	*/

	# The largest round (decimals) this number can still carry.
	def MaxRound()
		_nResult_ = len( ""+ MaxNumberInRing() ) - This.NumberOfIntegers()

		if This.ContainsDecimalPart()
			_nResult_ -= (1 + This.NumberOfDecimals())
		ok

		return _nResult_

	# How many more decimals can be added before the max round.
	def NumberOfRoundsWeCanAddBeforeMaxRoundIsReached()

		_nResult_ =  This.MaxNumberOfDigitsTheNumberCanContain() -
		      	   This.NumberOfDigitsTheNumberActuallyContains()

		return _nResult_

	#@ aka  round to nearest, nearest whole number, round off
	# Round the number to the nearest integer (mutating).
	  #-- THE REGIME (numeric foundation phase 2) --------------------------

	def SetRegime(pcRegime, pnPlaces)
		@cRegime = pcRegime
		@nRegimePlaces = pnPlaces
		# apply it to the value it was born with
		This.Update( This.Content() )
		return This

	#@ aka  what kind of quantity, which regime, money or exact
	def Regime()
		return @cRegime

	def RegimePlaces()
		return @nRegimePlaces

	def IsMoney()
		return @cRegime = :money

	def IsMeasured()
		return @cRegime = :measured

	def IsExactRegime()
		return @cRegime = :exact

	# Bring a value into line with the regime. Money and measurements ROUND (always
	# banker's -- the bias argument in the tie-rule guard applies to every total).
	# An exact quantity does not round at all: if the value cannot be held exactly
	# it RAISES, because silently approximating is the one thing that regime exists
	# to prevent.
	def _pvtApplyRegime(pcValue)
		_c_ = "" + pcValue
		if @cRegime = :money or @cRegime = :measured
			if _StzIsPlainDecimal(_c_)
				return _StzRoundDecimalString(_c_, @nRegimePlaces, :HalfEven)
			ok
			return _c_
		ok
		if @cRegime = :exact
			if This.IsApproximate()
				StzRaise("This number is EXACT by regime, and '" + _c_ + "' is not an " +
				         "exact value: " + This.WhyNotExact() + ". Use a fraction (p/q) " +
				         "for a quotient that does not terminate, or StzNumberQ for a " +
				         "value that may be approximate.")
			ok
		ok
		return _c_

	  #-- ROUNDING, WITH THE MODE IN THE VERB (numeric foundation phase 2)--
	  #
	  # Scope-Oriented Programming, move M3: the frame goes in the VERB at the call
	  # site, not in a setting made somewhere else. Regex says MatchLine() rather
	  # than Match()-with-a-flag; this says RoundedToHalfEven(2) rather than
	  # RoundedTo(2) with a mode set three lines up.
	  #
	  # The tie rule is exactly the kind of frame the paradigm is about: it is
	  # invisible at the call site, it changes the answer, and money depends on it.
	  # Half-up is BIASED -- every tie moves the same way, so over a long ledger the
	  # total drifts upward. Half-even splits ties and the bias cancels. That is why
	  # accounting uses it, and why it deserves a name you can see.
	  #
	  # RoundedTo() keeps its historical half-up behaviour, so nothing existing
	  # moves; the mode is something you ASK for.

	#@ aka  banker's rounding, round half to even, accounting rounding
	def RoundedToHalfEven(pnPlaces)
		return _StzRoundDecimalString("" + This.Content(), pnPlaces, :HalfEven)

		def RoundedToHalfEvenQ(pnPlaces)
			return new stzNumber(This.RoundedToHalfEven(pnPlaces))

		def RoundToHalfEven(pnPlaces)
			This.Update( This.RoundedToHalfEven(pnPlaces) )

			def RoundToHalfEvenQ(pnPlaces)
				This.RoundToHalfEven(pnPlaces)
				return This

	#@ aka  round half away from zero, commercial rounding
	def RoundedToHalfUp(pnPlaces)
		return _StzRoundDecimalString("" + This.Content(), pnPlaces, :HalfUp)

		def RoundedToHalfUpQ(pnPlaces)
			return new stzNumber(This.RoundedToHalfUp(pnPlaces))

		def RoundToHalfUp(pnPlaces)
			This.Update( This.RoundedToHalfUp(pnPlaces) )

			def RoundToHalfUpQ(pnPlaces)
				This.RoundToHalfUp(pnPlaces)
				return This

	  #-- THE REPRESENTATION LADDER (numeric foundation phase 1) ----------
	  #
	  # stzNumber keeps ONE front door and carries a representation inside, rather
	  # than making the caller pick between six classes. This reports which rung the
	  # value is currently on, so the ladder is observable instead of folklore:
	  #
	  #   :integer     a whole number inside the range an f64 represents exactly
	  #   :bigInteger  a whole number beyond that (2^53), held exactly as digits
	  #   :decimal     a value with a fractional part, held exactly as digits
	  #
	  # Promotion is automatic and upward only: adding 1 to a 2^53 integer yields a
	  # :bigInteger, and nothing silently demotes. :rational and :complex are named
	  # in the plan and not built yet, so they are not reported -- a ladder that
	  # claims rungs it does not have is worse than a short one.

	#@ aka  which representation, what kind of number, integer or decimal
	def Representation()
		_c_ = "" + This.Content()
		if _StzIsRationalString(_c_)
			return :rational
		ok
		if _StzPlacesOf(_c_) > 0
			return :decimal
		ok
		if NOT _pvtLooksLikeInteger(_c_)
			return :decimal          # anything else is carried as a decimal string
		ok
		if len( _StzDigitsOnly(_c_) ) > 15
			return :bigInteger
		ok
		return :integer

	def IsBigInteger()
		return This.Representation() = :bigInteger

	def IsDecimalNumber()
		return This.Representation() = :decimal

	def IsRational()
		return This.Representation() = :rational

	  #-- EXACTNESS (numeric foundation phase 1) --------------------------
	  #
	  # Numeric surprise is almost always about a frame the caller could not see:
	  # a rounding, a binary-float representation, a division that does not
	  # terminate. So the number carries that fact rather than making you deduce
	  # it -- the same habit as the natural layer's evidential register.

	#@ aka  is it exact, was anything lost, is this precise
	def IsExact()
		return @cExactness = :exact

	def IsApproximate()
		return NOT This.IsExact()

	# Empty when the value is exact; otherwise a plain sentence saying what was
	# lost and where.
	#@ aka  why not exact, what was lost, explain the precision
	def WhyNotExact()
		return @cInexactReason

		def Why()
			return This.WhyNotExact()

	def Exactness()
		return @cExactness

	# MATHEMATICAL equality, as opposed to Ring's `=` on the rendered strings.
	# "1.50" and "1.5" are the same number; "0.1" and 0.1 are not the same BITS.
	#@ aka  same number, equal in value, numerically equal
	def Same(pOther)
		_cOther_ = ""
		if isObject(pOther)
			_cOther_ = "" + pOther.Content()
		but isString(pOther)
			_cOther_ = pOther
		but isNumber(pOther)
			_cOther_ = "" + pOther
		else
			return 0
		ok
		# a fraction compares by cross-multiplication, so "1/2" and "0.5" are the
		# same number and "1/3" is not 0.333...
		if _StzIsRationalString("" + This.Content()) or _StzIsRationalString(_cOther_)
			_x_ = _StzAsRationalParts("" + This.Content())
			_y_ = _StzAsRationalParts(_cOther_)
			_pL_ = StzEngineBigIntMul( StzEngineBigIntFromString(_x_[1]),
			                           StzEngineBigIntFromString(_y_[2]) )
			_pR_ = StzEngineBigIntMul( StzEngineBigIntFromString(_y_[1]),
			                           StzEngineBigIntFromString(_x_[2]) )
			if _pL_ = "" or _pR_ = ""
				return 0
			ok
			return StzEngineBigIntEquals(_pL_, _pR_)
		ok
		return _StzSameNumberString("" + This.Content(), _cOther_)

		def IsSameAs(pOther)
			return This.Same(pOther)

	def Round()
		return @nRound

		#< @FunctionAlternativeForms

		# These alternatives are provided to the user if
		# he wants to avoid semantic confustion the global
		# function Round(). This function is made to enable
		# external code in other languages.

		def GetRound()
			return This.Round()

		# The current round (decimals) of the number.
		def NumberRound()
			return This.Round()

		#>

	def RoundToXT(_nRound_)
		if CheckingParams()
			if isString(_nRound_) and _nRound_ = :Max
				_nRound_ = MaxRoundInRing()
			ok

			if NOT isNumber(_nRound_)
				StzRaise("Incorrect param type! nRound must be a number.")
			ok
		ok

		if _nRound_ > MaxRoundInRing()
			StzRaise("Incorrect round! nRound can't exceed the maxround in Ring, " + MaxRound() + ".")
		ok

		@nRound = _nRound_

		_nCurrentRound_ = StzCurrentRound()
		StzDecimals(_nRound_)
		@cContent = ""+ This.NumericValue()

		if This.IsInteger() and _nRound_ > 0
			@cContent += "."
			for _i_ = 1 to _nRound_
				@cContent += "0"
			next
		ok

		StzDecimals(_nCurrentRound_)

		#< @FunctionFluentForm

		def RoundToXTQ(pRound)
			This.RoundToXT(pRound)
			return This

		#>

		#< @FunctionAlternativeForm

		def SetRoundXT(_nRound_)
			This.RoundToXT(_nRound_)

			def SetRoundXTQ(_nRound_)
				return This.RoundToXTQ(_nRound_)

		#>

	def RoundedToXT(pRound)
		_cResult_ = This.Copy().RoundToXTQ(pRound).Content()
		return _cResult_

	#--

	def RoundToMaxXT()
		This.RoundToXT(:Max)


	def RoundedToMaxXT()
		return This.RoundedTo(MaxRoundXT())

	#---

	# Round the number to the given number of decimals (mutating).
	#@ aka  decimals, precision, digits after the point
	def RoundTo(_nRound_)
		# Round to _nRound_ places, then TIDY: "12.4560" reads back as "12.456".
		# That tidying is deliberate -- test 61_roundedto records RoundedTo(4) of
		# 12.456 as "12.456" and not "12.4560".
		#
		# FIXED 2026-07-25. It was done with RemoveThisTrailingCharQ("0") over the
		# WHOLE string, which is only safe while a decimal point survives. Once the
		# rounding removed it, the strip ate the INTEGER's zeros:
		#
		#     RoundedTo(0) of  10.4  ->  "1"      (a 10x error)
		#     RoundedTo(0) of 100.4  ->  "1"      (a 100x error)
		#     RoundedTo(0) of 0.125  ->  ""       -> the constructor then RAISED
		#
		# Silently, and in the method every caller uses to round a number. The strip
		# now applies to the FRACTIONAL part only -- the same rule and the same
		# helper that RemoveZerosFromRight uses, for the same reason: a trailing zero
		# left of the point is a place value, not noise.
		_cRounded_ = "" + This.RoundToXTQ(_nRound_).ToStzString().Content()
		_cResult_ = _StzStripTrailingFractionZeros(_cRounded_)
		if _cResult_ = "" or _cResult_ = "-"
			_cResult_ = "0"
		ok

		This.Update(_cResult_)

		#< @FunctionFluentForm

		def RoundToQ(pRound)
			This.RoundTo(pRound)
			return This

		#>

		#< @FunctionAlternativeForm

		# Set how many decimals (the round) this number renders with.
		def SetRound(_nRound_)
			This.RoundTo(_nRound_)

			def SetRoundQ(_nRound_)
				return This.RoundToQ(_nRound_)

		#>

	# A copy rounded to the given number of decimals; the original
	# is unchanged.
	def RoundedTo(pRound)
		_cResult_ = This.Copy().RoundToQ(pRound).Content()
		return _cResult_

	#--

	# Round to the maximum round available (mutating).
	def RoundToMax()
		This.RoundTo(:Max)

	# A copy rounded to the maximum round available.
	def RoundedToMax()
		return This.RoundedTo(MaxRound())

	#---

	# The number rounded UP (toward the next integer).
	def RoundUp()
		return This.pvtCalculate( "floor", "" )

	# The number rounded DOWN (toward the previous integer).
	def RoundDown()
		return This.pvtCalculate( "ceil", "" )
			
	# Round to the same number of decimals as the given number
	# (mutating).
	def RoundToSameRoundAs(pOtherNumber)
		_oOtherNumber_ = new stzNumber(pOtherNumber)
		_nRoundOtherNumber_ = _oOtherNumber_.Round()

		This.RoundTo(_nRoundOtherNumber_)

	# TRUE if this number carries more decimals than the given one.
	def RoundIsGreaterThanRoundOf(pOtherNumber)

		_nRound_ = This.Round()

		_oOtherNumber_ = new stzNumber(pOtherNumber)
		_nOtherRound_ = _oOtherNumber_.NumberOfDigits()

		if _nRound_ > _nOtherRound_
			return 1
		else
			return 0
		ok

	# TRUE if this number carries fewer decimals than the given one.
	def RoundIsLessThanRoundOf(pOtherNumber)
		_nRound_ = This.Round()

		_oOtherNumber_ = new stzNumber(pOtherNumber)
		_nOtherRound_ = _oOtherNumber_.NumberOfDigits()

		if _nRound_ < _nOtherRound_
			return 1
		else
			return 0
		ok
	
	# TRUE if both numbers carry the same number of decimals.
	def RoundIsSameAsRoundOf(pOtherNumber)
		_nRound_ = This.Round()

		_oOtherNumber_ = new stzNumber(pOtherNumber)
		_nOtherRound_ = _oOtherNumber_.NumberOfDigits()

		if _nRound_ = _nOtherRound_
			return 1
		else
			return 0
		ok

	# Compare the rounds: :Greater, :Less or :Same.
	def CompareRoundsWith(pOtherNumber)
		# FIXED 2026-07-25: these were called as IsRound...; the methods are named
		# RoundIs... (defined just above). Three R14s in one three-branch switch.
		if  This.RoundIsSameAsRoundOf(pOtherNumber)
			return :Equal

		but This.RoundIsGreaterThanRoundOf(pOtherNumber)
			return :Greater

		but This.RoundIsLessThanRoundOf(pOtherNumber)
			return :Less
		ok

	  #----------------#
	 #    ADDITION    #
	#----------------#

	# Add the given number to this one (mutating). For a copy, use
	# Added.
	#@ aka  plus, sum, increase, increment
	def Add(pOtherNumber)
		_StzHistoOpen(This.NumericValue())
		This.Update( pvtCalculate("+", pOtherNumber ) )
		_StzHistoAdd(This.NumericValue())

		#< @FunctionFluentForm

		def AddQ(pOtherNumber)
			This.Add(pOtherNumber)
			return This

		#>

	#-- @FunctionPassiveForm

	# The sum with the given number, as data; the original is
	# unchanged.
	def Added(pOtherNumber)
		_nResult_ = This.Copy().AddQ(pOtherNumber).NumericValue()
		return _nResult_


	# Add each of the given numbers to this number (mutating).
	def AddMany(paOtherNumbers)
		This.AddManyXT(paOtherNumbers, :ReturnIntermediateResults = 0)

		#< @FunctionFluentForm

		def AddManyQ(paOtherNumbers)
			This.AddMany(paOtherNumbers)
			return This

		#>

		#< @FunctionAlternativeForm

		# Same as AddMany.
		def AddThese(paOtherNumbers)
			This.AddMany(paOtherNumbers)

			def AddTheseQ(paOtherNumbers)
				This.AddThese(paOtherNumbers)
				return This

		#>

	#-- @FunctionPassiveForm

	# The sum with all the given numbers, as data; the original is
	# unchanged.
	def AddedMany(pOtherNumbers)
		_nResult_ = This.Copy().AddManyQ(pOtherNumbers).NumbericValue()
		return _nResult_


		def ManyAdded(pOtherNumbers)
			return This.AddedMany(pOtherNumbers)

			def TheseAdded(pOtherNumbers)
				return This.ManyAdded(pOtherNumbers)

		#>
	
	# AddMany returning every intermediate sum along the way.
	def AddManyWithIntermediateResults(paOtherNumbers)
		return This.AddManyXT(paOtherNumbers, :ReturnIntermediateResults = 1)

		#< @FunctionFluentForm

		def AddManyWithIntermediateResultsQ(paOtherNumbers)
			return new stzListOfNumbers( This.AddManyWithIntermediateResults(paOtherNumbers) )
	
		#>

		#< @FunctionAlternativeForm

		def AddTheseWithIntermediateResults(paOtherNumbers)
			This.AddManyWithIntermediateResults(paOtherNumbers)

			def AddTheseWithIntermediateResultsQ(paOtherNumbers)
				This.AddTheseWithIntermediateResults(paOtherNumbers)
				return This

		#>

	def AddManyXT(paOtherNumbers, paReturnIntermediateResults)
		if CheckingParams()
			if NOT ( isList(paOtherNumbers) and @IsListOfNumbersOrStrings(paOtherNumbers) )
				StzRaise("Incorrect param type! paOtherNumbers must be a list of numbers or strings.")
			ok
		ok

		_bReturnIntermediateResults_ = 0

		if paReturnIntermediateResults[1] = :ReturnIntermediateResults and
		   paReturnIntermediateResults[2] = 1

			_bReturnIntermediateResults_ = 1
		ok

		_nLen_ = len(paOtherNumbers)
		_aIntermediateResults_ = []

		for _i_ = 1 to _nLen_
			This.Add(paOtherNumbers[_i_])
			_aIntermediateResults_ + This.Content()
		next

		if _bReturnIntermediateResults_
			return _aIntermediateResults_
		ok

		#< @FunctionFluentForm

		def AddManyXTQ(paOtherNumbers, paReturnIntermediateResults)
			return new stzListOfNumbers( This.AddManyXT(paOtherNumbers, paReturnIntermediateResults) )
	
		#>

		#< @FunctionAlternativeForm

		def AddTheseXT(paOtherNumbers, paReturnIntermediateResults)
			This.AddManyXT(paOtherNumbers, paReturnIntermediateResults)

			def AddTheseXTQ(paOtherNumbers, paReturnIntermediateResults)
				This.AddTheseXT(paOtherNumbers, paReturnIntermediateResults)
				return This

		#>

	  #--------------------#
	 #    SubStructION    #
	#--------------------#

	# Subtract the given number from this one (mutating).
	#@ aka  subtract, minus, decrease, take away
	def SubStruct(pOtherNumber)

		_StzHistoOpen(This.NumericValue())
		This.Update( pvtCalculate("-", pOtherNumber ) )
		_StzHistoAdd(This.NumericValue())

		#< @FunctionFluentForm

		def SubStructQ(pOtherNumber)
			This.SubStruct(pOtherNumber)
			return This
	
		#>

		#< @FunctionAlternativeForms

		# Subtract the given number from this one (same as SubStruct).
		def Retrieve(pOtherNumber)
			This.SubStruct(pOtherNumber)

			def RetrieveQ(pOtherNumber)
				This.Retrieve(pOtherNumber)
				return This

		def Substract(pOtherNumber)
			This.SubStruct(pOtherNumber)

			def SubstractQ(pOtherNumber)
				return This.RetrieveQ(pOtherNumber)

		def Subtract(pOtherNumber)
			This.SubStruct(pOtherNumber)

			def SubtractQ(pOtherNumber)
				return This.RetrieveQ(pOtherNumber)

		def Subtruct(pOtherNumber)
			This.SubStruct(pOtherNumber)

			def SubtructQ(pOtherNumber)
				return This.RetrieveQ(pOtherNumber)

		#>

		#< @FunctionPassiveForm

		# The difference after subtracting the given number, as data.
		def Substructed(pOtherNumber)
			_nResult_ = This.Copy().SubstructQ(pOtherNumber).NumericValue()
			return _nResult_

			# The difference after subtracting the given number, as data.
			def Retrieved(pOtherNumber)
				return This.Substructed(pOtherNumber)

		# The difference after subtracting the given number, as data.
		def Substracted(pOtherNumber)
			return This.SubStructed(pOtherNumber)

		# The difference after subtracting the given number, as data.
		def Subtracted(pOtherNumber)
			return This.SubStructed(pOtherNumber)

		# The difference after subtracting the given number, as data.
		def Subtructed(pOtherNumber)
			return This.SubStructed(pOtherNumber)

		#>

	# Subtract each of the given numbers from this number (mutating).
	def SubStructMany(paOtherNumbers)
		#TODO // Add "These" as alternative of "Many"

		This.SubStructManyXT(paOtherNumbers, :ReturnIntermediateResults = 0)

		#< @FunctionFluentForm

		def SubStructManyQ(paOtherNumbers)
			This.SubStructMany(paOtherNumbers)
			return This

		#>

		#< @FunctionAlternativeForms

		def SubstractMany(pOtherNumbers)
			This.SubStructMany(pOtherNumbers)

		def SubtractMany(pOtherNumbers)
			This.SubStructMany(pOtherNumbers)

		def SubtructMany(pOtherNumbers)
			This.SubStructMany(pOtherNumbers)

		#>

		#< @FunctionPassiveForms

		# The value after subtracting all the given numbers, as data.
		def SubstructedMany(pOtherNumbers)
			_nResult_ = This.Copy().SubStructManyQ(pOtherNumbers).Content()
			return _nResult_

		# The value after subtracting all the given numbers, as data.
		def SubstractedMany(pOtherNumber)
			return This.SubStructedMany(pOtherNumbers)

		# The value after subtracting all the given numbers, as data.
		def SubtractedMany(pOtherNumbers)
			return This.SubStructedMany(pOtherNumbers)

		# The value after subtracting all the given numbers, as data.
		def SubtructedMany(pOtherNumbers)
			return This.SubStructedMany(pOtherNumbers)

		#>


	#--

	def SubStructManyXT(paOtherNumbers, paReturnIntermediateResults)
		#TODO // Add "These" as alternative of "Many"

		if CheckingParams()
			if NOT ( isList(paOtherNumbers) and @IsListOfNumbersOrStrings(paOtherNumbers) )
				StzRaise("Incorrect param type! paOtherNumbers must be a list of numbers or strings.")
			ok
		ok
	
		_bReturnIntermediateResults_ = 0
		if paReturnIntermediateResults[1] = :ReturnIntermediateResults and
		   paReturnIntermediateResults[2] = 1

			_bReturnIntermediateResults_ = 1
		ok
	
		_nLen_ = len(paOtherNumbers)
		_aIntermediateResults_ = []

		for _i_ = 1 to _nLen_
			This.SubStruct(paOtherNumbers[_i_])
			_aIntermediateResults_ + This.Content()
		next
	
		if _bReturnIntermediateResults_
			return _aIntermediateResults_
		ok

		#< @FunctionFluentForm

		def SubStructManyXTQ(paOtherNumbers, paReturnIntermediateResults)
			if paReturnIntermediateResults[1] = 0
				This.SubStructManyXT(paOtherNumbers, paReturnIntermediateResults)
				return This

			else
				return stzListOfNumbers( This.SubStructManyXT(paOtherNumbers, paReturnIntermediateResults) )
			ok

		#>

						
	# Subtract each of the given numbers (same as SubStructMany).
	def RetrieveMany(paOtherNumbers)
		#TODO // Add "These" as alternative of "Many"

		This.SubStructMany(paOtherNumbers)

		def RetrieveManyQ(paOtherNumbers)
			This.RetrieveMany(paOtherNumbers)
			return This
	
		def RetrieveManyXT(paOtherNumbers, paReturnIntermediateResults)
			return This.SubStructManyXT(paOtherNumbers, paReturnIntermediateResults)
			
			def RetrieveManyXTQ(paOtherNumbers, paReturnIntermediateResults)
				return This.SubStructManyXTQ(paOtherNumbers, paReturnIntermediateResults)
  	
	  #-------------------------------------------#
	 #  INCRMENET / DECREMENT THE NUMBER (BY 1)  #
	#-------------------------------------------#

	# The value one greater / one less, WITHOUT changing this number.
	#
	# ADDED 2026-07-25. The operator() hook has always answered "++" and "--" with
	# these, but they did not exist. They RETURN rather than mutate, because that
	# hook returns the result of the operation -- Increment()/Decrement() just below
	# are the mutating pair.
	def NextNumber()
		_o_ = new stzNumber(This.Content())
		_o_.Add(1)
		return _o_.Content()

		def NextNumberQ()
			return new stzNumber(This.NextNumber())

	def PreviousNumber()
		_o_ = new stzNumber(This.Content())
		_o_.Subtract(1)
		return _o_.Content()

		def PreviousNumberQ()
			return new stzNumber(This.PreviousNumber())

	def Increment()
		This.Add(1)

		def IncrementQ()
			This.Add(1)
			return This        # FIXED 2026-07-25: a Q form must return the object
			return This

	def Incremented()
		_nResult_ = This.NumericValue() + 1

	#--

	def Decrement()
		This.Substract(1)

		def DecrementQ()
			This.Subtract(1)
			return This        # FIXED 2026-07-25: a Q form must return the object
			return This

	def Decremented()
		_nResult_ = This.NumericValue() - 1

	  #-------------------------------------------------#
	 #    MULTIPLYING THE NUMBER BY AN OTHER NUMBER    #
	#-------------------------------------------------#

	def MultiplyBy(pOtherNumber)

		if CheckingParams()
			if isList(pOtherNumber)
				This.MultiplyByMany(pOtherNumber)
				return
			ok
		ok

		_StzHistoOpen(This.NumericValue())
		This.Update( pvtCalculate("*", pOtherNumber ) )
		_StzHistoAdd(This.NumericValue())

		#< @FunctionAlternativeForm

		def MultiplyByQ(pOtherNumber)
			This.MultiplyBy(pOtherNumber)
			return This
	
		#>

		#< @FunctionAlternativeForm

		def Multiply(pOtherNumber)
			if CheckingParams()
				if isList(pOtherNumber) and Q(pOtherNumber).IsByOrWithOrUsingNamedParam()
					pOtherNumber = pOtherNumber[2]
				ok
			ok

			This.MultiplyBy(pOtherNumber)

		#>

	def MultipliedBy(pOtherNumber)
		_nResult_ = This.Copy().MultiplyByQ(pOtherNumber).NumericValue()
		return _nResult_

		def Multiplied(pOtherNumber)
			return This.MultipliedBy(pOtherNumber)

		def Times(pOtherNumber)
			return This.MultipliedBy(pOtherNumber)

	  #----------------------------------------------------#
	 #    MULTIPLYING THE NUMBER BY MANY OTHER NUMBERS    #
	#----------------------------------------------------#

	def MultiplyByMany(paOtherNumbers)
		#TODO // Add "These" as alternative of "Many"

		This.MultiplyByManyXT(paOtherNumbers, :ReturnIntermediateResults = 0)

		#< @FunctionFluentForm

		def MultiplyByManyQ(paOtherNumbers)
			This.MultiplyByMany(paOtherNumbers)
			return This
	
		#>
	
		def MultipliedByMany(paOtherNumbers)
			_nResult_ = This.Copy().MultiplyByManyQ(paOtherNumbers).NumericValue()
			return _nResult_

	def MultiplyByManyXT(paOtherNumbers, paReturnIntermediateResults)
		#TODO // Add "These" as alternative of "Many"

		if CheckingParams()
			if NOT ( isList(paOtherNumbers) and @IsListOfNumbersOrStrings(paOtherNumbers) )
				StzRaise("Incorrect param type! paOtherNumbers must be a list of numbers or strings.")
			ok
		ok

		_aIntermediateResults_ = []
	
		_bReturnIntermediateResults_ = 0
	
		if paReturnIntermediateResults[1] = :ReturnIntermediateResults and
		   paReturnIntermediateResults[2] = 1
	
			_bReturnIntermediateResults_ = 1
		ok
	
		_nLen_ = len(paOtherNumbers)
		_aIntermediateResults_ = []

		for _i_ = 1 to _nLen_
			This.MultiplyBy(paOtherNumbers[_i_])
			_aIntermediateResults_ + This.Content()
		next
	
		if _bReturnIntermediateResults_
			return _aIntermediateResults_
		ok		

	  #----------------#
	 #    DIVISION    #
	#----------------#

	# Divide this number by the given one (mutating).
	def Divide(pOtherNumber)
		if CheckingParams()

			if isList(pOtherNumber) and Q(pOtherNumber).IsByNamedParam()
				paByDividor = paByDividor[2]
			ok
	
		ok

		This.DivideBy(pOtherNumber)

		#< @FunctionFluentForm

		def DivideQ(pOtherNumber)
			This.Divide(pOtherNumber)
			return This

		#>

		#< @FunctionPassiveForm

		# The quotient by the given number, as data; the original is
		# unchanged.
		def Divided(pOtherNumber)
			_nResult_ = This.Copy().DivideQ(pOtherNumber).NumericValue()
			return _nResult_

		#>

	# Divide this number by the given one (mutating).
	#@ aka  over, quotient, split by, divided
	def DivideBy(pOtherNumber)
		_StzHistoOpen(This.NumericValue())
		This.Update( pvtCalculate("/", pOtherNumber ) )
		_StzHistoAdd(This.NumericValue())

		#< @FunctionFluentForm

		def DivideByQ(pOtherNumber)
			This.DivideBy(pOtherNumber)
			return This

		#>

		#< @FunctionPassiveForm

		# The quotient by the given number, as data.
		def DividedBy(pOtherNumber)
			_nResult_ = This.Copy().DivideByQ(pOtherNumber).NumericValue()
			return _nResult_

		#>
	
	# Divide this number by each of the given numbers in turn
	# (mutating).
	def DivideByMany(paOtherNumbers)
		#TODO // Add "These" as alternative of "Many"

		This.DivideByManyXT(paOtherNumbers, :ReturnIntermediateResults = 0)

		#< @FunctionFluentForm

		def DivideByManyQ(paOtherNumbers)
			This.DivideByMany(paOtherNumbers)
			return This
	
		#>

		# A copy divided by each of the given numbers.
		def DividedByMany(paOtherNumbers)
			_nResult_ = This.Copy().DivideByManyQ(paOtherNumbers).NumericValue()
			return _nResult_

	def DivideByManyXT(paOtherNumbers, paReturnIntermediateResults)
		#TODO // Add "These" as alternative of "Many"

		if CheckingParams()
			if NOT ( isList(paOtherNumbers) and @IsListOfNumbersOrStrings(paOtherNumbers) )
				StzRaise("Incorrect param type! paOtherNumbers must be a list of numbers or strings.")
			ok
		ok

		_aIntermediateResults_ = []
	
		_bReturnIntermediateResults_ = 0
	
		if paReturnIntermediateResults[1] = :ReturnIntermediateResults and
		   paReturnIntermediateResults[2] = 1
	
			_bReturnIntermediateResults_ = 1
		ok
	
		_nLen_ = len(paOtherNumbers)
		_aIntermediateResults_ = []

		for _i_ = 1 to _nLen_
			This.DivideBy(paOtherNumbers[_i_])
			_aIntermediateResults_ + This.Content()
		next
	
		if _bReturnIntermediateResults_
			return _aIntermediateResults_
		ok
	
	  #-------------#
	 #    MATHS    #
	#-------------#

	# MODULO

	#@ aka  remainder, mod, leftover of division
	# The remainder of the division by the given number.
	def Modulo(pOtherNumber)
		return This.pvtCalculate("%", pOtherNumber)

		def ModuloQ(pOtherNumber)
			return new stzNumber(This.Modulo(pOtherNumber))
	
	# POWER

	#@ aka  to the power of, exponent, raised to, power
	# Raise the number to the given power (mutating).
	def Power(pOtherNumber)
		return This.pvtCalculate("^", pOtherNumber)

		def PowerQ(pOtherNumber)
			return new stzNumber(This.Power(pOtherNumber))
	
	# SINE

	# The sine of the number (mutating: the number becomes it).
	def Sine()
		return This.pvtCalculate( "sin", "" )

		def SineQ()
			return new stzNumber(This.Sine())
	
	# COSINE

	# The cosine of the number (mutating).
	def Cosine()
		return This.pvtCalculate( "cos", "" )

		def CosineQ()
			return new stzNumber(This.Cosine())
	
	# TANGENT

	# The tangent of the number (mutating).
	def Tangent()
		return This.pvtCalculate( "tan", "" )
		
		def TangentQ()
			return new stzNumber(This.Tangent())
	
	# COTANGENT

	# The cotangent of the number (mutating).
	def Cotangent()
		return This.pvtCalculate( "cotan", "" )

		def CotangentQ()
			return new stzNumber(This.Cotangent())
	
	# ARCSINE

	# The arc sine of the number (mutating).
	def ArcSine()
		return This.pvtCalculate( "asin", "" )
	
		def ArcSineQ()
			return new stzNumber(This.ArcSine())
	
	# ARCCOSINE

	# The arc cosine of the number (mutating).
	def ArcCosine()
		return This.pvtCalculate( "acos", "" )

		def ArcCosineQ()
			return new stzNumber(This.ArcCosine())
	
	# ARCTANGENT

	# The arc tangent of the number (mutating).
	def ArcTangent()
		return This.pvtCalculate( "atan", "" )

		def ArcTangentQ()
			return new stzNumber(This.ArcTangent())
	
	# ARCTANGENT2

	# The two-argument arc tangent (atan2) of the number (mutating).
	def ArcTangent2()
		return This.pvtCalculate( "atan2", "" )

		def ArcTangent2Q()
			return new stzNumber(This.ArcTangent2())
	
	# SINH

	# The hyperbolic sine of the number (mutating).
	def HyperbolicSine()
		return This.pvtCalculate( "sinh", "" )

		def HyperbolicSineQ()
			return new stzNumber(This.HyperbolicSine())
	
	# COSH

	# The hyperbolic cosine of the number (mutating).
	def HyperbolicCosine()
		return This.pvtCalculate( "cosh", "" )

		def HyperbolicCosineQ()
			return new stzNumber(This.HyperbolicCosine())
	
	# TANH

	# The hyperbolic tangent of the number (mutating).
	def HyperbolicTangent()
		return This.pvtCalculate( "tanh", "" )

		def HyperbolicTangentQ()
				return new stzNumber(This.HyperbolicTangent())
	
	# EXP

	# e raised to the number (mutating).
	def Exponential()
		return This.pvtCalculate( "exp", "" )

		def ExponentialQ()
			return new stzNumber(This.Exponential())
	
	# LOG

	# The natural logarithm (base e) of the number (mutating).
	def NaturalLogarithm()
		return This.pvtCalculate( "log", "" )

		def NaturalLogarithmQ()
			return new stzNumber(This.NaturalLogarithmQ())
	
	# LOG10

	# The common logarithm (base 10) of the number (mutating).
	def CommonLogarithm()
		return This.pvtCalculate( "log10", "" )

		def CommonLogarithmQ()
			return new stzNumber(This.CommonLogarithm())
	
	# ABS

	# The absolute value of the number (mutating).
	#@ aka  abs, magnitude, positive value, without sign
	def Absolute()
		if This.IsInteger()
			_n_ = This.NumericValue()
			if _n_ < 0
				return -_n_
			else
				return _n_
			ok
		else
			_oStrNumber_ = new stzString(This.Content())
			if _oStrNumber_.FirstChar() = "-"
				return _oStrNumber_.FirstCharRemoved()
			else
				return _oStrNumber_.Content()
			ok
		ok

		def AbsoluteQ()
			return new stzNumber(This.AbsoluteQ())

		#@ aka  absolute value, magnitude, without the sign, distance from zero
		def Abs()
			return This.Absolute()

			def AbsQ()
				return This.AbsoluteQ()
	
	# SQRT

	#@ aka  square root, sqrt, root of the number
	# The square root of the number (mutating).
	def SquareRoot()
		return This.pvtCalculate( "sqrt", "" )

		def SquareRootQ()
			return new stzNumber(This.SquareRoot())
	
	# FACT

	# The factorial of the (integer) number (mutating).
	#@ aka  factorial of, n bang, product of integers up to
	def Factorial()
		if NOT This.IsInteger()
			StzRaise("Can't compute factorial of a non-integer!")
		ok
		_n_ = This.NumericValue()
		if _n_ < 0
			StzRaise("Can't compute factorial of a negative number!")
		ok
		pBigInt = StzEngineNumberFactorial(_n_)
		_cResult_ = StzEngineBigIntToString(pBigInt)
		StzEngineBigIntFree(pBigInt)
		return _cResult_

		def FactorialQ()
				return new stzNumber(This.Factorial())
	
	# PERCENT

	# The number as a percentage string.
	def InPercentage()
		return This.pvtCalculate( "/", 10 ) + "%"

	# SIGMOID

	# The sigmoid of the number (mutating).
	def Sigmoid()
		return This.pvtCalculate( "sigmoid", "" )

		def SigmoidQ()
			return new stzNumber(This.Sigmoid())
	

	# The derivative via the engine calculator (reserved form).
	def Derivative(pcFunc)
		return This.pvtCalculate( "derivative", pcdef ) 

		def DerivativeQ(pcFunc)
				return new stzNumber(This.Derivative(pcFunc))
	
	# DERIVATIVE SIGMOID

	# The sigmoid derivative of the number (mutating).
	def DerivativeSigmoid()
		return This.pvtCalculate( "DerivativeSigmoid", "" )

		def DerivativeSigmoidQ()
			return new stzNumber(This.DerivativeSigmoid())
	

	# The least common multiple with the given number.
	def LeastCommonMultiple(pOtherNumber)

		if isList(pOtherNumber) and Q(pOtherNumber).IsWithNamedParam()
			pOtherNumber = pOtherNumber[2]
		ok

		# FIXED 2026-07-25: the second predicate, IsListOfNumbersInStrings(), exists
		# nowhere -- and Ring's `or` evaluates BOTH sides, so this raised R14 for any
		# list argument rather than falling through. Replaced by a local helper that
		# accepts numbers and numbers-written-as-strings alike.
		if isList(pOtherNumber) and _StzIsListOfNumbersOrNumberStrings(pOtherNumber)

			return This.LeastCommonMultipleOfManyNumbers(pOtherNumber)

		# FIXED 2026-07-25: `pOtherNumbe` was missing its "r", and a method cannot be
		# called on a bare string -- it needs Q(). Both would have raised the moment
		# an LCM was asked for with a number in a string.
		but isNumber(pOtherNumber) or
		    ( isString(pOtherNumber) and Q(pOtherNumber).IsNumberInString() )
			return pvtCalculate( "LCM", pOtherNumber)
		
		else
			StzRaise("Incorrect param type! pOtherNumber must be a number in string or a list of numbers (or numbers in strings).")

		ok

		def LeastCommonMultipleQ(pOtherNumber)
			return new stzNumber(This.LeastCommonMultiple(pOtherNumber))

	# The LCM of this number with EVERY number in the given list.
	#
	# ADDED 2026-07-25. LeastCommonMultiple() has always branched here for a list
	# argument, but the method did not exist -- so
	# stzListOfNumbers([4,6,8]).LeastCommonMultiple(), which routes through it,
	# silently answered 0 instead of 24. lcm is associative, so folding pairwise is
	# the whole implementation.
	def LeastCommonMultipleOfManyNumbers(paNumbers)
		if NOT isList(paNumbers)
			StzRaise("Incorrect param type! paNumbers must be a list of numbers.")
		ok
		_nLen_ = len(paNumbers)
		if _nLen_ = 0
			return 0 + This.Content()
		ok
		_nResult_ = 0 + This.Content()
		for _i_ = 1 to _nLen_
			_oTmp_ = new stzNumber(_nResult_)
			_nResult_ = 0 + _oTmp_.LeastCommonMultiple( 0 + paNumbers[_i_] )
		next
		return _nResult_

		def LeastCommonMultipleOfManyNumbersQ(paNumbers)
			return new stzNumber(This.LeastCommonMultipleOfManyNumbers(paNumbers))

		def LCMOfManyNumbers(paNumbers)
			return This.LeastCommonMultipleOfManyNumbers(paNumbers)


	# The greatest common divisor with the given number.
	def GreatestCommonDividor(pOtherNumber)
		return This.pvtCalculate( "GCD", pOtherNumber)

		def GreatestCommonDividorQ(n)
			# FIXED 2026-07-25: called This.GreatCommonDividor() -- missing "est",
			# and dropping the argument, so it could never have worked.
			return new stzNumber(This.GreatestCommonDividor(n))

		def CommonGreatestDividor(pOtherNumber)
			return This.GreatestCommonDividor(pOtherNumber)
	
	# INVERSE

	# The multiplicative inverse (1/n) of the number (mutating).
	def Inverse()
		return This.pvtCalculate( "inverse", "" )

		def InverseQ()
			return new stzNumber(This.Inverse())
	
	# FACTORS

	# The factors (divisors) of the integer number, as a list.
	def Factors()
		if NOT This.IsInteger()
			StzRaise("Factors can't be computed for a non integer!")
		ok

		// Returns the factors of just the integer part!
		if This.NumericValue() > 0
			return ring_factors(This.IntegerPartValue())
		else
			StzRaise("For factors(n), n must must be positive!")
		ok

		#< @FunctionFluentForm

		def FactorsQ()
			return This.FactorsQRT(:stzList)

		# The factors, in the requested return type (QRT).
		def FactorsQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Factors() )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.Factors() )
			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def Dividors()
			return This.Factors()

		def Divisors()
			return This.Factors()

		#>

		#< @FunctionMisspelledForm

		def Divirdos()
			return This.Factors()

		#>

	def FactorsXT()
		_anFactors_ = This.Factors()
		_nLen_ = len(_anFactors_)

		_aResult_ = []
		for _i_ = 1 to _nLen_
			_aResult_ + [ _anFactors_[_i_], This.IntegerPartValue() / _anFactors_[_i_] ]
		next

		return _aResult_

		#< @FunctionFluentForm

		# The factors, in the requested return type (variant form).
		def FactorsXRQ()
			return This.FactorsXTQRT(:stzList)

		# The factors with options, in the requested return type.
		def FactorsXTQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.FactorsXT() )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.FactorsXT() )
			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def DividorsXT()
			return This.FactorsXT()

		def DivisorsXT()
			return This.FactorsXT()

		#>

		#< @FunctionMisspelledForm

		def DivirdosXT()
			return This.Factors()

		#>

	# The prime factors of the number, as a list.
	def PrimeFactors()
		_aResult_ = []

		_aThisFactors1_ = This.Factors()
		_nThisFactors1Len_ = len(_aThisFactors1_)
		for _iLoopThisFactors1_ = 1 to _nThisFactors1Len_
			_n_ = _aThisFactors1_[_iLoopThisFactors1_]
			_oTempNumber_ = new stzNumber(_n_)

			if _oTempNumber_.IsPrimeNumber()
				_aResult_ + _n_
			ok
		next

		return _aResult_


		#< @FunctionFluentForm

		def PrimeFactorsQ()
			return This.PrimeFactorsQRT(:stzList)

		# The prime factors, in the requested return type (QRT).
		def PrimeFactorsQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Factors() )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.Factors() )
			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def PrimeDividors()
			return This.PrimeFactors()

		def PrimeDivisors()
			return This.PrimeFactors()

		#>

		#< @FunctionMisspelledForm

		def PrimeDivirdos()
			return This.PrimeFactors()

		#>

	def PrimeFactorsXT()
		_aResult_ = []
		_aThisPrimeFactors1_ = This.PrimeFactors()
		_nThisPrimeFactors1Len_ = len(_aThisPrimeFactors1_)
		for _iLoopThisPrimeFactors1_ = 1 to _nThisPrimeFactors1Len_
			_n_ = _aThisPrimeFactors1_[_iLoopThisPrimeFactors1_]
			_aResult_ + [ _n_, This.IntegerPartValue() / _n_ ]
		next
		return _aResult_

		#< @FunctionFluentForm

		# The prime factors, in the requested return type (variant
		# form).
		def PrimeFactorsXRQ()
			return This.PrimeFactorsXTQRT(:stzList)

		# The prime factors with options, in the requested return type.
		def PrimeFactorsXTQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.PrimeFactorsXT() )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.PrimeFactorsXT() )
			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForm

		def PrimeDividorsXT()
			return This.PrimeFactorsXT()

		def PrimeDivisorsXT()
			return This.PrimeFactorsXT()

		#>

		#< @FunctionMisspelledForm

		def PrimeDivirdosXT()
			return This.PrimeFactors()

		#>

	# The factor pair closest to a square (rows x cols).
	def MostSquareLikeFactors()
		return @MostSquareLikeFactors(This.Content())

		def MSLF()
			return This.MostSquareLikeFactors()

	# MULTIPLES UNTIL

	# How many multiples of the given number divide into this one.
	def NumberOfMultiples(pOtherNumber)
		return len( This.Multiples(pOtherNumber) )

	# How many multiples fit up to the given limit.
	def NumberOfMultiplesUntil(pOtherNumber)
		return len( This.MultiplesUntil(pOtherNumber) )

		def NumberOfMultiplesUpTo(pOtherNumber)
			return This.NumberOfMultiplesUntil(pOtherNumber)

	# The multiples of the number up to the given count.
	def Multiples(pOtherNumber)
		if isList(pOtherNumber) and
		   IsOneOfTheseNamedParamsList(pOtherNumber, [ :Until, :UpTo, :Under ])
			pOtherNumber = pOtherNumber[2]
		ok

		return This.MultiplesUntil(pOtherNumber)

	# The multiples of the number up to the given limit.
	def MultiplesUntil(pOtherNumber)

		if CheckingParams()

			if NOT (isNumber(pOtherNumber) or isString(pOtherNumber))
				StzRaise("Incorrect param type! pOtherNumber must be a number or a string.")
			ok
	
			if isString(pOtherNumber) and
			   NOT Q(pOtherNumber).IsNumberInString()
				StzRaise("Incorrect value! pOtherNumber must be a number in string.")
			ok
		ok

		_nOtherNumber_ = StzNumberQ(pOtherNumber).NumericValue()
		if _nOtherNumber_ <= This.NumericValue()
			StzRaise("Can't proceed! pOtherNumber must be >= your main number.")
		ok

		# Memorizing the current round in the program
		# (actuated by StzDecimals() that you should
		# use instead of the standard Ring decimals()

		_nCurrentRound_ = StzCurrentRound()

		# Getting the round of the other number

		_nOtherRound_ = _nCurrentRound_
		if isString(pOtherNumber)
			_nOtherRound_ = StzNumberQ(n).Round()
		ok

		# Applying the max between the two rounds
		# (becausse we want the calculation to be
		# as precise as possiblle)

		StzDecimals( @Max([ This.Round(), _nOtherRound_ ]) )

		# Doing the job under that round

		_bInteger_ = 0
		if This.IsInteger() and Q(pOtherNumber).IsInteger()
			_bInteger_ = 1
		ok

		_aResult_ = []
		_bContinue_ = 1
		_i_ = 0
		while _bContinue_
			_i_++
			_n_ = This.MultipliedBy(_i_)
			if _bInteger_
				_n_ = 0+ _n_
			ok

			if _n_ <= _nOtherNumber_
				_aResult_ + _n_
			else
				_bContinue_ = 0
			ok
		end

		return _aResult_

		# Resetting the current round

		StzDecimals( _nCurrentRound_ )

		def MultiplesUntilQ(pOtherNumber)
			return This.MultiplesUntilQRT(pOtherNumber, :stzList)

		# The multiples up to the limit, in the requested return type.
		def MultiplesUntilQRT(pOtherNumber, pcReturnType)

			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT ( isString(pcReturnType) and Q(pcReturnType).IsStzType() )
				StzRaise("Incorrect param! pcReturnType must be a string containing the name of a Softanza class.")
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.MultiplesUntil(pOtherNumber) )

			on :stzListOfNumbers

				_anMultiples_ = This.MultiplesUntil(pOtherNumber)

				_anNumbers_ = []
				_nAnMultiples1Len_ = len(_anMultiples_)
				for _iLoopAnMultiples1_ = 1 to _nAnMultiples1Len_
					_n_ = _anMultiples_[_iLoopAnMultiples1_]
					if isString(_n_)
						_anNumbers_ + ( 0+ _n_ )
					else
						_anNumbers_ + _n_
					ok
				next

				return new stzListOfNumbers( _anNumbers_ )

			on :stzListOfStrings
				_acNumbers_ = []
				_aThisMultiplesUntilpOther1_ = This.MultiplesUntil(pOtherNumber)
				_nThisMultiplesUntilpOther1Len_ = len(_aThisMultiplesUntilpOther1_)
				for _iLoopThisMultiplesUntilpOther1_ = 1 to _nThisMultiplesUntilpOther1Len_
					_n_ = _aThisMultiplesUntilpOther1_[_iLoopThisMultiplesUntilpOther1_]
					if isNumber(_n_)
						_acNumbers_ + ( ""+ _n_ )
					else
						_acNumbers_ + _n_
					ok
				next

				return new stzListOfNumbers( _anNumbers_ )

			other
				StzRaise("Unssupported return type!")
			off


		def MultiplesUpTo(pOtherNumber)
			return This.MultiplesUntil(pOtherNumber)

		def MultiplesUnder(pOtherNumber)
			return This.MultiplesUntil(pOtherNumber)

	# DIVIDABILITY

	# TRUE if the number divides evenly by n.
	def IsDividableBy(n)
		if CheckingParams()
			if NOT @IsNumberOrString(n)
				StzRaise("Incorrect param type! n must be a number or string.")
			ok

			if isString(n) and NOT Q(n).IsNumberInString()
				StzRaise("Incorrect value! n must be a decimal number in string.")
			ok
		ok

		# Memorizing the current round in the program
		# (actuated by StzDecimals() that you should
		# use instead of the standard Ring decimals()

		_nCurrentRound_ = StzCurrentRound()

		# Getting the round of the other number

		_nOtherRound_ = _nCurrentRound_
		if isString(n)
			_nOtherRound_ = StzNumberQ(n).Round()
		ok

		# Applying the max between the two rounds
		# (becausse we want the calculation to be
		# as precise as possiblle)

		StzDecimals( @Max([ This.Round(), _nOtherRound_ ]) )

		# Doing the job under that round

		n = StzNumberQ(n).NumericValue()

		_oTempList_ = new stzList( This.Factors() )
		_bResult_ = 0

		if _oTempList_.Contains(n)
			_bResult_ = 1
		ok

		# Resetting the current round

		StzDecimals(_nCurrentRound_)

		# Returning the result

		return _bResult_

		def IsDivisibleBy(n)
			return This.IsDividableBy(n)

		def CanBeDividedBy(n)
			return This.IsDividableBy(n)
			
	# TRUE if the number divides evenly INTO n.
	def IsDividorOf(n)	// Main Number and n must be integers!
		_oNumber_ = new stzNumber(n)

		return _oNumber_.IsDividableBy(This.IntegerPartValue())

	# The integer part, as a number.
	def IntegerPartValue()
		return 0+ This.IntegerPart()

		def IntegerPartNumericValue()
			return This.IntegerPartValue()

	# The fractional part, as a number.
	def FractionalPartValue()
		return 0+ This.FractionalPart()

		def DecimalPartValue()
			return This.FractionalPartValue()

		def FractionalPartNumericValue()
			return This.FractionalPartValue()

		def DecimalPartNumericValue()
			return This.FractionalPartValue()

	  #-------------------#
	 #     CONVERSION    #
	#-------------------#

	# The number wrapped as a stzString object.
	def ToStzString()
		return new stzString(This.Content())
	
	# Converting decimal to hex form
	
	def ToHexForm()
		_cResult_ = HexNumberPrefix() + This.ToHexFormWithoutPrefix()
		return _cResult_

		#< @FunctionFluentForm

		def ToHexFormQ()
			return new stzHexNumber( This.ToHexForm() )

		#>

		#< @FunctionAlternativeForm

		#@ aka  hexadecimal, hex, base 16
		# The number in hexadecimal form.
		def ToHex()
			return ToHexForm()

			def ToHexQ()
				return new stzHexNumber( This.ToHex() )

		#>

	# The number wrapped as a stzHexNumber object.
	def ToHexNumber()
		return new stzHexNumber( This.ToHex() )

	# The number in Unicode hex form (U+0041).
	def ToUnicodeHexForm()
		return "U+" + This.ToHexFormWithoutPrefix()
	
		#< @FunctionAlternativeForms

		# The number in Unicode hex form (U+0041).
		def ToUnicodeHex()
			return ToUnicodeHexForm()

		# The number in Unicode hex form (U+0041).
		def ToHexUnicode()
			return ToUnicodeHexForm()

		#>

	# The hexadecimal form without the 0x prefix.
	def ToHexFormWithoutPrefix()
		_cResult_ = This.IntegerPartToHexForm()

		if This.HasFractionalPart()
			_cResult_ += "." + This.FractionalPartToHexForm()
		ok

		return _cResult_

		#< @FunctionAlternativeForms

		def ToHexWithoutPrefix()
			return This.ToHexFormWithoutPrefix()

		#>
			
	# The integer part in hexadecimal form.
	def IntegerPartToHexForm()
		return StzUpper(StzEngineNumberToBase(This.IntegerPartValue(), 16))

	# The fractional part in hexadecimal form.
	def FractionalPartToHexForm()
		_cFraction_ = This.FractionalPart()

		def DecimalPartToHexForm()
			return This.FractionalPartToHexForm()
  
	# Converting decimal to binary form

	def ToBinaryForm()
		_oConversion_ = new stzDecimalToBinary(This.Content())
		return _oConversion_.ToBinaryForm()

		#@ aka  binary, base 2, bits, binary representation
		def ToBinary()
			return This.ToBinaryForm()

		def ToBinaryQ()
			return new stzBinaryNumber( This.ToBinaryForm() )

		# The number wrapped as a stzBinaryNumber object.
		def ToBinaryNumber()
			return new stzBinaryNumber( This.ToBinaryForm() )

	# Variant that strips the "0b" prefix from the binary form, for
	# callers that just want the raw bit-string.
	def ToBinaryFormWithoutPrefix()
		_cBin_ = This.ToBinaryForm()
		if isString(_cBin_) and StzLen(_cBin_) >= 2 and StzMid(_cBin_, 1, 2) = "0b"
			return StzMidToEnd(_cBin_, 3)
		ok
		return _cBin_

		def ToBinaryWithoutPrefix()
			return This.ToBinaryFormWithoutPrefix()

		def ToBinaryFormNoPrefix()
			return This.ToBinaryFormWithoutPrefix()

		def ToBinaryNoPrefix()
			return This.ToBinaryFormWithoutPrefix()
	
	# Converting decimal to octal form

	def IntegerPartToOctalForm()
		# Use fabs -- bare abs() resolves case-insensitively to this
		# class's own Abs() method (0 params) and raises R20 on the
		# argument. Same family as the Insert/Swap/Add shadows.
		return This.Sign() + StzEngineNumberToBase(fabs(This.IntegerPartValue()), 8)

	# The fractional part written in octal.
	#
	# ADDED 2026-07-25. ToOctalFormWithoutPrefix() has always called this for a real
	# number, but it did not exist -- so any octal rendering of a number with a
	# fractional part raised R14.
	#
	# A fraction is converted by repeatedly multiplying by 8 and taking the integer
	# part as the next digit. Unlike the integer side this can run forever (1/3 in
	# octal is 0.2525...), so it is bounded by the number's own round -- the digits
	# the caller asked to keep -- and stops early when the fraction reaches zero.
	def FractionalPartToOctalForm()
		_cFrac_ = This.FractionalPartWithoutZeroDot()
		if _cFrac_ = ""
			return ""
		ok
		_nFrac_ = 0 + ("0." + _cFrac_)
		_nMax_ = This.Round()
		if _nMax_ < 1
			_nMax_ = 6
		ok
		_cOut_ = ""
		_nGuard_ = 0
		while _nFrac_ > 0 and _nGuard_ < _nMax_
			_nFrac_ = _nFrac_ * 8
			_nDigit_ = floor(_nFrac_)
			_cOut_ += "" + _nDigit_
			_nFrac_ = _nFrac_ - _nDigit_
			_nGuard_++
		end
		if _cOut_ = ""
			return "0"
		ok
		return _cOut_

	# The number in octal form (with prefix).
	def ToOctalForm()
		return OctalNumberPrefix() + This.ToOctalFormWithoutPrefix()

		def ToOctal()
			return This.ToOctalForm()

		def ToOctalQ()
			return new stzOctalNumber( This.ToOctalForm() ) 

		# The number wrapped as a stzOctalNumber object.
		def ToOctalNumber()
			return new stzOctalNumber( This.ToOctalForm() )
	
	# The octal form without the prefix.
	def ToOctalFormWithoutPrefix()
		_cResult_ = This.IntegerPartToOctalForm()

		if This.FractionalPart() != ""
			_cResult_ += "." + This.FractionalPartToOctalForm()
		ok

		return _cResult_

	// Returns a string containing the equivalent of the interger part
	// in the specified base n (between 2 and 36)
	# The integer part written in base n (2..36).
	def IntegerPartToBaseNForm(n)
		if n >= 2 and n <= 36
			_nVal_ = This.IntegerPartValue()   # FIXED 2026-07-25: was This.IntegerValue()
			if _nVal_ = 0
				return "0"
			ok
			_cPrefix_ = ""
			if _nVal_ < 0
				_cPrefix_ = "-"
				_nVal_ = -_nVal_
			ok
			return _cPrefix_ + StzEngineNumberToBase(_nVal_, n)
		else
			StzRaise(stzNumberError(:CanNotConvertNumberToSpecifiedBase))
		ok

	# Converting decimal number to bytes

	def ToBytes()
		return double2bytes( This.Content() )
		# Because Ring uses double C type to represent numbers internally

	def FromBinaryForm(cBinary)
		This.Update( StzBinaryNumberQ(cBinary).ToDecimalForm() )

		def FromBinary(cBinary)
			This.FromBinaryForm(cBinary)

	# Set the number from the given octal form (mutating).
	def FromOctalForm(cOctal)
		This.Update( StzOctalNumberQ(cOctal).ToDecimalForm() )

		def FromOctal(cOctal)
			This.FromOctalForm(cOctal)

	# Set the number from the given hex form (mutating).
	def FromHexForm(cHex)
		This.Update( StzHexNumberQ(cHex).ToDecimalForm() )

		def FromHex(cHex)
			This.FromHexForm(cHex)

	  #-----------------------------------------------------------#
	 #    UNITS, HUNDREDS, THOUSANDS, MILLIONS, AND BILLIONS     #
	#-----------------------------------------------------------#
	/*
	TODO: Refactor StructureXT() and Structure() to avoid duplicated code.
	*/

	def StructureXT()
	/*
		Given a number, the method returns its structure in a hashlist
		taking the following form:
			 
			_aStructure_ = [ :aHundreds , :aThousands , :aMillions , :aBillions , :aTrillions ]
			where each inner list takes the form :
				       [ :Units, :Dozens, :Hundreds ]
			
		The following visual representation better illustrates the point:
			 
			+/-    999   999   999    999    999  . 999 999 999 999 9
			 |      |     |     |      |      |     |_______ _______|
	       		 |      V     V     V      V      V             V
			 |    Trill. Bill. Mill. Thous. Hund.           |
			 |    |______________ ______________|           |
		 	 |                   V                          |
			 |                   |                          |
		  	 |                   |                          |
		 	 V                   V                          V
			Sign             IntegerPart              FractionalPart
			                                     (called also DecimalPart)
		And for each block of 3 digits we have:

			9 9 9
			| | |__ Units
			| |____ Dozens
			|______ Hundreds

		*/

		# FIXED 2026-07-25: this used IntegerPart(), which KEEPS the sign, while
		# Structure() correctly uses IntegerPartWithoutSign() -- and the doc above
		# says the sign is not part of the analysis. A negative number fed its "-"
		# into the digit grouping.
		_oStzIntegerPart_ = new stzString(This.IntegerPartWithoutSign())
		_oStzFractionalPart_ = new stzString(This.FractionalPart())

		// Initializing the structure containers and the required variables
		_aHundreds_  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	_cHundreds_ = ""
		_aThousands_ = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	_cThousands_ = ""
		_aMillions_  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	_cMillions_ = ""
		_aBillions_  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ] _cBillions_ = ""
		_aTrillions_ = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ] _cTrillions_ = ""
			
		_aStructure_ = [ :aHundreds = [], :aThousands = [], :aMillions = [], :aBillions = [], :aTrillions = [] ]

		# FIXED 2026-07-25: same wrong split as Structure() -- see
		# _StzDigitGroupsOfThree.
		_aTemp_ = _StzDigitGroupsOfThree( _oStzIntegerPart_.Content() )

		if len(_aTemp_) >= 1  _cHundreds_  = _aTemp_[1] ok
		if len(_aTemp_) >= 2  _cThousands_ = _aTemp_[2] ok
		if len(_aTemp_) >= 3  _cMillions_  = _aTemp_[3] ok
		if len(_aTemp_) >= 4  _cBillions_  = _aTemp_[4] ok
		if len(_aTemp_) >= 5  _cTrillions_ = _aTemp_[5] ok

		_aStructure_ = [ 	
			:aTrillions = GetMicroStructure(_cTrillions_),
			:aBillions  = GetMicroStructure(_cBillions_),
			:aMillions  = GetMicroStructure(_cMillions_),
			:aThousands = GetMicroStructure(_cThousands_),
			:aHundreds  = GetMicroStructure(_cHundreds_)
		]

		return _aStructure_

	def Structure()
		# Given a number, the function returns its structure in a hashlist
		# taking the following form:
		# 
		# 	aStructure = [ :cHundreds , :cThousands , :cMillions , :cBillions , :cTrillions ]
		# 	where each key contains a string with the relevant number hosted in it.
		#NOTE that the sign is not included in the analysis, but we have it in This.Sign()

		_oStzIntegerPart_ = new stzString(This.IntegerPartWithoutSign())
		_oStzFractionalPart_ = new stzString(This.FractionalPart())

		// Initializing the structure containers and the required variables
		_aHundreds_  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	_cHundreds_ = ""
		_aThousands_ = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	_cThousands_ = ""
		_aMillions_  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ]	_cMillions_ = ""
		_aBillions_  = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ] _cBillions_ = ""
		_aTrillions_ = [ :Units = 0, :Dozens = 0, :Hundreds = 0 ] _cTrillions_ = ""
			
		_aStructure_ = [ :aHundreds = [], :aThousands = [], :aMillions = [], :aBillions = [], :aTrillions = [] ]

		# FIXED 2026-07-25: was SplitToNPartsQ(3) -- THREE PARTS, not parts OF three.
		_aTemp_ = _StzDigitGroupsOfThree( _oStzIntegerPart_.Content() )

		if len(_aTemp_) >= 1  _cHundreds_  = _aTemp_[1] ok
		if len(_aTemp_) >= 2  _cThousands_ = _aTemp_[2] ok
		if len(_aTemp_) >= 3  _cMillions_  = _aTemp_[3] ok
		if len(_aTemp_) >= 4  _cBillions_  = _aTemp_[4] ok
		if len(_aTemp_) >= 5  _cTrillions_ = _aTemp_[5] ok

		_cNumber_ = _cTrillions_ + _cBillions_ + _cMillions_ + _cThousands_ + _cHundreds_

		// Removing zeros from the left	
		_oNumber_ = new stzNumber(_cNumber_)
		_cNumber_ = _oNumber_.RemoveZeros()

		_aStructure_ = [ 	
			:cTrillions = _cTrillions_,
			:cBillions  = _cBillions_,
			:cMillions  = _cMillions_,
			:cThousands = _cThousands_,
			:cHundreds  = _cHundreds_
		]

		return _aStructure_

	#-- HUNDREDS --#
	# The hundreds part of the number's structure.
	def Hundreds()
		return This.Structure()[ :cHundreds ]		

	# The hundreds part of the structure, in detailed (XT) form.
	def HundredsXT()
		return This.StructureXT()[ :aHundreds ]

	# The units digit inside the number's hundreds.
	def UnitsInHundreds()
		return This.HundredsXT()[ :Units ]

		def Units()
			return This.UnitsInHundreds()

	# The dozens digit inside the number's hundreds.
	def DozensInHundreds()
		return This.HundredsXT()[ :Dozens ]

		def Dozens()
			return This.DozensInHundreds()

	# The hundreds digit inside the number's hundreds.
	def HundredsInHundreds()
		return This.HundredsXT()[ :Hundreds ]

	# TRUE if the number reaches the hundreds.
	def HasHundreds()
		_oNumber_ = new stzNumber(This.Content())
			
		if len(_oNumber_.IntegerPart()) > 0 and
		   _oNumber_.NumericValue() != 0

				return 1
		else
				return 0
		ok

		def ContainsHundreds()
			return This.HasHundreds()

	#-- TOUHSANDS --#
	# The thousands part of the number's structure.
	def Thousands()
		return This.Structure()[ :cThousands ]

	# The thousands part of the structure, in detailed (XT) form.
	def ThousandsXT()
		return This.StructureXT()[ :aThousands ]

	# The units digit inside the number's thousands.
	def UnitsInThousands()
		return This.ThousandsXT()[ :Units ]

	# The dozens digit inside the number's thousands.
	def DozensInThousands()
		return This.ThousandsXT()[ :Dozens ]

	# The hundreds digit inside the number's thousands.
	def HundredsInThousands()
		return This.ThousandsXT()[ :Hundreds ]

	# TRUE if the number reaches the thousands.
	def HasThousands()
		_oNumber_ = new stzNumber(This.Content())
			
		if len(_oNumber_.IntegerPart()) > 3
			return 1

		else
			return 0
		ok

		def ContainsThousands()
			return This.HasThousands()

	#-- MILLIONS --#
	# The millions part of the number's structure.
	def Millions()
		return This.Structure()[ :cMillions ]

	# The millions part of the structure, in detailed (XT) form.
	def MillionsXT()
		return This.StructureXT()[ :aMillions ]

	# The units digit inside the number's millions.
	def UnitsInMillions()
		return This.MillionsXT()[ :Units ]

	# The dozens digit inside the number's millions.
	def DozensInMillions()
		return This.MillionsXT()[ :Dozens ]

	# The hundreds digit inside the number's millions.
	def HundredsInMillions()
		return This.MillionsXT()[ :Hundreds ]

	# TRUE if the number reaches the millions.
	def HasMillions()
		_oNumber_ = new stzNumber(This.Content())
			
		if len(_oNumber_.IntegerPart()) > 6
			return 1

		else
			return 0
		ok

		def ContainsMillions()
			return This.HasMillions()

	#-- BILLIONS --#
	# The billions part of the number's structure.
	def Billions()
		return This.Structure()[ :cBillions ]

	# The billions part of the structure, in detailed (XT) form.
	def BillionsXT()
		return This.StructureXT()[ :aBillions ]
			
	# The units digit inside the number's billions.
	def UnitsInBillions()
		return This.BillionsXT()[ :Units ]

	# The dozens digit inside the number's billions.
	def DozensInBillions()
		return This.BillionsXT()[ :Dozens ]

	# The hundreds digit inside the number's billions.
	def HundredsInBillions()
		return This.BillionsXT()[ :Hundreds ]

	# TRUE if the number reaches the billions.
	def HasBillions()
		_oNumber_ = new stzNumber(This.Content())
			
		if len(_oNumber_.IntegerPart()) > 9
			return 1
		else
			return 0
		ok

		def ContainsBillions()
			return This.HasBillions()

	#-- TRILLIONS --#
	# The trillions part of the number's structure.
	def Trillions()
		return This.Structure()[ :cTrillions ]

	# The trillions part of the structure, in detailed (XT) form.
	def TrillionsXT()
		return This.StructureXT()[ :aTrillions ]

	# The units digit inside the number's trillions.
	def UnitsInTrillions()
		return This.TrillionsXT()[ :Units ]

	# The dozens digit inside the number's trillions.
	def DozensInTrillions()
		return This.TrillionsXT()[ :Dozens ]

	# The hundreds digit inside the number's trillions.
	def HundredsInTrillions()
		return This.TrillionsXT()[ :Hundreds ]

	# TRUE if the number reaches the trillions.
	def HasTrillions()
		_oNumber_ = new stzNumber(This.Content())
			
		if len(_oNumber_.IntegerPart()) > 12
			return 1

		else
			return 0
		ok

		def ContainsTrillions()
			return This.HasTrillions()

	#-- ALL IN ONCE --#
	# The units digit at every scale level, as a hash.
	def AllUnits()
		return 	[ :InHundreds  = This.UnitsInHundreds(),
			  :InThousands = This.UnitsInThousands(),
			  :InMillions  = This.UnitsInMillions(),
			  :InBillions  = This.UnitsInBillions(),
			  :InTrillions = This.UnitsInTrillions()
			]

	# The dozens digit at every scale level, as a hash.
	def AllDozens()
		return 	[ :InHundreds  = This.DozensInHundreds(),
			  :InThousands = This.DozensInThousands(),
			  :InMillions  = This.DozensInMillions(),
			  :InBillions  = This.DozensInBillions(),
			  :InTrillions = This.DozensInTrillions()
			]

	# The hundreds digit at every scale level, as a hash.
	def AllHundreds()
		return 	[ :InHundreds  = This.HundredsInHundreds(),
			  :InThousands = This.HundredsInThousands(),
			  :InMillions  = This.HundredsInMillions(),
			  :InBillions  = This.HundredsInBillions(),
			  :InTrillions = This.HundredsInTrillions()
			]

	  #-----------------------#
	 #    CONTAINABILITY     #
	#-----------------------#

	# Always TRUE: a number is made of digits.
	def ContainsDigits()
		return 1

	# TRUE if the number contains the given digit.
	def Contains(pcDigit)
		return StzFindFirst(pcDigit, This.Content()) > 0

	# TRUE if the number occurs in the given list.
	def ExistsIn(paList)
		return ListContains(paList, This.NumericValue())

		# Same as ExistsIn: TRUE if the number occurs in the given list.
		def Inn(paList)
			return ExistsIn(paList)

	# TRUE if the number contains the digit 0.
	def ContainsZeros()
		return This.Contains("0")

		def HasZeros()
			return This.ContainsZeros()

	# TRUE if the number contains the digit 1.
	def ContainsOnes()
		return This.Contains("1")

		def HasOnes()
			return This.ContainsOnes()

	# TRUE if the given digit occurs more than once.
	def ContainsSeveral(pcDigit)
		return StringNumberOfOccurrence(This.Content(), pcDigit) > 1

		def ContainsMany(pcDigit)
			return This.ContainsSeveral(pcDigit)

		def HasSeveral(pcDigit)
			return This.ContainsSeveral(pcDigit)

		def HasMany(pcDigit)
			return This.ContainsSeveral(pcDigit)

	# TRUE if the digit 0 occurs more than once.
	def ContainsSeveralZeros()
		return This.ContainsSeveral("0")

		def ContainsManyZeros()
			return This.ContainsSeveralZeros()

		def HasSeveralZeros()
			return This.ContainsSeveralZeros()

		def HasManyZeros()
			return This.ContainsSeveralZeros()

	# TRUE if the digit 1 occurs more than once.
	def ContainsSeveralOnes()
		return This.ContainsSeveral("1")

		def ContainsManyOnes()
			return This.ContainsSeveralOnes()

		def HasSeveralOnes()
			return This.ContainsSeveralOnes()

		def HasManyOnes()
			return This.ContainsSeveralOnes()

	# TRUE if the number is at least 10.
	def ContainsDozens()
		return This.NumericValue() >= 10

		def ContainsSeveralDozens()
			return This.ContainsDozens()

		def ContainsManyDozens()
			return This.ContainsDozens()

	# TRUE if the number is at least 200 (several hundreds).
	def ContainsSeveralHundreds()
		return This.NumericValue() >= 200

		def ContainsManyHundreds()
			return This.ContainsSeveralHundreds()

		def HasSeveralHundreds()
			return This.ContainsSeveralHundreds()

		def HasManyHundreds()
			return This.ContainsSeveralHundreds()

	# TRUE if the number is at least 2000 (several thousands).
	def ContainsSeveralThousands()
		return This.NumericValue() >= 2000

		def ContainsManyThousands()
			return This.ContainsSeveralThousands()

		def HasSeveralThousands()
			return This.ContainsSeveralThousands()

		def HasManyThousands()
			return This.ContainsSeveralThousands()

	# TRUE if the number is at least 10 000.
	def ContainsTensOfThousands()
		return This.NumericValue() >= 10_000

		def ContainsSeveralTensOfThousands()
			return This.ContainsTensOfThousands()

		def ContainsManyTensOfThousands()
			return This.ContainsTensOfThousands()

		def HasTensOfThousands()
			return This.ContainsTensOfThousands()

		def HasSeveralTensOfThousands()
			return This.ContainsSeveralTensOfThousands()

		def HasManyTensOfThousands()
			return This.ContainsSeveralTensOfThousands()

	# TRUE if the number is at least 100 000.
	def ContainsHundredsOfThousands()
		return This.NumericValue() >= 100_000

		def ContainsSeveralHundredsOfThousands()
			return This.ContainsHundredsOfThousands()

		def ContainsManyHundredsOfThousands()
			return This.ContainsHundredsOfThousands()

		def HasHundredsOfThousands()
			return This.ContainsHundredsOfThousands()

		def HasSeveralHundredsOfThousands()
			return This.ContainsHundredsOfThousands()

		def HasManyHundredsOfThousands()
			return This.ContainsHundredsOfThousands()

	# TRUE if the number is at least 2 000 000.
	def ContainsSeveralMillions()
		return This.NumericValue() >= 2_000_000

		def ContainsManyMillions()
			return This.ContainsSeveralMillions()

		def ContainsThousandsOfThousands()
			return This.ContainsMillions()

		def ContainsSeveralThousandsOfThousands()
			return This.ContainsSeveralMillions()

		def ContainsManyThousandsOfThousands()
			return This.ContainsSeveralMillions()

		#--

		def HasSeveralMilllions()
			return This.ContainsSeveralMillions()

		def HsManyMillions()
			return This.ContainsSeveralMillions()

		def HasThousandsOfThousands()
			return This.ContainsMillions()

		def HasSeveralThousandsOfThousands()
			return This.ContainsSeveralMillions()

		def HasManyThousandsOfThousands()
			return This.ContainsSeveralMillions()

	# TRUE if the number is at least 10 000 000.
	def ContainsTensOfMillions()
		return This.NumericValue() >= 10_000_000

		def ContainsSeveralTensOfMillions()
			return This.ContainsTensOfMillions()

		def ContainsManyTensOfMillions()
			return This.ContainsTensOfMillions()

		#--

		def HasTensOfMillions()
			return This.ContainsTensOfMillions()

		def HasSeveralTensOfMillions()
			return This.ContainsTensOfMillions()

		def HasMayTensOfMillions()
			return This.ContainsTensOfMillions()

	# TRUE if the number is at least 100 000 000.
	def ContainsHundredsOfMillions()
		return This.NumericValue() >= 100_000_000

		def ContainsSeveralHundredsOfMillions()
			return This.ContainsHundredsOfMillions()

		def ContainsManyHundredsOfMillions()
			return This.ContainsHundredsOfMillions()

		#--

		def HasHundredsOfMillions()
			return This.ContainsHundredsOfMillions()

		def HasSeveralHundredsOfMillions()
			return This.ContainsHundredsOfMillions()

		def HasManyHundredsOfMillions()
			return This.ContainsHundredsOfMillions()

	# TRUE if the number is at least 2 000 000 000.
	def ContainsSeveralBillions()
			return This.NumericValue() >= 2_000_000_000

		# TRUE if the number is at least 2 billion.
		def ContainsManyBillions()
			return This.ContainsSeveralBillions()

		# TRUE if the number reaches the billions (thousands of
		# millions).
		def ContainsThousandsOfMillions()
			return This.ContainsSeveralBillions()

		# TRUE if the number is at least 2 billion.
		def ContainsSeveralThousandsOfMillions()
			return This.ContainsSeveralBillions()

		# TRUE if the number is at least 2 billion.
		def ContainsManyThousandsOfMillions()
			return This.ContainsSeveralBillions()	

		#--

		def HasSeveralBillions()
			return This.ContainsSeveralBillions()

		# TRUE if the number is at least 2 billion.
		def HasManyBillions()
			return This.ContainsSeveralBillions()

		def HasThousandsOfMillions()
			return This.ContainsBillions()

		# TRUE if the number is at least 2 billion.
		def HasSeveralThousandsOfMillions()
			return This.ContainsSeveralBillions()

		# TRUE if the number is at least 2 billion.
		def HasManyThousandsOfMillions()
			return This.ContainsSeveralBillions()

	# TRUE if the number is at least 10 billion.
	def ContainsTensOfBillions()
		return This.NumericValue() >= 10_000_000_000

		def ContainsSeveralTensOfBillions()
			return This.ContainsTensOfBillions()

		def ContainsManyTensOfBillions()
			return This.ContainsTensOfBillions()

		#--

		def HasTensOfBillions()
			return This.ContainsTensOfBillions()

		# TRUE if the number is at least 20 billion.
		def HasSeveralTensOfBillions()
			return This.HasManyTensOfBillions()

		# TRUE if the number is at least 20 billion.
		def HasManyTensOfBillions()
			return This.HasManyTensOfBillions()

	# TRUE if the number is at least 100 billion.
	def ContainsHundredsOfBillions()
		return This.NumericValue() >= 100_000_000_000

		def ContainsSeveralHundredsOfBillions()
			return This.ContainsHundredsOfBillions()

		def ContainsManyHundredsOfBillions()
			return This.ContainsHundredsOfBillions()

		#--

		def HasHundredsOfBillions()
			return This.ContainsHundredsOfBillions()

		def HasSeveralHundredsOfBillions()
			return This.ContainsHundredsOfBillions()

		def HasManyHundredsOfBillions()
			return This.ContainsHundredsOfBillions()

	# TRUE if the number is at least 2 trillion.
	def ContainsSeveralTrillions()
		return This.NumericValue() >= 2_000_000_000_000

		def ContainsManyTrillions()
			return This.ContainsSeveralTrillions()

		#--

		def HasSeveralTrillions()
			return This.ContainsSeveralTrillions()

		def HasManyTrillions()
			return This.ContainsSeveralTrillions()


	# TRUE if the number is at least 10 trillion.
	def ContainsTensOfTrillions()
		return This.NumericValue() >= 10_000_000_000_000

		def ContainsSeveralTensOfTrillions()
			return This.ContainsTensOfTrillions()

		def ContainsManyTensOfTrillions()
			return This.ContainsTensOfTrillions()

		#--

		def HasTensOfTrillions()
			return This.ContainsTensOfTrillions()

		def HasSeveralTensOfTrillions()
			return This.ContainsTensOfTrillions()

		def HasManyTensOfTrillions()
			return This.ContainsTensOfTrillions()

	# TRUE if the number is at least 100 trillion.
	def ContainsHundredsOfTrillions()
		return This.NumericValue() >= 100_000_000_000_000

		def ContainsSeveralHundredsOfTrillions()
			return This.HasHundredsOfTrillions()

		def ContainsManyHundredsOfTrillions()
			return This.HasHundredsOfTrillions()

		#--

		def HasHundredsOfTrillions()
			return This.ContainsHundredsOfTrillions()

		def HasSeveralHundredsOfTrillions()
			return This.HasHundredsOfTrillions()

		def HasManyHundredsOfTrillions()
			return This.HasHundredsOfTrillions()

	  #----------------------------------#
	 #    REMOVING SPACES FROM NUMBER   #
	#----------------------------------#

	def RemoveSpaces()
		This.Update( This.ToStzString().SpacesRemoved() )

	def RemoveSpacesQ()
		This.RemoveSpaces()
		return This

	def SpacesRemoved()
		_cResult_ = This.Copy().RemoveSpacesQ().Content()
		return _cResult_

	def RemoveLeadingSpaces()
		This.Update( This.ToStzString().LeadingSpacesRemoved() )

		def RemoveLeadingSpacesQ()
			This.RemoveLeadingSpaces()
			return This

	def LeadingSpacesRemoved()
		_cResult_ = This.Copy().RemoveLeadingSpacesQ().Content()
		return _cResult_

	def RemoveTrailingSpaces()
		This.Update( This.ToStzString().TrailingSpacesRemoved() )

		def RemoveTrailingSpacesQ()
			This.RemoveTrailingSpaces()
			return This

	def TrailingSpacesRemoved()
		_cResult_ = This.Copy().RemoveTrailingSpacesQ().Content()
		return _cResult_

	  #---------------------------------#
	 #    REMOVING ZEROS FROM NUMBER   #
	#---------------------------------#

	# REWRITTEN 2026-07-25. All three of these called stzString methods that do not
	# exist -- RepeatedLeadingcharIs, RepeatedTrailingCharIs,
	# RemoveThisRepeatedLeadingCharQ, RemoveRepeatedTrailingCharQ -- so every one
	# raised R14. That is how ApplyFormatXT() came to fail: Structure() reaches here.
	#
	# The LOGIC was wrong too, independently of the names:
	#   * RemoveZerosFromLeft ALSO stripped trailing zeros, which is not "from left";
	#   * RemoveZeros stripped TRAILING twice and never touched the leading zeros.
	#
	# They are now expressed directly on the digits. The right-hand strip stays
	# guarded by IsReal(): trailing zeros of an INTEGER are significant, and turning
	# 100 into 1 would be a catastrophe rather than a tidy-up.

	# "007" -> "7", "00.5" -> "0.5". A single leading zero before the point is kept.
	def RemoveZerosFromLeft()
		This.Update( _StzStripLeadingZeros("" + This.Content()) )

		def RemoveZerosFromLeftQ()
			This.RemoveZerosFromLeft()
			return This

	# "1.500" -> "1.5". Only for a real number, and only in the fractional part.
	def RemoveZerosFromRight()
		if This.IsReal()
			This.Update( _StzStripTrailingFractionZeros("" + This.Content()) )
		ok

		def RemoveZerosFromRightQ()
			This.RemoveZerosFromRight()
			return This

	# both ends: "007.500" -> "7.5"
	def RemoveZeros()
		This.RemoveZerosFromLeft()
		This.RemoveZerosFromRight()

		

	def ZerosRemoved()
		_cResult_ = This.Copy().RemoveZerosQ().Content()
		return _cResult_

	  #------------------#
	 #    FORMATTING    #
	#------------------#

	# Apply the default number format (mutating).
	def ApplyFormat()
		return This.ApplyFormatXT([])

		# Format the number with the default options (mutating).
		def Format()
			return This.ApplyFormatXT([])

	# Format the number with the given options (mutating).
	def FormatXT(paFormat)
		return This.ApplyFormatXT(paFormat)

	# Apply the given format options to the number (mutating).
	def ApplyFormatXT(paFormat)
	#TODO// Add formatting strings like +99 999.99%
	#TODO// Support Compact form (K, B, M) see methods below
	#TODO// Review the overall accuracy of the formatting logic

		# Setting default configs

			# Precision
			_bRestrictFractionalPart_ = 0
			_nNumberOfDigitsInFractionalPart_ = 0
			_bRoundItWhenRestricted_ = 0
			
			# Round
			_bRounded_ = 0
			_nRoundTo_ = 0
			
			# Alignment
			_bApplyAlignment_ = 0

			_nWidth_ = 0
			_cFillBlanksWith_ = " "
			
			_cAlignTo_ = :Left
			_bFixPrefixToLeft_ = 0
			_bFixSuffixToRight_ = 0
				
			# Sign
			_bShowSign_ = 1
			_bPutNegativeBetweenParentheses_ = 0
			
			# Prefix, separators, and suffix
			_cPrefix_ = ""
			
			_cThousandsSeparator_ = "."

			_cFractionalSeparator_ = ","
			
			_cSuffix_ = ""
			
			# Conversion
			_bToPercentage_ = 0
			_bToScientificNotation_ = 0
			
			_bToHex_ = 0
			_bToBinary_ = 0
			_bToOctal_ = 0
			_nToBase_ = 10
			
			_bToIndian_ = 0
			_bToRoman_ = 0

		# Reading provided configs

			# Precision

			if HasKey(paFormat, :RestrictFractionalPart)
				_bRestrictFractionalPart_ = paFormat[ :RestrictFractionalPart ]
			ok

			if HasKey(paFormat, :NumberOfDigitsInFractionalPart)
				_nNumberOfDigitsInFractionalPart_ = paFormat[ :NumberOfDigitsInFractionalPart ]
			ok

			if HasKey(paFormat, :RoundItWhenRestricted)
				_bRoundItWhenRestricted_ = paFormat[ :RoundItWhenRestricted ]
			ok
		
			# Round

			if HasKey(paFormat, :ApplyRound)
				_bRounded_ = paFormat[ :ApplyRound ]
			ok

			if HasKey(paFormat, :RoundTo)
				_nRoundTo_ = paFormat[ :RoundTo ]
			ok
			
			# Alignment
				
			if HasKey(paFormat, :ApplyAlignment)
				_bApplyAlignment_ = paFormat[ :ApplyAlignment ]
			ok

			if HasKey(paFormat, :Width)
				_nWidth_ = paFormat[ :Width ]
			ok

			if HasKey(paFormat, :FillBlanksWith)
				_cFillBlanksWith_ = paFormat[ :FillBlanksWith ]
			ok

			if HasKey(paFormat, :AlignTo)		
				_cAlignTo_ = paFormat[ :AlignTo ]
			ok

			if HasKey(paFormat, :FixPrefixToLeft)
				_bFixPrefixToLeft_ = paFormat[ :FixPrefixToLeft ]
			ok

			if HasKey(paFormat, :FixSuffixToRight)
				_bFixSuffixToRight_ = paFormat[ :FixSuffixToRight ]
			ok
				
			# Sign

			if HasKey(paFormat, :ShowSign)
				_bShowSign_ = paFormat[ :ShowSign ]
			ok

			if HasKey(paFormat, :PutNegativeBetweenParentheses)
				_bPutNegativeBetweenParentheses_ = paFormat[ :PutNegativeBetweenParentheses ]
			ok
			
			# Prefix, separators, and suffix

			if HasKey(paFormat, :Prefix)
				_cPrefix_ = paFormat[ :Prefix ]
			ok
			
			if HasKey(paFormat, :ThousandsSeparator)
				_cThousandsSeparator_ = paFormat[ :ThousandsSeparator ]
			ok

			if HasKey(paFormat, :FractionalSeparator)
				_cFractionalSeparator_ = paFormat[ :FractionalSeparator ]
			ok
			
			if HasKey(paFormat, :Suffix)
				_cSuffix_ = paFormat[ :Suffix ]
			ok
			
			# Conversion

			if HasKey(paFormat, :ToPercentage)
				_bToPercentage_ = paFormat[ :ToPercentage ]
			ok

			if HasKey(paFormat, :ToScientificNotation)
				_bToScientificNotation_ = paFormat[ :ToScientificNotation ]
			ok

			if HasKey(paFormat, :ToHex)
				_bToHex_ = paFormat[ :ToHex ]
			ok

			if HasKey(paFormat, :ToBinary)
				_bToBinary_ = paFormat[ :ToBinary ]
			ok

			if HasKey(paFormat, :ToOctal)
				_bToOctal_ = paFormat[ :ToOctal ]
			ok

			if HasKey(paFormat, :ToBase)
				_nToBase_ = paFormat[ :ToBase ]
			ok
			
			if HasKey(paFormat, :ToIndian)
				_bToIndian_ = paFormat[ :ToIndian ]
			ok

			if HasKey(paFormat, :ToRoman)
				_bToRoman_ = paFormat[ :ToRoman ]
			ok

		# Computing the required formatting
	
		_cFormattedNumber_ = ""
		_cIntegerPart_ = This.IntegerPartWithoutSign()
		_cFractionalPart_ = ""

		# Managing precision by computing the fractional part

		if _bRestrictFractionalPart_ = 0
			_cFractionalPart_ = This.FractionalPartWithoutZerodot()
		else
			_cCurrentFractionalPart_ = This.FractionalPartWithoutZerodot()
				
			_cFractionalPart_ = ""
			for _i_ = 1 to _nNumberOfDigitsInFractionalPart_
				_cFractionalPart_ += _cCurrentFractionalPart_[_i_]
			next

			if _bRoundItWhenRestricted_ = 1

				#TODO This branch now RUNS (it used to die with R20 at the
				# decimals() call below) but it does not yet round: the loop
				# above has already TRUNCATED _cFractionalPart_ to
				# _nNumberOfDigitsInFractionalPart_ digits, so rounding
				# "0." + that truncated part can never carry.
				# Measured: 3.14159265 to 3 places gives +3,141 with
				# RoundItWhenRestricted both 0 and 1; rounding should give
				# +3,142. The fix is to round the FULL fractional part and
				# truncate afterwards -- a change to what the formatter
				# computes, so it is named here rather than guessed at.

				# Memorise the active round
				_nCurrentRound_ = GetActiveRound()

				# Setting the rounding system to the number of restricted digits
				#
				# StzDecimals(), not decimals(): this code is INSIDE a class
				# that defines a 0-parameter Decimals() method, and in Ring a
				# method shadows a same-named builtin. `decimals(n)` therefore
				# resolved to that method and raised Error (R20) on every call,
				# killing this whole branch. StzDecimals() is a global function,
				# so it reaches the builtin -- and it is the idiom used at the
				# twelve other memorise/restore sites in this file.
				StzDecimals(_nNumberOfDigitsInFractionalPart_)

				# Composing a dummy number with the restricted fraction part
				_cTempNumber_ = "0." + _cFractionalPart_

				# Rounding that number
				_nTempNumber_ = 0+ _cTempNumber_
				# Saving the rounded number in a string
				_cTempNumber_ = ""+ _nTempNumber_

				# Reading the rounded fraction part
				_cFractionalPart_ = ""
				_nTempNumberLen_ = len(_cTempNumber_)
				for _i_ = StzFindFirst(".", _cTempNumber_) + 1 to _nTempNumberLen_
					_cFractionalPart_ += _cTempNumber_[_i_]
				next

				# Restore the rounding system memorised above. Every other
				# memorise/restore pair in this file does this; this one could
				# not, because the branch died at the decimals() call before
				# reaching here. Fixing that made the leak reachable.
				StzDecimals(_nCurrentRound_)
			ok
		ok

		# Managing Sign
			
		if _bShowSign_ and This.Sign() = ""
			_cFormattedNumber_ += "+"
		ok

		if This.Sign() = "-"
				
			if NOT _bPutNegativeBetweenParentheses_
				_cFormattedNumber_ += "-"
			else
				_cFormattedNumber_ += "("
			ok	
		ok

		# Managing prefix

		if _cPrefix_ != ""
			_cFormattedNumber_ += _cPrefix_
		ok

		# Managing separators

		if This.Trillions() != ""
			_cFormattedNumber_ += This.Trillions() + _cThousandsSeparator_
		ok

		if This.Billions() != ""
			_cFormattedNumber_ += This.Billions() + _cThousandsSeparator_
		ok

		if This.Millions() != ""
			_cFormattedNumber_ += This.Millions() + _cThousandsSeparator_
		ok

		if This.Thousands() != ""
			_cFormattedNumber_ += This.Thousands() + _cThousandsSeparator_
		ok

		if This.Hundreds() != ""
			_cFormattedNumber_ += This.Hundreds()
		ok

		# Defining fractional part

		_cCurrentFractionalPart_ = This.FractionalPartWithoutZeroDot()
		_nCurrentNumberOfDigitsInFractionalPart_ = len(_cCurrentFractionalPart_)

		_cNewFractionalPart_ = ""

		if _nNumberOfDigitsInFractionalPart_ <= _nCurrentNumberOfDigitsInFractionalPart_
			for _i_ = 1 to _nNumberOfDigitsInFractionalPart_
				_cNewFractionalPart_ += _cCurrentFractionalPart_[_i_]
			next

		else
			_nDiff_ = _nNumberOfDigitsInFractionalPart_ - _nCurrentNumberOfDigitsInFractionalPart_

			for _i_ = 1 to _nDiff_
				_cNewFractionalPart_ += "0"
			next
		ok

		# Managing round

		_cFractionalPart_ = _cNewFractionalPart_

		if NOT _bRounded_ #TODO // review the round() mechanism! #DONE
			if _cFractionalPart_ != ""
				_cFormattedNumber_ += (_cFractionalSeparator_ + _cFractionalPart_)
			ok
		else
			_oTempNumber_ = new stzNumber(This.RoundTo(_nRoundTo_))

			if _oTempNumber_.FractionalPartWithoutZerodot() != ""

				_cFormattedNumber_ += _cFractionalSeparator_

				if _nNumberOfDigitsInFractionalPart_ <= len(_oTempNumber_.FractionalPartWithoutZerodot())
					for _i_ = 1 to _nNumberOfDigitsInFractionalPart_
						_cFormattedNumber_ += _oTempNumber_.FractionalPartWithoutZerodot()[_i_]
					next

				else 
					_nDiff_ = _nNumberOfDigitsInFractionalPart_ - len(_oTempNumber_.FractionalPartWithoutZerodot())
		
					for _i_ = 1 to _nDiff_
						_cFormattedNumber_ += "0"
					next
				ok				
					
			ok
		ok

		# Managing suffix

		if _cSuffix_ != ""
			_cFormattedNumber_ += _cSuffix_
		ok

		# Adding the closing parenthese if required
		#
		# FIXED 2026-07-25: this asked only whether the OPTION was set, while the
		# opening "(" above is (correctly) also guarded by the number being negative
		# -- so any POSITIVE number formatted with :PutNegativeBetweenParentheses
		# came out with a stray ")" on the end. Visible in test
		# 70_review_implementation, which could not run at all until the dead call in
		# Structure() was repaired.
		if _bPutNegativeBetweenParentheses_ and This.Sign() = "-"
			_cFormattedNumber_ += ")"
		ok

		return _cFormattedNumber_

		_oNumber_ = This
		if bPercent = 1
			_cNumber_ = _oNumber_.InPercentage()
			_oNumber_ = new stzNumber(_cNumber_)
		ok
	
		_cNumber_ = _cPrefix_
		if _bShowSign_
			_cSign_ = ""

			if This.IsPositive()
				_cSign_ = "+"

			but This.IsNegative()
					_cSign_ = "-"

			but This.IsZero()
					_cSign_ = ""
			ok

			_cNumber_ += _cSign_
		ok

		if _oNumber_.Trillions() != ""
			_cNumber_ += _oNumber_.Trillions() + cThousandsSep
		ok

		if _oNumber_.Billions() != ""
			_cNumber_ += _oNumber_.Billions() + cThousandsSep
		ok

		if _oNumber_.Millions() != ""
			_cNumber_ += _oNumber_.Millions() + cThousandsSep
		ok

		if _oNumber_.Thousands() != ""
			_cNumber_ += _oNumber_.Thousands() + cThousandsSep
		ok

		if _oNumber_.Hundreds() != ""
			_cNumber_ += _oNumber_.Hundreds()
		ok

		if _oNumber_.FractionalPart() != ""
			_cNumber_ += _cFractionalSeparator_ + _oNumber_.FractionalPartWithoutZerodot()
		ok

		if bPercent = 1
			_cNumber_ += "%"
		ok

		return _cNumber_


	# The number in compact form (1.2K / 3.4M style).
	#
	# A NUMBER TOO SMALL TO ABBREVIATE IS RETURNED AS ITSELF. The chain below used
	# to have no else, so every value under 1000 compacted to the EMPTY STRING --
	# and 12.25 has no shorter form than "12.25", so nothing is the one answer that
	# cannot be right. KForm() and MForm() just below already end with
	# `return This.Content()`; this one simply lost its branch.
	#
	# It was found through stzHistogram, whose bin labels are built from this: a
	# histogram of small numbers reserved two label rows under its axis and drew
	# nothing in them.
	#
	# The billion boundary was wrong too -- `> 1_000_000_000` let EXACTLY one
	# billion fall through to the same empty answer, where every other boundary in
	# the chain is inclusive.
	def CompactForm()
		_nNumber_ = This.Value()
	    if _nNumber_ >= 1000 and _nNumber_ < 1_000_000
			return '' + RoundN(_nNumber_/1000, 1) + "K"

		but _nNumber_ >= 1_000_000 and _nNumber_ < 1_000_000_000
			return '' + RoundN(_nNumber_/1_000_000, 1) + "M"

		but _nNumber_ >= 1_000_000_000
			return '' + RoundN(_nNumber_/1000_000_000, 1) + "B"

		else
			return This.Content()
		ok

		def ToCompactForm()
			return This.CompactForm()


	# The number in K (thousands) form.
	def KForm()
		_nNumber_ = This.Value()
	    if _nNumber_ >= 1000
	        return '' + RoundN(_nNumber_/1000, 1) + "K"
	    else
	        return This.Content()
	    ok

		def ToKForm()
			return This.KForm()


	# The number in M (millions) form.
	def MForm()
		_nNumber_ = This.Value()
	    if _nNumber_ >= 1_000_000
	        return '' + RoundN(_nNumber_/1_000_000, 1) + "M"
	    else
	        return This.Content()
	    ok

		def ToMForm()
			return This.MForm()

	# The number in B (billions) form.
	def BForm()
		_nNumber_ = This.Value()
	    if _nNumber_ >= 1000_000_000
	        return '' + RoundN(_nNumber_/1000_000_000, 1) + "B"
	    else
	        return This.Content()
	    ok

		def ToBForm()
			return This.BForm()


	# Default-format setting (unsupported in this version: raises).
	def SetDefaultFormat() // TODO
		StzRaise("Unsupported feature in this version!")

	# Locale application (unsupported in this version: raises).
	def ApplyLocale(pcLocale) // TODO
		StzRaise("Unsupported feature in this version!")

	  #------------------------------------------------------------------------#
	 #  Generating a compact form of the number using K letter for thousands  #
	#------------------------------------------------------------------------#



	  #-----------------------------#
	 #     OPERATORS OVERLOADING   #
	#-----------------------------#

	#TODO // Operators should carry same semantics in all classes...
	#TODO // Make a request to Mahmoud to enable multichar operators in Ring

	#WARNING // DON'T ADD = OPERATOR
	# Because it causes semantic conflict with
	# feature in stzExtCode (see CREATE_TABLE sql function)

	def operator (pOp, pValue)

		#WARNING // DON'T ADD = OPERATOR
		# Because it causes semantic conflict with
		# feature in stzExtCode (see CREATE_TABLE sql function)

		if  pOp = "+"
			if isString(pValue)
				return This.Added(pValue)

			but @IsStzString(pValue)
				This.Add(pValue.Content())
				return This

			but isNumber(pValue)
				return This.Added(""+pValue)

			but @IsStzNumber(pValue)
				This.Add(pValue.Content())
				return This

			but isList(pValue)
				return This.AddedMany(pValue)

			but @IsStzList(pValue)
				This.AddMany(pValue.Content())
				return This
		
			ok

		but pOp = "-"
			if isString(pValue)
				return This.SubStructed(pValue)

			but @IsStzString(pValue)
				This.SubStruct(pValue.Content())
				return This

			but isNumber(pValue)
				return This.SubStructed(""+pValue)

			but @IsStzNumber(pValue)
				This.SubStruct(pValue.Content())
				return This

			but isList(pValue)
				return This.SubStructedMany(pValue)

			but @IsStzList(pValue)
				This.SubStructMany(pValue.Content())
				return This
		
			ok

		but pOp = "*"
			if isString(pValue)
				return This.MultipliedBy(pValue)

			but @IsStzString(pValue)
				This.MultiplyBy(pValue.Content())
				return This

			but isNumber(pValue)
				return This.MultipliedBy(""+pValue)

			but @IsStzNumber(pValue)
				This.MultiplyBy(pValue.Content())
				return This

			but isList(pValue)
				return This.MultipliedByMany(pValue)

			but @IsStzList(pValue)
				This.MultiplyByMany(pValue.Content())
				return This
		
			ok

		but pOp = "/"
			if isString(pValue)
				return This.DividedBy(pValue)

			but @IsStzString(pValue)
				This.DivideBy(pValue.Content())
				return This

			but isNumber(pValue)
				return This.DividedBy(""+pValue)

			but @IsStzNumber(pValue)
				This.DivideBy(pValue.Content())
				return This

			but isList(pValue)
				return This.dividedByMany(pValue)

			but @IsStzList(pValue)
				_aResult_ = Q( This.DivideByMany(pValue.Content()) )
				return _aResult_
		
			ok

		but pOp = "^" or pOp = "^^"
			if @IsStzNumber(pValue) or
			   (@IsStzString(pValue) and Q(pValue).IsNumberInString())

				
				_cPower_ = This.Power()
				This.UpdateWith(_cPower_)

			else

				return This.Power(pValue)
			ok

		but pOp = "%"
			return This.Modulo(pValue)

		but pOp = ">"
			return This.IsStrictlyGreaterThan(pValue)

		but pOp = ">="
			# FIXED 2026-07-25: was IsGreaterThanOrEqualTo (no such method)
			return This.IsEqualOrGreaterThan(pValue)

		but pOp = "<"
			return This.IsStrictlyLessThan(pValue)

		but pOp = "<="
			# FIXED 2026-07-25: was IsLessThanOrEqualTo (no such method)
			return This.IsLessOrEqualTo(pValue)

		but pOp = "<>" or pOp = "!"
			return This.IsDifferentFrom(pValue)

		but pOp = "++" #TODO // check if it works! (++ is reserved by Ring)
			return This.NextNumber()

		but pOp = "--" #TODO // check if it works! (-- is reserved by Ring)
			return This.PreviousNumber()

		but pOp = "[]"
			# Supporting external Python syntax:
				# In Pyhton: 345 // 100 #--> 3
				# In Ring with Softanza:
				# ? Q(345)['// 100'] #--> 3

			if isString(pValue) and Q(pValue).StartsWith("//") 
				_oStr_ = new stzString(pValue)
				_nLen_ = _oStr_.NumberOfChars()
				_cRemainingPart_ = _oStr_.SectionQ(3, _nLen_).Trimmed()

				if Q(_cRemainingPart_).IsNumberInString()
					_n_ = 0+ _cRemainingPart_
					_nResult_ = floor( This.NumbericValue() / _n_ )
					#NOTE this a misspelled form of NumericValue()!

					return _nResult_
				ok

			ok

			return This.Content()[pValue]

		ok

	  #--------------------------------#
	 #    USUED FOR NATURAL-CODING    #
	#--------------------------------#

	# Always TRUE: the object IS a stzNumber.
	def IsStzNumber()
		return 1

	# The Softanza type symbol: :stzNumber.
	def stzType()
		return :stzNumber

	#--- ITEM
	
	# Always TRUE: a number can be a list item.
	def IsItem()
		return 1
	
	# TRUE if the number occurs in the given list.
	def IsItemOf(paList)
		return ListContains(paList, This.NumericValue())
		
		def AsAnItemOf(paList)
			return This.IsItemOf(paList)
		
	def IsItemIn(paList)
		return This.IsItemOf(paList)
		
		def IsAnItemIn(paList)
			return This.IsItemOf(paList)

	#--- MEMEBER

	# Always TRUE: a number can be a member.
	def IsMember()
		return 1
	
	# TRUE if the number (as held) occurs in the given list.
	def IsMemberOf(paList)
		return ListContains(paList, This.Content())
		
		def AsAMemberOf(paList)
			return This.IsMemberOf(paList)
		
	def IsMemberIn(paList)
		return This.IsMemberOf(paList)
		
			def IsAMemberIn(paList)
				return This.IsMemberOf(paList)
	
	#--- NUMBER
	
	# Always TRUE: the object holds a number.
	def IsANumber()
		return 1

		# Always FALSE: it IS a number.
		def IsNotANumber()
			return 0

	# Always FALSE: a number is not a string.
	def IsAString()
		return 0

		# Always TRUE: a number is not a string.
		def IsNotAString()
			return 1

	# Always FALSE: a number is not a list.
	def IsAList()
		return 0

		# Always TRUE: a number is not a list.
		def IsNotAList()
			return 1

	# Always TRUE: the wrapper is an object.
	def IsAnObject()
		return 1

		# Always TRUE: the wrapper is an object.
		def IsAObject()
			return 1

		# Always FALSE: the wrapper is an object.
		def IsNotAnObject()
			return 1

	# TRUE if the number occurs in the given list.
	def IsNumberOf(paList)
		return This.IsItemOf(paList)
	
		def IsANumberOf(paList)
			return This.IsNumberOf(paList)
		
	def IsNumberIn(paList)
		return This.IsNumberOf(paList)
	
		def IsANumberIn(paList)
			return This.IsNumberOf(paList)

	# TRUE if the number occurs in the given list.
	def IsOneOfThese(paList)
		return This.IsItemOf(paList)

		# TRUE if the number occurs in NONE of the given values.
		def IsNotOneOfThese(paList)
			return NOT This.IsOneOfThese(paList)
	
	#--- STRING
	
	# Always FALSE: a number is not a letter.
	def IsLetter()
		return 0
	
	# Always FALSE: a number is not a letter.
	def IsALetter()
		return 0
	
	# Always FALSE: a number is not a letter.
	def IsLetterOf(pStrOrListOfChars)
		return 0
	
		# Always FALSE: a number is not a letter.
		def IsALetterOf(pcStr)
			return 0
		
	# Always FALSE: a number is not a letter.
	def IsLetterIn(pcStr)
		return 0
	
		# Always FALSE: a number is not a letter.
		def IsALetterIn(pcStr)
			return 0
	
	# Always FALSE: a number is not a char.
	def IsCharOf(pStrOrListOfChars)
		return 0
	
		# Always FALSE: a number is not a char.
		def IsACharOf(pcStr)
			return 0
	
	# Always FALSE: a number is not a char.
	def IsCharIn(pcStr)
		return 0
	
		# Always FALSE: a number is not a char.
		def IsACharIn(pcStr)
			return 0
	
	  #------------------------------------------#
	 #   STRINGIFY(), TOSTRING(), AND TOCODE()  #
	#------------------------------------------#

	def Stringify()
		# Do nothing, the object is naturally stringified
		# becauses it contains its value always as a string

		def StringifyQ()
			return new stzString( This.StringValue() )

		def DeepStringifiy()
			// Nothing

			def DeepStringfyQ()
				return This.StringifyQ()

	def Stringified()
		return This.StringValue()

		def DeepStringified()
			return This.Stringified()

	def ToString()
		return This.StringValue()

		def ToStringQ()
			return new stzString( This.ToString() )
	
	def ToCode()
		return This.StringValue()

		def ToCodeQ()
			return new stzString( This.ToCode() )

	  #-------------#
	 #    MISC.    #
	#-------------#

	# TRUE if the number is a valid RGB color value.
	def IsRGBColor()
		return @IsRGBColor(This.Content())

		# TRUE if the number is a valid RGB color value.
		def IsAnRGBColor()
			return @IsRGBColor(This.Content())

	# TRUE if the given value is a number too.
	def HasSameTypeAs(p)
		return isNumber(p)

	# The numbers from this one UP TO n, as a list.
	def UpTo(pnOtherNumber)
		if pnOtherNumber > This.Value()
			_anResult_ = This.Value() : pnOtherNumber
			return _anResult_
		ok
	
	# The numbers from this one DOWN TO n, as a list.
	def DownTo(pnOtherNumber)
		if This.Value() > pnOtherNumber
			_anResult_ = This.Value() : pnOtherNumber
			return _anResult_
		ok

	# Swapping the content of the stzNumber with an other stzNumber

	def SwapWith(pOtherStzNumber)

		if CheckingParams()

			if NOT @IsStzNumber(pOtherStzNumber)
				StzRaise("Incorrect param type! pOtherStzNumber must be a stzNumber object.")
			ok
	
		ok

		_nThis_ = This.Content()
		_nOther_ = pOtherStzNumber.Content()

		This.UpdateWith(_nOther_)
		pOtherStzNumber.UpdateWith(_nThis_)


		def SwapWithQ(pOtherStzNumber)
			This.SwapWith(pOtherStzNumber)
			return This

		def SwapContentWith(pOtherStzNumber)
			This.SwapWith(pOtherStzNumber)

			def SwapContentWithQ(pOtherStzNumber)
				return This.SwapWithQ(pOtherStzNumber)

	# The least common multiple with the given number.
	# FIXED 2026-07-25: this was a SECOND, simpler implementation that went straight
	# to the engine, so it neither unwrapped a `:With` named param nor handled a
	# LIST -- and stzListOfNumbers.LeastCommonMultiple() calls exactly this name with
	# `:With = <list>`, which is why that method silently answered 0 instead of the
	# lcm. A short name should be an ALIAS of the full one, not a divergent twin.
	def LCM(pOtherNumber)
		return This.LeastCommonMultiple(pOtherNumber)

	# The greatest common divisor with the given number.
	# ...and the same for GCD, for the same reason: one implementation, one meaning.
	def GCD(pOtherNumber)
		return This.GreatestCommonDividor(pOtherNumber)

	  #=========================================#
	 #  ENGINE-BACKED NUMBER OPERATIONS        #
	#=========================================#

	# TRUE if the integer is a perfect number (equals the sum of its
	# divisors).
	def IsPerfect()
		if NOT This.IsInteger()
			return 0
		ok
		return StzEngineNumberIsPerfect(This.NumericValue())

		def IsPerfectNumber()
			return This.IsPerfect()

	# How many digits the integer has.
	def DigitCount()
		if NOT This.IsInteger()
			return len(This.IntegerPartValue())
		ok
		return StzEngineNumberDigitCount(This.NumericValue())

		def HowManyDigits()
			return This.DigitCount()

	# The sum of the digits of the integer.
	#@ aka  sum of the digits, add the digits together
	def DigitSum()
		if NOT This.IsInteger()
			StzRaise("Can't compute digit sum of a non-integer!")
		ok
		return StzEngineNumberDigitSum(This.NumericValue())

		def SumOfDigits()
			return This.DigitSum()

	# The digits of the integer, reversed.
	def ReverseDigits()
		if NOT This.IsInteger()
			StzRaise("Can't reverse digits of a non-integer!")
		ok
		return StzEngineNumberReverseDigits(This.NumericValue())

		def ReversedDigits()
			return This.ReverseDigits()

	# TRUE if the digits read the same backward.
	def IsDigitPalindrome()
		if NOT This.IsInteger()
			return 0
		ok
		return StzEngineNumberIsPalindrome(This.NumericValue())

		def IsPalindromeNumber()
			return This.IsDigitPalindrome()

	# The Fibonacci value for this integer.
	def Fibonacci()
		if NOT This.IsInteger()
			StzRaise("Can't compute Fibonacci of a non-integer!")
		ok
		_n_ = This.NumericValue()
		if _n_ < 0
			StzRaise("Can't compute Fibonacci of a negative number!")
		ok
		pBigInt = StzEngineNumberFibonacci(_n_)
		_cResult_ = StzEngineBigIntToString(pBigInt)
		StzEngineBigIntFree(pBigInt)
		return _cResult_

		def FibonacciQ()
			return new stzNumber(This.Fibonacci())

	# The methods of the object (Ring reflection).
	def Methods()
		return ring_methods(This)

	# The attributes of the object (Ring reflection).
	def Attributes()
		return ring_attributes(This)

	# The lowercase class name: "stznumber".
	def ClassName()
		return "stznumber"

		def StzClassName()
			return This.ClassName()

		def StzClass()
			return This.ClassName()

	# Always FALSE: plain numbers carry no name.
	def IsNamedObject()
		return 0

	# How many times the given digit occurs in the number.
	def HowMany(n)
		if isNumber(n)
			n = "" + n
		ok

		if NOT isString(n)
			StzRaise("Incorrect param type! n must be a number or string.")
		ok
		
		_nResult_ = This.ToStzString().HowMany(n)
		return _nResult_

	# The digits of the number, as a list.
	def Digits()
		_acChars_ = This.StringValueQ().RemoveManyQ([ "+", "-", "." ]).Chars()
		_nLen_ = len(_acChars_)

		_anResult_ = []

		for _i_ = 1 to _nLen_
			_anResult_ + (0+ _acChars_[_i_])

		next

		return _anResult_

		def DigitsQ()
			return new stzList( This.Digits() )

		# The digits, in the requested return type (QRT).
		def DigitsQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Digits() )
			on :stzListOfNumbers
				return new stzListOfNumbers( This.Digits() )
			other
				StzRaise("Unsupported return type!")
			off

	  #-------------------#
	 # PERCENTAGE FORMS  #
	#-------------------#

	# The number as a percentage string.
	def Percent()
		return This.NumericValue() / 100

	# What percentage this number is OF the given one.
	def PercentOf(n)
		return This.NumbericValue() * (n/100)

	  #=====================================#
	 #    INTERNAL KITCHEN OF THE CLASS    #
	#=====================================#

	Private

	# Record whether the rendered result lost anything relative to the f64 the
	# operation produced. Transcendentals are inherently approximate; a division
	# that does not terminate in the available places is approximate; everything
	# else that renders back to the same value is exact.
	def _pvtNoteExactness(pcOp, pcA, pcB, pnResult, pcRendered)
		if _pvtIsTranscendental(pcOp)
			@cExactness = :inexact
			@cInexactReason = "'" + pcOp + "' has no exact decimal result in general"
			return
		ok
		if NOT _pvtRendersExactly(pcRendered, pnResult)
			@cExactness = :inexact
			if pcOp = "/"
				@cInexactReason = "the division does not terminate in " +
					len(_StzDecimalsPart("" + pcRendered)) + " decimal place(s)"
			else
				@cInexactReason = "the result was rounded to " +
					len(_StzDecimalsPart("" + pcRendered)) + " decimal place(s)"
			ok
			return
		ok
		# the operands themselves may already carry an approximation
		if This.IsApproximate()
			return
		ok
		@cExactness = :exact
		@cInexactReason = ""

	def pvtCalculate(pcOperation, pOtherNumber)

		# Makes basic arithmetic operations (+, -, *, and /) and
		# other mathematical operations (sin, cos, tan, log...) in
		# a round-independent way:

		#--> Whatever the active round defined by decimals() is,
		# the result is always returned in a string containing the
		# effective number of the decimals.

		# EXACTNESS, 2026-07-25 (numeric foundation phase 1). Two things were
		# wrong here, and both destroyed value silently.
		#
		# (1) THE RESULT'S DECIMAL PLACES came from This.Round() -- the RECEIVER's
		# places alone -- for every operation. That is right for + and - only when
		# the receiver already has at least as many places as the operand, and it is
		# never right for *. It gave 0.1 * 0.1 = 0.0, 0.5 * 0.5 = 0.3,
		# 19.99 * 0.15 = 3.00, 1 + 0.001 = 1.00 and 0.5 + 0.125 = 0.6. The places
		# are now derived PER OPERATION from both operands (_pvtResultPlaces_).
		#
		# (2) EXACT INTEGERS beyond 2^53 were lost, because both operands go through
		# NumericValue() into an f64. When both operands are integers and the result
		# can exceed the f64-exact range, the operation is now redone through the
		# engine's arbitrary-precision integers, which have been present and correct
		# all along (std.math.big).
		#
		# Both paths record whether the result is EXACT, so IsExact()/Why() can tell
		# the caller instead of leaving them to guess.

		_cSelfContent_ = "" + This.Content()
		_cOtherContent_ = ""
		if isString(pOtherNumber)
			_cOtherContent_ = pOtherNumber
		but isNumber(pOtherNumber)
			_cOtherContent_ = "" + pOtherNumber
		ok

		# THE EXACT PATH, before anything touches an f64. + - * % ^ on decimal
		# operands are computed on the SCALED INTEGERS through the engine's
		# arbitrary-precision integers, so the answer is exact by construction
		# rather than "f64 then rounded to a hopeful number of places":
		# 19.99 * 0.15 becomes 1999 * 15 = 29985 with the point 4 from the right.
		# Small integer arithmetic keeps the f64 fast path, where it is exact anyway.
		# A FRACTION ON EITHER SIDE takes the rational path -- promotion is upward,
		# so 0.25 + 1/4 is 1/2 rather than 0.5. Only + - * / are defined on
		# fractions here; % and ^ fall through to the ordinary handling.
		if StzFindFirst(pcOperation, [ "+", "-", "*", "/" ]) > 0
			if _StzIsRationalString(_cSelfContent_) or _StzIsRationalString(_cOtherContent_)
				_cRat_ = _StzExactRationalCalc(pcOperation, _cSelfContent_, _cOtherContent_)
				if _cRat_ != ""
					@cExactness = :exact
					@cInexactReason = ""
					return _cRat_
				ok
			ok
		ok

		if _pvtIsExactIntegerOp(pcOperation)
			if _pvtWantsExactPath(pcOperation, _cSelfContent_, _cOtherContent_)
				_cX_ = _pvtExactDecimalCalc(pcOperation, _cSelfContent_, _cOtherContent_)
				if _cX_ != ""
					@cExactness = :exact
					@cInexactReason = ""
					return _cX_
				ok
			ok
		ok

		# First, string values are converted to number values
		_n1_ = This.NumericValue()
		if isString(pOtherNumber)
			_n2_ = StringToNumber(pOtherNumber)
		else
			_n2_ = pOtherNumber
		ok
	

		# Then, calculation is made and result is hosted inside
		# the nResult variable
		switch pcOperation
		on "+"
			_nResult_ = _n1_ + _n2_

		on "-"
			_nResult_ = _n1_ - _n2_
	
		on "*"
			_nResult_ = _n1_ * _n2_
	
		on "/"
			_nResult_ = _n1_ / _n2_
	
		on "%"
			_oTemp1_ = new stzNumber(_n1_)
			_oTemp2_ = new stzNumber(_n2_)

			if _oTemp1_.IsInteger() and _oTemp2_.IsInteger()
				_nResult_ = _n1_ % _n2_
			else
				StzRaise("Can't calculate the modulo. The two numbers must be integers!")
			ok
	
		on "^"
			_nResult_ = ring_pow(_n1_, _n2_)
	
		on "sin"
			_nResult_ = ring_sin(_n1_)
	
		on "cos"
			_nResult_ = ring_cos(_n1_)
	
		on "tan"
			_nResult_ = ring_tan(_n1_)
	
		on "cotan"
			_nResult_ = 1 / ring_tan(_n1_)
	
		on "asin"
			_nResult_ = ring_asin(_n1_)
	
		on "acos"
			_nResult_ = ring_acos(_n1_)
	
		on "atan2"
			_nResult_ = ring_atan2(_n1_)
	
		on "sinh"
			_nResult_ = ring_sinh(_n1_)
	
		on "cosh"
			_nResult_ = ring_cosh(_n1_)
	
		on "tanh"
			_nResult_ = ring_tanhh(_n1_)
	
		on "exp"
			_nResult_ = ring_exp(_n1_)
	
		on "log"
			_nResult_ = ring_log(_n1_)
	
		on "log10"
			_nResult_ = ring_log10(_n1_)
	
		on "fabs"
			_nResult_ = fabs(_n1_)

		on "sigmoid"
			_nResult_ = 1 / (1 + ring_exp(-_n1_))
	
		on "DerivativeSigmoid"
			_nSigmoid_ = 1 / (1 + ring_exp(-_n1_))
			_nResult_ = _nSigmoid_ * ( 1 - _nSigmoid_)

		on "LCM"
			_nResult_ = StzEngineNumberLcm(_n1_, _n2_)

		on "GCD"
			_nResult_ = StzEngineNumberGcd(_n1_, _n2_)

		on "inverse"
			_nResult_ = 1 / _n1_

		on "sqrt"
			_nResult_ = sqrt(_n1_)

		# Special case: the result is a list of integers!
		#--> Nothing to round: return the list of factors directly
		on "factors"
			return ring_factors(_n1_)		

		off

		/*
		Now, and before it is returned back, _nResult_ must be put in
		a string to preserve the round expressed in its effective
		round and hosted in a whatever the active round is in
		the program (made using decimals())
		*/

		# The result's DECIMAL PLACES, derived from the operation and BOTH operands
		# rather than from the receiver alone -- see the note at the top.
		_nPlaces_ = _pvtResultPlaces_(pcOperation, _cSelfContent_, _cOtherContent_, This.Round())

		_nCurrentRound_ = StzCurrentRound()
		StzDecimals(_nPlaces_)
		_cResult_ = ""+ _nResult_
		StzDecimals(_nCurrentRound_)

		# ...and record whether that rendering LOST anything, so IsExact()/Why()
		# can answer honestly.
		This._pvtNoteExactness(pcOperation, _cSelfContent_, _cOtherContent_, _nResult_, _cResult_)

		return _cResult_
