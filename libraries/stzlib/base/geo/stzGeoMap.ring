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
		[ :Earth,   [ "#F6F1E5", "#DCCFA8", "#B8A165", "#8C6D36", "#5C4218" ] ],

		# VIRIDIS, whose absence from this table was a real gap: it is the
		# default scientific ramp almost everywhere, and the reason is that
		# it is PERCEPTUALLY UNIFORM -- equal steps in the data are equal
		# steps to the eye -- and it survives being printed in grey and
		# being read by the colour-blind, neither of which the rainbow it
		# replaced can claim.
		[ :Viridis, [ "#440154", "#3B528B", "#21918C", "#5EC962", "#FDE725" ] ],

		# THE OTHER TWO PERCEPTUALLY-UNIFORM STANDARDS, which travel with
		# Viridis for the same reasons and are chosen for different grounds:
		# Magma reads on a DARK background where Viridis washes out, and
		# Cividis is built to look the same to a colour-blind reader as to
		# anyone else -- not merely legible, identical.
		[ :Magma,   [ "#000004", "#3B0F70", "#8C2981", "#DE4968", "#FE9F6D" ] ],
		[ :Cividis, [ "#00204D", "#31446B", "#666970", "#9C9078", "#FFE945" ] ],

		# ...AND A RAMP FOR LINES ON A LIGHT GROUND, which the others are
		# not. Every sequential ramp above is built for FILLED AREAS, so its
		# pale end is nearly the paper -- correct for a choropleth, where a
		# light region still has an outline, and useless for a half-pixel
		# stroke, which simply vanishes. This one stays dark enough to see
		# at every speed and carries the magnitude in hue and depth at once.
		[ :Flow,    [ "#9DB4CE", "#6B8CB8", "#42619E", "#3B3F8C", "#4A1F6B" ] ]
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
# IS THIS PAPER POINT INSIDE THIS PAPER OUTLINE? An even-odd ray cast, the
# textbook one, done here rather than through the features object because
# the anchor search asks it a hundred times per region and each of those
# would otherwise be an inverse projection followed by a crossing into the
# engine. Everything this decides is re-checked exactly by _BoxInRegion.
func _PaperPointIn(paRing, pnX, pnY)
	_n_ = len(paRing) / 2
	if _n_ < 3  return FALSE  ok
	_in_ = FALSE
	_j_ = _n_
	for _i_ = 1 to _n_
		_xi_ = paRing[_i_ * 2 - 1]
		_yi_ = paRing[_i_ * 2]
		_xj_ = paRing[_j_ * 2 - 1]
		_yj_ = paRing[_j_ * 2]
		if (_yi_ > pnY) != (_yj_ > pnY)
			if pnX < (_xj_ - _xi_) * (pnY - _yi_) / (_yj_ - _yi_) + _xi_
				_in_ = NOT _in_
			ok
		ok
		_j_ = _i_
	next
	return _in_

# THE CENTRE OF A REGION IS ITS AREA CENTROID, AND NOT THE MEAN OF ITS
# OUTLINE'S POINTS. Those are two different places and the difference is
# visible on every real map.
#
# A mean of vertices is a mean of the SAMPLING, not of the shape: a ragged
# coast carries fifty points where a straight desert border carries two, so
# the mean slides towards the coast and a name centred on it sits off to one
# side of the region it names. The Principal marked five of them on one
# sheet -- Agadez, Zinder, Diffa, Kebili and Tataouine -- each pulled a
# different way, which is the signature of this and not of a placement bug.
#
# The area centroid is the shoelace formula, and it does not care how the
# outline was sampled: a long straight edge of two points weighs exactly as
# much as the area it bounds. A degenerate ring -- zero area, all points on
# a line -- has no centroid, and falls back to the mean, which is then the
# right answer for the only reason it is ever the right answer.
func _PaperCentroid(paRing)
	_n_ = len(paRing) / 2
	if _n_ < 3  return []  ok
	_a2_ = 0
	_cx_ = 0
	_cy_ = 0
	for _i_ = 1 to _n_
		_j_ = _i_ + 1
		if _j_ > _n_  _j_ = 1  ok
		_x1_ = paRing[_i_ * 2 - 1]
		_y1_ = paRing[_i_ * 2]
		_x2_ = paRing[_j_ * 2 - 1]
		_y2_ = paRing[_j_ * 2]
		_cr_ = _x1_ * _y2_ - _x2_ * _y1_
		_a2_ += _cr_
		_cx_ += (_x1_ + _x2_) * _cr_
		_cy_ += (_y1_ + _y2_) * _cr_
	next
	if fabs(_a2_) < 0.000001
		_sx_ = 0  _sy_ = 0
		for _i_ = 1 to _n_
			_sx_ += paRing[_i_ * 2 - 1]
			_sy_ += paRing[_i_ * 2]
		next
		return [ _sx_ / _n_, _sy_ / _n_ ]
	ok
	return [ _cx_ / (3 * _a2_), _cy_ / (3 * _a2_) ]

# HOW MUCH ROOM IS AROUND THIS POINT, in pixels: the distance to the nearest
# vertex of the outline. Nearest VERTEX and not nearest EDGE, which is a
# slight over-estimate on a long straight border -- and the right trade,
# because this only RANKS candidates and _BoxInRegion is what decides.
func _PaperEdgeDist(paRing, pnX, pnY)
	_n_ = len(paRing) / 2
	_best_ = 1000000000
	for _i_ = 1 to _n_
		_dx_ = paRing[_i_ * 2 - 1] - pnX
		_dy_ = paRing[_i_ * 2] - pnY
		_d_ = _dx_ * _dx_ + _dy_ * _dy_
		if _d_ < _best_  _best_ = _d_  ok
	next
	return sqrt(_best_)

# HATCH A POLYGON, CLIPPED TO IT, at 45 degrees.
#
# Every point on one hatch line has the same x + y, so the family of lines
# is just a sweep of that sum -- which turns "where does this diagonal cross
# the shape" into the ordinary scanline question, asked along a rotated
# axis. For each line the edges it crosses are found, the crossings sorted
# along it, and the ODD spans drawn: inside, outside, inside, exactly as
# even-odd filling works.
#
# It is written once and called by two things that must not drift apart --
# the no-data countries on the map and the no-data swatch in the legend. A
# reader has to recognise the second as the first.
func _HatchPolygon(poCanvas, paXY, pnSpacing, pColour, pnWidth)
	_n_ = len(paXY) / 2
	if _n_ < 3 or pnSpacing <= 0  return  ok
	_lo_ = paXY[1] + paXY[2]
	_hi_ = _lo_
	for _i_ = 2 to _n_
		_u_ = paXY[_i_ * 2 - 1] + paXY[_i_ * 2]
		if _u_ < _lo_  _lo_ = _u_  ok
		if _u_ > _hi_  _hi_ = _u_  ok
	next
	# START ON A GLOBAL GRID, so two countries sharing a border carry one
	# continuous hatch across it instead of two patterns meeting at an angle.
	#
	# The cost of a global grid is that a shape's phase is decided by where
	# it happens to sit, and a shape narrower than the spacing can fall
	# BETWEEN two grid lines and catch none -- which would leave a small
	# country unhatched, silently, and put us back at "no data is invisible"
	# for exactly the countries a reader is least able to identify. Measured
	# on the world sheet before this line existed: Belgium took two lines in
	# the upper panel and one in the lower, off nothing but the panel's y
	# offset. So a shape that catches nothing is swept once through its
	# middle: every no-data region carries at least one mark.
	_c_ = floor(_lo_ / pnSpacing) * pnSpacing
	_drawn_ = 0
	while _c_ <= _hi_
		_drawn_ += _HatchSweep(poCanvas, paXY, _n_, _c_, pColour, pnWidth)
		_c_ += pnSpacing
	end
	if _drawn_ = 0
		_HatchSweep(poCanvas, paXY, _n_, (_lo_ + _hi_) / 2, pColour, pnWidth)
	ok

# ONE HATCH LINE, clipped: the crossings of the diagonal x + y = pnC with the
# polygon's edges, sorted along it, and the odd spans drawn. Returns how many
# segments it drew, which is how _HatchPolygon knows a shape caught nothing.
func _HatchSweep(poCanvas, paXY, pnN, pnC, pColour, pnWidth)
	_xs_ = []
	_j_ = pnN
	for _i_ = 1 to pnN
		_xi_ = paXY[_i_ * 2 - 1]
		_yi_ = paXY[_i_ * 2]
		_xj_ = paXY[_j_ * 2 - 1]
		_yj_ = paXY[_j_ * 2]
		_ui_ = _xi_ + _yi_
		_uj_ = _xj_ + _yj_
		if (_ui_ <= pnC) != (_uj_ <= pnC)
			_t_ = (pnC - _ui_) / (_uj_ - _ui_)
			_xs_ + (_xi_ + (_xj_ - _xi_) * _t_)
		ok
		_j_ = _i_
	next
	if len(_xs_) < 2  return 0  ok
	for _a_ = 1 to len(_xs_) - 1
		for _b_ = 1 to len(_xs_) - _a_
			if _xs_[_b_] > _xs_[_b_ + 1]
				_t_ = _xs_[_b_]
				_xs_[_b_] = _xs_[_b_ + 1]
				_xs_[_b_ + 1] = _t_
			ok
		next
	next
	_out_ = 0
	_k_ = 1
	while _k_ + 1 <= len(_xs_)
		_x1_ = _xs_[_k_]
		_x2_ = _xs_[_k_ + 1]
		if _x2_ - _x1_ > 0.4
			poCanvas.AddLineQ(_x1_, pnC - _x1_, _x2_, pnC - _x2_).Stroke(pColour, pnWidth)
			_out_++
		ok
		_k_ += 2
	end
	return _out_

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

