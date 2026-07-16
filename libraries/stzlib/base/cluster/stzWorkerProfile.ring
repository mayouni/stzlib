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

	def Tag()
		return @cTag

	def Capabilities()
		return @aCapabilities

	def Budget()
		return @nBudget

	def SetBudget(nBudget)
		if nBudget < 1
			stzraise("Budget must be >= 1.")
		ok
		@nBudget = nBudget
		return This

	def InFlight()
		return @nInFlight

	def AdmittedCount()
		return @nAdmitted

	def RejectedCount()
		return @nRejected

	# Backpressure: cap the queue so sustained overload SHEDS load
	# (returns a rejection) instead of growing unbounded -> OOM. 0 =
	# unbounded (operators SHOULD set a bound in production).
	def SetMaxQueue(nMax)
		if nMax < 0  nMax = 0  ok
		@nMaxQueue = nMax
		return This

	def MaxQueue()
		return @nMaxQueue

	def ShedCount()
		return @nShed

	def Shed()
		@nShed++
		return This

	# Mark this profile as a POLYGLOT worker backed by an external tool
	# (run off-process via the reactor's async spawn -- R8.3). Vision/OCR
	# is the canonical case (no engine image support).
	def SetExternalTool(pcTool)
		@cExternalTool = "" + pcTool
		return This

	def ExternalTool()
		return @cExternalTool

	def IsPolyglot()
		return @cExternalTool != ""

	#-- facet<->module provenance (OPTIONAL; never forced 1:1) --------------
	# Record which base/ modules realize this facet. A facet may map to a
	# module 1:1 (:data), to several (:math, :knowledge -- composed), or
	# to none (:vision -- external; :search -- composed-only). This is a
	# recorded RELATION between the facet-graph and stzCodeGraph, not an
	# identity. See the R8 naming law.
	def SetRealizedBy(paModules)
		if isList(paModules)
			@aRealizedBy = paModules
		else
			@aRealizedBy = [ "" + paModules ]
		ok
		return This

	def RealizingModules()
		return @aRealizedBy

	# How the facet maps to code: :grounded (exactly one module),
	# :composed (2+ modules), :external (polyglot, no module), :logical
	# (no module and not polyglot -- a purely logical competence).
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

	# Does this profile serve a capability? (case-insensitive)
	def Handles(pcCapability)
		_c_ = StzLower("" + pcCapability)
		_n_ = len(@aCapabilities)
		for _i_ = 1 to _n_
			if StzLower("" + @aCapabilities[_i_]) = _c_
				return TRUE
			ok
		next
		return FALSE

	#-- admission (the load-isolation primitive) ---------------------------

	def CanAdmit()
		return @nInFlight < @nBudget

	# Take a slot if one is free. Returns TRUE (admitted) or FALSE
	# (over budget -- the caller queues). Every decision is counted.
	def Acquire()
		if @nInFlight < @nBudget
			@nInFlight++
			@nAdmitted++
			return TRUE
		ok
		@nRejected++
		return FALSE

	def Release()
		if @nInFlight > 0
			@nInFlight--
		ok
		return This

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
