load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 3 of the numeric foundation, second slice: resolving stzMatrix's DUAL
# REPRESENTATION -- the open question the plan named.
#
# stzMatrix held its values twice: @aContent (a Ring nested list) and
# @pEngineMatrix (an engine handle). Two copies of one matrix, and the rule for
# keeping them in step was "every method that writes the Ring side must remember to
# invalidate the engine side".
#
# SEVENTEEN OF THE TWENTY-THREE WRITERS DID NOT REMEMBER -- the whole Replace*
# family among them -- so:
#
#     o = new stzMatrix([[1,2],[3,4]])
#     o.Determinant()            -->  -2       and this builds the engine copy
#     o.ReplaceRow(1, [99,2])
#     o.Content()                -->  [[99,2],[3,4]]      the new matrix
#     o.Determinant()            -->  -2       THE OLD ONE. Should be 390.
#
# A silent wrong answer out of a cache nobody invalidated. Adding the seventeen
# missing calls would have fixed today and left the eighteenth method to reopen it,
# so the discipline is REMOVED rather than relied upon: the engine matrix is now a
# TRANSIENT, rebuilt from the Ring content whenever it is needed. Every call site
# was a one-shot engine operation anyway, so nothing was gaining from the cache.

Scenario("the Ring side and the engine side can no longer disagree")
	oM = new stzMatrix([ [1,2], [3,4] ])
	Then("the determinant is right to begin with", oM.Determinant(), -2)
	# ...and that call is what used to leave a stale engine copy behind.

	oM.ReplaceRow(1, [99, 2])
	Then("the content shows the change", @@(oM.Content()), "[ [ 99, 2 ], [ 3, 4 ] ]")
	Then("and the ENGINE agrees: 99*4 - 2*3", oM.Determinant(), 390)
EndScenario()

Scenario("...for every writer, not just the one that was noticed")
	# The audit that found this walked every method writing @aContent and asked
	# whether its body invalidates. Four representatives of the family:
	oRow = new stzMatrix([ [1,2], [3,4] ])
	nWarm = oRow.Determinant()
	oRow.ReplaceRow(1, [99, 2])
	Then("ReplaceRow", oRow.Determinant(), 390)

	oCol = new stzMatrix([ [1,2], [3,4] ])
	nWarm = oCol.Determinant()
	oCol.ReplaceCol(1, [99, 3])
	Then("ReplaceCol", oCol.Determinant(), 390)

	oAt = new stzMatrix([ [1,2], [3,4] ])
	nWarm = oAt.Determinant()
	oAt.ReplaceElementAt([1, 1], 99)
	Then("ReplaceElementAt", oAt.Determinant(), 390)

	oEl = new stzMatrix([ [1,2], [3,4] ])
	nWarm = oEl.Determinant()
	oEl.ReplaceElement(1, 99)
	Then("ReplaceElement", oEl.Determinant(), 390)
	# each of these used to answer -2.
EndScenario()

Scenario("the engine result still flows back to the Ring side")
	# The fix must not break the other direction: an operation performed IN the
	# engine has to leave the Ring content correct too.
	oT = new stzMatrix([ [1,2], [3,4] ])
	oT.Transpose()
	Then("a transpose lands in the content", @@(oT.Content()), "[ [ 1, 3 ], [ 2, 4 ] ]")

	oP = new stzMatrix([ [1,2], [3,4] ])
	oP.MultiplyByMatrix([ [1,0], [0,1] ])
	Then("multiplying by the identity is a no-op, both sides",
	     @@(oP.Content()), "[ [ 1, 2 ], [ 3, 4 ] ]")
	Then("...and the determinant follows", oP.Determinant(), -2)
EndScenario()

Scenario("what correctness by construction costs here: almost nothing")
	# Rebuilding is O(cells), and every consumer is a one-shot operation, so the
	# cache was saving a marshal that nobody was repeating. Measured: fifty
	# transposes of a 50x50 -- fifty rebuilds of 2500 cells -- take about 0.05s in
	# total, roughly a millisecond each.
	nD = 20
	aM = []
	for i = 1 to nD
		r = []
		for j = 1 to nD
			r + ((i * j) % 7 + 1)
		next
		aM + r
	next
	oBig = new stzMatrix(aM)
	nT0 = clock()
	for k = 1 to 20
		oBig.Transpose()
	next
	nT1 = clock()
	Then("twenty rebuild-and-transpose passes stay well under a second",
	     ((nT1 - nT0) / clockspersecond()) < 1, TRUE)
	Then("...and the matrix is intact afterwards", oBig.Rows(), nD)

	# A SEPARATE LIMIT, worth knowing and NOT introduced here: the engine's
	# determinant is naive cofactor expansion, which is O(n!) -- fine at 2x2, hard
	# work at 8x8, and impossible beyond about ten. The plan's phase 4 calls for LU
	# decomposition, which makes a determinant O(n^3); until then, Determinant() is
	# for small matrices.
EndScenario()

Summary()
