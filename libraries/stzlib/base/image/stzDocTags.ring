#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZDOCTAGS                     #
#--------------------------------------------------------------#
#                                                              #
#   Description  : DocTags -- the markup Granite-Docling writes #
#                  about a page (IM7, :doc-vlm) -- read into the #
#                  SAME blocks the native PDF reader returns    #
#                  (stzPdf.Blocks()), so one scorer judges both.#
#                                                              #
#--------------------------------------------------------------#

# The bar a page must reach to AGREE (the faculty's golden checker "doc-blocks"): the mean of the metrics that
# apply to the document. Fixed before any model read a page of the golden set. (A global sits ABOVE the first
# function: Ring reads a statement after a func as part of that function.)
$nStzDocAgreeBar = 0.9

/*
	What the model writes, for a page:

		<doctag><section_header_level_1><loc_47><loc_36><loc_402><loc_49>Results</section_header_level_1>
		<text><loc_47><loc_58><loc_437><loc_74>The first paragraph.</text>
		<otsl><loc_47><loc_108><loc_280><loc_174><fcel>Variety<fcel>Yield<nl><fcel>Sahel Gold<fcel>1,240<nl>
		<caption><loc_47><loc_101><loc_230><loc_108>Table 1. Yield</caption></otsl></doctag>

	Every tag is a token of the model's vocabulary. <loc_N> is a coordinate on a 500 x 500 grid over the page
	(which this reader leaves alone: the blocks come in the model's reading order); a table is OTSL, a cell per
	tag: <fcel> a cell with text, <ched> and <rhed> a column and a row header, <srow> a section row, <ecel> an
	empty cell, <lcel> and <ucel> a cell merged with the one to its left and above, <xcel> with both, <nl> the end
	of a row. A merged cell repeats its text in every cell it covers, as the PDF reader does.

	A block is [ :kind, :level, :text, :rows ] with a kind the PDF reader uses: heading, paragraph, list_item, code,
	caption, table, page_header, page_footer. A title and a section_header_level_N are headings (level 1 for a title,
	N for a section header); a footnote and a formula are paragraphs; a picture is not text and gives no block.
*/

