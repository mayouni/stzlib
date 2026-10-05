#---------------------------------------------------------------------------#
#  STZGEOPROJECTION -- the sphere, on paper (GE0)                            #
#---------------------------------------------------------------------------#
#
#     oP = new stzGeoProjection(:Orthographic)
#     oP.RotateQ([ -20, -30, 0 ]).FitToSphere(600, 600, 10)
#     oP.Project(2.35, 48.85)        # Paris, in pixels -- or [] behind the globe
#     oP.Outline()                   # the world's edge, as pieces of polyline
#     oP.Graticule(10)               # meridians and parallels every ten degrees
#     oP.Line([ lon1, lat1, lon2, lat2, ... ])   # a great-circle route, resampled
#
# WHAT THIS IS. Every map is a choice of how to flatten a sphere, and every
# choice lies about something -- area, shape, distance or direction -- so a
# map that does not say which projection it used is asserting a thing it
# cannot check. This object IS that choice, named, with its parameters, and
# it answers the two questions a picture will ask of it: where does a place
# go, and what place is under this pixel.
#
# WHERE THE WORK RUNS. The arithmetic lives in the engine (stz_geo.dll,
# geo_projection.zig): rotation, sixteen projections and their inverses,
# adaptive resampling so a straight edge on the sphere becomes the curve it
# is, clipping at the seam of a flat map and the horizon of a globe. This
# object holds the eleven numbers that define a projection and crosses the
# bridge with them on every call, so nothing engine-side can go stale and
# the Ring object is the single source of truth.
#
# WHAT IS NOT HERE, said plainly: the ellipsoid (every projection treats the
# Earth as a sphere, which is every atlas and no survey); polygon FILL
# across a seam or a horizon (GE0c -- a ring is projected as the line it
# is, and every visible edge lands where it belongs); Albers-USA and
# Robinson.

# the kinds, read from the engine ONCE so the two cannot disagree.
# StzGeoProjectionKinds, not StzGeoProjections: that name belongs to
# stzGeoRegions.ring's own two-projection reader (DN24b), which GE2 will
# rebuild on this object and retire. Until then the two lists coexist and
# this comment is the record that it was seen.
$aStzGeoKinds = []

func StzGeoProjectionKinds()
	if len($aStzGeoKinds) = 0
		_n_ = StzEngineGeoKindCount()
		for _i_ = 0 to _n_ - 1
			$aStzGeoKinds + StzEngineGeoKindName(_i_)
		next
	ok
	return $aStzGeoKinds

func StzGeoKindNumber(pKind)
	_c_ = StzLower(ring_trim("" + pKind))
	_a_ = StzGeoProjectionKinds()
	for _i_ = 1 to len(_a_)
		if StzLower(_a_[_i_]) = _c_  return _i_ - 1  ok
	next
	stzraise("stzGeoProjection: '" + pKind + "' is not a projection the engine knows -- " +
		"one of " + _GeoNames(_a_) + ".")

func _GeoNames(paList)
	_c_ = ""
	for _i_ = 1 to len(paList)
		if _i_ > 1  _c_ += ", "  ok
		_c_ += "" + paList[_i_]
	next
	return _c_

# A circle of angular radius r around (lon, lat), n points, closed: what a
# range ring is, and what Tissot's indicatrix is before it is projected.
func StzGeoCircle(pnLon, pnLat, pnRadiusDeg, pnPoints)
	return StzEngineGeoCircle(pnLon, pnLat, pnRadiusDeg, pnPoints)

# the same circle with its radius in kilometres, on a sphere of 6371 km
func StzGeoCircleKm(pnLon, pnLat, pnRadiusKm, pnPoints)
	return StzEngineGeoCircle(pnLon, pnLat, pnRadiusKm / 6371 * 180 / 3.141592653589793, pnPoints)

# the point a fraction t of the way from one place to another along the
# GREAT CIRCLE -- what "the line between two places" means on a sphere
func StzGeoInterpolate(pnLon1, pnLat1, pnLon2, pnLat2, pnT)
	return StzEngineGeoInterpolate(pnLon1, pnLat1, pnLon2, pnLat2, pnT)

# the great circle from one place to another as n+1 points, ready to be a
# line on any projection
func StzGeoArc(pnLon1, pnLat1, pnLon2, pnLat2, pnSteps)
	_a_ = []
	for _i_ = 0 to pnSteps
		_p_ = StzEngineGeoInterpolate(pnLon1, pnLat1, pnLon2, pnLat2, _i_ / pnSteps)
		_a_ + _p_[1]
		_a_ + _p_[2]
	next
	return _a_

# WGS84'S TWO DEFINING NUMBERS, read from the engine rather than written
# here. A second copy of 6378137 and 1/298.257223563 in a Ring file is a
# second place for them to be wrong, and this plane has paid for a duplicated
# definition three times in one week.
# ...and NOT cached in a global. The first version of these two put the
# pair in $nStzGeoW84A/F on first use and every geo guard died on
# "using uninitialized variable" -- Ring will not READ a global that has
# not been written, so a lazily-filled one is a landmine under whichever
# caller arrives first. A global would have been the wrong shape even
# working: this repository has a standing rule against library code
# reading a global a caller can overwrite, learned when a caller's `nL`
# replaced the newline constant with a number. The lookup is a table read
# behind a geodesic solve that costs a thousand times more.
func StzGeoWGS84A()
	return StzEngineGeoEllipsoidAt(1)[1]

func StzGeoWGS84F()
	return StzEngineGeoEllipsoidAt(1)[2]

# THE AREA OF A RING, km2, ON THE ELLIPSOID -- WGS84, because that is what
# the area of a country means and what every published figure is measured
# on. Its edges are taken as GEODESICS, so a box drawn along parallels must
# be densified first if it is to measure as the box somebody drew.
#
# THIS USED TO BE A SPHERE OF 6371 km AND THE CHANGE IS THE POINT OF GE8.
# The spherical answer is still here, one function down, under a name that
# says so -- so nothing is lost, the gap between the two can be measured,
# and no caller gets the old number while reading a name that does not
# mention a sphere. On the 110m world file the two differ by 108,000 km2
# out of 147 million.
func StzGeoRingAreaKm2(paLonLat)
	return StzEngineGeoGeodesicArea(StzGeoWGS84A(), StzGeoWGS84F(), paLonLat)[1] / 1000000

# ...and the same ring on the sphere this plane used until GE8, great
# circles for edges and a radius of 6371 km. It is what the SPATIAL
# STATISTICS still work on -- Ripley's K, the kernel densities, the
# envelopes -- because every one of those estimators is built on a constant
# radius, and moving them to the ellipsoid is GE7's business and not this
# plane's. Naming it here is how that boundary stays visible.
func StzGeoRingAreaOnSphereKm2(paLonLat)
	return fabs(StzEngineGeoRingArea(paLonLat)) * 6371 * 6371

