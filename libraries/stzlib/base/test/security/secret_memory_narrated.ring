load "../../stzBase.ring"
load "../_narrated.ring"

# COMPASS-KERN-07 -- what stzSecret does with a secret in MEMORY, four numbers.
#
# Read on 2026-11-05 against main: a literal secret lived in a Ring string, so it
# could be neither wiped (Ring has no destructor and copies strings freely) nor
# kept out of the page file, and stzPassword.Matches compared with a plain "=",
# which stops at the first differing byte. The value now lives in an engine cell:
# pages locked in RAM, zeroed on Release, compared in constant time. Each
# scenario below ends on the one number the Compass asked for.
#
# What this does NOT cover, said here so nobody reads it in: a text returned by
# Reveal is a Ring string and is not wiped -- Matches exists so that most callers
# never need one.

cMarker = "invented-MARKER-7Q4Z-not-a-real-key"

Scenario("1. zeroing on drop: Release wipes the held value before freeing it")
	nBase = StzHeldSecrets()
	o1 = StzSecretQ("db").FromLiteralQ(cMarker)
	o2 = o1                                     # a Ring copy shares the value
	Then("one more value is held", StzHeldSecrets() - nBase, 1)
	o1.Release()
	aW = StzLastSecretWipe()
	Then("the wipe SAW the value: non-zero bytes before it", aW[:before], len(cMarker))
	Then("NUMBER -- non-zero bytes left after the wipe", aW[:after], 0)
	Then("...and the cell is gone", StzHeldSecrets() - nBase, 0)
	cErr = ""
	try  o1.Reveal(HumanActor("alice"))  catch  cErr = cCatchError  done
	Then("the released face refuses to reveal", StzFindFirst("was released", cErr) > 0, 1)
	cErr = ""
	try  o2.Reveal(HumanActor("alice"))  catch  cErr = cCatchError  done
	Then("a copy taken before the release raises too, never reads freed memory",
		StzFindFirst("was destroyed", cErr) > 0, 1)
	o3 = StzSecretQ("again").FromLiteralQ("invented-other")
	Then("a released secret does not disturb the next one",
		o3.Reveal(HumanActor("alice")), "invented-other")
	o3.Release()
	? "  NUMBER zeroing: " + aW[:after] + " of " + aW[:before] + " bytes left after the wipe"
EndScenario()

Scenario("2. locking in RAM: every held value sits in pages the OS has pinned")
	nBase = StzHeldSecrets()
	aHeld = []
	for i = 1 to 200
		aHeld + StzPasswordQ("p" + i).FromLiteralQ("invented-pw-" + i)
	next
	nLocked = 0
	for i = 1 to 200
		if aHeld[i].IsLockedInRam()  nLocked++  ok
	next
	Then("NUMBER -- held values locked, of 200", nLocked, 200)
	Then("a secret read from the environment holds nothing, so it is not 'locked'",
		StzSecretQ("e").FromEnvQ("STZ_KERN07_UNSET").IsLockedInRam(), 0)
	for i = 1 to 200  aHeld[i].Release()  next
	Then("releasing them all leaves nothing more held", StzHeldSecrets() - nBase, 0)
	? "  NUMBER locking: " + nLocked + " of 200 held values locked (Windows: read from QueryWorkingSetEx)"
EndScenario()

Scenario("3. no plaintext in the ledger, the access log, a descriptor or an error")
	StzOpenSecurityLedger(64)
	oS = StzApiKeyQ("payments").FromLiteralQ(cMarker)
	oStore = new stzSecretStore("vault")
	oStore.Register(oS)
	aSinks = []
	try  oS.Reveal(LLMActor("bot"))  catch  aSinks + cCatchError  done
	try  oStore.Reveal("payments", LLMActor("bot"))  catch  aSinks + cCatchError  done
	try  oStore.RotateToFresh("payments", LLMActor("bot"))  catch  aSinks + cCatchError  done
	oStore.Reveal("payments", HumanActor("alice"))           # a GRANTED reveal is logged too
	oStore.RotateToFresh("payments", HumanActor("alice"))
	aSinks + oS.Descriptor()
	aSinks + oStore.DescriptorOf("payments")
	aSinks + list2str(oStore.Names())
	aLog = oStore.AccessLog()
	nLen = len(aLog)
	for i = 1 to nLen  aSinks + list2str(aLog[i])  next
	aSinks + StzSecurityLedgerQ().ToOcsfNdJson()
	aSinks + StzSecurityLedgerQ().ToOtelLogsJson()
	Then("the ledger did record the refusals", len(StzSecurityLedgerQ().Refusals()) >= 3, 1)
	nFound = 0
	nSinks = len(aSinks)
	for i = 1 to nSinks
		if StzFindFirst(cMarker, aSinks[i]) > 0  nFound++  ok
	next
	Then("the search CAN find the marker where it is (negative sibling)",
		StzFindFirst(cMarker, oS.Reveal(HumanActor("alice"))) > 0, 1)
	Then("NUMBER -- sinks holding the plaintext, of " + nSinks, nFound, 0)
	StzCloseSecurityLedger()
	oS.Release()
	? "  NUMBER plaintext: found in " + nFound + " of " + nSinks + " sinks"
