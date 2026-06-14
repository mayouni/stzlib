load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for the random helpers (stzRandom +
# stzList.Randomize). The classic files asserted one-off sample draws;
# this suite asserts INVARIANTS over many runs (range / membership /
# permutation / actually-shuffles) -- the correct way to test randomness.

Scenario("ARandomNumberBetween stays within bounds")
    Given("200 draws between 10 and 20")
    nOOR = 0
    for _i_ = 1 to 200
        x = ARandomNumberBetween(10, 20)
        if x < 10 or x > 20 nOOR++ ok
    next
    Then("every draw was within [10,20]", nOOR, 0)
EndScenario()

Scenario("random01 stays within the unit interval")
    Given("200 draws of random01()")
    nOOR = 0
    for _i_ = 1 to 200
        x = random01()
        if x < 0 or x > 1 nOOR++ ok
    next
    Then("every draw was within [0,1]", nOOR, 0)
EndScenario()

Scenario("Some() returns a subset of its source")
    Given("a source list and 100 Some() draws")
    aSrc = [ 12, 9, 10, 7, 25, 8, 3, 14 ]
    nForeign = 0
    nTooBig = 0
    for _i_ = 1 to 100
        aGot = Some(aSrc)
        if len(aGot) > len(aSrc) nTooBig++ ok
        nJ = len(aGot)
        for _j_ = 1 to nJ
            if find(aSrc, aGot[_j_]) = 0 nForeign++ ok
        next
    next
    Then("no drawn element came from outside the source", nForeign, 0)
    Then("no draw was larger than the source", nTooBig, 0)
EndScenario()

Scenario("Randomize is a true permutation")
    Given("the list 1..10 shuffled")
    o = Lst(1:10)
    o.Randomize()
    aShuf = o.Content()
    Then("the shuffle preserves length", len(aShuf), 10)
    Then("the shuffle is a permutation of 1..10",
        ListEq(sort(aShuf), 1:10), TRUE)
EndScenario()

Scenario("Randomize actually changes order across runs")
    Given("20 independent shuffles of 1..10")
    nDifferent = 0
    for _i_ = 1 to 20
        o = Lst(1:10)
        o.Randomize()
        if NOT ListEq(o.Content(), 1:10) nDifferent++ ok
    next
    Then("at least one shuffle reordered the list", nDifferent > 0, TRUE)
EndScenario()

Summary()

func Lst aList
    return new stzList(aList)

func ListEq aA, aE
    if NOT (isList(aA) and isList(aE)) return FALSE ok
    if len(aA) != len(aE) return FALSE ok
    nL = len(aA)
    for i = 1 to nL
        if NOT (aA[i] = aE[i]) return FALSE ok
    next
    return TRUE