# Holds a map made of layers: a projection and a set of features, with values, classes, groups, labels, insets, legends, scale bar, sun and flows drawn on a canvas.
#
# Build it with StzGeoMap(oProjection, oFeatures) after fitting the projection to the features. The
# data layer takes one value per feature (SetValues, from stzGeoAtlas.ValuesFor, CountPointsIn or
# ValuesFromArea) or named groups (SetGroups), the classes are the author's (SetClasses, SetRamp,
# SetOpenTop) and a region with no value is hatched, never coloured as zero. SetPaper tells the map
# its sheet and should be the first call: labels are kept on it and the scale bar and the stream-
# density raster are measured over it. DrawSheetOn is the statistical map: dark hairline borders,
# the no-data hatch and the selection outlined; DrawLabelsOn writes a name inside its region or
# numbers it with a key; AddInset magnifies a place too small to label. A map judges itself
# (Findings, IsSound): a choropleth, a membership map or hexagon bins on a projection that is not
# equal-area is an error, as is a number with no key. Known gaps: with values set and no classes,
# ClassOf, ColourOf and the Draw methods that colour raise error R2; an inset does not copy
# SetOpenTop; DensityPointsIn is per 10000 km2. Pictures, each looked at by 'stzlib-docs visual pass
# (a model reading the PNG)' on 2026-10-05: doc/gallery/stzGeoMap/niger_density.png, a density
# choropleth with inset, legend, scale bar and north arrow, RIGHT except the Niamey inset, which is
# grey instead of red (WRONG, see FINDINGS_geo.md); world_area.png, country areas on Equal Earth
# with a hatched no-data region, RIGHT; africa_blocs.png, a membership map, RIGHT;
# daynight_world.png, the night side and twilight on 2026-10-05, RIGHT; hexbin_flows.png, hexagon
# bins, area-true circles and great-circle routes, RIGHT; wind_streams.png and wind_arrows.png, an
# invented wind field, RIGHT as far as a picture can say. Index: doc/gallery/INDEX_geo.md.
#
#   receiver   o1 = StzGeoMap(oP, oN)  # oN =
#              StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson")), oP =
#              StzGeoConicFor(oN, :ConicEqualArea) fitted to oN
#   example    ? o1.Features().Count()
#              #--> 8
#              ? o1.LabelMode()
#              #--> auto
#   see        stzGeoProjection, stzGeoFeatures, stzGeoAtlas, stzGeoField
class stzGeoMap from stzObject
	@oP = NULL
	@oF = NULL
	@aValues = []
	@aEdges = []
	@aPalette = []
	@cSource = ""
	@aGroups = []
	@aGroupOf = []
	@aUnresolved = []
	@aHighlit = []
	@nHiClass = 0
	@bIdentify = FALSE
	@cNoData = "#E8E8E8"
	@cHatch = "#9EB6D8"
	@bOpenTop = FALSE
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
	@cLabelMode = :Auto
	@aRingCache = []
	@aCentroidCache = []
	@aInsets = []
	@cInsetInk = "#5A6B7C"
	@cInsetPaper = "#FFFFFF"
	@nLblInset = 0
	@bInsetsDrawn = FALSE
	@nCell = 0
	@nGx = 0
	@nGy = 0
	@aLand = []

	# Binds the map to a projection and to the features it draws; raises an error unless both are objects.
	#
	#   poProjection   the stzGeoProjection that places everything
	#   poFeatures     the stzGeoFeatures to draw
	#   returns        nothing; the map is bound
	#   note           StzGeoMap(oProjection, oFeatures) builds and binds in one call. Fit the
	#                  projection to the features first
	#   see            StzGeoMap, Projection
	def Bind(poProjection, poFeatures)
		if NOT isObject(poProjection) or NOT isObject(poFeatures)
			stzraise("stzGeoMap: give a projection and a set of features.")
		ok
		@oP = poProjection
		@oF = poFeatures

	# Returns the projection the map draws with.
	#
	#   returns    a stzGeoProjection
	#   see        Bind, Features
	def Projection()
		return @oP

	# Returns the features the map draws.
	#
	#   returns    a stzGeoFeatures
	#   see        Bind, Projection
	def Features()
		return @oF

	# Sets the value that colours each feature, one per feature in the features' own order, "" where there is none.
	#
	#   paValues   one number per feature, or "" for no data
	#   returns    nothing; the values are stored
	#   note       A region with no value is drawn as no data, never as zero. Set the classes before
	#              drawing: with values and no classes the Draw methods that colour raise error R2
	#   see        ValueOf, SetClasses, stzGeoAtlas.ValuesFor
	#@ aka  -- what is being shown -------------------------------------------------
	def SetValues(paValues)
		@aValues = paValues

		def SetValuesQ(paValues)
			This.SetValues(paValues)
			return This

	# Returns every feature's own area in square kilometres, a value that needs no other file.
	#
	#   returns    a list of numbers, one per feature
	#   note       Measured on WGS84, like AreasKm2; an older comment in the source says sphere
	#   see        SetValues, stzGeoFeatures.AreasKm2
	#@ aka  every feature's own true area in square kilometres, measured on the SPHERE from its rings -- a value that needs no other file, and the one an equal-area projection can be checked against
	def ValuesFromArea()
		return @oF.AreasKm2()

	# Returns the value of feature pnI.
	#
	#   pnI        the position of the feature, from 1
	#   returns    the stored value, or "" when pnI is outside the list of values
	#   see        SetValues, ClassOf
	def ValueOf(pnI)
		if pnI < 1 or pnI > len(@aValues)  return ""  ok
		return @aValues[pnI]

	# Sets the class edges that colour the regions, and gives a Blues ramp of the right size when the number of classes changed.
	#
	#   paEdges    a rising list of at least two edges
	#   returns    nothing; the edges are stored
	#   note       Raises an error for fewer than two edges or edges that do not rise. The edges are
	#              the author's: there are no automatic breaks
	#   see        SetRamp, SetPalette, SetOpenTop, ClassOf
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

	# Sets the class colours from a named ramp, in as many steps as there are classes.
	#
	#   pName      the ramp's name: :Blues, :YlOrRd, :YlGnBu, :Greens, :Oranges, :Purples, :Reds,
	#              :BuPu, :Earth, :Viridis, :Magma, :Cividis or :Flow
	#   returns    nothing; the palette is stored
	#   note       Raises an error before the classes are set
	#   warning    Defect: the error for an unknown name lists nine ramps although thirteen exist
	#              (Viridis, Magma, Cividis and Flow are missing from the message).
	#   see        SetPalette, StzGeoRamps
	#@ aka  the palette by the name of a ramp, in the classes already set
	def SetRamp(pName)
		if len(@aEdges) < 2
			stzraise("stzGeoMap.SetRamp: set the classes before the ramp -- a ramp " +
				"has to know how many steps to give.")
		ok
		@aPalette = StzGeoRamp(pName, len(@aEdges) - 1)

		def SetRampQ(pName)
			This.SetRamp(pName)
			return This

	# Sets the colour of each class by hand.
	#
	#   paColours   one colour per class, as hex text
	#   returns     nothing; the palette is stored
	#   note        Set the classes first, then the palette or the ramp
	#   warning     Defect: before SetClasses it raises with the message -1 classes need -1 colours,
	#               because an empty edge list counts as -1 classes.
	#   see         SetRamp, SetClasses
	def SetPalette(paColours)
		if len(paColours) != len(@aEdges) - 1
			stzraise("stzGeoMap: " + (len(@aEdges) - 1) + " classes need " +
				(len(@aEdges) - 1) + " colours -- " + len(paColours) + " given.")
		ok
		@aPalette = paColours

		def SetPaletteQ(paColours)
			This.SetPalette(paColours)
			return This

	# Tells the map the box it is drawn in, so no label is written off the sheet and the scale bar is measured over that box.
	#
	#   pnX0       left edge of the sheet
	#   pnY0       top edge of the sheet
	#   pnX1       right edge of the sheet
	#   pnY1       bottom edge of the sheet
	#   returns    nothing; the box is stored
	#   note       Call it first
	#   warning    Defect: when it is not called, the scale-bar and stream-density methods guess the
	#              sheet from the projection's scale and misjudge a country map.
	#   see        DrawLabelsOn, DrawScaleBarOn
	#@ aka  where the boundaries came from and when. A map asserts where a border lies; this class will not invent the authority for it. THE BOX THE MAP WAS DRAWN IN, so a name cannot be written off the edge of it. Without this the label engine only knows where a region is, not where the sheet ends, and the first version wrote "Diffa" half into the margin beside it. Unset, nothing is clipped.
	def SetPaper(pnX0, pnY0, pnX1, pnY1)
		@aPaper = [ pnX0, pnY0, pnX1, pnY1 ]

		def SetPaperQ(pnX0, pnY0, pnX1, pnY1)
			This.SetPaper(pnX0, pnY0, pnX1, pnY1)
			return This

	# Sets the fill colour of a region no class and no group claims.
	#
	#   pColour    the colour, as hex text
	#   returns    nothing; the colour is stored
	#   note       The default is #E8E8E8
	#   see        SetHatch, ColourOf
	#@ aka  THE COLOUR OF A REGION NO CLASS AND NO GROUP CLAIMS. It is a real statement -- "this one is not in the data" -- and a caller drawing a bloc map wants it quieter than the default, because on that sheet the unclaimed countries are most of the world.
	def SetNoData(pColour)
		@cNoData = pColour

		def SetNoDataQ(pColour)
			This.SetNoData(pColour)
			return This

	# Sets the colour of the hatch that says "not measured", on the map and in the legend swatch.
	#
	#   pColour    the hatch colour, as hex text
	#   returns    nothing; the colour is stored
	#   note       The default is #9EB6D8
	#   see        Hatch, DrawNoDataHatchOn
	#@ aka  THE COLOUR OF THE HATCH THAT SAYS "NOT MEASURED", on the map and in the legend's swatch, which are one thing and read from one place. The default is a blue-grey: cool, so it cannot be mistaken for a step in a warm ramp, and light, so a hatched country does not out-shout a measured one.
	def SetHatch(pColour)
		@cHatch = pColour

		def SetHatchQ(pColour)
			This.SetHatch(pColour)
			return This

	# Returns the colour of the no-data hatch.
	#
	#   returns    text, "#9EB6D8" by default
	#   see        SetHatch
	def Hatch()
		return @cHatch

	# Declares that the top class has no upper edge, so a value above the last edge belongs to it and the legend draws an arrow.
	#
	#   pbOn       1 to make the top class open
	#   returns    nothing; the flag is stored
	#   warning    Defect: an inset made by DrawInsetsOn does not copy it, so a region above the
	#              last edge shows as no data in the inset (Niamey on the Niger sheet).
	#   see        IsOpenTop, ClassOf, DrawRampLegendOn
	#@ aka  IS THE TOP CLASS OPEN -- "30 and over" rather than "20 to 30". It is a statement about the SCALE, so it lives with the scale and not in the legend's argument list: the classifier and the legend both read it, and a reader must never meet an arrow the map refused to fill.
	def SetOpenTop(pbOn)
		@bOpenTop = pbOn

		def SetOpenTopQ(pbOn)
			This.SetOpenTop(pbOn)
			return This

	# TRUE if the top class has been declared open.
	#
	#   returns    TRUE or FALSE
	#   see        SetOpenTop
	def IsOpenTop()
		return @bOpenTop

	# Sets the text that says where the boundaries came from and when; the caption prints it.
	#
	#   pcSource   the source of the boundaries as text
	#   returns    nothing; the text is stored
	#   note       Without it the caption says "boundaries: source not stated" and Findings warns
	#   see        Caption, Findings
	def SetSource(pcSource)
		@cSource = "" + pcSource

		def SetSourceQ(pcSource)
			This.SetSource(pcSource)
			return This

	# Sets a membership map: groups of named regions each with a colour, in place of any quantity.
	#
	#   paGroups   a list of [ label, colour, [ names ] ] rows
	#   returns    nothing; the groups are stored, and the names that matched nothing are kept for
	#              UnresolvedMembers
	#   note       Raises an error for no groups or a row with fewer than three items. A country
	#              named in two groups goes to the first. "Cabo Verde" matches nothing in the 110m
	#              file: no alias, unlike stzGeoAtlas
	#   see        Groups, GroupOf, UnresolvedMembers, DrawGroupKeyOn
	#@ aka  -- MEMBERSHIP, WHICH IS NOT A QUANTITY --------------------------------
	def SetGroups(paGroups)
		if NOT isList(paGroups) or len(paGroups) = 0
			stzraise("stzGeoMap.SetGroups: the groups are " +
				"[ [ label, colour, [ names ] ], ... ] -- a bloc is a list of " +
				"country names, which is how anybody actually has one.")
		ok
		_n_ = @oF.Count()
		@aGroups = []
		@aGroupOf = []
		@aUnresolved = []
		for _i_ = 1 to _n_  @aGroupOf + 0  next
		for _g_ = 1 to len(paGroups)
			_row_ = paGroups[_g_]
			if NOT (isList(_row_) and len(_row_) >= 3)
				stzraise("stzGeoMap.SetGroups: group " + _g_ + " is not " +
					"[ label, colour, [ names ] ].")
			ok
			@aGroups + [ :label = "" + _row_[1], :colour = _row_[2], :members = _row_[3],
			             :found = 0, :taken = 0 ]
			for _k_ = 1 to len(_row_[3])
				_c_ = "" + _row_[3][_k_]
				_i_ = @oF.IndexOfName(_c_)
				if _i_ < 1
					@aUnresolved + [ :group = "" + _row_[1], :name = _c_ ]
					loop
				ok
				@aGroups[_g_][:found]++
				if @aGroupOf[_i_] = 0
					@aGroupOf[_i_] = _g_
				else
					@aGroups[_g_][:taken]++
				ok
			next
		next

		def SetGroupsQ(paGroups)
			This.SetGroups(paGroups)
			return This

	# Returns the groups with how many members were found and how many were already taken by an earlier group.
	#
	#   returns    a list of hash lists [ :label, :colour, :members, :found, :taken ]
	#   see        SetGroups, GroupOf
	def Groups()
		return @aGroups

	# Returns the group that claimed feature pnI.
	#
	#   pnI        the position of the feature, from 1
	#   returns    a number from 1, or 0 for none or a position out of range
	#   see        SetGroups, IsGrouped
	#@ aka  which group claimed this feature, or 0 for none
	def GroupOf(pnI)
		if len(@aGroupOf) < pnI  return 0  ok
		return @aGroupOf[pnI]

	# Returns every member name that matched no feature.
	#
	#   returns    a list of hash lists [ :group, :name ], [ ] when all matched
	#   note       A non-empty list makes Findings report an error: the map draws fewer members than
	#              its key claims
	#   see        SetGroups, Findings
	#@ aka  [ [ :group, :name ], ... ] -- every member name that matched no feature
	def UnresolvedMembers()
		return @aUnresolved

	# TRUE if groups have been set.
	#
	#   returns    TRUE or FALSE
	#   see        SetGroups
	def IsGrouped()
		return len(@aGroups) > 0

	# Draws one swatch and one label per group on a canvas.
	#
	#   poCanvas   the stzCanvas to draw on
	#   poFont     the stzFont to write with
	#   pnSize     the type size, never below 13
	#   pnX        left edge of the key
	#   pnY        baseline of the first row
	#   pInk       the text colour
	#   returns    the y to continue from, or pnY when there are no groups
	#   note       Rows are pnSize + 10 pixels apart
	#   see        SetGroups, DrawLegendOn
	#@ aka  the key a membership map owes: one swatch and one label per group, with the count it actually DREW rather than the count it was handed
	def DrawGroupKeyOn(poCanvas, poFont, pnSize, pnX, pnY, pInk)
		if len(@aGroups) = 0  return pnY  ok
		_sz_ = pnSize
		if _sz_ < This.LabelFloor()  _sz_ = This.LabelFloor()  ok
		_y_ = pnY
		for _g_ = 1 to len(@aGroups)
			poCanvas.AddRectQ(pnX, _y_ - _sz_ + 2, _sz_ + 4, _sz_).
				FillQ(@aGroups[_g_][:colour]).Stroke("#FFFFFF", 0.8)
			poCanvas.SetFontQ(poFont, _sz_).
				AddTextQ(@aGroups[_g_][:label], pnX + _sz_ + 12, _y_).Fill(pInk)
			_y_ += _sz_ + 10
		next
		poCanvas.Flush()
		return _y_

	# Returns the class that feature pnI's value falls in.
	#
	#   pnI        the position of the feature, from 1
	#   returns    a number from 1, or 0 for no value or a value outside the classes
	#   note       An edge belongs to the class above it, the top edge to the top class
	#   warning    Defect: raises error R2 when values are set and the classes are not, because the
	#              class edges are an empty list read at index 0.
	#   see        ColourOf, SetOpenTop
	def ClassOf(pnI)
		_v_ = This.ValueOf(pnI)
		if NOT isNumber(_v_)  return 0  ok
		_n_ = len(@aEdges) - 1
		for _c_ = 1 to _n_
			if _v_ >= @aEdges[_c_] and _v_ < @aEdges[_c_ + 1]  return _c_  ok
		next
		if _v_ = @aEdges[_n_ + 1]  return _n_  ok
		# ABOVE THE TOP EDGE, WHEN THE TOP IS DECLARED OPEN, IS THE TOP CLASS.
		# The ramp legend can draw its last swatch as an arrow, which says to
		# the reader "30 and over". If the classifier then answered 0 for a
		# value of 35, the legend would promise a class the map refused to put
		# anyone in -- and that country would be drawn as NO DATA, which is a
		# lie about a number somebody measured.
		if @bOpenTop and _v_ > @aEdges[_n_ + 1]  return _n_  ok
		return 0

	# Returns the fill colour of feature pnI: its group's colour, its class's colour, or the no-data colour.
	#
	#   pnI        the position of the feature, from 1
	#   returns    the colour as hex text
	#   note       A group outranks a class
	#   warning    Defect: raises error R2 when values are set and the classes are not, because the
	#              class edges are an empty list read at index 0.
	#   see        ClassOf, SetNoData
	def ColourOf(pnI)
		# a group is MEMBERSHIP and outranks any numeric class: a map cannot
		# be both "which bloc" and "how much" at once, and a caller who set
		# groups meant the first
		if len(@aGroups) > 0
			_g_ = This.GroupOf(pnI)
			if _g_ < 1  return @cNoData  ok
			return @aGroups[_g_][:colour]
		ok
		_c_ = This.ClassOf(pnI)
		if _c_ < 1  return @cNoData  ok
		return @aPalette[_c_]

	# Draws the old-style layers on a canvas: sphere, graticule every 30 degrees, regions with white edges, the world's edge.
	#
	#   poCanvas   the stzCanvas to draw on
	#   returns    nothing; the layers are added to the canvas
	#   note       The sheet the statistical maps use is DrawSheetOn
	#   warning    Defect: raises error R2 when values are set and the classes are not, because the
	#              class edges are an empty list read at index 0.
	#   see        DrawSheetOn, DrawRegionsOn
	#@ aka  -- the layers ----------------------------------------------------------
	def DrawOn(poCanvas)
		This.DrawSphereOn(poCanvas, "#EAF1FB", "#8FA8C8", 1)
		This.DrawGraticuleOn(poCanvas, 30, "#D2DCEA", 1)
		This.DrawRegionsOn(poCanvas, "#FFFFFF", 0.6)
		@oP.DrawOutlineOn(poCanvas, "#3B5B8C", 1.5)

		def DrawOnQ(poCanvas)
			This.DrawOn(poCanvas)
			return This

	# Draws the sphere, the sea of the map, on a canvas.
	#
	#   poCanvas   the stzCanvas to draw on
	#   pFill      the fill colour
	#   pStroke    the edge colour
	#   pnW        the edge width in pixels
	#   returns    nothing; the polygon is added to the canvas
	#   note       Draw it first
	#   see        DrawGraticuleOn, stzGeoProjection.DrawSphereOn
	def DrawSphereOn(poCanvas, pFill, pStroke, pnW)
		@oP.DrawSphereOn(poCanvas, pFill, pStroke, pnW)

	# Draws the meridians and parallels every pnStep degrees on a canvas.
	#
	#   poCanvas   the stzCanvas to draw on
	#   pnStep     the spacing of the lines in degrees
	#   pStroke    the line colour
	#   pnW        the line width in pixels
	#   returns    nothing; the lines are added to the canvas
	#   note       The whole sphere, not only the fitted window
	#   see        DrawSphereOn
	def DrawGraticuleOn(poCanvas, pnStep, pStroke, pnW)
		@oP.DrawGraticuleOn(poCanvas, pnStep, pStroke, pnW)

	# Draws every feature in the colour its value earns, with one edge colour.
	#
	#   poCanvas    the stzCanvas to draw on
	#   pStroke     the edge colour
	#   pnStrokeW   the edge width in pixels
	#   returns     nothing; the polygons are added to the canvas
	#   warning     Defect: raises error R2 when values are set and the classes are not, because the
	#               class edges are an empty list read at index 0.
	#   see         DrawSheetOn, ColourOf
	#@ aka  every feature, in the colour its value earns it
	def DrawRegionsOn(poCanvas, pStroke, pnStrokeW)
		for _i_ = 1 to @oF.Count()
			@oP.DrawFeatureOn(poCanvas, @oF, _i_, This.ColourOf(_i_), pStroke, pnStrokeW)
		next

	# Draws one feature again over the rest in a colour of the caller's choice.
	#
	#   poCanvas    the stzCanvas to draw on
	#   pnI         the position of the feature, from 1
	#   pFill       the fill colour
	#   pStroke     the edge colour
	#   pnStrokeW   the edge width in pixels
	#   returns     nothing; the feature is added to the canvas
	#   note        Recolours: to outline a selection instead use SetHighlight
	#   see         SetHighlight, DrawHighlightOn
	#@ aka  one feature picked out, over the rest
	def HighlightOn(poCanvas, pnI, pFill, pStroke, pnStrokeW)
		@oP.DrawFeatureOn(poCanvas, @oF, pnI, pFill, pStroke, pnStrokeW)

	# Draws one circle per feature at its mean point, the circle's AREA carrying the value.
	#
	#   poCanvas      the stzCanvas to draw on
	#   paValues      one value per feature, numbers above 0 drawn and the rest skipped
	#   pnMaxRadius   the radius of the circle of the largest value, in pixels
	#   pFill         the fill colour
	#   pStroke       the edge colour
	#   returns       nothing; the circles are added to the canvas
	#   note          The radius is proportional to the square root of the value. Draws nothing when
	#                 no value is above 0
	#   see           CentroidOf, DrawSymbolAt
	#@ aka  -- symbols -------------------------------------------------------------
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

	# Draws one circle at a place the caller names.
	#
	#   poCanvas   the stzCanvas to draw on
	#   pnLon      longitude in degrees east
	#   pnLat      latitude in degrees north
	#   pnRadius   the radius in pixels
	#   pFill      the fill colour
	#   pStroke    the edge colour
	#   returns    nothing; the circle is added to the canvas
	#   note       LONGITUDE FIRST. A place with no image is skipped
	#   see        DrawSymbolsOn
	#@ aka  a symbol at a place the caller names, rather than at a feature
	def DrawSymbolAt(poCanvas, pnLon, pnLat, pnRadius, pFill, pStroke)
		_q_ = @oP.Project(pnLon, pnLat)
		if len(_q_) < 2  return  ok
		poCanvas.AddCircleQ(_q_[1], _q_[2], pnRadius).FillQ(pFill).Stroke(pStroke, 1)

	# Returns the mean of the points of the outer ring of feature pnI's largest part, in longitude and latitude.
	#
	#   pnI        the position of the feature, from 1
	#   returns    a list [ lon, lat ]; [ ] for a position out of range
	#   note       A mean of vertices, not the area centroid: it follows the sampling, so on a
	#              ragged coast it slides toward the coast
	#   see        LabelPointOf, DrawSymbolsOn
	#@ aka  the middle of a feature's largest part, in longitude and latitude: the mean of its outer ring, which is where a symbol belongs and is NOT where a label belongs on a crescent-shaped country
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

	# Projects places onto the paper and counts them in hexagonal cells.
	#
	#   paLonLat   the places as one flat list lon, lat, lon, lat, ...
	#   pnRadius   the radius of a hexagon in paper units
	#   returns    a list of [ x, y, count ]: the cell centre in paper units and its places
	#   note       Marks the map as binned, so Findings then demands an equal-area projection
	#   see        DrawHexBinsOn, HexBinMax
	#@ aka  -- hexagonal bins ------------------------------------------------------
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

	# Draws the bins on a canvas, each in the colour its count earns from the edges; an empty bin is not drawn.
	#
	#   poCanvas    the stzCanvas to draw on
	#   paBins      the bins as HexBin answers them
	#   pnRadius    the radius of a hexagon in paper units
	#   paEdges     rising count edges
	#   paPalette   one colour per class
	#   pStroke     the edge colour
	#   returns     nothing; the hexagons are added to the canvas
	#   note        A count past the last edge takes the top class
	#   see         HexBin, HexBinMax
	#@ aka  the bins drawn, each in the colour its COUNT earns from the edges given. A bin holding nothing is not drawn: an empty cell is not a quantity of zero, it is a place nobody counted.
	def DrawHexBinsOn(poCanvas, paBins, pnRadius, paEdges, paPalette, pStroke)
		for _i_ = 1 to len(paBins)
			_b_ = paBins[_i_]
			if _b_[3] <= 0  loop  ok
			_c_ = _HexClassOf(_b_[3], paEdges)
			if _c_ < 1  loop  ok
			poCanvas.AddPolygonQ(StzEngineGeoHexagon(_b_[1], _b_[2], pnRadius)).
				FillQ(paPalette[_c_]).Stroke(pStroke, 0.5)
		next

	# Returns the largest count among the bins, what a legend's last edge wants.
	#
	#   paBins     the bins as HexBin answers them
	#   returns    a number, 0 for no bins
	#   see        HexBin
	#@ aka  the biggest count in a set of bins -- what a legend's last edge wants
	def HexBinMax(paBins)
		_m_ = 0
		for _i_ = 1 to len(paBins)
			if paBins[_i_][3] > _m_  _m_ = paBins[_i_][3]  ok
		next
		return _m_

	# Draws great-circle routes between places on a canvas, each as the curve it is.
	#
	#   poCanvas   the stzCanvas to draw on
	#   paRoutes   a list of [ lon1, lat1, lon2, lat2 ] or the same with a width as a fifth item
	#   pStroke    the line colour
	#   pnWidth    the width in pixels when a route gives none
	#   returns    nothing; the lines are added to the canvas
	#   note       A route is a great circle on the sphere, not an ellipsoid geodesic
	#   see        stzGeoProjection.Arc, DrawFlowOn
	#@ aka  -- flows ---------------------------------------------------------------
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

	# Returns which feature each place fell in: a spatial join.
	#
	#   paLonLat   the places as one flat list lon, lat, lon, lat, ...
	#   returns    a list with one number per place, 0 for a place outside every feature
	#   note       A place across the border is 0, not the nearest region
	#   see        CountPointsIn, PointsOutside
	#@ aka  -- observations, joined to the regions they fell in ---------------------
	def AssignPoints(paLonLat)
		_a_ = []
		_n_ = len(paLonLat) / 2
		for _i_ = 1 to _n_
			_a_ + @oF.IndexAt(paLonLat[_i_ * 2 - 1], paLonLat[_i_ * 2])
		next
		return _a_

	# Returns how many places fell in each feature, in the features' order, ready for SetValues.
	#
	#   paLonLat   the places as one flat list lon, lat, lon, lat, ...
	#   returns    a list with one count per feature
	#   note       A count is not a density: colour a choropleth with DensityPointsIn
	#   see        DensityPointsIn, AssignPoints
	#@ aka  how many points fell in each feature, in the features' own order -- which is exactly the shape SetValues takes, so a table of coordinates becomes a choropleth in two calls
	def CountPointsIn(paLonLat)
		_a_ = []
		for _i_ = 1 to @oF.Count()  _a_ + 0  next
		_n_ = len(paLonLat) / 2
		for _i_ = 1 to _n_
			_k_ = @oF.IndexAt(paLonLat[_i_ * 2 - 1], paLonLat[_i_ * 2])
			if _k_ > 0  _a_[_k_]++  ok
		next
		return _a_

	# Returns how many places fell outside every feature.
	#
	#   paLonLat   the places as one flat list lon, lat, lon, lat, ...
	#   returns    a number
	#   see        AssignPoints, CountPointsIn
	#@ aka  ...and how many fell outside every region, which a caller must be told rather than left to notice that their totals do not add up
	def PointsOutside(paLonLat)
		_c_ = 0
		_n_ = len(paLonLat) / 2
		for _i_ = 1 to _n_
			if @oF.IndexAt(paLonLat[_i_ * 2 - 1], paLonLat[_i_ * 2]) = 0  _c_++  ok
		next
		return _c_

	# Returns the places per feature divided by the feature's area, ready for SetValues.
	#
	#   paLonLat   the places as one flat list lon, lat, lon, lat, ...
	#   returns    a list with one number per feature: places per 10000 km2, "" for a feature with
	#              no area
	#   warning    Defect in the comment: the source says per square kilometre but the code
	#              multiplies by 10000, so the figure is per 10000 km2.
	#   see        CountPointsIn, ValuesFromArea
	#@ aka  the same counts, divided by each region's own area in square kilometres: a DENSITY, which is the number a choropleth may honestly colour. A count may not -- a big region collects more of anything -- and that is the commonest lie in the genre after the radius one.
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

	# Returns invented places thrown at random inside the features, by rejection sampling in the bounding box.
	#
	#   pnHowMany   how many places
	#   pnSeed      the seed of the sequence, the same seed giving the same places
	#   returns     a flat list lon, lat, lon, lat, ...; fewer than asked if the tries run out
	#   note        Invented data: say so in the caption
	#   see         CountPointsIn, stzGeoPoints.Sample
	#@ aka  PLACES SCATTERED INSIDE THE REGIONS, for a demonstration or a rehearsal. REJECTION SAMPLING: a point is drawn in the bounding box and kept only if it falls in a region, which is the standard way and the only one that needs no assumption about the shape.
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

	# Returns where a name goes: the area centroid of the largest part, or the roomiest inner point when the centroid is outside it.
	#
	#   pnI        the position of the feature, from 1
	#   returns    a list [ lon, lat ]; [ ] for a ring of fewer than 3 points
	#   warning    Defect: no range check, so a position of 0 or past the last raises error R2.
	#   see        CentroidOf, PaperCentreOf
	#@ aka  -- labels ---------------------------------------------------------------
	def LabelPointOf(pnI)
		_k_ = @oF.LargestPartOf(pnI)
		_r_ = @oF.OuterRingOf(pnI, _k_)
		_n_ = len(_r_) / 2
		if _n_ < 3  return []  ok
		# THE AREA CENTROID, never the mean of the outline's points -- see
		# _PaperCentroid for why those differ and what it looked like when
		# this said "mean". The same correction, on the sphere's side.
		_g_ = _PaperCentroid(_r_)
		if len(_g_) != 2  return []  ok
		_cx_ = _g_[1]
		_cy_ = _g_[2]
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

	# Returns the smallest type size, in pixels, the labelling will draw.
	#
	#   returns    a number, 13
	#   see        DrawLabelsOn
	#@ aka  -- naming the regions ---------------------------------------------------
	def LabelFloor()
		return 13

	# Returns what the last labelling did, in counts.
	#
	#   returns    a hash list [ :named, :numbered, :inset, :dropped, :unlisted ] that adds up to
	#              the feature count
	#   note       Unlisted counts key entries the key box had no room for
	#   see        DrawLabelsOn, Findings
	#@ aka  WHAT THE LABELLING DID, in four numbers that add up to the feature count. `unlisted` is the one that was nearly left out: entries the key box had no room for. A key that runs off the bottom of its box loses names SILENTLY, and the first version of DrawKeyOn did exactly that -- 39 of France's 75 entries drawn and 36 gone, under a comment in this same file claiming a key must never do that. So it is
	def LabelReport()
		return [ :named = @nLblNamed, :numbered = @nLblNumbered,
		         :inset = @nLblInset, :dropped = @nLblDropped,
		         :unlisted = @nKeyUnlisted ]

	# Sets the box where the key is written, so a region too small for its name can be numbered.
	#
	#   pnX0       left edge of the key box
	#   pnY0       top edge of the key box
	#   pnX1       right edge of the key box
	#   pnY1       bottom edge of the key box
	#   returns    nothing; the box is stored
	#   note       Without a key box and without key codes, a region that cannot carry its name is
	#              dropped and counted
	#   see        DrawKeyOn, SetLabelMode
	#@ aka  where the key is written: [ x0, y0, x1, y1 ]. With no key box set, a region that cannot carry its own name is dropped -- a number with nothing to look it up in is worse than a blank.
	def SetKeyBox(pnX0, pnY0, pnX1, pnY1)
		@aKeyBox = [ pnX0, pnY0, pnX1, pnY1 ]

		def SetKeyBoxQ(pnX0, pnY0, pnX1, pnY1)
			This.SetKeyBox(pnX0, pnY0, pnX1, pnY1)
			return This

	# Sets the title written above the key.
	#
	#   pcTitle    the title as text
	#   returns    nothing; the title is stored
	#   see        DrawKeyOn
	def SetKeyTitle(pcTitle)
		@cKeyTitle = "" + pcTitle

		def SetKeyTitleQ(pcTitle)
			This.SetKeyTitle(pcTitle)
			return This

	# Marks the regions by a property's official code, the part after its last dash, instead of 1, 2, 3 in reading order.
	#
	#   pcProperty   the property that holds the code, such as iso_3166_2 where "FR-59" gives 59
	#   returns      nothing; the property name is stored
	#   note         Off by default: codes are not in reading order. A property that is absent or
	#                empty falls back to the sequence
	#   see          DrawKeyOn
	#@ aka  NUMBER THEM WITH THE CODE THEY ALREADY HAVE, where the file carries one. Natural Earth's iso_3166_2 is "FR-59" for the Nord and "TN-83" for Tataouine, and the part after the dash IS the number printed on every French number plate and written on every Tunisian address.
	def SetKeyCodes(pcProperty)
		@cKeyCode = "" + pcProperty

		def SetKeyCodesQ(pcProperty)
			This.SetKeyCodes(pcProperty)
			return This

	# Sets how regions are labelled: :Names, :Numbers or :Auto.
	#
	#   pcMode     :Names for a name or nothing, :Numbers for a number everywhere with the names in
	#              the key, :Auto for the name where it fits and a number where it does not
	#   returns    nothing; the mode is stored
	#   note       Raises an error for another word. The mode is the caller's, not the engine's
	#   see        LabelMode, DrawLabelsOn
	# --- THE THREE WAYS TO LABEL A MAP -----------------------------------
	#@ aka  :Names every region carries its NAME, or nothing at all. What nivo, Datawrapper and Flourish do, and what a map with a dozen big regions wants: no key to consult, no number to decode, and the units too small to hold a name simply go unlabelled. The report says how many.
	def SetLabelMode(pcMode)
		_m_ = StzLower(ring_trim("" + pcMode))
		if _m_ != "auto" and _m_ != "names" and _m_ != "numbers"
			stzraise("stzGeoMap.SetLabelMode: '" + pcMode + "' is not a labelling " +
				"mode -- :Names (name or nothing), :Numbers (a number for every " +
				"region, every name in the key), or :Auto (the name where it fits).")
		ok
		@cLabelMode = _m_

		def SetLabelModeQ(pcMode)
			This.SetLabelMode(pcMode)
			return This

	# Returns the labelling mode.
	#
	#   returns    text, "auto" by default
	#   see        SetLabelMode
	def LabelMode()
		return @cLabelMode

	# Returns the key the last labelling built.
	#
	#   returns    a list of [ mark, name, value ] rows; the value is "" unless the labelling showed
	#              values
	#   see        DrawKeyOn, DrawLabelsOn
	def KeyEntries()
		return @aKey

	# Returns every box the last labelling put down, so a guard can check they do not overlap.
	#
	#   returns    a list of [ x0, y0, x1, y1 ] boxes in paper units
	#   see        DrawLabelsOn, LabelReport
	#@ aka  EVERY BOX THE LAST LABELLING PUT DOWN, as [ x0, y0, x1, y1 ]. Exposed so a guard can assert the MECHANISM rather than a number that agrees with it by accident: the suite used to check "fewer regions were named than exist", which passes just as well when nothing was drawn at all. With the boxes in hand it can test every pair and prove they are disjoint.
	def PlacedBoxes()
		return @aPlaced

	# Writes the regions' names on a canvas inside their regions, and numbers the ones whose name does not fit.
	#
	#   poCanvas   the stzCanvas to draw on
	#   poFont     the stzFont to write with
	#   pnSize     the type size, never below 13
	#   pInk       the text colour where no class colour calls for a better one
	#   returns    nothing; the text is added to the canvas, and LabelReport and KeyEntries are
	#              filled
	#   note       The biggest region speaks first. A map with groups names its members only; a
	#              region held by an inset is left to it
	#   see        DrawLabelsWithValuesOn, DrawKeyOn, LabelReport
	def DrawLabelsOn(poCanvas, poFont, pnSize, pInk)
		This.DrawLabelsXT(poCanvas, poFont, pnSize, pInk, FALSE)

	# Writes each region's name with its value under it, the same labelling as DrawLabelsOn.
	#
	#   poCanvas   the stzCanvas to draw on
	#   poFont     the stzFont to write with
	#   pnSize     the type size, never below 13
	#   pInk       the text colour
	#   returns    nothing; the text is added to the canvas
	#   note       The key shows values too
	#   see        DrawLabelsOn
	def DrawLabelsWithValuesOn(poCanvas, poFont, pnSize, pInk)
		This.DrawLabelsXT(poCanvas, poFont, pnSize, pInk, TRUE)

	# Writes the regions' names on a canvas, with each value under its name when pbValues is TRUE.
	#
	#   poCanvas   the stzCanvas to draw on
	#   poFont     the stzFont to write with
	#   pnSize     the type size, never below 13
	#   pInk       the text colour
	#   pbValues   1 to show the values
	#   returns    nothing; the text is added to the canvas
	#   see        DrawLabelsOn, DrawLabelsWithValuesOn
	def DrawLabelsXT(poCanvas, poFont, pnSize, pInk, pbValues)
		@bLabelled = TRUE
		@bKeyDrawn = FALSE
		@nKeyUnlisted = 0
		@aPlaced = []
		@nLblNamed = 0
		@nLblInset = 0
		@nLblNumbered = 0
		@nLblDropped = 0
		@aKey = []
		_nF_ = @oF.Count()
		if _nF_ = 0  return  ok
		_sz_ = pnSize
		if _sz_ < This.LabelFloor()  _sz_ = This.LabelFloor()  ok
		This._ResolveInsets()
		# the outlines, projected and thinned ONCE, through the one builder
		# DrawNamedLabelOn also uses -- every anchor search reads them
		@aRingCache = []
		@aCentroidCache = []
		This._EnsureLabelCaches()

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
		# In :Numbers every region is a number, so this tier is skipped
		# whole rather than being run and then overridden -- a pass that
		# draws and a pass that undraws is how two of this file's earlier
		# defects got in.
		_placed_ = []
		_rest_ = []
		for _k_ = 1 to _nF_
			_i_ = _ord_[_k_]
			if NOT _aOk_[_i_]  loop  ok
			# A MEMBERSHIP MAP NAMES ITS MEMBERS AND NOTHING ELSE. Where
			# groups are set, the map is ABOUT them: labelling the other
			# hundred and fifty-nine countries of a world sheet would bury
			# the eighteen it exists to show. A caller who wants every
			# region named sets no groups.
			if len(@aGroups) > 0 and This.GroupOf(_i_) = 0  loop  ok
			# A REGION IS LABELLED IN EXACTLY ONE PLACE. What an inset has
			# taken, the parent leaves alone -- otherwise the name appears
			# twice, or the parent reports as DROPPED a region that is in
			# fact named an inch away, which is the worse of the two.
			if This.InsetHolding(_i_) > 0
				@nLblInset++
				loop
			ok
			if @cLabelMode = "numbers"
				_rest_ + _i_
				loop
			ok
			_bx_ = This._FitInside(_aW_[_i_], _aH_[_i_], _i_, _placed_)
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
		#
		# In :Names there is no second tier at all: a region whose name will
		# not fit goes unlabelled, which is what every screen-charting
		# library does and what a reader of a map with no key expects.
		if @cLabelMode = "names"
			for _n_ = 1 to len(_rest_)  @nLblDropped++  next
			poCanvas.Flush()
			return
		ok
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
			_bx_ = This._FitInside(_w_, _sz_, _i_, _placed_)
			_bIn_ = len(_bx_) = 4
			if NOT _bIn_
				_bx_ = This._FitBeside(_w_, _sz_, _i_, _placed_)
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

	# THE BOX THAT LIES INSIDE THE REGION, or [] if none does -- tried at
	# the region's centre first and at its roomiest points after, which is
	# what _AnchorsFor ranks them for.
	#
	# The nine fixed offsets this used to try were arbitrary: half a box
	# left, half a box up, and so on, around whatever point the sphere-side
	# search had produced. They found room by accident when they found it at
	# all. A ranked list of interior points, measured for the room actually
	# around them, is the same work spent on purpose.
	def _FitInside(pnW, pnH, pnI, paPlaced)
		_an_ = This._AnchorsFor(pnI)
		for _t_ = 1 to len(_an_)
			_bx_ = [ _an_[_t_][1] - pnW / 2, _an_[_t_][2] - pnH / 2,
			         _an_[_t_][1] + pnW / 2, _an_[_t_][2] + pnH / 2 ]
			if NOT This._OnPaper(_bx_)  loop  ok
			if NOT This._BoxInRegion(_bx_, pnI)  loop  ok
			if NOT _GeoBoxFree(_bx_, paPlaced)  loop  ok
			return _bx_
		next
		return []

	# Returns how far outside its region a number may be set, in pixels.
	#
	#   returns    a number, 16
	#   see        DrawLabelsOn
	#@ aka  HOW FAR OUTSIDE ITS REGION A NUMBER MAY BE SET, in pixels. Sixteen is about a line of type: far enough to clear a border stroke and the region's own neighbour, near enough that no reader has to decide which of two regions a number belongs to.
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
	def _FitBeside(pnW, pnH, pnI, paPlaced)
		_r_ = @aRingCache[pnI]
		_n_ = len(_r_) / 2
		if _n_ < 3  return []  ok
		_b_ = This.PaperBoxOf(pnI)
		_cx_ = (_b_[1] + _b_[3]) / 2
		_cy_ = (_b_[2] + _b_[4]) / 2
		# at most sixty vertices looked at, evenly spaced round the ring
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

	# --- WHERE A LABEL GOES INSIDE ITS REGION ----------------------------
	#
	# AT THE CENTRE, AND SOMEWHERE BETTER WHEN THE CENTRE IS TOO NARROW FOR
	# IT. Those are two different points and the order between them matters:
	# a reader expects a name in the middle of its region, so the middle is
	# tried first and only a name that will not FIT there is moved.
	#
	# The middle is the mean of the region's outline. When the box will not
	# fit there -- an hourglass pinched at the waist, an L whose mean sits
	# in the notch, a long thin department -- the fallback is the point
	# FURTHEST FROM ANY EDGE, which is the centre of the largest circle the
	# region will hold. That is the pole of inaccessibility, and it is what
	# Mapbox's polylabel and QGIS both use for the same reason.
	#
	# Both are computed ON THE PAPER, not on the sphere, because the
	# question is whether a box of pixels fits inside a shape of pixels. The
	# old code searched in degrees and then asked a separate question in
	# pixels, so the two never quite agreed.
	#
	# The search is a coarse grid refined twice, over a SIMPLIFIED outline
	# of at most 200 points -- a department can carry two thousand and the
	# hundredth says nothing the ninety-ninth did not. It ranks candidates
	# rather than picking one, so a box that will not fit at the best point
	# can try the second and the third before giving up. Everything it
	# proposes is then checked EXACTLY, against the real outline, by
	# _BoxInRegion -- so simplifying here costs accuracy nowhere.
	def _AnchorsFor(pnI)
		_r_ = @aRingCache[pnI]
		_n_ = len(_r_) / 2
		if _n_ < 3  return []  ok
		_out_ = []

		# 1. THE CENTRE, first and by right -- the AREA centroid, taken from
		# the FULL outline and not the thinned one. Thinning is fine for
		# ranking the fallbacks; the centre is the point a reader checks by
		# eye, so it is computed exactly.
		_g_ = @aCentroidCache[pnI]
		if len(_g_) = 2 and _PaperPointIn(_r_, _g_[1], _g_[2])  _out_ + _g_  ok

		# 2. the interior points furthest from any edge, ranked
		_b_ = This.PaperBoxOf(pnI)
		_w_ = _b_[3] - _b_[1]
		_h_ = _b_[4] - _b_[2]
		if _w_ <= 0 or _h_ <= 0  return _out_  ok
		_cand_ = []
		_steps_ = 10
		for _a_ = 1 to _steps_ - 1
			for _c_ = 1 to _steps_ - 1
				_x_ = _b_[1] + _w_ * _a_ / _steps_
				_y_ = _b_[2] + _h_ * _c_ / _steps_
				if NOT _PaperPointIn(_r_, _x_, _y_)  loop  ok
				_cand_ + [ _PaperEdgeDist(_r_, _x_, _y_), _x_, _y_ ]
			next
		next
		if len(_cand_) = 0  return _out_  ok
		for _p_ = 1 to len(_cand_) - 1
			for _q_ = 1 to len(_cand_) - _p_
				if _cand_[_q_][1] < _cand_[_q_ + 1][1]
					_t_ = _cand_[_q_]
					_cand_[_q_] = _cand_[_q_ + 1]
					_cand_[_q_ + 1] = _t_
				ok
			next
		next

		# refine the best one twice, halving the step each round -- the
		# coarse grid finds the right neighbourhood and this finds the point
		_bx_ = _cand_[1][2]
		_by_ = _cand_[1][3]
		_bd_ = _cand_[1][1]
		_sw_ = _w_ / _steps_
		_sh_ = _h_ / _steps_
		for _pass_ = 1 to 2
			for _a_ = -2 to 2
				for _c_ = -2 to 2
					_x_ = _bx_ + _sw_ * _a_ / 2
					_y_ = _by_ + _sh_ * _c_ / 2
					if NOT _PaperPointIn(_r_, _x_, _y_)  loop  ok
					_d_ = _PaperEdgeDist(_r_, _x_, _y_)
					if _d_ > _bd_
						_bd_ = _d_
						_bx_ = _x_
						_by_ = _y_
					ok
				next
			next
			_sw_ = _sw_ / 2
			_sh_ = _sh_ / 2
		next
		_out_ + [ _bx_, _by_ ]
		# and the next few of the coarse ranking, so a box too wide for the
		# roundest part of the region can still try the long part
		_take_ = 6
		if len(_cand_) < _take_  _take_ = len(_cand_)  ok
		for _t_ = 1 to _take_
			_out_ + [ _cand_[_t_][2], _cand_[_t_][3] ]
		next
		return _out_

	# Returns the area centroid of feature pnI's largest part as drawn, in paper units.
	#
	#   pnI        the position of the feature, from 1
	#   returns    a list [ x, y ]; [ ] for a ring of fewer than 3 points
	#   note       The point a name goes at when it fits there
	#   see        LabelPointOf, PaperBoxOf
	#@ aka  THE CENTRE OF A REGION ON THE PAPER: the area centroid of its largest part's outline, projected. This is the point a name goes at when it fits there, and the point a reader checks the placement against.
	def PaperCentreOf(pnI)
		_k_ = @oF.LargestPartOf(pnI)
		_r_ = @oF.OuterRingOf(pnI, _k_)
		_n_ = len(_r_) / 2
		if _n_ < 3  return []  ok
		_p_ = []
		for _j_ = 1 to _n_
			_q_ = @oP.Project(_r_[_j_ * 2 - 1], _r_[_j_ * 2])
			if len(_q_) < 2  loop  ok
			_p_ + _q_[1]
			_p_ + _q_[2]
		next
		return _PaperCentroid(_p_)

	# the region's outline as drawn, thinned to at most 200 points
	def _SimplePaperRingOf(pnI)
		_k_ = @oF.LargestPartOf(pnI)
		_r_ = @oF.OuterRingOf(pnI, _k_)
		_n_ = len(_r_) / 2
		if _n_ < 3  return []  ok
		_keep_ = 200
		if _n_ < _keep_  _keep_ = _n_  ok
		_out_ = []
		for _t_ = 0 to _keep_ - 1
			_j_ = floor(_t_ * _n_ / _keep_) + 1
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

	# Writes the key, number to name, in as many columns as its box carries.
	#
	#   poCanvas   the stzCanvas to draw on
	#   poFont     the stzFont to write with
	#   pnSize     the type size, never below 13
	#   pInk       the text colour
	#   returns    nothing; the text is added to the canvas, and LabelReport counts the entries that
	#              did not fit
	#   note       Does nothing without SetKeyBox, and a number on the map with no key is an error
	#              in Findings
	#   see        SetKeyBox, KeyEntries
	#@ aka  THE KEY, in as many columns as its box will carry. A key that runs off the bottom of its box is a key that lost entries silently, so the column width comes from the widest entry ACTUALLY PRESENT and the row count from the box's own height.
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

	# Returns the readable text colour for the class colour under feature pnI, from the colour system's contrast rule.
	#
	#   pnI        the position of the feature, from 1
	#   pInk       the ink to use when no class colour decides
	#   pnSize     the type size in pixels the ink must be readable at
	#   returns    the colour as hex text; pInk itself when there are no classes or values
	#   note       #FFFFFF over a dark class, #000000 over a pale one
	#   see        DrawLabelsOn
	# --- 3. THE INK IS THE COLOUR SYSTEM'S ANSWER, NOT THIS FILE'S --------
	#@ aka  This used to ask StzIsDarkColor and choose white or the caller's ink, and it put black names on dark blue and dark red -- which the Principal returned twice. The house HAS a contrast contract: StzReadableTextOn(background, sizePx, bold) answers the ink AND whether that size can carry it, measured against WCAG's 4.5:1 for normal text and 3:1 for large. A drawing file has no business having its own 
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

	# Returns the box of feature pnI's largest part on the paper.
	#
	#   pnI        the position of the feature, from 1
	#   returns    a list [ x0, y0, x1, y1 ] in paper units; [ 0, 0, 0, 0 ] when nothing projects
	#   note       Niamey on the Niger sheet is 9 by 8 pixels
	#   see        PaperCentreOf, IsOnPaper
	#@ aka  a region's box ON THE PAPER: what the reader's eye measures a name against, which is not the box it has on the sphere
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

	# Sets the colour of the insets' frames and locator rectangles.
	#
	#   pInk       the colour
	#   returns    nothing; the colour is stored
	#   note       The default is #5A6B7C
	#   see        SetInsetPaper, AddInset
	#@ aka  -- insets ---------------------------------------------------------------
	def SetInsetInk(pInk)
		@cInsetInk = pInk

		def SetInsetInkQ(pInk)
			This.SetInsetInk(pInk)
			return This

	# Sets the fill of the insets' background.
	#
	#   pFill      the colour
	#   returns    nothing; the colour is stored
	#   note       The default is white
	#   see        SetInsetInk
	def SetInsetPaper(pFill)
		@cInsetPaper = pFill

		def SetInsetPaperQ(pFill)
			This.SetInsetPaper(pFill)
			return This

	# Adds an inset: a window of ground to magnify and the box on the canvas where it goes.
	#
	#   paWindow   the ground as [ lon0, lat0, lon1, lat1 ], given in either order
	#   paBox      the box on the canvas as [ x0, y0, x1, y1 ]
	#   returns    nothing; the inset is stored
	#   note       Raises an error unless both are lists of four. The inset takes a copy of the
	#              parent's projection refitted, so the shapes stay the same
	#   see        Insets, DrawInsetsOn
	#@ aka  paWindow is the ground to magnify, [ lon0, lat0, lon1, lat1 ]; paBox is where it goes on the canvas, [ x0, y0, x1, y1 ].
	def AddInset(paWindow, paBox)
		This.AddInsetXT(paWindow, paBox, "")

		def AddInsetQ(paWindow, paBox)
			This.AddInset(paWindow, paBox)
			return This

	def AddInsetXT(paWindow, paBox, pcTitle)
		if NOT (isList(paWindow) and len(paWindow) = 4)
			stzraise("stzGeoMap.AddInset: the window is [ lon0, lat0, lon1, lat1 ].")
		ok
		if NOT (isList(paBox) and len(paBox) = 4)
			stzraise("stzGeoMap.AddInset: the box on the canvas is [ x0, y0, x1, y1 ].")
		ok
		_w_ = paWindow
		if _w_[1] > _w_[3]  _t_ = _w_[1]  _w_[1] = _w_[3]  _w_[3] = _t_  ok
		if _w_[2] > _w_[4]  _t_ = _w_[2]  _w_[2] = _w_[4]  _w_[4] = _t_  ok
		@aInsets + [ :window = _w_, :box = paBox, :title = "" + pcTitle,
		             :idx = [], :count = 0, :scale = 0, :named = 0, :dropped = 0 ]

		def AddInsetXTQ(paWindow, paBox, pcTitle)
			This.AddInsetXT(paWindow, paBox, pcTitle)
			return This

	# Returns the insets with what resolving them found.
	#
	#   returns    a list of hash lists [ :window, :box, :title, :idx, :count, :scale, :named,
	#              :dropped ]
	#   see        AddInset, InsetReports
	def Insets()
		return @aInsets

	# WHICH REGIONS EACH INSET HAS TAKEN, resolved ONCE and read by everyone.
	#
	# ONE DEFINITION OF "INSIDE THIS WINDOW", AND ONLY ONE. The first version
	# had two: the parent asked whether a region's LABEL POINT fell in the
	# window, and the inset drew whatever IndicesWithin returned, which tests
	# the centre of the bounding BOX. Those are different points, so a region
	# could be skipped by the parent as "the inset has it" and then not drawn
	# by the inset -- a name lost between two pieces of code that each
	# believed the other had it.
	#
	# That is the same shape as the two definitions of "centre" that put five
	# names off their regions on an earlier sheet. The cure is not to make
	# the two tests agree; it is to have ONE test, and let the other caller
	# read its answer.
	def _ResolveInsets()
		for _k_ = 1 to len(@aInsets)
			_w_ = @aInsets[_k_][:window]
			@aInsets[_k_][:idx] = @oF.IndicesWithin(_w_[1], _w_[2], _w_[3], _w_[4])
			@aInsets[_k_][:count] = len(@aInsets[_k_][:idx])
		next

	# Returns the first inset that has taken feature pnI.
	#
	#   pnI        the position of the feature, from 1
	#   returns    a number from 1, or 0 when none has it
	#   note       Resolved when the labelling or DrawInsetsOn runs: 0 before
	#   see        Insets, DrawLabelsOn
	#@ aka  the FIRST inset holding it, and not the nearest: two insets over the same ground is a mistake the caller should see, not a tie to break here
	def InsetHolding(pnI)
		for _k_ = 1 to len(@aInsets)
			_x_ = @aInsets[_k_][:idx]
			for _t_ = 1 to len(_x_)
				if _x_[_t_] = pnI  return _k_  ok
			next
		next
		return 0

	# Returns what each inset drew: its title, the regions it took, its scale and how many it named or dropped.
	#
	#   returns    a list of hash lists [ :title, :count, :scale, :named, :dropped ]
	#   note       The scale is measured from the two projections: 15.3 for Niamey on the Niger
	#              sheet
	#   see        Insets, Findings
	def InsetReports()
		_a_ = []
		for _k_ = 1 to len(@aInsets)
			_a_ + [ :title = @aInsets[_k_][:title], :count = @aInsets[_k_][:count],
			        :scale = @aInsets[_k_][:scale], :named = @aInsets[_k_][:named],
			        :dropped = @aInsets[_k_][:dropped] ]
		next
		return _a_

	# Draws every inset on a canvas: its locator rectangle on the parent, its enlarged map, its frame, its title and its scale.
	#
	#   poCanvas   the stzCanvas to draw on
	#   poFont     the stzFont to write with
	#   pnSize     the type size, never below 13
	#   pInk       the text colour
	#   returns    nothing; the pieces are added to the canvas, and InsetReports is filled
	#   warning    Defect: the inset copies values, edges and palette but not SetOpenTop, so a value
	#              above the last edge draws as no data inside the inset while the parent paints it
	#              in the top colour (Niamey on the Niger sheet).
	#   see        AddInset, InsetReports
	def DrawInsetsOn(poCanvas, poFont, pnSize, pInk)
		if len(@aInsets) = 0  return  ok
		@bInsetsDrawn = TRUE
		This._ResolveInsets()
		_sz_ = pnSize
		if _sz_ < This.LabelFloor()  _sz_ = This.LabelFloor()  ok
		_ink_ = @cInsetInk
		for _k_ = 1 to len(@aInsets)
			_w_ = @aInsets[_k_][:window]
			_b_ = @aInsets[_k_][:box]
			_idx_ = @aInsets[_k_][:idx]
			if len(_idx_) = 0  loop  ok
			_sub_ = @oF.Subset(_idx_)

			# --- the locator on the parent, before the inset covers it ---
			# each edge sampled, because a lon/lat rectangle is not a
			# rectangle once a conic has had it
			_loc_ = []
			_n_ = 8
			for _t_ = 0 to _n_
				_loc_ = This._LocPush(_loc_, _w_[1] + (_w_[3] - _w_[1]) * _t_ / _n_, _w_[2])
			next
			for _t_ = 0 to _n_
				_loc_ = This._LocPush(_loc_, _w_[3], _w_[2] + (_w_[4] - _w_[2]) * _t_ / _n_)
			next
			for _t_ = 0 to _n_
				_loc_ = This._LocPush(_loc_, _w_[3] - (_w_[3] - _w_[1]) * _t_ / _n_, _w_[4])
			next
			for _t_ = 0 to _n_
				_loc_ = This._LocPush(_loc_, _w_[1], _w_[4] - (_w_[4] - _w_[2]) * _t_ / _n_)
			next
			if len(_loc_) >= 6
				# A LOCATOR SMALLER THAN THE PEN THAT DRAWS IT IS NOT A
				# LOCATOR. Niamey is a capital district eight pixels across
				# on a sheet of Niger, and its true outline came out as a
				# smudge the reader could not find -- so the mark is grown
				# to a minimum, about its own centre, the way every atlas
				# gives a minimum size to a symbol that must be seen. It
				# then overstates the window slightly, which is the honest
				# trade: a mark that is a little too big is read, and a mark
				# that is exactly right and invisible is not.
				_loc_ = This._LocAtLeast(_loc_, 11)
				_loc_ + _loc_[1]
				_loc_ + _loc_[2]
				poCanvas.AddPolylineQ(_loc_).Stroke(_ink_, 1.4)
			ok

			# --- the inset's own map: the parent's projection, enlarged ---
			# Ring copies an object on assignment, which is usually the trap
			# and is here the mechanism: the copy keeps the parallels and
			# the rotation, and FitFeaturesIn touches only scale and
			# translation.
			_p_ = @oP
			_p_.FitFeaturesIn(_sub_, _b_[1] + 6, _b_[2] + 6, _b_[3] - 6, _b_[4] - 6, 4)
			@aInsets[_k_][:scale] = _p_.ScaleOf() / @oP.ScaleOf()

			poCanvas.AddRectQ(_b_[1], _b_[2], _b_[3] - _b_[1], _b_[4] - _b_[2]).
				FillQ(@cInsetPaper).Stroke("#00000000", 0)
			_m_ = StzGeoMap(_p_, _sub_)
			_v_ = []
			for _t_ = 1 to len(_idx_)
				if _idx_[_t_] <= len(@aValues)  _v_ + @aValues[_idx_[_t_]]  else  _v_ + ""  ok
			next
			if len(_v_) > 0  _m_.SetValues(_v_)  ok
			if len(@aEdges) > 1  _m_.SetClasses(@aEdges)  ok
			if len(@aPalette) > 0  _m_.SetPalette(@aPalette)  ok
			_m_.SetPaper(_b_[1], _b_[2], _b_[3], _b_[4])
			# AN INSET LABELS THE WAY ITS PARENT LABELS ITS UNITS. Where the
			# parent numbers with OFFICIAL CODES, so does the inset: 75, 92,
			# 93 and 94 are what a French reader calls those departments, so
			# writing "Seine-Saint-Denis" there instead would be a different
			# vocabulary on the same sheet -- and the code fits where the
			# name does not, which is the whole difficulty. Otherwise the
			# inset writes NAMES, because it exists so that names fit and a
			# SEQUENTIAL number inside one would need a second key; a sheet
			# with two keys has given up.
			if @cKeyCode != ""
				_m_.SetKeyCodes(@cKeyCode)
				_m_.SetLabelMode(:Numbers)
			else
				_m_.SetLabelMode(:Names)
			ok
			_m_.DrawRegionsOn(poCanvas, "#FFFFFF", 0.8)
			_m_.DrawLabelsOn(poCanvas, poFont, _sz_, pInk)
			_r_ = _m_.LabelReport()
			@aInsets[_k_][:named] = _r_[:named] + _r_[:numbered]
			@aInsets[_k_][:dropped] = _r_[:dropped]

			# --- the frame, and what the frame is of ---------------------
			poCanvas.AddPolylineQ([ _b_[1], _b_[2], _b_[3], _b_[2], _b_[3], _b_[4],
			                        _b_[1], _b_[4], _b_[1], _b_[2] ]).Stroke(_ink_, 1.4)
			if @aInsets[_k_][:title] != ""
				poCanvas.SetFontQ(poFont, _sz_).
					AddTextQ(@aInsets[_k_][:title], _b_[1], _b_[2] - 6).Fill(pInk)
			ok
			poCanvas.SetFontQ(poFont, _sz_).
				AddTextQ(This._InsetScaleText(@aInsets[_k_][:scale]),
					_b_[1], _b_[4] + _sz_ + 4).Fill(pInk)
		next
		poCanvas.Flush()

	def _LocAtLeast(paLoc, pnMin)
		_n_ = len(paLoc) / 2
		if _n_ < 2  return paLoc  ok
		_x0_ = paLoc[1]  _x1_ = paLoc[1]
		_y0_ = paLoc[2]  _y1_ = paLoc[2]
		for _t_ = 2 to _n_
			if paLoc[_t_ * 2 - 1] < _x0_  _x0_ = paLoc[_t_ * 2 - 1]  ok
			if paLoc[_t_ * 2 - 1] > _x1_  _x1_ = paLoc[_t_ * 2 - 1]  ok
			if paLoc[_t_ * 2] < _y0_  _y0_ = paLoc[_t_ * 2]  ok
			if paLoc[_t_ * 2] > _y1_  _y1_ = paLoc[_t_ * 2]  ok
		next
		if _x1_ - _x0_ >= pnMin and _y1_ - _y0_ >= pnMin  return paLoc  ok
		_cx_ = (_x0_ + _x1_) / 2
		_cy_ = (_y0_ + _y1_) / 2
		_h_ = pnMin / 2
		return [ _cx_ - _h_, _cy_ - _h_, _cx_ + _h_, _cy_ - _h_,
		         _cx_ + _h_, _cy_ + _h_, _cx_ - _h_, _cy_ + _h_ ]

	def _LocPush(paOut, pnLon, pnLat)
		_q_ = @oP.Project(pnLon, pnLat)
		if len(_q_) < 2  return paOut  ok
		_o_ = paOut
		_o_ + _q_[1]
		_o_ + _q_[2]
		return _o_

	# MEASURED FROM THE TWO PROJECTIONS, never taken from the caller. An
	# inset whose caption disagrees with its own geometry is worse than one
	# with no caption at all.
	def _InsetScaleText(pnRatio)
		if pnRatio <= 0  return "scale not measurable"  ok
		if pnRatio >= 10  return "x" + floor(pnRatio + 0.5) + " the main map"  ok
		return "x" + StzFactNumText(floor(pnRatio * 10 + 0.5) / 10) + " the main map"

	# Selects regions by name to be outlined heavily, replacing any earlier selection.
	#
	#   paNames    the regions' names
	#   returns    nothing; the selection is stored
	#   note       Outlines, never recolours
	#   see        Highlighted, DrawHighlightOn, HighlightClass
	#@ aka  -- THE SHEET A READER BELIEVES (GE2c) ----------------------------------
	def SetHighlight(paNames)
		@aHighlit = []
		for _i_ = 1 to len(paNames)
			_k_ = @oF.IndexOfName("" + paNames[_i_])
			if _k_ > 0  @aHighlit + _k_  ok
		next

		def SetHighlightQ(paNames)
			This.SetHighlight(paNames)
			return This

	# Selects every region of one class to be outlined, which is what clicking a legend swatch means.
	#
	#   pnClass    the class, from 1
	#   returns    nothing; the selection is stored
	#   note       The legend frames the same swatch. A class past the last selects nothing
	#   see        SetHighlight, DrawRampLegendOn
	#@ aka  SELECT A WHOLE CLASS, which is what clicking a legend swatch means: "show me everyone between 2 and 5 per cent". The class is outlined on the map AND framed in the legend, so the two read as one gesture.
	def HighlightClass(pnClass)
		@nHiClass = pnClass
		@aHighlit = []
		if pnClass < 1  return  ok
		for _i_ = 1 to @oF.Count()
			if This.ClassOf(_i_) = pnClass  @aHighlit + _i_  ok
		next

		def HighlightClassQ(pnClass)
			This.HighlightClass(pnClass)
			return This

	# Returns the positions of the selected regions.
	#
	#   returns    a list of numbers
	#   see        SetHighlight, HighlightClass
	def Highlighted()
		return @aHighlit

	# TRUE if feature pnI is selected.
	#
	#   pnI        the position of the feature, from 1
	#   returns    TRUE or FALSE
	#   see        Highlighted
	def IsHighlighted(pnI)
		for _i_ = 1 to len(@aHighlit)
			if @aHighlit[_i_] = pnI  return TRUE  ok
		next
		return FALSE

	# Makes DrawSheetOn put an id, a class and a tooltip title on every region in the SVG.
	#
	#   pbOn       1 to carry identity into the SVG
	#   returns    nothing; the flag is stored
	#   note       A script can then address a region; the browser shows the title with no script
	#   see        IsInteractive, IdentOf
	#@ aka  EVERY REGION CARRIES ITS OWN IDENTITY INTO THE SVG, which is what an interactive layer is made of: an id a script can address, a class a stylesheet can hover, and a <title> the browser shows as a tooltip with no script at all. The diagram plane has had this since DN3b; a map is the surface that wants it most, because a reader's first question of any choropleth is "which country is that and what is
	def SetInteractive(pbOn)
		@bIdentify = pbOn

		def SetInteractiveQ(pbOn)
			This.SetInteractive(pbOn)
			return This

	# TRUE if the map carries identity into the SVG.
	#
	#   returns    TRUE or FALSE
	#   see        SetInteractive
	def IsInteractive()
		return @bIdentify

	# Returns the id feature pnI takes in the SVG: "geo-" and its name in lowercase, anything but a letter or digit turned into one hyphen.
	#
	#   pnI        the position of the feature, from 1
	#   returns    text such as "geo-agadez"; "geo-region-" and the position for a name with no
	#              letter or digit
	#   note       Works on bytes: a multibyte letter becomes hyphens, so Cote d'Ivoire with a
	#              circumflex gives geo-c-te-d-ivoire
	#   see        SetInteractive
	#@ aka  the id a region takes in the SVG: its name, lowercased, with anything that is not a letter or a digit turned into a hyphen
	def IdentOf(pnI)
		# BYTES, DELIBERATELY, and the two are consistent: len() counts
		# bytes and [] indexes them. Only a-z and 0-9 survive, so a
		# multibyte letter splits into bytes that all become hyphens and
		# collapse to one -- "Cote d'Ivoire" and "Côte d'Ivoire" both give
		# a usable id. Mixing StzLen (codepoints) with [] (bytes) is the
		# documented trap and is not what this does.
		_c_ = StzLower("" + @oF.NameOf(pnI))
		_o_ = ""
		_n_ = len(_c_)
		# ASCII CODES, NOT CHARACTER COMPARISON. Ring raises R41 "invalid
		# numeric string" on `"a" >= "b"` -- it tries to read both sides as
		# numbers. stzGeoAtlas.StzGeoNormalizeName already learned this and
		# this method had to learn it again, which is the cost of two places
		# normalising a name.
		for _k_ = 1 to _n_
			_a_ = ascii(_c_[_k_])
			if (_a_ >= 97 and _a_ <= 122) or (_a_ >= 48 and _a_ <= 57)
				_o_ += _c_[_k_]
			but _o_ != "" and StzRight(_o_, 1) != "-"
				_o_ += "-"
			ok
		next
		if _o_ != "" and StzRight(_o_, 1) = "-"  _o_ = StzLeft(_o_, len(_o_) - 1)  ok
		if _o_ = ""  _o_ = "region-" + pnI  ok
		return "geo-" + _o_

	# Draws the regions as a statistical map does: dark hairline borders, the no-data hatch, then the heavy outline of the selection.
	#
	#   poCanvas     the stzCanvas to draw on
	#   pInk         the border colour
	#   pnHairline   the border width in pixels
	#   returns      nothing; the layers are added to the canvas
	#   note         Does not draw the sphere or the graticule. With SetInteractive each region
	#                carries its id
	#   warning      Defect: raises error R2 when values are set and the classes are not, because
	#                the class edges are an empty list read at index 0.
	#   see          DrawNoDataHatchOn, DrawHighlightOn, DrawLabelsOn
	#@ aka  THE REGIONS, DRAWN THE WAY A STATISTICAL MAP DRAWS THEM: dark hairline borders, the highlighted ones outlined heavily on top, and each one carrying its identity when the map is interactive.
	def DrawSheetOn(poCanvas, pInk, pnHairline)
		_nF_ = @oF.Count()
		for _i_ = 1 to _nF_
			if @bIdentify
				poCanvas.SetSvgIdent(This.IdentOf(_i_),
					"geo-region " + This._IdentClassOf(_i_))
			ok
			@oP.DrawFeatureOn(poCanvas, @oF, _i_, This.ColourOf(_i_), pInk, pnHairline)
		next
		if @bIdentify  poCanvas.ClearSvgIdent()  ok
		poCanvas.Flush()

		# THE HATCH IS PART OF DRAWING THE SHEET, not something a caller
		# remembers to add. The legend prints a no-data swatch whenever the
		# map has unclassed regions, so the map owes the reader the matching
		# mark -- and the first version of this sheet left it to the caller,
		# who did not know they had been given the job.
		#
		# It goes on AFTER every fill, because a country drawn later would
		# paint over a neighbour's hatching, and BEFORE the highlight, whose
		# outlines must sit on top of everything.
		This.DrawNoDataHatchOn(poCanvas, @cHatch, 0.8, 6)
		This.DrawHighlightOn(poCanvas, "#1A1A1A", 2.2)

	def _IdentClassOf(pnI)
		if len(@aGroups) > 0
			_g_ = This.GroupOf(pnI)
			if _g_ < 1  return "geo-nogroup"  ok
			return "geo-group-" + _g_
		ok
		_c_ = This.ClassOf(pnI)
		if _c_ < 1  return "geo-nodata"  ok
		return "geo-class-" + _c_

	# Draws the heavy outline of the selected regions over everything else, so a neighbour cannot cover it.
	#
	#   poCanvas   the stzCanvas to draw on
	#   pInk       the outline colour
	#   pnWidth    the outline width in pixels
	#   returns    nothing; the outlines are added to the canvas
	#   note       DrawSheetOn calls it with #1A1A1A and 2.2
	#   see        SetHighlight, DrawSheetOn
	#@ aka  the heavy outline, drawn OVER everything so a neighbour cannot cover it
	def DrawHighlightOn(poCanvas, pInk, pnWidth)
		if len(@aHighlit) = 0  return  ok
		for _h_ = 1 to len(@aHighlit)
			_i_ = @aHighlit[_h_]
			for _k_ = 1 to @oF.PartCount(_i_)
				for _r_ = 1 to len(@oF.RingsOf(_i_, _k_))
					@oP.DrawRingOutlineOn(poCanvas, @oF.RingsOf(_i_, _k_)[_r_], pInk, pnWidth)
				next
			next
		next
		poCanvas.Flush()

	# Hatches every region that has no value, at 45 degrees and clipped to its shape.
	#
	#   poCanvas    the stzCanvas to draw on
	#   pColour     the hatch colour
	#   pnWidth     the line width in pixels
	#   pnSpacing   the distance between lines in pixels
	#   returns     nothing; the lines are added to the canvas
	#   note        A shape too narrow for the spacing still gets one mark. Does nothing on a map
	#               with no values and no groups
	#   see         IsUnclassed, SetHatch
	#@ aka  NO DATA IS HATCHED, NOT COLOURED, and it is hatched ON THE MAP.
	def DrawNoDataHatchOn(poCanvas, pColour, pnWidth, pnSpacing)
		_n_ = @oF.Count()
		for _i_ = 1 to _n_
			if NOT This.IsUnclassed(_i_)  loop  ok
			if @bIdentify
				poCanvas.SetSvgIdent(This.IdentOf(_i_) + "-hatch", "geo-nodata-hatch")
			ok
			for _k_ = 1 to @oF.PartCount(_i_)
				_pcs_ = @oP.FilledPolygon(@oF.RingsOf(_i_, _k_))
				for _p_ = 1 to len(_pcs_)
					_HatchPolygon(poCanvas, _pcs_[_p_], pnSpacing, pColour, pnWidth)
				next
			next
		next
		if @bIdentify  poCanvas.ClearSvgIdent()  ok
		poCanvas.Flush()

	# TRUE if feature pnI has no value, or in a grouped map belongs to no group.
	#
	#   pnI        the position of the feature, from 1
	#   returns    TRUE or FALSE
	#   note       A value outside the classes is not unclassed: it is data badly classed. A map
	#              with no values and no groups has none
	#   see        NoDataCount, HasThematicLayer
	#@ aka  NO DATA MEANS NO VALUE, and it does not mean "a value my scale has no box for". A country measured at 35 on a scale topping out at 30 is data -- badly classed data, which is the cartographer's problem and not the country's -- and hatching it would tell the reader nobody counted it. So this asks for the VALUE where the map is numeric, and for membership where the map is categorical, since a map can
	def IsUnclassed(pnI)
		# A MAP WITH NO THEMATIC LAYER HAS NO NO-DATA. "Not measured" is a
		# statement about a measurement that was supposed to exist, so it
		# needs something to be missing FROM: where a caller set no values
		# and no groups, the picture is a base map and every region is
		# simply a region.
		#
		# Without this line the hatch fired on all 177 countries of the
		# GE8 witness, which sets no values at all -- the whole world came
		# out cross-hatched, and it was hard to read as anything but a
		# rendering fault. That is the cost of asking "has this one got a
		# value" without first asking "is anybody being valued here".
		if NOT This.HasThematicLayer()  return FALSE  ok
		if len(@aGroups) > 0  return This.GroupOf(pnI) = 0  ok
		return NOT isNumber(This.ValueOf(pnI))

	# TRUE if the map is about something: values or groups were set.
	#
	#   returns    TRUE or FALSE
	#   see        IsUnclassed
	#@ aka  is this map ABOUT something, or is it the ground under one?
	def HasThematicLayer()
		return len(@aGroups) > 0 or len(@aValues) > 0

	# Returns how many features have no value or no group.
	#
	#   returns    a number
	#   see        IsUnclassed, DrawRampLegendOn
	def NoDataCount()
		_n_ = 0
		for _i_ = 1 to @oF.Count()
			if This.IsUnclassed(_i_)  _n_++  ok
		next
		return _n_

	# Writes one text inside feature pnI with a halo, only if the whole text fits inside the region.
	#
	#   poCanvas   the stzCanvas to draw on
	#   poFont     the stzFont to write with
	#   pnSize     the type size in pixels
	#   pnI        the position of the feature, from 1
	#   pcText     the text to write
	#   pInk       the text colour
	#   pHalo      the halo colour
	#   pnR        the halo radius in pixels
	#   returns    TRUE if drawn, FALSE when nothing was drawn because it does not fit or pnI is out
	#              of range
	#   note       A label that would land on a neighbour is worse than none
	#   see        DrawHaloTextOn, DrawLabelsOn
	#@ aka  A NAME WITH A HALO, because a label on a choropleth has no single background to contrast with: the same word crosses a pale class and a dark one. The halo is the ink's opposite, drawn as eight offset copies under the text -- which is what every map library does and what the colour system cannot answer, since its question is "this ink on THAT background" and here there is no one background. ONE REG
	def DrawNamedLabelOn(poCanvas, poFont, pnSize, pnI, pcText, pInk, pHalo, pnR)
		if pnI < 1 or pnI > @oF.Count()  return FALSE  ok
		This._EnsureLabelCaches()
		_t_ = "" + pcText
		_w_ = poFont.WidthOf(_t_, pnSize)
		_bx_ = This._FitInside(_w_, pnSize, pnI, [])
		if len(_bx_) != 4  return FALSE  ok
		# the baseline at eight tenths of the box, so the descenders stay
		# inside the box _BoxInRegion just certified
		This.DrawHaloTextOn(poCanvas, poFont, pnSize, _t_,
			_bx_[1], _bx_[2] + pnSize * 0.8, pInk, pHalo, pnR)
		return TRUE

	# the projected outlines and centres every anchor search reads. Built
	# ONCE -- projecting a region's two thousand points per candidate is a
	# shape of cost this file has paid before -- and built in ONE place, so
	# a caller who wants a single label does not have to know the label
	# engine's setup in order to get the label engine's placement.
	def _EnsureLabelCaches()
		if len(@aRingCache) = @oF.Count() and len(@aCentroidCache) = @oF.Count()
			return
		ok
		This._BuildLandGrid()
		@aRingCache = []
		@aCentroidCache = []
		for _i_ = 1 to @oF.Count()
			@aRingCache + This._SimplePaperRingOf(_i_)
			@aCentroidCache + This.PaperCentreOf(_i_)
		next

	# Writes text with a halo of eight offset copies underneath, readable on every shade of a ramp.
	#
	#   poCanvas   the stzCanvas to draw on
	#   poFont     the stzFont to write with
	#   pnSize     the type size in pixels
	#   pcText     the text to write
	#   pnX        left edge of the text
	#   pnY        baseline of the text
	#   pInk       the text colour
	#   pHalo      the halo colour
	#   pnR        the halo radius in pixels
	#   returns    nothing; the text is added to the canvas
	#   see        DrawNamedLabelOn
	def DrawHaloTextOn(poCanvas, poFont, pnSize, pcText, pnX, pnY, pInk, pHalo, pnR)
		_off_ = [ [ -1, 0 ], [ 1, 0 ], [ 0, -1 ], [ 0, 1 ],
		          [ -0.7, -0.7 ], [ 0.7, -0.7 ], [ -0.7, 0.7 ], [ 0.7, 0.7 ] ]
		for _k_ = 1 to len(_off_)
			poCanvas.SetFontQ(poFont, pnSize).
				AddTextQ(pcText, pnX + _off_[_k_][1] * pnR, pnY + _off_[_k_][2] * pnR).Fill(pHalo)
		next
		poCanvas.SetFontQ(poFont, pnSize).AddTextQ(pcText, pnX, pnY).Fill(pInk)
		poCanvas.Flush()

	# Draws the ramp legend: one bar of classes butted together, the edges written at the joins, a hatched no-data swatch when needed.
	#
	#   poCanvas   the stzCanvas to draw on
	#   poFont     the stzFont to write with
	#   pnSize     the type size, at least 11
	#   pnX        left edge of the legend
	#   pnY        top edge of the bar
	#   pnW        width of the bar of classes
	#   pnH        height of the bar
	#   pInk       the text and frame colour
	#   returns    the y below the legend; pnY when no classes are set
	#   note       The top class is an arrow when SetOpenTop was called. The no-data swatch appears
	#              only when NoDataCount is above 0
	#   see        DrawLegendOn, SetOpenTop, HighlightClass
	#@ aka  THE RAMP LEGEND: one bar, the classes butted together, the numbers at the JOINS, and a hatched no-data swatch to its left. Returns where it ended, so a caller can stack a caption under it.
	def DrawRampLegendOn(poCanvas, poFont, pnSize, pnX, pnY, pnW, pnH, pInk)
		if len(@aEdges) < 2  return pnY  ok
		_n_ = len(@aEdges) - 1
		_sz_ = pnSize
		if _sz_ < 11  _sz_ = 11  ok

		# THE NO-DATA SWATCH, DRAWN ONLY WHEN THERE IS NO DATA TO STAND FOR.
		#
		# A legend must not advertise a category the map does not use: on a
		# sheet where every region carries a value, a hatched "No data"
		# swatch is the same lie as a class that colours nothing, and the
		# gate already forbids the second. The legend knows -- it can ask
		# NoDataCount() -- so it omits the swatch when the answer is zero and
		# starts the ramp at the left margin instead.
		#
		# Hatched with the same clipper the map uses, so the legend's mark
		# and the country's are one thing; a POLYGON handed to _HatchPolygon
		# rather than free diagonals, which the first version ran out of the
		# box on both sides.
		_nd_ = 0
		if This.NoDataCount() > 0
			_nd_ = 46
			poCanvas.SetFontQ(poFont, _sz_).
				AddTextQ("No data", pnX, pnY - 6).Fill("#777777")
			poCanvas.Flush()
			poCanvas.AddRectQ(pnX, pnY, _nd_, pnH).FillQ("#FFFFFF").Stroke("#00000000", 0)
			_box_ = [ pnX, pnY, pnX + _nd_, pnY, pnX + _nd_, pnY + pnH, pnX, pnY + pnH ]
			_HatchPolygon(poCanvas, _box_, 6, @cHatch, 0.9)
			poCanvas.AddRectQ(pnX, pnY, _nd_, pnH).FillQ("#00000000").Stroke(pInk, 0.9)
			poCanvas.Flush()
		ok

		_x0_ = pnX + _nd_
		if _nd_ > 0  _x0_ += 16  ok
		_cw_ = pnW / _n_
		for _c_ = 1 to _n_
			_x_ = _x0_ + (_c_ - 1) * _cw_
			if @bIdentify
				poCanvas.SetSvgIdent("geo-legend-class-" + _c_, "geo-legend-swatch")
			ok
			if _c_ = _n_ and @bOpenTop
				# the open top: a box with a point on it
				poCanvas.AddPolygonQ([ _x_, pnY, _x_ + _cw_ * 0.55, pnY,
				                       _x_ + _cw_, pnY + pnH / 2,
				                       _x_ + _cw_ * 0.55, pnY + pnH, _x_, pnY + pnH ]).
					FillQ(@aPalette[_c_]).Stroke(pInk, 0.9)
			else
				poCanvas.AddRectQ(_x_, pnY, _cw_, pnH).FillQ(@aPalette[_c_]).Stroke(pInk, 0.9)
			ok
		next
		if @bIdentify  poCanvas.ClearSvgIdent()  ok

		# THE SELECTED CLASS, FRAMED IN THE LEGEND. The map and the legend
		# must show one gesture, or the reader has to work out that the
		# heavy outlines and the framed swatch mean the same thing.
		if @nHiClass >= 1 and @nHiClass <= _n_
			_x_ = _x0_ + (@nHiClass - 1) * _cw_
			poCanvas.AddRectQ(_x_ - 1, pnY - 1, _cw_ + 2, pnH + 2).
				FillQ("#00000000").Stroke("#1A1A1A", 2.2)
		ok
		poCanvas.Flush()

		# the numbers at the joins, every edge including both ends
		for _c_ = 0 to _n_
			_t_ = StzFactNumText(@aEdges[_c_ + 1])
			_w_ = poFont.WidthOf(_t_, _sz_)
			poCanvas.SetFontQ(poFont, _sz_).
				AddTextQ(_t_, _x0_ + _c_ * _cw_ - _w_ / 2, pnY - 6).Fill("#555555")
		next
		poCanvas.Flush()
		return pnY + pnH + _sz_ + 8

	# Draws a scale bar at a stated latitude and prints that latitude; draws nothing when the scale varies too much over the sheet.
	#
	#   poCanvas     the stzCanvas to draw on
	#   poFont       the stzFont to write with
	#   pnSize       the type size in pixels
	#   pnX          left edge of the bar
	#   pnY          top edge of the bar
	#   pnTargetPx   the wished width of the bar in pixels, rounded to a round number of km
	#   pnAtLat      the latitude the bar is true at, in degrees north
	#   pInk         the colour
	#   returns      the y the bar ended at, or 0 when nothing was drawn
	#   note         Refuses when the largest scale over the smallest exceeds 1.25
	#   warning      Defect: without SetPaper the sheet is guessed from the projection's scale as
	#                plus and minus pi times it, so a country map measures a scale variation of
	#                57.85 instead of 1.009 and the bar is refused.
	#   see          ScaleBarAt, ScaleVariation
	#@ aka  -- GE10: THE FURNITURE, and the two plots a field still owed ----------
	def DrawScaleBarOn(poCanvas, poFont, pnSize, pnX, pnY, pnTargetPx, pnAtLat, pInk)
		return This.DrawScaleBarOnXT(poCanvas, poFont, pnSize, pnX, pnY,
			pnTargetPx, pnAtLat, pInk, 1.25)

	def DrawScaleBarOnXT(poCanvas, poFont, pnSize, pnX, pnY, pnTargetPx, pnAtLat, pInk, pnTolerance)
		_b_ = This._ScaleBarRaw(pnTargetPx, pnAtLat)
		if len(_b_) < 4  return 0  ok
		if _b_[1] <= 0 or _b_[2] <= 0  return 0  ok
		# THE REFUSAL IS THE POINT. A caller who ignores the variation draws
		# the lie; a face that draws it anyway makes the caller complicit
		# without telling them.
		if _b_[4] > pnTolerance  return 0  ok

		_h_ = pnSize * 0.55
		# the bar in two halves, light and dark, which is how an atlas draws
		# one: a reader measures the half as easily as the whole
		_half_ = _b_[2] / 2
		poCanvas.AddRectQ(pnX, pnY, _half_, _h_).FillQ("#FFFFFF").Stroke(pInk, 0.9)
		poCanvas.AddRectQ(pnX + _half_, pnY, _half_, _h_).FillQ(pInk).Stroke(pInk, 0.9)
		poCanvas.Flush()
		poCanvas.SetFontQ(poFont, pnSize).AddTextQ("0", pnX - 3, pnY - 4).Fill(pInk)
		poCanvas.Flush()
		_c_ = StzFactNumText(_b_[1] / 2)
		poCanvas.SetFontQ(poFont, pnSize).AddTextQ(_c_, pnX + _half_ - 8, pnY - 4).Fill(pInk)
		poCanvas.Flush()
		_c2_ = StzFactNumText(_b_[1]) + " km"
		poCanvas.SetFontQ(poFont, pnSize).AddTextQ(_c2_, pnX + _b_[2] - 12, pnY - 4).Fill(pInk)
		poCanvas.Flush()
		# ...AND THE LATITUDE IT IS TRUE AT, which is the whole difference
		# between a scale bar and a scale bar somebody can rely on
		_at_ = "true at " + StzFactNumText(fabs(pnAtLat)) + " degrees"
		if pnAtLat > 0  _at_ += " north"  ok
		if pnAtLat < 0  _at_ += " south"  ok
		poCanvas.SetFontQ(poFont, pnSize - 2).
			AddTextQ(_at_, pnX, pnY + _h_ + pnSize).Fill("#888888")
		poCanvas.Flush()
		return pnY + _h_ + pnSize + 6

	# Returns the ratio of the largest local scale to the smallest over the sheet: 1 means a scale bar is true everywhere.
	#
	#   returns    a number from 1: 1.009 for Niger on its conic with SetPaper
	#   note       A world Mercator measures 7.9 million, because the poles are in the sheet
	#   warning    Defect: without SetPaper the sheet is guessed from the projection's scale as plus
	#              and minus pi times it, so a country map measures a scale variation of 57.85
	#              instead of 1.009 and the bar is refused.
	#   see        ScaleBarAt, DrawScaleBarOn
	#@ aka  WOULD A SCALE BAR BE HONEST ON THIS MAP? The ratio of the largest local scale on the sheet to the smallest. 1 means a bar is true everywhere; anything much above it means the bar is decoration.
	def ScaleVariation()
		_b_ = This._ScaleBarRaw(100, 0)
		if len(_b_) < 4  return 1  ok
		return _b_[4]

	# Returns the scale bar that would be drawn, without drawing it.
	#
	#   pnTargetPx   the wished width of the bar in pixels
	#   pnAtLat      the latitude the bar is true at, in degrees north
	#   returns      a hash list [ :km, :pixels, :atLat, :variation ]: the round length in km, its
	#                length in pixels, the latitude and the variation
	#   note         Niger on its conic with SetPaper: 200 km is 57.6 pixels at 15 N
	#   warning      Defect: without SetPaper the sheet is guessed from the projection's scale as
	#                plus and minus pi times it, so a country map measures a scale variation of
	#                57.85 instead of 1.009 and the bar is refused.
	#   see          DrawScaleBarOn
	def ScaleBarAt(pnTargetPx, pnAtLat)
		_b_ = This._ScaleBarRaw(pnTargetPx, pnAtLat)
		if len(_b_) < 4  return []  ok
		return [ :km = _b_[1], :pixels = _b_[2], :atLat = _b_[3], :variation = _b_[4] ]

	# THE SHEET IS WHAT THE VARIATION IS MEASURED OVER, so the paper
	# rectangle has to reach the engine. SetPaper gives it where a caller
	# set one; otherwise it is taken from the projection's own fit, which
	# is the box the fit was asked to fill.
	def _ScaleBarRaw(pnTargetPx, pnAtLat)
		_p_ = @aPaper
		if len(_p_) != 4  _p_ = This._FitBox()  ok
		return StzEngineGeoScaleBar(@oP.Params(), pnTargetPx, pnAtLat, 0,
			_p_[1], _p_[2], _p_[3], _p_[4])

	# the box the projection was fitted into, recovered from its own
	# translation and scale -- a projection remembers where it was put even
	# when nobody called SetPaper
	def _FitBox()
		_t_ = @oP.TranslateOf()
		_s_ = @oP.ScaleOf()
		if len(_t_) < 2 or _s_ <= 0  return [ 0, 0, 1, 1 ]  ok
		# a sphere of unit radius spans -pi..pi in x and -pi/2..pi/2 in y
		# before the fit, so the fitted sheet is at most this wide
		_w_ = 3.141592653589793 * _s_
		_h_ = 1.570796326794897 * _s_
		return [ _t_[1] - _w_, _t_[2] - _h_, _t_[1] + _w_, _t_[2] + _h_ ]

	# Draws an arrow pointing where north really goes at a place, measured by projecting a step north.
	#
	#   poCanvas   the stzCanvas to draw on
	#   poFont     the stzFont to write with
	#   pnSize     the type size in pixels
	#   pnX        x of the arrow's foot
	#   pnY        y of the arrow's foot
	#   pnLen      length of the arrow in pixels
	#   pnAtLon    longitude of the place whose north is drawn, in degrees east
	#   pnAtLat    latitude of that place, in degrees north
	#   pInk       the colour
	#   returns    1 when drawn, 0 when the place has no image
	#   note       North is not always up: on a rotated or conic map the arrow tilts
	#   see        DrawScaleBarOn
	#@ aka  NORTH, WHICH IS NOT ALWAYS UP. On most world projections it is, and the arrow is then decoration; on a rotated or oblique one it is not, and a reader has no other way to know. So the arrow is MEASURED -- project a short step due north from the given place and draw where it actually went -- rather than drawn pointing up and hoped over.
	def DrawNorthArrowOn(poCanvas, poFont, pnSize, pnX, pnY, pnLen, pnAtLon, pnAtLat, pInk)
		_a_ = @oP.Project(pnAtLon, pnAtLat)
		_b_ = @oP.Project(pnAtLon, pnAtLat + 0.5)
		if len(_a_) < 2 or len(_b_) < 2  return 0  ok
		_dx_ = _b_[1] - _a_[1]
		_dy_ = _b_[2] - _a_[2]
		_m_ = sqrt(_dx_ * _dx_ + _dy_ * _dy_)
		if _m_ < 0.000001  return 0  ok
		_dx_ /= _m_
		_dy_ /= _m_
		_tx_ = pnX + _dx_ * pnLen
		_ty_ = pnY + _dy_ * pnLen
		# the head, as two barbs off the shaft
		_px_ = -_dy_
		_py_ = _dx_
		poCanvas.AddPolygonQ([ _tx_, _ty_,
			_tx_ - _dx_ * pnLen * 0.3 + _px_ * pnLen * 0.15,
			_ty_ - _dy_ * pnLen * 0.3 + _py_ * pnLen * 0.15,
			_tx_ - _dx_ * pnLen * 0.3 - _px_ * pnLen * 0.15,
			_ty_ - _dy_ * pnLen * 0.3 - _py_ * pnLen * 0.15 ]).FillQ(pInk).Stroke(pInk, 1)
		poCanvas.AddLineQ(pnX, pnY, _tx_, _ty_).Stroke(pInk, 1.6)
		poCanvas.Flush()
		poCanvas.SetFontQ(poFont, pnSize).
			AddTextQ("N", _tx_ + _dx_ * 10 - 4, _ty_ + _dy_ * 10 + 4).Fill(pInk)
		poCanvas.Flush()
		return 1

	# Returns where the sun is overhead at a moment, with the equation of time.
	#
	#   pnYear      the year
	#   pnMonth     the month from 1
	#   pnDay       the day of the month
	#   pnHourUtc   the hour in UTC, with decimals
	#   returns     a hash list [ :lat, :lon, :declination, :equationOfTime ]; degrees and minutes;
	#               on 2026-10-05 at 12 UTC the latitude is -4.85 and the longitude -2.90
	#   note        The latitude is the solar declination, which is the seasons
	#   see         TerminatorAt, SolarElevationAt
	#@ aka  -- day and night -------------------------------------------------------
	def SunAt(pnYear, pnMonth, pnDay, pnHourUtc)
		_jd_ = StzEngineGeoJulianDay(pnYear, pnMonth, pnDay, pnHourUtc)
		_s_ = StzEngineGeoSunAt(_jd_)
		if len(_s_) < 4  return []  ok
		return [ :lat = _s_[1], :lon = _s_[2], :declination = _s_[3],
		         :equationOfTime = _s_[4] ]

	# Returns the line between day and night, every place 90 degrees from the sun's overhead point.
	#
	#   pnYear      the year
	#   pnMonth     the month from 1
	#   pnDay       the day of the month
	#   pnHourUtc   the hour in UTC
	#   returns     a flat list lon, lat, lon, lat, ... of 181 places
	#   note        The same as TwilightAt with 90
	#   see         TwilightAt, DrawTerminatorOn
	#@ aka  THE LINE BETWEEN DAY AND NIGHT, as lon/lat: every place ninety degrees from the subsolar point, which is where the sun is exactly on the horizon.
	def TerminatorAt(pnYear, pnMonth, pnDay, pnHourUtc)
		return This.TwilightAt(pnYear, pnMonth, pnDay, pnHourUtc, 90)

	# Returns the circle of places where the sun is a stated angle below the horizon.
	#
	#   pnYear       the year
	#   pnMonth      the month from 1
	#   pnDay        the day of the month
	#   pnHourUtc    the hour in UTC
	#   pnAngleDeg   the angle from the sun's overhead point: 90 horizon, 96 civil twilight, 102
	#                nautical, 108 astronomical
	#   returns      a flat list lon, lat, lon, lat, ... of 181 places
	#   see          TerminatorAt, DrawTwilightOn
	#@ aka  ...AND TWILIGHT IS THE SAME CIRCLE, FURTHER OUT: civil twilight ends with the sun 6 degrees below the horizon, nautical at 12 and astronomical at 18 -- so they are the circles at 96, 102 and 108. One routine draws all four because they are one thing.
	def TwilightAt(pnYear, pnMonth, pnDay, pnHourUtc, pnAngleDeg)
		_s_ = This.SunAt(pnYear, pnMonth, pnDay, pnHourUtc)
		if len(_s_) = 0  return []  ok
		return StzEngineGeoTerminator(_s_[:lat], _s_[:lon], pnAngleDeg, 181)

	# Returns how high the sun is above the horizon at a place, in degrees; negative is night.
	#
	#   pnYear      the year
	#   pnMonth     the month from 1
	#   pnDay       the day of the month
	#   pnHourUtc   the hour in UTC
	#   pnLon       longitude of the place in degrees east
	#   pnLat       latitude of the place in degrees north
	#   returns     a number from -90 to 90, 79.95 at Niamey at 12 UTC on 2026-06-21
	#   note        LONGITUDE FIRST
	#   see         IsDaylightAt, SunAt
	#@ aka  HOW HIGH THE SUN IS at a place, degrees -- negative is night. It is the terminator asked as a question rather than drawn as a line, and is what SHADES a map rather than outlining it.
	def SolarElevationAt(pnYear, pnMonth, pnDay, pnHourUtc, pnLon, pnLat)
		_s_ = This.SunAt(pnYear, pnMonth, pnDay, pnHourUtc)
		if len(_s_) = 0  return 0  ok
		return StzEngineGeoSolarElevation(_s_[:lat], _s_[:lon], pnLon, pnLat)

	# TRUE if the sun is above the horizon at a place.
	#
	#   pnYear      the year
	#   pnMonth     the month from 1
	#   pnDay       the day of the month
	#   pnHourUtc   the hour in UTC
	#   pnLon       longitude of the place in degrees east
	#   pnLat       latitude of the place in degrees north
	#   returns     TRUE or FALSE
	#   note        LONGITUDE FIRST. Niamey at 12 UTC is day and at 0 UTC night
	#   see         SolarElevationAt
	def IsDaylightAt(pnYear, pnMonth, pnDay, pnHourUtc, pnLon, pnLat)
		return This.SolarElevationAt(pnYear, pnMonth, pnDay, pnHourUtc, pnLon, pnLat) > 0

	# Draws the line between day and night on a canvas.
	#
	#   poCanvas    the stzCanvas to draw on
	#   pnYear      the year
	#   pnMonth     the month from 1
	#   pnDay       the day of the month
	#   pnHourUtc   the hour in UTC
	#   pInk        the line colour
	#   pnWidth     the line width in pixels
	#   returns     1 when drawn, 0 when nothing was
	#   see         TerminatorAt, DrawNightOn
	#@ aka  THE NIGHT SIDE, drawn. The terminator is a great circle, so on most projections it is a curve that leaves the sheet at one edge and comes back at the other -- which is why it is drawn as a LINE over a shading rather than as a filled polygon: a polygon would have to decide what "inside" means on a projection that cuts it, and would get it wrong at exactly the two solstices.
	def DrawTerminatorOn(poCanvas, pnYear, pnMonth, pnDay, pnHourUtc, pInk, pnWidth)
		_a_ = This.TerminatorAt(pnYear, pnMonth, pnDay, pnHourUtc)
		if len(_a_) < 6  return 0  ok
		@oP.DrawLineOn(poCanvas, _a_, pInk, pnWidth)
		poCanvas.Flush()
		return 1

	# Fills the night side on a canvas with four nested translucent caps, so full dark is reached gradually.
	#
	#   poCanvas    the stzCanvas to draw on
	#   pnYear      the year
	#   pnMonth     the month from 1
	#   pnDay       the day of the month
	#   pnHourUtc   the hour in UTC
	#   pInk        the colour of one cap, translucent
	#   returns     the number of caps drawn, 4
	#   note        The caps are 0, 6, 12 and 18 degrees past the horizon; the alpha of pInk
	#               accumulates
	#   see         DrawTwilightOn, DrawTerminatorOn
	#@ aka  THE NIGHT SIDE, FILLED -- and this is the method that matters.
	def DrawNightOn(poCanvas, pnYear, pnMonth, pnDay, pnHourUtc, pInk)
		_s_ = This.SunAt(pnYear, pnMonth, pnDay, pnHourUtc)
		if len(_s_) = 0  return 0  ok
		_n_ = 0
		aBelow = [ 0, 6, 12, 18 ]
		for _i_ = 1 to len(aBelow)
			_r_ = StzEngineGeoNightCap(_s_[:lat], _s_[:lon], aBelow[_i_], 361)
			if len(_r_) < 6  loop  ok
			@oP.DrawRingOn(poCanvas, _r_, pInk, "#00000000", 0)
			_n_++
		next
		poCanvas.Flush()
		return _n_

	# Draws the four lines of the horizon and of civil, nautical and astronomical twilight, each thinner than the last.
	#
	#   poCanvas    the stzCanvas to draw on
	#   pnYear      the year
	#   pnMonth     the month from 1
	#   pnDay       the day of the month
	#   pnHourUtc   the hour in UTC
	#   pInk        the line colour
	#   returns     the number of lines drawn, 4
	#   see         DrawNightOn, TwilightAt
	#@ aka  ...and the twilight bands with it, each fainter than the last, which is what a day-night map actually looks like
	def DrawTwilightOn(poCanvas, pnYear, pnMonth, pnDay, pnHourUtc, pInk)
		_n_ = 0
		aAng = [ 90, 96, 102, 108 ]
		aWid = [ 1.6, 1.0, 0.8, 0.6 ]
		for _i_ = 1 to len(aAng)
			_a_ = This.TwilightAt(pnYear, pnMonth, pnDay, pnHourUtc, aAng[_i_])
			if len(_a_) < 6  loop  ok
			@oP.DrawLineOn(poCanvas, _a_, pInk, aWid[_i_])
			_n_++
		next
		poCanvas.Flush()
		return _n_

	# Draws a vector field as arrows whose colour comes from a ramp by speed and whose length carries it too.
	#
	#   poCanvas      the stzCanvas to draw on
	#   paGrid        the field's grid as [ lon0, lat0, dlon, dlat, nx, ny ]
	#   paU           the eastward component at every node, row 0 south
	#   paV           the northward component at every node, row 0 south
	#   pnEvery       draw every n-th node
	#   pnPxPerUnit   arrow length in pixels per unit of speed
	#   pcRamp        the ramp's name, such as :Viridis
	#   pnWidth       the line width in pixels
	#   returns       the number of arrows drawn
	#   note          A zero vector is skipped; each arrow's direction is measured on the paper, not
	#                 assumed
	#   see           DrawVectorsOn, DrawFlowRampedOn
	#@ aka  -- a field that has a direction ----------------------------------------
	def DrawVectorsRampedOn(poCanvas, paGrid, paU, paV, pnEvery, pnPxPerUnit, pcRamp, pnWidth)
		return This._DrawVectorsCore(poCanvas, paGrid, paU, paV, pnEvery,
			pnPxPerUnit, "", pnWidth, StzGeoRamp(pcRamp, 9))

	# Draws a vector field as arrows in one colour, each as long as its speed.
	#
	#   poCanvas      the stzCanvas to draw on
	#   paGrid        the field's grid as [ lon0, lat0, dlon, dlat, nx, ny ]
	#   paU           the eastward component at every node, row 0 south
	#   paV           the northward component at every node, row 0 south
	#   pnEvery       draw every n-th node
	#   pnPxPerUnit   arrow length in pixels per unit of speed
	#   pInk          the colour
	#   pnWidth       the line width in pixels
	#   returns       the number of arrows drawn
	#   note          Returns 0 for a grid that is not six numbers
	#   see           DrawVectorsRampedOn
	def DrawVectorsOn(poCanvas, paGrid, paU, paV, pnEvery, pnPxPerUnit, pInk, pnWidth)
		return This._DrawVectorsCore(poCanvas, paGrid, paU, paV, pnEvery,
			pnPxPerUnit, pInk, pnWidth, [])

	def _DrawVectorsCore(poCanvas, paGrid, paU, paV, pnEvery, pnPxPerUnit, pInk, pnWidth, paRamp)
		_a_ = StzEngineGeoVectorField(paGrid, paU, paV, pnEvery)
		_mmax_ = 0
		for _q_ = 1 to len(_a_) / 5
			if _a_[_q_ * 5] > _mmax_  _mmax_ = _a_[_q_ * 5]  ok
		next
		if _mmax_ <= 0  _mmax_ = 1  ok
		_n_ = len(_a_) / 5
		_drawn_ = 0
		for _i_ = 1 to _n_
			_lon_ = _a_[_i_ * 5 - 4]
			_lat_ = _a_[_i_ * 5 - 3]
			_u_ = _a_[_i_ * 5 - 2]
			_v_ = _a_[_i_ * 5 - 1]
			_m_ = _a_[_i_ * 5]
			if _m_ <= 0  loop  ok
			_p_ = @oP.Project(_lon_, _lat_)
			if len(_p_) < 2  loop  ok
			# THE ARROW IS DRAWN IN THE PAPER'S DIRECTIONS AND NOT IN THE
			# GLOBE'S. A vector pointing due east at 60 degrees north does
			# not point right on most projections, so the heading is taken
			# by projecting a short step ALONG the vector and seeing where
			# it landed -- which costs a second projection and is the only
			# way an arrow on a curved graticule can be right.
			_step_ = 0.4
			_cf_ = cos(_lat_ * 3.141592653589793 / 180)
			if _cf_ < 0.01  _cf_ = 0.01  ok
			_q_ = @oP.Project(_lon_ + _step_ * _u_ / _m_ / _cf_,
			                  _lat_ + _step_ * _v_ / _m_)
			if len(_q_) < 2  loop  ok
			_dx_ = _q_[1] - _p_[1]
			_dy_ = _q_[2] - _p_[2]
			_d_ = sqrt(_dx_ * _dx_ + _dy_ * _dy_)
			if _d_ < 0.000001  loop  ok
			_len_ = _m_ * pnPxPerUnit
			_ink_ = pInk
			if len(paRamp) > 0
				_bb_ = floor(_m_ / _mmax_ * (len(paRamp) - 1)) + 1
				if _bb_ < 1  _bb_ = 1  ok
				if _bb_ > len(paRamp)  _bb_ = len(paRamp)  ok
				_ink_ = paRamp[_bb_]
			ok
			_ex_ = _p_[1] + _dx_ / _d_ * _len_
			_ey_ = _p_[2] + _dy_ / _d_ * _len_
			poCanvas.AddLineQ(_p_[1], _p_[2], _ex_, _ey_).Stroke(_ink_, pnWidth)
			# a head, at a fixed fraction of the shaft
			_hx_ = _dx_ / _d_
			_hy_ = _dy_ / _d_
			_px_ = -_hy_
			_py_ = _hx_
			poCanvas.AddPolygonQ([ _ex_, _ey_,
				_ex_ - _hx_ * _len_ * 0.35 + _px_ * _len_ * 0.18,
				_ey_ - _hy_ * _len_ * 0.35 + _py_ * _len_ * 0.18,
				_ex_ - _hx_ * _len_ * 0.35 - _px_ * _len_ * 0.18,
				_ey_ - _hy_ * _len_ * 0.35 - _py_ * _len_ * 0.18 ]).
				FillQ(_ink_).Stroke("#00000000", 0)
			_drawn_++
		next
		poCanvas.Flush()
		return _drawn_

	# Draws the path of a particle released at each seed, followed by fourth-order Runge-Kutta.
	#
	#   poCanvas    the stzCanvas to draw on
	#   paGrid      the field's grid as [ lon0, lat0, dlon, dlat, nx, ny ]
	#   paU         the eastward component at every node
	#   paV         the northward component at every node
	#   paSeeds     the starting places as one flat list lon, lat, ...
	#   pnStepDeg   the step in degrees of ground
	#   pnSteps     how many steps
	#   pInk        the line colour
	#   pnWidth     the width in pixels
	#   returns     the number of streamlines drawn
	#   note        A line that makes fewer than three points is not drawn
	#   see         StreamlineFrom, DrawFlowOn
	#@ aka  STREAMLINES: a particle released at each seed and followed while the field carries it, integrated by fourth-order Runge-Kutta.
	def DrawStreamlinesOn(poCanvas, paGrid, paU, paV, paSeeds, pnStepDeg, pnSteps, pInk, pnWidth)
		_n_ = len(paSeeds) / 2
		_drawn_ = 0
		for _i_ = 1 to _n_
			_line_ = StzEngineGeoStreamline(paGrid, paU, paV,
				paSeeds[_i_ * 2 - 1], paSeeds[_i_ * 2], pnStepDeg, pnSteps)
			if len(_line_) < 6  loop  ok
			@oP.DrawLineOn(poCanvas, _line_, pInk, pnWidth)
			_drawn_++
		next
		poCanvas.Flush()
		return _drawn_

	# Draws evenly spaced streamlines of a field, which read as motion, with a head every 24 pixels.
	#
	#   poCanvas   the stzCanvas to draw on
	#   paGrid     the field's grid as [ lon0, lat0, dlon, dlat, nx, ny ]
	#   paU        the eastward component at every node
	#   paV        the northward component at every node
	#   pnSepDeg   the spacing of the lines in degrees
	#   pInk       the line and head colour
	#   returns    the number of lines drawn
	#   note       A line stops within half a spacing of another. The stroke widens with speed
	#   see        DrawFlowRampedOn, DrawStreamlinesOn
	#@ aka  EVENLY-SPACED STREAMLINES, which is the difference between a stream plot that reads and one that does not.
	def DrawFlowOn(poCanvas, paGrid, paU, paV, pnSepDeg, pInk)
		return This.DrawFlowOnXT(poCanvas, paGrid, paU, paV, pnSepDeg, pInk,
			pInk, 0.35, 1.9, 400)

	# Draws the same evenly spaced streamlines with speed as colour and as width, and heads in their own colour.
	#
	#   poCanvas   the stzCanvas to draw on
	#   paGrid     the field's grid as [ lon0, lat0, dlon, dlat, nx, ny ]
	#   paU        the eastward component at every node
	#   paV        the northward component at every node
	#   pnSepDeg   the spacing of the lines in degrees
	#   pcRamp     the ramp's name, such as :Viridis
	#   pHeadInk   the colour of the heads
	#   returns    the number of lines drawn
	#   see        DrawFlowOn, DrawVectorsRampedOn
	#@ aka  THE HEAD TAKES ITS OWN COLOUR, because it is a different statement from the line. The line says WHERE the flow goes and the head says WHICH WAY -- two facts, and a reader separates them faster when the ink does. Blue lines with red heads is the pairing the Principal asked for and it is the right one: the path is the quiet layer and the direction is the loud one. ...AND THE SAME FLOW WITH SPEED AS 
	def DrawFlowRampedOn(poCanvas, paGrid, paU, paV, pnSepDeg, pcRamp, pHeadInk)
		return This.DrawFlowRampedOnXT(poCanvas, paGrid, paU, paV, pnSepDeg,
			pcRamp, pHeadInk, 0.5, 2.2, 600)

	def DrawFlowRampedOnXT(poCanvas, paGrid, paU, paV, pnSepDeg, pcRamp, pHeadInk, pnMinW, pnMaxW, pnMaxLines)
		return This._DrawFlowCore(poCanvas, paGrid, paU, paV, pnSepDeg, "",
			pHeadInk, pnMinW, pnMaxW, pnMaxLines, StzGeoRamp(pcRamp, 9))

	def DrawFlowOnXT(poCanvas, paGrid, paU, paV, pnSepDeg, pInk, pHeadInk, pnMinW, pnMaxW, pnMaxLines)
		return This._DrawFlowCore(poCanvas, paGrid, paU, paV, pnSepDeg, pInk,
			pHeadInk, pnMinW, pnMaxW, pnMaxLines, [])

	def _DrawFlowCore(poCanvas, paGrid, paU, paV, pnSepDeg, pInk, pHeadInk, pnMinW, pnMaxW, pnMaxLines, paRamp)
		return This._DrawFlowCoreXT(poCanvas, paGrid, paU, paV, pnSepDeg, pInk, pHeadInk, pnMinW, pnMaxW, pnMaxLines, paRamp, "")

	def _DrawFlowCoreXT(poCanvas, paGrid, paU, paV, pnSepDeg, pInk, pHeadInk, pnMinW, pnMaxW, pnMaxLines, paRamp, pHaloInk)
		if len(paGrid) < 6  return 0  ok
		_lon0_ = paGrid[1]
		_lat0_ = paGrid[2]
		_lon1_ = _lon0_ + paGrid[3] * (paGrid[5] - 1)
		_lat1_ = _lat0_ + paGrid[4] * (paGrid[6] - 1)
		_f_ = StzEngineGeoEvenStreamlines(paGrid, paU, paV,
			_lon0_, _lat0_, _lon1_, _lat1_, pnSepDeg, pnSepDeg / 3, 600, pnMaxLines)
		if len(_f_) < 4  return 0  ok
		_n_ = _f_[1]
		if _n_ < 1  return 0  ok

		# the speed range, so the stroke can be scaled against it rather
		# than against a number picked by hand
		_smax_ = 0
		_base_ = 1 + _n_
		_prev_ = 0
		for _k_ = 1 to _n_
			_end_ = _f_[1 + _k_]
			_i_ = _prev_
			while _i_ < _end_
				_sp_ = StzEngineGeoSpeedAt(paGrid, paU, paV,
					_f_[_base_ + _i_ * 2 + 1], _f_[_base_ + _i_ * 2 + 2])
				if _sp_ > _smax_  _smax_ = _sp_  ok
				_i_ += 8
			end
			_prev_ = _end_
		next
		if _smax_ <= 0  _smax_ = 1  ok

		# EACH LINE IS DRAWN IN SHORT RUNS, not as one polyline, because the
		# width has to change along it. A single stroke can only have one
		# width, so a plot whose stroke means something has to be cut into
		# pieces short enough for the meaning to hold across each.
		_drawn_ = 0
		_prev_ = 0
		for _k_ = 1 to _n_
			_end_ = _f_[1 + _k_]
			_cnt_ = _end_ - _prev_
			if _cnt_ < 4
				_prev_ = _end_
				loop
			ok
			_run_ = 6
			_i_ = _prev_
			while _i_ + 1 < _end_
				_to_ = _i_ + _run_
				if _to_ > _end_ - 1  _to_ = _end_ - 1  ok
				_seg_ = []
				_j_ = _i_
				while _j_ <= _to_
					_seg_ + _f_[_base_ + _j_ * 2 + 1]
					_seg_ + _f_[_base_ + _j_ * 2 + 2]
					_j_++
				end
				_sp_ = StzEngineGeoSpeedAt(paGrid, paU, paV,
					_f_[_base_ + _i_ * 2 + 1], _f_[_base_ + _i_ * 2 + 2])
				_t_ = _sp_ / _smax_
				if _t_ > 1  _t_ = 1  ok
				# THE INK IS THE RAMP'S WHERE ONE WAS GIVEN, and the caller's
				# single colour otherwise. Both paths run the same code, so a
				# ramped flow and a plain one cannot drift apart.
				_ink_ = pInk
				if len(paRamp) > 0
					_b_ = floor(_t_ * (len(paRamp) - 1)) + 1
					if _b_ < 1  _b_ = 1  ok
					if _b_ > len(paRamp)  _b_ = len(paRamp)  ok
					_ink_ = paRamp[_b_]
				ok
				_wd_ = pnMinW + (pnMaxW - pnMinW) * _t_
				# A LIGHT HALO UNDER THE LINE, where one is asked for. A dark
				# line over a full-range perceptual ramp -- viridis, magma --
				# vanishes in the ramp's dark end, so a stream-density plot
				# lays a pale wider stroke under each segment first: the line
				# then reads on the black corners and the bright cores alike.
				# It is the basemap lesson once more -- a mark over a ground
				# it cannot predict has to carry its own contrast.
				if pHaloInk != ""
					@oP.DrawLineOn(poCanvas, _seg_, pHaloInk, _wd_ + 1.6)
				ok
				@oP.DrawLineOn(poCanvas, _seg_, _ink_, _wd_)
				_i_ = _to_
			end
			# ARROWHEADS SPACED BY DISTANCE ON THE PAPER, not by how many
			# points went by.
			#
			# A head only at the END puts every head where a line happened
			# to stop -- under even spacing, wherever it ran into a
			# neighbour -- so they cluster along the seams BETWEEN lines
			# and say nothing about the field. Spacing them every so many
			# POINTS fixes that and breaks something else: the integrator
			# steps in degrees of ground, so a line curving tightly round a
			# vortex packs many steps into few pixels, and twenty-six
			# points can be four pixels. The heads then pile into a solid
			# red chain, and at the centre of a tight vortex into a blob.
			#
			# So the walk accumulates PROJECTED distance and drops a head
			# every so many pixels. The eye reads a head as a mark on the
			# paper, so the paper is what has to space them.
			_run_px_ = 0
			_at_ = _prev_ + 3
			_lastx_ = 0
			_lasty_ = 0
			_have_ = FALSE
			while _at_ < _end_ - 2
				_q_ = @oP.Project(_f_[_base_ + _at_ * 2 + 1], _f_[_base_ + _at_ * 2 + 2])
				if len(_q_) = 2
					if _have_
						_d_ = sqrt(pow(_q_[1] - _lastx_, 2) + pow(_q_[2] - _lasty_, 2))
						# A JUMP IS THE PROJECTION'S SEAM and not travel, so
						# it resets rather than counting: without this a line
						# cut at the antimeridian earns a head on both sides
						# of the map for one step.
						if _d_ < 40  _run_px_ += _d_  else  _run_px_ = 0  ok
					ok
					_lastx_ = _q_[1]
					_lasty_ = _q_[2]
					_have_ = TRUE
					# DENSER THAN IT WAS. At one head every 46 pixels the
					# direction was a mark here and there; Wolfram puts them
					# close enough that a reader never has to look for the
					# next one, and that is what makes a stream plot read as
					# motion rather than as a set of curves.
					if _run_px_ >= 24
						This._FlowHeadOn(poCanvas, _f_, _base_, _at_, pHeadInk)
						_run_px_ = 0
					ok
				ok
				_at_ += 2
			end
			_drawn_++
			_prev_ = _end_
		next
		poCanvas.Flush()
		return _drawn_

	def _FlowHeadOn(poCanvas, paFlat, pnBase, pnAt, pInk)
		if pnAt < 2  return  ok
		_a_ = @oP.Project(paFlat[pnBase + (pnAt - 2) * 2 + 1], paFlat[pnBase + (pnAt - 2) * 2 + 2])
		_b_ = @oP.Project(paFlat[pnBase + pnAt * 2 + 1], paFlat[pnBase + pnAt * 2 + 2])
		if len(_a_) < 2 or len(_b_) < 2  return  ok
		_dx_ = _b_[1] - _a_[1]
		_dy_ = _b_[2] - _a_[2]
		_m_ = sqrt(_dx_ * _dx_ + _dy_ * _dy_)
		# A HEAD ON A SEGMENT THE PROJECTION CUT would point across the
		# whole map, so a jump longer than a head is refused rather than
		# drawn -- the same seam every line in this plane has to survive.
		if _m_ < 0.5 or _m_ > 60  return  ok
		_dx_ /= _m_
		_dy_ /= _m_
		_px_ = -_dy_
		_py_ = _dx_
		# SMALL, because a head is a mark ON a line and not a thing beside
		# it: at five pixels on a 0.3-pixel stroke the head WAS the line.
		# SLIM, and aligned exactly with the line. A blunt head sits BESIDE
		# a streamline; a slender one sits ON it, which at this density is
		# the difference between arrows and a dotted overlay.
		_L_ = 4.2
		poCanvas.AddPolygonQ([ _b_[1], _b_[2],
			_b_[1] - _dx_ * _L_ + _px_ * _L_ * 0.30,
			_b_[2] - _dy_ * _L_ + _py_ * _L_ * 0.30,
			_b_[1] - _dx_ * _L_ - _px_ * _L_ * 0.30,
			_b_[2] - _dy_ * _L_ - _py_ * _L_ * 0.30 ]).FillQ(pInk).Stroke("#00000000", 0)

	# Returns the path of a particle released at a place and carried by the field.
	#
	#   paGrid      the field's grid as [ lon0, lat0, dlon, dlat, nx, ny ]
	#   paU         the eastward component at every node
	#   paV         the northward component at every node
	#   pnLon       longitude of the release in degrees east
	#   pnLat       latitude of the release in degrees north
	#   pnStepDeg   the step in degrees of ground
	#   pnSteps     how many steps
	#   returns     a flat list lon, lat, lon, lat, ... starting at the place
	#   note        LONGITUDE FIRST
	#   see         DrawStreamlinesOn
	def StreamlineFrom(paGrid, paU, paV, pnLon, pnLat, pnStepDeg, pnSteps)
		return StzEngineGeoStreamline(paGrid, paU, paV, pnLon, pnLat, pnStepDeg, pnSteps)

	# Returns the field's vectors at every pnEvery-th node.
	#
	#   paGrid     the field's grid as [ lon0, lat0, dlon, dlat, nx, ny ]
	#   paU        the eastward component at every node
	#   paV        the northward component at every node
	#   pnEvery    take every n-th node
	#   returns    a flat list of five numbers per vector: lon, lat, u, v, speed
	#   note       A 6 by 5 grid with pnEvery 1 gives 30 vectors
	#   see        SpeedField, DrawVectorsOn
	def VectorsOf(paGrid, paU, paV, pnEvery)
		return StzEngineGeoVectorField(paGrid, paU, paV, pnEvery)

	# Returns the speed sqrt(u squared + v squared) at every node.
	#
	#   paGrid     the field's grid as [ lon0, lat0, dlon, dlat, nx, ny ]
	#   paU        the eastward component at every node
	#   paV        the northward component at every node
	#   returns    a list of numbers, one per node, the south row first
	#   note       What a stream-density plot shades
	#   see        DrawStreamDensityOn, stzGeoField
	#@ aka  STREAM DENSITY: THE FLOW DRAWN OVER ITS OWN MAGNITUDE, which is the one thing Wolfram's field plots did that this plane could not.
	def SpeedField(paGrid, paU, paV)
		_n_ = paGrid[5] * paGrid[6]
		_s_ = []
		for _i_ = 1 to _n_
			_s_ + sqrt(paU[_i_] * paU[_i_] + paV[_i_] * paV[_i_])
		next
		return _s_

	# Draws a field's speed as a shaded raster with evenly spaced streamlines on top, the speed on the ground and the shape on the lines.
	#
	#   poCanvas   the stzCanvas to draw on
	#   paGrid     the field's grid as [ lon0, lat0, dlon, dlat, nx, ny ]
	#   paU        the eastward component at every node
	#   paV        the northward component at every node
	#   pnSepDeg   the spacing of the lines in degrees
	#   pcRamp     the ramp's name for the raster
	#   returns    the number of streamlines drawn, 0 when the grid or the components are too short
	#   warning    Defect: without SetPaper the sheet is guessed from the projection's scale, so the
	#              raster covers a box thousands of pixels wide.
	#   see        DrawFlowOn, SpeedField
	def DrawStreamDensityOn(poCanvas, paGrid, paU, paV, pnSepDeg, pcRamp)
		return This.DrawStreamDensityOnXT(poCanvas, paGrid, paU, paV, pnSepDeg,
			pcRamp, "#1A2A44", 20, 8, 800)

	def DrawStreamDensityOnXT(poCanvas, paGrid, paU, paV, pnSepDeg, pcRamp, pLineInk, pnClasses, pnContours, pnMaxLines)
		if len(paGrid) < 6  return 0  ok
		_n_ = paGrid[5] * paGrid[6]
		if len(paU) < _n_ or len(paV) < _n_  return 0  ok

		# the speed at every node: the scalar the background shows, through
		# the one helper so the density and any test read the same numbers
		_fld_ = StzGeoField(paGrid, This.SpeedField(paGrid, paU, paV))
		# THE CLASSES BEFORE THE RAMP, because a ramp has to know how many
		# steps to give -- the field's own contract, met in the right order.
		_fld_.SetClassesEvery(pnClasses)
		_fld_.SetRamp(pcRamp)

		_pp_ = @aPaper
		if len(_pp_) != 4  _pp_ = This._FitBox()  ok

		# 1. THE SHADED MAGNITUDE, GE7b's raster, fully opaque -- it is the
		#    ground and there is nothing under it to show through
		_fld_.DrawXT(poCanvas, @oP, _pp_[1], _pp_[2], _pp_[3], _pp_[4], 255)

		# 2. ITS CONTOURS, faint and pale, so the reader can read a level off
		#    the wash without the lines competing with the flow
		if pnContours > 0
			_lv_ = _fld_.LevelsEvery(pnContours)
			if len(_lv_) > 0
				_fld_.DrawContoursOn(poCanvas, @oP, _lv_, "#FFFFFF44", 0.6)
			ok
		ok

		# 3. THE FLOW ON TOP, one dark ink over a pale halo so the lines read
		#    on every part of the ramp, its head the same ink
		return This._DrawFlowCoreXT(poCanvas, paGrid, paU, paV, pnSepDeg,
			pLineInk, pLineInk, 0.5, 1.8, pnMaxLines, [], "#FFFFFFAA")

	# Draws the older legend: one row per class with its range, "(no region)" for a class nothing falls in, and a no-data row.
	#
	#   poCanvas   the stzCanvas to draw on
	#   poFont     the stzFont to write with
	#   pnX        left edge of the legend
	#   pnY        baseline of the title
	#   pcTitle    the title, "" for none
	#   returns    the y below the legend
	#   note       DrawRampLegendOn is the statistical map's legend
	#   warning    Defect: raises error R2 when values are set and the classes are not, because the
	#              class edges are an empty list read at index 0.
	#   see        DrawRampLegendOn, Findings
	#@ aka  -- the legend and the caption -------------------------------------------
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

	# Returns how the map was made: the projection with its parameters and the source of the boundaries.
	#
	#   returns    text such as "ConicEqualArea (13.67N, 21.56N) rotated -8.08, 0, 0
	#   warning    DrawCaptionOn, SetSource
	#@ aka  how the map was made, and on whose word its borders are where they are. A map with no source says "source not stated" rather than nothing, because silence reads as authority.
	def Caption()
		_c_ = @oP.Caption()
		if @cSource != ""
			_c_ += "  |  " + @cSource
		else
			_c_ += "  |  boundaries: source not stated"
		ok
		return _c_

	# Writes the caption on a canvas in grey.
	#
	#   poCanvas   the stzCanvas to draw on
	#   poFont     the stzFont to write with
	#   pnX        left edge of the text
	#   pnY        baseline of the text
	#   returns    nothing; the text is added to the canvas
	#   note       Size 15
	#   see        Caption
	def DrawCaptionOn(poCanvas, poFont, pnX, pnY)
		poCanvas.SetFontQ(poFont, 15).AddTextQ(This.Caption(), pnX, pnY).Fill("#555555")

	# Returns where the map argues against itself: area-distorting projection, lost members, missing keys, bad insets, no source.
	#
	#   returns    a list of [ :rule, :subject, :where, :severity, :message ]; [ ] when clean
	#   note       An error is a picture that argues against its own legend, a warning an advice. It
	#              does not see values set without classes
	#   see        IsSound, StzCheckGeoMaps
	#@ aka  -- WHAT THE GATE OWES A MAP (GE3) --------------------------------------
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

		# 1a-bis. A MEMBERSHIP MAP THAT LOST A MEMBER IS WRONG ABOUT THE
		# ONE THING IT SHOWS. "BRICS -- 11 members" over ten painted
		# countries is a false caption, and the failure is silent: the
		# missing one just looks like everybody else. GE4 refuses fuzzy
		# matching for this reason and this is the same refusal, enforced
		# where the names are finally used.
		if len(@aUnresolved) > 0
			_who_ = @aUnresolved[1][:name]
			_a_ + [ :rule = "every_named_member_was_found",
				:subject = _cM_, :where = "" + len(@aUnresolved) + " name(s), from '" + _who_ + "'",
				:severity = "error",
				:message = "" + len(@aUnresolved) + " named member(s) matched no feature in " +
					"this map, beginning with '" + _who_ + "' -- the map draws fewer " +
					"members than its own key claims, and nothing on the sheet says so" ]
		ok

		# 1a-ter. TWO BLOCS CANNOT BOTH OWN A COUNTRY, and where a caller's
		# lists overlap the first claims it. That is a real fact about the
		# data -- a country in two blocs -- and the reader is owed it rather
		# than a colour chosen by list order.
		_dup_ = 0
		for _g_ = 1 to len(@aGroups)  _dup_ += @aGroups[_g_][:taken]  next
		if _dup_ > 0
			_a_ + [ :rule = "a_country_belongs_to_one_group",
				:subject = _cM_, :where = "" + _dup_ + " overlap(s)",
				:severity = "warning",
				:message = "" + _dup_ + " country(ies) are named in more than one group; " +
					"each is drawn in the colour of the FIRST that claims it, which is " +
					"list order and not a fact about the world" ]
		ok

		# 1a-quater. AND THE AREA RULE REACHES A BLOC MAP HARDEST OF ALL.
		# A choropleth at least has a legend a reader can check a colour
		# against. A membership map's whole rhetorical content is HOW MUCH
		# OF THE WORLD each group covers -- that is the only quantity on the
		# sheet, and it is read straight off the painted area. On Mercator,
		# Russia and Canada are three times the ground they have, so the
		# picture makes an argument about size that the projection invented.
		if len(@aGroups) > 0 and NOT @oP.IsEqualArea()
			_a_ + [ :rule = "a_membership_map_needs_an_equal_area_projection",
				:subject = _cM_, :where = @oP.Name(), :severity = "error",
				:message = "the regions are coloured by which group they belong to and '" +
					@oP.Name() + "' does not preserve area -- the only quantity a bloc " +
					"map carries is how much of the world each bloc covers, and this " +
					"projection invents it" ]
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
				# A RULE MUST JUDGE WHAT WAS DRAWN. Once a membership map
				# labels only its members, this was accusing the other
				# hundred and fifty-nine countries of a world sheet of
				# mis-placed labels they never had -- a warning about work
				# the map did not do, which is the kind that gets ignored
				# and then hides a real one.
				if len(@aGroups) > 0 and This.GroupOf(_i_) = 0  loop  ok
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

		# 1c-quater. AN INSET IS OF SOMEWHERE, AND IT IS LARGER.
		#
		# Two ways to draw a box that is not an inset. A window catching no
		# feature is a frame over nothing, and the locator rectangle on the
		# parent then points at empty ground -- the reader hunts for what it
		# marks and there is nothing there: ERROR. And a window drawn at the
		# parent's own scale or smaller is not a magnification, it is the
		# same picture again in a frame, which spends a reader's attention
		# and returns nothing: ERROR, because the caller meant to magnify
		# and did not.
		if @bInsetsDrawn
			for _k_ = 1 to len(@aInsets)
				if @aInsets[_k_][:count] = 0
					_a_ + [ :rule = "an_inset_is_of_somewhere",
						:subject = _cM_, :where = "inset " + _k_,
						:severity = "error",
						:message = "inset " + _k_ + " has a window no region falls in, " +
							"so its locator rectangle marks empty ground and its frame " +
							"holds nothing" ]
					loop
				ok
				if @aInsets[_k_][:dropped] > 0
					_a_ + [ :rule = "an_inset_names_what_it_took",
						:subject = _cM_, :where = "inset " + _k_,
						:severity = "warning",
						:message = "inset " + _k_ + " took " + @aInsets[_k_][:count] +
							" region(s) off the main map and could name only " +
							@aInsets[_k_][:named] + " of them -- the other " +
							@aInsets[_k_][:dropped] + " are labelled NOWHERE on the " +
							"sheet, because the parent left them to the inset. Give " +
							"the inset box more room" ]
				ok
				if @aInsets[_k_][:scale] <= 1.05
					_a_ + [ :rule = "an_inset_is_larger_than_the_map",
						:subject = _cM_, :where = "inset " + _k_,
						:severity = "error",
						:message = "inset " + _k_ + " is drawn at " +
							StzFactNumText(@aInsets[_k_][:scale]) + " times the main " +
							"map's scale -- an inset exists to magnify, and one that " +
							"does not is the same picture again inside a frame" ]
				ok
			next
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

	# TRUE if any part of feature pnI reaches the paper at all.
	#
	#   pnI        the position of the feature, from 1
	#   returns    TRUE or FALSE
	#   note       Looks at the outer ring of each part
	#   warning    Defect: no range check, so a position of 0 or past the last raises error R2.
	#   see        Findings, PaperBoxOf
	#@ aka  does any point of this feature reach the paper at all?
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

	# TRUE if the map has no finding of severity error.
	#
	#   returns    TRUE or FALSE
	#   note       Warnings do not count
	#   see        Findings
	def IsSound()
		_a_ = This.Findings()
		for _i_ = 1 to len(_a_)
			if _a_[_i_][:severity] = "error"  return FALSE  ok
		next
		return TRUE

	# Returns the longitude and latitude under a pixel, the inverse of the projection.
	#
	#   pnX        paper x
	#   pnY        paper y
	#   returns    a list [ lon, lat ], or [ ] off the sphere
	#   see        FeatureAt, stzGeoProjection.Invert
	#@ aka  -- GE5: THE HANDS ------------------------------------------------------
	def PlaceAt(pnX, pnY)
		return @oP.Invert(pnX, pnY)

	# Returns the feature under a pixel: what a click asks.
	#
	#   pnX        paper x
	#   pnY        paper y
	#   returns    a number from 1, or 0 for the sea, the sky and the margin
	#   see        NameAt, ValueAt, PlaceAt
	#@ aka  the feature under a pixel, or 0 for the sea, the sky and the margin
	def FeatureAt(pnX, pnY)
		_g_ = @oP.Invert(pnX, pnY)
		if len(_g_) < 2  return 0  ok
		return @oF.IndexAt(_g_[1], _g_[2])

	# Returns the name of the feature under a pixel, what a tooltip shows.
	#
	#   pnX        paper x
	#   pnY        paper y
	#   returns    text, "" where there is none
	#   see        FeatureAt
	#@ aka  ...and what it is called, or "" -- what a tooltip shows
	def NameAt(pnX, pnY)
		_i_ = This.FeatureAt(pnX, pnY)
		if _i_ < 1  return ""  ok
		return @oF.NameOf(_i_)

	# Returns the value of the feature under a pixel.
	#
	#   pnX        paper x
	#   pnY        paper y
	#   returns    the stored value, or "" where there is no feature or no value
	#   see        FeatureAt, NameAt
	#@ aka  ...and its value, or "" where it has none
	def ValueAt(pnX, pnY)
		_i_ = This.FeatureAt(pnX, pnY)
		if _i_ < 1  return ""  ok
		return This.ValueOf(_i_)
