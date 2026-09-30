load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-ANOMALY-01 -- threat-model risk R9 (NIST CSF DE.AE): detection
# that learns its threshold from history instead of having it written down.
#
# BURST, SEQUENCE and ANY each need a number somebody chose. Password
# spraying is built to stay under it: one guess on each of fifty accounts
# never makes five failures on one. The UNUSUAL shape judges the newest
# window against the SAME kind's own history -- leave-one-out, so the
# window being judged is never part of its own baseline.
#
# Every event carries an explicit wall time, so the windows are exact and
# the guard cannot flake on machine speed.

$T = 1785500000000     # the moment of judgement
$W = 60000             # one window
$aQuiet = [ 1, 2, 1, 0, 2, 1, 1, 2, 0, 1, 2, 1 ]   # failures per past window

Scenario("password spraying: invisible per account, loud against history")
	oLed = StzSecurityLedger(1024)
	History(oLed, $aQuiet)
	Spray(oLed, 50)
	oPerAccount = StzDetection("credential-stuffing")
	oPerAccount.WhenKind("auth.login.failed").PerActor().Repeats(5).Within(60000)
	Then("the per-account burst sees nothing", len(oPerAccount.CheckAgainst(oLed)), 0)
	oD = Spraying().AtLeast(10)
	aF = oD.CheckAgainst(oLed)
	Then("the unusual rate fires once", len(aF), 1)
	Then("...in the unified rule shape", aF[1][:subject] + "/" + aF[1][:rule], "security/spraying")
	Then("...naming the count and the baseline", StzFindFirst("50 x auth.login.failed", aF[1][:message]) > 0, 1)
	Then("...and the evidence is the window, not the history", len(oD.LastEvidence()), 50)
EndScenario()

Scenario("sigma decides, not the floor (the boundary, both sides)")
	# the furthest window is only partly retained, so the baseline is the 11
	# windows fully covered: mean 1.18, sd 0.72 -- 3 is 2.5 sigma, 4 is 3.9
	oLed = StzSecurityLedger(1024)
	History(oLed, $aQuiet)
	Spray(oLed, 3)
	Then("3 in the window is ordinary variation", len(Spraying().AtLeast(3).CheckAgainst(oLed)), 0)
	oLed2 = StzSecurityLedger(1024)
	History(oLed2, $aQuiet)
	Spray(oLed2, 4)
	aF = Spraying().AtLeast(3).CheckAgainst(oLed2)
	Then("4 in the window is unusual", len(aF), 1)
	Then("...and the message gives the sigma", StzFindFirst("3.9", aF[1][:message]) > 0, 1)
EndScenario()

Scenario("leave-one-out: a jump off a flat baseline fires")
	oLed = StzSecurityLedger(1024)
	History(oLed, [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ])
	Spray(oLed, 6)
	aF = Spraying().AtLeast(3).CheckAgainst(oLed)
	Then("6 against a steady 2 fires", len(aF), 1)
	Then("...said as a flat baseline", StzFindFirst("flat baseline", aF[1][:message]) > 0, 1)
	oLed2 = StzSecurityLedger(1024)
	History(oLed2, [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ])
	Spray(oLed2, 2)
	Then("2 against a steady 2 does not (negative sibling)", len(Spraying().AtLeast(1).CheckAgainst(oLed2)), 0)
EndScenario()

Scenario("cold start is not an anomaly")
	oLed = StzSecurityLedger(1024)
	History(oLed, [ 1, 1 ])            # only two windows of history
	Spray(oLed, 50)
	Then("two windows of history: nothing is claimed", len(Spraying().AtLeast(10).CheckAgainst(oLed)), 0)
EndScenario()

Scenario("a flood that evicted its own baseline is reported, not silenced")
	oLed = StzSecurityLedger(64)
	History(oLed, $aQuiet)
	Spray(oLed, 100)
	Then("the ledger evicted the history", oLed.Count() > oLed.Size(), 1)
	aF = Spraying().AtLeast(10).CheckAgainst(oLed)
	Then("the detection still speaks", len(aF), 1)
	Then("...as a warning", aF[1][:severity], "warning")
	Then("...saying why it cannot compare", StzFindFirst("pushed its own baseline out of reach", aF[1][:message]) > 0, 1)
EndScenario()

Scenario("per actor: one account far above its own history")
	oLed = StzSecurityLedger(1024)
	for k = 12 to 1 step -1
		AddFailures(oLed, "carol", k, 1, 1)
		AddFailures(oLed, "dana", k, 1, 1)
	next
	AddFailures(oLed, "carol", 0, 1, 1)
	AddFailures(oLed, "dana", 0, 12, 1)
	oD = Spraying().PerActor().AtLeast(5)
	aF = oD.CheckAgainst(oLed)
	Then("one finding", len(aF), 1)
	Then("...about dana, not carol", aF[1][:where], "spraying/dana")
EndScenario()

Scenario("the house set carries it, and says what it is")
	oSet = StzDefaultDetectionSet()
	Then("password-spraying ships by default", ring_find(oSet.Names(), "password-spraying") > 0, 1)
	oLed = StzSecurityLedger(1024)
	aLong = []
	for i = 1 to 32  aLong + ((i % 3))  next
	History(oLed, aLong)
	Spray(oLed, 40)
	oSet.DetectionQ("password-spraying").AsOf($T)
	Then("...and fires on a spray", ring_find(oSet.FiredNames(oLed), "password-spraying") > 0, 1)
	Then("its explanation names the shape",
		StzFindFirst("an unusual rate of auth.login.failed", oSet.DetectionQ("password-spraying").Explain()[1]) > 0, 1)
EndScenario()

Summary()

# -- helpers (after the main code) ------------------------------------

func Spraying
	oD = StzDetection("spraying")
	oD.WhenKind("auth.login.failed").Unusual().Buckets($W).AgainstBaseline(12).Sigma(3)
	oD.AsOf($T)
	return oD

# past windows, oldest first: aCounts[1] is the window furthest back
func History oLed, aCounts
	nK = len(aCounts)
	for j = 1 to nK
		AddFailures(oLed, "", nK - j + 1, aCounts[j], j)
	next

# the window being judged: one failure on each of n accounts
func Spray oLed, n
	AddFailures(oLed, "", 0, n, 1000)

# n failures inside window k (0 = the newest); an empty actor means one
# account per event
func AddFailures oLed, cActor, k, n, nSeed
	if n = 0  return  ok
	nStep = floor(($W - 2000) / n)
	for i = 1 to n
		cWho = cActor
		if cWho = ""  cWho = "user" + nSeed + "-" + i  ok
		nAt = $T - ((k + 1) * $W) + 1000 + ((i - 1) * nStep)
		oE = StzSecurityEvent("auth.login.failed")
		oE.ByActorNamed(cWho, "external")
		oE.About("user:" + cWho)
		oE.Refused("(scripted for the guard)")
		oE.OccurredAt(nAt)
		oLed.Record(oE)
	next
