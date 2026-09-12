load "../../stzBase.ring"
decimals(4)

# GE0 -- THE SPHERE. A narrated guard for the projection engine: every
# assertion below is a PROPERTY a map reader could check with a ruler, and
# each positive has the negative that keeps it honest. No atlas is read;
# nothing here needs a device.

nOk = 0  nBad = 0

? "=========================================================="
? " GE0: the sphere -- projections, rotation, cutting, fitting"
? "=========================================================="

? ""
? "-- 1. The engine knows sixteen ways to flatten a sphere, by name --"
aK = StzGeoProjectionKinds()
chk("sixteen projections, each with a name", len(aK) = 16 and aK[1] = "Equirectangular" and aK[16] = "EqualEarth")
chk("a projection is asked for by name, in any case", (new stzGeoProjection(:mercator)).Name() = "Mercator")
chk("NEGATIVE: a projection the engine does not know is refused BY NAME", _Refuses(:Peters))

? ""
? "-- 2. Every projection inverts its own forward: what is under the pixel --"
bAll = TRUE
for i = 1 to len(aK)
	oP = new stzGeoProjection(aK[i])
	oP.ScaleQ(200).Translate([ 400, 300 ])
	q = oP.Project(12.5, 41.9)
	if len(q) < 2  bAll = FALSE  loop  ok
	g = oP.Invert(q[1], q[2])
	if len(g) < 2 or fabs(g[1] - 12.5) > 0.0001 or fabs(g[2] - 41.9) > 0.0001  bAll = FALSE  ok
next
chk("Rome goes to a pixel and comes back as Rome on all sixteen", bAll)
oO = new stzGeoProjection(:Orthographic)
oO.RotateQ([ -30, -40, 10 ]).ScaleQ(250).Translate([ 300, 300 ])
q = oO.Project(2.35, 48.85)
g = oO.Invert(q[1], q[2])
chk("...and on a sphere turned three ways at once", fabs(g[1] - 2.35) < 0.0001 and fabs(g[2] - 48.85) < 0.0001)

? ""
? "-- 3. North is up, east is right -- the axis the choropleth learnt the hard way --"
oE = new stzGeoProjection(:Equirectangular)
oE.ScaleQ(100).Translate([ 500, 300 ])
qN = oE.Project(0, 45)
qS = oE.Project(0, -45)
qW = oE.Project(-45, 0)
qEa = oE.Project(45, 0)
chk("a northern point draws ABOVE a southern one (smaller y), an eastern one to the RIGHT",
    qN[2] < qS[2] and qEa[1] > qW[1])

? ""
? "-- 4. The far side of a globe is not drawn, and the horizon is exact --"
oO2 = new stzGeoProjection(:Orthographic)
oO2.FitToSphere(600, 600, 0)
chk("a point on the far side answers [] rather than a wrong pixel", len(oO2.Project(170, 0)) = 0)
chk("NEGATIVE: a point on the near side answers a pixel", len(oO2.Project(10, 0)) = 2)
aPcs = oO2.Line([ 0, 0, 180, 0 ])
chk("a line from the centre to the far side is drawn as ONE piece that stops at the horizon",
    len(aPcs) = 1 and _EndsOnHorizon(aPcs[1], 300, 300, 300))
aPcs2 = oO2.Line([ -170, 0, 170, 0 ])
chk("NEGATIVE: a line that begins and ends behind the globe draws NOTHING", len(aPcs2) = 0)

? ""
? "-- 5. The seam of a flat map cuts a line in two, exactly at the edge --"
oN = new stzGeoProjection(:NaturalEarth)
oN.FitToSphere(800, 400, 0)
aCut = oN.Line([ 170, 10, -170, 10 ])
chk("a short hop across the antimeridian comes back as TWO pieces", len(aCut) = 2)
chk("...and each piece ends at the map's edge, not somewhere in the middle",
    _NearEdge(aCut[1], oN) and _NearEdge(aCut[2], oN))
aWhole = oN.Line([ -10, 10, 10, 10 ])
chk("NEGATIVE: the same hop away from the seam is one piece", len(aWhole) = 1)

? ""
? "-- 6. Two points make a GREAT CIRCLE, and a great circle is a curve on the paper --"
# A line is given as two points and drawn as the shortest path between
# them on the sphere. That path is a curve on almost every projection, so
# the engine RESAMPLES it: subdivides until the drawn midpoint sits within
# the precision of the chord. The one line that stays straight everywhere
# is the equator on a cylindrical, which is the negative.
oC = new stzGeoProjection(:ConicEqualArea)
oC.ParallelsQ([ 30, 50 ]).FitToSphere(800, 600, 0)
aPar = oC.Line([ -60, 40, 60, 40 ])
chk("a line given as two points comes back as many, bent into the great circle's arc",
    len(aPar) = 1 and len(aPar[1]) / 2 > 4 and _Bows(aPar[1]))
