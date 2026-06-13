load "../../stzBase.ring"
load "../_narrated.ring"

# Narrated form of 50_extercode_smoke.ring. Same coverage,
# structured output. Demonstrates the GIVEN/WHEN/THEN runner.

Scenario("stzExterCode supports the canonical language registry")
    Given("a fresh stzExterCode handle in python mode")
    o = new stzExterCode(:python)
    Then("python is recognized",
        o.IsLanguageSupported("python"), TRUE)
    Then("the lookup is case-insensitive",
        o.IsLanguageSupported("PYTHON"), TRUE)
    Then("an unknown language is rejected",
        o.IsLanguageSupported("ringx"), FALSE)
    Then("R is registered",      o.IsLanguageSupported("R"),      TRUE)
    Then("julia is registered",  o.IsLanguageSupported("julia"),  TRUE)
    Then("prolog is registered", o.IsLanguageSupported("prolog"), TRUE)
    Then("c is registered",      o.IsLanguageSupported("c"),      TRUE)
    Then("nodejs is registered", o.IsLanguageSupported("nodejs"), TRUE)
EndScenario()

Scenario("SetCode + Code is an in-memory roundtrip")
    Given("an stzExterCode with no source yet")
    o = new stzExterCode(:python)
    When("the caller sets a code body")
    o.SetCode("print(2+2)")
    Then("Code() returns the just-set source",
        o.Code(), "print(2+2)")
EndScenario()

Scenario("Thin language wrappers construct and roundtrip")
    Given("a stzPythonCode obtained via the py() factory")
    oPy = py()
    Then("the wrapper is a real object",
        isObject(oPy), TRUE)
    When("the caller sets a python expression")
    oPy.SetCode("x = 1")
    Then("Code() forwards through to the in-memory source",
        oPy.Code(), "x = 1")
EndScenario()

Summary()
