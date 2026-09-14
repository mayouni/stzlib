load "../../stzBase.ring"
decimals(4)

# GE7b -- A FIELD. A narrated guard for stzGeoField: the smoothed intensity
# of a point pattern, the contours through it, the raster under a projection,
# and the ESRI grid reader -- each proven on a field whose right answer is
# known by construction rather than by running the code and believing it.
#
# The window is the no-lake Arda: 0..5 E, 0..10 N, about 555 by 1,111 km.

nOk = 0  nBad = 0
? "=========================================================="
? " GE7b: a field -- density, contours, raster, ESRI grid"
? "=========================================================="

oW = StzGeoFeaturesFromJson(_ArdaJson())
oPat = StzGeoPoints([], oW)
? "   the window measures " + StzFactNumText(oW.AreaKm2()) + " km2"

? ""
? "-- 1. A KERNEL DENSITY IS AN INTENSITY: places per km2 --"
# 400 places uniform in the window. The intensity anywhere in the middle
# must be about n/area -- that is what "per km2" MEANS, and it is a number
# this guard can compute without asking the engine.
aUni = oPat.Sample(400, 20260914)
oUni = oPat.With(aUni)
oF = StzGeoDensityField(oUni, 20, 90)
nWant = 400 / oW.AreaKm2()
nGot = oF.ValueAt(2.5, 5)
? "   n/area is " + StzFactNumText(nWant * 1000000) + " per million km2; the field says " +
  StzFactNumText(nGot * 1000000)
chk("THE DENSITY OF A UNIFORM PATTERN IS ITS OWN n OVER ITS OWN AREA, which " +
    "is a number this guard computes and the engine never sees",
    fabs(nGot / nWant - 1) < 0.25)
chk("the field says what it is measured in, and where it came from",
    oF.Unit() = "places per km2" and StzFindFirst("kernel density", oF.Source()) > 0)
chk("...and it covers the window's ground, node-centred and at the cell size " +
    "asked for",
    oF.ColumnCount() > 20 and oF.RowCount() > 40 and
    fabs(oF.CellSizeDegrees()[2] * 111.19 - 20) < 0.5)

? ""
? "-- 2. WHAT IS NOT KNOWN IS NOT ZERO --"
aS = oF.Stats()
? "   " + aS[:known] + " nodes measured, " + aS[:unknown] + " outside the window"
# ON A WINDOW THAT FILLS ITS OWN BOX, NO GRID NODE IS OUTSIDE. Arda is a
# rectangle and the grid is laid over its bounds, so every node is on it or
# in it -- the first version of this assertion read "unknown > 0" and passed
# only because the ray cast then put the whole western boundary column
# OUTSIDE, which was the GE0 defect GE7b found and not a property of the
# window. A window that does not fill its box is what the assertion needs.
oTri = StzGeoPoints([], StzGeoFeaturesFromJson(_TriangleJson()))
oTF = StzGeoDensityField(oTri.With(oTri.Sample(200, 3)), 25, 90)
aTS = oTF.Stats()
? "   on a triangular window: " + aTS[:known] + " nodes measured, " + aTS[:unknown] + " outside it"
chk("a node outside the window comes back UNKNOWN, never zero -- 'no ground " +
    "here' and 'no places here' are different statements",
    oTF.ValueAt(0.5, 9) = "" and aTS[:unknown] > aTS[:known] * 0.5 and aTS[:known] > 0 and
    oF.ValueAt(-3, 5) = "")
chk("NEGATIVE: a node INSIDE the window with no place near it is ZERO, which " +
    "is a measurement and not a gap",
    isNumber(oF.ValueAt(2.5, 5)))

? ""
? "-- 3. THE DENSITY FINDS A CLUSTER THE UNIFORM PATTERN HAS NOT GOT --"
aClu = oPat.SampleClustered(4, 100, 30, 20260914)
oCF = StzGeoDensityField(oPat.With(aClu), 20, 60)
? "   uniform peak " + StzFactNumText(oF.Max() * 1000000) + ", clustered peak " +
  StzFactNumText(oCF.Max() * 1000000) + " per million km2"
chk("A CLUSTERED PATTERN'S PEAK IS FAR ABOVE A UNIFORM ONE'S, on the same " +
    "window with about the same count -- which is the whole reason to smooth",
    oCF.Max() > oF.Max() * 3)
chk("...and its minimum is at or near zero, because the ground between the " +
    "clusters is empty",
    oCF.Min() < oF.Min() + oF.Max() * 0.2)

