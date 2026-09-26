#=====================================================================#
#  STZCOMPLEXPLANEFIGURE -- M1c: the complex plane is a FIGURE, and a  #
#  root is checked where it is drawn                                   #
#=====================================================================#
/*
	THE FIFTH VISUAL DOOR (base/math/CHARTER.md). A complex number is a
	point; the roots of a polynomial are points that come in mirrored
	pairs when the coefficients are real; a modulus is a length and an
	argument is an angle. The figure draws them, and its rules check the
	one claim the engine makes that a drawing cannot show false: that a
	point named a root IS a root -- evaluated here in Ring by Horner's
	rule, against roots the engine found by Francis QR on the companion
	matrix (poly.zig), so the picture checks the engine and not itself.

	WHAT A COMPLEX PLANE IS HERE:

	    DOMAIN     Frame, Axis (Re and Im), Tick; Point, a complex number;
	               Note, its name (a constructor over Point); Ray, the
	               segment from 0 to a shown point; Arc, its argument; Unit,
	               the unit circle. Root(Point), Given(Point), Shown(Point).

	    SUBSTANCE  built from a declaration:
	                 [ :points = [ [ 1, 2 ], [ -1, 0.5, "w" ] ],
	                   :roots = [ 1, 0, 0, -1 ],          the coefficients
	                   :unit = TRUE, :show = [ 1, 2 ], :label = "..." ]
	               The window is SQUARE in scale -- one unit is the same
	               number of pixels along both axes, or the unit circle is
	               not a circle -- and symmetric about 0.

	    STYLE      the frame, the axes arrowed with Re and Im, ticks at
	               the frame edges; a point as a dot, hollow when a root;
	               a note SOLVED beside its point on the side away from the
	               real axis; the unit circle faint; the ray and the arc of
	               a shown point in the info colour with |z| and arg z
	               written on them.

	WHAT THE DOMAIN OWES THE GATE:

	    root_is_a_root          p(z) is small at every point named a root
	    conjugates_pair         a root off the real axis has its mirror
	    note_reads_near_its_point

	WHAT IS SAID PLAINLY: coefficients are given as stzPolynomial takes
	them; a polynomial of degree under one has no roots to draw and is
	refused; the branch cut of log is not drawn, because complex log is
	not in the library yet (a routed question of M5).
*/

