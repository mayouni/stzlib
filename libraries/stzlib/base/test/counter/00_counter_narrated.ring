load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzCounter -- a cyclic counter
# (start / skip-or-reach / restart / step). Converted from the classic
# files in this dir; all deterministic.

Scenario("Skip after 9, restart at 0")
    Given("a counter 1.. that restarts at 0 after 9")
    oC = Ctr([ :StartAt = 1, :AfterYouSkip = 9, :RestartAt = 0, :Step = 1 ])
    Then("Counting(:To=13) cycles 1..9,0,1,2,3",
        ListEq(oC.Counting(:To = 13), [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3 ]), TRUE)
    Then("the last counted value is 3",
        oC.CountingXT(:To = 13, :AndReturning = :Last), 3)
EndScenario()

Scenario("When you reach 5, restart at 1")
    Given("a counter 1.. that restarts at 1 when it reaches 5")
    oC2 = Ctr([ :StartAt = 1, :WhenYouReach = 5, :RestartAt = 1 ])
    Then("CountTo(9) = 1,2,3,4,1,2,3,4,1",
        ListEq(oC2.CountTo(9), [ 1, 2, 3, 4, 1, 2, 3, 4, 1 ]), TRUE)
    Then("the 7th counted value is 3", oC2.CountToXT(9, :ReturnNth = 7), 3)
EndScenario()

Scenario("When you reach 5, restart at 2")
    Given("a counter 1.. that restarts at 2 when it reaches 5")
    oC3 = Ctr([ :StartAt = 1, :WhenYouReach = 5, :RestartAt = 2 ])
    Then("CountTo(9) = 1,2,3,4,2,3,4,2,3",
        ListEq(oC3.CountTo(9), [ 1, 2, 3, 4, 2, 3, 4, 2, 3 ]), TRUE)
    Then("the 7th counted value is 4", oC3.CountToXT(9, :ReturnNth = 7), 4)
EndScenario()

Scenario("CountToQ yields a sequence object at scale")
    Given("a 1..4 cyclic counter counted to 1000")
    oC4 = Ctr([ :StartAt = 1, :WhenYouReach = 4, :RestartAt = 1 ])
    oSeq = oC4.CountToQ(1000)
    Then("the sequence length is 1000", oSeq.Count(), 1000)
    Then("the first value is 1", oSeq.First(), 1)
    Then("the second value is 2", oSeq.At(2), 2)
EndScenario()

Summary()

func Ctr aOpts
    return new stzCounter(aOpts)

func ListEq aA, aE
    if NOT (isList(aA) and isList(aE)) return FALSE ok
    if len(aA) != len(aE) return FALSE ok
    nL = len(aA)
    for i = 1 to nL
        if NOT (aA[i] = aE[i]) return FALSE ok
    next
    return TRUE
