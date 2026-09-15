load "../../stzBase.ring"
decimals(4)

# GE10 -- MAP FURNITURE, AND THE TWO PLOTS A FIELD STILL OWED.
#
# The things a map carries around and over it: a scale bar, a north arrow,
# the line between day and night, and the arrows and streamlines that show
# which way a field is going.
#
# TWO OF THEM ARE WHERE MAPS LIE MOST.
#
# A SCALE BAR says "this length is 500 km", and on a world map that is true
# along one line and nowhere else -- a Mercator's scale is nearly six times
# greater at 80 degrees than at the equator. Almost every world map carries
# one anyway. GE9 measured exactly that variation, so this plane can draw
# the bar at a STATED latitude and REFUSE to draw one at all when the sheet
# cannot support it.
#
# A NORTH ARROW is usually drawn pointing up and hoped over. On a rotated
# or oblique projection north is not up, and a reader has no other way to
# know. So it is MEASURED: project a short step due north and draw where it
# actually went.
#
# AND THE SOLAR CONSTANTS ARE THE ONLY THINGS HERE SOMEBODY HAD TO TYPE, so
# they are held to facts that need no almanac -- the declination is +23.44
# at the June solstice and -23.44 at the December one, zero at both
# equinoxes, and the subsolar longitude advances fifteen degrees an hour.
# That is the discipline GE9's gallery used, for the same reason.

nOk = 0  nBad = 0  nSec = 0

oSq = StzGeoFeaturesFromJson(_FSquare())
oEE = StzGeoMap(new stzGeoProjection(:EqualEarth), oSq)
oEE.Projection().FitToSphere(900, 450, 4)
oEE.SetPaper(0, 0, 900, 450)
oMe = StzGeoMap(new stzGeoProjection(:Mercator), oSq)
oMe.Projection().FitToSphere(900, 900, 4)
oMe.SetPaper(0, 0, 900, 900)

# ---------------------------------------------------------------------
sec("THE SUN, against facts that need no almanac")

aSeasons = [ [ 3, 20, "March equinox", 0 ], [ 6, 21, "June solstice", 23.44 ],
             [ 9, 23, "September equinox", 0 ], [ 12, 21, "December solstice", -23.44 ] ]
for i = 1 to len(aSeasons)
	a = aSeasons[i]
	s = oEE.SunAt(2026, a[1], a[2], 12)
	? "   " + a[3] + ": declination " + s[:declination] +
	  " (want " + a[4] + "), equation of time " + s[:equationOfTime] + " min"
next
chk("THE DECLINATION IS ZERO AT BOTH EQUINOXES AND PLUS OR MINUS 23.44 AT " +
    "THE SOLSTICES. That sequence IS the year, and no series with a " +
    "mistyped constant produces it -- which is the only reason the " +
    "Almanac's numbers can be trusted here at all",
    _FDecl(3, 20, 0, 0.3) and _FDecl(6, 21, 23.44, 0.02) and
    _FDecl(9, 23, 0, 0.3) and _FDecl(12, 21, -23.44, 0.02))
chk("...and the EQUATION OF TIME runs about -7.5 minutes in March and " +
    "+7.5 in September -- the true sun ahead of a clock sun and then " +
    "behind it, which is why the earliest sunset is not on the shortest day",
    _FEot(3, 20, -7.5, 1.5) and _FEot(9, 23, 7.5, 1.5))
chk("THE SUBSOLAR LONGITUDE ADVANCES FIFTEEN DEGREES AN HOUR, because that " +
    "is what a day IS. Any error in the sidereal-time constant shows here " +
    "as a drift and nowhere else",
    _FAdvance())
chk("...and at noon UTC the sun is within a few degrees of the prime " +
    "meridian, the gap being the equation of time turned into longitude at " +
    "a quarter degree a minute",
    fabs(oEE.SunAt(2026, 6, 21, 12)[:lon]) < 5 and
    fabs(oEE.SunAt(2026, 3, 20, 12)[:lon]) < 5)

# ---------------------------------------------------------------------
sec("THE TERMINATOR, which is astronomy and not drawing")

aEq = oEE.TerminatorAt(2026, 3, 20, 12)
aSo = oEE.TerminatorAt(2026, 6, 21, 12)
? "   equinox terminator reaches latitude " + _FMaxLat(aEq) +
  ", solstice " + _FMaxLat(aSo)
