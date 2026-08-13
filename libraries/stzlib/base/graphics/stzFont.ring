#---------------------------------------------------------------------------#
#  STZFONT -- a loaded typeface, and the measuring tape that goes with it.   #
#---------------------------------------------------------------------------#
#
#     oF = new stzFont("amiri.ttf")
#     ? oF.GlyphCount()
#     ? oF.WidthOf("Softanza", 24)         # px, from the REAL shaper
#     ? oF.WidthOf("سوفتانزا", 24)         # ...and it is right for Arabic too
#
# A font here is not a name the system might resolve differently tomorrow:
# it is BYTES you loaded, shaped by the engine's own pipeline (SheenBidi ->
# HarfBuzz -> stb_truetype). That is why WidthOf() can be trusted for
# LAYOUT -- centring a label, right-aligning a heading -- in any script.
#
# State is one number (the generation-keyed engine font id), so Ring's
# copy-on-assign is harmless: copies share the same loaded face, and a
# freed id answers by NAME, never with another font's glyphs.

func StzFontQ(pcPathOrBytes)
	return new stzFont(pcPathOrBytes)

class stzFont from stzObject

	@nId = 0
	@cSource = ""

	# Takes a file PATH, or the font's bytes directly (so a font can come
	# from a resource bundle, a database blob, or the network).
	def init(pcPathOrBytes)
		_cBytes_ = "" + pcPathOrBytes
		if len(_cBytes_) < 512 and fexists(_cBytes_)
			@cSource = _cBytes_
			_cBytes_ = read(_cBytes_)
		else
			@cSource = "(bytes)"
		ok
		if len(_cBytes_) = 0
			StzRaise("stzFont: nothing to load from '" + @cSource + "'.")
		ok
		@nId = StzEngineGpuFontLoad(_cBytes_)
		if @nId = 0
			StzRaise("stzFont: '" + @cSource + "' is not a font the engine " +
				"can read (needs a TTF/OTF with a glyph table).")
		ok

	def Id_()
		return @nId

	def Source()
		return @cSource

	def IsAlive()
		return StzEngineGpuFontGlyphCount(@nId) >= 0

	def GlyphCount()
		return StzEngineGpuFontGlyphCount(@nId)

	# The shaped advance width in pixels -- the number to centre or align by.
	def WidthOf(pcText, pnSize)
		_a_ = StzEngineGpuTextLayout(@nId, "" + pcText, pnSize)
		if len(_a_) = 0
			return 0
		ok
		return _a_[1]

	# How many VISUAL runs the text breaks into: 1 for pure Latin or pure
	# Arabic, 3 for "abc عربي xyz". Bidi made inspectable.
	def RunCountOf(pcText, pnSize)
		_a_ = StzEngineGpuTextLayout(@nId, "" + pcText, pnSize)
		if len(_a_) = 0
			return 0
		ok
		return _a_[2]

	# The positioned GLYPH IDs -- in visual order, eight numbers each:
	#   [ gid, x, y, byteCluster, pen, advance, clusterEnd, bidiLevel ]
	# The mechanism, exposed: this is what proves Arabic joined rather
	# than merely looking joined. x is the DRAW position (it carries the
	# mark offset); [pen, pen+advance) is the HIT-TEST box -- they are
	# different numbers and confusing them is a classic caret bug.
	def GlyphsOf(pcText, pnSize)
		_a_ = StzEngineGpuTextLayout(@nId, "" + pcText, pnSize)
		if len(_a_) = 0
			return []
		ok
		return _a_[3]

	# Vertical metrics in px at this size: [ ascender, descender, lineGap ].
	# Ascender and descender are both POSITIVE distances from the baseline.
	def MetricsOf(pcText, pnSize)
		_a_ = StzEngineGpuTextLayout(@nId, "" + pcText, pnSize)
		if len(_a_) = 0
			return [ 0, 0, 0 ]
		ok
		return [ _a_[4], _a_[5], _a_[6] ]

	def LineHeightOf(pcText, pnSize)
		_a_ = This.MetricsOf(pcText, pnSize)
		return _a_[1] + _a_[2] + _a_[3]

	# TRUE when the paragraph's own base direction is right-to-left --
	# which decides where the caret sits past the last character.
	def IsRtlParagraph(pcText, pnSize)
		_a_ = StzEngineGpuTextLayout(@nId, "" + pcText, pnSize)
		if len(_a_) = 0
			return 0
		ok
		return _a_[7] = 1

	#-- REVERSIBILITY: the two queries every platform IME demands ---------#
	#
	# Windows TSF asks GetTextExt and GetACPFromPoint; macOS asks
	# firstRectForCharacterRange: and characterIndexForPoint:; Android and
	# the Web's EditContext ask the same pair in their own words. A layout
	# that cannot answer them can shape Arabic beautifully and still never
	# accept a single character of Chinese.
	#
	# Byte offsets, not character counts: they are what the shaper's
	# clusters already speak, and what StzFind and friends return.

	# The visual rects covering the LOGICAL byte range [nStart, nEnd) --
	# [ [x, top, w, h], ... ], x from the text origin and y DOWN from the
	# baseline at 0. A LIST, because a range that crosses a bidi seam is
	# genuinely in several pieces on screen. An empty range selects
	# nothing -- for a caret, ask CaretRectAt.
	def RectsOfRange(pcText, pnSize, pnStart, pnEnd)
		return StzEngineGpuTextRects(@nId, "" + pcText, pnSize, pnStart, pnEnd)

	# The zero-width, full-line-height rect where a caret sits: the very
	# rectangle a platform IME wants its candidate window positioned by.
	#
	# bTrailing is the AFFINITY bit, and it is not decoration. At a bidi
	# seam one byte offset has two legitimate screen positions and nothing
	# in the text chooses between them -- the caller's affinity does. Pass
	# back what IndexAtPoint gave you and the round trip is exact.
	def CaretRectAt(pcText, pnSize, pnIndex, pbTrailing)
		_n_ = 0
		if pbTrailing = 1
			_n_ = 1
		ok
		return StzEngineGpuTextCaretRect(@nId, "" + pcText, pnSize, pnIndex, _n_)

	# The character under a point -- [ nIndex, bTrailing, nCaretByte ].
	# nIndex is the cluster's FIRST byte (what the platform APIs return);
	# nCaretByte is that index already resolved through the affinity, so a
	# caller who only wants "where does the caret go" reads item 3.
	def IndexAtPoint(pcText, pnSize, pnX)
		_a_ = StzEngineGpuTextIndexAt(@nId, "" + pcText, pnSize, pnX)
		if len(_a_) = 0
			return [ 0, 0, 0 ]
		ok
		return _a_

	def Free()
		if @nId > 0
			StzEngineGpuFontFree(@nId)
			@nId = 0
		ok
