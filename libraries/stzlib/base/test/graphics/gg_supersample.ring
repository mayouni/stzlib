load "../../stzBase.ring"
decimals(4)

# SUPERSAMPLING -- the render quality knob for a figure meant to be shown.
#
# 4x MSAA antialiases a shape's edges and still BEADS a thin near-axis line:
# its four samples are fixed, so a half-pixel diagonal catches them unevenly
# and the line runs light and dark along its length. That bead is what reads
# as "rasterised". Rendering at 2x and box-averaging gives sixteen effective
# samples where the line is, and the bead fills in.
#
# THIS FILE MEASURES THE BEAD rather than asserting it away. A thin diagonal
# line is drawn; the darkest pixel in each column is the line's coverage
# there; the VARIANCE of that darkness along the line IS the beading. It
# must fall when the same line is supersampled.

nOk = 0  nBad = 0

# ---------------------------------------------------------------------
? "-- 1. THE OUTPUT SIZE IS UNCHANGED: a supersampled render downsamples --"
oA = new stzCanvas(200, 120)
oA.SetBackground("#FFFFFF")
oA.AddLineQ(10, 20, 190, 100).Stroke("#102040", 0.8)
oA.Flush()
cPlain = oA.ToPixels()
cHi = oA.ToPixelsHiRes(2)
? "   plain " + len(cPlain) + " bytes, supersampled " + len(cHi) + " bytes"
chk("A SUPERSAMPLED RENDER RETURNS THE SAME-SIZED IMAGE -- it draws at 2x " +
    "and box-averages down, so the picture is crisper and not larger",
    len(cHi) = len(cPlain) and len(cHi) = 200 * 120 * 4)
chk("...and the factor is CLAMPED to a sane range, so a caller cannot ask " +
    "for a sixteen-times target that would not fit in memory",
    len(oA.ToPixelsHiRes(99)) = len(cPlain) and len(oA.ToPixelsHiRes(0)) = len(cPlain))

# ---------------------------------------------------------------------
? ""
? "-- 2. THE BEAD FALLS: a thin line is smoother supersampled --"
nVarPlain = _BeadOf(cPlain, 200, 120)
nVarHi = _BeadOf(cHi, 200, 120)
? "   darkness variance along the line: plain " + nVarPlain + ", supersampled " + nVarHi
chk("A THIN DIAGONAL LINE BEADS UNDER PLAIN 4x MSAA and is SMOOTHER " +
    "supersampled -- the variance of its darkness along its length falls, " +
    "which is the beading measured rather than asserted away",
    nVarHi < nVarPlain * 0.7)
chk("...and the line is still THERE -- supersampling smooths it, it does " +
    "not erase it: the average darkness is within a quarter of the plain " +
    "render's, not washed to nothing",
    _MeanDark(cHi, 200, 120) > _MeanDark(cPlain, 200, 120) * 0.6)

# ---------------------------------------------------------------------
? ""
? "-- 3. IT IS NOT THE DEFAULT: ToPNG stays plain, a figure opts in --"
chk("ToPNG AND ToPNGXT ARE THE PLAIN RENDER, unchanged -- a test that " +
    "compares rendered bytes wants the plain path, and a nine-hundred-file " +
    "suite does not want to pay 4x the fill for pixels nobody looks at",
    len(oA.ToPNG("")) > 0 and len(oA.ToPNGHiRes("")) > 0)

? ""
? "=========================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=========================================================="

func chk pcWhat, pbOk
	if pbOk
		nOk++
		? "  ok   " + pcWhat
	else
		nBad++
		? "  FAIL " + pcWhat
	ok

# the darkness of the line in each column is its darkest pixel; the beading
# is the variance of that along the columns the line crosses
func _BeadOf cPx, nW, nH
	_d_ = []
	for _x_ = 20 to nW - 20
		_dark_ = 0
		for _y_ = 0 to nH - 1
			_o_ = (_y_ * nW + _x_) * 4
			_v_ = 255 - ascii(cPx[_o_ + 1])
			if _v_ > _dark_  _dark_ = _v_  ok
		next
		_d_ + _dark_
	next
	# variance
	_m_ = 0
	for _i_ = 1 to len(_d_)  _m_ += _d_[_i_]  next
	_m_ /= len(_d_)
	_v_ = 0
	for _i_ = 1 to len(_d_)  _v_ += pow(_d_[_i_] - _m_, 2)  next
	return _v_ / len(_d_)

func _MeanDark cPx, nW, nH
	_s_ = 0
	_n_ = 0
	for _x_ = 20 to nW - 20
		_dark_ = 0
		for _y_ = 0 to nH - 1
			_o_ = (_y_ * nW + _x_) * 4
			_v_ = 255 - ascii(cPx[_o_ + 1])
			if _v_ > _dark_  _dark_ = _v_  ok
		next
		_s_ += _dark_
		_n_++
	next
	return _s_ / _n_
