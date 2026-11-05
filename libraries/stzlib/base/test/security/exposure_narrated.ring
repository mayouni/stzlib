load "../../stzBase.ring"
load "../_narrated.ring"

# SOFTANZA_ONE_HOUR.md, B1 (rung W0) -- what this process runs, as data.
#
# An advisory names a component and a version; before it can be matched to us,
# we must name what we run, from the process and its recorded digests, never
# from a document. Four numbers: engine domains loaded, vendored libraries with a
# digest each, models recorded, listeners noted -- and one refusal: a vendored
# tree that differs from its record (engine/tools/vendor_digest.py, exit code).

Scenario("1. the engine domains loaded, read from their handles")
	oX = new stzExposure()
	Then("NUMBER -- domains loaded", oX.NumberOfDomains() >= 60, 1)
	Then("the crypto domain, which this guard's secrets use, is one", oX.HasDomain("crypto"), 1)
	Then("the security ledger's domain is one", oX.HasDomain("seclog"), 1)
	Then("a domain that does not exist is not", oX.HasDomain("nonesuch"), 0)
	? "  NUMBER domains: " + oX.NumberOfDomains() + " loaded"
EndScenario()

Scenario("2. every vendored library has a version and a tree digest")
	oX = new stzExposure()
	Then("NUMBER -- vendored libraries recorded", oX.NumberOfVendored(), 21)
	nDigested = 0
	aV = oX.Vendored()
	for i = 1 to len(aV)
		if len(aV[i][4]) = 64 and aV[i][3] > 0  nDigested++  ok
	next
	Then("...each with a 64-hex digest over a non-empty tree", nDigested, 21)
	Then("mbedtls is the 3.6 LTS line", StzFindFirst("3.6", oX.VendoredVersionOf("mbedtls")) > 0, 1)
	Then("the record says when it was written", len(oX.VendoredRecordedAt()) = 20, 1)
	Then("an unknown library has no digest", oX.VendoredDigestOf("nonesuch"), "")
	? "  NUMBER vendored: " + nDigested + " of " + oX.NumberOfVendored() + " with a digest, recorded " + oX.VendoredRecordedAt()
EndScenario()

Scenario("3. the models the record names, and whether each is here")
	oX = new stzExposure()
	if oX.NumberOfModels() = 0
		? "  NOT RUN: no models record reachable (set STZ_MODELS_DIR under a Ring++ engine copy)"
	else
		Then("NUMBER -- models recorded", oX.NumberOfModels() >= 3, 1)
		aM = oX.Models()
		nPresent = 0
		for i = 1 to len(aM)
			if aM[i][3] = 1  nPresent++  ok
		next
		Then("each row carries a 64-hex digest", len(aM[1][2]), 64)
		? "  NUMBER models: " + oX.NumberOfModels() + " recorded, " + nPresent + " present"
	ok
EndScenario()

Scenario("4. a listener tells the exposure before it opens, and loopback is the default")
	StzForgetListeners()
	oS = new stzTcpServer()
	oS.Listen(0, "")                                  # port 0: the OS picks; host "": the default
	oX = new stzExposure()
	Then("one listener noted", oX.NumberOfListeners(), 1)
	Then("its class", oX.Listeners()[1][1], "stzTcpServer")
	Then("the default host is loopback (it was 0.0.0.0 until 2026-11-05)", oX.Listeners()[1][2], "127.0.0.1")
	Then("NUMBER -- listeners beyond loopback", oX.NumberOfExposedListeners(), 0)
	oS.Close()
	StzNoteListener("probe", "0.0.0.0", 9)             # what a wide bind would look like
	oX.Refresh()
	Then("a wide bind IS counted as exposed (negative sibling)", oX.NumberOfExposedListeners(), 1)
	StzForgetListeners()
EndScenario()

Scenario("5. the bill of materials an outside scanner reads")
	StzForgetListeners()
	StzNoteListener("stzReactor.http", "127.0.0.1", 8080)
	oX = new stzExposure()
	cBom = oX.AsCycloneDx()
	Then("it is CycloneDX 1.5", StzFindFirst('"bomFormat":"CycloneDX","specVersion":"1.5"', cBom) > 0, 1)
	Then("it is valid JSON", StzJsonIsValid(cBom), 1)
	aB = JsonToList(cBom)
	nLib = 0  nData = 0
	aC = aB[:components]
	for i = 1 to len(aC)
		if aC[i][:type] = "library"  nLib++  ok
		if aC[i][:type] = "data"     nData++  ok
	next
	Then("libraries = vendored + engine domains", nLib, oX.NumberOfVendored() + oX.NumberOfDomains())
	Then("data components = the models", nData, oX.NumberOfModels())
	Then("the listener is a service with its endpoint", StzFindFirst('"endpoints":["127.0.0.1:8080"]', cBom) > 0, 1)
	Then("a vendored digest travels as SHA-256", StzFindFirst('"alg":"SHA-256","content":"' + oX.VendoredDigestOf("zlib") + '"', cBom) > 0, 1)
	StzForgetListeners()
	? "  NUMBER bom: " + len(aC) + " components, " + len(aB[:services]) + " service"
EndScenario()

Scenario("6. the vendored record refuses a changed tree (the tool's own fixture)")
	cOut = systemCmd("python -I " + $cEngineDir + "/tools/vendor_digest.py --selftest")
	Then("selftest: a clean tree passes, a changed byte and an added file are refused",
		StzFindFirst("selftest: clean=0 tampered=1 added=1", cOut) > 0, 1)
	cOut = systemCmd("python -I " + $cEngineDir + "/tools/vendor_digest.py --check --quiet")
	# the engine this process runs may be a COPY (the Ring++ build lives beside the
	# source tree); a copy that differs from the record is information, not a failure
	# here -- the check must NAME what differs and its count must agree with its list
	nChanged = len(StzFindCS("CHANGED", cOut, 1)) + len(StzFindCS("UNRECORDED", cOut, 1)) + len(StzFindCS("MISSING", cOut, 1))
	Then("the check's count agrees with the libraries it names",
		StzFindFirst("differing from the record: " + nChanged, cOut) > 0, 1)
	? "  NUMBER vendored check on " + $cEngineDir + ": " + nChanged + " differing from the record"
	if nChanged > 0  ? "  " + ring_trim(cOut)  ok
EndScenario()

Summary()
