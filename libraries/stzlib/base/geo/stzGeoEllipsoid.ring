#----------------------------------------------------------------------#
#  GE8 -- THE ELLIPSOID, AND EVERY MEASUREMENT MADE ON IT               #
#----------------------------------------------------------------------#

# AN ELLIPSOID IS A CLAIM ABOUT THE SHAPE OF THE EARTH, and a distance is
# only as true as the claim underneath it.
#
# Everything this plane measured until now ran on a SPHERE of radius
# 6371.0088 km. That sphere is a real choice -- it is the one whose volume
# matches the Earth's -- and it is still a sphere. The Earth is flattened by
# about one part in 298, so a spherical distance is up to half a per cent
# out: a north-south line comes back LONG and an east-west line SHORT. New
# York to London measures 5540.0 km on that sphere and 5554.9 km on WGS84 --
# fifteen kilometres, on a flight anybody can look up. An analyst comparing
# our numbers to a GPS, to Wolfram or to an airline's own figure finds the
# gap immediately, and is right to.
#
# So this class is what the plane measures WITH. It carries one ellipsoid,
# by name, and answers:
#
#   * THE GEODESIC -- the shortest path: its length, the azimuth you leave
#     on, the azimuth you arrive on, and the path itself as points to draw.
#   * THE RHUMB LINE -- the path of constant bearing, which is longer and is
#     the one you can actually steer. A Mercator chart exists to draw it
#     straight, and the difference from the geodesic is the reason a
#     transatlantic flight looks bent.
#   * THE FRAMES -- ECEF and ENU, because latitude and longitude are ANGLES
#     and not a vector space: you cannot subtract two of them and call the
#     result a displacement.
#   * THE AREA of a region whose edges are geodesics, which is what a
#     country's area means.
#   * THE MERIDIAN AND THE PARALLEL, and degrees-minutes-seconds, which is
#     how coordinates are written down wherever they are written by hand.
#
# WHERE THE WORK RUNS. In the engine, geo_geodesy.zig inside stz_geo.dll.
# The ellipsoid crosses the bridge as its two DEFINING numbers -- the
# equatorial radius and the flattening -- and everything else is derived on
# the far side, so the two sides cannot hold different opinions about the
# same ellipsoid.
#
# UNITS. The engine speaks METRES, because a survey does. This face offers
# both: a method ending Km answers kilometres, one ending M answers metres,
# and nothing answers "a number" without saying which.

func StzGeoEllipsoid(pcName)
	return new stzGeoEllipsoid(pcName)

func StzGeoEllipsoidQ(pcName)
	return new stzGeoEllipsoid(pcName)

# THE NAMES THIS LIBRARY KNOWS, in the engine's own order. Asking the engine
# rather than keeping a copy here is the point: a list of ellipsoids in a
# Ring file would be a second place for the numbers to be wrong.
func StzGeoEllipsoids()
	_a_ = []
	for _i_ = 1 to StzEngineGeoEllipsoidCount()
		_a_ + StzEngineGeoEllipsoidName(_i_)
	next
	return _a_

# WGS84 IS THE DEFAULT EVERYWHERE, because it is what a GPS reports, what a
# phone reports, and what almost every dataset published this century is on.
func StzGeoWGS84()
	return new stzGeoEllipsoid(:WGS84)

# EXACTLY n DECIMAL PLACES, built rather than borrowed. Ring's `decimals()`
# is a GLOBAL, so a library function that set it to format one number would
# change how the caller's own numbers print for the rest of the program --
# the clobbering hazard this repository has already paid for with NL and
# TRUE. So the digits are assembled here and nothing global is touched.
func _GeoFixed(pnValue, pnPlaces)
	_p_ = pnPlaces
	if _p_ < 0  _p_ = 0  ok
	_neg_ = FALSE
	_v_ = pnValue
	if _v_ < 0
		_neg_ = TRUE
		_v_ = -_v_
	ok
	_scale_ = pow(10, _p_)
	_r_ = floor(_v_ * _scale_ + 0.5)
	_int_ = floor(_r_ / _scale_)
	_frac_ = _r_ - _int_ * _scale_
	_o_ = "" + _int_
	if _p_ > 0
		_fs_ = "" + _frac_
		while len(_fs_) < _p_  _fs_ = "0" + _fs_  end
		_o_ += "." + _fs_
	ok
	if _neg_  _o_ = "-" + _o_  ok
	return _o_

