#=====================================================================#
#  STZNUMBERLINEFIGURE -- M1b: a number line is a FIGURE, declared,    #
#  computed, then solved -- the child's first picture of a number      #
#=====================================================================#
/*
	THE SECOND VISUAL DOOR (base/math/CHARTER.md, level L0): a number is
	a place on a line, a sum is a jump along it, and a picture of either
	must be one a child can read and one the gate can convict. A number
	line is declared -- a range, the numbers to place, the jumps to make
	-- the builder COMPUTES every position, and the solver PLACES every
	name where it does not cover a neighbour.

	WHAT A NUMBER LINE IS HERE:

	    DOMAIN     Axis, the line with an arrow at both ends; Tick, a
	               number the axis names; Point, a number placed on the
	               line; Note, the name of a point (a constructor over
	               Point, so a rule binds the two); Jump, an arc from one
	               point to another (a constructor over Point, Point) that
	               carries the difference it draws.

	    SUBSTANCE  built from a declaration:
	                 [ :on = [ -5, 10 ], :points = [ 3, -2, 7.5 ],
	                   :jumps = [ [ 2, 5 ] ], :label = "..." ]
	               A point may carry a name: [ 0.5, "half" ]. A jump's
	               ends become points if they were not declared. Ticks
	               take a nice step giving at most sixteen. Every position
	               is a datum in pixels; a point carries its value; a jump
	               carries the difference its label prints.

	    STYLE      the axis; a tick as a cross-mark with its number
	               beneath; a point as a dot; a note SOLVED beside its
	               point, on the side the builder chose (below when a jump
	               lands there, above otherwise), off the axis, the tick
	               numbers and the other notes; a jump as an arc above the
	               line with an arrowhead at its landing and its
	               difference at its top.

	WHAT THE DOMAIN OWES THE GATE -- claims a drawing cannot show false:

	    jump_lands_where_it_says     a jump's landing value is its start
	                                 plus the difference it prints
	    points_keep_their_order      two points stand on the line in the
	                                 order of their values
	    note_reads_near_its_point    a note is within reach of its point

	WHAT IS SAID PLAINLY: values are numbers in the author's unit; a
	number line is one line -- two lines want two pictures; a jump goes
	above the line and a name of a landed-on point goes below it, which is
	the one layout choice this domain makes for the author.
*/

