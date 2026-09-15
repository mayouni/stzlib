load "../../stzBase.ring"
decimals(2)

# GE10b -- A GALLERY OF FLOWS, TO BE JUDGED AGAINST THE BEST.
#
# Eight classic vector fields and one density study, drawn the way this
# plane draws a flow: evenly-spaced streamlines whose stroke thickens with
# speed, in blue, with red heads along them.
#
# TWO INKS BECAUSE THERE ARE TWO STATEMENTS. The line says WHERE the flow
# goes; the head says WHICH WAY. A reader separates them faster when the
# ink does, and the path is the quiet layer while the direction is the loud
# one.
#
# THE FIELDS ARE THE ONES EVERY TEXTBOOK USES, which is the point: a reader
# who knows what a saddle or a dipole is supposed to look like can see at a
# glance whether this draws one. An invented field proves nothing, because
# nobody knows what it should look like.
#
# THEY SIT NEAR THE EQUATOR ON PURPOSE. The integrator divides the eastward
# component by cos(latitude), because a degree of longitude is not a degree
# of ground -- correct for a map and a distortion for an abstract plot. At
# 15 degrees that factor is 0.966, so the shapes read as the textbook ones
# to within three per cent, and the choice is stated rather than hidden.

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")

# a plain rectangular frame: an equirectangular fitted to the box IS the
# Cartesian plane, which is what these fields live on
nSpan = 15
nGrid = 61
nStep = 2 * nSpan / (nGrid - 1)

aFields = [
	[ "Two gyres, as ARROWS", "what is happening HERE -- length and colour both carry speed" ],
	[ "Saddle",           "u = x, v = -y: flow in on one axis, out on the other" ],
	[ "Source and sink",  "a dipole -- everything leaves one and arrives at the other" ],
	[ "Vortex pair",      "two opposite rotations; the pair drifts as one" ],
	[ "Shear jet",        "u = sech-squared(y): fast in the middle, still at the edges" ],
	[ "Past a cylinder",  "uniform flow with a circle in it -- potential flow" ],
	[ "Spiral",           "a source and a vortex at once" ],
	[ "Four cells",       "a doubly periodic field, which closes on itself everywhere" ]
]

nCols = 4
nCell = 290
nPadX = 18
nPadY = 74
nRows = 2

oC = new stzCanvas(nCols * (nCell + nPadX) + 60, nRows * (nCell + nPadY) + 640)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 26).AddTextQ("Eight flows, drawn the same way", 40, 50).Fill("#1A1A1A")
oC.Flush()
oC.SetFontQ(oFont, 14).AddTextQ("evenly-spaced streamlines, the stroke thickening with " +
	"speed AND darkening with it, red for the direction", 40, 74).Fill("#777777")
oC.Flush()
oC.SetFontQ(oFont, 13).AddTextQ("these are the fields every textbook uses -- a reader " +
	"who knows what a saddle looks like can see at once whether this draws one",
	40, 96).Fill("#888888")
oC.Flush()

