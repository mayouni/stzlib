#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZPDF                         #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzPdf -- the TEXT LAYER of a born-digital   #
#                  PDF, read by the engine (engine/src/pdf.zig, #
#                  in stz_file.dll): its blocks in reading      #
#                  order, typed as headings, paragraphs, list   #
#                  items, code, tables, captions and page       #
#                  furniture. No model, no OCR, no network: it  #
#                  is the deterministic FLOOR of the document   #
#                  faculty. A scanned page has no text layer    #
#                  and yields no text -- HasText() says so.     #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

# Returns a stzPdf over the PDF at pcPath, read once by the engine.
#
#   pcPath     the path of the PDF file
#   returns    a stzPdf object; a file that is not a readable PDF raises, saying why
func StzPdfQ(pcPath)
	return new stzPdf(pcPath)

# Returns the body text of the PDF at pcPath in reading order, blocks separated by a blank line.
#
#   pcPath     the path of the PDF file
#   returns    text; page headers and footers are left out
func StzPdfText(pcPath)
	return StzPdfQ(pcPath).Text()

# Reads the text layer of a PDF and answers its blocks in reading order, typed by what they are.
#
# The reading is done once, in the engine, when the object is made; every method then reads that result.
#
#   receiver   o1 = new stzPdf("_data/golden_v1/d03.pdf")
#   example    ? o1.NumberOfPages()
#              #--> 1
#   see        StzPdfQ, StzPdfText
class stzPdf from stzObject

	@cPath = ""
	@aInfo = []
	@aBlocks = []
	@cText = ""
	@aImages = []
	@aOcrBy = []
	@aOcrMarks = []
	@cOcrLang = ""

	# Reads the PDF at pcPath through the engine and keeps its blocks, its text and its facts.
	#
	#   pcPath     the path of the PDF file
	#   warning    a file that is not a PDF, an encrypted PDF or one without pages raises with the reason
	def init(pcPath)
		@cPath = pcPath
		_n_ = StzEnginePdfOpen(pcPath)
		if _n_ < 0
			_cWhy_ = StzEnginePdfError()
			StzEnginePdfClose()
			stzraise("Can't read the PDF '" + pcPath + "': " + _cWhy_ + ".")
		ok
		@aInfo = StzEnginePdfInfo()
		@aBlocks = StzEnginePdfBlocks()
		@cText = StzEnginePdfText()
		@aImages = StzEnginePdfImages()
		StzEnginePdfClose()

	  #------------------#
	 #  THE DOCUMENT    #
	#------------------#

	# Returns the path the PDF was read from, as it was given.
	#
	#   returns    text
	def Path()
		return @cPath

	# Returns how many pages the page tree of the PDF holds.
	#
	#   returns    a number
	def NumberOfPages()
		return @aInfo[1]

	# Returns the PDF version written in the file's header, such as 1.4 or 1.7.
	#
	#   returns    text
	def Version()
		return @aInfo[2]

	# Returns the height of page pnPage in points, from its crop box (or its media box).
	#
	#   pnPage     the page number, from 1
	#   returns    a number; 0 for a page that does not exist
	def PageHeight(pnPage)
		if len(@aInfo) < 7 or pnPage < 1 or pnPage > len(@aInfo[7]) return 0 ok
		return @aInfo[7][pnPage]

	# TRUE if the PDF carries a structure tree (a tagged PDF), which this reader does not use yet.
	def IsTagged()
		return @aInfo[4]

	# Returns how many glyphs the text layer holds; 0 for a scanned PDF, which needs OCR.
	#
	#   returns    a number
	def NumberOfGlyphs()
		return @aInfo[5]

	# TRUE if the PDF has a text layer; FALSE for a scanned page, which needs OCR instead.
	def HasText()
		return @aInfo[5] > 0

	  #------------------#
	 #  THE TEXT        #
	#------------------#

	# Returns the body text in reading order, blocks separated by a blank line, page headers and footers left out.
	#
	#   returns    text
	def Text()
		return @cText

	# Returns the text of the blocks of page pnPage in reading order, page headers and footers left out.
	#
	#   pnPage     the page number, from 1
	#   returns    text; empty for a page with no text
	def TextOfPage(pnPage)
		_c_ = ""
		_n_ = ring_len(@aBlocks)
		for _i_ = 1 to _n_
			_aB_ = @aBlocks[_i_]
			if _aB_[1] != pnPage loop ok
			if _aB_[2] = "page_header" or _aB_[2] = "page_footer" loop ok
			if _c_ != "" _c_ += char(10) + char(10) ok
			_c_ += _aB_[11]
		next
		return _c_

	  #------------------#
	 #  THE BLOCKS      #
	#------------------#

	# Returns every block in reading order, each as a hash list of its page, kind, level, box, style, text and rows.
	#
	#   returns    a list of [ :page, :kind, :level, :box = [ x0, y0, x1, y1 ], :size, :bold, :mono, :text, :rows ]
	#   note       the box is in points from the page's top-left corner; :rows holds a table's cells
	def Blocks()
		_aRes_ = []
		_n_ = ring_len(@aBlocks)
		for _i_ = 1 to _n_
			_a_ = @aBlocks[_i_]
			_aRes_ + [ :page = _a_[1], :kind = _a_[2], :level = _a_[3], :box = [ _a_[4], _a_[5], _a_[6], _a_[7] ],
				   :size = _a_[8], :bold = _a_[9], :mono = _a_[10], :text = _a_[11], :rows = _a_[12] ]
		next
		return _aRes_

	# Counts the blocks the reader found, every kind included.
	#
	#   returns    a number
	def NumberOfBlocks()
		return ring_len(@aBlocks)

	# Returns the text of every block of the kind pcKind, in reading order.
	#
	#   pcKind     heading, paragraph, list_item, code, table, caption, page_header or page_footer
	#   returns    a list of texts
	def BlocksOfKind(pcKind)
		_cK_ = lower("" + pcKind)
		_aRes_ = []
		_n_ = ring_len(@aBlocks)
		for _i_ = 1 to _n_
			if @aBlocks[_i_][2] = _cK_ _aRes_ + @aBlocks[_i_][11] ok
		next
		return _aRes_

	# Returns the headings with their level, 1 for the largest type, in reading order.
	#
	#   returns    a list of [ level, text ] pairs
	def Headings()
		return This._LeveledOf("heading")

	# Returns the list items with their nesting level, 0 for the outermost, in reading order.
	#
	#   returns    a list of [ level, text ] pairs
	#   note       a bullet drawn as a shape counts as a marker; a written marker (1., a)) stays in the text
	def ListItems()
		return This._LeveledOf("list_item")

	# Returns the paragraphs of body text in reading order.
	#
	#   returns    a list of texts
	def Paragraphs()
		return This.BlocksOfKind("paragraph")

	# Returns the code blocks, set in a monospaced font, with their lines and indentation kept.
	#
	#   returns    a list of texts, lines separated by a newline
	def CodeBlocks()
		return This.BlocksOfKind("code")

	# Returns the captions found right above or below a table.
	#
	#   returns    a list of texts
	def Captions()
		return This.BlocksOfKind("caption")

	# Returns every table as its rows of cells; a merged cell repeats its text in every cell it covers.
	#
	#   returns    a list of tables, each a list of rows, each a list of texts
	#   note       only tables drawn with ruling lines are found; a table without rules reads as paragraphs
	def Tables()
		_aRes_ = []
		_n_ = ring_len(@aBlocks)
		for _i_ = 1 to _n_
			if @aBlocks[_i_][2] = "table" _aRes_ + @aBlocks[_i_][12] ok
		next
		return _aRes_

	# Returns the page headers and footers, the text repeated in the page margins, page numbers included.
	#
	#   returns    a list of texts
	def Furniture()
		_aRes_ = []
		_n_ = ring_len(@aBlocks)
		for _i_ = 1 to _n_
			if @aBlocks[_i_][2] = "page_header" or @aBlocks[_i_][2] = "page_footer" _aRes_ + @aBlocks[_i_][11] ok
		next
		return _aRes_

	def _LeveledOf(pcKind)
		_aRes_ = []
		_n_ = ring_len(@aBlocks)
		for _i_ = 1 to _n_
			if @aBlocks[_i_][2] = pcKind _aRes_ + [ @aBlocks[_i_][3], @aBlocks[_i_][11] ] ok
		next
		return _aRes_

	  #------------------#
	 #  PAGE IMAGES     #
	#------------------#

	# Returns the images drawn on the pages, in page order, each as a record: the page, the box it lands in
	# (page points, y down), its width and height in pixels, its bits per component, its components (1 gray,
	# 3 RGB, 4 CMYK), its stream filter, and its kind -- "samples" when the engine decoded it, "jpeg" when the
	# stream is a JPEG the engine hands out as it is, "unsupported" when it is neither (JPX, CCITT, JBIG2).
	#
	#   returns    a list of records [ :page, :box, :width, :height, :bits, :components, :filter, :kind ]
	def PageImages()
		_aRes_ = []
		_n_ = ring_len(@aImages)
		for _i_ = 1 to _n_
			_a_ = @aImages[_i_]
			_aRes_ + [ :page = _a_[1], :box = [ _a_[2], _a_[3], _a_[4], _a_[5] ], :width = _a_[6], :height = _a_[7],
				   :bits = _a_[8], :components = _a_[9], :filter = _a_[10], :kind = _a_[11] ]
		next
		return _aRes_

	def NumberOfImages()
		return ring_len(@aImages)

	def HasImages()
		return ring_len(@aImages) > 0

	# TRUE when the document is a scan: pages with images and no text layer.
	def IsScanned()
		return NOT This.HasText() and This.HasImages()

	# Writes image number pnImage to a file and returns its path: pcPathBase with ".jpg" for a JPEG stream, ".bmp"
	# for decoded samples; raises when the image is of a kind the engine does not hand out.
	#
	#   pnImage     the image's number in PageImages(), from 1
	#   pcPathBase  the path to write, without extension (the right one is added)
	#   returns     the path written
	def SaveImage(pnImage, pcPathBase)
		if pnImage < 1 or pnImage > ring_len(@aImages)
			stzraise("stzPdf: no image number " + pnImage + " (the document has " + ring_len(@aImages) + ")")
		ok
		_cKind_ = @aImages[pnImage][11]
		if _cKind_ = "unsupported"
			stzraise("stzPdf: image " + pnImage + " is " + @aImages[pnImage][10] + "-encoded, which the engine does not hand out")
		ok
		_cPath_ = pcPathBase + ".bmp"
		if _cKind_ = "jpeg" _cPath_ = pcPathBase + ".jpg" ok
		_n_ = StzEnginePdfOpen(@cPath)
		if _n_ < 0
			_cWhy_ = StzEnginePdfError()
			StzEnginePdfClose()
			stzraise("Can't re-read the PDF '" + @cPath + "': " + _cWhy_ + ".")
		ok
		_bOk_ = StzEnginePdfImageSave(pnImage, _cPath_)
		_cWhy_ = StzEnginePdfError()
		StzEnginePdfClose()
		if NOT _bOk_
			stzraise("stzPdf: image " + pnImage + " could not be written: " + _cWhy_)
		ok
		return _cPath_

	# Writes the largest image of a page to a temporary file and returns its path ("" when the page has none).
	def PageImageFile(pnPage)
		_nBest_ = This.PageImageNumber(pnPage)
		if _nBest_ = 0 return "" ok
		return This.SaveImage(_nBest_, sysget("TEMP") + "\stz_pdf_p" + pnPage + "_" + random(999999))

	# How many of an image's pixels make one PRINTED point (1/72 inch): the scale the page marks are found at (a rule
	# is 28 pt long, a bullet 2.5 to 9 pt). A PDF that sizes its page in real points says it directly (its width
	# between 400 and 900 points: a sheet of paper). A phone's scan app often sizes the page to the image instead
	# (one point per pixel: 1660 points wide), and then the paper is read from the image's proportions -- A4 at 1.41,
	# US Letter at 1.29 -- and the image is taken to span its width. Anything else keeps the PDF's own scale.
	#
	#   pnImage    the image's number in PageImages()
	#   returns    pixels per printed point (150 dpi: 2.083)
	def ImagePixelsPerPoint(pnImage)
		_a_ = @aImages[pnImage]
		_nW_ = _a_[4] - _a_[2]
		_nPx_ = _a_[6]
		_nPy_ = _a_[7]
		if _nW_ <= 0 or _nPx_ <= 0 return 150 / 72 ok
		if _nW_ >= 400 and _nW_ <= 900 return _nPx_ / _nW_ ok
		_nR_ = _nPy_ / _nPx_
		if _nR_ < 1 _nR_ = 1 / _nR_ ok
		_nShort_ = _nPx_
		if _nPy_ < _nPx_ _nShort_ = _nPy_ ok
		_dA_ = _nR_ - 1.414
		if _dA_ < 0 _dA_ = -_dA_ ok
		_dL_ = _nR_ - 1.294
		if _dL_ < 0 _dL_ = -_dL_ ok
		if _dA_ <= 0.04 return _nShort_ / 595.3 ok
		if _dL_ <= 0.04 return _nShort_ / 612 ok
		return _nPx_ / _nW_

	# The number in PageImages() of a page's largest image the engine hands out, 0 when it has none.
	def PageImageNumber(pnPage)
		_nBest_ = 0
		_nArea_ = 0
		_n_ = ring_len(@aImages)
		for _i_ = 1 to _n_
			if @aImages[_i_][1] = pnPage and @aImages[_i_][11] != "unsupported"
				_nA_ = @aImages[_i_][6] * @aImages[_i_][7]
				if _nA_ > _nArea_
					_nArea_ = _nA_
					_nBest_ = _i_
				ok
			ok
		next
		return _nBest_

	# The :ocr reader over the pages' images: the registry picks its implementation (the platform floor until a
	# model is measured better); its Text() is the pages' text in reading order of the lines.
	#
	#   pcLang     the language pack to read with, or "" for the user's own languages
	#   returns    a stzOcr
	def Ocr(pcLang)
		_aPages_ = []
		_nP_ = This.NumberOfPages()
		for _i_ = 1 to _nP_
			_c_ = This.PageImageFile(_i_)
			if _c_ != "" _aPages_ + _c_ ok
		next
		if ring_len(_aPages_) = 0
			stzraise("stzPdf: no page image to read -- the document has no image the engine hands out")
		ok
		return StzOcrQ([ :pages = _aPages_, :lang = pcLang ])

	# The text layer when there is one, the OCR text of the page images otherwise.
	def TextOrOcr(pcLang)
		if This.HasText() return @cText ok
		return This.Ocr(pcLang).Text()

	# Reads the document again with its scanned pages read through OCR (OCR slice O4): each page with no text
	# layer is read by the :ocr faculty (the registry picks the implementation per language), and its lines, each
	# with its box, enter the reader's layout as fragments. Blocks(), Text() and Info() are then those of the
	# scan, built by the reader's own rules: headings, lists, tables, page furniture and reading order.
	#
	#   pcLang     the language of the pages ("fr-FR", "ar-SA", "ru-RU"), or "" for the user's own languages
	#   returns    nothing; ReadOcrQ chains
	#   note       a page that has a text layer keeps it and is not read by OCR; a font size is ESTIMATED from
	#              each line's box, and no OCR line is bold (the faculty does not say)
	#   warning    raises when the faculty cannot read the language, or the PDF cannot be read again
	def ReadOcr(pcLang)
		# the pages that already have text keep it
		_aHas_ = []
		_nB_ = ring_len(@aBlocks)
		for _i_ = 1 to _nB_
			if ring_find(_aHas_, @aBlocks[_i_][1]) = 0 _aHas_ + @aBlocks[_i_][1] ok
		next
		StzEnginePdfOcrClear()
		@aOcrBy = []
		@aOcrMarks = []
		_nP_ = This.NumberOfPages()
		for _i_ = 1 to _nP_
			if ring_find(_aHas_, _i_) > 0 loop ok
			_nImg_ = This.PageImageNumber(_i_)
			if _nImg_ = 0 loop ok
			_cImg_ = This.PageImageFile(_i_)
			# a scan turned by a quarter of a degree or more is read from a level copy (its lines' boxes stay as tall
			# as their letters and its ruled lines stay lines; the copy turns about the centre, so the boxes still
			# land where their text is, within a few points at the corners), and a soft one from a sharpened copy when
			# the platform will read it (blur costs the platform's OCR; the PP-OCR model reads a blurred page better
			# as it is)
			_bMay_ = 0
			if StzOcrImplementationFor(pcLang) = "platform" _bMay_ = 1 ok
			_aPrep_ = StzEngineNeuralOcrPrepare(_cImg_, _cImg_ + "_prepared.bmp", 0.25, _bMay_)
			_nSkew_ = 0
			_bSharp_ = 0
			if ring_len(_aPrep_) = 4
				_nSkew_ = _aPrep_[1]
				_bSharp_ = _aPrep_[3]
				if _aPrep_[4] = 1 _cImg_ = _cImg_ + "_prepared.bmp" ok
			ok
			_aL_ = StzOcrLinesWithBoxes(_cImg_, pcLang)
			@aOcrBy + [ _i_, $cStzOcrLinesBy, ring_len(_aL_), _nSkew_, _bSharp_ ]
			# what the page shows besides its letters (rules, bullets, shadings) and each line's stroke width
			_nPpt_ = This.ImagePixelsPerPoint(_nImg_)
			_cBoxes_ = ""
			_nL_ = ring_len(_aL_)
			for _k_ = 1 to _nL_
				_aBx_ = _aL_[_k_][:box]
				if _k_ > 1 _cBoxes_ += ";" ok
				if ring_len(_aBx_) = 4
					_cBoxes_ += "" + _aBx_[1] + " " + _aBx_[2] + " " + _aBx_[3] + " " + _aBx_[4]
				else
					_cBoxes_ += "0 0 0 0"
				ok
			next
			_aMk_ = StzEngineNeuralOcrMarks(_cImg_, _nPpt_, _cBoxes_)
			_aStrokes_ = []
			if ring_len(_aMk_) = 2
				_nM_ = ring_len(_aMk_[1])
				for _k_ = 1 to _nM_
					_m_ = _aMk_[1][_k_]
					StzEnginePdfOcrMark(_i_, _m_[1], _m_[2], _m_[3], _m_[4], _m_[5])
				next
				_aStrokes_ = _aMk_[2]
				@aOcrMarks + [ _i_, _nM_ ]
			ok
			for _k_ = 1 to _nL_
				_aBx_ = _aL_[_k_][:box]
				if ring_len(_aBx_) = 4
					_nSt_ = 0
					if _k_ <= ring_len(_aStrokes_) _nSt_ = _aStrokes_[_k_] ok
					StzEnginePdfOcrAdd(_i_, _aBx_[1], _aBx_[2], _aBx_[3], _aBx_[4], _aL_[_k_][:text], _aL_[_k_][:tight], _nSt_)
				ok
			next
		next
		_n_ = StzEnginePdfOpenOcr(@cPath)
		StzEnginePdfOcrClear()
		if _n_ < 0
			_cWhy_ = StzEnginePdfError()
			StzEnginePdfClose()
			stzraise("Can't re-read the PDF '" + @cPath + "' with its OCR lines: " + _cWhy_ + ".")
		ok
		@aInfo = StzEnginePdfInfo()
		@aBlocks = StzEnginePdfBlocks()
		@cText = StzEnginePdfText()
		StzEnginePdfClose()
		@cOcrLang = "" + pcLang

		def ReadOcrQ(pcLang)
			This.ReadOcr(pcLang)
			return This

	# TRUE once ReadOcr laid out at least one page from OCR lines.
	def IsReadByOcr()
		return ring_len(@aOcrBy) > 0

	# Which implementation read each scanned page in the last ReadOcr: [ nPage, cImplementation, nLines, nSkew,
	# bSharpened ] per page ("platform" or "ppocr"; nSkew the degrees the page was turned level by, 0 when it was
	# level; bSharpened 1 when the page was soft and read from a sharpened copy).
	def OcrPages()
		return @aOcrBy

	# How many marks (rules, bullets, shadings) the last ReadOcr found in each scanned page's pixels: [ nPage, nMarks ].
	def OcrMarks()
		return @aOcrMarks
