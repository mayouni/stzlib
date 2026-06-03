# Narrative
# --------
# # EXAMPLE 13: Node Shapes Gallery               #
#
# Extracted from stzdotcodetest.ring, block #20.

load "../../stzBase.ring"

# Learn: Different node shapes, styling basics  #
#-----------------------------------------------#

pr()

Dot = XDot()
Dot.SetCode('
digraph NodeShapes {
    graph [rankdir=LR, bgcolor=white, splines=ortho]
    node [style=filled, fontname="Arial"]
    
    # Basic shapes
    box [shape=box, fillcolor=lightblue, label="box"]
    circle [shape=circle, fillcolor=lightgreen, label="circle"]
    ellipse [shape=ellipse, fillcolor=lightyellow, label="ellipse"]
    diamond [shape=diamond, fillcolor=pink, label="diamond"]
    
    # Polygon shapes
    pentagon [shape=pentagon, fillcolor=lavender, label="pentagon"]
    hexagon [shape=hexagon, fillcolor=lightcoral, label="hexagon"]
    octagon [shape=octagon, fillcolor=lightgray, label="octagon"]
    
    # Special shapes
    record [shape=record, fillcolor=wheat, label="{Record|{Left|Right}}"]
    note [shape=note, fillcolor=lightyellow, label="note"]
    tab [shape=tab, fillcolor=lightsteelblue, label="tab"]
    
    # Flow chart shapes
    start [shape=circle, fillcolor=green, fontcolor=white, label="Start"]
    process [shape=box, fillcolor=skyblue, label="Process"]
    decision [shape=diamond, fillcolor=gold, label="Decision?"]
    end [shape=doublecircle, fillcolor=red, fontcolor=white, label="End"]
    
    # Connect them in logical groups
    {box, circle, ellipse, diamond} -> pentagon [style=invis]
    pentagon -> {hexagon, octagon} [style=invis]
    {record, note, tab} -> start [style=invis]
    start -> process -> decision -> end
}
')

Dot.SetOutputFormat("svg")
Dot.ExecuteAndView()

pf()
# Executed in 0.62 second(s) in Ring 1.24
