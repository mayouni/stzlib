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
#   sandbox-in-production (ERROR) and its siblings -- surfaced from the project's
#       stzServiceRegistry (SetServices), so the ONE security gate also covers the
#       external-dependency surface: no fake payment gateway, no fake mail sink and
#       no in-memory store may ship. The registry OWNS that logic; this class does
#       not re-implement it (two copies of a rule is how they drift apart).

  #=============#
 #  FUNCTIONS  #
#=============#

func StzSecurityPostureQ(pcName)
	return new stzSecurityPosture(pcName)

func StzSecurityInvariantNames()
	return [ "no-sandboxed-effectful", "inline-key", "no-central-store", "refused-accesses",
	         "sandbox-in-production", "ephemeral-in-production", "live-without-secret",
	         "unbound-service", "inline-credential", "conformance-in-production",
	         "live-without-certificate", "ungoverned-payouts-in-production" ]

# CI-style top-level entry points (parity with StzCheckAgentGraph):
func StzCheckSecurityPosture(poPosture)
	return poPosture.Findings()

func StzSecurityPostureIsSound(poPosture)
	return poPosture.IsSound()


  #=====================#
 #  STZSECURITYPOSTURE  #
#=====================#

# Runs the security invariants over a project's surface, its secret store, its sites, its actors and its services, and reports findings.
#
# It turns the principle that expression is free and admission is governed into a check. The
# invariants are no-sandboxed-effectful (an error: a sandboxed actor that holds the effectful
# capability), inline-key, no-central-store and refused-accesses (warnings), and the findings of an
# attached service registry. Findings are [ :invariant, :severity, :where, :message ] with the
# severity written error or warn. IsSound means no error; IsClean means nothing flagged at all. The
# posture keeps a copy of everything handed to it, so describe the surface completely first and ask
# last.
#
#   receiver   o1 = new stzSecurityPosture("restolean")
#   example    o1.AddActor(LLMActor("planner"))
#              ? o1.IsSound()
#              #--> 1
#   see        stzSecretStore, stzServiceRegistry, stzSystemActor
class stzSecurityPosture from stzObject

	@cName = ""
	@oStore = ""     # the project's central stzSecretStore (or NULL)
	@aSites = []       # deployment sites to audit
	@aActors = []      # actors to audit
	@oReg = ""       # the project's stzServiceRegistry (or NULL)

	# Builds an empty posture audit of a project's security surface, with no store, no sites, no actors and no service registry.
	#
	#   pcName     the project's name, shown in the report and in findings
	#   returns    nothing; the object is built
	#   see        SetStore, AddSite, AddActor
	def init(pcName)
		@cName = "" + pcName

	# Sets the project's central secret store, so the audit can see its refused reveals and tell a store-backed site from an inline key.
	#
	#   poStore    the stzSecretStore of the project
	#   returns    the posture itself, so calls chain
	#   note       without a store, secret-bearing sites raise the no-central-store warning
	#   warning    the posture keeps a COPY of the store: reveals refused after this call are not
	#              seen, so set the store last, just before asking
	#   see        AddSite, Findings
	#@ aka  -- describe the surface --------------------------------------------
	def SetStore(poStore)
		@oStore = poStore
		return This

	# Adds a deployment site to audit for a secret it holds inline instead of through the store.
	#
	#   poSite     the stzDeploymentSite to audit
	#   returns    the posture itself, so calls chain
	#   note       an inline secret raises the inline-key warning
	#   warning    the posture keeps a COPY of the site
	#   see        AddActor, SetStore
	def AddSite(poSite)
		@aSites + poSite
		return This

	# Adds an actor to audit for the load-bearing rule that a sandboxed actor must never hold the effectful capability.
	#
	#   poActor    the actor to audit, such as HumanActor or LLMActor
	#   returns    the posture itself, so calls chain
	#   note       a sandboxed actor that holds effectful is an ERROR finding
	#   warning    the posture keeps a COPY of the actor: a posture or capability changed after this
	#              call is not seen
	#   see        AddSite, Findings
	def AddActor(poActor)
		@aActors + poActor
		return This

	# Attaches the project's service registry, so findings about fakes and unbound services join the same audit.
	#
	#   poReg      the stzServiceRegistry of the project
	#   returns    the posture itself, so calls chain
	#   note       the audit asks the registry in the production frame and restores its phase, so a
	#              sandbox still bound is reported while there is time to act
	#   see        ServicesQ, HasServices, Findings
	#@ aka  Attach the external-dependency surface. Its findings already carry this class's exact shape, so they join the report verbatim -- see _CheckServiceBindings.
	def SetServices(poReg)
		@oReg = poReg
		return This

	# Returns the attached service registry.
	#
	#   returns    the stzServiceRegistry, or an empty text when none was attached
	#   see        SetServices, HasServices
	def ServicesQ()
		return @oReg

	# TRUE if a service registry was attached with SetServices.
	#
	#   returns    TRUE or FALSE
	#   see        SetServices, ServicesQ
	def HasServices()
		return isObject(@oReg)

	# Runs every invariant over the described surface and returns the findings as one flat list.
	#
	#   returns    a list of [ :invariant, :severity, :where, :message ] findings; [ ] when nothing
	#              is flagged
	#   note       the severity is the symbol error or warn, not the word warning that stzDetection
	#              uses; the findings are recomputed at each call
	#   see        IsSound, NumberOf, Report, StzSecurityInvariantNames
	#@ aka  -- run the invariants ----------------------------------------------
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
		_a1_ = This._CheckServiceBindings()
		_n_ = len(_a1_)
		for _i_ = 1 to _n_
			_aF_ + _a1_[_i_]
		next
		return _aF_

	# TRUE if no finding is an error; warnings are advisory and do not block.
	#
	#   returns    TRUE or FALSE
	#   see        IsClean, NumberOf, Findings
	#@ aka  sound = no ERROR findings (warnings are advisory, not blocking).
	def IsSound()
		return This.NumberOf(:error) = 0

	# TRUE if nothing at all is flagged, neither an error nor a warning.
	#
	#   returns    TRUE or FALSE
	#   see        IsSound, NumberOfFindings
	#@ aka  clean = nothing flagged at all.
	def IsClean()
		return len(This.Findings()) = 0

	# Returns how many findings the audit raises, errors and warnings together.
	#
	#   returns    a number
	#   see        Findings, NumberOf
	def NumberOfFindings()
		return len(This.Findings())

	# Returns how many findings have one severity.
	#
	#   pcSeverity   error or warn, as the findings spell it
	#   returns      a number
	#   note         NumberOf(:error) and NumberOf(:warn) are the two that count
	#   warning      warning does not match: the findings say warn, so NumberOf with the word
	#                warning answers 0, and the match is case-sensitive
	#   see          Findings, NumberOfFindings
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

	# Prints a verdict line for the project, then one line per finding with its severity, invariant, place and message.
	#
	#   returns    nothing; it prints
	#   note       the verdict reads SOUND or UNSOUND (errors present)
	#   see        Findings, IsSound
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

	# THE EXTERNAL SURFACE (service-virtualization phase 7). A project that ships a
	# fake payment gateway or an in-memory database has a SECURITY problem, not
	# merely an incomplete one -- so the same gate that refuses a sandboxed actor
	# holding 'effectful' refuses a sandbox bound in production.
	#
	# DELEGATED, NOT RE-IMPLEMENTED. stzServiceRegistry owns these invariants and
	# already emits [ :invariant, :severity, :where, :message ] -- this class's
	# exact shape -- so they pass straight through under their own names. Two
	# copies of one rule is how the copies drift apart.
	#
	# The registry reports sandbox-in-production only when its phase IS production,
	# which is correct for it and wrong here: a posture audit should say so while
	# there is still time to act. So the check asks in the production frame and puts
	# the phase back -- the same rehearse-then-restore move stzDelivery uses.
	def _CheckServiceBindings()
		_aF_ = []
		if NOT This.HasServices()
			return _aF_
		ok
		_cWas_ = "" + @oReg.Phase()
		@oReg.SetPhaseQ(:production)
		_aR_ = @oReg.FindingsVia(@oStore)
		@oReg.SetPhaseQ(_cWas_)
		_n_ = len(_aR_)
		for _i_ = 1 to _n_
			_aF_ + _aR_[_i_]
		next
		return _aF_


func _StzPostureVerdict(pbSound)
	if pbSound
		return "SOUND"
	ok
	return "UNSOUND (errors present)"