oQ = new stzGeoProjection(:Equirectangular)
oQ.FitToSphere(800, 400, 0)
aGc = oQ.Line([ -60, 40, 60, 40 ])
chk("...even on Equirectangular, where the same two points are joined by an arc that " +
    "rises north of both -- the parallel through them is NOT the shortest path",
    len(aGc) = 1 and len(aGc[1]) / 2 > 8 and _Bows(aGc[1]))
aEq = oQ.Line([ -60, 0, 60, 0 ])
chk("NEGATIVE: the equator on Equirectangular is straight and stays two points",
    len(aEq) = 1 and len(aEq[1]) = 4)
oQ.Precision(50)
aCoarse = oQ.Line([ -60, 40, 60, 40 ])
chk("NEGATIVE: with a precision of fifty pixels the same arc is drawn with fewer points -- " +
    "the resampling is the precision's, not a constant",
    len(aCoarse[1]) < len(aGc[1]))

? ""
? "-- 7. Equal-area means equal area; conformal means round stays round --"
aBoxLow = _DenseBox(0, 0, 10, 10)
aBoxHigh = _DenseBox(0, 50, 10, 70)
oM = new stzGeoProjection(:Mollweide)
oM.FitToSphere(800, 400, 0)
nA1 = _PolyArea(oM.Ring(aBoxLow)[1])
nA2 = _PolyArea(oM.Ring(aBoxHigh)[1])
? "   two boxes of equal true area draw " + nA1 + " and " + nA2 + " px2 on Mollweide"
chk("on an equal-area projection two boxes of equal true area draw with equal area",
    oM.IsEqualArea() and fabs(nA1 - nA2) / nA1 < 0.02)
oMe = new stzGeoProjection(:Mercator)
oMe.FitToSphere(800, 800, 0)
nB1 = _PolyArea(oMe.Ring(aBoxLow)[1])
nB2 = _PolyArea(oMe.Ring(aBoxHigh)[1])
chk("NEGATIVE: on Mercator the northern box draws far larger -- the lie the projection tells",
    NOT oMe.IsEqualArea() and nB2 / nB1 > 2)
aCirc = StzGeoCircle(20, 55, 5, 72)
aOnMe = oMe.Ring(aCirc)[1]
chk("on a conformal projection a small circle stays ROUND: its width and height agree",
    oMe.IsConformal() and _Roundness(aOnMe) > 0.95)
oCy = new stzGeoProjection(:CylindricalEqualArea)
oCy.FitToSphere(800, 400, 0)
chk("NEGATIVE: on an equal-area cylindrical the same circle is squashed flat",
    _Roundness(oCy.Ring(aCirc)[1]) < 0.6)

? ""
? "-- 8. Distance and direction on the sphere itself --"
nKm = StzGeoDistanceKm(-0.13, 51.51, 2.35, 48.85)
chk("London to Paris is about 344 km by the great circle", nKm > 340 and nKm < 348)
aMid = StzGeoInterpolate(0, 0, 90, 0, 0.5)
chk("halfway along the equator from 0 to 90 is 45", fabs(aMid[1] - 45) < 0.0001 and fabs(aMid[2]) < 0.0001)
aArc = StzGeoArc(-74, 40.7, 139.7, 35.7, 32)
nMaxLat = 0
for i = 2 to len(aArc) step 2
	if aArc[i] > nMaxLat  nMaxLat = aArc[i]  ok
next
chk("the great circle New York to Tokyo passes far north of both -- the route bends over the pole",
    nMaxLat > 60)
nOct = fabs(StzEngineGeoRingArea([ 0, 0, 90, 0, 0, 90, 0, 0 ]))
chk("the area of an octant is an eighth of the sphere", fabs(nOct - 3.141592653589793 / 2) < 0.000001)

? ""
? "-- 9. Fitting: the whole sphere in a box, or the places given --"
oF = new stzGeoProjection(:EqualEarth)
oF.FitToSphere(800, 400, 10)
aOut = oF.Outline()
aBox = _Bounds(aOut[1])
chk("the fitted outline sits inside the box with the padding asked for",
    aBox[1] >= 9.9 and aBox[3] <= 790.1 and aBox[2] >= 9.9 and aBox[4] <= 390.1)
chk("...and touches the box on its wider axis, so the fit is tight, not merely inside",
    fabs(aBox[3] - aBox[1] - 780) < 1 or fabs(aBox[4] - aBox[2] - 380) < 1)
