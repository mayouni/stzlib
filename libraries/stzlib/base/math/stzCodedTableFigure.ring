#=====================================================================#
#  STZCODEDTABLEFIGURE -- the coded two-way table, as a figure of M1   #
#  (SOFTANZA_TUKEY_PLAN.md 2.5 and 2.8, TK3; plane stzlib-math, M4c)   #
#=====================================================================#
/*
	A two-way table's residuals, each shown as a GLYPH for the band of
	residual over scale it falls in, so the eye reads the whole table at
	once: where the fit holds, where it misses mildly, where a cell stands
	out. The scale is the residuals' fourth-spread; the bands are fixed
	(plan 2.5) and the legend prints them with the scale, or the table is
	a lie:

	    |r| / s  < 0.5    at the fit       .
	             < 1      mild, signed     - / +
	             < 2      notable, signed  < / >
	             < 3      outside, signed  v / ^
	             >= 3     far out          *

	    oF = StzMathFigureQ(:CodedTable, [ :of = aRows, :names = [ aRowNames, aColNames ] ])
	    ? oF.Text()

	Keys: :of, :names, :glyphs (:ascii, the default, or :symbols for the
	dot, circles, triangles and diamond of the plan -- the font must have
	them), :label. Glyph SETS are swappable; the meaning of a band is not.
	Rules: a cell's glyph is its band, recomputed from its residual and
	the scale; the legend is printed with the scale; the cells tile the
	table.
*/

StzRegisterMathRuleSet("codedtable", StzCodedTableRuleSet())

func StzCodedTableDomain()
	_o_ = new stzMathDomain("codedtable")
	_o_.AddType("Figure")
	_o_.AddType("Row")
	_o_.AddType("Col")
	_o_.AddType("Cell")
	_o_.AddType("Legend")
	return _o_

func StzCodedTableFigureCell()
	return 44
func StzCodedTableFigureTypeSize()
	return 17
func StzCodedTableFigureTitleSize()
	return 20
func StzCodedTableFigureMaxSide()
	return 20

func StzCodedTableFigureKeys()
	return [ "of", "names", "glyphs", "label" ]

# the glyph of a band (0..4) and a sign (-1, 0, 1) in a set
func StzCodedGlyph(pcSet, pnBand, pnSign)
	if pcSet = "symbols"
		if pnBand = 0  return "·"  ok
		if pnBand = 1  if pnSign < 0  return "○"  else  return "●"  ok  ok
		if pnBand = 2  if pnSign < 0  return "◔"  else  return "◕"  ok  ok
		if pnBand = 3  if pnSign < 0  return "▽"  else  return "▲"  ok  ok
		return "◆"
	ok
	if pnBand = 0  return "."  ok
	if pnBand = 1  if pnSign < 0  return "-"  else  return "+"  ok  ok
	if pnBand = 2  if pnSign < 0  return "<"  else  return ">"  ok  ok
	if pnBand = 3  if pnSign < 0  return "v"  else  return "^"  ok  ok
	return "*"

# the band of a residual over the scale: 0 at the fit .. 4 far out
func StzCodedBand(pnRes, pnScale)
	if pnScale <= 0  return 0  ok
	_b_ = fabs(pnRes) / pnScale
	if _b_ < 0.5  return 0  ok
	if _b_ < 1  return 1  ok
	if _b_ < 2  return 2  ok
	if _b_ < 3  return 3  ok
	return 4

func StzCodedBandName(pnBand)
	if pnBand = 0  return "at the fit"  ok
	if pnBand = 1  return "mild"  ok
	if pnBand = 2  return "notable"  ok
	if pnBand = 3  return "outside"  ok
	return "far out"

func StzCodedTableFigureFrom(paSpec)
	return StzCodedTableFigureFromXT(StzMathFigureFont(), paSpec)

func StzCodedTableFigureBuildXT(poFont, paSpec)
	_oS_ = StzCodedTableFigureFromXT(poFont, paSpec)
	_o_ = new stzMathDiagram(StzCodedTableDomain(), _oS_,
		StzCodedTableStyleXT(_oS_.DataOf("fr", "w"), _oS_.DataOf("fr", "h")))
	_o_.SetFont(poFont, StzCodedTableFigureTypeSize())
	return _o_

