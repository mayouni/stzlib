load "../../stzBase.ring"
load "../_narrated.ring"
decimals(4)

# stzGeoProcess -- the two defects the documenting wave found, reproduced with real data and held shut.
# DOCREFORM follow-up, 2026-10-24. Run from inside test/geo:  ring stzGeoProcess_defects_narrated.ring
#
# The register listed two rows:
#   1. PatternIn raised for every kind. It passed the window's list of rings to StzGeoPoints, which wants
#      the stzGeoFeatures. Reproduced before the fix with Poisson on Niger and with SSI and MaternCluster on
#      the two-country fixture; each raised "the window is a stzGeoFeatures -- the region the points were
#      observed in". FIXED: it builds the pattern with poPoints.With(places), so the result carries the
#      SAME window and the places GenerateIn draws for the same seed.
#   2. ExpectedCount for an Inhomogeneous process answered the mean of ALL the grid values times the
#      window's area: 191.9 on Niger (the gallery surface, 28 x 22 nodes) against 152.5 drawn on average
#      over 60 seeds (149.4 in the register, with other seeds) and 152.2 integrated. THE ENGINE DOES NOT
#      DRAW THAT: geo_process.zig draws Poisson(lmax x window area) candidates uniformly in the WINDOW and
#      keeps each with lambda(x)/lmax, so the mean count is the window's area times the mean of the surface
#      OVER THE WINDOW, a surface read bilinearly, as 0 outside its grid. Two areas cannot name a window,
#      so the two-argument ExpectedCount now RAISES for this kind and tells the caller to use the new
#      ExpectedCountIn(poPoints), which integrates over the window. For every other kind it is unchanged.
#
# THE ORACLES ARE WRITTEN BEFORE THE CODE AND DO NOT CALL IT:
#   - the ramp (0 to 0.05 rising to the east): the mean over any window of a surface that depends on the
#     longitude alone is 0.025 over the stretch of longitude it spans, whatever the latitudes
#   - half coverage: a constant 0.01 surface over lon 0..1 under a window of lon 0..2 has half the window
#     under it, and the equal-area measure on the sphere is proportional to the longitude width
#   - a surface linear in latitude: integrated here by 20,000 slices of equal area (equal steps of
#     sin(latitude)), in this file, with no call into the library
#   - one unknown node in the middle of a constant surface: the four cells that touch it lose a quarter of
#     their value each, so the mean is 0.01 x (1 - 4/16 x 1/4) = 0.009375 (an unknown node reads as 0, which
#     was verified by drawing: 24.1 points per seed in the middle block where 23.1 are expected for 0 and
#     none for "no data")
#   - a triangle window under a surface that climbs with the longitude: the mean longitude of a triangle is
#     its centroid's, one third of the way along
#   - a constant surface under ANY window: its count is the constant times the window's area, hole or not
#   - MaternII's ceiling in its closed form (1 - exp(-t)) / (pi r2) per km2, written in this file
#   - the Poisson, MaternCluster and Thomas literals from the register: 177.5 for Poisson at 0.00015 per
#     km2 over Niger, 189.4 for a cluster process at 4e-6 parents of 40 children
#
# THE DRAWN MEANS ARE JUDGED BY THEIR OWN VARIANCE, over a FIXED set of 200 seeds so nothing flakes:
# five standard errors of a mean of 200, with the variance of a Poisson count (the mean) for Poisson,
# Inhomogeneous and MaternII, and of a compound Poisson count (parents x (m + m2)) for the cluster kinds.
#
# What each scenario holds:
#   1. PatternIn, all seven kinds   -> a stzGeoPoints, the same window, GenerateIn's places, seeded
#   2. PatternIn on the reported windows (Niger, two countries)
#   3. the old ExpectedCount        -> unchanged for the six other kinds; the literals
#   4. the old ExpectedCount        -> raises for Inhomogeneous, naming ExpectedCountIn
#   5. ExpectedCountIn, six kinds   -> the same literals on Niger, and the closed form for MaternII
#   6. ExpectedCountIn, inhomogeneous -> nine surfaces against their oracles AND against the draws
#   7. the six other kinds, drawn   -> the mean over 200 seeds agrees
#   8. bad arguments and degenerate windows
#
# Every positive has a negative sibling: a different seed, the OLD number shown to be wrong, a window
# that is not a window.

$cGpNiger = read("../graphics/niger_adm1.geojson")
$cGpTwo = read("../graphics/fixtures/two_countries.geojson")

oSq = GpWin(GpSquare(0, 0, 1, 1))
nSqA = oSq.AreaKm2()

