# R4b -- stzGovernance: PROGRAMMATIC GOVERNANCE AS DECLARABLE CONTRACTS
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.7 G6 + 5.8 trust postures.)
# The five primitives closing the industry's governance gaps, plus the
# structural split the doctrine demands:
#
#   PERMISSION (CAN)  is not  AUTHORITY (SHOULD) -- an actor may hold
#   one without the other, and MayProceed() composes BOTH with the
#   action's RISK TIER before anything happens.
#
#   oGov = new stzGovernance("kitchen-ops")
#   oGov.DeclareRisk("send-invoice", 3)
#   oGov.GrantPermission("billing-agent", "send-invoice")   # CAN
#   oGov.SetAuthority("billing-agent", :Delegated)          # SHOULD (level 2)
#   ? oGov.MayProceed("billing-agent", "send-invoice")      # refused: tier 3
#                                                           # needs autonomous+
# MECHANISM ONLY: no fixed constitution ships with Softanza; regimes
# are product space (the 5.7 boundary). FORMAT: *.zgov.



# THE LINEAGE LIVES IN A TABLE, NOT IN AN ATTRIBUTE.
#
# Ring's `=` and attribute-stores COPY, so a governance handed to an
# agent host, a constellation or a federation becomes a SNAPSHOT there.
# For the regime (risks, permissions, authorities, postures) that
# forking fails CLOSED -- a permission the copy never saw is a
# permission refused -- which is why it stayed in attributes and why
# this was a caveat rather than an emergency.
#
# The lineage does not have that mercy. It is a RECORD, and a record
# that forks does not fail closed or open: it silently answers a
# different question than the one asked. Decisions taken through the
# host's copy were invisible to the caller's own handle and vice versa,
# so `NumberOfDecisions()` returned a number that was true of one face
# and of no other -- and an audit trail that is true of one face is not
# an audit trail. With the rows in a table keyed by id, every copy IS
# the lineage.
#
# Same shape as $aStzServiceRegistries, for the same reason, and the
# same reason the security ledger's current slot lives in the engine:
# state that must not fork does not belong in a copied object.
# [ [ id, rows, capacity, dropped ], ... ]
$aStzGovernanceLineages = []
$nStzGovernanceSeq = 0

