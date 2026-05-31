# Narrative
# --------
# Color high performers
#
# Extracted from stzorgcharttest.ring, block #32.

load "../../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddManagerXT("mgr", "Manager")
    AddStaffXT("dev1", "Dev 1")
    AddStaffXT("dev2", "Dev 2")
    
    ReportsTo("dev1", "mgr")
    ReportsTo("dev2", "mgr")

    SetNodeProperty("dev1", "performance", 85)
    SetNodeProperty("dev2", "performance", 65)
    
    oRule = new stzGraphRule("highlight_high") #ERR  class not found!
    oRule {
        SetRuleType("visual")
        When("performance", "greaterthan", 80)
        Then("color", "set", "gold")
    }
    
    SetRule(oRule)
    ApplyVisualRules() #ERR has no effect!
    
    ? @@( NodesAffectedByRules() ) #--> ["dev1"]
    #ERR returned all the nodes! [ "mgr", "dev1", "dev2" ]
    View() // #ERR Must show dev1 in gold, dev2 in default color
}

pf()

#==========================#
#  ORGANIZATIONAL CHANGES  #
#==========================#
