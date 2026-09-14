load "../../stzBase.ring"
decimals(4)

# GE7a -- A POINT PATTERN AND ITS WINDOW. A narrated guard for stzGeoPoints:
# the measures an analyst asks first -- clustered, scattered or random --
# proven on patterns whose answer is KNOWN because the guard made them, and
# the null drawn by simulation rather than by a correction formula.
#
# The window is the no-lake Arda from the fixtures: five degrees of longitude
# by ten of latitude on the equator, about 555 km by 1,111 km. Big enough that
# a cluster of 20 km radius is a cluster and not the whole country.

nOk = 0  nBad = 0
? "=========================================================="
? " GE7a: a point pattern and its window"
? "=========================================================="

oW = StzGeoFeaturesFromJson(_ArdaJson())
nArea = oW.AreaKm2()
? "   the window measures " + StzFactNumText(nArea) + " km2"

? ""
? "-- 1. A PATTERN IS ITS POINTS AND ITS WINDOW, never the points alone --"
chk("a pattern without a window is refused -- a hundred wells in Tunisia and " +
    "the same hundred in Niger are one list and two opposite answers",
    _RefusesNoWindow())
oU = StzGeoPoints([ 2.5, 5, 2.6, 5.1 ], oW)
chk("the area a density divides by is the window's, holes out and parts in",
    fabs(oU.AreaKm2() - nArea) < 0.001 and nArea > 500000 and nArea < 700000)
oOut = StzGeoPoints([ 2.5, 5, 40, 40, 41, 41 ], oW)
? "   three points, two of them far outside: Outside() says " + oOut.Outside()
chk("POINTS OUTSIDE THE WINDOW ARE COUNTED, NEVER DROPPED -- they stand in the " +
    "density and on none of its area, and the gate warns",
    oOut.Outside() = 2 and _HasFinding(oOut.Findings(), "the_points_are_in_their_window", "warning"))
chk("...and the map's own area is the features' area now, not a second copy of " +
    "the arithmetic",
    fabs(StzGeoMap(new stzGeoProjection(:Equirectangular), oW).ValuesFromArea()[1] - nArea) < 0.001)

? ""
? "-- 2. THREE PATTERNS WHOSE ANSWER IS KNOWN, because this guard made them --"
aRnd = oU.Sample(500, 20260914)
aClu = oU.SampleClustered(10, 50, 20, 20260914)
aDis = oU.SampleDispersed(500, 15, 20260914)
oRnd = oU.With(aRnd)
oClu = oU.With(aClu)
oDis = oU.With(aDis)
? "   uniform " + oRnd.Count() + ", clustered " + oClu.Count() + ", dispersed " + oDis.Count()
chk("a uniform sample gives the count asked for, and every point is inside " +
    "the window",
    oRnd.Count() = 500 and oRnd.Outside() = 0)
chk("the clustered and the dispersed samples are inside it too",
    oClu.Count() > 300 and oClu.Outside() = 0 and oDis.Count() > 300 and oDis.Outside() = 0)
# compared element by element: Ring's = between two lists is not that
chk("SEEDED: the same seed gives the same points, so a picture does not move " +
    "between renders -- and a different seed gives different ones",
    _SameList(oU.Sample(50, 7), oU.Sample(50, 7)) and NOT _SameList(oU.Sample(50, 7), oU.Sample(50, 8)))
chk("NEGATIVE: a hard-core sample that asks for more discs than the window " +
    "holds gives FEWER, and says so in the count rather than overlapping them",
    len(oU.SampleDispersed(100000, 60, 1)) / 2 < 100000)

? ""
? "-- 3. CLARK-EVANS: the first question, in one number --"
rR = oRnd.ClarkEvans()
rC = oClu.ClarkEvans()
rD = oDis.ClarkEvans()
? "   uniform   R " + StzFactNumText(rR[:r]) + "  z " + StzFactNumText(rR[:z]) + "  -> " + rR[:verdict]
? "   clustered R " + StzFactNumText(rC[:r]) + "  z " + StzFactNumText(rC[:z]) + "  -> " + rC[:verdict]
? "   dispersed R " + StzFactNumText(rD[:r]) + "  z " + StzFactNumText(rD[:z]) + "  -> " + rD[:verdict]
chk("a uniform pattern reads as RANDOM: R near 1, z inside +-1.96",
    rR[:verdict] = "random" and rR[:r] > 0.9 and rR[:r] < 1.1)
chk("a Matern cluster pattern reads as CLUSTERED: R well under 1, z under -1.96",
    rC[:verdict] = "clustered" and rC[:r] < 0.7)
chk("a hard-core pattern reads as DISPERSED: R over 1, z over 1.96",
    rD[:verdict] = "dispersed" and rD[:r] > 1.2)
