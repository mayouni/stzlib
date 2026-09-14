# stzGeoPoints -- A POINT PATTERN AND THE WINDOW IT WAS OBSERVED IN (GE7a)
#
# The first questions an analyst asks of a table of places -- clinics,
# wells, boreholes, outbreaks -- before any other: ARE THEY CLUSTERED,
# SCATTERED, OR RANDOM? Where is the middle of them? Which way do they
# spread? Every one is a spatial statistic, and every one is meaningless
# without the WINDOW: a hundred wells in Tunisia and the same hundred in
# Niger are one list and two opposite answers. So a pattern here is never a
# bare list of points. It is the points AND the region they were observed
# in, and the region's area and outline go into every measure that needs
# them.
#
# What it answers, and the standard it answers it to:
#
#   ClarkEvans()          Clark and Evans (1954): the mean nearest-neighbour
#                         distance over the one a random pattern of the same
#                         density expects, with its z. The first thing an
#                         analyst asks, and one number.
#   RipleyK(radii)        Ripley's K, UNCORRECTED for the edge and saying so.
#   L(radii)              K in the form that is a flat line under randomness.
#   G(radii)              the nearest-neighbour distribution.
#   F(radii, tests, seed) the empty-space distribution.
#   Envelope(radii, sims, seed)
#                         THE NULL BY SIMULATION, not by formula: the same
#                         count of uniform points in the same window, `sims`
#                         times, and the band their K makes. What spatstat's
#                         envelope() does. It puts the null under exactly the
#                         edge effect the data has, so no correction has to
#                         be trusted -- and it is what makes the uncorrected
#                         K honest to plot.
#   MeanCentre()          the middle, on the sphere.
#   SpatialMedian()       the point of least total distance to all the others.
#   Ellipse()             the standard deviational ellipse every GIS prints.
#
# And three ways to MAKE a pattern, seeded so a picture does not move:
# Sample (uniform in the window), SampleClustered (Matern), SampleDispersed
# (hard-core). They are the null models the measures are judged against, and
# they are how the guard proves the measures can tell the three apart.
#
# THE ARITHMETIC IS THE ENGINE'S. Ten thousand places is fifty million
# distances, and the envelope is that again per simulation.

func StzGeoPoints(paLonLat, poWindow)
	return new stzGeoPoints(paLonLat, poWindow)

