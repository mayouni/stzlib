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
$bStzGraphicsDeviceTried = 0

func StzColorToNumber(pColor)
	if isNumber(pColor)
		return pColor
	ok
	if NOT isString(pColor)
		StzRaise("stzColor: a colour is a string like '#e0a030' or a name " +
			"like :Gold -- got a " + type(pColor) + ".")
	ok

	_c_ = lower(ring_trim("" + pColor))

	if _c_ = "transparent"  return 0  ok

	# NOT A HEX LITERAL? Hand it to the ONE resolver.
	#
	# This function used to carry its own table of eleven softened names and
	# REFUSE everything else, which is why only stzDiagram could speak the
	# colour language: `Fill("blue+")` raised, `Fill(:Success)` raised, and
	# where both tables did know a name they DISAGREED -- "blue" was
	# #466EE6 here and #0000FF in the resolver. Two colour tables in one
	# library, which is the divergence this house has a law about.
	#
	# Measured before removing them: the whole graphics layer and its tests
	# had THREE bare-name call sites. Everything else already passed hex, so
	# unifying cost nothing visually and bought every face the entire
	# language -- shades (blue+, gray--), semantic roles (:Success,
	# :Danger), and theme lookups.
	if left(_c_, 1) != "#"
		# StzTryResolveColor, not StzResolveColor: the strict one answers ""
		# for a name the language does not know, so a typo REFUSES here
		# instead of being quietly substituted.
		_r_ = StzTryResolveColor(_c_)
		if NOT (isString(_r_) and left(_r_, 1) = "#")
			StzRaise("stzColor: '" + pColor + "' is not a colour. Use " +
				"'#rrggbb', a name like :Gold, a shade like 'blue+' or " +
				"'gray--', or a semantic role like :Success.")
		ok
		_c_ = lower(_r_)
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

# ---- computed colours (GR5) -------------------------------------------
#
# Hex literals are how a colour is WRITTEN; these are how a colour is
# COMPUTED. A frame loop cycling a hue, a chart colouring N series apart, a
# fade that depends on age -- none of those can name their colour in
# advance, and building the hex string by hand at the call site is how a
# picture ends up with a rounding bug nobody can find.

# Hue 0..360 (0 red, 120 green, 240 blue), saturation and lightness 0..100.
# Values outside those ranges are WRAPPED (hue) or CLAMPED (s, l) rather
# than refused: a hue that keeps increasing is the normal way to animate
# one, and making the caller do the modulo is a trap, not a service.
func StzColorFromHSL(pnH, pnS, pnL)
	if NOT (isNumber(pnH) and isNumber(pnS) and isNumber(pnL))
		StzRaise("StzColorFromHSL: hue 0-360, saturation and lightness 0-100.")
	ok
	_nH_ = pnH % 360
	if _nH_ < 0
		_nH_ += 360
	ok
	_nS_ = _StzClamp01(pnS / 100)
	_nL_ = _StzClamp01(pnL / 100)

	_nC_ = (1 - fabs(2 * _nL_ - 1)) * _nS_
	_nHp_ = _nH_ / 60
	_nX_ = _nC_ * (1 - fabs((_nHp_ % 2) - 1))
	_nM_ = _nL_ - _nC_ / 2

	_nR_ = 0  _nG_ = 0  _nB_ = 0
	if _nHp_ < 1
		_nR_ = _nC_  _nG_ = _nX_
	but _nHp_ < 2
		_nR_ = _nX_  _nG_ = _nC_
	but _nHp_ < 3
		_nG_ = _nC_  _nB_ = _nX_
	but _nHp_ < 4
		_nG_ = _nX_  _nB_ = _nC_
	but _nHp_ < 5
		_nR_ = _nX_  _nB_ = _nC_
	else
		_nR_ = _nC_  _nB_ = _nX_
	ok

	return _StzRgba(floor((_nR_ + _nM_) * 255 + 0.5),
	                floor((_nG_ + _nM_) * 255 + 0.5),
	                floor((_nB_ + _nM_) * 255 + 0.5), 255)

# The same colour at a different opacity. Alpha is 0..255 (0 invisible,
# 255 opaque) -- the same scale the packed colour itself uses, so there is
# one alpha convention in the plane rather than two.
func StzColorWithAlpha(pColor, pnAlpha)
	_n_ = StzColorToNumber(pColor)
	_nA_ = floor(pnAlpha)
	if _nA_ < 0    _nA_ = 0    ok
	if _nA_ > 255  _nA_ = 255  ok
	return floor(_n_ / 256) * 256 + _nA_

# Mix two colours, 0 = all the first, 1 = all the second. Component-wise
# and including alpha -- what a gradient stop or a hover state wants.
func StzColorMix(pFrom, pTo, pnT)
	_nT_ = _StzClamp01(pnT)
	_a_ = _StzColorParts(StzColorToNumber(pFrom))
	_b_ = _StzColorParts(StzColorToNumber(pTo))
	return _StzRgba(floor(_a_[1] + (_b_[1] - _a_[1]) * _nT_ + 0.5),
	                floor(_a_[2] + (_b_[2] - _a_[2]) * _nT_ + 0.5),
	                floor(_a_[3] + (_b_[3] - _a_[3]) * _nT_ + 0.5),
	                floor(_a_[4] + (_b_[4] - _a_[4]) * _nT_ + 0.5))

