# stzComplex -- a number with a real part and an imaginary one (numeric phase 7).
#
#   oZ = new stzComplex(3, 4)
#   ? oZ.Content()      #--> "3+4i"
#   ? oZ.Modulus()      #--> 5
#   ? oZ.IsReal()       #--> FALSE
#
# WHY THIS EXISTS, AND WHY ONLY NOW. Phase 7 of the numeric plan is explicitly gated:
# "each gated on a genuine consumer, not on completeness." Four of its five candidates
# failed that gate -- mpdecimal (the big-int decimal was measured and is sufficient),
# OSQP (nothing poses a quadratic program), HiGHS (nothing poses a mixed-integer one)
# and an FFT (there is no spectral code to serve). Complex numbers passed on ONE
# consumer, written down as a refusal back in phase 4:
#
#   EigenValues() on a non-symmetric matrix RAISED, saying "a general matrix has
#   complex eigenvalues, which needs a different algorithm and a complex type the
#   library does not have".
#
# That refusal was right -- returning the eigenvalues of (A + A')/2 and letting you
# believe they belong to A would have been far worse -- and this is the type it named.
#
# WHAT IS DELIBERATELY ABSENT: log, the inverse trigonometric functions, and general
# powers. Each needs a branch-cut policy, nothing asks for one yet, and a guessed
# branch cut is a wrong answer a library cannot take back later.

