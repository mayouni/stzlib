#=====================================================================#
#  STZBOXPLOTFIGURE -- M1d: a box plot is a FIGURE, and the five       #
#  numbers it draws are the five numbers it says                       #
#=====================================================================#
/*
	THE SIXTH VISUAL DOOR (base/math/CHARTER.md, and the Tukey plan's
	TK3, which asks for a box plot that can be READ BACK -- its median
	and hinge columns asserted -- and a text rendition beside the drawn
	one). A box plot is five numbers and a rule: the box from the first
	to the third quartile, the median across it, whiskers to the last
	values inside the fences at 1.5 times the box's width, and every
	value beyond a fence drawn alone. The numbers come from stzDataSet
	(engine percentiles, the same fences as stats.zig); the figure draws
	them, names them, and its rules hold the drawing to them.

	WHAT A BOX PLOT IS HERE:

	    DOMAIN     Frame; Axis, the value axis with its Ticks; Box, one
	               group's five numbers and its fences; Outlier, a value
	               beyond a fence (a constructor over Box); Note, a
	               number written above its place (a constructor over
	               Box). Named(Box) when the group has a name.

	    SUBSTANCE  built from a declaration:
	                 [ :of = [ 2, 4, 4, 5, 7, 9, 12, 25 ] ]            one group
	                 [ :groups = [ [ "A", [ ... ] ], [ "B", [ ... ] ] ] ]
	               with :numbers (the five numbers written, on by default
	               for one group), :label. Groups stack downward; they
	               share one value axis, so their boxes compare.

	    STYLE      the box as a rect, the median a heavier line, the
	               whiskers lines with caps, an outlier a hollow dot; the
	               notes SOLVED above the box, off one another and off
	               the median line; the group's name to the left.

	    TEXT       StzBoxPlotFigureText(substance): one ruled line per
	               group, the five numbers in a header, the box drawn in
	               characters on a sixty-column scale -- the rendition a
	               terminal, a test log or a blind reader gets.

	WHAT THE DOMAIN OWES THE GATE:

	    box_keeps_its_order            q1 <= median <= q3
	    whiskers_stay_inside_the_fences the whiskers end inside 1.5 IQR
	    outliers_lie_beyond_the_fences  every outlier is past a fence

	WHAT IS SAID PLAINLY: the quartiles are the engine's percentiles at
	25 and 75, which is one of several conventions -- Tukey's fourths
	are TK0's spike, not this figure's; a group of fewer than four values
	has no quartiles worth drawing and is refused.
*/

