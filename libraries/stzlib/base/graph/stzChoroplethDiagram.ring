#=====================================================================#
#  STZCHOROPLETHDIAGRAM -- DN24: a choropleth map is regions coloured  #
#  by a value, a scale of classes, and a legend that says which is which #
#=====================================================================#
/*
	THE LAST DOMAIN OF THE LIST, and the first whose colour is the datum.
	A choropleth map paints each region by where its value falls among a
	few classes, darker meaning more, and a legend beside the map says
	what each shade stands for. The regions are polygons the author gives
	in map units, the classes are the edges the author gives, and every
	pixel and every fill follows from those by arithmetic. Nothing is
	solved; the solver reports "nothing to lay out"; and the picture is
	still a mathematical diagram -- it answers Fact(), carries marks, sits
	in a storyboard, is judged by the one gate and renders through
	Rendition() like everything else.

	WHAT A CHOROPLETH IS HERE:

	    DOMAIN     Region, a polygon with a name and a value; Swatch, one
	               class of the legend; Legend, its title; Value, the
	               number written under a region's name.

	    SUBSTANCE  built from a quantity's name, regions -- [ name, value,
	               [ x1, y1, x2, y2, ... ] ] with "" for no value -- the
	               class edges -- [ e0, e1, ..., en ], ascending, n classes
	               -- and a palette of n colours, or none for the primary
	               hue stepped from light to dark. The builder fits the map
	               beside the legend, finds each region's class and its
	               centroid, and puts every number on its object.

	    STYLE      a region as its polygon filled in its class's colour
	               with its name and value at its centroid; a swatch per
	               class in the legend with its range; a region without a
	               value in a pale grey, and a swatch saying so.

	WHAT THE DOMAIN OWES THE GATE -- the mistakes people make in a map,
	and none of them is visible in a drawing that draws what it is given:

	    every_region_has_a_value     a region with no value is a hole in
	                                 the map, and must say so
	    values_fall_in_the_classes   a value beyond the last edge, or
	                                 below the first, has no colour
	    darker_means_more            the palette darkens with the class
	    every_class_has_a_region     a class no region falls in is a
	                                 colour the legend promises for nothing

	Each names the regions and the classes by the names and edges the
	author gave, and each registers itself into the math governance from
	this file.

	WHAT IS SAID PLAINLY: regions are simple polygons the author gives,
	not fetched from any atlas; a projection is the author's business;
	classes are the author's edges, not computed quantiles; the map has
	no north arrow, no scale bar and no coastline beyond the regions.
*/

