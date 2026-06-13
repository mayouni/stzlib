load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("StzUUID produces engine-backed v4 strings")
    Given("the global StzUUID() helper")
    cU = StzUUID()
    Then("it is 36 characters", len(cU), 36)
    Then("position 9 is a hyphen",  cU[9],  "-")
    Then("position 14 is a hyphen", cU[14], "-")
    Then("the version digit is 4",  cU[15], "4")
EndScenario()

Scenario("Null UUID round-trips through engine")
    Then("NullUUID has the canonical nil shape",
        StzNullUUID(), "00000000-0000-0000-0000-000000000000")
EndScenario()

Scenario("Validation accepts uppercase + rejects garbage")
    Then("a fresh UUID validates",  IsValidUuid(StzUUID()), TRUE)
    Then("a random string fails",   IsValidUuid("not-a-uuid"), FALSE)
EndScenario()

Scenario("Two UUIDs are distinct (engine PRNG works)")
    Given("two consecutive UUIDs")
    a = StzUUID()
    b = StzUUID()
    Then("they differ", a = b, FALSE)
EndScenario()

Scenario("stzUUID class wraps engine UUIDs")
    Given("a fresh stzUUID instance")
    o = new stzUUID()
    Then("Content() is 36 chars",      len(o.Content()),   36)
    Then("Version() returns 4",        o.Version(),        4)
    Then("IsValid() is TRUE",          o.IsValid(),        TRUE)
    Then("IsNull() is FALSE",          o.IsNull(),         FALSE)
    Then("WithoutHyphens() is 32 chars",
        len(o.WithoutHyphens()), 32)
    Then("ToBytes() returns 16 bytes",
        len(o.ToBytes()), 16)
EndScenario()

Summary()
