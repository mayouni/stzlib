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


# Holds worker profiles, each with its own budget of slots, and runs or queues work against them so a busy kind never starves another.
#
# Work is sent to the profile it targets: the profile runs it at once when a slot is free, queues it
# when not, and sheds it when a bounded queue is full. That is load isolation. A heavy batch of one
# profile leaves the slots of every other profile alone. Profiles come from a facet catalog the pool
# owns (AddFacet, SeedAllFacets) or are declared ad hoc (AddProfile). The pool is in-process: work
# runs in the calling process and no worker process is started.
#
#   receiver   o1 = new stzWorkerPool()
#   example    o1.AddProfile("nlp", [ :sentiment, :classify ], 2)
#              o1.AddProfile("vision", [ :ocr ], 1)
#              ? o1.Tags()[2]
#              #--> vision
#              ? o1.ProfileFor(:classify)
#              #--> nlp
#              ? o1.Acquire("vision")
#              #--> 1
#              ? o1.Dispatch("vision", func { return 1 })[:queued]
#              #--> 1
#              ? o1.Dispatch("nlp", func { return 6 * 7 })[:result]
#              #--> 42
#   see        stzWorkerProfile, stzFacetCatalog
class stzWorkerPool from stzObject

	@aoProfiles = []      # list of stzWorkerProfile
	@aQueues = []        # parallel to @aoProfiles: [ [ fWork, ... ], ... ]
	@aResults = []       # drained results: [ [ tag, value ], ... ]
	@oReactorPool = "" # attached for the R8.3 fleet (optional at R8.1)
	@oCatalog = ""     # the competence registry this pool draws facets
	# Builds an empty pool of worker profiles, with its own copy of the standard facet catalog.
	#
	#   returns    nothing; the object is built
	#   see        StzWorkerPoolQ, CatalogQ
	#@ aka  from (INSTANCE-scoped; seeded standard, custom- izable) -- not a global (a deployment concern)
	def init()
		@aoProfiles = []
		@aQueues = []
		@aResults = []
		@oCatalog = new stzFacetCatalog()

	# Returns the facet catalog this pool draws its facets from.
	#
	#   returns    a stzFacetCatalog
	#   see        SetCatalog, DefineFacet, AddFacet
	#@ aka  -- the facet catalog (instance-owned) ---------------------------------
	def CatalogQ()
		return @oCatalog

	# Replaces the pool's facet catalog with a catalog you built; do it before adding facets.
	#
	#   poCatalog   the stzFacetCatalog to use from now on
	#   returns     the pool itself, so calls chain
	#   see         CatalogQ, DefineFacet
	#@ aka  Swap in a fully-built custom catalog (build it before adding facets).
	def SetCatalog(poCatalog)
		@oCatalog = poCatalog
		return This

	# Adds or overrides an engine-native facet in the pool's own catalog.
	#
	#   pcName      the facet's name
	#   paCaps      the capabilities it serves, as a list
	#   paModules   the library modules realizing it, as a list
	#   returns     the pool itself, so calls chain
	#   see         AddFacet, DefinePolyglotFacet
	#@ aka  Customize this pool's OWN catalog (delegated so the pool's live copy stays the single source of truth -- the aliasing doctrine).
	def DefineFacet(pcName, paCaps, paModules)
		@oCatalog.Define(pcName, paCaps, paModules)
		return This
	# Adds a facet to the pool's own catalog that is served by an outside tool.
	#
	#   pcName     the facet's name
	#   paCaps     the capabilities it serves, as a list
	#   pcTool     the name of the external tool
	#   returns    the pool itself, so calls chain
	#   see        DefineFacet, AddFacet
	def DefinePolyglotFacet(pcName, paCaps, pcTool)
		@oCatalog.DefinePolyglot(pcName, paCaps, pcTool)
		return This

	# Adds a profile for a facet of the pool's catalog, taking its capabilities, modules and tool from there.
	#
	#   pcName     the facet's name, as defined in the catalog
	#   nBudget    the number of concurrent slots
	#   returns    nothing; use AddFacetQ to get the pool back
	#   warning    a facet that is not in the catalog raises an error; a tag already in the pool
	#              raises an error too
	#   see        AddProfile, SeedAllFacets, DefineFacet
	#@ aka  Add a profile for a facet DEFINED IN THIS POOL'S CATALOG: capabilities, provenance and external tool are taken from the catalog.
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

	# Seed one profile per catalog facet at the given budget (the full
	# breadth). The honest answer to "NLP and Math are not the only facets".

		def AddFacetQ(pcName, nBudget)
			This.AddFacet(pcName, nBudget)
			return This

	# Adds one profile for every facet of the catalog, each with the same budget.
	#
	#   nBudget    the slots given to every profile
	#   returns    the pool itself, so calls chain
	#   warning    the standard catalog holds 18 facets, from text to vision
	#   see        AddFacet, Tags
	def SeedAllFacets(nBudget)
		if nBudget < 1  nBudget = 1  ok
		_a_ = @oCatalog.Names()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			This.AddFacet(_a_[_i_], nBudget)
		next
		return This

	# Adds a profile of your own, outside the catalog, under a tag.
	#
	#   pcTag            the profile's tag, compared without regard to case
	#   paCapabilities   the capabilities it serves, as a list
	#   pnBudget         the number of concurrent slots
	#   returns          nothing; use AddProfileQ to get the new profile back
	#   warning          a tag already in the pool raises an error saying the profile already exists
	#   see              AddProfileQ, AddFacet
	#@ aka  -- ad-hoc profiles (a facet NOT from the catalog) ---------------------
	def AddProfile(pcTag, paCapabilities, pnBudget)
		if This._IndexOf(pcTag) > 0
			stzraise("stzWorkerPool: profile '" + pcTag + "' already exists.")
		ok
		@aoProfiles + new stzWorkerProfile(pcTag, paCapabilities, pnBudget)
		@aQueues + []


	# the SAME act, returning the NEW profile so you can chain onto it:
	#   oPool.AddProfileQ("vision", [ :ocr ], 1).SetExternalTool("tesseract")
	# The verb states the act, the Q states what comes back.

	def AddProfileQ(pcTag, paCapabilities, pnBudget)
		This.AddProfile(pcTag, paCapabilities, pnBudget)
		return This.ProfileQ(pcTag)
	# Returns the profile with a tag, to read it or to call it in a chain.
	#
	#   pcTag      the profile's tag, without regard to case
	#   returns    a stzWorkerProfile; an empty text when the tag is unknown
	#   warning    an object kept in a variable is a copy: change a profile by calling ProfileQ
	#              again each time, not through the variable
	#   see        HasProfile, Tags
	def ProfileQ(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0  return ""  ok
		return @aoProfiles[_i_]

	# TRUE if the pool has a profile under that tag.
	#
	#   pcTag      the tag to look for, without regard to case
	#   returns    TRUE or FALSE
	#   see        ProfileQ, Tags
	def HasProfile(pcTag)
		return This._IndexOf(pcTag) > 0

	# Returns how many profiles the pool holds.
	#
	#   returns    a number
	#   see        Tags, HasProfile
	def NumberOfProfiles()
		return len(@aoProfiles)

	# Returns the tags of the profiles, in the order they were added.
	#
	#   returns    a list of text, in lower case
	#   see        NumberOfProfiles, ProfileFor
	def Tags()
		_a_ = []
		_n_ = len(@aoProfiles)
		for _i_ = 1 to _n_
			_a_ + @aoProfiles[_i_].Tag()
		next
		return _a_

	# Returns the tag of the first profile that serves a capability, to route work by what it needs.
	#
	#   pcCapability   the capability to route, as a text or a symbol
	#   returns        a text; empty when no profile serves it
	#   see            Tags, Dispatch
	#@ aka  The profile whose CAPABILITIES include pcCapability (routing seam for R8.2). Returns the tag, or "" if none.
	def ProfileFor(pcCapability)
		_n_ = len(@aoProfiles)
		for _i_ = 1 to _n_
			if @aoProfiles[_i_].Handles(pcCapability)
				return @aoProfiles[_i_].Tag()
			ok
		next
		return ""

	# Attaches a reactor pool, kept for the later fleet wiring; nothing in the pool uses it yet.
	#
	#   poReactorPool   the reactor pool to keep
	#   returns         the pool itself, so calls chain
	#   see             ReactorPoolQ
	def SetReactorPool(poReactorPool)
		@oReactorPool = poReactorPool
		return This

	# Returns the reactor pool attached to this pool.
	#
	#   returns    the attached object; an empty text when none
	#   see        SetReactorPool
	def ReactorPoolQ()
		return @oReactorPool

	# Runs a function now if the profile has a free slot, else queues it, or sheds it when the queue is full.
	#
	#   pcTag      the tag of the profile that takes the work
	#   fWork      the function to call, with no argument
	#   returns    a hashlist: admitted 1 with result and tag when it ran; admitted 0 with queued 1
	#              when queued; admitted 0 with shed 1 when refused
	#   warning    an unknown tag raises an error; the function runs in this process, no worker
	#              process is started; a full profile never touches another profile's slots
	#   see        Drain, Acquire, Results
	#@ aka  -- dispatch (admission + load isolation) ------------------------------
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

	# Reserves a slot of a profile without running any work, to model a long job in flight.
	#
	#   pcTag      the tag of the profile
	#   returns    TRUE when a slot was taken, FALSE when the profile is over budget
	#   warning    an unknown tag raises an error
	#   see        Release, Dispatch
	#@ aka  Reserve a slot WITHOUT running work (lets a caller model a long-running/in-flight job for isolation tests + the R8.3 fleet). Returns TRUE (slot taken) or FALSE (over budget).
	def Acquire(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0
			stzraise("stzWorkerPool.Acquire: no profile '" + pcTag + "'.")
		ok
		return @aoProfiles[_i_].Acquire()

	# Frees one reserved slot of a profile.
	#
	#   pcTag      the tag of the profile
	#   returns    the pool itself, so calls chain
	#   warning    an unknown tag raises an error
	#   see        Acquire, Drain
	def Release(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0
			stzraise("stzWorkerPool.Release: no profile '" + pcTag + "'.")
		ok
		@aoProfiles[_i_].Release()
		return This

	# Runs the queued work of every profile as far as its free slots allow.
	#
	#   returns    a number: how many queued items ran in this pass
	#   see        Dispatch, QueueDepth
	#@ aka  Run queued work for every profile as slots free. Returns the number of queued items that ran this pass.
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

	# Returns how many slots a profile holds now.
	#
	#   pcTag      the tag of the profile
	#   returns    a number; 0 for an unknown tag
	#   see        QueueDepth, Metrics
	#@ aka  -- metrics ------------------------------------------------------------
	def InFlight(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0  return 0  ok
		return @aoProfiles[_i_].InFlight()

	# Returns how many pieces of work wait in a profile's queue.
	#
	#   pcTag      the tag of the profile
	#   returns    a number; 0 for an unknown tag
	#   see        Drain, Dispatch
	def QueueDepth(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0  return 0  ok
		return len(@aQueues[_i_])

	# Returns how many pieces of work a profile has shed because its queue was full.
	#
	#   pcTag      the tag of the profile
	#   returns    a number; 0 for an unknown tag
	#   see        Dispatch
	def ShedCount(pcTag)
		_i_ = This._IndexOf(pcTag)
		if _i_ = 0  return 0  ok
		return @aoProfiles[_i_].ShedCount()

	# Returns the values produced by the work that ran, in the order it ran.
	#
	#   returns    a list of [ tag, value ] pairs
	#   see        Dispatch, Drain
	def Results()
		return @aResults

	# Returns a snapshot of every profile for a health console or an autoscaler.
	#
	#   returns    a list of hashlists with the keys tag, budget, inflight, queue, admitted and
	#              rejected
	#   see        InFlight, QueueDepth
	#@ aka  A snapshot the R8.4 autoscaler + the health console read (REAL numbers, not the old random() monitor).
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

	# Returns a text that describes the pool: one line per profile with its slots and queue.
	#
	#   returns    a text with lines separated by a new line
	#   see        Metrics
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
