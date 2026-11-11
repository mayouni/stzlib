# _ticket_app.ring -- the first APPLICATION of the model-flow layer: a support desk.
#
# It is an EXAMPLE and a MEASUREMENT BED, not part of the library: every faculty here has a hand-written deterministic
# floor, a golden set whose answers are decided by a deterministic checker (no model judges a model), and model
# implementations that earn their place only by beating the floor on that set.
#
# Load AFTER stzBase.ring, then call StzTicketAppDeclare(). Functions live at the END of this file: in Ring,
# whatever follows a func belongs to it.
#
#   FLOW 1  retrieval     :retrieve (embed)  ->  :rerank           a question to the best help article
#   FLOW 2  text->record  :triage-extract                          a ticket to { product, severity }
#   FLOW 3  three stages  :brief -> :kind -> :route                a ticket summarised, classified, routed

$aTkModels = [
	# [ id, needle (a fragment of the GGUF name), licence, memory MB ]
	[ "smollm2-135m",  "smollm2-135m",       "apache-2.0",  200 ],
	[ "qwen3-0.6b",    "qwen3-0.6b-q8",      "apache-2.0",  700 ],
	[ "granite-350m",  "granite-4.0-350m",   "apache-2.0",  450 ],
	[ "granite-1b",    "granite-4.0-1b",     "apache-2.0", 1800 ],
	[ "qwen25c-0.5b",  "qwen2.5-coder-0.5b", "apache-2.0",  800 ],
	[ "qwen25c-1.5b",  "qwen2.5-coder-1.5b", "apache-2.0", 1900 ],
	[ "granite42-3b",  "granite-4.2-3b",     "apache-2.0", 3000 ],
	# NVIDIA's Nemotron 3.5 Bolt E4B (Gemma 4), the challenger of RADAR-NVIDIA-BOLTCOURT-01 (2026-11-11)
	[ "bolt-e4b",      "nemotron-3.5-bolt",  "openmdw-1.1", 6400 ],
	# Liquid AI's LFM3-1.7B (convolutions and gated attention), RADAR-LFM3-FAMILY-01 (2026-11-11)
	[ "lfm3-1.7b",     "lfm3-1.7b",          "lfm-1.0",     2100 ]
]

# THE GOLDEN SET: 36 tickets written by an INDEPENDENT author who never saw a floor (so a floor cannot be tuned to it),
# with deliberately tricky cases. Tab-separated: text, product, severity, kind, keyword the one-line brief must keep.
func StzTicketTickets()
	_aOut_ = []
	_aL_ = split(read("_data/tickets_heldout.tsv"), char(10))
	for _i_ = 1 to len(_aL_)
		_c_ = _aL_[_i_]
		if right(_c_, 1) = char(13) _c_ = left(_c_, len(_c_) - 1) ok
		if len(trim(_c_)) = 0 loop ok
		_aF_ = StzSplit(_c_, char(9))
		if len(_aF_) = 5 add(_aOut_, _aF_) ok
	next
	return _aOut_

# THE FRESH TICKETS of one language: [ [ text, product, severity ] ... ] from _data/tickets_fresh_frar.tsv (lang, product,
# severity, text a line)
func StzTicketFresh(pcLang)
	_aOut_ = []
	_aL_ = split(read("_data/tickets_fresh_frar.tsv"), char(10))
	for _i_ = 1 to len(_aL_)
		_c_ = _aL_[_i_]
		if right(_c_, 1) = char(13) _c_ = left(_c_, len(_c_) - 1) ok
		if len(trim(_c_)) = 0 loop ok
		_aF_ = StzSplit(_c_, char(9))
		if len(_aF_) = 4 and _aF_[1] = pcLang add(_aOut_, [ _aF_[4], _aF_[2], _aF_[3] ]) ok
	next
	return _aOut_

