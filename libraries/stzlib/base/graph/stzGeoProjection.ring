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

# the area of a ring on the sphere, in square kilometres (6371 km radius).
# The ring's edges are taken as great circles, so a box drawn along
# parallels must be densified first to measure as the box it is.
func StzGeoRingAreaKm2(paLonLat)
	return fabs(StzEngineGeoRingArea(paLonLat)) * 6371 * 6371

# is this place inside that ring, on the sphere?
func StzGeoRingContains(paLonLat, pnLon, pnLat)
	return StzEngineGeoRingContains(paLonLat, pnLon, pnLat) = 1

func StzGeoDistanceKm(pnLon1, pnLat1, pnLon2, pnLat2)
	return StzEngineGeoHaversine(pnLat1, pnLon1, pnLat2, pnLon2)

# the same distance as an angle at the centre of the sphere, degrees
func StzGeoAngularDistance(pnLon1, pnLat1, pnLon2, pnLat2)
	return StzEngineGeoHaversine(pnLat1, pnLon1, pnLat2, pnLon2) / 6371 * 180 / 3.141592653589793

class stzGeoProjection from stzObject
	@nKind = 0
	@aRot = [ 0, 0, 0 ]
	@aPar = [ 30, 30 ]
	@nScale = 150
	@nTx = 480
	@nTy = 250
	@nClip = 0
	@nPrecision = 0.7

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

	def Name()
		return StzGeoProjectionKinds()[@nKind + 1]

	def KindNumber()
		return @nKind

	# THE ELEVEN NUMBERS, the shape the engine reads
	def Params()
		return [ @nKind, @aRot[1], @aRot[2], @aRot[3], @aPar[1], @aPar[2],
		         @nScale, @nTx, @nTy, @nClip, @nPrecision ]

	#-- what kind of lie this projection tells -----------------------------

	def IsEqualArea()
		return StzEngineGeoKindTraits(@nKind)[1] = 1

	def IsConformal()
		return StzEngineGeoKindTraits(@nKind)[2] = 1

	def IsAzimuthal()
		return StzEngineGeoKindTraits(@nKind)[3] = 1

	def IsConic()
		_c_ = StzLower(This.Name())
		return StzLeft(_c_, 5) = "conic"

	#-- the parameters ------------------------------------------------------

	# yaw, pitch, roll in degrees: d3's [lambda, phi, gamma]. To centre a
	# globe on a place at (lon, lat), rotate by [-lon, -lat, 0].
	def Rotate(paLPG)
		@aRot = [ paLPG[1], paLPG[2], 0 ]
		if len(paLPG) >= 3  @aRot[3] = paLPG[3]  ok

		def RotateQ(paLPG)
			This.Rotate(paLPG)
			return This

	def CenterOn(pnLon, pnLat)
		This.Rotate([ -pnLon, -pnLat, 0 ])

		def CenterOnQ(pnLon, pnLat)
			This.CenterOn(pnLon, pnLat)
			return This

	def Parallels(paP)
		@aPar = [ paP[1], paP[1] ]
		if len(paP) >= 2  @aPar[2] = paP[2]  ok

		def ParallelsQ(paP)
			This.Parallels(paP)
			return This

	def Scale(pn)
		@nScale = pn

		def ScaleQ(pn)
			This.Scale(pn)
			return This

	def Translate(paXY)
		@nTx = paXY[1]
		@nTy = paXY[2]

		def TranslateQ(paXY)
			This.Translate(paXY)
			return This

	def ClipAngle(pn)
		@nClip = pn

		def ClipAngleQ(pn)
			This.ClipAngle(pn)
			return This

	def Precision(pn)
		@nPrecision = pn

		def PrecisionQ(pn)
			This.Precision(pn)
			return This

	def ScaleOf()
		return @nScale

	def TranslateOf()
		return [ @nTx, @nTy ]

	def RotationOf()
		return @aRot

	#-- fitting -------------------------------------------------------------

	# scale and place so the WHOLE sphere fills a w x h box with pad px of
	# air: what a world map asks for
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

	# the same for a box [x0, y0, x1, y1] on a larger sheet
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

	# scale and place so these points fill the box: what a map of one
	# country asks for
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

	#-- the two questions ---------------------------------------------------

	# where a place goes: [x, y] in pixels, or [] when it is behind the
	# globe or has no image on this projection
	def Project(pnLon, pnLat)
		_pp_ = This.Params()
		return StzEngineGeoProject(_pp_, pnLon, pnLat)

	# what place a pixel is: [lon, lat], or [] off the sphere
	def Invert(pnX, pnY)
		_pp_ = This.Params()
		return StzEngineGeoInvert(_pp_, pnX, pnY)

	#-- lines on paper ------------------------------------------------------
	#
	# Each answers PIECES: a list of flat [x1, y1, x2, y2, ...] polylines,
	# one per visible stretch. A line that goes behind a globe or crosses
	# the seam of a flat map comes back in two, cut exactly at the edge.

	def Line(paLonLat)
		_pp_ = This.Params()
		return StzEngineGeoProjectLine(_pp_, paLonLat)

	# a ring as the LINES it is: pieces, cut where the map cuts them
	def Ring(paLonLat)
		_pp_ = This.Params()
		return StzEngineGeoProjectRing(_pp_, paLonLat)

	# a ring as the POLYGONS it is (GE0c): the same pieces, rejoined along
	# the map's own edge so each one closes and can be filled. A country
	# across the antimeridian comes back as two polygons that meet the two
	# seams; a continent around the pole comes back as one that runs along
	# the bottom of the map.
	def FilledRing(paLonLat)
		_pp_ = This.Params()
		return StzEngineGeoProjectRingFilled(_pp_, paLonLat)

	def Graticule(pnStepDeg)
		_pp_ = This.Params()
		return StzEngineGeoGraticule(_pp_, pnStepDeg)

	def Outline()
		_pp_ = This.Params()
		return StzEngineGeoOutline(_pp_)

	# the great circle between two places, as pieces
	def Arc(pnLon1, pnLat1, pnLon2, pnLat2)
		return This.Line(StzGeoArc(pnLon1, pnLat1, pnLon2, pnLat2, 64))

	#-- drawing the base map on a canvas ------------------------------------
	#
	# The sphere's fill, the graticule and the outline: what every map
	# stands on. Colours are the caller's; the shapes are the engine's.

	def DrawSphereOn(poCanvas, pFill, pStroke, pnStrokeW)
		_a_ = This.Outline()
		for _i_ = 1 to len(_a_)
			if len(_a_[_i_]) >= 6
				poCanvas.AddPolygonQ(_a_[_i_]).FillQ(pFill).Stroke(pStroke, pnStrokeW)
			ok
		next

	def DrawGraticuleOn(poCanvas, pnStepDeg, pStroke, pnStrokeW)
		_a_ = This.Graticule(pnStepDeg)
		for _i_ = 1 to len(_a_)
			if len(_a_[_i_]) >= 4
				poCanvas.AddPolylineQ(_a_[_i_]).Stroke(pStroke, pnStrokeW)
			ok
		next

	def DrawOutlineOn(poCanvas, pStroke, pnStrokeW)
		_a_ = This.Outline()
		for _i_ = 1 to len(_a_)
			if len(_a_[_i_]) >= 4
				poCanvas.AddPolylineQ(_a_[_i_]).Stroke(pStroke, pnStrokeW)
			ok
		next

	def DrawLineOn(poCanvas, paLonLat, pStroke, pnStrokeW)
		_a_ = This.Line(paLonLat)
		for _i_ = 1 to len(_a_)
			if len(_a_[_i_]) >= 4
				poCanvas.AddPolylineQ(_a_[_i_]).Stroke(pStroke, pnStrokeW)
			ok
		next

	# a ring, FILLED where it came back whole and stroked where the seam or
	# the horizon cut it in two -- a cut piece is not a polygon and filling
	# it would draw a shape the sphere does not have
	# A RING, FILLED -- every piece of it. Since GE0c a cut ring comes back
	# closed along the map's edge, so there is no longer a case where a
	# region can only be outlined.
	def DrawRingOn(poCanvas, paLonLat, pFill, pStroke, pnStrokeW)
		_a_ = This.FilledRing(paLonLat)
		for _i_ = 1 to len(_a_)
			if len(_a_[_i_]) >= 6
				poCanvas.AddPolygonQ(_a_[_i_]).FillQ(pFill).Stroke(pStroke, pnStrokeW)
			ok
		next

	# A POLYGON -- an outer ring and its HOLES (GE1) -- closed on the paper.
	# paRings[1] is the outer edge; every ring after it is a hole, bridged
	# into it so a lake inside a country is not filled in as land.
	def FilledPolygon(paRings)
		_pp_ = This.Params()
		return StzEngineGeoProjectPolygonFilled(_pp_, paRings)

	# how many holes the last FilledPolygon could not give: a hole whose
	# outer ring the map cut cannot carry a bridge, and it is counted
	def HolesDropped()
		return StzEngineGeoHolesDropped()

	# ...and the same ring as an outline only, uncut and unfilled
	def DrawRingOutlineOn(poCanvas, paLonLat, pStroke, pnStrokeW)
		_a_ = This.Ring(paLonLat)
		for _i_ = 1 to len(_a_)
			if len(_a_[_i_]) >= 4
				poCanvas.AddPolylineQ(_a_[_i_]).Stroke(pStroke, pnStrokeW)
			ok
		next

	#-- a whole feature, from a boundary file (GE1) -------------------------

	# every part of it, each with its holes -- the islands DN24b's reader
	# dropped and the lakes it filled in
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

	def DrawFeaturesOn(poCanvas, poFeatures, pFill, pStroke, pnStrokeW)
		for _i_ = 1 to poFeatures.Count()
			This.DrawFeatureOn(poCanvas, poFeatures, _i_, pFill, pStroke, pnStrokeW)
		next

	# fit the paper to everything a file holds
	def FitToFeatures(poFeatures, pnW, pnH, pnPad)
		This.FitToPoints(poFeatures.AllPoints(), pnW, pnH, pnPad)

		def FitToFeaturesQ(poFeatures, pnW, pnH, pnPad)
			This.FitToFeatures(poFeatures, pnW, pnH, pnPad)
			return This

	# TISSOT'S INDICATRIX: circles of one true size all over the sphere,
	# projected. Where they stay round the projection keeps shapes; where
	# they stay the same size it keeps areas; where they do neither it says
	# so. The honest way to show what a projection does, and it needs no
	# atlas at all.
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

	# the place at the middle of the paper: what the rotation put there
	def Center()
		_pp_ = This.Params()
		return StzEngineGeoInvert(_pp_, @nTx, @nTy)

	# the projection, named on the picture: a map that does not say how it
	# was flattened is asserting what it cannot check
	def Caption()
		_c_ = This.Name()
		if This.IsConic()
			_c_ += " (" + @aPar[1] + "N, " + @aPar[2] + "N)"
		ok
		if @aRot[1] != 0 or @aRot[2] != 0 or @aRot[3] != 0
			_c_ += " rotated " + @aRot[1] + ", " + @aRot[2] + ", " + @aRot[3]
		ok
		return _c_