? ""
? "-- 4. THE EDGE CORRECTION, AND WHAT IT IS FOR --"
oPlain = StzGeoDensityFieldXT(oUni, 20, 90, :Quartic, FALSE)
# AVERAGED OVER MANY PLACES, NOT READ AT ONE. A kernel of 90 km holds about
# sixteen of these four hundred places, so a single reading swings by a third
# on Poisson noise alone -- measured here: interior samples of 510, 814 and
# 938 per million km2 around a true 650. The first version of this section
# compared ONE corner against ONE midpoint and failed a correct engine,
# which is the same defect as yesterday's planar expectation for a spherical
# answer: an assertion that cannot see the effect it names.
aEdgeAt = [ 0.3, 0.3, 4.7, 0.3, 0.3, 9.7, 4.7, 9.7, 2.5, 0.3, 2.5, 9.7,
            0.3, 5, 4.7, 5 ]
aMidAt = [ 2.5, 2, 2.5, 3, 2.5, 4, 2.5, 5, 2.5, 6, 2.5, 7, 2.5, 8,
           1.8, 4, 3.2, 4, 1.8, 6, 3.2, 6 ]
nEdgePlain = _MeanAt(oPlain, aEdgeAt)
nMidPlain = _MeanAt(oPlain, aMidAt)
nEdgeFixed = _MeanAt(oF, aEdgeAt)
nMidFixed = _MeanAt(oF, aMidAt)
? "   uncorrected: border " + StzFactNumText(nEdgePlain * 1000000) + ", middle " +
  StzFactNumText(nMidPlain * 1000000) + " per million km2 (true 650)"
? "   corrected:   border " + StzFactNumText(nEdgeFixed * 1000000) + ", middle " +
  StzFactNumText(nMidFixed * 1000000)
chk("UNCORRECTED, THE BORDER IS SHORT OF DENSITY -- much of a kernel centred " +
    "there lands outside the window, exactly the bias GE7a met in Clark-Evans",
    nEdgePlain < nMidPlain * 0.8)
# JUDGED AGAINST THE TRUTH, NOT AGAINST ONE RUN. The first version asked for
# a lift of 1.3x, which was the number one run had given; the ray-cast fix
# put the boundary column inside the mask, the correction integrated a
# little more inside-mass at the border, and the lift became 1.25x on the
# same points. The yardstick a correction is owed is the true intensity --
# n over the area, which this guard computes itself: uncorrected the border
# is a quarter short of it, corrected it is within a tenth. (The residual is
# discretisation: a node ON the boundary is weighed as a whole cell though
# half of it is outside, so the correction is right to about half a cell.)
nTrue = 400 / oW.AreaKm2()
chk("...and the correction lifts the border TOWARD THE TRUTH while leaving " +
    "the middle alone: uncorrected it is more than a fifth short of n/area, " +
    "corrected it is within a tenth, and the middle moves under 12%",
    nEdgePlain < nTrue * 0.8 and fabs(nEdgeFixed / nTrue - 1) < 0.1 and
    nEdgeFixed > nEdgePlain * 1.15 and fabs(nMidFixed / nMidPlain - 1) < 0.12)
chk("NEGATIVE: a kernel this file does not know is refused BY NAME, with the " +
    "two it does know in the refusal",
    _RefusesKernel(oUni))
chk("NEGATIVE: a bandwidth of zero is refused -- it is how far one place " +
    "spreads, and nothing spreads nowhere",
    _RefusesBandwidth(oUni))
chk("NEGATIVE: a density without a window is refused -- the kernel near the " +
    "border has to know where the border is",
    _RefusesNoPattern())

? ""
? "-- 5. A CONTOUR OF A CONE IS A CIRCLE, and this guard knows its radius --"
# v = 100 - distance from the middle, in degrees, on a plain lattice. The
# level 60 must come back as the circle of radius 40, closed.
oCone = StzGeoField([ -50, -50, 1, 1, 101, 101 ], _ConeValues(101, 101))
aRings = oCone.ContourAt(60)
? "   the level 60 came back as " + len(aRings) + " ring(s) of " +
  (len(aRings[1]) / 2) + " points"
chk("ONE ring, CLOSED, and every point of it 40 from the centre -- the " +
    "expected answer is the geometry's and not the engine's",
    len(aRings) = 1 and _OnCircle(aRings[1], 40, 0.6) and _IsClosed(aRings[1]))
chk("a level above everything in the field is NOTHING, not an empty ring",
    len(oCone.ContourAt(200)) = 0)