# --- 1. PatternIn, all seven kinds ---------------------------------------------------------
Scenario("PatternIn returns the pattern of GenerateIn as a stzGeoPoints in the same window, for every kind")
	Given("the unit square at 0..1 E, 0..1 N (" + nSqA + " km2) and one process of each kind")
	aKinds = [ "Poisson", "Binomial", "Inhomogeneous", "MaternCluster", "Thomas", "MaternII", "SSI" ]
	for k = 1 to len(aKinds)
		oP = GpProc(aKinds[k])
		aFlat = oP.GenerateIn(oSq, 4101)
		oPat = oP.PatternIn(oSq, 4101)
		cK = aKinds[k]
		Then(cK + ": it returns a stzGeoPoints", classname(oPat), "stzgeopoints")
		Then(cK + ": it holds " + (len(aFlat) / 2) + " places, as many as GenerateIn drew", oPat.Count(), len(aFlat) / 2)
		Then(cK + ": and they are GenerateIn's places, one by one", GpSame(oPat.Points(), aFlat), 1)
		Then(cK + ": the window is the same: its area", oPat.AreaKm2(), nSqA)
		Then(cK + ": the window is the same: its box", GpSame(oPat.WindowBox(), oSq.WindowBox()), 1)
		Then(cK + ": the window is the same: its outer rings", GpSameRings(oPat.WindowRings(), oSq.WindowRings()), 1)
		Then(cK + ": no place falls outside the window", oPat.Outside(), 0)
		Then(cK + ": it is measurable at once: Clark-Evans answers a verdict", isString(oPat.ClarkEvans()[:verdict]), 1)
		Then(cK + ": and so does Ripley's K, one number per radius", len(oPat.RipleyK([ 5, 10, 20 ])), 3)
		Then(cK + ": the same seed gives the same pattern again", GpSame(oP.PatternIn(oSq, 4101).Points(), oPat.Points()), 1)
		Then(cK + ": NEGATIVE: another seed gives another pattern", GpSame(oP.PatternIn(oSq, 4102).Points(), oPat.Points()), 0)
		Then(cK + ": NEGATIVE: it is not empty", oPat.Count() > 3, 1)
	next
	Then("Binomial keeps its count fixed through the pattern", GpProc("Binomial").PatternIn(oSq, 7).Count(), 100)
	Then("SSI keeps its count through the pattern", GpProc("SSI").PatternIn(oSq, 7).Count(), 60)
	nSsi = GpMinNN(GpProc("SSI").PatternIn(oSq, 7))
	Then("the mechanism survives: no two SSI places closer than the 4 km core (nearest pair " + nSsi + " km)", nSsi > 3.99, 1)
	nMii = GpMinNN(GpProc("MaternII").PatternIn(oSq, 7))
	Then("the mechanism survives: no two MaternII places closer than the 3 km core (nearest pair " + nMii + " km)", nMii > 2.99, 1)
	nPoi = GpMinNN(GpProc("Poisson").PatternIn(oSq, 7))
	Then("NEGATIVE: Poisson has no core, its nearest pair is " + nPoi + " km, under 3", nPoi < 3, 1)
EndScenario()

# --- 2. PatternIn on the windows where it was seen to raise -------------------------------
Scenario("PatternIn works on the reported windows: Poisson on Niger, SSI and MaternCluster on the two countries")
	oNiger = GpWin($cGpNiger)
	oTwo = GpWin($cGpTwo)
	Given("Niger (" + oNiger.AreaKm2() + " km2) and the two invented countries with a hole and an island (" + oTwo.AreaKm2() + " km2)")
	oPo = new stzGeoProcess(:Poisson)
	oPo.SetIntensity(0.00015)
	oPat = oPo.PatternIn(oNiger, 20261024)
	Then("Poisson at 0.00015 per km2 on Niger returns a stzGeoPoints", classname(oPat), "stzgeopoints")
	Then("...with GenerateIn's " + (len(oPo.GenerateIn(oNiger, 20261024)) / 2) + " places", GpSame(oPat.Points(), oPo.GenerateIn(oNiger, 20261024)), 1)
	Then("...in Niger's window", oPat.AreaKm2(), oNiger.AreaKm2())
	Then("...every place inside it", oPat.Outside(), 0)
	oSsi = new stzGeoProcess(:SSI)
	oSsi.SetCount(40)
	oSsi.SetHardCoreKm(60)
	oPat = oSsi.PatternIn(oTwo, 11)
	Then("SSI on the two countries returns a stzGeoPoints", classname(oPat), "stzgeopoints")
	Then("...of 40 places", oPat.Count(), 40)
	Then("...in the two countries' window", oPat.AreaKm2(), oTwo.AreaKm2())
	Then("...and the 60 km core holds (nearest pair " + GpMinNN(oPat) + " km)", GpMinNN(oPat) > 59.5, 1)
	oMc = new stzGeoProcess(:MaternCluster)
	oMc.SetParentIntensity(0.000004)
	oMc.SetMeanChildren(30)
	oMc.SetRadiusKm(50)
	oPat = oMc.PatternIn(oTwo, 11)
	Then("MaternCluster on the two countries returns a stzGeoPoints", classname(oPat), "stzgeopoints")
	Then("...with GenerateIn's places", GpSame(oPat.Points(), oMc.GenerateIn(oTwo, 11)), 1)
	Then("...and a verdict can be asked of it", len(oPat.ClarkEvans()[:verdict]) > 0, 1)
	Then("NEGATIVE: another window is another pattern: Niger's is not the two countries'", GpSame(oMc.PatternIn(oNiger, 11).Points(), oPat.Points()), 0)
EndScenario()

