#=====================================================================#
#  STZSTEMPLOTFIGURE -- the stem-and-leaf display as a figure of M1    #
#  (SOFTANZA_TUKEY_PLAN.md 2.8, TK3; plane stzlib-math, M4c)           #
#=====================================================================#
/*
	Tukey's stem-and-leaf keeps every digit of the data on the page: a
	value is split at a chosen unit into a STEM (the leading digits, one
	row) and a LEAF (the next digit, one character on the row), and the
	rows, read together, are a histogram that lost nothing.

	    oF = StzMathFigureQ(:StemPlot, [ :of = [ 2, 4, 4, 5, 7, 9, 12, 25 ] ])
	    ? oF.Text()
	    #-->  0 | 2 4 4 5 7 9
	    #-->  1 | 2
	    #-->  2 | 5
	    #-->  leaf unit 1 -- 1 | 2 means 12

	Keys: :of (the values, at or above zero), :unit (the leaf unit, a power
	of ten; chosen from the range when absent), :lines (1, or 2 to split
	each stem into leaves 0-4 and 5-9, Tukey's * and . rows), :label.
	Nothing is solved: every row sits where its stem puts it. The rules are
	the display's own honesty -- the leaves count the values, the leaves of
	a row are sorted, the stems are consecutive with the empty ones shown.

	Negative values are refused by name in this slice: Tukey's -0 stem is a
	convention this figure does not yet print, and a quiet floor on a
	negative value would put 3 on the row of -1.
*/

StzRegisterMathRuleSet("stemplot", StzStemPlotRuleSet())

func StzStemPlotDomain()
	_o_ = new stzMathDomain("stemplot")
	_o_.AddType("Figure")
	_o_.AddType("Stem")
	_o_.AddType("Leaves")
	_o_.AddType("Legend")
	_o_.AddPredicate("Empty", [ "Stem" ])
	return _o_

func StzStemPlotFigureWidth()
	return 620
func StzStemPlotFigureLeft()
	return 120
func StzStemPlotFigureRowPitch()
	return 30
func StzStemPlotFigureTypeSize()
	return 18
func StzStemPlotFigureTitleSize()
	return 20
func StzStemPlotFigureMaxRows()
	return 40

func StzStemPlotFigureKeys()
	return [ "of", "unit", "lines", "label" ]

func StzStemPlotFigureFrom(paSpec)
	return StzStemPlotFigureFromXT(StzMathFigureFont(), paSpec)

func StzStemPlotFigureBuildXT(poFont, paSpec)
	_oS_ = StzStemPlotFigureFromXT(poFont, paSpec)
	_nH_ = _oS_.DataOf("fr", "h")
	_o_ = new stzMathDiagram(StzStemPlotDomain(), _oS_, StzStemPlotStyleXT(StzStemPlotFigureWidth(), _nH_))
	_o_.SetFont(poFont, StzStemPlotFigureTypeSize())
	return _o_