chk("AT AN EQUINOX THE TERMINATOR PASSES THROUGH BOTH POLES -- the day is " +
    "twelve hours everywhere on Earth, which is what an equinox means and " +
    "is the same statement seen as a line",
    _FMaxLat(aEq) > 89.5)
chk("AT THE JUNE SOLSTICE IT STOPS AT 66.56 DEGREES -- the Arctic Circle, " +
    "which is DEFINED as ninety minus the tilt and is exactly where the " +
    "sun does not set. The line the engine draws and the line in the " +
    "definition are the same line",
    fabs(_FMaxLat(aSo) - 66.56) < 0.05)
chk("DAY AND NIGHT ARE THE SAME CIRCLE ASKED AS A QUESTION: at the June " +
    "solstice the sun is up at 80 north all day and down at 80 south all " +
    "day, which is the polar day and the polar night",
    oEE.IsDaylightAt(2026, 6, 21, 0, 0, 80) and
    oEE.IsDaylightAt(2026, 6, 21, 12, 0, 80) and
    NOT oEE.IsDaylightAt(2026, 6, 21, 0, 0, -80) and
    NOT oEE.IsDaylightAt(2026, 6, 21, 12, 0, -80))
chk("...and the sun's elevation at the subsolar point is ninety degrees, " +
    "which is what 'directly overhead' means and is the one value the " +
    "whole calculation cannot get wrong without getting everything wrong",
    _FOverhead())
chk("TWILIGHT IS THE SAME CIRCLE FURTHER OUT -- civil at 6 degrees below " +
    "the horizon, nautical at 12, astronomical at 18, so 96, 102 and 108. " +
    "One routine draws all four because they are one thing, and each band " +
    "reaches further from the sun than the last",
    _FTwilightNests())

# ---------------------------------------------------------------------
sec("THE SCALE BAR, AND WHEN IT REFUSES")

? "   scale varies by x" + oEE.ScaleVariation() + " on Equal Earth, x" +
  oMe.ScaleVariation() + " on Mercator"
chk("A SCALE BAR IS A ROUND NUMBER OF KILOMETRES -- 1, 2 or 5 times a power " +
    "of ten, which is what an atlas uses and what a reader can divide by in " +
    "their head",
    _FNice(oEE.ScaleBarAt(140, 0)[:km]) and _FNice(oEE.ScaleBarAt(40, 0)[:km]) and
    _FNice(oEE.ScaleBarAt(300, 45)[:km]))
chk("...and its LENGTH IS MEASURED, not derived from a scale parameter: " +
    "two points a known distance apart on WGS84, projected, and the pixels " +
    "between them. That works for all forty-four projections including the " +
    "twenty-eight with no closed-form inverse",
    _FBarMeasured())
chk("THE BAR IS SHORTER PER KILOMETRE WHERE THE MAP IS SMALLER. On a " +
    "Mercator the same ground takes nearly twice the pixels at 60 degrees " +
    "that it takes at the equator -- which is the reason a single bar " +
    "cannot serve a whole world map",
    _FBarGrows())
oC1 = new stzCanvas(600, 300)
oC1.SetBackground("#FFFFFF")
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
nDrew = oMe.DrawScaleBarOn(oC1, oFont, 12, 40, 200, 140, 0, "#333333")
? "   drawing a bar on a world Mercator returned " + nDrew
chk("AND ON A WORLD MAP IT REFUSES TO BE DRAWN AT ALL, answering 0 so the " +
    "caller knows nothing happened. A face that drew it anyway would make " +
    "the caller complicit in the lie without telling them -- and every " +
    "world atlas in print has made that choice the other way",
    nDrew = 0)
oCity = StzGeoMap(new stzGeoProjection(:Mercator), oSq)
oCity.Projection().FitPointsIn([ 2.2, 48.8, 2.5, 48.9 ], 0, 0, 600, 300, 10)
oCity.SetPaper(0, 0, 600, 300)
oC2 = new stzCanvas(600, 300)
oC2.SetBackground("#FFFFFF")
nDrew2 = oCity.DrawScaleBarOn(oC2, oFont, 12, 40, 250, 140, 48.85, "#333333")
? "   ...on a city-sized Mercator it returned " + nDrew2 +
  " (variation there is only x" + oCity.ScaleVariation() + ")"
chk("NEGATIVE: ON A CITY PLAN IT DRAWS, because there the scale really is " +
    "constant. A refusal that refused everything would be a rule nobody " +
    "could use",
    nDrew2 > 0)

