#================================================================#
#  STZSERVICEREGISTRY -- one place for every external dependency   #
#================================================================#

/*--- The spine of the service-virtualization plane.

A registry is to SERVICES what stzSecretStore is to secrets: the single place a
solution declares "I depend on payments, mail, an LLM and blob storage", binds
each to a fee-free SANDBOX while programming and to a LIVE adapter at deploy, and
makes that whole external surface enumerable and governable.

    oReg = new stzServiceRegistry("restolean")
    oReg.Declare(:payments)                     # the dependency SURFACE, up front
    oReg.Declare(:mail)

    oReg.Bind(:mail, new stzMailSandbox())      # captures, never sends
    oMail = oReg.Service(:mail)                 # the app asks by NAME
    oMail.Send("a@b.c", "hi", "body")           # free, offline, assertable

    # at deploy the SAME registry binds live adapters, credentials from the store:
    oReg.BindLive(:mail, oSmtpAdapter, "smtp-key")
    oReg.SetPhase(:production)

THE WHOLE TRICK IS THE INDIRECTION. Application code never names an
implementation, only a service; the PHASE decides what comes back. So the code is
byte-identical in emulation and in production -- which is the only way "we tested
against the sandbox" means anything.

WHY A REGISTRY RATHER THAN JUST PASSING OBJECTS AROUND: because a dependency you
cannot ENUMERATE is a dependency you cannot GOVERN. Once the external surface is
declared in one place, questions that were previously archaeology become queries:
what does this solution touch? is anything still bound to a fake? does every live
service have a credential, and is that credential in the store rather than inline?
Findings()/IsSound() answer those, in the same shape stzSecurityPosture and the
graph rules use -- so they drop into the same CI gate.

THREE POSTURES, because "fake vs real" turned out to be too coarse. Building the
database exemplar (phase 2) made it obvious: a mail sandbox does not send, but a
database sandbox is SQLITE -- a real database in a file you own. The plan calls
that LOCAL-REAL, and shipping it is not a violation; plenty of good systems run
sqlite in production forever.

  :sandbox  a FAKE (mail sink, OIDC double, virtual authenticator). Must NOT ship.
  :local    a genuine local equivalent (sqlite, the filesystem, a local model).
            MAY ship -- self-hosting is a choice, not a mistake.
  :live     a hosted/remote service reached with a credential.

An object declares which it is: IsSandbox() -> :sandbox, else IsLocalReal() ->
:local, else :live. No opinion means :live, because defaulting to :sandbox would
excuse the very thing the production check exists to catch.

FIVE INVARIANTS (severities as elsewhere: ERROR blocks, WARN advises):
  * sandbox-in-production  (ERROR) -- a fake bound in a production phase. This is
    the plane's whole reason to exist: "flip it to real before shipping" must be
    ENFORCED, not remembered.
  * unbound-service       (ERROR) -- declared and never bound. An unbound service
    must never silently no-op; asking for one RAISES.
  * live-without-secret   (ERROR) -- a live adapter whose credential is not in the
    secret store, checked against the store you pass.
  * ephemeral-in-production (ERROR) -- a LOCAL source that vanishes on restart
    (sqlite ":memory:"). It is a real database right up to the moment the process
    dies, and it is one character away from the safe spelling -- which is exactly
    why it needs a check rather than a convention.
  * inline-credential     (WARN)  -- a live adapter bound without naming a store
    secret at all, i.e. holding its key some other way.

RING NOTE, and it is a real one: Ring copies an object on `=` AND on insertion
into a list, so a registry hands out a COPY of what was bound. For a stateless
live adapter that is invisible. A STATEFUL sandbox must therefore share its state
across copies -- through a handle table (stzMailSandbox) or an engine handle
(sqlite). That is a requirement OF THE PORT CONTRACT, not a wart of the registry,
and the mail sandbox demonstrates it working through a registry round trip.
*/

