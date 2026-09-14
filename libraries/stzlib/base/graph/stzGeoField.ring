# stzGeoField -- A QUANTITY THAT HAS A VALUE EVERYWHERE (GE7b)
#
# GE7a asked whether a LIST of places is clustered. This asks the other half
# of every spatial question: rainfall, elevation, temperature, the smoothed
# intensity of an outbreak -- things that are not a list at all but a
# quantity defined over ground.
#
# Wolfram spends three of its twelve geo plot types on this and they are the
# same substrate seen three ways:
#
#   GeoSmoothHistogram  a point pattern, smoothed  ->  StzGeoDensityField
#   GeoDensityPlot      the field, coloured        ->  DrawOn
#   GeoContourPlot      the field, at levels       ->  DrawContoursOn
#
# So there is ONE type here and three things done to it. A field is a grid of
# numbers over lon/lat, row 0 SOUTH, and a value that is not known is ""
# rather than a number -- because the commonest way an elevation map acquires
# a trench eleven kilometres deep is a NODATA of -9999 read as a depth.
#
# WHERE A FIELD COMES FROM:
#
#   StzGeoDensityField(points, cellKm, bandwidthKm)
#       the kernel density of a stzGeoPoints pattern, in PLACES PER KM2,
#       clipped to that pattern's own window and edge-corrected by default.
#   StzGeoFieldFromAsciiGrid(text)
#       an ESRI ASCII grid, the format every GIS can write. Bring your own
#       rainfall or elevation raster; this library vendors no data.
#   StzGeoField(grid, values)
#       the plain constructor, for a field computed some other way.
#
# WHAT IT REFUSES: to be drawn as a density over a projection that does not
# preserve area, for the same reason a choropleth may not be -- shading that
# says "per square kilometre" over a Mercator says a bigger number in the
# north than it means. GE3 already refuses that for regions; this is the
# same rule for the raster, and it is a rule and not a preference.

func StzGeoField(paGrid, paValues)
	return new stzGeoField(paGrid, paValues)

# THE SMOOTHED INTENSITY OF A POINT PATTERN, in places per km2. cellKm is how
# fine the answer is, bandwidthKm how far each place spreads -- and the
# bandwidth is the choice that matters: too small and the map is the points
# again with halos, too large and every country is one smooth hill.
func StzGeoDensityField(poPoints, pnCellKm, pnBandwidthKm)
	return StzGeoDensityFieldXT(poPoints, pnCellKm, pnBandwidthKm, :Quartic, TRUE)

func StzGeoDensityFieldXT(poPoints, pnCellKm, pnBandwidthKm, pcKernel, pbEdgeCorrected)
	if NOT isObject(poPoints)
		stzraise("StzGeoDensityField: the first argument is a stzGeoPoints -- a " +
			"density needs the window as much as the places, because a kernel " +
			"near the border spills its mass outside it.")
	ok
	if pnBandwidthKm <= 0
		stzraise("StzGeoDensityField: the bandwidth is a distance in km and must " +
			"be positive -- it is how far one place spreads.")
	ok
	_k_ = 0
	_c_ = StzLower(ring_trim("" + pcKernel))
	if _c_ = "gaussian"
		_k_ = 1
	but _c_ != "quartic"
		stzraise("StzGeoDensityField: the kernel is :Quartic (compact, what every " +
			"GIS calls kernel density) or :Gaussian (truncated at four bandwidths).")
	ok
	_g_ = StzEngineGeoGridOver(poPoints.Window().Bounds(), pnCellKm)
	_e_ = 0
	if pbEdgeCorrected  _e_ = 1  ok
	_v_ = StzEngineGeoKernelDensity(poPoints.Points(), _g_, pnBandwidthKm, _k_,
		poPoints.WindowRings(), poPoints.Window().Bounds(), _e_)
	_f_ = new stzGeoField(_g_, _v_)
	_f_.SetUnit("places per km2")
	_f_.SetSource("kernel density, " + _c_ + " at " + pnBandwidthKm + " km")
	return _f_

func StzGeoFieldFromAsciiGrid(pcText)
	_a_ = StzEngineGeoReadAsciiGrid("" + pcText)
	if len(_a_) < 2
		stzraise("StzGeoFieldFromAsciiGrid: this is not an ESRI ASCII grid, or it " +
			"ends before its own header says it should. The header is ncols, " +
			"nrows, xllcorner/xllcenter, yllcorner/yllcenter, cellsize and an " +
			"optional NODATA_value; a short file is refused rather than half read.")
	ok
	_f_ = new stzGeoField(_a_[1], _a_[2])
	_f_.SetSource("ESRI ASCII grid")
	return _f_