# THE RETRIEVAL SET'S OTHER LANGUAGES (v2): [ [ lang, articles, [ [ question, number of the right article ] ... ] ] ... ]
# read from _data/retrieval_v2.tsv -- lang, doc|query, number, text -- written before any challenger ran on it
func StzTicketRetrievalV2()
	_aOut_ = []
	_aL_ = split(read("_data/retrieval_v2.tsv"), char(10))
	for _i_ = 1 to len(_aL_)
		_c_ = _aL_[_i_]
		if right(_c_, 1) = char(13) _c_ = left(_c_, len(_c_) - 1) ok
		if len(trim(_c_)) = 0 loop ok
		_aF_ = StzSplit(_c_, char(9))
		if len(_aF_) != 4 loop ok
		_k_ = 0
		for _j_ = 1 to len(_aOut_)
			if _aOut_[_j_][1] = _aF_[1] _k_ = _j_ ok
		next
		if _k_ = 0
			add(_aOut_, [ _aF_[1], [], [] ])
			_k_ = len(_aOut_)
		ok
		if _aF_[2] = "doc"
			add(_aOut_[_k_][2], _aF_[4])
		but _aF_[2] = "query"
			add(_aOut_[_k_][3], [ _aF_[4], 0 + _aF_[3] ])
		ok
	next
	return _aOut_

# THE DEV SET: the 20 tickets the author of the floors READ while writing them. The extraction and kind floors were
# written looking at these, and score 1.0 on them: that proves nothing about generalisation, which is exactly why the
# golden set above is a different, independently written one. Kept for reference and for debugging a floor.
func StzTicketDevTickets()
	# [ text, product, severity, kind, keyword the one-line brief must keep ]
	return [
	[ "The mobile app crashes every time I open it, so my whole team is blocked.", "app", "high", "bug", "crash" ],
	[ "There is a small typo on the pricing page of your website.", "web", "low", "other", "typo" ],
	[ "Since this morning your API answers every request with a 500 error.", "api", "high", "bug", "500" ],
	[ "I was charged twice for my monthly subscription, please refund one payment.", "web", "high", "billing", "charged" ],
	[ "It would be nice if the dashboard had a dark theme someday.", "web", "low", "other", "dark" ],
	[ "The webhook endpoint stopped receiving events after your last update, our orders are lost.", "api", "high", "bug", "webhook" ],
	[ "My invoice shows the wrong company name, could you correct it when convenient?", "web", "low", "billing", "invoice" ],
	[ "The Android app freezes for a few seconds when scrolling the list, annoying but usable.", "app", "low", "bug", "freezes" ],
	[ "We cannot log in to the website at all, the page just spins forever.", "web", "high", "bug", "log in" ],
	[ "Please explain how the API pagination works, the docs are unclear.", "api", "low", "other", "pagination" ],
	[ "The iOS app drains my battery quickly since version 3.2.", "app", "low", "bug", "battery" ],
	[ "Our credit card was declined at renewal although the card is valid, service may stop today.", "web", "high", "billing", "declined" ],
	[ "Could you add an export button to the mobile app?", "app", "low", "other", "export" ],
	[ "The API rate limit seems lower than documented and our nightly job fails.", "api", "high", "bug", "rate limit" ],
	[ "I would like a copy of last year's invoices for my accountant.", "web", "low", "billing", "invoices" ],
	[ "Charts on the website render blank in Firefox, other browsers are fine.", "web", "low", "bug", "charts" ],
	[ "Every call to the API times out and our production site is down.", "api", "high", "bug", "times out" ],
	[ "The app shows the old price after the discount code was applied.", "app", "low", "billing", "price" ],
	[ "Thanks for the great service, just wanted to say hello.", "other", "low", "other", "hello" ],
	[ "The push notifications stopped on my phone and I miss urgent alerts from my clients.", "app", "high", "bug", "notifications" ]
	]

