#=====================================================================#
#  STZSURFACEFIGURE -- M1d: z = f(x, y) is a FIGURE, projected by the  #
#  engine and drawn on the vector tier                                 #
#=====================================================================#
/*
	THE SEVENTH VISUAL DOOR (base/math/CHARTER.md). The plot engine's
	"surface" is a treemap; this is a surface: z = f(x, y) sampled on a
	grid by the engine's tape, PROJECTED by the engine's own camera
	matrices (the four Mat4 bridges stzScene.Project uses, which need no
	device), and drawn as a wireframe on the canvas -- rows and columns
	as polylines coloured by their height on one ramp, inside the box
	that frames the space. It has a vector rendition, so it is byte-tested
	and shown without a GPU; the true mesh on a device is M2's window.

	WHAT A SURFACE IS HERE:

	    DOMAIN     Frame, the paper and the box's twelve edges; Line, one
	               row or one column of the grid, as a polyline of n
	               points; Corner, a text at a corner of the box naming
	               an axis or an end value. Row(Line) or Column(Line);
	               PtsN(Line) for the polygon rule written for n.

	    SUBSTANCE  built from a declaration:
	                 [ :f = "sin(x) * cos(y)", :x = [ -3, 3 ], :y = [ -3, 3 ],
	                   :samples = 24, :view = [ -50, 30 ], :label = "..." ]
	               :samples per axis (8..48); :view is azimuth and elevation
	               in degrees. Every sample's z is a datum of the frame,
	               so a rule can hold the drawing to the function.

	    STYLE      the box's edges muted; each line a spline through its
	               samples with no interpolation, coloured on a ramp from
	               muted to primary by its mean height; the corner texts.

	WHAT THE DOMAIN OWES THE GATE:

	    sample_is_the_function   five samples -- the corners and the
	                             centre -- re-evaluated from the expression
	                             agree with the frame's data
	    grid_is_complete         2n lines of n points each

	WHAT IS SAID PLAINLY: a surface that is not finite somewhere on its
	grid is refused with the place -- a wireframe with a hole is a later
	slice; no hidden-line removal; the space is a unit cube in scale, so
	the picture's proportions are the box's, never the function's.
*/

