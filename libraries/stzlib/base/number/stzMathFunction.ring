# stzMathFunction -- a function of named variables that knows its own derivatives
# (numeric phase 6, slice 1).
#
#   oF = new stzMathFunction("x^2 + 3*x*y", [ "x", "y" ])
#   ? oF.ValueAt([ 2, 3 ])         #--> 22
#   ? oF.GradientAt([ 2, 3 ])      #--> [ 13, 6 ]
#   ? oF.DerivativeAt("x", [2,3])  #--> 13
#
# WHAT THIS IS, AND WHY IT IS NOT FINITE DIFFERENCES. The gradient comes from
# REVERSE-MODE AUTOMATIC DIFFERENTIATION in the engine: the expression is compiled
# to a tape, evaluated forwards, then walked backwards carrying an adjoint. That
# gives the derivative with respect to EVERY variable from one backward pass, and
# gives it exactly -- not to within a step size. Finite differences would need n+1
# evaluations for n variables and would still be approximate, with an error that
# gets worse as the step shrinks and rounding takes over.
#
# WHAT IT IS FOR. Optimisation. An objective the library has never seen can now be
# handed to it with its gradients available, which is what L-BFGS and every other
# gradient method needs. It is also the honest way to check a hand-derived gradient
# -- the trainer's backprop was verified against this rather than against a step
# size.
#
# THE SYNTAX IS THE INFIX SYNTAX you would write anyway: + - * / ^ with the usual
# precedence, ^ right-associative, parentheses, and the functions exp, log (= ln),
# sqrt, sin, cos, tan, tanh, abs, min, max, pow. `pi` and `e` are constants, not
# variables. Names match case-insensitively, as Ring itself does.
#
# It is NOT the W() expression language, and the reason is worth stating: W() is a
# predicate DSL for filtering lists -- its variable is "the current item", and its
# vocabulary is IsVowel, StartsWith, Replace. It has no exp, no log, no named
# variables, and four fifths of it is not differentiable. Sharing the infix syntax
# without sharing the domain is the honest arrangement.