func StzTicketDocs()
	return [
	"To reset your password, open Settings and choose Security, then Reset password.",
	"Invoices are emailed on the first day of each month to the billing contact.",
	"The mobile app crashes on start when the cache is full; clear the cache to recover.",
	"Our API rate limit is 100 requests per minute per key.",
	"You can export all your data as CSV from the Account page.",
	"Two-factor authentication can be enabled with any authenticator app.",
	"Refunds are processed within five business days of approval.",
	"The status page shows live incidents and scheduled maintenance.",
	"Team members can be invited by email from the Members tab.",
	"Dark mode follows the system setting and can be forced in Preferences.",
	"Webhooks retry failed deliveries three times with exponential backoff.",
	"Annual plans are billed upfront and can be cancelled for a prorated refund."
	]

func StzTicketQueries()
	# [ question, index of the right article in StzTicketDocs() ] -- paraphrased, so word overlap alone is not enough
	return [
	[ "I forgot my login secret, how do I change it?", 1 ],
	[ "When will I get my money back?", 7 ],
	[ "app keeps closing right after it opens on my phone", 3 ],
	[ "how many calls per minute may I make", 4 ],
	[ "download everything I stored in spreadsheet form", 5 ],
	[ "add a second verification step to my account", 6 ],
	[ "where can I see if the service is down", 8 ],
	[ "invite a colleague to my team", 9 ],
	[ "make the screen dark", 10 ],
	[ "what happens when my callback endpoint is unavailable", 11 ],
	[ "stop my yearly subscription early", 12 ],
	[ "when do I get the monthly bill", 2 ]
	]

