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

class stzObjective from stzObject

	@oFunc = ""
	@cSense = "minimum"
	@nMaxIterations = 500
	@nGradientTolerance = 0

	def init(pcExpression, pacVariables)
		@oFunc = new stzMathFunction(pcExpression, pacVariables)

	def Expression()
		return @oFunc.Expression()

	def Variables()
		return @oFunc.Variables()

	# NOT `Function()`: Ring accepts `function` as a synonym for `func`, so a method
	# by that name is a C6 "Error in function name" at load time. Same family as
	# naming a variable `oR`, which folds onto the `or` keyword.
	# an OBJECT accessor, so it is Q-only -- a plain twin would return an object,
	# which is exactly what the plain form must never do
	def MathFunctionQ()
		return @oFunc

	def ValueAt(paPoint)
		return @oFunc.ValueAt(paPoint)

	def GradientAt(paPoint)
		return @oFunc.GradientAt(paPoint)

	def SetMaxIterations(n)
		if n > 0
			@nMaxIterations = n
		ok

		def SetMaxIterationsQ(n)
			This.SetMaxIterations(n)
			return This

	# How small the gradient must get before the search calls it done. Left at the
	# engine's default when unset, rather than guessed at here.
	def SetGradientTolerance(n)
		if n > 0
			@nGradientTolerance = n
		ok

		def SetGradientToleranceQ(n)
			This.SetGradientTolerance(n)
			return This

	# THE ANSWER IS A RECORD, NOT A POINT, for the same reason the hypothesis tests
	# return one: a bare answer cannot tell you it did not converge. :status says how
	# it stopped, :evaluations is the honest cost (an iteration that line-searched
	# twelve times is not one unit of work), and :why says it in words.
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

	# THE LARGEST value, by minimising the negative. Doing it here rather than
	# telling you to rewrite the expression is the point: -f has the same maximiser
	# as f has minimiser, but the VALUE comes back negated, and forgetting to flip it
	# back is the obvious way to get this wrong.
	def MaximizeFrom(paStart)
		_oNeg_ = new stzObjective("-(" + @oFunc.Expression() + ")", @oFunc.Variables())
		_oNeg_.SetMaxIterations(@nMaxIterations)
		if @nGradientTolerance > 0
			_oNeg_.SetGradientTolerance(@nGradientTolerance)
		ok
		_a_ = _oNeg_.MinimizeFrom(paStart)
		_a_[:value] = -_a_[:value]
		return _a_
