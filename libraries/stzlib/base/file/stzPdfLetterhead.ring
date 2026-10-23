#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZPDFLETTERHEAD               #
#--------------------------------------------------------------#
#                                                              #
#   Description  : the LETTERHEAD decision, as a faculty above  #
#                  the native PDF reader. On the first page of  #
#                  a document, is a block the sender's identity #
#                  (a name or logo, an address, a phone, a tax  #
#                  number) or the document's own content (its   #
#                  title, its text)? The reader answers with a  #
#                  deterministic rule: that is the FLOOR. A     #
#                  model may answer instead only when it was    #
#                  MEASURED strictly better than the floor on   #
#                  an independent golden set; the registry      #
#                  decides, and explains why.                   #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

# Declares the :letterhead faculty: a block of page 1 (a record) in, letterhead or content out.
#
# Its floor is the reader's own rule; each generative model installed in the models directory is added
# as an implementation that reads its probability for the two answers. When paGolden is given, its items
# (each [ record, label ]) become the golden set every implementation is measured on.
#
#   paGolden   a list of [ record, "letterhead" | "content" ] pairs, or [ ] for none
#   returns    the faculty, a stzFaculty
func StzPdfDeclareLetterhead(paGolden)
	_o_ = StzFacultyQ(:letterhead)
	_o_.SetInputTypeQ(:record).SetOutputTypeQ(:label).SetParamsQ([ :labels = [ "letterhead", "content" ] ]).
	    SetFloorQ("reader-rule", "_StzLhFloor").SetGoldenCheckerQ("exact").SetGoldenVersionQ("v7")
	_aModels_ = [
		[ "granite-1b-choice",   "granite-4.0-1b",     "apache-2.0", 1800 ],
		[ "qwen25c-1.5b-choice", "qwen2.5-coder-1.5b", "apache-2.0", 1900 ],
		[ "granite42-3b-choice", "granite-4.2-3b",     "apache-2.0", 3000 ]
	]
	_aHave_ = _o_.ImplementationIds()
	for _i_ = 1 to len(_aModels_)
		if len(StzFind(_aModels_[_i_][1], _aHave_)) > 0 loop ok
		_o_.AddImplementation([ :id = _aModels_[_i_][1], :kind = "model", :fn = "_StzLhModel", :needle = _aModels_[_i_][2],
				       :licence = _aModels_[_i_][3], :memory = _aModels_[_i_][4] ])
	next
	if isList(paGolden) and len(_o_.Goldens()) = 0
		for _i_ = 1 to len(paGolden)
			_o_.AddGolden(paGolden[_i_][1], paGolden[_i_][2])
		next
	ok
	return _o_

# Returns the blocks of the top band of page 1 as records, each with the facts the decision is made from.
#
# The top band is the upper third of the first page. Each record holds the block's text, its size against
# the body text of the document, whether it is the largest text of the page, its rank from the top, and
# the reader's own verdict.
#
#   oPdf       a stzPdf
#   returns    a list of records: [ :text, :ratio, :largest, :rank, :reader ]
func StzPdfTopBlocks(oPdf)
	_aB_ = oPdf.Blocks()
	_nH_ = oPdf.PageHeight(1)
	# the body size: the size that holds the most text
	_aSz_ = []
	_aLen_ = []
	for _i_ = 1 to len(_aB_)
		_k_ = "" + (floor(_aB_[_i_][:size] * 2 + 0.5) / 2)
		_n_ = StzFind(_k_, _aSz_)
		if len(_n_) = 0
			_aSz_ + _k_
			_aLen_ + len(_aB_[_i_][:text])
		else
			_aLen_[_n_[1]] += len(_aB_[_i_][:text])
		ok
	next
	_nBody_ = 10
	_nBest_ = 0
	for _i_ = 1 to len(_aSz_)
		if _aLen_[_i_] > _nBest_
			_nBest_ = _aLen_[_i_]
			_nBody_ = 0 + _aSz_[_i_]
		ok
	next
	_nMax_ = 0
	for _i_ = 1 to len(_aB_)
		if _aB_[_i_][:page] = 1 and _aB_[_i_][:size] > _nMax_ _nMax_ = _aB_[_i_][:size] ok
	next
	_aRes_ = []
	_nRank_ = 0
	for _i_ = 1 to len(_aB_)
		_b_ = _aB_[_i_]
		if _b_[:page] != 1 loop ok
		if _b_[:box][2] > 0.33 * _nH_ loop ok
		if _b_[:kind] = "table" loop ok
		_nRank_++
		_cReader_ = "content"
		if _b_[:kind] = "page_header" or _b_[:kind] = "page_footer" _cReader_ = "letterhead" ok
		_aRes_ + [ :text = _b_[:text], :ratio = floor(_b_[:size] / _nBody_ * 10 + 0.5) / 10,
			   :largest = (_b_[:size] >= _nMax_ - 0.01), :rank = _nRank_, :reader = _cReader_ ]
	next
	return _aRes_

