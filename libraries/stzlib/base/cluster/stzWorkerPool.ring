# base/cluster/stzWorkerPool.ring
# -----------------------------------------------------------------------------
# R8.1 (the SCALE plane) -- stzWorkerPool: the HOST'S WORKER MODEL.
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md section 7; executes the 5.10
#  ruling: cluster/ folds into the host's worker model.)
#
# A pool of domain WORKER PROFILES, each with its own RESOURCE BUDGET.
# Work is dispatched to the profile whose tag it targets; each profile
# admits up to its budget and QUEUES the rest -- so a saturated profile
# (a heavy vision/neural batch) NEVER starves a different profile (light
# NLP requests): that is LOAD ISOLATION, the property that survives once
# the resident engine makes specialization-for-warmth moot.
#
#   oPool = new stzWorkerPool()
#   oPool.AddProfile("nlp",  [ :sentiment, :classify ], 4)
#   oPool.AddProfile("vision", [ :ocr ], 1).Profile("vision").UsesExternalTool("tesseract")
#   r = oPool.Dispatch("nlp", func { return StzEngineTextSentiment("great!") })
#   ? r[:admitted]   # 1 -> ran now; 0 -> queued (Drain() runs it as slots free)
#
# R8.1 is the in-process FOUNDATION (admission + dispatch + isolation +
# metrics). The FLEET of worker PROCESSES (reactor spawn) and the async
# proxy (reactor curl/TCP) land in R8.3; a reactor pool can be attached
# now via UsingReactorPool() for the later distribution wiring.
# -----------------------------------------------------------------------------

func StzWorkerPool()
	return new stzWorkerPool()

# THE SOFTANZA FACET CATALOG. The 2024 clustering doc named only four
# "computational domains" (NLP/Math/Vision/Search) -- an enterprise-
# compute narrowing. Softanza's real breadth is far larger, and a
# cluster specializes workers along ANY of these facets, not just four.
# Every facet EXCEPT vision is engine-native (the resident engine serves
# it hot); vision is the ONE polyglot facet (no image support in the
# engine -> an external tool via the reactor's async spawn).
#
# A FACET IS NOT A MODULE (the R8 naming law). The 4th column records the
# OPTIONAL facet->module provenance -- a MANY-TO-MANY relation, never a
# forced 1:1: :data->[data] (grounded); :math/:knowledge (composed,
# several modules); :search (composed, NO search/ module); :nlp (logical
# -- the nlp/ folder was DELETED by ruling, yet the competence is real);
# :vision->[] (external/polyglot, no module).
#   [ facet, [ capabilities... ], isPolyglot, [ realizing modules... ] ]
func StzSoftanzaFacets()
	return [
		[ :text,      [ :transform, :find, :match, :case, :split, :unicode ], FALSE, [ "string", "char", "text" ] ],
		[ :list,      [ :sort, :filter, :map, :reduce, :setops, :dedup ], FALSE, [ "list" ] ],
		[ :table,     [ :query, :aggregate, :join, :pivot, :wrangle ], FALSE, [ "table", "datawrangler" ] ],
		[ :number,    [ :arith, :convert, :format, :sequence ], FALSE, [ "number" ] ],
		[ :math,      [ :matrix, :optimize, :stats, :solve, :ggml ], FALSE, [ "matrix", "stats", "number" ] ],
		[ :graph,     [ :paths, :centrality, :planner, :rules, :orgchart ], FALSE, [ "graph" ] ],
		[ :knowledge, [ :facts, :derive, :prove, :query, :ontology ], FALSE, [ "natural", "graph" ] ],
		[ :nlp,       [ :sentiment, :entities, :classify, :summarize, :translate, :pos, :lemmatize ], FALSE, [ "natural", "neural" ] ],
		[ :neural,    [ :embed, :generate, :zeroshot, :rerank, :dlm ], FALSE, [ "neural" ] ],
		[ :learning,  [ :train, :knn, :bayes, :tfidf, :kmeans, :apriori ], FALSE, [ "learning" ] ],
		[ :search,    [ :index, :similarity, :rank, :semantic ], FALSE, [ "neural", "graph", "data" ] ],
		[ :datetime,  [ :date, :duration, :calendar, :timezone ], FALSE, [ "datetime", "date", "calendar", "duration" ] ],
		[ :reactive,  [ :stream, :watch, :timer, :debounce ], FALSE, [ "reactive" ] ],
		[ :agentic,   [ :perceive, :plan, :act, :govern ], FALSE, [ "agentic" ] ],
		[ :refine,    [ :propose, :cascade, :revert ], FALSE, [ "refine" ] ],
		[ :code,      [ :codegraph, :impact, :polyglotgraph ], FALSE, [ "meta", "reflect" ] ],
		[ :data,      [ :crud, :persist, :sqlite ], FALSE, [ "data" ] ],
		[ :vision,    [ :ocr, :image ], TRUE, [] ]    # the ONLY polyglot facet (no module)
	]

