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
