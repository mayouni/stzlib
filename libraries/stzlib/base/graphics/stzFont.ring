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

	# The positioned GLYPH IDs -- [ [gid, x, y, byteCluster], ... ] in
	# visual order. The mechanism, exposed: this is what proves Arabic
	# joined rather than merely looking joined.
	def GlyphsOf(pcText, pnSize)
		_a_ = StzEngineGpuTextLayout(@nId, "" + pcText, pnSize)
		if len(_a_) = 0
			return []
		ok
		return _a_[3]

	def Free()
		if @nId > 0
			StzEngineGpuFontFree(@nId)
			@nId = 0
		ok