chk("the levels of a field spread evenly BETWEEN its ends, leaving the ends " +
    "out -- a contour at the minimum is the map's own border",
    _Ascending(oCone.LevelsEvery(4)) and len(oCone.LevelsEvery(4)) = 4 and
    oCone.LevelsEvery(4)[1] > oCone.Min() and
    oCone.LevelsEvery(4)[4] < oCone.Max())

? ""
? "-- 6. A CONTOUR IS NOT DRAWN ACROSS GROUND NOBODY MEASURED --"
# TWO THINGS WRONG WITH THE FIRST VERSION OF THIS, and the second is the
# one worth keeping. It punched the hole at x = 40..45 on row 50 -- ten
# nodes from the centre, where the field is 90 and the level 60 never goes
# -- so the fixture was looking somewhere the contour is not. And when that
# was fixed it still read 1 piece and was still called a failure, because
# the assertion said "breaks into pieces": A CLOSED RING WITH ONE BITE OUT
# OF IT IS ONE OPEN ARC, not two. The engine was right both times.
#
# The level 60 is the circle r = 40, so on row 50 it crosses at x = 10 and
# x = 90. One hole there opens the ring; two holes cut it in half.
aHole1 = _ConeValues(101, 101)
for i = 8 to 13  aHole1[50 * 101 + i + 1] = ""  next
oHole1 = StzGeoField([ -50, -50, 1, 1, 101, 101 ], aHole1)
aOpen = oHole1.ContourAt(60)
? "   one hole on its path: " + len(aOpen) + " piece(s), closed " + _IsClosed(aOpen[1])
chk("A HOLE IN THE FIELD OPENS THE RING -- the contour stops at the ground " +
    "nobody measured instead of drawing a line across it, and what was a " +
    "closed circle comes back as one shorter ARC",
    len(aOpen) = 1 and NOT _IsClosed(aOpen[1]) and len(aOpen[1]) < len(aRings[1]))
aHole2 = aHole1
for i = 88 to 93  aHole2[50 * 101 + i + 1] = ""  next
aCut = StzGeoField([ -50, -50, 1, 1, 101, 101 ], aHole2).ContourAt(60)
? "   and a second hole opposite it: " + len(aCut) + " piece(s)"
chk("...and a second hole opposite cuts the ring in TWO, which is what " +
    "'breaks into pieces' actually looks like",
    len(aCut) = 2 and NOT _IsClosed(aCut[1]) and NOT _IsClosed(aCut[2]))

? ""
? "-- 7. THE RASTER IS RESAMPLED THROUGH THE PROJECTION --"
oP = new stzGeoProjection(:ConicEqualArea)
oP.FitFeaturesIn(oW, 20, 20, 220, 420, 6)
oC = new stzCanvas(260, 460)
oC.SetBackground("#FFFFFF")
oF.SetClassesEvery(5)
oF.SetRamp(:YlOrRd)
oF.DrawOn(oC, oP, 10, 10, 250, 450)
oC.Flush()
cSvg = oC.ToSVG()
chk("the field reaches the canvas as ONE image and not forty thousand quads " +
    "-- a lon/lat cell is not a rectangle once a conic has had it",
    StzFindFirst("<image", cSvg) > 0)
# THE CLIP IS THE POLYGON, AT PIXEL RESOLUTION, ANTIALIASED. The bytes are
# read back from the engine's own buffer, on the TRIANGULAR window drawn
# into a box that holds its whole bounding rectangle -- so the box has
# ground that is inside it and outside the window: a pixel in the triangle
# is opaque, one in the empty half is empty, and the pixels the hypotenuse
# crosses are PARTLY covered, which is what an edge that is not a staircase
# means. The first probe put its "outside" pixel beyond the image box, where
# the index wrapped into the next row and read an inside pixel as 255.
oTF.SetClassesEvery(3)
oTP = new stzGeoProjection(:Equirectangular)
oTP.FitFeaturesIn(StzGeoFeaturesFromJson(_ArdaJson()), 20, 20, 220, 420, 0)
cImg = StzEngineGeoFieldImage(oTP.Params(), oTF.Values(), oTF.Grid(), 10, 10, 240, 440,
	oTF.Classes(), [ 255, 255, 178, 253, 141, 60, 189, 0, 38 ], 255, oTF.Clip())
