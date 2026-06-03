# Narrative
# --------
# # EXAMPLE 22: Timeline/Gantt-style         #
#
# Extracted from stzdotcodetest.ring, block #29.

load "../../stzBase.ring"

# Learn: Creative use of ranks and shapes  #
#------------------------------------------#

pr()

#TODO Review the sample: not so accurate!

Dot = XDot()
Dot.SetCode('
digraph Timeline {
    graph [rankdir=LR, bgcolor=white, splines=line]
    node [fontname="Arial", shape=box, style="rounded,filled"]
    edge [arrowhead=none, penwidth=2]
    
    # Time markers
    {rank=same; t1, t2, t3, t4, t5}
    node [shape=plaintext, fillcolor=none]
    t1 [label="Week 1"]
    t2 [label="Week 2"]
    t3 [label="Week 3"]
    t4 [label="Week 4"]
    t5 [label="Week 5"]
    
    t1 -> t2 -> t3 -> t4 -> t5 [style=invis]
    
    # Tasks
    node [shape=box, style="rounded,filled"]
    
    {rank=same; t1, planning}
    planning [fillcolor=lightblue, label="Planning\n& Design"]
    
    {rank=same; t2, dev1}
    dev1 [fillcolor=lightgreen, label="Development\nPhase 1"]
    
    {rank=same; t3, dev2}
    dev2 [fillcolor=lightgreen, label="Development\nPhase 2"]
    
    {rank=same; t4, testing}
    testing [fillcolor=yellow, label="Testing\n& QA"]
    
    {rank=same; t5, deploy}
    deploy [fillcolor=orange, label="Deployment\n& Launch"]
    
    # Dependencies
    planning -> dev1 [penwidth=2, color=gray40]
    dev1 -> dev2 [penwidth=2, color=gray40]
    dev2 -> testing [penwidth=2, color=gray40]
    testing -> deploy [penwidth=2, color=gray40]
}
')

Dot.SetOutputFormat("svg")
Dot.ExecuteAndView()

pf()