# Holds a complex number, a real part plus an imaginary part, and does its arithmetic: sum, product, quotient, modulus, argument, conjugate.
#
# Build one with new stzComplex(re, im). It follows the Softanza forms: an active verb (Conjugate,
# Negate) changes the number in place; the passive form (Conjugated, Negated, Plus, Times ...)
# returns the result as a [ re, im ] pair and leaves the number alone; the Q twin (ConjugatedQ,
# PlusQ ...) returns a new stzComplex to chain on. The other operand of Plus, Minus, Times,
# DividedBy and Equals may be a number, a pair or another stzComplex. Log, inverse trigonometry and
# general powers are absent on purpose. The factory function StzComplexQ(re, im) written at the end
# of the file is not reachable as a function today (error R3).
#
#   receiver   o1 = new stzComplex(3, 4)
#   example    ? o1.Content()
#              #--> 3+4i
#              ? o1.Modulus()
#              #--> 5
#              ? @@( o1.Times([ 0, 1 ]) )
#              #--> [ -4, 3 ]
#              ? o1.PlusQ([ 1, 1 ]).Content()
#              #--> 4+5i
#              ? o1.IsReal()
#              #--> 0
#   see        stzNumber, stzMatrix
class stzComplex from stzObject

	@nRe = 0
	@nIm = 0

	# Builds a complex number from a real part and an imaginary part; a part that is not a number becomes 0.
	#
	#   pnReal        the real part, or a pair [ re, im ] that carries both
	#   pnImaginary   the imaginary part (give 0 when pnReal is a pair)
	#   returns       nothing; the object is built
	#   warning       Both arguments are required: new stzComplex([2, -3]) with the pair alone
	#                 raises R19 (less number of parameters), so give new stzComplex([2, -3], 0); a
	#                 text for a part is silently read as 0: ("x", "y") builds 0+0i
	#   see           Parts, Content
	def init(pnReal, pnImaginary)
		if isList(pnReal) and len(pnReal) = 2
			@nRe = pnReal[1]
			@nIm = pnReal[2]
		else
			@nRe = pnReal
			@nIm = pnImaginary
		ok
		if NOT isNumber(@nRe)
			@nRe = 0
		ok
		if NOT isNumber(@nIm)
			@nIm = 0
		ok

	# Returns the real part of the number.
	#
	#   returns    a number
	#   see        ImaginaryPart, Parts
	def RealPart()
		return @nRe

	# Returns the imaginary part of the number, the coefficient of i.
	#
	#   returns    a number
	#   see        RealPart, Parts
	def ImaginaryPart()
		return @nIm

	# Returns the real and imaginary parts together as a pair.
	#
	#   returns    a list [ re, im ]
	#   see        RealPart, ImaginaryPart
	def Parts()
		return [ @nRe, @nIm ]

	# Returns the number written as text, such as 3+4i or 3-4i, a bare 3 when the imaginary part is 0, 5i when the real part is 0.
	#
	#   returns    a text
	#   note       i and -i stand for an imaginary part of 1 and -1
	#   see        Parts
	#@ aka  "3+4i", "3-4i", "3" when the imaginary part is zero, "4i" when the real part is
	def Content()
		if @nIm = 0
			return "" + @nRe
		ok
		if @nRe = 0
			if @nIm = 1
				return "i"
			ok
			if @nIm = -1
				return "-i"
			ok
			return "" + @nIm + "i"
		ok
		if @nIm < 0
			return "" + @nRe + "-" + (-@nIm) + "i"
		ok
		return "" + @nRe + "+" + @nIm + "i"

	# TRUE if the imaginary part is 0.
	#
	#   returns    TRUE or FALSE
	#   note       0 itself is real
	#   see        IsImaginary, IsZero
	def IsReal()
		return @nIm = 0

	# TRUE if the real part is 0 and the imaginary part is not.
	#
	#   returns    TRUE or FALSE
	#   note       0 is not imaginary
	#   see        IsReal, IsZero
	def IsImaginary()
		return @nRe = 0 and @nIm != 0

	# TRUE if both parts are 0.
	#
	#   returns    TRUE or FALSE
	#   see        IsReal
	def IsZero()
		return @nRe = 0 and @nIm = 0

	# Returns the distance of the number from 0, the length sqrt(re^2 + im^2), computed so that very large parts do not overflow.
	#
	#   returns    a number, 0 or more
	#   note       Magnitude is the same method; 3+4i has modulus 5
	#   see        Argument, Magnitude
	#@ aka  |z|. Via the hypotenuse rather than sqrt(re^2 + im^2), which overflows for parts above about 1e154 on values the answer handles perfectly well.
	def Modulus()
		_nA_ = fabs(@nRe)
		_nB_ = fabs(@nIm)
		if _nA_ = 0 and _nB_ = 0
			return 0
		ok
		if _nA_ > _nB_
			_nR_ = _nB_ / _nA_
			return _nA_ * sqrt(1 + _nR_ * _nR_)
		ok
		_nR_ = _nA_ / _nB_
		return _nB_ * sqrt(1 + _nR_ * _nR_)

		def Magnitude()
			return This.Modulus()

	# Returns the angle of the number from the positive real axis, in radians, between minus pi (excluded) and pi.
	#
	#   returns    a number
	#   note       0 for the number 0; -1 gives pi
	#   see        Modulus
	#@ aka  the angle from the positive real axis, in (-pi, pi]
	def Argument()
		return atan2(@nIm, @nRe)

	# Changes the number into its conjugate in place, the imaginary part changing sign.
	#
	#   returns    nothing; use ConjugateQ to chain
	#   note       Conjugated leaves the number alone
	#   see        Conjugated, Negate
	#@ aka  ── THE FORMS, which in Softanza carry the semantics ──
	def Conjugate()
		@nIm = -@nIm

		def ConjugateQ()
			This.Conjugate()
			return This

	# Returns the conjugate as a pair [ re, -im ], leaving the number unchanged.
	#
	#   returns    a list [ re, im ]
	#   note       ConjugatedQ answers a new stzComplex
	#   see        Conjugate
	def Conjugated()
		return [ @nRe, -@nIm ]

		def ConjugatedQ()
			return new stzComplex(@nRe, -@nIm)

	# Changes the number into its opposite in place, both parts changing sign.
	#
	#   returns    nothing; use NegateQ to chain
	#   see        Negated, Conjugate
	def Negate()
		@nRe = -@nRe
		@nIm = -@nIm

		def NegateQ()
			This.Negate()
			return This

	# Returns the opposite as a pair [ -re, -im ], leaving the number unchanged.
	#
	#   returns    a list [ re, im ]
	#   note       NegatedQ answers a new stzComplex
	#   see        Negate
	def Negated()
		return [ -@nRe, -@nIm ]

		def NegatedQ()
			return new stzComplex(-@nRe, -@nIm)

	# Returns the sum with another number as a pair [ re, im ], leaving this number unchanged.
	#
	#   pZ         the other number: a plain number, a pair [ re, im ] or a stzComplex
	#   returns    a list [ re, im ]
	#   note       PlusQ answers a new stzComplex to chain on; any other kind of value raises "Give
	#              me a number, a [re, im] pair, or another stzComplex."
	#   see        Minus, Times
	#@ aka  ── arithmetic: DATA out, or a chainable object from the Q twin ──
	def Plus(pZ)
		_a_ = This._PartsOf(pZ)
		return [ @nRe + _a_[1], @nIm + _a_[2] ]

		def PlusQ(pZ)
			_a_ = This._PartsOf(pZ)
			return new stzComplex(@nRe + _a_[1], @nIm + _a_[2])

	# Returns the difference with another number as a pair [ re, im ], leaving this number unchanged.
	#
	#   pZ         the number to subtract: a plain number, a pair [ re, im ] or a stzComplex
	#   returns    a list [ re, im ]
	#   note       MinusQ answers a new stzComplex
	#   see        Plus
	def Minus(pZ)
		_a_ = This._PartsOf(pZ)
		return [ @nRe - _a_[1], @nIm - _a_[2] ]

		def MinusQ(pZ)
			_a_ = This._PartsOf(pZ)
			return new stzComplex(@nRe - _a_[1], @nIm - _a_[2])

	# Returns the product with another number as a pair [ re, im ], leaving this number unchanged.
	#
	#   pZ         the factor: a plain number, a pair [ re, im ] or a stzComplex
	#   returns    a list [ re, im ]
	#   note       TimesQ answers a new stzComplex; 3+4i times i is -4+3i
	#   see        DividedBy
	def Times(pZ)
		_a_ = This._PartsOf(pZ)
		return [ @nRe * _a_[1] - @nIm * _a_[2], @nRe * _a_[2] + @nIm * _a_[1] ]

		def TimesQ(pZ)
			_a_ = This._PartsOf(pZ)
			return new stzComplex(@nRe * _a_[1] - @nIm * _a_[2],
				@nRe * _a_[2] + @nIm * _a_[1])

	# Returns the quotient by another number as a pair [ re, im ], leaving this number unchanged, using a form that does not overflow.
	#
	#   pZ         the divisor: a plain number, a pair [ re, im ] or a stzComplex, not zero
	#   returns    a list [ re, im ]
	#   note       dividing by 0 raises "Can't divide a complex number by zero."; DividedByQ answers
	#              a new stzComplex
	#   see        Times
	#@ aka  Smith's formula, for the same overflow reason as Modulus(): dividing through by the larger part first keeps the intermediates near 1.
	def DividedBy(pZ)
		_a_ = This._PartsOf(pZ)
		_c_ = _a_[1]
		_d_ = _a_[2]
		if _c_ = 0 and _d_ = 0
			stzraise("Can't divide a complex number by zero.")
		ok
		if fabs(_c_) >= fabs(_d_)
			_r_ = _d_ / _c_
			_den_ = _c_ + _d_ * _r_
			return [ (@nRe + @nIm * _r_) / _den_, (@nIm - @nRe * _r_) / _den_ ]
		ok
		_r_ = _c_ / _d_
		_den_ = _c_ * _r_ + _d_
		return [ (@nRe * _r_ + @nIm) / _den_, (@nIm * _r_ - @nRe) / _den_ ]

		def DividedByQ(pZ)
			_a_ = This.DividedBy(pZ)
			return new stzComplex(_a_[1], _a_[2])

	# TRUE if the other number has the same real and imaginary parts.
	#
	#   pZ         the number to compare with: a plain number, a pair [ re, im ] or a stzComplex
	#   returns    TRUE or FALSE
	#   note       the comparison is exact, with no tolerance for rounding
	#   see        Plus
	def Equals(pZ)
		_a_ = This._PartsOf(pZ)
		return @nRe = _a_[1] and @nIm = _a_[2]

	def _PartsOf(pZ)
		if isNumber(pZ)
			return [ pZ, 0 ]
		ok
		if isList(pZ) and len(pZ) = 2
			return [ pZ[1], pZ[2] ]
		ok
		if isObject(pZ)
			return pZ.Parts()
		ok
		stzraise("Give me a number, a [re, im] pair, or another stzComplex.")

func StzComplexQ(pnRe, pnIm)
	return new stzComplex(pnRe, pnIm)