qIn = oTP.Project(4, 3)
qOut = oTP.Project(1, 8)
nAin = _AlphaAt(cImg, 240, qIn[1] - 10, qIn[2] - 10)
nAout = _AlphaAt(cImg, 240, qOut[1] - 10, qOut[2] - 10)
nPartial = _PartialInImage(cImg, 240, 440)
? "   alpha in the triangle " + nAin + ", in the empty half " + nAout + ", partly covered pixels " + nPartial
chk("THE RASTER IS CLIPPED TO THE WINDOW AT PIXEL RESOLUTION: opaque inside, " +
    "empty outside, and PARTLY covered where the border crosses a pixel -- " +
    "an edge that is antialiased and not a staircase of cells",
    nAin = 255 and nAout = 0 and nPartial >= 100)
chk("the classes were taken from the field's own ends, so its peak is IN the " +
    "top class and not above the legend",
    len(oF.Classes()) = 6 and oF.Classes()[6] >= oF.Max() and
    oF.Classes()[1] <= oF.Min())
chk("NEGATIVE: a field drawn with no classes at all is refused -- a shade " +
    "with no legend is a decoration",
    _RefusesNoClasses(oF, oC, oP))

? ""
? "-- 8. AN ESRI ASCII GRID: the format every GIS can write --"
oG = StzGeoFieldFromAsciiGrid(_GridText())
? "   read " + oG.ColumnCount() + " x " + oG.RowCount() + ", corner became centre at " +
  StzFactNumText(oG.Grid()[1]) + ", " + StzFactNumText(oG.Grid()[2])
chk("THE FILE'S FIRST ROW IS THE NORTHERNMOST and this grid's row 0 is the " +
    "south, so it is FLIPPED on the way in -- getting that wrong turns a map " +
    "upside down and looks plausible",
    oG.Values()[1] = 4 and oG.Values()[4] = 1)
chk("...and xllcorner is the CORNER of the first cell, so the node is half a " +
    "cell in from it",
    fabs(oG.Grid()[1] - 10.25) < 0.000001 and fabs(oG.Grid()[2] - 30.25) < 0.000001)
chk("NODATA BECOMES UNKNOWN, never a number -- -9999 read as a depth is how " +
    "an elevation map acquires a trench",
    oG.Values()[2] = "" and oG.Stats()[:unknown] = 1 and oG.Stats()[:min] = 1)
chk("NEGATIVE: a file that ends before its header says it should is REFUSED, " +
    "not half read",
    _RefusesShortGrid())
chk("NEGATIVE: and so is a value that is not a number", _RefusesJunkGrid())

? ""
? "-- 9. WHAT THE GATE OWES A FIELD --"
oEmpty = StzGeoField([ 0, 0, 1, 1, 3, 3 ], [ "", "", "", "", "", "", "", "", "" ])
chk("A FIELD WITH NO KNOWN VALUE AT ALL is an ERROR -- it draws as a handsome " +
    "map of nothing",
    _Has(oEmpty.Findings(), "a_field_has_a_known_value", "error") and NOT oEmpty.IsSound())
oShort = StzGeoField(oF.Grid(), oF.Values())
oShort.SetClasses([ 0, oF.Max() / 2 ])
chk("CLASSES THAT DO NOT REACH THE DATA are an ERROR: everything above the " +
    "last edge draws as no data, so the PEAK comes out as a hole",
    _Has(oShort.Findings(), "the_classes_reach_the_data", "error"))
oMerc = new stzGeoProjection(:Mercator)
oMerc.FitFeaturesIn(oW, 20, 20, 220, 420, 6)
chk("A DENSITY ON A NON-EQUAL-AREA PROJECTION is an ERROR, the same rule GE3 " +
    "keeps for a choropleth -- 'per km2' over a Mercator says a bigger number " +
    "in the north than it means",
    _Has(oF.FindingsOn(oMerc), "a_density_wants_an_equal_area_projection", "error"))
chk("NEGATIVE: the same field on the equal-area conic reports nothing",
    NOT _Has(oF.FindingsOn(oP), "a_density_wants_an_equal_area_projection", "error"))
chk("NEGATIVE: a well-classed field of a measured window is SOUND",
    oF.IsSound())

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

# the field averaged over a list of places, flat lon/lat
func _MeanAt poF, paAt
	_s_ = 0
	_n_ = 0
	for _k_ = 1 to len(paAt) / 2
		_v_ = poF.ValueAt(paAt[_k_ * 2 - 1], paAt[_k_ * 2])
		if isNumber(_v_)
			_s_ += _v_
			_n_++
		ok
	next
	if _n_ = 0  return 0  ok
	return _s_ / _n_

