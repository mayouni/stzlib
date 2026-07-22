#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZSECURITYPOSTURE        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# The security doctrine, made RUNNABLE. Like stzGovernanceChecks runs invariants
# over an agent graph, stzSecurityPosture runs invariants over a PROJECT's
# security surface -- its central store, its deployment sites, its actors -- and
# reports structured findings a human (or CI) acts on. It turns "expression is
# free, admission is governed" from a principle into a check.
#
# You describe the surface, then ask:
#
#   oP = new stzSecurityPosture("restolean")
#   oP.SetStore(oStore).AddSite(oApi).AddSite(oWeb).AddActor(oLLM).AddActor(oHuman)
#   aFindings = oP.Findings()      # [ [ :invariant, :severity, :where, :message ], ... ]
#   ? oP.IsSound()                 # verdict: no ERRORS (warnings are advisory)
#   oP.Report()                    # human-readable
#
# Invariants (findings shaped like stzGovernanceChecks: invariant/severity/message):
#   no-sandboxed-effectful (ERROR) -- an actor is sandboxed yet holds 'effectful'
#       (the load-bearing rule: a sandboxed/LLM actor must never commit).
#   inline-key (WARN) -- a site holds a secret inline, not registered in the
#       central store, so its reveals are NOT centrally audited.
#   no-central-store (WARN) -- the project has secret-bearing sites but no store.
#   refused-accesses (WARN) -- the store logged refused reveals; review for misuse.

  #=============#
 #  FUNCTIONS  #
#=============#

func StzSecurityPostureQ(pcName)
	return new stzSecurityPosture(pcName)

func StzSecurityInvariantNames()
	return [ "no-sandboxed-effectful", "inline-key", "no-central-store", "refused-accesses" ]

# CI-style top-level entry points (parity with StzCheckAgentGraph):
func StzCheckSecurityPosture(poPosture)
	return poPosture.Findings()

func StzSecurityPostureIsSound(poPosture)
	return poPosture.IsSound()


  #=====================#
 #  STZSECURITYPOSTURE  #
#=====================#

class stzSecurityPosture from stzObject

	@cName = ""
	@oStore = NULL     # the project's central stzSecretStore (or NULL)
	@aSites = []       # deployment sites to audit
	@aActors = []      # actors to audit

	def init(pcName)
		@cName = "" + pcName

	  #-- describe the surface --------------------------------------------

	def SetStore(poStore)
		@oStore = poStore
		return This

	def AddSite(poSite)
		@aSites + poSite
		return This

	def AddActor(poActor)
		@aActors + poActor
		return This

	  #-- run the invariants ----------------------------------------------

	# every invariant, as a flat finding list. A finding is
	# [ :invariant, :severity, :where, :message ] -- same spirit as
	# stzGovernanceChecks (invariant / severity / message).
	def Findings()
		_aF_ = []
		_a1_ = This._CheckSandboxedEffectful()
		_n_ = len(_a1_)
		for _i_ = 1 to _n_
			_aF_ + _a1_[_i_]
		next
		_a1_ = This._CheckInlineKeys()
		_n_ = len(_a1_)
		for _i_ = 1 to _n_
			_aF_ + _a1_[_i_]
		next
		_a1_ = This._CheckNoCentralStore()
		_n_ = len(_a1_)
		for _i_ = 1 to _n_
			_aF_ + _a1_[_i_]
		next
		_a1_ = This._CheckRefusedAccesses()
		_n_ = len(_a1_)
		for _i_ = 1 to _n_
			_aF_ + _a1_[_i_]
		next
		return _aF_

	# sound = no ERROR findings (warnings are advisory, not blocking).
	def IsSound()
		return This.NumberOf(:error) = 0

	# clean = nothing flagged at all.
	def IsClean()
		return len(This.Findings()) = 0

	def NumberOfFindings()
		return len(This.Findings())

	def NumberOf(pcSeverity)
		_c_ = 0
		_aF_ = This.Findings()
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			if _aF_[_i_][:severity] = pcSeverity
				_c_++
			ok
		next
		return _c_

	def Report()
		_aF_ = This.Findings()
		? "Security posture of '" + @cName + "': " + This.NumberOf(:error) +
			" error(s), " + This.NumberOf(:warn) + " warning(s)  -> " +
			_StzPostureVerdict(This.IsSound())
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			_f_ = _aF_[_i_]
			? "  [" + upper("" + _f_[:severity]) + "] " + _f_[:invariant] + " @ " +
				_f_[:where] + " -- " + _f_[:message]
		next

	  #-- the invariants (each returns its own finding list) --------------

	# an actor is sandboxed yet can cause effects -- an LLM that could commit.
	def _CheckSandboxedEffectful()
		_aF_ = []
		_n_ = len(@aActors)
		for _i_ = 1 to _n_
			_a_ = @aActors[_i_]
			if _a_.Posture() = "sandboxed" and _a_.IsEffectful()
				_aF_ + [ :invariant = "no-sandboxed-effectful", :severity = :error,
					:where = "" + _a_.Name(),
					:message = "actor '" + _a_.Name() + "' is sandboxed yet holds 'effectful' -- " +
					"a sandboxed/LLM actor must never be able to commit" ]
			ok
		next
		return _aF_

	# a site holds a secret inline (directly), not registered in the store,
	# so its reveals bypass the central audit.
	def _CheckInlineKeys()
		_aF_ = []
		_n_ = len(@aSites)
		for _i_ = 1 to _n_
			_s_ = @aSites[_i_]
			if _s_.HasAuthSecret()   # a directly-held stzSecret (not store-backed)
				_aF_ + [ :invariant = "inline-key", :severity = :warn,
					:where = "" + _s_.Name(),
					:message = "site '" + _s_.Name() + "' holds an inline secret (" +
					_s_.AuthReference() + ") not registered in the central store -- " +
					"its reveals are not centrally audited; prefer SetAuthFromStoreQ(store, name)" ]
			ok
		next
		return _aF_

	# secret-bearing sites but no central store to govern them.
	def _CheckNoCentralStore()
		_aF_ = []
		if isObject(@oStore)
			return _aF_
		ok
		_n_ = len(@aSites)
		for _i_ = 1 to _n_
			if @aSites[_i_].HasSecretAuth()
				_aF_ + [ :invariant = "no-central-store", :severity = :warn,
					:where = "" + @cName,
					:message = "the project has secret-bearing sites but no central store -- " +
					"register secrets in a stzSecretStore for one governed, audited surface" ]
				return _aF_
			ok
		next
		return _aF_

	# the store logged refused reveals -- a misuse signal worth reviewing.
	def _CheckRefusedAccesses()
		_aF_ = []
		if NOT isObject(@oStore)
			return _aF_
		ok
		_nR_ = @oStore.RefusedAccesses()
		if _nR_ > 0
			_aF_ + [ :invariant = "refused-accesses", :severity = :warn,
				:where = "" + @oStore.Name(),
				:message = "the central store logged " + _nR_ + " refused reveal(s) -- " +
				"an actor tried to read a secret it may not; review the access log" ]
		ok
		return _aF_


func _StzPostureVerdict(pbSound)
	if pbSound
		return "SOUND"
	ok
	return "UNSOUND (errors present)"