func StzTicketAppDeclare()
	_aTick_ = StzTicketTickets()
	_aDocs_ = StzTicketDocs()
	_aQ_ = StzTicketQueries()

	# ---- FLOW 1: retrieval -------------------------------------------------------------------
	# v2 (RADAR-NVIDIA-EMBEDSET-01, 2026-11-11): the 12 English questions, and 12 French and 12 Arabic ones, each over
	# its own language's help articles (_data/retrieval_v2.tsv), so a multilingual embedder is judged per language
	_o_ = StzFacultyQ(:retrieve)
	_o_.SetInputTypeQ(:record).SetOutputTypeQ(:record).SetFloorQ("word-idf", "_TkRetrieveFloor").SetGoldenCheckerQ("indocs").
	    SetGoldenVersionQ("v2").SetGoldenLanguageKeyQ(:lang)
	for _i_ = 1 to len(_aQ_)
		_o_.AddGolden([ :query = _aQ_[_i_][1], :docs = _aDocs_, :lang = "en" ], _aDocs_[_aQ_[_i_][2]])
	next
	_aML_ = StzTicketRetrievalV2()
	for _l_ = 1 to len(_aML_)
		_aD_ = _aML_[_l_][2]
		_aQL_ = _aML_[_l_][3]
		for _i_ = 1 to len(_aQL_)
			_o_.AddGolden([ :query = _aQL_[_i_][1], :docs = _aD_, :lang = _aML_[_l_][1] ], _aD_[_aQL_[_i_][2]])
		next
	next
	_o_.AddImplementation([ :id = "minilm-cosine", :kind = "model", :fn = "_TkRetrieveEmbed", :needle = "all-minilm",
				:licence = "apache-2.0", :memory = 60 ])
	# SigLIP2's text tower (the image plane's, multilingual by its Gemma vocabulary): a second embedder on the same set
	_o_.AddImplementation([ :id = "siglip2-text", :kind = "graph", :fn = "_TkRetrieveSiglip", :needle = "vision/siglip2_text.gguf",
				:licence = "apache-2.0", :memory = 1200 ])
	_o2_ = StzFacultyQ(:rerank)
	_o2_.SetInputTypeQ(:record).SetOutputTypeQ(:ranking).SetFloorQ("stem-overlap", "_TkRerankFloor").SetGoldenCheckerQ("first")
	for _i_ = 1 to len(_aQ_)
		_o2_.AddGolden([ :query = _aQ_[_i_][1], :docs = _aDocs_ ], _aDocs_[_aQ_[_i_][2]])
	next
	_o2_.AddImplementation([ :id = "jina-turbo", :kind = "model", :fn = "_TkRerankModel", :needle = "jina-reranker",
				 :licence = "apache-2.0", :memory = 80 ])

	# ---- FLOW 2: text -> record --------------------------------------------------------------
	_oSchema_ = StzTicketSchema()
	_o3_ = StzFacultyQ(:triage_extract)
	_o3_.SetInputTypeQ(:text).SetOutputTypeQ(:record).SetParamsQ([ :schema = _oSchema_ ]).SetFloorQ("keyword-rules", "_TkExtractFloor").
	     SetGoldenCheckerQ("fields")
	# STZ_TICKETS_FRESH = fr | ar: the FRESH tickets of that language instead (_data/tickets_fresh_frar.tsv, written
	# 2026-11-12 by an author who saw no floor, no model and no result), golden version fresh1-fr / fresh1-ar -- the
	# set that confirms or overturns, before Bolt is ever a default, its extraction win on the English set
	# (BOLT-PLACEMENT-01 (c)). The English set stays v1.
	_cFresh_ = sysget("STZ_TICKETS_FRESH")
	if _cFresh_ = "fr" or _cFresh_ = "ar"
		_o3_.SetGoldenVersion("fresh1-" + _cFresh_)
		_aF_ = StzTicketFresh(_cFresh_)
		for _i_ = 1 to len(_aF_)
			_o3_.AddGolden(_aF_[_i_][1], [ :product = _aF_[_i_][2], :severity = _aF_[_i_][3] ])
		next
	else
		for _i_ = 1 to len(_aTick_)
			_o3_.AddGolden(_aTick_[_i_][1], [ :product = _aTick_[_i_][2], :severity = _aTick_[_i_][3] ])
		next
	ok

	# ---- FLOW 3: brief -> kind -> route ---------------------------------------------------------
	_o4_ = StzFacultyQ(:brief)
	_o4_.SetInputTypeQ(:text).SetOutputTypeQ(:text).SetFloorQ("first-clause", "_TkBriefFloor").SetGoldenCheckerQ("kwmax")
	for _i_ = 1 to len(_aTick_)
		_o4_.AddGolden(_aTick_[_i_][1], _aTick_[_i_][5] + "|9")
	next
	_o5_ = StzFacultyQ(:kind)
	_o5_.SetInputTypeQ(:text).SetOutputTypeQ(:label).SetParamsQ([ :labels = [ "bug", "billing", "other" ] ]).SetFloorQ("keyword-rules", "_TkKindFloor").
	     SetGoldenCheckerQ("lower")
	for _i_ = 1 to len(_aTick_)
		_o5_.AddGolden(_aTick_[_i_][1], _aTick_[_i_][4])
	next
	_o6_ = StzFacultyQ(:route)
	_o6_.SetInputTypeQ(:label).SetOutputTypeQ(:record).SetParamsQ([ :schema = StzRouteSchema() ]).SetFloorQ("table", "_TkRoute").SetGoldenCheckerQ("fields")
	_o6_.AddGoldenQ("bug", [ :queue = "engineering", :hours = 8 ]).AddGoldenQ("billing", [ :queue = "finance", :hours = 24 ]).
	     AddGoldenQ("other", [ :queue = "support", :hours = 72 ])

	# ---- the model implementations, one per installed model, on every generative faculty ------------------
	for _m_ = 1 to len($aTkModels)
		_a_ = $aTkModels[_m_]
		_o3_.AddImplementation([ :id = _a_[1], :kind = "model", :fn = "_TkExtractModel", :needle = _a_[2], :licence = _a_[3], :memory = _a_[4] ])
		_o4_.AddImplementation([ :id = _a_[1], :kind = "model", :fn = "_TkBriefModel",   :needle = _a_[2], :licence = _a_[3], :memory = _a_[4] ])
		_o5_.AddImplementation([ :id = _a_[1], :kind = "model", :fn = "_TkKindModel",    :needle = _a_[2], :licence = _a_[3], :memory = _a_[4] ])
		# the same models read by PROBABILITY instead of generation (StzOptionProbabilities): one forward pass, no parsing
		_o3_.AddImplementation([ :id = _a_[1] + "-choice", :kind = "model", :fn = "_TkExtractChoice", :needle = _a_[2], :licence = _a_[3], :memory = _a_[4] ])
		_o5_.AddImplementation([ :id = _a_[1] + "-choice", :kind = "model", :fn = "_TkKindChoice",    :needle = _a_[2], :licence = _a_[3], :memory = _a_[4] ])
	next
	return 1