func _GeoEllipsoidNames()
	_o_ = ""
	_a_ = StzGeoEllipsoids()
	for _i_ = 1 to len(_a_)
		if _i_ > 1  _o_ += ", "  ok
		_o_ += _a_[_i_]
	next
	return _o_

# EVERY FUNCTION IN THIS FILE SITS ABOVE THE CLASS, and that is Ring and
# not taste: once `class` appears, what follows belongs to the class until
# the file ends, so a `func` written underneath one is simply not there. It
# is the same rule that makes a statement after a `func` part of that
# function, and it fails the same silent way -- no error at the definition,
# only "calling function without definition" at the call.

#----------------------------------------------------------------------#
#  DEGREES, MINUTES AND SECONDS                                         #
#----------------------------------------------------------------------#

# A COORDINATE IS WRITTEN IN DEGREES AND MINUTES WHEREVER IT IS WRITTEN BY
# HAND, and a library that only takes a decimal number cannot read a chart,
# a deed, a survey note or half the place-name databases in the world.
#
# These are FUNCTIONS AND NOT METHODS because they are facts about writing
# an angle down, not about any ellipsoid: 48 degrees 51 minutes north is the
# same latitude on Airy 1830 and on WGS84. It is the DISTANCE between two
# such latitudes that needs the ellipsoid, and that is what the class above
# is for.

# 48.8566 -> "48 51' 23.76"" -- degrees, minutes, seconds
#
# THERE IS NO DEGREE SIGN IN THE OUTPUT, deliberately. It is the correct
# character and it is also one this project has a standing rule against
# emitting: a Windows console renders it as a question mark or worse, so a
# coordinate printed while debugging would be harder to read than one
# without it. The minute and second marks carry the reading unambiguously
# on their own, and StzDmsToDeg reads either form back.
func StzDegToDms(pnDeg)
	return StzDegToDmsXT(pnDeg, 2, "")

# ...with a hemisphere letter instead of a minus sign, which is how a chart
# writes it: StzDegToDmsXT(-33.87, 1, "NS") gives 33 52' 12.0" S
func StzDegToDmsXT(pnDeg, pnDecimals, pcHemi)
	_v_ = pnDeg
	_sign_ = ""
	if _v_ < 0
		_v_ = -_v_
		_sign_ = "-"
	ok
	if pcHemi != "" and len(pcHemi) = 2
		if pnDeg < 0
			_sign_ = ""
			pcHemi = StzRight(pcHemi, 1)
		else
			pcHemi = StzLeft(pcHemi, 1)
		ok
	ok
	_d_ = floor(_v_)
	_m_ = floor((_v_ - _d_) * 60)
	_s_ = (_v_ - _d_ - _m_ / 60) * 3600
	# ROUNDING THE SECONDS CAN CARRY, and a coordinate reading 59.9995"
	# printed to three places must become the next minute rather than
	# 60.000" -- which is not a time anybody writes and not a minute anybody
	# reads.
	_s_ = StzRoundTo(_s_, pnDecimals)
	if _s_ >= 60
		_s_ = 0
		_m_++
	ok
	if _m_ >= 60
		_m_ = 0
		_d_++
	ok
	_o_ = _sign_ + _d_ + " " + _m_ + "' " + _GeoFixed(_s_, pnDecimals) + char(34)
	if pcHemi != ""  _o_ += " " + pcHemi  ok
	return _o_

