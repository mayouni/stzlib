# Narrative
# --------
# # EXAMPLE 17: Record Shapes (Tables)              #
#
# Extracted from stzdotcodetest.ring, block #24.

load "../../stzBase.ring"

# Learn: Record nodes, ports, complex structures  #
#-------------------------------------------------#

pr()

Dot = XDot()
Dot.SetCode('
digraph Records {
    graph [rankdir=LR, bgcolor=white]
    node [fontname="Courier New", fontsize=10]
    
    # Struct-like records
    struct1 [shape=record, label="<f0> left|<f1> mid|<f2> right"]
    struct2 [shape=record, label="<f0> one|<f1> two"]
    struct3 [shape=record, label="<f0> hello|<f1> world"]
    
    # More complex record
    class [shape=record, style=filled, fillcolor=lightblue,
           label="{<name> User|<attrs> - id: int\l- name: string\l- email: string\l|<methods> + login()\l+ logout()\l}"]
    
    # Nested records (like linked list)
    node1 [shape=record, label="<data> 42|<next>"]
    node2 [shape=record, label="<data> 17|<next>"]
    node3 [shape=record, label="<data> 89|<next>"]
    
    # Connect to specific ports
    struct1:f0 -> struct2:f1
    struct1:f1 -> struct3:f0
    struct1:f2 -> struct2:f0
    
    # Linked list
    node1:next -> node2:data
    node2:next -> node3:data
    node3:next -> node1:data [style=dashed, label="circular"]
    
    # Separate the examples visually
    {struct1, struct2, struct3} -> class [style=invis]
    class -> node1 [style=invis]
}
')

Dot.SetOutputFormat("svg")
Dot.ExecuteAndView()

pf()
# Executed in 0.47 second(s) in Ring 1.24