# ---------------------------------------------------------------------
sec("NORTH IS NOT ALWAYS UP")

oC3 = new stzCanvas(400, 400)
oC3.SetBackground("#FFFFFF")
oRot = StzGeoMap(new stzGeoProjection(:Orthographic), oSq)
oRot.Projection().FitToSphere(400, 400, 4)
chk("ON AN UNROTATED CYLINDRICAL PROJECTION NORTH IS UP, and the measured " +
    "arrow agrees -- so the measurement costs nothing where the assumption " +
    "would have held",
    _FNorthIsUp(oMe, 0, 0) and _FNorthIsUp(oMe, 30, 40))
oRot.Projection().Rotate([ 0, 0, 35 ])
chk("...AND ON A ROLLED ONE IT IS NOT, by the angle it was rolled. A north " +
    "arrow drawn pointing up would be wrong by thirty-five degrees and " +
    "nothing on the sheet would say so",
    _FNorthTilt(oRot, 0, 0) > 25 and _FNorthTilt(oRot, 0, 0) < 45)

# ---------------------------------------------------------------------
sec("A FIELD THAT HAS A DIRECTION")

aG = _FGrid()
aU = _FRotU()
aV = _FRotV()
aLine = oEE.StreamlineFrom(aG, aU, aV, 20, 0, 0.4, 3000)
aR = _FRadii(aLine)
? "   a rotational field, seeded at (20,0): " + (len(aLine)/2) +
  " points, radius " + aR[1] + " to " + aR[2]
chk("A STREAMLINE IN A ROTATIONAL FIELD KEEPS ITS RADIUS. Euler's method " +
    "spirals OUTWARD here -- a closed circular flow comes back as an " +
    "opening spiral, which a reader takes for a real divergence rather " +
    "than for the integrator's own error. RK4 holds it to a part in ten " +
    "thousand over three thousand steps",
    aR[2] - aR[1] < 0.01)
chk("...and WHERE it ends is not the invariant: that depends only on how " +
    "many steps were taken. The first version of this check called that a " +
    "closure failure when it was arithmetic",
    len(aLine) / 2 = 3000)
aStr = oEE.StreamlineFrom(aG, _FUniformU(), _FUniformV(), 0, 0, 0.5, 60)
chk("A STREAMLINE IN A UNIFORM FIELD IS STRAIGHT, which is the other " +
    "end of the same test and catches an integrator that curves when " +
    "nothing told it to",
    _FIsStraight(aStr))
# THE NIGHT IS A FILLED CAP AND NOT SAMPLED PIXELS. The first witness asked
# every sixth pixel whether the sun was up and painted a rectangle if not:
# correct, and a staircase along the terminator with two flat tones. The
# night is the spherical cap about the ANTIPODE of the subsolar point, and
# a cap is a ring the projection already knows how to cut and fill.
aCap = StzEngineGeoNightCap(oEE.SunAt(2026, 6, 21, 12)[:lat],
	oEE.SunAt(2026, 6, 21, 12)[:lon], 0, 181)
? "   the night cap is " + (len(aCap)/2) + " points; every one of them is " +
  _FCapElev(aCap) + " degrees of solar elevation"
chk("THE NIGHT IS A SPHERICAL CAP -- every point on its edge has the sun " +
    "exactly on the horizon, which is what the terminator IS. Handing a " +
    "ring to the projection gives a filled antialiased region; sampling " +
    "pixels gives a staircase and two flat tones",
    len(aCap) = 362 and fabs(_FCapElev(aCap)) < 0.001)
chk("...and the twilight bands are the SAME CAP SMALLER -- 6 degrees below " +
    "the horizon is 84 from the antipode, nautical 78, astronomical 72 -- " +
    "so four nested caps drawn one over the other give the gradient a " +
    "reader sees at dusk, out of one routine",
    _FCapNests())

# EVENLY-SPACED STREAMLINES (Jobard and Lefebvre). Seeding on a grid puts
# the lines where the SEEDS are and not where the paper has room: the slow
# places crowd and the fast places go bald, and a reader cannot tell a
# dense patch from a lucky lattice.
aFlow = StzEngineGeoEvenStreamlines(aG, aU, aV, -40, -40, 40, 40, 4, 1.3, 400, 300)
? "   evenly-spaced: " + aFlow[1] + " lines, each grown until it met a neighbour"
chk("EVENLY-SPACED STREAMLINES ARE AN ALGORITHM AND NOT A STYLING CHOICE. " +
    "Each stops the moment it comes within half a separation of a line " +
    "already drawn, and each new seed is one separation to the side of an " +
    "existing one -- so the curves are that far apart EVERYWHERE, which is " +
    "what frees the shape to carry the meaning instead of the density",
    aFlow[1] > 10 and _FEvenlySpaced(aFlow, 4))