StzRegisterMathRuleSet("complexplane", StzComplexPlaneRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzComplexPlaneDomain()
	_o_ = new stzMathDomain("complexplane")
	_o_.AddType("Frame")
	_o_.AddType("Axis")
	_o_.AddType("Tick")
	_o_.AddType("Point")
	_o_.AddType("Note")
	_o_.AddType("Ray")
	_o_.AddType("Arc")
	_o_.AddType("Unit")
	_o_.AddConstructor("Note", [ "Point" ])
	_o_.AddConstructor("Ray", [ "Point" ])
	_o_.AddConstructor("Arc", [ "Point" ])
	_o_.AddPredicate("Root", [ "Point" ])
	_o_.AddPredicate("Given", [ "Point" ])
	_o_.AddPredicate("Shown", [ "Point" ])
	_o_.AddPredicate("OnY", [ "Tick" ])
	return _o_

func StzComplexPlaneFigureWidth()
	return 900

func StzComplexPlaneFigureHeight()
	return 620

func StzComplexPlaneFigureTypeSize()
	return 15

func StzComplexPlaneFigureTitleSize()
	return 20

func StzComplexPlaneFigureLeash()
	return 40

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM A DECLARATION                                   #
#---------------------------------------------------------------------#

func StzComplexPlaneFigureKeys()
	return [ "points", "roots", "unit", "show", "label", "range" ]

func StzComplexPlaneFigureFrom(paSpec)
	return StzComplexPlaneFigureFromXT(NULL, paSpec)

func StzComplexPlaneFigureBuildXT(poFont, paSpec)
	_oS_ = StzComplexPlaneFigureFromXT(poFont, paSpec)
	_o_ = new stzMathDiagram(_oS_.DomainQ(), _oS_, StzComplexPlaneStyle())
	if isObject(poFont)  _o_.SetFont(poFont, StzComplexPlaneFigureTypeSize())  ok
	_o_.SetVariation("complexplane")
	return _o_

func StzComplexPlaneFigureFromXT(poFont, paSpec)
	_d_ = _CpDeclaration(paSpec)
	_aP_ = []           # [ re, im, name, kind ]
	for _i_ = 1 to len(_d_[:points])
		_aP_ + [ _d_[:points][_i_][1], _d_[:points][_i_][2], _d_[:points][_i_][3], "given" ]
	next
	_aCo_ = _d_[:roots]
	if len(_aCo_) > 0
		_oPoly_ = new stzPolynomial(_aCo_)
		_aR_ = _oPoly_.ComplexRoots()
		for _i_ = 1 to len(_aR_)
			_aP_ + [ _aR_[_i_].RealPart(), _aR_[_i_].ImaginaryPart(), "", "root" ]
		next
	ok

	# THE WINDOW: square in scale, symmetric about 0, holding every point
	# with air, and the unit circle when asked
	_nMax_ = 0
	for _i_ = 1 to len(_aP_)
		if fabs(_aP_[_i_][1]) > _nMax_  _nMax_ = fabs(_aP_[_i_][1])  ok
		if fabs(_aP_[_i_][2]) > _nMax_  _nMax_ = fabs(_aP_[_i_][2])  ok
	next
	if _d_[:unit] and _nMax_ < 1  _nMax_ = 1  ok
	if _nMax_ = 0  _nMax_ = 1  ok
	_nExt_ = _nMax_ * 1.25
	if len(_d_[:range]) = 1  _nExt_ = _d_[:range][1]  ok
	_nL_ = 78  _nT_ = 48
	_nPw_ = StzComplexPlaneFigureWidth() - _nL_ - 54
	_nPh_ = StzComplexPlaneFigureHeight() - _nT_ - 56
	# one scale for both axes: the smaller of the two the frame allows
	_nK_ = _nPh_ / (2 * _nExt_)
	_nExtX_ = _nPw_ / (2 * _nK_)
	_nCx_ = _nL_ + _nPw_ / 2
	_nCy_ = _nT_ + _nPh_ / 2

	_oS_ = new stzMathSubstance(StzComplexPlaneDomain())
	_oS_.Declare("Frame", "fr")
	_oS_.Label("fr", _d_[:label])
	_oS_.SetData("fr", "x0", _nL_)  _oS_.SetData("fr", "y0", _nT_)
	_oS_.SetData("fr", "x1", _nL_ + _nPw_)  _oS_.SetData("fr", "y1", _nT_ + _nPh_)
	_oS_.SetData("fr", "cx", _nCx_)  _oS_.SetData("fr", "cy", _nCy_)
	_oS_.SetData("fr", "k", _nK_)
	_oS_.SetData("fr", "ext", _nExt_)  _oS_.SetData("fr", "extx", _nExtX_)
	_oS_.SetData("fr", "tx", _nL_ + _FfTextWidth(poFont, _d_[:label], StzComplexPlaneFigureTitleSize()) / 2)
	_oS_.SetData("fr", "ty", _nT_ / 2)
	_oS_.SetData("fr", "points", len(_aP_))
	_oS_.SetData("fr", "roots", len(_aCo_))
	_oS_.SetData("fr", "degree", 0)
	if len(_aCo_) > 0  _oS_.SetData("fr", "degree", len(_aCo_) - 1)  ok
	for _i_ = 1 to len(_aCo_)
		_oS_.SetData("fr", "c" + _i_, _aCo_[_i_])
	next
	_oS_.SetData("fr", "unit", _d_[:unit])

	# the axes through 0, named Re and Im
	_oS_.Declare("Axis", "ax")
	_oS_.Label("ax", "Re")
	_oS_.SetData("ax", "x0", _nL_)  _oS_.SetData("ax", "y0", _nCy_)
	_oS_.SetData("ax", "x1", _nL_ + _nPw_ + 14)  _oS_.SetData("ax", "y1", _nCy_)
	_oS_.SetData("ax", "lx", _nL_ + _nPw_ + 22 + _FfTextWidth(poFont, "Re", StzComplexPlaneFigureTypeSize() + 2) / 2)
	_oS_.SetData("ax", "ly", _nCy_)
	_oS_.Declare("Axis", "ay")
	_oS_.Label("ay", "Im")
	_oS_.SetData("ay", "x0", _nCx_)  _oS_.SetData("ay", "y0", _nT_ + _nPh_)
	_oS_.SetData("ay", "x1", _nCx_)  _oS_.SetData("ay", "y1", _nT_ - 10)
	_oS_.SetData("ay", "lx", _nCx_ + 12 + _FfTextWidth(poFont, "Im", StzComplexPlaneFigureTypeSize() + 2) / 2)
	_oS_.SetData("ay", "ly", _nT_ - 19)

	# the ticks at the frame edges, one nice step for both axes
	_nStep_ = _FfNiceStep(2 * _nExt_, 6)
	_nKt_ = 0
	for _j_ = ceil(-_nExtX_ / _nStep_) to floor(_nExtX_ / _nStep_)
		_v_ = _j_ * _nStep_
		_nKt_++
		_oS_.Declare("Tick", "tx" + _nKt_)
		_oS_.Label("tx" + _nKt_, _FfNum(_v_, 6))
		_oS_.SetData("tx" + _nKt_, "v", _v_)
		_oS_.SetData("tx" + _nKt_, "x", _nCx_ + _v_ * _nK_)
		_oS_.SetData("tx" + _nKt_, "y", _nT_ + _nPh_ + 3)
		_oS_.SetData("tx" + _nKt_, "dx", 0)  _oS_.SetData("tx" + _nKt_, "dy", 3)
		_oS_.SetData("tx" + _nKt_, "lx", _nCx_ + _v_ * _nK_)
		_oS_.SetData("tx" + _nKt_, "ly", _nT_ + _nPh_ + 19)
	next
	_nKt_ = 0
	for _j_ = ceil(-_nExt_ / _nStep_) to floor(_nExt_ / _nStep_)
		_v_ = _j_ * _nStep_
		_nKt_++
		_c_ = _FfNum(_v_, 6)
		if _v_ != 0  _c_ += "i"  ok
		_oS_.Declare("Tick", "ty" + _nKt_)
		_oS_.Assert("OnY", [ "ty" + _nKt_ ])
		_oS_.Label("ty" + _nKt_, _c_)
		_oS_.SetData("ty" + _nKt_, "v", _v_)
		_oS_.SetData("ty" + _nKt_, "x", _nL_ - 3)
		_oS_.SetData("ty" + _nKt_, "y", _nCy_ - _v_ * _nK_)
		_oS_.SetData("ty" + _nKt_, "dx", 3)  _oS_.SetData("ty" + _nKt_, "dy", 0)
		_oS_.SetData("ty" + _nKt_, "lx", _nL_ - 13 - _FfTextWidth(poFont, _c_, StzComplexPlaneFigureTypeSize()) / 2)
		_oS_.SetData("ty" + _nKt_, "ly", _nCy_ - _v_ * _nK_)
	next

	# the unit circle
	if _d_[:unit]
		_oS_.Declare("Unit", "unit")
		_oS_.Label("unit", "")
		_oS_.SetData("unit", "x", _nCx_)  _oS_.SetData("unit", "y", _nCy_)
		_oS_.SetData("unit", "r", _nK_)
	ok

	# the points and their notes; a root is hollow, a given point filled
	for _i_ = 1 to len(_aP_)
		_re_ = _aP_[_i_][1]
		_im_ = _aP_[_i_][2]
		_cP_ = "p" + _i_
		_oS_.Declare("Point", _cP_)
		_oS_.Label(_cP_, "")
		_oS_.SetData(_cP_, "re", _re_)  _oS_.SetData(_cP_, "im", _im_)
		_oS_.SetData(_cP_, "x", _nCx_ + _re_ * _nK_)
		_oS_.SetData(_cP_, "y", _nCy_ - _im_ * _nK_)
		# a note stands away from the real axis: above a point on or over
		# it, below a point under it
		_nSide_ = -1
		if _im_ < 0  _nSide_ = 1  ok
		_oS_.SetData(_cP_, "side", _nSide_)
		if _aP_[_i_][4] = "root"
			_oS_.Assert("Root", [ _cP_ ])
		else
			_oS_.Assert("Given", [ _cP_ ])
		ok
		_cText_ = _CpText(_re_, _im_)
		if _aP_[_i_][3] != ""  _cText_ = _aP_[_i_][3] + " = " + _cText_  ok
		_oS_.Define("n" + _i_, "Note", [ _cP_ ])
		_oS_.Label("n" + _i_, _cText_)
	next

	# the shown point: its ray from 0 with |z| on it, its argument arc
	if len(_d_[:show]) = 2
		_re_ = _d_[:show][1]
		_im_ = _d_[:show][2]
		_k_ = 0
		for _i_ = 1 to len(_aP_)
			if fabs(_aP_[_i_][1] - _re_) < 0.000000001 and fabs(_aP_[_i_][2] - _im_) < 0.000000001  _k_ = _i_  ok
		next
		if _k_ = 0
			stzraise("StzComplexPlaneFigure: the point to show, " + _CpText(_re_, _im_) +
				", is not one of the figure's points.")
		ok
		_cP_ = "p" + _k_
		_oS_.Assert("Shown", [ _cP_ ])
		_nMod_ = sqrt(_re_ * _re_ + _im_ * _im_)
		_nArg_ = atan2(_im_, _re_)
		_oS_.Define("ray", "Ray", [ _cP_ ])
		_oS_.Label("ray", "|z| = " + _FfNum(_nMod_, 3))
		_oS_.SetData("ray", "mod", _nMod_)
		_oS_.SetData("ray", "x1", _nCx_)  _oS_.SetData("ray", "y1", _nCy_)
		_oS_.SetData("ray", "x2", _nCx_ + _re_ * _nK_)  _oS_.SetData("ray", "y2", _nCy_ - _im_ * _nK_)
		# the name of the length stands beside the ray's middle, on the
		# side away from the argument arc
		_nNx_ = -sin(_nArg_)  _nNy_ = -cos(_nArg_)
		_oS_.SetData("ray", "lx", _nCx_ + _re_ * _nK_ / 2 + _nNx_ * 22 * _nSide_)
		_oS_.SetData("ray", "ly", _nCy_ - _im_ * _nK_ / 2 + _nNy_ * 22 * _nSide_)
		_oS_.Define("arc", "Arc", [ _cP_ ])
		_oS_.Label("arc", "arg z = " + _FfNum(_nArg_ * 180 / 3.14159265358979, 1) + " deg")
		_oS_.SetData("arc", "arg", _nArg_)
		_nRa_ = 46
		if _nMod_ * _nK_ < 70  _nRa_ = _nMod_ * _nK_ * 0.6  ok
		for _q_ = 0 to 6
			_t_ = _nArg_ * _q_ / 6
			_oS_.SetData("arc", "x" + (_q_ + 1), _nCx_ + _nRa_ * cos(_t_))
			_oS_.SetData("arc", "y" + (_q_ + 1), _nCy_ - _nRa_ * sin(_t_))
		next
		_oS_.SetData("arc", "lx", _nCx_ + (_nRa_ + 34 + _FfTextWidth(poFont, "arg z = 000.0 deg", StzComplexPlaneFigureTypeSize()) / 2) * cos(_nArg_ / 2))
		_oS_.SetData("arc", "ly", _nCy_ - (_nRa_ + 22) * sin(_nArg_ / 2))
	ok
	return _oS_

# a complex number as it reads: "1 + 2i", "-0.5 - 0.866i", "1", "2i"
func _CpText(pnRe, pnIm)
	_cRe_ = _FfNum(pnRe, 3)
	_cIm_ = _FfNum(fabs(pnIm), 3)
	if fabs(pnIm) < 0.0005  return _cRe_  ok
	_cSign_ = " + "
	if pnIm < 0  _cSign_ = " - "  ok
	if fabs(pnRe) < 0.0005
		if pnIm < 0  return "-" + _cIm_ + "i"  ok
		return _cIm_ + "i"
	ok
	return _cRe_ + _cSign_ + _cIm_ + "i"

func StzComplexPlaneFigureWhy(poSubstance)
	_c_ = "a complex plane: " + poSubstance.DataOf("fr", "points") + " point(s)"
	if poSubstance.DataOf("fr", "degree") > 0
		_c_ += ", among them the " + poSubstance.DataOf("fr", "degree") + " root(s) of a polynomial of degree " +
			poSubstance.DataOf("fr", "degree")
	ok
	if poSubstance.DataOf("fr", "unit") = 1  _c_ += ", the unit circle"  ok
	return _c_

#-- the declaration, read and refused by name -------------------------

func _CpDeclaration(paSpec)
	if NOT isList(paSpec) or len(paSpec) = 0
		stzraise("StzComplexPlaneFigure: a complex plane is declared as keys, like [ :points = [ [ 1, 2 ] ] ].")
	ok
	_acKeys_ = StzComplexPlaneFigureKeys()
	for _i_ = 1 to len(paSpec)
		_e_ = paSpec[_i_]
		if NOT isList(_e_) or len(_e_) != 2 or NOT isString(_e_[1])
			stzraise("StzComplexPlaneFigure: entry " + _i_ + " of the declaration is not a key and a value.")
		ok
		if NOT _FfIn(_acKeys_, StzLower(_e_[1]))
			stzraise("StzComplexPlaneFigure: ':" + _e_[1] + "' is not a key of a complex plane -- " +
				"the keys are " + @@(_acKeys_) + ".")
		ok
	next
	_d_ = [ :points = [], :roots = [], :unit = FALSE, :show = [], :label = "", :range = [] ]
	_aP_ = _FfGet(paSpec, "points", [])
	if NOT isList(_aP_)
		stzraise("StzComplexPlaneFigure: :points is a list of [ re, im ] or [ re, im, name ].")
	ok
	for _i_ = 1 to len(_aP_)
		_e_ = _aP_[_i_]
		if isList(_e_) and len(_e_) = 2 and isNumber(_e_[1]) and isNumber(_e_[2])
			_d_[:points] + [ _e_[1], _e_[2], "" ]
		but isList(_e_) and len(_e_) = 3 and isNumber(_e_[1]) and isNumber(_e_[2]) and isString(_e_[3])
			_d_[:points] + [ _e_[1], _e_[2], _e_[3] ]
		else
			stzraise("StzComplexPlaneFigure: point " + _i_ + " is not [ re, im ] or [ re, im, name ].")
		ok
	next
	_aR_ = _FfGet(paSpec, "roots", [])
	if NOT isList(_aR_)
		stzraise("StzComplexPlaneFigure: :roots is the list of a polynomial's coefficients.")
	ok
	if len(_aR_) > 0
		if len(_aR_) < 2
			stzraise("StzComplexPlaneFigure: a polynomial of degree under one has no root to draw.")
		ok
		for _i_ = 1 to len(_aR_)
			if NOT isNumber(_aR_[_i_])
				stzraise("StzComplexPlaneFigure: coefficient " + _i_ + " is not a number.")
			ok
		next
		if _aR_[1] = 0
			stzraise("StzComplexPlaneFigure: the leading coefficient is zero -- say the polynomial's true degree.")
		ok
		if len(_aR_) > 13
			stzraise("StzComplexPlaneFigure: a polynomial of degree over twelve has more roots than a picture names.")
		ok
		_d_[:roots] = _aR_
	ok
	if len(_d_[:points]) = 0 and len(_d_[:roots]) = 0
		stzraise("StzComplexPlaneFigure: say what to draw -- :points, or :roots of a polynomial.")
	ok
	_u_ = _FfGet(paSpec, "unit", FALSE)
	if NOT isNumber(_u_)
		stzraise("StzComplexPlaneFigure: :unit is TRUE or FALSE.")
	ok
	_d_[:unit] = (_u_ != 0)
	_aSh_ = _FfGet(paSpec, "show", [])
	if isList(_aSh_) and len(_aSh_) > 0
		if len(_aSh_) != 2 or NOT isNumber(_aSh_[1]) or NOT isNumber(_aSh_[2])
			stzraise("StzComplexPlaneFigure: :show is [ re, im ], one of the figure's points.")
		ok
		_d_[:show] = [ _aSh_[1], _aSh_[2] ]
	ok
	_nR_ = _FfGet(paSpec, "range", "")
	if isNumber(_nR_)
		if _nR_ <= 0
			stzraise("StzComplexPlaneFigure: :range is the half-width of the window, a positive number.")
		ok
		_d_[:range] = [ _nR_ ]
	ok
	_cL_ = _FfGet(paSpec, "label", "")
	if NOT isString(_cL_)
		stzraise("StzComplexPlaneFigure: :label is text.")
	ok
	_d_[:label] = _cL_
	return _d_

#---------------------------------------------------------------------#
#  THE STYLE                                                           #
#---------------------------------------------------------------------#

func StzComplexPlaneStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(StzComplexPlaneFigureWidth(), StzComplexPlaneFigureHeight())
	_o_.SetMargin(6)
	_nT_ = StzComplexPlaneFigureTypeSize()
	_o_.ForAll("Frame f", [
		[ :shape, "f.box", :rect, [ :cx = "(f.x0 + f.x1) / 2", :cy = "(f.y0 + f.y1) / 2",
		                            :w = "f.x1 - f.x0", :h = "f.y1 - f.y0",
		                            :fill = [ :alpha, "primary", 0.05 ], :stroke = "muted", :strokeWidth = 1 ] ],
		[ :shape, "f.text", :text, [ :cx = "f.tx", :cy = "f.ty", :size = StzComplexPlaneFigureTitleSize(),
		                             :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAll("Axis a", [
		[ :shape, "a.icon", :line, [ :x1 = "a.x0", :y1 = "a.y0", :x2 = "a.x1", :y2 = "a.y1",
		                             :stroke = "neutral", :strokeWidth = 1.5, :arrow = "end" ] ],
		[ :shape, "a.text", :text, [ :cx = "a.lx", :cy = "a.ly", :size = _nT_ + 2, :fill = "neutral" ] ] ])
	_o_.ForAll("Tick k", [
		[ :shape, "k.icon", :line, [ :x1 = "k.x - k.dx", :y1 = "k.y - k.dy", :x2 = "k.x + k.dx", :y2 = "k.y + k.dy",
		                             :stroke = "neutral", :strokeWidth = 1 ] ],
		[ :shape, "k.text", :text, [ :cx = "k.lx", :cy = "k.ly", :size = _nT_, :fill = "muted" ] ] ])
	_o_.ForAll("Unit u", [
		[ :shape, "u.icon", :circle, [ :cx = "u.x", :cy = "u.y", :r = "u.r",
		                               :stroke = [ :alpha, "primary", 0.45 ], :strokeWidth = 1.5 ] ] ])
	_o_.ForAll("Point p", [
		[ :shape, "p.icon", :circle, [ :cx = "p.x", :cy = "p.y", :r = 5.5,
		                               :fill = "info", :stroke = "background", :strokeWidth = 1.5 ] ] ])
	_o_.ForAllWhere("Point p", "Root(p)", [
		[ :delete, "p.icon" ],
		[ :shape, "p.icon", :circle, [ :cx = "p.x", :cy = "p.y", :r = 5.5,
		                               :fill = "background", :stroke = "primary", :strokeWidth = 2.2 ] ] ])
	# A NOTE STARTS WHERE IT CAN END: an offset from its point, away from
	# the real axis, and settles off the axes, the ticks, the ray, the arc,
	# the other points and the other notes
	_o_.ForAllWhere("Note n; Point p", "n := Note(p)", [
		[ :unknown, "n.ox", -40, 40 ],
		[ :unknown, "n.oy", 18, 40 ],
		[ :shape, "n.text", :text, [ :cx = "p.x + n.ox", :cy = "p.y + p.side * n.oy",
		                             :size = _nT_, :fill = [ :on, "paper" ] ] ],
		[ :encourage, "near", [ "n.text", "p.icon", 22 ] ],
		[ :ensure, "lessThan", [ "dist(n.text, p.icon)", "" + StzComplexPlaneFigureLeash() + " + n.text.w / 2" ] ],
		[ :ensure, "disjoint", [ "n.text", "p.icon", 4 ] ],
		[ :layer, "n.text", :above, "p.icon" ] ])
	_o_.ForAll("Note n; Axis a", [
		[ :ensure, "disjoint", [ "n.text", "a.icon", 5 ] ],
		[ :ensure, "disjoint", [ "n.text", "a.text", 4 ] ] ])
	_o_.ForAll("Note n; Tick k", [
		[ :ensure, "disjoint", [ "n.text", "k.text", 4 ] ] ])
	_o_.ForAll("Note n; Note m", [
		[ :ensure, "disjoint", [ "n.text", "m.text", 4 ] ] ])
	_o_.ForAll("Note n; Point q", [
		[ :ensure, "disjoint", [ "n.text", "q.icon", 4 ] ] ])
	_o_.ForAll("Note n; Frame f", [
		[ :ensure, "contains", [ "f.box", "n.text", 5 ] ],
		[ :ensure, "disjoint", [ "n.text", "f.text", 6 ] ] ])
	_o_.ForAll("Note n; Unit u", [
		[ :ensure, "disjoint", [ "n.text", "u.icon", 3 ] ] ])
	# THE SHOWN POINT: its ray with |z| written beside it, its argument
	# arc with arg z written past it
	_o_.ForAllWhere("Ray r; Point p", "r := Ray(p)", [
		[ :shape, "r.icon", :line, [ :x1 = "r.x1", :y1 = "r.y1", :x2 = "r.x2", :y2 = "r.y2",
		                             :stroke = "info", :strokeWidth = 2 ] ],
		[ :shape, "r.text", :text, [ :cx = "r.lx", :cy = "r.ly", :size = _nT_, :fill = "info" ] ],
		[ :layer, "p.icon", :above, "r.icon" ] ])
	_o_.ForAllWhere("Arc c; Point p", "c := Arc(p)", [
		[ :shape, "c.icon", :spline, [ :n = 7, :samples = 5,
		    :x1 = "c.x1", :y1 = "c.y1", :x2 = "c.x2", :y2 = "c.y2", :x3 = "c.x3", :y3 = "c.y3",
		    :x4 = "c.x4", :y4 = "c.y4", :x5 = "c.x5", :y5 = "c.y5", :x6 = "c.x6", :y6 = "c.y6",
		    :x7 = "c.x7", :y7 = "c.y7", :stroke = "info", :strokeWidth = 1.5 ] ],
		[ :shape, "c.text", :text, [ :cx = "c.lx", :cy = "c.ly", :size = _nT_, :fill = "info" ] ] ])
	_o_.ForAll("Note n; Ray r", [
		[ :ensure, "disjoint", [ "n.text", "r.icon", 4 ] ],
		[ :ensure, "disjoint", [ "n.text", "r.text", 4 ] ] ])
	_o_.ForAll("Note n; Arc c", [
		[ :ensure, "disjoint", [ "n.text", "c.text", 4 ] ] ])
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE                                        #
#---------------------------------------------------------------------#

func _CpIsComplexPlane(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "complexplane"

func _CpRoots(poDg, pcPrefix)
	_r_ = []
	if NOT _CpIsComplexPlane(poDg)  return _r_  ok
	_oS_ = poDg.Substance()
	_ac_ = _oS_.ObjectsOfType("Point")
	for _i_ = 1 to len(_ac_)
		if _oS_.Holds("Root", [ _ac_[_i_] ])  _r_ + (pcPrefix + _ac_[_i_])  ok
	next
	return _r_

func _CpNotes(poDg, pcPrefix)
	_r_ = []
	if NOT _CpIsComplexPlane(poDg)  return _r_  ok
	_ac_ = poDg.Substance().ObjectsOfType("Note")
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _CpCounter(poDg, pcPrefix)
	_r_ = []
	if NOT isObject(poDg) or _CpIsComplexPlane(poDg)  return _r_  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return _r_  ok
	_ac_ = poDg.Substance().ObjectNames()
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

# p(z) by Horner's rule in Ring, on the coefficients the frame carries --
# a computation the engine's root finder never made
func _CpHorner(poSubstance, pnRe, pnIm)
	_n_ = poSubstance.DataOf("fr", "degree") + 1
	_re_ = 0  _im_ = 0
	for _i_ = 1 to _n_
		_c_ = poSubstance.DataOf("fr", "c" + _i_)
		_t_ = _re_ * pnRe - _im_ * pnIm + _c_
		_im_ = _re_ * pnIm + _im_ * pnRe
		_re_ = _t_
	next
	return sqrt(_re_ * _re_ + _im_ * _im_)

func _CpCoeffScale(poSubstance)
	_n_ = poSubstance.DataOf("fr", "degree") + 1
	_m_ = 0
	for _i_ = 1 to _n_
		if fabs(poSubstance.DataOf("fr", "c" + _i_)) > _m_  _m_ = fabs(poSubstance.DataOf("fr", "c" + _i_))  ok
	next
	return _m_

func StzComplexPlaneRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("root_is_a_root")
	_o1_.SetClaim("the polynomial is small at every point named a root")
	_o1_.SetOrder(82)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _CpRoots(oDg, "root:") })
	_o1_.SetCounter(func(oDg) { return _CpCounter(oDg, "root:") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cP_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_re_ = _oS_.DataOf(_cP_, "re")
		_im_ = _oS_.DataOf(_cP_, "im")
		_nV_ = _CpHorner(_oS_, _re_, _im_)
		_nTol_ = 0.000001 * (1 + _CpCoeffScale(_oS_)) * (1 + pow(sqrt(_re_ * _re_ + _im_ * _im_), _oS_.DataOf("fr", "degree")))
		if _nV_ > _nTol_
			return [ FALSE, "at " + _CpText(_re_, _im_) + " the polynomial is " + _FfNum(_nV_, 6) +
				" in modulus, not a root" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("conjugates_pair")
	_o2_.SetClaim("a root off the real axis has its mirror among the roots")
	_o2_.SetOrder(83)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) { return _CpRoots(oDg, "root:") })
	_o2_.SetCounter(func(oDg) { return _CpCounter(oDg, "root:") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cP_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_re_ = _oS_.DataOf(_cP_, "re")
		_im_ = _oS_.DataOf(_cP_, "im")
		if fabs(_im_) < 0.000001  return [ TRUE, "" ]  ok
		_ac_ = _oS_.ObjectsOfType("Point")
		for _i_ = 1 to len(_ac_)
			if NOT _oS_.Holds("Root", [ _ac_[_i_] ])  loop  ok
			if fabs(_oS_.DataOf(_ac_[_i_], "re") - _re_) < 0.000001 and
			   fabs(_oS_.DataOf(_ac_[_i_], "im") + _im_) < 0.000001
				return [ TRUE, "" ]
			ok
		next
		return [ FALSE, "the root " + _CpText(_re_, _im_) + " has no mirror " + _CpText(_re_, -_im_) +
			" among the roots" ]
	})
	_ao_ + _o2_

	_o3_ = StzPlasticRule("note_reads_near_its_number")
	_o3_.SetClaim("a note stands within reach of the number it names")
	_o3_.SetOrder(84)
	_o3_.SetReads([ "picture" ])
	_o3_.SetScope(func(oDg) { return _CpNotes(oDg, "note:") })
	_o3_.SetCounter(func(oDg) { return _CpCounter(oDg, "note:") })
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cN_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_aD_ = _oS_.Definitions()
		_cP_ = ""
		for _i_ = 1 to len(_aD_)
			if _aD_[_i_][1] = _cN_  _cP_ = "" + _aD_[_i_][3][1]  ok
		next
		if _cP_ = ""  return [ TRUE, "" ]  ok
		_aT_ = oDg.ShapeOf(_cN_ + ".text")
		_aP_ = oDg.ShapeOf(_cP_ + ".icon")
		if len(_aT_) = 0 or len(_aP_) = 0  return [ TRUE, "" ]  ok
		_nD_ = sqrt(pow(_aT_[:cx] - _aP_[:cx], 2) + pow(_aT_[:cy] - _aP_[:cy], 2))
		_nR_ = StzComplexPlaneFigureLeash() + _aT_[:w] / 2 + 1
		if _nD_ > _nR_
			return [ FALSE, "the note '" + _oS_.LabelOf(_cN_) + "' stands " + _FfNum(_nD_, 1) +
				" px from its number, past its leash of " + _FfNum(_nR_, 1) ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o3_

	return _ao_
