# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #949.
#ERR Error (R14) : Calling Method without definition: vizfindboxedxt

load "../../stzBase.ring"

pr()

o1 = new stzString("SOFTANZA")

? o1.VizFindBoxedXT("A", [
	:PositionChar = "↑", # Or :PositionSign or :HilightChar or :HilightSign
	:Numbered = TRUE,
	:Solid = TRUE,

	:Rounded = TRUE,
	:Corners = [ :round, :round, :rect, :rect ]

]) + NL
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───╮
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴─↑─┴───┴───┴─↑─┘
#                   5           8 

? o1.VizFindBoxedXT("A", [
	:Dashed = TRUE,
	:Rounded = TRUE,

	:PositionSign = "↑",
	:Numbered = TRUE
])
#-->
# ╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
# ┊ S ┊ O ┊ F ┊ T ┊ A ┊ N ┊ Z ┊ A ┊
# ╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴─↑─┴╌╌╌┴╌╌╌┴─↑─╯
#                   5           8

pf()
# Executed in 0.14 second(s) in Ring 1.24
# Executed in 0.08 second(s) in Ring 1.26