class stzGeoPoints from stzObject
	@aPts = []
	@oW = NULL
	@aRings = []
	@aBox = []
	@nArea = 0
	@nPerimeter = 0
	@nOutside = 0

	def init(paLonLat, poWindow)
		if NOT isList(paLonLat) or len(paLonLat) % 2 != 0
			stzraise("stzGeoPoints: the points are a flat list [ lon, lat, lon, lat, ... ].")
		ok
		if NOT isObject(poWindow)
			stzraise("stzGeoPoints: the window is a stzGeoFeatures -- the region the " +
				"points were observed in. A pattern without its window has no " +
				"density and no answer.")
		ok
		if poWindow.Count() = 0
			stzraise("stzGeoPoints: the window holds no feature.")
		ok
		@aPts = paLonLat
		@oW = poWindow
		# the window as the engine takes it: every part's OUTER ring, and
		# the box round them all. Holes are not carried -- a lake inside
		# the window counts as window, which is wrong by the lake.
		@aRings = []
		for _i_ = 1 to @oW.Count()
			for _k_ = 1 to @oW.PartCount(_i_)
				@aRings + @oW.OuterRingOf(_i_, _k_)
			next
		next
		@aBox = @oW.Bounds()
		@nArea = @oW.AreaKm2()
		@nPerimeter = 0
		for _i_ = 1 to len(@aRings)  @nPerimeter += StzEngineGeoRingLength(@aRings[_i_])  next
		@nOutside = 0
		_n_ = len(@aPts) / 2
		for _i_ = 1 to _n_
			if @oW.IndexAt(@aPts[_i_ * 2 - 1], @aPts[_i_ * 2]) = 0  @nOutside++  ok
		next

	def Points()
		return @aPts

	def Count()
		return len(@aPts) / 2

	def Window()
		return @oW

	# the window as the engine takes it: every part's OUTER ring. Built once
	# at birth and handed out rather than rebuilt, because GE7b's fields ask
	# for it per call and rebuilding would be the same list twice.
	def WindowRings()
		return @aRings

	def AreaKm2()
		return @nArea

	# THE WINDOW'S BOUNDING BOX, which is not the window. Every simulation
	# in this plane places candidates in the box and rejects those outside
	# the window, so the box is part of the engine's contract and a caller
	# building a process needs it too.
	def WindowBox()
		return @aBox

	# ...and how much ground the BOX covers, which a CLUSTER process needs
	# and the window's own area cannot answer. Parents are drawn in the box
	# rather than in the window on purpose: a cluster whose centre falls
	# just outside still throws children in, and dropping those parents
	# would leave the window's edge visibly emptier than its middle -- the
	# same edge effect Ripley's K corrects for, met on the generating side.
	def BoxAreaKm2()
		if len(@aBox) < 4  return @nArea  ok
		return StzGeoRingAreaKm2([ @aBox[1], @aBox[2], @aBox[3], @aBox[2],
		                           @aBox[3], @aBox[4], @aBox[1], @aBox[4] ])

	# the window's outline, km -- what Donnelly's edge correction needs
	def PerimeterKm()
		return @nPerimeter

	# how many of the points fall outside the window they were said to be
	# observed in. Reported, never dropped: a well across the border is a
	# fact about the data, and a density computed as if it were inside is
	# wrong by one well.
	def Outside()
		return @nOutside

	def DensityPerKm2()
		if @nArea <= 0  return 0  ok
		return This.Count() / @nArea

	#-- the measures -------------------------------------------------------

	def NearestNeighbourKm()
		return StzEngineGeoNearestNeighbour(@aPts)

	# [ :r, :z, :observed, :expected, :verdict ]. R below 1 is closer than
	# chance, above 1 farther; the verdict reads the z at the usual 1.96.
	#
	# EDGE-CORRECTED, BY DONNELLY. Uncorrected, the index leans toward
	# "dispersed" on every real window -- a point near the border has no
	# neighbours beyond it -- and five hundred uniform points in a window
	# the shape of a country read as dispersed at z = 2.0 the first time
	# this ran. The correction uses the window's perimeter, which is why a
	# pattern carries its window. ClarkEvansUncorrected() is the naive one,
	# for comparison and for readers who know the older literature.
	def ClarkEvans()
		return This.ClarkEvansXT(TRUE)

	def ClarkEvansUncorrected()
		return This.ClarkEvansXT(FALSE)

	def ClarkEvansXT(pbCorrected)
		_p_ = 0
		if pbCorrected  _p_ = @nPerimeter  ok
		_a_ = StzEngineGeoClarkEvans(@aPts, @nArea, _p_)
		if len(_a_) < 4  return [ :r = 0, :z = 0, :observed = 0, :expected = 0, :verdict = "unknown" ]  ok
		_v_ = "random"
		if _a_[2] < -1.96  _v_ = "clustered"  ok
		if _a_[2] > 1.96   _v_ = "dispersed"  ok
		return [ :r = _a_[1], :z = _a_[2], :observed = _a_[3], :expected = _a_[4], :verdict = _v_ ]

	def _CheckRadii(paRadii)
		if NOT isList(paRadii) or len(paRadii) = 0
			stzraise("stzGeoPoints: the radii are a list of distances in km, ascending.")
		ok
		for _i_ = 2 to len(paRadii)
			if paRadii[_i_] <= paRadii[_i_ - 1]
				stzraise("stzGeoPoints: the radii must ascend -- " + paRadii[_i_ - 1] +
					" is followed by " + paRadii[_i_] + ".")
			ok
		next

	# Ripley's K at each radius, UNCORRECTED FOR THE EDGE. Points near the
	# window's border have fewer neighbours within r than they would in an
	# infinite plane, so K falls short at large r. This is not corrected
	# by formula; it is answered by Envelope(), which simulates the null
	# under the same edge.
	def RipleyK(paRadiiKm)
		This._CheckRadii(paRadiiKm)
		return StzEngineGeoRipleyK(@aPts, @nArea, paRadiiKm)

	# L(r) = sqrt(K / pi) - r: flat at zero under randomness, above it
	# clustered, below it dispersed -- the form a reader can see
	def L(paRadiiKm)
		_k_ = This.RipleyK(paRadiiKm)
		_out_ = []
		for _i_ = 1 to len(_k_)
			_out_ + (sqrt(_k_[_i_] / 3.14159265358979) - paRadiiKm[_i_])
		next
		return _out_

	def G(paRadiiKm)
		This._CheckRadii(paRadiiKm)
		return StzEngineGeoGFunction(@aPts, paRadiiKm)

	def F(paRadiiKm, pnTests, pnSeed)
		This._CheckRadii(paRadiiKm)
		return StzEngineGeoFFunction(@aPts, @aRings, @aBox, pnTests, pnSeed, paRadiiKm)

	# [ [ lo, hi, mean ], ... ] per radius, over pnSims uniform patterns of
	# this pattern's own count in its own window. Thirty-nine is the classic
	# count: an observed K outside the band of 39 is significant at 5% on
	# each side.
	def Envelope(paRadiiKm, pnSims, pnSeed)
		This._CheckRadii(paRadiiKm)
		_f_ = StzEngineGeoKEnvelope(@aRings, @aBox, This.Count(), @nArea, paRadiiKm, pnSims, pnSeed)
		_out_ = []
		for _i_ = 1 to len(paRadiiKm)
			_out_ + [ _f_[_i_ * 3 - 2], _f_[_i_ * 3 - 1], _f_[_i_ * 3] ]
		next
		return _out_

	# the same band in L form, so it plots against L()
	def EnvelopeL(paRadiiKm, pnSims, pnSeed)
		_e_ = This.Envelope(paRadiiKm, pnSims, pnSeed)
		_out_ = []
		for _i_ = 1 to len(_e_)
			_r_ = paRadiiKm[_i_]
			_out_ + [ sqrt(_e_[_i_][1] / 3.14159265358979) - _r_,
			          sqrt(_e_[_i_][2] / 3.14159265358979) - _r_,
			          sqrt(_e_[_i_][3] / 3.14159265358979) - _r_ ]
		next
		return _out_

	#-- where the middle is, and how it spreads -----------------------------

	def MeanCentre()
		return StzEngineGeoMeanCentre(@aPts)

	def SpatialMedian()
		return StzEngineGeoSpatialMedian(@aPts)

	# [ :lon, :lat, :sd, :major, :minor, :bearing ] -- the centre, the
	# standard distance in km, the semi-axes at one standard deviation, and
	# the bearing of the major axis clockwise from north
	def Ellipse()
		_a_ = StzEngineGeoEllipse(@aPts)
		if len(_a_) < 6  return []  ok
		return [ :lon = _a_[1], :lat = _a_[2], :sd = _a_[3],
		         :major = _a_[4], :minor = _a_[5], :bearing = _a_[6] ]

	# the ellipse as a lon/lat ring a projection can draw
	def EllipseRing(pnPoints)
		_e_ = StzEngineGeoEllipse(@aPts)
		if len(_e_) < 6  return []  ok
		return StzEngineGeoEllipseRing(_e_[1], _e_[2], _e_[4], _e_[5], _e_[6], pnPoints)

	#-- making patterns, seeded --------------------------------------------

	# uniform ON THE SPHERE inside the window, by rejection in its box
	def Sample(pnHowMany, pnSeed)
		return StzEngineGeoSampleInside(@aRings, @aBox, pnHowMany, pnSeed)

	# a Matern cluster process: parents uniform, children uniform in a disk
	# round each, kept only inside the window
	def SampleClustered(pnParents, pnChildren, pnRadiusKm, pnSeed)
		return StzEngineGeoMaternCluster(@aRings, @aBox, pnParents, pnChildren, pnRadiusKm, pnSeed)

	# a hard-core process: no two points closer than pnMinKm. Fewer than
	# asked when the window cannot hold that many discs -- read the count.
	def SampleDispersed(pnHowMany, pnMinKm, pnSeed)
		return StzEngineGeoHardCore(@aRings, @aBox, pnHowMany, pnMinKm, pnSeed)

	# the same pattern object, on a new set of points in the same window
	def With(paLonLat)
		return new stzGeoPoints(paLonLat, @oW)

	#-- what the gate owes a pattern ---------------------------------------

	def Findings()
		_a_ = []
		_c_ = "pattern of " + This.Count() + " in " + @oW.NameOf(1)
		if @oW.Count() > 1  _c_ = "pattern of " + This.Count() + " in " + @oW.Count() + " regions"  ok
		# 1. POINTS OUTSIDE THE WINDOW. They are in the count and not in
		# the area, so every density is wrong by them; and a well across
		# the border is usually a data error worth seeing.
		if @nOutside > 0
			_a_ + [ :rule = "the_points_are_in_their_window",
				:subject = _c_, :where = "" + @nOutside + " point(s)",
				:severity = "warning",
				:message = "" + @nOutside + " of " + This.Count() + " points fall outside " +
					"the window they were said to be observed in -- they are counted " +
					"in the density and stand on none of its area" ]
		ok
		# 2. TOO FEW TO JUDGE. Clark-Evans's z rests on a normal
		# approximation that needs a few dozen points; below that the
		# verdict is a guess wearing a number.
		if This.Count() < 30
			_a_ + [ :rule = "enough_points_to_judge",
				:subject = _c_, :where = "" + This.Count() + " points",
				:severity = "warning",
				:message = "" + This.Count() + " points is too few for the Clark-Evans z " +
					"to mean what it says -- report the pattern, do not judge it" ]
		ok
		# 3. A WINDOW WITH NO AREA cannot hold a density
		if @nArea <= 0
			_a_ + [ :rule = "the_window_has_area",
				:subject = _c_, :where = "window", :severity = "error",
				:message = "the window's area measures " + @nArea + " km2 -- every " +
					"density and every K divides by it" ]
		ok
		return _a_

	def IsSound()
		_a_ = This.Findings()
		for _i_ = 1 to len(_a_)
			if _a_[_i_][:severity] = "error"  return FALSE  ok
		next
		return TRUE