# is this place inside that ring, on the sphere?
func StzGeoRingContains(paLonLat, pnLon, pnLat)
	return StzEngineGeoRingContains(paLonLat, pnLon, pnLat) = 1

# HOW FAR APART TWO PLACES ARE, km, ALONG THE SHORTEST PATH ON WGS84.
# From (-0.13, 51.51) to (2.35, 48.85) it is 344.804 km; the sphere said
# 344.438, and a GPS agrees with the first. See StzGeoDistanceOnSphereKm
# for the old answer, and the note there for why the spatial statistics
# still measure with it.
func StzGeoDistanceKm(pnLon1, pnLat1, pnLon2, pnLat2)
	return StzEngineGeoGeodesicInverse(StzGeoWGS84A(), StzGeoWGS84F(),
		pnLat1, pnLon1, pnLat2, pnLon2)[1] / 1000

# the haversine on a sphere of 6371 km -- what the engine's spatial
# statistics measure with, so anything cross-checking them must ask for it
# BY THIS NAME rather than get it by accident
func StzGeoDistanceOnSphereKm(pnLon1, pnLat1, pnLon2, pnLat2)
	return StzEngineGeoHaversine(pnLat1, pnLon1, pnLat2, pnLon2)

# the same distance as an angle at the centre of the sphere, degrees
func StzGeoAngularDistance(pnLon1, pnLat1, pnLon2, pnLat2)
	return StzEngineGeoHaversine(pnLat1, pnLon1, pnLat2, pnLon2) / 6371 * 180 / 3.141592653589793

# THE PROJECTION AN ATLAS WOULD CHOOSE FOR ONE COUNTRY, and the reason it
# is not the caller's problem. A country is a small piece of a sphere, so
# the question is never "which of sixteen" but "where are its parallels":
# a conic whose two standard parallels sit inside the country's own
# latitude span is shape-true through the middle of it and wrong nowhere
# anybody is looking.
#
# The rule is the cartographer's and is a century old: the parallels go at
# a SIXTH and FIVE SIXTHS of the latitude span, and the central meridian at
# the middle of the longitude span. For Niger that is 12.7N and 20.7N; for
# Tunisia 31.7N and 36.4N; for France 43.1N and 49.4N.
#
# EQUAL-AREA BY DEFAULT, because a country map is nearly always a
# choropleth and the gate would refuse a conformal one under one. A caller
# who wants shapes over quantities asks for :ConicConformal by name.
func StzGeoConicFor(poFeatures, pcKind)
	_b_ = poFeatures.Bounds()
	if len(_b_) < 4
		stzraise("StzGeoConicFor: those features have no extent to fit a conic to.")
	ok
	_k_ = pcKind
	if NOT (isString(_k_) and len(_k_) > 0)  _k_ = :ConicEqualArea  ok
	_o_ = new stzGeoProjection(_k_)
	_span_ = _b_[4] - _b_[2]
	_o_.Parallels([ _b_[2] + _span_ / 6, _b_[2] + _span_ * 5 / 6 ])
	_o_.Rotate([ -(_b_[1] + _b_[3]) / 2, 0, 0 ])
	return _o_

#----------------------------------------------------------------------#
#  GE9 -- UTM: sixty transverse Mercators, and two that are not tidy    #
#----------------------------------------------------------------------#

# UTM IS THE PROJECTION EVERY SURVEY FALLS BACK TO. Sixty zones of six
# degrees each, every one a transverse Mercator on its own central
# meridian, every one scaled by 0.9996 so the error is SHARED between the
# middle of the zone and its edges rather than piled at the edges. Within a
# zone it is good to about one part in 2500, which is why a military map, a
# cadastre and a GPS receiver all speak it.
#
# THE EXCEPTIONS ARE REAL AND ARE NOT TIDY. Zone 32 was widened in 1950 so
# that south-west Norway is not cut in half, and the Svalbard zones were
# rearranged for the same reason. A library that computes the zone
# arithmetically and stops is wrong for two countries -- and wrong
# silently, which is worse.
#
# Answers [ :zone, :band, :north, :centralMeridian, :falseEasting,
#           :falseNorthing ]. The false easting and northing are a
# coordinate CONVENTION rather than part of the projection: 500000 metres
# so no easting is negative, and ten million in the south so no northing
# is either. That is the whole reason they exist.
func StzGeoUtmZoneOf(pnLon, pnLat)
	_v_ = StzEngineGeoUtmZone(pnLon, pnLat)
	if len(_v_) < 6  return []  ok
	return [ :zone = _v_[1], :band = char(_v_[4]), :north = (_v_[2] = 1),
	         :centralMeridian = _v_[3],
	         :falseEasting = _v_[5], :falseNorthing = _v_[6] ]

# ...and the projection for a zone, ready to use.
func StzGeoUtmProjection(pnZone)
	_v_ = StzEngineGeoUtmProjection(pnZone)
	_p_ = new stzGeoProjection(:TransverseMercator)
	if len(_v_) >= 11
		_p_.Rotate([ _v_[2], _v_[3], _v_[4] ])
		_p_.Scale(_v_[7])
		_p_.Translate([ _v_[8], _v_[9] ])
	ok
	return _p_

# the zone a longitude falls in by arithmetic alone, WITHOUT the Norway and
# Svalbard exceptions -- here so a caller can see the gap for themselves
# rather than take it on trust
func StzGeoUtmZoneArithmetic(pnLon)
	_l_ = pnLon
	while _l_ < -180  _l_ += 360  end
	while _l_ >= 180  _l_ -= 360  end
	return floor((_l_ + 180) / 6) + 1