func StzTicketSchema()
	return StzOutputSchemaQ([
		[ :field = "product",  :type = :oneof, :choices = [ "app", "web", "api", "other" ] ],
		[ :field = "severity", :type = :oneof, :choices = [ "low", "high" ] ]
	])

func StzRouteSchema()
	return StzOutputSchemaQ([
		[ :field = "queue", :type = :oneof, :choices = [ "engineering", "finance", "support" ] ],
		[ :field = "hours", :type = :number, :must = [ [ ">=", 1 ], [ "<=", 72 ] ] ]
	])

# ================= the implementations ==================================================================

# ---- words, for the retrieval floors --------------------------------------------------------------------
func _TkWords(cText)
	_c_ = lower(cText)
	# a new text, not _c_[_i_] = " ": Ring++ does not assign into a text by
	# index (Ring did), it raises Bad parameter type (2026-11-07)
	_o_ = ""
	for _i_ = 1 to len(_c_)
		_n_ = ascii(_c_[_i_])
		# letters and digits stay; everything else becomes a space (compared by code: Ring's >= does not order strings)
		if (_n_ >= 97 and _n_ <= 122) or (_n_ >= 48 and _n_ <= 57)
			_o_ += _c_[_i_]
		else
			_o_ += " "
		ok
	next
	_a_ = []
	_aW_ = split(_o_, " ")
	for _i_ = 1 to len(_aW_)
		if len(_aW_[_i_]) > 2 add(_a_, _aW_[_i_]) ok
	next
	return _a_

func _TkStem(cWord)
	if len(cWord) > 4 return left(cWord, 4) ok
	return cWord

# document frequency of a (stemmed or not) term over the corpus
func _TkDf(aDocWords, cTerm)
	_n_ = 0
	for _i_ = 1 to len(aDocWords)
		if len(StzFind(cTerm, aDocWords[_i_])) > 0 _n_++ ok
	next
	return _n_

func _TkScoreDocs(cQuery, aDocs, bStem)
	_aQ_ = _TkWords(cQuery)
	_aDW_ = []
	for _i_ = 1 to len(aDocs)
		_aW_ = _TkWords(aDocs[_i_])
		if bStem = 1
			for _k_ = 1 to len(_aW_) _aW_[_k_] = _TkStem(_aW_[_k_]) next
		ok
		add(_aDW_, _aW_)
	next
	_aScored_ = []
	for _i_ = 1 to len(aDocs)
		_s_ = 0
		for _k_ = 1 to len(_aQ_)
			_t_ = _aQ_[_k_]
			if bStem = 1 _t_ = _TkStem(_t_) ok
			if len(StzFind(_t_, _aDW_[_i_])) > 0
				_s_ += log((len(aDocs) + 1) / (_TkDf(_aDW_, _t_) + 1)) + 1
			ok
		next
		add(_aScored_, [ aDocs[_i_], _s_ ])
	next
	# best first (stable for ties: earlier document wins)
	for _i_ = 1 to len(_aScored_) - 1
		_m_ = _i_
		for _j_ = _i_ + 1 to len(_aScored_)
			if _aScored_[_j_][2] > _aScored_[_m_][2] _m_ = _j_ ok
		next
		if _m_ != _i_
			_t2_ = _aScored_[_i_]
			_aScored_[_i_] = _aScored_[_m_]
			_aScored_[_m_] = _t2_
		ok
	next
	return _aScored_

