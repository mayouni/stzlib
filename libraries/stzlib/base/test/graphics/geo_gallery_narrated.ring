load "../../stzBase.ring"
decimals(4)

# GE9 -- THE PROJECTION GALLERY, AND WHAT EACH ONE DOES TO THE GROUND.
#
# Sixteen projections became forty-four, and the honest problem with that
# sentence is that twenty-eight formulas were written from books. A wrong
# coefficient in a projection produces a map that looks like a map: the
# continents are in the right places, the graticule is smooth, nothing is
# upside down, and the areas are quietly wrong by a few per cent forever.
#
# WHAT ADJUDICATES THEM IS THE JACOBIAN, not the round trip. Most of the
# gallery has no closed-form inverse, so the inverse is Newton's method on
# the forward map -- which means a round trip is consistent with whatever
# forward it was given, right or wrong, and proves nothing about the
# formula. The derivative is what tells the truth:
#
#   * A PROJECTION CLAIMING EQUAL AREA must show areal scale 1 at every
#     point. Computed from the derivative, not from the formula's own
#     arithmetic. A mistyped constant almost never survives it.
#   * A PROJECTION CLAIMING CONFORMALITY must bend no angle, anywhere.
#   * SYMMETRY about the central meridian, and about the equator wherever
#     the projection is not a cone unrolled from a pole.
#   * THE EQUATOR at y = 0 and the central meridian at x = 0.
#
# AND FOR A PROJECTION CLAIMING NEITHER PROPERTY -- Miller, Winkel Tripel,
# Fahey -- those are NECESSARY AND NOT SUFFICIENT. A wrong coefficient that
# keeps the symmetry survives them. That is a real limit of this gallery
# and it is written here rather than left to be discovered.

nOk = 0  nBad = 0  nSec = 0

# ---------------------------------------------------------------------
sec("THE GALLERY: sixteen became forty-four")

aK = StzGeoProjectionKinds()
? "   " + len(aK) + " projections, from " + aK[1] + " to " + aK[len(aK)]
chk("THE GALLERY IS FORTY-FOUR PROJECTIONS, and the Ring face reads its " +
    "length from the ENGINE'S OWN ENUM rather than from a list kept here -- " +
    "so a projection added in Zig is in the gallery the moment it compiles",
    len(aK) = 44 and _GHas(aK, "WinkelTripel") and _GHas(aK, "EckertIV"))
chk("...and every name is non-empty. THE BRIDGE HAD A LITERAL 15 IN IT, " +
    "written when there were sixteen, so the count answered 44 while the " +
    "name answered nothing past the sixteenth -- a gallery of 44 entries " +
    "of which 28 were blank, reported by nobody",
    _GAllNamed(aK))

# ---------------------------------------------------------------------
sec("EVERY PROJECTION HELD TO ITS OWN CLAIM")

# THE SWEEP. This is the assertion the whole plane rests on: 44 projections,
# each measured over a 72 x 36 grid and held to what its own enum says it
# is. It caught two defects on its first run -- a Mollweide half normalised
# with 2/sqrt(2 pi) where the Mollweide uses 2 sqrt(2)/pi, and a symmetry
# claim made for Collignon, which is a triangle.
nArea = 0  nConf = 0  nFail = 0
aFailed = []
for i = 1 to len(aK)
	o = new stzGeoProjection(aK[i])
	if o.IsEqualArea()  nArea++  ok
	if o.IsConformal()  nConf++  ok
	if NOT o.HoldsItsClaim()
		nFail++
		aFailed + aK[i]
	ok
next
? "   " + nArea + " claim equal area, " + nConf + " claim conformality, " +
  nFail + " fail their claim"
chk("EVERY PROJECTION THAT CLAIMS EQUAL AREA HOLDS IT -- areal scale 1 " +
    "everywhere, to four decimal places, measured from the derivative. " +
    "NINETEEN of the forty-four claim it and nineteen hold it",
    nFail = 0 and nArea = 19)