# Holds the choice of how to flatten the sphere: one of 44 named projections with its rotation, parallels, scale and clip, and answers where a place goes on paper and what place a pixel is.
#
# The object keeps eleven numbers (Params) and crosses the bridge to the engine with them on every
# call, so the Ring object is the single source of truth. Project takes LONGITUDE FIRST, then
# latitude, and answers paper units with y growing downward, or an empty list for a place behind a
# globe or without an image; Invert goes back. A new projection has scale 150 and translation 480,
# 250: use a Fit method (FitToSphere, FitSphereIn for the world, FitFeaturesIn, FitPointsIn,
# FitFeatureIn for a place) to put the picture in the box you draw in. Lines come back as pieces,
# cut where a flat map's seam or a globe's horizon cuts them. The sphere is a sphere: no projection
# here uses an ellipsoid (stzGeoEllipsoid measures on one). IsEqualArea and IsConformal say what the
# projection claims, Distortion and HoldsItsClaim measure it, and stzGeoMap refuses a choropleth on
# a projection that is not equal-area. Pictures, each looked at by 'stzlib-docs visual pass (a model
# reading the PNG)' on 2026-10-05: doc/gallery/stzGeoProjection/projections_compared.png, six
# projections with Tissot circles, RIGHT (Mercator circles swell toward the poles, the equal-area
# ones keep their size and squash); globe_routes.png, an orthographic globe with great-circle routes
# and range rings, RIGHT; niger_conic_utm.png, Niger on a conic and on a Mercator, RIGHT (the
# printed area scales 1.06 and 1.18 are the secant squared of 13.5 and 23 degrees). Index:
# doc/gallery/INDEX_geo.md.
#
#   receiver   o1 = new stzGeoProjection(:Mercator)
#   example    ? o1.Name()
#              #--> Mercator
#              ? o1.IsConformal()
#              #--> 1
#              ? @@( o1.Project(2.35, 48.85) )
#              #--> [ 486.15, 103.03 ]
#   see        stzGeoMap, stzGeoFeatures, stzGeoEllipsoid
class stzGeoProjection from stzObject
	@nKind = 0
	@aRot = [ 0, 0, 0 ]
	@aPar = [ 30, 30 ]
	@nScale = 150
	@nTx = 480
	@nTy = 250
	@nClip = 0
	@nPrecision = 0.7

	# Builds the projection called pKind (case ignored) with default parameters; raises an error naming all 44 kinds when pKind is unknown.
	#
	#   pKind      the projection's name as text or a symbol, such as :Mercator, :EqualEarth or
	#              :Orthographic
	#   returns    nothing; the object is built
	#   note       The defaults are scale 150, translation 480, 250, no rotation. The conics start
	#              with parallels 30 and 30; the others with 0 and 0
	#   see        Name, StzGeoProjectionKinds
	def init(pKind)
		@nKind = StzGeoKindNumber(pKind)
		_t_ = StzEngineGeoKindTraits(@nKind)
		@nClip = _t_[4]
		# the conics want two standard parallels and default to Albers's
		# for the mid-latitudes; a cylindrical equal-area wants one and
		# defaults to the equator
		if This.IsConic()
			@aPar = [ 30, 30 ]
		else
			@aPar = [ 0, 0 ]
		ok

	# Returns the canonical name of the projection, as the engine spells it.
	#
	#   returns    text, for example "Mercator"
	#   see        KindNumber, Caption
	def Name()
		return StzGeoProjectionKinds()[@nKind + 1]

	# Returns the engine's own index of the projection, counted from 0 in the order StzGeoProjectionKinds lists them.
	#
	#   returns    a number from 0 to 43, 1 for Mercator
	#   see        Name, Params
	def KindNumber()
		return @nKind

	# Returns the eleven numbers that define the projection, in the order the engine reads them.
	#
	#   returns    a list [ kind, yaw, pitch, roll, parallel1, parallel2, scale, translateX,
	#              translateY, clipAngle, precision ]
	#   note       The object holds nothing else, so this list is the whole truth about it
	#   see        Rotate, Scale, Translate, ClipAngle, Precision
	#@ aka  THE ELEVEN NUMBERS, the shape the engine reads
	def Params()
		return [ @nKind, @aRot[1], @aRot[2], @aRot[3], @aPar[1], @aPar[2],
		         @nScale, @nTx, @nTy, @nClip, @nPrecision ]

	# Returns how the projection distorts the map at one place: scales along and across, area scale and bending.
	#
	#   pnLon      longitude in degrees east
	#   pnLat      latitude in degrees north
	#   returns    a hash list [ :h, :k, :a, :b, :areal, :angular, :crossing ]: meridian and
	#              parallel scale, greatest and least scale, area scale, largest angle bent in
	#              degrees, angle at which they cross
	#   note       On Mercator at 70 N the area scale is 8.55 and no angle is bent. 1 means true
	#   see        ArealScaleAt, AngularDistortionAt, Distortion
	#@ aka  -- GE9: WHAT THE LIE MEASURES, not just what it is called --------------
	def DistortionAt(pnLon, pnLat)
		_v_ = StzEngineGeoDistortionAt(This.Params(), pnLon, pnLat)
		if len(_v_) < 7  return []  ok
		return [ :h = _v_[1], :k = _v_[2], :a = _v_[3], :b = _v_[4],
		         :areal = _v_[5], :angular = _v_[6], :crossing = _v_[7] ]

	# Returns how many times larger or smaller than on the ground a small area at this place is drawn.
	#
	#   pnLon      longitude in degrees east
	#   pnLat      latitude in degrees north
	#   returns    a number, 1 where true, 8.55 for Mercator at 70 degrees north, 0 when the place
	#              has no image
	#   note       Equal-area projections answer 1 everywhere
	#   see        DistortionAt, AngularDistortionAt
	#@ aka  HOW MUCH BIGGER OR SMALLER THIS PLACE IS DRAWN than it really is. On a Mercator at 70 degrees it is 8.5, which is the whole Greenland argument in one number.
	def ArealScaleAt(pnLon, pnLat)
		_v_ = StzEngineGeoDistortionAt(This.Params(), pnLon, pnLat)
		if len(_v_) < 7  return 0  ok
		return _v_[5]

	# Returns the largest angle, in degrees, that the projection bends at this place.
	#
	#   pnLon      longitude in degrees east
	#   pnLat      latitude in degrees north
	#   returns    a number of degrees, 0 for a conformal projection and 0 when the place has no
	#              image
	#   see        DistortionAt, ArealScaleAt
	def AngularDistortionAt(pnLon, pnLat)
		_v_ = StzEngineGeoDistortionAt(This.Params(), pnLon, pnLat)
		if len(_v_) < 7  return 0  ok
		return _v_[6]

	# Returns the area and angle distortion of the whole map, weighted by the ground each cell covers, over a 72 by 36 grid.
	#
	#   returns    a hash list [ :arealMin, :arealMax, :arealMean, :angularMax, :angularMean,
	#              :sampled ]
	#   note       Mercator: mean area x3.11 and largest x58.7; EqualEarth: area 1 everywhere and
	#              mean bend 29.1 degrees
	#   see        HoldsItsClaim, DistortionAt
	#@ aka  THE WHOLE MAP AT ONCE, which is how two projections get compared.
	def Distortion()
		return This.DistortionXT(72, 36)

	def DistortionXT(pnCols, pnRows)
		_v_ = StzEngineGeoDistortionSummary(This.Params(), pnCols, pnRows)
		if len(_v_) < 6  return []  ok
		return [ :arealMin = _v_[1], :arealMax = _v_[2], :arealMean = _v_[3],
		         :angularMax = _v_[4], :angularMean = _v_[5], :sampled = _v_[6] ]

	# TRUE if the measured distortion agrees with what the projection claims: area scale 1 for equal-area, no bend for conformal.
	#
	#   returns    TRUE or FALSE
	#   note       A check on the formulas, not on a map
	#   see        Distortion, IsEqualArea, IsConformal
	#@ aka  DOES THIS PROJECTION KEEP ITS OWN PROMISE, measured rather than declared? An equal-area projection whose areal scale is not 1 everywhere has a wrong formula, and so does a conformal one that bends an angle. It is the check that caught two real defects the day this gallery was written -- a Mollweide half with the wrong normalisation, and a symmetry claim made for a projection that is a triangle.
	def HoldsItsClaim()
		_d_ = This.Distortion()
		if len(_d_) = 0  return FALSE  ok
		if This.IsEqualArea()
			if fabs(_d_[:arealMin] - 1) > 0.0001  return FALSE  ok
			if fabs(_d_[:arealMax] - 1) > 0.0001  return FALSE  ok
		ok
		if This.IsConformal()
			if _d_[:angularMax] > 0.0001  return FALSE  ok
		ok
		return TRUE

	# Returns the projected outline of a small circle of true radius pnRadiusDeg around a place, Tissot's indicatrix, 48 points.
	#
	#   pnLon         longitude in degrees east of the circle's centre
	#   pnLat         latitude in degrees north of the circle's centre
	#   pnRadiusDeg   radius of the circle on the ground, in degrees of arc
	#   returns       a flat list of 96 numbers x, y, x, y, ... in paper units, to draw as a closed
	#                 polygon
	#   note          Built by projecting the circle, so it shows the bending an ellipse could not
	#   see           DrawTissotOn, DistortionAt
	#@ aka  TISSOT'S INDICATRIX AS A RING TO DRAW, in the paper's own coordinates.
	def IndicatrixAt(pnLon, pnLat, pnRadiusDeg)
		return This.IndicatrixAtXT(pnLon, pnLat, pnRadiusDeg, 48)

	def IndicatrixAtXT(pnLon, pnLat, pnRadiusDeg, pnPoints)
		return StzEngineGeoIndicatrix(This.Params(), pnLon, pnLat, pnRadiusDeg, pnPoints)

	# TRUE if the projection preserves areas, so a region of the ground has the same area on paper everywhere.
	#
	#   returns    TRUE or FALSE
	#   note       A choropleth of a density wants this
	#   see        IsConformal, HoldsItsClaim
	#@ aka  -- what kind of lie this projection tells -----------------------------
	def IsEqualArea()
		return StzEngineGeoKindTraits(@nKind)[1] = 1

	# TRUE if the projection preserves angles, so small shapes keep their form.
	#
	#   returns    TRUE or FALSE
	#   see        IsEqualArea
	def IsConformal()
		return StzEngineGeoKindTraits(@nKind)[2] = 1

	# TRUE if the projection is azimuthal, drawing the sphere around one centre point.
	#
	#   returns    TRUE or FALSE
	#   see        ClipAngle, CenterOn
	def IsAzimuthal()
		return StzEngineGeoKindTraits(@nKind)[3] = 1

	# TRUE if the projection is a cone developed on two standard parallels, whose name starts with Conic.
	#
	#   returns    TRUE or FALSE
	#   note       Polyconic is not counted
	#   see        Parallels
	def IsConic()
		_c_ = StzLower(This.Name())
		return StzLeft(_c_, 5) = "conic"

	# Turns the sphere under the map by yaw, pitch and roll, in degrees, as d3 does; a missing roll is 0.
	#
	#   paLPG      the rotation as [ yaw, pitch, roll ] in degrees, or [ yaw, pitch ]
	#   returns    nothing; the rotation is stored
	#   note       To put a place at (lon, lat) in the middle rotate by [ -lon, -lat, 0 ]. A roll
	#              puts north somewhere other than up
	#   see        CenterOn, RotationOf
	#@ aka  -- the parameters ------------------------------------------------------
	def Rotate(paLPG)
		@aRot = [ paLPG[1], paLPG[2], 0 ]
		if len(paLPG) >= 3  @aRot[3] = paLPG[3]  ok

		def RotateQ(paLPG)
			This.Rotate(paLPG)
			return This

	# Rotates the sphere so the place at (pnLon, pnLat) sits in the middle of the map.
	#
	#   pnLon      longitude in degrees east of the new centre
	#   pnLat      latitude in degrees north of the new centre
	#   returns    nothing; the rotation is stored
	#   note       The same as Rotate([ -pnLon, -pnLat, 0 ])
	#   see        Rotate, Center
	def CenterOn(pnLon, pnLat)
		This.Rotate([ -pnLon, -pnLat, 0 ])

		def CenterOnQ(pnLon, pnLat)
			This.CenterOn(pnLon, pnLat)
			return This

	# Sets the standard parallels, in degrees north; a single number serves for both.
	#
	#   paP        a list with one or two latitudes in degrees
	#   returns    nothing; the parallels are stored
	#   note       Used by the conics and the cylindrical equal-area; Equirectangular ignores them
	#   see        IsConic
	def Parallels(paP)
		@aPar = [ paP[1], paP[1] ]
		if len(paP) >= 2  @aPar[2] = paP[2]  ok

		def ParallelsQ(paP)
			This.Parallels(paP)
			return This

	# Sets the scale factor, in paper units per radian of the unit sphere; the default is 150.
	#
	#   pn         the scale factor
	#   returns    nothing; the scale is stored
	#   note       A Fit method overwrites it
	#   see        Translate, ScaleOf, FitToSphere
	def Scale(pn)
		@nScale = pn

		def ScaleQ(pn)
			This.Scale(pn)
			return This

	# Sets where the centre of the projection falls on the paper; the default is 480, 250.
	#
	#   paXY       the paper position of the centre as [ x, y ]
	#   returns    nothing; the translation is stored
	#   note       It REPLACES the translation a Fit just computed instead of adding to it
	#   see        Scale, TranslateOf
	def Translate(paXY)
		@nTx = paXY[1]
		@nTy = paXY[2]

		def TranslateQ(paXY)
			This.Translate(paXY)
			return This

	# Sets the angle from the centre, in degrees, beyond which an azimuthal map shows nothing.
	#
	#   pn         the clip angle in degrees, 0 for no clipping
	#   returns    nothing; the angle is stored
	#   note       Defaults seen: 90 for Orthographic, 142 for Stereographic, 0 for Mercator. With
	#              60, a place 70 degrees from the centre has no image
	#   see        IsAzimuthal
	def ClipAngle(pn)
		@nClip = pn

		def ClipAngleQ(pn)
			This.ClipAngle(pn)
			return This

	# Sets how closely lines follow curves: the tolerance, in paper units, below which the engine stops adding points.
	#
	#   pn         the tolerance, 0.7 by default and smaller for a smoother line
	#   returns    nothing; the precision is stored
	#   note       A straight parallel on Mercator needs no extra point whatever the value
	#   see        Line, Ring
	def Precision(pn)
		@nPrecision = pn

		def PrecisionQ(pn)
			This.Precision(pn)
			return This

	# Returns the scale factor set by Scale or by a Fit method.
	#
	#   returns    a number
	#   see        Scale, FitToSphere
	def ScaleOf()
		return @nScale

	# Returns where the centre of the projection falls on the paper.
	#
	#   returns    a list [ x, y ]
	#   see        Translate
	def TranslateOf()
		return [ @nTx, @nTy ]

	# Returns the rotation as it is stored.
	#
	#   returns    a list [ yaw, pitch, roll ] in degrees
	#   see        Rotate, CenterOn
	def RotationOf()
		return @aRot

	# Sets the scale and translation so the whole sphere fills a box of pnW by pnH at the origin, leaving pnPad of air.
	#
	#   pnW        width of the box in paper units
	#   pnH        height of the box in paper units
	#   pnPad      the empty margin kept on each side
	#   returns    nothing; scale and translation are stored
	#   note       Raises an error when nothing of the sphere projects. Mercator is cut at about 85
	#              degrees
	#   see        FitSphereIn, FitToPoints
	#@ aka  -- fitting -------------------------------------------------------------
	def FitToSphere(pnW, pnH, pnPad)
		_pp_ = This.Params()
		_a_ = StzEngineGeoFitSphere(_pp_, 0, 0, pnW, pnH, pnPad)
		if len(_a_) < 3
			stzraise("stzGeoProjection.FitToSphere: nothing of the sphere projects with these parameters.")
		ok
		@nScale = _a_[1]
		@nTx = _a_[2]
		@nTy = _a_[3]

		def FitToSphereQ(pnW, pnH, pnPad)
			This.FitToSphere(pnW, pnH, pnPad)
			return This

	# Sets the scale and translation so the whole sphere fills the box x0, y0, x1, y1 on a larger sheet.
	#
	#   pnX0       left edge of the box
	#   pnY0       top edge of the box
	#   pnX1       right edge of the box
	#   pnY1       bottom edge of the box
	#   pnPad      the empty margin kept on each side
	#   returns    nothing; scale and translation are stored
	#   note       Raises an error when nothing of the sphere projects
	#   see        FitToSphere, FitFeaturesIn
	#@ aka  the same for a box [x0, y0, x1, y1] on a larger sheet
	def FitSphereIn(pnX0, pnY0, pnX1, pnY1, pnPad)
		_pp_ = This.Params()
		_a_ = StzEngineGeoFitSphere(_pp_, pnX0, pnY0, pnX1, pnY1, pnPad)
		if len(_a_) < 3
			stzraise("stzGeoProjection.FitSphereIn: nothing of the sphere projects with these parameters.")
		ok
		@nScale = _a_[1]
		@nTx = _a_[2]
		@nTy = _a_[3]

		def FitSphereInQ(pnX0, pnY0, pnX1, pnY1, pnPad)
			This.FitSphereIn(pnX0, pnY0, pnX1, pnY1, pnPad)
			return This

	# Sets the scale and translation so the given places fill a box of pnW by pnH at the origin.
	#
	#   paLonLat   the places as one flat list lon, lat, lon, lat, ...
	#   pnW        width of the box in paper units
	#   pnH        height of the box in paper units
	#   pnPad      the empty margin kept on each side
	#   returns    nothing; scale and translation are stored
	#   note       Raises an error when none of the points projects. Use it before Translate, never
	#              after
	#   see        FitPointsIn, FitToFeatures
	#@ aka  scale and place so these points fill the box: what a map of one country asks for
	def FitToPoints(paLonLat, pnW, pnH, pnPad)
		_pp_ = This.Params()
		_a_ = StzEngineGeoFitPoints(_pp_, paLonLat, 0, 0, pnW, pnH, pnPad)
		if len(_a_) < 3
			stzraise("stzGeoProjection.FitToPoints: none of the points project with these parameters.")
		ok
		@nScale = _a_[1]
		@nTx = _a_[2]
		@nTy = _a_[3]

		def FitToPointsQ(paLonLat, pnW, pnH, pnPad)
			This.FitToPoints(paLonLat, pnW, pnH, pnPad)
			return This

	# Sets the scale and translation so all the features of a set fill the box x0, y0, x1, y1: what drawing one country means.
	#
	#   poFeatures   a stzGeoFeatures holding the boundaries
	#   pnX0         left edge of the box
	#   pnY0         top edge of the box
	#   pnX1         right edge of the box
	#   pnY1         bottom edge of the box
	#   pnPad        the empty margin kept on each side
	#   returns      nothing; scale and translation are stored
	#   note         The sheet shows only the fitted extent: one feature that lies far from the
	#                rest, such as an island across the antimeridian, shrinks the rest to a speck
	#   see          FitToFeatures, FitFeatureIn, FitSphereIn
	#@ aka  scale and place so ALL the features fill the box. This is what "draw Tunisia" means, and it is NOT FitToSphere -- which fits the whole globe and leaves a country a speck in the middle of it. The first sheet of the three countries was drawn that way and came out as three clusters of labels over nothing at all.
	def FitFeaturesIn(poFeatures, pnX0, pnY0, pnX1, pnY1, pnPad)
		_pp_ = This.Params()
		_a_ = StzEngineGeoFitPoints(_pp_, poFeatures.AllPoints(), pnX0, pnY0, pnX1, pnY1, pnPad)
		if len(_a_) < 3
			stzraise("stzGeoProjection.FitFeaturesIn: none of those features project.")
		ok
		@nScale = _a_[1]
		@nTx = _a_[2]
		@nTy = _a_[3]

		def FitFeaturesInQ(poFeatures, pnX0, pnY0, pnX1, pnY1, pnPad)
			This.FitFeaturesIn(poFeatures, pnX0, pnY0, pnX1, pnY1, pnPad)
			return This

	# Sets the scale and translation so the given places fill the box x0, y0, x1, y1 of a larger sheet.
	#
	#   paLonLat   the places as one flat list lon, lat, lon, lat, ...
	#   pnX0       left edge of the box
	#   pnY0       top edge of the box
	#   pnX1       right edge of the box
	#   pnY1       bottom edge of the box
	#   pnPad      the empty margin kept on each side
	#   returns    nothing; scale and translation are stored
	#   note       The way to fit a window of the world on a Mercator, which runs to infinity at the
	#              poles
	#   see        FitToPoints, FitFeaturesIn
	#@ aka  THE SIBLING FitFeaturesIn AND FitFeatureIn ALREADY HAD, and the one a caller needs to fit a WINDOW OF THE WORLD into a box: Mercator runs to infinity at the poles, so a world sheet on it is fitted to a lon/lat box cut at about 83 degrees rather than to the features themselves.
	def FitPointsIn(paLonLat, pnX0, pnY0, pnX1, pnY1, pnPad)
		_pp_ = This.Params()
		_a_ = StzEngineGeoFitPoints(_pp_, paLonLat, pnX0, pnY0, pnX1, pnY1, pnPad)
		if len(_a_) < 3
			stzraise("stzGeoProjection.FitPointsIn: none of those points project " +
				"with these parameters.")
		ok
		@nScale = _a_[1]
		@nTx = _a_[2]
		@nTy = _a_[3]

		def FitPointsInQ(paLonLat, pnX0, pnY0, pnX1, pnY1, pnPad)
			This.FitPointsIn(paLonLat, pnX0, pnY0, pnX1, pnY1, pnPad)
			return This

	# Sets the scale and translation so all the features fill a box of pnW by pnH at the origin.
	#
	#   poFeatures   a stzGeoFeatures holding the boundaries
	#   pnW          width of the box in paper units
	#   pnH          height of the box in paper units
	#   pnPad        the empty margin kept on each side
	#   returns      nothing; scale and translation are stored
	#   see          FitFeaturesIn, FitToFeature
	def FitToFeatures(poFeatures, pnW, pnH, pnPad)
		This.FitToPoints(poFeatures.AllPoints(), pnW, pnH, pnPad)

		def FitToFeaturesQ(poFeatures, pnW, pnH, pnPad)
			This.FitToFeatures(poFeatures, pnW, pnH, pnPad)
			return This

	# Sets the scale and translation so one feature fills a box of pnW by pnH at the origin: zoom to a country.
	#
	#   poFeatures   a stzGeoFeatures holding the boundaries
	#   pnI          the position of the feature, from 1
	#   pnW          width of the box in paper units
	#   pnH          height of the box in paper units
	#   pnPad        the empty margin kept on each side
	#   returns      nothing; scale and translation are stored
	#   see          FitFeatureIn, FitToFeatures
	#@ aka  scale and place so ONE feature fills the box: what "zoom to Tunisia" means, and what a caller does before drawing its governorates
	def FitToFeature(poFeatures, pnI, pnW, pnH, pnPad)
		This.FitToPoints(poFeatures.PointsOf(pnI), pnW, pnH, pnPad)

		def FitToFeatureQ(poFeatures, pnI, pnW, pnH, pnPad)
			This.FitToFeature(poFeatures, pnI, pnW, pnH, pnPad)
			return This

	# Sets the scale and translation so one feature fills the box x0, y0, x1, y1 of a larger sheet.
	#
	#   poFeatures   a stzGeoFeatures holding the boundaries
	#   pnI          the position of the feature, from 1
	#   pnX0         left edge of the box
	#   pnY0         top edge of the box
	#   pnX1         right edge of the box
	#   pnY1         bottom edge of the box
	#   pnPad        the empty margin kept on each side
	#   returns      nothing; scale and translation are stored
	#   note         Raises an error when the feature projects nowhere
	#   see          FitToFeature, FitFeaturesIn
	def FitFeatureIn(poFeatures, pnI, pnX0, pnY0, pnX1, pnY1, pnPad)
		_pp_ = This.Params()
		_a_ = StzEngineGeoFitPoints(_pp_, poFeatures.PointsOf(pnI), pnX0, pnY0, pnX1, pnY1, pnPad)
		if len(_a_) < 3
			stzraise("stzGeoProjection.FitFeatureIn: that feature projects nowhere.")
		ok
		@nScale = _a_[1]
		@nTx = _a_[2]
		@nTy = _a_[3]

		def FitFeatureInQ(poFeatures, pnI, pnX0, pnY0, pnX1, pnY1, pnPad)
			This.FitFeatureIn(poFeatures, pnI, pnX0, pnY0, pnX1, pnY1, pnPad)
			return This

	# Returns the paper position of the place at longitude pnLon and latitude pnLat.
	#
	#   pnLon      longitude in degrees east
	#   pnLat      latitude in degrees north
	#   returns    a list [ x, y ] in paper units with y growing downward, or [ ] when the place is
	#              behind a globe or has no image
	#   note       LONGITUDE FIRST. Mercator at the defaults: Paris (2.35, 48.85) lands at [ 486.15,
	#              103.03 ] and the pole has no image
	#   see        Invert, Line
	#@ aka  -- the two questions ---------------------------------------------------
	def Project(pnLon, pnLat)
		_pp_ = This.Params()
		return StzEngineGeoProject(_pp_, pnLon, pnLat)

	# Returns the place under a paper position, the inverse of Project.
	#
	#   pnX        paper x
	#   pnY        paper y
	#   returns    a list [ lon, lat ] in degrees, or [ ] off the sphere
	#   note       The paper centre of a Mercator at the defaults, 480 and 250, is [ 0, 0 ]
	#   see        Project, Center
	#@ aka  what place a pixel is: [lon, lat], or [] off the sphere
	def Invert(pnX, pnY)
		_pp_ = This.Params()
		return StzEngineGeoInvert(_pp_, pnX, pnY)

	# Returns the visible stretches of a line given by places, resampled so a straight edge on the sphere bends as it should.
	#
	#   paLonLat   the line as one flat list lon, lat, lon, lat, ...
	#   returns    a list of pieces, each a flat list x, y, x, y, ...; two pieces when the map's
	#              seam or a globe's horizon cuts the line
	#   note       The straight segment between two places is a great circle, not a parallel
	#   see        Ring, Arc, DrawLineOn
	#@ aka  -- lines on paper ------------------------------------------------------
	def Line(paLonLat)
		_pp_ = This.Params()
		return StzEngineGeoProjectLine(_pp_, paLonLat)

	# Returns a ring of places as the outline pieces the map leaves of it, cut where the map cuts them.
	#
	#   paLonLat   the ring as one flat list lon, lat, lon, lat, ...
	#   returns    a list of pieces, each a flat list x, y, x, y, ...; not closed polygons
	#   note       To fill a ring use FilledRing
	#   see        FilledRing, Line
	#@ aka  a ring as the LINES it is: pieces, cut where the map cuts them
	def Ring(paLonLat)
		_pp_ = This.Params()
		return StzEngineGeoProjectRing(_pp_, paLonLat)

	# Returns a ring of places as closed polygons, the pieces rejoined along the map's own edge so each can be filled.
	#
	#   paLonLat   the ring as one flat list lon, lat, lon, lat, ...
	#   returns    a list of closed polygons, each a flat list x, y, x, y, ...; a ring across the
	#              seam comes back as two
	#   note       What DrawRingOn draws
	#   see        Ring, DrawRingOn, FilledPolygon
	#@ aka  a ring as the POLYGONS it is (GE0c): the same pieces, rejoined along the map's own edge so each one closes and can be filled. A country across the antimeridian comes back as two polygons that meet the two seams; a continent around the pole comes back as one that runs along the bottom of the map.
	def FilledRing(paLonLat)
		_pp_ = This.Params()
		return StzEngineGeoProjectRingFilled(_pp_, paLonLat)

	# Returns the meridians and parallels every pnStepDeg degrees as lines on the paper.
	#
	#   pnStepDeg   the spacing of the lines in degrees
	#   returns     a list of pieces, each a flat list x, y, x, y, ...
	#   note        The whole sphere, not only the part a fitted window shows
	#   see         DrawGraticuleOn, Outline
	def Graticule(pnStepDeg)
		_pp_ = This.Params()
		return StzEngineGeoGraticule(_pp_, pnStepDeg)

	# Returns the edge of the world as pieces of line on the paper.
	#
	#   returns    a list of pieces, each a flat list x, y, x, y, ...
	#   note       A globe's horizon is a circle; a flat map's is its seam and its poles
	#   see        DrawOutlineOn, Graticule
	def Outline()
		_pp_ = This.Params()
		return StzEngineGeoOutline(_pp_)

	# Returns the great circle between two places as lines on the paper, 64 steps, cut where the map cuts it.
	#
	#   pnLon1     longitude of the start in degrees east
	#   pnLat1     latitude of the start in degrees north
	#   pnLon2     longitude of the end in degrees east
	#   pnLat2     latitude of the end in degrees north
	#   returns    a list of pieces, each a flat list x, y, x, y, ...
	#   note       LONGITUDE FIRST, unlike stzGeoEllipsoid. The path is the sphere's great circle,
	#              not the ellipsoid's geodesic
	#   see        Line, DrawLineOn
	#@ aka  the great circle between two places, as pieces
	def Arc(pnLon1, pnLat1, pnLon2, pnLat2)
		return This.Line(StzGeoArc(pnLon1, pnLat1, pnLon2, pnLat2, 64))

	# Fills the world's outline with a colour and strokes its edge on a canvas: the sea or the sky of a map.
	#
	#   poCanvas    the stzCanvas to draw on
	#   pFill       the fill colour
	#   pStroke     the edge colour
	#   pnStrokeW   the edge width in pixels
	#   returns     nothing; the polygon is added to the canvas
	#   note        Draw it first
	#   see         DrawGraticuleOn, DrawOutlineOn
	#@ aka  -- drawing the base map on a canvas ------------------------------------
	def DrawSphereOn(poCanvas, pFill, pStroke, pnStrokeW)
		_a_ = This.Outline()
		for _i_ = 1 to len(_a_)
			if len(_a_[_i_]) >= 6
				poCanvas.AddPolygonQ(_a_[_i_]).FillQ(pFill).Stroke(pStroke, pnStrokeW)
			ok
		next

	# Draws the meridians and parallels every pnStep degrees on a canvas.
	#
	#   poCanvas    the stzCanvas to draw on
	#   pnStepDeg   the spacing of the lines in degrees
	#   pStroke     the line colour
	#   pnStrokeW   the line width in pixels
	#   returns     nothing; the lines are added to the canvas
	#   note        It draws the whole sphere, so lines show outside a fitted window; draw your own
	#               lines for a small area
	#   see         Graticule, DrawSphereOn
	def DrawGraticuleOn(poCanvas, pnStepDeg, pStroke, pnStrokeW)
		_a_ = This.Graticule(pnStepDeg)
		for _i_ = 1 to len(_a_)
			if len(_a_[_i_]) >= 4
				poCanvas.AddPolylineQ(_a_[_i_]).Stroke(pStroke, pnStrokeW)
			ok
		next

	# Strokes the edge of the world on a canvas.
	#
	#   poCanvas    the stzCanvas to draw on
	#   pStroke     the line colour
	#   pnStrokeW   the line width in pixels
	#   returns     nothing; the line is added to the canvas
	#   see         Outline, DrawSphereOn
	def DrawOutlineOn(poCanvas, pStroke, pnStrokeW)
		_a_ = This.Outline()
		for _i_ = 1 to len(_a_)
			if len(_a_[_i_]) >= 4
				poCanvas.AddPolylineQ(_a_[_i_]).Stroke(pStroke, pnStrokeW)
			ok
		next

	# Strokes a line given by places on a canvas, cut where the map cuts it.
	#
	#   poCanvas    the stzCanvas to draw on
	#   paLonLat    the line as one flat list lon, lat, lon, lat, ...
	#   pStroke     the line colour
	#   pnStrokeW   the line width in pixels
	#   returns     nothing; the pieces are added to the canvas
	#   note        Pass StzGeoArc or a geodesic from stzGeoEllipsoid for a route
	#   see         Line, DrawRingOn
	def DrawLineOn(poCanvas, paLonLat, pStroke, pnStrokeW)
		_a_ = This.Line(paLonLat)
		for _i_ = 1 to len(_a_)
			if len(_a_[_i_]) >= 4
				poCanvas.AddPolylineQ(_a_[_i_]).Stroke(pStroke, pnStrokeW)
			ok
		next

	# Fills a ring of places with a colour and strokes its edge on a canvas, every piece of it.
	#
	#   poCanvas    the stzCanvas to draw on
	#   paLonLat    the ring as one flat list lon, lat, lon, lat, ...
	#   pFill       the fill colour
	#   pStroke     the edge colour
	#   pnStrokeW   the edge width in pixels
	#   returns     nothing; the polygons are added to the canvas
	#   note        Used for range rings and night caps. A transparent fill such as "#00000000"
	#               gives an outline
	#   see         FilledRing, DrawRingOutlineOn
	#@ aka  a ring, FILLED where it came back whole and stroked where the seam or the horizon cut it in two -- a cut piece is not a polygon and filling it would draw a shape the sphere does not have A RING, FILLED -- every piece of it. Since GE0c a cut ring comes back closed along the map's edge, so there is no longer a case where a region can only be outlined.
	def DrawRingOn(poCanvas, paLonLat, pFill, pStroke, pnStrokeW)
		_a_ = This.FilledRing(paLonLat)
		for _i_ = 1 to len(_a_)
			if len(_a_[_i_]) >= 6
				poCanvas.AddPolygonQ(_a_[_i_]).FillQ(pFill).Stroke(pStroke, pnStrokeW)
			ok
		next

	# Returns a polygon with its holes as closed shapes on the paper, each hole bridged into its outer ring.
	#
	#   paRings    the polygon as a list of rings, each a flat list lon, lat, ...: the outer ring
	#              first, then the holes
	#   returns    a list of closed polygons, each a flat list x, y, x, y, ...
	#   note       A hole whose outer ring the map cuts cannot carry its bridge and is counted by
	#              HolesDropped
	#   see        HolesDropped, DrawFeatureOn
	#@ aka  A POLYGON -- an outer ring and its HOLES (GE1) -- closed on the paper. paRings[1] is the outer edge; every ring after it is a hole, bridged into it so a lake inside a country is not filled in as land.
	def FilledPolygon(paRings)
		_pp_ = This.Params()
		return StzEngineGeoProjectPolygonFilled(_pp_, paRings)

	# Returns how many holes the last FilledPolygon could not give, because the map cut their outer ring.
	#
	#   returns    a number, 0 when every hole was kept
	#   note       A global count of the engine, not of this object
	#   see        FilledPolygon
	#@ aka  how many holes the last FilledPolygon could not give: a hole whose outer ring the map cut cannot carry a bridge, and it is counted
	def HolesDropped()
		return StzEngineGeoHolesDropped()

	# Strokes a ring of places as a line on a canvas, uncut and unfilled.
	#
	#   poCanvas    the stzCanvas to draw on
	#   paLonLat    the ring as one flat list lon, lat, lon, lat, ...
	#   pStroke     the line colour
	#   pnStrokeW   the line width in pixels
	#   returns     nothing; the lines are added to the canvas
	#   see         DrawRingOn, Ring
	#@ aka  ...and the same ring as an outline only, uncut and unfilled
	def DrawRingOutlineOn(poCanvas, paLonLat, pStroke, pnStrokeW)
		_a_ = This.Ring(paLonLat)
		for _i_ = 1 to len(_a_)
			if len(_a_[_i_]) >= 4
				poCanvas.AddPolylineQ(_a_[_i_]).Stroke(pStroke, pnStrokeW)
			ok
		next

	# Draws one feature of a boundary file on a canvas: polygons with their parts and holes, lines as lines, points as circles.
	#
	#   poCanvas     the stzCanvas to draw on
	#   poFeatures   a stzGeoFeatures holding the boundaries
	#   pnI          the position of the feature, from 1
	#   pFill        the fill colour
	#   pStroke      the edge colour
	#   pnStrokeW    the edge width in pixels, 0 for no edge
	#   returns      nothing; the shapes are added to the canvas
	#   note         A point is a circle of radius twice pnStrokeW, so a width of 0 draws no point
	#   see          DrawFeaturesOn, FilledPolygon
	#@ aka  -- a whole feature, from a boundary file (GE1) -------------------------
	def DrawFeatureOn(poCanvas, poFeatures, pnI, pFill, pStroke, pnStrokeW)
		if poFeatures.KindOf(pnI) = "line"
			_a_ = poFeatures.PartsOf(pnI)
			for _i_ = 1 to len(_a_)
				This.DrawLineOn(poCanvas, _a_[_i_][1], pStroke, pnStrokeW)
			next
			return
		ok
		if poFeatures.KindOf(pnI) = "point"
			_a_ = poFeatures.PartsOf(pnI)
			for _i_ = 1 to len(_a_)
				_q_ = This.Project(_a_[_i_][1][1], _a_[_i_][1][2])
				if len(_q_) = 2
					poCanvas.AddCircleQ(_q_[1], _q_[2], pnStrokeW * 2).FillQ(pFill).Stroke(pStroke, 1)
				ok
			next
			return
		ok
		# THE FILL IS THE BRIDGED POLYGON AND THE OUTLINE IS NOT. A hole is
		# bridged into its outer ring by a channel cut between them, and a
		# stroke that followed the bridged ring would draw that channel --
		# a white scratch running from the lake to the coast, which is what
		# the first GE1 picture showed. The rings are stroked as the rings
		# they are, each on its own.
		_a_ = poFeatures.PartsOf(pnI)
		for _i_ = 1 to len(_a_)
			_pcs_ = This.FilledPolygon(_a_[_i_])
			for _k_ = 1 to len(_pcs_)
				if len(_pcs_[_k_]) >= 6
					poCanvas.AddPolygonQ(_pcs_[_k_]).Fill(pFill)
				ok
			next
		next
		if pnStrokeW > 0
			for _i_ = 1 to len(_a_)
				for _r_ = 1 to len(_a_[_i_])
					This.DrawRingOutlineOn(poCanvas, _a_[_i_][_r_], pStroke, pnStrokeW)
				next
			next
		ok

	# Draws every feature of a boundary file on a canvas in one fill and one edge colour.
	#
	#   poCanvas     the stzCanvas to draw on
	#   poFeatures   a stzGeoFeatures holding the boundaries
	#   pFill        the fill colour
	#   pStroke      the edge colour
	#   pnStrokeW    the edge width in pixels, 0 for no edge
	#   returns      nothing; the shapes are added to the canvas
	#   note         stzGeoMap colours each feature by its class instead
	#   see          DrawFeatureOn
	def DrawFeaturesOn(poCanvas, poFeatures, pFill, pStroke, pnStrokeW)
		for _i_ = 1 to poFeatures.Count()
			This.DrawFeatureOn(poCanvas, poFeatures, _i_, pFill, pStroke, pnStrokeW)
		next

	# Draws circles of one true size all over the sphere, as Tissot's indicatrix shows what the projection does to shape and area.
	#
	#   poCanvas      the stzCanvas to draw on
	#   pnRadiusDeg   radius of each circle on the ground in degrees of arc
	#   pnStepDeg     the spacing of the circle centres in degrees
	#   pFill         the fill colour
	#   pStroke       the edge colour
	#   returns       nothing; the polygons are added to the canvas
	#   note          Centres run between 60 S and 60 N; on an azimuthal map a circle near the
	#                 horizon is left out
	#   see           IndicatrixAt, Distortion
	#@ aka  fit the paper to everything a file holds TISSOT'S INDICATRIX: circles of one true size all over the sphere, projected. Where they stay round the projection keeps shapes; where they stay the same size it keeps areas; where they do neither it says so. The honest way to show what a projection does, and it needs no atlas at all.
	def DrawTissotOn(poCanvas, pnRadiusDeg, pnStepDeg, pFill, pStroke)
		# A CIRCLE THAT ENCLOSES THE ANTIPODE OF THE CENTRE IS INSIDE-OUT
		# on an azimuthal map: its inside is everything, so filled it paints
		# the whole disc -- which the first sheet did, in orange, twice. A
		# circle that reaches within its own radius of the horizon is left
		# out here; GE0c will clip it instead of skipping it.
		_bAz_ = This.IsAzimuthal()
		_aC_ = This.Center()
		for _lat_ = -60 to 60 step pnStepDeg
			for _lon_ = -180 + pnStepDeg / 2 to 180 step pnStepDeg
				if _bAz_ and len(_aC_) = 2
					_d_ = StzGeoAngularDistance(_aC_[1], _aC_[2], _lon_, _lat_)
					if _d_ > @nClip - pnRadiusDeg - 1  loop  ok
				ok
				This.DrawRingOn(poCanvas, StzGeoCircle(_lon_, _lat_, pnRadiusDeg, 48), pFill, pStroke, 1)
			next
		next

	# Returns the place at the middle of the paper: the point the rotation puts at the translation.
	#
	#   returns    a list [ lon, lat ] in degrees
	#   see        CenterOn, Invert
	#@ aka  the place at the middle of the paper: what the rotation put there
	def Center()
		_pp_ = This.Params()
		return StzEngineGeoInvert(_pp_, @nTx, @nTy)

	# Returns the projection written for a picture: its name, the parallels of a conic and the rotation if any.
	#
	#   returns    text such as "ConicEqualArea (13.67N, 21.56N) rotated -8.08, 0, 0"
	#   warning    Defect: the parallels of a conic always carry an N, so 22.78 degrees south prints
	#              as -22.78N.
	#   see        stzGeoMap.Caption
	#@ aka  the projection, named on the picture: a map that does not say how it was flattened is asserting what it cannot check
	def Caption()
		_c_ = This.Name()
		if This.IsConic()
			_c_ += " (" + @aPar[1] + "N, " + @aPar[2] + "N)"
		ok
		if @aRot[1] != 0 or @aRot[2] != 0 or @aRot[3] != 0
			_c_ += " rotated " + @aRot[1] + ", " + @aRot[2] + ", " + @aRot[3]
		ok
		return _c_
