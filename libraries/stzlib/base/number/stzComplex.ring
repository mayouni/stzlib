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

class stzComplex from stzObject

	@nRe = 0
	@nIm = 0

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

	def RealPart()
		return @nRe

	def ImaginaryPart()
		return @nIm

	def Parts()
		return [ @nRe, @nIm ]

	# "3+4i", "3-4i", "3" when the imaginary part is zero, "4i" when the real part is
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

	def IsReal()
		return @nIm = 0

	def IsImaginary()
		return @nRe = 0 and @nIm != 0

	def IsZero()
		return @nRe = 0 and @nIm = 0

	# |z|. Via the hypotenuse rather than sqrt(re^2 + im^2), which overflows for
	# parts above about 1e154 on values the answer handles perfectly well.
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

	# the angle from the positive real axis, in (-pi, pi]
	def Argument()
		return atan2(@nIm, @nRe)

	# ── THE FORMS, which in Softanza carry the semantics ──
	#
	# An ACTIVE verb mutates this number and returns nothing; the PASSIVE ...ed form
	# returns the [re, im] DATA and leaves it alone; the Q twin returns a new
	# stzComplex so calls chain. The first version of this class had Conjugate() and
	# Negated() both returning new objects from plain names, which breaks the rule
	# that a plain method returns data and only a Q form returns a Softanza object.

	def Conjugate()
		@nIm = -@nIm

		def ConjugateQ()
			This.Conjugate()
			return This

	def Conjugated()
		return [ @nRe, -@nIm ]

		def ConjugatedQ()
			return new stzComplex(@nRe, -@nIm)

	def Negate()
		@nRe = -@nRe
		@nIm = -@nIm

		def NegateQ()
			This.Negate()
			return This

	def Negated()
		return [ -@nRe, -@nIm ]

		def NegatedQ()
			return new stzComplex(-@nRe, -@nIm)

	# ── arithmetic: DATA out, or a chainable object from the Q twin ──

	def Plus(pZ)
		_a_ = This._PartsOf(pZ)
		return [ @nRe + _a_[1], @nIm + _a_[2] ]

		def PlusQ(pZ)
			_a_ = This._PartsOf(pZ)
			return new stzComplex(@nRe + _a_[1], @nIm + _a_[2])

	def Minus(pZ)
		_a_ = This._PartsOf(pZ)
		return [ @nRe - _a_[1], @nIm - _a_[2] ]

		def MinusQ(pZ)
			_a_ = This._PartsOf(pZ)
			return new stzComplex(@nRe - _a_[1], @nIm - _a_[2])

	def Times(pZ)
		_a_ = This._PartsOf(pZ)
		return [ @nRe * _a_[1] - @nIm * _a_[2], @nRe * _a_[2] + @nIm * _a_[1] ]

		def TimesQ(pZ)
			_a_ = This._PartsOf(pZ)
			return new stzComplex(@nRe * _a_[1] - @nIm * _a_[2],
				@nRe * _a_[2] + @nIm * _a_[1])

	# Smith's formula, for the same overflow reason as Modulus(): dividing through
	# by the larger part first keeps the intermediates near 1.
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
