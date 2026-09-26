#=====================================================================#
#  STZFRACTIONFIGURE -- M1b: a fraction is a FIGURE, and the picture   #
#  agrees with a count                                                 #
#=====================================================================#
/*
	THE THIRD VISUAL DOOR (base/math/CHARTER.md, level L0): three of four
	is three shaded parts of four equal ones, and a child proves it by
	counting. So does the gate. A fraction is declared -- a numerator and
	a denominator, or several fractions to compare, as bars or as discs
	-- and the builder COMPUTES every part; nothing is solved, because a
	fraction picture has no choice to make, and the figure says so
	("nothing to lay out"), the way the gantt and the timeline do.

	WHAT A FRACTION IS HERE:

	    DOMAIN     Whole, a bar or a disc; Part, one of its equal pieces,
	               Shaded when it counts; Note, the name of a whole (a
	               constructor over Whole), "3/4"; Verdict, what two
	               fractions compared say, ">" "<" or "=", decided by
	               cross-multiplication on integers -- exactly.

	    SUBSTANCE  built from a declaration:
	                 [ :of = [ 3, 4 ] ]                          one fraction
	                 [ :compare = [ [ 3, 4 ], [ 2, 3 ] ] ]       several
	                 :as = :bar (default) or :disc; :label
	               Bars share one width, so equal fractions END at the
	               same place -- 2/4 and 1/2 align to the pixel, which is
	               the picture's own proof that they are equal. Discs sit
	               side by side.

	    STYLE      a whole as a faint field with a stroke; a shaded part
	               in the primary colour, an unshaded one nearly clear;
	               parts separated by the paper's colour; the name to the
	               left of a bar or under a disc; a verdict between two
	               bars.

	WHAT THE DOMAIN OWES THE GATE:

	    shaded_is_the_numerator     a whole's shaded parts number its
	                                numerator
	    parts_are_the_denominator   a whole's parts number its denominator
	    parts_tile_the_whole        a bar's parts add up to its width, a
	                                disc's to a full turn

	WHAT IS SAID PLAINLY: a numerator larger than its denominator wants
	more than one whole, and is refused here until a later slice draws
	two; a denominator over 48 draws parts no eye can count and is
	refused; the name "3/4" is text, since the notation of a stacked
	fraction is M1's last step.
*/