# Returns the furniture of a PDF with the letterhead of page 1 decided by the :letterhead faculty.
#
# The registry runs the implementation it chose (the reader's rule, unless a model was measured better)
# on every block of page 1's top band; the other furniture is the reader's.
#
#   pcPath     the path of the PDF file
#   returns    a list of texts
func StzPdfFurnitureDecided(pcPath)
	_o_ = StzPdfQ(pcPath)
	StzPdfDeclareLetterhead([])
	_aTop_ = StzPdfTopBlocks(_o_)
	_aRes_ = []
	_aFur_ = _o_.Furniture()
	for _i_ = 1 to len(_aFur_)
		_bTop_ = 0
		for _j_ = 1 to len(_aTop_)
			if _aTop_[_j_][:text] = _aFur_[_i_] _bTop_ = 1 ok
		next
		if _bTop_ = 0 _aRes_ + _aFur_[_i_] ok
	next
	for _i_ = 1 to len(_aTop_)
		_v_ = StzRunFaculty("letterhead", _aTop_[_i_], [], [], [], 0).Value()
		if isString(_v_) and _v_ = "letterhead" _aRes_ + _aTop_[_i_][:text] ok
	next
	return _aRes_

func _StzLhFloor(paRec, paParams)
	return paRec[:reader]

func _StzLhModel(paRec, paParams)
	_cYes_ = "no"
	if paRec[:largest] _cYes_ = "yes" ok
	_cSys_ = "You read the first page of a document. A LETTERHEAD is the sender's identity printed at the top: " +
		 "an organisation's name or logo text, its slogan, address, phone, e-mail, website, registration or tax numbers. " +
		 "The CONTENT is the document itself: its title (what kind of document it is, such as Invoice, Annual Report, " +
		 "Lab results, Timetable), its dates, references, names of people it is about, and its text. " +
		 "Answer with one word: letterhead or content."
	_cUser_ = "Block: " + paRec[:text] + char(10) + "Its size: " + paRec[:ratio] + " times the body text; the largest text on the page: " +
		  _cYes_ + "; position: block " + paRec[:rank] + " from the top of page 1."
	_aOpt_ = [ "letterhead", "content", "Letterhead", "Content" ]
	_aR_ = StzOptionProbabilities(StzChatPrompt(_cSys_, _cUser_), _aOpt_)
	if len(_aR_) = 0 stzraise("no generative model is loaded") ok
	_nL_ = _aR_[:probabilities][1][2] + _aR_[:probabilities][3][2]
	_nC_ = _aR_[:probabilities][2][2] + _aR_[:probabilities][4][2]
	_cAns_ = "content"
	_nP_ = 0.5
	if _nL_ + _nC_ > 0 _nP_ = _nC_ / (_nL_ + _nC_) ok
	if _nL_ > _nC_
		_cAns_ = "letterhead"
		_nP_ = _nL_ / (_nL_ + _nC_)
	ok
	$aStzImplNote = [ :certainty = StzBandOfProbability(_nP_), :p = _nP_, :detail = "read by probability" ]
	return _cAns_