StzRegisterMathRuleSet("surface", StzSurfaceRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzSurfaceDomain()
	return StzSurfaceDomainXT(24)

func StzSurfaceDomainXT(pnN)
	_o_ = new stzMathDomain("surface")
	_o_.AddType("Frame")
	_o_.AddType("Line")
	_o_.AddType("Corner")
	_o_.AddType("Function")
	_o_.AddPredicate("Row", [ "Line" ])
	_o_.AddPredicate("Column", [ "Line" ])
	_o_.AddPredicate("Pts" + pnN, [ "Line" ])
	return _o_

func StzSurfaceFigureWidth()
	return 900

func StzSurfaceFigureHeight()
	return 640

func StzSurfaceFigureTypeSize()
	return 15

func StzSurfaceFigureTitleSize()
	return 20

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM A DECLARATION                                   #
#---------------------------------------------------------------------#

func StzSurfaceFigureKeys()
	return [ "f", "x", "y", "samples", "view", "label" ]

func StzSurfaceFigureFrom(paSpec)
	return StzSurfaceFigureFromXT(NULL, paSpec)

func StzSurfaceFigureBuildXT(poFont, paSpec)
	_oS_ = StzSurfaceFigureFromXT(poFont, paSpec)
	_o_ = new stzMathDiagram(_oS_.DomainQ(), _oS_, StzSurfaceStyleXT(_oS_.DataOf("fr", "n")))
	if isObject(poFont)  _o_.SetFont(poFont, StzSurfaceFigureTypeSize())  ok
	_o_.SetVariation("surface")
	return _o_

func StzSurfaceFigureFromXT(poFont, paSpec)
	_d_ = _SfDeclaration(paSpec)
	_nN_ = _d_[:samples]
	_nA_ = _d_[:x][1]  _nB_ = _d_[:x][2]
	_nC_ = _d_[:y][1]  _nD_ = _d_[:y][2]

	# THE COMPUTED HALF: z on the grid, from the engine's tape
	_oF_ = new stzMathFunction(_d_[:f], [ "x", "y" ])
	_aZ_ = []
	_nZmin_ = 0  _nZmax_ = 0  _bAny_ = FALSE
	for _i_ = 1 to _nN_
		_row_ = []
		_x_ = _nA_ + (_nB_ - _nA_) * (_i_ - 1) / (_nN_ - 1)
		for _j_ = 1 to _nN_
			_y_ = _nC_ + (_nD_ - _nC_) * (_j_ - 1) / (_nN_ - 1)
			_z_ = _oF_.ValueAt([ _x_, _y_ ])
			if NOT _FfFinite(_z_)
				_oF_.Free()
				stzraise("StzSurfaceFigure: '" + _d_[:f] + "' is not finite at (" + _FfNum(_x_, 4) + ", " +
					_FfNum(_y_, 4) + ") -- a surface with a hole is a later slice.")
			ok
			_row_ + _z_
			if NOT _bAny_  _nZmin_ = _z_  _nZmax_ = _z_  _bAny_ = TRUE  ok
			if _z_ < _nZmin_  _nZmin_ = _z_  ok
			if _z_ > _nZmax_  _nZmax_ = _z_  ok
		next
		_aZ_ + _row_
	next
	_oF_.Free()
	_nZr_ = _nZmax_ - _nZmin_
	if _nZr_ < 0.000000001  _nZr_ = 1  ok

	# THE PROJECTION: the space as a unit cube, seen by the engine's camera
	_nAz_ = _d_[:view][1] * 3.14159265358979 / 180
	_nEl_ = _d_[:view][2] * 3.14159265358979 / 180
	_nDist_ = 3.0
	_aEye_ = [ _nDist_ * cos(_nEl_) * sin(_nAz_), _nDist_ * sin(_nEl_), _nDist_ * cos(_nEl_) * cos(_nAz_) ]
	# the projection box stops 90 px above the paper's bottom and the eye
	# looks a little below the cube's centre, so the names under the cube
	# land on the paper (at the bottom edge they ran 6 px off it)
	_nL_ = 40  _nT_ = 60
	_nPw_ = StzSurfaceFigureWidth() - 80
	_nPh_ = StzSurfaceFigureHeight() - _nT_ - 90
	_aV_ = StzEngineGpuMat4LookAt(_aEye_[1], _aEye_[2], _aEye_[3], 0, -0.06, 0, 0, 1, 0)
	_aP_ = StzEngineGpuMat4Perspective(30, _nPw_ / _nPh_, 0.1, 100)
	_aVP_ = StzEngineGpuMat4Mul(_aP_, _aV_)

	_oS_ = new stzMathSubstance(StzSurfaceDomainXT(_nN_))
	_oS_.Declare("Frame", "fr")
	_oS_.Label("fr", _d_[:label])
	_oS_.SetData("fr", "n", _nN_)
	_oS_.SetData("fr", "xa", _nA_)  _oS_.SetData("fr", "xb", _nB_)
	_oS_.SetData("fr", "ya", _nC_)  _oS_.SetData("fr", "yb", _nD_)
	_oS_.SetData("fr", "zmin", _nZmin_)  _oS_.SetData("fr", "zmax", _nZmax_)
	_oS_.SetData("fr", "az", _d_[:view][1])  _oS_.SetData("fr", "el", _d_[:view][2])
	_oS_.SetData("fr", "tx", 30 + _FfTextWidth(poFont, _d_[:label], StzSurfaceFigureTitleSize()) / 2)
	_oS_.SetData("fr", "ty", 30)
	_oS_.Declare("Function", "fn")
	_oS_.Label("fn", _d_[:f])
	# every z a datum of the frame, for the rule that re-evaluates it
	for _i_ = 1 to _nN_
		for _j_ = 1 to _nN_
			_oS_.SetData("fr", "z" + _i_ + "_" + _j_, _aZ_[_i_][_j_])
		next
	next

	# the box's twelve edges, projected
	_aCorners_ = [ [ -0.5, -0.3, -0.5 ], [ 0.5, -0.3, -0.5 ], [ 0.5, -0.3, 0.5 ], [ -0.5, -0.3, 0.5 ],
	               [ -0.5, 0.3, -0.5 ], [ 0.5, 0.3, -0.5 ], [ 0.5, 0.3, 0.5 ], [ -0.5, 0.3, 0.5 ] ]
	_aEdges_ = [ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 1 ], [ 5, 6 ], [ 6, 7 ], [ 7, 8 ], [ 8, 5 ],
	             [ 1, 5 ], [ 2, 6 ], [ 3, 7 ], [ 4, 8 ] ]
	_aPc_ = []
	for _k_ = 1 to 8
		_aPc_ + _SfProject(_aVP_, _aCorners_[_k_], _nL_, _nT_, _nPw_, _nPh_)
	next
	for _k_ = 1 to 12
		_oS_.SetData("fr", "e" + _k_ + "x1", _aPc_[_aEdges_[_k_][1]][1])
		_oS_.SetData("fr", "e" + _k_ + "y1", _aPc_[_aEdges_[_k_][1]][2])
		_oS_.SetData("fr", "e" + _k_ + "x2", _aPc_[_aEdges_[_k_][2]][1])
		_oS_.SetData("fr", "e" + _k_ + "y2", _aPc_[_aEdges_[_k_][2]][2])
	next

	# the corner texts: the axis names and their end values
	# the corner texts, below the cube's bottom face where neither an edge
	# nor the wire can reach them (beside the edges they sat on the edges)
	# WHICH EDGES ARE NEAR depends on where the eye is: the x names go
	# under the bottom edge on the eye's side in z, the y names under the
	# bottom edge on the eye's side in x, the z names up the vertical edge
	# on the eye's side in x and away from it in z -- under the FAR edge
	# they projected inside the cube, behind the wire
	_nSx_ = 1
	if _aEye_[1] < 0  _nSx_ = -1  ok
	_nSz_ = 1
	if _aEye_[3] < 0  _nSz_ = -1  ok
	_aTx_ = [ [ "x", [ 0, -0.52, _nSz_ * 0.5 ] ], [ _FfNum(_nA_, 4), [ -0.42, -0.52, _nSz_ * 0.5 ] ], [ _FfNum(_nB_, 4), [ 0.42, -0.52, _nSz_ * 0.5 ] ],
	          [ "y", [ _nSx_ * 0.5, -0.52, 0 ] ], [ _FfNum(_nC_, 4), [ _nSx_ * 0.5, -0.52, -0.42 ] ], [ _FfNum(_nD_, 4), [ _nSx_ * 0.5, -0.52, 0.42 ] ],
	          [ "z", [ _nSx_ * 0.74, 0, -_nSz_ * 0.5 ] ], [ _FfNum(_nZmin_, 4), [ _nSx_ * 0.74, -0.26, -_nSz_ * 0.5 ] ], [ _FfNum(_nZmax_, 4), [ _nSx_ * 0.74, 0.3, -_nSz_ * 0.5 ] ] ]
	for _k_ = 1 to len(_aTx_)
		_p_ = _SfProject(_aVP_, _aTx_[_k_][2], _nL_, _nT_, _nPw_, _nPh_)
		_oS_.Declare("Corner", "k" + _k_)
		_oS_.Label("k" + _k_, _aTx_[_k_][1])
		_oS_.SetData("k" + _k_, "x", _p_[1])  _oS_.SetData("k" + _k_, "y", _p_[2])
	next

	# the lines: n rows and n columns, each a polyline of n projected points
	_nLines_ = 0
	for _i_ = 1 to _nN_
		_nLines_++
		_cL_ = "r" + _i_
		_oS_.Declare("Line", _cL_)
		_oS_.Label(_cL_, "")
		_oS_.Assert("Row", [ _cL_ ])
		_oS_.Assert("Pts" + _nN_, [ _cL_ ])
		_nSum_ = 0
		for _j_ = 1 to _nN_
			_p_ = _SfProject(_aVP_, _SfCube(_i_, _j_, _aZ_[_i_][_j_], _nN_, _nZmin_, _nZr_), _nL_, _nT_, _nPw_, _nPh_)
			_oS_.SetData(_cL_, "x" + _j_, _p_[1])
			_oS_.SetData(_cL_, "y" + _j_, _p_[2])
			_nSum_ += (_aZ_[_i_][_j_] - _nZmin_) / _nZr_
		next
		_oS_.SetData(_cL_, "t", _nSum_ / _nN_)
		_oS_.SetData(_cL_, "at", _i_)
	next
	for _j_ = 1 to _nN_
		_nLines_++
		_cL_ = "c" + _j_
		_oS_.Declare("Line", _cL_)
		_oS_.Label(_cL_, "")
		_oS_.Assert("Column", [ _cL_ ])
		_oS_.Assert("Pts" + _nN_, [ _cL_ ])
		_nSum_ = 0
		for _i_ = 1 to _nN_
			_p_ = _SfProject(_aVP_, _SfCube(_i_, _j_, _aZ_[_i_][_j_], _nN_, _nZmin_, _nZr_), _nL_, _nT_, _nPw_, _nPh_)
			_oS_.SetData(_cL_, "x" + _i_, _p_[1])
			_oS_.SetData(_cL_, "y" + _i_, _p_[2])
			_nSum_ += (_aZ_[_i_][_j_] - _nZmin_) / _nZr_
		next
		_oS_.SetData(_cL_, "t", _nSum_ / _nN_)
		_oS_.SetData(_cL_, "at", _j_)
	next
	_oS_.SetData("fr", "lines", _nLines_)
	return _oS_

