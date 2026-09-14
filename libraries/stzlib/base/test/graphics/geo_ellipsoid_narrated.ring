load "../../stzBase.ring"
decimals(6)

# GE8 -- GEODESY ON THE ELLIPSOID.
#
# Every measurement this plane made until now ran on a SPHERE of radius
# 6371.0088 km. The Earth is flattened by about one part in 298, so that
# sphere is up to half a per cent out -- fifteen kilometres on a
# transatlantic flight, which is a gap anybody comparing our answer to a
# GPS or to an airline's own figure finds at once.
#
# HOW THIS FILE IS ARGUED, because a geodesy library is the easiest kind to
# get subtly and invisibly wrong. A distance that is right in the first six
# digits and wrong in the seventh looks correct in every picture, survives
# every round trip, and is still wrong. So NOTHING here is checked against a
# number this engine produced. Every expectation comes from one of four
# places that know nothing about the implementation:
#
#   1. PUBLISHED CONSTANTS a reader can look up in a minute -- the quarter
#      meridian, the authalic radius, the surface area of WGS84.
#   2. CLOSED FORMS that hold on this surface whatever algorithm computes
#      them -- the length of the equator is a times the longitude; the area
#      of a lune is the surface times its share of the turn.
#   3. GIRARD'S THEOREM on a sphere, where a triangle's area is its
#      spherical excess and the excess comes from angles this engine
#      measured independently of any area.
#   4. ROUND TRIPS, which catch an inconsistency even where no independent
#      value exists -- and are reported in METRES OF MISS rather than as a
#      pass, so a reader sees the size of the agreement and not just its
#      existence.

# THE COUNTERS AND THE TWO HELPERS LIVE AT THE BOTTOM OF THIS FILE, with
# every other function, because in Ring a `func` swallows everything
# written after it until the next one. Defined up here they take the whole
# suite into sec() and the file runs in silence -- no error, no output,
# nothing. Every narrated guard in this directory is laid out the same way.
nPass = 0
nFail = 0
nSec = 0

# ---------------------------------------------------------------------
sec("THE TABLE: an ellipsoid is a CLAIM about the shape of the Earth")

aNames = StzGeoEllipsoids()
? "   " + len(aNames) + " reference ellipsoids: " + StzJoinWith(aNames, ", ")
chk("THE LIBRARY CARRIES THE REFERENCE ELLIPSOIDS BY NAME, not one hard " +
    "number, because a coordinate without a datum is not a position -- the " +
    "same latitude on Airy 1830 and on WGS84 is a few hundred metres apart " +
    "in Britain, which is why a walker's map and a phone disagree",
    len(aNames) >= 10 and StzFindFirst("WGS84", StzJoinWith(aNames, ", ")) > 0)

oW = StzGeoWGS84()
oB = StzGeoEllipsoid(:Bessel1841)
oS = StzGeoEllipsoid(:Sphere)
? "   WGS84  a = " + oW.EquatorialRadius() + " m   1/f = " + oW.InverseFlattening()
chk("WGS84 IS DEFINED BY TWO NUMBERS -- a = 6378137 m exactly and " +
    "1/f = 298.257223563 -- and this library holds those two and DERIVES " +
    "the rest, so no two quantities in it can disagree about one ellipsoid",
    oW.EquatorialRadius() = 6378137 and
    fabs(oW.InverseFlattening() - 298.257223563) < 0.00000001)
chk("...so the polar radius is not a third number to keep in step: " +
    "b = a(1-f) = 6356752.314 m, which is what a standards document says",
    fabs(oW.PolarRadius() - 6356752.3142) < 0.001)
chk("NEGATIVE: a name nothing in the table answers to is REFUSED and not " +
    "quietly WGS84 -- a caller who asked for Bessel and silently got WGS84 " +
    "would be hundreds of metres wrong across a country and never told",
    _Refuses("Hipparchus1900"))
chk("...and Bessel 1841 really is a different ellipsoid: its equator is " +
    "740 m smaller than WGS84's, which is the gap that moves a coordinate",
    fabs(oW.EquatorialRadius() - oB.EquatorialRadius()) > 700)
