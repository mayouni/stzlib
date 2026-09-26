# THE MATHEMATICS-PLANE SCENES, AS FUNCTIONS TWO FILES SHARE.
#
# The catalogue renders them; the gate holds them to their claims. Written
# once, here, for the reason gg_math_scenes gives: a family written in two
# places drifts. Functions only: loading this file draws nothing.
#
# Every scene is a FIGURE (base/math/stzMathFigure.ring): a declaration the
# engine computes and the diagram solver places. The font is the house one,
# found by the figure itself.

#-- M1a: the :Function figure --------------------------------------------

# the cardinal sine: zeros at every multiple of pi, extrema where tan x = x
func StzMathFigScene01()
	return StzMathFigureQ(:Function, [ :f = "sin(x) / x", :on = [ -12, 12 ],
		:mark = [ :zeros, :extrema ], :label = "y = sin(x) / x" ])

# a cubic with its three zeros, two extrema, and the tangent at 1.2
func StzMathFigScene02()
	return StzMathFigureQ(:Function, [ :f = "x^3 - x", :on = [ -1.6, 1.6 ],
		:mark = [ :zeros, :extrema ], :tangent = 1.2, :label = "y = x^3 - x" ])

# a Lissajous figure, parametric, two points of it named by their t
func StzMathFigScene03()
	return StzMathFigureQ(:Function, [ :x = "cos(t)", :y = "sin(2*t)", :t = [ 0, 6.2832 ],
		:mark = [ 0, 1.5708 ], :label = "x = cos t, y = sin 2t" ])

# a three-petal rose, polar
func StzMathFigScene04()
	return StzMathFigureQ(:Function, [ :r = "cos(3*t)", :t = [ 0, 3.1416 ],
		:label = "r = cos 3t" ])

# a hyperbola with its pole: the curve breaks, and the window bounds it
func StzMathFigScene05()
	return StzMathFigureQ(:Function, [ :f = "1 / x", :on = [ -2, 2 ],
		:window = [ -6, 6 ], :label = "y = 1 / x" ])

# the tangent function: three pieces, and only its true zeros marked --
# the sign change across each pole is NOT a zero
func StzMathFigScene06()
	return StzMathFigureQ(:Function, [ :f = "tan(x)", :on = [ -4.5, 4.5 ],
		:window = [ -4, 4 ], :mark = [ :zeros ], :label = "y = tan x" ])

# THE WITNESS: the cardinal sine with three things made wrong AFTER the
# build, each a claim the drawing cannot show to be false -- a zero whose
# bracketing samples have the same sign, an extremum whose bracketing
# slopes do not turn, and a note dragged out of reach of its mark. The
# figure's own rules must find all three.
func StzMathFigWitness()
	_o_ = StzMathFigScene01()
	_oS_ = _o_.Substance()
	_cZ_ = ""  _cE_ = ""
	_ac_ = _oS_.ObjectsOfType("Mark")
	for _i_ = 1 to len(_ac_)
		if _cZ_ = "" and _oS_.Holds("Zero", [ _ac_[_i_] ])  _cZ_ = _ac_[_i_]  ok
		if _cE_ = "" and _oS_.Holds("Extremum", [ _ac_[_i_] ])  _cE_ = _ac_[_i_]  ok
	next
	# through the FIGURE: Ring hands back a copy when a method returns an
	# object, and a witness that tampered a copy found nothing
	_o_.SetDatum(_cZ_, "yl", 0.5)
	_o_.SetDatum(_cZ_, "yr", 0.7)
	_o_.SetDatum(_cE_, "yl", 0.3)
	_o_.SetDatum(_cE_, "yr", 0.2)
	_o_.Layout()
	# the first note, held two hundred pixels above its solved place --
	# through its offsets, since a note's centre is derived from its mark
	_aT_ = _o_.ShapeOf("n1.text")
	_o_.MoveNoteTo("n1", _aT_[:cx], _aT_[:cy] - 200)
	return _o_

# the names the witness tampered with, for the gate to assert against
func StzMathFigWitnessMarks(poFigure)
	_oS_ = poFigure.Substance()
	_cZ_ = ""  _cE_ = ""
	_ac_ = _oS_.ObjectsOfType("Mark")
	for _i_ = 1 to len(_ac_)
		if _cZ_ = "" and _oS_.Holds("Zero", [ _ac_[_i_] ])  _cZ_ = _ac_[_i_]  ok
		if _cE_ = "" and _oS_.Holds("Extremum", [ _ac_[_i_] ])  _cE_ = _ac_[_i_]  ok
	next
	return [ _cZ_, _cE_ ]

func StzMathFigSceneCount()
	return 7

func StzMathFigSceneTitles()
	return [ "THE CARDINAL SINE                (zeros at every multiple of pi, extrema where tan x = x; twelve notes solved)",
	         "A CUBIC WITH ITS TANGENT         (three zeros, two extrema, the tangent at 1.2 clipped to the window)",
	         "A LISSAJOUS FIGURE               (parametric: x = cos t, y = sin 2t; two points named by their t)",
	         "A THREE-PETAL ROSE               (polar: r = cos 3t; nothing to solve)",
	         "A HYPERBOLA WITH ITS POLE        (y = 1/x breaks at 0; the window bounds it; nothing to solve)",
	         "THE TANGENT FUNCTION             (three pieces; the sign change across a pole is NOT a zero)",
	         "THE WITNESS, THREE THINGS WRONG  (a zero between same-sign samples, an extremum with no turn, a note out of reach)" ]

func StzMathFigScene(pnI)
	if pnI = 1  return StzMathFigScene01()  ok
	if pnI = 2  return StzMathFigScene02()  ok
	if pnI = 3  return StzMathFigScene03()  ok
	if pnI = 4  return StzMathFigScene04()  ok
	if pnI = 5  return StzMathFigScene05()  ok
	if pnI = 6  return StzMathFigScene06()  ok
	return StzMathFigWitness()
