load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for misc global helpers -- the lowercase
# stz* string primitives, ring_del, the @substr swiss-army knife, and
# @Min/@Max. Deterministic.

Scenario("Lowercase string primitives")
    Then("stzlen('softanza') is 8", stzlen("softanza"), 8)
    Then("stzleft('softanza',4) is 'soft'", stzleft("softanza", 4), "soft")
    Then("stzright('softanza',4) is 'anza'", stzright("softanza", 4), "anza")
EndScenario()

Scenario("ring_del removes and returns the list")
    Given("[one, two, x, three]")
    aList = [ "one", "two", "x", "three" ]
    Then("ring_del(_,3) returns the trimmed list", ListEq(ring_del(aList, 3), [ "one", "two", "three" ]), TRUE)
    Then("and the source list is modified in place", ListEq(aList, [ "one", "two", "three" ]), TRUE)
EndScenario()

Scenario("The @substr swiss-army helper")
    Then("3-arg form replaces", @substr("one five three", "five", "two"), "one two three")
    Then("empty-new form finds the position", @substr("one two three", "two", []), 5)
    Then("numeric form slices [5..7]", @substr("one two three", 5, 7), "two")
EndScenario()

Scenario("@Min and @Max")
    Then("@Min([2,3]) is 2", @Min([ 2, 3 ]), 2)
    Then("@Max([2,3]) is 3", @Max([ 2, 3 ]), 3)
    Then("@Min([5,2,8,1]) is 1", @Min([ 5, 2, 8, 1 ]), 1)
    Then("@Max([5,2,8,1]) is 8", @Max([ 5, 2, 8, 1 ]), 8)
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