func StzStemPlotFigureFromXT(poFont, paSpec)
	_d_ = _SpDeclaration(paSpec)
	_aV_ = _d_[:values]
	_n_ = len(_aV_)
	_nU_ = _d_[:unit]
	if _nU_ = 0  _nU_ = _SpUnit(_aV_)  ok
	# stems and leaves: stem = floor(v / (10 unit)), leaf = floor(v / unit) mod 10
	_aStem_ = []
	_aLeaf_ = []
	for _i_ = 1 to _n_
		_nQ_ = floor(_aV_[_i_] / _nU_ + 0.000000001)
		_aStem_ + floor(_nQ_ / 10)
		_aLeaf_ + (_nQ_ - 10 * floor(_nQ_ / 10))
	next
	_nS0_ = _aStem_[1]  _nS1_ = _aStem_[1]
	for _i_ = 2 to _n_
		if _aStem_[_i_] < _nS0_  _nS0_ = _aStem_[_i_]  ok
		if _aStem_[_i_] > _nS1_  _nS1_ = _aStem_[_i_]  ok
	next
	_nRows_ = (_nS1_ - _nS0_ + 1) * _d_[:lines]
	if _nRows_ > StzStemPlotFigureMaxRows()
		stzraise("StzStemPlotFigure: " + _nRows_ + " rows at leaf unit " + _FfNum(_nU_, 6) +
			" -- more than " + StzStemPlotFigureMaxRows() + " cannot be read; give a larger :unit.")
	ok
	_nTop_ = 40
	if _d_[:label] != ""  _nTop_ = 66  ok
	_nH_ = _nTop_ + _nRows_ * StzStemPlotFigureRowPitch() + 60
	_oS_ = new stzMathSubstance(StzStemPlotDomain())
	_oS_.Declare("Figure", "fr")
	_oS_.Label("fr", _d_[:label])
	_oS_.SetData("fr", "n", _n_)
	_oS_.SetData("fr", "unit", _nU_)
	_oS_.SetData("fr", "lines", _d_[:lines])
	_oS_.SetData("fr", "rows", _nRows_)
	_oS_.SetData("fr", "h", _nH_)
	_oS_.SetData("fr", "tx", 30 + _FfTextWidth(poFont, _d_[:label], StzStemPlotFigureTitleSize()) / 2)
	_oS_.SetData("fr", "ty", 34)
	_nEmpty_ = 0
	_nR_ = 0
	_nX0_ = StzStemPlotFigureLeft()
	for _s_ = _nS0_ to _nS1_
		for _l_ = 1 to _d_[:lines]
			_nR_++
			_cS_ = "s" + _nR_
			# the leaves of this row, sorted
			_aL_ = []
			for _i_ = 1 to _n_
				if _aStem_[_i_] != _s_  loop  ok
				if _d_[:lines] = 2
					if _l_ = 1 and _aLeaf_[_i_] >= 5  loop  ok
					if _l_ = 2 and _aLeaf_[_i_] < 5  loop  ok
				ok
				_aL_ + _aLeaf_[_i_]
			next
			_aL_ = _SpSorted(_aL_)
			_cLeaves_ = ""
			for _i_ = 1 to len(_aL_)
				if _i_ > 1  _cLeaves_ += " "  ok
				_cLeaves_ += ("" + _aL_[_i_])
			next
			_cStem_ = "" + _s_
			if _d_[:lines] = 2
				if _l_ = 1  _cStem_ += "*"  else  _cStem_ += "."  ok
			ok
			_oS_.Declare("Stem", _cS_)
			_oS_.Label(_cS_, _cStem_ + " |")
			_oS_.SetData(_cS_, "v", _s_)
			_oS_.SetData(_cS_, "line", _l_)
			_oS_.SetData(_cS_, "k", len(_aL_))
			_oS_.SetData(_cS_, "y", _nTop_ + (_nR_ - 0.5) * StzStemPlotFigureRowPitch())
			_oS_.SetData(_cS_, "x", _nX0_ - 14 - _FfTextWidth(poFont, _cStem_ + " |", StzStemPlotFigureTypeSize()) / 2)
			# the leaves are a labelled object of their own: a label is text, a datum is a number
			_oS_.Declare("Leaves", "l" + _nR_)
			_oS_.Label("l" + _nR_, _cLeaves_)
			_oS_.SetData("l" + _nR_, "x", _nX0_ + 6 + _FfTextWidth(poFont, _cLeaves_, StzStemPlotFigureTypeSize()) / 2)
			_oS_.SetData("l" + _nR_, "y", _nTop_ + (_nR_ - 0.5) * StzStemPlotFigureRowPitch())
			if len(_aL_) = 0
				_oS_.Assert("Empty", [ _cS_ ])
				_nEmpty_++
			ok
		next
	next
	_oS_.SetData("fr", "empty", _nEmpty_)
	# the legend: what a row means, in the data's own units
	_cLg_ = "leaf unit " + _FfNum(_nU_, 6) + " -- " + _SpExample(_nS0_, _nU_)
	_oS_.Declare("Legend", "lg")
	_oS_.Label("lg", _cLg_)
	_oS_.SetData("lg", "x", 30 + _FfTextWidth(poFont, _cLg_, StzStemPlotFigureTypeSize() - 2) / 2)
	_oS_.SetData("lg", "y", _nH_ - 26)
	return _oS_

