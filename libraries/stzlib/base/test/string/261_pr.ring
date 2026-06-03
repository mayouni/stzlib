# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #261.

load "../../stzBase.ring"


o1 = new stzString(" isNumber( 0+  @item  ) ")
o1.ReplaceMany([ "" ], 'any')

? o1.Content()
#--> " isNumber( 0+  @item  ) "

pf()
# Executed in 0.01 second(s) in Ring 1.21
