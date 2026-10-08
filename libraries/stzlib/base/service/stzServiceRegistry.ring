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

FOUR POSTURES, because "fake vs real" turned out to be too coarse. Building the
database exemplar (phase 2) made it obvious: a mail sandbox does not send, but a
database sandbox is SQLITE -- a real database in a file you own. The plan calls
that LOCAL-REAL, and shipping it is not a violation; plenty of good systems run
sqlite in production forever.

  :sandbox  a FAKE (mail sink, OIDC double, virtual authenticator). Must NOT ship.
  :local    a genuine local equivalent (sqlite, the filesystem, a local model).
            MAY ship -- self-hosting is a choice, not a mistake.
  :live     a hosted/remote service reached with a credential.
  :conformance  the GENUINE protocol of a hosted service over VIRTUAL money: the BCEAO's
            sandbox for payments. Neither a fake (it speaks the real hub's protocol, with
            real OAuth credentials) nor shippable (nothing in it is real). A conformance
            run is what a platform does BEFORE going live, so it is expected in
            development and must never be bound when the platform ships.

An object declares which it is: IsSandbox() -> :sandbox, else IsLocalReal() ->
:local, else :live. No opinion means :live, because defaulting to :sandbox would
excuse the very thing the production check exists to catch.

EIGHT INVARIANTS (severities as elsewhere: ERROR blocks, WARN advises):
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
  * conformance-in-production (ERROR) -- virtual money bound in a production phase, the
    same mistake as a fake in production and caught by the same gate.
  * ungoverned-payouts-in-production (ERROR) -- a payments port that was told to skip the plan
    (AllowUngovernedPayouts()) bound in a production phase. A port is governed by default and
    turning that off is what a test of the twin does; shipping it is the mistake.
  * live-without-certificate (ERROR) -- a live adapter that needs an mTLS client
    certificate (it says so: RequiresCertificate() and CertificateSecretName(), or the
    binding names it) whose certificate is not in the store, has no value, or has
    lapsed. Refused at IsSound(), BEFORE the first call, in any phase, exactly where
    live-without-secret refuses a missing API key.

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


