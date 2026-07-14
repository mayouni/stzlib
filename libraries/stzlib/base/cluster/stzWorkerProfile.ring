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

func StzWorkerProfile(pcTag, paCapabilities, pnBudget)
	return new stzWorkerProfile(pcTag, paCapabilities, pnBudget)

class stzWorkerProfile from stzObject

	@cTag = ""
	@aCapabilities = []     # engine features this profile serves
	@nBudget = 1            # max concurrent slots (load isolation)
	@nInFlight = 0          # slots currently held
	@cExternalTool = ""     # non-empty = a polyglot-spawn worker (e.g. vision)
	@nAdmitted = 0          # lifetime admitted count (metrics)
	@nRejected = 0          # lifetime over-budget rejections (metrics)

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

	# Mark this profile as a POLYGLOT worker backed by an external tool
	# (run off-process via the reactor's async spawn -- R8.3). Vision/OCR
	# is the canonical case (no engine image support).
	def UsesExternalTool(pcTool)
		@cExternalTool = "" + pcTool
		return This

	def ExternalTool()
		return @cExternalTool

	def IsPolyglot()
		return @cExternalTool != ""

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
