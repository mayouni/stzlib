# base/cluster/stzWorkerProfile.ring
# -----------------------------------------------------------------------------
# R8.1 (the SCALE plane) -- stzWorkerProfile: SPECIALIZATION AS A BUDGET,
# not a subclass. (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md section 7.)
#
# The 2024 clustering vision made specialization a CLASS TREE
# (stzNLPServer/stzMathServer/... each PRELOADING libraries). The
# resident engine makes preloading moot -- every worker shares the one
# hot engine. So specialization survives only as a WORKER PROFILE: a
# capability TAG + the engine CAPABILITIES it serves + a RESOURCE BUDGET
# (max concurrent slots) that gives it LOAD ISOLATION from other
# profiles. Vision (no engine support) additionally names an EXTERNAL
# tool run via the reactor's async spawn (R7).
#
#   oP = new stzWorkerProfile("nlp", [ :sentiment, :entities, :classify ], 4)
#   oP.CanAdmit()          # slots free?
#   oP.Acquire()           # take a slot (in-flight++)
#   oP.Release()           # free a slot
#   oP.Handles(:entities)  # capability check (routing, R8.2)
# -----------------------------------------------------------------------------

func StzWorkerProfileQ(pcTag, paCapabilities, pnBudget)
	return new stzWorkerProfile(pcTag, paCapabilities, pnBudget)