# ---- FLOW 1 -----------------------------------------------------------------------------------------------
func _TkRetrieveFloor(aRec, aParams)
	_aS_ = _TkScoreDocs(aRec[:query], aRec[:docs], 0)
	_aTop_ = []
	for _i_ = 1 to min([4, len(_aS_)])
		add(_aTop_, _aS_[_i_][1])
	next
	return [ :query = aRec[:query], :docs = _aTop_ ]

func _TkCosine(aA, aB)
	_d_ = 0 _na_ = 0 _nb_ = 0
	for _i_ = 1 to len(aA)
		_d_ += aA[_i_] * aB[_i_]
		_na_ += aA[_i_] * aA[_i_]
		_nb_ += aB[_i_] * aB[_i_]
	next
	if _na_ = 0 or _nb_ = 0 return 0 ok
	return _d_ / (sqrt(_na_) * sqrt(_nb_))

func _TkRetrieveEmbed(aRec, aParams)
	_aQv_ = StzNeuralEmbeddingOf(aRec[:query])
	_aScored_ = []
	for _i_ = 1 to len(aRec[:docs])
		add(_aScored_, [ aRec[:docs][_i_], _TkCosine(_aQv_, StzNeuralEmbeddingOf(aRec[:docs][_i_])) ])
	next
	for _i_ = 1 to len(_aScored_) - 1
		_m_ = _i_
		for _j_ = _i_ + 1 to len(_aScored_)
			if _aScored_[_j_][2] > _aScored_[_m_][2] _m_ = _j_ ok
		next
		if _m_ != _i_
			_t_ = _aScored_[_i_]
			_aScored_[_i_] = _aScored_[_m_]
			_aScored_[_m_] = _t_
		ok
	next
	_aTop_ = []
	for _i_ = 1 to min([4, len(_aScored_)])
		add(_aTop_, _aScored_[_i_][1])
	next
	return [ :query = aRec[:query], :docs = _aTop_ ]

# the same ranking by SigLIP2's text tower: its vectors are L2-normalized, so the dot product is the cosine
func _TkRetrieveSiglip(aRec, aParams)
	_aQv_ = StzVisionTextEmbedding(aRec[:query])
	_aScored_ = []
	for _i_ = 1 to len(aRec[:docs])
		add(_aScored_, [ aRec[:docs][_i_], _TkCosine(_aQv_, StzVisionTextEmbedding(aRec[:docs][_i_])) ])
	next
	for _i_ = 1 to len(_aScored_) - 1
		_m_ = _i_
		for _j_ = _i_ + 1 to len(_aScored_)
			if _aScored_[_j_][2] > _aScored_[_m_][2] _m_ = _j_ ok
		next
		if _m_ != _i_
			_t_ = _aScored_[_i_]
			_aScored_[_i_] = _aScored_[_m_]
			_aScored_[_m_] = _t_
		ok
	next
	_aTop_ = []
	for _i_ = 1 to min([4, len(_aScored_)])
		add(_aTop_, _aScored_[_i_][1])
	next
	return [ :query = aRec[:query], :docs = _aTop_ ]

func _TkRerankFloor(aRec, aParams)
	return _TkScoreDocs(aRec[:query], aRec[:docs], 1)

func _TkRerankModel(aRec, aParams)
	return StzRerank(aRec[:query], aRec[:docs])

# ---- FLOW 2: the floor reads keywords; the model reads the ticket -------------------------------------------
func _TkHas(cText, acWords)
	_c_ = lower(cText)
	for _i_ = 1 to len(acWords)
		if len(StzFind(acWords[_i_], _c_)) > 0 return 1 ok
	next
	return 0

