# Narrative
# --------
# Visual rules merging with visual rules
#
# Extracted from stzdiagramtest.ring, block #56.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("RuleMerging")
oDiag {
    AddNodeXTT("node1", "Test", [
        :priority = 10,
        :sensitive = TRUE
    ])
    
    # Multiple overlapping rules
    RegisterVisualRule("HIGH_PRIORITY", [
        :conditionType = "property_range",
        :conditionParams = ["priority", 8, 15],
        :effects = [["color", "red"], ["penwidth", 3]]
    ])
    
    RegisterVisualRule("SENSITIVE_DATA", [
        :conditionType = "property_equals",
        :conditionParams = ["sensitive", TRUE],
        :effects = [["color", "orange"], ["style", "dashed"]]
    ])
    
    ApplyVisualRules()
    
    ? "Rules applied to node1:"
    ? @@( NodesAffectedByVisualRules() )
    
    # Should show: orange (overrides red), penwidth 3, dashed style
    View()
}

pf()
# Executed in 0.59 second(s) in Ring 1.25