# --- 3. the two-argument ExpectedCount, unchanged for the six other kinds ----------------------
Scenario("ExpectedCount with two areas still answers the literals for the six kinds that have a count")
	oNiger = GpWin($cGpNiger)
	nA = oNiger.AreaKm2()
	nB = oNiger.BoxAreaKm2()
	Given("Niger: " + nA + " km2, its box " + nB + " km2")
	oPo = new stzGeoProcess(:Poisson)
	oPo.SetIntensity(0.00015)
	Then("Poisson at 0.00015 per km2: 177.5, which is 0.00015 times 1183623.9266", GpNear(oPo.ExpectedCount(nA, nB), 177.54358, 0.001), 1)
	oBi = new stzGeoProcess(:Binomial)
	oBi.SetCount(246)
	Then("Binomial of 246: 246 whatever the area", GpNear(oBi.ExpectedCount(nA, nB), 246, 0.000001), 1)
	Then("...and 246 for another area", GpNear(oBi.ExpectedCount(5, 9), 246, 0.000001), 1)
	oS = new stzGeoProcess(:SSI)
	oS.SetCount(180)
	oS.SetHardCoreKm(40)
	Then("SSI of 180: 180", GpNear(oS.ExpectedCount(nA, nB), 180, 0.000001), 1)
	oMc = new stzGeoProcess(:MaternCluster)
	oMc.SetParentIntensity(0.000004)
	oMc.SetMeanChildren(40)
	oMc.SetRadiusKm(60)
	Then("MaternCluster at 4e-6 parents of 40 children: 4e-6 x 40 x area = 189.38", GpNear(oMc.ExpectedCount(nA, nB), 0.000004 * 40 * nA, 0.001), 1)
	oTh = new stzGeoProcess(:Thomas)
	oTh.SetParentIntensity(0.000004)
	oTh.SetMeanChildren(40)
	oTh.SetSigmaKm(30)
	Then("Thomas, the same: 189.38", GpNear(oTh.ExpectedCount(nA, nB), 0.000004 * 40 * nA, 0.001), 1)
	oM2 = new stzGeoProcess(:MaternII)
	oM2.SetIntensity(0.0004)
	oM2.SetHardCoreKm(40)
	nT = 0.0004 * 3.14159265358979 * 40 * 40
	nCeil = (1 - exp(-nT)) / (3.14159265358979 * 40 * 40)
	Then("MaternII at 0.0004 per km2, core 40 km: the survivors (1 - exp(-t)) / (pi r2) per km2 times the area = " + (nCeil * nA), GpNear(oM2.ExpectedCount(nA, nB), nCeil * nA, 0.001), 1)
	Then("NEGATIVE: that is not the proposal 0.0004 x area = " + (0.0004 * nA), GpNear(oM2.ExpectedCount(nA, nB), 0.0004 * nA, 1), 0)
EndScenario()

# --- 4. the two-argument ExpectedCount raises for Inhomogeneous -----------------------------------
Scenario("ExpectedCount with two areas refuses an Inhomogeneous process and names the call to use")
	oNiger = GpWin($cGpNiger)
	oI = GpNigerSurface()
	bRaised = FALSE
	cMsg = ""
	try
		oI.ExpectedCount(oNiger.AreaKm2(), oNiger.BoxAreaKm2())
	catch
		bRaised = TRUE
		cMsg = cCatchError
	done
	Then("the call that answered 191.9 for a count of 152 now raises", bRaised, TRUE)
	Then("...and the message names ExpectedCountIn", StzFindFirst("ExpectedCountIn", cMsg) > 0, TRUE)
	Then("...and says why: two areas cannot name a window", StzFindFirst("cannot name", cMsg) > 0, TRUE)
	Then("NEGATIVE: the same call on a Poisson process does not raise", GpRaisesExpected(GpProc("Poisson")), FALSE)
	Then("NEGATIVE: and the asking for the window does not raise on this surface", GpRaisesIn(oI, oNiger), FALSE)
EndScenario()

# --- 5. ExpectedCountIn for the six other kinds ----------------------------------------------------
Scenario("ExpectedCountIn answers the same numbers as ExpectedCount for every kind but Inhomogeneous")
	oNiger = GpWin($cGpNiger)
	nA = oNiger.AreaKm2()
	oPo = new stzGeoProcess(:Poisson)
	oPo.SetIntensity(0.00015)
	Then("Poisson at 0.00015 per km2 over Niger: 177.5", GpNear(oPo.ExpectedCountIn(oNiger), 177.54358, 0.001), 1)
	Then("...and it is ExpectedCount of the window's two areas", oPo.ExpectedCountIn(oNiger), oPo.ExpectedCount(nA, oNiger.BoxAreaKm2()))
	oBi = new stzGeoProcess(:Binomial)
	oBi.SetCount(246)
	Then("Binomial of 246: 246", GpNear(oBi.ExpectedCountIn(oNiger), 246, 0.000001), 1)
	oMc = new stzGeoProcess(:MaternCluster)
	oMc.SetParentIntensity(0.000004)
	oMc.SetMeanChildren(40)
	oMc.SetRadiusKm(60)
	Then("MaternCluster: 189.38", GpNear(oMc.ExpectedCountIn(oNiger), 0.000004 * 40 * nA, 0.001), 1)
	oM2 = new stzGeoProcess(:MaternII)
	oM2.SetIntensity(0.0004)
	oM2.SetHardCoreKm(40)
	nT = 0.0004 * 3.14159265358979 * 40 * 40
	Then("MaternII: the closed form of the ceiling", GpNear(oM2.ExpectedCountIn(oNiger), (1 - exp(-nT)) / (3.14159265358979 * 40 * 40) * nA, 0.001), 1)
	oS = new stzGeoProcess(:SSI)
	oS.SetCount(180)
	oS.SetHardCoreKm(40)
	Then("SSI of 180: 180", GpNear(oS.ExpectedCountIn(oNiger), 180, 0.000001), 1)
	Then("the lattice dial changes nothing for them: ExpectedCountInXT(window, 8) is the same Poisson number", GpNear(oPo.ExpectedCountInXT(oNiger, 8), oPo.ExpectedCountIn(oNiger), 0.000001), 1)
	oNoInt = new stzGeoProcess(:Poisson)
	Then("NEGATIVE: a Poisson process with no intensity set expects 0 and not the Niger number", GpNear(oNoInt.ExpectedCountIn(oNiger), 0, 0.000001), 1)
