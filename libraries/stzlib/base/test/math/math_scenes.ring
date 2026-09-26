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

#-- M1b: the :NumberLine and :Fraction figures ----------------------------

# a number line a child reads: four numbers placed, one of them named, and
# a jump of three from 2 to 5
func StzMathFigScene08()
	return StzMathFigureQ(:NumberLine, [ :on = [ -5, 10 ], :points = [ 3, -2, 7.5, [ 0.5, "half" ] ],
		:jumps = [ [ 2, 5 ] ], :label = "the numbers from -5 to 10, and 2 + 3" ])

# a backward jump: 9 - 5 lands on 4
func StzMathFigScene09()
	return StzMathFigureQ(:NumberLine, [ :on = [ 0, 12 ], :jumps = [ [ 9, 4 ] ], :step = 1,
		:label = "9 - 5 = 4" ])

# three of four, as a bar
func StzMathFigScene10()
	return StzMathFigureQ(:Fraction, [ :of = [ 3, 4 ], :label = "three of four" ])

# four fractions compared as bars: 2/4 and 1/2 END at the same place
func StzMathFigScene11()
	return StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 4 ], [ 2, 3 ], [ 2, 4 ], [ 1, 2 ] ],
		:label = "which is more?" ])

# three of eight and one of four, as discs
func StzMathFigScene12()
	return StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 8 ], [ 1, 4 ] ], :as = :disc,
		:label = "three of eight, one of four" ])

# THE NUMBER LINE WITNESS: the jump's difference tampered, and a point's
# place moved past its neighbour -- the rules must find both
func StzMathFigNumberLineWitness()
	_o_ = StzMathFigScene08()
	_o_.Layout()
	_o_.SetDatum("j1", "d", 4)
	_oS_ = _o_.Substance()
	_o_.SetDatum("p3", "x", _oS_.DataOf("p4", "x") + 30)
	return _o_

# THE FRACTION WITNESS: the numerator's datum says two while three parts
# are shaded, the denominator's says five while four are cut
func StzMathFigFractionWitness()
	_o_ = StzMathFigScene10()
	_o_.Layout()
	_o_.SetDatum("w1", "n", 2)
	_o_.SetDatum("w1", "d", 5)
	return _o_

#-- M1c: the :Matrix and :ComplexPlane figures ------------------------------

# scene 30's product, with row 2 of A against column 2 of B lit
func StzMathFigScene15()
	return StzMathFigureQ(:Matrix, [ :product = [ [ [ 2, 7, 1, 8 ], [ 2, 8, 1, 8 ], [ 2, 8, 4, 5 ] ],
		[ [ 9, 0, 4 ], [ 5, 2, 3 ], [ 5, 3, 6 ], [ 0, 2, 8 ] ] ], :show = [ 2, 2 ],
		:label = "how a cell of a product is made" ])

# a matrix as heat: a band, seen before any number is read
func StzMathFigScene16()
	return StzMathFigureQ(:Matrix, [ :of = [ [ 4, 1, 0, 0, 0 ], [ 1, 4, 1, 0, 0 ], [ 0, 1, 4, 1, 0 ],
		[ 0, 0, 1, 4, 1 ], [ 0, 0, 0, 1, 4 ] ], :as = :heat, :names = [ "T" ], :label = "a band matrix, on one ramp" ])

# the three cube roots of one, on the unit circle
func StzMathFigScene17()
	return StzMathFigureQ(:ComplexPlane, [ :roots = [ 1, 0, 0, -1 ], :unit = TRUE,
		:label = "the roots of z^3 = 1" ])

# a number shown with its modulus and argument
func StzMathFigScene18()
	return StzMathFigureQ(:ComplexPlane, [ :points = [ [ 3, 2, "z" ], [ 3, -2, "conj z" ] ], :show = [ 3, 2 ],
		:label = "z = 3 + 2i: its length and its angle" ])

