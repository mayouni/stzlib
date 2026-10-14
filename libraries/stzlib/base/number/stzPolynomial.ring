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

# Holds a polynomial in one variable, evaluates and differentiates it, adds and multiplies, and finds its real and complex roots.
#
# Coefficients are written highest degree first, the way the polynomial is written: [1, -6, 11, -6]
# is x^3 - 6x^2 + 11x - 6, and leading zeros are dropped. The roots are the eigenvalues of the
# companion matrix, computed by the engine, so a root repeated m times comes back as a small cluster
# rather than exactly (the tolerance of RealRoots and RealRootsWithin is how that is surfaced).
# Plus, Minus, Times and the Derivative return coefficient lists and the Q forms return a new
# stzPolynomial; none of them changes the object. Checked by hand: x^3 - 6x^2 + 11x - 6 has the
# roots 1, 2, 3, value 6 at 4, derivative 3x^2 - 12x + 11 and, times x - 1, the product x^4 - 7x^3 +
# 17x^2 - 17x + 6; x^2 + 1 has the roots i and -i.
#
#   receiver   o1 = new stzPolynomial([ 1, -6, 11, -6 ])
#   example    ? o1.ToString()
#              #--> x^3 - 6x^2 + 11x - 6
#              ? o1.ValueAt(4)
#              #--> 6
#              ? @@( o1.Derivative() )
#              #--> [ 3, -12, 11 ]
#              ? @@( o1.Times([ 1, -1 ]) )
#              #--> [ 1, -7, 17, -17, 6 ]
#              ? @@( o1.RealRoots() )
#              #--> [ 1.00, 2.00, 3.00 ]
#              o2 = new stzPolynomial([ 1, 0, 1 ])
#              ? o2.HasRealRoot()
#              #--> 0
#   see        stzComplex, stzMatrix, stzFourier
class stzPolynomial from stzObject

	@aCoeffs = []		# highest degree first

	# Builds a polynomial in one variable from its coefficients, highest degree first, dropping leading zeros.
	#
	#   paCoefficients   the coefficient list, highest degree first, numbers or numbers written as
	#                    text
	#   returns          nothing; the object is built
	#   note             [1, -6, 11, -6] is x^3 - 6x^2 + 11x - 6; [0, 0, 1, -3] is x - 3; all zeros
	#                    give the zero polynomial [ 0 ]; build one with StzPolynomialQ(list)
	#   see              Coefficients, ValueAt
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

	# Returns the coefficients, highest degree first, with leading zeros removed.
	#
	#   returns    a list of numbers
	#   note       Coeffs is the same call; [0, 0, 1, -3] gives [ 1, -3 ]
	#   see        Degree, LeadingCoefficient
	#@ aka  -- READING THE POLYNOMIAL ------------------------------------------
	def Coefficients()
		return @aCoeffs

		def Coeffs()
			return This.Coefficients()

	# Returns the highest power of x with a non-zero coefficient.
	#
	#   returns    a number; 0 for a constant and for the zero polynomial
	#   note       x^3 - 6x^2 + 11x - 6 gives 3; the constant 5 gives 0
	#   see        Coefficients, IsZeroPolynomial
	#@ aka  The degree: 0 for a constant, n for x^n. The zero polynomial has no meaningful degree; it answers 0.
	def Degree()
		return len(@aCoeffs) - 1

	# Returns the coefficient of the highest power.
	#
	#   returns    a number
	#   note       Leading is the same call; 2x^2 - 8x + 8 gives 2
	#   see        IsMonic, Monic
	def LeadingCoefficient()
		return @aCoeffs[1]

		def Leading()
			return This.LeadingCoefficient()

	# TRUE if the leading coefficient is exactly 1.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       x^3 - 6x^2 + 11x - 6 gives 1; 2x^2 - 8x + 8 gives 0
	#   see        Monic, LeadingCoefficient
	def IsMonic()
		return @aCoeffs[1] = 1

	# TRUE if every coefficient is zero.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       [0, 0] gives 1; the constant 5 gives 0
	#   see        Degree
	def IsZeroPolynomial()
		return len(@aCoeffs) = 1 and @aCoeffs[1] = 0

	# Returns the coefficients divided by the leading one, so that the leading coefficient is 1.
	#
	#   returns    a list of numbers; the object is not changed
	#   note       MonicQ returns a stzPolynomial; 2x^2 - 8x + 8 gives [ 1, -4, 4 ]
	#   warning    the zero polynomial raises Monic: the zero polynomial cannot be made monic
	#   see        IsMonic, CompanionMatrix
	#@ aka  The same polynomial scaled to leading coefficient 1 -- the form the companion matrix needs.
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

	# Returns the value of the polynomial at a number, by Horner's rule.
	#
	#   pnX        the number to evaluate at
	#   returns    a number
	#   note       At and Eval are the same call; x^3 - 6x^2 + 11x - 6 gives 6 at 4, 0 at 1 and -6
	#              at 0
	#   see        Derivative, RealRoots
	#@ aka  -- EVALUATION ------------------------------------------------------
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

	# Returns the coefficients of the derivative, by the power rule.
	#
	#   returns    a list of numbers; [ 0 ] for a constant
	#   note       DerivativeQ returns a stzPolynomial; x^3 - 6x^2 + 11x - 6 gives [ 3, -12, 11 ]
	#   see        ValueAt, Degree
	#@ aka  p'(x)'s coefficients: the power rule, term by term.
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

	# Returns the companion matrix of the monic form, whose eigenvalues are the roots.
	#
	#   returns    a list of rows, each a list of numbers
	#   note       CompanionMatrixQ returns a stzMatrix; x^3 - 6x^2 + 11x - 6 gives [6, -11, 6], [1,
	#              0, 0], [0, 1, 0]; x^2 + 1 gives [0, -1], [1, 0]
	#   warning    a constant, of degree 0, raises CompanionMatrix: this needs a polynomial of
	#              degree 1 or more
	#   see        ComplexRoots, Monic
	#@ aka  -- THE ROOTS -------------------------------------------------------
	def CompanionMatrix()
		_aR_ = StzEnginePolyCompanion(@aCoeffs)
		if NOT isList(_aR_) or len(_aR_) < 1
			StzRaise("CompanionMatrix: this needs a polynomial of degree 1 or more.")
		ok
		_n_ = _aR_[1]
		_aM_ = []
		for _i_ = 1 to _n_
			_aRow_ = []
			for _j_ = 1 to _n_
				_aRow_ + _aR_[1 + (_i_ - 1) * _n_ + _j_]
			next
			_aM_ + _aRow_
		next
		return _aM_

		def CompanionMatrixQ()
			return new stzMatrix(This.CompanionMatrix())

	# Returns every root, real or complex, as a list of stzComplex, found as the eigenvalues of the companion matrix.
	#
	#   returns    a list of stzComplex, one per degree; [ ] for a constant or the zero polynomial
	#   note       Roots is the same call; x^2 + 1 gives i and -i, x^2 + 2x + 5 gives -1 plus or
	#              minus 2i
	#   warning    a root repeated m times comes back as a cluster of nearby roots, not exactly:
	#              (x-2)^3 gives 2.00001 plus or minus 0.0000166i and 1.99998
	#   see        RealRoots, CompanionMatrix
	#@ aka  EVERY ROOT, complex ones included, as a list of stzComplex.
	def ComplexRoots()
		_aR_ = StzEnginePolyRoots(@aCoeffs)
		if NOT isList(_aR_)
			StzRaise("Roots: the QR iteration did not converge on this polynomial.")
		ok
		_aOut_ = []
		_n_ = len(_aR_) / 2
		for _i_ = 1 to _n_
			_aOut_ + new stzComplex(_aR_[(_i_ - 1) * 2 + 1], _aR_[(_i_ - 1) * 2 + 2])
		next
		return _aOut_

		def Roots()
			return This.ComplexRoots()

	# Returns the real roots in ascending order, counting a root as real when its imaginary part is at most a tolerance.
	#
	#   pnTolerance   the largest absolute imaginary part still counted as real
	#   returns       a list of numbers
	#   note          x^3 - 6x^2 + 11x - 6 gives 1, 2, 3 up to rounding
	#   warning       a repeated root only comes back whole with a loose tolerance: (x-2)^3 gives 2,
	#                 2, 2 with 0.001 and a single 2 with 0
	#   see           RealRoots, HasComplexRoot
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

	# Returns the real roots in ascending order, with a tolerance of 0.000001.
	#
	#   returns    a list of numbers; [ ] when all roots are complex
	#   note       x^3 - 6x^2 + 11x - 6 gives 1, 2, 3; x^2 + 1 gives [ ]; 2x^2 - 8x + 8 gives 2, 2;
	#              x^6 - 1 gives -1 and 1
	#   warning    a root repeated three times loses two of its copies, since their imaginary parts
	#              exceed the tolerance: (x-2)^3 gives a single 2
	#   see        RealRootsWithin, NumberOfRealRoots
	def RealRoots()
		return This.RealRootsWithin(0.000001)

	# Returns how many real roots there are, counted with the tolerance of RealRoots.
	#
	#   returns    a number
	#   note       x^3 - 6x^2 + 11x - 6 gives 3; x^2 + 1 gives 0
	#   see        RealRoots, HasRealRoot
	def NumberOfRealRoots()
		return len(This.RealRoots())

	# TRUE if the polynomial has at least one real root.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       x^2 + 1 gives 0; the constant 5 gives 0
	#   see        RealRoots
	def HasRealRoot()
		return len(This.RealRoots()) > 0

	# TRUE if the polynomial has more roots than real ones, so some root has a non-negligible imaginary part.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       x^2 + 1 gives 1; x^3 - 6x^2 + 11x - 6 gives 0
	#   warning    a real polynomial with a repeated real root can answer TRUE: (x-2)^3 gives 1
	#   see        ComplexRoots, HasRealRoot
	#@ aka  TRUE when any root is genuinely complex (beyond the tolerance).
	def HasComplexRoot()
		return len(This.ComplexRoots()) > len(This.RealRoots())

	# Returns the coefficients of the sum with another polynomial, aligned at the lowest degree.
	#
	#   paOther    a stzPolynomial or a coefficient list
	#   returns    a list of numbers; the object is not changed
	#   note       PlusQ returns a stzPolynomial and trims; adding [1, 1] gives [ 1, -6, 12, -5 ];
	#              adding x^2 + 1 gives [ 1, -5, 11, -5 ]
	#   warning    the result keeps leading zeros: x^3 - 6x^2 + 11x - 6 minus itself gives [ 0, 0,
	#              0, 0 ], which init would trim; any other value raises I need a polynomial or a
	#              coefficient list
	#   see        Minus, Times
	#@ aka  -- ARITHMETIC ------------------------------------------------------
	def Plus(paOther)
		_aB_ = This._CoeffsOf(paOther)
		return This._AddPadded(@aCoeffs, _aB_, 1)

		def PlusQ(paOther)
			return new stzPolynomial(This.Plus(paOther))

	# Returns the coefficients of the difference with another polynomial, aligned at the lowest degree.
	#
	#   paOther    a stzPolynomial or a coefficient list
	#   returns    a list of numbers; the object is not changed
	#   note       MinusQ returns a stzPolynomial and trims; subtracting [1, 0, 0, 0] gives [ 0, -6,
	#              11, -6 ], written -6x^2 + 11x - 6 by MinusQ
	#   warning    the result keeps leading zeros, as Plus does
	#   see        Plus, Times
	def Minus(paOther)
		_aB_ = This._CoeffsOf(paOther)
		return This._AddPadded(@aCoeffs, _aB_, -1)

		def MinusQ(paOther)
			return new stzPolynomial(This.Minus(paOther))

	# Returns the coefficients of the product with another polynomial, by convolution.
	#
	#   paOther    a stzPolynomial or a coefficient list
	#   returns    a list of numbers; the object is not changed
	#   note       TimesQ returns a stzPolynomial; exact for whole coefficients; x^3 - 6x^2 + 11x -
	#              6 times x - 1 gives [ 1, -7, 17, -17, 6 ] and times x^2 + 1 gives [ 1, -6, 12,
	#              -12, 11, -6 ]; above 4096 coefficient pairs it switches to the transform
	#   see        TimesViaTransform, Plus
	#@ aka  Convolution of the coefficient lists -- the definition of a product of polynomials. MULTIPLICATION IS A CONVOLUTION, which is why this has two paths.
	def Times(paOther)
		_aB_ = This._CoeffsOf(paOther)
		_nA_ = len(@aCoeffs)
		_nB_ = len(_aB_)

		# the crossover: below this the double loop is ~n*m cheap multiplies with no
		# transform overhead at all, and exact besides
		if _nA_ * _nB_ > 4096
			return This._TimesViaTransform(_aB_)
		ok

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

	# Returns the same product by the frequency domain, so the two routes can be compared.
	#
	#   paOther    a stzPolynomial or a coefficient list
	#   returns    a list of numbers, which may carry rounding errors
	#   note       TimesViaTransformQ returns a stzPolynomial; x + 1 times 1, 2, 3 gives [ 1, 3, 5,
	#              3 ]
	#   see        Times
	#@ aka  The same product through the frequency domain -- exposed so the guard can compare the two routes on the SAME polynomials rather than having to grow one past the crossover to reach this code.
	def TimesViaTransform(paOther)
		return This._TimesViaTransform(This._CoeffsOf(paOther))

		def TimesViaTransformQ(paOther)
			return new stzPolynomial(This.TimesViaTransform(paOther))

	def _TimesViaTransform(paB)
		_oF_ = new stzFourier(@aCoeffs)
		return _oF_.ConvolvedWith(paB)

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

	# Returns the coefficients, highest degree first.
	#
	#   returns    a list of numbers
	#   see        Coefficients, ToString
	#@ aka  -- DISPLAY ---------------------------------------------------------
	def Content()
		return @aCoeffs

	# Prints the polynomial as text on the console.
	#
	#   returns    nothing; one line is printed
	#   note       x^3 - 6x^2 + 11x - 6 prints as that line
	#   see        ToString
	def Show()
		? This.ToString()

	# Returns the polynomial written in the usual form, such as x^2 - 3x + 2.
	#
	#   returns    a text; 0 for the zero polynomial
	#   note       zero terms are left out, a coefficient of 1 is not written, and signs sit between
	#              terms: -x^2 + 4, 0.50x^2 - 1.50x + 1 and x - 3
	#   see        Show, Coefficients
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