# THE REGISTRY'S OWN STATE IS SHARED ACROSS COPIES, for the same reason it demands
# that of every sandbox it holds -- and here it is not a convenience but a
# GOVERNANCE requirement. `=` and attribute-stores COPY in Ring, so a registry
# handed to stzDelivery used to become a snapshot: bind a fake on your own handle
# afterwards and the delivery's copy still looked sound, so the production gate
# would have PASSED an unsound surface. A gate that fails OPEN is worse than no
# gate. With the state in a table keyed by id, every copy IS the registry.
# [ [ id, declared, bound, phase ], ... ]
$aStzServiceRegistries = []
$nStzServiceRegistrySeq = 0

func StzServiceRegistryQ(pcName)
	return new stzServiceRegistry(pcName)

# CI helpers, mirroring StzCheckSecurityPosture / StzSecurityPostureIsSound.
func StzCheckServices(poRegistry)
	return poRegistry.Findings()

func StzServicesAreSound(poRegistry)
	return poRegistry.IsSound()


class stzServiceRegistry from stzObject

	@cName = ""
	@nId = 0     # the slot in $aStzServiceRegistries -- survives Ring's copy

	def init(pcName)
		@cName = ring_trim("" + pcName)
		if @cName = ""
			StzRaise("stzServiceRegistry: a name is required (it is what the findings point at).")
		ok
		$nStzServiceRegistrySeq = $nStzServiceRegistrySeq + 1
		@nId = $nStzServiceRegistrySeq
		# [ id, declared, bound, phase ]
		$aStzServiceRegistries + [ @nId, [], [], :development ]

	def Name()
		return @cName

	  #-- the dependency surface -------------------------------------------

	# Declare a service this solution depends on, before anything is bound. This
	# is what turns "what does this touch?" from archaeology into a query -- and it
	# is what lets an UNBOUND dependency be a finding rather than a surprise.
	def Declare(pcService)
		This.DeclareQ(pcService)

	def DeclareQ(pcService)
		_s_ = This._Key(pcService)
		if NOT This.IsDeclared(_s_)
			$aStzServiceRegistries[This._Slot()][2] + _s_
		ok
		return This

	def DeclareMany(paServices)
		_n_ = len(paServices)
		for _i_ = 1 to _n_
			This.DeclareQ(paServices[_i_])
		next
		return This

	def IsDeclared(pcService)
		return This._IndexIn($aStzServiceRegistries[This._Slot()][2], This._Key(pcService)) > 0

	def DeclaredServices()
		return $aStzServiceRegistries[This._Slot()][2]

	def NumberOfDeclared()
		return len($aStzServiceRegistries[This._Slot()][2])

	  #-- binding ----------------------------------------------------------

	# Bind an implementation. The posture is asked OF THE OBJECT: anything with
	# IsSandbox() answering true is a sandbox. Declaring itself beats guessing from
	# a class name, and it means a third-party double can opt in.
	def Bind(pcService, poImpl)
		This.BindQ(pcService, poImpl)

	def BindQ(pcService, poImpl)
		return This._BindWith(pcService, poImpl, This._PostureOf(poImpl), "")

	# ...say it explicitly when the object cannot.
	def BindSandbox(pcService, poImpl)
		This.BindSandboxQ(pcService, poImpl)

	def BindSandboxQ(pcService, poImpl)
		return This._BindWith(pcService, poImpl, :sandbox, "")

	# Bind a genuine LOCAL equivalent -- sqlite, the filesystem, a local model. Not
	# a fake, so unlike a sandbox this may ship; see the posture note above.
	def BindLocal(pcService, poImpl)
		This.BindLocalQ(pcService, poImpl)

	def BindLocalQ(pcService, poImpl)
		return This._BindWith(pcService, poImpl, :local, "")

	# Bind the real thing, naming the STORE SECRET its credential lives in. The
	# name, not the key: a registry that held credentials would be one more place
	# they leak from.
	def BindLive(pcService, poImpl, pcSecretName)
		This.BindLiveQ(pcService, poImpl, pcSecretName)

	def BindLiveQ(pcService, poImpl, pcSecretName)
		return This._BindWith(pcService, poImpl, :live, "" + pcSecretName)

	# Remove the IMPLEMENTATION but keep the dependency. The service is then
	# declared-and-unbound, which IS a finding -- your solution still needs the
	# thing, it just has nothing to serve it. To retire the dependency itself, use
	# Undeclare.
	def Unbind(pcService)
		_s_ = This._Key(pcService)
		_aNew_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][3][_i_][1] != _s_
				_aNew_ + $aStzServiceRegistries[This._Slot()][3][_i_]
			ok
		next
		$aStzServiceRegistries[This._Slot()][3] = _aNew_
		return This

	# Retire the dependency altogether -- the solution no longer needs this
	# service. Unbinds it too, so nothing is left half-declared.
	def Undeclare(pcService)
		_s_ = This._Key(pcService)
		This.Unbind(_s_)
		_aNew_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][2])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][2][_i_] != _s_
				_aNew_ + $aStzServiceRegistries[This._Slot()][2][_i_]
			ok
		next
		$aStzServiceRegistries[This._Slot()][2] = _aNew_
		return This

	  #-- resolution (what the application actually calls) ------------------

	# The service by name. RAISES when nothing is bound -- an unbound dependency
	# that silently returned NULL would fail later, somewhere else, as a null-call
	# with no hint of the real cause.
	def Service(pcService)
		_i_ = This._BoundIndex(pcService)
		if _i_ = 0
			StzRaise("stzServiceRegistry(" + @cName + "): nothing is bound for service '" +
			         This._Key(pcService) + "'. Bind it (or BindLive it) before use.")
		ok
		return $aStzServiceRegistries[This._Slot()][3][_i_][2]

	def Has(pcService)
		return This._BoundIndex(pcService) > 0

	def BoundServices()
		_out_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			_out_ + $aStzServiceRegistries[This._Slot()][3][_i_][1]
		next
		return _out_

	def NumberOfBound()
		return len($aStzServiceRegistries[This._Slot()][3])

	def PostureOf(pcService)
		_i_ = This._BoundIndex(pcService)
		if _i_ = 0
			return ""
		ok
		return $aStzServiceRegistries[This._Slot()][3][_i_][3]

	def IsSandboxed(pcService)
		return This.PostureOf(pcService) = :sandbox

	def SecretNameOf(pcService)
		_i_ = This._BoundIndex(pcService)
		if _i_ = 0
			return ""
		ok
		return $aStzServiceRegistries[This._Slot()][3][_i_][4]

	# every service still bound to a fake -- the "what is not real yet" list.
	def SandboxedServices()
		_out_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][3][_i_][3] = :sandbox
				_out_ + $aStzServiceRegistries[This._Slot()][3][_i_][1]
			ok
		next
		return _out_

	# the genuinely-local ones: real, self-hosted, shippable.
	def LocalServices()
		_out_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][3][_i_][3] = :local
				_out_ + $aStzServiceRegistries[This._Slot()][3][_i_][1]
			ok
		next
		return _out_

	def IsLocal(pcService)
		return This.PostureOf(pcService) = :local

	def LiveServices()
		_out_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][3][_i_][3] = :live
				_out_ + $aStzServiceRegistries[This._Slot()][3][_i_][1]
			ok
		next
		return _out_

	def UnboundServices()
		_out_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][2])
		for _i_ = 1 to _n_
			if NOT This.Has($aStzServiceRegistries[This._Slot()][2][_i_])
				_out_ + $aStzServiceRegistries[This._Slot()][2][_i_]
			ok
		next
		return _out_

	  #-- the phase --------------------------------------------------------

	# :development / :emulated -> sandboxes are expected. :production -> they are a
	# violation. The phase is the SAME switch stzDelivery already uses, so nothing
	# new decides what is real.
	def SetPhase(pcPhase)
		This.SetPhaseQ(pcPhase)

	def SetPhaseQ(pcPhase)
		_p_ = This._Key(pcPhase)
		if _p_ != "development" and _p_ != "emulated" and _p_ != "production"
			StzRaise("stzServiceRegistry.SetPhase: expected :development, :emulated or :production.")
		ok
		$aStzServiceRegistries[This._Slot()][4] = _p_
		return This

	def Phase()
		return $aStzServiceRegistries[This._Slot()][4]

	def IsProduction()
		return $aStzServiceRegistries[This._Slot()][4] = "production"

	  #-- governance -------------------------------------------------------

	# [ [ :invariant, :severity, :where, :message ], ... ] -- the same shape
	# stzSecurityPosture and the graph rules use, so one CI gate covers all three.
	# poStore may be NULL when there is no keyring to check against.
	# NOTE: each _Check returns its OWN list and this LOOPS to append the elements.
	# Ring's `+` on a list appends the whole list as ONE element, so
	# `_aF_ + This._Check...()` would nest rather than accumulate -- and a nested
	# findings list silently reports zero errors. Same shape as stzSecurityPosture.
	def FindingsVia(poStore)
		_aF_ = []
		_a1_ = This._CheckUnbound()
		_n_ = len(_a1_)
		for _i_ = 1 to _n_
			_aF_ + _a1_[_i_]
		next
		_a1_ = This._CheckSandboxInProduction()
		_n_ = len(_a1_)
		for _i_ = 1 to _n_
			_aF_ + _a1_[_i_]
		next
		_a1_ = This._CheckEphemeralInProduction()
		_n_ = len(_a1_)
		for _i_ = 1 to _n_
			_aF_ + _a1_[_i_]
		next
		_a1_ = This._CheckLiveCredentials(poStore)
		_n_ = len(_a1_)
		for _i_ = 1 to _n_
			_aF_ + _a1_[_i_]
		next
		return _aF_

	def Findings()
		return This.FindingsVia("")

	def IsSoundVia(poStore)
		_aF_ = This.FindingsVia(poStore)
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			if _aF_[_i_][:severity] = :error
				return 0
			ok
		next
		return 1

	def IsSound()
		return This.IsSoundVia("")

	def NumberOfFindings()
		return len(This.Findings())

	def ReportVia(poStore)
		_aF_ = This.FindingsVia(poStore)
		? "Service registry '" + @cName + "' [" + $aStzServiceRegistries[This._Slot()][4] + "] -- " +
		  len($aStzServiceRegistries[This._Slot()][3]) + " bound: " + len(This.SandboxedServices()) + " sandboxed, " +
		  len(This.LocalServices()) + " local, " + len(This.LiveServices()) + " live"
		if len(_aF_) = 0
			? "  (no findings)"
			return This
		ok
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			? "  [" + upper("" + _aF_[_i_][:severity]) + "] " + _aF_[_i_][:invariant] +
			  " @ " + _aF_[_i_][:where] + " -- " + _aF_[_i_][:message]
		next
		return This

	def Report()
		return This.ReportVia("")

	# The production gate, mirroring the library's other admission checkpoints:
	# nothing may go live unless the surface is sound AND an EFFECTFUL,
	# non-sandboxed actor commits it. Expression is free; admission is governed.
	#
	# ASKED IN THE PRODUCTION FRAME, whatever the current phase. "May I go LIVE?"
	# IS the production question, so answering it from a :development phase would
	# have said YES with a fake still bound -- the phase-dependent invariants
	# (sandbox-in-production, ephemeral-in-production) simply had not fired yet.
	# The phase is set, the surface judged, the phase restored: asking is not
	# declaring. (Found while writing the narration; the guard had only ever asked
	# after setting production, so the honest answer and the convenient one agreed.)
	def MayGoLive(poActor, poStore)
		if NOT isObject(poActor)
			return 0
		ok
		if NOT poActor.IsEffectful()
			return 0
		ok
		if poActor.Posture() = "sandboxed"
			return 0
		ok
		return This._SoundForProductionVia(poStore)

	# the surface judged as production would judge it, then put back
	def FindingsForProductionVia(poStore)
		_cWas_ = "" + This.Phase()
		This.SetPhaseQ(:production)
		_aF_ = This.FindingsVia(poStore)
		This.SetPhaseQ(_cWas_)
		return _aF_

	def FindingsForProduction()
		return This.FindingsForProductionVia("")

	def _SoundForProductionVia(poStore)
		_aF_ = This.FindingsForProductionVia(poStore)
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			if _aF_[_i_][:severity] = :error
				return 0
			ok
		next
		return 1

	# ...and the same, but explaining itself.
	def WhyNotLive(poActor, poStore)
		if NOT isObject(poActor)
			return "no actor was offered to commit the change"
		ok
		if NOT poActor.IsEffectful()
			return "actor '" + poActor.Name() + "' is not effectful -- it may propose, not commit"
		ok
		if poActor.Posture() = "sandboxed"
			return "actor '" + poActor.Name() + "' is sandboxed"
		ok
		_aF_ = This.FindingsForProductionVia(poStore)
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			if _aF_[_i_][:severity] = :error
				return _aF_[_i_][:invariant] + ": " + _aF_[_i_][:message]
			ok
		next
		return ""

	  #-- the graph projection (phase 7) -----------------------------------

	# Project the dependency surface into an stzGraph the rule engine can run
	# over -- the same move stzOrgChart.AsRuleGraph() makes for positions.
	#
	# The application is a node; every declared service is a node with its
	# posture, its secret name and the phase as properties; an application
	# `depends-on` each of its services.
	#
	# NOTE this does NOT duplicate the invariants above. Findings from Findings()
	# already carry the report's shape, so the registry joins the shared CI gate
	# directly:  oReport.IngestLegacy(oReg.Findings(), "services").
	# What the GRAPH adds is the question a flag check cannot ask -- which PART of
	# a solution depends on a fake -- and that needs the delivery's parts joined
	# to these nodes (see stzDelivery.AsRuleGraph and stzServiceRuleSet).
	def AsRuleGraph()
		_oG_ = new stzGraph("services-rules")
		_app_ = "app:" + @cName
		_oG_.AddNode(_app_)
		_oG_.SetNodeProperty(_app_, "kind", "application")
		_oG_.SetNodeProperty(_app_, "phase", "" + $aStzServiceRegistries[This._Slot()][4])

		_n_ = len($aStzServiceRegistries[This._Slot()][2])
		for _i_ = 1 to _n_
			This._AddServiceNode(_oG_, "" + $aStzServiceRegistries[This._Slot()][2][_i_], _app_)
		next
		# a service may be bound without having been declared
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			This._AddServiceNode(_oG_, "" + $aStzServiceRegistries[This._Slot()][3][_i_][1], _app_)
		next
		return _oG_

	def _AddServiceNode(poG, pcName, pcApp)
		_id_ = "service:" + pcName
		if poG.NodeExists(_id_)
			return
		ok
		poG.AddNode(_id_)
		poG.SetNodeProperty(_id_, "kind", "service")
		poG.SetNodeProperty(_id_, "service", pcName)
		poG.SetNodeProperty(_id_, "phase", "" + $aStzServiceRegistries[This._Slot()][4])
		poG.SetNodeProperty(_id_, "posture", "" + This.PostureOf(pcName))
		poG.SetNodeProperty(_id_, "bound", This.Has(pcName))
		poG.SetNodeProperty(_id_, "secret", "" + This.SecretNameOf(pcName))
		# ephemeral is asked of the OBJECT, as everywhere else in this file
		_bEph_ = 0
		if This.Has(pcName)
			try
				if This.Service(pcName).IsEphemeral()
					_bEph_ = 1
				ok
			catch
			done
		ok
		poG.SetNodeProperty(_id_, "ephemeral", _bEph_)
		if NOT poG.EdgeExists(pcApp, _id_)
			poG.AddEdgeXTT(pcApp, _id_, "depends-on", [ :type = "service" ])
		ok

	def Show()
		? "stzServiceRegistry(" + @cName + ", " + $aStzServiceRegistries[This._Slot()][4] + ", " +
		  len($aStzServiceRegistries[This._Slot()][3]) + "/" + len($aStzServiceRegistries[This._Slot()][2]) + " bound)"

	  #==== internals ======================================================

	def _Slot()
		_n_ = len($aStzServiceRegistries)
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[_i_][1] = @nId
				return _i_
			ok
		next
		$aStzServiceRegistries + [ @nId, [], [], :development ]
		return len($aStzServiceRegistries)

	def _CheckUnbound()
		_aF_ = []
		_a_ = This.UnboundServices()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_aF_ + [ :invariant = "unbound-service", :severity = :error,
			         :where = @cName + "/" + _a_[_i_],
			         :message = "declared but never bound -- asking for it will raise" ]
		next
		return _aF_

	def _CheckSandboxInProduction()
		_aF_ = []
		if NOT This.IsProduction()
			return _aF_
		ok
		_a_ = This.SandboxedServices()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_aF_ + [ :invariant = "sandbox-in-production", :severity = :error,
			         :where = @cName + "/" + _a_[_i_],
			         :message = "still bound to a SANDBOX in a production phase -- " +
			                    "a fake must never ship" ]
		next
		return _aF_

	# A local source that does not survive a restart. Asked of the object, so any
	# local-real implementation can opt into the check.
	def _CheckEphemeralInProduction()
		_aF_ = []
		if NOT This.IsProduction()
			return _aF_
		ok
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][3][_i_][3] != :local
				loop
			ok
			_bGone_ = 0
			try
				if $aStzServiceRegistries[This._Slot()][3][_i_][2].IsEphemeral()
					_bGone_ = 1
				ok
			catch
				# no opinion -> assume it persists
			done
			if _bGone_
				_aF_ + [ :invariant = "ephemeral-in-production", :severity = :error,
				         :where = @cName + "/" + $aStzServiceRegistries[This._Slot()][3][_i_][1],
				         :message = "a LOCAL source that vanishes on restart (in-memory) " +
				                    "is bound in a production phase" ]
			ok
		next
		return _aF_

	def _CheckLiveCredentials(poStore)
		_aF_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][3][_i_][3] != :live
				loop
			ok
			_svc_ = $aStzServiceRegistries[This._Slot()][3][_i_][1]
			_sec_ = $aStzServiceRegistries[This._Slot()][3][_i_][4]
			if _sec_ = ""
				_aF_ + [ :invariant = "inline-credential", :severity = :warn,
				         :where = @cName + "/" + _svc_,
				         :message = "live adapter bound without naming a store secret" ]
				loop
			ok
			if isObject(poStore)
				if NOT poStore.Has(_sec_)
					_aF_ + [ :invariant = "live-without-secret", :severity = :error,
					         :where = @cName + "/" + _svc_,
					         :message = "credential '" + _sec_ + "' is not in the secret store" ]
				ok
			ok
		next
		return _aF_

	def _BindWith(pcService, poImpl, pcPosture, pcSecret)
		if NOT isObject(poImpl)
			StzRaise("stzServiceRegistry.Bind: an implementation object is required for '" +
			         This._Key(pcService) + "'.")
		ok
		_s_ = This._Key(pcService)
		This.DeclareQ(_s_)              # binding implies the dependency
		_i_ = This._BoundIndex(_s_)
		_rec_ = [ _s_, poImpl, pcPosture, "" + pcSecret ]
		if _i_ > 0
			$aStzServiceRegistries[This._Slot()][3][_i_] = _rec_        # re-binding replaces: dev -> live at deploy
		else
			$aStzServiceRegistries[This._Slot()][3] + _rec_
		ok
		return This

	# Ask the object what it is. A double that declares itself cannot be mistaken
	# for the real thing by a class-name heuristic, and vice versa.
	def _PostureOf(poImpl)
		try
			if poImpl.IsSandbox()
				return :sandbox
			ok
		catch
			# says nothing about being a fake -- fall through
		done
		try
			if poImpl.IsLocalReal()
				return :local
			ok
		catch
			# says nothing about being local either
		done
		# no opinion -> LIVE, because guessing "sandbox" would silently excuse the
		# very thing the production check exists to catch
		return :live

	def _BoundIndex(pcService)
		_s_ = This._Key(pcService)
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][3][_i_][1] = _s_
				return _i_
			ok
		next
		return 0

	def _IndexIn(paList, pcKey)
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if paList[_i_] = pcKey
				return _i_
			ok
		next
		return 0

	# service names arrive as :symbols or strings; one spelling wins
	def _Key(pService)
		return StzLower(ring_trim("" + pService))