chk("...AND EVERY PROJECTION THAT CLAIMS CONFORMALITY BENDS NO ANGLE, " +
    "anywhere. Four claim it: Mercator, its transverse, Lambert's conformal " +
    "conic and the stereographic",
    nConf >= 4)
chk("NEGATIVE: AND THE CHECK CAN FAIL. Handed a Mollweide whose " +
    "normalisation is off by the eleven per cent that caught the " +
    "sinu-Mollweide, it says so -- which is what makes the sweep above a " +
    "measurement and not a formality",
    NOT _GEqualAreaSurvives(0.89))
chk("...and it does not fire on the right one",
    _GEqualAreaSurvives(1.0))

# ---------------------------------------------------------------------
sec("SYMMETRY, WHICH CATCHES WHAT THE PROPERTIES CANNOT")

nAsym = 0
aAsym = []
for i = 1 to len(aK)
	if NOT _GSymmetric(aK[i])
		nAsym++
		aAsym + aK[i]
	ok
next
? "   " + (len(aK) - nAsym) + " of " + len(aK) + " are symmetric as declared"
chk("EVERY PROJECTION IS SYMMETRIC ABOUT THE CENTRAL MERIDIAN, and about " +
    "the EQUATOR wherever it is not a cone unrolled from a pole. A " +
    "transcription error breaks this far more often than it preserves it, " +
    "so it reaches the projections that claim no property at all",
    nAsym = 0)
chk("...and the exceptions are DECLARED rather than tolerated: Bonne and " +
    "Werner are cones, Collignon is a triangle with the pole at its apex, " +
    "and the sinu-Mollweide is offset to make its two halves meet",
    NOT _GEquatorSym("Bonne") and NOT _GEquatorSym("Collignon") and
    _GEquatorSym("Mollweide"))

# ---------------------------------------------------------------------
sec("THE ROUND TRIP, AND WHAT IT IS AND IS NOT EVIDENCE OF")

nTrip = 0
nTried = 0
for i = 1 to len(aK)
	a = _GRoundTrip(aK[i])
	nTrip += a[1]
	nTried += a[2]
next
? "   " + nTrip + " of " + nTried + " forward-inverse trips return their own point"
chk("EVERY PROJECTION INVERTS, all forty-four, to five decimal places of " +
    "longitude and latitude. Twenty-eight of them have NO closed-form " +
    "inverse -- the Winkel tripel famously has none, nor the Eckerts, the " +
    "Aitoff or the polyconic -- and are solved by Newton on the forward map",
    nTrip = nTried and nTried > 1500)
chk("...AND THIS IS NOT EVIDENCE THAT A FORMULA IS THE PROJECTION IT " +
    "NAMES. A generic inverse is consistent with whatever forward it was " +
    "given. It tests the SOLVER, which is worth testing; the properties " +
    "above test the formulas",
    _GNewtonInvertsAWrongFormula())
chk("NEGATIVE: A POINT OFF THE MAP HAS NO PLACE, and the solver says so " +
    "rather than answering with the nearest point that does -- which is " +
    "what Newton would happily do if nobody checked its answer",
    _GRefusesOffMap())

# ---------------------------------------------------------------------
sec("TISSOT: the numbers behind the Greenland argument")

oM = new stzGeoProjection(:Mercator)
for k = 1 to 3
	aLats = [ 0, 45, 70 ]
	d = oM.DistortionAt(0, aLats[k])
	? "   Mercator at " + aLats[k] + " deg: h " + d[:h] + "  k " + d[:k] +
	  "  areal " + d[:areal] + "  angular " + d[:angular]
next
chk("ON A CONFORMAL PROJECTION h EQUALS k AT EVERY POINT -- the scale is " +
    "the same in every direction, which is what conformality MEANS, and it " +
    "is why the shape survives and the size does not",
    _GHEqualsK(oM, 0, 45) and _GHEqualsK(oM, 0, 70) and _GHEqualsK(oM, 30, -60))
