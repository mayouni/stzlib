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

# THE LAND COLOUR RAMP a choropleth uses when the caller names none: the
# primary hue from light to dark, the same ramp DN24 draws, so two maps of
# the same data in the two planes read alike.
func StzGeoMapPaletteFor(pnClasses)
	return StzChoroplethPaletteFor(pnClasses)

class stzGeoMap from stzObject
	@oP = NULL
	@oF = NULL
	@aValues = []
	@aEdges = []
	@aPalette = []
	@cSource = ""
	@cNoData = "#E8E8E8"

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
