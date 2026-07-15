# base/cluster/stzRequestClassifier.ring
# -----------------------------------------------------------------------------
# R8.2 (the SCALE plane) -- stzRequestClassifier: THE SMART ROUTER.
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md section 7.)
#
# The 2024 doc's "domain-aware load balancer" was hand-wavy; this is the
# real thing. It maps an incoming request to a FACET (the routing target,
# R8.1) in three tiers, cheap-to-rich:
#   TIER 1  RULES     -- deterministic path / content-type / method rules
#                        (fast, explicit, no analysis): the operator's
#                        known routes.
#   TIER 2  LEXICAL   -- capability-lexical scoring: tokenize the request
#                        (engine Unicode text ops) and score against each
#                        facet's OWN capability vocabulary + a synonym
#                        lexicon, drawn from THIS deployment's catalog.
#                        Always available, deterministic, offline.
#   TIER 3  MODEL     -- an OPTIONAL engine classifier seam
#                        (WithModelClassifier): zero-shot / embedding
#                        similarity when a neural model is loaded. The
#                        richer path; never required for the floor.
#
# The classifier only routes to facets THIS deployment's catalog knows
# (instance-scoped, per the R8 naming law) -- UsingCatalog binds it to a
# cluster's catalog.
#
#   oR = new stzRequestClassifier()
#   oR.RouteWhenPath("/api/risk", :math).RouteWhenContentType("application/pdf", :vision)
#   ? oR.Classify("POST", "/api/analyze-contract", "application/pdf", "review this NDA")
#     #--> vision (content-type rule wins; body would also lexically hit :nlp)
#   ? oR.ClassifyText("find the shortest path between two nodes")   #--> graph
# -----------------------------------------------------------------------------

func StzRequestClassifier()
	return new stzRequestClassifier()