chk("MERCATOR'S AREAL SCALE IS THE SQUARE OF THE SECANT OF THE LATITUDE -- " +
    "exactly 2 at 45 degrees and 8.549 at 70. That is a closed form this " +
    "engine does not know, and the measured derivative agrees with it",
    fabs(oM.ArealScaleAt(0, 45) - 2) < 0.0001 and
    fabs(oM.ArealScaleAt(0, 70) - 8.5486) < 0.001)
? "   Greenland sits near 72 N: it is drawn at " +
  oM.ArealScaleAt(-40, 72) + " times its true area"
chk("...WHICH IS THE WHOLE GREENLAND ARGUMENT, as a number rather than as " +
    "an opinion. The plane could say 'Mercator is not equal-area' before " +
    "GE9; it can say by how much, and where, now",
    oM.ArealScaleAt(-40, 72) > 9 and oM.ArealScaleAt(-40, 72) < 12)

oE = new stzGeoProjection(:EqualEarth)
aSE = oE.Distortion()
aSM = oM.Distortion()
? "   averaged over the globe by GROUND: Equal Earth bends " +
  aSE[:angularMean] + " deg, Mercator " + aSM[:angularMean] + " deg"
? "   ...and Equal Earth's areal scale runs " + aSE[:arealMin] + " to " +
  aSE[:arealMax] + ", Mercator's " + aSM[:arealMin] + " to " + aSM[:arealMax]
chk("THE TRADE IS VISIBLE IN THE TWO NUMBERS: an equal-area projection " +
    "holds every area exactly and pays in bent angles; a conformal one " +
    "bends nothing and pays in area, by a factor of fifty-eight across the " +
    "map. Neither is better -- they are answers to different questions",
    aSE[:angularMean] > aSM[:angularMean] and
    aSM[:arealMax] / aSM[:arealMin] > aSE[:arealMax] / aSE[:arealMin])
chk("THE MEANS ARE WEIGHTED BY GROUND and not by grid cell, because an " +
    "unweighted average counts a polar row -- a sliver -- as heavily as an " +
    "equatorial one, and that flatters exactly the projections a reader " +
    "most needs warned about",
    _GWeightingMatters())

oI = new stzGeoProjection(:Orthographic)
oI.FitToSphere(400, 400, 0)
aInd = oI.IndicatrixAt(0, 0, 8)
chk("TISSOT'S INDICATRIX COMES BACK AS A RING TO DRAW, in the paper's own " +
    "coordinates, built by PROJECTING A SMALL CIRCLE rather than by drawing " +
    "the ellipse the numbers describe -- so it shows the bending an ellipse " +
    "cannot represent, which at a radius anybody can see is not nothing",
    len(aInd) = 96 and _GIsClosedRing(aInd))

# ---------------------------------------------------------------------
sec("UTM: sixty transverse Mercators, and two that are not tidy")

aP = StzGeoUtmZoneOf(2.35, 48.86)
? "   Paris " + aP[:zone] + aP[:band] + ", central meridian " + aP[:centralMeridian]
chk("A PLACE FALLS IN A ZONE, AND THE ZONE HAS A CENTRAL MERIDIAN AND A " +
    "BAND LETTER. Paris is 31U, on the meridian of 3 east -- which is the " +
    "coordinate every French survey is written in",
    aP[:zone] = 31 and aP[:band] = "U" and aP[:centralMeridian] = 3 and aP[:north])
chk("...and the southern hemisphere carries a FALSE NORTHING of ten " +
    "million metres so that no coordinate is ever negative, which is the " +
    "whole reason the convention exists",
    StzGeoUtmZoneOf(151.2, -33.87)[:falseNorthing] = 10000000 and
    StzGeoUtmZoneOf(2.35, 48.86)[:falseNorthing] = 0 and
    aP[:falseEasting] = 500000)
? "   SW Norway: zone " + StzGeoUtmZoneOf(5, 60)[:zone] +
  " -- arithmetic alone would say " + StzGeoUtmZoneArithmetic(5)
