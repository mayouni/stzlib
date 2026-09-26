#=====================================================================#
#  STZFUNCTIONFIGURE -- M1a: y = f(x) is a FIGURE, declared,           #
#  computed, then solved                                               #
#=====================================================================#
/*
	THE FIRST VISUAL DOOR of the mathematics plane (base/math/CHARTER.md,
	law 4). A function plot is not a drawing command here: it is a
	DECLARATION -- an expression, a range, what to mark -- that the engine
	COMPUTES into samples, zeros and extrema, and that the diagram solver
	then SOLVES: every label finds a place off the curve, off the axes and
	off its neighbours, and the picture is judged by the one gate like
	every other mathematical diagram.

	WHY "COMPUTED" STANDS BETWEEN "DECLARED" AND "SOLVED": the solver
	holds 256 tape variables (engine/src/autodiff.zig:38), and a curve of
	four hundred samples is not four hundred unknowns. The curve is DATA,
	the way the dots, timeline and choropleth domains mint no unknowns;
	only what has a choice -- where a name stands -- is a variable.

	WHAT A FUNCTION FIGURE IS HERE:

	    DOMAIN     Frame, the paper's window onto the plane; Axis, the two
	               axes; Tick, a named position on an axis; Curve, one
	               unbroken piece of the graph; Mark, a point of interest
	               on the curve -- Zero, Extremum, or Given by the author;
	               Note, the name of a mark (a constructor over Mark, so
	               a rule binds the two); Tangent, the line at a point;
	               Pole, a place the function is not finite.

	    SUBSTANCE  built from a declaration:
	                 [ :f = "sin(x) / x", :on = [ -12, 12 ] ]          explicit
	                 [ :x = "cos(t)", :y = "sin(2*t)", :t = [ 0, 6.3 ] ] parametric
	                 [ :r = "1 + cos(t)", :t = [ 0, 6.3 ] ]              polar
	               with :samples (400), :mark ([ :zeros, :extrema ] or
	               numbers), :label, :tangent (an x), :y (a fixed
	               [ymin, ymax] window, explicit form only) and :font.
	               Every sample is a datum in pixels; a mark carries its
	               place in the author's units AND the two neighbouring
	               samples that bracket it, so a rule can check the claim
	               without trusting the search that made it.

	    STYLE      the frame as a faint rect; an axis as a line with an
	               arrow; a tick as a cross-mark with its number; a piece
	               of the curve as ONE polyline (a spline of its samples
	               with no interpolation, so <g id="c1"> is the curve to
	               a consumer); a mark as a dot -- hollow for a zero,
	               filled for an extremum, in the info colour for a point
	               the author named; a note SOLVED near its mark and off
	               the curve's local chords, the axes, the tick numbers
	               and the other notes; a tangent as a line; a pole as a
	               faint vertical in the colour of a fault.

	WHAT THE DOMAIN OWES THE GATE -- claims a drawing cannot show false:

	    zero_brackets_a_sign_change   a mark named a zero stands between
	                                  two samples of opposite sign
	    extremum_brackets_a_turn      a mark named an extremum stands
	                                  between two samples of opposite slope
	    note_reads_near_its_mark      a note is within reach of its mark
	                                  (picture: solved, not placed)

	WHAT IS SAID PLAINLY: the function is evaluated by the engine's tape
	(stzMathFunction), never by Ring; a root is refined by bisection on
	that tape between two samples; a function that is not finite somewhere
	on its range is not refused -- the curve breaks there and a Pole says
	so; a y-window given by the author breaks the curve where it leaves
	the window, and the piece says it was Clipped. No arc primitive exists
	on the canvas, so a curve is its samples joined; four hundred of them
	over a range is a line the eye cannot break.
*/

