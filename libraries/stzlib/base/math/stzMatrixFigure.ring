#=====================================================================#
#  STZMATRIXFIGURE -- M1c: a matrix is a FIGURE, and a product is a    #
#  picture of how every cell is made                                   #
#=====================================================================#
/*
	THE FOURTH VISUAL DOOR (base/math/CHARTER.md, "matrices as pictures").
	A matrix is a grid of cells; a product A . B = C is three grids with
	the glyphs between them, and the one thing worth SEEING in a product
	is how a cell of C is made: a row of A against a column of B. The
	figure lights them. The heat form colours every cell by its value on
	one ramp across the whole figure, which is how a matrix's shape --
	a band, a block, a spike -- shows before any number is read.

	WHAT A MATRIX FIGURE IS HERE:

	    DOMAIN     Figure, the paper and its title; Grid, one matrix with
	               its name, rows and columns; Cell, one value in a grid;
	               Glyph, the "x" or "=" between grids; Head, a grid's
	               name and dimensions above it. Lit(Cell) marks a cell
	               the author asked to see; Result(Grid) marks the grid
	               the figure computed; Heat(Cell) colours by value.

	    SUBSTANCE  built from a declaration:
	                 [ :of = [ [ 1, 2 ], [ 3, 4 ] ] ]                     one matrix
	                 [ :product = [ A, B ], :show = [ 2, 1 ] ]           A . B = C
	               with :as = :grid (default) or :heat, :names, :label.
	               The product is computed here in Ring, exactly for
	               integers; every cell is a datum and its place a datum.

	    STYLE      a cell as a square with its value inside, lit ones in
	               the info colour, heat ones on a ramp from the paper to
	               the primary colour with the digits switching to what
	               reads on them; heads above; glyphs between.

	WHAT THE DOMAIN OWES THE GATE:

	    product_cell_is_the_dot_product   every cell of the result is the
	                                      row of A against the column of B
	    dimensions_agree                  A's columns are B's rows
	    grid_holds_its_cells              a grid has rows times columns cells

	WHAT IS SAID PLAINLY: nothing is solved -- a matrix picture has no
	choice to make, and it says "nothing to lay out"; values are f64 here,
	so a product of decimals is as exact as f64 is, and the exact tower's
	path through a matrix is M3's teaching slice; a matrix wider than
	twelve or taller than twelve does not fit a paper a person reads and
	is refused with the numbers.
*/