# a grid sample as a point of the unit cube: x and y across [-0.5, 0.5],
# z up across [-0.3, 0.3] -- the scene's up is the second coordinate
func _SfCube(pnI, pnJ, pnZ, pnN, pnZmin, pnZr)
	return [ -0.5 + (pnI - 1) / (pnN - 1), -0.3 + 0.6 * (pnZ - pnZmin) / pnZr, -0.5 + (pnJ - 1) / (pnN - 1) ]

# a point of the cube on the paper, through the engine's projection
func _SfProject(paVP, paP, pnL, pnT, pnW, pnH)
	_a_ = StzEngineGpuMat4Project(paVP, paP[1], paP[2], paP[3], pnW, pnH)
	return [ pnL + _a_[1], pnT + _a_[2] ]

func StzSurfaceFigureWhy(poSubstance)
	_n_ = poSubstance.DataOf("fr", "n")
	return "a surface z = " + poSubstance.LabelOf("fn") + ": " + _n_ + " x " + _n_ + " samples, z in [" +
		_FfNum(poSubstance.DataOf("fr", "zmin"), 4) + ", " + _FfNum(poSubstance.DataOf("fr", "zmax"), 4) +
		"], seen from azimuth " + _FfNum(poSubstance.DataOf("fr", "az"), 1) + " and elevation " +
		_FfNum(poSubstance.DataOf("fr", "el"), 1) + " degrees"