func StzCodedTableFigureFromXT(poFont, paSpec)
	_d_ = _CtDeclaration(paSpec)
	_aRows_ = _d_[:rows]
	_nR_ = len(_aRows_)
	_nC_ = len(_aRows_[1])
	_aP_ = StzEngineTukeyPolish(_aRows_, 0.01, 10)
	if NOT isList(_aP_) or len(_aP_) < 6
		stzraise("StzCodedTableFigure: the engine refused the table.")
	ok
	_nCommon_ = _aP_[1]
	_aRes_ = _aP_[4]
	_aFlat_ = []
	for _i_ = 1 to _nR_
		for _j_ = 1 to _nC_
			_aFlat_ + _aRes_[_i_][_j_]
		next
	next
	_aF_ = StzEngineTukeyFourths(_aFlat_)
	_nS_ = _aF_[2] - _aF_[1]
	# geometry: row names on the left, column names on top, the legend below
	_nCell_ = StzCodedTableFigureCell()
	_nT_ = StzCodedTableFigureTypeSize()
	_nNameW_ = 0
	for _i_ = 1 to _nR_
		_w_ = _FfTextWidth(poFont, _d_[:rownames][_i_], _nT_)
		if _w_ > _nNameW_  _nNameW_ = _w_  ok
	next
	_nL_ = 30 + _nNameW_ + 16
	_nTop_ = 30
	if _d_[:label] != ""  _nTop_ = 60  ok
	_nTop_ += 34
	_nW_ = _nL_ + _nC_ * _nCell_ + 40
	if _nW_ < 520  _nW_ = 520  ok
	_nTw_ = 60 + _FfTextWidth(poFont, _d_[:label], StzCodedTableFigureTitleSize())
	if _nW_ < _nTw_  _nW_ = _nTw_  ok
	_nLw_ = 60 + _FfTextWidth(poFont, "scale 0000.0000 = the residuals' fourth-spread; common 0000.0000; hinges: Tukey's fourths", _nT_ - 1)
	if _nW_ < _nLw_  _nW_ = _nLw_  ok
	_nH_ = _nTop_ + _nR_ * _nCell_ + 20 + 7 * 24 + 20
	_oS_ = new stzMathSubstance(StzCodedTableDomain())
	_oS_.Declare("Figure", "fr")
	_oS_.Label("fr", _d_[:label])
	_oS_.SetData("fr", "rows", _nR_)  _oS_.SetData("fr", "cols", _nC_)
	_oS_.SetData("fr", "common", _nCommon_)  _oS_.SetData("fr", "scale", _nS_)
	_oS_.SetData("fr", "w", _nW_)  _oS_.SetData("fr", "h", _nH_)
	_oS_.SetData("fr", "x0", _nL_)  _oS_.SetData("fr", "y0", _nTop_)
	_oS_.SetData("fr", "cell", _nCell_)
	_oS_.SetData("fr", "tx", 30 + _FfTextWidth(poFont, _d_[:label], StzCodedTableFigureTitleSize()) / 2)
	_oS_.SetData("fr", "ty", 32)
	_oS_.SetData("fr", "symbols", 0)
	if _d_[:glyphs] = "symbols"  _oS_.SetData("fr", "symbols", 1)  ok
	for _i_ = 1 to _nR_
		_oS_.Declare("Row", "r" + _i_)
		_oS_.Label("r" + _i_, _d_[:rownames][_i_])
		_oS_.SetData("r" + _i_, "x", _nL_ - 12 - _FfTextWidth(poFont, _d_[:rownames][_i_], _nT_) / 2)
		_oS_.SetData("r" + _i_, "y", _nTop_ + (_i_ - 0.5) * _nCell_)
	next
	for _j_ = 1 to _nC_
		_oS_.Declare("Col", "c" + _j_)
		_oS_.Label("c" + _j_, _d_[:colnames][_j_])
		_oS_.SetData("c" + _j_, "x", _nL_ + (_j_ - 0.5) * _nCell_)
		_oS_.SetData("c" + _j_, "y", _nTop_ - 18)
	next
	_aCount_ = [ 0, 0, 0, 0, 0 ]
	for _i_ = 1 to _nR_
		for _j_ = 1 to _nC_
			_r_ = _aRes_[_i_][_j_]
			_nB_ = StzCodedBand(_r_, _nS_)
			_nSg_ = 0
			if _r_ < 0  _nSg_ = -1  but _r_ > 0  _nSg_ = 1  ok
			_cZ_ = "z" + _i_ + "_" + _j_
			_oS_.Declare("Cell", _cZ_)
			_oS_.Label(_cZ_, StzCodedGlyph(_d_[:glyphs], _nB_, _nSg_))
			_oS_.SetData(_cZ_, "row", _i_)  _oS_.SetData(_cZ_, "col", _j_)
			_oS_.SetData(_cZ_, "res", _r_)  _oS_.SetData(_cZ_, "band", _nB_)  _oS_.SetData(_cZ_, "sign", _nSg_)
			_oS_.SetData(_cZ_, "x", _nL_ + (_j_ - 0.5) * _nCell_)
			_oS_.SetData(_cZ_, "y", _nTop_ + (_i_ - 0.5) * _nCell_)
			_aCount_[_nB_ + 1]++
		next
	next
	for _b_ = 0 to 4
		_oS_.SetData("fr", "band" + _b_, _aCount_[_b_ + 1])
	next
	# THE LEGEND, OR THE TABLE IS A LIE: the scale, then the five bands
	_acL_ = [ "scale " + _FfNum(_nS_, 4) + " = the residuals' fourth-spread; common " + _FfNum(_nCommon_, 4) + "; hinges: Tukey's fourths" ]
	_acL_ + ("  " + StzCodedGlyph(_d_[:glyphs], 0, 0) + "  |r| / scale < 0.5     at the fit")
	_acL_ + ("  " + StzCodedGlyph(_d_[:glyphs], 1, -1) + " " + StzCodedGlyph(_d_[:glyphs], 1, 1) + "  < 1     mild, signed")
	_acL_ + ("  " + StzCodedGlyph(_d_[:glyphs], 2, -1) + " " + StzCodedGlyph(_d_[:glyphs], 2, 1) + "  < 2     notable, signed")
	_acL_ + ("  " + StzCodedGlyph(_d_[:glyphs], 3, -1) + " " + StzCodedGlyph(_d_[:glyphs], 3, 1) + "  < 3     outside, signed")
	_acL_ + ("  " + StzCodedGlyph(_d_[:glyphs], 4, 0) + "  >= 3    far out")
	_nLy_ = _nTop_ + _nR_ * _nCell_ + 34
	for _k_ = 1 to len(_acL_)
		_oS_.Declare("Legend", "g" + _k_)
		_oS_.Label("g" + _k_, _acL_[_k_])
		_oS_.SetData("g" + _k_, "x", 30 + _FfTextWidth(poFont, _acL_[_k_], _nT_ - 1) / 2)
		_oS_.SetData("g" + _k_, "y", _nLy_ + (_k_ - 1) * 24)
	next
	_oS_.SetData("fr", "legend", len(_acL_))
	return _oS_

