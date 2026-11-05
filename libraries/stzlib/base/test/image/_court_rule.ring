# The court's rule, restated INDEPENDENTLY for the image guards (SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md section 8; the default gate since
# 2026-11-05). A guard asserts that the registry chose what this file says the rule chooses. Two things here are computed apart from the
# registry, so the assertion is a check and not an identity: the tail probability is an exact sum of binomial coefficients in Ring (the
# registry asks the engine's incomplete beta), and the choice is made by this file's own walk (incumbent, floor, score order). Only the
# counts are read from the registry, because they are the evidence both must judge.
#
#   CourtRuleChoice(cFaculty, cGolden)   -> the implementation the rule chooses: the best-scoring one that is upheld against the incumbent
#                                           and the floor (the incumbent needs only the floor); the floor when none is
#   CourtTail(nGains, nLosses)           -> P(X >= gains | gains + losses, 1/2), exactly

func CourtTail(nG, nL)
	n = nG + nL
	if nG <= 0  return 1 ok
	if nG > n  return 0 ok
	# C(n, k) / 2^n summed for k = gains .. n, term by term (each term from the last: C(n, k+1) = C(n, k) (n - k) / (k + 1))
	t = 1
	for i = 1 to n  t = t / 2  next
	c = t
	for k = 0 to nG - 1
		c = c * (n - k) / (k + 1)
	next
	s = 0
	for k = nG to n
		s += c
		c = c * (n - k) / (k + 1)
	next
	return s

func CourtUpheld(cF, cGolden, cA, cB)
	a = StzCourtVerdictOf(cF, cGolden, cA, cB)
	if len(a) = 0  return 0 ok
	if a[:gains] <= a[:losses]  return 0 ok
	if CourtTail(a[:gains], a[:losses]) <= 0.05  return 1 ok
	return 0

func CourtRuleChoice(cF, cGolden)
	oF = StzFacultyQ(cF)
	a = oF.Implementations()
	cFloor = ""
	aCand = []
	for i = 1 to len(a)
		if a[i][:kind] = "floor"
			cFloor = a[i][:id]
		else
			m = StzMeasurementOf(cF, a[i][:id], cGolden)
			if len(m) > 0 and StzImplementationIsInstalled(a[i]) = 1 and a[i][:kind] != "service"
				if m[:conformance] >= 1  aCand + [ a[i][:id], m[:score] ] ok
			ok
		ok
	next
	mF = StzMeasurementOf(cF, cFloor, cGolden)
	if len(mF) = 0  return cFloor ok
	cInc = StzCourtIncumbent(cF, cGolden)
	if cInc = ""  cInc = cFloor ok
	cBest = cFloor
	nBest = -1
	for i = 1 to len(aCand)
		cId = aCand[i][1]
		if aCand[i][2] <= mF[:score]  loop ok
		if CourtUpheld(cF, cGolden, cId, cFloor) = 0  loop ok
		if cId != cInc and cInc != cFloor
			if CourtUpheld(cF, cGolden, cId, cInc) = 0  loop ok
		ok
		if aCand[i][2] > nBest
			nBest = aCand[i][2]
			cBest = cId
		ok
	next
	return cBest