func _StzColorParts(pn)
	return [ floor(pn / 16777216) % 256,
	         floor(pn / 65536) % 256,
	         floor(pn / 256) % 256,
	         pn % 256 ]

func _StzClamp01(pn)
	if pn < 0  return 0  ok
	if pn > 1  return 1  ok
	return pn

#---------------------------------------------------------------------------#
#  THE CONTRAST LAYER -- readable text on any background, everywhere        #
#---------------------------------------------------------------------------#
#
#     StzContrastingText("gold")     -> "black"
#     StzContrastingText("blue+")    -> "white"
#     StzIsDarkColor(:Danger)        -> 0
#
# This used to live as a METHOD on stzDiagram, so a plot, a tree, a canvas
# or a scene that wanted legible text had to either invent its own rule or
# instantiate a diagram to borrow one. It is not a diagram concern -- it is
# the question "what can be read on top of this", and every visual face
# asks it.
#
# ONE implementation. stzDiagram.ContrastingTextColor now delegates here,
# so the two cannot drift apart the way the two colour TABLES did.

# Perceptual brightness, ITU-R BT.709 weights, 0..255.
func StzColorLuminance(pColor)
	_a_ = StzHexToRGB(StzResolveColor(pColor))
	return 0.299 * _a_[1] + 0.587 * _a_[2] + 0.114 * _a_[3]

func StzIsDarkColor(pColor)
	return StzColorLuminance(pColor) < 150

# "white" or "black" -- whichever can actually be READ on pColor.
#
# The threshold is 150 rather than the midpoint 128, and that is
# deliberate: at 128 a mid blue takes black text and becomes unreadable.
# It is the value stzDiagram has shipped with, kept so no existing picture
# changes.
# WHICH OF BLACK/WHITE TO READ ON pBg AT THIS SIZE AND WEIGHT, and
# whether the text must be emphasised to carry it.
#
#   -> [ colour, wcagRatio, bNeedsEmphasis ]
#
# THE RATIO ALONE IS NOT THE ANSWER, and picking the higher of the two was
# a real regression dressed as a fix. On every saturated mid-tone black
# measures better than white -- and reads worse: dark ink on a dark-ish
# saturated field is muddy however the number comes out, which is why dot
# writes white on exactly these fills and why StzIsDarkColor already sets
# its threshold at 150 rather than the midpoint 128, with the reason
# written beside it: "at 128 a mid blue takes black text and becomes
# unreadable". The intent was in the tree; measuring louder overrode it.
#
# WCAG's own answer is the missing half. 4.5:1 is the minimum for normal
# text and 3:1 for LARGE text -- 24px, or 18.66px when bold. White on a
# saturated role sits between the two, so it is not "failing", it is text
# that must be large or bold. That is the rule this encodes: prefer white
# on anything dark, and say when the size it was asked for cannot carry
# it, so the renderer can thicken it rather than the colour being swapped
# for one nobody can read either.
func StzReadableTextOn(pBg, pnSizePx, pbBold)
	_lg_ = 0
	if isNumber(pnSizePx)
		if pnSizePx >= 24  _lg_ = 1  ok
		if pbBold and pnSizePx >= 18.66  _lg_ = 1  ok
	ok
	_min_ = StzContrastMinimumBodyText()
	if _lg_  _min_ = StzContrastMinimumLargeText()  ok

	_w_ = StzContrastOf(:White, pBg)
	_k_ = StzContrastOf(:Black, pBg)

	if StzIsDarkColor(pBg)
		# white is the right ink here; the only question is whether this
		# size can carry it
		if _w_ >= _min_  return [ "white", _w_, 0 ]  ok
		if _w_ >= StzContrastMinimumLargeText()  return [ "white", _w_, 1 ]  ok
		# white cannot reach even the large-text floor -- now black, and
		# only now, is the better read
		if _k_ >= StzContrastMinimumBodyText()  return [ "black", _k_, 0 ]  ok
		return [ "white", _w_, 1 ]
	ok

	# a light field: black, and white only if black somehow cannot
	if _k_ >= _min_  return [ "black", _k_, 0 ]  ok
	if _w_ >= StzContrastMinimumBodyText()  return [ "white", _w_, 0 ]  ok
	return [ "black", _k_, 1 ]

# THE FOREGROUND THAT CAN ACTUALLY BE READ ON pColor, for a caller that
# has no size to offer. It reports the colour only; a caller that knows
# its font size should ask StzReadableTextOn, which also says whether that
# size needs emphasis.
func StzContrastingText(pColor)
	_r_ = StzReadableTextOn(pColor, 0, 0)
	return _r_[1]

	func StzForegroundOn(pColor)
		return StzContrastingText(pColor)

