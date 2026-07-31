# The sentinel -- incident analysis I4 (SOFTANZA_INCIDENT_ANALYSIS.md).
#
# A detection set judges when asked; the sentinel asks on a cadence and
# fires only on TRANSITIONS. The identity of a firing is the finding's
# :where -- credential-stuffing/victim, not merely credential-stuffing
# -- so two accounts under attack are two stories and one account still
# under attack is not a new story every second.
#
# It also photographs a CASE at the moment of firing (finding + ledger
# head digest + the events nearest it), which is what I5's incident
# will be built from.
#
# Ring traps avoided: main code before the first func; no oR / nL /
# cAll locals; kinds are STRINGS; callbacks tracked by boolean flags.

load "../../stzBase.ring"

nPass = 0
nFail = 0

nT0 = 1785600000000
$nSeen = 0
$nCleared = 0
$cLastWhere = ""

pr()

? "-- Scene 1: a quiet ledger fires nothing --"
oLed = StzSecurityLedger(256)
oSet = StzDefaultDetectionSet()
oSent = StzSecuritySentinel(oSet)
oSent.Watching(oLed).SetChannels("i4.detection", "i4.clear")
oSent.OnDetection(func aFinding { $nSeen++ $cLastWhere = aFinding[:where] })
oSent.OnClear(func cWhere { $nCleared++ })
chk("nothing fires on an empty ledger", oSent.Check() = 0)
chk("...and the sentinel says it is quiet", NOT oSent.IsFiring())

? ""
? "-- Scene 2: an attack appears -- it fires ONCE --"
for i = 1 to 5
	oLed.Record(BuildEvt("auth.login.failed", "victim", "user:victim", nT0 + (i * 3000)))
next
chk("the first pass fires the new detection", oSent.Check() = 1)
chk("the callback saw it", $nSeen = 1)
chk("...and it names the ACCOUNT, not just the rule", StzFindFirst("credential-stuffing/victim", $cLastWhere) = 1)
chk("one story is active", len(oSent.ActiveDetections()) = 1 and oSent.IsFiring())

? ""
? "-- Scene 3: still under attack is NOT a new story --"
chk("a second pass fires nothing (edge-triggered)", oSent.Check() = 0)
oLed.Record(BuildEvt("auth.login.failed", "victim", "user:victim", nT0 + 20000))
chk("...even as more failures arrive", oSent.Check() = 0)
chk("the callback count is unchanged", $nSeen = 1)

? ""
? "-- Scene 4: a SECOND account is a second story --"
for i = 1 to 5
	oLed.Record(BuildEvt("auth.login.failed", "admin", "user:admin", nT0 + 100000 + (i * 3000)))
next
chk("the other account fires its own detection", oSent.Check() = 1)
chk("two stories are now active", len(oSent.ActiveDetections()) = 2)
chk("the callback saw the second", $nSeen = 2)

? ""
? "-- Scene 5: the event bus carried every transition --"
oBus = new stzEventBus()
chk("two detections were announced on the channel", oBus.EventCount("i4.detection") = 2)
chk("...and the last payload names the story", StzFindFirst("credential-stuffing/", oBus.LastEvent("i4.detection")) = 1)

? ""
? "-- Scene 6: THE CASE -- photographed at the moment of firing --"
aCase = oSent.LastCase()
chk("a case was taken", len(aCase) > 0)
chk("...naming the story", StzFindFirst("credential-stuffing/admin", aCase[:where]) = 1)
chk("...with the ledger's head digest (a commitment to the history)", len(aCase[:headDigest]) = 64)
chk("...how many events existed at that moment", aCase[:ledgerCount] = oLed.Count())
chk("...and the events nearest the firing, for the timeline to come", len(aCase[:recent]) > 0)
chk("two firings, two cases", len(oSent.Cases()) = 2)

? ""
? "-- Scene 7: when the evidence ages out, the story CLEARS --"
oLed.Reset()
chk("the clearing pass fires no new detections", oSent.Check() = 0)
chk("both stories cleared", NOT oSent.IsFiring() and len(oSent.ActiveDetections()) = 0)
chk("the clear callback ran for each", $nCleared = 2)
chk("...and the bus announced them", oBus.EventCount("i4.clear") = 2)

? ""
? "-- Scene 8: a returning attack is a NEW story (it fires again) --"
for i = 1 to 5
	oLed.Record(BuildEvt("auth.login.failed", "victim", "user:victim", nT0 + 300000 + (i * 3000)))
next
chk("after a genuine clear, the same account fires again", oSent.Check() = 1)
chk("the callback count moved", $nSeen = 3)
chk("the alert log kept the whole story (fire, fire, clear, clear, fire)", len(oSent.AlertLog()) = 5)
chk("...and the last entry is the re-fire", oSent.LastAlert()[2] = "detection")

? ""
? "-- Scene 9: the cadence, and the agent-host contract --"
oSent.Every(60)
nC1 = oSent.Tick()
nC2 = oSent.Tick()
chk("Tick() is cadence-gated (the second is not due)", isNumber(nC1) and nC2 = 0)
chk("Name_() answers, as a host requires", oSent.Name_() = "security-sentinel")

oLed2 = StzSecurityLedger(64)
oSet2 = StzDefaultDetectionSet()
oHosted = StzSecuritySentinel(oSet2)
oHosted.SetName("hosted-watch").Watching(oLed2).SetChannels("i4b.detection", "i4b.clear")
oHosted.Every(50)
oHost = new stzAgentHost()
oHost.Supervise(oHosted, 50)
oLed2.Record(BuildEvt("sig.nonce.replayed", "peer-3", "key:billing", nT0))
oHost.RunFor(260)
? "  the host ticked the sentinel " + oHost.TicksOf("hosted-watch") + " time(s)"
chk("a host supervises the sentinel like any agent", oHost.TicksOf("hosted-watch") >= 3)
chk("...and the hosted copy fired on the replay", oBus.EventCount("i4b.detection") = 1)

? ""
? "-- Scene 10: it explains itself --"
oSent.Show()
aL = oSent.Explain()
chk("the header counts checks and active stories", StzFindFirst("check(s)", aL[1]) > 0)
oLed.Destroy()
oLed2.Destroy()

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func BuildEvt cKind, cActor, cSubject, nWall
	oE = StzSecurityEvent(cKind)
	oE.ByActorNamed(cActor, "external")
	oE.About(cSubject)
	oE.Refused("(scripted for the guard)")
	oE.OccurredAt(nWall)
	return oE
