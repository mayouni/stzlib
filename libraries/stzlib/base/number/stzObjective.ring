# stzObjective -- a function you want made as small as possible, and the machinery
# to do it (numeric phase 6, slice 2).
#
#   oO = new stzObjective("(x-1)^2 + (y-2)^2", [ "x", "y" ])
#   aR = oO.MinimizeFrom([ -5, 8 ])
#   ? aR[:point]        #--> [ 1, 2 ]
#   ? aR[:value]        #--> 0
#   ? aR[:why]          #--> "the gradient reached zero ..."
#
# AN OBJECTIVE IS A MATH FUNCTION PLUS A DIRECTION. stzMathFunction knows how to
# evaluate and differentiate; this knows what to DO with that -- find the point where
# the function is smallest. Maximising is minimising the negative, which MaximizeFrom
# does for you rather than making you rewrite the expression.
#
# THE METHOD IS L-BFGS, and the short version of why: Newton's method needs the
# matrix of second derivatives -- n-squared numbers and a linear solve every step.
# BFGS builds an approximation to its inverse out of successive gradients, still
# n-squared. L-BFGS never forms the matrix at all; it remembers the last few (step,
# gradient-change) pairs and reconstructs what the matrix would have DONE to a vector.
# Memory goes from n-squared to about seven times n, which is the difference between
# megabytes and kilobytes at a thousand variables.
#
# WHY NOT JUST GRADIENT DESCENT. On a well-scaled bowl it is fine. On anything
# stretched it is not: the guard for this class minimises a function whose curvature
# differs by a factor of a million between its two directions, and L-BFGS finds the
# bottom in under fifty iterations where gradient descent would still be zig-zagging
# down the walls after thousands.
#
# WHAT IT NEEDS FROM YOU. A smooth function. There is no constraint handling here --
# for linear constraints the library has a simplex (stzLinearSolver), and that is a
# different problem with a different method, not a worse version of this one.

