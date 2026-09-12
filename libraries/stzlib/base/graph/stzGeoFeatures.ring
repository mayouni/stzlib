#---------------------------------------------------------------------------#
#  STZGEOFEATURES -- boundary data, whole (GE1)                              #
#---------------------------------------------------------------------------#
#
#     oF = StzGeoFeaturesFromJson(read("provinces.geojson"))
#     oF = StzGeoFeaturesFromTopoJson(read("countries-110m.json"), "countries")
#
#     oF.Count()                  how many features
#     oF.NameOf(3)                what the file calls it
#     oF.PropertyOf(3, "pop")     a value to colour by
#     oF.PartsOf(3)               its parts; each part is a list of RINGS
#     oF.RingsOf(3, 1)            the first part: ring 1 is the outer edge,
#                                 every ring after it is a HOLE
#
# WHAT THIS KEEPS THAT DN24b THREW AWAY. The choropleth's own reader takes
# a feature's largest ring and drops the rest: a country becomes its
# mainland, its islands vanish, and a lake inside it is filled in as land.
# That was the right first step and it is not a data layer. This reads the
# whole geometry -- every part, every hole -- and tells the caller what it
# holds rather than deciding for them.
#
# AND IT READS TOPOJSON, which is what every public atlas actually ships.
# TopoJSON stores each shared border ONCE, as an ARC, and writes a country
# as the list of arcs that bound it; a negative index means the arc walked
# backwards. Coordinates are delta-encoded against a quantised grid, so a
# world at the scale a screen can show is a fifth the size of the same
# GeoJSON and its neighbours' borders cannot drift apart, because there is
# only one copy of each.
#
# WHAT IS NOT HERE, named: no simplification (a file is drawn at the detail
# it was saved with), no reprojection of the source data (coordinates are
# longitude and latitude, as both formats require), no writing.

# EVERY BOUNDARY FILE IS READ BY THE HOUSE'S OWN JSON READER, not Ring's.
# StzJsonToList parses in the engine; the measurements are on that function
# in base/file/stzJsonFuncs.ring. In short: Ring's JsonToList loses its
# place on a raw multibyte character AND does not read the \uXXXX escape at
# all, and both failures are silent -- a well-formed list, wrong.

func StzGeoFeaturesFromJson(pcJson)
	_o_ = new stzGeoFeatures
	_o_.ReadGeoJson(pcJson)
	return _o_

func StzGeoFeaturesFromTopoJson(pcJson, pcObject)
	_o_ = new stzGeoFeatures
	_o_.ReadTopoJson(pcJson, pcObject)
	return _o_

# the keys a boundary file is likely to call a name, in the order a reader
# would try them. A file that uses none of them is not broken -- the caller
# names their own key with PropertyOf().
func StzGeoNameKeys()
	return [ "name", "NAME", "Name", "nom", "admin", "ADMIN", "NAME_EN",
	         "NAME_LONG", "name_en", "title", "label", "id" ]