nY0 = 152
for f = 1 to len(aFields)
	nCol = ((f - 1) % nCols)
	nRow = floor((f - 1) / nCols)
	nX = 40 + nCol * (nCell + nPadX)
	nY = nY0 + nRow * (nCell + nPadY)

	oC.AddRectQ(nX, nY, nCell, nCell).FillQ("#FBFCFD").Stroke("#E0E4E8", 1)
	oC.Flush()

	oP = new stzGeoProjection(:Equirectangular)
	oP.FitPointsIn([ -nSpan, -nSpan, nSpan, nSpan ], nX, nY, nX + nCell, nY + nCell, 2)
	oM = StzGeoMap(oP, _Dummy())
	oM.SetPaper(nX, nY, nX + nCell, nY + nCell)

	aG = [ -nSpan, -nSpan, nStep, nStep, nGrid, nGrid ]
	aUV = _FieldOf(f, nSpan, nGrid, nStep)
	if f = 1
		# THE SAME FIELD AS ARROWS, once, so the two forms can be compared
		# on one sheet. Arrows answer "what is happening HERE" and
		# streamlines answer "where does this GO", and a reader who has
		# only ever seen one of them cannot tell which question they need.
		n = oM.DrawVectorsRampedOn(oC, aG, aUV[1], aUV[2], 3, 13, :Flow, 1.1)
	else
		n = oM.DrawFlowRampedOnXT(oC, aG, aUV[1], aUV[2], 1.35, :Flow, "#C0392B", 0.5, 2.2, 600)
	ok

	oC.SetFontQ(oFont, 14).AddTextQ(aFields[f][1], nX, nY - 24).Fill("#1A1A1A")
	oC.Flush()
	oC.SetFontQ(oFont, 10).AddTextQ(aFields[f][2], nX, nY - 10).Fill("#999999")
	oC.Flush()
	cWhat = " lines"
	if f = 1  cWhat = " arrows"  ok
	oC.SetFontQ(oFont, 10).AddTextQ("" + n + cWhat, nX, nY + nCell + 14).Fill("#AAAAAA")
	oC.Flush()
next

# ---- the density study ---------------------------------------------------
nY1 = nY0 + nRows * (nCell + nPadY) + 20
oC.SetFontQ(oFont, 19).AddTextQ("How dense should it be?", 40, nY1).Fill("#1A1A1A")
oC.Flush()
oC.SetFontQ(oFont, 13).AddTextQ("one field at four separations. The spacing is a " +
	"parameter, not an accident -- which is the whole point of drawing them evenly",
	40, nY1 + 22).Fill("#777777")
oC.Flush()

aSeps = [ 3.2, 2.0, 1.3, 0.85 ]
nY2 = nY1 + 46
for k = 1 to len(aSeps)
	nX = 40 + (k - 1) * (nCell + nPadX)
	oC.AddRectQ(nX, nY2, nCell, nCell).FillQ("#FBFCFD").Stroke("#E0E4E8", 1)
	oC.Flush()
	oP = new stzGeoProjection(:Equirectangular)
	oP.FitPointsIn([ -nSpan, -nSpan, nSpan, nSpan ], nX, nY2, nX + nCell, nY2 + nCell, 2)
	oM = StzGeoMap(oP, _Dummy())
	oM.SetPaper(nX, nY2, nX + nCell, nY2 + nCell)
	aG = [ -nSpan, -nSpan, nStep, nStep, nGrid, nGrid ]
	aUV = _FieldOf(4, nSpan, nGrid, nStep)
	n = oM.DrawFlowRampedOnXT(oC, aG, aUV[1], aUV[2], aSeps[k], :Flow, "#C0392B", 0.5, 2.2, 900)
	oC.SetFontQ(oFont, 13).AddTextQ("separation " + aSeps[k] + " degrees", nX, nY2 - 12).Fill("#1A1A1A")
	oC.Flush()
	oC.SetFontQ(oFont, 10).AddTextQ("" + n + " lines", nX, nY2 + nCell + 14).Fill("#AAAAAA")
	oC.Flush()
next

oC.SetFontQ(oFont, 12).AddTextQ("Every one of these is the same algorithm with one " +
	"number changed. A grid of seeds cannot do this: its density follows the SEEDS, " +
	"so a sparse plot goes bald where the flow is fast and a dense one clots where " +
	"it is slow.", 40, nY2 + nCell + 44).Fill("#666666")
oC.Flush()

oC.ToPNGHiRes("geo_flow_gallery.png")

? "-- eight flows --"
for f = 1 to len(aFields)
	? "  " + aFields[f][1] + ": " + aFields[f][2]
next
? ""
? "-- the density study, on the vortex pair --"
for k = 1 to len(aSeps)
	? "  separation " + aSeps[k] + " degrees"
next
? "-> geo_flow_gallery.png"

