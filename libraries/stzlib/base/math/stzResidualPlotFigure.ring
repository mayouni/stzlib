#=====================================================================#
#  STZRESIDUALPLOTFIGURE -- residual versus fit, as a figure of M1     #
#  (SOFTANZA_TUKEY_PLAN.md 2.8, TK3; plane stzlib-math, M4c)           #
#=====================================================================#
/*
	The one picture that tells whether a two-way fit is honest: every
	cell as a point whose x is its FITTED value (common + row effect +
	column effect) and whose y is its RESIDUAL, with the zero line and
	Tukey's FENCES on the residual batch -- outside at hinge -+ 1.5
	fourth-spreads, far out at hinge -+ 3 -- the same rule the summary,
	the box plot and the verdicts use, so "far out" is one word here. A
	fit that misses a corner of the table shows it as a point past a
	fence; a fit that needs a re-expression shows it as a bow.

	    oF = StzMathFigureQ(:ResidualPlot, [ :of = aRows, :names = [ aRowNames, aColNames ] ])
	    ? oF.Why()
	    #--> a residual-versus-fit of 5 x 3 cells: common 8, residual fourth-spread 1, ...

	Keys: :of (the table as rows), :names ([ row names, column names ],
	optional), :label. The polish is R's, through eda.zig; nothing is
	solved -- every point sits where its two numbers put it -- and the
	rules read it back: a point is its cell (its fit is common + row +
	column, and it is drawn there), and the fences are the residuals'
	hinges and fourth-spread recomputed from the points themselves.
*/

StzRegisterMathRuleSet("residualplot", StzResidualPlotRuleSet())

func StzResidualPlotDomain()
	_o_ = new stzMathDomain("residualplot")
	_o_.AddType("Frame")
	_o_.AddType("Axis")
	_o_.AddType("Tick")
	_o_.AddType("Row")
	_o_.AddType("Col")
	_o_.AddType("Point")
	_o_.AddType("Band")
	_o_.AddType("Note")
	_o_.AddConstructor("Note", [ "Point" ])
	_o_.AddPredicate("Outside", [ "Point" ])
	_o_.AddPredicate("FarOut", [ "Point" ])
	_o_.AddPredicate("OnY", [ "Tick" ])
	_o_.AddPredicate("Stacked", [ "Point" ])
	return _o_

func StzResidualPlotFigureWidth()
	return 760
func StzResidualPlotFigureHeight()
	return 500
func StzResidualPlotFigureTypeSize()
	return 15
func StzResidualPlotFigureTitleSize()
	return 20
func StzResidualPlotFigureMaxCells()
	return 400

func StzResidualPlotFigureKeys()
	return [ "of", "names", "label" ]

func StzResidualPlotFigureFrom(paSpec)
	return StzResidualPlotFigureFromXT(StzMathFigureFont(), paSpec)

func StzResidualPlotFigureBuildXT(poFont, paSpec)
	_oS_ = StzResidualPlotFigureFromXT(poFont, paSpec)
	_o_ = new stzMathDiagram(StzResidualPlotDomain(), _oS_, StzResidualPlotStyle())
	_o_.SetFont(poFont, StzResidualPlotFigureTypeSize())
	return _o_