StzRegisterMathRuleSet("choropleth", StzChoroplethRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzChoroplethDomain()
	_o_ = new stzMathDomain("choropleth")
	_o_.AddType("Region")
	_o_.AddType("Swatch")
	_o_.AddType("Legend")
	_o_.AddType("Value")
	# a region's class, and a swatch's -- one predicate per class, up to
	# nine, since the style paints by predicate
	for _i_ = 1 to StzChoroplethMaxClasses()
		_o_.AddPredicate("C" + _i_, [ "Region" ])
		_o_.AddPredicate("K" + _i_, [ "Swatch" ])
		_o_.AddPredicate("V" + _i_, [ "Value" ])
	next
	# a region's count of vertices: a polygon's count is a literal of the
	# style, so the style paints each count by its own rule
	for _i_ = 3 to 24
		_o_.AddPredicate("N" + _i_, [ "Region" ])
	next
	_o_.AddPredicate("NoData", [ "Region" ])
	_o_.AddPredicate("NoDataSwatch", [ "Swatch" ])
	# the legend's entry for what lies beyond the classes
	_o_.AddPredicate("OutsideSwatch", [ "Swatch" ])
	# A FAULT IS DRAWN, NOT HIDDEN: a value outside the classes, a class
	# with no region, a swatch lighter than the one before it
	_o_.AddPredicate("Outside", [ "Region" ])
	_o_.AddPredicate("Empty", [ "Swatch" ])
	_o_.AddPredicate("Misordered", [ "Swatch" ])
	return _o_

func StzChoroplethMaxClasses()
	return 9

# THE HOUSE TYPE SIZE, and the paper that carries it. This drew names at
# 12 points and values at 10 on a 760-wide sheet, which the Principal has
# now called unreadable on three domains: "as usual, text is very small".
# A catalogue picture is read at the DRAKON catalogue's scale, so the type
# is raised to it and the paper and the legend column are widened to carry
# it -- raising type on a sheet sized for smaller type only moves the
# problem into the collisions the rules then report.
func StzChoroplethWidth()
	return 1180

func StzChoroplethLegendWidth()
	return 300

func StzChoroplethMargin()
	return 30

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM REGIONS, EDGES AND A PALETTE                    #
#---------------------------------------------------------------------#

func StzChoroplethFromRegions(pcQuantity, paRegions, paEdges)
	return StzChoroplethFromRegionsXT(pcQuantity, paRegions, paEdges, [])

# paRegions: [ name, value, [ x1, y1, ... ] ] each, "" for no value;
# paEdges: the class edges ascending, n + 1 of them for n classes;
# paPalette: n colours, or [] for the primary hue from light to dark.
# Objects are r1..rN, v1..vN, l1..ln (and lnd where a region has no
# value), and lg; a region's LABEL is its name.
func StzChoroplethFromRegionsXT(pcQuantity, paRegions, paEdges, paPalette)
	_oS_ = new stzMathSubstance(StzChoroplethDomain())
	_nR_ = len(paRegions)
	if _nR_ = 0
		stzraise("StzChoroplethFromRegions: a map needs at least one region.")
	ok
	_nE_ = len(paEdges)
	if _nE_ < 2 or _nE_ > StzChoroplethMaxClasses() + 1
		stzraise("StzChoroplethFromRegions: the classes need two to ten edges -- " + _nE_ + " given.")
	ok
	for _i_ = 1 to _nE_
		if NOT isNumber(paEdges[_i_])
			stzraise("StzChoroplethFromRegions: a class edge is a number.")
		ok
		if _i_ > 1 and paEdges[_i_] <= paEdges[_i_ - 1]
			stzraise("StzChoroplethFromRegions: the class edges must rise -- " + paEdges[_i_ - 1] +
				" is followed by " + paEdges[_i_] + ".")
		ok
	next
	_nC_ = _nE_ - 1
	_aPal_ = []
	if isList(paPalette) and len(paPalette) > 0
		if len(paPalette) != _nC_
			stzraise("StzChoroplethFromRegions: " + _nC_ + " classes need " + _nC_ + " colours -- " + len(paPalette) + " given.")
		ok
		for _i_ = 1 to _nC_  _aPal_ + StzResolveColor("" + paPalette[_i_])  next
	else
		_aPal_ = StzChoroplethPaletteFor(_nC_)
	ok

	# the map's extent, and the fit beside the legend
	_bAny_ = FALSE
	_nX0_ = 0  _nY0_ = 0  _nX1_ = 0  _nY1_ = 0
	for _i_ = 1 to _nR_
		_a_ = paRegions[_i_]
		if len(_a_) < 3 or NOT isList(_a_[3]) or len(_a_[3]) < 6 or len(_a_[3]) % 2 = 1
			stzraise("StzChoroplethFromRegions: region " + _i_ + " needs a name, a value and at least three points.")
		ok
		if len(_a_[3]) > 2 * 24
			stzraise("StzChoroplethFromRegions: region '" + _a_[1] + "' has more than twenty-four points.")
		ok
		for _j_ = 1 to _i_ - 1
			if StzLower(ring_trim("" + paRegions[_j_][1])) = StzLower(ring_trim("" + _a_[1]))
				stzraise("StzChoroplethFromRegions: two regions are named '" + _a_[1] + "' -- a name must say which.")
			ok
		next
		_aP_ = _a_[3]
		for _j_ = 1 to len(_aP_) step 2
			if NOT isNumber(_aP_[_j_]) or NOT isNumber(_aP_[_j_ + 1])
				stzraise("StzChoroplethFromRegions: region '" + _a_[1] + "' has a point that is not two numbers.")
			ok
			if NOT _bAny_
				_nX0_ = _aP_[_j_]  _nX1_ = _aP_[_j_]  _nY0_ = _aP_[_j_ + 1]  _nY1_ = _aP_[_j_ + 1]
				_bAny_ = TRUE
			ok
			if _aP_[_j_] < _nX0_  _nX0_ = _aP_[_j_]  ok
			if _aP_[_j_] > _nX1_  _nX1_ = _aP_[_j_]  ok
			if _aP_[_j_ + 1] < _nY0_  _nY0_ = _aP_[_j_ + 1]  ok
			if _aP_[_j_ + 1] > _nY1_  _nY1_ = _aP_[_j_ + 1]  ok
		next
	next
	_nM_ = StzChoroplethMargin()
	_nMapW_ = StzChoroplethWidth() - StzChoroplethLegendWidth() - 2 * _nM_
	_nK_ = _nMapW_ / (_nX1_ - _nX0_)
	_nH_ = ceil((_nY1_ - _nY0_) * _nK_ + 2 * _nM_)

	# THE REGIONS: each in its class, its centroid found, its points in pixels
	_anCount_ = []
	for _c_ = 1 to _nC_  _anCount_ + 0  next
	_bNoData_ = FALSE
	for _i_ = 1 to _nR_
		_a_ = paRegions[_i_]
		_cR_ = "r" + _i_
		_oS_.Declare("Region", _cR_)
		_oS_.Label(_cR_, "" + _a_[1])
		_aP_ = _a_[3]
		_nN_ = len(_aP_) / 2
		_oS_.SetData(_cR_, "n", _nN_)
		_oS_.Assert("N" + _nN_, [ _cR_ ])
		for _j_ = 1 to _nN_
			_oS_.SetData(_cR_, "x" + _j_, _nM_ + (_aP_[_j_ * 2 - 1] - _nX0_) * _nK_)
			_oS_.SetData(_cR_, "y" + _j_, _nM_ + (_aP_[_j_ * 2] - _nY0_) * _nK_)
		next
		_aCt_ = _ChCentroid(_aP_)
		_oS_.SetData(_cR_, "cx", _nM_ + (_aCt_[1] - _nX0_) * _nK_)
		_oS_.SetData(_cR_, "cy", _nM_ + (_aCt_[2] - _nY0_) * _nK_)
		_oS_.SetData(_cR_, "class", 0)
		_oS_.Declare("Value", "v" + _i_)
		_oS_.SetData("v" + _i_, "cx", _oS_.DataOf(_cR_, "cx"))
		_oS_.SetData("v" + _i_, "cy", _oS_.DataOf(_cR_, "cy") + 18)
		if NOT isNumber(_a_[2])
			_oS_.SetData(_cR_, "value", 0)
			_oS_.Assert("NoData", [ _cR_ ])
			_oS_.Label("v" + _i_, "no data")
			_bNoData_ = TRUE
			loop
		ok
		_oS_.SetData(_cR_, "value", _a_[2])
		_oS_.Label("v" + _i_, StzFactNumText(_a_[2]))
		_nCl_ = _ChClassOf(_a_[2], paEdges)
		if _nCl_ = 0
			_oS_.Assert("Outside", [ _cR_ ])
		else
			_oS_.SetData(_cR_, "class", _nCl_)
			_oS_.Assert("C" + _nCl_, [ _cR_ ])
			_oS_.Assert("V" + _nCl_, [ "v" + _i_ ])
			_anCount_[_nCl_]++
		ok
	next

	# THE LEGEND: its title, a swatch per class with its range, then an
	# entry for whatever lies beyond the classes, then a swatch for no
	# data where the map has a hole. THE LEGEND SAYS WHY. The Principal
	# read the witness cold: "the centre is 450 and it is not in the
	# legend; and some entries of the legend are not on the map". Both
	# were the planted faults, rimmed in the fault's colour -- and a rim
	# says something is wrong without saying what. So a class that
	# colours nothing says so after its range, a shade out of order says
	# so, and a value beyond the classes gets an entry of its own in the
	# fault's colour, so that every region on the map is in the legend.
	_nLx_ = StzChoroplethWidth() - StzChoroplethLegendWidth() + 10
	_oS_.Declare("Legend", "lg")
	_oS_.Label("lg", "" + pcQuantity)
	_oS_.SetData("lg", "x", _nLx_)
	_oS_.SetData("lg", "y", _nM_ + 6)
	_oS_.SetData("lg", "classes", _nC_)
	_nRow_ = 0
	for _c_ = 1 to _nC_
		_cL_ = "l" + _c_
		_nRow_++
		_oS_.Declare("Swatch", _cL_)
		_cRange_ = StzFactNumText(paEdges[_c_]) + " - " + StzFactNumText(paEdges[_c_ + 1])
		_cSay_ = _cRange_
		if _anCount_[_c_] = 0  _cSay_ += "  (no region)"  ok
		_bMis_ = _c_ > 1 and StzColorLuminance(_aPal_[_c_]) >= StzColorLuminance(_aPal_[_c_ - 1])
		if _bMis_  _cSay_ += "  (out of order)"  ok
		_oS_.Label(_cL_, _cSay_)
		_oS_.SetData(_cL_, "x", _nLx_ + 11)
		_oS_.SetData(_cL_, "y", _nM_ + 30 + _nRow_ * 40)
		_oS_.SetData(_cL_, "lo", paEdges[_c_])
		_oS_.SetData(_cL_, "hi", paEdges[_c_ + 1])
		_oS_.SetData(_cL_, "index", _c_)
		_oS_.SetData(_cL_, "regions", _anCount_[_c_])
		_oS_.SetData(_cL_, "lum", StzColorLuminance(_aPal_[_c_]))
		_oS_.Assert("K" + _c_, [ _cL_ ])
		if _anCount_[_c_] = 0  _oS_.Assert("Empty", [ _cL_ ])  ok
		if _bMis_  _oS_.Assert("Misordered", [ _cL_ ])  ok
	next
	# what lies beyond the classes, above and below, in the fault's colour
	_nAbove_ = 0  _nBelow_ = 0
	for _i_ = 1 to _nR_
		if NOT _oS_.Holds("Outside", [ "r" + _i_ ])  loop  ok
		if _oS_.DataOf("r" + _i_, "value") > paEdges[_nE_]  _nAbove_++  else  _nBelow_++  ok
	next
	if _nAbove_ > 0
		_nRow_++
		_oS_.Declare("Swatch", "labove")
		_oS_.Label("labove", "above " + StzFactNumText(paEdges[_nE_]) + "  (no class)")
		_ChExtraSwatch(_oS_, "labove", _nLx_ + 11, _nM_ + 30 + _nRow_ * 40, _nAbove_)
		_oS_.Assert("OutsideSwatch", [ "labove" ])
	ok
	if _nBelow_ > 0
		_nRow_++
		_oS_.Declare("Swatch", "lbelow")
		_oS_.Label("lbelow", "below " + StzFactNumText(paEdges[1]) + "  (no class)")
		_ChExtraSwatch(_oS_, "lbelow", _nLx_ + 11, _nM_ + 30 + _nRow_ * 40, _nBelow_)
		_oS_.Assert("OutsideSwatch", [ "lbelow" ])
	ok
	if _bNoData_
		_nRow_++
		_oS_.Declare("Swatch", "lnd")
		_oS_.Label("lnd", "no data")
		_ChExtraSwatch(_oS_, "lnd", _nLx_ + 11, _nM_ + 30 + _nRow_ * 40, 0)
		_oS_.Assert("NoDataSwatch", [ "lnd" ])
	ok
	_nLegH_ = _nM_ + 30 + (_nRow_ + 1) * 40 + 10
	if _nLegH_ > _nH_  _nH_ = _nLegH_  ok
	_oS_.SetData("lg", "paperw", StzChoroplethWidth())
	_oS_.SetData("lg", "paperh", _nH_)
	return _oS_

# a legend entry that is no class: no index, no range
func _ChExtraSwatch(poS, pcL, pnX, pnY, pnRegions)
	poS.SetData(pcL, "x", pnX)
	poS.SetData(pcL, "y", pnY)
	poS.SetData(pcL, "index", 0)
	poS.SetData(pcL, "regions", pnRegions)
	poS.SetData(pcL, "lum", 0)
	poS.SetData(pcL, "lo", 0)
	poS.SetData(pcL, "hi", 0)

# a class's range, said as the legend says it, without the reason
func _ChRange(poS, pcL)
	return StzFactNumText(poS.DataOf(pcL, "lo")) + " - " + StzFactNumText(poS.DataOf(pcL, "hi"))

# the class a value falls in: the classes are [ e_i, e_i+1 ), the last
# closed at its top; 0 where the value is outside them all
func _ChClassOf(pnV, paEdges)
	_n_ = len(paEdges) - 1
	for _c_ = 1 to _n_
		if pnV >= paEdges[_c_] and pnV < paEdges[_c_ + 1]  return _c_  ok
	next
	if pnV = paEdges[_n_ + 1]  return _n_  ok
	return 0

# the centroid of a simple polygon, by the shoelace; a degenerate
# polygon falls back to the mean of its points
func _ChCentroid(paP)
	_n_ = len(paP) / 2
	_nA_ = 0  _nCx_ = 0  _nCy_ = 0
	for _i_ = 1 to _n_
		_j_ = _i_ + 1
		if _j_ > _n_  _j_ = 1  ok
		_x1_ = paP[_i_ * 2 - 1]  _y1_ = paP[_i_ * 2]
		_x2_ = paP[_j_ * 2 - 1]  _y2_ = paP[_j_ * 2]
		_nX_ = _x1_ * _y2_ - _x2_ * _y1_
		_nA_ += _nX_
		_nCx_ += (_x1_ + _x2_) * _nX_
		_nCy_ += (_y1_ + _y2_) * _nX_
	next
	if fabs(_nA_) < 0.000001
		_nSx_ = 0  _nSy_ = 0
		for _i_ = 1 to _n_  _nSx_ += paP[_i_ * 2 - 1]  _nSy_ += paP[_i_ * 2]  next
		return [ _nSx_ / _n_, _nSy_ / _n_ ]
	ok
	return [ _nCx_ / (3 * _nA_), _nCy_ / (3 * _nA_) ]

# THE DEFAULT PALETTE: the primary hue stepped from light to dark, one
# step per class, hue-stable by the colour system's own ramp
func StzChoroplethPaletteFor(pnClasses)
	_a_ = []
	_cHue_ = StzResolveColor("primary")
	if _cHue_ = "" or StzLeft(_cHue_, 1) != "#"  _cHue_ = "#4D4DC9"  ok
	# lightness on the ramp's own scale, 0 to 1: from a pale tint to a
	# deep shade, the same hue throughout
	for _c_ = 1 to pnClasses
		_nL_ = 0.90
		if pnClasses > 1  _nL_ = 0.90 - 0.55 * (_c_ - 1) / (pnClasses - 1)  ok
		_a_ + StzColorAtLightness(_cHue_, _nL_)
	next
	return _a_

func StzChoroplethPaperOf(poSubstance)
	return [ poSubstance.DataOf("lg", "paperw"), poSubstance.DataOf("lg", "paperh") ]

#---------------------------------------------------------------------#
#  THE STYLE -- no constraint, no unknown, every position a datum      #
#---------------------------------------------------------------------#

# paPalette: the resolved colours, one per class, as the builder used
# them; paCounts: the vertex counts the map's regions have, each a rule
func StzChoroplethStyle(pnW, pnH, paPalette, paCounts)
	_o_ = new stzMathStyle()
	_o_.SetCanvas(pnW, pnH)
	_o_.SetMargin(10)
	_nC_ = len(paPalette)
	# A REGION is its polygon in its class's colour, its name and value at
	# its centroid in whichever of black and white reads on the fill --
	# one rule per class and per count of vertices, since a polygon's
	# count is a literal of the style
	for _c_ = 1 to _nC_
		for _k_ = 1 to len(paCounts)
			_o_.ForAllWhere("Region r", "C" + _c_ + "(r); N" + paCounts[_k_] + "(r)", [
				[ :shape, "r.icon", :poly, _ChPolyProps(paCounts[_k_], paPalette[_c_], "background", 1.5) ],
				[ :shape, "r.text", :text, [ :cx = "r.cx", :cy = "r.cy - 15", :size = 20, :fill = [ :on, "r.icon" ] ] ],
				[ :layer, "r.text", :above, "r.icon" ] ])
		next
		_o_.ForAllWhere("Swatch s", "K" + _c_ + "(s)", [
			[ :shape, "s.icon", :rect, [ :cx = "s.x", :cy = "s.y", :w = 34, :h = 22,
			                             :fill = paPalette[_c_], :stroke = "neutral", :strokeWidth = 1 ] ],
			[ :shape, "s.text", :text, [ :cx = "s.x + 28 + s.text.w / 2", :cy = "s.y", :size = 17, :fill = [ :on, "paper" ] ] ] ])
	next
	# a region with no value is a pale grey hole, named as such
	for _k_ = 1 to len(paCounts)
		_o_.ForAllWhere("Region r", "NoData(r); N" + paCounts[_k_] + "(r)", [
			[ :shape, "r.icon", :poly, _ChPolyProps(paCounts[_k_], [ :alpha, "neutral", 0.18 ], "background", 1.5) ],
			[ :shape, "r.text", :text, [ :cx = "r.cx", :cy = "r.cy - 15", :size = 20, :fill = [ :on, "paper" ] ] ],
			[ :layer, "r.text", :above, "r.icon" ] ])
	next
	_o_.ForAllWhere("Swatch s", "OutsideSwatch(s)", [
		[ :shape, "s.icon", :rect, [ :cx = "s.x", :cy = "s.y", :w = 34, :h = 22,
		                             :fill = [ :alpha, "danger", 0.35 ], :stroke = "danger", :strokeWidth = 2 ] ],
		[ :shape, "s.text", :text, [ :cx = "s.x + 28 + s.text.w / 2", :cy = "s.y", :size = 17, :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAllWhere("Swatch s", "NoDataSwatch(s)", [
		[ :shape, "s.icon", :rect, [ :cx = "s.x", :cy = "s.y", :w = 34, :h = 22,
		                             :fill = [ :alpha, "neutral", 0.18 ], :stroke = "neutral", :strokeWidth = 1 ] ],
		[ :shape, "s.text", :text, [ :cx = "s.x + 28 + s.text.w / 2", :cy = "s.y", :size = 17, :fill = [ :on, "paper" ] ] ] ])
	# THE VALUE UNDER THE NAME, IN WHICHEVER OF BLACK AND WHITE READS ON ITS
	# CLASS'S FILL. The value is its own object and cannot name the
	# region's polygon, so it was painted for the paper -- and the gate
	# read "310" in black on the deepest shade, under 3:1 in both themes.
	# The class's colour is a literal here, so the choice is made here.
	_o_.ForAll("Value v", [
		[ :shape, "v.text", :text, [ :cx = "v.cx", :cy = "v.cy", :size = 16, :fill = [ :on, "paper" ] ] ] ])
	for _c_ = 1 to _nC_
		_cInk_ = "#000000"
		if StzIsDarkColor(paPalette[_c_])  _cInk_ = "#FFFFFF"  ok
		_o_.ForAllWhere("Value v", "V" + _c_ + "(v)", [
			[ :delete, "v.text" ],
			[ :shape, "v.text", :text, [ :cx = "v.cx", :cy = "v.cy", :size = 16, :fill = _cInk_ ] ] ])
	next
	# the legend's title
	_o_.ForAll("Legend g", [
		[ :shape, "g.text", :text, [ :cx = "g.x + g.text.w / 2", :cy = "g.y + 12", :size = 20, :fill = [ :on, "paper" ] ] ] ])
	# A FAULT IS DRAWN: a region beyond the classes in the colour of a
	# fault; a class no region falls in, and a swatch lighter than the
	# one before it, rimmed in that colour
	for _k_ = 1 to len(paCounts)
		_o_.ForAllWhere("Region r", "Outside(r); N" + paCounts[_k_] + "(r)", [
			[ :shape, "r.icon", :poly, _ChPolyProps(paCounts[_k_], [ :alpha, "danger", 0.35 ], "danger", 2) ],
			[ :shape, "r.text", :text, [ :cx = "r.cx", :cy = "r.cy - 15", :size = 20, :fill = [ :on, "paper" ] ] ],
			[ :layer, "r.text", :above, "r.icon" ] ])
	next
	_o_.ForAllWhere("Swatch s", "Empty(s)", [
		[ :delete, "s.icon" ],
		[ :shape, "s.icon", :rect, [ :cx = "s.x", :cy = "s.y", :w = 34, :h = 22,
		                             :fill = "background", :stroke = "danger", :strokeWidth = 2 ] ] ])
	_o_.ForAllWhere("Swatch s", "Misordered(s)", [
		[ :delete, "s.icon" ],
		[ :shape, "s.icon", :rect, [ :cx = "s.x", :cy = "s.y", :w = 34, :h = 22,
		                             :fill = "background", :stroke = "danger", :strokeWidth = 2 ] ] ])
	return _o_

# a polygon's props for a region of pnN points, read from the region's
# data, in its fill and rule
func _ChPolyProps(pnN, pFill, pStroke, pnW)
	_a_ = [ [ "n", pnN ] ]
	for _j_ = 1 to pnN
		_a_ + [ "x" + _j_, "r.x" + _j_ ]
		_a_ + [ "y" + _j_, "r.y" + _j_ ]
	next
	_a_ + [ "fill", pFill ]
	_a_ + [ "stroke", pStroke ]
	_a_ + [ "strokeWidth", pnW ]
	return _a_

# the whole picture in one call
func StzChoroplethDiagram(poFont, pcQuantity, paRegions, paEdges)
	return StzChoroplethDiagramXT(poFont, pcQuantity, paRegions, paEdges, [])

func StzChoroplethDiagramXT(poFont, pcQuantity, paRegions, paEdges, paPalette)
	_oS_ = StzChoroplethFromRegionsXT(pcQuantity, paRegions, paEdges, paPalette)
	_aPal_ = []
	_nC_ = len(paEdges) - 1
	if isList(paPalette) and len(paPalette) = _nC_
		for _i_ = 1 to _nC_  _aPal_ + StzResolveColor("" + paPalette[_i_])  next
	else
		_aPal_ = StzChoroplethPaletteFor(_nC_)
	ok
	_aP_ = StzChoroplethPaperOf(_oS_)
	# the vertex counts the map has, each its own rule in the style
	_aN_ = []
	_ar_ = _oS_.ObjectsOfType("Region")
	for _i_ = 1 to len(_ar_)
		_n_ = _oS_.DataOf(_ar_[_i_], "n")
		_bIn_ = FALSE
		for _j_ = 1 to len(_aN_)
			if _aN_[_j_] = _n_  _bIn_ = TRUE  exit  ok
		next
		if NOT _bIn_  _aN_ + _n_  ok
	next
	_o_ = new stzMathDiagram(StzChoroplethDomain(), _oS_, StzChoroplethStyle(_aP_[1], _aP_[2], _aPal_, _aN_))
	if isObject(poFont)  _o_.SetFont(poFont, 11)  ok
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE -- every one about the map             #
#---------------------------------------------------------------------#

func _ChIsMap(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "choropleth"

func _ChScope(poDg, pcType, pcPrefix)
	_r_ = []
	if NOT _ChIsMap(poDg)  return _r_  ok
	_ac_ = poDg.Substance().ObjectsOfType(pcType)
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _ChCounter(poDg, pcPrefix)
	_r_ = []
	if NOT isObject(poDg) or _ChIsMap(poDg)  return _r_  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return _r_  ok
	_ac_ = poDg.Substance().ObjectNames()
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _ChName(poS, pcObj)
	_c_ = poS.LabelOf(pcObj)
	if _c_ = ""  _c_ = pcObj  ok
	return _c_

func StzChoroplethRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("every_region_has_a_value")
	_o1_.SetClaim("every region carries a value")
	_o1_.SetOrder(67)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _ChScope(oDg, "Region", "region:") })
	_o1_.SetCounter(func(oDg) { return _ChCounter(oDg, "region:") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cR_ = StzStringSection(cSub, 8, len(cSub))
		_oS_ = oDg.Substance()
		if _oS_.Holds("NoData", [ _cR_ ])
			return [ FALSE, "'" + _ChName(_oS_, _cR_) + "' has no value -- a hole in the map, drawn as no data" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	# the regions with a value; one without is the first rule's
	_o2_ = StzPlasticRule("values_fall_in_the_classes")
	_o2_.SetClaim("every value falls between the first edge and the last")
	_o2_.SetOrder(68)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) {
		_r_ = []
		if NOT _ChIsMap(oDg)  return _r_  ok
		_oS_ = oDg.Substance()
		_ac_ = _oS_.ObjectsOfType("Region")
		for _i_ = 1 to len(_ac_)
			if NOT _oS_.Holds("NoData", [ _ac_[_i_] ])  _r_ + ("region:" + _ac_[_i_])  ok
		next
		return _r_
	})
	_o2_.SetCounter(func(oDg) {
		_r_ = _ChCounter(oDg, "region:")
		if NOT _ChIsMap(oDg)  return _r_  ok
		_oS_ = oDg.Substance()
		_ac_ = _oS_.ObjectsOfType("Region")
		for _i_ = 1 to len(_ac_)
			if _oS_.Holds("NoData", [ _ac_[_i_] ])  _r_ + ("region:" + _ac_[_i_])  ok
		next
		return _r_
	})
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cR_ = StzStringSection(cSub, 8, len(cSub))
		_oS_ = oDg.Substance()
		if NOT _oS_.Holds("Outside", [ _cR_ ])  return [ TRUE, "" ]  ok
		_nV_ = _oS_.DataOf(_cR_, "value")
		_nC_ = _oS_.DataOf("lg", "classes")
		_nLo_ = _oS_.DataOf("l1", "lo")
		_nHi_ = _oS_.DataOf("l" + _nC_, "hi")
		if _nV_ > _nHi_
			return [ FALSE, "'" + _ChName(_oS_, _cR_) + "' is " + StzFactNumText(_nV_) +
				", above the last class, which ends at " + StzFactNumText(_nHi_) + " -- it has no colour" ]
		ok
		return [ FALSE, "'" + _ChName(_oS_, _cR_) + "' is " + StzFactNumText(_nV_) +
			", below the first class, which begins at " + StzFactNumText(_nLo_) + " -- it has no colour" ]
	})
	_ao_ + _o2_

	# the classes after the first; the first has nothing to be darker than
	_o3_ = StzPlasticRule("darker_means_more")
	_o3_.SetClaim("each class is darker than the one before it")
	_o3_.SetOrder(69)
	_o3_.SetReads([ "substance" ])
	_o3_.SetScope(func(oDg) {
		_r_ = []
		if NOT _ChIsMap(oDg)  return _r_  ok
		_oS_ = oDg.Substance()
		_ac_ = _oS_.ObjectsOfType("Swatch")
		for _i_ = 1 to len(_ac_)
			if _oS_.DataOf(_ac_[_i_], "index") > 1  _r_ + ("class:" + _ac_[_i_])  ok
		next
		return _r_
	})
	_o3_.SetCounter(func(oDg) {
		_r_ = _ChCounter(oDg, "class:")
		if NOT _ChIsMap(oDg)  return _r_  ok
		_oS_ = oDg.Substance()
		_ac_ = _oS_.ObjectsOfType("Swatch")
		for _i_ = 1 to len(_ac_)
			if _oS_.DataOf(_ac_[_i_], "index") <= 1  _r_ + ("class:" + _ac_[_i_])  ok
		next
		return _r_
	})
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cL_ = StzStringSection(cSub, 7, len(cSub))
		_oS_ = oDg.Substance()
		if _oS_.Holds("Misordered", [ _cL_ ])
			_n_ = _oS_.DataOf(_cL_, "index")
			return [ FALSE, "class " + _n_ + " (" + _ChRange(_oS_, _cL_) + ") is lighter than class " + (_n_ - 1) +
				" (" + _ChRange(_oS_, "l" + (_n_ - 1)) + ") -- a darker colour means more" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o3_

	_o4_ = StzPlasticRule("every_class_has_a_region")
	_o4_.SetClaim("no class of the legend colours nothing on the map")
	_o4_.SetOrder(70)
	_o4_.SetReads([ "substance" ])
	_o4_.SetScope(func(oDg) {
		_r_ = []
		if NOT _ChIsMap(oDg)  return _r_  ok
		_oS_ = oDg.Substance()
		_ac_ = _oS_.ObjectsOfType("Swatch")
		for _i_ = 1 to len(_ac_)
			if _oS_.DataOf(_ac_[_i_], "index") > 0  _r_ + ("class:" + _ac_[_i_])  ok
		next
		return _r_
	})
	_o4_.SetCounter(func(oDg) {
		_r_ = _ChCounter(oDg, "class:")
		if NOT _ChIsMap(oDg)  return _r_  ok
		_oS_ = oDg.Substance()
		_ac_ = _oS_.ObjectsOfType("Swatch")
		for _i_ = 1 to len(_ac_)
			if _oS_.DataOf(_ac_[_i_], "index") = 0  _r_ + ("class:" + _ac_[_i_])  ok
		next
		return _r_
	})
	_o4_.SetClaimCheck(func(oDg, cSub) {
		_cL_ = StzStringSection(cSub, 7, len(cSub))
		_oS_ = oDg.Substance()
		if _oS_.DataOf(_cL_, "regions") = 0
			return [ FALSE, "class " + _oS_.DataOf(_cL_, "index") + " (" + _ChRange(_oS_, _cL_) +
				") colours no region -- the legend promises a shade the map never shows" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o4_

	return _ao_
