#---------------------------------------------------------------------------#
#  STZNODESHAPE -- graphviz's node vocabulary, drawn on an stzCanvas         #
#---------------------------------------------------------------------------#
#
#     StzDrawNodeShape(oCanvas, :Hexagon, 100, 80, 120, 60)
#     ? StzNodeShapeNames()        # the 24 this speaks
#
# WHY THIS EXISTS. `stzDiagram` can only be SEEN by shelling out to
# dot.exe, which is why SOFTANZA_GRAPH_PLANE_PLAN.md section 3 refused to
# replace it "until GG1's kill criterion is actually met". GG1 met it. The
# remaining blocker was never layout -- it was that a diagram node can be
# any of twenty-four shapes and the canvas could draw three of them.
#
# Measured before building: of the 24, twenty are a CIRCLE, a RECT or a
# POLYGON, all of which stzCanvas already drew. The other four -- ellipse,
# egg, cylinder, doublecircle -- all needed ONE missing primitive, and so
# stzCanvas gained AddEllipse (engine-tessellated, both tiers agreeing by
# construction because the engine builds it as a polygon).
#
# So this file is a VOCABULARY, not a renderer. Every shape below is
# composed from primitives that already existed or from that single
# addition; nothing here draws pixels itself, which is why the SVG and PNG
# tiers cannot disagree about a shape.
#
# The box given is the shape's BOUNDING BOX (x, y = top-left), so a caller
# laying out nodes reasons in boxes and never in shape-specific geometry.

func StzNodeShapeNames()
	return [
		:Box, :Rect, :Square, :Circle, :DoubleCircle, :Ellipse, :Egg,
		:Diamond, :Triangle, :InvTriangle, :Trapezium, :InvTrapezium,
		:Parallelogram, :House, :InvHouse, :Pentagon, :Hexagon, :Septagon,
		:Octagon, :TripleOctagon, :Cylinder, :Folder, :Tab, :Note,
		:Component
	]

func StzIsNodeShape(pcName)
	_c_ = StzLower("" + pcName)
	for _s_ in StzNodeShapeNames()
		if StzLower("" + _s_) = _c_  return 1  ok
	next
	return 0

# Draw a shape AND say how it is painted, in one call.
#
# Prefer this over styling around StzDrawNodeShape. The canvas styles the
# PENDING shape, so `FillQ(c)` immediately after drawing an edge recolours
# THE EDGE and leaves the node with whatever default was in force -- which
# is how the first node of a diagram came out the wrong colour while every
# other node was right. Passing the paint in removes the ordering question
# instead of documenting it.
#
# pnStrokeW = 0 means no outline.
func StzDrawNodeShapeXT(poCanvas, pcShape, pnX, pnY, pnW, pnH, pcFill, pcStroke, pnStrokeW)
	if NOT isObject(poCanvas)
		StzRaise("StzDrawNodeShapeXT: give me a canvas to draw on.")
	ok
	poCanvas.Flush()                 # nothing pending -> these set DEFAULTS
	poCanvas.Fill(pcFill)
	if isNumber(pnStrokeW) and pnStrokeW > 0
		poCanvas.Stroke(pcStroke, pnStrokeW)
	ok
	return StzDrawNodeShape(poCanvas, pcShape, pnX, pnY, pnW, pnH)