# A theme's colour for a ROLE: primary, success, warning, danger, info,
# neutral, background. The themes are the ones stzDiagram already defines
# ($aPalette), now reachable from any face.
func StzThemeColor(pcTheme, pcRole)
	_t_ = lower("" + pcTheme)
	_r_ = lower("" + pcRole)
	if NOT isList($aPalette)  return ""  ok
	for _p_ in $aPalette
		if isList(_p_) and len(_p_) = 2 and lower("" + _p_[1]) = _t_
			for _q_ in _p_[2]
				if isList(_q_) and len(_q_) = 2 and lower("" + _q_[1]) = _r_
					return _q_[2]
				ok
			next
		ok
	next
	return ""

# StzColorThemes() is NOT defined here -- stzDiagramColor.ring already
# provides it, and a second definition is a C22 that takes the whole
# library down at load time.

# TWO DIFFERENT THINGS, and conflating them was a bug in this file's first
# version -- StzColorRoles() advertised :Background, a caller painted with
# it, and the resolver refused because there is no standalone colour by
# that name.
#
#   StzSemanticColors()  names that RESOLVE on their own. Fill(:Danger)
#                        works anywhere, with no theme in force.
#   StzThemeRoles()      the slots a THEME fills in. :Background is one of
#                        these: it is meaningless without a theme to look
#                        it up in, so it is only ever reached through
#                        StzThemeColor(theme, :background).
# TWO FAMILIES, and the order says which is which. :Success .. :Muted are
# family one -- a STATE the thing is in. :Neutral is family two, metadata
# carrying no semantic charge, and it is last because it is a different
# kind of thing rather than a seventh status. :Primary leads because it is
# Rule 3's one-accent-per-application quantity, not a state either.
#
# :Muted was missing until 2026-08-22 and its absence was not tidiness: a
# channel implementing four of the law's five values cannot be written
# into a cross-medium conformance record at all, which left another
# repository's keystone unable to report anything but NOT PROVED. See
# StzMutedOf() in stzDiagramColor.ring for what muting IS, and why it is a
# treatment of a status rather than a seventh hue.
func StzSemanticColors()
	return [ :Primary, :Success, :Warning, :Danger, :Info, :Muted, :Neutral ]

func StzThemeRoles()
	return [ :Primary, :Success, :Warning, :Danger, :Info, :Muted, :Neutral,
	         :Background ]

	# kept: StzColorRoles reads as the theme's slots, which is where it is used
	func StzColorRoles()
		return StzThemeRoles()

#---------------------------------------------------------------------------#
#  CONTRAST AS A NUMBER (C3 of SOFTANZA_COLOR_SYSTEM.md)                    #
#---------------------------------------------------------------------------#
#
#     StzContrastOf(:White, :Danger)     -> a WCAG ratio, 1.0 .. 21.0
#     StzContrastLc("black", "gold")     -> an APCA Lc, signed for polarity
#     StzIsLegible(text, background)     -> against a stated minimum
#
# StzContrastingText answers WHICH of black/white to use. It cannot answer
# "is this pair legible?", so nothing could refuse an illegible combination
# -- a design system that cannot FAIL an accessibility check does not have
# one. These are the calls a theme is gated by.
#
# TWO METRICS ON PURPOSE, and the metric is named every time it is
# reported. WCAG 2 is the one standards and clients ask for, and its
# anchors are exact (white on black is 21.0). APCA models POLARITY -- dark
# text on light behaves differently from light on dark -- and is better on
# the mid-tones where WCAG 2 is known to misjudge. Quoting an Lc where
# somebody expects a 4.5:1 ratio is how a number becomes misleading.

func _StzRgb24(pColor)
	_a_ = StzHexToRGB(StzResolveColor(pColor))
	return _a_[1] * 65536 + _a_[2] * 256 + _a_[3]

# WCAG 2.x contrast ratio. Order does not matter.
func StzContrastOf(pA, pB)
	return StzEngineColorContrastWcag(_StzRgb24(pA), _StzRgb24(pB))

# APCA Lc. TEXT first, BACKGROUND second -- unlike the ratio, the order
# carries meaning: positive is dark-on-light, negative is light-on-dark.
func StzContrastLc(pText, pBg)
	return StzEngineColorContrastApca(_StzRgb24(pText), _StzRgb24(pBg))

# The WCAG 2 minimum for normal body text. Named rather than inlined so a
# caller reads the intent, and so raising or lowering it is one edit that
# shows up in a diff.
func StzContrastMinimumBodyText()
	return 4.5

func StzContrastMinimumLargeText()
	return 3.0

func StzIsLegible(pText, pBg)
	return StzContrastOf(pText, pBg) >= StzContrastMinimumBodyText()

func StzIsLegibleXT(pText, pBg, pnMin)
	return StzContrastOf(pText, pBg) >= pnMin

# The best of black/white ON a fill, chosen by MEASURED contrast rather
# than by a luminance threshold. StzContrastingText keeps its exact
# current answers because pictures depend on them; this one is free to be
# right instead of compatible, and reports the ratio it achieved.
#
#   -> [ colour, wcagRatio ]
func StzBestTextOn(pBg)
	_w_ = StzContrastOf(:White, pBg)
	_k_ = StzContrastOf(:Black, pBg)
	if _w_ >= _k_
		return [ "white", _w_ ]
	ok
	return [ "black", _k_ ]