func StzStemPlotFigureWhy(poSubstance)
	_c_ = "a stem-and-leaf of " + poSubstance.DataOf("fr", "n") + " value(s), leaf unit " +
		_FfNum(poSubstance.DataOf("fr", "unit"), 6) + ", " + poSubstance.DataOf("fr", "rows") + " row(s)"
	if poSubstance.DataOf("fr", "lines") = 2  _c_ += " (two per stem)"  ok
	if poSubstance.DataOf("fr", "empty") > 0  _c_ += ", " + poSubstance.DataOf("fr", "empty") + " empty"  ok
	return _c_

# the text rendition: the rows, then the legend
func StzStemPlotFigureText(poSubstance)
	_nRows_ = poSubstance.DataOf("fr", "rows")
	_nW_ = 0
	for _r_ = 1 to _nRows_
		_cL_ = poSubstance.LabelOf("s" + _r_)
		if len(_cL_) > _nW_  _nW_ = len(_cL_)  ok
	next
	_c_ = ""
	for _r_ = 1 to _nRows_
		_cL_ = poSubstance.LabelOf("s" + _r_)
		_c_ += "  " + _SpSpaces(_nW_ - len(_cL_)) + _cL_ + " " + poSubstance.LabelOf("l" + _r_) + char(10)
	next
	_c_ += "  " + poSubstance.LabelOf("lg") + char(10)
	return _c_

#-- the declaration, read and refused by name -------------------------

func _SpDeclaration(paSpec)
	if NOT isList(paSpec) or len(paSpec) = 0
		stzraise("StzStemPlotFigure: a stem-and-leaf is declared as keys, like [ :of = [ 12, 15, 21 ] ].")
	ok
	_acKeys_ = StzStemPlotFigureKeys()
	for _i_ = 1 to len(paSpec)
		_e_ = paSpec[_i_]
		if NOT isList(_e_) or len(_e_) != 2 or NOT isString(_e_[1])
			stzraise("StzStemPlotFigure: entry " + _i_ + " of the declaration is not a key and a value.")
		ok
		if NOT _FfIn(_acKeys_, StzLower(_e_[1]))
			stzraise("StzStemPlotFigure: ':" + _e_[1] + "' is not a key of a stem-and-leaf -- the keys are " + @@(_acKeys_) + ".")
		ok
	next
	_d_ = [ :values = [], :unit = 0, :lines = 1, :label = "" ]
	_aV_ = _FfGet(paSpec, "of", [])
	if NOT isList(_aV_) or len(_aV_) = 0
		stzraise("StzStemPlotFigure: :of is the list of values.")
	ok
	for _i_ = 1 to len(_aV_)
		if NOT isNumber(_aV_[_i_])
			stzraise("StzStemPlotFigure: value " + _i_ + " is not a number.")
		ok
		if _aV_[_i_] < 0
			stzraise("StzStemPlotFigure: value " + _i_ + " is negative -- this slice draws values at or above zero " +
				"(Tukey's -0 stem is not printed yet).")
		ok
	next
	_d_[:values] = _aV_
	_nU_ = _FfGet(paSpec, "unit", 0)
	if NOT isNumber(_nU_) or _nU_ < 0
		stzraise("StzStemPlotFigure: :unit is a positive power of ten, the value of one leaf digit.")
	ok
	if _nU_ > 0
		_nL_ = log(_nU_) / log(10)
		if fabs(_nL_ - floor(_nL_ + 0.5)) > 0.000001
			stzraise("StzStemPlotFigure: :unit must be a power of ten -- 0.1, 1, 10, 100 -- not " + _FfNum(_nU_, 6) + ".")
		ok
		_nU_ = pow(10, floor(_nL_ + 0.5))
	ok
	_d_[:unit] = _nU_
	_nLn_ = _FfGet(paSpec, "lines", 1)
	if NOT isNumber(_nLn_) or (_nLn_ != 1 and _nLn_ != 2)
		stzraise("StzStemPlotFigure: :lines is 1, or 2 to split each stem into leaves 0-4 and 5-9.")
	ok
	_d_[:lines] = _nLn_
	_cL_ = _FfGet(paSpec, "label", "")
	if NOT isString(_cL_)
		stzraise("StzStemPlotFigure: :label is text.")
	ok
	_d_[:label] = _cL_
	return _d_