# Draw one node shape into its bounding box. The canvas's CURRENT fill and
# stroke apply, exactly as they do for a bare AddRect -- a shape is not a
# style, and keeping those separate is what lets a diagram theme every
# shape the same way.
func StzDrawNodeShape(poCanvas, pcShape, pnX, pnY, pnW, pnH)
	if NOT isObject(poCanvas)
		StzRaise("StzDrawNodeShape: give me a canvas to draw on.")
	ok
	if NOT (isNumber(pnX) and isNumber(pnY) and isNumber(pnW) and isNumber(pnH))
		StzRaise("StzDrawNodeShape: the box is x, y, width, height in pixels.")
	ok
	if pnW <= 0 or pnH <= 0
		StzRaise("StzDrawNodeShape: a shape needs a box with area.")
	ok

	_c_ = StzLower("" + pcShape)
	if NOT StzIsNodeShape(_c_)
		StzRaise("StzDrawNodeShape: '" + _c_ + "' is not a node shape. " +
			"The vocabulary is: " + StzJoin(StzNodeShapeNames(), ", ") + ".")
	ok

	# FLUSH FIRST, AND FLUSH AGAIN AT THE END. stzCanvas.Fill documents
	# that "with a shape pending, Fill colours THAT shape" -- so a caller
	# writing the natural sequence
	#
	#     oC.FillQ(red)   StzDrawNodeShape(oC, :Box, ...)
	#     oC.FillQ(green) StzDrawNodeShape(oC, :Hexagon, ...)
	#
	# had every colour land on the PREVIOUS shape: box green, hexagon blue,
	# ellipse red. Measured exactly that way, three shapes, three sampled
	# pixels. A contact sheet HID it completely -- every shape still had
	# some colour, so the picture looked right while every binding was
	# wrong.
	#
	# Leaving nothing pending on both sides means Fill/Stroke around a call
	# set the canvas DEFAULTS, which is what the sequence above reads as.
	poCanvas.Flush()

	_x_ = pnX  _y_ = pnY  _w_ = pnW  _h_ = pnH
	_cx_ = _x_ + _w_ / 2
	_cy_ = _y_ + _h_ / 2

	switch _c_

	on "box"
		poCanvas.AddRect(_x_, _y_, _w_, _h_)
	on "rect"
		poCanvas.AddRect(_x_, _y_, _w_, _h_)
	on "square"
		# a square fits INSIDE the box, centred -- a caller who asked for a
		# square and got a rectangle would have to check every call site
		_s_ = min([_w_, _h_])
		poCanvas.AddRect(_cx_ - _s_ / 2, _cy_ - _s_ / 2, _s_, _s_)
	on "circle"
		poCanvas.AddCircle(_cx_, _cy_, min([_w_, _h_]) / 2)
	on "doublecircle"
		_r_ = min([_w_, _h_]) / 2
		poCanvas.AddCircle(_cx_, _cy_, _r_)
		poCanvas.AddCircle(_cx_, _cy_, _r_ * 0.82)
	on "ellipse"
		poCanvas.AddEllipse(_cx_, _cy_, _w_ / 2, _h_ / 2)
	on "egg"
		# graphviz's egg is an ellipse fatter at the bottom. Drawn as a
		# polygon from the ellipse equation with the radius modulated by
		# height, because an egg is not composable from two ellipses
		# without a visible seam where they meet.
		_p_ = []
		for _i_ = 0 to 47
			_t_ = 2 * 3.141592653589793 * _i_ / 48
			_sy_ = sin(_t_)
			_k_ = 1 + 0.18 * _sy_
			_p_ + (_cx_ + (_w_ / 2) * cos(_t_) * _k_)
			_p_ + (_cy_ + (_h_ / 2) * _sy_)
		next
		poCanvas.AddPolygon(_p_)
	on "diamond"
		poCanvas.AddPolygon([ _cx_, _y_, _x_ + _w_, _cy_, _cx_, _y_ + _h_, _x_, _cy_ ])
	on "triangle"
		poCanvas.AddPolygon([ _cx_, _y_, _x_ + _w_, _y_ + _h_, _x_, _y_ + _h_ ])
	on "invtriangle"
		poCanvas.AddPolygon([ _x_, _y_, _x_ + _w_, _y_, _cx_, _y_ + _h_ ])
	on "trapezium"
		_i_ = _w_ * 0.22
		poCanvas.AddPolygon([ _x_ + _i_, _y_, _x_ + _w_ - _i_, _y_,
			_x_ + _w_, _y_ + _h_, _x_, _y_ + _h_ ])
	on "invtrapezium"
		_i_ = _w_ * 0.22
		poCanvas.AddPolygon([ _x_, _y_, _x_ + _w_, _y_,
			_x_ + _w_ - _i_, _y_ + _h_, _x_ + _i_, _y_ + _h_ ])
	on "parallelogram"
		_i_ = _w_ * 0.2
		poCanvas.AddPolygon([ _x_ + _i_, _y_, _x_ + _w_, _y_,
			_x_ + _w_ - _i_, _y_ + _h_, _x_, _y_ + _h_ ])
	on "house"
		_r_ = _h_ * 0.35
		poCanvas.AddPolygon([ _cx_, _y_, _x_ + _w_, _y_ + _r_,
			_x_ + _w_, _y_ + _h_, _x_, _y_ + _h_, _x_, _y_ + _r_ ])
	on "invhouse"
		_r_ = _h_ * 0.35
		poCanvas.AddPolygon([ _x_, _y_, _x_ + _w_, _y_,
			_x_ + _w_, _y_ + _h_ - _r_, _cx_, _y_ + _h_, _x_, _y_ + _h_ - _r_ ])
	on "pentagon"
		poCanvas.AddPolygon(_StzRegularPoly(_cx_, _cy_, _w_ / 2, _h_ / 2, 5, -90))
	on "hexagon"
		poCanvas.AddPolygon([ _x_ + _w_ * 0.25, _y_, _x_ + _w_ * 0.75, _y_,
			_x_ + _w_, _cy_, _x_ + _w_ * 0.75, _y_ + _h_,
			_x_ + _w_ * 0.25, _y_ + _h_, _x_, _cy_ ])
	on "septagon"
		poCanvas.AddPolygon(_StzRegularPoly(_cx_, _cy_, _w_ / 2, _h_ / 2, 7, -90))
	on "octagon"
		poCanvas.AddPolygon(_StzRegularPoly(_cx_, _cy_, _w_ / 2, _h_ / 2, 8, -112.5))
	on "tripleoctagon"
		poCanvas.AddPolygon(_StzRegularPoly(_cx_, _cy_, _w_ / 2, _h_ / 2, 8, -112.5))
		poCanvas.AddPolygon(_StzRegularPoly(_cx_, _cy_, _w_ * 0.42, _h_ * 0.42, 8, -112.5))
		poCanvas.AddPolygon(_StzRegularPoly(_cx_, _cy_, _w_ * 0.34, _h_ * 0.34, 8, -112.5))
	on "cylinder"
		# a database: a body with an elliptical cap. The cap is drawn LAST
		# so it sits on top of the body rather than being covered by it.
		_ry_ = _h_ * 0.13
		poCanvas.AddRect(_x_, _y_ + _ry_, _w_, _h_ - 2 * _ry_)
		poCanvas.AddEllipse(_cx_, _y_ + _h_ - _ry_, _w_ / 2, _ry_)
		poCanvas.AddEllipse(_cx_, _y_ + _ry_, _w_ / 2, _ry_)
	on "folder"
		_t_ = _h_ * 0.16
		poCanvas.AddPolygon([ _x_, _y_ + _t_, _x_ + _w_ * 0.4, _y_ + _t_,
			_x_ + _w_ * 0.47, _y_, _x_ + _w_, _y_,
			_x_ + _w_, _y_ + _h_, _x_, _y_ + _h_ ])
	on "tab"
		_t_ = _h_ * 0.18
		poCanvas.AddPolygon([ _x_, _y_, _x_ + _w_ * 0.38, _y_,
			_x_ + _w_ * 0.38, _y_ + _t_, _x_ + _w_, _y_ + _t_,
			_x_ + _w_, _y_ + _h_, _x_, _y_ + _h_ ])
	on "note"
		_f_ = min([_w_, _h_]) * 0.24
		poCanvas.AddPolygon([ _x_, _y_, _x_ + _w_ - _f_, _y_,
			_x_ + _w_, _y_ + _f_, _x_ + _w_, _y_ + _h_, _x_, _y_ + _h_ ])
	on "component"
		poCanvas.AddRect(_x_ + _w_ * 0.1, _y_, _w_ * 0.9, _h_)
		poCanvas.AddRect(_x_, _y_ + _h_ * 0.18, _w_ * 0.22, _h_ * 0.2)
		poCanvas.AddRect(_x_, _y_ + _h_ * 0.62, _w_ * 0.22, _h_ * 0.2)
	off

	# and leave nothing pending, so the caller's NEXT Fill/Stroke sets
	# defaults instead of recolouring the last primitive drawn here
	poCanvas.Flush()
	return 1

# A regular n-gon inscribed in the box, first vertex at pnStartDeg. Kept
# private: a caller wants "hexagon", not a vertex count.
func _StzRegularPoly(pnCX, pnCY, pnRX, pnRY, pnSides, pnStartDeg)
	_a_ = []
	_st_ = pnStartDeg * 3.141592653589793 / 180
	for _i_ = 0 to pnSides - 1
		_t_ = _st_ + 2 * 3.141592653589793 * _i_ / pnSides
		_a_ + (pnCX + pnRX * cos(_t_))
		_a_ + (pnCY + pnRY * sin(_t_))
	next
	return _a_