StzRegisterMathRuleSet("numberline", StzNumberLineRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzNumberLineDomain()
	_o_ = new stzMathDomain("numberline")
	_o_.AddType("Axis")
	_o_.AddType("Tick")
	_o_.AddType("Point")
	_o_.AddType("Note")
	_o_.AddType("Jump")
	_o_.AddConstructor("Note", [ "Point" ])
	_o_.AddConstructor("Jump", [ "Point", "Point" ])
	_o_.AddPredicate("Named", [ "Point" ])
	_o_.AddPredicate("Backward", [ "Jump" ])
	return _o_

func StzNumberLineFigureWidth()
	return 900

func StzNumberLineFigureHeight()
	return 280

func StzNumberLineFigureLeft()
	return 60

func StzNumberLineFigureRight()
	return 60

func StzNumberLineFigureAxisY()
	return 170

func StzNumberLineFigureTypeSize()
	return 15

func StzNumberLineFigureTitleSize()
	return 20

func StzNumberLineFigureLeash()
	return 34

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM A DECLARATION                                   #
#---------------------------------------------------------------------#

func StzNumberLineFigureKeys()
	return [ "on", "points", "jumps", "step", "label" ]

func StzNumberLineFigureFrom(paSpec)
	return StzNumberLineFigureFromXT(NULL, paSpec)

func StzNumberLineFigureBuildXT(poFont, paSpec)
	_oS_ = StzNumberLineFigureFromXT(poFont, paSpec)
	_o_ = new stzMathDiagram(_oS_.DomainQ(), _oS_, StzNumberLineStyle())
	if isObject(poFont)  _o_.SetFont(poFont, StzNumberLineFigureTypeSize())  ok
	_o_.SetVariation("numberline")
	return _o_

func StzNumberLineFigureFromXT(poFont, paSpec)
	_d_ = _NlDeclaration(paSpec)
	_nA_ = _d_[:on][1]
	_nB_ = _d_[:on][2]
	_nL_ = StzNumberLineFigureLeft()
	_nR_ = StzNumberLineFigureWidth() - StzNumberLineFigureRight()
	_nK_ = (_nR_ - _nL_) / (_nB_ - _nA_)
	_nAy_ = StzNumberLineFigureAxisY()

	_oS_ = new stzMathSubstance(StzNumberLineDomain())

	# the axis, arrowed both ways: a number line goes on past its ends
	_oS_.Declare("Axis", "ax")
	_oS_.Label("ax", _d_[:label])
	_oS_.SetData("ax", "x0", _nL_ - 24)  _oS_.SetData("ax", "x1", _nR_ + 24)
	_oS_.SetData("ax", "y", _nAy_)
	_oS_.SetData("ax", "a", _nA_)  _oS_.SetData("ax", "b", _nB_)
	_oS_.SetData("ax", "px0", _nL_)  _oS_.SetData("ax", "px1", _nR_)
	_aTb_ = _FfTitleBox(poFont, _d_[:label], StzNumberLineFigureTitleSize())
	_oS_.SetData("ax", "tx", _nL_ + _NlTextWidth(poFont, _d_[:label], StzNumberLineFigureTitleSize()) / 2)
	_oS_.SetData("ax", "ty", max([ 34, _aTb_[1] + 8 ]))

	# the ticks: the author's step, or a nice one giving sixteen or fewer
	_nStep_ = _d_[:step]
	if _nStep_ = 0  _nStep_ = _NlNiceStep(_nB_ - _nA_, 16)  ok
	_nK2_ = 0
	for _j_ = ceil(_nA_ / _nStep_) to floor(_nB_ / _nStep_)
		_v_ = _j_ * _nStep_
		_nK2_++
		_oS_.Declare("Tick", "t" + _nK2_)
		_oS_.Label("t" + _nK2_, _NlNum(_v_, 6))
		_oS_.SetData("t" + _nK2_, "v", _v_)
		_oS_.SetData("t" + _nK2_, "x", _nL_ + (_v_ - _nA_) * _nK_)
		_oS_.SetData("t" + _nK2_, "y", _nAy_)
		_oS_.SetData("t" + _nK2_, "ly", _nAy_ + 22)
	next
	_oS_.SetData("ax", "step", _nStep_)
	_oS_.SetData("ax", "ticks", _nK2_)

	# the points: the author's, and every jump's ends that were not among them
	_aP_ = []           # [ value, name, fromJump ]
	for _i_ = 1 to len(_d_[:points])
		_aP_ + [ _d_[:points][_i_][1], _d_[:points][_i_][2], FALSE ]
	next
	for _i_ = 1 to len(_d_[:jumps])
		for _q_ = 1 to 2
			_v_ = _d_[:jumps][_i_][_q_]
			if _NlPointIndex(_aP_, _v_) = 0  _aP_ + [ _v_, "", TRUE ]  ok
		next
	next
	# in the order of their values, so p1 is the leftmost
	_aP_ = _NlSortPoints(_aP_)
	_nP_ = len(_aP_)
	for _i_ = 1 to _nP_
		_v_ = _aP_[_i_][1]
		if _v_ < _nA_ or _v_ > _nB_
			stzraise("StzNumberLineFigure: " + _NlNum(_v_, 6) + " is not on the line [" +
				_NlNum(_nA_, 6) + ", " + _NlNum(_nB_, 6) + "].")
		ok
		_cP_ = "p" + _i_
		_oS_.Declare("Point", _cP_)
		_oS_.Label(_cP_, "")
		_oS_.SetData(_cP_, "v", _v_)
		_oS_.SetData(_cP_, "x", _nL_ + (_v_ - _nA_) * _nK_)
		_oS_.SetData(_cP_, "y", _nAy_)
		_oS_.SetData(_cP_, "rank", _i_)
		# the note's side: below when a jump lands or starts here (the arc
		# is above), else above; and never the side its left neighbour took
		# when the two are closer than a name
		_nSide_ = -1
		if _aP_[_i_][3] or _NlJumpTouches(_d_[:jumps], _v_)  _nSide_ = 1  ok
		if _i_ > 1 and _nSide_ = -1
			if (_v_ - _aP_[_i_ - 1][1]) * _nK_ < 70 and _oS_.DataOf("p" + (_i_ - 1), "side") = -1
				_nSide_ = 1
			ok
		ok
		_oS_.SetData(_cP_, "side", _nSide_)
		_cText_ = _NlNum(_v_, 6)
		if _aP_[_i_][2] != ""
			_oS_.Assert("Named", [ _cP_ ])
			_cText_ = _aP_[_i_][2] + " = " + _cText_
		ok
		# A POINT ON A TICK IS NAMED BY THE TICK: a note there repeated the
		# number beneath it ("2 2"), so only a point off the ticks, or one
		# the author named, gets a note of its own
		_bOnTick_ = (fabs(_v_ / _nStep_ - floor(_v_ / _nStep_ + 0.5)) < 0.000000001)
		if _aP_[_i_][2] != "" or NOT _bOnTick_
			_oS_.Define("n" + _i_, "Note", [ _cP_ ])
			_oS_.Label("n" + _i_, _cText_)
		ok
	next
	_oS_.SetData("ax", "points", _nP_)

	# the jumps: an arc above the line from one point to the other, its
	# difference at its top, an arrowhead where it lands
	for _i_ = 1 to len(_d_[:jumps])
		_vFrom_ = _d_[:jumps][_i_][1]
		_vTo_ = _d_[:jumps][_i_][2]
		_cFrom_ = "p" + _NlPointIndex(_aP_, _vFrom_)
		_cTo_ = "p" + _NlPointIndex(_aP_, _vTo_)
		_cJ_ = "j" + _i_
		_oS_.Define(_cJ_, "Jump", [ _cFrom_, _cTo_ ])
		_nD_ = _vTo_ - _vFrom_
		_c_ = "+ " + _NlNum(_nD_, 6)
		if _nD_ < 0
			_c_ = "- " + _NlNum(-_nD_, 6)
			_oS_.Assert("Backward", [ _cJ_ ])
		ok
		_oS_.Label(_cJ_, _c_)
		_oS_.SetData(_cJ_, "d", _nD_)
		_x1_ = _nL_ + (_vFrom_ - _nA_) * _nK_
		_x2_ = _nL_ + (_vTo_ - _nA_) * _nK_
		_nH_ = fabs(_x2_ - _x1_) / 2.6
		if _nH_ > 70  _nH_ = 70  ok
		if _nH_ < 26  _nH_ = 26  ok
		# seven controls on a half-ellipse, drawn as a spline
		for _q_ = 0 to 6
			_t_ = 3.14159265358979 * (1 - _q_ / 6)
			if _x2_ < _x1_  _t_ = 3.14159265358979 * _q_ / 6  ok
			_cx_ = (_x1_ + _x2_) / 2 + (fabs(_x2_ - _x1_) / 2) * cos(_t_)
			_cy_ = _nAy_ - 8 - _nH_ * sin(_t_)
			_oS_.SetData(_cJ_, "x" + (_q_ + 1), _cx_)
			_oS_.SetData(_cJ_, "y" + (_q_ + 1), _cy_)
		next
		_oS_.SetData(_cJ_, "lx", (_x1_ + _x2_) / 2)
		_oS_.SetData(_cJ_, "ly", _nAy_ - 8 - _nH_ - 16)
		_oS_.SetData(_cJ_, "top", _nAy_ - 8 - _nH_)
	next
	_oS_.SetData("ax", "jumps", len(_d_[:jumps]))
	return _oS_

# what the figure says about itself: one sentence from the substance
func StzNumberLineFigureWhy(poSubstance)
	_c_ = "a number line from " + _NlNum(poSubstance.DataOf("ax", "a"), 6) + " to " +
		_NlNum(poSubstance.DataOf("ax", "b"), 6) + ": " + poSubstance.DataOf("ax", "ticks") +
		" ticks, " + poSubstance.DataOf("ax", "points") + " point(s), " +
		poSubstance.DataOf("ax", "jumps") + " jump(s)"
	return _c_

#-- the declaration, read and refused by name -------------------------

func _NlDeclaration(paSpec)
	if NOT isList(paSpec) or len(paSpec) = 0
		stzraise("StzNumberLineFigure: a number line is declared as keys, like " +
			"[ :on = [ -5, 10 ], :points = [ 3, -2 ] ].")
	ok
	_acKeys_ = StzNumberLineFigureKeys()
	for _i_ = 1 to len(paSpec)
		_e_ = paSpec[_i_]
		if NOT isList(_e_) or len(_e_) != 2 or NOT isString(_e_[1])
			stzraise("StzNumberLineFigure: entry " + _i_ + " of the declaration is not a key and a value.")
		ok
		if NOT _FfIn(_acKeys_, StzLower(_e_[1]))
			stzraise("StzNumberLineFigure: ':" + _e_[1] + "' is not a key of a number line -- " +
				"the keys are " + @@(_acKeys_) + ".")
		ok
	next
	_d_ = [ :on = [], :points = [], :jumps = [], :step = 0, :label = "" ]
	_aR_ = _FfGet(paSpec, "on", [])
	if NOT isList(_aR_) or len(_aR_) != 2 or NOT isNumber(_aR_[1]) or NOT isNumber(_aR_[2])
		stzraise("StzNumberLineFigure: a number line needs its range, :on = [ a, b ].")
	ok
	if _aR_[2] <= _aR_[1]
		stzraise("StzNumberLineFigure: the range [ " + _NlNum(_aR_[1], 6) + ", " + _NlNum(_aR_[2], 6) +
			" ] runs backwards -- a range is [ a, b ] with a < b.")
	ok
	_d_[:on] = _aR_
	_aP_ = _FfGet(paSpec, "points", [])
	if isNumber(_aP_)  _aP_ = [ _aP_ ]  ok
	if NOT isList(_aP_)
		stzraise("StzNumberLineFigure: :points is a list of numbers, or of [ number, name ].")
	ok
	for _i_ = 1 to len(_aP_)
		_e_ = _aP_[_i_]
		if isNumber(_e_)
			_d_[:points] + [ _e_, "" ]
		but isList(_e_) and len(_e_) = 2 and isNumber(_e_[1]) and isString(_e_[2])
			_d_[:points] + [ _e_[1], _e_[2] ]
		else
			stzraise("StzNumberLineFigure: point " + _i_ + " is not a number or a [ number, name ].")
		ok
	next
	for _i_ = 1 to len(_d_[:points])
		for _j_ = 1 to _i_ - 1
			if _d_[:points][_i_][1] = _d_[:points][_j_][1]
				stzraise("StzNumberLineFigure: " + _NlNum(_d_[:points][_i_][1], 6) +
					" is placed twice -- one point stands at one number.")
			ok
		next
	next
	_aJ_ = _FfGet(paSpec, "jumps", [])
	if NOT isList(_aJ_)
		stzraise("StzNumberLineFigure: :jumps is a list of [ from, to ].")
	ok
	for _i_ = 1 to len(_aJ_)
		_e_ = _aJ_[_i_]
		if NOT isList(_e_) or len(_e_) != 2 or NOT isNumber(_e_[1]) or NOT isNumber(_e_[2])
			stzraise("StzNumberLineFigure: jump " + _i_ + " is not [ from, to ].")
		ok
		if _e_[1] = _e_[2]
			stzraise("StzNumberLineFigure: jump " + _i_ + " goes from " + _NlNum(_e_[1], 6) +
				" to itself -- a jump is a difference.")
		ok
		_d_[:jumps] + [ _e_[1], _e_[2] ]
	next
	_nS_ = _FfGet(paSpec, "step", 0)
	if NOT isNumber(_nS_) or _nS_ < 0
		stzraise("StzNumberLineFigure: :step is a positive number, the distance between ticks.")
	ok
	if _nS_ > 0 and (_aR_[2] - _aR_[1]) / _nS_ > 60
		stzraise("StzNumberLineFigure: a step of " + _NlNum(_nS_, 6) + " gives more than sixty ticks -- " +
			"a line that dense cannot be read.")
	ok
	_d_[:step] = _nS_
	_cL_ = _FfGet(paSpec, "label", "")
	if NOT isString(_cL_)
		stzraise("StzNumberLineFigure: :label is text.")
	ok
	_d_[:label] = _cL_
	return _d_

func _NlPointIndex(paP, pnV)
	for _i_ = 1 to len(paP)
		if fabs(paP[_i_][1] - pnV) < 0.000000001  return _i_  ok
	next
	return 0

func _NlSortPoints(paP)
	_a_ = []
	for _i_ = 1 to len(paP)  _a_ + [ paP[_i_][1], _i_ ]  next
	_a_ = sort(_a_, 1)
	_out_ = []
	for _i_ = 1 to len(_a_)  _out_ + paP[_a_[_i_][2]]  next
	return _out_

func _NlJumpTouches(paJumps, pnV)
	for _i_ = 1 to len(paJumps)
		if fabs(paJumps[_i_][1] - pnV) < 0.000000001 or fabs(paJumps[_i_][2] - pnV) < 0.000000001
			return TRUE
		ok
	next
	return FALSE

func _NlNiceStep(pnRange, pnTicks)
	return _FfNiceStep(pnRange, pnTicks)

func _NlNum(pn, pnDec)
	return _FfNum(pn, pnDec)

func _NlTextWidth(poFont, pcText, pnSize)
	return _FfTextWidth(poFont, pcText, pnSize)

#---------------------------------------------------------------------#
#  THE STYLE                                                           #
#---------------------------------------------------------------------#

func StzNumberLineStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(StzNumberLineFigureWidth(), StzNumberLineFigureHeight())
	_o_.SetMargin(6)
	_nT_ = StzNumberLineFigureTypeSize()
	_o_.ForAll("Axis a", [
		[ :shape, "a.icon", :line, [ :x1 = "a.x0", :y1 = "a.y", :x2 = "a.x1", :y2 = "a.y",
		                             :stroke = "neutral", :strokeWidth = 2, :arrow = "both" ] ],
		[ :shape, "a.text", :text, [ :cx = "a.tx", :cy = "a.ty", :size = StzNumberLineFigureTitleSize(),
		                             :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAll("Tick k", [
		[ :shape, "k.icon", :line, [ :x1 = "k.x", :y1 = "k.y - 6", :x2 = "k.x", :y2 = "k.y + 6",
		                             :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "k.text", :text, [ :cx = "k.x", :cy = "k.ly", :size = _nT_, :fill = "muted" ] ] ])
	_o_.ForAll("Point p", [
		[ :shape, "p.icon", :circle, [ :cx = "p.x", :cy = "p.y", :r = 6,
		                               :fill = "primary", :stroke = "background", :strokeWidth = 1.5 ] ] ])
	# A NOTE STARTS WHERE IT CAN END: an offset from its own point, on the
	# side the builder chose, and it settles off the axis, the tick numbers
	# and the other notes
	_o_.ForAllWhere("Note n; Point p", "n := Note(p)", [
		[ :unknown, "n.ox", -30, 30 ],
		[ :unknown, "n.oy", 22, 40 ],
		[ :shape, "n.text", :text, [ :cx = "p.x + n.ox", :cy = "p.y + p.side * n.oy",
		                             :size = _nT_ + 1, :fill = [ :on, "paper" ] ] ],
		[ :encourage, "near", [ "n.text", "p.icon", 24 ] ],
		[ :ensure, "lessThan", [ "dist(n.text, p.icon)", "" + StzNumberLineFigureLeash() + " + n.text.w / 2" ] ],
		[ :ensure, "disjoint", [ "n.text", "p.icon", 4 ] ],
		[ :layer, "n.text", :above, "p.icon" ] ])
	_o_.ForAll("Note n; Axis a", [
		[ :ensure, "disjoint", [ "n.text", "a.icon", 4 ] ] ])
	_o_.ForAll("Note n; Tick k", [
		[ :ensure, "disjoint", [ "n.text", "k.text", 4 ] ],
		[ :ensure, "disjoint", [ "n.text", "k.icon", 3 ] ] ])
	_o_.ForAll("Note n; Note m", [
		[ :ensure, "disjoint", [ "n.text", "m.text", 5 ] ] ])
	_o_.ForAll("Note n; Point q", [
		[ :ensure, "disjoint", [ "n.text", "q.icon", 4 ] ] ])
	# A JUMP is an arc above the line, its difference at its top, an
	# arrowhead on its last chord where it lands
	_o_.ForAllWhere("Jump j; Point p; Point q", "j := Jump(p, q)", [
		[ :shape, "j.icon", :spline, [ :n = 7, :samples = 6,
		    :x1 = "j.x1", :y1 = "j.y1", :x2 = "j.x2", :y2 = "j.y2", :x3 = "j.x3", :y3 = "j.y3",
		    :x4 = "j.x4", :y4 = "j.y4", :x5 = "j.x5", :y5 = "j.y5", :x6 = "j.x6", :y6 = "j.y6",
		    :x7 = "j.x7", :y7 = "j.y7", :stroke = "info", :strokeWidth = 2.5 ] ],
		[ :shape, "j.head", :line, [ :x1 = "j.x6", :y1 = "j.y6", :x2 = "j.x7", :y2 = "j.y7",
		                             :stroke = "info", :strokeWidth = 2.5, :arrow = "end" ] ],
		[ :shape, "j.text", :text, [ :cx = "j.lx", :cy = "j.ly", :size = _nT_ + 2, :fill = "info" ] ],
		[ :layer, "j.head", :above, "j.icon" ] ])
	_o_.ForAll("Note n; Jump j", [
		[ :ensure, "disjoint", [ "n.text", "j.text", 4 ] ] ])
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE                                        #
#---------------------------------------------------------------------#

func _NlIsNumberLine(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "numberline"

func _NlScope(poDg, pcType, pcPrefix)
	_r_ = []
	if NOT _NlIsNumberLine(poDg)  return _r_  ok
	_ac_ = poDg.Substance().ObjectsOfType(pcType)
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _NlCounter(poDg, pcPrefix)
	_r_ = []
	if NOT isObject(poDg) or _NlIsNumberLine(poDg)  return _r_  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return _r_  ok
	_ac_ = poDg.Substance().ObjectNames()
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _NlDefinitionArgs(poSubstance, pcName)
	_aD_ = poSubstance.Definitions()
	for _i_ = 1 to len(_aD_)
		if _aD_[_i_][1] = pcName  return _aD_[_i_][3]  ok
	next
	return []

func StzNumberLineRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("jump_lands_where_it_says")
	_o1_.SetClaim("a jump's landing value is its start plus the difference it prints")
	_o1_.SetOrder(73)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _NlScope(oDg, "Jump", "jump:") })
	_o1_.SetCounter(func(oDg) { return _NlCounter(oDg, "jump:") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cJ_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_aA_ = _NlDefinitionArgs(_oS_, _cJ_)
		if len(_aA_) < 2  return [ TRUE, "" ]  ok
		_nFrom_ = _oS_.DataOf("" + _aA_[1], "v")
		_nTo_ = _oS_.DataOf("" + _aA_[2], "v")
		_nD_ = _oS_.DataOf(_cJ_, "d")
		if fabs(_nFrom_ + _nD_ - _nTo_) > 0.000000001
			return [ FALSE, "the jump from " + _NlNum(_nFrom_, 6) + " prints '" + _oS_.LabelOf(_cJ_) +
				"' and lands on " + _NlNum(_nTo_, 6) + ", which is " + _NlNum(_nTo_ - _nFrom_, 6) + " away" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("points_keep_their_order")
	_o2_.SetClaim("two points stand on the line in the order of their values")
	_o2_.SetOrder(74)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) { return _NlScope(oDg, "Point", "point:") })
	_o2_.SetCounter(func(oDg) { return _NlCounter(oDg, "point:") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cP_ = StzStringSection(cSub, 7, len(cSub))
		_oS_ = oDg.Substance()
		_nV_ = _oS_.DataOf(_cP_, "v")
		_nX_ = _oS_.DataOf(_cP_, "x")
		_ac_ = _oS_.ObjectsOfType("Point")
		for _i_ = 1 to len(_ac_)
			if _ac_[_i_] = _cP_  loop  ok
			_nV2_ = _oS_.DataOf(_ac_[_i_], "v")
			_nX2_ = _oS_.DataOf(_ac_[_i_], "x")
			if (_nV2_ > _nV_ and _nX2_ < _nX_) or (_nV2_ < _nV_ and _nX2_ > _nX_)
				return [ FALSE, "the point at " + _NlNum(_nV_, 6) + " stands " + _NlNum(_nX_, 1) +
					" px along the line and the point at " + _NlNum(_nV2_, 6) + " stands " +
					_NlNum(_nX2_, 1) + " px -- the order is wrong" ]
			ok
		next
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	_o3_ = StzPlasticRule("note_reads_near_its_point")
	_o3_.SetClaim("a note stands within reach of the point it names")
	_o3_.SetOrder(75)
	_o3_.SetReads([ "picture" ])
	_o3_.SetScope(func(oDg) { return _NlScope(oDg, "Note", "note:") })
	_o3_.SetCounter(func(oDg) { return _NlCounter(oDg, "note:") })
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cN_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_aA_ = _NlDefinitionArgs(_oS_, _cN_)
		if len(_aA_) < 1  return [ TRUE, "" ]  ok
		_aT_ = oDg.ShapeOf(_cN_ + ".text")
		_aP_ = oDg.ShapeOf("" + _aA_[1] + ".icon")
		if len(_aT_) = 0 or len(_aP_) = 0  return [ TRUE, "" ]  ok
		_nD_ = sqrt(pow(_aT_[:cx] - _aP_[:cx], 2) + pow(_aT_[:cy] - _aP_[:cy], 2))
		_nR_ = StzNumberLineFigureLeash() + _aT_[:w] / 2 + 1
		if _nD_ > _nR_
			return [ FALSE, "the note '" + _oS_.LabelOf(_cN_) + "' stands " + _NlNum(_nD_, 1) +
				" px from its point, past its leash of " + _NlNum(_nR_, 1) ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o3_

	return _ao_