class stzGeoFeatures from stzObject
	@aFeat = []      # each: [ cKind, cId, aProps, aParts ]
	@nSkipped = 0
	# THE ARCS, FLAT, AND NOT A PARAMETER. Ring assigns and passes lists BY
	# VALUE, so handing the decoded arcs down through the reader copied ten
	# thousand points once per country: the world atlas took 52 SECONDS to
	# read, and 0.6 after this. They live on the object now, as one flat
	# list of numbers with an offset and a length per arc, so every read is
	# of a NUMBER and nothing is ever copied.
	@aArcXY = []
	@aArcOff = []
	@aArcLen = []

	#-- reading ------------------------------------------------------------

	def ReadGeoJson(pcJson)
		if NOT (isString(pcJson) and len(ring_trim(pcJson)) > 0)
			stzraise("stzGeoFeatures: give the GeoJSON text to read.")
		ok
		_aJ_ = StzJsonToList(pcJson)
		if NOT isList(_aJ_)
			stzraise("stzGeoFeatures: that is not JSON this reader could parse.")
		ok
		@aFeat = []
		@nSkipped = 0
		if HasKey(_aJ_, :features)
			_aF_ = _aJ_[:features]
			for _i_ = 1 to len(_aF_)
				This._TakeFeature(_aF_[_i_])
			next
		but HasKey(_aJ_, :geometry)
			This._TakeFeature(_aJ_)
		but HasKey(_aJ_, :type) and HasKey(_aJ_, :coordinates)
			This._TakeGeometry(_aJ_, "", [])
		else
			stzraise("stzGeoFeatures: no 'features' and no 'geometry' -- this reader " +
				"takes a GeoJSON FeatureCollection, a Feature, or a bare geometry.")
		ok

	def _TakeFeature(paF)
		if NOT (isList(paF) and HasKey(paF, :geometry))
			@nSkipped++
			return
		ok
		_p_ = []
		if HasKey(paF, :properties) and isList(paF[:properties])  _p_ = paF[:properties]  ok
		_id_ = ""
		if HasKey(paF, :id)  _id_ = "" + paF[:id]  ok
		This._TakeGeometry(paF[:geometry], _id_, _p_)

	def _TakeGeometry(paG, pcId, paProps)
		if NOT (isList(paG) and HasKey(paG, :type))
			@nSkipped++
			return
		ok
		_t_ = StzLower("" + paG[:type])
		if _t_ = "geometrycollection"
			if NOT HasKey(paG, :geometries)  @nSkipped++  return  ok
			_ag_ = paG[:geometries]
			for _i_ = 1 to len(_ag_)
				This._TakeGeometry(_ag_[_i_], pcId, paProps)
			next
			return
		ok
		if NOT HasKey(paG, :coordinates)  @nSkipped++  return  ok
		_c_ = paG[:coordinates]
		_aParts_ = []
		_kind_ = ""
		if _t_ = "polygon"
			_kind_ = "polygon"
			_aParts_ + This._Rings(_c_)
		but _t_ = "multipolygon"
			_kind_ = "polygon"
			for _i_ = 1 to len(_c_)
				_r_ = This._Rings(_c_[_i_])
				if len(_r_) > 0  _aParts_ + _r_  ok
			next
		but _t_ = "linestring"
			_kind_ = "line"
			_aParts_ + [ This._Flat(_c_) ]
		but _t_ = "multilinestring"
			_kind_ = "line"
			for _i_ = 1 to len(_c_)
				_aParts_ + [ This._Flat(_c_[_i_]) ]
			next
		but _t_ = "point"
			_kind_ = "point"
			if isList(_c_) and len(_c_) >= 2  _aParts_ + [ [ _c_[1], _c_[2] ] ]  ok
		but _t_ = "multipoint"
			_kind_ = "point"
			for _i_ = 1 to len(_c_)
				if isList(_c_[_i_]) and len(_c_[_i_]) >= 2
					_aParts_ + [ [ _c_[_i_][1], _c_[_i_][2] ] ]
				ok
			next
		else
			@nSkipped++
			return
		ok
		if len(_aParts_) = 0
			@nSkipped++
			return
		ok
		@aFeat + [ _kind_, pcId, paProps, _aParts_ ]

	# a polygon's rings: the first is the outer edge, the rest are holes.
	# EVERY RING IS CLOSED HERE, whichever file it came from. GeoJSON writes
	# the first point again at the end and TopoJSON does not, so a reader
	# that passed each through untouched would answer two different lists
	# for the same border -- and the one property worth having of these two
	# readers is that they cannot.
	def _Rings(paC)
		_a_ = []
		if NOT isList(paC)  return _a_  ok
		for _i_ = 1 to len(paC)
			_f_ = _GeoCloseRing(This._Flat(paC[_i_]))
			if len(_f_) >= 6  _a_ + _f_  ok
		next
		return _a_

	def _Flat(paRing)
		_a_ = []
		if NOT isList(paRing)  return _a_  ok
		for _i_ = 1 to len(paRing)
			_p_ = paRing[_i_]
			if isList(_p_) and len(_p_) >= 2 and isNumber(_p_[1]) and isNumber(_p_[2])
				_a_ + _p_[1]
				_a_ + _p_[2]
			ok
		next
		return _a_

	# THE ARCS ARE SHARED AND THE NUMBERS ARE DELTAS. A TopoJSON stores each
	# border once and every shape as the arcs that bound it; -1 means arc 0
	# walked backwards (the format writes ~i, which is -i-1). The positions
	# inside an arc are cumulative sums on a quantised grid and become
	# degrees through the transform.
	def ReadTopoJson(pcJson, pcObject)
		if NOT (isString(pcJson) and len(ring_trim(pcJson)) > 0)
			stzraise("stzGeoFeatures: give the TopoJSON text to read.")
		ok
		_aJ_ = StzJsonToList(pcJson)
		if NOT (isList(_aJ_) and HasKey(_aJ_, :arcs) and HasKey(_aJ_, :objects))
			stzraise("stzGeoFeatures: that is not a TopoJSON topology -- it needs " +
				"'arcs' and 'objects'.")
		ok
		_sx_ = 1  _sy_ = 1  _tx_ = 0  _ty_ = 0
		if HasKey(_aJ_, :transform)
			_tr_ = _aJ_[:transform]
			if HasKey(_tr_, :scale)  _sx_ = _tr_[:scale][1]  _sy_ = _tr_[:scale][2]  ok
			if HasKey(_tr_, :translate)  _tx_ = _tr_[:translate][1]  _ty_ = _tr_[:translate][2]  ok
		ok
		# every arc, decoded once, into ONE flat list
		@aArcXY = []
		@aArcOff = []
		@aArcLen = []
		_raw_ = _aJ_[:arcs]
		_bT_ = HasKey(_aJ_, :transform)
		for _i_ = 1 to len(_raw_)
			_a_ = _raw_[_i_]
			_x_ = 0  _y_ = 0
			_n0_ = len(@aArcXY)
			_cnt_ = 0
			for _j_ = 1 to len(_a_)
				_p_ = _a_[_j_]
				if NOT (isList(_p_) and len(_p_) >= 2)  loop  ok
				if _bT_
					_x_ += _p_[1]
					_y_ += _p_[2]
					@aArcXY + (_x_ * _sx_ + _tx_)
					@aArcXY + (_y_ * _sy_ + _ty_)
				else
					@aArcXY + _p_[1]
					@aArcXY + _p_[2]
				ok
				_cnt_++
			next
			@aArcOff + _n0_
			@aArcLen + _cnt_
		next

		_objs_ = _aJ_[:objects]
		_ob_ = []
		if pcObject != NULL and isString(pcObject) and len(pcObject) > 0
			if NOT HasKey(_objs_, pcObject)
				stzraise("stzGeoFeatures: this topology has no object called '" + pcObject +
					"' -- it holds " + _GeoKeyNames(_objs_) + ".")
			ok
			_ob_ = _objs_[pcObject]
		else
			# the only object, when the caller does not say which
			if len(_objs_) < 1
				stzraise("stzGeoFeatures: this topology has no objects in it.")
			ok
			_ob_ = _objs_[1][2]
		ok

		@aFeat = []
		@nSkipped = 0
		This._TakeTopoGeometry(_ob_, "", [])

	def _TakeTopoGeometry(paG, pcId, paProps)
		if NOT (isList(paG) and HasKey(paG, :type))  @nSkipped++  return  ok
		_t_ = StzLower("" + paG[:type])
		_id_ = pcId
		if HasKey(paG, :id)  _id_ = "" + paG[:id]  ok
		_pr_ = paProps
		if HasKey(paG, :properties) and isList(paG[:properties])  _pr_ = paG[:properties]  ok
		if _t_ = "geometrycollection"
			if NOT HasKey(paG, :geometries)  @nSkipped++  return  ok
			_ag_ = paG[:geometries]
			for _i_ = 1 to len(_ag_)
				This._TakeTopoGeometry(_ag_[_i_], _id_, _pr_)
			next
			return
		ok
		if NOT HasKey(paG, :arcs)  @nSkipped++  return  ok
		_c_ = paG[:arcs]
		_aParts_ = []
		_kind_ = ""
		if _t_ = "polygon"
			_kind_ = "polygon"
			_aParts_ + This._TopoRings(_c_)
		but _t_ = "multipolygon"
			_kind_ = "polygon"
			for _i_ = 1 to len(_c_)
				_r_ = This._TopoRings(_c_[_i_])
				if len(_r_) > 0  _aParts_ + _r_  ok
			next
		but _t_ = "linestring"
			_kind_ = "line"
			_aParts_ + [ This._TopoRing(_c_) ]
		but _t_ = "multilinestring"
			_kind_ = "line"
			for _i_ = 1 to len(_c_)
				_aParts_ + [ This._TopoRing(_c_[_i_]) ]
			next
		else
			@nSkipped++
			return
		ok
		if len(_aParts_) = 0  @nSkipped++  return  ok
		@aFeat + [ _kind_, _id_, _pr_, _aParts_ ]

	def _TopoRings(paRings)
		_a_ = []
		for _i_ = 1 to len(paRings)
			_f_ = _GeoCloseRing(This._TopoRing(paRings[_i_]))
			if len(_f_) >= 6  _a_ + _f_  ok
		next
		return _a_

	# one ring, stitched out of the arcs it names. Every read below is of a
	# NUMBER out of the flat table -- no arc is ever copied.
	def _TopoRing(paIdx)
		_out_ = []
		if NOT isList(paIdx)  return _out_  ok
		for _i_ = 1 to len(paIdx)
			_k_ = paIdx[_i_]
			if NOT isNumber(_k_)  loop  ok
			_rev_ = FALSE
			_n_ = _k_
			if _n_ < 0
				_rev_ = TRUE
				_n_ = -_n_ - 1
			ok
			if _n_ < 0 or _n_ >= len(@aArcOff)  loop  ok
			_off_ = @aArcOff[_n_ + 1]
			_np_ = @aArcLen[_n_ + 1]
			# the join point is written in both arcs; drop the repeat
			_from_ = 1
			if len(_out_) > 0  _from_ = 2  ok
			for _j_ = _from_ to _np_
				_at_ = _j_
				if _rev_  _at_ = _np_ - _j_ + 1  ok
				_out_ + @aArcXY[_off_ + _at_ * 2 - 1]
				_out_ + @aArcXY[_off_ + _at_ * 2]
			next
		next
		return _out_

	#-- what it holds -------------------------------------------------------

	def Count()
		return len(@aFeat)

	# how many geometries the reader could not use, counted rather than
	# guessed at -- a record that drops counts what it dropped
	def SkippedCount()
		return @nSkipped

	def KindOf(pn)
		return @aFeat[pn][1]

	def IdOf(pn)
		return @aFeat[pn][2]

	def PropertiesOf(pn)
		return @aFeat[pn][3]

	def PropertyOf(pn, pcKey)
		_p_ = @aFeat[pn][3]
		if isList(_p_) and HasKey(_p_, pcKey)  return _p_[pcKey]  ok
		return ""

	def HasProperty(pn, pcKey)
		_p_ = @aFeat[pn][3]
		return isList(_p_) and HasKey(_p_, pcKey)

	# what the file calls it: the first of the usual name keys it carries,
	# or its id, or "" -- and the caller who knows better says so themselves
	def NameOf(pn)
		_p_ = @aFeat[pn][3]
		if isList(_p_)
			_k_ = StzGeoNameKeys()
			for _i_ = 1 to len(_k_)
				if HasKey(_p_, _k_[_i_])  return "" + _p_[_k_[_i_]]  ok
			next
		ok
		return @aFeat[pn][2]

	def IndexOfName(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		for _i_ = 1 to len(@aFeat)
			if StzLower(ring_trim(This.NameOf(_i_))) = _c_  return _i_  ok
		next
		return 0

	def PartsOf(pn)
		return @aFeat[pn][4]

	def PartCount(pn)
		return len(@aFeat[pn][4])

	# a part's rings: [1] is the outer edge, every one after it is a HOLE
	def RingsOf(pn, pnPart)
		return @aFeat[pn][4][pnPart]

	def OuterRingOf(pn, pnPart)
		return @aFeat[pn][4][pnPart][1]

	def HoleCountOf(pn)
		_n_ = 0
		_a_ = @aFeat[pn][4]
		for _i_ = 1 to len(_a_)
			_n_ += len(_a_[_i_]) - 1
		next
		return _n_

	# every lon/lat this feature holds, flat -- what FitToPoints takes
	def PointsOf(pn)
		_a_ = []
		_p_ = @aFeat[pn][4]
		for _i_ = 1 to len(_p_)
			for _j_ = 1 to len(_p_[_i_])
				_r_ = _p_[_i_][_j_]
				for _k_ = 1 to len(_r_)  _a_ + _r_[_k_]  next
			next
		next
		return _a_

	def AllPoints()
		_a_ = []
		for _i_ = 1 to len(@aFeat)
			_p_ = This.PointsOf(_i_)
			for _k_ = 1 to len(_p_)  _a_ + _p_[_k_]  next
		next
		return _a_

	# [ lonMin, latMin, lonMax, latMax ]
	def BoundsOf(pn)
		return _GeoLonLatBounds(This.PointsOf(pn))

	def Bounds()
		return _GeoLonLatBounds(This.AllPoints())

	# the biggest part by point count -- the mainland, and the only thing
	# DN24b's reader ever kept
	def LargestPartOf(pn)
		_a_ = @aFeat[pn][4]
		_best_ = 1
		_n_ = 0
		for _i_ = 1 to len(_a_)
			if len(_a_[_i_][1]) > _n_
				_n_ = len(_a_[_i_][1])
				_best_ = _i_
			ok
		next
		return _best_

	# is this place inside this feature? Any part counts; a hole excludes.
	def Contains(pn, pnLon, pnLat)
		_a_ = @aFeat[pn][4]
		for _i_ = 1 to len(_a_)
			if StzGeoRingContains(_a_[_i_][1], pnLon, pnLat)
				_bHole_ = FALSE
				for _j_ = 2 to len(_a_[_i_])
					if StzGeoRingContains(_a_[_i_][_j_], pnLon, pnLat)  _bHole_ = TRUE  ok
				next
				if NOT _bHole_  return TRUE  ok
			ok
		next
		return FALSE

	# which feature is at this place, or 0 -- what a click will ask
	def IndexAt(pnLon, pnLat)
		for _i_ = 1 to len(@aFeat)
			if This.Contains(_i_, pnLon, pnLat)  return _i_  ok
		next
		return 0

	# the regions the choropleth builder takes, so a file read here can go
	# straight into DN24's picture: [ name, value, flatOuterRing ] each,
	# from the LARGEST part of every feature
	def AsRegions(pcValueKey)
		_a_ = []
		for _i_ = 1 to len(@aFeat)
			if @aFeat[_i_][1] != "polygon"  loop  ok
			_v_ = ""
			if This.HasProperty(_i_, pcValueKey)  _v_ = This.PropertyOf(_i_, pcValueKey)  ok
			_a_ + [ This.NameOf(_i_), _v_, This.OuterRingOf(_i_, This.LargestPartOf(_i_)) ]
		next
		return _a_

# the first point written again at the end, if it is not there already
func _GeoCloseRing(paLonLat)
	_n_ = len(paLonLat)
	if _n_ < 6  return paLonLat  ok
	if paLonLat[1] = paLonLat[_n_ - 1] and paLonLat[2] = paLonLat[_n_]  return paLonLat  ok
	_a_ = paLonLat
	_a_ + paLonLat[1]
	_a_ + paLonLat[2]
	return _a_

func _GeoLonLatBounds(paLonLat)
	if len(paLonLat) < 2  return [ 0, 0, 0, 0 ]  ok
	_x0_ = paLonLat[1]  _x1_ = paLonLat[1]
	_y0_ = paLonLat[2]  _y1_ = paLonLat[2]
	for _i_ = 1 to len(paLonLat) - 1 step 2
		if paLonLat[_i_] < _x0_  _x0_ = paLonLat[_i_]  ok
		if paLonLat[_i_] > _x1_  _x1_ = paLonLat[_i_]  ok
		if paLonLat[_i_ + 1] < _y0_  _y0_ = paLonLat[_i_ + 1]  ok
		if paLonLat[_i_ + 1] > _y1_  _y1_ = paLonLat[_i_ + 1]  ok
	next
	return [ _x0_, _y0_, _x1_, _y1_ ]

func _GeoKeyNames(paHash)
	_c_ = ""
	for _i_ = 1 to len(paHash)
		if _i_ > 1  _c_ += ", "  ok
		_c_ += "" + paHash[_i_][1]
	next
	return _c_