# The base/ modules that realize a facet ([] = external/logical).
func StzFacetModules(pcFacet)
	_cF_ = StzLower("" + pcFacet)
	_a_ = StzSoftanzaFacets()
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if StzLower("" + _a_[_i_][1]) = _cF_
			return _a_[_i_][4]
		ok
	next
	return []

# Capabilities of a named facet ([] if unknown).
func StzFacetCapabilities(pcFacet)
	_cF_ = StzLower("" + pcFacet)
	_a_ = StzSoftanzaFacets()
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if StzLower("" + _a_[_i_][1]) = _cF_
			return _a_[_i_][2]
		ok
	next
	return []

func StzFacetIsPolyglot(pcFacet)
	_cF_ = StzLower("" + pcFacet)
	_a_ = StzSoftanzaFacets()
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if StzLower("" + _a_[_i_][1]) = _cF_
			return _a_[_i_][3]
		ok
	next
	return FALSE

func StzKnownFacets()
	_a_ = StzSoftanzaFacets()
	_o_ = []
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		_o_ + _a_[_i_][1]
	next
	return _o_

# Default profiles matching the clustering doc's four (kept for the doc's
# scenarios). Use StzSoftanzaWorkerPool() for the full facet breadth.
func StzDefaultWorkerPool()
	oPool = new stzWorkerPool()
	oPool.AddProfile("nlp",    [ :sentiment, :entities, :classify, :summarize, :translate ], 4)
	oPool.AddProfile("math",   [ :matrix, :optimize, :stats, :solve ], 2)
	oPool.AddProfile("search", [ :embed, :similarity, :rank, :index ], 2)
	oPool.AddProfile("vision", [ :ocr, :image ], 1)
	oPool.Profile("vision").UsesExternalTool("python")   # tesseract/opencv off-process
	return oPool

# The FULL Softanza facet breadth as a worker pool (one profile per facet,
# budget nDefaultBudget each). This is the honest answer to "NLP and Math
# are not the only facets": text/list/table/graph/knowledge/learning/
# neural/datetime/reactive/agentic/refine/code/data/... all specialize.
func StzSoftanzaWorkerPool(nDefaultBudget)
	if nDefaultBudget < 1  nDefaultBudget = 1  ok
	oPool = new stzWorkerPool()
	_a_ = StzSoftanzaFacets()
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		oPool.AddProfile(_a_[_i_][1], _a_[_i_][2], nDefaultBudget)
		oPool.Profile(_a_[_i_][1]).RealizedBy(_a_[_i_][4])   # provenance
		if _a_[_i_][3]   # polyglot facet
			oPool.Profile(_a_[_i_][1]).UsesExternalTool("python")
		ok
	next
	return oPool


