load "../../stzBase.ring"
load "../_narrated.ring"

# SOFTANZA_ONE_HOUR.md ruling 3, rung W7b -- the domain door.
#
# A program may name the engine domains it needs before it loads the library;
# what it leaves out is never loaded, and a domain the deny list names is
# refused even when asked for. A manifest acts at LOAD, so every case runs in a
# child process this guard starts (same rnxc, same engine, its own manifest),
# and the guard reads what the child printed. The deny file is this guard's
# own, never the shared engine folder's.
#
# The parent itself loads with no manifest: its domain count is the baseline
# the first child must match.

$cDir = currentdir()
$cDeny = "_dm_deny.txt"
$aChildren = []
$cStzDomainDenyFile = $cDeny
if fexists($cDeny)  remove($cDeny)  ok

oBase = new stzExposure()
nBase = oBase.NumberOfDomains()

Scenario("1. no manifest: every domain loads, as before W7b")
	a = Child("none1", "", "", "")
	Then("the child loads as many domains as this process", 0 + a[:domains], nBase)
	Then("...and skips none", 0 + a[:skipped], 0)
	? "  NUMBER domains loaded with no manifest: " + nBase
EndScenario()

Scenario("2. a manifest of two: the floor and the two, nothing else")
	a = Child("two", "$aStzDomains = [ " + char(34) + "crypto" + char(34) + ", " + char(34) + "seclog" + char(34) + " ]", "", "")
	Then("NUMBER -- six floor domains, the core's stk_string, and the two named", 0 + a[:domains], 9)
	Then("crypto is loaded", 0 + a[:crypto], 1)
	Then("hashmap is loaded: the floor, which the library's own load needs", 0 + a[:hashmap], 1)
	Then("http is not", 0 + a[:http], 0)
	Then("the named domain works", a[:sha], "ba7816bf8f01")
	Then("a call into a domain left out raises at its line, naming the function", StzFindFirst("stzenginehttpget", StzLower(a[:httpcall])) > 0, 1)
	? "  NUMBER domains NOT loaded under the manifest: " + a[:skipped] + " of " + (0 + a[:skipped] + 9)
EndScenario()

Scenario("3. the same through the environment, and the floor alone")
	a = Child("env", "", "STZ_DOMAINS=none", "")
	Then("STZ_DOMAINS=none loads the floor (six, and the core's stk_string) and nothing more", 0 + a[:domains], 7)
	Then("...crypto not among them", a[:sha], "absent")
EndScenario()

Scenario("4. the deny list beats the manifest, and the refusal reaches the ledger")
	write($cDeny, "compress|DRILL-2026-0701|a zlib advisory, denied until rebuilt" + char(10))
	a = Child("deny", "", "", $cDeny)
	Then("a denied domain is not loaded with no manifest", 0 + a[:compress], 0)
	Then("...and is counted as refused, not skipped", "" + a[:refused] + "/" + a[:skipped], "1/0")
	Then("opening a ledger writes exposure.closed under the advisory", a[:closed], "domain compress@DRILL-2026-0701")
	b = Child("denyasked", "$aStzDomains = [ " + char(34) + "compress" + char(34) + " ]", "", $cDeny)
	Then("a manifest that asks for it is refused all the same", 0 + b[:compress], 0)
	remove($cDeny)
EndScenario()

Scenario("5. the responder writes the deny; this process keeps the library, the next one does not")
	StzCloseSecurityLedger()
	oResp = new stzExposureResponder()
	oResp.ShutDomain("DRILL-2026-0702", "url", "a url-parser advisory")
	Then("the deny line is in this guard's file", StzFindFirst("url|DRILL-2026-0702|", read($cDeny)) > 0, 1)
	aRv = StzSecurityLedgerQ().OfKind("capability.revoked")
	Then("this process records the deny as revoked", aRv[len(aRv)][:origin], "DRILL-2026-0702")
	aT = StzTimeToSafe("DRILL-2026-0702")
	Then("...and claims no door shut: the library is still loaded here", aT[:closedAt], -1)
	Then("...which stzExposure confirms", oBase.HasDomain("url"), 1)
	a = Child("next", "", "", $cDeny)
	Then("the next process refuses url at load", 0 + a[:url], 0)
	Then("...and writes exposure.closed", a[:closed], "domain url@DRILL-2026-0702")
	Then("ReopenDomains removes the advisory's line", oResp.ReopenDomains("DRILL-2026-0702"), 1)
	Then("...records it", len(StzSecurityLedgerQ().OfKind("exposure.reopened")), 1)
	a = Child("reopened", "", "", $cDeny)
	Then("...and the process after loads url again", 0 + a[:url], 1)
	remove($cDeny)
