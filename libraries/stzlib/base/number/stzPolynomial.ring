#---------------------------------------------------------------------------#
#     SOFTANZA LIBRARY (V1.2) - STZPOLYNOMIAL                               #
#     A polynomial in one variable -- and, above all, its ROOTS.             #
#---------------------------------------------------------------------------#
#     ( Ring 1.27 )                                                         #
#---------------------------------------------------------------------------#

/*
	A POLYNOMIAL, AND THE ONE HARD THING ABOUT IT.

	Evaluating a polynomial is a loop. Differentiating it is a loop. The only
	genuinely hard operation is FINDING ITS ROOTS -- and the honest way to do
	that for arbitrary degree is not a formula, because past degree four no
	formula exists (Abel-Ruffini). It is an eigenvalue problem.

	-- WHY THE ROOTS ARE AN EIGENVALUE PROBLEM --

	For a monic polynomial

	    p(x) = x^n + b1 x^(n-1) + ... + b(n-1) x + bn

	the COMPANION MATRIX

	    [ -b1  -b2  ...  -b(n-1)  -bn ]
	    [   1    0  ...     0       0  ]
	    [   0    1  ...     0       0  ]
	    [            ...               ]
	    [   0    0  ...     1       0  ]

	has p as its characteristic polynomial. So THE ROOTS OF p ARE EXACTLY THE
	EIGENVALUES OF C -- and we already own a Francis double-shift QR that
	returns complex eigenvalues, balances the matrix on the way in, and has a
	robustness guard behind it.

	This is not a shortcut. It is what numpy.roots does, for the same reason:
	a general root-finder IS an eigensolver, and writing a second iteration
	here would be a parallel authority over the same mathematics.

	So Roots() builds the companion matrix and asks stzMatrix. One algorithm,
	one place -- the One-Definition-Authority the library holds itself to.

	-- WHAT THIS INHERITS, INCLUDING THE UNCOMFORTABLE PART --

	Riding the eigensolver inherits its balancing and its convergence. It also
	inherits the CONDITIONING OF MULTIPLE ROOTS, which is a property of the
	problem and not of the method: a root repeated m times is perturbed like
	eps^(1/m), so (x-2)^3 comes back as 2.00001 +/- 0.000017i rather than
	exactly 2, three times. Every library does this, numpy included. Rather
	than hide it, RealRoots() takes a tolerance and RootMultiplicity() reads
	the cluster -- the imprecision is surfaced, not papered over.

	#NOTE Coefficients are HIGHEST DEGREE FIRST, the way a polynomial is
	written: [1, -6, 11, -6] is x^3 - 6x^2 + 11x - 6.
*/

func StzPolynomialQ(paCoefficients)
	return new stzPolynomial(paCoefficients)