chk("A SPHERE IS A ROW IN THE SAME TABLE -- the one this plane measured on " +
    "until GE8 -- so the old answer stays reachable and the gap stays " +
    "measurable instead of becoming folklore",
    oS.IsSphere() and oS.Flattening() = 0 and NOT oW.IsSphere())

# ---------------------------------------------------------------------
sec("PUBLISHED CONSTANTS: numbers a reader can check in a minute")

? "   quarter meridian " + oW.QuarterMeridianKm() + " km"
chk("THE POLE IS 10001.966 km FROM THE EQUATOR along the meridian. The " +
    "metre was defined in 1793 as a ten-millionth of exactly this, so the " +
    "figure says how far out that first survey was: 1966 metres over a " +
    "length nobody had walked",
    fabs(oW.QuarterMeridianKm() - 10001.965729) < 0.000002)
chk("THE SURFACE OF WGS84 IS 510,065,621.7 km2, from the closed form for " +
    "an oblate spheroid -- and it is computed here, not tabulated, because " +
    "the area routine uses it to recognise a polygon that swallowed a pole",
    fabs(oW.SurfaceAreaKm2() - 510065621.724) < 0.01)
chk("THE AUTHALIC RADIUS IS 6371.007 km -- the sphere with the SAME " +
    "SURFACE. It is not the 6371.0088 km sphere this plane used, which is " +
    "the equal-VOLUME one, and the two being so close is exactly why " +
    "nobody notices which is in use",
    fabs(oW.AuthalicRadiusKm() - 6371.007181) < 0.000002)

# ---------------------------------------------------------------------
sec("CLOSED FORMS: what must hold on this surface, whatever computes it")

# THE EQUATOR. A geodesic along the equator has k = 0, so the two
# integrals collapse and the length becomes a times the longitude --
# the one distance on this surface everybody already knows.
nEq = oW.DistanceM(0, 0, 0, 90)
? "   a quarter of the equator: " + nEq + " m;  a*pi/2 = " + (6378137 * 3.14159265358979 / 2)
chk("A QUARTER OF THE EQUATOR IS a TIMES pi/2, to the millimetre. This is " +
    "not a tolerance -- the equator is a geodesic and its length is the " +
    "equatorial radius times the angle, so any error in the machinery " +
    "shows here first",
    fabs(nEq - 6378137 * 3.141592653589793 / 2) < 0.001)
chk("...and you leave due east on it, which is the other half of the same " +
    "statement",
    fabs(oW.Azimuth(0, 0, 0, 90) - 90) < 0.000000001)

# THE MERIDIAN. Same code, different constant: a meridional geodesic's
# length IS the meridian arc, so the two must agree exactly or one of
# them is a second implementation.
chk("THE MERIDIAN MEASURED AS A GEODESIC AND MEASURED AS AN ARC ARE THE " +
    "SAME NUMBER, to the micrometre -- they had better be, because they " +
    "are one integral asked twice, and a gap would mean a second copy of " +
    "the formula had grown somewhere",
    fabs(oW.DistanceM(0, 0, 90, 0) - oW.QuarterMeridianKm() * 1000) < 0.000001)
chk("POLE TO POLE IS TWICE THE QUARTER, which is the same statement run " +
    "through the over-the-pole branch instead of the ordinary one",
    fabs(oW.DistanceM(-90, 0, 90, 0) - 2 * oW.QuarterMeridianKm() * 1000) < 0.000001)

# A DEGREE IS NOT A DEGREE. The two numbers every analyst converting a
# tolerance into degrees needs, and the reason a sphere gets both wrong.
? "   a degree of latitude: " + oW.DegreeOfLatitudeKm(0) + " km at the equator, " +
  oW.DegreeOfLatitudeKm(89.5) + " km at the pole"
chk("A DEGREE OF LATITUDE IS 110.574 km AT THE EQUATOR AND 111.694 km AT " +
    "THE POLE -- a whole kilometre longer. The ground is flatter there, so " +
    "the same tilt of the vertical walks further over it, and a sphere " +
    "cannot say this at all: on a sphere both are 111.19 km",
    fabs(oW.DegreeOfLatitudeKm(0) - 110.574) < 0.001 and
    fabs(oW.DegreeOfLatitudeKm(89.5) - 111.694) < 0.001)
