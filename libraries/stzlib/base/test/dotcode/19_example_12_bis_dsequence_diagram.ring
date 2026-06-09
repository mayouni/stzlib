# Narrative
# --------
# #  Example 12 bis: DSEQUENCE DIAGRAM  #
#
# Extracted from stzdotcodetest.ring, block #19.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#-------------------------------------#

pr()

Dot = new stzDotCode()
Dot.SetCode('

digraph SEQ_DIAGRAM {
    graph [overlap=true, splines=line, nodesep=1.0, ordering=out];
    edge [arrowhead=none];
    node [shape=none, width=0, height=0, label=""];

    {
        rank=same;
        node[shape=rectangle, height=0.7, width=2];
        api_a[label="API A"];
        api_b[label="API B"];
        api_c[label="API C"];
    }
    // Draw vertical lines
    {
        edge [style=dashed, weight=6];
        api_a -> a1 -> a2 -> a3;
        a3 -> a4 [penwidth=5, style=solid];
        a4 -> a5;
    }
    {
        edge [style=dashed, weight=6];
        api_b -> b1 -> b2 -> b3 -> b4;
        b4 -> b5 [penwidth=5; style=solid];
    }
    {
        edge [style=dashed, weight=6];
        api_c -> c1;
        c1-> c2 [penwidth=5, style=solid];
        c2 -> c3 -> c4 -> c5;
    }
    // Draws activations
    { rank=same; a1 -> b1 [label="activate()"]; b1 -> c1 [arrowhead=normal]; }
    { rank=same; a2 -> b2 [style=invis]; b2 -> c2 [label="refund()", arrowhead=normal, dir=back]; }
    { rank=same; a3 -> b3 [arrowhead=normal, dir=back, label="place_order()"]; b3 -> c3; }
    { rank=same; a4 -> b4 [label="distribute()", arrowhead=normal]; }
    { rank=same; a5 -> b5 [style=invis]; b5 -> c5 [label="bill_order()", arrowhead=normal]; }
}

')

Dot.Execute()
Dot.View()

#NOTE #TODO Use this technique in stzDiagram to fix the messy
# native "ortho" splines type of Graphiz DOT engine

#NOTE
# There are some important hints on how this was achieved:

# Each component have a list of nodes which have no shape,
# no height and no width.
#
# Each line must be at the same rank, otherwise DOT will position
# them accordingly to their automatic ranking.

# In order to make things straight, all directions are the same:
# from a to b to c. If you invert some of them, DOT will make a mess.
# The trick to achieve the right direction on the arrow is to use dir
# edge attribute.

# Weight attribute on edges is very important to keep vertical
# lines straight. They must outnumber the biggest rank. If you need
# to create a diagram where a rank will go as deep as 100, your weight
# must be 101 at least or it will be impossible to have a straight
# dashed vertical line.

# In order to get a straigh horizontal line, you have to connect each
# node on the same rank. Otherwise, DOT will bend the line. For instance,
# connecting a1 to c1 is achieved by connecting a1 to b1 and b1 to c1.

#TODO: Seek wher I found this on the internet and reference the author!

pf()
# Executed in 1.30 second(s) in Ring 1.24
