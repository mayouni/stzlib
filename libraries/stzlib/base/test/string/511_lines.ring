# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #511.

load "../../stzBase.ring"

pr()

o1 = new stzString("
lfldfkdlfk
mlsdlk

llkslkflk
   
medmf")

? @@NL( o1.Lines() ) + NL

? o1.NumberOfEmptyLines() + NL
#--> 3

o1.RemoveEmptyLines()
? o1.Content()
#-->
# lfldfkdlfk
# mlsdlk
# llkslkflk
# medmf

pf()
# Executed in 0.01 second(s).