# Returns the blocks of a DocTags text, in the order the model wrote them.
#
#   pcDocTags  the model's text, tags included
#   returns    a list of [ :kind, :level, :text, :rows ] (rows empty unless the kind is "table")
#   note       a tag the reader does not know is skipped and the text goes on; text outside any block is dropped
func StzDocTagsBlocks(pcDocTags)
	_aItems_ = _StzDocTagsItems("" + pcDocTags)
	_aRes_ = []
	_bBlock_ = 0
	_cKind_ = ""
	_nLevel_ = 0
	_cTxt_ = ""
	_bTable_ = 0
	_aRows_ = []
	_aRow_ = []
	_bCell_ = 0
	_cCell_ = ""
	_aAfter_ = []
	_nItems_ = ring_len(_aItems_)
	for _i_ = 1 to _nItems_
		_cItem_ = _aItems_[_i_][2]
		if _aItems_[_i_][1] = 0
			if _bBlock_
				_cTxt_ += _cItem_
			but _bCell_
				_cCell_ += _cItem_
			ok
			loop
		ok
		# a tag
		_cOpen_ = _StzDocTagsKindOf(_cItem_)
		if _cOpen_ != ""
			_bBlock_ = 1
			_cKind_ = _cOpen_
			_nLevel_ = _StzDocTagsLevelOf(_cItem_)
			_cTxt_ = ""
			# a cell in progress ends where a caption or a footnote begins inside a table
			if _bTable_ and _bCell_
				_aRow_ + _StzDocTagsTidy(_cCell_)
				_bCell_ = 0
				_cCell_ = ""
			ok
			loop
		ok
		if left(_cItem_, 1) = "/"
			_cName_ = right(_cItem_, ring_len(_cItem_) - 1)
			if _bBlock_ and _StzDocTagsKindOf(_cName_) = _cKind_
				_cTxt_ = _StzDocTagsTidy(_cTxt_)
				if _cTxt_ != ""
					_aBlock_ = [ :kind = _cKind_, :level = _nLevel_, :text = _cTxt_, :rows = [] ]
					if _bTable_
						_aAfter_ + _aBlock_
					else
						_aRes_ + _aBlock_
					ok
				ok
				_bBlock_ = 0
			but _cName_ = "otsl"
				if _bCell_
					_aRow_ + _StzDocTagsTidy(_cCell_)
				ok
				if ring_len(_aRow_) > 0
					_aRows_ + _aRow_
				ok
				_aRes_ + [ :kind = "table", :level = 0, :text = "", :rows = _aRows_ ]
				_nAfter_ = ring_len(_aAfter_)
				for _k_ = 1 to _nAfter_
					_aRes_ + _aAfter_[_k_]
				next
				_aAfter_ = []
				_bTable_ = 0
				_bCell_ = 0
				_aRows_ = []
				_aRow_ = []
			ok
			loop
		ok
		if _cItem_ = "otsl"
			_bTable_ = 1
			_aRows_ = []
			_aRow_ = []
			_aAfter_ = []
			_bCell_ = 0
			_cCell_ = ""
			loop
		ok
		if NOT _bTable_ loop ok
		# inside a table: a cell tag ends the cell in progress, and begins the next
		if _cItem_ = "fcel" or _cItem_ = "ched" or _cItem_ = "rhed" or _cItem_ = "srow" or _cItem_ = "ecel" or
		   _cItem_ = "lcel" or _cItem_ = "ucel" or _cItem_ = "xcel" or _cItem_ = "nl"
			if _bCell_
				_aRow_ + _StzDocTagsTidy(_cCell_)
				_bCell_ = 0
				_cCell_ = ""
			ok
			if _cItem_ = "nl"
				_aRows_ + _aRow_
				_aRow_ = []
			but _cItem_ = "ecel"
				_aRow_ + ""
			but _cItem_ = "lcel"
				_nW_ = ring_len(_aRow_)
				if _nW_ > 0 _aRow_ + _aRow_[_nW_] else _aRow_ + "" ok
			but _cItem_ = "ucel" or _cItem_ = "xcel"
				_nW_ = ring_len(_aRow_) + 1
				_nR_ = ring_len(_aRows_)
				if _nR_ > 0 and ring_len(_aRows_[_nR_]) >= _nW_
					_aRow_ + _aRows_[_nR_][_nW_]
				but ring_len(_aRow_) > 0
					_aRow_ + _aRow_[ring_len(_aRow_)]
				else
					_aRow_ + ""
				ok
			else
				_bCell_ = 1
				_cCell_ = ""
			ok
		ok
	next
	return _aRes_

# the block kind a content tag opens ("" for any other tag), the closing tag passing its name without the slash
func _StzDocTagsKindOf(pcTag)
	if pcTag = "text" or pcTag = "paragraph" or pcTag = "footnote" or pcTag = "formula" or pcTag = "reference"
		return "paragraph"
	but pcTag = "title" or left(pcTag, 21) = "section_header_level_"
		return "heading"
	but pcTag = "list_item"
		return "list_item"
	but pcTag = "caption"
		return "caption"
	but pcTag = "page_header"
		return "page_header"
	but pcTag = "page_footer"
		return "page_footer"
	but pcTag = "code"
		return "code"
	ok
	return ""

func _StzDocTagsLevelOf(pcTag)
	if pcTag = "title" return 1 ok
	if left(pcTag, 21) = "section_header_level_" return 0 + right(pcTag, ring_len(pcTag) - 21) ok
	return 0

# the text of a block or a cell: whitespace runs are one space, the ends are trimmed
func _StzDocTagsTidy(pcText)
	_c_ = "" + pcText
	_c_ = StzReplace(_c_, char(13), " ")
	_c_ = StzReplace(_c_, char(10), " ")
	_c_ = StzReplace(_c_, char(9), " ")
	while ring_len(StzFind("  ", _c_)) > 0
		_c_ = StzReplace(_c_, "  ", " ")
	end
	return ring_trim(_c_)

