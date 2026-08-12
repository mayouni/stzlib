load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for Softanza's nulliness/emptiness/
# truthiness/falsiness predicates. Deterministic.
# (Note: the classic IsTrue([])=TRUE was stale -- an empty list is now
#  falsy: IsTrue([])=FALSE and IsFalse([])=TRUE, which agree with each
#  other.)

Scenario("Nulliness -- only '' and NullObject are null")
    Then("IsNull('') is TRUE", IsNull(""), TRUE)
    Then("IsNull([]) is FALSE", IsNull([]), FALSE)
    Then("IsNull(0) is FALSE", IsNull(0), FALSE)
    Then("IsNull(NullObject()) is TRUE", IsNull(NullObject()), TRUE)
    Then("IsNull(TrueObject()) is FALSE", IsNull(TrueObject()), FALSE)
    Then("IsNull(FalseObject()) is FALSE", IsNull(FalseObject()), FALSE)
EndScenario()

Scenario("Emptiness")
    Then("IsEmpty('') is TRUE", IsEmpty(""), TRUE)
    Then("IsEmpty([]) is TRUE", IsEmpty([]), TRUE)
    Then("IsEmpty(0) is FALSE", IsEmpty(0), FALSE)
    Then("IsEmpty(NullObject()) is TRUE", IsEmpty(NullObject()), TRUE)
    Then("IsEmpty(FalseObject()) is FALSE", IsEmpty(FalseObject()), FALSE)
EndScenario()

# NOTE: plain IsTrue/IsFalse use Ring's native truthiness on primitives
# (''/0/[] falsy, non-empty truthy). They do NOT model the sentinel
# objects -- under plain IsTrue, any object is truthy. The sentinel-aware
# variants (IsTrueXT/IsFalseXT) are currently broken (R19 crash on objects,
# flagged separately), so only primitive truthiness is asserted here. The
# sentinels stay covered by the IsNull/IsEmpty scenarios above.
Scenario("Truthiness of primitives")
    Then("IsTrue('') is FALSE", IsTrue(""), FALSE)
    Then("IsTrue(0) is FALSE", IsTrue(0), FALSE)
    Then("IsTrue(123) is TRUE", IsTrue(123), TRUE)
    Then("IsTrue(-23) is TRUE", IsTrue(-23), TRUE)
    Then("IsTrue('text') is TRUE", IsTrue("text"), TRUE)
    Then("IsTrue([1,2,3]) is TRUE", IsTrue([1, 2, 3]), TRUE)
    Then("IsTrue([]) is FALSE (empty is falsy)", IsTrue([]), FALSE)
EndScenario()

Scenario("Falsiness of primitives")
    Then("IsFalse('') is TRUE", IsFalse(""), TRUE)
    Then("IsFalse(0) is TRUE", IsFalse(0), TRUE)
    Then("IsFalse(123) is FALSE", IsFalse(123), FALSE)
    Then("IsFalse('text') is FALSE", IsFalse("text"), FALSE)
    Then("IsFalse([1,2,3]) is FALSE", IsFalse([1, 2, 3]), FALSE)
    Then("IsFalse([]) is TRUE (empty is falsy)", IsFalse([]), TRUE)
EndScenario()

# The sentinel-aware extended predicates (regression: IsTrueXT/IsFalseXT
# used to crash R19 on any object; IsTrueObject was inverted via a
# copy-paste classname; the null branch was inverted -- all fixed).
Scenario("Extended truthiness recognises the sentinel objects")
    Then("IsTrueXT(TrueObject()) is TRUE", IsTrueXT(TrueObject()), TRUE)
    Then("IsTrueXT(FalseObject()) is FALSE", IsTrueXT(FalseObject()), FALSE)
    Then("IsTrueXT(NullObject()) is FALSE", IsTrueXT(NullObject()), FALSE)
    Then("IsFalseXT(FalseObject()) is TRUE", IsFalseXT(FalseObject()), TRUE)
    Then("IsFalseXT(TrueObject()) is FALSE", IsFalseXT(TrueObject()), FALSE)
    Then("IsTrueXT('Hello') is TRUE", IsTrueXT("Hello"), TRUE)
    Then("IsTrueXT('') is FALSE", IsTrueXT(""), FALSE)
    Then("IsTrueXT([]) is FALSE", IsTrueXT([]), FALSE)
EndScenario()

# Regression: the three lists that configure extended truthiness --
# $acSubStringsMakingAStringFalse, $aItemsMakingAListFalse and
# $aInnerItemsMakingAListFalse -- all default to [], and the
# ContainsOneOfTheseCS they are handed to validates with IsListOfStrings,
# which deliberately REFUSES an empty list. So the library's own defaults
# failed its own validator and IsTrueXT RAISED for every non-empty string
# and every non-empty list. This whole suite died at line 61 above.
#
# An empty configuration means "nothing marks this false" -- not an error.

Scenario("An unconfigured falsity list means nothing marks a value false")
    Given("the defaults, with no substring or item configured")
    Then("a plain string is true", IsTrueXT("Hello"), TRUE)
    Then("a plain list is true", IsTrueXT([1, 2]), TRUE)
    Then("IsFalseXT agrees (it delegates here)", IsFalseXT("Hello"), FALSE)
    Then("...and the empty cases are untouched", IsTrueXT(""), FALSE)
EndScenario()

# The negative sibling of the scenario above. If the fix had simply stopped
# consulting the lists, everything here would still answer TRUE -- so this
# is what separates "empty means no" from "the feature was switched off".
Scenario("A CONFIGURED falsity list still bites")
    Given("'no' and 'off' configured as falsity markers")
    SetSubStringsMakingAStringFalse([ "no", "off" ])
    Then("a string carrying a marker is FALSE", IsTrueXT("no way"), FALSE)
    Then("...and IsFalseXT says so", IsFalseXT("no way"), TRUE)
    Then("a string without one is still TRUE", IsTrueXT("Hello"), TRUE)
    When("the configuration is cleared again -- [] is the DEFAULT, so the")
    When("setter has to accept it; it used to refuse its own initial value")
    SetSubStringsMakingAStringFalse([])
    Then("the marker stops biting", IsTrueXT("no way"), TRUE)
    Then("...and a non-string list is still refused", NOT IsListOfStrings([ 1, 2 ]), TRUE)
EndScenario()

Summary()