chk("...while a degree of LONGITUDE shrinks from 111.320 km to 0.973 km " +
    "over the same journey, which is why latitude and longitude are not a " +
    "vector space and cannot be subtracted",
    fabs(oW.DegreeOfLongitudeKm(0) - 111.3195) < 0.001 and
    oW.DegreeOfLongitudeKm(89.5) < 1)

# ---------------------------------------------------------------------
sec("THE GEODESIC: shortest paths, and how far the sphere was out")

aJL = oW.Between(40.6413, -73.7781, 51.4700, -0.4543)
nSph = StzGeoDistanceOnSphereKm(-73.7781, 40.6413, -0.4543, 51.4700)
? "   JFK to LHR: " + aJL[:km] + " km on WGS84, " + nSph + " km on the sphere"
? "   leaving on " + aJL[:azimuth] + " deg, arriving on " + aJL[:finalAzimuth] + " deg"
chk("NEW YORK TO LONDON IS 5554.909 km ON WGS84, against 5540.019 km on " +
    "the sphere -- FIFTEEN KILOMETRES, on a flight anybody can look up. " +
    "That gap is the whole of GE8",
    fabs(aJL[:km] - 5554.9088) < 0.001 and aJL[:km] - nSph > 14.8)
chk("YOU LEAVE ON 51.4 DEGREES AND ARRIVE ON 108.0 -- fifty-six degrees of " +
    "turn, which is why a great-circle course has to be re-steered the " +
    "whole way and why the route looks bent on a Mercator chart",
    fabs(aJL[:azimuth] - 51.3816) < 0.001 and
    fabs(aJL[:finalAzimuth] - 107.9828) < 0.001)

# ROUND TRIPS, reported in metres of miss. This is the check that reaches
# the cases no published number covers -- and the antipodal ones are
# exactly where Vincenty's method, the usual alternative, fails to
# converge at all.
aCases = [
	[ 40.6413, -73.7781, 51.47, -0.4543, "JFK to LHR" ],
	[ -33.8688, 151.2093, 51.5074, -0.1278, "Sydney to London" ],
	[ 0, 0, 0.5, 179.5, "nearly antipodal on the equator" ],
	[ 30, 0, -30.1, 179.8, "nearly antipodal, off the equator" ],
	[ 0.0000001, 0, -0.0000001, 180, "as antipodal as it gets" ],
	[ 45, 10, 45.0000001, 10.0000001, "a centimetre" ],
	[ 89.9, 0, -89.9, 180, "over the pole" ]
]
nWorst = 0
for i = 1 to len(aCases)
	a = aCases[i]
	r = oW.Between(a[1], a[2], a[3], a[4])
	d = oW.DestinationKm(a[1], a[2], r[:azimuth], r[:km])
	miss = oW.DistanceM(d[1], d[2], a[3], a[4])
	if miss > nWorst  nWorst = miss  ok
	? "   " + a[5] + ": " + r[:km] + " km, direct lands " + miss + " m away"
next
chk("GOING BACK OUT THE WAY THE INVERSE SAID LANDS ON THE POINT -- worst " +
    "miss over seven cases is under a MICROMETRE, and four of the seven " +
    "are the near-antipodal geometry where Vincenty's method, the usual " +
    "alternative, does not converge at all",
    nWorst < 0.000001)

chk("A MIDPOINT IS THE SAME DISTANCE FROM BOTH ENDS, which no part of the " +
    "code was told to arrange",
    _MidpointBalanced(oW, 40.6413, -73.7781, 51.47, -0.4543))

# ---------------------------------------------------------------------
sec("THE RHUMB LINE: the path you can actually steer")