class stzGovernance from stzObject

	@cName = ""
	@aRisks = []          # [ action, tier 1..4 ]
	@aPermissions = []    # CAN:    [ actor, action ]
	@aAuthorities = []    # SHOULD: [ actor, type ]
	@aCommitments = []    # [ id, state, history(list) ]
	@aDecommissions = []  # [ actor, obligations(list), fulfilled(list) ]
	@aPostures = []       # [ executor, trusted|external|sandboxed ]
	@cWhy = ""
	# The slot in $aStzGovernanceLineages. An ID survives Ring's copy; a
	# list does not. Materialized EAGERLY in init(), never lazily -- a
	# lazily-created handle is created once PER COPY and forks silently,
	# which is the exact failure this table exists to remove.
	@nId = 0

	def init(pcName)
		@cName = "" + pcName
		$nStzGovernanceSeq = $nStzGovernanceSeq + 1
		@nId = $nStzGovernanceSeq
		# [ id, rows, capacity, dropped ]. The lineage is BOUNDED, and says
		# so: an unbounded list that grows for the life of a long-running
		# process is a leak wearing an audit trail's clothes, and a bounded
		# one that drops SILENTLY is worse, because the gap reads as a
		# period when nothing was decided. The dropped count is the
		# difference between the two.
		$aStzGovernanceLineages + [ @nId, [], 512, 0 ]

	def SetName(pcName)
		@cName = "" + pcName

	def Name_()
		return @cName

	def Why()
		return @cWhy

	#-- 1. ACTION RISK TIERS ------------------------------------------------

	def DeclareRisk(pcAction, nTier)
		if nTier < 1 or nTier > 4
			stzraise("Risk tiers run 1 (low) to 4 (critical).")
		ok
		_cA_ = StzLower(ring_trim("" + pcAction))
		_n_ = len(@aRisks)
		for _i_ = 1 to _n_
			if @aRisks[_i_][1] = _cA_
				@aRisks[_i_][2] = nTier
				return This
			ok
		next
		@aRisks + [ _cA_, nTier ]
		return This

	def RiskOf(pcAction)
		_cA_ = StzLower(ring_trim("" + pcAction))
		_n_ = len(@aRisks)
		for _i_ = 1 to _n_
			if @aRisks[_i_][1] = _cA_
				return @aRisks[_i_][2]
			ok
		next
		return 0   # undeclared

	#-- 2. PERMISSION (CAN) vs AUTHORITY (SHOULD) ----------------------------

	def GrantPermission(pcActor, pcAction)
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_cAn_ = StzLower(ring_trim("" + pcAction))
		_n_ = len(@aPermissions)
		for _i_ = 1 to _n_
			if @aPermissions[_i_][1] = _cAc_ and @aPermissions[_i_][2] = _cAn_
				return This
			ok
		next
		@aPermissions + [ _cAc_, _cAn_ ]
		return This

	def HasPermission(pcActor, pcAction)
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_cAn_ = StzLower(ring_trim("" + pcAction))
		_n_ = len(@aPermissions)
		for _i_ = 1 to _n_
			if @aPermissions[_i_][1] = _cAc_ and @aPermissions[_i_][2] = _cAn_
				return 1
			ok
		next
		return 0

	def SetAuthority(pcActor, pcType)
		_cT_ = StzLower(ring_trim("" + pcType))
		if This._AuthLevel(_cT_) = 0
			stzraise("Authority is :Advisory, :Delegated, :Autonomous or :EmergencyOverride.")
		ok
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_n_ = len(@aAuthorities)
		for _i_ = 1 to _n_
			if @aAuthorities[_i_][1] = _cAc_
				@aAuthorities[_i_][2] = _cT_
				return This
			ok
		next
		@aAuthorities + [ _cAc_, _cT_ ]
		return This

	def AuthorityOf(pcActor)
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_n_ = len(@aAuthorities)
		for _i_ = 1 to _n_
			if @aAuthorities[_i_][1] = _cAc_
				return @aAuthorities[_i_][2]
			ok
		next
		return ""

	def _AuthLevel(pcType)
		if pcType = "advisory"
			return 1
		but pcType = "delegated"
			return 2
		but pcType = "autonomous"
			return 3
		but pcType = "emergencyoverride" or pcType = "emergency_override"
			return 4
		ok
		return 0

	# THE COMPOSITION: CAN + SHOULD + RISK, decided BEFORE the act.
	# An actor proceeds only when it HAS the permission AND its
	# authority level covers the action's risk tier. Every verdict
	# narrates (LAW 3); an undeclared action is REFUSED, not assumed.
	def MayProceed(pcActor, pcAction)
		_nTier_ = This.RiskOf(pcAction)
		if _nTier_ = 0
			@cWhy = "refused: '" + pcAction + "' has NO declared risk tier (undeclared actions never proceed)"
			return 0
		ok
		if This.HasPermission(pcActor, pcAction) = 0
			@cWhy = "refused: '" + pcActor + "' lacks PERMISSION (can) for '" + pcAction + "'"
			return 0
		ok
		_cAuth_ = This.AuthorityOf(pcActor)
		_nLevel_ = This._AuthLevel(_cAuth_)
		if _nLevel_ < _nTier_
			@cWhy = "refused: '" + pcActor + "' holds '" + _cAuth_ +
				"' authority (level " + _nLevel_ + ") but '" + pcAction +
				"' is risk tier " + _nTier_ + " (SHOULD does not cover it)"
			return 0
		ok
		@cWhy = "allowed: permission held AND '" + _cAuth_ +
			"' authority (level " + _nLevel_ + ") covers risk tier " + _nTier_
		return 1

	#-- 3. COMMITMENT STATE (forward-only) -----------------------------------

	def OpenCommitment(pcId)
		_cId_ = StzLower(ring_trim("" + pcId))
		_n_ = len(@aCommitments)
		for _i_ = 1 to _n_
			if @aCommitments[_i_][1] = _cId_
				stzraise("Commitment '" + _cId_ + "' already open.")
			ok
		next
		@aCommitments + [ _cId_, "exploratory", [ "exploratory" ] ]
		return This

	def AdvanceCommitment(pcId)
		_cId_ = StzLower(ring_trim("" + pcId))
		_n_ = len(@aCommitments)
		for _i_ = 1 to _n_
			if @aCommitments[_i_][1] = _cId_
				if @aCommitments[_i_][2] = "exploratory"
					@aCommitments[_i_][2] = "provisional"
				but @aCommitments[_i_][2] = "provisional"
					@aCommitments[_i_][2] = "committed"
				else
					stzraise("Commitment '" + _cId_ + "' is already COMMITTED -- the state is forward-only (regressions are new commitments, deliberately).")
				ok
				@aCommitments[_i_][3] + @aCommitments[_i_][2]
				return @aCommitments[_i_][2]
			ok
		next
		stzraise("No commitment '" + _cId_ + "'.")

	def CommitmentStateOf(pcId)
		_cId_ = StzLower(ring_trim("" + pcId))
		_n_ = len(@aCommitments)
		for _i_ = 1 to _n_
			if @aCommitments[_i_][1] = _cId_
				return @aCommitments[_i_][2]
			ok
		next
		return ""

	#-- 4. DECOMMISSION CONTRACT ---------------------------------------------

	def DeclareDecommission(pcActor, pacObligations)
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_acO_ = []
		_n_ = len(pacObligations)
		for _i_ = 1 to _n_
			_acO_ + StzLower(ring_trim("" + pacObligations[_i_]))
		next
		@aDecommissions + [ _cAc_, _acO_, [] ]
		return This

	def FulfillObligation(pcActor, pcObligation)
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_cO_ = StzLower(ring_trim("" + pcObligation))
		_n_ = len(@aDecommissions)
		for _i_ = 1 to _n_
			if @aDecommissions[_i_][1] = _cAc_
				if ring_find(@aDecommissions[_i_][2], _cO_) = 0
					stzraise("'" + _cO_ + "' is not a declared obligation for '" + _cAc_ + "'.")
				ok
				if ring_find(@aDecommissions[_i_][3], _cO_) = 0
					@aDecommissions[_i_][3] + _cO_
				ok
				return This
			ok
		next
		stzraise("No decommission contract for '" + _cAc_ + "'.")

	# retirement is EARNED: every declared obligation fulfilled first
	def MayRetire(pcActor)
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_n_ = len(@aDecommissions)
		for _i_ = 1 to _n_
			if @aDecommissions[_i_][1] = _cAc_
				_acMissing_ = []
				_nO_ = len(@aDecommissions[_i_][2])
				for _j_ = 1 to _nO_
					if ring_find(@aDecommissions[_i_][3], @aDecommissions[_i_][2][_j_]) = 0
						_acMissing_ + @aDecommissions[_i_][2][_j_]
					ok
				next
				if len(_acMissing_) = 0
					@cWhy = "allowed: every declared obligation fulfilled"
					return 1
				ok
				@cWhy = "refused: obligations pending -- " + JoinXT(_acMissing_, ", ")
				return 0
			ok
		next
		@cWhy = "refused: no decommission contract declared for '" + _cAc_ + "' (retirement without a contract never proceeds)"
		return 0

	#-- 5. DECISION LINEAGE ----------------------------------------------------

	# a decision records its rationale AND the actor's authority + the
	# action's risk AT THE TIME -- 'why does this look the way it does'
	# stays answerable forever
	#
	# WHEN it was decided is part of that answer, and it used to be
	# missing: a lineage without time cannot say whether a decision came
	# before or after the change it is supposed to explain, which is the
	# first question anyone asks of it. The clock is the WALL clock on
	# purpose -- this is an absolute "when in the world", not a duration,
	# and epoch MILLIS stay exact in f64 (nanos would not).
	def RecordDecision(pcId, pcRationale, pcActor, pcAction)
		return This.RecordDecisionAt(pcId, pcRationale, pcActor, pcAction,
			StzEngineTimeNowMs())

	# the deterministic twin, so a guard can pin an ordering without
	# racing the clock
	def RecordDecisionAt(pcId, pcRationale, pcActor, pcAction, pnWallMs)
		# The ACTION is kept beside its risk tier. Keeping only the tier
		# (as the first shape did) makes "what was decided about
		# send-invoice" unanswerable: two unrelated actions at tier 3 are
		# indistinguishable, so the pivot would return confident nonsense.
		#
		# The authority and the risk are read through THIS face, because
		# they are what the deciding face believed at the moment it
		# decided -- that is precisely the fact being recorded. Only the
		# ROWS are shared; the regime is not.
		This._Append([ StzLower(ring_trim("" + pcId)), "" + pcRationale,
			StzLower(ring_trim("" + pcActor)), This.AuthorityOf(pcActor),
			This.RiskOf(pcAction), pnWallMs,
			StzLower(ring_trim("" + pcAction)) ])
		return This

	# How many decisions this governance keeps. Lowering it below the
	# current count drops the oldest immediately -- and counts them.
	def SetLineageCapacity(pnMax)
		return This.SetLineageCapacityQ(pnMax)

	def SetLineageCapacityQ(pnMax)
		if pnMax < 1
			stzraise("stzGovernance: a lineage capacity of " + pnMax +
				" would keep no decisions at all.")
		ok
		_nSlot_ = This._Slot()
		$aStzGovernanceLineages[_nSlot_][3] = pnMax
		_aRows_ = $aStzGovernanceLineages[_nSlot_][2]
		_nDrop_ = 0
		while len(_aRows_) > pnMax
			del(_aRows_, 1)
			_nDrop_++
		end
		$aStzGovernanceLineages[_nSlot_][2] = _aRows_
		$aStzGovernanceLineages[_nSlot_][4] = $aStzGovernanceLineages[_nSlot_][4] + _nDrop_
		return This

	def LineageCapacity()
		return $aStzGovernanceLineages[This._Slot()][3]

	# The count the bound cost. Zero means the lineage below is COMPLETE;
	# anything else means the record starts later than the process did,
	# and an auditor deserves to know which of the two they are reading.
	def LineageDropped()
		return $aStzGovernanceLineages[This._Slot()][4]

	def LineageIsComplete()
		return This.LineageDropped() = 0

	# The decision under this id. When an id was recorded more than once
	# the LATEST wins -- a re-decision supersedes, and the earlier ones
	# stay reachable through LineageHistoryOf().
	def LineageOf(pcId)
		_cId_ = StzLower(ring_trim("" + pcId))
		_aRows_ = This.Lineage()
		_n_ = len(_aRows_)
		for _i_ = _n_ to 1 step -1
			if _aRows_[_i_][1] = _cId_
				return This._RecordOf(_aRows_[_i_])
			ok
		next
		return []

	def LineageHistoryOf(pcId)
		return This._DecisionsWhere(1, StzLower(ring_trim("" + pcId)))

	# THE PIVOTS. Answering only by id made the lineage useless for every
	# question an investigation actually opens with -- "what did this
	# actor decide", "who decided anything about this action", "what was
	# decided in the hour before the incident". An audit trail you can
	# only query by a key you already know is a lookup table.
	def DecisionsOf(pcActor)
		return This._DecisionsWhere(3, StzLower(ring_trim("" + pcActor)))

	def DecisionsAbout(pcAction)
		return This._DecisionsWhere(7, StzLower(ring_trim("" + pcAction)))

	def DecisionsSince(pnWallMs)
		return This.DecisionsBetween(pnWallMs, 0)

	# A zero upper bound means "no upper bound" -- an epoch stamp is never
	# zero, so the sentinel cannot collide with a real one.
	def DecisionsBetween(pnFromMs, pnToMs)
		_aOut_ = []
		_aRows_ = This.Lineage()
		_n_ = len(_aRows_)
		for _i_ = 1 to _n_
			if _aRows_[_i_][6] >= pnFromMs
				if pnToMs = 0 or _aRows_[_i_][6] <= pnToMs
					_aOut_ + This._RecordOf(_aRows_[_i_])
				ok
			ok
		next
		return _aOut_

		# the full decision lineage (every recorded decision), raw rows.
		# THE SHARED ROWS -- read through the table, so any face sees
		# every face's decisions.
		def Lineage()
			return $aStzGovernanceLineages[This._Slot()][2]

		# ...and the same as readable records
		def Decisions()
			_aOut_ = []
			_aRows_ = This.Lineage()
			_n_ = len(_aRows_)
			for _i_ = 1 to _n_
				_aOut_ + This._RecordOf(_aRows_[_i_])
			next
			return _aOut_

		def NumberOfDecisions()
			return len( This.Lineage() )

	# Release this governance's slot. Ring has no destructor, so this is
	# the OWNER's explicit act -- and only the owner's: a copy calling it
	# would free the rows every other face is still reading. Without it
	# the table keeps one slot per governance ever constructed, which is
	# fine for a regime that lives as long as the process and a leak for
	# one built per request.
	def ReleaseLineage()
		_n_ = len($aStzGovernanceLineages)
		for _i_ = 1 to _n_
			if $aStzGovernanceLineages[_i_][1] = @nId
				del($aStzGovernanceLineages, _i_)
				return This
			ok
		next
		return This

	  #-- the table ---------------------------------------------------------

	def _Slot()
		if @nId = 0
			stzraise("stzGovernance: this object has no lineage slot -- it was " +
				"built with a paren-less `new stzGovernance`, which skips init(). " +
				"Use `new stzGovernance(name)`.")
		ok
		_n_ = len($aStzGovernanceLineages)
		for _i_ = 1 to _n_
			if $aStzGovernanceLineages[_i_][1] = @nId
				return _i_
			ok
		next
		# only reachable after ReleaseLineage(); re-open rather than raise
		$aStzGovernanceLineages + [ @nId, [], 512, 0 ]
		return len($aStzGovernanceLineages)

	# Read-modify-write, deliberately explicit: the table hands back a
	# COPY of the rows (Ring copies on return), so an append has to be
	# written back or it lands nowhere.
	def _Append(paRow)
		_nSlot_ = This._Slot()
		_aRows_ = $aStzGovernanceLineages[_nSlot_][2]
		_aRows_ + paRow
		if len(_aRows_) > $aStzGovernanceLineages[_nSlot_][3]
			del(_aRows_, 1)
			$aStzGovernanceLineages[_nSlot_][4] = $aStzGovernanceLineages[_nSlot_][4] + 1
		ok
		$aStzGovernanceLineages[_nSlot_][2] = _aRows_

	def _RecordOf(paRow)
		return [ :id = paRow[1],
			:rationale = paRow[2],
			:actor = paRow[3],
			:authorityAtTime = paRow[4],
			:riskAtTime = paRow[5],
			:at = paRow[6],
			:action = paRow[7] ]

	def _DecisionsWhere(pnField, pcValue)
		_aOut_ = []
		_aRows_ = This.Lineage()
		_n_ = len(_aRows_)
		for _i_ = 1 to _n_
			if _aRows_[_i_][pnField] = pcValue
				_aOut_ + This._RecordOf(_aRows_[_i_])
			ok
		next
		return _aOut_

	#-- EXECUTION TRUST POSTURES (5.8) -----------------------------------------

	def DeclarePosture(pcExecutor, pcPosture)
		_cP_ = StzLower(ring_trim("" + pcPosture))
		if ring_find([ "trusted", "external", "sandboxed" ], _cP_) = 0
			stzraise("A posture is :Trusted (in-process), :External (out-of-process) or :Sandboxed (LLM-composed).")
		ok
		_cE_ = StzLower(ring_trim("" + pcExecutor))
		_n_ = len(@aPostures)
		for _i_ = 1 to _n_
			if @aPostures[_i_][1] = _cE_
				@aPostures[_i_][2] = _cP_
				return This
			ok
		next
		@aPostures + [ _cE_, _cP_ ]
		return This

	def PostureOf(pcExecutor)
		_cE_ = StzLower(ring_trim("" + pcExecutor))
		_n_ = len(@aPostures)
		for _i_ = 1 to _n_
			if @aPostures[_i_][1] = _cE_
				return @aPostures[_i_][2]
			ok
		next
		return ""

	# execution without a declared posture never proceeds
	def MayExecute(pcExecutor)
		_cP_ = This.PostureOf(pcExecutor)
		if _cP_ = ""
			@cWhy = "refused: '" + pcExecutor + "' has NO declared trust posture"
			return 0
		ok
		@cWhy = "allowed: posture '" + _cP_ + "' declared"
		return 1

	#-- persistence (*.zgov) ------------------------------------------------------

	# LOAD a .zgov back INTO this governance -- the mirror of Save(), and
	# the object's OWN act (LoadFrom: 'Load' is a Ring keyword).
	def LoadFrom(pcFile)
		_cContent_ = StzReplace(read(pcFile), char(13), "")
		_acLines_ = StzSplit(_cContent_, char(10))
		_cSection_ = ""
		_nLen_ = len(_acLines_)
		for _i_ = 1 to _nLen_
			_cL_ = ring_trim(_acLines_[_i_])
			if _cL_ = ""
				loop
			ok
			if StzLeft(_cL_, 11) = 'governance '
				_acQ_ = StzSplit(_cL_, '"')
				if len(_acQ_) >= 2
					This.SetName(_acQ_[2])
				ok
			# A SECTION HEADER IS ANY LINE WITHOUT A FIELD SEPARATOR. The
			# old form listed the four known headers by name, so a file
			# carrying a section this build does not know kept the
			# PREVIOUS section active and fed that section's parser rows
			# meant for another -- and DeclarePosture raises on a value
			# it does not recognise, so a newer file took an older build
			# down. Recognising headers structurally makes an unknown
			# section skip its own rows instead.
			but StzFindFirst("|", _cL_) = 0
				_cSection_ = _cL_
			but _cSection_ = "risks"
				_acP_ = StzSplit(_cL_, "|")
				if len(_acP_) = 2
					This.DeclareRisk(ring_trim(_acP_[1]), ring_number(ring_trim(_acP_[2])))
				ok
			but _cSection_ = "permissions"
				_acP_ = StzSplit(_cL_, "|")
				if len(_acP_) = 2
					This.GrantPermission(ring_trim(_acP_[1]), ring_trim(_acP_[2]))
				ok
			but _cSection_ = "authorities"
				_acP_ = StzSplit(_cL_, "|")
				if len(_acP_) = 2
					This.SetAuthority(ring_trim(_acP_[1]), ring_trim(_acP_[2]))
				ok
			but _cSection_ = "postures"
				_acP_ = StzSplit(_cL_, "|")
				if len(_acP_) = 2
					This.DeclarePosture(ring_trim(_acP_[1]), ring_trim(_acP_[2]))
				ok
			but _cSection_ = "decisions"
				This._LoadDecisionLine(_cL_)
			ok
		next
		return This

	# id | at | actor | authority | risk | action | rationale...
	# The rationale is LAST and its own separators are rejoined, so a
	# rationale that argues "a|b|c" survives the round trip intact. The
	# authority and risk are read from the FILE, not recomputed: they are
	# the values AS OF THE DECISION, and a regime that has changed since
	# would otherwise rewrite its own history on load.
	def _LoadDecisionLine(pcLine)
		_acP_ = StzSplit(pcLine, "|")
		if len(_acP_) < 7
			return
		ok
		# Rejoin the tail RAW and trim once at the end. Trimming each
		# segment first would eat the spaces around an interior
		# separator, so "audit | ticket" came back as "audit| ticket" --
		# a round trip that alters the text it preserves is not one.
		_cRat_ = _acP_[7]
		_n_ = len(_acP_)
		for _i_ = 8 to _n_
			_cRat_ += "|" + _acP_[_i_]
		next
		_cRat_ = ring_trim(_cRat_)
		This._Append([ ring_trim(_acP_[1]), _cRat_, ring_trim(_acP_[3]),
			ring_trim(_acP_[4]), ring_number(ring_trim(_acP_[5])),
			ring_number(ring_trim(_acP_[2])), ring_trim(_acP_[6]) ])

	def Save(pcFile)
		if StzRight(pcFile, 5) != ".zgov"
			pcFile += ".zgov"
		ok
		_c_ = 'governance "' + @cName + '"' + NL
		_c_ += "risks" + NL
		_n_ = len(@aRisks)
		for _i_ = 1 to _n_
			_c_ += "    " + @aRisks[_i_][1] + " | " + @aRisks[_i_][2] + NL
		next
		_c_ += "permissions" + NL
		_n_ = len(@aPermissions)
		for _i_ = 1 to _n_
			_c_ += "    " + @aPermissions[_i_][1] + " | " + @aPermissions[_i_][2] + NL
		next
		_c_ += "authorities" + NL
		_n_ = len(@aAuthorities)
		for _i_ = 1 to _n_
			_c_ += "    " + @aAuthorities[_i_][1] + " | " + @aAuthorities[_i_][2] + NL
		next
		_c_ += "postures" + NL
		_n_ = len(@aPostures)
		for _i_ = 1 to _n_
			_c_ += "    " + @aPostures[_i_][1] + " | " + @aPostures[_i_][2] + NL
		next
		# THE SECTION THAT WAS MISSING. Save() wrote the regime and left
		# the lineage behind, so every reason the regime looks the way it
		# does died with the process that held it -- exactly the loss
		# "answerable forever" was written to prevent. The regime is what
		# the rules ARE; the lineage is why. Persisting one without the
		# other keeps the half a reader can already see.
		_c_ += "decisions" + NL
		_aRows_ = This.Lineage()
		_n_ = len(_aRows_)
		for _i_ = 1 to _n_
			_c_ += "    " + _aRows_[_i_][1] + " | " + _aRows_[_i_][6] +
				" | " + _aRows_[_i_][3] + " | " + _aRows_[_i_][4] +
				" | " + _aRows_[_i_][5] + " | " + _aRows_[_i_][7] +
				" | " + This._OneLine(_aRows_[_i_][2]) + NL
		next
		write(pcFile, _c_)
		return pcFile

	# The format is line-based, so a rationale carrying a newline would
	# forge a row. Folded to spaces on the way out -- the only lossy step
	# in the round trip, and it loses layout, never words.
	def _OneLine(pcText)
		_c_ = StzReplace("" + pcText, char(13), " ")
		return ring_trim(StzReplace(_c_, char(10), " "))
