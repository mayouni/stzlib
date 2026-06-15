load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for Adverb() (English adverb formation).
#
# Regression guards (both fixed this session):
#  - Capture-group bug: \1 mapped to the full match, so "happy" -> "happyily"
#    instead of "happily". Now maps to the captured stem.
#  - Unanchored geographic/language rules: "(asia?)" matched the "asi" inside
#    "basic" and returned "asian". Anchored to ^...$ so place/language names
#    only fire on the whole word; "basic" -> "basically" via morphology.

Scenario("Morphological adverbs (the previously-broken path)")
    Given("adjectives")
    Then("quick -> quickly", Adverb("quick"), "quickly")
    Then("happy -> happily (y -> ily)", Adverb("happy"), "happily")
    Then("easy -> easily", Adverb("easy"), "easily")
    Then("basic -> basically (ic -> ically, no longer 'asian')", Adverb("basic"), "basically")
    Then("gentle -> gently (le -> ly)", Adverb("gentle"), "gently")
    Then("careful -> carefully (ful -> fully)", Adverb("careful"), "carefully")
    Then("final -> finally (al -> ally)", Adverb("final"), "finally")
EndScenario()

Scenario("Irregular adverbs")
    Given("special adjectives")
    Then("good -> well", Adverb("good"), "well")
    Then("fast -> fast (unchanged)", Adverb("fast"), "fast")
EndScenario()

Scenario("Whole-word geographic/language forms still fire")
    Given("exact place/language names")
    Then("asia -> asian", Adverb("asia"), "asian")
    Then("africa -> african", Adverb("africa"), "african")
    Then("north -> northern", Adverb("north"), "northern")
    Then("france -> french", Adverb("france"), "french")
EndScenario()

Summary()
