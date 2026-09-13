#---------------------------------------------------------------------------#
#  STZGEOMAP -- a map made of layers (GE2)                                   #
#---------------------------------------------------------------------------#
#
#     oM = StzGeoMap(oProjection, oFeatures)
#     oM.SetValues(aValues)                  one per feature, "" for no data
#     oM.SetClasses([ 0, 1e5, 1e6, 5e6 ])
#     oM.DrawOn(oCanvas)                     sphere, graticule, regions, edge
#     oM.DrawLegendOn(oCanvas, 940, 90, "km2")
#     oM.DrawSymbolsOn(oCanvas, aValues, 26) circles by AREA, never radius
#     oM.DrawFlowsOn(oCanvas, aRoutes)       great circles between places
#
# WHAT THIS IS, and what DN24 was. The choropleth of DN24 takes polygons
# ALREADY IN MAP UNITS and solves a picture from them; it is a diagram that
# happens to look like a map, and it is judged by the math plane's rules.
# This is the other half: longitude and latitude in, a PROJECTION chosen
# and named, base layers underneath, and every part and hole of every
# feature drawn. The two meet at AsRegions(), which turns a file read here
# into the regions that builder takes.
#
# A MAP SAYS HOW IT WAS MADE. Caption() gives the projection, its
# parameters, and whatever the caller said about where the boundaries came
# from and when -- because a map asserts where a border lies, and a picture
# in this plane may not assert what it cannot attribute. The caller sets
# the source; this class refuses to invent one.
#
# WHAT IS NOT HERE, named: no automatic class breaks (quantiles, Jenks --
# the edges are the author's, as in DN24), no label placement, no
# projection chosen for the caller.

func StzGeoMap(poProjection, poFeatures)
	_o_ = new stzGeoMap
	_o_.Bind(poProjection, poFeatures)
	return _o_

# THE RAMP A MAP IS COLOURED WITH, and why it is not the diagram plane's.
#
# DN24 steps one hue from a pale tint to a deep shade, which is right for a
# diagram of six regions read beside its legend. On a map of ninety-six it
# reads as a wall: the eye cannot rank two shades of one hue that are four
# per cent apart, and the Principal put it plainly the first time they saw
# one -- "the blue color is not nice".
#
# These are CYNTHIA BREWER'S sequential schemes (ColorBrewer 2.0, five
# classes), which exist because she measured what people can actually rank
# on a map: the lightness falls evenly AND the hue turns as it goes, so a
# step is legible twice over. They are stated as data, in full, rather than
# computed from a hue -- a ramp that is generated is a ramp nobody checked.
#
# ColorBrewer is Cynthia Brewer, Mark Harrower and Penn State; the schemes
# are published under the Apache licence and are a table of numbers, which
# is a fact about perception and not a boundary claim.
func StzGeoRamps()
	return [
		[ :Blues,   [ "#EFF3FF", "#BDD7E7", "#6BAED6", "#3182BD", "#08519C" ] ],
		[ :YlOrRd,  [ "#FFFFB2", "#FECC5C", "#FD8D3C", "#F03B20", "#BD0026" ] ],
		[ :YlGnBu,  [ "#FFFFCC", "#A1DAB4", "#41B6C4", "#2C7FB8", "#253494" ] ],
		[ :Greens,  [ "#EDF8E9", "#BAE4B3", "#74C476", "#31A354", "#006D2C" ] ],
		[ :Oranges, [ "#FEEDDE", "#FDBE85", "#FD8D3C", "#E6550D", "#A63603" ] ],
		[ :Purples, [ "#F2F0F7", "#CBC9E2", "#9E9AC8", "#756BB1", "#54278F" ] ],
		[ :Reds,    [ "#FEE5D9", "#FCAE91", "#FB6A4A", "#DE2D26", "#A50F15" ] ],
		[ :BuPu,    [ "#EDF8FB", "#B3CDE3", "#8C96C6", "#8856A7", "#810F7C" ] ],
		[ :Earth,   [ "#F6F1E5", "#DCCFA8", "#B8A165", "#8C6D36", "#5C4218" ] ]
	]

# A ramp by name, in as many classes as are asked for. Fewer than five takes
# the ends and the middles; more than five interpolates between the stated
# stops, which is what every serious atlas does rather than inventing new
# ones.
func StzGeoRamp(pName, pnClasses)
	_c_ = StzLower(ring_trim("" + pName))
	_a_ = StzGeoRamps()
	_stops_ = []
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][1]) = _c_  _stops_ = _a_[_i_][2]  exit  ok
	next
	if len(_stops_) = 0
		stzraise("StzGeoRamp: '" + pName + "' is not a ramp this file knows -- " +
			"Blues, YlOrRd, YlGnBu, Greens, Oranges, Purples, Reds, BuPu or Earth.")
	ok
	if pnClasses < 1  return []  ok
	if pnClasses = 1  return [ _stops_[3] ]  ok
	_out_ = []
	_n_ = len(_stops_)
	for _k_ = 1 to pnClasses
		_t_ = (_k_ - 1) / (pnClasses - 1) * (_n_ - 1) + 1
		_lo_ = floor(_t_)
		if _lo_ < 1  _lo_ = 1  ok
		if _lo_ > _n_ - 1  _lo_ = _n_ - 1  ok
		_f_ = _t_ - _lo_
		# EXACTLY ON A STOP MEANS THE STOP ITSELF. Five classes out of a
		# five-stop scheme must be Brewer's own five colours and not five
		# re-mixes of them; and the answer stays HEX throughout, because
		# StzColorMix hands back a packed number and a ramp that is half
		# strings and half integers is a ramp somebody will read wrong.
		if _f_ < 0.000001
			_out_ + _stops_[_lo_]
		else
			_out_ + _GeoMixHex(_stops_[_lo_], _stops_[_lo_ + 1], _f_)
		ok
	next
	return _out_

# two hex colours mixed, answered as hex
func _GeoMixHex(pcA, pcB, pnT)
	_r_ = _GeoHexByte(pcA, 1) + (_GeoHexByte(pcB, 1) - _GeoHexByte(pcA, 1)) * pnT
	_g_ = _GeoHexByte(pcA, 3) + (_GeoHexByte(pcB, 3) - _GeoHexByte(pcA, 3)) * pnT
	_b_ = _GeoHexByte(pcA, 5) + (_GeoHexByte(pcB, 5) - _GeoHexByte(pcA, 5)) * pnT
	return "#" + _GeoHex2(_r_) + _GeoHex2(_g_) + _GeoHex2(_b_)

func _GeoHexByte(pcHex, pnAt)
	return _GeoHexDigit(pcHex[pnAt + 1]) * 16 + _GeoHexDigit(pcHex[pnAt + 2])

func _GeoHexDigit(pcC)
	_n_ = ascii(StzLower("" + pcC))
	if _n_ >= 48 and _n_ <= 57  return _n_ - 48  ok
	if _n_ >= 97 and _n_ <= 102  return _n_ - 87  ok
	return 0

