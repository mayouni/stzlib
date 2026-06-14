load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzList2D -- a 2D list (rows x cols)
# whose headline operation is transposition. Deterministic.

Scenario("Hold a 2D list verbatim")
    Given("a 2-row, 3-col list")
    o = L2D([ [ "A", "B", "C" ], [ 10, 20, 30 ] ])
    Then("Content() returns it unchanged", ListEq(o.Content(), [ [ "A", "B", "C" ], [ 10, 20, 30 ] ]), TRUE)
EndScenario()

Scenario("Transpose rows and columns")
    Given("the same 2x3 list")
    o = L2D([ [ "A", "B", "C" ], [ 10, 20, 30 ] ])
    Then("Transposed() yields a 3x2 list", ListEq(o.Transposed(), [ [ "A", 10 ], [ "B", 20 ], [ "C", 30 ] ]), TRUE)
    Then("Transposed() leaves the source intact", ListEq(o.Content(), [ [ "A", "B", "C" ], [ 10, 20, 30 ] ]), TRUE)
    When("TransposeQ() mutates in place")
    o.TransposeQ()
    Then("Content() is now the transposed form", ListEq(o.Content(), [ [ "A", 10 ], [ "B", 20 ], [ "C", 30 ] ]), TRUE)
EndScenario()

Scenario("Transposition is an involution")
    Given("an arbitrary 3x2 list")
    aSrc = [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ] ]
    Then("transposing twice returns the original", ListEq(L2D(L2D(aSrc).Transposed()).Transposed(), aSrc), TRUE)
EndScenario()

Scenario("The global Transpose() helper")
    Then("Transpose() matches the object form", ListEq(Transpose([ [ "A", "B", "C" ], [ 10, 20, 30 ] ]), [ [ "A", 10 ], [ "B", 20 ], [ "C", 30 ] ]), TRUE)
EndScenario()

Summary()

func L2D aList
    return new stzList2D(aList)

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
