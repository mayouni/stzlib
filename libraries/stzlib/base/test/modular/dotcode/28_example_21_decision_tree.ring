# Narrative
# --------
# # EXAMPLE 21: Decision Tree                     #
#
# Extracted from stzdotcodetest.ring, block #28.

load "../../../stzBase.ring"

# Learn: Tree structures, styling for clarity   #
#-----------------------------------------------#

pr()

Dot = XDot()
Dot.SetCode('
digraph DecisionTree {
    graph [rankdir=TB, bgcolor=white]
    node [fontname="Arial"]
    edge [fontname="Arial", fontsize=10]
    
    # Decision nodes
    node [shape=diamond, style=filled, fillcolor=lightyellow]
    root [label="Credit Score\n> 700?"]
    income [label="Annual Income\n> $50k?"]
    history [label="Payment History\nClean?"]
    
    # Outcome nodes
    node [shape=box, style="rounded,filled"]
    approve_instant [fillcolor=darkgreen, fontcolor=white, label="Approve\nInstantly"]
    approve_review [fillcolor=lightgreen, label="Approve with\nManual Review"]
    deny_income [fillcolor=orange, label="Deny\n(Low Income)"]
    deny_history [fillcolor=red, fontcolor=white, label="Deny\n(Bad History)"]
    deny_score [fillcolor=red, fontcolor=white, label="Deny\n(Low Score)"]
    
    # Tree structure
    root -> income [label="Yes", color=green]
    root -> history [label="No", color=red]
    
    income -> approve_instant [label="Yes", color=green]
    income -> deny_income [label="No", color=red]
    
    history -> approve_review [label="Yes", color=green]
    history -> deny_history [label="No", color=red]
    
    root -> deny_score [label="< 600", color=darkred, style=bold]
}
')

Dot.SetOutputFormat("svg")
Dot.ExecuteAndView()

pf()
# Executed in 1.19 second(s) in Ring 1.24