class stzWorkerPool from stzObject

	@aProfiles = []      # list of stzWorkerProfile
	@aQueues = []        # parallel to @aProfiles: [ [ fWork, ... ], ... ]
	@aResults = []       # drained results: [ [ tag, value ], ... ]
	@oReactorPool = NULL # attached for the R8.3 fleet (optional at R8.1)

	def init()
		@aProfiles = []
		@aQueues = []
		@aResults = []

	def AddProfile(pcTag, paCapabilities, pnBudget)
		if This._IndexOf(pcTag) > 0
			stzraise("stzWorkerPool: profile '" + pcTag + "' already exists.")
		ok
		@aProfiles + new stzWorkerProfile(pcTag, paCapabilities, pnBudget)
		@aQueues + []
		return This

	def Profile(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0  return NULL  ok
		return @aProfiles[_i_]

	def HasProfile(pcTag)
		return This._IndexOf(pcTag) > 0

	def NumberOfProfiles()
		return len(@aProfiles)

	def Tags()
		_a_ = []
		_n_ = len(@aProfiles)
		for _i_ = 1 to _n_
			_a_ + @aProfiles[_i_].Tag()
		next
		return _a_

	# The profile whose CAPABILITIES include pcCapability (routing seam
	# for R8.2). Returns the tag, or "" if none.
	def ProfileFor(pcCapability)
		_n_ = len(@aProfiles)
		for _i_ = 1 to _n_
			if @aProfiles[_i_].Handles(pcCapability)
				return @aProfiles[_i_].Tag()
			ok
		next
		return ""

	def UsingReactorPool(poReactorPool)
		@oReactorPool = poReactorPool
		return This

	def ReactorPoolQ()
		return @oReactorPool

	#-- dispatch (admission + load isolation) ------------------------------

	# Dispatch fWork to the profile tagged pcTag. If the profile can
	# admit (in-flight < budget), run it NOW (acquire -> call -> release)
	# and return [ :admitted = 1, :result = <value>, :tag = pcTag ]. Else
	# QUEUE it and return [ :admitted = 0, :queued = 1, :tag = pcTag ] --
	# Drain() runs queued work as slots free. A saturated profile queues
	# WITHOUT touching any other profile's budget (load isolation).
	def Dispatch(pcTag, fWork)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0
			stzraise("stzWorkerPool.Dispatch: no profile '" + pcTag + "'.")
		ok
		if @aProfiles[_i_].Acquire()
			_v_ = call fWork()
			@aProfiles[_i_].Release()
			@aResults + [ pcTag, _v_ ]
			return [ :admitted = 1, :result = _v_, :tag = pcTag ]
		ok
		@aQueues[_i_] + fWork
		return [ :admitted = 0, :queued = 1, :tag = pcTag ]

	# Reserve a slot WITHOUT running work (lets a caller model a
	# long-running/in-flight job for isolation tests + the R8.3 fleet).
	# Returns TRUE (slot taken) or FALSE (over budget).
	def Acquire(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0
			stzraise("stzWorkerPool.Acquire: no profile '" + pcTag + "'.")
		ok
		return @aProfiles[_i_].Acquire()

	def Release(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0
			stzraise("stzWorkerPool.Release: no profile '" + pcTag + "'.")
		ok
		@aProfiles[_i_].Release()
		return This

	# Run queued work for every profile as slots free. Returns the number
	# of queued items that ran this pass.
	def Drain()
		_nRan_ = 0
		_nP_ = len(@aProfiles)
		for _i_ = 1 to _nP_
			# run from the front while the profile can admit and work waits
			while len(@aQueues[_i_]) > 0 and @aProfiles[_i_].CanAdmit()
				_fWork_ = @aQueues[_i_][1]
				del(@aQueues[_i_], 1)
				@aProfiles[_i_].Acquire()
				_v_ = call _fWork_()
				@aProfiles[_i_].Release()
				@aResults + [ @aProfiles[_i_].Tag(), _v_ ]
				_nRan_++
			end
		next
		return _nRan_

	#-- metrics ------------------------------------------------------------

	def InFlight(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0  return 0  ok
		return @aProfiles[_i_].InFlight()

	def QueueDepth(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0  return 0  ok
		return len(@aQueues[_i_])

	def Results()
		return @aResults

	# A snapshot the R8.4 autoscaler + the health console read (REAL
	# numbers, not the old random() monitor).
	def Metrics()
		_a_ = []
		_n_ = len(@aProfiles)
		for _i_ = 1 to _n_
			_a_ + [
				:tag = @aProfiles[_i_].Tag(),
				:budget = @aProfiles[_i_].Budget(),
				:inflight = @aProfiles[_i_].InFlight(),
				:queue = len(@aQueues[_i_]),
				:admitted = @aProfiles[_i_].AdmittedCount(),
				:rejected = @aProfiles[_i_].RejectedCount()
			]
		next
		return _a_

	def Narrate()
		_cR_ = "worker pool [" + len(@aProfiles) + " profile(s)]:"
		_n_ = len(@aProfiles)
		for _i_ = 1 to _n_
			_cR_ += char(10) + "  " + @aProfiles[_i_].Narrate() +
				"  queue=" + len(@aQueues[_i_])
		next
		return _cR_

	#-- internals ----------------------------------------------------------

	def _IndexOf(pcTag)
		_c_ = StzLower("" + pcTag)
		_n_ = len(@aProfiles)
		for _i_ = 1 to _n_
			if @aProfiles[_i_].Tag() = _c_  return _i_  ok
		next
		return 0
