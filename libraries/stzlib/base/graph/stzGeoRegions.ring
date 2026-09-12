#---------------------------------------------------------------------------#
#  STZGEOREGIONS -- real boundaries, without an atlas                        #
#---------------------------------------------------------------------------#
#
#     aRegions = StzGeoRegionsFromJson(read("provinces.geojson"), "name", "density")
#     oMap = StzChoroplethDiagram(oFont, "People per km2", aRegions, [ 0, 50, 100, 200, 400 ])
#
# THE GAP THIS CLOSES, and the one it deliberately does not. DN24 draws a
# choropleth from polygons the AUTHOR gives, in map units, and refuses to
# fetch anything from an atlas. That refusal stands: this file vendors no
# boundary data, names no country, and carries no opinion about where a
# border lies. What it does is let an author who HAS boundary data -- their
# own, their employer's, or a public dataset they chose and can account
# for -- turn it into the shape the builder already takes, without writing
# the conversion by hand for every map.
#
# WHY A PROJECTION LIVES HERE AT ALL, when the plan says a projection is
# the author's business. Because a choropleth ENCODES A QUANTITY AS AREA'S
# COLOUR, and a projection that distorts area makes the picture argue
# against its own legend: on Mercator, Greenland reads as large as Africa
# while carrying a fourteenth of its people. So the default here is an
# EQUAL-AREA projection, and it is a default rather than a law -- an
# author who knows their extent is small may ask for the plain one.
#
# WHERE THE WORK RUNS, measured rather than assumed. Projecting 100,000
# points in Ring costs 73 ms on this machine; a whole world at the coarsest
# usable scale is 10,000 to 25,000 points, so about 7 to 18 ms. The
# engine-first rule is for work whose cost grows with a corpus, and this
# does not reach it. Ring keeps it, and the number is written here so the
# next person can argue with the decision rather than re-take it.

# How many features the last read could not use. A global because the
# reader answers a LIST of regions and the count is a second answer; it is
# initialised HERE, at load, because Ring raises on reading a global that
# was never written and a guard asking before the first read would have
# found that the hard way.
$nStzGeoSkipped = 0
# the standard parallel the last read actually used, so a caller can see
# what "from the data" decided rather than infer it
$nStzGeoLat0 = 0

func StzGeoProjections()
	return [ :EqualArea, :Equirectangular ]

# LAMBERT CYLINDRICAL EQUAL-AREA, which is the honest default for a map
# that colours areas: x = lon * cos(lat0), y = sin(lat). Every region's
# drawn area is proportional to its true area, so a reader comparing two
# shades is comparing two quantities and not two distortions. The standard
# parallel lat0 is where the map is also shape-true; 0 is the equator and
# the caller's own mid-latitude is the usual better answer.
#
# EQUIRECTANGULAR is the naive one: x = lon * cos(lat0), y = lat. It keeps
# north-south distances honest and stretches area away from lat0. Offered
# because over a small extent the difference is invisible and the numbers
# stay readable, and refused as a default for the reason above.
# BOTH AXES IN ONE UNIT, which cost a picture to learn. The first version
# wrote x in DEGREES and y as a SINE -- a pure number -- so a country 12
# degrees wide and 6 tall came out 12 units by 0.065, a 184:1 hairline.
# Every polygon drew, two pixels tall, and every name collided with the
# next. A projection's two axes must share a unit or it is not a
# projection, and no test of the numbers alone would have said so.
func StzGeoProject(pnLon, pnLat, pcKind, pnLat0)
	_k_ = StzLower(ring_trim("" + pcKind))
	_r_ = 3.141592653589793 / 180
	_cs_ = cos(pnLat0 * _r_)
	if _cs_ = 0  _cs_ = 0.000001  ok
	if _k_ = "equirectangular"
		return [ pnLon * _r_ * _cs_, pnLat * _r_ ]
	but _k_ = "equalarea"
		return [ pnLon * _r_ * _cs_, sin(pnLat * _r_) / _cs_ ]
	ok
	stzraise("StzGeoProject: '" + _k_ + "' is not a projection this file " +
		"knows -- equalarea or equirectangular.")

# EVERY POINT OF ONE RING, projected. The ring arrives as GeoJSON writes
# it, [ [lon, lat], ... ], and leaves as the flat [ x1, y1, x2, y2, ... ]
# the choropleth builder takes.
func StzGeoProjectRing(paRing, pcKind, pnLat0)
	_a_ = []
	_n_ = len(paRing)
	for _i_ = 1 to _n_
		_p_ = paRing[_i_]
		if NOT (isList(_p_) and len(_p_) >= 2)  loop  ok
		_xy_ = StzGeoProject(_p_[1], _p_[2], pcKind, pnLat0)
		_a_ + _xy_[1]
		_a_ + _xy_[2]
	next
	return _a_

func StzGeoRegionsFromJson(pcJson, pcNameKey, pcValueKey)
	return StzGeoRegionsFromJsonXT(pcJson, pcNameKey, pcValueKey, :EqualArea, :Auto)