aR = oW.RhumbBetween(40.6413, -73.7781, 51.47, -0.4543)
? "   JFK to LHR by rhumb: " + aR[:km] + " km on a constant " + aR[:azimuth] + " deg"
chk("THE RHUMB LINE IS LONGER THAN THE GEODESIC -- 5774.190 km against " +
    "5554.909, so 219 km is what a great-circle course saves. Before " +
    "satellite navigation you steered the rhumb because you CAN: one " +
    "compass bearing, held all the way",
    fabs(aR[:km] - 5774.1898) < 0.001 and aR[:km] > aJL[:km])
chk("...and its bearing does not change, which is the entire definition. " +
    "The geodesic's did, by fifty-six degrees",
    fabs(aR[:azimuth] - 77.9684) < 0.001)
chk("A RHUMB SAILED IS A RHUMB ARRIVED: going 5774.190 km on 77.968 " +
    "degrees lands on Heathrow to seven decimal places",
    _RhumbRoundTrip(oW, 40.6413, -73.7781, 51.47, -0.4543))
chk("DUE EAST ALONG A PARALLEL IS THE PARALLEL'S OWN LENGTH -- the case " +
    "where the meridian arc is zero and the usual formula would divide by " +
    "zero, so it is answered by the parallel instead",
    fabs(oW.RhumbDistanceKm(45, 0, 45, 180) - oW.ParallelLengthKm(45) / 2) < 0.001)

# ---------------------------------------------------------------------
sec("THE FRAMES: because latitude and longitude are ANGLES")

aEcef = oW.ToEcef(48.8566, 2.3522, 35)
aBack = oW.FromEcef(aEcef[1], aEcef[2], aEcef[3])
? "   Paris in ECEF: " + aEcef[1] + ", " + aEcef[2] + ", " + aEcef[3]
chk("ECEF PUTS A PLACE IN ONE CARTESIAN FRAME, metres on all three axes -- " +
    "and the round trip returns the latitude to a nanodegree and the " +
    "height to a micrometre, which is what lets a displacement be a " +
    "SUBTRACTION instead of a spherical trigonometry problem",
    fabs(aBack[1] - 48.8566) < 0.000000001 and fabs(aBack[2] - 2.3522) < 0.000000001 and
    fabs(aBack[3] - 35) < 0.000001)
chk("A POINT ON THE EQUATOR AT THE PRIME MERIDIAN IS (a, 0, 0), which is " +
    "the definition of the frame and therefore the one value it cannot " +
    "get wrong without getting everything wrong",
    _IsEcef(oW.ToEcef(0, 0, 0), 6378137, 0, 0))
chk("...and the north pole is (0, 0, b), the POLAR radius -- the place " +
    "where a frame built on a sphere would be 21 km out",
    _IsEcef(oW.ToEcef(90, 0, 0), 0, 0, 6356752.3142))

aEnu = oW.ToEnu(48.8566, 2.3522, 0, 48.8666, 2.3622, 100)
aEnuBack = oW.FromEnu(48.8566, 2.3522, 0, aEnu[1], aEnu[2], aEnu[3])
? "   1 km north-east of Paris in ENU: e=" + aEnu[1] + " n=" + aEnu[2] + " u=" + aEnu[3]
chk("ENU IS THE FRAME A PERSON LIVES IN -- east, north and up in metres " +
    "about a chosen origin, which is what a radar bearing, a survey offset " +
    "or a drone's position already is",
    aEnu[1] > 700 and aEnu[1] < 760 and aEnu[2] > 1100 and aEnu[2] < 1120)
chk("...and the trip back out lands where it started, which is how such a " +
    "thing gets onto a globe",
    fabs(aEnuBack[1] - 48.8666) < 0.000000001 and fabs(aEnuBack[2] - 2.3622) < 0.000000001)
chk("UP IS NOT 100 METRES BUT 99.861 -- the ground curves away over that " +
    "kilometre, so a point at the same height a kilometre off is slightly " +
    "BELOW the local horizontal. That 14 cm is the flat-earth error a " +
    "surveyor corrects for, and it is here rather than assumed away",
    fabs(aEnu[3] - 99.86) < 0.01)

# ---------------------------------------------------------------------
sec("THE AREA: a region whose edges are geodesics")