func _GeoHex2(pnV)
	_n_ = floor(pnV + 0.5)
	if _n_ < 0  _n_ = 0  ok
	if _n_ > 255  _n_ = 255  ok
	_d_ = "0123456789ABCDEF"
	return _d_[floor(_n_ / 16) + 1] + _d_[(_n_ % 16) + 1]

# THE DEFAULT A MAP TAKES when the caller names no palette. Blues, because
# it is the scheme a reader has seen on every population map ever printed
# and the one whose steps are furthest apart at the light end, where a
# choropleth spends most of its ink.
func StzGeoMapPaletteFor(pnClasses)
	return StzGeoRamp(:Blues, pnClasses)

# which class a bin's count falls in; 0 for none
# how far a place is from the nearest edge of a ring, in degrees. Crude on
# purpose: a label only has to be comfortably inside, and an exact distance
# to a polygon costs more than the picture is worth.
func _GeoEdgeDistance(paRing, pnX, pnY)
	_best_ = 1000000
	_n_ = len(paRing) / 2
	for _i_ = 1 to _n_
		_dx_ = paRing[_i_ * 2 - 1] - pnX
		_dy_ = paRing[_i_ * 2] - pnY
		_d_ = _dx_ * _dx_ + _dy_ * _dy_
		if _d_ < _best_  _best_ = _d_  ok
	next
	return sqrt(_best_)

# is this box clear of every box already placed? Axis-aligned overlap, with
# a couple of pixels of air so two names never touch.
func _GeoBoxFree(paBox, paPlaced)
	for _i_ = 1 to len(paPlaced)
		_p_ = paPlaced[_i_]
		if paBox[1] < _p_[3] + 2 and paBox[3] + 2 > _p_[1] and
		   paBox[2] < _p_[4] + 2 and paBox[4] + 2 > _p_[2]
			return FALSE
		ok
	next
	return TRUE

func _HexClassOf(pnV, paEdges)
	_n_ = len(paEdges) - 1
	for _c_ = 1 to _n_
		if pnV >= paEdges[_c_] and pnV < paEdges[_c_ + 1]  return _c_  ok
	next
	if pnV >= paEdges[_n_ + 1]  return _n_  ok
	return 0

# EVERY MAP JUDGED AT ONCE, into the ONE report the whole library gates on.
# Mirrors StzCheckPictures: [ [ name, oMap ], ... ] in, a stzRuleReport out,
# and a map's findings arrive already in the unified shape so nothing has to
# be translated.
func StzCheckGeoMaps(paMaps)
	_oRep_ = new stzRuleReport("geomaps")
	for _i_ = 1 to len(paMaps)
		if NOT (isList(paMaps[_i_]) and len(paMaps[_i_]) >= 2)  loop  ok
		if NOT isObject(paMaps[_i_][2])  loop  ok
		_oRep_.Ingest(_GeoTagged(paMaps[_i_][2].Findings(), "" + paMaps[_i_][1]))
	next
	? "maps judged: " + len(paMaps) + " -- findings: " + len(_oRep_.Findings())
	return _oRep_

# the map's own name in front of the subject, so a report over several maps
# says WHICH one spoke
func _GeoTagged(paFindings, pcName)
	_a_ = []
	for _i_ = 1 to len(paFindings)
		_f_ = paFindings[_i_]
		_a_ + [ :rule = _f_[:rule], :subject = pcName + "/" + _f_[:subject],
		        :where = _f_[:where], :severity = _f_[:severity], :message = _f_[:message] ]
	next
	return _a_