oCC = new stzGeoProjection(:ConicConformal)
oCC.ParallelsQ([ 40, 60 ]).FitToPoints([ -9, 38, 30, 60, 25, 38, -20, 64 ], 600, 400, 20)
bIn = TRUE
aFour = [ [ -9, 38 ], [ 30, 60 ], [ 25, 38 ], [ -20, 64 ] ]
for i = 1 to len(aFour)
	q = oCC.Project(aFour[i][1], aFour[i][2])
	if len(q) < 2 or q[1] < 19 or q[1] > 581 or q[2] < 19 or q[2] > 381  bIn = FALSE  ok
next
chk("fitted to four places, all four land inside the box", bIn)

? ""
? "-- 10. A map names its projection -- it asserts nothing it cannot say --"
chk("the caption carries the name, the parallels and the rotation",
    StzFindFirst("ConicConformal", oCC.Caption()) > 0 and StzFindFirst("40N", oCC.Caption()) > 0 and
    StzFindFirst("rotated", oO.Caption()) > 0)

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

func _Refuses pKind
	_b_ = FALSE
	try
		new stzGeoProjection(pKind)
	catch
		_b_ = TRUE
	done
	return _b_

# the piece's last point lies on the circle of radius r about (cx, cy)
func _EndsOnHorizon paXY, pnCx, pnCy, pnR
	_n_ = len(paXY)
	_x_ = paXY[_n_ - 1] - pnCx
	_y_ = paXY[_n_] - pnCy
	return fabs(sqrt(_x_ * _x_ + _y_ * _y_) - pnR) < 1.5

# one end of the piece lies within a few px of the projected outline
func _NearEdge paXY, poP
	_o_ = poP.Outline()[1]
	_n_ = len(paXY)
	return _Dist(paXY[1], paXY[2], _o_) < 3 or _Dist(paXY[_n_ - 1], paXY[_n_], _o_) < 3

func _Dist pnX, pnY, paPoly
	_best_ = 1000000
	for _i_ = 1 to len(paPoly) - 1 step 2
		_d_ = sqrt(pow(paPoly[_i_] - pnX, 2) + pow(paPoly[_i_ + 1] - pnY, 2))
		if _d_ < _best_  _best_ = _d_  ok
	next
	return _best_

# the middle of the polyline is off the chord between its ends
func _Bows paXY
	_n_ = len(paXY) / 2
	_m_ = floor(_n_ / 2) + 1
	_cx_ = (paXY[1] + paXY[_n_ * 2 - 1]) / 2
	_cy_ = (paXY[2] + paXY[_n_ * 2]) / 2
	return sqrt(pow(paXY[_m_ * 2 - 1] - _cx_, 2) + pow(paXY[_m_ * 2] - _cy_, 2)) > 5

func _DenseBox pnLon0, pnLat0, pnLon1, pnLat1
	_a_ = []
	for _i_ = 0 to 20
		_a_ + (pnLon0 + (pnLon1 - pnLon0) * _i_ / 20)  _a_ + pnLat0
	next
	for _i_ = 0 to 20
		_a_ + (pnLon1 - (pnLon1 - pnLon0) * _i_ / 20)  _a_ + pnLat1
	next
	_a_ + pnLon0  _a_ + pnLat0
	return _a_

func _PolyArea paXY
	_n_ = len(paXY) / 2
	_s_ = 0
	for _i_ = 1 to _n_
		_j_ = _i_ % _n_ + 1
		_s_ += paXY[_i_ * 2 - 1] * paXY[_j_ * 2] - paXY[_j_ * 2 - 1] * paXY[_i_ * 2]
	next
	return fabs(_s_) / 2

func _Bounds paXY
	_x0_ = 1000000  _y0_ = 1000000  _x1_ = -1000000  _y1_ = -1000000
	for _i_ = 1 to len(paXY) - 1 step 2
		if paXY[_i_] < _x0_  _x0_ = paXY[_i_]  ok
		if paXY[_i_] > _x1_  _x1_ = paXY[_i_]  ok
		if paXY[_i_ + 1] < _y0_  _y0_ = paXY[_i_ + 1]  ok
		if paXY[_i_ + 1] > _y1_  _y1_ = paXY[_i_ + 1]  ok
	next
	return [ _x0_, _y0_, _x1_, _y1_ ]

# height over width of the bounding box, 1 for a round shape
func _Roundness paXY
	_b_ = _Bounds(paXY)
	_w_ = _b_[3] - _b_[1]
	_h_ = _b_[4] - _b_[2]
	if _w_ = 0 or _h_ = 0  return 0  ok
	if _h_ > _w_  return _w_ / _h_  ok
	return _h_ / _w_
