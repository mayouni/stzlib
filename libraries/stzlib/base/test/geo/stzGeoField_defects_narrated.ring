load "../../stzBase.ring"
load "../_narrated.ring"
decimals(4)

# stzGeoField -- the defects the documenting wave found, reproduced with real data and held shut.
# DOCREFORM follow-up, 2026-10-18. Run from inside test/geo:  ring stzGeoField_defects_narrated.ring
#
# Data: invented grids only (a constant field of 0.1, 0.3, 2.7, 0.001, 123.456; a field that
# climbs; a field with a flat floor and a flat ceiling), and the Arda window (0..5 E, 0..10 N),
# so nothing here needs the atlas.
#
# What each scenario holds, and the rule it answers to:
#   1. a constant field        -> a read at ANY place is the node value to the last bit
#   2. a field that climbs     -> a read is still INTERPOLATED (hand-computed), not flattened
#   3. unknown nodes           -> weights renormalised to the known ones; never outside their range
#   4. the class edges         -> the first edge IS the lowest value and the last IS the highest
#   5. the raster              -> a flat floor and a flat ceiling are painted, not left as no data
#   6. the ramp names          -> the error lists every ramp that exists
#
# THE ROOT IS IN THE ENGINE (geo_field.zig, sampleAt and classOf: weights that sum to 1 only up
# to rounding, and a class test that is exact), which this desk does not rebuild. The library
# answers it at its own boundary: ValueAt clamps to the nodes the read is made of, and the
# raster asks the engine for classes with a tolerance of 1e-12 of the range at each edge.
#
# THE RASTER CLAIM WAS VERIFIED BY COUNTING PIXELS. Nobody has looked at the picture; a
# picture is a human-judged artefact and this guard says only that no pixel inside the field
# is left as no data.
#
# Every positive carries a negative sibling: what must still be interpolated, still be
# refused, still be left unpainted.

# --- 1. a constant field ------------------------------------------------------------------
Scenario("A constant field reads as exactly its node value, at every place")
	aV = [ 0.1, 0.3, 2.7, 0.001, 123.456, 1/3, 7.77, 1000000.1 ]
	nBadAll = 0
	nOffNodeAll = 0
	for k = 1 to len(aV)
		oF = ConstField(aV[k])
		aR = LatticeDiff(oF, aV[k])
		nBadAll += aR[1]
		nOffNodeAll += aR[2]
		Then("the value " + aV[k] + " reads back exactly at all " + aR[3] + " lattice places", aR[1], 0)
	next
	Then("NEGATIVE: the lattice is not just the nodes -- most of its places lie between them",
		nOffNodeAll > 6000, 1)
	oK = ConstField(0.3)
	Then("NEGATIVE: a place off the grid is still no answer at all, not the node value", oK.ValueAt(9, 12), "")
	Then("NEGATIVE: and so is a place just past the last node", oK.ValueAt(4.001, 12), "")
EndScenario()

# --- 2. a field that climbs ---------------------------------------------------------------
Scenario("A field that climbs is still interpolated, not flattened by the clamp")
	oF = new stzGeoField([ 0, 10, 1, 1, 4, 3 ], [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ])
	# v(lon, lat) = 1 + lon + 4 * (lat - 10): a plane, which bilinear reproduces exactly
	Then("the documented example: (1.5, 10.5) reads 4.5", Near(oF.ValueAt(1.5, 10.5), 4.5), 1)
	Then("a quarter point of the first cell, (0.25, 10.25), reads 1 + 0.25 + 1 = 2.25",
		Near(oF.ValueAt(0.25, 10.25), 2.25), 1)
	Then("a quarter point of the last cell, (2.75, 11.75), reads 1 + 2.75 + 7 = 10.75",
		Near(oF.ValueAt(2.75, 11.75), 10.75), 1)
	Then("a node reads as itself: (3, 12) is 12", Near(oF.ValueAt(3, 12), 12), 1)
	nStrict = 0
	for ix = 1 to 29
		for iy = 1 to 19
			nV = oF.ValueAt(ix / 10, 10 + iy / 10)
			if isNumber(nV) and nV > 1 and nV < 12  nStrict++  ok
		next
	next
	Then("NEGATIVE: between the nodes the reads are strictly inside the range, not pinned to its ends",
		nStrict, 29 * 19)
	# a cell with a twist, so the product term counts: 0 0 / 0 4 over one cell
	oT = new stzGeoField([ 0, 0, 1, 1, 2, 2 ], [ 0, 0, 0, 4 ])
	Then("a twisted cell reads 1 at its centre", Near(oT.ValueAt(0.5, 0.5), 1), 1)
	Then("a twisted cell reads 0.25 at its quarter point (0.25, 0.25)", Near(oT.ValueAt(0.25, 0.25), 0.25), 1)
	Then("a twisted cell reads 4 * 0.75 * 0.5 = 1.5 at (0.75, 0.5) -- the clamp does not touch an inner value",
		Near(oT.ValueAt(0.75, 0.5), 1.5), 1)