func StzCodedTableFigureWhy(poSubstance)
	return "a coded table of " + poSubstance.DataOf("fr", "rows") + " x " + poSubstance.DataOf("fr", "cols") +
		" residuals over a scale of " + _FfNum(poSubstance.DataOf("fr", "scale"), 4) + ": " +
		poSubstance.DataOf("fr", "band0") + " at the fit, " + poSubstance.DataOf("fr", "band1") + " mild, " +
		poSubstance.DataOf("fr", "band2") + " notable, " + poSubstance.DataOf("fr", "band3") + " outside, " +
		poSubstance.DataOf("fr", "band4") + " far out"

# the text rendition: names, glyphs, the legend
func StzCodedTableFigureText(poSubstance)
	_nR_ = poSubstance.DataOf("fr", "rows")
	_nC_ = poSubstance.DataOf("fr", "cols")
	_nW_ = 0
	for _i_ = 1 to _nR_
		if len(poSubstance.LabelOf("r" + _i_)) > _nW_  _nW_ = len(poSubstance.LabelOf("r" + _i_))  ok
	next
	_nCw_ = 3
	for _j_ = 1 to _nC_
		if len(poSubstance.LabelOf("c" + _j_)) > _nCw_  _nCw_ = len(poSubstance.LabelOf("c" + _j_))  ok
	next
	_c_ = "  " + _CtSpaces(_nW_) + " "
	for _j_ = 1 to _nC_
		_cN_ = poSubstance.LabelOf("c" + _j_)
		_c_ += " " + _CtSpaces(_nCw_ - len(_cN_)) + _cN_
	next
	_c_ += char(10)
	for _i_ = 1 to _nR_
		_cN_ = poSubstance.LabelOf("r" + _i_)
		_c_ += "  " + _CtSpaces(_nW_ - len(_cN_)) + _cN_ + " "
		for _j_ = 1 to _nC_
			_c_ += " " + _CtSpaces(_nCw_ - 1) + poSubstance.LabelOf("z" + _i_ + "_" + _j_)
		next
		_c_ += char(10)
	next
	for _k_ = 1 to poSubstance.DataOf("fr", "legend")
		_c_ += "  " + poSubstance.LabelOf("g" + _k_) + char(10)
	next
	return _c_

