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

# ONE COUNTRY OUT OF A FILE THAT HOLDS THE WORLD. Natural Earth's admin-1
# file -- every province, governorate, region and department on Earth -- is
# 40 MB and 4,596 features. A caller who wants the eight regions of Niger
# does not want the other 4,588 crossing the bridge, and on this machine a
# Ring list of that tree is the "holds a large corpus in memory" hazard the
# house has a rule about.
#
# So the match happens IN THE ENGINE and only what was asked for is parsed:
# 38.8 MB in, 60 KB out, under a second. The property is whatever the file
# carries -- iso_a2, adm0_a3, admin -- and a number matches its own digits,
# so an id written as 250 is found by "250".
func StzGeoFeaturesFromJsonWhere(pcJson, pcKey, pcValue)
	_c_ = StzEngineJsonFilterFeatures("" + pcJson, "" + pcKey, "" + pcValue)
	if len(_c_) = 0
		stzraise("StzGeoFeaturesFromJsonWhere: nothing came back -- is that a " +
			"FeatureCollection, and does it carry a '" + pcKey + "' property?")
	ok
	return StzGeoFeaturesFromJson(_c_)

func StzGeoFeaturesFromJson(pcJson)
	_o_ = new stzGeoFeatures
	_o_.ReadGeoJson(pcJson)
	_o_._Box()
	return _o_

func StzGeoFeaturesFromTopoJson(pcJson, pcObject)
	_o_ = new stzGeoFeatures
	_o_.ReadTopoJson(pcJson, pcObject)
	_o_._Box()
	return _o_

# the keys a boundary file is likely to call a name, in the order a reader
# would try them. A file that uses none of them is not broken -- the caller
# names their own key with PropertyOf().
func StzGeoNameKeys()
	# geoBoundaries -- one of the most-used open boundary sources, and the
	# UN's for humanitarian work -- calls the name shapeName, so a reader
	# that did not know that key answered a country of blanks for the whole
	# of Niger. Added where it is tried, not worked around at the call site.
	return [ "name", "NAME", "Name", "nom", "admin", "ADMIN", "NAME_EN",
	         "NAME_LONG", "name_en", "shapeName", "shapeName_en",
	         "title", "label", "id" ]