# Finds where a formula of named variables is smallest or largest, starting from a point, and reports how the search ended.
#
# Build one with new stzObjective("(x-1)^2 + (y-2)^2", [ "x", "y" ]). The search is L-BFGS on the
# exact gradient of the formula, with no constraints; for linear constraints use stzLinearSolver.
# MinimizeFrom and MaximizeFrom answer a record, not a bare point, because a bare point cannot say
# it did not converge: read :status and :why, and :evaluations for the real cost. The result is a
# local extremum, so different starts can end at different points. SetMaxIterations and
# SetGradientTolerance tune the stop. Status words are lowercase: converged, settled, maxiterations,
# linesearchfailed, notfinite.
#
#   receiver   o1 = new stzObjective("(x-1)^2 + (y-2)^2", [ "x", "y" ])
#   example    aR = o1.MinimizeFrom([ -5, 8 ])
#              ? @@( aR[:point] )
#              #--> [ 1, 2 ]
#              ? aR[:status]
#              #--> converged
#              ? o1.ValueAt([ 0, 0 ])
#              #--> 5
#   see        stzMathFunction, stzLinearSolver
class stzObjective from stzObject

	@oFunc = ""
	@cSense = "minimum"
	@nMaxIterations = 500
	@nGradientTolerance = 0

	# Builds an objective from a formula of named variables, such as "(x-1)^2 + (y-2)^2", to be minimised or maximised.
	#
	#   pcExpression   the formula as text, in the syntax of stzMathFunction
	#   pacVariables   the names of its variables, in the order points will be given
	#   returns        nothing; the object is built
	#   warning        the formula is compiled at once, so a bad formula or variable list raises the
	#                  error of stzMathFunction here
	#   see            MinimizeFrom, MaximizeFrom
	def init(pcExpression, pacVariables)
		@oFunc = new stzMathFunction(pcExpression, pacVariables)

	# Returns the formula text as it was given.
	#
	#   returns    a text
	#   see        Variables
	def Expression()
		return @oFunc.Expression()

	# Returns the variable names in declared order, which is the order of every point.
	#
	#   returns    a list of texts
	#   see        Expression
	def Variables()
		return @oFunc.Variables()

	# Returns the stzMathFunction that holds the compiled formula, to ask its derivatives directly.
	#
	#   returns    a stzMathFunction
	#   note       there is no plain form because it would return an object; the Q is the name
	#   see        ValueAt, GradientAt
	#@ aka  NOT `Function()`: Ring accepts `function` as a synonym for `func`, so a method by that name is a C6 "Error in function name" at load time. Same family as naming a variable `oR`, which folds onto the `or` keyword. an OBJECT accessor, so it is Q-only -- a plain twin would return an object, which is exactly what the plain form must never do
	def MathFunctionQ()
		return @oFunc

	# Returns the value of the formula at a point.
	#
	#   paPoint    the values of the variables, one per variable in declared order
	#   returns    a number
	#   note       the same as stzMathFunction.ValueAt; a point of the wrong length raises an error
	#   see        GradientAt, MinimizeFrom
	def ValueAt(paPoint)
		return @oFunc.ValueAt(paPoint)

	# Returns the exact partial derivatives of the formula at a point, one per variable.
	#
	#   paPoint    the values of the variables, one per variable in declared order
	#   returns    a list of numbers
	#   see        ValueAt
	def GradientAt(paPoint)
		return @oFunc.GradientAt(paPoint)

	# Sets how many iterations the search may take before it gives up; the default is 500.
	#
	#   n          the limit, a number above 0
	#   returns    nothing; use SetMaxIterationsQ to chain
	#   note       a value of 0 or less is ignored without a message and the limit stays as it was
	#   see        SetGradientTolerance, MinimizeFrom
	def SetMaxIterations(n)
		if n > 0
			@nMaxIterations = n
		ok

		def SetMaxIterationsQ(n)
			This.SetMaxIterations(n)
			return This

	# Sets how small the gradient must become for the search to call itself done; unset, the engine's default applies.
	#
	#   n          the tolerance, a number above 0
	#   returns    nothing; use SetGradientToleranceQ to chain
	#   note       a value of 0 or less is ignored without a message; a large tolerance stops the
	#              search early, away from the minimum
	#   see        SetMaxIterations
	#@ aka  How small the gradient must get before the search calls it done. Left at the engine's default when unset, rather than guessed at here.
	def SetGradientTolerance(n)
		if n > 0
			@nGradientTolerance = n
		ok

		def SetGradientToleranceQ(n)
			This.SetGradientTolerance(n)
			return This

	# Searches downhill from a starting point with L-BFGS and returns the point it reached with a record of how the search ended.
	#
	#   paStart    the starting values of the variables, one per variable in declared order
	#   returns    a hash list with :point, :value, :status, :iterations, :evaluations,
	#              :gradientNorm and :why
	#   note       check :status, which is "converged", "settled", "maxiterations",
	#              "linesearchfailed" or "notfinite" (lowercase, since Ring folds the case of
	#              symbols): a point is returned even when the search did not converge; it finds a
	#              local minimum, so the start matters
	#   see        MaximizeFrom, SetMaxIterations
	#@ aka  THE ANSWER IS A RECORD, NOT A POINT, for the same reason the hypothesis tests return one: a bare answer cannot tell you it did not converge. :status says how it stopped, :evaluations is the honest cost (an iteration that line-searched twelve times is not one unit of work), and :why says it in words.
	def MinimizeFrom(paStart)
		if NOT isList(paStart) or len(paStart) != len(@oFunc.Variables())
			stzraise("This objective has " + len(@oFunc.Variables()) +
				" variable(s); the starting point has " + len(paStart) + ".")
		ok

		_a_ = StzEngineMinimize(@oFunc._Program(), paStart,
			@nMaxIterations, @nGradientTolerance)
		if NOT isList(_a_) or len(_a_) < 5
			stzraise("The engine refused the minimisation.")
		ok

		_aPoint_ = []
		for _i_ = 6 to len(_a_)
			_aPoint_ + _a_[_i_]
		next

		_nSt_ = _a_[1]
		_cStatus_ = :maxIterations
		_cWhy_ = "it ran out of iterations before the gradient got small"
		if _nSt_ = 0
			_cStatus_ = :converged
			_cWhy_ = "the gradient reached zero, which is what a minimum looks like"
		but _nSt_ = 1
			_cStatus_ = :settled
			_cWhy_ = "the value stopped changing -- flat here, or as close as f64 gets"
		but _nSt_ = 3
			_cStatus_ = :lineSearchFailed
			_cWhy_ = "no step along the search direction improved the value; " +
				"the function may not be smooth here"
		but _nSt_ = 4
			_cStatus_ = :notFinite
			_cWhy_ = "the function was not a finite number at the starting point"
		ok

		return [
			:point = _aPoint_,
			:value = _a_[2],
			:status = _cStatus_,
			:iterations = _a_[3],
			:evaluations = _a_[4],
			:gradientNorm = _a_[5],
			:why = _cWhy_
		]

	# Searches uphill from a starting point and returns the record of MinimizeFrom, holding the formula's own value, not its negative.
	#
	#   paStart    the starting values of the variables, one per variable in declared order
	#   returns    a hash list with :point, :value, :status, :iterations, :evaluations,
	#              :gradientNorm and :why
	#   note       a formula with no maximum ends with :status "linesearchfailed": maximising
	#              (x-1)^2 + (y-2)^2 from [ 0, 0 ] returns the start
	#   see        MinimizeFrom
	#@ aka  THE LARGEST value, by minimising the negative. Doing it here rather than telling you to rewrite the expression is the point: -f has the same maximiser as f has minimiser, but the VALUE comes back negated, and forgetting to flip it back is the obvious way to get this wrong.
	def MaximizeFrom(paStart)
		_oNeg_ = new stzObjective("-(" + @oFunc.Expression() + ")", @oFunc.Variables())
		_oNeg_.SetMaxIterations(@nMaxIterations)
		if @nGradientTolerance > 0
			_oNeg_.SetGradientTolerance(@nGradientTolerance)
		ok
		_a_ = _oNeg_.MinimizeFrom(paStart)
		_a_[:value] = -_a_[:value]
		return _a_
