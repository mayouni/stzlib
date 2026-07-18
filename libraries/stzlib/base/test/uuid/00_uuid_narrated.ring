load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzUUID (engine-backed UUID v4).
# Converted from the classic `? expr #--> <a specific uuid>` files, whose
# expected values were necessarily one-off random samples. A UUID suite
# must assert FORMAT + INVARIANTS (version, variant, validity) and, above
# all, UNIQUENESS across many generations -- not exact values.

Scenario("A generated UUID has the v4 format and metadata")
    Given("a fresh stzUUID")
    oU = new stzUUID()
    cId = oU.Content()
    Then("it is 36 chars (8-4-4-4-12 + hyphens)", StzLen(cId), 36)
    Then("it is hyphenated", StzFindFirst("-", cId) > 0, TRUE)
    Then("the version nibble (pos 15) is '4'", cId[15], "4")
    Then("Version() is 4", oU.Version(), 4)
    Then("Variant() is RFC 4122", oU.Variant(), "RFC 4122")
    Then("it is not the nil UUID", oU.IsNull(), FALSE)
    Then("it validates", oU.IsValid(), TRUE)
EndScenario()

Scenario("WithoutHyphens drops the dashes")
    Given("a fresh stzUUID")
    oU2 = new stzUUID()
    cBare = oU2.WithoutHyphens()
    Then("the bare form is 32 chars", StzLen(cBare), 32)
    Then("the bare form has no hyphens", StzFindFirst("-", cBare), 0)
EndScenario()

Scenario("The nil UUID and validity checks")
    Given("the nil UUID")
    cNil = NullUuid()
    Then("nil is all-zero canonical form",
        cNil, "00000000-0000-0000-0000-000000000000")
    Then("a real UUID string validates", IsValidUuid(Uuid()), TRUE)
    Then("plain text does not validate", IsValidUuid("Ring"), FALSE)
    Then("a malformed string does not validate",
        IsValidUuid("12345-not-a-uuid"), FALSE)
EndScenario()

Scenario("UUIDs are unique and well-formed across many generations")
    Given("500 freshly generated UUIDs")
    nN = 500
    aAll = []
    nCollisions = 0
    nBadLen = 0
    nBadVer = 0
    nInvalid = 0
    for _i_ = 1 to nN
        cId = Uuid()
        if find(aAll, cId) > 0 nCollisions++ ok
        aAll + cId
        if StzLen(cId) != 36 nBadLen++ ok
        if cId[15] != "4" nBadVer++ ok
        if NOT IsValidUuid(cId) nInvalid++ ok
    next
    Then("no two collided (all 500 unique)", nCollisions, 0)
    Then("all were 36 chars", nBadLen, 0)
    Then("all were version 4", nBadVer, 0)
    Then("all validated", nInvalid, 0)
EndScenario()

Summary()