# the leaf unit from the range: the power of ten that gives 5 to 20 stems
func _SpUnit(paV)
	_nMin_ = paV[1]  _nMax_ = paV[1]
	for _i_ = 2 to len(paV)
		if paV[_i_] < _nMin_  _nMin_ = paV[_i_]  ok
		if paV[_i_] > _nMax_  _nMax_ = paV[_i_]  ok
	next
	_nR_ = _nMax_ - _nMin_
	if _nR_ <= 0  _nR_ = 1  ok
	_nU_ = pow(10, floor(log(_nR_ / 10) / log(10)))
	if _nR_ / (10 * _nU_) < 2  _nU_ = _nU_ / 10  ok
	return _nU_

func _SpSorted(paL)
	_a_ = []
	for _i_ = 1 to len(paL)  _a_ + paL[_i_]  next
	_n_ = len(_a_)
	for _i_ = 1 to _n_ - 1
		for _j_ = _i_ + 1 to _n_
			if _a_[_j_] < _a_[_i_]
				_t_ = _a_[_i_]  _a_[_i_] = _a_[_j_]  _a_[_j_] = _t_
			ok
		next
	next
	return _a_

func _SpExample(pnStem, pnU)
	_nS_ = pnStem
	if _nS_ = 0  _nS_ = 1  ok
	return "" + _nS_ + " | 2 means " + _FfNum((_nS_ * 10 + 2) * pnU, 6)

func _SpSpaces(pn)
	_c_ = ""
	for _i_ = 1 to pn  _c_ += " "  next
	return _c_

#-- the style: nothing to solve, text where its row is -------------------

func StzStemPlotStyle()
	return StzStemPlotStyleXT(StzStemPlotFigureWidth(), 400)

