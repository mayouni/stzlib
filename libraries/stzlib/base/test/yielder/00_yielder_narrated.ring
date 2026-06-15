load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzYielder (named Map / Filter / Reduce
# transforms over a numeric list). Deterministic.

Scenario("Map applies a named transform to every item")
    Given("a yielder over [1,-2,3,-4,5]")
    o = new stzYielder([ 1, -2, 3, -4, 5 ])
    Then("Map(:Abs) takes absolute values", ListEq(o.Map(:Abs), [ 1, 2, 3, 4, 5 ]), TRUE)
    Then("Map(:Negate) flips signs", ListEq(o.Map(:Negate), [ -1, 2, -3, 4, -5 ]), TRUE)
    Then("Map(:Double) doubles", ListEq(o.Map(:Double), [ 2, -4, 6, -8, 10 ]), TRUE)
    Then("Map(:Square) squares", ListEq(o.Map(:Square), [ 1, 4, 9, 16, 25 ]), TRUE)
EndScenario()

Scenario("Filter keeps items matching a named predicate")
    Given("the same yielder")
    o = new stzYielder([ 1, -2, 3, -4, 5 ])
    Then("Filter(:IsPositive) keeps positives", ListEq(o.Filter(:IsPositive), [ 1, 3, 5 ]), TRUE)
    Then("Filter(:IsNegative) keeps negatives", ListEq(o.Filter(:IsNegative), [ -2, -4 ]), TRUE)
    Then("Filter(:IsEven) keeps evens", ListEq(o.Filter(:IsEven), [ -2, -4 ]), TRUE)
EndScenario()

Scenario("Reduce folds the items")
    Given("a yielder over [1,2,3,4,5]")
    o = new stzYielder([ 1, 2, 3, 4, 5 ])
    Then("Reduce(:Sum) totals 15", o.Reduce(:Sum), 15)
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
