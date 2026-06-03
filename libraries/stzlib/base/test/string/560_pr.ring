# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #560.

load "../../stzBase.ring"


#                       +----------------------+
#                       |                      |
#                       V                      V
o1 = new stzString("my <<word>> and your <<word>>")
? o1.FindXT("word", :BoundedBy = [ "<<", ">>" ])
#--> [ 6, 24 ]

#                       +----+            +----+
#                       |    |            |    |
#                       V    V            V    V
o1 = new stzString("my <<word>> and your <<word>>")
? o1.FindXT("word", :BoundedBy = [ "<<", ">>" ])
#--> [6, 24]

pf()
# Executed in 0.04 second(s) in Ring 1.22