func _CtSpaces(pn)
	_c_ = ""
	for _i_ = 1 to pn  _c_ += " "  next
	return _c_

#-- the declaration ---------------------------------------------------------

func _CtDeclaration(paSpec)
	if NOT isList(paSpec) or len(paSpec) = 0
		stzraise("StzCodedTableFigure: a coded table is declared as keys, like [ :of = [ [ 1, 2 ], [ 3, 4 ] ] ].")
	ok
	_acKeys_ = StzCodedTableFigureKeys()
	for _i_ = 1 to len(paSpec)
		_e_ = paSpec[_i_]
		if NOT isList(_e_) or len(_e_) != 2 or NOT isString(_e_[1])
			stzraise("StzCodedTableFigure: entry " + _i_ + " of the declaration is not a key and a value.")
		ok
		if NOT _FfIn(_acKeys_, StzLower(_e_[1]))
			stzraise("StzCodedTableFigure: ':" + _e_[1] + "' is not a key of a coded table -- the keys are " + @@(_acKeys_) + ".")
		ok
	next
	_d_ = [ :rows = [], :rownames = [], :colnames = [], :glyphs = "ascii", :label = "" ]
	_aR_ = _FfGet(paSpec, "of", [])
	_RpCheckTable(_aR_, "StzCodedTableFigure")
	if len(_aR_) > StzCodedTableFigureMaxSide() or len(_aR_[1]) > StzCodedTableFigureMaxSide()
		stzraise("StzCodedTableFigure: at most " + StzCodedTableFigureMaxSide() + " rows and columns on one picture.")
	ok
	_d_[:rows] = _aR_
	_nR_ = len(_aR_)
	_nC_ = len(_aR_[1])
	_aN_ = _FfGet(paSpec, "names", [])
	if NOT isList(_aN_)
		stzraise("StzCodedTableFigure: :names is [ row names, column names ].")
	ok
	if len(_aN_) = 0
		for _i_ = 1 to _nR_  _d_[:rownames] + ("r" + _i_)  next
		for _j_ = 1 to _nC_  _d_[:colnames] + ("c" + _j_)  next
	else
		if len(_aN_) != 2 or NOT isList(_aN_[1]) or NOT isList(_aN_[2]) or len(_aN_[1]) != _nR_ or len(_aN_[2]) != _nC_
			stzraise("StzCodedTableFigure: :names is [ row names, column names ] with " + _nR_ + " and " + _nC_ + " names.")
		ok
		for _i_ = 1 to _nR_  _d_[:rownames] + ("" + _aN_[1][_i_])  next
		for _j_ = 1 to _nC_  _d_[:colnames] + ("" + _aN_[2][_j_])  next
	ok
	_cG_ = _FfGet(paSpec, "glyphs", "ascii")
	if NOT isString(_cG_)
		stzraise("StzCodedTableFigure: :glyphs is :Ascii or :Symbols.")
	ok
	_cG_ = StzLower(_cG_)
	if _cG_ != "ascii" and _cG_ != "symbols"
		stzraise("StzCodedTableFigure: :glyphs is :Ascii or :Symbols -- not '" + _cG_ + "'. The meanings of the bands never change; only the glyph set does.")
	ok
	_d_[:glyphs] = _cG_
	_cL_ = _FfGet(paSpec, "label", "")
	if NOT isString(_cL_)
		stzraise("StzCodedTableFigure: :label is text.")
	ok
	_d_[:label] = _cL_
	return _d_

#-- the style ----------------------------------------------------------------

func StzCodedTableStyle()
	return StzCodedTableStyleXT(520, 400)

