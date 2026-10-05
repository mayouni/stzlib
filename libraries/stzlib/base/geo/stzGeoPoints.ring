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

# Holds a list of places and the window they were observed in, and answers whether they are clustered, scattered or random, where their middle is and which way they spread.
#
# A pattern is never a bare list: it is the places AND the region, because a hundred wells in
# Tunisia and the same hundred in Niger are one list and two opposite answers. The places are one
# flat list lon, lat, lon, lat, ... (longitude first); distances are kilometres on a sphere of 6371
# km, areas on WGS84. The measures are Clark-Evans (edge-corrected by Donnelly), Ripley's K, L, G
# and F, the null band by simulation (Envelope, 39 simulations being the classic count), the mean
# centre, the spatial median and the standard deviational ellipse. Three generators make patterns
# whose truth is known, all seeded so a picture does not move: Sample (uniform), SampleClustered
# (Matern) and SampleDispersed (hard core); StzGeoProcess is the general form. A point outside the
# window is reported by Outside and Findings, never dropped. Pictures, each looked at by 'stzlib-
# docs visual pass (a model reading the PNG)' on 2026-10-05:
# doc/gallery/stzGeoPoints/three_patterns.png, three invented patterns in Niger with ellipse,
# centres and Clark-Evans verdicts, RIGHT (random, clustered and dispersed are named as the patterns
# were made); ripley_g_f.png, L with its band, G and F, RIGHT (L climbs far above the band for
# clusters, G stays at 0 below the hard-core distance for the dispersed pattern);
# outside_the_window.png, places across the border counted but flagged, RIGHT. Index:
# doc/gallery/INDEX_geo.md.
#
#   receiver   o1 = StzGeoPoints([ 2.1, 13.5, 8.0, 15.0 ],
#              StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson")))
#   example    ? o1.Count()
#              #--> 2
#              ? o1.Outside()
#              #--> 0
#   see        stzGeoProcess, stzGeoFeatures, stzGeoField, stzGeoSamples
class stzGeoPoints from stzObject
	@aPts = []
	@oW = NULL
	@aRings = []
	@aBox = []
	@nArea = 0
	@nPerimeter = 0
	@nOutside = 0

	# Builds a pattern from places and their window; raises an error for an odd list, a window that is not a stzGeoFeatures, or an empty one.
	#
	#   paLonLat   the places as one flat list lon, lat, lon, lat, ...
	#   poWindow   the stzGeoFeatures of the region the places were observed in
	#   returns    nothing; the pattern is built
	#   note       Computes the window's area and perimeter and counts the places that fall outside
	#              it
	#   see        StzGeoPoints, With
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

	# Returns the places of the pattern.
	#
	#   returns    a flat list lon, lat, lon, lat, ...
	#   see        Count, With
	def Points()
		return @aPts

	# Returns how many places the pattern holds.
	#
	#   returns    a number
	#   see        Points, Outside
	def Count()
		return len(@aPts) / 2

	# Returns the features that make the window.
	#
	#   returns    a stzGeoFeatures
	#   see        WindowRings, AreaKm2
	def Window()
		return @oW

	# Returns the outer ring of every part of the window, the shape the engine takes.
	#
	#   returns    a list of flat lon, lat lists, 8 for Niger
	#   note       Holes are not carried, so a lake inside the window counts as window
	#   see        Window, WindowBox
	#@ aka  the window as the engine takes it: every part's OUTER ring. Built once at birth and handed out rather than rebuilt, because GE7b's fields ask for it per call and rebuilding would be the same list twice.
	def WindowRings()
		return @aRings

	# Returns the area of the window in square kilometres, on WGS84.
	#
	#   returns    a number of km2; 1183623.9 for Niger's eight regions
	#   see        BoxAreaKm2, DensityPerKm2
	def AreaKm2()
		return @nArea

	# Returns the box around the window, in longitude and latitude.
	#
	#   returns    a list [ lonMin, latMin, lonMax, latMax ] in degrees
	#   note       The simulations place candidates in this box and keep those inside the window
	#   see        BoxAreaKm2, WindowRings
	#@ aka  THE WINDOW'S BOUNDING BOX, which is not the window. Every simulation in this plane places candidates in the box and rejects those outside the window, so the box is part of the engine's contract and a caller building a process needs it too.
	def WindowBox()
		return @aBox

	# Returns the area of the window's box in square kilometres: more than the window, and what a cluster process needs.
	#
	#   returns    a number of km2; 2207102.6 for Niger
	#   note       Parents are drawn in the box so the window's edge is not emptier than its middle
	#   see        AreaKm2, WindowBox
	#@ aka  ...and how much ground the BOX covers, which a CLUSTER process needs and the window's own area cannot answer. Parents are drawn in the box rather than in the window on purpose: a cluster whose centre falls just outside still throws children in, and dropping those parents would leave the window's edge visibly emptier than its middle -- the same edge effect Ripley's K corrects for, met on the genera
	def BoxAreaKm2()
		if len(@aBox) < 4  return @nArea  ok
		return StzGeoRingAreaKm2([ @aBox[1], @aBox[2], @aBox[3], @aBox[2],
		                           @aBox[3], @aBox[4], @aBox[1], @aBox[4] ])

	# Returns the total length of the window's outer rings, in kilometres.
	#
	#   returns    a number of km; 12734.1 for Niger
	#   note       Donnelly's edge correction of Clark-Evans needs it. Internal borders between
	#              regions count too
	#   see        AreaKm2
	#@ aka  the window's outline, km -- what Donnelly's edge correction needs
	def PerimeterKm()
		return @nPerimeter

	# Returns how many places fall outside the window they were said to be observed in.
	#
	#   returns    a number, 0 for a clean pattern
	#   note       Reported, never dropped: they stay in the count and the density
	#   see        Findings, Count
	#@ aka  how many of the points fall outside the window they were said to be observed in. Reported, never dropped: a well across the border is a fact about the data, and a density computed as if it were inside is wrong by one well.
	def Outside()
		return @nOutside

	# Returns the places per square kilometre of the window.
	#
	#   returns    a number, 0.000127 for 150 places in Niger; 0 for a window with no area
	#   see        AreaKm2, Count
	def DensityPerKm2()
		if @nArea <= 0  return 0  ok
		return This.Count() / @nArea

	# Returns, for every place, the distance in km to its nearest other place.
	#
	#   returns    a list of numbers, one per place
	#   see        ClarkEvans, G
	#@ aka  -- the measures -------------------------------------------------------
	def NearestNeighbourKm()
		return StzEngineGeoNearestNeighbour(@aPts)

	# Returns the Clark-Evans nearest-neighbour index, corrected for the edge by Donnelly, with its z and a verdict.
	#
	#   returns    a hash list [ :r, :z, :observed, :expected, :verdict ]; r below 1 is closer than
	#              chance, the verdict is "clustered", "dispersed" or "random" at z beyond 1.96
	#   note       Needs a few dozen places to mean anything: Findings warns below 30
	#   see        ClarkEvansUncorrected, RipleyK, Envelope
	#@ aka  [ :r, :z, :observed, :expected, :verdict ]. R below 1 is closer than chance, above 1 farther; the verdict reads the z at the usual 1.96.
	def ClarkEvans()
		return This.ClarkEvansXT(TRUE)

	# Returns the naive Clark-Evans index with no edge correction, for comparison with the older literature.
	#
	#   returns    a hash list [ :r, :z, :observed, :expected, :verdict ]
	#   note       Leans toward "dispersed" on every real window: 150 uniform places read dispersed
	#              at z 2.26
	#   see        ClarkEvans
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

	# Returns Ripley's K at each radius, not corrected for the edge.
	#
	#   paRadiiKm   the distances in km, ascending and not empty
	#   returns     a list of numbers in km2, one per radius
	#   note        Raises an error for radii that do not ascend. K falls short at large radii near
	#               the window's border; Envelope is the answer, not a formula
	#   see         L, Envelope
	#@ aka  Ripley's K at each radius, UNCORRECTED FOR THE EDGE. Points near the window's border have fewer neighbours within r than they would in an infinite plane, so K falls short at large r. This is not corrected by formula; it is answered by Envelope(), which simulates the null under the same edge.
	def RipleyK(paRadiiKm)
		This._CheckRadii(paRadiiKm)
		return StzEngineGeoRipleyK(@aPts, @nArea, paRadiiKm)

	# Returns sqrt(K / pi) minus the radius, at each radius: about 0 for random places, above 0 for clusters, below 0 for dispersion.
	#
	#   paRadiiKm   the distances in km, ascending and not empty
	#   returns     a list of numbers in km, one per radius
	#   note        Raises an error for radii that do not ascend
	#   see         RipleyK, EnvelopeL
	#@ aka  L(r) = sqrt(K / pi) - r: flat at zero under randomness, above it clustered, below it dispersed -- the form a reader can see
	def L(paRadiiKm)
		_k_ = This.RipleyK(paRadiiKm)
		_out_ = []
		for _i_ = 1 to len(_k_)
			_out_ + (sqrt(_k_[_i_] / 3.14159265358979) - paRadiiKm[_i_])
		next
		return _out_

	# Returns the share of places whose nearest neighbour lies within each radius.
	#
	#   paRadiiKm   the distances in km, ascending and not empty
	#   returns     a list of numbers from 0 to 1, one per radius
	#   note        0 below a hard-core distance and near 1 quickly for clusters
	#   see         F, NearestNeighbourKm
	def G(paRadiiKm)
		This._CheckRadii(paRadiiKm)
		return StzEngineGeoGFunction(@aPts, paRadiiKm)

	# Returns the share of random test places in the window that have a pattern place within each radius, the empty-space distribution.
	#
	#   paRadiiKm   the distances in km, ascending and not empty
	#   pnTests     how many random test places to throw
	#   pnSeed      the seed of the random draw
	#   returns     a list of numbers from 0 to 1, one per radius
	#   note        Slow to rise for clusters, which leave much ground empty
	#   see         G, Envelope
	def F(paRadiiKm, pnTests, pnSeed)
		This._CheckRadii(paRadiiKm)
		return StzEngineGeoFFunction(@aPts, @aRings, @aBox, pnTests, pnSeed, paRadiiKm)

	# Returns the null band of K by simulation: the lowest, highest and mean K of pnSims uniform patterns of the same count in the same window.
	#
	#   paRadiiKm   the distances in km, ascending and not empty
	#   pnSims      how many simulated patterns, 39 being the classic count
	#   pnSeed      the seed of the random draw
	#   returns     a list of [ lo, hi, mean ], one per radius
	#   note        The nulls have the same edge as the data, so no correction is needed. The band
	#               widens with pnSims
	#   see         EnvelopeL, RipleyK
	#@ aka  [ [ lo, hi, mean ], ... ] per radius, over pnSims uniform patterns of this pattern's own count in its own window. Thirty-nine is the classic count: an observed K outside the band of 39 is significant at 5% on each side.
	def Envelope(paRadiiKm, pnSims, pnSeed)
		This._CheckRadii(paRadiiKm)
		_f_ = StzEngineGeoKEnvelope(@aRings, @aBox, This.Count(), @nArea, paRadiiKm, pnSims, pnSeed)
		_out_ = []
		for _i_ = 1 to len(paRadiiKm)
			_out_ + [ _f_[_i_ * 3 - 2], _f_[_i_ * 3 - 1], _f_[_i_ * 3] ]
		next
		return _out_

	# Returns the same null band in the form of L, so it plots against L.
	#
	#   paRadiiKm   the distances in km, ascending and not empty
	#   pnSims      how many simulated patterns, 39 being the classic count
	#   pnSeed      the seed of the random draw
	#   returns     a list of [ lo, hi, mean ] in km, one per radius
	#   note        An observed L above hi is clustering at that radius, below lo is dispersion
	#   see         Envelope, L
	#@ aka  the same band in L form, so it plots against L()
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

	# Returns the centre of mass of the places, on the sphere.
	#
	#   returns    a list [ lon, lat ] in degrees
	#   note       For a clustered pattern it can fall in empty ground between the clusters
	#   see        SpatialMedian, Ellipse
	#@ aka  -- where the middle is, and how it spreads -----------------------------
	def MeanCentre()
		return StzEngineGeoMeanCentre(@aPts)

	# Returns the point of least total distance to all the places.
	#
	#   returns    a list [ lon, lat ] in degrees
	#   note       Sits in the biggest cluster where the mean centre sits between them
	#   see        MeanCentre
	def SpatialMedian()
		return StzEngineGeoSpatialMedian(@aPts)

	# Returns the standard deviational ellipse: centre, standard distance, semi-axes and the bearing of the major axis.
	#
	#   returns    a hash list [ :lon, :lat, :sd, :major, :minor, :bearing ]; km, and degrees
	#              clockwise from north
	#   see        EllipseRing, MeanCentre
	#@ aka  [ :lon, :lat, :sd, :major, :minor, :bearing ] -- the centre, the standard distance in km, the semi-axes at one standard deviation, and the bearing of the major axis clockwise from north
	def Ellipse()
		_a_ = StzEngineGeoEllipse(@aPts)
		if len(_a_) < 6  return []  ok
		return [ :lon = _a_[1], :lat = _a_[2], :sd = _a_[3],
		         :major = _a_[4], :minor = _a_[5], :bearing = _a_[6] ]

	# Returns the standard deviational ellipse as a ring a projection can draw.
	#
	#   pnPoints   how many points the ring has
	#   returns    a flat list lon, lat, ... of pnPoints points
	#   note       Draw it with Ring, so a seam cuts it correctly
	#   see        Ellipse, stzGeoProjection.Ring
	#@ aka  the ellipse as a lon/lat ring a projection can draw
	def EllipseRing(pnPoints)
		_e_ = StzEngineGeoEllipse(@aPts)
		if len(_e_) < 6  return []  ok
		return StzEngineGeoEllipseRing(_e_[1], _e_[2], _e_[4], _e_[5], _e_[6], pnPoints)

	# Returns pnHowMany places thrown uniformly on the sphere inside the window.
	#
	#   pnHowMany   how many places
	#   pnSeed      the seed of the random draw
	#   returns     a flat list lon, lat, lon, lat, ...
	#   note        Seeded: the same seed gives the same pattern, so a picture does not move
	#   see         SampleClustered, SampleDispersed, With
	#@ aka  -- making patterns, seeded --------------------------------------------
	def Sample(pnHowMany, pnSeed)
		return StzEngineGeoSampleInside(@aRings, @aBox, pnHowMany, pnSeed)

	# Returns a Matern cluster pattern: parents thrown in the window's box, children thrown in a disc round each and kept inside the window.
	#
	#   pnParents    how many cluster centres
	#   pnChildren   the mean number of children per parent
	#   pnRadiusKm   the radius of each cluster's disc in km
	#   pnSeed       the seed of the random draw
	#   returns      a flat list lon, lat, lon, lat, ...
	#   note         The children count is a mean, so the total varies: 8 parents of 25 gave 182
	#                places
	#   see          Sample, SampleDispersed
	#@ aka  a Matern cluster process: parents uniform, children uniform in a disk round each, kept only inside the window
	def SampleClustered(pnParents, pnChildren, pnRadiusKm, pnSeed)
		return StzEngineGeoMaternCluster(@aRings, @aBox, pnParents, pnChildren, pnRadiusKm, pnSeed)

	# Returns a hard-core pattern: no two places closer than pnMinKm.
	#
	#   pnHowMany   how many places to try for
	#   pnMinKm     the least distance between two places in km
	#   pnSeed      the seed of the random draw
	#   returns     a flat list lon, lat, lon, lat, ...; fewer than asked when the window cannot
	#               hold that many discs
	#   note        Read the count it gives back
	#   see         Sample, SampleClustered
	#@ aka  a hard-core process: no two points closer than pnMinKm. Fewer than asked when the window cannot hold that many discs -- read the count.
	def SampleDispersed(pnHowMany, pnMinKm, pnSeed)
		return StzEngineGeoHardCore(@aRings, @aBox, pnHowMany, pnMinKm, pnSeed)

	# Returns a new pattern of other places in the same window.
	#
	#   paLonLat   the places as one flat list lon, lat, lon, lat, ...
	#   returns    a stzGeoPoints
	#   note       The usual way to turn Sample's answer into something measurable
	#   see        Points, Sample
	#@ aka  the same pattern object, on a new set of points in the same window
	def With(paLonLat)
		return new stzGeoPoints(paLonLat, @oW)

	# Returns what is wrong with the pattern: places outside the window, too few places to judge, a window with no area.
	#
	#   returns    a list of [ :rule, :subject, :where, :severity, :message ]; [ ] when clean
	#   note       Fewer than 30 places is a warning, a window without area is an error
	#   see        IsSound
	#@ aka  -- what the gate owes a pattern ---------------------------------------
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

	# TRUE if the pattern has no finding of severity error.
	#
	#   returns    TRUE or FALSE
	#   note       Warnings do not count: a pattern with a place outside the window is still sound
	#   see        Findings
	def IsSound()
		_a_ = This.Findings()
		for _i_ = 1 to len(_a_)
			if _a_[_i_][:severity] = "error"  return FALSE  ok
		next
		return TRUE