class stzGeoMap from stzObject
	@oP = NULL
	@oF = NULL
	@aValues = []
	@aEdges = []
	@aPalette = []
	@cSource = ""
	@cNoData = "#E8E8E8"
	@bBinned = FALSE
	@bLabelled = FALSE
	@nLblInline = 0
	@nLblLeader = 0
	@nLblDropped = 0
	@aPaper = []

	def Bind(poProjection, poFeatures)
		if NOT isObject(poProjection) or NOT isObject(poFeatures)
			stzraise("stzGeoMap: give a projection and a set of features.")
		ok
		@oP = poProjection
		@oF = poFeatures

	def Projection()
		return @oP

	def Features()
		return @oF

	#-- what is being shown -------------------------------------------------

	# one value per feature, in the features' own order; "" where the map
	# has a hole. A region with no value is DRAWN as no data and says so in
	# the legend -- it is never quietly coloured as zero.
	def SetValues(paValues)
		@aValues = paValues

		def SetValuesQ(paValues)
			This.SetValues(paValues)
			return This

	# every feature's own true area in square kilometres, measured on the
	# SPHERE from its rings -- a value that needs no other file, and the
	# one an equal-area projection can be checked against
	def ValuesFromArea()
		_a_ = []
		for _i_ = 1 to @oF.Count()
			_s_ = 0
			for _k_ = 1 to @oF.PartCount(_i_)
				_r_ = @oF.RingsOf(_i_, _k_)
				_s_ += StzGeoRingAreaKm2(_r_[1])
				for _h_ = 2 to len(_r_)
					_s_ -= StzGeoRingAreaKm2(_r_[_h_])
				next
			next
			_a_ + _s_
		next
		return _a_

	def ValueOf(pnI)
		if pnI < 1 or pnI > len(@aValues)  return ""  ok
		return @aValues[pnI]

	def SetClasses(paEdges)
		if NOT (isList(paEdges) and len(paEdges) >= 2)
			stzraise("stzGeoMap: the classes need at least two edges.")
		ok
		for _i_ = 2 to len(paEdges)
			if paEdges[_i_] <= paEdges[_i_ - 1]
				stzraise("stzGeoMap: the class edges must rise -- " + paEdges[_i_ - 1] +
					" is followed by " + paEdges[_i_] + ".")
			ok
		next
		@aEdges = paEdges
		if len(@aPalette) != len(paEdges) - 1
			@aPalette = StzGeoMapPaletteFor(len(paEdges) - 1)
		ok

		def SetClassesQ(paEdges)
			This.SetClasses(paEdges)
			return This

	# the palette by the name of a ramp, in the classes already set
	def SetRamp(pName)
		if len(@aEdges) < 2
			stzraise("stzGeoMap.SetRamp: set the classes before the ramp -- a ramp " +
				"has to know how many steps to give.")
		ok
		@aPalette = StzGeoRamp(pName, len(@aEdges) - 1)

		def SetRampQ(pName)
			This.SetRamp(pName)
			return This

	def SetPalette(paColours)
		if len(paColours) != len(@aEdges) - 1
			stzraise("stzGeoMap: " + (len(@aEdges) - 1) + " classes need " +
				(len(@aEdges) - 1) + " colours -- " + len(paColours) + " given.")
		ok
		@aPalette = paColours

		def SetPaletteQ(paColours)
			This.SetPalette(paColours)
			return This

	# where the boundaries came from and when. A map asserts where a border
	# lies; this class will not invent the authority for it.
	# THE BOX THE MAP WAS DRAWN IN, so a name cannot be written off the edge
	# of it. Without this the label engine only knows where a region is, not
	# where the sheet ends, and the first version wrote "Diffa" half into the
	# margin beside it. Unset, nothing is clipped.
	def SetPaper(pnX0, pnY0, pnX1, pnY1)
		@aPaper = [ pnX0, pnY0, pnX1, pnY1 ]

		def SetPaperQ(pnX0, pnY0, pnX1, pnY1)
			This.SetPaper(pnX0, pnY0, pnX1, pnY1)
			return This

	def SetSource(pcSource)
		@cSource = "" + pcSource

		def SetSourceQ(pcSource)
			This.SetSource(pcSource)
			return This

	def ClassOf(pnI)
		_v_ = This.ValueOf(pnI)
		if NOT isNumber(_v_)  return 0  ok
		_n_ = len(@aEdges) - 1
		for _c_ = 1 to _n_
			if _v_ >= @aEdges[_c_] and _v_ < @aEdges[_c_ + 1]  return _c_  ok
		next
		if _v_ = @aEdges[_n_ + 1]  return _n_  ok
		return 0

	def ColourOf(pnI)
		_c_ = This.ClassOf(pnI)
		if _c_ < 1  return @cNoData  ok
		return @aPalette[_c_]

	#-- the layers ----------------------------------------------------------

	# the sphere, the graticule, then every feature in its class's colour,
	# then the world's edge on top: the order an atlas draws them in
	def DrawOn(poCanvas)
		This.DrawSphereOn(poCanvas, "#EAF1FB", "#8FA8C8", 1)
		This.DrawGraticuleOn(poCanvas, 30, "#D2DCEA", 1)
		This.DrawRegionsOn(poCanvas, "#FFFFFF", 0.6)
		@oP.DrawOutlineOn(poCanvas, "#3B5B8C", 1.5)

		def DrawOnQ(poCanvas)
			This.DrawOn(poCanvas)
			return This

	def DrawSphereOn(poCanvas, pFill, pStroke, pnW)
		@oP.DrawSphereOn(poCanvas, pFill, pStroke, pnW)

	def DrawGraticuleOn(poCanvas, pnStep, pStroke, pnW)
		@oP.DrawGraticuleOn(poCanvas, pnStep, pStroke, pnW)

	# every feature, in the colour its value earns it
	def DrawRegionsOn(poCanvas, pStroke, pnStrokeW)
		for _i_ = 1 to @oF.Count()
			@oP.DrawFeatureOn(poCanvas, @oF, _i_, This.ColourOf(_i_), pStroke, pnStrokeW)
		next

	# one feature picked out, over the rest
	def HighlightOn(poCanvas, pnI, pFill, pStroke, pnStrokeW)
		@oP.DrawFeatureOn(poCanvas, @oF, pnI, pFill, pStroke, pnStrokeW)

	#-- symbols -------------------------------------------------------------

	# A CIRCLE'S AREA CARRIES THE VALUE, NEVER ITS RADIUS. Doubling a radius
	# quadruples the ink, so a symbol map scaled by radius overstates its
	# largest places fourfold -- the oldest lie in the genre, and the one a
	# reader cannot see being told. The radius here is proportional to the
	# SQUARE ROOT of the value, so equal values draw equal ink.
	def DrawSymbolsOn(poCanvas, paValues, pnMaxRadius, pFill, pStroke)
		_max_ = 0
		for _i_ = 1 to len(paValues)
			if isNumber(paValues[_i_]) and paValues[_i_] > _max_  _max_ = paValues[_i_]  ok
		next
		if _max_ <= 0  return  ok
		for _i_ = 1 to len(paValues)
			_v_ = paValues[_i_]
			if NOT isNumber(_v_) or _v_ <= 0  loop  ok
			_c_ = This.CentroidOf(_i_)
			if len(_c_) < 2  loop  ok
			_q_ = @oP.Project(_c_[1], _c_[2])
			if len(_q_) < 2  loop  ok
			_r_ = pnMaxRadius * sqrt(_v_ / _max_)
			poCanvas.AddCircleQ(_q_[1], _q_[2], _r_).FillQ(pFill).Stroke(pStroke, 1)
		next

	# a symbol at a place the caller names, rather than at a feature
	def DrawSymbolAt(poCanvas, pnLon, pnLat, pnRadius, pFill, pStroke)
		_q_ = @oP.Project(pnLon, pnLat)
		if len(_q_) < 2  return  ok
		poCanvas.AddCircleQ(_q_[1], _q_[2], pnRadius).FillQ(pFill).Stroke(pStroke, 1)

	# the middle of a feature's largest part, in longitude and latitude:
	# the mean of its outer ring, which is where a symbol belongs and is
	# NOT where a label belongs on a crescent-shaped country
	def CentroidOf(pnI)
		if pnI < 1 or pnI > @oF.Count()  return []  ok
		_r_ = @oF.OuterRingOf(pnI, @oF.LargestPartOf(pnI))
		_n_ = len(_r_) / 2
		if _n_ < 1  return []  ok
		_sx_ = 0  _sy_ = 0
		for _j_ = 1 to _n_
			_sx_ += _r_[_j_ * 2 - 1]
			_sy_ += _r_[_j_ * 2]
		next
		return [ _sx_ / _n_, _sy_ / _n_ ]

	#-- hexagonal bins ------------------------------------------------------

	# TEN THOUSAND DOTS ON A MAP ARE A STAIN, not a picture: they overplot,
	# and the densest places look exactly like the merely busy ones. Binning
	# answers the question the dots were asked -- HOW MANY HERE -- and the
	# cell is a HEXAGON because a square grid lies twice: its cells touch
	# their diagonal neighbours at a point and their orthogonal ones along an
	# edge, so "next to" means two distances, and its rows line up into
	# stripes the eye invents structure out of.
	#
	# The points arrive as longitude and latitude and are PROJECTED first,
	# so the bins are cells of the paper. That is d3's choice too, and the
	# map's own rules say what it costs on a projection that distorts area.
	def HexBin(paLonLat, pnRadius)
		_xy_ = []
		for _i_ = 1 to len(paLonLat) - 1 step 2
			_q_ = @oP.Project(paLonLat[_i_], paLonLat[_i_ + 1])
			if len(_q_) = 2
				_xy_ + _q_[1]
				_xy_ + _q_[2]
			ok
		next
		@bBinned = TRUE
		return StzEngineGeoHexBin(_xy_, pnRadius)

	# the bins drawn, each in the colour its COUNT earns from the edges
	# given. A bin holding nothing is not drawn: an empty cell is not a
	# quantity of zero, it is a place nobody counted.
	def DrawHexBinsOn(poCanvas, paBins, pnRadius, paEdges, paPalette, pStroke)
		for _i_ = 1 to len(paBins)
			_b_ = paBins[_i_]
			if _b_[3] <= 0  loop  ok
			_c_ = _HexClassOf(_b_[3], paEdges)
			if _c_ < 1  loop  ok
			poCanvas.AddPolygonQ(StzEngineGeoHexagon(_b_[1], _b_[2], pnRadius)).
				FillQ(paPalette[_c_]).Stroke(pStroke, 0.5)
		next

	# the biggest count in a set of bins -- what a legend's last edge wants
	def HexBinMax(paBins)
		_m_ = 0
		for _i_ = 1 to len(paBins)
			if paBins[_i_][3] > _m_  _m_ = paBins[_i_][3]  ok
		next
		return _m_

	#-- flows ---------------------------------------------------------------

	# A FLOW IS A GREAT CIRCLE, not a straight line on the paper: the route
	# between two places bends on every projection, and drawing it straight
	# is drawing a journey nobody takes. Each route is
	# [ lon1, lat1, lon2, lat2 ] or the same with a width as a fifth item.
	def DrawFlowsOn(poCanvas, paRoutes, pStroke, pnWidth)
		for _i_ = 1 to len(paRoutes)
			_r_ = paRoutes[_i_]
			if len(_r_) < 4  loop  ok
			_w_ = pnWidth
			if len(_r_) >= 5 and isNumber(_r_[5])  _w_ = _r_[5]  ok
			_pcs_ = @oP.Arc(_r_[1], _r_[2], _r_[3], _r_[4])
			for _k_ = 1 to len(_pcs_)
				if len(_pcs_[_k_]) >= 4
					poCanvas.AddPolylineQ(_pcs_[_k_]).Stroke(pStroke, _w_)
				ok
			next
		next

	#-- observations, joined to the regions they fell in ---------------------
	#
	# THIS IS THE SPATIAL JOIN, and it is the whole of spatial analytics'
	# first step: a table of places -- wells, clinics, rain gauges, sales --
	# each with a longitude and a latitude, and the question "how many in
	# each region". Nothing about it is a picture yet.

	# which feature each point fell in, one index per point, 0 for a point
	# outside every one of them. A point outside is NOT an error and not
	# rounded to the nearest region: it is reported as 0, because a well
	# across the border belongs to the other side.
	def AssignPoints(paLonLat)
		_a_ = []
		_n_ = len(paLonLat) / 2
		for _i_ = 1 to _n_
			_a_ + @oF.IndexAt(paLonLat[_i_ * 2 - 1], paLonLat[_i_ * 2])
		next
		return _a_

	# how many points fell in each feature, in the features' own order --
	# which is exactly the shape SetValues takes, so a table of coordinates
	# becomes a choropleth in two calls
	def CountPointsIn(paLonLat)
		_a_ = []
		for _i_ = 1 to @oF.Count()  _a_ + 0  next
		_n_ = len(paLonLat) / 2
		for _i_ = 1 to _n_
			_k_ = @oF.IndexAt(paLonLat[_i_ * 2 - 1], paLonLat[_i_ * 2])
			if _k_ > 0  _a_[_k_]++  ok
		next
		return _a_

	# ...and how many fell outside every region, which a caller must be told
	# rather than left to notice that their totals do not add up
	def PointsOutside(paLonLat)
		_c_ = 0
		_n_ = len(paLonLat) / 2
		for _i_ = 1 to _n_
			if @oF.IndexAt(paLonLat[_i_ * 2 - 1], paLonLat[_i_ * 2]) = 0  _c_++  ok
		next
		return _c_

	# the same counts, divided by each region's own area in square
	# kilometres: a DENSITY, which is the number a choropleth may honestly
	# colour. A count may not -- a big region collects more of anything --
	# and that is the commonest lie in the genre after the radius one.
	def DensityPointsIn(paLonLat)
		_c_ = This.CountPointsIn(paLonLat)
		_a_ = This.ValuesFromArea()
		_d_ = []
		for _i_ = 1 to len(_c_)
			if _a_[_i_] > 0
				_d_ + (_c_[_i_] / _a_[_i_] * 10000)
			else
				_d_ + ""
			ok
		next
		return _d_

	# PLACES SCATTERED INSIDE THE REGIONS, for a demonstration or a
	# rehearsal. REJECTION SAMPLING: a point is drawn in the bounding box and
	# kept only if it falls in a region, which is the standard way and the
	# only one that needs no assumption about the shape.
	#
	# The sequence is the caller's seed, so the same call gives the same
	# places every time -- a committed picture that moves on every render is
	# a diff nobody can read. And the answer is INVENTED DATA: the caller who
	# draws it owes their reader that word, which is why the map's caption
	# takes a source line.
	def SamplePointsInside(pnHowMany, pnSeed)
		_b_ = @oF.Bounds()
		if len(_b_) < 4  return []  ok
		_a_ = []
		_s_ = pnSeed
		_tries_ = 0
		_cap_ = pnHowMany * 400 + 4000
		while len(_a_) < pnHowMany * 2 and _tries_ < _cap_
			_tries_++
			_s_ = (_s_ * 1103515245 + 12345) % 2147483648
			_x_ = _b_[1] + (_b_[3] - _b_[1]) * (_s_ % 100000) / 100000
			_s_ = (_s_ * 1103515245 + 12345) % 2147483648
			_y_ = _b_[2] + (_b_[4] - _b_[2]) * (_s_ % 100000) / 100000
			if @oF.IndexAt(_x_, _y_) > 0
				_a_ + _x_
				_a_ + _y_
			ok
		end
		return _a_

	#-- labels ---------------------------------------------------------------

	# WHERE A NAME GOES. The mean of a ring is not inside it whenever the
	# region is a crescent, a horseshoe or a pair of islands -- and a label
	# outside its own region is a label on somebody else's. So the mean is
	# TRIED and, when it lands outside, an interior point is searched for:
	# the point of a coarse grid that is inside and furthest from the edge,
	# which is the pole of inaccessibility a cartographer would use, taken
	# at a resolution a map at this size cannot tell from the exact one.
	def LabelPointOf(pnI)
		_k_ = @oF.LargestPartOf(pnI)
		_r_ = @oF.OuterRingOf(pnI, _k_)
		_n_ = len(_r_) / 2
		if _n_ < 3  return []  ok
		_sx_ = 0  _sy_ = 0
		for _j_ = 1 to _n_
			_sx_ += _r_[_j_ * 2 - 1]
			_sy_ += _r_[_j_ * 2]
		next
		_cx_ = _sx_ / _n_
		_cy_ = _sy_ / _n_
		if @oF.PartContains(pnI, _k_, _cx_, _cy_)  return [ _cx_, _cy_ ]  ok

		_b_ = @oF.BoundsOf(pnI)
		_best_ = []
		_bestd_ = -1
		_steps_ = 24
		for _a_ = 1 to _steps_ - 1
			for _b2_ = 1 to _steps_ - 1
				_x_ = _b_[1] + (_b_[3] - _b_[1]) * _a_ / _steps_
				_y_ = _b_[2] + (_b_[4] - _b_[2]) * _b2_ / _steps_
				if NOT @oF.PartContains(pnI, _k_, _x_, _y_)  loop  ok
				_d_ = _GeoEdgeDistance(_r_, _x_, _y_)
				if _d_ > _bestd_
					_bestd_ = _d_
					_best_ = [ _x_, _y_ ]
				ok
			next
		next
		if len(_best_) = 2  return _best_  ok
		return [ _cx_, _cy_ ]

	#-- naming the regions ---------------------------------------------------
	#
	# NINETY-SIX NAMES ON ONE SHEET IS NOT A LABELLING, and the first
	# version of this drew exactly that: every department's name at its own
	# centre, overlapping into a grey smear that said nothing. The Principal
	# returned it in one line -- "labels are not readable, you need a
	# smarter algorithm" -- and they are right that this is a solved problem
	# elsewhere. What every serious label engine does (QGIS's PAL, Mapbox
	# GL, ArcGIS Maplex) comes down to four rules, and they are the four
	# below:
	#
	#   1. A LABEL IS A BOX, not a point. Nothing can be decided until the
	#      name is measured at the size it will be drawn.
	#   2. THE BIGGEST REGION SPEAKS FIRST. Placement is greedy by
	#      importance, because a name dropped from a large region is a worse
	#      loss than one dropped from a small one, and area is the
	#      importance a map has to hand.
	#   3. A LABEL THAT WILL NOT FIT INSIDE ITS REGION GOES OUTSIDE IT, on a
	#      leader line, rather than lying across its neighbours. This is the
	#      rule the first version had no notion of and the one the Principal
	#      asked for by name.
	#   4. A LABEL THAT CANNOT GO ANYWHERE IS DROPPED, and the picture SAYS
	#      how many -- a map that silently omits names is a map whose reader
	#      does not know what they are not being told.
	#
	# What is NOT here, named: no curved labels along a river, no repeated
	# labels down a long region, no font-size stepping per region. Those are
	# the next tier and none of them is needed to read a country.

	# the boxes placed by the last DrawLabelsOn, and what it had to do
	def LabelReport()
		return [ :inline = @nLblInline, :leadered = @nLblLeader, :dropped = @nLblDropped ]

	# EVERY REGION NAMED, as well as the sheet allows. paMargin is where a
	# leadered label may be written: [ x0, y0, x1, y1 ], usually a column
	# beside the map. Pass [] and a label that will not fit is dropped
	# instead of leadered.
	def DrawLabelsOn(poCanvas, poFont, pnSize, pInk)
		This.DrawLabelsXT(poCanvas, poFont, pnSize, pInk, [], FALSE)

	def DrawLabelsWithValuesOn(poCanvas, poFont, pnSize, pInk)
		This.DrawLabelsXT(poCanvas, poFont, pnSize, pInk, [], TRUE)

	def DrawLabelsInMargin(poCanvas, poFont, pnSize, pInk, paMargin)
		This.DrawLabelsXT(poCanvas, poFont, pnSize, pInk, paMargin, FALSE)

	def DrawLabelsXT(poCanvas, poFont, pnSize, pInk, paMargin, pbValues)
		@bLabelled = TRUE
		@nLblInline = 0
		@nLblLeader = 0
		@nLblDropped = 0
		_nF_ = @oF.Count()
		if _nF_ = 0  return  ok

		# --- 1. a label is a BOX, measured ---------------------------------
		_aW_ = []
		_aH_ = []
		_aX_ = []
		_aY_ = []
		_aFit_ = []
		_aArea_ = []
		for _i_ = 1 to _nF_
			_c_ = "" + @oF.NameOf(_i_)
			_w_ = poFont.WidthOf(_c_, pnSize)
			_h_ = pnSize
			if pbValues and isNumber(This.ValueOf(_i_))
				_w2_ = poFont.WidthOf(StzFactNumText(This.ValueOf(_i_)), pnSize - 3)
				if _w2_ > _w_  _w_ = _w2_  ok
				_h_ += pnSize
			ok
			_aW_ + _w_
			_aH_ + _h_
			_g_ = This.LabelPointOf(_i_)
			if len(_g_) < 2
				_aX_ + 0  _aY_ + 0  _aFit_ + FALSE  _aArea_ + 0
				loop
			ok
			_q_ = @oP.Project(_g_[1], _g_[2])
			if len(_q_) < 2
				_aX_ + 0  _aY_ + 0  _aFit_ + FALSE  _aArea_ + 0
				loop
			ok
			_aX_ + _q_[1]
			_aY_ + _q_[2]
			# DOES THE NAME FIT INSIDE THE REGION? Measured on the DRAWN
			# shape, not on the sphere: the region's projected box, which is
			# what the reader's eye is comparing the name against.
			_b_ = This.PaperBoxOf(_i_)
			_aArea_ + ((_b_[3] - _b_[1]) * (_b_[4] - _b_[2]))
			_aFit_ + ((_b_[3] - _b_[1]) >= _w_ + 4 and (_b_[4] - _b_[2]) >= _h_ + 4)
		next

		# --- 2. the biggest region speaks first ----------------------------
		_ord_ = []
		for _i_ = 1 to _nF_  _ord_ + _i_  next
		for _a_ = 1 to _nF_ - 1
			for _b_ = 1 to _nF_ - _a_
				if _aArea_[_ord_[_b_]] < _aArea_[_ord_[_b_ + 1]]
					_t_ = _ord_[_b_]
					_ord_[_b_] = _ord_[_b_ + 1]
					_ord_[_b_ + 1] = _t_
				ok
			next
		next

		_placed_ = []
		_lead_ = []
		for _k_ = 1 to _nF_
			_i_ = _ord_[_k_]
			if _aArea_[_i_] <= 0  loop  ok
			_w_ = _aW_[_i_]
			_h_ = _aH_[_i_]
			if _aFit_[_i_]
				# four candidates: the anchor, then a little up, down, right
				_cand_ = [ [ _aX_[_i_] - _w_ / 2, _aY_[_i_] - _h_ / 2 ],
				           [ _aX_[_i_] - _w_ / 2, _aY_[_i_] - _h_ / 2 - _h_ ],
				           [ _aX_[_i_] - _w_ / 2, _aY_[_i_] - _h_ / 2 + _h_ ],
				           [ _aX_[_i_] - _w_ / 2 + _w_ / 3, _aY_[_i_] - _h_ / 2 ] ]
				_done_ = FALSE
				for _t_ = 1 to len(_cand_)
					_bx_ = [ _cand_[_t_][1], _cand_[_t_][2], _cand_[_t_][1] + _w_, _cand_[_t_][2] + _h_ ]
					if NOT This._OnPaper(_bx_)  loop  ok
					if _GeoBoxFree(_bx_, _placed_)
						_placed_ + _bx_
						This._WriteLabel(poCanvas, poFont, pnSize, pInk, _i_,
							_bx_[1] + _w_ / 2, _bx_[2] + pnSize, pbValues)
						@nLblInline++
						_done_ = TRUE
						exit
					ok
				next
				if _done_  loop  ok
			ok
			# --- 3. it does not fit, or nowhere free: a leader ------------
			if len(paMargin) = 4
				_lead_ + _i_
			else
				@nLblDropped++
			ok
		next

		# --- the leadered ones, down the margin in the order they sit -----
		if len(_lead_) > 0 and len(paMargin) = 4
			for _a_ = 1 to len(_lead_) - 1
				for _b_ = 1 to len(_lead_) - _a_
					if _aY_[_lead_[_b_]] > _aY_[_lead_[_b_ + 1]]
						_t_ = _lead_[_b_]
						_lead_[_b_] = _lead_[_b_ + 1]
						_lead_[_b_ + 1] = _t_
					ok
				next
			next
			_pitch_ = pnSize + 5
			_room_ = floor((paMargin[4] - paMargin[2]) / _pitch_)
			_y_ = paMargin[2] + pnSize
			for _n_ = 1 to len(_lead_)
				if _n_ > _room_
					@nLblDropped++
					loop
				ok
				_i_ = _lead_[_n_]
				_x_ = paMargin[1]
				# the line runs from the region to its name, and is drawn
				# UNDER nothing -- a leader that crosses another label is
				# worse than the crowding it was meant to cure, so it is
				# kept short and horizontal at its own end
				# AN ELBOW, NOT A DIAGONAL. A leader drawn straight from the
				# region to its name crosses the map and every other leader
				# with it; the first version of this drew thirty-five such
				# lines over France and they were a cat's cradle. The line
				# goes OUT to the margin's edge at the region's own height,
				# then along -- which is what an atlas does, and what makes
				# two leaders share a corridor instead of crossing.
				poCanvas.AddPolylineQ([ _aX_[_i_], _aY_[_i_],
				                        _x_ - 14, _aY_[_i_],
				                        _x_ - 6, _y_ - pnSize / 3,
				                        _x_ - 2, _y_ - pnSize / 3 ]).Stroke("#9AA7B4", 0.8)
				poCanvas.SetFontQ(poFont, pnSize).AddTextQ("" + @oF.NameOf(_i_), _x_, _y_).Fill(pInk)
				@nLblLeader++
				_y_ += _pitch_
			next
		ok
		# CLOSE THE GROUP. The canvas keeps the last shape open so that
		# Fill and SetFont can still reach it, so a caption written after
		# this would otherwise resize the last name drawn.
		poCanvas.Flush()

	# THE INK A NAME IS WRITTEN IN, over the shade it sits on. A dark name
	# on a dark class is not a name -- Niger's four southern regions were
	# unreadable the first time this drew them in one ink over a Brewer
	# ramp. The choropleth settled this in DN24 by choosing black or white
	# per class; a map on a filled region owes the same, and asks the same
	# question of the colour system.
	def InkOver(pnI, pInk)
		if len(@aEdges) < 2 or len(@aValues) = 0  return pInk  ok
		_c_ = This.ClassOf(pnI)
		if _c_ < 1  return pInk  ok
		if StzIsDarkColor(@aPalette[_c_])  return "#FFFFFF"  ok
		return pInk

	def _OnPaper(paBox)
		if len(@aPaper) != 4  return TRUE  ok
		return paBox[1] >= @aPaper[1] and paBox[3] <= @aPaper[3] and
		       paBox[2] >= @aPaper[2] and paBox[4] <= @aPaper[4]

	def _WriteLabel(poCanvas, poFont, pnSize, pInk, pnI, pnCx, pnY, pbValues)
		pInk = This.InkOver(pnI, pInk)
		_c_ = "" + @oF.NameOf(pnI)
		_w_ = poFont.WidthOf(_c_, pnSize)
		poCanvas.SetFontQ(poFont, pnSize).AddTextQ(_c_, pnCx - _w_ / 2, pnY).Fill(pInk)
		if NOT pbValues  return  ok
		if NOT isNumber(This.ValueOf(pnI))  return  ok
		_t_ = StzFactNumText(This.ValueOf(pnI))
		_w2_ = poFont.WidthOf(_t_, pnSize - 3)
		poCanvas.SetFontQ(poFont, pnSize - 3).AddTextQ(_t_, pnCx - _w2_ / 2, pnY + pnSize).Fill(pInk)

	# a region's box ON THE PAPER: what the reader's eye measures a name
	# against, which is not the box it has on the sphere
	def PaperBoxOf(pnI)
		_k_ = @oF.LargestPartOf(pnI)
		_r_ = @oF.OuterRingOf(pnI, _k_)
		_n_ = len(_r_) / 2
		_x0_ = 1000000  _y0_ = 1000000  _x1_ = -1000000  _y1_ = -1000000
		for _j_ = 1 to _n_
			_q_ = @oP.Project(_r_[_j_ * 2 - 1], _r_[_j_ * 2])
			if len(_q_) < 2  loop  ok
			if _q_[1] < _x0_  _x0_ = _q_[1]  ok
			if _q_[1] > _x1_  _x1_ = _q_[1]  ok
			if _q_[2] < _y0_  _y0_ = _q_[2]  ok
			if _q_[2] > _y1_  _y1_ = _q_[2]  ok
		next
		if _x0_ > _x1_  return [ 0, 0, 0, 0 ]  ok
		return [ _x0_, _y0_, _x1_, _y1_ ]

	#-- the legend and the caption -------------------------------------------

	# THE LEGEND SAYS WHAT EVERY SHADE MEANS, and a class that colours
	# nothing says so: a legend promising a shade the map never shows is
	# the fault DN24's own rules were written to catch, and it is the same
	# fault here.
	def DrawLegendOn(poCanvas, poFont, pnX, pnY, pcTitle)
		_n_ = len(@aEdges) - 1
		_y_ = pnY
		if pcTitle != NULL and len("" + pcTitle) > 0
			poCanvas.SetFontQ(poFont, 18).AddTextQ("" + pcTitle, pnX, _y_).Fill("#111111")
			_y_ += 26
		ok
		_anCount_ = []
		for _c_ = 1 to _n_  _anCount_ + 0  next
		_nNo_ = 0
		for _i_ = 1 to @oF.Count()
			_c_ = This.ClassOf(_i_)
			if _c_ < 1  _nNo_++  else  _anCount_[_c_]++  ok
		next
		for _c_ = 1 to _n_
			poCanvas.AddRectQ(pnX, _y_ - 12, 30, 18).FillQ(@aPalette[_c_]).Stroke("#666666", 1)
			_t_ = StzFactNumText(@aEdges[_c_]) + " - " + StzFactNumText(@aEdges[_c_ + 1])
			if _anCount_[_c_] = 0  _t_ += "   (no region)"  ok
			poCanvas.SetFontQ(poFont, 16).AddTextQ(_t_, pnX + 40, _y_).Fill("#222222")
			_y_ += 28
		next
		if _nNo_ > 0
			poCanvas.AddRectQ(pnX, _y_ - 12, 30, 18).FillQ(@cNoData).Stroke("#666666", 1)
			poCanvas.SetFontQ(poFont, 16).AddTextQ("no data   (" + _nNo_ + ")", pnX + 40, _y_).Fill("#222222")
			_y_ += 28
		ok
		return _y_

	# how the map was made, and on whose word its borders are where they
	# are. A map with no source says "source not stated" rather than
	# nothing, because silence reads as authority.
	def Caption()
		_c_ = @oP.Caption()
		if @cSource != ""
			_c_ += "  |  " + @cSource
		else
			_c_ += "  |  boundaries: source not stated"
		ok
		return _c_

	def DrawCaptionOn(poCanvas, poFont, pnX, pnY)
		poCanvas.SetFontQ(poFont, 15).AddTextQ(This.Caption(), pnX, pnY).Fill("#555555")

	#-- WHAT THE GATE OWES A MAP (GE3) --------------------------------------
	#
	# A map is not judged the way a diagram is. DN24's choropleth is a
	# mathematical picture with a substance the math governance can read; a
	# map is a projection, a file and a set of values, and the mistakes it
	# makes are mistakes of ARGUMENT rather than of geometry. So it reports
	# itself, in the house's unified finding shape --
	#
	#     [ :rule, :subject, :where, :severity, :message ]
	#
	# -- which stzRuleReport ingests, so a map joins the one CI gate beside
	# every other domain instead of growing a second one.
	#
	# The severities follow the house convention: an ERROR is a picture that
	# ARGUES AGAINST ITSELF and a warning ADVISES. A map missing its source
	# is a warning because the picture is still true; a choropleth on a
	# projection that distorts area is an ERROR because the picture is not.

	def Findings()
		_a_ = []
		_cM_ = "map"
		_nF_ = @oF.Count()
		_bChoro_ = len(@aEdges) >= 2 and len(@aValues) > 0

		# 1. THE ONE A CHOROPLETH CANNOT SURVIVE. It encodes a quantity as
		# the colour of an AREA, so on a projection that distorts area the
		# picture argues against its own legend: on Mercator, Greenland
		# reads as large as Africa while carrying a fourteenth of its
		# people. This is DN24's own reasoning, enforced where the
		# projection is finally a choice.
		if _bChoro_ and NOT @oP.IsEqualArea()
			_a_ + [ :rule = "choropleth_needs_an_equal_area_projection",
				:subject = _cM_, :where = @oP.Name(), :severity = "error",
				:message = "the regions are coloured by a quantity but '" + @oP.Name() +
					"' does not preserve area -- the picture argues against its own legend" ]
		ok

		# 1b. AND THE SAME REASONING REACHES THE BINS. A hexagon is a cell
		# of the PAPER; it stands for an equal area on the ground only where
		# the projection preserves area. On any other, a bin near the pole
		# counts what happened over less ground than one at the equator
		# while drawing the same size -- the choropleth's lie, told with
		# hexagons. The caller declares a bin layer so the map can say so.
		if @bBinned and NOT @oP.IsEqualArea()
			_a_ + [ :rule = "bins_need_an_equal_area_projection",
				:subject = _cM_, :where = @oP.Name(), :severity = "error",
				:message = "the counts are binned into cells of the paper but '" + @oP.Name() +
					"' does not preserve area -- a bin near the pole covers less ground " +
					"than one at the equator and draws the same size" ]
		ok

		# 1c. A LABEL SITS IN ITS OWN REGION. This was named in GE3's first
		# table and left undone; it is checkable now that a label has a
		# place of its own. The mean of a ring falls outside it whenever the
		# region is a crescent or a pair of islands, and a name outside its
		# region is a name on somebody else's.
		if @bLabelled
			_nOut_ = 0
			_cWho_ = ""
			for _i_ = 1 to _nF_
				_g_ = This.LabelPointOf(_i_)
				if len(_g_) < 2  loop  ok
				if @oF.IndexAt(_g_[1], _g_[2]) = _i_  loop  ok
				_nOut_++
				if _cWho_ = ""  _cWho_ = @oF.NameOf(_i_)  ok
			next
			if _nOut_ > 0
				_a_ + [ :rule = "a_label_sits_in_its_region",
					:subject = _cM_, :where = _cWho_, :severity = "warning",
					:message = "" + _nOut_ + " label(s) fall outside the region they name, " +
						"beginning with '" + _cWho_ + "' -- a name outside its region is a " +
						"name on somebody else's" ]
			ok
		ok

		# 1d. THE EXTENT IS ONE PLACE, or the projection is fitted to the
		# sea between two. Natural Earth's France carries Guyane, Reunion,
		# Martinique, Guadeloupe and Mayotte beside the departments, so its
		# latitude span runs from -21 to 51 -- and a conic fitted to THAT
		# put its standard parallels at 9S and 39N, a projection for the
		# Atlantic. The picture would not be wrong; it would be a map of
		# mostly ocean with the subject in a corner.
		#
		# TWO NUMBERS, AND BOTH WERE MEASURED BEFORE THE RULE WAS WRITTEN.
		# The first draft used a spread and could not see one outlier among
		# six; the second used the largest GAP alone and fired on Niger,
		# which is one place with big regions. What separates them is the
		# gap TOGETHER WITH the bulk's own span:
		#
		#     set                  n     span    gap    bulk span
		#     Niger                8     6.25    3.28   2.97
		#     Tunisia             23     5.29    1.33   3.96
		#     France, all        101    71.64   25.70   8.65   <- fires
		#     France, metro       96     8.65    0.55   8.10
		#     the world          177   146.28   22.74   123.54
		#
		# Ten degrees of EMPTY latitude in one step, with the rest of the
		# regions inside thirty, is one compact place plus some far-flung
		# members. The world has the gap and not the compactness; Niger has
		# neither.
		if _nF_ >= 4
			_lat_ = []
			for _i_ = 1 to _nF_
				_b_ = @oF.BoundsOf(_i_)
				if len(_b_) >= 4  _lat_ + ((_b_[2] + _b_[4]) / 2)  ok
			next
			_lat_ = sort(_lat_)
			_m_ = len(_lat_)
			if _m_ >= 4
				_gap_ = 0
				_at_ = 0
				for _i_ = 2 to _m_
					if _lat_[_i_] - _lat_[_i_ - 1] > _gap_
						_gap_ = _lat_[_i_] - _lat_[_i_ - 1]
						_at_ = _i_
					ok
				next
				_bLow_ = (_at_ - 1) <= (_m_ - _at_ + 1)
				if _bLow_
					_maj_ = _lat_[_m_] - _lat_[_at_]
				else
					_maj_ = _lat_[_at_ - 1] - _lat_[1]
				ok
				if _gap_ > 10 and _maj_ < 30
					_who_ = ""
					for _i_ = 1 to _nF_
						_b_ = @oF.BoundsOf(_i_)
						if len(_b_) < 4  loop  ok
						_cy_ = (_b_[2] + _b_[4]) / 2
						if _bLow_ and _cy_ <= _lat_[_at_ - 1]  _who_ = @oF.NameOf(_i_)  exit  ok
						if NOT _bLow_ and _cy_ >= _lat_[_at_]  _who_ = @oF.NameOf(_i_)  exit  ok
					next
					_a_ + [ :rule = "the_extent_is_one_place",
						:subject = _cM_, :where = _who_, :severity = "warning",
						:message = "the regions leave " + StzFactNumText(_gap_) +
							" degrees of latitude EMPTY in one step while the rest of them " +
							"sit inside " + StzFactNumText(_maj_) + " -- '" + _who_ + "' and " +
							"its like are a second cluster, and a projection fitted to both " +
							"is fitted to the sea between" ]
				ok
			ok
		ok

		# 2. NORTH IS UP unless the map says otherwise. Turning the sphere to
		# centre a globe is ordinary; ROLLING it puts north somewhere other
		# than up, and every reader of this plane's pictures assumes it is
		# not there.
		if fabs(@oP.RotationOf()[3]) > 0.0001
			_a_ + [ :rule = "north_is_up",
				:subject = _cM_, :where = "roll " + @oP.RotationOf()[3],
				:severity = "error",
				:message = "the sphere is rolled by " + @oP.RotationOf()[3] +
					" degrees, so north is not up -- a reader is given no way to know" ]
		ok

		# 3. A MAP SAYS ON WHOSE WORD ITS BORDERS ARE WHERE THEY ARE. It is a
		# warning and not an error because the picture may be perfectly
		# true; what is missing is the means to check it.
		if @cSource = ""
			_a_ + [ :rule = "the_map_names_its_source",
				:subject = _cM_, :where = "caption", :severity = "warning",
				:message = "no source is stated for the boundaries -- a map asserts " +
					"where a border lies, and silence reads as authority" ]
		ok

		# 4. EVERY VALUE HAS A COLOUR. A value outside the classes is drawn
		# as no data, which is a region the legend cannot explain.
		if _bChoro_
			_n_ = len(@aEdges) - 1
			for _i_ = 1 to _nF_
				_v_ = This.ValueOf(_i_)
				if NOT isNumber(_v_)  loop  ok
				if This.ClassOf(_i_) > 0  loop  ok
				_side_ = "below the first class, which begins at " + StzFactNumText(@aEdges[1])
				if _v_ > @aEdges[_n_ + 1]
					_side_ = "above the last class, which ends at " + StzFactNumText(@aEdges[_n_ + 1])
				ok
				_a_ + [ :rule = "values_fall_in_the_classes",
					:subject = _cM_, :where = @oF.NameOf(_i_), :severity = "error",
					:message = "'" + @oF.NameOf(_i_) + "' is " + StzFactNumText(_v_) +
						", " + _side_ + " -- it has no colour" ]
			next
		ok

		# 5. A CLASS THAT COLOURS NOTHING is a shade the legend promises and
		# the map never shows.
		if _bChoro_
			_n_ = len(@aEdges) - 1
			_cnt_ = []
			for _c_ = 1 to _n_  _cnt_ + 0  next
			for _i_ = 1 to _nF_
				_c_ = This.ClassOf(_i_)
				if _c_ >= 1  _cnt_[_c_]++  ok
			next
			for _c_ = 1 to _n_
				if _cnt_[_c_] > 0  loop  ok
				_a_ + [ :rule = "every_class_colours_a_region",
					:subject = _cM_, :where = "class " + _c_, :severity = "warning",
					:message = "class " + _c_ + " (" + StzFactNumText(@aEdges[_c_]) + " - " +
						StzFactNumText(@aEdges[_c_ + 1]) + ") colours no region -- the legend " +
						"promises a shade the map never shows" ]
			next
		ok

		# 6. A REGION WITH NO VALUE is a hole in the map. It is drawn as no
		# data and said so in the legend, which is honest -- so it advises.
		if _bChoro_
			_nNo_ = 0
			for _i_ = 1 to _nF_
				if NOT isNumber(This.ValueOf(_i_))  _nNo_++  ok
			next
			if _nNo_ > 0
				_a_ + [ :rule = "every_region_has_a_value",
					:subject = _cM_, :where = "" + _nNo_ + " of " + _nF_, :severity = "warning",
					:message = "" + _nNo_ + " of " + _nF_ + " regions carry no value and are " +
						"drawn as no data -- the map is short, and says so" ]
			ok
		ok

		# 7. A REGION THE PAPER CANNOT SHOW. A feature that projects nowhere
		# -- behind the globe, or off the fitted extent -- is counted in the
		# legend and invisible to the reader.
		_nOff_ = 0
		_cFirst_ = ""
		for _i_ = 1 to _nF_
			if This.IsOnPaper(_i_)  loop  ok
			_nOff_++
			if _cFirst_ = ""  _cFirst_ = @oF.NameOf(_i_)  ok
		next
		if _nOff_ > 0
			_a_ + [ :rule = "the_data_fits_the_paper",
				:subject = _cM_, :where = _cFirst_, :severity = "warning",
				:message = "" + _nOff_ + " region(s) project nowhere on this map, beginning " +
					"with '" + _cFirst_ + "' -- they are counted in the legend and cannot be seen" ]
		ok

		return _a_

	# does any point of this feature reach the paper at all?
	def IsOnPaper(pnI)
		_p_ = @oF.PartsOf(pnI)
		for _k_ = 1 to len(_p_)
			_r_ = _p_[_k_][1]
			_n_ = len(_r_) / 2
			_step_ = 1
			if _n_ > 40  _step_ = floor(_n_ / 40)  ok
			for _j_ = 1 to _n_ step _step_
				if len(@oP.Project(_r_[_j_ * 2 - 1], _r_[_j_ * 2])) = 2  return TRUE  ok
			next
		next
		return FALSE

	def IsSound()
		_a_ = This.Findings()
		for _i_ = 1 to len(_a_)
			if _a_[_i_][:severity] = "error"  return FALSE  ok
		next
		return TRUE

	#-- GE5: THE HANDS ------------------------------------------------------
	#
	# What a click is over. The projection is inverted to a place on the
	# sphere and the place is asked of the features -- so the answer is
	# right on a globe, on a cut map, and under any rotation, because none
	# of that is special-cased: it is the same invert the guard asserts
	# round-trips on all sixteen projections.

	# [ lon, lat ] under a pixel, or [] off the sphere
	def PlaceAt(pnX, pnY)
		return @oP.Invert(pnX, pnY)

	# the feature under a pixel, or 0 for the sea, the sky and the margin
	def FeatureAt(pnX, pnY)
		_g_ = @oP.Invert(pnX, pnY)
		if len(_g_) < 2  return 0  ok
		return @oF.IndexAt(_g_[1], _g_[2])

	# ...and what it is called, or "" -- what a tooltip shows
	def NameAt(pnX, pnY)
		_i_ = This.FeatureAt(pnX, pnY)
		if _i_ < 1  return ""  ok
		return @oF.NameOf(_i_)

	# ...and its value, or "" where it has none
	def ValueAt(pnX, pnY)
		_i_ = This.FeatureAt(pnX, pnY)
		if _i_ < 1  return ""  ok
		return This.ValueOf(_i_)