func StzStemPlotStyleXT(pnW, pnH)
	_o_ = new stzMathStyle()
	_o_.SetCanvas(pnW, pnH)
	_o_.SetMargin(6)
	_nT_ = StzStemPlotFigureTypeSize()
	_o_.ForAll("Figure f", [
		[ :shape, "f.text", :text, [ :cx = "f.tx", :cy = "f.ty", :size = StzStemPlotFigureTitleSize(),
		                             :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAll("Stem s", [
		[ :shape, "s.text", :text, [ :cx = "s.x", :cy = "s.y", :size = _nT_, :fill = "muted" ] ] ])
	_o_.ForAll("Leaves l", [
		[ :shape, "l.text", :text, [ :cx = "l.x", :cy = "l.y", :size = _nT_, :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAll("Legend g", [
		[ :shape, "g.text", :text, [ :cx = "g.x", :cy = "g.y", :size = _nT_ - 2, :fill = "muted" ] ] ])
	return _o_

#-- the rules: the display's own honesty ---------------------------------

func StzStemPlotRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("leaves_count_the_values")
	_o1_.SetClaim("the leaves over all rows are as many as the values")
	_o1_.SetOrder(90)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _SpScopeFigure(oDg) })
	_o1_.SetCounter(func(oDg) { return _SpCounterFigure(oDg) })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_oS_ = oDg.Substance()
		_n_ = _oS_.DataOf("fr", "n")
		_nRows_ = _oS_.DataOf("fr", "rows")
		_nK_ = 0
		for _r_ = 1 to _nRows_
			_nK_ += _oS_.DataOf("s" + _r_, "k")
		next
		if _nK_ != _n_
			return [ FALSE, "the rows carry " + _nK_ + " leaf(ves) for " + _n_ + " value(s)" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("leaves_are_sorted")
	_o2_.SetClaim("the leaves of a row rise from left to right, and their count is the row's count")
	_o2_.SetOrder(91)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) { return _SpScope(oDg, "Stem", "stem:") })
	_o2_.SetCounter(func(oDg) { return _SpCounter(oDg, "stem:") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cS_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_cL_ = "" + _oS_.LabelOf("l" + StzStringSection(_cS_, 2, len(_cS_)))
		_aD_ = StzSplit(_cL_, " ")
		_nK_ = 0
		_nPrev_ = -1
		for _i_ = 1 to len(_aD_)
			if ring_trim(_aD_[_i_]) = ""  loop  ok
			_nK_++
			_nD_ = 0 + _aD_[_i_]
			if _nD_ < _nPrev_
				return [ FALSE, "row '" + _oS_.LabelOf(_cS_) + "' has leaf " + _nD_ + " after " + _nPrev_ ]
			ok
			_nPrev_ = _nD_
		next
		if _nK_ != _oS_.DataOf(_cS_, "k")
			return [ FALSE, "row '" + _oS_.LabelOf(_cS_) + "' prints " + _nK_ + " leaf(ves) and counts " + _oS_.DataOf(_cS_, "k") ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	_o3_ = StzPlasticRule("stems_are_consecutive")
	_o3_.SetClaim("each row's stem follows the one above it, with the empty stems shown")
	_o3_.SetOrder(92)
	_o3_.SetReads([ "substance" ])
	_o3_.SetScope(func(oDg) { return _SpScope(oDg, "Stem", "stem:") })
	_o3_.SetCounter(func(oDg) { return _SpCounter(oDg, "stem:") })
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cS_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_nR_ = 0 + StzStringSection(_cS_, 2, len(_cS_))
		if _nR_ = 1  return [ TRUE, "" ]  ok
		_nLines_ = _oS_.DataOf("fr", "lines")
		_nV_ = _oS_.DataOf(_cS_, "v")
		_nVp_ = _oS_.DataOf("s" + (_nR_ - 1), "v")
		_nL_ = _oS_.DataOf(_cS_, "line")
		_nWant_ = _nVp_
		if _nLines_ = 1 or _nL_ = 1  _nWant_ = _nVp_ + 1  ok
		if _nV_ != _nWant_
			return [ FALSE, "row " + _nR_ + " has stem " + _nV_ + " after stem " + _nVp_ ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o3_
	return _ao_

func _SpIsStem(poDg)
	return isObject(poDg) and StzLower("" + poDg.Substance().DomainQ().Name_()) = "stemplot"

func _SpScopeFigure(poDg)
	if NOT _SpIsStem(poDg)  return []  ok
	return [ "figure:fr" ]

func _SpCounterFigure(poDg)
	if NOT _SpIsStem(poDg)  return 0  ok
	return 1

func _SpScope(poDg, pcType, pcPrefix)
	if NOT _SpIsStem(poDg)  return []  ok
	_ac_ = poDg.Substance().ObjectsOfType(pcType)
	_a_ = []
	for _i_ = 1 to len(_ac_)  _a_ + (pcPrefix + _ac_[_i_])  next
	return _a_

func _SpCounter(poDg, pcPrefix)
	return len(_SpScope(poDg, "Stem", pcPrefix))
