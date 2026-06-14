load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzDataWrangler -- list data cleaning
# transformations (trim / dedupe / case / missing-value handling). Mutating
# methods rewrite the wrangler's data, read back via GetData(). Deterministic.

Scenario("Trim whitespace")
    Given("values with surrounding spaces")
    o = Dw([ "John", "  Mary  ", " Bob" ])
    o.TrimWhitespace()
    Then("whitespace is stripped", ListEq(o.GetData(), [ "John", "Mary", "Bob" ]), TRUE)
EndScenario()

Scenario("Remove duplicates")
    Given("values with repeats")
    o = Dw([ "John", "Mary", "Bob", "John", "Mary" ])
    o.RemoveDuplicates()
    Then("only first occurrences remain", ListEq(o.GetData(), [ "John", "Mary", "Bob" ]), TRUE)
EndScenario()

Scenario("Normalize case")
    Given("mixed-case values")
    o = Dw([ "John", "BOB", "alice" ])
    o.NormalizeCase("lower")
    Then("lower-casing", ListEq(o.GetData(), [ "john", "bob", "alice" ]), TRUE)
    u = Dw([ "abc", "def" ])
    u.NormalizeCase("upper")
    Then("upper-casing", ListEq(u.GetData(), [ "ABC", "DEF" ]), TRUE)
EndScenario()

Scenario("Handle missing values")
    Given("values with '' and 'NULL' placeholders")
    o = Dw([ "John", "", "NULL", "Mary" ])
    o.HandleMissingValues("remove")
    Then("missing entries are dropped", ListEq(o.GetData(), [ "John", "Mary" ]), TRUE)
EndScenario()

Scenario("A full cleaning pipeline")
    Given("messy data: spaces, dupes, mixed case")
    o = Dw([ "John", "  Mary  ", "BOB", "alice", "John" ])
    o.TrimWhitespace()
    o.RemoveDuplicates()
    o.NormalizeCase("lower")
    Then("the chained transforms yield clean, unique, lowercase data", ListEq(o.GetData(), [ "john", "mary", "bob", "alice" ]), TRUE)
EndScenario()

Summary()

func Dw aList
    return new stzDataWrangler(aList, [])

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
