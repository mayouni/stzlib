load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzListOfHashLists -- a list of
# hashlists (records). Deterministic.

Scenario("Construct and inspect a list of records")
    Given("3 name/age records")
    o = Lhl([ [ [ "name", "Ali" ], [ "age", 35 ] ], [ [ "name", "Dania" ], [ "age", 28 ] ], [ [ "name", "Han" ], [ "age", 42 ] ] ])
    Then("NumberOfItems is 3", o.NumberOfItems(), 3)
    Then("IsEmpty is FALSE", o.IsEmpty(), FALSE)
    Then("Content has 3 records", len(o.Content()), 3)
    Then("ListOfHashLists alias also has 3", len(o.ListOfHashLists()), 3)
EndScenario()

Scenario("Convert records to stzHashList objects")
    Given("the same 3 records")
    o = Lhl([ [ [ "name", "Ali" ], [ "age", 35 ] ], [ [ "name", "Dania" ], [ "age", 28 ] ], [ [ "name", "Han" ], [ "age", 42 ] ] ])
    aS = o.ToListOfStzHashLists()
    Then("it yields 3 objects", len(aS), 3)
    Then("each is a stzhashlist", ring_classname(aS[1]), "stzhashlist")
    Then("record 1 has the 'name' key", aS[1].HasKey("name"), TRUE)
    Then("record 2 name is Dania", aS[2]["name"], "Dania")
    Then("record 3 age is 42", aS[3]["age"], 42)
EndScenario()

Scenario("Empty list edge case")
    Given("an empty list of hashlists")
    e = Lhl([])
    Then("IsEmpty is TRUE", e.IsEmpty(), TRUE)
    Then("NumberOfItems is 0", e.NumberOfItems(), 0)
    Then("Content is empty", len(e.Content()), 0)
EndScenario()

Summary()

func Lhl aList
    return new stzListOfHashLists(aList)