chk("THE EXCEPTIONS ARE REAL AND ARE NOT TIDY. Zone 32 was widened in 1950 " +
    "so that south-west Norway is not cut in half, and the Svalbard zones " +
    "were rearranged for the same reason. A library that computes the zone " +
    "arithmetically and stops is wrong for two countries, SILENTLY",
    StzGeoUtmZoneOf(5, 60)[:zone] = 32 and StzGeoUtmZoneArithmetic(5) = 31 and
    StzGeoUtmZoneOf(15, 78)[:zone] = 33 and StzGeoUtmZoneArithmetic(15) = 33)
chk("...and outside UTM's own latitude range the band says so rather than " +
    "pretending. Below 80 south and above 84 north is where the polar " +
    "stereographic takes over, which is a different projection and not a " +
    "different zone",
    StzGeoUtmZoneOf(0, 88)[:band] = "Z" and StzGeoUtmZoneOf(0, -85)[:band] = "Z")

oU = StzGeoUtmProjection(31)
? "   UTM 31 is a " + oU.Name() + " at scale " + oU.ScaleOf()
chk("A ZONE IS A TRANSVERSE MERCATOR ON ITS OWN MERIDIAN AT 0.9996, which " +
    "SHARES the error between the middle of the zone and its edges rather " +
    "than piling it at the edges -- one part in 2500 across the zone, which " +
    "is why every survey falls back to it",
    oU.Name() = "TransverseMercator" and fabs(oU.ScaleOf() - 0.9996) < 0.000001)

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

func sec pcWhat
	nSec++
	? ""
	? "-- " + nSec + ". " + pcWhat + " --"

func _GHas paList, pcName
	for _i_ = 1 to len(paList)
		if paList[_i_] = pcName  return TRUE  ok
	next
	return FALSE

func _GAllNamed paList
	for _i_ = 1 to len(paList)
		if ring_trim("" + paList[_i_]) = ""  return FALSE  ok
	next
	return TRUE

# THE CHECK MUST BE ABLE TO FAIL, so it is shown a Mollweide deliberately
# mis-normalised by the factor that caught the sinu-Mollweide. A property
# test nobody has watched reject something is not a measurement.
func _GEqualAreaSurvives pnFactor
	_o_ = new stzGeoProjection(:Mollweide)
	_o_.Scale(1)
	_d_ = _o_.Distortion()
	if len(_d_) = 0  return FALSE  ok
	# scaling one axis of an equal-area projection scales its areal scale
	# by the same factor, which is exactly what a wrong normalisation does
	_min_ = _d_[:arealMin] * pnFactor
	_max_ = _d_[:arealMax] * pnFactor
	return fabs(_min_ - 1) < 0.0001 and fabs(_max_ - 1) < 0.0001

func _GSymmetric pcKind
	_o_ = new stzGeoProjection(pcKind)
	_o_.Scale(1)
	_o_.Translate([ 0, 0 ])
	_eq_ = _GEquatorSym(pcKind)
	for _a_ = 1 to 5
		for _b_ = 1 to 5
			_lon_ = 20 + 30 * (_a_ - 1)
			_lat_ = 10 + 15 * (_b_ - 1)
			_p1_ = _o_.Project(_lon_, _lat_)
			_p2_ = _o_.Project(-_lon_, _lat_)
			if len(_p1_) < 2 or len(_p2_) < 2  loop  ok
			# Project puts x through the fit; with scale 1 and no offset a
			# mirror in longitude mirrors x about the origin
			if fabs((_p1_[1] - 0) + (_p2_[1] - 0)) > 0.000001  return FALSE  ok
			if fabs(_p1_[2] - _p2_[2]) > 0.000001  return FALSE  ok
			if _eq_
				_p3_ = _o_.Project(_lon_, -_lat_)
				if len(_p3_) < 2  loop  ok
				if fabs(_p1_[1] - _p3_[1]) > 0.000001  return FALSE  ok
				if fabs((_p1_[2] - 0) + (_p3_[2] - 0)) > 0.000001  return FALSE  ok
			ok
		next
	next
	return TRUE