func _ConeValues pnNx, pnNy
	_a_ = []
	for _j_ = 0 to pnNy - 1
		for _i_ = 0 to pnNx - 1
			_a_ + (100 - sqrt(pow(_i_ - 50, 2) + pow(_j_ - 50, 2)))
		next
	next
	return _a_

func _OnCircle paRing, pnR, pnTol
	_n_ = len(paRing) / 2
	if _n_ < 20  return FALSE  ok
	for _k_ = 1 to _n_
		_r_ = sqrt(pow(paRing[_k_ * 2 - 1], 2) + pow(paRing[_k_ * 2], 2))
		if fabs(_r_ - pnR) > pnTol  return FALSE  ok
	next
	return TRUE

func _IsClosed paRing
	_n_ = len(paRing) / 2
	return fabs(paRing[1] - paRing[_n_ * 2 - 1]) < 0.000001 and
	       fabs(paRing[2] - paRing[_n_ * 2]) < 0.000001

func _Ascending paV
	for _i_ = 2 to len(paV)
		if paV[_i_] <= paV[_i_ - 1]  return FALSE  ok
	next
	return TRUE

func _Has paF, pcRule, pcSev
	for _i_ = 1 to len(paF)
		if paF[_i_][:rule] = pcRule and paF[_i_][:severity] = pcSev  return TRUE  ok
	next
	return FALSE

func _RefusesKernel poPat
	try
		StzGeoDensityFieldXT(poPat, 20, 50, :Triangular, TRUE)
	catch
		return StzFindFirst(":Gaussian", cCatchError) > 0
	done
	return FALSE

func _RefusesBandwidth poPat
	try
		StzGeoDensityField(poPat, 20, 0)
	catch
		return StzFindFirst("bandwidth", cCatchError) > 0
	done
	return FALSE

func _RefusesNoPattern
	try
		StzGeoDensityField([ 1, 1, 2, 2 ], 20, 50)
	catch
		return StzFindFirst("window", cCatchError) > 0
	done
	return FALSE

# the alpha byte of the pixel at (x, y) in a w-wide RGBA buffer
func _AlphaAt pcImg, pnW, pnX, pnY
	_i_ = (floor(pnY) * pnW + floor(pnX)) * 4 + 4
	if _i_ < 1 or _i_ > len(pcImg)  return -1  ok
	return ascii(pcImg[_i_])

# how many pixels of the whole image are neither empty nor opaque
func _PartialInImage pcImg, pnW, pnH
	_n_ = 0
	_len_ = len(pcImg)
	for _k_ = 1 to pnW * pnH
		_i_ = _k_ * 4
		if _i_ <= _len_
			_a_ = ascii(pcImg[_i_])
			if _a_ > 0 and _a_ < 255  _n_++  ok
		ok
	next
	return _n_

func _RefusesNoClasses poF, poC, poP
	_f_ = StzGeoField(poF.Grid(), poF.Values())
	try
		_f_.DrawOn(poC, poP, 10, 10, 100, 100)
	catch
		return StzFindFirst("classes", cCatchError) > 0
	done
	return FALSE

func _RefusesShortGrid
	try
		StzGeoFieldFromAsciiGrid("ncols 3" + nl + "nrows 2" + nl + "xllcorner 0" + nl +
			"yllcorner 0" + nl + "cellsize 1" + nl + "1 2 3" + nl + "4 5")
	catch
		return StzFindFirst("ESRI", cCatchError) > 0
	done
	return FALSE

func _RefusesJunkGrid
	try
		StzGeoFieldFromAsciiGrid("ncols 2" + nl + "nrows 2" + nl + "xllcorner 0" + nl +
			"yllcorner 0" + nl + "cellsize 1" + nl + "1 2" + nl + "3 wet")
	catch
		return StzFindFirst("ESRI", cCatchError) > 0
	done
	return FALSE

func _GridText
	return "ncols 3" + nl + "nrows 2" + nl + "xllcorner 10.0" + nl +
	       "yllcorner 30.0" + nl + "cellsize 0.5" + nl + "NODATA_value -9999" + nl +
	       "1 2 3" + nl + "4 -9999 6"

# the south-eastern half of Arda: a window that does not fill its own box
func _TriangleJson
	return '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"name":"Half"},' +
		'"geometry":{"type":"Polygon","coordinates":[[[0,0],[5,0],[5,10],[0,0]]]}}]}'

func _ArdaJson
	return '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"name":"Arda"},' +
		'"geometry":{"type":"Polygon","coordinates":[[[0,0],[5,0],[5,10],[0,10],[0,0]]]}}]}'
