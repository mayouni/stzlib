load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzListOfNumbers.
# Converted from the classic `? expr #--> expected` files in this dir to
# asserting GIVEN/WHEN/THEN form. Deterministic ops assert exact values;
# the random ops assert INVARIANTS over many draws (their old #--> values
# were stale) -- see the last scenario.

Scenario("Construction, type, and basic statistics")
    Given("a list of 1..5")
    o = NumsOf(1:5)
    Then("StzType is stzlistofnumbers", lower(o.StzType()), "stzlistofnumbers")
    Then("Min is 1",     o.Min(), 1)
    Then("Max is 5",     o.Max(), 5)
    Then("Sum is 15",    o.Sum(), 15)
    Then("Average is 3", o.Average(), 3)
EndScenario()

Scenario("Smallest and largest N numbers")
    Given("an unsorted list 2,7,3,10,5,4,9,1,6,8")
    o = NumsOf([ 2, 7, 3, 10, 5, 4, 9, 1, 6, 8 ])
    Then("NSmallestNumbers(3) = [1,2,3]", ListEq(o.NSmallestNumbers(3), [ 1, 2, 3 ]), TRUE)
    Then("NLargestNumbers(3) = [8,9,10]", ListEq(o.NLargestNumbers(3), [ 8, 9, 10 ]), TRUE)
EndScenario()

Scenario("Threshold filters")
    Given("a list of 1..5")
    o = NumsOf(1:5)
    Then("NumbersGreaterThan(3) = [4,5]",  ListEq(o.NumbersGreaterThan(3), [ 4, 5 ]), TRUE)
    Then("NumbersLessThan(3) = [1,2]",     ListEq(o.NumbersLessThan(3), [ 1, 2 ]), TRUE)
    Then("NumbersOtherThan(3) = [1,2,4,5]", ListEq(o.NumbersOtherThan(3), [ 1, 2, 4, 5 ]), TRUE)
EndScenario()

Scenario("Consecutive differences")
    Given("the list 8,12,14,18,20,24")
    o = NumsOf([ 8, 12, 14, 18, 20, 24 ])
    Then("Diffs() = [4,2,4,2,4]", ListEq(o.Diffs(), [ 4, 2, 4, 2, 4 ]), TRUE)
EndScenario()

Scenario("Distinct step sizes")
    Given("the list 1,2,5,6,9,10")
    o = NumsOf([ 1, 2, 5, 6, 9, 10 ])
    Then("Steps() = [1,3]", ListEq(o.Steps(), [ 1, 3 ]), TRUE)
EndScenario()

Scenario("Nearest value lookups")
    Given("the list 2,7,18,18,10,12,25,4")
    o = NumsOf([ 2, 7, 18, 18, 10, 12, 25, 4 ])
    Then("Nearest(88) = 25",   o.Nearest(88), 25)
    Then("NearestTo(10) = 12", o.NearestTo(10), 12)
    Then("Nearest(:To=12) = 10", o.Nearest(:To = 12), 10)
EndScenario()

Scenario("Left/right neighbors")
    Given("the list 2,7,18,18,10,25,4")
    o = NumsOf([ 2, 7, 18, 18, 10, 25, 4 ])
    Then("Neighbors(10) = [7,18]", ListEq(o.Neighbors(10), [ 7, 18 ]), TRUE)
EndScenario()

Scenario("Sign-mix detection")
    Given("an all-positive list")
    o = NumsOf([ 1, 5, 7, 9 ])
    Then("no sign mix", o.ContainsPositiveAndNegativeNumbers(), FALSE)
    When("a list mixes signs")
    o = NumsOf([ 1, 5, -7, 9 ])
    Then("sign mix detected", o.ContainsPositiveAndNegativeNumbers(), TRUE)
EndScenario()

Scenario("Global reduction helpers")
    Given("plain Ring number lists")
    Then("Divide([12,2,3]) = 2",   Divide([ 12, 2, 3 ]), 2)
    Then("Multiply([10,2,3]) = 60", Multiply([ 10, 2, 3 ]), 60)
    Then("Sum([10,2,4]) = 16",     Sum([ 10, 2, 4 ]), 16)
    Then("@Min([2,4]) = 2",        @Min([ 2, 4 ]), 2)
    Then("@Max([2,4]) = 4",        @Max([ 2, 4 ]), 4)
EndScenario()

Scenario("Random draws hold their invariants over many runs")
    Given("50 draws of NRandomNumbers(3) from 1..10")
    nRuns = 50
    nBadLen = 0
    nOutOfRange = 0
    aSeen = []
    for _i_ = 1 to nRuns
        aR = NumsOf(1:10).NRandomNumbers(3)
        if len(aR) != 3 nBadLen++ ok
        nJ = len(aR)
        for _j_ = 1 to nJ
            if aR[_j_] < 1 or aR[_j_] > 10 nOutOfRange++ ok
            if find(aSeen, aR[_j_]) = 0 aSeen + aR[_j_] ok
        next
    next
    Then("every draw had length 3", nBadLen, 0)
    Then("every value stayed within 1..10", nOutOfRange, 0)
    Then("more than one distinct value appeared (RNG not stuck)",
        len(aSeen) > 1, TRUE)

    Given("50 draws of NRandomNumbersIn(3, 1:10)")
    nOOR2 = 0
    for _i_ = 1 to nRuns
        aR = NRandomNumbersIn(3, 1:10)
        if len(aR) != 3 nBadLen++ ok
        nJ = len(aR)
        for _j_ = 1 to nJ
            if aR[_j_] < 1 or aR[_j_] > 10 nOOR2++ ok
        next
    next
    Then("NRandomNumbersIn lengths all 3", nBadLen, 0)
    Then("NRandomNumbersIn values all in 1..10", nOOR2, 0)
EndScenario()

Summary()

func NumsOf aList
    return new stzListOfNumbers(aList)

func ListEq aA, aE
    if NOT (isList(aA) and isList(aE)) return FALSE ok
    if len(aA) != len(aE) return FALSE ok
    nL = len(aA)
    for i = 1 to nL
        if NOT (aA[i] = aE[i]) return FALSE ok
    next
    return TRUE