# Holds a formula of named variables and gives its value and its exact derivatives at any point, by automatic differentiation.
#
# Build one with new stzMathFunction("x^2 + 3*x*y", [ "x", "y" ]). The engine compiles the formula
# once and walks it backwards to get the derivative with respect to every variable in one pass,
# exactly and not within a step size, which is what an optimiser or a check of a hand-derived
# gradient needs. The syntax is infix: + - * / ^ (right-associative), parentheses, exp, log, sqrt,
# sin, cos, tan, tanh, abs, min, max, pow, and the constants pi and e. A point is a list with one
# value per variable, in declared order. This is not the W() expression language of lists. Call Free
# when done with it.
#
#   receiver   o1 = new stzMathFunction("x^2 + 3*x*y", [ "x", "y" ])
#   example    ? o1.ValueAt([ 2, 3 ])
#              #--> 22
#              ? @@( o1.GradientAt([ 2, 3 ]) )
#              #--> [ 13, 6 ]
#              ? o1.DerivativeAt("y", [ 2, 3 ])
#              #--> 6
#   see        stzObjective, stzNumber
class stzMathFunction from stzObject

	@cExpr = ""
	@acVars = []
	@pProg = ""

	# Compiles a formula of named variables, such as "x^2 + 3*x*y", so its value and exact derivatives can be asked at any point.
	#
	#   pcExpression   the formula as text, with + - * / ^ , parentheses and the functions exp, log,
	#                  sqrt, sin, cos, tan, tanh, abs, min, max, pow, and the constants pi and e
	#   pacVariables   the names of the variables, in the order points will be given
	#   returns        nothing; the object is built
	#   warning        an empty formula, an empty variable list, a formula with a character it
	#                  cannot use, or a name that is not a listed variable raises an error saying
	#                  why
	#   see            ValueAt, GradientAt
	def init(pcExpression, pacVariables)
		if NOT isString(pcExpression) or ring_trim(pcExpression) = ""
			stzraise("Give me an expression to differentiate.")
		ok
		if NOT isList(pacVariables) or len(pacVariables) = 0
			stzraise("Name the variables, as in: new stzMathFunction('x^2', [ 'x' ]).")
		ok

		@cExpr = pcExpression
		@acVars = []
		_cJoined_ = ""
		_n_ = len(pacVariables)
		for _i_ = 1 to _n_
			_cV_ = ring_trim("" + pacVariables[_i_])
			if _cV_ = ""
				stzraise("Variable " + _i_ + " has no name.")
			ok
			@acVars + _cV_
			if _cJoined_ != ""
				_cJoined_ += ","
			ok
			_cJoined_ += _cV_
		next

		@pProg = StzEngineGradCompile(@cExpr, _cJoined_)
		if @pProg = ""
			# the REASON, not just a refusal -- see the note in the bridge
			stzraise("Can't read '" + @cExpr + "': " + StzEngineGradWhy() + ".")
		ok

	# Returns the formula text as it was given.
	#
	#   returns    a text
	#   see        Variables
	def Expression()
		return @cExpr

	# Returns the variable names in the order they were declared, which is the order of every point and gradient.
	#
	#   returns    a list of texts
	#   see        NumberOfVariables
	def Variables()
		return @acVars

	# Returns how many variables the formula has.
	#
	#   returns    a number
	#   see        Variables
	def NumberOfVariables()
		return len(@acVars)

	# Returns the value of the formula at a point, without computing derivatives.
	#
	#   paPoint    the values of the variables, one per variable in declared order, such as [ 2, 3 ]
	#   returns    a number
	#   note       "x^2 + 3*x*y" at [ 2, 3 ] is 22
	#   warning    a point with the wrong number of values raises "This function has 2 variable(s);
	#              the point has 1."; a point outside the domain gives inf, -inf or nan, not an
	#              error; after Free it answers 0
	#   see        GradientAt, ValueAndGradientAt
	#@ aka  the value alone -- no tape walk, which is what a line search wants
	def ValueAt(paPoint)
		This._CheckPoint(paPoint)
		return StzEngineGradValueAt(@pProg, paPoint)

	# Returns the exact partial derivatives at a point, one per variable in declared order, by reverse-mode automatic differentiation.
	#
	#   paPoint    the values of the variables, one per variable in declared order
	#   returns    a list of numbers
	#   note       not a finite difference: the derivatives are exact; at [ 2, 3 ] the gradient of
	#              x^2 + 3*x*y is [ 13, 6 ]
	#   see        DerivativeAt, ValueAndGradientAt
	#@ aka  the gradient: one entry per variable, in the order they were named
	def GradientAt(paPoint)
		This._CheckPoint(paPoint)
		_a_ = StzEngineGradAt(@pProg, paPoint)
		if NOT isList(_a_) or len(_a_) != len(@acVars) + 1
			stzraise("The engine refused the point.")
		ok
		_aG_ = []
		for _i_ = 2 to len(_a_)
			_aG_ + _a_[_i_]
		next
		return _aG_

	# Returns the value and the gradient at a point from one backward pass, cheaper than asking for each.
	#
	#   paPoint    the values of the variables, one per variable in declared order
	#   returns    a hash list [ :value = number, :gradient = list of numbers ]
	#   see        ValueAt, GradientAt
	#@ aka  value and gradient together, because the backward pass computes both and asking for them separately evaluates the expression twice
	def ValueAndGradientAt(paPoint)
		This._CheckPoint(paPoint)
		_a_ = StzEngineGradAt(@pProg, paPoint)
		if NOT isList(_a_) or len(_a_) != len(@acVars) + 1
			stzraise("The engine refused the point.")
		ok
		_aG_ = []
		for _i_ = 2 to len(_a_)
			_aG_ + _a_[_i_]
		next
		return [ :value = _a_[1], :gradient = _aG_ ]

	# Returns the partial derivative with respect to one named variable at a point.
	#
	#   pcVar      the name of the variable, in any case
	#   paPoint    the values of all the variables, in declared order
	#   returns    a number
	#   note       a name that is not a variable raises an error listing the variables
	#   see        GradientAt
	#@ aka  the partial derivative with respect to one named variable
	def DerivativeAt(pcVar, paPoint)
		_nAt_ = 0
		_n_ = len(@acVars)
		for _i_ = 1 to _n_
			if StzLower(@acVars[_i_]) = StzLower("" + pcVar)
				_nAt_ = _i_
				exit
			ok
		next
		if _nAt_ = 0
			stzraise("'" + pcVar + "' is not one of this function's variables (" +
				@@(@acVars) + ").")
		ok
		return This.GradientAt(paPoint)[_nAt_]

	def _CheckPoint(paPoint)
		if NOT isList(paPoint) or len(paPoint) != len(@acVars)
			stzraise("This function has " + len(@acVars) + " variable(s); " +
				"the point has " + len(paPoint) + ".")
		ok

	# the compiled tape, for stzObjective -- which minimises this function and so
	# needs the engine to evaluate it without a Ring round trip per line-search step
	def _Program()
		return @pProg

	# Releases the compiled formula held by the engine, which Ring cannot do by itself.
	#
	#   returns    nothing
	#   note       after it the object answers 0 to ValueAt instead of raising: do not use it again
	#   see        init
	def Free()
		if @pProg != ""
			StzEngineGradFree(@pProg)
			@pProg = ""
		ok