class stzRequestClassifier from stzObject

	@oCatalog = NULL       # the facet vocabulary this router classifies to
	@aPathRules = []       # [ prefix, facet ]
	@aTypeRules = []       # [ contentType-substring, facet ]
	@aMethodRules = []     # [ method, facet ]
	@aKeywords = []        # [ keyword, facet ]  synonym lexicon (augments caps)
	@fModel = NULL         # optional tier-3 engine classifier: f(text)->facet
	@cWhy = ""

	def init()
		@oCatalog = new stzFacetCatalog()
		This._SeedKeywords()

	# Bind to a specific (e.g. a cluster's) catalog -- so the router routes
	# to exactly the facets THAT deployment offers.
	def UsingCatalog(poCatalog)
		@oCatalog = poCatalog
		return This

	def CatalogQ()
		return @oCatalog

	def Why()
		return @cWhy

	#-- TIER 1: deterministic rules ----------------------------------------

	# A path whose start matches pcPrefix routes to pcFacet.
	def RouteWhenPath(pcPrefix, pcFacet)
		@aPathRules + [ StzLower("" + pcPrefix), StzLower("" + pcFacet) ]
		return This

	# A request whose Content-Type CONTAINS pcType routes to pcFacet.
	def RouteWhenContentType(pcType, pcFacet)
		@aTypeRules + [ StzLower("" + pcType), StzLower("" + pcFacet) ]
		return This

	def RouteWhenMethod(pcMethod, pcFacet)
		@aMethodRules + [ StzUpper("" + pcMethod), StzLower("" + pcFacet) ]
		return This

	#-- TIER 2: the capability-lexical vocabulary --------------------------

	# Extend the synonym lexicon (a word that hints a facet). Capability
	# names are matched automatically; keywords add natural phrasing.
	def AddKeyword(pcKeyword, pcFacet)
		@aKeywords + [ StzLower("" + pcKeyword), StzLower("" + pcFacet) ]
		return This

	#-- TIER 3: an optional engine classifier ------------------------------

	# f(cText) -> facet name (or ""). Used only when tiers 1+2 abstain.
	def WithModelClassifier(fClassify)
		@fModel = fClassify
		return This

	#-- classification -----------------------------------------------------

	# Route a full request to a facet ("" if undecidable). Rules first,
	# then lexical, then the model seam. Why() explains the decision.
	def Classify(pcMethod, pcPath, pcContentType, pcBody)
		_cPath_ = StzLower("" + pcPath)
		_cType_ = StzLower("" + pcContentType)
		_cMethod_ = StzUpper("" + pcMethod)

		# TIER 1 -- content-type, then path, then method
		_n_ = len(@aTypeRules)
		for _i_ = 1 to _n_
			if _cType_ != "" and StzFindFirst(_cType_, @aTypeRules[_i_][1]) > 0
				return This._Decide(@aTypeRules[_i_][2], "rule: content-type '" + @aTypeRules[_i_][1] + "'")
			ok
		next
		_n_ = len(@aPathRules)
		for _i_ = 1 to _n_
			if StzFindFirst(_cPath_, @aPathRules[_i_][1]) = 1
				return This._Decide(@aPathRules[_i_][2], "rule: path '" + @aPathRules[_i_][1] + "'")
			ok
		next
		_n_ = len(@aMethodRules)
		for _i_ = 1 to _n_
			if _cMethod_ = @aMethodRules[_i_][1]
				return This._Decide(@aMethodRules[_i_][2], "rule: method " + @aMethodRules[_i_][1])
			ok
		next

		# TIER 2 -- capability-lexical over path + body
		_cFacet_ = This._LexicalFacet(_cPath_ + " " + StzLower("" + pcBody))
		if _cFacet_ != ""
			return _cFacet_   # _Decide already set Why inside
		ok

		# TIER 3 -- optional model seam
		if @fModel != NULL
			_f_ = @fModel
			_cM_ = "" + call _f_("" + pcPath + " " + pcBody)
			if _cM_ != "" and @oCatalog.Has(_cM_)
				return This._Decide(StzLower(_cM_), "model classifier")
			ok
		ok

		@cWhy = "undecidable: no rule, lexical, or model match"
		return ""

	def ClassifyPath(pcPath)
		return This.Classify("GET", pcPath, "", "")

	def ClassifyText(pcText)
		_cFacet_ = This._LexicalFacet(StzLower("" + pcText))
		if _cFacet_ != ""  return _cFacet_  ok
		if @fModel != NULL
			_f_ = @fModel
			_cM_ = "" + call _f_("" + pcText)
			if _cM_ != "" and @oCatalog.Has(_cM_)
				return This._Decide(StzLower(_cM_), "model classifier")
			ok
		ok
		@cWhy = "undecidable"
		return ""

	# COMPAT (retires the pre-engine classifier in place): the old
	# stzLoadBalancer calls this with an stzAppRequest.
	def ClassifyComputationalDomain(oRequest)
		return This.Classify(oRequest.Method(), oRequest.Path(), "", oRequest.Body())

	#-- internals ----------------------------------------------------------

	# Score the text against every catalog facet: +1 per token matching a
	# capability name of the facet, +1 per token matching a synonym keyword
	# mapped to it. Highest score wins (ties -> first in catalog order).
	def _LexicalFacet(pcText)
		_aTokens_ = This._Tokenize(pcText)
		if len(_aTokens_) = 0
			@cWhy = "no tokens"
			return ""
		ok
		_aFacets_ = @oCatalog.Names()
		_nF_ = len(_aFacets_)
		_cBest_ = ""
		_nBest_ = 0
		for _f_ = 1 to _nF_
			_cFacet_ = StzLower("" + _aFacets_[_f_])
			_nScore_ = This._ScoreFacet(_cFacet_, _aTokens_)
			if _nScore_ > _nBest_
				_nBest_ = _nScore_
				_cBest_ = _cFacet_
			ok
		next
		if _nBest_ = 0
			@cWhy = "lexical: no capability/keyword hit"
			return ""
		ok
		return This._Decide(_cBest_, "lexical: " + _nBest_ + " hit(s)")

	def _ScoreFacet(pcFacet, paTokens)
		_nScore_ = 0
		_aCaps_ = @oCatalog.CapabilitiesOf(pcFacet)
		_nT_ = len(paTokens)
		for _t_ = 1 to _nT_
			_cTok_ = paTokens[_t_]
			_nC_ = len(_aCaps_)
			for _c_ = 1 to _nC_
				if _cTok_ = StzLower("" + _aCaps_[_c_])
					_nScore_++
				ok
			next
			_nK_ = len(@aKeywords)
			for _k_ = 1 to _nK_
				if @aKeywords[_k_][2] = pcFacet and @aKeywords[_k_][1] = _cTok_
					_nScore_++
				ok
			next
		next
		return _nScore_

	# Unicode-aware tokenize: lowercase (done by caller), punctuation ->
	# space, split on space, drop empties.
	def _Tokenize(pcText)
		_c_ = "" + pcText
		_aPunct_ = [ "/", ".", ",", "-", "_", "?", "&", "=", ":", ";", "(", ")",
		             "[", "]", "{", "}", "!", char(34), char(39), char(9), char(10), char(13) ]
		_n_ = len(_aPunct_)
		for _i_ = 1 to _n_
			_c_ = StzReplace(_c_, _aPunct_[_i_], " ")
		next
		_aRaw_ = StzSplit(_c_, " ")
		_aOut_ = []
		_nR_ = len(_aRaw_)
		for _i_ = 1 to _nR_
			if ring_trim(_aRaw_[_i_]) != ""
				_aOut_ + ring_trim(_aRaw_[_i_])
			ok
		next
		return _aOut_

	def _Decide(pcFacet, pcWhy)
		@cWhy = pcWhy + " -> " + pcFacet
		return pcFacet

	# Natural-phrasing synonyms over the STANDARD facets (a custom facet
	# added to the catalog can gain synonyms via AddKeyword).
	def _SeedKeywords()
		@aKeywords = []
		This._Kw(:text, [ "text", "string", "uppercase", "lowercase", "replace" ])
		This._Kw(:list, [ "list", "sort", "filter", "dedup", "unique" ])
		This._Kw(:table, [ "table", "csv", "column", "row", "dataframe", "aggregate" ])
		This._Kw(:number, [ "number", "arithmetic", "convert", "format" ])
		This._Kw(:math, [ "math", "matrix", "optimize", "optimization", "risk",
		                  "statistics", "statistical", "calculate", "calculation",
		                  "financial", "model", "regression" ])
		This._Kw(:graph, [ "graph", "path", "shortest", "route", "network",
		                   "centrality", "node", "edge", "planner" ])
		This._Kw(:knowledge, [ "knowledge", "fact", "ontology", "prove", "reason",
		                       "infer", "related", "derive" ])
		This._Kw(:nlp, [ "sentiment", "entity", "entities", "classify", "summarize",
		                 "summary", "translate", "language", "contract", "legal",
		                 "review", "nda", "clause" ])
		This._Kw(:neural, [ "embed", "embedding", "generate", "generation", "rerank" ])
		This._Kw(:learning, [ "learn", "train", "predict", "cluster", "kmeans",
		                      "bayes", "knn" ])
		This._Kw(:search, [ "search", "similarity", "rank", "ranking", "retrieve",
		                    "index", "semantic", "discover" ])
		This._Kw(:datetime, [ "date", "time", "duration", "calendar", "schedule", "timezone" ])
		This._Kw(:reactive, [ "stream", "watch", "timer", "debounce", "event" ])
		This._Kw(:agentic, [ "agent", "plan", "act", "goal", "perceive" ])
		This._Kw(:refine, [ "refine", "refinement", "propose", "cascade", "revert", "tune" ])
		This._Kw(:code, [ "code", "class", "method", "impact", "refactor", "ast" ])
		This._Kw(:data, [ "database", "sql", "sqlite", "crud", "persist", "record", "reservation" ])
		This._Kw(:vision, [ "image", "ocr", "scan", "photo", "picture", "xray", "pdf" ])

	def _Kw(pcFacet, paWords)
		_c_ = StzLower("" + pcFacet)
		_n_ = len(paWords)
		for _i_ = 1 to _n_
			@aKeywords + [ StzLower("" + paWords[_i_]), _c_ ]
		next