# "48 51' 23.76" N", "48:51:23.76", "48d51m23.76sN", "N 48 51 23.76" and
# "-48 51 23.76" all read the same.
#
# THE PARSER TAKES THE NUMBERS AND THE SIGN AND IGNORES EVERYTHING ELSE,
# because there is no agreed punctuation for this and never has been: the
# degree mark alone appears as a ring, an 'o', a 'd', a colon or nothing at
# all, depending on who typed it and on what keyboard.
func StzDmsToDeg(pcText)
	_c_ = StzTrim("" + pcText)
	if _c_ = ""  return 0  ok
	# A HEMISPHERE LETTER SITS AT ONE END OR THE OTHER, and looking for it
	# ANYWHERE is a bug this guard caught on its first run: "48d51m23.76s"
	# writes the seconds with an s, and a parser scanning the whole string
	# for an S read that as SOUTH and answered -48.8566 for a northern
	# latitude. A sign error of a hundred degrees, from a letter that was
	# never a hemisphere. So only the first and last characters are asked --
	# which is the only place "48 51 23.76 N" and "N 48 51 23.76" ever put
	# it.
	_neg_ = FALSE
	_up_ = StzUpper(_c_)
	_first_ = StzLeft(_up_, 1)
	_last_ = StzRight(_up_, 1)
	# A TRAILING LOWERCASE s AFTER A DIGIT IS SECONDS, NOT SOUTH, and the
	# whole of this branch is that one collision. "48d51m23.76s" is a
	# northern latitude written with unit letters; a parser that read its
	# final s as a hemisphere answered -48.8566, off by a hundred degrees,
	# and nothing about the string looked wrong. The two are told apart by
	# what precedes them: a unit marker follows its NUMBER, a hemisphere
	# follows a space, a quote mark or another unit.
	if len(_c_) >= 2 and StzRight(_c_, 1) = "s"
		_prev_ = ascii(_c_[len(_c_) - 1])
		if (_prev_ >= 48 and _prev_ <= 57) or _c_[len(_c_) - 1] = "."
			_last_ = ""
		ok
	ok
	if _first_ = "S" or _first_ = "W" or _last_ = "S" or _last_ = "W"
		_neg_ = TRUE
	ok
	if _first_ = "-"  _neg_ = TRUE  ok
	_nums_ = []
	_cur_ = ""
	_n_ = len(_c_)
	for _i_ = 1 to _n_
		_ch_ = _c_[_i_]
		_a_ = ascii(_ch_)
		# ASCII CODES, NOT STRING COMPARISON: Ring reads `"5" >= "0"` as a
		# comparison of two NUMBERS and raises R41 on the first letter it
		# meets, which in a coordinate is always.
		if (_a_ >= 48 and _a_ <= 57) or _ch_ = "."
			_cur_ += _ch_
		else
			if _cur_ != "" and _cur_ != "."
				_nums_ + (0 + _cur_)
			ok
			_cur_ = ""
		ok
	next
	if _cur_ != "" and _cur_ != "."  _nums_ + (0 + _cur_)  ok
	if len(_nums_) = 0  return 0  ok
	_v_ = _nums_[1]
	if len(_nums_) > 1  _v_ += _nums_[2] / 60  ok
	if len(_nums_) > 2  _v_ += _nums_[3] / 3600  ok
	if _neg_  _v_ = -_v_  ok
	return _v_

# a position, written the way a chart writes it
func StzLatLonToDms(pnLat, pnLon)
	return StzDegToDmsXT(pnLat, 2, "NS") + "  " + StzDegToDmsXT(pnLon, 2, "EW")