# the text cut into [ 0, text ] and [ 1, tag name ] items. A tag is "<", a lower-case name of letters, digits and
# "_" or "-" (with a leading "/" for a closing tag) and ">"; any other "<" is text. Every cut falls on an ASCII
# byte, so the UTF-8 between two tags is never split
func _StzDocTagsItems(pcS)
	_aRes_ = []
	_n_ = ring_len(pcS)
	_nFrom_ = 1
	_i_ = 1
	while _i_ <= _n_
		if pcS[_i_] = "<"
			_j_ = _i_ + 1
			_bTag_ = 0
			while _j_ <= _n_ and _j_ - _i_ <= 40
				_c_ = pcS[_j_]
				if _c_ = ">"
					_bTag_ = (_j_ > _i_ + 1)
					exit
				ok
				if NOT (islower(_c_) or isdigit(_c_) or _c_ = "_" or _c_ = "-" or (_c_ = "/" and _j_ = _i_ + 1))
					exit
				ok
				_j_++
			end
			if _bTag_
				if _i_ > _nFrom_
					_aRes_ + [ 0, substr(pcS, _nFrom_, _i_ - _nFrom_) ]
				ok
				_aRes_ + [ 1, substr(pcS, _i_ + 1, _j_ - _i_ - 1) ]
				_nFrom_ = _j_ + 1
				_i_ = _j_
			ok
		ok
		_i_++
	end
	if _nFrom_ <= _n_
		_aRes_ + [ 0, substr(pcS, _nFrom_, _n_ - _nFrom_ + 1) ]
	ok
	return _aRes_

  #-----------------------------------------------------------#
 #  JUDGING BLOCKS AGAINST A DOCUMENT'S EXPECTED STRUCTURE   #
#-----------------------------------------------------------#

