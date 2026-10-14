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
#                        (SetModelClassifier): zero-shot / embedding
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

func StzRequestClassifierQ()
	return new stzRequestClassifier()

# Maps an incoming request to a facet, the routing target, in three tiers: operator rules, capability-lexical scoring and an optional model.
#
# Rules on content type, path prefix and method are tried first and win; then the lexical tier
# scores the request against each facet's own capability vocabulary and a synonym lexicon; then an
# optional model function, installed with SetModelClassifier, is asked. It only routes to facets the
# bound catalog knows. Why() says which tier decided. The lexical tier is deterministic and offline.
#
#   receiver   o1 = new stzRequestClassifier() o1.RouteWhenPath("/api/risk", :math)
#              o1.RouteWhenContentType("application/pdf", :vision)
#   example    ? o1.Classify("POST", "/api/analyze", "application/pdf", "review this NDA")
#              #--> vision
#              ? o1.Why()
#              #--> rule: content-type 'application/pdf' -> vision
#              ? o1.ClassifyText("find the shortest path between two nodes")
#              #--> graph
#              ? o1.ClassifyPath("/api/risk/score")
#              #--> math
#   see        stzFacetCatalog, stzComputePipeline, stzClusterSupervisor
class stzRequestClassifier from stzObject

	@oCatalog = ""       # the facet vocabulary this router classifies to
	@aPathRules = []       # [ prefix, facet ]
	@aTypeRules = []       # [ contentType-substring, facet ]
	@aMethodRules = []     # [ method, facet ]
	@aKeywords = []        # [ keyword, facet ]  synonym lexicon (augments caps)
	@fModel = ""         # optional tier-3 engine classifier: f(text)->facet
	@cWhy = ""

	# Creates a classifier with a standard facet catalog and a seeded keyword lexicon, and no rules.
	#
	#   returns    nothing; the object is built
	#   see        Classify, SetCatalog
	def init()
		@oCatalog = new stzFacetCatalog()
		This._SeedKeywords()

	# Binds the classifier to a deployment's own facet catalog, so it only routes to facets that catalog knows.
	#
	#   poCatalog   a stzFacetCatalog, or any object that answers Has(facet)
	#   returns     the classifier itself, so calls chain
	#   warning     a model's answer naming a facet the catalog lacks is ignored
	#   see         CatalogQ, Classify
	#@ aka  Bind to a specific (e.g. a cluster's) catalog -- so the router routes to exactly the facets THAT deployment offers.
	def SetCatalog(poCatalog)
		@oCatalog = poCatalog
		return This

	# Returns the facet catalog the classifier routes against.
	#
	#   returns    a stzFacetCatalog
	#   see        SetCatalog
	def CatalogQ()
		return @oCatalog

	# Returns the reason for the last decision, naming the rule, the lexical hits or the model; empty before the first call.
	#
	#   returns    a text
	#   warning    for an undecidable request it says undecidable
	#   see        Classify, ClassifyText
	def Why()
		return @cWhy

	# Adds a rule: a request whose path starts with a prefix goes to a facet.
	#
	#   pcPrefix   the path prefix, matched at the start of the path without regard to case
	#   pcFacet    the facet to route to, stored in lower case
	#   returns    the classifier itself, so calls chain
	#   warning    rules are tried in the order content type, path, method, and the first match wins
	#   see        RouteWhenContentType, Classify
	#@ aka  -- TIER 1: deterministic rules ----------------------------------------
	def RouteWhenPath(pcPrefix, pcFacet)
		@aPathRules + [ StzLower("" + pcPrefix), StzLower("" + pcFacet) ]
		return This

	# Adds a rule: a request whose content type contains a text goes to a facet.
	#
	#   pcType     the text the content type must contain, such as application/pdf
	#   pcFacet    the facet to route to, stored in lower case
	#   returns    the classifier itself, so calls chain
	#   warning    a content type that carries parameters still matches
	#   see        RouteWhenPath, Classify
	#@ aka  A request whose Content-Type CONTAINS pcType routes to pcFacet.
	def RouteWhenContentType(pcType, pcFacet)
		@aTypeRules + [ StzLower("" + pcType), StzLower("" + pcFacet) ]
		return This

	# Adds a rule: a request with a given HTTP method goes to a facet.
	#
	#   pcMethod   the method, such as DELETE, matched without regard to case
	#   pcFacet    the facet to route to, stored in lower case
	#   returns    the classifier itself, so calls chain
	#   see        RouteWhenPath, Classify
	def RouteWhenMethod(pcMethod, pcFacet)
		@aMethodRules + [ StzUpper("" + pcMethod), StzLower("" + pcFacet) ]
		return This

	# Teaches the lexical tier a word or phrase that hints at a facet.
	#
	#   pcKeyword   the word that hints a facet, stored in lower case
	#   pcFacet     the facet it hints at, stored in lower case
	#   returns     nothing; use AddKeywordQ to chain
	#   warning     capability names are matched automatically; keywords add natural phrasing
	#   see         ClassifyText
	#@ aka  -- TIER 2: the capability-lexical vocabulary --------------------------
	def AddKeyword(pcKeyword, pcFacet)
		@aKeywords + [ StzLower("" + pcKeyword), StzLower("" + pcFacet) ]

	#-- TIER 3: an optional engine classifier ------------------------------

	# f(cText) -> facet name (or ""). Used only when tiers 1+2 abstain.

		def AddKeywordQ(pcKeyword, pcFacet)
			This.AddKeyword(pcKeyword, pcFacet)
			return This

	# Installs an optional classifier function, used only when the rules and the lexicon abstain.
	#
	#   fClassify   a function that takes the text and returns a facet name, or an empty text
	#   returns     the classifier itself, so calls chain
	#   warning     its answer is used only when the catalog knows the facet
	#   see         ClassifyText, Why
	def SetModelClassifier(fClassify)
		@fModel = fClassify
		return This

	# Routes a request to a facet in three tiers: rules first, then capability-lexical scoring, then the model; returns the facet name.
	#
	#   pcMethod        the HTTP method
	#   pcPath          the request path
	#   pcContentType   the content type, may be empty
	#   pcBody          the request body text
	#   returns         the facet name as lower-case text; empty when undecidable
	#   warning         Why says which tier decided
	#   see             ClassifyPath, ClassifyText, Why
	#@ aka  -- classification -----------------------------------------------------
	def Classify(pcMethod, pcPath, pcContentType, pcBody)
		_cPath_ = StzLower("" + pcPath)
		_cType_ = StzLower("" + pcContentType)
		_cMethod_ = StzUpper("" + pcMethod)

		# TIER 1 -- content-type, then path, then method
		#
		# NEEDLE FIRST: StzFindFirst(what-to-find, where-to-look). Both
		# loops had the arguments the other way round, which asked "does
		# the REQUEST appear inside the RULE" -- true only when the two
		# are identical. An exact hit therefore passed and every real
		# rule silently did not: "/api/search" never caught
		# "/api/search/products", and a content type carrying parameters
		# ("application/pdf; charset=utf-8") never matched its own rule.
		# Tier 1 fell through to the lexical tier, which often reached
		# the same facet by a different route -- so the ROUTING looked
		# right and only Why() disagreed. See [[reference-stzfind-contract]].
		_n_ = len(@aTypeRules)
		for _i_ = 1 to _n_
			if _cType_ != "" and StzFindFirst(@aTypeRules[_i_][1], _cType_) > 0
				return This._Decide(@aTypeRules[_i_][2], "rule: content-type '" + @aTypeRules[_i_][1] + "'")
			ok
		next
		# a path rule is a PREFIX rule: it matches at position 1.
		_n_ = len(@aPathRules)
		for _i_ = 1 to _n_
			if StzFindFirst(@aPathRules[_i_][1], _cPath_) = 1
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
		if @fModel != ""
			_f_ = @fModel
			_cM_ = "" + call _f_("" + pcPath + " " + pcBody)
			if _cM_ != "" and @oCatalog.Has(_cM_)
				return This._Decide(StzLower(_cM_), "model classifier")
			ok
		ok

		@cWhy = "undecidable: no rule, lexical, or model match"
		return ""

	# Routes a request known only by its path, as a GET without body.
	#
	#   pcPath     the request path
	#   returns    the facet name; empty when undecidable
	#   see        Classify
	def ClassifyPath(pcPath)
		return This.Classify("GET", pcPath, "", "")

	# Routes free text to a facet, by the lexicon and then the model, with no rules.
	#
	#   pcText     the text to route
	#   returns    the facet name; empty when undecidable
	#   see        Classify, AddKeyword, SetModelClassifier
	def ClassifyText(pcText)
		_cFacet_ = This._LexicalFacet(StzLower("" + pcText))
		if _cFacet_ != ""  return _cFacet_  ok
		if @fModel != ""
			_f_ = @fModel
			_cM_ = "" + call _f_("" + pcText)
			if _cM_ != "" and @oCatalog.Has(_cM_)
				return This._Decide(StzLower(_cM_), "model classifier")
			ok
		ok
		@cWhy = "undecidable"
		return ""

	# Routes a request object by its method, path and body.
	#
	#   oRequest   an object that answers Method(), Path() and Body(), such as an HTTP request
	#   returns    the facet name; empty when undecidable
	#   warning    the content type is not read, so content-type rules do not apply
	#   see        Classify
	#@ aka  COMPAT (retires the pre-engine classifier in place): the old The fleet router calls this with an stzAppRequest.
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
