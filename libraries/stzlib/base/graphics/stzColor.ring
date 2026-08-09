#---------------------------------------------------------------------------#
#  COLOR -- the one place a human-written colour becomes engine bytes.       #
#---------------------------------------------------------------------------#
#
# Everything in base/graphics/ takes colours the way a designer writes them:
#
#     "#e0a030"      opaque
#     "#e0a030c0"    with alpha
#     "#fa3"         the 3-digit short form
#     :Red :White :Transparent ...   a small named set for quick work
#
# and hands the engine a packed 0xRRGGBBAA number (exact in Ring's f64).
# ONE converter, shared -- a second one would drift, and a colour that
# means something different on two tiers is exactly the bug the whole
# two-renderer design exists to prevent.
#
# A malformed colour RAISES by name. It never silently becomes black:
# a picture that renders in the wrong colour teaches nothing, while a
# refusal names the typo.

# Graphics-wide load-time state. It lives HERE, before the first func of
# the first graphics file loaded, because a global assigned after a func
# definition becomes part of that function and never executes.
$bStzGraphicsDeviceTried = FALSE

func StzColorToNumber(pColor)
	if isNumber(pColor)
		return pColor
	ok
	if NOT isString(pColor)
		StzRaise("stzColor: a colour is a string like '#e0a030' or a name " +
			"like :Gold -- got a " + type(pColor) + ".")
	ok

	_c_ = lower(ring_trim("" + pColor))

	# named colours: the handful worth having without a lookup
	switch _c_
	on "black"        return _StzRgba(0, 0, 0, 255)
	on "white"        return _StzRgba(255, 255, 255, 255)
	on "red"          return _StzRgba(220, 60, 60, 255)
	on "green"        return _StzRgba(60, 180, 90, 255)
	on "blue"         return _StzRgba(70, 110, 230, 255)
	on "gold"         return _StzRgba(240, 200, 40, 255)
	on "orange"       return _StzRgba(240, 140, 70, 255)
	on "purple"       return _StzRgba(180, 90, 200, 255)
	on "cyan"         return _StzRgba(90, 200, 210, 255)
	on "gray"         return _StzRgba(150, 150, 150, 255)
	on "grey"         return _StzRgba(150, 150, 150, 255)
	on "transparent"  return 0
	off

	if left(_c_, 1) != "#"
		StzRaise("stzColor: '" + pColor + "' is not a colour -- use '#rrggbb', " +
			"'#rrggbbaa', '#rgb', or a name like :Gold.")
	ok
	_h_ = substr(_c_, 2)
	_n_ = len(_h_)

	if _n_ = 3        # #rgb -> #rrggbb
		_h_ = substr(_h_,1,1) + substr(_h_,1,1) +
		      substr(_h_,2,1) + substr(_h_,2,1) +
		      substr(_h_,3,1) + substr(_h_,3,1)
		_n_ = 6
	ok
	if _n_ != 6 and _n_ != 8
		StzRaise("stzColor: '" + pColor + "' has " + _n_ + " hex digits -- " +
			"expected 3, 6 or 8.")
	ok

	_nR_ = _StzHexByte(_h_, 1, pColor)
	_nG_ = _StzHexByte(_h_, 3, pColor)
	_nB_ = _StzHexByte(_h_, 5, pColor)
	_nA_ = 255
	if _n_ = 8
		_nA_ = _StzHexByte(_h_, 7, pColor)
	ok
	return _StzRgba(_nR_, _nG_, _nB_, _nA_)

func _StzRgba(pR, pG, pB, pA)
	return pR * 16777216 + pG * 65536 + pB * 256 + pA

func _StzHexByte(pcHex, pnAt, pOriginal)
	return _StzHexDigit(substr(pcHex, pnAt, 1), pOriginal) * 16 +
	       _StzHexDigit(substr(pcHex, pnAt + 1, 1), pOriginal)

func _StzHexDigit(pcC, pOriginal)
	_n_ = ascii(pcC)
	if _n_ >= 48 and _n_ <= 57    return _n_ - 48  ok      # 0-9
	if _n_ >= 97 and _n_ <= 102   return _n_ - 87  ok      # a-f
	StzRaise("stzColor: '" + pOriginal + "' contains '" + pcC +
		"', which is not a hex digit.")

# The inverse, for faces that must show a colour back the way it came in.
func StzColorToHex(pnColor)
	_aD_ = "0123456789abcdef"
	_c_ = "#"
	_aV_ = [ floor(pnColor / 16777216) % 256,
	         floor(pnColor / 65536) % 256,
	         floor(pnColor / 256) % 256,
	         pnColor % 256 ]
	for _i_ = 1 to 3
		_c_ += substr(_aD_, floor(_aV_[_i_] / 16) + 1, 1) +
		       substr(_aD_, (_aV_[_i_] % 16) + 1, 1)
	next
	if _aV_[4] != 255
		_c_ += substr(_aD_, floor(_aV_[4] / 16) + 1, 1) +
		       substr(_aD_, (_aV_[4] % 16) + 1, 1)
	ok
	return _c_