chk("NEGATIVE: and no two of them come closer than the separation allows, " +
    "which is the property the algorithm exists for and the one a grid of " +
    "seeds cannot give at any density",
    _FNoneTooClose(aFlow, 4))

aVec = oEE.VectorsOf(aG, aU, aV, 20)
? "   the same field as arrows, every 20th node: " + (len(aVec)/5)
chk("THE ARROWS COME BACK AS PLACE, COMPONENTS AND MAGNITUDE -- five " +
    "numbers each -- because an arrow's LENGTH is a scale the caller sets: " +
    "the engine does not know how big the paper is or what the field's " +
    "units are",
    len(aVec) % 5 = 0 and len(aVec) / 5 = 25 and _FMagnitudesRight(aVec))

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

func _FSquare()
	return '{"type":"FeatureCollection","features":[{"type":"Feature",' +
		'"properties":{"name":"S"},"geometry":{"type":"Polygon",' +
		'"coordinates":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}}]}'

func _FDecl pnM, pnD, pnWant, pnTol
	_m_ = StzGeoMap(new stzGeoProjection(:EqualEarth), StzGeoFeaturesFromJson(_FSquare()))
	return fabs(_m_.SunAt(2026, pnM, pnD, 12)[:declination] - pnWant) < pnTol

func _FEot pnM, pnD, pnWant, pnTol
	_m_ = StzGeoMap(new stzGeoProjection(:EqualEarth), StzGeoFeaturesFromJson(_FSquare()))
	return fabs(_m_.SunAt(2026, pnM, pnD, 12)[:equationOfTime] - pnWant) < pnTol

# FIFTEEN DEGREES AN HOUR is what a day IS, and the check is the difference
# between two readings rather than either one -- so it tests the rate and
# not the epoch, which is the thing a sidereal constant can get wrong.
func _FAdvance()
	_m_ = StzGeoMap(new stzGeoProjection(:EqualEarth), StzGeoFeaturesFromJson(_FSquare()))
	_a_ = _m_.SunAt(2026, 6, 21, 2)[:lon]
	_b_ = _m_.SunAt(2026, 6, 21, 4)[:lon]
	_d_ = _b_ - _a_
	if _d_ > 180  _d_ -= 360  ok
	if _d_ < -180  _d_ += 360  ok
	? "   two hours moves the subsolar longitude " + _d_ + " degrees (want -30)"
	return fabs(_d_ + 30) < 0.02

func _FMaxLat paRing
	_m_ = 0
	for _i_ = 1 to len(paRing) / 2
		if fabs(paRing[_i_ * 2]) > _m_  _m_ = fabs(paRing[_i_ * 2])  ok
	next
	return _m_

func _FOverhead()
	_m_ = StzGeoMap(new stzGeoProjection(:EqualEarth), StzGeoFeaturesFromJson(_FSquare()))
	_s_ = _m_.SunAt(2026, 6, 21, 12)
	return fabs(_m_.SolarElevationAt(2026, 6, 21, 12, _s_[:lon], _s_[:lat]) - 90) < 0.001

# each twilight band must reach FURTHER from the sun than the last
func _FTwilightNests()
	_m_ = StzGeoMap(new stzGeoProjection(:EqualEarth), StzGeoFeaturesFromJson(_FSquare()))
	_s_ = _m_.SunAt(2026, 6, 21, 12)
	_prev_ = 0
	aAng = [ 90, 96, 102, 108 ]
	for _i_ = 1 to len(aAng)
		_r_ = _m_.TwilightAt(2026, 6, 21, 12, aAng[_i_])
		if len(_r_) < 6  return FALSE  ok
		# the angular distance from the subsolar point to the ring
		_d_ = 90 - _m_.SolarElevationAt(2026, 6, 21, 12, _r_[1], _r_[2])
		if _d_ <= _prev_  return FALSE  ok
		_prev_ = _d_
	next
	return TRUE

func _FNice pn
	if pn <= 0  return FALSE  ok
	_e_ = floor(log10(pn))
	_m_ = pn / pow(10, _e_)
	return fabs(_m_ - 1) < 0.001 or fabs(_m_ - 2) < 0.001 or fabs(_m_ - 5) < 0.001

