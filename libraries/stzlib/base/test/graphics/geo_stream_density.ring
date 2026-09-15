load "../../stzBase.ring"
decimals(2)

# GE10c -- STREAM DENSITY: the flow drawn OVER its own magnitude.
#
# The one thing Wolfram's field plots did that this plane could not: put the
# streamlines on a continuous wash of colour, brightest where the flow is
# fastest. A streamline shows a DIRECTION and hides a SPEED, and a reader
# should not have to trace a line to learn how hard the flow is going
# through it. The density puts the speed on the GROUND, where the eye reads
# it first.
#
# IT IS A COMPOSITION AND NOT A NEW THING. The scalar shaded is the speed,
# and a scalar field is what GE7b draws -- so this builds a stzGeoField from
# the speed, uses GE7b's raster and GE7b's contours, and lays GE10's flow
# on top. Nothing here is reimplemented, which is why the density carries a
# real legend that Wolfram's does not.

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")

nSpan = 15
nGrid = 71
nStep = 2 * nSpan / (nGrid - 1)

aFields = [
	[ "Vortex pair",     "two opposite rotations; fastest between the cores" ,   :Viridis ],
	[ "Source and sink", "a dipole -- the flow races through the neck between them", :Magma ],
	[ "Past a cylinder", "uniform flow with a circle in it; the sides speed up",  :Viridis ],
	[ "Four cells",      "a doubly periodic field; the corners are the fast lanes", :Cividis ]
]

nCols = 2
nCell = 520
nPadX = 40
nPadY = 110

oC = new stzCanvas(nCols * nCell + (nCols - 1) * nPadX + 80, 2 * (nCell + nPadY) + 130)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 26).AddTextQ("Stream density: the flow over its own speed", 40, 50).Fill("#1A1A1A")
oC.Flush()
oC.SetFontQ(oFont, 14).AddTextQ("the colour is the magnitude -- brightest where the flow " +
	"is fastest -- and the lines carry only the shape; the eye reads the fast places at once",
	40, 74).Fill("#777777")
oC.Flush()

nY0 = 150
for f = 1 to len(aFields)
	nCol = ((f - 1) % nCols)
	nRow = floor((f - 1) / nCols)
	nX = 40 + nCol * (nCell + nPadX)
	nY = nY0 + nRow * (nCell + nPadY)

	oP = new stzGeoProjection(:Equirectangular)
	oP.FitPointsIn([ -nSpan, -nSpan, nSpan, nSpan ], nX, nY, nX + nCell, nY + nCell, 0)
	oM = StzGeoMap(oP, _Dummy())
	oM.SetPaper(nX, nY, nX + nCell, nY + nCell)

	aG = [ -nSpan, -nSpan, nStep, nStep, nGrid, nGrid ]
	aUV = _FieldOf(f, nSpan, nGrid, nStep)
	n = oM.DrawStreamDensityOnXT(oC, aG, aUV[1], aUV[2], 1.5, aFields[f][3], "#12203A", 22, 9, 700)

	oC.AddRectQ(nX, nY, nCell, nCell).FillQ("#00000000").Stroke("#CCCCCC", 1)
	oC.Flush()
	oC.SetFontQ(oFont, 16).AddTextQ(aFields[f][1], nX, nY - 30).Fill("#1A1A1A")
	oC.Flush()
	oC.SetFontQ(oFont, 12).AddTextQ(aFields[f][2], nX, nY - 12).Fill("#999999")
	oC.Flush()
	oC.SetFontQ(oFont, 11).AddTextQ("" + n + " streamlines over a " + aFields[f][3] +
		" density of the speed, with contours", nX, nY + nCell + 20).Fill("#AAAAAA")
	oC.Flush()
next

oC.ToPNGHiRes("geo_stream_density.png")

? "-- stream density plots --"
for f = 1 to len(aFields)
	? "  " + aFields[f][1] + " on " + aFields[f][3]
next
? "-> geo_stream_density.png"

func _Dummy()
	return StzGeoFeaturesFromJson('{"type":"FeatureCollection","features":[{"type":"Feature",' +
		'"properties":{"name":"box"},"geometry":{"type":"Polygon","coordinates":' +
		'[[[-15,-15],[15,-15],[15,15],[-15,15],[-15,-15]]]}}]}')

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
		# vortex pair
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
	if pnWhich = 2
		# source and sink
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
	if pnWhich = 3
		# uniform flow past a cylinder
		_r2_ = x*x + y*y
		if _r2_ < 16  _r2_ = 16  ok
		_a2_ = 16
		return [ 1 - _a2_ * (x*x - y*y) / (_r2_*_r2_), -_a2_ * 2*x*y / (_r2_*_r2_) ]
	ok
	# four cells
	_k_ = 3.141592653589793 / 7.5
	return [ sin(_k_ * x) * cos(_k_ * y), -cos(_k_ * x) * sin(_k_ * y) ]