class stzGeoEllipsoid from stzObject

	@cName = "WGS84"
	@nA = 6378137
	@nF = 0
	@nB = 0
	@nE2 = 0
	@nEp2 = 0
	@nN = 0
	@nSurface = 0
	@nAuthalic = 0
	@nQuarter = 0

	def init(pcName)
		_c_ = "WGS84"
		if isString(pcName) and pcName != ""  _c_ = pcName  ok
		if isNumber(pcName)  _c_ = StzEngineGeoEllipsoidName(pcName)  ok
		_i_ = 0
		for _k_ = 1 to StzEngineGeoEllipsoidCount()
			if StzLower(StzEngineGeoEllipsoidName(_k_)) = StzLower("" + _c_)
				_i_ = _k_
				exit
			ok
		next
		if _i_ = 0
			# A NAME NOBODY KNOWS IS NOT QUIETLY WGS84. A caller who asked
			# for Bessel and silently got WGS84 would be a few hundred
			# metres wrong across a country and would never be told; this
			# plane's whole GE4 lesson was that a name which does not bind
			# must be REPORTED and never guessed.
			raise("Softanza: no reference ellipsoid is named '" + _c_ +
				"'. The ones this library knows are: " +
				_GeoEllipsoidNames() + ".")
		ok
		@cName = StzEngineGeoEllipsoidName(_i_)
		_v_ = StzEngineGeoEllipsoidAt(_i_)
		@nA = _v_[1]
		@nF = _v_[2]
		@nB = _v_[3]
		@nE2 = _v_[4]
		@nEp2 = _v_[5]
		@nN = _v_[6]
		@nSurface = _v_[7]
		@nAuthalic = _v_[8]
		@nQuarter = _v_[9]

	#-- what it IS ----------------------------------------------------------

	def Name()
		return @cName

	def Content()
		return [ :name = @cName, :a = @nA, :f = @nF, :b = @nB ]

	# the equatorial radius, metres -- the one number every other follows from
	def EquatorialRadius()
		return @nA

	def PolarRadius()
		return @nB

	def Flattening()
		return @nF

	def InverseFlattening()
		if @nF = 0  return 0  ok
		return 1 / @nF

	def Eccentricity()
		return sqrt(@nE2)

	def EccentricitySquared()
		return @nE2

	def SecondEccentricitySquared()
		return @nEp2

	def ThirdFlattening()
		return @nN

	def IsSphere()
		return @nF = 0

	def SurfaceAreaKm2()
		return @nSurface / 1000000

	# THE SPHERE THAT HAS THE SAME SURFACE AREA. It is the right radius to
	# use when a spherical formula must be used for an AREA -- and it is
	# 6371.007 km, which is why the figure looks so like the sphere this
	# plane used and is not the same number.
	def AuthalicRadiusKm()
		return @nAuthalic / 1000

	# THE DISTANCE FROM THE EQUATOR TO THE POLE, 10001.966 km on WGS84. The
	# metre was defined in 1793 as a ten-millionth of exactly this, so the
	# figure says how far out that first survey was: 1966 metres, about two
	# hundredths of one per cent, over a length nobody had ever walked.
	def QuarterMeridianKm()
		return @nQuarter / 1000

	#-- the geodesic --------------------------------------------------------

	# EVERYTHING THE SHORTEST PATH KNOWS, in one answer, because a caller who
	# wants the distance usually wants the bearing too and solving it twice
	# is solving it twice.
	#
	#   :km, :metres    how far
	#   :azimuth        the bearing you leave point 1 on, degrees from north
	#   :finalAzimuth   the bearing you are on when you ARRIVE, which on any
	#                   long path is a different number -- this is why a
	#                   great-circle course has to be re-steered, and why a
	#                   flight from London to Tokyo starts out heading north
	#   :reducedLength  how far apart two paths leaving a degree apart are
	#                   when they arrive; where it reaches zero the shortest
	#                   path has stopped being shortest
	#   :arcDegrees     the arc on the auxiliary sphere -- the engine's own
	#                   parameter, exposed because a caller sampling a path
	#                   may want to step it evenly in arc rather than length
	def Between(pnLat1, pnLon1, pnLat2, pnLon2)
		_r_ = StzEngineGeoGeodesicInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)
		if len(_r_) < 6  return []  ok
		return [
			:metres = _r_[1],
			:km = _r_[1] / 1000,
			:azimuth = _r_[2],
			:finalAzimuth = _r_[3],
			:reducedLength = _r_[4],
			:arcDegrees = _r_[5]
		]

	def DistanceKm(pnLat1, pnLon1, pnLat2, pnLon2)
		return StzEngineGeoGeodesicInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)[1] / 1000

	def DistanceM(pnLat1, pnLon1, pnLat2, pnLon2)
		return StzEngineGeoGeodesicInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)[1]

	# THE BEARING YOU LEAVE ON, degrees clockwise from north. It is NOT the
	# bearing you arrive on and it is NOT constant along the way; see
	# RhumbAzimuth for the one that is.
	def Azimuth(pnLat1, pnLon1, pnLat2, pnLon2)
		return StzEngineGeoGeodesicInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)[2]

	def FinalAzimuth(pnLat1, pnLon1, pnLat2, pnLon2)
		return StzEngineGeoGeodesicInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)[3]

	# WHERE YOU ARRIVE, going a distance on a bearing. Answers [ lat, lon ].
	def DestinationKm(pnLat, pnLon, pnAzimuth, pnKm)
		_r_ = StzEngineGeoGeodesicDirect(@nA, @nF, pnLat, pnLon, pnAzimuth, pnKm * 1000)
		if len(_r_) < 2  return []  ok
		return [ _r_[1], _r_[2] ]

	def DestinationM(pnLat, pnLon, pnAzimuth, pnM)
		_r_ = StzEngineGeoGeodesicDirect(@nA, @nF, pnLat, pnLon, pnAzimuth, pnM)
		if len(_r_) < 2  return []  ok
		return [ _r_[1], _r_[2] ]

	def DestinationXT(pnLat, pnLon, pnAzimuth, pnKm)
		_r_ = StzEngineGeoGeodesicDirect(@nA, @nF, pnLat, pnLon, pnAzimuth, pnKm * 1000)
		if len(_r_) < 5  return []  ok
		return [ :lat = _r_[1], :lon = _r_[2], :finalAzimuth = _r_[3],
		         :reducedLength = _r_[4], :arcDegrees = _r_[5] ]

	# THE PATH ITSELF, as lon/lat pairs ready for a projection. A geodesic
	# drawn as a straight line between its endpoints is a lie on every
	# projection but the gnomonic, and this is how a flight path or a
	# boundary gets drawn honestly: sample the curve on the sphere, then let
	# the projection bend it. The endpoints come back EXACTLY as given, so
	# two segments that share a point still meet.
	def GeodesicBetween(pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)
		_flat_ = StzEngineGeoGeodesicLine(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)
		return This._Pairs(_flat_)

	# the same as ONE flat list of lon,lat -- what the projection takes
	def GeodesicFlat(pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)
		return StzEngineGeoGeodesicLine(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)

	def MidpointOf(pnLat1, pnLon1, pnLat2, pnLon2)
		_r_ = StzEngineGeoGeodesicInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)
		_d_ = StzEngineGeoGeodesicDirect(@nA, @nF, pnLat1, pnLon1, _r_[2], _r_[1] / 2)
		return [ _d_[1], _d_[2] ]

	#-- the rhumb line ------------------------------------------------------

	# THE PATH OF CONSTANT BEARING -- longer than the geodesic, and the one a
	# ship or a small aircraft can actually hold. Before satellite
	# navigation this WAS the route: you set a compass course and kept it.
	# New York to London is 5554.9 km by geodesic and 5774.2 km by rhumb, and
	# the 219 km is what a great-circle course buys at the price of
	# re-steering all the way.
	def RhumbBetween(pnLat1, pnLon1, pnLat2, pnLon2)
		_r_ = StzEngineGeoRhumbInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)
		if len(_r_) < 2  return []  ok
		return [ :metres = _r_[1], :km = _r_[1] / 1000, :azimuth = _r_[2] ]

	def RhumbDistanceKm(pnLat1, pnLon1, pnLat2, pnLon2)
		return StzEngineGeoRhumbInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)[1] / 1000

	# THE ONE BEARING THAT DOES NOT CHANGE along the way, which is what makes
	# this line steerable at all.
	def RhumbAzimuth(pnLat1, pnLon1, pnLat2, pnLon2)
		return StzEngineGeoRhumbInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)[2]

	def RhumbDestinationKm(pnLat, pnLon, pnAzimuth, pnKm)
		return StzEngineGeoRhumbDirect(@nA, @nF, pnLat, pnLon, pnAzimuth, pnKm * 1000)

	def RhumbLineBetween(pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)
		return This._Pairs(StzEngineGeoRhumbLine(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2, pnPoints))

	def RhumbFlat(pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)
		return StzEngineGeoRhumbLine(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)

	#-- the meridian and the parallel ---------------------------------------

	# HOW FAR NORTH A LATITUDE IS, in km from the equator along the meridian.
	# On a sphere this is just R times the angle; on an ellipsoid it is not,
	# and the gap is why a degree of latitude is 110.57 km at the equator and
	# 111.69 km at the pole -- the ground is flatter there, so the same
	# angular change of the vertical covers more of it.
	def MeridianArcKm(pnLat)
		return StzEngineGeoMeridianArc(@nA, @nF, pnLat) / 1000

	def LatitudeAtArcKm(pnKm)
		return StzEngineGeoLatitudeAtArc(@nA, @nF, pnKm * 1000)

	# the whole way round a parallel of latitude, km
	def ParallelLengthKm(pnLat)
		return StzEngineGeoParallelLength(@nA, @nF, pnLat) / 1000

	# a degree of latitude, and a degree of longitude, AT a latitude -- the
	# two numbers anybody converting a tolerance into degrees needs
	def DegreeOfLatitudeKm(pnLat)
		return This.DistanceKm(pnLat - 0.5, 0, pnLat + 0.5, 0)

	def DegreeOfLongitudeKm(pnLat)
		return This.DistanceKm(pnLat, -0.5, pnLat, 0.5)

	#-- the frames ----------------------------------------------------------

	# ECEF: ONE CARTESIAN FRAME, metres on all three axes, origin at the
	# Earth's centre, Z through the pole, X through where the equator meets
	# the prime meridian. It exists because latitude and longitude cannot be
	# subtracted: near a pole the same ground is a hundred times more degrees
	# of longitude than at the equator, so an average of two coordinates, a
	# difference, or anything handed to a linear-algebra routine is wrong.
	# Height is metres ABOVE THE ELLIPSOID, which is not height above sea
	# level -- the two differ by up to a hundred metres and the difference
	# needs a geoid model this plane does not carry.
	def ToEcef(pnLat, pnLon, pnHeight)
		return StzEngineGeoToEcef(@nA, @nF, pnLat, pnLon, pnHeight)

	def FromEcef(pnX, pnY, pnZ)
		return StzEngineGeoFromEcef(@nA, @nF, pnX, pnY, pnZ)

	# ENU: THE LOCAL FRAME A PERSON LIVES IN -- east, north and up in metres
	# about a chosen origin. A radar bearing, a survey offset, a drone's
	# position or a robot's odometry is naturally in this frame, and the trip
	# back out through ECEF is how such a thing lands on a globe.
	def ToEnu(pnLat0, pnLon0, pnH0, pnLat, pnLon, pnH)
		return StzEngineGeoToEnu(@nA, @nF, pnLat0, pnLon0, pnH0, pnLat, pnLon, pnH)

	def FromEnu(pnLat0, pnLon0, pnH0, pnEast, pnNorth, pnUp)
		return StzEngineGeoFromEnu(@nA, @nF, pnLat0, pnLon0, pnH0, pnEast, pnNorth, pnUp)

	#-- the area ------------------------------------------------------------

	# THE AREA OF A REGION whose edges are geodesics, km2, from a flat list of
	# lon,lat. That is what a country's area means: its border follows the
	# ground, and the ground is this surface.
	#
	# The ring need not be closed -- the last point joins the first -- and
	# its winding does not matter, since an area is not signed. A ring that
	# swallows a pole comes back as the region it encloses and not as the
	# rest of the world, which is the one case where a boundary integral
	# needs to be told what it measured.
	def AreaKm2(paLonLat)
		_r_ = StzEngineGeoGeodesicArea(@nA, @nF, paLonLat)
		if len(_r_) < 2  return 0  ok
		return _r_[1] / 1000000

	def PerimeterKm(paLonLat)
		_r_ = StzEngineGeoGeodesicArea(@nA, @nF, paLonLat)
		if len(_r_) < 2  return 0  ok
		return _r_[2] / 1000

	def AreaXT(paLonLat)
		_r_ = StzEngineGeoGeodesicArea(@nA, @nF, paLonLat)
		if len(_r_) < 2  return []  ok
		return [ :km2 = _r_[1] / 1000000, :m2 = _r_[1],
		         :perimeterKm = _r_[2] / 1000, :perimeterM = _r_[2] ]

	# the length of an open path along geodesics, km -- a river, a route, a
	# flight plan with waypoints
	def PathLengthKm(paLonLat)
		_n_ = len(paLonLat) / 2
		if _n_ < 2  return 0  ok
		_t_ = 0
		for _i_ = 1 to _n_ - 1
			_t_ += StzEngineGeoGeodesicInverse(@nA, @nF,
				paLonLat[_i_ * 2], paLonLat[_i_ * 2 - 1],
				paLonLat[_i_ * 2 + 2], paLonLat[_i_ * 2 + 1])[1]
		next
		return _t_ / 1000

	#-- helpers -------------------------------------------------------------

	def _Pairs(paFlat)
		_o_ = []
		_n_ = len(paFlat) / 2
		for _i_ = 1 to _n_
			_o_ + [ paFlat[_i_ * 2 - 1], paFlat[_i_ * 2] ]
		next
		return _o_