EndScenario()

# --- 6. ExpectedCountIn, inhomogeneous --------------------------------------------------------------
Scenario("ExpectedCountIn of an inhomogeneous process is the integral over the window: nine surfaces, each against its oracle and against 200 draws")
	Given("the unit square (" + nSqA + " km2) and surfaces whose integral is known without the library")

	# (a) the ramp: 0 to 0.05 per km2 rising east over lon 0..1 -> mean 0.025 over the window
	oRamp = new stzGeoProcess(:Inhomogeneous)
	oRamp.SetIntensityGrid([ 0, 0, 0.05, 0.05, 21, 21 ], GpRampValues())
	nOr = 0.025 * nSqA
	aD = GpDraw(oRamp, oSq, 200)
	nIn = oRamp.ExpectedCountIn(oSq)
	Then("(a) the ramp: the oracle is 0.025 x area = " + nOr + " and ExpectedCountIn says " + nIn, GpNear(nIn / nOr, 1, 0.003), 1)
	Then("(a) ...and 200 seeds draw " + aD[1] + " on average, within 5 sigma of it", GpNear(aD[1], nOr, 5 * sqrt(nOr / 200)), 1)
	# the western half of the same ramp: lon 0..0.5 climbs 0 to 0.025, mean 0.0125
	oWestW = GpWin(GpSquare(0, 0, 0.5, 1))
	nOr = 0.0125 * oWestW.AreaKm2()
	aD = GpDraw(oRamp, oWestW, 200)
	nIn = oRamp.ExpectedCountIn(oWestW)
	Then("(a) the western half of the ramp: the oracle is 0.0125 x area = " + nOr + " and ExpectedCountIn says " + nIn, GpNear(nIn / nOr, 1, 0.003), 1)
	Then("(a) ...and 200 seeds draw " + aD[1] + " on average, within 5 sigma of it", GpNear(aD[1], nOr, 5 * sqrt(nOr / 200)), 1)
	Then("(a) NEGATIVE: the OLD formula, the grid mean 0.025 times the area = " + (0.025 * oWestW.AreaKm2()) + ", is twice what the western half draws", fabs(0.025 * oWestW.AreaKm2() - aD[1]) > 5 * sqrt(nOr / 200), 1)

	# (b) half coverage: a constant 0.01 over lon 0..1 under a window of lon 0..2
	oHalfW = GpWin(GpSquare(0, 0, 2, 1))
	oHalf = new stzGeoProcess(:Inhomogeneous)
	oHalf.SetIntensityGrid([ 0, 0, 0.25, 0.25, 5, 5 ], GpConstValues(25, 0.01))
	nOr = 0.01 * 0.5 * oHalfW.AreaKm2()
	aD = GpDraw(oHalf, oHalfW, 200)
	nIn = oHalf.ExpectedCountIn(oHalfW)
	nOld = 0.01 * oHalfW.AreaKm2()
	Then("(b) half the window under the surface: the oracle is 0.01 x half the area = " + nOr + " and ExpectedCountIn says " + nIn, GpNear(nIn / nOr, 1, 0.003), 1)
	Then("(b) ...and 200 seeds draw " + aD[1] + " on average, within 5 sigma of it", GpNear(aD[1], nOr, 5 * sqrt(nOr / 200)), 1)
	Then("(b) NEGATIVE: the OLD formula, the grid mean times the area = " + nOld + ", is far outside what is drawn: " + ((nOld - aD[1]) / sqrt(nOr / 200)) + " standard errors", fabs(nOld - aD[1]) > 5 * sqrt(nOr / 200), 1)

	# (c) linear in latitude: 0.002 x (lat + 1), integrated here by 20,000 slices of equal area
	oLat = new stzGeoProcess(:Inhomogeneous)
	oLat.SetIntensityGrid([ -1, -1, 1, 1, 20, 14 ], GpLatValues())
	nOr = nSqA * GpLatMean()
	aD = GpDraw(oLat, oSq, 200)
	nIn = oLat.ExpectedCountIn(oSq)
	Then("(c) linear in latitude: the oracle is " + nOr + " (mean " + GpLatMean() + ") and ExpectedCountIn says " + nIn, GpNear(nIn / nOr, 1, 0.003), 1)
	Then("(c) ...and 200 seeds draw " + aD[1] + " on average, within 5 sigma of it", GpNear(aD[1], nOr, 5 * sqrt(nOr / 200)), 1)
	nOld = 0.013 * nSqA
	Then("(c) NEGATIVE: the OLD formula, the mean of the whole grid 0.013 times the area = " + nOld + ", is " + ((nOld - aD[1]) / sqrt(nOr / 200)) + " standard errors from what is drawn", fabs(nOld - aD[1]) > 5 * sqrt(nOr / 200), 1)

	# (d) one unknown node in the middle of a constant 0.01 surface
	oUnk = new stzGeoProcess(:Inhomogeneous)
	oUnk.SetIntensityGrid([ 0, 0, 0.25, 0.25, 5, 5 ], GpConstValuesHole(0.01))
	nOr = 0.009375 * nSqA
	aD = GpDraw(oUnk, oSq, 200)
	nIn = oUnk.ExpectedCountIn(oSq)
	Then("(d) one unknown node reads as 0: the oracle is 0.009375 x area = " + nOr + " and ExpectedCountIn says " + nIn, GpNear(nIn / nOr, 1, 0.003), 1)
	Then("(d) ...and 200 seeds draw " + aD[1] + " on average, within 5 sigma of it", GpNear(aD[1], nOr, 5 * sqrt(nOr / 200)), 1)
	Then("(d) NEGATIVE: with the hole filled (0.01 x area = " + (0.01 * nSqA) + ") it would be a different number", GpNear(nIn, 0.01 * nSqA, 0.0001 * nSqA), 0)
	Then("(d) NEGATIVE: ...and the draws see it too, " + ((0.01 * nSqA - aD[1]) / sqrt(nOr / 200)) + " standard errors under the filled number", (0.01 * nSqA - aD[1]) > 5 * sqrt(nOr / 200), 1)

	# (e) a surface of zeros
	oZero = new stzGeoProcess(:Inhomogeneous)
	oZero.SetIntensityGrid([ 0, 0, 0.25, 0.25, 5, 5 ], GpConstValues(25, 0))
	Then("(e) a surface of zeros expects 0", oZero.ExpectedCountIn(oSq), 0)
	Then("(e) ...and draws 0 on every one of 200 seeds", GpDraw(oZero, oSq, 200)[2], 0)
	Then("(e) ...and its pattern is empty but a stzGeoPoints all the same", classname(oZero.PatternIn(oSq, 3)) + ":" + oZero.PatternIn(oSq, 3).Count(), "stzgeopoints:0")

	# (f) a surface that is zero in the window and positive elsewhere
	oAway = new stzGeoProcess(:Inhomogeneous)
	oAway.SetIntensityGrid([ -1, -1, 1, 1, 20, 14 ], GpEastValues())
	Then("(f) positive only east of 5 E, a window at 0..1 E expects 0", oAway.ExpectedCountIn(oSq), 0)
	Then("(f) ...and draws 0 on every one of 200 seeds", GpDraw(oAway, oSq, 200)[2], 0)
	oEastW = GpWin(GpSquare(6, 0, 7, 1))
	Then("(f) NEGATIVE: a window at 6..7 E is under it and expects " + oAway.ExpectedCountIn(oEastW), GpNear(oAway.ExpectedCountIn(oEastW) / (0.01 * oEastW.AreaKm2()), 1, 0.003), 1)

	# (g) a constant surface under a window with a hole and an island: the count is the constant x the area
	oTwo = GpWin($cGpTwo)
	oConst = new stzGeoProcess(:Inhomogeneous)
	oConst.SetIntensityGrid([ -1, -1, 1, 1, 20, 14 ], GpConstValues(280, 0.00002))
	nOr = 0.00002 * oTwo.AreaKm2()
	aD = GpDraw(oConst, oTwo, 200)
	nIn = oConst.ExpectedCountIn(oTwo)
	Then("(g) a constant 0.00002 under the two countries: the oracle is the constant x " + oTwo.AreaKm2() + " km2 = " + nOr + " and ExpectedCountIn says " + nIn, GpNear(nIn / nOr, 1, 0.0001), 1)
	Then("(g) ...and 200 seeds draw " + aD[1] + " on average, within 5 sigma of it", GpNear(aD[1], nOr, 5 * sqrt(nOr / 200)), 1)

	# (h) a small window inside a constant surface
	oSmallW = GpWin(GpSquare(0.5, 0.5, 0.6, 0.6))
	oC2 = new stzGeoProcess(:Inhomogeneous)
	oC2.SetIntensityGrid([ -1, -1, 1, 1, 20, 14 ], GpConstValues(280, 0.01))
	nOr = 0.01 * oSmallW.AreaKm2()
	aD = GpDraw(oC2, oSmallW, 200)
	Then("(h) a window of " + oSmallW.AreaKm2() + " km2: the oracle is " + nOr + " and ExpectedCountIn says " + oC2.ExpectedCountIn(oSmallW), GpNear(oC2.ExpectedCountIn(oSmallW) / nOr, 1, 0.0001), 1)
	Then("(h) ...and 200 seeds draw " + aD[1] + " on average, within 5 sigma of it", GpNear(aD[1], nOr, 5 * sqrt(nOr / 200)), 1)

	# (i) a window that is NOT its box: the triangle (0,0) (1,0) (0,1) under a surface that climbs with the
	# longitude, 0.005 x lon. The mean of the longitude over a triangle is its centroid's, one third of the way
	# along (0.3333 against 0.5 for the box), so the window changes the answer and a lattice that ignored it
	# would say 50% too many
	oTri = GpWin('{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"name":"T"},"geometry":{"type":"Polygon","coordinates":[[[0,0],[1,0],[0,1],[0,0]]]}}]}')
	oLon = new stzGeoProcess(:Inhomogeneous)
	oLon.SetIntensityGrid([ -1, -1, 1, 1, 20, 14 ], GpLonValues())
	nOr = 0.005 / 3 * oTri.AreaKm2()
	aD = GpDraw(oLon, oTri, 200)
	nIn = oLon.ExpectedCountIn(oTri)
	Then("(i) a triangle of " + oTri.AreaKm2() + " km2: the oracle is 0.005 x one third x area = " + nOr + " and ExpectedCountIn says " + nIn, GpNear(nIn / nOr, 1, 0.01), 1)
	Then("(i) ...and 200 seeds draw " + aD[1] + " on average, within 5 sigma of it", GpNear(aD[1], nOr, 5 * sqrt(nOr / 200)), 1)
	Then("(i) NEGATIVE: the answer for the whole box, 0.005 x one half x area = " + (0.0025 * oTri.AreaKm2()) + ", is not it", GpNear(nIn, 0.0025 * oTri.AreaKm2(), 0.05 * nOr), 0)

	# the lattice dial converges, and no surface at all expects nothing
	nHi = oLat.ExpectedCountInXT(oSq, 400)
	Then("the lattice dial: 400 places along the side gives " + nHi + ", within 0.3% of the default", GpNear(nHi / oLat.ExpectedCountIn(oSq), 1, 0.003), 1)
	oNoSurf = new stzGeoProcess(:Inhomogeneous)
	Then("an Inhomogeneous process with no surface set expects 0", oNoSurf.ExpectedCountIn(oSq), 0)
	Then("...and draws no place", len(oNoSurf.GenerateIn(oSq, 3)), 0)
