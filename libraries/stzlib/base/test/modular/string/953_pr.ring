# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #953.

load "../../../stzBase.ring"


o1 = new stzString("..STZ..StZ..stz")

? o1.vizFindCS("stz", FALSE)
# ..STZ..StZ..stz
# --^----^----^--

pf()
# Executed in almost 0 second(s) in Ring 1.26
# Executed in 0.01 second(s) in Ring 1.24