chk("...and the three R values ORDER the way the patterns were made, " +
    "clustered below random below dispersed -- the mechanism, not three " +
    "verdicts that could each be right by accident",
    rC[:r] < rR[:r] and rR[:r] < rD[:r])
# THE EDGE CORRECTION, SHOWN TO DO ITS WORK. Uncorrected, the same uniform
# pattern reads as dispersed: every point near the border has its nearest
# neighbour farther than an unbounded plane would give it, and the mean
# rises. Donnelly's correction lifts the expectation by a term in the
# window's perimeter and the verdict comes back to random.
rU = oRnd.ClarkEvansUncorrected()
? "   the same uniform pattern UNCORRECTED: R " + StzFactNumText(rU[:r]) + "  z " +
  StzFactNumText(rU[:z]) + "  -> " + rU[:verdict] + "   (perimeter " +
  StzFactNumText(oRnd.PerimeterKm()) + " km)"
chk("THE UNCORRECTED INDEX LEANS TOWARD DISPERSED on a real window, and the " +
    "correction pulls it back: the corrected z is lower and the corrected " +
    "expectation higher, on the same observed distances",
    rR[:z] < rU[:z] and rR[:expected] > rU[:expected] and
    fabs(rR[:observed] - rU[:observed]) < 0.000001)
chk("the uncorrected expectation is 0.5 over the root of the density, which " +
    "is Clark and Evans's own formula and not this file's",
    fabs(rU[:expected] - 0.5 / sqrt(oRnd.Count() / nArea)) < 0.0001)

? ""
? "-- 4. RIPLEY'S K, AND THE NULL BY SIMULATION --"
aRad = [ 10, 20, 30, 40, 60, 80 ]
aK = oRnd.RipleyK(aRad)
? "   K(10) " + StzFactNumText(aK[1]) + " against pi r2 = " + StzFactNumText(3.14159265358979 * 100)
chk("K of a uniform pattern at a small radius is close to pi r squared -- " +
    "the edge has taken little yet",
    fabs(aK[1] / (3.14159265358979 * 100) - 1) < 0.2)
chk("K rises with r, because it counts everything within r",
    aK[2] > aK[1] and aK[6] > aK[5])
chk("NEGATIVE: radii that do not ascend are refused by name", _RefusesRadii(oRnd))
aE = oRnd.EnvelopeL(aRad, 39, 20260914)
aLR = oRnd.L(aRad)
aLC = oClu.L(aRad)
aLD = oDis.L(aRad)
? "   L at 30 km: uniform " + StzFactNumText(aLR[3]) + ", clustered " + StzFactNumText(aLC[3]) +
  ", dispersed " + StzFactNumText(aLD[3]) + "; the band of 39 nulls is [" +
  StzFactNumText(aE[3][1]) + ", " + StzFactNumText(aE[3][2]) + "]"
chk("the envelope is a band: lo <= mean <= hi at every radius",
    _BandOrdered(aE))
chk("THE UNIFORM PATTERN'S L STAYS INSIDE THE BAND of 39 simulated nulls at " +
    "every radius -- which is what makes the uncorrected K honest to read",
    _InsideBand(aLR, aE))
chk("THE CLUSTERED PATTERN'S L RISES ABOVE THE BAND at the cluster's own scale",
    aLC[2] > aE[2][2] or aLC[3] > aE[3][2])
chk("THE DISPERSED PATTERN'S L FALLS BELOW THE BAND at the inhibition distance",
    aLD[1] < aE[1][1] or aLD[2] < aE[2][1])

? ""
? "-- 5. G AND F: two distributions that read the same three patterns --"
aG = oRnd.G(aRad)
aF = oRnd.F(aRad, 400, 20260914)
chk("G and F rise from 0 toward 1 and never fall -- they are distributions",
    _Monotone(aG) and _Monotone(aF) and aG[6] <= 1 and aF[6] <= 1)
aGC = oClu.G(aRad)
chk("a clustered pattern's G rises FASTER than a uniform one's at small r: " +
    "its points have near neighbours",
    aGC[1] > aG[1])
aFC = oClu.F(aRad, 400, 20260914)
chk("...and its F rises SLOWER: the empty space between clusters is emptier",
    aFC[2] < aF[2])

? ""
? "-- 6. WHERE THE MIDDLE IS, AND WHICH WAY IT SPREADS --"
aSym = [ 2.5, 3, 2.5, 7, 1.5, 5, 3.5, 5 ]
oSym = oU.With(aSym)
aMc = oSym.MeanCentre()
? "   the mean centre of the cross is " + StzFactNumText(aMc[1]) + ", " + aMc[2]
# ON THE SPHERE THE CENTRE OF A CROSS IS NOT QUITE ITS CROSSING. The pair
# east and west of it, at 1.5E and 3.5E on the same latitude, have their
# midpoint a hair POLEWARD of that latitude -- the chord between them runs
# under the parallel -- so the mean of the four sits about 0.0004 degrees
# north of 5. The first draft of this line asked for 0.0001 and failed on a
# correct answer. The longitude is exact by symmetry; the latitude gets the
# sphere's tolerance and not the arithmetic's.
chk("the mean centre of a symmetric pattern is on its meridian exactly, and " +
    "on its parallel to the sphere's own tolerance",
    fabs(aMc[1] - 2.5) < 0.000000001 and fabs(aMc[2] - 5) < 0.001 and aMc[2] > 5)