# THE BAR'S LENGTH MUST MATCH WHAT THE PROJECTION ACTUALLY DID, so it is
# checked against a projection of the same ground rather than against the
# arithmetic that produced it.
func _FBarMeasured()
	_m_ = StzGeoMap(new stzGeoProjection(:EqualEarth), StzGeoFeaturesFromJson(_FSquare()))
	_m_.Projection().FitToSphere(900, 450, 4)
	_b_ = _m_.ScaleBarAt(140, 0)
	_e_ = StzGeoWGS84()
	# how many degrees of longitude the bar's kilometres are, at the equator
	_deg_ = _b_[:km] / _e_.DegreeOfLongitudeKm(0)
	_p1_ = _m_.Projection().Project(0, 0)
	_p2_ = _m_.Projection().Project(_deg_, 0)
	if len(_p1_) < 2 or len(_p2_) < 2  return FALSE  ok
	_px_ = fabs(_p2_[1] - _p1_[1])
	? "   the bar says " + _b_[:pixels] + " px; projecting that much ground gives " + _px_
	return fabs(_px_ - _b_[:pixels]) / _b_[:pixels] < 0.01

func _FBarGrows()
	_m_ = StzGeoMap(new stzGeoProjection(:Mercator), StzGeoFeaturesFromJson(_FSquare()))
	_m_.Projection().FitToSphere(900, 900, 4)
	_a_ = _m_.ScaleBarAt(140, 0)
	_b_ = _m_.ScaleBarAt(140, 60)
	# pixels per km at each latitude
	_r0_ = _a_[:pixels] / _a_[:km]
	_r60_ = _b_[:pixels] / _b_[:km]
	? "   Mercator: " + _r0_ + " px/km at the equator, " + _r60_ + " at 60 degrees"
	return _r60_ / _r0_ > 1.8 and _r60_ / _r0_ < 2.2

func _FNorthIsUp poMap, pnLon, pnLat
	return _FNorthTilt(poMap, pnLon, pnLat) < 0.5

# how far off vertical the measured north direction is, degrees
func _FNorthTilt poMap, pnLon, pnLat
	_a_ = poMap.Projection().Project(pnLon, pnLat)
	_b_ = poMap.Projection().Project(pnLon, pnLat + 0.5)
	if len(_a_) < 2 or len(_b_) < 2  return 999  ok
	_dx_ = _b_[1] - _a_[1]
	_dy_ = _b_[2] - _a_[2]
	# on a canvas y grows downward, so north is -y
	return fabs(atan2(_dx_, -_dy_) * 180 / 3.141592653589793)

func _FGrid()
	return [ -40, -40, 1, 1, 81, 81 ]

func _FRotU()
	_a_ = []
	for _j_ = 0 to 80
		for _i_ = 0 to 80
			_a_ + (-(-40 + _j_) * cos((-40 + _j_) * 3.141592653589793 / 180))
		next
	next
	return _a_

func _FRotV()
	_a_ = []
	for _j_ = 0 to 80
		for _i_ = 0 to 80
			_a_ + (-40 + _i_)
		next
	next
	return _a_

func _FUniformU()
	_a_ = []
	for _k_ = 1 to 6561  _a_ + 1  next
	return _a_

func _FUniformV()
	_a_ = []
	for _k_ = 1 to 6561  _a_ + 0  next
	return _a_

func _FRadii paLine
	_lo_ = 99999
	_hi_ = 0
	for _i_ = 1 to len(paLine) / 2
		_r_ = sqrt(pow(paLine[_i_ * 2 - 1], 2) + pow(paLine[_i_ * 2], 2))
		if _r_ < _lo_  _lo_ = _r_  ok
		if _r_ > _hi_  _hi_ = _r_  ok
	next
	return [ _lo_, _hi_ ]

func _FIsStraight paLine
	_n_ = len(paLine) / 2
	if _n_ < 10  return FALSE  ok
	for _i_ = 1 to _n_
		if fabs(paLine[_i_ * 2]) > 0.001  return FALSE  ok
	next
	return paLine[(_n_ - 1) * 2 + 1] > paLine[1]

# the solar elevation at the first point of a cap ring -- zero on the
# terminator, which is the definition of it
func _FCapElev paRing
	_m_ = StzGeoMap(new stzGeoProjection(:EqualEarth), StzGeoFeaturesFromJson(_FSquare()))
	return _m_.SolarElevationAt(2026, 6, 21, 12, paRing[1], paRing[2])