#-- the declaration, read and refused by name -------------------------

func _SfDeclaration(paSpec)
	if NOT isList(paSpec) or len(paSpec) = 0
		stzraise("StzSurfaceFigure: a surface is declared as keys, like [ :f = 'x^2 - y^2', :x = [ -1, 1 ], :y = [ -1, 1 ] ].")
	ok
	_acKeys_ = StzSurfaceFigureKeys()
	for _i_ = 1 to len(paSpec)
		_e_ = paSpec[_i_]
		if NOT isList(_e_) or len(_e_) != 2 or NOT isString(_e_[1])
			stzraise("StzSurfaceFigure: entry " + _i_ + " of the declaration is not a key and a value.")
		ok
		if NOT _FfIn(_acKeys_, StzLower(_e_[1]))
			stzraise("StzSurfaceFigure: ':" + _e_[1] + "' is not a key of a surface -- the keys are " + @@(_acKeys_) + ".")
		ok
	next
	_d_ = [ :f = "", :x = [], :y = [], :samples = 24, :view = [ -50, 30 ], :label = "" ]
	_cF_ = _FfGet(paSpec, "f", "")
	if NOT isString(_cF_) or ring_trim(_cF_) = ""
		stzraise("StzSurfaceFigure: say the function, :f = 'sin(x) * cos(y)'.")
	ok
	_d_[:f] = _cF_
	for _k_ in [ "x", "y" ]
		_aR_ = _FfGet(paSpec, _k_, [])
		if NOT isList(_aR_) or len(_aR_) != 2 or NOT isNumber(_aR_[1]) or NOT isNumber(_aR_[2])
			stzraise("StzSurfaceFigure: :" + _k_ + " is the range [ a, b ] of " + _k_ + ".")
		ok
		if _aR_[2] <= _aR_[1]
			stzraise("StzSurfaceFigure: the range of " + _k_ + " runs backwards.")
		ok
		_d_[_k_] = _aR_
	next
	_nS_ = _FfGet(paSpec, "samples", 24)
	if NOT isNumber(_nS_) or _nS_ != floor(_nS_) or _nS_ < 8 or _nS_ > 48
		stzraise("StzSurfaceFigure: :samples is a whole number from 8 to 48, per axis.")
	ok
	_d_[:samples] = _nS_
	_aV_ = _FfGet(paSpec, "view", [ -50, 30 ])
	if NOT isList(_aV_) or len(_aV_) != 2 or NOT isNumber(_aV_[1]) or NOT isNumber(_aV_[2])
		stzraise("StzSurfaceFigure: :view is [ azimuth, elevation ] in degrees.")
	ok
	if _aV_[2] <= 0 or _aV_[2] >= 90
		stzraise("StzSurfaceFigure: the elevation is between 0 and 90 degrees, exclusive -- from above the plane, not on it.")
	ok
	_d_[:view] = _aV_
	_cL_ = _FfGet(paSpec, "label", "")
	if NOT isString(_cL_)
		stzraise("StzSurfaceFigure: :label is text.")
	ok
	_d_[:label] = _cL_
	return _d_