# Holds the polygons, lines and points of a boundary file whole, every part and every hole, read from GeoJSON or TopoJSON, and answers what lies where.
#
# Build one with StzGeoFeaturesFromJson, StzGeoFeaturesFromTopoJson or StzGeoFeaturesFromJsonWhere,
# which also compute the boxes that make point-in-region tests fast. Each feature is a kind, an id,
# a hash list of properties and its parts; a polygon part is a list of rings, the first the outer
# edge and every one after it a hole. Every ring is closed, whichever format it came from.
# Coordinates are longitude then latitude, degrees, as both formats require, and every place-taking
# method here is LONGITUDE FIRST (Contains, IndexAt, Within). Nothing is simplified or reprojected,
# and this library vendors no boundary data: the atlas files are the caller's
# (test/graphics/atlas/README.md). Areas are measured on WGS84. One trap in the windows: a feature
# that crosses the antimeridian (Fiji, Russia, Antarctica) has a bounding box 360 degrees wide whose
# middle falls anywhere, so Within and IndicesWithin take Fiji for an Africa window. Pictures, each
# looked at by 'stzlib-docs visual pass (a model reading the PNG)' on 2026-10-05:
# doc/gallery/stzGeoFeatures/parts_holes_lookup.png, parts, holes, an IndexAt raster of Niger and
# South Africa's hole, RIGHT; doc/gallery/stzGeoFeatures/window_and_areas.png, the areas panel RIGHT
# and the Within panel WRONG (Fiji is taken, see FINDINGS_geo.md); lines_points_kinds.png, a river,
# wells and a lake with a hole read from GeoJSON, RIGHT. Index: doc/gallery/INDEX_geo.md.
#
#   receiver   o1 = StzGeoFeaturesFromJson(read("../graphics/fixtures/two_countries.geojson"))
#   example    ? o1.Count()
#              #--> 2
#              ? o1.NameOf(2)
#              #--> Berea
#              ? o1.IndexAt(8, 5)
#              #--> 2
#   see        stzGeoMap, stzGeoProjection, stzGeoAtlas, stzGeoPoints
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
	# EVERY FEATURE'S BOX, computed once. A spatial join asks "is this point
	# in that region" for every pair, and for 3,000 points over 23
	# governorates that is 69,000 questions of which almost all are answered
	# by a box. MEASURED, on exactly that: 3.4 s -> 0.6 s, 5.7 times, with
	# the answers identical to the unit -- 1,848 inside, 1,152 outside, the
	# same governorate busiest. The hit test on the world went 2.6 ms to
	# 0.38 ms, seven times, which is the difference between a click and a
	# hover.
	#
	# The first draft of this comment said "seventeen times", written before
	# the measurement. It stands here as the number it actually is.
	@aBox = []

	# Replaces the features with those of a GeoJSON text: a FeatureCollection, one Feature or a bare geometry; raises an error for anything else.
	#
	#   pcJson     the GeoJSON text to read
	#   returns    nothing; the features are stored, and SkippedCount says how many geometries were
	#              unusable
	#   note       Called directly it does not compute the per-feature boxes that make Contains fast
	#              (StzGeoFeaturesFromJson does); answers stay correct
	#   see        ReadTopoJson, Count, SkippedCount
	#@ aka  -- reading ------------------------------------------------------------
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

	# Replaces the features with those of one object of a TopoJSON topology, its shared arcs decoded and every ring closed.
	#
	#   pcJson     the TopoJSON text to read
	#   pcObject   the name of the object to take, such as "countries", or "" for the only or first
	#              one
	#   returns    nothing; the features are stored
	#   note       Raises an error that names the objects the file holds when pcObject is not one of
	#              them. The two readers give the same closed rings for the same border
	#   see        ReadGeoJson, Count
	#@ aka  THE ARCS ARE SHARED AND THE NUMBERS ARE DELTAS. A TopoJSON stores each border once and every shape as the arcs that bound it; -1 means arc 0 walked backwards (the format writes ~i, which is -i-1). The positions inside an arc are cumulative sums on a quantised grid and become degrees through the transform.
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
		@aBox = []
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

	# Returns how many features the set holds.
	#
	#   returns    a number, 8 for Niger's regions and 177 for the 110m world
	#   see        SkippedCount, NameOf
	#@ aka  -- what it holds -------------------------------------------------------
	def Count()
		return len(@aFeat)

	# Returns how many geometries the last read could not use and left out.
	#
	#   returns    a number, 0 for a clean file
	#   see        ReadGeoJson, Count
	#@ aka  how many geometries the reader could not use, counted rather than guessed at -- a record that drops counts what it dropped
	def SkippedCount()
		return @nSkipped

	# Returns what kind of shape feature pn is.
	#
	#   pn         the position of the feature, from 1
	#   returns    one of the texts "polygon", "line" or "point"
	#   see        PartsOf, DrawFeatureOn
	def KindOf(pn)
		return @aFeat[pn][1]

	# Returns the id the file gives feature pn, as text.
	#
	#   pn         the position of the feature, from 1
	#   returns    text, "" when the file gives none, "242" for Fiji in the 110m world
	#   see        NameOf, IndexOfName
	def IdOf(pn)
		return @aFeat[pn][2]

	# Returns the properties the file gives feature pn.
	#
	#   pn         the position of the feature, from 1
	#   returns    a hash list of the file's own keys and values, [ ] when it has none
	#   see        PropertyOf, NameOf
	def PropertiesOf(pn)
		return @aFeat[pn][3]

	# Returns one property of feature pn, the value a map is coloured by.
	#
	#   pn         the position of the feature, from 1
	#   pcKey      the property's key, case as in the file
	#   returns    the value as the file wrote it, a number or text; "" when the feature lacks the
	#              key
	#   see        HasProperty, PropertiesOf
	def PropertyOf(pn, pcKey)
		_p_ = @aFeat[pn][3]
		if isList(_p_) and HasKey(_p_, pcKey)  return _p_[pcKey]  ok
		return ""

	# TRUE if feature pn carries the property pcKey.
	#
	#   pn         the position of the feature, from 1
	#   pcKey      the property's key, case as in the file
	#   returns    TRUE or FALSE
	#   see        PropertyOf
	def HasProperty(pn, pcKey)
		_p_ = @aFeat[pn][3]
		return isList(_p_) and HasKey(_p_, pcKey)

	# Returns what the file calls feature pn: the first of the usual name keys it carries, else its id.
	#
	#   pn         the position of the feature, from 1
	#   returns    text; "Agadez" for Niger's first region, whose key is shapeName
	#   note       The keys tried, in order: name, NAME, Name, nom, admin, ADMIN, NAME_EN,
	#              NAME_LONG, name_en, shapeName, shapeName_en, title, label, id
	#   see        IndexOfName, IdOf, StzGeoNameKeys
	#@ aka  what the file calls it: the first of the usual name keys it carries, or its id, or "" -- and the caller who knows better says so themselves
	def NameOf(pn)
		_p_ = @aFeat[pn][3]
		if isList(_p_)
			_k_ = StzGeoNameKeys()
			for _i_ = 1 to len(_k_)
				if HasKey(_p_, _k_[_i_])  return "" + _p_[_k_[_i_]]  ok
			next
		ok
		return @aFeat[pn][2]

	# Returns the position of the feature the file calls pcName, ignoring case and surrounding blanks.
	#
	#   pcName     the name to look for, as NameOf would give it
	#   returns    a number from 1, or 0 when no feature has that name
	#   note       Exact match only: no accents folded, no alias. The atlas does that
	#   see        NameOf, StzGeoAtlas.IndexOf
	def IndexOfName(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		for _i_ = 1 to len(@aFeat)
			if StzLower(ring_trim(This.NameOf(_i_))) = _c_  return _i_  ok
		next
		return 0

	# Returns every part of feature pn, each part a list of rings.
	#
	#   pn         the position of the feature, from 1
	#   returns    a list of parts; each part is a list of flat lon, lat lists, the first the outer
	#              edge and the rest holes
	#   note       Every ring is closed, whichever file it came from
	#   see        RingsOf, PartCount
	def PartsOf(pn)
		return @aFeat[pn][4]

	# Returns how many parts feature pn has: 1 for a country in one piece, more with islands.
	#
	#   pn         the position of the feature, from 1
	#   returns    a number, 3 for France in the 110m world (Guyane, the mainland, Corsica)
	#   see        PartsOf, LargestPartOf
	def PartCount(pn)
		return len(@aFeat[pn][4])

	# Returns the rings of one part of feature pn.
	#
	#   pn         the position of the feature, from 1
	#   pnPart     the position of the part, from 1
	#   returns    a list of flat lon, lat lists: the first is the outer edge and every one after it
	#              is a hole
	#   note       Raises an error when pnPart is past the last part
	#   see        OuterRingOf, PartsOf
	#@ aka  a part's rings: [1] is the outer edge, every one after it is a HOLE
	def RingsOf(pn, pnPart)
		return @aFeat[pn][4][pnPart]

	# Returns the outer edge of one part of feature pn.
	#
	#   pn         the position of the feature, from 1
	#   pnPart     the position of the part, from 1
	#   returns    a flat list lon, lat, lon, lat, ..., closed
	#   see        RingsOf, LargestPartOf
	def OuterRingOf(pn, pnPart)
		return @aFeat[pn][4][pnPart][1]

	# Returns how many holes feature pn has, over all its parts.
	#
	#   pn         the position of the feature, from 1
	#   returns    a number, 1 for South Africa in the 110m world, the hole being Lesotho
	#   see        RingsOf, Contains
	def HoleCountOf(pn)
		_n_ = 0
		_a_ = @aFeat[pn][4]
		for _i_ = 1 to len(_a_)
			_n_ += len(_a_[_i_]) - 1
		next
		return _n_

	# Returns every place of feature pn, holes included, as one flat list.
	#
	#   pn         the position of the feature, from 1
	#   returns    a flat list lon, lat, lon, lat, ...
	#   note       What the FitTo methods of stzGeoProjection take
	#   see        AllPoints, BoundsOf
	#@ aka  every lon/lat this feature holds, flat -- what FitToPoints takes
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

	# Returns every place of every feature as one flat list.
	#
	#   returns    a flat list lon, lat, lon, lat, ...
	#   see        PointsOf, Bounds
	def AllPoints()
		_a_ = []
		for _i_ = 1 to len(@aFeat)
			_p_ = This.PointsOf(_i_)
			for _k_ = 1 to len(_p_)  _a_ + _p_[_k_]  next
		next
		return _a_

	# Returns the box around feature pn, in longitude and latitude.
	#
	#   pn         the position of the feature, from 1
	#   returns    a list [ lonMin, latMin, lonMax, latMax ] in degrees, [ 0, 0, 0, 0 ] for a
	#              feature with no point
	#   note       A feature that crosses the antimeridian, such as Fiji or Russia, has a box 360
	#              degrees wide: its middle is then no place at all
	#   see        Bounds, IndicesWithin
	#@ aka  [ lonMin, latMin, lonMax, latMax ]
	def BoundsOf(pn)
		return _GeoLonLatBounds(This.PointsOf(pn))

	# Returns the box around the whole set, in longitude and latitude.
	#
	#   returns    a list [ lonMin, latMin, lonMax, latMax ] in degrees; [ 0.17, 11.70, 16.00, 23.53
	#              ] for Niger
	#   see        BoundsOf, AllPoints
	def Bounds()
		return _GeoLonLatBounds(This.AllPoints())

	# Returns the area of feature pn in square kilometres, measured on WGS84, outer rings added and holes taken out.
	#
	#   pn         the position of the feature, from 1
	#   returns    a number of km2; 621917.6 for Niger's Agadez region
	#   note       Meaningful for polygons only
	#   see        AreasKm2, AreaKm2
	#@ aka  the biggest part by point count -- the mainland, and the only thing DN24b's reader ever kept A FEATURE'S AREA ON THE SPHERE, km2, with its holes taken out and all its parts added in. This lived in stzGeoMap.ValuesFromArea and moved here when the point patterns (GE7a) needed a window's area and the map's own copy would have been a second one -- duplicated logic diverges, and it diverges in cost fir
	def AreaKm2Of(pn)
		_s_ = 0
		for _k_ = 1 to This.PartCount(pn)
			_r_ = This.RingsOf(pn, _k_)
			if len(_r_) = 0  loop  ok
			_s_ += StzGeoRingAreaKm2(_r_[1])
			for _h_ = 2 to len(_r_)
				_s_ -= StzGeoRingAreaKm2(_r_[_h_])
			next
		next
		return _s_

	# Returns the area of every feature, in the features' own order.
	#
	#   returns    a list of numbers in km2
	#   see        AreaKm2Of, AreaKm2
	#@ aka  every feature's area, in feature order
	def AreasKm2()
		_a_ = []
		for _i_ = 1 to This.Count()  _a_ + This.AreaKm2Of(_i_)  next
		return _a_

	# Returns the area of the whole set, the sum over its features, in square kilometres.
	#
	#   returns    a number of km2; 1183623.9 for Niger's eight regions
	#   note       The window area a point pattern's density divides by
	#   see        AreasKm2, stzGeoPoints.AreaKm2
	#@ aka  the whole set's area: what a point pattern observed over all of it divides by
	def AreaKm2()
		_s_ = 0
		for _i_ = 1 to This.Count()  _s_ += This.AreaKm2Of(_i_)  next
		return _s_

	# Returns the position of the part of feature pn whose outer ring has the most points: the mainland.
	#
	#   pn         the position of the feature, from 1
	#   returns    a number from 1
	#   note       Counts points, not area
	#   see        PartCount, OuterRingOf
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

	# TRUE if the place lies inside feature pn: in one of its parts and in none of that part's holes.
	#
	#   pn         the position of the feature, from 1
	#   pnLon      longitude of the place in degrees east
	#   pnLat      latitude of the place in degrees north
	#   returns    TRUE or FALSE
	#   note       LONGITUDE FIRST. On the fixtures a point in Arda's lake answers FALSE
	#   see        IndexAt, PartContains
	#@ aka  is this place inside this feature? Any part counts; a hole excludes.
	def Contains(pn, pnLon, pnLat)
		if len(@aBox) >= pn
			_bx_ = @aBox[pn]
			if pnLon < _bx_[1] or pnLon > _bx_[3] or pnLat < _bx_[2] or pnLat > _bx_[4]
				return FALSE
			ok
		ok
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

	# TRUE if the place lies inside one part of feature pn and in none of that part's holes.
	#
	#   pn         the position of the feature, from 1
	#   pnK        the position of the part, from 1
	#   pnLon      longitude of the place in degrees east
	#   pnLat      latitude of the place in degrees north
	#   returns    TRUE or FALSE
	#   note       FALSE when pnK is past the last part
	#   see        Contains
	#@ aka  is this place inside ONE PART of this feature? What a label placer asks: a name belongs in the part it was measured against, not merely somewhere in the country.
	def PartContains(pn, pnK, pnLon, pnLat)
		_a_ = @aFeat[pn][4]
		if pnK < 1 or pnK > len(_a_)  return FALSE  ok
		if NOT StzGeoRingContains(_a_[pnK][1], pnLon, pnLat)  return FALSE  ok
		for _j_ = 2 to len(_a_[pnK])
			if StzGeoRingContains(_a_[pnK][_j_], pnLon, pnLat)  return FALSE  ok
		next
		return TRUE

	# Returns the position of the first feature that contains a place: what a click asks.
	#
	#   pnLon      longitude of the place in degrees east
	#   pnLat      latitude of the place in degrees north
	#   returns    a number from 1, or 0 for the sea or for nothing
	#   note       LONGITUDE FIRST. A place on a shared border goes to the first feature that claims
	#              it
	#   see        Contains, stzGeoMap.FeatureAt
	#@ aka  which feature is at this place, or 0 -- what a click will ask
	def IndexAt(pnLon, pnLat)
		for _i_ = 1 to len(@aFeat)
			if This.Contains(_i_, pnLon, pnLat)  return _i_  ok
		next
		return 0

	# Returns a new set made of the features at the given positions, in that order.
	#
	#   paIndices   a list of feature positions, from 1
	#   returns     a stzGeoFeatures; positions out of range are skipped
	#   see         Within, Adopt
	#@ aka  -- taking part of a file ------------------------------------------------
	def Subset(paIndices)
		_o_ = new stzGeoFeatures
		_a_ = []
		for _i_ = 1 to len(paIndices)
			_k_ = paIndices[_i_]
			if _k_ < 1 or _k_ > len(@aFeat)  loop  ok
			_a_ + @aFeat[_k_]
		next
		_o_.Adopt(_a_)
		return _o_

	# Replaces the features with raw records and recomputes the boxes.
	#
	#   paFeat     a list of records [ kind, id, properties, parts ] as Subset builds them
	#   returns    nothing; the features are stored
	#   note       Used by Subset
	#   see        Subset
	def Adopt(paFeat)
		@aFeat = paFeat
		@nSkipped = 0
		This._Box()

	# the boxes, once, after the features are in place
	def _Box()
		@aBox = []
		for _i_ = 1 to len(@aFeat)
			@aBox + This.BoundsOf(_i_)
		next

	# Returns the positions of the features whose bounding box has its middle inside a box of longitude and latitude.
	#
	#   pnLon0     western edge in degrees east
	#   pnLat0     southern edge in degrees north
	#   pnLon1     eastern edge in degrees east
	#   pnLat1     northern edge in degrees north
	#   returns    a list of numbers
	#   warning    Defect: a feature across the antimeridian has a box 360 degrees wide whose middle
	#              is longitude 0, so Fiji is taken by a window around Africa.
	#   see        Within, BoundsOf
	#@ aka  THE FEATURES WHOSE MIDDLE FALLS IN A BOX, by index. What "metropolitan France" means to a file that also carries Réunion and Guyane: not a political statement, a WINDOW -- the caller says which piece of the world they are drawing, and the file is unchanged.
	def IndicesWithin(pnLon0, pnLat0, pnLon1, pnLat1)
		_a_ = []
		for _i_ = 1 to len(@aFeat)
			_b_ = This.BoundsOf(_i_)
			if len(_b_) < 4  loop  ok
			_cx_ = (_b_[1] + _b_[3]) / 2
			_cy_ = (_b_[2] + _b_[4]) / 2
			if _cx_ >= pnLon0 and _cx_ <= pnLon1 and _cy_ >= pnLat0 and _cy_ <= pnLat1
				_a_ + _i_
			ok
		next
		return _a_

	# Returns a new set of the features whose bounding box has its middle inside a box of longitude and latitude.
	#
	#   pnLon0     western edge in degrees east
	#   pnLat0     southern edge in degrees north
	#   pnLon1     eastern edge in degrees east
	#   pnLat1     northern edge in degrees north
	#   returns    a stzGeoFeatures
	#   note       Metropolitan France is a window, not a political claim
	#   warning    Defect: the same antimeridian trap as IndicesWithin: Fiji is taken by a window
	#              around Africa.
	#   see        IndicesWithin, Subset
	def Within(pnLon0, pnLat0, pnLon1, pnLat1)
		return This.Subset(This.IndicesWithin(pnLon0, pnLat0, pnLon1, pnLat1))

	# Returns the polygons as the regions the older choropleth builder takes, each from its largest part.
	#
	#   pcValueKey   the property that gives each region's value
	#   returns      a list of [ name, value, flat outer ring ]; the value is "" when the feature
	#                lacks pcValueKey; lines and points are left out
	#   see          PropertyOf, LargestPartOf
	#@ aka  the regions the choropleth builder takes, so a file read here can go straight into DN24's picture: [ name, value, flatOuterRing ] each, from the LARGEST part of every feature
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
