load "../../stzBase.ring"
load "../_narrated.ring"

# SOFTANZA_ONE_HOUR.md, B2 and B4 (rung W1) -- an advisory meets the inventory,
# and time-to-safe is a number the ledger reports.
#
# Everything here is a FIXTURE: the feed is seeded, never fetched. The live door
# (FetchLive) is a program's declared act and is not exercised by a guard
# (ruling 4). The drill of scenario 4 pushes one seeded advisory through the
# five kinds of the patch ledger and prints the two numbers the budget is about.

Scenario("1. an advisory that names what we run is matched, and recorded with its id as origin")
	StzCloseSecurityLedger()
	oX = new stzExposure()
	cZlib = oX.VendoredVersionOf("zlib")
	Then("the exposure knows zlib's version", StzFindFirst("1.3", cZlib) > 0, 1)
	oF = new stzAdvisoryFeed()
	oF.SeedAdvisory("FIX-2026-0001", "zlib", "1.3", 7.5, 0)              # a prefix that covers 1.3.1
	oF.SeedAdvisory("FIX-2026-0002", "zlib", "1.2", 9.8, 1)              # an older line: not ours
	oF.SeedAdvisory("FIX-2026-0003", "nonesuch", "*", 10, 1)             # a library we do not carry
	oF.SeedAdvisory("FIX-2026-0004", "stz_crypto", "*", 5.0, 0)          # an engine domain, loaded
	oF.SeedAdvisory("FIX-2026-0005", "stz_nonesuch", "*", 5.0, 0)        # a domain that does not exist
	n = oF.Match(oX)
	Then("NUMBER -- matches of 5 seeded advisories", n, 2)
	Then("the ledger was opened by the match", StzSecurityLedgerIsOpen(), 1)
	aR = StzSecurityLedgerQ().OfKind("advisory.matched")
	Then("one record per match", len(aR), 2)
	Then("the first names zlib with the advisory id as origin", aR[1][:subject] + "@" + aR[1][:origin], "zlib@FIX-2026-0001")
	Then("...a warning at 7.5", aR[1][:severity], "warning")
	Then("the second is the loaded domain", aR[2][:subject], "stz_crypto")
	? "  NUMBER matched: " + n + " of " + oF.NumberOfAdvisories() + " advisories reach this process"
EndScenario()

Scenario("2. severity follows the score and the exploited flag")
	StzCloseSecurityLedger()
	oX = new stzExposure()
	oF = new stzAdvisoryFeed()
	oF.SeedAdvisory("FIX-2026-0010", "zlib", "*", 9.8, 0)                # critical by score
	oF.SeedAdvisory("FIX-2026-0011", "zlib", "*", 4.0, 1)                # low score, but exploited
	oF.SeedAdvisory("FIX-2026-0012", "zlib", "*", 4.0, 0)                # low, not exploited
	oF.Match(oX)
	aR = StzSecurityLedgerQ().OfKind("advisory.matched")
	Then("a 9.8 is an error", aR[1][:severity], "error")
	Then("an exploited 4.0 is an error too, and says EXPLOITED", aR[2][:severity] + "/" + (StzFindFirst("EXPLOITED", aR[2][:reason]) > 0), "error/1")
	Then("a plain 4.0 is a warning", aR[3][:severity], "warning")
	Then("the chain verifies", StzSecurityLedgerQ().Verify()[:intact], 1)
EndScenario()

Scenario("3. versions: exact, prefix, all -- and a record whose text carries words around the number")
	oF = new stzAdvisoryFeed()
	Then("* covers anything", oF.Affects("curl 8.22.0 (libcurl only)", [ "x", "curl", "*", 0, 0, "" ]), 1)
	Then("a prefix covers its line", oF.Affects("Mbed TLS 3.6.7 (the 3.6 LTS line)", [ "x", "mbedtls", "3.6", 0, 0, "" ]), 1)
	Then("...and not another line", oF.Affects("Mbed TLS 3.6.7 (the 3.6 LTS line)", [ "x", "mbedtls", "3.5", 0, 0, "" ]), 0)
	Then("an exact version matches itself", oF.Affects("zlib 1.3.1", [ "x", "zlib", "1.3.1", 0, 0, "" ]), 1)
	Then("...and not its neighbour", oF.Affects("zlib 1.3.1", [ "x", "zlib", "1.3.2", 0, 0, "" ]), 0)
	Then("a record with no number matches nothing but *", oF.Affects("ggml unknown", [ "x", "ggml", "0", 0, 0, "" ]), 0)
EndScenario()

Scenario("4. THE DRILL: one advisory through the five kinds, and the two numbers")
	StzCloseSecurityLedger()
	oX = new stzExposure()
	oF = new stzAdvisoryFeed()
	oF.SeedAdvisory("DRILL-2026-0001", "zlib", "*", 9.8, 1)
	oF.Match(oX)
	t0 = StzTimeToSafe("DRILL-2026-0001")
	Then("matched, nothing else yet: both numbers are -1", "" + t0[:msToClosed] + "/" + t0[:msToGreen], "-1/-1")
	Then("...so the budget does not hold", StzTimeToSafeHolds("DRILL-2026-0001"), 0)
	StzNoteExposureClosed("DRILL-2026-0001", "zlib", "the domain that links zlib was unloaded")
	t1 = StzTimeToSafe("DRILL-2026-0001")
	Then("the door shut: msToClosed is measured (>= 0)", t1[:msToClosed] >= 0, 1)
	Then("...and msToGreen is still -1", t1[:msToGreen], -1)
	StzNotePinMoved("DRILL-2026-0001", "zlib", "1.3.1 -> 1.3.2")
	StzNoteRebuilt("DRILL-2026-0001", "zlib", "zig build -j2, stz_compress")
	StzNoteGuardGreen("DRILL-2026-0001", "zlib", "compress_narrated 40/40")
	t2 = StzTimeToSafe("DRILL-2026-0001")
	Then("all five kinds have a moment", (t2[:matchedAt] >= 0) + (t2[:closedAt] >= 0) + (t2[:pinMovedAt] >= 0) + (t2[:rebuiltAt] >= 0) + (t2[:greenAt] >= 0), 5)
	Then("NUMBER -- the budget holds for the drill", StzTimeToSafeHolds("DRILL-2026-0001"), 1)
	aB = StzTimeToSafeBudget()
	Then("the budget is ruling 4's: one hour to the door, one day to green", "" + aB[:msToClosed] + "/" + aB[:msToGreen], "3600000/86400000")
	Then("an advisory nobody matched has no numbers", StzTimeToSafe("NONE-0000")[:msToClosed], -1)
	Then("the chain verifies across the five", StzSecurityLedgerQ().Verify()[:intact], 1)
	? "  NUMBER time-to-safe (drill): " + t2[:msToClosed] + " ms to the door shut, " + t2[:msToGreen] + " ms to green (budget 3600000 / 86400000)"
	StzCloseSecurityLedger()
EndScenario()

Summary()