#---------------------------------------------------------------------#
#  THE STYLE -- every position a datum                                 #
#---------------------------------------------------------------------#

func StzSurfaceStyle()
	return StzSurfaceStyleXT(24)

func StzSurfaceStyleXT(pnN)
	_o_ = new stzMathStyle()
	_o_.SetCanvas(StzSurfaceFigureWidth(), StzSurfaceFigureHeight())
	_o_.SetMargin(4)
	_nT_ = StzSurfaceFigureTypeSize()
	_aRows_ = [ [ :shape, "f.text", :text, [ :cx = "f.tx", :cy = "f.ty", :size = StzSurfaceFigureTitleSize(),
	                                          :fill = [ :on, "paper" ] ] ] ]
	for _k_ = 1 to 12
		_aRows_ + [ :shape, "f.e" + _k_, :line, [ :x1 = "f.e" + _k_ + "x1", :y1 = "f.e" + _k_ + "y1",
		                                          :x2 = "f.e" + _k_ + "x2", :y2 = "f.e" + _k_ + "y2",
		                                          :stroke = [ :alpha, "muted", 0.7 ], :strokeWidth = 1 ] ]
	next
	_o_.ForAll("Frame f", _aRows_)
	_o_.ForAll("Corner k", [
		[ :shape, "k.text", :text, [ :cx = "k.x", :cy = "k.y", :size = _nT_, :fill = "muted" ] ] ])
	_aP_ = [ :n = pnN, :samples = 1, :stroke = [ :ramp, "l.t", 0, 1, "muted", "primary" ], :strokeWidth = 1.4 ]
	for _v_ = 1 to pnN
		_aP_ + [ "x" + _v_, "l.x" + _v_ ]
		_aP_ + [ "y" + _v_, "l.y" + _v_ ]
	next
	_o_.ForAllWhere("Line l", "Pts" + pnN + "(l)", [
		[ :shape, "l.icon", :spline, _aP_ ] ])
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE                                        #
#---------------------------------------------------------------------#

