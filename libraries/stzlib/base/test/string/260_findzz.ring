# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #260.

load "../../stzBase.ring"

pr()

o1 = new stzString(" isNumber( 0+  @item  ) ")

? @@( o1.FindZZ("") )
#--> []

o1.Replace("", "any")
? o1.Content()
#--> " isNumber( 0+  @item  ) "

pf()
# Executed in 0.01 second(s) in Ring 1.21