func _TkExtractFloor(cText, aParams)
	_cProduct_ = "other"
	if _TkHas(cText, [ "api", "webhook", "endpoint", "rate limit", "pagination" ])
		_cProduct_ = "api"
	but _TkHas(cText, [ "app", "android", "ios", "phone", "mobile", "push" ])
		_cProduct_ = "app"
	but _TkHas(cText, [ "website", "page", "dashboard", "browser", "log in", "chart", "invoice", "charged", "subscription", "card" ])
		_cProduct_ = "web"
	ok
	_cSev_ = "low"
	if _TkHas(cText, [ "crash", "cannot", "500", "every", "down", "blocked", "lost", "stopped", "declined", "today", "twice", "urgent", "forever", "fails" ])
		_cSev_ = "high"
	ok
	return [ :product = _cProduct_, :severity = _cSev_ ]

func _TkExtractModel(cText, aParams)
	_oF_ = new stzLLMFunction("triage-extract")
	_oF_.SetPrompt("Read this support ticket and fill in the fields: the product it is about (app, web, api or other) and how severe it is (low or high).\nTicket: {input}")
	_oF_.ReturnsStructure([
		[ :field = "product",  :type = :oneof, :choices = [ "app", "web", "api", "other" ] ],
		[ :field = "severity", :type = :oneof, :choices = [ "low", "high" ] ] ])
	_oF_.Budget(3)
	_oF_.SetMaxTokens(40)
	return _oF_.Call_(cText)

# ---- FLOW 3 -------------------------------------------------------------------------------------------------
func _TkBriefFloor(cText, aParams)
	# the first clause, cut to nine words
	_c_ = cText
	_n_ = StzFindFirst(",", _c_)
	if _n_ > 0 _c_ = left(_c_, _n_ - 1) ok
	_aW_ = split(trim(_c_), " ")
	_o_ = ""
	for _i_ = 1 to min([9, len(_aW_)])
		if _o_ != "" _o_ += " " ok
		_o_ += _aW_[_i_]
	next
	return _o_

func _TkBriefModel(cText, aParams)
	_cP_ = StzChatPrompt("You write one very short summary of a support ticket: at most eight words, no preamble.", "Ticket: " + cText + char(10) + "Summary in at most eight words:")
	_c_ = trim(StzGenerate(_cP_, 24))
	_n_ = StzFindFirst(char(10), _c_)
	if _n_ > 0 _c_ = left(_c_, _n_ - 1) ok
	return trim(_c_)

func _TkKindFloor(cText, aParams)
	if _TkHas(cText, [ "charged", "invoice", "refund", "card", "billing", "renewal", "price", "payment" ]) return "billing" ok
	if _TkHas(cText, [ "crash", "error", "500", "freez", "fails", "stopped", "down", "blank", "drains", "times out", "cannot", "spins", "lost", "wrong" ]) return "bug" ok
	return "other"

func _TkKindModel(cText, aParams)
	_oF_ = new stzLLMFunction("triage-kind")
	_oF_.SetPrompt("Classify this support ticket as bug, billing or other.\nTicket: {input}")
	_oF_.ReturnsOneOf([ "bug", "billing", "other" ])
	_oF_.Budget(3)
	_oF_.SetMaxTokens(8)
	return _oF_.Call_(cText)