func StzResidualPlotFigureFromXT(poFont, paSpec)
	_d_ = _RpDeclaration(paSpec)
	_aRows_ = _d_[:rows]
	_nR_ = len(_aRows_)
	_nC_ = len(_aRows_[1])
	# THE POLISH, R's, in one crossing
	_aP_ = StzEngineTukeyPolish(_aRows_, 0.01, 10)
	if NOT isList(_aP_) or len(_aP_) < 6
		stzraise("StzResidualPlotFigure: the engine refused the table.")
	ok
	_nCommon_ = _aP_[1]
	_aRe_ = _aP_[2]
	_aCe_ = _aP_[3]
	_aRes_ = _aP_[4]
	# the residual scale: the fourth-spread of all residuals
	_aFlat_ = []
	for _i_ = 1 to _nR_
		for _j_ = 1 to _nC_
			_aFlat_ + _aRes_[_i_][_j_]
		next
	next
	_aF_ = StzEngineTukeyFourths(_aFlat_)
	_nS_ = _aF_[2] - _aF_[1]
	_nFlo_ = _aF_[1]
	_nFhi_ = _aF_[2]
	# the ranges
	_nFmin_ = 0  _nFmax_ = 0  _nRmax_ = 0  _bAny_ = FALSE
	for _i_ = 1 to _nR_
		for _j_ = 1 to _nC_
			_f_ = _nCommon_ + _aRe_[_i_] + _aCe_[_j_]
			if NOT _bAny_  _nFmin_ = _f_  _nFmax_ = _f_  _bAny_ = TRUE  ok
			if _f_ < _nFmin_  _nFmin_ = _f_  ok
			if _f_ > _nFmax_  _nFmax_ = _f_  ok
			if fabs(_aRes_[_i_][_j_]) > _nRmax_  _nRmax_ = fabs(_aRes_[_i_][_j_])  ok
		next
	next
	if _nFmax_ - _nFmin_ < 0.000000001  _nFmin_ -= 1  _nFmax_ += 1  ok
	_nPad_ = (_nFmax_ - _nFmin_) * 0.08
	_nVmin_ = _nFmin_ - _nPad_
	_nVmax_ = _nFmax_ + _nPad_
	_nRr_ = _nRmax_
	if fabs(_nFhi_ + 3 * _nS_) > _nRr_  _nRr_ = fabs(_nFhi_ + 3 * _nS_)  ok
	if fabs(_nFlo_ - 3 * _nS_) > _nRr_  _nRr_ = fabs(_nFlo_ - 3 * _nS_)  ok
	if _nRr_ <= 0  _nRr_ = 1  ok
	_nRr_ = _nRr_ * 1.15
	_nL_ = 84
	_nT_ = 56
	if _d_[:label] = ""  _nT_ = 30  ok
	_nPw_ = StzResidualPlotFigureWidth() - _nL_ - 40
	_nPh_ = StzResidualPlotFigureHeight() - _nT_ - 70
	_nKx_ = _nPw_ / (_nVmax_ - _nVmin_)
	_nKy_ = (_nPh_ / 2) / _nRr_
	_nZy_ = _nT_ + _nPh_ / 2
	_oS_ = new stzMathSubstance(StzResidualPlotDomain())
	_oS_.Declare("Frame", "fr")
	_oS_.Label("fr", _d_[:label])
	_oS_.SetData("fr", "x0", _nL_)  _oS_.SetData("fr", "y0", _nT_)
	_oS_.SetData("fr", "x1", _nL_ + _nPw_)  _oS_.SetData("fr", "y1", _nT_ + _nPh_)
	_oS_.SetData("fr", "vmin", _nVmin_)  _oS_.SetData("fr", "vmax", _nVmax_)
	_oS_.SetData("fr", "kx", _nKx_)  _oS_.SetData("fr", "ky", _nKy_)  _oS_.SetData("fr", "zy", _nZy_)
	_oS_.SetData("fr", "common", _nCommon_)  _oS_.SetData("fr", "scale", _nS_)
	_oS_.SetData("fr", "flo", _nFlo_)  _oS_.SetData("fr", "fhi", _nFhi_)
	_oS_.SetData("fr", "rows", _nR_)  _oS_.SetData("fr", "cols", _nC_)
	_oS_.SetData("fr", "tx", _nL_ + _FfTextWidth(poFont, _d_[:label], StzResidualPlotFigureTitleSize()) / 2)
	_oS_.SetData("fr", "ty", 28)
	for _i_ = 1 to _nR_
		_oS_.Declare("Row", "r" + _i_)
		_oS_.Label("r" + _i_, _d_[:rownames][_i_])
		_oS_.SetData("r" + _i_, "e", _aRe_[_i_])
	next
	for _j_ = 1 to _nC_
		_oS_.Declare("Col", "c" + _j_)
		_oS_.Label("c" + _j_, _d_[:colnames][_j_])
		_oS_.SetData("c" + _j_, "e", _aCe_[_j_])
	next
	# the axes: x along the zero line, y up the left edge
	_oS_.Declare("Axis", "ax")
	_oS_.Label("ax", "fitted")
	_oS_.SetData("ax", "x0", _nL_)  _oS_.SetData("ax", "y0", _nZy_)
	_oS_.SetData("ax", "x1", _nL_ + _nPw_ + 12)  _oS_.SetData("ax", "y1", _nZy_)
	_oS_.SetData("ax", "lx", _nL_ + _nPw_ / 2)  _oS_.SetData("ax", "ly", _nT_ + _nPh_ + 44)
	_oS_.Declare("Axis", "ay")
	_oS_.Label("ay", "residual")
	_oS_.SetData("ay", "x0", _nL_)  _oS_.SetData("ay", "y0", _nT_ + _nPh_)
	_oS_.SetData("ay", "x1", _nL_)  _oS_.SetData("ay", "y1", _nT_ - 2)
	_oS_.SetData("ay", "lx", _nL_ + 14 + _FfTextWidth(poFont, "residual", StzResidualPlotFigureTypeSize() + 2) / 2)
	_oS_.SetData("ay", "ly", _nT_ + 14)
	# ticks on x (fitted) and y (residual)
	_nStep_ = _FfNiceStep(_nVmax_ - _nVmin_, 7)
	_nK_ = 0
	for _q_ = ceil(_nVmin_ / _nStep_) to floor(_nVmax_ / _nStep_)
		_v_ = _q_ * _nStep_
		_nK_++
		_oS_.Declare("Tick", "tx" + _nK_)
		_oS_.Label("tx" + _nK_, _FfNum(_v_, 6))
		_oS_.SetData("tx" + _nK_, "v", _v_)
		_oS_.SetData("tx" + _nK_, "x", _nL_ + (_v_ - _nVmin_) * _nKx_)
		_oS_.SetData("tx" + _nK_, "y", _nT_ + _nPh_)
		_oS_.SetData("tx" + _nK_, "dx", 0)  _oS_.SetData("tx" + _nK_, "dy", 4)
		_oS_.SetData("tx" + _nK_, "lx", _nL_ + (_v_ - _nVmin_) * _nKx_)
		_oS_.SetData("tx" + _nK_, "ly", _nT_ + _nPh_ + 18)
	next
	_nStepY_ = _FfNiceStep(2 * _nRr_, 6)
	_nKy2_ = 0
	for _q_ = ceil(-_nRr_ / _nStepY_) to floor(_nRr_ / _nStepY_)
		_v_ = _q_ * _nStepY_
		_nKy2_++
		_oS_.Declare("Tick", "ty" + _nKy2_)
		_oS_.Assert("OnY", [ "ty" + _nKy2_ ])
		_oS_.Label("ty" + _nKy2_, _FfNum(_v_, 6))
		_oS_.SetData("ty" + _nKy2_, "v", _v_)
		_oS_.SetData("ty" + _nKy2_, "x", _nL_)
		_oS_.SetData("ty" + _nKy2_, "y", _nZy_ - _v_ * _nKy_)
		_oS_.SetData("ty" + _nKy2_, "dx", 4)  _oS_.SetData("ty" + _nKy2_, "dy", 0)
		_oS_.SetData("ty" + _nKy2_, "lx", _nL_ - 14 - _FfTextWidth(poFont, _FfNum(_v_, 6), StzResidualPlotFigureTypeSize()) / 2)
		_oS_.SetData("ty" + _nKy2_, "ly", _nZy_ - _v_ * _nKy_)
	next
	# THE FENCES: outside at hinge -+ 1.5 fourth-spreads, far out at -+ 3
	_aK_ = [ -3, -1.5, 1.5, 3 ]
	for _b_ = 1 to 4
		_v_ = _nFhi_ + _aK_[_b_] * _nS_
		if _aK_[_b_] < 0  _v_ = _nFlo_ + _aK_[_b_] * _nS_  ok
		_oS_.Declare("Band", "b" + _b_)
		_oS_.Label("b" + _b_, "")
		_oS_.SetData("b" + _b_, "k", _aK_[_b_])
		_oS_.SetData("b" + _b_, "v", _v_)
		_oS_.SetData("b" + _b_, "y", _nZy_ - _v_ * _nKy_)
		_oS_.SetData("b" + _b_, "x0", _nL_)  _oS_.SetData("b" + _b_, "x1", _nL_ + _nPw_)
	next
	# the points, one per cell. TWO CELLS WITH THE SAME NUMBERS SIT ON THE
	# SAME SPOT, and a dot painted over a dot hides a cell: the second is
	# drawn as a RING around the first (k = 1), the third as a wider ring
	# (k = 2), so every cell stays visible and every cell stays at its
	# numbers. Integer tables coincide often -- R's deaths table three times.
	_nOut_ = 0  _nFar_ = 0  _nP_ = 0  _nStacked_ = 0
	_aSeenF_ = []  _aSeenR_ = []
	for _i_ = 1 to _nR_
		for _j_ = 1 to _nC_
			_nP_++
			_cP_ = "p" + _nP_
			_f_ = _nCommon_ + _aRe_[_i_] + _aCe_[_j_]
			_r_ = _aRes_[_i_][_j_]
			_oS_.Declare("Point", _cP_)
			_oS_.Label(_cP_, "")
			_oS_.SetData(_cP_, "row", _i_)  _oS_.SetData(_cP_, "col", _j_)
			_oS_.SetData(_cP_, "fit", _f_)  _oS_.SetData(_cP_, "res", _r_)
			_oS_.SetData(_cP_, "x", _nL_ + (_f_ - _nVmin_) * _nKx_)
			_oS_.SetData(_cP_, "y", _nZy_ - _r_ * _nKy_)
			_nKk_ = 0
			for _q_ = 1 to len(_aSeenF_)
				if fabs(_aSeenF_[_q_] - _f_) < 0.000000001 and fabs(_aSeenR_[_q_] - _r_) < 0.000000001  _nKk_++  ok
			next
			_aSeenF_ + _f_  _aSeenR_ + _r_
			_oS_.SetData(_cP_, "k", _nKk_)
			if _nKk_ > 0
				_oS_.Assert("Stacked", [ _cP_ ])
				_nStacked_++
			ok
			_nB_ = 0
			if _nS_ > 0
				if _r_ < _nFlo_ - 3 * _nS_ or _r_ > _nFhi_ + 3 * _nS_
					_nB_ = 3
				but _r_ < _nFlo_ - 1.5 * _nS_ or _r_ > _nFhi_ + 1.5 * _nS_
					_nB_ = 2
				ok
			but _r_ != 0
				# a zero spread: the fences sit on the hinge and any residual is past them
				_nB_ = 3
			ok
			if _nB_ >= 3
				_oS_.Assert("FarOut", [ _cP_ ])
				_nFar_++
				_nOut_++
				_oS_.Define("n" + _nP_, "Note", [ _cP_ ])
				_oS_.Label("n" + _nP_, _d_[:rownames][_i_] + ", " + _d_[:colnames][_j_])
				_oS_.SetData("n" + _nP_, "x", _nL_ + (_f_ - _nVmin_) * _nKx_ + 10 +
					_FfTextWidth(poFont, _d_[:rownames][_i_] + ", " + _d_[:colnames][_j_], StzResidualPlotFigureTypeSize()) / 2)
				_oS_.SetData("n" + _nP_, "y", _nZy_ - _r_ * _nKy_ - 12)
			but _nB_ >= 2
				_oS_.Assert("Outside", [ _cP_ ])
				_nOut_++
			ok
		next
	next
	_oS_.SetData("fr", "points", _nP_)
	_oS_.SetData("fr", "outside", _nOut_)  _oS_.SetData("fr", "farout", _nFar_)
	_oS_.SetData("fr", "stacked", _nStacked_)
	return _oS_