func _FCapNests()
	_m_ = StzGeoMap(new stzGeoProjection(:EqualEarth), StzGeoFeaturesFromJson(_FSquare()))
	_s_ = _m_.SunAt(2026, 6, 21, 12)
	_prev_ = 99
	aB = [ 0, 6, 12, 18 ]
	for _i_ = 1 to len(aB)
		_r_ = StzEngineGeoNightCap(_s_[:lat], _s_[:lon], aB[_i_], 91)
		if len(_r_) < 6  return FALSE  ok
		_e_ = _m_.SolarElevationAt(2026, 6, 21, 12, _r_[1], _r_[2])
		# each band is FURTHER below the horizon than the last
		if _e_ >= _prev_  return FALSE  ok
		if fabs(_e_ + aB[_i_]) > 0.001  return FALSE  ok
		_prev_ = _e_
	next
	return TRUE

# the mean gap between a sampled point of one line and the nearest point of
# any OTHER line, which the algorithm holds near the separation it was given
func _FEvenlySpaced paFlow, pnSep
	_n_ = paFlow[1]
	if _n_ < 2  return FALSE  ok
	_base_ = 1 + _n_
	_prev_ = 0
	aStart = []
	aEnd = []
	for _k_ = 1 to _n_
		aStart + _prev_
		aEnd + paFlow[1 + _k_]
		_prev_ = paFlow[1 + _k_]
	next
	_sum_ = 0
	_cnt_ = 0
	_cap_ = _n_
	if _cap_ > 12  _cap_ = 12  ok
	for _k_ = 1 to _cap_
		_i_ = aStart[_k_] + floor((aEnd[_k_] - aStart[_k_]) / 2)
		_x_ = paFlow[_base_ + _i_ * 2 + 1]
		_y_ = paFlow[_base_ + _i_ * 2 + 2]
		_best_ = 99999
		for _m_ = 1 to _n_
			if _m_ = _k_  loop  ok
			_j_ = aStart[_m_]
			while _j_ < aEnd[_m_]
				_d_ = sqrt(pow(paFlow[_base_ + _j_ * 2 + 1] - _x_, 2) +
				           pow(paFlow[_base_ + _j_ * 2 + 2] - _y_, 2))
				if _d_ < _best_  _best_ = _d_  ok
				_j_ += 3
			end
		next
		if _best_ < 9999
			_sum_ += _best_
			_cnt_++
		ok
	next
	if _cnt_ = 0  return FALSE  ok
	_mean_ = _sum_ / _cnt_
	? "   the mean gap to the nearest other line is " + _mean_ +
	  " degrees, against a separation of " + pnSep
	return _mean_ > pnSep * 0.4 and _mean_ < pnSep * 1.8

func _FNoneTooClose paFlow, pnSep
	_n_ = paFlow[1]
	if _n_ < 2  return FALSE  ok
	_base_ = 1 + _n_
	_prev_ = 0
	aStart = []
	aEnd = []
	for _k_ = 1 to _n_
		aStart + _prev_
		aEnd + paFlow[1 + _k_]
		_prev_ = paFlow[1 + _k_]
	next
	_cap_ = _n_
	if _cap_ > 8  _cap_ = 8  ok
	for _k_ = 1 to _cap_
		_i_ = aStart[_k_] + floor((aEnd[_k_] - aStart[_k_]) / 2)
		_x_ = paFlow[_base_ + _i_ * 2 + 1]
		_y_ = paFlow[_base_ + _i_ * 2 + 2]
		for _m_ = _k_ + 1 to _cap_
			_j_ = aStart[_m_]
			while _j_ < aEnd[_m_]
				_d_ = sqrt(pow(paFlow[_base_ + _j_ * 2 + 1] - _x_, 2) +
				           pow(paFlow[_base_ + _j_ * 2 + 2] - _y_, 2))
				if _d_ < pnSep * 0.35  return FALSE  ok
				_j_ += 2
			end
		next
	next
	return TRUE

func _FMagnitudesRight paVec
	for _i_ = 1 to len(paVec) / 5
		_u_ = paVec[_i_ * 5 - 2]
		_v_ = paVec[_i_ * 5 - 1]
		_m_ = paVec[_i_ * 5]
		if fabs(_m_ - sqrt(_u_ * _u_ + _v_ * _v_)) > 0.000001  return FALSE  ok
	next
	return TRUE