EndScenario()

# --- 3. unknown nodes ---------------------------------------------------------------------
Scenario("With unknown nodes the read is over the known ones and stays inside their range")
	oF = new stzGeoField([ 0, 0, 1, 1, 2, 2 ], [ 1, 2, 3, "" ])
	Then("one corner unknown: the centre is the mean of the other three, (1 + 2 + 3) / 3 = 2",
		Near(oF.ValueAt(0.5, 0.5), 2), 1)
	oC = new stzGeoField([ 0, 0, 1, 1, 2, 2 ], [ 0.3, 0.3, 0.3, "" ])
	nBad = 0
	for ix = 0 to 20
		for iy = 0 to 20
			nV = oC.ValueAt(ix / 20, iy / 20)
			if nV != 0.3  nBad++  ok
		next
	next
	Then("one corner unknown over a constant 0.3: every read of the cell is exactly 0.3", nBad, 0)
	# no node of the middle cell known: the 4 x 4 block around it answers
	aVals = []
	for j = 0 to 3
		for i = 0 to 3
			if (i = 1 or i = 2) and (j = 1 or j = 2)
				aVals + ""
			else
				aVals + 0.7
			ok
		next
	next
	oB = new stzGeoField([ 0, 0, 1, 1, 4, 4 ], aVals)
	Then("none of the four known: the surrounding block answers, exactly 0.7 when it is all 0.7",
		oB.ValueAt(1.5, 1.5), 0.7)
	oNone = new stzGeoField([ 0, 0, 1, 1, 2, 2 ], [ "", "", "", "" ])
	Then("NEGATIVE: a field with nothing known at all answers no value", oNone.ValueAt(0.5, 0.5), "")
	Then("NEGATIVE: and an unknown node does not read as zero -- the other three decide",
		oF.ValueAt(0.9, 0.9) > 1, 1)
EndScenario()

# --- 4. the class edges -------------------------------------------------------------------
Scenario("SetClassesEvery: the first edge is the lowest value and the last is the highest, to the last bit")
	aLo = [ 0.1, 0.3, 0.001, 123.456, 1/3, 7.77, 0.7, 0.15 ]
	aHi = [ 2.7, 0.9, 0.0171, 129.456, 5/7, 31.9, 3.3, 9.45 ]
	nEnds = 0
	nRising = 0
	nChecked = 0
	for k = 1 to len(aLo)
		for n = 2 to 9
			oF = new stzGeoField([ 0, 0, 1, 1, 2, 2 ], [ aLo[k], aHi[k], aLo[k], aHi[k] ])
			oF.SetClassesEvery(n)
			aE = oF.Classes()
			nChecked++
			if aE[1] = aLo[k] and aE[n + 1] = aHi[k]  nEnds++  ok
			bUp = 1
			for e = 2 to len(aE)
				if aE[e] <= aE[e - 1]  bUp = 0  ok
			next
			nRising += bUp
		next
	next
	Then("all " + nChecked + " edge lists start at the minimum and end at the maximum exactly", nEnds, nChecked)
	Then("NEGATIVE: and every one of them still rises, with n + 1 edges", nRising, nChecked)
	oF = new stzGeoField([ 0, 0, 1, 1, 2, 2 ], [ 1, 2, 3, 5 ])
	oF.SetClassesEvery(4)
	Then("an inner edge is still the even step: 1, 2, 3, 4, 5", oF.Classes()[3], 3)
	oNone = new stzGeoField([ 0, 0, 1, 1, 2, 2 ], [ "", "", "", "" ])
	Then("NEGATIVE: a field with nothing known still refuses", RaisesOn(oNone, 4), 1)
EndScenario()