func StzResidualPlotFigureWhy(poSubstance)
	return "a residual-versus-fit of " + poSubstance.DataOf("fr", "rows") + " x " + poSubstance.DataOf("fr", "cols") +
		" cells: common " + _FfNum(poSubstance.DataOf("fr", "common"), 4) + ", residual fourth-spread " +
		_FfNum(poSubstance.DataOf("fr", "scale"), 4) + ", " + poSubstance.DataOf("fr", "outside") +
		" beyond the outside fences, " + poSubstance.DataOf("fr", "farout") + " far out, " +
		poSubstance.DataOf("fr", "stacked") + " ringed on another cell's spot"

#-- the declaration, read and refused by name -------------------------

func _RpDeclaration(paSpec)
	if NOT isList(paSpec) or len(paSpec) = 0
		stzraise("StzResidualPlotFigure: a residual plot is declared as keys, like [ :of = [ [ 1, 2 ], [ 3, 4 ] ] ].")
	ok
	_acKeys_ = StzResidualPlotFigureKeys()
	for _i_ = 1 to len(paSpec)
		_e_ = paSpec[_i_]
		if NOT isList(_e_) or len(_e_) != 2 or NOT isString(_e_[1])
			stzraise("StzResidualPlotFigure: entry " + _i_ + " of the declaration is not a key and a value.")
		ok
		if NOT _FfIn(_acKeys_, StzLower(_e_[1]))
			stzraise("StzResidualPlotFigure: ':" + _e_[1] + "' is not a key of a residual plot -- the keys are " + @@(_acKeys_) + ".")
		ok
	next
	_d_ = [ :rows = [], :rownames = [], :colnames = [], :label = "" ]
	_aR_ = _FfGet(paSpec, "of", [])
	_RpCheckTable(_aR_, "StzResidualPlotFigure")
	_d_[:rows] = _aR_
	_nR_ = len(_aR_)
	_nC_ = len(_aR_[1])
	_aN_ = _FfGet(paSpec, "names", [])
	if NOT isList(_aN_)
		stzraise("StzResidualPlotFigure: :names is [ row names, column names ].")
	ok
	if len(_aN_) = 0
		for _i_ = 1 to _nR_  _d_[:rownames] + ("r" + _i_)  next
		for _j_ = 1 to _nC_  _d_[:colnames] + ("c" + _j_)  next
	else
		if len(_aN_) != 2 or NOT isList(_aN_[1]) or NOT isList(_aN_[2]) or len(_aN_[1]) != _nR_ or len(_aN_[2]) != _nC_
			stzraise("StzResidualPlotFigure: :names is [ row names, column names ] with " + _nR_ + " and " + _nC_ + " names.")
		ok
		for _i_ = 1 to _nR_  _d_[:rownames] + ("" + _aN_[1][_i_])  next
		for _j_ = 1 to _nC_  _d_[:colnames] + ("" + _aN_[2][_j_])  next
	ok
	_cL_ = _FfGet(paSpec, "label", "")
	if NOT isString(_cL_)
		stzraise("StzResidualPlotFigure: :label is text.")
	ok
	_d_[:label] = _cL_
	return _d_