# Holds the services a solution depends on and what serves each, so that a fake can be refused when the solution ships.
#
# Application code asks the registry for a service by name, never for an implementation, and the
# phase decides what is in place: a sandbox that captures mail or a local database while
# programming, a hosted adapter at deploy. Because the whole outside surface is declared in one
# place it can be listed and judged: Findings names what is unbound, what is still a fake in a
# production phase, what is a local source that vanishes on restart, and what is live without its
# credential in the secret store, and IsSound says whether any of that is an error. Each binding
# carries a posture read off the object itself (sandbox, local, live or conformance), and an object
# that says nothing is taken as live so that production does not excuse it. The registry holds the
# NAME of a credential, never the credential. The payments binding comes second. The library ships
# one live adapter for a payment hub, stzPispiHttpAdapter, and it is UNPERCEIVED: it is proven
# against the twin served over real HTTP, plain and with mutual TLS, and has NOT been run against
# the BCEAO's sandbox. No payment made through it has been watched landing in a real dashboard, so a
# registry that judges it sound has judged the declared surface and not the service. BindLive,
# BindConformance and BindLiveWithCertificate carry the same status in their notes. The twin and the
# BCEAO's sandbox are refused in production (sandbox-in-production, conformance-in-production), and
# so is a payments port told to skip the payout plan. The payments guide, docs/payments-guide.md, is
# the desk's own account.
#
#   receiver   o1 = new stzServiceRegistry("restolean")
#   example    o1.Declare(:mail)
#              o1.Bind(:mail, new stzMailSandbox())
#              ? o1.PostureOf(:mail)
#              #--> sandbox
#              ? o1.SetPhaseQ(:production).IsSound()
#              #--> 0
#   see        stzSecretStore, stzMailSandbox, stzPispiHttpAdapter, stzPiSpiSandbox
class stzServiceRegistry from stzObject

	@cName = ""
	@nId = 0     # the slot in $aStzServiceRegistries -- survives Ring's copy

	# Builds an empty registry for one solution, whose name every finding and report line points at.
	#
	#   pcName     the solution's name, a text that is not blank because a blank name raises an
	#              error
	#   returns    nothing; the object is built
	#   see        Declare, Bind
	def init(pcName)
		@cName = ring_trim("" + pcName)
		if @cName = ""
			StzRaise("stzServiceRegistry: a name is required (it is what the findings point at).")
		ok
		$nStzServiceRegistrySeq = $nStzServiceRegistrySeq + 1
		@nId = $nStzServiceRegistrySeq
		# [ id, declared, bound, phase ]
		$aStzServiceRegistries + [ @nId, [], [], :development ]

	# Returns the name the registry was built with.
	#
	#   returns    a text
	#   see        init
	def Name()
		return @cName

	# Records a service the solution depends on before anything serves it, so that an unserved one is a finding and not a surprise.
	#
	#   pcService   the service's name, as a symbol or a text, kept in lower case with surrounding
	#               spaces removed
	#   returns     nothing; use DeclareQ to chain
	#   note        DeclareQ is the same call and returns the registry, and DeclareMany takes a list
	#               of names
	#   warning     declaring a name twice keeps one entry
	#   see         DeclareQ, Bind, UnboundServices
	#@ aka  -- the dependency surface -------------------------------------------
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

	# TRUE if the service is on the dependency list, whether or not anything serves it.
	#
	#   pcService   the service's name, matched without regard to case
	#   returns     TRUE or FALSE
	#   warning     binding a service declares it, so a bound service is always declared
	#   see         Declare, Has
	def IsDeclared(pcService)
		return This._IndexIn($aStzServiceRegistries[This._Slot()][2], This._Key(pcService)) > 0

	# Returns the dependency list, in the order the services were first named.
	#
	#   returns    a list of lower-case texts; [ ] when nothing is declared
	#   see        NumberOfDeclared, BoundServices
	def DeclaredServices()
		return $aStzServiceRegistries[This._Slot()][2]

	# Returns how many services the solution depends on, served or not.
	#
	#   returns    a number
	#   see        DeclaredServices, NumberOfBound
	def NumberOfDeclared()
		return len($aStzServiceRegistries[This._Slot()][2])

	# Attaches an implementation to a service, taking its posture from what the object says it is.
	#
	#   pcService   the service's name, declared by this call if it is new
	#   poImpl      the object that serves it
	#   returns     nothing; use BindQ to chain
	#   note        the object is asked IsSandbox() first, then IsConformance(), then IsLocalReal();
	#               BindQ is the same call and returns the registry
	#   warning     raises an error when poImpl is not an object; an object that says nothing about
	#               itself is recorded as live, never as a sandbox, so that production does not
	#               excuse it; binding a name again replaces the earlier binding in place
	#   see         BindSandbox, BindLocal, BindLive, PostureOf
	#@ aka  -- binding ----------------------------------------------------------
	def Bind(pcService, poImpl)
		This.BindQ(pcService, poImpl)

	def BindQ(pcService, poImpl)
		return This._BindWith(pcService, poImpl, This._PostureOf(poImpl), "", "")

	# Attaches an implementation as a fake that must never ship, whatever the object says about itself.
	#
	#   pcService   the service's name, declared by this call if it is new
	#   poImpl      the fake that serves it
	#   returns     nothing; use BindSandboxQ to chain
	#   note        a double that declares itself with IsSandbox() needs only Bind
	#   warning     in a production phase this binding is an error finding named sandbox-in-
	#               production
	#   see         Bind, SandboxedServices, FindingsForProduction
	#@ aka  ...say it explicitly when the object cannot.
	def BindSandbox(pcService, poImpl)
		This.BindSandboxQ(pcService, poImpl)

	def BindSandboxQ(pcService, poImpl)
		return This._BindWith(pcService, poImpl, :sandbox, "", "")

	# Attaches a genuine local equivalent, such as sqlite, the filesystem or a local model, which may ship.
	#
	#   pcService   the service's name, declared by this call if it is new
	#   poImpl      the local implementation that serves it
	#   returns     nothing; use BindLocalQ to chain
	#   note        a local source is not a fake, so no other finding is raised for it
	#   warning     an implementation that answers IsEphemeral() with true, such as an in-memory
	#               database, is refused in a production phase as ephemeral-in-production
	#   see         Bind, LocalServices, IsLocal
	#@ aka  Bind a genuine LOCAL equivalent -- sqlite, the filesystem, a local model. Not a fake, so unlike a sandbox this may ship; see the posture note above.
	def BindLocal(pcService, poImpl)
		This.BindLocalQ(pcService, poImpl)

	def BindLocalQ(pcService, poImpl)
		return This._BindWith(pcService, poImpl, :local, "", "")

	# Attaches the real hosted service and names the store secret its credential lives in, never the credential itself.
	#
	#   pcService      the service's name, declared by this call if it is new
	#   poImpl         the adapter that talks to the real service
	#   pcSecretName   the name of the credential in the secret store, or an empty text to bind
	#                  without naming one
	#   returns        nothing; use BindLiveQ to chain
	#   note           UNPERCEIVED, for the one live adapter this library ships to a payment hub,
	#                  stzPispiHttpAdapter: it is proven against the twin served over real HTTP and
	#                  has NOT been run against the BCEAO's sandbox, and no payment made through it
	#                  has been watched landing in a real dashboard. This call records a binding and
	#                  runs nothing, and a sound registry says the surface is declared, not that the
	#                  service works. An adapter for any other service is the caller's and carries
	#                  its own status
	#   warning        an empty pcSecretName is a warning named inline-credential, not an error; a
	#                  name the store does not hold is the error live-without-secret, and only when
	#                  a store is passed to FindingsVia or IsSoundVia
	#   see            Bind, BindLiveWithCertificate, BindConformance, IsSoundVia
	#@ aka  Bind the real thing, naming the STORE SECRET its credential lives in. The name, not the key: a registry that held credentials would be one more place they leak from.
	def BindLive(pcService, poImpl, pcSecretName)
		This.BindLiveQ(pcService, poImpl, pcSecretName)

	def BindLiveQ(pcService, poImpl, pcSecretName)
		return This._BindWith(pcService, poImpl, :live, "" + pcSecretName, "")

	# Attaches an adapter of the genuine protocol over virtual money, a trial before going live, naming its credential's store secret.
	#
	#   pcService      the service's name, declared by this call if it is new
	#   poImpl         the adapter that speaks the real protocol to the trial service
	#   pcSecretName   the name of the credential in the secret store
	#   returns        nothing; use BindConformanceQ to chain
	#   note           UNPERCEIVED, for the BCEAO's sandbox: stzPispiHttpAdapter in its conformance
	#                  posture has NOT been run against it, and stays unperceived until a named
	#                  person has watched a payment land in the sandbox dashboard. This call records
	#                  the binding and runs nothing
	#   warning        this binding is expected in development and is an error finding named
	#                  conformance-in-production in a production phase; its credential is checked
	#                  like a live one
	#   see            Bind, BindLive, ConformanceServices, IsConformance
	#@ aka  Bind the genuine protocol over virtual money (see :conformance above), naming the store secret its credential lives in. Never shippable: production refuses it.
	def BindConformance(pcService, poImpl, pcSecretName)
		This.BindConformanceQ(pcService, poImpl, pcSecretName)

	def BindConformanceQ(pcService, poImpl, pcSecretName)
		return This._BindWith(pcService, poImpl, :conformance, "" + pcSecretName, "")

	# Attaches the real hosted service and names both the store secret of its credential and the one holding its mTLS client certificate.
	#
	#   pcService          the service's name, declared by this call if it is new
	#   poImpl             the adapter that talks to the real service
	#   pcSecretName       the name of the credential in the secret store
	#   pcCertSecretName   the name of the client certificate secret in the secret store
	#   returns            nothing; use BindLiveWithCertificateQ to chain
	#   note               UNPERCEIVED, for the live payment adapter: it has been run only against
	#                      the twin served over real HTTP, plain and with mutual TLS, and NOT
	#                      against the BCEAO's sandbox, so no mutual-TLS handshake with a real hub
	#                      has been watched. This call records the names and runs nothing
	#   warning            a certificate absent from the store, without a value, or past its end
	#                      date is the error live-without-certificate, judged only when a store is
	#                      passed and in any phase; an adapter that answers RequiresCertificate()
	#                      needs only BindLive because the registry asks it
	#   see                BindLive, CertificateNameOf, IsSoundVia
	#@ aka  Bind the real thing AND name the store secret that holds its mTLS client certificate, for an adapter that cannot say so itself. An adapter that can (RequiresCertificate()) needs only BindLive.
	def BindLiveWithCertificate(pcService, poImpl, pcSecretName, pcCertSecretName)
		This.BindLiveWithCertificateQ(pcService, poImpl, pcSecretName, pcCertSecretName)

	def BindLiveWithCertificateQ(pcService, poImpl, pcSecretName, pcCertSecretName)
		return This._BindWith(pcService, poImpl, :live, "" + pcSecretName, "" + pcCertSecretName)

	# Removes the implementation of a service and keeps the dependency, which leaves it declared and unserved.
	#
	#   pcService   the service's name
	#   returns     the registry itself, so calls chain
	#   warning     an unserved declared service is the error unbound-service; a name that is not
	#               bound changes nothing
	#   see         Undeclare, Bind, UnboundServices
	#@ aka  Remove the IMPLEMENTATION but keep the dependency. The service is then declared-and-unbound, which IS a finding -- your solution still needs the thing, it just has nothing to serve it. To retire the dependency itself, use Undeclare.
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

	# Retires a dependency for good, unbinding it first so that nothing stays half declared.
	#
	#   pcService   the service's name
	#   returns     the registry itself, so calls chain
	#   see         Unbind, Declare
	#@ aka  Retire the dependency altogether -- the solution no longer needs this service. Unbinds it too, so nothing is left half-declared.
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

	# Returns the implementation bound to a service, the one call the application makes.
	#
	#   pcService   the service's name, matched without regard to case
	#   returns     the object that was bound
	#   note        Ring copies an object when it is stored and when it is read back, so an
	#               implementation that keeps state must share it across copies, as the mail sandbox
	#               does
	#   warning     raises an error naming the service when nothing is bound, instead of returning
	#               an empty value that would fail later
	#   see         Has, Bind, PostureOf
	#@ aka  -- resolution (what the application actually calls) ------------------
	def Service(pcService)
		_i_ = This._BoundIndex(pcService)
		if _i_ = 0
			StzRaise("stzServiceRegistry(" + @cName + "): nothing is bound for service '" +
			         This._Key(pcService) + "'. Bind it (or BindLive it) before use.")
		ok
		return $aStzServiceRegistries[This._Slot()][3][_i_][2]

	# TRUE if an implementation is bound to the service.
	#
	#   pcService   the service's name, matched without regard to case
	#   returns     TRUE or FALSE
	#   see         Service, IsDeclared
	def Has(pcService)
		return This._BoundIndex(pcService) > 0

	# Returns the names of the services that have an implementation, in the order they were first bound.
	#
	#   returns    a list of lower-case texts; [ ] when nothing is bound
	#   warning    binding a name again keeps its place in the list
	#   see        NumberOfBound, DeclaredServices
	def BoundServices()
		_out_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			_out_ + $aStzServiceRegistries[This._Slot()][3][_i_][1]
		next
		return _out_

	# Returns how many services have an implementation.
	#
	#   returns    a number
	#   see        BoundServices, NumberOfDeclared
	def NumberOfBound()
		return len($aStzServiceRegistries[This._Slot()][3])

	# Returns how a service is bound: sandbox, local, live or conformance.
	#
	#   pcService   the service's name
	#   returns     a text, or an empty text when nothing is bound
	#   see         Bind, IsSandboxed, IsLocal, IsConformance
	def PostureOf(pcService)
		_i_ = This._BoundIndex(pcService)
		if _i_ = 0
			return ""
		ok
		return $aStzServiceRegistries[This._Slot()][3][_i_][3]

	# TRUE if the service is bound as a fake.
	#
	#   pcService   the service's name
	#   returns     TRUE or FALSE; FALSE when nothing is bound
	#   see         PostureOf, SandboxedServices
	def IsSandboxed(pcService)
		return This.PostureOf(pcService) = :sandbox

	# Returns the name of the secret store entry given for the service's credential.
	#
	#   pcService   the service's name
	#   returns     a text, or an empty text when nothing is bound or no name was given
	#   see         BindLive, CertificateNameOf
	def SecretNameOf(pcService)
		_i_ = This._BoundIndex(pcService)
		if _i_ = 0
			return ""
		ok
		return $aStzServiceRegistries[This._Slot()][3][_i_][4]

	# Returns the name of the store secret that the binding gave for the service's mTLS client certificate.
	#
	#   pcService   the service's name
	#   returns     a text, or an empty text when the binding named none
	#   warning     an adapter that names its own certificate through CertificateSecretName() is not
	#               reported here, only a name given at binding
	#   see         BindLiveWithCertificate, SecretNameOf
	#@ aka  the store secret holding a service's mTLS certificate, when the BINDING named one
	def CertificateNameOf(pcService)
		_i_ = This._BoundIndex(pcService)
		if _i_ = 0
			return ""
		ok
		return $aStzServiceRegistries[This._Slot()][3][_i_][5]

	# Returns the services bound to the genuine protocol over virtual money.
	#
	#   returns    a list of lower-case texts; [ ] when none
	#   see        IsConformance, BindConformance, LiveServices
	#@ aka  every service bound to the genuine protocol over virtual money
	def ConformanceServices()
		_out_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][3][_i_][3] = :conformance
				_out_ + $aStzServiceRegistries[This._Slot()][3][_i_][1]
			ok
		next
		return _out_

	# TRUE if the service is bound to the genuine protocol over virtual money.
	#
	#   pcService   the service's name
	#   returns     TRUE or FALSE; FALSE when nothing is bound
	#   see         PostureOf, ConformanceServices
	def IsConformance(pcService)
		return This.PostureOf(pcService) = :conformance

	# Returns the services still bound to a fake, the list of what is not real yet.
	#
	#   returns    a list of lower-case texts; [ ] when none
	#   see        IsSandboxed, LocalServices
	#@ aka  every service still bound to a fake -- the "what is not real yet" list.
	def SandboxedServices()
		_out_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][3][_i_][3] = :sandbox
				_out_ + $aStzServiceRegistries[This._Slot()][3][_i_][1]
			ok
		next
		return _out_

	# Returns the services bound to a genuine local equivalent, which may ship.
	#
	#   returns    a list of lower-case texts; [ ] when none
	#   see        IsLocal, SandboxedServices
	#@ aka  the genuinely-local ones: real, self-hosted, shippable.
	def LocalServices()
		_out_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][3][_i_][3] = :local
				_out_ + $aStzServiceRegistries[This._Slot()][3][_i_][1]
			ok
		next
		return _out_

	# TRUE if the service is bound to a genuine local equivalent.
	#
	#   pcService   the service's name
	#   returns     TRUE or FALSE; FALSE when nothing is bound
	#   see         PostureOf, LocalServices
	def IsLocal(pcService)
		return This.PostureOf(pcService) = :local

	# Returns the services bound to the real hosted thing.
	#
	#   returns    a list of lower-case texts; [ ] when none
	#   see        BindLive, ConformanceServices
	def LiveServices()
		_out_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][3][_i_][3] = :live
				_out_ + $aStzServiceRegistries[This._Slot()][3][_i_][1]
			ok
		next
		return _out_

	# Returns the declared services that nothing serves, each of which is an error finding.
	#
	#   returns    a list of lower-case texts; [ ] when every declared service is bound
	#   see        Declare, Unbind, Findings
	def UnboundServices()
		_out_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][2])
		for _i_ = 1 to _n_
			if NOT This.Has($aStzServiceRegistries[This._Slot()][2][_i_])
				_out_ + $aStzServiceRegistries[This._Slot()][2][_i_]
			ok
		next
		return _out_

	# Sets the phase the registry is judged in, development or emulated where fakes are expected and production where they are errors.
	#
	#   pcPhase    development, emulated or production, as a symbol or a text
	#   returns    nothing; use SetPhaseQ to chain
	#   warning    raises an error for any other word and leaves the phase unchanged
	#   see        Phase, IsProduction, FindingsForProduction
	#@ aka  -- the phase --------------------------------------------------------
	def SetPhase(pcPhase)
		This.SetPhaseQ(pcPhase)

	def SetPhaseQ(pcPhase)
		_p_ = This._Key(pcPhase)
		if _p_ != "development" and _p_ != "emulated" and _p_ != "production"
			StzRaise("stzServiceRegistry.SetPhase: expected :development, :emulated or :production.")
		ok
		$aStzServiceRegistries[This._Slot()][4] = _p_
		return This

	# Returns the phase the registry is judged in.
	#
	#   returns    a text, development until it is set
	#   see        SetPhase, IsProduction
	def Phase()
		return $aStzServiceRegistries[This._Slot()][4]

	# TRUE if the registry is judged in the production phase.
	#
	#   returns    TRUE or FALSE
	#   see        Phase, SetPhase
	def IsProduction()
		return $aStzServiceRegistries[This._Slot()][4] = "production"

	# Returns what is wrong with the surface in the current phase, one record per broken invariant, judging credentials against a store.
	#
	#   poStore    the stzSecretStore that must hold every live credential and certificate, or an
	#              empty text to skip those two checks
	#   returns    a list of records with the keys invariant, severity (error or warn), where and
	#              message; [ ] when nothing is wrong
	#   note       the record has the shape the security posture and the graph rules use, so one
	#              gate reads all three
	#   warning    the checks are unbound-service, sandbox-in-production, ephemeral-in-production,
	#              conformance-in-production, ungoverned-payouts-in-production, live-without-secret,
	#              inline-credential (a warning) and live-without-certificate
	#   see        Findings, IsSoundVia, ReportVia
	#@ aka  -- governance -------------------------------------------------------
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
		_a1_ = This._CheckConformanceInProduction()
		_n_ = len(_a1_)
		for _i_ = 1 to _n_
			_aF_ + _a1_[_i_]
		next
		_a1_ = This._CheckUngovernedPayouts()
		_n_ = len(_a1_)
		for _i_ = 1 to _n_
			_aF_ + _a1_[_i_]
		next
		_a1_ = This._CheckLiveCredentials(poStore)
		_n_ = len(_a1_)
		for _i_ = 1 to _n_
			_aF_ + _a1_[_i_]
		next
		_a1_ = This._CheckLiveCertificates(poStore)
		_n_ = len(_a1_)
		for _i_ = 1 to _n_
			_aF_ + _a1_[_i_]
		next
		return _aF_

	# Returns the findings judged without a secret store, so credentials and certificates are not checked.
	#
	#   returns    a list of records, [ ] when nothing is wrong
	#   see        FindingsVia, IsSound, NumberOfFindings
	def Findings()
		return This.FindingsVia("")

	# TRUE if no finding judged against the store is an error, warnings not counting.
	#
	#   poStore    the stzSecretStore that must hold every live credential and certificate, or an
	#              empty text to skip those checks
	#   returns    TRUE or FALSE
	#   warning    a sound registry says the surface is declared and its credentials exist, not that
	#              any service answers
	#   see        IsSound, FindingsVia, MayGoLive
	def IsSoundVia(poStore)
		_aF_ = This.FindingsVia(poStore)
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			if _aF_[_i_][:severity] = :error
				return 0
			ok
		next
		return 1

	# TRUE if no finding judged without a secret store is an error, warnings not counting.
	#
	#   returns    TRUE or FALSE
	#   warning    credentials and certificates are not checked here, so a live binding naming a
	#              missing secret still passes
	#   see        IsSoundVia, Findings
	def IsSound()
		return This.IsSoundVia("")

	# Returns how many findings there are without a secret store, errors and warnings together.
	#
	#   returns    a number
	#   see        Findings, IsSound
	def NumberOfFindings()
		return len(This.Findings())

	# Prints a header line with the counts per posture and one line per finding, judged against a secret store.
	#
	#   poStore    the stzSecretStore that must hold every live credential and certificate, or an
	#              empty text to skip those checks
	#   returns    the registry itself, so calls chain
	#   warning    it prints to the console and does not return the findings
	#   see        Report, FindingsVia
	def ReportVia(poStore)
		_aF_ = This.FindingsVia(poStore)
		? "Service registry '" + @cName + "' [" + $aStzServiceRegistries[This._Slot()][4] + "] -- " +
		  len($aStzServiceRegistries[This._Slot()][3]) + " bound: " + len(This.SandboxedServices()) + " sandboxed, " +
		  len(This.LocalServices()) + " local, " + len(This.LiveServices()) + " live" +
		  This._ConformanceNote()
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

	# Prints the same lines as ReportVia, judged without a secret store.
	#
	#   returns    the registry itself, so calls chain
	#   see        ReportVia, Findings
	def Report()
		return This.ReportVia("")

	# TRUE if an effectful actor that is not sandboxed offers to commit and the surface is sound as production would judge it.
	#
	#   poActor    the actor that would commit the change, a human passes and a language-model or
	#              guardian actor does not
	#   poStore    the stzSecretStore that must hold every live credential and certificate, or an
	#              empty text to skip those checks
	#   returns    TRUE or FALSE
	#   note       expression is free and admission is governed, so an agent may compose the whole
	#              integration and still not be the one who makes it real
	#   warning    the question is asked in the production frame whatever the current phase, then
	#              the phase is put back; a value that is not an object answers FALSE
	#   see        WhyNotLive, FindingsForProduction
	#@ aka  The production gate, mirroring the library's other admission checkpoints: nothing may go live unless the surface is sound AND an EFFECTFUL, non-sandboxed actor commits it. Expression is free; admission is governed.
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

	# Returns the findings production would give, judging against a secret store, and leaves the phase as it was.
	#
	#   poStore    the stzSecretStore that must hold every live credential and certificate, or an
	#              empty text to skip those checks
	#   returns    a list of records like those of FindingsVia
	#   see        FindingsForProduction, MayGoLive
	#@ aka  the surface judged as production would judge it, then put back
	def FindingsForProductionVia(poStore)
		_cWas_ = "" + This.Phase()
		This.SetPhaseQ(:production)
		_aF_ = This.FindingsVia(poStore)
		This.SetPhaseQ(_cWas_)
		return _aF_

	# Returns the findings production would give, judged without a secret store, and leaves the phase as it was.
	#
	#   returns    a list of records like those of FindingsVia
	#   see        FindingsForProductionVia, Findings
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

	# Returns the first reason going live is refused, naming the actor or the failed invariant.
	#
	#   poActor    the actor that would commit the change
	#   poStore    the stzSecretStore that must hold every live credential and certificate, or an
	#              empty text to skip those checks
	#   returns    a text, an empty text when going live is allowed
	#   warning    an invariant is named as its name, a colon and its message
	#   see        MayGoLive, FindingsForProductionVia
	#@ aka  ...and the same, but explaining itself.
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

	# Returns the dependency surface as a graph for the rule engine, with one node for the application and one per service.
	#
	#   returns    an stzGraph whose service nodes carry the phase, posture, secret name, bound and
	#              ephemeral properties
	#   warning    it restates what the findings already say as a graph, to ask which part of a
	#              solution depends on a fake
	#   see        Findings, Show
	#@ aka  -- the graph projection (phase 7) -----------------------------------
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

	# Prints one line giving the name, the phase and how many declared services are bound.
	#
	#   returns    nothing; it prints
	#   see        Report
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

	# A port that skips the plan, asked of the object, in a production phase.
	def _CheckUngovernedPayouts()
		_aF_ = []
		if NOT This.IsProduction()
			return _aF_
		ok
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			_bFree_ = 0
			try
				if $aStzServiceRegistries[This._Slot()][3][_i_][2].AllowsUngovernedPayouts()
					_bFree_ = 1
				ok
			catch
				# says nothing about payouts
			done
			if _bFree_
				_aF_ + [ :invariant = "ungoverned-payouts-in-production", :severity = :error,
				         :where = @cName + "/" + $aStzServiceRegistries[This._Slot()][3][_i_][1],
				         :message = "a payments port that skips the payout plan is bound in a production phase -- " +
				                    "money out must be a plan a human commits" ]
			ok
		next
		return _aF_

	# virtual money in a production phase: the same mistake as a fake, caught by the same gate
	def _CheckConformanceInProduction()
		_aF_ = []
		if NOT This.IsProduction()
			return _aF_
		ok
		_a_ = This.ConformanceServices()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_aF_ + [ :invariant = "conformance-in-production", :severity = :error,
			         :where = @cName + "/" + _a_[_i_],
			         :message = "still bound to a CONFORMANCE sandbox in a production phase -- " +
			                    "virtual money must never ship" ]
		next
		return _aF_

	# A live adapter that needs an mTLS client certificate. Asked of the OBJECT (it says so with
	# RequiresCertificate() and CertificateSecretName()), or named by the binding. Judged from
	# the store alone, in any phase, like live-without-secret.
	def _CheckLiveCertificates(poStore)
		_aF_ = []
		if NOT isObject(poStore)
			return _aF_
		ok
		_nNow_ = StzEngineTimeNowMs() / 1000
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][3][_i_][3] != :live
				loop
			ok
			_svc_ = $aStzServiceRegistries[This._Slot()][3][_i_][1]
			_cert_ = $aStzServiceRegistries[This._Slot()][3][_i_][5]
			if _cert_ = ""
				try
					if $aStzServiceRegistries[This._Slot()][3][_i_][2].RequiresCertificate()
						_cert_ = "" + $aStzServiceRegistries[This._Slot()][3][_i_][2].CertificateSecretName()
					ok
				catch
					# says nothing about needing one
				done
			ok
			if _cert_ = ""
				loop
			ok
			_cWhere_ = @cName + "/" + _svc_
			if NOT poStore.Has(_cert_)
				_aF_ + [ :invariant = "live-without-certificate", :severity = :error, :where = _cWhere_,
				         :message = "the mTLS certificate '" + _cert_ + "' is not in the secret store" ]
				loop
			ok
			_oC_ = poStore.Secret(_cert_)
			if _oC_.SourceKind() = "unset"
				_aF_ + [ :invariant = "live-without-certificate", :severity = :error, :where = _cWhere_,
				         :message = "the mTLS certificate '" + _cert_ + "' is in the store but has no value" ]
				loop
			ok
			if isMethod(_oC_, "IsExpiredAt")
				if _oC_.IsExpiredAt(_nNow_)
					_aF_ + [ :invariant = "live-without-certificate", :severity = :error, :where = _cWhere_,
					         :message = "the mTLS certificate '" + _cert_ + "' is expired -- the hub will refuse every call" ]
				ok
			ok
		next
		return _aF_

	def _ConformanceNote()
		_n_ = len(This.ConformanceServices())
		if _n_ = 0
			return ""
		ok
		return ", " + _n_ + " conformance"

	def _CheckLiveCredentials(poStore)
		_aF_ = []
		_n_ = len($aStzServiceRegistries[This._Slot()][3])
		for _i_ = 1 to _n_
			if $aStzServiceRegistries[This._Slot()][3][_i_][3] != :live and
			   $aStzServiceRegistries[This._Slot()][3][_i_][3] != :conformance
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
				else
					# a descriptor registered and never given a value is a NAME, not a credential
					if poStore.Secret(_sec_).SourceKind() = "unset"
						_aF_ + [ :invariant = "live-without-secret", :severity = :error,
						         :where = @cName + "/" + _svc_,
						         :message = "credential '" + _sec_ + "' is in the secret store but has no value" ]
					ok
				ok
			ok
		next
		return _aF_

	def _BindWith(pcService, poImpl, pcPosture, pcSecret, pcCert)
		if NOT isObject(poImpl)
			StzRaise("stzServiceRegistry.Bind: an implementation object is required for '" +
			         This._Key(pcService) + "'.")
		ok
		_s_ = This._Key(pcService)
		This.DeclareQ(_s_)              # binding implies the dependency
		_i_ = This._BoundIndex(_s_)
		_rec_ = [ _s_, poImpl, pcPosture, "" + pcSecret, "" + pcCert ]
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
			if poImpl.IsConformance()
				return :conformance
			ok
		catch
			# says nothing about being a conformance adapter -- fall through
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
