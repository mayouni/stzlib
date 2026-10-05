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

# Holds one reference ellipsoid by name and measures on it: shortest and constant-bearing paths, destinations, meridian and parallel lengths, ECEF and ENU frames, areas.
#
# Fifteen ellipsoids are known (WGS84, GRS80, WGS72, GRS67, Airy1830, AiryModified, Bessel1841,
# Clarke1866, Clarke1880, International1924, Krassovsky1940, Everest1830, AustralianNational,
# SouthAmerican1969 and Sphere) and WGS84 is the default everywhere, because it is what a GPS
# reports. The engine speaks metres and degrees: a method ending Km answers kilometres, one ending M
# metres. Mind the axis order: the point methods take LATITUDE FIRST, then longitude (DistanceKm,
# Azimuth, DestinationKm, MidpointOf ...), while every flat list of places (AreaKm2, PathLengthKm
# and the Flat methods) and every stzGeoProjection method take LONGITUDE FIRST; swapping them raises
# nothing and measures another pair of places. Niamey to Paris is 3919.43 km on WGS84 and 3931.58 km
# if the arguments are swapped. A shortest path (geodesic) is not a constant-bearing path (rhumb
# line): New York to London is 5585.2 km by the first and 5809.8 km by the second. Pictures, each
# looked at by 'stzlib-docs visual pass (a model reading the PNG)' on 2026-10-05:
# doc/gallery/stzGeoEllipsoid/geodesic_vs_rhumb.png, a geodesic and a rhumb line on a Mercator,
# RIGHT (the rhumb line is straight, the geodesic bows toward the pole);
# doc/gallery/stzGeoEllipsoid/rings_and_areas.png, rings made with DestinationKm on an azimuthal
# equidistant map, RIGHT (they are true circles); ellipsoids_compared.png, six ellipsoids as the gap
# from WGS84 in metres and km2, RIGHT (the Sphere is 10.8 km long on Niamey to Paris). Index:
# doc/gallery/INDEX_geo.md.
#
#   receiver   o1 = new stzGeoEllipsoid("WGS84")
#   example    ? o1.IsSphere()
#              #--> 0
#              ? o1.DistanceKm(13.5116, 2.1254, 48.8566, 2.3522)
#              #--> 3919.43
#   see        stzGeoProjection, stzGeoFeatures, stzGeoMap
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

	# Builds the ellipsoid called pcName (case ignored) or the one at that place in the catalogue; raises an error for an unknown name.
	#
	#   pcName     the ellipsoid's name such as WGS84, Airy1830 or Sphere, or its 1-based position
	#              in StzGeoEllipsoids()
	#   returns    nothing; the object is built
	#   note       An empty text builds WGS84. The catalogue holds fifteen ellipsoids; the error
	#              names them all
	#   see        StzGeoEllipsoids, StzGeoWGS84
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

	# Returns the catalogue name of this ellipsoid as the engine spells it.
	#
	#   returns    text, for example "WGS84"
	#   see        Content, StzGeoEllipsoids
	#@ aka  -- what it IS ----------------------------------------------------------
	def Name()
		return @cName

	# Returns the name and the defining numbers of this ellipsoid, the lengths in metres.
	#
	#   returns    a hash list [ :name, :a, :f, :b ]: name, equatorial radius, flattening, polar
	#              radius
	#   see        EquatorialRadius, PolarRadius, Flattening
	def Content()
		return [ :name = @cName, :a = @nA, :f = @nF, :b = @nB ]

	# Returns the radius at the equator, the semi-major axis a, in metres.
	#
	#   returns    a number of metres, 6378137 for WGS84
	#   see        PolarRadius, Flattening
	#@ aka  the equatorial radius, metres -- the one number every other follows from
	def EquatorialRadius()
		return @nA

	# Returns the distance from the centre to a pole, the semi-minor axis b, in metres.
	#
	#   returns    a number of metres, 6356752.3142 for WGS84
	#   see        EquatorialRadius, Flattening
	def PolarRadius()
		return @nB

	# Returns how much the poles are flattened, (a - b) / a, a pure ratio.
	#
	#   returns    a number, 0.0033528 for WGS84 and 0 for the sphere
	#   see        InverseFlattening, ThirdFlattening
	def Flattening()
		return @nF

	# Returns one over the flattening, the form a geodesy table quotes.
	#
	#   returns    a number, 298.257224 for WGS84, and 0 for the sphere
	#   see        Flattening
	def InverseFlattening()
		if @nF = 0  return 0  ok
		return 1 / @nF

	# Returns the first eccentricity e, the square root of its square.
	#
	#   returns    a number, 0.081819 for WGS84
	#   see        EccentricitySquared, SecondEccentricitySquared
	def Eccentricity()
		return sqrt(@nE2)

	# Returns the first eccentricity squared, e2 = f (2 - f).
	#
	#   returns    a number, 0.006694 for WGS84
	#   see        Eccentricity
	def EccentricitySquared()
		return @nE2

	# Returns the second eccentricity squared, e'2 = e2 / (1 - e2).
	#
	#   returns    a number, 0.006739 for WGS84
	#   see        EccentricitySquared
	def SecondEccentricitySquared()
		return @nEp2

	# Returns n = (a - b) / (a + b), the quantity the meridian-arc series are written in.
	#
	#   returns    a number, 0.001679 for WGS84
	#   see        Flattening
	def ThirdFlattening()
		return @nN

	# TRUE if the flattening is zero, which only the catalogue entry Sphere has.
	#
	#   returns    TRUE or FALSE
	#   see        Flattening
	def IsSphere()
		return @nF = 0

	# Returns the area of the whole surface of the ellipsoid in square kilometres.
	#
	#   returns    a number, 510065621.7 for WGS84
	#   see        AuthalicRadiusKm
	def SurfaceAreaKm2()
		return @nSurface / 1000000

	# Returns the radius in km of the sphere that has the same surface area as this ellipsoid.
	#
	#   returns    a number of km, 6371.007181 for WGS84
	#   see        SurfaceAreaKm2
	#@ aka  THE SPHERE THAT HAS THE SAME SURFACE AREA. It is the right radius to use when a spherical formula must be used for an AREA -- and it is 6371.007 km, which is why the figure looks so like the sphere this plane used and is not the same number.
	def AuthalicRadiusKm()
		return @nAuthalic / 1000

	# Returns the distance from the equator to a pole along a meridian, in km.
	#
	#   returns    a number of km, 10001.965729 for WGS84
	#   see        MeridianArcKm
	#@ aka  THE DISTANCE FROM THE EQUATOR TO THE POLE, 10001.966 km on WGS84. The metre was defined in 1793 as a ten-millionth of exactly this, so the figure says how far out that first survey was: 1966 metres, about two hundredths of one per cent, over a length nobody had ever walked.
	def QuarterMeridianKm()
		return @nQuarter / 1000

	# Returns the length, both bearings and the arc of the shortest path between two places.
	#
	#   pnLat1     latitude of the start in degrees north
	#   pnLon1     longitude of the start in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   returns    a hash list [ :metres, :km, :azimuth, :finalAzimuth, :reducedLength, :arcDegrees
	#              ], or [ ] when the engine gives no answer
	#   note       LATITUDE COMES FIRST. Niamey to Paris is 3919.43 km and leaves on 0.26 degrees;
	#              with longitude first the same call answers 3931.58 km for two other places and
	#              raises nothing
	#   see        DistanceKm, Azimuth, FinalAzimuth
	#@ aka  -- the geodesic --------------------------------------------------------
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

	# Returns the length of the shortest path between two places on this ellipsoid, in kilometres.
	#
	#   pnLat1     latitude of the start in degrees north
	#   pnLon1     longitude of the start in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   returns    a number of km, 3919.43 from Niamey to Paris on WGS84
	#   note       Latitude first; the plain function StzGeoDistanceKm takes longitude first
	#   see        DistanceM, Between, RhumbDistanceKm
	def DistanceKm(pnLat1, pnLon1, pnLat2, pnLon2)
		return StzEngineGeoGeodesicInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)[1] / 1000

	# Returns the length of the shortest path between two places on this ellipsoid, in metres.
	#
	#   pnLat1     latitude of the start in degrees north
	#   pnLon1     longitude of the start in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   returns    a number of metres, 3919425.44 from Niamey to Paris on WGS84
	#   note       Latitude first
	#   see        DistanceKm, Between
	def DistanceM(pnLat1, pnLon1, pnLat2, pnLon2)
		return StzEngineGeoGeodesicInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)[1]

	# Returns the bearing the shortest path leaves the first place on, in degrees clockwise from north.
	#
	#   pnLat1     latitude of the start in degrees north
	#   pnLon1     longitude of the start in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   returns    a number from -180 to 180, 0.26 from Niamey to Paris and -179.62 for the way back
	#   note       Not constant along the way and not the bearing of arrival
	#   see        FinalAzimuth, RhumbAzimuth
	#@ aka  THE BEARING YOU LEAVE ON, degrees clockwise from north. It is NOT the bearing you arrive on and it is NOT constant along the way; see RhumbAzimuth for the one that is.
	def Azimuth(pnLat1, pnLon1, pnLat2, pnLon2)
		return StzEngineGeoGeodesicInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)[2]

	# Returns the bearing the shortest path has on arriving at the second place, in degrees clockwise from north.
	#
	#   pnLat1     latitude of the start in degrees north
	#   pnLon1     longitude of the start in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   returns    a number from -180 to 180, 0.38 from Niamey to Paris
	#   note       On a long path it differs from the departure bearing, which is why a great-circle
	#              course is re-steered
	#   see        Azimuth
	def FinalAzimuth(pnLat1, pnLon1, pnLat2, pnLon2)
		return StzEngineGeoGeodesicInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)[3]

	# Returns the place reached by following the shortest path from a start on a given bearing for pnKm km.
	#
	#   pnLat       latitude of the start in degrees north
	#   pnLon       longitude of the start in degrees east
	#   pnAzimuth   the bearing to leave on in degrees clockwise from north
	#   pnKm        the distance to travel in kilometres
	#   returns     a list [ lat, lon ] in degrees, [ 0, 8.98 ] for 1000 km due east from the
	#               equator at 0 E
	#   note        Answers latitude first, like its arguments
	#   see         DestinationM, DestinationXT, Between
	#@ aka  WHERE YOU ARRIVE, going a distance on a bearing. Answers [ lat, lon ].
	def DestinationKm(pnLat, pnLon, pnAzimuth, pnKm)
		_r_ = StzEngineGeoGeodesicDirect(@nA, @nF, pnLat, pnLon, pnAzimuth, pnKm * 1000)
		if len(_r_) < 2  return []  ok
		return [ _r_[1], _r_[2] ]

	# Returns the place reached by following the shortest path from a start on a given bearing for pnM metres.
	#
	#   pnLat       latitude of the start in degrees north
	#   pnLon       longitude of the start in degrees east
	#   pnAzimuth   the bearing to leave on in degrees clockwise from north
	#   pnM         the distance to travel in metres
	#   returns     a list [ lat, lon ] in degrees
	#   note        Answers latitude first
	#   see         DestinationKm
	def DestinationM(pnLat, pnLon, pnAzimuth, pnM)
		_r_ = StzEngineGeoGeodesicDirect(@nA, @nF, pnLat, pnLon, pnAzimuth, pnM)
		if len(_r_) < 2  return []  ok
		return [ _r_[1], _r_[2] ]

	# Returns the place reached, with the arrival bearing, the reduced length and the arc, for pnKm km on a bearing.
	#
	#   pnLat       latitude of the start in degrees north
	#   pnLon       longitude of the start in degrees east
	#   pnAzimuth   the bearing to leave on in degrees clockwise from north
	#   pnKm        the distance to travel in kilometres
	#   returns     a hash list [ :lat, :lon, :finalAzimuth, :reducedLength, :arcDegrees ], or [ ]
	#   note        Same solver as DestinationKm
	#   see         DestinationKm, Between
	def DestinationXT(pnLat, pnLon, pnAzimuth, pnKm)
		_r_ = StzEngineGeoGeodesicDirect(@nA, @nF, pnLat, pnLon, pnAzimuth, pnKm * 1000)
		if len(_r_) < 5  return []  ok
		return [ :lat = _r_[1], :lon = _r_[2], :finalAzimuth = _r_[3],
		         :reducedLength = _r_[4], :arcDegrees = _r_[5] ]

	# Returns pnPoints points along the shortest path between two places as [ lon, lat ] pairs, ready to draw.
	#
	#   pnLat1     latitude of the start in degrees north
	#   pnLon1     longitude of the start in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   pnPoints   how many points to return, the two ends included
	#   returns    a list of [ lon, lat ] pairs, the first and last exactly as given
	#   note       The arguments are latitude first but each answered pair is longitude first, the
	#              order a projection takes
	#   see        GeodesicFlat, RhumbLineBetween, Between
	#@ aka  THE PATH ITSELF, as lon/lat pairs ready for a projection. A geodesic drawn as a straight line between its endpoints is a lie on every projection but the gnomonic, and this is how a flight path or a boundary gets drawn honestly: sample the curve on the sphere, then let the projection bend it. The endpoints come back EXACTLY as given, so two segments that share a point still meet.
	def GeodesicBetween(pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)
		_flat_ = StzEngineGeoGeodesicLine(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)
		return This._Pairs(_flat_)

	# Returns pnPoints points along the shortest path as one flat list lon, lat, lon, lat, ... that a projection takes.
	#
	#   pnLat1     latitude of the start in degrees north
	#   pnLon1     longitude of the start in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   pnPoints   how many points to return, the two ends included
	#   returns    a flat list of 2 x pnPoints numbers, longitude first in each pair
	#   note       Pass it straight to stzGeoProjection.Line or DrawLineOn
	#   see        GeodesicBetween, RhumbFlat
	#@ aka  the same as ONE flat list of lon,lat -- what the projection takes
	def GeodesicFlat(pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)
		return StzEngineGeoGeodesicLine(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)

	# Returns the place halfway along the shortest path between two places.
	#
	#   pnLat1     latitude of the start in degrees north
	#   pnLon1     longitude of the start in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   returns    a list [ lat, lon ] in degrees, [ 31.21, 2.22 ] between Niamey and Paris
	#   note       Answers latitude first
	#   see        Between, DestinationKm
	def MidpointOf(pnLat1, pnLon1, pnLat2, pnLon2)
		_r_ = StzEngineGeoGeodesicInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)
		_d_ = StzEngineGeoGeodesicDirect(@nA, @nF, pnLat1, pnLon1, _r_[2], _r_[1] / 2)
		return [ _d_[1], _d_[2] ]

	# Returns the length and the constant bearing of the rhumb line between two places.
	#
	#   pnLat1     latitude of the start in degrees north
	#   pnLon1     longitude of the start in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   returns    a hash list [ :metres, :km, :azimuth ], or [ ]
	#   note       New York to London: 5809.8 km on a constant 78.08 degrees, against 5585.2 km by
	#              the shortest path
	#   see        RhumbDistanceKm, RhumbAzimuth, Between
	#@ aka  -- the rhumb line ------------------------------------------------------
	def RhumbBetween(pnLat1, pnLon1, pnLat2, pnLon2)
		_r_ = StzEngineGeoRhumbInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)
		if len(_r_) < 2  return []  ok
		return [ :metres = _r_[1], :km = _r_[1] / 1000, :azimuth = _r_[2] ]

	# Returns the length of the constant-bearing path between two places, in kilometres.
	#
	#   pnLat1     latitude of the start in degrees north
	#   pnLon1     longitude of the start in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   returns    a number of km, 5809.80 from New York to London
	#   note       Latitude first
	#   see        DistanceKm, RhumbBetween
	def RhumbDistanceKm(pnLat1, pnLon1, pnLat2, pnLon2)
		return StzEngineGeoRhumbInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)[1] / 1000

	# Returns the one bearing that stays constant along the rhumb line between two places, in degrees from north.
	#
	#   pnLat1     latitude of the start in degrees north
	#   pnLon1     longitude of the start in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   returns    a number in degrees, 78.08 from New York to London
	#   note       Latitude first
	#   see        Azimuth, RhumbBetween
	#@ aka  THE ONE BEARING THAT DOES NOT CHANGE along the way, which is what makes this line steerable at all.
	def RhumbAzimuth(pnLat1, pnLon1, pnLat2, pnLon2)
		return StzEngineGeoRhumbInverse(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2)[2]

	# Returns the place reached by holding one bearing for pnKm km.
	#
	#   pnLat       latitude of the start in degrees north
	#   pnLon       longitude of the start in degrees east
	#   pnAzimuth   the constant bearing in degrees clockwise from north
	#   pnKm        the distance to travel in kilometres
	#   returns     a list [ lat, lon ] in degrees
	#   note        Answers latitude first
	#   see         DestinationKm, RhumbBetween
	def RhumbDestinationKm(pnLat, pnLon, pnAzimuth, pnKm)
		return StzEngineGeoRhumbDirect(@nA, @nF, pnLat, pnLon, pnAzimuth, pnKm * 1000)

	# Returns pnPoints points along the rhumb line between two places as [ lon, lat ] pairs.
	#
	#   pnLat1     latitude of the start in degrees north
	#   pnLon1     longitude of the start in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   pnPoints   how many points to return, the two ends included
	#   returns    a list of [ lon, lat ] pairs, the first and last exactly as given
	#   note       A straight line on a Mercator map. Arguments latitude first, answered pairs
	#              longitude first
	#   see        RhumbFlat, GeodesicBetween
	def RhumbLineBetween(pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)
		return This._Pairs(StzEngineGeoRhumbLine(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2, pnPoints))

	# Returns pnPoints points along the rhumb line as one flat list lon, lat, lon, lat, ... that a projection takes.
	#
	#   pnLat1     latitude of the start in degrees north
	#   pnLon1     longitude of the start in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   pnPoints   how many points to return, the two ends included
	#   returns    a flat list of 2 x pnPoints numbers
	#   note       Longitude first in each pair
	#   see        RhumbLineBetween, GeodesicFlat
	def RhumbFlat(pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)
		return StzEngineGeoRhumbLine(@nA, @nF, pnLat1, pnLon1, pnLat2, pnLon2, pnPoints)

	# Returns the distance from the equator to a latitude along a meridian, in kilometres.
	#
	#   pnLat      the latitude in degrees north
	#   returns    a number of km, 4984.94 at 45 degrees and 10001.97 at 90
	#   note       Not R times the angle: the ground is flatter toward the poles
	#   see        LatitudeAtArcKm, QuarterMeridianKm
	#@ aka  -- the meridian and the parallel ---------------------------------------
	def MeridianArcKm(pnLat)
		return StzEngineGeoMeridianArc(@nA, @nF, pnLat) / 1000

	# Returns the latitude lying pnKm km from the equator along a meridian, the inverse of the meridian arc.
	#
	#   pnKm       the distance from the equator along a meridian in kilometres
	#   returns    a number of degrees, 45.1355 for 5000 km
	#   see        MeridianArcKm
	def LatitudeAtArcKm(pnKm)
		return StzEngineGeoLatitudeAtArc(@nA, @nF, pnKm * 1000)

	# Returns the length of the whole circle of one parallel of latitude, in kilometres.
	#
	#   pnLat      the latitude in degrees north
	#   returns    a number of km, 40075.02 at the equator and 20088.00 at 60 degrees
	#   see        DegreeOfLongitudeKm, MeridianArcKm
	#@ aka  the whole way round a parallel of latitude, km
	def ParallelLengthKm(pnLat)
		return StzEngineGeoParallelLength(@nA, @nF, pnLat) / 1000

	# Returns the length in km of a one-degree step of latitude centred on pnLat.
	#
	#   pnLat      the latitude in degrees north at the middle of the degree
	#   returns    a number of km, 110.57 at the equator and 111.69 at 89 degrees
	#   note       Measured as the shortest path from pnLat - 0.5 to pnLat + 0.5 on the same
	#              meridian
	#   see        DegreeOfLongitudeKm
	#@ aka  a degree of latitude, and a degree of longitude, AT a latitude -- the two numbers anybody converting a tolerance into degrees needs
	def DegreeOfLatitudeKm(pnLat)
		return This.DistanceKm(pnLat - 0.5, 0, pnLat + 0.5, 0)

	# Returns the length in km of a one-degree step of longitude along the parallel at pnLat.
	#
	#   pnLat      the latitude in degrees north of the parallel
	#   returns    a number of km, 111.32 at the equator and 55.80 at 60 degrees
	#   note       Measured as the shortest path, which is a little shorter than the parallel itself
	#              at high latitudes
	#   see        DegreeOfLatitudeKm, ParallelLengthKm
	def DegreeOfLongitudeKm(pnLat)
		return This.DistanceKm(pnLat, -0.5, pnLat, 0.5)

	# Returns the Earth-centred Cartesian coordinates, in metres, of a place at a height above the ellipsoid.
	#
	#   pnLat      latitude in degrees north
	#   pnLon      longitude in degrees east
	#   pnHeight   metres above the ellipsoid, not above sea level
	#   returns    a list [ x, y, z ] in metres, [ 6378237, 0, 0 ] for 100 m over the equator at 0 E
	#   note       X through the equator at the prime meridian, Z through the north pole
	#   see        FromEcef, ToEnu
	#@ aka  -- the frames ----------------------------------------------------------
	def ToEcef(pnLat, pnLon, pnHeight)
		return StzEngineGeoToEcef(@nA, @nF, pnLat, pnLon, pnHeight)

	# Returns the latitude, longitude and height of a point given by Earth-centred Cartesian coordinates.
	#
	#   pnX        metres along the axis through the equator at 0 E
	#   pnY        metres along the axis through the equator at 90 E
	#   pnZ        metres along the axis through the north pole
	#   returns    a list [ lat, lon, height ], degrees and metres above the ellipsoid
	#   see        ToEcef, FromEnu
	def FromEcef(pnX, pnY, pnZ)
		return StzEngineGeoFromEcef(@nA, @nF, pnX, pnY, pnZ)

	# Returns the east, north and up offsets in metres of a place from a local origin, in the origin's own frame.
	#
	#   pnLat0     latitude of the origin in degrees north
	#   pnLon0     longitude of the origin in degrees east
	#   pnH0       height of the origin in metres above the ellipsoid
	#   pnLat      latitude of the place in degrees north
	#   pnLon      longitude of the place in degrees east
	#   pnH        height of the place in metres above the ellipsoid
	#   returns    a list [ east, north, up ] in metres
	#   note       Near Niamey, 0.0084 degrees north and 0.0046 degrees east of the origin gives
	#              about 498 m east and 929 m north
	#   see        FromEnu, ToEcef
	#@ aka  ENU: THE LOCAL FRAME A PERSON LIVES IN -- east, north and up in metres about a chosen origin. A radar bearing, a survey offset, a drone's position or a robot's odometry is naturally in this frame, and the trip back out through ECEF is how such a thing lands on a globe.
	def ToEnu(pnLat0, pnLon0, pnH0, pnLat, pnLon, pnH)
		return StzEngineGeoToEnu(@nA, @nF, pnLat0, pnLon0, pnH0, pnLat, pnLon, pnH)

	# Returns the latitude, longitude and height of a point given as east, north and up metres from a local origin.
	#
	#   pnLat0     latitude of the origin in degrees north
	#   pnLon0     longitude of the origin in degrees east
	#   pnH0       height of the origin in metres above the ellipsoid
	#   pnEast     metres east of the origin
	#   pnNorth    metres north of the origin
	#   pnUp       metres above the origin
	#   returns    a list [ lat, lon, height ], degrees and metres
	#   see        ToEnu, FromEcef
	def FromEnu(pnLat0, pnLon0, pnH0, pnEast, pnNorth, pnUp)
		return StzEngineGeoFromEnu(@nA, @nF, pnLat0, pnLon0, pnH0, pnEast, pnNorth, pnUp)

	# Returns the area enclosed by a ring whose edges are geodesics, in square kilometres.
	#
	#   paLonLat   the ring as one flat list lon, lat, lon, lat, ..., closed or not, wound either
	#              way
	#   returns    a number of km2, 12308.78 for the one-degree cell at the equator
	#   note       LONGITUDE FIRST here, unlike the point methods. A ring that encloses a pole is
	#              measured as the cap, not as the rest of the world
	#   see        PerimeterKm, PathLengthKm
	#@ aka  -- the area ------------------------------------------------------------
	def AreaKm2(paLonLat)
		_r_ = StzEngineGeoGeodesicArea(@nA, @nF, paLonLat)
		if len(_r_) < 2  return 0  ok
		return _r_[1] / 1000000

	# Returns the length of the outline of a ring whose edges are geodesics, in kilometres.
	#
	#   paLonLat   the ring as one flat list lon, lat, lon, lat, ...
	#   returns    a number of km, 443.77 for the one-degree cell at the equator
	#   note       Longitude first, and the last point joins the first
	#   see        AreaKm2, PathLengthKm
	def PerimeterKm(paLonLat)
		_r_ = StzEngineGeoGeodesicArea(@nA, @nF, paLonLat)
		if len(_r_) < 2  return 0  ok
		return _r_[2] / 1000

	def AreaXT(paLonLat)
		_r_ = StzEngineGeoGeodesicArea(@nA, @nF, paLonLat)
		if len(_r_) < 2  return []  ok
		return [ :km2 = _r_[1] / 1000000, :m2 = _r_[1],
		         :perimeterKm = _r_[2] / 1000, :perimeterM = _r_[2] ]

	# Returns the length of an open path along geodesics through waypoints, in kilometres.
	#
	#   paLonLat   the waypoints as one flat list lon, lat, lon, lat, ...
	#   returns    a number of km, 3919.43 for a path made of Niamey and Paris; 0 for fewer than two
	#              points
	#   note       Longitude first, unlike DistanceKm
	#   see        AreaKm2, DistanceKm
	#@ aka  the length of an open path along geodesics, km -- a river, a route, a flight plan with waypoints
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

