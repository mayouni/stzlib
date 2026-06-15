load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for Singular() (English singularisation).
# Same capture-group fix as Plural(): \1 now maps to the captured stem, so
# "cities" -> "city" instead of "citiesy".

Scenario("Regular singulars")
    Given("plural nouns")
    Then("cats -> cat", Singular("cats"), "cat")
    Then("dogs -> dog", Singular("dogs"), "dog")
EndScenario()

Scenario("Morphological stem rewrites (previously broken)")
    Given("plurals whose stem changes")
    Then("cities -> city (ies -> y)", Singular("cities"), "city")
    Then("babies -> baby", Singular("babies"), "baby")
    Then("boxes -> box (xes -> x)", Singular("boxes"), "box")
EndScenario()

Scenario("Irregular singulars")
    Given("special plurals")
    Then("children -> child", Singular("children"), "child")
    Then("men -> man", Singular("men"), "man")
EndScenario()

Summary()