EndScenario()

# --- 7. the six other kinds, drawn ----------------------------------------------------------------
Scenario("The expected count of every other kind agrees with the mean of 200 drawn patterns, within 5 standard errors")
	Given("the unit square and one process of each kind; the standard error is that of a mean of 200")
	oPo = GpProc("Poisson")
	nE = oPo.ExpectedCountIn(oSq)
	aD = GpDraw(oPo, oSq, 200)
	Then("Poisson at 0.01: expected " + nE + " (0.01 x area), drawn " + aD[1], GpNear(aD[1], nE, 5 * sqrt(nE / 200)), 1)
	Then("...and the expected count is the literal 0.01 x area", GpNear(nE, 0.01 * nSqA, 0.0001), 1)
	oBi = GpProc("Binomial")
	aD = GpDraw(oBi, oSq, 200)
	Then("Binomial of 100: every one of 200 patterns has exactly 100", "" + aD[1] + ":" + aD[2] + ":" + aD[3], "100:100:100")
	oSsi = GpProc("SSI")
	aD = GpDraw(oSsi, oSq, 200)
	Then("SSI of 60: every one of 200 patterns has exactly 60", "" + aD[1] + ":" + aD[2] + ":" + aD[3], "60:60:60")
	oMc = GpProc("MaternCluster")
	nE = oMc.ExpectedCountIn(oSq)
	nVar = 0.0004 * nSqA * (20 + 20 * 20)
	aD = GpDraw(oMc, oSq, 200)
	Then("MaternCluster: expected " + nE + " (parents x children), drawn " + aD[1] + ", 5 sigma = " + (5 * sqrt(nVar / 200)), GpNear(aD[1], nE, 5 * sqrt(nVar / 200)), 1)
	oTh = GpProc("Thomas")
	aD = GpDraw(oTh, oSq, 200)
	Then("Thomas: expected " + nE + ", drawn " + aD[1], GpNear(aD[1], nE, 5 * sqrt(nVar / 200)), 1)
	oM2 = GpProc("MaternII")
	nE = oM2.ExpectedCountIn(oSq)
	aD = GpDraw(oM2, oSq, 200)
	Then("MaternII: expected " + nE + " (the ceiling's closed form), drawn " + aD[1], GpNear(aD[1], nE, 5 * sqrt(nE / 200)), 1)
	Then("NEGATIVE: the proposal 0.02 x area = " + (0.02 * nSqA) + " is not what MaternII keeps", GpNear(aD[1], 0.02 * nSqA, 5 * sqrt(nE / 200)), 0)
