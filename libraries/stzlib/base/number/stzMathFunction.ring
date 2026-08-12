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

class stzMathFunction from stzObject

	@cExpr = ""
	@acVars = []
	@pProg = ""

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

	def Expression()
		return @cExpr

	def Variables()
		return @acVars

	def NumberOfVariables()
		return len(@acVars)

	# the value alone -- no tape walk, which is what a line search wants
	def ValueAt(paPoint)
		This._CheckPoint(paPoint)
		return StzEngineGradValueAt(@pProg, paPoint)

	# the gradient: one entry per variable, in the order they were named
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

	# value and gradient together, because the backward pass computes both and
	# asking for them separately evaluates the expression twice
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

	# the partial derivative with respect to one named variable
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

	def Free()
		if @pProg != ""
			StzEngineGradFree(@pProg)
			@pProg = ""
		ok