# a rectangular table of numbers, at least 2 x 2, at most MaxCells
func _RpCheckTable(paR, pcWho)
	if NOT isList(paR) or len(paR) < 2 or NOT isList(paR[1]) or len(paR[1]) < 2
		stzraise(pcWho + ": :of is a table of at least two rows and two columns.")
	ok
	_nC_ = len(paR[1])
	for _i_ = 1 to len(paR)
		if NOT isList(paR[_i_]) or len(paR[_i_]) != _nC_
			stzraise(pcWho + ": row " + _i_ + " does not have " + _nC_ + " value(s) -- the table is rectangular.")
		ok
		for _j_ = 1 to _nC_
			if NOT isNumber(paR[_i_][_j_])
				stzraise(pcWho + ": cell (" + _i_ + ", " + _j_ + ") is not a number.")
			ok
		next
	next
	if len(paR) * _nC_ > StzResidualPlotFigureMaxCells()
		stzraise(pcWho + ": " + (len(paR) * _nC_) + " cells -- at most " + StzResidualPlotFigureMaxCells() + " on one picture.")
	ok

#-- the style ----------------------------------------------------------

func StzResidualPlotStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(StzResidualPlotFigureWidth(), StzResidualPlotFigureHeight())
	_o_.SetMargin(6)
	_nT_ = StzResidualPlotFigureTypeSize()
	_o_.ForAll("Frame f", [
		[ :shape, "f.box", :rect, [ :cx = "(f.x0 + f.x1) / 2", :cy = "(f.y0 + f.y1) / 2",
		                            :w = "f.x1 - f.x0", :h = "f.y1 - f.y0",
		                            :fill = [ :alpha, "primary", 0.04 ], :stroke = "muted", :strokeWidth = 1 ] ],
		[ :shape, "f.text", :text, [ :cx = "f.tx", :cy = "f.ty", :size = StzResidualPlotFigureTitleSize(),
		                             :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAll("Axis a", [
		[ :shape, "a.icon", :line, [ :x1 = "a.x0", :y1 = "a.y0", :x2 = "a.x1", :y2 = "a.y1",
		                             :stroke = "neutral", :strokeWidth = 1.5, :arrow = "end" ] ],
		[ :shape, "a.text", :text, [ :cx = "a.lx", :cy = "a.ly", :size = _nT_ + 2, :fill = "neutral" ] ] ])
	_o_.ForAll("Tick k", [
		[ :shape, "k.icon", :line, [ :x1 = "k.x - k.dx", :y1 = "k.y - k.dy", :x2 = "k.x + k.dx", :y2 = "k.y + k.dy",
		                             :stroke = "neutral", :strokeWidth = 1 ] ],
		[ :shape, "k.text", :text, [ :cx = "k.lx", :cy = "k.ly", :size = _nT_, :fill = "muted" ] ] ])
	_o_.ForAll("Band b", [
		[ :shape, "b.icon", :line, [ :x1 = "b.x0", :y1 = "b.y", :x2 = "b.x1", :y2 = "b.y",
		                             :stroke = [ :alpha, "primary", 0.35 ], :strokeWidth = 1 ] ] ])
	_o_.ForAll("Point p", [
		[ :shape, "p.icon", :circle, [ :cx = "p.x", :cy = "p.y", :r = 5.5,
		                               :fill = "primary", :stroke = "background", :strokeWidth = 1.5 ] ] ])
	_o_.ForAllWhere("Point p", "Outside(p)", [
		[ :delete, "p.icon" ],
		[ :shape, "p.icon", :circle, [ :cx = "p.x", :cy = "p.y", :r = 6,
		                               :fill = "warning", :stroke = "background", :strokeWidth = 1.5 ] ] ])
	_o_.ForAllWhere("Point p", "FarOut(p)", [
		[ :delete, "p.icon" ],
		[ :shape, "p.icon", :circle, [ :cx = "p.x", :cy = "p.y", :r = 6.5,
		                               :fill = "danger", :stroke = "background", :strokeWidth = 1.5 ] ] ])
	_o_.ForAllWhere("Point p", "Stacked(p)", [
		[ :delete, "p.icon" ],
		[ :shape, "p.icon", :circle, [ :cx = "p.x", :cy = "p.y", :r = "6.5 + 4 * p.k",
		                               :stroke = "primary", :strokeWidth = 1.5 ] ] ])
	_o_.ForAllWhere("Note n; Point p", "n := Note(p)", [
		[ :shape, "n.text", :text, [ :cx = "n.x", :cy = "n.y", :size = _nT_, :fill = [ :on, "paper" ] ] ],
		[ :layer, "n.text", :above, "p.icon" ] ])
	return _o_

#-- the rules --------------------------------------------------------------

func StzResidualPlotRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("point_is_its_cell")
	_o1_.SetClaim("a point's fit is the common value plus its row's and its column's effects, it is drawn there, and a cell on another's spot is ringed, never hidden")
	_o1_.SetOrder(93)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _RpScope(oDg, "Point", "point:") })
	_o1_.SetCounter(func(oDg) { return _RpCounter(oDg, "Point") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cP_ = StzStringSection(cSub, 7, len(cSub))
		_oS_ = oDg.Substance()
		_i_ = _oS_.DataOf(_cP_, "row")
		_j_ = _oS_.DataOf(_cP_, "col")
		_nFit_ = _oS_.DataOf("fr", "common") + _oS_.DataOf("r" + _i_, "e") + _oS_.DataOf("c" + _j_, "e")
		if fabs(_nFit_ - _oS_.DataOf(_cP_, "fit")) > 0.000000001
			return [ FALSE, "cell (" + _i_ + ", " + _j_ + ") carries fit " + _FfNum(_oS_.DataOf(_cP_, "fit"), 4) +
				" where common + row + column is " + _FfNum(_nFit_, 4) ]
		ok
		_nX_ = _oS_.DataOf("fr", "x0") + (_nFit_ - _oS_.DataOf("fr", "vmin")) * _oS_.DataOf("fr", "kx")
		_nY_ = _oS_.DataOf("fr", "zy") - _oS_.DataOf(_cP_, "res") * _oS_.DataOf("fr", "ky")
		if fabs(_nX_ - _oS_.DataOf(_cP_, "x")) > 0.000001 or fabs(_nY_ - _oS_.DataOf(_cP_, "y")) > 0.000001
			return [ FALSE, "cell (" + _i_ + ", " + _j_ + ") is drawn " + _FfNum(fabs(_nX_ - _oS_.DataOf(_cP_, "x")) + fabs(_nY_ - _oS_.DataOf(_cP_, "y")), 2) + " px from its numbers" ]
		ok
		# its ring index is the number of EARLIER cells on the same spot
		_ac_ = _oS_.ObjectsOfType("Point")
		_nEarlier_ = 0
		for _q_ = 1 to len(_ac_)
			if _ac_[_q_] = _cP_  exit  ok
			if fabs(_oS_.DataOf(_ac_[_q_], "fit") - _oS_.DataOf(_cP_, "fit")) < 0.000000001 and
			   fabs(_oS_.DataOf(_ac_[_q_], "res") - _oS_.DataOf(_cP_, "res")) < 0.000000001
				_nEarlier_++
			ok
		next
		if _nEarlier_ != _oS_.DataOf(_cP_, "k")
			return [ FALSE, "cell (" + _i_ + ", " + _j_ + ") shares its spot with " + _nEarlier_ +
				" earlier cell(s) and is drawn as ring " + _oS_.DataOf(_cP_, "k") ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("bands_are_the_scale")
	_o2_.SetClaim("each fence sits at its multiple of the residuals' fourth-spread beyond the hinge, hinges and spread recomputed from the points")
	_o2_.SetOrder(94)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) { return _RpScope(oDg, "Band", "band:") })
	_o2_.SetCounter(func(oDg) { return _RpCounter(oDg, "Band") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cB_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_ac_ = _oS_.ObjectsOfType("Point")
		_aR_ = []
		for _i_ = 1 to len(_ac_)  _aR_ + _oS_.DataOf(_ac_[_i_], "res")  next
		_aF_ = StzEngineTukeyFourths(_aR_)
		_nS_ = _aF_[2] - _aF_[1]
		if fabs(_nS_ - _oS_.DataOf("fr", "scale")) > 0.000000001
			return [ FALSE, "the picture says the scale is " + _FfNum(_oS_.DataOf("fr", "scale"), 4) +
				" and the points' fourth-spread is " + _FfNum(_nS_, 4) ]
		ok
		if fabs(_aF_[1] - _oS_.DataOf("fr", "flo")) > 0.000000001 or fabs(_aF_[2] - _oS_.DataOf("fr", "fhi")) > 0.000000001
			return [ FALSE, "the picture says the hinges are " + _FfNum(_oS_.DataOf("fr", "flo"), 4) + " and " +
				_FfNum(_oS_.DataOf("fr", "fhi"), 4) + " and the points' are " + _FfNum(_aF_[1], 4) + " and " + _FfNum(_aF_[2], 4) ]
		ok
		_nK_ = _oS_.DataOf(_cB_, "k")
		_nV_ = _aF_[2] + _nK_ * _nS_
		if _nK_ < 0  _nV_ = _aF_[1] + _nK_ * _nS_  ok
		_nY_ = _oS_.DataOf("fr", "zy") - _nV_ * _oS_.DataOf("fr", "ky")
		if fabs(_nY_ - _oS_.DataOf(_cB_, "y")) > 0.000001
			return [ FALSE, "the fence at " + _nK_ + " fourth-spread(s) from the hinge is drawn " +
				_FfNum(fabs(_nY_ - _oS_.DataOf(_cB_, "y")), 2) + " px from its place" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o2_
	return _ao_

func _RpIsResidual(poDg)
	return isObject(poDg) and StzLower("" + poDg.Substance().DomainQ().Name_()) = "residualplot"

func _RpScope(poDg, pcType, pcPrefix)
	if NOT _RpIsResidual(poDg)  return []  ok
	_ac_ = poDg.Substance().ObjectsOfType(pcType)
	_a_ = []
	for _i_ = 1 to len(_ac_)  _a_ + (pcPrefix + _ac_[_i_])  next
	return _a_

func _RpCounter(poDg, pcType)
	if NOT _RpIsResidual(poDg)  return 0  ok
	return len(poDg.Substance().ObjectsOfType(pcType))