aMed = oSym.SpatialMedian()
chk("...and so is its spatial median",
    fabs(aMed[1] - 2.5) < 0.001 and fabs(aMed[2] - 5) < 0.001)
aNS = [ 2.5, 2, 2.5, 3, 2.5, 4, 2.5, 5, 2.5, 6, 2.5, 7, 2.5, 8 ]
eNS = oU.With(aNS).Ellipse()
? "   a north-south line: major " + StzFactNumText(eNS[:major]) + " km, minor " +
  StzFactNumText(eNS[:minor]) + " km, bearing " + StzFactNumText(eNS[:bearing])
chk("THE ELLIPSE LIES ALONG THE SPREAD: a north-south line bears 0, its minor " +
    "axis is nothing",
    (eNS[:bearing] < 0.01 or eNS[:bearing] > 179.99) and eNS[:minor] < 0.01 and eNS[:major] > 200)
aEW = [ 1, 5, 1.5, 5, 2, 5, 2.5, 5, 3, 5, 3.5, 5, 4, 5 ]
chk("...and an east-west line bears 90",
    fabs(oU.With(aEW).Ellipse()[:bearing] - 90) < 0.01)
aRing = oClu.EllipseRing(48)
oP = new stzGeoProjection(:Equirectangular)
oP.FitToFeatures(oW, 400, 600, 20)
chk("the ellipse comes back as a lon/lat ring the projection can draw",
    len(aRing) = 96 and len(oP.Ring(aRing)) >= 1)
chk("the standard distance is the root mean square distance from the centre, " +
    "and for the uniform pattern it is a sizeable fraction of the window",
    oRnd.Ellipse()[:sd] > 150 and oRnd.Ellipse()[:sd] < 450)

? ""
? "-- 7. WHAT THE GATE OWES A PATTERN --"
oFew = oU.With([ 2.5, 5, 2.6, 5.1, 2.7, 5.2 ])
chk("too few points to judge WARNS -- the z rests on a normal approximation " +
    "that needs a few dozen",
    _HasFinding(oFew.Findings(), "enough_points_to_judge", "warning"))
chk("NEGATIVE: five hundred points inside their window report nothing at all",
    len(oRnd.Findings()) = 0 and oRnd.IsSound())

? ""
? "=========================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=========================================================="

func chk pcWhat, pbOk
	if pbOk
		nOk++
		? "  ok   " + pcWhat
	else
		nBad++
		? "  FAIL " + pcWhat
	ok

func _RefusesNoWindow
	try
		StzGeoPoints([ 1, 1 ], "not a window")
	catch
		return StzFindFirst("window", cCatchError) > 0
	done
	return FALSE

func _RefusesRadii poP
	try
		poP.RipleyK([ 10, 5, 20 ])
	catch
		return StzFindFirst("ascend", cCatchError) > 0
	done
	return FALSE

func _BandOrdered paE
	for _i_ = 1 to len(paE)
		if NOT (paE[_i_][1] <= paE[_i_][3] + 0.000001 and paE[_i_][3] <= paE[_i_][2] + 0.000001)
			return FALSE
		ok
	next
	return TRUE

func _InsideBand paL, paE
	for _i_ = 1 to len(paL)
		if paL[_i_] < paE[_i_][1] - 0.000001 or paL[_i_] > paE[_i_][2] + 0.000001  return FALSE  ok
	next
	return TRUE

func _SameList paA, paB
	if len(paA) != len(paB)  return FALSE  ok
	for _i_ = 1 to len(paA)
		if paA[_i_] != paB[_i_]  return FALSE  ok
	next
	return TRUE

func _Monotone paV
	for _i_ = 2 to len(paV)
		if paV[_i_] < paV[_i_ - 1]  return FALSE  ok
	next
	return TRUE

func _HasFinding paFindings, pcRule, pcSeverity
	for _i_ = 1 to len(paFindings)
		if paFindings[_i_][:rule] = pcRule and paFindings[_i_][:severity] = pcSeverity
			return TRUE
		ok
	next
	return FALSE

# Arda without its lake: 0..5 E, 0..10 N
func _ArdaJson
	return '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"name":"Arda"},' +
		'"geometry":{"type":"Polygon","coordinates":[[[0,0],[5,0],[5,10],[0,10],[0,0]]]}}]}'
