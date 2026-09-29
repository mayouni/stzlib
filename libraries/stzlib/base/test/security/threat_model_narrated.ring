load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-THREAT-MODEL-01 -- the threat model's claims stay attached to
# their proofs.
#
# base/security/SOFTANZA_THREAT_MODEL.md lists every guarantee with the
# guard that proves it. A document like that decays silently: a guard is
# renamed, the row still reads as proven. This guard reads the document
# and checks, for section 3 (the guarantees):
#   - every guarantee row (| G.. |) names at least one proof
#   - every guard file it names EXISTS
# It does not RUN them -- that is the security gate's job, and running
# forty guards here would make this one slow.

$cDoc = read("../../security/SOFTANZA_THREAT_MODEL.md")

Scenario("the threat model exists and has its sections")
	Then("the document was read", len($cDoc) > 1000, 1)
	Then("it has a guarantees section", StzFindFirst("## 3. Guarantees", $cDoc) > 0, 1)
	Then("it has an open-risks section", StzFindFirst("## 4. Open risks", $cDoc) > 0, 1)
EndScenario()

aRows = GuaranteeRows($cDoc)

Scenario("every guarantee names its proof")
	Then("there are guarantees to check", len(aRows) >= 20, 1)
	aNoProof = RowsWithoutProof(aRows)
	if len(aNoProof) > 0  ? "    rows without proof: " + @@(aNoProof)  ok
	Then("no guarantee row lacks a proof", len(aNoProof), 0)
EndScenario()

Scenario("every guard the threat model names exists")
	aPaths = GuardPaths(aRows)
	Then("the rows name guard files", len(aPaths) >= 30, 1)
	aMissing = MissingPaths(aPaths)
	if len(aMissing) > 0  ? "    missing: " + @@(aMissing)  ok
	Then("none is missing", len(aMissing), 0)
EndScenario()

Scenario("the checker itself catches a broken row (negative sibling)")
	cFake = "## 3. Guarantees" + char(10) +
		"| G98 | a claim | code | `base/test/security/no_such_guard_narrated.ring` (5) | A01 | - |" + char(10) +
		"| G99 | an unproven claim | code | nothing here | A01 | - |" + char(10) +
		"## 4. Open risks" + char(10)
	aFR = GuaranteeRows(cFake)
	Then("it reads both fake rows", len(aFR), 2)
	Then("it flags the row with no proof", len(RowsWithoutProof(aFR)), 1)
	Then("it flags the guard that does not exist", len(MissingPaths(GuardPaths(aFR))), 1)
EndScenario()

Summary()

# -- helpers (after the main code: a func swallows what follows it) ---

# the "| Gnn |" table rows of section 3
func GuaranteeRows cDoc
	nA = StzFindFirst("## 3. Guarantees", cDoc)
	nB = StzFindFirst("## 4. Open risks", cDoc)
	aOut = []
	if nA = 0 or nB = 0  return aOut  ok
	acLines = split(StzMid(cDoc, nA, nB - nA), char(10))
	for i = 1 to len(acLines)
		c = trim(acLines[i])
		if StzLeft(c, 3) = "| G" and StzFindFirst("|", StzMidToEnd(c, 2)) > 0
			cId = trim(StzMid(c, 3, 4))
			if IsTwoDigits(StzMid(cId, 2, 2))  aOut + c  ok
		ok
	next
	return aOut

# a proof is a guard file, the vendored-record check, the fuzz run, or SECURITY.md
func RowsWithoutProof aRows
	aOut = []
	for i = 1 to len(aRows)
		c = aRows[i]
		if StzFindFirst("_narrated.ring", c) = 0 and StzFindFirst("sbom.py --check", c) = 0 and
		   StzFindFirst("zig build fuzz", c) = 0 and StzFindFirst("SECURITY.md` |", c) = 0
			aOut + StzLeft(c, 8)
		ok
	next
	return aOut

# every `base/test/....ring` path in the rows, deduplicated
func GuardPaths aRows
	aOut = []
	for i = 1 to len(aRows)
		acParts = split(aRows[i], "`")
		for j = 1 to len(acParts)
			p = acParts[j]
			if StzLeft(p, 10) = "base/test/" and StzRight(p, 5) = ".ring"
				if find(aOut, p) = 0  aOut + p  ok
			ok
		next
	next
	return aOut

# paths are relative to libraries/stzlib; this guard runs in base/test/security
func MissingPaths aPaths
	aOut = []
	for i = 1 to len(aPaths)
		if NOT fexists("../../../" + aPaths[i])  aOut + aPaths[i]  ok
	next
	return aOut

# "01".."99" -- written out: isdigit() is shadowed by a one-character
# version in the library, and answered 0 for "01"
func IsTwoDigits c
	if len(c) != 2  return 0  ok
	for i = 1 to 2
		n = ascii(c[i])
		if n < 48 or n > 57  return 0  ok
	next
	return 1