# THE MATRIX WITNESS: a product cell tampered, and B's rows misstated
func StzMathFigMatrixWitness()
	_o_ = StzMathFigScene15()
	_o_.Layout()
	_o_.SetDatum("c2_2", "v", 999)
	_o_.SetDatum("g2", "rows", 5)
	return _o_

# THE COMPLEX WITNESS: a root moved off its place -- it is no root and it
# has no mirror
func StzMathFigComplexWitness()
	_o_ = StzMathFigScene17()
	_o_.Layout()
	_oS_ = _o_.Substance()
	_ac_ = _oS_.ObjectsOfType("Point")
	_cP_ = ""
	for _i_ = 1 to len(_ac_)
		if _cP_ = "" and _oS_.DataOf(_ac_[_i_], "im") > 0.1  _cP_ = _ac_[_i_]  ok
	next
	_o_.SetDatum(_cP_, "re", _oS_.DataOf(_cP_, "re") + 0.3)
	return _o_

#-- M1d: the :BoxPlot and :Surface figures ---------------------------------

# one group with an outlier, its five numbers written
func StzMathFigScene21()
	return StzMathFigureQ(:BoxPlot, [ :of = [ 2, 4, 4, 5, 7, 9, 12, 25 ], :label = "eight values, one of them alone" ])

# three groups on one axis, so their boxes compare
func StzMathFigScene22()
	return StzMathFigureQ(:BoxPlot, [ :groups = [ [ "morning", [ 12, 15, 14, 18, 16, 15, 13, 40 ] ],
		[ "noon", [ 20, 22, 25, 21, 23, 24, 22, 26 ] ], [ "evening", [ 8, 30, 12, 28, 10, 26, 14, 24 ] ] ],
		:label = "three groups of eight" ])

# a saddle, seen from the usual corner
func StzMathFigScene23()
	return StzMathFigureQ(:Surface, [ :f = "x^2 - y^2", :x = [ -1, 1 ], :y = [ -1, 1 ], :samples = 20,
		:label = "z = x^2 - y^2" ])

# a ripple, denser
func StzMathFigScene24()
	return StzMathFigureQ(:Surface, [ :f = "sin(3 * sqrt(x^2 + y^2)) / (1 + x^2 + y^2)", :x = [ -3, 3 ], :y = [ -3, 3 ],
		:samples = 24, :view = [ -35, 38 ], :label = "a ripple" ])

# THE BOX PLOT WITNESS: the median datum moved past Q3, and an outlier's
# value moved inside the fences
func StzMathFigBoxPlotWitness()
	_o_ = StzMathFigScene21()
	_o_.Layout()
	_o_.SetDatum("b1", "med", 20)
	_o_.SetDatum("o1", "v", 6)
	return _o_

# THE SURFACE WITNESS: one corner's z tampered
func StzMathFigSurfaceWitness()
	_o_ = StzMathFigScene23()
	_o_.Layout()
	_o_.SetDatum("fr", "z1_1", 7)
	return _o_

#-- M1 notation: the labels the reader is held to, and three scenes ---------

# THE LABELS the notation reader is held to, byte for byte: the probe
# writes their runs to base/test/math/expect/notation.txt and the gate
# compares. Sixteen from before the reader moved here, ten from its growth.
func StzMathNotationLabels()
	return [ "$\alpha$", "$\alpha^2 + \beta_1$", "$x^{n+1}$", "$\sum_{i=1}^{n} x_i$", "$e^{i\pi} + 1 = 0$",
	         "$\Omega \subseteq \Gamma$", "$a \le b \ne c$", "$\int f \, dx$", "$\nabla \cdot F$", "$x_{i_j}$",
	         "$\sqrt{2}$", "plain text", "$\frac{1}{2}$", "$\levitate$", "$x^{y^{z^{w}}}$", "$\infty$",
	         "$\frac{a+b}{2}$", "$\frac{1}{\frac{1}{x}}$", "$\sqrt{x^2 + 1}$", "$\prod^{n}_{k=1} k$", "$\matrix{1, 2; 3, 4}$",
	         "$\matrix{a, b, c}$", "$\frac{1}$", "$\matrix{1, 2; 3}$", "$\matrix{1, ; 3, 4}$", "$\sqrt$" ]

