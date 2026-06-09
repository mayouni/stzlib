# Narrative
# --------
# APPROVAL WORKFLOW VISUALIZATION
#
# Extracted from stzdiagramtest.ring, block #55.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

oDiag = new stzDiagram("ExpenseApproval")
oDiag {
    SetTheme(:neutral)
    
    # Build structure
    AddNodeXTT("submit", "Submit", [:type = "start"])
    AddNodeXTT("manager", "Manager", [:type = "decision"])
    AddNodeXTT("process", "Process", [:type = "process"])
    
    Connect("submit", "manager")
    Connect("manager", "process")
    
    # VISUAL RULES ONLY
    RegisterVisualRule("DECISION_HIGHLIGHT", [
        :conditionType = "property_equals",
        :conditionParams = ["type", "decision"],
        :effects = [
            ["color", "orange"],
            ["penwidth", 2]
        ]
    ])
    
    ApplyVisualRules()
    
    # Rendering metrics (not validation)
    ? "Nodes rendered: " + NodeCount()
    ? "Visual rules applied: " + len(VisualRulesApplied())
    
    View()
}

pf()
# Executed in 0.59 second(s) in Ring 1.25
