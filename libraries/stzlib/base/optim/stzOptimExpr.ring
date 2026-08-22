#=====================================================================#
#  STZOPTIMEXPR -- an expression becomes a LINEAR FORM, in the engine  #
#=====================================================================#
/*
	R4 step 5 (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.5). One job: turn
	"3*x + 2*y" into the coefficient vector the solver needs, and
	"x + y <= 50" into a coefficient vector, a relation and a
	right-hand side -- WITHOUT eval() and WITHOUT substring arithmetic.

	WHY THE GRADIENT, AND WHY IT IS EXACT. A linear form's gradient IS
	its coefficient vector, and it is constant everywhere. So one call to
	the engine's autodiff tape at the origin returns the whole thing:
	the value there is the constant term, and the partial derivatives are
	the coefficients. `4*x - 2*y + 7` answers [ 7, 4, -2 ], measured, not
	approximated -- autodiff is a tape, not a finite difference, so there
	is no step size to choose and no error to bound.

	THE DESIGN NAMED expr.zig FOR THIS AND expr.zig CANNOT DO IT, which
	is recorded here because a divergence found and not written down is a
	divergence the next reader pays for again. Measured 2026-08-22 from
	Ring, both directions:

	  - expr.zig (the W-DSL) has `<=` but NO NAMED VARIABLES. Its whole
	    variable vocabulary is @item, @i, @accumulator, @char,
	    @numberofitems and This[k]; a bare `x` is an error token and the
	    compile returns nothing. StzEngineListEvalColumnsDense with
	    "3*x + 2*y" returns an EMPTY list; the same call with
	    "3*This[1] + 2*This[2]" returns 5 at x=y=1.
	  - autodiff.zig has named variables and NO comparison operators.
	    StzEngineGradCompile("x + y <= 50", "x,y") is refused with
	    "there is a character the expression cannot use".

	So neither engine alone spans one constraint string, and the split is
	the answer rather than the obstacle: THIS FILE SPLITS THE RELATION,
	the engine compiles each side. Splitting on a relational operator is
	four string positions, not arithmetic -- it is the parsing that got
	stzCoeffExtractor into trouble that stays out of Ring, and that is
	what "retire the eval-based parsing" was actually asking for.
*/

#---------------------------------------------------------------------#
#  THE LINEAR FORM                                                     #
#---------------------------------------------------------------------#

# "3*x + 2*y" over [ "x", "y" ] -> [ :ok, :const, :coeffs, :why ]
# The constant is the value at the origin; the coefficients are the
# gradient there. Both come back from ONE engine call.
func StzLinearFormOf(pcExpr, pacVars)
	_cE_ = ring_trim("" + pcExpr)
	if _cE_ = ""
		return [ :ok = 0, :const = 0, :coeffs = [],
			 :why = "an empty expression states nothing" ]
	ok

	_n_ = len(pacVars)
	_cJoined_ = ""
	for _i_ = 1 to _n_
		if _i_ > 1
			_cJoined_ += ","
		ok
		_cJoined_ += "" + pacVars[_i_]
	next

	_oP_ = StzEngineGradCompile(_cE_, _cJoined_)
	if _oP_ = ""
		return [ :ok = 0, :const = 0, :coeffs = [],
			 :why = "the engine refused '" + _cE_ + "': " +
				StzEngineGradWhy() ]
	ok

	_aZero_ = []
	for _i_ = 1 to _n_
		_aZero_ + 0
	next

	_aR_ = StzEngineGradAt(_oP_, _aZero_)
	StzEngineGradFree(_oP_)

	# a length mismatch answers 0 rather than a list -- reported, never
	# read as an answer
	if NOT isList(_aR_)
		return [ :ok = 0, :const = 0, :coeffs = [],
			 :why = "the engine could not differentiate '" + _cE_ +
				"' over " + _n_ + " variable(s)" ]
	ok
	if len(_aR_) != (_n_ + 1)
		return [ :ok = 0, :const = 0, :coeffs = [],
			 :why = "the engine returned " + len(_aR_) +
				" value(s) for " + _n_ + " variable(s)" ]
	ok

	_aC_ = []
	for _i_ = 1 to _n_
		_aC_ + _aR_[_i_ + 1]
	next
	return [ :ok = 1, :const = _aR_[1], :coeffs = _aC_, :why = "" ]

#---------------------------------------------------------------------#
#  THE RELATION                                                        #
#---------------------------------------------------------------------#

# The three operators, longest first: "<=" must be tried before "=",
# or "x + y <= 50" splits at the "=" and both sides are nonsense.
func StzOptimRelationAt(pcText)
	_c_ = "" + pcText
	_n_ = StzFind("<=", _c_)
	if len(_n_) > 0
		return [ :at = _n_[1], :len = 2, :op = -1 ]
	ok
	_n_ = StzFind(">=", _c_)
	if len(_n_) > 0
		return [ :at = _n_[1], :len = 2, :op = 1 ]
	ok
	# "=<" and "=>" are accepted spellings: a reader who writes one means
	# the same thing, and refusing it teaches nothing
	_n_ = StzFind("=<", _c_)
	if len(_n_) > 0
		return [ :at = _n_[1], :len = 2, :op = -1 ]
	ok
	_n_ = StzFind("=>", _c_)
	if len(_n_) > 0
		return [ :at = _n_[1], :len = 2, :op = 1 ]
	ok
	_n_ = StzFind("=", _c_)
	if len(_n_) > 0
		return [ :at = _n_[1], :len = 1, :op = 0 ]
	ok
	return [ :at = 0, :len = 0, :op = 0 ]

# "x + y <= 50" over [ "x", "y" ]
#   -> [ :ok, :coeffs, :op, :rhs, :why ]
# Both sides are compiled and SUBTRACTED, so "2*x + 3 <= y + 10" is read
# exactly as "2*x - y <= 7" without any term-shuffling in Ring.
func StzLinearConstraintOf(pcText, pacVars)
	_c_ = ring_trim("" + pcText)
	_aRel_ = StzOptimRelationAt(_c_)
	if _aRel_[:at] = 0
		return [ :ok = 0, :coeffs = [], :op = 0, :rhs = 0,
			 :why = "'" + _c_ + "' states no relation -- a constraint " +
				"needs one of <=, >= or =" ]
	ok

	_cL_ = ring_trim(StzLeft(_c_, _aRel_[:at] - 1))
	_cR_ = ring_trim(StzMid(_c_, _aRel_[:at] + _aRel_[:len],
		StzLen(_c_) - _aRel_[:at] - _aRel_[:len] + 1))

	_aL_ = StzLinearFormOf(_cL_, pacVars)
	if _aL_[:ok] = 0
		return [ :ok = 0, :coeffs = [], :op = 0, :rhs = 0, :why = _aL_[:why] ]
	ok
	_aR_ = StzLinearFormOf(_cR_, pacVars)
	if _aR_[:ok] = 0
		return [ :ok = 0, :coeffs = [], :op = 0, :rhs = 0, :why = _aR_[:why] ]
	ok

	_n_ = len(pacVars)
	_aC_ = []
	for _i_ = 1 to _n_
		_aC_ + (_aL_[:coeffs][_i_] - _aR_[:coeffs][_i_])
	next
	return [ :ok = 1, :coeffs = _aC_, :op = _aRel_[:op],
		 :rhs = (_aR_[:const] - _aL_[:const]), :why = "" ]

# the operator as it reads in a narration
func StzOptimOpWord(pnOp)
	if pnOp = -1
		return "<="
	but pnOp = 1
		return ">="
	ok
	return "="