# The seven metrics of base/test/document/_doc_score.py, the one scorer every document reader of the house is
# judged by, in Ring so a faculty's golden checker can call it: each a share in [ 0, 1 ], or "" when the document
# has nothing of that kind.
#
#   paBlocks   [ :kind, :level, :text, :rows ] blocks, as StzPdf.Blocks() and StzDocTagsBlocks() give them
#   paExp      what a correct reader recovers: [ :sentences = [ ... ], :headings = [ ... ], :tables = [ rows ... ],
#              :lists = [ ... ], :furniture = [ ... ], :code = [ ... ] ]
#   returns    [ text, order, headings, tables, lists, furniture, code ]
#              text      key body sentences found verbatim in the body text (whitespace collapsed)
#              order     of those found, consecutive pairs that appear in the expected order
#              headings  expected headings found among the heading blocks
#              tables    expected cells found at the same row and column in the best-matching table
#              lists     expected list items found among the list items (a marker before the text is allowed)
#              furniture expected header and footer strings kept OUT of the body text
#              code      expected code blocks found inside a code block
func StzDocBlocksScores(paBlocks, paExp)
	_aBody_ = []
	_aHeads_ = []
	_aLists_ = []
	_aCodes_ = []
	_aTables_ = []
	_nB_ = ring_len(paBlocks)
	for _i_ = 1 to _nB_
		_cK_ = paBlocks[_i_][:kind]
		if _cK_ = "page_header" or _cK_ = "page_footer" loop ok
		if _cK_ = "table"
			_aGrid_ = []
			_nR_ = ring_len(paBlocks[_i_][:rows])
			for _r_ = 1 to _nR_
				_aRow_ = []
				_nC_ = ring_len(paBlocks[_i_][:rows][_r_])
				for _c_ = 1 to _nC_
					_aRow_ + _StzDocTagsTidy(paBlocks[_i_][:rows][_r_][_c_])
				next
				_aGrid_ + _aRow_
				_aBody_ + StzJoinWith(_aRow_, " ")
			next
			_aTables_ + _aGrid_
			loop
		ok
		_cT_ = _StzDocTagsTidy(paBlocks[_i_][:text])
		if _cT_ = "" loop ok
		_aBody_ + _cT_
		if _cK_ = "heading"
			_aHeads_ + _cT_
		but _cK_ = "list_item"
			_aLists_ + _cT_
		but _cK_ = "code"
			_aCodes_ + _cT_
		ok
	next
	_cBody_ = StzJoinWith(_aBody_, " ")

	_aSent_ = paExp[:sentences]
	_nS_ = ring_len(_aSent_)
	_aPos_ = []
	_nFound_ = 0
	for _i_ = 1 to _nS_
		_aF_ = StzFind(_StzDocTagsTidy(_aSent_[_i_]), _cBody_)
		if ring_len(_aF_) > 0
			_aPos_ + _aF_[1]
			_nFound_++
		else
			_aPos_ + 0
		ok
	next
	_nPairs_ = 0
	_nInOrder_ = 0
	for _i_ = 1 to _nS_ - 1
		if _aPos_[_i_] > 0 and _aPos_[_i_ + 1] > 0
			_nPairs_++
			if _aPos_[_i_] < _aPos_[_i_ + 1] _nInOrder_++ ok
		ok
	next
	_aRes_ = [ _StzDocShare(_nFound_, _nS_), _StzDocShare(_nInOrder_, _nPairs_) ]

	_aEh_ = paExp[:headings]
	_nHit_ = 0
	for _i_ = 1 to ring_len(_aEh_)
		if ring_find(_aHeads_, _StzDocTagsTidy(_aEh_[_i_])) > 0 _nHit_++ ok
	next
	_aRes_ + _StzDocShare(_nHit_, ring_len(_aEh_))

	_nHit_ = 0
	_nTotal_ = 0
	for _t_ = 1 to ring_len(paExp[:tables])
		_nCells_ = 0
		_nBest_ = 0
		for _r_ = 1 to ring_len(paExp[:tables][_t_])
			_nCells_ += ring_len(paExp[:tables][_t_][_r_])
		next
		for _g_ = 1 to ring_len(_aTables_)
			_k_ = 0
			for _r_ = 1 to ring_len(paExp[:tables][_t_])
				for _c_ = 1 to ring_len(paExp[:tables][_t_][_r_])
					if _r_ <= ring_len(_aTables_[_g_]) and _c_ <= ring_len(_aTables_[_g_][_r_])
						if _aTables_[_g_][_r_][_c_] = _StzDocTagsTidy(paExp[:tables][_t_][_r_][_c_]) _k_++ ok
					ok
				next
			next
			if _k_ > _nBest_ _nBest_ = _k_ ok
		next
		_nHit_ += _nBest_
		_nTotal_ += _nCells_
	next
	_aRes_ + _StzDocShare(_nHit_, _nTotal_)

	_aEl_ = paExp[:lists]
	_nHit_ = 0
	for _i_ = 1 to ring_len(_aEl_)
		_cX_ = _StzDocTagsTidy(_aEl_[_i_])
		for _p_ = 1 to ring_len(_aLists_)
			if _aLists_[_p_] = _cX_ or right(_aLists_[_p_], ring_len(_cX_)) = _cX_
				_nHit_++
				exit
			ok
		next
	next
	_aRes_ + _StzDocShare(_nHit_, ring_len(_aEl_))

	_aEf_ = paExp[:furniture]
	_nHit_ = 0
	for _i_ = 1 to ring_len(_aEf_)
		if ring_len(StzFind(_StzDocTagsTidy(_aEf_[_i_]), _cBody_)) = 0 _nHit_++ ok
	next
	_aRes_ + _StzDocShare(_nHit_, ring_len(_aEf_))

	_aEc_ = paExp[:code]
	_nHit_ = 0
	for _i_ = 1 to ring_len(_aEc_)
		_cX_ = _StzDocTagsTidy(_aEc_[_i_])
		for _p_ = 1 to ring_len(_aCodes_)
			if ring_len(StzFind(_cX_, _aCodes_[_p_])) > 0
				_nHit_++
				exit
			ok
		next
	next
	_aRes_ + _StzDocShare(_nHit_, ring_len(_aEc_))
	return _aRes_

func _StzDocShare(pnHits, pnTotal)
	if pnTotal = 0 return "" ok  # no such metric for this document (a string: 0 is a score)
	return pnHits / pnTotal

# the mean of the metrics a document has (all seven are "" for an empty expectation: then 1)
func StzDocBlocksMean(paScores)
	_n_ = 0
	_nSum_ = 0
	for _i_ = 1 to ring_len(paScores)
		# "" is no metric; a score of 0 is a score (in Ring 0 = "" is TRUE: test the TYPE)
		if isNumber(paScores[_i_])
			_nSum_ += paScores[_i_]
			_n_++
		ok
	next
	if _n_ = 0 return 1 ok
	return _nSum_ / _n_

# the faculty's golden checker "doc-blocks": the page agrees when the mean of its metrics reaches the bar
func StzDocBlocksAgree(pBlocks, pExpected)
	if NOT isList(pBlocks) or NOT isList(pExpected) return 0 ok
	return StzDocBlocksMean(StzDocBlocksScores(pBlocks, pExpected)) >= $nStzDocAgreeBar
