load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-CONTAIN-01 -- the first REAL responder, the missing account
# lock, and the two numbers a drill exists to produce.
#
# The response catalogue named :LockAccount, but stzAuth had no such act:
# only the failure lockout, a counter that expires by itself. A plan could
# propose a lock that nothing could perform, and no responder had ever
# been wired -- containment stopped at the proposal.
#
# Now stzAuth.LockAccount closes every login path AND every live session,
# kept in the store; stzAuthResponder performs :LockAccount and
# :RevokeSession on a real stzAuth (by reference, never a copy); and the
# drill closes its loop: attack a spawned target over real HTTP, detect
# from sealed and verified evidence, contain through a plan governed in
# the parent and performed in the target, verify from outside, and print
# TIME TO DETECT and TIME TO CONTAIN.

$cDb = "_tmp_contain_auth.db"
CleanDb($cDb)

# =====================================================================
#  THE ACCOUNT LOCK
# =====================================================================

Scenario("a locked account refuses the right password and every live session")
	oAuth = new stzAuth()
	oAuth.Register("mallory", "right-password")
	cTok = oAuth.Login("mallory", "right-password")
	Then("before the lock: login works", cTok != "", 1)
	Then("and the session is live", oAuth.IsValidSession(cTok), 1)
	oAuth.LockAccount("mallory", "credential stuffing observed")
	Then("the account reports locked", oAuth.IsAccountLocked("mallory"), 1)
	Then("the RIGHT password is refused", oAuth.Login("mallory", "right-password"), "")
	Then("the existing session stops answering", oAuth.IsValidSession(cTok), 0)
	Then("the lock says why", oAuth.AccountLock("mallory")[:reason], "credential stuffing observed")
	oAuth.UnlockAccount("mallory")
	Then("unlocked, the right password works again (negative sibling)",
		oAuth.Login("mallory", "right-password") != "", 1)
EndScenario()

Scenario("the lock is kept in the store, so a durable store keeps it")
	oA1 = new stzAuth()
	oA1.SetStore(new stzAuthDbStore($cDb))
	oA1.Register("mallory", "right-password")
	oA1.LockAccount("mallory", "contained")
	oA2 = new stzAuth()
	oA2.SetStore(new stzAuthDbStore($cDb))
	Then("a second stzAuth over the same database sees the lock", oA2.IsAccountLocked("mallory"), 1)
	Then("and refuses the login", oA2.Login("mallory", "right-password"), "")
	# close both connections, or Windows keeps the file and cleanup fails
	oA1.@oStore.DatabaseQ().Close()
	oA2.@oStore.DatabaseQ().Close()
EndScenario()

# =====================================================================
#  THE REAL RESPONDER
# =====================================================================

Scenario("a plan committed by a human operator locks and ends sessions for real")
	oAuth = new stzAuth()
	oAuth.Register("mallory", "pw")
	cTok = oAuth.Login("mallory", "pw")
	oPlan = StzResponsePlan("contain-mallory")
	oPlan.Propose(:LockAccount, "mallory", "five bad passwords in a minute")
	oPlan.Propose(:RevokeSession, "mallory", "five bad passwords in a minute")
	nDone = oPlan.ExecuteOn(StzAuthResponder(oAuth), HumanActor("oncall"))
	Then("both actions were committed", nDone, 2)
	Then("the account the CALLER holds is locked (a reference, not a copy)",
		oAuth.IsAccountLocked("mallory"), 1)
	Then("its sessions are gone from the store", len(oAuth.SessionsOf("mallory")), 0)
	Then("the old token is dead", oAuth.IsValidSession(cTok), 0)
EndScenario()

Scenario("an LLM can propose the same plan and cannot commit it")
	oAuth = new stzAuth()
	oAuth.Register("mallory", "pw")
	oPlan = StzResponsePlan("contain-mallory")
	oPlan.Propose(:LockAccount, "mallory", "proposed by the investigating model")
	nDone = oPlan.ExecuteOn(StzAuthResponder(oAuth), LLMActor("investigator"))
	Then("nothing was committed", nDone, 0)
	Then("the account is untouched", oAuth.IsAccountLocked("mallory"), 0)
	Then("the refusal is audited", oPlan.RefusedCount(), 1)
EndScenario()

Scenario("the responder refuses what authentication does not own, loudly")
	oAuth = new stzAuth()
	bRaised = 0
	try  StzAuthResponder(oAuth).RotateSecret("stripe-live")  catch  bRaised = 1  done
	Then(":RotateSecret raises instead of pretending", bRaised, 1)
EndScenario()

# =====================================================================
#  THE DRILL: attack, detect, contain -- and the two numbers
# =====================================================================

Scenario("the drill detects credential stuffing and contains it, timed")
	oDrill = StzSecurityDrill("contain")
	Given("a spawned target with a real stzAuth and a real responder")
	Then("the target is up", oDrill.SpawnTarget(0), 1)
	Then("the victim has a live session before the attack",
		oDrill.OpenVictimSession("victim", "correct-horse"), 1)
	When("five bad passwords are sent over real HTTP")
	oDrill.FireCredentialStuffing("victim", 5)
	Then("the sealed evidence is acquired and verified", oDrill.CollectEvidence(), 1)
	Then("credential stuffing was detected", oDrill.Passed(), 1)
	When("an LLM investigator tries to contain")
	Then("it commits nothing", oDrill.Contain(LLMActor("investigator")), 0)
	Then("and the victim can still log in", oDrill.ContainmentHolds(), 0)
	When("the on-call human contains")
	nDone = oDrill.Contain(HumanActor("oncall"))
	Then("the lock and the session revocation were committed", nDone >= 2, 1)
	Then("containment holds, verified from outside the target", oDrill.ContainmentHolds(), 1)
	nTTD = oDrill.TimeToDetectMs()
	nTTC = oDrill.TimeToContainMs()
	Then("time to detect was measured", nTTD >= 0, 1)
	Then("time to contain was measured", nTTC >= 0, 1)
	? ""
	? "  >> TIME TO DETECT : " + nTTD + " ms  (first bad password -> detection on verified evidence)"
	? "  >> TIME TO CONTAIN: " + nTTC + " ms  (detection -> account locked + sessions ended, verified)"
	oDrill.Show()
	oDrill.Destroy()
EndScenario()

CleanDb($cDb)
Summary()

func CleanDb cPath
	acSuffix = [ "", "-wal", "-shm", "-journal" ]
	for i = 1 to 4
		if fexists(cPath + acSuffix[i])  remove(cPath + acSuffix[i])  ok
	next