StzRegisterMathRuleSet("fraction", StzFractionRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzFractionDomain()
	_o_ = new stzMathDomain("fraction")
	_o_.AddType("Figure")
	_o_.AddType("Whole")
	_o_.AddType("Part")
	_o_.AddType("Note")
	_o_.AddType("Verdict")
	_o_.AddConstructor("Note", [ "Whole" ])
	_o_.AddConstructor("Verdict", [ "Whole", "Whole" ])
	_o_.AddPredicate("Shaded", [ "Part" ])
	_o_.AddPredicate("Disc", [ "Whole" ])
	_o_.AddPredicate("Wedge", [ "Part" ])
	# a wedge is a polygon of a fixed vertex count, and a polygon rule is
	# written for a count, so each count that can occur is a predicate
	for _n_ = 3 to 24
		_o_.AddPredicate("Pts" + _n_, [ "Part" ])
	next
	return _o_

func StzFractionFigureWidth()
	return 900

func StzFractionFigureTypeSize()
	return 17

func StzFractionFigureTitleSize()
	return 20

func StzFractionFigureBarLeft()
	return 150

func StzFractionFigureBarRight()
	return 760

func StzFractionFigureBarHeight()
	return 54

func StzFractionFigureBarPitch()
	return 96

func StzFractionFigureDiscRadius()
	return 108

func StzFractionFigureMaxDenominator()
	return 48

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM A DECLARATION                                   #
#---------------------------------------------------------------------#

func StzFractionFigureKeys()
	return [ "of", "compare", "as", "label" ]

func StzFractionFigureFrom(paSpec)
	return StzFractionFigureFromXT(NULL, paSpec)

func StzFractionFigureBuildXT(poFont, paSpec)
	_oS_ = StzFractionFigureFromXT(poFont, paSpec)
	_o_ = new stzMathDiagram(_oS_.DomainQ(), _oS_, StzFractionStyleXT(StzFractionFigureHeightOf(_oS_)))
	if isObject(poFont)  _o_.SetFont(poFont, StzFractionFigureTypeSize())  ok
	_o_.SetVariation("fraction")
	return _o_

func StzFractionFigureHeightOf(poSubstance)
	return poSubstance.DataOf("fig", "h")

func StzFractionFigureFromXT(poFont, paSpec)
	_d_ = _FrDeclaration(paSpec)
	_aF_ = _d_[:fractions]
	_nW_ = len(_aF_)
	_oS_ = new stzMathSubstance(StzFractionDomain())
	_nTop_ = 56
	if _d_[:label] = ""  _nTop_ = 26  ok

	# the figure's own datum: its height follows how many wholes it holds
	_oS_.Declare("Figure", "fig")
	_oS_.Label("fig", _d_[:label])
	_oS_.SetData("fig", "wholes", _nW_)
	_oS_.SetData("fig", "tx", 40 + _FfTextWidth(poFont, _d_[:label], StzFractionFigureTitleSize()) / 2)
	_oS_.SetData("fig", "ty", 30)

	if _d_[:as] = "bar"
		_nH_ = _nTop_ + _nW_ * StzFractionFigureBarPitch() + 10
		_nX0_ = StzFractionFigureBarLeft()
		_nX1_ = StzFractionFigureBarRight()
		for _w_ = 1 to _nW_
			_nN_ = _aF_[_w_][1]
			_nD_ = _aF_[_w_][2]
			_cW_ = "w" + _w_
			_nY_ = _nTop_ + (_w_ - 1) * StzFractionFigureBarPitch() + StzFractionFigureBarHeight() / 2 + 10
			_oS_.Declare("Whole", _cW_)
			_oS_.Label(_cW_, "")
			_oS_.SetData(_cW_, "n", _nN_)  _oS_.SetData(_cW_, "d", _nD_)
			_oS_.SetData(_cW_, "x0", _nX0_)  _oS_.SetData(_cW_, "x1", _nX1_)
			_oS_.SetData(_cW_, "x", (_nX0_ + _nX1_) / 2)  _oS_.SetData(_cW_, "y", _nY_)
			_oS_.SetData(_cW_, "w", _nX1_ - _nX0_)  _oS_.SetData(_cW_, "hh", StzFractionFigureBarHeight())
			_oS_.SetData(_cW_, "r", 0)
			_oS_.SetData(_cW_, "nx", _nX0_ - 16 - _FfTextWidth(poFont, "" + _nN_ + "/" + _nD_, StzFractionFigureTypeSize() + 4) / 2)
			_oS_.SetData(_cW_, "ny", _nY_)
			_nPw_ = (_nX1_ - _nX0_) / _nD_
			for _k_ = 1 to _nD_
				_cP_ = _FrPartName(_w_, _k_, _k_ <= _nN_)
				_oS_.Declare("Part", _cP_)
				_oS_.Label(_cP_, "")
				_oS_.SetData(_cP_, "whole", _w_)
				_oS_.SetData(_cP_, "k", _k_)
				_oS_.SetData(_cP_, "x", _nX0_ + (_k_ - 0.5) * _nPw_)
				_oS_.SetData(_cP_, "y", _nY_)
				_oS_.SetData(_cP_, "w", _nPw_)
				_oS_.SetData(_cP_, "hh", StzFractionFigureBarHeight())
				_oS_.SetData(_cP_, "angle", 0)
				if _k_ <= _nN_  _oS_.Assert("Shaded", [ _cP_ ])  ok
			next
			_oS_.Define("nm" + _w_, "Note", [ _cW_ ])
			_oS_.Label("nm" + _w_, "" + _nN_ + "/" + _nD_)
		next
		# the verdicts, between consecutive bars: cross-multiplied, exactly
		for _w_ = 1 to _nW_ - 1
			_cV_ = "v" + _w_
			_oS_.Define(_cV_, "Verdict", [ "w" + _w_, "w" + (_w_ + 1) ])
			_oS_.Label(_cV_, _FrCompare(_aF_[_w_], _aF_[_w_ + 1]))
			_oS_.SetData(_cV_, "x", _nX1_ + 34)
			_oS_.SetData(_cV_, "y", _nTop_ + (_w_ - 0.5) * StzFractionFigureBarPitch() + StzFractionFigureBarHeight() / 2 + 10)
		next
	else
		_nR_ = StzFractionFigureDiscRadius()
		_nH_ = _nTop_ + 2 * _nR_ + 70
		_nGap_ = (StzFractionFigureWidth() - _nW_ * 2 * _nR_) / (_nW_ + 1)
		for _w_ = 1 to _nW_
			_nN_ = _aF_[_w_][1]
			_nD_ = _aF_[_w_][2]
			_cW_ = "w" + _w_
			_nCx_ = _nGap_ + _nR_ + (_w_ - 1) * (2 * _nR_ + _nGap_)
			_nCy_ = _nTop_ + _nR_ + 10
			_oS_.Declare("Whole", _cW_)
			_oS_.Label(_cW_, "")
			_oS_.Assert("Disc", [ _cW_ ])
			_oS_.SetData(_cW_, "n", _nN_)  _oS_.SetData(_cW_, "d", _nD_)
			_oS_.SetData(_cW_, "x", _nCx_)  _oS_.SetData(_cW_, "y", _nCy_)
			_oS_.SetData(_cW_, "x0", _nCx_ - _nR_)  _oS_.SetData(_cW_, "x1", _nCx_ + _nR_)
			_oS_.SetData(_cW_, "w", 2 * _nR_)  _oS_.SetData(_cW_, "hh", 2 * _nR_)
			_oS_.SetData(_cW_, "r", _nR_)
			_oS_.SetData(_cW_, "nx", _nCx_)
			_oS_.SetData(_cW_, "ny", _nCy_ + _nR_ + 30)
			# a wedge is a polygon: the centre, then the arc sampled so
			# that the whole disc has about 22 points on its rim
			_nA_ = 2 * 3.14159265358979 / _nD_
			for _k_ = 1 to _nD_
				_cP_ = _FrPartName(_w_, _k_, _k_ <= _nN_)
				_oS_.Declare("Part", _cP_)
				_oS_.Label(_cP_, "")
				_oS_.Assert("Wedge", [ _cP_ ])
				_oS_.SetData(_cP_, "whole", _w_)
				_oS_.SetData(_cP_, "k", _k_)
				_oS_.SetData(_cP_, "angle", _nA_)
				_oS_.SetData(_cP_, "w", 0)  _oS_.SetData(_cP_, "hh", 0)
				_oS_.SetData(_cP_, "x", _nCx_)  _oS_.SetData(_cP_, "y", _nCy_)
				# every wedge takes the polygon's full rim of 23 points: with a
				# share of 22 spread over the disc, an eighth had four, its
				# chords fell a pixel short of the circle, and the whole's
				# stroke showed through as a dotted ring
				_nArc_ = 23
				_t0_ = -3.14159265358979 / 2 + (_k_ - 1) * _nA_
				_oS_.SetData(_cP_, "pts", _nArc_ + 1)
				_oS_.Assert("Pts" + (_nArc_ + 1), [ _cP_ ])
				_oS_.SetData(_cP_, "x1", _nCx_)  _oS_.SetData(_cP_, "y1", _nCy_)
				for _q_ = 0 to _nArc_ - 1
					_t_ = _t0_ + _nA_ * _q_ / (_nArc_ - 1)
					_oS_.SetData(_cP_, "x" + (_q_ + 2), _nCx_ + _nR_ * cos(_t_))
					_oS_.SetData(_cP_, "y" + (_q_ + 2), _nCy_ + _nR_ * sin(_t_))
				next
				if _k_ <= _nN_  _oS_.Assert("Shaded", [ _cP_ ])  ok
			next
			_oS_.Define("nm" + _w_, "Note", [ _cW_ ])
			_oS_.Label("nm" + _w_, "" + _nN_ + "/" + _nD_)
		next
		for _w_ = 1 to _nW_ - 1
			_cV_ = "v" + _w_
			_oS_.Define(_cV_, "Verdict", [ "w" + _w_, "w" + (_w_ + 1) ])
			_oS_.Label(_cV_, _FrCompare(_aF_[_w_], _aF_[_w_ + 1]))
			_oS_.SetData(_cV_, "x", _nGap_ + 2 * _nR_ + _nGap_ / 2 + (_w_ - 1) * (2 * _nR_ + _nGap_))
			_oS_.SetData(_cV_, "y", _nTop_ + _nR_ + 10)
		next
	ok
	_oS_.SetData("fig", "h", _nH_)
	_oS_.SetData("fig", "isbar", (_d_[:as] = "bar"))
	return _oS_

# the shaded parts are named s<whole>_<k>, the others u<whole>_<k>, so a
# consumer -- and a child -- can COUNT them by their ids
func _FrPartName(pnW, pnK, pbShaded)
	if pbShaded  return "s" + pnW + "_" + pnK  ok
	return "u" + pnW + "_" + pnK

# ">" "<" or "=" between two fractions, by cross-multiplication on integers
func _FrCompare(paA, paB)
	_nL_ = paA[1] * paB[2]
	_nR_ = paB[1] * paA[2]
	if _nL_ > _nR_  return ">"  ok
	if _nL_ < _nR_  return "<"  ok
	return "="

func StzFractionFigureWhy(poSubstance)
	_nW_ = poSubstance.DataOf("fig", "wholes")
	_c_ = "a fraction figure of " + _nW_ + " whole(s)"
	if poSubstance.DataOf("fig", "isbar") = 1  _c_ += " as bars"  else  _c_ += " as discs"  ok
	_c_ += ": "
	for _w_ = 1 to _nW_
		if _w_ > 1  _c_ += ", "  ok
		_c_ += "" + poSubstance.DataOf("w" + _w_, "n") + " of " + poSubstance.DataOf("w" + _w_, "d") + " shaded"
	next
	return _c_

#-- the declaration, read and refused by name -------------------------

func _FrDeclaration(paSpec)
	if NOT isList(paSpec) or len(paSpec) = 0
		stzraise("StzFractionFigure: a fraction is declared as keys, like [ :of = [ 3, 4 ] ].")
	ok
	_acKeys_ = StzFractionFigureKeys()
	for _i_ = 1 to len(paSpec)
		_e_ = paSpec[_i_]
		if NOT isList(_e_) or len(_e_) != 2 or NOT isString(_e_[1])
			stzraise("StzFractionFigure: entry " + _i_ + " of the declaration is not a key and a value.")
		ok
		if NOT _FfIn(_acKeys_, StzLower(_e_[1]))
			stzraise("StzFractionFigure: ':" + _e_[1] + "' is not a key of a fraction figure -- " +
				"the keys are " + @@(_acKeys_) + ".")
		ok
	next
	_d_ = [ :fractions = [], :as = "bar", :label = "" ]
	_aOf_ = _FfGet(paSpec, "of", [])
	_aCmp_ = _FfGet(paSpec, "compare", [])
	if isList(_aOf_) and len(_aOf_) > 0 and isList(_aCmp_) and len(_aCmp_) > 0
		stzraise("StzFractionFigure: :of and :compare cannot both be given -- one fraction, or several.")
	ok
	if isList(_aOf_) and len(_aOf_) > 0
		_d_[:fractions] + _FrFraction(_aOf_, 1)
	but isList(_aCmp_) and len(_aCmp_) > 0
		if len(_aCmp_) > 5
			stzraise("StzFractionFigure: at most five fractions compare on one paper.")
		ok
		for _i_ = 1 to len(_aCmp_)
			_d_[:fractions] + _FrFraction(_aCmp_[_i_], _i_)
		next
	else
		stzraise("StzFractionFigure: say which fraction -- :of = [ 3, 4 ] -- or which to compare.")
	ok
	_cAs_ = _FfGet(paSpec, "as", "bar")
	_cAs_ = StzLower(ring_trim("" + _cAs_))
	if _cAs_ != "bar" and _cAs_ != "disc"
		stzraise("StzFractionFigure: :as is :bar or :disc.")
	ok
	_d_[:as] = _cAs_
	_cL_ = _FfGet(paSpec, "label", "")
	if NOT isString(_cL_)
		stzraise("StzFractionFigure: :label is text.")
	ok
	_d_[:label] = _cL_
	return _d_

func _FrFraction(paF, pnAt)
	if NOT isList(paF) or len(paF) != 2 or NOT isNumber(paF[1]) or NOT isNumber(paF[2])
		stzraise("StzFractionFigure: fraction " + pnAt + " is [ numerator, denominator ], two whole numbers.")
	ok
	_nN_ = paF[1]
	_nD_ = paF[2]
	if _nN_ != floor(_nN_) or _nD_ != floor(_nD_)
		stzraise("StzFractionFigure: " + _FfNum(_nN_, 6) + "/" + _FfNum(_nD_, 6) +
			" -- a fraction is made of whole numbers.")
	ok
	if _nD_ < 1
		stzraise("StzFractionFigure: a denominator of " + _nD_ + " cuts a whole into no parts.")
	ok
	if _nD_ > StzFractionFigureMaxDenominator()
		stzraise("StzFractionFigure: " + _nD_ + " parts cannot be counted by eye -- the most is " +
			StzFractionFigureMaxDenominator() + ".")
	ok
	if _nN_ < 0
		stzraise("StzFractionFigure: a numerator of " + _nN_ + " shades fewer than no parts.")
	ok
	if _nN_ > _nD_
		stzraise("StzFractionFigure: " + "" + _nN_ + "/" + _nD_ + " is more than one whole, and this figure " +
			"draws one -- an improper fraction is a later slice.")
	ok
	return [ _nN_, _nD_ ]

#---------------------------------------------------------------------#
#  THE STYLE -- every position a datum                                 #
#---------------------------------------------------------------------#

func StzFractionStyle()
	return StzFractionStyleXT(300)

func StzFractionStyleXT(pnHeight)
	_o_ = new stzMathStyle()
	_o_.SetCanvas(StzFractionFigureWidth(), pnHeight)
	_o_.SetMargin(4)
	_nT_ = StzFractionFigureTypeSize()
	# the figure's title
	_o_.ForAll("Figure g", [
		[ :shape, "g.text", :text, [ :cx = "g.tx", :cy = "g.ty", :size = StzFractionFigureTitleSize(),
		                             :fill = [ :on, "paper" ] ] ] ])
	# A BAR: a faint field with a stroke; its name to its left
	_o_.ForAll("Whole w", [
		[ :shape, "w.box", :rect, [ :cx = "w.x", :cy = "w.y", :w = "w.w", :h = "w.hh",
		                            :fill = [ :alpha, "primary", 0.06 ], :stroke = "neutral", :strokeWidth = 1.5 ] ] ])
	_o_.ForAllWhere("Whole w", "Disc(w)", [
		[ :delete, "w.box" ],
		[ :shape, "w.box", :circle, [ :cx = "w.x", :cy = "w.y", :r = "w.r",
		                              :fill = [ :alpha, "primary", 0.06 ], :stroke = "neutral", :strokeWidth = 1.5 ] ] ])
	# A PART of a bar: a rect, shaded or nearly clear, edged in the paper's colour
	_o_.ForAll("Part p", [
		[ :shape, "p.icon", :rect, [ :cx = "p.x", :cy = "p.y", :w = "p.w", :h = "p.hh",
		                             :fill = [ :alpha, "primary", 0.10 ], :stroke = "background", :strokeWidth = 2 ] ] ])
	_o_.ForAllWhere("Part p", "Shaded(p)", [
		[ :delete, "p.icon" ],
		[ :shape, "p.icon", :rect, [ :cx = "p.x", :cy = "p.y", :w = "p.w", :h = "p.hh",
		                             :fill = "primary", :stroke = "background", :strokeWidth = 2 ] ] ])
	# A WEDGE of a disc: a polygon from the centre round the arc
	# (a + on a Ring list appends IN PLACE, so each property list is copied
	# by assignment before it grows)
	for _n_ = 3 to 24
		_aP_ = [ :n = _n_ ]
		for _v_ = 1 to _n_
			_aP_ + [ "x" + _v_, "p.x" + _v_ ]
			_aP_ + [ "y" + _v_, "p.y" + _v_ ]
		next
		_aC_ = _aP_
		_aC_ + [ "fill", [ :alpha, "primary", 0.10 ] ]
		_aC_ + [ "stroke", "background" ]
		_aC_ + [ "strokeWidth", 2 ]
		_aS_ = _aP_
		_aS_ + [ "fill", "primary" ]
		_aS_ + [ "stroke", "background" ]
		_aS_ + [ "strokeWidth", 2 ]
		_o_.ForAllWhere("Part p", "Wedge(p); Pts" + _n_ + "(p)", [
			[ :delete, "p.icon" ],
			[ :shape, "p.icon", :poly, _aC_ ] ])
		_o_.ForAllWhere("Part p", "Wedge(p); Pts" + _n_ + "(p); Shaded(p)", [
			[ :delete, "p.icon" ],
			[ :shape, "p.icon", :poly, _aS_ ] ])
	next
	# the name of a whole, and the verdict between two
	_o_.ForAllWhere("Note n; Whole w", "n := Note(w)", [
		[ :shape, "n.text", :text, [ :cx = "w.nx", :cy = "w.ny", :size = _nT_ + 4, :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAllWhere("Verdict v; Whole a; Whole b", "v := Verdict(a, b)", [
		[ :shape, "v.text", :text, [ :cx = "v.x", :cy = "v.y", :size = _nT_ + 6, :fill = "info" ] ] ])
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE                                        #
#---------------------------------------------------------------------#

func _FrIsFraction(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "fraction"

func _FrScope(poDg, pcPrefix)
	_r_ = []
	if NOT _FrIsFraction(poDg)  return _r_  ok
	_ac_ = poDg.Substance().ObjectsOfType("Whole")
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _FrCounter(poDg, pcPrefix)
	_r_ = []
	if NOT isObject(poDg) or _FrIsFraction(poDg)  return _r_  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return _r_  ok
	_ac_ = poDg.Substance().ObjectNames()
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _FrPartsOf(poSubstance, pcWhole)
	_nW_ = 0
	for _i_ = 2 to len(pcWhole)
		_nW_ = _nW_ * 10 + (ascii(pcWhole[_i_]) - 48)
	next
	_a_ = []
	_ac_ = poSubstance.ObjectsOfType("Part")
	for _i_ = 1 to len(_ac_)
		if poSubstance.DataOf(_ac_[_i_], "whole") = _nW_  _a_ + _ac_[_i_]  ok
	next
	return _a_

func StzFractionRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("shaded_is_the_numerator")
	_o1_.SetClaim("a whole's shaded parts number its numerator")
	_o1_.SetOrder(76)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _FrScope(oDg, "whole:") })
	_o1_.SetCounter(func(oDg) { return _FrCounter(oDg, "whole:") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cW_ = StzStringSection(cSub, 7, len(cSub))
		_oS_ = oDg.Substance()
		_ac_ = _FrPartsOf(_oS_, _cW_)
		_n_ = 0
		for _i_ = 1 to len(_ac_)
			if _oS_.Holds("Shaded", [ _ac_[_i_] ])  _n_++  ok
		next
		if _n_ != _oS_.DataOf(_cW_, "n")
			return [ FALSE, "'" + _oS_.DataOf(_cW_, "n") + "/" + _oS_.DataOf(_cW_, "d") + "' shades " +
				_n_ + " part(s), not " + _oS_.DataOf(_cW_, "n") ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("parts_are_the_denominator")
	_o2_.SetClaim("a whole's parts number its denominator")
	_o2_.SetOrder(77)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) { return _FrScope(oDg, "whole:") })
	_o2_.SetCounter(func(oDg) { return _FrCounter(oDg, "whole:") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cW_ = StzStringSection(cSub, 7, len(cSub))
		_oS_ = oDg.Substance()
		_n_ = len(_FrPartsOf(_oS_, _cW_))
		if _n_ != _oS_.DataOf(_cW_, "d")
			return [ FALSE, "'" + _oS_.DataOf(_cW_, "n") + "/" + _oS_.DataOf(_cW_, "d") + "' is cut into " +
				_n_ + " part(s), not " + _oS_.DataOf(_cW_, "d") ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	_o3_ = StzPlasticRule("parts_tile_the_whole")
	_o3_.SetClaim("a bar's parts add up to its width, a disc's to a full turn")
	_o3_.SetOrder(78)
	_o3_.SetReads([ "substance" ])
	_o3_.SetScope(func(oDg) { return _FrScope(oDg, "whole:") })
	_o3_.SetCounter(func(oDg) { return _FrCounter(oDg, "whole:") })
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cW_ = StzStringSection(cSub, 7, len(cSub))
		_oS_ = oDg.Substance()
		_ac_ = _FrPartsOf(_oS_, _cW_)
		_nSum_ = 0
		if _oS_.Holds("Disc", [ _cW_ ])
			for _i_ = 1 to len(_ac_)  _nSum_ += _oS_.DataOf(_ac_[_i_], "angle")  next
			if fabs(_nSum_ - 2 * 3.14159265358979) > 0.000001
				return [ FALSE, "the wedges of '" + _oS_.DataOf(_cW_, "n") + "/" + _oS_.DataOf(_cW_, "d") +
					"' turn " + _FfNum(_nSum_, 4) + " radians, not a full turn" ]
			ok
		else
			for _i_ = 1 to len(_ac_)  _nSum_ += _oS_.DataOf(_ac_[_i_], "w")  next
			if fabs(_nSum_ - _oS_.DataOf(_cW_, "w")) > 0.001
				return [ FALSE, "the parts of '" + _oS_.DataOf(_cW_, "n") + "/" + _oS_.DataOf(_cW_, "d") +
					"' add up to " + _FfNum(_nSum_, 2) + " px, not the bar's " + _FfNum(_oS_.DataOf(_cW_, "w"), 2) ]
			ok
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o3_

	return _ao_
