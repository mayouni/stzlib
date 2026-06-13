load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("iif handles boolean and string-expression inputs")
    Given("a true numeric condition")
    Then("the TRUE branch returns", iif(1, "yes", "no"), "yes")
    Given("a false numeric condition")
    Then("the FALSE branch returns", iif(0, "yes", "no"), "no")
    Given("a string equality expression that holds")
    Then("eval branch returns TRUE arm", iif("1 = 1", "T", "F"), "T")
    Given("a string inequality expression")
    Then("eval branch returns FALSE arm", iif("2 = 3", "T", "F"), "F")
EndScenario()

Scenario("Length() forwarder delegates to Ring len()")
    Then("list length", Length([1, 2, 3]), 3)
    Then("string byte length", Length("abc"), 3)
EndScenario()

Scenario("range0 follows Python end-exclusive semantics")
    Then("range0(3) = [0..2]", @@(range0(3)), "[ 0, 1, 2 ]")
    Then("range0([1, 4]) = [1..3]", @@(range0([1, 4])), "[ 1, 2, 3 ]")
    Then("range0([1, 6, 2]) steps by 2", @@(range0([1, 6, 2])), "[ 1, 3, 5 ]")
    Then("range0([5, 1, -1]) walks backward", @@(range0([5, 1, -1])), "[ 5, 4, 3, 2 ]")
EndScenario()

Scenario("range1 is 1-based and end-inclusive")
    Then("range1(3) = [1..3]", @@(range1(3)), "[ 1, 2, 3 ]")
    Then("range1([2, 5]) = [2..5]", @@(range1([2, 5])), "[ 2, 3, 4, 5 ]")
EndScenario()

Summary()
