# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #954.

load "../../stzBase.ring"

pr()

o1 = new stzString("..STZ..StZ..stz")

# The fellowing calls all return  the same result:

? o1.VizFindCSXT("STZ", :CS = FALSE, [ :Numbered = TRUE ]) + NL
#-->
# ..STZ..StZ..stz
# --^----^----^--
#   3    8    13 

? o1.VizFindXT("stz", [ :Numbered = TRUE, :CS = FALSE ] ) + NL
#-->
# ..STZ..StZ..stz
# --^----^----^--
#   3    8    13 

? o1.VizFindCSXT("stz", :CS = FALSE, [ :Numbered = TRUE ] )
#-->
# ..STZ..StZ..stz
# --^----^----^--
#   3    8    13 

pf()
# Executed in 0.01 second(s) in Ring 1.26
# Executed in 0.02 second(s) in Ring 1.21
