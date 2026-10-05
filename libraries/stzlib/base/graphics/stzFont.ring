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

# Holds a loaded TTF or OTF typeface and measures text with it: widths, glyph positions, caret rectangles, and which glyphs a fallback chain had to borrow.
#
# The font is bytes you loaded, shaped by the engine's own pipeline (bidirectional analysis,
# HarfBuzz, stb_truetype), so a width can be trusted for layout in any script, Arabic included.
# Sizes are in pixels. A text that one font cannot draw comes out as hollow boxes, one per
# character; AddFallback puts other fonts behind it and CoverageOf counts what was borrowed and what
# is still missing. The caret and hit-test queries (RectsOfRange, CaretRectAt, IndexAtPoint) count
# bytes, not characters. The object holds one number, the engine's id for the face, so copies of the
# object share the same loaded font; after Free every measurement answers 0 or an empty list (and
# DrawsEveryGlyphOf answers TRUE, which is misleading). A stzCanvas draws text with a font set by
# SetFont.
#
#   receiver   o1 = new stzFont("C:/Windows/Fonts/segoeui.ttf")
#   example    ? o1.WidthOf("abc", 24)
#              #--> 37.42
#   see        stzCanvas, stzObject
class stzFont from stzObject

	@nId = 0
	@cSource = ""

	# Loads a font from a file path or from its own bytes; raises an error when nothing is given or the engine cannot read it as TTF or OTF.
	#
	#   pcPathOrBytes   A path to a TTF or OTF file, or the bytes of one
	#   returns         nothing; the font is built
	#   note            the bytes route lets a font come from a resource bundle or a database blob;
	#                   Source then answers "(bytes)"
	#   see             Source, GlyphCount
	#@ aka  Takes a file PATH, or the font's bytes directly (so a font can come from a resource bundle, a database blob, or the network).
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

	# Returns the engine's number for the loaded font, 0 once the font has been released.
	#
	#   returns    a number
	#   see        IsAlive, Free
	def Id_()
		return @nId

	# Returns the file path the font was loaded from, or "(bytes)" when it was built from bytes.
	#
	#   returns    text
	#   see        init, Id_
	def Source()
		return @cSource

	# TRUE if the font is still loaded in the engine; FALSE once it has been released.
	#
	#   returns    TRUE or FALSE
	#   see        Free, GlyphCount
	def IsAlive()
		return StzEngineGpuFontGlyphCount(@nId) >= 0

	# Returns how many glyphs the font file holds, or -1 once the font has been released.
	#
	#   returns    a number
	#   see        IsAlive
	def GlyphCount()
		return StzEngineGpuFontGlyphCount(@nId)

	# Appends a font to the fallback chain, to supply the glyphs this font lacks; raises an error for a non-font, itself or a ninth link.
	#
	#   poFont     The stzFont to add behind this one
	#   returns    the font itself, so calls can be chained
	#   note       adding the same font twice does nothing and raises nothing; the font itself is
	#              always asked first; the chain holds at most eight fonts
	#   see        FallbackCount, ClearFallbacks, CoverageOf
	#@ aka  -- THE FALLBACK CHAIN (GR2c) -------------------------------------------
	def AddFallback(poFont)
		if NOT isObject(poFont)
			StzRaise("stzFont.AddFallback: give an stzFont to fall back to.")
		ok
		_n_ = StzEngineGpuFontAddFallback(@nId, poFont.Id_())
		if _n_ != 0
			StzRaise("stzFont.AddFallback: '" + poFont.Source() + "' was refused -- " +
				"a font cannot fall back to itself, to a freed font, or beyond " +
				"the eighth link of a chain.")
		ok
		return This

		def AddFallbackQ(poFont)
			return This.AddFallback(poFont)

	# Returns how many fonts stand in the fallback chain behind this one.
	#
	#   returns    a number; -1 once the font has been released
	#   see        AddFallback, HasFallbacks
	def FallbackCount()
		return StzEngineGpuFontFallbackCount(@nId)

	# TRUE if at least one fallback font has been added.
	#
	#   returns    TRUE or FALSE
	#   see        FallbackCount, AddFallback
	def HasFallbacks()
		return This.FallbackCount() > 0

	# Empties the fallback chain, leaving this font to draw alone.
	#
	#   returns    the font itself
	#   see        AddFallback, FallbackCount
	def ClearFallbacks()
		StzEngineGpuFontClearFallbacks(@nId)
		return This

	# Reports what the chain did to a text: how many glyphs came from a fallback font and how many no font could draw.
	#
	#   pcText     The text to measure
	#   pnSize     The font size, in pixels
	#   returns    a list of two numbers [ fallback, notdef ]
	#   note       the notdef glyphs are the hollow boxes that appear on screen
	#   see        DrawsEveryGlyphOf, AddFallback
	#@ aka  WHAT THE CHAIN DID to a given string: [ fallback, notdef ] -- how many glyphs came from a font other than this one, and how many the whole chain could not draw and which will appear as a box. A caller who knows can add a font; a caller who knows nothing cannot.
	def CoverageOf(pcText, pnSize)
		_a_ = StzEngineGpuTextLayout(@nId, "" + pcText, pnSize)
		if len(_a_) < 11  return [ 0, 0 ]  ok
		return [ _a_[10], _a_[11] ]

	# TRUE if every character of the text has a real glyph in this font or its fallbacks, so no hollow box would appear.
	#
	#   pcText     The text to test
	#   pnSize     The font size, in pixels
	#   returns    TRUE or FALSE
	#   note       for the Korean word 안녕 in Segoe UI the answer is FALSE until a Korean font is
	#              added as a fallback
	#   warning    a freed font answers TRUE, because it counts no missing glyph
	#   see        CoverageOf, AddFallback
	def DrawsEveryGlyphOf(pcText, pnSize)
		return This.CoverageOf(pcText, pnSize)[2] = 0

	# Returns the shaped advance width of a text in pixels, the number to centre or right-align a label by; 0 for an empty text.
	#
	#   pcText     The text to measure
	#   pnSize     The font size, in pixels
	#   returns    a number of pixels
	#   note       the width comes from the real shaper, so it is right for Arabic and other joined
	#              scripts as well as for Latin
	#   see        RunCountOf, InkOf, LineHeightOf
	#@ aka  The shaped advance width in pixels -- the number to centre or align by.
	def WidthOf(pcText, pnSize)
		_a_ = StzEngineGpuTextLayout(@nId, "" + pcText, pnSize)
		if len(_a_) = 0
			return 0
		ok
		return _a_[1]

	# Returns how many visual runs the text breaks into: 1 for pure Latin or pure Arabic, 3 for Arabic between Latin words.
	#
	#   pcText     The text to analyse
	#   pnSize     The font size, in pixels
	#   returns    a number
	#   note       0 for an empty text or a freed font
	#   see        IsRtlParagraph, GlyphsOf
	#@ aka  How many VISUAL runs the text breaks into: 1 for pure Latin or pure Arabic, 3 for "abc عربي xyz". Bidi made inspectable.
	def RunCountOf(pcText, pnSize)
		_a_ = StzEngineGpuTextLayout(@nId, "" + pcText, pnSize)
		if len(_a_) = 0
			return 0
		ok
		return _a_[2]

	# Returns the positioned glyphs of a text in visual order, one list of nine numbers per glyph.
	#
	#   pcText     The text to shape
	#   pnSize     The font size, in pixels
	#   returns    a list of lists [ gid, x, y, byteCluster, pen, advance, clusterEnd, bidiLevel,
	#              fontId ]; [ ] for an empty text
	#   note       x is where the glyph is drawn and [pen, pen + advance) is its hit-test box, two
	#              different numbers; the ninth number, the id of the font that supplied the glyph,
	#              is not in the source comment, which says eight
	#   see        WidthOf, RectsOfRange
	#@ aka  The positioned GLYPH IDs -- in visual order, eight numbers each: [ gid, x, y, byteCluster, pen, advance, clusterEnd, bidiLevel ] The mechanism, exposed: this is what proves Arabic joined rather than merely looking joined. x is the DRAW position (it carries the mark offset); [pen, pen+advance) is the HIT-TEST box -- they are different numbers and confusing them is a classic caret bug.
	def GlyphsOf(pcText, pnSize)
		_a_ = StzEngineGpuTextLayout(@nId, "" + pcText, pnSize)
		if len(_a_) = 0
			return []
		ok
		return _a_[3]

	# Returns the vertical metrics of the font at a size: ascender and descender, both positive from the baseline, and line gap.
	#
	#   pcText     Any text
	#   pnSize     The font size, in pixels
	#   returns    a list of three numbers [ ascender, descender, lineGap ]; [ 0, 0, 0 ] for an
	#              empty text
	#   note       the metrics are the font's, the same for every text
	#   see        LineHeightOf, InkOf
	#@ aka  Vertical metrics in px at this size: [ ascender, descender, lineGap ]. Ascender and descender are both POSITIVE distances from the baseline.
	def MetricsOf(pcText, pnSize)
		_a_ = StzEngineGpuTextLayout(@nId, "" + pcText, pnSize)
		if len(_a_) = 0
			return [ 0, 0, 0 ]
		ok
		return [ _a_[4], _a_[5], _a_[6] ]

	# Returns the full line height in pixels: ascender plus descender plus line gap at the size.
	#
	#   pcText     Any text
	#   pnSize     The font size, in pixels
	#   returns    a number of pixels
	#   note       31.92 for Segoe UI at size 24
	#   see        MetricsOf, CapHeightOf
	def LineHeightOf(pcText, pnSize)
		_a_ = This.MetricsOf(pcText, pnSize)
		return _a_[1] + _a_[2] + _a_[3]

	# Returns how far the shaped ink of a text reaches above and below the baseline, which is tighter than the font's em box.
	#
	#   pcText     The text whose ink is measured
	#   pnSize     The font size, in pixels
	#   returns    a list of two numbers [ above, below ] in pixels, both positive; [ 0, 0 ] for an
	#              empty text
	#   note       an H reaches the cap height and 0 below, a g reaches its x-height above and its
	#              descender below
	#   see        CapHeightOf, MetricsOf
	#@ aka  THE INK of this string, px: [ above the baseline, below it ], both positive -- the union of the shaped glyphs' extents, not the font's em box. "H" reaches the cap height and 0 below; "g" reaches the x-height and its descender below. The em box (MetricsOf) is the same for every string at a size; this is the string's own.
	def InkOf(pcText, pnSize)
		_a_ = StzEngineGpuTextLayout(@nId, "" + pcText, pnSize)
		if len(_a_) < 9
			return [ 0, 0 ]
		ok
		return [ _a_[8], _a_[9] ]

	# Returns the height in pixels of a capital H at the size, measured from its ink; the number a label centred by eye should be centred on.
	#
	#   pnSize     The font size, in pixels
	#   returns    a number of pixels
	#   see        InkOf, LineHeightOf
	#@ aka  The cap height at this size, measured: the ink top of an H. What a label centred by eye is centred on -- not the em box, whose centre sits below a capital's by half the descender space nothing uses.
	def CapHeightOf(pnSize)
		return This.InkOf("H", pnSize)[1]

	# TRUE if the base direction of the text is right to left, which decides on which side of the last character the caret ends.
	#
	#   pcText     The text to test
	#   pnSize     The font size, in pixels
	#   returns    TRUE or FALSE
	#   note       FALSE for an empty text or a freed font
	#   see        RunCountOf
	#@ aka  TRUE when the paragraph's own base direction is right-to-left -- which decides where the caret sits past the last character.
	def IsRtlParagraph(pcText, pnSize)
		_a_ = StzEngineGpuTextLayout(@nId, "" + pcText, pnSize)
		if len(_a_) = 0
			return 0
		ok
		return _a_[7] = 1

	#-- REVERSIBILITY: the two queries every platform IME demands ---------#
	# Returns the screen rectangles covered by a range of bytes of the text; a range crossing a direction change comes in several pieces.
	#
	#   pcText     The text
	#   pnSize     The font size, in pixels
	#   pnStart    The byte offset where the range starts, 0 for the first byte
	#   pnEnd      The byte offset where the range ends, not included
	#   returns    a list of [ x, top, width, height ] rectangles, x from the text origin and y
	#              measured down from the baseline at 0; [ ] for an empty range
	#   note       the offsets count bytes, so an Arabic letter takes two
	#   see        CaretRectAt, GlyphsOf
	#@ aka  Windows TSF asks GetTextExt and GetACPFromPoint; macOS asks firstRectForCharacterRange: and characterIndexForPoint:; Android and the Web's EditContext ask the same pair in their own words. A layout that cannot answer them can shape Arabic beautifully and still never accept a single character of Chinese.
	def RectsOfRange(pcText, pnSize, pnStart, pnEnd)
		return StzEngineGpuTextRects(@nId, "" + pcText, pnSize, pnStart, pnEnd)

	# Returns the zero-width, full-line-height rectangle where a caret sits at a byte offset; an input method places its window by it.
	#
	#   pcText       The text
	#   pnSize       The font size, in pixels
	#   pnIndex      The byte offset of the character the caret is at
	#   pbTrailing   1 for the trailing edge of that character, 0 for the leading edge
	#   returns      a list of four numbers [ x, top, 0, height ]
	#   note         at a direction change one offset has two screen positions, and the trailing
	#                flag picks between them; pass back the flag IndexAtPoint gave for an exact
	#                round trip
	#   see          IndexAtPoint, RectsOfRange
	#@ aka  The zero-width, full-line-height rect where a caret sits: the very rectangle a platform IME wants its candidate window positioned by.
	def CaretRectAt(pcText, pnSize, pnIndex, pbTrailing)
		_n_ = 0
		if pbTrailing = 1
			_n_ = 1
		ok
		return StzEngineGpuTextCaretRect(@nId, "" + pcText, pnSize, pnIndex, _n_)

	# Returns which character lies under a horizontal position of the text, the reverse of the caret query.
	#
	#   pcText     The text
	#   pnSize     The font size, in pixels
	#   pnX        The horizontal position in pixels from the text origin
	#   returns    a list of three numbers [ index, trailing, caretByte ]; [ 0, 0, 0 ] for a freed
	#              font
	#   note       index is the first byte of the character, trailing is 1 when the point lies in
	#              its second half, and caretByte is the index already resolved through trailing
	#   see        CaretRectAt
	#@ aka  The character under a point -- [ nIndex, bTrailing, nCaretByte ]. nIndex is the cluster's FIRST byte (what the platform APIs return); nCaretByte is that index already resolved through the affinity, so a caller who only wants "where does the caret go" reads item 3.
	def IndexAtPoint(pcText, pnSize, pnX)
		_a_ = StzEngineGpuTextIndexAt(@nId, "" + pcText, pnSize, pnX)
		if len(_a_) = 0
			return [ 0, 0, 0 ]
		ok
		return _a_

	# Releases the loaded font in the engine and sets its id to 0; later measurements answer 0 or an empty list.
	#
	#   returns    nothing
	#   note       a copy of the object made earlier keeps the old id but answers FALSE to IsAlive;
	#              freeing twice is harmless
	#   see        IsAlive, Id_
	def Free()
		if @nId > 0
			StzEngineGpuFontFree(@nId)
			@nId = 0
		ok