# ---- choice by probability ----------------------------------------------------------------------------------
# Reads the model's next-token distribution over the candidate answers (lower-case and Capitalised, since a model
# may begin either way) and returns the best label with its probability among the candidates and the mass they hold.
func _TkChoice(cSystem, cUser, acOptions)
	_cP_ = StzChatPrompt(cSystem, cUser)
	# each option and its capitalised twin -- the twin only when its first token is no other option's first token
	# (2026-11-11: in LFM3's vocabulary "Bug" and "Billing" both begin with "B", and StzOptionProbabilities refuses
	# options it cannot tell apart, so every :kind reading of that model failed; no model measured before had a clash)
	_aFirst_ = []
	for _i_ = 1 to len(acOptions)
		add(_aFirst_, _TkFirstToken(acOptions[_i_]))
	next
	_aAll_ = []
	_aOwner_ = []
	for _i_ = 1 to len(acOptions)
		add(_aAll_, acOptions[_i_])
		add(_aOwner_, _i_)
	next
	for _i_ = 1 to len(acOptions)
		_cCap_ = upper(left(acOptions[_i_], 1)) + right(acOptions[_i_], len(acOptions[_i_]) - 1)
		_nT_ = _TkFirstToken(_cCap_)
		if len(StzFind(_nT_, _aFirst_)) = 0
			add(_aAll_, _cCap_)
			add(_aOwner_, _i_)
			add(_aFirst_, _nT_)
		ok
	next
	_aR_ = StzOptionProbabilities(_cP_, _aAll_)
	if len(_aR_) = 0 stzraise("no generative model is loaded") ok
	_aSum_ = []
	for _i_ = 1 to len(acOptions)
		add(_aSum_, 0)
	next
	_nTot_ = 0
	for _k_ = 1 to len(_aAll_)
		_aSum_[_aOwner_[_k_]] += _aR_[:probabilities][_k_][2]
		_nTot_ += _aR_[:probabilities][_k_][2]
	next
	_nBest_ = 1
	for _i_ = 2 to len(acOptions)
		if _aSum_[_i_] > _aSum_[_nBest_] _nBest_ = _i_ ok
	next
	_nShare_ = 0
	if _nTot_ > 0 _nShare_ = _aSum_[_nBest_] / _nTot_ ok
	return [ acOptions[_nBest_], _nShare_, _nTot_ ]

# the first token of a word, after a BOS the tokenizer may prepend (found as StzOptionProbabilities finds it)
func _TkFirstToken(cWord)
	StzEngineNeuralGenTokenize("a")
	_nA_ = StzEngineNeuralGenTokenAt(0)
	StzEngineNeuralGenTokenize("b")
	_nSkip_ = 0
	if StzEngineNeuralGenTokenAt(0) = _nA_ _nSkip_ = 1 ok
	StzEngineNeuralGenTokenize(cWord)
	return StzEngineNeuralGenTokenAt(_nSkip_)

func _TkNoteChoice(nShare)
	$aStzImplNote = [ :certainty = StzBandOfProbability(nShare), :p = nShare, :detail = "read by probability" ]

func _TkKindChoice(cText, aParams)
	_a_ = _TkChoice("You triage customer-support tickets. Classify the ticket as exactly one of: bug (something is broken or behaves wrongly), billing (money: charges, refunds, invoices, plans, prices), other (a question, request or feedback). Answer with the single word.",
		"Ticket: " + cText, [ "bug", "billing", "other" ])
	_TkNoteChoice(_a_[2])
	return _a_[1]

func _TkExtractChoice(cText, aParams)
	_aP_ = _TkChoice("You triage customer-support tickets. Which product is the ticket about: app (the mobile app), web (the website, dashboard, account or billing pages), api (the developer API, SDKs, webhooks), or other? Answer with the single word.",
		"Ticket: " + cText, [ "app", "web", "api", "other" ])
	_aS_ = _TkChoice("You triage customer-support tickets. How severe is it: high (it blocks the customer's work, loses money or data, is an outage, or has a deadline today or tomorrow) or low (anything else)? Answer with the single word.",
		"Ticket: " + cText, [ "high", "low" ])
	_TkNoteChoice(_aP_[2] * _aS_[2])
	return [ :product = _aP_[1], :severity = _aS_[1] ]

func _TkRoute(cLabel, aParams)
	if cLabel = "bug" return [ :queue = "engineering", :hours = 8 ] ok
	if cLabel = "billing" return [ :queue = "finance", :hours = 24 ] ok
	return [ :queue = "support", :hours = 72 ]