# Declares a kind of worker as a tag, the capabilities it serves and a budget of concurrent slots.
#
# Specialization is a budget, not a subclass: the resident engine is shared, so what separates one
# kind of worker from another is only what it serves and how much of the machine it may use at once.
# A profile admits work while a slot is free and refuses it otherwise, counting every decision,
# which isolates a heavy profile from a light one. A profile backed by an outside tool, such as OCR,
# is marked polyglot. A profile only declares and counts: it never starts a process.
#
#   receiver   o1 = new stzWorkerProfile("nlp", [ :sentiment, :entities ], 2)
#   example    ? o1.Handles("ENTITIES")
#              #--> 1
#              ? o1.Acquire()
#              #--> 1
#              ? o1.Acquire()
#              #--> 1
#              ? o1.Acquire()
#              #--> 0
#              ? o1.Narrate()
#              #--> profile nlp [2/2 slots, serves sentiment, entities]
#   see        stzWorkerPool, stzFacetCatalog
class stzWorkerProfile from stzObject

	@cTag = ""
	@aCapabilities = []     # engine features this profile serves
	@nBudget = 1            # max concurrent slots (load isolation)
	@nInFlight = 0          # slots currently held
	@cExternalTool = ""     # non-empty = a polyglot-spawn worker (e.g. vision)
	@aRealizedBy = []       # OPTIONAL provenance: base/ modules realizing
	                        # this facet (facet<->module is many-to-many;
	                        # never forced 1:1 -- see the R8 naming law)
	@nAdmitted = 0          # lifetime admitted count (metrics)
	@nRejected = 0          # lifetime over-budget rejections (metrics)
	@nMaxQueue = 0          # backpressure: max queued items (0 = unbounded)
	@nShed = 0              # lifetime load-shed count (queue-full rejections)

	# Builds a worker profile: a capability tag, the capabilities it serves and a budget of concurrent slots.
	#
	#   pcTag            the profile's tag, kept in lower case
	#   paCapabilities   the capabilities it serves, as a list, or one value that is wrapped into a
	#                    list
	#   pnBudget         how many slots may be held at once, at least 1
	#   returns          nothing; the object is built
	#   note             a budget that is not a whole number is accepted as given
	#   warning          a budget below 1 raises an error saying the budget must be at least 1 slot
	#   see              StzWorkerProfileQ, Budget
	def init(pcTag, paCapabilities, pnBudget)
		@cTag = StzLower("" + pcTag)
		if isList(paCapabilities)
			@aCapabilities = paCapabilities
		else
			@aCapabilities = [ paCapabilities ]
		ok
		if pnBudget < 1
			stzraise("A worker profile's budget must be >= 1 slot.")
		ok
		@nBudget = pnBudget

	# Returns the profile's tag, in lower case.
	#
	#   returns    a text
	#   see        Handles, init
	def Tag()
		return @cTag

	# Returns the capabilities this profile serves.
	#
	#   returns    a list, as given at birth
	#   see        Handles
	def Capabilities()
		return @aCapabilities

	# Returns the most slots the profile may hold at once.
	#
	#   returns    a number
	#   see        SetBudget, InFlight
	def Budget()
		return @nBudget

	# Changes the budget of concurrent slots; slots already held are not taken back.
	#
	#   nBudget    the new number of slots, at least 1
	#   returns    the profile itself, so calls chain
	#   warning    a value below 1 raises an error and keeps the old budget
	#   see        Budget, CanAdmit
	def SetBudget(nBudget)
		if nBudget < 1
			stzraise("Budget must be >= 1.")
		ok
		@nBudget = nBudget
		return This

	# Returns how many slots are held now.
	#
	#   returns    a number
	#   see        Acquire, Release, Budget
	def InFlight()
		return @nInFlight

	# Returns how many Acquire calls were admitted since the profile was built.
	#
	#   returns    a number
	#   see        RejectedCount, Acquire
	def AdmittedCount()
		return @nAdmitted

	# Returns how many Acquire calls were refused for lack of a free slot since the profile was built.
	#
	#   returns    a number
	#   see        AdmittedCount, Acquire
	def RejectedCount()
		return @nRejected

	# Caps the queue of waiting work, so sustained overload is shed instead of growing without bound; 0 means unbounded.
	#
	#   nMax       the most queued items allowed
	#   returns    the profile itself, so calls chain
	#   see        MaxQueue, ShedCount
	#@ aka  Backpressure: cap the queue so sustained overload SHEDS load (returns a rejection) instead of growing unbounded -> OOM. 0 = unbounded (operators SHOULD set a bound in production).
	def SetMaxQueue(nMax)
		if nMax < 0  nMax = 0  ok
		@nMaxQueue = nMax
		return This

	# Returns the cap on the queue of waiting work.
	#
	#   returns    a number; 0 means unbounded
	#   see        SetMaxQueue
	def MaxQueue()
		return @nMaxQueue

	# Returns how many pieces of work were shed, refused because the queue was full.
	#
	#   returns    a number
	#   see        Shed, SetMaxQueue
	def ShedCount()
		return @nShed

	# Counts one piece of work as shed; the pool calls it when a dispatch meets a full queue.
	#
	#   returns    the profile itself, so calls chain
	#   see        ShedCount, SetMaxQueue
	def Shed()
		@nShed++
		return This

	# Marks the profile as a polyglot worker backed by an outside tool such as an OCR program.
	#
	#   pcTool     the name of the external tool
	#   returns    the profile itself, so calls chain
	#   warning    the tool is only recorded: nothing is launched
	#   see        ExternalTool, IsPolyglot
	#@ aka  Mark this profile as a POLYGLOT worker backed by an external tool (run off-process via the reactor's async spawn -- R8.3). Vision/OCR is the canonical case (no engine image support).
	def SetExternalTool(pcTool)
		@cExternalTool = "" + pcTool
		return This

	# Returns the name of the outside tool behind the profile.
	#
	#   returns    a text; empty for an engine-native profile
	#   see        SetExternalTool, IsPolyglot
	def ExternalTool()
		return @cExternalTool

	# TRUE if the profile is backed by an external tool.
	#
	#   returns    TRUE or FALSE
	#   see        ExternalTool, MappingKind
	def IsPolyglot()
		return @cExternalTool != ""

	# Returns the names of the library modules recorded as realizing this profile.
	#
	#   returns    a list of text; empty until set
	#   see        SetRealizedBy, MappingKind
	#@ aka  -- facet<->module provenance (OPTIONAL; never forced 1:1) -------------- Record which base/ modules realize this facet. A facet may map to a module 1:1 (:data), to several (:math, :knowledge -- composed), or to none (:vision -- external; :search -- composed-only). This is a recorded RELATION between the facet-graph and stzCodeGraph, not an identity. See the R8 naming law. the modules that realize 
	def RealizedBy()
		return @aRealizedBy

	# Records which library modules realize this profile.
	#
	#   paModules   a list of module names, or one name that is wrapped into a list
	#   returns     the profile itself, so calls chain
	#   see         RealizedBy, MappingKind
	def SetRealizedBy(paModules)
		if isList(paModules)
			@aRealizedBy = paModules
		else
			@aRealizedBy = [ "" + paModules ]
		ok
		return This

	# Returns the modules that realize this profile, the same list that RealizedBy gives.
	#
	#   returns    a list of text; empty until set
	#   see        RealizedBy
	def RealizingModules()
		return @aRealizedBy

	# Returns how the profile maps to code: external, logical, grounded or composed.
	#
	#   returns    a symbol: external when an outside tool backs it, else logical for no module,
	#              grounded for one module, composed for two or more
	#   see        SetRealizedBy, SetExternalTool
	#@ aka  How the facet maps to code: :grounded (exactly one module), :composed (2+ modules), :external (polyglot, no module), :logical (no module and not polyglot -- a purely logical competence).
	def MappingKind()
		if @cExternalTool != ""
			return :external
		ok
		_n_ = len(@aRealizedBy)
		if _n_ = 0
			return :logical
		but _n_ = 1
			return :grounded
		ok
		return :composed

	# TRUE if the profile serves a capability, whatever its letter case.
	#
	#   pcCapability   the capability to look for, as a text or a symbol
	#   returns        TRUE or FALSE
	#   see            Capabilities, Tag
	#@ aka  Does this profile serve a capability? (case-insensitive)
	def Handles(pcCapability)
		_c_ = StzLower("" + pcCapability)
		_n_ = len(@aCapabilities)
		for _i_ = 1 to _n_
			if StzLower("" + @aCapabilities[_i_]) = _c_
				return 1
			ok
		next
		return 0

	# TRUE if at least one slot is free.
	#
	#   returns    TRUE or FALSE
	#   see        Acquire, Budget
	#@ aka  -- admission (the load-isolation primitive) ---------------------------
	def CanAdmit()
		return @nInFlight < @nBudget

	# Takes a slot if one is free and counts the decision.
	#
	#   returns    TRUE when a slot was taken, FALSE when the profile is over budget
	#   see        Release, CanAdmit, AdmittedCount
	#@ aka  Take a slot if one is free. Returns TRUE (admitted) or FALSE (over budget -- the caller queues). Every decision is counted.
	def Acquire()
		if @nInFlight < @nBudget
			@nInFlight++
			@nAdmitted++
			return 1
		ok
		@nRejected++
		return 0

	# Frees one held slot; it never goes below zero.
	#
	#   returns    the profile itself, so calls chain
	#   see        Acquire, InFlight
	def Release()
		if @nInFlight > 0
			@nInFlight--
		ok
		return This

	# Returns one line describing the profile: tag, outside tool, slots held out of budget and capabilities.
	#
	#   returns    a text such as profile nlp [0/2 slots, serves sentiment, entities]
	#   see        Capabilities, InFlight
	def Narrate()
		_cX_ = ""
		if @cExternalTool != ""
			_cX_ = " via " + @cExternalTool
		ok
		return "profile " + @cTag + _cX_ + " [" + @nInFlight + "/" + @nBudget +
			" slots, serves " + This._JoinCaps() + "]"

	def _JoinCaps()
		_cR_ = ""
		_n_ = len(@aCapabilities)
		for _i_ = 1 to _n_
			_cR_ += "" + @aCapabilities[_i_]
			if _i_ < _n_  _cR_ += ", "  ok
		next
		return _cR_
