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
#   oPool.AddProfileQ("vision", [ :ocr ], 1).SetExternalTool("tesseract")
#   r = oPool.Dispatch("nlp", func { return StzEngineTextSentiment("great!") })
#   ? r[:admitted]   # 1 -> ran now; 0 -> queued (Drain() runs it as slots free)
#
# R8.1 is the in-process FOUNDATION (admission + dispatch + isolation +
# metrics). The FLEET of worker PROCESSES (reactor spawn) and the async
# proxy (reactor curl/TCP) land in R8.3; a reactor pool can be attached
# now via SetReactorPool() for the later distribution wiring.
# -----------------------------------------------------------------------------

func StzWorkerPoolQ()
	return new stzWorkerPool()


class stzWorkerPool from stzObject

	@aoProfiles = []      # list of stzWorkerProfile
	@aQueues = []        # parallel to @aoProfiles: [ [ fWork, ... ], ... ]
	@aResults = []       # drained results: [ [ tag, value ], ... ]
	@oReactorPool = NULL # attached for the R8.3 fleet (optional at R8.1)
	@oCatalog = NULL     # the competence registry this pool draws facets
	                     # from (INSTANCE-scoped; seeded standard, custom-
	                     # izable) -- not a global (a deployment concern)

	def init()
		@aoProfiles = []
		@aQueues = []
		@aResults = []
		@oCatalog = new stzFacetCatalog()

	#-- the facet catalog (instance-owned) ---------------------------------

	def CatalogQ()
		return @oCatalog

	# Swap in a fully-built custom catalog (build it before adding facets).
	def SetCatalog(poCatalog)
		@oCatalog = poCatalog
		return This

	# Customize this pool's OWN catalog (delegated so the pool's live copy
	# stays the single source of truth -- the aliasing doctrine).
	def DefineFacet(pcName, paCaps, paModules)
		@oCatalog.Define(pcName, paCaps, paModules)
		return This
	def DefinePolyglotFacet(pcName, paCaps, pcTool)
		@oCatalog.DefinePolyglot(pcName, paCaps, pcTool)
		return This

	# Add a profile for a facet DEFINED IN THIS POOL'S CATALOG: capabilities,
	# provenance and external tool are taken from the catalog.
	def AddFacet(pcName, nBudget)
		if NOT @oCatalog.Has(pcName)
			stzraise("stzWorkerPool.AddFacet: '" + pcName + "' is not in this " +
			         "pool's catalog. Define it first or use AddProfile for an " +
			         "ad-hoc profile. Known: see CatalogQ().Names().")
		ok
		_cTag_ = StzLower("" + pcName)
		This.AddProfile(_cTag_, @oCatalog.CapabilitiesOf(pcName), nBudget)
		# call THROUGH Profile() each time -- assigning to a local COPIES
		# the profile (Ring aliasing), so the mutation would be discarded.
		This.ProfileQ(_cTag_).SetRealizedBy(@oCatalog.ModulesOf(pcName))
		if @oCatalog.IsPolyglot(pcName)
			This.ProfileQ(_cTag_).SetExternalTool(@oCatalog.ToolOf(pcName))
		ok
		return This

	# Seed one profile per catalog facet at the given budget (the full
	# breadth). The honest answer to "NLP and Math are not the only facets".
	def SeedAllFacets(nBudget)
		if nBudget < 1  nBudget = 1  ok
		_a_ = @oCatalog.Names()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			This.AddFacet(_a_[_i_], nBudget)
		next
		return This

	#-- ad-hoc profiles (a facet NOT from the catalog) ---------------------

	def AddProfile(pcTag, paCapabilities, pnBudget)
		if This._IndexOf(pcTag) > 0
			stzraise("stzWorkerPool: profile '" + pcTag + "' already exists.")
		ok
		@aoProfiles + new stzWorkerProfile(pcTag, paCapabilities, pnBudget)
		@aQueues + []
		return This


	# the SAME act, returning the NEW profile so you can chain onto it:
	#   oPool.AddProfileQ("vision", [ :ocr ], 1).SetExternalTool("tesseract")
	# The verb states the act, the Q states what comes back.
	def AddProfileQ(pcTag, paCapabilities, pnBudget)
		This.AddProfile(pcTag, paCapabilities, pnBudget)
		return This.ProfileQ(pcTag)
	def ProfileQ(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0  return NULL  ok
		return @aoProfiles[_i_]

	def HasProfile(pcTag)
		return This._IndexOf(pcTag) > 0

	def NumberOfProfiles()
		return len(@aoProfiles)

	def Tags()
		_a_ = []
		_n_ = len(@aoProfiles)
		for _i_ = 1 to _n_
			_a_ + @aoProfiles[_i_].Tag()
		next
		return _a_

	# The profile whose CAPABILITIES include pcCapability (routing seam
	# for R8.2). Returns the tag, or "" if none.
	def ProfileFor(pcCapability)
		_n_ = len(@aoProfiles)
		for _i_ = 1 to _n_
			if @aoProfiles[_i_].Handles(pcCapability)
				return @aoProfiles[_i_].Tag()
			ok
		next
		return ""

	def SetReactorPool(poReactorPool)
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
		if @aoProfiles[_i_].Acquire()
			_v_ = call fWork()
			@aoProfiles[_i_].Release()
			@aResults + [ pcTag, _v_ ]
			return [ :admitted = 1, :result = _v_, :tag = pcTag ]
		ok
		# over budget -> queue, unless the queue is bounded AND full, in
		# which case SHED (backpressure) rather than grow unbounded.
		if @aoProfiles[_i_].MaxQueue() > 0 and len(@aQueues[_i_]) >= @aoProfiles[_i_].MaxQueue()
			@aoProfiles[_i_].Shed()
			return [ :admitted = 0, :queued = 0, :shed = 1, :tag = pcTag ]
		ok
		@aQueues[_i_] + fWork
		return [ :admitted = 0, :queued = 1, :shed = 0, :tag = pcTag ]

	# Reserve a slot WITHOUT running work (lets a caller model a
	# long-running/in-flight job for isolation tests + the R8.3 fleet).
	# Returns TRUE (slot taken) or FALSE (over budget).
	def Acquire(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0
			stzraise("stzWorkerPool.Acquire: no profile '" + pcTag + "'.")
		ok
		return @aoProfiles[_i_].Acquire()

	def Release(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0
			stzraise("stzWorkerPool.Release: no profile '" + pcTag + "'.")
		ok
		@aoProfiles[_i_].Release()
		return This

	# Run queued work for every profile as slots free. Returns the number
	# of queued items that ran this pass.
	def Drain()
		_nRan_ = 0
		_nP_ = len(@aoProfiles)
		for _i_ = 1 to _nP_
			# run from the front while the profile can admit and work waits
			while len(@aQueues[_i_]) > 0 and @aoProfiles[_i_].CanAdmit()
				_fWork_ = @aQueues[_i_][1]
				del(@aQueues[_i_], 1)
				@aoProfiles[_i_].Acquire()
				_v_ = call _fWork_()
				@aoProfiles[_i_].Release()
				@aResults + [ @aoProfiles[_i_].Tag(), _v_ ]
				_nRan_++
			end
		next
		return _nRan_

	#-- metrics ------------------------------------------------------------

	def InFlight(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0  return 0  ok
		return @aoProfiles[_i_].InFlight()

	def QueueDepth(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0  return 0  ok
		return len(@aQueues[_i_])

	def ShedCount(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0  return 0  ok
		return @aoProfiles[_i_].ShedCount()

	def Results()
		return @aResults

	# A snapshot the R8.4 autoscaler + the health console read (REAL
	# numbers, not the old random() monitor).
	def Metrics()
		_a_ = []
		_n_ = len(@aoProfiles)
		for _i_ = 1 to _n_
			_a_ + [
				:tag = @aoProfiles[_i_].Tag(),
				:budget = @aoProfiles[_i_].Budget(),
				:inflight = @aoProfiles[_i_].InFlight(),
				:queue = len(@aQueues[_i_]),
				:admitted = @aoProfiles[_i_].AdmittedCount(),
				:rejected = @aoProfiles[_i_].RejectedCount()
			]
		next
		return _a_

	def Narrate()
		_cR_ = "worker pool [" + len(@aoProfiles) + " profile(s)]:"
		_n_ = len(@aoProfiles)
		for _i_ = 1 to _n_
			_cR_ += char(10) + "  " + @aoProfiles[_i_].Narrate() +
				"  queue=" + len(@aQueues[_i_])
		next
		return _cR_

	#-- internals ----------------------------------------------------------

	def _IndexOf(pcTag)
		_c_ = StzLower("" + pcTag)
		_n_ = len(@aoProfiles)
		for _i_ = 1 to _n_
			if @aoProfiles[_i_].Tag() = _c_  return _i_  ok
		next
		return 0