# A GeoJSON FeatureCollection as the regions the choropleth draws:
# [ [ name, value, [ x1, y1, ... ] ], ... ]. The name and the value are
# read from the feature's own properties by the keys the caller names,
# because no two datasets agree on what to call either.
#
# WHAT IS TAKEN AND WHAT IS LEFT, said plainly. A Polygon contributes its
# OUTER ring; a MultiPolygon contributes the outer ring of its LARGEST
# part. Holes are dropped and so are the smaller islands of a multi-part
# region -- the choropleth draws one simple polygon per region, and a
# reader is better served by a mainland than by a shape that closes
# through its own holes. A feature with no geometry, fewer than three
# points, or no name is SKIPPED and counted, never guessed at: the count
# comes back so a caller knows their map is short before they look at it.
func StzGeoRegionsFromJsonXT(pcJson, pcNameKey, pcValueKey, pcKind, pnLat0)
	_aOut_ = []
	_nSkip_ = 0
	if NOT (isString(pcJson) and len(ring_trim(pcJson)) > 0)
		stzraise("StzGeoRegionsFromJson: give the GeoJSON text to read.")
	ok
	_aJ_ = JsonToList(pcJson)
	if NOT isList(_aJ_)
		stzraise("StzGeoRegionsFromJson: that is not JSON this reader could parse.")
	ok
	if NOT HasKey(_aJ_, :features)
		stzraise("StzGeoRegionsFromJson: no 'features' -- this reader takes a " +
			"GeoJSON FeatureCollection, which is what an export gives you.")
	ok
	_aF_ = _aJ_[:features]
	_nF_ = len(_aF_)

	# THE STANDARD PARALLEL, FROM THE DATA unless the caller names one.
	# A cylindrical equal-area map is area-true everywhere and shape-true
	# only at its standard parallel, so leaving it at the equator draws a
	# country at 50 degrees north three times too wide -- correct in the
	# quantity it encodes and wrong in every shape a reader recognises.
	# The data's own middle latitude is the answer a caller would have
	# given, so it is what they get when they say nothing.
	_nLat0_ = pnLat0
	if NOT isNumber(_nLat0_)
		# FROM THE FEATURES THAT WILL BE KEPT, not from every feature in the
		# file. A feature this reader skips -- no name, no geometry, too few
		# points -- draws nothing, and letting one drag the standard parallel
		# distorts the map that IS drawn. The guard caught this: one nameless
		# feature near the equator pulled a country at fifty north down to a
		# parallel of twenty-six.
		_nLo_ = 91  _nHi_ = -91
		for _i_ = 1 to _nF_
			_f0_ = _aF_[_i_]
			if NOT (isList(_f0_) and HasKey(_f0_, :geometry) and HasKey(_f0_, :properties))  loop  ok
			_p0_ = _f0_[:properties]
			if NOT (isList(_p0_) and HasKey(_p0_, pcNameKey))  loop  ok
			_r0_ = _GeoOuterRing(_f0_[:geometry])
			if len(_r0_) < 3  loop  ok
			for _j_ = 1 to len(_r0_)
				_pt_ = _r0_[_j_]
				if NOT (isList(_pt_) and len(_pt_) >= 2)  loop  ok
				if _pt_[2] < _nLo_  _nLo_ = _pt_[2]  ok
				if _pt_[2] > _nHi_  _nHi_ = _pt_[2]  ok
			next
		next
		_nLat0_ = 0
		if _nHi_ >= _nLo_  _nLat0_ = (_nLo_ + _nHi_) / 2  ok
	ok
	$nStzGeoLat0 = _nLat0_

	for _i_ = 1 to _nF_
		_f_ = _aF_[_i_]
		if NOT isList(_f_)  _nSkip_++  loop  ok
		if NOT (HasKey(_f_, :geometry) and HasKey(_f_, :properties))  _nSkip_++  loop  ok
		_p_ = _f_[:properties]
		if NOT (isList(_p_) and HasKey(_p_, pcNameKey))  _nSkip_++  loop  ok
		_cName_ = "" + _p_[pcNameKey]
		_val_ = ""
		if HasKey(_p_, pcValueKey)  _val_ = _p_[pcValueKey]  ok
		_aRing_ = _GeoOuterRing(_f_[:geometry])
		if len(_aRing_) < 3  _nSkip_++  loop  ok
		_aXY_ = StzGeoProjectRing(_aRing_, pcKind, _nLat0_)
		if len(_aXY_) < 6  _nSkip_++  loop  ok
		_aOut_ + [ _cName_, _val_, _aXY_ ]
	next
	$nStzGeoSkipped = _nSkip_
	return _aOut_

# how many features the last read could not use -- a record that drops
# counts what it dropped
func StzGeoSkippedCount()
	return $nStzGeoSkipped

func StzGeoStandardParallel()
	return $nStzGeoLat0

func _GeoOuterRing(paGeom)
	if NOT (isList(paGeom) and HasKey(paGeom, :type) and HasKey(paGeom, :coordinates))
		return []
	ok
	_t_ = StzLower("" + paGeom[:type])
	_c_ = paGeom[:coordinates]
	if NOT isList(_c_)  return []  ok
	if _t_ = "polygon"
		if len(_c_) = 0  return []  ok
		return _c_[1]
	but _t_ = "multipolygon"
		# the LARGEST part, by point count -- a proxy for area that needs no
		# arithmetic and picks the mainland over its islands every time a
		# mainland is drawn in more detail, which is every time
		_best_ = []
		for _i_ = 1 to len(_c_)
			_part_ = _c_[_i_]
			if NOT (isList(_part_) and len(_part_) > 0)  loop  ok
			_ring_ = _part_[1]
			if isList(_ring_) and len(_ring_) > len(_best_)  _best_ = _ring_  ok
		next
		return _best_
	ok
	return []