StzRegisterMathRuleSet("boxplot", StzBoxPlotRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzBoxPlotDomain()
	_o_ = new stzMathDomain("boxplot")
	_o_.AddType("Frame")
	_o_.AddType("Axis")
	_o_.AddType("Tick")
	_o_.AddType("Box")
	_o_.AddType("Outlier")
	_o_.AddType("Note")
	_o_.AddConstructor("Outlier", [ "Box" ])
	_o_.AddConstructor("Note", [ "Box" ])
	_o_.AddPredicate("Named", [ "Box" ])
	return _o_

func StzBoxPlotFigureWidth()
	return 900

func StzBoxPlotFigureLeft()
	return 150

func StzBoxPlotFigureRight()
	return 50

func StzBoxPlotFigureRowPitch()
	return 96

func StzBoxPlotFigureBoxHeight()
	return 36

func StzBoxPlotFigureTypeSize()
	return 15

func StzBoxPlotFigureTitleSize()
	return 20

func StzBoxPlotFigureLeash()
	return 30

func StzBoxPlotFigureMaxGroups()
	return 6

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM A DECLARATION                                   #
#---------------------------------------------------------------------#

func StzBoxPlotFigureKeys()
	return [ "of", "groups", "numbers", "label" ]

func StzBoxPlotFigureFrom(paSpec)
	return StzBoxPlotFigureFromXT(NULL, paSpec)

func StzBoxPlotFigureBuildXT(poFont, paSpec)
	_oS_ = StzBoxPlotFigureFromXT(poFont, paSpec)
	_o_ = new stzMathDiagram(_oS_.DomainQ(), _oS_, StzBoxPlotStyleXT(_oS_.DataOf("fr", "h")))
	if isObject(poFont)  _o_.SetFont(poFont, StzBoxPlotFigureTypeSize())  ok
	_o_.SetVariation("boxplot")
	return _o_

func StzBoxPlotFigureFromXT(poFont, paSpec)
	_d_ = _BpDeclaration(paSpec)
	_aG_ = _d_[:groups]        # [ [ name, values ] ]
	_nG_ = len(_aG_)

	# THE NUMBERS, from the data set: engine percentiles and 1.5 IQR fences
	_aSt_ = []
	_nMin_ = 0  _nMax_ = 0  _bAny_ = FALSE
	for _g_ = 1 to _nG_
		_oD_ = new stzDataSet(_aG_[_g_][2])
		_aB_ = _oD_.BoxPlotStats()
		_aO_ = _oD_.Outliers()
		_aSt_ + [ _aB_, _aO_ ]
		if NOT _bAny_  _nMin_ = _aB_[:min]  _nMax_ = _aB_[:max]  _bAny_ = TRUE  ok
		if _aB_[:min] < _nMin_  _nMin_ = _aB_[:min]  ok
		if _aB_[:max] > _nMax_  _nMax_ = _aB_[:max]  ok
	next
	if _nMax_ - _nMin_ < 0.000000001  _nMin_ = _nMin_ - 1  _nMax_ = _nMax_ + 1  ok
	_nPad_ = (_nMax_ - _nMin_) * 0.06
	_nVmin_ = _nMin_ - _nPad_
	_nVmax_ = _nMax_ + _nPad_

	_nTop_ = 60
	if _d_[:label] = ""  _nTop_ = 30  ok
	if _d_[:numbers]  _nTop_ += 34  ok
	_nX0_ = StzBoxPlotFigureLeft()
	_nX1_ = StzBoxPlotFigureWidth() - StzBoxPlotFigureRight()
	_nK_ = (_nX1_ - _nX0_) / (_nVmax_ - _nVmin_)
	_nAxY_ = _nTop_ + _nG_ * StzBoxPlotFigureRowPitch() + 10
	_nH_ = _nAxY_ + 46

	_oS_ = new stzMathSubstance(StzBoxPlotDomain())
	_oS_.Declare("Frame", "fr")
	_oS_.Label("fr", _d_[:label])
	_oS_.SetData("fr", "h", _nH_)
	_oS_.SetData("fr", "groups", _nG_)
	_oS_.SetData("fr", "vmin", _nVmin_)  _oS_.SetData("fr", "vmax", _nVmax_)
	_oS_.SetData("fr", "x0", _nX0_)  _oS_.SetData("fr", "x1", _nX1_)
	_oS_.SetData("fr", "tx", 30 + _FfTextWidth(poFont, _d_[:label], StzBoxPlotFigureTitleSize()) / 2)
	_oS_.SetData("fr", "ty", 30)
	_oS_.SetData("fr", "numbers", _d_[:numbers])

	# the value axis and its ticks
	_oS_.Declare("Axis", "ax")
	_oS_.Label("ax", "")
	_oS_.SetData("ax", "x0", _nX0_ - 10)  _oS_.SetData("ax", "x1", _nX1_ + 10)
	_oS_.SetData("ax", "y", _nAxY_)
	_nStep_ = _FfNiceStep(_nVmax_ - _nVmin_, 8)
	_nK2_ = 0
	for _j_ = ceil(_nVmin_ / _nStep_) to floor(_nVmax_ / _nStep_)
		_v_ = _j_ * _nStep_
		_nK2_++
		_oS_.Declare("Tick", "t" + _nK2_)
		_oS_.Label("t" + _nK2_, _FfNum(_v_, 6))
		_oS_.SetData("t" + _nK2_, "v", _v_)
		_oS_.SetData("t" + _nK2_, "x", _nX0_ + (_v_ - _nVmin_) * _nK_)
		_oS_.SetData("t" + _nK2_, "y", _nAxY_)
		_oS_.SetData("t" + _nK2_, "ly", _nAxY_ + 20)
	next
	_oS_.SetData("ax", "ticks", _nK2_)

	# the boxes, one row each
	_nOut_ = 0
	for _g_ = 1 to _nG_
		_aB_ = _aSt_[_g_][1]
		_aO_ = _aSt_[_g_][2]
		_cB_ = "b" + _g_
		_nY_ = _nTop_ + (_g_ - 0.5) * StzBoxPlotFigureRowPitch() + 14
		_oS_.Declare("Box", _cB_)
		_oS_.Label(_cB_, _aG_[_g_][1])
		if _aG_[_g_][1] != ""  _oS_.Assert("Named", [ _cB_ ])  ok
		_oS_.SetData(_cB_, "n", len(_aG_[_g_][2]))
		_oS_.SetData(_cB_, "min", _aB_[:min])  _oS_.SetData(_cB_, "max", _aB_[:max])
		_oS_.SetData(_cB_, "q1", _aB_[:q1])  _oS_.SetData(_cB_, "med", _aB_[:median])  _oS_.SetData(_cB_, "q3", _aB_[:q3])
		_oS_.SetData(_cB_, "iqr", _aB_[:iqr])
		_oS_.SetData(_cB_, "wlo", _aB_[:whisker_low])  _oS_.SetData(_cB_, "whi", _aB_[:whisker_high])
		_oS_.SetData(_cB_, "flo", _aB_[:q1] - 1.5 * _aB_[:iqr])  _oS_.SetData(_cB_, "fhi", _aB_[:q3] + 1.5 * _aB_[:iqr])
		_oS_.SetData(_cB_, "y", _nY_)
		_oS_.SetData(_cB_, "hh", StzBoxPlotFigureBoxHeight())
		_oS_.SetData(_cB_, "xq1", _nX0_ + (_aB_[:q1] - _nVmin_) * _nK_)
		_oS_.SetData(_cB_, "xmed", _nX0_ + (_aB_[:median] - _nVmin_) * _nK_)
		_oS_.SetData(_cB_, "xq3", _nX0_ + (_aB_[:q3] - _nVmin_) * _nK_)
		_oS_.SetData(_cB_, "xwlo", _nX0_ + (_aB_[:whisker_low] - _nVmin_) * _nK_)
		_oS_.SetData(_cB_, "xwhi", _nX0_ + (_aB_[:whisker_high] - _nVmin_) * _nK_)
		_oS_.SetData(_cB_, "nx", _nX0_ - 20 - _FfTextWidth(poFont, _aG_[_g_][1], StzBoxPlotFigureTypeSize() + 1) / 2)
		_oS_.SetData(_cB_, "outliers", len(_aO_))
		for _i_ = 1 to len(_aO_)
			_nOut_++
			_cO_ = "o" + _nOut_
			_oS_.Define(_cO_, "Outlier", [ _cB_ ])
			_oS_.Label(_cO_, "")
			_oS_.SetData(_cO_, "v", _aO_[_i_])
			_oS_.SetData(_cO_, "x", _nX0_ + (_aO_[_i_] - _nVmin_) * _nK_)
			_oS_.SetData(_cO_, "y", _nY_)
		next
		# the five numbers, written above their places and SOLVED apart
		if _d_[:numbers]
			_aN_ = [ [ "q1", "Q1 = " + _FfNum(_aB_[:q1], 4) ], [ "med", "median = " + _FfNum(_aB_[:median], 4) ],
			         [ "q3", "Q3 = " + _FfNum(_aB_[:q3], 4) ] ]
			for _i_ = 1 to 3
				_cN_ = "n" + _g_ + "_" + _aN_[_i_][1]
				_oS_.Define(_cN_, "Note", [ _cB_ ])
				_oS_.Label(_cN_, _aN_[_i_][2])
				_oS_.SetData(_cN_, "ax", _oS_.DataOf(_cB_, "x" + _aN_[_i_][1]))
				_oS_.SetData(_cN_, "ay", _nY_ - StzBoxPlotFigureBoxHeight() / 2)
			next
		ok
	next
	_oS_.SetData("fr", "outliers", _nOut_)
	return _oS_

func StzBoxPlotFigureWhy(poSubstance)
	_nG_ = poSubstance.DataOf("fr", "groups")
	_c_ = "a box plot of " + _nG_ + " group(s): "
	for _g_ = 1 to _nG_
		if _g_ > 1  _c_ += "; "  ok
		_cN_ = poSubstance.LabelOf("b" + _g_)
		if _cN_ != ""  _c_ += _cN_ + " "  ok
		_c_ += "n = " + poSubstance.DataOf("b" + _g_, "n") + ", box " + _FfNum(poSubstance.DataOf("b" + _g_, "q1"), 4) +
			" | " + _FfNum(poSubstance.DataOf("b" + _g_, "med"), 4) + " | " + _FfNum(poSubstance.DataOf("b" + _g_, "q3"), 4) +
			", " + poSubstance.DataOf("b" + _g_, "outliers") + " outlier(s)"
	next
	return _c_

# THE TEXT RENDITION: one ruled line per group on a sixty-column scale,
# the five numbers in a header, the box in characters -- what a terminal,
# a test log or a blind reader gets, and what TK3 asks to read back
func StzBoxPlotFigureText(poSubstance)
	_nG_ = poSubstance.DataOf("fr", "groups")
	_nLo_ = poSubstance.DataOf("fr", "vmin")
	_nHi_ = poSubstance.DataOf("fr", "vmax")
	_nCols_ = 60
	_c_ = ""
	for _g_ = 1 to _nG_
		_cB_ = "b" + _g_
		_cN_ = poSubstance.LabelOf(_cB_)
		if _cN_ = ""  _cN_ = "group " + _g_  ok
		_c_ += _cN_ + "  n=" + poSubstance.DataOf(_cB_, "n") + "  min " + _FfNum(poSubstance.DataOf(_cB_, "min"), 4) +
			"  Q1 " + _FfNum(poSubstance.DataOf(_cB_, "q1"), 4) + "  med " + _FfNum(poSubstance.DataOf(_cB_, "med"), 4) +
			"  Q3 " + _FfNum(poSubstance.DataOf(_cB_, "q3"), 4) + "  max " + _FfNum(poSubstance.DataOf(_cB_, "max"), 4) +
			"  outliers " + poSubstance.DataOf(_cB_, "outliers") + char(10)
		# the ruled line: spaces, whiskers as -, the box as [ ], the median as |, outliers as o
		_aL_ = []
		for _i_ = 1 to _nCols_  _aL_ + " "  next
		_nA_ = _BpCol(poSubstance.DataOf(_cB_, "wlo"), _nLo_, _nHi_, _nCols_)
		_nB_ = _BpCol(poSubstance.DataOf(_cB_, "whi"), _nLo_, _nHi_, _nCols_)
		for _i_ = _nA_ to _nB_  _aL_[_i_] = "-"  next
		_nQ1_ = _BpCol(poSubstance.DataOf(_cB_, "q1"), _nLo_, _nHi_, _nCols_)
		_nQ3_ = _BpCol(poSubstance.DataOf(_cB_, "q3"), _nLo_, _nHi_, _nCols_)
		for _i_ = _nQ1_ to _nQ3_  _aL_[_i_] = "="  next
		_aL_[_nQ1_] = "["
		_aL_[_nQ3_] = "]"
		_aL_[_BpCol(poSubstance.DataOf(_cB_, "med"), _nLo_, _nHi_, _nCols_)] = "|"
		_ac_ = poSubstance.ObjectsOfType("Outlier")
		_aD_ = poSubstance.Definitions()
		for _i_ = 1 to len(_aD_)
			if _aD_[_i_][2] != "Outlier" or "" + _aD_[_i_][3][1] != _cB_  loop  ok
			_aL_[_BpCol(poSubstance.DataOf(_aD_[_i_][1], "v"), _nLo_, _nHi_, _nCols_)] = "o"
		next
		_cLine_ = ""
		for _i_ = 1 to _nCols_  _cLine_ += _aL_[_i_]  next
		_c_ += "  " + _cLine_ + char(10)
	next
	_c_ += "  " + _FfNum(_nLo_, 4) + _BpSpaces(_nCols_ - len(_FfNum(_nLo_, 4)) - len(_FfNum(_nHi_, 4))) +
		_FfNum(_nHi_, 4) + char(10)
	return _c_

func _BpSpaces(pn)
	_c_ = ""
	for _i_ = 1 to pn  _c_ += " "  next
	return _c_

func _BpCol(pnV, pnLo, pnHi, pnCols)
	_c_ = 1 + floor((pnV - pnLo) / (pnHi - pnLo) * (pnCols - 1) + 0.5)
	if _c_ < 1  _c_ = 1  ok
	if _c_ > pnCols  _c_ = pnCols  ok
	return _c_

#-- the declaration, read and refused by name -------------------------

func _BpDeclaration(paSpec)
	if NOT isList(paSpec) or len(paSpec) = 0
		stzraise("StzBoxPlotFigure: a box plot is declared as keys, like [ :of = [ 2, 4, 4, 5, 7, 9 ] ].")
	ok
	_acKeys_ = StzBoxPlotFigureKeys()
	for _i_ = 1 to len(paSpec)
		_e_ = paSpec[_i_]
		if NOT isList(_e_) or len(_e_) != 2 or NOT isString(_e_[1])
			stzraise("StzBoxPlotFigure: entry " + _i_ + " of the declaration is not a key and a value.")
		ok
		if NOT _FfIn(_acKeys_, StzLower(_e_[1]))
			stzraise("StzBoxPlotFigure: ':" + _e_[1] + "' is not a key of a box plot -- the keys are " + @@(_acKeys_) + ".")
		ok
	next
	_d_ = [ :groups = [], :numbers = FALSE, :label = "" ]
	_aOf_ = _FfGet(paSpec, "of", [])
	_aGr_ = _FfGet(paSpec, "groups", [])
	if isList(_aOf_) and len(_aOf_) > 0 and isList(_aGr_) and len(_aGr_) > 0
		stzraise("StzBoxPlotFigure: :of and :groups cannot both be given.")
	ok
	if isList(_aOf_) and len(_aOf_) > 0
		_d_[:groups] + [ "", _BpValues(_aOf_, "the values") ]
	but isList(_aGr_) and len(_aGr_) > 0
		if len(_aGr_) > StzBoxPlotFigureMaxGroups()
			stzraise("StzBoxPlotFigure: at most " + StzBoxPlotFigureMaxGroups() + " groups on one paper.")
		ok
		for _i_ = 1 to len(_aGr_)
			_e_ = _aGr_[_i_]
			if NOT isList(_e_) or len(_e_) != 2 or NOT isString(_e_[1]) or NOT isList(_e_[2])
				stzraise("StzBoxPlotFigure: group " + _i_ + " is [ name, values ].")
			ok
			_d_[:groups] + [ _e_[1], _BpValues(_e_[2], "group '" + _e_[1] + "'") ]
		next
	else
		stzraise("StzBoxPlotFigure: say what to draw -- :of = the values, or :groups = [ [ name, values ] ].")
	ok
	_n_ = _FfGet(paSpec, "numbers", "")
	if isNumber(_n_)
		_d_[:numbers] = (_n_ != 0)
	but isString(_n_) and _n_ = ""
		_d_[:numbers] = (len(_d_[:groups]) = 1)
	else
		stzraise("StzBoxPlotFigure: :numbers is TRUE or FALSE -- whether the five numbers are written.")
	ok
	_cL_ = _FfGet(paSpec, "label", "")
	if NOT isString(_cL_)
		stzraise("StzBoxPlotFigure: :label is text.")
	ok
	_d_[:label] = _cL_
	return _d_

func _BpValues(paV, pcWhat)
	if NOT isList(paV) or len(paV) < 4
		stzraise("StzBoxPlotFigure: " + pcWhat + " needs at least four numbers for quartiles to mean anything.")
	ok
	for _i_ = 1 to len(paV)
		if NOT isNumber(paV[_i_])
			stzraise("StzBoxPlotFigure: value " + _i_ + " of " + pcWhat + " is not a number.")
		ok
	next
	return paV

#---------------------------------------------------------------------#
#  THE STYLE                                                           #
#---------------------------------------------------------------------#

func StzBoxPlotStyle()
	return StzBoxPlotStyleXT(300)

func StzBoxPlotStyleXT(pnH)
	_o_ = new stzMathStyle()
	_o_.SetCanvas(StzBoxPlotFigureWidth(), pnH)
	_o_.SetMargin(4)
	_nT_ = StzBoxPlotFigureTypeSize()
	_o_.ForAll("Frame f", [
		[ :shape, "f.text", :text, [ :cx = "f.tx", :cy = "f.ty", :size = StzBoxPlotFigureTitleSize(),
		                             :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAll("Axis a", [
		[ :shape, "a.icon", :line, [ :x1 = "a.x0", :y1 = "a.y", :x2 = "a.x1", :y2 = "a.y",
		                             :stroke = "neutral", :strokeWidth = 1.5 ] ] ])
	_o_.ForAll("Tick k", [
		[ :shape, "k.icon", :line, [ :x1 = "k.x", :y1 = "k.y - 4", :x2 = "k.x", :y2 = "k.y + 4",
		                             :stroke = "neutral", :strokeWidth = 1 ] ],
		[ :shape, "k.text", :text, [ :cx = "k.x", :cy = "k.ly", :size = _nT_, :fill = "muted" ] ] ])
	# THE BOX: whiskers first (under), the box, the median heavier, the caps
	_o_.ForAll("Box b", [
		[ :shape, "b.wlo", :line, [ :x1 = "b.xwlo", :y1 = "b.y", :x2 = "b.xq1", :y2 = "b.y",
		                            :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "b.whi", :line, [ :x1 = "b.xq3", :y1 = "b.y", :x2 = "b.xwhi", :y2 = "b.y",
		                            :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "b.caplo", :line, [ :x1 = "b.xwlo", :y1 = "b.y - b.hh / 3", :x2 = "b.xwlo", :y2 = "b.y + b.hh / 3",
		                              :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "b.caphi", :line, [ :x1 = "b.xwhi", :y1 = "b.y - b.hh / 3", :x2 = "b.xwhi", :y2 = "b.y + b.hh / 3",
		                              :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "b.icon", :rect, [ :cx = "(b.xq1 + b.xq3) / 2", :cy = "b.y", :w = "b.xq3 - b.xq1", :h = "b.hh",
		                             :fill = [ :alpha, "primary", 0.18 ], :stroke = "primary", :strokeWidth = 1.5 ] ],
		[ :shape, "b.med", :line, [ :x1 = "b.xmed", :y1 = "b.y - b.hh / 2", :x2 = "b.xmed", :y2 = "b.y + b.hh / 2",
		                            :stroke = "primary", :strokeWidth = 3 ] ],
		[ :layer, "b.icon", :above, "b.wlo" ], [ :layer, "b.icon", :above, "b.whi" ],
		[ :layer, "b.med", :above, "b.icon" ] ])
	_o_.ForAllWhere("Box b", "Named(b)", [
		[ :shape, "b.text", :text, [ :cx = "b.nx", :cy = "b.y", :size = _nT_ + 1, :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAllWhere("Outlier o; Box b", "o := Outlier(b)", [
		[ :shape, "o.icon", :circle, [ :cx = "o.x", :cy = "o.y", :r = 4.5,
		                               :fill = "background", :stroke = "primary", :strokeWidth = 1.8 ] ] ])
	# A NOTE STARTS WHERE IT CAN END: an offset above its place on the box,
	# and settles off the other notes and off the box's edge
	_o_.ForAllWhere("Note n; Box b", "n := Note(b)", [
		[ :unknown, "n.ox", -30, 30 ],
		[ :unknown, "n.oy", 16, 34 ],
		[ :shape, "n.text", :text, [ :cx = "n.ax + n.ox", :cy = "n.ay - n.oy", :size = _nT_, :fill = [ :on, "paper" ] ] ],
		[ :encourage, "near", [ "n.text", "b.med", 14 ] ],
		# ABOVE the box, always: left free, a note slid under the box onto
		# the value axis
		[ :ensure, "greaterThan", [ "n.oy", 12 ] ],
		[ :ensure, "disjoint", [ "n.text", "b.icon", 4 ] ],
		[ :ensure, "disjoint", [ "n.text", "b.caplo", 3 ] ],
		[ :ensure, "disjoint", [ "n.text", "b.caphi", 3 ] ] ])
	_o_.ForAll("Note n; Note m", [
		[ :ensure, "disjoint", [ "n.text", "m.text", 5 ] ] ])
	_o_.ForAll("Note n; Axis a", [
		[ :ensure, "disjoint", [ "n.text", "a.icon", 4 ] ] ])
	_o_.ForAll("Note n; Tick k", [
		[ :ensure, "disjoint", [ "n.text", "k.text", 4 ] ] ])
	_o_.ForAll("Note n; Frame f", [
		[ :ensure, "disjoint", [ "n.text", "f.text", 6 ] ] ])
	_o_.ForAll("Note n; Outlier o", [
		[ :ensure, "disjoint", [ "n.text", "o.icon", 4 ] ] ])
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE                                        #
#---------------------------------------------------------------------#

func _BpIsBoxPlot(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "boxplot"

func _BpScope(poDg, pcType, pcPrefix)
	_r_ = []
	if NOT _BpIsBoxPlot(poDg)  return _r_  ok
	_ac_ = poDg.Substance().ObjectsOfType(pcType)
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _BpCounter(poDg, pcPrefix)
	_r_ = []
	if NOT isObject(poDg) or _BpIsBoxPlot(poDg)  return _r_  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return _r_  ok
	_ac_ = poDg.Substance().ObjectNames()
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _BpBoxOf(poSubstance, pcOutlier)
	_aD_ = poSubstance.Definitions()
	for _i_ = 1 to len(_aD_)
		if _aD_[_i_][1] = pcOutlier  return "" + _aD_[_i_][3][1]  ok
	next
	return ""

func StzBoxPlotRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("box_keeps_its_order")
	_o1_.SetClaim("the first quartile, the median and the third quartile stand in order")
	_o1_.SetOrder(85)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _BpScope(oDg, "Box", "box:") })
	_o1_.SetCounter(func(oDg) { return _BpCounter(oDg, "box:") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cB_ = StzStringSection(cSub, 5, len(cSub))
		_oS_ = oDg.Substance()
		_q1_ = _oS_.DataOf(_cB_, "q1")  _m_ = _oS_.DataOf(_cB_, "med")  _q3_ = _oS_.DataOf(_cB_, "q3")
		if _q1_ > _m_ or _m_ > _q3_
			return [ FALSE, "the box says Q1 = " + _FfNum(_q1_, 4) + ", median = " + _FfNum(_m_, 4) +
				", Q3 = " + _FfNum(_q3_, 4) + " -- not in order" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("whiskers_stay_inside_the_fences")
	_o2_.SetClaim("the whiskers end inside the fences at 1.5 IQR from the box")
	_o2_.SetOrder(86)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) { return _BpScope(oDg, "Box", "box:") })
	_o2_.SetCounter(func(oDg) { return _BpCounter(oDg, "box:") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cB_ = StzStringSection(cSub, 5, len(cSub))
		_oS_ = oDg.Substance()
		_lo_ = _oS_.DataOf(_cB_, "wlo")  _hi_ = _oS_.DataOf(_cB_, "whi")
		_flo_ = _oS_.DataOf(_cB_, "q1") - 1.5 * _oS_.DataOf(_cB_, "iqr")
		_fhi_ = _oS_.DataOf(_cB_, "q3") + 1.5 * _oS_.DataOf(_cB_, "iqr")
		if _lo_ < _flo_ - 0.000000001 or _hi_ > _fhi_ + 0.000000001
			return [ FALSE, "the whiskers reach " + _FfNum(_lo_, 4) + " and " + _FfNum(_hi_, 4) +
				" while the fences stand at " + _FfNum(_flo_, 4) + " and " + _FfNum(_fhi_, 4) ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	_o3_ = StzPlasticRule("outliers_lie_beyond_the_fences")
	_o3_.SetClaim("every value drawn alone lies beyond a fence")
	_o3_.SetOrder(87)
	_o3_.SetReads([ "substance" ])
	_o3_.SetScope(func(oDg) { return _BpScope(oDg, "Outlier", "outlier:") })
	_o3_.SetCounter(func(oDg) { return _BpCounter(oDg, "outlier:") })
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cO_ = StzStringSection(cSub, 9, len(cSub))
		_oS_ = oDg.Substance()
		_cB_ = _BpBoxOf(_oS_, _cO_)
		if _cB_ = ""  return [ TRUE, "" ]  ok
		_v_ = _oS_.DataOf(_cO_, "v")
		_flo_ = _oS_.DataOf(_cB_, "q1") - 1.5 * _oS_.DataOf(_cB_, "iqr")
		_fhi_ = _oS_.DataOf(_cB_, "q3") + 1.5 * _oS_.DataOf(_cB_, "iqr")
		if _v_ >= _flo_ - 0.000000001 and _v_ <= _fhi_ + 0.000000001
			return [ FALSE, "the value " + _FfNum(_v_, 4) + " is drawn alone yet lies inside the fences " +
				_FfNum(_flo_, 4) + " .. " + _FfNum(_fhi_, 4) ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o3_

	return _ao_