Scenario("SetClassesEvery on a constant field says why it cannot, and names SetClasses")
	oK = ConstField(0.3)
	cErr = ErrOfEvery(oK, 4)
	Then("it raises", cErr != "", 1)
	Then("it says every value is the same, not that edges must rise", Has(cErr, "no range to divide"), 1)
	Then("it names the cure, SetClasses", Has(cErr, "SetClasses"), 1)
	oRange = new stzGeoField([ 0, 0, 1, 1, 2, 2 ], [ 1, 2, 3, 4 ])
	Then("NEGATIVE: a field with a range does not raise", ErrOfEvery(oRange, 4), "")
	oK = ConstField(0.3)
	oK.SetClasses([ 0.3, 0.4 ])
	Then("NEGATIVE: and SetClasses with edges round the value still works", len(oK.Classes()), 2)
EndScenario()

# --- 5. the raster -----------------------------------------------------------------------
Scenario("A flat floor and a flat ceiling are painted: no no-data pixel inside the field")
	aCase = [ [ 0.3, 2.7, 4 ], [ 0.1, 0.9, 4 ], [ 0.3, 2.7, 3 ], [ 123.456, 129.456, 6 ],
	          [ 0.001, 0.0171, 7 ], [ 0.7, 3.3, 5 ] ]
	nHoles = 0
	for k = 1 to len(aCase)
		oF = FlatField(aCase[k][1], aCase[k][2])
		oF.SetClassesEvery(aCase[k][3])
		oF.SetRamp(:YlOrRd)
		nH = HolesOnCanvas(oF)
		nHoles += nH
		Then("lo " + aCase[k][1] + ", hi " + aCase[k][2] + ", " + aCase[k][3] +
			" classes: no pixel of the field is left as no data", nH, 0)
	next
	Then("NEGATIVE: the picture is not blank -- the classes all show (4 classes, 4 colours)",
		DistinctPainted(FlatClassed(4)), 4)
	oOut = FlatField(0.3, 2.7)
	oOut.SetClasses([ 0.3, 1.0, 1.5 ])
	oOut.SetRamp(:YlOrRd)
	nOut = HolesOnCanvas(oOut)
	Then("NEGATIVE: a value above the last edge is STILL left unpainted (the tolerance is not a licence)",
		nOut > 3000, 1)
	oBelow = FlatField(0.3, 2.7)
	oBelow.SetClasses([ 0.5, 1.5, 2.7 ])
	oBelow.SetRamp(:YlOrRd)
	Then("NEGATIVE: and so is a value below the first edge", HolesOnCanvas(oBelow) > 3000, 1)
	aT = _GeoFieldTolerantEdges([ 0, 1, 2, 3 ])
	Then("the tolerance moves the first edge down and the others up, by far less than a class",
		aT[1] < 0 and aT[2] > 1 and aT[4] > 3 and aT[2] - 1 < 0.000001, 1)
	aW = _GeoFieldTolerantEdges([ -100, 0, 0.000000000001, 1000000 ])
	Then("NEGATIVE: edges as close as the tolerance still rise after it, and stay as many",
		len(aW) = 4 and aW[1] < aW[2] and aW[2] < aW[3] and aW[3] < aW[4], 1)
EndScenario()

# --- 6. the ramp names -------------------------------------------------------------------
Scenario("SetRamp with a name that is not a ramp lists every ramp there is")
	oF = FlatField(0.3, 2.7)
	oF.SetClassesEvery(4)
	cErr = ErrOfRamp(oF, :NoSuchRamp)
	aRamps = StzGeoRamps()
	Then("it raises", cErr != "", 1)
	nIn = 0
	for r = 1 to len(aRamps)
		if Has(cErr, "" + aRamps[r][1])  nIn++  ok
	next
	Then("the table holds " + len(aRamps) + " ramps and the message names " + nIn, nIn, len(aRamps))
	Then("the table has grown past nine: thirteen ramps", len(aRamps), 13)
	# Ring folds a :Symbol to lower case, so the table and the message spell the names in lower case
	Then("viridis, magma, cividis and flow -- the four after the nine -- are all in the message",
		Has(cErr, "viridis") and Has(cErr, "magma") and Has(cErr, "cividis") and Has(cErr, "flow"), 1)
	Then("NEGATIVE: a ramp that exists does not raise", ErrOfRamp(oF, :Viridis), "")
	Then("NEGATIVE: and a ramp name in another case does not raise either", ErrOfRamp(oF, "blues"), "")
	Then("NEGATIVE: before the classes are set the other refusal stands",
		Has(ErrOfRamp(FlatField(0.3, 2.7), :Blues), "set the classes before the ramp"), 1)
