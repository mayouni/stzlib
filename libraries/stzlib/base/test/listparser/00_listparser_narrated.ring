load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzListParser -- walks a list with a
# (start, end, step) parse plan, tracking the current position. Built
# outside any brace-block so Then() stays in file scope. Deterministic.

Scenario("Default parser state over A..L")
    Given("a parser over the 12-item list A..L")
    o = new stzListParser("A":"L")
    Then("List has 12 items", len(o.List()), 12)
    Then("StartPosition is 1", o.StartPosition(), 1)
    Then("EndPosition is 12", o.EndPosition(), 12)
    Then("NumberOfSteps is 1", o.NumberOfSteps(), 1)
    Then("CurrentPosition starts at 1", o.CurrentPosition(), 1)
EndScenario()

Scenario("Parse a strided range")
    Given("Parse(From=3, To=9, Step=3)")
    o = new stzListParser("A":"L")
    o.Parse( :From = 3, :To = 9, :Step = 3 )
    Then("ParsedPositions are [3,6,9]", ListEq(o.ParsedPositions(), [ 3, 6, 9 ]), TRUE)
    Then("ParsedItems are [C,F,I]", ListEq(o.ParsedItems(), [ "C", "F", "I" ]), TRUE)
    Then("CurrentItem is C (first parsed)", o.CurrentItem(), "C")
EndScenario()

Scenario("Step the cursor forward")
    Given("a parsed strided range starting at C")
    o = new stzListParser("A":"L")
    o.Parse( :From = 3, :To = 9, :Step = 3 )
    Then("NextItem advances to F", o.NextItem(), "F")
    Then("CurrentPosition is now 6", o.CurrentPosition(), 6)
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