EndScenario()

Scenario("6. the library folder is found apart from the engine (stzlib-docs' finding)")
	Then("_StzBaseDir names a folder holding stzBase.ring", fexists(_StzBaseDir() + "/stzBase.ring"), 1)
	Then("...even when the engine is outside the tree", StzFindFirst("/zig-out", _StzBaseDir()), 0)
EndScenario()

for i = 1 to len($aChildren)
	if fexists($aChildren[i])  remove($aChildren[i])  ok
next
Summary()
shutdown($_zst_fail)

# Starts a child rnxc on a generated program and returns what it printed as a
# hash list. pcHead goes before load; pcEnv is NAME=value or ""; pcDeny names
# the deny file the child reads, or "".
func Child(pcName, pcHead, pcEnv, pcDeny)
	q = char(34)
	cF = "_dm_child_" + pcName + ".ring"
	cOut = "_dm_child_" + pcName + ".txt"
	$aChildren + cF
	$aChildren + cOut
	c = pcHead + char(10) +
		"load " + q + "../../stzBase.ring" + q + char(10) +
		"oX = new stzExposure()" + char(10) +
		"? " + q + "domains=" + q + " + oX.NumberOfDomains()" + char(10) +
		"? " + q + "skipped=" + q + " + len(StzDomainsSkipped())" + char(10) +
		"? " + q + "refused=" + q + " + len(StzDomainsRefused())" + char(10) +
		"? " + q + "crypto=" + q + " + oX.HasDomain(" + q + "crypto" + q + ")" + char(10) +
		"? " + q + "hashmap=" + q + " + oX.HasDomain(" + q + "hashmap" + q + ")" + char(10) +
		"? " + q + "http=" + q + " + oX.HasDomain(" + q + "http" + q + ")" + char(10) +
		"? " + q + "compress=" + q + " + oX.HasDomain(" + q + "compress" + q + ")" + char(10) +
		"? " + q + "url=" + q + " + oX.HasDomain(" + q + "url" + q + ")" + char(10) +
		"if oX.HasDomain(" + q + "crypto" + q + ")" + char(10) +
		"	? " + q + "sha=" + q + " + left(StzEngineCryptoSha256(" + q + "abc" + q + "), 12)" + char(10) +
		"else" + char(10) +
		"	? " + q + "sha=absent" + q + char(10) +
		"ok" + char(10) +
		"try" + char(10) +
		"	StzEngineHttpGet(" + q + "http://192.0.2.1/" + q + ")" + char(10) +
		"	? " + q + "httpcall=answered" + q + char(10) +
		"catch" + char(10) +
		"	? " + q + "httpcall=" + q + " + StzReplace(cCatchError, char(10), " + q + " " + q + ")" + char(10) +
		"done" + char(10) +
		"StzOpenSecurityLedger(256)" + char(10) +
		"aR = StzSecurityLedgerQ().OfKind(" + q + "exposure.closed" + q + ")" + char(10) +
		"if len(aR) > 0" + char(10) +
		"	? " + q + "closed=" + q + " + aR[1][:subject] + " + q + "@" + q + " + aR[1][:origin]" + char(10) +
		"else" + char(10) +
		"	? " + q + "closed=none" + q + char(10) +
		"ok" + char(10)
	write(cF, c)
	cCmd = ""
	if pcEnv != ""  cCmd += "set " + pcEnv + "&& "  ok
	if pcDeny != ""  cCmd += "set STZ_DOMAIN_DENY=" + pcDeny + "&& "  ok
	cCmd += q + exefilename() + q + " " + cF + " > " + cOut + " 2>&1"
	system(cCmd)
	aOut = []
	aL = str2list(read(cOut))
	for i = 1 to len(aL)
		k = StzFindFirst("=", aL[i])
		if k > 1 and StzFindFirst("WARNING", aL[i]) != 1
			aOut + [ StzLeft(aL[i], k - 1), StzRight(aL[i], len(aL[i]) - k) ]
		ok
	next
	return aOut