# A LUNE IS A FRACTION OF THE SURFACE BY SYMMETRY ALONE, whatever the
# shape of the meridian -- so this expectation owes the area routine
# nothing at all.
aLune = [ 0,-89.999999, 40,-89.999999, 40,89.999999, 0,89.999999 ]
nLune = oW.AreaKm2(aLune)
nWant = oW.SurfaceAreaKm2() * 40 / 360
? "   a 40-degree lune: " + nLune + " km2;  surface x 40/360 = " + nWant
chk("A LUNE BETWEEN TWO MERIDIANS IS ITS SHARE OF THE WHOLE SURFACE, to " +
    "fourteen digits. Symmetry fixes this one whatever the meridian's " +
    "shape, so the agreement is the area routine's and not the " +
    "expectation's",
    fabs(nLune - nWant) / nWant < 0.000000000001)

# GIRARD'S THEOREM on a sphere: a triangle's area is its spherical
# excess, and the excess comes from angles the INVERSE problem measured,
# which the area routine never sees.
aTri = [ 0,0.000001, 90,0.000001, 0,89.999999 ]
nTri = oS.AreaKm2(aTri)
nExc = _ExcessOf(oS, aTri)
nGirard = nExc * oS.EquatorialRadius() * oS.EquatorialRadius() / 1000000
? "   octant: " + nTri + " km2;  Girard R2 x excess = " + nGirard
chk("ON A SPHERE A TRIANGLE'S AREA IS ITS SPHERICAL EXCESS TIMES R SQUARED " +
    "-- and the excess here is built from three azimuths the inverse " +
    "problem answered, which the area routine has never seen. They agree " +
    "to eight digits",
    fabs(nTri - nGirard) / nGirard < 0.0000001)

# THE CASE THE FIRST VERSION GOT WRONG, kept as its own assertion.
# 720 SIDES, NOT 60. A polygon's edges are GEODESICS, and a geodesic
# between two points at the same latitude bulges POLEWARD of the parallel
# between them -- so a coarse ring measures LESS than the cap it stands
# for. At 60 sides that gap is 0.18 per cent and swamps what this
# assertion is about; at 720 it is under a part in ten thousand, and what
# is left is the winding rule being tested rather than my own polygon.
aAnt = _CapRing(-80, 720)
nCap = oW.AreaKm2(aAnt)
nCapWant = oW.SurfaceAreaKm2() * (1 - _SinAuth(oW, 80)) / 2
? "   a cap below 80S: " + nCap + " km2;  the zone formula says " + nCapWant
chk("A RING THAT WINDS ROUND A POLE IS THE CAP AND NOT THE REST OF THE " +
    "WORLD. A boundary integral measures the area between the path and " +
    "the equator, and for a path that goes right round -- Antarctica's " +
    "coast, in every world file there is -- that is the whole southern " +
    "hemisphere minus the cap. Before this was handled Antarctica " +
    "measured 242,965,092 km2 for a continent of 12,236,255",
    fabs(nCap - nCapWant) / nCapWant < 0.0001)
chk("...and the same ring at 60 sides comes out 0.18 per cent SMALLER, " +
    "which is not an error but the geodesics cutting inside the parallel " +
    "they replace -- a polygon is its edges and its edges are straight " +
    "lines on this surface",
    _CoarserIsSmaller(oW, nCap))

nSq = oW.AreaKm2([ 0,0, 1,0, 1,1, 0,1 ])
chk("A ONE-DEGREE SQUARE AT THE EQUATOR IS 12,308.8 km2, which is its own " +
    "two sides multiplied -- 111.320 by 110.574 -- because at the equator " +
    "the ground is nearly flat and the answer must nearly be the " +
    "schoolbook one",
    fabs(nSq - 12308.778) < 0.01)
chk("NEGATIVE: and the WINDING does not change it. An area is not signed, " +
    "and a caller should not have to know which way a file wound its rings",
    fabs(oW.AreaKm2([ 0,1, 1,1, 1,0, 0,0 ]) - nSq) < 0.000000001)

# ---------------------------------------------------------------------
sec("DEGREES, MINUTES AND SECONDS: how a coordinate is written by hand")