StzRegisterMathRuleSet("function", StzFunctionRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzFunctionDomain()
	return StzFunctionDomainXT([])

# WITH THE PIECE SIZES: a spline shape takes its point count as a number,
# never as a datum, so a piece of n samples is drawn by a rule written
# for n -- and the rule finds its pieces through a predicate the domain
# declares for each size that occurs. The domain is otherwise the same.
func StzFunctionDomainXT(panSizes)
	_o_ = new stzMathDomain("function")
	_o_.AddType("Frame")
	_o_.AddType("Axis")
	_o_.AddType("Tick")
	_o_.AddType("Curve")
	_o_.AddType("Mark")
	_o_.AddType("Note")
	_o_.AddType("Tangent")
	_o_.AddType("Pole")
	_o_.AddConstructor("Note", [ "Mark" ])
	_o_.AddPredicate("Zero", [ "Mark" ])
	_o_.AddPredicate("Extremum", [ "Mark" ])
	_o_.AddPredicate("Given", [ "Mark" ])
	_o_.AddPredicate("OnY", [ "Tick" ])
	_o_.AddPredicate("Clipped", [ "Curve" ])
	_n_ = len(panSizes)
	for _i_ = 1 to _n_
		_o_.AddPredicate("Pts" + panSizes[_i_], [ "Curve" ])
	next
	return _o_

# THE HOUSE TYPE SIZE, and every paired dimension with it (the timeline's
# lesson: a builder that spaces at one size while the style draws at
# another overlaps every name by the difference)
func StzFunctionFigureWidth()
	return 900

func StzFunctionFigureHeight()
	return 600

func StzFunctionFigureLeft()
	return 78

func StzFunctionFigureRight()
	return 44

func StzFunctionFigureTop()
	return 48

func StzFunctionFigureBottom()
	return 56

func StzFunctionFigureTypeSize()
	return 15

func StzFunctionFigureTitleSize()
	return 20

func StzFunctionFigureDefaultSamples()
	return 400

# how far a note's centre may stand from its mark, past half its own width
func StzFunctionFigureLeash()
	return 40

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM A DECLARATION                                   #
#---------------------------------------------------------------------#

func StzFunctionFigureFrom(paSpec)
	return StzFunctionFigureFromXT(NULL, paSpec)

# the whole picture in one call: substance, a style written for the
# piece sizes that occurred, the diagram with its font
func StzFunctionFigureBuildXT(poFont, paSpec)
	_oS_ = StzFunctionFigureFromXT(poFont, paSpec)
	_o_ = new stzMathDiagram(_oS_.DomainQ(), _oS_, StzFunctionStyleXT(StzFunctionPieceSizesOf(_oS_)))
	if isObject(poFont)  _o_.SetFont(poFont, StzFunctionFigureTypeSize())  ok
	_o_.SetVariation("function")
	return _o_

func StzFunctionFigure(poFont, paSpec)
	return StzFunctionFigureBuildXT(poFont, paSpec)

# the sizes of the pieces a substance holds, distinct, ascending
func StzFunctionPieceSizesOf(poSubstance)
	_a_ = []
	_ac_ = poSubstance.ObjectsOfType("Curve")
	_n_ = len(_ac_)
	for _i_ = 1 to _n_
		_k_ = poSubstance.DataOf(_ac_[_i_], "n")
		if NOT _FfIn(_a_, _k_)  _a_ + _k_  ok
	next
	return sort(_a_)

func StzFunctionFigureFromXT(poFont, paSpec)
	_d_ = _FfDeclaration(paSpec)

	# THE COMPUTED HALF: the samples, from the engine's tape
	_oF_ = NULL  _oG_ = NULL
	_aT_ = []  _aX_ = []  _aY_ = []
	_nN_ = _d_[:samples]
	_nA_ = _d_[:range][1]
	_nB_ = _d_[:range][2]
	if _d_[:form] = "explicit"
		_oF_ = _FfCompile(_d_[:f], "x")
		for _i_ = 0 to _nN_ - 1
			_x_ = _nA_ + (_nB_ - _nA_) * _i_ / (_nN_ - 1)
			_aT_ + _x_
			_aX_ + _x_
			_aY_ + _oF_.ValueAt([ _x_ ])
		next
	but _d_[:form] = "parametric"
		_oF_ = _FfCompile(_d_[:x], "t")
		_oG_ = _FfCompile(_d_[:y], "t")
		for _i_ = 0 to _nN_ - 1
			_t_ = _nA_ + (_nB_ - _nA_) * _i_ / (_nN_ - 1)
			_aT_ + _t_
			_aX_ + _oF_.ValueAt([ _t_ ])
			_aY_ + _oG_.ValueAt([ _t_ ])
		next
	else
		_oF_ = _FfCompile(_d_[:r], "t")
		for _i_ = 0 to _nN_ - 1
			_t_ = _nA_ + (_nB_ - _nA_) * _i_ / (_nN_ - 1)
			_r_ = _oF_.ValueAt([ _t_ ])
			_aT_ + _t_
			_aX_ + (_r_ * cos(_t_))
			_aY_ + (_r_ * sin(_t_))
		next
	ok

	# THE WINDOW: the author's, or the finite samples' with air around them
	_nXmin_ = 0  _nXmax_ = 0  _nYmin_ = 0  _nYmax_ = 0
	_bAny_ = FALSE
	for _i_ = 1 to _nN_
		if NOT (_FfFinite(_aX_[_i_]) and _FfFinite(_aY_[_i_]))  loop  ok
		if NOT _bAny_
			_nXmin_ = _aX_[_i_]  _nXmax_ = _aX_[_i_]
			_nYmin_ = _aY_[_i_]  _nYmax_ = _aY_[_i_]
			_bAny_ = TRUE
		ok
		if _aX_[_i_] < _nXmin_  _nXmin_ = _aX_[_i_]  ok
		if _aX_[_i_] > _nXmax_  _nXmax_ = _aX_[_i_]  ok
		if _aY_[_i_] < _nYmin_  _nYmin_ = _aY_[_i_]  ok
		if _aY_[_i_] > _nYmax_  _nYmax_ = _aY_[_i_]  ok
	next
	if NOT _bAny_
		stzraise("StzFunctionFigure: '" + _d_[:text] + "' is finite nowhere on " +
			"[" + _FfNum(_nA_, 6) + ", " + _FfNum(_nB_, 6) + "] -- there is no curve to draw.")
	ok
	if _d_[:form] = "explicit"
		_nXmin_ = _nA_  _nXmax_ = _nB_
	ok
	_bWindow_ = (len(_d_[:window]) = 2)
	if _bWindow_
		_nYmin_ = _d_[:window][1]
		_nYmax_ = _d_[:window][2]
	else
		if _nYmax_ - _nYmin_ < 0.000000001
			_nYmin_ = _nYmin_ - 1
			_nYmax_ = _nYmax_ + 1
		ok
		# at least 52 px of air above and below the samples -- a note under
		# a minimum needs 37 -- and never less than eight per cent
		_nPh0_ = StzFunctionFigureHeight() - StzFunctionFigureTop() - StzFunctionFigureBottom() - 40
		_nPad_ = (_nYmax_ - _nYmin_) * 0.08
		_nAir_ = (_nYmax_ - _nYmin_) * 52 / (_nPh0_ - 104)
		if _nAir_ > _nPad_  _nPad_ = _nAir_  ok
		_nYmin_ = _nYmin_ - _nPad_
		_nYmax_ = _nYmax_ + _nPad_
		if _d_[:form] != "explicit"
			if _nXmax_ - _nXmin_ < 0.000000001
				_nXmin_ = _nXmin_ - 1
				_nXmax_ = _nXmax_ + 1
			ok
			_nPad_ = (_nXmax_ - _nXmin_) * 0.08
			_nXmin_ = _nXmin_ - _nPad_
			_nXmax_ = _nXmax_ + _nPad_
		ok
	ok

	# PIXELS: the window onto the paper. y grows upward in mathematics
	# and downward on a canvas, so the map flips it.
	_nL_ = StzFunctionFigureLeft()
	_nT_ = StzFunctionFigureTop()
	_aTb_ = _FfTitleBox(poFont, _d_[:label], StzFunctionFigureTitleSize())
	if _aTb_[1] + _aTb_[2] + 18 > _nT_  _nT_ = _aTb_[1] + _aTb_[2] + 18  ok
	_nPw_ = StzFunctionFigureWidth() - _nL_ - StzFunctionFigureRight()
	_nPh_ = StzFunctionFigureHeight() - _nT_ - StzFunctionFigureBottom()
	_nKx_ = _nPw_ / (_nXmax_ - _nXmin_)
	_nKy_ = _nPh_ / (_nYmax_ - _nYmin_)

	# THE PIECES: the curve breaks where a sample is not finite or leaves
	# the author's window; a break of the first kind is a pole
	_aPieces_ = []      # [ [ i0, i1 ], ... ] sample index ranges
	_anPoles_ = []      # sample indices that are not finite
	_bClipped_ = FALSE
	_i0_ = 0
	for _i_ = 1 to _nN_
		_bIn_ = _FfFinite(_aX_[_i_]) and _FfFinite(_aY_[_i_])
		if _bIn_ and NOT (_FfFinite(_aX_[_i_]) and _FfFinite(_aY_[_i_]))  _bIn_ = FALSE  ok
		if _bIn_ and _bWindow_ and (_aY_[_i_] < _nYmin_ or _aY_[_i_] > _nYmax_)
			_bIn_ = FALSE
			_bClipped_ = TRUE
		but NOT _bIn_
			_anPoles_ + _i_
		ok
		if _bIn_
			if _i0_ = 0  _i0_ = _i_  ok
		else
			if _i0_ > 0  _aPieces_ + [ _i0_, _i_ - 1 ]  ok
			_i0_ = 0
		ok
	next
	if _i0_ > 0  _aPieces_ + [ _i0_, _nN_ ]  ok
	# a piece of one sample is a point, not a curve; it is dropped and the
	# frame counts it
	_aKeep_ = []
	_nDropped_ = 0
	for _i_ = 1 to len(_aPieces_)
		if _aPieces_[_i_][2] - _aPieces_[_i_][1] >= 1
			_aKeep_ + _aPieces_[_i_]
		else
			_nDropped_++
		ok
	next
	_aPieces_ = _aKeep_
	if len(_aPieces_) = 0
		stzraise("StzFunctionFigure: '" + _d_[:text] + "' leaves no two consecutive " +
			"samples to join on its range -- nothing to draw.")
	ok
	# RUNS: a spline holds at most 64 controls (stzMathDiagram._MintShape),
	# so a piece longer than that is drawn as consecutive runs that share
	# an endpoint -- one polyline to the eye, several elements to a consumer
	_aRuns_ = []        # [ [ i0, i1, piece ] ]
	for _i_ = 1 to len(_aPieces_)
		_s_ = _aPieces_[_i_][1]
		while _s_ < _aPieces_[_i_][2]
			_e_ = _s_ + 63
			if _e_ > _aPieces_[_i_][2]  _e_ = _aPieces_[_i_][2]  ok
			_aRuns_ + [ _s_, _e_, _i_ ]
			_s_ = _e_
		end
	next
	_anSizes_ = []
	for _i_ = 1 to len(_aRuns_)
		_k_ = _aRuns_[_i_][2] - _aRuns_[_i_][1] + 1
		if NOT _FfIn(_anSizes_, _k_)  _anSizes_ + _k_  ok
	next

	# THE MARKS: zeros and extrema found between samples and refined on
	# the tape; points the author named; the tangent's foot
	_aMarks_ = []       # [ [ kind, x, y, i, yl, yr ] ]
	if _d_[:form] = "explicit"
		if _d_[:zeros]
			for _i_ = 1 to _nN_ - 1
				if NOT (_FfFinite(_aY_[_i_]) and _FfFinite(_aY_[_i_ + 1]))  loop  ok
				if _aY_[_i_] = 0
					_aMarks_ + [ "zero", _aX_[_i_], 0, _i_, _FfNeighbour(_aY_, _i_, -1), _FfNeighbour(_aY_, _i_, 1) ]
				but (_aY_[_i_] < 0) != (_aY_[_i_ + 1] < 0)
					_x_ = _FfBisect(_oF_, _aX_[_i_], _aX_[_i_ + 1], _aY_[_i_], _aY_[_i_ + 1], FALSE)
					_y_ = _oF_.ValueAt([ _x_ ])
					# tan crosses from +197 to -57 at pi/2 and the search lands ON
					# the pole: a zero is where the value is small, not merely
					# where the sign turns
					if _FfFinite(_y_) and fabs(_y_) <= 0.000001 * (1 + min([ fabs(_aY_[_i_]), fabs(_aY_[_i_ + 1]) ]))
						_aMarks_ + [ "zero", _x_, _y_, _i_, _aY_[_i_], _aY_[_i_ + 1] ]
					ok
				ok
			next
		ok
		if _d_[:extrema]
			_aD_ = []
			for _i_ = 1 to _nN_
				if _FfFinite(_aY_[_i_])
					_aD_ + _oF_.GradientAt([ _aX_[_i_] ])[1]
				else
					_aD_ + 0
				ok
			next
			for _i_ = 1 to _nN_ - 1
				if NOT (_FfFinite(_aY_[_i_]) and _FfFinite(_aY_[_i_ + 1]))  loop  ok
				if (_aD_[_i_] < 0) != (_aD_[_i_ + 1] < 0) and _aD_[_i_] != 0
					_x_ = _FfBisect(_oF_, _aX_[_i_], _aX_[_i_ + 1], _aD_[_i_], _aD_[_i_ + 1], TRUE)
					_y_ = _oF_.ValueAt([ _x_ ])
					_g_ = _oF_.GradientAt([ _x_ ])[1]
					_k_ = "min"
					if _aD_[_i_] > 0  _k_ = "max"  ok
					if _FfFinite(_y_) and _FfFinite(_g_) and
					   fabs(_g_) <= 0.000001 * (1 + min([ fabs(_aD_[_i_]), fabs(_aD_[_i_ + 1]) ]))
						_aMarks_ + [ _k_, _x_, _y_, _i_, _aD_[_i_], _aD_[_i_ + 1] ]
					ok
				ok
			next
		ok
		_ag_ = _d_[:given]
		for _i_ = 1 to len(_ag_)
			_x_ = _ag_[_i_]
			if _x_ < _nA_ or _x_ > _nB_
				stzraise("StzFunctionFigure: the point x = " + _FfNum(_x_, 6) + " to mark is " +
					"not on the range [" + _FfNum(_nA_, 6) + ", " + _FfNum(_nB_, 6) + "].")
			ok
			_y_ = _oF_.ValueAt([ _x_ ])
			if NOT _FfFinite(_y_)
				stzraise("StzFunctionFigure: '" + _d_[:text] + "' is not finite at x = " +
					_FfNum(_x_, 6) + ", so there is no point there to mark.")
			ok
			if _bWindow_ and (_y_ < _nYmin_ or _y_ > _nYmax_)
				stzraise("StzFunctionFigure: the point (" + _FfNum(_x_, 4) + ", " + _FfNum(_y_, 4) +
					") to mark lies outside the window [" + _FfNum(_nYmin_, 4) + ", " + _FfNum(_nYmax_, 4) + "].")
			ok
			_aMarks_ + [ "given", _x_, _y_, _FfIndexNear(_aX_, _x_), 0, 0 ]
		next
	else
		_ag_ = _d_[:given]
		for _i_ = 1 to len(_ag_)
			_t_ = _ag_[_i_]
			if _t_ < _nA_ or _t_ > _nB_
				stzraise("StzFunctionFigure: the parameter t = " + _FfNum(_t_, 6) + " to mark is " +
					"not on the range [" + _FfNum(_nA_, 6) + ", " + _FfNum(_nB_, 6) + "].")
			ok
			if _d_[:form] = "parametric"
				_x_ = _oF_.ValueAt([ _t_ ])
				_y_ = _oG_.ValueAt([ _t_ ])
			else
				_r_ = _oF_.ValueAt([ _t_ ])
				_x_ = _r_ * cos(_t_)
				_y_ = _r_ * sin(_t_)
			ok
			_aMarks_ + [ "given", _x_, _y_, _FfIndexNear(_aT_, _t_), 0, 0 ]
		next
	ok
	# THE CAP: a family of sines over a long range has more zeros than a
	# picture has room for names; the first ones in x stay and the frame
	# says how many were left out
	# a computed mark outside the window has no place on the paper
	_aKeep_ = []
	for _i_ = 1 to len(_aMarks_)
		_m_ = _aMarks_[_i_]
		if _m_[2] < _nXmin_ or _m_[2] > _nXmax_ or _m_[3] < _nYmin_ or _m_[3] > _nYmax_  loop  ok
		_aKeep_ + _m_
	next
	_aMarks_ = _aKeep_
	_nMax_ = _d_[:maxmarks]
	_nLeft_ = 0
	_aMarks_ = _FfSortMarks(_aMarks_, (_nA_ + _nB_) / 2)
	if len(_aMarks_) > _nMax_  _nLeft_ = len(_aMarks_) - _nMax_  ok

	# THE DOMAIN, with the sizes that occurred, and the substance
	_oDom_ = StzFunctionDomainXT(_anSizes_)
	_oS_ = new stzMathSubstance(_oDom_)

	# the frame: the window in both units, what was computed, the title
	_nX0_ = _nL_
	_nY0_ = _nT_
	_nX1_ = _nL_ + _nPw_
	_nY1_ = _nT_ + _nPh_
	_oS_.Declare("Frame", "fr")
	_oS_.Label("fr", _d_[:label])
	_oS_.SetData("fr", "x0", _nX0_)  _oS_.SetData("fr", "y0", _nY0_)
	_oS_.SetData("fr", "x1", _nX1_)  _oS_.SetData("fr", "y1", _nY1_)
	_oS_.SetData("fr", "xmin", _nXmin_)  _oS_.SetData("fr", "xmax", _nXmax_)
	_oS_.SetData("fr", "ymin", _nYmin_)  _oS_.SetData("fr", "ymax", _nYmax_)
	_oS_.SetData("fr", "samples", _nN_)
	_oS_.SetData("fr", "pieces", len(_aPieces_))
	_oS_.SetData("fr", "runs", len(_aRuns_))
	_oS_.SetData("fr", "marks", len(_aMarks_))
	_oS_.SetData("fr", "marksleft", _nLeft_)
	_oS_.SetData("fr", "poles", len(_anPoles_))
	_oS_.SetData("fr", "dropped", _nDropped_)
	_oS_.SetData("fr", "clipped", _bClipped_)
	_oS_.SetData("fr", "tx", _nX0_ + _FfTextWidth(poFont, _d_[:label], StzFunctionFigureTitleSize()) / 2)
	_oS_.SetData("fr", "ty", _aTb_[1] + 6)

	# the axes: through the origin when the window holds it, on the
	# window's edge when it does not
	_nAxY_ = _nY1_
	if _nYmin_ < 0 and _nYmax_ > 0  _nAxY_ = _nY0_ + (_nYmax_ - 0) * _nKy_  ok
	_nAxX_ = _nX0_
	if _nXmin_ < 0 and _nXmax_ > 0  _nAxX_ = _nX0_ + (0 - _nXmin_) * _nKx_  ok
	_oS_.Declare("Axis", "ax")
	_oS_.Label("ax", _d_[:xname])
	_oS_.SetData("ax", "x0", _nX0_)  _oS_.SetData("ax", "y0", _nAxY_)
	_oS_.SetData("ax", "x1", _nX1_ + 14)  _oS_.SetData("ax", "y1", _nAxY_)
	_oS_.SetData("ax", "lx", _nX1_ + 22 + _FfTextWidth(poFont, _d_[:xname], StzFunctionFigureTypeSize() + 2) / 2)
	_oS_.SetData("ax", "ly", _nAxY_)
	_oS_.Declare("Axis", "ay")
	_oS_.Label("ay", _d_[:yname])
	_oS_.SetData("ay", "x0", _nAxX_)  _oS_.SetData("ay", "y0", _nY1_)
	# THE Y AXIS ENDS AT THE FRAME'S TOP and its name stands just inside:
	# above the frame is the title's band, and a stacked title met the
	# arrow and the name there
	_oS_.SetData("ay", "x1", _nAxX_)  _oS_.SetData("ay", "y1", _nY0_ - 2)
	_oS_.SetData("ay", "lx", _nAxX_ + 12 + _FfTextWidth(poFont, _d_[:yname], StzFunctionFigureTypeSize() + 2) / 2)
	_oS_.SetData("ay", "ly", _nY0_ + 17)

	# the ticks: a nice step giving six to eight, on every multiple in the window
	_nStep_ = _FfNiceStep(_nXmax_ - _nXmin_, 7)
	_nK_ = 0
	for _j_ = ceil(_nXmin_ / _nStep_) to floor(_nXmax_ / _nStep_)
		_v_ = _j_ * _nStep_
		_nK_++
		_oS_.Declare("Tick", "tx" + _nK_)
		_oS_.Label("tx" + _nK_, _FfNum(_v_, 6))
		_oS_.SetData("tx" + _nK_, "v", _v_)
		_oS_.SetData("tx" + _nK_, "x", _nX0_ + (_v_ - _nXmin_) * _nKx_)
		_oS_.SetData("tx" + _nK_, "y", _nY1_ + 3)
		_oS_.SetData("tx" + _nK_, "dx", 0)  _oS_.SetData("tx" + _nK_, "dy", 3)
		_oS_.SetData("tx" + _nK_, "lx", _nX0_ + (_v_ - _nXmin_) * _nKx_)
		_oS_.SetData("tx" + _nK_, "ly", _nY1_ + 19)
	next
	_nStep_ = _FfNiceStep(_nYmax_ - _nYmin_, 6)
	_nK_ = 0
	for _j_ = ceil(_nYmin_ / _nStep_) to floor(_nYmax_ / _nStep_)
		_v_ = _j_ * _nStep_
		_nK_++
		_c_ = _FfNum(_v_, 6)
		_oS_.Declare("Tick", "ty" + _nK_)
		_oS_.Assert("OnY", [ "ty" + _nK_ ])
		_oS_.Label("ty" + _nK_, _c_)
		_oS_.SetData("ty" + _nK_, "v", _v_)
		_oS_.SetData("ty" + _nK_, "x", _nX0_ - 3)
		_oS_.SetData("ty" + _nK_, "y", _nY0_ + (_nYmax_ - _v_) * _nKy_)
		_oS_.SetData("ty" + _nK_, "dx", 3)  _oS_.SetData("ty" + _nK_, "dy", 0)
		_oS_.SetData("ty" + _nK_, "lx", _nX0_ - 13 - _FfTextWidth(poFont, _c_, StzFunctionFigureTypeSize()) / 2)
		_oS_.SetData("ty" + _nK_, "ly", _nY0_ + (_nYmax_ - _v_) * _nKy_)
	next

	# the pieces: every sample a datum in pixels, the count a datum too --
	# unless a motion draws the curve, in which case no run is minted
	_oS_.SetData("fr", "live", (_d_[:curve] = "live"))
	if _d_[:curve] = "live"
		_aRuns_ = []
		_oS_.SetData("fr", "runs", 0)
	ok
	for _p_ = 1 to len(_aRuns_)
		_cC_ = "c" + _p_
		_i0_ = _aRuns_[_p_][1]
		_i1_ = _aRuns_[_p_][2]
		_q_ = _aRuns_[_p_][3]
		_oS_.Declare("Curve", _cC_)
		_oS_.Label(_cC_, "")
		_oS_.SetData(_cC_, "n", _i1_ - _i0_ + 1)
		_oS_.SetData(_cC_, "piece", _q_)
		_oS_.SetData(_cC_, "from", _i0_)
		_oS_.SetData(_cC_, "to", _i1_)
		_oS_.Assert("Pts" + (_i1_ - _i0_ + 1), [ _cC_ ])
		if _bClipped_ and (_aPieces_[_q_][1] > 1 or _aPieces_[_q_][2] < _nN_)  _oS_.Assert("Clipped", [ _cC_ ])  ok
		_v_ = 0
		for _i_ = _i0_ to _i1_
			_v_++
			_oS_.SetData(_cC_, "x" + _v_, _nX0_ + (_aX_[_i_] - _nXmin_) * _nKx_)
			_oS_.SetData(_cC_, "y" + _v_, _nY0_ + (_nYmax_ - _aY_[_i_]) * _nKy_)
		next
	next

	# the poles: one vertical per run of samples that are not finite
	_nP_ = 0
	_nPrev_ = -9
	for _i_ = 1 to len(_anPoles_)
		_k_ = _anPoles_[_i_]
		if _k_ = _nPrev_ + 1
			_nPrev_ = _k_
			loop
		ok
		_nPrev_ = _k_
		if _bWindow_ and _FfFinite(_aY_[_k_])  loop  ok
		_nP_++
		_x_ = _aT_[_k_]
		if _d_[:form] != "explicit"  loop  ok
		_oS_.Declare("Pole", "p" + _nP_)
		_oS_.Label("p" + _nP_, "")
		_oS_.SetData("p" + _nP_, "at", _x_)
		_oS_.SetData("p" + _nP_, "x", _nX0_ + (_x_ - _nXmin_) * _nKx_)
		_oS_.SetData("p" + _nP_, "y0", _nY0_)
		_oS_.SetData("p" + _nP_, "y1", _nY1_)
	next

	# the tangent: the line through (x0, f(x0)) with the tape's own slope
	if _d_[:form] = "explicit" and isNumber(_d_[:tangent])
		_x_ = _d_[:tangent]
		if _x_ < _nA_ or _x_ > _nB_
			stzraise("StzFunctionFigure: the tangent's foot x = " + _FfNum(_x_, 6) + " is not on " +
				"the range [" + _FfNum(_nA_, 6) + ", " + _FfNum(_nB_, 6) + "].")
		ok
		_y_ = _oF_.ValueAt([ _x_ ])
		_m_ = _oF_.GradientAt([ _x_ ])[1]
		if NOT (_FfFinite(_y_) and _FfFinite(_m_))
			stzraise("StzFunctionFigure: '" + _d_[:text] + "' has no tangent at x = " +
				_FfNum(_x_, 6) + " -- the function or its slope is not finite there.")
		ok
		if _bWindow_ and (_y_ < _nYmin_ or _y_ > _nYmax_)
			stzraise("StzFunctionFigure: the tangent's foot (" + _FfNum(_x_, 4) + ", " + _FfNum(_y_, 4) +
				") lies outside the window.")
		ok
		# a sixth of the range each way, then CLIPPED to the window: a
		# tangent that runs off the paper is a picture the gate refuses
		_nH_ = (_nB_ - _nA_) / 6
		_aSeg_ = _FfClipToBox(_x_ - _nH_, _y_ - _m_ * _nH_, _x_ + _nH_, _y_ + _m_ * _nH_,
			_nXmin_, _nYmin_, _nXmax_, _nYmax_)
		_oS_.Declare("Tangent", "tg")
		_oS_.Label("tg", "")
		_oS_.SetData("tg", "at", _x_)
		_oS_.SetData("tg", "slope", _m_)
		_oS_.SetData("tg", "x1", _nX0_ + (_aSeg_[1] - _nXmin_) * _nKx_)
		_oS_.SetData("tg", "y1", _nY0_ + (_nYmax_ - _aSeg_[2]) * _nKy_)
		_oS_.SetData("tg", "x2", _nX0_ + (_aSeg_[3] - _nXmin_) * _nKx_)
		_oS_.SetData("tg", "y2", _nY0_ + (_nYmax_ - _aSeg_[4]) * _nKy_)
		_aMarks_ + [ "given", _x_, _y_, _FfIndexNear(_aX_, _x_), 0, 0 ]
	ok

	# THE COARSE CHORDS of the curve: one per five samples, in pixels,
	# from which each mark takes the twelve nearest -- a note is kept off
	# the curve where the curve actually is, within the reach its leash
	# allows, and a constraint against every one of four hundred segments
	# would be four hundred terms per name
	_aChords_ = []      # [ x1, y1, x2, y2, midx, midy ]
	for _p_ = 1 to len(_aPieces_)
		_i0_ = _aPieces_[_p_][1]
		_i1_ = _aPieces_[_p_][2]
		_s_ = _i0_
		while _s_ < _i1_
			_e_ = _s_ + 5
			if _e_ > _i1_  _e_ = _i1_  ok
			_x1_ = _nX0_ + (_aX_[_s_] - _nXmin_) * _nKx_
			_y1_ = _nY0_ + (_nYmax_ - _aY_[_s_]) * _nKy_
			_x2_ = _nX0_ + (_aX_[_e_] - _nXmin_) * _nKx_
			_y2_ = _nY0_ + (_nYmax_ - _aY_[_e_]) * _nKy_
			_aChords_ + [ _x1_, _y1_, _x2_, _y2_, (_x1_ + _x2_) / 2, (_y1_ + _y2_) / 2 ]
			_s_ = _e_
		end
	next

	# the marks and their notes: a mark carries its place in both units,
	# the two samples that bracket it, and its twelve nearest chords
	for _k_ = 1 to len(_aMarks_)
		_m_ = _aMarks_[_k_]
		_cM_ = "m" + _k_
		_oS_.Declare("Mark", _cM_)
		_oS_.Label(_cM_, "")
		_oS_.SetData(_cM_, "x", _m_[2])
		_oS_.SetData(_cM_, "y", _m_[3])
		_oS_.SetData(_cM_, "px", _nX0_ + (_m_[2] - _nXmin_) * _nKx_)
		_oS_.SetData(_cM_, "py", _nY0_ + (_nYmax_ - _m_[3]) * _nKy_)
		_oS_.SetData(_cM_, "yl", _m_[5])
		_oS_.SetData(_cM_, "yr", _m_[6])
		# THE FREE SIDE: a note starts below a minimum and above anything
		# else, because above a minimum is the inside of its bell
		_nSide_ = -1
		if _m_[1] = "min"  _nSide_ = 1  ok
		_oS_.SetData(_cM_, "side", _nSide_)
		if _m_[1] = "zero"
			_oS_.Assert("Zero", [ _cM_ ])
			_cText_ = "x = " + _FfNum(_m_[2], 4)
		but _m_[1] = "max" or _m_[1] = "min"
			_oS_.Assert("Extremum", [ _cM_ ])
			_cText_ = _m_[1] + " (" + _FfNum(_m_[2], 2) + ", " + _FfNum(_m_[3], 2) + ")"
		else
			_oS_.Assert("Given", [ _cM_ ])
			_cText_ = "(" + _FfNum(_m_[2], 3) + ", " + _FfNum(_m_[3], 3) + ")"
		ok
		_aNear_ = _FfNearestChords(_aChords_, _nX0_ + (_m_[2] - _nXmin_) * _nKx_,
			_nY0_ + (_nYmax_ - _m_[3]) * _nKy_, StzFunctionFigureChordsPerMark())
		for _q_ = 1 to StzFunctionFigureChordsPerMark()
			_ch_ = _aNear_[_q_]
			_oS_.SetData(_cM_, "k" + _q_ + "x1", _ch_[1])
			_oS_.SetData(_cM_, "k" + _q_ + "y1", _ch_[2])
			_oS_.SetData(_cM_, "k" + _q_ + "x2", _ch_[3])
			_oS_.SetData(_cM_, "k" + _q_ + "y2", _ch_[4])
		next
		if _k_ <= _nMax_
			_oS_.Define("n" + _k_, "Note", [ _cM_ ])
			_oS_.Label("n" + _k_, _cText_)
		ok
	next

	if isObject(_oF_)  _oF_.Free()  ok
	if isObject(_oG_)  _oG_.Free()  ok
	return _oS_

#-- the declaration, read and refused by name -------------------------

# the keys a declaration may carry, and what they mean, so a refusal
# can say what is allowed
func StzFunctionFigureKeys()
	return [ "f", "x", "y", "r", "t", "on", "samples", "mark", "label",
	         "tangent", "window", "maxmarks", "xname", "yname", "curve", "livesamples" ]

func _FfDeclaration(paSpec)
	if NOT isList(paSpec) or len(paSpec) = 0
		stzraise("StzFunctionFigure: a figure is declared as keys, like " +
			"[ :f = 'sin(x)', :on = [ -6, 6 ] ].")
	ok
	_acKeys_ = StzFunctionFigureKeys()
	for _i_ = 1 to len(paSpec)
		_e_ = paSpec[_i_]
		if NOT isList(_e_) or len(_e_) != 2 or NOT isString(_e_[1])
			stzraise("StzFunctionFigure: entry " + _i_ + " of the declaration is not a " +
				"key and a value.")
		ok
		if NOT _FfIn(_acKeys_, StzLower(_e_[1]))
			stzraise("StzFunctionFigure: ':" + _e_[1] + "' is not a key of a function " +
				"figure -- the keys are " + @@(_acKeys_) + ".")
		ok
	next
	_d_ = [ :form = "", :f = "", :x = "", :y = "", :r = "", :text = "",
	        :range = [], :samples = StzFunctionFigureDefaultSamples(),
	        :zeros = FALSE, :extrema = FALSE, :given = [], :label = "",
	        :tangent = "", :window = [], :maxmarks = 9, :xname = "x", :yname = "y", :curve = "drawn" ]
	_cF_ = _FfGet(paSpec, "f", "")
	_cX_ = _FfGet(paSpec, "x", "")
	_cY_ = _FfGet(paSpec, "y", "")
	_cR_ = _FfGet(paSpec, "r", "")
	if isString(_cF_) and _cF_ != ""
		_d_[:form] = "explicit"
		_d_[:f] = _cF_
		_d_[:text] = "y = " + _cF_
		_d_[:range] = _FfGet(paSpec, "on", [])
		if len(_d_[:range]) = 0
			stzraise("StzFunctionFigure: y = " + _cF_ + " needs its range, :on = [ a, b ].")
		ok
	but isString(_cX_) and _cX_ != "" and isString(_cY_) and _cY_ != ""
		_d_[:form] = "parametric"
		_d_[:x] = _cX_  _d_[:y] = _cY_
		_d_[:text] = "x = " + _cX_ + ", y = " + _cY_
		_d_[:range] = _FfGet(paSpec, "t", [])
		if len(_d_[:range]) = 0
			stzraise("StzFunctionFigure: a parametric curve needs its parameter's range, :t = [ a, b ].")
		ok
	but isString(_cR_) and _cR_ != ""
		_d_[:form] = "polar"
		_d_[:r] = _cR_
		_d_[:text] = "r = " + _cR_
		_d_[:range] = _FfGet(paSpec, "t", [])
		if len(_d_[:range]) = 0
			stzraise("StzFunctionFigure: a polar curve needs its angle's range, :t = [ a, b ].")
		ok
	else
		stzraise("StzFunctionFigure: say what to draw -- :f = 'sin(x)' for y = f(x), " +
			":x and :y for a parametric curve, or :r for a polar one.")
	ok
	if _d_[:form] != "explicit" and isString(_cF_) and _cF_ != ""
		stzraise("StzFunctionFigure: :f and :x/:y/:r cannot both be given -- one curve per figure.")
	ok
	_aR_ = _d_[:range]
	if NOT isList(_aR_) or len(_aR_) != 2 or NOT isNumber(_aR_[1]) or NOT isNumber(_aR_[2])
		stzraise("StzFunctionFigure: a range is two numbers, [ a, b ].")
	ok
	if _aR_[2] <= _aR_[1]
		stzraise("StzFunctionFigure: the range [ " + _FfNum(_aR_[1], 6) + ", " + _FfNum(_aR_[2], 6) +
			" ] runs backwards -- a range is [ a, b ] with a < b.")
	ok
	_nS_ = _FfGet(paSpec, "samples", StzFunctionFigureDefaultSamples())
	if NOT isNumber(_nS_) or _nS_ != floor(_nS_) or _nS_ < 8 or _nS_ > 4000
		stzraise("StzFunctionFigure: :samples is a whole number from 8 to 4000.")
	ok
	_d_[:samples] = _nS_
	_aM_ = _FfGet(paSpec, "mark", [])
	if isString(_aM_) or isNumber(_aM_)  _aM_ = [ _aM_ ]  ok
	if NOT isList(_aM_)
		stzraise("StzFunctionFigure: :mark is a list -- :zeros, :extrema, or numbers to mark.")
	ok
	for _i_ = 1 to len(_aM_)
		_e_ = _aM_[_i_]
		if isString(_e_)
			_c_ = StzLower(ring_trim(_e_))
			if _c_ = "zeros"
				_d_[:zeros] = TRUE
			but _c_ = "extrema"
				_d_[:extrema] = TRUE
			else
				stzraise("StzFunctionFigure: ':" + _e_ + "' is not a mark -- :zeros, :extrema, or a number.")
			ok
		but isNumber(_e_)
			_d_[:given] + _e_
		else
			stzraise("StzFunctionFigure: a mark is :zeros, :extrema, or a number.")
		ok
	next
	if _d_[:form] != "explicit" and (_d_[:zeros] or _d_[:extrema])
		stzraise("StzFunctionFigure: :zeros and :extrema are marks of y = f(x); a parametric " +
			"or polar curve marks values of t.")
	ok
	_cL_ = _FfGet(paSpec, "label", "")
	if NOT isString(_cL_)
		stzraise("StzFunctionFigure: :label is text.")
	ok
	_d_[:label] = _cL_
	_t_ = _FfGet(paSpec, "tangent", "")
	if isNumber(_t_)
		if _d_[:form] != "explicit"
			stzraise("StzFunctionFigure: :tangent is a tangent of y = f(x) at an x.")
		ok
		_d_[:tangent] = _t_
	but NOT (isString(_t_) and _t_ = "")
		stzraise("StzFunctionFigure: :tangent is the x where the tangent touches.")
	ok
	_w_ = _FfGet(paSpec, "window", [])
	if isList(_w_) and len(_w_) > 0
		if _d_[:form] != "explicit"
			stzraise("StzFunctionFigure: :window is the y-window of y = f(x).")
		ok
		if len(_w_) != 2 or NOT isNumber(_w_[1]) or NOT isNumber(_w_[2]) or _w_[2] <= _w_[1]
			stzraise("StzFunctionFigure: :window is [ ymin, ymax ] with ymin < ymax.")
		ok
		_d_[:window] = _w_
	ok
	_nM_ = _FfGet(paSpec, "maxmarks", 9)
	if NOT isNumber(_nM_) or _nM_ < 1 or _nM_ != floor(_nM_)
		stzraise("StzFunctionFigure: :maxmarks is a whole number, at least 1.")
	ok
	_d_[:maxmarks] = _nM_
	_cN_ = _FfGet(paSpec, "xname", "x")
	if isString(_cN_) and _cN_ != ""  _d_[:xname] = _cN_  ok
	_cN_ = _FfGet(paSpec, "yname", "y")
	if isString(_cN_) and _cN_ != ""  _d_[:yname] = _cN_  ok
	# :curve = :live -- a MOTION draws the curve where its parameters are
	# now; the figure computes everything and draws all but the curve
	_cC_ = StzLower(ring_trim("" + _FfGet(paSpec, "curve", "drawn")))
	if _cC_ != "drawn" and _cC_ != "live"
		stzraise("StzFunctionFigure: :curve is :drawn (the figure draws it) or :live (a motion does).")
	ok
	_d_[:curve] = _cC_
	return _d_

# membership, plainly: StzFind answers a list of positions, not a number
func _FfIn(paList, pItem)
	_n_ = len(paList)
	for _i_ = 1 to _n_
		if paList[_i_] = pItem  return TRUE  ok
	next
	return FALSE

func _FfGet(paSpec, pcKey, pDefault)
	_k_ = StzLower("" + pcKey)
	_n_ = len(paSpec)
	for _i_ = 1 to _n_
		if isList(paSpec[_i_]) and len(paSpec[_i_]) = 2 and isString(paSpec[_i_][1]) and
		   StzLower(paSpec[_i_][1]) = _k_
			return paSpec[_i_][2]
		ok
	next
	return pDefault

# the tape, with the reason when the expression cannot be read
func _FfCompile(pcExpr, pcVar)
	if NOT isString(pcExpr) or ring_trim(pcExpr) = ""
		stzraise("StzFunctionFigure: an expression in " + pcVar + " is needed.")
	ok
	return new stzMathFunction(pcExpr, [ pcVar ])

func _FfFinite(pn)
	if NOT isNumber(pn)  return FALSE  ok
	if pn > pow(10, 300) or pn < -pow(10, 300)  return FALSE  ok
	if NOT (pn <= 0 or pn >= 0)  return FALSE  ok
	return TRUE

# bisection on the tape between two samples of opposite sign, of the
# value or of the slope; eighty halvings is far past the double's floor
func _FfBisect(poF, pnA, pnB, pnFa, pnFb, pbSlope)
	_a_ = pnA  _b_ = pnB  _fa_ = pnFa
	for _i_ = 1 to 80
		_m_ = (_a_ + _b_) / 2
		if pbSlope
			_fm_ = poF.GradientAt([ _m_ ])[1]
		else
			_fm_ = poF.ValueAt([ _m_ ])
		ok
		if _fm_ = 0  return _m_  ok
		if (_fa_ < 0) = (_fm_ < 0)
			_a_ = _m_  _fa_ = _fm_
		else
			_b_ = _m_
		ok
		if fabs(_b_ - _a_) <= 0.000000000001 * (1 + fabs(_m_))  exit  ok
	next
	return (_a_ + _b_) / 2

# a segment cut to a box, parametrically: each edge shortens the part of
# [0, 1] that is inside, and what is left is the segment inside
func _FfClipToBox(pnX1, pnY1, pnX2, pnY2, pnL, pnB, pnR, pnT)
	_t0_ = 0  _t1_ = 1
	_dx_ = pnX2 - pnX1  _dy_ = pnY2 - pnY1
	_aP_ = [ -_dx_, _dx_, -_dy_, _dy_ ]
	_aQ_ = [ pnX1 - pnL, pnR - pnX1, pnY1 - pnB, pnT - pnY1 ]
	for _k_ = 1 to 4
		if _aP_[_k_] = 0
			if _aQ_[_k_] < 0  return [ pnX1, pnY1, pnX1, pnY1 ]  ok
		else
			_r_ = _aQ_[_k_] / _aP_[_k_]
			if _aP_[_k_] < 0
				if _r_ > _t0_  _t0_ = _r_  ok
			else
				if _r_ < _t1_  _t1_ = _r_  ok
			ok
		ok
	next
	if _t0_ > _t1_  return [ pnX1, pnY1, pnX1, pnY1 ]  ok
	return [ pnX1 + _t0_ * _dx_, pnY1 + _t0_ * _dy_, pnX1 + _t1_ * _dx_, pnY1 + _t1_ * _dy_ ]

# how many chords of the curve each mark keeps its note off
func StzFunctionFigureChordsPerMark()
	return 12

# the pnCount chords nearest a point, by their midpoints; a curve with
# fewer chords repeats its last one, so the count is always met
func _FfNearestChords(paChords, pnX, pnY, pnCount)
	_a_ = []
	_n_ = len(paChords)
	for _i_ = 1 to _n_
		_a_ + [ pow(paChords[_i_][5] - pnX, 2) + pow(paChords[_i_][6] - pnY, 2), _i_ ]
	next
	_a_ = sort(_a_, 1)
	_out_ = []
	for _i_ = 1 to pnCount
		_j_ = _i_
		if _j_ > _n_  _j_ = _n_  ok
		_out_ + paChords[_a_[_j_][2]]
	next
	return _out_

func _FfNeighbour(paY, pnI, pnDir)
	_j_ = pnI + pnDir
	if _j_ < 1 or _j_ > len(paY)  return 0  ok
	return paY[_j_]

func _FfIndexNear(paT, pnV)
	_n_ = len(paT)
	_best_ = 1
	for _i_ = 2 to _n_
		if fabs(paT[_i_] - pnV) < fabs(paT[_best_] - pnV)  _best_ = _i_  ok
	next
	return _best_

# an index inside the samples, moved off a sample that is not finite
func _FfClampIndex(pnI, pnN, paX, paY)
	_i_ = pnI
	if _i_ < 1  _i_ = 1  ok
	if _i_ > pnN  _i_ = pnN  ok
	_k_ = 0
	while NOT (_FfFinite(paX[_i_]) and _FfFinite(paY[_i_])) and _k_ < pnN
		_i_++
		if _i_ > pnN  _i_ = 1  ok
		_k_++
	end
	return _i_

# nearest the middle of the range first, so a symmetric picture keeps its
# symmetric names when the cap bites
func _FfSortMarks(paMarks, pnMid)
	_a_ = []
	for _i_ = 1 to len(paMarks)  _a_ + [ fabs(paMarks[_i_][2] - pnMid), _i_ ]  next
	_a_ = sort(_a_, 1)
	_out_ = []
	for _i_ = 1 to len(_a_)  _out_ + paMarks[_a_[_i_][2]]  next
	return _out_

# a nice step: 1, 2, 2.5 or 5 times a power of ten, giving at most pnTicks
func _FfNiceStep(pnRange, pnTicks)
	if pnRange <= 0  return 1  ok
	_raw_ = pnRange / pnTicks
	_p_ = pow(10, floor(log10(_raw_)))
	_f_ = _raw_ / _p_
	if _f_ <= 1
		_s_ = 1
	but _f_ <= 2
		_s_ = 2
	but _f_ <= 2.5
		_s_ = 2.5
	but _f_ <= 5
		_s_ = 5
	else
		_s_ = 10
	ok
	return _s_ * _p_

# a number as a label: up to pnDec decimals, trailing zeros gone, no "-0"
func _FfNum(pn, pnDec)
	if NOT isNumber(pn)  return "" + pn  ok
	if fabs(pn) < 0.0000000001  return "0"  ok
	_cP_ = "" + (1 / 3)
	_nDot_ = StzFindFirst(".", _cP_)
	_nOld_ = 0
	if _nDot_ > 0  _nOld_ = len(_cP_) - _nDot_  ok
	decimals(pnDec)
	_c_ = "" + pn
	decimals(_nOld_)
	if StzFindFirst(".", _c_) > 0
		while StzRight(_c_, 1) = "0"
			_c_ = StzStringSection(_c_, 1, len(_c_) - 1)
		end
		if StzRight(_c_, 1) = "."
			_c_ = StzStringSection(_c_, 1, len(_c_) - 1)
		ok
	ok
	if _c_ = "-0"  _c_ = "0"  ok
	return _c_

# A TITLE'S BOX -- [ ascent, descent ] in px -- measured through the
# notation reader when the title carries notation (a stacked fraction is
# twice as tall as its type), estimated from the size when it does not.
# Every figure grows its top margin to hold it: at a fixed margin a
# stacked title ran 9 px off the canvas.
func _FfTitleBox(poFont, pcText, pnSize)
	if isObject(poFont) and StzHasNotation("" + pcText)
		_a_ = StzNotationRuns("" + pcText, pnSize, poFont)
		return [ _a_[3], _a_[4] ]
	ok
	return [ pnSize * 0.78, pnSize * 0.24 ]

# a label's width as it will be drawn, or seven pixels a character
func _FfTextWidth(poFont, pcText, pnSize)
	if isObject(poFont)  return poFont.WidthOf("" + pcText, pnSize)  ok
	return StzLen("" + pcText) * pnSize * 0.5

#---------------------------------------------------------------------#
#  THE STYLE -- data for everything that has no choice, a solve for    #
#  every name that has one                                             #
#---------------------------------------------------------------------#

func StzFunctionStyle()
	return StzFunctionStyleXT([ StzFunctionFigureDefaultSamples() ])

func StzFunctionStyleXT(panSizes)
	_o_ = new stzMathStyle()
	_o_.SetCanvas(StzFunctionFigureWidth(), StzFunctionFigureHeight())
	_o_.SetMargin(6)
	_nT_ = StzFunctionFigureTypeSize()
	# THE FRAME: a faint field, and the title centred over it
	_o_.ForAll("Frame f", [
		[ :shape, "f.box", :rect, [ :cx = "(f.x0 + f.x1) / 2", :cy = "(f.y0 + f.y1) / 2",
		                            :w = "f.x1 - f.x0", :h = "f.y1 - f.y0",
		                            :fill = [ :alpha, "primary", 0.05 ], :stroke = "muted", :strokeWidth = 1 ] ],
		[ :shape, "f.text", :text, [ :cx = "f.tx", :cy = "f.ty", :size = StzFunctionFigureTitleSize(),
		                             :fill = [ :on, "paper" ] ] ] ])
	# AN AXIS is one line with an arrow, its name past the arrow
	_o_.ForAll("Axis a", [
		[ :shape, "a.icon", :line, [ :x1 = "a.x0", :y1 = "a.y0", :x2 = "a.x1", :y2 = "a.y1",
		                             :stroke = "neutral", :strokeWidth = 1.5, :arrow = "end" ] ],
		[ :shape, "a.text", :text, [ :cx = "a.lx", :cy = "a.ly", :size = _nT_ + 2, :fill = "neutral" ] ] ])
	# A TICK is a cross-mark with its number: beneath it on the x axis, to
	# its left on the y axis -- the builder chose the place, the style draws
	_o_.ForAll("Tick k", [
		[ :shape, "k.icon", :line, [ :x1 = "k.x - k.dx", :y1 = "k.y - k.dy", :x2 = "k.x + k.dx", :y2 = "k.y + k.dy",
		                             :stroke = "neutral", :strokeWidth = 1 ] ],
		[ :shape, "k.text", :text, [ :cx = "k.lx", :cy = "k.ly", :size = _nT_, :fill = "muted" ] ] ])
	# A PIECE OF THE CURVE is one polyline of its samples: a spline whose
	# controls are the samples and whose spans carry no interpolated point
	_n_ = len(panSizes)
	for _i_ = 1 to _n_
		_k_ = panSizes[_i_]
		_aP_ = [ :n = _k_, :samples = 1, :stroke = "primary", :strokeWidth = 2.5 ]
		for _v_ = 1 to _k_
			_aP_ + [ "x" + _v_, "c.x" + _v_ ]
			_aP_ + [ "y" + _v_, "c.y" + _v_ ]
		next
		_o_.ForAllWhere("Curve c", "Pts" + _k_ + "(c)", [
			[ :shape, "c.icon", :spline, _aP_ ] ])
	next
	# A TANGENT is a line in the info colour, under the marks
	_o_.ForAll("Tangent t", [
		[ :shape, "t.icon", :line, [ :x1 = "t.x1", :y1 = "t.y1", :x2 = "t.x2", :y2 = "t.y2",
		                             :stroke = "info", :strokeWidth = 2 ] ] ])
	# A POLE is a faint vertical in the colour of a fault: the function is
	# not finite here, and the picture says so rather than joining across
	_o_.ForAll("Pole p", [
		[ :shape, "p.icon", :line, [ :x1 = "p.x", :y1 = "p.y0", :x2 = "p.x", :y2 = "p.y1",
		                             :stroke = [ :alpha, "danger", 0.55 ], :strokeWidth = 1.5 ] ] ])
	# A MARK is a dot on the curve, and four hidden chords of the curve
	# around it that its note must stay off
	_aRows_ = [
		[ :shape, "m.icon", :circle, [ :cx = "m.px", :cy = "m.py", :r = 5,
		                               :fill = "primary", :stroke = "background", :strokeWidth = 1.5 ] ] ]
	for _q_ = 1 to StzFunctionFigureChordsPerMark()
		_aRows_ + [ :shape, "m.k" + _q_, :line, [ :x1 = "m.k" + _q_ + "x1", :y1 = "m.k" + _q_ + "y1",
		                                          :x2 = "m.k" + _q_ + "x2", :y2 = "m.k" + _q_ + "y2", :hidden = 1 ] ]
	next
	_o_.ForAll("Mark m", _aRows_)
	# a zero is hollow; a point the author named is in the info colour
	_o_.ForAllWhere("Mark m", "Zero(m)", [
		[ :delete, "m.icon" ],
		[ :shape, "m.icon", :circle, [ :cx = "m.px", :cy = "m.py", :r = 5,
		                               :fill = "background", :stroke = "primary", :strokeWidth = 2 ] ] ])
	_o_.ForAllWhere("Mark m", "Given(m)", [
		[ :delete, "m.icon" ],
		[ :shape, "m.icon", :circle, [ :cx = "m.px", :cy = "m.py", :r = 5,
		                               :fill = "info", :stroke = "background", :strokeWidth = 1.5 ] ] ])
	# A NOTE IS SOLVED: near its mark, off the mark, off the curve's local
	# chords -- everything else it must avoid is bound in the rules below
	# A NOTE STARTS WHERE IT CAN END: its place is an OFFSET from its own
	# mark, two unknowns started in a band on the mark's free side (the
	# builder's datum: below a minimum, above anything else), so every
	# note begins inside its leash and relaxes from there. Started at
	# random on the paper, the same rules ran thirty-five penalty rounds
	# and stuck; started above a minimum, inside its bell, they stuck too.
	_aRows_ = [
		[ :unknown, "n.ox", -70, 70 ],
		[ :unknown, "n.oy", 16, 44 ],
		[ :shape, "n.text", :text, [ :cx = "m.px + n.ox", :cy = "m.py + m.side * n.oy",
		                             :size = _nT_, :fill = [ :on, "paper" ] ] ],
		[ :encourage, "near", [ "n.text", "m.icon", 26 ] ],
		[ :ensure, "lessThan", [ "dist(n.text, m.icon)", "" + StzFunctionFigureLeash() + " + n.text.w / 2" ] ],
		[ :ensure, "disjoint", [ "n.text", "m.icon", 5 ] ],
		[ :layer, "n.text", :above, "m.icon" ] ]
	for _q_ = 1 to StzFunctionFigureChordsPerMark()
		_aRows_ + [ :ensure, "disjoint", [ "n.text", "m.k" + _q_, 6 ] ]
	next
	_o_.ForAllWhere("Note n; Mark m", "n := Note(m)", _aRows_)
	_o_.ForAll("Note n; Axis a", [
		[ :ensure, "disjoint", [ "n.text", "a.icon", 6 ] ],
		[ :ensure, "disjoint", [ "n.text", "a.text", 4 ] ] ])
	_o_.ForAll("Note n; Tick k", [
		[ :ensure, "disjoint", [ "n.text", "k.text", 4 ] ] ])
	_o_.ForAll("Note n; Note p", [
		[ :ensure, "disjoint", [ "n.text", "p.text", 4 ] ] ])
	# a note stays INSIDE the frame, clear of its stroke, and off the title
	_o_.ForAll("Note n; Frame f", [
		[ :ensure, "contains", [ "f.box", "n.text", 5 ] ],
		[ :ensure, "disjoint", [ "n.text", "f.text", 6 ] ] ])
	_o_.ForAll("Note n; Tangent t", [
		[ :ensure, "disjoint", [ "n.text", "t.icon", 8 ] ] ])
	# and a note off every OTHER mark's dot
	_o_.ForAll("Note n; Mark q", [
		[ :ensure, "disjoint", [ "n.text", "q.icon", 4 ] ] ])
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE -- claims a drawing cannot show false  #
#---------------------------------------------------------------------#

func _FfIsFunctionFigure(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "function"

# the marks that carry a claim, by predicate, prefixed for the gate
func _FfScope(poDg, pcPredicate, pcPrefix)
	_r_ = []
	if NOT _FfIsFunctionFigure(poDg)  return _r_  ok
	_oS_ = poDg.Substance()
	_ac_ = _oS_.ObjectsOfType("Mark")
	for _i_ = 1 to len(_ac_)
		if _oS_.Holds(pcPredicate, [ _ac_[_i_] ])  _r_ + (pcPrefix + _ac_[_i_])  ok
	next
	return _r_

func _FfNoteScope(poDg, pcPrefix)
	_r_ = []
	if NOT _FfIsFunctionFigure(poDg)  return _r_  ok
	_ac_ = poDg.Substance().ObjectsOfType("Note")
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _FfCounter(poDg, pcPrefix)
	_r_ = []
	if NOT isObject(poDg) or _FfIsFunctionFigure(poDg)  return _r_  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return _r_  ok
	_ac_ = poDg.Substance().ObjectNames()
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func StzFunctionRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("zero_brackets_a_sign_change")
	_o1_.SetClaim("a mark named a zero stands between two samples of opposite sign")
	_o1_.SetOrder(70)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _FfScope(oDg, "Zero", "zero:") })
	_o1_.SetCounter(func(oDg) { return _FfCounter(oDg, "zero:") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cM_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_nL_ = _oS_.DataOf(_cM_, "yl")
		_nR_ = _oS_.DataOf(_cM_, "yr")
		if _nL_ * _nR_ > 0
			return [ FALSE, "the zero at x = " + _FfNum(_oS_.DataOf(_cM_, "x"), 4) +
				" stands between samples of the same sign, " + _FfNum(_nL_, 4) + " and " + _FfNum(_nR_, 4) ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("extremum_brackets_a_turn")
	_o2_.SetClaim("a mark named an extremum stands between two samples of opposite slope")
	_o2_.SetOrder(71)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) { return _FfScope(oDg, "Extremum", "extremum:") })
	_o2_.SetCounter(func(oDg) { return _FfCounter(oDg, "extremum:") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cM_ = StzStringSection(cSub, 10, len(cSub))
		_oS_ = oDg.Substance()
		_nL_ = _oS_.DataOf(_cM_, "yl")
		_nR_ = _oS_.DataOf(_cM_, "yr")
		if _nL_ * _nR_ >= 0
			return [ FALSE, "the extremum at x = " + _FfNum(_oS_.DataOf(_cM_, "x"), 4) +
				" stands between slopes that do not change sign, " + _FfNum(_nL_, 4) + " and " + _FfNum(_nR_, 4) ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	_o3_ = StzPlasticRule("note_reads_near_its_mark")
	_o3_.SetClaim("a note stands within reach of the mark it names")
	_o3_.SetOrder(72)
	_o3_.SetReads([ "picture" ])
	_o3_.SetScope(func(oDg) { return _FfNoteScope(oDg, "note:") })
	_o3_.SetCounter(func(oDg) { return _FfCounter(oDg, "note:") })
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cN_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_aD_ = _oS_.Definitions()
		_cM_ = ""
		for _i_ = 1 to len(_aD_)
			if _aD_[_i_][1] = _cN_  _cM_ = "" + _aD_[_i_][3][1]  ok
		next
		if _cM_ = ""  return [ TRUE, "" ]  ok
		_aT_ = oDg.ShapeOf(_cN_ + ".text")
		_aM_ = oDg.ShapeOf(_cM_ + ".icon")
		if len(_aT_) = 0 or len(_aM_) = 0  return [ TRUE, "" ]  ok
		_nD_ = sqrt(pow(_aT_[:cx] - _aM_[:cx], 2) + pow(_aT_[:cy] - _aM_[:cy], 2))
		_nR_ = StzFunctionFigureLeash() + _aT_[:w] / 2 + 1
		if _nD_ > _nR_
			return [ FALSE, "the note '" + _oS_.LabelOf(_cN_) + "' stands " + _FfNum(_nD_, 1) +
				" px from its mark, past its leash of " + _FfNum(_nR_, 1) ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o3_

	return _ao_