# a window the map class will accept; the flow needs no geography
func _Dummy()
	return StzGeoFeaturesFromJson('{"type":"FeatureCollection","features":[{"type":"Feature",' +
		'"properties":{"name":"box"},"geometry":{"type":"Polygon","coordinates":' +
		'[[[-15,-15],[15,-15],[15,15],[-15,15],[-15,-15]]]}}]}')

# THE EIGHT FIELDS, each written as its textbook formula so a reader can
# check the picture against what the formula must do.
func _FieldOf pnWhich, pnSpan, pnGrid, pnStep
	_u_ = []
	_v_ = []
	for _j_ = 0 to pnGrid - 1
		for _i_ = 0 to pnGrid - 1
			_x_ = -pnSpan + pnStep * _i_
			_y_ = -pnSpan + pnStep * _j_
			_a_ = _VecAt(pnWhich, _x_, _y_)
			_u_ + _a_[1]
			_v_ + _a_[2]
		next
	next
	return [ _u_, _v_ ]

func _VecAt pnWhich, x, y
	if pnWhich = 1
		# two counter-rotating gyres
		_u_ = 0  _v_ = 0
		_ax_ = -7  _ay_ = 5  _s_ = 1
		for _k_ = 1 to 2
			if _k_ = 2  _ax_ = 7  _ay_ = -5  _s_ = -1  ok
			_dx_ = (x - _ax_) / 7
			_dy_ = (y - _ay_) / 7
			_r_ = _dx_*_dx_ + _dy_*_dy_ + 0.28
			_u_ += _s_ * -_dy_ / _r_
			_v_ += _s_ * _dx_ / _r_
		next
		return [ _u_, _v_ ]
	ok
	if pnWhich = 2
		# the saddle: in along one axis, out along the other
		return [ x / 6, -y / 6 ]
	ok
	if pnWhich = 3
		# a source and a sink -- a dipole
		_u_ = 0  _v_ = 0
		_ax_ = -6  _s_ = 1
		for _k_ = 1 to 2
			if _k_ = 2  _ax_ = 6  _s_ = -1  ok
			_dx_ = x - _ax_
			_dy_ = y
			_r_ = _dx_*_dx_ + _dy_*_dy_ + 1.2
			_u_ += _s_ * _dx_ / _r_ * 12
			_v_ += _s_ * _dy_ / _r_ * 12
		next
		return [ _u_, _v_ ]
	ok
	if pnWhich = 4
		# two opposite vortices; the pair drifts as one
		_u_ = 0  _v_ = 0
		_ax_ = -5  _s_ = 1
		for _k_ = 1 to 2
			if _k_ = 2  _ax_ = 5  _s_ = -1  ok
			_dx_ = x - _ax_
			_dy_ = y
			_r_ = _dx_*_dx_ + _dy_*_dy_ + 1.0
			_u_ += _s_ * -_dy_ / _r_ * 14
			_v_ += _s_ * _dx_ / _r_ * 14
		next
		return [ _u_, _v_ ]
	ok
	if pnWhich = 5
		# a shear jet: sech squared, fast in the middle and still outside
		_t_ = y / 4
		_e_ = exp(_t_) + exp(-_t_)
		_sech2_ = 4 / (_e_ * _e_)
		return [ _sech2_ * 3, 0.15 * sin(x / 3) ]
	ok
	if pnWhich = 6
		# uniform flow past a cylinder -- the classic potential solution
		_r2_ = x*x + y*y
		if _r2_ < 16  _r2_ = 16  ok
		_a2_ = 16
		return [ 1 - _a2_ * (x*x - y*y) / (_r2_*_r2_), -_a2_ * 2*x*y / (_r2_*_r2_) ]
	ok
	if pnWhich = 7
		# a source and a vortex at the same place: a spiral
		_r_ = x*x + y*y + 1.5
		return [ (x * 0.5 - y) / _r_ * 10, (y * 0.5 + x) / _r_ * 10 ]
	ok
	# four cells: doubly periodic, closing on itself everywhere
	_k_ = 3.141592653589793 / 7.5
	return [ sin(_k_ * x) * cos(_k_ * y), -cos(_k_ * x) * sin(_k_ * y) ]
