# Narrative
# --------
# # EXAMPLE 18: Color Schemes                  #
#
# Extracted from stzdotcodetest.ring, block #25.

load "../../stzBase.ring"

# Learn: Color schemes, gradients, palettes  #
#--------------------------------------------#

#TODO Use DOR natiuve palettes instead of Softanza-made color themes
# in stzDiagram class

pr()

Dot = XDot()
Dot.SetCode('
digraph ColorSchemes {
    graph [rankdir=LR, bgcolor=gray95]
    node [shape=box, style="rounded,filled", fontname="Arial", width=1.2]
    
    # Blues scheme
    subgraph cluster_blues {
        label="Blues Palette"
        style=filled
        fillcolor=white
        
        node [colorscheme=blues9]
        b1 [fillcolor=1, label="1"]
        b3 [fillcolor=3, label="3"]
        b5 [fillcolor=5, label="5"]
        b7 [fillcolor=7, label="7", fontcolor=white]
        b9 [fillcolor=9, label="9", fontcolor=white]
        
        b1 -> b3 -> b5 -> b7 -> b9 [style=invis]
    }
    
    # Reds scheme
    subgraph cluster_reds {
        label="Reds Palette"
        style=filled
        fillcolor=white
        
        node [colorscheme=reds9]
        r1 [fillcolor=1, label="1"]
        r3 [fillcolor=3, label="3"]
        r5 [fillcolor=5, label="5"]
        r7 [fillcolor=7, label="7", fontcolor=white]
        r9 [fillcolor=9, label="9", fontcolor=white]
        
        r1 -> r3 -> r5 -> r7 -> r9 [style=invis]
    }
    
    # Greens scheme
    subgraph cluster_greens {
        label="Greens Palette"
        style=filled
        fillcolor=white
        
        node [colorscheme=greens9]
        g1 [fillcolor=1, label="1"]
        g3 [fillcolor=3, label="3"]
        g5 [fillcolor=5, label="5"]
        g7 [fillcolor=7, label="7", fontcolor=white]
        g9 [fillcolor=9, label="9", fontcolor=white]
        
        g1 -> g3 -> g5 -> g7 -> g9 [style=invis]
    }
}
')

Dot.SetOutputFormat("svg")
Dot.ExecuteAndView()

? Dot.Duration()
#--> 0.92 second(s)

pf()
# Executed in 1.48 second(s) in Ring 1.24