# every label as runs and a box, or its refusal -- one line each
func StzMathNotationProbeText(poFont)
	_ac_ = StzMathNotationLabels()
	_c_ = ""
	for _i_ = 1 to len(_ac_)
		_l_ = _ac_[_i_]
		_cOut_ = "[" + _i_ + "] " + _l_ + " -> has=" + StzHasNotation(_l_)
		try
			_a_ = StzNotationRuns(_l_, 20, poFont)
			_cOut_ += " w=" + _a_[2] + " asc=" + _a_[3] + " desc=" + _a_[4] + " runs=" + @@(_a_[1])
		catch
			_cOut_ += " REFUSED: " + StzLeft(StzReplace(cCatchError, char(10), " "), 90)
		done
		_c_ += _cOut_ + char(10)
	next
	_c_ += "symbol(alpha)=" + StzNotationSymbol("alpha") + " symbol(zzz)=[" + StzNotationSymbol("zzz") + "]" + char(10)
	return _c_

# fractions and a root as the names of points on a line
func StzMathFigScene27()
	return StzMathFigureQ(:NumberLine, [ :on = [ 0, 2 ], :points = [ [ 0.5, "$\frac{1}{2}$" ], [ 0.25, "$\frac{1}{4}$" ],
		[ 1.5, "$\frac{3}{2}$" ], [ 1.4142, "$\sqrt{2}$" ] ], :label = "fractions and a root, named on the line" ])

# a title with a stacked fraction and a sum with its limits
func StzMathFigScene28()
	return StzMathFigureQ(:Function, [ :f = "sin(x) / x", :on = [ -12, 12 ], :mark = [ :extrema ],
		:label = "$y = \frac{sin x}{x}$    and    $\sum_{k=1}^{n} \frac{1}{k^2} \to \frac{\pi^2}{6}$" ])

# a matrix named in its title
func StzMathFigScene29()
	return StzMathFigureQ(:Matrix, [ :of = [ [ 1, 2 ], [ 3, 4 ] ], :label = "$A = \matrix{1, 2; 3, 4}$" ])

func StzMathFigSceneCount()
	return 29

