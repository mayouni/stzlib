load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for the dynamic named-variable helpers:
# Vr (name) / Vl (value) / v (read) / vxt (name+value) / VrVl (set).
# Deterministic.

Scenario("Create variables with computed names")
    Given("name1..name5 = 10..50 built in a loop")
    for i = 1 to 5 { Vr( 'name' + i ) '=' Vl( 10 * i ) }
    Then("v(:name1) is 10", v(:name1), 10)
    Then("v(:name3) is 30", v(:name3), 30)
    Then("v(:name5) is 50", v(:name5), 50)
    Then("vxt(:name3) is the name/value pair", ListEq(vxt(:name3), [ "name3", 30 ]), TRUE)
EndScenario()

Scenario("Reassign a named variable")
    Given("name3 currently 30")
    When("set to 44 via Vr/Vl")
    Vr( :name3 ) '=' Vl( 44 )
    Then("v(:name3) is 44", v(:name3), 44)
    When("set back to 30 via VrVl")
    VrVl( :name3 = 30 )
    Then("v(:name3) is 30 again", v(:name3), 30)
EndScenario()

Summary()

func ListEq aA, aE
    if len(aA) != len(aE) return FALSE ok
    nLen = len(aA)
    for i = 1 to nLen
        if isList(aA[i]) and isList(aE[i])
            if NOT ListEq(aA[i], aE[i]) return FALSE ok
        else
            if aA[i] != aE[i] return FALSE ok
        ok
    next
    return TRUE