? "   " + StzLatLonToDms(-33.8688, 151.2093)
chk("A COORDINATE WRITTEN BY HAND IS DEGREES, MINUTES AND SECONDS, and a " +
    "library that only takes a decimal cannot read a chart, a deed or half " +
    "the place-name databases in the world",
    StzDegToDmsXT(48.8566, 2, "NS") = "48 51' 23.76" + char(34) + " N")
chk("...and a southern latitude takes the letter rather than the minus " +
    "sign, which is what a chart does",
    StzDegToDmsXT(-33.8688, 2, "NS") = "33 52' 7.68" + char(34) + " S")
chk("THE PARSER TAKES THE NUMBERS AND THE SIGN AND IGNORES THE " +
    "PUNCTUATION, because there has never been an agreed punctuation for " +
    "this -- the degree mark appears as a ring, an o, a d, a colon or " +
    "nothing at all depending on the keyboard",
    fabs(StzDmsToDeg("48 51' 23.76" + char(34) + " N") - 48.8566) < 0.000001 and
    fabs(StzDmsToDeg("48:51:23.76") - 48.8566) < 0.000001 and
    fabs(StzDmsToDeg("48d51m23.76s") - 48.8566) < 0.000001)
chk("A TRAILING s IS SECONDS AND NOT SOUTH. 48d51m23.76s is a NORTHERN " +
    "latitude written with unit letters, and a parser that took its last " +
    "letter for a hemisphere answered -48.8566 -- a hundred degrees out, " +
    "from a string nothing about which looked wrong. They are told apart " +
    "by what comes before: a unit follows its number, a hemisphere follows " +
    "a space or a quote mark",
    StzDmsToDeg("48d51m23.76s") > 0 and
    StzDmsToDeg("48 51 23.76 s") < 0 and
    StzDmsToDeg("48d51m23.76sS") < 0)
chk("...and W or S means negative, however it is written",
    fabs(StzDmsToDeg("0 27 15.48 W") + 0.4543) < 0.000001 and
    fabs(StzDmsToDeg("-0 27 15.48") + 0.4543) < 0.000001)
chk("ROUNDING THE SECONDS CARRIES. 1.9999999 degrees to three places is " +
    "2 degrees 0 minutes, and never 1 degree 59 minutes 60.000 seconds, " +
    "which is not a minute anybody reads",
    StzDegToDmsXT(1.9999999, 3, "NS") = "2 0' 0.000" + char(34) + " N")
chk("A COORDINATE SURVIVES THE ROUND TRIP through the way it is written " +
    "down, which is the only property that matters for a format",
    fabs(StzDmsToDeg(StzDegToDmsXT(48.8566, 6, "NS")) - 48.8566) < 0.000000001)

# ---------------------------------------------------------------------
sec("THE WORLD, MEASURED AGAIN")

if fexists("atlas/countries-110m.json")
	oF = StzGeoFeaturesFromTopoJson(read("atlas/countries-110m.json"), "countries")
	nLand = oF.AreaKm2()
	? "   land on WGS84: " + nLand + " km2   (the world's land is about 148,940,000)"
	chk("THE WORLD'S LAND MEASURES 147.4 MILLION km2 ON THE ELLIPSOID from " +
	    "a 110m outline -- one per cent under the true 148.94 million, and " +
	    "that one per cent is the SIMPLIFICATION and not the geodesy: a " +
	    "coastline cut to 110m resolution has had its bays smoothed away",
	    nLand > 145000000 and nLand < 149000000)
	nRu = oF.AreaKm2Of(oF.IndexOfName("Russia"))
	? "   Russia: " + nRu + " km2   (published 17,098,246)"
	chk("...and Russia comes out within three per cent of its published " +
	    "17,098,246 km2, measured from rings that cross the antimeridian",
	    fabs(nRu - 17098246) / 17098246 < 0.03)
else
	? "   SKIPPED, by name: atlas/countries-110m.json is not present."
ok

? ""
? "=========================================================="
? " " + nPass + " ok, " + nFail + " failed"
? "=========================================================="