class stzGeoField from stzObject
	@aGrid = []
	@aVals = []
	@cUnit = ""
	@cSource = ""
	@aEdges = []
	@aPalette = []

	def init(paGrid, paValues)
		if NOT (isList(paGrid) and len(paGrid) = 6)
			stzraise("stzGeoField: the grid is [ lon0, lat0, dlon, dlat, nx, ny ].")
		ok
		if paGrid[5] < 2 or paGrid[6] < 2
			stzraise("stzGeoField: a grid needs at least two nodes each way.")
		ok
		if NOT isList(paValues) or len(paValues) != paGrid[5] * paGrid[6]
			stzraise("stzGeoField: the grid says " + paGrid[5] + " x " + paGrid[6] +
				" = " + (paGrid[5] * paGrid[6]) + " values and " + len(paValues) +
				" were given.")
		ok
		@aGrid = paGrid
		@aVals = paValues

	#-- what it is ---------------------------------------------------------

	def Grid()
		return @aGrid

	def Values()
		return @aVals

	def ColumnCount()
		return @aGrid[5]

	def RowCount()
		return @aGrid[6]

	def CellSizeDegrees()
		return [ @aGrid[3], @aGrid[4] ]

	# [ lon0, lat0, lon1, lat1 ] -- the ground this field covers
	def Bounds()
		return [ @aGrid[1], @aGrid[2],
		         @aGrid[1] + (@aGrid[5] - 1) * @aGrid[3],
		         @aGrid[2] + (@aGrid[6] - 1) * @aGrid[4] ]

	def SetUnit(pcUnit)
		@cUnit = "" + pcUnit

		def SetUnitQ(pcUnit)
			This.SetUnit(pcUnit)
			return This

	def Unit()
		return @cUnit

	def SetSource(pcSource)
		@cSource = "" + pcSource

		def SetSourceQ(pcSource)
			This.SetSource(pcSource)
			return This

	def Source()
		return @cSource

	#-- reading it ---------------------------------------------------------

	# [ :min, :max, :known, :unknown ] -- and `unknown` is the one to read
	# first, because a field that is nine tenths nodata will draw as a
	# handsome map of one tenth of the ground
	def Stats()
		_a_ = StzEngineGeoFieldStats(@aVals)
		if len(_a_) < 4  return [ :min = 0, :max = 0, :known = 0, :unknown = 0 ]  ok
		return [ :min = _a_[1], :max = _a_[2], :known = _a_[3], :unknown = _a_[4] ]

	def Min()
		return This.Stats()[:min]

	def Max()
		return This.Stats()[:max]

	# the value at a place: bilinear where its four neighbours are known,
	# nearest where they are not, "" off the grid or with nothing to read
	def ValueAt(pnLon, pnLat)
		return StzEngineGeoFieldAt(@aVals, @aGrid, pnLon, pnLat)

	# LEVELS SPREAD EVENLY BETWEEN THE ENDS, which is what a contour map
	# without a stated scheme means. The ends themselves are left out: a
	# contour at the minimum is the whole map's border and a contour at the
	# maximum is a point.
	def LevelsEvery(pnHowMany)
		_s_ = This.Stats()
		if _s_[:known] = 0 or pnHowMany < 1  return []  ok
		_a_ = []
		for _i_ = 1 to pnHowMany
			_a_ + (_s_[:min] + (_s_[:max] - _s_[:min]) * _i_ / (pnHowMany + 1))
		next
		return _a_

	# the contour at one level, as a list of lon/lat polylines
	def ContourAt(pnLevel)
		return StzEngineGeoContour(@aVals, @aGrid, pnLevel)

	#-- how it is coloured -------------------------------------------------

	def SetClasses(paEdges)
		if NOT isList(paEdges) or len(paEdges) < 2
			stzraise("stzGeoField.SetClasses: the edges are a rising list, at least " +
				"two of them.")
		ok
		for _i_ = 2 to len(paEdges)
			if paEdges[_i_] <= paEdges[_i_ - 1]
				stzraise("stzGeoField.SetClasses: the edges must rise -- " +
					paEdges[_i_ - 1] + " is followed by " + paEdges[_i_] + ".")
			ok
		next
		@aEdges = paEdges
		if len(@aPalette) != len(paEdges) - 1
			@aPalette = StzGeoRamp(:YlOrRd, len(paEdges) - 1)
		ok

		def SetClassesQ(paEdges)
			This.SetClasses(paEdges)
			return This

	# CLASS EDGES FROM THE FIELD ITSELF, evenly between its ends. Equal steps
	# and not quantiles, because a density's story is usually its peak and a
	# quantile scale flattens exactly that.
	def SetClassesEvery(pnHowMany)
		_s_ = This.Stats()
		if _s_[:known] = 0
			stzraise("stzGeoField.SetClassesEvery: this field has no known value " +
				"at all -- there is nothing to divide.")
		ok
		_a_ = []
		for _i_ = 0 to pnHowMany
			_a_ + (_s_[:min] + (_s_[:max] - _s_[:min]) * _i_ / pnHowMany)
		next
		This.SetClasses(_a_)

		def SetClassesEveryQ(pnHowMany)
			This.SetClassesEvery(pnHowMany)
			return This

	def SetRamp(pName)
		if len(@aEdges) < 2
			stzraise("stzGeoField.SetRamp: set the classes before the ramp -- a ramp " +
				"has to know how many steps to give.")
		ok
		@aPalette = StzGeoRamp(pName, len(@aEdges) - 1)

		def SetRampQ(pName)
			This.SetRamp(pName)
			return This

	def SetPalette(paColours)
		if len(@aEdges) > 1 and len(paColours) != len(@aEdges) - 1
			stzraise("stzGeoField.SetPalette: " + (len(@aEdges) - 1) + " classes and " +
				len(paColours) + " colours.")
		ok
		@aPalette = paColours

		def SetPaletteQ(paColours)
			This.SetPalette(paColours)
			return This

	def Classes()
		return @aEdges

	def Palette()
		return @aPalette

	#-- drawing it ---------------------------------------------------------

	# THE FIELD AS A PICTURE, resampled through the projection into ONE image.
	#
	# Not as cells: a lon/lat cell is not a rectangle once a conic has had it,
	# and forty thousand quads would be forty thousand wrong shapes. The
	# engine inverts every pixel of the box, reads the field there and takes
	# its class's colour -- which is how every GIS draws a raster under a
	# projection, and costs one AddImage.
	#
	# pnAlpha lets the map beneath show through; 255 is opaque.
	def DrawOn(poCanvas, poProjection, pnX0, pnY0, pnX1, pnY1)
		This.DrawXT(poCanvas, poProjection, pnX0, pnY0, pnX1, pnY1, 255)

	def DrawXT(poCanvas, poProjection, pnX0, pnY0, pnX1, pnY1, pnAlpha)
		if len(@aEdges) < 2
			stzraise("stzGeoField.DrawOn: set the classes first -- a field drawn " +
				"without them has no legend, and a shade with no legend is a " +
				"decoration.")
		ok
		_w_ = floor(pnX1 - pnX0)
		_h_ = floor(pnY1 - pnY0)
		if _w_ < 1 or _h_ < 1  return  ok
		# the palette as bytes, through the colour system's resolver and
		# stzGeoMap's own hex reader -- a second hex reader in this file
		# would be the second definition of one thing
		_rgb_ = []
		for _i_ = 1 to len(@aPalette)
			_c_ = StzResolveColor(@aPalette[_i_])
			if NOT (isString(_c_) and StzLeft(_c_, 1) = "#" and len(_c_) >= 7)
				_c_ = "#888888"
			ok
			# 1, 3, 5 and not 0, 2, 4: _GeoHexByte reads the two digits AFTER
			# the offset, so the red of "#RRGGBB" starts at 1. Called with 0
			# it reads the '#' as the high nibble of red, and a ramp of warm
			# yellows came out as a cyan fringe. Reusing the house helper
			# instead of writing a second one was right; not reading its
			# contract first was not.
			_rgb_ + _GeoHexByte(_c_, 1)
			_rgb_ + _GeoHexByte(_c_, 3)
			_rgb_ + _GeoHexByte(_c_, 5)
		next
		_img_ = StzEngineGeoFieldImage(poProjection.Params(), @aVals, @aGrid,
			pnX0, pnY0, _w_, _h_, @aEdges, _rgb_, pnAlpha)
		if len(_img_) < _w_ * _h_ * 4  return  ok
		poCanvas.AddImage(pnX0, pnY0, _w_, _h_, _w_, _h_, _img_)

	# THE CONTOURS, one stroke per level. A contour is a LINE and never a
	# fill: the ground between two levels is not one value, and shading it as
	# though it were is the choropleth lie in another costume.
	def DrawContoursOn(poCanvas, poProjection, paLevels, pStroke, pnWidth)
		for _i_ = 1 to len(paLevels)
			_pieces_ = This.ContourAt(paLevels[_i_])
			for _k_ = 1 to len(_pieces_)
				_proj_ = poProjection.Line(_pieces_[_k_])
				for _q_ = 1 to len(_proj_)
					if len(_proj_[_q_]) >= 4
						poCanvas.AddPolylineQ(_proj_[_q_]).Stroke(pStroke, pnWidth)
					ok
				next
			next
		next
		poCanvas.Flush()

	# the legend a field owes: one row per class, with the unit named
	def DrawLegendOn(poCanvas, poFont, pnX, pnY, pcTitle)
		_y_ = pnY
		_t_ = "" + pcTitle
		if _t_ = "" and @cUnit != ""  _t_ = @cUnit  ok
		if _t_ != ""
			poCanvas.SetFontQ(poFont, 13).AddTextQ(_t_, pnX, _y_).Fill("#333333")
			_y_ += 20
		ok
		for _i_ = len(@aPalette) to 1 step -1
			poCanvas.AddRectQ(pnX, _y_ - 10, 16, 12).FillQ(@aPalette[_i_]).Stroke("#FFFFFF", 0.5)
			poCanvas.SetFontQ(poFont, 13).
				AddTextQ(StzFactNumText(@aEdges[_i_]) + " to " + StzFactNumText(@aEdges[_i_ + 1]),
					pnX + 24, _y_).Fill("#555555")
			_y_ += 18
		next
		poCanvas.Flush()
		return _y_

	#-- what the gate owes a field -----------------------------------------

	def Findings()
		return This.FindingsOn(NULL)

	def FindingsOn(poProjection)
		_a_ = []
		_s_ = This.Stats()
		_c_ = "field " + This.ColumnCount() + "x" + This.RowCount()
		if @cUnit != ""  _c_ = "field of " + @cUnit  ok

		# 1. A FIELD WITH NOTHING IN IT. Every level, every class and every
		# legend below divides by a range that does not exist.
		if _s_[:known] = 0
			_a_ + [ :rule = "a_field_has_a_known_value",
				:subject = _c_, :where = "all " + (_s_[:known] + _s_[:unknown]) + " nodes",
				:severity = "error",
				:message = "no node of this field has a value -- a NODATA sentinel " +
					"read as a number is the usual cause, and it draws as a handsome " +
					"map of nothing" ]
			return _a_
		ok

		# 2. MOSTLY UNKNOWN. Honest, common, and worth saying: a raster
		# clipped to a country is mostly outside it, and a reader seeing a
		# full rectangle of colour should know how much of it was measured.
		_n_ = _s_[:known] + _s_[:unknown]
		if _s_[:unknown] > _n_ * 0.9
			_a_ + [ :rule = "most_of_the_field_is_measured",
				:subject = _c_, :where = "" + _s_[:unknown] + " of " + _n_ + " nodes",
				:severity = "warning",
				:message = "" + floor(_s_[:unknown] * 100 / _n_) + "% of this field's " +
					"nodes have no value -- what is drawn is a tenth of the ground " +
					"it covers" ]
		ok

		# 3. CLASSES THAT DO NOT REACH THE DATA. The top of a field outside
		# the last edge draws as nothing, so the peak -- the one thing a
		# density map is usually FOR -- comes out as a hole.
		if len(@aEdges) > 1
			if _s_[:max] > @aEdges[len(@aEdges)]
				_a_ + [ :rule = "the_classes_reach_the_data",
					:subject = _c_, :where = "max " + StzFactNumText(_s_[:max]),
					:severity = "error",
					:message = "the field reaches " + StzFactNumText(_s_[:max]) +
						" and the last class edge is " + StzFactNumText(@aEdges[len(@aEdges)]) +
						" -- everything above it draws as NO DATA, so the peak comes " +
						"out as a hole" ]
			ok
			if _s_[:min] < @aEdges[1]
				_a_ + [ :rule = "the_classes_reach_the_data",
					:subject = _c_, :where = "min " + StzFactNumText(_s_[:min]),
					:severity = "warning",
					:message = "the field falls to " + StzFactNumText(_s_[:min]) +
						" and the first class edge is " + StzFactNumText(@aEdges[1]) +
						" -- everything below it draws as no data" ]
			ok
		ok

		# 4. A DENSITY WANTS AN EQUAL-AREA PROJECTION, exactly as a
		# choropleth does (GE3). Shading that says "per square kilometre"
		# over a Mercator says a bigger number in the north than it means.
		if isObject(poProjection) and @cUnit != ""
			if StzFindFirst("per km2", @cUnit) > 0 and NOT poProjection.IsEqualArea()
				_a_ + [ :rule = "a_density_wants_an_equal_area_projection",
					:subject = _c_, :where = poProjection.Name(),
					:severity = "error",
					:message = "this field is measured " + @cUnit + " and " +
						poProjection.Name() + " does not preserve area -- the same " +
						"density draws as a bigger patch of colour the further it is " +
						"from the standard line" ]
			ok
		ok
		return _a_

	def IsSound()
		_a_ = This.Findings()
		for _i_ = 1 to len(_a_)
			if _a_[_i_][:severity] = "error"  return FALSE  ok
		next
		return TRUE
