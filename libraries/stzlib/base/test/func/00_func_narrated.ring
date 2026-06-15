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

Summary()