EndScenario()

# --- 8. bad arguments and degenerate windows ------------------------------------------------------
Scenario("Bad arguments are refused with a message, and a window with no area expects nothing")
	oI = GpProc("Inhomogeneous")
	oP = GpProc("Poisson")
	Then("PatternIn with a number for a window raises", GpRaisesPattern(oP, 5), TRUE)
	Then("PatternIn with the window's list of rings (the old argument) raises", GpRaisesPattern(oP, oSq.WindowRings()), TRUE)
	Then("PatternIn with a stzGeoFeatures (not a stzGeoPoints) raises", GpRaisesPattern(oP, StzGeoFeaturesFromJson(GpSquare(0, 0, 1, 1))), TRUE)
	Then("ExpectedCountIn with a number raises", GpRaisesInArg(oP, 5), TRUE)
	Then("ExpectedCountIn with a text raises, for Inhomogeneous too", GpRaisesInArg(oI, "Niger"), TRUE)
	Then("ExpectedCountInXT with 2 places along the side raises", GpRaisesXT(oI, oSq, 2), TRUE)
	Then("ExpectedCountInXT with a text raises", GpRaisesXT(oI, oSq, "many"), TRUE)
	Then("NEGATIVE: ExpectedCountInXT with 4 places is the smallest accepted", GpRaisesXT(oI, oSq, 4), FALSE)
	bShort = FALSE
	oShort = new stzGeoProcess(:Inhomogeneous)
	oShort.SetIntensityGrid([ 0, 0, 0.25, 0.25, 5, 5 ], [ 0.01, 0.01, 0.01 ])
	try
		oShort.ExpectedCountIn(oSq)
	catch
		bShort = TRUE
	done
	Then("a surface with 3 values for a grid of 25 nodes is refused, not read past its end", bShort, TRUE)
	bEmpty = FALSE
	try
		oNone = StzGeoPoints([], StzGeoFeaturesFromJson('{"type":"FeatureCollection","features":[]}'))
	catch
		bEmpty = TRUE
	done
	Then("a window with no feature cannot be built at all, so no process is asked about it", bEmpty, TRUE)
	oZ = GpWin('{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"name":"Z"},"geometry":{"type":"Polygon","coordinates":[[[0,0],[1,0],[0,0]]]}}]}')
	Then("a window with no area (" + oZ.AreaKm2() + " km2) expects 0 of an inhomogeneous process", oI.ExpectedCountIn(oZ), 0)
	oConst = new stzGeoProcess(:Inhomogeneous)
	oConst.SetIntensityGrid([ -1, -1, 1, 1, 20, 14 ], GpConstValues(280, 0.01))
	Then("...and of a constant one", oConst.ExpectedCountIn(oZ), 0)
	Then("...and PatternIn on it is an empty pattern, not an error", oConst.PatternIn(oZ, 3).Count(), 0)
	oPo = new stzGeoProcess(:Poisson)
	Then("a Poisson process with no intensity set draws an empty pattern", oPo.PatternIn(oSq, 3).Count(), 0)
	Then("NEGATIVE: and with an intensity set it does not", GpProc("Poisson").PatternIn(oSq, 3).Count() > 0, 1)