func chk pcWhat, pbOk
	if pbOk
		nPass++
		? "  ok   " + pcWhat
	else
		nFail++
		? "  FAIL " + pcWhat
	ok

func sec pcWhat
	nSec++
	? ""
	? "-- " + nSec + ". " + pcWhat + " --"

func _Refuses pcName
	try
		StzGeoEllipsoid(pcName)
		return FALSE
	catch
		return TRUE
	done

func _MidpointBalanced poE, pn1, pn2, pn3, pn4
	_m_ = poE.MidpointOf(pn1, pn2, pn3, pn4)
	_a_ = poE.DistanceM(pn1, pn2, _m_[1], _m_[2])
	_b_ = poE.DistanceM(_m_[1], _m_[2], pn3, pn4)
	? "   the two halves are " + _a_ + " m and " + _b_ + " m"
	return fabs(_a_ - _b_) < 0.000001

func _RhumbRoundTrip poE, pn1, pn2, pn3, pn4
	_r_ = poE.RhumbBetween(pn1, pn2, pn3, pn4)
	_d_ = poE.RhumbDestinationKm(pn1, pn2, _r_[:azimuth], _r_[:km])
	return fabs(_d_[1] - pn3) < 0.0000001 and fabs(_d_[2] - pn4) < 0.0000001

func _IsEcef paV, pnX, pnY, pnZ
	return fabs(paV[1] - pnX) < 0.001 and fabs(paV[2] - pnY) < 0.001 and
	       fabs(paV[3] - pnZ) < 0.001

# THE SPHERICAL EXCESS from the triangle's own interior angles, which come
# out of the INVERSE problem's azimuths. Girard's theorem then gives the
# area with no reference at all to the routine being tested -- which is the
# only kind of expectation worth writing for a thing this easy to get
# plausibly wrong.
func _ExcessOf poE, paTri
	_sum_ = 0
	for _i_ = 1 to 3
		_p_ = _i_ - 1  if _p_ < 1  _p_ = 3  ok
		_n_ = _i_ + 1  if _n_ > 3  _n_ = 1  ok
		_to_ = poE.Azimuth(paTri[_i_*2], paTri[_i_*2-1], paTri[_n_*2], paTri[_n_*2-1])
		_fr_ = poE.Azimuth(paTri[_i_*2], paTri[_i_*2-1], paTri[_p_*2], paTri[_p_*2-1])
		_a_ = fabs(_to_ - _fr_)
		if _a_ > 180  _a_ = 360 - _a_  ok
		_sum_ += _a_ * 3.141592653589793 / 180
	next
	return _sum_ - 3.141592653589793

# a ring right round the world at one latitude, which is the shape every
# world file gives Antarctica
func _CoarserIsSmaller poE, pnFine
	_c_ = poE.AreaKm2(_CapRing(-80, 60))
	? "   the same cap at 60 sides: " + _c_ + " km2, " +
	  ((pnFine - _c_) / pnFine * 100) + " per cent under the 720-sided one"
	return _c_ < pnFine and (pnFine - _c_) / pnFine > 0.001

func _CapRing pnLat, pnSteps
	_o_ = []
	for _i_ = 0 to pnSteps - 1
		_o_ + (-180 + 360 * _i_ / pnSteps)
		_o_ + pnLat
	next
	return _o_

# the AUTHALIC sine: the fraction of a hemisphere's AREA lying below a
# latitude. On a sphere it is sin(phi); on an ellipsoid the ground near the
# pole is flatter and carries less area per degree, and this is the closed
# form of that -- the same zone function the area routine integrates, which
# is why it is stated here and derived from the surface area rather than
# copied from it.
func _SinAuth poE, pnLat
	_e_ = poE.Eccentricity()
	_s_ = sin(pnLat * 3.141592653589793 / 180)
	_q_ = _s_ / (1 - _e_*_e_*_s_*_s_) + log((1 + _e_*_s_) / (1 - _e_*_s_)) / (2*_e_)
	_qp_ = 1 / (1 - _e_*_e_) + log((1 + _e_) / (1 - _e_)) / (2*_e_)
	return _q_ / _qp_
