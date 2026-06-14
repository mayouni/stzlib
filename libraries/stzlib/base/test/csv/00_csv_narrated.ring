load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for the CSV helpers (module-level funcs,
# no class): CSVSeparator/SetCSVSeparator, IsCSV, CSVToList (column-major),
# ListToCSV. The separator is global mutable state -- the suite sets it
# explicitly and restores the default. Deterministic.

Scenario("The CSV separator setting")
    Then("the default separator is ';'", CSVSeparator(), ";")
    When("set to ','")
    SetCSVSeparator(",")
    Then("',' sticks", CSVSeparator(), ",")
    When("set back to ';'")
    SetCSVSeparator(";")
    Then("';' sticks", CSVSeparator(), ";")
EndScenario()

Scenario("Recognise CSV text")
    Given("comma-separated input and the ',' separator")
    SetCSVSeparator(",")
    cStr = "name,age" + nl + "Ali,35" + nl + "Dania,28"
    Then("well-formed CSV is recognised", IsCSV(cStr), TRUE)
    Then("a plain sentence is not CSV", IsCSV("just a sentence"), FALSE)
EndScenario()

Scenario("Parse CSV to a column-major list")
    Given("comma-separated input")
    SetCSVSeparator(",")
    cStr = "name,age" + nl + "Ali,35" + nl + "Dania,28"
    Then("CSVToList groups values under each header", ListEq(CSVToList(cStr), [ [ "name", [ "Ali", "Dania" ] ], [ "age", [ 35, 28 ] ] ]), TRUE)
EndScenario()

Scenario("Emit CSV from a column-major list")
    Given("a 2-column sample and the ',' separator")
    SetCSVSeparator(",")
    aSample = [ [ "NAME", [ "Ali", "Dania" ] ], [ "AGE", [ 35, 28 ] ] ]
    Then("ListToCSV emits header + rows", ListToCSV(aSample), "NAME,AGE" + nl + "Ali,35" + nl + "Dania,28")
EndScenario()

# restore the default separator for any later loaders
SetCSVSeparator(";")

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