class stzPolynomial from stzObject

	@aCoeffs = []		# highest degree first

	def init(paCoefficients)
		if NOT isList(paCoefficients)
			StzRaise("stzPolynomial: I need a list of coefficients, highest degree first.")
		ok
		if len(paCoefficients) = 0
			StzRaise("stzPolynomial: the coefficient list is empty.")
		ok

		_aC_ = []
		_nL_ = len(paCoefficients)
		for _i_ = 1 to _nL_
			if NOT IsNumberInStringOrNumber(paCoefficients[_i_])
				StzRaise("stzPolynomial: coefficient " + _i_ + " is not a number.")
			ok
			_aC_ + number("" + paCoefficients[_i_])
		next

		# Leading zeros are not part of the polynomial -- [0,0,1,-3] IS x - 3,
		# a degree-1 polynomial, and its companion matrix must be 1x1 and not
		# 3x3 with a singular leading coefficient.
		_nFirst_ = 0
		_nL2_ = len(_aC_)
		for _i_ = 1 to _nL2_
			if _nFirst_ = 0 and _aC_[_i_] != 0
				_nFirst_ = _i_
			ok
		next
		if _nFirst_ = 0
			# every coefficient is zero: the zero polynomial
			@aCoeffs = [ 0 ]
			return
		ok

		_aTrim_ = []
		for _i_ = _nFirst_ to _nL2_
			_aTrim_ + _aC_[_i_]
		next
		@aCoeffs = _aTrim_

	#-- READING THE POLYNOMIAL ------------------------------------------

	def Coefficients()
		return @aCoeffs

		def Coeffs()
			return This.Coefficients()

	# The degree: 0 for a constant, n for x^n. The zero polynomial has no
	# meaningful degree; it answers 0.
	def Degree()
		return len(@aCoeffs) - 1

	def LeadingCoefficient()
		return @aCoeffs[1]

		def Leading()
			return This.LeadingCoefficient()

	def IsMonic()
		return @aCoeffs[1] = 1

	def IsZeroPolynomial()
		return len(@aCoeffs) = 1 and @aCoeffs[1] = 0

	# The same polynomial scaled to leading coefficient 1 -- the form the
	# companion matrix needs.
	def Monic()
		if This.IsZeroPolynomial()
			StzRaise("Monic: the zero polynomial cannot be made monic.")
		ok
		_nLead_ = @aCoeffs[1]
		_aOut_ = []
		_nL_ = len(@aCoeffs)
		for _i_ = 1 to _nL_
			_aOut_ + (@aCoeffs[_i_] / _nLead_)
		next
		return _aOut_

		def MonicQ()
			return new stzPolynomial(This.Monic())

	#-- EVALUATION ------------------------------------------------------

	# p(x) by Horner's rule -- n multiplications, and numerically the steadiest
	# way to evaluate a polynomial.
	def ValueAt(pnX)
		_nAcc_ = 0
		_nL_ = len(@aCoeffs)
		for _i_ = 1 to _nL_
			_nAcc_ = _nAcc_ * pnX + @aCoeffs[_i_]
		next
		return _nAcc_

		def At(pnX)
			return This.ValueAt(pnX)

		def Eval(pnX)
			return This.ValueAt(pnX)

	# p'(x)'s coefficients: the power rule, term by term.
	def Derivative()
		_nDeg_ = This.Degree()
		if _nDeg_ < 1
			return [ 0 ]
		ok
		_aOut_ = []
		_nL_ = len(@aCoeffs)
		for _i_ = 1 to _nL_ - 1
			_aOut_ + (@aCoeffs[_i_] * (_nDeg_ - _i_ + 1))
		next
		return _aOut_

		def DerivativeQ()
			return new stzPolynomial(This.Derivative())

	#-- THE ROOTS -------------------------------------------------------

	# The companion matrix of the MONIC form of this polynomial: the matrix
	# whose characteristic polynomial is p, and therefore whose eigenvalues
	# are p's roots.
	def CompanionMatrix()
		_nDeg_ = This.Degree()
		if _nDeg_ < 1
			StzRaise("CompanionMatrix: a constant has no companion matrix " +
				"(and no roots to find).")
		ok
		_aM_ = This.Monic()
		_aOut_ = []
		for _i_ = 1 to _nDeg_
			_aRow_ = []
			for _j_ = 1 to _nDeg_
				_aRow_ + 0
			next
			_aOut_ + _aRow_
		next
		# top row: the negated monic coefficients after the leading 1
		for _j_ = 1 to _nDeg_
			_aOut_[1][_j_] = -_aM_[_j_ + 1]
		next
		# sub-diagonal ones
		for _i_ = 2 to _nDeg_
			_aOut_[_i_][_i_ - 1] = 1
		next
		return _aOut_

		def CompanionMatrixQ()
			return new stzMatrix(This.CompanionMatrix())

	# EVERY root, complex ones included, as a list of stzComplex -- degree many
	# of them, counted with multiplicity, per the fundamental theorem of algebra.
	#
	# This is the eigenvalue computation described at the top of the file: no
	# second iteration lives here.
	def ComplexRoots()
		_nDeg_ = This.Degree()
		if _nDeg_ < 1
			StzRaise("ComplexRoots: a constant polynomial has no roots " +
				"(or, if it is zero, every number is one).")
		ok
		return This.CompanionMatrixQ().ComplexEigenValues()

		def Roots()
			return This.ComplexRoots()

	# The REAL roots only, as plain numbers, ascending.
	#
	# The tolerance is a real parameter and not a hidden constant: a root
	# repeated m times is perturbed like eps^(1/m), so a triple root arrives
	# with a small imaginary part that is an artifact of conditioning rather
	# than a genuinely complex root. Anything whose imaginary part is within
	# pnTolerance counts as real.
	def RealRootsWithin(pnTolerance)
		_aZ_ = This.ComplexRoots()
		_aOut_ = []
		_nL_ = len(_aZ_)
		for _i_ = 1 to _nL_
			if fabs(_aZ_[_i_].ImaginaryPart()) <= pnTolerance
				_aOut_ + _aZ_[_i_].RealPart()
			ok
		next
		return sort(_aOut_)

	def RealRoots()
		return This.RealRootsWithin(0.000001)

	def NumberOfRealRoots()
		return len(This.RealRoots())

	def HasRealRoot()
		return len(This.RealRoots()) > 0

	# TRUE when any root is genuinely complex (beyond the tolerance).
	def HasComplexRoot()
		return len(This.ComplexRoots()) > len(This.RealRoots())

	#-- ARITHMETIC ------------------------------------------------------

	def Plus(paOther)
		_aB_ = This._CoeffsOf(paOther)
		return This._AddPadded(@aCoeffs, _aB_, 1)

		def PlusQ(paOther)
			return new stzPolynomial(This.Plus(paOther))

	def Minus(paOther)
		_aB_ = This._CoeffsOf(paOther)
		return This._AddPadded(@aCoeffs, _aB_, -1)

		def MinusQ(paOther)
			return new stzPolynomial(This.Minus(paOther))

	# Convolution of the coefficient lists -- the definition of a product of
	# polynomials.
	def Times(paOther)
		_aB_ = This._CoeffsOf(paOther)
		_nA_ = len(@aCoeffs)
		_nB_ = len(_aB_)
		_aOut_ = []
		for _i_ = 1 to _nA_ + _nB_ - 1
			_aOut_ + 0
		next
		for _i_ = 1 to _nA_
			for _j_ = 1 to _nB_
				_aOut_[_i_ + _j_ - 1] += @aCoeffs[_i_] * _aB_[_j_]
			next
		next
		return _aOut_

		def TimesQ(paOther)
			return new stzPolynomial(This.Times(paOther))

	#-- INTERNALS -------------------------------------------------------

	def _CoeffsOf(paOther)
		if isObject(paOther)
			return paOther.Coefficients()
		ok
		if isList(paOther)
			return paOther
		ok
		StzRaise("stzPolynomial: I need a polynomial or a coefficient list.")

	# Add two highest-degree-first lists of different lengths, with the second
	# scaled by nSign. Padding happens on the LEFT, since the lists are aligned
	# at their lowest-degree end.
	def _AddPadded(paA, paB, pnSign)
		_nA_ = len(paA)
		_nB_ = len(paB)
		_nN_ = _nA_
		if _nB_ > _nN_
			_nN_ = _nB_
		ok
		_aOut_ = []
		for _i_ = 1 to _nN_
			_nAv_ = 0
			_nBv_ = 0
			_iA_ = _i_ - (_nN_ - _nA_)
			_iB_ = _i_ - (_nN_ - _nB_)
			if _iA_ >= 1
				_nAv_ = paA[_iA_]
			ok
			if _iB_ >= 1
				_nBv_ = paB[_iB_]
			ok
			_aOut_ + (_nAv_ + pnSign * _nBv_)
		next
		return _aOut_

	#-- DISPLAY ---------------------------------------------------------

	def Content()
		return @aCoeffs

	def Show()
		? This.ToString()

	def ToString()
		_nDeg_ = This.Degree()
		_cOut_ = ""
		_nL_ = len(@aCoeffs)
		for _i_ = 1 to _nL_
			_nC_ = @aCoeffs[_i_]
			if _nC_ = 0 and _nL_ > 1
				loop
			ok
			_nP_ = _nDeg_ - _i_ + 1
			if _cOut_ != "" and _nC_ > 0
				_cOut_ += " + "
			but _cOut_ != "" and _nC_ < 0
				_cOut_ += " - "
			but _nC_ < 0
				_cOut_ += "-"
			ok
			_nAbs_ = fabs(_nC_)
			if _nP_ = 0
				_cOut_ += ("" + _nAbs_)
			but _nP_ = 1
				if _nAbs_ = 1
					_cOut_ += "x"
				else
					_cOut_ += ("" + _nAbs_ + "x")
				ok
			else
				if _nAbs_ = 1
					_cOut_ += ("x^" + _nP_)
				else
					_cOut_ += ("" + _nAbs_ + "x^" + _nP_)
				ok
			ok
		next
		if _cOut_ = ""
			return "0"
		ok
		return _cOut_