func StzMathFigSceneTitles()
	return [ "THE CARDINAL SINE                (zeros at every multiple of pi, extrema where tan x = x; twelve notes solved)",
	         "A CUBIC WITH ITS TANGENT         (three zeros, two extrema, the tangent at 1.2 clipped to the window)",
	         "A LISSAJOUS FIGURE               (parametric: x = cos t, y = sin 2t; two points named by their t)",
	         "A THREE-PETAL ROSE               (polar: r = cos 3t; nothing to solve)",
	         "A HYPERBOLA WITH ITS POLE        (y = 1/x breaks at 0; the window bounds it; nothing to solve)",
	         "THE TANGENT FUNCTION             (three pieces; the sign change across a pole is NOT a zero)",
	         "THE WITNESS, THREE THINGS WRONG  (a zero between same-sign samples, an extremum with no turn, a note out of reach)",
	         "A NUMBER LINE                    (M1b: four numbers placed, one named, and 2 + 3 as a jump; notes solved)",
	         "A BACKWARD JUMP                  (9 - 5 lands on 4; the arc reads leftwards)",
	         "THREE OF FOUR                    (a fraction as a bar: three shaded parts of four equal ones -- count them)",
	         "WHICH IS MORE?                   (four bars share one width, so 2/4 and 1/2 end at the same pixel; verdicts cross-multiplied)",
	         "THREE OF EIGHT, ONE OF FOUR      (as discs: wedges are polygons from the centre round the rim)",
	         "THE NUMBER LINE, TWO THINGS WRONG (a jump printing + 4 that lands 3 away, a point drawn past its neighbour)",
	         "THE FRACTION, TWO THINGS WRONG   (a numerator of two over three shaded parts, a denominator of five over four cut)",
	         "HOW A CELL OF A PRODUCT IS MADE  (M1c: A . B = C with row 2 of A and column 2 of B lit, and the cell they make)",
	         "A BAND MATRIX, ON ONE RAMP       (heat: every cell coloured by its value; the band shows before a number is read)",
	         "THE ROOTS OF z^3 = 1             (three hollow points on the unit circle, found by the engine, checked by Horner)",
	         "z = 3 + 2i                       (its ray with |z| and its argument arc, and its conjugate below)",
	         "THE MATRIX, TWO THINGS WRONG     (a product cell of 999, and B said to have five rows)",
	         "THE ROOT THAT IS NOT ONE         (a root moved 0.3 to the right: the polynomial is not small there, and it has no mirror)",
	         "EIGHT VALUES, ONE ALONE          (M1d: a box plot with its five numbers solved apart, and the outlier past the fence)",
	         "THREE GROUPS OF EIGHT            (three boxes on one axis; the evening's box is wide, the noon's narrow)",
	         "A SADDLE                         (z = x^2 - y^2 projected by the engine's camera, drawn as a wireframe on the vector tier)",
	         "A RIPPLE                         (24 x 24 samples, lines coloured by their height on one ramp)",
	         "THE BOX PLOT, TWO THINGS WRONG   (a median past Q3, an outlier inside the fences)",
	         "THE SURFACE, ONE THING WRONG     (a corner's z that the function does not give)",
	         "FRACTIONS ON THE LINE            (M1 notation: 1/2, 1/4, 3/2 stacked and sqrt 2 with its bar, as names of points)",
	         "A TITLE WITH A FRACTION AND A SUM (sin x over x, and the sum of 1/k^2 with its limits stacked on the sign)",
	         "A MATRIX IN A TITLE              (a 2 x 2 between brackets scaled to it, as notation, beside the same matrix as cells)" ]

func StzMathFigScene(pnI)
	if pnI = 1  return StzMathFigScene01()  ok
	if pnI = 2  return StzMathFigScene02()  ok
	if pnI = 3  return StzMathFigScene03()  ok
	if pnI = 4  return StzMathFigScene04()  ok
	if pnI = 5  return StzMathFigScene05()  ok
	if pnI = 6  return StzMathFigScene06()  ok
	if pnI = 7  return StzMathFigWitness()  ok
	if pnI = 8  return StzMathFigScene08()  ok
	if pnI = 9  return StzMathFigScene09()  ok
	if pnI = 10  return StzMathFigScene10()  ok
	if pnI = 11  return StzMathFigScene11()  ok
	if pnI = 12  return StzMathFigScene12()  ok
	if pnI = 13  return StzMathFigNumberLineWitness()  ok
	if pnI = 14  return StzMathFigFractionWitness()  ok
	if pnI = 15  return StzMathFigScene15()  ok
	if pnI = 16  return StzMathFigScene16()  ok
	if pnI = 17  return StzMathFigScene17()  ok
	if pnI = 18  return StzMathFigScene18()  ok
	if pnI = 19  return StzMathFigMatrixWitness()  ok
	if pnI = 20  return StzMathFigComplexWitness()  ok
	if pnI = 21  return StzMathFigScene21()  ok
	if pnI = 22  return StzMathFigScene22()  ok
	if pnI = 23  return StzMathFigScene23()  ok
	if pnI = 24  return StzMathFigScene24()  ok
	if pnI = 25  return StzMathFigBoxPlotWitness()  ok
	if pnI = 26  return StzMathFigSurfaceWitness()  ok
	if pnI = 27  return StzMathFigScene27()  ok
	if pnI = 28  return StzMathFigScene28()  ok
	return StzMathFigScene29()
