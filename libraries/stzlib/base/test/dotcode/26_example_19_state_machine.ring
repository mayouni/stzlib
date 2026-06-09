# Narrative
# --------
# # EXAMPLE 19: State Machine                          #
#
# Extracted from stzdotcodetest.ring, block #26.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Learn: Practical application of shapes and styles  #
#----------------------------------------------------#

#TODO Learn from this sample in stzWorkflow and stzStateMachineWorkflow

pr()

Dot = XDot()
Dot.SetCode('
digraph StateMachine {
    graph [rankdir=LR, bgcolor=white, fontname="Arial"]
    node [fontname="Arial", style=filled]
    edge [fontname="Arial", fontsize=10]
    
    # Special states
    start [shape=circle, fillcolor=black, width=0.3, label=""]
    end [shape=doublecircle, fillcolor=black, width=0.3, label=""]
    
    # Regular states
    idle [shape=circle, fillcolor=lightblue, label="Idle"]
    processing [shape=circle, fillcolor=yellow, label="Processing"]
    waiting [shape=circle, fillcolor=orange, label="Waiting"]
    complete [shape=circle, fillcolor=lightgreen, label="Complete"]
    error [shape=circle, fillcolor=red, fontcolor=white, label="Error"]
    
    # Transitions
    start -> idle [label="init"]
    idle -> processing [label="start()"]
    processing -> waiting [label="wait_for_input()"]
    processing -> complete [label="success"]
    processing -> error [label="exception"]
    waiting -> processing [label="input_received()"]
    waiting -> error [label="timeout"]
    error -> idle [label="retry()", style=dashed]
    complete -> end [label="finalize"]
    
    # Self-loop
    idle -> idle [label="ping()", style=dotted]
}
')

Dot.SetOutputFormat("svg")
Dot.ExecuteAndView()
? Dot.Duration()
#--> 0.95

pf()
# Executed in 0.46 second(s) in Ring 1.24