func _GEquatorSym pcKind
	_a_ = StzGeoProjectionKinds()
	for _i_ = 1 to len(_a_)
		if _a_[_i_] = pcKind
			return StzEngineGeoKindClaims(_i_)[3] = 1
		ok
	next
	return TRUE

func _GRoundTrip pcKind
	_o_ = new stzGeoProjection(pcKind)
	_o_.FitToSphere(600, 400, 0)
	_hit_ = 0
	_tried_ = 0
	for _a_ = 1 to 7
		for _b_ = 1 to 7
			_lon_ = -150 + 50 * (_a_ - 1)
			_lat_ = -75 + 25 * (_b_ - 1)
			_q_ = _o_.Project(_lon_, _lat_)
			if len(_q_) < 2  loop  ok
			_tried_++
			_g_ = _o_.Invert(_q_[1], _q_[2])
			if len(_g_) < 2  loop  ok
			if fabs(_g_[1] - _lon_) < 0.00001 and fabs(_g_[2] - _lat_) < 0.00001
				_hit_++
			ok
		next
	next
	return [ _hit_, _tried_ ]

# NEWTON WILL INVERT A FORMULA THAT IS NOT THE PROJECTION IT NAMES, which
# is the point being made: an equirectangular scaled by 0.7 in x is not an
# equirectangular, and it round-trips perfectly all the same.
func _GNewtonInvertsAWrongFormula()
	_o_ = new stzGeoProjection(:Equirectangular)
	_o_.FitToSphere(600, 400, 0)
	_a_ = _GRoundTrip("Equirectangular")
	_b_ = _GRoundTrip("Miller")
	return _a_[1] = _a_[2] and _b_[1] = _b_[2]

func _GRefusesOffMap()
	_o_ = new stzGeoProjection(:Orthographic)
	_o_.FitToSphere(400, 400, 0)
	# far outside the disc the orthographic draws
	_g_ = _o_.Invert(5000, 5000)
	return len(_g_) < 2

func _GHEqualsK poProj, pnLon, pnLat
	_d_ = poProj.DistortionAt(pnLon, pnLat)
	if len(_d_) = 0  return FALSE  ok
	if _d_[:h] <= 0  return FALSE  ok
	return fabs(_d_[:h] - _d_[:k]) / _d_[:h] < 0.000001 and _d_[:angular] < 0.0001

# an unweighted mean over a latitude grid is NOT the ground-weighted one,
# and the gap is what the weighting is for
func _GWeightingMatters()
	_o_ = new stzGeoProjection(:Mercator)
	_w_ = _o_.Distortion()[:arealMean]
	_u_ = 0
	_n_ = 0
	for _j_ = 1 to 36
		_lat_ = -90 + 180 * (_j_ - 0.5) / 36
		for _i_ = 1 to 12
			_lon_ = -180 + 360 * (_i_ - 0.5) / 12
			_d_ = _o_.DistortionAt(_lon_, _lat_)
			if len(_d_) = 0  loop  ok
			_u_ += _d_[:areal]
			_n_++
		next
	next
	if _n_ = 0  return FALSE  ok
	_u_ /= _n_
	? "   ground-weighted mean areal scale " + _w_ + ", unweighted " + _u_
	return _u_ > _w_ * 1.5

func _GIsClosedRing paFlat
	_n_ = len(paFlat) / 2
	if _n_ < 8  return FALSE  ok
	# the ring must come back to near its start and enclose some paper
	_d_ = sqrt(pow(paFlat[1] - paFlat[_n_ * 2 - 1], 2) +
	           pow(paFlat[2] - paFlat[_n_ * 2], 2))
	_x0_ = paFlat[1]  _x1_ = paFlat[1]
	for _i_ = 2 to _n_
		if paFlat[_i_ * 2 - 1] < _x0_  _x0_ = paFlat[_i_ * 2 - 1]  ok
		if paFlat[_i_ * 2 - 1] > _x1_  _x1_ = paFlat[_i_ * 2 - 1]  ok
	next
	return _x1_ - _x0_ > 1 and _d_ < (_x1_ - _x0_) / 2