func StzCodedTableStyleXT(pnW, pnH)
	_o_ = new stzMathStyle()
	_o_.SetCanvas(pnW, pnH)
	_o_.SetMargin(4)
	_nT_ = StzCodedTableFigureTypeSize()
	_nC_ = StzCodedTableFigureCell()
	_o_.ForAll("Figure f", [
		[ :shape, "f.text", :text, [ :cx = "f.tx", :cy = "f.ty", :size = StzCodedTableFigureTitleSize(),
		                             :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAll("Row r", [
		[ :shape, "r.text", :text, [ :cx = "r.x", :cy = "r.y", :size = _nT_, :fill = "neutral" ] ] ])
	_o_.ForAll("Col c", [
		[ :shape, "c.text", :text, [ :cx = "c.x", :cy = "c.y", :size = _nT_ - 1, :fill = "neutral" ] ] ])
	_o_.ForAll("Cell z", [
		[ :shape, "z.icon", :rect, [ :cx = "z.x", :cy = "z.y", :w = _nC_ - 2, :h = _nC_ - 2,
		                             :fill = [ :ramp, "z.band", 0, 4, "background", "primary" ],
		                             :stroke = "background", :strokeWidth = 2 ] ],
		[ :shape, "z.text", :text, [ :cx = "z.x", :cy = "z.y", :size = _nT_ + 4, :fill = [ :on, "z.icon" ] ] ],
		[ :layer, "z.text", :above, "z.icon" ] ])
	_o_.ForAll("Legend g", [
		[ :shape, "g.text", :text, [ :cx = "g.x", :cy = "g.y", :size = _nT_ - 1, :fill = "neutral" ] ] ])
	return _o_

#-- the rules --------------------------------------------------------------

func StzCodedTableRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("glyph_is_its_band")
	_o1_.SetClaim("a cell's glyph is the glyph of its residual's band over the scale, with its sign")
	_o1_.SetOrder(95)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _CtScope(oDg, "Cell", "cell:") })
	_o1_.SetCounter(func(oDg) { return _CtCounter(oDg, "Cell") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cZ_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_cSet_ = "ascii"
		if _oS_.DataOf("fr", "symbols") = 1  _cSet_ = "symbols"  ok
		_r_ = _oS_.DataOf(_cZ_, "res")
		_nB_ = StzCodedBand(_r_, _oS_.DataOf("fr", "scale"))
		_nSg_ = 0
		if _r_ < 0  _nSg_ = -1  but _r_ > 0  _nSg_ = 1  ok
		_cWant_ = StzCodedGlyph(_cSet_, _nB_, _nSg_)
		if _oS_.LabelOf(_cZ_) != _cWant_
			return [ FALSE, "cell (" + _oS_.DataOf(_cZ_, "row") + ", " + _oS_.DataOf(_cZ_, "col") + ") shows '" +
				_oS_.LabelOf(_cZ_) + "' for a residual of " + _FfNum(_r_, 4) + ", which is " + StzCodedBandName(_nB_) +
				" and should show '" + _cWant_ + "'" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("legend_is_printed")
	_o2_.SetClaim("the legend names the scale, the common value and the hinge convention, and lists the five bands")
	_o2_.SetOrder(96)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) { return _CtScopeFigure(oDg) })
	_o2_.SetCounter(func(oDg) { return _CtCounterFigure(oDg) })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_oS_ = oDg.Substance()
		_n_ = _oS_.DataOf("fr", "legend")
		if _n_ < 6
			return [ FALSE, "the legend has " + _n_ + " line(s); the scale and five bands need six" ]
		ok
		_c1_ = _oS_.LabelOf("g1")
		if StzFindFirst("scale " + _FfNum(_oS_.DataOf("fr", "scale"), 4), _c1_) = 0 or StzFindFirst("hinges", _c1_) = 0
			return [ FALSE, "the legend's first line does not name the scale and the hinge convention: '" + _c1_ + "'" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	_o3_ = StzPlasticRule("cells_tile_the_table")
	_o3_.SetClaim("there is one cell per row and column, no more and no fewer")
	_o3_.SetOrder(97)
	_o3_.SetReads([ "substance" ])
	_o3_.SetScope(func(oDg) { return _CtScopeFigure(oDg) })
	_o3_.SetCounter(func(oDg) { return _CtCounterFigure(oDg) })
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_oS_ = oDg.Substance()
		_n_ = len(_oS_.ObjectsOfType("Cell"))
		_nWant_ = _oS_.DataOf("fr", "rows") * _oS_.DataOf("fr", "cols")
		if _n_ != _nWant_
			return [ FALSE, "" + _n_ + " cell(s) for a table of " + _nWant_ ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o3_
	return _ao_

func _CtIsCoded(poDg)
	return isObject(poDg) and StzLower("" + poDg.Substance().DomainQ().Name_()) = "codedtable"

func _CtScope(poDg, pcType, pcPrefix)
	if NOT _CtIsCoded(poDg)  return []  ok
	_ac_ = poDg.Substance().ObjectsOfType(pcType)
	_a_ = []
	for _i_ = 1 to len(_ac_)  _a_ + (pcPrefix + _ac_[_i_])  next
	return _a_

func _CtCounter(poDg, pcType)
	if NOT _CtIsCoded(poDg)  return 0  ok
	return len(poDg.Substance().ObjectsOfType(pcType))

func _CtScopeFigure(poDg)
	if NOT _CtIsCoded(poDg)  return []  ok
	return [ "figure:fr" ]

func _CtCounterFigure(poDg)
	if NOT _CtIsCoded(poDg)  return 0  ok
	return 1
