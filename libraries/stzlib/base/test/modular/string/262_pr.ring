# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #262.

load "../../../stzBase.ring"


o1 = new stzString(" isNumber( 0+  @item  ) ")
? o1.ReplaceManyCSQ([
	" @position ", " @CurrentPosition ",
	" @Current@i ", " @CurrentI ",
	" @EachPosition ", " @EachI " ],

	:By = " @i ", :CS = FALSE).Content()

#--> " isNumber( 0+  @item  ) "

pf()
# Executed in 0.01 second(s) in Ring 1.21