func _SfIsSurface(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "surface"

func _SfCounter(poDg, pcPrefix)
	_r_ = []
	if NOT isObject(poDg) or _SfIsSurface(poDg)  return _r_  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return _r_  ok
	_ac_ = poDg.Substance().ObjectNames()
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func StzSurfaceRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("sample_is_the_function")
	_o1_.SetClaim("the corners and the centre of the grid, re-evaluated from the expression, agree with the frame's data")
	_o1_.SetOrder(88)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) {
		_r_ = []
		if _SfIsSurface(oDg)  _r_ + "surface:fr"  ok
		return _r_ })
	_o1_.SetCounter(func(oDg) { return _SfCounter(oDg, "surface:") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_oS_ = oDg.Substance()
		_n_ = _oS_.DataOf("fr", "n")
		_oF_ = new stzMathFunction(_oS_.LabelOf("fn"), [ "x", "y" ])
		_aAt_ = [ [ 1, 1 ], [ 1, _n_ ], [ _n_, 1 ], [ _n_, _n_ ], [ ceil(_n_ / 2), ceil(_n_ / 2) ] ]
		_nA_ = _oS_.DataOf("fr", "xa")  _nB_ = _oS_.DataOf("fr", "xb")
		_nC_ = _oS_.DataOf("fr", "ya")  _nD_ = _oS_.DataOf("fr", "yb")
		for _k_ = 1 to 5
			_i_ = _aAt_[_k_][1]  _j_ = _aAt_[_k_][2]
			_x_ = _nA_ + (_nB_ - _nA_) * (_i_ - 1) / (_n_ - 1)
			_y_ = _nC_ + (_nD_ - _nC_) * (_j_ - 1) / (_n_ - 1)
			_z_ = _oF_.ValueAt([ _x_, _y_ ])
			_w_ = _oS_.DataOf("fr", "z" + _i_ + "_" + _j_)
			if fabs(_z_ - _w_) > 0.000000001 * (1 + fabs(_z_))
				_oF_.Free()
				return [ FALSE, "at (" + _FfNum(_x_, 4) + ", " + _FfNum(_y_, 4) + ") the frame says z = " +
					_FfNum(_w_, 6) + " and the function gives " + _FfNum(_z_, 6) ]
			ok
		next
		_oF_.Free()
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("grid_is_complete")
	_o2_.SetClaim("the wireframe has 2n lines of n points each")
	_o2_.SetOrder(89)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) {
		_r_ = []
		if _SfIsSurface(oDg)  _r_ + "grid:fr"  ok
		return _r_ })
	_o2_.SetCounter(func(oDg) { return _SfCounter(oDg, "grid:") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_oS_ = oDg.Substance()
		_n_ = _oS_.DataOf("fr", "n")
		_ac_ = _oS_.ObjectsOfType("Line")
		if len(_ac_) != 2 * _n_
			return [ FALSE, "a " + _n_ + " x " + _n_ + " grid has " + (2 * _n_) + " lines and the picture holds " + len(_ac_) ]
		ok
		for _i_ = 1 to len(_ac_)
			if NOT _oS_.HasData(_ac_[_i_], "x" + _n_)
				return [ FALSE, "the line '" + _ac_[_i_] + "' has fewer than " + _n_ + " points" ]
			ok
		next
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	return _ao_