EndScenario()

Summary()

# --- helpers (after the scenarios: Ring puts everything after a func inside it) -------------------

func GpSquare(x0, y0, x1, y1)
	return '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"name":"S"},"geometry":{"type":"Polygon","coordinates":[[[' + x0 + ',' + y0 + '],[' + x1 + ',' + y0 + '],[' + x1 + ',' + y1 + '],[' + x0 + ',' + y1 + '],[' + x0 + ',' + y0 + ']]]}}]}'

func GpWin(cJson)
	return StzGeoPoints([], StzGeoFeaturesFromJson(cJson))

func GpNear(a, b, tol)
	if fabs(a - b) <= tol  return 1  ok
	return 0

# two flat number lists, element by element (never strcmp: it stops at a NUL and folds nothing here)
func GpSame(a, b)
	if len(a) != len(b)  return 0  ok
	for _i_ = 1 to len(a)
		if a[_i_] != b[_i_]  return 0  ok
	next
	return 1

func GpSameRings(a, b)
	if len(a) != len(b)  return 0  ok
	for _i_ = 1 to len(a)
		if GpSame(a[_i_], b[_i_]) = 0  return 0  ok
	next
	return 1

# smallest nearest-neighbour distance in a pattern
func GpMinNN(oPat)
	_a_ = oPat.NearestNeighbourKm()
	_m_ = 1000000
	for _i_ = 1 to len(_a_)
		if _a_[_i_] < _m_  _m_ = _a_[_i_]  ok
	next
	return _m_

# [ mean, min, max ] of the number of places over nSeeds patterns, seeds 9001 and up (fixed, so nothing flakes)
func GpDraw(oProc, oWin, nSeeds)
	_s_ = 0
	_lo_ = 1000000000
	_hi_ = 0
	for _k_ = 1 to nSeeds
		_n_ = len(oProc.GenerateIn(oWin, 9000 + _k_)) / 2
		_s_ += _n_
		if _n_ < _lo_  _lo_ = _n_  ok
		if _n_ > _hi_  _hi_ = _n_  ok
	next
	return [ _s_ / nSeeds, _lo_, _hi_ ]