StzRegisterMathRuleSet("matrix", StzMatrixRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzMatrixDomain()
	_o_ = new stzMathDomain("matrix")
	_o_.AddType("Figure")
	_o_.AddType("Grid")
	_o_.AddType("Cell")
	_o_.AddType("Glyph")
	_o_.AddType("Head")
	_o_.AddPredicate("Lit", [ "Cell" ])
	_o_.AddPredicate("Heat", [ "Cell" ])
	_o_.AddPredicate("Result", [ "Grid" ])
	return _o_

func StzMatrixFigureCell()
	return 54

func StzMatrixFigureGap()
	return 70

func StzMatrixFigureTypeSize()
	return 17

func StzMatrixFigureTitleSize()
	return 20

func StzMatrixFigureMaxSide()
	return 12

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM A DECLARATION                                   #
#---------------------------------------------------------------------#

func StzMatrixFigureKeys()
	return [ "of", "product", "as", "show", "names", "label" ]

func StzMatrixFigureFrom(paSpec)
	return StzMatrixFigureFromXT(NULL, paSpec)

func StzMatrixFigureBuildXT(poFont, paSpec)
	_oS_ = StzMatrixFigureFromXT(poFont, paSpec)
	_o_ = new stzMathDiagram(_oS_.DomainQ(), _oS_,
		StzMatrixStyleXT(_oS_.DataOf("fig", "w"), _oS_.DataOf("fig", "h")))
	if isObject(poFont)  _o_.SetFont(poFont, StzMatrixFigureTypeSize())  ok
	_o_.SetVariation("matrix")
	return _o_

func StzMatrixFigureFromXT(poFont, paSpec)
	_d_ = _MxDeclaration(paSpec)
	_aG_ = _d_[:grids]          # [ [ name, rows ] ] -- the result grid last when a product
	_nC_ = StzMatrixFigureCell()
	_nGap_ = StzMatrixFigureGap()
	_nTop_ = 96
	if _d_[:label] = ""  _nTop_ = 66  ok
	_aTb_ = _FfTitleBox(poFont, _d_[:label], StzMatrixFigureTitleSize())
	if _d_[:label] != "" and _aTb_[1] + _aTb_[2] + 50 > _nTop_  _nTop_ = _aTb_[1] + _aTb_[2] + 50  ok

	# the paper: grids side by side, glyphs between, heads above
	_nMaxRows_ = 0
	_nW_ = 60
	for _g_ = 1 to len(_aG_)
		_nR_ = len(_aG_[_g_][2])
		if _nR_ > _nMaxRows_  _nMaxRows_ = _nR_  ok
		_nW_ += len(_aG_[_g_][2][1]) * _nC_
		if _g_ < len(_aG_)  _nW_ += _nGap_  ok
	next
	_nW_ += 60
	_nH_ = _nTop_ + _nMaxRows_ * _nC_ + 50

	# the ramp's range: the least and the greatest value in the figure
	_nLo_ = 0  _nHi_ = 0  _bAny_ = FALSE
	for _g_ = 1 to len(_aG_)
		_aM_ = _aG_[_g_][2]
		for _i_ = 1 to len(_aM_)
			for _j_ = 1 to len(_aM_[_i_])
				if NOT _bAny_  _nLo_ = _aM_[_i_][_j_]  _nHi_ = _aM_[_i_][_j_]  _bAny_ = TRUE  ok
				if _aM_[_i_][_j_] < _nLo_  _nLo_ = _aM_[_i_][_j_]  ok
				if _aM_[_i_][_j_] > _nHi_  _nHi_ = _aM_[_i_][_j_]  ok
			next
		next
	next
	if _nHi_ - _nLo_ < 0.000000001  _nHi_ = _nLo_ + 1  ok

	_oS_ = new stzMathSubstance(StzMatrixDomain())
	_oS_.Declare("Figure", "fig")
	_oS_.Label("fig", _d_[:label])
	_oS_.SetData("fig", "w", _nW_)  _oS_.SetData("fig", "h", _nH_)
	_oS_.SetData("fig", "tx", 30 + _FfTextWidth(poFont, _d_[:label], StzMatrixFigureTitleSize()) / 2)
	_oS_.SetData("fig", "ty", _aTb_[1] + 8)
	_oS_.SetData("fig", "grids", len(_aG_))
	_oS_.SetData("fig", "lo", _nLo_)  _oS_.SetData("fig", "hi", _nHi_)
	_oS_.SetData("fig", "isheat", (_d_[:as] = "heat"))
	_oS_.SetData("fig", "isproduct", _d_[:product])
	_oS_.SetData("fig", "cells", 0)

	_nX_ = 30
	_nCells_ = 0
	_acPfx_ = [ "a", "b", "c" ]
	for _g_ = 1 to len(_aG_)
		_cName_ = _aG_[_g_][1]
		_aM_ = _aG_[_g_][2]
		_nR_ = len(_aM_)
		_nK_ = len(_aM_[1])
		_cG_ = "g" + _g_
		_cP_ = _acPfx_[_g_]
		_nY0_ = _nTop_ + (_nMaxRows_ - _nR_) * _nC_ / 2
		_oS_.Declare("Grid", _cG_)
		_oS_.Label(_cG_, _cName_)
		_oS_.SetData(_cG_, "rows", _nR_)  _oS_.SetData(_cG_, "cols", _nK_)
		_oS_.SetData(_cG_, "x0", _nX_)  _oS_.SetData(_cG_, "y0", _nY0_)
		_oS_.SetData(_cG_, "x", _nX_ + _nK_ * _nC_ / 2)  _oS_.SetData(_cG_, "y", _nY0_ + _nR_ * _nC_ / 2)
		_oS_.SetData(_cG_, "w", _nK_ * _nC_)  _oS_.SetData(_cG_, "hh", _nR_ * _nC_)
		if _d_[:product] and _g_ = 3  _oS_.Assert("Result", [ _cG_ ])  ok
		_oS_.Declare("Head", "h" + _g_)
		_oS_.Label("h" + _g_, _cName_ + "  (" + _nR_ + " x " + _nK_ + ")")
		_oS_.SetData("h" + _g_, "x", _nX_ + _nK_ * _nC_ / 2)
		_oS_.SetData("h" + _g_, "y", _nY0_ - 22)
		for _i_ = 1 to _nR_
			for _j_ = 1 to _nK_
				_cC_ = _cP_ + _i_ + "_" + _j_
				_v_ = _aM_[_i_][_j_]
				_oS_.Declare("Cell", _cC_)
				_oS_.Label(_cC_, _FfNum(_v_, 4))
				_oS_.SetData(_cC_, "grid", _g_)
				_oS_.SetData(_cC_, "row", _i_)  _oS_.SetData(_cC_, "col", _j_)
				_oS_.SetData(_cC_, "v", _v_)
				_oS_.SetData(_cC_, "t", (_v_ - _nLo_) / (_nHi_ - _nLo_))
				_oS_.SetData(_cC_, "x", _nX_ + (_j_ - 0.5) * _nC_)
				_oS_.SetData(_cC_, "y", _nY0_ + (_i_ - 0.5) * _nC_)
				if _d_[:as] = "heat"  _oS_.Assert("Heat", [ _cC_ ])  ok
				_nCells_++
			next
		next
		# the lit row, column and cell of a shown product entry
		if _d_[:product] and len(_d_[:show]) = 2
			_nSi_ = _d_[:show][1]
			_nSj_ = _d_[:show][2]
			if _g_ = 1
				for _j_ = 1 to _nK_  _oS_.Assert("Lit", [ "a" + _nSi_ + "_" + _j_ ])  next
			but _g_ = 2
				for _i_ = 1 to _nR_  _oS_.Assert("Lit", [ "b" + _i_ + "_" + _nSj_ ])  next
			else
				_oS_.Assert("Lit", [ "c" + _nSi_ + "_" + _nSj_ ])
			ok
		ok
		_nX_ += _nK_ * _nC_
		if _g_ < len(_aG_)
			_cGl_ = "times"
			_cT_ = "x"
			if _g_ = 2  _cGl_ = "equals"  _cT_ = "="  ok
			_oS_.Declare("Glyph", _cGl_)
			_oS_.Label(_cGl_, _cT_)
			_oS_.SetData(_cGl_, "x", _nX_ + _nGap_ / 2)
			_oS_.SetData(_cGl_, "y", _nTop_ + _nMaxRows_ * _nC_ / 2)
			_nX_ += _nGap_
		ok
	next
	_oS_.SetData("fig", "cells", _nCells_)
	return _oS_

func StzMatrixFigureWhy(poSubstance)
	_n_ = poSubstance.DataOf("fig", "grids")
	_c_ = "a matrix figure: "
	for _g_ = 1 to _n_
		if _g_ = 2  _c_ += " . "  ok
		if _g_ = 3  _c_ += " = "  ok
		_c_ += poSubstance.LabelOf("g" + _g_) + " (" + poSubstance.DataOf("g" + _g_, "rows") + " x " +
			poSubstance.DataOf("g" + _g_, "cols") + ")"
	next
	_c_ += ", " + poSubstance.DataOf("fig", "cells") + " cells"
	if poSubstance.DataOf("fig", "isheat") = 1  _c_ += " on one ramp"  ok
	return _c_

#-- the declaration, read and refused by name -------------------------

func _MxDeclaration(paSpec)
	if NOT isList(paSpec) or len(paSpec) = 0
		stzraise("StzMatrixFigure: a matrix is declared as keys, like [ :of = [ [ 1, 2 ], [ 3, 4 ] ] ].")
	ok
	_acKeys_ = StzMatrixFigureKeys()
	for _i_ = 1 to len(paSpec)
		_e_ = paSpec[_i_]
		if NOT isList(_e_) or len(_e_) != 2 or NOT isString(_e_[1])
			stzraise("StzMatrixFigure: entry " + _i_ + " of the declaration is not a key and a value.")
		ok
		if NOT _FfIn(_acKeys_, StzLower(_e_[1]))
			stzraise("StzMatrixFigure: ':" + _e_[1] + "' is not a key of a matrix figure -- " +
				"the keys are " + @@(_acKeys_) + ".")
		ok
	next
	_d_ = [ :grids = [], :product = FALSE, :as = "grid", :show = [], :label = "" ]
	_acN_ = _FfGet(paSpec, "names", [])
	if isString(_acN_)  _acN_ = [ _acN_ ]  ok
	if NOT isList(_acN_)
		stzraise("StzMatrixFigure: :names is a list of names, one per matrix.")
	ok
	_aOf_ = _FfGet(paSpec, "of", [])
	_aPr_ = _FfGet(paSpec, "product", [])
	if isList(_aOf_) and len(_aOf_) > 0 and isList(_aPr_) and len(_aPr_) > 0
		stzraise("StzMatrixFigure: :of and :product cannot both be given.")
	ok
	if isList(_aOf_) and len(_aOf_) > 0
		_aM_ = _MxMatrix(_aOf_, "the matrix")
		_cN_ = "A"
		if len(_acN_) >= 1  _cN_ = "" + _acN_[1]  ok
		_d_[:grids] + [ _cN_, _aM_ ]
	but isList(_aPr_) and len(_aPr_) > 0
		if len(_aPr_) != 2
			stzraise("StzMatrixFigure: :product is [ A, B ], two matrices.")
		ok
		_aA_ = _MxMatrix(_aPr_[1], "A")
		_aB_ = _MxMatrix(_aPr_[2], "B")
		if len(_aA_[1]) != len(_aB_)
			stzraise("StzMatrixFigure: A has " + len(_aA_[1]) + " column(s) and B has " + len(_aB_) +
				" row(s) -- a product needs them equal.")
		ok
		_cA_ = "A"  _cB_ = "B"
		if len(_acN_) >= 1  _cA_ = "" + _acN_[1]  ok
		if len(_acN_) >= 2  _cB_ = "" + _acN_[2]  ok
		_aC_ = []
		for _i_ = 1 to len(_aA_)
			_row_ = []
			for _j_ = 1 to len(_aB_[1])
				_s_ = 0
				for _k_ = 1 to len(_aB_)
					_s_ += _aA_[_i_][_k_] * _aB_[_k_][_j_]
				next
				_row_ + _s_
			next
			_aC_ + _row_
		next
		_d_[:grids] + [ _cA_, _aA_ ]
		_d_[:grids] + [ _cB_, _aB_ ]
		_d_[:grids] + [ _cA_ + " . " + _cB_, _aC_ ]
		_d_[:product] = TRUE
		_aSh_ = _FfGet(paSpec, "show", [])
		if isList(_aSh_) and len(_aSh_) > 0
			if len(_aSh_) != 2 or NOT isNumber(_aSh_[1]) or NOT isNumber(_aSh_[2])
				stzraise("StzMatrixFigure: :show is [ row, column ] of the product to light.")
			ok
			if _aSh_[1] < 1 or _aSh_[1] > len(_aA_) or _aSh_[2] < 1 or _aSh_[2] > len(_aB_[1]) or
			   _aSh_[1] != floor(_aSh_[1]) or _aSh_[2] != floor(_aSh_[2])
				stzraise("StzMatrixFigure: there is no cell (" + _aSh_[1] + ", " + _aSh_[2] + ") in a " +
					len(_aA_) + " x " + len(_aB_[1]) + " product.")
			ok
			_d_[:show] = [ _aSh_[1], _aSh_[2] ]
		ok
	else
		stzraise("StzMatrixFigure: say what to draw -- :of = a matrix, or :product = [ A, B ].")
	ok
	_cAs_ = StzLower(ring_trim("" + _FfGet(paSpec, "as", "grid")))
	if _cAs_ != "grid" and _cAs_ != "heat"
		stzraise("StzMatrixFigure: :as is :grid or :heat.")
	ok
	_d_[:as] = _cAs_
	_cL_ = _FfGet(paSpec, "label", "")
	if NOT isString(_cL_)
		stzraise("StzMatrixFigure: :label is text.")
	ok
	_d_[:label] = _cL_
	return _d_

func _MxMatrix(paM, pcWhat)
	if NOT isList(paM) or len(paM) = 0 or NOT isList(paM[1]) or len(paM[1]) = 0
		stzraise("StzMatrixFigure: " + pcWhat + " is a list of rows, each a list of numbers.")
	ok
	_nK_ = len(paM[1])
	for _i_ = 1 to len(paM)
		if NOT isList(paM[_i_]) or len(paM[_i_]) != _nK_
			stzraise("StzMatrixFigure: row " + _i_ + " of " + pcWhat + " has " + len(paM[_i_]) +
				" entries where row 1 has " + _nK_ + " -- a matrix is rectangular.")
		ok
		for _j_ = 1 to _nK_
			if NOT isNumber(paM[_i_][_j_])
				stzraise("StzMatrixFigure: entry (" + _i_ + ", " + _j_ + ") of " + pcWhat + " is not a number.")
			ok
		next
	next
	if len(paM) > StzMatrixFigureMaxSide() or _nK_ > StzMatrixFigureMaxSide()
		stzraise("StzMatrixFigure: " + pcWhat + " is " + len(paM) + " x " + _nK_ + " -- more than " +
			StzMatrixFigureMaxSide() + " a side does not fit a paper a person reads.")
	ok
	return paM

#---------------------------------------------------------------------#
#  THE STYLE -- every position a datum                                 #
#---------------------------------------------------------------------#

func StzMatrixStyle()
	return StzMatrixStyleXT(600, 300)

func StzMatrixStyleXT(pnW, pnH)
	_o_ = new stzMathStyle()
	_o_.SetCanvas(pnW, pnH)
	_o_.SetMargin(4)
	_nT_ = StzMatrixFigureTypeSize()
	_nC_ = StzMatrixFigureCell()
	_o_.ForAll("Figure g", [
		[ :shape, "g.text", :text, [ :cx = "g.tx", :cy = "g.ty", :size = StzMatrixFigureTitleSize(),
		                             :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAll("Grid m", [
		[ :shape, "m.box", :rect, [ :cx = "m.x", :cy = "m.y", :w = "m.w", :h = "m.hh",
		                            :fill = [ :alpha, "primary", 0.03 ], :stroke = "neutral", :strokeWidth = 1.5 ] ] ])
	_o_.ForAllWhere("Grid m", "Result(m)", [
		[ :delete, "m.box" ],
		[ :shape, "m.box", :rect, [ :cx = "m.x", :cy = "m.y", :w = "m.w", :h = "m.hh",
		                            :fill = [ :alpha, "primary", 0.03 ], :stroke = "primary", :strokeWidth = 2 ] ] ])
	_o_.ForAll("Cell c", [
		[ :shape, "c.icon", :rect, [ :cx = "c.x", :cy = "c.y", :w = _nC_ - 2, :h = _nC_ - 2,
		                             :fill = [ :alpha, "primary", 0.06 ], :stroke = "background", :strokeWidth = 2 ] ],
		[ :shape, "c.text", :text, [ :cx = "c.x", :cy = "c.y", :size = _nT_, :fill = [ :on, "c.icon" ] ] ],
		[ :layer, "c.text", :above, "c.icon" ] ])
	_o_.ForAllWhere("Cell c", "Heat(c)", [
		[ :delete, "c.icon" ],
		[ :shape, "c.icon", :rect, [ :cx = "c.x", :cy = "c.y", :w = _nC_ - 2, :h = _nC_ - 2,
		                             :fill = [ :ramp, "c.t", 0, 1, "background", "primary" ],
		                             :stroke = "background", :strokeWidth = 2 ] ] ])
	_o_.ForAllWhere("Cell c", "Lit(c)", [
		[ :delete, "c.icon" ],
		[ :shape, "c.icon", :rect, [ :cx = "c.x", :cy = "c.y", :w = _nC_ - 2, :h = _nC_ - 2,
		                             :fill = [ :alpha, "info", 0.35 ], :stroke = "info", :strokeWidth = 2 ] ] ])
	_o_.ForAll("Glyph y", [
		[ :shape, "y.text", :text, [ :cx = "y.x", :cy = "y.y", :size = 30, :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAll("Head h", [
		[ :shape, "h.text", :text, [ :cx = "h.x", :cy = "h.y", :size = _nT_ - 1, :fill = "neutral" ] ] ])
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE                                        #
#---------------------------------------------------------------------#

func _MxIsMatrix(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "matrix"

func _MxScope(poDg, pcType, pcPrefix)
	_r_ = []
	if NOT _MxIsMatrix(poDg)  return _r_  ok
	_ac_ = poDg.Substance().ObjectsOfType(pcType)
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _MxResultCells(poDg, pcPrefix)
	_r_ = []
	if NOT _MxIsMatrix(poDg)  return _r_  ok
	_oS_ = poDg.Substance()
	if _oS_.DataOf("fig", "isproduct") != 1  return _r_  ok
	_ac_ = _oS_.ObjectsOfType("Cell")
	for _i_ = 1 to len(_ac_)
		if _oS_.DataOf(_ac_[_i_], "grid") = 3  _r_ + (pcPrefix + _ac_[_i_])  ok
	next
	return _r_

func _MxCounter(poDg, pcPrefix)
	_r_ = []
	if NOT isObject(poDg) or _MxIsMatrix(poDg)  return _r_  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return _r_  ok
	_ac_ = poDg.Substance().ObjectNames()
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

# the value at (grid, row, col), by the cell's name
func _MxValue(poSubstance, pcPrefix, pnRow, pnCol)
	return poSubstance.DataOf(pcPrefix + pnRow + "_" + pnCol, "v")

func StzMatrixRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("product_cell_is_the_dot_product")
	_o1_.SetClaim("every cell of the result is the row of A against the column of B")
	_o1_.SetOrder(79)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _MxResultCells(oDg, "cell:") })
	_o1_.SetCounter(func(oDg) { return _MxCounter(oDg, "cell:") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cC_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_i_ = _oS_.DataOf(_cC_, "row")
		_j_ = _oS_.DataOf(_cC_, "col")
		_nK_ = _oS_.DataOf("g1", "cols")
		_s_ = 0
		for _k_ = 1 to _nK_
			_s_ += _MxValue(_oS_, "a", _i_, _k_) * _MxValue(_oS_, "b", _k_, _j_)
		next
		_v_ = _oS_.DataOf(_cC_, "v")
		if fabs(_s_ - _v_) > 0.000000001 * (1 + fabs(_s_))
			return [ FALSE, "cell (" + _i_ + ", " + _j_ + ") of the product shows " + _FfNum(_v_, 6) +
				", and row " + _i_ + " of A against column " + _j_ + " of B is " + _FfNum(_s_, 6) ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("dimensions_agree")
	_o2_.SetClaim("in a product, A's columns are B's rows")
	_o2_.SetOrder(80)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) {
		_r_ = []
		if NOT _MxIsMatrix(oDg)  return _r_  ok
		if oDg.Substance().DataOf("fig", "isproduct") = 1  _r_ + "product:g3"  ok
		return _r_ })
	_o2_.SetCounter(func(oDg) { return _MxCounter(oDg, "product:") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_oS_ = oDg.Substance()
		_nA_ = _oS_.DataOf("g1", "cols")
		_nB_ = _oS_.DataOf("g2", "rows")
		if _nA_ != _nB_
			return [ FALSE, "A has " + _nA_ + " column(s) and B has " + _nB_ + " row(s)" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	_o3_ = StzPlasticRule("grid_holds_its_cells")
	_o3_.SetClaim("a grid has rows times columns cells")
	_o3_.SetOrder(81)
	_o3_.SetReads([ "substance" ])
	_o3_.SetScope(func(oDg) { return _MxScope(oDg, "Grid", "grid:") })
	_o3_.SetCounter(func(oDg) { return _MxCounter(oDg, "grid:") })
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cG_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_nG_ = 0
		for _i_ = 2 to len(_cG_)  _nG_ = _nG_ * 10 + (ascii(_cG_[_i_]) - 48)  next
		_n_ = 0
		_ac_ = _oS_.ObjectsOfType("Cell")
		for _i_ = 1 to len(_ac_)
			if _oS_.DataOf(_ac_[_i_], "grid") = _nG_  _n_++  ok
		next
		_nWant_ = _oS_.DataOf(_cG_, "rows") * _oS_.DataOf(_cG_, "cols")
		if _n_ != _nWant_
			return [ FALSE, "'" + _oS_.LabelOf(_cG_) + "' says " + _oS_.DataOf(_cG_, "rows") + " x " +
				_oS_.DataOf(_cG_, "cols") + " and holds " + _n_ + " cell(s)" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o3_

	return _ao_
