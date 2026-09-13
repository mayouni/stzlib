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
	@nLblNamed = 0
	@nLblNumbered = 0
	@nLblDropped = 0
	@aPaper = []
	@aKeyBox = []
	@aKey = []
	@cKeyCode = ""
	@cKeyTitle = ""
	@bKeyDrawn = FALSE
	@nKeyUnlisted = 0
	@aPlaced = []
	@nCell = 0
	@nGx = 0
	@nGy = 0
	@aLand = []

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
	# A NAME GOES INSIDE ITS REGION OR IT BECOMES A NUMBER. There is no
	# third thing, and there are no lines.
	#
	# There WERE lines. Three rounds of this drew leaders -- a name parked
	# in the nearest empty paper, or out in a margin, with a rule back to
	# the region it belonged to -- and the Principal returned every one of
	# them, the last time as "these lines are a total mess". They were
	# right, and the finding is worth more than the fix: THE LEADERS WERE
	# MY INVENTION AND NOT THE FIELD'S. Asked what the best tools actually
	# do, the answer is that none of them does this for an area:
	#
	#   nivo, Datawrapper, Flourish, ThoughtSpot -- a name is drawn where it
	#     FITS inside its region, and otherwise not at all; the rest is a
	#     tooltip.
	#   d3-geo's own examples -- centroid text above an area threshold.
	#   QGIS (PAL), Mapbox GL, ArcGIS (Maplex) -- collision placement by
	#     priority, and what does not fit is DROPPED at that scale. Maplex
	#     will draw a leader for a POINT feature, capped and short; never a
	#     sheaf of them across a choropleth.
	#   every printed atlas -- IGN, Michelin, National Geographic -- puts a
	#     NUMBER in the small unit and a KEY beside the map. "1 Tunis,
	#     2 Ariana, 3 Ben Arous, 4 Manouba" is how a map of Tunisia has
	#     always handled Grand Tunis.
	#
	# So this file does what the atlases do, in two tiers and a key:
	#
	#   1. THE NAME INSIDE, where its whole box lies within the region it
	#      names -- not merely within that region's bounding box, which is
	#      how a ragged region's name ends up on its neighbour.
	#   2. OTHERWISE A NUMBER, inside the region if the digits fit, and
	#      otherwise in the empty paper TOUCHING its border. Touching, and
	#      not merely near: with no line, what says the number belongs to
	#      this region is that it sits against its edge. One that cannot be
	#      set there is DROPPED AND COUNTED, because a number floating in
	#      open paper is a riddle, not a label.
	#   3. THE KEY beside the map, number to name, NUMBERED IN READING
	#      ORDER -- rows down the sheet, west to east within a row -- so a
	#      reader looking for 17 walks to it instead of hunting.
	#
	# Two things from the leader era were sound and are kept: the ink comes
	# from the colour system (StzReadableTextOn), never from an opinion held
	# in a drawing file; and a label is a BOX, measured at the size it will
	# be drawn and judged against the region AS DRAWN.
	#
	# What is not here, named: INSETS. A zoomed box for Grand Tunis or the
	# Ile-de-France is how an atlas rescues the numbers this drops, and it
	# is the next step, not this one.

	# THE SMALLEST TYPE THIS WILL DRAW. The Principal has returned a picture
	# for unreadable text once per plane; a label below this is not a label.
	def LabelFloor()
		return 13

	# WHAT THE LABELLING DID, in four numbers that add up to the feature
	# count. `unlisted` is the one that was nearly left out: entries the key
	# box had no room for. A key that runs off the bottom of its box loses
	# names SILENTLY, and the first version of DrawKeyOn did exactly that --
	# 39 of France's 75 entries drawn and 36 gone, under a comment in this
	# same file claiming a key must never do that. So it is counted here and
	# the gate refuses it.
	def LabelReport()
		return [ :named = @nLblNamed, :numbered = @nLblNumbered,
		         :dropped = @nLblDropped, :unlisted = @nKeyUnlisted ]

	# where the key is written: [ x0, y0, x1, y1 ]. With no key box set, a
	# region that cannot carry its own name is dropped -- a number with
	# nothing to look it up in is worse than a blank.
	def SetKeyBox(pnX0, pnY0, pnX1, pnY1)
		@aKeyBox = [ pnX0, pnY0, pnX1, pnY1 ]

		def SetKeyBoxQ(pnX0, pnY0, pnX1, pnY1)
			This.SetKeyBox(pnX0, pnY0, pnX1, pnY1)
			return This

	def SetKeyTitle(pcTitle)
		@cKeyTitle = "" + pcTitle

		def SetKeyTitleQ(pcTitle)
			This.SetKeyTitle(pcTitle)
			return This

	# NUMBER THEM WITH THE CODE THEY ALREADY HAVE, where the file carries
	# one. Natural Earth's iso_3166_2 is "FR-59" for the Nord and "TN-83"
	# for Tataouine, and the part after the dash IS the number printed on
	# every French number plate and written on every Tunisian address.
	#
	# OFF BY DEFAULT, and deliberately: official codes are not in reading
	# order, so "08" sitting beside "59" tells a reader who does not
	# already know them nothing about where to look. Sequential in reading
	# order is the atlas default; the code is for a sheet drawn for people
	# who are at home in it.
	def SetKeyCodes(pcProperty)
		@cKeyCode = "" + pcProperty

		def SetKeyCodesQ(pcProperty)
			This.SetKeyCodes(pcProperty)
			return This

	def KeyEntries()
		return @aKey

	# EVERY BOX THE LAST LABELLING PUT DOWN, as [ x0, y0, x1, y1 ]. Exposed
	# so a guard can assert the MECHANISM rather than a number that agrees
	# with it by accident: the suite used to check "fewer regions were named
	# than exist", which passes just as well when nothing was drawn at all.
	# With the boxes in hand it can test every pair and prove they are
	# disjoint.
	def PlacedBoxes()
		return @aPlaced

	def DrawLabelsOn(poCanvas, poFont, pnSize, pInk)
		This.DrawLabelsXT(poCanvas, poFont, pnSize, pInk, FALSE)

	def DrawLabelsWithValuesOn(poCanvas, poFont, pnSize, pInk)
		This.DrawLabelsXT(poCanvas, poFont, pnSize, pInk, TRUE)

	def DrawLabelsXT(poCanvas, poFont, pnSize, pInk, pbValues)
		@bLabelled = TRUE
		@bKeyDrawn = FALSE
		@nKeyUnlisted = 0
		@aPlaced = []
		@nLblNamed = 0
		@nLblNumbered = 0
		@nLblDropped = 0
		@aKey = []
		_nF_ = @oF.Count()
		if _nF_ = 0  return  ok
		_sz_ = pnSize
		if _sz_ < This.LabelFloor()  _sz_ = This.LabelFloor()  ok
		This._BuildLandGrid()

		# --- 1. every name as a BOX, and where its region sits ------------
		_aW_ = []  _aH_ = []  _aX_ = []  _aY_ = []  _aArea_ = []  _aOk_ = []
		for _i_ = 1 to _nF_
			_c_ = "" + @oF.NameOf(_i_)
			_w_ = poFont.WidthOf(_c_, _sz_)
			_h_ = _sz_
			if pbValues and isNumber(This.ValueOf(_i_))
				_w2_ = poFont.WidthOf(StzFactNumText(This.ValueOf(_i_)), _sz_ - 2)
				if _w2_ > _w_  _w_ = _w2_  ok
				_h_ += _sz_
			ok
			_aW_ + _w_
			_aH_ + _h_
			_g_ = This.LabelPointOf(_i_)
			_q_ = []
			if len(_g_) = 2  _q_ = @oP.Project(_g_[1], _g_[2])  ok
			if len(_q_) < 2
				_aX_ + 0  _aY_ + 0  _aArea_ + 0  _aOk_ + FALSE
				loop
			ok
			_aX_ + _q_[1]
			_aY_ + _q_[2]
			_b_ = This.PaperBoxOf(_i_)
			_aArea_ + ((_b_[3] - _b_[1]) * (_b_[4] - _b_[2]))
			_aOk_ + TRUE
		next

		# --- 2. the biggest region speaks first ---------------------------
		# Area is the importance a map has to hand, and a name lost from a
		# large region is the worse loss.
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

		# --- 3. the names that fit inside ---------------------------------
		_placed_ = []
		_rest_ = []
		for _k_ = 1 to _nF_
			_i_ = _ord_[_k_]
			if NOT _aOk_[_i_]  loop  ok
			_bx_ = This._FitInside(_aX_[_i_], _aY_[_i_], _aW_[_i_], _aH_[_i_], _i_, _placed_)
			if len(_bx_) != 4
				_rest_ + _i_
				loop
			ok
			_placed_ + _bx_
			@aPlaced + _bx_
			# THE BASELINE SITS AT EIGHT TENTHS OF THE BOX, not at its
			# bottom. A box of height = type size holds an ascent of about
			# 0.8em and a descent of about 0.2em; putting the baseline on
			# the bottom edge hangs every descender BELOW the box that was
			# tested, so the g of 'Gironde' and the p of a neighbour's name
			# crossed borders the in-region test had certified clear.
			This._WriteLabel(poCanvas, poFont, _sz_, pInk, _i_,
				(_bx_[1] + _bx_[3]) / 2, _bx_[2] + _sz_ * 0.8, pbValues)
			@nLblNamed++
		next

		# --- 4. the rest become numbers, IN READING ORDER -----------------
		#
		# A number is drawn when the reader has SOME way to resolve it: a
		# key box to look it up in, or a mark that is already the unit's
		# public name. With neither, the name is dropped rather than
		# replaced by a digit nothing decodes.
		if len(@aKeyBox) != 4 and @cKeyCode = ""
			for _n_ = 1 to len(_rest_)  @nLblDropped++  next
			poCanvas.Flush()
			return
		ok
		_rest_ = This._ReadingOrder(_rest_, _aX_, _aY_, _sz_)

		for _n_ = 1 to len(_rest_)
			_i_ = _rest_[_n_]
			_c_ = This._KeyMarkOf(_i_, len(@aKey) + 1)
			_w_ = poFont.WidthOf(_c_, _sz_)
			_bx_ = This._FitInside(_aX_[_i_], _aY_[_i_], _w_, _sz_, _i_, _placed_)
			_bIn_ = len(_bx_) = 4
			if NOT _bIn_
				_bx_ = This._FitBeside(_aX_[_i_], _aY_[_i_], _w_, _sz_, _i_, _placed_)
			ok
			if len(_bx_) != 4
				@nLblDropped++
				loop
			ok
			_placed_ + _bx_
			@aPlaced + _bx_
			_ink_ = pInk
			if _bIn_  _ink_ = This.InkOver(_i_, pInk, _sz_)  ok
			poCanvas.SetFontQ(poFont, _sz_).
				AddTextQ(_c_, (_bx_[1] + _bx_[3]) / 2 - _w_ / 2, _bx_[2] + _sz_ * 0.8).Fill(_ink_)
			# THE KEY SHOWS A VALUE ONLY WHEN THE MAP WAS ASKED TO. The
			# first version appended it whenever one existed, so a sheet
			# drawn with DrawLabelsOn -- which shows no numbers anywhere --
			# came out with an area in square kilometres beside every name
			# in the key. The key is the rest of the labelling, not a table.
			_v_ = ""
			if pbValues  _v_ = This.ValueOf(_i_)  ok
			@aKey + [ _c_, "" + @oF.NameOf(_i_), _v_ ]
			@nLblNumbered++
		next
		poCanvas.Flush()

	# THE BOX THAT LIES INSIDE THE REGION, or [] if none does. Nine tries
	# around the anchor: the anchor itself, a line up and a line down, then
	# the sides and the four diagonals -- enough for a region whose widest
	# part is not under its own label point, and cheap enough per feature.
	def _FitInside(pnX, pnY, pnW, pnH, pnI, paPlaced)
		_cand_ = [ [ 0, 0 ], [ 0, -pnH ], [ 0, pnH ], [ -pnW / 2, 0 ], [ pnW / 2, 0 ],
		           [ -pnW / 2, -pnH ], [ pnW / 2, -pnH ], [ -pnW / 2, pnH ], [ pnW / 2, pnH ] ]
		for _t_ = 1 to len(_cand_)
			_bx_ = [ pnX + _cand_[_t_][1] - pnW / 2, pnY + _cand_[_t_][2] - pnH / 2,
			         pnX + _cand_[_t_][1] + pnW / 2, pnY + _cand_[_t_][2] + pnH / 2 ]
			if NOT This._OnPaper(_bx_)  loop  ok
			if NOT This._BoxInRegion(_bx_, pnI)  loop  ok
			if NOT _GeoBoxFree(_bx_, paPlaced)  loop  ok
			return _bx_
		next
		return []

	# HOW FAR OUTSIDE ITS REGION A NUMBER MAY BE SET, in pixels. Sixteen is
	# about a line of type: far enough to clear a border stroke and the
	# region's own neighbour, near enough that no reader has to decide which
	# of two regions a number belongs to.
	def KeyReachPixels()
		return 16

	# A NUMBER SET AGAINST ITS OWN EDGE, in the empty paper immediately
	# outside the region -- the sea, or the ground beyond the border.
	#
	# AGAINST THE OUTLINE, NOT THE BOUNDING BOX, and that distinction is
	# the whole of this method. The first version stepped outward from the
	# centre of the region's BOX, which for a ragged department put "75"
	# and "74" adrift in the Mediterranean, nearer to Corsica than to
	# anything they named: a box's corner can be a long way from any land.
	# So the search walks the region's own PROJECTED OUTLINE, offsets each
	# sampled vertex along its outward normal, and takes the first offset
	# that lands on empty paper. Every candidate is therefore within a few
	# pixels of a point the reader can see belongs to this region, which is
	# the only thing standing in for the leader line that used to be drawn.
	def _FitBeside(pnX, pnY, pnW, pnH, pnI, paPlaced)
		_r_ = This._PaperRingOf(pnI)
		_n_ = len(_r_) / 2
		if _n_ < 3  return []  ok
		_b_ = This.PaperBoxOf(pnI)
		_cx_ = (_b_[1] + _b_[3]) / 2
		_cy_ = (_b_[2] + _b_[4]) / 2
		# at most sixty vertices looked at, evenly spaced round the ring:
		# a department's outline can carry two thousand points and the
		# hundredth of them says nothing the ninety-ninth did not
		_take_ = 60
		if _n_ < _take_  _take_ = _n_  ok
		_reach_ = This.KeyReachPixels()
		for _step_ = 1 to 3
			_out_ = 4 + (_reach_ - 4) * _step_ / 3
			for _t_ = 0 to _take_ - 1
				_j_ = floor(_t_ * _n_ / _take_) + 1
				_vx_ = _r_[_j_ * 2 - 1]
				_vy_ = _r_[_j_ * 2]
				_dx_ = _vx_ - _cx_
				_dy_ = _vy_ - _cy_
				_d_ = sqrt(_dx_ * _dx_ + _dy_ * _dy_)
				if _d_ < 0.001  loop  ok
				_x_ = _vx_ + _dx_ / _d_ * (_out_ + pnW / 2)
				_y_ = _vy_ + _dy_ / _d_ * (_out_ + pnH / 2)
				_bx_ = [ _x_ - pnW / 2, _y_ - pnH / 2, _x_ + pnW / 2, _y_ + pnH / 2 ]
				if NOT This._OnPaper(_bx_)  loop  ok
				if NOT This._BoxOnEmpty(_bx_)  loop  ok
				if NOT _GeoBoxFree(_bx_, paPlaced)  loop  ok
				return _bx_
			next
		next
		return []

	# the region's largest outer ring, PROJECTED -- the outline as drawn
	def _PaperRingOf(pnI)
		_k_ = @oF.LargestPartOf(pnI)
		_r_ = @oF.OuterRingOf(pnI, _k_)
		_n_ = len(_r_) / 2
		_out_ = []
		for _j_ = 1 to _n_
			_q_ = @oP.Project(_r_[_j_ * 2 - 1], _r_[_j_ * 2])
			if len(_q_) < 2  loop  ok
			_out_ + _q_[1]
			_out_ + _q_[2]
		next
		return _out_

	# THE MARK A NUMBERED REGION CARRIES: its official code where the caller
	# named the property holding one, and otherwise its place in the reading
	# order. "FR-59" yields "59"; a property that is absent or empty falls
	# back to the sequence rather than printing a blank.
	def _KeyMarkOf(pnI, pnSeq)
		if @cKeyCode = ""  return "" + pnSeq  ok
		_v_ = ring_trim("" + @oF.PropertyOf(pnI, @cKeyCode))
		if _v_ = "" or _v_ = "NULL"  return "" + pnSeq  ok
		_a_ = StzSplit(_v_, "-")
		if len(_a_) > 1  _v_ = _a_[len(_a_)]  ok
		return _v_

	# READING ORDER: rows down the sheet, west to east inside a row. A plain
	# sort on y alone numbers two regions side by side in whatever order
	# their centres happen to differ by a pixel, which reads as random; a
	# BAND of two and a half lines of type is what makes a row a row.
	def _ReadingOrder(paIdx, paX, paY, pnSize)
		_n_ = len(paIdx)
		if _n_ < 2  return paIdx  ok
		_a_ = paIdx
		for _p_ = 1 to _n_ - 1
			for _q_ = 1 to _n_ - _p_
				if paY[_a_[_q_]] > paY[_a_[_q_ + 1]]
					_t_ = _a_[_q_]
					_a_[_q_] = _a_[_q_ + 1]
					_a_[_q_ + 1] = _t_
				ok
			next
		next
		_band_ = pnSize * 2.5
		_out_ = []
		_row_ = [ _a_[1] ]
		_top_ = paY[_a_[1]]
		for _k_ = 2 to _n_
			if paY[_a_[_k_]] - _top_ <= _band_
				_row_ + _a_[_k_]
				loop
			ok
			# ONE AT A TIME, never `_out_ = _out_ + _row_`. Ring's `+` on a
			# list appends ONE item, so adding a list adds it NESTED -- and
			# the next loop then indexes an array with a list and reads out
			# of range, which is the error this cost.
			_r2_ = This._WestToEast(_row_, paX)
			for _z_ = 1 to len(_r2_)  _out_ + _r2_[_z_]  next
			_row_ = [ _a_[_k_] ]
			_top_ = paY[_a_[_k_]]
		next
		_r2_ = This._WestToEast(_row_, paX)
		for _z_ = 1 to len(_r2_)  _out_ + _r2_[_z_]  next
		return _out_

	def _WestToEast(paRow, paX)
		_n_ = len(paRow)
		_r_ = paRow
		for _p_ = 1 to _n_ - 1
			for _q_ = 1 to _n_ - _p_
				if paX[_r_[_q_]] > paX[_r_[_q_ + 1]]
					_t_ = _r_[_q_]
					_r_[_q_] = _r_[_q_ + 1]
					_r_[_q_ + 1] = _t_
				ok
			next
		next
		return _r_

	# THE KEY, in as many columns as its box will carry. A key that runs off
	# the bottom of its box is a key that lost entries silently, so the
	# column width comes from the widest entry ACTUALLY PRESENT and the row
	# count from the box's own height.
	def DrawKeyOn(poCanvas, poFont, pnSize, pInk)
		if len(@aKeyBox) != 4  return  ok
		@bKeyDrawn = TRUE
		@nKeyUnlisted = 0
		if len(@aKey) = 0  return  ok
		_sz_ = pnSize
		if _sz_ < This.LabelFloor()  _sz_ = This.LabelFloor()  ok
		_x0_ = @aKeyBox[1]
		_y0_ = @aKeyBox[2]
		if @cKeyTitle != ""
			poCanvas.SetFontQ(poFont, _sz_).AddTextQ(@cKeyTitle, _x0_, _y0_ + _sz_).Fill(pInk)
			_y0_ += _sz_ + 8
		ok
		_pitch_ = _sz_ + 5
		_rows_ = floor((@aKeyBox[4] - _y0_) / _pitch_)
		if _rows_ < 1
			@nKeyUnlisted = len(@aKey)
			return
		ok
		_wMark_ = 0
		_wAll_ = 0
		for _k_ = 1 to len(@aKey)
			_w_ = poFont.WidthOf(@aKey[_k_][1], _sz_)
			if _w_ > _wMark_  _wMark_ = _w_  ok
		next
		for _k_ = 1 to len(@aKey)
			_w_ = _wMark_ + 6 + poFont.WidthOf(This._KeyTextOf(_k_), _sz_)
			if _w_ > _wAll_  _wAll_ = _w_  ok
		next
		_colw_ = _wAll_ + 16
		_cols_ = floor((@aKeyBox[3] - _x0_) / _colw_)
		if _cols_ < 1  _cols_ = 1  ok
		_room_ = _rows_ * _cols_
		if len(@aKey) > _room_  @nKeyUnlisted = len(@aKey) - _room_  ok
		for _k_ = 1 to len(@aKey)
			_c_ = floor((_k_ - 1) / _rows_)
			if _c_ >= _cols_  exit  ok
			_r_ = (_k_ - 1) % _rows_
			_x_ = _x0_ + _c_ * _colw_
			_y_ = _y0_ + _r_ * _pitch_ + _sz_
			# the mark RIGHT-ALIGNED in its own column, the way a numbered
			# list sets: ones under tens, so every name starts on one edge
			_m_ = @aKey[_k_][1]
			_wm_ = poFont.WidthOf(_m_, _sz_)
			poCanvas.SetFontQ(poFont, _sz_).AddTextQ(_m_, _x_ + _wMark_ - _wm_, _y_).Fill(pInk)
			poCanvas.SetFontQ(poFont, _sz_).
				AddTextQ(This._KeyTextOf(_k_), _x_ + _wMark_ + 6, _y_).Fill(pInk)
		next
		poCanvas.Flush()

	def _KeyTextOf(pnK)
		_c_ = @aKey[pnK][2]
		if isNumber(@aKey[pnK][3])  _c_ += "  " + StzFactNumText(@aKey[pnK][3])  ok
		return _c_

	# --- THE EMPTY PAPER IS A RASTER, NOT FIVE SAMPLED POINTS ------------
	#
	# The first version asked whether the four corners and the centre of a
	# name's box fell on any region. It let "Sousse" be written across the
	# Cap Bon peninsula and "Manubah" across the gulf into Bizerte, because
	# a forty-pixel box laid over a coastline can miss land at all five
	# points and still cover it in between. Sampling a shape at five points
	# is not a test of the shape.
	#
	# So the paper is RASTERISED ONCE, at four pixels a cell, exactly the
	# way a serious label engine keeps an obstacle layer: every region's
	# rings are walked and the cells they cross are marked as coastline,
	# then the paper is FLOOD FILLED inward from its own edge. What the
	# flood reaches without crossing a coastline is empty paper -- the sea,
	# the margin, the ground outside the country -- and nothing else is.
	# A box is empty when every cell it covers was reached.
	#
	# It costs one pass over the rings the map has already drawn, and it
	# turns every later question into four integer comparisons and a lookup.
	# A per-candidate geometric test would be tens of thousands of
	# point-in-polygon calls; this is none.
	def _BuildLandGrid()
		@aLand = []
		@nCell = 0
		if len(@aPaper) != 4  return  ok
		_cell_ = 4
		_gx_ = ceil((@aPaper[3] - @aPaper[1]) / _cell_) + 1
		_gy_ = ceil((@aPaper[4] - @aPaper[2]) / _cell_) + 1
		if _gx_ < 2 or _gy_ < 2  return  ok
		# A SHEET THIS BIG IS NOT A LABELLING PROBLEM, IT IS A MISTAKE.
		# Guarding the cell count keeps a caller who passes a paper of a
		# million pixels from silently spending a minute here.
		if _gx_ * _gy_ > 400000  return  ok
		_n_ = _gx_ * _gy_
		_g_ = []
		for _t_ = 1 to _n_  _g_ + 0  next

		# 1. the coastlines, marked cell by cell
		_nF_ = @oF.Count()
		for _i_ = 1 to _nF_
			_np_ = @oF.PartCount(_i_)
			for _k_ = 1 to _np_
				_r_ = @oF.OuterRingOf(_i_, _k_)
				_m_ = len(_r_) / 2
				if _m_ < 2  loop  ok
				_px_ = -99999  _py_ = -99999
				for _j_ = 1 to _m_
					_q_ = @oP.Project(_r_[_j_ * 2 - 1], _r_[_j_ * 2])
					if len(_q_) < 2
						_px_ = -99999
						loop
					ok
					_cx_ = (_q_[1] - @aPaper[1]) / _cell_
					_cy_ = (_q_[2] - @aPaper[2]) / _cell_
					if _px_ > -99998
						_dx_ = _cx_ - _px_
						_dy_ = _cy_ - _py_
						_len_ = fabs(_dx_)
						if fabs(_dy_) > _len_  _len_ = fabs(_dy_)  ok
						_steps_ = ceil(_len_ * 2) + 1
						for _t_ = 0 to _steps_
							_u_ = _t_ / _steps_
							_a_ = floor(_px_ + _dx_ * _u_)
							_b_ = floor(_py_ + _dy_ * _u_)
							if _a_ >= 0 and _a_ < _gx_ and _b_ >= 0 and _b_ < _gy_
								_g_[_b_ * _gx_ + _a_ + 1] = 1
							ok
						next
					ok
					_px_ = _cx_
					_py_ = _cy_
				next
			next
		next

		# 2. the flood, inward from the paper's own edge
		_q_ = []
		for _a_ = 0 to _gx_ - 1
			if _g_[_a_ + 1] = 0        _g_[_a_ + 1] = 2        _q_ + _a_               ok
			_z_ = (_gy_ - 1) * _gx_ + _a_
			if _g_[_z_ + 1] = 0        _g_[_z_ + 1] = 2        _q_ + _z_               ok
		next
		for _b_ = 0 to _gy_ - 1
			_z_ = _b_ * _gx_
			if _g_[_z_ + 1] = 0        _g_[_z_ + 1] = 2        _q_ + _z_               ok
			_z_ = _b_ * _gx_ + _gx_ - 1
			if _g_[_z_ + 1] = 0        _g_[_z_ + 1] = 2        _q_ + _z_               ok
		next
		# a HEAD INDEX, never a del() -- Ring's list removal is O(n) and a
		# flood over twenty thousand cells would pay it twenty thousand times
		_h_ = 1
		while _h_ <= len(_q_)
			_z_ = _q_[_h_]
			_h_++
			_a_ = _z_ % _gx_
			_b_ = floor(_z_ / _gx_)
			if _a_ > 0 and _g_[_z_] = 0            _g_[_z_] = 2            _q_ + (_z_ - 1)     ok
			if _a_ < _gx_ - 1 and _g_[_z_ + 2] = 0 _g_[_z_ + 2] = 2        _q_ + (_z_ + 1)     ok
			if _b_ > 0 and _g_[_z_ - _gx_ + 1] = 0
				_g_[_z_ - _gx_ + 1] = 2
				_q_ + (_z_ - _gx_)
			ok
			if _b_ < _gy_ - 1 and _g_[_z_ + _gx_ + 1] = 0
				_g_[_z_ + _gx_ + 1] = 2
				_q_ + (_z_ + _gx_)
			ok
		end
		@aLand = _g_
		@nGx = _gx_
		@nGy = _gy_
		@nCell = _cell_

	# EMPTY, AND WITH AIR AROUND IT. The box is grown by three pixels before
	# the question is asked, so a name never comes to rest touching a border
	# it does not cross.
	def _BoxOnEmpty(paBox)
		if @nCell = 0  return FALSE  ok
		_a0_ = floor((paBox[1] - 3 - @aPaper[1]) / @nCell)
		_a1_ = floor((paBox[3] + 3 - @aPaper[1]) / @nCell)
		_b0_ = floor((paBox[2] - 3 - @aPaper[2]) / @nCell)
		_b1_ = floor((paBox[4] + 3 - @aPaper[2]) / @nCell)
		if _a0_ < 0 or _b0_ < 0 or _a1_ >= @nGx or _b1_ >= @nGy  return FALSE  ok
		for _b_ = _b0_ to _b1_
			_row_ = _b_ * @nGx
			for _a_ = _a0_ to _a1_
				if @aLand[_row_ + _a_ + 1] != 2  return FALSE  ok
			next
		next
		return TRUE

	def _WriteLabel(poCanvas, poFont, pnSize, pInk, pnI, pnCx, pnY, pbValues)
		_ink_ = This.InkOver(pnI, pInk, pnSize)
		_c_ = "" + @oF.NameOf(pnI)
		_w_ = poFont.WidthOf(_c_, pnSize)
		poCanvas.SetFontQ(poFont, pnSize).AddTextQ(_c_, pnCx - _w_ / 2, pnY).Fill(_ink_)
		if NOT pbValues  return  ok
		if NOT isNumber(This.ValueOf(pnI))  return  ok
		_t_ = StzFactNumText(This.ValueOf(pnI))
		_w2_ = poFont.WidthOf(_t_, pnSize - 2)
		poCanvas.SetFontQ(poFont, pnSize - 2).AddTextQ(_t_, pnCx - _w2_ / 2, pnY + pnSize).Fill(_ink_)

	# --- 3. THE INK IS THE COLOUR SYSTEM'S ANSWER, NOT THIS FILE'S --------
	#
	# This used to ask StzIsDarkColor and choose white or the caller's ink,
	# and it put black names on dark blue and dark red -- which the
	# Principal returned twice. The house HAS a contrast contract:
	# StzReadableTextOn(background, sizePx, bold) answers the ink AND
	# whether that size can carry it, measured against WCAG's 4.5:1 for
	# normal text and 3:1 for large. A drawing file has no business having
	# its own opinion about contrast when the colour system holds one.
	def InkOver(pnI, pInk, pnSize)
		if len(@aEdges) < 2 or len(@aValues) = 0  return pInk  ok
		_c_ = This.ClassOf(pnI)
		_bg_ = @cNoData
		if _c_ >= 1  _bg_ = @aPalette[_c_]  ok
		_r_ = StzReadableTextOn(_bg_, pnSize, FALSE)
		return StzResolveColor(_r_[1])

	# --- 2. IS THE WHOLE BOX INSIDE THE REGION IT NAMES? Sampled on a grid, at
	# eight pixels or finer, and NOT at the four corners and the centre.
	#
	# This made the same mistake _BoxOnEmpty made, and made it in the same
	# picture: a name is forty-odd pixels wide, a border is one pixel, and a
	# border that cuts across the middle of the box misses all five sampled
	# points -- so "Zinder" was written across the line into Maradi and
	# "Sfax" across its own coast. SAMPLING A SHAPE AT ITS CORNERS IS NOT A
	# TEST OF THE SHAPE, and having written that sentence about the sea this
	# morning I left the identical defect standing in the test beside it.
	#
	# The grid is sized from the box, so a long name costs more points than
	# a short one and nothing costs more than 8 x 6.
	def _BoxInRegion(paBox, pnI)
		_k_ = @oF.LargestPartOf(pnI)
		_w_ = paBox[3] - paBox[1]
		_h_ = paBox[4] - paBox[2]
		_nc_ = ceil(_w_ / 8) + 1
		_nr_ = ceil(_h_ / 8) + 1
		if _nc_ < 2  _nc_ = 2  ok
		if _nr_ < 2  _nr_ = 2  ok
		if _nc_ > 8  _nc_ = 8  ok
		if _nr_ > 6  _nr_ = 6  ok
		for _r_ = 0 to _nr_ - 1
			_y_ = paBox[2] + _h_ * _r_ / (_nr_ - 1)
			for _c_ = 0 to _nc_ - 1
				_x_ = paBox[1] + _w_ * _c_ / (_nc_ - 1)
				_g_ = @oP.Invert(_x_, _y_)
				if len(_g_) < 2  return FALSE  ok
				if NOT @oF.PartContains(pnI, _k_, _g_[1], _g_[2])  return FALSE  ok
			next
		next
		return TRUE

	def _OnPaper(paBox)
		if len(@aPaper) != 4  return TRUE  ok
		return paBox[1] >= @aPaper[1] and paBox[3] <= @aPaper[3] and
		       paBox[2] >= @aPaper[2] and paBox[4] <= @aPaper[4]

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

		# 1c-bis. A NUMBER ON THE MAP HAS SOMETHING TO LOOK IT UP IN.
		# Numbering is what replaced the leader lines, and it works because
		# a key stands beside the map. A sheet carrying "17" with no key is
		# strictly worse than one that left the region blank: the reader can
		# see there was something to know and has no way to it.
		#
		# TWO SEVERITIES, AND THE DIFFERENCE IS REAL. A SEQUENTIAL mark is
		# an index into a key and nothing else, so without the key it means
		# nothing to anybody: ERROR. An OFFICIAL CODE is the unit's own
		# public name -- "59" is the Nord to every French reader, the way
		# "CA" is California -- so a sheet of codes without a key is how
		# every road atlas of France is printed, and the only reader it
		# fails is the one from elsewhere: WARNING.
		if @nLblNumbered > 0 and NOT @bKeyDrawn
			_sev_ = "error"
			_why_ = "a number with nothing to look it up in tells the reader only " +
				"that they are missing something"
			if @cKeyCode != ""
				_sev_ = "warning"
				_why_ = "the marks are official codes from '" + @cKeyCode + "', which " +
					"a reader at home in the country already knows -- but a reader " +
					"from elsewhere has no way in"
			ok
			_a_ + [ :rule = "every_number_has_a_key",
				:subject = _cM_, :where = "" + @nLblNumbered + " numbered regions",
				:severity = _sev_,
				:message = "" + @nLblNumbered + " region(s) carry a number instead of a " +
					"name and DrawKeyOn was never called -- " + _why_ ]
		ok

		# 1c-ter. AND THE KEY LISTS EVERY ONE OF THEM. A key box too small
		# for its entries drops the tail off the bottom, and the reader has
		# no way to know it happened -- they look for 61, do not find it,
		# and conclude they misread the map. Found in this file's own France
		# sheet: 39 entries drawn of 75.
		if @nKeyUnlisted > 0
			_a_ + [ :rule = "the_key_lists_every_number",
				:subject = _cM_, :where = "" + @nKeyUnlisted + " entries",
				:severity = "error",
				:message = "the key box has room for " +
					"" + (@nLblNumbered - @nKeyUnlisted) + " of " + @nLblNumbered +
					" entries, so " + @nKeyUnlisted + " number(s) are drawn on the map " +
					"and appear nowhere in the key -- give the key box more room, or " +
					"fewer numbers to carry" ]
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