func GpConstValues(nCount, nValue)
	_a_ = []
	for _i_ = 1 to nCount
		_a_ + nValue
	next
	return _a_

# 5 x 5 nodes of nValue with the middle node unknown
func GpConstValuesHole(nValue)
	_a_ = []
	for _j_ = 1 to 5
		for _i_ = 1 to 5
			if _i_ = 3 and _j_ = 3  _a_ + ""  else  _a_ + nValue  ok
		next
	next
	return _a_

func GpRampValues()
	_a_ = []
	for _j_ = 0 to 20
		for _i_ = 0 to 20
			_a_ + (0.05 * _i_ / 20)
		next
	next
	return _a_

# grid [ -1, -1, 1, 1, 20, 14 ]: lon -1..18, lat -1..12; the node on row j sits at lat j - 1, so 0.002 x j is 0.002 x (lat + 1)
func GpLatValues()
	_a_ = []
	for _j_ = 0 to 13
		for _i_ = 0 to 19
			_a_ + (0.002 * _j_)
		next
	next
	return _a_

# the same grid: 0.01 where the node's longitude is 5 or more, else 0
func GpEastValues()
	_a_ = []
	for _j_ = 0 to 13
		for _i_ = 0 to 19
			if (_i_ - 1) >= 5  _a_ + 0.01  else  _a_ + 0  ok
		next
	next
	return _a_

# THE ORACLE FOR (c), with no call into the library: the mean of 0.002 x (lat + 1) over the unit square
# on the sphere, by 20,000 slices of equal area (equal steps of sin(latitude))
func GpLatMean()
	_r_ = 3.14159265358979 / 180
	_s0_ = sin(0)
	_s1_ = sin(1 * _r_)
	_n_ = 20000
	_t_ = 0
	for _k_ = 1 to _n_
		_sk_ = _s0_ + (_s1_ - _s0_) * (_k_ - 0.5) / _n_
		_lat_ = asin(_sk_) / _r_
		_t_ += 0.002 * (_lat_ + 1)
	next
	return _t_ / _n_

# the same grid: 0.005 x the node's longitude (the node on column i sits at lon i - 1)
func GpLonValues()
	_a_ = []
	for _j_ = 0 to 13
		for _i_ = 0 to 19
			_a_ + (0.005 * (_i_ - 1))
		next
	next
	return _a_

func GpProc(cKind)
	_o_ = new stzGeoProcess(cKind)
	if cKind = "Poisson"  _o_.SetIntensity(0.01)  ok
	if cKind = "Binomial"  _o_.SetCount(100)  ok
	if cKind = "Inhomogeneous"
		_o_.SetIntensityGrid([ 0, 0, 0.05, 0.05, 21, 21 ], GpRampValues())
	ok
	if cKind = "MaternCluster"
		_o_.SetParentIntensity(0.0004)
		_o_.SetMeanChildren(20)
		_o_.SetRadiusKm(3)
	ok
	if cKind = "Thomas"
		_o_.SetParentIntensity(0.0004)
		_o_.SetMeanChildren(20)
		_o_.SetSigmaKm(2)
	ok
	if cKind = "MaternII"
		_o_.SetIntensity(0.02)
		_o_.SetHardCoreKm(3)
	ok
	if cKind = "SSI"
		_o_.SetCount(60)
		_o_.SetHardCoreKm(4)
	ok
	return _o_

# the gallery surface over Niger (28 x 22 nodes, richer toward 11.7 N, 0 E) as an Inhomogeneous process
func GpNigerSurface()
	_w_ = GpWin($cGpNiger)
	_g_ = StzEngineGeoGridOver(_w_.WindowBox(), 60)
	_v_ = []
	for _r_ = 0 to _g_[6] - 1
		for _c_ = 0 to _g_[5] - 1
			_lon_ = _g_[1] + _c_ * _g_[3]
			_lat_ = _g_[2] + _r_ * _g_[4]
			_v_ + (0.0012 * exp(-((_lat_ - 11.7) * (_lat_ - 11.7) + _lon_ * _lon_) / 30))
		next
	next
	_o_ = new stzGeoProcess(:Inhomogeneous)
	_o_.SetIntensityGrid(_g_, _v_)
	return _o_

func GpRaisesExpected(oProc)
	_b_ = FALSE
	try
		oProc.ExpectedCount(100, 200)
	catch
		_b_ = TRUE
	done
	return _b_

func GpRaisesIn(oProc, oWin)
	_b_ = FALSE
	try
		oProc.ExpectedCountIn(oWin)
	catch
		_b_ = TRUE
	done
	return _b_

func GpRaisesInArg(oProc, xArg)
	_b_ = FALSE
	try
		oProc.ExpectedCountIn(xArg)
	catch
		_b_ = TRUE
	done
	return _b_

func GpRaisesPattern(oProc, xArg)
	_b_ = FALSE
	try
		oProc.PatternIn(xArg, 1)
	catch
		_b_ = TRUE
	done
	return _b_

func GpRaisesXT(oProc, oWin, xNodes)
	_b_ = FALSE
	try
		oProc.ExpectedCountInXT(oWin, xNodes)
	catch
		_b_ = TRUE
	done
	return _b_
