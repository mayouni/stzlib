load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzOrgChart -- positions (executive/
# manager/staff), reporting edges, people assignment and vacancy tracking.
# Deterministic. Objects are built outside any brace-block so Then() stays
# in file scope.

Scenario("Build a reporting hierarchy")
    Given("a CEO, a VP and two devs reporting upward")
    o = new stzOrgChart("TechCo")
    o.AddExecutiveXT(:@ceo, "CEO")
    o.AddManagerXT(:@vp_eng, "VP Engineering")
    o.AddStaffXT(:@dev1, "Senior Dev")
    o.AddStaffXT(:@dev2, "Junior Dev")
    o.ReportsTo(:@vp_eng, :@ceo)
    o.ReportsTo(:@dev1, :@vp_eng)
    o.ReportsTo(:@dev2, :@vp_eng)
    Then("NodeCount is 4", o.NodeCount(), 4)
    Then("EdgeCount is 3", o.EdgeCount(), 3)
    Then("the VP has 2 direct reports", o.DirectReportsN(:@vp_eng), 2)
    Then("they are dev1 and dev2", ListEq(o.DirectReports(:@vp_eng), [ "@dev1", "@dev2" ]), TRUE)
    Then("the CEO has 1 direct report", o.DirectReportsN(:@ceo), 1)
EndScenario()

Scenario("Vacancy tracking and assignment")
    Given("3 positions, all initially vacant")
    o = new stzOrgChart("TechCo")
    o.AddExecutiveXT(:@ceo, "CEO")
    o.AddManagerXT(:@vp1, "VP Sales")
    o.AddStaffXT(:@dev1, "Developer")
    Then("all 3 positions are vacant", ListEq(o.VacantPositions(), [ "@ceo", "@vp1", "@dev1" ]), TRUE)
    Then("VacancyRate is 100", o.VacancyRate(), 100)
    When("Alice is assigned to the CEO position")
    o.AddPersonXT(:@alice, "Alice")
    o.Assign(:@alice, :ToNode = :@ceo)
    Then("only vp1 and dev1 remain vacant", ListEq(o.VacantPositions(), [ "@vp1", "@dev1" ]), TRUE)
    Then("VacancyRate drops to ~66.67", Rnd2(o.VacancyRate()), 66.67)
    Then("Alice's position is @ceo", PersonField(o, :@alice, "position"), "@ceo")
EndScenario()

Summary()

func PersonField o, cId, cField
    aData = o.PersonData(cId)
    nLen = len(aData)
    for i = 1 to nLen
        if aData[i][1] = cField return aData[i][2] ok
    next
    return ""

func Rnd2 n
    return floor(n * 100 + 0.5) / 100

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