EndScenario()

Summary()

# --------------------------------------------------------------------------------------
# helpers (after the scenarios: in Ring, code after a func is part of the func)

func Near(nA, nB)
	if NOT isNumber(nA)  return 0  ok
	if fabs(nA - nB) < 0.000000001  return 1  ok
	return 0

# a 5 x 5 field of one number, lon 0..4, lat 10..14
func ConstField(nV)
	aVals = []
	for i = 1 to 25  aVals + nV  next
	return new stzGeoField([ 0, 10, 1, 1, 5, 5 ], aVals)

# [ places that did not read as nNode, places that are not nodes, places read ]
func LatticeDiff(oF, nNode)
	nBad = 0
	nOff = 0
	nAll = 0
	for ix = 0 to 80
		for iy = 0 to 80
			nLon = ix * 4 / 80
			nLat = 10 + iy * 4 / 80
			nAll++
			if nLon != floor(nLon) or iy * 4 / 80 != floor(iy * 4 / 80)  nOff++  ok
			nV = oF.ValueAt(nLon, nLat)
			if nV != nNode  nBad++  ok
		next
	next
	return [ nBad, nOff, nAll ]

# the Arda window 0..5 E x 0..10 N, 11 x 11 nodes: a flat floor up to lat 3, a climb to lat 8,
# a flat ceiling above
func FlatField(nLo, nHi)
	aVals = []
	for j = 0 to 10
		if j <= 3
			nV = nLo
		but j >= 8
			nV = nHi
		else
			nV = nLo + (j - 3) * (nHi - nLo) / 5
		ok
		for i = 0 to 10  aVals + nV  next
	next
	return new stzGeoField([ 0, 0, 0.5, 1, 11, 11 ], aVals)

func FlatClassed(nN)
	oF = FlatField(0.3, 2.7)
	oF.SetClassesEvery(nN)
	oF.SetRamp(:YlOrRd)
	return oF

func ArdaProjection()
	cJson = '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"name":"Arda"},' +
		'"geometry":{"type":"Polygon","coordinates":[[[0,0],[5,0],[5,10],[0,10],[0,0]]]}}]}'
	oP = new stzGeoProjection(:Equirectangular)
	oP.FitFeaturesIn(StzGeoFeaturesFromJson(cJson), 10, 10, 110, 210, 0)
	return oP

# The field drawn through DrawOn on a canvas whose background is magenta, read back as pixels:
# the magenta pixels inside the field's box (a two pixel margin kept off its rim) are the pixels
# left as no data. If this machine has no graphics device the count is read from the raster the
# same call builds instead -- the engine's own image with the edges DrawXT hands it.
func PixelsOf(oF)
	oC = new stzCanvas(120, 220)
	oC.SetBackground("#FF00FF")
	oF.DrawOn(oC, ArdaProjection(), 10, 10, 110, 210)
	oC.Flush()
	return oC.ToPixels()

func HolesOnCanvas(oF)
	cPix = PixelsOf(oF)
	nHoles = 0
	if len(cPix) < 120 * 220 * 4  return -1  ok
	for y = 12 to 207
		for x = 12 to 107
			o = (y * 120 + x) * 4
			if ascii(cPix[o + 1]) = 255 and ascii(cPix[o + 2]) = 0 and ascii(cPix[o + 3]) = 255
				nHoles++
			ok
		next
	next
	return nHoles

# how many different colours the field paints inside its box (background excluded)
func DistinctPainted(oF)
	cPix = PixelsOf(oF)
	aSeen = []
	for y = 12 to 207 step 3
		for x = 12 to 107 step 3
			o = (y * 120 + x) * 4
			cK = "" + ascii(cPix[o + 1]) + "," + ascii(cPix[o + 2]) + "," + ascii(cPix[o + 3])
			if cK != "255,0,255" and find(aSeen, cK) = 0  aSeen + cK  ok
		next
	next
	return len(aSeen)

func ErrOfEvery(oF, n)
	cErr = ""
	try
		oF.SetClassesEvery(n)
	catch
		cErr = cCatchError
	done
	return cErr

func RaisesOn(oF, n)
	if ErrOfEvery(oF, n) != ""  return 1  ok
	return 0

func ErrOfRamp(oF, pName)
	cErr = ""
	try
		oF.SetRamp(pName)
	catch
		cErr = cCatchError
	done
	return cErr

func Has(cText, cNeedle)
	return substr(cText, cNeedle) > 0