EndScenario()

Scenario("4. constant-time compare: the time does not say where two values differ")
	cBig = copy("a", 65536)
	oK = StzSecretQ("big").FromLiteralQ(cBig)
	cEarly = "b" + copy("a", 65535)             # differs at the first byte
	cLate  = copy("a", 65535) + "b"             # differs at the last byte
	h = oK.@nCell
	# the median of 201 paired rounds, measured inside the engine: a preemption
	# spoils a round, never a whole arm (a ratio of two long totals failed one
	# run in three on this machine)
	nCt = StzEngineSecretCompareRatio(h, cEarly, cLate, 201, 8, 0)
	nPl = StzEngineSecretCompareRatio(h, cEarly, cLate, 201, 8, 1)
	Then("NUMBER -- constant-time: late/early time ratio within 0.8..1.25", nCt > 0.8 and nCt < 1.25, 1)
	Then("the early-exit sibling DOES leak: ratio above 10", nPl > 10, 1)
	oP = StzPasswordQ("login").FromLiteralQ("invented-pw")
	Then("Matches answers right for the password", oP.Matches("invented-pw", HumanActor("a")), 1)
	Then("...and for one wrong byte", oP.Matches("invented-pW", HumanActor("a")), 0)
	Then("...and for a prefix", oP.Matches("invented", HumanActor("a")), 0)
	Then("StzSecureEq: equal", StzSecureEq("abc", "abc"), 1)
	Then("StzSecureEq: other length", StzSecureEq("abc", "abcd"), 0)
	oP.Release()
	oK.Release()
	? "  NUMBER constant-time: late/early " + nCt + " (early-exit sibling: " + nPl + ")"
EndScenario()

Scenario("5. rotation and revocation wipe the values the store made")
	oAlice = HumanActor("alice")
	nBase = StzHeldSecrets()
	oMine = StzApiKeyQ("k").FromLiteralQ("invented-first-value")
	oStore = new stzSecretStore("rot")
	oStore.Register(oMine)
	oStore.RotateToFresh("k", oAlice)
	Then("the first value came from outside, so it is NOT wiped: the caller still reveals it",
		oMine.Reveal(oAlice), "invented-first-value")
	Then("the store owns the fresh value", oStore.OwnsValueOf("k"), 1)
	oCopy = oStore.Secret("k")
	Then("the fresh value is 64 hex characters", len(oCopy.Reveal(oAlice)), 64)
	nWiped = 0  nLeft = 0
	for r = 1 to 10
		oStore.RotateToFresh("k", oAlice)
		aW = StzLastSecretWipe()
		if aW[:before] = 64  nWiped++  ok
		nLeft += aW[:after]
	next
	Then("NUMBER -- of 10 rotated-out values, wiped", nWiped, 10)
	Then("...with 0 bytes left in any of them", nLeft, 0)
	cErr = ""
	try  oCopy.Reveal(oAlice)  catch  cErr = cCatchError  done
	Then("a copy of a rotated-out value raises, never reads freed memory", StzFindFirst("was destroyed", cErr) > 0, 1)
	Then("asking a stale copy whether it is locked answers 0, not an error", oCopy.IsLockedInRam(), 0)
	oCopy.Release()
	Then("releasing a stale copy is harmless", StzLastSecretWipe()[:after], 0)
	oStore.Revoke("k")
	Then("Revoke wipes the value the store made", StzLastSecretWipe()[:before], 64)
	Then("...and the store no longer owns a value under that name", oStore.OwnsValueOf("k"), 0)
	Then("held values: only the caller's own is left", StzHeldSecrets() - nBase, 1)
	oStore.Register(oMine)
	oStore.Revoke("k")
	Then("revoking a value registered from outside leaves it to its owner",
		oMine.Reveal(oAlice), "invented-first-value")
	oMine.Release()
	Then("...who releases it", StzHeldSecrets() - nBase, 0)
	? "  NUMBER rotation: " + nWiped + " of 10 rotated-out values wiped, " + nLeft + " bytes left"
EndScenario()

Summary()
shutdown($_zst_fail)
