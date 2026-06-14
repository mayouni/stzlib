load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzTimeLines -- a set of named lanes
# over a global [start,end] window. Deterministic (fixed dates). Lane
# labels are normalised to uppercase on store.

Scenario("Create timelines with explicit start/end")
    Given("a 2-lane timeline spanning all of 2024")
    o = Tl([ :Lanes = [ "Team A", "Team B" ], :Start = "2024-01-01 00:00:00", :End = "2024-12-31 23:59:59" ])
    Then("GlobalStart is the window start", o.GlobalStart(), "2024-01-01 00:00:00")
    Then("GlobalEnd is the window end", o.GlobalEnd(), "2024-12-31 23:59:59")
    Then("Duration is the span in seconds", o.Duration(), 31622399)
    Then("DurationQ().ToHuman() reads '1 year'", o.DurationQ().ToHuman(), "1 year")
    Then("NumberOfLanes is 2", o.NumberOfLanes(), 2)
    Then("Lanes are stored uppercased", ListEq(o.Lanes(), [ "TEAM A", "TEAM B" ]), TRUE)
EndScenario()

Scenario("Create timelines with a date-only boundary")
    Given("From a bare date, To a full timestamp")
    o = Tl([ :Lanes = [ "Dev", "QA" ], :From = "2024-10-10", :To = "2024-10-22 16:40:00" ])
    Then("the bare 'From' date gains a 00:00:00 time", o.GlobalStart(), "2024-10-10 00:00:00")
    Then("the 'To' timestamp is kept verbatim", o.GlobalEnd(), "2024-10-22 16:40:00")
    Then("lanes are uppercased here too", ListEq(o.Lanes(), [ "DEV", "QA" ]), TRUE)
EndScenario()

Summary()

func Tl aOpts
    return new stzTimeLines(aOpts)

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
