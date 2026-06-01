# Narrative
# --------
# #todo #narration
#
# Extracted from stzStringTest.ring, block #947.

load "../../../stzBase.ring"


pr()

o1 = new stzString("SOFTANZA")

? o1.VizFind("A") + NL
#-->
# SOFTANZA
# ----^--^

? o1.VizFindXT("A", [ :Spacified = TRUE  ]) + NL
#-->
# S O F T A N Z A
# --------^-----^

? o1.VizFindXT("A", [ :Spacified = TRUE, :PositionSign = Heart() ]) + NL
#-->
# S O F T A N Z A
# --------♥-----♥

? o1.VizFindXT("A", [ :Spacified = 1, :PositionSign = Heart(), :Numbered = 1 ]) + NL
#-->
# S O F T A N Z A
# --------♥-----♥
#         9     15

? o1.VizFindBoxed("A") + NL
#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴─•─┴───┴───┴─•─┘

? o1.VizFindBoxedXT("A", [
	:PositionSign = Heart(),
	:AllCorners = :Rounded
]) + NL

#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───╮
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# ╰───┴───┴───┴───┴─♥─┴───┴───┴─♥─╯

? o1.VizFindXT( "A", [
	:Boxed = TRUE,
	:Rounded = TRUE, 
	:AllCorners = :Rounded,

	:Numbered = TRUE,

	:PositionSign = Heart()
])
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───╮
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# ╰───┴───┴───┴───┴─♥─┴───┴───┴─♥─╯
#                   5           8

pf()
# Executed in 0.28 second(s) in Ring 1.24
# Executed in 0.19 second(s) in Ring 1.22
# Executed in 0.23 second(s) in Ring 1.20
